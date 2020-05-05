--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: Gray_Code_package.vhd
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


package Gray_Code_package is

    function f_Binary_to_Gray(input_bin : in std_logic_vector)
        return std_logic_vector;

    function f_Gray_to_Binary(input_gray : in std_logic_vector)
        return std_logic_vector;

end package Gray_Code_package;

package body Gray_Code_package is

    function f_Binary_to_Gray(input_bin : in std_logic_vector) return std_logic_vector is
        variable gray_code : std_logic_vector(input_bin'high downto 0);
    begin
        gray_code := input_bin xor ('0' & input_bin(input_bin'high downto 1));
        return gray_code;
    end;

    function f_Gray_to_Binary(input_gray : in std_logic_vector) return std_logic_vector is
        variable bin_val : std_logic_vector(input_gray'high downto 0);
    begin
        bin_val(bin_val'high) := input_gray(input_gray'high);
        for i in (input_gray'high - 1) downto 0 loop
            bin_val(i) := bin_val(i + 1) xor input_gray(i);
        end loop;
        return bin_val;
    end;

end package body Gray_Code_package;