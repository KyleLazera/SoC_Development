`timescale 1ns / 1ps

/*
* General Purpose Input core used to interface the Microblaze MCS with the external world
*/
module GPI_Core
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
    //External wires for the GPI core
    input logic [DATA_WIDTH-1:0] data_in
);

//Signal Declerations
logic [DATA_WIDTH-1:0] buf_reg;

always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        buf_reg <= 0;
    else
        buf_reg <= data_in;
end

//The GPI core will continously sample data on every clock cycle but the MMIO controller
//will determine whether its' data will be sent to the processor using a multiplexer
//Note: The output data is 32 bits but we need to append 0's in fron to the actual data because we are not sending
//the full 32 bits of data 
assign rd_data[31:DATA_WIDTH] = 0;
assign rd_data[DATA_WIDTH-1:0] = buf_reg;

endmodule
