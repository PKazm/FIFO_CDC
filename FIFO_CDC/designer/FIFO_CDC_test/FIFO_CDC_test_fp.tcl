new_project \
         -name {FIFO_CDC_test} \
         -location {E:\Github_Repos\FIFO_CDC\FIFO_CDC\designer\FIFO_CDC_test\FIFO_CDC_test_fp} \
         -mode {chain} \
         -connect_programmers {FALSE}
add_actel_device \
         -device {M2S010} \
         -name {M2S010}
enable_device \
         -name {M2S010} \
         -enable {TRUE}
save_project
close_project
