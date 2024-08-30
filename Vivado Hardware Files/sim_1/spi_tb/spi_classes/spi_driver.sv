`ifndef _SPI_DRIVER
`define _SPI_DRIVER

`include "spi_trans_item.sv"

/****************************************
 SPI Master Driver
 ****************************************/

class spi_driver;
    //Virutal interface definition
    virtual spi_if vif;
    //Mailbox & event to interact with the generator
    mailbox drv_mbx, drv_scb_mbx;
    event drv_done;
    //String tag
    string TAG = "[Master] Driver";
    
    //Redefinition of constructor
    function new(mailbox _mbx, event _event);
        drv_mbx = _mbx;
        drv_done = _event;
    endfunction : new
    
    //Task that drives data to the virtual interface/hardware module
    task main();
    
    $display("[%s] Starting...", TAG);
    
    forever begin
        //Transaction item from the generator
        spi_trans_item rec_item;
        //Local variable declarations
        @(posedge vif.clk);
        //check if the spi ready signal is high - this indicates we can begin a transmission
        if(vif.rd_data[8]) begin
            //Fetch the transmitted item from the generator
            drv_mbx.get(rec_item);     
            //Write data to the SPI Module - this also starts the spi transfer
            write_data(rec_item);
            //Set event for the generator indicating more data can be driven
            //Send the item that was just driven to the scoreboard - this is used for the final scorebaord             
            drv_scb_mbx.put(rec_item);         
            ->drv_done;
        end    
    end //forever loop
    endtask: main
    
    //Task that write data into the SPI registers - this is used to initialize communication
    task write_data(spi_trans_item rec_item);
        /**** SPI Configuration *****/
        vif.cs = 1'b1;
        vif.write = 1'b1;
        vif.reg_addr = 5'b11;               //Write into the ctrl register (0x3)
        vif.wr_data = 32'h00200;            //This sets mode 0 & freq to 50KHz
        @(posedge vif.clk);
        vif.reg_addr = 5'b1;
        vif.wr_data = 32'hFFFFFFFE;          //Set the Slave Select bit
        @(posedge vif.clk);
        /**** Writing Data to the SPI Module ***/
        vif.reg_addr = 5'b00010;            //Write into reg two to init SPI module
        vif.wr_data = {24'h0, rec_item.mosi_dout};//Value to transmit from the SPI module     
        /*** Disable Write & CS****/ 
        @(posedge vif.clk);
        vif.cs = 1'b0;
        vif.write = 1'b0;                
    endtask: write_data      
endclass : spi_driver

/****************************************
 SPI Slave Driver
 ****************************************/

class spi_slave_driver;
    //Virtual interface
    virtual spi_slave_if vif;
    //Mailbox to interface with scoreboard & generator
    mailbox drv_mbx_s, drv_scb_mbx_s;
    string TAG = "[Slave] Driver";
    
    //Redefinition of constructor
    function new(mailbox _mbx);
        drv_mbx_s = _mbx;
    endfunction : new
    
    //Main Task that drives signals to the spi slave interface
    task main();
        //Instance of transaction item
        spi_slave_trans_item rec_item;
        @(posedge vif.clk);
        //Fetch transaction Item from generator
        drv_mbx_s.get(rec_item);
        //Populate register file (simulate random vars being written into it)
        populate_reg_file(rec_item);
        $display("[%s] Register file has been succesfully populated.", TAG);
        rec_item.print(TAG);
        //Send transaction Item to scoreboard
        drv_scb_mbx_s.put(rec_item);
        $display("[%s] Complete", TAG);
    endtask : main
    
    //This task is used to write into the spi slave interface & populate the register file 
    task populate_reg_file(spi_slave_trans_item item);
        for(int i = 1; i < 16; i++) begin
            vif.cs = 1'b1;
            vif.write = 1'b1;
            vif.reg_addr = i;
            vif.wr_data = {24'h0, item.slave_reg_file[i]};
            @(posedge vif.clk);
            vif.cs = 1'b0;
            vif.write = 1'b0;
        end
    endtask : populate_reg_file
    
endclass : spi_slave_driver

`endif  //_SPI_DRIVER