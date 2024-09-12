#ifndef _IO_MAP_INCLUDED
#define _IO_MAP_INCLUDED

#define SYS_CLK_FREQ		100

//Base Address for IO ports
#define BRIDGE_BASE 0xC0000000

//Slot Definitions
typedef enum{
	S0_SYS_TIMER,			//System Timer
	S1_UART,				//UART Module
	S2_LED,					//LED Output Values (Deprecated - Use GPIO)
	S3_SW,					//Switches, Input values (Deprecated - Use GPIO)
	S4_SEG,					//7 Segment Display
	S5_GPIO,				//general purpose input output (controllers and switches)
	S6_XADC,				//XADC Module
	S7_PWM,					//Pulse width modulation module
	S8_SPI,					//SPI Master module
	S9_SPI_S,				//SPI Slave Module
	S10_I2C_M,				//I2C Master Module
	S11_I2C_S				//I2C Slave Module
}SLOT;

#endif
