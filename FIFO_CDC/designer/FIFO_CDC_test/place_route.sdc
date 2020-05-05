# Microsemi Corp.
# Date: 2020-May-04 22:46:15
# This file was generated based on the following SDC source files:
#   E:/Github_Repos/FIFO_CDC/FIFO_CDC/constraint/FIFO_CDC_test_derived_constraints.sdc
#

create_clock -name {OSC_C0_0/OSC_C0_0/I_RCOSC_25_50MHZ/CLKOUT} -period 20 [ get_pins { OSC_C0_0/OSC_C0_0/I_RCOSC_25_50MHZ/CLKOUT } ]
create_generated_clock -name {FCCC_C0_0/FCCC_C0_0/GL0} -multiply_by 20 -divide_by 8 -source [ get_pins { FCCC_C0_0/FCCC_C0_0/CCC_INST/INST_CCC_IP/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { FCCC_C0_0/FCCC_C0_0/CCC_INST/INST_CCC_IP/GL0 } ]
create_generated_clock -name {FCCC_C0_0/FCCC_C0_0/GL1} -multiply_by 20 -divide_by 10 -source [ get_pins { FCCC_C0_0/FCCC_C0_0/CCC_INST/INST_CCC_IP/RCOSC_25_50MHZ } ] -phase 0 [ get_pins { FCCC_C0_0/FCCC_C0_0/CCC_INST/INST_CCC_IP/GL1 } ]
