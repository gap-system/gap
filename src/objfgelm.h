/****************************************************************************
**
*W  objfgelm.h                  GAP source                       Frank Celler
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
*/

#ifndef GAP_OBJFGELM_H
#define GAP_OBJFGELM_H


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
    ( (Char*)ADDR_OBJ( (word) ) + 2*sizeof(Obj) )


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
    ( INT_INTOBJ( ADDR_OBJ( (word) )[1]) )


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

*F  NEW_WORD( <word>, <type>, <npairs> )
**
**  'NEW_WORD' creates  a new object which has  the given <type> and room for
**  <npairs> pairs of generator number/exponent.  The new  word is return  in
**  <word>.
*/
static inline Obj NewWord(Obj type, UInt npairs) {
  Obj word;
  word = NewBag(T_DATOBJ,2*sizeof(Obj)+npairs*BITS_WORDTYPE(type)/8L);
  (ADDR_OBJ(word)[1] = INTOBJ_INT(npairs));
  SetTypeDatObj(word, type);
  return word;
}

#define NEW_WORD_READ_WRITE(word, type, npairs) \
  (word) = NewWord((type), (npairs))

#define NEW_WORD(word, type, npairs) \
  (word) = NewWord((type), (npairs))

/****************************************************************************
**
*F  RESIZE_WORD( <word>, <npairs> )
*/
static inline Obj RESIZE_WORD( Obj word, UInt npairs )
{
  WriteGuard(word);
  ResizeBag( (word), 2*sizeof(Obj)+((npairs)*BITS_WORD((word))/8L));
  (ADDR_OBJ((word))[1] = INTOBJ_INT((npairs)));
  return word;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoFreeGroupElements() . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoFreeGroupElements ( void );


#endif // GAP_OBJFGELM_H

/****************************************************************************
**

*E  objfgelm.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
