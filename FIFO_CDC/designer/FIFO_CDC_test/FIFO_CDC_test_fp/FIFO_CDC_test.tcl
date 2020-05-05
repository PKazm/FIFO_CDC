open_project -project {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\FIFO_CDC_test_fp\FIFO_CDC_test.pro}
enable_device -name {M2S010} -enable 1
set_programming_file -name {M2S010} -file {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\FIFO_CDC_test.ppd}
set_programming_action -action {PROGRAM} -name {M2S010} 
run_selected_actions
save_project
close_project
