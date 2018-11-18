/****************************************************************************
**
*W  stringobj.h                 GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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
static inline UChar CHAR_VALUE(Obj charObj)
{
    GAP_ASSERT(TNUM_OBJ(charObj) == T_CHAR);
    return *(const UChar *)CONST_ADDR_OBJ(charObj);
}


/****************************************************************************
**
*F  SET_CHAR_VALUE( <charObj>, <c> )
*/
static inline void SET_CHAR_VALUE(Obj charObj, UChar c)
{
    GAP_ASSERT(TNUM_OBJ(charObj) == T_CHAR);
    *(UChar *)CONST_ADDR_OBJ(charObj) = c;
}


/****************************************************************************
**
*F  SINT_CHAR(a)
**
**  'SINT_CHAR' converts the character a (a UInt1) into a signed (C) integer.
*/
static inline Int SINT_CHAR(UInt1 a)
{
    return a < 128 ? (Int)a : (Int)a-256;
}


/****************************************************************************
**
*F  CHAR_SINT(n)
**
**  'CHAR_SINT' converts the signed (C) integer n into an (UInt1) character.
*/
static inline UInt1 CHAR_SINT(Int n)
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
static inline Int IS_STRING_REP(Obj list)
{
    return (T_STRING <= TNUM_OBJ(list) &&
            TNUM_OBJ(list) <= T_STRING_SSORT + IMMUTABLE);
}


/****************************************************************************
**
*F  SIZEBAG_STRINGLEN( <len> ) . . . . size of Bag for string of length <len>
**
*/
static inline UInt SIZEBAG_STRINGLEN(UInt len)
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

static inline Char * CSTR_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    return (Char *)ADDR_OBJ(list) + sizeof(UInt);
}

static inline const Char * CONST_CSTR_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    return (const Char *)CONST_ADDR_OBJ(list) + sizeof(UInt);
}

static inline UChar * CHARS_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    return (UChar *)ADDR_OBJ(list) + sizeof(UInt);
}

static inline const UChar * CONST_CHARS_STRING(Obj list)
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

static inline UInt GET_LEN_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    return *((const UInt *)CONST_ADDR_OBJ(list));
}

/****************************************************************************
**
*F  SET_LEN_STRING( <list>, <len> ) . . . . . . . . . set length of a string
**
**  'SET_LEN_STRING' sets length of the string <list> to C integer <len>.
*/

static inline void SET_LEN_STRING(Obj list, Int len)
{
    GAP_ASSERT(IS_STRING_REP(list));
    GAP_ASSERT(len >= 0);
    GAP_ASSERT(SIZEBAG_STRINGLEN(len) <= SIZE_OBJ(list));
    (*((UInt *)ADDR_OBJ(list)) = (UInt)(len));
}

/****************************************************************************
**
*F  NEW_STRING( <len> ) . . . . . . . . . . . . . . . . . . make a new string
**
**  'NEW_STRING' returns a new string with room for <len> characters. It also
**  sets its length to len. 
**
*/
extern Obj NEW_STRING(Int len);

/****************************************************************************
**
*F  GROW_STRING(<list>, <len>) . . . .  make sure a string is large enough
**
**  'GROW_STRING' grows  the string <list>  if necessary to ensure that it
**  has room for at least <len> elements.
**
*/

extern  Int             GrowString (
            Obj                 list,
            UInt                need );

static inline void GROW_STRING(Obj list, Int len)
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
static inline void SHRINK_STRING(Obj list)
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
static inline void COPY_CHARS(Obj str, const UChar * pnt, Int n)
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
extern void PrintString (
    Obj                 list );


/****************************************************************************
**
*F  PrintString1( <list> )  . . . . . . . . . . .  print a string for 'Print'
**
**  'PrintString1' prints the string  constant  in  the  format  used  by  the
**  'Print' and 'PrintTo' function.
*/
extern void PrintString1 (
            Obj                 list );


/****************************************************************************
**
*F  IS_STRING( <obj> )  . . . . . . . . . . . . test if an object is a string
**
**  'IS_STRING' returns 1  if the object <obj>  is a string  and 0 otherwise.
**  It does not change the representation of <obj>.
*/
extern  Int             (*IsStringFuncs [LAST_REAL_TNUM+1]) ( Obj obj );

static inline Int IS_STRING(Obj obj)
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
extern Int IsString (
            Obj                 obj );


/****************************************************************************
**
*F  CopyToStringRep( <string> ) . . .  copy a string to string representation
**
**  'CopyToStringRep' copies the string <string> to a new mutable string in
**  string representation.
*/
extern Obj CopyToStringRep(
            Obj                 string );


/****************************************************************************
**
*F  ImmutableString( <string> ) . . . copy to immutable string in string rep.
**
**  'ImmutableString' returns an immutable string in string representation
**  equal to <string>. This may return <string> if it already satisfies these
**  criteria.
*/
extern Obj ImmutableString(Obj string);


/****************************************************************************
**
*F  ConvString( <string> ) . . . .  convert a string to string representation
**
**  'ConvString' converts the string <string> to string representation.
*/
extern void ConvString (
            Obj                 string );


/****************************************************************************
**
*F  IsStringConv( <obj> ) . . . . . test if an object is a string and convert
**
**  'IsStringConv'   returns 1  if   the object <obj>  is   a  string,  and 0
**  otherwise.   If <obj> is a  string it  changes  its representation to the
**  string representation.
*/
extern Int IsStringConv (
            Obj                 obj );


/****************************************************************************
**
*F  C_NEW_STRING( <string>, <len>, <cstring> )  . . . . . . create GAP string
*/
#define C_NEW_STRING(string,len,cstr) \
  do { \
    size_t tmp_len = (len); \
    string = NEW_STRING( tmp_len ); \
    memcpy( CHARS_STRING(string), (cstr), tmp_len ); \
  } while ( 0 );


/****************************************************************************
**
*F  MakeImmutableString( <str> ) . . . . . . make a string immutable in place
*/
static inline void MakeImmutableString(Obj str)
{
    MakeImmutableNoRecurse(str);
}


// Functions to create mutable and immutable GAP strings from C strings.
// MakeString and MakeImmString are inlineable so 'strlen' can be optimised
// away for constant strings.

static inline Obj MakeString(const Char * cstr)
{
    size_t len = strlen(cstr);
    Obj    result = NEW_STRING(len);
    memcpy(CHARS_STRING(result), cstr, len);
    return result;
}

static inline Obj MakeImmString(const Char * cstr)
{
    Obj result = MakeString(cstr);
    MakeImmutableString(result);
    return result;
}


/****************************************************************************
**
*F  C_NEW_STRING_DYN( <string>, <cstring> ) . . . . . . . . create GAP string
**
**  The cstring is assumed to be allocated on the heap, hence its length
**  is dynamic and must be computed during runtime using strlen.
**
**  This macro is provided for backwards compatibility of packages.
**  'MakeString' and 'MakeImmString' are as efficient and should be used
**  instead.
*/
#define C_NEW_STRING_DYN(string,cstr) \
  C_NEW_STRING(string, strlen(cstr), cstr)

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
