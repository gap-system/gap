/****************************************************************************
**
*W  objfgelm.h                  GAP source                       Frank Celler
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*/
#ifdef  INCLUDE_DECLARATION_PART
char * Revision_objfgelm_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*D  AWP_SOMETHING
*/
#define AWP_FIRST_ENTRY          5
#define AWP_PURE_KIND 		 (AWP_FIRST_ENTRY+0)
#define AWP_NR_BITS_EXP          (AWP_FIRST_ENTRY+1)
#define AWP_NR_GENS              (AWP_FIRST_ENTRY+2)
#define AWP_NR_BITS_PAIR         (AWP_FIRST_ENTRY+3)
#define AWP_FUN_OBJ_BY_VECTOR    (AWP_FIRST_ENTRY+4)
#define AWP_FUN_ASSOC_WORD       (AWP_FIRST_ENTRY+5)
#define AWP_FIRST_FREE           (AWP_FIRST_ENTRY+6)


/****************************************************************************
**

*F  BITS_WORDKIND( <kind> )
*/
#define BITS_WORDKIND( kind ) \
    ( INT_INTOBJ( ELM_PLIST( (kind), AWP_NR_BITS_PAIR ) ) )


/****************************************************************************
**
*F  EBITS_WORDKIND( <kind> )
*/
#define EBITS_WORDKIND( kind ) \
    ( INT_INTOBJ( ELM_PLIST( (kind), AWP_NR_BITS_EXP ) ) )


/****************************************************************************
**
*F  RANK_WORDKIND( <kind> )
*/
#define RANK_WORDKIND( kind ) \
    ( INT_INTOBJ( ELM_PLIST( (kind), AWP_NR_GENS ) ) )


/****************************************************************************
**
*F  PUREKIND_WORDKIND( <kind> )
*/
#define PUREKIND_WORDKIND( kind ) \
    ( ELM_PLIST( (kind), AWP_PURE_KIND ) )


/****************************************************************************
**

*F  BITS_WORD( <word> )
*/
#define BITS_WORD( word ) \
    ( BITS_WORDKIND( KIND_DATOBJ( (word) ) ) )


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
    ( EBITS_WORDKIND( KIND_DATOBJ( (word) ) ) )


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
    ( RANK_WORDKIND( KIND_DATOBJ( (word) ) ) )


/****************************************************************************
**
*F  PUREKIND_WORD( <word> )
*/
#define PUREKIND_WORD( word ) \
    ( PUREKIND_WORDKIND( KIND_DATOBJ( (word) ) ) )


/****************************************************************************
**

*F  NEW_WORD( <word>, <kind>, <npairs> )
**
**  'NEW_WORD' creates  a new object which has  the given <kind> and room for
**  <npairs> pairs of generator number/exponent.  The new  word is return  in
**  <word>.
*/
#define NEW_WORD( word, kind, npairs ) \
 ((word)=NewBag(T_DATOBJ,2*sizeof(Obj)+((npairs)*BITS_WORDKIND((kind))/8L)),\
  (ADDR_OBJ((word))[1] = INTOBJ_INT((npairs))),\
  SET_KIND_DATOBJ( (word), (kind) ), (word) )


/****************************************************************************
**
*F  RESIZE_WORD( <word>, <npairs> )
*/
#define RESIZE_WORD( word, bits, npairs ) \
  (ResizeBag( (word), 2*sizeof(Obj)+((npairs)*BITS_WORD((word))/8L)), \
   (ADDR_OBJ((word))[1] = INTOBJ_INT((npairs))), \
   (word) )


/****************************************************************************
**

*F  InitFreeGroupElements()
*/
extern void InitFreeGroupElements ( void );



/****************************************************************************
**

*E  objfgelm.h  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
