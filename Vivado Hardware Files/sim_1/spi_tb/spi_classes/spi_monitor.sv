`ifndef _SPI_MON
`define _SPI_MON

`include "spi_trans_item.sv"

class spi_monitor;
    //Virtual interface handle
    virtual spi_if vif;
    //Maiblox to interact with scoreboard
    mailbox scb_mbx;
    event mtr_done;
    string TAG = "Monitor";
    
    //Redefinition of the constructor
    function new(virtual spi_if _vif, mailbox _mbx, event _mtr_event);
        vif = _vif;
        scb_mbx = _mbx;
        mtr_done = _mtr_event;
    endfunction : new
    
    //Main task of the monitor 
    task main();
        //Init a transaction item
        spi_trans_item scb_item = new;
        //Debugging tag
        $display("[%s] Starting...", TAG);
        
        forever begin
            @(posedge vif.clk);
            //If spi_ready signal is low - this indicates the spi is undergoing transmission. During this time,
            //probe the mosi line
            if(!vif.rd_data[8]) begin
                compute_mosi(scb_item.mosi_dout);
                //Wait for the spi_ready signal to go high indicating transmission complete
                @(vif.rd_data[8]);
                //Read data recieved from the MISO line
                read_data(scb_item.miso_din);
                //Send new item to the scoreboard
                scb_mbx.put(scb_item);
                scb_item.print(TAG); 
                ->mtr_done;               
            end //if statement
        end //forever loop
        
    endtask : main
   
   //This task outputs the recieved data from the MISO which is stored
    //in register 0x00 of the wrapper module
    task read_data(output bit [7:0] d_out);
        vif.cs = 1'b1;
        vif.read = 1'b1;
        vif.reg_addr = 5'b00000;
        d_out = vif.rd_data[7:0];
        //Deactive the read signals
        @(posedge vif.clk);
        vif.cs = 1'b0;
        vif.read = 1'b0;
    endtask : read_data
    
    //This task is used to compute the data on the MOSI line and compare to the 
    //data that was originally transmitted by the driver
    task compute_mosi(output bit [7:0] mosi_value);
        //Make sure to read all 8 signals on the MOSI line
        for(int i = 0; i < 8; i++) begin
            //Wait for a rising edge on the spi clock
            @(posedge vif.spi_clk);
            //Sample the data on the MOSI line & shift into an 8 bit "register"
            mosi_value = {mosi_value[6:0], vif.spi_mosi};
        end
    endtask : compute_mosi
    
endclass : spi_monitor

`endif  //_SPI_MON