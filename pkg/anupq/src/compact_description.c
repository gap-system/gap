/****************************************************************************
**
*A  compact_description.c       ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: compact_description.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"
#include "constants.h"

/******************************************************************************
 **  AUTHOR:     C. Rhodes
 **  DATE:       21/1/93
 **  REVISION:   1.0   (Release)
 **  STATUS:     This code is designed to be an extension to the pq program
 **              by E.A. O'Brien. It encodes the pc-presentation into a 
 **              sequence of integers and then appends that sequence to a 
 **              file called gps<order>, where <order> is the order of the
 **              group. Note that existing files of this name are updated.
 ****************************************************************************/

#if defined (LARGE_INT)

MP_INT Encode (p, length, list)
int p;
int length;
int *list;
{
  MP_INT powers, code;
  int i;
  MP_INT factor;

  mpz_init_set_ui (&code, 0);

  for (i = 1; i <= length; ++i) {
     mpz_init_set_si (&powers, 0);
     if (list[i] != 0) 
        mpz_ui_pow_ui (&powers, p, i-1);
     mpz_add (&code, &code, &powers);
  }
/*
     if (list[i] != 0) {
        mpz_init_set_si (&factor, list[i]);
        mpz_ui_pow_ui (&powers, p, i);
        mpz_mul (&powers, &powers, &factor);
        mpz_add (&code, &code, &powers);
     }
  }
*/
  return code;
}
#endif

/* construct a compact description of the group as a sequence;
   if write_to_file TRUE, then write the compact description, 
   sequence, to file and also return it */

int *compact_description (write_to_file, pcp)
Logical write_to_file;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int p1;
   register int p2;
   int *sequence;
   int nmr_of_exponents;
   int weight_g, weight_h;
   int g, h;
   int generator;
   int offset;
   int index;  /* used to count current position in sequence of exponents */
   int n;          
#include "access.h"

   n = pcp->lastg;
   nmr_of_exponents = choose (n + 1, 3);
   sequence = allocate_vector (nmr_of_exponents, 1, TRUE);
   
   offset = 0;
   index = 0;

   if (pcp->cc == 1) {
      /* write the sequence to a file */
      output_information (sequence, nmr_of_exponents, pcp);
      return sequence;
   }

   for (generator = 2; generator <= n; ++generator) {

      /* examine all power relations g^p where g < generator and store 
	 all exponents of generator which occur in these relations */

      for (g = 1; g < generator; ++g) {
	 p1 = y[pcp->ppower + g];
         
	 trace_relation (sequence, &index, p1, generator, pcp);

	 /* examine all commutator relations [h, g] where g < h < generator 
	    and store exponents of generator which occur in such relations */

	 weight_g = WT(y[pcp->structure + g]);
         
	 /* is the relation [h, g] stored? */ 
	 for (h = g + 1; h < generator; ++h) {
	    weight_h = WT(y[pcp->structure + h]);
	    if (weight_g + weight_h <= pcp->cc) {
	       p1 = y[pcp->ppcomm + h];
	       p2 = y[p1 + g];
	       trace_relation (sequence, &index, p2, generator, pcp);
	    }
	    else 
	       ++index;
	 }
      }

      offset += (generator - 1) * (generator - 2) / 2 + (generator - 1);
      index = offset;
   }

#if defined (DEBUG)
   print_array (sequence, 1, nmr_of_exponents);
#endif 

   /* write the sequence to a file */
   if (write_to_file) 
      output_information (sequence, nmr_of_exponents, pcp);

   return sequence;
}

/* find all occurences of generator in relation with address ptr */

void trace_relation (sequence, index, ptr, generator, pcp)
int *sequence;
int *index;
int ptr;
int generator;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int i, gen, exp, count;
#include "access.h"

   ++(*index);
   if (ptr == generator)
      sequence[*index] = 1;
   else if (ptr < 0) {
      ptr = -ptr + 1;
      count = y[ptr];
      for (i = 1; i <= count; i++) {
	 gen = FIELD2 (y[ptr + i]);
	 if (gen == generator) {
	    exp = FIELD1 (y[ptr + i]);
	    sequence[*index] =exp;
	 }
      }
   }
}

/* append the sequence of length nmr_of_exponents to file with name
   formed by concatenating "gps" and "p^n" */
   
void output_information (sequence, nmr_of_exponents, pcp)
int *sequence;
int nmr_of_exponents;
struct pcp_vars *pcp;
{
#include "define_y.h"
  
   register int count;
   FILE_TYPE output_file;
   char *file_name;
#ifdef LARGE_INT 
   MP_INT code;
#endif

   file_name = allocate_char_vector (MAXWORD + 1, 0, FALSE);

   sprintf (file_name, "gps%d^%d", pcp->p, pcp->lastg);

   /* open the file in update mode */
   output_file = OpenFile (file_name, "a+");

   /* write rank of Frattini quotient, number of pcp generators, prime,
      and exponent-p class to file */

#ifdef LARGE_INT 
   fprintf (output_file, "[%d, %d, %d, ",
	    y[pcp->clend + 1], pcp->lastg, pcp->cc);
   code = Encode (pcp->p, nmr_of_exponents, sequence);
   mpz_out_str (output_file, 10, &code);
   fprintf (output_file, "],\n");
#else
   fprintf (output_file, "%d %d %d %d ",
	    y[pcp->clend + 1], pcp->lastg, pcp->p, pcp->cc);
   /* now write out the sequence of exponents */ 
   for (count = 1; count <= nmr_of_exponents - 1; count++)
      fprintf (output_file, "%d,", sequence[count]);
   fprintf (output_file, "%d\n", sequence[nmr_of_exponents]);
#endif

   CloseFile (output_file);

   free (file_name);
}
