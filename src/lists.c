/****************************************************************************
**
*W  lists.c                     GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions of the generic list package.
**
**  This package provides a uniform   interface to the functions that  access
**  lists and their elements  for the other packages  in the GAP kernel.  For
**  example, 'ExecFor' can loop over the elements  in a list using the macros
**  'LEN_LIST' and 'ELM_LIST' independently of the type of the list.
**
**  This package uses plain lists (of type 'T_PLIST') and  assumes that it is
**  possible to put values of any type into plain  lists.  It uses the macros
**  'LEN_PLIST', 'SET_LEN_PLIST',   'ELM_PLIST', and 'SET_ELM_PLIST' exported
**  by the plain list package to access and modify plain lists.
*/
#include <src/system.h>                 /* Ints, UInts */
#include <src/gapstate.h>


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */

#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */
#include <src/ariths.h>                 /* basic arithmetic */

#include <src/records.h>                /* generic records */

#include <src/lists.h>                  /* generic lists */

#include <src/bool.h>                   /* booleans */

#include <src/precord.h>                /* plain records */

#include <src/plist.h>                  /* plain lists */
#include <src/range.h>                  /* ranges */
#include <src/stringobj.h>              /* strings */
#include <src/gmpints.h>                /* integers */

#include <src/hpc/aobjects.h>           /* atomic objects */

#include <src/code.h>                   /* coder */
#include <src/hpc/thread.h>             /* threads */
#include <src/hpc/tls.h>                /* thread-local storage */

#include <src/gaputils.h>


/****************************************************************************
**
*F  IS_LIST(<obj>)  . . . . . . . . . . . . . . . . . . . is an object a list
*V  IsListFuncs[<type>] . . . . . . . . . . . . . . . . . table for list test
**
**  'IS_LIST' only calls the function pointed  to  by  'IsListFuncs[<type>]',
**  passing <obj> as argument.
**
**  'IS_LIST' is defined in the declaration part of this package as follows
**
#define IS_LIST(obj)    (*IsListFuncs[ TNUM_OBJ( (obj) ) ])( obj )
*/
Int             (*IsListFuncs [LAST_REAL_TNUM+1]) ( Obj obj );

Obj             IsListFilt;

Obj             FuncIS_LIST (
    Obj                 self,
    Obj                 obj )
{
    return (IS_LIST( obj ) ? True : False);
}

Int             IsListObject (
    Obj                 obj )
{
    return (DoFilter( IsListFilt, obj ) == True);
}


Obj Elm2List(Obj list, Obj pos1, Obj pos2) {
  Obj ixs = NEW_PLIST(T_PLIST,2);
  SET_ELM_PLIST(ixs,1,pos1);
  SET_ELM_PLIST(ixs,2,pos2);
  SET_LEN_PLIST(ixs,2);
  return ELMB_LIST(list, ixs);
}

void Ass2List(Obj list, Obj pos1, Obj pos2, Obj obj) {
  Obj ixs = NEW_PLIST(T_PLIST,2);
  SET_ELM_PLIST(ixs,1,pos1);
  SET_ELM_PLIST(ixs,2,pos2);
  SET_LEN_PLIST(ixs,2);
  ASSB_LIST(list, ixs, obj);
}

/****************************************************************************
**
*F  IS_SMALL_LIST(<obj>)  . . . . . . . . . . . . . . . . . . . is an object a list
*V  IsListFuncs[<type>] . . . . . . . . . . . . . . . . . table for list test
**
**  'IS_SMALL_LIST' only calls the function pointed  to  by  'IsListFuncs[<type>]',
**  passing <obj> as argument.
**
**  'IS_SMALL_LIST' is defined in the declaration part of this package as follows
**
**  This is, in some sense, a workaround for the not yet implemented features
**  below (see LENGTH).
** 
#define IS_SMALL_LIST(obj)    (*IsSmallListFuncs[ TNUM_OBJ( (obj) ) ])( obj )
*/
Int             (*IsSmallListFuncs [LAST_REAL_TNUM+1]) ( Obj obj );

Obj             IsSmallListFilt;
Obj             HasIsSmallListFilt;
Obj             LengthAttr;
Obj             SetIsSmallList;

Int             IsSmallListObject (
    Obj                 obj )
{
  Obj len;
  if (DoFilter(IsListFilt, obj) != True)
    return 0;
  if (DoFilter(HasIsSmallListFilt, obj) == True)
    return DoFilter(IsSmallListFilt, obj) == True;
  if (DoTestAttribute(LengthAttr, obj) == True)
    {
      len = DoAttribute(LengthAttr, obj);
      if (IS_INTOBJ(len))
        {
          CALL_2ARGS(SetIsSmallList, obj, True);
          return 1;
        }
      else
        {
          CALL_2ARGS(SetIsSmallList, obj, False);
          return 0;
        }
    }
  return 0;
}



/****************************************************************************
**
*F  FuncLENGTH( <self>, <list> ) . . . . . . . . . . .  'Length' interface
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
**  - the for/list assignment has to be carefull to catch the special case of
**    a range constructor with small integer bounds
**
**  - the list access/assigment is a binary operation (NOT YET IMPLEMENTED)
**
**  - the conversion/test functions are split into three different functions
**    (NOT YET IMPLEMENTED)
**
**  - 'ResetFilterObj' and 'SetFilterObj'  are implemented using a table  for
**    internal types (NOT YET IMPLEMENTED)
*/

Obj FuncLENGTH (
    Obj             self,
    Obj             list )
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
**  'LEN_LIST' is defined in the declaration part of this package as follows
**
#define LEN_LIST(list)  ((*LenListFuncs[ TNUM_OBJ((list)) ])( (list) ))
**
**  At the  moment  this also handles external    types but this   is a hack,
**  because external  lists can have large  length or even  be infinite.  See
**  'FuncLENGTH'.
*/
Int (*LenListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj FuncLEN_LIST (
    Obj                 self,
    Obj                 list )
{
    /* special case for plain lists (avoid conversion back and forth)      */
    if ( IS_PLIST(list) ) {
        return INTOBJ_INT( LEN_PLIST( list ) );
    }

    /* generic case (will signal an error if <list> is not a list)         */
    else {
        return FuncLENGTH( LengthAttr, list );
    }
}


Int LenListError (
    Obj                 list )
{
    list = ErrorReturnObj(
        "Length: <list> must be a list (not a %s)",
        (Int)TNAM_OBJ(list), 0L,
        "you can replace <list> via 'return <list>;'" );
    return LEN_LIST( list );
}


Int LenListObject (
    Obj                 obj )
{
    Obj                 len;

    len = FuncLENGTH( LengthAttr, obj );
    while ( !IS_INTOBJ(len) || INT_INTOBJ(len) < 0 ) {
        len = ErrorReturnObj(
            "Length: method must return a nonnegative value (not a %s)",
            (Int)TNAM_OBJ(len), 0L,
            "you can replace value <length> via 'return <length>;'" );
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
**  Note that  'LENGTH' is a  macro, so do  not call it with arguments that
**  have side effects.
**
**  A package  implementing a list type <type>  must  provide such a function
**  and install it in 'LengthFuncs[<type>]'.

#define LENGTH(list)  ((*LengthFuncs[ TNUM_OBJ(list) ])( list )) 
*/

Obj             (*LengthFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj LengthError (
    Obj                 list )
{
    list = ErrorReturnObj(
        "Length: <list> must be a list (not a %s)",
        (Int)TNAM_OBJ(list), 0L,
        "you can replace <list> via 'return <list>;'" );
    return LENGTH( list );
}


Obj LengthObject (
    Obj                 obj )
{
    return FuncLENGTH( LengthAttr, obj );
}

Obj LengthInternal (
    Obj                 obj )
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
**
**  'ISB_LIST' is defined in  the declaration  part of this
**  package as follows
**
#define ISB_LIST(list,pos) \
                        ((*IsbListFuncs[TNUM_OBJ(list)])(list,pos))
*/
Int             (*IsbListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

Obj             IsbListOper;

Obj             FuncISB_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    if (IS_POS_INTOBJ(pos))
        return ISB_LIST( list, INT_INTOBJ(pos) ) ? True : False;
    else
        return ISBB_LIST( list, pos ) ? True : False;
}

Int             IsbListError (
    Obj                 list,
    Int                 pos )
{
    list = ErrorReturnObj(
        "IsBound: <list> must be a list (not a %s)",
        (Int)TNAM_OBJ(list), 0L,
        "you can replace <list> via 'return <list>;'" );
    return ISB_LIST( list, pos );
}

Int             IsbListObject (
    Obj                 list,
    Int                 pos )
{
    return DoOperation2Args( IsbListOper, list, INTOBJ_INT(pos) ) == True;
}

Int             ISBB_LIST (
    Obj                 list,
    Obj                 pos )
{
    return DoOperation2Args( IsbListOper, list, pos ) == True;
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
Obj Elm0ListError (
    Obj                 list,
    Int                 pos )
{
    list = ErrorReturnObj(
        "List Element: <list> must be a list (not a %s)",
        (Int)TNAM_OBJ(list), 0L,
        "you can replace <list> via 'return <list>;'" );
    return ELM0_LIST( list, pos );
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
**
**  Note that the method   returns `Fail' if there  is  no entry  at position
**  <pos>, in this case `Elm0ListObject' must  check if the position is bound
**  and `Fail'  means that there realy is  the object `Fail' at this position
**  or if it is unbound in which case 0 is returned.
*/
Obj Elm0ListOper;

Obj Elm0ListObject (
    Obj                 list,
    Int                 pos )
{
    Obj                 elm;

    elm = DoOperation2Args( Elm0ListOper, list, INTOBJ_INT(pos) );

    if ( elm == Fail ) {
        if ( DoOperation2Args(IsbListOper,list,INTOBJ_INT(pos)) == True )
            return Fail;
        else
            return 0;
    } else {
        return elm;
    }
}


/****************************************************************************
**
*F  FuncELM0_LIST( <self>, <list>, <pos> )  . . . . . . operation `ELM0_LIST'
*/
Obj FuncELM0_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    Obj                 elm;
    elm = ELM0_LIST( list, INT_INTOBJ(pos) );
    if ( elm == 0 ) {
        return Fail;
    }
    else {
        return elm;
    }
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
Obj ElmListError (
    Obj                 list,
    Int                 pos )
{
    list = ErrorReturnObj(
        "List Element: <list> must be a list (not a %s)",
        (Int)TNAM_OBJ(list), 0L,
        "you can replace <list> via 'return <list>;'" );
    return ELM_LIST( list, pos );
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
Obj ElmListOper;

Obj ElmListObject (
    Obj                 list,
    Int                 pos )
{
    Obj                 elm;

    elm = DoOperation2Args( ElmListOper, list, INTOBJ_INT(pos) );
    while ( elm == 0 ) {
        elm = ErrorReturnObj(
            "List access method must return a value", 0L, 0L,
            "you can supply a value <val> via 'return <val>;'" );
    }
    return elm;
}


Obj ELMB_LIST(Obj list, Obj pos)     {
   Obj                 elm;

    elm = DoOperation2Args( ElmListOper, list, pos );
    while ( elm == 0 ) {
        elm = ErrorReturnObj(
            "List access method must return a value", 0L, 0L,
            "you can supply a value <val> via 'return <val>;'" );
    }
    return elm;
}


/****************************************************************************
**
*F  FuncELM_LIST( <self>, <list>, <pos> ) . . . . . . .  operation `ELM_LIST'
*/
Obj FuncELM_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
  if (IS_INTOBJ(pos))
    return ELM_LIST( list, INT_INTOBJ(pos) );
  else
    return ELMB_LIST(list, pos );
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
Obj ElmsListError (
    Obj                 list,
    Obj                 poss )
{
    list = ErrorReturnObj(
        "List Elements: <list> must be a list (not a %s)",
        (Int)TNAM_OBJ(list), 0L,
        "you can replace <list> via 'return <list>;'" );
    return ELMS_LIST( list, poss );
}


/****************************************************************************
**
*F  ElmsListObject( <list>, <pos> ) . . . . . . . select elements from a list
**
**  `ElmsListObject' is the `ELMS_LIST' function for objects.
*/
Obj ElmsListOper;

Obj ElmsListObject (
    Obj                 list,
    Obj                 poss )
{
    Obj                 elm;

    elm = DoOperation2Args( ElmsListOper, list, poss );
    while ( elm == 0 ) {
        elm = ErrorReturnObj(
            "List multi-access method must return a value", 0L, 0L,
            "you can supply a value <val> via 'return <val>;'");
    }
    return elm;
}


/****************************************************************************
**
*F  FuncELMS_LIST( <self>, <list>, <poss> ) . . . . . . `ELMS_LIST' operation
*/
Obj FuncELMS_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 poss )
{
    return ELMS_LIST( list, poss );
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
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element from <list>         */
    Int                 lenPoss;        /* length of <positions>           */
    Int                 pos;            /* <position> as integer           */
    Int                 inc;            /* increment in a range            */
    Int                 i;              /* loop variable                   */
    Obj                 p;

    /* general code                                                        */
    if ( ! IS_RANGE(poss) ) {

        /* get the length of <list>                                        */
        lenList = LEN_LIST( list );

        /* get the length of <positions>                                   */
        /* OK because all positions lists are small                        */
        lenPoss = LEN_LIST( poss );

        /* make the result list                                            */
        elms = NEW_PLIST( T_PLIST, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
          p = ELMW_LIST( poss, i);
          while (!IS_INTOBJ(p))
            {
              p = ErrorReturnObj("List Elements: position is too large for this type of list",
                                 0L, 0L, 
                                 "you can supply a new position <pos> via 'return <pos>;'" );
            }
            pos = INT_INTOBJ( p );

            /* select the element                                          */
            elm = ELM0_LIST( list, pos );
            if ( elm == 0 ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can 'return;' after assigning a value" );
                return ELMS_LIST( list, poss );
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
        lenList = LEN_LIST( list );

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
                (Int)pos + (lenPoss-1) * inc, 0L,
                "you can 'return;' after assigning a value" );
            return ELMS_LIST( list, poss );
        }

        /* make the result list                                            */
        elms = NEW_PLIST( T_PLIST, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {

            /* select the element                                          */
            elm = ELMV0_LIST( list, pos );
            if ( elm == 0 ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can 'return;' after assigning a value" );
                return ELMS_LIST( list, poss );
            }

            /* assign the element to <elms>                                */
            SET_ELM_PLIST( elms, i, elm );

            /* notify Gasman                                               */
            CHANGED_BAG( elms );

        }

    }

    /* return the result                                                   */
    return elms;
}


/****************************************************************************
**
*F  FuncELMS_LIST_DEFAULT( <self>, <list>, <poss> ) . . . . `ElmsListDefault'
*/
Obj FuncELMS_LIST_DEFAULT (
    Obj                 self,
    Obj                 list,
    Obj                 poss )
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
    if ( ! IS_POSS_LIST(poss) ) {
        ErrorQuit(
      "List Elements: <positions> must be a dense list of positive integers",
            0L, 0L );
    }
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
    if ( ! IS_POSS_LIST(poss) ) {
        ErrorQuit(
      "List Elements: <positions> must be a dense list of positive integers",
            0L, 0L );
    }
    ElmsListLevel( lists, poss, level );
}


/****************************************************************************
**
*F  UNB_LIST(<list>,<pos>)  . . . . . . . . . . .  unbind element from a list
*V  UnbListFuncs[<type>]  . . . . . . . . . . . . . table of unbind functions
*F  UnbListError(<list>,<pos>)  . . . . . . . . . . . . error unbind function
**
#define UNB_LIST(list,pos) \
                        ((*UnbListFuncs[TNUM_OBJ(list)])(list,pos))
*/
void             (*UnbListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

Obj             UnbListOper;

Obj             FuncUNB_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    if (IS_POS_INTOBJ(pos))
        UNB_LIST( list, INT_INTOBJ(pos) );
    else
        UNBB_LIST( list, pos );
    return 0;
}

void            UnbListError (
    Obj                 list,
    Int                 pos )
{
    list = ErrorReturnObj(
        "Unbind: <list> must be a list (not a %s)",
        (Int)TNAM_OBJ(list), 0L,
        "you can replace <list> via 'return <list>;'" );
    UNB_LIST( list, pos );
}

void            UnbListDefault (
    Obj                 list,
    Int                 pos )
{
    PLAIN_LIST( list );
    UNB_LIST( list, pos );
}

void            UnbListObject (
    Obj                 list,
    Int                 pos )
{
    DoOperation2Args( UnbListOper, list, INTOBJ_INT(pos) );
}

void            UNBB_LIST (
    Obj                 list,
    Obj                 pos )
{
    DoOperation2Args( UnbListOper, list, pos );
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
**  'ASS_LIST' is defined in the declaration part of this package as follows.
**
#define ASS_LIST(list,pos,obj) \
                        ((*AssListFuncs[TNUM_OBJ(list)])(list,pos,obj))
*/
void            (*AssListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos, Obj obj );

Obj AssListOper;

Obj             FuncASS_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 pos,
    Obj                 obj )
{
    if (IS_INTOBJ(pos)) 
        ASS_LIST( list, INT_INTOBJ(pos), obj );
    else
        ASSB_LIST(list, pos, obj);
    return 0;
}

void            AssListError (
    Obj                 list,
    Int                 pos,
    Obj                 obj )
{
    list = ErrorReturnObj(
        "List Assignment: <list> must be a list (not a %s)",
        (Int)TNAM_OBJ(list), 0L,
        "you can replace <list> via 'return <list>;'" );
    ASS_LIST( list, pos, obj );
}

void            AssListDefault (
    Obj                 list,
    Int                 pos,
    Obj                 obj )
{
    PLAIN_LIST( list );
    ASS_LIST( list, pos, obj );
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
**
**  'ASSS_LIST'  is  defined in the  declaration  part  of  this  package  as
**  follows
**
#define ASSS_LIST(list,poss,objs) \
                        ((*AsssListFuncs[TNUM_OBJ(list)])(list,poss,objs))
*/
void            (*AsssListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Obj poss, Obj objs );

Obj             AsssListOper;

Obj             FuncASSS_LIST (
    Obj                 self,
    Obj                 list,
    Obj                 poss,
    Obj                 objs )
{
    ASSS_LIST( list, poss, objs );
    return 0;
}

void            AsssListError (
    Obj                 list,
    Obj                 poss,
    Obj                 objs )
{
    list = ErrorReturnObj(
        "List Assignments: <list> must be a list (not a %s)",
        (Int)TNAM_OBJ(list), 0L,
        "you can replace <list> via 'return <list>;'" );
    ASSS_LIST( list, poss, objs );
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

void            AsssListObject (
    Obj                 list,
    Obj                 poss,
    Obj                 objs )
{
    DoOperation3Args( AsssListOper, list, poss, objs );
}

Obj FuncASSS_LIST_DEFAULT (
    Obj                 self,
    Obj                 list,
    Obj                 poss,
    Obj                 objs )
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
**
**  'IS_DENSE_LIST'  is defined in the declaration  part  of this  package as
**  follows
**
#define IS_DENSE_LIST(list) \
                        ((*IsDenseListFuncs[TNUM_OBJ(list)])(list))
*/
Int             (*IsDenseListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj             IsDenseListFilt;

Obj             FuncIS_DENSE_LIST (
    Obj                 self,
    Obj                 obj )
{
    return (IS_DENSE_LIST( obj ) ? True : False);
}

Int             IsDenseListDefault (
    Obj                 list )
{
    Int                 lenList;        /* length of <list>                */
    Int                 i;              /* loop variable                   */

    /* get the length of the list                                          */
    lenList = LEN_LIST( list );

    /* special case for the empty list                                     */
    if ( lenList == 0 ) {
        return 1L;
    }

    /* loop over the entries of the list                                   */
    for ( i = 1; i <= lenList; i++ ) {
        if ( ! ISB_LIST( list, i ) ) {
            return 0L;
        }
    }

    /* the list is dense                                                   */
    return 1L;
}

Int             IsDenseListObject (
    Obj                 obj )
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
**  'IS_HOMOG_LIST' is defined in the declaration part  of  this  package  as
**  follows
**
#define IS_HOMOG_LIST(list) \
                        ((*IsHomogListFuncs[TNUM_OBJ(list)])(list))
*/
Int             (*IsHomogListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj             IsHomogListFilt;

Obj             FuncIS_HOMOG_LIST (
    Obj                 self,
    Obj                 obj )
{
    return (IS_HOMOG_LIST( obj ) ? True : False);
}

Int             IsHomogListDefault (
    Obj                 list )
{
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Obj                 fam;            /* family of elements of <list>    */
    Int                 i;              /* loop variable                   */

    /* get the length of the list                                          */
    lenList = LEN_LIST( list );

    /* special case for the empty list                                     */
    if ( lenList == 0 ) {
        return 0L;
    }

    /* get the family                                                      */
    elm = ELMV0_LIST( list, 1 );
    if ( elm == 0 ) {
        return 0L;
    }
    fam = FAMILY_TYPE( TYPE_OBJ( elm ) );

    /* loop over the entries of the list                                   */
    for ( i = 2; i <= lenList; i++ ) {
        elm = ELMV0_LIST( list, i );
        if ( elm == 0 || fam != FAMILY_TYPE( TYPE_OBJ( elm ) ) ) {
            return 0L;
        }
    }

    /* the list is homogeneous                                             */
    return 1L;
}

Int             IsHomogListObject (
    Obj                 obj )
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
**
**  'IS_TABLE_LIST' is defined in the declaration part  of  this  package  as
**  follows
**
#define IS_TABLE_LIST(list) \
                        ((*IsTableListFuncs[TNUM_OBJ(list)])(list))
*/
Int             (*IsTableListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj             IsTableListFilt;

Obj             FuncIS_TABLE_LIST (
    Obj                 self,
    Obj                 obj )
{
    return (IS_TABLE_LIST( obj ) ? True : False);
}

Int             IsTableListDefault (
    Obj                 list )
{
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Obj                 fam;            /* family of elements of <list>    */
/*  Int                 len;            / length of elements              */
    Int                 i;              /* loop variable                   */

    /* get the length of the list                                          */
    lenList = LEN_LIST( list );

    /* special case for the empty list                                     */
    if ( lenList == 0 ) {
        return 0L;
    }

    /* get the family                                                      */
    elm = ELMV0_LIST( list, 1 );
    if ( elm == 0 ) {
        return 0L;
    }
    if ( ! IS_HOMOG_LIST( elm ) ) {
        return 0L;
    }
    fam = FAMILY_TYPE( TYPE_OBJ( elm ) );
    /*     len = LEN_LIST( elm ); */

    /* loop over the entries of the list                                   */
    for ( i = 2; i <= lenList; i++ ) {
        elm = ELMV0_LIST( list, i );
        if ( elm == 0 || fam != FAMILY_TYPE( TYPE_OBJ( elm ) ) ) {
            return 0L;
        }
        /*        if ( ! IS_LIST( elm ) || LEN_LIST( elm ) != len ) {
            return 0L;
            } */
    }

    /* the list is equal length                                            */
    return 1L;
}

Int             IsTableListObject (
    Obj                 obj )
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
**  'IS_SSORTED_LIST'  is defined in the  declaration part of this package as
**  follows
**
#define IS_SSORTED_LIST(list) \
                        ((*IsSSortListFuncs[TNUM_OBJ(list)])(list))
*/
Int (*IsSSortListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj IsSSortListProp;

Obj FuncIS_SSORT_LIST (
    Obj                 self,
    Obj                 obj )
{
    return (IS_SSORT_LIST( obj ) ? True : False);
}

Int IsSSortListDefault (
    Obj                 list )
{
    Int                 lenList;
    Obj                 elm1;
    Obj                 elm2;
    Int                 i;

    /* get the length of the list                                          */
    lenList = LEN_LIST( list );

    /* special case for the empty list                                     */
    if ( lenList == 0 ) {
        return 2L;
    }

    /* a list must be homogeneous to be strictly sorted                    */
    if ( ! IS_HOMOG_LIST(list) ) {
        return 0L;
    }

    /* get the first element                                               */
    elm1 = ELMW_LIST( list, 1 );

    /* compare each element with its precursor                             */
    for ( i = 2; i <= lenList; i++ ) {
        elm2 = ELMW_LIST( list, i );
        if ( ! LT( elm1, elm2 ) ) {
            return 0L;
        }
        elm1 = elm2;
    }

    /* the list is strictly sorted                                         */
    return 2L;
}

Int             IsSSortListObject (
    Obj                 obj )
{
    return (DoProperty( IsSSortListProp, obj ) == True);
}

Obj FuncIS_SSORT_LIST_DEFAULT (
    Obj                 self,
    Obj                 obj )
{
    return (IsSSortListDefault( obj ) ? True : False);
}


/****************************************************************************
**
*F  IsNSortListProp( <list> ) . . . . . . . . . . . . list which are unsorted
**
*/
Obj IsNSortListProp;

Obj FuncIS_NSORT_LIST (
    Obj                 self,
    Obj                 obj )
{
    ErrorQuit( "not ready yet", 0L, 0L );
    return (Obj)0L;
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
**
**  'IS_POSS_LIST' is  defined  in the  declaration  part of this  package as
**  follows
**
#define IS_POSS_LIST(list) \
                        ((*IsPossListFuncs[TNUM_OBJ(list)])(list))
*/
Int             (*IsPossListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj             IsPossListProp;

Obj             FuncIS_POSS_LIST (
    Obj                 self,
    Obj                 obj )
{
    return (IS_POSS_LIST(obj) ? True : False);
}

Int             IsPossListDefault (
    Obj                 list )
{
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Int                 i;              /* loop variable                   */

    /* get the length of the variable                                      */
    lenList = LEN_LIST( list );

    /* loop over the entries of the list                                   */
    for ( i = 1; i <= lenList; i++ ) {
        elm = ELMV0_LIST( list, i );

        /* if it's a hole then its not a poss list */
        if ( elm == 0)
          return 0L;

        /* if it's a small integer and non-positive then
           it's not a poss list */
        if ( IS_INTOBJ(elm)) {
          if (INT_INTOBJ(elm) <= 0)
            return  0L;
        }
        /* or if it's not a small integer or a positive large integer then it's
           not a poss list */
        else if (TNUM_OBJ(elm) != T_INTPOS)
          return 0L;
    }

    /* the list is a positions list                                        */
    return 1L;
}

Int             IsPossListObject (
    Obj                 obj )
{
    return (DoProperty( IsPossListProp, obj ) == True);
}

Obj FuncIS_POSS_LIST_DEFAULT (
    Obj                 self,
    Obj                 obj )
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
**
**  'POS_LIST' is defined in the declaration part of this package as follows
**
#define POS_LIST(list,obj,start) \
                        ((*PosListFuncs[TNUM_OBJ(list)])(list,obj,start))
*/
Obj             (*PosListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Obj obj, Obj start );

Obj             PosListOper;

Obj             PosListHandler2 (
    Obj                 self,
    Obj                 list,
    Obj                 obj )
{
    return POS_LIST( list, obj, INTOBJ_INT(0) );
}

Obj             PosListHandler3 (
    Obj                 self,
    Obj                 list,
    Obj                 obj,
    Obj                 start )
{
    while ( TNUM_OBJ(start) != T_INTPOS &&
            (! IS_INTOBJ(start) || INT_INTOBJ(start) < 0) ) {
        start = ErrorReturnObj(
            "Position: <start> must be a nonnegative integer (not a %s)",
            (Int)TNAM_OBJ(start), 0L,
            "you can replace <start> via 'return <start>;'" );
    }
    return POS_LIST( list, obj, start );
}

Obj             PosListError (
    Obj                 list,
    Obj                 obj,
    Obj                 start )
{
    list = ErrorReturnObj(
        "Position: <list> must be a list (not a %s)",
        (Int)TNAM_OBJ(list), 0L,
        "you can replace <list> via 'return <list>;'" );
    return POS_LIST( list, obj, start );
}

Obj             PosListDefault (
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

Obj             PosListObject (
    Obj                 list,
    Obj                 obj,
    Obj                 start )
{
    return DoOperation3Args( PosListOper, list, obj, start );
}

Obj FuncPOS_LIST_DEFAULT (
    Obj                 self,
    Obj                 list,
    Obj                 obj,
    Obj                 start )
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
    Obj pos;
    Obj pos1;
    Obj pos2;
      

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
              pos1 = ELM_PLIST(ixs,1);
              pos2 = ELM_PLIST(ixs,2);
              elm = ELM2_LIST(list, pos1, pos2);
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

    /* Workaround for issue #312: Accessing a two-level sublist
       of a compressed FFE vector could lead to crashes because
       FuncELMS_VEC8BIT and FuncELMS_GF2VEC may return lists which are
       not plists. This boils down to a conflict between the documented
       behavior and requirements of ElmsListLevel and ElmsListFuncs.
       Resolving this properly requires some more discussion. But until
       then, this change at least prevents hard crashes. */
    if (!IS_PLIST(lists)) {
        ErrorMayQuit(
            "List Elements: <lists> must be a list (not a %s)",
            (Int)TNAM_OBJ(lists), 0L );
    }

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
    Obj pos,pos1,pos2;

    /* check <objs>                                                        */
    while ( ! IS_DENSE_LIST(objs) || LEN_LIST(lists) != LEN_LIST(objs) ) {
        if ( ! IS_DENSE_LIST(objs) ) {
            objs = ErrorReturnObj(
                "List Assignment: <objs> must be a dense list (not a %s)",
                (Int)TNAM_OBJ(objs), 0L,
                "you can replace <objs> via 'return <objs>;'" );
        }
        if ( LEN_LIST(lists) != LEN_LIST(objs) ) {
            objs = ErrorReturnObj(
         "List Assignment: <objs> must have the same length as <lists> (%d)",
                LEN_LIST(lists), 0L,
                "you can replace <objs> via 'return <objs>;'" );
        }
    }

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
              pos1 = ELM_PLIST(ixs,1);
              pos2 = ELM_PLIST(ixs,2);
              ASS2_LIST(list, pos1, pos2, obj);
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

    /* check <objs>                                                        */
    while ( ! IS_DENSE_LIST(objs) || LEN_LIST(lists) != LEN_LIST(objs) ) {
        if ( ! IS_DENSE_LIST(objs) ) {
            objs = ErrorReturnObj(
                "List Assignment: <objs> must be a dense list (not a %s)",
                (Int)TNAM_OBJ(objs), 0L,
                "you can replace <objs> via 'return <objs>;'" );
        }
        if ( LEN_LIST(lists) != LEN_LIST(objs) ) {
            objs = ErrorReturnObj(
         "List Assignment: <objs> must have the same length as <lists> (%d)",
                LEN_LIST(lists), 0L,
                "you can replace <objs> via 'return <objs>;'" );
        }
    }

    /* if <lev> is one, loop over all the lists and assign the value       */
    if ( lev == 1 ) {

        /* loop over the list entries (which must be lists too)            */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* select the elements to assign                               */
            obj = ELMW_LIST( objs, i );
            while ( ! IS_DENSE_LIST( obj )
                 || LEN_LIST( poss ) != LEN_LIST( obj ) ) {
                if ( ! IS_DENSE_LIST( obj ) ) {
                    obj = ErrorReturnObj(
                  "List Assignments: <objs> must be a dense list (not a %s)",
                        (Int)TNAM_OBJ(obj), 0L,
                        "you can replace <objs> via 'return <objs>;'" );
                }
                if ( LEN_LIST( poss ) != LEN_LIST( obj ) ) {
                    obj = ErrorReturnObj(
     "List Assignments: <objs> must have the same length as <positions> (%d)",
                        LEN_LIST( poss ), 0L,
                        "you can replace <objs> via 'return <objs>;'" );
                }
            }

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
**
**  'PLAIN_LIST'  is defined in  the  declaration  part  of  this  package as
**  follows
**
#define PLAIN_LIST(list) \
                        ((*PlainListFuncs[TNUM_OBJ(list)])(list))
*/
void            (*PlainListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

void            PlainListError (
    Obj                 list )
{
    ErrorQuit(
        "Panic: cannot convert <list> (is a %s) to a plain list",
        (Int)TNAM_OBJ(list), 0L );
}


/****************************************************************************
**
*F  TYPES_LIST_FAM(<fam>) . . . . . . .  list of types of lists over a family
*/
UInt            TYPES_LIST_FAM_RNam;

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
**  'PrintList' simply prints the list.
*/
void            PrintListDefault (
    Obj                 list )
{
    Obj                 elm;

    if ( 0 < LEN_LIST(list) && IsStringConv(list) ) {
        PrintString(list);
        return;
    }

    Pr("%2>[ %2>",0L,0L);
    for ( STATE(PrintObjIndex)=1; STATE(PrintObjIndex)<=LEN_LIST(list); STATE(PrintObjIndex)++ ) {
        elm = ELMV0_LIST( list, STATE(PrintObjIndex) );
        if ( elm != 0 ) {
            if ( 1 < STATE(PrintObjIndex) )  Pr( "%<,%< %2>", 0L, 0L );
            PrintObj( elm );
        }
        else {
            if ( 1 < STATE(PrintObjIndex) )  Pr( "%2<,%2>", 0L, 0L );
        }
    }
    Pr(" %4<]",0L,0L);
}

void            PrintPathList (
    Obj                 list,
    Int                 indx )
{
    Pr( "[%d]", indx, 0L );
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
*F  FuncSET_FILTER_LIST( <self>, <list>, <filter> ) . . . . . . .  set filter
*/
Obj FuncSET_FILTER_LIST (
    Obj             self,
    Obj             list,
    Obj             filter )
{
    Int             new;
    Obj             flags;

    if ( ! IS_OPERATION(filter) ) {
        ErrorQuit("<oper> must be an operation",0L,0L);
        return 0;
    }
    /* this could be done by a table lookup                                */
    flags = FLAGS_FILT(filter);
    if (FuncIS_SUBSET_FLAGS(0,flags,FLAGS_FILT(IsSSortListProp))==True) {
        new = SetFiltListTNums[TNUM_OBJ(list)][FN_IS_DENSE];
        if ( new < 0 )  goto error;
        new = SetFiltListTNums[TNUM_OBJ(list)][FN_IS_HOMOG];
        if ( new < 0 )  goto error;
        new = SetFiltListTNums[TNUM_OBJ(list)][FN_IS_SSORT];
        if ( new > 0 )  RetypeBag( list, new );  else goto error;
    }
    if (FuncIS_SUBSET_FLAGS(0,flags,FLAGS_FILT(IsNSortListProp))==True) {
        new = SetFiltListTNums[TNUM_OBJ(list)][FN_IS_NSORT];
        if ( new > 0 )  RetypeBag( list, new );  else goto error;
    }
    return 0;

    /* setting of filter failed                                            */
error:
    ErrorReturnVoid( "filter not possible for %s",
                     (Int)TNAM_OBJ(list), 0,
                     "you can 'return;'" );
    return 0;
}


/****************************************************************************
**
*F  FuncRESET_FILTER_LIST( <self>, <list>, <filter> ) . . . . .  reset filter
*/
Obj FuncRESET_FILTER_LIST (
    Obj             self,
    Obj             list,
    Obj             filter )
{
    Int             fn;
    Int             new;

    /* this could be done by a table lookup                                */
    if ( filter == IsSSortListProp ) {
        fn = FN_IS_SSORT;
    }
    else if ( filter == IsNSortListProp ) {
        fn = FN_IS_NSORT;
    }
    else {
        return 0;
    }

    /* try to set the filter                                               */
    new = ResetFiltListTNums[TNUM_OBJ(list)][fn];
    if ( new > 0 ) {
        RetypeBag( list, new );
    }
    else if ( new < 0 ) {
        ErrorReturnVoid( "filter not possible for %s",
                         (Int)TNAM_OBJ(list), 0,
                         "you can 'return;'" );
    }
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
    if ( ! IS_POSS_LIST(poss) ) {
        ErrorQuit(
    "List Assignment: <positions> must be a dense list of positive integers",
            0L, 0L );
    }
    if ( ! IS_DENSE_LIST(rhss) ) {
        ErrorQuit(
            "List Assignment: <rhss> must be a dense list",
            0L, 0L );
    }
    if ( LEN_LIST( poss ) != LEN_LIST( rhss ) ) {
        ErrorQuit(
     "List Assignment: <rhss> must have the same length as <positions> (%d)",
            (Int)LEN_LIST(poss), 0L );
    }
    ASSS_LIST( list, poss, rhss );
}


/****************************************************************************
**
*F  AsssPosObjCheck( <list>, <poss>, <rhss> ) . . . . . . . . . . . ASSS_LIST
*/
void AsssPosObjCheck (
    Obj                 list,
    Obj                 poss,
    Obj                 rhss )
{
    if ( ! IS_POSS_LIST(poss) ) {
        ErrorQuit(
    "List Assignment: <positions> must be a dense list of positive integers",
            0L, 0L );
    }
    if ( ! IS_DENSE_LIST(rhss) ) {
        ErrorQuit(
            "List Assignment: <rhss> must be a dense list",
            0L, 0L );
    }
    if ( LEN_LIST( poss ) != LEN_LIST( rhss ) ) {
        ErrorQuit(
     "List Assignment: <rhss> must have the same length as <positions> (%d)",
            (Int)LEN_LIST(poss), 0L );
    }
    if ( TNUM_OBJ(list) == T_POSOBJ ) {
        ErrorQuit( "sorry: <posobj>!{<poss>} not yet implemented", 0L, 0L );
    }
    else {
        ASSS_LIST( list, poss, rhss );
    }
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
    if ( ! IS_POSS_LIST(poss) ) {
        ErrorQuit(
    "List Assignment: <positions> must be a dense list of positive integers",
            0L, 0L );
    }
    AsssListLevel( lists, poss, rhss, level );
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILTER(IS_LIST, "obj", &IsListFilt),
    GVAR_FILTER(IS_DENSE_LIST, "obj", &IsDenseListFilt),
    GVAR_FILTER(IS_HOMOG_LIST, "obj", &IsHomogListFilt),
    GVAR_FILTER(IS_TABLE_LIST, "obj", &IsTableListFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarAttrs . . . . . . . . . . . . . . . . .  list of attributes to export
*/
static StructGVarAttr GVarAttrs [] = {

    GVAR_FILTER(LENGTH, "list", &LengthAttr),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarProps . . . . . . . . . . . . . . . . .  list of properties to export
*/
static StructGVarProp GVarProps [] = {

    GVAR_FILTER(IS_SSORT_LIST, "obj", &IsSSortListProp),
    GVAR_FILTER(IS_NSORT_LIST, "obj", &IsNSortListProp),
    GVAR_FILTER(IS_POSS_LIST, "obj", &IsPossListProp),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarOpers . . . . . . . . . . . . . . . . .  list of operations to export
*/
static StructGVarOper GVarOpers [] = {

    // FIXME: why DoOperation0Args below?
    { "POS_LIST", -1, "list, obj", &PosListOper,
      DoOperation0Args, "src/lists.c:POS_LIST" },

    GVAR_OPER(ISB_LIST, 2, "list, pos", &IsbListOper),
    GVAR_OPER(ELM0_LIST, 2, "list, pos", &Elm0ListOper),
    GVAR_OPER(ELM_LIST, 2, "list, pos", &ElmListOper),
    GVAR_OPER(ELMS_LIST, 2, "list, poss", &ElmsListOper),
    GVAR_OPER(UNB_LIST, 2, "list, pos", &UnbListOper),
    GVAR_OPER(ASS_LIST, 3, "list, pos, obj", &AssListOper),
    GVAR_OPER(ASSS_LIST, 3, "list, poss, objs", &AsssListOper),
    { 0, 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    GVAR_FUNC(LEN_LIST, 1, "list"),
    GVAR_FUNC(ELMS_LIST_DEFAULT, 2, "list, poss"),
    GVAR_FUNC(ASSS_LIST_DEFAULT, 3, "list, poss, objs"),
    GVAR_FUNC(IS_SSORT_LIST_DEFAULT, 1, "list"),
    GVAR_FUNC(IS_POSS_LIST_DEFAULT, 1, "list"),
    GVAR_FUNC(POS_LIST_DEFAULT, 3, "list, obj, start"),
    GVAR_FUNC(SET_FILTER_LIST, 2, "list, filter"),
    GVAR_FUNC(RESET_FILTER_LIST, 2, "list, filter"),
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
        UnbListFuncs[ type ] = UnbListDefault;
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
        AssListFuncs[ type ] = AssListDefault;
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
        IsDenseListFuncs[ type ] = IsDenseListDefault;
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
        IsHomogListFuncs[ type ] = IsHomogListDefault;
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
        IsTableListFuncs[ type ] = IsTableListDefault;
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
        IsSSortListFuncs[ type ] = IsSSortListDefault;
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
        IsPossListFuncs[ type ] = IsPossListDefault;
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
        PosListFuncs[ type ] = PosListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        PosListFuncs[ type ] = PosListObject;
    }


    /* install the error functions into the other tables                   */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        assert(PlainListFuncs [ type ] == 0);
        PlainListFuncs [ type ] = PlainListError;
    }


    /* install the generic mutability test function                        */
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type += 2 ) {
        IsMutableObjFuncs[  type           ] = AlwaysYes;
        IsMutableObjFuncs[  type+IMMUTABLE ] = AlwaysNo;
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

    /* return success                                                      */
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
    InitGVarAttrsFromTable( GVarAttrs );
    InitGVarPropsFromTable( GVarProps );
    InitGVarOpersFromTable( GVarOpers );
    InitGVarFuncsFromTable( GVarFuncs );

    /* make and install the 'POS_LIST' operation                           */
    SET_HDLR_FUNC( PosListOper, 2, PosListHandler2 );
    SET_HDLR_FUNC( PosListOper, 3, PosListHandler3 );

    /* return success                                                      */
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

    Int         fnums[] = { FN_IS_EMPTY, FN_IS_DENSE,
                            FN_IS_NDENSE, FN_IS_HOMOG, FN_IS_NHOMOG,
                            FN_IS_TABLE, FN_IS_SSORT, FN_IS_NSORT };
    const Char *fnams[] = { "empty", "dense", "ndense",
                            "homog", "nhomog", "table", "ssort",
                            "nsort" };


    /* fix unknown list types                                              */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i +=2 ) {
        if ( InfoBags[i].name == 0 ) {
            InfoBags[i].name = "unknown list type";
        }
        if ( InfoBags[i+IMMUTABLE].name == 0 ) {
            InfoBags[i+IMMUTABLE].name = "unknown immutable list type";
        }
    }

    /* check that all relevant `ClearFiltListTNums' are installed          */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i++ ) {
        if ( ClearFiltsTNums[i] == 0 ) {
            Pr( "#W  ClearFiltsListTNums [%s] missing\n",
                    (Int)(InfoBags[i].name), 0L );
            success = 0;
        }
    }


    /* check that all relevant `HasFiltListTNums' are installed            */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i++ ) {
        for ( j = 0;  j < ARRAY_SIZE(fnums);  j++ ) {
            if ( HasFiltListTNums[i][fnums[j]] == -1 ) {
                Pr( "#W  HasFiltListTNums [%s] [%s] missing\n",
                    (Int)(InfoBags[i].name), (Int)fnams[j] );
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
                    (Int)(InfoBags[i].name), (Int)fnams[j] );
                success = 0;
            }
        }
    }


    /* check that all relevant `ResetFiltListTNums' are installed          */
    for ( i = FIRST_LIST_TNUM;  i <= LAST_LIST_TNUM;  i++ ) {
        for ( j = 0;  j < ARRAY_SIZE(fnums);  j++ ) {
            if ( ResetFiltListTNums[i][fnums[j]] == 0 ) {
                Pr( "#W  ResetFiltListTNums [%s] [%s] missing\n",
                    (Int)(InfoBags[i].name), (Int)fnams[j] );
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
                     (Int)(InfoBags[i].name), (Int)fnams[j] );
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
                     (Int)(InfoBags[i].name), (Int)fnams[j] );
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
                    (Int)(InfoBags[i].name), 0 );
                success = 0;
            }
            for ( j = 0;  j < ARRAY_SIZE(fnums);  j++ ) {

                if ( HasFiltListTNums[i][fnums[j]] !=
                     HasFiltListTNums[i+IMMUTABLE][fnums[j]]) {
                    Pr( "#W  HasFiltListTNums [%s] [%s] mismatch between mutable and immutable\n",
                        (Int)(InfoBags[i].name), (Int)fnams[j] );
                    success = 0;
                }

                if ( (SetFiltListTNums[i][fnums[j]] | IMMUTABLE) !=
                     SetFiltListTNums[i+IMMUTABLE][fnums[j]]) {
                    Pr( "#W  SetFiltListTNums [%s] [%s] mismatch between mutable and immutable\n",
                        (Int)(InfoBags[i].name), (Int)fnams[j] );
                    success = 0;
                }

                if ( (ResetFiltListTNums[i][fnums[j]] | IMMUTABLE) !=
                     ResetFiltListTNums[i+IMMUTABLE][fnums[j]]) {
                    Pr( "#W  ResetFiltListTNums [%s] [%s] mismatch between mutable and immutable\n",
                        (Int)(InfoBags[i].name), (Int)fnams[j] );
                    success = 0;
                }

            }
        }

        if ( HasFiltListTNums[i][FN_IS_EMPTY] ) {
            if ( ! HasFiltListTNums[i][FN_IS_DENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty -> dense ] missing\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_NDENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty + ndense ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
            if ( ! HasFiltListTNums[i][FN_IS_HOMOG] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty -> homog ] missing\n",
                 (Int)(InfoBags[i].name), 0L );
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_NHOMOG] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty + nhomog ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
            if ( ! HasFiltListTNums[i][FN_IS_SSORT] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty -> ssort ] missing\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_NSORT] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty + nsort ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_TABLE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ empty + table ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_DENSE] ) {
            if ( HasFiltListTNums[i][FN_IS_NDENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ dense + ndense ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_NDENSE] ) {
            if ( HasFiltListTNums[i][FN_IS_HOMOG] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ ndense + homog ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_TABLE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ ndense + table ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_HOMOG] ) {
            if ( HasFiltListTNums[i][FN_IS_NHOMOG] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ homog + nhomog ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
            if ( ! HasFiltListTNums[i][FN_IS_DENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ homog -> dense ] missing\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
            if ( HasFiltListTNums[i][FN_IS_NDENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ homog + ndense ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_NHOMOG] ) {
            if ( HasFiltListTNums[i][FN_IS_TABLE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ nhomog + table ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_TABLE] ) {
            if ( ! HasFiltListTNums[i][FN_IS_HOMOG] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ table -> homog ] missing\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
            if ( ! HasFiltListTNums[i][FN_IS_DENSE] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ table -> dense ] missing\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
        }

        if ( HasFiltListTNums[i][FN_IS_SSORT] ) {
            if ( HasFiltListTNums[i][FN_IS_NSORT] ) {
                Pr(
                 "#W  HasFiltListTNums [%s] [ ssort + nsort ] illegal\n",
                 (Int)(InfoBags[i].name), 0L );   
                success = 0;
            }
        }           
    }

    /* return success                                                      */
    return ! success;
}


/****************************************************************************
**
*F  InitInfoLists() . . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "lists",                            /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    CheckInit,                          /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    PostRestore                         /* postRestore                    */
};

StructInitInfo * InitInfoLists ( void )
{
    return &module;
}
