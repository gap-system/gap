/****************************************************************************
**
*A  Magma.c                     ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: Magma.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (Magma_LINK) 
#include "pq_defs.h"
#include "pga_vars.h"
#include "pcp_vars.h"
#include "pq_functions.h"
#include "constants.h"

/* write out permutations to file in suitable form for input to Magma */

void write_Magma_permutation (Magma_input, nmr_of_permutation, perms, pga)
FILE *Magma_input;
int nmr_of_permutation;
int *perms;
struct pga_vars *pga;
{
   register int i;
   
   fprintf (Magma_input, "p%d := \\[", nmr_of_permutation);
   for (i = 1; i < pga->Degree; ++i) {
      fprintf (Magma_input, "%d, ", perms[i]);
      if (i % 20 == 0)
	 fprintf (Magma_input, "\n");
   }

   fprintf (Magma_input, "%d];\n", perms[pga->Degree]);
}

/* write out initial information required for stabiliser calculation */

void start_Magma_file (Magma_input, auts, pga)
FILE **Magma_input;
int ***auts;
struct pga_vars *pga;
{
   register int i, j;
   register int value, factor;
   int *subset;

   *Magma_input = OpenFile ("Magma_input", "w+");

   fprintf (*Magma_input, "p := %d; nmg := %d;\n", pga->p, pga->ndgen);
   fprintf (*Magma_input, "f := FiniteField (p); glnp := GL (nmg, f);\n");
   fprintf (*Magma_input, "gen := [Id (glnp)];\n");
   fprintf (*Magma_input, "nmrgens := %d;\n", pga->q);
   fprintf (*Magma_input, "glqp := GL (nmrgens, f);\n");
   fprintf (*Magma_input, "genq := [Id (glqp)];\n");

   for (i = 1; i <= pga->m; ++i)
      write_Magma_matrix (*Magma_input, "gen", "glnp",
			  auts[i], pga->ndgen, 1, i);
                                                       
   fprintf (*Magma_input, "nsteps := %d; nmrids := %d; t := %d;\n", 
	    pga->s, pga->nmr_def_sets, pga->m);

   fprintf (*Magma_input, "holdid := [");
   factor = pga->q >= 10 ? 100 : 10;
   for (i = 0; i < pga->nmr_def_sets; ++i) {
      subset = bitstring_to_subset (pga->list[i], pga);
      value = 0;
      for (j = pga->s - 1; j >= 0; --j) 
	 value += (subset[j] + 1) * int_power (factor, pga->s - 1 - j);
      if (i != pga->nmr_def_sets - 1)
	 fprintf (*Magma_input, "%d, ", value);
      else 
	 fprintf (*Magma_input, "%d];\n", value);
      if (i % 20 == 0)
	 fprintf (*Magma_input, "\n");
      free_vector (subset, 0);
   }      

   fprintf (*Magma_input, "len := [");
   for (i = 0; i < pga->nmr_def_sets - 1; ++i) {
      fprintf (*Magma_input, "%d, ", pga->available[i]);
      if (i % 20 == 0)
	 fprintf (*Magma_input, "\n");
   }
   fprintf (*Magma_input, "%d];\n", pga->available[i]);
}

/* write out a matrix in a Magma input form */

void write_Magma_matrix (Magma_input, gen, string, A, size, start,
                          nmr_of_generator) 
FILE *Magma_input;
char *gen;
char *string;
int **A;
int size;
int start;
int nmr_of_generator;
{
   register int i, j;

   fprintf (Magma_input, "%s[%d] := %s![\n", gen, nmr_of_generator, string);

   for (i = start; i < start + size; ++i) {
      for (j = start; j < start + size - 1; ++j)  
	 fprintf (Magma_input, "%d, ", A[i][j]);
      if (i != start + size - 1)
	 fprintf (Magma_input, "%d,\n", A[i][j]);
      else
	 fprintf (Magma_input, "%d];\n", A[i][j]);
 
   }
}

/* calculate the stabiliser of the supplied representative using Magma */

void insoluble_stab_gens (rep, orbit_length) 
int rep;
int orbit_length;
{
   char *path, *script, *command;
   FILE_TYPE Magma_rep;

   Magma_rep = OpenFile ("Magma_rep", "w+");
   fprintf (Magma_rep, "r := [%d];\n", rep);
   fprintf (Magma_rep, "orblen := [%d];\n", orbit_length);

   path = (char *) getenv ("Magma_DIR");
   if (path == NULL) {
      printf ("You must set the environment variable Magma_DIR -- see Release Notes\n");
      exit (FAILURE);
   }

   fprintf (Magma_rep, "load \"%s/", path);
   fprintf (Magma_rep, "stabcalc.m\";\n");
   CloseFile (Magma_rep); 

   /* compute the stabiliser of the orbit representative */

   script = "/Magma_script";
   command = (char *) malloc ((1 + strlen (path) + strlen (script)) * 
                              sizeof(char)); 
   strcpy (command, path);
   strcat (command, script);
   if (isatty (0))
      printf ("Now calling Magma to compute stabiliser...\n");

#if defined (SPARC) 
   if (vsystem (command) != 0) {
#else 
   if (system (command) != 0) {
#endif 
      printf ("Error in system call to Magma\n");
      exit (FAILURE);
   }
   free (command);
}

#endif
