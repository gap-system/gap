/****************************************************************************
**
*A  blister.h                   GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
#ifdef  INCLUDE_DECLARATION_PART
char *          Revision_blister_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**
*V  BIPEB . . . . . . . . . . . . . . . . . . . . . . . . . .  bits per block
**
**  'BIPEB' is the number of bits per block, usually 32.
*/
#define BIPEB                           (sizeof(UInt4) * 8L)


/****************************************************************************
**
*F  PLEN_SIZE_BLIST(<size>) . .  physical length from size for a boolean list
**
**  'PLEN_SIZE_BLIST'  computes  the  physical  length  (e.g.  the  number of
**  elements that could be stored  in a list) from the <size> (as reported by
**  'SIZE') for a boolean list.
**
**  Note that 'PLEN_SIZE_BLIST' is a macro, so  do not call it with arguments
**  that have sideeffects.
*/
#define PLEN_SIZE_BLIST(size) \
                        ((((size)-sizeof(Obj))/sizeof(Obj)) * BIPEB)


/****************************************************************************
**
*F  SIZE_PLEN_BLIST(<plen>)size for a boolean list with given physical length
**
**  'SIZE_PLEN_BLIST' returns  the size  that a boolean list  with  room  for
**  <plen> elements must at least have.
**
**  Note that 'SIZE_PLEN_BLIST' is a macro, so do not call it with  arguments
**  that have sideeffects.
*/
#define SIZE_PLEN_BLIST(plen) \
                        (sizeof(Obj)+((plen)+BIPEB-1)/BIPEB*sizeof(Obj))


/****************************************************************************
**
*F  LEN_BLIST(<list>) . . . . . . . . . . . . . . .  length of a boolean list
**
**  'LEN_BLIST' returns the logical length of the boolean list <list>, as a C
**  integer.
**
**  Note that 'LEN_BLIST' is a macro, so do not call it  with  arguments that
**  have sideeffects.
*/
#define LEN_BLIST(list) \
                        (INT_INTOBJ(ADDR_OBJ(list)[0]))


/****************************************************************************
**
*F  SET_LEN_BLIST(<list>,<len>) . . . . . .  set the length of a boolean list
**
**  'SET_LEN_BLIST' sets the  length of the boolean list  <list> to the value
**  <len>, which must be a positive C integer.
**
**  Note that 'SET_LEN_BLIST' is a macro, so do  not  call it with  arguments
**  that have sideeffects.
*/
#define SET_LEN_BLIST(list,len) \
                        (ADDR_OBJ(list)[0] = INTOBJ_INT(len))


/****************************************************************************
**
*F  ELM_BLIST(<list>,<pos>) . . . . . . . . . . . . element of a boolean list
**
**  'ELM_BLIST' return the <pos>-th element of the boolean list <list>, which
**  is either 'true' or 'false'.  <pos> must  be a positive integer less than
**  or equal to the length of <hdList>.
**
**  Note that 'ELM_BLIST' is a macro, so do not call it  with arguments  that
**  have sideeffects.
*/
#define ELM_BLIST(list,pos) \
 (((UInt4*)(ADDR_OBJ(list)+1))[((pos)-1)/BIPEB]&(1UL<<((pos)-1)%BIPEB) ? \
  True : False)


/****************************************************************************
**
*F  SET_ELM_BLIST(<list>,<pos>,<val>) . . .  set an element of a boolean list
**
**  'SET_ELM_BLIST' sets  the element at position <pos>   in the boolean list
**  <list> to the value <val>.  <pos> must be a positive integer less than or
**  equal to the length of <hdList>.  <val> must be either 'true' or 'false'.
**
**  Note that  'SET_ELM_BLIST' is  a macro, so do not  call it with arguments
**  that have sideeffects.
*/
#define SET_ELM_BLIST(list,pos,val)  \
 ((val) == True ? \
  (((UInt4*)(ADDR_OBJ(list)+1))[((pos)-1)/BIPEB]|=(1UL<<((pos)-1)%BIPEB)) : \
  (((UInt4*)(ADDR_OBJ(list)+1))[((pos)-1)/BIPEB]&=~(1UL<<((pos)-1)%BIPEB)))


/****************************************************************************
**
*F  InitBlist() . . . . . . . . . . . . . initialize the boolean list package
**
**  'InitBlist' initializes the boolean list package.
*/
extern  void            InitBlist ( void );



