`timescale 1ns / 1ps

/*
* Creates a FIFO Buffer that utilizes a FIFO Controller and a register file
*/
module fifo
#(
    parameter DATA_WIDTH = 8,
              ADDR_WIDTH = 2
)
(
    input logic clk, reset,
    input logic rd, wr, 
    input logic [DATA_WIDTH-1:0] wr_data,
    output logic full, empty, 
    output logic [DATA_WIDTH-1:0] rd_data
);

//Signal Declarations
logic [ADDR_WIDTH-1:0] w_addr, r_addr;
logic wr_en, full_tmp;

assign wr_en = wr & ~full_tmp;          //write enable is high if wr is set and the FIFO is not full
assign full = full_tmp;

//Module Inst.
fifo_controller#(.ADDR_WIDTH(ADDR_WIDTH)) c_unit
                (.*, .full(full_tmp));
                
fifo_reg_file#(.ADDR_WIDTH(ADDR_WIDTH), .DATA_WIDTH(DATA_WIDTH)) reg_file(.*);                

endmodule
