`timescale 1ns / 1ps

/*
* This module maps the FPro Bus to each slot interface. This MMIo controller has the capacity to hold up to 64 
* slots and serves as the system level multiplexing and decoding circuit that determines which slot is communicating 
* with the processor.
*/
module MMIO_Controller
(
    input logic clk, reset,
    //FPro Bus Interface
    input logic mmio_cs,
    input logic mmio_read,
    input logic mmio_write,
    input logic [20:0] mmio_addr,       //we will use 21 bits from the microblaze MCS (which produces 32 bits)
    input logic [31:0] mmio_wr_data,
    output logic [31:0] mmio_rd_data,
    //Signals to Interface with Slots 
    output logic [63:0] slot_cs,
    output logic [63:0] slot_mem_rd,
    output logic [63:0] slot_mem_wr,
    output logic [4:0] slot_mem_addr [63:0],
    output logic [31:0] slot_wr_data [63:0],
    input logic [31:0] slot_rd_data [63:0]   
);

//Signal Declerations
logic [5:0] slot_addr;
logic [4:0] reg_addr;

//Break down the 21 bit address from the MCU into 2 seperate sections:
//1) 5 LSB are for the register address within each custom core
//2) The following 6 bits index which slot
assign reg_addr = mmio_addr[4:0];
assign slot_addr = mmio_addr[10:5];

//Decoding logic used for writing to each slot
always_comb
begin
    //Clear the slot cs
    slot_cs = 0;
    if(mmio_cs)
        slot_cs[slot_addr] = 1;
end

//Multiplexing logic for reading 
assign mmio_rd_data = slot_rd_data[slot_addr];

//Broadcast the following signals to all of the slots:
//1) read and write signals
//2) data to write to the slot
//3) register addr 
generate
    genvar i;
    for(i = 0; i < 64; i++)
    begin: slot_signal_gen
        assign slot_mem_rd[i] = mmio_read;
        assign slot_mem_wr[i] = mmio_write;
        assign slot_wr_data[i] = mmio_wr_data;
        assign slot_mem_addr[i] = mmio_addr;
    end
endgenerate


endmodule
