`ifndef _SPI_DRIVER
`define _SPI_DRIVER

`include "spi_trans_item.sv"

class spi_driver;
    //Virutal interface definition
    virtual spi_if vif;
    //Maiblox and event to interact with the generator
    mailbox drv_mbx, drv_scb_mbx;
    event drv_done;
    //String tag
    string TAG = "Driver";
    
    //Redefinition of constructor
    function new(mailbox _mbx, event _event);
        drv_mbx = _mbx;
        drv_done = _event;
    endfunction : new
    
    //Task that drives data to the virtual interface/hardware module
    task main();
    
    $display("[%s] Starting...", TAG);
    
    //Error Checking 
    if(vif == null)
        $fatal("[%s] Virtual Interface not Initialized",TAG);
    
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
            //Send dummy/randomized data on the MISO line
            generate_miso(rec_item.miso_din);
            //Set event for the generator indicating more data can be driven
            //Send the item that was just driven to the scoreboard - this is used for the final scorebaord
            $display("[%s] MOSI: %0h, MISO: %0h", TAG, rec_item.mosi_dout, rec_item.miso_din);              
            drv_scb_mbx.put(rec_item);       
            $display("[%s] Item sent to scoreboard", TAG);   
            ->drv_done;
        end
        
    end //forever loop
    
    endtask: main
    
    //Task that write data into the SPI registers - this is used to initialize communication
    //TODO: Make the Modes and dvsr more modular and allow for multiple test instances with diff values for these
    task write_data(spi_trans_item rec_item);
        /**** SPI Configuration *****/
        vif.cs = 1'b1;
        vif.write = 1'b1;
        vif.reg_addr = 5'b11;               //Write into the ctrl register (0x3)
        vif.wr_data = 32'h00200;            //This sets mode 0 & freq to 50KHz
        vif.spi_ss_n = 0;                   //We are simulating communication between 2 "masters" therefore we can ignore the chip select signal
        @(posedge vif.clk);
        /**** Writing Data to the SPI Module ***/
        vif.reg_addr = 5'b00010;            //Write into reg two to init SPI module
        vif.wr_data = {24'h0, rec_item.mosi_dout};//Value to transmit from the SPI module     
        /*** Disable Write ****/
        @(posedge vif.clk);
        vif.cs = 1'b0;
        vif.write = 1'b0;
    endtask: write_data
    
    //Task used to generate a randomized MISO value on the vif.miso line
    //This will be stored in the SPI shift register
    task generate_miso(input bit [7:0] miso_value);
        //Ensure that 8 bits are sent on the MISO line starting at the MSB first
        for(int i = 7; i >= 0; i--) begin
            //Send the MSB
            vif.spi_miso = miso_value[i];
            //Wait for the negative edge of the spi clock before driving the next bit
            @(negedge vif.spi_clk);
        end
    endtask : generate_miso
       
endclass : spi_driver

`endif  //_SPI_DRIVER