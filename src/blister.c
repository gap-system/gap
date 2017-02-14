/****************************************************************************
**
*W  blister.c                   GAP source                       Frank Celler
*W                                                         & Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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
**  The third part consists   of the functions  'IsBlistConv', 'FuncIsBlist',
**  'FuncBLIST_LIST', 'FuncLIST_BLIST', 'FuncSIZE_BLIST', 'FuncIS_SUB_BLIST',
**  'FuncUNITE_BLIST', 'FuncINTER_BLIST',   and    'FuncSUBTR_BLIST'.   These
**  functions make it possible to make  boolean lists, either by converting a
**  list to  a boolean list, or by  computing the characteristic boolean list
**  of a sublist, or  by computing the  union, intersection or  difference of
**  two boolean lists.
**
*N  1992/12/16 martin should have 'LtBlist'
*/
#include        "system.h"              /* system dependent part           */


#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */
#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */
#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations              */

#include        "ariths.h"              /* basic arithmetic                */

#include        "bool.h"                /* booleans                        */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"               /* plain lists                     */
#include        "set.h"                 /* plain sets                      */
#include        "blister.h"             /* boolean lists                   */
#include        "range.h"               /* ranges                          */
#include        "stringobj.h"              /* strings                         */

#include        "saveload.h"            /* saving and loading              */

#include	"code.h"		/* coder                           */
#include	"hpc/thread.h"		/* threads			   */
#include	"hpc/tls.h"		/* thread-local storage		   */


/****************************************************************************
**

*F  TypeBlist( <list> )  . . . . . . . . . . . . . . . type of a boolean list
**
**  'TypeBlist' returns the type of a boolean list.
**
**  'TypeBlist' is the function in 'TypeObjFuncs' for boolean lists.
*/

/* The following are imported from the GAP level, we have one type for
 * each blist TNUM. */
Obj TYPE_BLIST_MUT;
Obj TYPE_BLIST_IMM;
Obj TYPE_BLIST_NSORT_MUT;
Obj TYPE_BLIST_NSORT_IMM;
Obj TYPE_BLIST_SSORT_MUT;
Obj TYPE_BLIST_SSORT_IMM;
Obj TYPE_BLIST_EMPTY_MUT;
Obj TYPE_BLIST_EMPTY_IMM;

Obj TypeBlistMut (
    Obj                 list )
{
    /* special case for the empty blist                                    */
    if ( LEN_BLIST(list) == 0 ) {
        return TYPE_BLIST_EMPTY_MUT;
    } else {
        return TYPE_BLIST_MUT;
    }
}

Obj TypeBlistImm (
    Obj                 list )
{
    /* special case for the empty blist                                    */
    if ( LEN_BLIST(list) == 0 ) {
        return TYPE_BLIST_EMPTY_IMM;
    } else {
        return TYPE_BLIST_IMM;
    }
}

Obj TypeBlistNSortMut (
    Obj                 list )
{
    /* special case for the empty blist                                    */
    if ( LEN_BLIST(list) == 0 ) {
        return TYPE_BLIST_EMPTY_MUT;
    } else {
        return TYPE_BLIST_NSORT_MUT;
    }
}

Obj TypeBlistNSortImm (
    Obj                 list )
{
    /* special case for the empty blist                                    */
    if ( LEN_BLIST(list) == 0 ) {
        return TYPE_BLIST_EMPTY_IMM;
    } else {
        return TYPE_BLIST_NSORT_IMM;
    }
}

Obj TypeBlistSSortMut (
    Obj                 list )
{
    /* special case for the empty blist                                    */
    if ( LEN_BLIST(list) == 0 ) {
        return TYPE_BLIST_EMPTY_MUT;
    } else {
        return TYPE_BLIST_SSORT_MUT;
    }
}

Obj TypeBlistSSortImm (
    Obj                 list )
{
    /* special case for the empty blist                                    */
    if ( LEN_BLIST(list) == 0 ) {
        return TYPE_BLIST_EMPTY_IMM;
    } else {
        return TYPE_BLIST_SSORT_IMM;
    }
}

/****************************************************************************
**
*F  SaveBlist( <blist> ) . . . . . . . . . . . . . . . . . . . . save a blist
**
**   The saving method for the blist tnums
*/
void SaveBlist (
    Obj                 bl )
{
    UInt                i;
    UInt *              ptr;

    /* logical length                                                      */
    SaveSubObj(ADDR_OBJ(bl)[0]);
    ptr = BLOCKS_BLIST(bl);
    for (i = 1; i <= NUMBER_BLOCKS_BLIST( bl ); i++ )
        SaveUInt(*ptr++);
    return;
}

/****************************************************************************
**
*F  LoadBlist( <blist> ) . . . . . . . . . . . . . . . . . . . . load a blist
**
**   The loading method for the blist tnums
*/
void LoadBlist (
    Obj                 bl )
{
    UInt                i;
    UInt *              ptr;
  
    /* get the length back, then NUMBER_BLOCKS_BLIST is OK                 */
    ADDR_OBJ(bl)[0] = LoadSubObj(); 
  
    /* Now load the real data                                              */
    ptr = (UInt *)BLOCKS_BLIST(bl);
    for (i = 1; i <= NUMBER_BLOCKS_BLIST( bl ); i++ )
        *ptr++ = LoadUInt();
    return;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * * copy functions * * * * * * * * * * * * * * * *
*/

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

Obj DoCopyBlist(Obj list, Int mut) {
  Obj copy;
  UInt *l;
  UInt *c;
    /* make a copy                                                         */
    if ( mut ) {
      copy = NewBag( MUTABLE_TNUM(TNUM_OBJ(list)), SIZE_OBJ(list) );
    }
    else {
      copy = NewBag( IMMUTABLE_TNUM( TNUM_OBJ(list) ), SIZE_OBJ(list) );
    }


    /* copy the subvalues                                                  */
    l = (UInt*)(ADDR_OBJ(list));
    c = (UInt*)(ADDR_OBJ(copy));
    memcpy((void *)c, (void *)l, sizeof(UInt)*(1+NUMBER_BLOCKS_BLIST(list)));

    /* return the copy                                                     */
    return copy;
  
}

Obj CopyBlist (
    Obj                 list,
    Int                 mut )
{

    /* don't change immutable objects                                      */
    if ( ! IS_MUTABLE_OBJ(list) ) {
        return list;
    }

    return DoCopyBlist(list, mut);
}

Obj ShallowCopyBlist ( Obj list)
{
  return DoCopyBlist(list, 1);
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
    UNMARK_LIST( list, COPYING );
}


/****************************************************************************
**

*F * * * * * * * * * * * * * * list functions * * * * * * * * * * * * * * * *
*/

/****************************************************************************
**


*F  EqBlist( <listL>, <listR> ) . . . . . test if two boolean lists are equal
**
**  'EqBlist' returns 'true' if the two boolean lists <listL> and <listR> are
**  equal and 'false' otherwise.
*/
Int EqBlist (
    Obj                 listL,
    Obj                 listR )
{
    long                lenL;           /* length of the left operand      */
    long                lenR;           /* length of the right operand     */
    UInt *              ptrL;           /* pointer to the left operand     */
    UInt *              ptrR;           /* pointer to the right operand    */
    UInt                i;              /* loop variable                   */

    /* get the lengths of the lists and compare them                       */
    lenL = LEN_BLIST( listL );
    lenR = LEN_BLIST( listR );
    if ( lenL != lenR ) {
        return 0L;
    }

    /* test for equality blockwise                                         */
    ptrL = BLOCKS_BLIST(listL);
    ptrR = BLOCKS_BLIST(listR);
    for ( i = (lenL+BIPEB-1)/BIPEB; 0 < i; i-- ) {
        if ( *ptrL++ != *ptrR++ )
            return 0L;
    }

    /* no differences found, the lists are equal                           */
    return 1L;
}


/****************************************************************************
**
*F  LenBlist( <list> )  . . . . . . . . . . . . . .  length of a boolean list
**
**  'LenBlist' returns the length of the boolean list <list> as a C integer.
**
**  'LenBlist' is the function in 'LenListFuncs' for boolean lists.
*/
Int LenBlist (
    Obj                 list )
{
    return LEN_BLIST( list );
}


/****************************************************************************
**
*F  IsbBlist( <list>, <pos> ) . . . . . test for an element of a boolean list
**
**  'IsbBlist' returns  1 if the boolean list <list> contains an  element  at
**  the position <pos> and 0 otherwise.  It  is  the  responsibility  of  the
**  caller to ensure that <pos> is a positive integer.
**
**  'IsbBlist' is the function in 'IsbListFuncs' for boolean lists.
*/
Int IsbBlist (
    Obj                 list,
    Int                 pos )
{
    return (pos <= LEN_BLIST(list));
}


/****************************************************************************
**
*F  IsbvBlist( <list>, <pos> )  . . . . test for an element of a boolean list
*/
Int IsbvBlist (
    Obj                 list,
    Int                 pos )
{
    return 1L;
}


/****************************************************************************
**

*F  Elm0Blist( <list>, <pos> )  . . . . . select an element of a boolean list
**
**  'Elm0Blist' returns the element at the position <pos> of the boolean list
**  <list>, or 0 if  <list>  has no  assigned object  at  <pos>.  It  is  the
**  responsibility of the caller to ensure that <pos> is a positive integer.
*/
Obj Elm0Blist (
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


/****************************************************************************
**
*F  Elm0vBlist( <list>, <pos> ) . . . . . select an element of a boolean list
**
**  'Elm0vPlist' does the same thing than 'Elm0List', but need not check that
**  <pos>  is less  than or  equal   to the length   of  <list>, this is  the
**  responsibility of the caller.
*/
Obj Elm0vBlist (
    Obj                 list,
    Int                 pos )
{
    return ELM_BLIST( list, pos );
}


/****************************************************************************
**
*F  ElmBlist( <list>, <pos> ) . . . . . . select an element of a boolean list
**
**  'ElmBlist' selects  the  element at  position <pos> of  the  boolean list
**  <list>.  It is the responsibility of the caller to ensure that <pos> is a
**  positive integer.   An  error is signalled   if <pos> is larger  than the
**  length of <list>.
**
**  'ElmBlist'   is  the  function  in    'ElmListFuncs'  for boolean  lists.
**  'ElmvBlist' is the function in 'ElmvListFuncs' for boolean lists.
*/
Obj ElmBlist (
    Obj                 list,
    Int                 pos )
{

    /* check the position                                                  */
    if ( LEN_BLIST( list ) < pos ) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            pos, 0L,
            "you can assign a value and 'return;'" );
        return ELM_LIST( list, pos );
    }

    /* select and return the element                                       */
    return ELM_BLIST( list, pos );
}

/****************************************************************************
**
*F  ElmvBlist( <list>, <pos> )  . . . . . select an element of a boolean list
**
**  'ElmvBlist' does the same thing than  'ElmBlist', but need not check that
**  <pos>   is less than   or equal  to the  length  of  <list>,  this is the
**  responsibility of the caller.
**
*/
Obj ElmvBlist (
    Obj                 list,
    Int                 pos )
{
    /* select and return the element                                       */
    return ELM_BLIST( list, pos );
}


/****************************************************************************
**
*F  ElmsBlist( <list>, <poss> ) . . . .  select a sublist from a boolean list
**
**  'ElmsBlist' returns a new list  containing the elements at the  positions
**  given in the   list  <poss> from  the boolean   list <list>.   It  is the
**  responsibility of the caller to ensure  that <poss> is dense and contains
**  only positive integers.  An error is signalled if an element of <poss> is
**  larger than the length of <list>.
**
**  'ElmsBlist' is the function in 'ElmsListFuncs' for boolean lists.
*/
Obj ElmsBlist (
    Obj                 list,
    Obj                 poss )
{
    Obj                 elms;           /* selected sublist, result        */
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element from <list>         */
    Int                 lenPoss;        /* length of <positions>           */
    Int                 pos;            /* <position> as integer           */
    Int                 inc;            /* increment in a range            */
    UInt                block;          /* one block of <elms>             */
    UInt                bit;            /* one bit of a block              */
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
            pos = INT_INTOBJ( ELMW_LIST( poss, (Int)i ) );
            if ( lenList < pos ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    pos, 0L,
                    "you can assign a value and 'return;'" );
                return ELMS_LIST( list, poss );
            }

            /* select the element                                          */
            elm = ELM_BLIST( list, pos );

            /* assign the element into <elms>                              */
            if ( elm == True )
                block |= bit;
            bit <<= 1;
            if ( bit == 0 || i == lenPoss ) {
                BLOCK_ELM_BLIST( elms, i) =  block;
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
                "you can assign a value and 'return;'" );
            return ELMS_LIST( list, poss );
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                pos+(lenPoss-1)*inc, 0L,
                "you can assign a value and 'return;'" );
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
                BLOCK_ELM_BLIST(elms, i) =  block;
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
void AssBlist (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    /* if <pos> is less than the logical length and <elm> is 'true'        */
    if      ( pos <= LEN_BLIST(list) && val == True ) {
        SET_ELM_BLIST( list, pos, True );
        CLEAR_FILTS_LIST(list);
    }

    /* if <i> is less than the logical length and <elm> is 'false'         */
    else if ( pos <= LEN_BLIST(list) && val == False ) {
        SET_ELM_BLIST( list, pos, False );
        CLEAR_FILTS_LIST(list);
    }

    /* if <i> is one more than the logical length and <elm> is 'true'      */
    else if ( pos == LEN_BLIST(list)+1 && val == True ) {
        if ( SIZE_OBJ(list) < SIZE_PLEN_BLIST(pos) )
            ResizeBag( list, SIZE_PLEN_BLIST(pos) );
        SET_LEN_BLIST( list, pos );
        SET_ELM_BLIST( list, pos, True );
        CLEAR_FILTS_LIST(list);
    }

    /* if <i> is one more than the logical length and <elm> is 'false'     */
    else if ( pos == LEN_BLIST(list)+1 && val == False ) {
        if ( SIZE_OBJ(list) < SIZE_PLEN_BLIST(pos) )
            ResizeBag( list, SIZE_PLEN_BLIST(pos) );
        SET_LEN_BLIST( list, pos );
        SET_ELM_BLIST( list, pos, False );
        CLEAR_FILTS_LIST(list);
    }

    /* otherwise convert to ordinary list and assign as in 'AssList'       */
    else {
        PLAIN_LIST(list);
        CLEAR_FILTS_LIST(list);
        if ( LEN_PLIST(list) < pos ) {
            GROW_PLIST( list, (UInt)pos );
            SET_LEN_PLIST( list, pos );
        }
        SET_ELM_PLIST( list, pos, val );
        CHANGED_BAG( list );
    }
}


/****************************************************************************
**
*F  AssBlistImm( <list>, <pos>, <val> ) . assign to an immutable boolean list
*/
void AssBlistImm (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    ErrorReturnVoid(
        "Lists Assignment: <list> must be a mutable list",
        0L, 0L,
        "you can 'return;' and ignore the assignment" );
}


/****************************************************************************
**
*F  AsssBlist( <list>, <poss>, <vals> ) .  assign several elements to a blist
**
**  'AsssBlist' assignes the values  from  the list  <vals> at the  positions
**  given  in the  list  <poss>  to the   boolean  list  <list>.  It is   the
**  responsibility of the caller to ensure that  <poss> is dense and contains
**  only positive integers, that <poss> and <vals>  have the same length, and
**  that <vals> is dense.
**
**  'AsssBlist' is intended as function in 'AsssListFuncs' for boolean lists.
**  Note that currently, we use AsssListDefault instead. This ensures 
**  automatically that <list> remains a blist if possible.
**
*/
void AsssBlist (     /*  currently not used */
    Obj                 list,
    Obj                 poss,
    Obj                 vals )
{
   Int   i, len, pos;
   Obj   val;

   len = LEN_LIST(poss);
   for (i=1; i <= len; i++) {
      /* use generic macros because list might be unpacked */
      pos = INT_INTOBJ(ELMW_LIST(poss, i));
      val = ELMW_LIST(vals, i);
      ASS_LIST( list, pos, val);
    }
}


/****************************************************************************
**
*F  AsssBlistImm( <list>, <poss>, <vals> )  . .  assign to an immutable blist
*/
void AsssBlistImm (
    Obj                 list,
    Obj                 poss,
    Obj                 val )
{
    ErrorReturnVoid(
        "Lists Assignments: <list> must be a mutable list",
        0L, 0L,
        "you can 'return;' and ignore the assignment" );
}


/****************************************************************************
**

*F  PosBlist( <list>, <val>, <start> )   position of an elm in a boolean list
**
**  'PosBlist' returns the   position of  the first  occurrence  of the  value
**  <val>, which may be  an  object of  arbitrary  type, in the boolean  list
**  <list> after <start> as a C  integer.  If <val> does  not occur in <list>
**  after <start>, then 0 is returned.
**
**  'PosBlist' is the function in 'PosListFuncs' for boolean lists.
*/
Obj PosBlist (
    Obj                 list,
    Obj                 val,
    Obj                 start )
{
    Int                 len;            /* logical length of the list      */
    UInt *              ptr;            /* pointer to the blocks           */
    UInt                i,  j;          /* loop variables                  */
    UInt                istart;
    UInt                firstblock, lastblock;
    UInt                firstoffset, lastoffset;
    UInt                x;

    if (!IS_INTOBJ(start))
      return Fail;
    
    istart = INT_INTOBJ(start);

    len = LEN_BLIST(list);

    /* look just beyond end                                                */
    if ( len == istart ) {
      return Fail;
    }

    ptr = BLOCKS_BLIST(list);
    firstblock = istart/BIPEB;
    lastblock = (len-1)/BIPEB;
    firstoffset = istart%BIPEB;
    lastoffset = (len-1)%BIPEB;

    /* look for 'true'                                                     */
     if ( val == True ) {

       x = ptr[firstblock];
       if (firstblock == lastblock) 
         {
           if (x != 0)
             for (j = firstoffset; j <= lastoffset; j++)
               if ((x & (1UL << j)) != 0)
                 return INTOBJ_INT(BIPEB*firstblock + j + 1);
           return Fail;
         }
       if (x != 0)
         for (j = firstoffset; j < BIPEB; j++)
           if ((x & (1UL << j)) != 0)
             return INTOBJ_INT(BIPEB*firstblock + j + 1);
       for (i  = firstblock + 1; i < lastblock; i++)
         {
           x = ptr[i];
           if (x != 0)
             for (j = 0; j < BIPEB; j++)
               if ((x & (1UL << j)) != 0)
                 return INTOBJ_INT(BIPEB*i + j + 1);
         }
       x = ptr[lastblock];
       if (x != 0)
         for (j = 0; j <= lastoffset; j++)
           if ((x & (1UL << j)) != 0)
             return INTOBJ_INT(BIPEB*lastblock + j + 1);
       return Fail;
    }

    /* look for 'false'                                                    */
    else if ( val == False ) {
      x = ptr[firstblock];
      if (firstblock == lastblock) 
        {
          if (x != ~0UL)
            for (j = firstoffset; j <= lastoffset; j++)
              if ((x & (1UL << j)) == 0)
                return INTOBJ_INT(BIPEB*firstblock + j + 1);
           return Fail;
         }
       if (x != ~0UL)
         for (j = firstoffset; j < BIPEB; j++)
           if ((x & (1UL << j)) == 0)
             return INTOBJ_INT(BIPEB*firstblock + j + 1);
       for (i  = firstblock + 1; i < lastblock; i++)
         {
           x = ptr[i];
           if (x != ~0UL)
             for (j = 0; j < BIPEB; j++)
               if ((x & (1UL << j)) == 0)
                 return INTOBJ_INT(BIPEB*i + j + 1);
         }
       x = ptr[lastblock];
       if (x != ~0UL)
         for (j = 0; j <= lastoffset; j++)
           if ((x & (1UL << j)) == 0)
             return INTOBJ_INT(BIPEB*lastblock + j + 1);
       return Fail;
    }

    /* look for something else                                             */
    else {
      return Fail;
    }

}


/****************************************************************************
**
*F  PlainBlist( <list> )  . . .  convert a boolean list into an ordinary list
**
**  'PlainBlist' converts the boolean list <list> to a plain list.
**
**  'PlainBlist' is the function in 'PlainListFuncs' for boolean lists.
*/
void PlainBlist (
    Obj                 list )
{
    Int                 len;            /* length of <list>                */
    UInt                i;              /* loop variable                   */

    /* resize the list and retype it, in this order                        */
    len = LEN_BLIST(list);
    RetypeBag( list, IS_MUTABLE_OBJ(list) ? T_PLIST : T_PLIST+IMMUTABLE );
    GROW_PLIST( list, (UInt)len );
    SET_LEN_PLIST( list, len );

    /* replace the bits by 'True' or 'False' as the case may be            */
    /* this must of course be done from the end of the list backwards      */
    for ( i = len; 0 < i; i-- )
        SET_ELM_PLIST( list, i, ELM_BLIST( list, i ) );

    /* 'CHANGED_BAG' not needed, 'True' and 'False' are safe           */
}



/****************************************************************************
**
*F  IsPossBlist( <list> ) . .  positions list test function for boolean lists
**
**  'IsPossBlist' returns  1 if  <list> is  empty, and 0 otherwise, since a
**  boolean list is a positions list if and only if it is empty.
*/
Int IsPossBlist (
    Obj                 list )
{
    return LEN_BLIST(list) == 0;
}


/****************************************************************************
**

*F  IsDenseBlist( <list> )  . . .  dense list test function for boolean lists
**
**  'IsDenseBlist' returns 1, since boolean lists are always dense.
**
**  'IsDenseBlist' is the function in 'IsDenseBlistFuncs' for boolean lists.
*/
Int IsDenseBlist (
    Obj                 list )
{
    return 1L;
}


/****************************************************************************
**
*F  IsHomogBlist( <list> )  . . . . . . . . . . check if <list> is homogenous
*/
Int IsHomogBlist (
    Obj                 list )
{
    return (0 < LEN_BLIST(list));
}


/****************************************************************************
**
*F  IsSSortBlist( <list> )  . . . . . . .  check if <list> is strictly sorted
*/
Int IsSSortBlist (
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
    SET_FILT_LIST( list, (isSort ? FN_IS_SSORT : FN_IS_NSORT) );

    return isSort;
}


/****************************************************************************
**
*F  IsSSortBlistNot( <list> ) . . . . . . . . . . . . . unsorted boolean list
*/
Int IsSSortBlistNot (
    Obj                 list )
{
    return 0L;
}


/****************************************************************************
**
*F  IsSSortBlistYes( <list> ) . . . . . . . . . . . . . . sorted boolean list
*/
Int IsSSortBlistYes (
    Obj                 list )
{
    return 1L;
}


/****************************************************************************
**

*F  ConvBlist( <list> ) . . . . . . . . .  convert a list into a boolean list
**
**  `ConvBlist' changes the representation of boolean  lists into the compact
**  representation of type 'T_BLIST' described above.
*/
void ConvBlist (
    Obj                 list )
{
    Int                 len;            /* logical length of the list      */
    UInt                block;          /* one block of the boolean list   */
    UInt                bit;            /* one bit of a block              */
    UInt                i;              /* loop variable                   */

    /* if <list> is known to be a boolean list, it is very easy            */
    if ( IS_BLIST_REP(list) ) {
        return;
    }

    /* change its representation                                           */
    block = 0;
    bit = 1;
    len = LEN_LIST( list );
    for ( i = 1; i <= len; i++ ) {
        if ( ELMW_LIST( list, (Int)i ) == True )
            block |= bit;
        bit = bit << 1;
        if ( bit == 0 || i == len ) {
            BLOCK_ELM_BLIST(list,i) = block;
            block = 0;
            bit = 1;
        }
    }
    RetypeBag( list, IS_MUTABLE_OBJ(list) ? T_BLIST : T_BLIST+IMMUTABLE );
    ResizeBag( list, SIZE_PLEN_BLIST(len) );
    SET_LEN_BLIST( list, len );
}


/****************************************************************************
**
*F  IsBlist( <list> ) . . . . . . . . . test whether a list is a boolean list
**
**  'IsBlist' returns  1  if  the  list  <list> is  a  boolean list, i.e.,  a
**  list that   has no holes  and contains  only  'true' and  'false',  and 0
**  otherwise.
*/
Int IsBlist (
    Obj                 list )
{
    UInt                isBlist;        /* result of the test              */
    Int                 len;            /* logical length of the list      */
    UInt                i;              /* loop variable                   */

    /* if <list> is known to be a boolean list, it is very easy            */
    if ( IS_BLIST_REP(list) ) {
        isBlist = 1;
    }

    /* if <list> is not a small list, its not a boolean list (convert to list)   */
    else if ( ! IS_SMALL_LIST( list ) ) {
        isBlist = 0;
    }

    /* otherwise test if there are holes and if all elements are boolean   */
    else {

        /* test that all elements are bound and either 'true' or 'false'   */
        len = LEN_LIST( list );
        for ( i = 1; i <= len; i++ ) {
            if ( ELMV0_LIST( list, (Int)i ) == 0
              || (ELMW_LIST( list, (Int)i ) != True
               && ELMW_LIST( list, (Int)i ) != False) ) {
                break;
            }
        }

        isBlist = (len < i);
    }

    /* return the result                                                   */
    return isBlist;
}


/****************************************************************************
**
*F  IsBlistConv( <list> ) . test whether a list is a boolean list and convert
**
**  'IsBlistConv' returns 1 if  the list <list> is  a  boolean list, i.e.,  a
**  list that   has no holes  and contains  only  'true' and  'false',  and 0
**  otherwise.  As a  side effect 'IsBlistConv' changes the representation  of
**  boolean lists into the compact representation of type 'T_BLIST' described
**  above.
*/
Int IsBlistConv (
    Obj                 list )
{
    UInt                isBlist;        /* result of the test              */
    Int                 len;            /* logical length of the list      */
    UInt                i;              /* loop variable                   */

    /* if <list> is known to be a boolean list, it is very easy            */
    if ( IS_BLIST_REP(list) ) {
        isBlist = 1;
    }

    /* if <list> is not a list, its not a boolean list (convert to list)   */
    else if ( ! IS_SMALL_LIST(list) ) {
        isBlist = 0;
    }

    /* otherwise test if there are holes and if all elements are boolean   */
    else {

        /* test that all elements are bound and either 'true' or 'false'   */
        len = LEN_LIST( list );
        for ( i = 1;  i <= len;  i++ ) {
            if ( ELMV0_LIST( list, (Int)i ) == 0
              || (ELMW_LIST( list, (Int)i ) != True
               && ELMW_LIST( list, (Int)i ) != False) ) {
                break;
            }
        }

        /* if <list> is a boolean list, change its representation        */
        isBlist = (len < i);
        if ( isBlist ) {
            ConvBlist(list);
        }
    }

    /* return the result                                                   */
    return isBlist;
}


/****************************************************************************
**
*F  SizeBlist( <blist> )  . . . .  number of 'true' entries in a boolean list
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
*N  1996/11/12 Steve  altered to handle 64 bit also
**
**  Introduced the SizeBlist function for kernel use, and the 
**  COUNT_TRUES_BLOCK( <var> ) macro which replaces a block of bits in <var> 
**  by the number of ones it contains. It will fail horribly if <var> is not 
**  a variable.
*/
UInt SizeBlist (
    Obj                 blist )
{
    UInt *              ptr;            /* pointer to blist                */
    UInt                nrb;            /* number of blocks in blist       */
    UInt                m;              /* number of bits in a block       */
    UInt                n;              /* number of bits in blist         */
    UInt                i;              /* loop variable                   */

    /* get the number of blocks and a pointer                              */
    nrb = NUMBER_BLOCKS_BLIST(blist);
    ptr = BLOCKS_BLIST( blist );

    /* loop over the blocks, adding the number of bits of each one         */
    n = 0;
    for ( i = 1; i <= nrb; i++ ) {
        m = *ptr++;
        COUNT_TRUES_BLOCK(m);
        n += m;
    }

    /* return the number of bits                                           */
    return n;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * * GAP level functions  * * * * * * * * * * * * *
*/

/****************************************************************************
**


*F  FuncIS_BLIST( <self>, <val> ) . . . . . test if a value is a boolean list
**
**  'FuncIS_BLIST' handles the internal function 'IsBlist'.
**
**  'IsBlist( <val> )'
**
**  'IsBlist' returns 'true' if the value <val> is a boolean list and 'false'
**  otherwise.  A value is a   boolean list if  it is  a lists without  holes
**  containing only  'true' and 'false'.
*/
Obj IsBlistFilt;

Obj FuncIS_BLIST (
    Obj                 self,
    Obj                 val )
{
    /* let 'IsBlist' do the work                                           */
    return IsBlist( val ) ? True : False;
}


/****************************************************************************
**
*F  FuncIS_BLIST_CONV( <self>, <val> )  . . test if a value is a boolean list
**
**  'FuncIS_BLIST_CONV' handles the internal function 'IsBlist'.
**
**  'IsBlistConv( <val> )'
**
**  'IsBlist' returns 'true' if the value <val> is a boolean list and 'false'
**  otherwise.  A value is a   boolean list if  it is  a lists without  holes
**  containing only  'true' and 'false'.
*/
Obj IsBlistFilt;

Obj FuncIS_BLIST_CONV (
    Obj                 self,
    Obj                 val )
{
    /* let 'IsBlist' do the work                                           */
    return IsBlistConv( val ) ? True : False;
}


/****************************************************************************
**
*F  FuncCONV_BLIST( <self>, <blist> ) . . . . convert into a boolean list rep
*/
Obj FuncCONV_BLIST (
    Obj                 self,
    Obj                 blist )
{
    /* check whether <blist> is a boolean list                             */
    while ( ! IsBlistConv(blist) ) {
        blist = ErrorReturnObj(
            "CONV_BLIST: <blist> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(blist), 0L,
            "you can replace <blist> via 'return <blist>;'" );
    }

    /* return nothing                                                      */
    return 0;
}

/****************************************************************************
**
**
*F  FuncIS_BLIST_REP( <self>, <obj> ) . . test if value is a boolean list rep
*/
Obj IsBlistRepFilt;

Obj FuncIS_BLIST_REP (
    Obj                 self,
    Obj                 obj )
{
    return (IS_BLIST_REP( obj ) ? True : False);
}


/****************************************************************************
**

*F  FuncSIZE_BLIST( <self>, <blist> ) . . number of 'true' entries in <blist>
**
**  'FuncSIZE_BLIST' implements the internal function 'SizeBlist'
*/
Obj FuncSIZE_BLIST (
    Obj                 self,
    Obj                 blist )
{
    /* get and check the argument                                          */
    while ( ! IsBlistConv(blist) ) {
        blist = ErrorReturnObj(
            "SizeBlist: <blist> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(blist), 0L,
            "you can replace <blist> via 'return <blist>;'" );
    }
  
    return INTOBJ_INT(SizeBlist(blist));
}



/****************************************************************************
**
*F  FuncBLIST_LIST( <self>, <list>, <sub> )  make boolean list from a sublist
**
**  'FuncBLIST_LIST' implements the internal function 'BlistList'.
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
Obj FuncBLIST_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 sub )
{
    Obj                 blist;          /* boolean list, result            */
    UInt  *             ptrBlist;       /* pointer to the boolean list     */
    UInt                block;          /* one block of boolean list       */
    UInt                bit;            /* one bit of block                */
    Int                 lenList;        /* logical length of the list      */
    Obj *               ptrSub;         /* pointer to the sublist          */
    UInt                lenSub;         /* logical length of sublist       */
    UInt                i, j, k = 0, l;     /* loop variables                  */
    long                s, t;           /* elements of a range             */

    /* get and check the arguments                                         */
    while ( ! IS_SMALL_LIST(list) ) {
        list = ErrorReturnObj(
            "BlistList: <list> must be a small list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can replace <list> via 'return <list>;'" );
    }
    while ( ! IS_SMALL_LIST(sub) ) {
        sub = ErrorReturnObj(
            "BlistList: <sub> must be a small list (not a %s)",
            (Int)TNAM_OBJ(sub), 0L,
            "you can replace <sub> via 'return <sub>;'" );
    }

    /* for a range as subset of a range, it is extremely easy               */
    if ( IS_RANGE(list) && IS_RANGE(sub) && GET_INC_RANGE( list ) == 1
          && GET_INC_RANGE( sub ) == 1) {

        /* allocate the boolean list and get pointer                       */
        lenList  = GET_LEN_RANGE( list );
        lenSub   = GET_LEN_RANGE( sub );
        blist = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenList ) );
        ADDR_OBJ(blist)[0] = INTOBJ_INT(lenList);
        ptrBlist = BLOCKS_BLIST(blist);

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
            ptrBlist[(k-1)/BIPEB] = ~(UInt)0;
        for ( ; k <= j; k++ )
            ptrBlist[(k-1)/BIPEB] |= (1UL << (k-1)%BIPEB);

    }

    /* for a list as subset of a range, we need basically no search        */
    else if ( IS_RANGE(list) && GET_INC_RANGE( list) == 1
          && IS_PLIST(sub) ) {

        /* allocate the boolean list and get pointer                       */
        lenList  = GET_LEN_RANGE( list );
        lenSub   = LEN_LIST( sub );
        blist = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenList ) );
        ADDR_OBJ(blist)[0] = INTOBJ_INT(lenList);
        ptrBlist = BLOCKS_BLIST(blist);
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

     /* Nobody seems to remember what the code below is good for,
      * we will now just assume that non-immediate integers are
      * never in a range. I'll leave the old code in a comment
      * for a while, the third arg for PosRange is wrong anyway.
      * FL  */
                /* otherwise it may be a record, let 'PosRange' handle it  */
              /*  else {
                    Obj pos;
                    pos = PosRange( list, ptrSub[l], 0L );
                    if (pos != Fail) {
                      k = INT_INTOBJ(pos);
                      ptrBlist[(k-1)/BIPEB] |= (1UL << (k-1)%BIPEB);
                    }  
                } */

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
                      SET_ELM_BLIST( blist, k, True);
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
                  BLOCK_ELM_BLIST( blist, l) = block;
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
                BLOCK_ELM_BLIST( blist, l) =  block;
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
*F  FuncLIST_BLIST( <self>, <list>, <blist> ) . make a sublist from a <blist>
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
Obj FuncLIST_BLIST (
    Obj                 self,
    Obj                 list,
    Obj                 blist )
{
    Obj                 sub;            /* handle of the result            */
    Int                 len;            /* logical length of the list      */
    UInt                n;              /* number of bits in blist         */
    UInt                nn;
    UInt                i;              /* loop variable                   */

    /* get and check the first argument                                    */
    while ( ! IS_SMALL_LIST( list ) ) {
        list = ErrorReturnObj(
            "ListBlist: <list> must be a small list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can replace <list> via 'return <list>;'" );
    }
    /* get and check the second argument                                   */
    while ( ! IsBlistConv( blist ) ) {
        blist = ErrorReturnObj(
            "ListBlist: <blist> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(blist), 0L,
            "you can replace <blist> via 'return <blist>;'" );
    }
    while ( LEN_LIST( list ) != LEN_BLIST( blist ) ) {
        blist = ErrorReturnObj(
            "ListBlist: <blist> must have the same length as <list> (%d)",
            LEN_PLIST( list ), 0L,
            "you can replace <blist> via 'return <blist>;'" );
    }

    /* compute the number of 'true'-s                                      */
    n = SizeBlist(blist);

    /* make the sublist (we now know its size exactly)                    */
    sub = NEW_PLIST( IS_MUTABLE_OBJ(list) ? T_PLIST : T_PLIST+IMMUTABLE, n );
    SET_LEN_PLIST( sub, n );

    /* loop over the boolean list and stuff elements into <sub>            */
    len = LEN_LIST( list );
    nn  = 1;
    for ( i = 1;  nn <= n && i <= len;  i++  ) {
        if ( ELM_BLIST( blist, i ) == True ) {
            SET_ELM_PLIST( sub, (Int)nn, ELMW_LIST( list, (Int)i ) );
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
*N  Fix up for 64 bit SL
*/
Obj FuncPositionsTrueBlist (
    Obj                 self,
    Obj                 blist )
{
    Obj                 sub;            /* handle of the result            */
    Int                 len;            /* logical length of the list      */
    UInt  *             ptr;            /* pointer to blist                */
    UInt                nrb;            /* number of blocks in blist       */
    UInt                m;              /* number of bits in a block       */
    UInt                n;              /* number of bits in blist         */
    UInt                nn;
    UInt                i;              /* loop variable                   */

    /* get and check the first argument                                    */
    while ( ! IsBlistConv( blist ) ) {
        blist = ErrorReturnObj(
            "ListBlist: <blist> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(blist), 0L,
            "you can replace <blist> via 'return <blist>;'" );
    }

    /* compute the number of 'true'-s just as in 'FuncSIZE_BLIST'            */
    nrb = NUMBER_BLOCKS_BLIST( blist);
    ptr = BLOCKS_BLIST( blist );
    n = 0;
    for ( i = 1; i <= nrb; i++ ) {
        m = *ptr++;
        COUNT_TRUES_BLOCK(m);
        n += m;
    }

    /* make the sublist (we now know its size exactly)                    */
    sub = NEW_PLIST( T_PLIST, n );
    SET_LEN_PLIST( sub, n );

    /* loop over the boolean list and stuff elements into <sub>            */
    /* This could be a bit quicker for sparse blists by skipping whole empty
       blocks as we go past                  SL  9/1/97                    */
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
*F  FuncPositionNthTrueBlist( <self>, <blist>, <Nth> )  . . . find true value
**
*N  1992/12/15 martin this depends on 'BIPEB' being 32
*N  Fixed up for 64 SL
*/
Obj FuncPositionNthTrueBlist (

    Obj                 self,
    Obj                 blist,
    Obj                 Nth )
{
    UInt                nrb;
    Int                 nth,  pos,  i;
    UInt                m,  mask;
    UInt  *             ptr;

    /* Check the arguments. */    
    while ( ! IsBlistConv( blist ) ) {
        blist = ErrorReturnObj(
            "ListBlist: <blist> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(blist), 0L,
            "you can replace <blist> via 'return <blist>;'" );
    }
    while ( ! IS_INTOBJ(Nth) || INT_INTOBJ(Nth) <= 0 ) {
        Nth = ErrorReturnObj(
            "Position: <nth> must be a positive integer (not a %s)",
            (Int)TNAM_OBJ(Nth), 0L,
            "you can replace <nth> via 'return <nth>;'" );
    }
    
    nrb = NUMBER_BLOCKS_BLIST(blist);
    if ( ! nrb )  return Fail;
    nth = INT_INTOBJ( Nth );
    pos = 0;
    ptr = BLOCKS_BLIST( blist );
    i = 1;
    m = *ptr;
    COUNT_TRUES_BLOCK(m);
    while ( nth > m ) {
        if ( ++i > nrb )  return Fail;
        nth -= m;
        pos += BIPEB;
        ptr++;
        m = *ptr;
        COUNT_TRUES_BLOCK(m);
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
*F  FuncIsSubsetBlist( <self>, <list1>, <list2> ) . . . . . . . . subset test
**
**  'FuncIsSubsetBlist' implements the internal function 'IsSubsetBlist'.
**
**  'IsSubsetBlist( <list1>, <list2> )'
**
**  'IsSubsetBlist' returns 'true' if the boolean list <list2> is a subset of
**  the  boolean  list <list1>, which must  have  equal length.  <list2> is a
**  subset if <list1> if '<list2>[<i>] >= <list1>[<i>]' for all <i>.
*/
Obj FuncIS_SUB_BLIST (
    Obj                 self,
    Obj                 list1,
    Obj                 list2 )
{
    UInt *              ptr1;           /* pointer to the first argument   */
    UInt *              ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    /* get and check the arguments                                         */
    while ( ! IsBlistConv( list1 ) ) {
        list1 = ErrorReturnObj(
            "IsSubsetBlist: <blist1> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(list1), 0L,
            "you can replace <blist1> via 'return <blist1>;'" );
    }
    while ( ! IsBlistConv( list2 ) ) {
        list2 = ErrorReturnObj(
            "IsSubsetBlist: <blist2> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(list2), 0L,
            "you can replace <blist2> via 'return <blist2>;'" );
    }
    while ( LEN_BLIST(list1) != LEN_BLIST(list2) ) {
        list2 = ErrorReturnObj(
        "IsSubsetBlist: <blist2> must have the same length as <blist1> (%d)",
            LEN_BLIST(list1), 0L,
            "you can replace <blist2> via 'return <blist2>;'" );
    }

    /* test for subset property blockwise                                  */
    ptr1 = BLOCKS_BLIST(list1);
    ptr2 = BLOCKS_BLIST(list2);

    for ( i = NUMBER_BLOCKS_BLIST(list1); 0 < i; i-- ) {
        if ( *ptr1 != (*ptr1 | *ptr2) )
            break;
        ptr1++;  ptr2++;
    }

    /* if no counterexample was found, <blist2> is a subset of <blist1>    */
    return (i == 0) ? True : False;
}


/****************************************************************************
**
*F  FuncUNITE_BLIST( <self>, <list1>, <list2> ) . unite one list with another
**
**  'FuncUNITE_BLIST' implements the internal function 'UniteBlist'.
**
**  'UniteBlist( <blist1>, <blist2> )'
**
**  'UniteBlist'  unites  the  boolean list  <blist1>  with  the boolean list
**  <blist2>,  which  must  have the   same  length.  This  is  equivalent to
**  assigning '<blist1>[<i>] := <blist1>[<i>] or <blist2>[<i>]' for all <i>.
*/
Obj FuncUNITE_BLIST (
    Obj                 self,
    Obj                 list1,
    Obj                 list2 )
{
    UInt *              ptr1;           /* pointer to the first argument   */
    UInt *              ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    /* get and check the arguments                                         */
    while ( ! IsBlistConv( list1 ) ) {
        list1 = ErrorReturnObj(
            "UniteBlist: <blist1> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(list1), 0L,
            "you can replace <blist1> via 'return <blist1>;'" );
    }
    while ( ! IsBlistConv( list2 ) ) {
        list2 = ErrorReturnObj(
            "UniteBlist: <blist2> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(list2), 0L,
            "you can replace <blist2> via 'return <blist2>;'" );
    }
    while ( LEN_BLIST(list1) != LEN_BLIST(list2) ) {
        list2 = ErrorReturnObj(
           "UniteBlist: <blist2> must have the same length as <blist1> (%d)",
            LEN_BLIST(list1), 0L,
            "you can replace <blist2> via 'return <blist2>;'" );
    }

    /* compute the union by *or*-ing blockwise                             */
    ptr1 = BLOCKS_BLIST(list1);
    ptr2 = BLOCKS_BLIST(list2);
    for ( i = (LEN_BLIST(list1)+BIPEB-1)/BIPEB; 0 < i; i-- ) {
        *ptr1++ |= *ptr2++;
    }

    /* return nothing, this function is a procedure                        */
    return 0;
}


/****************************************************************************
**
*F  FuncUNITE_BLIST_LIST( <self>, <list>,<blist>, <sub> )
**
**  'FuncUNITE_BLIST_LIST' implements the internal function 'BlistList'.
**
**  'UniteBlistList( <list>,<blist>, <sub> )'
**
**  'UniteBlistList'  works like `BlistList', but adds the entries to the
**  existing <blist>.
*/
Obj FuncUNITE_BLIST_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 blist,
    Obj                 sub )
{
    UInt  *             ptrBlist;       /* pointer to the boolean list     */
    UInt                block;          /* one block of boolean list       */
    UInt                bit;            /* one bit of block                */
    Int                 lenList;        /* logical length of the list      */
    Obj *               ptrSub;         /* pointer to the sublist          */
    UInt                lenSub;         /* logical length of sublist       */
    UInt                i, j, k = 0, l;     /* loop variables                  */
    long                s, t;           /* elements of a range             */

    /* get and check the arguments                                         */
    while ( ! IS_SMALL_LIST(list) ) {
        list = ErrorReturnObj(
            "UniteBlistList: <list> must be a small list (not a %s)",
            (Int)TNAM_OBJ(list), 0L,
            "you can replace <list> via 'return <list>;'" );
    }
    while ( ! IsBlistConv( blist ) ) {
        blist = ErrorReturnObj(
            "UniteBlistList: <blist> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(blist), 0L,
            "you can replace <blist> via 'return <blist>;'" );
    }
    while ( ! IS_SMALL_LIST(sub) ) {
        sub = ErrorReturnObj(
            "UniteBlistList: <sub> must be a small list (not a %s)",
            (Int)TNAM_OBJ(sub), 0L,
            "you can replace <sub> via 'return <sub>;'" );
    }

    /* for a range as subset of a range, it is extremely easy               */
    if ( IS_RANGE(list) && IS_RANGE(sub) && GET_INC_RANGE( list ) == 1
          && GET_INC_RANGE( sub ) == 1) {

        /* allocate the boolean list and get pointer                       */
        lenList  = GET_LEN_RANGE( list );

        /* check length */
        while ( LEN_BLIST(blist) != lenList ) {
            blist = ErrorReturnObj(
              "UniteBlistList: <blist> must have the same length as <list> (%d)",
                lenList, 0L,
                "you can replace <blist> via 'return <blist>;'" );
        }

        lenSub   = GET_LEN_RANGE( sub );
        ptrBlist = BLOCKS_BLIST(blist);

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
            ptrBlist[(k-1)/BIPEB] = ~(UInt)0;
        for ( ; k <= j; k++ )
            ptrBlist[(k-1)/BIPEB] |= (1UL << (k-1)%BIPEB);

    }

    /* for a list as subset of a range, we need basically no search        */
    else if ( IS_RANGE(list) && GET_INC_RANGE( list) == 1
          && IS_PLIST(sub) ) {

        /* allocate the boolean list and get pointer                       */
        lenList  = GET_LEN_RANGE( list );

        /* check length */
        while ( LEN_BLIST(blist) != lenList ) {
            blist = ErrorReturnObj(
              "UniteBlistList: <blist> must have the same length as <list> (%d)",
                lenList, 0L,
                "you can replace <blist> via 'return <blist>;'" );
        }

        lenSub   = LEN_LIST( sub );
        ptrBlist = BLOCKS_BLIST(blist);
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

       /* see comment where PosRange was used above   FL */         
                /* otherwise it may be a record, let 'PosRange' handle it  */
              /*  else {
                  Obj pos;
                    pos = PosRange( list, ptrSub[l], 0L );
                    if (pos != Fail)
                      k = INT_INTOBJ(pos);
                    ptrBlist[(k-1)/BIPEB] |= (1UL << (k-1)%BIPEB);
                }    */

            }
        }

    }

    /* if <list> is a set we have two possibilities                        */
    else if ( IsSet( list ) ) {

        /* get the length of <list> and its logarithm                      */
        lenList = LEN_PLIST( list );

        /* check length */
        while ( LEN_BLIST(blist) != lenList ) {
            blist = ErrorReturnObj(
              "UniteBlistList: <blist> must have the same length as <list> (%d)",
                lenList, 0L,
                "you can replace <blist> via 'return <blist>;'" );
        }

        for ( i = lenList, l = 0; i != 0; i >>= 1, l++ ) ;
        PLAIN_LIST( sub );
        lenSub = LEN_LIST( sub );

        /* if <sub> is small, we loop over <sub> and use binary search     */
        if ( l * lenSub < 2 * lenList ) {

            /* allocate the boolean list and get pointer                   */

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
                      SET_ELM_BLIST( blist, k, True);
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
                  BLOCK_ELM_BLIST( blist, l) |= block;
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

        /* check length */
        while ( LEN_BLIST(blist) != lenList ) {
            blist = ErrorReturnObj(
              "UniteBlistList: <blist> must have the same length as <list> (%d)",
                lenList, 0L,
                "you can replace <blist> via 'return <blist>;'" );
        }

        lenSub   = LEN_PLIST( sub );

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
                BLOCK_ELM_BLIST( blist,l) |= block;
                block = 0;
                bit   = 1;
            }
        }

    }

    /* return */
    return 0;
}


/****************************************************************************
**
*F  FuncINTER_BLIST( <self>, <list1>, <list2> ) .  <list1> intersection <list2>
**
**  'FuncINTER_BLIST' implements the function 'IntersectBlist'.
**
**  'IntersectBlist( <list1>, <list2> )'
**
**  'IntersectBlist' intersects the   boolean list <list1> with  the  boolean
**  list <list2>, which  must have the  same length.   This is equivalent  to
**  assigning '<list1>[<i>] := <list1>[<i>] and <list2>[<i>]' for all <i>.
*/
Obj FuncINTER_BLIST (
    Obj                 self,
    Obj                 list1,
    Obj                 list2 )
{
    UInt  *             ptr1;           /* pointer to the first argument   */
    UInt  *             ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    /* get and check the arguments                                         */
    while ( ! IsBlistConv( list1 ) ) {
        list1 = ErrorReturnObj(
            "IntersectBlist: <blist1> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(list1), 0L,
            "you can replace <blist1> via 'return <blist1>;'" );
    }
    while ( ! IsBlistConv( list2 ) ) {
        list2 = ErrorReturnObj(
            "IntersectBlist: <blist2> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(list2), 0L,
            "you can replace <blist2> via 'return <blist2>;'" );
    }
    while ( LEN_BLIST(list1) != LEN_BLIST(list2) ) {
        list2 = ErrorReturnObj(
       "IntersectBlist: <blist2> must have the same length as <blist1> (%d)",
            LEN_BLIST(list1), 0L,
            "you can replace <blist2> via 'return <blist2>;'" );
    }

    /* compute the intersection by *and*-ing blockwise                     */
    ptr1 = BLOCKS_BLIST(list1);
    ptr2 = BLOCKS_BLIST(list2);
    for ( i = NUMBER_BLOCKS_BLIST(list1); 0 < i; i-- ) {
        *ptr1++ &= *ptr2++;
    }

    /* return nothing, this function is a procedure                        */
    return 0;
}


/****************************************************************************
**
*F  FuncSUBTR_BLIST( <self>, <list1>, <list2> ) . . . . . . <list1> - <list2>
**
**  'FuncSUBTR_BLIST' implements the internal function 'SubtractBlist'.
**
**  'SubtractBlist( <list1>, <list2> )'
**
**  'SubtractBlist' subtracts the boolean  list <list2> from the boolean list
**  <list1>, which  must have the  same length.  This is equivalent assigning
**  '<list1>[<i>] := <list1>[<i>] and not <list2>[<i>]' for all <i>.
*/
Obj FuncSUBTR_BLIST (
    Obj                 self,
    Obj                 list1,
    Obj                 list2 )
{
    UInt *              ptr1;           /* pointer to the first argument   */
    UInt *              ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    /* get and check the arguments                                         */
    while ( ! IsBlistConv( list1 ) ) {
        list1 = ErrorReturnObj(
            "SubtractBlist: <blist1> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(list1), 0L,
            "you can replace <blist1> via 'return <blist1>;'" );
    }
    while ( ! IsBlistConv( list2 ) ) {
        list2 = ErrorReturnObj(
            "SubtractBlist: <blist2> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(list2), 0L,
            "you can replace <blist2> via 'return <blist2>;'" );
    }
    while ( LEN_BLIST(list1) != LEN_BLIST(list2) ) {
        list2 = ErrorReturnObj(
        "SubtractBlist: <blist2> must have the same length as <blist1> (%d)",
            LEN_BLIST(list1), 0L,
            "you can replace <blist2> via 'return <blist2>;'" );
    }

    /* compute the difference by operating blockwise                       */
    ptr1 = BLOCKS_BLIST(list1);
    ptr2 = BLOCKS_BLIST(list2); 
    for ( i = NUMBER_BLOCKS_BLIST(list1); 0 < i; i-- ) 
      { 
        *ptr1++ &= ~ *ptr2++; 
      }

    /* return nothing, this function is a procedure */ return 0; }

/****************************************************************************
**
*F  FuncMEET_BLIST( <self>, <list1>, <list2> ) . . . 
**
**  'FuncSUBTR_BLIST' implements the internal function 'MeetBlist'.
**
**  'MeetBlist( <list1>, <list2> )'
**
**  'MeetBlist' returns true if list1 and list2 have true in the same
**  position and false otherwise. It is equivalent to, but faster than
**  SizeBlist(IntersectionBlist(list1, list2)) <> 0
**  The lists must have the same length.
*/

Obj FuncMEET_BLIST (
    Obj                 self,
    Obj                 list1,
    Obj                 list2 )
{
    UInt *              ptr1;           /* pointer to the first argument   */
    UInt *              ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    /* get and check the arguments                                         */
    while ( ! IsBlistConv( list1 ) ) {
        list1 = ErrorReturnObj(
            "MeetBlist: <blist1> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(list1), 0L,
            "you can replace <blist1> via 'return <blist1>;'" );
    }
    while ( ! IsBlistConv( list2 ) ) {
        list2 = ErrorReturnObj(
            "MeetBlist: <blist2> must be a boolean list (not a %s)",
            (Int)TNAM_OBJ(list2), 0L,
            "you can replace <blist2> via 'return <blist2>;'" );
    }
    while ( LEN_BLIST(list1) != LEN_BLIST(list2) ) {
        list2 = ErrorReturnObj(
        "MeetBlist: <blist2> must have the same length as <blist1> (%d)",
            LEN_BLIST(list1), 0L,
            "you can replace <blist2> via 'return <blist2>;'" );
    }

    /* compute the difference by operating blockwise                       */
    ptr1 = BLOCKS_BLIST(list1);
    ptr2 = BLOCKS_BLIST(list2); 
    for ( i = NUMBER_BLOCKS_BLIST(list1); 0 < i; i-- ) 
      { 
	if (*ptr1++ & *ptr2++) return True;
      }

    return False;
}


/****************************************************************************
**
**
*F  MakeImmutableBlist( <blist> )
*/

void MakeImmutableBlist( Obj blist )
{
  RetypeBag(blist, IMMUTABLE_TNUM(TNUM_OBJ(blist)));
}

/****************************************************************************
**
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_BLIST,                           "list (boolean)"                  },
  { T_BLIST       +IMMUTABLE,          "list (boolean,imm)"              },
  { T_BLIST                  +COPYING, "list (boolean,copied)"           },
  { T_BLIST       +IMMUTABLE +COPYING, "list (boolean,imm,copied)"       },
  { T_BLIST_NSORT,                     "list (boolean,nsort)"            },
  { T_BLIST_NSORT +IMMUTABLE,          "list (boolean,nsort,imm)"        },
  { T_BLIST_NSORT            +COPYING, "list (boolean,nsort,copied)"     },
  { T_BLIST_NSORT +IMMUTABLE +COPYING, "list (boolean,nsort,imm,copied)" },
  { T_BLIST_SSORT,                     "list (boolean,ssort)"            },
  { T_BLIST_SSORT +IMMUTABLE,          "list (boolean,ssort,imm)"        },
  { T_BLIST_SSORT            +COPYING, "list (boolean,ssort,copied)"     },
  { T_BLIST_SSORT +IMMUTABLE +COPYING, "list (boolean,ssort,imm,copied)" },
  { -1,                                ""                                }
};


/****************************************************************************
**
*V  ClearFiltsTab . . . . . . . . . . . . . . . . . . . .  clear filter tnums
*/
static Int ClearFiltsTab [] = {
    T_BLIST,                 T_BLIST,
    T_BLIST      +IMMUTABLE, T_BLIST+IMMUTABLE,
    T_BLIST_NSORT,           T_BLIST,
    T_BLIST_NSORT+IMMUTABLE, T_BLIST+IMMUTABLE,
    T_BLIST_SSORT,           T_BLIST,
    T_BLIST_SSORT+IMMUTABLE, T_BLIST+IMMUTABLE,
    -1,                      -1
};


/****************************************************************************
**
*V  HasFiltTab  . . . . . . . . . . . . . . . . . . . . .  tester filter tnum
*/
static Int HasFiltTab [] = {

    /* mutable boolean list                                                */
    T_BLIST,                    FN_IS_MUTABLE,  1,
    T_BLIST,                    FN_IS_EMPTY,    0,
    T_BLIST,                    FN_IS_DENSE,    1,
    T_BLIST,                    FN_IS_NDENSE,   0,
    T_BLIST,                    FN_IS_HOMOG,    1,
    T_BLIST,                    FN_IS_NHOMOG,   0,
    T_BLIST,                    FN_IS_TABLE,    0,
    T_BLIST,                    FN_IS_SSORT,    0,
    T_BLIST,                    FN_IS_NSORT,    0,

    /* immutable boolean list                                               */
    T_BLIST      +IMMUTABLE,    FN_IS_MUTABLE,  0,
    T_BLIST      +IMMUTABLE,    FN_IS_EMPTY,    0,
    T_BLIST      +IMMUTABLE,    FN_IS_DENSE,    1,
    T_BLIST      +IMMUTABLE,    FN_IS_NDENSE,   0,
    T_BLIST      +IMMUTABLE,    FN_IS_HOMOG,    1,
    T_BLIST      +IMMUTABLE,    FN_IS_NHOMOG,   0,
    T_BLIST      +IMMUTABLE,    FN_IS_TABLE,    0,
    T_BLIST      +IMMUTABLE,    FN_IS_SSORT,    0,
    T_BLIST      +IMMUTABLE,    FN_IS_NSORT,    0,

    /* nsort mutable boolean list                                          */
    T_BLIST_NSORT,              FN_IS_MUTABLE,  1,
    T_BLIST_NSORT,              FN_IS_EMPTY,    0,
    T_BLIST_NSORT,              FN_IS_DENSE,    1,
    T_BLIST_NSORT,              FN_IS_NDENSE,   0,
    T_BLIST_NSORT,              FN_IS_HOMOG,    1,
    T_BLIST_NSORT,              FN_IS_NHOMOG,   0,
    T_BLIST_NSORT,              FN_IS_TABLE,    0,
    T_BLIST_NSORT,              FN_IS_SSORT,    0,
    T_BLIST_NSORT,              FN_IS_NSORT,    1,

    /* nsort immutable boolean list                                        */
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_MUTABLE,  0,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_EMPTY,    0,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_DENSE,    1,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_NDENSE,   0,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_HOMOG,    1,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_NHOMOG,   0,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_TABLE,    0,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_SSORT,    0,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_NSORT,    1,

    /* ssort mutable boolean list                                          */
    T_BLIST_SSORT,              FN_IS_MUTABLE,  1,
    T_BLIST_SSORT,              FN_IS_EMPTY,    0,
    T_BLIST_SSORT,              FN_IS_DENSE,    1,
    T_BLIST_SSORT,              FN_IS_NDENSE,   0,
    T_BLIST_SSORT,              FN_IS_HOMOG,    1,
    T_BLIST_SSORT,              FN_IS_NHOMOG,   0,
    T_BLIST_SSORT,              FN_IS_TABLE,    0,
    T_BLIST_SSORT,              FN_IS_SSORT,    1,
    T_BLIST_SSORT,              FN_IS_NSORT,    0,

    /* ssort immutable boolean list                                        */
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_MUTABLE,  0,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_EMPTY,    0,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_DENSE,    1,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_NDENSE,   0,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_HOMOG,    1,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_NHOMOG,   0,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_TABLE,    0,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_SSORT,    1,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_NSORT,    0,

    -1,                         -1,             -1
};


/****************************************************************************
**
*V  SetFiltTab  . . . . . . . . . . . . . . . . . . . . .  setter filter tnum
*/
static Int SetFiltTab [] = {

    /* mutable boolean list                                                */
    T_BLIST,                    FN_IS_MUTABLE,  T_BLIST,
    T_BLIST,                    FN_IS_EMPTY,    T_BLIST_SSORT,
    T_BLIST,                    FN_IS_DENSE,    T_BLIST,
    T_BLIST,                    FN_IS_NDENSE,   -1,
    T_BLIST,                    FN_IS_HOMOG,    T_BLIST,
    T_BLIST,                    FN_IS_NHOMOG,   -1,
    T_BLIST,                    FN_IS_TABLE,    -1,
    T_BLIST,                    FN_IS_SSORT,    T_BLIST_SSORT,
    T_BLIST,                    FN_IS_NSORT,    T_BLIST_NSORT,

    /* immutable boolean list                                              */
    T_BLIST      +IMMUTABLE,    FN_IS_MUTABLE,  T_BLIST,
    T_BLIST      +IMMUTABLE,    FN_IS_EMPTY,    T_BLIST_SSORT+IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_DENSE,    T_BLIST      +IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_NDENSE,   -1,
    T_BLIST      +IMMUTABLE,    FN_IS_HOMOG,    T_BLIST      +IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_NHOMOG,   -1,
    T_BLIST      +IMMUTABLE,    FN_IS_TABLE,    -1,
    T_BLIST      +IMMUTABLE,    FN_IS_SSORT,    T_BLIST_SSORT+IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_NSORT,    T_BLIST_NSORT+IMMUTABLE,

    /* nsort mutable boolean list                                          */
    T_BLIST_NSORT,              FN_IS_MUTABLE,  T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_EMPTY,    -1,
    T_BLIST_NSORT,              FN_IS_DENSE,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_NDENSE,   -1,
    T_BLIST_NSORT,              FN_IS_HOMOG,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_NHOMOG,   -1,
    T_BLIST_NSORT,              FN_IS_TABLE,    -1,
    T_BLIST_NSORT,              FN_IS_SSORT,    -1,
    T_BLIST_NSORT,              FN_IS_NSORT,    T_BLIST_NSORT,

    /* nsort immutable boolean list                                        */
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_MUTABLE,  T_BLIST_NSORT,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_EMPTY,    -1,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_DENSE,    T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_NDENSE,   -1,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_HOMOG,    T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_NHOMOG,   -1,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_TABLE,    -1,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_SSORT,    -1,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_NSORT,    T_BLIST_NSORT+IMMUTABLE,

    /* ssort mutable boolean list                                          */
    T_BLIST_SSORT,              FN_IS_MUTABLE,  T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_EMPTY,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_DENSE,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_NDENSE,   -1,
    T_BLIST_SSORT,              FN_IS_HOMOG,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_NHOMOG,   -1,
    T_BLIST_SSORT,              FN_IS_TABLE,    -1,
    T_BLIST_SSORT,              FN_IS_SSORT,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_NSORT,    -1,

    /* ssort immutable boolean list                                        */
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_MUTABLE,  T_BLIST_SSORT,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_EMPTY,    T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_DENSE,    T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_NDENSE,   -1,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_HOMOG,    T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_NHOMOG,   -1,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_TABLE,    -1,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_SSORT,    T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_NSORT,    -1,

    -1,                         -1,             -1

};


/****************************************************************************
**
*V  ResetFiltTab  . . . . . . . . . . . . . . . . . . .  unsetter filter tnum
*/
static Int ResetFiltTab [] = {

    /* mutable boolean list                                                */
    T_BLIST,                    FN_IS_MUTABLE,  T_BLIST      +IMMUTABLE,
    T_BLIST,                    FN_IS_EMPTY,    T_BLIST,
    T_BLIST,                    FN_IS_DENSE,    T_BLIST,
    T_BLIST,                    FN_IS_NDENSE,   T_BLIST,
    T_BLIST,                    FN_IS_HOMOG,    T_BLIST,
    T_BLIST,                    FN_IS_NHOMOG,   T_BLIST,
    T_BLIST,                    FN_IS_TABLE,    T_BLIST,
    T_BLIST,                    FN_IS_SSORT,    T_BLIST,
    T_BLIST,                    FN_IS_NSORT,    T_BLIST,

    /* immutable boolean list                                               */
    T_BLIST      +IMMUTABLE,    FN_IS_MUTABLE,  T_BLIST      +IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_EMPTY,    T_BLIST      +IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_DENSE,    T_BLIST      +IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_NDENSE,   T_BLIST      +IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_HOMOG,    T_BLIST      +IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_NHOMOG,   T_BLIST      +IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_NSORT,    T_BLIST      +IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_SSORT,    T_BLIST      +IMMUTABLE,
    T_BLIST      +IMMUTABLE,    FN_IS_TABLE,    T_BLIST      +IMMUTABLE,

    /* nsort mutable boolean list                                          */
    T_BLIST_NSORT,              FN_IS_MUTABLE,  T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT,              FN_IS_EMPTY,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_DENSE,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_NDENSE,   T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_HOMOG,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_NHOMOG,   T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_TABLE,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_SSORT,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_NSORT,    T_BLIST,

    /* nsort immutable boolean list                                        */
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_MUTABLE,  T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_EMPTY,    T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_DENSE,    T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_NDENSE,   T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_HOMOG,    T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_NHOMOG,   T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_TABLE,    T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_SSORT,    T_BLIST_NSORT+IMMUTABLE,
    T_BLIST_NSORT+IMMUTABLE,    FN_IS_NSORT,    T_BLIST      +IMMUTABLE,

    /* ssort mutable boolean list                                          */
    T_BLIST_SSORT,              FN_IS_MUTABLE,  T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT,              FN_IS_EMPTY,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_DENSE,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_NDENSE,   T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_HOMOG,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_NHOMOG,   T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_TABLE,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_SSORT,    T_BLIST,
    T_BLIST_SSORT,              FN_IS_NSORT,    T_BLIST_SSORT,

    /* ssort immutable boolean list                                        */
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_MUTABLE,  T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_EMPTY,    T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_DENSE,    T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_NDENSE,   T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_HOMOG,    T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_NHOMOG,   T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_TABLE,    T_BLIST_SSORT+IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_SSORT,    T_BLIST      +IMMUTABLE,
    T_BLIST_SSORT+IMMUTABLE,    FN_IS_NSORT,    T_BLIST_SSORT+IMMUTABLE,

    -1,                         -1,             -1

};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    { "IS_BLIST", "obj", &IsBlistFilt, 
      FuncIS_BLIST, "src/blister.c:IS_BLIST" },

    { "IS_BLIST_REP", "obj", &IsBlistRepFilt, 
      FuncIS_BLIST_REP, "src/blister.c:IS_BLIST_REP" },

    { 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "IS_BLIST_CONV", 1, "obj", 
      FuncIS_BLIST_CONV, "src/blister.c:IS_BLIST_CONV" },

    { "CONV_BLIST", 1, "blist",
      FuncCONV_BLIST, "src/blister.c:CONV_BLIST" },

    { "BLIST_LIST", 2, "list, sub",
      FuncBLIST_LIST, "src/blister.c:BLIST_LIST" },

    { "LIST_BLIST", 2, "list, blist",
      FuncLIST_BLIST, "src/blister.c:LIST_BLIST" },

    { "SIZE_BLIST", 1, "blist",
      FuncSIZE_BLIST, "src/blister.c:SIZE_BLIST" },

    { "IS_SUB_BLIST", 2, "blist1, blist2",
      FuncIS_SUB_BLIST, "src/blister.c:IS_SUB_BLIST" },

    { "UNITE_BLIST", 2, "blist1, blist2",
      FuncUNITE_BLIST, "src/blister.c:UNITE_BLIST" },

    { "UNITE_BLIST_LIST", 3, "list, blist, sub",
      FuncUNITE_BLIST_LIST, "src/blister.c:UNITE_BLIST_LIST" },

    { "INTER_BLIST", 2, "blist1, blist2",
      FuncINTER_BLIST, "src/blister.c:INTER_BLIST" },

    { "SUBTR_BLIST", 2, "blist1, blist2",
      FuncSUBTR_BLIST, "src/blister.c:SUBTR_BLIST" },

    { "MEET_BLIST", 2, "blist1, blist2",
      FuncMEET_BLIST, "src/blister.c:MEET_BLIST" },

    { "PositionNthTrueBlist", 2, "blist, nth",
      FuncPositionNthTrueBlist, "src/blister.c:PositionNthTrueBlist" },

    { "PositionsTrueBlist", 1, "blist",
      FuncPositionsTrueBlist, "src/blister.c:PositionsTrueBlist" },

    { 0 }

};


/****************************************************************************
**

*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                t1;
    UInt                t2;

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* GASMAN marking functions and GASMAN names                           */
    InitBagNamesFromTable( BagNames );

    for ( t1 = T_BLIST;  t1 <= T_BLIST_SSORT;  t1 += 2 ) {
        InitMarkFuncBags( t1,                      MarkNoSubBags  );
        InitMarkFuncBags( t1 +IMMUTABLE,           MarkNoSubBags  );
        InitMarkFuncBags( t1            +COPYING , MarkOneSubBags );
        InitMarkFuncBags( t1 +IMMUTABLE +COPYING , MarkOneSubBags );
    }

    /* Make immutable blists public					   */
    for ( t1 = T_BLIST; t1 <= T_BLIST_SSORT; t1 += 2 ) {
        MakeBagTypePublic( t1 + IMMUTABLE );
    }

    /* install the type methods                                            */
    TypeObjFuncs[ T_BLIST ] = TypeBlistMut;
    TypeObjFuncs[ T_BLIST +IMMUTABLE ] = TypeBlistImm;
    TypeObjFuncs[ T_BLIST_NSORT ] = TypeBlistNSortMut;
    TypeObjFuncs[ T_BLIST_NSORT +IMMUTABLE ] = TypeBlistNSortImm;
    TypeObjFuncs[ T_BLIST_SSORT ] = TypeBlistSSortMut;
    TypeObjFuncs[ T_BLIST_SSORT +IMMUTABLE ] = TypeBlistSSortImm;

    /* initialise list tables                                              */
    InitClearFiltsTNumsFromTable   ( ClearFiltsTab );
    InitHasFiltListTNumsFromTable  ( HasFiltTab    );
    InitSetFiltListTNumsFromTable  ( SetFiltTab    );
    InitResetFiltListTNumsFromTable( ResetFiltTab  );

    /* Install the saving functions -- cannot save while copying           */
    for ( t1 = T_BLIST;  t1 <= T_BLIST_SSORT;  t1 += 2 ) {
        SaveObjFuncs[ t1            ] = SaveBlist;
        SaveObjFuncs[ t1 +IMMUTABLE ] = SaveBlist;
        LoadObjFuncs[ t1            ] = LoadBlist;
        LoadObjFuncs[ t1 +IMMUTABLE ] = LoadBlist;
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
	ShallowCopyObjFuncs[ t1 ] = ShallowCopyBlist;
	ShallowCopyObjFuncs[ t1 +IMMUTABLE ] = ShallowCopyBlist;
    }

    /* install the comparison methods                                      */
    for ( t1 = T_BLIST;  t1 <= T_BLIST_SSORT+IMMUTABLE;  t1++ ) {
        for ( t2 = T_BLIST;  t2 <= T_BLIST_SSORT+IMMUTABLE;  t2++ ) {
            EqFuncs[ t1 ][ t2 ] = EqBlist;
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
        AsssListFuncs   [ t1            ] = AsssListDefault;
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
        MakeImmutableObjFuncs [ t1      ] = MakeImmutableBlist;
    }
    IsSSortListFuncs[ T_BLIST_NSORT            ] = IsSSortBlistNot;
    IsSSortListFuncs[ T_BLIST_NSORT +IMMUTABLE ] = IsSSortBlistNot;
    IsSSortListFuncs[ T_BLIST_SSORT            ] = IsSSortBlistYes;
    IsSSortListFuncs[ T_BLIST_SSORT +IMMUTABLE ] = IsSSortBlistYes;

    /* Import the types of blists: */
    ImportGVarFromLibrary( "TYPE_BLIST_MUT", &TYPE_BLIST_MUT );
    ImportGVarFromLibrary( "TYPE_BLIST_IMM", &TYPE_BLIST_IMM );
    ImportGVarFromLibrary( "TYPE_BLIST_NSORT_MUT", &TYPE_BLIST_NSORT_MUT );
    ImportGVarFromLibrary( "TYPE_BLIST_NSORT_IMM", &TYPE_BLIST_NSORT_IMM );
    ImportGVarFromLibrary( "TYPE_BLIST_SSORT_MUT", &TYPE_BLIST_SSORT_MUT );
    ImportGVarFromLibrary( "TYPE_BLIST_SSORT_IMM", &TYPE_BLIST_SSORT_IMM );
    ImportGVarFromLibrary( "TYPE_BLIST_EMPTY_MUT", &TYPE_BLIST_EMPTY_MUT );
    ImportGVarFromLibrary( "TYPE_BLIST_EMPTY_IMM", &TYPE_BLIST_EMPTY_IMM );

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
*F  InitInfoBlist() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "blister",                          /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoBlist ( void )
{
    return &module;
}


/****************************************************************************
**

*E  blister.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
