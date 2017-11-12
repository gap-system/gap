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
**  the  macros     'NEW_STRING',   `CHARS_STRING'  (and   'CSTR_STRING'),
**  'GET_LEN_STRING',   `SET_LEN_STRING', `GROW_STRING',  'GET_ELM_STRING'
**  and `SET_ELM_STRING'.
**  
**  This  package also contains the   list  function  for ranges, which   are
**  installed in the appropriate tables by 'InitString'.
*/

#ifndef GAP_STRINGOBJ_H
#define GAP_STRINGOBJ_H

#include <string.h>         // for memcpy
#include <src/objects.h>    // for TNUMs

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

static inline UChar * CHARS_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    return (UChar *)ADDR_OBJ(list) + sizeof(UInt);
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
**
**  Note that 'SHRINK_STRING' is a macro, so do not call it with arguments that
**  have side effects.
*/
static inline void SHRINK_STRING(Obj list)
{
    GAP_ASSERT(IS_STRING_REP(list));
    ResizeBag(list, SIZEBAG_STRINGLEN(GET_LEN_STRING((list))));
}

/****************************************************************************
**
*F  GET_ELM_STRING( <list>, <pos> ) . . . . . . select an element of a string
**
**  'GET_ELM_STRING'  returns the  <pos>-th  element  of  the string  <list>.
**  <pos> must be  a positive integer  less than  or  equal to  the length of
**  <list>.
*/
static inline Obj GET_ELM_STRING(Obj list, Int pos)
{
    GAP_ASSERT(IS_STRING_REP(list));
    GAP_ASSERT(pos > 0);
    GAP_ASSERT(pos <= GET_LEN_STRING(list));
    UChar c = CHARS_STRING(list)[pos - 1];
    return ObjsChar[c];
}

/****************************************************************************
**
*F  SET_ELM_STRING( <list>, <pos>, <val> ) . . . . set a character of a string
**
**  'SET_ELM_STRING'  sets the  <pos>-th  character  of  the string  <list>.
**  <val> must be a character and <list> stay a string after the assignment.
*/
static inline void SET_ELM_STRING(Obj list, Int pos, Obj val)
{
    GAP_ASSERT(IS_STRING_REP(list));
    GAP_ASSERT(pos > 0);
    GAP_ASSERT(pos <= GET_LEN_STRING(list));
    GAP_ASSERT(TNUM_OBJ(val) == T_CHAR);
    UChar * ptr = CHARS_STRING(list) + (pos - 1);
    *ptr = CHAR_VALUE(val);
}

/****************************************************************************
**
*F  COPY_CHARS( <str>, <charpnt>, <n> ) . . . copies <n> chars, starting
**  from character pointer <charpnt>, to beginning of string
**
**  It assumes that the data area in <str> is large enough. It does not add
**  a terminating null character and not change the length of the string.
*/
static inline void COPY_CHARS(Obj str, UChar * pnt, Int n)
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
** escaped by a backslash '\', which is done in 'Pr'.  */
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
*F  CopyToStringRep( <string> )  . . copy a string to the string representation
**
**  'CopyToStringRep' copies the string <string> to a new string in string
**  representation.
*/
extern Obj CopyToStringRep(
            Obj                 string );


/****************************************************************************
**
*F  ConvString( <string> )  . . convert a string to the string representation
**
**  'ConvString' converts the string <list> to the string representation.
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
*F  MakeImmutableString(  <str> ) make a string immutable in place
**
*/

void MakeImmutableString(Obj str);


// Functions to create mutable and immutable GAP strings from C strings.
// MakeString and MakeImmString are inlineable so 'strlen' can be optimised
// away for constant strings.

static inline Obj MakeString(const Char * cstr)
{
    Obj result;
    C_NEW_STRING(result, strlen(cstr), cstr);
    return result;
}

static inline Obj MakeImmString(const Char * cstr)
{
    Obj result = MakeString(cstr);
    RetypeBag(result, IMMUTABLE_TNUM(T_STRING));
    return result;
}


Obj MakeString2(const Char *cstr1, const Char *cstr2);
Obj MakeString3(const Char *cstr1, const Char *cstr2, const Char *cstr3);

Obj MakeImmString2(const Char *cstr1, const Char *cstr2);
Obj MakeImmString3(const Char *cstr1, const Char *cstr2, const Char *cstr3);
Obj ConvImmString(Obj str);


/****************************************************************************
**
*F  C_NEW_STRING_DYN( <string>, <cstring> ) . . . . . . . . create GAP string
**
** The cstring is assumed to be allocated on the heap, hence its length
** is dynamic and must be computed during runtime using strlen.
**
** This macro is provided for backwards compatibility of packages.
** MakeString and MakeImmString are as efficient and should be used instead.
*/
#define C_NEW_STRING_DYN(string,cstr) \
  C_NEW_STRING(string, strlen(cstr), cstr)

/****************************************************************************
**
*F  SINT_CHAR(a)
**
**  'SINT_CHAR' converts the character a (a UInt1) into a signed (C) integer.
*/
#define SINT_CHAR(a)    (((UInt1)a)<128 ? (Int)a : (Int)a-256)

/****************************************************************************
**
*F  CHAR_SINT(n)
**
**  'CHAR_SINT' converts the signed (C) integer n into an (UInt1) character.
*/
#define CHAR_SINT(n)    (UInt1)(n>=0 ? n : n+256)

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoString()  . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoString ( void );


#endif // GAP_STRINGOBJ_H
