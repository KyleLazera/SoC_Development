#include "fpro_init.h"
#include "gpo_core.h"
#include "gpi_core.h"
#include "seg.h"
#include "gpio_core.h"
#include "uart.h"

/******** Macros ****************/
#define SW1				0

/******** Function Declarations **********/

void gpio_blink(gpio_handle_t* gpio, Timer_Handle_t* timer);
void gpio_read_sw(gpio_handle_t* gpio, Timer_Handle_t* timer);
void set_led_gpio(gpio_handle_t* gpio, Timer_Handle_t* timer, int led_num);
void timer_reset(Timer_Handle_t* timer, gpio_handle_t* gpio);
void uart_test(uart_handle_t* uart);

int main()
{
	/*****Init Peripherals ******/
	Timer_Handle_t timer_core;
	seg_handle_t seg;
	gpio_handle_t gpio;
	uart_handle_t uart;

	//Initialize the peripherals - This sets their address
	gpio_init(&gpio, get_slot_addr(BRIDGE_BASE, S5_GPIO));
	Timer_Init(&timer_core, get_slot_addr(BRIDGE_BASE, TIMER_SLOT));
	seg_init(&seg, get_slot_addr(BRIDGE_BASE, S4_SEG));
	uart_init(&uart, get_slot_addr(BRIDGE_BASE, S1_UART));

	//Set timer mode to continous
	timer_set_mode(&timer_core, TIMER_CONT);

	//Set the period for the timer - this is tested using a logic analyzer
	//With the 100MHz clock this is a period of 5 seconds
	timer_set_period(&timer_core, 500000000);

	//Start the timer
	Timer_Go(&timer_core);

	//To show the board has been flashed successfully start by blinking all LEDs 10 times
	gpio_blink(&gpio, &timer_core);

	//Blink each LED
	set_led_gpio(&gpio, &timer_core, 16);

	while(1)
	{
		//Blink each LED to indicate the start of the loop - This is also
		//Used to prevent an overflow of the UART tx FIFO buffer due to the processor clock speed
		set_led_gpio(&gpio, &timer_core, 16);
		uart_test(&uart);
	}

	return 0;
}

/**************** Function Definitions *********************/
//Utilizes the first switch on the basys board to reset the one-shot timer
void timer_reset(Timer_Handle_t* timer, gpio_handle_t* gpio)
{
	gpio_set_mode(gpio, INPUT_MODE);
	//Check if switch is high
	if(gpio_bit_read(gpio, SW1))
	{
		//Disable the go bit
		Timer_Pause(timer);
		//Clear the timer counter
		Timer_Clear(timer);
		//Restart Counter
		timer_set_mode(timer, TIMER_ONE_SHOT);
		Timer_Go(timer);
	}
}

//Test function for the UART Module
void uart_test(uart_handle_t* uart)
{
	static int counter = 0;
	disp_str(uart, "Hello From UART #");
	disp_num(uart, counter, 10);
	disp_str(uart, "\n\r");
	counter++;
}

//Blink all 16 LED's on the Basys 3 board
void gpio_blink(gpio_handle_t* gpio, Timer_Handle_t* timer)
{
	//Turn gpio to output mode
	gpio_set_mode(gpio, OUTPUT_MODE);
	for(int i = 0; i < 5; i++)
	{
		gpio_write_word(gpio, 0xffff);
		sleep_ms(timer, 500);
		gpio_write_word(gpio, 0x0);
		sleep_ms(timer, 500);
	}
}

//Reads switch values and blinks corresponding LEDs 5 times
void gpio_read_sw(gpio_handle_t* gpio, Timer_Handle_t* timer)
{
	gpio_set_mode(gpio, INPUT_MODE);
	//Read the switches from the basys3 board
	uint32_t switch_value = gpio_word_read(gpio);
	gpio_set_mode(gpio, OUTPUT_MODE);
	for(int i = 0; i < 5; i++)
	{
		//Turn on LED correlated to switch
		gpio_write_word(gpio, switch_value);
		sleep_ms(timer, 100);
		//Turn off LED correlated to switch
		gpio_write_word(gpio, 0);
		sleep_ms(timer, 100);
	}
}

//Sets each individual LED on he basys3 baord sequentially
void set_led_gpio(gpio_handle_t* gpio, Timer_Handle_t* timer, int led_num)
{
	for(int i = 0; i < led_num; i++)
	{
		//Turns on the LED in position i
		gpio_bit_write(gpio, 1, i);
		sleep_ms(timer, 200);
		//Turn off led in position i
		gpio_bit_write(gpio, 0, i);
		sleep_ms(timer, 200);
	}
}

/******************** Deprecated Functions ********************/

//Blinks all LED's on the Basys3 board at an interval of 500ms 10 times
//Deprecated due to use of GPO Peripheral
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
//Deprecated due to use of GPO core - Rewritten using GPIO peripheral
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
//Deprecated due to use og GPO and GPI core
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
