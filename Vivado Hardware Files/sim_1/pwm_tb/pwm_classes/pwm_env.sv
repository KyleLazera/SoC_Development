`ifndef     _PWM_ENV
`define     _PWM_ENV

//Includes
`include "pwm_driver.sv"
`include "pwm_monitor.sv"
`include "pwm_scoreboard.sv"

class pwm_env;
    pwm_driver      driver;
    pwm_monitor     monitor;
    pwm_scoreboard  scb;
    //mailbox and events
    mailbox         scb_mbx;
    //Virtual Interface
    virtual pwm_if vif;
    
    function new();
        //component init
        driver = new;
        monitor = new;
        scb = new;
        //Mailbox initialization
        scb_mbx = new();
    endfunction : new
    
    task main();
        //Assign virtual interfaces
        driver.vif = vif;
        monitor.vif = vif;
        //assign mailboxes
        monitor.scb_mbx = scb_mbx;
        scb.scb_mbx = scb_mbx;
        
        //Fork into threads for each component
        fork
            driver.main();
            monitor.main();
            scb.main();
        join_any
    endtask : main


endclass : pwm_env

`endif