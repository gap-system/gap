/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef GAP_OBJFGELM_H
#define GAP_OBJFGELM_H

#include "objects.h"

/****************************************************************************
**
*D  AWP_SOMETHING
*/
#define AWP_FIRST_ENTRY          5
#define AWP_PURE_TYPE            (AWP_FIRST_ENTRY+0)
#define AWP_NR_BITS_EXP          (AWP_FIRST_ENTRY+1)
#define AWP_NR_GENS              (AWP_FIRST_ENTRY+2)
#define AWP_NR_BITS_PAIR         (AWP_FIRST_ENTRY+3)
#define AWP_FUN_OBJ_BY_VECTOR    (AWP_FIRST_ENTRY+4)
#define AWP_FUN_ASSOC_WORD       (AWP_FIRST_ENTRY+5)
#define AWP_FIRST_FREE           (AWP_FIRST_ENTRY+6)


/****************************************************************************
**
*F  BITS_WORDTYPE( <type> )
*/
#define BITS_WORDTYPE( type ) \
    ( INT_INTOBJ( ELM_PLIST( (type), AWP_NR_BITS_PAIR ) ) )


/****************************************************************************
**
*F  EBITS_WORDTYPE( <type> )
*/
#define EBITS_WORDTYPE( type ) \
    ( INT_INTOBJ( ELM_PLIST( (type), AWP_NR_BITS_EXP ) ) )


/****************************************************************************
**
*F  RANK_WORDTYPE( <type> )
*/
#define RANK_WORDTYPE( type ) \
    ( INT_INTOBJ( ELM_PLIST( (type), AWP_NR_GENS ) ) )


/****************************************************************************
**
*F  PURETYPE_WORDTYPE( <type> )
*/
#define PURETYPE_WORDTYPE( type ) \
    ( ELM_PLIST( (type), AWP_PURE_TYPE ) )


/****************************************************************************
**
*F  BITS_WORD( <word> )
*/
#define BITS_WORD( word ) \
    ( BITS_WORDTYPE( TYPE_DATOBJ( (word) ) ) )


/****************************************************************************
**
*F  DATA_WORD( <word> )
**
**  'DATA_WORD' returns a pointer to the data area of <word>.
*/
#define DATA_WORD( word ) \
    ((UIntN *)( (Char*)ADDR_OBJ( (word) ) + 2*sizeof(Obj) ))
#define CONST_DATA_WORD( word ) \
    ((const UIntN *)( (const Char*)CONST_ADDR_OBJ( (word) ) + 2*sizeof(Obj) ))


/****************************************************************************
**
*F  EBITS_WORD( <word> )
*/
#define EBITS_WORD( word ) \
    ( EBITS_WORDTYPE( TYPE_DATOBJ( (word) ) ) )


/****************************************************************************
**
*F  NPAIRS_WORD( <word> )
**
**  'NPAIRS_WORD' returns the  number of pairs of  generator  number/exponent
**  pairs of <word>.
*/
#define NPAIRS_WORD( word ) \
    ( INT_INTOBJ( CONST_ADDR_OBJ( (word) )[1]) )


/****************************************************************************
**
*F  RANK_WORD( <word> )
*/
#define RANK_WORD( word ) \
    ( RANK_WORDTYPE( TYPE_DATOBJ( (word) ) ) )


/****************************************************************************
**
*F  PURETYPE_WORD( <word> )
*/
#define PURETYPE_WORD( word ) \
    ( PURETYPE_WORDTYPE( TYPE_DATOBJ( (word) ) ) )


/****************************************************************************
**
*F  NewWord( <type>, <npairs> )
**
**  'NewWord' returns a new object which has the given <type> and room for
**  <npairs> pairs of generator number/exponent.
*/
extern Obj NewWord(Obj type, UInt npairs);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoFreeGroupElements() . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoFreeGroupElements ( void );


#endif // GAP_OBJFGELM_H
