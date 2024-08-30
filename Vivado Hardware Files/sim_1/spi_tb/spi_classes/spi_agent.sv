`ifndef _SPI_AGENT
`define _SPI_AGENT

`include "spi_generator.sv"
`include "spi_driver.sv"
`include "spi_monitor.sv"

/***********************************************
SPI Master Agent
***********************************************/

class spi_agent;
    spi_generator   gen;
    spi_driver      drv;
    spi_monitor     monitor;
    //Init mailboxes & events
    mailbox drv_mbx;
    event drv_event, mtr_done;
    //Virtual Interface
    virtual spi_if vif;
    string TAG = "[Master] Agent";
    
    //Constructor Redefinition
    function new(virtual spi_if _vif, mailbox _mbx);
        //Create all subclasses of the agent (drivers, monitors & generators)
        drv_mbx = new();
        gen = new(drv_mbx, drv_event, mtr_done);
        drv = new(drv_mbx, drv_event);
        monitor = new(_vif, _mbx, mtr_done);
        //Set the vritual interface to the one passed through the constructor
        vif = _vif;
    endfunction : new
    
    //Main function called - this is used to assign and initialize other class vars
    task main();
        $display("[%s] Starting...",TAG);
        //Assign the virtual interface 
        drv.vif = vif;
        
        //Creat threads to run each task
        fork
            gen.main();
            drv.main();
            monitor.main();
        join_any
    endtask : main
endclass: spi_agent


/***********************************************
SPI Slave Agent
***********************************************/

class spi_slave_agent;
    spi_slave_generator         gen;
    spi_slave_driver            drv;
    //Mailboxes & events
    mailbox drv_mbx_s;
    //Virtual Interface
    virtual spi_slave_if vif;
    string TAG = "[Slave] Agent";
    
    //Constructor Redefinition
    function new(virtual spi_slave_if _vif);
        //Create all subclasses of the agent (drivers, monitors & generators) & mailboxes
        //to connect them 
        drv_mbx_s = new();
        gen = new(drv_mbx_s);
        drv = new(drv_mbx_s);
        //Set the vritual interface of the agent
        vif = _vif;
    endfunction : new    
    
    //Main function called - this is used to assign and initialize other class vars
    task main();
        $display("[%s] Starting...",TAG);
        //Assign the virtual interface 
        drv.vif = vif;
        
        //Creat threads to run each task & wait for both tasks to complete before 
        //rejoining with the main thread 
        fork
            gen.main();
            drv.main();
        join
    endtask : main    
        
endclass : spi_slave_agent

`endif //_SPI_AGENT
