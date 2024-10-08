#include "io_rw.h"
#include "io_map.h"


//Bit Masks
#define TIMER_GO			(1UL << 0)
#define TIMER_PAUSE			~(1UL << 0)
#define TIMER_CLR			(1UL << 1)
#define TIMER_ONE_SHOT		(1UL << 2)
#define TIMER_CONT			(0UL << 2)


//Holds the register values for the timer core
typedef enum{
	CTRL_REG = 0,					//Control Register
	PERIOD_LOWER_REG = 1,			//Holds lower 32 bits of period
	PERIOD_UPPER_REG = 2,			//Upper 16 bits of period
	COUNTER_LOWER_REG = 3,			//Lower 32 bits of counter
	COUNTER_UPPER_REG = 4			//Upper 16 bits of counter
}Timer_Registers;

//Timer core handle
typedef struct{
	uint32_t base_addr;
	uint32_t ctrl_reg;
	uint32_t period[2];
}Timer_Handle_t;

/******Functions*******/

/*
 * @brief Start the timer by writing the GO command to the control register
 * @note Timer period is initialized to (2^48) - 1 -> this is default value
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

/*
 * @brief Sets the timer period
 * @note Default period if set to (2^48) - 1
 * @note max period width is 48 bits
 */
void timer_set_period(Timer_Handle_t* self, uint64_t period);

/*
 * @brief Sets the mode of the timer - either one shot or continous
 */
void timer_set_mode(Timer_Handle_t* self, uint32_t mode);
