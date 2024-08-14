`ifndef UART_SCB
`define UART_SCB

/*Used to check the correctness of the outputs from the DUT*/
class uart_scoreboard;
    //mailbox to communicate with monitor
    mailbox scb_mailbox;
    //Queue to store the data 
    bit [7:0] tx_data_rec[$];
    bit [7:0] rx_data_rec[$];
    //Tag used for debugging
    string TAG = "Scoreboard";
    //Variables used to keep track of number of successes/fails
    int success = 0, fail = 0, total_trans = 0;
    
    task run();
        $display("T=%0t [%s] Starting Scoreboard...", $time, TAG);
        //monitor scoreboard for duration of simulation
        forever begin
            uart_trans_item observed_item;         
            //Fetch the data from the mailbox
            scb_mailbox.get(observed_item);
            total_trans = observed_item.num_trans;
            verify_data_transfer(tx_data_rec, rx_data_rec, observed_item);
            display_error_flags(observed_item);
        end
    endtask : run
    
    function display_error_flags(uart_trans_item observed_item);
        if(observed_item.parity_err)
            $fatal("Parity Error");
        if(observed_item.overflow_err)
            $fatal("Overflow Error");
        if(observed_item.frame_err)
            $fatal("Frame Error");
    endfunction
       
    //verify the data transmitted and recicved by both UARTs
    function verify_data_transfer(bit[7:0] tx_data[$], bit[7:0] rx_data[$], uart_trans_item observed_item);
        //Push the recieved and transmitted values into queues that will hold only tx or rx data
        tx_data_rec.push_front(observed_item.tx_data);
        rx_data_rec.push_front(observed_item.rd_data);
        //Compare the values of the queues - if all data was transmitted correctly,
        //the queues should have the exact same values just in different locations
        //To avoid having to iterate through a long list after transmission and reception have complete, we will
        //compare each input and if it matches, it will be deleted to keep the iteration as short as possible
        for(int i = 0; i < tx_data_rec.size(); i++) begin
            for(int j = 0; j < rx_data_rec.size(); j++) begin
                if(tx_data_rec[i] == rx_data_rec[j]) begin
                    $display("T=%0t [%s] DATA MATCH: TX: %0h RX: %0h", $time, TAG, tx_data_rec[i], rx_data_rec[j]);
                    tx_data_rec.delete(i);
                    rx_data_rec.delete(j);
                    success += 1;
                end
                
            end
        end
    endfunction
    
    function void display_score();
        $display("****************************************");
        $display("Final Score Board: ");
        if(((total_trans*2)-1) == success)
            $display("All Data Succesfully Transmitted!");
        else begin
            $display("Successeful Transmissions: %0d", success);
            $display("Failed Transmission: %0d", total_trans - success);
        end
    endfunction
    
endclass : uart_scoreboard

`endif //UART_SCB