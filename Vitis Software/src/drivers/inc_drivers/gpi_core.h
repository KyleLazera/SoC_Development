#include "io_rw.h"
#include "io_map.h"

#define DATA_REG 			0x0

//Handle for the GPI Core
typedef struct{
	uint32_t base_addr;
}GPI_Handle_t;

/*
 * @brief Init the GPI object with the base address
 */
void GPI_Init(GPI_Handle_t* self, uint32_t base_core_addr);

/*
 * @brief Reads the value from the data register
 */
uint32_t GPI_Read(GPI_Handle_t* self);

/*
 * @brief Reads a singular bit determined by the bit position
 */
uint32_t GPI_Read_1bit(GPI_Handle_t* self, uint32_t bit_pos);
