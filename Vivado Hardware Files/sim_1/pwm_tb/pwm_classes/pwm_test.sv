`ifndef     _PWM_TEST
`define     _PWM_TEST

`include "pwm_env.sv"

class pwm_test;
    //Init env
    pwm_env     env;
    //mailbox
    mailbox     drv_mbx;
    //Event indicating that a transmission was complete
    event trans_complete;
    string TAG = "Test";
    
    function new(virtual pwm_if vif);
        env = new();
        drv_mbx = new();
    endfunction : new
    
    task main();
        //assign driver mailbox
        env.driver.drv_mbx = drv_mbx;
        env.monitor.trans_complete = trans_complete;
        
        //Call environemnt task in a seperate thread
        fork
            env.main();
        join_none
        //Apply stimulus here
        stimulus();
        //Print the scoreboard after completion
        env.scb.display_score();
    endtask : main

    task stimulus();
        //Create a virtual interface
        pwm_trans_item gen_item = new;
        
        for(int i = 0; i < 100; i++) begin 
            $display("[%s] Generating stimulus %0d", TAG, i);
            //On the first iteration, generate a random dvsr and resolution value 
            if(i == 0) begin
                gen_item.dvsr = 120;
                gen_item.resolution = 1023;
            end
            //The duty cycle is varied
            gen_item.randomize();
            gen_item.duty_count = ((gen_item.duty_cycle)*(gen_item.resolution))/(100);
            drv_mbx.put(gen_item);
            gen_item.print_gen(TAG);
            @(trans_complete);
        end
    endtask : stimulus

endclass : pwm_test

`endif      //_PWM_TEST
