`timescale 1ns / 1ps

/*
*This will be a 48 bit counter that will be used to reset the processor. It will take approximatley 32
* days to reset, counting at 100MHz.
* This counter module will have 3 registers, each 32 bits:
* Register 0: lower 32 bits of the counter.
* Register 1: Upper 16 bits of counter
* Register 2: Control Register:
*       Bit 0: Go -> When high counter increments
*       Bit 1: clr -> When high the counter is reset
*
*/
module Timer_Core
#(parameter COUNTER_WIDTH = 48)
(
    input logic clk, reset,
    //Slot Interface 
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data
);

//Signal Declerations
logic [COUNTER_WIDTH-1:0] counter_reg;
logic ctrl_reg;
logic wr_en, clr, go;

/********Counter Logic***********/
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        counter_reg <= 0;
    else
        if(clr)
            counter_reg <= 0;
        else if(go)
            counter_reg <= counter_reg + 1;
end

/********Control Circuit (for Control Register)***********/
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        ctrl_reg <= 0;
    else
        if(wr_en)
            ctrl_reg <= wr_data[0];
end

//The write enable signal determine if the ctrl register can be written to
//It can only be written to if the following conditions are met:
//1) The chip select for the current module is high
//2) The write bit is high from the CPU
//3) The register address is 2 - this is for control register
assign wr_en = cs && write && (reg_addr[1:0] == 2'b10);
assign clr = wr_en && wr_data[1];
assign go = ctrl_reg;

//If the input address lsb is 0 read the lower bits of counter and if it is 1 read the upper bits
assign rd_data = (reg_addr[0] == 0) ? counter_reg[31:0] : {16'h0000, counter_reg[COUNTER_WIDTH-1:32]};

endmodule
