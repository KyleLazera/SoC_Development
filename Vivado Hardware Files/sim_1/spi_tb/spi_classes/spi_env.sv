`ifndef _SPI_ENV
`define _SPI_ENV

`include "spi_agent.sv"
`include "spi_scoreboard.sv"

class spi_env;
    //Initialize scoreboard and agents
    spi_agent           spi_master;
    spi_scoreboard      scb;
    //Declare scb mailbox
    mailbox scb_mbx, drv_scb_mbx;
    string TAG = "Environment";
    
    //Redfinition of constructor:
    //Arguments: Accepts 2 virtual interfaces, one for each agent to be initialized 
    function new(virtual spi_if _vif);
        scb_mbx = new();
        drv_scb_mbx = new();
        spi_master = new(_vif, scb_mbx);
        scb = new();
    endfunction : new
    
    //Main task called form the test class
    task main();
        $display("[%s] Starting...", TAG);
        //Set the scoreboard & monitor mailbox
        scb.scb_mbx = scb_mbx;
        scb.drv_scb_mbx = drv_scb_mbx;
        spi_master.drv.drv_scb_mbx = drv_scb_mbx;
        //fork and run the main functions from the scoreboard and agents
        fork
            spi_master.main();
            scb.main();
        join_any     
    endtask : main
    
    //End of Test Hook to display final results
    function void display_final();
        scb.display_score();
    endfunction : display_final
    
    
endclass : spi_env

`endif //_SPI_ENV