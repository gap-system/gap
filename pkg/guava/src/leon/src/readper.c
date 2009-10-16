/* File readPer.  Contains routines to read in and write out individual
   permutations.  The files must already be open. */

#include <stddef.h>
#include <stdio.h>
#include <string.h>

#include "group.h"
#include "groupio.h"

#include "errmesg.h"
#include "essentia.h"
#include "readgrp.h"
#include "storage.h"
#include "token.h"

CHECK( readpe)

extern GroupOptions options;


/*-------------------------- readPermutation ------------------------------*/

Permutation *readPermutation(
   char *libFileName,
   char *libName,
   const Unsigned requiredDegree,
   const BOOLEAN inverseFlag)               /* If true, adjoin inverse. */
{
   Permutation *perm = allocPermutation();
   Unsigned pt;
   Token token, saveToken;
   char inputBuffer[81];
   FILE *libFile;

   /* Open input file. */
   libFile = fopen( libFileName, "r");
   if ( libFile == NULL )
      ERROR1s( "readPermutation", "File ", libFileName,
               " could not be opened for input.")

   /* Initialize input routines to correct file. */
   setInputFile( libFile);
   lowerCase( libName);

   /* Initialize storage manager. */
   initializeStorageManager( requiredDegree);

   /* Search for the correct library.  Terminate with error message if
      not found. */
   rewind( libFile);
   for (;;) {
      fgets( inputBuffer, 80, libFile);
      if ( feof(libFile) )
         ERROR1s( "readPermutation", "Library block ", libName,
                  " not found in specified library.")
      if ( inputBuffer[0] == 'l' || inputBuffer[0] == 'L' ) {
         setInputString( inputBuffer);
         if ( ( (token = sReadToken()) , token.type == identifier &&
                strcmp(lowerCase(token.value.identValue),"library") == 0 )
              &&
              ( (token = sReadToken()) , token.type == identifier &&
                strcmp(lowerCase(token.value.identValue),libName) == 0 ) )
            break;
      }
   }

   /* Set the degree of the permutation (must be specified). */
   perm->degree = requiredDegree;

   /* Read the permutation name. */
   if ( (token = nkReadToken() , saveToken = token , token.type == identifier) &&
         (token = nkReadToken() , token.type == equal) )
      strcpy( perm->name, saveToken.value.identValue);

   /* Read the permutation. */
   perm->level = 0;
   MAKE_NOT_ESSENTIAL_ALL( perm);
   perm->image = allocIntArrayDegree();
   for ( pt = 1 ; pt <= requiredDegree ; ++pt )
      perm->image[pt] = 0;

   /* Check whether permutation is in cycle or image format, and call
      appropriate function to finish read. */
   switch ( token = readToken() , token.type ) {
      case leftParen:
         unreadToken( token);
         readCyclePerm( perm);
         break;
      case slash:
         unreadToken( token);
         readImagePerm( perm);
         break;
      default:
         unreadToken( token);
         ERROR( "readPermutation",
                "Invalid symbol at start of cycle/image field.");
   }

   /* Adjoin inverse, if requested. */
   if ( inverseFlag ) {
      perm->invImage = allocIntArrayDegree();
      for ( pt = 1 ; pt <= requiredDegree ; ++pt )
         perm->invImage[perm->image[pt]] = pt;
   }

   /* Close the input file and return. */
   fclose( libFile);
   return perm;
}


/*-------------------------- writePermutation -----------------------------*/

void writePermutation(
   char *libFileName,
   char *libName,
   Permutation *perm,
   char *format,
   char *comment)
{
   Unsigned column;
   FILE *libFile;

   /* Open output file. */
   libFile = fopen( libFileName, options.outputFileMode);
   if ( libFile == NULL )
      ERROR1s( "writePermutation", "File ", libFileName,
               " could not be opened for output.")

   setOutputFile( libFile);

   /* Write library name. */
   fprintf( libFile, "LIBRARY %s;", libName);

   /* Write the comment. */
   if ( comment )
      fprintf( libFile, "\n& %s &", comment);

   /* Assign the name x if the permutation has no name. */
   if ( !perm->name[0] )
      strcpy( perm->name, "x");

   column = 1 + fprintf( libFile, "\n  %s = ", perm->name);

   if ( strcmp( format, "image") == 0 )
      writeImagePerm( perm, column, 8, 80);
   else
      writeCyclePerm( perm, column, 8, 80);
   fprintf( libFile, ";");

   /* Write "finish". */
   fprintf( libFile, "\nFINISH;\n");

   /* Return to caller. */
   return;
}



/*-------------------------- writePermutationRestricted -------------------*/

/* This procedure is identical to writePermutation, except that it assumes
   that perm fixes {1,...,restrictedDegree} (not checked!) and writes it
   out as a permutation of degree restrictedDegree. */

void writePermutationRestricted(
   char *libFileName,
   char *libName,
   Permutation *perm,
   char *format,
   char *comment,
   Unsigned restrictedDegree)
{
   Unsigned trueDegree = perm->degree;
   perm->degree = restrictedDegree;
   writePermutation( libFileName, libName, perm, format, comment);
   perm->degree = trueDegree;
}
