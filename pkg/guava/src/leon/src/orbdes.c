/* File orbdes.c.  Main program for orbdes command, which may be used
   construct a design from the orbits of a point stabilizer in a permutation
   group.  The format of the command is:

        orbdes  <options> <permGroup> <orbRep> <design>

   where the meaning of the parameters is as follows:

            <options>:    Options for program.

            <permGroup>:  The permutation group from which the design is
                          to be constructed.

            <orbRep>:     Determines which orbit of the point stabilizer
                          of 1 (or the first point in <orbRep>^<permGroup>
                          for an intransitive group) will be used.

            <design>:     The name for the design to be created.
*/


#include <stddef.h>
#include <errno.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define MAIN

#include "group.h"
#include "groupio.h"

#include "chbase.h"
#include "errmesg.h"
#include "new.h"
#include "oldcopy.h"
#include "permut.h"
#include "readdes.h"
#include "readgrp.h"
#include "storage.h"
#include "util.h"

static void verifyOptions(void);

GroupOptions options;

int main( int argc, char *argv[])
{
   char permGroupFileName[MAX_FILE_NAME_LENGTH] = "",
        designFileName[MAX_FILE_NAME_LENGTH] = "",
        permGroupLibraryName[MAX_NAME_LENGTH] = "",
        designLibraryName[MAX_NAME_LENGTH] = "";
   char comment[60];
   Unsigned orbRep, i, j, pt, basePt, processed, found, img, optionCountPlus1;
   char *flag;
   Unsigned *pointList;
   PermGroup *G;
   Matrix_01 *D;
   Permutation *gen;
   BOOLEAN matrixFlag, transposeMatrixFlag;

   /* If there are no options, provide usage information and exit. */
   if ( argc == 1 ) {
      printf( "\nUsage:  orbdes [-a] [-m] [-mt] permGroup point design\n");
      return 0;
   }

   /* Check for limits option.  If present in position 1, give limits and 
      return. */
   if ( strcmp( argv[1], "-l") == 0 || strcmp( argv[1], "-L") == 0 ) {
      showLimits();
      return 0;
   }
   /* Check for verify option.  If present in position i (i as above) perform
      verify (Note verifyOptions terminates program). */
   if ( strcmp( argv[1], "-v") == 0 || strcmp( argv[1], "-V") == 0 )
      verifyOptions();

   /* Check for exactly 3 parameters following options. */
   for ( optionCountPlus1 = 1 ; optionCountPlus1 < argc &&
              argv[optionCountPlus1][0] == '-' ; ++optionCountPlus1 )
      ;

   if ( argc - optionCountPlus1 != 3 ) {
      ERROR( "main (design group)",
             "Exactly 3 non-option parameters are required.");
      exit(ERROR_RETURN_CODE);
   }

   options.maxBaseSize = DEFAULT_MAX_BASE_SIZE;
   strcpy( options.outputFileMode, "w");
   matrixFlag = FALSE;
   transposeMatrixFlag = FALSE;
   /* Translate options to lower case and process them. */
   for ( i = 1 ; i < optionCountPlus1 ; ++i ) {
      for ( j = 1 ; argv[i][j] != ':' && argv[i][j] != '\0' ; ++j )
#ifdef EBCDIC
         argv[i][j] = ( argv[i][j] >= 'A' && argv[i][j] <= 'I' ||
                        argv[i][j] >= 'J' && argv[i][j] <= 'R' ||
                        argv[i][j] >= 'S' && argv[i][j] <= 'Z' ) ?
                        (argv[i][j] + 'a' - 'A') : argv[i][j];
#else
         argv[i][j] = (argv[i][j] >= 'A' && argv[i][j] <= 'Z') ?
                      (argv[i][j] + 'a' - 'A') : argv[i][j];
#endif

      if ( strcmp( argv[i], "-a") == 0 )
         strcpy( options.outputFileMode, "a");
      else if ( strncmp( argv[i], "-mb:", 4) == 0 ) {
         errno = 0;
         options.maxBaseSize = (Unsigned) strtol(argv[i]+4,NULL,0);
         if ( errno )
            ERROR( "main (cent)", "Invalid syntax for -mb option")
      }
      else if ( strncmp( argv[i], "-mw:", 4) == 0 ) {
         errno = 0;
         options.maxWordLength = (Unsigned) strtol(argv[i]+4,NULL,0);
         if ( errno )
            ERROR( "main (cent)", "Invalid syntax for -mw option")
      }
      else if ( strcmp( argv[i], "-m") == 0 ) {
         matrixFlag = TRUE;
         transposeMatrixFlag = FALSE;
      }
      else if ( strcmp( argv[i], "-mt") == 0 ) {
         transposeMatrixFlag = TRUE;
         matrixFlag = FALSE;
      }
   }

   /* Compute maximum degree and word length. */
   options.maxWordLength = 200 + 5 * options.maxBaseSize;
   options.maxDegree = MAX_INT - 2 - options.maxBaseSize;

   /* Compute file and library names. */
   parseLibraryName( argv[optionCountPlus1], "", "", permGroupFileName,
                     permGroupLibraryName);
   parseLibraryName( argv[optionCountPlus1+2], "", "", designFileName,
                     designLibraryName);

   /* Read in group. */
   G = readPermGroup( permGroupFileName, permGroupLibraryName, 0, "Generate");

   /* Obtain orbit representive and suborbit representative. */
   errno = 0;
   orbRep = strtol( argv[optionCountPlus1+1], NULL, 0);
   if ( errno != 0 || orbRep < 1 || orbRep > G->degree )
      ERROR1s( "main (orbdes command)", "Invalid orbit representative ",
               argv[optionCountPlus1+1], ".");

   /* Find the first point in the G-orbit of orbRep, call it basePt,and make
      it the first base point.  Make orbRep the second base point. */
   insertBasePoint( G, 1, orbRep);
   for ( basePt = 1; G->schreierVec[1][basePt] == NULL ; ++basePt )
      ;
   insertBasePoint( G, 1, basePt);
   insertBasePoint( G, 2, orbRep);

   /* Allocate the design. */
   D = newZeroMatrix( 2, G->degree, G->degree);

   /* Construct the design. */
   pointList = allocIntArrayDegree();
   flag = allocBooleanArrayDegree();
   processed = 0;
   found  = 1;
   pointList[1] = basePt;
   for ( pt = 1 ; pt <= G->degree ; ++pt )
      flag[pt] = FALSE;
   flag[basePt] = TRUE;
   for ( i = 1 ; i <= G->basicOrbLen[2] ; ++i )
      D->entry[G->basicOrbit[2][i]][basePt] = 1;
   while ( processed < found ) {
      pt = pointList[++processed];
      for ( gen = G->generator ; gen ; gen = gen->next ) {
         img = gen->image[pt];
         if ( !flag[img] ) {
            flag[img] = TRUE;
            pointList[++found] = img;
            for ( i = 1 ; i <= G->degree ; ++i )
               D->entry[gen->image[i]][img] = D->entry[i][pt];
         }
      }
   }

   /* Write out the design. */
   sprintf( comment, "Design from group %s, %s_%d orbit of %d.", G->name,
                     G->name, basePt, orbRep);
   strcpy( D->name, designLibraryName);
   if ( matrixFlag )
      write01Matrix( designFileName, designLibraryName, D, FALSE, comment);
   else if ( transposeMatrixFlag )
      write01Matrix( designFileName, designLibraryName, D, TRUE, comment);
   else
      writeDesign( designFileName, designLibraryName, D, comment);

   return 0;
}


/*-------------------------- verifyOptions -------------------------------*/

static void verifyOptions(void)
{
   CompileOptions mainOpts = { DEFAULT_MAX_BASE_SIZE, MAX_NAME_LENGTH,
                               MAX_PRIME_FACTORS,
                               MAX_REFINEMENT_PARMS, MAX_FAMILY_PARMS,
                               MAX_EXTRA,  XLARGE, SGND, NFLT};
   extern void xaddsge( CompileOptions *cOpts);
   extern void xbitman( CompileOptions *cOpts);
   extern void xcopy  ( CompileOptions *cOpts);
   extern void xcstbor( CompileOptions *cOpts);
   extern void xerrmes( CompileOptions *cOpts);
   extern void xessent( CompileOptions *cOpts);
   extern void xfactor( CompileOptions *cOpts);
   extern void xnew   ( CompileOptions *cOpts);
   extern void xoldcop( CompileOptions *cOpts);
   extern void xpermgr( CompileOptions *cOpts);
   extern void xpermut( CompileOptions *cOpts);
   extern void xprimes( CompileOptions *cOpts);
   extern void xrandgr( CompileOptions *cOpts);
   extern void xrandsc( CompileOptions *cOpts);
   extern void xreadde( CompileOptions *cOpts);
   extern void xreadgr( CompileOptions *cOpts);
   extern void xreadpe( CompileOptions *cOpts);
   extern void xstorag( CompileOptions *cOpts);
   extern void xtoken ( CompileOptions *cOpts);
   extern void xutil  ( CompileOptions *cOpts);

   xaddsge( &mainOpts);
   xbitman( &mainOpts);
   xcopy  ( &mainOpts);
   xcstbor( &mainOpts);
   xerrmes( &mainOpts);
   xessent( &mainOpts);
   xfactor( &mainOpts);
   xnew   ( &mainOpts);
   xoldcop( &mainOpts);
   xpermgr( &mainOpts);
   xpermut( &mainOpts);
   xprimes( &mainOpts);
   xrandgr( &mainOpts);
   xrandsc( &mainOpts);
   xreadde( &mainOpts);
   xreadgr( &mainOpts);
   xreadpe( &mainOpts);
   xstorag( &mainOpts);
   xtoken ( &mainOpts);
   xutil  ( &mainOpts);
}

