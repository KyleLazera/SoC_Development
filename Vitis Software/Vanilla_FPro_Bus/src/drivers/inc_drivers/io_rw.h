#ifndef _IO_RW_INCLUDED
#define _IO_RW_INCLUDED

#include <inttypes.h>

//Macros for Type-Casting and calculating address:
//Used to read from an address
#define io_read(base_addr, offset) \
		(*(volatile uint32_t*)((base_addr) + 4*(offset)))

//Used to write to an address
#define io_write(base_addr, offset, data) \
		(*(volatile uint32_t*)((base_addr) + 4*(offset)) = (data))

//Used to get the slot address
#define get_slot_addr(mmio_base, slot)\
		((uint32_t)((mmio_base) + (slot)*32*4))

//Bit Manipulation Macros
#define bit_set(data, n)				((data) |= (1UL << n))
#define bit_clear(data, n)				((data &= ~(1UL << n)))
#define bit_toggle(data, n)				((data) ^= (1UL << n))
#define bit_read(data, n)				(((data) >> (n)) & 0x01)
#define bit_write(data, n, bitvalue)\
		(bitvalue ? bit_set(data, n) : bit_clear(data, n))
#define bit(n)							(1UL << n)

#endif
