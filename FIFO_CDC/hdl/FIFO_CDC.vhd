--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FIFO_CDC.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
-- g_ctrl_side = 0 for control signals to enter in R_CLK domain
-- g_ctrl_side = 1 for control signals to enter in W_CLK domain
--
-- Targeted device: <Family::SmartFusion2> <Die::M2S010> <Package::144 TQ>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.Gray_Code_package.all;


entity FIFO_CDC is
generic (
    g_ctrl_dom_w : natural := 0
);
port (
    W_CLK   : in std_logic;
    R_CLK   : in std_logic;
    RSTn    : in std_logic;

    W_EN    : in std_logic;
    W_DATA  : in std_logic_vector(31 downto 0);
    W_FULL  : out std_logic;

    R_EN    : in std_logic;
    R_DATA  : out std_logic_vector(31 downto 0);
    R_READY : out std_logic;

    FIFO_ON : in std_logic;
    FIFO_IS_ON : out std_logic;
    BYTES   : in std_logic_vector(1 downto 0)
);
end FIFO_CDC;
architecture architecture_FIFO_CDC of FIFO_CDC is

    constant ADDR_N_BITS : natural := 11;
    constant SYNC_DEPTH : natural := 2;

    constant STRTUP_MAX : natural := 3;
    signal   strtup_cnt_w : natural range 0 to STRTUP_MAX + 1;
    signal   strtup_cnt_r : natural range 0 to STRTUP_MAX;

    type addr_sync_type is array (0 to SYNC_DEPTH - 1) of std_logic_vector(ADDR_N_BITS - 1 downto 0);
    type addr_w_depth_type is array (0 to 2) of std_logic_vector(ADDR_N_BITS - 1 downto 0);
    type addr_r_depth_type is array (0 to 1) of std_logic_vector(ADDR_N_BITS - 1 downto 0);

    --=========================================================================
    -- Internal Control Signals
    --=========================================================================
    signal M_CLK        : std_logic; -- master clock determined by generic parameter
    signal S_CLK        : std_logic; -- slave clock determined by generic parameter
    signal INT_ON       : std_logic;
    signal MST_ON       : std_logic;
    signal SLV_ON       : std_logic;
    signal SLVDOM_ON    : std_logic_vector(SYNC_DEPTH - 1 downto 0);
    signal INT_IS_ON    : std_logic;
    signal MST_IS_ON    : std_logic;
    signal SLV_IS_ON    : std_logic;
    signal SLVDOM_IS_ON : std_logic_vector(SYNC_DEPTH - 1 downto 0);
    --=========================================================================
    -- Signals for logic in the W_CLK domain
    --=========================================================================
    signal W_DATA_sig       : std_logic_vector(31 downto 0);
    signal W_FULL_sig       : std_logic;
    signal W_ALMSTFULL_sig  : std_logic;
    signal W_ON             : std_logic;
    signal W_IS_ON          : std_logic;
    signal W_adr_gray       : addr_w_depth_type;

    signal W_raddr : addr_sync_type;
    signal W_raddr_next : addr_sync_type;

    signal W_bytes : std_logic_vector(1 downto 0);

    --=========================================================================
    -- Signals for logic in the R_CLK domain
    --=========================================================================
    signal R_RDY_sig        : std_logic;
    signal R_ON             : std_logic;
    signal R_IS_ON          : std_logic;
    signal R_adr_gray       : addr_r_depth_type;

    signal R_waddr : addr_sync_type;
    signal R_waddr_next : addr_sync_type;

    signal R_bytes : std_logic_vector(1 downto 0);

    --=========================================================================
    -- Functions
    --=========================================================================

    -- These shift functions shift an array of their respective data types towards 0
    -- Overall usage is that new data is entered at data'high and data to be used
    -- (e.g. synchronizer) is at data(0)

    function f_shift_vect(input_dat : in addr_sync_type; new_dat : in std_logic_vector) return addr_sync_type is
        variable shifted_dat : addr_sync_type;
    begin
        shifted_dat(shifted_dat'high) := new_dat;
        for i in (shifted_dat'high - 1) downto 0 loop
            shifted_dat(i) := input_dat(i + 1);
        end loop;
        return shifted_dat;
    end;

    function f_shift_vect_wadr(input_dat : in addr_w_depth_type; new_dat : in std_logic_vector) return addr_w_depth_type is
        variable shifted_dat : addr_w_depth_type;
    begin
        shifted_dat(shifted_dat'high) := new_dat;
        for i in (shifted_dat'high - 1) downto 0 loop
            shifted_dat(i) := input_dat(i + 1);
        end loop;
        return shifted_dat;
    end;

    function f_shift_vect_radr(input_dat : in addr_r_depth_type; new_dat : in std_logic_vector) return addr_r_depth_type is
        variable shifted_dat : addr_r_depth_type;
    begin
        shifted_dat(shifted_dat'high) := new_dat;
        for i in (shifted_dat'high - 1) downto 0 loop
            shifted_dat(i) := input_dat(i + 1);
        end loop;
        return shifted_dat;
    end;

    function f_shift_bits(input_dat : in std_logic_vector; new_dat : in std_logic) return std_logic_vector is
        variable shifted_dat : std_logic_vector(input_dat'high downto 0);
    begin
        shifted_dat(shifted_dat'high) := new_dat;
        for i in (shifted_dat'high - 1) downto 0 loop
            shifted_dat(i) := input_dat(i + 1);
        end loop;
        return shifted_dat;
    end;


    --=========================================================================
    -- Components and their signals
    --=========================================================================
    
    component FIFO_CDC_LSRAM
        -- ports
        port(
            -- Inputs
            W_DIN : in std_logic_vector(31 downto 0);
            W_ADDR : in std_logic_vector(10 downto 0);
            R_ADDR : in std_logic_vector(10 downto 0);
            W_CLK : in std_logic;
            R_CLK : in std_logic;
            W_WEN : in std_logic;
            BYTES : in std_logic_vector(1 downto 0);

            -- Outputs
            R_DOUT : out std_logic_vector(31 downto 0)
        );
    end component;

    signal W_ADDR       : std_logic_vector(10 downto 0);
    signal R_ADDR       : std_logic_vector(10 downto 0);
    signal W_WEN        : std_logic;
    signal BYTES_sig    : std_logic_vector(1 downto 0);

    component Gray_Code_Counter
        generic(
            g_n_bits : natural
        );
        port(
            CLK : in std_logic;
            RSTn : in std_logic;

            max_cnt_bin : in std_logic_vector(g_n_bits - 1 downto 0);
            cnt_clr : in std_logic;
            incr_cntr : in std_logic;
            gray_out : out std_logic_vector(g_n_bits - 1 downto 0)
        );
    end component;

    signal W_max_cnt_bin : std_logic_vector(ADDR_N_BITS - 1 downto 0);
    signal W_cnt_clr : std_logic;
    signal W_incr_cntr : std_logic;
    signal W_gray_out : std_logic_vector(ADDR_N_BITS - 1 downto 0);

    signal R_max_cnt_bin : std_logic_vector(ADDR_N_BITS - 1 downto 0);
    signal R_cnt_clr : std_logic;
    signal R_incr_cntr : std_logic;
    signal R_incr_cntr_strtup : std_logic;
    signal R_gray_out : std_logic_vector(ADDR_N_BITS - 1 downto 0);

begin


    FIFO_CDC_LSRAM_0 : FIFO_CDC_LSRAM
        -- port map
        port map(
            -- Inputs
            W_CLK => W_CLK,
            R_CLK => R_CLK,

            W_DIN => W_DATA_sig,
            W_ADDR => W_ADDR,
            R_ADDR => R_ADDR,
            W_WEN => W_WEN,
            BYTES => BYTES_sig,
            --BYTES => "11",

            -- Outputs
            R_DOUT => R_DATA
        );

    --=========================================================================
    -- CONTROL SIGNALS
    -- this section has processes from both clock domains
    --=========================================================================

    gen_W_ctrl_YES : if(g_ctrl_dom_w /= 0) generate
        M_CLK <= W_CLK;
        S_CLK <= R_CLK;

        W_ON <= FIFO_ON;
        SLV_ON <= FIFO_ON;
        R_ON <= SLVDOM_ON(0);   -- CDC happened
        SLV_IS_ON <= R_IS_ON;   -- this feeds a sync
        MST_IS_ON <= W_IS_ON;

        R_READY <= R_RDY_sig;
        W_FULL <= (W_FULL_sig or W_ALMSTFULL_sig) or not INT_IS_ON;

    end generate gen_W_ctrl_YES;

    gen_W_ctrl_NO : if(g_ctrl_dom_w = 0) generate
        M_CLK <= R_CLK;
        S_CLK <= W_CLK;

        R_ON <= FIFO_ON;
        SLV_ON <= FIFO_ON;
        W_ON <= SLVDOM_ON(0);   -- CDC happened
        SLV_IS_ON <= W_IS_ON;   -- this feeds a sync
        MST_IS_ON <= R_IS_ON;

        R_READY <= R_RDY_sig and INT_IS_ON;
        W_FULL <= W_FULL_sig or W_ALMSTFULL_sig;

    end generate gen_W_ctrl_NO;

    -- Sync ctrl responses, handshakes
    p_ctrl_mst_sync : process(M_CLK, RSTn)
    begin
        if(RSTn = '0') then
            SLVDOM_IS_ON <= (others => '0');
        elsif(rising_edge(M_CLK)) then
            SLVDOM_IS_ON <= f_shift_bits(SLVDOM_IS_ON, SLV_IS_ON);
        end if;
    end process;

    -- Sync ctrl signals into the slave domain
    p_ctrl_slv_sync : process(S_CLK, RSTn)
    begin
        if(RSTn = '0') then
            SLVDOM_ON <= (others => '0');
        elsif(rising_edge(S_CLK)) then
            SLVDOM_ON <= f_shift_bits(SLVDOM_ON, SLV_ON);
        end if;
    end process;


    p_ctrl_logic_s : process(M_CLK, RSTn)
    begin
        if(RSTn = '0') then
            INT_IS_ON <= '0';
            BYTES_sig <= (others => '0');
        elsif(rising_edge(M_CLK)) then
            INT_IS_ON <= MST_IS_ON and SLVDOM_IS_ON(0);
			
			-- test if FIFO is off, if off, update LSRAM data width
            if(INT_IS_ON = '0') then
                BYTES_sig <= BYTES;
            end if;
        end if;
    end process;

    p_ctrl_logic_c : process(INT_IS_ON)
    begin
        FIFO_IS_ON <= INT_IS_ON;
    end process;


    --=========================================================================
    -- LOGIC USING W_CLK BELOW
    -- writing data into the FIFO
    --=========================================================================

    Gray_Code_Counter_W : Gray_Code_Counter
        generic map(
            g_n_bits => ADDR_N_BITS
        )
        port map(
            CLK => W_CLK,
            RSTn => RSTn,
            max_cnt_bin => W_max_cnt_bin,
            cnt_clr => W_cnt_clr,
            incr_cntr => W_incr_cntr,
            gray_out => W_gray_out
        );

    p_W_sync : process(W_CLK, RSTn)
    begin
        if(RSTn = '0') then
            W_raddr <= (others => (others => '0'));
            W_raddr_next <= (others => (others => '0'));
        elsif(rising_edge(W_CLK)) then
            if(W_ON = '0') then
                null;
            else
                W_raddr_next <= f_shift_vect(w_raddr_next, R_adr_gray(1));
                W_raddr <= f_shift_vect(w_raddr, R_adr_gray(0));
            end if;
        end if;
    end process;

    p_W_logic_s : process(W_CLK, RSTn)
    begin
        if(RSTn = '0') then
            W_bytes <= (others => '0');
            W_adr_gray <= (others => (others => '0'));
            W_IS_ON <= '0';
            strtup_cnt_w <= 0;
            W_WEN <= '0';
            W_DATA_sig <= (others => '0');
            W_cnt_clr <= '0';
            W_incr_cntr <= '0';
        elsif(rising_edge(W_CLK)) then
            if(W_ON = '0') then
                -- FIFO configuration updates while FIFO is off
                -- these signals may have crossed a CDC but they should be stable and unused until W_ON = '1'
                W_bytes <= BYTES;
                W_IS_ON <= '0';
                strtup_cnt_w <= 0;
                W_WEN <= '0';
                W_cnt_clr <= '1';
                W_incr_cntr <= '0';
            else
                -- Do normal FIFO write stuff
                W_cnt_clr <= '0';

                if(strtup_cnt_w /= STRTUP_MAX + 1) then
                    strtup_cnt_w <= strtup_cnt_w + 1;
                    case strtup_cnt_w is
                        when 0 =>
                            W_incr_cntr <= '1';
                        when 1 =>
                            W_incr_cntr <= '1';
                            W_adr_gray(0) <= W_gray_out;
                        when 2 =>
                            W_incr_cntr <= '1';
                            W_adr_gray(1) <= W_gray_out;
                        when 3 =>
                            W_incr_cntr <= '0';
                            W_adr_gray(2) <= W_gray_out;
                        when others =>
                            W_incr_cntr <= '0';
                    end case;
                else
                    W_IS_ON <= '1';

                    if(W_FULL_sig = '1') then
                        W_WEN <= '0';
                        W_incr_cntr <= '0';
                    else

                        if(W_EN = '1') then
                            W_DATA_sig <= W_DATA;
                            W_WEN <= '1';
                            W_incr_cntr <= '1';
                        else
                            W_WEN <= '0';
                            W_incr_cntr <= '0';
                        end if;

                        if(W_WEN = '1') then
                            W_adr_gray <= f_shift_vect_wadr(W_adr_gray, W_gray_out);
                        else
                            null;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    p_W_logic_c : process(W_FULL_sig, W_bytes, W_adr_gray(0), W_adr_gray(1), W_adr_gray(2), W_raddr(0), W_raddr(1))
    begin
        
        W_ADDR <= W_adr_gray(0);

        case W_bytes is
            when "00" =>
                W_max_cnt_bin <= (others => '1');
            when "01" =>
                W_max_cnt_bin <= (W_max_cnt_bin'high => '0', others => '1');
            when "10" =>
                W_max_cnt_bin <= (W_max_cnt_bin'high downto W_max_cnt_bin'high - 1 => '0', others => '1');
            when "11" =>
                W_max_cnt_bin <= (W_max_cnt_bin'high downto W_max_cnt_bin'high - 2 => '0', others => '1');
            when others =>
                W_max_cnt_bin <= (others => '1');
        end case;

        if(W_adr_gray(1) = W_raddr(0) or W_adr_gray(2) = W_raddr(0)) then
            W_ALMSTFULL_sig <= '1';
        else
            W_ALMSTFULL_sig <= '0';
        end if;

        if(W_adr_gray(1) = W_raddr(0)) then
            W_FULL_sig <= '1';
        else
            W_FULL_sig <= '0';
        end if;
    end process;

    --=========================================================================
    -- LOGIC USING R_CLK BELOW
    -- reading data out of the FIFO
    --=========================================================================

    Gray_Code_Counter_R : Gray_Code_Counter
        generic map(
            g_n_bits => ADDR_N_BITS
        )
        port map(
            CLK => R_CLK,
            RSTn => RSTn,
            max_cnt_bin => R_max_cnt_bin,
            cnt_clr => R_cnt_clr,
            incr_cntr => R_incr_cntr,
            gray_out => R_gray_out
        );

    p_R_sync : process(R_CLK, RSTn)
    begin
        if(RSTn = '0') then
            R_waddr <= (others => (others => '0'));
            R_waddr_next <= (others => (others => '0'));
        elsif(rising_edge(R_CLK)) then
            if(R_ON = '0') then
                null;
            else
                R_waddr_next <= f_shift_vect(R_waddr_next, W_adr_gray(1));
                R_waddr <= f_shift_vect(R_waddr, W_adr_gray(0));
            end if;
        end if;
    end process;

    p_R_logic_s : process(R_CLK, RSTn)
        --variable strtup_cnt : natural range 0 to STRTUP_MAX;
    begin
        if(RSTn = '0') then
            R_bytes <= (others => '0');
            R_adr_gray <= (others => (others => '0'));
            R_IS_ON <= '0';
            strtup_cnt_r <= 0;
            R_RDY_sig <= '0';
            R_cnt_clr <= '0';
            R_incr_cntr_strtup <= '0';
        elsif(rising_edge(R_CLK)) then
            if(R_ON = '0') then
                -- FIFO configuration updates while FIFO is off
                -- these signals may have crossed a CDC but they should be stable and unused until R_ON = '1'
                R_bytes <= BYTES;
                R_IS_ON <= '0';
                strtup_cnt_r <= 0;
                R_RDY_sig <= '0';
                R_cnt_clr <= '1';
                R_incr_cntr_strtup <= '0';
            else
                -- Do normal FIFO write stuff
                R_cnt_clr <= '0';

                if(strtup_cnt_r /= STRTUP_MAX) then
                    strtup_cnt_r <= strtup_cnt_r + 1;
                    case strtup_cnt_r is
                        when 0 =>
                            R_incr_cntr_strtup <= '1';
                        when 1 =>
                            R_incr_cntr_strtup <= '1';
                            R_adr_gray(0) <= R_gray_out;
                        when 2 =>
                            R_incr_cntr_strtup <= '0';
                            R_adr_gray(1) <= R_gray_out;
                        when others =>
                            R_incr_cntr_strtup <= '0';
                    end case;
                else
                    R_IS_ON <= '1';
                    if(R_adr_gray(1) = R_waddr(0) or R_adr_gray(1) = R_waddr_next(0)) then
                        -- next read adr and current or next write adr are the same
                        R_RDY_sig <= '0';
                        --R_incr_cntr <= '0';
                    else
                        R_RDY_sig <= '1';
                        if(R_EN = '1') then
                            --R_incr_cntr <= '1';
                            R_adr_gray <= f_shift_vect_radr(R_adr_gray, R_gray_out);
                        else
                            --R_incr_cntr <= '0';
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    p_R_logic_c : process(R_bytes, R_adr_gray(0), R_adr_gray(1), R_waddr(0), R_waddr_next(0), R_EN, R_incr_cntr_strtup)
    begin

        if((R_adr_gray(1) /= R_waddr(0) and R_adr_gray(1) /= R_waddr_next(0)) and R_EN = '1') then
            R_incr_cntr <= '1';
        elsif(R_incr_cntr_strtup = '1') then
            R_incr_cntr <= '1';
        else
            R_incr_cntr <= '0';
        end if;
        R_ADDR <= R_adr_gray(0);

        case R_bytes is
            when "00" =>
                R_max_cnt_bin <= (others => '1');
            when "01" =>
                R_max_cnt_bin <= (R_max_cnt_bin'high => '0', others => '1');
            when "10" =>
                R_max_cnt_bin <= (R_max_cnt_bin'high downto R_max_cnt_bin'high - 1 => '0', others => '1');
            when "11" =>
                R_max_cnt_bin <= (R_max_cnt_bin'high downto R_max_cnt_bin'high - 2 => '0', others => '1');
            when others =>
                R_max_cnt_bin <= (others => '1');
        end case;
    end process;

   -- architecture body
end architecture_FIFO_CDC;
