`ifndef _I2C_ENV
`define _I2C_ENV

`include "i2c_gen_m.sv"
`include "i2c_m_driver.sv"
`include "i2c_m_monitor.sv"
`include "i2c_m_scb.sv"

class i2c_m_env;
    //instances of the generator, monitor and driver
    i2c_gen_m       generator;
    i2c_m_driver    drv;
    i2c_m_monitor   mon;
    i2c_m_scb       scb;
    //Mailbox & event Instances
    mailbox drv_mbx, scb_mbx, gen_scb_mbx;
    event drv_done, mon_done;
    //Class variables
    string TAG = "Env";
    
    //Environment constructor
    function new(virtual i2c_m_if _vif);
        //Init mailboxes
        drv_mbx = new();
        scb_mbx = new();
        gen_scb_mbx = new();
        //Init each class
        generator = new(drv_mbx, drv_done);
        drv = new(drv_mbx, drv_done, _vif);
        mon = new(scb_mbx, _vif);
        scb = new(scb_mbx);
    endfunction : new
    
    //Create a process for each task to run in 
    task main();
        $display("[%s] Starting...", TAG);
        
        mon.mon_done = mon_done;
        generator.mon_done = mon_done;
        generator.gen_scb_mbx = gen_scb_mbx;
        scb.gen_scb_mbx = gen_scb_mbx;
        
        fork
            drv.main();
            generator.main();
            mon.main();
            scb.main();
        join_any
        
    endtask : main
    
    function display_final();
        scb.final_score();
    endfunction: display_final
    

endclass : i2c_m_env

`endif //_I2C_ENV
