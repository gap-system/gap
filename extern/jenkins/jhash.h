/******************************************************************************
 *
 *    jhash.h     The Bob Jenkins Hash Function
 *
 *    File      : $RCSfile$
 *    Author    : Henrik Bäärnhielm 
 *    Dev start : 2006-07-16 
 *
 *    Version   : $Revision$
 *    Date      : $Date$
 *    Last edit : $Author$
 *
 *    @(#)$Id$
 *
 *    Definitions for Jenkins Hash
 *
 *****************************************************************************/

#ifndef JHASH_H
#define JHASH_H

#include<sys/types.h>

// Are these bit-numbers really safe?
// unsingned long is probably not guaranteed to be 32-bit
//typedef unsigned long uint32_t;
//typedef unsigned long long uint8_t;
//typedef unsigned short uint16_t;


#if !defined(__CYGWIN__)
typedef u_int32_t uint32_t;
typedef u_int16_t uint16_t;
typedef u_int8_t uint8_t;
#endif

// General hash
extern uint32_t hashword(register uint32_t *k, 
						register size_t length, 
						register uint32_t initval);

// Little endian hash
extern uint32_t hashlittle(register void *key, 
						  register size_t length, 
						  register uint32_t initval);

// Big endian hash
extern uint32_t hashbig(register void *key, 
					  register size_t length, 
					  register uint32_t initval);

#endif

