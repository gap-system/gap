/****************************************************************************
**
*W  range.c                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions that deal with ranges.
**
**  A *range* is  a list without  holes  consisting  of consecutive integers.
**  For the full definition of ranges see chapter "Ranges" in the GAP Manual.
**  Read  also   "More about Ranges"  about  the different  representation of
**  ranges.
**
**  A list that is  known to be  a  range is  represented  by a  bag of  type
**  'T_RANGE', which has the following format:
**
**      +-------+-------+-------+
**      |logical| first | incr- |
**      | length|element| ement |
**      +-------+-------+-------+
**
**  The first entry is the handle of the logical length.  The second entry is
**  the first element of the range.  The last  entry  is the  increment.  All
**  three are represented as immediate GAP integers.
**
**  The element at position <pos> is thus simply <first> + (<pos>-1) * <inc>.
**
**  Note  that  a list  represented by a   bag of type   'T_LIST', 'T_SET' or
**  'T_VECTOR' might still  be a range.  It is  just that the kernel does not
**  know this.
**
**  This package consists of three parts.
**
**  The  first part   consists   of  the  macros    'NEW_RANGE',  'IS_RANGE',
**  'SET_LEN_RANGE',   'GET_LEN_RANGE',    'SET_LOW_RANGE',  'GET_LOW_RANGE',
**  'SET_INC_RANGE', 'GET_INC_RANGE',    and 'GET_ELM_RANGE'.  They determine
**  the representation of ranges.  Everything else in  this file and the rest
**  of the {\GAP} kernel uses those macros to access and modify ranges.
**
**  The  second part  consists  of   the functions  'LenRange',   'ElmRange',
**  'ElmsRange',   'AssRange',      'AsssRange',   'PosRange',  'PlainRange',
**  'IsDenseRange',   'IsPossRange', 'PrintRange', 'EqRange', and  'LtRange'.
**  They  are the  functions required by  the generic   lists package.  Using
**  these functions the other parts of the {\GAP} kernel can access or modify
**  ranges without actually being aware that they are dealing with a range.
**
**  The  third part consists  ...
*/
char *          Revision_range_c =
   "@(#)$Id$";

#include        "system.h"              /* system dependent functions      */

#include        "gasman.h"              /* NewBag, ResizeBag, CHANGED_BAG  */
#include        "objects.h"             /* Obj, TNUM_OBJ, SIZE_OBJ, ...    */
#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* AssGVar, GVarName               */

#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations package      */

#include        "ariths.h"              /* generic operations package      */
#include        "lists.h"               /* generic list package            */

#include        "bool.h"                /* True, False                     */

#include        "plist.h"               /* GET_LEN_PLIST, GET_ELM_PLIST,...*/

#define INCLUDE_DECLARATION_PART
#include        "range.h"               /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**

*F  NEW_RANGE() . . . . . . . . . . . . . . . . . . . . . .  make a new range
**
**  'NEW_RANGE' returns a new range.  Note that  you must set the length, the
**  low value, and the increment before you can use the range.
**
**  'NEW_RANGE' is defined in the declaration part of this package as follows
**
#define NEW_RANGE_NSORT() NewBag( T_RANGE_NSORT, 3 * sizeof(Obj) )
#define NEW_RANGE_SSORT() NewBag( T_RANGE_SSORT, 3 * sizeof(Obj) )
*/


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
**
**  'IS_RANGE' is defined in the declaration part of this package as follows
**
#define IS_RANGE(val)   (TNUM_OBJ(val)==T_RANGE_NSORT || TNUM_OBJ(val)==T_RANGE_SSORT)
*/


/****************************************************************************
**
*F  SET_LEN_RANGE(<list>,<len>) . . . . . . . . . . set the length of a range
**
**  'SET_LEN_RANGE' sets the length  of the range <list>  to the value <len>,
**  which must be a C integer larger than 1.
**
**  Note that 'SET_LEN_RANGE' is a macro,  so  do not  call it with arguments
**  that have sideeffects.
**
**  'SET_LEN_RANGE' is  defined in  the declaration part  of  this package as
**  follows
**
#define SET_LEN_RANGE(list,len)         (ADDR_OBJ(list)[0] = INTOBJ_INT(len))
*/


/****************************************************************************
**
*F  GET_LEN_RANGE(<list>) . . . . . . . . . . . . . . . . . length of a range
**
**  'GET_LEN_RANGE' returns the  logical length of  the range <list>, as  a C
**  integer.
**
**  Note that  'GET_LEN_RANGE' is a macro, so  do not call  it with arguments
**  that have sideeffects.
**
**  'GET_LEN_RANGE' is  defined in  the declaration part  of this  package as
**  follows
**
#define GET_LEN_RANGE(list)             INT_INTOBJ( ADDR_OBJ(list)[0] )
*/


/****************************************************************************
**
*F  SET_LOW_RANGE(<list>,<low>) . . . . . .  set the first element of a range
**
**  'SET_LOW_RANGE' sets the  first element of the range  <list> to the value
**  <low>, which must be a C integer.
**
**  Note  that 'SET_LOW_RANGE' is a macro, so do not call  it with  arguments
**  that have sideeffects.
**
**  'SET_LOW_RANGE' is defined  in the declaration  part  of this package  as
**  follows
**
#define SET_LOW_RANGE(list,low)         (ADDR_OBJ(list)[1] = INTOBJ_INT(low))
*/


/****************************************************************************
**
*F  GET_LOW_RANGE(<list>) . . . . . . . . . . . . .  first element of a range
**
**  'GET_LOW_RANGE' returns the first  element  of the  range  <list> as a  C
**  integer.
**
**  Note that 'GET_LOW_RANGE' is a  macro, so do not  call it with  arguments
**  that have sideeffects.
**
**  'GET_LOW_RANGE'  is defined in  the declaration  part  of this package as
**  follows
**
#define GET_LOW_RANGE(list)             INT_INTOBJ( ADDR_OBJ(list)[1] )
*/


/****************************************************************************
**
*F  SET_INC_RANGE(<list>,<inc>) . . . . . . . .  set the increment of a range
**
**  'SET_INC_RANGE' sets  the  increment of  the range  <list>   to the value
**  <inc>, which must be a C integer.
**
**  Note that  'SET_INC_RANGE' is a macro,  so do  not call it with arguments
**  that have sideeffects.
**
**  'SET_INC_RANGE' is  defined  in the  declaration part of  this package as
**  follows
**
#define SET_INC_RANGE(list,inc)         (ADDR_OBJ(list)[2] = INTOBJ_INT(inc))
*/


/****************************************************************************
**
*F  GET_INC_RANGE(<list>) . . . . . . . . . . . . . . .  increment of a range
**
**  'GET_INC_RANGE' returns the increment of the range <list> as a C integer.
**
**  Note  that 'GET_INC_RANGE' is  a macro, so  do not call it with arguments
**  that have sideeffects.
**
**  'GET_INC_RANGE' is  defined  in the  declaration part  of this package as
**  follows
**
#define GET_INC_RANGE(list)             INT_INTOBJ( ADDR_OBJ(list)[2] )
*/


/****************************************************************************
**
*F  GET_ELM_RANGE(<list>,<pos>) . . . . . . . . . . . . .  element of a range
**
**  'GET_ELM_RANGE' return  the <pos>-th element  of the range <list>.  <pos>
**  must be a positive integer less than or equal to the length of <list>.
**
**  Note that 'GET_ELM_RANGE'  is a macro, so do  not call  it with arguments
**  that have sideeffects.
**
**  'GET_ELM_RANGE'  is  defined in the  declaration part  of this package as
**  follows
**
#define GET_ELM_RANGE(list,pos)         INTOBJ_INT( GET_LOW_RANGE(list) \
                                          + ((pos)-1) * GET_INC_RANGE(list) )
*/


/****************************************************************************
**

*F  TypeRangeNSortImmutable( <range> )  . . . . . . . . . . . kind of a range
**
**  'TypeRangeNSortMutable' is the   function in 'TypeObjFuncs' for immutable
**  ranges which are not strictly sorted.
*/
Obj TYPE_RANGE_NSORT_IMMUTABLE;

Obj TypeRangeNSortImmutable (
    Obj                 list )
{
    return TYPE_RANGE_NSORT_IMMUTABLE;
}
    
/****************************************************************************
**
*F  TypeRangeNSortMutable( <range> )  . . . . . . . . . . . . kind of a range
**
**  'TypeRangeNSortMutable' is the   function in 'TypeObjFuncs' for   mutable
**  ranges which are not strictly sorted.
*/
Obj TYPE_RANGE_NSORT_MUTABLE;

Obj TypeRangeNSortMutable (
    Obj                 list )
{
    return TYPE_RANGE_NSORT_MUTABLE;
}
    
/****************************************************************************
**
*F  TypeRangeSSortImmutable( <range> )  . . . . . . . . . . . kind of a range
**
**  'TypeRangeNSortMutable' is the   function in 'TypeObjFuncs' for immutable
**  ranges which are strictly sorted.
*/
Obj TYPE_RANGE_SSORT_IMMUTABLE;

Obj TypeRangeSSortImmutable (
    Obj                 list )
{
    return TYPE_RANGE_SSORT_IMMUTABLE;
}


/****************************************************************************
**
*F  TypeRangeSSortMutable( <range> )  . . . . . . . . . . . . kind of a range
**
**  'TypeRangeNSortMutable' is the   function in 'TypeObjFuncs' for   mutable
**  ranges which are strictly sorted.
*/
Obj TYPE_RANGE_SSORT_MUTABLE;

Obj TypeRangeSSortMutable (
    Obj                 list )
{
    return TYPE_RANGE_SSORT_MUTABLE;
}
    
/****************************************************************************
**

*F  CopyRange( <list>, <mut> )  . . . . . . . . . . . . . . . .  copy a range
**
**  'CopyRange' returns a structural (deep) copy of the range <list>, i.e., a
**  recursive copy that preserves the structure.
**
**  If <list> has not  yet  been copied, it makes   a copy, leaves  a forward
**  pointer to the copy  in the first entry of  the range, where the size  of
**  the range usually  resides, and copies the other  entries.   If the range
**  has already been copied, it returns the value of the forwarding pointer.
**
**  'CopyRange' is the function in 'CopyObjFuncs' for ranges.
**
**  'CleanRange' removes the mark  and the forwarding  pointer from the range
**  <list>.
**
**  'CleanRange' is the function in 'CleanObjFuncs' for ranges.
*/
Obj CopyRange (
    Obj                 list,
    Int                 mut )
{
    Obj                 copy;           /* copy, result                    */

    /* don't change immutable objects                                      */
    if ( ! IS_MUTABLE_OBJ(list) ) {
        return list;
    }

    /* make a copy                                                         */
    if ( mut ) {
        copy = NewBag( TNUM_OBJ(list), SIZE_OBJ(list) );
    }
    else {
        copy = NewBag( IMMUTABLE_TNUM( TNUM_OBJ(list) ), SIZE_OBJ(list) );
    }
    ADDR_OBJ(copy)[0] = ADDR_OBJ(list)[0];

    /* leave a forwarding pointer                                          */
    ADDR_OBJ(list)[0] = copy;
    CHANGED_BAG( list );

    /* now it is copied                                                    */
    RetypeBag( list, TNUM_OBJ(list) + COPYING );

    /* copy the subvalues                                                  */
    ADDR_OBJ(copy)[1] = ADDR_OBJ(list)[1];
    ADDR_OBJ(copy)[2] = ADDR_OBJ(list)[2];

    /* return the copy                                                     */
    return copy;
}


/****************************************************************************
**
*F  CopyRangeCopy( <list>, <mut> )  . . . . . . . . . . . copy a copied range
*/
Obj CopyRangeCopy (
    Obj                 list,
    Int                 mut )
{
    return ADDR_OBJ(list)[0];
}


/****************************************************************************
**
*F  CleanRange( <list> )  . . . . . . . . . . . . . . . . .  clean up a range
*/
void CleanRange (
    Obj                 list )
{
}


/****************************************************************************
**
*F  CleanRange( <list> )  . . . . . . . . . . . . . . clean up a copied range
*/
void CleanRangeCopy (
    Obj                 list )
{
    /* remove the forwarding pointer                                       */
    ADDR_OBJ(list)[0] = ADDR_OBJ( ADDR_OBJ(list)[0] )[0];

    /* now it is cleaned                                                   */
    RetypeBag( list, TNUM_OBJ(list) - COPYING );
}


/****************************************************************************
**

*F  PrintRange(<list>)  . . . . . . . . . . . . . . . . . . . . print a range
**
**  'PrintRange' prints the range <list>.
**
**  'PrintRange' handles bags of type 'T_RANGE'.
*/
void            PrintRange (
    Obj                 list )
{
    Pr( "%2>[ %2>%d",   
       GET_LOW_RANGE(list), 0L );
    if ( GET_INC_RANGE(list) != 1 ) {
        Pr( "%<,%< %2>%d",
           GET_LOW_RANGE(list)+GET_INC_RANGE(list), 0L );
    }
    Pr( "%2< .. %2>%d%4< ]",
       GET_LOW_RANGE(list)+(GET_LEN_RANGE(list)-1)*GET_INC_RANGE(list), 0L );
}


/****************************************************************************
**
*F  EqRange(<listL>,<listR>)  . . . . . . . . .  test if two ranges are equal
**
**  'EqRange' returns 'true' if the two ranges <listL>  and <listR> are equal
**  and 'false' otherwise.
*/
Int             EqRange (
    Obj                 listL,
    Obj                 listR )
{
    return ( GET_LEN_RANGE(listL) == GET_LEN_RANGE(listR)
          && GET_LOW_RANGE(listL) == GET_LOW_RANGE(listR)
          && GET_INC_RANGE(listL) == GET_INC_RANGE(listR) );
}


/****************************************************************************
**
*F  LtRange(<listL>,<listR>)  . . . . . . . . .  test if two ranges are equal
**
**  'LtRange' returns 'true'  if  the range  <listL> is less  than the  range
**  <listR> and 'false' otherwise.
*/
Int             LtRange (
    Obj                 listL,
    Obj                 listR )
{
    /* first compare the first elements                                    */
    if ( GET_LOW_RANGE(listL) < GET_LOW_RANGE(listR) )
        return 1L;
    else if ( GET_LOW_RANGE(listR) < GET_LOW_RANGE(listL) )
        return 0L;

    /* next compare the increments (or the second elements)                */
    if ( GET_INC_RANGE(listL) < GET_INC_RANGE(listR) )
        return 1L;
    else if ( GET_INC_RANGE(listR) < GET_INC_RANGE(listL) )
        return 0L;

    /* finally compare the lengths                                         */
    if ( GET_LEN_RANGE(listL) < GET_LEN_RANGE(listR) )
        return 1L;
    else if ( GET_LEN_RANGE(listR) < GET_LEN_RANGE(listL) )
        return 0L;

    /* the two ranges are equal                                            */
    return 0L;
}


/****************************************************************************
**
*F  LenRange(<list>)  . . . . . . . . . . . . . . . . . . . length of a range
**
**  'LenRange' returns the length of the range <list> as a C integer.
**
**  'LenRange' is the function in 'LenListFuncs' for ranges.
*/
Int             LenRange (
    Obj                 list )
{
    return GET_LEN_RANGE( list );
}


/****************************************************************************
**
*F  IsbRange(<list>,<pos>)  . . . . . . . .  test for an element from a range
**
**  'IsbRange' returns 1 if the range has an element at  the  position  <pos>
**  and 0 otherwise.  It is the responsibility of the caller to  ensure  that
**  <pos> is a positive integer.
**
**  'IsbRange' is the function in 'IsbListFuncs' for ranges.
*/
Int             IsbRange (
    Obj                 list,
    Int                 pos )
{
    return (pos <= GET_LEN_RANGE(list));
}

Int             IsbvRange (
    Obj                 list,
    Int                 pos )
{
    return 1L;
}


/****************************************************************************
**
*F  Elm0Range(<list>,<pos>) . . . . . . . . . .  select an element of a range
*F  Elm0vRange(<list>,<pos>)  . . . . . . . . .  select an element of a range
**
**  'Elm0Range' returns  the  element  at  the position   <pos> of  the range
**  <list>, or 0   if <list> has   no assigned object  at  <pos>.  It  is the
**  responsibility of the caller to ensure that <pos> is a positive integer.
**
**  'Elm0vRange' does  the same thing  than  'Elm0Range', but  need not check
**  that <pos> is  less than or  equal to the  length of <list>, this is  the
**  responsibility of the caller.
*/
Obj             Elm0Range (
    Obj                 list,
    Int                 pos )
{
    if ( pos <= GET_LEN_RANGE( list ) ) {
        return GET_ELM_RANGE( list, pos );
    }
    else {
        return 0;
    }
}

Obj             Elm0vRange (
    Obj                 list,
    Int                 pos )
{
    return GET_ELM_RANGE( list, pos );
}


/****************************************************************************
**
*F  ElmRange(<list>,<pos>)  . . . . . . . . . .  select an element of a range
**
**  'ElmRange' selects the element at position <pos> of the range <list>.  It
**  is the  responsibility of the  caller to ensure that  <pos> is a positive
**  integer.  An error is signaller  if <pos>  is  larger than the length  of
**  <list>.
**
**  'ElmvRange' does the same thing than 'ElmRange', but  need not check that
**  <pos>   is less than or   equal  to the  length  of  <list>,  this is the
**  responsibility of the caller.
**
**  'ElmRange' is the function in  'ElmListFuncs' for ranges.  'ElmvRange' is
**  the function in 'ElmvListFuncs' for ranges.
*/
Obj             ElmRange (
    Obj                 list,
    Int                 pos )
{
    /* check the position                                                  */
    if ( GET_LEN_RANGE( list ) < pos ) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            (Int)pos, 0L,
            "you can return after assigning a value" );
        return ELM_LIST( list, pos );
    }

    /* return the selected element                                         */
    return GET_ELM_RANGE( list, pos );
}

Obj             ElmvRange (
    Obj                 list,
    Int                 pos )
{
    return GET_ELM_RANGE( list, pos );
}


/****************************************************************************
**
*F  ElmsRange(<list>,<poss>)  . . . . . . . . . select a sublist from a range
**
**  'ElmsRange' returns a new list  containing the elements at the  positions
**  given in the list <poss> from the range <list>.  It is the responsibility
**  of the caller to ensure that  <poss> is dense  and contains only positive
**  integers.  An error  is signalled if an element  of <poss> is larger than
**  the length of <list>.
**
**  'ElmsRange' is the function in 'ElmsListFuncs' for ranges.
*/
Obj             ElmsRange (
    Obj                 list,
    Obj                 poss )
{
    Obj                 elms;           /* selected sublist, result        */
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element from <list>         */
    Int                 lenPoss;        /* length of <positions>           */
    Int                 pos;            /* <position> as integer           */
    Int                 inc;            /* increment in a range            */
    Int                 i;              /* loop variable                   */

    /* general code                                                        */
    if ( ! IS_RANGE(poss) ) {

        /* get the length of <list>                                        */
        lenList = GET_LEN_RANGE( list );

        /* get the length of <positions>                                   */
        lenPoss = LEN_LIST( poss );

        /* make the result list                                            */
        elms = NEW_PLIST( T_PLIST, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );
            if ( lenList < pos ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can return after assigning a value" );
                return ELMS_LIST( list, poss );
            }

            /* select the element                                          */
            elm = GET_ELM_RANGE( list, pos );

            /* assign the element into <elms>                              */
            SET_ELM_PLIST( elms, i, elm );

        }

    }

    /* special code for ranges                                             */
    else {

        /* get the length of <list>                                        */
        lenList = GET_LEN_RANGE( list );

        /* get the length of <positions>, the first elements, and the inc. */
        lenPoss = GET_LEN_RANGE( poss );
        pos = GET_LOW_RANGE( poss );
        inc = GET_INC_RANGE( poss );

        /* check that no <position> is larger than 'LEN_LIST(<list>)'      */
        if ( lenList < pos ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos, 0L,
                "you can return after assigning a value" );
            return ELMS_LIST( list, poss );
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)(pos + (lenPoss-1) * inc), 0L,
                "you can return after assigning a value" );
            return ELMS_LIST( list, poss );
        }

        /* make the result range                                           */
        if ( 0 < inc * GET_INC_RANGE(list) )
            elms = NEW_RANGE_SSORT();
        else
            elms = NEW_RANGE_NSORT();
        SET_LEN_RANGE( elms, lenPoss );
        SET_LOW_RANGE( elms, INT_INTOBJ( GET_ELM_RANGE( list, pos ) ) );
        SET_INC_RANGE( elms, inc * GET_INC_RANGE( list ) );

    }

    /* return the result                                                   */
    return elms;
}


/****************************************************************************
**
*F  AssRange(<list>,<pos>,<val>)  . . . . . . . . . . . . . assign to a range
**
**  'AssRange' assigns the value  <val> to the range  <list> at the  position
**  <pos>.  It  is the responsibility of the  caller to ensure that  <pos> is
**  positive, and that <val> is not 0.
**
**  'AssRange' is the function in 'AssListFuncs' for ranges.
**
**  'AssRange' simply converts the range into a plain list, and then does the
**  same stuff as 'AssPlist'.  This is because a  range is not very likely to
**  stay a range after the assignment.
*/
void            AssRange (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    /* convert the range into a plain list                                 */
    PLAIN_LIST( list );
    RetypeBag( list, T_PLIST );

    /* resize the list if necessary                                        */
    if ( LEN_PLIST( list ) < pos ) {
        GROW_PLIST( list, pos );
        SET_LEN_PLIST( list, pos );
    }

    /* now perform the assignment and return the assigned value            */
    SET_ELM_PLIST( list, pos, val );
    CHANGED_BAG( list );
}

void            AssRangeImm (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    ErrorReturnVoid(
        "Lists Assignment: <list> must be a mutable list",
        0L, 0L,
        "you can return and ignore the assignment" );
}


/****************************************************************************
**
*F  AsssRange(<list>,<poss>,<vals>) . . .  assign several elements to a range
**
**  'AsssRange' assignes the  values  from the list  <vals>  at the positions
**  given in the  list <poss> to the range  <list>.  It is the responsibility
**  of the caller to  ensure that <poss> is dense  and contains only positive
**  integers, that <poss> and <vals> have the same length, and that <vals> is
**  dense.
**
**  'AsssRange' is the function in 'AsssListFuncs' for ranges.
**
**  'AsssRange' simply converts the range to a plain  list  and then does the
**  same stuff as 'AsssPlist'.  This is because a range is not very likely to
**  stay a range after the assignment.
*/
void            AsssRange (
    Obj                 list,
    Obj                 poss,
    Obj                 vals )
{
    /* convert <list> to a plain list                                      */
    PLAIN_LIST( list );
    RetypeBag( list, T_PLIST );

    /* and delegate                                                        */
    ASSS_LIST( list, poss, vals );
}

void            AsssRangeImm (
    Obj                 list,
    Obj                 poss,
    Obj                 val )
{
    ErrorReturnVoid(
        "Lists Assignments: <list> must be a mutable list",
        0L, 0L,
        "you can return and ignore the assignment" );
}


/****************************************************************************
**
*F  IsDenseRange(<list>)  . . . . . . . . dense list test function for ranges
**
**  'IsDenseRange' returns 1, since ranges are always dense.
**
**  'IsDenseRange' is the function in 'IsDenseListFuncs' for ranges.
*/
Int             IsDenseRange (
    Obj                 list )
{
    return 1;
}


/****************************************************************************
**
*F  IsHomogRange(<list>)
*/
Int             IsHomogRange (
    Obj                 list )
{
    return 1;
}


/****************************************************************************
**
*F  IsSSortRange(<list>)
*/
Int             IsSSortRangeNot (
    Obj                 list )
{
    return 0;
}

Int             IsSSortRangeYes (
    Obj                 list )
{
    return 1;
}


/****************************************************************************
**
*F  IsPossRange(<list>) . . . . . . . positions list test function for ranges
**
**  'IsPossRange' returns 1  if the range <list>  is a dense list  containing
**  only positive integers, and 0 otherwise.
**
**  'IsPossRange' is the function in 'IsPossListFuncs' for ranges.
*/
Int             IsPossRange (
    Obj                 list )
{
    /* test if the first element is positive                               */
    if ( GET_LOW_RANGE( list ) <= 0 )
        return 0;

    /* test if the last element is positive                                */
    if ( INT_INTOBJ( GET_ELM_RANGE( list, GET_LEN_RANGE(list) ) ) <= 0 )
        return 0;

    /* otherwise <list> is a positions list                                */
    return 1;
}


/****************************************************************************
**
*F  PosRange(<list>,<val>,<start>)  . . . . position of an element in a range
**
**  'PosRange' returns the position  of the value <val>  in the range  <list>
**  after the first position <start> as a C integer.   0 is returned if <val>
**  is not in the list.
**
**  'PosRange' is the function in 'PosListFuncs' for ranges.
*/
Int             PosRange (
    Obj                 list,
    Obj                 val,
    Int                 start )
{
    Int                 k;              /* position, result                */
    Int                 lenList;        /* length of <list>                */
    Int                 low;            /* first element of <list>         */
    Int                 inc;            /* increment of <list>             */
    Int                 v;              /* numerical value of <val>        */

    /* get the length, the first element, and the increment of <list>      */
    lenList = GET_LEN_RANGE(list);
    low     = GET_LOW_RANGE(list);
    inc     = GET_INC_RANGE(list);

    /* look just beyond the end                                            */
    if ( start == lenList ) {
        k = 0;
    }

    /* look for an integer                                                 */
    else if ( TNUM_OBJ(val) == T_INT ) {
        v = INT_INTOBJ(val);
        if ( 0 < inc
          && low + start * inc <= v && v <= low + (lenList-1) * inc
          && (v - low) % inc == 0 ) {
            k = (v - low) / inc + 1;
        }
        else if ( inc < 0
          && low + (lenList-1) * inc <= v && v <= low + start * inc
          && (v - low) % inc == 0 ) {
            k = (v - low) / inc + 1;
        }
        else {
            k = 0;
        }
    }

    /* for a record compare every entry                                    */
    else if ( TNUM_OBJ(val) == T_PREC ) {
        for ( k = start+1; k <= lenList; k++ ) {
            if ( EQ( INTOBJ_INT( low + (k-1) * inc ), val ) )
                break;
        }
        if ( lenList < k ) {
            k = 0;
        }
    }

    /* otherwise it can not be an element of the range                     */
    else {
        k = 0;
    }

    /* return the position                                                 */
    return k;
}


/****************************************************************************
**
*F  PlainRange(<list>)  . . . . . . . . . . . convert a range to a plain list
**
**  'PlainRange' converts the range <list> to a plain list.
**
**  'PlainRange' is the function in 'PlainListFuncs' for ranges.
*/
void            PlainRange (
    Obj                 list )
{
    Int                 lenList;        /* length of <list>                */
    Int                 low;            /* first element of <list>         */
    Int                 inc;            /* increment of <list>             */
    Int                 i;              /* loop variable                   */

    /* get the length, the first element, and the increment of <list>      */
    lenList = GET_LEN_RANGE( list );
    low     = GET_LOW_RANGE( list );
    inc     = GET_INC_RANGE( list );

    /* change the type of the list, and allocate enough space              */
    RetypeBag( list, IS_MUTABLE_OBJ(list) ? T_PLIST : T_PLIST + IMMUTABLE );
    GROW_PLIST( list, lenList );
    SET_LEN_PLIST( list, lenList );

    /* enter the values in <list>                                          */
    for ( i = 1; i <= lenList; i++ ) {
        SET_ELM_PLIST( list, i, INTOBJ_INT( low + (i-1) * inc ) );
    }
}


/****************************************************************************
**
*F  IsRange(<list>) . . . . . . . . . . . . . . . . test if a list is a range
**
**  'IsRange' returns 1 if the list  with the handle <list>  is a range and 0
**  otherwise.  As a  sideeffect 'IsRange' converts proper ranges represented
**  the ordinary way to the compact representation.
*/
Int             IsRange (
    Obj                 list )
{
    Int                 isRange;        /* result of the test              */
    Int                 len;            /* logical length of list          */
    Int                 low;            /* value of first element of range */
    Int                 inc;            /* increment                       */
    Int                 i;              /* loop variable                   */

    /* if <list> is represented as a range, it is of course a range      */
    if ( TNUM_OBJ(list) == T_RANGE_NSORT
      || TNUM_OBJ(list) == T_RANGE_SSORT ) {
        isRange = 1;
    }

    /* if <list> is not a list, it is not a range                        */
    else if ( ! IS_LIST( list ) ) {
        isRange = 0;
    }

    /* if <list> is the empty list, it is a range by definition          */
    else if ( LEN_LIST(list) == 0 ) {
        isRange = 1;
    }

    /* if <list> is a list with just one integer, it is also a range     */
    else if ( LEN_LIST(list)==1 && TNUM_OBJ(ELMW_LIST(list,1))==T_INT ) {
        isRange = 1;
    }

    /* if the first element is not an integer, it is not a range           */
    else if ( ELMV0_LIST(list,1)==0 || TNUM_OBJ(ELMW_LIST(list,1))!=T_INT ) {
        isRange = 0;
    }

    /* if the second element is not an integer, it is not a range          */
    else if ( ELMV0_LIST(list,2)==0 || TNUM_OBJ(ELMW_LIST(list,2))!=T_INT ) {
        isRange = 0;
    }

    /* if the first and the second element are equal it is also not a range*/
    else if ( ELMW_LIST(list,1) == ELMW_LIST(list,2) ) {
        isRange = 0;
    }

    /* otherwise, test if the elements are consecutive integers            */
    else {

        /* get the logical length of the list                              */
        len = LEN_LIST(list);
        low = INT_INTOBJ( ELMW_LIST( list, 1 ) );
        inc = INT_INTOBJ( ELMW_LIST( list, 2 ) ) - low;

        /* test all entries against the first one                          */
        for ( i = 3;  i <= len;  i++ ) {
            if ( ELMV0_LIST(list,i) != INTOBJ_INT( low + (i-1) * inc ) )
                break;
        }

        /* if <list> is a range, convert to the compact representation   */
        isRange = (len < i);
        if ( isRange ) {
            if ( IS_MUTABLE_OBJ(list) ) {
                RetypeBag( list, (0 < inc ? T_RANGE_SSORT : T_RANGE_NSORT) );
            }
            else {
                RetypeBag( list, (0 < inc ? T_RANGE_SSORT : T_RANGE_NSORT)
                                 + IMMUTABLE );
            }
            ResizeBag( list, 3 * sizeof(Obj) );
            SET_LEN_RANGE( list, len );
            SET_LOW_RANGE( list, low );
            SET_INC_RANGE( list, inc );
        }

    }

    /* return the result of the test                                       */
    return isRange;
}


/****************************************************************************
**
*F  FuncIsRange(<self>,<obj>) . . . . . . . . . . . . . . .  test for a range
**
**  'FuncIsRange' implements the internal function 'IsRange'.
**
**  'IsRange( <obj> )'
**
**  'IsRange' returns 'true' if <obj>, which may be an object of any type, is
**  a range and 'false' otherwise.  A range is a list without holes such that
**  the elements are  consecutive integers.
*/
Obj             IsRangeFilt;

Obj             IsRangeHandler (
    Obj                 self,
    Obj                 obj )
{
    /* let 'IsRange' do the work for lists                                 */
    return IsRange(obj) ? True : False;
}


/****************************************************************************
**

*F  InitRange() . . . . . . . . . . . . . . . .  initialize the range package
**
**  'InitRange' initializes the range package.
*/
void            InitRange ( void )
{
    /* install the marking functions                                       */
    InfoBags[           T_RANGE_NSORT                     ].name
        = "list (range)";
    InitMarkFuncBags(   T_RANGE_NSORT                     , MarkAllSubBags );
    InfoBags[           T_RANGE_NSORT +IMMUTABLE          ].name
        = "list (range)";
    InitMarkFuncBags(   T_RANGE_NSORT +IMMUTABLE          , MarkAllSubBags );
    InfoBags[           T_RANGE_SSORT                     ].name
        = "list (range)";
    InitMarkFuncBags(   T_RANGE_SSORT                     , MarkAllSubBags );
    InfoBags[           T_RANGE_SSORT +IMMUTABLE          ].name
        = "list (range)";
    InitMarkFuncBags(   T_RANGE_SSORT +IMMUTABLE          , MarkAllSubBags );
    InfoBags[           T_RANGE_NSORT            +COPYING ].name
        = "list (range), copied";
    InitMarkFuncBags(   T_RANGE_NSORT            +COPYING , MarkAllSubBags );
    InfoBags[           T_RANGE_NSORT +IMMUTABLE +COPYING ].name
        = "list (range), copied";
    InitMarkFuncBags(   T_RANGE_NSORT +IMMUTABLE +COPYING , MarkAllSubBags );
    InfoBags[           T_RANGE_SSORT            +COPYING ].name
        = "list (range), copied";
    InitMarkFuncBags(   T_RANGE_SSORT            +COPYING , MarkAllSubBags );
    InfoBags[           T_RANGE_SSORT +IMMUTABLE +COPYING ].name
        = "list (range), copied";
    InitMarkFuncBags(   T_RANGE_SSORT +IMMUTABLE +COPYING , MarkAllSubBags );


    /* install the kind function                                           */
    ImportGVarFromLibrary( "TYPE_RANGE_NSORT_MUTABLE",
                           &TYPE_RANGE_NSORT_MUTABLE );

    ImportGVarFromLibrary( "TYPE_RANGE_SSORT_MUTABLE",
                           &TYPE_RANGE_SSORT_MUTABLE );

    ImportGVarFromLibrary( "TYPE_RANGE_NSORT_IMMUTABLE",
                           &TYPE_RANGE_NSORT_IMMUTABLE );

    ImportGVarFromLibrary( "TYPE_RANGE_SSORT_IMMUTABLE",
                           &TYPE_RANGE_SSORT_IMMUTABLE );

    TypeObjFuncs[ T_RANGE_NSORT            ] = TypeRangeNSortMutable;
    TypeObjFuncs[ T_RANGE_NSORT +IMMUTABLE ] = TypeRangeNSortImmutable;
    TypeObjFuncs[ T_RANGE_SSORT            ] = TypeRangeSSortMutable;
    TypeObjFuncs[ T_RANGE_SSORT +IMMUTABLE ] = TypeRangeSSortImmutable;

    /* install the copy methods                                            */
    CopyObjFuncs [ T_RANGE_NSORT                     ] = CopyRange;
    CopyObjFuncs [ T_RANGE_NSORT            +COPYING ] = CopyRangeCopy;
    CopyObjFuncs [ T_RANGE_NSORT +IMMUTABLE          ] = CopyRange;
    CopyObjFuncs [ T_RANGE_NSORT +IMMUTABLE +COPYING ] = CopyRangeCopy;
    CopyObjFuncs [ T_RANGE_SSORT                     ] = CopyRange;
    CopyObjFuncs [ T_RANGE_SSORT            +COPYING ] = CopyRangeCopy;
    CopyObjFuncs [ T_RANGE_SSORT +IMMUTABLE          ] = CopyRange;
    CopyObjFuncs [ T_RANGE_SSORT +IMMUTABLE +COPYING ] = CopyRangeCopy;
    CleanObjFuncs[ T_RANGE_NSORT                     ] = CleanRange;
    CleanObjFuncs[ T_RANGE_NSORT            +COPYING ] = CleanRangeCopy;
    CleanObjFuncs[ T_RANGE_NSORT +IMMUTABLE          ] = CleanRange;
    CleanObjFuncs[ T_RANGE_NSORT +IMMUTABLE +COPYING ] = CleanRangeCopy;
    CleanObjFuncs[ T_RANGE_SSORT                     ] = CleanRange;
    CleanObjFuncs[ T_RANGE_SSORT            +COPYING ] = CleanRangeCopy;
    CleanObjFuncs[ T_RANGE_SSORT +IMMUTABLE          ] = CleanRange;
    CleanObjFuncs[ T_RANGE_SSORT +IMMUTABLE +COPYING ] = CleanRangeCopy;

    /* install the print method                                            */
    PrintObjFuncs[ T_RANGE_NSORT            ] = PrintRange;
    PrintObjFuncs[ T_RANGE_NSORT +IMMUTABLE ] = PrintRange;
    PrintObjFuncs[ T_RANGE_SSORT            ] = PrintRange;
    PrintObjFuncs[ T_RANGE_SSORT +IMMUTABLE ] = PrintRange;

    /* install the comparison methods                                      */
    EqFuncs[ T_RANGE_NSORT ][ T_RANGE_NSORT ] = EqRange;
    EqFuncs[ T_RANGE_NSORT ][ T_RANGE_SSORT ] = EqRange;
    EqFuncs[ T_RANGE_SSORT ][ T_RANGE_NSORT ] = EqRange;
    EqFuncs[ T_RANGE_SSORT ][ T_RANGE_SSORT ] = EqRange;
    LtFuncs[ T_RANGE_NSORT ][ T_RANGE_NSORT ] = LtRange;
    LtFuncs[ T_RANGE_NSORT ][ T_RANGE_SSORT ] = LtRange;
    LtFuncs[ T_RANGE_SSORT ][ T_RANGE_NSORT ] = LtRange;
    LtFuncs[ T_RANGE_SSORT ][ T_RANGE_SSORT ] = LtRange;

    /* install the list functions in the tables                            */
    LenListFuncs    [ T_RANGE_NSORT            ] = LenRange;
    LenListFuncs    [ T_RANGE_NSORT +IMMUTABLE ] = LenRange;
    LenListFuncs    [ T_RANGE_SSORT            ] = LenRange;
    LenListFuncs    [ T_RANGE_SSORT +IMMUTABLE ] = LenRange;
    IsbListFuncs    [ T_RANGE_NSORT            ] = IsbRange;
    IsbListFuncs    [ T_RANGE_NSORT +IMMUTABLE ] = IsbRange;
    IsbListFuncs    [ T_RANGE_SSORT            ] = IsbRange;
    IsbListFuncs    [ T_RANGE_SSORT +IMMUTABLE ] = IsbRange;
    IsbvListFuncs   [ T_RANGE_NSORT            ] = IsbvRange;
    IsbvListFuncs   [ T_RANGE_NSORT +IMMUTABLE ] = IsbvRange;
    IsbvListFuncs   [ T_RANGE_SSORT            ] = IsbvRange;
    IsbvListFuncs   [ T_RANGE_SSORT +IMMUTABLE ] = IsbvRange;
    Elm0ListFuncs   [ T_RANGE_NSORT            ] = Elm0Range;
    Elm0ListFuncs   [ T_RANGE_NSORT +IMMUTABLE ] = Elm0Range;
    Elm0ListFuncs   [ T_RANGE_SSORT            ] = Elm0Range;
    Elm0ListFuncs   [ T_RANGE_SSORT +IMMUTABLE ] = Elm0Range;
    Elm0vListFuncs  [ T_RANGE_NSORT            ] = Elm0vRange;
    Elm0vListFuncs  [ T_RANGE_NSORT +IMMUTABLE ] = Elm0vRange;
    Elm0vListFuncs  [ T_RANGE_SSORT            ] = Elm0vRange;
    Elm0vListFuncs  [ T_RANGE_SSORT +IMMUTABLE ] = Elm0vRange;
    ElmListFuncs    [ T_RANGE_NSORT            ] = ElmRange;
    ElmListFuncs    [ T_RANGE_NSORT +IMMUTABLE ] = ElmRange;
    ElmListFuncs    [ T_RANGE_SSORT            ] = ElmRange;
    ElmListFuncs    [ T_RANGE_SSORT +IMMUTABLE ] = ElmRange;
    ElmvListFuncs   [ T_RANGE_NSORT            ] = ElmvRange;
    ElmvListFuncs   [ T_RANGE_NSORT +IMMUTABLE ] = ElmvRange;
    ElmvListFuncs   [ T_RANGE_SSORT            ] = ElmvRange;
    ElmvListFuncs   [ T_RANGE_SSORT +IMMUTABLE ] = ElmvRange;
    ElmwListFuncs   [ T_RANGE_NSORT            ] = ElmvRange;
    ElmwListFuncs   [ T_RANGE_NSORT +IMMUTABLE ] = ElmvRange;
    ElmwListFuncs   [ T_RANGE_SSORT            ] = ElmvRange;
    ElmwListFuncs   [ T_RANGE_SSORT +IMMUTABLE ] = ElmvRange;
    ElmsListFuncs   [ T_RANGE_NSORT            ] = ElmsRange;
    ElmsListFuncs   [ T_RANGE_NSORT +IMMUTABLE ] = ElmsRange;
    ElmsListFuncs   [ T_RANGE_SSORT            ] = ElmsRange;
    ElmsListFuncs   [ T_RANGE_SSORT +IMMUTABLE ] = ElmsRange;
    AssListFuncs    [ T_RANGE_NSORT            ] = AssRange;
    AssListFuncs    [ T_RANGE_NSORT +IMMUTABLE ] = AssRangeImm;
    AssListFuncs    [ T_RANGE_SSORT            ] = AssRange;
    AssListFuncs    [ T_RANGE_SSORT +IMMUTABLE ] = AssRangeImm;
    AsssListFuncs   [ T_RANGE_NSORT            ] = AsssRange;
    AsssListFuncs   [ T_RANGE_NSORT +IMMUTABLE ] = AsssRangeImm;
    AsssListFuncs   [ T_RANGE_SSORT            ] = AsssRange;
    AsssListFuncs   [ T_RANGE_SSORT +IMMUTABLE ] = AsssRangeImm;
    IsDenseListFuncs[ T_RANGE_NSORT            ] = IsDenseRange;
    IsDenseListFuncs[ T_RANGE_NSORT +IMMUTABLE ] = IsDenseRange;
    IsDenseListFuncs[ T_RANGE_SSORT            ] = IsDenseRange;
    IsDenseListFuncs[ T_RANGE_SSORT +IMMUTABLE ] = IsDenseRange;
    IsHomogListFuncs[ T_RANGE_NSORT            ] = IsHomogRange;
    IsHomogListFuncs[ T_RANGE_NSORT +IMMUTABLE ] = IsHomogRange;
    IsHomogListFuncs[ T_RANGE_SSORT            ] = IsHomogRange;
    IsHomogListFuncs[ T_RANGE_SSORT +IMMUTABLE ] = IsHomogRange;
    IsSSortListFuncs[ T_RANGE_NSORT            ] = IsSSortRangeNot;
    IsSSortListFuncs[ T_RANGE_NSORT +IMMUTABLE ] = IsSSortRangeNot;
    IsSSortListFuncs[ T_RANGE_SSORT            ] = IsSSortRangeYes;
    IsSSortListFuncs[ T_RANGE_SSORT +IMMUTABLE ] = IsSSortRangeYes;
    IsPossListFuncs [ T_RANGE_NSORT            ] = IsPossRange;
    IsPossListFuncs [ T_RANGE_NSORT +IMMUTABLE ] = IsPossRange;
    IsPossListFuncs [ T_RANGE_SSORT            ] = IsPossRange;
    IsPossListFuncs [ T_RANGE_SSORT +IMMUTABLE ] = IsPossRange;
    PosListFuncs    [ T_RANGE_NSORT            ] = PosRange;
    PosListFuncs    [ T_RANGE_NSORT +IMMUTABLE ] = PosRange;
    PosListFuncs    [ T_RANGE_SSORT            ] = PosRange;
    PosListFuncs    [ T_RANGE_SSORT +IMMUTABLE ] = PosRange;
    PlainListFuncs  [ T_RANGE_NSORT            ] = PlainRange;
    PlainListFuncs  [ T_RANGE_NSORT +IMMUTABLE ] = PlainRange;
    PlainListFuncs  [ T_RANGE_SSORT            ] = PlainRange;
    PlainListFuncs  [ T_RANGE_SSORT +IMMUTABLE ] = PlainRange;

    /* install the internal function                                       */
    InitHandlerFunc( IsRangeHandler, "IsRange" );
    IsRangeFilt = NewFilterC( "IsRange", 1L, "obj",
                                IsRangeHandler );
    AssGVar( GVarName( "IS_RANGE" ), IsRangeFilt );
}


/****************************************************************************
**

*E  range.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
