`ifndef _SPI_ENV
`define _SPI_ENV

`include "spi_agent.sv"
`include "spi_scoreboard.sv"

class spi_env;
    //Initialize scoreboard and agents
    spi_agent           spi_master;
    spi_slave_agent     spi_slave;
    spi_scoreboard      scb;
    //Declare scb mailbox
    mailbox scb_mbx, drv_scb_mbx, drv_scb_mbx_s;
    string TAG = "Environment";
    
    //Redfinition of constructor:
    //Arguments: Accepts 2 virtual interfaces, one for each agent to be initialized 
    function new(virtual spi_if _vif, virtual spi_slave_if _vif_s);
        //Init the mailboxes needed to interact with the scoreboard
        scb_mbx = new();
        drv_scb_mbx = new();
        drv_scb_mbx_s = new();
        //Init the agents (Slave & Master Interface)
        spi_master = new(_vif, scb_mbx);
        spi_slave = new(_vif_s);
        //Init the Scoreboard
        scb = new();
    endfunction : new
    
    //Main task called form the test class
    task main();
        $display("[%s] Starting...", TAG);
        //Set the scoreboard malboxes
        scb.scb_mbx = scb_mbx;
        scb.drv_scb_mbx_s = drv_scb_mbx_s;
        scb.drv_scb_mbx = drv_scb_mbx;
        spi_master.drv.drv_scb_mbx = drv_scb_mbx;
        spi_slave.drv.drv_scb_mbx_s = drv_scb_mbx_s;
        
        //Initialize the spi slave register file first
        spi_slave.main();
        
        //fork and run the main functions from SPI Master - the scoreboard and agent
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