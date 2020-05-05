----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Mon May  4 00:41:37 2020
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FIFO_CDC_tb.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- <Description here>
--
-- Targeted device: <Family::SmartFusion2> <Die::M2S010> <Package::144 TQ>
-- Author: <Name>
--
--------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;


library modelsim_lib;
use modelsim_lib.util.all;

library osvvm;
use osvvm.RandomPkg.all;
use osvvm.CoveragePkg.all;

entity testbench is
end testbench;

architecture behavioral of testbench is

    constant SYSCLK_PERIOD : time := 10 ns; -- 100MHZ
    constant SYSCLK_PERIOD125 : time := 8 ns; -- 125MHZ

    signal SYSCLK : std_logic := '0';
    signal SYSCLK125 : std_logic := '0';
    signal NSYSRESET : std_logic := '0';

    constant CTRL_MASTER : natural := 0;    -- 0: R_CLK, 1: W_CLK

    constant ADDR_N_BITS : natural := 11;
    constant SYNC_DEPTH : natural := 2;
    constant STRTUP_MAX : natural := 3;

    type addr_sync_type is array (0 to SYNC_DEPTH - 1) of std_logic_vector(ADDR_N_BITS - 1 downto 0);

    
    signal W_gray_out_spy : std_logic_vector(ADDR_N_BITS - 1 downto 0);
    signal R_gray_out_spy : std_logic_vector(ADDR_N_BITS - 1 downto 0);
    signal W_adr_gray_spy   : addr_sync_type;   -- this shoule be addr_depth_type but its the same and reduces require functions
    signal W_raddr_spy      : addr_sync_type;
    signal W_raddr_next_spy : addr_sync_type;
    signal R_adr_gray_spy   : addr_sync_type;   -- this shoule be addr_depth_type but its the same and reduces require functions
    signal R_waddr_spy      : addr_sync_type;
    signal R_waddr_next_spy : addr_sync_type;
    signal strtup_cnt_w_spy : natural range 0 to STRTUP_MAX;
    signal strtup_cnt_r_spy : natural range 0 to STRTUP_MAX;

    component FIFO_CDC
        generic(
            g_ctrl_dom_w : natural
        );
        port( 
            -- Inputs
            W_CLK : in std_logic;
            R_CLK : in std_logic;
            RSTn : in std_logic;
            W_EN : in std_logic;
            W_DATA : in std_logic_vector(31 downto 0);
            R_EN : in std_logic;
            FIFO_ON : in std_logic;
            BYTES : in std_logic_vector(1 downto 0);

            -- Outputs
            W_FULL : out std_logic;
            R_DATA : out std_logic_vector(31 downto 0);
            R_READY : out std_logic;
            FIFO_IS_ON : out std_logic

            -- Inouts

        );
    end component;

    signal W_EN_0         : std_logic;
    signal W_DATA_0       : std_logic_vector(31 downto 0);
    signal R_EN_0         : std_logic;
    signal FIFO_ON_0      : std_logic;
    signal BYTES_0        : std_logic_vector(1 downto 0);
    signal W_FULL_0       : std_logic;
    signal R_DATA_0       : std_logic_vector(31 downto 0);
    signal R_READY_0      : std_logic;
    signal FIFO_IS_ON_0   : std_logic;

    signal W_EN_1         : std_logic;
    signal W_DATA_1       : std_logic_vector(31 downto 0);
    signal R_EN_1         : std_logic;
    signal FIFO_ON_1      : std_logic;
    signal BYTES_1        : std_logic_vector(1 downto 0);
    signal W_FULL_1       : std_logic;
    signal R_DATA_1       : std_logic_vector(31 downto 0);
    signal R_READY_1      : std_logic;
    signal FIFO_IS_ON_1   : std_logic;


    type data_type is array (0 to 10000) of std_logic_vector(31 downto 0);
    signal test_data : data_type := (others => (others => '0'));

    signal write_done, read_done : boolean := false;
    signal test_complete : boolean := false;

    shared variable cov_BYTES_0 : CovPType;
    shared variable cov_BYTES_1 : CovPType;

begin

    process
        variable vhdl_initial : BOOLEAN := TRUE;

    begin
        if ( vhdl_initial ) then
            -- Assert Reset
            NSYSRESET <= '0';
            wait for ( SYSCLK_PERIOD * 10 );
            
            NSYSRESET <= '1';
            wait;
        end if;
    end process;

    -- Clock Driver
    SYSCLK <= not SYSCLK after (SYSCLK_PERIOD / 2.0 );
    SYSCLK125 <= not SYSCLK125 after (SYSCLK_PERIOD125 / 2.0 );

    -- Instantiate Unit Under Test:  FIFO_CDC
    FIFO_CDC_0 : FIFO_CDC
        generic map(
            g_ctrl_dom_w => 0
        )
        port map( 
            -- Inputs
            W_CLK => SYSCLK125,
            R_CLK => SYSCLK,
            RSTn => NSYSRESET,
            W_EN => W_EN_0,
            W_DATA => W_DATA_0,
            R_EN => R_EN_0,
            FIFO_ON => FIFO_ON_0,
            BYTES => BYTES_0,

            -- Outputs
            W_FULL => W_FULL_0,
            R_DATA => R_DATA_0,
            R_READY => R_READY_0,
            FIFO_IS_ON => FIFO_IS_ON_0

            -- Inouts

        );

    FIFO_CDC_1 : FIFO_CDC
        generic map(
            g_ctrl_dom_w => 1
        )
        port map( 
            -- Inputs
            W_CLK => SYSCLK125,
            R_CLK => SYSCLK,
            RSTn => NSYSRESET,
            W_EN => W_EN_1,
            W_DATA => W_DATA_1,
            R_EN => R_EN_1,
            FIFO_ON => FIFO_ON_1,
            BYTES => BYTES_1,

            -- Outputs
            W_FULL => W_FULL_1,
            R_DATA => R_DATA_1,
            R_READY => R_READY_1,
            FIFO_IS_ON => FIFO_IS_ON_1

            -- Inouts

        );

    spy_process : process
    begin
        init_signal_spy("FIFO_CDC_0/W_gray_out", "W_gray_out_spy", 1, -1);
        init_signal_spy("FIFO_CDC_0/R_gray_out", "R_gray_out_spy", 1, -1);
        init_signal_spy("FIFO_CDC_0/W_adr_gray", "W_adr_gray_spy", 1, -1);
        init_signal_spy("FIFO_CDC_0/W_raddr", "W_raddr_spy", 1, -1);
        init_signal_spy("FIFO_CDC_0/W_raddr_next", "W_raddr_next_spy", 1, -1);
        init_signal_spy("FIFO_CDC_0/R_adr_gray", "R_adr_gray_spy", 1, -1);
        init_signal_spy("FIFO_CDC_0/R_waddr", "R_waddr_spy", 1, -1);
        init_signal_spy("FIFO_CDC_0/R_waddr_next", "R_waddr_next_spy", 1, -1);
        init_signal_spy("FIFO_CDC_0/strtup_cnt_w", "strtup_cnt_w_spy", 1, -1);
        init_signal_spy("FIFO_CDC_0/strtup_cnt_r", "strtup_cnt_r_spy", 1, -1);
        wait;
    end process;

    r_clk_100 : process
        variable RndBYTES : RandomPType;
        variable smpl_i : natural := 0;
    begin
        wait for 1 ns;

        RndBYTES.InitSeed(RndBYTES'instance_name);

        R_EN_0 <= '0';
        FIFO_ON_0 <= '0';
        BYTES_0 <= "00";

        R_EN_1 <= '0';

        read_done <= false;

        if(NSYSRESET /= '1') then
            wait until (NSYSRESET = '1');
        end if;

        wait until (SYSCLK = '1');

        wait for (SYSCLK_PERIOD * 5);
        FIFO_ON_0 <= '1';


        while (not cov_BYTES_0.iscovered) loop
            cov_BYTES_0.icover(to_integer(unsigned(BYTES_0)));
            report "BYTES_0: " & to_string(BYTES_0);
            smpl_i := 0;

            while (write_done = false or R_READY_0 = '1') loop

                if(R_READY_0 = '1') then
                    R_EN_0 <= '1';
                    wait for (SYSCLK_PERIOD * 1);
                    R_EN_0 <= '0';
                    assert (test_data(smpl_i) = R_DATA_0)
                        report "Data Mismatch i = " & integer'image(smpl_i) &
                                " expected: " & to_hstring(test_data(smpl_i)) &
                                " got: " & to_hstring(R_DATA_0)
                        severity error;

                    smpl_i := smpl_i + 1;
                end if;

                wait for (SYSCLK_PERIOD * 1);

            end loop;

            -- set next BYTE config
            FIFO_ON_0 <= '0';
            wait until (FIFO_IS_ON_0 = '0');
            wait for (SYSCLK_PERIOD * 1);
            BYTES_0 <= RndBYTES.Randslv(0, 3, 2);
            wait for (SYSCLK_PERIOD * 1);
            FIFO_ON_0 <= '1';
            wait until (FIFO_IS_ON_0 = '1');

            wait for (SYSCLK_PERIOD * 1);

        end loop;

        
        FIFO_ON_0 <= '0';
        smpl_i := 0;

        report "read FIFO_CDC_1 start";

        loop
            if(FIFO_IS_ON_1 = '0') then
                smpl_i := 0;
            end if;
            read_done <= true;

            if(R_READY_1 = '1') then
                read_done <= false;
                R_EN_1 <= '1';
                wait for (SYSCLK_PERIOD * 1);
                R_EN_1 <= '0';
                assert (test_data(smpl_i) = R_DATA_1)
                    report "Data Mismatch i = " & integer'image(smpl_i) &
                            " expected: " & to_hstring(test_data(smpl_i)) &
                            " got: " & to_hstring(R_DATA_1)
                    severity error;

                smpl_i := smpl_i + 1;
            end if;

            wait for (SYSCLK_PERIOD * 1);
        end loop;

        wait;
    end process;

    w_clk_125 : process
        variable RndBYTES : RandomPType;
        variable RndDat : RandomPType;
        variable tmp_dat : std_logic_vector(31 downto 0);
    begin
        wait for 1 ns;

        RndDat.InitSeed(RndDat'instance_name);

        W_EN_0 <= '0';
        W_DATA_0 <= (others => '0');

        W_EN_1 <= '0';
        W_DATA_1 <= (others => '0');

        FIFO_ON_1 <= '0';
        BYTES_1 <= "00";

        write_done <= false;

        if(NSYSRESET /= '1') then
            wait until (NSYSRESET = '1');
        end if;

        wait until (SYSCLK125 = '1');

        while (not cov_BYTES_0.iscovered) loop
            wait until (FIFO_IS_ON_0 = '1'); -- possible (probable?) hang here
            write_done <= false;

            wait until (SYSCLK125 = '1');
            wait for (SYSCLK_PERIOD125 * 1);

            for i in 0 to 5000 loop
                if(W_FULL_0 = '1') then
                    W_EN_0 <= '0';
                    wait until (W_FULL_0 = '0');
                    wait until (SYSCLK125 = '1');
                end if;

                case BYTES_0 is
                    when "00" =>
                        tmp_dat := RndDat.Randslv(0, 255, 32);
                    when "01" =>
                        tmp_dat := RndDat.Randslv(0, 65535, 32);
                    when "10" =>
                        tmp_dat := RndDat.Randslv(0, 16777215, 32);
                    when "11" =>
                        tmp_dat := RndDat.Randslv(0, 65535, 16) & RndDat.Randslv(0, 65535, 16);
                    when others =>
                        tmp_dat := (others => '1');
                end case;
                W_DATA_0 <= tmp_dat;
                test_data(i) <= tmp_dat;
                W_EN_0 <= '1';

                wait for (SYSCLK_PERIOD125 * 1);
            end loop;

            W_EN_0 <= '0';
            write_done <= true;
        end loop;


        -- test W_CLK domain master component

        FIFO_ON_1 <= '1';
        if(FIFO_IS_ON_1 = '0') then
            wait until (FIFO_IS_ON_1 = '1');
        end if;

        while (not cov_BYTES_1.iscovered) loop
            cov_BYTES_1.icover(to_integer(unsigned(BYTES_1)));
            report "BYTES_1: " & to_string(BYTES_1);
            write_done <= false;

            for i in 0 to 2000 loop
                if(W_FULL_1 = '1') then
                    W_EN_1 <= '0';
                    wait until (W_FULL_1 = '0');
                    wait until (SYSCLK125 = '1');
                end if;

                case BYTES_1 is
                    when "00" =>
                        tmp_dat := RndDat.Randslv(0, 255, 32);
                    when "01" =>
                        tmp_dat := RndDat.Randslv(0, 65535, 32);
                    when "10" =>
                        tmp_dat := RndDat.Randslv(0, 16777215, 32);
                    when "11" =>
                        tmp_dat := RndDat.Randslv(0, 65535, 16) & RndDat.Randslv(0, 65535, 16);
                    when others =>
                        tmp_dat := (others => '1');
                end case;
                W_DATA_1 <= tmp_dat;
                test_data(i) <= tmp_dat;
                W_EN_1 <= '1';

                wait for (SYSCLK_PERIOD125 * 1);
            end loop;

            W_EN_1 <= '0';
            write_done <= true;

            wait until (R_READY_1 = '0');
            
            wait until (SYSCLK125 = '1');
            wait for (SYSCLK_PERIOD125 * 1);

            -- set next BYTE config
            FIFO_ON_1 <= '0';
            wait until (FIFO_IS_ON_1 = '0');
            wait for (SYSCLK_PERIOD125 * 1);
            BYTES_1 <= RndBYTES.Randslv(0, 3, 2);
            wait for (SYSCLK_PERIOD125 * 1);
            FIFO_ON_1 <= '1';
            wait until (FIFO_IS_ON_1 = '1');

            wait until (SYSCLK125 = '1');
            wait for (SYSCLK_PERIOD125 * 1);
        end loop;

        write_done <= true;

        wait;
    end process;

    

    init_coverage : process
    begin
        cov_BYTES_0.AddBins(GenBin(0, 3));
        cov_BYTES_1.AddBins(GenBin(0, 3));
        wait;
    end process;

    process
    begin
        while test_complete = false loop
            wait for 1 ns;
            if(cov_BYTES_0.iscovered and cov_BYTES_1.iscovered and write_done and read_done) then
                test_complete <= true;
            end if;
        end loop;
        wait;
    end process;

    report_coverage : process
    begin
        wait until test_complete;
        cov_BYTES_0.WriteBin;
        cov_BYTES_1.WriteBin;

        wait;
    end process;

end behavioral;

