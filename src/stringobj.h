/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions which mainly deal with strings.
**
**  A *string* is a  list that  has no  holes, and  whose  elements  are  all
**  characters.  For the full definition of strings see chapter  "Strings" in
**  the {\GAP} manual.  Read also "More about Strings" about the  string flag
**  and the compact representation of strings.
**
**  Strings in compact representation  can be accessed and handled through
**  the functions 'NEW_STRING', 'CHARS_STRING' (and 'CSTR_STRING'),
**  'GET_LEN_STRING', 'SET_LEN_STRING', 'GROW_STRING' and more.
*/

#ifndef GAP_STRINGOBJ_H
#define GAP_STRINGOBJ_H

#include "objects.h"

#include <string.h>


/****************************************************************************
**
*F * * * * * * * * * * * * * * character functions  * * * * * * * * * * * * *
*/


/****************************************************************************
**
*V  ObjsChar[<chr>] . . . . . . . . . . . . . . . . table of character values
**
**  'ObjsChar' contains all the character values.  That way we do not need to
**  allocate new bags for new characters.
*/
extern Obj ObjsChar[256];


/****************************************************************************
**
*F  CHAR_VALUE( <charObj> )
*/
EXPORT_INLINE UChar CHAR_VALUE(Obj charObj)
{
    GAP_ASSERT(TNUM_OBJ(charObj) == T_CHAR);
    return *(const UChar *)CONST_ADDR_OBJ(charObj);
}


/****************************************************************************
**
*F  SET_CHAR_VALUE( <charObj>, <c> )
*/
EXPORT_INLINE void SET_CHAR_VALUE(Obj charObj, UChar c)
{
    GAP_ASSERT(TNUM_OBJ(charObj) == T_CHAR);
    *(UChar *)ADDR_OBJ(charObj) = c;
}


/****************************************************************************
**
*F  SINT_CHAR(a)
**
**  'SINT_CHAR' converts the character a (a UInt1) into a signed (C) integer.
*/
EXPORT_INLINE Int SINT_CHAR(UInt1 a)
{
    return a < 128 ? (Int)a : (Int)a-256;
}


/****************************************************************************
**
*F  CHAR_SINT(n)
**
**  'CHAR_SINT' converts the signed (C) integer n into an (UInt1) character.
*/
EXPORT_INLINE UInt1 CHAR_SINT(Int n)
{
    return (UInt1)(n >= 0 ? n : n+256);
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * * string functions * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  IS_STRING_REP( <list> ) . . . . . . . .  check if <list> is in string rep
*/
EXPORT_INLINE BOOL IS_STRING_REP(Obj list)
{
    return (T_STRING <= TNUM_OBJ(list) &&
            TNUM_OBJ(list) <= T_STRING_SSORT + IMMUTABLE);
}


/****************************************************************************
**
*F  SIZEBAG_STRINGLEN( <len> ) . . . . size of Bag for string of length <len>
**
*/
EXPORT_INLINE UInt SIZEBAG_STRINGLEN(UInt len)
{
    return len + 1 + sizeof(UInt);
}

/****************************************************************************
**
*F  CSTR_STRING( <list> ) . . . . . . . . . . . . . . .  C string of a string
*F  CHARS_STRING( <list> ) . . . . . . . . . . . . . .   same pointer
**
**  'CSTR_STRING'  returns the (address  of the)  C  character string of  the
**  string <list>. 'CHARS_STRING' is the same, but returns a pointer to an
**  unsigned char.
**
**  Remember that GAP strings can contain embedded NULLs, so do not assume
**  the string stops at the first null character, instead use
**  GET_LEN_STRING.
*/

EXPORT_INLINE Char * CSTR_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    return (Char *)ADDR_OBJ(list) + sizeof(UInt);
}

EXPORT_INLINE const Char * CONST_CSTR_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    return (const Char *)CONST_ADDR_OBJ(list) + sizeof(UInt);
}

EXPORT_INLINE UChar * CHARS_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    return (UChar *)ADDR_OBJ(list) + sizeof(UInt);
}

EXPORT_INLINE const UChar * CONST_CHARS_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    return (const UChar *)CONST_ADDR_OBJ(list) + sizeof(UInt);
}

/****************************************************************************
**
*F  GET_LEN_STRING( <list> )  . . . . . . . . . . . . . .  length of a string
**
**  'GET_LEN_STRING' returns the length of the string <list>, as a C integer.
*/

EXPORT_INLINE UInt GET_LEN_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    return INT_INTOBJ(CONST_ADDR_OBJ(list)[0]);
}

/****************************************************************************
**
*F  SET_LEN_STRING( <list>, <len> ) . . . . . . . . . set length of a string
**
**  'SET_LEN_STRING' sets length of the string <list> to C integer <len>.
*/

EXPORT_INLINE void SET_LEN_STRING(Obj list, Int len)
{
    GAP_ASSERT(IS_STRING_REP(list));
    GAP_ASSERT(len >= 0);
    GAP_ASSERT(SIZEBAG_STRINGLEN(len) <= SIZE_OBJ(list));
    ADDR_OBJ(list)[0] = INTOBJ_INT(len);
}

/****************************************************************************
**
*F  NEW_STRING( <len> ) . . . . . . . . . . . . . . . . . . make a new string
**
**  'NEW_STRING' returns a new string with room for <len> characters. It also
**  sets its length to len. 
**
*/
Obj NEW_STRING(Int len);

/****************************************************************************
**
*F  GROW_STRING(<list>, <len>) . . . .  make sure a string is large enough
**
**  'GROW_STRING' grows  the string <list>  if necessary to ensure that it
**  has room for at least <len> elements.
**
*/

Int GrowString(Obj list, UInt need);

EXPORT_INLINE void GROW_STRING(Obj list, Int len)
{
    GAP_ASSERT(IS_STRING_REP(list));
    GAP_ASSERT(len >= 0);
    if (SIZEBAG_STRINGLEN(len) > SIZE_OBJ(list)) {
        GrowString(list, len);
    }
}

/****************************************************************************
**
*F  SHRINK_STRING(<list>) . . . . . . . . .  shrink a string to minimal size
**
**  'SHRINK_STRING' gives back not needed memory allocated by string.
*/
EXPORT_INLINE void SHRINK_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    ResizeBag(list, SIZEBAG_STRINGLEN(GET_LEN_STRING((list))));
}

/****************************************************************************
**
*F  COPY_CHARS( <str>, <charpnt>, <n> ) . . . copies <n> chars, starting
**  from character pointer <charpnt>, to beginning of string
**
**  It assumes that the data area in <str> is large enough. It does not add
**  a terminating null character and not change the length of the string.
*/
EXPORT_INLINE void COPY_CHARS(Obj str, const UChar * pnt, Int n)
{
    GAP_ASSERT(IS_STRING_REP(str));
    GAP_ASSERT(n >= 0);
    GAP_ASSERT(SIZEBAG_STRINGLEN(n) <= SIZE_OBJ(str));
    memcpy(CHARS_STRING(str), pnt, n);
}

/****************************************************************************
**
*F  PrintString( <list> ) . . . . . . . . . . . . . . . . . .  print a string
**
**  'PrintString' prints the string with the handle <list>.
**
**  No  linebreaks are allowed,  if one must be  inserted  anyhow, it must be
**  escaped by a backslash '\', which is done in 'Pr'.
*/
void PrintString(Obj list);


/****************************************************************************
**
*F  PrintString1( <list> )  . . . . . . . . . . .  print a string for 'Print'
**
**  'PrintString1' prints the string  constant  in  the  format  used  by  the
**  'Print' and 'PrintTo' function.
*/
void PrintString1(Obj list);


/****************************************************************************
**
*F  IS_STRING( <obj> )  . . . . . . . . . . . . test if an object is a string
**
**  'IS_STRING' returns 1  if the object <obj>  is a string  and 0 otherwise.
**  It does not change the representation of <obj>.
*/
extern BOOL (*IsStringFuncs[LAST_REAL_TNUM + 1])(Obj obj);

EXPORT_INLINE BOOL IS_STRING(Obj obj)
{
    return (*IsStringFuncs[TNUM_OBJ(obj)])(obj);
}


/****************************************************************************
**
*F  IsString( <obj> ) . . . . . . . . . . . . . test if an object is a string
**
**  'IsString' returns 1 if the object <obj> is a string and 0 otherwise.  It
**  does not change the representation of <obj>.
*/
BOOL IsString(Obj obj);


/****************************************************************************
**
*F  CopyToStringRep( <string> ) . . .  copy a string to string representation
**
**  'CopyToStringRep' copies the string <string> to a new mutable string in
**  string representation.
*/
Obj CopyToStringRep(Obj string);


/****************************************************************************
**
*F  ImmutableString( <string> ) . . . copy to immutable string in string rep.
**
**  'ImmutableString' returns an immutable string in string representation
**  equal to <string>. This may return <string> if it already satisfies these
**  criteria.
*/
Obj ImmutableString(Obj string);


/****************************************************************************
**
*F  ConvString( <string> ) . . . .  convert a string to string representation
**
**  'ConvString' converts the string <string> to string representation.
*/
void ConvString(Obj string);


/****************************************************************************
**
*F  IsStringConv( <obj> ) . . . . . test if an object is a string and convert
**
**  'IsStringConv'   returns 1  if   the object <obj>  is   a  string,  and 0
**  otherwise.   If <obj> is a  string it  changes  its representation to the
**  string representation.
*/
BOOL IsStringConv(Obj obj);


// Functions to create mutable and immutable GAP strings from C strings.
// MakeString and MakeImmString are inlineable so 'strlen' can be optimised
// away for constant strings.

EXPORT_INLINE Obj MakeStringWithLen(const char * buf, size_t len)
{
    Obj result = NEW_STRING(len);
    memcpy(CHARS_STRING(result), buf, len);
    return result;
}

EXPORT_INLINE Obj MakeString(const char * cstr)
{
    return MakeStringWithLen(cstr, strlen(cstr));
}

EXPORT_INLINE Obj MakeImmString(const char * cstr)
{
    Obj result = MakeString(cstr);
    MakeImmutableNoRecurse(result);
    return result;
}

EXPORT_INLINE Obj MakeImmStringWithLen(const char * buf, size_t len)
{
    Obj result = MakeStringWithLen(buf, len);
    MakeImmutableNoRecurse(result);
    return result;
}


/****************************************************************************
**
*F  C_NEW_STRING( <string>, <len>, <cstring> )  . . . . . . create GAP string
**
**  This macro is deprecated and only provided for backwards compatibility
**  with some package kernel extensions. Use 'MakeStringWithLen' and
**  'MakeImmStringWithLen' instead.
*/
#define C_NEW_STRING(string,len,cstr) \
    string = MakeStringWithLen( (cstr), (len) )


/****************************************************************************
**
*F  AppendCStr( <str>, <buf>, <len> ) . . append data in a buffer to a string
**
**  'AppendCStr' appends <len> bytes of data taken from <buf> to <str>, where
**  <str> must be a mutable GAP string object.
*/
void AppendCStr(Obj str, const char * buf, UInt len);


/****************************************************************************
**
*F  AppendString( <str1>, <str2> ) . . . . . . . append one string to another
**
**  'AppendString' appends <str2> to the end of <str1>. Both <str1> and <str>
**  must be a GAP string objects, and <str1> must be mutable.
*/
void AppendString(Obj str1, Obj str2);


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoString()  . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoString ( void );


#endif // GAP_STRINGOBJ_H
