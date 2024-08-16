#ifndef _XADC_H
#define _XADC_H

#include "io_rw.h"
#include "io_map.h"

/*************** Macros ***********/
#define ADC_0_REG				0b10110
#define ADC_1_REG				0b11110
#define ADC_2_REG				0b10111
#define ADC_3_REG				0b11111
#define TEMP_REG				0b00000
#define VCC_REG					0b00001
#define FLAG_REG				0b00010

//Address of register to configure the channels
#define ON_CHIP_CHANNEL_SEL		0x8
#define	AUX_CHANNEL_SEL			0x9
//Address of registers to configure unipolar/bipolar - Note: only the auxiliary
//channels can be configured. All on-chip channels are set to unipolar
#define AUX_MODE_SEL			0xD

//Channel selection bits
#define ON_CHIP_TEMP		(1UL << 8)
#define ON_CHIP_VCC			(1UL << 9)
#define AUX_CHANNEL_0		(1UL << 0)
#define AUX_CHANNEL_1		(1UL << 1)
#define AUX_CHANNEL_2		(1UL << 2)
#define AUX_CHANNEL_3		(1UL << 3)
#define AUX_CHANNEL_4		(1UL << 4)
#define AUX_CHANNEL_5		(1UL << 5)
#define AUX_CHANNEL_6		(1UL << 6)
#define AUX_CHANNEL_7		(1UL << 7)
#define AUX_CHANNEL_8		(1UL << 8)
#define AUX_CHANNEL_9		(1UL << 9)
#define AUX_CHANNEL_10		(1UL << 10)
#define AUX_CHANNEL_11		(1UL << 11)
#define AUX_CHANNEL_12		(1UL << 12)
#define AUX_CHANNEL_13		(1UL << 13)
#define AUX_CHANNEL_14		(1UL << 14)
#define AUX_CHANNEL_15		(1UL << 15)

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
 * @brief Function used to set the channels used in the continous sequencer mode
 * @param addr - the address to write to for the XADC
 * @param value - the value to write into the XADC
 */
void adc_config_channels(xadc_handle_t* self, uint32_t addr, uint32_t value);

/**
 * @brief Used to set the mode (unipolar or bipolar)
 */
void adc_set_mode(xadc_handle_t* self, uint32_t addr, uint32_t mode);

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
