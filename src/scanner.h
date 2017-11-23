/****************************************************************************
**
*W  scanner.h                   GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the scanner, which provides a very
**  abstractions, namely the concept that an input file is a stream of
**  symbols, such nasty things as <space>, <tab>, <newline> characters or
**  comments (they are worst :-), characters making up identifiers or digits
**  that make up integers are hidden from the rest of GAP.
*/

#ifndef GAP_SCANNER_H
#define GAP_SCANNER_H

#include <src/system.h>

/****************************************************************************
**
*V  Symbol  . . . . . . . . . . . . . . . . .  current symbol read from input
**
**  The  variable 'Symbol' contains the current  symbol read from  the input.
**  It is represented as an unsigned long integer.
**
**  The possible values for 'Symbol' are defined in the  definition  file  of
**  this package as follows:
*/
enum SCANNER_SYMBOLS {
    S_ILLEGAL           = 0UL,

    S_IDENT             = (1UL<< 3),
    S_UNBIND            = (1UL<< 3)+1,
    S_ISBOUND           = (1UL<< 3)+2,
    S_TRYNEXT           = (1UL<< 3)+3,
    S_INFO              = (1UL<< 3)+4,
    S_ASSERT            = (1UL<< 3)+5,
    S_LBRACK            = (1UL<< 4)+0,
    S_LBRACE            = (1UL<< 4)+1,
    S_BLBRACK           = (1UL<< 4)+2,
    S_BLBRACE           = (1UL<< 4)+3,
    S_RBRACK            = (1UL<< 5)+0,
    S_RBRACE            = (1UL<< 5)+1,
    S_DOT               = (1UL<< 6)+0,
    S_BDOT              = (1UL<< 6)+1,
    S_LPAREN            = (1UL<< 7),
    S_RPAREN            = (1UL<< 8),
    S_COMMA             = (1UL<< 9)+0,
    S_DOTDOT            = (1UL<< 9)+1,
    S_COLON             = (1UL<< 9)+2,
    S_READWRITE         = (1UL<< 9)+3,
    S_READONLY          = (1UL<< 9)+4,
    S_DOTDOTDOT         = (1UL<< 9)+5,

    S_PARTIALINT        = (1UL<<10)+0, // Some digits
    S_INT               = (1UL<<10)+1,
    S_FLOAT             = (1UL<<10)+2,

    // A decimal point only, but in a context where we know it's the start of
    // a number
    S_PARTIALFLOAT1     = (1UL<<10)+3,

    // Some digits and a decimal point
    S_PARTIALFLOAT2     = (1UL<<10)+4,

    // Some digits and a decimal point and an exponent indicator and maybe a
    // sign, but no digits
    S_PARTIALFLOAT3     = (1UL<<10)+5,

    // Some digits and a decimal point and an exponent indicator and maybe a
    // sign, and at least one digit
    S_PARTIALFLOAT4     = (1UL<<10)+6,

    S_TRUE              = (1UL<<11)+0,
    S_FALSE             = (1UL<<11)+1,
    S_CHAR              = (1UL<<11)+2,
    S_STRING            = (1UL<<11)+3,
    S_PARTIALSTRING     = (1UL<<11)+4,
    S_PARTIALTRIPSTRING = (1UL<<11)+5,
    S_TILDE             = (1UL<<11)+6,
    S_HELP              = (1UL<<11)+7,

    S_REC               = (1UL<<12)+0,
    S_BACKQUOTE         = (1UL<<12)+1,

    S_FUNCTION          = (1UL<<13),
    S_LOCAL             = (1UL<<14),
    S_END               = (1UL<<15),
    S_MAPTO             = (1UL<<16),

    S_MULT              = (1UL<<17)+0,
    S_DIV               = (1UL<<17)+1,
    S_MOD               = (1UL<<17)+2,
    S_POW               = (1UL<<17)+3,

    S_PLUS              = (1UL<<18)+0,
    S_MINUS             = (1UL<<18)+1,

    S_EQ                = (1UL<<19)+0,
    S_LT                = (1UL<<19)+1,
    S_GT                = (1UL<<19)+2,
    S_NE                = (1UL<<19)+3,
    S_LE                = (1UL<<19)+4,
    S_GE                = (1UL<<19)+5,
    S_IN                = (1UL<<19)+6,

    S_NOT               = (1UL<<20)+0,
    S_AND               = (1UL<<20)+1,
    S_OR                = (1UL<<20)+2,

    S_ASSIGN            = (1UL<<21),

    S_IF                = (1UL<<22)+0,
    S_FOR               = (1UL<<22)+1,
    S_WHILE             = (1UL<<22)+2,
    S_REPEAT            = (1UL<<22)+3,
    S_ATOMIC            = (1UL<<22)+4,

    S_THEN              = (1UL<<23),
    S_ELIF              = (1UL<<24)+0,
    S_ELSE              = (1UL<<24)+1,
    S_FI                = (1UL<<25),
    S_DO                = (1UL<<26),
    S_OD                = (1UL<<27),
    S_UNTIL             = (1UL<<28),

    S_BREAK             = (1UL<<29)+0,
    S_RETURN            = (1UL<<29)+1,
    S_QUIT              = (1UL<<29)+2,
    S_QQUIT             = (1UL<<29)+3,
    S_CONTINUE          = (1UL<<29)+4,

    S_SEMICOLON         = (1UL<<30)+0,
    S_DUALSEMICOLON     = (1UL<<30)+1,

    S_EOF               = (1UL<<31),
};
/* TL: extern  UInt            Symbol; */


/****************************************************************************
**
*T  TypSymbolSet  . . . . . . . . . . . . . . . . . . type of sets of symbols
**
**  'TypSymbolSet' is the type of sets of symbols.  Sets  of symbols are used
**  in the error recovery of the  parser  to specify that 'Match' should skip
**  all symbols until finding one in a specified set.
**
**  If there were less than 32 different symbols  things would be  very easy.
**  We could  simply assign   the  symbolic constants   that are the possible
**  values for 'Symbol' values 1, 2, 4, 8, 16, ...  and so on.  Then making a
**  set  would  simply mean  or-ing the  values, as in  'S_INT|S_STRING', and
**  checking whether a symbol is in a set would be '(<symbol> & <set>) != 0'.
**
**  There  are however more  than 32 different  symbols, so  we must  be more
**  clever.  We  group some  symbols that  are syntactically  equivalent like
**  '*', '/' in a class. We use the least significant 3 bits to differentiate
**  between members in one class.  And now  every symbol class, many of which
**  contain   just  one  symbol,  has exactly  one   of  the  remaining most
**  significant 29  bits  set.   Thus   sets  of symbols  are  represented as
**  unsigned long integers, which is typedef-ed to 'TypSymbolSet'.
**
**  The classes are as follows, all other symbols are in a class themself:
**      identifiers, IsBound, UnBind, Info, Assert
**      if, for, repeat, while, return
**      elif, else
**      not, and, or
**      =, <>, <, >=, <=, >, in
**      +, -
**      *, /, mod, ^
**
**  'TypSymbolSet'  is defined in the   definition  file of  this  package as
**  follows:
*/
typedef UInt            TypSymbolSet;


/****************************************************************************
**
*F  IS_IN( <symbol>, <set> )  . . . . . . . . is a symbol in a set of symbols
**
**  'IS_IN' returns non-zero if the symbol <symbol> is in the symbol set
**  <set> and 0
**  otherwise.  Due to the grouping into classes some symbol sets may contain
**  more than mentioned, for  example 'IS_IN(S_POW,S_MULT|S_DIV|S_MOD)' is 1.
**
**  'IS_IN' is defined in the definition file of this package as follows:
*/
#define IS_IN(symbol,set)       ((symbol) & ((set) & ~7))


/****************************************************************************
**
*V  EXPRBEGIN . . . . . . . . . . . . set of symbols that start an expression
*V  STATBEGIN . . . . . . . . . . . . . set of symbols that start a statement
**
**  'EXPRBEGIN'  is the  set  of  symbols   that might  start  an expression.
**
**  'STATBEGIN' is the set of symbols that might start a stament.
*/
#define EXPRBEGIN  (S_IDENT|S_ISBOUND|S_INT|S_TRUE|S_FALSE|S_TILDE \
                    |S_CHAR|S_STRING|S_LBRACK|S_REC|S_FUNCTION \
                    |S_PLUS|S_MINUS|S_NOT|S_LPAREN)

#define STATBEGIN  (S_IDENT|S_UNBIND|S_IF|S_FOR|S_WHILE|S_REPEAT \
                    |S_BREAK|S_RETURN|S_HELP|S_QUIT)


/****************************************************************************
**
*V  Value . . . . . . . . . . . .  value of the identifier, integer or string
**
**  If 'Symbol' is 'S_IDENT', 'S_INT' or 'S_STRING' the variable 'Value' holds
**  the name of the identifier, the digits of the integer or the value of the
**  string constant.
**
**  Note  that  the  size  of  'Value'  limits  the  maximal  number  of
**  significant  characters of  an identifier.  'GetIdent' truncates  an
**  identifier after that many characters.
**
**  The  only other  symbols  which  may not  fit  into  Value are  long
**  integers  or strings.  Therefore we  have  to check  in 'GetInt'  and
**  'GetStr' if  the symbols is  not yet  completely read when  Value is
**  filled.
**
**  We only fill Value up to SAFE_VALUE_SIZE normally. The last few
**  bytes are used in the floating point parsing code to ensure that we don't
**  stop the scan just before a non-digit (., E, +,-, etc.) which would make
**  it hard for the scanner to carry on correctly.
*/
/* TL: extern  Char            Value [1030]; */
/* TL: extern  UInt            ValueLen; */

#define         SAFE_VALUE_SIZE 1024

/****************************************************************************
**
*V  NrError . . . . . . . . . . . . . . . .  number of errors in current expr
*V  NrErrLine . . . . . . . . . . . . . . .  number of errors on current line
**
**  'NrError' is an integer whose value is the number of errors already found
**  in the current expression.  It is set to 0 at the beginning of 'Read' and
**  incremented with each 'SyntaxError' call, including those  from  'Match'.
**
**  If 'NrError' is greater than zero the parser functions  will  not  create
**  new bags.  This prevents the parser from creating new bags after an error
**  occured.
**
**  'NrErrLine' is an integer whose value is the number of  errors  found  on
**  the current line.  It is set to 0 in 'GetLine' and incremented with  each
**  'SyntaxError' call, including those from 'Match'.
**
**  If 'NrErrLine' is greater  than  zero  'SyntaxError' will  not  print  an
**  error message.  This prevents the printing of multiple error messages for
**  one line, since they  probabely  just reflect  the  fact that the  parser
**  has not resynchronized yet.
*/
/* TL: extern  UInt            NrError; */
/* TL: extern  UInt            NrErrLine; */


static inline int IsIdent(char c)
{
    return IsAlpha(c) || c == '_' || c == '@';
}

extern int IsKeyword(const char * str);


/****************************************************************************
**
*F  GetSymbol() . . . . . . . . . . . . . . . . .  get the next symbol, local
**
**  'GetSymbol' reads  the  next symbol from   the  input,  storing it in the
**  variable 'Symbol'.  If 'Symbol' is  'T_IDENT', 'T_INT' or 'T_STRING'  the
**  value of the symbol is stored in the variable 'Value'.  'GetSymbol' first
**  skips all <space>, <tab> and <newline> characters and comments.
**
**  After reading  a  symbol the current  character   is the first  character
**  beyond that symbol.
*/
extern void GetSymbol ( void );


/****************************************************************************
**
*F  SyntaxError( <msg> )  . . . . . . . . . . . . . . .  raise a syntax error
*F  SyntaxWarning( <msg> ) ..................display a syntax warning
**
**  'SyntaxError' prints the current line, followed by the error message:
**
**      ^ syntax error, <msg> in <current file name>
**
**  with the '^' pointing to the current symbol on the current line.  If  the
**  <current file name> is '*stdin*' it is not printed.
**
**  'SyntaxError' is called from the parser to print error messages for those
**  errors that are not caught by 'Match',  for example if the left hand side
**  of an assignment is not a variable, a list element or a record component,
**  or if two formal arguments of a function have the same identifier.  
**
**  'SyntaxError' first increments 'NrError' by   1.  If 'NrError' is greater
**  than zero the parser functions  will not create  new bags.  This prevents
**  the parser from creating new bags after an error occured.
**
**  'SyntaxError'  also  increments  'NrErrLine'  by  1.  If  'NrErrLine'  is
**  greater than zero  'SyntaxError' will not print an  error  message.  This
**  prevents the printing of multiple error messages for one line, since they
**  probabely  just reflect the  fact  that the parser has not resynchronized
**  yet.  'NrErrLine' is reset to 0 if a new line is read in 'GetLine'.
** 
**  'SyntaxWarning' displays in the same way but does not increase NrError or 
**  NrErrLine
**
*/
extern  void            SyntaxError (
            const Char *        msg );

extern  void            SyntaxWarning (
            const Char *        msg );


/****************************************************************************
**
*F  Match( <symbol>, <msg>, <skipto> )  . match current symbol and fetch next
**
**  'Match' is the main  interface between the  scanner and the  parser.   It
**  performs the  4 most common actions in  the scanner  with  just one call.
**  First it checks that  the current symbol stored  in the variable 'Symbol'
**  is the expected symbol  as passed in the  argument <symbol>.  If  it  is,
**  'Match' reads the next symbol from input  and returns.  Otherwise 'Match'
**  first prints the current input line followed by the syntax error message:
**  '^ syntax error, <msg> expected' with '^' pointing to the current symbol.
**  It then  skips symbols up to one  in the resynchronisation  set <skipto>.
**  Actually 'Match' calls 'SyntaxError' so its comments apply here too.
**
**  One kind of typical 'Match' call has the form
**
**      'Match( Symbol, "", 0L );'.
**
**  This is used if the parser knows that the current  symbol is correct, for
**  example in 'ReadReturn'  the  first symbol must be 'S_RETURN',  otherwise
**  'ReadReturn' would not have been called. Called this  way 'Match' will of
**  course never raise a syntax error, therefore <msg> and <skipto> are of no
**  concern.  The effect of this call is  merely to read the next symbol from
**  input.
**
**  Another typical 'Match' call is in 'ReadIf' after we read the if symbol
**  and the condition following, and now expect to see the 'then' symbol:
**
**      Match( S_THEN, "then", STATBEGIN|S_ELIF|S_ELSE|S_FI|follow );
**
**  If the current symbol  is 'S_THEN' it is  matched  and the next symbol is
**  read.  Otherwise 'Match'  prints the  current line followed by the  error
**  message: '^ syntax error, then expected'.  Then 'Match' skips all symbols
**  until finding either  a symbol  that can begin  a statment,  an 'elif' or
**  'else' or 'fi' symbol, or a symbol that is  contained in the set <follow>
**  which is passed to 'ReadIf' and contains all symbols allowing  one of the
**  calling functions  to resynchronize,  for example 'S_OD' if 'ReadIf'  has
**  been called from 'ReadFor'.  <follow> always contain 'S_EOF', which 'Read'
**  uses to resynchronise.
**
**  If 'Match' needs to  read a  new line from  '*stdin*' or '*errin*' to get
**  the next symbol it prints the string pointed to by 'Prompt'.
*/
extern void Match (
            UInt                symbol,
            const Char *        msg,
            TypSymbolSet        skipto );


/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitInfoScanner() . . . . . . . . . . . . . . . . table of init functions
*/
StructInitInfo * InitInfoScanner ( void );

#endif // GAP_SCANNER_H
