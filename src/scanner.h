/****************************************************************************
**
*W  scanner.h                   GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file declares the functions of the scanner, which is responsible for
**  all input and output processing.
**
**  The scanner  exports two very  important abstractions.  The  first is the
**  concept that an input file is  a stream of symbols,  such nasty things as
**  <space>,  <tab>,  <newline> characters or  comments (they are worst  :-),
**  characters making  up identifiers  or  digits that  make  up integers are
**  hidden from the rest of GAP.
**
**  The second is  the concept of  a current input  and output file.   In the
**  main   module   they are opened  and   closed  with the  'OpenInput'  and
**  'CloseInput' respectively  'OpenOutput' and 'CloseOutput' calls.  All the
**  other modules just read from the  current input  and write to the current
**  output file.
**
**  The scanner relies on the functions  provided  by  the  operating  system
**  dependent module 'system.c' for the low level input/output.
*/

#ifndef GAP_SCANNER_H
#define GAP_SCANNER_H


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
#define S_ILLEGAL       (0UL)

#define S_IDENT         ((1UL<< 3))
#define S_UNBIND        ((1UL<< 3)+1)
#define S_ISBOUND       ((1UL<< 3)+2)
#define S_TRYNEXT       ((1UL<< 3)+3)
#define S_INFO          ((1UL<< 3)+4)
#define S_ASSERT        ((1UL<< 3)+5)
#define S_LBRACK        ((1UL<< 4)+0)
#define S_LBRACE        ((1UL<< 4)+1)
#define S_BLBRACK       ((1UL<< 4)+2)
#define S_BLBRACE       ((1UL<< 4)+3)
#define S_RBRACK        ((1UL<< 5)+0)
#define S_RBRACE        ((1UL<< 5)+1)
#define S_DOT           ((1UL<< 6)+0)
#define S_BDOT          ((1UL<< 6)+1)
#define S_LPAREN        ((1UL<< 7))
#define S_RPAREN        ((1UL<< 8))
#define S_COMMA         ((1UL<< 9)+0)
#define S_DOTDOT        ((1UL<< 9)+1)
#define S_COLON         ((1UL<< 9)+2)
#define S_READWRITE     ((1UL<< 9)+3)
#define S_READONLY      ((1UL<< 9)+4)
#define S_DOTDOTDOT     ((1UL<< 9)+5)

#define S_PARTIALINT    ((1UL<<10)+0) /* Some digits */
#define S_INT           ((1UL<<10)+1)
#define S_FLOAT         ((1UL<<10)+2)

/* A decimal point only, but in a context where we know it's the start of a
   number */
#define S_PARTIALFLOAT1  ((1UL<<10)+3)

/* Some digits and a decimal point */
#define S_PARTIALFLOAT2  ((1UL<<10)+4)

/* Some digits and a decimal point and an exponent indicator and maybe a
   sign, but no digits*/
#define S_PARTIALFLOAT3  ((1UL<<10)+5)

/* Some digits and a decimal point and an exponent indicator and maybe a
   sign, and at least one digit*/
#define S_PARTIALFLOAT4  ((1UL<<10)+6)

#define S_TRUE          ((1UL<<11)+0)
#define S_FALSE         ((1UL<<11)+1)
#define S_CHAR          ((1UL<<11)+2)
#define S_STRING        ((1UL<<11)+3)
#define S_PARTIALSTRING ((1UL<<11)+4)
#define S_PARTIALTRIPSTRING   ((1UL<<11)+5)
#define S_TILDE         ((1UL<< 3)+6)

#define S_REC           ((1UL<<12)+0)
#define S_BACKQUOTE     ((1UL<<12)+1)

#define S_FUNCTION      ((1UL<<13))
#define S_LOCAL         ((1UL<<14))
#define S_END           ((1UL<<15))
#define S_MAPTO         ((1UL<<16))

#define S_MULT          ((1UL<<17)+0)
#define S_DIV           ((1UL<<17)+1)
#define S_MOD           ((1UL<<17)+2)
#define S_POW           ((1UL<<17)+3)

#define S_PLUS          ((1UL<<18)+0)
#define S_MINUS         ((1UL<<18)+1)

#define S_EQ            ((1UL<<19)+0)
#define S_LT            ((1UL<<19)+1)
#define S_GT            ((1UL<<19)+2)
#define S_NE            ((1UL<<19)+3)
#define S_LE            ((1UL<<19)+4)
#define S_GE            ((1UL<<19)+5)
#define S_IN            ((1UL<<19)+6)

#define S_NOT           ((1UL<<20)+0)
#define S_AND           ((1UL<<20)+1)
#define S_OR            ((1UL<<20)+2)

#define S_ASSIGN        ((1UL<<21)+0)
#define S_INCORPORATE   ((1UL<<21)+1)

#define S_IF            ((1UL<<22)+0)
#define S_FOR           ((1UL<<22)+1)
#define S_WHILE         ((1UL<<22)+2)
#define S_REPEAT        ((1UL<<22)+3)
#define S_ATOMIC        ((1UL<<22)+4)

#define S_THEN          ((1UL<<23))
#define S_ELIF          ((1UL<<24)+0)
#define S_ELSE          ((1UL<<24)+1)
#define S_FI            ((1UL<<25))
#define S_DO            ((1UL<<26))
#define S_OD            ((1UL<<27))
#define S_UNTIL         ((1UL<<28))

#define S_BREAK         ((1UL<<29)+0)
#define S_RETURN        ((1UL<<29)+1)
#define S_QUIT          ((1UL<<29)+2)
#define S_QQUIT         ((1UL<<29)+3)
#define S_CONTINUE      ((1UL<<29)+4)

#define S_SEMICOLON     ((1UL<<30))

#define S_EOF           ((1UL<<31))

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
                    |S_BREAK|S_RETURN|S_QUIT)


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
#define MAX_VALUE_LEN 1025

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


/****************************************************************************
**
*V  Prompt  . . . . . . . . . . . . . . . . . . . . . .  prompt to be printed
**
**  'Prompt' holds the string that is to be printed if a  new  line  is  read
**  from the interactive files '*stdin*' or '*errin*'.
**
**  It is set to 'gap> ' or 'brk> ' in the  read-eval-print loops and changed
**  to the partial prompt '> ' in 'Read' after the first symbol is read.
*/
/* TL: extern  const Char *    Prompt; */

/***************************************************************************** 
**
*V  PrintPromptHook . . . . . . . . . . . . . .  function for printing prompt
*V  EndLineHook . . . . . . . . . . .  function called at end of command line
**  
**  These functions can be set on GAP-level. If they are not bound  the 
**  default is: Instead of `PrintPromptHook' the `Prompt' is printed and
**  instead of `EndLineHook' nothing is done.
*/
/* TL: extern Obj  PrintPromptHook; */
extern Obj  EndLineHook;

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
**  example in 'RdReturn'  the   first symbol must be 'S_RETURN',   otherwise
**  'RdReturn' would not have been  called.  Called this  way 'Match' will of
**  course never raise a syntax error,  therefore <msg>  and <skipto> are of
**  no concern, they are passed nevertheless  to please  lint.  The effect of
**  this call is merely to read the next symbol from input.
**
**  Another typical 'Match' call is in 'RdIf' after we read the if symbol and
**  the condition following, and now expect to see the 'then' symbol:
**
**      Match( S_THEN, "then", STATBEGIN|S_ELIF|S_ELSE|S_FI|follow );
**
**  If the current symbol  is 'S_THEN' it is  matched  and the next symbol is
**  read.  Otherwise 'Match'  prints the  current line followed by the  error
**  message: '^ syntax error, then expected'.  Then 'Match' skips all symbols
**  until finding either  a symbol  that can begin  a statment,  an 'elif' or
**  'else' or 'fi' symbol, or a symbol that is  contained in the set <follow>
**  which is passed to  'RdIf' and contains  all symbols allowing  one of the
**  calling functions to resynchronize, for example 'S_OD' if 'RdIf' has been
**  called from 'RdFor'.  <follow>  always contain 'S_EOF', which 'Read' uses
**  to resynchronise.
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
*F  ClearError()  . . . . . . . . . . . . . .  reset execution and error flag
*/
extern void ClearError ( void );

/****************************************************************************
**
*F  BreakLoopPending()  . . . . . .report whether a break loop is pending due
**                               to Ctrl-C, memory overflow, or similar cause
**
**  return  values 0 -- no break loop
**                 BLP_CTRLC -- break loop due to ctrl-C
**                 BLP_MEMORY -- due to -o 
**
*/


extern Int BreakLoopPending( void );
#define BLP_CTRLC 1
#define BLP_MEMORY 2


/****************************************************************************
**

*F * * * * * * * * * * * open input/output functions  * * * * * * * * * * * *
*/


/****************************************************************************
**

*F  OpenInput( <filename> ) . . . . . . . . . .  open a file as current input
**
**  'OpenInput' opens  the file with  the name <filename>  as  current input.
**  All  subsequent input will  be taken from that  file, until it is  closed
**  again  with 'CloseInput'  or  another file  is opened  with  'OpenInput'.
**  'OpenInput'  will not  close the  current  file, i.e., if  <filename>  is
**  closed again, input will again be taken from the current input file.
**
**  'OpenInput'  returns 1 if  it   could  successfully open  <filename>  for
**  reading and 0  to indicate  failure.   'OpenInput' will fail if  the file
**  does not exist or if you do not have permissions to read it.  'OpenInput'
**  may  also fail if  you have too  many files open at once.   It  is system
**  dependent how many are  too many, but  16  files should  work everywhere.
**
**  Directely after the 'OpenInput' call the variable  'Symbol' has the value
**  'S_ILLEGAL' to indicate that no symbol has yet been  read from this file.
**  The first symbol is read by 'Read' in the first call to 'Match' call.
**
**  You can open  '*stdin*' to  read  from the standard  input file, which is
**  usually the terminal, or '*errin*' to  read from the standard error file,
**  which  is  the  terminal  even if '*stdin*'  is  redirected from  a file.
**  'OpenInput' passes those  file names  to  'SyFopen' like any other  name,
**  they are  just  a  convention between the  main  and the system  package.
**  'SyFopen' and thus 'OpenInput' will  fail to open  '*errin*' if the  file
**  'stderr'  (Unix file  descriptor  2)  is  not a  terminal,  because  of a
**  redirection say, to avoid that break loops take their input from a file.
**
**  It is not neccessary to open the initial input  file, 'InitScanner' opens
**  '*stdin*' for  that purpose.  This  file on   the other   hand  cannot be
**  closed by 'CloseInput'.
*/
extern UInt OpenInput (
    const Char *        filename );


/****************************************************************************
**
*F  OpenInputStream( <stream> ) . . . . . . .  open a stream as current input
**
**  The same as 'OpenInput' but for streams.
*/
extern UInt OpenInputStream (
    Obj                 stream );


/****************************************************************************
**
*F  CloseInput()  . . . . . . . . . . . . . . . . .  close current input file
**
**  'CloseInput'  will close the  current input file.   Subsequent input will
**  again be taken from the previous input file.   'CloseInput' will return 1
**  to indicate success.
**
**  'CloseInput' will not close the initial input file '*stdin*', and returns
**  0  if such  an  attempt is made.   This is  used in  'Error'  which calls
**  'CloseInput' until it returns 0, therebye closing all open input files.
**
**  Calling 'CloseInput' if the  corresponding  'OpenInput' call failed  will
**  close the current output file, which will lead to very strange behaviour.
*/
extern UInt CloseInput ( void );


/****************************************************************************
**
*F  OpenLog( <filename> ) . . . . . . . . . . . . . log interaction to a file
**
**  'OpenLog'  instructs  the scanner to   echo  all  input   from  the files
**  '*stdin*' and  '*errin*'  and  all  output to  the  files '*stdout*'  and
**  '*errout*' to the file with  name <filename>.  The  file is truncated  to
**  size 0 if it existed, otherwise it is created.
**
**  'OpenLog' returns 1 if it could  successfully open <filename> for writing
**  and 0  to indicate failure.   'OpenLog' will  fail if  you do  not   have
**  permissions  to create the file or   write to  it.  'OpenOutput' may also
**  fail if you have too many files open at once.  It is system dependent how
**  many   are too   many, but  16   files should  work everywhere.   Finally
**  'OpenLog' will fail if there is already a current logfile.
*/
extern UInt OpenLog (
    const Char *        filename );


/****************************************************************************
**
*F  OpenLogStream( <stream> ) . . . . . . . . . . log interaction to a stream
**
**  The same as 'OpenLog' but for streams.
*/
extern UInt OpenLogStream (
    Obj             stream );


/****************************************************************************
**
*F  CloseLog()  . . . . . . . . . . . . . . . . . . close the current logfile
**
**  'CloseLog' closes the current logfile again, so that input from '*stdin*'
**  and '*errin*' and output to '*stdout*' and '*errout*' will no  longer  be
**  echoed to a file.  'CloseLog' will return 1 to indicate success.
**
**  'CloseLog' will fail if there is no logfile active and will return  0  in
**  this case.
*/
extern UInt CloseLog ( void );


/****************************************************************************
**
*F  OpenInputLog( <filename> )  . . . . . . . . . . . . . log input to a file
**
**  'OpenInputLog'  instructs the  scanner  to echo  all input from the files
**  '*stdin*' and  '*errin*' to the file  with  name <filename>.  The file is
**  truncated to size 0 if it existed, otherwise it is created.
**
**  'OpenInputLog' returns 1  if it  could successfully open  <filename>  for
**  writing  and  0 to indicate failure.  'OpenInputLog' will fail  if you do
**  not have  permissions to create the file  or write to it.  'OpenInputLog'
**  may also fail  if you  have  too many  files open  at once.  It is system
**  dependent  how many are too many,  but 16 files  should work  everywhere.
**  Finally 'OpenInputLog' will fail if there is already a current logfile.
*/
extern UInt OpenInputLog (
    const Char *        filename );


/****************************************************************************
**
*F  OpenInputLogStream( <stream> )  . . . . . . . . . . log input to a stream
**
**  The same as 'OpenInputLog' but for streams.
*/
extern UInt OpenInputLogStream (
    Obj                 stream );


/****************************************************************************
**
*F  CloseInputLog() . . . . . . . . . . . . . . . . close the current logfile
**
**  'CloseInputLog'  closes  the current  logfile again,  so  that input from
**  '*stdin*'  and   '*errin*'  will  no  longer   be  echoed   to  a   file.
**  'CloseInputLog' will return 1 to indicate success.
**
**  'CloseInputLog' will fail if there is no logfile active and will return 0
**  in this case.
*/
extern UInt CloseInputLog ( void );


/****************************************************************************
**
*F  OpenOutputLog( <filename> )  . . . . . . . . . . .  log output to a file
**
**  'OpenInputLog'  instructs the  scanner to echo   all output to  the files
**  '*stdout*' and '*errout*' to the file with name  <filename>.  The file is
**  truncated to size 0 if it existed, otherwise it is created.
**
**  'OpenOutputLog'  returns 1 if it  could  successfully open <filename> for
**  writing and 0 to  indicate failure.  'OpenOutputLog'  will fail if you do
**  not have permissions to create the file  or write to it.  'OpenOutputLog'
**  may also  fail if you have  too many  files  open at  once.  It is system
**  dependent how many are  too many,  but  16 files should  work everywhere.
**  Finally 'OpenOutputLog' will fail if there is already a current logfile.
*/
extern UInt OpenOutputLog (
    const Char *        filename );


/****************************************************************************
**
*F  OpenOutputLogStream( <stream> )  . . . . . . . .  log output to a stream
**
**  The same as 'OpenOutputLog' but for streams.
*/
extern UInt OpenOutputLogStream (
    Obj                 stream );


/****************************************************************************
**
*F  CloseOutputLog()  . . . . . . . . . . . . . . . close the current logfile
**
**  'CloseInputLog' closes   the current logfile   again, so  that output  to
**  '*stdout*'  and    '*errout*'  will no   longer  be   echoed to  a  file.
**  'CloseOutputLog' will return 1 to indicate success.
**
**  'CloseOutputLog' will fail if there is  no logfile active and will return
**  0 in this case.
*/
extern UInt CloseOutputLog ( void );


/****************************************************************************
**
*F  OpenOutput( <filename> )  . . . . . . . . . open a file as current output
**
**  'OpenOutput' opens the file  with the name  <filename> as current output.
**  All subsequent output will go  to that file, until either   it is  closed
**  again  with 'CloseOutput' or  another  file is  opened with 'OpenOutput'.
**  The file is truncated to size 0 if it existed, otherwise it  is  created.
**  'OpenOutput' does not  close  the  current file, i.e., if  <filename>  is
**  closed again, output will go again to the current output file.
**
**  'OpenOutput'  returns  1 if it  could  successfully  open  <filename> for
**  writing and 0 to indicate failure.  'OpenOutput' will fail if  you do not
**  have  permissions to create the  file or write   to it.  'OpenOutput' may
**  also   fail if you   have  too many files   open  at once.   It is system
**  dependent how many are too many, but 16 files should work everywhere.
**
**  You can open '*stdout*'  to write  to the standard output  file, which is
**  usually the terminal, or '*errout*' to write  to the standard error file,
**  which is the terminal  even   if '*stdout*'  is  redirected to   a  file.
**  'OpenOutput' passes  those  file names to 'SyFopen'  like any other name,
**  they are just a convention between the main and the system package.
**  The function does nothing and returns success for '*stdout*' and '*errout*'
**  when IgnoreStdoutErrout is true (useful for testing purposes).
**
**  It is not neccessary to open the initial output file, 'InitScanner' opens
**  '*stdout*' for that purpose.  This  file  on the other hand   can not  be
**  closed by 'CloseOutput'.
*/
extern UInt OpenOutput (
    const Char *        filename );


/****************************************************************************
**
*F  OpenOutputStream( <stream> )  . . . . . . open a stream as current output
**
**  The same as 'OpenOutput' (and also 'OpenAppend') but for streams.
*/
extern UInt OpenOutputStream (
    Obj                 stream );


/****************************************************************************
**
*F  CloseOutput() . . . . . . . . . . . . . . . . . close current output file
**
**  'CloseOutput' will  first flush all   pending output and  then  close the
**  current  output  file.   Subsequent output will  again go to the previous
**  output file.  'CloseOutput' returns 1 to indicate success.
**
**  'CloseOutput' will  not  close the  initial output file   '*stdout*', and
**  returns 0 if such attempt is made.  This  is  used in 'Error' which calls
**  'CloseOutput' until it returns 0, thereby closing all open output files.
**
**  Calling 'CloseOutput' if the corresponding 'OpenOutput' call failed  will
**  close the current output file, which will lead to very strange behaviour.
**  On the other  hand if you  forget  to call  'CloseOutput' at the end of a
**  'PrintTo' call or an error will not yield much better results.
*/
extern UInt CloseOutput ( void );


/****************************************************************************
**
*F  OpenAppend( <filename> )  . . open a file as current output for appending
**
**  'OpenAppend' opens the file  with the name  <filename> as current output.
**  All subsequent output will go  to that file, until either   it is  closed
**  again  with 'CloseOutput' or  another  file is  opened with 'OpenOutput'.
**  Unlike 'OpenOutput' 'OpenAppend' does not truncate the file to size 0  if
**  it exists.  Appart from that 'OpenAppend' is equal to 'OpenOutput' so its
**  description applies to 'OpenAppend' too.
*/
extern UInt OpenAppend (
    const Char *        filename );


/****************************************************************************
**
*T  TypInputFile  . . . . . . . . . .  structure of an open input file, local
**
**  'TypInputFile' describes the  information stored  for  open input  files:
**
**  'isstream' is 'true' if input come from a stream.
**
**  'file'  holds the  file identifier  which  is received from 'SyFopen' and
**  which is passed to 'SyFgets' and 'SyFclose' to identify this file.
**
**  'name' is the name of the file, this is only used in error messages.
**
**  'line' is a  buffer that holds the  current input  line.  This is  always
**  terminated by the character '\0'.  Because 'line' holds  only part of the
**  line for very long lines the last character need not be a <newline>.
**
**  'ptr' points to the current character within that line.  This is not used
**  for the current input file, where 'In' points to the  current  character.
**
**  'number' is the number of the current line, is used in error messages.
**
**  'stream' is none zero if the input points to a stream.
**
**  'sline' contains the next line from the stream as GAP string.
**
*/
typedef struct {
  UInt        isstream;
  Int         file;
  Char        name [256];
  Obj         gapname;
  UInt        gapnameid;
  Char        line [32768];
  Char *      ptr;
  UInt        symbol;
  Int         number;
  Obj         stream;
  UInt        isstringstream;
  Obj         sline;
  Int         spos;
  UInt        echo;
} TypInputFile;



/****************************************************************************
**
*V  InputFiles[]  . . . . . . . . . . . . .  stack of open input files, local
*V  Input . . . . . . . . . . . . . . .  pointer to current input file, local
*V  In  . . . . . . . . . . . . . . . . . pointer to current character, local
**
**  'InputFiles' is the stack of the open input  files.  It is represented as
**  an array of structures of type 'TypInputFile'.
**
**  'Input' is a pointer to the current input file.   It points to the top of
**  the stack 'InputFiles'.
**
**  'In' is a  pointer to  the current  input character, i.e.,  '*In' is  the
**  current input character.  It points into the buffer 'Input->line'.
*/

/* TL: extern TypInputFile    InputFiles [16]; */
/* TL: extern TypInputFile *  Input; */
/* TL: extern Char *          In; */


/****************************************************************************
**
*T  TypOutputFiles  . . . . . . . . . structure of an open output file, local
*V  OutputFiles . . . . . . . . . . . . . . stack of open output files, local
*V  Output  . . . . . . . . . . . . . . pointer to current output file, local
**
**  'TypOutputFile' describes the information stored for open  output  files:
**  'file' holds the file identifier which is  received  from  'SyFopen'  and
**  which is passed to  'SyFputs'  and  'SyFclose'  to  identify  this  file.
**  'line' is a buffer that holds the current output line.
**  'pos' is the position of the current character on that line.
**
**  'OutputFiles' is the stack of open output files.  It  is  represented  as
**  an array of structures of type 'TypOutputFile'.
**
**  'Output' is a pointer to the current output file.  It points to  the  top
**  of the stack 'OutputFiles'.
*/
/* the widest allowed screen width */
#define MAXLENOUTPUTLINE  4096
/* the maximal number of used line break hints */ 
#define MAXHINTS 100
typedef struct {
    UInt        isstream;
    UInt        isstringstream;
    Int         file;
    Char        line [MAXLENOUTPUTLINE];
    Int         pos;
    Int         format;
    Int         indent;
    /* each hint is a tripel (position, value, indent) */
    Int         hints[3*MAXHINTS+1];
    Obj         stream;
} TypOutputFile;

/****************************************************************************
**
*F  GetCurrentOutput()  . . . . . . . . . . . get the current thread's output
**
**  The same as 'OpenOutput' but for streams.
*/
extern TypOutputFile *GetCurrentOutput ( void );

/****************************************************************************
**
*F  Pr( <format>, <arg1>, <arg2> )  . . . . . . . . .  print formatted output
**
**  'Pr' is the output function. The first argument is a 'printf' like format
**  string containing   up   to 2  '%'  format   fields,   specifing  how the
**  corresponding arguments are to be  printed.  The two arguments are passed
**  as  'long'  integers.   This  is possible  since every  C object  ('int',
**  'char', pointers) except 'float' or 'double', which are not used  in GAP,
**  can be converted to a 'long' without loss of information.
**
**  The function 'Pr' currently support the following '%' format  fields:
**  '%c'    the corresponding argument represents a character,  usually it is
**          its ASCII or EBCDIC code, and this character is printed.
**  '%s'    the corresponding argument is the address of  a  null  terminated
**          character string which is printed.
**  '%d'    the corresponding argument is a signed integer, which is printed.
**          Between the '%' and the 'd' an integer might be used  to  specify
**          the width of a field in which the integer is right justified.  If
**          the first character is '0' 'Pr' pads with '0' instead of <space>.
**  '%>'    increment the indentation level.
**  '%<'    decrement the indentation level.
**  '%%'    can be used to print a single '%' character. No argument is used.
**
**  You must always  cast the arguments to  '(long)' to avoid  problems  with
**  those compilers with a default integer size of 16 instead of 32 bit.  You
**  must pass 0L if you don't make use of an argument to please lint.
*/

typedef TypOutputFile *KOutputStream;

extern  void            Pr (
            const Char *    format,
            Int                 arg1,
            Int                 arg2 );


extern  void            PrTo (
            KOutputStream   stream,
            const Char *    format,
            Int                 arg1,
            Int                 arg2 );

extern  void            SPrTo (
			       Char * buffer,
			       UInt maxlen,
            const Char *    format,
            Int                 arg1,
            Int                 arg2 );



/****************************************************************************
**
*V  InputLog  . . . . . . . . . . . . . . . file identifier of logfile, local
**
**  'InputLog' is the file identifier of the current input logfile.  If it is
**  not 0  the    scanner echoes all input   from  the files  '*stdin*'   and
**  '*errin*' to this file.
*/
/* TL: extern TypOutputFile * InputLog; */


/****************************************************************************
**
*V  OutputLog . . . . . . . . . . . . . . . file identifier of logfile, local
**
**  'OutputLog' is the file identifier of  the current output logfile.  If it
**  is  not  0  the  scanner echoes  all output  to  the files '*stdout*' and
**  '*errout*' to this file.
*/
/* TL: extern TypOutputFile * OutputLog; */


/****************************************************************************
**
*F  FlushRestOfInputLine()  . . . . . . . . . . . . discard remainder of line
*/

extern void FlushRestOfInputLine( void );




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

/****************************************************************************
**

*E  scanner.h . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
*/
