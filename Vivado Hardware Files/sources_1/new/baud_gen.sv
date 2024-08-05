`timescale 1ns / 1ps

/*
* Baud generator module. This module is similar to a module counter to generate a tick.
* It takes in a dvsr, which is input by the user, to determine the baudrate. The following equation can be used
* to calculate the dvsr for the desired baud rate:
* dvsr = ((sys_freq)/(16 * baud)) - 1
* where sys-freq is 100MHz for teh Basys3 Dev board and baud is the desired baud rate 
* Note: To decrease circuit complexity, we count up to the dvsr not dvsr-1
*/
module baud_gen
#(parameter DVSR_WIDTH = 11)
(
    input logic clk, reset,
    input logic [DVSR_WIDTH-1:0] dvsr,
    output logic tick
);

//Signal Declarations 
logic [DVSR_WIDTH-1:0] counter_reg;

//Counter logic
always_ff @(posedge clk , posedge reset)
begin
    if(reset)
        counter_reg <= 0;
    else
        counter_reg <= (counter_reg == dvsr) ? 0 : counter_reg + 1;        
end

//Output logic
assign tick = (counter_reg == 1);

endmodule
