`ifndef UART_ENV
`define UART_ENV

`include "uart_driver.sv"
`include "uart_generator.sv"
`include "uart_monitor.sv"
`include "uart_scoreboard.sv"
`include "uart_config.sv"

/* The UART agent contains the 3 major components for each uart to interact with the virtual interface: 
* The generator - allowing each agent to generate their own data
* The Driver - Allowing each agent to drive the generated ddata to the connected DUT
* The Monitor - Allows each agent to monitor the results*/
class uart_agent;
    // Components of the agent
    uart_generator          gen;
    uart_driver             drv;
    uart_monitor            mon;
    uart_config             uart_cfg;
    // Mailbox & events for communication
    mailbox drv_mailbox;
    event drv_done;
    // Virtual interface handle
    virtual uart_itf        vif;
    
    string TAG = "Agent";

    // Constructor
    function new(virtual uart_itf _vif, uart_config cfg);
        //Init the agent with a handle to the virtual interface
        vif = _vif;
        uart_cfg = cfg;
        // Instantiate the components
        gen = new();
        drv = new();
        mon = new();
        //instantiate the mailbox
        drv_mailbox = new();
        
        // Set up the mailboxes & events
        gen.drv_mailbox = drv_mailbox;
        gen.drv_done = drv_done;
        drv.drv_mailbox = drv_mailbox;
        drv.drv_done = drv_done;
        //Set the configuration
        drv.uart_cfg = uart_cfg;
        
    endfunction

    // Task to start the agent components
    task run();
        $display("T=%0t [%s] Agent Starting...", $time, TAG);
        
        // Connect the virtual interface of the drivers
        drv.vif = vif;
        mon.vif = vif;
        
        // Start the tasks concurrently
        fork
            gen.run();
            drv.run();
            mon.run();
        join_any
    endtask : run
   
endclass : uart_agent


class uart_env;
    // Components of the environment
    uart_agent              agent_1;
    uart_agent              agent_2;
    uart_scoreboard         scb;
    uart_config             uart_cfg;
    //Mailbox for scoreboard and monitors
    mailbox                 scb_mailbox;
   

    // Virtual interfaces for both UARTs
    virtual uart_itf uart_1_vif;
    virtual uart_itf uart_2_vif;

    string TAG = "Environment";
    
    function new(uart_config cfg);
        //Set the configuration
        uart_cfg = cfg;
        //Initialize components
        scb = new;
        //Init mailbox
        scb_mailbox = new();
        //Set the mailbox for the scoreboard
        scb.scb_mailbox = scb_mailbox;
    endfunction

    // Task to start the environment components
    task run();
        $display("T=%0t [%s] Starting env...", $time, TAG);
        
        agent_1 = new(uart_1_vif, uart_cfg);
        agent_2 = new(uart_2_vif, uart_cfg);
        
        // Set up the scoreboard mailbox for each agent
        agent_1.mon.scb_mailbox = scb_mailbox;
        agent_2.mon.scb_mailbox = scb_mailbox;
        
        // Start the agents and scoreboard
        fork
            agent_1.run();
            agent_2.run();
            scb.run();
        join_any
    endtask : run

    
endclass : uart_env

`endif//UART_ENV