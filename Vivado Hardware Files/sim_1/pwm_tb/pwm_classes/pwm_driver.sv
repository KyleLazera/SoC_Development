`ifndef     _PWM_DRIVER
`define     _PWM_DRIVER

`include "pwm_trans_item.sv"

class pwm_driver;
    //instance of virtual inerface
    virtual pwm_if vif;
    //mailbox and event 
    mailbox drv_mbx;
    //debugging TAG
    string TAG = "Driver";
    
    task main();
        $display("[%s] Starting...", TAG);
        
        forever begin 
            for(int i = 0; i < 2; i++) begin
            //Generated transaction Item
            pwm_trans_item pwm_gen_item;
            @(posedge vif.clk);           
            $display("[%s] Waiting for Item...", TAG);
            drv_mbx.get(pwm_gen_item);
            //pass the resolution, duty cycle, dvsr  & channel id through the VIF. This is used for scoreboard monitoring
            vif.res = pwm_gen_item.resolution;
            vif.actual_duty_cycle = pwm_gen_item.duty_cycle;
            vif.actual_dvsr = pwm_gen_item.dvsr;
            //Write the dvsr and resolution
            write_pwm(5'h0, pwm_gen_item.dvsr);             //Write dvsr into the module
            write_pwm(5'h1, pwm_gen_item.resolution);       //Write resolution into the module
            //Write a duty cycle to each port
            write_pwm(5'b10000, pwm_gen_item.duty_count);
            end
        end
    endtask : main
    
    //Task used to write generated values to the PWM core
    task write_pwm(input logic[5:0] _reg_addr, input logic[31:0] data);
        vif.cs = 1'b1;
        vif.write = 1'b1;
        vif.read = 1'b0;
        vif.reg_addr = _reg_addr;
        vif.wr_data = data;
        @(posedge vif.clk);
        //Reset all values
        vif.cs = 1'b0;
        vif.write = 1'b0;
        vif.read = 1'b0;
    endtask : write_pwm
    
    
endclass : pwm_driver

`endif     // _PWM_DRIVER
