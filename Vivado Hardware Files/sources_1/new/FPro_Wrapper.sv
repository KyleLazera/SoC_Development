`timescale 1ns / 1ps

/*
* This module wraps the FPro bridge and the MMIO Wrapper to create the overall system
*/
module FPro_Wrapper
#(
    parameter BRG_BASE = 32'hC000_0000,
    parameter DATA_WIDTH = 16    
)
(
    input logic clk, reset_n,
    //Switches and LEDS
    input logic [DATA_WIDTH-1:0] sw,
    output logic [DATA_WIDTH-1:0] LED,
    //Seven Segment Display
    output logic [7:0] seg,
    output logic [3:0] an,
    //Timer
    output logic timer_complete,
    //UART Signals
    input logic rx,
    output logic tx,
    //XADC Signals
    input logic [3:0] adc_p, adc_n,
    //PWM output
    output logic [5:0] pwm_out,
    //SPI Signals
    output logic spi_mosi,
    output logic spi_clk,
    output logic [1:0] spi_cs,
    input logic spi_miso    
);

//Signal Declerations
logic clk_100M;
logic reset_sys;
//Microbalze MCS bus lines
logic io_addr_strobe;
logic io_read_strobe;
logic io_write_strobe;
logic [3:0] io_byte_enable;
logic [31:0] io_address;
logic [31:0] io_write_data;
logic [31:0] io_read_data;
logic io_ready;
//FPro Bus Lines
logic fp_mmio_cs;
logic fp_wr;
logic fp_rd;
logic [20:0] fp_addr;
logic [31:0] fp_wr_data;
logic [31:0] fp_rd_data;

assign clk_100M = clk;
assign reset_sys = !reset_n;     //Set to active low

//Instantiate MicroBlaze MCS IP Core
//Assign all wires (except clk and reset) to the signals declares for Microblaze MCS
microblaze_cpu cpu_unit(
  .Clk(clk_100M),                          // input wire Clk
  .Reset(reset_sys),                      // input wire Reset
  .IO_addr_strobe(io_addr_strobe),    // output wire IO_addr_strobe
  .IO_address(io_address),            // output wire [31 : 0] IO_address
  .IO_byte_enable(io_byte_enable),    // output wire [3 : 0] IO_byte_enable
  .IO_read_data(io_read_data),        // input wire [31 : 0] IO_read_data
  .IO_read_strobe(io_read_strobe),    // output wire IO_read_strobe
  .IO_ready(io_ready),                // input wire IO_ready
  .IO_write_data(io_write_data),      // output wire [31 : 0] IO_write_data
  .IO_write_strobe(io_write_strobe)  // output wire IO_write_strobe
);

//Instantiate the FPro System bridge
//Not using fp_video_cs for this project so leaving it empty
//This conects the microblaze to the MMIO module
FPro_Bridge #(.BRG_BASE(BRG_BASE)) bridge_unit (.*, .fp_video_cs());

MMIO_Wrapper #(.DATA_WIDTH(DATA_WIDTH)) mmio_unit(
    .clk(clk),
    .reset(reset_sys),
    .mmio_cs(fp_mmio_cs),
    .mmio_read(fp_rd), 
    .mmio_write(fp_wr),
    .mmio_addr(fp_addr),
    .mmio_wr_data(fp_wr_data),
    .mmio_rd_data(fp_rd_data),
    .sw(sw),
    .led(LED),
    .an(an),
    .seg(seg),
    .timer_complete(timer_complete),
    .tx(tx),
    .rx(rx),
    .adc_p(adc_p),
    .adc_n(adc_n),
    .pwm_out(pwm_out),
    .spi_clk(spi_clk),
    .spi_mosi(spi_mosi),
    .spi_miso(spi_miso),
    .spi_cs(spi_cs)
); 

endmodule
