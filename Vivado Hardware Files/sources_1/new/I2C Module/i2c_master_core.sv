`timescale 1ns / 1ps

/*
 * This module contains the wrapping circuit for the I2C master interface that allows the i2c master
 * to interact with the processor. To interact with the i2c master core, the processor must write values
 * into the "registers" based on the desired action. The wrapper architecture is as follows: 
 * Note: Not all registers are explicity declared in this wrapper
 * Read/Status Register : Offsett 0x00
 *      bit 9 : ack bit
 *      bit 8 : ready status
 *      bit 7 - 0: 8-bit receieved data
 * Dvsr Register : Offset 0x0
 *      bit 15 - 0: dvsr value
 * Data & Ctrl Reg : Offset 0x1
 *      bit 10 - 8: command for i2c
 *      bit 7 - 0: 8-bit data to write on i2c
*/
module i2c_master_core
(
    input logic clk, reset,
    //Slot Interface 
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    //I2C Interface
    output tri scl,
    inout tri sda    
);

//Signal Declarations
logic [15:0] dvsr_reg;
logic wr_i2c, wr_dvsr;
logic [7:0] dout;
logic ready, ack, done;

//Instantiate I2C Controller
i2c_master i2c_master_core(.clk(clk), .reset(reset), .din(wr_data[7:0]), .dvsr(dvsr_reg), .cmd(wr_data[10:8]), 
                            .wr_i2c(wr_i2c), .ready(ready), .done_tick(done), .ack(ack), .dout(dout), .sda(sda), .scl(scl));
                            
/* Register Logic */
always_ff @(posedge clk) begin
    if(reset) 
        dvsr_reg <= 0;
    else 
        if(wr_dvsr)
            dvsr_reg <= wr_data[15:0];
end                            

// Decoding Logic
assign wr_dvsr = cs && write && ~reg_addr[0];
assign wr_i2c = cs && write && reg_addr[0];
assign rd_data = {21'h0, done, ack, ready, dout};

endmodule
