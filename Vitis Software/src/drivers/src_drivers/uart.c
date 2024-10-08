#include "uart.h"

void disp_num(uart_handle_t* self, int num, int base);

/***********************************************
 * Initialization Functions
 ***********************************************/

void set_baud_rate(uart_handle_t* self, uint32_t baud_rate)
{
	//Calculate the dvsr value to write into the registers
	uint32_t dvsr = SYS_CLK_FREQ*1000000 / 16 / baud_rate - 1;
	self->ctrl_reg_val |= dvsr;
	io_write(self->base_reg, UART_CTRL_REG, self->ctrl_reg_val);
}

void uart_init(uart_handle_t* self, uint32_t core_base_addr)
{
	//Set the base address of the peripheral
	self->base_reg = core_base_addr;
	//Initialize the control reg value to 0
	self->ctrl_reg_val = 0;
	//Set default baud rate to 9600
	set_baud_rate(self, 9600);
}

void set_data_bits(uart_handle_t* self, uint32_t data_bits)
{
	//Clear the data first
	self->ctrl_reg_val &= ~DATA_BITS_CLEAR;
	//Write bits
	self->ctrl_reg_val |= data_bits;
	//Write value into ctrl register
	io_write(self->base_reg, UART_CTRL_REG, self->ctrl_reg_val);
}

void set_stop_bits(uart_handle_t* self, uint32_t stop_bits)
{
	//Clear the bit first
	self->ctrl_reg_val &= ~STOP_BITS_CLEAR;
	//Write value in
	self->ctrl_reg_val |= stop_bits;
	//Write new value to the control register
	io_write(self->base_reg, UART_CTRL_REG, self->ctrl_reg_val);
}

void set_parity(uart_handle_t* self, uint32_t parity_en, uint32_t parity_pol)
{
	//Clear the parity bits first
	self->ctrl_reg_val &= ~(PARITY_ENABLE | PARITY_EVEN);
	//Write desired parity values in
	self->ctrl_reg_val |= (parity_en | parity_pol);
	//Write values to teh register
	io_write(self->base_reg, UART_CTRL_REG, self->ctrl_reg_val);
}

/***********************************************
 * Status Checking Functions
 ***********************************************/

int rx_fifo_empty(uart_handle_t* self)
{
	uint32_t rx_empty;
	//Read the value from the read register and use a bit mask to isolate desired bit
	rx_empty = ((io_read(self->base_reg, STATUS_REG) & RX_EMPTY_MASK) >> 3);
	return (int)rx_empty;
}

int tx_fifo_full(uart_handle_t* self)
{
	uint32_t rd_word;
	int full_flag;
	//read the value from status register and use bit mask to isolate desired bit
	rd_word = io_read(self->base_reg, STATUS_REG);
	//Bit shift the value
	full_flag = (int)(rd_word & TX_FULL_MASK) >> 9;
	return full_flag;
}

int uart_status(uart_handle_t* self)
{
	uint32_t rd_word;
	//read the value from status register
	rd_word = io_read(self->base_reg, STATUS_REG);
	return rd_word;
}

/***********************************************
 * Communication Functions
 ***********************************************/

void tx_byte(uart_handle_t* self, uint8_t tx_byte)
{
	//Wait until tx fifo is not full so we can write into it
	while(tx_fifo_full(self)){};
	//Once the fifo is not full, write the desired value in
	io_write(self->base_reg, WR_REG, (uint32_t)tx_byte);
}

int rx_byte(uart_handle_t* self)
{
	uint32_t rd_data;
	//Check if the rx fifo is empty to check if read data is valid
	if(rx_fifo_empty(self))
		return -1;
	else
	{
		//Read the value from read data reg
		rd_data = io_read(self->base_reg, RD_REG);
		return (int)(rd_data & RX_DATA_MASK);
	}
}

/**************************************************
 * Helper/Private Functions
 **************************************************/

/*
 * @brief Display a string by breaking it down & sending it as individual chars
 */
static void display_str(uart_handle_t* self, const char* str)
{
	//While there are still characters in the input string, send
	//each character and then increment the address to the next char
	while((uint8_t) *str){
		tx_byte(self, *str);
		str++;
	}
}

/*
 * @brief Convert a numerical input into a string to display
 * @param self: instance of the uart handle
 * @param num: value to print
 * @param base: base of the value (base 2 = binary, base 8 = octal etc.)
 * @param len: num of digits in string
 */
static void convert_num_to_str(uart_handle_t* self, int num, int base, int len)
{
	char buffer[33];		//Largest number of bits it can hold is 32 + null
	char* str, ch, sign;
	int remainder, num_digits;
	unsigned int value;

	//Error check for length - largest string of numbers is 32 digits
	if(len > 32)
		len = 32;

	//Check if number is negative
	if(base == 10 && num < 0)
	{
		//Assign value and sign for negative
		value = (unsigned)(-num);
		sign = '-';
	}
	else
	{
		//Assign value and sign as positive
		value = (unsigned)num;
		sign = ' ';
	}

	/***** Conversion Logic ********/
	//Start from the end of the buffer and pad the number with blanks in front of it
	str = &buffer[33];
	//Set null terminator
	*str = '\0';
	num_digits = 0;
	do{
		str--;
		//Calculate the least significant digit in the number
		remainder = value % base;
		//Divide the value by the base to move to the next significant digit (right shift of number)
		value = value / base;
		if(remainder < 10)
			ch = (char)remainder + '0';
		//Used to map for hex values above 9
		else
			ch = (char)remainder - 10 + 'a';
		*str = ch;
		num_digits++;
	} while(value);
	//Attach the sign for a negative value
	if(sign == '-')
	{
		str--;
		*str = sign;
		num_digits++;
	}

	//Pad with blanks for the remainder of the digit
	while(num_digits < len)
	{
		str--;
		*str = ' ';
		num_digits++;
	}

	display_str(self, str);
}

/*********************************************
 * Display Functions
 *********************************************/

void disp_char(uart_handle_t* self, char ch)
{
	//Transmit a singular character
	tx_byte(self, ch);
}

void disp_str(uart_handle_t* self, const char* str)
{
	display_str(self, str);
}

void disp_num(uart_handle_t* self, int num, int base)
{
	convert_num_to_str(self, num, base, 0);
}

void disp_double(uart_handle_t* self, double num, int digit)
{
	double num_a, frac;
	int n, i, i_part;

	//get absolute value of num
	num_a = num;
	if(num < 0.0){
		num_a = -num;
		disp_str(self, "-");
	}

	//Display integer portion & decimal point
	i_part = (int)num_a;
	disp_num(self, i_part, 10);
	disp_str(self, ".");

	//Display fraction portion
	frac = num_a - (double)i_part;
	for(int n = 0; n < digit; n++)
	{
		frac *= 10.0;
		i = (int)frac;
		disp_num(self, i, 10);
		frac -= i;
	}
}

