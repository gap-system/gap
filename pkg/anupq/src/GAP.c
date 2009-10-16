/****************************************************************************
**
*A  GAP.c                      ANUPQ source                    Eamonn O'Brien
*A                                                             & Frank Celler
**
*A  @(#)$Id: GAP.c,v 1.6 2002/02/15 15:08:49 gap Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1997-1997,  School of Mathematical Sciences, ANU,     Australia
**
*H  $Log: GAP.c,v $
*H  Revision 1.6  2002/02/15 15:08:49  gap
*H  Included -r option in GAP call as per suggestion by SL. - GG
*H
*H  Revision 1.5  2001/06/15 14:31:51  werner
*H  fucked up revision numbers.   WN
*H
*H  Revision 1.3  2001/06/15 07:43:14  werner
*H  Fixing revision number. WN
*H
*H  Revision 1.1.1.1  2001/04/15 15:09:32  werner
*H  Try again to import ANUPQ. WN
*H
*/
#if defined (GAP_LINK) 

#include "pq_defs.h"
#include "pga_vars.h"
#include "pcp_vars.h"
#include "pq_functions.h"
#include "constants.h"


/****************************************************************************
**
*V  p1, p2
*/
int     p1[2],  p2[2];


/****************************************************************************
**
*F  WriteGap( <str> )
**                                          write <str> to gap via input pipe
*/
void    WriteGap ( str )
    char  * str;
{
   write( p2[1], str, strlen (str) );
}


/****************************************************************************
**
*F  ReadGap( <str> )
**                     read string from gap via output pipe into buffer <str>
*/
void    ReadGap ( str )
    char  * str;
{
   char  * ptr;

   /* read next line                                                      */
   ptr = str;
   do
      while ( read( p1[0], ptr, 1 ) != 1)
	 ;
   while ( *ptr++ != '\n' );

   /* append a trailing '\0'                                              */
   *(--ptr) = 0;

   /* if line begins with a '#' ignore this line and start again          */
   if ( *str == '#' )
   {
      fprintf( stderr, "%s\n", str );
      ReadGap( str );
   }
}


/****************************************************************************
**
*F  WriteGapInfo( <auts>, <pga> )
**                                write initial information to GAP input pipe
*/
void    WriteGapInfo ( auts, pga )
    int             *** auts;
    struct pga_vars   * pga;
{
   int                 i;
   char                str[MAXWORD];

   /* we need the GAP library files defined in the package "anupq"        */
   WriteGap( "RequirePackage( \"anupq\" );\n" );

   /* give debug information if 'ANUPQlog' is set to 'LogTo'              */
   WriteGap( "ANUPQlog( \"debug.out\" );\n"    );

   /* use a record 'ANUPQglb' to hold all global variables                */
   WriteGap( "ANUPQglb := rec();;\n" );
   sprintf( str, "ANUPQglb.d := %d;\n", pga->ndgen     );
   WriteGap( str );  ReadGap( str );
   sprintf( str, "ANUPQglb.F := GF(%d);\n", pga->p     );
   WriteGap( str );  ReadGap( str );
   sprintf( str, "ANUPQglb.q := %d;\n", pga->q         );
   WriteGap( str );  ReadGap( str );
   sprintf( str, "ANUPQglb.genD := [];\n"              );
   WriteGap( str );  ReadGap( str );
   sprintf( str, "ANUPQglb.genQ := [];\n"              );
   WriteGap( str );  ReadGap( str );
   for ( i = 1;  i <= pga->m; ++i ) 
      write_GAP_matrix( 0, "ANUPQglb.genD", auts[i], pga->ndgen, 1, i );
}


/****************************************************************************
**
*F  start_GAP_file( <auts>, <pga> )
**       start GAP process or write necessary information to existing process
*/
void    start_GAP_file (auts, pga)
    int             *** auts;
    struct pga_vars   * pga;
{
   int                 pid;
   char              * path;
   int                 i;
   char                tmp[200];

   pipe(p1);
   pipe(p2);
#if defined(SPARC) || defined(NeXT)
   if ( (pid = vfork()) == 0 )
#else
      if ( (pid = fork()) == 0 )
#endif
      {
	 dup2( p1[1], 1 );
	 dup2( p2[0], 0 );
	 if ( ( path = (char*) getenv( "ANUPQ_GAP_EXEC" ) ) == NULL )
#           if defined( ANUPQ_GAP_EXEC )
	    path = ANUPQ_GAP_EXEC;
#           else
	 path = "gap";
#           endif
	 if ( execlp( path, path, "-r -q", 0 ) == -1 )
	 {
            perror( "Error in system call to GAP" );
            exit( FAILURE );
	 }
      }
      else if ( pid == -1 )
      {
	 perror( "cannot fork" );
	 exit( FAILURE );
      }
      else
      {

	 /* write GAP information to file                                   */
	 WriteGapInfo( auts, pga );

	 /* try to syncronise with gap process                              */
	 WriteGap("165287638495312637;\n");
	 for ( i = 0;  i < 100;  i++ )
	 {
            ReadGap(tmp);
            if ( !strcmp(tmp,"165287638495312637") )
	       break;
	 }
	 if ( i == 100 )
	    fprintf( stderr, "WARNING: did not got magic number, got '%s'\n",
		     tmp );
      }
}


/****************************************************************************
**
*F  QuitGap()
**                                                     close the pipes to GAP
*/
void QuitGap ()
{
   WriteGap( "quit;\n" );
   close(p1[1]);
   close(p2[1]);
   close(p1[0]);
   close(p2[0]);
   wait( (int *) 0 );
}


/****************************************************************************
**
*F  ReadFromGapPipe( <value> )
**  read a string from the GAP output pipe and check whether it is an integer
*/
void    ReadFromGapPipe (value)
    int       * value;
{
   Logical     error;
   char        str[MAXWORD];

   ReadGap(str);
   *value = string_to_int(str, &error);
   if (error)
   {
      fprintf(stderr, "Error in reading stabiliser data from GAP pipe\n");
      fprintf(stderr, "got line: '%s'\n", str                           );
      exit (FAILURE);
   }
}


/****************************************************************************
**
*F  read_stabiliser_gens( <nr>, <sol>, <pga> )
**                    read the insoluble stabiliser generators from the pipe;
**                    each list of stabilisers is preceded by two integers -- 
**                     the first indicates whether the stabiliser is soluble; 
**                  the second is the number of generators for the stabiliser
*/
int     *** read_stabiliser_gens ( nr_gens, sol_gens, pga )
    int                 nr_gens;
    int             *** sol_gens;
    struct pga_vars   * pga;
{
   int                 ndgen = pga->ndgen;
   int                 gamma,  i,  j;
   int             *** stabiliser;
   int                 current;

   /* check if any gens for the stabiliser have already been computed     */
   current = pga->nmr_stabilisers;

   /* read the first two integers (is soluble and number of generators)   */
   ReadFromGapPipe(&pga->soluble);
   ReadFromGapPipe(&pga->nmr_stabilisers);
    
   /* get enough room for the generators                                  */
   pga->nmr_stabilisers += current;

   /* memory leakage September 1996 */
   stabiliser = reallocate_array( sol_gens, current, ndgen, 
				  nr_gens, pga->nmr_stabilisers,
				  ndgen, nr_gens, TRUE );
/* 
   if (current != 0) {
   stabiliser = reallocate_array( sol_gens, current, ndgen, 
   nr_gens, pga->nmr_stabilisers,
   ndgen, nr_gens, TRUE );
   }
   else {
   stabiliser = allocate_array( pga->nmr_stabilisers, ndgen, 
   nr_gens, TRUE );
   }
   */

   /* now read in the insoluble generators                                */
   for ( gamma = current + 1;  gamma <= pga->nmr_stabilisers;  ++gamma ) 
      for ( i = 1;  i <= ndgen;  ++i ) 
	 for ( j = 1;  j <= ndgen;  ++j )
	    ReadFromGapPipe(&stabiliser[gamma][i][j]);

   /* return the result                                                   */
   return stabiliser; 
}


/****************************************************************************
**
*F  insoluble_stab_gens( <rep>, <orbit_length> )
**          calculate the stabiliser of the supplied representative using GAP
*/
void    insoluble_stab_gens (rep, orbit_length) 
    int     rep;
    int     orbit_length;
{
   char    str[MAXWORD];

   sprintf( str, "stab := ANUPQstabilizer( %d, %d, ANUPQglb );;1;\n",
	    rep, orbit_length );
   WriteGap(str);  ReadGap(str);
   sprintf( str, "ANUPQoutputResult( stab, \"*stdout*\" );;\n" );
   WriteGap(str);
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
   char        str[MAXWORD];

   sprintf( str, "%s[%d] := [\n", gen, nr );
   WriteGap(str);
   for ( i = start;  i < start + size;  ++i )
   {
      WriteGap( "[" );
      for ( j = start;  j < start + size - 1;  ++j )
      {
	 sprintf( str, "%d, ", A[i][j] );
	 WriteGap(str);
      }
      if ( i != start + size - 1 )
	 sprintf( str, "%d],\n", A[i][j] );
      else
	 sprintf( str, "%d]] * One( ANUPQglb.F );;\n", A[i][j] );
      WriteGap(str);
   }
}


/****************************************************************************
**
*F  StartGapFile( <pga> )
**                            write basic input information to GAP input pipe
*/
void    StartGapFile (pga)
    struct pga_vars   * pga;
{
   char                str[MAXWORD];

   sprintf( str, "ANUPQglb.s := %d;\n", pga->s );
   WriteGap( str );  ReadGap( str );
   sprintf( str, "ANUPQglb.r := %d;\n", pga->r );
   WriteGap( str );  ReadGap( str );
}


#endif 

