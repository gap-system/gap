/****************************************************************************
**
*W  range.h                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file declares the functions that deal with ranges.
**
**  A *range* is  a list without  holes  consisting  of consecutive integers.
**  For the full definition of ranges see chapter "Ranges" in the GAP Manual.
**  Read  also   "More about Ranges"  about  the different  representation of
**  ranges.
**
**  Ranges  can  be  accessed  through  the macros  'NEW_RANGE',  'IS_RANGE',
**  'SET_LEN_RANGE',   'GET_LEN_RANGE',  'SET_LOW_RANGE',    'GET_LOW_RANGE',
**  'SET_INC_RANGE', 'GET_INC_RANGE', and 'GET_ELM_RANGE'.
**
**  This package  also contains  the  list  functions  for ranges, which  are
**  installed in the appropriate tables by 'InitRange'.
*/
#ifdef  INCLUDE_DECLARATION_PART
SYS_CONST char * Revision_range_h =
   "@(#)$Id$";
#endif


/****************************************************************************
**

*F  NEW_RANGE() . . . . . . . . . . . . . . . . . . . . . .  make a new range
**
**  'NEW_RANGE' returns a new range.  Note that  you must set the length, the
**  low value, and the increment before you can use the range.
*/
#define NEW_RANGE_NSORT() NewBag( T_RANGE_NSORT, 3 * sizeof(Obj) )
#define NEW_RANGE_SSORT() NewBag( T_RANGE_SSORT, 3 * sizeof(Obj) )


/****************************************************************************
**
*F  IS_RANGE(<val>) . . . . . . . . . . . . . . .  test if a value is a range
**
**  'IS_RANGE' returns 1  if the value  <val> is known  to be a range,  and 0
**  otherwise.  Note that a list for which 'IS_RANGE' returns  0 may still be
**  a range, but  the kernel does not know  this yet.  Use  'IsRange' to test
**  whether a list is a range.
**
**  Note that  'IS_RANGE' is a  macro, so do not  call it with arguments that
**  have sideeffects.
*/
#define IS_RANGE(val)   (TNUM_OBJ(val)==T_RANGE_NSORT || TNUM_OBJ(val)==T_RANGE_SSORT)


/****************************************************************************
**
*F  SET_LEN_RANGE(<list>,<len>) . . . . . . . . . . set the length of a range
**
**  'SET_LEN_RANGE' sets the length  of the range <list>  to the value <len>,
**  which must be a C integer larger than 1.
**
**  Note that 'SET_LEN_RANGE' is a macro,  so  do not  call it with arguments
**  that have sideeffects.
*/
#define SET_LEN_RANGE(list,len)         (ADDR_OBJ(list)[0] = INTOBJ_INT(len))


/****************************************************************************
**
*F  GET_LEN_RANGE(<list>) . . . . . . . . . . . . . . . . . length of a range
**
**  'GET_LEN_RANGE' returns the  logical length of  the range <list>, as  a C
**  integer.
**
**  Note that  'GET_LEN_RANGE' is a macro, so  do not call  it with arguments
**  that have sideeffects.
*/
#define GET_LEN_RANGE(list)             INT_INTOBJ( ADDR_OBJ(list)[0] )


/****************************************************************************
**
*F  SET_LOW_RANGE(<list>,<low>) . . . . . .  set the first element of a range
**
**  'SET_LOW_RANGE' sets the  first element of the range  <list> to the value
**  <low>, which must be a C integer.
**
**  Note  that 'SET_LOW_RANGE' is a macro, so do not call  it with  arguments
**  that have sideeffects.
*/
#define SET_LOW_RANGE(list,low)         (ADDR_OBJ(list)[1] = INTOBJ_INT(low))


/****************************************************************************
**
*F  GET_LOW_RANGE(<list>) . . . . . . . . . . . . .  first element of a range
**
**  'GET_LOW_RANGE' returns the first  element  of the  range  <list> as a  C
**  integer.
**
**  Note that 'GET_LOW_RANGE' is a  macro, so do not  call it with  arguments
**  that have sideeffects.
*/
#define GET_LOW_RANGE(list)             INT_INTOBJ( ADDR_OBJ(list)[1] )


/****************************************************************************
**
*F  SET_INC_RANGE(<list>,<inc>) . . . . . . . .  set the increment of a range
**
**  'SET_INC_RANGE' sets  the  increment of  the range  <list>   to the value
**  <inc>, which must be a C integer.
**
**  Note that  'SET_INC_RANGE' is a macro,  so do  not call it with arguments
**  that have sideeffects.
*/
#define SET_INC_RANGE(list,inc)         (ADDR_OBJ(list)[2] = INTOBJ_INT(inc))


/****************************************************************************
**
*F  GET_INC_RANGE(<list>) . . . . . . . . . . . . . . .  increment of a range
**
**  'GET_INC_RANGE' returns the increment of the range <list> as a C integer.
**
**  Note  that 'GET_INC_RANGE' is  a macro, so  do not call it with arguments
**  that have sideeffects.
*/
#define GET_INC_RANGE(list)             INT_INTOBJ( ADDR_OBJ(list)[2] )


/****************************************************************************
**
*F  GET_ELM_RANGE(<list>,<pos>) . . . . . . . . . . . . .  element of a range
**
**  'GET_ELM_RANGE' return  the <pos>-th element  of the range <list>.  <pos>
**  must be a positive integer less than or equal to the length of <list>.
**
**  Note that 'GET_ELM_RANGE'  is a macro, so do  not call  it with arguments
**  that have sideeffects.
*/
#define GET_ELM_RANGE(list,pos)         INTOBJ_INT( GET_LOW_RANGE(list) \
                                          + ((pos)-1) * GET_INC_RANGE(list) )


/****************************************************************************
**
*F  PosRange(<list>,<val>,<start>)  . . . . position of an element in a range
**
**  'PosRange' returns the position  of the value <val>  in the range  <list>
**  after the first position <start> as a C integer.   0 is returned if <val>
**  is not in the list.
*/
extern  Int             PosRange (
            Obj                 list,
            Obj                 val,
            Int                 start );


/****************************************************************************
**
*F  Range2Check( <first>, <last> )  . . . . . . . . . . . . . construct range
*/
extern Obj Range2Check (
    Obj                 first,
    Obj                 last );


/****************************************************************************
**
*F  Range3Check( <first>, <second>, <last> )  . . . . . . . . construct range
*/
extern Obj Range3Check (
    Obj                 first,
    Obj                 second,
    Obj                 last );


/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  SetupRange() . . . . . . . . . . . . . . . . initialize the range package
*/
extern void SetupRange ( void );


/****************************************************************************
**
*F  InitRange() . . . . . . . . . . . . . . . .  initialize the range package
**
**  'InitRange' initializes the range package.
*/
extern void InitRange ( void );


/****************************************************************************
**
*F  CheckRange()  . . . . . . . check the initialisation of the range package
*/
extern void CheckRange ( void );


/****************************************************************************
**

*E  range.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
