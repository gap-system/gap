/****************************************************************************
**
*W  range.c                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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
**  'IsPossRange', 'PrintRange', 'EqRange', and  'LtRange'.
**  They  are the  functions required by  the generic   lists package.  Using
**  these functions the other parts of the {\GAP} kernel can access or modify
**  ranges without actually being aware that they are dealing with a range.
**
**  The  third part consists  ...
*/

#include "range.h"

#include "ariths.h"
#include "bool.h"
#include "error.h"
#include "gaputils.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "saveload.h"


/****************************************************************************
**
*F  TypeRangeNSort( <range> ) . . . . . . . . . . . . . . . . type of a range
**
**  'TypeRangeNSort' is the  function in 'TypeObjFuncs' for ranges which are
**  not strictly sorted.
*/
Obj TYPE_RANGE_NSORT_IMMUTABLE;
Obj TYPE_RANGE_NSORT_MUTABLE;

Obj TypeRangeNSort(Obj list)
{
    return IS_MUTABLE_PLAIN_OBJ(list) ? TYPE_RANGE_NSORT_MUTABLE
                                      : TYPE_RANGE_NSORT_IMMUTABLE;
}

    
/****************************************************************************
**
*F  TypeRangeSSort( <range> ) . . . . . . . . . . . . . . . . type of a range
**
**  'TypeRangeSSort' is the function in 'TypeObjFuncs' for ranges which are
**  strictly sorted.
*/
Obj TYPE_RANGE_SSORT_IMMUTABLE;
Obj TYPE_RANGE_SSORT_MUTABLE;

Obj TypeRangeSSort(Obj list)
{
    return IS_MUTABLE_PLAIN_OBJ(list) ? TYPE_RANGE_SSORT_MUTABLE
                                      : TYPE_RANGE_SSORT_IMMUTABLE;
}


#if !defined(USE_THREADSAFE_COPYING)

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
    ADDR_OBJ(copy)[0] = CONST_ADDR_OBJ(list)[0];

    /* leave a forwarding pointer                                          */
    ADDR_OBJ(list)[0] = copy;
    CHANGED_BAG( list );

    /* now it is copied                                                    */
    RetypeBag( list, TNUM_OBJ(list) + COPYING );

    /* copy the subvalues                                                  */
    ADDR_OBJ(copy)[1] = CONST_ADDR_OBJ(list)[1];
    ADDR_OBJ(copy)[2] = CONST_ADDR_OBJ(list)[2];

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
    ADDR_OBJ(list)[0] = CONST_ADDR_OBJ( CONST_ADDR_OBJ(list)[0] )[0];

    /* now it is cleaned                                                   */
    RetypeBag( list, TNUM_OBJ(list) - COPYING );
}

#endif // !defined(USE_THREADSAFE_COPYING)


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
            "you can 'return;' after assigning a value" );
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
            Obj p = ELMW_LIST(poss, i);
            while (!IS_INTOBJ(p)) {
                p = ErrorReturnObj("List Elements: position is too large for "
                                   "this type of list",
                                   0L, 0L,
                                   "you can supply a new position <pos> via "
                                   "'return <pos>;'");
            }
            pos = INT_INTOBJ(p);

            /* select the element                                          */
            if ( lenList < pos ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can 'return;' after assigning a value" );
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
                "you can 'return;' after assigning a value" );
            return ELMS_LIST( list, poss );
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)(pos + (lenPoss-1) * inc), 0L,
                "you can 'return;' after assigning a value" );
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
**  after the first position <start> as a GAP integer. Fail is returned if <val>
**  is not in the list.
**
**  'PosRange' is the function in 'PosListFuncs' for ranges.
*/
Obj             PosRange (
    Obj                 list,
    Obj                 val,
    Obj                 start )
{
    Int                 k;              /* position, result                */
    Int                 lenList;        /* length of <list>                */
    Int                 low;            /* first element of <list>         */
    Int                 inc;            /* increment of <list>             */
    Int                 v;              /* numerical value of <val>        */
    Int    istart;

    /* if the starting position is too big to be a small int
       then there can't be anything to find */
    if (!IS_INTOBJ(start))
      return Fail;
    
    istart = INT_INTOBJ(start);
    /* get the length, the first element, and the increment of <list>      */
    lenList = GET_LEN_RANGE(list);
    low     = GET_LOW_RANGE(list);
    inc     = GET_INC_RANGE(list);

    /* look just beyond the end                                            */
    if ( istart == lenList ) {
        k = 0;
    }

    /* look for an integer                                                 */
    else if ( IS_INTOBJ(val) ) {
        v = INT_INTOBJ(val);
        if ( 0 < inc
          && low + istart * inc <= v && v <= low + (lenList-1) * inc
          && (v - low) % inc == 0 ) {
            k = (v - low) / inc + 1;
        }
        else if ( inc < 0
          && low + (lenList-1) * inc <= v && v <= low + istart * inc
          && (v - low) % inc == 0 ) {
            k = (v - low) / inc + 1;
        }
        else {
            k = 0;
        }
    }

    /* otherwise it can not be an element of the range                     */
    else {
        k = 0;
    }

    /* return the position                                                 */
    return k == 0 ? Fail : INTOBJ_INT(k);
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
**  otherwise.  As a  side effect 'IsRange' converts proper ranges represented
**  the ordinary way to the compact representation.
*/
Obj IsRangeFilt;

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

    /* if <list> is not a list, it is not a range at the moment        */
    else if ( ! IS_SMALL_LIST( list ) ) {
       /* isRange = 0; */
       isRange = (DoFilter(IsRangeFilt, list) == True);
    }

    /* if <list> is the empty list, it is a range by definition          */
    else if ( LEN_LIST(list) == 0 ) {
        isRange = 1;
    }

    /* if <list> is a list with just one integer, it is also a range     */
    else if ( LEN_LIST(list)==1 && IS_INTOBJ(ELMW_LIST(list,1)) ) {
        isRange = 1;
    }

    /* if the first element is not an integer, it is not a range           */
    else if ( ELMV0_LIST(list,1)==0 || !IS_INTOBJ(ELMW_LIST(list,1)) ) {
        isRange = 0;
    }

    /* if the second element is not an integer, it is not a range          */
    else if ( ELMV0_LIST(list,2)==0 || !IS_INTOBJ(ELMW_LIST(list,2)) ) {
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
Obj FuncIS_RANGE (
    Obj                 self,
    Obj                 obj )
{
    /* let 'IsRange' do the work for lists                                 */
    return IsRange(obj) ? True : False;
}


/****************************************************************************
**
*F  SaveRange( <range> )
**
*/

void SaveRange( Obj range )
{
  SaveSubObj(CONST_ADDR_OBJ(range)[0]); /* length */
  SaveSubObj(CONST_ADDR_OBJ(range)[1]); /* base */
  SaveSubObj(CONST_ADDR_OBJ(range)[2]); /* increment */
}

/****************************************************************************
**
*F  LoadRange( <range> )
**
*/

void LoadRange( Obj range )
{
  ADDR_OBJ(range)[0] = LoadSubObj(); /* length */
  ADDR_OBJ(range)[1] = LoadSubObj(); /* base */
  ADDR_OBJ(range)[2] = LoadSubObj(); /* increment */
}


/****************************************************************************
**
*F  Range2Check( <first>, <last> )  . . . . . . . . . . . . . construct range
*/
Obj Range2Check (
    Obj                 first,
    Obj                 last )
{
    Obj                 range;
    Int                 f, l;
    if ( ! IS_INTOBJ(first) ) {
        ErrorQuit(
            "Range: <first> must be a positive small integer (not a %s)",
            (Int)TNAM_OBJ(first), 0L );
    }
    f = INT_INTOBJ(first);
    if ( ! IS_INTOBJ(last) ) {
        ErrorQuit(
            "Range: <last> must be a positive small integer (not a %s)",
            (Int)TNAM_OBJ(last), 0L );
    }
    l = INT_INTOBJ(last);
    if ( f > l ) {
        range = NEW_PLIST( T_PLIST, 0 );
    }
    else if ( f == l ) {
        range = NEW_PLIST( T_PLIST, 1 );
        SET_LEN_PLIST( range, 1 );
        SET_ELM_PLIST( range, 1, first );
    }
    else {
        range = NEW_RANGE_SSORT();
        SET_LEN_RANGE( range, (l-f) + 1 );
        SET_LOW_RANGE( range, f );
        SET_INC_RANGE( range, 1 );
    }
    return range;
}


/****************************************************************************
**
*F  Range3Check( <first>, <second>, <last> )  . . . . . . . . construct range
*/
Obj Range3Check (
    Obj                 first,
    Obj                 second,
    Obj                 last )
{
    Obj                 range;
    Int                 f, i, l;
    if ( ! IS_INTOBJ(first) ) {
        ErrorQuit(
            "Range: <first> must be a positive small integer (not a %s)",
            (Int)TNAM_OBJ(first), 0L );
    }
    f = INT_INTOBJ(first);
    if ( ! IS_INTOBJ(second) ) {
        ErrorQuit(
            "Range: <second> must be a positive small integer (not a %s)",
            (Int)TNAM_OBJ(second), 0L );
    }
    if ( first == second ) {
        ErrorQuit(
            "Range: <second> must not be equal to <first> (%d)",
            (Int)INT_INTOBJ(first), 0L );
    }
    i = INT_INTOBJ(second) - f;
    if ( ! IS_INTOBJ(last) ) {
        ErrorQuit(
            "Range: <last> must be a positive small integer (not a %s)",
            (Int)TNAM_OBJ(last), 0L );
    }
    l = INT_INTOBJ(last);
    if ( (l - f) % i != 0 ) {
        ErrorQuit(
            "Range: <last>-<first> (%d) must be divisible by <inc> (%d)",
            (Int)(l - f), (Int)i );
    }
    if ( (0 < i && f > l) || (i < 0 && f < l) ) {
        range = NEW_PLIST( T_PLIST, 0 );
    }
    else if ( f == l ) {
        range = NEW_PLIST( T_PLIST, 1 );
        SET_LEN_PLIST( range, 1 );
        SET_ELM_PLIST( range, 1, first );
    }
    else {
        if ( 0 < i )
            range = NEW_RANGE_SSORT();
        else
            range = NEW_RANGE_NSORT();
        SET_LEN_RANGE( range, (l - f) / i + 1 );
        SET_LOW_RANGE( range, f );
        SET_INC_RANGE( range, i );
    }
    return range;
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * GAP level functions  * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FuncIS_RANGE_REP( <self>, <obj> ) . . . . . test if value is in range rep
*/
Obj IsRangeRepFilt;

Obj FuncIS_RANGE_REP (
    Obj                 self,
    Obj                 obj )
{
    return (IS_RANGE( obj ) ? True : False);
}

/****************************************************************************
**
*F  MakeImmutableRange( <range> )
**
*/

void MakeImmutableRange( Obj range )
{
  RetypeBag( range, IMMUTABLE_TNUM(TNUM_OBJ(range)));
}

/****************************************************************************
**
*F  FuncINTER_RANGE( <range1>, <range2> )
**
*/

static Int egcd (Int a, Int b, Int *lastx, Int *lasty)
{
  Int x = 0, y = 1;
  *lastx = 1; *lasty = 0;

  while (b != 0) {
    Int t, q;
    t = b; q = a / b; b = a % b; a = t;
    if (lastx) { t = x; x = *lastx - q*x; *lastx = t; }
    if (lasty) { t = y; y = *lasty - q*y; *lasty = t; }
  }
  return a;
} /* returns g=gcd(a,b), with lastx*a+lasty*b = g */

Obj FuncINTER_RANGE( Obj self, Obj r1, Obj r2)
{
  Int low1, low2, inc1, inc2, lowi, inci, g, x, y;
  UInt len1, len2, leni;
  
  low1 = GET_LOW_RANGE(r1);
  low2 = GET_LOW_RANGE(r2);
  inc1 = GET_INC_RANGE(r1);
  inc2 = GET_INC_RANGE(r2);
  len1 = GET_LEN_RANGE(r1);
  len2 = GET_LEN_RANGE(r2);

  if (inc1 < 0)
    {
      low1 = low1 + (len1-1)*inc1;
      inc1 = -inc1;
    }
  if (inc2 < 0)
    {
      low2 = low2 + (len2-1)*inc2;
      inc2 = -inc2;
    }

  if (low1 > low2)
    {
      Int t;
      UInt ut;
      t = low1; low1 = low2; low2 = t;
      t = inc1; inc1 = inc2; inc2 = t;
      ut = len1; len1 = len2; len2 = ut;
    }

  g = egcd(inc1, inc2, &x, &y);

  inci = (inc1 / g) * inc2;

  if (inci / inc2 != inc1 / g) /* overflow */
    goto empty_range;

  if ((low2 - low1) % g) /* ranges are disjoint */
    goto empty_range;

  x = (-y * ((low2 - low1) / g)) % (inc1 / g);
  if (x < 0)
    x += inc1/g;
  lowi = low2 + inc2 * x;

  x = (low1 + (len1-1)*inc1 - lowi);
  y = (low2 + (len2-1)*inc2 - lowi);
  if (x < 0 || y < 0)
    goto empty_range;
  if (x > y)
    leni = 1 + y / inci;
  else
    leni = 1 + x / inci;
  
  SET_LOW_RANGE(r1,lowi);
  SET_LEN_RANGE(r1,leni);
  SET_INC_RANGE(r1,inci);
  return (Obj)0;

 empty_range:
  RetypeBag(r1, T_PLIST_EMPTY);
  ResizeBag(r1,sizeof(Obj));
  SET_LEN_PLIST(r1, 0L);
  return (Obj) 0;
}
/* torture:
a := [-10..10];; INTER_RANGE(a,[-10..10]); a;
a := [-10..10];; INTER_RANGE(a,[-11..10]); a;
a := [-10..10];; INTER_RANGE(a,[-10..11]); a;
a := [-10..10];; INTER_RANGE(a,[-11..9]); a;
a := [-10..10];; INTER_RANGE(a,[-9..11]); a;
a := [-10..10];; INTER_RANGE(a,[-21,-18..21]); a;
a := [-10..10];; INTER_RANGE(a,[-6,-3..21]); a;
a := [-10..10];; INTER_RANGE(a,[-21,-18..6]); a;
a := [-10,-7..20];; INTER_RANGE(a,[-21,-18..6]); a;
a := [-9,-6..21];; INTER_RANGE(a,[-21,-18..6]); a;
a := [-12,-10..20];; INTER_RANGE(a,[-21,-18..6]); a;
a := [-15,-12..3];; INTER_RANGE(a,[-21,-18..6]); a;
a := [-12,-9..3];; INTER_RANGE(a,[-21,-18..6]); a;
a := [-9,-6..3];; INTER_RANGE(a,[-21,-18..6]); a;
a := [-9,-3..3];; INTER_RANGE(a,[-21,-18..6]); a;
a := [-9,-5..3];; INTER_RANGE(a,[-21,-18..6]); a;
*/    

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_RANGE_NSORT,                     "list (range,nsort)"            },
  { T_RANGE_NSORT +IMMUTABLE,          "list (range,nsort,imm)"        },
  { T_RANGE_SSORT,                     "list (range,ssort)"            },
  { T_RANGE_SSORT +IMMUTABLE,          "list (range,ssort,imm)"        },
#if !defined(USE_THREADSAFE_COPYING)
  { T_RANGE_NSORT            +COPYING, "list (range,nsort,copied)"     },
  { T_RANGE_NSORT +IMMUTABLE +COPYING, "list (range,nsort,imm,copied)" },
  { T_RANGE_SSORT            +COPYING, "list (range,ssort,copied)"     },
  { T_RANGE_SSORT +IMMUTABLE +COPYING, "list (range,ssort,imm,copied)" },
#endif
  { -1,                                ""                              }
};


/****************************************************************************
**
*V  ClearFiltsTab . . . . . . . . . . . . . . . . . . . .  clear filter tnums
*/
static Int ClearFiltsTab [] = {
    T_RANGE_NSORT,           T_RANGE_NSORT,
    T_RANGE_SSORT,           T_RANGE_SSORT,
    -1,                      -1
};


/****************************************************************************
**
*V  HasFiltTab  . . . . . . . . . . . . . . . . . . . . .  tester filter tnum
*/
static Int HasFiltTab [] = {

    // nsort range
    T_RANGE_NSORT,              FN_IS_DENSE,    1,
    T_RANGE_NSORT,              FN_IS_NDENSE,   0,
    T_RANGE_NSORT,              FN_IS_HOMOG,    1,
    T_RANGE_NSORT,              FN_IS_NHOMOG,   0,
    T_RANGE_NSORT,              FN_IS_TABLE,    0,
    T_RANGE_NSORT,              FN_IS_RECT,     0,
    T_RANGE_NSORT,              FN_IS_SSORT,    0,
    T_RANGE_NSORT,              FN_IS_NSORT,    1,

    // ssort range
    T_RANGE_SSORT,              FN_IS_DENSE,    1,
    T_RANGE_SSORT,              FN_IS_NDENSE,   0,
    T_RANGE_SSORT,              FN_IS_HOMOG,    1,
    T_RANGE_SSORT,              FN_IS_NHOMOG,   0,
    T_RANGE_SSORT,              FN_IS_TABLE,    0,
    T_RANGE_SSORT,              FN_IS_RECT,     0,
    T_RANGE_SSORT,              FN_IS_SSORT,    1,
    T_RANGE_SSORT,              FN_IS_NSORT,    0,

    -1,                         -1,             -1
};


/****************************************************************************
**
*V  SetFiltTab  . . . . . . . . . . . . . . . . . . . . .  setter filter tnum
*/
static Int SetFiltTab [] = {

    // nsort range
    T_RANGE_NSORT,              FN_IS_DENSE,    T_RANGE_NSORT,
    T_RANGE_NSORT,              FN_IS_NDENSE,   -1,
    T_RANGE_NSORT,              FN_IS_HOMOG,    T_RANGE_NSORT,
    T_RANGE_NSORT,              FN_IS_NHOMOG,   -1,
    T_RANGE_NSORT,              FN_IS_TABLE,    -1,
    T_RANGE_NSORT,              FN_IS_RECT,     -1,
    T_RANGE_NSORT,              FN_IS_SSORT,    -1,
    T_RANGE_NSORT,              FN_IS_NSORT,    T_RANGE_NSORT,

    // ssort range
    T_RANGE_SSORT,              FN_IS_DENSE,    T_RANGE_SSORT,
    T_RANGE_SSORT,              FN_IS_NDENSE,   -1,
    T_RANGE_SSORT,              FN_IS_HOMOG,    T_RANGE_SSORT,
    T_RANGE_SSORT,              FN_IS_NHOMOG,   -1,
    T_RANGE_SSORT,              FN_IS_TABLE,    -1,
    T_RANGE_SSORT,              FN_IS_RECT,     -1,
    T_RANGE_SSORT,              FN_IS_SSORT,    T_RANGE_SSORT,
    T_RANGE_SSORT,              FN_IS_NSORT,    -1,

    -1,                         -1,             -1

};


/****************************************************************************
**
*V  ResetFiltTab  . . . . . . . . . . . . . . . . . . .  unsetter filter tnum
*/
static Int ResetFiltTab [] = {

    // nsort range
    T_RANGE_NSORT,              FN_IS_DENSE,    T_RANGE_NSORT,
    T_RANGE_NSORT,              FN_IS_NDENSE,   T_RANGE_NSORT,
    T_RANGE_NSORT,              FN_IS_HOMOG,    T_RANGE_NSORT,
    T_RANGE_NSORT,              FN_IS_NHOMOG,   T_RANGE_NSORT,
    T_RANGE_NSORT,              FN_IS_TABLE,    T_RANGE_NSORT,
    T_RANGE_NSORT,              FN_IS_RECT,     T_RANGE_NSORT,
    T_RANGE_NSORT,              FN_IS_SSORT,    T_RANGE_NSORT,
    T_RANGE_NSORT,              FN_IS_NSORT,    T_RANGE_NSORT,

    // ssort range
    T_RANGE_SSORT,              FN_IS_DENSE,    T_RANGE_SSORT,
    T_RANGE_SSORT,              FN_IS_NDENSE,   T_RANGE_SSORT,
    T_RANGE_SSORT,              FN_IS_HOMOG,    T_RANGE_SSORT,
    T_RANGE_SSORT,              FN_IS_NHOMOG,   T_RANGE_SSORT,
    T_RANGE_SSORT,              FN_IS_TABLE,    T_RANGE_SSORT,
    T_RANGE_SSORT,              FN_IS_RECT,     T_RANGE_SSORT,
    T_RANGE_SSORT,              FN_IS_SSORT,    T_RANGE_SSORT,
    T_RANGE_SSORT,              FN_IS_NSORT,    T_RANGE_SSORT,

    -1,                         -1,             -1

};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILTER(IS_RANGE, "obj", &IsRangeFilt),
    GVAR_FILTER(IS_RANGE_REP, "obj", &IsRangeRepFilt),
    { 0, 0, 0, 0, 0 }

};

/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(INTER_RANGE, 2, "range1, range2"),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    /* GASMAN marking functions and GASMAN names                           */
    InitBagNamesFromTable( BagNames );

    InitMarkFuncBags(   T_RANGE_NSORT                     , MarkAllSubBags );
    InitMarkFuncBags(   T_RANGE_NSORT +IMMUTABLE          , MarkAllSubBags );
    InitMarkFuncBags(   T_RANGE_SSORT                     , MarkAllSubBags );
    InitMarkFuncBags(   T_RANGE_SSORT +IMMUTABLE          , MarkAllSubBags );
#if !defined(USE_THREADSAFE_COPYING)
    InitMarkFuncBags(   T_RANGE_NSORT            +COPYING , MarkAllSubBags );
    InitMarkFuncBags(   T_RANGE_NSORT +IMMUTABLE +COPYING , MarkAllSubBags );
    InitMarkFuncBags(   T_RANGE_SSORT            +COPYING , MarkAllSubBags );
    InitMarkFuncBags(   T_RANGE_SSORT +IMMUTABLE +COPYING , MarkAllSubBags );
#endif

#ifdef HPCGAP
    /* Make immutable bags public                                          */
    MakeBagTypePublic( T_RANGE_NSORT + IMMUTABLE );
    MakeBagTypePublic( T_RANGE_SSORT + IMMUTABLE );
#endif

    /* install the type function                                           */
    ImportGVarFromLibrary( "TYPE_RANGE_NSORT_MUTABLE",
                           &TYPE_RANGE_NSORT_MUTABLE );

    ImportGVarFromLibrary( "TYPE_RANGE_SSORT_MUTABLE",
                           &TYPE_RANGE_SSORT_MUTABLE );

    ImportGVarFromLibrary( "TYPE_RANGE_NSORT_IMMUTABLE",
                           &TYPE_RANGE_NSORT_IMMUTABLE );

    ImportGVarFromLibrary( "TYPE_RANGE_SSORT_IMMUTABLE",
                           &TYPE_RANGE_SSORT_IMMUTABLE );

    TypeObjFuncs[ T_RANGE_NSORT            ] = TypeRangeNSort;
    TypeObjFuncs[ T_RANGE_NSORT +IMMUTABLE ] = TypeRangeNSort;
    TypeObjFuncs[ T_RANGE_SSORT            ] = TypeRangeSSort;
    TypeObjFuncs[ T_RANGE_SSORT +IMMUTABLE ] = TypeRangeSSort;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* Saving functions */
    SaveObjFuncs[T_RANGE_NSORT            ] = SaveRange;
    SaveObjFuncs[T_RANGE_NSORT +IMMUTABLE ] = SaveRange;
    SaveObjFuncs[T_RANGE_SSORT            ] = SaveRange;
    SaveObjFuncs[T_RANGE_SSORT +IMMUTABLE ] = SaveRange;
    LoadObjFuncs[T_RANGE_NSORT            ] = LoadRange;
    LoadObjFuncs[T_RANGE_NSORT +IMMUTABLE ] = LoadRange;
    LoadObjFuncs[T_RANGE_SSORT            ] = LoadRange;
    LoadObjFuncs[T_RANGE_SSORT +IMMUTABLE ] = LoadRange;

#if !defined(USE_THREADSAFE_COPYING)
    /* install the copy methods                                            */
    CopyObjFuncs [ T_RANGE_NSORT                     ] = CopyRange;
    CopyObjFuncs [ T_RANGE_NSORT +IMMUTABLE          ] = CopyRange;
    CopyObjFuncs [ T_RANGE_NSORT            +COPYING ] = CopyRangeCopy;
    CopyObjFuncs [ T_RANGE_NSORT +IMMUTABLE +COPYING ] = CopyRangeCopy;
    CopyObjFuncs [ T_RANGE_SSORT                     ] = CopyRange;
    CopyObjFuncs [ T_RANGE_SSORT +IMMUTABLE          ] = CopyRange;
    CopyObjFuncs [ T_RANGE_SSORT            +COPYING ] = CopyRangeCopy;
    CopyObjFuncs [ T_RANGE_SSORT +IMMUTABLE +COPYING ] = CopyRangeCopy;
    CleanObjFuncs[ T_RANGE_NSORT                     ] = CleanRange;
    CleanObjFuncs[ T_RANGE_NSORT +IMMUTABLE          ] = CleanRange;
    CleanObjFuncs[ T_RANGE_NSORT            +COPYING ] = CleanRangeCopy;
    CleanObjFuncs[ T_RANGE_NSORT +IMMUTABLE +COPYING ] = CleanRangeCopy;
    CleanObjFuncs[ T_RANGE_SSORT                     ] = CleanRange;
    CleanObjFuncs[ T_RANGE_SSORT +IMMUTABLE          ] = CleanRange;
    CleanObjFuncs[ T_RANGE_SSORT            +COPYING ] = CleanRangeCopy;
    CleanObjFuncs[ T_RANGE_SSORT +IMMUTABLE +COPYING ] = CleanRangeCopy;
#endif

    /* Make immutable methods */
    MakeImmutableObjFuncs[ T_RANGE_NSORT ] = MakeImmutableRange;
    MakeImmutableObjFuncs[ T_RANGE_SSORT ] = MakeImmutableRange;
    
    /* install the print method                                            */
    PrintObjFuncs[ T_RANGE_NSORT            ] = PrintRange;
    PrintObjFuncs[ T_RANGE_NSORT +IMMUTABLE ] = PrintRange;
    PrintObjFuncs[ T_RANGE_SSORT            ] = PrintRange;
    PrintObjFuncs[ T_RANGE_SSORT +IMMUTABLE ] = PrintRange;

    /* initialise list tables                                              */
    InitClearFiltsTNumsFromTable   ( ClearFiltsTab );
    InitHasFiltListTNumsFromTable  ( HasFiltTab    );
    InitSetFiltListTNumsFromTable  ( SetFiltTab    );
    InitResetFiltListTNumsFromTable( ResetFiltTab  );

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
    AssListFuncs    [ T_RANGE_SSORT            ] = AssRange;
    AsssListFuncs   [ T_RANGE_NSORT            ] = AsssRange;
    AsssListFuncs   [ T_RANGE_SSORT            ] = AsssRange;
    IsDenseListFuncs[ T_RANGE_NSORT            ] = AlwaysYes;
    IsDenseListFuncs[ T_RANGE_NSORT +IMMUTABLE ] = AlwaysYes;
    IsDenseListFuncs[ T_RANGE_SSORT            ] = AlwaysYes;
    IsDenseListFuncs[ T_RANGE_SSORT +IMMUTABLE ] = AlwaysYes;
    IsHomogListFuncs[ T_RANGE_NSORT            ] = AlwaysYes;
    IsHomogListFuncs[ T_RANGE_NSORT +IMMUTABLE ] = AlwaysYes;
    IsHomogListFuncs[ T_RANGE_SSORT            ] = AlwaysYes;
    IsHomogListFuncs[ T_RANGE_SSORT +IMMUTABLE ] = AlwaysYes;
    IsSSortListFuncs[ T_RANGE_NSORT            ] = AlwaysNo;
    IsSSortListFuncs[ T_RANGE_NSORT +IMMUTABLE ] = AlwaysNo;
    IsSSortListFuncs[ T_RANGE_SSORT            ] = AlwaysYes;
    IsSSortListFuncs[ T_RANGE_SSORT +IMMUTABLE ] = AlwaysYes;
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

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoRange() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "range",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoRange ( void )
{
    return &module;
}
