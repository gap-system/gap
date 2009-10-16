/****************************************************************************
**
*A  word_types.h                ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: word_types.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* header file for call types to procedures to read words and for 
   symbols used in words */

#ifndef __WORD_TYPES__
#define __WORD_TYPES__

#define LHS 1
#define RHS 2
#define WORD 3
#define INVERSE_OF_WORD 3
#define VALUE_A 4
#define VALUE_B 5
#define FIRST_ENTRY 6
#define NEXT_ENTRY 7
#define ACTION 8 

#define END_OF_WORD ';' 
#define LHS_COMMUTATOR '[' 
#define RHS_COMMUTATOR ']' 

#endif 
