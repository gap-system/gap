#ifndef GROUPIO
#define GROUPIO

#define MAX_TOKEN_LENGTH 32

typedef enum {
   keyword, identifier, integer, floatingPt, leftParen, rightParen, leftBracket,
   rightBracket, leftAngle, rightAngle, semicolon, equal, asterisk, caret,
   comma, slash, period, colon, other, eof
} TokenType;

typedef struct {
   TokenType type;
   union {
      char keyValue[MAX_TOKEN_LENGTH+1];
      char identValue[MAX_TOKEN_LENGTH+1];
      Unsigned  intValue;
      char charValue;
   } value;
} Token;

#endif
