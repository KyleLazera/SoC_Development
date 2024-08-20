    `ifndef     _PWM_SCB
`define     _PWM_SCB

class pwm_scoreboard;
    //mailbox
    mailbox scb_mbx, drv_scb_mbx;
    //Variables
    int dvsr_succ = 0, dvsr_fail = 0;
    int dc_succ = 0, dc_fail = 0;
    string TAG = "Scoreboard";
    
    task main();
        $display("[%s] Starting...", TAG);
    
        forever begin
            pwm_trans_item rec_item, gen_item;
            //get the generated item from the monitor first
            drv_scb_mbx.get(gen_item);
            //Recieve the item from the monitor
            scb_mbx.get(rec_item);
            //rec_item.print(TAG);
            //Validate the calculated items
            validate_dvsr(gen_item, rec_item);
            validate_duty_cycle(gen_item, rec_item);
        end
 
    endtask : main
    
    //Function used to validate the dvsr calculation
    function void validate_dvsr(pwm_trans_item gen_item, pwm_trans_item rec_item);
        if((rec_item.calc_dvsr < (gen_item.dvsr - 1)) || rec_item.calc_dvsr > (gen_item.dvsr + 1)) begin
            dvsr_fail++;
            $display("[%s] Dvsr Failed", TAG);
        end
        else begin
            dvsr_succ++;
            $display("[%s] Dvsr Success", TAG);
        end
    endfunction : validate_dvsr
    
    //Function used to validate the duty cycle calculation
    function void validate_duty_cycle(pwm_trans_item gen_item, pwm_trans_item rec_item);
        if((rec_item.calc_duty_cycle < (gen_item.duty_cycle - 1)) || rec_item.calc_duty_cycle > (gen_item.duty_cycle + 1)) begin
            dc_fail++;
            $display("[%s] Duty Cycle Failed", TAG);
        end
        else begin
            dc_succ++;
            $display("[%s] Duty Cycle Success", TAG);
        end
    endfunction : validate_duty_cycle
    
    //Function that displays the final score - called from the
    function void display_score();
        $display("****************************************");
        $display("Final Score Board: ");
        $display("Successeful PWM Transmissions: %0d", dc_succ);
        $display("Failed PWM Transmissions: %0d", dc_fail);
    endfunction

endclass : pwm_scoreboard

`endif  //_PWM_SCB
