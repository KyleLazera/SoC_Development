#include "gpio_core.h"

void gpio_init(gpio_handle_t* self, uint32_t base_core_addr)
{
	//Set addr for peripheral
	self->base_reg = base_core_addr;
	//Clear data and set GPIO to default (input mode)
	self->wr_data = 0;
	self->ctrl_reg = INPUT_MODE;
	//Write to address
	io_write(self->base_reg, CTRL_REG_GPIO, self->ctrl_reg);
}

void gpio_set_mode(gpio_handle_t* self, uint32_t mode)
{
	self->ctrl_reg = mode;
	//Write mode inot the control register
	io_write(self->base_reg, CTRL_REG_GPIO, self->ctrl_reg);
}

void gpio_write_word(gpio_handle_t* self, uint32_t data)
{
	self->wr_data = data;
	//Write 32 bit data value into the output regsiter
	io_write(self->base_reg, OUTPUT_REG, self->wr_data);
}

void gpio_bit_write(gpio_handle_t* self, uint32_t bit_value, uint32_t bit_pos)
{
	//Set the bit specified by the bit position
	self->wr_data = bit_write(self->wr_data, bit_pos, bit_value);;
	//Write this value into the output register
	io_write(self->base_reg, OUTPUT_REG, self->wr_data);
}

uint32_t gpio_word_read(gpio_handle_t* self)
{
	return io_read(self->base_reg, INPUT_REG);
}

uint32_t gpio_bit_read(gpio_handle_t* self, uint32_t bit_pos)
{
	uint32_t data_reg = io_read(self->base_reg, INPUT_REG);
	return ((data_reg >> bit_pos) & 0x1);
}
