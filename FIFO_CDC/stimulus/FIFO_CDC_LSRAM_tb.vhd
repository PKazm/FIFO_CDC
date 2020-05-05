----------------------------------------------------------------------
-- Created by Microsemi SmartDesign Thu Apr 30 23:36:06 2020
-- Testbench Template
-- This is a basic testbench that instantiates your design with basic 
-- clock and reset pins connected.  If your design has special
-- clock/reset or testbench driver requirements then you should 
-- copy this file and modify it. 
----------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FIFO_CDC_LSRAM_tb.vhd
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

entity testbench is
end testbench;

architecture behavioral of testbench is

    constant SYSCLK_PERIOD : time := 10 ns; -- 100MHZ
    constant SYSCLK_PERIOD125 : time := 8 ns;  -- 125MHZ

    signal SYSCLK : std_logic := '0';
    signal SYSCLK125 : std_logic := '0';
    signal NSYSRESET : std_logic := '0';


    type data_type is array (0 to 2048) of std_logic_vector(32 downto 0);
    signal temp_data : data_type := (others => (others => '0'));

    signal ADDR_MAX : std_logic_vector(10 downto 0) := (others => '1');

    signal BYTES_STABLE : std_logic := '1';

    signal W_ADDR_next : std_logic_vector(10 downto 0);
    signal R_ADDR_next : std_logic_vector(10 downto 0);

    component FIFO_CDC_LSRAM
        -- ports
        port( 
            -- Inputs
            W_DIN : in std_logic_vector(32 downto 0);
            W_ADDR : in std_logic_vector(10 downto 0);
            R_ADDR : in std_logic_vector(10 downto 0);
            W_CLK : in std_logic;
            R_CLK : in std_logic;
            W_WEN : in std_logic;
            BYTES : in std_logic_vector(1 downto 0);

            -- Outputs
            R_DOUT : out std_logic_vector(32 downto 0)

            -- Inouts

        );
    end component;


    signal W_DIN    : std_logic_vector(32 downto 0);
    signal W_ADDR   : std_logic_vector(10 downto 0);
    signal R_ADDR   : std_logic_vector(10 downto 0);
    signal R_DOUT   : std_logic_vector(32 downto 0);
    --signal W_CLK    : std_logic;
    --signal R_CLK    : std_logic;
    signal W_WEN    : std_logic;
    signal BYTES    : std_logic_vector(1 downto 0);

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

    -- Instantiate Unit Under Test:  FIFO_CDC_LSRAM
    FIFO_CDC_LSRAM_0 : FIFO_CDC_LSRAM
        -- port map
        port map( 
            -- Inputs
            W_CLK => SYSCLK125,
            R_CLK => SYSCLK,

            W_DIN => W_DIN,
            W_ADDR => W_ADDR,
            R_ADDR => R_ADDR,
            W_WEN => W_WEN,
            BYTES => BYTES,

            -- Outputs
            R_DOUT => R_DOUT

            -- Inouts

        );

    R_ADDR_next <= std_logic_vector(unsigned(R_ADDR) + 1) when R_ADDR /= ADDR_MAX else (others => '0');

    kobayashi_maru_100 : process
    begin

        R_ADDR <= (others => '0');
        
        --R_DOUT

        if(NSYSRESET /= '1') then
            wait until (NSYSRESET = '1');
        end if;

        wait until (SYSCLK = '1');

        loop
            if(R_ADDR_next /= W_ADDR and R_ADDR_next /= W_ADDR_next) then
                -- haven't run into W_ADDR yet
                wait for (SYSCLK_PERIOD * 1); -- LSRAM is registered DOUT
                assert (temp_data(to_integer(unsigned(R_ADDR))) = R_DOUT)
                    report "Data Mismatch i = " & to_hstring(R_ADDR) & 
                            " expected: " & to_hstring(temp_data(to_integer(unsigned(R_ADDR)))) &
                            " got: " & to_hstring(R_DOUT)
                    severity error;

                if(R_ADDR = ADDR_MAX) then
                    R_ADDR <= (others => '0');
                else
                    R_ADDR <= std_logic_vector(unsigned(R_ADDR) + 1);
                end if;
            end if;
            wait for (SYSCLK_PERIOD * 1);

            if(BYTES_STABLE = '0') then
                R_ADDR <= (others => '0');
            end if;
        end loop;

        wait;
    end process;


    W_ADDR_next <= std_logic_vector(unsigned(W_ADDR) + 1) when W_ADDR /= ADDR_MAX else (others => '0');

    kobayashi_maru_125 : process
        variable seed1, seed2 : integer := 1;
        variable r : real;
    begin

        BYTES <= "00";
        W_WEN <= '0';
        W_DIN <= (others => '0');
        W_ADDR <= (others => '0');
        ADDR_MAX <= std_logic_vector(to_unsigned(2047, ADDR_MAX'length));

        if(NSYSRESET /= '1') then
            wait until (NSYSRESET = '1');
        end if;

        wait until (SYSCLK125 = '1');

        --=========================================================================
        -- Test 8 bit 2048 location mode
        --=========================================================================

        report "TEST START 8 bit 2048 location";
        for i in 0 to 4096 loop

            if(W_ADDR_next = R_ADDR) then
                W_WEN <= '0';
                wait until (W_ADDR_next /= R_ADDR);
                wait until (SYSCLK125 = '1');
            end if;

            W_DIN <= (others => '0');
            for k in 0 to 7 loop
                uniform(seed1, seed2, r);
                W_DIN(k) <= '1' when r > 0.5 else '0';
            end loop;
            temp_data(to_integer(unsigned(W_ADDR))) <= W_DIN;

            W_WEN <= '1';
            
            wait for (SYSCLK_PERIOD125 * 1);
            
            if(W_ADDR = ADDR_MAX) then
                W_ADDR <= (others => '0');
            else
                W_ADDR <= std_logic_vector(unsigned(W_ADDR) + 1);
            end if;


        end loop;
        W_WEN <= '0';
        report "TEST COMPLETE 8 bit 2048 location";

        if(R_ADDR_next /= W_ADDR) then
            wait until (R_ADDR_next = W_ADDR);
        end if;

        wait for (SYSCLK_PERIOD125 * 10);
        BYTES <= "01";
        ADDR_MAX <= std_logic_vector(to_unsigned(1023, ADDR_MAX'length));
        W_ADDR <= (others => '0');

        BYTES_STABLE <= '0';
        wait for (SYSCLK_PERIOD125 * 5);
        BYTES_STABLE <= '1';
        wait for (SYSCLK_PERIOD125 * 5);

        wait until (SYSCLK125 = '1');

        --=========================================================================
        -- Test 16 bit 1024 location mode
        --=========================================================================

        report "TEST START 16 bit 1024 location";
        for i in 0 to 2048 loop

            if(W_ADDR_next = R_ADDR) then
                W_WEN <= '0';
                wait until (W_ADDR_next /= R_ADDR);
                wait until (SYSCLK125 = '1');
            end if;

            W_DIN <= (others => '0');
            for k in 0 to 15 loop
                uniform(seed1, seed2, r);
                W_DIN(k) <= '1' when r > 0.5 else '0';
            end loop;
            temp_data(to_integer(unsigned(W_ADDR))) <= W_DIN;

            W_WEN <= '1';
            
            wait for (SYSCLK_PERIOD125 * 1);
            
            if(W_ADDR = ADDR_MAX) then
                W_ADDR <= (others => '0');
            else
                W_ADDR <= std_logic_vector(unsigned(W_ADDR) + 1);
            end if;


        end loop;
        W_WEN <= '0';
        report "TEST COMPLETE 16 bit 1024 location";

        if(R_ADDR_next /= W_ADDR) then
            wait until (R_ADDR_next = W_ADDR);
        end if;

        wait for (SYSCLK_PERIOD125 * 10);
        ADDR_MAX <= std_logic_vector(to_unsigned(511, ADDR_MAX'length));
        BYTES <= "10";
        W_ADDR <= (others => '0');

        BYTES_STABLE <= '0';
        wait for (SYSCLK_PERIOD125 * 5);
        BYTES_STABLE <= '1';
        wait for (SYSCLK_PERIOD125 * 5);

        wait until (SYSCLK125 = '1');

        --=========================================================================
        -- Test 24 bit 512 location mode
        --=========================================================================

        report "TEST START 24 bit 512 location";
        for i in 0 to 1024 loop

            if(W_ADDR_next = R_ADDR) then
                W_WEN <= '0';
                wait until (W_ADDR_next /= R_ADDR);
                wait until (SYSCLK125 = '1');
            end if;

            W_DIN <= (others => '0');
            for k in 0 to 23 loop
                uniform(seed1, seed2, r);
                W_DIN(k) <= '1' when r > 0.5 else '0';
            end loop;
            temp_data(to_integer(unsigned(W_ADDR))) <= W_DIN;

            W_WEN <= '1';
            
            wait for (SYSCLK_PERIOD125 * 1);
            
            if(W_ADDR = ADDR_MAX) then
                W_ADDR <= (others => '0');
            else
                W_ADDR <= std_logic_vector(unsigned(W_ADDR) + 1);
            end if;


        end loop;
        W_WEN <= '0';
        report "TEST COMPLETE 24 bit 512 location";

        if(R_ADDR_next /= W_ADDR) then
            wait until (R_ADDR_next = W_ADDR);
        end if;

        wait for (SYSCLK_PERIOD125 * 10);
        ADDR_MAX <= std_logic_vector(to_unsigned(511, ADDR_MAX'length));
        BYTES <= "11";
        W_ADDR <= (others => '0');

        BYTES_STABLE <= '0';
        wait for (SYSCLK_PERIOD125 * 5);
        BYTES_STABLE <= '1';
        wait for (SYSCLK_PERIOD125 * 5);

        wait until (SYSCLK125 = '1');

        --=========================================================================
        -- Test 32 bit 512 location mode
        --=========================================================================

        report "TEST START 32 bit 512 location";
        for i in 0 to 1024 loop

            if(W_ADDR_next = R_ADDR) then
                W_WEN <= '0';
                wait until (W_ADDR_next /= R_ADDR);
                wait until (SYSCLK125 = '1');
            end if;

            W_DIN <= (others => '0');
            for k in 0 to 31 loop
                uniform(seed1, seed2, r);
                W_DIN(k) <= '1' when r > 0.5 else '0';
            end loop;
            temp_data(to_integer(unsigned(W_ADDR))) <= W_DIN;

            W_WEN <= '1';
            
            wait for (SYSCLK_PERIOD125 * 1);
            
            if(W_ADDR = ADDR_MAX) then
                W_ADDR <= (others => '0');
            else
                W_ADDR <= std_logic_vector(unsigned(W_ADDR) + 1);
            end if;


        end loop;
        W_WEN <= '0';
        report "TEST COMPLETE 32 bit 512 location";

        

        wait;
    end process;

end behavioral;

