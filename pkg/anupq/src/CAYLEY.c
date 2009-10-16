/****************************************************************************
**
*A  CAYLEY.c                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: CAYLEY.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pga_vars.h"
#include "pcp_vars.h"
#include "pq_functions.h"
#include "constants.h"

#define CAYLEY_WORKSPACE 500000

/* write out permutations to file in suitable form for input to CAYLEY */

void write_CAYLEY_permutation (CAYLEY_input, nmr_of_permutation, perms, pga)
FILE *CAYLEY_input;
int nmr_of_permutation;
int *perms;
struct pga_vars *pga;
{
   register int i;
   
   fprintf (CAYLEY_input, "p%d = /", nmr_of_permutation);
   for (i = 1; i < pga->Degree; ++i) {
      fprintf (CAYLEY_input, "%d, ", perms[i]);
      if (i % 20 == 0)
	 fprintf (CAYLEY_input, "\n");
   }

   fprintf (CAYLEY_input, "%d/ of permgp;\n", perms[pga->Degree]);
}

/* write out initial information required for stabiliser calculation */

void start_CAYLEY_file (CAYLEY_input, auts, pga)
FILE **CAYLEY_input;
int ***auts;
struct pga_vars *pga;
{
   register int i, j;
   register int value, factor;
   int *subset;

   *CAYLEY_input = OpenFile ("CAYLEY_input", "w+");

   fprintf (*CAYLEY_input, "set workspace = %d;\n", CAYLEY_WORKSPACE);
   fprintf (*CAYLEY_input, "p = %d; nmg = %d;\n", pga->p, pga->ndgen);
   fprintf (*CAYLEY_input, "f = field (p); glnp = general linear (nmg, f);\n");
   fprintf (*CAYLEY_input, "gen = seq (identity);\n");
   fprintf (*CAYLEY_input, "nmrgens = %d;\n", pga->q);
   fprintf (*CAYLEY_input, "glqp = general linear (nmrgens, f);\n");
   fprintf (*CAYLEY_input, "genq = seq (identity) of glqp;\n");

   for (i = 1; i <= pga->m; ++i)
      write_CAYLEY_matrix (*CAYLEY_input, "gen", "glnp",
			   auts[i], pga->ndgen, 1, i);
                                                       
   fprintf (*CAYLEY_input, "nsteps = %d; nmrids = %d; t = %d;\n", 
	    pga->s, pga->nmr_def_sets, pga->m);

   fprintf (*CAYLEY_input, "holdid = seq (");
   factor = pga->q >= 10 ? 100 : 10;
   for (i = 0; i < pga->nmr_def_sets; ++i) {
      subset = bitstring_to_subset (pga->list[i], pga);
      value = 0;
      for (j = pga->s - 1; j >= 0; --j) 
	 value += (subset[j] + 1) * int_power (factor, pga->s - 1 - j);
      if (i != pga->nmr_def_sets - 1)
	 fprintf (*CAYLEY_input, "%d, ", value);
      else 
	 fprintf (*CAYLEY_input, "%d);\n", value);
      if (i % 20 == 0)
	 fprintf (*CAYLEY_input, "\n");
      free_vector (subset, 0);
   }      

   fprintf (*CAYLEY_input, "len = seq (");
   for (i = 0; i < pga->nmr_def_sets - 1; ++i) {
      fprintf (*CAYLEY_input, "%d, ", pga->available[i]);
      if (i % 20 == 0)
	 fprintf (*CAYLEY_input, "\n");
   }
   fprintf (*CAYLEY_input, "%d);\n", pga->available[i]);
}

/* write out a matrix in a CAYLEY input form */

void write_CAYLEY_matrix (CAYLEY_input, gen, string, A, size, start,
                          nmr_of_generator) 
FILE *CAYLEY_input;
char *gen;
char *string;
int **A;
int size;
int start;
int nmr_of_generator;
{
   register int i, j;

   fprintf (CAYLEY_input, "%s[%d] = mat (\n", gen, nmr_of_generator);

   for (i = start; i < start + size; ++i) {
      for (j = start; j < start + size - 1; ++j)  
	 fprintf (CAYLEY_input, "%d, ", A[i][j]);
      if (i != start + size - 1)
	 fprintf (CAYLEY_input, "%d:\n", A[i][j]);
      else
	 fprintf (CAYLEY_input, "%d) of %s;\n", A[i][j], string);
   }
}

#if defined (CAYLEY_LINK)

/* calculate the stabiliser of the supplied representative using CAYLEY */

void insoluble_stab_gens (rep, orbit_length) 
int rep;
int orbit_length;
{
   char *path, *script, *command;
   FILE_TYPE CAYLEY_rep;

   CAYLEY_rep = OpenFile ("CAYLEY_rep", "w+");
   fprintf (CAYLEY_rep, "r = seq(%d);\n", rep);
   fprintf (CAYLEY_rep, "orblen = seq(%d);\n", orbit_length);
   fprintf (CAYLEY_rep, "library stabcalc;\n");
   CloseFile (CAYLEY_rep); 

   /* compute the stabiliser of the orbit representative */

   path = (char *) getenv ("CAYLEY_DIR");
   if (path == NULL) {
      printf ("You must set the environment variable CAYLEY_DIR -- see Release Notes\n");
      exit (FAILURE);
   }
   
   script = "/CAYLEY_script";
   command = (char *) malloc ((1 + strlen (path) + strlen (script)) * 
                              sizeof(char)); 
   strcpy (command, path);
   strcat (command, script);
   if (isatty (0))
      printf ("Now calling CAYLEY to compute stabiliser...\n");

#if defined (SPARC) 
   if (vsystem (command) != 0) {
#else 
   if (system (command) != 0) {
#endif 
      printf ("Error in system call to CAYLEY\n");
      exit (FAILURE);
   }
   free (command);
}

#endif 
