/* Core Includes */
#include "fpro_init.h"
#include "gpo_core.h"
#include "gpi_core.h"
#include "seg.h"
#include "gpio_core.h"
#include "uart.h"
#include "xadc.h"
#include "pwm_core.h"
#include "spi_core.h"
#include "i2c_core.h"

/* Macros */

#define SW1				0
#define DUMMY_DATA		0x00

/* Testing Functions */

/**
 * @brief This function utilizes the i2c slave and master to communicate with one another
 * @note the i2c master starts by reading all the values from the i2c slave register file
 * @note the master then increments each value and transmits it back to the i2c slave
 * @note the i2c slave then reads each value and prints to the console
 * @param i2c_master - the i2c master module
 * @param i2c_slave - The i2c slave module
 * @param uart - Used to print to the console
 */
void i2c_master_slave_test(i2c_handle_t* i2c_master, i2c_handle_t* i2c_slave, uart_handle_t* uart);

/**
 * @brief Utilizes the i2c master to communicate with the external adxl345 accelerometer
 * @note Values from the accelerometer are printed out using UART
 */
void adxl_i2c_read_data(i2c_handle_t* i2c_master, uart_handle_t* uart);

/**
 * @brief This tests the SPI slave and master interface in a singular function
 * @note To have this function operate successfully, connect the SPI Master core to the SPI slave
 * 		 core with the external pmod connectors.
 * @note This function operates as follows:
 * 		1) The SPI Master reads each address starting from 0x0 from the SPI Slave
 * 		2) The SPI Master then increments the the value at that address by 1
 * 		3) The new register file value is printed out via the UART
 * @param spi_master - the instance of the SPI Core that will act as the spi master
 * @param spi_slave - instance of spi handle that represents the slave
 * @param uart - This is the uart handle that allows the function to print out values to the console
 * @param reg_addr - This is the register address that is sent to the SPI Slave
 */
void spi_master_slave_test(spi_handle_t* spi_master, spi_handle_t* spi_slave, uart_handle_t* uart, uint8_t reg_addr);

/**
 * @brief This is a function used by the spi_master_slave_test function to print out the values
 * 			read by the SPI Master form the Slave
 * @note This prints out the values to the UART Console & is useful for debugging
 */
void display_addr_value(uart_handle_t* uart, uint8_t reg_addr, uint8_t value);

/**
 * @brief Test function for the SPI Master
 * @note This function interfaces with the ADXL345 accelerometer externally and transmits/reads
 * 		accelerometer data and prints it to the uart
 */
void adxl_spi_read_data(spi_handle_t* spi, uart_handle_t* uart);

/**
 * @brief Function used to test the XADC module by reading temperature and VCC data from
 * 			the interal sensors and printing them to the UART console
 */
double get_temp(uart_handle_t* uart, xadc_handle_t* adc);

/**
 * @brief Blinks the LEDs at a constant interval
 */
void gpio_blink(gpio_handle_t* gpio, Timer_Handle_t* timer);

/**
 * @brief Reads the switch values at a periodic interval
 */
void gpio_read_sw(gpio_handle_t* gpio, Timer_Handle_t* timer);

/**
 * @brief Blinks all LED's on the Basys3 board at an interval of 500ms 10 times
 * @note Deprecated due to use of GPO Peripheral
 */
void blink_leds(Timer_Handle_t* timer, GPO_Handle_t* gpo);

/**
 * @brief Sets each individual LED on he basys3 board sequentially
 */
void set_led_gpio(gpio_handle_t* gpio, Timer_Handle_t* timer, int led_num);

/**
 * @brief This is used to reset the one-shot timer using a GPIO switch. For this function to work, the timer must be
 * 			operating in one-shot mode
 */
void timer_reset(Timer_Handle_t* timer, gpio_handle_t* gpio);

/**
 * @brief This function tests the UART module by printing both strings and numbers to the console
 */
void uart_test(uart_handle_t* uart, gpio_handle_t* gpio, Timer_Handle_t* timer);

/**
 * @brief Outputs PWM pulses with different duty cycles on 3 different channels
 * @note This can be tested using a logic analyzer or oscilloscope
 */
void pwm_test(pwm_handle_t* pwm);

/**
 * @brief Used to set a specified LED & blink this LED at a specified interval
 * @note Deprecated due to replacing the GPO and GPI port with the GPIO core
 */
void set_led(GPO_Handle_t* gpo_core, Timer_Handle_t* timer, int led_num);

/**
 * @brief Reads the switches on the Basys3 board and activates the LED's correlated to the on switches
 * @note Deprecated function due to replacement of the GPO and GPI core with the GPIO core
 */
void read_sw(GPO_Handle_t* gpo_core, Timer_Handle_t* timer, GPI_Handle_t* gpi_core);
