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
#include "permutat.h"


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
    if ( TYPE_OBJ(list) == T_POSOBJ ) {
        ErrorQuit( "sorry: <posobj>!{<poss>} not yet implemented", 0L, 0L );
    }
    else {
        ASSS_LIST( list, poss, rhss );
    }
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


Obj Array2Perm (
    Obj			array )
{
    Obj                 perm;           /* permutation, result             */
    UInt4 *             ptr4;           /* pointer into perm               */
    UInt2 *             ptr2;           /* pointer into perm               */
    Obj                 val;            /* one entry as value              */
    UInt                c, p, l;        /* entries in permutation          */
    UInt                m;              /* maximal entry in permutation    */
    Obj                 cycle;          /* one cycle of permutation        */
    UInt                i, j, k;        /* loop variable                   */

    /* special case for identity permutation                               */
    if ( LEN_LIST(array) == 0 ) {
        return IdentityPerm;
    }

    /* allocate the new permutation                                        */
    m = 0;
    perm = NEW_PERM4( 0 );

    /* loop over the cycles                                                */
    for ( i = 1; i <= LEN_LIST(array); i++ ) {
        cycle = ELM_LIST( array, i );
	while ( ! IS_LIST(cycle) ) {
	    cycle = ErrorReturnObj(
	        "Arra2Perm: <cycle> must be a list (not a %s)",
		(Int)(InfoBags[TYPE_OBJ(cycle)].name), 0L,
		"you can return a list" );
	}

        /* loop over the entries of the cycle                              */
        c = p = l = 0;
        for ( j = LEN_LIST(cycle); 1 <= j; j-- ) {

            /* get and check current entry for the cycle                   */
            val = ELM_LIST( cycle, j );
            while ( ! IS_INTOBJ(val) || INT_INTOBJ(val) <= 0 ) {
                val = ErrorReturnObj(
              "Permutation: <expr> must be a positive integer (not to a %s)",
                    (Int)(InfoBags[TYPE_OBJ(val)].name), 0L,
                    "you can return a positive integer" );
            }
            c = INT_INTOBJ(val);

            /* if necessary resize the permutation                         */
            if ( SIZE_OBJ(perm)/sizeof(UInt4) < c ) {
                ResizeBag( perm, (c + 1023) / 1024 * 1024 * sizeof(UInt4) );
                ptr4 = ADDR_PERM4( perm );
                for ( k = m+1; k <= SIZE_OBJ(perm)/sizeof(UInt4); k++ ) {
                    ptr4[k-1] = k-1;
                }
            }
            if ( m < c ) {
                m = c;
            }

            /* check that the cycles are disjoint                          */
            ptr4 = ADDR_PERM4( perm );
            if ( (p != 0 && p == c) || (ptr4[c-1] != c-1) ) {
                return ErrorReturnObj(
                    "Permutation: cycles must be disjoint",
                    0L, 0L,
                    "you can return a permutation" );
            }

            /* enter the previous entry at current location                */
            ptr4 = ADDR_PERM4( perm );
            if ( p != 0 ) { ptr4[c-1] = p-1; }
            else          { l = c;          }

            /* remember current entry for next round                       */
            p = c;
        }

        /* enter first (last popped) entry at last (first popped) location */
        ptr4 = ADDR_PERM4( perm );
        ptr4[l-1] = p-1;

    }

    /* if possible represent the permutation with short entries            */
    if ( m <= 65536UL ) {
        ptr2 = ADDR_PERM2( perm );
        ptr4 = ADDR_PERM4( perm );
        for ( k = 1; k <= m; k++ ) {
            ptr2[k-1] = ptr4[k-1];
        };
        RetypeBag( perm, T_PERM2 );
        ResizeBag( perm, m * sizeof(UInt2) );
    }

    /* otherwise just shorten the permutation                              */
    else {
        ResizeBag( perm, m * sizeof(UInt4) );
    }

    /* return the permutation                                              */
    return perm;
}



/****************************************************************************
**
*E  compiled.c  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/



