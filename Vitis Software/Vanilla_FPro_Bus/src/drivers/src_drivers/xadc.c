#include "xadc.h"
#include "uart.h"

void xadc_init(xadc_handle_t* self, uint32_t core_base_addr)
{
	self->base_addr = core_base_addr;
}

/**
 * @brief Helper function that polls the rdy flag to determined whether the data being read from the
 * 			XADC is valid
 */
static uint16_t poll_rdy_flag(xadc_handle_t* self, int reg_offset)
{
	uint16_t rd_data;
	rd_data = (uint16_t)(io_read(self->base_addr, reg_offset) & 0x0001ffff);
	return (rd_data & 0x00000001);
}

uint16_t read_raw(xadc_handle_t* self, int reg_offset)
{
	uint16_t rd_data;
	//Ensure the rdy flag from the DRP interface is raised - indicating a valid read
	while(poll_rdy_flag(self, reg_offset)){}
	//When the rdy flag is raised, read the data and bit shift to the right once to remove the rdy flag
	rd_data = (uint16_t)((io_read(self->base_addr, reg_offset) & 0x0001ffff) >> 1);
	return rd_data;
}

void adc_set_mode(xadc_handle_t* self, uint32_t addr, uint32_t mode)
{
	io_write(self->base_addr, addr, mode);
	//After writing, validate the write by waiting for the drdy flag to go high
	while(poll_rdy_flag(self, 0x0)){}
}

void adc_config_channels(xadc_handle_t* self, uint32_t addr, uint32_t value)
{
	//Clear the SEQ bits before changing the channels for the XADC
	io_write(self->base_addr, 0x01, 0x0);
	//Wait for the rdy flag to be raised indicating a succesful write
	while(poll_rdy_flag(self, 0x0)){}
	//Write the value into the desired register
	io_write(self->base_addr, addr, value);
	//Wait for the rdy flag to be raised indicating a succesful write
	while(poll_rdy_flag(self, 0x0)){}
	//Set the SEQ bits back to continous
	io_write(self->base_addr, 0x01, 0x2000);
	//Wait for the rdy flag to be raised indicating a succesful write
	while(poll_rdy_flag(self, 0x0)){}
}

double read_adc_in(xadc_handle_t* self, int reg_offset)
{
	uint16_t raw;
	raw = read_raw(self, reg_offset) >> 4;
	return ((double)raw/4096.0);
}

double read_fpga_vcc(xadc_handle_t* self)
{
	return(read_adc_in(self, VCC_REG) * 3.0);
}

double read_fpga_temp(xadc_handle_t* self)
{
	return(read_adc_in(self, TEMP_REG)*503.975 - 273.15);
}
