#include "pwm_core.h"

void pwm_init(pwm_handle_t* self, uint32_t core_addr)
{
	//Set the initial Core address
	self->base_reg = core_addr;
	//Default resolution is 2**8
	set_res(self, 255);
	self->resolution = 255;
}

void set_dvsr(pwm_handle_t* self, uint32_t dvsr_val)
{
	//Write the dvsr value into the base address with the dvsr reg offset
	io_write(self->base_reg, DVSR_REG, dvsr_val);
}

void set_res(pwm_handle_t* self, uint32_t res_val)
{
	//Write the resolution value into the core
	io_write(self->base_reg, RES_REG, res_val);
	self->resolution = res_val;
}

void set_duty(pwm_handle_t* self, uint32_t duty_cycle, uint32_t channel)
{
	uint32_t duty_count;
	//Calculate the value tow rite in based off the duty cycle input
	duty_count = (duty_cycle*(self->resolution))/100;
	//Write the duty_cycle to the specific channel register
	io_write(self->base_reg, (DUTY_REG_BASE + channel), duty_count);
}




