`ifndef     _PWM_TRANS_ITEM
`define     _PWM_TRANS_ITEM

//Transaction Item used in the scoreboard - used to derive the self-checking testbench
class pwm_trans_item;
    // Values generated & sent to the module
    bit [31:0] dvsr;                   //The dvsr value to pass into the PWM module
    rand int duty_cycle;               //The actual duty cycle of the PWM (percentage) - calculated based off duty_count
    bit [10:0] duty_count;             //The value to count up to - this is placed into the PWM module
    bit [31:0] resolution;             //Holds the resolution value for the PWM module
    
    //Values calculated by testbench for self-checking
    int calc_dvsr;
    int calc_duty_cycle;
    
    //Constrain the duty cycle - for this case, we will excllude the two edge cases where the duty cycle is 0 and 100 to
    //keep the testbench simple - this functionality will be tested in realtime using a logic analyzer/oscilliscope
    constraint duty_cycle_range
    {
        duty_cycle > 0;
        duty_cycle < 100;
    }
    
    //Function used for printing out the generated items only
    function void print_gen(string tag = "");
        $display("[%s] dvsr: %0d, duty_cycle: %0d calc_dvsr: %0d, calc_dc: %0d, ", tag, dvsr, duty_cycle, calc_dvsr, calc_duty_cycle);
    endfunction
    
    //Function used for printing out the Calculated items only
    function void print_calc(string tag = "");
        $display("[%s] dvsr: %0d, duty_cycle: %0d ", tag, calc_dvsr, calc_duty_cycle);
    endfunction
    
endclass : pwm_trans_item

`endif     //_PWM_TRANS_ITEM
