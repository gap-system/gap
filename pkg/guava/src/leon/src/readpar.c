/* File readPar.  Contains routines to read in and write out partitions.
   The files must already be open. */

#include <stddef.h>
#include <stdio.h>
#include <string.h>

#include "group.h"
#include "groupio.h"

#include "storage.h"
#include "token.h"
#include "errmesg.h"

CHECK( readpa)

extern GroupOptions options;


/*-------------------------- readPartition --------------------------------*/

Partition *readPartition(
   char *libFileName,
   char *libName,
   Unsigned degree)
{
   Unsigned pt, currentCellNumber, pointsFound;
   Partition *partn = allocPartition();
   Token token, saveToken;
   char inputBuffer[81];
   FILE *libFile;

   /* Open input file. */
   libFile = fopen( libFileName, "r");
   if ( libFile == NULL )
      ERROR1s( "readPartition", "File ", libFileName,
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
         ERROR1s( "readPartition", "Library block ", libName,
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

   /* Set the degree of the partition (must be specified). */
   partn->degree = degree;

   /* Read the partition name. */
   if ( (token = nkReadToken() , saveToken = token , token.type == identifier) &&
         (token = nkReadToken() , token.type == equal) )
      strcpy( partn->name, saveToken.value.identValue);

   if ( (token = readToken() , token.type != identifier) ||
             strcmp( token.value.identValue, "seq") != 0 ||
             (token = readToken() , token.type != leftParen) )
      ERROR( "readPartition", "Invalid syntax in partition library.")

   /* Allocate fields for partition structure. */
   partn->pointList = allocIntArrayDegree();
   partn->invPointList = allocIntArrayDegree();
   partn->cellNumber = allocIntArrayDegree();
   partn->startCell = allocIntArrayDegree();

   /* Read the partition. */
   for ( pt = 1 ; pt <= degree ; ++pt )
      partn->cellNumber[pt] = 0;
   currentCellNumber = 0;
   pointsFound = 0;
   do {
      if ( token = readToken() , token.type == leftBracket )
         ++currentCellNumber;
      else
         ERROR( "readPartition", "Invalid symbol in point list.")
      partn->startCell[currentCellNumber] = pointsFound + 1;
      while  (token = readToken() , token.type == integer ||
                                    token.type == comma )
         if ( token.type == integer && (pt = token.value.intValue) > 0 &&
                                       pt <= partn->degree )
            if ( partn->cellNumber[pt] == 0 ) {
               partn->pointList[++pointsFound] = pt;
               partn->invPointList[pt] = pointsFound;
               partn->cellNumber[pt] = currentCellNumber;
            }
            else
               ERROR1i( "readPartition", "Point ", pt,
                        " occurs more than once in point list.")
         else if ( token.type == integer )
            ERROR1i( "readPartition", "Invalid point ", pt, ".")
      if ( token.type != rightBracket || (token = readToken() ,
                          token.type != comma && token.type != rightParen) )
         ERROR( "readPartition", "Invalid symbol in point list.")
   } while ( token.type != rightParen );
   partn->startCell[currentCellNumber+1] = degree + 1;
   if ( token = readToken() , token.type != semicolon )
      ERROR( "readPartition", "Missing semicolon terminating partition.")

   /* Close the input file and return. */
   fclose( libFile);
   return partn;
}


/*-------------------------- writePartition ------------------------------*/

void writePartition(
   char *libFileName,
   char *libName,
   char *comment,
   Partition *partn)
{
   Unsigned i, column, cellNo;
   FILE *libFile;

   /* Open output file. */
   libFile = fopen( libFileName, options.outputFileMode);
   if ( libFile == NULL )
      ERROR1s( "writePartition", "File ", libFileName,
               " could not be opened for output.")

   /* Write the library name. */
   fprintf( libFile, "LIBRARY %s;\n", libName);

   /* Write the comment. */
   if ( comment )
      fprintf( libFile, "& %s &\n", comment);

   /* Write the partition set name. */
   if ( !partn->name[0] )
      strcpy( partn->name, "Pi");
   column = fprintf( libFile, "  %s = seq(", partn->name);

   /* Write the cells. */
   for ( cellNo = 1 ; partn->startCell[cellNo] <= partn->degree ; ++cellNo ) {
      column += fprintf( libFile, "[");
      for ( i = partn->startCell[cellNo] ; i < partn->startCell[cellNo+1] ; ++i ) {
         if ( column > 73 ) {
            fprintf( libFile, "\n        ");
            column = 9;
         }
         column += fprintf( libFile, "%u", partn->pointList[i]) + 1;
         if ( i < partn->startCell[cellNo+1] - 1 )
            column += fprintf( libFile, ",");
      }
      column += fprintf( libFile, "]");
      if ( partn->startCell[cellNo+1] <= partn->degree )
         column += fprintf( libFile, ",");
   }

   /* Write terminators. */
   fprintf( libFile, ");\nFINISH;\n");

   /* Close output file. */
   fclose( libFile);
}
