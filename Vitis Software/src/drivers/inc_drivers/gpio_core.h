#include "io_rw.h"
#include "io_map.h"

//Macros for the mode of the GPIO
#define INPUT_MODE				0
#define OUTPUT_MODE				1

//Register declarations
typedef enum{
	INPUT_REG = 1,
	OUTPUT_REG = 2,
	CTRL_REG_GPIO = 3
}GPIO_Reg;

//Handle for GPIO
typedef struct{
	uint32_t base_reg;
	uint32_t wr_data;
	uint32_t ctrl_reg;
}gpio_handle_t;

/****** GPIO Functions *******/

/*
 * @brief Function used to init the GPIO peripheral
 */
void gpio_init(gpio_handle_t* self, uint32_t base_core_addr);

/*
 * @brief Function used to set the mode (input/output)
 */
void gpio_set_mode(gpio_handle_t* self, uint32_t mode);

/*
 * @brief Writes 32 bits to the GPIO port
 */
void gpio_write_word(gpio_handle_t* self, uint32_t data);

/*
 * @brief Write a singular bit to the GPIO port
 */
void gpio_bit_write(gpio_handle_t* self, uint32_t bit_value, uint32_t bit_pos);

/*
 * @brief Read 32 bits from the Input buffer
 */
uint32_t gpio_word_read(gpio_handle_t* self);

/*
 * @brief Read a singular bit from the input buffer
 */
uint32_t gpio_bit_read(gpio_handle_t* self, uint32_t bit_pos);
