# Written by Synplify Pro version mapact, Build 2737R. Synopsys Run ID: sid1588646749 
# Top Level Design Parameters 

# Clocks 
create_clock -period 20.000 -waveform {0.000 10.000} -name {OSC_C0_0/OSC_C0_0/I_RCOSC_25_50MHZ/CLKOUT} [get_pins {OSC_C0_0/OSC_C0_0/I_RCOSC_25_50MHZ/CLKOUT}] 

# Virtual Clocks 

# Generated Clocks 
create_generated_clock -name {FCCC_C0_0/FCCC_C0_0/GL0} -multiply_by {20} -divide_by {8} -source [get_pins {FCCC_C0_0/FCCC_C0_0/CCC_INST/RCOSC_25_50MHZ}]  [get_pins {FCCC_C0_0/FCCC_C0_0/CCC_INST/GL0}] 
create_generated_clock -name {FCCC_C0_0/FCCC_C0_0/GL1} -multiply_by {20} -divide_by {10} -source [get_pins {FCCC_C0_0/FCCC_C0_0/CCC_INST/RCOSC_25_50MHZ}]  [get_pins {FCCC_C0_0/FCCC_C0_0/CCC_INST/GL1}] 

# Paths Between Clocks 

# Multicycle Constraints 

# Point-to-point Delay Constraints 

# False Path Constraints 

# Output Load Constraints 

# Driving Cell Constraints 

# Input Delay Constraints 

# Output Delay Constraints 

# Wire Loads 

# Other Constraints 

# syn_hier Attributes 

# set_case Attributes 

# Clock Delay Constraints 

# syn_mode Attributes 

# Cells 

# Port DRC Rules 

# Input Transition Constraints 

# Unused constraints (intentionally commented out) 


# Non-forward-annotatable constraints (intentionally commented out) 

# Block Path constraints 

