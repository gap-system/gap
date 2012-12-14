/****************************************************************************
**
*W  scanner.c                   GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl  für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions of the scanner, which is responsible for
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
**  SL 5/99 I now plan to break the second abstraction in regard of output
**  streams. Instead of all Print/View/etc output going via Pr to PutLine, etc.
**  they will go via PrTo and PutLineTo. The extra argument of these will be
**  of type KOutputStream, a pointer to a C structure (using a GAP object would
**  be difficult in the early bootstrap, and because writing to a string stream
**  may cause a garbage collection, which can be a pain).
**
**  The scanner relies on the functions  provided  by  the  operating  system
**  dependent module 'system.c' for the low level input/output.
*/
#include        "system.h"              /* system dependent part           */


#include        "sysfiles.h"            /* file input/output               */

#include        "gasman.h"              /* garbage collector               */
#include        "objects.h"             /* objects                         */

#include        "scanner.h"             /* scanner                         */

#include        "gap.h"                 /* error handling, initialisation  */

#include        "gvars.h"               /* global variables                */
#include        "calls.h"               /* generic call mechanism          */

#include        "bool.h"                /* booleans                        */

#include        "records.h"             /* generic records                 */
#include        "precord.h"             /* plain records                   */

#include        "lists.h"               /* generic lists                   */
#include        "plist.h"              /* plain lists                     */
#include        "string.h"              /* strings                         */

#include        "opers.h"               /* DoFilter...                     */
#include        "read.h"                /* Call0ArgsInNewReader            */

#include <assert.h>
#include <limits.h>

/****************************************************************************
**

*V  Symbol  . . . . . . . . . . . . . . . . .  current symbol read from input
**
**  The  variable 'Symbol' contains the current  symbol read from  the input.
**  It is represented as an unsigned long integer.
**
**  The possible values for 'Symbol' are defined in the  definition  file  of
**  this package as follows:
**
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

#define S_PARTIALINT    ((1UL<<10)+0)
#define S_INT           ((1UL<<10)+1)

#define S_TRUE          ((1UL<<11)+0)
#define S_FALSE         ((1UL<<11)+1)
#define S_CHAR          ((1UL<<11)+2)
#define S_STRING        ((1UL<<11)+3)
#define S_PARTIALSTRING ((1UL<<11)+4)

#define S_REC           ((1UL<<12))

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

#define S_ASSIGN        ((1UL<<21))

#define S_IF            ((1UL<<22)+0)
#define S_FOR           ((1UL<<22)+1)
#define S_WHILE         ((1UL<<22)+2)
#define S_REPEAT        ((1UL<<22)+3)

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
*/
UInt            Symbol;


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
**  set  would  simply mean  or-ing the  values, as in  'S_IN|TS_STRING', and
**  checking whether a symbol is in a set would be '(<symbol> & <set>) != 0'.
**
**  There  are however more  than 32 different  symbols, so  we must  be more
**  clever.  We  group some  symbols that  are syntactically  equivalent like
**  '*', '/' in a class. We use the least significant 3 bits to differentiate
**  between members in one class.  And now  every symbol class, many of which
**  contain   just  one  symbol,  has exactely  one   of  the  remaining most
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
**
typedef UInt            TypSymbolSet;
*/


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
**
#define IS_IN(symbol,set)       ((symbol) & ((set) & ~7))
*/


/****************************************************************************
**
*V  EXPRBEGIN . . . . . . . . . . . . set of symbols that start an expression
*V  STATBEGIN . . . . . . . . . . . . . set of symbols that start a statement
**
**  'EXPRBEGIN' is  the set   of symbols   that might  start   an expression.
**  'STATBEGIN' is the set of symbols that might  start a stament, this  is a
**  superset of 'EXPRBEGIN', since expressions are themselfs statments.
**
**  'EXPRBEGIN' and 'STATBEGIN'  are defined in  the definition  file of this
**  package as follows:
**
#define EXPRBEGIN  (S_IDENT|S_INT|S_STRING|S_LPAREN|S_FUNCTION)
#define STATBEGIN  (EXPRBEGIN|S_IF|S_FOR|S_WHILE|S_REPEAT|S_RETURN)
*/


/****************************************************************************
**
*V  Value . . . . . . . . . . . .  value of the identifier, integer or string
**
**  If 'Symbol' is 'S_IDENT','S_INT' or 'S_STRING' the variable 'Value' holds
**  the name of the identifier, the digits of the integer or the value of the
**  string constant.
**
**  Note  that  the  size  of  'Value'  limits  the  maximal  number  of
**  significant  characters of  an identifier.  'GetIdent' truncates  an
**  identifier after that many characters.
**
**  The  only other  symbols  which  may not  fit  into  Value are  long
**  integers  or strings.  Therefor we  have  to check  in 'GetInt'  and
**  'GetStr' if  the symbols is  not yet  completely read when  Value is
**  filled.
**
**  We only fill Value up to SAFE_VALUE_SIZE normally. The last few
**  bytes are used in the floating point parsing code to ensure that we don't
**  stop the scan just before a non-digit (., E, +,-, etc.) which would make
**  it hard for the scanner to carry on correctly.
*/
Char            Value [1030];
UInt            ValueLen;
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
UInt            NrError;
UInt            NrErrLine;


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
const Char *    Prompt;

/* see scanner.h */
Obj  PrintPromptHook = 0;
Obj  EndLineHook = 0;



/****************************************************************************
**

*T  TypInputFile  . . . . . . . . . .  structure of an open input file, local
*V  InputFiles[]  . . . . . . . . . . . . .  stack of open input files, local
*V  Input . . . . . . . . . . . . . . .  pointer to current input file, local
*V  In  . . . . . . . . . . . . . . . . . pointer to current character, local
**
**  'TypInputFile' describes the  information stored  for  open input  files:
**  'file' holds the file  identifier which is received  from   'SyFopen' and
**  which  is  passed to 'SyFgets'   and  'SyFclose' to identify  this  file.
**  'name' is the name of  the file, this   is only used  in error  messages.
**  'line' is a buffer  that  holds the current  input  line.  This is always
**  terminated by the character '\0'.  Because 'line' holds  only part of the
**  line for very  long lines  the last character   need not be  a <newline>.
**  'ptr' points to the current character within that line.  This is not used
**  for the current input file, where 'In' points to the  current  character.
**  'number' is the number of the current line, is used in error messages.
**
**  'InputFiles' is the stack of the open input  files.  It is represented as
**  an array of structures of type 'TypInputFile'.
**
**  'Input' is a pointer to the current input file.   It points to the top of
**  the stack 'InputFiles'.
**
**  'In' is a  pointer to  the current  input character, i.e.,  '*In' is  the
**  current input  character.  It points  into the buffer 'Input->line'.
*/
TypInputFile    InputFiles [16];
TypInputFile *  Input;
Char *          In;


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
TypOutputFile   OutputFiles [16];
TypOutputFile * Output;


/****************************************************************************
**
*V  InputLog  . . . . . . . . . . . . . . . file identifier of logfile, local
**
**  'InputLog' is the file identifier of the current input logfile.  If it is
**  not 0  the    scanner echoes all input   from  the files  '*stdin*'   and
**  '*errin*' to this file.
*/
TypOutputFile * InputLog;


/****************************************************************************
**
*V  OutputLog . . . . . . . . . . . . . . . file identifier of logfile, local
**
**  'OutputLog' is the file identifier of  the current output logfile.  If it
**  is  not  0  the  scanner echoes  all output  to  the files '*stdout*' and
**  '*errout*' to this file.
*/
TypOutputFile * OutputLog;


/****************************************************************************
**
*V  TestInput . . . . . . . . . . . . .  file identifier of test input, local
*V  TestOutput  . . . . . . . . . . . . file identifier of test output, local
*V  TestLine  . . . . . . . . . . . . . . . . one line from test input, local
**
**  'TestInput' is the file identifier  of the file for  test input.  If this
**  is  not -1  and  'GetLine' reads  a line  from  'TestInput' that does not
**  begins with  'gap>'  'GetLine' assumes  that this was  expected as output
**  that did not appear and echoes this input line to 'TestOutput'.
**
**  'TestOutput' is the current output file  for test output.  If 'TestInput'
**  is not -1 then 'PutLine' compares every line that is  about to be printed
**  to 'TestOutput' with the next  line from 'TestInput'.   If this line does
**  not starts with 'gap>'  and the rest of  it  matches the output line  the
**  output  line  is not printed  and the  input   comment line is discarded.
**  Otherwise 'PutLine' prints the output line and does not discard the input
**  line.
**
**  'TestLine' holds the one line that is read from 'TestInput' to compare it
**  with a line that is about to be printed to 'TestOutput'.
*/
TypInputFile *  TestInput  = 0;
TypOutputFile * TestOutput = 0;
Char            TestLine [256];


/****************************************************************************
**

*F  SyntaxError( <msg> )  . . . . . . . . . . . . . . .  raise a syntax error
**
**  'SyntaxError' prints the current line, followed by the error message:
**
**      ^ syntax error, <msg> in <current file name>
**
**  with the '^' pointing to the current symbol on the current line.  If  the
**  <current file name> is '*stdin*' it is not printed.
**
**  'SyntaxError' is called from the parser to print error messages for those
**  errors that are not cought by 'Match',  for example if the left hand side
**  of an assignment is not a variable, a list element or a record component,
**  or if two formal arguments of a function have the same identifier.  It is
**  also called for warnings, for example if a statement has no effect.
**
**  'SyntaxError' first increments 'NrError' by   1.  If 'NrError' is greater
**  than zero the parser functions  will not create  new bags.  This prevents
**  the parser from creating new bags after an error occured.
**
**  'SyntaxError' also  increments  'NrErrLine'  by   1.  If  'NrErrLine'  is
**  greater than zero  'SyntaxError' will not print an  error  message.  This
**  prevents the printing of multiple error messages for one line, since they
**  probabely  just reflect the  fact  that the parser has not resynchronized
**  yet.  'NrErrLine' is reset to 0 if a new line is read in 'GetLine'.
*/
void            SyntaxError (
    const Char *        msg )
{
    Int                 i;

    /* open error output                                                   */
    OpenOutput( "*errout*" );
    assert(Output);

    /* one more error                                                      */
    NrError++;
    NrErrLine++;

    /* do not print a message if we found one already on the current line  */
    if ( NrErrLine == 1 )

      {
        /* print the message and the filename, unless it is '*stdin*'          */
        Pr( "Syntax error: %s", (Int)msg, 0L );
        if ( strcmp( "*stdin*", Input->name ) != 0 )
          Pr( " in %s line %d", (Int)Input->name, (Int)Input->number );
        Pr( "\n", 0L, 0L );

        /* print the current line                                              */
        Pr( "%s", (Int)Input->line, 0L );

        /* print a '^' pointing to the current position                        */
        for ( i = 0; i < In - Input->line - 1; i++ ) {
          if ( Input->line[i] == '\t' )  Pr("\t",0L,0L);
          else  Pr(" ",0L,0L);
        }
        Pr( "^\n", 0L, 0L );
      }
    /* close error output                                                  */
    assert(Output);
    CloseOutput();
    assert(Output);
}


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
**  course never raise an syntax error,  therefore <msg>  and <skipto> are of
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
void Match (
    UInt                symbol,
    const Char *        msg,
    TypSymbolSet        skipto )
{
    Char                errmsg [256];

    /* if 'Symbol' is the expected symbol match it away                    */
    if ( symbol == Symbol ) {
        GetSymbol();
    }

    /* else generate an error message and skip to a symbol in <skipto>     */
    else {
        strlcpy( errmsg, msg, sizeof(errmsg) );
        strlcat( errmsg, " expected", sizeof(errmsg) );
        SyntaxError( errmsg );
        while ( ! IS_IN( Symbol, skipto ) )
            GetSymbol();
    }
}


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
UInt OpenInput (
    const Char *        filename )
{
    Int                 file;

    /* fail if we can not handle another open input file                   */
    if ( Input+1 == InputFiles+(sizeof(InputFiles)/sizeof(InputFiles[0])) )
        return 0;

    /* in test mode keep reading from test input file for break loop input */
    if ( TestInput != 0 && ! strcmp( filename, "*errin*" ) )
        return 1;

    /* try to open the input file                                          */
    file = SyFopen( filename, "r" );
    if ( file == -1 )
        return 0;

    /* remember the current position in the current file                   */
    if ( Input+1 != InputFiles ) {
        Input->ptr    = In;
        Input->symbol = Symbol;
    }

    /* enter the file identifier and the file name                         */
    Input++;
    Input->isstream = 0;
    Input->file = file;
    if (strcmp("*errin*", filename) && strcmp("*stdin*", filename))
      Input->echo = 0;
    else
      Input->echo = 1;
    strlcpy( Input->name, filename, sizeof(Input->name) );
    Input->gapname = (Obj) 0;

    /* start with an empty line and no symbol                              */
    In = Input->line;
    In[0] = In[1] = '\0';
    Symbol = S_ILLEGAL;
    Input->number = 1;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenInputStream( <stream> ) . . . . . . .  open a stream as current input
**
**  The same as 'OpenInput' but for streams.
*/
Obj IsStringStream;

UInt OpenInputStream (
    Obj                 stream )
{
    /* fail if we can not handle another open input file                   */
    if ( Input+1 == InputFiles+(sizeof(InputFiles)/sizeof(InputFiles[0])) )
        return 0;

    /* remember the current position in the current file                   */
    if ( Input+1 != InputFiles ) {
        Input->ptr    = In;
        Input->symbol = Symbol;
    }

    /* enter the file identifier and the file name                         */
    Input++;
    Input->isstream = 1;
    Input->stream = stream;
    Input->isstringstream = (CALL_1ARGS(IsStringStream, stream) == True);
    if (Input->isstringstream) {
        Input->sline = ADDR_OBJ(stream)[2];
        Input->spos = INT_INTOBJ(ADDR_OBJ(stream)[1]);
    }
    else {
        Input->sline = 0;
    }
    Input->file = -1;
    Input->echo = 0;
    strlcpy( Input->name, "stream", sizeof(Input->name) );

    /* start with an empty line and no symbol                              */
    In = Input->line;
    In[0] = In[1] = '\0';
    Symbol = S_ILLEGAL;
    Input->number = 1;

    /* indicate success                                                    */
    return 1;
}


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
UInt CloseInput ( void )
{
    /* refuse to close the initial input file                              */
    if ( Input == InputFiles )
        return 0;

    /* refuse to close the test input file                                 */
    if ( Input == TestInput )
        return 0;

    /* close the input file                                                */
    if ( ! Input->isstream ) {
        SyFclose( Input->file );
    }

    /* don't keep GAP objects alive unnecessarily */
    Input->gapname = 0;
    Input->sline = 0;

    /* revert to last file                                                 */
    Input--;
    In     = Input->ptr;
    Symbol = Input->symbol;



    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  FlushRestOfInputLine()  . . . . . . . . . . . . discard remainder of line
*/

void FlushRestOfInputLine( void )
{
  In[0] = In[1] = '\0';
  /*   Input->number = 1; */
  Symbol = S_ILLEGAL;
}



/****************************************************************************
**
*F  OpenTest( <filename> )  . . . . . . . .  open an input file for test mode
**
**  'OpenTest'  opens the file with the  name <filename> as current input for
**  test mode.  All subsequent input will  be taken  from that file, until it
**  is closed   again with  'CloseTest'   or another  file is   opened   with
**  'OpenInput'.   'OpenTest' will  not  close the   current file,  i.e.,  if
**  <filename> is  closed again, input will be  taken again from  the current
**  input file.
**
**  Test mode works as follows.  If the  scanner is about  to print a line to
**  the current output  file (or to be  more precise to  the output file that
**  was current when  'OpenTest' was called) this  line is compared with  the
**  next line from the test  input file, i.e.,  the one opened by 'OpenTest'.
**  If this line does not start  with  'gap>' and the rest  of it matches the
**  output line the output line is not printed and the  input comment line is
**  discarded.   Otherwise the scanner  prints the  output  line and does not
**  discard the input line.
**
**  On the other hand if an input line is encountered on  the test input that
**  does not start with 'gap>'  the scanner assumes that  this is an expected
**  output  line that  did not appear  and  echoes  this line  to the current
**  output file.
**
**  The upshot is that you  can write test files  that consist of alternating
**  input starting with 'gap>' and lines the expected output.  If GAP behaves
**  normal and produces the expected output then  nothing is printed.  But if
**  something  goes wrong  you  see what actually   was printed and what  was
**  expected instead.
**
**  As a convention GAP test files should start with:
**
**    gap> START_TEST("%Id%");
**
**  where the '%' is to be replaced by '$' and end with
**
**    gap> STOP_TEST( "filename.tst", 123456789 );
**
**  This tells the user that the  test file completed  and also how much time
**  it took.  The constant should be such that a P5-133MHz gets roughly 10000
**  GAPstones.
**
**  'OpenTest' returns 1 if it could successfully open <filename> for reading
**  and  0 to indicate failure.  'OpenTest'  will fail if   the file does not
**  exist or if you have no permissions to read it.  'OpenTest' may also fail
**  if you have too many files open at once.  It is system dependent how many
**  are too may, but 16 files shoule work everywhere.
**
**  Directely after the 'OpenTest'  call the variable  'Symbol' has the value
**  'S_ILLEGAL' to indicate that no symbol has yet been  read from this file.
**  The first symbol is read by 'Read' in the first call to 'Match' call.
*/
UInt OpenTest (
    const Char *        filename )
{
    /* do not allow to nest test files                                     */
    if ( TestInput != 0 )
        return 0;

    /* try to open the file as input file                                  */
    if ( ! OpenInput( filename ) )
        return 0;

    /* remember this is a test input                                       */
    TestInput   = Input;
    TestOutput  = Output;
    TestLine[0] = '\0';

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenTestStream( <stream> )  . . . . .  open an input stream for test mode
**
**  The same as 'OpenTest' but for streams.
*/
UInt OpenTestStream (
    Obj                 stream )
{
    /* do not allow to nest test files                                     */
    if ( TestInput != 0 )
        return 0;

    /* try to open the file as input file                                  */
    if ( ! OpenInputStream( stream ) )
        return 0;

    /* remember this is a test input                                       */
    TestInput   = Input;
    TestOutput  = Output;
    TestLine[0] = '\0';

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  CloseTest() . . . . . . . . . . . . . . . . . . close the test input file
**
**  'CloseTest'  closes the  current test  input  file and ends  test   mode.
**  Subsequent  input   will again be taken   from  the previous  input file.
**  Output will no longer be compared with  comment lines from the test input
**  file.  'CloseTest' will return 1 to indicate success.
**
**  'CloseTest' will not close a non test input file and returns 0 if such an
**  attempt is made.
*/
UInt CloseTest ( void )
{
    /* refuse to a non test file                                           */
    if ( TestInput != Input )
        return 0;

    /* close the input file                                                */
    if ( ! Input->isstream ) {
        SyFclose( Input->file );
    }

    /* revert to last file                                                 */
    Input--;
    In     = Input->ptr;
    Symbol = Input->symbol;

    /* we are no longer in test mode                                       */
    TestInput   = 0;
    TestOutput  = 0;
    TestLine[0] = '\0';

    /* indicate success                                                    */
    return 1;
}


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
static TypOutputFile logFile;

UInt OpenLog (
    const Char *        filename )
{

    /* refuse to open a logfile if we already log to one                   */
    if ( InputLog != 0 || OutputLog != 0 )
        return 0;

    /* try to open the file                                                */
    logFile.file = SyFopen( filename, "w" );
    logFile.isstream = 0;
    if ( logFile.file == -1 )
        return 0;

    InputLog  = &logFile;
    OutputLog = &logFile;

    /* otherwise indicate success                                          */
    return 1;
}


/****************************************************************************
**
*F  OpenLogStream( <stream> ) . . . . . . . . . . log interaction to a stream
**
**  The same as 'OpenLog' but for streams.
*/
static TypOutputFile logStream;

UInt OpenLogStream (
    Obj             stream )
{

    /* refuse to open a logfile if we already log to one                   */
    if ( InputLog != 0 || OutputLog != 0 )
        return 0;

    /* try to open the file                                                */
    logStream.isstream = 1;
    logStream.stream = stream;
    logStream.file = -1;

    InputLog  = &logStream;
    OutputLog = &logStream;

    /* otherwise indicate success                                          */
    return 1;
}


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
UInt CloseLog ( void )
{
    /* refuse to close a non existent logfile                              */
    if ( InputLog == 0 || OutputLog == 0 || InputLog != OutputLog )
        return 0;

    /* close the logfile                                                   */
    if ( ! InputLog->isstream ) {
        SyFclose( InputLog->file );
    }
    InputLog  = 0;
    OutputLog = 0;

    /* indicate success                                                    */
    return 1;
}


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
static TypOutputFile inputLogFile;

UInt OpenInputLog (
    const Char *        filename )
{

    /* refuse to open a logfile if we already log to one                   */
    if ( InputLog != 0 )
        return 0;

    /* try to open the file                                                */
    inputLogFile.file = SyFopen( filename, "w" );
    inputLogFile.isstream = 0;
    if ( inputLogFile.file == -1 )
        return 0;

    InputLog = &inputLogFile;

    /* otherwise indicate success                                          */
    return 1;
}


/****************************************************************************
**
*F  OpenInputLogStream( <stream> )  . . . . . . . . . . log input to a stream
**
**  The same as 'OpenInputLog' but for streams.
*/
static TypOutputFile inputLogStream;

UInt OpenInputLogStream (
    Obj                 stream )
{

    /* refuse to open a logfile if we already log to one                   */
    if ( InputLog != 0 )
        return 0;

    /* try to open the file                                                */
    inputLogStream.isstream = 1;
    inputLogStream.stream = stream;
    inputLogStream.file = -1;

    InputLog = &inputLogStream;

    /* otherwise indicate success                                          */
    return 1;
}


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
UInt CloseInputLog ( void )
{
    /* refuse to close a non existent logfile                              */
    if ( InputLog == 0 )
        return 0;

    /* refuse to close a log opened with LogTo */
    if (InputLog == OutputLog)
      return 0;
    
    /* close the logfile                                                   */
    if ( ! InputLog->isstream ) {
        SyFclose( InputLog->file );
    }

    InputLog = 0;

    /* indicate success                                                    */
    return 1;
}


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
static TypOutputFile outputLogFile;

UInt OpenOutputLog (
    const Char *        filename )
{

    /* refuse to open a logfile if we already log to one                   */
    if ( OutputLog != 0 )
        return 0;

    /* try to open the file                                                */
    outputLogFile.file = SyFopen( filename, "w" );
    outputLogFile.isstream = 0;
    if ( outputLogFile.file == -1 )
        return 0;

    OutputLog = &outputLogFile;

    /* otherwise indicate success                                          */
    return 1;
}


/****************************************************************************
**
*F  OpenOutputLogStream( <stream> )  . . . . . . . .  log output to a stream
**
**  The same as 'OpenOutputLog' but for streams.
*/
static TypOutputFile outputLogStream;

UInt OpenOutputLogStream (
    Obj                 stream )
{

    /* refuse to open a logfile if we already log to one                   */
    if ( OutputLog != 0 )
        return 0;

    /* try to open the file                                                */
    outputLogStream.isstream = 1;
    outputLogStream.stream = stream;
    outputLogStream.file = -1;

    OutputLog = &outputLogStream;

    /* otherwise indicate success                                          */
    return 1;
}


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
UInt CloseOutputLog ( void )
{
    /* refuse to close a non existent logfile                              */
    if ( OutputLog == 0 )
        return 0;

    /* refuse to close a log opened with LogTo */
    if (OutputLog == InputLog)
      return 0;

    /* close the logfile                                                   */
    if ( ! OutputLog->isstream ) {
        SyFclose( OutputLog->file );
    }

    OutputLog = 0;

    /* indicate success                                                    */
    return 1;
}

TypOutputFile*  IgnoreStdoutErrout = NULL;

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
**
**  It is not neccessary to open the initial output file, 'InitScanner' opens
**  '*stdout*' for that purpose.  This  file  on the other hand   can not  be
**  closed by 'CloseOutput'.
*/
UInt OpenOutput (
    const Char *        filename )
{
    Int                 file;

    /* do nothing for stdout and errout if catched */
    if ( Output != NULL && IgnoreStdoutErrout == Output &&
          ( strcmp( filename, "*errout*" ) == 0
           || strcmp( filename, "*stdout*" ) == 0 ) ) {
        return 1;
    }

    /* fail if we can not handle another open output file                  */
    if ( Output+1==OutputFiles+(sizeof(OutputFiles)/sizeof(OutputFiles[0])) )
        return 0;

    /* in test mode keep printing to test output file for breakloop output */
    if ( TestInput != 0 && ! strcmp( filename, "*errout*" ) )
        return 1;

    /* try to open the file                                                */
    file = SyFopen( filename, "w" );
    if ( file == -1 )
        return 0;

    /* put the file on the stack, start at position 0 on an empty line     */
    if (Output == 0L)
      Output = OutputFiles;
    else
      Output++;
    Output->file     = file;
    Output->line[0]  = '\0';
    Output->pos      = 0;
    Output->indent   = 0;
    Output->isstream = 0;
    Output->format   = 1;

    /* variables related to line splitting, very bad place to split        */
    Output->hints[0] = -1;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenOutputStream( <stream> )  . . . . . . open a stream as current output
**
**  The same as 'OpenOutput' but for streams.
*/

Obj PrintFormattingStatus;

UInt OpenOutputStream (
    Obj                 stream )
{
    /* fail if we can not handle another open output file                  */
    if ( Output+1==OutputFiles+(sizeof(OutputFiles)/sizeof(OutputFiles[0])) )
        return 0;

    /* put the file on the stack, start at position 0 on an empty line     */
    Output++;
    Output->stream   = stream;
    Output->isstringstream = (CALL_1ARGS(IsStringStream, stream) == True);
    Output->format   = (CALL_1ARGS(PrintFormattingStatus, stream) == True);
    Output->line[0]  = '\0';
    Output->pos      = 0;
    Output->indent   = 0;
    Output->isstream = 1;

    /* variables related to line splitting, very bad place to split        */
    Output->hints[0] = -1;

    /* indicate success                                                    */
    return 1;
}


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
UInt CloseOutput ( void )
{

    /* silently refuse to close the test output file this is probably
         an attempt to close *errout* which is silently not opened, so
         lets silently not close it  */
    if ( Output == TestOutput )
        return 1;
    /* and similarly */
    if ( IgnoreStdoutErrout == Output )
        return 1;

    /* refuse to close the initial output file '*stdout*'                  */
    if ( Output == OutputFiles )
      return 0;


    /* flush output and close the file                                     */
    Pr( "%c", (Int)'\03', 0L );
    if ( ! Output->isstream ) {
      SyFclose( Output->file );
    }

    /* revert to previous output file and indicate success                 */
    Output--;
    return 1;
}


/****************************************************************************
**
*F  OpenAppend( <filename> )  . . open a file as current output for appending
**
**  'OpenAppend' opens the file  with the name  <filename> as current output.
**  All subsequent output will go  to that file, until either   it is  closed
**  again  with 'CloseAppend' or  another  file is  opened with 'OpenOutput'.
**  Unlike 'OpenOutput' 'OpenAppend' does not truncate the file to size 0  if
**  it exists.  Appart from that 'OpenAppend' is equal to 'OpenOutput' so its
**  description applies to 'OpenAppend' too.
*/
UInt OpenAppend (
    const Char *        filename )
{
    Int                 file;

    /* fail if we can not handle another open output file                  */
    if ( Output+1==OutputFiles+(sizeof(OutputFiles)/sizeof(OutputFiles[0])) )
        return 0;

    /* in test mode keep printing to test output file for breakloop output */
    if ( TestInput != 0 && ! strcmp( filename, "*errout*" ) )
        return 1;

    /* try to open the file                                                */
    file = SyFopen( filename, "a" );
    if ( file == -1 )
        return 0;

    /* put the file on the stack, start at position 0 on an empty line     */
    Output++;
    Output->file     = file;
    Output->line[0]  = '\0';
    Output->pos      = 0;
    Output->indent   = 0;
    Output->isstream = 0;

    /* variables related to line splitting, very bad place to split        */
    Output->hints[0] = -1;

    /* indicate success                                                    */
    return 1;
}


/****************************************************************************
**
*F  OpenAppendStream( <stream> )  . . . . . . open a stream as current output
**
**  The same as 'OpenAppend' but for streams.
*/
UInt OpenAppendStream (
    Obj                 stream )
{
    return OpenOutputStream(stream);
}


/****************************************************************************
**
*F  CloseAppend() . . . . . . . . . . . . . . . . . close current output file
**
**  'CloseAppend' will  first flush all   pending output and  then  close the
**  current  output  file.   Subsequent output will  again go to the previous
**  output file.  'CloseAppend' returns 1 to indicate success.  'CloseAppend'
**  is exactely equal to 'CloseOutput' so its description applies.
*/
UInt CloseAppend ( void )
{
    /* refuse to close the initial output file '*stdout*'                  */
    if ( Output == OutputFiles )
        return 0;

    /* refuse to close the test output file                                */
    if ( Output == TestOutput )
        return 0;

    /* flush output and close the file                                     */
    Pr( "%c", (Int)'\03', 0L );
    if ( ! Output->isstream ) {
        SyFclose( Output->file );
    }

    /* revert to previous output file and indicate success                 */
    Output--;
    return 1;
}


/****************************************************************************
**

*F * * * * * * * * * * * * * * input functions  * * * * * * * * * * * * * * *
*/


/****************************************************************************
**

*V  ReadLineFunc  . . . . . . . . . . . . . . . . . . . . . . . .  'ReadLine'
*/
Obj ReadLineFunc;


/****************************************************************************
**
*F  GetLine2( <input>, <buffer>, <length> ) . . . . . . . . get a line, local
*/
static Int GetLine2 (
    TypInputFile *          input,
    Char *                  buffer,
    UInt                    length )
{

    if ( input->isstream ) {
        if ( input->sline == 0
          || GET_LEN_STRING(input->sline) <= input->spos )
        {
            input->sline = CALL_1ARGS( ReadLineFunc, input->stream );
            input->spos  = 0;
        }
        if ( input->sline == Fail || ! IS_STRING(input->sline) ) {
            return 0;
        }
        else {
            ConvString(input->sline);
            /* we now allow that input->sline actually contains several lines,
               e.g., it can be a  string from a string stream  */
            {
                /***  probably this can be a bit more optimized  ***/
                register Char * ptr, * bptr;
                register UInt count, len, max, cbuf;
                /* start position in buffer */
                for(cbuf = 0; buffer[cbuf]; cbuf++);
                /* copy piece of input->sline into buffer and adjust counters */
                for(count = input->spos,
                    ptr = (Char *)CHARS_STRING(input->sline) + count,
                    len = GET_LEN_STRING(input->sline),
                    max = length-2,
                    bptr = buffer + cbuf;
                    cbuf < max && count < len
                                  && *ptr != '\n' && *ptr != '\r';
                    *bptr = *ptr, cbuf++, ptr++, bptr++, count++);
                /* we also copy an end of line if there is one */
                if (*ptr == '\n' || *ptr == '\r') {
                    buffer[cbuf] = *ptr;
                    cbuf++;
                    count++;
                }
                buffer[cbuf] = '\0';
                input->spos = count;
                /* if input->stream is a string stream, we have to adjust the
                   position counter in the stream object as well */
                if (input->isstringstream) {
                    ADDR_OBJ(input->stream)[1] = INTOBJ_INT(count);
                }
            }
        }
    }
    else {
        if ( ! SyFgets( buffer, length, input->file ) ) {
            return 0;
        }
    }
    return 1;
}


/****************************************************************************
**
*F  GetLine() . . . . . . . . . . . . . . . . . . . . . . . get a line, local
**
**  'GetLine'  fetches another  line from  the  input 'Input' into the buffer
**  'Input->line', sets the pointer 'In' to  the beginning of this buffer and
**  returns the first character from the line.
**
**  If   the input file is  '*stdin*'   or '*errin*' 'GetLine'  first  prints
**  'Prompt', unless it is '*stdin*' and GAP was called with option '-q'.
**
**  If there is an  input logfile in use  and the input  file is '*stdin*' or
**  '*errin*' 'GetLine' echoes the new line to the logfile.
*/
extern void PutLine2(
    TypOutputFile *         output,
    const Char *            line,
    UInt                    len   );

Int HELPSubsOn = 1;

Char GetLine ( void )
{
    Char            buf[200];
    Char *          p;
    Char *          q;

    /* if file is '*stdin*' or '*errin*' print the prompt and flush it     */
    /* if the GAP function `PrintPromptHook' is defined then it is called  */
    /* for printing the prompt, see also `EndLineHook'                     */
    if ( ! Input->isstream ) {
       if ( Input->file == 0 ) {
            if ( ! SyQuiet ) {
                if (Output->pos > 0)
                    Pr("\n", 0L, 0L);
                if ( PrintPromptHook )
                     Call0ArgsInNewReader( PrintPromptHook );
                else
                     Pr( "%s%c", (Int)Prompt, (Int)'\03' );
            } else
                Pr( "%c", (Int)'\03', 0L );
        }
        else if ( Input->file == 2 ) {
            if (Output->pos > 0)
                Pr("\n", 0L, 0L);
            if ( PrintPromptHook )
                 Call0ArgsInNewReader( PrintPromptHook );
            else
                 Pr( "%s%c", (Int)Prompt, (Int)'\03' );
        }
    }

    /* bump the line number                                                */
    if ( Input->line < In && (*(In-1) == '\n' || *(In-1) == '\r') ) {
        Input->number++;
    }

    /* initialize 'In', no errors on this line so far                      */
    In = Input->line;  In[0] = '\0';
    NrErrLine = 0;

    /* read a line from an ordinary input file                             */
    if ( TestInput != Input ) {

        /* try to read a line                                              */
        if ( ! GetLine2( Input, Input->line, sizeof(Input->line) ) ) {
            In[0] = '\377';  In[1] = '\0';
        }


        /* convert '?' at the beginning into 'HELP'
           (if not inside reading long string which may have line
           or chunk from GetLine starting with '?')                        */

        if ( In[0] == '?' && HELPSubsOn == 1) {
            strlcpy( buf, In+1, sizeof(buf) );
            strcpy( In, "HELP(\"" );
            for ( p = In+6,  q = buf;  *q;  q++ ) {
                if ( *q != '"' && *q != '\n' ) {
                    *p++ = *q;
                }
                else if ( *q == '"' ) {
                    *p++ = '\\';
                    *p++ = *q;
                }
            }
            *p = '\0';
            /* FIXME: We should do bounds checking, but don't know what 'In' points to */
            strcat( In, "\");\n" );
        }

        /* if necessary echo the line to the logfile                      */
        if( InputLog != 0 && Input->echo == 1)
            if ( !(In[0] == '\377' && In[1] == '\0') )
            PutLine2( InputLog, In, strlen(In) );

                /*      if ( ! Input->isstream ) {
          if ( InputLog != 0 && ! Input->isstream ) {
            if ( Input->file == 0 || Input->file == 2 ) {
              PutLine2( InputLog, In );
            }
            }
            } */

    }

    /* read a line for test input file                                     */
    else {

        /* continue until we got an input line                             */
        while ( In[0] == '\0' ) {

            /* there may be one line waiting                               */
            if ( TestLine[0] != '\0' ) {
                SyStrncat( In, TestLine, sizeof(Input->line) );
                TestLine[0] = '\0';
            }

            /* otherwise try to read a line                                */
            else {
                if ( ! GetLine2(Input, Input->line, sizeof(Input->line)) ) {
                    In[0] = '\377';  In[1] = '\0';
                }
            }

            /* if the line starts with a prompt its an input line          */
            if      ( In[0] == 'g' && In[1] == 'a' && In[2] == 'p'
                   && In[3] == '>' && In[4] == ' ' ) {
                In = In + 5;
            }
            else if ( In[0] == '>' && In[1] == ' ' ) {
                In = In + 2;
            }

            /* if the line is not empty or a comment, print it             */
            else if ( In[0] != '\n' && In[0] != '#' && In[0] != '\377' ) {
                /* Commented out by AK
                char obuf[8];
                snprintf(obuf, sizeof(obuf), "-%5i:\n- ", (int)TestInput->number++);
                PutLine2( TestOutput, obuf, 7 );
                */
                PutLine2( TestOutput, "- ", 2 );
                PutLine2( TestOutput, In, strlen(In) );
                In[0] = '\0';
            }

        }

    }

    /* return the current character                                        */
    return *In;
}


/****************************************************************************
**
*F  GET_CHAR()  . . . . . . . . . . . . . . . . get the next character, local
**
**  'GET_CHAR' returns the next character from  the current input file.  This
**  character is afterwords also available as '*In'.
**
**  For efficiency  reasons 'GET_CHAR' is a  macro that  just  increments the
**  pointer 'In'  and checks that  there is another  character.  If  not, for
**  example at the end a line, 'GET_CHAR' calls 'GetLine' to fetch a new line
**  from the input file.
*/

static Char Pushback = '\0';
static Char *RealIn;

static inline void GET_CHAR( void ) {
  if (In == &Pushback) {
      In = RealIn;
  } else
    In++;
  if (!*In)
    GetLine();
}

static inline void UNGET_CHAR( Char c ) {
  assert(In != &Pushback);
  Pushback = c;
  RealIn = In;
  In = &Pushback;
}


/****************************************************************************
**
*F  GetIdent()  . . . . . . . . . . . . . get an identifier or keyword, local
**
**  'GetIdent' reads   an identifier from  the current  input  file  into the
**  variable 'Value' and sets 'Symbol' to 'S_IDENT'.   The first character of
**  the   identifier  is  the current character  pointed to  by 'In'.  If the
**  characters make  up   a  keyword 'GetIdent'  will  set   'Symbol'  to the
**  corresponding value.  The parser will ignore 'Value' in this case.
**
**  An  identifier consists of a letter  followed by more letters, digits and
**  underscores '_'.  An identifier is terminated by the first  character not
**  in this  class.  The escape sequence '\<newline>'  is ignored,  making it
**  possible to split  long identifiers  over multiple lines.  The  backslash
**  '\' can be used  to include special characters like  '('  in identifiers.
**  For example 'G\(2\,5\)' is an identifier not a call to a function 'G'.
**
**  The size  of 'Value' limits the  number  of significant characters  in an
**  identifier.   If  an  identifier   has more characters    'GetIdent' will
**  silently truncate it.
**
**  After reading the identifier 'GetIdent'  looks at the  first and the last
**  character  of  'Value' to see if  it  could possibly  be  a keyword.  For
**  example 'test'  could  not be  a  keyword  because there  is  no  keyword
**  starting and ending with a 't'.  After that  test either 'GetIdent' knows
**  that 'Value' is not a keyword, or there is a unique possible keyword that
**  could match, because   no two  keywords  have  identical  first and  last
**  characters.  For example if 'Value' starts with 'f' and ends with 'n' the
**  only possible keyword  is 'function'.   Thus in this case  'GetIdent' can
**  decide with one string comparison if 'Value' holds a keyword or not.
*/
extern void GetSymbol ( void );

typedef struct {const Char *name; UInt sym;} s_keyword;

static const s_keyword AllKeywords[] = {
  {"and",       S_AND},
  {"break",     S_BREAK},
  {"continue",  S_CONTINUE},
  {"do",        S_DO},
  {"elif",      S_ELIF},
  {"else",      S_ELSE},
  {"end",       S_END},
  {"false",     S_FALSE},
  {"fi",        S_FI},
  {"for",       S_FOR},
  {"function",  S_FUNCTION},
  {"if",        S_IF},
  {"in",        S_IN},
  {"local",     S_LOCAL},
  {"mod",       S_MOD},
  {"not",       S_NOT},
  {"od",        S_OD},
  {"or",        S_OR},
  {"rec",       S_REC},
  {"repeat",    S_REPEAT},
  {"return",    S_RETURN},
  {"then",      S_THEN},
  {"true",      S_TRUE},
  {"until",     S_UNTIL},
  {"while",     S_WHILE},
  {"quit",      S_QUIT},
  {"QUIT",      S_QQUIT},
  {"IsBound",   S_ISBOUND},
  {"Unbind",    S_UNBIND},
  {"TryNextMethod", S_TRYNEXT},
  {"Info",      S_INFO},
  {"Assert",    S_ASSERT}};


static int IsIdent(char c) {
    return IsAlpha(c) || c == '_' || c == '$' || c == '@';
}

void GetIdent ( void )
{
    Int                 i, fetch;
    Int                 isQuoted;

    /* initially it could be a keyword                                     */
    isQuoted = 0;

    /* read all characters into 'Value'                                    */
    for ( i=0; IsIdent(*In) || IsDigit(*In) || *In=='\\'; i++ ) {

        fetch = 1;
        /* handle escape sequences                                         */
        /* we ignore '\ newline' by decrementing i, except at the
           very start of the identifier, when we cannot do that
           so we recurse instead                                           */
        if ( *In == '\\' ) {
            GET_CHAR();
            if      ( *In == '\n' && i == 0 )  { GetSymbol();  return; }
            else if ( *In == '\r' )  {
                GET_CHAR();
                if  ( *In == '\n' )  {
                     if (i == 0) { GetSymbol();  return; }
                     else i--;
                }
                else  {Value[i] = '\r'; fetch = 0;}
            }
            else if ( *In == '\n' && i < SAFE_VALUE_SIZE-1 )  i--;
            else if ( *In == 'n'  && i < SAFE_VALUE_SIZE-1 )  Value[i] = '\n';
            else if ( *In == 't'  && i < SAFE_VALUE_SIZE-1 )  Value[i] = '\t';
            else if ( *In == 'r'  && i < SAFE_VALUE_SIZE-1 )  Value[i] = '\r';
            else if ( *In == 'b'  && i < SAFE_VALUE_SIZE-1 )  Value[i] = '\b';
            else if ( i < SAFE_VALUE_SIZE-1 )  {
                Value[i] = *In;
                isQuoted = 1;
            }
        }

        /* put normal chars into 'Value' but only if there is room         */
        else {
            if ( i < SAFE_VALUE_SIZE-1 )  Value[i] = *In;
        }

        /* read the next character                                         */
        if (fetch) GET_CHAR();

    }

    /* terminate the identifier and lets assume that it is not a keyword   */
    if ( i < SAFE_VALUE_SIZE-1 )
        Value[i] = '\0';
    else {
        SyntaxError("Identifiers in GAP must consist of less than 1023 characters.");
        i =  SAFE_VALUE_SIZE-1;
        Value[i] = '\0';
    }
    Symbol = S_IDENT;

    /* now check if 'Value' holds a keyword                                */
    switch ( 256*Value[0]+Value[i-1] ) {
    case 256*'a'+'d': if(!strcmp(Value,"and"))     Symbol=S_AND;     break;
    case 256*'b'+'k': if(!strcmp(Value,"break"))   Symbol=S_BREAK;   break;
    case 256*'c'+'e': if(!strcmp(Value,"continue"))   Symbol=S_CONTINUE;   break;
    case 256*'d'+'o': if(!strcmp(Value,"do"))      Symbol=S_DO;      break;
    case 256*'e'+'f': if(!strcmp(Value,"elif"))    Symbol=S_ELIF;    break;
    case 256*'e'+'e': if(!strcmp(Value,"else"))    Symbol=S_ELSE;    break;
    case 256*'e'+'d': if(!strcmp(Value,"end"))     Symbol=S_END;     break;
    case 256*'f'+'e': if(!strcmp(Value,"false"))   Symbol=S_FALSE;   break;
    case 256*'f'+'i': if(!strcmp(Value,"fi"))      Symbol=S_FI;      break;
    case 256*'f'+'r': if(!strcmp(Value,"for"))     Symbol=S_FOR;     break;
    case 256*'f'+'n': if(!strcmp(Value,"function"))Symbol=S_FUNCTION;break;
    case 256*'i'+'f': if(!strcmp(Value,"if"))      Symbol=S_IF;      break;
    case 256*'i'+'n': if(!strcmp(Value,"in"))      Symbol=S_IN;      break;
    case 256*'l'+'l': if(!strcmp(Value,"local"))   Symbol=S_LOCAL;   break;
    case 256*'m'+'d': if(!strcmp(Value,"mod"))     Symbol=S_MOD;     break;
    case 256*'n'+'t': if(!strcmp(Value,"not"))     Symbol=S_NOT;     break;
    case 256*'o'+'d': if(!strcmp(Value,"od"))      Symbol=S_OD;      break;
    case 256*'o'+'r': if(!strcmp(Value,"or"))      Symbol=S_OR;      break;
    case 256*'r'+'c': if(!strcmp(Value,"rec"))     Symbol=S_REC;     break;
    case 256*'r'+'t': if(!strcmp(Value,"repeat"))  Symbol=S_REPEAT;  break;
    case 256*'r'+'n': if(!strcmp(Value,"return"))  Symbol=S_RETURN;  break;
    case 256*'t'+'n': if(!strcmp(Value,"then"))    Symbol=S_THEN;    break;
    case 256*'t'+'e': if(!strcmp(Value,"true"))    Symbol=S_TRUE;    break;
    case 256*'u'+'l': if(!strcmp(Value,"until"))   Symbol=S_UNTIL;   break;
    case 256*'w'+'e': if(!strcmp(Value,"while"))   Symbol=S_WHILE;   break;
    case 256*'q'+'t': if(!strcmp(Value,"quit"))    Symbol=S_QUIT;    break;
    case 256*'Q'+'T': if(!strcmp(Value,"QUIT"))    Symbol=S_QQUIT;   break;

    case 256*'I'+'d': if(!strcmp(Value,"IsBound")) Symbol=S_ISBOUND; break;
    case 256*'U'+'d': if(!strcmp(Value,"Unbind"))  Symbol=S_UNBIND;  break;
    case 256*'T'+'d': if(!strcmp(Value,"TryNextMethod"))
                                                     Symbol=S_TRYNEXT; break;
    case 256*'I'+'o': if(!strcmp(Value,"Info"))    Symbol=S_INFO;    break;
    case 256*'A'+'t': if(!strcmp(Value,"Assert"))  Symbol=S_ASSERT;  break;

    default: ;
    }

    /* if it is quoted it is an identifier                                 */
    if ( isQuoted )  Symbol = S_IDENT;


}


/******************************************************************************
*F  GetNumber()  . . . . . . . . . . . . . .  get an integer or float literal
**
**  'GetNumber' reads  a number from  the  current  input file into the
**  variable  'Value' and sets  'Symbol' to 'S_INT', 'S_PARTIALINT',
**  'S_FLOAT' or 'S_PARTIALFLOAT'.   The first character of
**  the number is the current character pointed to by 'In'.
**
**  If the sequence contains characters which do not match the regular expression
**  [0-9]+.?[0-9]*([edqEDQ][+-]?[0-9]+)? 'GetNumber'  will
**  interpret the sequence as an identifier and set 'Symbol' to 'S_IDENT'.
**
**  As we read, we keep track of whether we have seen a . or exponent notation
**  and so whether we will return S_[PARTIAL]INT or S_[PARTIAL]FLOAT.
**
**  When Value is  completely filled we have to check  if the reading of
**  the number  is complete  or not to  decide whether to return a PARTIAL type.
**
**  The argument reflects how far we are through reading a possibly very long number
**  literal. 0 indicates that nothing has been read. 1 that at least one digit has been
**  read, but no decimal point. 2 that a decimal point has been read with no digits before
**  or after it. 3 a decimal point and at least one digit, but no exponential indicator
**  4 an exponential indicator  but no exponent digits and 5 an exponential indicator and
**  at least one exponent digit.
**
*/
static Char GetCleanedChar( UInt *wasEscaped ) {
  GET_CHAR();
  *wasEscaped = 0;
  if (*In == '\\') {
    GET_CHAR();
    if      ( *In == '\n')
      return GetCleanedChar(wasEscaped);
    else if ( *In == '\r' )  {
      GET_CHAR();
      if  ( *In == '\n' )
        return GetCleanedChar(wasEscaped);
      else {
        UNGET_CHAR(*In);
        *wasEscaped = 1;
        return '\r';
      }
    }
    else {
      *wasEscaped = 1;
      if ( *In == 'n')  return '\n';
      else if ( *In == 't')  return '\t';
      else if ( *In == 'r')  return '\r';
      else if ( *In == 'b')  return '\b';
      else if ( *In == '>')  return '\01';
      else if ( *In == '<')  return '\02';
      else if ( *In == 'c')  return '\03';
    }
  }
  return *In;
}


void GetNumber ( UInt StartingStatus )
{
  Int                 i=0;
  Char                c;
  UInt seenExp = 0;
  UInt wasEscaped = 0;
  UInt seenADigit = (StartingStatus != 0 && StartingStatus != 2);
  UInt seenExpDigit = (StartingStatus ==5);

  c = *In;
  if (StartingStatus  <  2) {
    /* read initial sequence of digits into 'Value'             */
    for (i = 0; !wasEscaped && IsDigit(c) && i < SAFE_VALUE_SIZE-1; i++) {
      Value[i] = c;
      seenADigit = 1;
      c = GetCleanedChar(&wasEscaped);
    }

    /* So why did we run off the end of that loop */
    /* maybe we saw an identifier character and realised that this is an identifier we are reading */
    if (wasEscaped || IsIdent(c)) {
      /* Now we know we have an identifier read the rest of it */
      Value[i++] = c;
      c = GetCleanedChar(&wasEscaped);
      for (; wasEscaped || IsIdent(c) || IsDigit(c); i++) {
        if (i < SAFE_VALUE_SIZE -1)
          Value[i] = c;
        c = GetCleanedChar(&wasEscaped);
      }
      if (i < SAFE_VALUE_SIZE -1)
        Value[i] = '\0';
      else
        Value[SAFE_VALUE_SIZE-1] = '\0';
      Symbol = S_IDENT;
      return;
    }

    /* Or maybe we just ran out of space */
    if (IsDigit(c)) {
      assert(i >= SAFE_VALUE_SIZE-1);
      Symbol = S_PARTIALINT;
      Value[SAFE_VALUE_SIZE-1] = '\0';
      return;
    }

    /* Or maybe we saw a . which could indicate one of two things:
       a float literal or .. */
    if (c == '.'){
      /* peek ahead to decide which */
      GET_CHAR();
      if (*In == '.') {
        /* It was .. */
        UNGET_CHAR(*In);
        Symbol = S_INT;
        Value[i] = '\0';
        return;
      }


      /* Not .. Put back the character we peeked at */
      UNGET_CHAR(*In);
      /* Now the . must be part of our number
         store it and move on */
      Value[i++] = c;
      c = GetCleanedChar(&wasEscaped);
    }

    else {
      /* Anything else we see tells us that the token is done */
      Value[i]  = '\0';
      Symbol = S_INT;
      return;
    }
  }



  /* The only case in which we fall through to here is when
     we have read zero or more digits, followed by . which is not part of a .. token
     or we were called with StartingStatus >= 2 so we read at least that much in
     a previous token */


  if (StartingStatus< 4) {
    /* When we get here we have read (either in this token or a previous S_PARTIALFLOAT*)
       possibly some digits, a . and possibly some more digits, but not an e,E,d,D,q or Q */

    /* read digits */
    for (; !wasEscaped && IsDigit(c) && i < SAFE_VALUE_SIZE-1; i++) {
      Value[i] = c;
      seenADigit = 1;
      c = GetCleanedChar(&wasEscaped);
    }
    /* If we found an identifier type character in this context could be an error
      or the start of one of the allowed trailing marker sequences */
    if (wasEscaped || (IsIdent(c)  && c != 'e' && c != 'E' && c != 'D' && c != 'q' &&
                       c != 'd' && c != 'Q')) {

      /* We allow one letter on the end of the numbers -- could be an i,
       C99 style */
      if (!wasEscaped) {
        if (IsAlpha(c)) {
          Value[i++] = c;
          c = GetCleanedChar(&wasEscaped);
        }
        /* independently of that, we allow an _ signalling immediate conversion */
        if (c == '_') {
          Value[i++] = c;
          c = GetCleanedChar(&wasEscaped);
          /* After which there may be one character signifying the conversion style */
          if (IsAlpha(c)) {
            Value[i++] = c;
            c = GetCleanedChar(&wasEscaped);
          }
        }
        /* Now if the next character is alphanumerical, or an identifier type symbol then we
           really do have an error, otherwise we return a result */
        if (!IsIdent(c) && !IsDigit(c)) {
          Value[i] = '\0';
          Symbol = S_FLOAT;
          return;
        }
      }
      SyntaxError("Badly formed number");
    }
    /* If the next thing is the start of the exponential notation,
       read it now -- we have left enough space at the end of the buffer even if we
       left the previous loop because of overflow */
    if (IsAlpha(c)) {
        if (!seenADigit)
          SyntaxError("Badly formed number, need a digit before or after the decimal point");
        seenExp = 1;
        Value[i++] = c;
        c = GetCleanedChar(&wasEscaped);
        if (!wasEscaped && (c == '+' || c == '-'))
          {
            Value[i++] = c;
            c = GetCleanedChar(&wasEscaped);
          }
      }

    /* Now deal with full buffer case */
    if (i >= SAFE_VALUE_SIZE -1) {
      Symbol = seenExp ? S_PARTIALFLOAT3 : S_PARTIALFLOAT2;
      Value[i] = '\0';
      return;
    }

    /* Either we saw an exponent indicator, or we hit end of token
       deal with the end of token case */
    if (!seenExp) {
      if (!seenADigit)
        SyntaxError("Badly formed number, need a digit before or after the decimal point");
      /* Might be a conversion marker */
      if (!wasEscaped) {
        if (IsAlpha(c) && c != 'e' && c != 'E' && c != 'd' && c != 'D' && c != 'q' && c != 'Q') {
          Value[i++] = c;
          c = GetCleanedChar(&wasEscaped);
        }
        /* independently of that, we allow an _ signalling immediate conversion */
        if (c == '_') {
          Value[i++] = c;
          c = GetCleanedChar(&wasEscaped);
          /* After which there may be one character signifying the conversion style */
          if (IsAlpha(c))
            Value[i++] = c;
          c = GetCleanedChar(&wasEscaped);
        }
        /* Now if the next character is alphanumerical, or an identifier type symbol then we
           really do have an error, otherwise we return a result */
        if (!IsIdent(c) && !IsDigit(c)) {
          Value[i] = '\0';
          Symbol = S_FLOAT;
          return;
        }
      }
      SyntaxError("Badly Formed Number");
    }

  }

  /* Here we are into the unsigned exponent of a number
     in scientific notation, so we just read digits */
  for (; !wasEscaped && IsDigit(c) && i < SAFE_VALUE_SIZE-1; i++) {
    Value[i] = c;
    seenExpDigit = 1;
    c = GetCleanedChar(&wasEscaped);
  }

  /* Look out for a single alphabetic character on the end
     which could be a conversion marker */
  if (seenExpDigit) {
    if (IsAlpha(c)) {
      Value[i] = c;
      c = GetCleanedChar(&wasEscaped);
      Value[i+1] = '\0';
      Symbol = S_FLOAT;
      return;
    }
    if (c == '_') {
      Value[i++] = c;
      c = GetCleanedChar(&wasEscaped);
      /* After which there may be one character signifying the conversion style */
      if (IsAlpha(c)) {
        Value[i++] = c;
        c = GetCleanedChar(&wasEscaped);
      }
      Value[i] = '\0';
      Symbol = S_FLOAT;
      return;
    }
  }

  /* If we ran off the end */
  if (i >= SAFE_VALUE_SIZE -1) {
    Symbol = seenExpDigit ? S_PARTIALFLOAT4 : S_PARTIALFLOAT3;
    Value[i] = '\0';
    return;
  }

  /* Otherwise this is the end of the token */
  if (!seenExpDigit)
    SyntaxError("Badly Formed Number, need at least one digit in the exponent");
  Symbol = S_FLOAT;
  Value[i] = '\0';
  return;
}




/****************************************************************************
 **
 *F  GetStr()  . . . . . . . . . . . . . . . . . . . . . . get a string, local
 **
 **  'GetStr' reads  a  string from the  current input file into  the variable
 **  'Value' and sets 'Symbol'   to  'S_STRING'.  The opening double quote '"'
 **  of the string is the current character pointed to by 'In'.
 **
 **  A string is a sequence of characters delimited  by double quotes '"'.  It
 **  must not include  '"' or <newline>  characters, but the  escape sequences
 **  '\"' or '\n' can  be used instead.  The  escape sequence  '\<newline>' is
 **  ignored, making it possible to split long strings over multiple lines.
 **
 **  An error is raised if the string includes a <newline> character or if the
 **  file ends before the closing '"'.
 **
 **  When Value is  completely filled we have to check  if the reading of
 **  the string is  complete or not to decide  between Symbol=S_STRING or
 **  S_PARTIALSTRING.
 */
void GetStr ( void )
{
  Int                 i = 0, fetch;
  Char                a, b, c;

  /* Avoid substitution of '?' in beginning of GetLine chunks */
  HELPSubsOn = 0;

  /* read all characters into 'Value'                                    */
  for ( i = 0; i < SAFE_VALUE_SIZE-1 && *In != '"'
           && *In != '\n' && *In != '\377'; i++ ) {

    fetch = 1;
    /* handle escape sequences                                         */
    if ( *In == '\\' ) {
      GET_CHAR();
      /* if next is another '\\' followed by '\n' it must be ignored */
      while ( *In == '\\' ) {
        GET_CHAR();
        if ( *In == '\n' )
          GET_CHAR();
        else {
          UNGET_CHAR( '\\' );
          break;
        }
      }
      if      ( *In == '\n' )  i--;
      else if ( *In == '\r' )  {
        GET_CHAR();
        if  ( *In == '\n' )  i--;
        else  {Value[i] = '\r'; fetch = 0;}
      }
      else if ( *In == 'n'  )  Value[i] = '\n';
      else if ( *In == 't'  )  Value[i] = '\t';
      else if ( *In == 'r'  )  Value[i] = '\r';
      else if ( *In == 'b'  )  Value[i] = '\b';
      else if ( *In == '>'  )  Value[i] = '\01';
      else if ( *In == '<'  )  Value[i] = '\02';
      else if ( *In == 'c'  )  Value[i] = '\03';
      else if ( IsDigit( *In ) ) {
        a = *In; GET_CHAR(); b = *In; GET_CHAR(); c = *In;
        if (!( IsDigit(b) && IsDigit(c) )){
          SyntaxError("expecting three octal digits after \\ in string");
        }
        Value[i] = (a-'0') * 64 + (b-'0') * 8 + c-'0';
      }
      else  Value[i] = *In;
    }

    /* put normal chars into 'Value' but only if there is room         */
    else {
      Value[i] = *In;
    }

    /* read the next character                                         */
    if (fetch) GET_CHAR();

  }

  /* XXX although we have ValueLen we need trailing \000 here,
     in gap.c, function FuncMAKE_INIT this is still used as C-string
     and long integers and strings are not yet supported!    */
  Value[i] = '\0';

  /* check for error conditions                                          */
  if ( *In == '\n'  )
    SyntaxError("string must not include <newline>");
  if ( *In == '\377' )
    SyntaxError("string must end with \" before end of file");

  /* set length of string, set 'Symbol' and skip trailing '"'            */
  ValueLen = i;
  if ( i < SAFE_VALUE_SIZE-1 )  {
    Symbol = S_STRING;
    if ( *In == '"' )  GET_CHAR();
  }
  else
    Symbol = S_PARTIALSTRING;

  /* switching on substitution of '?' */
  HELPSubsOn = 1;
}


/****************************************************************************
 **
 *F  GetChar() . . . . . . . . . . . . . . . . . get a single character, local
 **
 **  'GetChar' reads the next  character from the current input file  into the
 **  variable 'Value' and sets 'Symbol' to 'S_CHAR'.  The opening single quote
 **  '\'' of the character is the current character pointed to by 'In'.
 **
 **  A  character is  a  single character delimited by single quotes '\''.  It
 **  must not  be '\'' or <newline>, but  the escape  sequences '\\\'' or '\n'
 **  can be used instead.
 */
void GetChar ( void )
{
  Char c;

  /* skip '\''                                                           */
  GET_CHAR();

  /* handle escape equences                                              */
  if ( *In == '\\' ) {
    GET_CHAR();
    if ( *In == 'n'  )       Value[0] = '\n';
    else if ( *In == 't'  )  Value[0] = '\t';
    else if ( *In == 'r'  )  Value[0] = '\r';
    else if ( *In == 'b'  )  Value[0] = '\b';
    else if ( *In == '>'  )  Value[0] = '\01';
    else if ( *In == '<'  )  Value[0] = '\02';
    else if ( *In == 'c'  )  Value[0] = '\03';
    else if ( *In >= '0' && *In <= '7' ) {
      /* escaped three digit octal numbers are allowed in input */
      c = 64 * (*In - '0');
      GET_CHAR();
      if ( *In < '0' || *In > '7' )
        SyntaxError("expecting octal digit in character constant");
      c = c + 8 * (*In - '0');
      GET_CHAR();
      if ( *In < '0' || *In > '7' )
        SyntaxError("expecting 3 octal digits in character constant");
      c = c + (*In - '0');
      Value[0] = c;
    }
    else                     Value[0] = *In;
  }

  /* put normal chars into 'Value'                                       */
  else {
    Value[0] = *In;
  }

  /* read the next character                                             */
  GET_CHAR();

  /* check for terminating single quote                                  */
  if ( *In != '\'' )
    SyntaxError("missing single quote in character constant");

  /* skip the closing quote                                              */
  Symbol = S_CHAR;
  if ( *In == '\'' )  GET_CHAR();

}


/****************************************************************************
 **
 *F  GetSymbol() . . . . . . . . . . . . . . . . .  get the next symbol, local
 **
 **  'GetSymbol' reads  the  next symbol from   the  input,  storing it in the
 **  variable 'Symbol'.  If 'Symbol' is  'S_IDENT', 'S_INT' or 'S_STRING'  the
 **  value of the symbol is stored in the variable 'Value'.  'GetSymbol' first
 **  skips all <space>, <tab> and <newline> characters and comments.
 **
 **  After reading  a  symbol the current  character   is the first  character
 **  beyond that symbol.
 */
Int DualSemicolon = 0;

void GetSymbol ( void )
{
  /* special case if reading of a long token is not finished */
  if (Symbol == S_PARTIALSTRING) {
    GetStr();
    return;
  }
  if (Symbol == S_PARTIALINT) {
    if (Value[0] == '\0')
      GetNumber(0);
    else
      GetNumber(1);
    return;
  }
  if (Symbol == S_PARTIALFLOAT1) {
    GetNumber(2);
    return;
  }

  if (Symbol == S_PARTIALFLOAT2) {
    GetNumber(3);
    return;
  }
  if (Symbol == S_PARTIALFLOAT3) {
    GetNumber(4);
    return;
  }

  if (Symbol == S_PARTIALFLOAT4) {
    GetNumber(5);
    return;
  }


  /* if no character is available then get one                           */
  if ( *In == '\0' )
    { In--;
      GET_CHAR();
    }

  /* skip over <spaces>, <tabs>, <newlines> and comments                 */
  while (*In==' '||*In=='\t'||*In=='\n'||*In=='\r'||*In=='\f'||*In=='#') {
    if ( *In == '#' ) {
      while ( *In != '\n' && *In != '\r' && *In != '\377' )
        GET_CHAR();
    }
    GET_CHAR();
  }

  /* switch according to the character                                   */
  switch ( *In ) {

  case '.':   Symbol = S_DOT;                         GET_CHAR();
    /*            if ( *In == '\\' ) { GET_CHAR();
            if ( *In == '\n' ) { GET_CHAR(); } }   */
    if ( *In == '.' ) { Symbol = S_DOTDOT;  GET_CHAR();  break; }
    break;

  case '!':   Symbol = S_ILLEGAL;                     GET_CHAR();
    if ( *In == '\\' ) { GET_CHAR();
      if ( *In == '\n' ) { GET_CHAR(); } }
    if ( *In == '.' ) { Symbol = S_BDOT;    GET_CHAR();  break; }
    if ( *In == '[' ) { Symbol = S_BLBRACK; GET_CHAR();  break; }
    if ( *In == '{' ) { Symbol = S_BLBRACE; GET_CHAR();  break; }
    break;
  case '[':   Symbol = S_LBRACK;                      GET_CHAR();  break;
  case ']':   Symbol = S_RBRACK;                      GET_CHAR();  break;
  case '{':   Symbol = S_LBRACE;                      GET_CHAR();  break;
  case '}':   Symbol = S_RBRACE;                      GET_CHAR();  break;
  case '(':   Symbol = S_LPAREN;                      GET_CHAR();  break;
  case ')':   Symbol = S_RPAREN;                      GET_CHAR();  break;
  case ',':   Symbol = S_COMMA;                       GET_CHAR();  break;

  case ':':   Symbol = S_COLON;                       GET_CHAR();
    if ( *In == '\\' ) {
      GET_CHAR();
      if ( *In == '\n' )
        { GET_CHAR(); }
    }
    if ( *In == '=' ) { Symbol = S_ASSIGN;  GET_CHAR(); break; }
    break;

  case ';':   Symbol = S_SEMICOLON;                   GET_CHAR();  break;

  case '=':   Symbol = S_EQ;                          GET_CHAR();  break;
  case '<':   Symbol = S_LT;                          GET_CHAR();
    if ( *In == '\\' ) { GET_CHAR();
      if ( *In == '\n' ) { GET_CHAR(); } }
    if ( *In == '=' ) { Symbol = S_LE;      GET_CHAR();  break; }
    if ( *In == '>' ) { Symbol = S_NE;      GET_CHAR();  break; }
    break;
  case '>':   Symbol = S_GT;                          GET_CHAR();
    if ( *In == '\\' ) { GET_CHAR();
      if ( *In == '\n' ) { GET_CHAR(); } }
    if ( *In == '=' ) { Symbol = S_GE;      GET_CHAR();  break; }
    break;

  case '+':   Symbol = S_PLUS;                        GET_CHAR();  break;
  case '-':   Symbol = S_MINUS;                       GET_CHAR();
    if ( *In == '\\' ) { GET_CHAR();
      if ( *In == '\n' ) { GET_CHAR(); } }
    if ( *In == '>' ) { Symbol=S_MAPTO;     GET_CHAR();  break; }
    break;
  case '*':   Symbol = S_MULT;                        GET_CHAR();  break;
  case '/':   Symbol = S_DIV;                         GET_CHAR();  break;
  case '^':   Symbol = S_POW;                         GET_CHAR();  break;

  case '"':                               GET_CHAR(); GetStr();    break;
  case '\'':                                          GetChar();   break;
  case '\\':                                          GetIdent();  break;
  case '_':                                           GetIdent();  break;
  case '$':                                           GetIdent();  break;
  case '@':                                           GetIdent();  break;
  case '~':   Value[0] = '~';  Value[1] = '\0';
    Symbol = S_IDENT;                       GET_CHAR();  break;

  case '0': case '1': case '2': case '3': case '4':
  case '5': case '6': case '7': case '8': case '9':
    GetNumber(0);    break;

  case '\377': Symbol = S_EOF;                        *In = '\0';  break;

  default :   if ( IsAlpha(*In) )                   { GetIdent();  break; }
    Symbol = S_ILLEGAL;                     GET_CHAR();  break;
  }
}


/****************************************************************************
 **

 *F * * * * * * * * * * * * *  output functions  * * * * * * * * * * * * * * *
 */


/****************************************************************************
 **

 *V  WriteAllFunc  . . . . . . . . . . . . . . . . . . . . . . . .  'WriteAll'
 */
Obj WriteAllFunc;


/****************************************************************************
 **
 *F  PutLine2( <output>, <line>, <len> )  . . . . . . . . . print a line, local
 **
 **  Introduced  <len> argument. Actually in all cases where this is called one
 **  knows the length of <line>, so it is not necessary to compute it again
 **  with the inefficient C- strlen.  (FL)
 */


void PutLine2(
        TypOutputFile *         output,
        const Char *            line,
        UInt                    len )
{
  Obj                     str;
  UInt                    lstr;
  if ( output->isstream ) {
    /* special handling of string streams, where we can copy directly */
    if (output->isstringstream) {
      str = ADDR_OBJ(output->stream)[1];
      lstr = GET_LEN_STRING(str);
      GROW_STRING(str, lstr+len);
      memcpy((void *) (CHARS_STRING(str) + lstr), line, len);
      SET_LEN_STRING(str, lstr + len);
      *(CHARS_STRING(str) + lstr + len) = '\0';
      CHANGED_BAG(str);
      return;
    }

    /* Space for the null is allowed for in GAP strings */
    str = NEW_STRING( len );

    /* But we have to allow for it in SyStrncat */
    /*    XXX SyStrncat( CSTR_STRING(str), line, len + 1 );    */
    /* this contains trailing zero character */
    memcpy(CHARS_STRING(str),  line, len + 1 );

    /* now delegate to library level */
    CALL_2ARGS( WriteAllFunc, output->stream, str );
  }
  else {
    SyFputs( line, output->file );
  }
}


/****************************************************************************
 **
 *F  PutLineTo ( stream, len ) . . . . . . . . . . . . . . print a line, local
 **
 **  'PutLineTo'  prints the first len characters of the current output
 **  line   'stream->line' to <stream>
 **  It  is  called from 'PutChrTo'.
 **
 **  'PutLineTo' also compares the output line with the  next line from the test
 **  input file 'TestInput' if 'TestInput' is not 0.  If  this input line does
 **  not starts with 'gap>' and the rest  of the line  matches the output line
 **  then the output line is not printed and the input line is discarded.
 **
 **  'PutLineTo'  also echoes the  output  line  to the  logfile 'OutputLog' if
 **  'OutputLog' is not 0 and the output file is '*stdout*' or '*errout*'.
 **
 **  Finally 'PutLineTo' checks whether the user has hit '<ctr>-C' to  interrupt
 **  the printing.
 */
void PutLineTo ( KOutputStream stream, UInt len )
{
  Char *          p;
  UInt lt,ls;     /* These are supposed to hold string lengths */

  /* if in test mode and the next input line matches print nothing       */
  if ( TestInput != 0 && TestOutput == stream ) {
    if ( TestLine[0] == '\0' ) {
      if ( ! GetLine2( TestInput, TestLine, sizeof(TestLine) ) ) {
        TestLine[0] = '\0';
      }
      TestInput->number++;
    }

    /* Note that TestLine is ended by a \n, but stream->line need not! */

    lt = strlen(TestLine);   /* this counts including the newline! */
    p = TestLine + (lt-2);
    /* this now points to the last char before \n in the line! */
    while ( TestLine <= p && ( *p == ' ' || *p == '\t' ) ) {
      p[1] = '\0';  p[0] = '\n';  p--; lt--;
    }
    /* lt is still the correct string length including \n */
    ls = strlen(stream->line);
    p = stream->line + (ls-1);
    /* this now points to the last char of the string, could be a \n */
    if (*p == '\n') {
      p--;   /* now we point before that newline character */
      while ( stream->line <= p && ( *p == ' ' || *p == '\t' ) ) {
        p[1] = '\0';  p[0] = '\n';  p--; ls--;
      }
    }
    /* ls is still the correct string length including a possible \n */
    if ( ! strncmp( TestLine, stream->line, ls ) ) {
      if (ls < lt)
        memmove(TestLine,TestLine + ls,lt-ls+1);
      else
        TestLine[0] = '\0';
    }
    else {
      char obuf[80];
      /* snprintf(obuf, sizeof(obuf), "+ 5%i bad example:\n+ ", (int)TestInput->number); */
      snprintf(obuf, sizeof(obuf), "Line %i : \n+ ", (int)TestInput->number);
      PutLine2( stream, obuf, strlen(obuf) );
      PutLine2( stream, Output->line, strlen(Output->line) );
    }
  }

  /* otherwise output this line                                          */
  else {
    PutLine2( stream, stream->line, len );
  }

  /* if neccessary echo it to the logfile                                */
  if ( OutputLog != 0 && ! stream->isstream ) {
    if ( stream->file == 1 || stream->file == 3 ) {
      PutLine2( OutputLog, stream->line, len );
    }
  }
}


/****************************************************************************
 **
 *F  PutChrTo( <stream>, <ch> )  . . . . . . . . . print character <ch>, local
 **
 **  'PutChrTo' prints the single character <ch> to the stream <stream>
 **
 **  'PutChrTo' buffers the  output characters until  either <ch> is  <newline>,
 **  <ch> is '\03' (<flush>) or the buffer fills up.
 **
 **  In the later case 'PutChrTo' has to decide where to  split the output line.
 **  It takes the point at which $linelength - pos + 8 * indent$ is minimal.
 */
Int NoSplitLine = 0;

/* helper function to add a hint about a possible line break;
   a triple (pos, value, indent), such that the minimal (value-pos) wins */
void addLineBreakHint( KOutputStream stream, Int pos, Int val, Int indentdiff )
{
  Int nr, i;
  /* find next free slot */
  for (nr = 0; nr < MAXHINTS && stream->hints[3*nr] != -1; nr++);
  if (nr == MAXHINTS) {
    /* forget the first stored hint */
    for (i = 0; i < 3*MAXHINTS - 3; i++)
       stream->hints[i] =  stream->hints[i+3];
    nr--;
  }
  /* if pos is same as before only relevant if new entry has higher
     priority */
  if ( nr > 0 && stream->hints[3*(nr-1)] == pos )
    nr--;

  if ( stream->indent < pos &&
       (stream->hints[3*nr] == -1 || val < stream->hints[3*(nr)+1]) ) {
    stream->hints[3*nr] = pos;
    stream->hints[3*nr+1] = val;
    stream->hints[3*nr+2] = stream->indent;
    stream->hints[3*nr+3] = -1;
  }
  stream->indent += indentdiff;
}
/* helper function to find line break position,
   returns position nr in stream[hints] or -1 if none found */
Int nrLineBreak( KOutputStream stream )
{
  Int nr=-1, min, i;
  for (i = 0, min = INT_MAX; stream->hints[3*i] != -1; i++)
  {
    if (stream->hints[3*i] > 0 &&
        stream->hints[3*i+1] - stream->hints[3*i] <= min)
    {
      nr = i;
      min = stream->hints[3*i+1] - stream->hints[3*i];
    }
  }
  if (min < INT_MAX)
    return nr;
  else
    return -1;
}



void PutChrTo (
         KOutputStream stream,
         Char                ch )
{
  Int                 i, hint, spos;
  Char                str [MAXLENOUTPUTLINE];



  /* '\01', increment indentation level                                  */
  if ( ch == '\01' ) {

    if (!stream->format)
      return;

    /* add hint to break line  */
    addLineBreakHint(stream, stream->pos, 16*stream->indent, 1);
  }

  /* '\02', decrement indentation level                                  */
  else if ( ch == '\02' ) {

    if (!stream -> format)
      return;

    /* if this is a better place to split the line remember it         */
    addLineBreakHint(stream, stream->pos, 16*stream->indent, -1);
  }

  /* '\03', print line                                                   */
  else if ( ch == '\03' ) {

    /* print the line                                                  */
    if (stream->pos != 0)
      {
        stream->line[ stream->pos ] = '\0';
        PutLineTo(stream, stream->pos );

        /* start the next line                                         */
        stream->pos      = 0;
      }
    /* reset line break hints                                          */
    stream->hints[0] = -1;

  }

  /* <newline> or <return>, print line, indent next                      */
  else if ( ch == '\n' || ch == '\r' ) {

    /* put the character on the line and terminate it                  */
    stream->line[ stream->pos++ ] = ch;
    stream->line[ stream->pos   ] = '\0';

    /* print the line                                                  */
    PutLineTo( stream, stream->pos );

    /* and dump it from the buffer */
    stream->pos = 0;
    if (stream -> format)
      {
        /* indent for next line                                         */
        for ( i = 0;  i < stream->indent; i++ )
          stream->line[ stream->pos++ ] = ' ';
      }
    /* reset line break hints                                       */
    stream->hints[0] = -1;

  }

  /* normal character, room on the current line                          */
  else if ( stream->pos < SyNrCols-2-NoSplitLine ) {

    /* put the character on this line                                  */
    stream->line[ stream->pos++ ] = ch;

  }

  else
    {
      /* position to split                                              */
      if ( (hint = nrLineBreak(stream)) != -1 )
        spos = stream->hints[3*hint];
      else
        spos = 0;

      /* if we are going to split at the end of the line, and we are
         formatting discard blanks */
      if ( stream->format && spos == stream->pos && ch == ' ' ) {
        ;
      }

      /* full line, acceptable split position                              */
      else if ( stream->format && spos != 0 ) {

        /* add character to the line, terminate it                         */
        stream->line[ stream->pos++ ] = ch;
        stream->line[ stream->pos++ ] = '\0';

        /* copy the rest after the best split position to a safe place     */
        for ( i = spos; i < stream->pos; i++ )
          str[ i-spos ] = stream->line[ i ];
        str[ i-spos] = '\0';

        /* print line up to the best split position                        */
        stream->line[ spos++ ] = '\n';
        stream->line[ spos   ] = '\0';
        PutLineTo( stream, spos );
        spos--;

        /* indent for the rest                                             */
        stream->pos = 0;
        for ( i = 0; i < stream->hints[3*hint+2]; i++ )
          stream->line[ stream->pos++ ] = ' ';
        spos -= stream->hints[3*hint+2];

        /* copy the rest onto the next line                                */
        for ( i = 0; str[ i ] != '\0'; i++ )
          stream->line[ stream->pos++ ] = str[ i ];
        /* recover line break hints for copied rest                      */
        for ( i = hint+1; stream->hints[3*i] != -1; i++ )
        {
          stream->hints[3*(i-hint-1)] = stream->hints[3*i]-spos;
          stream->hints[3*(i-hint-1)+1] = stream->hints[3*i+1];
          stream->hints[3*(i-hint-1)+2] = stream->hints[3*i+2];
        }
        stream->hints[3*(i-hint-1)] = -1;
      }

      /* full line, no split position                                       */
      else {

        if (stream->format)
          {
            /* append a '\',*/
            stream->line[ stream->pos++ ] = '\\';
            stream->line[ stream->pos++ ] = '\n';
          }
        /* and print the line                                */
        stream->line[ stream->pos   ] = '\0';
        PutLineTo( stream, stream->pos );

        /* add the character to the next line                              */
        stream->pos = 0;
        stream->line[ stream->pos++ ] = ch;

        if (stream->format)
          stream->hints[0] = -1;
      }

    }
}

/****************************************************************************
 **
 *F  FuncToggleEcho( )
 **
*/

Obj FuncToggleEcho( Obj self)
{
  Input->echo = 1 - Input->echo;
  return (Obj)0;
}

/****************************************************************************
 **
 *F  FuncCPROMPT( )
 **
 **  returns the current `Prompt' as GAP string.
 */
Obj FuncCPROMPT( Obj self)
{
  Obj p;
  C_NEW_STRING( p, strlen( Prompt ), Prompt );
  return p;
}

/****************************************************************************
 **
 *F  FuncPRINT_CPROMPT( <prompt> )
 **
 **  prints current `Prompt' if argument <prompt> is not in StringRep, otherwise
 **  uses the content of <prompt> as `Prompt' (at most 80 characters).
 **  (important is the flush character without resetting the cursor column)
 */
Char promptBuf[81];
Obj FuncPRINT_CPROMPT( Obj self, Obj prompt )
{
  if (IS_STRING_REP(prompt)) {
    /* by assigning to Prompt we also tell readline (if used) what the
       current prompt is  */
    strlcpy(promptBuf, CSTR_STRING(prompt), sizeof(promptBuf));
    Prompt = promptBuf;
  }
  Pr("%s%c", (Int)Prompt, (Int)'\03' );
  return (Obj) 0;
}

/****************************************************************************
 **
 *F  Pr( <format>, <arg1>, <arg2> )  . . . . . . . . .  print formatted output
 *F  PrTo( <stream>, <format>, <arg1>, <arg2> )  . . .  print formatted output
 **
 **  'Pr' is the output function. The first argument is a 'printf' like format
 **  string containing   up   to 2  '%'  format   fields,   specifing  how the
 **  corresponding arguments are to be  printed.  The two arguments are passed
 **  as  'Int'   integers.   This  is possible  since every  C object  ('int',
 **  'char', pointers) except 'float' or 'double', which are not used  in GAP,
 **  can be converted to a 'Int' without loss of information.
 **
 **  The function 'Pr' currently support the following '%' format  fields:
 **  '%c'    the corresponding argument represents a character,  usually it is
 **          its ASCII or EBCDIC code, and this character is printed.
 **  '%s'    the corresponding argument is the address of  a  null  terminated
 **          character string which is printed.
 **  '%S'    the corresponding argument is the address of  a  null  terminated
 **          character string which is printed with escapes.
 **  '%C'    the corresponding argument is the address of  a  null  terminated
 **          character string which is printed with C escapes.
 **  '%d'    the corresponding argument is a signed integer, which is printed.
 **          Between the '%' and the 'd' an integer might be used  to  specify
 **          the width of a field in which the integer is right justified.  If
 **          the first character is '0' 'Pr' pads with '0' instead of <space>.
 **  '%i'    is a synonym of %d, in line with recent C library developements
 **  '%I'    print an identifier
 **  '%>'    increment the indentation level.
 **  '%<'    decrement the indentation level.
 **  '%%'    can be used to print a single '%' character. No argument is used.
 **
 **  You must always  cast the arguments to  '(Int)'  to avoid  problems  with
 **  those compilers with a default integer size of 16 instead of 32 bit.  You
 **  must pass 0L if you don't make use of an argument to please lint.
 */

void FormatOutput(void (*put_a_char)(Char c), const Char *format, Int arg1, Int arg2 ) {
  const Char *        p;
  Char *              q;
  Int                 prec,  n;
  Char                fill;

  /* loop over the characters of the <format> string                     */
  for ( p = format; *p != '\0'; p++ ) {

    /* not a '%' character, simply print it                            */
    if ( *p != '%' ) {
      put_a_char( *p );
      continue;
    }

    /* if the character is '%' do something special                    */

    /* first look for a precision field                            */
    p++;
    prec = 0;
    fill = (*p == '0' ? '0' : ' ');
    while ( IsDigit(*p) ) {
      prec = 10 * prec + *p - '0';
      p++;
    }

    /* handle the case of a missing argument                     */
    if (arg1 == 0 && (*p == 's' || *p == 'S' || *p == 'C' || *p == 'I')) {
      put_a_char('<');
      put_a_char('n');
      put_a_char('u');
      put_a_char('l');
      put_a_char('l');
      put_a_char('>');

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%d' print an integer                                       */
    else if ( *p == 'd'|| *p == 'i' ) {
      int is_neg = (arg1 < 0);
      if ( is_neg ) {
        arg1 = -arg1;
        prec--; /* we loose one digit of output precision for the minus sign */
      }

      /* compute how many characters this number requires    */
      for ( n = 1; n <= arg1/10; n*=10 ) {
        prec--;
      }
      while ( --prec > 0 )  put_a_char(fill);

      if ( is_neg ) {
        put_a_char('-');
      }

      for ( ; n > 0; n /= 10 )
        put_a_char( (Char)(((arg1/n)%10) + '0') );

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%s' print a string                                         */
    else if ( *p == 's' ) {

      /* compute how many characters this identifier requires    */
      for ( q = (Char*)arg1; *q != '\0' && prec > 0; q++ ) {
        prec--;
      }

      /* if wanted push an appropriate number of <space>-s       */
      while ( prec-- > 0 )  put_a_char(' ');

      /* print the string                                        */
      /* must be careful that line breaks don't go inside
         escaped sequences \n or \123 or similar */
      for ( q = (Char*)arg1; *q != '\0'; q++ ) {
        if (*q == '\\' && NoSplitLine == 0) {
          if (*(q+1) < '8' && *(q+1) >= '0')
            NoSplitLine = 3;
          else
            NoSplitLine = 1;
        }
        else if (NoSplitLine > 0)
          NoSplitLine--;
        put_a_char( *q );
      }

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%S' print a string with the necessary escapes              */
    else if ( *p == 'S' ) {

      /* compute how many characters this identifier requires    */
      for ( q = (Char*)arg1; *q != '\0' && prec > 0; q++ ) {
        if      ( *q == '\n'  ) { prec -= 2; }
        else if ( *q == '\t'  ) { prec -= 2; }
        else if ( *q == '\r'  ) { prec -= 2; }
        else if ( *q == '\b'  ) { prec -= 2; }
        else if ( *q == '\01' ) { prec -= 2; }
        else if ( *q == '\02' ) { prec -= 2; }
        else if ( *q == '\03' ) { prec -= 2; }
        else if ( *q == '"'   ) { prec -= 2; }
        else if ( *q == '\\'  ) { prec -= 2; }
        else                    { prec -= 1; }
      }

      /* if wanted push an appropriate number of <space>-s       */
      while ( prec-- > 0 )  put_a_char(' ');

      /* print the string                                        */
      for ( q = (Char*)arg1; *q != '\0'; q++ ) {
        if      ( *q == '\n'  ) { put_a_char('\\'); put_a_char('n');  }
        else if ( *q == '\t'  ) { put_a_char('\\'); put_a_char('t');  }
        else if ( *q == '\r'  ) { put_a_char('\\'); put_a_char('r');  }
        else if ( *q == '\b'  ) { put_a_char('\\'); put_a_char('b');  }
        else if ( *q == '\01' ) { put_a_char('\\'); put_a_char('>');  }
        else if ( *q == '\02' ) { put_a_char('\\'); put_a_char('<');  }
        else if ( *q == '\03' ) { put_a_char('\\'); put_a_char('c');  }
        else if ( *q == '"'   ) { put_a_char('\\'); put_a_char('"');  }
        else if ( *q == '\\'  ) { put_a_char('\\'); put_a_char('\\'); }
        else                    { put_a_char( *q );               }
      }

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%C' print a string with the necessary C escapes            */
    else if ( *p == 'C' ) {

      /* compute how many characters this identifier requires    */
      for ( q = (Char*)arg1; *q != '\0' && prec > 0; q++ ) {
        if      ( *q == '\n'  ) { prec -= 2; }
        else if ( *q == '\t'  ) { prec -= 2; }
        else if ( *q == '\r'  ) { prec -= 2; }
        else if ( *q == '\b'  ) { prec -= 2; }
        else if ( *q == '\01' ) { prec -= 3; }
        else if ( *q == '\02' ) { prec -= 3; }
        else if ( *q == '\03' ) { prec -= 3; }
        else if ( *q == '"'   ) { prec -= 2; }
        else if ( *q == '\\'  ) { prec -= 2; }
        else                    { prec -= 1; }
      }

      /* if wanted push an appropriate number of <space>-s       */
      while ( prec-- > 0 )  put_a_char(' ');

      /* print the string                                        */
      for ( q = (Char*)arg1; *q != '\0'; q++ ) {
        if      ( *q == '\n'  ) { put_a_char('\\'); put_a_char('n');  }
        else if ( *q == '\t'  ) { put_a_char('\\'); put_a_char('t');  }
        else if ( *q == '\r'  ) { put_a_char('\\'); put_a_char('r');  }
        else if ( *q == '\b'  ) { put_a_char('\\'); put_a_char('b');  }
        else if ( *q == '\01' ) { put_a_char('\\'); put_a_char('0');
          put_a_char('1');                }
        else if ( *q == '\02' ) { put_a_char('\\'); put_a_char('0');
          put_a_char('2');                }
        else if ( *q == '\03' ) { put_a_char('\\'); put_a_char('0');
          put_a_char('3');                }
        else if ( *q == '"'   ) { put_a_char('\\'); put_a_char('"');  }
        else if ( *q == '\\'  ) { put_a_char('\\'); put_a_char('\\'); }
        else                    { put_a_char( *q );               }
      }

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%I' print an identifier                                    */
    else if ( *p == 'I' ) {
      int found_keyword = 0;
      int i;

      /* check if q matches a keyword    */
      q = (Char*)arg1;
      for ( i = 0; i < sizeof(AllKeywords)/sizeof(AllKeywords[0]); i++ ) {
        if ( strcmp(q, AllKeywords[i].name) == 0 ) {
          found_keyword = 1;
          break;
        }
      }

      /* compute how many characters this identifier requires    */
      if (found_keyword) {
        prec--;
      }
      for ( q = (Char*)arg1; *q != '\0'; q++ ) {
        if ( !IsIdent(*q) && !IsDigit(*q) ) {
          prec--;
        }
        prec--;
      }

      /* if wanted push an appropriate number of <space>-s       */
      while ( prec-- > 0 ) { put_a_char(' '); }

      /* print the identifier                                    */
      if ( found_keyword ) {
        put_a_char( '\\' );
      }
      for ( q = (Char*)arg1; *q != '\0'; q++ ) {
        if ( !IsIdent(*q) && !IsDigit(*q) ) {
          put_a_char( '\\' );
        }
        put_a_char( *q );
      }

      /* on to the next argument                                 */
      arg1 = arg2;
    }

    /* '%c' print a character                                      */
    else if ( *p == 'c' ) {
      put_a_char( (Char)arg1 );
      arg1 = arg2;
    }

    /* '%%' print a '%' character                                  */
    else if ( *p == '%' ) {
      put_a_char( '%' );
    }

    /* '%>' increment the indentation level                        */
    else if ( *p == '>' ) {
      put_a_char( '\01' );
      while ( --prec > 0 )
        put_a_char( '\01' );
    }

    /* '%<' decrement the indentation level                        */
    else if ( *p == '<' ) {
      put_a_char( '\02' );
      while ( --prec > 0 )
        put_a_char( '\02' );
    }

    /* else raise an error                                         */
    else {
      for ( p = "%format error"; *p != '\0'; p++ )
        put_a_char( *p );
    }

  }

}


static KOutputStream theStream;

static void putToTheStream( Char c) {
  PutChrTo(theStream, c);
}

void PrTo (
           KOutputStream     stream,
           const Char *      format,
           Int                 arg1,
           Int                 arg2 )
{
  KOutputStream savedStream = theStream;
  theStream = stream;
  FormatOutput( putToTheStream, format, arg1, arg2);
  theStream = savedStream;
}

void Pr (
         const Char *      format,
         Int                 arg1,
         Int                 arg2 )
{
  PrTo(Output, format, arg1, arg2);
}

static Char *theBuffer;
static UInt theCount;
static UInt theLimit;

static void putToTheBuffer( Char c)
{
  if (theCount < theLimit)
    theBuffer[theCount++] = c;
}

void SPrTo(Char *buffer, UInt maxlen, const Char *format, Int arg1, Int arg2)
{
  Char *savedBuffer = theBuffer;
  UInt savedCount = theCount;
  UInt savedLimit = theLimit;
  theBuffer = buffer;
  theCount = 0;
  theLimit = maxlen;
  FormatOutput(putToTheBuffer, format, arg1, arg2);
  putToTheBuffer('\0');
  theBuffer = savedBuffer;
  theCount = savedCount;
  theLimit = savedLimit;
}


Obj FuncINPUT_FILENAME( Obj self) {
  Obj s;
  C_NEW_STRING( s, strlen(Input->name), Input->name );
  return s;
}

Obj FuncINPUT_LINENUMBER( Obj self) {
  return INTOBJ_INT(Input->number);
}

Obj FuncALL_KEYWORDS(Obj self) {
  Obj l;

  Obj s;
  UInt i;
  l = NEW_PLIST(T_PLIST_EMPTY, 0);
  SET_LEN_PLIST(l,0);
  for (i = 0; i < sizeof(AllKeywords)/sizeof(AllKeywords[0]); i++) {
    C_NEW_STRING(s,strlen(AllKeywords[i].name),AllKeywords[i].name);
    ASS_LIST(l, i+1, s);
  }
  MakeImmutable(l);
  return l;
}

Obj FuncSET_PRINT_FORMATTING_STDOUT(Obj self, Obj val) {
  if (val == False)
    (OutputFiles+1)->format = 0;
  else
    (OutputFiles+1)->format = 1;
  return val;
}



/****************************************************************************
 **
 *F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
 */

/****************************************************************************
 **
 *V  GVarFuncs . . . . . . . . . . . . . . . . . . list of functions to export
 */
static StructGVarFunc GVarFuncs [] = {

  { "ToggleEcho", 0, "",
    FuncToggleEcho, "src/scanner.c:ToggleEcho" },

  { "CPROMPT", 0, "",
    FuncCPROMPT, "src/scanner.c:CPROMPT" },

  { "PRINT_CPROMPT", 1, "prompt",
    FuncPRINT_CPROMPT, "src/scanner.c:PRINT_CPROMPT" },

  { "INPUT_FILENAME", 0 , "",
    FuncINPUT_FILENAME, "src/scanner.c:INPUT_FILENAME" },

  { "INPUT_LINENUMBER", 0 , "",
    FuncINPUT_LINENUMBER, "src/scanner.c:INPUT_LINENUMBER" },

  { "ALL_KEYWORDS", 0 , "",
    FuncALL_KEYWORDS, "src/scanner.c:ALL_KEYWORDS"},

  { "SET_PRINT_FORMATTING_STDOUT", 1 , "format",
    FuncSET_PRINT_FORMATTING_STDOUT,
    "src/scanner.c:SET_PRINT_FORMATTING_STDOUT"},

  { 0 }

};

/****************************************************************************
 **
 *F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
 */
static Int InitLibrary (
                        StructInitInfo *    module )
{
  /* init filters and functions                                          */
  InitGVarFuncsFromTable( GVarFuncs );

  /* return success                                                      */
  return 0;
}

/****************************************************************************
 **
 *F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
 */
static Char Cookie[sizeof(InputFiles)/sizeof(InputFiles[0])][9];
static Char MoreCookie[sizeof(InputFiles)/sizeof(InputFiles[0])][9];
static Char StillMoreCookie[sizeof(InputFiles)/sizeof(InputFiles[0])][9];

static Int InitKernel (
    StructInitInfo *    module )
{
    Int                 i;

    Input = InputFiles;
    Input--;
    (void)OpenInput(  "*stdin*"  );
    Input->echo = 1; /* echo stdin */
    Output = 0L;
    (void)OpenOutput( "*stdout*" );

    InputLog  = 0;  OutputLog  = 0;
    TestInput = 0;  TestOutput = 0;

    /* initialize cookies for streams                                      */
    /* also initialize the cookies for the GAP strings which hold the
       latest lines read from the streams  and the name of the current input file*/
    for ( i = 0;  i < sizeof(InputFiles)/sizeof(InputFiles[0]);  i++ ) {
      Cookie[i][0] = 's';  Cookie[i][1] = 't';  Cookie[i][2] = 'r';
      Cookie[i][3] = 'e';  Cookie[i][4] = 'a';  Cookie[i][5] = 'm';
      Cookie[i][6] = ' ';  Cookie[i][7] = '0'+i;
      Cookie[i][8] = '\0';
      InitGlobalBag(&(InputFiles[i].stream), &(Cookie[i][0]));

      MoreCookie[i][0] = 's';  MoreCookie[i][1] = 'l';  MoreCookie[i][2] = 'i';
      MoreCookie[i][3] = 'n';  MoreCookie[i][4] = 'e';  MoreCookie[i][5] = ' ';
      MoreCookie[i][6] = ' ';  MoreCookie[i][7] = '0'+i;
      MoreCookie[i][8] = '\0';
      InitGlobalBag(&(InputFiles[i].sline), &(MoreCookie[i][0]));

      StillMoreCookie[i][0] = 'g';  StillMoreCookie[i][1] = 'a';  StillMoreCookie[i][2] = 'p';
      StillMoreCookie[i][3] = 'n';  StillMoreCookie[i][4] = 'a';  StillMoreCookie[i][5] = 'm';
      StillMoreCookie[i][6] = 'e';  StillMoreCookie[i][7] = '0'+i;
      StillMoreCookie[i][8] = '\0';
      InitGlobalBag(&(InputFiles[i].gapname), &(StillMoreCookie[i][0]));
    }

    /* tell GASMAN about the global bags                                   */
    InitGlobalBag(&(logFile.stream),        "src/scanner.c:logFile"        );
    InitGlobalBag(&(logStream.stream),      "src/scanner.c:logStream"      );
    InitGlobalBag(&(inputLogStream.stream), "src/scanner.c:inputLogStream" );
    InitGlobalBag(&(outputLogStream.stream),"src/scanner.c:outputLogStream");


    /* import functions from the library                                   */
    ImportFuncFromLibrary( "ReadLine", &ReadLineFunc );
    ImportFuncFromLibrary( "WriteAll", &WriteAllFunc );
    ImportFuncFromLibrary( "IsInputTextStringRep", &IsStringStream );
    InitCopyGVar( "PrintPromptHook", &PrintPromptHook );
    InitCopyGVar( "EndLineHook", &EndLineHook );
    InitFopyGVar( "PrintFormattingStatus", &PrintFormattingStatus);

    InitHdlrFuncsFromTable( GVarFuncs );
    /* return success                                                      */
    return 0;
}


/****************************************************************************
 **
 *F  InitInfoScanner() . . . . . . . . . . . . . . . . table of init functions
 */
static StructInitInfo module = {
  MODULE_BUILTIN,                     /* type                           */
  "scanner",                          /* name                           */
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

StructInitInfo * InitInfoScanner ( void )
{
  FillInVersion( &module );
  return &module;
}


/****************************************************************************
 **

 *E  scanner.c . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
 */
