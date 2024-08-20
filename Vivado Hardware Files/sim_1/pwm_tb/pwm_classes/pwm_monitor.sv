`ifndef     _PWM_MONITOR
`define     _PWM_MONITOR

class pwm_monitor;
    //virtual interface
    virtual pwm_if vif;
    //mailbox
    mailbox scb_mbx;
    //Event indicating that a transmission was complete
    event trans_complete;
    string TAG = "Monitor";
    
    
    task main();
    $display("[%s] Starting...", TAG);
    @(posedge vif.clk);
    
    forever begin
        pwm_trans_item rec_item = new;
        
        //Calculate the duty_cycle and dvsr 
        calculate_values(rec_item.calc_duty_cycle, rec_item.calc_dvsr);
        rec_item.print_calc(TAG);
        scb_mbx.put(rec_item);
        //Signal the driver to send another "pulse"
        ->trans_complete;
    end
    
    endtask : main
    
    //task that calculates the dvsr & duty cycle based on the recieved signal from the hardware
    task calculate_values(output int duty_cycle, output int dvsr);
        int start_time, pulse_low, completion_time;
        int duty_cycle_dur, dvsr_dur;
        int duty_cycle, dvsr;
        
       start_time = $time;
        wait(vif.pwm_out[0] == 1'b1);

        //Wait until the pwm signal goes low - indicating the pulse has ended & sample the time
        wait(vif.pwm_out[0] == 1'b0);
        pulse_low = $time;

        //Wait until the pwm pulse goes high again - this will be the duration of a single pulse period
        wait(vif.pwm_out[0] == 1'b1);
        completion_time = $time;
        
        //Calculate the period of the entire process and the pulse
        duty_cycle_dur = pulse_low - start_time;
        dvsr_dur = completion_time - start_time;
        //$display("[%s] dvsr_dur: %0d, duty_cycle_dur: %0d", TAG, dvsr_dur, duty_cycle_dur);
        //using formula: dvsr = ((2^res)(sys_clk))/dvsr_period
        //This formula can be used to cauclate the dvsr from the period of the dvsr
        dvsr = ((dvsr_dur)/10)/(2**8);
        duty_cycle = ((duty_cycle_dur)*(100))/(dvsr_dur);  
    endtask : calculate_values
    
    
endclass : pwm_monitor

`endif  //_PWM_MONITOR
