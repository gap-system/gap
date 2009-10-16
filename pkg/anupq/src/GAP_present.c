/****************************************************************************
**
*A  GAP_present.c               ANUPQ source                   Eamonn O'Brien
*A                                                             & Frank Celler
*A                                                           & Benedikt Rothe
**
*A  @(#)$Id: GAP_present.c,v 1.8 2004/01/26 20:01:53 werner Exp $
**
*Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-1997,  School of Mathematical Sciences, ANU,     Australia
**
*H  $Log: GAP_present.c,v $
*H  Revision 1.8  2004/01/26 20:01:53  werner
*H  Fixed outstanding bug, reported by Boris Girnat
*H
*H  Revision 1.7  2001/09/22 20:20:33  gap
*H  Now we don't lose the IsCapable, NuclearRank and MultiplicatorRank info. - GG
*H
*H  Revision 1.6  2001/06/15 14:31:51  werner
*H  fucked up revision numbers.   WN
*H
*H  Revision 1.4  2001/06/15 07:43:30  werner
*H  Fixing revision number. WN
*H
*H  Revision 1.2  2001/04/16 11:04:04  werner
*H  Incorporated Eamonn's changes to report the rank of the
*H  p-multiplicator.						WN
*H
*H  Revision 1.1.1.1  2001/04/15 15:09:32  werner
*H  Try again to import ANUPQ. WN
*H
*H  Revision 1.1.1.1  1998/08/12 18:51:00  gap
*H  First attempt at adapting the ANU pq to GAP 4. 
*H
*/
#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "constants.h"
#include "pq_functions.h"
#include "menus.h"


/****************************************************************************
**
*F  print_GAP_word
**                                     print out a word of a pcp presentation
*/
void print_GAP_word ( file, ptr, pcp )
    FILE_TYPE           file;
    int                 ptr;
    struct pcp_vars   * pcp;
{
#include "define_y.h"

   int                 gen,  exp;
   int                 i;
   int                 count;
#include "access.h"

   if ( ptr == 0 )
      fprintf( file, " One(F)" );
   else if ( ptr > 0 )
      fprintf( file, " F.%d", ptr );
   else
   {
      ptr = -ptr + 1;
      count = y[ptr];
      fprintf( file, " %s", ( 1 < count ) ? "(" : "" );
      for ( i = 1;  i <= count; i++ )
      {
	 exp = FIELD1(y[ptr + i]);
	 gen = FIELD2(y[ptr + i]);
	 fprintf( file, "F.%d", gen );
	 if ( exp != 1 )
            fprintf( file, "^%d", exp );
	 if ( i != count )
            fprintf( file, "*" );
      }
      if ( 1 < count )  fprintf (file, ")");
   }
}


/****************************************************************************
**
*F  GAP_presentation
**                                write pq presentation to file in GAP format
*/
void GAP_presentation ( file, pcp, aspcgroup )
    FILE_TYPE           file;
    struct pcp_vars   * pcp;
    int                 aspcgroup;
{
#include "define_y.h"

   int                 i;
   int                 j;
   int                 k;
   int                 l;
   int                 p1;
   int                 p2;
   int                 weight;
   int                 comma;
   int                 ndgen = pcp->ndgen;
   int                 dgen = pcp->dgen;

#include "access.h"

   /* construct a free group with enough generators                       */
   fprintf( file, "F := FreeGroup( %d );\n",  pcp->lastg );

   if( aspcgroup ) {
     fprintf( file, "F := PcGroupFpGroupNC( F / [\n" );
   }
   else
     fprintf( file, "F := F / [\n" );

   /* write power-relators with possible non-trivial rhs                  */
   comma = 0;
   k = y[pcp->clend + pcp->cc - 1];
   for ( i = 1;  i <= k;  i++ )
   {
      if ( comma )  fprintf( file, ",\n" );  else comma = 1;
      p2 = y[pcp->ppower + i];
      if ( p2 == 0 )
	 fprintf( file, " F.%d^%d", i, pcp->p );
      else
      {
	 fprintf( file, " F.%d^%d /", i, pcp->p );
	 print_GAP_word( file, p2, pcp );
      }
   }
            
   /* write power-relators with trivial rhs                               */
   for ( i = k + 1;  i <= pcp->lastg;  ++i )
   {
      if ( comma )  fprintf( file, ",\n" );  else comma = 1;
      fprintf( file, " F.%d^%d", i, pcp->p );
   }
    
   /* write commutator-relators                                           */
   for ( i = 2;  i <= k;  i++ )
   {
      weight = WT(y[pcp->structure + i]);
      p1 = y[pcp->ppcomm + i];
      l = MIN( i - 1, y[pcp->clend + pcp->cc - weight] );
      for ( j = 1; j <= l; j++ )
      {
	 p2 = y[p1 + j];
	 if ( p2 != 0 )
	 {
	    fprintf( file, ",\n" );
	    fprintf( file, " Comm( F.%d, F.%d ) /", i, j );
	    print_GAP_word( file, p2, pcp );
	 }
      }
   }

   if( aspcgroup ) fprintf( file, "] );\n" );
   else            fprintf( file, "];\n" );

   /* store the relation between pc gens and fp gens                      */
   fprintf( file, "MapImages := [];\n" );
   for  ( i = 1;  i <= ndgen;  i++ )
   {
      p2 = y[dgen+i];
      fprintf( file, "MapImages[%d] := ", i );
      print_GAP_word( file, p2, pcp );
      fprintf( file, ";\n" );
   }
}


/****************************************************************************
**
*F  MakeNameList
**                             create p-group generation identifier for group  
*/
char * nextnumber ( ident )
    char  * ident;
{
   while ( *ident != '\0' && *ident != '#' )
      ident++;
   if ( *ident == '#' )
      ident++;
   return ident;
}

void MakeNameList ( file, ident )
    FILE_TYPE   file;
    char      * ident;
{
   int         first = 1;

   fprintf( file, "SetANUPQIdentity( F, [ " );
   while ( *(ident = nextnumber(ident)) != '\0' )
   {
      if (!first)
	 fprintf( file, "," );
      first = 0;
      fprintf(file, "[");
      do
	 fprintf( file, "%c", *ident );
      while ( *++ident != ';' );
      ident++;
      fprintf( file, "," );
      do
      {
	 fprintf( file, "%c", *ident );
	 ident++;
      }
      while ( '0' <= *ident && *ident <='9');
      fprintf( file, "]" );
   }
   fprintf( file, " ] );\n" );
}


/****************************************************************************
**
*F  write_GAP_library
**               write GAP library file in form suitable for reading into GAP
*/
int countcall = 0;

void write_GAP_library ( file, pcp )
    FILE_TYPE         file;
    struct pcp_vars * pcp;
{
   /* if this is the first call initialise 'ANUgroups'                    */
   if ( countcall == 0 ) 
   {
      fprintf( file, "ANUPQgroups := [];\n"                           );
      fprintf( file, "ANUPQautos  := [];\n\n"                         );
   }
   countcall++;

   /* write function call to <countcall>.th position of <ANUPQgroups>     */
   fprintf( file, "## group number: %d\n", countcall              );
   fprintf( file, "ANUPQgroups[%d] := function( L )\n", countcall );
   fprintf( file, "local   MapImages,  F;\n\n"        );

   /* write the GAP presentation to file                                  */
   GAP_presentation( file, pcp, 0 );

   /* convert <F> to a pc group in descendants case
      ... has to be done here; otherwise, we lose the property/attributes */
   fprintf( file, "if IsList(L) then\n    F := PcGroupFpGroupNC(F);\nfi;\n" ); 

   /* add info. whether group is capable, and its nuclear and mult'r ranks*/
   fprintf( file, "SetIsCapable(F, %s);\n", (pcp->newgen)?"true":"false" );
   fprintf( file, "SetNuclearRank(F, %d);\n", pcp->newgen                  );
   fprintf( file, "SetMultiplicatorRank (F, %d);\n", pcp->multiplicator_rank );

   /* add the pq identitfier                                              */
   MakeNameList( file, pcp->ident );

   /* add the group <F> to <L>                                            */
   fprintf( file, "if IsList(L) then\n    Add( L, F );\n" ); 
   fprintf( file, "else\n    L.group := F;\n    L.map := MapImages;\nfi;" );

   fprintf( file, "\nend;\n\n\n"       );
}


/****************************************************************************
**
*F  GAP_auts
**               write a description of the automorphism group of the current
**                      group to a file in a format suitable for input to GAP
*/
void GAP_auts ( file, central, stabiliser, pga, pcp )
    FILE_TYPE           file;
    int             *** central;
    int             *** stabiliser;
    struct pga_vars   * pga;
    struct pcp_vars   * pcp;
{
#include "define_y.h"

   int                 i, j, k, ngens,  first;

   /* if this is the first call something is wrong  '                     */
   if ( countcall == 0 )
   {
      fprintf( stderr, "internal error in 'GAP_auts'" );
      exit( FAILURE );
   }

   /* write function call to <countcall>.th position of <ANUPQgroups>     */
   fprintf( file, "## automorphisms number: %d\n", countcall             );
   fprintf( file, "ANUPQautos[%d] := function( G )\n", countcall         );
   fprintf( file, "local   frattGens,\n"                                 );
   fprintf( file, "        relOrders,\n"                                 );
   fprintf( file, "        centralAutos,\n"                              );
   fprintf( file, "        otherAutos;\n"                                );


   /* write information about automorphisms to file                       */
   ngens= y[pcp->clend + 1];
   fprintf(file,"SetIsPcgsAutomorphisms(G,%s);\n",pga->soluble?"true":"false");
   fprintf(file,"SetIsCapable(G,%s);\n", pga->capable ? "true" : "false"  );

   /* first write the Frattini generators                                 */
   fprintf( file, "frattGens := ["                                        );
   for ( k = 1;  k <= ngens; k++ )
   {
      if ( k != 1 )
	 fprintf( file, "," );
      fprintf( file, "G.%d", k );
   }
   fprintf( file, "];\n" );

   fprintf (file, "centralAutos := [];  # nr of central autos: %d\n", 
            pga->nmr_centrals );

   /* write out all central automorphisms                                 */
   for ( i = 1;  i <= pga->nmr_centrals;  ++i )
   {
      fprintf( file, "Add( centralAutos, [" );
      for ( j = 1;  j <= pga->ndgen;  ++j )
      {
	 if ( j != 1 )
            fprintf( file, "," );
	 first = 1;
	 for ( k = 1;  k <= pcp->lastg;  ++k )
	 {
	    if ( 0 != central[i][j][k] )
	    {
	       if ( !first )
		  fprintf( file, "*" );
	       first = 0;
	       if ( 1 != central[i][j][k] )
		  fprintf( file, "G.%d^%d", k, central[i][j][k] );
	       else
		  fprintf( file, "G.%d", k );
	    }
	 }
	 if ( first )
	 {
	    fprintf( stderr, "internal error in 'GAP_auts'\n" );
	    exit( FAILURE );
	 }
      }
      fprintf( file, "] );\n" );
   }

   
   fprintf (file, "otherAutos := [];  # nr of other autos: %d\n", 
            pga->nmr_stabilisers );

   /* write out all other automorphisms                                   */
   for ( i = 1;  i <= pga->nmr_stabilisers;  ++i )
   {
      fprintf( file, "Add( otherAutos, [" );
      for ( j = 1;  j <= pga->ndgen;  ++j )
      {
	 if ( j != 1 )
            fprintf( file, "," );
	 first = 1;
	 for ( k = 1;  k <= pcp->lastg;  ++k )
	 {
	    if ( 0 != stabiliser[i][j][k] )
	    {
	       if ( !first )
		  fprintf( file, "*" );
	       first = 0;
	       if ( 1 != stabiliser[i][j][k] )
		  fprintf( file, "G.%d^%d", k, stabiliser[i][j][k] );
	       else
		  fprintf( file, "G.%d", k );
	    }
	 }
	 if ( first )
	 {
	    fprintf( stderr, "internal error in 'GAP_auts'\n" );
	    exit( FAILURE );
	 }
      }
      fprintf( file, "] );\n" );
   }


   fprintf( file , "relOrders := [");
   if (pga->nmr_soluble > 0) {
     for (i = 1; i <= pga->nmr_soluble; ++i)
       fprintf (file, "%d, ", pga->relative[i]);
     fprintf (file, "%d", pga->relative[pga->nmr_soluble]);
   }
   fprintf (file, "];\n");


   fprintf( file, "ANUPQSetAutomorphismGroup( " );
   fprintf( file, "G, frattGens, centralAutos, otherAutos, relOrders, " );
   fprintf( file, "%s );\n", pga->soluble?"true":"false"); 
   fprintf( file, "end;\n\n\n" );
}
