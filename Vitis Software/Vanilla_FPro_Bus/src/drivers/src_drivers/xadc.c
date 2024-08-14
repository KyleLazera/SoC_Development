#include "xadc.h"

void xadc_init(xadc_handle_t* self, uint32_t core_base_addr)
{
	self->base_addr = core_base_addr;
}

uint16_t read_raw(xadc_handle_t* self, int reg_offset)
{
	uint16_t rd_data;
	//Read from the control/status register specified
	rd_data = (uint16_t)(io_read(self->base_addr, (ADC_0_REG + reg_offset)) & 0x0000ffff);
	return rd_data;
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
	return(read_adc_in(self, TMP_REG)*503.975 - 273.15);
}
