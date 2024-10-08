#ifndef _UART_H_INCLUDED
#define _UART_H_INCLUDED

#include "io_rw.h"
#include "io_map.h"

/********* UART Macros ***********/
#define DUMMY_DATA					0x0

//Status Register
#define PARITY_ERR_MASK				(1UL << 0)
#define FRAME_ERR_MASK				(1UL << 1)
#define OVERRUN_ERR_MASK			(1UL << 2)
#define RX_EMPTY_MASK				(1UL << 3)
#define TX_FULL_MASK				(1UL << 4)

/***Control Register Macros ***/
//Parity En/Disable
#define PARITY_DISABLE				(0UL << 11)
#define PARITY_ENABLE				(1UL << 11)
//Parity even/odd
#define PARITY_ODD					(0UL << 12)
#define PARITY_EVEN					(1UL << 12)
//Stop Bits
#define STOP_BITS_CLEAR				(3UL << 13)
#define STOP_BITS_1					(0UL << 13)
#define STOP_BITS_1_5				(1UL << 13)
#define STOP_BITS_2					(2UL << 13)
//Data Bits
#define DATA_BITS_CLEAR				(1UL << 15)
#define DATA_BITS_7					(1UL << 15)
#define DATA_BITS_8					(0UL << 15)

//Read Register
#define RX_DATA_MASK				0x000000ff

//UART Register mapping
typedef enum{
	UART_CTRL_REG = 0,
	STATUS_REG = 1,
	RD_REG = 2,
	WR_REG = 3
}UART_REG;

//UART Handle
typedef struct{
	uint32_t base_reg;
	uint32_t baud_rate;
	uint32_t ctrl_reg_val;
}uart_handle_t;

/*********** Function Declarations **********/

/*
 * @brief Initializer function that sets the base reg of the periph & the baud rate to 9600
 * @note If a different baud rate is desired, use the set_baud_rate() function
 */
void uart_init(uart_handle_t* self, uint32_t core_base_addr);

/*
 * @brief Calculates the dvsr value to input into the register UART register
 */
void set_baud_rate(uart_handle_t* self, uint32_t baud_rate);

/**
 * @brief Sets the number of data bits to recieve
 */
void set_data_bits(uart_handle_t* self, uint32_t data_bits);

/**
 * @brief Set Number of stop bits
 */
void set_stop_bits(uart_handle_t* self, uint32_t stop_bits);

/**
 * @brief Set the parity en/disable and even/odd
 */
void set_parity(uart_handle_t* self, uint32_t parity_en, uint32_t parity_pol);

/*
 * @brief Determines status of rx fifo
 * @retval Returns 1 if empty and  if not empty
 */
int rx_fifo_empty(uart_handle_t* self);

/**
 * @brief Reads the status register and returns the value
 * @note use flags to isolate and check for specific flags
 * @retval Returns the value held in status register
 */
int uart_status(uart_handle_t* self);

/*
 * @brief Determines if tx fifo is full
 * @retval returns 1 is fifo is full and 0 if not
 */
int tx_fifo_full(uart_handle_t* self);

/*
 * @brief Transmit byte of data
 */
void tx_byte(uart_handle_t* self, uint8_t tx_byte);

/*
 * @brief Read data
 */
int rx_byte(uart_handle_t* self);

/*
 * @brief display/print a character or send a char via UART
 */
void disp_char(uart_handle_t* self, char ch);

/*
 * @brief Display/print or send a string via UART
 */
void disp_str(uart_handle_t* self, const char* str);

/*
 * @brief Display/print of transmit a number in the format of a string
 */
void disp_num(uart_handle_t* self, int num, int base);

/*
 * @brief Display decimal values
 * @param num - the number to display
 * @param digit - the number of digits to display
 */
void disp_double(uart_handle_t* self, double num, int digit);


#endif
