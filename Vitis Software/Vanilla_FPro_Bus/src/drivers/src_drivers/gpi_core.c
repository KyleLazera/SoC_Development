#include "gpi_core.h"


void GPI_Init(GPI_Handle_t* self, uint32_t base_core_addr)
{
	self->base_addr = base_core_addr;
}

uint32_t GPI_Read(GPI_Handle_t* self)
{
	return io_read(self->base_addr, DATA_REG);
}

uint32_t GPI_Read_1bit(GPI_Handle_t* self, uint32_t bit_pos)
{
	uint32_t rd_data = io_read(self->base_addr, DATA_REG);
	return ((uint32_t)bit_read(rd_data, bit_pos));
}
