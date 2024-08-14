//This header file is used to keep track of the slot addresses for each custom IO 
`ifndef _IO_SLOT_MAP_INCLUDED
`define _IO_SLOT_MAP_INCLUDED

//System clock definition
`define SYS_CLK_FREQ        100

//Microblaze MCS base address
`define BRIDGE_BASE         0xC0000000

//Slot Definitions
`define S0_SYS_TIMER        0
`define S1_UART1            1
`define S2_LED              2
`define S3_SW               3
`define S4_SEG              4
`define S5_GPIO             5
`define S6_XADC             6

`endif