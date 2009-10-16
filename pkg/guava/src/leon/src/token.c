/* File token.c. */

#define  COMMENT_CHAR  '\"'
#define  ALT_COMMENT_CHAR '&'

#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "group.h"
#include "groupio.h"
#include "errmesg.h"

CHECK( token)


static FILE *inFile;              /* File to read from. */
static Unsigned lineNo;           /* Line number in file. */
static BOOLEAN bufferNonempty;    /* True if a token has been read but not
                                     returned. */
static Token tokenBuffer;         /* The token read but not returned. */
static BOOLEAN endOfFileReached;  /* True if end of file has been reached. */

static const char *inString;      /* String to read from. */
static Unsigned stringPosition;   /* First position in string not read. */
static BOOLEAN sBufferNonempty;   /* True if a token has been read from string
                                     but not returned. */
static Token sTokenBuffer;        /* The token read from string but not
                                     returned. */
static BOOLEAN endOfStringReached; /* True if end of string has been reached. */

static recognizeKeywordFlag = TRUE; /* If false, a colon is treated as an
                                       ordinary character.  Keywords are not
                                       recognized. */


/*-------------------------- lowerCase -----------------------------------*/

/* The function lowerCase(s) converts the string s to lower case and returns
   a pointer to s. */

char *lowerCase(
   char *s)
{
   Unsigned i;
   for ( i = 0 ; i < strlen(s) ; ++i )
#ifdef EBCDIC
      s[i] = ( s[i] >= 'A' && s[i] <= 'I' ||
               s[i] >= 'J' && s[i] <= 'R' ||
               s[i] >= 'S' && s[i] <= 'Z' ) ? (s[i] + 'a' - 'A') : s[i];
#else
      s[i] = (s[i] >= 'A' && s[i] <= 'Z') ? (s[i] + 'a' - 'A') : s[i];
#endif
   return s;
}


/*-------------------------- setInputFile --------------------------------*/

void setInputFile(
   FILE *newFile)
{
   inFile = newFile;
   lineNo = 1;
   endOfFileReached = FALSE;
   bufferNonempty = FALSE;
}


/*-------------------------- setInputString ------------------------------*/

void setInputString(
   const char *const newString)
{
   inString = newString;
   stringPosition = 0;
   endOfStringReached = FALSE;
   sBufferNonempty = FALSE;
}


/*-------------------------- discardThruChar --------------------------------*/

static void discardThruChar(
   Unsigned stopDiscard,
   Unsigned *lineNoPtr )
{
   Unsigned ch;
   do {
      ch = getc(inFile);
      if ( ch == '\n' )
         ++(*lineNoPtr);
   } while ( ch != '\n' && ch != stopDiscard);
}


/*-------------------------- readToken -----------------------------------*/

Token readToken( void)
{
   Token token;
   int  ch;
   Unsigned   lastPos;
   char  buffer[100];

   /* If a token has been read but not returned, return that token and exit. */
   if ( bufferNonempty ) {
      bufferNonempty = FALSE;
      return tokenBuffer;
   }

   /* If end of file has already been reached, return eof as token type. */
   if ( endOfFileReached ) {
      token.type = eof;
      return token;
   }

   /* Skip over white space, but keep track of line numbers in the file. */
   while ( (ch = getc(inFile)) == ' ' || ch == '\t' ||
           (ch == '\n' ? (++lineNo,TRUE) : FALSE)   ||
           ( (ch == COMMENT_CHAR || ch == ALT_COMMENT_CHAR) ?
                       (discardThruChar( ch, &lineNo),TRUE) : FALSE )  )
      ;

   /* This code handles keyword and identifier tokens. */
   if ( isalpha(ch) || ch == '_' ) {
      buffer[0] = ch;
      lastPos = 0;
      while ( (ch = getc(inFile)) , isalpha(ch) || isdigit(ch) || ch == '_' )
         if ( lastPos < MAX_TOKEN_LENGTH-1 )
            buffer[++lastPos] = ch;
         else
            ERROR1i( "readToken", "Token length exceed maximum of ",
                                MAX_TOKEN_LENGTH, ".")
      token.type = ( ch == ':' && recognizeKeywordFlag ) ? keyword : identifier;
      buffer[lastPos+1] = '\0';
      if ( token.type == keyword )
         strcpy( token.value.keyValue, buffer);
      else
         strcpy( token.value.identValue, buffer);
      if ( token.type == identifier)
         if ( ch != EOF )
            ungetc( ch, inFile);
         else
            endOfFileReached = TRUE;
   }

   /* This code handles integer tokens. */
   else if ( isdigit(ch) ) {
      ungetc( ch, inFile);
      if ( fscanf( inFile, SCANF_Int_FORMAT, &token.value.intValue) == 1 )
         token.type = integer;
      else
         ERROR( "readToken", "Error in reading integer token.")
   }

   /* This code handles end-of-file tokens. */
   else if ( ch == EOF ) {
       token.type = eof;
       endOfFileReached = TRUE;
   }

   /* This code handles single-character tokens. */
   else switch ( ch ) {
      case '(': token.type = leftParen; break;
      case ')': token.type = rightParen; break;
      case '[': token.type = leftBracket; break;
      case ']': token.type = rightBracket; break;
      case '<': token.type = leftAngle; break;
      case '>': token.type = rightAngle; break;
      case ';': token.type = semicolon; break;
      case '=': token.type = equal; break;
      case '*': token.type = asterisk; break;
      case '^': token.type = caret; break;
      case ',': token.type = comma; break;
      case '/': token.type = slash; break;
      case '.': token.type = period; break;
      case ':': token.type = colon; break;
      default:  token.type = other; token.value.charValue = ch;
   }

   return token;
}


/*-------------------------- nkReadToken ---------------------------------*/

Token nkReadToken(void)
{
   Token token;

   recognizeKeywordFlag = FALSE;
   token = readToken();
   if ( token.type == identifier )
      lowerCase( token.value.identValue);
   recognizeKeywordFlag = TRUE;
   return token;
}


/*-------------------------- sReadToken ----------------------------------*/

Token sReadToken( void)
{
   Token token;
   char  ch;
   Unsigned lastPos;
   char  sBuffer[100];

   /* If a token has been read but not returned, return that token and exit. */
   if ( sBufferNonempty ) {
      sBufferNonempty = FALSE;
      return sTokenBuffer;
   }

   /* If end of string has already been reached, return eof as token type. */
   if ( endOfStringReached ) {
      token.type = eof;
      return token;
   }

   /* Skip over white space, but keep track of line numbers in the file. */
   while ( (ch = inString[stringPosition++]) == ' ' || ch == '\t' ||
            ch == '\n' )
      ;

   /* This code handles keyword and identifier tokens. */
   if ( isalpha(ch) || ch == '_' ) {
      sBuffer[0] = ch;
      lastPos = 0;
      while ( (ch = inString[stringPosition++]) , isalpha(ch) || isdigit(ch) ||
                                                  ch == '_' )
         if ( lastPos < MAX_TOKEN_LENGTH-1 )
            sBuffer[++lastPos] = ch;
         else
            ERROR1i( "sReadToken", "Token length exceed maximum of ",
                                MAX_TOKEN_LENGTH, ".")
      token.type = ( ch == ':' && recognizeKeywordFlag ) ? keyword : identifier;
      sBuffer[lastPos+1] = '\0';
      if ( token.type == keyword )
         strcpy( token.value.keyValue, sBuffer);
      else
         strcpy( token.value.identValue, sBuffer);
      if ( token.type == identifier)
         if ( ch != '\0' )
            --stringPosition;
         else
            endOfStringReached = TRUE;
   }

   /* This code handles integer tokens. */
   else if ( isdigit(ch) ) {
      --stringPosition;
      if ( sscanf( inString+stringPosition, SCANF_Int_FORMAT,
                   &token.value.intValue) == 1 ) {
         token.type = integer;
         while ( isdigit( inString[++stringPosition]) )
            ;
      }
      else
         ERROR( "sReadToken", "Error in reading integer token.")
   }

   /* This code handles end-of-string tokens. */
   else if ( ch == '\0' ) {
       token.type = eof;
       endOfStringReached = TRUE;
   }

   /* This code handles single-character tokens. */
   else switch ( ch ) {
      case '(': token.type = leftParen; break;
      case ')': token.type = rightParen; break;
      case '[': token.type = leftBracket; break;
      case ']': token.type = rightBracket; break;
      case '<': token.type = leftAngle; break;
      case '>': token.type = rightAngle; break;
      case ';': token.type = semicolon; break;
      case '=': token.type = equal; break;
      case '*': token.type = asterisk; break;
      case '^': token.type = caret; break;
      case ',': token.type = comma; break;
      case '/': token.type = slash; break;
      case '.': token.type = period; break;
      case ':': token.type = colon; break;
      default:  token.type = other; token.value.charValue = ch;
   }

   return token;
}


/*-------------------------- unreadToken ---------------------------------*/

void unreadToken(
   Token tokenToUnread)
{
   tokenBuffer = tokenToUnread;
   bufferNonempty = TRUE;
}


/*-------------------------- sUnreadToken --------------------------------*/

void sUnreadToken(
   Token tokenToUnread)
{
   sTokenBuffer = tokenToUnread;
   sBufferNonempty = TRUE;
}
