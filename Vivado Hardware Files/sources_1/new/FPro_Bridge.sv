`timescale 1ns / 1ps
`include "io_slot_map.svh"

/*
* This module interfaces the MMIO wrapper with the Microblaze MCS I/O bus.
*/
module FPro_Bridge
#(parameter BRG_BASE = 32'hc000_0000)
(
    //MicroBlaze MCS I/O Bridge
    input logic io_addr_strobe,
    input logic io_read_strobe, 
    input logic io_write_strobe,
    input logic [3:0] io_byte_enable,
    input logic [31:0] io_address,
    input logic [31:0] io_write_data,
    output logic [31:0] io_read_data,
    output logic io_ready,
    //FPro Bus Signals
    output logic fp_video_cs,
    output logic fp_mmio_cs,
    output logic fp_wr,
    output logic fp_rd,
    output logic [20:0] fp_addr,
    output logic [31:0] fp_wr_data,
    input logic [31:0] fp_rd_data
);

//Signal Declerations
logic mcs_bridge_enable;
logic [29:0] word_addr;     //Using 30 bit-word addressing 

/*****Address translation and decoding logic********/
//Address Space breakdown: 
// Bits 31-24: Decode FPro I/O module base address
// Bit 23: Used to select either the video subsystem or mmio subsystem
// Bits 22 to 2: Used to identify I/O reg and slot 
//Bits 1 to 0: Not used because of 30-bit word addressable scheme
assign word_addr = io_address[31:2];
assign mcs_bridge_enable = (io_address[31:24] == BRG_BASE[31:24]);
assign fp_video_cs = (mcs_bridge_enable && io_address[23] == 1);
assign fp_mmio_cs = (mcs_bridge_enable && io_address[23] == 0);
assign fp_addr = word_addr[21:0];
/***********Control line conversion************/
//Read and write will have 1 to 1 mapping but io_ready will not be used in FPro
assign fp_wr = io_write_strobe;
assign fp_rd = io_read_strobe;
assign io_ready = 1;
/***********Data Line Conversion************/
assign fp_wr_data = io_write_data;
assign io_read_data = fp_rd_data;

endmodule
