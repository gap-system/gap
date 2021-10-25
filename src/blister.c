/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
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
**  'LEN_BLIST', 'SET_LEN_BLIST', 'ELM_BLIST', and 'SET_ELM_BLIST'. They
**  determine the  representation of boolean  lists.
**  The  rest  of the {\GAP} kernel  uses those macros  to access and  modify
**  boolean lists.
**
**  The  second  part  consists  of  the  functions  'LenBlist',  'ElmBlist',
**  'ElmsBlist',   'AssBlist',    'AsssBlist',   'PosBlist',    'PlainBlist',
**  'IsPossBlist', 'EqBlist', and  'LtBlist'.  They  are the
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

#include "blister.h"

#include "ariths.h"
#include "bits_intern.h"
#include "bool.h"
#include "error.h"
#include "gaputils.h"
#include "io.h"
#include "lists.h"
#include "modules.h"
#include "plist.h"
#include "range.h"
#include "saveload.h"
#include "set.h"

#include "config.h"


#define RequireBlist(funcname, op)                                           \
    RequireArgumentCondition(funcname, op, IsBlistConv(op),                  \
                             "must be a boolean list")

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
static Obj TYPE_BLIST_MUT;
static Obj TYPE_BLIST_IMM;
static Obj TYPE_BLIST_NSORT_MUT;
static Obj TYPE_BLIST_NSORT_IMM;
static Obj TYPE_BLIST_SSORT_MUT;
static Obj TYPE_BLIST_SSORT_IMM;
static Obj TYPE_BLIST_EMPTY_MUT;
static Obj TYPE_BLIST_EMPTY_IMM;

static Obj TypeBlist(Obj list)
{
    /* special case for the empty blist                                    */
    if ( LEN_BLIST(list) == 0 ) {
        return IS_MUTABLE_OBJ(list) ? TYPE_BLIST_EMPTY_MUT
                                    : TYPE_BLIST_EMPTY_IMM;
    } else {
        return IS_MUTABLE_OBJ(list) ? TYPE_BLIST_MUT : TYPE_BLIST_IMM;
    }
}

static Obj TypeBlistNSort(Obj list)
{
    /* special case for the empty blist                                    */
    if ( LEN_BLIST(list) == 0 ) {
        return IS_MUTABLE_OBJ(list) ? TYPE_BLIST_EMPTY_MUT
                                    : TYPE_BLIST_EMPTY_IMM;
    } else {
        return IS_MUTABLE_OBJ(list) ? TYPE_BLIST_NSORT_MUT
                                    : TYPE_BLIST_NSORT_IMM;
    }
}

static Obj TypeBlistSSort(Obj list)
{
    /* special case for the empty blist                                    */
    if ( LEN_BLIST(list) == 0 ) {
        return IS_MUTABLE_OBJ(list) ? TYPE_BLIST_EMPTY_MUT
                                    : TYPE_BLIST_EMPTY_IMM;
    } else {
        return IS_MUTABLE_OBJ(list) ? TYPE_BLIST_SSORT_MUT
                                    : TYPE_BLIST_SSORT_IMM;
    }
}

/****************************************************************************
**
*F  SaveBlist( <blist> ) . . . . . . . . . . . . . . . . . . . . save a blist
**
**   The saving method for the blist tnums
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveBlist(Obj bl)
{
    UInt                i;
    const UInt *        ptr;

    /* logical length                                                      */
    SaveSubObj(CONST_ADDR_OBJ(bl)[0]);
    ptr = CONST_BLOCKS_BLIST(bl);
    for (i = 1; i <= NUMBER_BLOCKS_BLIST( bl ); i++ )
        SaveUInt(*ptr++);
}
#endif


/****************************************************************************
**
*F  LoadBlist( <blist> ) . . . . . . . . . . . . . . . . . . . . load a blist
**
**   The loading method for the blist tnums
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadBlist(Obj bl)
{
    UInt                i;
    UInt *              ptr;
  
    /* get the length back, then NUMBER_BLOCKS_BLIST is OK                 */
    ADDR_OBJ(bl)[0] = LoadSubObj(); 
  
    /* Now load the real data                                              */
    ptr = BLOCKS_BLIST(bl);
    for (i = 1; i <= NUMBER_BLOCKS_BLIST( bl ); i++ )
        *ptr++ = LoadUInt();
}
#endif


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
*/

static Obj DoCopyBlist(Obj list, Int mut)
{
    Obj copy;

    /* make a copy                                                         */
    copy = NewBag(MUTABLE_TNUM(TNUM_OBJ(list)), SIZE_OBJ(list));
    if (!mut)
        MakeImmutableNoRecurse(copy);

    /* copy the subvalues                                                  */
    memcpy(ADDR_OBJ(copy), CONST_ADDR_OBJ(list),
            sizeof(UInt)*(1+NUMBER_BLOCKS_BLIST(list)));

    /* return the copy                                                     */
    return copy;
  
}

#if !defined(USE_THREADSAFE_COPYING)

static Obj CopyBlist(Obj list, Int mut)
{
    Obj copy;

    // immutable input is handled by COPY_OBJ
    GAP_ASSERT(IS_MUTABLE_OBJ(list));

    copy = DoCopyBlist(list, mut);

    /* leave a forwarding pointer */
    PrepareCopy(list, copy);
    return copy;
}

#endif // !defined(USE_THREADSAFE_COPYING)


static Obj ShallowCopyBlist(Obj list)
{
  return DoCopyBlist(list, 1);
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
static Int EqBlist(Obj listL, Obj listR)
{
    long                lenL;           /* length of the left operand      */
    long                lenR;           /* length of the right operand     */
    const UInt *        ptrL;           /* pointer to the left operand     */
    const UInt *        ptrR;           /* pointer to the right operand    */
    UInt                i;              /* loop variable                   */

    /* get the lengths of the lists and compare them                       */
    lenL = LEN_BLIST( listL );
    lenR = LEN_BLIST( listR );
    if ( lenL != lenR ) {
        return 0;
    }

    /* test for equality blockwise                                         */
    ptrL = CONST_BLOCKS_BLIST(listL);
    ptrR = CONST_BLOCKS_BLIST(listR);
    for ( i = (lenL+BIPEB-1)/BIPEB; 0 < i; i-- ) {
        if ( *ptrL++ != *ptrR++ )
            return 0;
    }

    /* no differences found, the lists are equal                           */
    return 1;
}


/****************************************************************************
**
*F  LenBlist( <list> )  . . . . . . . . . . . . . .  length of a boolean list
**
**  'LenBlist' returns the length of the boolean list <list> as a C integer.
**
**  'LenBlist' is the function in 'LenListFuncs' for boolean lists.
*/
static Int LenBlist(Obj list)
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
static BOOL IsbBlist(Obj list, Int pos)
{
    return (pos <= LEN_BLIST(list));
}


/****************************************************************************
**
*F  Elm0Blist( <list>, <pos> )  . . . . . select an element of a boolean list
**
**  'Elm0Blist' returns the element at the position <pos> of the boolean list
**  <list>, or 0 if  <list>  has no  assigned object  at  <pos>.  It  is  the
**  responsibility of the caller to ensure that <pos> is a positive integer.
*/
static Obj Elm0Blist(Obj list, Int pos)
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
**  'Elm0vPlist' does the same thing as 'Elm0Blist', but does not need to
**  check that <pos> is less than or equal to the length of <list>, this is
**  the responsibility of the caller.
*/
static Obj Elm0vBlist(Obj list, Int pos)
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
static Obj ElmBlist(Obj list, Int pos)
{

    /* check the position                                                  */
    if ( LEN_BLIST( list ) < pos ) {
        ErrorMayQuit("List Element: <list>[%d] must have an assigned value",
                     pos, 0);
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
static Obj ElmvBlist(Obj list, Int pos)
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
static Obj ElmsBlist(Obj list, Obj poss)
{
    Obj                 elms;           /* selected sublist, result        */
    Int                 lenList;        /* length of <list>                */
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
            Obj p = ELMW_LIST(poss, i);
            if (!IS_INTOBJ(p)) {
                ErrorMayQuit("List Elements: position is too large for "
                             "this type of list",
                             0, 0);
            }
            pos = INT_INTOBJ(p);

            /* select the element                                          */
            if ( lenList < pos ) {
                ErrorMayQuit(
                    "List Elements: <list>[%d] must have an assigned value",
                    pos, 0);
            }

            /* assign the element into <elms>                              */
            if (TEST_BIT_BLIST(list, pos))
                block |= bit;
            bit <<= 1;
            if ( bit == 0 || i == lenPoss ) {
                *BLOCK_ELM_BLIST_PTR(elms, i) = block;
                block = 0;
                bit = 1;
            }

        }

    }

    /* special code for ranges                                             */
    else {

        /* get the length of <list>                                        */
        lenList = LEN_BLIST( list );

        /* get the length of <positions>, the first elements, and the inc. */
        lenPoss = GET_LEN_RANGE( poss );
        pos = GET_LOW_RANGE( poss );
        inc = GET_INC_RANGE( poss );

        /* check that no <position> is larger than 'LEN_LIST(<list>)'      */
        if ( lenList < pos ) {
            ErrorMayQuit(
                "List Elements: <list>[%d] must have an assigned value", pos,
                0);
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorMayQuit(
                "List Elements: <list>[%d] must have an assigned value",
                pos + (lenPoss - 1) * inc, 0);
        }

        /* make the result list                                            */
        elms = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenPoss ) );
        SET_LEN_BLIST( elms, lenPoss );

        if (inc == 1) {
            CopyBits(CONST_BLOCKS_BLIST(list) + ((pos - 1) / BIPEB),
                     (pos - 1) % BIPEB, BLOCKS_BLIST(elms), 0, lenPoss);
        }
        else {
            /* loop over the entries of <positions> and select */
            block = 0;
            bit = 1;
            for (i = 1; i <= lenPoss; i++, pos += inc) {

                /* assign the element to <elms> */
                if (TEST_BIT_BLIST(list, pos))
                    block |= bit;
                bit <<= 1;
                if (bit == 0 || i == lenPoss) {
                    *BLOCK_ELM_BLIST_PTR(elms, i) = block;
                    block = 0;
                    bit = 1;
                }
            }
        }
    }
    return elms;
}


/****************************************************************************
**
*F  UnbBlist( <blist>, <pos> ) . . . .  unbind an element from a boolean list
**
**  This is to avoid unpacking of the boolean list to a plain list when <pos>
**  is larger or equal to the length of <blist>.
*/
static void UnbBlist(Obj blist, Int pos)
{
    GAP_ASSERT(IS_MUTABLE_OBJ(blist));
    const Int len = LEN_BLIST(blist);
    if (len == pos) {
        // maybe the list becomes sorted
        CLEAR_FILTS_LIST(blist);
        CLEAR_BIT_BLIST(blist, pos);
        SET_LEN_BLIST(blist, len - 1);
    }
    else if (pos < len) {
        PLAIN_LIST(blist);
        UNB_LIST(blist, pos);
    }
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
        SET_BIT_BLIST(list, pos);
        CLEAR_FILTS_LIST(list);
    }

    /* if <i> is less than the logical length and <elm> is 'false'         */
    else if ( pos <= LEN_BLIST(list) && val == False ) {
        CLEAR_BIT_BLIST(list, pos);
        CLEAR_FILTS_LIST(list);
    }

    /* if <i> is one more than the logical length and <elm> is 'true'      */
    else if ( pos == LEN_BLIST(list)+1 && val == True ) {
        if ( SIZE_OBJ(list) < SIZE_PLEN_BLIST(pos) )
            ResizeBag( list, SIZE_PLEN_BLIST(pos) );
        SET_LEN_BLIST( list, pos );
        SET_BIT_BLIST(list, pos);
        CLEAR_FILTS_LIST(list);
    }

    /* if <i> is one more than the logical length and <elm> is 'false'     */
    else if ( pos == LEN_BLIST(list)+1 && val == False ) {
        if ( SIZE_OBJ(list) < SIZE_PLEN_BLIST(pos) )
            ResizeBag( list, SIZE_PLEN_BLIST(pos) );
        SET_LEN_BLIST( list, pos );
        CLEAR_BIT_BLIST(list, pos);
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
*F  PosBlist( <list>, <val>, <start> )   position of an elm in a boolean list
**
**  'PosBlist' returns the   position of  the first  occurrence  of the  value
**  <val>, which may be  an  object of  arbitrary  type, in the boolean  list
**  <list> after <start> as a C  integer.  If <val> does  not occur in <list>
**  after <start>, then 0 is returned.
**
**  'PosBlist' is the function in 'PosListFuncs' for boolean lists.
*/
static Obj PosBlist(Obj list, Obj val, Obj start)
{
    Int                 len;            /* logical length of the list      */
    const UInt *        ptr;            /* pointer to the blocks           */
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

    ptr = CONST_BLOCKS_BLIST(list);
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
               if ((x & ((UInt)1 << j)) != 0)
                 return INTOBJ_INT(BIPEB*firstblock + j + 1);
           return Fail;
         }
       if (x != 0)
         for (j = firstoffset; j < BIPEB; j++)
           if ((x & ((UInt)1 << j)) != 0)
             return INTOBJ_INT(BIPEB*firstblock + j + 1);
       for (i  = firstblock + 1; i < lastblock; i++)
         {
           x = ptr[i];
           if (x != 0)
             for (j = 0; j < BIPEB; j++)
               if ((x & ((UInt)1 << j)) != 0)
                 return INTOBJ_INT(BIPEB*i + j + 1);
         }
       x = ptr[lastblock];
       if (x != 0)
         for (j = 0; j <= lastoffset; j++)
           if ((x & ((UInt)1 << j)) != 0)
             return INTOBJ_INT(BIPEB*lastblock + j + 1);
       return Fail;
    }

    /* look for 'false'                                                    */
    else if ( val == False ) {
      x = ptr[firstblock];
      if (firstblock == lastblock) 
        {
          if (x != ALL_BITS_UINT)
            for (j = firstoffset; j <= lastoffset; j++)
              if ((x & ((UInt)1 << j)) == 0)
                return INTOBJ_INT(BIPEB*firstblock + j + 1);
           return Fail;
         }
       if (x != ALL_BITS_UINT)
         for (j = firstoffset; j < BIPEB; j++)
           if ((x & ((UInt)1 << j)) == 0)
             return INTOBJ_INT(BIPEB*firstblock + j + 1);
       for (i  = firstblock + 1; i < lastblock; i++)
         {
           x = ptr[i];
           if (x != ALL_BITS_UINT)
             for (j = 0; j < BIPEB; j++)
               if ((x & ((UInt)1 << j)) == 0)
                 return INTOBJ_INT(BIPEB*i + j + 1);
         }
       x = ptr[lastblock];
       if (x != ALL_BITS_UINT)
         for (j = 0; j <= lastoffset; j++)
           if ((x & ((UInt)1 << j)) == 0)
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
static void PlainBlist(Obj list)
{
    Int                 len;            /* length of <list>                */
    UInt                i;              /* loop variable                   */

    /* resize the list and retype it, in this order                        */
    len = LEN_BLIST(list);
    RetypeBagSM( list, T_PLIST );
    GROW_PLIST( list, (UInt)len );
    SET_LEN_PLIST( list, len );

    /* replace the bits by 'True' or 'False' as the case may be            */
    /* this must of course be done from the end of the list backwards      */
    for ( i = len; 0 < i; i-- )
        SET_ELM_PLIST(list, i, ELM_BLIST(list, i));

    /* 'CHANGED_BAG' not needed, 'True' and 'False' are safe           */
}



/****************************************************************************
**
*F  IsPossBlist( <list> ) . .  positions list test function for boolean lists
**
**  'IsPossBlist' returns  1 if  <list> is  empty, and 0 otherwise, since a
**  boolean list is a positions list if and only if it is empty.
*/
static BOOL IsPossBlist(Obj list)
{
    return LEN_BLIST(list) == 0;
}


/****************************************************************************
**
*F  IsHomogBlist( <list> )  . . . . . . . . . . check if <list> is homogenous
*/
static BOOL IsHomogBlist(Obj list)
{
    return (0 < LEN_BLIST(list));
}


/****************************************************************************
**
*F  IsSSortBlist( <list> )  . . . . . . .  check if <list> is strictly sorted
*/
static BOOL IsSSortBlist(Obj list)
{
    BOOL isSort;

    if ( LEN_BLIST(list) <= 1 ) {
        isSort = TRUE;
    }
    else if ( LEN_BLIST(list) == 2 ) {
        isSort = (TEST_BIT_BLIST(list, 1) && !TEST_BIT_BLIST(list, 2));
    }
    else {
        isSort = FALSE;
    }
    SET_FILT_LIST( list, (isSort ? FN_IS_SSORT : FN_IS_NSORT) );

    return isSort;
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
            *BLOCK_ELM_BLIST_PTR(list, i) = block;
            block = 0;
            bit = 1;
        }
    }
    RetypeBagSM( list, T_BLIST );
    ResizeBag( list, SIZE_PLEN_BLIST(len) );
    SET_LEN_BLIST( list, len );
}

/****************************************************************************
**
*F  COUNT_TRUES_BLOCK( <block> ) . . . . . . . . . . .  count number of trues
*/
UInt COUNT_TRUES_BLOCK(UInt block)
{
#if USE_POPCNT && defined(HAVE___BUILTIN_POPCOUNTL)
    return __builtin_popcountl(block);
#else
#ifdef SYS_IS_64_BIT
    block =
        (block & 0x5555555555555555L) + ((block >> 1) & 0x5555555555555555L);
    block =
        (block & 0x3333333333333333L) + ((block >> 2) & 0x3333333333333333L);
    block = (block + (block >> 4)) & 0x0f0f0f0f0f0f0f0fL;
    block = (block + (block >> 8));
    block = (block + (block >> 16));
    block = (block + (block >> 32)) & 0x00000000000000ffL;
#else
    block = (block & 0x55555555) + ((block >> 1) & 0x55555555);
    block = (block & 0x33333333) + ((block >> 2) & 0x33333333);
    block = (block + (block >> 4)) & 0x0f0f0f0f;
    block = (block + (block >> 8));
    block = (block + (block >> 16)) & 0x000000ff;
#endif
    return block;
#endif
}

/****************************************************************************
**
*F  COUNT_TRUES_BLOCKS( <ptr>, <nblocks> )
*/
UInt COUNT_TRUES_BLOCKS(const UInt * ptr, UInt nblocks)
{
    UInt n = 0;
    while (nblocks >= 4) {
        UInt n1 = COUNT_TRUES_BLOCK(*ptr++);
        UInt n2 = COUNT_TRUES_BLOCK(*ptr++);
        UInt n3 = COUNT_TRUES_BLOCK(*ptr++);
        UInt n4 = COUNT_TRUES_BLOCK(*ptr++);
        n += n1 + n2 + n3 + n4;
        nblocks -= 4;
    }
    while (nblocks) {
        n += COUNT_TRUES_BLOCK(*ptr++);
        nblocks--;
    }
    // return the number of bits
    return n;
}

/****************************************************************************
**
*F  IsBlist( <list> ) . . . . . . . . . test whether a list is a boolean list
**
**  'IsBlist' returns  1  if  the  list  <list> is  a  boolean list, i.e.,  a
**  list that   has no holes  and contains  only  'true' and  'false',  and 0
**  otherwise.
*/
static BOOL IsBlist(Obj list)
{
    BOOL                isBlist;        /* result of the test              */
    Int                 len;            /* logical length of the list      */
    UInt                i;              /* loop variable                   */

    /* if <list> is known to be a boolean list, it is very easy            */
    if ( IS_BLIST_REP(list) ) {
        isBlist = TRUE;
    }

    /* if <list> is not a small list, it isn't a boolean list (convert to list)   */
    else if ( ! IS_SMALL_LIST( list ) ) {
        isBlist = FALSE;
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
static BOOL IsBlistConv(Obj list)
{
    BOOL                isBlist;        /* result of the test              */
    Int                 len;            /* logical length of the list      */
    UInt                i;              /* loop variable                   */

    /* if <list> is known to be a boolean list, it is very easy            */
    if ( IS_BLIST_REP(list) ) {
        isBlist = TRUE;
    }

    /* if <list> is not a list, it isn't a boolean list (convert to list)  */
    else if ( ! IS_SMALL_LIST(list) ) {
        isBlist = FALSE;
    }

    /* otherwise test if there are holes and if all elements are boolean   */
    else {

        /* test that all elements are bound and either 'true' or 'false'   */
        len = LEN_LIST( list );
        for ( i = 1;  i <= len;  i++ ) {
            Obj elm = ELMV0_LIST( list, (Int)i );
            if ( elm == 0 || (elm != True && elm != False) ) {
                break;
            }
        }

        /* if <list> is a boolean list, change its representation        */
        isBlist = (len < i);
        if ( isBlist ) {
            ConvBlist(list);
        }
    }

    return isBlist;
}


/****************************************************************************
**
*F  SizeBlist( <blist> )  . . . .  number of 'true' entries in a boolean list
**
**  'SizeBlist' returns   the number of  entries of  the boolean list <blist>
**  that are 'true'.
**
**  The work is done in `COUNT_TRUES_BLOCKS` in blister.h and the algorithms
**  are documented there.
*/
static UInt SizeBlist(Obj blist)
{
    const UInt *        ptr;            /* pointer to blist                */
    UInt                nrb;            /* number of blocks in blist       */

    /* get the number of blocks and a pointer                              */
    nrb = NUMBER_BLOCKS_BLIST(blist);
    ptr = CONST_BLOCKS_BLIST(blist);

    return COUNT_TRUES_BLOCKS( ptr, nrb);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * GAP level functions  * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FiltIS_BLIST( <self>, <val> ) . . . . . test if a value is a boolean list
**
**  'FiltIS_BLIST' handles the internal function 'IsBlist'.
**
**  'IsBlist( <val> )'
**
**  'IsBlist' returns 'true' if the value <val> is a boolean list and 'false'
**  otherwise.  A value is a   boolean list if  it is  a lists without  holes
**  containing only  'true' and 'false'.
*/
static Obj IsBlistFilt;

static Obj FiltIS_BLIST(Obj self, Obj val)
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
static Obj FuncIS_BLIST_CONV(Obj self, Obj val)
{
    // let 'IsBlistConv' do the work
    return IsBlistConv( val ) ? True : False;
}


/****************************************************************************
**
**
*F  FiltIS_BLIST_REP( <self>, <obj> ) . . test if value is a boolean list rep
*/
static Obj IsBlistRepFilt;

static Obj FiltIS_BLIST_REP(Obj self, Obj obj)
{
    return (IS_BLIST_REP( obj ) ? True : False);
}


/****************************************************************************
**
*F  FuncSIZE_BLIST( <self>, <blist> ) . . number of 'true' entries in <blist>
**
**  'FuncSIZE_BLIST' implements the internal function 'SizeBlist'
*/
static Obj FuncSIZE_BLIST(Obj self, Obj blist)
{
    RequireBlist(SELF_NAME, blist);
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

static Obj FuncUNITE_BLIST_LIST(Obj self, Obj list, Obj blist, Obj sub);

static Obj FuncBLIST_LIST(Obj self, Obj list, Obj sub)
{
    RequireSmallList(SELF_NAME, list);
    RequireSmallList(SELF_NAME, sub);

    Int lenList = LEN_LIST( list );
    Obj blist = NewBag( T_BLIST, SIZE_PLEN_BLIST( lenList ) );
    SET_LEN_BLIST(blist, lenList);

    FuncUNITE_BLIST_LIST(self, list, blist, sub);

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
static Obj FuncLIST_BLIST(Obj self, Obj list, Obj blist)
{
    Obj                 sub;            /* handle of the result            */
    Int                 len;            /* logical length of the list      */
    UInt                n;              /* number of bits in blist         */
    UInt                nn;
    UInt                i;              /* loop variable                   */

    RequireSmallList(SELF_NAME, list);
    RequireBlist(SELF_NAME, blist);
    RequireSameLength(SELF_NAME, blist, list);

    /* compute the number of 'true'-s                                      */
    n = SizeBlist(blist);

    /* make the sublist (we now know its size exactly)                    */
    sub = NEW_PLIST_WITH_MUTABILITY( IS_MUTABLE_OBJ(list), T_PLIST, n );
    SET_LEN_PLIST( sub, n );

    /* loop over the boolean list and stuff elements into <sub>            */
    len = LEN_LIST( list );
    nn  = 1;
    for ( i = 1;  nn <= n && i <= len;  i++  ) {
        if (TEST_BIT_BLIST(blist, i)) {
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
*F  FuncPositionNthTrueBlist( <self>, <blist>, <Nth> )  . . . find true value
**
*/
static Obj FuncPositionNthTrueBlist(

    Obj self, Obj blist, Obj Nth)
{
    UInt                nrb;
    Int                 pos, i;
    UInt                m,  mask;
    const UInt *        ptr;

    /* Check the arguments. */
    RequireBlist(SELF_NAME, blist);
    Int nth = GetPositiveSmallIntEx("Position", Nth, "<nth>");

    nrb = NUMBER_BLOCKS_BLIST(blist);
    if ( ! nrb )  return Fail;
    pos = 0;
    ptr = CONST_BLOCKS_BLIST(blist);
    i = 1;
    m = COUNT_TRUES_BLOCK(*ptr);
    while ( nth > m ) {
        if ( ++i > nrb )  return Fail;
        nth -= m;
        pos += BIPEB;
        ptr++;
        m = COUNT_TRUES_BLOCK(*ptr);
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
*F  FuncIsSubsetBlist( <self>, <blist1>, <blist2> ) . . . . . . . subset test
**
**  'FuncIsSubsetBlist' implements the internal function 'IsSubsetBlist'.
**
**  'IsSubsetBlist( <blist1>, <blist2> )'
**
**  'IsSubsetBlist' returns 'true' if the boolean list <blist2> is a subset
**  of the  boolean  list <blist1>, which must  have  equal length.  <blist2>
**  is a subset of <blist1> if '<blist2>[<i>] >= <blist1>[<i>]' for all <i>.
*/
static Obj FuncIS_SUB_BLIST(Obj self, Obj blist1, Obj blist2)
{
    const UInt *        ptr1;           /* pointer to the first argument   */
    const UInt *        ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    RequireBlist(SELF_NAME, blist1);
    RequireBlist(SELF_NAME, blist2);
    RequireSameLength(SELF_NAME, blist1, blist2);

    /* test for subset property blockwise                                  */
    ptr1 = CONST_BLOCKS_BLIST(blist1);
    ptr2 = CONST_BLOCKS_BLIST(blist2);

    for ( i = NUMBER_BLOCKS_BLIST(blist1); 0 < i; i-- ) {
        if ( *ptr1 != (*ptr1 | *ptr2) )
            break;
        ptr1++;  ptr2++;
    }

    /* if no counterexample was found, <blist2> is a subset of <blist1>    */
    return (i == 0) ? True : False;
}


/****************************************************************************
**
*F  FuncUNITE_BLIST( <self>, <blist1>, <blist2> ) . unite one list with another
**
**  'FuncUNITE_BLIST' implements the internal function 'UniteBlist'.
**
**  'UniteBlist( <blist1>, <blist2> )'
**
**  'UniteBlist'  unites  the  boolean list  <blist1>  with  the boolean list
**  <blist2>,  which  must  have the   same  length.  This  is  equivalent to
**  assigning '<blist1>[<i>] := <blist1>[<i>] or <blist2>[<i>]' for all <i>.
*/
static Obj FuncUNITE_BLIST(Obj self, Obj blist1, Obj blist2)
{
    UInt *              ptr1;           /* pointer to the first argument   */
    const UInt *        ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    RequireBlist(SELF_NAME, blist1);
    RequireMutable(SELF_NAME, blist1, "boolean list");
    RequireBlist(SELF_NAME, blist2);
    RequireSameLength(SELF_NAME, blist1, blist2);

    /* compute the union by *or*-ing blockwise                             */
    ptr1 = BLOCKS_BLIST(blist1);
    ptr2 = CONST_BLOCKS_BLIST(blist2);
    for ( i = (LEN_BLIST(blist1)+BIPEB-1)/BIPEB; 0 < i; i-- ) {
        *ptr1++ |= *ptr2++;
    }

    return 0;
}


/****************************************************************************
**
*F  FuncUNITE_BLIST_LIST( <self>, <list>,<blist>, <sub> )
**
**  'FuncUNITE_BLIST_LIST' implements the internal function 'UniteBlistList'.
**
**  'UniteBlistList( <list>,<blist>, <sub> )'
**
**  'UniteBlistList'  works like `BlistList', but adds the entries to the
**  existing <blist>.
*/
static Obj FuncUNITE_BLIST_LIST(Obj self, Obj list, Obj blist, Obj sub)
{
    UInt  *             ptrBlist;       /* pointer to the boolean list     */
    UInt                block;          /* one block of boolean list       */
    UInt                bit;            /* one bit of block                */
    Int                 lenList;        /* logical length of the list      */
    const Obj *         ptrSub;         /* pointer to the sublist          */
    Int                 lenSub;         /* logical length of sublist       */
    Int                 i, j, k, l;     /* loop variables                  */
    Int                 s, t;           /* elements of a range             */

    RequireSmallList(SELF_NAME, list);
    RequireBlist(SELF_NAME, blist);
    RequireMutable(SELF_NAME, blist, "boolean list");
    RequireSameLength(SELF_NAME, blist, list);
    RequireSmallList(SELF_NAME, sub);

    lenList  = LEN_LIST( list );
    lenSub   = LEN_LIST( sub );

    // if the list or the sublist are empty, nothing has to be done
    if (lenList == 0 || lenSub == 0) {
        return 0;
    }

    /* for a range as subset of a range, it is extremely easy               */
    if ( IS_RANGE(list) && IS_RANGE(sub) && GET_INC_RANGE( list ) == 1
          && GET_INC_RANGE( sub ) == 1) {

        ptrBlist = BLOCKS_BLIST(blist);

        /* get the bounds of the subset with respect to the boolean list   */
        s = INT_INTOBJ( GET_ELM_RANGE( list, 1 ) );
        t = INT_INTOBJ( GET_ELM_RANGE( sub, 1 ) );

        // compute bounds
        i = t - s;
        j = lenSub + i;
        if (i < 0)
            i = 0;
        if (j > lenList)
            j = lenList;

        /* set the corresponding entries to 'true'                         */
        for ( k = i; k < j && k%BIPEB != 0; k++ )
            ptrBlist[k/BIPEB] |= ((UInt)1 << k%BIPEB);
        for ( ; k+BIPEB < j; k += BIPEB )
            ptrBlist[k/BIPEB] = ~(UInt)0;
        for ( ; k < j; k++ )
            ptrBlist[k/BIPEB] |= ((UInt)1 << k%BIPEB);

    }

    /* for a list as subset of a range, we need basically no search        */
    else if ( IS_RANGE(list) && GET_INC_RANGE( list) == 1
          && IS_PLIST(sub) ) {

        ptrBlist = BLOCKS_BLIST(blist);
        ptrSub = CONST_ADDR_OBJ(sub);

        /* loop over <sub> and set the corresponding entries to 'true'     */
        s = INT_INTOBJ( GET_ELM_RANGE( list, 1 ) );
        for (l = 1; l <= lenSub; l++) {
            if ( ptrSub[l] != 0 ) {

                /* if <sub>[<l>] is an integer it is very easy             */
                if ( IS_INTOBJ( ptrSub[l] ) ) {
                    t = INT_INTOBJ( ptrSub[l] ) - s + 1;
                    if ( 0 < t && t <= lenList )
                        ptrBlist[(t-1)/BIPEB] |= ((UInt)1 << (t-1)%BIPEB);
                }
            }
        }
    }

    /* if <list> is a set we have two possibilities                        */
    else if (IS_SMALL_LIST(list) && IS_SSORT_LIST(list)) {

        if (!IS_PLIST(list))
            list = PLAIN_LIST_COPY(list);

        // compute the logarithm of the length of <list>
        for ( i = lenList, l = 0; i != 0; i >>= 1, l++ ) ;

        /* if <sub> is small, we loop over <sub> and use binary search     */
        if ( l * lenSub < 2 * lenList ) {

            /* run over the elements of <sub> and search for the elements  */
            for (l = 1; l <= lenSub; l++) {
                Obj elm = ELMV0_LIST(sub, l);
                if (elm != 0) {

                    /* perform the binary search to find the position      */
                    i = 0;  k = lenList+1;
                    while ( i+1 < k ) {
                        j = (i + k) / 2;
                        if (LT(ELM_PLIST(list, j), elm))
                            i = j;
                        else
                            k = j;
                    }

                    /* set bit if <sub>[<l>] was found at position k       */
                    if (k <= lenList && EQ(ELM_PLIST(list, k), elm))
                        SET_BIT_BLIST(blist, k);
                }
            }
        }

        /* if <sub> is large, run over both list in parallel               */
        else {

            // turn <sub> into a set (and hence a plist) for faster searching
            if (!IS_PLIST(sub) || !IS_SSORT_LIST(sub)) {
                sub = SetList(sub);
                lenSub = LEN_PLIST(sub);
            }

            /* run over the elements of <list>                             */
            k = 1;
            block = 0;
            bit   = 1;
            for ( l = 1; l <= lenList; l++ ) {
                Obj elm = ELM_LIST(list, l);

                /* test if <list>[<l>] is in <sub>                         */
                while (k <= lenSub && LT(ELM_PLIST(sub, k), elm))
                    k++;

                /* if <list>[<k>] is in <sub> set the current bit in block */
                if (k <= lenSub && EQ(ELM_PLIST(sub, k), elm)) {
                    block |= bit;
                    k++;
                }

                /* if block is full add it to boolean list and start next  */
                bit = bit << 1;
                if ( bit == 0 || l == lenList ) {
                    *BLOCK_ELM_BLIST_PTR(blist, l) |= block;
                    block = 0;
                    bit = 1;
                }

            }
        }

    }

    /* if <list> is not a set, we have to use brute force                  */
    else {

        // turn <sub> into a set (and hence a plist) for faster searching
        if (!IS_PLIST(sub) || !IS_SSORT_LIST(sub)) {
            sub = SetList(sub);
            lenSub = LEN_PLIST(sub);
        }

        /* run over the elements of <list>                                 */
        k = 1;
        block = 0;
        bit   = 1;
        Obj elm = 0, prev;
        for ( l = 1; l <= lenList; l++ ) {
            prev = elm;
            elm = ELM_LIST(list, l);
            /* test if <list>[<l>] is in <sub>                             */
            if (l == 1 || LT(prev, elm)) {
                while (k <= lenSub && LT(ELM_PLIST(sub, k), elm))
                    k++;
            }
            else {
                i = 0;
                k = lenSub + 1;
                while ( i+1 < k ) {
                    j = (i + k) / 2;
                    if (LT(ELM_PLIST(sub, j), elm))
                        i = j;
                    else
                        k = j;
                }
            }

            /* if <list>[<k>] is in <sub> set the current bit in the block */
            if (k <= lenSub && EQ(ELM_PLIST(sub, k), elm)) {
                block |= bit;
                k++;
            }

            /* if block is full add it to the boolean list and start next  */
            bit = bit << 1;
            if ( bit == 0 || l == lenList ) {
                *BLOCK_ELM_BLIST_PTR(blist, l) |= block;
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
*F  FuncINTER_BLIST( <self>, <blist1>, <blist2> ) .  <blist1> intersection <blist2>
**
**  'FuncINTER_BLIST' implements the function 'IntersectBlist'.
**
**  'IntersectBlist( <blist1>, <blist2> )'
**
**  'IntersectBlist' intersects the   boolean list <blist1> with  the  boolean
**  list <blist2>, which  must have the  same length.   This is equivalent  to
**  assigning '<blist1>[<i>] := <blist1>[<i>] and <blist2>[<i>]' for all <i>.
*/
static Obj FuncINTER_BLIST(Obj self, Obj blist1, Obj blist2)
{
    UInt *              ptr1;           /* pointer to the first argument   */
    const UInt *        ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    RequireBlist(SELF_NAME, blist1);
    RequireMutable(SELF_NAME, blist1, "boolean list");
    RequireBlist(SELF_NAME, blist2);
    RequireSameLength(SELF_NAME, blist1, blist2);

    /* compute the intersection by *and*-ing blockwise                     */
    ptr1 = BLOCKS_BLIST(blist1);
    ptr2 = CONST_BLOCKS_BLIST(blist2);
    for ( i = NUMBER_BLOCKS_BLIST(blist1); 0 < i; i-- )
        *ptr1++ &= *ptr2++;

    return 0;
}


/****************************************************************************
**
*F  FuncSUBTR_BLIST( <self>, <blist1>, <blist2> ) . . . . . . <blist1> - <blist2>
**
**  'FuncSUBTR_BLIST' implements the internal function 'SubtractBlist'.
**
**  'SubtractBlist( <blist1>, <blist2> )'
**
**  'SubtractBlist' subtracts the boolean  list <blist2> from the boolean list
**  <blist1>, which  must have the  same length.  This is equivalent assigning
**  '<blist1>[<i>] := <blist1>[<i>] and not <blist2>[<i>]' for all <i>.
*/
static Obj FuncSUBTR_BLIST(Obj self, Obj blist1, Obj blist2)
{
    UInt *              ptr1;           /* pointer to the first argument   */
    const UInt *        ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    RequireBlist(SELF_NAME, blist1);
    RequireMutable(SELF_NAME, blist1, "boolean list");
    RequireBlist(SELF_NAME, blist2);
    RequireSameLength(SELF_NAME, blist1, blist2);

    /* compute the difference by operating blockwise                       */
    ptr1 = BLOCKS_BLIST(blist1);
    ptr2 = CONST_BLOCKS_BLIST(blist2);
    for ( i = NUMBER_BLOCKS_BLIST(blist1); 0 < i; i-- )
        *ptr1++ &= ~ *ptr2++; 

    return 0;
}

/****************************************************************************
**
*F  FuncMEET_BLIST( <self>, <blist1>, <blist2> ) . . . 
**
**  'FuncMEET_BLIST' implements the internal function 'MeetBlist'.
**
**  'MeetBlist( <blist1>, <blist2> )'
**
**  'MeetBlist' returns true if blist1 and blist2 have true in the same
**  position and false otherwise. It is equivalent to, but faster than
**  SizeBlist(IntersectionBlist(blist1, blist2)) <> 0
**  The lists must have the same length.
*/

static Obj FuncMEET_BLIST(Obj self, Obj blist1, Obj blist2)
{
    const UInt *        ptr1;           /* pointer to the first argument   */
    const UInt *        ptr2;           /* pointer to the second argument  */
    UInt                i;              /* loop variable                   */

    RequireBlist(SELF_NAME, blist1);
    RequireBlist(SELF_NAME, blist2);
    RequireSameLength(SELF_NAME, blist1, blist2);

    /* compute the difference by operating blockwise                       */
    ptr1 = CONST_BLOCKS_BLIST(blist1);
    ptr2 = CONST_BLOCKS_BLIST(blist2);
    for ( i = NUMBER_BLOCKS_BLIST(blist1); 0 < i; i-- )
        if (*ptr1++ & *ptr2++) return True;

    return False;
}

/****************************************************************************
**
*F  FuncFLIP_BLIST( <self>, <blist> ) . . .
**
**  'FuncFLIP_BLIST' implements the internal function 'FlipBlist'.
**
**  'FlipBlist( <blist> )'
**
**  'FlipBlist' changes every value in the blist <blist> from true to false,
**  and vice versa.
*/

static Obj FuncFLIP_BLIST(Obj self, Obj blist)
{
    RequireBlist(SELF_NAME, blist);
    RequireMutable(SELF_NAME, blist, "boolean list");

    if (LEN_BLIST(blist) == 0) {
        return 0;
    }

    UInt * ptr = BLOCKS_BLIST(blist);
    for (UInt i = NUMBER_BLOCKS_BLIST(blist); 0 < i; i--) {
        *ptr = ~(*ptr);
        ptr++;
    }
    // If the logical length of the boolean list is not a multiple of BIPEB the
    // last block will contain unused bits, which are then zero.
    UInt mask =
        ~(UInt)0 >> ((BIPEB * NUMBER_BLOCKS_BLIST(blist)) - LEN_BLIST(blist));
    ptr = BLOCK_ELM_BLIST_PTR(blist, LEN_BLIST(blist));
    *ptr &= mask;
    return 0;
}

/****************************************************************************
**
*F  FuncCLEAR_ALL_BLIST( <self>, <blist> ) . . .
**
**  'FuncCLEAR_ALL_BLIST' implements the internal function 'ClearAllBlist'.
**
**  'ClearAllBlist( <blist> )'
**
**  'ClearAllBlist' changes every value in the blist <blist> to false.
*/

static Obj FuncCLEAR_ALL_BLIST(Obj self, Obj blist)
{
    RequireBlist(SELF_NAME, blist);
    RequireMutable(SELF_NAME, blist, "boolean list");

    if (LEN_BLIST(blist) == 0) {
        return 0;
    }

    UInt * ptr = BLOCKS_BLIST(blist);
    for (UInt i = NUMBER_BLOCKS_BLIST(blist); 0 < i; i--) {
        *ptr++ = 0;
    }

    return 0;
}

/****************************************************************************
**
*F  FuncSET_ALL_BLIST( <self>, <blist> ) . . .
**
**  'FuncSET_ALL_BLIST' implements the internal function 'SetAllBlist'.
**
**  'SetAllBlist( <blist> )'
**
**  'SetAllBlist' changes every value in the blist <blist> to true.
*/

static Obj FuncSET_ALL_BLIST(Obj self, Obj blist)
{
    RequireBlist(SELF_NAME, blist);
    RequireMutable(SELF_NAME, blist, "boolean list");

    if (LEN_BLIST(blist) == 0) {
        return 0;
    }

    UInt * ptr = BLOCKS_BLIST(blist);
    for (UInt i = NUMBER_BLOCKS_BLIST(blist); 0 < i; i--) {
        *ptr++ = ~(UInt)0;
    }
    // If the logical length of the boolean list is not a multiple of BIPEB the
    // last block will contain unused bits, which are then zero.
    UInt mask =
        ~(UInt)0 >> ((BIPEB * NUMBER_BLOCKS_BLIST(blist)) - LEN_BLIST(blist));
    ptr = BLOCK_ELM_BLIST_PTR(blist, LEN_BLIST(blist));
    *ptr &= mask;

    return 0;
}

/****************************************************************************
**
**
*F  MakeImmutableBlist( <blist> )
*/

static void MakeImmutableBlist(Obj blist)
{
    MakeImmutableNoRecurse(blist);
}

/****************************************************************************
**
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_BLIST,                           "list (boolean)"                  },
  { T_BLIST       +IMMUTABLE,          "list (boolean,imm)"              },
  { T_BLIST_NSORT,                     "list (boolean,nsort)"            },
  { T_BLIST_NSORT +IMMUTABLE,          "list (boolean,nsort,imm)"        },
  { T_BLIST_SSORT,                     "list (boolean,ssort)"            },
  { T_BLIST_SSORT +IMMUTABLE,          "list (boolean,ssort,imm)"        },
  { -1,                                ""                                }
};


/****************************************************************************
**
*V  ClearFiltsTab . . . . . . . . . . . . . . . . . . . .  clear filter tnums
*/
static Int ClearFiltsTab [] = {
    T_BLIST,                 T_BLIST,
    T_BLIST_NSORT,           T_BLIST,
    T_BLIST_SSORT,           T_BLIST,
    -1,                      -1
};


/****************************************************************************
**
*V  HasFiltTab  . . . . . . . . . . . . . . . . . . . . .  tester filter tnum
*/
static Int HasFiltTab [] = {

    /* mutable boolean list                                                */
    T_BLIST,                    FN_IS_DENSE,    1,
    T_BLIST,                    FN_IS_NDENSE,   0,
    T_BLIST,                    FN_IS_HOMOG,    1,
    T_BLIST,                    FN_IS_NHOMOG,   0,
    T_BLIST,                    FN_IS_TABLE,    0,
    T_BLIST,                    FN_IS_SSORT,    0,
    T_BLIST,                    FN_IS_NSORT,    0,

    /* nsort mutable boolean list                                          */
    T_BLIST_NSORT,              FN_IS_DENSE,    1,
    T_BLIST_NSORT,              FN_IS_NDENSE,   0,
    T_BLIST_NSORT,              FN_IS_HOMOG,    1,
    T_BLIST_NSORT,              FN_IS_NHOMOG,   0,
    T_BLIST_NSORT,              FN_IS_TABLE,    0,
    T_BLIST_NSORT,              FN_IS_SSORT,    0,
    T_BLIST_NSORT,              FN_IS_NSORT,    1,

    /* ssort mutable boolean list                                          */
    T_BLIST_SSORT,              FN_IS_DENSE,    1,
    T_BLIST_SSORT,              FN_IS_NDENSE,   0,
    T_BLIST_SSORT,              FN_IS_HOMOG,    1,
    T_BLIST_SSORT,              FN_IS_NHOMOG,   0,
    T_BLIST_SSORT,              FN_IS_TABLE,    0,
    T_BLIST_SSORT,              FN_IS_SSORT,    1,
    T_BLIST_SSORT,              FN_IS_NSORT,    0,

    -1,                         -1,             -1
};


/****************************************************************************
**
*V  SetFiltTab  . . . . . . . . . . . . . . . . . . . . .  setter filter tnum
*/
static Int SetFiltTab [] = {

    /* mutable boolean list                                                */
    T_BLIST,                    FN_IS_DENSE,    T_BLIST,
    T_BLIST,                    FN_IS_NDENSE,   -1,
    T_BLIST,                    FN_IS_HOMOG,    T_BLIST,
    T_BLIST,                    FN_IS_NHOMOG,   -1,
    T_BLIST,                    FN_IS_TABLE,    -1,
    T_BLIST,                    FN_IS_SSORT,    T_BLIST_SSORT,
    T_BLIST,                    FN_IS_NSORT,    T_BLIST_NSORT,

    /* nsort mutable boolean list                                          */
    T_BLIST_NSORT,              FN_IS_DENSE,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_NDENSE,   -1,
    T_BLIST_NSORT,              FN_IS_HOMOG,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_NHOMOG,   -1,
    T_BLIST_NSORT,              FN_IS_TABLE,    -1,
    T_BLIST_NSORT,              FN_IS_SSORT,    -1,
    T_BLIST_NSORT,              FN_IS_NSORT,    T_BLIST_NSORT,

    /* ssort mutable boolean list                                          */
    T_BLIST_SSORT,              FN_IS_DENSE,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_NDENSE,   -1,
    T_BLIST_SSORT,              FN_IS_HOMOG,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_NHOMOG,   -1,
    T_BLIST_SSORT,              FN_IS_TABLE,    -1,
    T_BLIST_SSORT,              FN_IS_SSORT,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_NSORT,    -1,

    -1,                         -1,             -1

};


/****************************************************************************
**
*V  ResetFiltTab  . . . . . . . . . . . . . . . . . . .  unsetter filter tnum
*/
static Int ResetFiltTab [] = {

    /* mutable boolean list                                                */
    T_BLIST,                    FN_IS_DENSE,    T_BLIST,
    T_BLIST,                    FN_IS_NDENSE,   T_BLIST,
    T_BLIST,                    FN_IS_HOMOG,    T_BLIST,
    T_BLIST,                    FN_IS_NHOMOG,   T_BLIST,
    T_BLIST,                    FN_IS_TABLE,    T_BLIST,
    T_BLIST,                    FN_IS_SSORT,    T_BLIST,
    T_BLIST,                    FN_IS_NSORT,    T_BLIST,

    /* nsort mutable boolean list                                          */
    T_BLIST_NSORT,              FN_IS_DENSE,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_NDENSE,   T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_HOMOG,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_NHOMOG,   T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_TABLE,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_SSORT,    T_BLIST_NSORT,
    T_BLIST_NSORT,              FN_IS_NSORT,    T_BLIST,

    /* ssort mutable boolean list                                          */
    T_BLIST_SSORT,              FN_IS_DENSE,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_NDENSE,   T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_HOMOG,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_NHOMOG,   T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_TABLE,    T_BLIST_SSORT,
    T_BLIST_SSORT,              FN_IS_SSORT,    T_BLIST,
    T_BLIST_SSORT,              FN_IS_NSORT,    T_BLIST_SSORT,

    -1,                         -1,             -1

};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_BLIST, "obj", &IsBlistFilt),
    GVAR_FILT(IS_BLIST_REP, "obj", &IsBlistRepFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_1ARGS(IS_BLIST_CONV, obj),
    GVAR_FUNC_2ARGS(BLIST_LIST, list, sub),
    GVAR_FUNC_2ARGS(LIST_BLIST, list, blist),
    GVAR_FUNC_1ARGS(SIZE_BLIST, blist),
    GVAR_FUNC_2ARGS(IS_SUB_BLIST, blist1, blist2),
    GVAR_FUNC_2ARGS(UNITE_BLIST, blist1, blist2),
    GVAR_FUNC_3ARGS(UNITE_BLIST_LIST, list, blist, sub),
    GVAR_FUNC_2ARGS(INTER_BLIST, blist1, blist2),
    GVAR_FUNC_2ARGS(SUBTR_BLIST, blist1, blist2),
    GVAR_FUNC_2ARGS(MEET_BLIST, blist1, blist2),
    GVAR_FUNC_1ARGS(FLIP_BLIST, blist),
    GVAR_FUNC_1ARGS(CLEAR_ALL_BLIST, blist),
    GVAR_FUNC_1ARGS(SET_ALL_BLIST, blist),
    GVAR_FUNC_2ARGS(PositionNthTrueBlist, blist, nth),
    { 0, 0, 0, 0, 0 }

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
        InitMarkFuncBags( t1                     , MarkNoSubBags  );
        InitMarkFuncBags( t1 +IMMUTABLE          , MarkNoSubBags  );
    }

    /* Make immutable blists public                                        */
#ifdef HPCGAP
    for ( t1 = T_BLIST; t1 <= T_BLIST_SSORT; t1 += 2 ) {
        MakeBagTypePublic( t1 + IMMUTABLE );
    }
#endif

    /* install the type methods                                            */
    TypeObjFuncs[ T_BLIST            ] = TypeBlist;
    TypeObjFuncs[ T_BLIST +IMMUTABLE ] = TypeBlist;
    TypeObjFuncs[ T_BLIST_NSORT            ] = TypeBlistNSort;
    TypeObjFuncs[ T_BLIST_NSORT +IMMUTABLE ] = TypeBlistNSort;
    TypeObjFuncs[ T_BLIST_SSORT            ] = TypeBlistSSort;
    TypeObjFuncs[ T_BLIST_SSORT +IMMUTABLE ] = TypeBlistSSort;

    /* initialise list tables                                              */
    InitClearFiltsTNumsFromTable   ( ClearFiltsTab );
    InitHasFiltListTNumsFromTable  ( HasFiltTab    );
    InitSetFiltListTNumsFromTable  ( SetFiltTab    );
    InitResetFiltListTNumsFromTable( ResetFiltTab  );

#ifdef GAP_ENABLE_SAVELOAD
    /* Install the saving functions -- cannot save while copying           */
    for ( t1 = T_BLIST;  t1 <= T_BLIST_SSORT;  t1 += 2 ) {
        SaveObjFuncs[ t1            ] = SaveBlist;
        SaveObjFuncs[ t1 +IMMUTABLE ] = SaveBlist;
        LoadObjFuncs[ t1            ] = LoadBlist;
        LoadObjFuncs[ t1 +IMMUTABLE ] = LoadBlist;
    }
#endif

    /* install the copy functions                                          */
    for ( t1 = T_BLIST; t1 <= T_BLIST_SSORT; t1 += 2 ) {
#if !defined(USE_THREADSAFE_COPYING)
        CopyObjFuncs [ t1                     ] = CopyBlist;
        CopyObjFuncs [ t1 +IMMUTABLE          ] = CopyBlist;
        CleanObjFuncs[ t1                     ] = 0;
        CleanObjFuncs[ t1 +IMMUTABLE          ] = 0;
#endif
        ShallowCopyObjFuncs[ t1               ] = ShallowCopyBlist;
        ShallowCopyObjFuncs[ t1 +IMMUTABLE    ] = ShallowCopyBlist;
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
        UnbListFuncs    [ t1            ] = UnbBlist;
        AssListFuncs    [ t1            ] = AssBlist;
        AsssListFuncs   [ t1            ] = AsssListDefault;
        IsDenseListFuncs[ t1            ] = AlwaysYes;
        IsDenseListFuncs[ t1 +IMMUTABLE ] = AlwaysYes;
        IsHomogListFuncs[ t1            ] = IsHomogBlist;
        IsHomogListFuncs[ t1 +IMMUTABLE ] = IsHomogBlist;
        IsTableListFuncs[ t1            ] = AlwaysNo;
        IsTableListFuncs[ t1 +IMMUTABLE ] = AlwaysNo;
        IsPossListFuncs [ t1            ] = IsPossBlist;
        IsPossListFuncs [ t1 +IMMUTABLE ] = IsPossBlist;
        PosListFuncs    [ t1            ] = PosBlist;
        PosListFuncs    [ t1 +IMMUTABLE ] = PosBlist;
        PlainListFuncs  [ t1            ] = PlainBlist;
        PlainListFuncs  [ t1 +IMMUTABLE ] = PlainBlist;
        MakeImmutableObjFuncs [ t1      ] = MakeImmutableBlist;
    }
    IsSSortListFuncs[ T_BLIST            ] = IsSSortBlist;
    IsSSortListFuncs[ T_BLIST +IMMUTABLE ] = IsSSortBlist;
    IsSSortListFuncs[ T_BLIST_NSORT            ] = AlwaysNo;
    IsSSortListFuncs[ T_BLIST_NSORT +IMMUTABLE ] = AlwaysNo;
    IsSSortListFuncs[ T_BLIST_SSORT            ] = AlwaysYes;
    IsSSortListFuncs[ T_BLIST_SSORT +IMMUTABLE ] = AlwaysYes;

    /* Import the types of blists: */
    ImportGVarFromLibrary( "TYPE_BLIST_MUT", &TYPE_BLIST_MUT );
    ImportGVarFromLibrary( "TYPE_BLIST_IMM", &TYPE_BLIST_IMM );
    ImportGVarFromLibrary( "TYPE_BLIST_NSORT_MUT", &TYPE_BLIST_NSORT_MUT );
    ImportGVarFromLibrary( "TYPE_BLIST_NSORT_IMM", &TYPE_BLIST_NSORT_IMM );
    ImportGVarFromLibrary( "TYPE_BLIST_SSORT_MUT", &TYPE_BLIST_SSORT_MUT );
    ImportGVarFromLibrary( "TYPE_BLIST_SSORT_IMM", &TYPE_BLIST_SSORT_IMM );
    ImportGVarFromLibrary( "TYPE_BLIST_EMPTY_MUT", &TYPE_BLIST_EMPTY_MUT );
    ImportGVarFromLibrary( "TYPE_BLIST_EMPTY_IMM", &TYPE_BLIST_EMPTY_IMM );

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

    return 0;
}


/****************************************************************************
**
*F  InitInfoBlist() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "blister",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoBlist ( void )
{
    return &module;
}
