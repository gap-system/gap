/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares low-level functions dealing with C strings and
**  characters.
*/

#ifndef GAP_SYSSTR_H
#define GAP_SYSSTR_H

#include "common.h"

#include <ctype.h>
#include <string.h>

/****************************************************************************
**
*F  IsAlpha( <ch> ) . . . . . . . . . . . . .  is a character a normal letter
**
**  'IsAlpha' returns 1 if its character argument is a character from the
**  range 'a..zA..Z' and 0 otherwise.
*/
#define IsAlpha(ch) (isalpha((unsigned int)ch))


/****************************************************************************
**
*F  IsDigit( <ch> ) . . . . . . . . . . . . . . . . .  is a character a digit
**
**  'IsDigit' returns 1 if its character argument is a digit from  the  range
**  '0..9' and 0 otherwise.
*/
#define IsDigit(ch) (isdigit((unsigned int)ch))


/****************************************************************************
**
*F  IsIdent( <ch> ) . . . . . . . .  is a character valid in a GAP identifier
**
**  'IsIdent' returns 1 if its character argument can be used unquoted inside
**  a GAP identifier, i.e., is in the range 'a..zA..Z0-9_@', and 0 otherwise.
*/
EXPORT_INLINE BOOL IsIdent(char ch)
{
    return isalnum((unsigned int)ch) || ch == '_' || ch == '@';
}


/****************************************************************************
**
*F  streq( <s1>, <s2> ) . . . . . . . .  test whether two C strings are equal
**
**  'streq' is a simple wrapper around the standard C function 'strcmp', with
**  the advantage that code using it is often easier to understand for human
**  beings.
*/
EXPORT_INLINE BOOL streq(const char * s1, const char * s2)
{
    return 0 == strcmp(s1, s2);
}


/****************************************************************************
**
*F  gap_strlcpy( <dst>, <src>, <len> )
**
**  Copy <src> to buffer <dst> of size <len>. At most <len>-1 characters will
**  be copied. Afterwards, <dst> is always 'NUL' terminated
**  (unless <len> == 0).
**
**  Returns 'strlen( <src> )'; hence if the return value is greater or equal
**  than <len>, truncation occurred.
**
**  This function is provided by some systems (e.g. OpenBSD, Mac OS X),
**  but not by all, so we provide a fallback implementation for those
**  systems that lack it.
*/
size_t gap_strlcpy(char * dst, const char * src, size_t len);

/****************************************************************************
**
*F  gap_strlcat( <dst>, <src>, <len> )
**
**  Appends <src> to buffer <dst> of size <len> (unlike 'strncat', <len> is
**  the full size of <dst>, not space left).
**  At most <len>-1 characters will be copied.
**  Afterwards, <dst> is always 'NUL' terminated (unless <len> == 0).
**
**  Returns initial length of <dst> plus 'strlen(<src>)'; hence if the return
**  value is greater or equal than <len>, truncation occurred.
**
**  This function is provided by some systems (e.g. OpenBSD, Mac OS X),
**  but not by all, so we provide a fallback implementation for those
**  systems that lack it.
*/
size_t gap_strlcat(char * dst, const char * src, size_t len);

/****************************************************************************
**
*F  strxcpy( <dst>, <src>, <len> )
**
**  Copy <src> to buffer <dst> of size <len>.
**  If an overflow would occur, trigger an assertion.
**
**  This should be used with caution; in general, proper error handling is
**  preferable.
**/
size_t strxcpy(char * dst, const char * src, size_t len);

/****************************************************************************
**
*F  strxcat( <dst>, <src>, <len> )
**
**  Append <src> to buffer <dst> of size <len>.
**  If an overflow would occur, trigger an assertion.
**
**  This should be used with caution; in general, proper error handling is
**  preferable.
**/
size_t strxcat(char * dst, const char * src, size_t len);

#endif    // GAP_SYSSTR_H
