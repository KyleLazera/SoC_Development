#include "i2c_core.h"


/****** Helper Functions ********/

/**
 * @brief Probes status flag of the I2C Core to check if it is ready
 * @note ready flag indicates it is either in a hold state or idle state waiting for a command
 */
static uint32_t i2c_ready(i2c_handle_t* self)
{
	return (uint32_t)((io_read(self->base_addr, RD_REG) >> 8) & 0x01);
}

/**
 * @brief Sends  a start command to the i2c master
 */
static void i2c_start(i2c_handle_t* self)
{
	//Wait for the i2c core to be ready
	while(!i2c_ready(self));
	io_write(self->base_addr, WR_REG, I2C_START);
}

/**
 * @brief Send a restart condition to the i2c master
 */
static void i2c_restart(i2c_handle_t* self)
{
	//Wait for i2c core to be ready
	while(!i2c_ready(self));
	io_write(self->base_addr, WR_REG, I2C_RESTART);
}

/**
 * @brief Send a stop request to the i2c master
 */
static void i2c_stop(i2c_handle_t* self)
{
	//Wait for ready flag
	while(!i2c_ready(self));
	io_write(self->base_addr, WR_REG, I2C_STOP);
}

/**
 * @brief Write a singular byte of data on the i2c master
 * @retval 0 indicates unsuccessful transmission and 1 indicates successful transmission
 */
static int i2c_write_byte(i2c_handle_t* self, uint8_t data)
{
	int acc_data;

	//Append the command with the data to send
	acc_data = data | I2C_WR;
	//Wait for the ready flag to be raised
	while(!i2c_ready(self));
	//Once ready, write the data into the core
	io_write(self->base_addr, WR_REG, acc_data);
	//Once again wait for a ready flag
	while(!i2c_ready(self));
	//Return the ack bit to determine if this this was successful
	return ((io_read(self->base_addr, RD_REG) >> 9) & 0x01);
}

/**
 * @brief Read a singular byte of data from the i2c Master
 */
static int i2c_read_byte(i2c_handle_t* self, uint8_t data)
{
	int acc_data;

	acc_data = data | I2C_RD;
	//Wait for the ready flag
	while(!i2c_ready(self));
	//Write data to the i2c master
	io_write(self->base_addr, WR_REG, acc_data);
	//Once again wait for rdy flag
	while(!i2c_ready(self));
	//return value read
	return (io_read(self->base_addr, RD_REG) & 0xff);
}


/****** Main methods ********/


void i2c_set_freq(i2c_handle_t* self, int i2c_freq)
{
	uint32_t dvsr;
	//Ensure the instance of I2C handle is set to master
	ASSERT_MODE(self->i2c_mode, MASTER_MODE);
	//Calculate the dvsr based off desired freq
	dvsr = (uint32_t)((SYS_CLK_FREQ*1000000)/(i2c_freq * 4));
	//Write dvsr value
	io_write(self->base_addr, DVSR_REG, dvsr);
}


void i2c_init(i2c_handle_t* self, uint32_t core_addr, uint32_t mode)
{
	self->base_addr = core_addr;
	self->i2c_mode = mode;
	if(mode == MASTER_MODE){
		//Init freq to 100KHz if mode is master
		i2c_set_freq(self, 100000);
	}
}

int i2c_read_transaction(i2c_handle_t* self, uint8_t addr, uint8_t *bytes, int num, int rstart)
{
	int ack;
	//Ensure the instance of I2C handle is set to master
	ASSERT_MODE(self->i2c_mode, MASTER_MODE);

	//Initialize start condition & wait for ready flag
	i2c_start(self);
	while(!i2c_ready(self));
	//Transmit device ID along with a read (lsb = 1)
	ack = i2c_write_byte(self, ((addr << 1) | 0x01));
	//Read bytes based on number specified
	for(int i = 0; i < (num - 1); i++)
	{
		//Transmit the read command with an ack at the end (last bit = 0)
		*bytes = i2c_read_byte(self, 0x00);
		//Increment the ptr address
		bytes++;
	}
	//Transmit final byte wiht a nack (lsb = 1)
	*bytes = i2c_read_byte(self, 0x01);

	//Check for retart or stop condition
	if(rstart)
		i2c_restart(self);
	else
		i2c_stop(self);

	//Return the ack of the initial transfer (slave address)
	return ack;
}

int i2c_write_transaction(i2c_handle_t* self, uint8_t addr, uint8_t *bytes, int num, int rstart)
{
	int ack1, ack;
	//Ensure the instance of I2C handle is set to master
	ASSERT_MODE(self->i2c_mode, MASTER_MODE);

	//Initialize start condition & wait for ready flag
	i2c_start(self);
	while(!i2c_ready(self));
	//Transmit device ID along with a write (lsb = 0)
	ack1 = i2c_write_byte(self, (addr << 1));
	//Write each byte into the i2c master
	for(int i = 0; i < num; i++)
	{
		ack = i2c_write_byte(self, *bytes);
		ack = ack + ack1;
		bytes++;
	}

	//Check for restart or stop conditions
	if(rstart)
		i2c_restart(self);
	else
		i2c_stop(self);

	//Return sum of all acks
	return ack;
}

uint8_t i2c_slave_read(i2c_handle_t* self, uint8_t reg)
{
	//Ensure the instance of I2C handle is set to slave
	ASSERT_MODE(self->i2c_mode, SLAVE_MODE);
	return (uint8_t)(io_read(self->base_addr, reg));
}

void i2c_slave_write(i2c_handle_t* self, uint8_t reg, uint8_t data)
{
	//Ensure the instance of I2C handle is set to slave
	ASSERT_MODE(self->i2c_mode, SLAVE_MODE);
	//Write into the desired register file addr
	io_write(self->base_addr, reg, (uint32_t)data);
}


