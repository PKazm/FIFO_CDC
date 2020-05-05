set_family {SmartFusion2}
read_adl {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\FIFO_CDC_test.adl}
read_afl {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\FIFO_CDC_test.afl}
map_netlist
read_sdc {E:\Github_Repos\FIFO_CDC\FIFO_CDC\constraint\FIFO_CDC_test_derived_constraints.sdc}
check_constraints {E:\Github_Repos\FIFO_CDC\FIFO_CDC\constraint\placer_sdc_errors.log}
write_sdc -strict -afl {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\place_route.sdc}
