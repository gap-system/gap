/****************************************************************************
**
*W  utils.c                     XGAP Source                      Frank Celler
**
*H  @(#)$Id: utils.c,v 1.2 1997/12/05 17:31:08 frank Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
**
**  This  file contains the  utility  functions  and  macros  used in   XGAP,
**  basically  the list functions  ('ELM', 'LEN',  'AddList', and 'List') and
**  the  debug  macro ('DEBUG').  This  file also  includes all the necessary
**  system and X11 include files and defines the following data types:
**
**      Boolean         "True" or "False" (defined by X11)
**      Char            a "Char" will be able to hold one character
**      Int             a 32-bit signed integer
**      Long            an integer able to hold a pointer
**      Pointer         a generic pointer
**      Short           a 16-bit signed integer
**      String          an array of chars
**      UChar           unsigned version of "Char"
**      UInt            a 32-bit unsigned integer
**      ULong           unsigned version of "Long"
**      UShort          a 16-bit unsigned integer
**
**  List( <len> )
**  -------------
**  'List' creates a new list able to hold <len> pointers of type 'Pointer'.
**
**  AddList( <lst>, <elm> )
**  -----------------------
**  'AddList' appends  the  new  element  <elm> of type  'Pointer'  to <lst>,
**  enlarging the list if necessary.
**
**  ELM( <lst>, <i> )
**  -----------------
**  'ELM' returns the <i>.th element of <lst>.
**
**  LEN( <lst> )
**  ------------
**  'LEN' returns the length of <lst>.
**
**  DEBUG( <type>, ( <debug-text>, ... ) )
**  --------------------------------------
**  'DEBUG' uses 'printf' to print the  <debug-text> in case that  'Debug' &&
**  <type> is true.  The text  is preceded by the line number  and the source
**  file name.  The following types are available:  D_LIST, D_XCMD, D_COMM.
*/
#include    "utils.h"


/****************************************************************************
**

*V  Debug . . . . . . . . . . . . . . . . . . . . . . . . . . .  debug on/off
*/
Int Debug = 0;


/****************************************************************************
**
*F  List( <len> )   . . . . . . . . . . . . . . . . . . .   create a new list
*/
#ifdef DEBUG_ON
TypeList LIST ( file, line, len )
    String	file;
    Int         line;
    UInt        len;
#else
TypeList List ( len )
    UInt        len;
#endif
{
    TypeList    list;

    /* get memory for new list */
    list       = (TypeList) XtMalloc( sizeof( struct _list ) );
    list->len  = len;
    list->size = len+10;
    list->ptr  = (Pointer) XtMalloc( list->size * sizeof(Pointer) );

    /* give some debug information */
#ifdef DEBUG_ON
    if ( Debug & D_LIST )
	printf( "%04d:%s: List(%d)=%p\n", line, file, len, (void*)list );
#endif

    /* return the new list */
    return list;
}


/****************************************************************************
**
*F  AddList( <lst>, <elm> ) . . . . . . . .  add list element <elm> to <list>
*/
#ifdef DEBUG_ON
void ADD_LIST ( file, line, lst, elm )
    String	file;
    Int         line;
    TypeList    lst;
    Pointer     elm;
#else
void AddList ( lst, elm )
    TypeList    lst;
    Pointer     elm;
#endif
{
    /* give some debug information */
#ifdef DEBUG_ON
    if ( Debug & D_LIST )
	printf( "%04d:%s: AddList( %p, %p )\n", line, file, (void*)lst,
	        (void*)elm );
#endif

    /* resize <lst> if necessary */
    if ( lst->len == lst->size )
    {
        lst->size = lst->size*4/3 + 5;
        lst->ptr  = (Pointer) XtRealloc( (char*) lst->ptr,
                                         lst->size * sizeof(Pointer) );
    }

    /* and add list element */
    lst->ptr[lst->len++] = elm;
}


/****************************************************************************
**

*E  utils.c . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
