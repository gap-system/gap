/****************************************************************************
**
*A  GAP_link_via_file.c         ANUPQ source                   Eamonn O'Brien
*A                                                             & Frank Celler
*A                                                           & Benedikt Rothe
**
*A  @(#)$Id: GAP_link_via_file.c,v 1.14 2006/01/24 04:50:24 gap Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-1997,  School of Mathematical Sciences, ANU,     Australia
**
*H  $Log: GAP_link_via_file.c,v $
*H  Revision 1.14  2006/01/24 04:50:24  gap
*H  src/GAP_link_via_file.c:
*H    deprecated GAP code updated for version 4.4
*H  include/pq_author.h:
*H    pq program is now version 1.8
*H  standalone-doc/{README,guide.tex}:
*H    modified for version 1.8 of the pq program                           - GG
*H
*H  Revision 1.13  2004/01/26 16:45:56  werner
*H  output a newline after data
*H
*H  Revision 1.12  2002/02/15 10:09:57  gap
*H  Change due to anustab.gi being moved up a directory from gap/lib to lib. - GG
*H
*H  Revision 1.11  2001/12/21 11:50:01  gap
*H  Missing semicolon in last commit, added. - GG
*H
*H  Revision 1.10  2001/12/21 11:32:04  gap
*H  Fixed a non-incompatibility with GAP 4.2 when not pq communicates calls
*H  GAP without using an iostream. - GG
*H
*H  Revision 1.9  2001/06/25 17:17:17  gap
*H  If pq is compiled without gmp then `ANUPQsize' and `ANUPQagsize'  used  not
*H  to get assigned. Now  `src/GAP_link_via_file.c'  assigns  `fail'  to  these
*H  variables  in  this  case.  This  was  the  simplest  solution;  this   way
*H  `PqStabiliserOfAllowableSubgroup' could be passed variables in the same way
*H  as before ... a few lines in `PqStabiliserOfAllowableSubgroup' were changed
*H  to look for the possibility that `ANUPQsize = fail' (rather than is  bound)
*H  and that also takes care of `ANUPQagsize = fail'. - GG
*H
*H  Revision 1.8  2001/06/21 23:33:18  gap
*H  Cleaned out a few commented out bits of old code. - GG
*H
*H  Revision 1.7  2001/06/21 23:04:21  gap
*H  src/*, include/*, Makefile.in:
*H   - pq binary now calls itself version 1.5 (global variable PQ_VERSION
*H     added in include/pq_author.h for this)
*H   - added -v option (gives pq version)
*H   - added -G option (equivalent to `-g -i -k' + assumes talking to GAP via
*H     an iostream ... extern variable: GAP4iostream added in include/global.h
*H     for this)
*H   - some idiosyncrasies in the menus cleaned up.
*H  standalone-doc/*:
*H   - updated ... see newly added header in guide.tex for details.
*H  gap/lib/anustab.g[id]:
*H   - replace gap/lib/anustab.g ... original code is now in function
*H     `PqStabiliserOfAllowableSubgroup'
*H  init.g,read.g:
*H   - now read in gap/lib/anustab.g[id] so that `PqStabiliserOfAllowableSubgroup'
*H     is defined. ANUPQ share package now calls itself Version 1.1.
*H  gap/lib/anupqhead.g:
*H   - now uses -v option of pq to extract the version. ANUPQData.infile is no
*H     longer defined.
*H  gap/lib/*.g[id] (other):
*H   - now when not being called to create a setup file GAP calls pq with the -G
*H     option. The setup file has comment on first line telling user to use:
*H     the `-i -g -k' flags. Modifications made to call
*H     `PqStabiliserOfAllowableSubgroup' in the `ToPQ' function when a
*H     `PQ_REQUEST' is detected.
*H   - `PQ_REQUEST' takes a string as argument and returns a boolean. It detects
*H     when a `GAP, please compute stabilisers!\n' request has been emitted by
*H     the `pq' binary.
*H  - GG
*H
*H  Revision 1.6  2001/06/16 15:05:04  werner
*H  Progress (?) with talking to pq
*H
*H  Revision 1.5  2001/06/15 14:31:51  werner
*H  fucked up revision numbers.   WN
*H
*H  Revision 1.3  2001/06/15 07:41:56  werner
*H  Fixing revision number. WN
*H
*H  Revision 1.1.1.1  2001/04/15 15:09:32  werner
*H  Try again to import ANUPQ. WN
*H
*/
#if defined(GAP_LINK_VIA_FILE)

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"
#include "global.h"
#include "pq_functions.h"
#include "menus.h"


/****************************************************************************
**
*F  start_GAP_file
**          write out initial information required for stabiliser calculation
**
*/
void start_GAP_file ( GAP_input, auts, pga, pcp )
    FILE             ** GAP_input;
    int             *** auts;
    struct pga_vars   * pga;
    struct pcp_vars   * pcp;
{
   register int i;
   int nmr_soluble = pga->nmr_soluble;

   /* open "GAP_input" file                                               */
   *GAP_input = OpenSystemFile( "GAP_input", "w+" );

   if (!GAP4iostream) { /* this is necessary for GAP 4.2 compatibility    */
     fprintf( *GAP_input, "if not IsBound( PcGroupFpGroupNC ) then\n" );
     fprintf( *GAP_input, "    PcGroupFpGroupNC := PcGroupFpGroup;\n" );
     fprintf( *GAP_input, "fi;\n" );
   }

   GAP_presentation (*GAP_input, pcp, 1);
#ifdef LARGE_INT
   Magma_report_autgp_order (*GAP_input, pga, pcp);                           
#else
   fprintf( *GAP_input, "ANUPQsize := fail;;\nANUPQagsize := fail;;\n" );
#endif

   /* write global variables                                              */
   fprintf( *GAP_input, "ANUPQglb := rec();;\n"                );
   fprintf( *GAP_input, "ANUPQglb.d := %d;;\n",     pcp->ccbeg - 1);
   fprintf( *GAP_input, "ANUPQglb.F := GF(%d);;\n", pga->p     );
   fprintf( *GAP_input, "ANUPQglb.one := One (ANUPQglb.F);;\n"     );
   fprintf( *GAP_input, "ANUPQglb.q := %d;;\n",     pga->q     );
   fprintf( *GAP_input, "ANUPQglb.s := %d;;\n",     pga->s     );
   fprintf( *GAP_input, "ANUPQglb.r := %d;;\n",     pga->r     );
   fprintf( *GAP_input, "ANUPQglb.agAutos := [];;\n"              );
   fprintf( *GAP_input, "ANUPQglb.glAutos := [];;\n"              );
   fprintf( *GAP_input, "ANUPQglb.genQ := [];;\n"              );

   /* write the generators <gendp> to file                                */
   for (i = 1; i <= nmr_soluble; ++i) 
     write_GAP_matrix(*GAP_input,"ANUPQglb.agAutos",auts[i],pcp->ccbeg - 1,1,i);


#ifdef DEBUG1 
   printf ("The relative orders are ");
      for (i = 1; i <= nmr_soluble; ++i) 
          printf ("%d, ", pga->relative[i]);
      printf ("\n");
#endif

   fprintf( *GAP_input, "relativeOrders := [" );
   if (nmr_soluble > 0) {
      for (i = 1; i < nmr_soluble; ++i) 
          fprintf (*GAP_input, "%d, ", pga->relative[i]);
      fprintf (*GAP_input, "%d", pga->relative[nmr_soluble]);
   }
   fprintf (*GAP_input, "];\n");

   for (i = nmr_soluble + 1; i <= pga->m; ++i) 
     write_GAP_matrix(*GAP_input,"ANUPQglb.glAutos",auts[i],pcp->ccbeg - 1,
                      1, i - nmr_soluble);
}


/****************************************************************************
**
*F  write_GAP_matrix
**                                     write out a matrix in a GAP input form
**
*/
void write_GAP_matrix ( GAP_input, gen, A, size, start, nr ) 
    FILE      * GAP_input;
    char      * gen;
    int      ** A;
    int         size;
    int         start;
    int         nr;
{
   int         i, j;

   fprintf( GAP_input, "%s[%d] := [\n", gen, nr );
   for ( i = start;  i < start + size;  ++i )
   {
      fprintf( GAP_input, "[" );
      for ( j = start;  j < start + size - 1;  ++j )  
	 fprintf( GAP_input, "%d, ", A[i][j] );
      if ( i != start + size - 1 )
	 fprintf( GAP_input, "%d],\n", A[i][j] );
      else
	 fprintf( GAP_input, "%d]] * ANUPQglb.one;;\n", A[i][j] );
   }
}


/****************************************************************************
**
*F  insoluble_stab_gens
**          calculate the stabiliser of the supplied representative using GAP
**
*/
void insoluble_stab_gens ( rep, orbit_length, pga, pcp ) 
    int     rep;
    int     orbit_length;
    struct pga_vars *pga;
    struct pcp_vars *pcp;
{
   FILE  * GAP_rep;
   char  * path,  *command;
   char  c;
   int index;
   int *subset;
   int **S;                                                                     

   /* append the commands to compute the stabilizer                       */
   GAP_rep = OpenFile( "GAP_rep", "w+" );

   S = label_to_subgroup (&index, &subset, rep, pga);
   GAP_factorise_subgroup (GAP_rep, S, index, subset, pga, pcp);
   free_matrix (S, pga->s, 0);
   free_vector (subset, 0);                                                     
   if ( !GAP4iostream ) {
     fprintf( GAP_rep, "LoadPackage(\"autpgrp\", \"1.2\");\n" );
     fprintf( GAP_rep, "if TestPackageAvailability(" );
     fprintf( GAP_rep,        "\"anupq\", \"3.0\") <> true then\n" );
     fprintf( GAP_rep, "  ANUPQData := rec(tmpdir := DirectoryCurrent());\n" );
     fprintf( GAP_rep, "  DeclareInfoClass(\"InfoANUPQ\");\n" );
     fprintf( GAP_rep, "  DeclareGlobalFunction(" );
     fprintf( GAP_rep,        "\"PqStabiliserOfAllowableSubgroup\");\n" );
     fprintf( GAP_rep, "  ReadPackage(\"anupq\", \"lib/anustab.gi\");\n");
     fprintf( GAP_rep, "fi;\n");
     fprintf( GAP_rep, "SetInfoLevel(InfoANUPQ, 2);\n" );
   }
   fprintf( GAP_rep, "PqStabiliserOfAllowableSubgroup( ANUPQglb, F,\n" );
   fprintf( GAP_rep, "    gens, relativeOrders, ANUPQsize, ANUPQagsize );\n" );

   CloseFile( GAP_rep );

   if ( GAP4iostream ) {
     printf( "GAP, please compute stabiliser!\n" );

     /* skip a comment                                                    */
     while( (c = getchar()) == ' ' ) ;
     if ( c == '#' ) {
       while ( (c = getchar()) != '\n' ) ;
     }

     /* we expect a line: "pq, stabiliser is ready.\n"                    */
     if ( c == 'p' ) putchar( c );
     while( (c = getchar()) != '\n' ) putchar( c );
     putchar( c );
   } 
   else {
     /* try to find gap                                                   */
     if ( ( path = (char*) getenv( "ANUPQ_GAP_EXEC" ) ) == NULL )
#       if defined( ANUPQ_GAP_EXEC )
       path = ANUPQ_GAP_EXEC;
#       else
     path = "gap";
#       endif
     command = (char*) malloc( strlen(path) + 200 );
#ifdef NeXT
     strcpy( command, "exec " );
     strcat( command, path    );
#else
     strcpy( command, path );
#endif
#if 0
     strcat( command, " -r -q GAP_input < GAP_rep > GAP_log" );
#else
     strcat( command, " -r -q GAP_input < GAP_rep" );
#endif

     /* inform the user that we are about to call GAP                     */
     if (isatty (0)) 
       printf ("Now calling GAP to compute stabiliser...\n");
     unlink( "LINK_output" );

     /* compute the stabiliser of the orbit representative                */
#   if defined (SPARC) || defined(NeXT)
     if ( vsystem(command) != 0 )
#   else
       if ( system(command) != 0 )
#   endif 
       {
	 printf( "Error in system call to GAP\n" );
	 exit(FAILURE);
       }
   }

   CloseFile( OpenFile( "LINK_output", "r" ) );

   unlink( "GAP_log" );
   unlink( "GAP_rep" );
}

#endif 
