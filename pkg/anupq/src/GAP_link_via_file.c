/****************************************************************************
**
*A  GAP_link_via_file.c         ANUPQ source                   Eamonn O'Brien
*A                                                             & Frank Celler
*A                                                           & Benedikt Rothe
**
*A  @(#)$Id: GAP_link_via_file.c,v 1.20 2011/11/29 13:59:26 gap Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-1997,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"
#include "global.h"
#include "pq_functions.h"
#include "menus.h"

#if defined(GAP_LINK_VIA_FILE)

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
#ifdef HAVE_GMP
   /* report the group and automorphism group order */
   fprintf( *GAP_input, "ANUPQsize := " );
   mpz_out_str( *GAP_input, 10, &(pga->aut_order) );
   fprintf( *GAP_input, ";\n" );
   fprintf( *GAP_input, "ANUPQagsize := " );
   fprintf( *GAP_input, "%d;;\n", pga->nmr_soluble );
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
#   ifdef HAVE_WORKING_VFORK
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
