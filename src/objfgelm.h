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
**
**  The following enum constants are positions of non-defining data in the
**  types of associative words (AWP = Associative Word Position).
*/
enum {
    START_ENUM_RANGE_INIT(AWP_FIRST_ENTRY, POS_FIRST_FREE_TYPE),

        // the pure type of the object itself, without knowledge features
        AWP_PURE_TYPE,

        // the number of bits available for each exponent
        AWP_NR_BITS_EXP,

        // the number of generators
        AWP_NR_GENS,

        // the number of bits available for each generator/exponent pair
        AWP_NR_BITS_PAIR,

        // the construction function to be called by `ObjByVector'
        AWP_FUN_OBJ_BY_VECTOR,

        // the construction function to be called by `AssocWord'
        AWP_FUN_ASSOC_WORD,

    END_ENUM_RANGE(AWP_LAST_ENTRY),
};

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
    ((UIntN *)( ADDR_OBJ( word ) + 2 ))
#define CONST_DATA_WORD( word ) \
    ((const UIntN *)( CONST_ADDR_OBJ( word ) + 2 ))


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
Obj NewWord(Obj type, UInt npairs);


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
