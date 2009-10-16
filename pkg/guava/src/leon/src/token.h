#ifndef TOKEN
#define TOKEN

extern char *lowerCase(
   char *s)
;

extern void setInputFile(
   FILE *newFile)
;

extern void setInputString(
   const char *const newString)
;

extern Token readToken( void)
;

extern Token nkReadToken(void)
;

extern Token sReadToken( void)
;

extern void unreadToken(
   Token tokenToUnread)
;

extern void sUnreadToken(
   Token tokenToUnread)
;

#endif
