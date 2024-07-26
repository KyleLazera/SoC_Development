`timescale 1ns / 1ps

/*
*Custom General Purpose Output core that will interface with the Microblaze MCS.
*/
module GPO_Core
#(DATA_WIDTH = 16)                  //Data width is set to 16 because BASYS3 has 16 LED's
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
    output logic [DATA_WIDTH-1:0] data_out
);

//Signal Declerations
logic [DATA_WIDTH-1:0] buf_reg;
logic wr_en;

always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        buf_reg <= 0;
    else
        if(wr_en)
            //Do not write all 32 bits of data to the buffer - only write the amount needed 
            buf_reg <= wr_data[DATA_WIDTH-1:0];
end

//We should only write to the GPO if the following conditions are met:
//1) CS is high - this signal comes from the decoder in MMIO controller
//2) If write pin is high - this signal comes from the Microblaze MCS CPU
//Note: This core does not have any control registers, therefore the reg_addr does not matter
assign wr_en = cs && write;
//Make sure that the read data output is always 0 in this core
assign rd_data = 0;
//Set output of the core equal to the contents of the buffer
assign data_out = buf_reg;

endmodule
