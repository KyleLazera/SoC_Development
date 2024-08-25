#include "spi_core.h"

/****** Helper Functions *********/

static void spi_set_ss(spi_handle_t* self, uint32_t bit_val, uint32_t bit_pos)
{
	//Set a bit in the slave select register to desired value
	bit_write(self->ss_reg, bit_pos, bit_val);
	//Write value to the register
	io_write(self->base_reg, SS_REG, self->ss_reg);
}

static uint32_t spi_ready(spi_handle_t* self)
{
	uint32_t rd_reg;
	//Read from the rd register
	rd_reg = io_read(self->base_reg, RD_DATA_REG);
	return ((rd_reg & SPI_RDY_MASK) >> 8);
}

/****** Methods ********/

void spi_init(spi_handle_t* self, uint32_t core_addr)
{
	//Init the SPI Core addres
	self->base_reg = core_addr;
	//default frequency is set to 400kHz
	spi_set_freq(self, 400000);
	//Set default mode of operation to mode 0
	spi_set_mode(self, MODE_0);
	//De-active all slave selects
	spi_deassert_ss(self, 0);
	spi_deassert_ss(self, 1);
}

void spi_set_freq(spi_handle_t* self, uint32_t freq_val)
{
	uint16_t dvsr;
	//Calculate the dvsr value based off the equation
	dvsr = (uint16_t)(((SYS_CLK_FREQ * 1000000)/(2 * freq_val)) - 1);
	self->spi_ctrl_reg |= dvsr;
	//Write value into the control register
	io_write(self->base_reg, CTRL_REG_SPI, self->spi_ctrl_reg);
}

void spi_set_mode(spi_handle_t* self, uint32_t mode)
{
	self->spi_ctrl_reg = (self->spi_ctrl_reg | mode);
	//Write value into ctrl reg
	io_write(self->base_reg, CTRL_REG_SPI, self->spi_ctrl_reg);
}

void spi_assert_ss(spi_handle_t* self, uint32_t bit_pos)
{
	spi_set_ss(self, 0, bit_pos);
}

void spi_deassert_ss(spi_handle_t* self, uint32_t bit_pos)
{
	spi_set_ss(self, 1, bit_pos);
}

uint8_t spi_transfer_data(spi_handle_t* self, uint8_t data)
{
	//Poll the spi ready flag - if it is not set, then wait
	while(!spi_ready(self)){}
	//If teh flag has been raised - the spi is ready for a transaction
	io_write(self->base_reg, WR_DATA_REG, (uint32_t)data);
	//Poll the ready flag
	while(!spi_ready(self)){}
	//Once flag is raised read the response from the slave
	return ((uint8_t)(io_read(self->base_reg, RD_DATA_REG)));
}

