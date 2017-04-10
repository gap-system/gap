/****************************************************************************
**
*W  stringobj.c                    GAP source                     Frank Lübeck,
*W                                            Frank Celler & Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
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
**  Note that a list represented by a bag of type  'T_PLIST' or 'T_SET' might
**  still be a string.  It is just that the kernel does not know this.
**
**  This package consists of three parts.
**  
**  The first part consists of the macros 'NEW_STRING', 'CHARS_STRING' (or
**  'CSTR_STRING'),  'GET_LEN_STRING', 'SET_LEN_STRING', 'GET_ELM_STRING',
**  'SET_ELM_STRING'  and  'C_NEW_STRING'.  These and  the functions below
**  use the detailed knowledge about the respresentation of strings.
**  
**  The second part  consists  of  the  functions  'LenString',  'ElmString',
**  'ElmsStrings', 'AssString',  'AsssString', PlainString', 'IsDenseString',
**  and 'IsPossString'.  They are the functions requried by the generic lists
**  package.  Using these functions the other  parts of the {\GAP} kernel can
**  access and  modify strings  without actually  being aware  that they  are
**  dealing with a string.
**
**  The third part consists  of the functions 'PrintString', which is  called
**  by 'FunPrint', and 'IsString', which test whether an arbitrary list  is a
** string, and if so converts it into the above format.  
*/
#include <src/system.h>                 /* system dependent part */


#include <src/gasman.h>                 /* garbage collector */
#include <src/objects.h>                /* objects */
#include <src/scanner.h>                /* scanner */
#include <src/code.h>                   /* coder */

#include <src/gap.h>                    /* error handling, initialisation */

#include <src/gvars.h>                  /* global variables */
#include <src/calls.h>                  /* generic call mechanism */
#include <src/opers.h>                  /* generic operations */

#include <src/ariths.h>                 /* basic arithmetic */

#include <src/bool.h>                   /* booleans */

#include <src/records.h>                /* generic records */
#include <src/precord.h>                /* plain records */

#include <src/lists.h>                  /* generic lists */
#include <src/plist.h>                  /* plain lists */
#include <src/range.h>                  /* ranges */

#include <src/stringobj.h>              /* strings */

#include <src/saveload.h>               /* saving and loading */
#include <src/hpc/tls.h>                /* thread-local storage */

#include <assert.h>


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
Obj TYPE_CHAR;

Obj TypeChar (
    Obj                 chr )
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
Int EqChar (
    Obj                 charL,
    Obj                 charR )
{
    return (*(UChar*)ADDR_OBJ(charL) == *(UChar*)ADDR_OBJ(charR));
}


/****************************************************************************
**
*F  LtChar( <charL>, <charR> )  . . . . . . . . . . .  compare two characters
**
**  'LtChar' returns  'true' if the    character <charL>  is less than    the
**  character <charR>, and 'false' otherwise.
*/
Int LtChar (
    Obj                 charL,
    Obj                 charR )
{
    return (*(UChar*)ADDR_OBJ(charL) < *(UChar*)ADDR_OBJ(charR));
}


/****************************************************************************
**
*F  PrintChar( <chr> )  . . . . . . . . . . . . . . . . . . print a character
**
**  'PrChar' prints the character <chr>.
*/
void PrintChar (
    Obj                 val )
{
    UChar               chr;

    chr = *(UChar*)ADDR_OBJ(val);
    if      ( chr == '\n'  )  Pr("'\\n'",0L,0L);
    else if ( chr == '\t'  )  Pr("'\\t'",0L,0L);
    else if ( chr == '\r'  )  Pr("'\\r'",0L,0L);
    else if ( chr == '\b'  )  Pr("'\\b'",0L,0L);
    else if ( chr == '\01' )  Pr("'\\>'",0L,0L);
    else if ( chr == '\02' )  Pr("'\\<'",0L,0L);
    else if ( chr == '\03' )  Pr("'\\c'",0L,0L);
    else if ( chr == '\''  )  Pr("'\\''",0L,0L);
    else if ( chr == '\\'  )  Pr("'\\\\'",0L,0L);
    /* print every non-printable on non-ASCII character in three digit
     * notation  */
    /*   old version (changed by FL)
    else if ( chr == '\0'  )  Pr("'\\0'",0L,0L);
    else if ( chr <  8     )  Pr("'\\0%d'",(Int)(chr&7),0L);
    else if ( chr <  32    )  Pr("'\\0%d%d'",(Int)(chr/8),(Int)(chr&7));*/
    else if ( chr < 32 || chr > 126 ) {
        Pr("'\\%d%d", (Int)((chr & 192) >> 6), (Int)((chr & 56) >> 3));
        Pr("%d'", (Int)(chr&7), 0L);
    }
    else                      Pr("'%c'",(Int)chr,0L);
}


/****************************************************************************
**
*F  SaveChar( <char> )  . . . . . . . . . . . . . . . . . .  save a character
**
*/
void SaveChar ( Obj c )
{
    SaveUInt1( *(UChar *)ADDR_OBJ(c));
}


/****************************************************************************
**
*F  LoadChar( <char> )  . . . . . . . . . . . . . . . . . .  load a character
**
*/
void LoadChar( Obj c )
{
    *(UChar *)ADDR_OBJ(c) = LoadUInt1();
}



/****************************************************************************
**

*F * * * * * * * * * * * * * * GAP level functions  * * * * * * * * * * * * *
*/


/****************************************************************************
**
*F  FuncEmptyString( <self>, <len> ) . . . . . . . empty string with space
*
* Returns an empty string, but with space for len characters preallocated.
*
*/
Obj    FuncEmptyString( Obj self, Obj len )
{
    Obj                 new;
    while ( ! IS_INTOBJ(len) ) {
        len = ErrorReturnObj(
            "<len> must be an integer (not a %s)",
            (Int)TNAM_OBJ(len), 0L,
            "you can replace <len> via 'return <len>;'" );
    }

    new = NEW_STRING(INT_INTOBJ(len));
    SET_LEN_STRING(new, 0);
    return new;
}

/****************************************************************************
**
*F  FuncShrinkAllocationString( <self>, <str> )  . . give back unneeded memory
*
*  Shrinks the bag of <str> to minimal possible size (possibly converts to 
*  compact representation).
*
*/
Obj   FuncShrinkAllocationString( Obj self, Obj str )
{
    while (! IsStringConv(str)) {
       str = ErrorReturnObj(
           "<str> must be a string, not a %s)",
           (Int)TNAM_OBJ(str), 0L,
           "you can replace <str> via 'return <str>;'" );
    }
    SHRINK_STRING(str);
    return (Obj)0;
}

/****************************************************************************
**
*F  FuncCHAR_INT( <self>, <int> ) . . . . . . . . . . . . . . char by integer
*/
Obj FuncCHAR_INT (
    Obj             self,
    Obj             val )
{
    Int             chr;

    /* get and check the integer value                                     */
again:
    while ( ! IS_INTOBJ(val) ) {
        val = ErrorReturnObj(
            "<val> must be an integer (not a %s)",
            (Int)TNAM_OBJ(val), 0L,
            "you can replace <val> via 'return <val>;'" );
    }
    chr = INT_INTOBJ(val);
    if ( 255 < chr || chr < 0 ) {
        val = ErrorReturnObj(
            "<val> must be an integer between 0 and 255",
            0L, 0L, "you can replace <val> via 'return <val>;'" );
        goto again;
    }

    /* return the character                                                */
    return ObjsChar[chr];
}


/****************************************************************************
**
*F  FuncINT_CHAR( <self>, <char> )  . . . . . . . . . . . . . integer by char
*/
Obj FuncINT_CHAR (
    Obj             self,
    Obj             val )
{
    /* get and check the character                                         */
    while ( TNUM_OBJ(val) != T_CHAR ) {
        val = ErrorReturnObj(
            "<val> must be a character (not a %s)",
            (Int)TNAM_OBJ(val), 0L,
            "you can replace <val> via 'return <val>;'" );
    }

    /* return the character                                                */
    return INTOBJ_INT(*(UChar*)ADDR_OBJ(val));
}

/****************************************************************************
**
*F  FuncCHAR_SINT( <self>, <int> ) .. . . . . . . . . . char by signed integer
*/
Obj FuncCHAR_SINT (
    Obj             self,
    Obj             val )
{
  Int             chr;

  /* get and check the integer value                                     */
agains:
  while ( ! IS_INTOBJ(val) ) {
      val = ErrorReturnObj(
	  "<val> must be an integer (not a %s)",
	  (Int)TNAM_OBJ(val), 0L,
	  "you can replace <val> via 'return <val>;'" );
  }
  chr = INT_INTOBJ(val);
  if ( 127 < chr || chr < -128 ) {
      val = ErrorReturnObj(
	  "<val> must be an integer between -128 and 127",
	  0L, 0L, "you can replace <val> via 'return <val>;'" );
      goto agains;
  }

    /* return the character                                                */
    return ObjsChar[CHAR_SINT(chr)];
}


/****************************************************************************
**
*F  FuncSINT_CHAR( <self>, <char> ) . . . . . . . . .  signed integer by char
*/
Obj FuncSINT_CHAR (
    Obj             self,
    Obj             val )
{
  /* get and check the character                                         */
  while ( TNUM_OBJ(val) != T_CHAR ) {
      val = ErrorReturnObj(
	  "<val> must be a character (not a %s)",
	  (Int)TNAM_OBJ(val), 0L,
	  "you can replace <val> via 'return <val>;'" );
  }

  /* return the character                                                */
  return INTOBJ_INT(SINT_CHAR(*(UChar*)ADDR_OBJ(val)));
}

/****************************************************************************
**
*F  FuncSINTLIST_STRING( <self>, <string> ) signed integer list by string
*/
Obj SINTCHARS[256];
Obj INTCHARS[256];
Obj FuncINTLIST_STRING (
    Obj             self,
    Obj             val,
    Obj             sign )
{
  UInt l,i;
  Obj n, *addr, *ints;
  UInt1 *p;

  /* test whether val is a string, convert to compact rep if necessary */
  while (! IsStringConv(val)) {
     val = ErrorReturnObj(
         "<val> must be a string, not a %s)",
         (Int)TNAM_OBJ(val), 0L,
         "you can replace <val> via 'return <val>;'" );
  }

  /* initialize before first use */
  if ( SINTCHARS[0] == (Obj) 0 )
     for (i=0; i<256; i++) {
       SINTCHARS[i] = INTOBJ_INT(SINT_CHAR(i));
       INTCHARS[i] = INTOBJ_INT((UInt1)i);
     }
       

  l=GET_LEN_STRING(val);
  n=NEW_PLIST(T_PLIST,l);
  SET_LEN_PLIST(n,l);
  p=CHARS_STRING(val);
  addr=ADDR_OBJ(n);
  /* signed or unsigned ? */
  if (sign == INTOBJ_INT(1L)) 
    ints = INTCHARS;
  else
    ints = SINTCHARS;
  for (i=1; i<=l; i++) {
    addr[i] = ints[p[i-1]];
  }

  CHANGED_BAG(n);
  return n;
}

Obj FuncSINTLIST_STRING (
    Obj             self,
    Obj             val )
{
  return FuncINTLIST_STRING ( self, val, INTOBJ_INT(-1L) );
}

/****************************************************************************
**
*F  FuncSTRING_SINTLIST( <self>, <string> ) string by signed integer list
*/
Obj FuncSTRING_SINTLIST (
    Obj             self,
    Obj             val )
{
  UInt l,i;
  Int low, inc;
  Obj n;
  UInt1 *p;

  /* there should be a test here, but how do I check cheaply for list of
   * integers ? */

  /* general code */
  if (! IS_RANGE(val) ) {
    if (! IS_PLIST(val)) {
       val = ErrorReturnObj(
           "<val> must be a plain list or range, not a %s)",
           (Int)TNAM_OBJ(val), 0L,
           "you can replace <val> via 'return <val>;'" );
    }
       
    l=LEN_PLIST(val);
    n=NEW_STRING(l);
    p=CHARS_STRING(n);
    for (i=1;i<=l;i++) {
      *p++=CHAR_SINT(INT_INTOBJ(ELM_PLIST(val,i)));
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

  CHANGED_BAG(n);
  return n;
}

/****************************************************************************
**
*F  FuncREVNEG_STRING( <self>, <string> ) string by signed integer list
*/
Obj FuncREVNEG_STRING (
    Obj             self,
    Obj             val )
{
  UInt l,i,j;
  Obj n;
  UInt1 *p,*q;

  /* test whether val is a string, convert to compact rep if necessary */
  while (! IsStringConv(val)) {
     val = ErrorReturnObj(
         "<val> must be a string, not a %s)",
         (Int)TNAM_OBJ(val), 0L,
         "you can replace <val> via 'return <val>;'" );
  }

  l=GET_LEN_STRING(val);
  n=NEW_STRING(l);
  p=CHARS_STRING(val);
  q=CHARS_STRING(n);
  j=l-1;
  for (i=1;i<=l;i++) {
    /* *q++=CHAR_SINT(-SINT_CHAR(p[j])); */
    *q++=-p[j];
    j--;
  }

  CHANGED_BAG(n);
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
Obj NEW_STRING ( Int len )
{
  Obj res;
  if (len < 0)
       ErrorQuit(
           "NEW_STRING: Cannot create string of negative length %d",
           (Int)len, 0L);
  res = NewBag( T_STRING, SIZEBAG_STRINGLEN(len)  ); 
  SET_LEN_STRING(res, len);
  /* it may be sometimes useful to have trailing zero characters */
  CHARS_STRING(res)[0] = '\0';
  CHARS_STRING(res)[len] = '\0';
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

    /* find out how large the data area  should become                     */
    good = 5 * (GET_LEN_STRING(list)+3) / 4 + 1;

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


Obj TypeString (
    Obj                 list )
{
    return ELM_PLIST(TYPES_STRING, TNUM_OBJ(list) - T_STRING + 1);
}



/****************************************************************************
**

*F * * * * * * * * * * * * * * copy functions * * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  CopyString( <list>, <mut> ) . . . . . . . . . . . . . . . . copy a string
**
**  'CopyString' returns a structural (deep) copy of the string <list>, i.e.,
**  a recursive copy that preserves the structure.
**
**  If <list> has not  yet  been copied, it makes   a copy, leaves  a forward
**  pointer to the copy in  the first entry of  the string, where the size of
**  the string usually resides,  and copies  all the  entries.  If  the plain
**  list  has already  been copied, it   returns the value of the  forwarding
**  pointer.
**
**  'CopyString' is the function in 'CopyObjFuncs' for strings.
**
**  'CleanString' removes the mark and the forwarding pointer from the string
**  <list>.
**
**  'CleanString' is the function in 'CleanObjFuncs' for strings.
*/
Obj CopyString (
    Obj                 list,
    Int                 mut )
{
    Obj                 copy;           /* handle of the copy, result      */

    /* just return immutable objects                                       */
    if ( ! IS_MUTABLE_OBJ(list) ) {
        return list;
    }

    /* make object for  copy                                               */
    if ( mut ) {
        copy = NewBag( TNUM_OBJ(list), SIZE_OBJ(list) );
    }
    else {
        copy = NewBag( IMMUTABLE_TNUM( TNUM_OBJ(list) ), SIZE_OBJ(list) );
    }
    ADDR_OBJ(copy)[0] = ADDR_OBJ(list)[0];

    /* leave a forwarding pointer                                          */
    ADDR_OBJ(list)[0] = copy;
    CHANGED_BAG( list );

    /* now it is copied                                                    */
    MARK_LIST( list, COPYING );

    /* copy the subvalues                                                  */
    memcpy((void*)(ADDR_OBJ(copy)+1), (void*)(ADDR_OBJ(list)+1), 
           ((SIZE_OBJ(copy)+sizeof(Obj)-1)/sizeof(Obj)-1) * sizeof(Obj));

    /* return the copy                                                     */
    return copy;
}

/****************************************************************************
**
*F  CopyStringCopy( <list>, <mut> ) . . . . . . . . . .  copy a copied string
*/
Obj CopyStringCopy (
    Obj                 list,
    Int                 mut )
{
    return ADDR_OBJ(list)[0];
}


/****************************************************************************
**
*F  CleanString( <list> ) . . . . . . . . . . . . . . . . . clean up a string
*/
void CleanString (
    Obj                 list )
{
}


/****************************************************************************
**
*F  CleanStringCopy( <list> ) . . . . . . . . . . .  clean up a copied string
*/
void CleanStringCopy (
    Obj                 list )
{
    /* remove the forwarding pointer                                       */
    ADDR_OBJ(list)[0] = ADDR_OBJ( ADDR_OBJ(list)[0] )[0];

    /* now it is cleaned                                                   */
    UNMARK_LIST( list, COPYING );
}


/****************************************************************************
**

*F * * * * * * * * * * * * * * list functions * * * * * * * * * * * * * * * *
*/

/****************************************************************************
**


*F  PrintString(<list>) . . . . . . . . . . . . . . . . . . .  print a string
**
**  'PrintString' prints the string with the handle <list>.
**
**  No linebreaks are  allowed, if one must be inserted  anyhow, it must
**  be escaped by a backslash '\', which is done in 'Pr'.
**
**  The kernel  buffer PrStrBuf  is used to  protect Pr  against garbage
**  collections caused by  printing to string streams,  which might move
**  the body of list.
**
**  The output uses octal number notation for non-ascii or non-printable
**  characters. The function can be used  to print *any* string in a way
**  which can be read in by GAP afterwards.
**
*/

void PrintString (
    Obj                 list )
{
  char PrStrBuf[10007];	/* 7 for a \c\123 at the end */
  UInt scanout, n;
  UInt1 c;
  UInt len = GET_LEN_STRING(list);
  UInt off = 0;
  Pr("\"", 0L, 0L);
  while (off < len)
    {
      scanout = 0;
      do 
	{
	  c = CHARS_STRING(list)[off++];
	  switch (c)
	    {
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
              if (c < 32 || c>126) {
                 PrStrBuf[scanout++] = '\\';
                 n = c / 64;
                 c = c - n*64;
                 PrStrBuf[scanout++] = n + '0';
                 n = c / 8;
                 c = c - n*8;
                 PrStrBuf[scanout++] = n + '0';
                 PrStrBuf[scanout++] = c + '0'; 
              }
              else
                 PrStrBuf[scanout++] = c;
	    }
	}
      while (off < len && scanout < 10000);
      PrStrBuf[scanout++] = '\0';
      Pr( "%s", (Int)PrStrBuf, 0L );
    }
  Pr( "\"", 0L, 0L );
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
  char PrStrBuf[10007];	/* 7 for a \c\123 at the end */
  UInt len = GET_LEN_STRING(list);
  UInt scanout, off = 0;
  UInt1  *p;

  while (off < len)    {
    for (p = CHARS_STRING(list), scanout=0; 
         p[off] && off<len && scanout<10000; 
         off++, scanout++) {
      PrStrBuf[scanout] = p[off];
    }
    PrStrBuf[scanout] = '\0';
    Pr( "%s", (Int)PrStrBuf, 0L );
    for (; off<len && CHARS_STRING(list)[off]==0; off++) {
      Pr("%c", 0L, 0L);
    }
  }
}


/****************************************************************************
**
*F  EqString(<listL>,<listR>) . . . . . . . .  test whether strings are equal
**
**  'EqString'  returns  'true' if the  two  strings <listL>  and <listR> are
**  equal and 'false' otherwise.
*/
Int EqString (
    Obj                 listL,
    Obj                 listR )
{
  UInt lL, lR, i;
  UInt1 *pL, *pR;
  lL = GET_LEN_STRING(listL);
  lR = GET_LEN_STRING(listR);
  if (lR != lL) return 0;
  pL = CHARS_STRING(listL);
  pR = CHARS_STRING(listR);
  for (i=0; i<lL && pL[i] == pR[i]; i++);
  return (i == lL);
}


/****************************************************************************
**
*F  LtString(<listL>,<listR>) .  test whether one string is less than another
**
**  'LtString' returns 'true' if  the string <listL> is  less than the string
**  <listR> and 'false' otherwise.
*/
Int LtString (
    Obj                 listL,
    Obj                 listR )
{
  UInt lL, lR, i;
  UInt1 *pL, *pR;
  lL = GET_LEN_STRING(listL);
  lR = GET_LEN_STRING(listR);
  pL = CHARS_STRING(listL);
  pR = CHARS_STRING(listR);
  for (i=0; i<lL && i<lR && pL[i] == pR[i]; i++);
  if (i == lL) return (lR > lL);
  if (i == lR) return 0;
  return pL[i] < pR[i];
}


/****************************************************************************
**
*F  LenString(<list>) . . . . . . . . . . . . . . . . . .  length of a string
**
**  'LenString' returns the length of the string <list> as a C integer.
**
**  'LenString' is the function in 'LenListFuncs' for strings.
*/
Int LenString (
    Obj                 list )
{
    return GET_LEN_STRING( list );
}


/****************************************************************************
**
*F  IsbString(<list>,<pos>) . . . . . . . . . test for an element of a string
*F  IsbvString(<list>,<pos>)  . . . . . . . . test for an element of a string
**
**  'IsbString' returns 1 if the string <list> contains
**  a character at the position <pos> and 0 otherwise.
**  It can rely on <pos> being a positive integer.
**
**  'IsbvString' does the same thing as 'IsbString', but it can 
**  also rely on <pos> not being larger than the length of <list>.
**
**  'IsbString'  is the function in 'IsbListFuncs'  for strings.
**  'IsbvString' is the function in 'IsbvListFuncs' for strings.
*/
Int IsbString (
    Obj                 list,
    Int                 pos )
{
    /* since strings are dense, this must only test for the length         */
    return (pos <= GET_LEN_STRING(list));
}

Int IsbvString (
    Obj                 list,
    Int                 pos )
{
    /* since strings are dense, this can only return 1                     */
    return 1L;
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
Obj Elm0String (
    Obj                 list,
    Int                 pos )
{
    if ( pos <= GET_LEN_STRING( list ) ) {
        return GET_ELM_STRING( list, pos );
    }
    else {
        return 0;
    }
}

Obj Elm0vString (
    Obj                 list,
    Int                 pos )
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
Obj ElmString (
    Obj                 list,
    Int                 pos )
{
    /* check the position                                                  */
    if ( GET_LEN_STRING( list ) < pos ) {
        ErrorReturnVoid(
            "List Element: <list>[%d] must have an assigned value",
            (Int)pos, 0L,
            "you can 'return;' after assigning a value" );
        return ELM_LIST( list, pos );
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
Obj ElmsString (
    Obj                 list,
    Obj                 poss )
{
    Obj                 elms;         /* selected sublist, result        */
    Int                 lenList;        /* length of <list>                */
    Char                elm;            /* one element from <list>         */
    Int                 lenPoss;        /* length of <positions>           */
    Int                 pos;            /* <position> as integer           */
    Int                 inc;            /* increment in a range            */
    Int                 i;              /* loop variable                   */
    UInt1               *p, *pn;        /* loop pointer                    */

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
            pos = INT_INTOBJ( ELMW_LIST( poss, i ) );
            if ( lenList < pos ) {
                ErrorReturnVoid(
                    "List Elements: <list>[%d] must have an assigned value",
                    (Int)pos, 0L,
                    "you can 'return;' after assigning a value" );
                return ELMS_LIST( list, poss );
            }

            /* select the element                                          */
            elm = CHARS_STRING(list)[pos-1];

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
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)pos, 0L,
                "you can 'return;' after assigning a value" );
            return ELMS_LIST( list, poss );
        }
        if ( lenList < pos + (lenPoss-1) * inc ) {
            ErrorReturnVoid(
                "List Elements: <list>[%d] must have an assigned value",
                (Int)(pos + (lenPoss-1) * inc), 0L,
                "you can 'return;' after assigning a value" );
            return ELMS_LIST( list, poss );
        }

        /* make the result list                                            */
        elms = NEW_STRING( lenPoss );

        /* loop over the entries of <positions> and select                 */
	p = CHARS_STRING(list);
	pn = CHARS_STRING(elms);
        for ( i = 1; i <= lenPoss; i++, pos += inc ) {
	  pn[i-1] = p[pos-1];
        }

    }

    /* return the result                                                   */
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
void AssString (
    Obj                 list,
    Int                 pos,
    Obj                 val )
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
    /*    CHARS_STRING(list)[pos-1] = *((UInt1*)ADDR_OBJ(val)); */
    CHANGED_BAG( list );
  }
}    

void AssStringImm (
    Obj                 list,
    Int                 pos,
    Obj                 val )
{
    ErrorReturnVoid(
        "Lists Assignment: <list> must be a mutable list",
        0L, 0L,
        "you can 'return;' and ignore the assignment" );
}


/****************************************************************************
**
*F  AsssString(<list>,<poss>,<vals>)  . . assign several elements to a string
**
**  'AsssString' assignes the  values from the  list <vals> at the  positions
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
void AsssString (
    Obj                 list,
    Obj                 poss,
    Obj                 vals )
{
  Int i, len = LEN_LIST(poss);
  for (i = 1; i <= len; i++) {
    ASS_LIST(list, INT_INTOBJ(ELM_LIST(poss, i)), ELM_LIST(vals, i));
  }
}

void AsssStringImm (
    Obj                 list,
    Obj                 poss,
    Obj                 val )
{
    ErrorReturnVoid(
        "Lists Assignments: <list> must be a mutable list",
        0L, 0L,
        "you can 'return;' and ignore the assignment" );
}


/****************************************************************************
**
*F  IsDenseString(<list>) . . . . . . .  dense list test function for strings
**
**  'IsDenseString' returns 1, since every string is dense.
**
**  'IsDenseString' is the function in 'IsDenseListFuncs' for strings.
*/
Int IsDenseString (
    Obj                 list )
{
    return 1L;
}


/****************************************************************************
**
*F  IsHomogString(<list>) . . . .  homogeneous list test function for strings
**
**  'IsHomogString' returns  1 if  the string  <list>  is homogeneous.  Every
**  nonempty string is homogeneous.
**
**  'IsHomogString' is the function in 'IsHomogListFuncs' for strings.
*/
Int IsHomogString (
    Obj                 list )
{
    return (0 < GET_LEN_STRING(list));
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
Int IsSSortString (
    Obj                 list )
{
    Int                 len;
    Int                 i;
    UInt1 *             ptr;

    /* test whether the string is strictly sorted                          */
    len = GET_LEN_STRING( list );
    ptr = (UInt1*) CHARS_STRING(list);
    for ( i = 1; i < len; i++ ) {
        if ( ! (ptr[i-1] < ptr[i]) )
            break;
    }

    /* retype according to the outcome                                     */
    SET_FILT_LIST( list, (len <= i) ? FN_IS_SSORT : FN_IS_NSORT );
    return (len <= i);
}

Int IsSSortStringNot (
    Obj                 list )
{
    return 0L;
}

Int IsSSortStringYes (
    Obj                 list )
{
    return 1L;
}


/****************************************************************************
**
*F  IsPossString(<list>)  . . . . .  positions list test function for strings
**
**  'IsPossString' returns 0, since every string contains no integers.
**
**  'IsPossString' is the function in 'TabIsPossList' for strings.
*/
Int IsPossString (
    Obj                 list )
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
Obj PosString (
    Obj                 list,
    Obj                 val,
    Obj                 start )
{
    Int                 lenList;        /* length of <list>                */
    Int                 i;              /* loop variable                   */
    UInt1               valc;        /* C characters                    */
    UInt1               *p;             /* pointer to chars of <list>      */
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
    valc = *(UInt1*)ADDR_OBJ(val);

    /* search entries in <list>                                     */
    p = CHARS_STRING(list);
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
void PlainString (
    Obj                 list )
{
    Int                 lenList;        /* logical length of the string    */
    Obj                 tmp;            /* handle of the list              */
    Int                 i;              /* loop variable                   */

    /* find the length and allocate a temporary copy                       */
    lenList = GET_LEN_STRING( list );
    tmp = NEW_PLIST( IS_MUTABLE_OBJ(list) ? T_PLIST : T_PLIST+IMMUTABLE, lenList );
    SET_LEN_PLIST( tmp, lenList );

    /* copy the characters                                                 */
    for ( i = 1; i <= lenList; i++ ) {
        SET_ELM_PLIST( tmp, i, GET_ELM_STRING( list, i ) );
    }

    /* change size and type of the string and copy back                    */
    ResizeBag( list, SIZE_OBJ(tmp) );
    RetypeBag( list, TNUM_OBJ(tmp) );

    /*    Why not just copying the data area ? (FL)
	  SET_LEN_PLIST( list, lenList );
	  for ( i = 1; i <= lenList; i++ ) {
	  SET_ELM_PLIST( list, i, ELM_PLIST( tmp, i ) );
	  CHANGED_BAG( list );
	  }
    */
    memcpy((void*)ADDR_OBJ(list), (void*)ADDR_OBJ(tmp), SIZE_OBJ(tmp));
    CHANGED_BAG(list);
}


/****************************************************************************
**

*F  IS_STRING( <obj> )  . . . . . . . . . . . . test if an object is a string
**
**  'IS_STRING' returns 1  if the object <obj>  is a string  and 0 otherwise.
**  It does not change the representation of <obj>.
*/
Int (*IsStringFuncs [LAST_REAL_TNUM+1]) ( Obj obj );

Obj IsStringFilt;

Int IsStringNot (
    Obj                 obj )
{
    return 0;
}

Int IsStringYes (
    Obj                 obj )
{
    return 1;
}

Int IsStringList (
    Obj                 list )
{
    Int                 lenList;
    Obj                 elm;
    Int                 i;
    
    lenList = LEN_LIST( list );
    for ( i = 1; i <= lenList; i++ ) {
        elm = ELMV0_LIST( list, i );
        if ( elm == 0 || TNUM_OBJ( elm ) != T_CHAR )
            break;
    }

    return (lenList < i);
}

Int IsStringListHom (
    Obj                 list )
{
    return (TNUM_OBJ( ELM_LIST(list,1) ) == T_CHAR);
}

Int IsStringObject (
    Obj                 obj )
{
    return (DoFilter( IsStringFilt, obj ) != False);
}


/****************************************************************************
**
*F  CopyToStringRep( <string> )  . . copy a string to the string representation
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
        memcpy(ADDR_OBJ(copy), ADDR_OBJ(string), SIZE_OBJ(string));
        /* XXX no error checks? */
    } else {
        /* copy the string to the string representation                     */
        for ( i = 1; i <= lenString; i++ ) {
            elm = ELMW_LIST( string, i );
            CHARS_STRING(copy)[i-1] = *((UChar*)ADDR_OBJ(elm));
        } 
        CHARS_STRING(copy)[lenString] = '\0';
    }
    CHANGED_BAG(copy);
    return (copy);
}



/****************************************************************************
**
*F  ConvString( <string> )  . . convert a string to the string representation
**
**  'ConvString' converts the string <list> to the string representation.
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
        CHARS_STRING(tmp)[i-1] = *((UChar*)ADDR_OBJ(elm));
    }
    CHARS_STRING(tmp)[lenString] = '\0';

    /* copy back to string  */
    RetypeBag( string, IS_MUTABLE_OBJ(string)?T_STRING:T_STRING+IMMUTABLE );
    ResizeBag( string, SIZEBAG_STRINGLEN(lenString) );
    /* copy data area from tmp */
    memcpy((void*)ADDR_OBJ(string), (void*)ADDR_OBJ(tmp), SIZE_OBJ(tmp));
    CHANGED_BAG(string);
}



/****************************************************************************
**
*F  IsStringConv( <obj> ) . . . . . test if an object is a string and convert
**
**  'IsStringConv'   returns 1  if   the object <obj>  is   a  string,  and 0
**  otherwise.   If <obj> is a  string it  changes  its representation to the
**  string representation.
*/
Obj IsStringConvFilt;

Int IsStringConv (
    Obj                 obj )
{
    Int                 res;

    /* test whether the object is a string                                 */
    res = IS_STRING( obj );

    /* if so, convert it to the string representation                      */
    if ( res ) {
        ConvString( obj );
    }

    /* return the result                                                   */
    return res;
}


/****************************************************************************
**
*F  MakeImmutableString(  <str> ) make a string immutable in place
**
*/

void MakeImmutableString( Obj str )
{
    RetypeBag(str, IMMUTABLE_TNUM(TNUM_OBJ(str)));
}


Obj MakeString(const Char *cstr)
{
  Obj result;
  C_NEW_STRING(result, strlen(cstr), cstr);
  return result;
}

Obj MakeString2(const Char *cstr1, const Char *cstr2)
{
  Obj result;
  size_t len1 = strlen(cstr1), len2 = strlen(cstr2);
  result = NEW_STRING(len1 + len2);
  memcpy(CSTR_STRING(result), cstr1, len1);
  memcpy(CSTR_STRING(result)+len1, cstr2, len2);
  return result;
}

Obj MakeString3(const Char *cstr1, const Char *cstr2, const Char *cstr3)
{
  Obj result;
  size_t len1 = strlen(cstr1), len2 = strlen(cstr2), len3 = strlen(cstr3);
  result = NEW_STRING(len1 + len2 + len3);
  memcpy(CSTR_STRING(result), cstr1, len1);
  memcpy(CSTR_STRING(result)+len1, cstr2, len2);
  memcpy(CSTR_STRING(result)+len1+len2, cstr3, len3);
  return result;
}

Obj MakeImmString(const Char *cstr)
{
  Obj result = MakeString(cstr);
  MakeImmutableString(result);
  return result;
}

Obj MakeImmString2(const Char *cstr1, const Char *cstr2)
{
  Obj result = MakeString2(cstr1, cstr2);
  MakeImmutableString(result);
  return result;
}

Obj MakeImmString3(const Char *cstr1, const Char *cstr2, const Char *cstr3)
{
  Obj result = MakeString3(cstr1, cstr2, cstr3);
  MakeImmutableString(result);
  return result;
}

Obj ConvImmString(Obj str)
{
  Obj result;
  if (!str || !IsStringConv(str))
    return (Obj) 0;
  if (!IS_MUTABLE_OBJ(str))
    return str;
  C_NEW_STRING(result, GET_LEN_STRING(str), CSTR_STRING(str))
  MakeImmutableString(result);
  return result;
}



/****************************************************************************
**

*F * * * * * * * * * * * * * * GAP level functions  * * * * * * * * * * * * *
*/

/****************************************************************************
**


*F  FuncIS_STRING( <self>, <obj> )  . . . . . . . . .  test value is a string
*/
Obj FuncIS_STRING (
    Obj                 self,
    Obj                 obj )
{
    return (IS_STRING( obj ) ? True : False);
}


/****************************************************************************
**
*F  FuncIS_STRING_CONV( <self>, <obj> ) . . . . . . . . . . check and convert
*/
Obj FuncIS_STRING_CONV (
    Obj                 self,
    Obj                 obj )
{
    /* return 'true' if <obj> is a string and 'false' otherwise            */
    return (IsStringConv(obj) ? True : False);
}


/****************************************************************************
**
*F  FuncCONV_STRING( <self>, <string> ) . . . . . . . . convert to string rep
*/
Obj FuncCONV_STRING (
    Obj                 self,
    Obj                 string )
{
    /* check whether <string> is a string                                  */
    if ( ! IS_STRING( string ) ) {
        string = ErrorReturnObj(
            "ConvString: <string> must be a string (not a %s)",
            (Int)TNAM_OBJ(string), 0L,
            "you can replace <string> via 'return <string>;'" );
        return FuncCONV_STRING( self, string );
    }

    /* convert to the string representation                                */
    ConvString( string );

    /* return nothing                                                      */
    return 0;
}


/****************************************************************************
**
*F  FuncIS_STRING_REP( <self>, <obj> )  . . . . test if value is a string rep
*/
Obj IsStringRepFilt;

Obj FuncIS_STRING_REP (
    Obj                 self,
    Obj                 obj )
{
    return (IS_STRING_REP( obj ) ? True : False);
}

/****************************************************************************
**
*F  FuncCOPY_TO_STRING_REP( <self>, <obj> ) . copy a string into string rep
*/
Obj FuncCOPY_TO_STRING_REP (
    Obj                 self,
    Obj                 obj )
{
    /* check whether <obj> is a string                                  */
    if (!IS_STRING(obj)) {
        obj = ErrorReturnObj(
            "ConvString: <string> must be a string (not a %s)",
            (Int)TNAM_OBJ(obj), 0L,
            "you can replace <string> via 'return <string>;'" );
        return FuncCOPY_TO_STRING_REP( self, obj );
    }
    return CopyToStringRep(obj);
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
Obj FuncPOSITION_SUBSTRING( 
			   Obj                  self,
			   Obj                  string,
			   Obj                  substr,
			   Obj                  off )
{
  Int    ipos, i, j, lens, lenss, max;
  UInt1  *s, *ss, c;

  /* check whether <string> is a string                                  */
  while ( ! IsStringConv( string ) ) {
    string = ErrorReturnObj(
	     "POSITION_SUBSTRING: <string> must be a string (not a %s)",
	     (Int)TNAM_OBJ(string), 0L,
	     "you can replace <string> via 'return <string>;'" );
  }
  
  /* check whether <substr> is a string                        */
  while ( ! IsStringConv( substr ) ) {
    substr = ErrorReturnObj(
	  "POSITION_SUBSTRING: <substr> must be a string (not a %s)",
	  (Int)TNAM_OBJ(substr), 0L,
	  "you can replace <substr> via 'return <substr>;'" );
  }

  /* check wether <off> is a non-negative integer  */
  while ( ! IS_INTOBJ(off) || (ipos = INT_INTOBJ(off)) < 0 ) {
    off = ErrorReturnObj(
          "POSITION_SUBSTRING: <off> must be a non-negative integer (not a %s)",
          (Int)TNAM_OBJ(off), 0L,
          "you can replace <off> via 'return <off>;'");
  }

  /* special case for the empty string */
  lenss = GET_LEN_STRING(substr);
  if ( lenss == 0 ) {
    return INTOBJ_INT(ipos + 1);
  }

  lens = GET_LEN_STRING(string);
  max = lens - lenss + 1;
  s = CHARS_STRING(string);
  ss = CHARS_STRING(substr);
  
  c = ss[0];
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
Obj FuncNormalizeWhitespace (
			      Obj     self,
			      Obj     string )
{
  UInt1  *s, c;
  Int i, j, len, white;

  /* check whether <string> is a string                                  */
  if ( ! IsStringConv( string ) ) {
    string = ErrorReturnObj(
	     "NormalizeWhitespace: <string> must be a string (not a %s)",
	     (Int)TNAM_OBJ(string), 0L,
	     "you can replace <string> via 'return <string>;'" );
    return FuncNormalizeWhitespace( self, string );
  }
  
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
*F  FuncRemoveCharacters( <self>, <string>, <rem> ) . . . . . delete characters
**  from <rem> in <string> in place 
**    
*/ 

Obj FuncRemoveCharacters (
			      Obj     self,
			      Obj     string,
                              Obj     rem     )
{
  UInt1  *s;
  Int i, j, len;
  UInt1 REMCHARLIST[257] = {0};

  /* check whether <string> is a string                                  */
  if ( ! IsStringConv( string ) ) {
    string = ErrorReturnObj(
	     "RemoveCharacters: first argument <string> must be a string (not a %s)",
	     (Int)TNAM_OBJ(string), 0L,
	     "you can replace <string> via 'return <string>;'" );
    return FuncRemoveCharacters( self, string, rem );
  }
  
  /* check whether <rem> is a string                                  */
  if ( ! IsStringConv( rem ) ) {
    rem = ErrorReturnObj(
	     "RemoveCharacters: second argument <rem> must be a string (not a %s)",
	     (Int)TNAM_OBJ(rem), 0L,
	     "you can replace <rem> via 'return <rem>;'" );
    return FuncRemoveCharacters( self, string, rem );
  }
  
  /* set REMCHARLIST by setting positions of characters in rem to 1 */
  len = GET_LEN_STRING(rem);
  s = CHARS_STRING(rem);
  REMCHARLIST[256] = 1;
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
Obj FuncTranslateString (
			      Obj     self,
			      Obj     string,
                              Obj     trans     )
{
  UInt1  *s, *t;
  Int j, len;

  /* check whether <string> is a string                                  */
  if ( ! IsStringConv( string ) ) {
    string = ErrorReturnObj(
	     "RemoveCharacters: first argument <string> must be a string (not a %s)",
	     (Int)TNAM_OBJ(string), 0L,
	     "you can replace <string> via 'return <string>;'" );
    return FuncTranslateString( self, string, trans );
  }
  
  /* check whether <trans> is a string                                  */
  if ( ! IsStringConv( trans ) ) {
    trans = ErrorReturnObj(
	     "RemoveCharacters: second argument <trans> must be a string (not a %s)",
	     (Int)TNAM_OBJ(trans), 0L,
	     "you can replace <trans> via 'return <trans>;'" );
    return FuncTranslateString( self, string, trans );
  }
 
  /* check if string has length at least 256 */
  if ( GET_LEN_STRING( trans ) < 256 ) {
    trans = ErrorReturnObj(
	     "RemoveCharacters: second argument <trans> must have length >= 256",
	     0L, 0L,
	     "you can replace <trans> via 'return <trans>;'" );
    return FuncTranslateString( self, string, trans );
  }
  
  /* now change string in place */
  len = GET_LEN_STRING(string);
  s = CHARS_STRING(string);
  t = CHARS_STRING(trans);
  for (j = 0; j < len; j++) {
    s[j] = t[s[j]];
  }
  
  return (Obj)0;
}


/****************************************************************************
**
*F  FuncSplitString( <self>, <string>, <seps>, <wspace> ) . . . . split string
**  at characters in <seps> and <wspace>
**    
**  The difference of <seps> and <wspace> is that characters in <wspace> don't
**  separate empty strings.
*/ 
UInt1 SPLITSTRINGSEPS[257];
UInt1 SPLITSTRINGWSPACE[257];
Obj FuncSplitString (
			      Obj     self,
			      Obj     string,
                              Obj     seps,
                              Obj     wspace    )
{
  UInt1  *s;
  Int i, a, z, l, pos, len;
  Obj res, part;

  /* check whether <string> is a string                                  */
  if ( ! IsStringConv( string ) ) {
    string = ErrorReturnObj(
	     "SplitString: first argument <string> must be a string (not a %s)",
	     (Int)TNAM_OBJ(string), 0L,
	     "you can replace <string> via 'return <string>;'" );
    return FuncSplitString( self, string, seps, wspace );
  }
  
  /* check whether <seps> is a string                                  */
  if ( ! IsStringConv( seps ) ) {
    seps = ErrorReturnObj(
	     "SplitString: second argument <seps> must be a string (not a %s)",
	     (Int)TNAM_OBJ(seps), 0L,
	     "you can replace <seps> via 'return <seps>;'" );
    return FuncSplitString( self, string, seps, wspace );
  }
  
  /* check whether <wspace> is a string                                  */
  if ( ! IsStringConv( wspace ) ) {
    wspace = ErrorReturnObj(
	     "SplitString: third argument <wspace> must be a string (not a %s)",
	     (Int)TNAM_OBJ(wspace), 0L,
	     "you can replace <wspace> via 'return <wspace>;'" );
    return FuncSplitString( self, string, seps, wspace );
  }
  
  /* reset SPLITSTRINGSEPS (in case of previous error) */
  if (SPLITSTRINGSEPS[256] != 0) {
    for(i=0; i<257; i++) SPLITSTRINGSEPS[i] = 0;
  }
  
  /* set SPLITSTRINGSEPS by setting positions of characters in rem to 1 */
  len = GET_LEN_STRING(seps);
  s = CHARS_STRING(seps);
  SPLITSTRINGSEPS[256] = 1;
  for(i=0; i<len; i++) SPLITSTRINGSEPS[s[i]] = 1;
  
  /* reset SPLITSTRINGWSPACE (in case of previous error) */
  if (SPLITSTRINGWSPACE[256] != 0) {
    for(i=0; i<257; i++) SPLITSTRINGWSPACE[i] = 0;
  }
  
  /* set SPLITSTRINGWSPACE by setting positions of characters in rem to 1 */
  len = GET_LEN_STRING(wspace);
  s = CHARS_STRING(wspace);
  SPLITSTRINGWSPACE[256] = 1;
  for(i=0; i<len; i++) SPLITSTRINGWSPACE[s[i]] = 1;
 
  /* create the result (list of strings) */
  res = NEW_PLIST(T_PLIST, 2);
  SET_LEN_PLIST(res, 0);
  pos = 0;

  /* now do the splitting */
  len = GET_LEN_STRING(string);
  s = CHARS_STRING(string);
  for (a=0, z=0; z<len; z++) {
    if (SPLITSTRINGWSPACE[s[z]] == 1) {
      if (a<z) {
        l = z-a;
        part = NEW_STRING(l);
        /* in case of garbage collection we need update */
        s = CHARS_STRING(string);
        COPY_CHARS(part, s+a, l);
        CHARS_STRING(part)[l] = 0;
        pos++;
        AssPlist(res, pos, part);
        s = CHARS_STRING(string);
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
        s = CHARS_STRING(string);
        COPY_CHARS(part, s+a, l);
        CHARS_STRING(part)[l] = 0;
        pos++;
        AssPlist(res, pos, part);
        s = CHARS_STRING(string);
        a = z+1;
      }
    }
  }
  
  /* collect a trailing part */
  if (a<z) {
    /* copy until last position which is z-1 */
    l = z-a;
    part = NEW_STRING(l);
    s = CHARS_STRING(string);
    COPY_CHARS(part, s+a, l);
    CHARS_STRING(part)[l] = 0;
    pos++;
    AssPlist(res, pos, part);
  }

  /* unset SPLITSTRINGSEPS  */
  len = GET_LEN_STRING(seps);
  s = CHARS_STRING(seps);
  for(i=0; i<len; i++) SPLITSTRINGSEPS[s[i]] = 0;
  SPLITSTRINGSEPS[256] = 0;

  /* unset SPLITSTRINGWSPACE  */
  len = GET_LEN_STRING(wspace);
  s = CHARS_STRING(wspace);
  for(i=0; i<len; i++) SPLITSTRINGWSPACE[s[i]] = 0;
  SPLITSTRINGWSPACE[256] = 0;

  return res;
}

/****************************************************************************
**
*F FuncSMALLINT_STR( <self>, <string> )
**
** Kernel function to extract parse small integers from strings. Needed before
** we can conveniently have Int working for things like parsing command line
** options
*/

Obj FuncSMALLINT_STR( Obj self, Obj string )
{
  return INTOBJ_INT(SyIntString(CSTR_STRING(string)));
}

/****************************************************************************
**
*F  UnbString( <string>, <pos> ) . . . . . Unbind function for strings
**  
**  This is to avoid unpacking of string to plain list when <pos> is 
**  larger or equal to the length of <string>.
**  
*/
void UnbString (
  Obj     string,
  Int     pos )
{
        Int len;
        len = GET_LEN_STRING(string);
	
        /* only do something special if last character is to be, and can be, 
         * unbound */
        if (len < pos) return;
        if (len != pos) {
                UnbListDefault(string, pos);
                return;
        }
        if (! IS_MUTABLE_OBJ(string)) {
                UnbPlistImm(string, pos);
                return;
        }
        /* maybe the string becomes sorted */
        CLEAR_FILTS_LIST(string);
        CHARS_STRING(string)[pos-1] = (UInt1)0;
        SET_LEN_STRING(string, len-1);
} 
            

  
/****************************************************************************
**

*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * * */

/****************************************************************************
**

*V  BagNames  . . . . . . . . . . . . . . . . . . . . . . . list of bag names
*/
static StructBagNames BagNames[] = {
  { T_CHAR,                           "character"                      },
  { T_STRING,                         "list (string)"                  },
  { T_STRING              +IMMUTABLE, "list (string,imm)"              },
  { T_STRING      +COPYING,           "list (string,copied)"           },
  { T_STRING      +COPYING+IMMUTABLE, "list (string,imm,copied)"       },
  { T_STRING_SSORT,                   "list (string,ssort)"            },
  { T_STRING_SSORT        +IMMUTABLE, "list (string,ssort,imm)"        },
  { T_STRING_SSORT+COPYING,           "list (string,ssort,copied)"     },
  { T_STRING_SSORT+COPYING+IMMUTABLE, "list (string,ssort,imm,copied)" },
  { T_STRING_NSORT,                   "list (string,nsort)"            },
  { T_STRING_NSORT        +IMMUTABLE, "list (string,nsort,imm)"        },
  { T_STRING_NSORT+COPYING,           "list (string,nsort,copied)"     },
  { T_STRING_NSORT+COPYING+IMMUTABLE, "list (string,nsort,imm,copied)" },
  { -1,                               ""                               }
};


/****************************************************************************
**
*V  ClearFiltsTab . . . . . . . . . . . . . . . . . . . .  clear filter tnums
*/
static Int ClearFiltsTab [] = {
    T_STRING,                 T_STRING,
    T_STRING      +IMMUTABLE, T_STRING+IMMUTABLE,
    T_STRING_NSORT,           T_STRING,
    T_STRING_NSORT+IMMUTABLE, T_STRING+IMMUTABLE,
    T_STRING_SSORT,           T_STRING,
    T_STRING_SSORT+IMMUTABLE, T_STRING+IMMUTABLE,
    -1,                       -1
};


/****************************************************************************
**
*V  HasFiltTab  . . . . . . . . . . . . . . . . . . . . .  tester filter tnum
*/
static Int HasFiltTab [] = {

    /* mutable string                                                      */
    T_STRING,                  FN_IS_MUTABLE, 1,
    T_STRING,                  FN_IS_EMPTY,   0,
    T_STRING,                  FN_IS_DENSE,   1,
    T_STRING,                  FN_IS_NDENSE,  0,
    T_STRING,                  FN_IS_HOMOG,   1,
    T_STRING,                  FN_IS_NHOMOG,  0,
    T_STRING,                  FN_IS_TABLE,   0,
    T_STRING,                  FN_IS_RECT,    0,
    T_STRING,                  FN_IS_SSORT,   0,
    T_STRING,                  FN_IS_NSORT,   0,

    /* immutable string                                                    */
    T_STRING      +IMMUTABLE,  FN_IS_MUTABLE, 0,
    T_STRING      +IMMUTABLE,  FN_IS_EMPTY,   0,
    T_STRING      +IMMUTABLE,  FN_IS_DENSE,   1,
    T_STRING      +IMMUTABLE,  FN_IS_NDENSE,  0,
    T_STRING      +IMMUTABLE,  FN_IS_HOMOG,   1,
    T_STRING      +IMMUTABLE,  FN_IS_NHOMOG,  0,
    T_STRING      +IMMUTABLE,  FN_IS_TABLE,   0,
    T_STRING      +IMMUTABLE,  FN_IS_RECT,    0,
    T_STRING      +IMMUTABLE,  FN_IS_SSORT,   0,
    T_STRING      +IMMUTABLE,  FN_IS_NSORT,   0,

    /* ssort mutable string                                                */
    T_STRING_SSORT,            FN_IS_MUTABLE, 1,
    T_STRING_SSORT,            FN_IS_EMPTY,   0,
    T_STRING_SSORT,            FN_IS_DENSE,   1,
    T_STRING_SSORT,            FN_IS_NDENSE,  0,
    T_STRING_SSORT,            FN_IS_HOMOG,   1,
    T_STRING_SSORT,            FN_IS_NHOMOG,  0,
    T_STRING_SSORT,            FN_IS_TABLE,   0,
    T_STRING_SSORT,            FN_IS_RECT,   0,
    T_STRING_SSORT,            FN_IS_SSORT,   1,
    T_STRING_SSORT,            FN_IS_NSORT,   0,

    /* ssort immutable string                                              */
    T_STRING_SSORT+IMMUTABLE,  FN_IS_MUTABLE, 0,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_EMPTY,   0,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_DENSE,   1,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_NDENSE,  0,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_HOMOG,   1,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_NHOMOG,  0,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_TABLE,   0,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_RECT,   0,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_SSORT,   1,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_NSORT,   0,

    /* nsort mutable string                                                */
    T_STRING_NSORT,            FN_IS_MUTABLE, 1,
    T_STRING_NSORT,            FN_IS_EMPTY,   0,
    T_STRING_NSORT,            FN_IS_DENSE,   1,
    T_STRING_NSORT,            FN_IS_NDENSE,  0,
    T_STRING_NSORT,            FN_IS_HOMOG,   1,
    T_STRING_NSORT,            FN_IS_NHOMOG,  0,
    T_STRING_NSORT,            FN_IS_TABLE,   0,
    T_STRING_NSORT,            FN_IS_RECT,   0,
    T_STRING_NSORT,            FN_IS_SSORT,   0,
    T_STRING_NSORT,            FN_IS_NSORT,   1,

    /* nsort immutable string                                              */
    T_STRING_NSORT+IMMUTABLE,  FN_IS_MUTABLE, 0,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_EMPTY,   0,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_DENSE,   1,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_NDENSE,  0,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_HOMOG,   1,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_NHOMOG,  0,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_TABLE,   0,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_RECT,   0,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_SSORT,   0,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_NSORT,   1,

    -1,                        -1,            -1
};


/****************************************************************************
**
*V  SetFiltTab  . . . . . . . . . . . . . . . . . . . . .  setter filter tnum
*/
static Int SetFiltTab [] = {

    /* mutable string                                                      */
    T_STRING,                  FN_IS_MUTABLE, T_STRING,
    T_STRING,                  FN_IS_EMPTY,   T_STRING_SSORT,
    T_STRING,                  FN_IS_DENSE,   T_STRING,
    T_STRING,                  FN_IS_NDENSE,  -1,
    T_STRING,                  FN_IS_HOMOG,   T_STRING,
    T_STRING,                  FN_IS_NHOMOG,  -1,
    T_STRING,                  FN_IS_TABLE,   -1,
    T_STRING,                  FN_IS_RECT,   -1,
    T_STRING,                  FN_IS_SSORT,   T_STRING_SSORT,
    T_STRING,                  FN_IS_NSORT,   T_STRING_NSORT,

    /* immutable string                                                    */
    T_STRING      +IMMUTABLE,  FN_IS_MUTABLE, T_STRING,
    T_STRING      +IMMUTABLE,  FN_IS_EMPTY,   T_STRING_SSORT+IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_DENSE,   T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_NDENSE,  -1,
    T_STRING      +IMMUTABLE,  FN_IS_HOMOG,   T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_NHOMOG,  -1,
    T_STRING      +IMMUTABLE,  FN_IS_TABLE,   -1,
    T_STRING      +IMMUTABLE,  FN_IS_RECT,   -1,
    T_STRING      +IMMUTABLE,  FN_IS_SSORT,   T_STRING_SSORT+IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_NSORT,   T_STRING_NSORT+IMMUTABLE,

    /* ssort mutable string                                                */
    T_STRING_SSORT,            FN_IS_MUTABLE, T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_EMPTY,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_DENSE,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_NDENSE,  -1,
    T_STRING_SSORT,            FN_IS_HOMOG,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_NHOMOG,  -1,
    T_STRING_SSORT,            FN_IS_TABLE,   -1,
    T_STRING_SSORT,            FN_IS_RECT,   -1,
    T_STRING_SSORT,            FN_IS_SSORT,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_NSORT,   -1,

    /* ssort immutable string                                              */
    T_STRING_SSORT+IMMUTABLE,  FN_IS_MUTABLE, T_STRING_SSORT,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_EMPTY,   T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_DENSE,   T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_NDENSE,  -1,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_HOMOG,   T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_NHOMOG,  -1,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_TABLE,   -1,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_RECT,   -1,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_SSORT,   T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_NSORT,   -1,

    /* nsort mutable string                                                */
    T_STRING_NSORT,            FN_IS_MUTABLE, T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_EMPTY,   -1,
    T_STRING_NSORT,            FN_IS_DENSE,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_NDENSE,  -1,
    T_STRING_NSORT,            FN_IS_HOMOG,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_NHOMOG,  -1,
    T_STRING_NSORT,            FN_IS_TABLE,   -1,
    T_STRING_NSORT,            FN_IS_RECT,   -1,
    T_STRING_NSORT,            FN_IS_SSORT,   -1,
    T_STRING_NSORT,            FN_IS_NSORT,   T_STRING_NSORT,

    /* nsort immutable string                                              */
    T_STRING_NSORT+IMMUTABLE,  FN_IS_MUTABLE, T_STRING_NSORT,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_EMPTY,   -1,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_DENSE,   T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_NDENSE,  -1,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_HOMOG,   T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_NHOMOG,  -1,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_TABLE,   -1,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_RECT,   -1,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_SSORT,   -1,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_NSORT,   T_STRING_NSORT+IMMUTABLE,

    -1,                        -1,            -1

};


/****************************************************************************
**
*V  ResetFiltTab  . . . . . . . . . . . . . . . . . . .  unsetter filter tnum
*/
static Int ResetFiltTab [] = {

    /* mutable string                                                      */
    T_STRING,                  FN_IS_MUTABLE, T_STRING      +IMMUTABLE,
    T_STRING,                  FN_IS_EMPTY,   T_STRING,
    T_STRING,                  FN_IS_DENSE,   T_STRING,
    T_STRING,                  FN_IS_NDENSE,  T_STRING,
    T_STRING,                  FN_IS_HOMOG,   T_STRING,
    T_STRING,                  FN_IS_NHOMOG,  T_STRING,
    T_STRING,                  FN_IS_TABLE,   T_STRING,
    T_STRING,                  FN_IS_RECT,   T_STRING,
    T_STRING,                  FN_IS_SSORT,   T_STRING,
    T_STRING,                  FN_IS_NSORT,   T_STRING,

    /* immutable string                                                    */
    T_STRING      +IMMUTABLE,  FN_IS_MUTABLE, T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_EMPTY,   T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_DENSE,   T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_NDENSE,  T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_HOMOG,   T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_NHOMOG,  T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_TABLE,   T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_RECT,    T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_SSORT,   T_STRING      +IMMUTABLE,
    T_STRING      +IMMUTABLE,  FN_IS_NSORT,   T_STRING      +IMMUTABLE,

    /* ssort mutable string                                                */
    T_STRING_SSORT,            FN_IS_MUTABLE, T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT,            FN_IS_EMPTY,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_DENSE,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_NDENSE,  T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_HOMOG,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_NHOMOG,  T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_TABLE,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_RECT,   T_STRING_SSORT,
    T_STRING_SSORT,            FN_IS_SSORT,   T_STRING,
    T_STRING_SSORT,            FN_IS_NSORT,   T_STRING_SSORT,

    /* ssort immutable string                                              */
    T_STRING_SSORT+IMMUTABLE,  FN_IS_MUTABLE, T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_EMPTY,   T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_DENSE,   T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_NDENSE,  T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_HOMOG,   T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_NHOMOG,  T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_TABLE,   T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_RECT,   T_STRING_SSORT+IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_SSORT,   T_STRING      +IMMUTABLE,
    T_STRING_SSORT+IMMUTABLE,  FN_IS_NSORT,   T_STRING_SSORT+IMMUTABLE,

    /* nsort mutable string                                                */
    T_STRING_NSORT,            FN_IS_MUTABLE, T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT,            FN_IS_EMPTY,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_DENSE,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_NDENSE,  T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_HOMOG,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_NHOMOG,  T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_TABLE,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_RECT,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_SSORT,   T_STRING_NSORT,
    T_STRING_NSORT,            FN_IS_NSORT,   T_STRING,

    /* nsort immutable string                                              */
    T_STRING_NSORT+IMMUTABLE,  FN_IS_MUTABLE, T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_EMPTY,   T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_DENSE,   T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_NDENSE,  T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_HOMOG,   T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_NHOMOG,  T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_TABLE,   T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_RECT,   T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_SSORT,   T_STRING_NSORT+IMMUTABLE,
    T_STRING_NSORT+IMMUTABLE,  FN_IS_NSORT,   T_STRING      +IMMUTABLE,

    -1,                        -1,            -1

};


/****************************************************************************
**
*V  GVarFilts . . . . . . . . . . . . . . . . . . . list of filters to export
*/
static StructGVarFilt GVarFilts [] = {

    { "IS_STRING", "obj", &IsStringFilt,
      FuncIS_STRING, "src/stringobj.c:IS_STRING" },

    { "IS_STRING_REP", "obj", &IsStringRepFilt,
      FuncIS_STRING_REP, "src/lists.c:IS_STRING_REP" },

    { 0 }

};


/****************************************************************************
**
*V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
*/
static StructGVarFunc GVarFuncs [] = {

    { "IS_STRING_CONV", 1, "string",
      FuncIS_STRING_CONV, "src/stringobj.c:IS_STRING_CONV" },

    { "CONV_STRING", 1, "string",
      FuncCONV_STRING, "src/stringobj.c:CONV_STRING" },

    { "COPY_TO_STRING_REP", 1, "string",
      FuncCOPY_TO_STRING_REP, "src/stringobj.c:COPY_TO_STRING_REP" },

    { "CHAR_INT", 1, "integer",
      FuncCHAR_INT, "src/stringobj.c:CHAR_INT" },

    { "INT_CHAR", 1, "char",
      FuncINT_CHAR, "src/stringobj.c:INT_CHAR" },

    { "CHAR_SINT", 1, "integer",
      FuncCHAR_SINT, "src/stringobj.c:CHAR_SINT" },

    { "SINT_CHAR", 1, "char",
      FuncSINT_CHAR, "src/stringobj.c:SINT_CHAR" },

    { "STRING_SINTLIST", 1, "list",
      FuncSTRING_SINTLIST, "src/stringobj.c:STRING_SINTLIST" },

    { "INTLIST_STRING", 2, "string, sign",
      FuncINTLIST_STRING, "src/stringobj.c:INTLIST_STRING" },

    { "SINTLIST_STRING", 1, "string",
      FuncSINTLIST_STRING, "src/stringobj.c:SINTLIST_STRING" },

    { "EmptyString", 1, "len",
      FuncEmptyString, "src/stringobj.c:FuncEmptyString" },
    
    { "ShrinkAllocationString", 1, "str",
      FuncShrinkAllocationString, "src/stringobj.c:FuncShrinkAllocationString" },
    
    { "REVNEG_STRING", 1, "string",
      FuncREVNEG_STRING, "src/stringobj.c:REVNEG_STRING" },

    { "POSITION_SUBSTRING", 3, "string, substr, off",
      FuncPOSITION_SUBSTRING, "src/stringobj.c:POSITION_SUBSTRING" },

    { "NormalizeWhitespace", 1, "string",
      FuncNormalizeWhitespace, "src/stringobj.c:NormalizeWhitespace" },

    { "REMOVE_CHARACTERS", 2, "string, rem",
      FuncRemoveCharacters, "src/stringobj.c:RemoveCharacters" },

    { "TranslateString", 2, "string, trans",
      FuncTranslateString, "src/stringobj.c:TranslateString" },

    { "SplitStringInternal", 3, "string, seps, wspace",
      FuncSplitString, "src/stringobj.c:SplitStringInternal" },

    { "SMALLINT_STR", 1, "string",
      FuncSMALLINT_STR, "src/stringobj.c:SMALLINT_STR" },

    { 0 }

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
        InitMarkFuncBags( t1 +COPYING            , MarkNoSubBags );
        InitMarkFuncBags( t1 +COPYING +IMMUTABLE , MarkNoSubBags );
    }
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1 += 2 ) {
      MakeBagTypePublic( t1 + IMMUTABLE );
    }

    MakeBagTypePublic(T_CHAR);

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

    /* Install the saving function                                         */
    SaveObjFuncs[ T_CHAR ] = SaveChar;
    LoadObjFuncs[ T_CHAR ] = LoadChar;

    /* install the character functions                                     */
    PrintObjFuncs[ T_CHAR ] = PrintChar;
    EqFuncs[ T_CHAR ][ T_CHAR ] = EqChar;
    LtFuncs[ T_CHAR ][ T_CHAR ] = LtChar;

    /* install the saving method                                             */
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1 += 2 ) {
        SaveObjFuncs[ t1            ] = SaveString;
        SaveObjFuncs[ t1 +IMMUTABLE ] = SaveString;
        LoadObjFuncs[ t1            ] = LoadString;
        LoadObjFuncs[ t1 +IMMUTABLE ] = LoadString;
    }

    /* install the copy method                                             */
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1++ ) {
        CopyObjFuncs [ t1                     ] = CopyString;
        CopyObjFuncs [ t1          +IMMUTABLE ] = CopyString;
        CleanObjFuncs[ t1                     ] = CleanString;
        CleanObjFuncs[ t1          +IMMUTABLE ] = CleanString;
        CopyObjFuncs [ t1 +COPYING            ] = CopyStringCopy;
        CopyObjFuncs [ t1 +COPYING +IMMUTABLE ] = CopyStringCopy;
        CleanObjFuncs[ t1 +COPYING            ] = CleanStringCopy;
        CleanObjFuncs[ t1 +COPYING +IMMUTABLE ] = CleanStringCopy;
    }

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
        IsbvListFuncs   [ t1            ] = IsbvString;
        IsbvListFuncs   [ t1 +IMMUTABLE ] = IsbvString;
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
        AssListFuncs    [ t1            ] = AssString;
        AssListFuncs    [ t1 +IMMUTABLE ] = AssStringImm;
        AsssListFuncs   [ t1            ] = AsssString;
        AsssListFuncs   [ t1 +IMMUTABLE ] = AsssStringImm;
        IsDenseListFuncs[ t1            ] = IsDenseString;
        IsDenseListFuncs[ t1 +IMMUTABLE ] = IsDenseString;
        IsHomogListFuncs[ t1            ] = IsHomogString;
        IsHomogListFuncs[ t1 +IMMUTABLE ] = IsHomogString;
        IsSSortListFuncs[ t1            ] = IsSSortString;
        IsSSortListFuncs[ t1 +IMMUTABLE ] = IsSSortString;
        IsPossListFuncs [ t1            ] = IsPossString;
        IsPossListFuncs [ t1 +IMMUTABLE ] = IsPossString;
        PosListFuncs    [ t1            ] = PosString;
        PosListFuncs    [ t1 +IMMUTABLE ] = PosString;
        PlainListFuncs  [ t1            ] = PlainString;
        PlainListFuncs  [ t1 +IMMUTABLE ] = PlainString;
    }
    IsSSortListFuncs[ T_STRING_NSORT            ] = IsSSortStringNot;
    IsSSortListFuncs[ T_STRING_NSORT +IMMUTABLE ] = IsSSortStringNot;
    IsSSortListFuncs[ T_STRING_SSORT            ] = IsSSortStringYes;
    IsSSortListFuncs[ T_STRING_SSORT +IMMUTABLE ] = IsSSortStringYes;


    /* install the `IsString' functions                                    */
    for ( t1 = FIRST_REAL_TNUM; t1 <= LAST_REAL_TNUM; t1++ ) {
        IsStringFuncs[ t1 ] = IsStringNot;
    }

    for ( t1 = FIRST_LIST_TNUM; t1 <= LAST_LIST_TNUM; t1++ ) {
        IsStringFuncs[ t1 ] = IsStringList;
    }

    for ( t1 = T_STRING; t1 <= T_STRING_SSORT; t1++ ) {
        IsStringFuncs[ t1 ] = IsStringYes;
    }

    for ( t1 = FIRST_EXTERNAL_TNUM; t1 <= LAST_EXTERNAL_TNUM; t1++ ) {
        IsStringFuncs[ t1 ] = IsStringObject;
    }

    /* install the list unbind methods  */
    for ( t1 = T_STRING; t1 <= T_STRING_SSORT+IMMUTABLE; t1++ ) {
           UnbListFuncs    [ t1            ] = UnbString;
    }

    MakeImmutableObjFuncs[ T_STRING       ] = MakeImmutableString;
    MakeImmutableObjFuncs[ T_STRING_SSORT ] = MakeImmutableString;
    MakeImmutableObjFuncs[ T_STRING_NSORT ] = MakeImmutableString;
    

    /* return success                                                      */
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
        ObjsChar[i] = NewBag( T_CHAR, 1L );
        *(UChar*)ADDR_OBJ(ObjsChar[i]) = (UChar)i;
    }

    /* init filters and functions                                          */
    InitGVarFiltsFromTable( GVarFilts );
    InitGVarFuncsFromTable( GVarFuncs );

    /* return success                                                      */
    return 0;
}


/****************************************************************************
**
*F  InitInfoString()  . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    MODULE_BUILTIN,                     /* type                           */
    "string",                           /* name                           */
    0,                                  /* revision entry of c file       */
    0,                                  /* revision entry of h file       */
    0,                                  /* version                        */
    0,                                  /* crc                            */
    InitKernel,                         /* initKernel                     */
    InitLibrary,                        /* initLibrary                    */
    0,                                  /* checkInit                      */
    0,                                  /* preSave                        */
    0,                                  /* postSave                       */
    0                                   /* postRestore                    */
};

StructInitInfo * InitInfoString ( void )
{
    return &module;
}


/****************************************************************************
**

*E  stringobj.c  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
