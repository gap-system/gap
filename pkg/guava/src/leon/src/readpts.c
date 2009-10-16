/* File readPts.  Contains routines to read in and write out point sets.
   The files must already be open. */

#include <stddef.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

#include "group.h"
#include "groupio.h"

#include "storage.h"
#include "token.h"
#include "errmesg.h"

CHECK( readpt)

extern GroupOptions options;


/*-------------------------- readPointSet ---------------------------------*/

PointSet *readPointSet(
   char *libFileName,
   char *libName,
   Unsigned degree)
{
   Unsigned pt;
   PointSet *P = allocPointSet();
   Token token, saveToken;
   char inputBuffer[81];
   FILE *libFile;

   /* Open input file. */
   libFile = fopen( libFileName, "r");
   if ( libFile == NULL )
      ERROR1s( "readPointSet", "File ", libFileName,
               " could not be opened for input.")

   /* Initialize input routines to correct file. */
   setInputFile( libFile);
   lowerCase( libName);

   /* Initialize storage manager. */
   initializeStorageManager( degree);

   /* Search for the correct library.  Terminate with error message if
      not found. */
   rewind( libFile);
   for (;;) {
      fgets( inputBuffer, 80, libFile);
      if ( feof(libFile) )
         ERROR1s( "readPointSet", "Library block ", libName,
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

   /* Set the degree of the point set (must be specified). */
   P->degree = degree;

   /* Read the point set name. */
   if ( (token = nkReadToken() , saveToken = token , token.type == identifier) &&
         (token = nkReadToken() , token.type == equal) )
      strcpy( P->name, saveToken.value.identValue);

   if ( token = readToken() , token.type != leftBracket )
      ERROR( "readPointSet", "Invalid syntax in point set library.")

   /* Read the points. */
   P->pointList = allocIntArrayDegree();
   P->inSet = allocBooleanArrayDegree();
   P->size = 0;
   for ( pt = 1 ; pt <= P->degree ; ++pt )
      P->inSet[pt] = FALSE;
   while  (token = readToken() , token.type == integer || token.type == comma)
      if ( token.type == integer && (pt = token.value.intValue) > 0 && pt <= P->degree )
         if ( !P->inSet[pt] ) {
            P->pointList[++P->size] = pt;
            P->inSet[pt] = TRUE;
         }
         else;
      else if ( token.type == integer )
         ERROR1i( "ReadPointSet", "Invalid point ", pt, ".")
   if ( token.type != rightBracket || (token = readToken() ,
                                        token.type !=semicolon) )
      ERROR( "readPointSet", "Invalid symbol in point list.")

   /* Close the input file and return. */
   fclose( libFile);
   return P;
}


/*-------------------------- writePointSet --------------------------------*/

void writePointSet(
   char *libFileName,
   char *libName,
   char *comment,
   PointSet *P)
{
   Unsigned i, column;
   FILE *libFile;

   /* Open output file. */
   libFile = fopen( libFileName, options.outputFileMode);
   if ( libFile == NULL )
      ERROR1s( "writePointSet", "File ", libFileName,
               " could not be opened for output.")

   /* Write the library name. */
   fprintf( libFile, "LIBRARY %s;\n", libName);

   /* Write the comment. */
   if ( comment )
      fprintf( libFile, "& %s &\n", comment);

   /* Write the point set name. */
   if ( !P->name[0] )
      strcpy( P->name, "P");
   column = fprintf( libFile, "  %s = [", P->name);

   /* Write the points. */
   for ( i = 1 ; i <= P->size ; ++i ) {
      if ( column > 75 ) {
         fprintf( libFile, "\n        ");
         column = 9;
      }
      column += fprintf( libFile, "%u", P->pointList[i]) + 1;
      if ( i < P->size )
         fprintf( libFile, ",");
   }

   /* Write terminators. */
   fprintf( libFile, "];\nFINISH;\n");

   /* Close output file. */
   fclose( libFile);
}
