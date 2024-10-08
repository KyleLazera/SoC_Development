#include "test_functions.h"

void i2c_master_slave_test(i2c_handle_t* i2c_master, i2c_handle_t* i2c_slave, uart_handle_t* uart)
{
	uint8_t ack;
	uint8_t slave_addr = 0x08;
	uint8_t init_addr = 0x00;
	uint8_t new_data[32];
	uint8_t rd_data[16];
	//Begin by reading the values from the register file with a burst read
	i2c_read_transaction(i2c_master, slave_addr, rd_data, 16, 1);

	//Display the register file from the i2c Master (this should match initial file printed to console)
	disp_str(uart, "Register file from the i2c master: \n\r");
	for(int i = 0; i < 16; i++){
		disp_num(uart, rd_data[i], 16);
		disp_str(uart, "\n\r");
		//Increment the data by 1
		rd_data[i]++;
	}

	//Create a new array holding the data to send - this will also include the
	//address of where to write the new data in the slave reg file
	for(int i = 0, j = 0; i < 16; i++, j += 2)
	{
		//Set the reg file address every second index
		new_data[j] = i;
		//Set the data for the address
		new_data[j+1] = rd_data[i];
	}

	//Transmit the new data into the register file
	i2c_write_transaction(i2c_master, slave_addr, new_data, 32, 1);
	//Transmit 1 final byte to reset the register file address to 0 for the next read
	i2c_write_transaction(i2c_master, slave_addr, &init_addr, 1, 0);


	//Print out the new i2c values - they should all be incremented by 1
	disp_str(uart, "New Register File (incremented by 1): \n\r");
	for(int i = 0; i < 16; i++){
		disp_num(uart, i2c_slave_read(i2c_slave, i), 16);
		disp_str(uart, "\n\r");
	}

}

void spi_master_slave_test(spi_handle_t* spi_master, spi_handle_t* spi_slave, uart_handle_t* uart, uint8_t reg_addr)
{
	uint8_t read_data;
	//Prompt SPI Master to read data from a specified address from SPI Slave
	//The SPI Transfer has to occur twice, in the first transaction the master specifies the address & the
	//second transaction the slave sends the data at that address
	spi_assert_ss(spi_master, 0);
	spi_transfer_data(spi_master, reg_addr);
	read_data = spi_transfer_data(spi_master, DUMMY_DATA);
	spi_deassert_ss(spi_master, 0);
	//Display the read value (this is corroborated with the SPI Slave Reg file printed out)
	display_addr_value(uart, reg_addr, read_data);
	//Prompt The SPI Master to write a new value into this address
	//First have the SPI Master send the write command along with the address to write to
	spi_assert_ss(spi_master, 0);
	spi_transfer_data(spi_master, (128 + reg_addr));
	//The second transaction sends the value to write into the specified address
	spi_transfer_data(spi_master, (read_data + 1));
	spi_deassert_ss(spi_master, 0);
}

void adxl_i2c_read_data(i2c_handle_t* i2c_master, uart_handle_t* uart)
{
	/******* Local Variables ******/
	//Address for the adxl345
	uint8_t adxl_addr =  0x1D;
	//ADXL Initialization vars
	uint8_t adxl_set_data_format[2] = {0x31, 0x01};
	uint8_t adxl_clear_powerctl_reg[2] = {0x2D, 0x00};
	uint8_t adxl_set_powerctl_reg[2] = {0x2D, 0x08};
	uint8_t adxl_set_bw_rate_reg[2] = {0x2C, 0x0A};
	uint8_t adxl_address[1] = {0xF2};	//Address of data register to read from
	uint8_t *adxl_id_addr = 0x00;
	uint8_t device_id[1];
	uint8_t adxl_data_rec[7];			//Buffer to store the adxl data
	int16_t x, y, z;

	//Read and print the device ID
	i2c_write_transaction(i2c_master, adxl_addr, adxl_id_addr, 1, 0);
	i2c_read_transaction(i2c_master, adxl_addr, device_id, 1, 0);
	disp_str(uart, "Device ID: ");
	disp_num(uart, (int)device_id[0], 10);
	disp_str(uart, "\n\r");

	//Configure the ADXL to read accelerometer data
	i2c_write_transaction(i2c_master, adxl_addr, adxl_set_data_format, 2, 0);
	i2c_write_transaction(i2c_master, adxl_addr, adxl_clear_powerctl_reg, 2, 0);
	i2c_write_transaction(i2c_master, adxl_addr, adxl_set_powerctl_reg, 2, 0);
	i2c_write_transaction(i2c_master, adxl_addr, adxl_set_bw_rate_reg, 2, 0);
	i2c_write_transaction(i2c_master, adxl_addr, adxl_address, 1, 0);
	//Read data from the ADXl
	i2c_read_transaction(i2c_master, adxl_addr, adxl_data_rec, 7, 0);

	/*
	* Convert the data into usable/readable values - this can be found in the ADXL345 documentation,
	* and send the stored values to a queue.
	*/
	x = ((adxl_data_rec[1] << 8) | adxl_data_rec[0]);
	y = ((adxl_data_rec[3] << 8) | adxl_data_rec[2]);
	z = ((adxl_data_rec[5] << 8) | adxl_data_rec[4]);

	disp_str(uart, "Accelerometer Readings: \n\r");
	disp_str(uart, "x-axis: ");
	disp_num(uart, x, 10);
	disp_str(uart, "\n\r");
	disp_str(uart, "y-axis: ");
	disp_num(uart, y, 10);
	disp_str(uart, "\n\r");
	disp_str(uart, "z-axis: ");
	disp_num(uart, z, 10);
	disp_str(uart, "\n\r");
}


void adxl_spi_read_data(spi_handle_t* spi, uart_handle_t* uart)
{
	/******* Local Variables ******/
	//ADXL Initialization vars
	uint8_t adxl_set_data_format[2] = {0x31, 0x01};
	uint8_t adxl_clear_powerctl_reg[2] = {0x2D, 0x00};
	uint8_t adxl_set_powerctl_reg[2] = {0x2D, 0x08};
	uint8_t adxl_set_bw_rate_reg[2] = {0x2C, 0x0A};
	uint8_t adxl_address = 0xF2;	//Address of data register to read from
	uint8_t adxl_data_rec[7];			//Buffer to store the adxl data
	int16_t x, y, z;

	//Init SPI Settings - for ADXL345, the mode of operation is cpol = 1, cphase = 1
	spi_set_mode(spi, MODE_3);

	//Assert the first slave select pin
	spi_assert_ss(spi, 0);

	/***** ADXL Initialization ****/
	//Select the register to write into
	spi_transfer_data(spi, adxl_clear_powerctl_reg[0]);
	//Send the value to write in
	spi_transfer_data(spi, adxl_clear_powerctl_reg[1]);
	spi_transfer_data(spi, adxl_set_data_format[0]);
	spi_transfer_data(spi, adxl_set_data_format[1]);
	spi_transfer_data(spi, adxl_set_bw_rate_reg[0]);
	spi_transfer_data(spi, adxl_set_bw_rate_reg[1]);
	spi_transfer_data(spi, adxl_set_powerctl_reg[0]);
	spi_transfer_data(spi, adxl_set_powerctl_reg[1]);

	/***** Read Registers from ADXL ********/
	//Set the address to read from
	//adxl_data_rec[0] = spi_transfer_data(spi, adxl_address);

	for(int i = 1; i < 7; i++)
	{
		//Continue reading data & send dummy data
		adxl_data_rec[i] = spi_transfer_data(spi, (adxl_address + i));
	}

	spi_deassert_ss(spi, 0);

	/*
	* Convert the data into usable/readable values - this can be found in the ADXL345 documentation,
	* and send the stored values to a queue.
	*/
	x = ((adxl_data_rec[1] << 8) | adxl_data_rec[0]);
	y = ((adxl_data_rec[3] << 8) | adxl_data_rec[2]);
	z = ((adxl_data_rec[5] << 8) | adxl_data_rec[4]);

	disp_str(uart, "Accelerometer Readings: \n\r");
	disp_str(uart, "x-axis: ");
	disp_num(uart, x, 10);
	disp_str(uart, "\n\r");
	disp_str(uart, "y-axis: ");
	disp_num(uart, y, 10);
	disp_str(uart, "\n\r");
	disp_str(uart, "z-axis: ");
	disp_num(uart, z, 10);
	disp_str(uart, "\n\r");

}

void display_addr_value(uart_handle_t* uart, uint8_t reg_addr, uint8_t value)
{
	disp_str(uart, "The value at address ");
	disp_num(uart, reg_addr, 16);
	disp_str(uart, " is ");
	disp_num(uart, value, 10);
	disp_str(uart, "\n\r");
}

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

double get_temp(uart_handle_t* uart, xadc_handle_t* adc)
{
	double temp;

	temp = read_fpga_temp(adc);
	disp_str(uart, "FPGA Temp from XADC: ");
	disp_double(uart, temp, 3);
	disp_str(uart, "\n\r");
	return temp;
}


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
