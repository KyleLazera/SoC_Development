#include "fpro_init.h"
#include "gpo_core.h"
#include "gpi_core.h"
#include "seg.h"

//Blinks all LED's on the Basys3 board at an interval of 500ms 10 times
void blink_leds(Timer_Handle_t* timer, GPO_Handle_t* gpo)
{
	for(int i = 0; i < 10; i++)
	{
		//16 bits are set to high because Basys3 has 16 leds
		GPO_Write(gpo, 0xffff);
		sleep_ms(timer, 500);
		//Clear LEDs
		GPO_Write(gpo, 0x0000);
		sleep_ms(timer, 500);
	}
}

//Sets each LED on the Basys3 board
void set_led(GPO_Handle_t* gpo_core, Timer_Handle_t* timer, int led_num)
{
	for(int i = 0; i < led_num; i++)
	{
		//Turns on the LED in position i
		GPO_Write_1Bit(gpo_core, 1, i);
		sleep_ms(timer, 200);
		//Turn off led in position i
		GPO_Write_1Bit(gpo_core, 0, i);
		sleep_ms(timer, 200);
	}
}

//Reads a switch value and turns on corresponding led
void read_sw(GPO_Handle_t* gpo_core, Timer_Handle_t* timer, GPI_Handle_t* gpi_core)
{
	//Read the switches from the basys3 board
	uint32_t switch_value = GPI_Read(gpi_core);
	for(int i = 0; i < 50; i++)
	{
		//Turn on LED correlated to switch
		GPO_Write(gpo_core, switch_value);
		sleep_ms(timer, 100);
		//Turn off LED correlated to switch
		GPO_Write(gpo_core, 0);
		sleep_ms(timer, 100);
	}
}

int main()
{
	//Init GPO/GPI Core and Timer Core
	GPO_Handle_t led;
	GPI_Handle_t sw;
	Timer_Handle_t timer_core;
	seg_handle_t seg;

	//Initialize the peripherals - This sets their address
	GPO_Init(&led, get_slot_addr(BRIDGE_BASE, S2_LED));
	GPI_Init(&sw, get_slot_addr(BRIDGE_BASE, S3_SW));
	Timer_Init(&timer_core, get_slot_addr(BRIDGE_BASE, TIMER_SLOT));
	seg_init(&seg, get_slot_addr(BRIDGE_BASE, S4_SEG));

	//To show the board has been flashed successfully start by blinking all LEDs
	blink_leds(&timer_core, &led);

	//Run all 16 LED's
	set_led(&led, &timer_core, 16);

	while(1)
	{
		//Loop that counts on seven segment display
		for(int i = 0; i < 30; i++)
			display_value(&seg, i);
	}

	return 0;
}
