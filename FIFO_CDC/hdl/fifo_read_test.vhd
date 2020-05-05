--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: fifo_read_test.vhd
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

library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fifo_read_test is
port (
    CLK : in std_logic;
    RSTn : in std_logic;

    buttons : in std_logic_vector(1 downto 0);

    FIFO_READY : in std_logic;
    R_DAT : in std_logic_vector(31 downto 0);
    R_EN : out std_logic;

    FIFO_ON : out std_logic;
    FIFO_IS_ON : in std_logic;
    FIFO_BYTES : out std_logic_vector(1 downto 0);

    LEDs : out std_logic_vector(7 downto 0)
);
end fifo_read_test;
architecture architecture_fifo_read_test of fifo_read_test is
    signal counter : unsigned(31 downto 0);
    signal BYTES : std_logic_vector(1 downto 0);
    signal FIFO_READY_sig : std_logic;
    signal FIFO_READY_sig2 : std_logic;
    signal LED_sig : std_logic_vector(7 downto 0);
begin

    process(CLK, RSTn)
        variable counter_trunc : std_logic_vector(31 downto 0);
    begin

        case BYTES is
            when "00" =>
                counter_trunc := (7 downto 0 => std_logic_vector(counter(7 downto 0)), others => '0');
                LED_sig <= std_logic_vector(counter(7 downto 0));
            when "01" =>
                counter_trunc := (15 downto 0 => std_logic_vector(counter(15 downto 0)), others => '0');
                LED_sig <= std_logic_vector(counter(15 downto 8));
            when "10" =>
                counter_trunc := (23 downto 0 => std_logic_vector(counter(23 downto 0)), others => '0');
                LED_sig <= std_logic_vector(counter(23 downto 16));
            when "11" =>
                counter_trunc := std_logic_vector(counter);
                LED_sig <= std_logic_vector(counter(31 downto 24));
            when others =>
                counter_trunc := (others => '0');
        end case;

		if(RSTn = '0') then
			counter <= (others => '0');
            LEDs <= (others => '0');
            FIFO_READY_sig <= '0';
            FIFO_READY_sig2 <= '0';
        elsif(rising_edge(CLK)) then
            LEDs(5) <= FIFO_ON;
            LEDs(6) <= FIFO_IS_ON;
            FIFO_READY_sig <= FIFO_READY;
            FIFO_READY_sig2 <= FIFO_READY_sig;

            if(FIFO_READY = '1') then
				R_EN <= '1';
			else
				R_EN <= '0';
            end if;
            if(FIFO_READY_sig2 = '1') then
				counter <= counter + 1;
                if(R_DAT = counter_trunc) then
                    LEDs(7) <= '1';
                else
                    LEDs(7) <= '0';
                end if;
                LEDs(4 downto 0) <= LED_sig(7 downto 3);
            end if;
        end if;
        
        FIFO_BYTES <= BYTES;
    end process;
    
    process(CLK, RSTn)
        variable buttons_last : std_logic_vector(1 downto 0);
        variable states : natural;
        variable next_BYTE : unsigned(1 downto 0);
    begin
        if(RSTn = '0') then
            states := 0;
            BYTES <= "11";
			FIFO_ON <= '0';
        elsif(rising_edge(CLK)) then
            case states is
                when 0 =>
                    FIFO_ON <= '1';
                    if(buttons_last(0) = '0' and buttons(0) = '1') then
                        states := 1;
                    end if;
                    if(buttons_last(1) = '0' and buttons(1) = '1') then
                        states := 1;
                    end if;
                when 1 =>
                    FIFO_ON <= '0';
                    next_BYTE := unsigned(BYTES);
                    next_BYTE := next_BYTE + 1;
                    if(FIFO_IS_ON = '0') then
                        states := 2;
                    end if;
                when 2 =>
                    BYTES <= std_logic_vector(next_BYTE);
                    FIFO_ON <= '1';
                    if(FIFO_IS_ON = '1') then
                        states := 3;
                    end if;
                when 3 =>
                    states := 0;
                when others =>
                    states := 0;
            end case;

            if(buttons_last(0) = '0' and buttons(0) = '1') then
                null;
            end if;

            if(buttons_last(1) = '0' and buttons(1) = '1') then
                null;
            end if;
            buttons_last := buttons;
        end if;
    end process;

   -- architecture body
end architecture_fifo_read_test;
