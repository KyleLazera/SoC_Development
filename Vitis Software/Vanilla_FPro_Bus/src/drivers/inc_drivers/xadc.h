#ifndef _XADC_H
#define _XADC_H

#include "io_rw.h"
#include "io_map.h"

typedef enum{
	ADC_0_REG = 0,
	TMP_REG = 4,
	VCC_REG = 5
}XADC_REG;

typedef struct{
	uint32_t base_addr;
}xadc_handle_t;

/**
 * @brief Constructor to initialize the base address of the xadc core
 */
void xadc_init(xadc_handle_t* self, uint32_t core_base_addr);

/**
 * @brief Read raw data from the ADC reg
 * @param reg_offset - Determines which adc register to read from
 */
uint16_t read_raw(xadc_handle_t* self, int reg_offset);

/**
 * @brief Read the ADC input and convert to actual voltage using equation
 * @param reg_offset - Determines which adc register to read from
 */
double read_adc_in(xadc_handle_t* self, int reg_offset);

/**
 * @brief Read the vcc reading for the FPGA core
 */
double read_fpga_vcc(xadc_handle_t* self);

/**
 * @brief Read built in temp sensor on FPGA
 */
double read_fpga_temp(xadc_handle_t* self);

#endif	//_XADC_H
