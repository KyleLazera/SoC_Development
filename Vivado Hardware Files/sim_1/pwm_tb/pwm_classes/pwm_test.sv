`ifndef     _PWM_TEST
`define     _PWM_TEST

`include "pwm_env.sv"

class pwm_test;
    //Init env
    pwm_env     env;
    //mailbox
    mailbox     drv_mbx, drv_scb_mbx;
    //Event indicating that a transmission was complete
    event trans_complete;
    string TAG = "Test";
    
    function new(virtual pwm_if vif);
        env = new();
        drv_mbx = new();
        drv_scb_mbx = new();
    endfunction : new
    
    task main();
        //assign driver mailbox
        env.driver.drv_mbx = drv_mbx;
        env.driver.drv_scb_mbx = drv_scb_mbx;
        env.scb.drv_scb_mbx = drv_scb_mbx;
        env.monitor.trans_complete = trans_complete;
        
        //Call environemnt task in a seperate thread
        fork
            env.main();
        join_none
        //Apply stimulus here
        stimulus();
        env.scb.display_score();
    endtask : main

    task stimulus();
        for(int i = 0; i < 100; i++) begin
            pwm_trans_item gen_item = new;
            $display("[%s] Starting stimulus...", TAG);
            gen_item.randomize();
            gen_item.dvsr = 120;
            gen_item.duty_count = ((gen_item.duty_cycle)*(2**8))/(100);
            drv_mbx.put(gen_item);
            gen_item.print_gen(TAG);
            @(trans_complete);
        end
    endtask : stimulus

endclass : pwm_test

`endif      //_PWM_TEST
