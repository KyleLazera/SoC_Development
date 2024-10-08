
#include "gpo_core.h"

void GPO_Init(GPO_Handle_t* self, uint32_t core_base_addr)
{
	self->base_addr = core_base_addr;
	self->wr_data = 0;
}

void GPO_Write(GPO_Handle_t* self, uint32_t data)
{
	self->wr_data = data;
	io_write(self->base_addr, DATA_REG, self->wr_data);
}

void GPO_Write_1Bit(GPO_Handle_t* self, uint32_t bit_value, uint32_t bit_pos)
{
	bit_write(self->wr_data, bit_pos, bit_value);
	io_write(self->base_addr, DATA_REG, self->wr_data);
}
