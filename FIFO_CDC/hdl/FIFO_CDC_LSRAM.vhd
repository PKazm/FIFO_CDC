--------------------------------------------------------------------------------
-- Company: <Name>
--
-- File: FIFO_CDC_LSRAM.vhd
-- File history:
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--      <Revision number>: <Date>: <Comments>
--
-- Description: 
--
-- This LSRAM instantiation operates as a Two-port LSRAM for FIFO operation
-- Port B is intended as the Write port
-- Port A is intended as the Read port
-- When the data width is set such that not all the bits
-- within either the ADDR, DIN, or DOUT vectors are used
-- only LSB with the desired length are used.
--
-- Targeted device: <Family::SmartFusion2> <Die::M2S010> <Package::144 TQ>
-- Author: <Name>
--
--------------------------------------------------------------------------------

library IEEE;

use IEEE.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;



entity FIFO_CDC_LSRAM is
port (
    W_DIN  : in    std_logic_vector(31 downto 0);
    R_DOUT : out   std_logic_vector(31 downto 0);
    W_ADDR : in    std_logic_vector(10 downto 0);
    R_ADDR : in    std_logic_vector(10 downto 0);
    W_CLK  : in    std_logic;
    R_CLK  : in    std_logic;
    W_WEN  : in    std_logic;
    BYTES  : in    std_logic_vector(1 downto 0)
);
end FIFO_CDC_LSRAM;
architecture architecture_FIFO_CDC_LSRAM of FIFO_CDC_LSRAM is


    signal data_width   : std_logic_vector(2 downto 0);
    signal A_DOUT_sig   : std_logic_vector(17 downto 0);
    signal B_DOUT_sig   : std_logic_vector(17 downto 0);
    signal A_DIN_sig    : std_logic_vector(17 downto 0);
    signal A_ADDR_sig   : std_logic_vector(13 downto 0);
    signal B_DIN_sig    : std_logic_vector(17 downto 0);
    signal B_ADDR_sig   : std_logic_vector(13 downto 0);
    signal A_WEN_sig    : std_logic_vector(1 downto 0);
    signal B_WEN_sig    : std_logic_vector(1 downto 0);

    component RAM1K18
    generic (MEMORYFILE:string := ""; RAMINDEX:string := "");
    port(
        A_DOUT        : out   std_logic_vector(17 downto 0);
        B_DOUT        : out   std_logic_vector(17 downto 0);
        BUSY          : out   std_logic;
        A_CLK         : in    std_logic := 'U';
        A_DOUT_CLK    : in    std_logic := 'U';
        A_ARST_N      : in    std_logic := 'U';
        A_DOUT_EN     : in    std_logic := 'U';
        A_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
        A_DOUT_ARST_N : in    std_logic := 'U';
        A_DOUT_SRST_N : in    std_logic := 'U';
        A_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
        A_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
        A_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
        B_CLK         : in    std_logic := 'U';
        B_DOUT_CLK    : in    std_logic := 'U';
        B_ARST_N      : in    std_logic := 'U';
        B_DOUT_EN     : in    std_logic := 'U';
        B_BLK         : in    std_logic_vector(2 downto 0) := (others => 'U');
        B_DOUT_ARST_N : in    std_logic := 'U';
        B_DOUT_SRST_N : in    std_logic := 'U';
        B_DIN         : in    std_logic_vector(17 downto 0) := (others => 'U');
        B_ADDR        : in    std_logic_vector(13 downto 0) := (others => 'U');
        B_WEN         : in    std_logic_vector(1 downto 0) := (others => 'U');
        A_EN          : in    std_logic := 'U';
        A_DOUT_LAT    : in    std_logic := 'U';
        A_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
        A_WMODE       : in    std_logic := 'U';
        B_EN          : in    std_logic := 'U';
        B_DOUT_LAT    : in    std_logic := 'U';
        B_WIDTH       : in    std_logic_vector(2 downto 0) := (others => 'U');
        B_WMODE       : in    std_logic := 'U';
        SII_LOCK      : in    std_logic := 'U'
        );
    end component;

    component GND
        port(Y : out std_logic); 
    end component;

    component VCC
        port(Y : out std_logic); 
    end component;

begin

    DPSRAM_0 : RAM1K18
        port map(
            A_DOUT          => A_DOUT_sig,
            B_DOUT          => B_DOUT_sig,
            BUSY            => open,
            A_CLK           => R_CLK,
            A_DOUT_CLK      => '1',
            A_ARST_N        => '1',
            A_DOUT_EN       => '1',
            A_BLK           => "111",
            A_DOUT_ARST_N   => '1',
            A_DOUT_SRST_N   => '1',
            A_DIN           => A_DIN_sig,
            A_ADDR          => A_ADDR_sig,
            A_WEN           => A_WEN_sig,
            B_CLK           => W_CLK,
            B_DOUT_CLK      => '1',
            B_ARST_N        => '1',
            B_DOUT_EN       => '1',
            B_BLK           => "111",
            B_DOUT_ARST_N   => '1',
            B_DOUT_SRST_N   => '1',
            B_DIN           => B_DIN_sig,
            B_ADDR          => B_ADDR_sig,
            B_WEN           => B_WEN_sig,
            A_EN            => '1',
            A_DOUT_LAT      => '1',
            A_WIDTH         => data_width,
            A_WMODE         => '0',
            B_EN            => '1',
            B_DOUT_LAT      => '1',
            B_WIDTH         => data_width,
            B_WMODE         => '0',
            SII_LOCK        => '0'
        );


    process(BYTES, W_ADDR, R_ADDR, W_DIN, R_DOUT, A_DOUT_sig, B_DOUT_sig, W_WEN)
    begin

        case BYTES is
            when "00" =>
                -- 1 byte, 8 bit [7:0]
                -- 2048 entries
                data_width  <= "011";

                -- Write stuff
                B_ADDR_sig  <= (13 downto 3 => W_ADDR, others => '0');
                B_DIN_sig   <= (7 downto 0 => W_DIN(7 downto 0), others => '0');
                A_DIN_sig   <= (others => '0');
                B_WEN_sig   <= '0' & W_WEN;
                A_WEN_sig   <= (others => '0');

                -- Read stuff
                A_ADDR_sig  <= (13 downto 3 => R_ADDR, others => '0');
                R_DOUT      <= (7 downto 0 => A_DOUT_sig(7 downto 0), others => '0');
                -- B_OUT_sig unused
            when "01" =>
                -- 2 bytes, 16 bit [16:9]&[7:0]
                -- 1024 entries
                data_width  <= "100";

                
                B_ADDR_sig  <= (13 downto 4 => W_ADDR(9 downto 0),
                                others => '0');
                B_DIN_sig   <= (16 downto 9 => W_DIN(15 downto 8),
                                7 downto 0  => W_DIN(7 downto 0),
                                others => '0');
                A_DIN_sig   <= (others => '0');
                B_WEN_sig   <= W_WEN & W_WEN;
                A_WEN_sig   <= (others => '0');

                -- Read stuff
                A_ADDR_sig  <= (13 downto 4 => R_ADDR(9 downto 0), others => '0');
                R_DOUT      <= (15 downto 8 => A_DOUT_sig(16 downto 9),
                                7 downto 0  => A_DOUT_sig(7 downto 0),
                                others => '0');
                -- B_OUT_sig unused
            when "10" =>
                -- 3 bytes, 24 bit [16:9]&[7:0]
                -- 512 entries
                -- its the same as 4 bytes but the top 8 bits are ignored in writing and reading
                data_width  <= "111";

                -- Write stuff
                B_ADDR_sig  <= (13 downto 5 => W_ADDR(8 downto 0), others => '0');
                B_DIN_sig   <= (16 downto 9 => W_DIN(15 downto 8),
                                7 downto 0  => W_DIN(7 downto 0),
                                others => '0');
                A_DIN_sig   <= (7 downto 0 => W_DIN(23 downto 16), others => '0');
                B_WEN_sig   <= W_WEN & W_WEN;
                A_WEN_sig   <= W_WEN & W_WEN;

                -- Read stuff
                A_ADDR_sig  <= (13 downto 5 => R_ADDR(8 downto 0), others => '0');
                R_DOUT      <= (23 downto 16 => A_DOUT_sig(7 downto 0),
                                15 downto 8  => B_DOUT_sig(16 downto 9),
                                7 downto 0   => B_DOUT_sig(7 downto 0),
                                others => '0');
            when "11" =>
                -- 4 bytes, 32 bit [16:9]&[7:0]
                -- 512 entries
                data_width  <= "111";

                -- Write stuff
                B_ADDR_sig  <= (13 downto 5 => W_ADDR(8 downto 0), others => '0');
                B_DIN_sig   <= (16 downto 9 => W_DIN(15 downto 8),
                                7 downto 0  => W_DIN(7 downto 0),
                                others => '0');
                A_DIN_sig   <= (16 downto 9 => W_DIN(31 downto 24),
                                7 downto 0  => W_DIN(23 downto 16),
                                others => '0');
                B_WEN_sig   <= W_WEN & W_WEN;
                A_WEN_sig   <= W_WEN & W_WEN;

                -- Read stuff
                A_ADDR_sig  <= (13 downto 5 => R_ADDR(8 downto 0), others => '0');
                R_DOUT      <= (31 downto 24 => A_DOUT_sig(16 downto 9),
                                23 downto 16 => A_DOUT_sig(7 downto 0),
                                15 downto 8  => B_DOUT_sig(16 downto 9),
                                7 downto 0   => B_DOUT_sig(7 downto 0),
                                others => '0');
            when others =>

        end case;
    end process;

    -- architecture body
end architecture_FIFO_CDC_LSRAM;
