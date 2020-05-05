quietly set ACTELLIBNAME SmartFusion2
quietly set PROJECT_DIR "E:/Github_Repos/FIFO_CDC/FIFO_CDC"

if {[file exists presynth/_info]} {
   echo "INFO: Simulation library presynth already exists"
} else {
   file delete -force presynth 
   vlib presynth
}
vmap presynth presynth
vmap SmartFusion2 "C:/Microsemi/Libero_SoC_v12.4/Designer/lib/modelsimpro/precompiled/vlog/SmartFusion2"
if {[file exists COREABC_LIB/_info]} {
   echo "INFO: Simulation library COREABC_LIB already exists"
} else {
   file delete -force COREABC_LIB 
   vlib COREABC_LIB
}
vmap COREABC_LIB "COREABC_LIB"

vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/FCCC_C0/FCCC_C0_0/FCCC_C0_FCCC_C0_0_FCCC.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/FCCC_C0/FCCC_C0.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FIFO_CDC_LSRAM.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/Gray_Code_package.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/Gray_Code_Counter.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/FIFO_CDC.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/LED_inverter_dimmer.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/OSC_C0/OSC_C0_0/OSC_C0_OSC_C0_0_OSC.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/OSC_C0/OSC_C0.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/fifo_read_test.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/hdl/fifo_write_test.vhd"
vcom -2008 -explicit  -work presynth "${PROJECT_DIR}/component/work/FIFO_CDC_test/FIFO_CDC_test.vhd"

vsim -L SmartFusion2 -L presynth -L COREABC_LIB  -t 10ps presynth.FIFO_CDC_test
# The following lines are commented because no testbench is associated with the project
# add wave /testbench/*
# run 1ms
