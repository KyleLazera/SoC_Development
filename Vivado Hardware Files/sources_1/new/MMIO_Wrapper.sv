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
    output logic [3:0] an,
    output logic [7:0] seg,
    output logic timer_complete
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

//Assign 0's to all unused rd_data slots
generate
    genvar i;
    for(i = 6; i <64; i++)
        assign slot_rd_data[i] = 32'hffffffff;
    assign slot_rd_data[1] = 32'hffffffff;
    assign slot_rd_data[2] = 32'hffffffff;
    assign slot_rd_data[3] = 32'hffffffff;
endgenerate


endmodule
