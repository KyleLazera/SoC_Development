`timescale 1ns / 1ps

/*
* This is the core that allows the microblaze to directly interact with the PWM peripheral.
* It allows for a configurable resolution (this applies to all pwm output ports) & a configurable 
* duty cycle for each output port.
* The register architecture is as follows:
* Register address 0x00: 
*   Bits 31 to 0: divisor/prescaler register used to determine the PWM frequency
* Register address 0x01:
*   Bits 31 to 0: resolution register - holds the resolution of the PWM counter
* Register address 0x1X:
*   Bits RES to 0: duty cycle for each pwm port X
* Note: The equation to determines the dvsr for the desired switching freq is: f = ((sys_freq)/(dvsr))/2**(Resolution))
*/
module pwm_core
#(
    parameter OUT_PORTS = 6,                //Number of output ports
    parameter RES = 10                      //Number of resolution bits
 )                   
(
    input logic clk, reset,
    //Slot Interface 
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    //External signal
    output logic [OUT_PORTS-1:0] pwm_out
);

/************ Signal Declaration *******************/
//Register signals
logic [31:0] duty_reg [OUT_PORTS-1:0];
logic [31:0] dvsr_reg, res_reg;
logic duty_array_en, dvsr_en, res_en;
//PWM Signals
logic [31:0] dvsr_ctr;              //Register to count up to the dvsr_reg value
logic [31:0] duty_ctr;              //Register to count up to the duty_reg value
logic [OUT_PORTS-1:0] pwm_reg, pwm_next;

/*************** Register Interface Logic *******************/

//Decoding logic fo registers
assign dvsr_en = write && cs && (reg_addr == 5'b0);
assign duty_array_en = write && cs && reg_addr[4];
assign res_en = write && cs && (reg_addr == 5'b1);

//Logic to write a dvsr into the register address
always_ff @(posedge clk) begin
    if(reset) begin
        dvsr_reg <= 0;
        res_reg <= 32'h000000FF; //Default resolution set to 255 (2**8)
    end
    else begin
        if(dvsr_en) 
            dvsr_reg <= wr_data;
       
        if(res_en)
            res_reg <= wr_data; 
    end    
end

//Logic to write the duty cycle into a specified pwm port
always_ff @(posedge clk) begin
    if(duty_array_en)
        duty_reg[reg_addr[3:0]] <= wr_data[31:0];
end

/*************** PWM Logic ****************/
//PWM counting logic
always_ff @(posedge clk) begin
    if(reset) begin
        dvsr_ctr <= 0;
        duty_ctr <= 0;
        pwm_reg <= 0;
    end
    else begin
        //Dvsr/prescaler counting logic
        dvsr_ctr <= (dvsr_ctr == dvsr_reg) ? 0 : dvsr_ctr + 1;      
        //Duty cycle counting logic
        if(dvsr_ctr == 0) 
            duty_ctr <= (duty_ctr == res_reg) ? 0 : duty_ctr + 1;
        
        pwm_reg <= pwm_next;
    end
end

//Decoding logic for each PWM port
generate 
    genvar i;
    for(i = 0; i < OUT_PORTS; i++) 
        assign pwm_next[i] = {1'b0, duty_ctr} < duty_reg[i];
endgenerate

//Output logic 
assign pwm_out = pwm_reg;
assign rd_data = 32'h0;     //Read dat not used

endmodule
