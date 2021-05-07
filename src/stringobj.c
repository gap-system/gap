/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions which mainly deal with strings.
**
**  A *string* is a  list that  has no  holes, and  whose  elements  are  all
**  characters.  For the full definition of strings see chapter  "Strings" in
**  the {\GAP} manual.  Read also "More about Strings" about the  string flag
**  and the compact representation of strings.
**
**  A list  that  is  known to  be a  string is  represented by a bag of type
**  'T_STRING', which has the following format:
**
**      +--------+----+----+- - - -+----+----+
**      |length  |1st |2nd |       |last|null|
**      |as UInt |char|char|       |char|char|
**      +--------+----+----+- - - -+----+----+
**
**  Each entry is a  single character (of C type 'unsigned char').   The last
**  entry  in  the  bag is the  null  character  ('\0'),  which terminates  C
**  strings.  We add this null character although the length is stored in the
**  object. This allows to use C routines with  strings  directly  with  null 
**  character free strings (e.g., filenames). 
**
**  Note that a list represented by a bag of type 'T_PLIST' might still be a
**  string. It is just that the kernel does not know this.
**
**  This package consists of three parts.
**  
**  The first part consists of the functions 'NEW_STRING', 'CHARS_STRING' (or
**  'CSTR_STRING'),  'GET_LEN_STRING', 'SET_LEN_STRING', and more. These and
**  the functions below use the detailed knowledge about the representation
**  of strings.
**  
**  The second part  consists  of  the  functions  'LenString',  'ElmString',
**  'ElmsStrings', 'AssString',  'AsssString', PlainString',
**  and 'IsPossString'.  They are the functions required by the generic lists
**  package.  Using these functions the other  parts of the {\GAP} kernel can
**  access and  modify strings  without actually  being aware  that they  are
**  dealing with a string.
**
**  The third part consists  of the functions 'PrintString', which is  called
**  by 'FuncPrint', and 'IsString', which test whether an arbitrary list is a
**  string, and if so converts it into the above format.
*/

#include "stringobj.h"

#include "ariths.h"
#include "bool.h"
#include "error.h"
#include "gaputils.h"
#include "io.h"
#include "listfunc.h"
#include "lists.h"
#include "modules.h"
#include "opers.h"
#include "plist.h"
#include "range.h"
#include "saveload.h"
#include "sysstr.h"

#ifdef HPCGAP
#include "hpc/guards.h"
#endif


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
Obj ObjsChar [256];


/****************************************************************************
**
*F  TypeChar( <chr> ) . . . . . . . . . . . . . . . type of a character value
**
**  'TypeChar' returns the type of the character <chr>.
**
**  'TypeChar' is the function in 'TypeObjFuncs' for character values.
*/
static Obj TYPE_CHAR;

static Obj TypeChar(Obj chr)
{
    return TYPE_CHAR;
}


/****************************************************************************
**
*F  EqChar( <charL>, <charR> )  . . . . . . . . . . .  compare two characters
**
**  'EqChar'  returns 'true'  if the two  characters <charL>  and <charR> are
**  equal, and 'false' otherwise.
*/
static Int EqChar(Obj charL, Obj charR)
{
    return CHAR_VALUE(charL) == CHAR_VALUE(charR);
}


/****************************************************************************
**
*F  LtChar( <charL>, <charR> )  . . . . . . . . . . .  compare two characters
**
**  'LtChar' returns  'true' if the    character <charL>  is less than    the
**  character <charR>, and 'false' otherwise.
*/
static Int LtChar(Obj charL, Obj charR)
{
    return CHAR_VALUE(charL) < CHAR_VALUE(charR);
}


/****************************************************************************
**
*F  PrintChar( <chr> )  . . . . . . . . . . . . . . . . . . print a character
**
**  'PrChar' prints the character <chr>.
*/
static void PrintChar(Obj val)
{
    UChar               chr;

    chr = CHAR_VALUE(val);
    if      ( chr == '\n'  )  Pr("'\\n'", 0, 0);
    else if ( chr == '\t'  )  Pr("'\\t'", 0, 0);
    else if ( chr == '\r'  )  Pr("'\\r'", 0, 0);
    else if ( chr == '\b'  )  Pr("'\\b'", 0, 0);
    else if ( chr == '\01' )  Pr("'\\>'", 0, 0);
    else if ( chr == '\02' )  Pr("'\\<'", 0, 0);
    else if ( chr == '\03' )  Pr("'\\c'", 0, 0);
    else if ( chr == '\''  )  Pr("'\\''", 0, 0);
    else if ( chr == '\\'  )  Pr("'\\\\'", 0, 0);
    /* print every non-printable on non-ASCII character in three digit
     * notation  */
    /*   old version (changed by FL)
    else if ( chr == '\0'  )  Pr("'\\0'", 0, 0);
    else if ( chr <  8     )  Pr("'\\0%d'",(Int)(chr&7), 0);
    else if ( chr <  32    )  Pr("'\\0%d%d'",(Int)(chr/8),(Int)(chr&7));*/
    else if ( chr < 32 || chr > 126 ) {
        Pr("'\\%d%d", (Int)((chr & 192) >> 6), (Int)((chr & 56) >> 3));
        Pr("%d'", (Int)(chr&7), 0);
    }
    else                      Pr("'%c'",(Int)chr, 0);
}


/****************************************************************************
**
*F  SaveChar( <char> )  . . . . . . . . . . . . . . . . . .  save a character
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void SaveChar(Obj c)
{
    SaveUInt1( CHAR_VALUE(c));
}
#endif


/****************************************************************************
**
*F  LoadChar( <char> )  . . . . . . . . . . . . . . . . . .  load a character
**
*/
#ifdef GAP_ENABLE_SAVELOAD
static void LoadChar(Obj c)
{
    SET_CHAR_VALUE(c, LoadUInt1());
}
#endif


/****************************************************************************
**
*F * * * * * * * * * * * * * * GAP level functions  * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncEmptyString( <self>, <len> ) . . . . . . . .  empty string with space
**
**  Returns an empty string, with space for <len> characters preallocated.
**
*/
static Obj FuncEmptyString(Obj self, Obj len)
{
    Obj                 new;
    RequireNonnegativeSmallInt(SELF_NAME, len);
    new = NEW_STRING(INT_INTOBJ(len));
    SET_LEN_STRING(new, 0);
    return new;
}

/****************************************************************************
**
*F  FuncShrinkAllocationString( <self>, <str> ) . . give back unneeded memory
**
**  Shrinks the bag of <str> to minimal possible size (possibly converts to
**  compact representation).
**
*/
static Obj FuncShrinkAllocationString(Obj self, Obj str)
{
    RequireStringRep(SELF_NAME, str);
    SHRINK_STRING(str);
    return (Obj)0;
}

/****************************************************************************
**
*F  FuncCHAR_INT( <self>, <int> ) . . . . . . . . . . . . . . char by integer
*/
static Obj FuncCHAR_INT(Obj self, Obj val)
{
    Int             chr;

    /* get and check the integer value                                     */
    chr = GetBoundedInt("CHAR_INT", val, 0, 255);

    /* return the character                                                */
    return ObjsChar[chr];
}


/****************************************************************************
**
*F  FuncINT_CHAR( <self>, <char> )  . . . . . . . . . . . . . integer by char
*/
static Obj FuncINT_CHAR(Obj self, Obj val)
{
    /* get and check the character                                         */
    if (TNUM_OBJ(val) != T_CHAR) {
        RequireArgument(SELF_NAME, val, "must be a character");
    }

    /* return the character                                                */
    return INTOBJ_INT(CHAR_VALUE(val));
}

/****************************************************************************
**
*F  FuncCHAR_SINT( <self>, <int> ) . . . . . . . . . . char by signed integer
*/
static Obj FuncCHAR_SINT(Obj self, Obj val)
{
    Int chr;

    /* get and check the integer value                                     */
    chr = GetBoundedInt("CHAR_SINT", val, -128, 127);

    /* return the character                                                */
    return ObjsChar[CHAR_SINT(chr)];
}


/****************************************************************************
**
*F  FuncSINT_CHAR( <self>, <char> ) . . . . . . . . .  signed integer by char
*/
static Obj FuncSINT_CHAR(Obj self, Obj val)
{
    /* get and check the character                                         */
    if (TNUM_OBJ(val) != T_CHAR) {
        RequireArgument(SELF_NAME, val, "must be a character");
    }

    /* return the character                                                */
    return INTOBJ_INT(SINT_CHAR(CHAR_VALUE(val)));
}

/****************************************************************************
**
*F  FuncSINTLIST_STRING( <self>, <string> ) signed integer list by string
*/
static Obj FuncINTLIST_STRING(Obj self, Obj val, Obj sign)
{
  UInt l,i;
  Obj n, *addr;
  const UInt1 *p;

  /* test whether val is a string, convert to compact rep if necessary */
  RequireStringRep(SELF_NAME, val);

  l=GET_LEN_STRING(val);
  n=NEW_PLIST(T_PLIST,l);
  SET_LEN_PLIST(n,l);
  p=CONST_CHARS_STRING(val);
  addr=ADDR_OBJ(n);
  /* signed or unsigned ? */
  if (sign == INTOBJ_INT(1)) {
    for (i=1; i<=l; i++) {
      addr[i] = INTOBJ_INT(p[i-1]);
    }
  }
  else {
    for (i=1; i<=l; i++) {
      addr[i] = INTOBJ_INT(SINT_CHAR(p[i-1]));
    }
  }

  CHANGED_BAG(n);
  return n;
}

static Obj FuncSINTLIST_STRING(Obj self, Obj val)
{
    return FuncINTLIST_STRING(self, val, INTOBJ_INT(-1));
}

/****************************************************************************
**
*F  FuncSTRING_SINTLIST( <self>, <string> ) string by signed integer list
*/
static Obj FuncSTRING_SINTLIST(Obj self, Obj val)
{
  UInt l,i;
  Int low, inc;
  Obj n;
  UInt1 *p;

  /* there should be a test here, but how do I check cheaply for list of
   * integers ? */

  /* general code */
  if (!IS_RANGE(val) && !IS_PLIST(val)) {
  again:
      RequireArgument(SELF_NAME, val,
                      "must be a plain list of small integers or a range");
  }
  if (! IS_RANGE(val) ) {
    l=LEN_PLIST(val);
    n=NEW_STRING(l);
    p=CHARS_STRING(n);
    for (i=1;i<=l;i++) {
      Obj x = ELM_PLIST(val,i);
      if (!IS_INTOBJ(x))
        goto again;
      *p++=CHAR_SINT(INT_INTOBJ(x));
    }
  }
  else {
    l=GET_LEN_RANGE(val);
    low=GET_LOW_RANGE(val);
    inc=GET_INC_RANGE(val);
    n=NEW_STRING(l);
    p=CHARS_STRING(n);
    for (i=1;i<=l;i++) {
      *p++=CHAR_SINT(low);
      low=low+inc;
    }

  }

  return n;
}

/****************************************************************************
**
*F  FuncREVNEG_STRING( <self>, <string> ) string by signed integer list
*/
static Obj FuncREVNEG_STRING(Obj self, Obj val)
{
  UInt l,i,j;
  Obj n;
  const UInt1 *p;
  UInt1 *q;

  /* test whether val is a string, convert to compact rep if necessary */
  RequireStringRep(SELF_NAME, val);

  l=GET_LEN_STRING(val);
  n=NEW_STRING(l);
  p=CONST_CHARS_STRING(val);
  q=CHARS_STRING(n);
  j=l-1;
  for (i=1;i<=l;i++) {
    *q++=-p[j];
    j--;
  }

  return n;
}

/****************************************************************************
**
*F * * * * * * * * * * * * * * * string functions * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  NEW_STRING( <len> )  . . . returns new string with length <len>, first
**  character and "first behind last" set to zero
**
*/
Obj NEW_STRING(Int len)
{
    GAP_ASSERT(len >= 0);
    if (len > INT_INTOBJ_MAX) {
        ErrorQuit("NEW_STRING: length must be a small integer", 0, 0);
    }
    Obj res = NewBag(T_STRING, SIZEBAG_STRINGLEN(len));
    SET_LEN_STRING(res, len);
    return res;
}

/****************************************************************************
**
*F  GrowString(<list>,<len>) . . . . . .  make sure a string is large enough
**
**  returns the new length, but doesn't set SET_LEN_STRING.
*/
Int             GrowString (
    Obj                 list,
    UInt                need )
{
    UInt                len;            /* new physical length             */
    UInt                good;           /* good new physical length        */

    if (need > INT_INTOBJ_MAX)
        ErrorMayQuit("GrowString: string length too large", 0, 0);

    /* find out how large the data area  should become                     */
    good = 5 * (GET_LEN_STRING(list)+3) / 4 + 1;
    if (good > INT_INTOBJ_MAX)
        good = INT_INTOBJ_MAX;

    /* but maybe we need more                                              */
    if ( need < good ) { len = good; }
    else               { len = need; }

    /* resize the bag                                                      */
    ResizeBag( list, SIZEBAG_STRINGLEN(len) );

    /* return the new maximal length                                       */
    return (Int) len;
}

/****************************************************************************
**
*F  TypeString(<list>)  . . . . . . . . . . . . . . . . . .  type of a string
**
**  'TypeString' returns the type of the string <list>.
**
**  'TypeString' is the function in 'TypeObjFuncs' for strings.
*/
static Obj TYPES_STRING;


static Obj TypeString(Obj list)
{
    return ELM_PLIST(TYPES_STRING, TNUM_OBJ(list) - T_STRING + 1);
}



/****************************************************************************
**
*F * * * * * * * * * * * * * * copy functions * * * * * * * * * * * * * * * *
*/

#if !defined(USE_THREADSAFE_COPYING)

/****************************************************************************
**
*F  CopyString( <list>, <mut> ) . . . . . . . . . . . . . . . . copy a string
**
**  'CopyString' returns a structural (deep) copy of the string <list>, i.e.,
**  a recursive copy that preserves the structure.
**
**  If <list> has not  yet  been copied, it makes   a copy, leaves  a forward
**  pointer to the copy in  the first entry of  the string, where the size of
**  the string usually resides,  and copies  all the  entries.  If the string
**  has already been copied, it returns the value of the forwarding pointer.
**
**  'CopyString' is the function in 'CopyObjFuncs' for strings.
*/
static Obj CopyString(Obj list, Int mut)
{
    Obj                 copy;           /* handle of the copy, result      */

    // immutable input is handled by COPY_OBJ
    GAP_ASSERT(IS_MUTABLE_OBJ(list));

    /* make object for  copy                                               */
    copy = NewBag(TNUM_OBJ(list), SIZE_OBJ(list));
    if (!mut)
        MakeImmutableNoRecurse(copy);
    ADDR_OBJ(copy)[0] = CONST_ADDR_OBJ(list)[0];

    /* leave a forwarding pointer                                          */
    PrepareCopy(list, copy);

    /* copy the subvalues                                                  */
    memcpy(ADDR_OBJ(copy)+1, CONST_ADDR_OBJ(list)+1,
           SIZE_OBJ(list)-sizeof(Obj) );

    /* return the copy                                                     */
    return copy;
}

#endif //!defined(USE_THREADSAFE_COPYING)


/****************************************************************************
**
*F * * * * * * * * * * * * * * list functions * * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  PrintString(<list>) . . . . . . . . . . . . . . . . . . .  print a string
*F  FuncVIEW_STRING_FOR_STRING(<list>) . . . . . .  view a string as a string
**
**  'PrintString' prints the string with the handle <list>.
**  'VIEW_STRING_FOR_STRING' returns a string containing what PrintString
**  outputs.
**
**  No linebreaks are  allowed, if one must be inserted  anyhow, it must
**  be escaped by a backslash '\', which is done in 'Pr'.
**
**  The buffer 'PrStrBuf' is used to protect 'Pr' against garbage collections
**  caused by printing to string streams, which might move the body of list.
**
**  The output uses octal number notation for non-ascii or non-printable
**  characters. The function can be used to print *any* string in a way
**  which can be read in by GAP afterwards.
*/

// Type of function given to OutputStringGeneric
typedef void StringOutputterType(void * data, char * strbuf, UInt len);

// Output using Pr
void ToPrOutputter(void * data, char * strbuf, UInt len)
{
    strbuf[len++] = '\0';
    Pr("%s", (Int)strbuf, 0);
}

// Output to a string
void ToStringOutputter(void * data, char * buf, UInt lenbuf)
{
    AppendCStr((Obj)data, buf, lenbuf);
}

void OutputStringGeneric(Obj list, StringOutputterType func, void * data)
{
    char  PrStrBuf[10007]; /* 7 for a \c\123 at the end */
    UInt  scanout = 0, n;
    UInt1 c;
    UInt  len = GET_LEN_STRING(list);
    UInt  off = 0;
    PrStrBuf[scanout++] = '\"';
    func(data, PrStrBuf, scanout);
    while (off < len) {
        scanout = 0;
        do {
            c = CONST_CHARS_STRING(list)[off++];
            switch (c) {
            case '\\':
                PrStrBuf[scanout++] = '\\';
                PrStrBuf[scanout++] = '\\';
                break;
            case '\"':
                PrStrBuf[scanout++] = '\\';
                PrStrBuf[scanout++] = '\"';
                break;
            case '\n':
                PrStrBuf[scanout++] = '\\';
                PrStrBuf[scanout++] = 'n';
                break;
            case '\t':
                PrStrBuf[scanout++] = '\\';
                PrStrBuf[scanout++] = 't';
                break;
            case '\r':
                PrStrBuf[scanout++] = '\\';
                PrStrBuf[scanout++] = 'r';
                break;
            case '\b':
                PrStrBuf[scanout++] = '\\';
                PrStrBuf[scanout++] = 'b';
                break;
            case '\01':
                PrStrBuf[scanout++] = '\\';
                PrStrBuf[scanout++] = '>';
                break;
            case '\02':
                PrStrBuf[scanout++] = '\\';
                PrStrBuf[scanout++] = '<';
                break;
            case '\03':
                PrStrBuf[scanout++] = '\\';
                PrStrBuf[scanout++] = 'c';
                break;
            default:
                if (c < 32 || c > 126) {
                    PrStrBuf[scanout++] = '\\';
                    n = c / 64;
                    c = c - n * 64;
                    PrStrBuf[scanout++] = n + '0';
                    n = c / 8;
                    c = c - n * 8;
                    PrStrBuf[scanout++] = n + '0';
                    PrStrBuf[scanout++] = c + '0';
                }
                else
                    PrStrBuf[scanout++] = c;
            }
        } while (off < len && scanout < 10000);
        func(data, PrStrBuf, scanout);
    }
    scanout = 0;
    PrStrBuf[scanout++] = '\"';
    func(data, PrStrBuf, scanout);
}

void PrintString(Obj list)
{
    OutputStringGeneric(list, ToPrOutputter, (void *)0);
}

Obj FuncVIEW_STRING_FOR_STRING(Obj self, Obj string)
{
    if (!IS_STRING(string)) {
        RequireArgument(SELF_NAME, string, "must be a string");
    }

    if (!IS_STRING_REP(string)) {
        string = CopyToStringRep(string);
    }

    Obj output = NEW_STRING(0);
    OutputStringGeneric(string, ToStringOutputter, output);
    return output;
}

/****************************************************************************
**
*F  PrintString1(<list>)  . . . . . . . . . . . .  print a string for 'Print'
**
**  'PrintString1' prints the string  constant  in  the  format  used  by the
**  'Print' and 'PrintTo' function.
*/
void PrintString1 (
    Obj                 list )
{
    Pr("%g", (Int)list, 0);
}


/****************************************************************************
**
*F  EqString(<listL>,<listR>) . . . . . . . .  test whether strings are equal
**
**  'EqString'  returns  'true' if the  two  strings <listL>  and <listR> are
**  equal and 'false' otherwise.
*/
static Int EqString(Obj listL, Obj listR)
{
  UInt lL, lR;
  const UInt1 *pL, *pR;
  lL = GET_LEN_STRING(listL);
  lR = GET_LEN_STRING(listR);
  if (lR != lL) return 0;
  pL = CONST_CHARS_STRING(listL);
  pR = CONST_CHARS_STRING(listR);
  return memcmp(pL, pR, lL) == 0;
}


/****************************************************************************
**
*F  LtString(<listL>,<listR>) .  test whether one string is less than another
**
**  'LtString' returns 'true' if  the string <listL> is  less than the string
**  <listR> and 'false' otherwise.
*/
static Int LtString(Obj listL, Obj listR)
{
  UInt lL, lR;
  const UInt1 *pL, *pR;
  lL = GET_LEN_STRING(listL);
  lR = GET_LEN_STRING(listR);
  pL = CONST_CHARS_STRING(listL);
  pR = CONST_CHARS_STRING(listR);

  Int res;
  if (lL <= lR) {
    res = memcmp(pL, pR, lL);
    if (res == 0)
      return lL < lR;
  }
  else {
    res = memcmp(pL, pR, lR);
    if (res == 0)
      return 0;
  }
  return res < 0;
}


/****************************************************************************
**
*F  LenString(<list>) . . . . . . . . . . . . . . . . . .  length of a string
**
**  'LenString' returns the length of the string <list> as a C integer.
**
**  'LenString' is the function in 'LenListFuncs' for strings.
*/
static Int LenString(Obj list)
{
    return GET_LEN_STRING( list );
}


/****************************************************************************
**
*F  IsbString(<list>,<pos>) . . . . . . . . . test for an element of a string
**
**  'IsbString' returns 1 if the string <list> contains
**  a character at the position <pos> and 0 otherwise.
**  It can rely on <pos> being a positive integer.
**
**  'IsbString'  is the function in 'IsbListFuncs'  for strings.
*/
static BOOL IsbString(Obj list, Int pos)
{
    /* since strings are dense, this must only test for the length         */
    return (pos <= GET_LEN_STRING(list));
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
    GAP_ASSERT((UInt) pos <= GET_LEN_STRING(list));
    UChar c = CONST_CHARS_STRING(list)[pos - 1];
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
    GAP_ASSERT((UInt) pos <= GET_LEN_STRING(list));
    GAP_ASSERT(TNUM_OBJ(val) == T_CHAR);
    UChar * ptr = CHARS_STRING(list) + (pos - 1);
    *ptr = CHAR_VALUE(val);
}


/****************************************************************************
**
*F  Elm0String(<list>,<pos>)  . . . . . . . . . select an element of a string
*F  Elm0vString(<list>,<pos>) . . . . . . . . . select an element of a string
**
**  'Elm0String' returns the element at the position <pos> of the string
**  <list>, or returns 0 if <list> has no assigned object at <pos>.
**  It can rely on <pos> being a positive integer.
**
**  'Elm0vString' does the same thing as 'Elm0String', but it can
**  also rely on <pos> not being larger than the length of <list>.
**
**  'Elm0String'  is the function on 'Elm0ListFuncs'  for strings.
**  'Elm0vString' is the function in 'Elm0vListFuncs' for strings.
*/
static Obj Elm0String(Obj list, Int pos)
{
    if ( pos <= GET_LEN_STRING( list ) ) {
        return GET_ELM_STRING( list, pos );
    }
    else {
        return 0;
    }
}

static Obj Elm0vString(Obj list, Int pos)
{
    return GET_ELM_STRING( list, pos );
}


/****************************************************************************
**
*F  ElmString(<list>,<pos>) . . . . . . . . . . select an element of a string
*F  ElmvString(<list>,<pos>)  . . . . . . . . . select an element of a string
**
**  'ElmString' returns the element at the position <pos> of the string
**  <list>, or signals an error if <list> has no assigned object at <pos>.
**  It can rely on <pos> being a positive integer.
**
**  'ElmvString' does the same thing as 'ElmString', but it can
**  also rely on <pos> not being larger than the length of <list>.
**
**  'ElmwString' does the same thing as 'ElmString', but it can
**  also rely on <list> having an assigned object at <pos>.
**
**  'ElmString'  is the function in 'ElmListFuncs'  for strings.
**  'ElmfString' is the function in 'ElmfListFuncs' for strings.
**  'ElmwString' is the function in 'ElmwListFuncs' for strings.
*/
static Obj ElmString(Obj list, Int pos)
{
    /* check the position                                                  */
    if ( GET_LEN_STRING( list ) < pos ) {
        ErrorMayQuit("List Element: <list>[%d] must have an assigned value",
                     (Int)pos, 0);
    }

    /* return the selected element                                         */
    return GET_ELM_STRING( list, pos );
}

#define ElmvString      Elm0vString

#define ElmwString      Elm0vString


/****************************************************************************
**
*F  ElmsString(<list>,<poss>) . . . . . . . .  select a sublist from a string
**
**  'ElmsString' returns a new list containing the  elements at the positions
**  given   in  the  list   <poss> from   the  string   <list>.   It  is  the
**  responsibility of the called to ensure that  <poss> is dense and contains
**  only positive integers.  An error is signalled if an element of <poss> is
**  larger than the length of <list>.
**
**  'ElmsString' is the function in 'ElmsListFuncs' for strings.
*/
static Obj ElmsString(Obj list, Obj poss)
{
    Obj                 elms;         /* selected sublist, result        */
    Int                 lenList;        /* length of <list>                */
    Char                elm;            /* one element from <list>         */
    Int                 lenPoss;        /* length of <positions>           */
    Int                 pos;            /* <position> as integer           */
    Int                 inc;            /* increment in a range            */
    Int                 i;              /* loop variable                   */

    /* general code                                                        */
    if ( ! IS_RANGE(poss) ) {

        /* get the length of <list>                                        */
        lenList = GET_LEN_STRING( list );

        /* get the length of <positions>                                   */
        lenPoss = LEN_LIST( poss );

        /* make the result list                                            */
        elms = NEW_STRING( lenPoss );

        /* loop over the entries of <positions> and select                 */
        for ( i = 1; i <= lenPoss; i++ ) {

            /* get <position>                                              */
            Obj p = ELMW_LIST(poss, i);
            if (!IS_INTOBJ(p)) {
                ErrorMayQuit("List Elements: position is too large for "
                             "this type of list",
                             0, 0);
            }
            pos = INT_INTOBJ(p);

            /* select the element                                          */
            if ( lenList < pos ) {
                ErrorMayQuit(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0);
            }

            /* select the element                                          */
            elm = CONST_CHARS_STRING(list)[pos-1];

            /* assign the element into <elms>                              */
            CHARS_STRING(elms)[i-1] = elm;

        }

    }

    /* special code for ranges                                             */
    else {

        /* get the length of <list>                                        */
        lenList = GET_LEN_STRING( list );

        /* get the length of <positions>, the first elements, and the inc. */
        lenPoss = GET_LEN_RANGE( poss );
        pos = GET_LOW_RANGE( poss );
        inc = GET_INC_RANGE( poss );

        /* check that no <position> is larger than 'LEN_LIST(<list>)'      */
        if ( lenList < pos ) {
            ErrorMayQuit(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos, 0);
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorMayQuit(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)(pos + (lenPoss - 1) * inc), 0);
        }

        /* make the result list                                            */
        elms = NEW_STRING( lenPoss );

        /* loop over the entries of <positions> and select                 */
        const UInt1 * p = CONST_CHARS_STRING(list);
        UInt1 * pn = CHARS_STRING(elms);
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {
            pn[i - 1] = p[pos - 1];
        }

    }

    return elms;
}


/****************************************************************************
**
*F  AssString(<list>,<pos>,<val>) . . . . . . . . . . . .  assign to a string
**
**  'AssString' assigns the value <val> to the  string <list> at the position
**  <pos>.   It is the responsibility  of the caller to  ensure that <pos> is
**  positive, and that <val> is not 0.
**
**  'AssString' is the function in 'AssListFuncs' for strings.
**
**  'AssString' keeps <list> in string representation if possible.
**  
*/
static void AssString(Obj list, Int pos, Obj val)
{
  UInt len = GET_LEN_STRING(list);

  if (TNUM_OBJ(val) != T_CHAR || pos > len+1) {
    /* convert the range into a plain list                                 */
    PLAIN_LIST(list);
    CLEAR_FILTS_LIST(list);

    /* resize the list if necessary                                        */
    if ( len < pos ) {
      GROW_PLIST( list, pos );
      SET_LEN_PLIST( list, pos );
    }

    /* now perform the assignment and return the assigned value            */
    SET_ELM_PLIST( list, pos, val );
    CHANGED_BAG( list );
  }
  else {
    CLEAR_FILTS_LIST(list);

    /* resize the list if necessary                                        */
    if ( len < pos ) {
      GROW_STRING( list, pos );
      SET_LEN_STRING( list, pos );
      CHARS_STRING(list)[pos] = (UInt1)0;
    }

    /* now perform the assignment and return the assigned value            */
    SET_ELM_STRING( list, pos, val ); 
  }
}    


/****************************************************************************
**
*F  AsssString(<list>,<poss>,<vals>)  . . assign several elements to a string
**
**  'AsssString' assigns the  values from the  list <vals> at the  positions
**  given in the list <poss> to the string  <list>.  It is the responsibility
**  of the caller to ensure that  <poss> is dense  and contains only positive
**  integers, that <poss> and <vals> have the same length, and that <vals> is
**  dense.
**
**  'AsssString' is the function in 'AsssListFuncs' for strings.
**
**  'AsssString' simply delegates to AssString. Note that the ordering of 
**  <poss> can be important if <list> should stay in string representation.
**   
*/
static void AsssString(Obj list, Obj poss, Obj vals)
{
  Int i, len = LEN_LIST(poss);
  for (i = 1; i <= len; i++) {
    ASS_LIST(list, INT_INTOBJ(ELM_LIST(poss, i)), ELM_LIST(vals, i));
  }
}


/****************************************************************************
**
*F  IsSSortString(<list>) . . . . . . . strictly sorted list test for strings
**
**  'IsSSortString'  returns 1 if the string  <list> is strictly sorted and 0
**  otherwise.
**
**  'IsSSortString' is the function in 'IsSSortListFuncs' for strings.
*/
static BOOL IsSSortString(Obj list)
{
    Int                 len;
    Int                 i;
    const UInt1 *       ptr;

    /* test whether the string is strictly sorted                          */
    len = GET_LEN_STRING( list );
    ptr = CONST_CHARS_STRING(list);
    for ( i = 1; i < len; i++ ) {
        if ( ! (ptr[i-1] < ptr[i]) )
            break;
    }

    /* retype according to the outcome                                     */
    SET_FILT_LIST( list, (len <= i) ? FN_IS_SSORT : FN_IS_NSORT );
    return (len <= i);
}


/****************************************************************************
**
*F  IsPossString(<list>)  . . . . .  positions list test function for strings
**
**  'IsPossString' is the function in 'IsPossListFuncs' for strings.
*/
static BOOL IsPossString(Obj list)
{
    return GET_LEN_STRING( list ) == 0;
}


/****************************************************************************
**
*F  PosString(<list>,<val>,<pos>) . . . .  position of an element in a string
**
**  'PosString' returns the position of the  value <val> in the string <list>
**  after the first position <start> as a C integer.   0 is returned if <val>
**  is not in the list.
**
**  'PosString' is the function in 'PosListFuncs' for strings.
*/
static Obj PosString(Obj list, Obj val, Obj start)
{
    Int                 lenList;        /* length of <list>                */
    Int                 i;              /* loop variable                   */
    UInt1               valc;        /* C characters                    */
    const UInt1         *p;             /* pointer to chars of <list>      */
    UInt                istart;

    /* if the starting position is too big to be a small int
       then there can't be anything to find */
    if (!IS_INTOBJ(start))
      return Fail;

    istart = INT_INTOBJ(start);
    
    /* get the length of <list>                                            */
    lenList = GET_LEN_STRING( list );

    /* a string contains only characters */
    if (TNUM_OBJ(val) != T_CHAR) return Fail;
    
    /* val as C character   */
    valc = CHAR_VALUE(val);

    /* search entries in <list>                                     */
    p = CONST_CHARS_STRING(list);
    for ( i = istart; i < lenList && p[i] != valc; i++ );

    /* return the position (0 if <val> was not found)                      */
    return (lenList <= i ? Fail : INTOBJ_INT(i+1));
}


/****************************************************************************
**
*F  PlainString(<list>) . . . . . . . . . .  convert a string to a plain list
**
**  'PlainString' converts the string <list> to a plain list.  Not much work.
**
**  'PlainString' is the function in 'PlainListFuncs' for strings.
*/
static void PlainString(Obj list)
{
    Int                 lenList;        /* logical length of the string    */
    Obj                 tmp;            /* handle of the list              */
    Int                 i;              /* loop variable                   */

    /* find the length and allocate a temporary copy                       */
    lenList = GET_LEN_STRING( list );
    tmp = NEW_PLIST_WITH_MUTABILITY(IS_MUTABLE_OBJ(list), T_PLIST, lenList);
    SET_LEN_PLIST( tmp, lenList );

    /* copy the characters                                                 */
    for ( i = 1; i <= lenList; i++ ) {
        SET_ELM_PLIST( tmp, i, GET_ELM_STRING( list, i ) );
    }

    /* change size and type of the string and copy back                    */
    ResizeBag( list, SIZE_OBJ(tmp) );
    RetypeBag( list, TNUM_OBJ(tmp) );

    memcpy(ADDR_OBJ(list), CONST_ADDR_OBJ(tmp), SIZE_OBJ(tmp));
    CHANGED_BAG(list);
}


/****************************************************************************
**
*F  IS_STRING( <obj> )  . . . . . . . . . . . . test if an object is a string
**
**  'IS_STRING' returns 1  if the object <obj>  is a string  and 0 otherwise.
**  It does not change the representation of <obj>.
*/
BOOL (*IsStringFuncs[LAST_REAL_TNUM + 1])(Obj obj);

static Obj IsStringFilt;

static BOOL IsStringList(Obj list)
{
    Int                 lenList;
    Obj                 elm;
    Int                 i;
    
    lenList = LEN_LIST( list );
    for ( i = 1; i <= lenList; i++ ) {
        elm = ELMV0_LIST( list, i );
        if ( elm == 0 )
            break;
#ifdef HPCGAP
        if ( !CheckReadAccess(elm) )
            break;
#endif
        if ( TNUM_OBJ( elm ) != T_CHAR )
            break;
    }

    return (lenList < i);
}

static BOOL IsStringListHom(Obj list)
{
    return (TNUM_OBJ( ELM_LIST(list,1) ) == T_CHAR);
}

static BOOL IsStringObject(Obj obj)
{
    return (DoFilter( IsStringFilt, obj ) != False);
}


/****************************************************************************
**
*F  CopyToStringRep( <string> ) . . .  copy a string to string representation
**
**  'CopyToStringRep' copies the string <string> to a new string in string
**  representation.
*/
Obj CopyToStringRep(
    Obj                 string )
{
    Int                 lenString;      /* length of the string            */
    Obj                 elm;            /* one element of the string       */
    Obj                 copy;           /* temporary string                */
    Int                 i;              /* loop variable                   */

    lenString = LEN_LIST(string);
    copy = NEW_STRING(lenString);

    if ( IS_STRING_REP(string) ) {
        memcpy(CHARS_STRING(copy), CONST_CHARS_STRING(string),
            GET_LEN_STRING(string));
        /* XXX no error checks? */
    } else {
        /* copy the string to the string representation                     */
        for ( i = 1; i <= lenString; i++ ) {
            elm = ELMW_LIST( string, i );
            CHARS_STRING(copy)[i-1] = CHAR_VALUE(elm);
        } 
        CHARS_STRING(copy)[lenString] = '\0';
    }
    return copy;
}


/****************************************************************************
**
*F  ImmutableString( <string> ) . . . copy to immutable string in string rep.
**
**  'ImmutableString' returns an immutable string in string representation
**  equal to <string>. This may return <string> if it already satisfies these
**  criteria.
*/
Obj ImmutableString(Obj string)
{
    if (!IS_STRING_REP(string) || IS_MUTABLE_OBJ(string)) {
        string = CopyToStringRep(string);
        MakeImmutableNoRecurse(string);
    }
    return string;
}


/****************************************************************************
**
*F  ConvString( <string> ) . . . .  convert a string to string representation
**
**  'ConvString' converts the string <string> to string representation.
*/
void ConvString (
    Obj                 string )
{
    Int                 lenString;      /* length of the string            */
    Obj                 elm;            /* one element of the string       */
    Obj                 tmp;            /* temporary string                */
    Int                 i;              /* loop variable                   */

    /* do nothing if the string is already in the string representation    */
    if ( IS_STRING_REP(string) )
    {
        return;
    }


    lenString = LEN_LIST(string);
    tmp = NEW_STRING(lenString);

    /* copy the string to the string representation                     */
    for ( i = 1; i <= lenString; i++ ) {
        elm = ELMW_LIST( string, i );
        CHARS_STRING(tmp)[i-1] = CHAR_VALUE(elm);
    }
    CHARS_STRING(tmp)[lenString] = '\0';

    /* copy back to string  */
    RetypeBagSM( string, T_STRING );
    ResizeBag( string, SIZEBAG_STRINGLEN(lenString) );
    /* copy data area from tmp */
    memcpy(ADDR_OBJ(string), CONST_ADDR_OBJ(tmp), SIZE_OBJ(tmp));
}



/****************************************************************************
**
*F  IsStringConv( <obj> ) . . . . . test if an object is a string and convert
**
**  'IsStringConv'   returns 1  if   the object <obj>  is   a  string,  and 0
**  otherwise.   If <obj> is a  string it  changes  its representation to the
**  string representation.
*/
BOOL IsStringConv(Obj obj)
{
    Int                 res;

    /* test whether the object is a string                                 */
    res = IS_STRING( obj );

    /* if so, convert it to the string representation                      */
    if ( res ) {
        ConvString( obj );
    }

    return res;
}


/****************************************************************************
**
*F  AppendCStr( <str>, <buf>, <len> ) . . append data in a buffer to a string
**
**  'AppendCStr' appends <len> bytes of data taken from <buf> to <str>, where
**  <str> must be a mutable GAP string object.
*/
void AppendCStr(Obj str, const char * buf, UInt len)
{
    GAP_ASSERT(IS_MUTABLE_OBJ(str));
    GAP_ASSERT(IS_STRING_REP(str));

    UInt len1 = GET_LEN_STRING(str);
    UInt newlen = len1 + len;
    GROW_STRING(str, newlen);
    SET_LEN_STRING(str, newlen);
    CLEAR_FILTS_LIST(str);
    memcpy(CHARS_STRING(str) + len1, buf, len);
    CHARS_STRING(str)[newlen] = '\0'; // add terminator
}


/****************************************************************************
**
*F  AppendString( <str1>, <str2> ) . . . . . . . append one string to another
**
**  'AppendString' appends <str2> to the end of <str1>. Both <str1> and <str>
**  must be a GAP string objects, and <str1> must be mutable.
*/
void AppendString(Obj str1, Obj str2)
{
    GAP_ASSERT(IS_MUTABLE_OBJ(str1));
    GAP_ASSERT(IS_STRING_REP(str1));
    GAP_ASSERT(IS_STRING_REP(str2));

    UInt len1 = GET_LEN_STRING(str1);
    UInt len2 = GET_LEN_STRING(str2);
    UInt newlen = len1 + len2;
    GROW_STRING(str1, newlen);
    SET_LEN_STRING(str1, newlen);
    CLEAR_FILTS_LIST(str1);
    memcpy(CHARS_STRING(str1) + len1, CONST_CHARS_STRING(str2), len2);
    CHARS_STRING(str1)[newlen] = '\0'; // add terminator
}


/****************************************************************************
**
*F * * * * * * * * * * * * * * GAP level functions  * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  FiltIS_STRING( <self>, <obj> )  . . . . . . . . .  test value is a string
*/
static Obj FiltIS_STRING(Obj self, Obj obj)
{
    return (IS_STRING( obj ) ? True : False);
}


/****************************************************************************
**
*F  FuncIS_STRING_CONV( <self>, <obj> ) . . . . . . . . . . check and convert
*/
static Obj FuncIS_STRING_CONV(Obj self, Obj obj)
{
    /* return 'true' if <obj> is a string and 'false' otherwise            */
    return (IsStringConv(obj) ? True : False);
}


/****************************************************************************
**
*F  FuncCONV_STRING( <self>, <string> ) . . . . . . . . convert to string rep
*/
static Obj FuncCONV_STRING(Obj self, Obj string)
{
    if (!IS_STRING(string)) {
        RequireArgument(SELF_NAME, string, "must be a string");
    }

    /* convert to the string representation                                */
    ConvString( string );

    return 0;
}


/****************************************************************************
**
*F  FiltIS_STRING_REP( <self>, <obj> )  . . . . test if value is a string rep
*/
static Obj IsStringRepFilt;

static Obj FiltIS_STRING_REP(Obj self, Obj obj)
{
    return (IS_STRING_REP( obj ) ? True : False);
}

/****************************************************************************
**
*F  FuncCOPY_TO_STRING_REP( <self>, <obj> ) . copy a string into string rep
*/
static Obj FuncCOPY_TO_STRING_REP(Obj self, Obj string)
{
    if (!IS_STRING(string)) {
        RequireArgument(SELF_NAME, string, "must be a string");
    }
    return CopyToStringRep(string);
}

/****************************************************************************
**
*F  FuncPOSITION_SUBSTRING( <self>,  <string>, <substr>, <off> ) .  position of
**  substring
**  
**  <str> and <substr> must be strings  and <off> an integer. The position
**  of  first  character of substring   in string,  search  starting  from
**  <off>+1, is  returned if such  a substring exists. Otherwise `fail' is
**  returned.
*/
static Obj FuncPOSITION_SUBSTRING(Obj self, Obj string, Obj substr, Obj off)
{
  Int    ipos, i, j, lens, lenss, max;
  const UInt1  *s, *ss;

  RequireStringRep(SELF_NAME, string);
  RequireStringRep(SELF_NAME, substr);
  RequireNonnegativeSmallInt(SELF_NAME, off);

  ipos = INT_INTOBJ(off);

  /* special case for the empty string */
  lenss = GET_LEN_STRING(substr);
  if ( lenss == 0 ) {
    return INTOBJ_INT(ipos + 1);
  }

  lens = GET_LEN_STRING(string);
  max = lens - lenss + 1;
  s = CONST_CHARS_STRING(string);
  ss = CONST_CHARS_STRING(substr);
  
  const UInt1 c = ss[0];
  for (i = ipos; i < max; i++) {
    if (c == s[i]) {
      for (j = 1; j < lenss; j++) {
        if (! (s[i+j] == ss[j]))
          break;
      }
      if (j == lenss) 
        return INTOBJ_INT(i+1);
    }
  }
  return Fail;
}

/****************************************************************************
**
*F  FuncNormalizeWhitespace( <self>, <string> ) . . . . . normalize white
**  space in place
**    
**  Whitespace  characters are  " \r\t\n".  Leading and  trailing whitespace  in
**  string  is  removed. Intermediate  sequences  of  whitespace characters  are
**  substituted by a single space.
**  
*/
static Obj FuncNormalizeWhitespace(Obj self, Obj string)
{
  UInt1  *s, c;
  Int i, j, len, white;

  RequireStringRep(SELF_NAME, string);

  len = GET_LEN_STRING(string);
  s = CHARS_STRING(string);
  i = -1;
  white = 1;
  for (j = 0; j < len; j++) {
    c = s[j];
    if (c == ' ' || c == '\n' || c == '\t' || c == '\r') {
      if (! white) {
        i++;
        s[i] = ' ';
        white = 1;
      }
    }
    else {
      i++;
      s[i] = c;
      white = 0;
    }
  }
  if (white && i > -1) 
    i--;
  s[i+1] = '\0';
  SET_LEN_STRING(string, i+1);
 
  /* to make it useful as C-string */
  CHARS_STRING(string)[i+1] = (UInt1)0;

  return (Obj)0;
}


/****************************************************************************
**
*F  FuncREMOVE_CHARACTERS( <self>, <string>, <rem> ) . . . . . delete characters
**  from <rem> in <string> in place 
**    
*/

static Obj FuncREMOVE_CHARACTERS(Obj self, Obj string, Obj rem)
{
  UInt1  *s;
  Int i, j, len;
  UInt1 REMCHARLIST[256] = {0};

  RequireStringRep(SELF_NAME, string);
  RequireStringRep(SELF_NAME, rem);

  /* set REMCHARLIST by setting positions of characters in rem to 1 */
  len = GET_LEN_STRING(rem);
  s = CHARS_STRING(rem);
  for(i=0; i<len; i++) REMCHARLIST[s[i]] = 1;
  
  /* now change string in place */
  len = GET_LEN_STRING(string);
  s = CHARS_STRING(string);
  i = -1;
  for (j = 0; j < len; j++) {
    if (REMCHARLIST[s[j]] == 0) {
      i++;
      s[i] = s[j];
    }
  }
  i++;
  s[i] = '\0';
  SET_LEN_STRING(string, i);
  SHRINK_STRING(string);

  return (Obj)0;
}


/****************************************************************************
**
*F  FuncTranslateString( <self>, <string>, <trans> ) . . . translate characters
**  in <string> in place, <string>[i] = <trans>[<string>[i]] 
**    
*/
static Obj FuncTranslateString(Obj self, Obj string, Obj trans)
{
  Int j, len;

  RequireStringRep(SELF_NAME, string);
  RequireStringRep(SELF_NAME, trans);
  if ( GET_LEN_STRING( trans ) < 256 ) {
      ErrorMayQuit("TranslateString: <trans> must have length >= 256",
                   0, 0 );
  }

  /* now change string in place */
  len = GET_LEN_STRING(string);
  UInt1 *s = CHARS_STRING(string);
  const UInt1 *t = CONST_CHARS_STRING(trans);
  for (j = 0; j < len; j++) {
    s[j] = t[s[j]];
  }
  
  return (Obj)0;
}


/****************************************************************************
**
*F  FuncSplitStringInternal( <self>, <string>, <seps>, <wspace> ) . . . . split string
**  at characters in <seps> and <wspace>
**    
**  The difference of <seps> and <wspace> is that characters in <wspace> don't
**  separate empty strings.
*/
static Obj FuncSplitStringInternal(Obj self, Obj string, Obj seps, Obj wspace)
{
  const UInt1  *s;
  Int i, a, z, l, pos, len;
  Obj res, part;
  UInt1 SPLITSTRINGSEPS[256] = { 0 };
  UInt1 SPLITSTRINGWSPACE[256] = { 0 };

  RequireStringRep(SELF_NAME, string);
  RequireStringRep(SELF_NAME, seps);
  RequireStringRep(SELF_NAME, wspace);

  /* set SPLITSTRINGSEPS by setting positions of characters in rem to 1 */
  len = GET_LEN_STRING(seps);
  s = CONST_CHARS_STRING(seps);
  for(i=0; i<len; i++) SPLITSTRINGSEPS[s[i]] = 1;
  
  /* set SPLITSTRINGWSPACE by setting positions of characters in rem to 1 */
  len = GET_LEN_STRING(wspace);
  s = CONST_CHARS_STRING(wspace);
  for(i=0; i<len; i++) SPLITSTRINGWSPACE[s[i]] = 1;
 
  /* create the result (list of strings) */
  res = NEW_PLIST(T_PLIST, 2);
  pos = 0;

  /* now do the splitting */
  len = GET_LEN_STRING(string);
  s = CONST_CHARS_STRING(string);
  for (a=0, z=0; z<len; z++) {
    // Whenever we encounter a separator or a white space, the substring
    // starting after the last separator/white space is cut out.  The
    // only difference between white spaces and separators is that white
    // spaces don't separate empty strings.
    if (SPLITSTRINGWSPACE[s[z]] == 1) {
      if (a<z) {
        l = z-a;
        part = NEW_STRING(l);
        // update s in case there was a garbage collection
        s = CONST_CHARS_STRING(string);
        COPY_CHARS(part, s + a, l);
        CHARS_STRING(part)[l] = 0;
        pos++;
        AssPlist(res, pos, part);
        s = CONST_CHARS_STRING(string);
        a = z+1;
      }
      else {
        a = z+1;
      }
    }
    else {
      if (SPLITSTRINGSEPS[s[z]] == 1) {
        l = z-a;
        part = NEW_STRING(l);
        // update s in case there was a garbage collection
        s = CONST_CHARS_STRING(string);
        COPY_CHARS(part, s + a, l);
        CHARS_STRING(part)[l] = 0;
        pos++;
        AssPlist(res, pos, part);
        s = CONST_CHARS_STRING(string);
        a = z+1;
      }
    }
  }
  
  // Pick up a substring at the end of the string.  Note that a trailing
  // separator does not produce an empty string.
  if (a<z) {
    /* copy until last position which is z-1 */
    l = z-a;
    part = NEW_STRING(l);
    s = CONST_CHARS_STRING(string);
    COPY_CHARS(part, s + a, l);
    CHARS_STRING(part)[l] = 0;
    pos++;
    AssPlist(res, pos, part);
  }

  return res;
}

#ifdef HPCGAP

/****************************************************************************
**
*F FuncFIND_ALL_IN_STRING( <self>, <string>, <chars> )
**
** Kernel function to return a list of all occurrences of a set of characters
** within a string.
*/

static Obj FuncFIND_ALL_IN_STRING(Obj self, Obj string, Obj chars)
{
  Obj result;
  UInt i, len, matches;
  unsigned char table[1<<(8*sizeof(char))];
  const UInt1 *s;
  if (!IsStringConv(string) || !IsStringConv(chars))
    ErrorQuit("FIND_ALL_IN_STRING: Requires two string arguments", 0, 0);
  memset(table, 0, sizeof(table));
  len = GET_LEN_STRING(chars);
  s = CONST_CHARS_STRING(chars);
  for (i=0; i<len; i++)
    table[s[i]] = 1;
  len = GET_LEN_STRING(string);
  s = CONST_CHARS_STRING(string);
  matches = 0;
  for (i = 0; i < len; i++)
    if (table[s[i]])
      matches++;
  result = NEW_PLIST(T_PLIST_DENSE, matches);
  SET_LEN_PLIST(result, matches);
  matches = 1;
  for (i = 0; i < len; i++)
    if (table[s[i]]) {
      SET_ELM_PLIST(result, matches, INTOBJ_INT(i+1));
      matches++;
    }
  return result;
}

/****************************************************************************
**
*F FuncNORMALIZE_NEWLINES( <self>, <string> )
**
** Kernel function to replace all occurrences of CR or CRLF within a
** string with LF characters. This function modifies its argument and
** returns it also as its result.
*/

static Obj FuncNORMALIZE_NEWLINES(Obj self, Obj string)
{
  UInt i, j, len;
  Char *s;
  if (!IsStringConv(string) || !REGION(string))
    ErrorQuit("NORMALIZE_NEWLINES: Requires a mutable string argument", 0, 0);
  len = GET_LEN_STRING(string);
  s = CSTR_STRING(string);
  for (i = j = 0; i < len; i++) {
    if (s[i] == '\r') {
      s[j++] = '\n';
      if (i + 1 < len && s[i+1] == '\n')
        i++;
    } else {
      s[j++] = s[i];
    }
  }
  SET_LEN_STRING(string, j);
  return string;
}

#endif

/****************************************************************************
**
*F FuncSMALLINT_STR( <self>, <string> )
**
** Kernel function to extract parse small integers from strings. Needed before
** we can conveniently have Int working for things like parsing command line
** options
*/

static Obj FuncSMALLINT_STR(Obj self, Obj str)
{
  const Char *string = CONST_CSTR_STRING(str);
  Int x = 0;
  Int sign = 1;
  while (isspace((unsigned int)*string))
    string++;
  if (*string == '-') {
    sign = -1;
    string++;
  } else if (*string == '+') {
    string++;
  }
  const Char * start = string;
  while (IsDigit(*string)) {
    x *= 10;
    x += (*string - '0');
    string++;
  }
  if (start == string || *string)
    return Fail;
  return INTOBJ_INT(sign*x);
}


/****************************************************************************
**
*F  UnbString( <string>, <pos> ) . . . . . .  unbind an element from a string
**
**  This is to avoid unpacking of the string to a plain list when <pos> is
**  larger or equal to the length of <string>.
*/
static void UnbString(Obj string, Int pos)
{
    GAP_ASSERT(IS_MUTABLE_OBJ(string));
    const Int len = GET_LEN_STRING(string);
    if (len == pos) {
        // maybe the string becomes sorted
        CLEAR_FILTS_LIST(string);
        CHARS_STRING(string)[pos - 1] = (UInt1)0;
        SET_LEN_STRING(string, len - 1);
    }
    else if (pos < len) {
        PLAIN_LIST(string);
        UNB_LIST(string, pos);
    }
}


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize module * * * * * * * * * * * * * * * */

/****************************************************************************
**
*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_CHAR,                           "character"                      },
  { T_STRING,                         "list (string)"                  },
  { T_STRING              +IMMUTABLE, "list (string,imm)"              },
  { T_STRING_SSORT,                   "list (string,ssort)"            },
  { T_STRING_SSORT        +IMMUTABLE, "list (string,ssort,imm)"        },
  { T_STRING_NSORT,                   "list (string,nsort)"            },
  { T_STRING_NSORT        +IMMUTABLE, "list (string,nsort,imm)"        },
  { -1,                               ""                               }
};


/****************************************************************************
**
*V  ClearFiltsTab . . . . . . . . . . . . . . . . . . . .  clear filter tnums
*/
static Int ClearFiltsTab [] = {
    T_STRING,                 T_STRING,
    T_STRING_NSORT,           T_STRING,
    T_STRING_SSORT,           T_STRING,
    -1,                       -1
};


/****************************************************************************
**
*V  HasFiltTab  . . . . . . . . . . . . . . . . . . . . .  tester filter tnum
*/
static Int HasFiltTab [] = {

    // string
    T_STRING,                  FN_IS_DENSE,   1,
    T_STRING,                  FN_IS_NDENSE,  0,
    T_STRING,                  FN_IS_HOMOG,   1,
    T_STRING,                  FN_IS_NHOMOG,  0,
    T_STRING,                  FN_IS_TABLE,   0,
    T_STRING,                  FN_IS_RECT,    0,
    T_STRING,                  FN_IS_SSORT,   0,
    T_STRING,                  FN_IS_NSORT,   0,

    // ssort string
    T_STRING_SSORT,            FN_IS_DENSE,   1,
    T_STRING_SSORT,            FN_IS_NDENSE,  0,
    T_STRING_SSORT,            FN_IS_HOMOG,   1,
    T_STRING_SSORT,            FN_IS_NHOMOG,  0,
    T_STRING_SSORT,            FN_IS_TABLE,   0,
    T_STRING_SSORT,            FN_IS_RECT,    0,
    T_STRING_SSORT,            FN_IS_SSORT,   1,
    T_STRING_SSORT,            FN_IS_NSORT,   0,

    // nsort string
    T_STRING_NSORT,            FN_IS_DENSE,   1,
    T_STRING_NSORT,            FN_IS_NDENSE,  0,
    T_STRING_NSORT,            FN_IS_HOMOG,   1,
    T_STRING_NSORT,            FN_IS_NHOMOG,  0,
    T_STRING_NSORT,            FN_IS_TABLE,   0,
    T_STRING_NSORT,            FN_IS_RECT,    0,
    T_STRING_NSORT,            FN_IS_SSORT,   0,
    T_STRING_NSORT,            FN_IS_NSORT,   1,

    -1,                        -1,            -1
};


/****************************************************************************
**
*V  SetFiltTab  . . . . . . . . . . . . . . . . . . . . .  setter filter tnum
*/
static Int SetFiltTab [] = {

    // string
    T_STRING,                  FN_IS_DENSE,   T_STRING,
    T_STRING,                  FN_IS_NDENSE,  -1,
    T_STRING,                  FN_IS_HOMOG,   T_STRING,
    T_STRING,                  FN_IS_NHOMOG,  -1,
    T_STRING,                  FN_IS_TABLE,   -1,
    T_STRING,                  FN_IS_RECT,    -1,
    T_STRING,                  FN_IS_SSORT,   T_STRING_SSORT,
    T_STRING,                  FN_IS_NSORT,   T_STRING_NSORT,

    // ssort string
    T_STRING_SSORT,            FN_IS_DENSE,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_NDENSE,  -1,
    T_STRING_SSORT,            FN_IS_HOMOG,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_NHOMOG,  -1,
    T_STRING_SSORT,            FN_IS_TABLE,   -1,
    T_STRING_SSORT,            FN_IS_RECT,    -1,
    T_STRING_SSORT,            FN_IS_SSORT,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_NSORT,   -1,

    // nsort string
    T_STRING_NSORT,            FN_IS_DENSE,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_NDENSE,  -1,
    T_STRING_NSORT,            FN_IS_HOMOG,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_NHOMOG,  -1,
    T_STRING_NSORT,            FN_IS_TABLE,   -1,
    T_STRING_NSORT,            FN_IS_RECT,    -1,
    T_STRING_NSORT,            FN_IS_SSORT,   -1,
    T_STRING_NSORT,            FN_IS_NSORT,   T_STRING_NSORT,

    -1,                        -1,            -1

};


/****************************************************************************
**
*V  ResetFiltTab  . . . . . . . . . . . . . . . . . . .  unsetter filter tnum
*/
static Int ResetFiltTab [] = {

    // string
    T_STRING,                  FN_IS_DENSE,   T_STRING,
    T_STRING,                  FN_IS_NDENSE,  T_STRING,
    T_STRING,                  FN_IS_HOMOG,   T_STRING,
    T_STRING,                  FN_IS_NHOMOG,  T_STRING,
    T_STRING,                  FN_IS_TABLE,   T_STRING,
    T_STRING,                  FN_IS_RECT,    T_STRING,
    T_STRING,                  FN_IS_SSORT,   T_STRING,
    T_STRING,                  FN_IS_NSORT,   T_STRING,

    // ssort string
    T_STRING_SSORT,            FN_IS_DENSE,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_NDENSE,  T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_HOMOG,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_NHOMOG,  T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_TABLE,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_RECT,    T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_SSORT,   T_STRING,
    T_STRING_SSORT,            FN_IS_NSORT,   T_STRING_SSORT,

    // nsort string
    T_STRING_NSORT,            FN_IS_DENSE,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_NDENSE,  T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_HOMOG,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_NHOMOG,  T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_TABLE,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_RECT,    T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_SSORT,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_NSORT,   T_STRING,

    -1,                        -1,            -1

};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    GVAR_FILT(IS_STRING, "obj", &IsStringFilt),
    GVAR_FILT(IS_STRING_REP, "obj", &IsStringRepFilt),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {
    GVAR_FUNC_1ARGS(VIEW_STRING_FOR_STRING, string),
    GVAR_FUNC_1ARGS(IS_STRING_CONV, string),
    GVAR_FUNC_1ARGS(CONV_STRING, string),
    GVAR_FUNC_1ARGS(COPY_TO_STRING_REP, string),
    GVAR_FUNC_1ARGS(CHAR_INT, integer),
    GVAR_FUNC_1ARGS(INT_CHAR, char),
    GVAR_FUNC_1ARGS(CHAR_SINT, integer),
    GVAR_FUNC_1ARGS(SINT_CHAR, char),
    GVAR_FUNC_1ARGS(STRING_SINTLIST, list),
    GVAR_FUNC_2ARGS(INTLIST_STRING, string, sign),
    GVAR_FUNC_1ARGS(SINTLIST_STRING, string),
    GVAR_FUNC_1ARGS(EmptyString, len),
    GVAR_FUNC_1ARGS(ShrinkAllocationString, str),
    GVAR_FUNC_1ARGS(REVNEG_STRING, string),
    GVAR_FUNC_3ARGS(POSITION_SUBSTRING, string, substr, off),
#ifdef HPCGAP
    GVAR_FUNC_2ARGS(FIND_ALL_IN_STRING, string, characters),
    GVAR_FUNC_1ARGS(NORMALIZE_NEWLINES, string),
#endif
    GVAR_FUNC_1ARGS(NormalizeWhitespace, string),
    GVAR_FUNC_2ARGS(REMOVE_CHARACTERS, string, rem),
    GVAR_FUNC_2ARGS(TranslateString, string, trans),
    GVAR_FUNC_3ARGS(SplitStringInternal, string, seps, wspace),
    GVAR_FUNC_1ARGS(SMALLINT_STR, string),
    { 0, 0, 0, 0, 0 }

};


/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Char CharCookie[256][21];

static Int InitKernel (
    StructInitInfo *    module )
{
    UInt                t1;
    UInt                t2;
    Int                 i, j;
    const Char *        cookie_base = "src/stringobj.c:Char";

    /* GASMAN marking functions and GASMAN names                           */
    InitBagNamesFromTable( BagNames );

    InitMarkFuncBags( T_CHAR , MarkNoSubBags );
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1 += 2 ) {
        InitMarkFuncBags( t1                     , MarkNoSubBags );
        InitMarkFuncBags( t1          +IMMUTABLE , MarkNoSubBags );
    }

#ifdef HPCGAP
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1 += 2 ) {
      MakeBagTypePublic( t1 + IMMUTABLE );
    }
    MakeBagTypePublic(T_CHAR);
#endif

    /* make all the character constants once and for all                   */
    for ( i = 0; i < 256; i++ ) {
        for (j = 0; j < 17; j++ ) {
            CharCookie[i][j] = cookie_base[j];
        }
        CharCookie[i][j++] = '0' + i/100;
        CharCookie[i][j++] = '0' + (i % 100)/10;
        CharCookie[i][j++] = '0' + i % 10;
        CharCookie[i][j++] = '\0';
        InitGlobalBag( &ObjsChar[i], &(CharCookie[i][0]) );
    }

    /* install the type method                                             */
    ImportGVarFromLibrary( "TYPE_CHAR", &TYPE_CHAR );
    TypeObjFuncs[ T_CHAR ] = TypeChar;

    /* install the type method                                             */
    ImportGVarFromLibrary( "TYPES_STRING", &TYPES_STRING );
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1 += 2 ) {
        TypeObjFuncs[ t1            ] = TypeString;
        TypeObjFuncs[ t1 +IMMUTABLE ] = TypeString;
    }

    /* init filters and functions                                          */
    InitHdlrFiltsFromTable( GVarFilts );
    InitHdlrFuncsFromTable( GVarFuncs );

    /* initialise list tables                                              */
    InitClearFiltsTNumsFromTable   ( ClearFiltsTab );
    InitHasFiltListTNumsFromTable  ( HasFiltTab    );
    InitSetFiltListTNumsFromTable  ( SetFiltTab    );
    InitResetFiltListTNumsFromTable( ResetFiltTab  );

#ifdef GAP_ENABLE_SAVELOAD
    /* Install the saving function                                         */
    SaveObjFuncs[ T_CHAR ] = SaveChar;
    LoadObjFuncs[ T_CHAR ] = LoadChar;
#endif

    /* install the character functions                                     */
    PrintObjFuncs[ T_CHAR ] = PrintChar;
    EqFuncs[ T_CHAR ][ T_CHAR ] = EqChar;
    LtFuncs[ T_CHAR ][ T_CHAR ] = LtChar;

#ifdef GAP_ENABLE_SAVELOAD
    /* install the saving method                                             */
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1 += 2 ) {
        SaveObjFuncs[ t1            ] = SaveString;
        SaveObjFuncs[ t1 +IMMUTABLE ] = SaveString;
        LoadObjFuncs[ t1            ] = LoadString;
        LoadObjFuncs[ t1 +IMMUTABLE ] = LoadString;
    }
#endif

#if !defined(USE_THREADSAFE_COPYING)
    /* install the copy method                                             */
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1 += 2 ) {
        CopyObjFuncs [ t1                     ] = CopyString;
        CopyObjFuncs [ t1          +IMMUTABLE ] = CopyString;
        CleanObjFuncs[ t1                     ] = 0;
        CleanObjFuncs[ t1          +IMMUTABLE ] = 0;
    }
#endif

    /* install the print method                                            */
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1 += 2 ) {
        PrintObjFuncs[ t1            ] = PrintString;
        PrintObjFuncs[ t1 +IMMUTABLE ] = PrintString;
    }

    /* install the comparison methods                                      */
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT+IMMUTABLE; t1++ ) {
        for ( t2 = T_STRING; t2 <= T_STRING_SSORT+IMMUTABLE; t2++ ) {
            EqFuncs[ t1 ][ t2 ] = EqString;
            LtFuncs[ t1 ][ t2 ] = LtString;
        }
    }

    /* install the list methods                                            */
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1 += 2 ) {
        LenListFuncs    [ t1            ] = LenString;
        LenListFuncs    [ t1 +IMMUTABLE ] = LenString;
        IsbListFuncs    [ t1            ] = IsbString;
        IsbListFuncs    [ t1 +IMMUTABLE ] = IsbString;
        Elm0ListFuncs   [ t1            ] = Elm0String;
        Elm0ListFuncs   [ t1 +IMMUTABLE ] = Elm0String;
        Elm0vListFuncs  [ t1            ] = Elm0vString;
        Elm0vListFuncs  [ t1 +IMMUTABLE ] = Elm0vString;
        ElmListFuncs    [ t1            ] = ElmString;
        ElmListFuncs    [ t1 +IMMUTABLE ] = ElmString;
        ElmvListFuncs   [ t1            ] = ElmvString;
        ElmvListFuncs   [ t1 +IMMUTABLE ] = ElmvString;
        ElmwListFuncs   [ t1            ] = ElmwString;
        ElmwListFuncs   [ t1 +IMMUTABLE ] = ElmwString;
        ElmsListFuncs   [ t1            ] = ElmsString;
        ElmsListFuncs   [ t1 +IMMUTABLE ] = ElmsString;
        UnbListFuncs    [ t1            ] = UnbString;
        AssListFuncs    [ t1            ] = AssString;
        AsssListFuncs   [ t1            ] = AsssString;
        IsDenseListFuncs[ t1            ] = AlwaysYes;
        IsDenseListFuncs[ t1 +IMMUTABLE ] = AlwaysYes;
        IsHomogListFuncs[ t1            ] = AlwaysYes;
        IsHomogListFuncs[ t1 +IMMUTABLE ] = AlwaysYes;
        IsTableListFuncs[ t1            ] = AlwaysNo;
        IsTableListFuncs[ t1 +IMMUTABLE ] = AlwaysNo;
        IsSSortListFuncs[ t1            ] = IsSSortString;
        IsSSortListFuncs[ t1 +IMMUTABLE ] = IsSSortString;
        IsPossListFuncs [ t1            ] = IsPossString;
        IsPossListFuncs [ t1 +IMMUTABLE ] = IsPossString;
        PosListFuncs    [ t1            ] = PosString;
        PosListFuncs    [ t1 +IMMUTABLE ] = PosString;
        PlainListFuncs  [ t1            ] = PlainString;
        PlainListFuncs  [ t1 +IMMUTABLE ] = PlainString;
    }
    IsSSortListFuncs[ T_STRING_NSORT            ] = AlwaysNo;
    IsSSortListFuncs[ T_STRING_NSORT +IMMUTABLE ] = AlwaysNo;
    IsSSortListFuncs[ T_STRING_SSORT            ] = AlwaysYes;
    IsSSortListFuncs[ T_STRING_SSORT +IMMUTABLE ] = AlwaysYes;


    /* install the `IsString' functions                                    */
    for ( t1 = FIRST_REAL_TNUM; t1 <= LAST_REAL_TNUM; t1++ ) {
        assert(IsStringFuncs[ t1 ] == 0);
        IsStringFuncs[ t1 ] = AlwaysNo;
    }

    IsStringFuncs[ T_PLIST                 ] = IsStringList;
    IsStringFuncs[ T_PLIST      +IMMUTABLE ] = IsStringList;
    IsStringFuncs[ T_PLIST_DENSE           ] = IsStringList;
    IsStringFuncs[ T_PLIST_DENSE+IMMUTABLE ] = IsStringList;
    IsStringFuncs[ T_PLIST_EMPTY           ] = AlwaysYes;
    IsStringFuncs[ T_PLIST_EMPTY+IMMUTABLE ] = AlwaysYes;

    for ( t1 = T_PLIST_HOM; t1 <= T_PLIST_HOM_SSORT; t1 += 2 ) {
        IsStringFuncs[ t1            ] = IsStringListHom;
        IsStringFuncs[ t1 +IMMUTABLE ] = IsStringListHom;
    }

    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1++ ) {
        IsStringFuncs[ t1 ] = AlwaysYes;
    }

    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        IsStringFuncs[ t1 ] = IsStringObject;
    }

    MakeImmutableObjFuncs[ T_STRING       ] = MakeImmutableNoRecurse;
    MakeImmutableObjFuncs[ T_STRING_SSORT ] = MakeImmutableNoRecurse;
    MakeImmutableObjFuncs[ T_STRING_NSORT ] = MakeImmutableNoRecurse;

    return 0;
}


/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
*/
static Int InitLibrary (
    StructInitInfo *    module )
{
    Int                 i;
    

    /* make all the character constants once and for all                   */
    for ( i = 0; i < 256; i++ ) {
        ObjsChar[i] = NewBag(T_CHAR, 1);
        SET_CHAR_VALUE(ObjsChar[i], (UChar)i);
    }

    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    return 0;
}


/****************************************************************************
**
*F  InitInfoString()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "string",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoString ( void )
{
    return &module;
}
