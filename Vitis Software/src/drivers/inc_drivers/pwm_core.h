#ifndef _PWM_CORE_H
#define _PWM_CORE_H

#include "io_rw.h"
#include "io_map.h"

//Macros
#define CHANNEL0			0
#define CHANNEL1			1
#define CHANNEL2			2
#define CHANNEL3			3
#define CHANNEL4			4
#define CHANNEL5			5
#define CHANNEL6			6

//Register declarations
enum{
	DVSR_REG = 0x0,
	RES_REG = 0x01,
	DUTY_REG_BASE = 0x10
};

//PWM Handle Object
typedef struct{
	uint32_t base_reg;
	uint32_t resolution;
}pwm_handle_t;

/******* Methods *********/

/**
 * @brief Constructor to init the base address of the peripheral
 */
void pwm_init(pwm_handle_t* self, uint32_t core_addr);

/**
 * @brief Function used to set the divisor for the system clock
 * @note This is used to adjust the switching frequency of the PWM signal
 * @note The default dvsr is set to 0, meaning the switching frequency will be 100MHz (same as the sys clk)
 */
void set_dvsr(pwm_handle_t* self, uint32_t dvsr_val);

/**
 * @brief Function used to set the resolution of the PWM counter
 * @note default value is 255 (2^8)
 */
void set_res(pwm_handle_t* self, uint32_t res_val);

/**
 * @brief Function used to set the duty cycle of the specified output channel
 * @note the duty_cycle input is a number from 0 to 100 and represents the percentage of the duty cycle
 */
void set_duty(pwm_handle_t* self, uint32_t duty_cycle, uint32_t channel);

#endif //_PWM_CORE_H
