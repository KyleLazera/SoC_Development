#ifndef _UART_H_INCLUDED
#define _UART_H_INCLUDED

#include "io_rw.h"
#include "io_map.h"

/********* UART Macros ***********/
#define DUMMY_DATA					0x0
#define RX_DATA_MASK				0x000000ff
#define RX_EMPTY_MASK				0x00000100
#define TX_FULL_MASK				0x00000200

//UART Register mapping
typedef enum{
	READ_DATA_REG = 0,
	DVSR_REG = 1,
	WR_DATA_REG = 2,
	RM_RD_DATA_REG = 3
}UART_REG;

//UART Handle
typedef struct{
	uint32_t base_reg;
	uint32_t baud_rate;
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

/*
 * @brief Determines if the rx fifo is empty
 * @retval Returns 1 if empty and  if not empty
 */
int rx_fifo_empty(uart_handle_t* self);

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



#endif
