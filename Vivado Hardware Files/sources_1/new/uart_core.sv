`timescale 1ns / 1ps

/*
* UART Core that interfaces with the Memory mapped I/O. The architecture of the core is as folllows:
* Status & data (register 0): 
*   bits 7-0: 8-bit receieved data
*   bit 8: empty status of rx fifo
*   bit 9: full status of tx fifo
* Baud Rate dvsr (register 1):
*   bits 10 - 0: divisor value
* Write data (register 2):
*   bits 7-0: 8-bit value to transmit
* Read data removal (Register 3):
*   dummy data write to generate pulse to remove a data byte from rx FIFO
*/

module uart_core
#(parameter FIFO_DEPTH = 8)
(
    input logic clk, reset,
    //Slot Interface
    input logic cs,
    input logic read,
    input logic write,
    input logic [4:0] reg_addr,
    input logic [31:0] wr_data,
    output logic [31:0] rd_data,
    //UART Signals
    output logic tx,
    input logic rx    
);

//Signal Declarations
logic wr_en;
logic wr_uart, rd_uart, wr_dvsr;
logic tx_full, rx_empty;
logic [10:0] dvsr_reg;
logic [7:0] r_data;
logic ctrl_reg;

//Module Instantation
uart_wrapper#(.DATA_BITS(8), .STOP_BITS(1), .FIFO_WIDTH(FIFO_DEPTH), .OVRSAMPLING(16), .DVSR_WIDTH(11)) uart_unit
             (.*, .wr_data(wr_data[7:0]), .dvsr(dvsr_reg), .rd_data(r_data));
             
//Dvsr Register Logic
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        dvsr_reg <= 0;
    else
        if(wr_dvsr)
            dvsr_reg <= wr_data[10:0];            
end             

//Decoding Logic to write to registers
assign wr_en = cs && write;
assign wr_dvsr = (wr_en && (reg_addr == 5'b1));
assign wr_uart = (wr_en && (reg_addr == 5'b10));
assign rd_uart = (wr_en && (reg_addr == 5'b11));

//Logic to read data from the uart slot interface
//The only register that is readable is register 0, so this register should be output
assign rd_data = {22'h0, tx_full, rx_empty, rd_data};

endmodule
