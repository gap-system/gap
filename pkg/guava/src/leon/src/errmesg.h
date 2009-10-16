#ifndef ERRMESG
#define ERRMESG

extern BOOLEAN isValidName(
   char *name)               /* The name to be checked for validity. */
;

extern void errorMessage(
   char *file,               /* The file in which the error occured. */
   int  line,                /* The line before which the error occured. */
   char *function,           /* The function in which the error occured. */
   char *message)            /* The message to be printed.  It will be
                                prefixed by "Error: ". */
;

extern void errorMessage1i(
   char *file,               /* The file in which the error occured. */
   int  line,                /* The line before which the error occured. */
   char *function,           /* The function in which the error occured. */
   char *message1,           /* The first part of the error message. */
   Unsigned intParm,         /* The integer variable part of the message. */
   char *message2)           /* The second part of the error message. */
;

extern void errorMessage1s(
   char *file,               /* The file in which the error occured. */
   int  line,                /* The line before which the error occured. */
   char *function,           /* The function in which the error occured. */
   char *message1,           /* The first part of the error message. */
   char *strParm,            /* The integer variable part of the message. */
   char *message2)           /* The second part of the error message. */
;

#endif
