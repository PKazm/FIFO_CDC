read_sdc -scenario "place_and_route" -netlist "optimized" -pin_separator "/" -ignore_errors {E:/Github_Repos/FIFO_CDC/FIFO_CDC/designer/FIFO_CDC_test/place_route.sdc}
set_options -tdpr_scenario "place_and_route" 
save
set_options -analysis_scenario "place_and_route"
report -type combinational_loops -format xml {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\FIFO_CDC_test_layout_combinational_loops.xml}
report -type slack {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\pinslacks.txt}
set coverage [report \
    -type     constraints_coverage \
    -format   xml \
    -slacks   no \
    {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\FIFO_CDC_test_place_and_route_constraint_coverage.xml}]
set reportfile {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\coverage_placeandroute}
set fp [open $reportfile w]
puts $fp $coverage
close $fp