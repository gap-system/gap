/* File errmesg.c.  Contains function errorMessage that is invoked when an
   error occurs.  It prints a message and terminates the program. */

#include "group.h"

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

CHECK( errmes)


/*-------------------------- isValidName ----------------------------------*/

BOOLEAN isValidName(
   char *name)               /* The name to be checked for validity. */
{
   Unsigned i;

   if ( strlen(name) > MAX_NAME_LENGTH )
      return FALSE;
   if ( !isalpha(name[0]) && name[0] != '_' )
      return FALSE;
   for ( i = 1 ; i < strlen(name) ; ++i )
      if ( !isalnum(name[i]) && name[i] != '_' )
         return FALSE;
   return TRUE;
}


/*-------------------------- errorMessage ---------------------------------*/

void errorMessage(
   char *file,               /* The file in which the error occured. */
   int  line,                /* The line before which the error occured. */
   char *function,           /* The function in which the error occured. */
   char *message)            /* The message to be printed.  It will be
                                prefixed by "Error: ". */
{
   printf( "\n\n Error: %s\n"
           " Program was executing function %s (line %d in file %s).",
           message, function, line, file);
   exit(ERROR_RETURN_CODE);
}


/*-------------------------- errorMessage1i -------------------------------*/

void errorMessage1i(
   char *file,               /* The file in which the error occured. */
   int  line,                /* The line before which the error occured. */
   char *function,           /* The function in which the error occured. */
   char *message1,           /* The first part of the error message. */
   Unsigned intParm,         /* The integer variable part of the message. */
   char *message2)           /* The second part of the error message. */
{
   printf( "\n\n Error: %s%u%s\n"
           " Program was executing function %s (line %d in file %s).",
           message1, intParm, message2, function, line, file);
   exit(ERROR_RETURN_CODE);
}


/*-------------------------- errorMessage1s -------------------------------*/

void errorMessage1s(
   char *file,               /* The file in which the error occured. */
   int  line,                /* The line before which the error occured. */
   char *function,           /* The function in which the error occured. */
   char *message1,           /* The first part of the error message. */
   char *strParm,            /* The integer variable part of the message. */
   char *message2)           /* The second part of the error message. */
{
   printf( "\n\n Error: %s%s%s\n"
           " Program was executing function %s (line %d in file %s).",
           message1, strParm, message2, function, line, file);
   exit(ERROR_RETURN_CODE);
}
