/****************************************************************************
**
*W  blister.c                   GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This  file contains the functions  that mainly operate  on boolean lists.
**  Because boolean lists are  just a special case  of lists many  things are
**  done in the list package.
**
**  A *boolean list* is a list that has no holes and contains only 'true' and
**  'false'.  For  the full definition of  boolean list  see chapter "Boolean
**  Lists" in the {\GAP} Manual.  Read  also the section "More  about Boolean
**  Lists" about the different internal representations of such lists.
**
**  A list that is known to be a boolean list is represented by a bag of type
**  'T_BLIST', which has the following format:
**
**      +-------+-------+-------+-------+- - - -+-------+
**      |logical| block | block | block |       | last  |
**      |length |   0   |   1   |   2   |       | block |
**      +-------+-------+-------+-------+- - - -+-------+
**             /         \
**        .---'           `-----------.
**       /                             \
**      +---+---+---+---+- - - -+---+---+
**      |bit|bit|bit|bit|       |bit|bit|
**      | 0 | 1 | 2 | 3 |       |n-1| n |
**      +---+---+---+---+- - - -+---+---+
**
**  The  first  entry is  the logical  length of the list,  represented as  a
**  {\GAP} immediate integer.  The other entries are blocks, represented as C
**  unsigned  long integer.   Each  block corresponds  to  <n>  (usually  32)
**  elements of the list.  The <j>-th bit (the bit corresponding to '2\^<j>')
**  in  the <i>-th block  is 1 if  the element  '<list>[BIPEB*<i>+<j>+1]'  it
**  'true'  and '0' if  it  is 'false'.  If the logical length of the boolean
**  list is not a multiple of BIPEB the  last block will contain unused bits,
**  which are then zero.
**
**  Note that a list represented by a bag of type 'T_PLIST'  might still be a
**  boolean list.  It is just that the kernel does not known this.
**
**  This package consists of three parts.
**
**  The  first  part  consists  of  the  macros  'BIPEB',  'SIZE_PLEN_BLIST',
**  'PLEN_SIZE_BLIST',   'LEN_BLIST',   'SET_LEN_BLIST',   'ELM_BLIST',   and
**  'SET_ELM_BLIST'.   They  determine the  representation of boolean  lists.
**  The  rest  of the {\GAP} kernel  uses those macros  to access and  modify
**  boolean lists.
**
**  The  second  part  consists  of  the  functions  'LenBlist',  'ElmBlist',
**  'ElmsBlist',   'AssBlist',    'AsssBlist',   'PosBlist',    'PlainBlist',
**  'IsDenseBlist',  'IsPossBlist', 'EqBlist', and  'LtBlist'.  They  are the
**  functions required by the  generic lists  package.  Using these functions
**  the other parts of  the {\GAP} kernel can access and modify boolean lists
**  without actually being aware that they are dealing with a boolean list.
**
**  The  third part  consists    of the functions  'IsBlist',  'FuncIsBlist',
**  'FuncBlistList', 'FuncListBlist',  'FuncSizeBlist',  'FuncIsSubsetBlist',
**  'FuncUniteBlist', 'FuncIntersectBlist',  and  'FuncSubtractBlist'.  These
**  functions make it possible to make boolean lists,  either by converting a
**  list to a boolean list,  or by computing  the characteristic boolean list
**  of a  sublist, or by  computing the union,  intersection or difference of
**  two boolean lists.
**
*N  1992/12/16 martin should have 'LtBlist'
*/
char *          Revision_blister_c =
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
#include        "set.h"                 /* IsSet, SetList                  */

#define INCLUDE_DECLARATION_PART
#include        "blister.h"             /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "range.h"               /* GET_LEN_RANGE, GET_LOW_RANGE,...*/

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**

*V  BIPEB . . . . . . . . . . . . . . . . . . . . . . . . . .  bits per block
**
**  'BIPEB' is the number of bits per block, wher a block fille a UInt, which
**   should be the same size as a bag identifier, although we do not rely on
**   this
**
**  'BIPEB' is defined in the declaration part of this package as follows:
**
#define BIPEB                           (sizeof(UInt) * 8L)
*/


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
**
**  'PLEN_SIZE_BLIST'  is defined in the declaration  part of this package as
**  follows:
**
#define PLEN_SIZE_BLIST(size) \
                        ((((size)-sizeof(Obj))/sizeof(Obj)) * BIPEB)
*/


/****************************************************************************
**
*F  SIZE_PLEN_BLIST(<plen>)size for a boolean list with given physical length
**
**  'SIZE_PLEN_BLIST' returns  the size  that a boolean list  with  room  for
**  <plen> elements must at least have.
**
**  Note that 'SIZE_PLEN_BLIST' is a macro, so do not call it with  arguments
**  that have sideeffects.
**
**  'SIZE_PLEN_BLIST' is  defined  in the declaration part of this package as
**  follows:
**
#define SIZE_PLEN_BLIST(plen) \
                        (sizeof(Obj)+((plen)+BIPEB-1)/BIPEB*sizeof(Obj))
*/


/****************************************************************************
**
*F  LEN_BLIST(<list>) . . . . . . . . . . . . . . .  length of a boolean list
**
**  'LEN_BLIST' returns the logical length of the boolean list <list>, as a C
**  integer.
**
**  Note that 'LEN_BLIST' is a macro, so do not call it  with  arguments that
**  have sideeffects.
**
**  'LEN_BLIST' is defined in the declaration part of the package as follows:
**
#define LEN_BLIST(list) \
                        ((Int)(ADDR_OBJ(list)[0]))
*/


/****************************************************************************
**
*F  SET_LEN_BLIST(<list>,<len>) . . . . . .  set the length of a boolean list
**
**  'SET_LEN_BLIST' sets the  length of the boolean list  <list> to the value
**  <len>, which must be a positive C integer.
**
**  Note that 'SET_LEN_BLIST' is a macro, so do  not  call it with  arguments
**  that have sideeffects.
**
**  'SET_LEN_BLIST' is  defined in the declaration part of  this  package  as
**  follows:
**
#define SET_LEN_BLIST(list,len) \
                        (ADDR_OBJ(list)[0] = (Obj)(len))
*/


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
**
**  'ELM_BLIST' is defined in the declaration part of the package as follows:
**
#define ELM_BLIST(list,pos) \
 (((UInt4*)(ADDR_OBJ(list)+1))[((pos)-1)/BIPEB]&(1UL<<((pos)-1)%BIPEB) ? \
  True : False)
*/


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
**
**  'SET_ELM_BLIST' is defined in  the  declaration  part of this  package as
**  follows:
**
#define SET_ELM_BLIST(list,pos,val)  \
 ((val) == True ? \
  (((UInt4*)(ADDR_OBJ(list)+1))[((pos)-1)/BIPEB]|=(1UL<<((pos)-1)%BIPEB)) : \
  (((UInt4*)(ADDR_OBJ(list)+1))[((pos)-1)/BIPEB]&=~(1UL<<((pos)-1)%BIPEB)))
*/


/****************************************************************************
**

*F  TypeBlist(<list>) . . . . . . . . . . . . . . . .  kind of a boolean list
**
**  'TypeBlist' returns the kind of a boolean list.
**
**  'TypeBlist' is the function in 'TypeObjFuncs' for boolean lists.
*/
extern  Obj             TYPE_LIST_EMPTY_MUTABLE;
extern  Obj             TYPE_LIST_EMPTY_IMMUTABLE;

extern  Obj             TYPE_LIST_HOM;

#define IS_IMM_BLIST(list)  ((TNUM_OBJ(list) - T_BLIST) % 2)

Obj             TypeBlist (
    Obj                 list )
{
    Obj                 kind;           /* kind, result                    */
    Int                 ktype;          /* kind type of <list>             */
    Obj                 family;         /* family of elements              */
    Obj                 kinds;          /* kinds list of <family>          */

    /* special case for the empty blist                                    */
    if ( LEN_BLIST(list) == 0 ) {
        if ( ! IS_IMM_BLIST(list) ) {
            return TYPE_LIST_EMPTY_MUTABLE;
        }
        else {
            return TYPE_LIST_EMPTY_IMMUTABLE;
        }
    }

    /* get the kind type and the family of the elements                    */
    ktype  = TNUM_OBJ( list );
    family = FAMILY_TYPE( TYPE_OBJ( ELM_BLIST( list, 1 ) ) );

    /* get the list kinds of that family                                   */
    kinds  = TYPES_LIST_FAM( family );

    /* get the kind, if it is not known, compute it                        */
    kind = ELM0_LIST( kinds, ktype-T_BLIST+1 );
    if ( kind == 0 ) {
        kind = CALL_2ARGS( TYPE_LIST_HOM,
            family, INTOBJ_INT(ktype-T_BLIST+1) );
        ASS_LIST( kinds, ktype-T_BLIST+1, kind );
    }

    /* return the kind                                                     */
    return kind;
}


/****************************************************************************
**

*F  CopyBlist( <list>, <mut> )  . . . . . . . . . . . . . copy a boolean list
**
**  'CopyBlist' returns a structural (deep) copy  of the boolean list <list>,
**  i.e., a recursive copy that preserves the structure.
**
**  If <list>  has not yet been copied,   it makes a   copy, leaves a forward
**  pointer  to the copy in the  first entry of  the  boolean list, where the
**  size of the boolean list usually resides, and copies all the entries.  If
**  the boolean  list has already been  copied, it returns  the  value of the
**  forwarding pointer.
**
**  'CopyBlist' is the function in 'CopyObjFuncs' for boolean lists.
**
**  'CleanBlist' removes the mark and the forwarding pointer from the boolean
**  list <list>.
**
**  'CleanBlist' is the function in 'CleanObjFuncs' for boolean lists.
*/
Obj CopyBlist (
    Obj                 list,
    Int                 mut )
{
    Obj                 copy;           /* handle of the copy, result      */
    UInt4 *             l;              /* pointer into the list           */
    UInt4 *             c;              /* pointer into the copy           */
    UInt                i;              /* loop variable                   */

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
    l = (UInt4*)(ADDR_OBJ(list)+1);
    c = (UInt4*)(ADDR_OBJ(copy)+1);
    for ( i = 1; i <= (LEN_BLIST(copy)+BIPEB-1)/BIPEB; i++ )
        *c++ = *l++;

    /* return the copy                                                     */
    return copy;
}


/****************************************************************************
**
*F  CopyBlistCopy( <list>, <mut> )  . . . . . . . copy a already copied blist
*/
Obj CopyBlistCopy (
    Obj                 list,
    Int                 mut )
{
    return ADDR_OBJ(list)[0];
}


/****************************************************************************
**
*F  CleanBlist( <list> )  . . . . . . . . . . . . . . clean up a boolean list
*/
void CleanBlist (
    Obj                 list )
{
}


/****************************************************************************
**
*F  CleanBlistCopy( <list> )  . . . . . . . . . . . . .  clean a copied blist
*/
void CleanBlistCopy (
    Obj                 list )
{
    /* remove the forwarding pointer                                       */
    ADDR_OBJ(list)[0] = ADDR_OBJ( ADDR_OBJ(list)[0] )[0];

    /* now it is cleaned                                                   */
    RetypeBag( list, TNUM_OBJ(list) - COPYING );
}


/****************************************************************************
**

*F  EqBlist(<listL>,<listR>)  . . . . . . test if two boolean lists are equal
**
**  'EqBlist' returns 'true' if the two boolean lists <listL> and <listR> are
**  equal and 'false' otherwise.
*/
Int             EqBlist (
    Obj                 listL,
    Obj                 listR )
{
    long                lenL;           /* length of the left operand      */
    long                lenR;           /* length of the right operand     */
    UInt4 *             ptrL;           /* pointer to the left operand     */
    UInt4 *             ptrR;           /* pointer to the right operand    */
    UInt                i;              /* loop variable                   */

    /* get the lengths of the lists and compare them                       */
    lenL = LEN_BLIST( listL );
    lenR = LEN_BLIST( listR );
    if ( lenL != lenR ) {
        return 0L;
    }

    /* test for equality blockwise                                         */
    ptrL = (UInt4*)(ADDR_OBJ(listL)+1);
    ptrR = (UInt4*)(ADDR_OBJ(listR)+1);
    for ( i = (lenL+BIPEB-1)/BIPEB; 0 < i; i-- ) {
        if ( *ptrL++ != *ptrR++ )
            return 0L;
    }

    /* no differences found, the lists are equal                           */
    return 1L;
}


/****************************************************************************
**
*F  LenBlist(<list>)  . . . . . . . . . . . . . . .  length of a boolean list
**
**  'LenBlist' returns the length of the boolean list <list> as a C integer.
**
**  'LenBlist' is the function in 'LenListFuncs' for boolean lists.
*/
Int             LenBlist (
    Obj                 list )
{
    return LEN_BLIST( list );
}


/****************************************************************************
**
*F  IsbBlist(<list>,<pos>)  . . . . . . test for an element of a boolean list
**
**  'IsbBlist' returns  1 if the boolean list <list> contains an  element  at
**  the position <pos> and 0 otherwise.  It  is  the  responsibility  of  the
**  caller to ensure that <pos> is a positive integer.
**
**  'IsbBlist' is the function in 'IsbListFuncs' for boolean lists.
*/
Int             IsbBlist (
    Obj                 list,
    Int                 pos )
{
    return (pos <= LEN_BLIST(list));
}

Int             IsbvBlist (
    Obj                 list,
    Int                 pos )
{
    return 1L;
}


/****************************************************************************
**
*F  Elm0Blist(<list>,<pos>) . . . . . . . select an element of a boolean list
*F  Elm0vBlist(<list>,<pos>)  . . . . . . select an element of a boolean list
**
**  'Elm0Blist' returns the element at the position <pos> of the boolean list
**  <list>, or 0 if  <list>  has no  assigned object  at  <pos>.  It  is  the
**  responsibility of the caller to ensure that <pos> is a positive integer.
**
**  'Elm0vPlist' does the same thing than 'Elm0List', but need not check that
**  <pos>  is less  than or  equal   to the length   of  <list>, this is  the
**  responsibility of the caller.
*/
Obj             Elm0Blist (
    Obj                 list,
    Int                 pos )
{
    if ( pos <= LEN_BLIST( list ) ) {
        return ELM_BLIST( list, pos );
    }
    else {
        return 0;
    }
}

Obj             Elm0vBlist (
    Obj                 list,
    Int                 pos )
{
    return ELM_BLIST( list, pos );
}


/****************************************************************************
**
*F  ElmBlist(<list>,<pos>)  . . . . . . . select an element of a boolean list
**
**  'ElmBlist' selects  the  element at  position <pos> of  the  boolean list
**  <list>.  It is the responsibility of the caller to ensure that <pos> is a
**  positive integer.   An  error is signalled   if <pos> is larger  than the
**  length of <list>.
**
**  'ElmvBlist' does the same thing than  'ElmBlist', but need not check that
**  <pos>   is less than   or equal  to the  length  of  <list>,  this is the
**  responsibility of the caller.
**
**  'ElmBlist'   is  the  function  in    'ElmListFuncs'  for boolean  lists.
**  'ElmvBlist' is the function in 'ElmvListFuncs' for boolean lists.
*/
Obj             ElmBlist (
    Obj                 list,
    Int                 pos )
{

    /* check the position                                                  */
    if ( LEN_BLIST( list ) < pos ) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            pos, 0L,
            "you can return after assigning a value" );
        return ELM_LIST( list, pos );
    }

    /* select and return the element                                       */
    return ELM_BLIST( list, pos );
}

Obj             ElmvBlist (
    Obj                 list,
    Int                 pos )
{
    /* select and return the element                                       */
    return ELM_BLIST( list, pos );
}


/****************************************************************************
**
*F  ElmsBlist(<list>,<poss>)  . . . . .  select a sublist from a boolean list
**
**  'ElmsBlist' returns a new list  containing the elements at the  positions
**  given in the   list  <poss> from  the boolean   list <list>.   It  is the
**  responsibility of the caller to ensure  that <poss> is dense and contains
**  only positive integers.  An error is signalled if an element of <poss> is
**  larger than the length of <list>.
**
**  'ElmsBlist' is the function in 'ElmsListFuncs' for boolean lists.
*/
Obj             ElmsBlist (
    Obj                 list,
    Obj                 poss )
{
    Obj                 elms;           /* selected sublist, result        */
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element from <list>         */
    Int                 lenPoss;        /* length of <positions>           */
    Int                 pos;            /* <position> as integer           */
    Int                 inc;            /* increment in a range            */
    UInt4               block;          /* one block of <elms>             */
    UInt4               bit;            /* one bit of a block              */
    UInt                i;              /* loop variable                   */

    /* general code                                                        */
    if ( ! IS_RANGE(poss) ) {

        /* get the length of <list>                                        */
        lenList = LEN_BLIST( list );

        /* get the length of <positions>                                   */
        lenPoss = LEN_LIST( poss );

        /* make the result list                                            */
        elms = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenPoss ) );
        SET_LEN_BLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        block = 0;  bit = 1;
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );
            if ( lenList < pos ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    pos, 0L,
                    "you can return after assigning a value" );
                return ELMS_LIST( list, poss );
            }

            /* select the element                                          */
            elm = ELM_BLIST( list, pos );

            /* assign the element into <elms>                              */
            if ( elm == True )
                block |= bit;
            bit <<= 1;
            if ( bit == 0 || i == lenPoss ) {
                ((UInt4*)(ADDR_OBJ(elms)+1))[(i-1)/BIPEB] = block;
                block = 0;
                bit = 1;
            }

        }

    }

    /* special code for ranges                                             */
    /*N 1992/12/15 martin special code for ranges with increment 1         */
    else {

        /* get the length of <list>                                        */
        lenList = LEN_PLIST( list );

        /* get the length of <positions>, the first elements, and the inc. */
        lenPoss = GET_LEN_RANGE( poss );
        pos = GET_LOW_RANGE( poss );
        inc = GET_INC_RANGE( poss );

        /* check that no <position> is larger than 'LEN_LIST(<list>)'      */
        if ( lenList < pos ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                pos, 0L,
                "you can return after assigning a value" );
            return ELMS_LIST( list, poss );
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                pos+(lenPoss-1)*inc, 0L,
                "you can return after assigning a value" );
            return ELMS_LIST( list, poss );
        }

        /* make the result list                                            */
        elms = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenPoss ) );
        SET_LEN_BLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        block = 0;  bit = 1;
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {

            /* select the element                                          */
            elm = ELM_BLIST( list, pos );

            /* assign the element to <elms>                                */
            if ( elm == True )
                block |= bit;
            bit <<= 1;
            if ( bit == 0 || i == lenPoss ) {
                ((UInt4*)(ADDR_OBJ(elms)+1))[(i-1)/BIPEB] = block;
                block = 0;
                bit = 1;
            }

        }

    }

    /* return the result                                                   */
    return elms;
}


/****************************************************************************
**
*F  AssBlist(<list>,<pos>,<val>)  . . . . . . . . .  assign to a boolean list
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
void            AssBlist (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    /* if <pos> is less than the logical length and <elm> is 'true'        */
    if      ( pos <= LEN_BLIST(list) && val == True ) {
        SET_ELM_BLIST( list, pos, True );
        RetypeBag( list, T_BLIST );
    }

    /* if <i> is less than the logical length and <elm> is 'false'         */
    else if ( pos <= LEN_BLIST(list) && val == False ) {
        SET_ELM_BLIST( list, pos, False );
        RetypeBag( list, T_BLIST );
    }

    /* if <i> is one more than the logical length and <elm> is 'true'      */
    else if ( pos == LEN_BLIST(list)+1 && val == True ) {
        if ( SIZE_OBJ(list) < SIZE_PLEN_BLIST(pos) )
            ResizeBag( list, SIZE_PLEN_BLIST(pos) );
        SET_LEN_BLIST( list, pos );
        SET_ELM_BLIST( list, pos, True );
        RetypeBag( list, T_BLIST );
    }

    /* if <i> is one more than the logical length and <elm> is 'true'      */
    else if ( pos == LEN_BLIST(list)+1 && val == False ) {
        if ( SIZE_OBJ(list) < SIZE_PLEN_BLIST(pos) )
            ResizeBag( list, SIZE_PLEN_BLIST(pos) );
        SET_LEN_BLIST( list, pos );
        SET_ELM_BLIST( list, pos, False );
        RetypeBag( list, T_BLIST );
    }

    /* otherwise convert to ordinary list and assign as in 'AssList'       */
    else {
        PLAIN_LIST( list );
        RetypeBag( list, T_PLIST );
        if ( LEN_PLIST(list) < pos ) {
            GROW_PLIST( list, pos );
            SET_LEN_PLIST( list, pos );
        }
        SET_ELM_PLIST( list, pos, val );
        CHANGED_BAG( list );
    }
}

void            AssBlistImm (
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
*F  AsssBlist(<list>,<poss>,<vals>) . . .  assign several elements to a blist
**
**  'AsssBlist' assignes the values  from  the list  <vals> at the  positions
**  given  in the  list  <poss>  to the   boolean  list  <list>.  It is   the
**  responsibility of the caller to ensure that  <poss> is dense and contains
**  only positive integers, that <poss> and <vals>  have the same length, and
**  that <vals> is dense.
**
**  'AsssBlist' is the function in 'AsssListFuncs' for boolean lists.
**
**  'AsssBlist' simply converts  the boolean list   to a plain  list and then
**  does the same stuff  as 'AsssPlist'.  This is   because a boolean is  not
**  very likely to stay a boolean list after the assignment.
*/
void            AsssBlist (
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

void            AsssBlistImm (
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
*F  IsDenseBlist(<list>)  . . .  dense list test function for boolean lists
**
**  'IsDenseBlist' returns 1, since boolean lists are always dense.
**
**  'IsDenseBlist' is the function in 'IsDenseBlistFuncs' for boolean lists.
*/
Int             IsDenseBlist (
    Obj                 list )
{
    return 1L;
}


/****************************************************************************
**
*F  IsHomogBlist(<list>)
*/
Int             IsHomogBlist (
    Obj                 list )
{
    return (0 < LEN_BLIST(list));
}


/****************************************************************************
**
*F  IsSSortBlist(<list>)
*/
Int             IsSSortBlist (
    Obj                 list )
{
    Int                 isSort;
    if ( LEN_BLIST(list) <= 1 ) {
        isSort = 1;
    }
    else if ( LEN_BLIST(list) == 2 ) {
        isSort = (ELM_BLIST(list,1) == True && ELM_BLIST(list,2) == False);
    }
    else {
        isSort = 0;
    }
    RetypeBag( list, (isSort ? T_BLIST_SSORT : T_BLIST_NSORT)
                     + IS_IMM_BLIST(list) );
    return isSort;
}

Int             IsSSortBlistNot (
    Obj                 list )
{
    return 0L;
}

Int             IsSSortBlistYes (
    Obj                 list )
{
    return 1L;
}


/****************************************************************************
**
*F  IsPossBlist(<list>) . .  positions list test function for boolean lists
**
**  'IsPossBlist' returns  1 if  <list> is  empty, and 0 otherwise, since a
**  boolean list is a positions list if and only if it is empty.
*/
Int             IsPossBlist (
    Obj                 list )
{
    return LEN_BLIST(list) == 0;
}


/****************************************************************************
**
*F  PosBlist(<list>,<val>,<start>) . . . position of an elm in a boolean list
**
**  'PosBlist' returns the   position of  the first  occurence  of the  value
**  <val>, which may be  an  object of  arbitrary  type, in the boolean  list
**  <list> after <start> as a C  integer.  If <val> does  not occur in <list>
**  after <start>, then 0 is returned.
**
**  'PosBlist' is the function in 'PosListFuncs' for boolean lists.
*/
Int             PosBlist (
    Obj                 list,
    Obj                 val,
    Int                 start )
{
    Int                 k;              /* position, result                */
    Int                 len;            /* logical length of the list      */
    UInt4 *             ptr;            /* pointer to the blocks           */
    UInt                i,  j;          /* loop variables                  */

    len = LEN_BLIST(list);

    /* look just beyond end                                                */
    if ( len == start ) {
        k = 0;
    }

    /* look for 'true'                                                     */
    else if ( val == True ) {
        ptr = (UInt4*)(ADDR_OBJ(list)+1);
        if ( ptr[start/BIPEB] >> (start%BIPEB) != 0 ) {
            i = start/BIPEB;
            for ( j = start%BIPEB; j < BIPEB; j++ ) {
                if ( (ptr[i] & (1UL << j)) != 0 )  break;
            }
        }
        else {
            for ( i = start/BIPEB+1; i < (len-1)/BIPEB; i++ ) {
                if ( ptr[i] != 0UL )  break;
            }
            for ( j = 0; j < BIPEB; j++ ) {
                if ( (ptr[i] & (1UL<<j)) != 0 )  break;
            }
        }
        k = (BIPEB*i+j+1 <= len ? BIPEB*i+j+1 : 0);
    }

    /* look for 'false'                                                    */
    else if ( val == False ) {
        ptr = (UInt4*)(ADDR_OBJ(list)+1);
        if ( ~ptr[start/BIPEB] >> (start%BIPEB) != 0 ) {
            i = start/BIPEB;
            for ( j = start%BIPEB; j < BIPEB; j++ ) {
                if ( (ptr[i] & (1UL<<j)) == 0 )  break;
            }
        }
        else {
            for ( i = start/BIPEB+1; i < (len-1)/BIPEB; i++ ) {
                if ( ptr[i] != ~0UL )  break;
            }
            for ( j = 0; j < BIPEB; j++ ) {
                if ( (ptr[i] & (1UL<<j)) == 0 )  break;
            }
        }
        k = (BIPEB*i+j+1 <= len ? BIPEB*i+j+1 : 0);
    }

    /* look for something else                                             */
    else {
        k = 0;
    }

    /* return the position                                                 */
    return k;
}

/****************************************************************************
**
*F  PlainBlist(<list>)  . . . .  convert a boolean list into an ordinary list
**
**  'PlainBlist' converts the boolean list <list> to a plain list.
**
**  'PlainBlist' is the function in 'PlainListFuncs' for boolean lists.
*/
void            PlainBlist (
    Obj                 list )
{
    Int                 len;            /* length of <list>                */
    UInt                i;              /* loop variable                   */

    /* resize the list and retype it, in this order                        */
    len = LEN_BLIST( list );
    RetypeBag( list, T_PLIST );
    GROW_PLIST( list, len );
    SET_LEN_PLIST( list, len );

    /* replace the bits by 'True' or 'False' as the case may be            */
    /* this must of course be done from the end of the list backwards      */
    for ( i = len; 0 < i; i-- )
        SET_ELM_PLIST( list, i, ELM_BLIST( list, i ) );

    /* 'CHANGED_BAG' not needed, 'True' and 'False' are safe           */
}


/****************************************************************************
**
*F  IsBlist(<list>) . . . . . . . . . . test whether a list is a boolean list
**
**  'IsBlist'  returns 1 if the list  <list> is a  boolean list, i.e., a list
**  that has no holes and contains only  'true' and 'false', and 0 otherwise.
**  As a sideeffect  'IsBlist'  changes the representation of   boolean lists
**  into the compact representation of type 'T_BLIST' described above.
*/
Int             IsBlist (
    Obj                 list )
{
    UInt                isBlist;        /* result of the test              */
    Int                 len;            /* logical length of the list      */
    UInt4               block;          /* one block of the boolean list   */
    UInt4               bit;            /* one bit of a block              */
    UInt                i;              /* loop variable                   */

    /* if <list> is known to be a boolean list, it is very easy            */
    if ( T_BLIST <= TNUM_OBJ(list)
      && TNUM_OBJ(list) <= T_BLIST_SSORT ) {
        isBlist = 1;
    }

    /* if <list> is not a list, its not a boolean list (convert to list)   */
    else if ( ! IS_LIST( list ) ) {
        isBlist = 0;
    }

    /* otherwise test if there are holes and if all elements are boolean   */
    else {

        /* test that all elements are bound and either 'true' or 'false'   */
        len = LEN_LIST( list );
        for ( i = 1; i <= len; i++ ) {
            if ( ELMV0_LIST( list, i ) == 0
              || (ELMW_LIST( list, i ) != True
               && ELMW_LIST( list, i ) != False) ) {
                break;
            }
        }

        /* if <list> is a boolean list, change its representation        */
        isBlist = (len < i);
        if ( isBlist ) {
            block = 0;
            bit = 1;
            for ( i = 1; i <= len; i++ ) {
                if ( ELMW_LIST( list, i ) == True )
                    block |= bit;
                bit = bit << 1;
                if ( bit == 0 || i == len ) {
                    ((UInt4*)(ADDR_OBJ(list)+1))[(i-1)/BIPEB] = block;
                    block = 0;
                    bit = 1;
                }
            }
            RetypeBag( list, (IS_MUTABLE_OBJ(list) ?
                              T_BLIST : T_BLIST+IMMUTABLE) );
            ResizeBag( list, SIZE_PLEN_BLIST( len ) );
            SET_LEN_BLIST( list, len );
        }

    }

    /* return the result                                                   */
    return isBlist;
}


/****************************************************************************
**

*F  FuncIsBlist( <self>, <val> )  . . . . . test if a value is a boolean list
**
**  'FuncIsBlist' implements the internal function 'IsBlist'.
**
**  'IsBlist( <val> )'
**
**  'IsBlist' returns 'true' if the value <val> is a boolean list and 'false'
**  otherwise.  A value is a   boolean list if  it is  a lists without  holes
**  containing only  'true' and 'false'.
*/
Obj IsBlistFilt;

Obj             IsBlistHandler (
    Obj                 self,
    Obj                 val )
{
    /* let 'IsBlist' do the work                                           */
    return IsBlist( val ) ? True : False;
}


/****************************************************************************
**
*F  FuncBlistList( <self>, <list>, <sub> ) make a boolean list from a sublist
**
**  'FuncBlistList' implements the internal function 'BlistList'.
**
**  'BlistList( <list>, <sub> )'
**
**  'BlistList'  creates a boolean  list   that describes the  list <sub>  as
**  sublist  of the list  <list>.  The result  is a new boolean list <blist>,
**  which has the same length  as <list>, such  that '<blist>[<i>]' is 'true'
**  if '<list>[<i>]' is an element of <sub> and 'false' otherwise.
**
**  'BlistList' is most effective if <list> is a set, but can be used with an
**  arbitrary list that has no holes.
*/
Obj FuncBlistList (
    Obj                 self,
    Obj                 list,
    Obj                 sub )
{
    Obj                 blist;          /* boolean list, result            */
    UInt4 *             ptrBlist;       /* pointer to the boolean list     */
    UInt4               block;          /* one block of boolean list       */
    UInt4               bit;            /* one bit of block                */
    Int                 lenList;        /* logical length of the list      */
    Obj *               ptrSub;         /* pointer to the sublist          */
    UInt                lenSub;         /* logical length of sublist       */
    UInt                i, j, k, l;     /* loop variables                  */
    long                s, t;           /* elements of a range             */

    /* get and check the arguments                                         */
    while ( ! IS_LIST(list) ) {
        list = ErrorReturnObj(
            "BlistList: <list> must be a list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
            "you can return a list for <list>" );
    }
    while ( ! IS_LIST(sub) ) {
        sub = ErrorReturnObj(
            "BlistList: <sub> must be a list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(sub)].name), 0L,
            "you can return a list for <sub>" );
    }

    /* for a range as subset of a range, it is extremly easy               */
    if ( IS_RANGE(list) && IS_RANGE(sub) ) {

        /* allocate the boolean list and get pointer                       */
        lenList  = GET_LEN_RANGE( list );
        lenSub   = GET_LEN_RANGE( sub );
        blist = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenList ) );
        ADDR_OBJ(blist)[0] = INTOBJ_INT(lenList);
        ptrBlist = (UInt4*)(ADDR_OBJ(blist)+1);

        /* get the bounds of the subset with respect to the boolean list   */
        s = INT_INTOBJ( GET_ELM_RANGE( list, 1 ) );
        t = INT_INTOBJ( GET_ELM_RANGE( sub, 1 ) );
        if ( s <= t )  i = t - s + 1;
        else           i = 1;
        if ( i + lenSub - 1 <= lenList )  j = i + lenSub - 1;
        else                              j = lenList;

        /* set the corresponding entries to 'true'                         */
        for ( k = i; k <= j && (k-1)%BIPEB != 0; k++ )
            ptrBlist[(k-1)/BIPEB] |= (1UL << (k-1)%BIPEB);
        for ( ; k+BIPEB <= j; k += BIPEB )
            ptrBlist[(k-1)/BIPEB] = ~0L;
        for ( ; k <= j; k++ )
            ptrBlist[(k-1)/BIPEB] |= (1UL << (k-1)%BIPEB);

    }

    /* for a list as subset of a range, we need basically no search        */
    else if ( IS_RANGE(list)
          && (T_PLIST <= TNUM_OBJ(sub)
           && TNUM_OBJ(sub) <= T_PLIST_CYC_SSORT) ) {

        /* allocate the boolean list and get pointer                       */
        lenList  = GET_LEN_RANGE( list );
        lenSub   = LEN_LIST( sub );
        blist = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenList ) );
        ADDR_OBJ(blist)[0] = INTOBJ_INT(lenList);
        ptrBlist = (UInt4*)(ADDR_OBJ(blist)+1);
        ptrSub = ADDR_OBJ(sub);

        /* loop over <sub> and set the corresponding entries to 'true'     */
        s = INT_INTOBJ( GET_ELM_RANGE( list, 1 ) );
        for ( l = 1; l <= LEN_LIST(sub); l++ ) {
            if ( ptrSub[l] != 0 ) {

                /* if <sub>[<l>] is an integer it is very easy             */
                if ( TNUM_OBJ( ptrSub[l] ) == T_INT ) {
                    t = INT_INTOBJ( ptrSub[l] ) - s + 1;
                    if ( 0 < t && t <= lenList )
                        ptrBlist[(t-1)/BIPEB] |= (1UL << (t-1)%BIPEB);
                }

                /* otherwise it may be a record, let 'PosRange' handle it  */
                else {
                    k = PosRange( list, ptrSub[l], 0L );
                    if ( k != 0 )
                        ptrBlist[(k-1)/BIPEB] |= (1UL << (k-1)%BIPEB);
                }

            }
        }

    }

    /* if <list> is a set we have two possibilities                        */
    else if ( IsSet( list ) ) {

        /* get the length of <list> and its logarithm                      */
        lenList = LEN_PLIST( list );
        for ( i = lenList, l = 0; i != 0; i >>= 1, l++ ) ;
        PLAIN_LIST( sub );
        lenSub = LEN_LIST( sub );

        /* if <sub> is small, we loop over <sub> and use binary search     */
        if ( l * lenSub < 2 * lenList ) {

            /* allocate the boolean list and get pointer                   */
            blist = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenList ) );
            ADDR_OBJ(blist)[0] = INTOBJ_INT(lenList);

            /* run over the elements of <sub> and search for the elements  */
            for ( l = 1; l <= LEN_LIST(sub); l++ ) {
                if ( ADDR_OBJ(sub)[l] != 0 ) {

                    /* perform the binary search to find the position      */
                    i = 0;  k = lenList+1;
                    while ( i+1 < k ) {
                        j = (i + k) / 2;
                        if ( LT(ADDR_OBJ(list)[j],ADDR_OBJ(sub)[l]) )
                            i = j;
                        else
                            k = j;
                    }

                    /* set bit if <sub>[<l>] was found at position k       */
                    if ( k <= lenList
                      && EQ( ADDR_OBJ(list)[k], ADDR_OBJ(sub)[l] ) )
                        ((UInt4*)(ADDR_OBJ(blist)+1))[(k-1)/BIPEB]
                            |= (1UL << (k-1)%BIPEB);
                }
            }

        }

        /* if <sub> is large, run over both list in parallel               */
        else {

            /* turn the <sub> into a set for faster searching              */
            if ( ! IsSet( sub ) ) {
                sub = SetList( sub );
                lenSub = LEN_LIST( sub );
            }

            /* allocate the boolean list and get pointer                   */
            blist = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenList ) );
            ADDR_OBJ(blist)[0] = INTOBJ_INT(lenList);

            /* run over the elements of <list>                             */
            k = 1;
            block = 0;
            bit   = 1;
            for ( l = 1; l <= lenList; l++ ) {

                /* test if <list>[<l>] is in <sub>                         */
                while ( k <= lenSub
                     && LT(ADDR_OBJ(sub)[k],ADDR_OBJ(list)[l]) )
                    k++;

                /* if <list>[<k>] is in <sub> set the current bit in block */
                if ( k <= lenSub
                  && EQ(ADDR_OBJ(sub)[k],ADDR_OBJ(list)[l]) ) {
                    block |= bit;
                    k++;
                }

                /* if block is full add it to boolean list and start next  */
                bit = bit << 1;
                if ( bit == 0 || l == lenList ) {
                    ((UInt4*)(ADDR_OBJ(blist)+1))[(l-1)/BIPEB] = block;
                    block = 0;
                    bit   = 1;
                }

            }
        }

    }

    /* if <list> is not a set, we have to use brute force                  */
    else {

        /* convert left argument to an ordinary list, ignore return value  */
        PLAIN_LIST( list );

        /* turn <sub> into a set for faster searching                      */
        if ( ! IsSet( sub ) )  sub = SetList( sub );

        /* allocate the boolean list and get pointer                       */
        lenList  = LEN_LIST( list );
        lenSub   = LEN_PLIST( sub );
        blist = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenList ) );
        ADDR_OBJ(blist)[0] = INTOBJ_INT(lenList);

        /* run over the elements of <list>                                 */
        k = 1;
        block = 0;
        bit   = 1;
        for ( l = 1; l <= lenList; l++ ) {

            /* test if <list>[<l>] is in <sub>                             */
            if ( l == 1 || LT(ADDR_OBJ(list)[l-1],ADDR_OBJ(list)[l]) ){
                while ( k <= lenSub
                     && LT(ADDR_OBJ(sub)[k],ADDR_OBJ(list)[l]) )
                    k++;
            }
            else {
                i = 0;  k = LEN_PLIST(sub) + 1;
                while ( i+1 < k ) {
                    j = (i + k) / 2;
                    if ( LT( ADDR_OBJ(sub)[j], ADDR_OBJ(list)[l] ) )
                        i = j;
                    else
                        k = j;
                }
            }

            /* if <list>[<k>] is in <sub> set the current bit in the block */
            if ( k <= lenSub
              && EQ( ADDR_OBJ(sub)[k], ADDR_OBJ(list)[l] ) ) {
                block |= bit;
                k++;
            }

            /* if block is full add it to the boolean list and start next  */
            bit = bit << 1;
            if ( bit == 0 || l == lenList ) {
                ((UInt4*)(ADDR_OBJ(blist)+1))[(l-1)/BIPEB] = block;
                block = 0;
                bit   = 1;
            }

        }

    }

    /* return the boolean list                                             */
    return blist;
}


/****************************************************************************
**
*F  FuncListBlist( <self>, <list>, <blist> )  . . make a sublist from a blist
**
**  'FuncListBlist' implements the internal function 'ListBlist'.
**
**  'ListBlist( <list>, <blist> )'
**
**  'ListBlist' returns the  sublist of the  elements of the list  <list> for
**  which the boolean list   <blist>, which must   have  the same  length  as
**  <list>, contains 'true'.  The order of the elements in the result is  the
**  same as in <list>.
**
*/
Obj FuncListBlist (
    Obj                 self,
    Obj                 list,
    Obj                 blist )
{
    Obj                 sub;            /* handle of the result            */
    Int                 len;            /* logical length of the list      */
    UInt4 *             ptr;            /* pointer to blist                */
    UInt                nrb;            /* number of blocks in blist       */
    UInt4               m;              /* number of bits in a block       */
    UInt                n;              /* number of bits in blist         */
    UInt                nn;
    UInt                i;              /* loop variable                   */

    /* get and check the first argument                                    */
    while ( ! IS_LIST( list ) ) {
        list = ErrorReturnObj(
            "ListBlist: <list> must be a list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
            "you can return a list for <list>" );
    }

    /* get and check the second argument                                   */
    if ( ! IsBlist( blist ) ) {
        blist = ErrorReturnObj(
            "ListBlist: <blist> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(blist)].name), 0L,
            "you can return a boolean list for <blist>" );
    }
    while ( LEN_LIST( list ) != LEN_BLIST( blist ) ) {
        blist = ErrorReturnObj(
            "ListBlist: <blist> must have the same length as <list> (%d)",
            LEN_PLIST( list ), 0L,
            "you can return another boolean list for <blist>" );
    }

    /* compute the number of 'true'-s just as in 'FuncSizeBlist'            */
    nrb = (LEN_BLIST(blist)+BIPEB-1)/BIPEB;
    ptr = (UInt4*)(ADDR_OBJ(blist)+1);
    n = 0;
    for ( i = 1; i <= nrb; i++ ) {
        m = *ptr++;
        m = (m & 0x55555555) + ((m >> 1) & 0x55555555);
        m = (m & 0x33333333) + ((m >> 2) & 0x33333333);
        m = (m + (m >>  4)) & 0x0f0f0f0f;
        m = (m + (m >>  8));
        m = (m + (m >> 16)) & 0x000000ff;
        n += m;
    }

    /* make the sublist (we now know its size exactely)                    */
    sub = NEW_PLIST( IS_MUTABLE_OBJ(list) ? T_PLIST : T_PLIST+IMMUTABLE, n );
    SET_LEN_PLIST( sub, n );

    /* loop over the boolean list and stuff elements into <sub>            */
    len = LEN_LIST( list );
    nn  = 1;
    for ( i = 1;  nn <= n && i <= len;  i++  ) {
        if ( ELM_BLIST( blist, i ) == True ) {
            SET_ELM_PLIST( sub, nn, ELMW_LIST( list, i ) );
            CHANGED_BAG( sub );
            nn++;
        }
    }

    /* return the sublist                                                  */
    return sub;
}


/****************************************************************************
**
*F  FuncPositionsTrueBlist( <self>, <blist> ) . . . true positions in a blist
**
*N  1992/12/15 martin this depends on 'BIPEB' being 32
*/
Obj FuncPositionsTrueBlist (
    Obj                 self,
    Obj                 blist )
{
    Obj                 sub;            /* handle of the result            */
    Int                 len;            /* logical length of the list      */
    UInt4 *             ptr;            /* pointer to blist                */
    UInt                nrb;            /* number of blocks in blist       */
    UInt4               m;              /* number of bits in a block       */
    UInt                n;              /* number of bits in blist         */
    UInt                nn;
    UInt                i;              /* loop variable                   */

    /* get and check the first argument                                    */
    if ( ! IsBlist( blist ) ) {
        blist = ErrorReturnObj(
            "ListBlist: <blist> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(blist)].name), 0L,
            "you can return a boolean list for <blist>" );
    }

    /* compute the number of 'true'-s just as in 'FuncSizeBlist'            */
    nrb = (LEN_BLIST(blist)+BIPEB-1)/BIPEB;
    ptr = (UInt4*)(ADDR_OBJ(blist)+1);
    n = 0;
    for ( i = 1; i <= nrb; i++ ) {
        m = *ptr++;
        m = (m & 0x55555555) + ((m >> 1) & 0x55555555);
        m = (m & 0x33333333) + ((m >> 2) & 0x33333333);
        m = (m + (m >>  4)) & 0x0f0f0f0f;
        m = (m + (m >>  8));
        m = (m + (m >> 16)) & 0x000000ff;
        n += m;
    }

    /* make the sublist (we now know its size exactely)                    */
    sub = NEW_PLIST( T_PLIST, n );
    SET_LEN_PLIST( sub, n );

    /* loop over the boolean list and stuff elements into <sub>            */
    len = LEN_BLIST( blist );
    nn  = 1;
    for ( i = 1; nn <= n && i <= len;  i++ ) {
        if ( ELM_BLIST( blist, i ) == True ) {
            SET_ELM_PLIST( sub, nn, INTOBJ_INT(i) );
            nn++;
        }
    }
    CHANGED_BAG(sub);

    /* return the sublist                                                  */
    return sub;
}


/****************************************************************************
**
*F  FuncPositionNthTrueBlist( <self>, <blist>, <Nth> )
**
*N  1992/12/15 martin this depends on 'BIPEB' being 32
*/
Obj FuncPositionNthTrueBlist (
    Obj                 self,
    Obj                 blist,
    Obj                 Nth )
{
    UInt                nrb;
    Int                 nth,  pos,  i;
    UInt4               m,  mask;
    UInt4 *             ptr;

    /* Check the arguments. */    
    while ( ! IsBlist( blist ) ) {
        blist = ErrorReturnObj(
            "ListBlist: <blist> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(blist)].name), 0L,
            "you can return a boolean list for <blist>" );
    }
    while ( ! IS_INTOBJ(Nth) || INT_INTOBJ(Nth) <= 0 ) {
        Nth = ErrorReturnObj(
            "Position: <nth> must be a positive integer (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(Nth)].name), 0L,
            "you can return a positive integer for <nth>" );
    }
    
    nrb = (LEN_BLIST(blist)+BIPEB-1)/BIPEB;
    if ( ! nrb )  return Fail;
    nth = INT_INTOBJ( Nth );
    pos = 0;
    ptr = (UInt4*)(ADDR_OBJ(blist)+1);
    i = 1;
    m = *ptr;
    m = (m & 0x55555555) + ((m >> 1) & 0x55555555);
    m = (m & 0x33333333) + ((m >> 2) & 0x33333333);
    m = (m + (m >>  4)) & 0x0f0f0f0f;
    m = (m + (m >>  8));
    m = (m + (m >> 16)) & 0x000000ff;
    while ( nth > m ) {
        if ( ++i > nrb )  return Fail;
        nth -= m;
        pos += BIPEB;
        ptr++;
        m = *ptr;
        m = (m & 0x55555555) + ((m >> 1) & 0x55555555);
        m = (m & 0x33333333) + ((m >> 2) & 0x33333333);
        m = (m + (m >>  4)) & 0x0f0f0f0f;
        m = (m + (m >>  8));
        m = (m + (m >> 16)) & 0x000000ff;
    }
    m = *ptr;
    mask = 0x1;
    while ( nth > 0 ) {
        pos++;
        if ( m & mask )  nth--;
        mask <<= 1;
    }
    return INTOBJ_INT( pos );
}


/****************************************************************************
**
*F  FuncSizeBlist( <self>, <blist> )  . . number of 'true' entries in <blist>
**
**  'FuncSizeBlist' implements the internal function 'SizeBlist'
**
**  'SizeBlist( <blist> )'
**
**  'SizeBlist' returns   the number of  entries of  the boolean list <blist>
**  that are 'true'.
**
**  The sequence to compute the  number of bits in  a block is quite  clever.
**  The idea is that after the <i>-th instruction each subblock of $2^i$ bits
**  holds the number of   bits of this  subblock  in the original block  <m>.
**  This is illustrated in the example below for a block of with 8 bits:
**
**       // a b c d e f g h
**      m = (m & 0x55)       +  ((m >> 1) & 0x55);
**       // . b . d . f . h  +  . a . c . e . g   =  a+b c+d e+f g+h
**      m = (m & 0x33)       +  ((m >> 2) & 0x33);
**       // . . c+d . . g+h  +  . . a+b . . e+f   =  a+b+c+d e+f+g+h
**      m = (m & 0x0f)       +  ((m >> 4) & 0x0f);
**       // . . . . e+f+g+h  +  . . . . a+b+c+d   =  a+b+c+d+e+f+g+h
**
**  In the actual  code  some unnecessary mask  have  been removed, improving
**  performance quite a bit,  because masks are 32  bit immediate values  for
**  which most RISC  processors need two  instructions to load them.  Talking
**  about performance.  The code is  close to optimal,  it should compile  to
**  only about  22 MIPS  or SPARC instructions.   Dividing the  block into  4
**  bytes and looking up the number of bits  of a byte in a  table may be 10%
**  faster, but only if the table lives in the data cache.
**
*N  1992/12/15 martin this depends on 'BIPEB' being 32
*/
Obj FuncSizeBlist (
    Obj                 self,
    Obj                 blist )
{
    UInt4 *             ptr;            /* pointer to blist                */
    UInt                nrb;            /* number of blocks in blist       */
    UInt4               m;              /* number of bits in a block       */
    UInt                n;              /* number of bits in blist         */
    UInt                i;              /* loop variable                   */

    /* get and check the argument                                          */
    while ( TNUM_OBJ(blist) != T_BLIST && ! IsBlist(blist) ) {
        blist = ErrorReturnObj(
            "SizeBlist: <blist> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(blist)].name), 0L,
            "you can return a boolean list for <blist>" );
    }

    /* get the number of blocks and a pointer                              */
    nrb = (LEN_BLIST(blist)+BIPEB-1)/BIPEB;
    ptr = (UInt4*)(ADDR_OBJ(blist)+1);

    /* loop over the blocks, adding the number of bits of each one         */
    n = 0;
    for ( i = 1; i <= nrb; i++ ) {
        m = *ptr++;
        m = (m & 0x55555555) + ((m >> 1) & 0x55555555);
        m = (m & 0x33333333) + ((m >> 2) & 0x33333333);
        m = (m + (m >>  4)) & 0x0f0f0f0f;
        m = (m + (m >>  8));
        m = (m + (m >> 16)) & 0x000000ff;
        n += m;
    }

    /* return the number of bits                                           */
    return INTOBJ_INT( n );
}


/****************************************************************************
**
*F  FuncIsSubsetBlist( <self>, <list1>, <list2> ) . .  <list2> subset <list1>
**
**  'FuncIsSubsetBlist' implements the internal function 'IsSubsetBlist'.
**
**  'IsSubsetBlist( <list1>, <list2> )'
**
**  'IsSubsetBlist' returns 'true' if the boolean list <list2> is a subset of
**  the  boolean  list <list1>, which must  have  equal length.  <list2> is a
**  subset if <list1> if '<list2>[<i>] >= <list1>[<i>]' for all <i>.
*/
Obj FuncIsSubsetBlist (
    Obj                 self,
    Obj                 list1,
    Obj                 list2 )
{
    UInt4 *             ptr1;           /* pointer to the first argument   */
    UInt4 *             ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    /* get and check the arguments                                         */
    while ( ! IsBlist( list1 ) ) {
        list1 = ErrorReturnObj(
            "IsSubsetBlist: <blist1> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(list1)].name), 0L,
            "you can return a boolean list for <blist1>" );
    }
    while ( ! IsBlist( list2 ) ) {
        list2 = ErrorReturnObj(
            "IsSubsetBlist: <blist2> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(list2)].name), 0L,
            "you can return a boolean list for <blist2>" );
    }
    while ( LEN_BLIST(list1) != LEN_BLIST(list2) ) {
        list2 = ErrorReturnObj(
        "IsSubsetBlist: <blist2> must have the same length as <blist1> (%d)",
            LEN_BLIST(list1), 0L,
            "you can return a new boolean list for <blist2>" );
    }

    /* test for subset property blockwise                                  */
    ptr1 = (UInt4*)(ADDR_OBJ(list1)+1);
    ptr2 = (UInt4*)(ADDR_OBJ(list2)+1);
    for ( i = (LEN_BLIST(list1)+BIPEB-1)/BIPEB; 0 < i; i-- ) {
        if ( *ptr1 != (*ptr1 | *ptr2) )
            break;
        ptr1++;  ptr2++;
    }

    /* if no counterexample was found, <blist2> is a subset of <blist1>    */
    return (i == 0) ? True : False;
}


/****************************************************************************
**
*F  FuncUniteBlist( <self>, <list1>, <list2> )  . unite one list with another
**
**  'FuncUniteBlist' implements the internal function 'UniteBlist'.
**
**  'UniteBlist( <blist1>, <blist2> )'
**
**  'UniteBlist'  unites  the  boolean list  <blist1>  with  the boolean list
**  <blist2>,  which  must  have the   same  length.  This  is  equivalent to
**  assigning '<blist1>[<i>] := <blist1>[<i>] or <blist2>[<i>]' for all <i>.
*/
Obj FuncUniteBlist (
    Obj                 self,
    Obj                 list1,
    Obj                 list2 )
{
    UInt4 *             ptr1;           /* pointer to the first argument   */
    UInt4 *             ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    /* get and check the arguments                                         */
    while ( ! IsBlist( list1 ) ) {
        list1 = ErrorReturnObj(
            "UniteBlist: <blist1> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(list1)].name), 0L,
            "you can return a boolean list for <blist1>" );
    }
    while ( ! IsBlist( list2 ) ) {
        list2 = ErrorReturnObj(
            "UniteBlist: <blist2> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(list2)].name), 0L,
            "you can return a boolean list for <blist2>" );
    }
    while ( LEN_BLIST(list1) != LEN_BLIST(list2) ) {
        list2 = ErrorReturnObj(
           "UniteBlist: <blist2> must have the same length as <blist1> (%d)",
            LEN_BLIST(list1), 0L,
            "you can return a new boolean list for <blist2>" );
    }

    /* compute the union by *or*-ing blockwise                             */
    ptr1 = (UInt4*)(ADDR_OBJ(list1)+1);
    ptr2 = (UInt4*)(ADDR_OBJ(list2)+1);
    for ( i = (LEN_BLIST(list1)+BIPEB-1)/BIPEB; 0 < i; i-- ) {
        *ptr1++ |= *ptr2++;
    }

    /* return nothing, this function is a procedure                        */
    return 0;
}


/****************************************************************************
**
*F  FuncIntersectBlist( <self>, <list1>, <list2>) .<list1> interstion <list2>
**
**  'FuncIntersectBlist' implements the function 'IntersectBlist'.
**
**  'IntersectBlist( <list1>, <list2> )'
**
**  'IntersectBlist' intersects the   boolean list <list1> with  the  boolean
**  list <list2>, which  must have the  same length.   This is equivalent  to
**  assigning '<list1>[<i>] := <list1>[<i>] and <list2>[<i>]' for all <i>.
*/
Obj FuncIntersectBlist (
    Obj                 self,
    Obj                 list1,
    Obj                 list2 )
{
    UInt4 *             ptr1;           /* pointer to the first argument   */
    UInt4 *             ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    /* get and check the arguments                                         */
    while ( ! IsBlist( list1 ) ) {
        list1 = ErrorReturnObj(
            "IntersectBlist: <blist1> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(list1)].name), 0L,
            "you can return a boolean list for <blist1>" );
    }
    while ( ! IsBlist( list2 ) ) {
        list2 = ErrorReturnObj(
            "IntersectBlist: <blist2> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(list2)].name), 0L,
            "you can return a boolean list for <blist2>" );
    }
    while ( LEN_BLIST(list1) != LEN_BLIST(list2) ) {
        list2 = ErrorReturnObj(
       "IntersectBlist: <blist2> must have the same length as <blist1> (%d)",
            LEN_BLIST(list1), 0L,
            "you can return a new boolean list for <blist2>" );
    }

    /* compute the intersection by *and*-ing blockwise                     */
    ptr1 = (UInt4*)(ADDR_OBJ(list1)+1);
    ptr2 = (UInt4*)(ADDR_OBJ(list2)+1);
    for ( i = (LEN_BLIST(list1)+BIPEB-1)/BIPEB; 0 < i; i-- ) {
        *ptr1++ &= *ptr2++;
    }

    /* return nothing, this function is a procedure                        */
    return 0;
}


/****************************************************************************
**
*F  FuncSubtractBlist( <self>, <list1>, <list2>)  . . . . . <list1> - <list2>
**
**  'FuncSubtractBlist' implements the internal function 'SubtractBlist'.
**
**  'SubtractBlist( <list1>, <list2> )'
**
**  'SubtractBlist' subtracts the boolean  list <list2> from the boolean list
**  <list1>, which  must have the  same length.  This is equivalent assigning
**  '<list1>[<i>] := <list1>[<i>] and not <list2>[<i>]' for all <i>.
*/
Obj FuncSubtractBlist (
    Obj                 self,
    Obj                 list1,
    Obj                 list2 )
{
    UInt4 *             ptr1;           /* pointer to the first argument   */
    UInt4 *             ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    /* get and check the arguments                                         */
    while ( ! IsBlist( list1 ) ) {
        list1 = ErrorReturnObj(
            "SubtractBlist: <blist1> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(list1)].name), 0L,
            "you can return a boolean list for <blist1>" );
    }
    while ( ! IsBlist( list2 ) ) {
        list2 = ErrorReturnObj(
            "SubtractBlist: <blist2> must be a boolean list (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(list2)].name), 0L,
            "you can return a boolean list for <blist2>" );
    }
    while ( LEN_BLIST(list1) != LEN_BLIST(list2) ) {
        list2 = ErrorReturnObj(
        "SubtractBlist: <blist2> must have the same length as <blist1> (%d)",
            LEN_BLIST(list1), 0L,
            "you can return a new boolean list for <blist2>" );
    }

    /* compute the difference by operating blockwise                       */
    ptr1 = (UInt4*)(ADDR_OBJ(list1)+1);
    ptr2 = (UInt4*)(ADDR_OBJ(list2)+1);
    for ( i = (LEN_BLIST(list1)+BIPEB-1)/BIPEB; 0 < i; i-- ) {
        *ptr1++ &= ~ *ptr2++;
    }

    /* return nothing, this function is a procedure                        */
    return 0;
}


/****************************************************************************
**

*F  InitBlist() . . . . . . . . . . . . . initialize the boolean list package
**
**  'InitBlist' initializes the boolean list package.
*/
void InitBlist ( void )
{
    Int                 t1, t2;

    /* install the marking function                                        */
    for ( t1 = T_BLIST; t1 <= T_BLIST_SSORT; t1 += 2 ) {
        InfoBags[         t1                     ].name
            = "list (boolean list)";
        InitMarkFuncBags( t1                     , MarkNoSubBags );
        InfoBags[         t1 +IMMUTABLE          ].name
            = "list (boolean list)";
        InitMarkFuncBags( t1 +IMMUTABLE          , MarkNoSubBags );
    }
    for ( t1 = T_BLIST; t1 <= T_BLIST_SSORT; t1 += 2 ) {
        InfoBags[         t1            +COPYING ].name
            = "list (boolean list), copied";
        InitMarkFuncBags( t1            +COPYING , MarkOneSubBags );
        InfoBags[         t1 +IMMUTABLE +COPYING ].name
            = "list (boolean list), copied";
        InitMarkFuncBags( t1 +IMMUTABLE +COPYING , MarkOneSubBags );
    }

    /* install the kind method                                             */
    for ( t1 = T_BLIST; t1 <= T_BLIST_SSORT; t1 += 2 ) {
        TypeObjFuncs[ t1            ] = TypeBlist;
        TypeObjFuncs[ t1 +IMMUTABLE ] = TypeBlist;
    }

    /* install the copy functions                                          */
    for ( t1 = T_BLIST; t1 <= T_BLIST_SSORT; t1 += 2 ) {
        CopyObjFuncs [ t1                     ] = CopyBlist;
        CopyObjFuncs [ t1 +IMMUTABLE          ] = CopyBlist;
        CopyObjFuncs [ t1            +COPYING ] = CopyBlistCopy;
        CopyObjFuncs [ t1 +IMMUTABLE +COPYING ] = CopyBlistCopy;
        CleanObjFuncs[ t1                     ] = CleanBlist;
        CleanObjFuncs[ t1 +IMMUTABLE          ] = CleanBlist;
        CleanObjFuncs[ t1            +COPYING ] = CleanBlistCopy;
        CleanObjFuncs[ t1 +IMMUTABLE +COPYING ] = CleanBlistCopy;
    }

    /* install the comparison methods                                      */
    for ( t1 = T_BLIST; t1 <= T_BLIST_SSORT+IMMUTABLE; t1++ ) {
        for ( t2 = T_BLIST; t2 <= T_BLIST_SSORT+IMMUTABLE; t2++ ) {
            EqFuncs  [  t1  ][ t2  ] = EqBlist;
        }
    }

    /* install the list functions in the tables                            */
    for ( t1 = T_BLIST; t1 <= T_BLIST_SSORT; t1 += 2 ) {
        LenListFuncs    [ t1            ] = LenBlist;
        LenListFuncs    [ t1 +IMMUTABLE ] = LenBlist;
        IsbListFuncs    [ t1            ] = IsbBlist;
        IsbListFuncs    [ t1 +IMMUTABLE ] = IsbBlist;
        IsbvListFuncs   [ t1            ] = IsbvBlist;
        IsbvListFuncs   [ t1 +IMMUTABLE ] = IsbvBlist;
        Elm0ListFuncs   [ t1            ] = Elm0Blist;
        Elm0ListFuncs   [ t1 +IMMUTABLE ] = Elm0Blist;
        Elm0vListFuncs  [ t1            ] = Elm0vBlist;
        Elm0vListFuncs  [ t1 +IMMUTABLE ] = Elm0vBlist;
        ElmListFuncs    [ t1            ] = ElmBlist;
        ElmListFuncs    [ t1 +IMMUTABLE ] = ElmBlist;
        ElmvListFuncs   [ t1            ] = ElmvBlist;
        ElmvListFuncs   [ t1 +IMMUTABLE ] = ElmvBlist;
        ElmwListFuncs   [ t1            ] = ElmvBlist;
        ElmwListFuncs   [ t1 +IMMUTABLE ] = ElmvBlist;
        ElmsListFuncs   [ t1            ] = ElmsBlist;
        ElmsListFuncs   [ t1 +IMMUTABLE ] = ElmsBlist;
        AssListFuncs    [ t1            ] = AssBlist;
        AssListFuncs    [ t1 +IMMUTABLE ] = AssBlistImm;
        AsssListFuncs   [ t1            ] = AsssBlist;
        AsssListFuncs   [ t1 +IMMUTABLE ] = AsssBlistImm;
        IsDenseListFuncs[ t1            ] = IsDenseBlist;
        IsDenseListFuncs[ t1 +IMMUTABLE ] = IsDenseBlist;
        IsHomogListFuncs[ t1            ] = IsHomogBlist;
        IsHomogListFuncs[ t1 +IMMUTABLE ] = IsHomogBlist;
        IsSSortListFuncs[ t1            ] = IsSSortBlist;
        IsSSortListFuncs[ t1 +IMMUTABLE ] = IsSSortBlist;
        IsPossListFuncs [ t1            ] = IsPossBlist;
        IsPossListFuncs [ t1 +IMMUTABLE ] = IsPossBlist;
        PosListFuncs    [ t1            ] = PosBlist;
        PosListFuncs    [ t1 +IMMUTABLE ] = PosBlist;
        PlainListFuncs  [ t1            ] = PlainBlist;
        PlainListFuncs  [ t1 +IMMUTABLE ] = PlainBlist;
    }
    IsSSortListFuncs[ T_BLIST_NSORT            ] = IsSSortBlistNot;
    IsSSortListFuncs[ T_BLIST_NSORT +IMMUTABLE ] = IsSSortBlistNot;
    IsSSortListFuncs[ T_BLIST_SSORT            ] = IsSSortBlistYes;
    IsSSortListFuncs[ T_BLIST_SSORT +IMMUTABLE ] = IsSSortBlistYes;

    /* install the internal functions                                      */
    InitHandlerFunc(IsBlistHandler, "IS_BLIST");
    IsBlistFilt = NewFilterC( "IS_BLIST", 1L, "obj", IsBlistHandler );
    AssGVar( GVarName( "IS_BLIST" ), IsBlistFilt );

    InitHandlerFunc(FuncBlistList, "BLIST_LIST");
    AssGVar( GVarName( "BLIST_LIST" ),
         NewFunctionC( "BLIST_LIST", 2L, "list, sub",
                    FuncBlistList ) );

    InitHandlerFunc(FuncListBlist, "LIST_BLIST");
    AssGVar( GVarName( "LIST_BLIST" ),
         NewFunctionC( "LIST_BLIST", 2L, "list, blist",
                    FuncListBlist ) );

    InitHandlerFunc(FuncSizeBlist, "SIZE_BLIST");
    AssGVar( GVarName( "SIZE_BLIST" ),
         NewFunctionC( "SIZE_BLIST", 1L, "blist",
                    FuncSizeBlist ) );

    InitHandlerFunc(FuncIsSubsetBlist, "IS_SUB_BLIST");
    AssGVar( GVarName( "IS_SUB_BLIST" ),
         NewFunctionC( "IS_SUB_BLIST", 2L, "blist1, blist2",
                    FuncIsSubsetBlist ) );

    InitHandlerFunc(FuncUniteBlist, "UNITE_BLIST");
    AssGVar( GVarName( "UNITE_BLIST" ),
         NewFunctionC( "UNITE_BLIST", 2L, "blist1, blist2", 
                    FuncUniteBlist ) );

    InitHandlerFunc(FuncIntersectBlist, "INTER_BLIST");
    AssGVar( GVarName( "INTER_BLIST" ),
         NewFunctionC( "INTER_BLIST", 2L, "blist1, blist2",
                    FuncIntersectBlist ) );

    InitHandlerFunc(FuncSubtractBlist, "SUBTR_BLIST");
    AssGVar( GVarName( "SUBTR_BLIST" ),
         NewFunctionC( "SUBTR_BLIST", 2L, "blist1, blist2",
                    FuncSubtractBlist ) );

    InitHandlerFunc(FuncPositionNthTrueBlist, "PositionNthTrueBlist");
    AssGVar( GVarName( "PositionNthTrueBlist" ),
         NewFunctionC( "PositionNthTrueBlist", 2L, "blist, nth",
                    FuncPositionNthTrueBlist ) );

    InitHandlerFunc(FuncPositionsTrueBlist, "PositionsTrueBlist");
    AssGVar( GVarName( "PositionsTrueBlist" ),
         NewFunctionC( "PositionsTrueBlist", 1L, "blist",
                    FuncPositionsTrueBlist ) );
}


/****************************************************************************
**

*E  blister.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
