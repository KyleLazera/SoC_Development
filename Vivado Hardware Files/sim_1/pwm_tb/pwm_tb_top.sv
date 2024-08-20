`timescale 1ns / 1ps


/* This module is used to test the PWM module using a large variety of possible values. This is not an extensive testbench, 
* that tests all conditions. The test does not handle the 2 edge cases where a duty cycle of 0 or 100 is used. This would have added
* more complexity to the testbench, which I felt was unnecessary for this rather simple module. Overall, the testbench is used to ensure 
* the module works over a large number of tests cases wihtout needing to regenerate a bitstream on each occassion*/
module pwm_tb_top;

    logic clk, reset;
    //Inst clock with 10 ns period
    always #5 clk = ~clk;
    //Init the virtual interface
    pwm_if  pwm_vif(clk, reset);
    
    //Module inst
    pwm_core #(.OUT_PORTS(6), .RES(8)) pwm_dut(.clk(clk), .reset(reset), .cs(pwm_vif.cs), .read(pwm_vif.read), .write(pwm_vif.write),
                                               .reg_addr(pwm_vif.reg_addr), .wr_data(pwm_vif.wr_data), .rd_data(pwm_vif.rd_data), 
                                               .pwm_out(pwm_vif.pwm_out));
                                               
    //Test Instance
    pwm_test default_test;
    
    initial begin
        clk = 0;
        
        //Reset the circuit
        reset = 1'b1;
        #10;
        reset = 1'b0;
        
        default_test = new(pwm_vif);
        default_test.env.vif = pwm_vif;
        default_test.main();
        
        #200;
        $finish;
    end

endmodule
