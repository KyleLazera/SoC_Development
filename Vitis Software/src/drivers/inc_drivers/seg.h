#include "io_map.h"
#include "io_rw.h"

#define anode_decode(an_pos)\
		(~(1UL << an_pos) & 0xF)

//Seven Segment Controller Object
typedef struct
{
	uint32_t base_reg;						//Holds the base adress for Fpro bus
	uint32_t output_reg;					//Holds value for output register (output value and anode)
	uint8_t output_value[4];				//Array to hold the output values for each seg
}seg_handle_t;

/*
 * @brief Initialize the seg controller with base register
 */
void seg_init(seg_handle_t* self, uint32_t base_core_reg);

/*
 * @brief Displays a value on the seven segment display based off input value
 */
void display_value(seg_handle_t* self, uint16_t value_to_display);
