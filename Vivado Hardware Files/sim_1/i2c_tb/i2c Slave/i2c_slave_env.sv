`ifndef _I2C_SLAVE_ENV
`define _I2C_SLAVE_ENV

`include "i2c_slave_driver.sv"
`include "i2c_slave_gen.sv"
`include "i2c_slave_monitor.sv"
`include "i2c_slave_scb.sv"

class i2c_slave_env;
    //Init the environemnt components
    i2c_slave_gen       gen;
    i2c_slave_driver    drv;
    i2c_slave_monitor   mon;
    i2c_slave_scb       scb;
    //Init mailboxes & events
    mailbox drv_mbx;
    mailbox scb_mbx, scb_drv_mbx;    
    event drv_done;
    //virtual interface
    virtual i2c_slave_if vif;
    string TAG = "Environment";
    
    function new(virtual i2c_slave_if _vif);
        //Init mailboxes
        scb_mbx = new();
        scb_drv_mbx = new();    
        drv_mbx = new();
        //init components
        gen = new(drv_mbx, drv_done);
        drv = new(drv_mbx, scb_drv_mbx, drv_done);
        mon = new(scb_mbx);
        scb = new(scb_mbx, scb_drv_mbx);        
        //Init virtual interface
        vif = _vif;
    endfunction : new    
    
    task main();
        $display("[%s] Starting...", TAG);
        
        //Assign virtual interface to the driver & monitor
        drv.vif = vif;
        mon.vif = vif;
        
        fork
            gen.main();
            drv.main();
            mon.main();
            scb.main();
        join_any
    endtask : main
    
    function final_scoreboard();
        scb.display_final();
    endfunction : final_scoreboard


endclass : i2c_slave_env


`endif //_I2C_SLAVE_ENV