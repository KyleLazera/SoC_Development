`timescale 1ns / 1ps

module sseg_controller
#(parameter DATA_WIDTH = 12)
(
    input logic clk, reset,
    //Slot Interface
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    //External seg interface
    output logic [3:0] an,
    output logic [7:0] sseg
);

//Signal Declarations
logic [DATA_WIDTH-1:0] buf_reg;
logic wr_en;

always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        begin
            buf_reg[3:0] <= 4'b1111;
            buf_reg[DATA_WIDTH-1:4] <= 8'b00000000;
        end      
    else
        if(wr_en)   
            buf_reg <= wr_data[DATA_WIDTH-1:0];
end

assign wr_en = write && cs;

assign rd_data = 0;
assign sseg = buf_reg[DATA_WIDTH-1:4];
assign an = buf_reg[3:0];

endmodule
