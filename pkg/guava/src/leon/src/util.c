/* File util.h.  Utility routines for use with partition backtrack
   algorithms. */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "group.h"

CHECK( util)

extern GroupOptions options;


/*-------------------------- parseLibraryName ----------------------------*/

void parseLibraryName(
   const char *const inputString,
   const char *const prefix,
   const char *const suffix,
   char *const libraryFileName,
   char *const libraryName)
{
   int i;
   for ( i = 0 ; i < strlen(inputString) ; ++i )
      if ( inputString[i] == ':' && inputString[i+1] == ':' )
         break;
   strcpy( libraryFileName, prefix);
   strncat( libraryFileName, inputString, i);
   strcat( libraryFileName, suffix);
#ifdef PERIOD_TO_BLANK
   for ( i = 0 ; i < strlen(libraryFileName) ; ++i )
      if ( libraryFileName[i] == '.' )
         libraryFileName[i] = ' ';
#endif
   i = (i < strlen(inputString)) ? (i + 2) : 0;
   strcpy( libraryName, inputString+i);
}


/*-------------------------- showLimits ----------------------------------*/

void showLimits(void)
{
   printf( "\n Default maximum base size:    %2d", DEFAULT_MAX_BASE_SIZE);
   printf( "\n Default maximum word length:  200 + 5 * maxBaseSize");
   printf( "\n Maximum degree:               %u - maxBaseSize", MAX_INT-2);
   printf( "\n Maximum name length:          %2d", MAX_NAME_LENGTH);
   printf( "\n Maximum file name length:     %2d", MAX_FILE_NAME_LENGTH);
   printf( "\n Maximum prime factors:        %2d\n", MAX_PRIME_FACTORS);
}


/*-------------------------- checkCompileOptions -------------------------*/

void checkCompileOptions(
   char *localFileName,
   CompileOptions *mainOpts,
   CompileOptions *localOpts)
{
   if ( localOpts->mbs != mainOpts->mbs ) {
      printf( "\n\nError: DEFAULT_MAX_BASE_SIZE is %d in main and %d in %s\n",
              mainOpts->mbs, localOpts->mbs, localFileName);
      exit(ERROR_RETURN_CODE);
   }
   if ( localOpts->mnl != mainOpts->mnl ) {
      printf( "\n\nError: MAX_NAME_LENGTH is %d in main and %d in %s\n",
              mainOpts->mnl, localOpts->mnl, localFileName);
      exit(ERROR_RETURN_CODE);
   }
   if ( localOpts->mpf != mainOpts->mpf ) {
      printf( "\n\nError: MAX_PRIME_FACTORS is %d in main and %d in %s\n",
              mainOpts->mpf, localOpts->mpf, localFileName);
      exit(ERROR_RETURN_CODE);
   }
   if ( localOpts->mrp != mainOpts->mrp ) {
      printf( "\n\nError: MAX_REFINEMENT_PARMS is %d in main and %d in %s\n",
              mainOpts->mrp, localOpts->mrp, localFileName);
      exit(ERROR_RETURN_CODE);
   }
   if ( localOpts->mfp != mainOpts->mfp ) {
      printf( "\n\nError: MAX_FAMILY_PARMS is %d in main and %d in %s\n",
              mainOpts->mfp, localOpts->mfp, localFileName);
      exit(ERROR_RETURN_CODE);
   }
   if ( localOpts->me != mainOpts->me ) {
      printf( "\n\nError: MAX_EXTRA is %d in main and %d in %s\n",
              mainOpts->me, localOpts->me, localFileName);
      exit(ERROR_RETURN_CODE);
   }
   if ( localOpts->xl != mainOpts->xl ) {
      printf( "\n\nError: EXTRA_LARGE is inconsistent in main and %s\n",
              localFileName);
      exit(ERROR_RETURN_CODE);
   }
   if ( localOpts->sg != mainOpts->sg ) {
      printf( "\n\nError: SIGNED is inconsistent in main and %s\n",
              localFileName);
      exit(ERROR_RETURN_CODE);
   }
   if ( localOpts->nf != mainOpts->nf ) {
      printf( "\n\nError: NOFLOAT is inconsistent in main and %s\n",
              localFileName);
      exit(ERROR_RETURN_CODE);
   }
   printf( "\nCompile options are consistent.\n");
   exit(0);
}
