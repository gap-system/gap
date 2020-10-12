/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file declares the functions of the scanner, which provides a very
**  abstractions, namely the concept that an input file is a stream of
**  symbols, such nasty things as <space>, <tab>, <newline> characters or
**  comments (they are worst :-), characters making up identifiers or digits
**  that make up integers are hidden from the rest of GAP.
*/

#ifndef GAP_SCANNER_H
#define GAP_SCANNER_H

#include "common.h"

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
    S_ILLEGAL           = 0,

    S_IDENT             = (1<< 3),
    S_UNBIND            = (1<< 3)+1,
    S_ISBOUND           = (1<< 3)+2,
    S_TRYNEXT           = (1<< 3)+3,
    S_INFO              = (1<< 3)+4,
    S_ASSERT            = (1<< 3)+5,
    S_LBRACK            = (1<< 4)+0,
    S_LBRACE            = (1<< 4)+1,
    S_BLBRACK           = (1<< 4)+2,
    S_RBRACK            = (1<< 5)+0,
    S_RBRACE            = (1<< 5)+1,
    S_DOT               = (1<< 6)+0,
    S_BDOT              = (1<< 6)+1,
    S_LPAREN            = (1<< 7),
    S_RPAREN            = (1<< 8),
    S_COMMA             = (1<< 9)+0,
    S_DOTDOT            = (1<< 9)+1,
    S_COLON             = (1<< 9)+2,
    S_READWRITE         = (1<< 9)+3,
    S_READONLY          = (1<< 9)+4,
    S_DOTDOTDOT         = (1<< 9)+5,

    S_INT               = (1<<10)+0,
    S_FLOAT             = (1<<10)+1,

    S_TRUE              = (1<<11)+0,
    S_FALSE             = (1<<11)+1,
    S_CHAR              = (1<<11)+2,
    S_STRING            = (1<<11)+3,
    S_TILDE             = (1<<11)+4,
    S_HELP              = (1<<11)+5,
    S_PRAGMA            = (1<<11)+6,


    S_REC               = (1<<12)+0,

    S_FUNCTION          = (1<<13),
    S_LOCAL             = (1<<14),
    S_END               = (1<<15),
    S_MAPTO             = (1<<16),

    S_MULT              = (1<<17)+0,
    S_DIV               = (1<<17)+1,
    S_MOD               = (1<<17)+2,
    S_POW               = (1<<17)+3,

    S_PLUS              = (1<<18)+0,
    S_MINUS             = (1<<18)+1,

    S_EQ                = (1<<19)+0,
    S_LT                = (1<<19)+1,
    S_GT                = (1<<19)+2,
    S_NE                = (1<<19)+3,
    S_LE                = (1<<19)+4,
    S_GE                = (1<<19)+5,
    S_IN                = (1<<19)+6,

    S_NOT               = (1<<20)+0,
    S_AND               = (1<<20)+1,
    S_OR                = (1<<20)+2,

    S_ASSIGN            = (1<<21),

    S_IF                = (1<<22)+0,
    S_FOR               = (1<<22)+1,
    S_WHILE             = (1<<22)+2,
    S_REPEAT            = (1<<22)+3,
    S_ATOMIC            = (1<<22)+4,

    S_THEN              = (1<<23),
    S_ELIF              = (1<<24)+0,
    S_ELSE              = (1<<24)+1,
    S_FI                = (1<<25),
    S_DO                = (1<<26),
    S_OD                = (1<<27),
    S_UNTIL             = (1<<28),

    S_BREAK             = (1<<29)+0,
    S_RETURN            = (1<<29)+1,
    S_QUIT              = (1<<29)+2,
    S_QQUIT             = (1<<29)+3,
    S_CONTINUE          = (1<<29)+4,

    S_SEMICOLON         = (1<<30)+0,
    S_DUALSEMICOLON     = (1<<30)+1,

    S_EOF               = (1<<31),
};


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
**      identifiers, IsBound, Unbind, Info, Assert
**      if, for, repeat, while, return
**      elif, else
**      not, and, or
**      =, <>, <, >=, <=, >, in
**      +, -
**      *, /, mod, ^
*/
typedef UInt            TypSymbolSet;


/****************************************************************************
**
*F  IS_IN( <symbol>, <set> )  . . . . . . . . is a symbol in a set of symbols
**
**  'IS_IN' returns non-zero if the symbol <symbol> is in the symbol set
**  <set> and 0 otherwise. Due to the grouping into classes some symbol sets
**  may contain more than mentioned.
**  For example 'IS_IN(S_POW,S_MULT|S_DIV|S_MOD)' is 1.
*/
#define IS_IN(symbol,set)       ((symbol) & ((set) & ~7))


/****************************************************************************
**
*V  EXPRBEGIN . . . . . . . . . . . . set of symbols that start an expression
*V  STATBEGIN . . . . . . . . . . . . . set of symbols that start a statement
**
**  'EXPRBEGIN'  is the  set  of  symbols   that might  start  an expression.
**
**  'STATBEGIN' is the set of symbols that might start a statement.
*/
#define EXPRBEGIN  (S_IDENT|S_ISBOUND|S_INT|S_TRUE|S_FALSE|S_TILDE \
                    |S_CHAR|S_STRING|S_LBRACK|S_REC|S_FUNCTION \
                    |S_PLUS|S_MINUS|S_NOT|S_LPAREN)

#define STATBEGIN  (S_IDENT|S_UNBIND|S_IF|S_FOR|S_WHILE|S_REPEAT \
                    |S_BREAK|S_RETURN|S_HELP|S_QUIT)


/****************************************************************************
**
*T  ScannerState
**
**  The struct 'ScannerState' encapsulates the state of the scanner.
*/
typedef struct {

    //
    TypInputFile * input;

    // If 'Symbol' is 'S_IDENT', 'S_INT' or 'S_FLOAT' then normally the
    // variable 'Value' holds the name of the identifier, the digits of the
    // integer or float literal as a C string. For large integer or float
    // literals that do not fit into 'Value', instead 'ValueObj' holds the
    // literal as a GAP string object
    //
    // Note that the size of identifiers in GAP is limited to 1023 characters,
    // hence identifiers are always stored in 'Value'. For this reason,
    // 'GetIdent' truncates an identifier after that many characters.
    char   Value[1024];

    // For large integer or float literals that do not fit into 'Value',
    // instead 'ValueObj' holds the literal as a GAP string object. If the
    // symbol is 'S_STRING' or 'S_HELP', the string literal or help text is
    // always stored in 'ValueObj' as a GAP string object.
    Obj    ValueObj;

    //
    enum SCANNER_SYMBOLS Symbol;

    // Track the last three symbols, for 'Unbound global' warnings
    UInt   SymbolStartPos[3];
    UInt   SymbolStartLine[3];
    
    // 'NrError' is an integer whose value is the number of errors already
    // found in the current expression. It is set to 0 at the beginning of
    // 'Read' and incremented with each 'SyntaxError' call, including those
    // from 'Match'.
    //
    // If 'NrError' is greater than zero the parser functions will not create
    // new bags. This prevents the parser from creating new bags after an
    // error occurred.
    UInt NrError;

} ScannerState;


/****************************************************************************
**
*F  SyntaxError( <msg> ) . . . . . . . . . . . . . . . . raise a syntax error
*F  SyntaxWarning( <msg> ) . . . . . . . . . . . . . . raise a syntax warning
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
**  the parser from creating new bags after an error occurred.
**
**  'SyntaxError' also records the current line number in 'lastErrorLine' to
**  prevent the printing of multiple error messages for one line, since they
**  usually  just reflect the  fact  that the parser has not resynchronized
**  yet.
** 
**  'SyntaxWarning' displays in the same way but does not change 'NrError'
**  or 'lastErrorLine'.
**
**  Note that unlike 'ErrorQuit', neither function raises an actual error,
**  so execution continues as normal. Thus you must make sure that subsequent
**  code can safely recover from the indicated error.
**
**  Both functions should only be called from the scanner or reader, but not
**  from e.g. the interpreter or coder, let alone any other parts of GAP.
**
**  The 'WithOffset' variants allow marking a previously parsed token as
**  the syntax error. This is used by 'Unbound global variable', as GAP
**  does not know if a variable is unbound until another 2 tokens are read.
**
*/
void SyntaxErrorWithOffset(ScannerState * s,
                           const Char *   msg,
                           Int            tokenoffset);

void SyntaxWarningWithOffset(ScannerState * s,
                             const Char *   msg,
                             Int            tokenoffset);

EXPORT_INLINE void SyntaxError(ScannerState * s, const Char * msg)
{
    SyntaxErrorWithOffset(s, msg, 0);
}

EXPORT_INLINE void SyntaxWarning(ScannerState * s, const Char * msg)
{
    SyntaxWarningWithOffset(s, msg, 0);
}


/****************************************************************************
**
*F  Match( <symbol>, <msg>, <skipto> )  . match current symbol and fetch next
**
**  'Match' is the main  interface between the  scanner and the  parser.   It
**  performs the four most common actions in the scanner with  just one call.
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
**      'Match( Symbol, "", 0 );'.
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
**  been called from 'ReadFor'. <follow> always contain 'S_EOF', which 'Read'
**  uses to resynchronise.
**
**  If 'Match' needs to  read a  new line from  '*stdin*' or '*errin*' to get
**  the next symbol it prints the string pointed to by 'Prompt'.
*/
void Match(ScannerState * s,
           UInt           symbol,
           const Char *   msg,
           TypSymbolSet   skipto);


/****************************************************************************
**
*F  ScanForFloatAfterDotHACK()
**
**  This function is called by 'ReadLiteral' if it encounters a single dot in
**  form the of the symbol 'S_DOT'. The only legal way this could happen is
**  if the dot is the start of a float literal like '.123'. As the scanner
**  cannot detect this without being context aware, we must provide this
**  function to allow the reader to signal to the scanner about this.
*/
void ScanForFloatAfterDotHACK(ScannerState * s);


#endif // GAP_SCANNER_H
