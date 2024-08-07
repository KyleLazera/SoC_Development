`timescale 1ns / 1ps

/*
* UART Core that interfaces with the Memory mapped I/O. The architecture of the core is as folllows:
* Note: the following architecture is not implemented physically - the registers do not all correlate with physical registers
* Control Register (Register 0):
*   bits 10 - 0: dvsr for baud rate
*   bit 11: parity enable -> (0 - disable, 1 -enable)
*   bit 12: parity odd/even -> (1 - even, 0 - odd) 
*   bit 14 & 13: stop bits -> (00 - 1 stop bit, 01 - 1.5 stop bits, 10 - 2 stop bits)
*   bit 15: data bits -> (0 - 7 data bits, 1 - 8 data bits) 
* Status Register (Register 1):
*   bit 0: Parity Error
*   bit 1: Frame error
*   bit 2: Buffer Overrun Error
*   bit 3: Rx FIFO Empty
*   bit 4: Tx FIFO Full
* Read Register (Register 2):
*   bits 7 - 0: read data
* Write Register (Register 3):
*   bits 7 - 0: write data
*/

module uart_core
#(parameter FIFO_DEPTH = 8)     //Address width for FIFO (2**FIFO_DEPTH) = num of data FIFO holds
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

//Register addresses
localparam CTRL_REG = 5'b00;
localparam STATUS_REG = 5'b01;
localparam RD_REG = 5'b10;
localparam WR_REG = 5'b11;


/********************* Signal Declarations ************************/
logic wr_en;
logic wr_uart, rd_uart, wr_ctrl;
logic data_bit, parity_en, parity_pol;
logic [1:0] stop_bits;
//Status signals
logic tx_full, rx_empty, parity_err, frame_err, buffer_err;
//Registers
logic [15:0] control_reg;
logic [10:0] dvsr_reg;
logic [7:0] r_data;                 //Data read from the UART wrapper


//Module Instantation
uart_wrapper#(.DATA_BITS(8), .FIFO_WIDTH(FIFO_DEPTH), .OVRSAMPLING(16), .DVSR_WIDTH(11)) uart_unit
            (.*, 
             .wr_data(wr_data[7:0]), 
             //Control Register Bits 
             .dvsr(dvsr_reg),           //dvsr for baud rate
             .data_bit(data_bit),       //Number of data bits
             .sb_ticks(stop_bits),     //Number of stop bits
             .wr_uart(wr_uart),
             .rd_uart(rd_uart),
             .rd_data(r_data),
             .tx_full(tx_full),
             .rx_empty(rx_empty),
             .parity_err(parity_err));
             
//Dvsr Register Logic
always_ff @(posedge clk, posedge reset)
begin
    if(reset)
        control_reg <= 0;
    else
        if(wr_ctrl)
            control_reg <= wr_data[15:0];          
end             

//Decoding Logic 
assign wr_en = cs && write;
assign wr_ctrl = (wr_en && (reg_addr == CTRL_REG));
//Logic for wires entering the uart_wrapper module
assign rd_uart = (cs && read && (reg_addr == RD_REG));
assign wr_uart = (wr_en && (reg_addr == WR_REG)); 
//Decoding of control register
assign dvsr_reg = control_reg[10:0];  
assign data_bit = control_reg[15];
assign parity_en = control_reg[11];
assign parity_pol = control_reg[12];
assign stop_bits = control_reg[14:13];  

//Logic to read data from the uart slot interface
//Only the status reg and read reg can be read from
assign rd_data = (reg_addr == STATUS_REG) ?   {27'h0, tx_full, rx_empty, 2'b00, parity_err} : {24'h0, r_data}; //TODO: add the error flags

endmodule
