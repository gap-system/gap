/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of the generic list package.
**
**  This package provides a uniform   interface to the functions that  access
**  lists and their elements  for the other packages  in the GAP kernel.  For
**  example, 'ExecFor' can loop over the elements  in a list using  'LEN_LIST'
**  and 'ELM_LIST' independently of the type of the list.
**
**  This package uses plain lists (of type 'T_PLIST') and  assumes that it is
**  possible to put values of any type into these. It uses the functions
**  'LEN_PLIST', 'SET_LEN_PLIST',   'ELM_PLIST', and 'SET_ELM_PLIST' exported
**  by the plain list package to access and modify plain lists.
*/

#include "lists.h"

#include "ariths.h"
#include "bool.h"
#include "calls.h"
#include "error.h"
#include "gaputils.h"
#include "integer.h"
#include "io.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "precord.h"
#include "range.h"
#include "records.h"
#include "stringobj.h"

#ifdef HPCGAP
#include "hpc/aobjects.h"
#include "hpc/guards.h"
#endif

/****************************************************************************
**
*F  IS_LIST(<obj>)  . . . . . . . . . . . . . . . . . . . is an object a list
*V  IsListFuncs[<type>] . . . . . . . . . . . . . . . . . table for list test
**
**  'IS_LIST' only calls the function pointed  to  by  'IsListFuncs[<type>]',
**  passing <obj> as argument.
*/
BOOL (*IsListFuncs[LAST_REAL_TNUM + 1])(Obj obj);

static Obj IsListFilt;

static Obj FiltIS_LIST(Obj self, Obj obj)
{
    return (IS_LIST( obj ) ? True : False);
}

static BOOL IsListObject(Obj obj)
{
    return (DoFilter( IsListFilt, obj ) == True);
}


/****************************************************************************
**
*F  IS_SMALL_LIST(<obj>)  . . . . . . . . . . . . . . . . . . . is an object a list
*V  IsListFuncs[<type>] . . . . . . . . . . . . . . . . . table for list test
**
**  'IS_SMALL_LIST' only calls the function pointed  to  by  'IsListFuncs[<type>]',
**  passing <obj> as argument.
**
**  This is, in some sense, a workaround for the not yet implemented features
**  below (see LENGTH).
*/
BOOL (*IsSmallListFuncs[LAST_REAL_TNUM + 1])(Obj obj);

static Obj IsSmallListFilt;
static Obj HasIsSmallListFilt;
static Obj LengthAttr;
static Obj SetIsSmallList;

static BOOL IsSmallListObject(Obj obj)
{
  Obj len;
  if (DoFilter(IsListFilt, obj) != True)
    return FALSE;
  if (DoFilter(HasIsSmallListFilt, obj) == True)
    return DoFilter(IsSmallListFilt, obj) == True;
  if (DoTestAttribute(LengthAttr, obj) == True)
    {
      len = DoAttribute(LengthAttr, obj);
      if (IS_INTOBJ(len))
        {
          CALL_2ARGS(SetIsSmallList, obj, True);
          return TRUE;
        }
      else
        {
          CALL_2ARGS(SetIsSmallList, obj, False);
          return FALSE;
        }
    }
  return 0;
}



/****************************************************************************
**
*F  AttrLENGTH( <self>, <list> ) . . . . . . . . . . .  'Length' interface
**
**  There are  the ``relatively''  easy  changes to  'LEN_LIST' to  allow  it
**  return GAP  objects instead of small C  integers, but then the kernel has
**  to be very careful not to assume that the length is small and most of the
**  code has to duplicated,  namely  one large  and  one small version.    So
**  instead the following solution has been taken:
**
**  - internal lists  have always a  small length,  that means that it is not
**    possible to have plain list of length larger than 2^28  (or maybe 2^32)
**    on 32-bit machines, 'LEN_LIST' can only be applied to internal objects,
**    'LENGTH' is the GAP interface for all kind of objects
**
**  - on  the  other hand we want ranges to have  large start and end points,
**    therefore  ranges  are no  longer  *internal*  objects,  they  are  now
**    external objects (NOT YET IMPLEMENTED)
**
**  - the for/list assignment has to be careful to catch the special case of
**    a range constructor with small integer bounds
**
**  - the list access/assignment is a binary operation (NOT YET IMPLEMENTED)
**
**  - the conversion/test functions are split into three different functions
**    (NOT YET IMPLEMENTED)
**
**  - 'ResetFilterObj' and 'SetFilterObj'  are implemented using a table  for
**    internal types (NOT YET IMPLEMENTED)
*/

static Obj AttrLENGTH(Obj self, Obj list)
{
    /* internal list types                                                 */
#ifdef HPCGAP
    ReadGuard(list);
    ImpliedWriteGuard(list);
    if ( (FIRST_LIST_TNUM<=TNUM_OBJ(list) && TNUM_OBJ(list)<=LAST_LIST_TNUM)
         || TNUM_OBJ(list) == T_ALIST || TNUM_OBJ(list) == T_FIXALIST) {
        return ObjInt_Int( LEN_LIST(list) );
    }
#else
    if ( FIRST_LIST_TNUM<=TNUM_OBJ(list) && TNUM_OBJ(list)<=LAST_LIST_TNUM) {
        return ObjInt_Int( LEN_LIST(list) );
    }
#endif

    /* external types                                                      */
    else {
        return DoAttribute( LengthAttr, list );
    }
}


/****************************************************************************
**
*F  LEN_LIST(<list>)  . . . . . . . . . . . . . . . . . . .  length of a list
*V  LenListFuncs[<type>]  . . . . . . . . . . . . . table of length functions
*F  LenListError(<list>)  . . . . . . . . . . . . . . . error length function
**
**  'LEN_LIST' only calls  the function pointed to by 'LenListFuncs[<type>]',
**  passing  <list> as argument.  If <type>  is not the type  of a list, then
**  'LenListFuncs[<type>]'  points to  'LenListError', which  just signals an
**  error.
**
**  At the  moment  this also handles external    types but this   is a hack,
**  because external  lists can have large  length or even  be infinite.  See
**  'AttrLENGTH'.
*/
Int (*LenListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

static Obj FuncLEN_LIST(Obj self, Obj list)
{
    /* special case for plain lists (avoid conversion back and forth)      */
    if ( IS_PLIST(list) ) {
        return INTOBJ_INT( LEN_PLIST( list ) );
    }

    /* generic case (will signal an error if <list> is not a list)         */
    else {
        return AttrLENGTH( LengthAttr, list );
    }
}


static Int LenListError(Obj list)
{
    RequireArgument("Length", list, "must be a list");
}


static Int LenListObject(Obj obj)
{
    Obj                 len;

    len = AttrLENGTH( LengthAttr, obj );
    if (!IS_NONNEG_INTOBJ(len)) {
        RequireArgumentEx("Length", len, 0,
                          "method must return a non-negative small integer");
    }
    return INT_INTOBJ( len );
}

/****************************************************************************
**
*F  LENGTH(<list>)  . . . . . . . . . . . . . . . . . . .  length of a list
*V  LengthFuncs[<type>]  . . . . . . . . . . . . . table of length functions
**
**  'LENGTH' returns the logical length of the list <list>  as a GAP object
**  An error is signalled if <list> is not a list.
**
**  A package  implementing a list type <type>  must  provide such a function
**  and install it in 'LengthFuncs[<type>]'.
*/

Obj             (*LengthFuncs[LAST_REAL_TNUM+1]) ( Obj list );

static Obj LengthError(Obj list)
{
    RequireArgument("Length", list, "must be a list");
}


static Obj LengthObject(Obj obj)
{
    return AttrLENGTH( LengthAttr, obj );
}

static Obj LengthInternal(Obj obj)
{
    return INTOBJ_INT(LEN_LIST(obj));
}




/****************************************************************************
**
*F  ISB_LIST(<list>,<pos>)  . . . . . . . . . .  test for element from a list
*V  IsbListFuncs[<type>]  . . . . . . . . . . . . . . table of test functions
**
**  'ISB_LIST' only calls the function pointed to by  'IsbListFuncs[<type>]',
**  passing <list> and <pos> as arguments.  If <type> is not the  type  of  a
**  list, then 'IsbListFuncs[<type>]' points to 'IsbListError', which signals
**  the error.
*/
BOOL (*IsbListFuncs[LAST_REAL_TNUM + 1])(Obj list, Int pos);

static Obj             IsbListOper;

static Obj FuncISB_LIST(Obj self, Obj list, Obj pos)
{
    if (IS_POS_INTOBJ(pos))
        return ISB_LIST( list, INT_INTOBJ(pos) ) ? True : False;
    else
        return ISBB_LIST( list, pos ) ? True : False;
}

static BOOL IsbListError(Obj list, Int pos)
{
    RequireArgument("IsBound", list, "must be a list");
}

static BOOL IsbListObject(Obj list, Int pos)
{
    return DoOperation2Args( IsbListOper, list, INTOBJ_INT(pos) ) == True;
}

BOOL ISBB_LIST(Obj list, Obj pos)
{
    return DoOperation2Args( IsbListOper, list, pos ) == True;
}

BOOL ISB_MAT(Obj mat, Obj row, Obj col)
{
    return DoOperation3Args(IsbListOper, mat, row, col) == True;
}


/****************************************************************************
**
*F * * * * * * * * * * * * list access functions  * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  Elm0ListFuncs[ <type> ] . . . . . . . . . .  table of selection functions
**
**  'ELM0_LIST' returns the element at the position <pos> in the list <list>,
**  or 0 if <list>  has no assigned  object at position  <pos>.  An  error is
**  signalled if <list>  is  not a list.  It   is the responsibility   of the
**  caller to ensure that <pos> is a positive integer.
*/
Obj (*Elm0ListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

/****************************************************************************
**
*V  ElmDefListFuncs[ <type> ] . . . . . . . . .  table of selection functions
**
**  'ELM_DEFAULT_LIST' returns the element at the position <pos> in the list
**  <list>, or <default> if <list> has no assigned object at position <pos>.
**  An error is signalled if <list> is not a list. It is the responsibility
**  of the caller to ensure that <pos> is a positive integer.
*/
Obj (*ElmDefListFuncs[LAST_REAL_TNUM + 1])(Obj list, Int pos, Obj def);

// Default implementation of ELM_DEFAULT_LIST
static Obj ElmDefListDefault(Obj list, Int pos, Obj def)
{
    Obj val = ELM0_LIST(list, pos);
    if (val) {
        return val;
    }
    else {
        return def;
    }
}

/****************************************************************************
**
*F  ElmDefListObject( <list>, <pos>, <default> )select an element from a list
**
**  `ElmDefListObject' is the `ELM_DEFAULT_LIST' function for objects.
**
*/
static Obj ElmDefListOper;

static Obj ElmDefListObject(Obj list, Int pos, Obj def)
{
    return DoOperation3Args(ElmDefListOper, list, INTOBJ_INT(pos), def);
}

static Obj FuncELM_DEFAULT_LIST(Obj self, Obj list, Obj pos, Obj def)
{
    Int ipos = GetPositiveSmallInt("GetWithDefault", pos);
    return ELM_DEFAULT_LIST(list, ipos, def);
}

/****************************************************************************
**
*V  Elm0vListFuncs[ <type> ]  . . . . . . . . .  table of selection functions
**
**  'ELMV0_LIST' does the same as 'ELM0_LIST', but the caller also guarantees
**  that <list> is a list and that <pos> is less than  or equal to the length
**  of <list>.
*/
Obj (*Elm0vListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );


/****************************************************************************
**
*F  Elm0ListError( <list>, <pos> )  . . . . . . . . . . . . . . error message
*/
static Obj Elm0ListError(Obj list, Int pos)
{
    RequireArgument("List Element", list, "must be a list");
}


/****************************************************************************
**
*F  Elm0ListObject( <list>, <pos> ) . . . . . . select an element from a list
**
**  `Elm0ListObject'  is    the  `ELM0_LIST'  and  `ELMV0_LIST' function  for
**  objects.  The  function returns the element at  the position <pos> of the
**  list object <list>, or 0 if <list>  has no assigned object  at <pos>.  It
**  is the responsibility  of the caller to  ensure that <pos> is a  positive
**  integer.
*/
static Obj Elm0ListObject(Obj list, Int pos)
{
    if (ISB_LIST(list, pos))
        return ELM_LIST(list, pos);
    else
        return 0;
}


/****************************************************************************
**
*V  ElmListFuncs[<type>]  . . . . . . . . . . .  table of selection functions
**
**  'ELM_LIST' returns the element at the position  <pos> in the list <list>.
**  An  error is signalled if  <list> is not a list,  if <pos> is larger than
**  the length of <list>, or if <list>  has no assigned  object at <pos>.  It
**  is the responsibility  of the caller to  ensure that <pos>  is a positive
**  integer.
**
**  'ELM_LIST' only calls the functions  pointed to by 'ElmListFuncs[<type>]'
**  passing <list> and <pos>  as arguments.  If  <type> is not  the type of a
**  list, then 'ElmListFuncs[<type>]' points to 'ElmListError', which signals
**  the error.
*/
Obj (*ElmListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );


/****************************************************************************
**
*V  ElmvListFuncs[<type>] . . . . . . . . . . .  table of selection functions
**
**  'ELMV_LIST' does  the same as 'ELM_LIST', but  the caller also guarantees
**  that <list> is a list and that <pos> is less  than or equal to the length
**  of <list>.
*/
Obj (*ElmvListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );


/****************************************************************************
**
*V  ElmwListFuncs[<type>] . . . . . . . . . . .  table of selection functions
**
**  'ELMW_LIST' does the same as 'ELMV_LIST', but  the caller also guarantees
**  that <list> has an assigned object at the position <pos>.
*/
Obj (*ElmwListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );


/****************************************************************************
**
*F  ElmListError( <list>, <pos> ) . . . . . . . . . . . . . . . error message
*/
static Obj ElmListError(Obj list, Int pos)
{
    RequireArgument("List Element", list, "must be a list");
}


/****************************************************************************
**
*F  ElmListObject( <list>, <pos>  . . . . . . . select an element from a list
**
**  `ElmListObject' is the `ELM_LIST',  `ELMV_LIST', and `ELMW_LIST' function
**  for objects.   'ElmListObjects' selects the  element at position <pos> of
**  list  object <list>.   It is the  responsibility  of the caller to ensure
**  that <pos> is a positive integer.  The methods have to signal an error if
**  <pos> is larger than the length of <list> or if the entry is not bound.
*/
static Obj ElmListOper;

static Obj ElmListObject(Obj list, Int pos)
{
    return ELMB_LIST( list, INTOBJ_INT(pos) );
}


Obj ELMB_LIST(Obj list, Obj pos)
{
    Obj                 elm;

    elm = DoOperation2Args( ElmListOper, list, pos );
    if (elm == 0) {
        ErrorMayQuit("List access method must return a value", 0, 0);
    }
    return elm;
}


/****************************************************************************
**
*F  FuncELM_MAT( <self>, <mat>, <row>, <col> ) . . . . .  operation `ELM_MAT'
*/
static Obj FuncELM_MAT(Obj self, Obj mat, Obj row, Obj col)
{
    return ELM_MAT(mat, row, col);
}

static Obj ElmMatOper;

Obj ELM_MAT(Obj mat, Obj row, Obj col)
{
    Obj elm;
    if (IS_POS_INTOBJ(row) && IS_POS_INTOBJ(col) && IS_PLIST(mat)) {
        Int r = INT_INTOBJ(row);
        if (r <= LEN_PLIST(mat)) {
            Obj rowlist = ELM_PLIST(mat, r);
            Int c = INT_INTOBJ(col);

            if (!rowlist)
                ErrorMayQuit("Matrix Element: <mat>[%d] must have an assigned value",
                             (Int)r, (Int)c);
            if (IS_PLIST(rowlist) && c <= LEN_PLIST(rowlist)) {
                elm = ELM_PLIST(rowlist, c);
                if (!elm)
                    ErrorMayQuit("Matrix Element: <mat>[%d,%d] must have an assigned value",
                                 (Int)r, (Int)c);
                return elm;
            }

            // fallback to generic list access code (also triggers error if
            // row isn't a list)
            return ELM_LIST(rowlist, c);
        }
    }

    elm = DoOperation3Args(ElmMatOper, mat, row, col);
    if (elm == 0) {
        ErrorMayQuit("Matrix access method must return a value", 0, 0);
    }
    return elm;
}


/****************************************************************************
**
*F  FuncELM_LIST( <self>, <list>, <pos> ) . . . . . . .  operation `ELM_LIST'
*/
static Obj FuncELM_LIST(Obj self, Obj list, Obj pos)
{
    if (IS_POS_INTOBJ(pos))
        return ELM_LIST(list, INT_INTOBJ(pos));
    else
        return ELMB_LIST(list, pos);
}


/****************************************************************************
**
*V  ElmsListFuncs[<type>] . . . . . . . . . . .  table of selection functions
**
**  'ELMS_LIST' returns a  new list containing the  elements at the positions
**  given in the list  <poss> from the <list>.  It  is the responsibility  of
**  the caller  to ensure that  <poss>  is dense and  contains only  positive
**  integers.  An error  is signalled if an element  of <poss> is larger than
**  the length of <list>.
**
**  'ELMS_LIST'    only    calls    the     function   pointed     to      by
**  'ElmsListFuncs[<type>]',  passing  <list> and  <poss>   as arguments.  If
**  <type> is not the type of  a list, then 'ElmsListFuncs[<type>]' points to
**  'ElmsListError', which just signals an error.
*/
Obj (*ElmsListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Obj poss );


/****************************************************************************
**
*F  ElmsListError(<list>,<poss>)  . . . . . . . . .  error selection function
*/
static Obj ElmsListError(Obj list, Obj poss)
{
    RequireArgument("List Elements", list, "must be a list");
}


/****************************************************************************
**
*F  ElmsListObject( <list>, <pos> ) . . . . . . . select elements from a list
**
**  `ElmsListObject' is the `ELMS_LIST' function for objects.
*/
static Obj ElmsListOper;

static Obj ElmsListObject(Obj list, Obj poss)
{
    Obj                 elm;

    elm = DoOperation2Args( ElmsListOper, list, poss );
    if (elm == 0) {
        ErrorMayQuit("List multi-access method must return a value", 0, 0);
    }
    return elm;
}


/****************************************************************************
**
*F  FuncELMS_LIST( <self>, <list>, <poss> ) . . . . . . `ELMS_LIST' operation
*/
static Obj FuncELMS_LIST(Obj self, Obj list, Obj poss)
{
    return ElmsListCheck( list, poss );
}


/****************************************************************************
**
*F  ElmsListDefault( <list>, <poss> ) . . .  default function for `ELMS_LIST'
**
**  Create a new plain list as result. <list> must be small.
*/
Obj ElmsListDefault (
    Obj                 list,
    Obj                 poss )
{
    Obj                 elms;           /* selected sublist, result        */
    Obj                 elm;            /* one element from <list>         */
    Int                 lenPoss;        /* length of <positions>           */
    Int                 pos;            /* <position> as integer           */
    Int                 inc;            /* increment in a range            */
    Int                 i;              /* loop variable                   */

    /* select no element                                                   */
    if ( LEN_LIST(poss) == 0 ) {
        elms = NewEmptyPlist();
    }

    /* general code                                                        */
    else if ( ! IS_RANGE(poss) ) {

        /* get the length of <positions>                                   */
        /* OK because all positions lists are small                        */
        lenPoss = LEN_LIST( poss );

        /* make the result list                                            */
        elms = NEW_PLIST( T_PLIST, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
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
            elm = ELM0_LIST( list, pos );
            if ( elm == 0 ) {
                ErrorMayQuit(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0);
            }

            /* assign the element into <elms>                              */
            SET_ELM_PLIST( elms, i, elm );

            /* notify Gasman                                               */
            CHANGED_BAG( elms );

        }

    }

    /* special code for ranges                                             */
    else {

        /* get the length of <list>                                        */
        Int lenList = LEN_LIST( list );

        /* get the length of <positions>, the first elements, and the inc. */
        lenPoss = GET_LEN_RANGE( poss );
        pos = GET_LOW_RANGE( poss );
        inc = GET_INC_RANGE( poss );

        /* check that no <position> is larger than 'LEN_LIST(<list>)'      */
        if ( lenList < pos ) {
            ErrorMayQuit(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos, 0);
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorMayQuit(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos + (lenPoss - 1) * inc, 0);
        }

        /* make the result list                                            */
        elms = NEW_PLIST( T_PLIST, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {

            /* select the element                                          */
            elm = ELMV0_LIST( list, pos );
            if ( elm == 0 ) {
                ErrorMayQuit(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0);
            }

            /* assign the element to <elms>                                */
            SET_ELM_PLIST( elms, i, elm );

            /* notify Gasman                                               */
            CHANGED_BAG( elms );

        }

    }

    return elms;
}


/****************************************************************************
**
*F  FuncELMS_LIST_DEFAULT( <self>, <list>, <poss> ) . . . . `ElmsListDefault'
*/
static Obj FuncELMS_LIST_DEFAULT(Obj self, Obj list, Obj poss)
{
    return ElmsListDefault( list, poss );
}


/****************************************************************************
**
*F  ElmsListCheck( <list>, <poss> ) . . . . . . . . . . . . . . . . ELMS_LIST
**
**  `ElmsListCheck' checks that <poss> is  a possitions lists before  calling
**  `ELMS_LIST'.
*/
Obj ElmsListCheck (
    Obj                 list,
    Obj                 poss )
{
    CheckIsPossList("List Elements", poss);
    return ELMS_LIST( list, poss );
}


/****************************************************************************
**
*F  ElmsListLevelCheck( <lists>, <poss>, <level> )  . . . . . . ElmsListLevel
**
**  `ElmsListLevelCheck'   checks that  <poss> is  a  possitions lists before
**  calling `ElmsListLevel'.
*/
void ElmsListLevelCheck (
    Obj                 lists,
    Obj                 poss,
    Int                 level )
{
    CheckIsPossList("List Elements", poss);
    ElmsListLevel( lists, poss, level );
}


/****************************************************************************
**
*F  UNB_LIST(<list>,<pos>)  . . . . . . . . . . .  unbind element from a list
*V  UnbListFuncs[<type>]  . . . . . . . . . . . . . table of unbind functions
*F  UnbListError(<list>,<pos>)  . . . . . . . . . . . . error unbind function
**
*/
void             (*UnbListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

static Obj             UnbListOper;

static Obj FuncUNB_LIST(Obj self, Obj list, Obj pos)
{
    if (IS_POS_INTOBJ(pos))
        UNB_LIST( list, INT_INTOBJ(pos) );
    else
        UNBB_LIST( list, pos );
    return 0;
}

static void UnbListError(Obj list, Int pos)
{
    RequireArgument("Unbind", list, "must be a list");
}

static void UnbListObject(Obj list, Int pos)
{
    DoOperation2Args( UnbListOper, list, INTOBJ_INT(pos) );
}

void            UNBB_LIST (
    Obj                 list,
    Obj                 pos )
{
    DoOperation2Args( UnbListOper, list, pos );
}

void UNB_MAT(Obj mat, Obj row, Obj col)
{
    DoOperation3Args(UnbListOper, mat, row, col);
}


/****************************************************************************
**
*F  ASS_LIST(<list>,<pos>,<obj>)  . . . . . . . . assign an element to a list
*V  AssListFuncs[<type>]  . . . . . . . . . . . table of assignment functions
*F  AssListError(<list>,<pos>,<obj>)  . . . . . . . error assignment function
**
**  'ASS_LIST' only calls the  function pointed to by 'AssListFuncs[<type>]',
**  passing <list>, <pos>, and <obj> as arguments.  If <type> is not the type
**  of  a list, then 'AssListFuncs[<type>]'  points to 'AssListError',  which
**  just signals an error.
**
*/
void            (*AssListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos, Obj obj );

static Obj AssListOper;

static Obj FuncASS_LIST(Obj self, Obj list, Obj pos, Obj obj)
{
    if (IS_POS_INTOBJ(pos))
        ASS_LIST(list, INT_INTOBJ(pos), obj);
    else
        ASSB_LIST(list, pos, obj);
    return 0;
}

static void AssListError(Obj list, Int pos, Obj obj)
{
    RequireArgument("List Assignments", list, "must be a list");
}


/****************************************************************************
**
*F  AssListObject( <list>, <pos>, <obj> ) . . . . . . . assign to list object
*/

void AssListObject (
    Obj                 list,
    Int                 pos,
    Obj                 obj )
{
    DoOperation3Args( AssListOper, list, INTOBJ_INT(pos), obj );
}

void ASSB_LIST (
    Obj                 list,
    Obj                 pos,
    Obj                 obj )
{
    DoOperation3Args( AssListOper, list, pos, obj );
}

static Obj AssMatOper;

static Obj FuncASS_MAT(Obj self, Obj mat, Obj row, Obj col, Obj obj)
{
    ASS_MAT(mat, row, col, obj);
    return 0;
}

void ASS_MAT(Obj mat, Obj row, Obj col, Obj obj)
{
    RequireMutable("Matrix Assignment", mat, "matrix");
    if (IS_POS_INTOBJ(row) && IS_POS_INTOBJ(col) && IS_PLIST(mat)) {
        Int r = INT_INTOBJ(row);
        if (r <= LEN_PLIST(mat)) {
            Obj rowlist = ELM_PLIST(mat, r);
            Int c = INT_INTOBJ(col);

            if (!rowlist)
                ErrorMayQuit("Matrix Assignment: <mat>[%d] must have an assigned value",
                             (Int)r, (Int)c);
            ASS_LIST(rowlist, c, obj);
            return;
        }
    }

    DoOperation4Args(AssMatOper, mat, row, col, obj);
}


/****************************************************************************
**
*F  ASSS_LIST(<list>,<poss>,<objs>) . . . . assign several elements to a list
*V  AsssListFuncs[<type>] . . . . . . . . . . .  table of assignment function
*F  AsssListError(<list>,<poss>,<objs>) . . . . . . error assignment function
**
**  'ASSS_LIST'    only      calls      the   function pointed      to     by
**  'AsssListFuncs[<type>]', passing <list>, <poss>, and <objs> as arguments.
**  If <type> is not the type of  a list, then 'AsssListFuncs[<type>]' points
**  to 'AsssListError', which just signals an error.
*/
void            (*AsssListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Obj poss, Obj objs );

static Obj             AsssListOper;

static Obj FuncASSS_LIST(Obj self, Obj list, Obj poss, Obj objs)
{
    AsssListCheck( list, poss, objs );
    return 0;
}

static void AsssListError(Obj list, Obj poss, Obj objs)
{
    RequireArgument("List Assignments", list, "must be a list");
}

void            AsssListDefault (
    Obj                 list,
    Obj                 poss,
    Obj                 objs )
{
    Int                 lenPoss;        /* length of <positions>           */
    Obj                 p;              /* <position> */
    Int                 pos;            /* <position> as integer           */
    Int                 inc;            /* increment in a range            */
    Obj                 obj;            /* one element from <objs>         */
    Int                 i;              /* loop variable                   */

    CheckIsPossList("List Assignments", poss);
    CheckIsDenseList("List Assignments", "rhss", objs);
    CheckSameLength("List Assignments", "rhss", "poss", objs, poss);

    /* general code                                                        */
    if ( ! IS_RANGE(poss) ) {

        /* get the length of <positions>                                   */
        lenPoss = LEN_LIST( poss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
          p  = ELMW_LIST( poss, i );
          
          /* select the element                                          */
          obj = ELMW_LIST( objs, i );
          if (IS_INTOBJ(p) )
            {
              /* assign the element into <elms>                              */
              ASS_LIST( list, INT_INTOBJ(p), obj );
            }
          else
            ASSB_LIST(list, p, obj);

        }

    }

    /* special code for ranges                                             */
    else {

        /* get the length of <positions>                                   */
        lenPoss = GET_LEN_RANGE( poss );
        pos = GET_LOW_RANGE( poss );
        inc = GET_INC_RANGE( poss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {

            /* select the element                                          */
            obj = ELMW_LIST( objs, i );

            /* assign the element to <elms>                                */
            ASS_LIST( list, pos, obj );

        }

    }

}

static void AsssListObject(Obj list, Obj poss, Obj objs)
{
    DoOperation3Args( AsssListOper, list, poss, objs );
}

static Obj FuncASSS_LIST_DEFAULT(Obj self, Obj list, Obj poss, Obj objs)
{
    AsssListDefault( list, poss, objs );
    return 0;
}


/****************************************************************************
**
*F  IS_DENSE_LIST(<list>) . . . . . . . . . . . . . . .  test for dense lists
*V  IsDenseListFuncs[<type>]  . . . . . . table for dense list test functions
**
**  'IS_DENSE_LIST'  only     calls   the      function   pointed    to    by
**  'IsDenseListFuncs[<type>]', passing <list> as argument.  If <type> is not
**  the   type  of  a    list,  then  'IsDenseListFuncs[<type>]'  points   to
**  'AlwaysNo', which just returns 0.
*/
BOOL (*IsDenseListFuncs[LAST_REAL_TNUM + 1])(Obj list);

static Obj IsDenseListFilt;

static Obj FiltIS_DENSE_LIST(Obj self, Obj obj)
{
    return (IS_DENSE_LIST( obj ) ? True : False);
}

static BOOL IsDenseListObject(Obj obj)
{
    return (DoFilter( IsDenseListFilt, obj ) == True);
}


/****************************************************************************
**
*F  IS_HOMOG_LIST(<list>) . . . . . . . . . . . .  test for homogeneous lists
*V  IsHomogListFuncs[<type>]  . . . table for homogeneous list test functions
**
**  'IS_HOMOG_LIST' only calls the function pointed to by
**  'IsHomogListFuncs[<type>]', passing <list> as argument.  If <type> is not
**  the type of a list, then 'IsHomogListFuncs[<type>]' points to
**  'AlwaysNo', which just returns 0.
**
*/
BOOL (*IsHomogListFuncs[LAST_REAL_TNUM + 1])(Obj list);

static Obj IsHomogListFilt;

static Obj FiltIS_HOMOG_LIST(Obj self, Obj obj)
{
    return (IS_HOMOG_LIST( obj ) ? True : False);
}

static BOOL IsHomogListObject(Obj obj)
{
    return (DoFilter( IsHomogListFilt, obj ) == True);
}


/****************************************************************************
**
*F  IS_TABLE_LIST(<list>) . . . . . . . . . . . . . . .  test for table lists
*V  IsTableListFuncs[<type>]  . . . . . . table for table list test functions
**
**  'IS_TABLE_LIST' only calls the function pointed to by
**  'IsTableListFuncs[<type>]', passing <list> as argument.  If <type> is not
**  the type of a list, then 'IsTableListFuncs[<type>]' points to
**  'AlwaysNo', which just returns 0.
*/
BOOL (*IsTableListFuncs[LAST_REAL_TNUM + 1])(Obj list);

static Obj IsTableListFilt;

static Obj FiltIS_TABLE_LIST(Obj self, Obj obj)
{
    return (IS_TABLE_LIST( obj ) ? True : False);
}

static BOOL IsTableListObject(Obj obj)
{
    return (DoFilter( IsTableListFilt, obj ) == True);
}


/****************************************************************************
**
*F  IS_SSORT_LIST( <list> ) . . . . . . . . .  test for strictly sorted lists
*V  IsSSortListFuncs[<type>]  .  table of strictly sorted list test functions
**
**  'IS_SSORT_LIST' only calls the function pointed to by
**  'IsSSortListFuncs[<type>]', passing <list> as argument.
**  If <type> is not the type of a list, then 'IsSSortListFuncs[<type>]'
**  points to 'AlwaysNo', which just returns 0.
**
*/
BOOL (*IsSSortListFuncs[LAST_REAL_TNUM + 1])(Obj list);

static Obj IsSSortListProp;

static Obj PropIS_SSORT_LIST(Obj self, Obj obj)
{
    return (IS_SSORT_LIST( obj ) ? True : False);
}

static BOOL IsSSortListDefault(Obj list)
{
    Int                 lenList;
    Obj                 elm1;
    Obj                 elm2;
    Int                 i;

    /* get the length of the list                                          */
    lenList = LEN_LIST( list );

    /* special case for the empty list                                     */
    if ( lenList == 0 ) {
        return TRUE;
    }

    /* get the first element                                               */
    elm1 = ELM0_LIST(list, 1);

    if (!elm1) {
        return FALSE;
    }

    /* compare each element with its precursor                             */
    for ( i = 2; i <= lenList; i++ ) {
        elm2 = ELM0_LIST(list, i);
        if (!elm2) {
            return FALSE;
        }
        if ( ! LT( elm1, elm2 ) ) {
            return FALSE;
        }
        elm1 = elm2;
    }

    /* the list is strictly sorted                                         */
    return TRUE;
}

static BOOL IsSSortListObject(Obj obj)
{
    return (DoProperty( IsSSortListProp, obj ) == True);
}

static Obj FuncIS_SSORT_LIST_DEFAULT(Obj self, Obj obj)
{
    return (IsSSortListDefault( obj ) ? True : False);
}


/****************************************************************************
**
*F  IS_POSS_LIST(<list>)  . . . . . . . . . . . . .  test for positions lists
*V  IsPossListFuncs[<type>] . . . . . . table of positions list test function
**
**  'IS_POSS_LIST'     only   calls    the     function  pointed      to   by
**  'IsPossListFuncs[<type>]', passing <list> as  argument.  If <type> is not
**  the   type    of a   list,    then  'IsPossListFuncs[<type>]'   points to
**  'NotIsPossList', which just returns 0.
*/
BOOL (*IsPossListFuncs[LAST_REAL_TNUM + 1])(Obj list);

static Obj IsPossListProp;

static Obj PropIS_POSS_LIST(Obj self, Obj obj)
{
    return (IS_POSS_LIST(obj) ? True : False);
}

static BOOL IsPossListDefault(Obj list)
{
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Int                 i;              /* loop variable                   */

    /* get the length of the variable                                      */
    lenList = LEN_LIST( list );

    /* loop over the entries of the list                                   */
    for ( i = 1; i <= lenList; i++ ) {
        elm = ELMV0_LIST( list, i );

        /* if it has a hole then it isn't a poss list */
        if ( elm == 0)
          return FALSE;

        /* if it's a small integer and non-positive then
           it's not a poss list */
        if ( IS_INTOBJ(elm)) {
          if (INT_INTOBJ(elm) <= 0)
            return FALSE;
        }
        /* or if it's not a small integer or a positive large integer then it's
           not a poss list */
        else if (TNUM_OBJ(elm) != T_INTPOS)
          return FALSE;
    }

    /* the list is a positions list                                        */
    return TRUE;
}

static BOOL IsPossListObject(Obj obj)
{
    return (DoProperty( IsPossListProp, obj ) == True);
}

static Obj FuncIS_POSS_LIST_DEFAULT(Obj self, Obj obj)
{
    return (IsPossListDefault( obj ) ? True : False);
}


/****************************************************************************
**
*F  POS_LIST(<list>,<obj>,<start>)  . . . . . . . . find an element in a list
*V  PosListFuncs[<type>]  . . . . . . . . . . .  table of searching functions
*F  PosListError(<list>,<obj>,<start>)  . . . . . .  error searching function
**
**  'POS_LIST' only calls  the function pointed to by 'PosListFuncs[<type>]',
**  passing <list>, <obj>,  and <start> as arguments.  If  <type>  is not the
**  type  of  a list, then  'PosListFuncs[<type>]'  points to 'PosListError',
**  which just signals an error.
*/
Obj             (*PosListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Obj obj, Obj start );

static Obj             PosListOper;

static Obj PosListHandler2(Obj self, Obj list, Obj obj)
{
    return POS_LIST( list, obj, INTOBJ_INT(0) );
}

static Obj PosListHandler3(Obj self, Obj list, Obj obj, Obj start)
{
    if (TNUM_OBJ(start) != T_INTPOS && !IS_NONNEG_INTOBJ(start)) {
        RequireArgument(SELF_NAME, start, "must be a non-negative integer");
    }
    return POS_LIST( list, obj, start );
}

static Obj PosListError(Obj list, Obj obj, Obj start)
{
    RequireArgument("Position", list, "must be a list");
}

static Obj PosListDefault (
    Obj                 list,
    Obj                 obj,
    Obj                 start )
{
    Int                 lenList;
    Obj                 elm;
    Int                 i;

    /* if the starting position is too big to be a small int
       then there can't be anything to find */
    if (!IS_INTOBJ(start))
      return Fail;

    /* get the length of the list                                          */
    lenList = LEN_LIST( list );

    /* loop over all bound entries of the list, and compare against <obj>  */
    for ( i = INT_INTOBJ(start)+1; i <= lenList; i++ ) {
        elm = ELMV0_LIST( list, i );
        if ( elm != 0 && EQ( elm, obj ) ) {
            break;
        }
    }

    /* return the position if found, and 0 otherwise                       */
    if ( i <= lenList ) {
      return INTOBJ_INT(i);
    }
    else {
      return Fail;
    }
}

static Obj PosListObject(Obj list, Obj obj, Obj start)
{
    return DoOperation3Args( PosListOper, list, obj, start );
}

static Obj FuncPOS_LIST_DEFAULT(Obj self, Obj list, Obj obj, Obj start)
{
    return PosListDefault( list, obj, start ) ;
}


/****************************************************************************
**
*F  ElmListLevel(<lists>,<pos>,<level>) . . . . . . . . . . . . . . . . . . .
*F  . . . . . . . . . . . . .  select an element of several lists in parallel
**
**  'ElmListLevel' either  selects an element  from all  lists in parallel if
**  <level> is 1, or recurses if <level> is greater than 1.
*/
void            ElmListLevel (
    Obj                 lists,
    Obj                 ixs,
    Int                 level )
{
    Int                 len;            /* length of <lists>               */
    Obj                 list;           /* one list from <lists>           */
    Obj                 elm;            /* selected element from <list>    */
    Int                 i;              /* loop variable                   */
    Obj                 pos;
    Obj                 row;
    Obj                 col;

    RequirePlainList("List Elements", lists);

    /* if <level> is one, perform the replacements                         */
    if ( level == 1 ) {

        /* loop over the elements of <lists> (which must be a plain list)  */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* select the element                                          */
            switch(LEN_PLIST(ixs)) {
            case 1:
              pos = ELM_PLIST(ixs,1);
              if (IS_INTOBJ(pos))
                elm = ELM_LIST( list, INT_INTOBJ(pos) );
              else
                elm = ELMB_LIST(list, pos);
              break;
          
            case 2:
                row = ELM_PLIST(ixs, 1);
                col = ELM_PLIST(ixs, 2);
                elm = ELM_MAT(list, row, col);
                break;

            default:
              elm = ELMB_LIST(list, ixs);
          
            }

            /* replace the list with the element                           */
            SET_ELM_PLIST( lists, i, elm );

            /* notify Gasman                                               */
            CHANGED_BAG( lists );

        }
        RetypeBag(lists, T_PLIST_DENSE);

    }

    /* otherwise recurse                                                   */
    else {

        /* loop over the elements of <lists> (which must be a plain list)  */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* recurse                                                     */
            ElmListLevel( list, ixs, level-1 );

        }

    }

}


/****************************************************************************
**
*F  ElmsListLevel(<lists>,<poss>,<level>) . . . . . . . . . . . . . . . . . .
*F  . . . . . . . . . .  select several elements of several lists in parallel
**
**  'ElmsListLevel' either selects  elements  from all lists in  parallel  if
**  <level> is 1, or recurses if <level> is greater than 1.
*/
void            ElmsListLevel (
    Obj                 lists,
    Obj                 poss,
    Int                 level )
{
    Int                 len;            /* length of <lists>               */
    Obj                 list;           /* one list from <lists>           */
    Obj                 elm;            /* selected elements from <list>   */
    Int                 i;              /* loop variable                   */

    RequirePlainList("List Elements", lists);

    /* if <level> is one, perform the replacements                         */
    if ( level == 1 ) {

        /* loop over the elements of <lists> (which must be a plain list)  */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* select the elements                                         */
            elm = ELMS_LIST( list, poss );

            /* replace the list with the elements                          */
            SET_ELM_PLIST( lists, i, elm );

            /* notify Gasman                                               */
            CHANGED_BAG( lists );

        }

        /* Since the elements of lists are now mutable lists
           (made by ELMS_LIST in the list above), we cannot remember too much
           about them */
        RetypeBag(lists, T_PLIST_DENSE);

    }

    /* otherwise recurse                                                   */
    else {

        /* loop over the elements of <lists> (which must be a plain list)  */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* recurse                                                     */
            ElmsListLevel( list, poss, level-1 );

        }
        RetypeBag(lists, T_PLIST_DENSE);

    }

}


/****************************************************************************
**
*F  AssListLevel(<lists>,<ixs>,<objs>,<level>)  . . . . . . . . . . . . . . .
*F  . . . . . . . . . . . . .  assign an element to several lists in parallel
**
**  'AssListLevel'  either assigns an  element  to all  lists in parallel  if
**  <level> is 1, or recurses if <level> is greater than 1.
*/
void            AssListLevel (
    Obj                 lists,
    Obj                 ixs,
    Obj                 objs,
    Int                 level )
{
    Int                 len;            /* length of <lists> and <objs>    */
    Obj                 list;           /* one list of <lists>             */
    Obj                 obj;            /* one value from <objs>           */
    Int                 i;              /* loop variable                   */
    Obj                 pos;
    Obj                 row;
    Obj                 col;

    RequirePlainList("List Assignments", lists);
    RequireDenseList("List Assignments", objs);
    RequireSameLength("List Assignments", objs, lists);

    /* if <level> is one, perform the assignments                          */
    if ( level == 1 ) {

        /* loop over the elements of <lists> (which must be a plain list)  */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* select the element to assign                                */
            obj = ELMW_LIST( objs, i );

            switch(LEN_PLIST(ixs)) {
            case 1:
              /* assign the element                                          */
              pos = ELM_PLIST(ixs,1);
              if (IS_INTOBJ(pos))
                ASS_LIST( list, INT_INTOBJ(pos), obj );
              else
                ASSB_LIST(list, pos, obj);
              break;
          
            case 2:
                row = ELM_PLIST(ixs, 1);
                col = ELM_PLIST(ixs, 2);
                ASS_MAT(list, row, col, obj);
                break;

            default:
              ASSB_LIST(list, ixs, obj);
            }

        }

    }

    /* otherwise recurse                                                   */
    else {

        /* loop over the elements of <lists> (which must be a plain list)  */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* get the values                                              */
            obj = ELMW_LIST( objs, i );

            /* recurse                                                     */
            AssListLevel( list, ixs, obj, level-1 );

        }

    }

}


/****************************************************************************
**
*F  AsssListLevel(<lists>,<poss>,<objs>,<level>)  . . . . . . . . . . . . . .
*F  . . . . . . . . . .  assign several elements to several lists in parallel
**
**  'AsssListLevel'  either  assigns elements  to   all lists in parallel  if
**  <level> is 1, or recurses if <level> is greater than 1.
*/
void            AsssListLevel (
    Obj                 lists,
    Obj                 poss,
    Obj                 objs,
    Int                 lev )
{
    Int                 len;            /* length of <lists> and <objs>    */
    Obj                 list;           /* one list of <lists>             */
    Obj                 obj;            /* one value from <objs>           */
    Int                 i;              /* loop variable                   */

    RequirePlainList("List Assignments", lists);
    RequireDenseList("List Assignments", objs);
    RequireSameLength("List Assignments", objs, lists);

    /* if <lev> is one, loop over all the lists and assign the value       */
    if ( lev == 1 ) {

        /* loop over the list entries (which must be lists too)            */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* select the elements to assign                               */
            obj = ELMW_LIST( objs, i );
            CheckIsDenseList("List Assignments", "objs", obj);
            CheckSameLength("List Assignments", "objs", "poss", obj, poss);

            /* assign the elements                                         */
            ASSS_LIST( list, poss, obj );

        }

    }

    /* otherwise recurse                                                   */
    else {

        /* loop over the list entries (which must be lists too)            */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* get the values                                              */
            obj = ELMW_LIST( objs, i );

            /* recurse                                                     */
            AsssListLevel( list, poss, obj, lev-1 );

        }

    }

}


/****************************************************************************
**
*F  PLAIN_LIST(<list>)  . . . . . . . . . . .  convert a list to a plain list
*V  PlainListFuncs[<type>]  . . . . . . . . . . table of conversion functions
*F  PlainListError(<list>)  . . . . . . . . . . . . error conversion function
**
**  'PLAIN_LIST'    only    calls       the    function  pointed    to     by
**  'PlainListFuncs[<type>]', passing <list>  as argument.  If  <type> is not
**  the     type of   a    list,  then    'PlainListFuncs[<type>]'  points to
**  'PlainListError', which just signals an error.
*/
void            (*PlainListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

static void PlainListError(Obj list)
{
    ErrorQuit("Panic: cannot convert <list> (is a %s) to a plain list",
              (Int)TNAM_OBJ(list), 0);
}

Obj PLAIN_LIST_COPY(Obj list)
{
    if (IS_PLIST(list)) {
        return SHALLOW_COPY_OBJ(list);
    }
    const Int len = LEN_LIST(list);
    if (len == 0)
        return NewEmptyPlist();
    Obj res = NEW_PLIST(T_PLIST, len);
    SET_LEN_PLIST(res, len);
    for (Int i = 1; i <= len; i++) {
        SET_ELM_PLIST(res, i, ELMV0_LIST(list, i));
        CHANGED_BAG(res);
    }
    return res;
}

Obj FuncPlainListCopy(Obj self, Obj list)
{
    RequireSmallList(SELF_NAME, list);
    return PLAIN_LIST_COPY(list);
}


/****************************************************************************
**
*F  TYPES_LIST_FAM(<fam>) . . . . . . .  list of types of lists over a family
*/
static UInt TYPES_LIST_FAM_RNam;

Obj             TYPES_LIST_FAM (
    Obj                 fam )
{
#ifdef HPCGAP
    switch (TNUM_OBJ(fam))
    {
      case T_COMOBJ:
        return ElmPRec( fam, TYPES_LIST_FAM_RNam );
      case T_ACOMOBJ:
        MEMBAR_READ();
        return GetARecordField( fam, TYPES_LIST_FAM_RNam );
      default:
        return 0;
    }
#else
    return ElmPRec( fam, TYPES_LIST_FAM_RNam );
#endif
}


/****************************************************************************
**
*F  PrintListDefault(<list>)  . . . . . . . . . . . . . . . . .  print a list
*F  PrintPathList(<list>,<indx>)  . . . . . . . . . . . . . print a list path
**
**  'PrintListDefault' simply prints the elements in the given list.
**  The line break hints are consistent with those
**  that appear in the 'ViewObj' and 'ViewString' methods for finite lists.
*/
static void PrintListDefault(Obj list)
{
    Obj                 elm;

    if ( 0 < LEN_LIST(list) && IsStringConv(list) ) {
        PrintString(list);
        return;
    }

    Pr("%2>[ %2>", 0, 0);
    for (UInt i = 1; i <= LEN_LIST(list); i++) {
        elm = ELMV0_LIST(list, i);
        if ( elm != 0 ) {
            if (1 < i)
                Pr("%<,%< %2>", 0, 0);
            SetPrintObjIndex(i);
            PrintObj( elm );
        }
        else {
            if (1 < i)
                Pr("%2<,%2>", 0, 0);
        }
    }
    Pr(" %4<]", 0, 0);
}

static void PrintPathList(Obj list, Int indx)
{
    Pr("[%d]", indx, 0);
}


/****************************************************************************
**
*V  SetFiltListTNums[ <tnum> ][ <fnum> ]  . . . . . new tnum after filter set
**
**  If a list  with type number <tnum>  gains  the filter  with filter number
**  <fnum>, then the new type number is stored in:
**
**  `SetFiltListTNums[<tnum>][<fnum>]'
**
**  The macro  `SET_FILT_LIST' is  used  to  set  the filter  for a  list  by
**  changing its type number.
*/
UInt SetFiltListTNums [ LAST_REAL_TNUM ] [ LAST_FN + 1 ];


/****************************************************************************
**
*V  ResetFiltListTNums[ <tnum> ][ <fnum> ]  . . . new tnum after filter reset
**
**  If a list  with type number <tnum>  loses  the filter  with filter number
**  <fnum>, then the new type number is stored in:
**
**  `ResetFiltListTNums[<tnum>][<fnum>]'
**
**  The macro `RESET_FILT_LIST' is used  to  set  the filter  for a  list  by
**  changing its type number.
*/
UInt ResetFiltListTNums [ LAST_REAL_TNUM ] [ LAST_FN  + 1];


/****************************************************************************
**
*V  HasFiltListTNums[ <tnum> ][ <fnum> ]  . . . . . . . . . . . .  has filter
*/
Int HasFiltListTNums [ LAST_REAL_TNUM ] [ LAST_FN + 1 ];


/****************************************************************************
**
*V  ClearFiltsTNums[ <tnum> ] . . . . . . . . . . . .  clear all list filters
**
**  The type  number without any  known properties  of a  list of type number
**  <tnum> is stored in:
**
**  `ClearPropsTNums[<tnum>]'
**
**  The macro `CLEAR_PROPS_LIST' is used to clear all properties of a list.
*/
UInt ClearFiltsTNums [ LAST_REAL_TNUM ];


/****************************************************************************
**
*F  SET_FILTER_LIST( <list>, <filter> ) . . . . . . . . . . . . .  set filter
*/
Obj SET_FILTER_LIST(Obj list, Obj filter)
{
    Int             new;
    Obj             flags;

    flags = FLAGS_FILT(filter);
    if (IS_SUBSET_FLAGS(flags, FLAGS_FILT(IsSSortListProp))) {
        new = SetFiltListTNums[TNUM_OBJ(list)][FN_IS_DENSE];
        if ( new < 0 )  goto error;
        new = SetFiltListTNums[TNUM_OBJ(list)][FN_IS_SSORT];
        if ( new > 0 )  RetypeBag( list, new );  else goto error;
    }
    return 0;

    /* setting of filter failed                                            */
error:
    ErrorMayQuit("filter not possible for %s", (Int)TNAM_OBJ(list), 0);
    return 0;
}


/****************************************************************************
**
*F * * * * * * * * * * * functions with checking  * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  AsssListCheck( <list>, <poss>, <rhss> ) . . . . . . . . . . . . ASSS_LIST
*/
void AsssListCheck (
    Obj                 list,
    Obj                 poss,
    Obj                 rhss )
{
    CheckIsPossList("List Assignments", poss);
    RequireDenseList("List Assignments", rhss);
    RequireSameLength("List Assignments", rhss, poss);
    ASSS_LIST( list, poss, rhss );
}


/****************************************************************************
**
*F  AsssListLevelCheck( <lists>, <poss>, <rhss>, <level> )  . . AsssListLevel
*/
void AsssListLevelCheck (
    Obj                 lists,
    Obj                 poss,
    Obj                 rhss,
    Int                 level )
{
    CheckIsPossList("List Assignments", poss);
    AsssListLevel( lists, poss, rhss, level );
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_LIST, "obj", &IsListFilt),
    GVAR_FILT(IS_DENSE_LIST, "obj", &IsDenseListFilt),
    GVAR_FILT(IS_HOMOG_LIST, "obj", &IsHomogListFilt),
    GVAR_FILT(IS_TABLE_LIST, "obj", &IsTableListFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarAttrs . . . . . . . . . . . . . . . . .  list of attributes to export
*/
static StructGVarAttr GVarAttrs [] = {

    GVAR_ATTR(LENGTH, "list", &LengthAttr),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarProps . . . . . . . . . . . . . . . . .  list of properties to export
*/
static StructGVarProp GVarProps [] = {

    GVAR_PROP(IS_SSORT_LIST, "obj", &IsSSortListProp),
    GVAR_PROP(IS_POSS_LIST, "obj", &IsPossListProp),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers[] = {

    // POS_LIST can take 2 or 3 arguments; since NewOperation ignores the
    // handler for variadic operations, use DoOperation0Args as a placeholder.
    { "POS_LIST", -1, "list, obj[, start]", &PosListOper, DoOperation0Args,
      "src/lists.c:POS_LIST" },

    GVAR_OPER_2ARGS(ISB_LIST, list, pos, &IsbListOper),
    GVAR_OPER_3ARGS(ELM_DEFAULT_LIST, list, pos, default, &ElmDefListOper),
    GVAR_OPER_2ARGS(ELM_LIST, list, pos, &ElmListOper),
    GVAR_OPER_2ARGS(ELMS_LIST, list, poss, &ElmsListOper),
    GVAR_OPER_2ARGS(UNB_LIST, list, pos, &UnbListOper),
    GVAR_OPER_3ARGS(ASS_LIST, list, pos, obj, &AssListOper),
    GVAR_OPER_3ARGS(ASSS_LIST, list, poss, objs, &AsssListOper),

    GVAR_OPER_4ARGS(ASS_MAT, mat, row, col, obj, &AssMatOper),
    GVAR_OPER_3ARGS(ELM_MAT, mat, row, col, &ElmMatOper),

    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC_1ARGS(LEN_LIST, list),
    GVAR_FUNC_2ARGS(ELMS_LIST_DEFAULT, list, poss),
    GVAR_FUNC_3ARGS(ASSS_LIST_DEFAULT, list, poss, objs),
    GVAR_FUNC_1ARGS(IS_SSORT_LIST_DEFAULT, list),
    GVAR_FUNC_1ARGS(IS_POSS_LIST_DEFAULT, list),
    GVAR_FUNC_3ARGS(POS_LIST_DEFAULT, list, obj, start),
    GVAR_FUNC_1ARGS(PlainListCopy, list),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                type;           /* loop variable                   */
    Int                 i;              /* loop variable                   */

    /* make and install the 'POS_LIST' operation                           */
    InitHandlerFunc( PosListHandler2, "src/lists.c:PosListHandler2" );
    InitHandlerFunc( PosListHandler3, "src/lists.c:PosListHandler3" );

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrAttrsFromTable( GVarAttrs );
    InitHdlrPropsFromTable( GVarProps );
    InitHdlrOpersFromTable( GVarOpers );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* import small list machinery from the library */
    ImportFuncFromLibrary("IsSmallList", &IsSmallListFilt);
    ImportFuncFromLibrary("HasIsSmallList", &HasIsSmallListFilt);
    ImportFuncFromLibrary("SetIsSmallList", &SetIsSmallList);

    /* make and install the 'IS_LIST' filter                               */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(IsListFuncs[ type ] == 0);
        IsListFuncs[ type ] = AlwaysNo;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsListFuncs[ type ] = AlwaysYes;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsListFuncs[ type ] = IsListObject;
    }

    /* make and install the 'IS_SMALL_LIST' filter                   */
    /* non-lists are not small lists */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(IsSmallListFuncs[ type ] == 0);
        IsSmallListFuncs[ type ] = AlwaysNo;
    }
    /* internal lists ARE small lists */
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsSmallListFuncs[ type ] = AlwaysYes;
    }
    /* external lists need to be asked */
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsSmallListFuncs[ type ] = IsSmallListObject;
    }


    /* make and install the 'LEN_LIST' function                            */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(LenListFuncs[ type ] == 0);
        LenListFuncs[ type ] = LenListError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        LenListFuncs[ type ] = LenListObject;
    }

    /* make and install the 'LENGTH' function                            */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(LengthFuncs[ type ] == 0);
        LengthFuncs[ type ] = LengthError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        LengthFuncs[ type ] = LengthObject;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        LengthFuncs[ type ] = LengthInternal;
    }


    /* make and install the 'ISB_LIST' operation                           */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        IsbListFuncs[  type ] = IsbListError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsbListFuncs[  type ] = IsbListObject;
    }

    /* make and install the 'ELM0_LIST' operation                          */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(Elm0ListFuncs[  type ] == 0);
        Elm0ListFuncs[  type ] = Elm0ListError;
        assert(Elm0vListFuncs[ type ] == 0);
        Elm0vListFuncs[ type ] = Elm0ListError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        Elm0ListFuncs[  type ] = Elm0ListObject;
        Elm0vListFuncs[ type ] = Elm0ListObject;
    }

    // make and install ELM_DEFAULT_LIST operation
    // we install this for all TNUMs, as the default implementation delegates
    // to other list operations, we can error if approriate
    for (type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++) {
        ElmDefListFuncs[type] = ElmDefListDefault;
    }
    for (type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++) {
        ElmDefListFuncs[type] = ElmDefListObject;
    }


    /* make and install the 'ELM_LIST' operation                           */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(ElmListFuncs[  type ] == 0);
        ElmListFuncs[  type ] = ElmListError;
        assert(ElmvListFuncs[ type ] == 0);
        ElmvListFuncs[ type ] = ElmListError;
        assert(ElmwListFuncs[ type ] == 0);
        ElmwListFuncs[ type ] = ElmListError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        ElmListFuncs[  type ] = ElmListObject;
        ElmvListFuncs[ type ] = ElmListObject;
        ElmwListFuncs[ type ] = ElmListObject;
    }


    /* make and install the 'ELMS_LIST' operation                          */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(ElmsListFuncs[ type ] == 0);
        ElmsListFuncs[ type ] = ElmsListError;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        ElmsListFuncs[ type ] = ElmsListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        ElmsListFuncs[ type ] = ElmsListObject;
    }


    /* make and install the 'UNB_LIST' operation                           */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(UnbListFuncs[ type ] == 0);
        UnbListFuncs[ type ] = UnbListError;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        UnbListFuncs[ type ] = 0;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        UnbListFuncs[ type ] = UnbListObject;
    }


    /* make and install the 'ASS_LIST' operation                           */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(AssListFuncs[ type ] == 0);
        AssListFuncs[ type ] = AssListError;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        AssListFuncs[ type ] = 0;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        AssListFuncs[ type ] = AssListObject;
    }


    /* make and install the 'ASSS_LIST' operation                          */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(AsssListFuncs[ type ] == 0);
        AsssListFuncs[ type ] = AsssListError;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        AsssListFuncs[ type ] = AsssListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        AsssListFuncs[ type ] = AsssListObject;
    }
    

    /* make and install the 'IS_DENSE_LIST' filter                         */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(IsDenseListFuncs[ type ] == 0);
        IsDenseListFuncs[ type ] = AlwaysNo;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsDenseListFuncs[ type ] = 0;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsDenseListFuncs[ type ] = IsDenseListObject;
    }


    /* make and install the 'IS_HOMOG_LIST' filter                         */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(IsHomogListFuncs[ type ] == 0);
        IsHomogListFuncs[ type ] = AlwaysNo;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsHomogListFuncs[ type ] = 0;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsHomogListFuncs[ type ] = IsHomogListObject;
    }


    /* make and install the 'IS_TABLE_LIST' filter                         */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(IsTableListFuncs[ type ] == 0);
        IsTableListFuncs[ type ] = AlwaysNo;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsTableListFuncs[ type ] = 0;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsTableListFuncs[ type ] = IsTableListObject;
    }


    /* make and install the 'IS_SSORT_LIST' property                       */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(IsSSortListFuncs[ type ] == 0);
        IsSSortListFuncs[ type ] = AlwaysNo;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsSSortListFuncs[ type ] = 0;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsSSortListFuncs[ type ] = IsSSortListObject;
    }


    /* make and install the 'IS_POSS_LIST' property                        */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(IsPossListFuncs[ type ] == 0);
        IsPossListFuncs[ type ] = AlwaysNo;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsPossListFuncs[ type ] = 0;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsPossListFuncs[ type ] = IsPossListObject;
    }


    /* make and install the 'POS_LIST' operation                           */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(PosListFuncs[ type ] == 0);
        PosListFuncs[ type ] = PosListError;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        PosListFuncs[ type ] = 0;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        PosListFuncs[ type ] = PosListObject;
    }


    /* install the error functions into the other tables                   */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(PlainListFuncs [ type ] == 0);
        PlainListFuncs [ type ] = PlainListError;
    }


    /* install tests for being copyable                                    */
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type += 2 ) {
        IsCopyableObjFuncs[ type           ] = AlwaysYes;
        IsCopyableObjFuncs[ type+IMMUTABLE ] = AlwaysYes;
    }

    /* install the default printers                                        */
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        PrintObjFuncs [ type ] = PrintListDefault;
        PrintPathFuncs[ type ] = PrintPathList;
    }


    /* initialise filter table                                             */
    for ( type = FIRST_LIST_TNUM;  type <= LAST_LIST_TNUM;  type +=2 ) {
        ClearFiltsTNums   [ type            ] = 0;
        ClearFiltsTNums   [ type +IMMUTABLE ] = 0;
        for ( i = 0;  i <= LAST_FN;  i++ ) {
            SetFiltListTNums  [ type            ][i] = 0;
            SetFiltListTNums  [ type +IMMUTABLE ][i] = 0;
            ResetFiltListTNums[ type            ][i] = 0;
            ResetFiltListTNums[ type +IMMUTABLE ][i] = 0;
            HasFiltListTNums  [ type            ][i] = -1;
            HasFiltListTNums  [ type +IMMUTABLE ][i] = -1;
        }
    }

    return 0;
}


/****************************************************************************
**
*F  PostRestore( <module> ) . . . . . . . . . . . . . after restore workspace
*/
static Int PostRestore (
    StructInitInfo *    module )
{
    /* whats that?                                                         */
    TYPES_LIST_FAM_RNam = RNamName( "TYPES_LIST_FAM" );

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
    InitGVarAttrsFromTable( GVarAttrs );
    InitGVarPropsFromTable( GVarProps );
    InitGVarOpersFromTable( GVarOpers );
    InitGVarFuncsFromTable( GVarFuncs );

    /* make and install the 'POS_LIST' operation                           */
    SET_HDLR_FUNC( PosListOper, 2, PosListHandler2 );
    SET_HDLR_FUNC( PosListOper, 3, PosListHandler3 );

    return PostRestore( module );
}


/****************************************************************************
**
*F  CheckInit( <module> ) . . . . . . . . . . . . . . .  check initialisation
*/
static Int CheckInit (
    StructInitInfo *    module )
{
    Int         i;              /* loop variable                           */
    Int         j;              /* loop variable                           */
    Int         success = 1;

    Int         fnums[] = { FN_IS_DENSE, FN_IS_NDENSE,
                            FN_IS_HOMOG, FN_IS_NHOMOG,
                            FN_IS_TABLE,
                            FN_IS_SSORT, FN_IS_NSORT };
    const Char *fnams[] = { "dense", "ndense",
                            "homog", "nhomog",
                            "table",
                            "ssort", "nsort" };


    /* fix unknown list types                                              */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i +=2 ) {
        GAP_ASSERT( TNAM_TNUM(i) );
        GAP_ASSERT( TNAM_TNUM(i + IMMUTABLE) );
    }

    for (i = FIRST_LIST_TNUM; i <= LAST_LIST_TNUM; i += 2) {
        GAP_ASSERT(UnbListFuncs[i]);
        GAP_ASSERT(AssListFuncs[i]);
    }
    for (i = FIRST_LIST_TNUM; i <= LAST_LIST_TNUM; i++) {
        GAP_ASSERT(IsDenseListFuncs[i]);
        GAP_ASSERT(IsHomogListFuncs[i]);
        GAP_ASSERT(IsTableListFuncs[i]);
        GAP_ASSERT(IsSSortListFuncs[i]);
        GAP_ASSERT(IsPossListFuncs[i]);
        GAP_ASSERT(PosListFuncs[i]);
        GAP_ASSERT(IsSSortListFuncs[i]);
        GAP_ASSERT(IsSSortListFuncs[i]);
    }

    /* check that all relevant `ClearFiltListTNums' are installed          */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i++ ) {
        if ( ClearFiltsTNums[i] == 0 ) {
            Pr( "#W  ClearFiltsListTNums [%s] missing\n",
                    (Int)TNAM_TNUM(i), 0);
            success = 0;
        }
    }


    /* check that all relevant `HasFiltListTNums' are installed            */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i++ ) {
        for ( j = 0;  j < ARRAY_SIZE(fnums);  j++ ) {
            if ( HasFiltListTNums[i][fnums[j]] == -1 ) {
                Pr( "#W  HasFiltListTNums [%s] [%s] missing\n",
                    (Int)TNAM_TNUM(i), (Int)fnams[j] );
                success = 0;
                HasFiltListTNums[i][fnums[j]] = 0;
            }
        }
    }


    /* check that all relevant `SetFiltListTNums' are installed            */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i++ ) {
        for ( j = 0;  j < ARRAY_SIZE(fnums);  j++ ) {
            if ( SetFiltListTNums[i][fnums[j]] == 0 ) {
                Pr( "#W  SetFiltListTNums [%s] [%s] missing\n",
                    (Int)TNAM_TNUM(i), (Int)fnams[j] );
                success = 0;
            }
        }
    }


    /* check that all relevant `ResetFiltListTNums' are installed          */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i++ ) {
        for ( j = 0;  j < ARRAY_SIZE(fnums);  j++ ) {
            if ( ResetFiltListTNums[i][fnums[j]] == 0 ) {
                Pr( "#W  ResetFiltListTNums [%s] [%s] missing\n",
                    (Int)TNAM_TNUM(i), (Int)fnams[j] );
                success = 0;
            }
        }
    }

    /* if a tnum has a filter, reset must change the tnum                  */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i++ ) {
        for ( j = 0;  j < ARRAY_SIZE(fnums);  j++ ) {
            if ( HasFiltListTNums[i][fnums[j]] ) {
                Int     new;
                new = ResetFiltListTNums[i][fnums[j]];
                if ( new == i ) {
                    continue;   /* filter coded into the representation    */

                }
                else if ( new != -1 && HasFiltListTNums[new][fnums[j]] ) {
                    Pr(
                     "#W  ResetFiltListTNums [%s] [%s] failed to reset\n",
                     (Int)TNAM_TNUM(i), (Int)fnams[j] );
                    success = 0;
                }
            }
        }
    }

    /* if a tnum has a filter, set must not change the tnum                */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i++ ) {
        for ( j = 0;  j < ARRAY_SIZE(fnums);  j++ ) {
            if ( HasFiltListTNums[i][fnums[j]] ) {
                Int     new;
                new = SetFiltListTNums[i][fnums[j]];
                if ( new != -1 && new != i ) {
                    Pr(
                     "#W  SetFiltListTNums [%s] [%s] must not change\n",
                     (Int)TNAM_TNUM(i), (Int)fnams[j] );
                    success = 0;
                }
            }
        }
    }

    /* check implications                                                  */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i++ ) {

        if ( (i & IMMUTABLE) == 0 ) {
            if ( ClearFiltsTNums[i]+IMMUTABLE != ClearFiltsTNums[i+IMMUTABLE]) {
                Pr( "#W  ClearFiltsTNums [%s] mismatch between mutable and immutable\n",
                    (Int)TNAM_TNUM(i), 0 );
                success = 0;
            }
            for ( j = 0;  j < ARRAY_SIZE(fnums);  j++ ) {

                if ( HasFiltListTNums[i][fnums[j]] !=
                     HasFiltListTNums[i+IMMUTABLE][fnums[j]]) {
                    Pr( "#W  HasFiltListTNums [%s] [%s] mismatch between mutable and immutable\n",
                        (Int)TNAM_TNUM(i), (Int)fnams[j] );
                    success = 0;
                }

                if ( (SetFiltListTNums[i][fnums[j]] | IMMUTABLE) !=
                     SetFiltListTNums[i+IMMUTABLE][fnums[j]]) {
                    Pr( "#W  SetFiltListTNums [%s] [%s] mismatch between mutable and immutable\n",
                        (Int)TNAM_TNUM(i), (Int)fnams[j] );
                    success = 0;
                }

                if ( (ResetFiltListTNums[i][fnums[j]] | IMMUTABLE) !=
                     ResetFiltListTNums[i+IMMUTABLE][fnums[j]]) {
                    Pr( "#W  ResetFiltListTNums [%s] [%s] mismatch between mutable and immutable\n",
                        (Int)TNAM_TNUM(i), (Int)fnams[j] );
                    success = 0;
                }

            }
        }

        if ( i == T_PLIST_EMPTY || i == T_PLIST_EMPTY+IMMUTABLE ) {
            if ( ! HasFiltListTNums[i][FN_IS_DENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty -> dense ] missing\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_NDENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty + ndense ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
            if ( ! HasFiltListTNums[i][FN_IS_HOMOG] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty -> homog ] missing\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_NHOMOG] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty + nhomog ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
            if ( ! HasFiltListTNums[i][FN_IS_SSORT] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty -> ssort ] missing\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_NSORT] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty + nsort ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_TABLE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty + table ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_DENSE] ) {
            if ( HasFiltListTNums[i][FN_IS_NDENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ dense + ndense ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_NDENSE] ) {
            if ( HasFiltListTNums[i][FN_IS_HOMOG] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ ndense + homog ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_TABLE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ ndense + table ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_HOMOG] ) {
            if ( HasFiltListTNums[i][FN_IS_NHOMOG] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ homog + nhomog ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
            if ( ! HasFiltListTNums[i][FN_IS_DENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ homog -> dense ] missing\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_NDENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ homog + ndense ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_NHOMOG] ) {
            if ( HasFiltListTNums[i][FN_IS_TABLE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ nhomog + table ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_TABLE] ) {
            if ( ! HasFiltListTNums[i][FN_IS_HOMOG] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ table -> homog ] missing\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
            if ( ! HasFiltListTNums[i][FN_IS_DENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ table -> dense ] missing\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_SSORT] ) {
            if ( HasFiltListTNums[i][FN_IS_NSORT] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ ssort + nsort ] illegal\n",
                 (Int)TNAM_TNUM(i), 0);
                success = 0;
            }
        }           
    }

    return ! success;
}


/****************************************************************************
**
*F  InitInfoLists() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "lists",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
    .checkInit = CheckInit,
    .postRestore = PostRestore
};

StructInitInfo * InitInfoLists ( void )
{
    return &module;
}
