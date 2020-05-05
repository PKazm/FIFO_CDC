--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: fifo_write_test.vhd
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

entity fifo_write_test is
port (
    CLK : in std_logic;
    RSTn : in std_logic;

    FIFO_FULL : in std_logic;
    W_DAT : out std_logic_vector(31 downto 0);
    W_EN : out std_logic
);
end fifo_write_test;
architecture architecture_fifo_write_test of fifo_write_test is
    signal counter : unsigned(31 downto 0);
begin

	process(CLK, RSTn)
	begin
		if(RSTn = '0') then
            counter <= (others => '0');
            W_DAT <= (others => '0');
            W_EN <= '0';
		elsif(rising_edge(CLK)) then
			if(FIFO_FULL = '0') then
				-- write data into FIFO
				W_DAT <= std_logic_vector(counter);
				counter <= counter + 1;
				W_EN <= '1';
			else
				W_EN <= '0';
			end if;
		end if;
	end process;

end architecture_fifo_write_test;
