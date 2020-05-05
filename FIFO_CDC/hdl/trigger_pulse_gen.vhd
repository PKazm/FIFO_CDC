--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: trigger_pulse_gen.vhd
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

entity trigger_pulse_gen is
port (
	clk : in std_logic;
	signal_in : in std_logic;
    pulse : out std_logic
);
end trigger_pulse_gen;
architecture architecture_trigger_pulse_gen of trigger_pulse_gen is

	signal old_signal : std_logic;
begin

	process(clk)
	
	begin
		if(rising_edge(clk)) then
			old_signal <= signal_in;
			
			if(old_signal = '0' and signal_in = '1') then
				pulse <= '1';
			else
				pulse <= '0';
			end if;
		end if;
	end process;

   -- architecture body
end architecture_trigger_pulse_gen;
