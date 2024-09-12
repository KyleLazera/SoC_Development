#include "io_rw.h"
#include "io_map.h"
#include "timer.h"

#define TIMER_SLOT		S0_SYS_TIMER

//Timing Functions
unsigned long now_us(Timer_Handle_t* self);
unsigned long now_ms(Timer_Handle_t* self);
void sleep_us(Timer_Handle_t* self, unsigned long int time_us);
void sleep_ms(Timer_Handle_t* self, unsigned long int time_ms);
