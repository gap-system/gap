/****************************************************************************
**
*A  precord.c                   GAP source                   Martin Schoenert
**
*H  @(#)$Id$
**
*Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
**
**  This file contains the functions for plain records.
**
**  A plain record  with <n>  components is stored  as  a bag  with 2  *  <n>
**  entries.  The odd entries are the record  names of the components and the
**  even entries are the corresponding values.
*/
char *          Revision_precord_c =
   "@(#)$Id$";

#include        "system.h"              /* Ints, UInts                     */
#include        "scanner.h"             /* Pr                              */
#include        "gasman.h"              /* NewBag, CHANGED_BAG             */

#include        "objects.h"             /* Obj, TYPE_OBJ, types            */
#include        "gvars.h"               /* global variables                */

#include        "calls.h"               /* generic call mechanism          */
#include        "opers.h"               /* generic operations mechanism    */

#include        "ariths.h"              /* generic operations package      */
#include        "records.h"             /* generic records                 */
#include        "lists.h"               /* generic lists                   */

#include        "bool.h"                /* True, False                     */

#define INCLUDE_DECLARATION_PART
#include        "precord.h"             /* declaration part of the package */
#undef  INCLUDE_DECLARATION_PART

#include        "plist.h"               /* NEW_PLIST, SET_LEN_PLIST, SET...*/
#include        "string.h"              /* NEW_STRING, CSTR_STRING         */

#include        "gap.h"                 /* Error                           */


/****************************************************************************
**
*F  NEW_PREC(<len>) . . . . . . . . . . . . . . . . . make a new plain record
**
**  'NEW_PREC' returns a new plain record with room for <len> components.
**
**  'NEW_PREC' is defined in the declaration part of this package as follows
**
#define NEW_PREC(len)   NewBag( T_PREC, (len) * 2*sizeof(Obj) + sizeof(Obj) )
*/


/****************************************************************************
**
*F  LEN_PREC(<rec>) . . . . . . . . . .  number of components of plain record
**
**  'LEN_PREC' returns the number of components of the plain record <rec>.
**
**  'LEN_PREC' is defined in the declaration part of this package as follows
**
#define LEN_PREC(rec)   ((SIZE_OBJ(rec) - sizeof(Obj)) / (2*sizeof(Obj)))
*/


/****************************************************************************
**
*F  SET_RNAM_PREC(<rec>,<i>,<rnam>) . . . set name of <i>-th record component
**
**  'SET_RNAM_PREC' sets   the name of  the  <i>-th  record component  of the
**  record <rec> to the record name <rnam>.
**
**  'SET_RNAM_PREC'  is defined  in the declaration  part  of this package as
**  follows
**
#define SET_RNAM_PREC(rec,i,rnam) \
                        (*(UInt*)(ADDR_OBJ(rec)+2*(i)-1) = (rnam))
*/


/****************************************************************************
**
*F  GET_RNAM_PREC(<rec>,<i>)  . . . . . . . . name of <i>-th record component
**
**  'GET_RNAM_PREC' returns the record name of the <i>-th record component of
**  the record <rec>.
**
**  'GET_RNAM_PREC'  is defined in  the declaration  part of  this package as
**  follows
**
#define GET_RNAM_PREC(rec,i) \
                        (*(UInt*)(ADDR_OBJ(rec)+2*(i)-1))
*/


/****************************************************************************
**
*F  SET_ELM_PREC(<rec>,<i>,<val>) . . .  set value of <i>-th record component
**
**  'SET_ELM_PREC' sets  the value  of  the  <i>-th  record component of  the
**  record <rec> to the value <val>.
**
**  'SET_ELM_PREC'  is defined  in the declaration   part of this package  as
**  follows
**
#define SET_ELM_PREC(rec,i,val) \
                        (*(ADDR_OBJ(rec)+2*(i)-0) = (val))
*/


/****************************************************************************
**
*F  GET_ELM_PREC(<rec>,<i>) . . . . . . . .  value of <i>-th record component
**
**  'GET_ELM_PREC' returns the value  of the <i>-th  record component of  the
**  record <rec>.
**
**  'GET_ELM_PREC' is defined in  the  declaration part  of this  package  as
**  follows
**
#define GET_ELM_PREC(rec,i) \
                        (*(ADDR_OBJ(rec)+2*(i)-0))
*/


/****************************************************************************
**
*F  KindPRec(<rec>) . . . . . . . . . . . . . . . . .  kind of a plain record
**
**  'KindPRec' returns the kind of the plain record <rec>.
**
**  'KindPRec' is the function in 'KindObjFuncs' for plain records.
*/
Obj             KIND_PREC_MUTABLE;

Obj             KindPRecMut (
    Obj                 prec )
{
    return KIND_PREC_MUTABLE;
}

Obj             KIND_PREC_IMMUTABLE;

Obj             KindPRecImm (
    Obj                 prec )
{
    return KIND_PREC_IMMUTABLE;
}


/****************************************************************************
**
*F  IsMutablePRecYes(<rec>) . . . . . . . mutability test for mutable records
*F  IsMutablePRecNo(<rec>)  . . . . . . mutability test for immutable records
**
**  'IsMutablePRecYes' simply returns 1.  'IsMutablePRecNo' simply returns 0.
**  Note that we can decide from the type number whether  a record is mutable
**  or immutable.
**
**  'IsMutablePRecYes'  is the function   in 'IsMutableObjFuncs'  for mutable
**  records.   'IsMutablePRecNo' is  the function  in 'IsMutableObjFuncs' for
**  immutable records.
*/
Int             IsMutablePRecYes (
    Obj                 rec )
{
    return 1;
}

Int             IsMutablePRecNo (
    Obj                 rec )
{
    return 0;
}


/****************************************************************************
**
*F  IsCopyablePRecYes(<rec>)  . . . . . . . . .  copyability test for records
**
**  'IsCopyablePRec' simply returns 1.  Note that all records are copyable.
**
**  'IsCopyablePRec' is the function in 'IsCopyableObjFuncs' for records.
*/
Int             IsCopyablePRecYes (
    Obj                 rec )
{
    return 1;
}


/****************************************************************************
**
*F  CopyPRec(<rec>) . . . . . . . . . . . . . . . . . . . copy a plain record
*F  CleanPRec(<rec>)  . . . . . . . . . . . . . . . . clean up a plain record
**
**  'CopyPRec' returns a structural (deep) copy  of the record <rec>, i.e., a
**  recursive copy that preserves the structure.
**
**  If <rec>  has not yet  been  copied, it makes a   copy, leaves a  forward
**  pointer to the copy in  the first entry   of the record, where the  first
**  record name usually resides,  and copies all the  entries.  If the record
**  has alread been copied, it returns the value of the forwarding pointer.
**
**  'CopyPRec' is the function in 'TabCopyObj' for records.
**
**  'CleanPRec' removes the  mark and the forwarding  pointer from the record
**  <rec>.
**
**  'CleanPRec' is the function in 'TabCleanObj' for records.
*/
Obj             CopyPRec (
    Obj                 rec,
    Int                 mut )
{
    Obj                 copy;           /* copy, result                    */
    Obj                 tmp;            /* temporary variable              */
    UInt                i;              /* loop variable                   */

    /* don't change immutable objects                                      */
    if ( ! IS_MUTABLE_OBJ(rec) ) {
        return rec;
    }

    /* if an empty record has not yet been copied                          */
    if ( LEN_PREC(rec) == 0 ) {

	/* make a copy                                                     */
	if ( mut ) {
	    copy = NewBag( TYPE_OBJ(rec), SIZE_OBJ(rec) );
	}
	else {
	    copy = NewBag( IMMUTABLE_TYPE(TYPE_OBJ(rec)), SIZE_OBJ(rec) );
	}

        /* leave a forwarding pointer                                      */
        ResizeBag( rec, SIZE_OBJ(rec) + sizeof(Obj) );
        SET_RNAM_PREC( rec, 1, (UInt)copy );
        CHANGED_BAG( rec );

        /* now it is copied                                                */
        RetypeBag( rec, TYPE_OBJ(rec) + COPYING );
    }

    /* if the record has not yet been copied                               */
    else {

	/* make a copy                                                     */
	if ( mut ) {
	    copy = NewBag( TYPE_OBJ(rec), SIZE_OBJ(rec) );
	}
	else {
	    copy = NewBag( IMMUTABLE_TYPE(TYPE_OBJ(rec)), SIZE_OBJ(rec) );
	}
        SET_RNAM_PREC( copy, 1, GET_RNAM_PREC( rec, 1 ) );

        /* leave a forwarding pointer                                      */
        SET_RNAM_PREC( rec, 1, (UInt)copy );
        CHANGED_BAG( rec );

        /* now it is copied                                                */
        RetypeBag( rec, TYPE_OBJ(rec) + COPYING );

        /* copy the subvalues                                              */
        tmp = COPY_OBJ( GET_ELM_PREC( rec, 1 ), mut );
        SET_ELM_PREC( copy, 1, tmp );
        CHANGED_BAG( copy );
        for ( i = 2; i <= LEN_PREC(copy); i++ ) {
            SET_RNAM_PREC( copy, i, GET_RNAM_PREC( rec, i ) );
            tmp = COPY_OBJ( GET_ELM_PREC( rec, i ), mut );
            SET_ELM_PREC( copy, i, tmp );
            CHANGED_BAG( copy );
        }

    }

    /* return the copy                                                     */
    return copy;
}

Obj             CopyPRecCopy (
    Obj                 rec,
    Int                 mut )
{
    return (Obj)GET_RNAM_PREC( rec, 1 );
}

void            CleanPRec (
    Obj                 rec )
{
}

void            CleanPRecCopy (
    Obj                 rec )
{
    UInt                i;              /* loop variable                   */

    /* empty record                                                        */
    if ( LEN_PREC(rec) == 0 ) {

        /* remove the forwarding pointer                                   */
        ResizeBag( rec, SIZE_OBJ(rec) - sizeof(Obj) );

        /* now it is cleaned                                               */
        RetypeBag( rec, TYPE_OBJ(rec) - COPYING );
    }

    /* nonempty record                                                     */
    else {

        /* remove the forwarding pointer                                   */
        SET_RNAM_PREC( rec, 1, GET_RNAM_PREC( GET_RNAM_PREC( rec, 1 ), 1 ) );

        /* now it is cleaned                                               */
        RetypeBag( rec, TYPE_OBJ(rec) - COPYING );

        /* clean the subvalues                                             */
        CLEAN_OBJ( GET_ELM_PREC( rec, 1 ) );
        for ( i = 2; i <= LEN_PREC(rec); i++ ) {
            CLEAN_OBJ( GET_ELM_PREC( rec, i ) );
        }
    }
}


/****************************************************************************
**
*F  IsbPRec(<rec>,<rnam>)  . . . . .  test for an element from a plain record
**
**  'IsbPRec' returns 1 if the record <rec> has a component with  the  record
**  name <rnam>, and 0 otherwise.
*/
Int             IsbPRec (
    Obj                 rec,
    UInt                rnam )
{
    UInt                len;            /* length of <rec>                 */
    UInt                i;              /* loop variable                   */

    /* get the length of the record                                        */
    len = LEN_PREC( rec );

    /* find the record component                                           */
    for ( i = 1; i <= len; i++ ) {
        if ( GET_RNAM_PREC( rec, i ) == rnam )
            break;
    }

    /* return the result                                                   */
    return (i <= len);
}


/****************************************************************************
**
*F  ElmPRec(<rec>,<rnam>) . . . . . . . select an element from a plain record
**
**  'ElmPRec' returns the element, i.e., the value of the component, with the
**  record name <rnam> in  the plain record <rec>.   An error is signalled if
**  <rec> has no component with record name <rnam>.
*/
Obj             ElmPRec (
    Obj                 rec,
    UInt                rnam )
{
    UInt                len;            /* length of <rec>                 */
    UInt                i;              /* loop variable                   */

    /* get the length of the record                                        */
    len = LEN_PREC( rec );

    /* find the record component                                           */
    for ( i = 1; i <= len; i++ ) {
        if ( GET_RNAM_PREC( rec, i ) == rnam )
            break;
    }

    /* signal an error if no such component exists                         */
    if ( len < i ) {
        ErrorReturnVoid(
            "Record: '<rec>.%s' must have an assigned value",
            (Int)NAME_RNAM(rnam), 0L,
            "you can return after assigning a value" );
        return ELM_REC( rec, rnam );
    }

    /* return the value of the component                                   */
    return GET_ELM_PREC( rec, i );
}


/****************************************************************************
**
*F  UnbPRec(<rec>,<rnam>) . . . unbind a record component from a plain record
**
**  'UnbPRec'  removes the record component  with the record name <rnam> from
**  the record <rec>.
*/
void            UnbPRec (
    Obj                 rec,
    UInt                rnam )
{
    UInt                len;            /* length of <rec>                 */
    UInt                i;              /* loop variable                   */

    /* get the length of the record                                        */
    len = LEN_PREC( rec );

    /* find the record component                                           */
    for ( i = 1; i <= len; i++ ) {
        if ( GET_RNAM_PREC( rec, i ) == rnam )
            break;
    }

    /* do nothing if no such component exists                              */
    if ( len < i ) {
        return;
    }

    /* otherwise move everything forward                                   */
    for ( ; i < len; i++ ) {
        SET_RNAM_PREC( rec, i, GET_RNAM_PREC( rec, i+1 ) );
        SET_ELM_PREC(  rec, i, GET_ELM_PREC(  rec, i+1 ) );
    }

    /* resize the record                                                   */
    ResizeBag( rec, SIZE_OBJ(rec) - 2*sizeof(Obj) );
}

void            UnbPRecImm (
    Obj                 rec,
    UInt                rnam )
{
    ErrorReturnVoid(
        "Record Unbind: <rec> must be a mutable record",
        0L, 0L,
        "you can return and ignore the unbind" );
}


/****************************************************************************
**
*F  AssPRec(<rec>,<rnam>,<val>)  . . . . . . . . . . assign to a plain record
**
**  'AssPRec' assigns the value <val> to the record component with the record
**  name <rnam> in the plain record <rec>.
*/
void            AssPRec (
    Obj                 rec,
    UInt                rnam,
    Obj                 val )
{
    UInt                len;            /* length of <rec>                 */
    UInt                i;              /* loop variable                   */

    /* get the length of the record                                        */
    len = LEN_PREC( rec );

    /* find the record component                                           */
    for ( i = 1; i <= len; i++ ) {
        if ( GET_RNAM_PREC( rec, i ) == rnam )
            break;
    }

    /* extend the record if no such component exists                       */
    if ( len < i ) {
        ResizeBag( rec, SIZE_OBJ(rec) + 2*sizeof(Obj) );
        SET_RNAM_PREC( rec, i, rnam );
    }

    /* assign the value to the component                                   */
    SET_ELM_PREC( rec, i, val );
    CHANGED_BAG( rec );
}

void            AssPRecImm (
    Obj                 rec,
    UInt                rnam,
    Obj                 val )
{
    ErrorReturnVoid(
        "Records Assignment: <rec> must be a mutable record",
        0L, 0L,
        "you can return and ignore the assignment" );
}


/****************************************************************************
**
*F  MethodPRec(<rec>,<rnam>)  . . . . . . . . . . . get a method for a record
**
**  'MethodPRec' returns  the function in the  component with the record name
**  <rnam> in the  record in the component  with the name 'operations' (which
**  really should be  called 'methods') of  the record <rec>  if this exists.
**  Otherwise it return 0.
*/
UInt            OperationsRNam;         /* 'operations' record name        */

Obj             MethodPRec (
    Obj                 rec,
    UInt                rnam )
{
    Obj                 method;         /* method, result                  */
    Obj                 opers;          /* operations record               */
    UInt                len;            /* length of the record            */
    UInt                i;              /* loop variable                   */

    /* is <rec> a record?                                                  */
    if ( TYPE_OBJ(rec) != T_PREC )
        return 0;

    /* try to get the operations record                                    */
    len = LEN_PREC( rec );
    for ( i = 1; i <= len; i++ ) {
        if ( GET_RNAM_PREC( rec, i ) == OperationsRNam )
            break;
    }
    if ( len < i ) {
        return 0;
    }
    opers = GET_ELM_PREC( rec, i );
    if ( TYPE_OBJ( opers ) != T_PREC ) {
        return 0;
    }

    /* try to get the method                                               */
    len = LEN_PREC( opers );
    for ( i = 1; i <= len; i++ ) {
        if ( GET_RNAM_PREC( opers, i ) == OperationsRNam )
            break;
    }
    if ( len < i ) {
        return 0;
    }
    method = GET_ELM_PREC( opers, i );
    if ( TYPE_OBJ( method ) != T_PREC ) {
        return 0;
    }

    /* return the method                                                   */
    return method;
}


/****************************************************************************
**
*F  PrintPRec(<rec>)  . . . . . . . . . . . . . . . . . . . .  print a record
**
**  'PrintRec' prints the plain record <rec>.
*/
UInt            PrintRNam;

void            PrintPRec (
    Obj                 rec )
{
    Obj                 method;         /* method                          */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( rec, PrintRNam )) ) {

        /* if no applicable method is found, print the record              */
        Pr( "%2>rec(\n%2>", 0L, 0L );
        for ( PrintObjIndex = 1;
              PrintObjIndex <= LEN_PREC(rec);
              PrintObjIndex++ ) {
            Pr( "%I", (Int)NAME_RNAM(GET_RNAM_PREC(rec,PrintObjIndex)), 0L );
            Pr( "%< := %>", 0L, 0L );
            PrintObj( GET_ELM_PREC( rec, PrintObjIndex ) );
            if ( PrintObjIndex < LEN_PREC(rec) ) {
                Pr( "%2<,\n%2>", 0L, 0L );
            }
        }
        Pr( " %4<)", 0L, 0L );
        return;

    }

    /* call that function                                                  */
    CALL_1ARGS( method, rec );
}

void            PrintPathPRec (
    Obj                 rec,
    Int                 indx )
{
    Pr( ".%I", (Int)NAME_RNAM( GET_RNAM_PREC(rec,indx) ), 0L );
}


/****************************************************************************
**
*F  SortPRec(<rec>) . . . . .  sort a record according to the component names
**
**  'SortPRec' sorts the plain record <rec> according to the component names.
*/
void            SortPRec (
    Obj                 rec )
{
    UInt                rnam;           /* name of component               */
    Obj                 val;            /* value of component              */
    UInt                h;              /* gap width in shellsort          */
    UInt                i,  k;          /* loop variables                  */

    /* sort the right record with a shellsort                              */
    h = 1;  while ( 9*h + 4 < LEN_PREC(rec) )  h = 3*h + 1;
    while ( 0 < h ) {
        for ( i = h+1; i <= LEN_PREC(rec); i++ ) {
            rnam = GET_RNAM_PREC( rec, i );
            val  = GET_ELM_PREC(  rec, i );
            k = i;
            while ( h < k
                 && SyStrcmp( NAME_RNAM(rnam),
                              NAME_RNAM( GET_RNAM_PREC(rec,k-h) ) ) < 0 ) {
                SET_RNAM_PREC( rec, k, GET_RNAM_PREC( rec, k-h ) );
                SET_ELM_PREC(  rec, k, GET_ELM_PREC(  rec, k-h ) );
                k -= h;
            }
            SET_RNAM_PREC( rec, k, rnam );
            SET_ELM_PREC(  rec, k, val  );
        }
        h = h / 3;
    }

}


/****************************************************************************
**
*F  EqPRec(<left>,<right>)  . . . . . . . . . . . .  comparison of two record
**
**  'EqRec' returns '1L'  if the two  operands <left> and <right> are equal
**  and '0L' otherwise.  At least one operand must be a plain record.
**
**  If at  least one of the  operands is a  record and has a '.operations.\='
**  method,  than this is called  and its result  is returned.  Otherwise the
**  records are compared componentwise.
*/
UInt            EqRNam;                 /* '=' record name                 */

Int             EqPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;         /* method                          */
    UInt                i;              /* loop variable                   */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, EqRNam ))
      && ! (method = MethodPRec( left,  EqRNam )) ) {

        /* quick first checks                                              */
        if ( TYPE_OBJ(left ) <  TYPE_OBJ(right) )  return 0L;
        if ( TYPE_OBJ(left ) >  TYPE_OBJ(right) )  return 0L;
        if ( LEN_PREC(left ) != LEN_PREC(right) )  return 0L;

        /* sort both records                                               */
        SortPRec( left  );
        SortPRec( right );

        /* compare componentwise                                           */
        for ( i = 1; i <= LEN_PREC(right); i++ ) {

            /* compare the names                                           */
            if ( GET_RNAM_PREC(left,i) != GET_RNAM_PREC(right,i) ) {
                return 0L;
            }

            /* compare the values                                          */
            if ( ! EQ(GET_ELM_PREC(left,i),GET_ELM_PREC(right,i)) ) {
                return 0L;
            }
        }

        /* the records are equal                                           */
        return 1L;

    }

    /* call that function                                                  */
    return (CALL_2ARGS( method, left, right ) == True);
}


/****************************************************************************
**
*F  LtPRec(<left>,<right>)  . . . . . . . . . . . .  comparison of two record
**
**  'LtRec' returns '1L'  if the operand  <left> is  less than the  operand
**  <right>, and '0L'  otherwise.  At least  one operand  must be a  plain
**  record.
**
**  If at least  one of the operands is  a record and  has a '.operations.\<'
**  method, than this  is called and its  result is  returned.  Otherwise the
**  records are compared componentwise.
*/
UInt            LtRNam;                 /* '<' record name                 */

Int             LtPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;         /* method                          */
    UInt                i;              /* loop variable                   */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, LtRNam ))
      && ! (method = MethodPRec( left,  LtRNam )) ) {

        /* quick first checks                                              */
        if ( TYPE_OBJ(left ) < TYPE_OBJ(right) )  return 1L;
        if ( TYPE_OBJ(left ) > TYPE_OBJ(right) )  return 0L;

        /* sort both records                                               */
        SortPRec( left );
        SortPRec( right );

        /* compare componentwise                                           */
        for ( i = 1; i <= LEN_PREC(right); i++ ) {

            /* if the left is a proper prefix of the right one             */
            if ( LEN_PREC(left) < i )  return 1L;

            /* compare the names                                           */
            if ( GET_RNAM_PREC(left,i) != GET_RNAM_PREC(right,i) ) {
                if ( SyStrcmp( NAME_RNAM( GET_RNAM_PREC(left,i) ),
                               NAME_RNAM( GET_RNAM_PREC(right,i) ) ) < 0 ) {
                    return 1L;
                }
                else {
                    return 0L;
                }
            }

            /* compare the values                                          */
            if ( ! EQ(GET_ELM_PREC(left,i),GET_ELM_PREC(right,i)) ) {
                return LT( GET_ELM_PREC(left,i), GET_ELM_PREC(right,i) );
            }

        }

        /* the records are equal or the right is a prefix of the left      */
        return 0L;

    }

    /* call that function                                                  */
    return (CALL_2ARGS( method, left, right ) == True);
}


/****************************************************************************
**
*F  InPRec(<left>,<right>)  . . . . . . . . . . . membership test for records
**
**  'InRec' returns 'True' if the operand <left>  is an element of the record
**  <right>.  <right> must be a plain record.
**
**  If <right> has  a '.operations.\in' method, than this  is called  and its
**  result is returned.  Otherwise an error is signalled.
*/
UInt            InRNam;                 /* 'in' record name                */

Int             InPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;         /* method                          */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, InRNam )) ) {
        method = ErrorReturnObj(
            "Record: right operand must have '~.operations.\\in'",
            0L, 0L,
            "you can return a function for '~.operations.\\in'" );
    }

    /* call that function                                                  */
    return (CALL_2ARGS( method, left, right ) == True);
}


/****************************************************************************
**
*F  SumPRec(<left>,<right>) . . . . . . . . . . . . . . .  sum of two records
**
**  'SumRec' returns the  sum  of the two   operands <left> and <right>.   At
**  least one of the operands must be a plain record.
**
**  If  at least one of the  operands is a  record and has a '.operations.\+'
**  method, than this  is called and its  result  is returned.   Otherwise an
**  error is signalled.
*/
UInt            SumRNam;                /* '+' record name                 */

Obj             SumPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;         /* method                          */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, SumRNam ))
      && ! (method = MethodPRec( left,  SumRNam )) ) {
        method = ErrorReturnObj(
            "Record: one operand must have '~.operations.\\+'",
            0L, 0L,
            "you can return a function for '~.operations.\\+'" );
    }

    /* call that function                                                  */
    return CALL_2ARGS( method, left, right );
}


/****************************************************************************
**
*F  DiffPRec(<left>,<right>)  . . . . . . . . . . . difference of two records
**
**  'DiffRec' returns the difference of the two  operands <left> and <right>.
**  At least one of the operands must be a plain record.
**
**  If  at least one  of the operands is  a record and has a '.operations.\-'
**  method, then this  is called  and  its result is returned.   Otherwise an
**  error is signalled.
*/
UInt            DiffRNam;               /* '-' record name                 */

Obj             DiffPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;           /* operation                       */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, DiffRNam ))
      && ! (method = MethodPRec( left,  DiffRNam )) ) {
        method = ErrorReturnObj(
            "Record: one operand must have '~.operations.\\-'",
            0L, 0L,
            "you can return a function for '~.operations.\\-'" );
    }

    /* call that function                                                  */
    return CALL_2ARGS( method, left, right );
}


/****************************************************************************
**
*F  ProdPRec(<left>,<right>)  . . . . . . . . . . . .  product of two records
**
**  'ProdRec' returns the product of the two operands <left> and <right>.  At
**  least one of the operands must be a plain record.
**
**  If  at least one  of the operands is  a record and has a '.operations.\*'
**  method, then this  is called  and  its result is returned.   Otherwise an
**  error is signalled.
*/
UInt            ProdRNam;               /* '*' record name                 */

Obj             ProdPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;         /* method                          */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, ProdRNam ))
      && ! (method = MethodPRec( left,  ProdRNam )) ) {
        method = ErrorReturnObj(
            "Record: one operand must have '~.operations.\\*'",
            0L, 0L,
            "you can return a function for '~.operations.\\*'" );
    }

    /* call that function                                                  */
    return CALL_2ARGS( method, left, right );
}


/****************************************************************************
**
*F  QuoPRec(<left>,<right>) . . . . . . . . . . . . . quotient of two records
**
**  'QuoRec' returns the quotient of the two operands <left> and <right>.  At
**  least one of the operands must be a plain record.
**
**  If  at least one  of the operands is  a record and has a '.operations.\/'
**  method, then this  is called  and  its result is returned.   Otherwise an
**  error is signalled.
*/
UInt            QuoRNam;                /* '/' record name                 */

Obj             QuoPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;         /* method                          */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, QuoRNam ))
      && ! (method = MethodPRec( left,  QuoRNam )) ) {
        method = ErrorReturnObj(
            "Record: one operand must have '~.operations.\\/'",
            0L, 0L,
            "you can return a function for '~.operations.\\/'" );
    }

    /* call that function                                                  */
    return CALL_2ARGS( method, left, right );
}


/****************************************************************************
**
*F  LQuoPRec(<left>,<right>)  . . . . . . . . .  left quotient of two records
**
**  'LQuoPRec' returns the   left quotient  of  the two   operands <left> and
**  <right>.  At least one of the operands must be a plain record.
**
**  If  at   least   one   of  the  operands     is a  record   and    has  a
**  '.operations.LeftQuotient' method, then this is  called and its result is
**  returned.  Otherwise an error is signalled.
*/
UInt            LQuoRNam;               /* 'LeftQuotient' record name      */

Obj             LQuoPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;         /* method                          */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, LQuoRNam ))
      && ! (method = MethodPRec( left,  LQuoRNam )) ) {
        method = ErrorReturnObj(
            "Record: one operand must have '~.operations.LeftQuotient'",
            0L, 0L,
            "you can return a function for '~.operations.LeftQuotient'" );
    }

    /* call that function                                                  */
    return CALL_2ARGS( method, left, right );
}


/****************************************************************************
**
*F  PowPRec(<left>,<right>) . . . . . . . . . . . . . .  power of two records
**
**  'PowPRec' returns the power of  the two operands  <left> and <right>.  At
**  least one of the operands must be a plain record.
**
**  If  at least one  of the operands is  a record and has a '.operations.\^'
**  method, then this  is called  and  its result is returned.   Otherwise an
**  error is signalled.
*/
UInt            PowRNam;                /* '^' record name                 */

Obj             PowPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;         /* method                          */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, PowRNam ))
      && ! (method = MethodPRec( left,  PowRNam )) ) {
        method = ErrorReturnObj(
            "Record: one operand must have '~.operations.\\^'",
            0L, 0L,
            "you can return a function for '~.operations.\\^'" );
    }

    /* call that function                                                  */
    return CALL_2ARGS( method, left, right );
}


/****************************************************************************
**
*F  CommPRec(<left>,<right>)  . . . . . . . . . .   commutator of two records
**
**  'CommPRec' returns the commutator of the two operands <left> and <right>.
**  At least one of the operands must be a plain record.
**
**  If at least one of the operands is  a record and has a '.operations.Comm'
**  method, then this  is called and its  result  is returned.  Otherwise  an
**  error is signalled.
*/
UInt            CommRNam;               /* 'Comm' record name              */

Obj             CommPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;         /* method                          */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, CommRNam ))
      && ! (method = MethodPRec( left,  CommRNam )) ) {
        method = ErrorReturnObj(
            "Record: one operand must have '~.operations.Comm'",
            0L, 0L,
            "you can return a function for '~.operations.Comm'" );
    }

    /* call that function                                                  */
    return CALL_2ARGS( method, left, right );
}


/****************************************************************************
**
*F  ModPRec(<left>,<right>) . . . . . . . . . . . .  remainder of two records
**
**  'ModPRec' returns the   remainder  the operands  <left>   by  the operand
**  <right>.  At least one of the operands must be a plain record.
**
**  If at least one of the operands is a  record and has a '.operations.\mod'
**  method, then this  is  called and its  result is  returned.  Otherwise an
**  error is signalled.
*/
UInt            ModRNam;                /* 'mod' record name               */

Obj             ModPRec (
    Obj                 left,
    Obj                 right )
{
    Obj                 method;         /* method                          */

    /* try to find an applicable method                                    */
    if ( ! (method = MethodPRec( right, ModRNam ))
      && ! (method = MethodPRec( left,  ModRNam )) ) {
        method = ErrorReturnObj(
            "Record: one operand must have '~.operations.\\mod'",
            0L, 0L,
            "you can return a function for '~.operations.\\mod'" );
    }

    /* call that function                                                  */
    return CALL_2ARGS( method, left, right );
}


/****************************************************************************
**
*F  FuncRecNames(<self>,<rec>)  . . . . . . . . . .  record names of a record
**
**  'FuncRecNames' implements the function 'RecNames'.
**
**  'RecNames( <rec> )'
**
**  'RecNames'  returns a list containing the  names of the components of the
**  record <rec> as strings.
*/
Obj             RecNamesFunc;

Obj             RecNamesHandler (
    Obj                 self,
    Obj                 rec )
{
    Obj                 list;           /* list of record names, result    */
    UInt                rnam;           /* one name of record              */
    Obj                 string;         /* one name as string              */
    UInt                i;              /* loop variable                   */

    /* check the argument                                                  */
    while ( TYPE_OBJ(rec) != T_PREC &&
	    TYPE_OBJ(rec) != T_PREC + IMMUTABLE ) {
        rec = ErrorReturnObj(
            "RecNames: <rec> must be a record (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(rec)].name), 0L,
            "you can return a record for <rec>" );
    }

    /* allocate the list                                                   */
    list = NEW_PLIST( T_PLIST, LEN_PREC(rec) );
    SET_LEN_PLIST( list, LEN_PREC(rec) );

    /* loop over the components                                            */
    for ( i = 1; i <= LEN_PREC(rec); i++ ) {
        rnam = GET_RNAM_PREC( rec, i );
        string = NEW_STRING( SyStrlen(NAME_RNAM(rnam)) );
        SyStrncat( CSTR_STRING(string), NAME_RNAM(rnam),
                   SyStrlen(NAME_RNAM(rnam)) );
        SET_ELM_PLIST( list, i, string );
        CHANGED_BAG( list );
    }

    /* return the list                                                     */
    return list;
}


/****************************************************************************
**
*F  InitPRecord() . . . . . . . . . . . . . . . . . initialize record package
**
**  'InitPRecord' initializes the record package.
*/
void            InitPRecord ( void )
{
    UInt                i;              /* loop variable                   */

    /* install the marking function                                        */
    InfoBags[         T_PREC                     ].name
        = "record (plain)";
    InitMarkFuncBags( T_PREC                     , MarkAllSubBags );
    InfoBags[         T_PREC +IMMUTABLE          ].name
        = "record (plain,immutable)";
    InitMarkFuncBags( T_PREC +IMMUTABLE          , MarkAllSubBags );
    InfoBags[         T_PREC            +COPYING ].name
        = "record (plain,copied)";
    InitMarkFuncBags( T_PREC            +COPYING , MarkAllSubBags );
    InfoBags[         T_PREC +IMMUTABLE +COPYING ].name
        = "record (plain,immutable,copied)";
    InitMarkFuncBags( T_PREC +IMMUTABLE +COPYING , MarkAllSubBags );

    /* install into record function tables                                 */
    ElmRecFuncs[ T_PREC            ] = ElmPRec;
    ElmRecFuncs[ T_PREC +IMMUTABLE ] = ElmPRec;
    IsbRecFuncs[ T_PREC            ] = IsbPRec;    
    IsbRecFuncs[ T_PREC +IMMUTABLE ] = IsbPRec;    
    AssRecFuncs[ T_PREC            ] = AssPRec;
    AssRecFuncs[ T_PREC +IMMUTABLE ] = AssPRecImm;
    UnbRecFuncs[ T_PREC            ] = UnbPRec;
    UnbRecFuncs[ T_PREC +IMMUTABLE ] = UnbPRecImm;

    /* install the kind function                                           */
    InitCopyGVar( GVarName("KIND_PREC_MUTABLE"),   &KIND_PREC_MUTABLE );
    InitCopyGVar( GVarName("KIND_PREC_IMMUTABLE"), &KIND_PREC_IMMUTABLE  );
    KindObjFuncs[ T_PREC            ] = KindPRecMut;
    KindObjFuncs[ T_PREC +IMMUTABLE ] = KindPRecImm;

    /* install mutability test                                             */
    IsMutableObjFuncs[  T_PREC            ] = IsMutablePRecYes;
    IsMutableObjFuncs[  T_PREC +IMMUTABLE ] = IsMutablePRecNo;
    IsCopyableObjFuncs[ T_PREC            ] = IsCopyablePRecYes;
    IsCopyableObjFuncs[ T_PREC +IMMUTABLE ] = IsCopyablePRecYes;

    /* install into copy function tables                                  */
    CopyObjFuncs [ T_PREC                     ] = CopyPRec;
    CopyObjFuncs [ T_PREC +IMMUTABLE          ] = CopyPRec;
    CopyObjFuncs [ T_PREC            +COPYING ] = CopyPRecCopy;
    CopyObjFuncs [ T_PREC +IMMUTABLE +COPYING ] = CopyPRecCopy;
    CleanObjFuncs[ T_PREC                     ] = CleanPRec;
    CleanObjFuncs[ T_PREC +IMMUTABLE          ] = CleanPRec;
    CleanObjFuncs[ T_PREC            +COPYING ] = CleanPRecCopy;
    CleanObjFuncs[ T_PREC +IMMUTABLE +COPYING ] = CleanPRecCopy;

    /* install printer                                                     */
    PrintObjFuncs[  T_PREC            ] = PrintPRec;
    PrintObjFuncs[  T_PREC +IMMUTABLE ] = PrintPRec;
    PrintPathFuncs[ T_PREC            ] = PrintPathPRec;
    PrintPathFuncs[ T_PREC +IMMUTABLE ] = PrintPathPRec;

    /* install evaluators                                                  */
    for ( i = FIRST_REAL_TYPE; i <= LAST_VIRTUAL_TYPE; i++ ) {
        if ( i < FIRST_EXTERNAL_TYPE || LAST_EXTERNAL_TYPE < i ) {
            EqFuncs  [ i                 ][ T_PREC            ] = EqPRec;
            EqFuncs  [ i                 ][ T_PREC +IMMUTABLE ] = EqPRec;
            EqFuncs  [ T_PREC            ][ i                 ] = EqPRec;
            EqFuncs  [ T_PREC +IMMUTABLE ][ i                 ] = EqPRec;
            LtFuncs  [ i                 ][ T_PREC            ] = LtPRec;
            LtFuncs  [ i                 ][ T_PREC +IMMUTABLE ] = LtPRec;
            LtFuncs  [ T_PREC            ][ i                 ] = LtPRec;
            LtFuncs  [ T_PREC +IMMUTABLE ][ i                 ] = LtPRec;
            InFuncs  [ i                 ][ T_PREC            ] = InPRec;
            InFuncs  [ i                 ][ T_PREC +IMMUTABLE ] = InPRec;
            SumFuncs [ i                 ][ T_PREC            ] = SumPRec;
            SumFuncs [ i                 ][ T_PREC +IMMUTABLE ] = SumPRec;
            SumFuncs [ T_PREC            ][ i                 ] = SumPRec;
            SumFuncs [ T_PREC +IMMUTABLE ][ i                 ] = SumPRec;
            DiffFuncs[ i                 ][ T_PREC            ] = DiffPRec;
            DiffFuncs[ i                 ][ T_PREC +IMMUTABLE ] = DiffPRec;
            DiffFuncs[ T_PREC            ][ i                 ] = DiffPRec;
            DiffFuncs[ T_PREC +IMMUTABLE ][ i                 ] = DiffPRec;
            ProdFuncs[ i                 ][ T_PREC            ] = ProdPRec;
            ProdFuncs[ i                 ][ T_PREC +IMMUTABLE ] = ProdPRec;
            ProdFuncs[ T_PREC            ][ i                 ] = ProdPRec;
            ProdFuncs[ T_PREC +IMMUTABLE ][ i                 ] = ProdPRec;
            QuoFuncs [ i                 ][ T_PREC            ] = QuoPRec;
            QuoFuncs [ i                 ][ T_PREC +IMMUTABLE ] = QuoPRec;
            QuoFuncs [ T_PREC            ][ i                 ] = QuoPRec;
            QuoFuncs [ T_PREC +IMMUTABLE ][ i                 ] = QuoPRec;
            LQuoFuncs[ i                 ][ T_PREC            ] = LQuoPRec;
            LQuoFuncs[ i                 ][ T_PREC +IMMUTABLE ] = LQuoPRec;
            LQuoFuncs[ T_PREC            ][ i                 ] = LQuoPRec;
            LQuoFuncs[ T_PREC +IMMUTABLE ][ i                 ] = LQuoPRec;
            PowFuncs [ i                 ][ T_PREC            ] = PowPRec;
            PowFuncs [ i                 ][ T_PREC +IMMUTABLE ] = PowPRec;
            PowFuncs [ T_PREC            ][ i                 ] = PowPRec;
            PowFuncs [ T_PREC +IMMUTABLE ][ i                 ] = PowPRec;
            CommFuncs[ i                 ][ T_PREC            ] = CommPRec;
            CommFuncs[ i                 ][ T_PREC +IMMUTABLE ] = CommPRec;
            CommFuncs[ T_PREC            ][ i                 ] = CommPRec;
            CommFuncs[ T_PREC +IMMUTABLE ][ i                 ] = CommPRec;
            ModFuncs [ i                 ][ T_PREC            ] = ModPRec;
            ModFuncs [ i                 ][ T_PREC +IMMUTABLE ] = ModPRec;
            ModFuncs [ T_PREC            ][ i                 ] = ModPRec;
            ModFuncs [ T_PREC +IMMUTABLE ][ i                 ] = ModPRec;
        }
    }

    /* get the appropriate record record name                              */
    OperationsRNam = RNamName( "operations"   );
    PrintRNam      = RNamName( "Print"        );
    EqRNam         = RNamName( "="            );
    LtRNam         = RNamName( "<"            );
    InRNam         = RNamName( "in"           );
    SumRNam        = RNamName( "+"            );
    DiffRNam       = RNamName( "-"            );
    ProdRNam       = RNamName( "*"            );
    QuoRNam        = RNamName( "/"            );
    LQuoRNam       = RNamName( "LeftQuotient" );
    PowRNam        = RNamName( "^"            );
    CommRNam       = RNamName( "Comm"         );
    ModRNam        = RNamName( "mod"          );

    /* install the internal functions                                      */
    RecNamesFunc = NewFunctionC(
        "REC_NAMES", 1L, "rec", RecNamesHandler );
    AssGVar( GVarName( "REC_NAMES" ), RecNamesFunc );

}


/****************************************************************************
**
*E  precord.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



