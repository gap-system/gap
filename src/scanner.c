/****************************************************************************
**
*W  scanner.c                   GAP source                   Martin Schönert
**
**
*Y  Copyright (C)  1996,  Lehrstuhl  für Mathematik,  RWTH Aachen,  Germany
*Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
*Y  Copyright (C) 2002 The GAP Group
**
**  This file contains the functions of the scanner, which provides a very
**  abstractions, namely the concept that an input file is a stream of
**  symbols, such nasty things as <space>, <tab>, <newline> characters or
**  comments (they are worst :-), characters making up identifiers or digits
**  that make up integers are hidden from the rest of GAP.
*/

#include <src/scanner.h>

#include <src/gap.h>
#include <src/gapstate.h>
#include <src/gaputils.h>
#include <src/io.h>
#include <src/lists.h>
#include <src/plist.h>
#include <src/stringobj.h>


/****************************************************************************
**
*F  SyntaxError( <msg> )  . . . . . . . . . . . . . . .  raise a syntax error
**
*/
void            SyntaxError (
    const Char *        msg )
{
    Int                 i;

    /* open error output                                                   */
    OpenOutput( "*errout*" );

    /* one more error                                                      */
    STATE(NrError)++;
    STATE(NrErrLine)++;

    /* do not print a message if we found one already on the current line  */
    if ( STATE(NrErrLine) == 1 )

      {
        /* print the message and the filename, unless it is '*stdin*'          */
        Pr( "Syntax error: %s", (Int)msg, 0L );
        if ( strcmp( "*stdin*", STATE(Input)->name ) != 0 )
            Pr(" in %s:%d", (Int)STATE(Input)->name, GetInputLineNumber());
        Pr( "\n", 0L, 0L );

        /* print the current line                                              */
        Pr( "%s", (Int)STATE(Input)->line, 0L );

        /* print a '^' pointing to the current position                        */
        Int pos = GetLinePosition();
        for (i = 0; i < pos; i++) {
            if (STATE(Input)->line[i] == '\t')
                Pr("\t", 0L, 0L);
            else
                Pr(" ", 0L, 0L);
        }
        Pr( "^\n", 0L, 0L );
      }
    /* close error output                                                  */
    CloseOutput();
}

/****************************************************************************
**
*F  SyntaxWarning( <msg> )  . . . . . . . . . . . . . . raise a syntax warning
**
*/
void            SyntaxWarning (
    const Char *        msg )
{
    Int                 i;

    /* open error output                                                   */
    OpenOutput( "*errout*" );


    /* do not print a message if we found one already on the current line  */
    if ( STATE(NrErrLine) == 0 )

      {
        /* print the message and the filename, unless it is '*stdin*'          */
        Pr( "Syntax warning: %s", (Int)msg, 0L );
        if ( strcmp( "*stdin*", STATE(Input)->name ) != 0 )
            Pr(" in %s:%d", (Int)STATE(Input)->name, GetInputLineNumber());
        Pr( "\n", 0L, 0L );

        /* print the current line                                              */
        Pr( "%s", (Int)STATE(Input)->line, 0L );

        /* print a '^' pointing to the current position                        */
        Int pos = GetLinePosition();
        for (i = 0; i < pos; i++) {
            if (STATE(Input)->line[i] == '\t')
                Pr("\t", 0L, 0L);
            else
                Pr(" ", 0L, 0L);
        }
        Pr( "^\n", 0L, 0L );
      }
    /* close error output                                                  */
    CloseOutput();
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
void Match (
    UInt                symbol,
    const Char *        msg,
    TypSymbolSet        skipto )
{
    Char                errmsg [256];

    // if 'STATE(Symbol)' is the expected symbol match it away
    if ( symbol == STATE(Symbol) ) {
        GetSymbol();
    }

    /* else generate an error message and skip to a symbol in <skipto>     */
    else {
        strlcpy( errmsg, msg, sizeof(errmsg) );
        strlcat( errmsg, " expected", sizeof(errmsg) );
        SyntaxError( errmsg );
        while ( ! IS_IN( STATE(Symbol), skipto ) )
            GetSymbol();
    }
}



/****************************************************************************
**
*F  GetIdent()  . . . . . . . . . . . . . get an identifier or keyword, local
**
**  'GetIdent' reads   an identifier from  the current  input  file  into the
**  variable 'STATE(Value)' and sets 'Symbol' to 'S_IDENT'. The first
**  character of the identifier is the current character pointed to by 'In'.
**  If the characters make up a keyword 'GetIdent' will set 'Symbol' to the
**  corresponding value. The parser will ignore 'STATE(Value)' in this case.
**
**  An  identifier consists of a letter  followed by more letters, digits and
**  underscores '_'.  An identifier is terminated by the first  character not
**  in this  class.  The escape sequence '\<newline>'  is ignored,  making it
**  possible to split  long identifiers  over multiple lines.  The  backslash
**  '\' can be used  to include special characters like  '('  in identifiers.
**  For example 'G\(2\,5\)' is an identifier not a call to a function 'G'.
**
**  The size of 'STATE(Value)' limits the number of significant characters in
**  an identifier. If an identifier has more characters 'GetIdent' will
**  silently truncate it.
**
**  After reading the identifier 'GetIdent'  looks at the  first and the last
**  character of 'STATE(Value)' to see if it could possibly be a keyword. For
**  example 'test'  could  not be  a  keyword  because there  is  no  keyword
**  starting and ending with a 't'.  After that  test either 'GetIdent' knows
**  that 'STATE(Value)' is not a keyword, or there is a unique possible
**  keyword that could match, because no two keywords have identical first
**  and last characters. For example if 'STATE(Value)' starts with 'f' and
**  ends with 'n' the only possible keyword is 'function'. Thus in this case
**  'GetIdent' can decide with one string comparison if 'STATE(Value)' holds
**  a keyword or not.
*/
void GetIdent ( void )
{
    Int                 i, fetch;
    Int                 isQuoted;

    /* initially it could be a keyword                                     */
    isQuoted = 0;

    /* read all characters into 'STATE(Value)'                                    */
    for ( i=0; IsIdent(*STATE(In)) || IsDigit(*STATE(In)) || *STATE(In)=='\\'; i++ ) {

        fetch = 1;
        /* handle escape sequences                                         */
        /* we ignore '\ newline' by decrementing i, except at the
           very start of the identifier, when we cannot do that
           so we recurse instead                                           */
        if ( *STATE(In) == '\\' ) {
            GET_CHAR();
            if      ( *STATE(In) == '\n' && i == 0 )  { GetSymbol();  return; }
            else if ( *STATE(In) == '\r' )  {
                GET_CHAR();
                if  ( *STATE(In) == '\n' )  {
                     if (i == 0) { GetSymbol();  return; }
                     else i--;
                }
                else  {STATE(Value)[i] = '\r'; fetch = 0;}
            }
            else if ( *STATE(In) == '\n' && i < SAFE_VALUE_SIZE-1 )  i--;
            else if ( *STATE(In) == 'n'  && i < SAFE_VALUE_SIZE-1 )  STATE(Value)[i] = '\n';
            else if ( *STATE(In) == 't'  && i < SAFE_VALUE_SIZE-1 )  STATE(Value)[i] = '\t';
            else if ( *STATE(In) == 'r'  && i < SAFE_VALUE_SIZE-1 )  STATE(Value)[i] = '\r';
            else if ( *STATE(In) == 'b'  && i < SAFE_VALUE_SIZE-1 )  STATE(Value)[i] = '\b';
            else if ( i < SAFE_VALUE_SIZE-1 )  {
                STATE(Value)[i] = *STATE(In);
                isQuoted = 1;
            }
        }

        /* put normal chars into 'STATE(Value)' but only if there is room         */
        else {
            if ( i < SAFE_VALUE_SIZE-1 )  STATE(Value)[i] = *STATE(In);
        }

        /* read the next character                                         */
        if (fetch) GET_CHAR();

    }

    /* terminate the identifier and lets assume that it is not a keyword   */
    if ( i < SAFE_VALUE_SIZE-1 )
        STATE(Value)[i] = '\0';
    else {
        SyntaxError("Identifiers in GAP must consist of less than 1023 characters.");
        i =  SAFE_VALUE_SIZE-1;
        STATE(Value)[i] = '\0';
    }
    STATE(Symbol) = S_IDENT;

    /* now check if 'STATE(Value)' holds a keyword                                */
    switch ( 256*STATE(Value)[0]+STATE(Value)[i-1] ) {
    case 256*'a'+'d': if(!strcmp(STATE(Value),"and"))     STATE(Symbol)=S_AND;     break;
    case 256*'a'+'c': if(!strcmp(STATE(Value),"atomic"))  STATE(Symbol)=S_ATOMIC;  break;
    case 256*'b'+'k': if(!strcmp(STATE(Value),"break"))   STATE(Symbol)=S_BREAK;   break;
    case 256*'c'+'e': if(!strcmp(STATE(Value),"continue"))   STATE(Symbol)=S_CONTINUE;   break;
    case 256*'d'+'o': if(!strcmp(STATE(Value),"do"))      STATE(Symbol)=S_DO;      break;
    case 256*'e'+'f': if(!strcmp(STATE(Value),"elif"))    STATE(Symbol)=S_ELIF;    break;
    case 256*'e'+'e': if(!strcmp(STATE(Value),"else"))    STATE(Symbol)=S_ELSE;    break;
    case 256*'e'+'d': if(!strcmp(STATE(Value),"end"))     STATE(Symbol)=S_END;     break;
    case 256*'f'+'e': if(!strcmp(STATE(Value),"false"))   STATE(Symbol)=S_FALSE;   break;
    case 256*'f'+'i': if(!strcmp(STATE(Value),"fi"))      STATE(Symbol)=S_FI;      break;
    case 256*'f'+'r': if(!strcmp(STATE(Value),"for"))     STATE(Symbol)=S_FOR;     break;
    case 256*'f'+'n': if(!strcmp(STATE(Value),"function"))STATE(Symbol)=S_FUNCTION;break;
    case 256*'i'+'f': if(!strcmp(STATE(Value),"if"))      STATE(Symbol)=S_IF;      break;
    case 256*'i'+'n': if(!strcmp(STATE(Value),"in"))      STATE(Symbol)=S_IN;      break;
    case 256*'l'+'l': if(!strcmp(STATE(Value),"local"))   STATE(Symbol)=S_LOCAL;   break;
    case 256*'m'+'d': if(!strcmp(STATE(Value),"mod"))     STATE(Symbol)=S_MOD;     break;
    case 256*'n'+'t': if(!strcmp(STATE(Value),"not"))     STATE(Symbol)=S_NOT;     break;
    case 256*'o'+'d': if(!strcmp(STATE(Value),"od"))      STATE(Symbol)=S_OD;      break;
    case 256*'o'+'r': if(!strcmp(STATE(Value),"or"))      STATE(Symbol)=S_OR;      break;
    case 256*'r'+'e': if(!strcmp(STATE(Value),"readwrite")) STATE(Symbol)=S_READWRITE;     break;
    case 256*'r'+'y': if(!strcmp(STATE(Value),"readonly"))  STATE(Symbol)=S_READONLY;     break;
    case 256*'r'+'c': if(!strcmp(STATE(Value),"rec"))     STATE(Symbol)=S_REC;     break;
    case 256*'r'+'t': if(!strcmp(STATE(Value),"repeat"))  STATE(Symbol)=S_REPEAT;  break;
    case 256*'r'+'n': if(!strcmp(STATE(Value),"return"))  STATE(Symbol)=S_RETURN;  break;
    case 256*'t'+'n': if(!strcmp(STATE(Value),"then"))    STATE(Symbol)=S_THEN;    break;
    case 256*'t'+'e': if(!strcmp(STATE(Value),"true"))    STATE(Symbol)=S_TRUE;    break;
    case 256*'u'+'l': if(!strcmp(STATE(Value),"until"))   STATE(Symbol)=S_UNTIL;   break;
    case 256*'w'+'e': if(!strcmp(STATE(Value),"while"))   STATE(Symbol)=S_WHILE;   break;
    case 256*'q'+'t': if(!strcmp(STATE(Value),"quit"))    STATE(Symbol)=S_QUIT;    break;
    case 256*'Q'+'T': if(!strcmp(STATE(Value),"QUIT"))    STATE(Symbol)=S_QQUIT;   break;

    case 256*'I'+'d': if(!strcmp(STATE(Value),"IsBound")) STATE(Symbol)=S_ISBOUND; break;
    case 256*'U'+'d': if(!strcmp(STATE(Value),"Unbind"))  STATE(Symbol)=S_UNBIND;  break;
    case 256*'T'+'d': if(!strcmp(STATE(Value),"TryNextMethod"))
                                                     STATE(Symbol)=S_TRYNEXT; break;
    case 256*'I'+'o': if(!strcmp(STATE(Value),"Info"))    STATE(Symbol)=S_INFO;    break;
    case 256*'A'+'t': if(!strcmp(STATE(Value),"Assert"))  STATE(Symbol)=S_ASSERT;  break;

    default: ;
    }

    /* if it is quoted it is an identifier                                 */
    if ( isQuoted )  STATE(Symbol) = S_IDENT;


}


/****************************************************************************
**
*F  GetNumber()  . . . . . . . . . . . . . .  get an integer or float literal
**
**  'GetNumber' reads a number from the current input file into the variable
**  'STATE(Value)' and sets 'Symbol' to 'S_INT', 'S_PARTIALINT', 'S_FLOAT' or
**  'S_PARTIALFLOAT'. The first character of the number is the current
**  character pointed to by 'In'.
**
**  If the sequence contains characters which do not match the regular
**  expression [0-9]+.?[0-9]*([edqEDQ][+-]?[0-9]+)? 'GetNumber'  will
**  interpret the sequence as an identifier and set 'Symbol' to 'S_IDENT'.
**
**  As we read, we keep track of whether we have seen a . or exponent
**  notation and so whether we will return S_[PARTIAL]INT or
**  S_[PARTIAL]FLOAT.
**
**  When STATE(Value) is completely filled we have to check if the reading of
**  the number is complete or not to decide whether to return a PARTIAL type.
**
**  The argument reflects how far we are through reading a possibly very long
**  number literal. 0 indicates that nothing has been read. 1 that at least
**  one digit has been read, but no decimal point. 2 that a decimal point has
**  been read with no digits before or after it. 3 a decimal point and at
**  least one digit, but no exponential indicator 4 an exponential indicator
**  but no exponent digits and 5 an exponential indicator and at least one
**  exponent digit.
**
*/
static Char GetCleanedChar( UInt *wasEscaped ) {
  GET_CHAR();
  *wasEscaped = 0;
  if (*STATE(In) == '\\') {
    GET_CHAR();
    if      ( *STATE(In) == '\n')
      return GetCleanedChar(wasEscaped);
    else if ( *STATE(In) == '\r' )  {
      if ( PEEK_CHAR() == '\n' ) {
        GET_CHAR();
        return GetCleanedChar(wasEscaped);
      }
      else {
        *wasEscaped = 1;
        return '\r';
      }
    }
    else {
      *wasEscaped = 1;
      if ( *STATE(In) == 'n')  return '\n';
      else if ( *STATE(In) == 't')  return '\t';
      else if ( *STATE(In) == 'r')  return '\r';
      else if ( *STATE(In) == 'b')  return '\b';
      else if ( *STATE(In) == '>')  return '\01';
      else if ( *STATE(In) == '<')  return '\02';
      else if ( *STATE(In) == 'c')  return '\03';
    }
  }
  return *STATE(In);
}


void GetNumber ( UInt StartingStatus )
{
  Int                 i=0;
  Char                c;
  UInt seenExp = 0;
  UInt wasEscaped = 0;
  UInt seenADigit = (StartingStatus != 0 && StartingStatus != 2);
  UInt seenExpDigit = (StartingStatus ==5);

  c = *STATE(In);
  if (StartingStatus  <  2) {
    /* read initial sequence of digits into 'Value'             */
    for (i = 0; !wasEscaped && IsDigit(c) && i < SAFE_VALUE_SIZE-1; i++) {
      STATE(Value)[i] = c;
      seenADigit = 1;
      c = GetCleanedChar(&wasEscaped);
    }

    /* So why did we run off the end of that loop */
    /* maybe we saw an identifier character and realised that this is an identifier we are reading */
    if (wasEscaped || IsIdent(c)) {
      /* Now we know we have an identifier read the rest of it */
      STATE(Value)[i++] = c;
      c = GetCleanedChar(&wasEscaped);
      for (; wasEscaped || IsIdent(c) || IsDigit(c); i++) {
        if (i < SAFE_VALUE_SIZE -1)
          STATE(Value)[i] = c;
        c = GetCleanedChar(&wasEscaped);
      }
      if (i < SAFE_VALUE_SIZE -1)
        STATE(Value)[i] = '\0';
      else
        STATE(Value)[SAFE_VALUE_SIZE-1] = '\0';
      STATE(Symbol) = S_IDENT;
      return;
    }

    /* Or maybe we just ran out of space */
    if (IsDigit(c)) {
      assert(i >= SAFE_VALUE_SIZE-1);
      STATE(Symbol) = S_PARTIALINT;
      STATE(Value)[SAFE_VALUE_SIZE-1] = '\0';
      return;
    }

    /* Or maybe we saw a . which could indicate one of two things:
       a float literal or .. */
    if (c == '.') {
      /* If the symbol before this integer was S_DOT then 
         we must be in a nested record element expression, so don't 
         look for a float.

      This is a bit fragile  */
      if (STATE(Symbol) == S_DOT || STATE(Symbol) == S_BDOT) {
        STATE(Value)[i]  = '\0';
        STATE(Symbol) = S_INT;
        return;
      }
      
      /* peek ahead to decide which */
      if (PEEK_CHAR() == '.') {
        /* It was .. */
        STATE(Symbol) = S_INT;
        STATE(Value)[i] = '\0';
        return;
      }

      /* Now the . must be part of our number
         store it and move on */
      STATE(Value)[i++] = '.';
      c = GetCleanedChar(&wasEscaped);
    }

    else {
      /* Anything else we see tells us that the token is done */
      STATE(Value)[i]  = '\0';
      STATE(Symbol) = S_INT;
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
      STATE(Value)[i] = c;
      seenADigit = 1;
      c = GetCleanedChar(&wasEscaped);
    }
    /* If we found an identifier type character in this context could be an error
      or the start of one of the allowed trailing marker sequences */
    if (wasEscaped || (IsIdent(c)  && c != 'e' && c != 'E' && c != 'D' && c != 'q' &&
                       c != 'd' && c != 'Q')) {

      if (!seenADigit)
        SyntaxError("Badly formed number: need a digit before or after the decimal point");
      /* We allow one letter on the end of the numbers -- could be an i,
       C99 style */
      if (!wasEscaped) {
        if (IsAlpha(c)) {
          STATE(Value)[i++] = c;
          c = GetCleanedChar(&wasEscaped);
        }
        /* independently of that, we allow an _ signalling immediate conversion */
        if (c == '_') {
          STATE(Value)[i++] = c;
          c = GetCleanedChar(&wasEscaped);
          /* After which there may be one character signifying the conversion style */
          if (IsAlpha(c)) {
            STATE(Value)[i++] = c;
            c = GetCleanedChar(&wasEscaped);
          }
        }
        /* Now if the next character is alphanumerical, or an identifier type symbol then we
           really do have an error, otherwise we return a result */
        if (!IsIdent(c) && !IsDigit(c)) {
          STATE(Value)[i] = '\0';
          STATE(Symbol) = S_FLOAT;
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
          SyntaxError("Badly formed number: need a digit before or after the decimal point");
        seenExp = 1;
        STATE(Value)[i++] = c;
        c = GetCleanedChar(&wasEscaped);
        if (!wasEscaped && (c == '+' || c == '-'))
          {
            STATE(Value)[i++] = c;
            c = GetCleanedChar(&wasEscaped);
          }
      }

    /* Now deal with full buffer case */
    if (i >= SAFE_VALUE_SIZE -1) {
      STATE(Symbol) = seenExp ? S_PARTIALFLOAT3 : S_PARTIALFLOAT2;
      STATE(Value)[i] = '\0';
      return;
    }

    /* Either we saw an exponent indicator, or we hit end of token
       deal with the end of token case */
    if (!seenExp) {
      if (!seenADigit)
        SyntaxError("Badly formed number: need a digit before or after the decimal point");
      /* Might be a conversion marker */
      if (!wasEscaped) {
        if (IsAlpha(c) && c != 'e' && c != 'E' && c != 'd' && c != 'D' && c != 'q' && c != 'Q') {
          STATE(Value)[i++] = c;
          c = GetCleanedChar(&wasEscaped);
        }
        /* independently of that, we allow an _ signalling immediate conversion */
        if (c == '_') {
          STATE(Value)[i++] = c;
          c = GetCleanedChar(&wasEscaped);
          /* After which there may be one character signifying the conversion style */
          if (IsAlpha(c))
            STATE(Value)[i++] = c;
          c = GetCleanedChar(&wasEscaped);
        }
        /* Now if the next character is alphanumerical, or an identifier type symbol then we
           really do have an error, otherwise we return a result */
        if (!IsIdent(c) && !IsDigit(c)) {
          STATE(Value)[i] = '\0';
          STATE(Symbol) = S_FLOAT;
          return;
        }
      }
      SyntaxError("Badly Formed Number");
    }

  }

  /* Here we are into the unsigned exponent of a number
     in scientific notation, so we just read digits */
  for (; !wasEscaped && IsDigit(c) && i < SAFE_VALUE_SIZE-1; i++) {
    STATE(Value)[i] = c;
    seenExpDigit = 1;
    c = GetCleanedChar(&wasEscaped);
  }

  /* Look out for a single alphabetic character on the end
     which could be a conversion marker */
  if (seenExpDigit) {
    if (IsAlpha(c)) {
      STATE(Value)[i] = c;
      c = GetCleanedChar(&wasEscaped);
      STATE(Value)[i+1] = '\0';
      STATE(Symbol) = S_FLOAT;
      return;
    }
    if (c == '_') {
      STATE(Value)[i++] = c;
      c = GetCleanedChar(&wasEscaped);
      /* After which there may be one character signifying the conversion style */
      if (IsAlpha(c)) {
        STATE(Value)[i++] = c;
        c = GetCleanedChar(&wasEscaped);
      }
      STATE(Value)[i] = '\0';
      STATE(Symbol) = S_FLOAT;
      return;
    }
  }

  /* If we ran off the end */
  if (i >= SAFE_VALUE_SIZE -1) {
    STATE(Symbol) = seenExpDigit ? S_PARTIALFLOAT4 : S_PARTIALFLOAT3;
    STATE(Value)[i] = '\0';
    return;
  }

  /* Otherwise this is the end of the token */
  if (!seenExpDigit)
    SyntaxError("Badly Formed Number: need at least one digit in the exponent");
  STATE(Symbol) = S_FLOAT;
  STATE(Value)[i] = '\0';
}


/****************************************************************************
**
*F  GetEscapedChar() . . . . . . . . . . . . . . . . get an escaped character
**
**  'GetEscapedChar' reads an escape sequence from the current input file
**  into the variable *dst.
**
*/
static inline Char GetOctalDigits( void )
{
    Char c;

    if ( *STATE(In) < '0' || *STATE(In) > '7' )
        SyntaxError("Expecting octal digit");
    c = 8 * (*STATE(In) - '0');
    GET_CHAR();
    if ( *STATE(In) < '0' || *STATE(In) > '7' )
        SyntaxError("Expecting octal digit");
    c = c + (*STATE(In) - '0');

    return c;
}


/****************************************************************************
**
*F  CharHexDigit( <ch> ) . . . . . . . . .  turn a single hex digit into Char
**
*/
static inline Char CharHexDigit( const Char ch ) {
    if (ch >= 'a') {
        return (ch - 'a' + 10);
    } else if (ch >= 'A') {
        return (ch - 'A' + 10);
    } else {
        return (ch - '0');
    }
}

Char GetEscapedChar( void )
{
  Char c;

  c = 0;

  if ( *STATE(In) == 'n'  )       c = '\n';
  else if ( *STATE(In) == 't'  )  c = '\t';
  else if ( *STATE(In) == 'r'  )  c = '\r';
  else if ( *STATE(In) == 'b'  )  c = '\b';
  else if ( *STATE(In) == '>'  )  c = '\01';
  else if ( *STATE(In) == '<'  )  c = '\02';
  else if ( *STATE(In) == 'c'  )  c = '\03';
  else if ( *STATE(In) == '"'  )  c = '"';
  else if ( *STATE(In) == '\\' )  c = '\\';
  else if ( *STATE(In) == '\'' )  c = '\'';
  else if ( *STATE(In) == '0'  ) {
    /* from here we can either read a hex-escape or three digit
       octal numbers */
    GET_CHAR();
    if (*STATE(In) == 'x') {
        GET_CHAR();
        if (!IsHexDigit(*STATE(In))) {
            SyntaxError("Expecting hexadecimal digit");
        }
        c = 16 * CharHexDigit(*STATE(In));
        GET_CHAR();
        if (!IsHexDigit(*STATE(In))) {
            SyntaxError("Expecting hexadecimal digit");
        }
        c += CharHexDigit(*STATE(In));
    } else if (*STATE(In) >= '0' && *STATE(In) <= '7' ) {
        c += GetOctalDigits();
    } else {
        SyntaxError("Expecting hexadecimal escape, or two more octal digits");
    }
  } else if ( *STATE(In) >= '1' && *STATE(In) <= '7' ) {
    /* escaped three digit octal numbers are allowed in input */
    c = 64 * (*STATE(In) - '0');
    GET_CHAR();
    c += GetOctalDigits();
  } else {
      /* Following discussions on pull-request #612, this warning is currently
         disabled for backwards compatibility; some code relies on this behaviour
         and tests break with the warning enabled */
      /*
      if (IsAlpha(*STATE(In)))
          SyntaxWarning("Alphabet letter after \\");
      */
      c = *STATE(In);
  }
  return c;
}

/****************************************************************************
**
*F  GetStr()  . . . . . . . . . . . . . . . . . . . . .  get a string, local
**
**  'GetStr' reads  a  string from the  current input file into  the variable
**  'STATE(Value)' and sets 'Symbol'   to  'S_STRING'.  The opening double quote '"'
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
**  When STATE(Value) is  completely filled we have to check  if the reading of
**  the string is  complete or not to decide  between Symbol=S_STRING or
**  S_PARTIALSTRING.
*/
void GetStr ( void )
{
  Int                 i = 0, fetch;


  /* read all characters into 'Value'                                    */
  for ( i = 0; i < SAFE_VALUE_SIZE-1 && *STATE(In) != '"'
           && *STATE(In) != '\n' && *STATE(In) != '\377'; i++ ) {

    fetch = 1;
    /* handle escape sequences                                         */
    if ( *STATE(In) == '\\' ) {
      GET_CHAR();
      /* if next is another '\\' followed by '\n' it must be ignored */
      while ( *STATE(In) == '\\' && PEEK_CHAR() == '\n' ) {
          GET_CHAR();
          GET_CHAR();
      }
      if      ( *STATE(In) == '\n' )  i--;
      else if ( *STATE(In) == '\r' )  {
        GET_CHAR();
        if  ( *STATE(In) == '\n' )  i--;
        else  {STATE(Value)[i] = '\r'; fetch = 0;}
      } else {
          STATE(Value)[i] = GetEscapedChar();
      }
    }

    /* put normal chars into 'Value' but only if there is room         */
    else {
      STATE(Value)[i] = *STATE(In);
    }

    /* read the next character                                         */
    if (fetch) GET_CHAR();

  }

  /* XXX although we have ValueLen we need trailing \000 here,
     in gap.c, function FuncMAKE_INIT this is still used as C-string
     and long integers and strings are not yet supported!    */
  STATE(Value)[i] = '\0';

  /* check for error conditions                                          */
  if ( *STATE(In) == '\n'  )
    SyntaxError("String must not include <newline>");
  if ( *STATE(In) == '\377' )
    SyntaxError("String must end with \" before end of file");

  /* set length of string, set 'Symbol' and skip trailing '"'            */
  STATE(ValueLen) = i;
  if ( i < SAFE_VALUE_SIZE-1 )  {
    STATE(Symbol) = S_STRING;
    if ( *STATE(In) == '"' )  GET_CHAR();
  }
  else
    STATE(Symbol) = S_PARTIALSTRING;
}

/****************************************************************************
**
*F  GetTripStr()  . . . . . . . . . . . . .get a triple quoted string, local
**
**  'GetTripStr' reads a triple-quoted string from the  current input file
**  into  the variable 'Value' and sets 'Symbol'   to  'S_STRING'.
**  The last member of the opening triple quote '"'
**  of the string is the current character pointed to by 'In'.
**
**  A triple quoted string is any sequence of characters which is terminated
**  by """. No escaping is performed.
**
**  An error is raised if the file ends before the closing """.
**
**  When Value is  completely filled we have to check  if the reading of
**  the string is  complete or not to decide  between Symbol=S_STRING or
**  S_PARTIALTRIPLESTRING.
*/
void GetTripStr ( void )
{
  Int                 i = 0;

  /* print only a partial prompt while reading a triple string           */
  if ( !SyQuiet )
    STATE(Prompt) = "> ";
  else
    STATE(Prompt) = "";
  
  /* read all characters into 'Value'                                    */
  for ( i = 0; i < SAFE_VALUE_SIZE-1 && *STATE(In) != '\377'; i++ ) {
    // Only thing to check for is a triple quote.
    
    if ( *STATE(In) == '"') {
        GET_CHAR();
        if (*STATE(In) == '"') {
            GET_CHAR();
            if(*STATE(In) == '"' ) {
                break;
            }
            STATE(Value)[i] = '"';
            i++;
        }
        STATE(Value)[i] = '"';
        i++;
    }
    STATE(Value)[i] = *STATE(In);


    /* read the next character                                         */
    GET_CHAR();
  }

  /* XXX although we have ValueLen we need trailing \000 here,
     in gap.c, function FuncMAKE_INIT this is still used as C-string
     and long integers and strings are not yet supported!    */
  STATE(Value)[i] = '\0';

  /* check for error conditions                                          */
  if ( *STATE(In) == '\377' )
    SyntaxError("String must end with \" before end of file");

  /* set length of string, set 'Symbol' and skip trailing '"'            */
  STATE(ValueLen) = i;
  if ( i < SAFE_VALUE_SIZE-1 )  {
    STATE(Symbol) = S_STRING;
    if ( *STATE(In) == '"' )  GET_CHAR();
  }
  else
    STATE(Symbol) = S_PARTIALTRIPSTRING;
}

/****************************************************************************
**
*F  GetMaybeTripStr()  . . . . . . . . . . . . . . . . . get a string, local
**
**  'GetMaybeTripStr' decides if we are reading a single quoted string,
**  or a triple quoted string.
*/
void GetMaybeTripStr ( void )
{
    /* This is just a normal string! */
    if ( *STATE(In) != '"' ) {
        GetStr();
        return;
    }
    
    GET_CHAR();
    /* This was just an empty string! */
    if ( *STATE(In) != '"' ) {
        STATE(Value)[0] = '\0';
        STATE(ValueLen) = 0;
        STATE(Symbol) = S_STRING;
        return;
    }
    
    GET_CHAR();
    /* Now we know we are reading a triple string */
    GetTripStr();
}


/****************************************************************************
**
*F  GetChar() . . . . . . . . . . . . . . . . . get a single character, local
**
**  'GetChar' reads the next  character from the current input file  into the
**  variable 'STATE(Value)' and sets 'Symbol' to 'S_CHAR'.  The opening single quote
**  '\'' of the character is the current character pointed to by 'In'.
**
**  A  character is  a  single character delimited by single quotes '\''.  It
**  must not  be '\'' or <newline>, but  the escape  sequences '\\\'' or '\n'
**  can be used instead.
*/
void GetChar ( void )
{
  /* skip '\''                                                           */
  GET_CHAR();

  /* Make sure symbol is set */
  STATE(Symbol) = S_CHAR;

  /* handle escape equences                                              */
  if ( *STATE(In) == '\n' ) {
    SyntaxError("Character literal must not include <newline>");
  } else {
    if ( *STATE(In) == '\\' ) {
      GET_CHAR();
      STATE(Value)[0] = GetEscapedChar();
    } else {
      /* put normal chars into 'STATE(Value)' */
      STATE(Value)[0] = *STATE(In);
    }

    /* read the next character */
    GET_CHAR();

    /* check for terminating single quote, and skip */
    if ( *STATE(In) == '\'' ) {
      GET_CHAR();
    } else {
      SyntaxError("Missing single quote in character constant");
    }
  }
}

void GetHelp( void )
{
    Int i = 0;

    /* Skip the first ? */
    GET_CHAR();
    while (i < SAFE_VALUE_SIZE-1 &&
           *STATE(In) != '\n' &&
           *STATE(In) != '\r' &&
           *STATE(In) != '\377') {
        STATE(Value)[i] = *STATE(In);
        i++;
        GET_CHAR();
    }
    STATE(Value)[i] = '\0';
    STATE(ValueLen) = i;
}

/****************************************************************************
**
*F  GetSymbol() . . . . . . . . . . . . . . . . .  get the next symbol, local
**
**  'GetSymbol' reads  the  next symbol from   the  input,  storing it in the
**  variable 'Symbol'.  If 'Symbol' is  'S_IDENT', 'S_INT' or 'S_STRING'  the
**  value of the symbol is stored in the variable 'STATE(Value)'.  'GetSymbol' first
**  skips all <space>, <tab> and <newline> characters and comments.
**
**  After reading  a  symbol the current  character   is the first  character
**  beyond that symbol.
*/
void GetSymbol ( void )
{
    /* special case if reading of a long token is not finished */
    switch (STATE(Symbol)) {
    case S_PARTIALSTRING:     GetStr();     return;
    case S_PARTIALTRIPSTRING: GetTripStr(); return;
    case S_PARTIALINT:        GetNumber(STATE(Value)[0] == '\0' ? 0 : 1); return;
    case S_PARTIALFLOAT1:     GetNumber(2); return;
    case S_PARTIALFLOAT2:     GetNumber(3); return;
    case S_PARTIALFLOAT3:     GetNumber(4); return;
    case S_PARTIALFLOAT4:     GetNumber(5); return;
    }


  /* if no character is available then get one                           */
  if ( *STATE(In) == '\0' )
    { STATE(In)--;
      GET_CHAR();
    }

  /* skip over <spaces>, <tabs>, <newlines> and comments                 */
  while (*STATE(In)==' '||*STATE(In)=='\t'||*STATE(In)=='\n'||*STATE(In)=='\r'||*STATE(In)=='\f'||*STATE(In)=='#') {
    if ( *STATE(In) == '#' ) {
      while ( *STATE(In) != '\n' && *STATE(In) != '\r' && *STATE(In) != '\377' )
        GET_CHAR();
    }
    GET_CHAR();
  }

  /* switch according to the character                                   */
  switch ( *STATE(In) ) {

  case '.':   STATE(Symbol) = S_DOT;                         GET_CHAR();
    /*            if ( *STATE(In) == '\\' ) { GET_CHAR();
            if ( *STATE(In) == '\n' ) { GET_CHAR(); } }   */
    if ( *STATE(In) == '.' ) { 
            STATE(Symbol) = S_DOTDOT; GET_CHAR();
            if ( *STATE(In) == '.') {
                    STATE(Symbol) = S_DOTDOTDOT; GET_CHAR();
            }
    }
    break;

  case '!':   STATE(Symbol) = S_ILLEGAL;                     GET_CHAR();
    if ( *STATE(In) == '\\' ) { GET_CHAR();
      if ( *STATE(In) == '\n' ) { GET_CHAR(); } }
    if ( *STATE(In) == '.' ) { STATE(Symbol) = S_BDOT;    GET_CHAR();  break; }
    if ( *STATE(In) == '[' ) { STATE(Symbol) = S_BLBRACK; GET_CHAR();  break; }
    if ( *STATE(In) == '{' ) { STATE(Symbol) = S_BLBRACE; GET_CHAR();  break; }
    break;
  case '[':   STATE(Symbol) = S_LBRACK;                      GET_CHAR();  break;
  case ']':   STATE(Symbol) = S_RBRACK;                      GET_CHAR();  break;
  case '{':   STATE(Symbol) = S_LBRACE;                      GET_CHAR();  break;
  case '}':   STATE(Symbol) = S_RBRACE;                      GET_CHAR();  break;
  case '(':   STATE(Symbol) = S_LPAREN;                      GET_CHAR();  break;
  case ')':   STATE(Symbol) = S_RPAREN;                      GET_CHAR();  break;
  case ',':   STATE(Symbol) = S_COMMA;                       GET_CHAR();  break;

  case ':':   STATE(Symbol) = S_COLON;                       GET_CHAR();
    if ( *STATE(In) == '\\' ) {
      GET_CHAR();
      if ( *STATE(In) == '\n' )
        { GET_CHAR(); }
    }
    if ( *STATE(In) == '=' ) { STATE(Symbol) = S_ASSIGN;  GET_CHAR(); break; }
    break;

  case ';':   STATE(Symbol) = S_SEMICOLON;                   GET_CHAR();
    if ( *STATE(In) == ';' ) {
        STATE(Symbol) = S_DUALSEMICOLON; GET_CHAR();
    }
    break;

  case '=':   STATE(Symbol) = S_EQ;                          GET_CHAR();  break;
  case '<':   STATE(Symbol) = S_LT;                          GET_CHAR();
    if ( *STATE(In) == '\\' ) { GET_CHAR();
      if ( *STATE(In) == '\n' ) { GET_CHAR(); } }
    if ( *STATE(In) == '=' ) { STATE(Symbol) = S_LE;      GET_CHAR();  break; }
    if ( *STATE(In) == '>' ) { STATE(Symbol) = S_NE;      GET_CHAR();  break; }
    break;
  case '>':   STATE(Symbol) = S_GT;                          GET_CHAR();
    if ( *STATE(In) == '\\' ) { GET_CHAR();
      if ( *STATE(In) == '\n' ) { GET_CHAR(); } }
    if ( *STATE(In) == '=' ) { STATE(Symbol) = S_GE;      GET_CHAR();  break; }
    break;

  case '+':   STATE(Symbol) = S_PLUS;                        GET_CHAR();  break;
  case '-':   STATE(Symbol) = S_MINUS;                       GET_CHAR();
    if ( *STATE(In) == '\\' ) { GET_CHAR();
      if ( *STATE(In) == '\n' ) { GET_CHAR(); } }
    if ( *STATE(In) == '>' ) { STATE(Symbol)=S_MAPTO;     GET_CHAR();  break; }
    break;
  case '*':   STATE(Symbol) = S_MULT;                        GET_CHAR();  break;
  case '/':   STATE(Symbol) = S_DIV;                         GET_CHAR();  break;
  case '^':   STATE(Symbol) = S_POW;                         GET_CHAR();  break;
#ifdef HPCGAP
  case '`':   STATE(Symbol) = S_BACKQUOTE;                   GET_CHAR();  break;
#endif

  case '"':                        GET_CHAR(); GetMaybeTripStr();  break;
  case '\'':                                          GetChar();   break;
  case '\\':                                          GetIdent();  break;
  case '_':                                           GetIdent();  break;
  case '@':                                           GetIdent();  break;
  case '~':   STATE(Symbol) = S_TILDE;                GET_CHAR();  break;
  case '?':   STATE(Symbol) = S_HELP;                 GetHelp();   break;

  case '0': case '1': case '2': case '3': case '4':
  case '5': case '6': case '7': case '8': case '9':
    GetNumber(0);    break;

  case '\377': STATE(Symbol) = S_EOF;                        *STATE(In) = '\0';  break;

  default :   if ( IsAlpha(*STATE(In)) )                   { GetIdent();  break; }
    STATE(Symbol) = S_ILLEGAL;                     GET_CHAR();  break;
  }
}

static const char * AllKeywords[] = {
    "and",     "atomic",   "break",         "continue", "do",     "elif",
    "else",    "end",      "false",         "fi",       "for",    "function",
    "if",      "in",       "local",         "mod",      "not",    "od",
    "or",      "readonly", "readwrite",     "rec",      "repeat", "return",
    "then",    "true",     "until",         "while",    "quit",   "QUIT",
    "IsBound", "Unbind",   "TryNextMethod", "Info",     "Assert",
};

int IsKeyword(const char * str)
{
    for (UInt i = 0; i < ARRAY_SIZE(AllKeywords); i++) {
        if (strcmp(str, AllKeywords[i]) == 0) {
            return 1;
        }
    }
    return 0;
}

Obj FuncALL_KEYWORDS(Obj self)
{
    Obj l = NEW_PLIST(T_PLIST_EMPTY, 0);
    SET_LEN_PLIST(l,0);
    for (UInt i = 0; i < ARRAY_SIZE(AllKeywords); i++) {
        Obj s = MakeImmString(AllKeywords[i]);
        ASS_LIST(l, i+1, s);
    }
    MakeImmutable(l);
    return l;
}


static StructGVarFunc GVarFuncs [] = {
    GVAR_FUNC(ALL_KEYWORDS, 0, ""),
    { 0, 0, 0, 0, 0 }

};

/****************************************************************************
**
*F * * * * * * * * * * * * * initialize package * * * * * * * * * * * * * * *
*/

/****************************************************************************
**
*F  InitLibrary( <module> ) . . . . . . .  initialise library data structures
 */
static Int InitLibrary (
                        StructInitInfo *    module )
{
  InitGVarFuncsFromTable( GVarFuncs );
  return 0;
}

/****************************************************************************
**
*F  InitKernel( <module> )  . . . . . . . . initialise kernel data structures
*/
static Int InitKernel (
    StructInitInfo *    module )
{
    InitHdlrFuncsFromTable( GVarFuncs );
    return 0;
}

static void InitModuleState(ModuleStateOffset offset)
{
}

/****************************************************************************
**
*F  InitInfoScanner() . . . . . . . . . . . . . . . . table of init functions
*/
static StructInitInfo module = {
    // init struct using C99 designated initializers; for a full list of
    // fields, please refer to the definition of StructInitInfo
    .type = MODULE_BUILTIN,
    .name = "scanner",
    .initKernel = InitKernel,
    .initLibrary = InitLibrary,
};

StructInitInfo * InitInfoScanner ( void )
{
    RegisterModuleState(0, InitModuleState, 0);
    return &module;
}
