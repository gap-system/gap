/****************************************************************************
**
*W  compiled.c                  GAP source                   Martin Schoenert
**
**  This package defines macros and functions that are used by compiled code.
**  Those macros and functions should go into the appropriate packages.
*/

#include "system.h"
#include "gasman.h"
#include "objects.h"
#include "gvars.h"
#include "calls.h"
#include "ariths.h"
#include "records.h"
#include "lists.h"
#include "bool.h"
#include "integer.h"
#include "precord.h"
#include "plist.h"
#include "range.h"
#include "string.h"
#include "code.h"
#include "vars.h"
#include "gap.h"


/* checks, should go into 'gap.c'  * * * * * * * * * * * * * * * * * * * * */

void            ErrorQuitBound (
    Char *              name )
{
    ErrorQuit(
        "variable '%s' must have an assigned value",
        (Int)name, 0L );
}

void            ErrorQuitFuncResult ( void )
{
    ErrorQuit(
        "function must return a value",
        0L, 0L );
}

void            ErrorQuitIntSmall (
    Obj                 obj )
{
    ErrorQuit(
        "<obj> must be a small integer (not a %s)",
        (Int)(InfoBags[TYPE_OBJ(obj)].name), 0L );
}

void            ErrorQuitIntSmallPos (
    Obj                 obj )
{
    ErrorQuit(
        "<obj> must be a positive small integer (not a %s)",
        (Int)(InfoBags[TYPE_OBJ(obj)].name), 0L );
}

void            ErrorQuitBool (
    Obj                 obj )
{
    ErrorQuit(
        "<obj> must be 'true' or 'false' (not a %s)",
        (Int)(InfoBags[TYPE_OBJ(obj)].name), 0L );
}

void            ErrorQuitFunc (
    Obj                 obj )
{
    ErrorQuit(
        "<obj> must be a function (not a %s)",
        (Int)(InfoBags[TYPE_OBJ(obj)].name), 0L );
}

void            ErrorQuitNrArgs (
    Int                 narg,
    Obj                 args )
{
    ErrorQuit(
        "Function Calls: number of arguments must be %d (not %d)",
        narg, LEN_PLIST( args ) );
}


/* lists, should go into 'lists.c' * * * * * * * * * * * * * * * * * * * * */

Obj             ElmsListCheck (
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

void            ElmsListLevelCheck (
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

void            AsssListCheck (
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

void            AsssListLevelCheck (
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


/* ranges, should go into 'range.c'  * * * * * * * * * * * * * * * * * * * */

Obj             Range2Check (
    Obj                 first,
    Obj                 last )
{
    Obj                 range;
    Int                 f, l;
    if ( ! IS_INTOBJ(first) ) {
        ErrorQuit(
            "Range: <first> must be a positive small integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(first)].name), 0L );
    }
    f = INT_INTOBJ(first);
    if ( ! IS_INTOBJ(last) ) {
        ErrorQuit(
            "Range: <last> must be a positive small integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(last)].name), 0L );
    }
    l = INT_INTOBJ(last);
    if ( f > l ) {
        range = NEW_PLIST( T_PLIST, 0 );
        SET_LEN_PLIST( range, 0 );
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

Obj             Range3Check (
    Obj                 first,
    Obj                 second,
    Obj                 last )
{
    Obj                 range;
    Int                 f, i, l;
    if ( ! IS_INTOBJ(first) ) {
        ErrorQuit(
            "Range: <first> must be a positive small integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(first)].name), 0L );
    }
    f = INT_INTOBJ(first);
    if ( ! IS_INTOBJ(second) ) {
        ErrorQuit(
            "Range: <second> must be a positive small integer (not a %s)",
            (Int)(InfoBags[TYPE_OBJ(second)].name), 0L );
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
            (Int)(InfoBags[TYPE_OBJ(last)].name), 0L );
    }
    l = INT_INTOBJ(last);
    if ( (l - f) % i != 0 ) {
        ErrorQuit(
            "Range: <last>-<first> (%d) must be divisible by <inc> (%d)",
            (Int)(l - f), (Int)i );
    }
    if ( (0 < i && f > l) || (i < 0 && f < l) ) {
        range = NEW_PLIST( T_PLIST, 0 );
        SET_LEN_PLIST( range, 0 );
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
*E  compiled.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



