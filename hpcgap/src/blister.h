/****************************************************************************
**
*W  blister.h                   GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This  file declares the functions  that mainly operate  on boolean lists.
**  Because boolean lists are  just a special case  of lists many  things are
**  done in the list package.
**
**  A *boolean list* is a list that has no holes and contains only 'true' and
**  'false'.  For  the full definition of  boolean list  see chapter "Boolean
**  Lists" in the {\GAP} Manual.  Read  also the section "More  about Boolean
**  Lists" about the different internal representations of such lists.
*/

#ifndef GAP_BLISTER_H
#define GAP_BLISTER_H


/****************************************************************************
**

*V  BIPEB . . . . . . . . . . . . . . . . . . . . . . . . . .  bits per block
**
**  'BIPEB' is the  number of bits  per  block, where a  block  fills a UInt,
**  which must be the same size as a bag identifier.
**
*/
#define BIPEB   (sizeof(UInt) * 8L)


/****************************************************************************
**

*F  PLEN_SIZE_BLIST( <size> ) .  physical length from size for a boolean list
**
**  'PLEN_SIZE_BLIST'  computes  the  physical  length  (e.g.  the  number of
**  elements that could be stored  in a list) from the <size> (as reported by
**  'SIZE') for a boolean list.
**
**  Note that 'PLEN_SIZE_BLIST' is a macro, so  do not call it with arguments
**  that have side effects.
*/
#define PLEN_SIZE_BLIST(size) \
                        ((((size)-sizeof(Obj))/sizeof(UInt)) * BIPEB)


/****************************************************************************
**
*F  SIZE_PLEN_BLIST( <plen> ) . . size for a blist with given physical length
**
**  'SIZE_PLEN_BLIST' returns  the size  that a boolean list  with  room  for
**  <plen> elements must at least have.
**
**  Note that 'SIZE_PLEN_BLIST' is a macro, so do not call it with  arguments
**  that have side effects.
*/
#define SIZE_PLEN_BLIST(plen) \
                        (sizeof(Obj)+((plen)+BIPEB-1)/BIPEB*sizeof(UInt))


/****************************************************************************
**
*F  LEN_BLIST( <list> ) . . . . . . . . . . . . . .  length of a boolean list
**
**  'LEN_BLIST' returns the logical length of the boolean list <list>, as a C
**  integer.
**
**  Note that 'LEN_BLIST' is a macro, so do not call it  with  arguments that
**  have side effects.
*/
#define LEN_BLIST(list)         (INT_INTOBJ(ADDR_OBJ(list)[0]))


/***************************************************************************
**
*F  NUMBER_BLOCKS_BLIST(<list>) . . . . . . . . number of UInt blocks in list
**
*/
#define NUMBER_BLOCKS_BLIST( blist ) ((LEN_BLIST((blist)) + BIPEB -1)/BIPEB)


/****************************************************************************
**
*F  SET_LEN_BLIST( <list>, <len> )  . . . .  set the length of a boolean list
**
**  'SET_LEN_BLIST' sets the  length of the boolean list  <list> to the value
**  <len>, which must be a positive C integer.
**
**  Note that 'SET_LEN_BLIST' is a macro, so do  not  call it with  arguments
**  that have side effects.
*/
#define SET_LEN_BLIST(list,len) \
                        (ADDR_OBJ(list)[0] = INTOBJ_INT(len))


/****************************************************************************
**
*F  BLOCKS_BLIST( <list> )  . . . . . . . . . . first block of a boolean list
**
**  returns a pointer to the start of the data of the Boolean list
**
*/
#define BLOCKS_BLIST( list )  ((UInt*)(ADDR_OBJ(list)+1))


/****************************************************************************
**
*F  BLOCK_ELM_BLIST( <list>, <pos> )  . . . . . . . . block of a boolean list
**
**  'BLOCK_ELM_BLIST' return the block containing the <pos>-th element of the
**  boolean list <list> as   a UInt value, which  is  also a valid left  hand
**  side.  <pos> must be a positive integer less than  or equal to the length
**  of <list>.
**
**  Note that 'BLOCK_ELM_BLIST' is a macro, so do not call it  with arguments
**  that have side effects.
*/
#define BLOCK_ELM_BLIST(list, pos) (BLOCKS_BLIST( list )[((pos)-1)/BIPEB])


/****************************************************************************
**
*F  MASK_POS_BLIST( <pos> )  . . . .  bit mask for position of a Boolean list
**
**  MASK_POS_BLIST(<pos>) returns a UInt with   a single set bit in  position
**  (pos-1) % BIPEB, useful for accessing the pos'th element of a blist
**
**  Note that 'MASK_POS_BLIST' is a  macro, so do  not call it with arguments
**  that have side effects.
*/
#define MASK_POS_BLIST( pos ) (((UInt) 1)<<((pos)-1)%BIPEB)


/****************************************************************************
**
*F  ELM_BLIST( <list>, <pos> ) . . . . . . . . . .  element of a boolean list
**
**  'ELM_BLIST' return the <pos>-th element of the boolean list <list>, which
**  is either 'true' or 'false'.  <pos> must  be a positive integer less than
**  or equal to the length of <list>.
**
**  Note that 'ELM_BLIST' is a macro, so do not call it  with arguments  that
**  have side effects.
*/
#define ELM_BLIST(list,pos) \
  ((BLOCK_ELM_BLIST(list,pos) & MASK_POS_BLIST(pos)) ?  True : False)


/****************************************************************************
**
*F  SET_ELM_BLIST( <list>, <pos>, <val> ) .  set an element of a boolean list
**
**  'SET_ELM_BLIST' sets  the element at position <pos>   in the boolean list
**  <list> to the value <val>.  <pos> must be a positive integer less than or
**  equal to the length of <list>.  <val> must be either 'true' or 'false'.
**
**  Note that  'SET_ELM_BLIST' is  a macro, so do not  call it with arguments
**  that have side effects.
*/
#define SET_ELM_BLIST(list,pos,val)  \
 ((val) == True ? \
  (BLOCK_ELM_BLIST(list, pos) |= MASK_POS_BLIST(pos)) : \
  (BLOCK_ELM_BLIST(list, pos) &= ~MASK_POS_BLIST(pos)))


/****************************************************************************
**
*F  IS_BLIST_REP( <list> )  . . . . .  check if <list> is in boolean list rep
*/
#define IS_BLIST_REP(list)  \
  ( T_BLIST <= TNUM_OBJ(list) && TNUM_OBJ(list) <= T_BLIST_SSORT+IMMUTABLE )


/****************************************************************************
**
*F  COUNT_TRUES_BLOCK( <block> )  . . . . . . . . . . . count number of trues
*/
#ifdef SYS_IS_64_BIT

#define COUNT_TRUES_BLOCK( block )                                                          \
        do {                                                                                \
        (block) = ((block) & 0x5555555555555555L) + (((block) >> 1) & 0x5555555555555555L); \
        (block) = ((block) & 0x3333333333333333L) + (((block) >> 2) & 0x3333333333333333L); \
        (block) = ((block) + ((block) >>  4)) & 0x0f0f0f0f0f0f0f0fL;                        \
        (block) = ((block) + ((block) >>  8));                                              \
        (block) = ((block) + ((block) >> 16));                                              \
        (block) = ((block) + ((block) >> 32)) & 0x00000000000000ffL; } while (0)            

#else

#define COUNT_TRUES_BLOCK( block )                                        \
        do {                                                              \
        (block) = ((block) & 0x55555555) + (((block) >> 1) & 0x55555555); \
        (block) = ((block) & 0x33333333) + (((block) >> 2) & 0x33333333); \
        (block) = ((block) + ((block) >>  4)) & 0x0f0f0f0f;               \
        (block) = ((block) + ((block) >>  8));                            \
        (block) = ((block) + ((block) >> 16)) & 0x000000ff; } while (0)   
#endif


/****************************************************************************
**

*F * * * * * * * * * * * * * * list functions * * * * * * * * * * * * * * * *
*/

/****************************************************************************
**


*F  AssBlist( <list>, <pos>, <val> )  . . . . . . .  assign to a boolean list
**
**  'AssBlist' assigns the   value <val> to  the  boolean list <list> at  the
**  position <pos>.   It is the responsibility  of the caller to  ensure that
**  <pos> is positive, and that <val> is not 0.
**
**  'AssBlist' is the function in 'AssListFuncs' for boolean lists.
**
**  If <pos> is less than or equal to the logical length  of the boolean list
**  and <val> is 'true' or   'false' the assignment  is  done by setting  the
**  corresponding bit.  If <pos>  is one more  than the logical length of the
**  boolean list  the assignment is  done by   resizing  the boolean list  if
**  necessary, setting the   corresponding bit and  incrementing  the logical
**  length  by one.  Otherwise  the boolean list is  converted to an ordinary
**  list and the assignment is performed the ordinary way.
*/
extern void AssBlist (
    Obj                 list,
    Int                 pos,
    Obj                 val );


/****************************************************************************
**
*F  ConvBlist( <list> ) . . . . . . . . .  convert a list into a boolean list
**
**  `ConvBlist' changes the representation of boolean  lists into the compact
**  representation of type 'T_BLIST' described above.
*/
extern void ConvBlist (
    Obj                 list );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**

*F  InitInfoBlist() . . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoBlist ( void );


#endif // GAP_BLISTER_H

/****************************************************************************
**

*E  blister.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
