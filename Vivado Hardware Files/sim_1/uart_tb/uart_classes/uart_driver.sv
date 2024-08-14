`ifndef UART_DRIVER
`define UART_DRIVER

`include "uart_trans_item.sv"
`include "uart_config.sv"

/*This will drive the transaction items into the virtual interface to send info to the DUT.*/

class uart_driver;
    //Mailbox and event to interact with generator
    mailbox drv_mailbox;
    event drv_done;
    uart_config uart_cfg;
    //virtual interface handle
    virtual uart_itf vif;
    string TAG = "Driver";
        
    //Task drives the signals to the virtual interface
    task run();
        $display("T=%0t [%s] Driver Starting...", $time, TAG);
        
        //Error Checking to ensure virtual interface is correctly set up
        if(vif == null)
            $fatal("T=%0t [%s] Failed to initialize vif", $time, TAG);
            
        //This forever loop does the following: 
        //1) Fetch a new transaction item from generator
        //2) Process this item and send it to the virtual interface
        //3) Signal the generator to create a new transaction item
        forever begin
            uart_trans_item gen_item;
            //get item from mailbox & store in gen_item
            drv_mailbox.get(gen_item);
            //process transaction
            uart_tx(gen_item);
            //Signal generator to produce a new item
            ->drv_done;
        end
    endtask : run

    //Helper function used to set the vif values for the uart to be in tx mode
    task uart_tx(uart_trans_item gen_item);
        //Set the testing parameters
        vif.dvsr = uart_cfg.dvsr;
        vif.sb_ticks = uart_cfg.stop_bits;
        vif.parity_en = uart_cfg.parity_en;
        vif.parity_pol = uart_cfg.parity_pol;
        vif.data_bit = uart_cfg.data_bits;
        vif.num_trans = gen_item.num_trans;
        
        //Control Signals
        @(posedge vif.clk);
        vif.wr_uart = 1'b1;                             //Indicate to DUT to write data to FIFO
        if(!vif.rx_empty)                               //If the rx fifo is NOT empty, set the read uart flag
            vif.rd_uart = 1'b1;        
        else                                            //else do note read from the uart
            vif.rd_uart = 1'b0;     
            
        if(vif.data_bit)                                //Make sure to adjust number of data bits depending on the configured value
            vif.wr_data = gen_item.tx_data[6:0];        //Set the value to write to the randomly generated value
        else
            vif.wr_data = gen_item.tx_data;
            
        @(posedge vif.clk);                             //After a clk edge, set the read and write flags low
        vif.wr_uart = 1'b0;
        vif.rd_uart = 1'b0;
        #((vif.dvsr * 160) * 12);                       //Add delay to make the process more indicative of how communication would operate
    endtask : uart_tx
   
    
endclass : uart_driver

`endif //UART_DRIVER