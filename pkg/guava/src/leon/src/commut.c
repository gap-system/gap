/* File commut.c.  Main program for program to compute commutator subgroups.
   Specifically, if H is a subgroup of G, the program computes the commutator
   group [G,H].  The formats for the command is

      commut  <options>  <group>  <subgroup>  <commutator>
   or
      commut  <options>  <group>  <commutator>

   where in the second case it is understood that <subgroup> equals <group>.

   The meaning of the parameters is as follows:

      <group>:      The group referred to as G above.

      <subgroup>:   The group referred to as H above.  Defaults to G.

      <commutator>: Set to the commutator group [G,H].

   The options are as follows:

      -i          The generators of <commutator> are to be written in image format.

      -overwrite: If the Cayley library file for <commutator> exists, it will
                  be overwritten to rather than appended to.

   The return code for set or partition stabilizer computations is as follows:
      0: computation successful,
      1: computation terminated due to error.
*/


#include <stddef.h>
#include <stdlib.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>

#include "group.h"
#include "groupio.h"

#include "ccommut.h"
#include "errmesg.h"
#include "factor.h"
#include "permgrp.h"
#include "readgrp.h"
#include "readper.h"
#include "storage.h"
#include "token.h"
#include "util.h"

GroupOptions options;

static void verifyOptions(void);

int main( int argc, char *argv[])
{
   char groupFileName[MAX_FILE_NAME_LENGTH] = "",
        subgroupFileName[MAX_FILE_NAME_LENGTH] = "",
        commutatorFileName[MAX_FILE_NAME_LENGTH] = "";
   Unsigned i, j, optionCountPlus1;
   char groupLibraryName[MAX_NAME_LENGTH+1] = "",
        subgroupLibraryName[MAX_NAME_LENGTH+1] = "",
        commutatorLibraryName[MAX_NAME_LENGTH+1] = "",
        prefix[MAX_FILE_NAME_LENGTH+1] = "",
        suffix[MAX_NAME_LENGTH+1] = "",
        commutatorName[MAX_NAME_LENGTH+1] = "";
   PermGroup *G, *H, *C;
   BOOLEAN imageFormatFlag = FALSE, HnotequalG, quietFlag, normalClosureFlag;
   char comment[100];

   /* If no arguments (except possibly -ncl) are given, provide help and exit. */
   if ( argc == 1 ) {
      printf( "\nUsage:  commut [options] group subgroup commutatorGroup\n");
      return 0;
   }
   else if ( argc == 2 && strcmp(argv[1],"-ncl") == 0 ) {
      printf( "\nUsage:  ncl [options] group subgroup normalClosure\n");
      return 0;
   }

   /* Check for limits option.  If present in position 1, give limits and
      return. */
   if ( argc > 1 && (strcmp( argv[1], "-l") == 0 || strcmp( argv[1], "-L") == 0) ) {
      showLimits();
      return 0;
   }
   /* Check for verify option.  If present in position 1, perform verify
      (Note verifyOptions terminates program). */
   if ( argc > 1 && (strcmp( argv[1], "-v") == 0 || strcmp( argv[1], "-V") == 0) ) 
      verifyOptions();

   /* Check for exactly 2 or 3 parameters following options. */
   for ( optionCountPlus1 = 1 ; optionCountPlus1 < argc &&
              argv[optionCountPlus1][0] == '-' ; ++optionCountPlus1 )
      ;

   if ( argc - optionCountPlus1 < 2 || argc - optionCountPlus1 > 3 )
      ERROR( "main (commut)", "Exactly 2 or 3 parameters are required.")

   /* Process options. */
   prefix[0] = '\0';
   suffix[0] = '\0';
   options.maxBaseSize = DEFAULT_MAX_BASE_SIZE;
   imageFormatFlag = FALSE;
   quietFlag = FALSE;
   normalClosureFlag = FALSE;
   strcpy( options.outputFileMode, "w");

   /* Process options. */
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
      errno = 0;
      if ( strncmp( argv[i], "-p:", 3) == 0 ) {
         strcpy( prefix, argv[i]+3);
      }
      else if ( strncmp( argv[i], "-t:", 3) == 0 ) {
         strcpy( suffix, argv[i]+3);
      }
      else if ( strcmp( argv[i], "-i") == 0 )
         imageFormatFlag = TRUE;
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
      else if ( strncmp( argv[i], "-n:", 3) == 0 )
         if ( isValidName( argv[i]+3) )
            strcpy( commutatorName, argv[i]+3);
         else
            ERROR1s( "main (commut)", "Invalid name ", commutatorName,
                     " for commutator group.")
      else if ( strcmp( argv[i], "-a") == 0 )
         strcpy( options.outputFileMode, "a");
      else if ( strcmp( argv[i], "-q") == 0 )
         quietFlag = TRUE;
      else if ( strcmp( argv[i], "-ncl") == 0 )
         normalClosureFlag = TRUE;
      else
         ERROR1s( "main (compute subgroup)", "Invalid option ", argv[i], ".")
   }

   /* Compute maximum degree and word length. */
   options.maxWordLength = 200 + 5 * options.maxBaseSize;
   options.maxDegree = MAX_INT - 2 - options.maxBaseSize;

   HnotequalG = (argc - optionCountPlus1 == 3);
   if ( normalClosureFlag && !HnotequalG )
      ERROR( "main (commut)", "Invalid number of arguments for normal closure")

   /* Compute names for files and libraries. */
   parseLibraryName( argv[optionCountPlus1], prefix, suffix,
                     groupFileName, groupLibraryName);
   if ( HnotequalG )
      parseLibraryName( argv[optionCountPlus1+1], prefix, suffix,
                        subgroupFileName, subgroupLibraryName);
   parseLibraryName( argv[optionCountPlus1+1+HnotequalG], "", "",
                     commutatorFileName, commutatorLibraryName);

   /* Read in the groups G and H. */
   G = readPermGroup( groupFileName, groupLibraryName, 0, "Generate");
   if ( HnotequalG )
      if ( normalClosureFlag )
         H = readPermGroup( subgroupFileName, subgroupLibraryName, G->degree,
                         "Generate");
      else
         H = readPermGroup( subgroupFileName, subgroupLibraryName, G->degree,
                         "");
   else
      H = G;

   /* Now we set C to the commutator of [G,H] of G and H, and write out C. */
   if ( normalClosureFlag )
      C = normalClosure( G, H);
   else
      C = commutatorGroup( G, H);
   if ( commutatorName[0] != '\0' )
      strcpy( C->name, commutatorName);
   else
      strcpy( C->name, commutatorLibraryName);
   C->printFormat = (imageFormatFlag ? imageFormat : cycleFormat);
   if ( normalClosureFlag )
      sprintf( comment, "The normal closure in %s of %s.", G->name, H->name);
   else
      sprintf( comment, "The commutator group [%s,%s].", G->name, H->name);
   writePermGroup( commutatorFileName, commutatorLibraryName, C, comment);

   /* Write commutator group order to std output. */
   if ( !quietFlag ) {
      if ( normalClosureFlag )
         printf( "\nNormal closure %s of %s in %s has order ", C->name,
                  H->name, G->name);
      else
         printf( "\nCommutator group %s = [%s,%s] has order ", C->name,
                  G->name, H->name);
      if ( C->order->noOfFactors == 0 )
         printf( "%d", 1);
      else
         for ( i = 0 ; i < C->order->noOfFactors ; ++i ) {
            if ( i > 0 )
               printf( " * ");
            printf( "%u", C->order->prime[i]);
            if ( C->order->exponent[i] > 1 )
               printf( "^%u", C->order->exponent[i]);
         }
      printf( "  (random Schreier)\n");
   }

   /* Return to caller. */
   if ( normalClosureFlag )
      return 0;
   else if ( C->order->noOfFactors == 0 )
      return 0;
   else if ( H->order )
      if ( factEqual( H->order, C->order) )
         return 3;
      else
         return 2;
   else
      return 4;
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
   extern void xccommu( CompileOptions *cOpts);
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
   extern void xreadgr( CompileOptions *cOpts);
   extern void xstorag( CompileOptions *cOpts);
   extern void xtoken ( CompileOptions *cOpts);
   extern void xutil  ( CompileOptions *cOpts);

   xaddsge( &mainOpts);
   xbitman( &mainOpts);
   xccommu( &mainOpts);
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
   xreadgr( &mainOpts);
   xstorag( &mainOpts);
   xutil  ( &mainOpts);
}



