`ifndef _SPI_TEST
`define _SPI_TEST

`include "spi_env.sv"

class spi_test;
    spi_env         env;
    string TAG = "Test";
    
    //Redefine the constructor:
    function new(virtual spi_if _vif);
        env = new(_vif);
    endfunction : new
    
    task main();
        $display("[%s] Starting...", TAG);
        
        //Call environemnt run task
        env.main();
        //Slight delay
        #100;
        $display("[%s] Test Complete", TAG);
        //Display final Score
        env.display_final();
    endtask : main
    
endclass : spi_test

`endif //_SPI_TEST
