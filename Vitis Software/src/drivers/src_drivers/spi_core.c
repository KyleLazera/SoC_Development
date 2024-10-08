#include "spi_core.h"

/****** Helper Functions *********/

static void spi_set_ss(spi_handle_t* self, uint32_t bit_val, uint32_t bit_pos)
{
	//Ensure SPI is in Master mode
	ASSERT_MODE(self->spi_bus_mode, SPI_MASTER)

	//Set a bit in the slave select register to desired value
	bit_write(self->ss_reg, bit_pos, bit_val);
	//Write value to the register
	io_write(self->base_reg, SS_REG, self->ss_reg);
}

//This is a helper function that returns the status of the the SPI Core
//It supports both SPI Master and SPI Slave mode
static uint32_t spi_ready(spi_handle_t* self)
{
	uint32_t rd_reg;
	if(self->spi_bus_mode == SPI_MASTER)
		//Read from the rd register
		rd_reg = io_read(self->base_reg, RD_DATA_REG);
	else
		//Read from the register addr 0x0
		rd_reg = io_read(self->base_reg, 0);

	return ((rd_reg & SPI_RDY_MASK) >> 8);
}


/****** Methods ********/

void spi_init(spi_handle_t* self, uint32_t core_addr, uint8_t bus_mode)
{
	//Init the SPI Core address (either for slave or master)
	self->base_reg = core_addr;
	//Set the SPI Bus direction
	self->spi_bus_mode = bus_mode;

	if(self->spi_bus_mode == SPI_MASTER){
	//default frequency is set to 400kHz
	spi_set_freq(self, 400000);
	//Set default mode of operation to mode 0
	spi_set_mode(self, MODE_0);
	//De-active all slave selects (Positions 0 & 1)
	spi_deassert_ss(self, 0);
	spi_deassert_ss(self, 1);
	}
}

void spi_set_freq(spi_handle_t* self, uint32_t freq_val)
{
	uint16_t dvsr;

	//Ensure SPI is in Master mode
	ASSERT_MODE(self->spi_bus_mode, SPI_MASTER)

	//Calculate the dvsr value based off the equation
	dvsr = (uint16_t)(((SYS_CLK_FREQ * 1000000)/(2 * freq_val)) - 1);
	self->spi_ctrl_reg |= dvsr;
	//Write value into the control register
	io_write(self->base_reg, CTRL_REG_SPI, self->spi_ctrl_reg);
}

void spi_set_mode(spi_handle_t* self, uint32_t mode)
{
	//Ensure SPI is in Master mode
	ASSERT_MODE(self->spi_bus_mode, SPI_MASTER)

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
	//Ensure SPI is in Master mode
	ASSERT_MODE(self->spi_bus_mode, SPI_MASTER)

	//Poll the spi ready flag - if it is not set, then wait
	while(!spi_ready(self)){}
	//If the flag has been raised - the spi is ready for a transaction
	io_write(self->base_reg, WR_DATA_REG, (uint32_t)data);
	//Poll the ready flag to indicate the transaction has complete
	while(!spi_ready(self)){}
	//Once flag is raised read the response from the slave
	return ((uint8_t)(io_read(self->base_reg, RD_DATA_REG)));
}

uint8_t spi_slave_read(spi_handle_t* self, uint8_t reg_addr)
{
	uint32_t rd_data;

	//Ensure SPI is in Slave mode
	ASSERT_MODE(self->spi_bus_mode, SPI_SLAVE)
	//Read teh data from the SPI Slave
	rd_data = io_read(self->base_reg, reg_addr);
	return (uint8_t)(rd_data & RD_DATA_MASK);
}

void spi_slave_write(spi_handle_t* self, uint8_t reg_addr, uint8_t data)
{
	//Ensure SPI is in Slave mode
	ASSERT_MODE(self->spi_bus_mode, SPI_SLAVE)
	//Poll to see if the SPI Slave is currently undergoing a transaction
	while(!spi_ready(self));
	//Once the flag is raized, this indciates we can write into the register file
	io_write(self->base_reg, reg_addr, (uint32_t)data);
}

