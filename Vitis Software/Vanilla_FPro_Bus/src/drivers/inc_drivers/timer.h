#include "io_rw.h"
#include "io_map.h"


//Bit Masks
#define TIMER_GO			0x00000001
#define TIMER_CLR			0x00000002

//Holds the register values for the timer core
typedef enum{
	COUNTER_LOWER_REG = 0,			//Holds lower 32 bits
	COUNTER_UPPER_REG = 1,			//Upper 16 bits of counter
	CTRL_REG = 2					//Control Register
}Timer_Registers;

//Timer core handle
typedef struct{
	uint32_t base_addr;
	uint32_t ctrl_reg;
}Timer_Handle_t;

/******Functions*******/

/*
 * @brief Start the timer by writing the GO command to the control register
 */
void Timer_Init(Timer_Handle_t* self, uint32_t core_base_addr);

/*
 * @brief Pause the timer by clearing the Go bit
 */
void Timer_Pause(Timer_Handle_t* self);

/*
 * @brief Start the timer by setting the go bit
 */
void Timer_Go(Timer_Handle_t* self);
/*
 * @brief Clear the timer
 */
void Timer_Clear(Timer_Handle_t* self);

/*
 * @brief Read from the timer
 */
uint64_t Timer_Read_Tick(Timer_Handle_t* self);

/*
 * @brief Returns the timer in microseconds
 */
uint64_t Timer_Read_Time(Timer_Handle_t* self);

/*
 * @brief A function that can put the system to sleep temporarily
 */
void Timer_Sleep(Timer_Handle_t* self, uint64_t time_us);

