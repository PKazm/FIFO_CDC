set_family {SmartFusion2}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\FIFO_CDC_LSRAM.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\Gray_Code_package.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\Gray_Code_Counter.vhd}
read_vhdl -mode vhdl_2008 {E:\Github_Repos\FIFO_CDC\FIFO_CDC\hdl\FIFO_CDC.vhd}
set_top_level {FIFO_CDC}
map_netlist
check_constraints {E:\Github_Repos\FIFO_CDC\FIFO_CDC\constraint\synthesis_sdc_errors.log}
write_fdc {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC\synthesis.fdc}
