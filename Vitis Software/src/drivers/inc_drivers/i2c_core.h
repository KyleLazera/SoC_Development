#ifndef _I2C_CORE
#define _I2C_CORE

#include "io_rw.h"
#include "io_map.h"

/* Macros */

//Macro used to ensure the SPI is in the correct bus mode
#define ASSERT_MODE(_i2c_mode, _target_mode) \
		do {\
				if((_i2c_mode) != (_target_mode)) return; \
		} while(0);

#define SLAVE_ADDR		0b01110001

//I2C Mode
#define MASTER_MODE		0x0
#define SLAVE_MODE		0x1

//Core Registers
#define DVSR_REG 	 	0x0
#define WR_REG 		 	0x1
#define RD_REG 		 	0x0

//Core Commands
#define I2C_START		(0x00 << 8)
#define I2C_WR			(0x01 << 8)
#define I2C_RD			(0x02 << 8)
#define I2C_STOP		(0x03 << 8)
#define I2C_RESTART		(0x04 << 8)


typedef struct
{
	uint32_t base_addr;
	uint32_t i2c_mode;
}i2c_handle_t;

/**** Methods *****/

/**
 * @brief Constructor to initialize i2c address & i2c freq of 100KHz
 * @param core_addr The address for the I2C Core
 * @param mode - Master os slave module
 */
void i2c_init(i2c_handle_t* self, uint32_t core_addr, uint32_t mode);

/**
 * @brief Sets the i2c clock frequency by calculating dvsr value
 * @note equation used: dvsr = sysclk/(4 * i2cclk)
 */
void i2c_set_freq(i2c_handle_t* self, int i2c_freq);

/**
 * @brief Prompts the i2c master to undergo a series of read transaction
 * @param self - Instance of the i2c
 * @param addr - device address (7 bits)
 * @param bytes - Pointer to store the data in
 * @param num - number of bytes to recieve
 * @param rstart - whether to generate a restart or stop condition (1 for rstart and 0 for stop)
 * @retval - the acknoweldge value form the first transfer
 */
int i2c_read_transaction(i2c_handle_t* self, uint8_t addr, uint8_t *bytes, int num, int rstart);

/**
 * @brief Prompts the i2c master to undergo a series of write transactions
 * @param self - Instance of the i2c
 * @param addr - device address (7 bits)
 * @param bytes - Array of data to transmit
 * @param num - number of bytes to transmit
 * @param rstart - whether to generate a restart or stop condition (1 for rstart and 0 for stop)
 * @retval - The sum of all the acks from the slave - this should equal num + 1
 */
int i2c_write_transaction(i2c_handle_t* self, uint8_t addr, uint8_t *bytes, int num, int rstart);

/**
 * @brief Reads data from the i2c slave register file
 * @param self - instance of the i2c slave
 * @param reg - The register address for the file to read from
 * @retval an 8-bit value from the register file
 */
uint8_t i2c_slave_read(i2c_handle_t* self, uint8_t reg);

/**
 * @brief Writes into the i2c slave register file
 * @param self - instance of teh register file
 * @param reg - the register to write into
 * @param data - The data to write into he register file
 */
void i2c_slave_write(i2c_handle_t* self, uint8_t reg, uint8_t data);

#endif //_I2C_CORE
