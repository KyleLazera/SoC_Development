`ifndef _SPI_GENERATOR
`define _SPI_GENERATOR

`include "spi_trans_item.sv"

class spi_generator;
    //Mailbox to send data from the generator to the driver
    mailbox drv_mbx;
    //Event indicating driver has completed processing of data
    event drv_done, mtr_done;
    //Tag for the class
    string TAG = "Generator";
    
    //Redefinition of constructor
    function new(mailbox _mbx, event _drv_evt, event _mtr_event);
        drv_mbx = _mbx;
        drv_done = _drv_evt;
        mtr_done = _mtr_event;
    endfunction : new
    
    //task used to generate the values to send to driver
    task main();
        spi_trans_item gen_item = new;
        $display("[%s] Starting...", TAG);
        
        //Send all possible combinations of data (256 total values because we are transmittting 8 bits)
        for(int i = 0; i < 256; i++) begin
            //Randomize the din value
            gen_item.randomize();
            //Send the generated item to the driver via mailbox
            drv_mbx.put(gen_item);
            //For tcl console debugging/flow of control
            $display("[%s] Item %0d Generated & sent to Driver", TAG, i);
            //Synchronize with monitor & driver:
            //Wait for driver to signal completion before sending a new value
            @(drv_done);
            //Wait for monitr to signal it has completed data capture
            @(mtr_done);
        end
    endtask : main
    
endclass : spi_generator

`endif  //_SPI_GENERATOR
