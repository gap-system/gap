/****************************************************************************
**
*W  lists.c                     GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
char *          Revision_lists_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */

#include        "gasman.h"              /* NewBag, CHANGED_BAG             */
#include        "objects.h"             /* Obj, TNUM_OBJ, SIZE_OBJ, ...    */
#include        "scanner.h"             /* Pr                              */

#include        "gvars.h"               /* AssGVar, GVarName               */

#include        "calls.h"               /* ObjFunc                         */
#include        "opers.h"               /* NewFilter, NewOperation, ...    */
#include        "ariths.h"              /* EQ, LT                          */

#include        "records.h"             /* RNamName (for TYPES_LIST_FAM)   */

#define INCLUDE_DECLARATION_PART
#include        "lists.h"               /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "bool.h"                /* True, False                     */

#include        "precord.h"             /* ElmPRec (for TYPES_LIST_FAM)    */

#include        "plist.h"               /* LEN_PLIST, SET_LEN_PLIST,   ... */
#include        "range.h"               /* IS_RANGE, GET_LEN_RANGE, ...    */
#include        "string.h"              /* strings and characters          */

#include        "gap.h"                 /* Error                           */


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

Obj             IsListHandler (
    Obj                 self,
    Obj                 obj )
{
    return (IS_LIST( obj ) ? True : False);
}

Int             IsListNot (
    Obj                 obj )
{
    return 0L;
}

Int             IsListYes (
    Obj                 obj )
{
    return 1L;
}

Int             IsListObject (
    Obj                 obj )
{
    return (DoFilter( IsListFilt, obj ) == True);
}


/****************************************************************************
**
*F  LENGTHHandler( <self>, <list> ) . . . . . . . . . . .  'Length' interface
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
Obj LengthAttr;

Obj LENGTHHandler (
    Obj             self,
    Obj             list )
{
    /* internal list types                                                 */
    if ( FIRST_LIST_TNUM<=TNUM_OBJ(list) && TNUM_OBJ(list)<=LAST_LIST_TNUM) {
        return INTOBJ_INT( LEN_LIST(list) );
    }

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
**  'LENGTHHandler'.
*/
Int (*LenListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj LenListHandler (
    Obj                 self,
    Obj                 list )
{
    /* special case for plain lists (avoid conversion back and forth)      */
    if ( TNUM_OBJ(list) == T_PLIST ) {
        return INTOBJ_INT( LEN_PLIST( list ) );
    }

    /* generic case (will signal an error if <list> is not a list)         */
    else {
        return LENGTHHandler( LengthAttr, list );
    }
}


Int LenListError (
    Obj                 list )
{
    list = ErrorReturnObj(
        "Length: <list> must be a list (not a %s)",
        (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
        "you can return a list for <list>" );
    return LEN_LIST( list );
}


Int LenListObject (
    Obj                 obj )
{
    Obj                 len;

    len = LENGTHHandler( LengthAttr, obj );
    while ( TNUM_OBJ(len) != T_INT || INT_INTOBJ(len) < 0 ) {
        len = ErrorReturnObj(
            "Length: method must return a nonnegative value (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(len)].name), 0L,
            "you can return a nonnegative integer value for <length>" );
    }
    return INT_INTOBJ( len );
}


/****************************************************************************
**
*F  ISB_LIST(<list>,<pos>)  . . . . . . . . . .  test for element from a list
*F  ISBV_LIST(<list>,<pos>) . . . . . . . . . .  test for element from a list
*V  IsbListFuncs[<type>]  . . . . . . . . . . . . . . table of test functions
*V  IsbvListFuncs[<type>] . . . . . . . . . . . . . . table of test functions
**
**  'ISB_LIST' only calls the function pointed to by  'IsbListFuncs[<type>]',
**  passing <list> and <pos> as arguments.  If <type> is not the  type  of  a
**  list, then 'IsbListFuncs[<type>]' points to 'IsbListError', which signals
**  the error.
**
**  'ISB_LIST' and 'ISBV_LIST'  are defined in  the declaration  part of this
**  package as follows
**
#define ISB_LIST(list,pos) \
                        ((*IsbListFuncs[TNUM_OBJ(list)])(list,pos))

#define ISBV_LIST(list,pos) \
                        ((*IsbvListFuncs[TNUM_OBJ(list)])(list,pos))
*/
Int             (*IsbListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

Int             (*IsbvListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

Obj             IsbListOper;

Obj             IsbListHandler (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    return (ISB_LIST( list, INT_INTOBJ(pos) ) ? True : False);
}

Int             IsbListError (
    Obj                 list,
    Int                 pos )
{
    list = ErrorReturnObj(
        "IsBound: <list> must be a list (not a %s)",
        (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
        "you can return a list for <list>" );
    return ISB_LIST( list, pos );
}

Int             IsbListObject (
    Obj                 list,
    Int                 pos )
{
    return (DoOperation2Args( IsbListOper, list, INTOBJ_INT(pos) ) == True);
}


/****************************************************************************
**
*F  ELM0_LIST(<list>,<pos>) . . . . . . . . . . select an element from a list
*F  ELMV0_LIST(<list>,<pos>)  . . . . . . . . . select an element from a list
*V  Elm0ListFuncs[<type>] . . . . . . . . . . .  table of selection functions
*V  Elmv0ListFuncs[<type>]  . . . . . . . . . .  table of selection functions
**
**  'ELM0_LIST'         only  calls    the     functions     pointed   to  by
**  'Elm0ListFuncs[<type>]' passing <list> and <pos> as arguments.  If <type>
**  is  not the  type of   a   list, then 'Elm0ListFuncs[<type>]'  points  to
**  'Elm0ListError', which signals the error.
**
**  'ELM0_LIST' and 'ELMV0_LIST' are defined in the  declaration part of this
**  package as follows
**
#define ELM0_LIST(list,pos) \
                        ((*Elm0ListFuncs[TNUM_OBJ(list)])(list,pos))

#define ELMV0_LIST(list,pos) \
                        ((*Elm0vListFuncs[TNUM_OBJ(list)])(list,pos))
*/
Obj             (*Elm0ListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

Obj             (*Elm0vListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

Obj             Elm0ListOper;

Obj             Elm0ListHandler (
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

Obj             Elm0ListError (
    Obj                 list,
    Int                 pos )
{
    list = ErrorReturnObj(
        "List Element: <list> must be a list (not a %s)",
        (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
        "you can return a list for <list>" );
    return ELM0_LIST( list, pos );
}

Obj             Elm0ListObject (
    Obj                 list,
    Int                 pos )
{
    Obj                 elm;
    elm = DoOperation2Args( Elm0ListOper, list, INTOBJ_INT(pos) );
    if ( elm == Fail ) {
        return 0;
    }
    else {
        return elm;
    }
}


/****************************************************************************
**
*F  ELM_LIST(<list>,<pos>)  . . . . . . . . . . select an element from a list
*F  ELMV_LIST(<list>,<pos>) . . . . . . . . . . select an element from a list
*F  ELMW_LIST(<list>,<pos>) . . . . . . . . . . select an element from a list
*V  ElmListFuncs[<type>]  . . . . . . . . . . .  table of selection functions
*V  ElmvListFuncs[<type>] . . . . . . . . . . .  table of selection functions
*V  ElmwListFuncs[<type>] . . . . . . . . . . .  table of selection functions
**
**  'ELM_LIST' only calls the functions  pointed to by 'ElmListFuncs[<type>]'
**  passing <list> and <pos>  as arguments.  If  <type> is not  the type of a
**  list, then 'ElmListFuncs[<type>]' points to 'ElmListError', which signals
**  the error.
**
**  'ELM_LIST', 'ELMV_LIST', and 'ELMW_LIST'  are defined in  the declaration
**  part of this package as follows
**
#define ELM_LIST(list,pos) \
                        ((*ElmListFuncs[TNUM_OBJ(list)])(list,pos))

#define ELMV_LIST(list,pos) \
                        ((*ElmvListFuncs[TNUM_OBJ(list)])(list,pos))

#define ELMW_LIST(list,pos) \
                        ((*ElmvListFuncs[TNUM_OBJ(list)])(list,pos))
*/
Obj             (*ElmListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

Obj             (*ElmvListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

Obj             (*ElmwListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Int pos );

Obj             ElmListOper;

Obj             ElmListHandler (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    return ELM_LIST( list, INT_INTOBJ(pos) );
}

Obj             ElmListError (
    Obj                 list,
    Int                 pos )
{
    list = ErrorReturnObj(
        "List Element: <list> must be a list (not a %s)",
        (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
        "you can return a list for <list>" );
    return ELM_LIST( list, pos );
}

Obj             ElmListObject (
    Obj                 list,
    Int                 pos )
{
    return DoOperation2Args( ElmListOper, list, INTOBJ_INT(pos) );
}


/****************************************************************************
**
*F  ELMS_LIST(<list>,<poss>)  . . . . . . select several elements from a list
*V  ElmsListFuncs[<type>] . . . . . . . . . . .  table of selection functions
*F  ElmsListError(<list>,<poss>)  . . . . . . . . .  error selection function
**
**  'ELMS_LIST'    only    calls    the     function   pointed     to      by
**  'ElmsListFuncs[<type>]',  passing  <list> and  <poss>   as arguments.  If
**  <type> is not the type of  a list, then 'ElmsListFuncs[<type>]' points to
**  'ElmsListError', which just signals an error.
**
**  'ELMS_LIST'  is defined in  the  declaration  part  of  this  package  as
**  follows
**
#define ELMS_LIST(list,poss) \
                        ((*ElmsListFuncs[TNUM_OBJ(list)])(list,poss))

*/
Obj             (*ElmsListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Obj poss );

Obj             ElmsListOper;

Obj             ElmsListHandler (
    Obj                 self,
    Obj                 list,
    Obj                 poss )
{
    return ELMS_LIST( list, poss );
}

Obj             ElmsListError (
    Obj                 list,
    Obj                 poss )
{
    list = ErrorReturnObj(
        "List Elements: <list> must be a list (not a %s)",
        (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
        "you can return a list for <list>" );
    return ELMS_LIST( list, poss );
}

Obj             ElmsListDefault (
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
        lenList = LEN_LIST( list );

        /* get the length of <positions>                                   */
        lenPoss = LEN_LIST( poss );

        /* make the result list                                            */
        elms = NEW_PLIST( T_PLIST, lenPoss );
        SET_LEN_PLIST( elms, lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );

            /* select the element                                          */
            elm = ELM0_LIST( list, pos );
            if ( elm == 0 ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can return after assigning a value" );
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
                "you can return after assigning a value" );
            return ELMS_LIST( list, poss );
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos + (lenPoss-1) * inc, 0L,
                "you can return after assigning a value" );
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
                    "you can return after assigning a value" );
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

Obj             ElmsListObject (
    Obj                 list,
    Obj                 poss )
{
    return DoOperation2Args( ElmsListOper, list, poss );
}

Obj             ElmsListDefaultFunc;

Obj             ElmsListDefaultHandler (
    Obj                 self,
    Obj                 list,
    Obj                 poss )
{
    return ElmsListDefault( list, poss );
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

Obj             UnbListHandler (
    Obj                 self,
    Obj                 list,
    Obj                 pos )
{
    UNB_LIST( list, INT_INTOBJ(pos) );
    return 0;
}

void            UnbListError (
    Obj                 list,
    Int                 pos )
{
    list = ErrorReturnObj(
        "Unbind: <list> must be a list (not a %s)",
        (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
        "you can return a list for <list>" );
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

Obj             AssListOper;

Obj             AssListHandler (
    Obj                 self,
    Obj                 list,
    Obj                 pos,
    Obj                 obj )
{
    ASS_LIST( list, INT_INTOBJ(pos), obj );
    return 0;
}

void            AssListError (
    Obj                 list,
    Int                 pos,
    Obj                 obj )
{
    list = ErrorReturnObj(
        "List Assignment: <list> must be a list (not a %s)",
        (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
        "you can return a list for <list>" );
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

void            AssListObject (
    Obj                 list,
    Int                 pos,
    Obj                 obj )
{
    DoOperation3Args( AssListOper, list, INTOBJ_INT(pos), obj );
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

Obj             AsssListHandler (
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
        (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
        "you can return a list for <list>" );
    ASSS_LIST( list, poss, objs );
}

void            AsssListDefault (
    Obj                 list,
    Obj                 poss,
    Obj                 objs )
{
    Int                 lenPoss;        /* length of <positions>           */
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
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );

            /* select the element                                          */
            obj = ELMW_LIST( objs, i );

            /* assign the element into <elms>                              */
            ASS_LIST( list, pos, obj );

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

Obj             AsssListDefaultFunc;

Obj             AsssListDefaultHandler (
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
*F  IsDenseListNot(<list>)  . . . . .  dense list test function for non lists
**
**  'IS_DENSE_LIST'  only     calls   the      function   pointed    to    by
**  'IsDenseListFuncs[<type>]', passing <list> as argument.  If <type> is not
**  the   type  of  a    list,  then  'IsDenseListFuncs[<type>]'  points   to
**  'IsDenseListNot', which just returns 0.
**
**  'IS_DENSE_LIST'  is defined in the declaration  part  of this  package as
**  follows
**
#define IS_DENSE_LIST(list) \
                        ((*IsDenseListFuncs[TNUM_OBJ(list)])(list))
*/
Int             (*IsDenseListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj             IsDenseListFilt;

Obj             IsDenseListHandler (
    Obj                 self,
    Obj                 obj )
{
    return (IS_DENSE_LIST( obj ) ? True : False);
}

Int             IsDenseListNot (
    Obj                 list )
{
    return 0L;
}

Int             IsDenseListYes (
    Obj                 list )
{
    return 1L;
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
*F  IsHomogListNot(<list>)  . .  homogeneous list test function for non lists
**
**  'IS_HOMOG_LIST' only calls the function pointed to by
**  'IsHomogListFuncs[<type>]', passing <list> as argument.  If <type> is not
**  the type of a list, then 'IsHomogListFuncs[<type>]' points to
**  'IsHomogListNot', which just returns 0.
**
**  'IS_HOMOG_LIST' is defined in the declaration part  of  this  package  as
**  follows
**
#define IS_HOMOG_LIST(list) \
                        ((*IsHomogListFuncs[TNUM_OBJ(list)])(list))
*/
Int             (*IsHomogListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj             IsHomogListFilt;

Obj             IsHomogListHandler (
    Obj                 self,
    Obj                 obj )
{
    return (IS_HOMOG_LIST( obj ) ? True : False);
}

Int             IsHomogListNot (
    Obj                 list )
{
    return 0L;
}

Int             IsHomogListYes (
    Obj                 list )
{
    return 1L;
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
*F  IsTableListNot(<list>)  . . . . .  table list test function for non lists
**
**  'IS_TABLE_LIST' only calls the function pointed to by
**  'IsTableListFuncs[<type>]', passing <list> as argument.  If <type> is not
**  the type of a list, then 'IsTableListFuncs[<type>]' points to
**  'IsTableListNot', which just returns 0.
**
**  'IS_TABLE_LIST' is defined in the declaration part  of  this  package  as
**  follows
**
#define IS_TABLE_LIST(list) \
                        ((*IsTableListFuncs[TNUM_OBJ(list)])(list))
*/
Int             (*IsTableListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj             IsTableListFilt;

Obj             IsTableListHandler (
    Obj                 self,
    Obj                 obj )
{
    return (IS_TABLE_LIST( obj ) ? True : False);
}

Int             IsTableListNot (
    Obj                 list )
{
    return 0L;
}

Int             IsTableListYes (
    Obj                 list )
{
    return 1L;
}

Int             IsTableListDefault (
    Obj                 list )
{
    Int                 lenList;        /* length of <list>                */
    Obj                 elm;            /* one element of <list>           */
    Obj                 fam;            /* family of elements of <list>    */
    Int                 len;            /* length of elements              */
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
    len = LEN_LIST( elm );

    /* loop over the entries of the list                                   */
    for ( i = 2; i <= lenList; i++ ) {
        elm = ELMV0_LIST( list, i );
        if ( elm == 0 || fam != FAMILY_TYPE( TYPE_OBJ( elm ) ) ) {
            return 0L;
        }
        if ( ! IS_LIST( elm ) || LEN_LIST( elm ) != len ) {
            return 0L;
        }
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
*F  IsSSortListNot( <list> ) strictly sorted list test function for non lists
**
**  'IS_SSORT_LIST' only calls the function pointed to by
**  'IsSSortListFuncs[<type>]', passing <list> as argument.
**  If <type> is not the type of a list, then 'IsSSortListFuncs[<type>]'
**  points to 'IsSSortListNot', which just returns 0.
**
**  'IS_SSORTED_LIST'  is defined in the  declaration part of this package as
**  follows
**
#define IS_SSORTED_LIST(list) \
                        ((*IsSSortListFuncs[TNUM_OBJ(list)])(list))
*/
Int (*IsSSortListFuncs[LAST_REAL_TNUM+1]) ( Obj list );

Obj IsSSortListProp;

Obj IsSSortListHandler (
    Obj                 self,
    Obj                 obj )
{
    return (IS_SSORT_LIST( obj ) ? True : False);
}

Int IsSSortListNot (
    Obj                 list )
{
    return 0L;
}

Int IsSSortListYes (
    Obj                 list )
{
    return 1L;
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

Obj             IsSSortListDefaultFunc;

Obj             IsSSortListDefaultHandler (
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

Obj IsNSortListHandler (
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
*F  IsPossListNot(<list>) . . . .  positions list test function for non lists
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

Obj             IsPossListHandler (
    Obj                 self,
    Obj                 obj )
{
    return (IS_POSS_LIST(obj) ? True : False);
}

Int             IsPossListNot (
    Obj                 list )
{
    return 0L;
}

Int             IsPossListYes (
    Obj                 list )
{
    return 1L;
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
        if ( elm == 0 || ! IS_INTOBJ(elm) || INT_INTOBJ(elm) <= 0 ) {
            return 0L;
        }
    }

    /* the list is a positions list                                        */
    return 1L;
}

Int             IsPossListObject (
    Obj                 obj )
{
    return (DoProperty( IsPossListProp, obj ) == True);
}

Obj             IsPossListDefaultFunc;

Obj             IsPossListDefaultHandler (
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
Int             (*PosListFuncs[LAST_REAL_TNUM+1]) ( Obj list, Obj obj, Int start );

Obj             PosListOper;

Obj             PosListHandler2 (
    Obj                 self,
    Obj                 list,
    Obj                 obj )
{
    Int                 pos;
    pos = POS_LIST( list, obj, 0L );
    return ( 0 < pos ? INTOBJ_INT(pos) : Fail );
}

Obj             PosListHandler3 (
    Obj                 self,
    Obj                 list,
    Obj                 obj,
    Obj                 start )
{
    Int                 pos;
    while ( ! IS_INTOBJ(start) || INT_INTOBJ(start) < 0 ) {
        start = ErrorReturnObj(
            "Position: <start> must be a nonnegative integer (not a %s)",
            (Int)(InfoBags[TNUM_OBJ(start)].name), 0L,
            "you can return a nonnegative integer for <start>" );
    }
    pos = POS_LIST( list, obj, INT_INTOBJ(start) );
    return ( 0 < pos ? INTOBJ_INT(pos) : Fail );
}

Int             PosListError (
    Obj                 list,
    Obj                 obj,
    Int                 start )
{
    list = ErrorReturnObj(
        "Position: <list> must be a list (not a %s)",
        (Int)(InfoBags[TNUM_OBJ(list)].name), 0L,
        "you can return a list for <list>" );
    return POS_LIST( list, obj, start );
}

Int             PosListDefault (
    Obj                 list,
    Obj                 obj,
    Int                 start )
{
    Int                 lenList;
    Obj                 elm;
    Int                 i;

    /* get the length of the list                                          */
    lenList = LEN_LIST( list );

    /* loop over all bound entries of the list, and compare against <obj>  */
    for ( i = start+1; i <= lenList; i++ ) {
        elm = ELMV0_LIST( list, i );
        if ( elm != 0 && EQ( elm, obj ) ) {
            break;
        }
    }

    /* return the position if found, and 0 otherwise                       */
    if ( i <= lenList ) {
        return i;
    }
    else {
        return 0L;
    }
}

Int             PosListObject (
    Obj                 list,
    Obj                 obj,
    Int                 start )
{
    Obj                 pos;
    pos = DoOperation3Args( PosListOper, list, obj, INTOBJ_INT(start) );
    while ( pos!=Fail && ( TNUM_OBJ(pos)!=T_INT || INT_INTOBJ(pos)<1 ) ) {
      pos = ErrorReturnObj(
        "Position: method must return a positive integer (not a %s) or fail",
        (Int)(InfoBags[TNUM_OBJ(pos)].name), 0L,
        "you can return a positive integer for <pos> or fail" );
    }
    return ( pos == Fail ? 0 : INT_INTOBJ( pos ) );
}

Obj             PosListDefaultFunc;

Obj             PosListDefaultHandler (
    Obj                 self,
    Obj                 list,
    Obj                 obj,
    Obj                 start )
{
    return INTOBJ_INT( PosListDefault( list, obj, INT_INTOBJ(start) ) );
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
    Int                 pos,
    Int                 level )
{
    Int                 len;            /* length of <lists>               */
    Obj                 list;           /* one list from <lists>           */
    Obj                 elm;            /* selected element from <list>    */
    Int                 i;              /* loop variable                   */

    /* if <level> is one, perform the replacements                         */
    if ( level == 1 ) {

        /* loop over the elements of <lists> (which must be a plain list)  */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* select the element                                          */
            elm = ELM_LIST( list, pos );

            /* replace the list with the element                           */
            SET_ELM_PLIST( lists, i, elm );

            /* notify Gasman                                               */
            CHANGED_BAG( lists );

        }

    }

    /* otherwise recurse                                                   */
    else {

        /* loop over the elements of <lists> (which must be a plain list)  */
        len = LEN_PLIST( lists );
        for ( i = 1; i <= len; i++ ) {

            /* get the list                                                */
            list = ELM_PLIST( lists, i );

            /* recurse                                                     */
            ElmListLevel( list, pos, level-1 );

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

    }

}


/****************************************************************************
**
*F  AssListLevel(<lists>,<pos>,<objs>,<level>)  . . . . . . . . . . . . . . .
*F  . . . . . . . . . . . . .  assign an element to several lists in parallel
**
**  'AssListLevel'  either assigns an  element  to all  lists in parallel  if
**  <level> is 1, or recurses if <level> is greater than 1.
*/
void            AssListLevel (
    Obj                 lists,
    Int                 pos,
    Obj                 objs,
    Int                 level )
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
                (Int)(InfoBags[TNUM_OBJ(objs)].name), 0L,
                "you can return a new dense list for <objs>" );
        }
        if ( LEN_LIST(lists) != LEN_LIST(objs) ) {
            objs = ErrorReturnObj(
         "List Assignment: <objs> must have the same length as <lists> (%d)",
                LEN_LIST(lists), 0L,
                "you can return a new dense list for <objs>" );
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

            /* assign the element                                          */
            ASS_LIST( list, pos, obj );

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
            AssListLevel( list, pos, obj, level-1 );

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
                (Int)(InfoBags[TNUM_OBJ(objs)].name), 0L,
                "you can return a new dense list for <objs>" );
        }
        if ( LEN_LIST(lists) != LEN_LIST(objs) ) {
            objs = ErrorReturnObj(
         "List Assignment: <objs> must have the same length as <lists> (%d)",
                LEN_LIST(lists), 0L,
                "you can return a new dense list for <objs>" );
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
                        (Int)(InfoBags[TNUM_OBJ(obj)].name), 0L,
                        "you can return a new dense list for <objs>" );
                }
                if ( LEN_LIST( poss ) != LEN_LIST( obj ) ) {
                    obj = ErrorReturnObj(
     "List Assigments: <objs> must have the same lenght as <positions> (%d)",
                        LEN_LIST( poss ), 0L,
                        "you can return a new dense list for <objs>" );
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
        (Int)(InfoBags[TNUM_OBJ(list)].name), 0L );
}


/****************************************************************************
**
*F  XTNum(<list>) . . . . . . . . . . . . . . . . . extended type of an value
*F  IS_XTNUM_LIST(<type>,<list>)  . . . . . . . . . .  test for extended type
*V  IsXTNumListFuncs[<type>]  . . . . . table of extended type test functions
**
**  'XTNum'  calls 'IS_XTNUM_LIST(<type>,<list>)'  with  <type> running  from
**  'T_VECTOR' to 'T_MATFFE' and returns    the first  type for which    this
**  function returns 1.  If no one returns  1, then 'XTNum' returns 'T_LISTX'
**  (and leaves the list as 'T_PLIST' or 'T_SET').
**
**  'IS_XTNUM_LIST' is defined in  the declaration  part  of this package  as
**  follows
**
#define IS_XTNUM_LIST(t,list) \
                        ((*IsXTNumListFuncs[t])(list))
*/
Int             (*IsXTNumListFuncs[LAST_VIRTUAL_TNUM+1]) ( Obj obj );

Int             XTNum (
    Obj                 obj )
{
    Int                 type;           /* loop variable                   */

    /* first handle non lists                                              */
    if ( TNUM_OBJ(obj) < FIRST_LIST_TNUM || LAST_LIST_TNUM < TNUM_OBJ(obj) )
        return TNUM_OBJ(obj);

    /* otherwise try the extended types in turn                            */
    /* this is done backwards to catch the more specific types first       */
    for ( type = LAST_VIRTUAL_TNUM; FIRST_REAL_TNUM <= type; type-- ) {
        if ( IsXTNumListFuncs[type] != 0 && IS_XTNUM_LIST( type, obj ) )
            return type;
    }

    /* nothing works, return 'T_OBJECT'                                    */
    return T_OBJECT;
}


/****************************************************************************
**
*F  TYPES_LIST_FAM(<fam>) . . . . . . .  list of kinds of lists over a family
*/
UInt            TYPES_LIST_FAM_RNam;

Obj             TYPES_LIST_FAM (
    Obj                 fam )
{
    return ElmPRec( fam, TYPES_LIST_FAM_RNam );
}


/****************************************************************************
**
*F  IsMutableListYes(<list>)  . . . . . . . mutability test for mutable lists
*F  IsMutableListNo(<list>) . . . . . . . mutability test for immutable lists
**
**  'IsMutableListYes' simply returns 1.  'IsMutableListNo' simply returns 0.
**  Note that we can decide from the type number whether a list is mutable or
**  immutable.
**
**  'IsMutableListYes' is  the function  in 'IsMutableObjFuncs'   for mutable
**  lists.   'IsMutableListNo'  is  the function  in 'IsMutableObjFuncs'  for
**  immutable lists.
*/
Int             IsMutableListNo (
    Obj                 list )
{
    return 0L;
}

Int             IsMutableListYes (
    Obj                 list )
{
    return 1L;
}


/****************************************************************************
**
*F  IsCopyableListYes(<list>) . . . . . . . . . .  copyability test for lists
**
**  'IsCopyableListYes' simply returns 1.  Note that all lists are copyable.
**
**  'IsCopyableListYes' is the function in 'IsCopyableObjFuncs' for lists.
*/
Int             IsCopyableListYes (
    Obj                     list )
{
    return 1;
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

    if ( IsStringConv(list) && MUTABLE_TNUM(TNUM_OBJ(list))==T_STRING ) {
	PrintString(list);
	return;
    }

    Pr("%2>[ %2>",0L,0L);
    for ( PrintObjIndex=1; PrintObjIndex<=LEN_LIST(list); PrintObjIndex++ ) {
        elm = ELMV0_LIST( list, PrintObjIndex );
        if ( elm != 0 ) {
            if ( 1 < PrintObjIndex )  Pr( "%<,%< %2>", 0L, 0L );
            PrintObj( elm );
        }
        else {
            if ( 1 < PrintObjIndex )  Pr( "%2<,%2>", 0L, 0L );
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
*F  InitLists() . . . . . . . . . . . . . initialize the generic list package
**
**  'InitLists' initializes the dispatch tables with the error handlers.
*/
void            InitLists ()
{
    UInt                type;           /* loop variable                   */

    /* make and install the 'IS_LIST' filter                               */
    InitHandlerFunc( IsListHandler, "IS_LIST" );
    IsListFilt = NewFilterC(
        "IS_LIST", 1L, "obj", IsListHandler );
    AssGVar( GVarName( "IS_LIST" ), IsListFilt );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        IsListFuncs[ type ] = IsListNot;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsListFuncs[ type ] = IsListYes;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsListFuncs[ type ] = IsListObject;
    }

    /* make and install the length attribute                               */
    C_NEW_GVAR_ATTR( "LENGTH", "list", LengthAttr, LENGTHHandler,
         "src/lists.c:LENGTH" );

    /* make and install the 'LEN_LIST' function                            */
    C_NEW_GVAR_FUNC( "LEN_LIST", 1L, "list", LenListHandler,
         "src/lists.c:LEN_LIST" );

    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        LenListFuncs[ type ] = LenListError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        LenListFuncs[ type ] = LenListObject;
    }

    /* make and install the 'ISB_LIST' operation                           */
    InitHandlerFunc( IsbListHandler, "ISB_LIST" );
    IsbListOper = NewOperationC(
        "ISB_LIST", 2L, "list, pos", IsbListHandler );
    AssGVar( GVarName( "ISB_LIST" ), IsbListOper );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        IsbListFuncs[ type ] = IsbListError;
        IsbvListFuncs[ type ] = IsbListError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsbListFuncs[ type ] = IsbListObject;
        IsbvListFuncs[ type ] = IsbListObject;
    }

    /* make and install the 'ELM0_LIST' operation                          */
    InitHandlerFunc( Elm0ListHandler, "ELM0_LIST" );
    Elm0ListOper = NewOperationC(
        "ELM0_LIST", 2L, "list, pos", Elm0ListHandler );
    AssGVar( GVarName( "ELM0_LIST" ), Elm0ListOper );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        Elm0ListFuncs[ type ] = Elm0ListError;
        Elm0vListFuncs[ type ] = Elm0ListError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        Elm0ListFuncs[ type ] = Elm0ListObject;
        Elm0vListFuncs[ type ] = Elm0ListObject;
    }

    /* make and install the 'ELM_LIST' operation                           */
    InitHandlerFunc( ElmListHandler, "ELM_LIST" );
    ElmListOper = NewOperationC(
        "ELM_LIST", 2L, "list, pos", ElmListHandler );
    AssGVar( GVarName( "ELM_LIST" ), ElmListOper );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        ElmListFuncs[  type ] = ElmListError;
        ElmvListFuncs[ type ] = ElmListError;
        ElmwListFuncs[ type ] = ElmListError;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        ElmListFuncs[  type ] = ElmListObject;
        ElmvListFuncs[ type ] = ElmListObject;
        ElmwListFuncs[ type ] = ElmListObject;
    }

    /* make and install the 'ELMS_LIST' operation                          */
    InitHandlerFunc( ElmsListHandler, "ELMS_LIST" );
    ElmsListOper = NewOperationC(
        "ELMS_LIST", 2L, "list, poss", ElmsListHandler );
    AssGVar( GVarName( "ELMS_LIST" ), ElmsListOper );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        ElmsListFuncs[ type ] = ElmsListError;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        ElmsListFuncs[ type ] = ElmsListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        ElmsListFuncs[ type ] = ElmsListObject;
    }


    InitHandlerFunc( ElmsListDefaultHandler, "ELMS_LIST_DEFAULT");
    ElmsListDefaultFunc = NewFunctionC(
         "ELMS_LIST_DEFAULT", 2L, "list, poss", ElmsListDefaultHandler );
    AssGVar( GVarName( "ELMS_LIST_DEFAULT" ), ElmsListDefaultFunc );

    /* make and install the 'UNB_LIST' operation                           */
    InitHandlerFunc( UnbListHandler, "UNB_LIST" );
    UnbListOper = NewOperationC(
        "UNB_LIST", 2L, "list, pos", UnbListHandler );
    AssGVar( GVarName( "UNB_LIST" ), UnbListOper );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        UnbListFuncs[ type ] = UnbListError;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        UnbListFuncs[ type ] = UnbListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        UnbListFuncs[ type ] = UnbListObject;
    }

    /* make and install the 'ASS_LIST' operation                           */
    InitHandlerFunc( AssListHandler, "ASS_LIST" );
    AssListOper = NewOperationC(
        "ASS_LIST", 3L, "list, pos, obj", AssListHandler );
    AssGVar( GVarName( "ASS_LIST" ), AssListOper );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        AssListFuncs[ type ] = AssListError;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        AssListFuncs[ type ] = AssListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        AssListFuncs[ type ] = AssListObject;
    }

    /* make and install the 'ASSS_LIST' operation                          */
    InitHandlerFunc( AsssListHandler, "ASSS_LIST" );
    AsssListOper = NewOperationC(
        "ASSS_LIST", 3L, "list, poss, objs", AsssListHandler );
    AssGVar( GVarName( "ASSS_LIST" ), AsssListOper );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        AsssListFuncs[ type ] = AsssListError;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        AsssListFuncs[ type ] = AsssListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        AsssListFuncs[ type ] = AsssListObject;
    }
    
    InitHandlerFunc( AsssListDefaultHandler, "ASSS_LIST_DEFAULT");
    AsssListDefaultFunc = NewFunctionC(
        "ASSS_LIST_DEFAULT", 3L, "list, poss, objs", AsssListDefaultHandler );
    AssGVar( GVarName( "ASSS_LIST_DEFAULT" ), AsssListDefaultFunc );

    /* make and install the 'IS_DENSE_LIST' filter                         */
    InitHandlerFunc( IsDenseListHandler, "IS_DENSE_LIST" );
    IsDenseListFilt = NewFilterC(
        "IS_DENSE_LIST", 1L, "obj", IsDenseListHandler );
    AssGVar( GVarName( "IS_DENSE_LIST" ), IsDenseListFilt );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        IsDenseListFuncs[ type ] = IsDenseListNot;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsDenseListFuncs[ type ] = IsDenseListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsDenseListFuncs[ type ] = IsDenseListObject;
    }

    /* make and install the 'IS_HOMOG_LIST' filter                         */
    InitHandlerFunc( IsHomogListHandler, "IS_HOMOG_LIST" );
    IsHomogListFilt = NewFilterC(
        "IS_HOMOG_LIST", 1L, "obj", IsHomogListHandler );
    AssGVar( GVarName( "IS_HOMOG_LIST" ), IsHomogListFilt );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        IsHomogListFuncs[ type ] = IsHomogListNot;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsHomogListFuncs[ type ] = IsHomogListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsHomogListFuncs[ type ] = IsHomogListObject;
    }

    /* make and install the 'IS_TABLE_LIST' filter                         */
    InitHandlerFunc( IsTableListHandler, "IS_TABLE_LIST" );
    IsTableListFilt = NewFilterC(
        "IS_TABLE_LIST", 1L, "obj", IsTableListHandler );
    AssGVar( GVarName( "IS_TABLE_LIST" ), IsTableListFilt );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        IsTableListFuncs[ type ] = IsTableListNot;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsTableListFuncs[ type ] = IsTableListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsTableListFuncs[ type ] = IsTableListObject;
    }

    /* make and install the 'IS_SSORT_LIST' property                       */
    InitHandlerFunc( IsSSortListHandler, "IS_SSORT_LIST" );
    IsSSortListProp = NewPropertyC(
        "IS_SSORT_LIST", 1L, "obj", IsSSortListHandler );
    AssGVar( GVarName( "IS_SSORT_LIST" ), IsSSortListProp );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        IsSSortListFuncs[ type ] = IsSSortListNot;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsSSortListFuncs[ type ] = IsSSortListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsSSortListFuncs[ type ] = IsSSortListObject;
    }

    InitHandlerFunc( IsSSortListDefaultHandler, "IS_SSORT_LIST_DEFAULT");
    IsSSortListDefaultFunc = NewFunctionC(
        "IS_SSORT_LIST_DEFAULT",1L,"obj", IsSSortListDefaultHandler );
    AssGVar( GVarName( "IS_SSORT_LIST_DEFAULT" ), IsSSortListDefaultFunc );

    /* make and install the 'IS_NSORT_LIST' property                       */
    InitHandlerFunc( IsNSortListHandler, "IS_NSORT_LIST" );
    IsNSortListProp = NewPropertyC(
        "IS_NSORT_LIST", 1L, "obj", IsNSortListHandler );
    AssGVar( GVarName( "IS_NSORT_LIST" ), IsNSortListProp );

    /* make and install the 'IS_POSS_LIST' property                        */
    InitHandlerFunc( IsPossListHandler, "IS_POSS_LIST" );
    IsPossListProp = NewPropertyC(
        "IS_POSS_LIST", 1L, "obj", IsPossListHandler );
    AssGVar( GVarName( "IS_POSS_LIST" ), IsPossListProp );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        IsPossListFuncs[ type ] = IsPossListNot;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        IsPossListFuncs[ type ] = IsPossListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        IsPossListFuncs[ type ] = IsPossListObject;
    }

    InitHandlerFunc( IsPossListDefaultHandler, "IS_POSS_LIST_DEFAULT");
    IsPossListDefaultFunc = NewFunctionC(
        "IS_POSS_LIST_DEFAULT",1L,"obj", IsPossListDefaultHandler );
    AssGVar( GVarName( "IS_POSS_LIST_DEFAULT" ), IsPossListDefaultFunc );

    /* make and install the 'POS_LIST' operation                           */    
    InitHandlerFunc( PosListHandler2, "POS_LIST 2 args" );
    InitHandlerFunc( PosListHandler3, "POS_LIST 3 args" );
    PosListOper = NewOperationC(
        "POS_LIST", -1, "list, obj", DoOperation0Args );
    HDLR_FUNC( PosListOper, 2 ) = PosListHandler2;
    HDLR_FUNC( PosListOper, 3 ) = PosListHandler3;
    AssGVar( GVarName( "POS_LIST" ), PosListOper );
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        PosListFuncs[ type ] = PosListError;
    }
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        PosListFuncs[ type ] = PosListDefault;
    }
    for ( type = FIRST_EXTERNAL_TNUM; type <= LAST_EXTERNAL_TNUM; type++ ) {
        PosListFuncs[ type ] = PosListObject;
    }

    InitHandlerFunc( PosListDefaultHandler, "POS_LIST_DEFAULT");
    PosListDefaultFunc = NewFunctionC(
        "POS_LIST_DEFAULT", 3L, "list, obj, start", PosListDefaultHandler );
    AssGVar( GVarName( "POS_LIST_DEFAULT" ), PosListDefaultFunc );

    /* install the error functions into the other tables                   */
    for ( type = FIRST_REAL_TNUM; type <= LAST_REAL_TNUM; type++ ) {
        PlainListFuncs  [ type ] = PlainListError;
    }

    /* whats that?                                                         */
    TYPES_LIST_FAM_RNam = RNamName( "TYPES_LIST_FAM" );

    /* install the generic mutability test function                        */
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type += 2 ) {
        IsMutableObjFuncs[  type           ] = IsMutableListYes;
        IsMutableObjFuncs[  type+IMMUTABLE ] = IsMutableListNo;
        IsCopyableObjFuncs[ type           ] = IsCopyableListYes;
        IsCopyableObjFuncs[ type+IMMUTABLE ] = IsCopyableListYes;
    }

    /* install the default printers                                        */
    for ( type = FIRST_LIST_TNUM; type <= LAST_LIST_TNUM; type++ ) {
        PrintObjFuncs [ type ] = PrintListDefault;
        PrintPathFuncs[ type ] = PrintPathList;
    }

}


/****************************************************************************
**

*E  lists.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



