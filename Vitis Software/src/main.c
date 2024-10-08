#include "test_functions.h"

/* This software is utilizes to test the SOC in hardware. Each core was tested using a simple program,
 * and each test can be viewed in its respective branch. As new cores and tests were created, older ones
 * were removed to clean up the code and prevent it form becoming too clutered.
 */

void init_timer(Timer_Handle_t* timer_core);
void init_uart(uart_handle_t* uart);
void i2c_slave_populate_reg_file(i2c_handle_t* i2c_slave, uart_handle_t* uart);

int main()
{
	//Variables
	uint8_t reg_addr = 0;

	/*****Init Peripherals ******/
	Timer_Handle_t timer_core;
	seg_handle_t seg;
	gpio_handle_t gpio;
	uart_handle_t uart;
	xadc_handle_t adc;
	pwm_handle_t pwm;
	spi_handle_t spi_master, spi_slave;
	i2c_handle_t i2c_master, i2c_slave;

	//Initialize the peripherals - This sets their address
	gpio_init(&gpio, get_slot_addr(BRIDGE_BASE, S5_GPIO));
	Timer_Init(&timer_core, get_slot_addr(BRIDGE_BASE, TIMER_SLOT));
	seg_init(&seg, get_slot_addr(BRIDGE_BASE, S4_SEG));
	uart_init(&uart, get_slot_addr(BRIDGE_BASE, S1_UART));
	xadc_init(&adc, get_slot_addr(BRIDGE_BASE, S6_XADC));
	pwm_init(&pwm, get_slot_addr(BRIDGE_BASE, S7_PWM));
	spi_init(&spi_master, get_slot_addr(BRIDGE_BASE, S8_SPI), SPI_MASTER);
	spi_init(&spi_slave, get_slot_addr(BRIDGE_BASE, S9_SPI_S), SPI_SLAVE);
	i2c_init(&i2c_master, get_slot_addr(BRIDGE_BASE, S10_I2C_M), MASTER_MODE);
	i2c_init(&i2c_slave, get_slot_addr(BRIDGE_BASE, S11_I2C_S), SLAVE_MODE);

	init_timer(&timer_core);

	//To show the board has been flashed successfully start by blinking all LEDs 10 times
	gpio_blink(&gpio, &timer_core);

	init_uart(&uart);

	//Set the PWM output signals to measure using an oscilloscope/logic analyzer
	pwm_test(&pwm);

	//Populate the slave register file
	i2c_slave_populate_reg_file(&i2c_slave, &uart);

	while(1)
	{
		//adxl_i2c_read_data(&i2c_master, &uart);
		i2c_master_slave_test(&i2c_master, &i2c_slave, &uart);
		//Blink each LED
		set_led_gpio(&gpio, &timer_core, 16);
		//Read ADC Temp and display to UART
		get_temp(&uart, &adc);

	}

	return 0;
}

//Function to init the timer
void init_timer(Timer_Handle_t* timer_core)
{
	//Set timer mode to continuous
	timer_set_mode(timer_core, TIMER_CONT);

	//Set the period for the timer - this is tested using a logic analyzer
	//With the 100MHz clock this is a period of 5 seconds
	timer_set_period(timer_core, 500000000);

	//Start the timer
	Timer_Go(timer_core);
}

//Initialize UARt specs
void init_uart(uart_handle_t* uart)
{
	//Adjust number of data bits
	set_data_bits(uart, DATA_BITS_8);

	//Adjust number of stop bits
	set_stop_bits(uart, STOP_BITS_1);

	//Adjust parity
	set_parity(uart, PARITY_ENABLE, PARITY_EVEN);
}

void i2c_slave_populate_reg_file(i2c_handle_t* i2c_slave, uart_handle_t* uart)
{
	//Populate the i2c slave register file with a series of values
	for(int i = 0; i < 16; i++){
		i2c_slave_write(i2c_slave, i, ((i * 3) + 5));
	}

	//To ensure the values were populated, print them out to UART Console
	disp_str(uart, "Register File: \n\r");
	for(int i = 0; i < 16; i++){
		disp_num(uart, i2c_slave_read(i2c_slave, i), 16);
		disp_str(uart, "\n\r");
	}
}

