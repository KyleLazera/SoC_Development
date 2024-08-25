#include "fpro_init.h"



unsigned long now_us(Timer_Handle_t* self)
{
	return ((unsigned long) Timer_Read_Time(self));
}

unsigned long now_ms(Timer_Handle_t* self)
{
	return ((unsigned long) Timer_Read_Time(self)/1000);
}

void sleep_us(Timer_Handle_t* self, unsigned long int time_us)
{
	Timer_Sleep(self, (uint64_t)time_us);
}

void sleep_ms(Timer_Handle_t* self, unsigned long int time_ms)
{
	Timer_Sleep(self, (uint64_t)(1000*time_ms));
}


