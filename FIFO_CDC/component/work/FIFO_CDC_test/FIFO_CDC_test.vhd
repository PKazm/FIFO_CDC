----------------------------------------------------------------------
-- Created by SmartDesign Mon May  4 18:42:36 2020
-- Version: v12.4 12.900.0.16
----------------------------------------------------------------------

----------------------------------------------------------------------
-- Libraries
----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

library smartfusion2;
use smartfusion2.all;
----------------------------------------------------------------------
-- FIFO_CDC_test entity declaration
----------------------------------------------------------------------
entity FIFO_CDC_test is
    -- Port list
    port(
        -- Inputs
        Board_Buttons : in  std_logic_vector(1 downto 0);
        -- Outputs
        Board_LEDs    : out std_logic_vector(7 downto 0)
        );
end FIFO_CDC_test;
----------------------------------------------------------------------
-- FIFO_CDC_test architecture body
----------------------------------------------------------------------
architecture RTL of FIFO_CDC_test is
----------------------------------------------------------------------
-- Component declarations
----------------------------------------------------------------------
-- FCCC_C0
component FCCC_C0
    -- Port list
    port(
        -- Inputs
        RCOSC_25_50MHZ : in  std_logic;
        -- Outputs
        GL0            : out std_logic;
        GL1            : out std_logic;
        LOCK           : out std_logic
        );
end component;
-- FIFO_CDC
component FIFO_CDC
    -- Port list
    port(
        -- Inputs
        BYTES      : in  std_logic_vector(1 downto 0);
        FIFO_ON    : in  std_logic;
        RSTn       : in  std_logic;
        R_CLK      : in  std_logic;
        R_EN       : in  std_logic;
        W_CLK      : in  std_logic;
        W_DATA     : in  std_logic_vector(31 downto 0);
        W_EN       : in  std_logic;
        -- Outputs
        FIFO_IS_ON : out std_logic;
        R_DATA     : out std_logic_vector(31 downto 0);
        R_READY    : out std_logic;
        W_FULL     : out std_logic
        );
end component;
-- fifo_read_test
component fifo_read_test
    -- Port list
    port(
        -- Inputs
        CLK        : in  std_logic;
        FIFO_IS_ON : in  std_logic;
        FIFO_READY : in  std_logic;
        RSTn       : in  std_logic;
        R_DAT      : in  std_logic_vector(31 downto 0);
        buttons    : in  std_logic_vector(1 downto 0);
        -- Outputs
        FIFO_BYTES : out std_logic_vector(1 downto 0);
        FIFO_ON    : out std_logic;
        LEDs       : out std_logic_vector(7 downto 0);
        R_EN       : out std_logic
        );
end component;
-- fifo_write_test
component fifo_write_test
    -- Port list
    port(
        -- Inputs
        CLK       : in  std_logic;
        FIFO_FULL : in  std_logic;
        RSTn      : in  std_logic;
        -- Outputs
        W_DAT     : out std_logic_vector(31 downto 0);
        W_EN      : out std_logic
        );
end component;
-- LED_inverter_dimmer
component LED_inverter_dimmer
    -- Port list
    port(
        -- Inputs
        CLK         : in  std_logic;
        LED_toggles : in  std_logic_vector(7 downto 0);
        -- Outputs
        Board_LEDs  : out std_logic_vector(7 downto 0)
        );
end component;
-- OSC_C0
component OSC_C0
    -- Port list
    port(
        -- Outputs
        RCOSC_25_50MHZ_CCC : out std_logic
        );
end component;
----------------------------------------------------------------------
-- Signal declarations
----------------------------------------------------------------------
signal Board_LEDs_net_0                                   : std_logic_vector(7 downto 0);
signal FCCC_C0_0_GL0                                      : std_logic;
signal FCCC_C0_0_GL1                                      : std_logic;
signal FCCC_C0_0_LOCK                                     : std_logic;
signal FIFO_CDC_0_FIFO_IS_ON                              : std_logic;
signal FIFO_CDC_0_R_DATA                                  : std_logic_vector(31 downto 0);
signal FIFO_CDC_0_R_READY                                 : std_logic;
signal FIFO_CDC_0_W_FULL                                  : std_logic;
signal fifo_read_test_0_FIFO_BYTES                        : std_logic_vector(1 downto 0);
signal fifo_read_test_0_FIFO_ON                           : std_logic;
signal fifo_read_test_0_LEDs                              : std_logic_vector(7 downto 0);
signal fifo_read_test_0_R_EN                              : std_logic;
signal fifo_write_test_0_W_DAT                            : std_logic_vector(31 downto 0);
signal fifo_write_test_0_W_EN                             : std_logic;
signal OSC_C0_0_RCOSC_25_50MHZ_CCC_OUT_RCOSC_25_50MHZ_CCC : std_logic;
signal Board_LEDs_net_1                                   : std_logic_vector(7 downto 0);
----------------------------------------------------------------------
-- TiedOff Signals
----------------------------------------------------------------------
signal GND_net                                            : std_logic;

begin
----------------------------------------------------------------------
-- Constant assignments
----------------------------------------------------------------------
 GND_net <= '0';
----------------------------------------------------------------------
-- Top level output port assignments
----------------------------------------------------------------------
 Board_LEDs_net_1       <= Board_LEDs_net_0;
 Board_LEDs(7 downto 0) <= Board_LEDs_net_1;
----------------------------------------------------------------------
-- Component instances
----------------------------------------------------------------------
-- FCCC_C0_0
FCCC_C0_0 : FCCC_C0
    port map( 
        -- Inputs
        RCOSC_25_50MHZ => OSC_C0_0_RCOSC_25_50MHZ_CCC_OUT_RCOSC_25_50MHZ_CCC,
        -- Outputs
        GL0            => FCCC_C0_0_GL0,
        LOCK           => FCCC_C0_0_LOCK,
        GL1            => FCCC_C0_0_GL1 
        );
-- FIFO_CDC_0
FIFO_CDC_0 : FIFO_CDC
    port map( 
        -- Inputs
        W_CLK      => FCCC_C0_0_GL0,
        R_CLK      => FCCC_C0_0_GL1,
        RSTn       => FCCC_C0_0_LOCK,
        W_EN       => fifo_write_test_0_W_EN,
        W_DATA     => fifo_write_test_0_W_DAT,
        R_EN       => fifo_read_test_0_R_EN,
        FIFO_ON    => fifo_read_test_0_FIFO_ON,
        BYTES      => fifo_read_test_0_FIFO_BYTES,
        -- Outputs
        W_FULL     => FIFO_CDC_0_W_FULL,
        R_DATA     => FIFO_CDC_0_R_DATA,
        R_READY    => FIFO_CDC_0_R_READY,
        FIFO_IS_ON => FIFO_CDC_0_FIFO_IS_ON 
        );
-- fifo_read_test_0
fifo_read_test_0 : fifo_read_test
    port map( 
        -- Inputs
        CLK        => FCCC_C0_0_GL1,
        RSTn       => FCCC_C0_0_LOCK,
        buttons    => Board_Buttons,
        FIFO_READY => FIFO_CDC_0_R_READY,
        R_DAT      => FIFO_CDC_0_R_DATA,
        FIFO_IS_ON => FIFO_CDC_0_FIFO_IS_ON,
        -- Outputs
        R_EN       => fifo_read_test_0_R_EN,
        FIFO_ON    => fifo_read_test_0_FIFO_ON,
        FIFO_BYTES => fifo_read_test_0_FIFO_BYTES,
        LEDs       => fifo_read_test_0_LEDs 
        );
-- fifo_write_test_0
fifo_write_test_0 : fifo_write_test
    port map( 
        -- Inputs
        CLK       => FCCC_C0_0_GL0,
        RSTn      => FCCC_C0_0_LOCK,
        FIFO_FULL => FIFO_CDC_0_W_FULL,
        -- Outputs
        W_DAT     => fifo_write_test_0_W_DAT,
        W_EN      => fifo_write_test_0_W_EN 
        );
-- LED_inverter_dimmer_0
LED_inverter_dimmer_0 : LED_inverter_dimmer
    port map( 
        -- Inputs
        CLK         => GND_net,
        LED_toggles => fifo_read_test_0_LEDs,
        -- Outputs
        Board_LEDs  => Board_LEDs_net_0 
        );
-- OSC_C0_0
OSC_C0_0 : OSC_C0
    port map( 
        -- Outputs
        RCOSC_25_50MHZ_CCC => OSC_C0_0_RCOSC_25_50MHZ_CCC_OUT_RCOSC_25_50MHZ_CCC 
        );

end RTL;
