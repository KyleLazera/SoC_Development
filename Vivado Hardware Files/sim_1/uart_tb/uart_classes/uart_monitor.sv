`ifndef UART_MONITOR
`define UART_MONITOR

/* Monitors the output of teh virtual interface/DUT. The output is then repackaed into the uart transaction
* item, and is sent to the scoreboard for analysis.*/
class uart_monitor;
    //virtual interface handle
    virtual uart_itf vif;
    //Mailbox to send info to scoreboard
    mailbox scb_mailbox;
    string TAG = "Monitor";
    
    //Task processes the virtual interface info from the DUT and uses this info to create
    // a new transaction item for teh scoreboard to use
    task run();
        $display("T=%0t [%s] Monitor Starting...", $time, TAG);
        
        //Monitor the virtual interface for the duration of the task
        forever begin
            uart_trans_item observed_item = new;
            //sample on every clock edge
            @(posedge vif.clk);
            if(!vif.rx_empty) begin
                //Process the data from the DUT
                observed_item.rd_data = vif.rd_data;
                observed_item.parity_err = vif.parity_err;
                observed_item.overflow_err = vif.overflow_err;
                observed_item.frame_err = vif.frame_err;
                observed_item.tx_data = vif.wr_data;
                observed_item.vif_tag = vif.name;
                observed_item.num_trans = vif.num_trans;
                //debugging
                observed_item.print(TAG);
                //Read from the FIFO to remove the fifo
                @(posedge vif.clk);
                vif.rd_uart = 1'b1;
                @(posedge vif.clk);
                vif.rd_uart = 1'b0;
                //Pass transaction item to the scoreboard
                scb_mailbox.put(observed_item);
            end
        end
    endtask
    
endclass : uart_monitor


`endif //UART_MONITOR