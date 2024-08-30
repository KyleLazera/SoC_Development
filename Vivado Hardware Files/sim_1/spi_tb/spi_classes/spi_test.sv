`ifndef _SPI_TEST
`define _SPI_TEST

`include "spi_env.sv"

class spi_test;
    spi_env         env;
    string TAG = "Test";
    
    //Redefine the constructor:
    function new(virtual spi_if _vif, virtual spi_slave_if _vif_s);
        env = new(_vif, _vif_s);
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
