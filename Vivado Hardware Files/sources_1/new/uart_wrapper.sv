`timescale 1ns / 1ps

/*
* This module combines the UART rx and tx module, baud rate generator and FIFO's
*/
module uart_wrapper
#(
    parameter DATA_BITS = 8,                            //Max number of data bits
              FIFO_WIDTH,                               //Address width of the FIFO 
              OVRSAMPLING = 16,                         //Oversampling rate
              DVSR_WIDTH = 11 
)
(
    input logic clk, reset,
    input logic rd_uart, wr_uart,                       //Signals indicating direction of transmission
    input logic rx,                                     //Bit of data being received by UART
    input logic data_bit,                               //Input bit indicating num of data bits to send/receive
    input logic [1:0] sb_ticks,
    input logic parity_en, parity_pol,                  //Input signals for parity
    input logic [DATA_BITS-1:0] wr_data,                //Full data to transmit from UART
    input logic [DVSR_WIDTH-1:0] dvsr,                  //Divisor used for baud rate
    output logic tx_full, rx_empty,                     //Flags indicating FIFO Status
    output logic parity_err,
    output logic tx,                                    //Bit of data being transmitted form UART
    output logic [DATA_BITS-1:0] rd_data                //Total data being read/received into UART
);

/************** Signal Declarations ******************/
logic tick, rx_done_tick, tx_done_tick;
logic tx_empty, tx_fifo_not_empty;
logic [DATA_BITS-1:0] tx_fifo_out, rx_data_out;
//User defined signals (can be dynamically changed)
logic [3:0] data_bits_decoded;
logic [5:0] stop_ticks;

/************ Module Instantiations **************/
//Baud Rate generator
baud_gen #(.DVSR_WIDTH(DVSR_WIDTH)) baud_gen_unit (.*, .tick(tick), .dvsr(dvsr));

//UART Transmitter Module
uart_tx #(.DATA_BITS(DATA_BITS), .OVRSAMPLING(OVRSAMPLING)) uart_tx_unit
        (.*, .s_tick(tick), .tx_start(tx_fifo_not_empty), .din(tx_fifo_out), .tx_done(tx_done_tick), .tx(tx), .d_bits(data_bits_decoded), 
        .stop_ticks(stop_ticks), .parity_en(parity_en), .parity_pol(parity_pol));

//tx FIFO
fifo #(.DATA_WIDTH(DATA_BITS), .ADDR_WIDTH(FIFO_WIDTH)) tx_fifo_unit
      (.*, .rd(tx_done_tick), .wr(wr_uart), .wr_data(wr_data), .full(tx_full), .empty(tx_empty), .rd_data(tx_fifo_out));   
        
//UART Receiver Module
uart_rx #(.DATA_BITS(DATA_BITS), .OVRSAMPLING(OVRSAMPLING))  uart_rx_unit
         (.*, .s_tick(tick), .rx(rx), .rx_done(rx_done_tick), .dout(rx_data_out), .d_bits(data_bits_decoded), .stop_ticks(stop_ticks),
          .parity_en(parity_en), .parity_pol(parity_pol), .parity_err(parity_err));   

//rx FIFO
fifo #(.DATA_WIDTH(DATA_BITS), .ADDR_WIDTH(FIFO_WIDTH)) rx_fifo_unit
       (.*, .rd(rd_uart), .wr(rx_done_tick), .wr_data(rx_data_out), .full(), .empty(rx_empty), .rd_data(rd_data));

/******************** Decoding and assingment Logic ******************/

assign tx_fifo_not_empty = ~tx_empty;

//Decoding logic for data bits 
always_comb
begin
    case(data_bit)
        1'b0: data_bits_decoded = 4'b1000;          //bit value 0 -> 8 data bits
        1'b1 : data_bits_decoded = 4'b0111;         //bit value 1 -> 7 data bits
        default: data_bits_decoded = 4'b1000;       //Default value is 8 bits
    endcase
end

//Decoding logic for num of stop bits (convert into number of stop ticks)
always_comb
begin
    case(sb_ticks)
        2'b00 : stop_ticks = 6'b10000;         //1 stop bit
        2'b01 : stop_ticks = 6'b11000;         //1.5 stop bits
        2'b10 : stop_ticks = 6'b100000;        //2 stop bits
        default : stop_ticks = 6'b10000;
    endcase
end

endmodule
