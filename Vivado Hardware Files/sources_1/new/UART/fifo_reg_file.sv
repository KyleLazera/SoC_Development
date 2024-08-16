`timescale 1ns / 1ps


module fifo_reg_file
#(
    parameter DATA_WIDTH,
              ADDR_WIDTH
)
(
    input logic clk, 
    input logic wr_en,
    input logic [ADDR_WIDTH-1:0] w_addr, r_addr,
    input logic [DATA_WIDTH-1:0] wr_data,
    output logic [DATA_WIDTH-1:0] rd_data
);

//Signal Declarations
logic [DATA_WIDTH-1:0] array_reg [0:(2**ADDR_WIDTH)-1];

//Reading/writing to FIFO logic
always_ff @(posedge clk)
    if(wr_en)
        array_reg[w_addr] <= wr_data;

//Output logic   
assign rd_data = array_reg[r_addr];


endmodule
