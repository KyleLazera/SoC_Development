`timescale 1ns / 1ps

/*
* This module will be a GPIO Bidirectional I/O core as opposed to individual GPI and GPO cores.
*/
module gpio_core
#(parameter DATA_WIDTH = 16)
(
    input logic clk, reset,
    //Slot Interface 
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    //External Wires
    output logic [DATA_WIDTH-1:0] data_out,
    input logic [DATA_WIDTH-1:0] data_in
);

//Signal Declerations
logic [DATA_WIDTH-1:0] input_buf, output_buf;
logic wr_en;
tri [DATA_WIDTH-1:0] tri_buffer;
logic ctrl_reg, wr_ctrl;

/************** Input/Output Buffer Registers *************/
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        begin
            input_buf <= 0;
            output_buf <= 0;
        end
    else
        begin
            input_buf <= data_in[DATA_WIDTH-1:0];   //Input is always sampling
            //If control register is high (output mode) write data to register
            if(ctrl_reg && wr_en) 
                output_buf <= wr_data[DATA_WIDTH-1:0];
        end
end

//Tri State buffer controls the output data (high impedence or output buffer)
assign tri_buffer = ctrl_reg ? output_buf : 1'bZ;
//If register specified is 0x2, write data into output register
assign wr_en = write && cs && (reg_addr == 4'b0010);

/************** Control Register Logic ***************/
//This controls the direction of the GPIO peripheral:
//      0 - Signals input (this is default)
//      1 - Signals output
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        ctrl_reg <= 0;    
    else
        if(wr_ctrl)
            ctrl_reg <= wr_data[0];
end

assign wr_ctrl = cs && write && (reg_addr == 4'b0011);

/*************** Output Logic ***********************/
assign data_out = tri_buffer;
assign rd_data[31:DATA_WIDTH] = 0;
assign rd_data[DATA_WIDTH-1:0] = input_buf; 

endmodule
