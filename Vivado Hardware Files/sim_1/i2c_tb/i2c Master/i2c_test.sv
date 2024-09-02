`ifndef _I2C_TEST
`define _I2C_TEST

`include "i2c_m_env.sv"

class i2c_test;
    i2c_m_env env;
    string TAG = "Test";
    
    function new(virtual i2c_m_if _vif);
        env = new(_vif);
    endfunction : new
    
    task main();
        $display("[%s] Starting...", TAG);
        //Run the env main function
        env.main();
        #100;
        //Print when test is complete
        $display("[%s] Test Complete", TAG);
        env.display_final();
    endtask : main

endclass : i2c_test


`endif //_I2C_TEST