#include "fpro_init.h"
#include "gpo_core.h"
#include "gpi_core.h"
#include "seg.h"
#include "gpio_core.h"
#include "uart.h"
#include "xadc.h"
#include "pwm_core.h"

/******** Macros ****************/
#define SW1				0

/******** Function Declarations **********/

void gpio_blink(gpio_handle_t* gpio, Timer_Handle_t* timer);
void gpio_read_sw(gpio_handle_t* gpio, Timer_Handle_t* timer);
void set_led_gpio(gpio_handle_t* gpio, Timer_Handle_t* timer, int led_num);
void timer_reset(Timer_Handle_t* timer, gpio_handle_t* gpio);
void uart_test(uart_handle_t* uart, gpio_handle_t* gpio, Timer_Handle_t* timer);
void get_temp(uart_handle_t* uart, xadc_handle_t* adc);
void pwm_test(pwm_handle_t* pwm);

int main()
{
	/*****Init Peripherals ******/
	Timer_Handle_t timer_core;
	seg_handle_t seg;
	gpio_handle_t gpio;
	uart_handle_t uart;
	xadc_handle_t adc;
	pwm_handle_t pwm;

	//Initialize the peripherals - This sets their address
	gpio_init(&gpio, get_slot_addr(BRIDGE_BASE, S5_GPIO));
	Timer_Init(&timer_core, get_slot_addr(BRIDGE_BASE, TIMER_SLOT));
	seg_init(&seg, get_slot_addr(BRIDGE_BASE, S4_SEG));
	uart_init(&uart, get_slot_addr(BRIDGE_BASE, S1_UART));
	xadc_init(&adc, get_slot_addr(BRIDGE_BASE, S6_XADC));
	pwm_init(&pwm, get_slot_addr(BRIDGE_BASE, S7_PWM));

	//Set timer mode to continous
	timer_set_mode(&timer_core, TIMER_CONT);

	//Set the period for the timer - this is tested using a logic analyzer
	//With the 100MHz clock this is a period of 5 seconds
	timer_set_period(&timer_core, 500000000);

	//Start the timer
	Timer_Go(&timer_core);

	//To show the board has been flashed successfully start by blinking all LEDs 10 times
	gpio_blink(&gpio, &timer_core);

	//Adjust num of data bits
	set_data_bits(&uart, DATA_BITS_8);

	//Adjust num of stop bits
	set_stop_bits(&uart, STOP_BITS_1);

	//Adjust parity
	set_parity(&uart, PARITY_ENABLE, PARITY_EVEN);

	//Set the PWM output signals to measure using an oscilliscope/logic analyzer
	pwm_test(&pwm);

	while(1)
	{
		for(int i = 0; i < 10; i++)
		{
			//Blink each LED
			set_led_gpio(&gpio, &timer_core, 16);
			get_temp(&uart, &adc);
		}
	}

	return 0;
}

/**************** Function Definitions *********************/
//Outputs PWM pulses with different duty cycles on 3 different channels
//This was checked using a logic analyzer
void pwm_test(pwm_handle_t* pwm)
{
	//Setting dvsr to 20 - this means that the pwm signal will have a clk period of 200ns or 5MHz
	set_dvsr(pwm, 20);
	//The resolution is unchanged, meaning it is at 255
	//Activate 3 channels, each with varying duty cycles and measure using an oscilliscope/logic analyzer
	set_duty(pwm, 50, CHANNEL0);
	set_duty(pwm, 25, CHANNEL1);
	set_duty(pwm, 75, CHANNEL2);
}

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

//Function used to test the XADC - this prints out the temperature which is passed through the ADC,
//& aso prints out the voltage of the core
void get_temp(uart_handle_t* uart, xadc_handle_t* adc)
{
	double temp, vcc;

	temp = read_fpga_temp(adc);
	disp_str(uart, "FPGA Temp from XADC: ");
	//disp_num(uart, (int)temp, 10);
	disp_double(uart, temp, 3);
	disp_str(uart, "\n\r");
	vcc = read_fpga_vcc(adc);
	disp_str(uart, "FPGA VCC from XADC: ");
	//disp_num(uart, (int)vcc, 10);
	disp_double(uart, vcc, 3);
	disp_str(uart, "\n\r");
}

//Test function for the UART Module and the ADC Module
void uart_test(uart_handle_t* uart, gpio_handle_t* gpio, Timer_Handle_t* timer)
{
	static int counter = 0;
	int num;
	disp_str(uart, "Hello From UART #");
	disp_num(uart, counter, 10);
	disp_str(uart, "\n\r");
	disp_str(uart, "Write a number: ");
	//Take in a user input
	num = rx_byte(uart);
	//print the number the user printed
	disp_num(uart, num, 10);
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
