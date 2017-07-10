/****************************************************************************
**
*W  objcftl.h                      GAP source                   Werner Nickel
**
**
**  This file declares the function collecting from the left with polycyclic
**  presentations.
*/

#ifndef GAP_OBJCFTL_H
#define GAP_OBJCFTL_H


#define PC_NUMBER_OF_GENERATORS      1
#define PC_GENERATORS                2
#define PC_INVERSES                  3
#define PC_COMMUTE                   4
#define PC_POWERS                    5
#define PC_INVERSEPOWERS             6
#define PC_EXPONENTS                 7
#define PC_CONJUGATES                8
#define PC_INVERSECONJUGATES         9
#define PC_CONJUGATESINVERSE        10
#define PC_INVERSECONJUGATESINVERSE 11
#define PC_DEEP_THOUGHT_POLS        12
#define PC_DEEP_THOUGHT_BOUND       13
#define PC_ORDERS                   14

#define PC_WORD_STACK               15
#define PC_STACK_SIZE               16
#define PC_WORD_EXPONENT_STACK      17
#define PC_SYLLABLE_STACK           18
#define PC_EXPONENT_STACK           19
#define PC_STACK_POINTER            20
#define PC_DEFAULT_TYPE             21

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  InitInfoPcc() . . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoPcc ( void );


#endif // GAP_OBJCFTL_H
