/****************************************************************************
**
**  This file is part of GAP, a system for computational discrete algebra.
**
**  Copyright of GAP belongs to its developers, whose names are too numerous
**  to list here. Please refer to the COPYRIGHT file for details.
**
**  SPDX-License-Identifier: GPL-2.0-or-later
**
**  This file contains the functions of the scanner, which provides a very
**  important abstraction, namely the concept that an input file is a stream
**  of symbols, while it hides such nasty things as <space>, <tab>, <newline>
**  characters, comments (they are worst :-), characters making up
**  identifiers or digits that make up integers from the rest of GAP.
*/

#include "scanner.h"

#include "error.h"
#include "gapstate.h"
#include "gaputils.h"
#include "io.h"
#include "lists.h"
#include "plist.h"
#include "stringobj.h"
#include "sysstr.h"


static UInt NextSymbol(ScannerState * s);

#define GET_NEXT_CHAR() GetNextChar(s->input)

/****************************************************************************
**
*F  SyntaxErrorOrWarning( <msg> ) . . . . . . raise a syntax error or warning
**
**  Helper function used by 'SyntaxError' and 'SyntaxWarning'.
**
*/
static void SyntaxErrorOrWarning(ScannerState * s,
                                 const Char *   msg,
                                 UInt           error,
                                 Int            tokenoffset)
{
    GAP_ASSERT(tokenoffset >= 0 && tokenoffset <= 2);
    // do not print a message if we found one already on the current line
    if (s->input->lastErrorLine != s->input->number) {

        // open error output
        TypOutputFile output = { 0 };
        OpenErrorOutput(&output);

        // print the message ...
        if (error)
            Pr("Syntax error: %s", (Int)msg, 0);
        else
            Pr("Syntax warning: %s", (Int)msg, 0);

        // ... and the filename + line, unless it is '*stdin*'
        if (!streq("*stdin*", GetInputFilename(s->input)))
            Pr(" in %s:%d", (Int)GetInputFilename(s->input),
               GetInputLineNumber(s->input));
        Pr("\n", 0, 0);

        // print the current line
        const char * line = GetInputLineBuffer(s->input);
        const UInt len = strlen(line);
        if (len > 0 && line[len-1] != '\n')
            Pr("%s\n", (Int)line, 0);
        else
            Pr("%s", (Int)line, 0);

        // print a '^' pointing to the current position
        Int startPos = s->SymbolStartPos[tokenoffset];
        Int pos;
        if (tokenoffset == 0)
            pos = GetInputLinePosition(s->input);
        else
            pos = s->SymbolStartPos[tokenoffset - 1];

        if (s->SymbolStartLine[tokenoffset] != GetInputLineNumber(s->input)) {
            startPos = 1;
            pos = GetInputLinePosition(s->input);
        }

        if (0 < pos && startPos <= pos) {
            Int i;
            for (i = 0; i < startPos; i++) {
                if (line[i] == '\t')
                    Pr("\t", 0, 0);
                else
                    Pr(" ", 0, 0);
            }

            for (; i < pos; i++)
                Pr("^", 0, 0);
            Pr("\n", 0, 0);
        }

        // close error output
        CloseOutput(&output);
    }

    if (error) {
        // one more error
        s->NrError++;
        s->input->lastErrorLine = s->input->number;
    }
}


/****************************************************************************
**
*F  SyntaxError( <msg> ) . . . . . . . . . . . . . . . . raise a syntax error
**
*/
void SyntaxErrorWithOffset(ScannerState * s,
                           const Char *   msg,
                           Int            tokenoffset)
{
    SyntaxErrorOrWarning(s, msg, 1, tokenoffset);
}

/****************************************************************************
**
*F  SyntaxWarning( <msg> ) . . . . . . . . . . . . . . raise a syntax warning
**
*/
void SyntaxWarningWithOffset(ScannerState * s,
                             const Char *   msg,
                             Int            tokenoffset)
{
    SyntaxErrorOrWarning(s, msg, 0, tokenoffset);
}


/****************************************************************************
**
*F  AppendBufToString()
**
**  Append 'bufsize' bytes from the string buffer 'buf' to the string object
**  'string'. If 'string' is 0, then a new string object is allocated first.
**
**  The string object is returned at the end, regardless of whether it was
**  given as an argument, or created from scratch.
**
*/
static Obj AppendBufToString(Obj string, const char * buf, UInt bufsize)
{
    char *s;
    if (string == 0) {
        string = NEW_STRING(bufsize);
        s = CSTR_STRING(string);
    }
    else {
        const UInt len = GET_LEN_STRING(string);
        GROW_STRING(string, len + bufsize);
        SET_LEN_STRING(string, len + bufsize);
        s = CSTR_STRING(string) + len;
    }
    memcpy(s, buf, bufsize);
    s[bufsize] = '\0';
    return string;
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
           TypSymbolSet   skipto)
{
    Char                errmsg [256];

    // if 's->Symbol' is the expected symbol match it away
    if (symbol == s->Symbol) {
        s->Symbol = NextSymbol(s);
    }

    /* else generate an error message and skip to a symbol in <skipto>     */
    else {
        gap_strlcpy( errmsg, msg, sizeof(errmsg) );
        gap_strlcat( errmsg, " expected", sizeof(errmsg) );
        SyntaxError(s, errmsg);
        while (!IS_IN(s->Symbol, skipto))
            s->Symbol = NextSymbol(s);
    }
}


/****************************************************************************
**
*F  GetIdent()  . . . . . . . . . . . . . get an identifier or keyword, local
**
**  'GetIdent' reads   an identifier from  the current  input  file  into the
**  variable 's->Value' and sets 'Symbol' to 'S_IDENT'. The first
**  character of the identifier is the current character pointed to by 'In'.
**  If the characters make up a keyword 'GetIdent' will set 'Symbol' to the
**  corresponding value. The parser will ignore 's->Value' in this case.
**
**  An identifier consists of a letter followed by more letters, digits and
**  underscores '_'. An identifier is terminated by the first character not
**  in this class. The backslash '\' can be used to include special
**  characters like '(' in identifiers. For example 'G\(2\,5\)' is an
**  identifier not a call to a function 'G'.
**
**  The size of 's->Value' limits the number of significant characters in
**  an identifier. If an identifier has more characters 'GetIdent' truncates
**  it and signal a syntax error.
**
**  After reading the identifier 'GetIdent'  looks at the  first and the last
**  character of 's->Value' to see if it could possibly be a keyword. For
**  example 'test'  could  not be  a  keyword  because there  is  no  keyword
**  starting and ending with a 't'.  After that  test either 'GetIdent' knows
**  that 's->Value' is not a keyword, or there is a unique possible
**  keyword that could match, because no two keywords have identical first
**  and last characters. For example if 's->Value' starts with 'f' and
**  ends with 'n' the only possible keyword is 'function'. Thus in this case
**  'GetIdent' can decide with one string comparison if 's->Value' holds
**  a keyword or not.
*/
static UInt GetIdent(ScannerState * s, Int i, Char c)
{
    // initially it could be a keyword
    Int isQuoted = 0;

    // read all characters into 's->Value'
    for (; IsIdent(c) || c == '\\'; i++) {

        // handle escape sequences
        if (c == '\\') {
            c = GET_NEXT_CHAR();
            switch(c) {
            case 'n': c = '\n'; break;
            case 't': c = '\t'; break;
            case 'r': c = '\r'; break;
            case 'b': c = '\b'; break;
            default:
                isQuoted = 1;
            }
        }

        /// put char into 's->Value' but only if there is room
        if (i < MAX_VALUE_LEN - 1)
            s->Value[i] = c;

        // read the next character
        c = GET_NEXT_CHAR();
    }

    // reject overlong identifiers
    if (i > MAX_VALUE_LEN - 1) {
        SyntaxError(
            s, "Identifiers in GAP must consist of at most 1023 characters.");
        i = MAX_VALUE_LEN - 1;
    }

    // terminate the identifier
    s->Value[i] = '\0';

    // if it is quoted then it is not a keyword
    if (isQuoted)
        return S_IDENT;

    // now check if 's->Value' holds a keyword
    const Char * v = s->Value;
    switch ( 256*v[0]+v[i-1] ) {
    case 256*'a'+'d': if(streq(v,"and"))           return S_AND;
    case 256*'a'+'c': if(streq(v,"atomic"))        return S_ATOMIC;
    case 256*'b'+'k': if(streq(v,"break"))         return S_BREAK;
    case 256*'c'+'e': if(streq(v,"continue"))      return S_CONTINUE;
    case 256*'d'+'o': if(streq(v,"do"))            return S_DO;
    case 256*'e'+'f': if(streq(v,"elif"))          return S_ELIF;
    case 256*'e'+'e': if(streq(v,"else"))          return S_ELSE;
    case 256*'e'+'d': if(streq(v,"end"))           return S_END;
    case 256*'f'+'e': if(streq(v,"false"))         return S_FALSE;
    case 256*'f'+'i': if(streq(v,"fi"))            return S_FI;
    case 256*'f'+'r': if(streq(v,"for"))           return S_FOR;
    case 256*'f'+'n': if(streq(v,"function"))      return S_FUNCTION;
    case 256*'i'+'f': if(streq(v,"if"))            return S_IF;
    case 256*'i'+'n': if(streq(v,"in"))            return S_IN;
    case 256*'l'+'l': if(streq(v,"local"))         return S_LOCAL;
    case 256*'m'+'d': if(streq(v,"mod"))           return S_MOD;
    case 256*'n'+'t': if(streq(v,"not"))           return S_NOT;
    case 256*'o'+'d': if(streq(v,"od"))            return S_OD;
    case 256*'o'+'r': if(streq(v,"or"))            return S_OR;
    case 256*'r'+'e': if(streq(v,"readwrite"))     return S_READWRITE;
    case 256*'r'+'y': if(streq(v,"readonly"))      return S_READONLY;
    case 256*'r'+'c': if(streq(v,"rec"))           return S_REC;
    case 256*'r'+'t': if(streq(v,"repeat"))        return S_REPEAT;
    case 256*'r'+'n': if(streq(v,"return"))        return S_RETURN;
    case 256*'t'+'n': if(streq(v,"then"))          return S_THEN;
    case 256*'t'+'e': if(streq(v,"true"))          return S_TRUE;
    case 256*'u'+'l': if(streq(v,"until"))         return S_UNTIL;
    case 256*'w'+'e': if(streq(v,"while"))         return S_WHILE;
    case 256*'q'+'t': if(streq(v,"quit"))          return S_QUIT;
    case 256*'Q'+'T': if(streq(v,"QUIT"))          return S_QQUIT;
    case 256*'I'+'d': if(streq(v,"IsBound"))       return S_ISBOUND;
    case 256*'U'+'d': if(streq(v,"Unbind"))        return S_UNBIND;
    case 256*'T'+'d': if(streq(v,"TryNextMethod")) return S_TRYNEXT;
    case 256*'I'+'o': if(streq(v,"Info"))          return S_INFO;
    case 256*'A'+'t': if(streq(v,"Assert"))        return S_ASSERT;
    }

    return S_IDENT;
}


/****************************************************************************
**
*F  GetNumber()  . . . . . . . . . . . . . .  get an integer or float literal
**
**  'GetNumber' reads a number from the current input file into the variable
**  's->Value' or 's->ValueObj' and sets 's->Symbol' to 'S_INT' or
**  'S_FLOAT'. The first character of the number is the current character
**  pointed to by 'In'.
**
**  If the sequence contains characters which do not match the regular
**  expression [0-9]+.?[0-9]*([edqEDQ][+-]?[0-9]+)? 'GetNumber'  will
**  interpret the sequence as an identifier by delegating to 'GetIdent'.
**
**  As we read, we keep track of whether we have seen a . or exponent
**  notation and so whether we will return 'S_INT' or 'S_FLOAT'.
**
**  When 's->Value' is completely filled, then a GAP string object is
**  created in 's->ValueObj' and all data is stored there.
**
**  The argument is used to signal if a decimal point was already read,
**  or whether we are starting from scratch..
**
*/
static UInt AddCharToBuf(Obj * string, Char * buf, UInt bufsize, UInt pos, Char c)
{
    if (pos >= bufsize) {
        *string = AppendBufToString(*string, buf, pos);
        pos = 0;
    }
    buf[pos++] = c;
    return pos;
}

static UInt AddCharToValue(ScannerState * s, UInt pos, Char c)
{
    return AddCharToBuf(&s->ValueObj, s->Value, MAX_VALUE_LEN - 1, pos, c);
}

static UInt GetNumber(ScannerState * s, Int readDecimalPoint, Char c)
{
    UInt symbol = S_ILLEGAL;
    UInt i = 0;
    BOOL seenADigit = FALSE;

    s->ValueObj = 0;

    if (readDecimalPoint) {
        s->Value[i++] = '.';
    }
    else {
        // read initial sequence of digits into 'Value'
        while (IsDigit(c)) {
            i = AddCharToValue(s, i, c);
            seenADigit = TRUE;
            c = GET_NEXT_CHAR();
        }

        // maybe we saw an identifier character and realised that this is an
        // identifier we are reading
        if (IsIdent(c) || c == '\\') {
            // if necessary, copy back from s->ValueObj to s->Value
            if (s->ValueObj) {
                i = GET_LEN_STRING(s->ValueObj);
                GAP_ASSERT(i >= MAX_VALUE_LEN - 1);
                memcpy(s->Value, CONST_CSTR_STRING(s->ValueObj),
                       MAX_VALUE_LEN);
                s->ValueObj = 0;
            }
            // this looks like an identifier, scan the rest of it
            return GetIdent(s, i, c);
        }

        // Or maybe we saw a '.' which could indicate one of three things:
        // - a float literal: 12.345
        // - S_DOT, i.e., '.' used to access a record entry: r.12.345
        // - S_DDOT, i.e., '..' in a range expression:  [12..345]
        if (c == '.') {
            GAP_ASSERT(i < MAX_VALUE_LEN - 1);

            // If the symbol before this integer was S_DOT then we must be in
            // a nested record element expression, so don't look for a float.
            // This is a bit fragile
            if (s->Symbol == S_DOT || s->Symbol == S_BDOT) {
                symbol = S_INT;
                goto finish;
            }

            // peek ahead to decide if we are looking at a range expression
            if (PEEK_NEXT_CHAR(s->input) == '.') {
                // we are looking at '..' and are probably inside a range
                // expression
                symbol = S_INT;
                goto finish;
            }

            // Now the '.' must be part of our number; store it and move on
            i = AddCharToValue(s, i, '.');
            c = GET_NEXT_CHAR();
        }
        else {
            // Anything else we see tells us that the token is done
            symbol = S_INT;
            goto finish;
        }
    }

    // When we get here we have read possibly some digits, a . and possibly
    // some more digits, but not an e,E,d,D,q or Q
    // In any case, from now on, we know we are dealing with a float literal
    symbol = S_FLOAT;

    // read digits
    while (IsDigit(c)) {
        i = AddCharToValue(s, i, c);
        seenADigit = TRUE;
        c = GET_NEXT_CHAR();
    }
    if (!seenADigit)
        SyntaxError(s,
                    "Badly formed number: need a digit before or after the "
                    "decimal point");
    if (c == '\\')
        SyntaxError(s, "Badly formed number");

    // If the next thing is the start of the exponential notation, read it
    // now.
    if (c == 'e' || c == 'E' || c == 'd' || c == 'D' || c == 'q' ||
        c == 'Q') {
        i = AddCharToValue(s, i, c);
        c = GET_NEXT_CHAR();
        if (c == '+' || c == '-') {
            i = AddCharToValue(s, i, c);
            c = GET_NEXT_CHAR();
        }

        // Here we are into the unsigned exponent of a number in scientific
        // notation, so we just read digits
        if (!IsDigit(c))
            SyntaxError(s, "Badly formed number: need at least one digit in "
                           "the exponent");
        while (IsDigit(c)) {
            i = AddCharToValue(s, i, c);
            c = GET_NEXT_CHAR();
        }
    }

    // Allow one letter at the end of the number, which is a conversion
    // marker; e.g. an `i` as in C99, to indicate an imaginary value.
    if (IsAlpha(c)) {
        i = AddCharToValue(s, i, c);
        c = GET_NEXT_CHAR();
    }

    // independently of that, we allow an _ signalling immediate or "eager"
    // conversion
    if (c == '_') {
        i = AddCharToValue(s, i, c);
        c = GET_NEXT_CHAR();
        // After which there may be one character signifying the
        // conversion styles
        if (IsAlpha(c)) {
            i = AddCharToValue(s, i, c);
            c = GET_NEXT_CHAR();
        }
    }

    // Now if the next character is an identifier symbol then we have an error
    if (IsIdent(c)) {
        SyntaxError(s, "Badly formed number");
    }

finish:
    i = AddCharToValue(s, i, '\0');
    if (s->ValueObj) {
        // flush buffer
        AppendBufToString(s->ValueObj, s->Value, i - 1);
    }
    return symbol;
}


/****************************************************************************
**
*F  ScanForFloatAfterDotHACK()
**
*/
void ScanForFloatAfterDotHACK(ScannerState * s)
{
    s->Symbol = GetNumber(s, 1, PEEK_CURR_CHAR(s->input));
}


/****************************************************************************
**
*F  GetOctalDigits()
**
*/
static inline Char GetOctalDigits(ScannerState * s, Char c)
{
    GAP_ASSERT('0' <= c && c <= '7');
    Char result;
    result = 8 * (c - '0');
    c = GET_NEXT_CHAR();
    if ( c < '0' || c > '7' )
        SyntaxError(s, "Expecting octal digit");
    result = result + (c - '0');

    return result;
}


/****************************************************************************
**
*F  CharHexDigit( <ch> ) . . . . . . . . .  turn a single hex digit into Char
**
*/
static inline Char CharHexDigit(ScannerState * s)
{
    Char c = GET_NEXT_CHAR();
    if (!isxdigit((unsigned int)c)) {
        SyntaxError(s, "Expecting hexadecimal digit");
    }
    if (c >= 'a') {
        return (c - 'a' + 10);
    } else if (c >= 'A') {
        return (c - 'A' + 10);
    } else {
        return (c - '0');
    }
}


/****************************************************************************
**
*F  GetEscapedChar() . . . . . . . . . . . . . . . . get an escaped character
**
**  'GetEscapedChar' reads an escape sequence from the current input file
**  into the variable *dst.
**
*/
static Char GetEscapedChar(ScannerState * s)
{
  Char result = 0;
  Char c = GET_NEXT_CHAR();

  if ( c == 'n'  )       result = '\n';
  else if ( c == 't'  )  result = '\t';
  else if ( c == 'r'  )  result = '\r';
  else if ( c == 'b'  )  result = '\b';
  else if ( c == '>'  )  result = '\01';
  else if ( c == '<'  )  result = '\02';
  else if ( c == 'c'  )  result = '\03';
  else if ( c == '"'  )  result = '"';
  else if ( c == '\\' )  result = '\\';
  else if ( c == '\'' )  result = '\'';
  else if ( c == '0'  ) {
    /* from here we can either read a hex-escape or three digit
       octal numbers */
    c = GET_NEXT_CHAR();
    if (c == 'x') {
        result = 16 * CharHexDigit(s);
        result += CharHexDigit(s);
    } else if (c >= '0' && c <= '7') {
        result += GetOctalDigits(s, c);
    } else {
        SyntaxError(s, "Expecting hexadecimal escape, or two more octal digits");
    }
  } else if ( c >= '1' && c <= '7' ) {
    /* escaped three digit octal numbers are allowed in input */
    result = 64 * (c - '0');
    c = GET_NEXT_CHAR();
    result += GetOctalDigits(s, c);
  } else {
      /* Following discussions on pull-request #612, this warning is currently
         disabled for backwards compatibility; some code relies on this behaviour
         and tests break with the warning enabled */
      /*
      if (IsAlpha(c))
          SyntaxWarning(s, "Alphabet letter after \\");
      */
      result = c;
  }
  return result;
}


/****************************************************************************
**
*F  GetStr()  . . . . . . . . . . . . . . . . . . . . .  get a string, local
**
**  'GetStr' reads  a  string from the  current input file into  the variable
**  's->ValueObj' and sets 'Symbol' to  'S_STRING'. The opening double
**  quote '"' of the string is the current character pointed to by 'In'.
**
**  A string is a sequence of characters delimited  by double quotes '"'.  It
**  must not include  '"' or <newline>  characters, but the  escape sequences
**  '\"' or '\n' can  be used instead.  The  escape sequence  '\<newline>' is
**  ignored, making it possible to split long strings over multiple lines.
**
**  An error is raised if the string includes a <newline> character or if the
**  file ends before the closing '"'.
*/
static Char GetStr(ScannerState * s, Char c)
{
    Obj  string = 0;
    Char buf[1024];
    UInt i = 0;

    while (c != '"' && c != '\n' && c != '\377') {
        if (c == '\\') {
            c = GetEscapedChar(s);
        }
        i = AddCharToBuf(&string, buf, sizeof(buf), i, c);

        // read the next character
        c = GET_NEXT_CHAR();
    }

    // append any remaining data to s->ValueObj
    s->ValueObj = AppendBufToString(string, buf, i);

    if (c == '\n')
        SyntaxError(s, "String must not include <newline>");

    if (c == '\377') {
        FlushRestOfInputLine(s->input);
        SyntaxError(s, "String must end with \" before end of file");
    }

    return c;
}


static void GetPragma(ScannerState * s, Char c)
{
    Obj  string = 0;
    Char buf[1024];
    UInt i = 0;

    while ( c != '\n' && c != '\r' && c != '\377') {
        i = AddCharToBuf(&string, buf, sizeof(buf), i, c);

        // read the next character
        c = GET_NEXT_CHAR();
    }

    // append any remaining data to s->ValueObj
    s->ValueObj = AppendBufToString(string, buf, i);

    if (c == '\377') {
        FlushRestOfInputLine(s->input);
    }
}


/****************************************************************************
**
*F  GetTripStr() . . . . . . . . . . . . .  get a triple quoted string, local
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
*/
static Char GetTripStr(ScannerState * s, Char c)
{
    Obj  string = 0;
    Char buf[1024];
    UInt i = 0;

    // print only a partial prompt while reading a triple string
    SetPrompt("> ");

    while (c != '\377') {
        // only thing to check for is a triple quote
        if (c == '"') {
            c = GET_NEXT_CHAR();
            if (c == '"') {
                c = GET_NEXT_CHAR();
                if (c == '"') {
                    break;
                }
                i = AddCharToBuf(&string, buf, sizeof(buf), i, '"');
            }
            i = AddCharToBuf(&string, buf, sizeof(buf), i, '"');
        }
        i = AddCharToBuf(&string, buf, sizeof(buf), i, c);

        // read the next character
        c = GET_NEXT_CHAR();
    }

    // append any remaining data to s->ValueObj
    s->ValueObj = AppendBufToString(string, buf, i);

    if (c == '\377') {
        FlushRestOfInputLine(s->input);
        SyntaxError(s, "String must end with \"\"\" before end of file");
    }

    return c;
}

/****************************************************************************
**
*F  GetString()  . . . . . . . . . . . . . . . . . . . .  get a string, local
**
**  'GetString' decides if we are reading a single quoted string, or a triple
**  quoted string, and then reads it. The opening quote '"' of the string is
**  the current character pointed to by 'In'.
*/
static void GetString(ScannerState * s)
{
    Int  isTripleQuoted = 0;
    Char c = GET_NEXT_CHAR();

    if (c == '"') {
        c = GET_NEXT_CHAR();
        if (c == '"') {
            isTripleQuoted = 1;
            c = GET_NEXT_CHAR();
        }
        else {
            // we read two '"' followed by something else, so this was
            // just an empty string!
            s->ValueObj = NEW_STRING(0);
            return;
        }
    }

    c = isTripleQuoted ? GetTripStr(s, c) : GetStr(s, c);

    // skip trailing '"'
    if (c == '"')
        c = GET_NEXT_CHAR();
}


/****************************************************************************
**
*F  GetChar() . . . . . . . . . . . . . . . . . get a single character, local
**
**  'GetChar' reads the next  character from the current input file  into the
**  variable 's->Value' and sets 'Symbol' to 'S_CHAR'.  The opening single quote
**  '\'' of the character is the current character pointed to by 'In'.
**
**  A  character is  a  single character delimited by single quotes '\''.  It
**  must not  be '\'' or <newline>, but  the escape  sequences '\\\'' or '\n'
**  can be used instead.
*/
static void GetChar(ScannerState * s)
{
  /* skip '\''                                                           */
  Char c = GET_NEXT_CHAR();

  /* handle escape equences                                              */
  if ( c == '\n' ) {
    SyntaxError(s, "Character literal must not include <newline>");
  } else {
    if ( c == '\\' ) {
      s->Value[0] = GetEscapedChar(s);
    } else {
      /* put normal chars into 's->Value' */
      s->Value[0] = c;
    }

    /* read the next character */
    c = GET_NEXT_CHAR();

    /* check for terminating single quote, and skip */
    if ( c == '\'' ) {
      c = GET_NEXT_CHAR();
    } else {
      SyntaxError(s, "Missing single quote in character constant");
    }
  }
}

static void GetHelp(ScannerState * s)
{
    Obj  string = 0;
    Char buf[1024];
    UInt i = 0;

    // Skip the leading '?'
    Char c = GET_NEXT_CHAR();

    while (c != '\n' && c != '\r' && c != '\377') {
        i = AddCharToBuf(&string, buf, sizeof(buf), i, c);
        c = GET_NEXT_CHAR();
    }

    // append any remaining data to s->ValueObj
    s->ValueObj = AppendBufToString(string, buf, i);
}


/****************************************************************************
**
*F  StoreSymbolPosition()
**
**  Store the current position in the input stream, for use in error and
**  warning messages. A sequence of positions is stored, which record the start
**  and end of each symbol.
*/
static void StoreSymbolPosition(ScannerState * s)
{
    s->SymbolStartLine[2] = s->SymbolStartLine[1];
    s->SymbolStartPos[2] = s->SymbolStartPos[1];
    s->SymbolStartLine[1] = s->SymbolStartLine[0];
    s->SymbolStartPos[1] = s->SymbolStartPos[0];
    s->SymbolStartLine[0] = GetInputLineNumber(s->input);
    s->SymbolStartPos[0] = GetInputLinePosition(s->input);
}


/****************************************************************************
**
*F  NextSymbol() . . . . . . . . . . . . . . . . . get the next symbol, local
**
**  'NextSymbol' reads  the  next symbol from  the  input,  storing it in the
**  variable 's->Symbol'. If 's->Symbol' is 'S_IDENT', 'S_INT',
**  'S_FLOAT' or 'S_STRING' the value of the symbol is stored in
**  's->Value' or  's->ValueObj'. 'NextSymbol' first skips all
**  <space>, <tab> and <newline> characters and comments.
**
**  After reading  a  symbol the current  character   is the first  character
**  beyond that symbol.
*/
static UInt NextSymbol(ScannerState * s)
{
    GAP_ASSERT(s->input == GetCurrentInput());

    // Record end of previous symbol's position
    StoreSymbolPosition(s);

    Char c = PEEK_CURR_CHAR(s->input);

    // skip over <spaces>, <tabs>, <newlines> and comments
    while (c == ' ' || c == '\t' || c== '\n' || c== '\r' || c == '\f' || c=='#') {
        if (c == '#') {
            c = GET_NEXT_CHAR_NO_LC(s->input);
            if (c == '%') {
                // we have encountered a pragma
                GetPragma(s, c);
                return S_PRAGMA;
            }

            SKIP_TO_END_OF_LINE(s->input);
        }
        c = GET_NEXT_CHAR();
    }

    // Record start of this symbol's position
    StoreSymbolPosition(s);

    // switch according to the character
    if (IsAlpha(c)) {
        return GetIdent(s, 0, c);
    }

    UInt symbol;

    switch (c) {
    case '.':         symbol = S_DOT;           c = GET_NEXT_CHAR();
      if (c == '.') { symbol = S_DOTDOT;        c = GET_NEXT_CHAR();
          if (c == '.') { symbol = S_DOTDOTDOT; c = GET_NEXT_CHAR(); }
      }
      break;

    case '!':         symbol = S_ILLEGAL;       c = GET_NEXT_CHAR();
      if (c == '.') { symbol = S_BDOT;              GET_NEXT_CHAR(); break; }
      if (c == '[') { symbol = S_BLBRACK;           GET_NEXT_CHAR(); break; }
      break;
    case '[':         symbol = S_LBRACK;            GET_NEXT_CHAR(); break;
    case ']':         symbol = S_RBRACK;            GET_NEXT_CHAR(); break;
    case '{':         symbol = S_LBRACE;            GET_NEXT_CHAR(); break;
    case '}':         symbol = S_RBRACE;            GET_NEXT_CHAR(); break;
    case '(':         symbol = S_LPAREN;            GET_NEXT_CHAR(); break;
    case ')':         symbol = S_RPAREN;            GET_NEXT_CHAR(); break;
    case ',':         symbol = S_COMMA;             GET_NEXT_CHAR(); break;

    case ':':         symbol = S_COLON;         c = GET_NEXT_CHAR();
      if (c == '=') { symbol = S_ASSIGN;            GET_NEXT_CHAR(); break; }
      break;

    case ';':         symbol = S_SEMICOLON;     c = GET_NEXT_CHAR();
      if (c == ';') { symbol = S_DUALSEMICOLON;     GET_NEXT_CHAR(); break; }
      break;

    case '=':         symbol = S_EQ;                GET_NEXT_CHAR(); break;
    case '<':         symbol = S_LT;            c = GET_NEXT_CHAR();
      if (c == '=') { symbol = S_LE;                GET_NEXT_CHAR(); break; }
      if (c == '>') { symbol = S_NE;                GET_NEXT_CHAR(); break; }
      break;
    case '>':         symbol = S_GT;            c = GET_NEXT_CHAR();
      if (c == '=') { symbol = S_GE;                GET_NEXT_CHAR(); break; }
      break;

    case '+':         symbol = S_PLUS;              GET_NEXT_CHAR(); break;
    case '-':         symbol = S_MINUS;         c = GET_NEXT_CHAR();
      if (c == '>') { symbol = S_MAPTO;             GET_NEXT_CHAR(); break; }
      break;
    case '*':         symbol = S_MULT;              GET_NEXT_CHAR(); break;
    case '/':         symbol = S_DIV;               GET_NEXT_CHAR(); break;
    case '^':         symbol = S_POW;               GET_NEXT_CHAR(); break;

    case '~':         symbol = S_TILDE;             GET_NEXT_CHAR(); break;
    case '?':         symbol = S_HELP;              GetHelp(s); break;
    case '"':         symbol = S_STRING;            GetString(s); break;
    case '\'':        symbol = S_CHAR;              GetChar(s); break;
    case '\\':        return GetIdent(s, 0, c);
    case '_':         return GetIdent(s, 0, c);
    case '@':         return GetIdent(s, 0, c);

    case '0': case '1': case '2': case '3': case '4':
    case '5': case '6': case '7': case '8': case '9':
                      return GetNumber(s, 0, c);

    case '\377':      symbol = S_EOF;  FlushRestOfInputLine(s->input); break;

    default:          symbol = S_ILLEGAL;       GET_NEXT_CHAR(); break;
    }
    return symbol;
}
