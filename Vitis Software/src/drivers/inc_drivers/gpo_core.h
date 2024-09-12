#include "io_rw.h"
#include "io_map.h"

#define DATA_REG		0x0

//GPO Handle
typedef struct{
	uint32_t base_addr;
	uint32_t wr_data;
}GPO_Handle_t;

/*
 * @brief Init the GPO object passed as an argument with the core addr and 0 for writing data
 */
void GPO_Init(GPO_Handle_t* self, uint32_t core_base_addr);

/*
 * @brief Function used to write 32 bits to the GPO core (turn on LEDs)
 */
void GPO_Write(GPO_Handle_t* self, uint32_t data);

/*
 * @brief Function used to write a singular bit to the GPO Core
 */
void GPO_Write_1Bit(GPO_Handle_t* self, uint32_t bit_value, uint32_t bit_pos);
