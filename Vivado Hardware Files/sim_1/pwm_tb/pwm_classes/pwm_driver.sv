`ifndef     _PWM_DRIVER
`define     _PWM_DRIVER

`include "pwm_trans_item.sv"

class pwm_driver;
    //instance of virtual inerface
    virtual pwm_if vif;
    //mailbox and event 
    mailbox drv_mbx, drv_scb_mbx;
    //debugging TAG
    string TAG = "Driver";
    
    task main();
        $display("[%s] Starting...", TAG);
        
        forever begin 
            @(posedge vif.clk);           
            for(int i = 0; i < 4; i++) begin
                //Generated transaction Item
                pwm_trans_item pwm_gen_item;
                $display("[%s] Waiting for Item...", TAG);
                drv_mbx.get(pwm_gen_item);
                //Send the generated item to the scoreboard
                drv_scb_mbx.put(pwm_gen_item);
                //Set the dvsr/prescaler for all of the PWM ports - this is universal to all ports
                //therefore only set it once
                if(i == 0)
                    write_pwm(5'h0, pwm_gen_item.dvsr);
                
                //Write a duty cycle to each port
                write_pwm(5'b10000, pwm_gen_item.duty_count);
                //pwm_gen_item.print(TAG);
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
