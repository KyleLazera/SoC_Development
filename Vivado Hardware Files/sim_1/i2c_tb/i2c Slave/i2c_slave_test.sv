`ifndef _I2C_SLAVE_TEST
`define _I2C_SLAVE_TEST

`include "i2c_slave_env.sv"

class i2c_slave_test;
    //Init components of test 
    i2c_slave_env       env;
    string TAG = "Test";
    
    function new(virtual i2c_slave_if _vif);
        //init components
        env = new(_vif);
    endfunction : new
    
    task main();
        $display("[%s] Stating...", TAG);
        
        fork
            env.main();
        join_any
        
        //Slight delay followed by final Scoreboard
        #100;
        env.final_scoreboard();
    endtask : main
    
endclass : i2c_slave_test

`endif //_I2C_SLAVE_TEST