/***************************************************************************
**
*W  sortbase.h                  GAP source
**
*Y  Copyright (C) 2015 The GAP Group
**
**  WARNING: This file should NOT be directly included. It is designed
**  to build all of the sort variants which GAP uses.
**
**
** This file provides a framework for expressing sort functions in a generic
** way, covering various options (provide comparator, optimised for Plists,
** and do SortParallel
**
** The following macros are used:
** SORT_FUNC_NAME        : Name of function
** SORT_FUNC_ARGS        : Arguments of function
** SORT_CREATE_TEMP(t)   : Create a temp variable named t that can store
**                         an element of the list
** SORT_LEN_LIST         : Get the length of the list to be sorted
** SORT_ASS_LIST_TO_TEMP(t,i) : Copy list element 'i' to temporary 't'
** SORT_ASS_TEMP_TO_LIST(i,t) : Copy temporary 't' to list element 'i'
** SORT_COMP(v,w)             : Compare temporaries v and w
** SORT_FILTER_CHECKS         : Arbitary code to be called at end of function,
**                              to fix filters effected by the sorting.
*/

void SORT_FUNC_NAME(SORT_FUNC_ARGS)
{
    UInt                len;            /* length of the list              */
    UInt                h;              /* gap width in the shellsort      */
		SORT_CREATE_TEMP(v);
		SORT_CREATE_TEMP(w);
    UInt                i, k;           /* loop variables                  */

    /* sort the list with a shellsort                                      */
    len = SORT_LEN_LIST();
    h = 1;
    while ( 9*h + 4 < len ) { h = 3*h + 1; }
    while ( 0 < h ) {
        for ( i = h+1; i <= len; i++ ) {
            SORT_ASS_LIST_TO_TEMP( v, i );
            k = i;
            SORT_ASS_LIST_TO_TEMP( w, k-h );
            while ( h < k && SORT_COMP( v, w ) ) {
                SORT_ASS_TEMP_TO_LIST( k, w );
                k -= h;
                if ( h < k ) {
									SORT_ASS_LIST_TO_TEMP( w, k-h );
								}
            }
            SORT_ASS_TEMP_TO_LIST( k, v );
        }
        h = h / 3;
    }
		SORT_FILTER_CHECKS();
}

#undef SORT_FUNC_NAME
#undef SORT_FUNC_ARGS
#undef SORT_CREATE_TEMP
#undef SORT_LEN_LIST
#undef SORT_ASS_LIST_TO_TEMP
#undef SORT_ASS_TEMP_TO_LIST
#undef SORT_COMP
#undef SORT_FILTER_CHECKS
