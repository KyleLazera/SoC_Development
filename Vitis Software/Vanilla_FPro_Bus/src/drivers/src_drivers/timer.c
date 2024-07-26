
#include "timer.h"

void Timer_Clear(Timer_Handle_t* self);

void Timer_Init(Timer_Handle_t* self, uint32_t core_base_addr)
{
	self->base_addr = core_base_addr;
	self->ctrl_reg = TIMER_GO;
	Timer_Clear(self);
	//Enable the timer
	io_write(self->base_addr, CTRL_REG, self->ctrl_reg);
}

void Timer_Pause(Timer_Handle_t* self)
{
	self->ctrl_reg &= ~TIMER_GO;
	io_write(self->base_addr, CTRL_REG, self->ctrl_reg);
}

void Timer_Go(Timer_Handle_t* self)
{
	self->ctrl_reg |= TIMER_GO;
	io_write(self->base_addr, CTRL_REG, self->ctrl_reg);
}

void Timer_Clear(Timer_Handle_t* self)
{
	uint32_t wdata = self->ctrl_reg | TIMER_CLR;
	//Write clear bit to generate a pulse
	io_write(self->base_addr, CTRL_REG, wdata);
}

uint64_t Timer_Read_Tick(Timer_Handle_t* self)
{
	uint64_t upper, lower;
	lower = (uint64_t)io_read(self->base_addr, COUNTER_LOWER_REG);
	upper = (uint64_t)io_read(self->base_addr, COUNTER_UPPER_REG);
	return ((upper << 32) | lower);
}

uint64_t Timer_Read_Time(Timer_Handle_t* self)
{
	return (Timer_Read_Tick(self)/SYS_CLK_FREQ);
}

void Timer_Sleep(Timer_Handle_t* self, uint64_t time_us)
{
	uint64_t start_time, current_time;

	//get starting time
	start_time = Timer_Read_Time(self);

	do{
		current_time = Timer_Read_Time(self);
	//Wait until the time elapsed is greater than the time passed as argument
	} while((current_time - start_time) < time_us);
}
