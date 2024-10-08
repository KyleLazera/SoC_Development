#ifndef _SPI_CORE_H
#define _SPI_CORE_H

#include "io_rw.h"
#include "io_map.h"

//Macro used to ensure the SPI is in the correct bus mode
#define ASSERT_MODE(_spi_mode, _target_mode) \
		do {\
				if((_spi_mode) != (_target_mode)) return; \
		} while(0);

/** SPI Macros **/
//SPI Bus Mode
#define SPI_MASTER		0
#define SPI_SLAVE		1

//SPI Mode
#define	MODE_0			0
#define MODE_1			(1UL << 17)
#define MODE_2          (1UL << 16)
#define MODE_3			(3UL << 16)

//Read register masks
#define RD_DATA_MASK	0xFF
#define SPI_RDY_MASK	0x100

typedef enum{
	RD_DATA_REG = 0,
	SS_REG = 1,
	WR_DATA_REG = 2,
	CTRL_REG_SPI = 3
}SPI_REG;

typedef struct{
	uint32_t base_reg;
	uint32_t spi_ctrl_reg;
	uint32_t ss_reg;
	uint8_t spi_bus_mode;
}spi_handle_t;

/**
 * @brief Constructor to initialize the SPI Core
 * @note SPI set to 400kHz freq by default with clock polarity = 0 & clokc phase = 0
 * @param core_addr - This is the address of the spi core itself
 * @param bus_mode - This sets the direction of teh spi bus - either as a spi master or spi slave
 */
void spi_init(spi_handle_t* self, uint32_t core_addr, uint8_t bus_mode);

/**
 * @brief Writes into the SPI control register to set the frequency to the desired value
 * @note The equation to determine the divisor (value written into the register) is:
 * 			dvsr = sys_clk/(2 * desired_freq) - 1
 * @note This function is used for SPI Master Mode
 * @param freq_val - This is the desired value to runt he SPI clock at
 */
void spi_set_freq(spi_handle_t* self, uint32_t freq_val);

/**
 * @brief Sets the mode of the SPI by writing into teh control register
 * @note This function is used for SPI Master Mode
 * @note The options are: 00 -> clock phase = 0, clock polarity = 0
 * 					      01 -> clock phase = 1, clock polarity = 0
 * 					      10 -> clock phase = 0, clock polarity = 1
 * 					      11 -> clock phase = 1, clock polarity = 1
 */
void spi_set_mode(spi_handle_t* self, uint32_t mode);

/**
 * @brief Select the slave select line to choose which slave to talk to
 * @note This function is used for SPI Master Mode
 * @param bit_pos - This allows the user to select which slave pin to access
 */
void spi_assert_ss(spi_handle_t* self, uint32_t bit_pos);

/**
 * @brief Select the slave line to de-assert
 * @note This function is used for SPI Master Mode
 * @param bit_pos - allows user to select which line to de-assert
 */
void spi_deassert_ss(spi_handle_t* self, uint32_t bit_pos);

/**
 * @brief Initiates a SPI data transfer between the master & the slave
 * @note The function writes the desired data & reads the response from the slave
 * @note This function is used for SPI Master Mode
 */
uint8_t spi_transfer_data(spi_handle_t* self, uint8_t data);

/**
 * @brief Reads the value from the slave register file (at the address specified)
 * @note This function is only intended for usage in spi slave mode
 * @param  reg_addr - The address of the register to read from
 */
uint8_t spi_slave_read(spi_handle_t* self, uint8_t reg_addr);

/**
 * @brief Writes data into the slave register file
 * @note This function is only intended for usage in spi slave mode
 * @param reg_addr - the address to write data into
 * @param data - The data to write into the register file
 */
void spi_slave_write(spi_handle_t* self, uint8_t reg_addr, uint8_t data);

#endif //_SPI_CORE_H
