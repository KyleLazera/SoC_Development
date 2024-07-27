#ifndef _IO_MAP_INCLUDED
#define _IO_MAP_INCLUDED

#define SYS_CLK_FREQ		100

//Base Address for IO ports
#define BRIDGE_BASE 0xC0000000

//Slot Definitions
typedef enum{
	S0_SYS_TIMER,
	S1_UART,
	S2_LED,
	S3_SW,
	S4_SEG,
	S5_GPIO
}SLOT;

#endif
