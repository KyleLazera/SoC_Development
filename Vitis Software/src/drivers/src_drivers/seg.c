#include "seg.h"
#include "fpro_init.h"

void seg_init(seg_handle_t* self, uint32_t base_core_reg)
{
	self->base_reg = base_core_reg;
	//Reset the seven segment display by setting all anodes to 1111 (in binary)
	//This is done by setting lower 4 bits of ctrl reg to 1111
	self->output_reg = (uint32_t)0x0F;
	//Initialize all values to 0
	for(int i = 0; i < 4; i++)
		self->output_value[i] = 0;

	io_write(self->base_reg, 0, self->output_reg);
}

/*
 * @brief Helper function that determines how a number will be displayed on the seg
 */
static void calculate_value(seg_handle_t* self, uint16_t value)
{
    self->output_value[0] = (uint8_t)(value % 10);        // Units
    self->output_value[1] = (uint8_t)((value / 10) % 10); // Tens
    self->output_value[2] = (uint8_t)((value / 100) % 10); // Hundreds
    self->output_value[3] = (uint8_t)((value / 1000) % 10); // Thousands
}

/*
 * @brief Helper function to convert the value into usable form for the seven segment display
 */
static void convert_to_binary(seg_handle_t* self)
{
    for (int i = 0; i < 4; i++) {
        switch (self->output_value[i]) {
            case 0: self->output_value[i] = 0b11000000; break;
            case 1: self->output_value[i] = 0b11111001; break;
            case 2: self->output_value[i] = 0b10100100; break;
            case 3: self->output_value[i] = 0b10110000; break;
            case 4: self->output_value[i] = 0b10011001; break;
            case 5: self->output_value[i] = 0b10010010; break;
            case 6: self->output_value[i] = 0b10000010; break;
            case 7: self->output_value[i] = 0b11111000; break;
            case 8: self->output_value[i] = 0b10000000; break;
            case 9: self->output_value[i] = 0b10010000; break;
        }
    }
}

/*
 * @brief Logic to display a number on a seven segment display
 */
void display_value(seg_handle_t* self, uint16_t value_to_display)
{
	uint32_t anode, value;

	//Create timer instance to allow for multiplexing of anode
	Timer_Handle_t mux_timer;

	Timer_Init(&mux_timer, get_slot_addr(BRIDGE_BASE, TIMER_SLOT));

	//Determine how the value will be broken down
	calculate_value(self, value_to_display);
	//Convert the value into a usable form for the seg
	convert_to_binary(self);

	for(int i = 0; i < 100; i++)
	{
		for(int j = 3; j >= 0; j--)
		{
			anode = anode_decode(j);
			value = self->output_value[j];
			self->output_reg = (value << 4) | anode;
			io_write(self->base_reg, 0, self->output_reg);
			sleep_us(&mux_timer, 625); //1600Hz anode changing
		}
	}
}
