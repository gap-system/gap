/******************************************************************************
 *
 *    jhash.h     The Bob Jenkins Hash Function
 *
 *    File      : $RCSfile: jhash.h,v $
 *    Author    : Henrik B‰‰rnhielm 
 *    Dev start : 2006-07-16 
 *
 *    Version   : $Revision: 1.6 $
 *    Date      : $Date: 2006/10/31 15:27:26 $
 *    Last edit : $Author: alexk $
 *
 *    @(#)$Id: jhash.h,v 1.6 2006/10/31 15:27:26 alexk Exp $
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


#include <stdint.h>

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

