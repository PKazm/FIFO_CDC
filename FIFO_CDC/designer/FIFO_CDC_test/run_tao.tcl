set_family {SmartFusion2}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\component\work\FCCC_C0\FCCC_C0_0\FCCC_C0_FCCC_C0_0_FCCC.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\component\work\FCCC_C0\FCCC_C0.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\FIFO_CDC_LSRAM.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\Gray_Code_package.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\Gray_Code_Counter.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\FIFO_CDC.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\LED_inverter_dimmer.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\component\work\OSC_C0\OSC_C0_0\OSC_C0_OSC_C0_0_OSC.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\component\work\OSC_C0\OSC_C0.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\fifo_read_test.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\fifo_write_test.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\component\work\FIFO_CDC_test\FIFO_CDC_test.vhd}
set_top_level {FIFO_CDC_test}
map_netlist
read_sdc {E:\Github_Repos\FIFO_CDC\FIFO_CDC\constraint\FIFO_CDC_test_derived_constraints.sdc}
check_constraints {E:\Github_Repos\FIFO_CDC\FIFO_CDC\constraint\synthesis_sdc_errors.log}
write_fdc {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\synthesis.fdc}
