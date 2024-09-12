`timescale 1ns / 1ps
`include "io_slot_map.svh"

/*
* This module wraps the MMIO controller and slot interfaces. To add more slots to teh system, 
* add them to this wrapper.
*/
module MMIO_Wrapper
#(parameter DATA_WIDTH = 16)
(
    input logic clk, reset,
    //FPro Bus Interface
    input logic mmio_cs,
    input logic mmio_read,
    input logic mmio_write,
    input logic [20:0] mmio_addr,       //we will use 21 bits from the microblaze MCS (which produces 32 bits)
    input logic [31:0] mmio_wr_data,
    output logic [31:0] mmio_rd_data,
    //Input and output switchs/LEDs used for GPI and GPO slot
    input logic [DATA_WIDTH-1:0] sw,   
    output logic [DATA_WIDTH-1:0] led,
    //Seven Segment Display Signals
    output logic [3:0] an,
    output logic [7:0] seg,
    //UART Signals
    input logic rx,
    output logic tx,
    //Timer signals 
    output logic timer_complete,
    //XADC Signals
    input logic [3:0] adc_p, adc_n,
    //PWM Output Signals
    output logic [5:0] pwm_out,
    //SPI Master Signals
    output logic spi_mosi,
    output logic spi_clk,
    output logic [1:0] spi_cs,
    input logic spi_miso,
    //SPI Slave Signals
    input logic spi_clk_s,
    input logic spi_mosi_s,
    input logic spi_cs_s_n,
    output logic spi_miso_s,
    //I2C Master Signals
    output tri scl_m,
    inout tri sda_m,
    //I2C slave Signals
    input logic scl_s,
    inout tri sda_s      
);

//Signal Declerations - These are used mainly for the initialization of the MMIO controller
logic [63:0] slot_cs;
logic [63:0] slot_mem_rd;
logic [63:0] slot_mem_wr;
logic [4:0] slot_mem_addr [63:0];
logic [31:0] slot_wr_data [63:0];
logic [31:0] slot_rd_data [63:0];  

/******Module Instantiations**********/
//MMIO controller init:
MMIO_Controller ctrl_unit
(.clk(clk), .reset(reset),
 .mmio_cs(mmio_cs),
 .mmio_read(mmio_read),
 .mmio_write(mmio_write),
 .mmio_addr(mmio_addr),
 .mmio_wr_data(mmio_wr_data),
 .mmio_rd_data(mmio_rd_data),
 //Interface the MMIO Controller with the slots
 .slot_cs(slot_cs),
 .slot_mem_rd(slot_mem_rd),
 .slot_mem_wr(slot_mem_wr),
 .slot_mem_addr(slot_mem_addr),
 .slot_wr_data(slot_wr_data),
 .slot_rd_data(slot_rd_data)
);

//Slot 0: System Timer
Timer_Core timer_slot_0
(.clk(clk), .reset(reset),
 .cs(slot_cs[`S0_SYS_TIMER]),
 .read(slot_mem_rd[`S0_SYS_TIMER]),
 .write(slot_mem_wr[`S0_SYS_TIMER]),
 .reg_addr(slot_mem_addr[`S0_SYS_TIMER]),
 .wr_data(slot_wr_data[`S0_SYS_TIMER]),
 .rd_data(slot_rd_data[`S0_SYS_TIMER]),
 .counter_done(timer_complete)
);

//Slot 1: UART Controller
uart_core uart_slot_1
(.clk(clk), .reset(reset),
 .cs(slot_cs[`S1_UART1]),
 .read(slot_mem_rd[`S1_UART1]),
 .write(slot_mem_wr[`S1_UART1]),
 .reg_addr(slot_mem_addr[`S1_UART1]),
 .wr_data(slot_wr_data[`S1_UART1]),
 .rd_data(slot_rd_data[`S1_UART1]),
 .tx(tx), .rx(rx)
);

/*Slot 2: GPO
GPO_Core #(.DATA_WIDTH(DATA_WIDTH)) gpo_slot_2 
(.clk(clk), .reset(reset),
 .cs(slot_cs[`S2_LED]),
 .read(slot_mem_rd[`S2_LED]),
 .write(slot_mem_wr[`S2_LED]),
 .reg_addr(slot_mem_addr[`S2_LED]),
 .wr_data(slot_wr_data[`S2_LED]),
 .rd_data(slot_rd_data[`S2_LED]),
 .data_out(led)
);*.

/*Slot 3: GPI
GPI_Core#(.DATA_WIDTH(DATA_WIDTH)) gpi_slot_3
(.clk(clk), .reset(reset),
 .cs(slot_cs[`S3_SW]),
 .read(slot_mem_rd[`S3_SW]),
 .write(slot_mem_wr[`S3_SW]),
 .reg_addr(slot_mem_addr[`S3_SW]),
 .wr_data(slot_wr_data[`S3_SW]),
 .rd_data(slot_rd_data[`S3_SW]),
 .data_in(sw)
);*/

//Slot 4: Seven Segment Display Interface
sseg_controller #(.DATA_WIDTH(12)) seg_gpo_slot_4
(.clk(clk), .reset(reset),
 .cs(slot_cs[`S4_SEG]),
 .read(slot_mem_rd[`S4_SEG]),
 .write(slot_mem_wr[`S4_SEG]),
 .reg_addr(slot_mem_addr[`S4_SEG]),
 .wr_data(slot_wr_data[`S4_SEG]),
 .rd_data(slot_rd_data[`S4_SEG]),
 .sseg(seg), .an(an)
);

//Slot 5: GPIO peripheral - Replaces GPI and GPO slots
gpio_core #(.DATA_WIDTH(DATA_WIDTH)) gpio_slot_5
(.clk(clk), .reset(reset),
 .cs(slot_cs[`S5_GPIO]),
 .read(slot_mem_rd[`S5_GPIO]),
 .write(slot_mem_wr[`S5_GPIO]),
 .reg_addr(slot_mem_addr[`S5_GPIO]),
 .wr_data(slot_wr_data[`S5_GPIO]),
 .rd_data(slot_rd_data[`S5_GPIO]),
 .data_out(led),
 .data_in(sw)
);

//Slot 6: XADC Core
xadc_core xadc_slot_6
(
 .clk(clk), .reset(reset),
 .cs(slot_cs[`S6_XADC]),
 .read(slot_mem_rd[`S6_XADC]),
 .write(slot_mem_wr[`S6_XADC]),
 .reg_addr(slot_mem_addr[`S6_XADC]),
 .wr_data(slot_wr_data[`S6_XADC]),
 .rd_data(slot_rd_data[`S6_XADC]),
 .adc_p(adc_p),
 .adc_n(adc_n)
);

//Slot 7: Multi-channel PWM Core
pwm_core #(.OUT_PORTS(6)) pwm_slot_7
(
 .clk(clk), .reset(reset),
 .cs(slot_cs[`S7_PWM]),
 .read(slot_mem_rd[`S7_PWM]),
 .write(slot_mem_wr[`S7_PWM]),
 .reg_addr(slot_mem_addr[`S7_PWM]),
 .wr_data(slot_wr_data[`S7_PWM]),
 .rd_data(slot_rd_data[`S7_PWM]),
 .pwm_out(pwm_out)
);

//Slot 8: SPI Module
SPI_Wrapper#(.S(2)) spi_slot_8
(
 .clk(clk), .reset(reset),
 .cs(slot_cs[`S8_SPI]),
 .read(slot_mem_rd[`S8_SPI]),
 .write(slot_mem_wr[`S8_SPI]),
 .reg_addr(slot_mem_addr[`S8_SPI]),
 .wr_data(slot_wr_data[`S8_SPI]),
 .rd_data(slot_rd_data[`S8_SPI]),
 //SPI Signals
 .spi_clk(spi_clk),
 .spi_mosi(spi_mosi),
 .spi_miso(spi_miso),
 .spi_ss_n(spi_cs)
);

spi_slave_reg_file #() spi_slave_core_9
(
 .clk(clk), .reset(reset),
 .cs(slot_cs[`S9_SPI_S]),
 .read(slot_mem_rd[`S9_SPI_S]),
 .write(slot_mem_wr[`S9_SPI_S]),
 .reg_addr(slot_mem_addr[`S9_SPI_S]),
 .wr_data(slot_wr_data[`S9_SPI_S]),
 .rd_data(slot_rd_data[`S9_SPI_S]),
 //SPI Signals
 .spi_clk(spi_clk_s),
 .spi_mosi(spi_mosi_s),
 .spi_miso(spi_miso_s),
 .spi_cs_n(spi_cs_s_n)
);

i2c_master_core i2c_master_10
(
 .clk(clk), .reset(reset),
 .cs(slot_cs[`S10_I2C_M]),
 .read(slot_mem_rd[`S10_I2C_M]),
 .write(slot_mem_wr[`S10_I2C_M]),
 .reg_addr(slot_mem_addr[`S10_I2C_M]),
 .wr_data(slot_wr_data[`S10_I2C_M]),
 .rd_data(slot_rd_data[`S10_I2C_M]),
 //I2C Signals
 .scl(scl_m), .sda(sda_m)    
);

i2c_slave_wrapper i2c_slave_11
(
 .clk(clk), .reset(reset),
 .cs(slot_cs[`S11_I2C_S]),
 .read(slot_mem_rd[`S11_I2C_S]),
 .write(slot_mem_wr[`S11_I2C_S]),
 .reg_addr(slot_mem_addr[`S11_I2C_S]),
 .wr_data(slot_wr_data[`S11_I2C_S]),
 .rd_data(slot_rd_data[`S11_I2C_S]),
 //I2C Signals
 .i_scl(scl_s), .sda(sda_s)    
);

//Assign 0's to all unused rd_data slots
generate
    genvar i;
    for(i = 12; i <64; i++)
        assign slot_rd_data[i] = 32'hffffffff;
    assign slot_rd_data[2] = 32'hffffffff;
    assign slot_rd_data[3] = 32'hffffffff;
endgenerate


endmodule
