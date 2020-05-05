--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Gray_Code_Counter.vhd
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
use IEEE.math_real.all;

use work.Gray_Code_package.all;

entity Gray_Code_Counter is
generic (
	g_n_bits : natural := 8
);
port (
    CLK : in std_logic;
    RSTn : in std_logic;

    max_cnt_bin : in std_logic_vector(g_n_bits - 1 downto 0);
    cnt_clr : in std_logic;

    incr_cntr : in std_logic;
    gray_out : out std_logic_vector(g_n_bits - 1 downto 0)
);
end Gray_Code_Counter;
architecture architecture_Gray_Code_Counter of Gray_Code_Counter is

    signal bin_cntr : unsigned(g_n_bits - 1 downto 0);

begin

    p_cntr : process(CLK, RSTn)
    begin
        if(RSTn = '0') then
            bin_cntr <= (others => '0');
        elsif(rising_edge(CLK)) then
            if(cnt_clr = '1') then
                bin_cntr <= (others => '0');
            else
                if(incr_cntr = '1') then
                    if(bin_cntr = unsigned(max_cnt_bin)) then
                        bin_cntr <= (others => '0');
                    else
                        bin_cntr <= bin_cntr + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;

    gray_out <= f_Binary_to_Gray(std_logic_vector(bin_cntr));

   -- architecture body
end architecture_Gray_Code_Counter;
