/* File readGrp. */

#include <stddef.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

#include "group.h"
#include "groupio.h"

#include "chbase.h"
#include "cstborb.h"
#include "errmesg.h"
#include "essentia.h"
#include "factor.h"
#include "permut.h"
#include "permgrp.h"
#include "randschr.h"
#include "storage.h"
#include "token.h"

CHECK( readgr)

extern GroupOptions options;

static FILE *outFile;   /* File to which group tables are output. */
static Unsigned permNumber;


/*-------------------------- readFactoredInt -----------------------------*/

FactoredInt readFactoredInt(void)
{
   FactoredInt fInt;
   Token  token, token2;

   fInt.noOfFactors = 0;
   token = readToken();
   if ( token.type != integer )
      ERROR( "readFactoredInt", "Invalid symbol in factored integer.")
   else if ( token.value.intValue == 1 )
      return fInt;
   else {
      unreadToken( token);
      do {
         token = readToken();
         if ( token.type != integer )
            ERROR( "readFactoredInt", "Invalid symbol in factored integer.");
         fInt.prime[fInt.noOfFactors] = token.value.intValue;
         if ( token = readToken() , token.type == caret )
            if ( token2 = readToken() , (token2.type == integer &&
                                         token2.value.intValue > 0) )
               fInt.exponent[fInt.noOfFactors] = token2.value.intValue;
            else
               ERROR( "readFactoredInt", "Invalid exponent in factored "
                                         "integer")
         else {
            fInt.exponent[fInt.noOfFactors] = 1;
            unreadToken( token);
         }
         ++fInt.noOfFactors;
      } while ( token = readToken() , token.type == asterisk );
      unreadToken( token);
   }

   return fInt;
}


/*-------------------------- writeFactoredInt ----------------------------*/

void writeFactoredInt(
   FactoredInt *fInt)
{
   Unsigned i;

   if ( fInt->noOfFactors == 0 ) {
      fprintf( outFile, "%d", 1);
      return;
   }

   for ( i = 0 ; i < fInt->noOfFactors ; ++i ) {
      if ( i > 0 )
         fprintf( outFile, " * ");
      fprintf( outFile, "%u", fInt->prime[i]);
      if ( fInt->exponent[i] > 1 )
         fprintf( outFile, "^%u", fInt->exponent[i]);
   }

   return;
}


/*-------------------------- readCyclePerm -------------------------------*/

TokenType readCyclePerm(
   Permutation *perm)
{
   Unsigned     pt, previousPt, firstPtOfCycle, parenLevel = 0;
   Unsigned     degree = perm->degree;
   Token   token;
   BOOLEAN newCycle;

   /* Read the cycles and fill in the image array. */
   while ( token = readToken() , (parenLevel > 0 || token.type != comma) &&
           token.type != semicolon && token.type != eof &&
           token.type != rightBracket )
      switch( token.type ) {
         case comma:
            break;
         case leftParen:
            if ( parenLevel == 0 ) {
               parenLevel = 1 ;
               newCycle = TRUE;
            }
            else
               ERROR1s( "readCyclePerm", "Parenthesis error in permutation ",
                       perm->name, ".")
            break;
         case rightParen:
            if ( parenLevel == 1 && !newCycle ) {
               parenLevel = 0 ;
               perm->image[previousPt] = firstPtOfCycle;
            }
            else
               ERROR1s( "readCyclePerm", "Parenthesis error in permutation ",
                        perm->name, ".")
            break;
         case integer:
            pt = token.value.intValue;
            if ( parenLevel == 1 && pt >= 1 && pt <= degree &&
                                               perm->image[pt] == 0 )
               if ( newCycle ) {
                  firstPtOfCycle = pt;
                  newCycle = FALSE;
                  previousPt = pt;
               }
               else {
                  perm->image[previousPt] = pt;
                  previousPt = pt;
               }
            else
               ERROR1s( "readCyclePerm", "Invalid or repeated point in "
                        "permutation ", perm->name, ".")
            break;
         default:
            ERROR1s( "readCyclePerm", "Invalid character in permutation ",
                     perm->name, ".")
      }

   /* For any points not occuring in cycles, mark the image as the point
      itself. */
   for ( pt = 1 ; pt <= degree ; ++pt)
      if ( perm->image[pt] == 0 )
         perm->image[pt] = pt;

   /* Return to caller. */
   return token.type;
}


/*-------------------------- readImagePerm --------------------------------*/

TokenType readImagePerm(
   Permutation *perm)
{
   Unsigned pt;
   Unsigned degree = perm->degree;
   Token token;
   char *found = allocBooleanArrayDegree();;

   /* First flag all points as not occuring as images. */
   for ( pt = 1 ; pt <= degree ; ++pt )
      found[pt] = FALSE;

   /* Clear slash and then read in images of points. */
   token = readToken();
   if ( token.type != slash ) {
      ERROR1s( "readImagePerm", "Invalid syntax in image form "
               "permutation ", perm->name, ".")
   }

   pt = 0;
   while ( token = readToken() , token.type != slash)
      if ( token.type == comma )
         ;
      else if( token.type == integer && token.value.intValue > 0 &&
               token.value.intValue <= degree &&
               found[token.value.intValue] == FALSE ) {
         perm->image[++pt] = token.value.intValue;
         found[token.value.intValue] = TRUE;
      }
      else {
         ERROR1s( "readImagePerm", "Invalid syntax in image form "
                  "permutation ", perm->name, ".")
      }

   /* Check that enough images were read. */
   if ( pt != degree ) {
      ERROR1s( "readImagePerm", "Invalid syntax in image form "
               "permutation ", perm->name, ".")
   }
   if ( token = readToken() , token.type != comma && token.type != semicolon &&
                            token.type != eof && token.type != rightBracket ) {
      ERROR1s( "readImagePerm", "Invalid syntax in image form "
               "permutation ", perm->name, ".")
   }

   /* Add trailing 0 to image array. */
   perm->image[degree+1] = 0;

   /* Return to caller. */
   freeBooleanArrayDegree( found);
   return token.type;
}


/*-------------------------- readPerm -------------------------------------*/

Permutation *readPerm(
   const Unsigned degree,        /* Degree of permutation to be read. */
   PermFormat *const format,     /* Set to cycleFormat or imageFormat. */
   TokenType *const terminator)  /* Set to type of token (comma, semicolon, or
                                   eof, or right square bracket) that terminated
                                   the permutation. */
{
   Unsigned  pt;
   Token     token, token2;
   Permutation *perm;

   /* Allocate the permutation. */
   perm = allocPermutation();

   /* Mark essential field as unknown. */
   MAKE_UNKNOWN_ESSENTIAL( perm);

   /* Process permutation name if present. */
   if ( token = readToken() , token.type == identifier )
      if ( token2 = readToken() , token2.type == equal ) {
         strncpy( perm->name, token.value.identValue, MAX_NAME_LENGTH+1);
         perm->name[MAX_NAME_LENGTH] = '\0';
      }
      else
         ERROR1s( "readPerm", "Missing equal sign after name in permutation ",
                  token.value.identValue, ".")
   else {
      sprintf( perm->name, "%c%u", '_', permNumber++);
      unreadToken( token);
   }

   /* Fill in the degree. */
   perm->degree = degree;

   /* Allocate the image array, and initially mark all point images as
      unknown.  Also add trailing 0 to array. */
   perm->image = allocIntArrayDegree();
   for ( pt = 1 ; pt <= degree+1 ; ++pt )
      perm->image[pt] = 0;

   /* Check whether permutation is in cycle or image format, and call
      appropriate function to finish read. */
   switch ( token = readToken() , token.type ) {
      case leftParen:
         unreadToken( token);
         *terminator = readCyclePerm( perm);
         *format = cycleFormat;
         break;
      case slash:
         unreadToken( token);
         *terminator = readImagePerm( perm);
         *format = imageFormat;
         break;
      default:
         unreadToken( token);
         ERROR( "readPerm", "Invalid symbol at start of cycle/image field.");
   }

   /* Return to caller. */
   return perm;
}


/*-------------------------- readPermGroup --------------------------------*/

PermGroup *readPermGroup(
   char *libFileName,             /* The library file containing the group. */
   char *libName,                 /* The library defining the group. */
   const Unsigned requiredDegree, /* The degree that the group must have,
                                     or zero if group may have any degree. */
   const char *rpgOptions)        /* Options:
                                      Generate:       generate base/sgs
                                                      if absent,
                                      CompleteOrbits: construct complete orbit
                                                     structure. */
{
   FILE *libFile;
   Unsigned level;
   Permutation *perm, *oldPerm;
   PermGroup *G = allocPermGroup();
   BOOLEAN generateFlag = FALSE, completeOrbitFlag = FALSE;
   BOOLEAN genSetFlag = FALSE, strGenSetFlag = FALSE;
   PermFormat format;
   Token token;
   TokenType terminator;
   char attribute[MAX_NAME_LENGTH+1];
   char inputBuffer[81];
   RandomSchreierOptions rOptions = {0,UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN,
                                     UNKNOWN,UNKNOWN,UNKNOWN,UNKNOWN};
   /* Attempt to open library file. */
   libFile = fopen( libFileName, "r");
   if ( libFile == NULL )
      ERROR1s( "readgrp", "File ", libFileName,
               " could not be opened for input.")

   /* Process options. */
   setInputString( rpgOptions);
   while ( token = sReadToken() , token.type != eof )
      if ( token.type == identifier && strcmp( token.value.identValue,
                                               "Generate") == 0 )
         generateFlag = TRUE;
      else if ( token.type == identifier && strcmp( token.value.identValue,
                                               "CompleteOrbits") == 0 )
         completeOrbitFlag = TRUE;
      else
         ERROR( "readPermGroup", "Invalid options.")

   /* Initialize input routines to correct file. */
   setInputFile( libFile);
   lowerCase(libName);
   permNumber = 1;

   /* Search for the correct library.  Terminate with error message if
      not found. */
   rewind( libFile);
   for (;;) {
      fgets( inputBuffer, 80, libFile);
      if ( feof(libFile) )
         ERROR1s( "readPermGroup", "Library block ", libName,
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

   /* Read the group name. */
   token = nkReadToken();
   if ( token.type != identifier )
      ERROR1s( "readPermGroup",
               "Invalid syntax at start of Cayley library block ", libName,
               ".")
   strcpy( G->name, token.value.identValue);
   if ( (token = nkReadToken() , token.type != colon) ||
        (token = nkReadToken() , token.type != identifier ||
                           strcmp(token.value.identValue,"permutation") != 0) ||
        (token = nkReadToken() , token.type != identifier ||
                           strcmp(token.value.identValue,"group") != 0) ||
        (token = nkReadToken() , token.type != leftParen) ||
        (token = nkReadToken() , token.type != integer ||
                               (G->degree = token.value.intValue) < 1 ||
                               G->degree > options.maxDegree ) ||
        (token = nkReadToken() , token.type != rightParen) ||
        (token = nkReadToken() , token.type != semicolon) )
      ERROR( "readPermGroup", "Invalid syntax in group declaration.")

   /* Check that group has the required degree, if specified. */
   if ( requiredDegree > 0 && G->degree != requiredDegree)
      ERROR1s( "readPermGroup", "Group ", G->name, " has incorrect degree.")

   /* Initialize the storage manager. */
   initializeStorageManager( G->degree);

   /* Read the attributes (forder, generators, base, strong generators). */
   for (;;) {
      token  = nkReadToken();
      if ( token.type == identifier &&
           strcmp( token.value.identValue, "finish") == 0 )
         break;
      if ( strcmp( token.value.identValue, G->name) != 0 ||
           (token = nkReadToken() , token.type != period) ||
           (token = nkReadToken() , token.type != identifier) )
         ERROR( "readPermGroup", "Invalid syntax in group attribute.")
      strcpy( attribute, token.value.identValue);

      /* Read factored order. */
      if ( strcmp(attribute,"forder") == 0 &&
           (token = nkReadToken() , token.type == colon) ) {
         G->order = allocFactoredInt();
         *(G->order) = readFactoredInt();
         if ( token = nkReadToken() , token.type != semicolon )
            ERROR( "readPermGroup",
                   "Invalid syntax in group attribute.")
      }

      /* Read the base. */
      else if ( strcmp(attribute,"base") == 0 &&
               (token = nkReadToken() , token.type == colon) &&
               (token = nkReadToken() , token.type == identifier) &&
               strcmp( token.value.identValue, "seq") == 0 &&
               (token = nkReadToken() , token.type == leftParen)  ) {
         G->baseSize = 0;
         G->base = allocIntArrayBaseSize();
         G->basicOrbLen = allocIntArrayBaseSize();
         G->basicOrbit = allocPtrArrayBaseSize();
         G->schreierVec = (Permutation ***) allocPtrArrayBaseSize();
         while ( token = nkReadToken() , token.type != rightParen )
            if ( token.type == integer && token.value.intValue >= 1 &&
                                         token.value.intValue <= G->degree &&
                                         G->baseSize < options.maxBaseSize )
               G->base[++G->baseSize] = token.value.intValue;
            else if ( token.type == comma )
               ;
            else
               ERROR( "readPermGroup", "Invalid base point.")
         if ( token = nkReadToken() , token.type != semicolon )
               ERROR( "readPermGroup", "Invalid syntax in base.")
      }

      /* Read the generators. */
      else if ( strcmp(attribute,"generators") == 0 &&
           (token = nkReadToken() , token.type == colon) ) {
         if ( strGenSetFlag )
            ERROR( "readPermGroup",
                   "Both generators and strong generators were specified.");
         genSetFlag = TRUE;
         do {
            perm = readPerm( G->degree, &format, &terminator);
            if ( !G->generator ) {
               G->generator = perm;
               G->printFormat = format;
               perm->last = NULL;
            }
            else {
               oldPerm->next = perm;
               perm->last = oldPerm;
            }
            perm->next = NULL;
            oldPerm = perm;
         } while ( terminator == comma );
         if ( terminator != semicolon )
            ERROR( "readPermGroup",
                   "Invalid syntax in group attribute.")
      }

      /* Read the strong generators. */
      else if ( strcmp(attribute,"strong") == 0 &&
           (token = nkReadToken() , token.type == identifier) &&
           strcmp( token.value.identValue, "generators") == 0 &&
           (token = nkReadToken() , token.type == colon ) &&
           (token = nkReadToken() , token.type == leftBracket) ) {
         if ( genSetFlag )
            ERROR( "readPermGroup",
                   "Both generators and strong generators were specified.");
         strGenSetFlag = TRUE;
         token = nkReadToken();
         if ( token.type != rightBracket ) {
            unreadToken( token);
            do {
               perm = readPerm( G->degree, &format, &terminator);
               if ( !G->generator ) {
                  G->generator = perm;
                  G->printFormat = format;
                  perm->last = NULL;
               }
               else {
                  oldPerm->next = perm;
                  perm->last = oldPerm;
               }
               perm->next = NULL;
               oldPerm = perm;
            } while ( terminator == comma );
         }
         else
            terminator = rightBracket;
         if ( terminator != rightBracket ||
              (token = nkReadToken() , token.type != semicolon) )
            ERROR( "readPermGroup",
                   "Invalid syntax in group attribute.")
      }

      /* Handle invalid attribute. */
      else
         ERROR( "readPermGroup", "Invalid syntax in group attribute.")
   }

   /* Mark point list fields as null. */
   G->invOmega = G->omega = NULL;

   /* Adjoin generator inverses. */
   adjoinGenInverses( G);

   /* If a base is known, construct either the Schreier vectors/ basic orbits
      or the complete orbit structure, depending on whether the input option
      CompleteOrbits is present. */
   if ( G->base ) {
      G->order->noOfFactors = 0;
      for ( perm = G->generator ; perm ; perm = perm->next )
         perm->level = levelIn( G, perm);
      for ( level = 1 ; level <= G->baseSize ; ++level ) {
         G->basicOrbLen[level] = 1;
         G->basicOrbit[level] = allocIntArrayDegree();
         G->schreierVec[level] = allocPtrArrayDegree();
         if ( completeOrbitFlag ) {
            G->orbNumberOfPt = (UnsignedS **) allocIntArrayBaseSize();
            G->startOfOrbitNo = (UnsignedS **) allocIntArrayBaseSize();
            constructAllOrbitInfo( G, level);
         }
         else
            constructBasicOrbit( G, level, "AllGensAtLevel");   /*??????*/
      }
   }

   /* If a base is not known, construct one if generate option is given. */
   else if ( generateFlag )
      randomSchreier( G, rOptions);        /*????????????*/

   /* Close the input file. */
   fclose( libFile);

   /* Return the permutation group read in. */
   return G;
}


/*-------------------------- setOutputFile -------------------------------*/

void setOutputFile(
   FILE *grpFile)
{
   outFile = grpFile;
}


/*-------------------------- writeCyclePerm ------------------------------*/

#define CHECK_NEW_LINE if ( column >= endCol-4 ) {  \
                          fprintf( outFile, "\n");  \
                          for ( j = 1 ; j < startCol2 ; ++j )  \
                             fprintf( outFile, " ");  \
                          column = startCol2;  \
                       }

void writeCyclePerm(
   Permutation *s,        /* The permutation to write. */
   Unsigned startCol1,    /* First line starts in this column. */
   Unsigned startCol2,    /* Remaining lines start in this column. */
   Unsigned endCol)       /* Lines end by this column. */
{
   Unsigned j, pt, img;
   Unsigned column = startCol1;
   char *found = allocBooleanArrayDegree();

   for ( pt = 1 ; pt <= s->degree ; ++pt )
      found[pt] = FALSE;

   if ( isIdentity(s) ) {
      fprintf( outFile, "1");
      freeBooleanArrayDegree( found);
      return;
   }
   for ( pt = 1 ; pt <= s->degree ; ++pt )
      if ( !found[pt] && s->image[pt] != pt ) {
         found[pt] = TRUE;
         CHECK_NEW_LINE
         column += fprintf (outFile, "(%u,", pt);
         for ( img = s->image[pt] ; img != pt ; img = s->image[img] ) {
            CHECK_NEW_LINE
            if ( s->image[img] == pt )
               column += fprintf( outFile, "%u)", img);
            else
               column += fprintf( outFile, "%u,", img);
            found[img] = TRUE;
         }
      }

   freeBooleanArrayDegree( found);
   return;
}


/*-------------------------- writeImagePerm -------------------------------*/

void writeImagePerm(
   Permutation *s,          /* The permutation to write. */
   Unsigned startCol1,      /* First line starts in this column. */
   Unsigned startCol2,      /* Remaining lines start in this column. */
   Unsigned endCol)         /* Lines end by this column. */
{
   Unsigned i, j;
   Unsigned column = startCol1;

   fprintf( outFile, "/");
   for ( i = 1 ; i <= s->degree-1 ; ++i ) {
      CHECK_NEW_LINE
      fprintf( outFile, "%u,", s->image[i] );
      column += 2 + (s->image[i] > 9) + (s->image[i] > 99) +
                (s->image[i] > 999) + (s->image[i] > 9999);
   }
   CHECK_NEW_LINE
   fprintf( outFile, "%u/", s->image[s->degree] );
}

#undef CHECK_NEW_LINE


/*-------------------------- writeImageMonomialPerm -----------------------*/

void writeImageMonomialPerm(
   Permutation *s,          /* The permutation to write. */
   Unsigned fieldSize,
   Unsigned startCol2)      /* Remaining lines start in this column. */
{
   Unsigned i, j, count;
   const Unsigned fSize = fieldSize - 1;

   fprintf( outFile, "/");
   for ( i = 1 , count = 0; i <= s->degree-fSize ; i += fSize ) {
      fprintf( outFile, "[%u]%u,", (s->image[i] - 1) % fSize + 1,
                                   (s->image[i] - 1) / fSize + 1);
      if ( ++count == 10 ) {
         count = 0;
         fprintf( outFile, "\n");  
         for ( j = 1 ; j < startCol2 ; ++j )
            fprintf( outFile, " ");
      }
   }
   fprintf( outFile, "[%u]%u/", (s->image[i] - 1) % fSize + 1,
                                (s->image[i] - 1) / fSize + 1);
}


/*-------------------------- writePermGroup ------------------------------*/

static BOOLEAN restrictLevel = FALSE; /* Shared with writePermGroupRestricted */
                                      /* Must be reset after each call. */
void writePermGroup(
   char *libFileName,
   char *libName,
   PermGroup *G,
   char *comment)
{
   Unsigned i, column;
   Permutation *gen;
   FILE *libFile;

   /* Open output file. */
   libFile = fopen( libFileName, options.outputFileMode);
   if ( libFile == NULL )
      ERROR1s( "writePermGroup", "File ", libFileName,
               " could not be opened for append.")

   /* Set correct output File. */
   setOutputFile( libFile);

   /* Write library name. */
   fprintf( outFile, "LIBRARY %s;", libName);

   /* Write the comment. */
   if ( comment )
      fprintf( outFile, "\n& %s &", comment);

   /* Write declaration for group. */
   fprintf( outFile, "\n%s:  Permutation group (%u);", G->name, G->degree);

   /* Write the order. */
   if ( G->order ) {
      fprintf( outFile, "\n%s.forder:  ", G->name);
      writeFactoredInt( G->order);
      fprintf( outFile, ";");
   }

   /* Write the base. */
   if ( G->base ) {
      fprintf( outFile, "\n%s.base:  seq(", G->name);
      for ( i = 1 ; i < G->baseSize ; ++i )
         fprintf( outFile,  "%u,", G->base[i]);
      if ( G->baseSize > 0 )
         fprintf( outFile, "%u", G->base[G->baseSize]);
      fprintf( outFile, ");");
   }

   /* Write out the strong generators, or generators if the base is not
      known. */
   if ( G->base )
      fprintf( outFile, "\n%s.strong generators:  [", G->name);
   else
      fprintf( outFile, "\n%s.generators:", G->name);
   for ( gen = G->generator ; gen ; gen = gen->next )
      if ( gen->name[0] != '*' && 
           (!restrictLevel || gen->level <= G->baseSize) ) {
         fprintf( outFile, "\n  ");
         column = 3;
         if ( !G->base && gen->name[0] != '\0' ) {
            fprintf( outFile, "%s = ", gen->name);
            column += 3 + strlen( gen->name);
         }
         if ( G->printFormat == cycleFormat )
            writeCyclePerm( gen, column, 7, 75);
         else
            writeImagePerm( gen, column, 7, 75);
         if ( gen->next )
            fprintf( outFile, "%c", ',');
         else if ( G->base )
            fprintf( outFile, "%s", "];");
         else
            fprintf( outFile, "%s", ";");
      }
   if ( !G->generator )
      fprintf( outFile, "%s", "];");

   /* Write "finish". */
   fprintf( outFile, "\nFINISH;\n");

   /* Reset restrictLevel. */
   restrictLevel = FALSE;

   /* Close group file and return to caller. */
   fprintf( outFile, "%c", '\n');
   fclose( libFile);
   return;
}


/*-------------------------- writePermGroupRestricted --------------------*/

/* This function is identical to writePermGroup except that the group G
   is assumed to stabilize {1,...,restrictedDegree}, and it is written
   out as a permutation group of degree restrictedDegree.  (Note this
   may reduce the group order.)  Also, the group must have the order
   and base fields filled in, as well as the level field of each 
   generator.  */

void writePermGroupRestricted(
   char *libFileName,
   char *libName,
   PermGroup *G,
   char *comment,
   Unsigned restrictedDegree)
{
   Unsigned i, restrictedBaseSize;
   Unsigned *acceptablePoint = allocIntArrayDegree();
   PermGroup *GRestricted = allocPermGroup();
   FactoredInt orbitLen;
   Permutation *gen;

   for ( i = 1 ; i <= restrictedDegree ; ++i )
      acceptablePoint[i] = i;
   acceptablePoint[restrictedDegree+1] = 0;

   restrictedBaseSize = restrictBasePoints( G, acceptablePoint);

   strcpy( GRestricted->name, G->name);
   GRestricted->degree = restrictedDegree;
   GRestricted->baseSize = restrictedBaseSize;
   GRestricted->base = G->base;
   GRestricted->order = allocFactoredInt();
   *(GRestricted->order) = *(G->order);
   for ( i = restrictedBaseSize+1 ; i <= G->baseSize ; ++i ) {
      orbitLen = factorize( G->basicOrbLen[i]);
      factDivide( GRestricted->order, &orbitLen);
   }
   GRestricted->generator = G->generator;
   for ( gen = G->generator ; gen ; gen = gen->next )
      gen->degree = restrictedDegree;
   GRestricted->printFormat = G->printFormat;
   restrictLevel = TRUE;

   writePermGroup( libFileName, libName, GRestricted, comment);

   for ( gen = G->generator ; gen ; gen = gen->next )
      gen->degree = G->degree;
   restrictLevel = FALSE;         /* For safety. */
   freeFactoredInt( GRestricted->order);
   freePermGroup( GRestricted);
   freeIntArrayDegree( acceptablePoint);
}
