`ifndef _PWM_VIF
`define _PWM_VIF

//Virtual interface for the PWM Core
interface pwm_if(input logic clk, input logic reset); 
    logic cs;
    logic read;
    logic write;
    logic [4:0] reg_addr;
    logic [31:0] wr_data;
    logic [31:0] rd_data;
    logic [5:0] pwm_out;
endinterface

`endif //_PWM_VIF