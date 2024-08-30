`ifndef _SPI_MON
`define _SPI_MON

`include "spi_trans_item.sv"

class spi_monitor;
    //Virtual interface handle
    virtual spi_if vif;
    //Mailbox to interact with scoreboard
    mailbox scb_mbx;
    event mtr_done;
    string TAG = "[Master] Monitor";
    
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
            //Wait for the spi_done tick from the SPI Master
            @(vif.rd_data[9]);
            //Read data recieved from the MISO line
            read_data(scb_item.miso_din);
            //Send new item to the scoreboard
            scb_mbx.put(scb_item);
            //Send event to generator indicating data has been read
            ->mtr_done;               
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
endclass : spi_monitor



`endif  //_SPI_MON