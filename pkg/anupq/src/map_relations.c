/****************************************************************************
**
*A  map_relations.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: map_relations.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (STANDARD_PCP) 
#include "pq_defs.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "menus.h"
#include "constants.h"
#include "pq_functions.h"

#define POWER -100
#undef COMMUTATOR 
#define COMMUTATOR -200

/* modify the stored relations under the action of the standard 
   automorphism and print out the result -- this code is complex 
   as a result of two problems:

   a. the "strange" form in which definitions of group generators
      are returned -- see note on "commutator" below;

   b. the need to meet the limitations imposed by the input routines of pq */

/* find the structure of pcp generator gen and store it in definition */ 

int find_structure (gen, definition, pcp)
int gen;
int *definition;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int structure = pcp->structure;
   register int lastg = pcp->lastg;
   register int u, v;
   register int i;
   int weight;
   int pointer;

#include "access.h"

   pointer = y[structure + gen];
   weight = WT(pointer);

   for (i = 1; i <= lastg; ++i)
      y[pcp->lused + i] = 0;

   u = PART2 (pointer);
   v = PART3 (pointer);
   find_definition (gen, pcp->lused, weight, pcp);

   if (v == 0) {
      definition[0] = POWER;
#if defined (DEBUG)
      printf ("%d is defined on %d^%d = ", gen, u, pcp->p);
#endif 
   }
   else {
#if defined (DEBUG)
      printf ("%d is defined on [%d, %d] = ", gen, u, v);
#endif 
      definition[0] = COMMUTATOR;
   }

   for (i = 1; i <= weight; ++i)
      definition[i] = y[pcp->lused + i];

#if defined (DEBUG)
   for (i = 1; i <= weight; ++i)
      if (definition[i] != 0)
	 printf ("%d ", definition[i]);
   printf ("\n");
#endif 

}

/* print the defining relations of the group after applying
   the standard automorphism described in map */

void map_relations (map, pga, pcp)
int **map;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int ndgen = pcp->ndgen;
   register int ndrel = pcp->ndrel;
   register int lastg = pcp->lastg;
   register int relp = pcp->relp;
   register int dgen = pcp->dgen;
   register int generator; 
   int *definition;
   register int i, j, k, l;
   register int pointer, length;
   int exp, absgen;
   FILE_TYPE present;
   Logical *defn;
   int *preimage;
   int *image;
   Logical identity_map;

   /* write out the basic information */
   present = OpenFile ("ISOM_present", "w+");
   fprintf (present, "1\n");
   fprintf (present, "prime %d\n", pcp->p);
   fprintf (present, "class %d\n", pcp->cc);
   fprintf (present, "output %d\n", MIN_PRINT);
   if (pcp->extra_relations != 0) 
      fprintf (present, "exponent %d\n", pcp->extra_relations);
   if (pcp->metabelian == TRUE) 
      fprintf (present, "metabelian\n");

   fprintf (present, "generators  {");

   /* if the map is the identity, then we need only 
      the existing generators and relations */

   if ((identity_map = is_identity_map (map, pga->ndgen, lastg))) {
#if defined (DEBUG)
      printf ("map is the identity map\n");
#endif 
      for (i = 1; i <= ndgen; ++i) 
	 fprintf (present, "x%d, ", i);
   }
   else {
      defn = allocate_vector (lastg, 1, TRUE);
      preimage = allocate_vector (lastg, 1, TRUE);
      image = allocate_vector (ndgen, 1, TRUE);

      /* identify which defining generators map to which pcp generators 
	 of the Frattini quotient; two arrays are stored as follows  --
         
	 preimage[i] = defining generator j
	 image[k] = pcp generator l */

      for (i = 1; i <= pga->ndgen; ++i) {
	 for (j = 1; j <= ndgen && y[dgen + j] != i; ++j)
	    ;
	 if (j > ndgen) {
	    printf ("Error in map_relations\n");
	    exit (FAILURE);
	 }
	 preimage[i] = j;
	 image[j] = i;
      }

      /* do we need to introduce new generators? */

      for (i = 1; i <= pga->ndgen; ++i) {
	 fprintf (present, "y%d, ", i);
	 preimage[i] = 0;
	 /*
	   if (is_ident (map[i], i, lastg)) {
	   fprintf (present, "x%d, ", preimage[i]);
	   image[ preimage[i] ] = -i;
	   }
	   else {
	   fprintf (present, "y%d, ", i);
	   preimage[i] = 0;
	   }
	   */
      }

#if defined (DEBUG)
      printf ("The correspondences are \n");
      print_array (preimage, 1, pcp->lastg + 1);
      print_array (image, 1, ndgen + 1);
#endif

      /* which pcp generators turn up in the image of the 
	 pcp generators of the Frattini quotient? */
      for (i = 1; i <= pga->ndgen; ++i) 
	 length_of_image (i, defn, map, pcp);

      /* what are the new defining generators needed for new presentation? */

      for (i = y[pcp->clend + 1] + 1; i <= lastg; ++i)
	 if (defn[i] == TRUE) 
	    fprintf (present, "y%d, ", i);

      /* print the remaining defining generators for the new presentation */
      for (i = 1; i <= ndgen; ++i) {
	 if (image[i] >= 0) 
	    fprintf (present, "x%d, ", i);
      }
   }

   fprintf (present, "}\n");

#if defined (DEBUG)
   printf ("First the generators\n");
   printf ("\nNow the relations\n");
#endif 

   /* print the existing relations */

   if (ndrel == 0)
      fprintf (present, " ;\n");
   else 
      fprintf (present, "relations {\n");

   for (k = 1; k <= ndrel; ++k) {
      for (l = 1; l <= 2; ++l) {
	 i = (k - 1) * 2 + l;
	 pointer = y[relp + i];
	 length = y[pointer];
	 if (length > 1) {
	    if (l == 2) fprintf (present, " = ");
	    exp = y[pointer + 1];
	    if (exp != 1)
	       fprintf (present, "(");
	    for (i = 2; i <= length; ++i) {
	       generator = y[pointer + i];
	       absgen = abs (generator);
	       fprintf (present, "x%d", absgen);
	       if (absgen != generator)
		  fprintf (present, "^-1");
	       if (i != length)
		  fprintf (present, " * ");
	    }
	    if (exp != 1)
	       fprintf (present, ")^%d", exp);
	 }
	 else if ((length = abs (length)) > 1) {
	    if (l == 2) fprintf (present, " = ");
	    fprintf (present, "[");
	    for (i = 2; i <= length; ++i) {
	       generator = y[pointer + i];
	       generator = y[pointer + i];
	       absgen = abs (generator);
	       fprintf (present, "x%d", absgen);
	       if (absgen != generator)
		  fprintf (present, "^-1");
	       if (i != length)
		  fprintf (present, ", ");
	    }
	    fprintf (present, "]");
	    if ((exp = y[pointer + 1]) != 1)
	       fprintf (present, "^%d", exp);
	 }
	 if (l == 2) {
	    fprintf (present, ",\n");
	 }
      }
   }

   /* now print the mappings of the defining generators */

   if (identity_map == FALSE) {
      for (i = 1; i <= pga->ndgen; ++i) {
	 /*
	   if (!is_ident (map[i], i, lastg)) {
	   */
	 /*    j = preimage[i]; */
	 for (j = 1; j <= ndgen && y[dgen + j] != i; ++j)
	    ;

	 fprintf (present, "x%d = ", j);
	 print_image_under_aut (present, preimage, i, defn, map, pcp);
	 fprintf (present, ",\n");
	 /*
	   }
	   */
      }

#if defined (DEBUG)
      printf ("the required pcp definitions are ");
      print_array (defn, 1, 1 + lastg);
#endif 

      definition = allocate_vector (pcp->cc + 1, 0, FALSE);
      for (i = y[pcp->clend + 1] + 1; i <= lastg; ++i)
	 if (defn[i] == TRUE) {
	    /* look up and print the structure of the pcp generator i */ 
	    find_structure (i, definition, pcp);
	    print_definition (present, preimage, i, definition, pcp); 
	 }

      free_vector (definition, 0);
      free_vector (preimage, 1);
      free_vector (image, 1);
      free_vector (defn, 1);
   }

   if (ndrel != 0)
      fprintf (present, "};\n");

   CloseFile (present);
}

/* is pcp generator i mapped to the identity? its image is supplied as map */

Logical is_ident (map, i, lastg)
int *map;
int i;
int lastg;
{
   register int j;
   Logical identity = TRUE;

   j = 1;
   while (j <= lastg && identity) {
      identity = (i == j) ? map[j] == 1 : map[j] == 0;
      ++j;
   }
   return identity;
}

/* is the map the identity on the pcp generators of the Frattini quotient */

Logical is_identity_map (map, ndgen, lastg)
int **map;
int ndgen;
int lastg;
{
   Logical identity = TRUE;
   register int i;

   i = 1;
   while (i <= ndgen && (identity = is_ident (map[i], i, lastg))) 
      ++i;

   return identity;
}

/* find length of image of gen under map */

int length_of_image (gen, defn, map, pcp)
int gen;
Logical *defn;
int **map;
struct pcp_vars *pcp;
{
   register int lastg = pcp->lastg;
   register int i;
   int non_zero = 0;

   for (i = 1; i <= lastg; ++i) {
      if (map[gen][i] != 0) { 
	 defn[i] = TRUE;
	 ++non_zero;
      }
   }

   return non_zero;
}

/* print image of gen under map */

int print_image_under_aut (present, preimage, gen, defn, map, pcp)
FILE *present;
int *preimage;
int gen;
Logical *defn;
int **map;
struct pcp_vars *pcp;
{
   register int lastg = pcp->lastg;
   register int i;
   int non_zero;
   int nmr_printed = 0;
   int preim, value;
   char *s;

   non_zero = length_of_image (gen, defn, map, pcp);

   for (i = 1; i <= lastg; ++i) {
      if (map[gen][i] == 0) continue;
      ++nmr_printed;

      preim = preimage[i];
      s = (preim != 0) ? "x" : "y";
      value = (preim != 0) ? preim : i;
      
      fprintf (present, "%s%d", s, value);
      if (map[gen][i] != 1)
	 fprintf (present, "^%d", map[gen][i]);
      
      if (nmr_printed != non_zero)
	 fprintf (present, " * ");
   }
}

/* print definition of pcp generator, gen */

int print_definition (present, preimage, gen, definition, pcp)
FILE *present;
int *preimage;
int gen;
int *definition;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int start = y[pcp->clend + 1] + 1;
   register int exponent;
   register int limit;
   register int i;
   int power, m, root;
   Logical first;
   char *s;
   int r;
#include "access.h"

   fprintf (present, "y%d = ", gen);
   
   if (gen < start) {
      fprintf (present, "y%d", gen);
   }
   else {
      /* replace generator by its definition */
      if (definition[0] == POWER) {
	 power = 0;
	 first = TRUE; 
	 limit = WT (y[pcp->structure + gen]);
	 for (m = 1; m <= limit; ++m) {
	    if (definition[m] != 0) {
	       ++power;
	       if (first) {
		  root = definition[m]; 
		  first = FALSE; 
	       }
	    }
	 }
	 exponent = int_power (pcp->p, power - 1);

	 s = preimage[root] != 0 ? "x" : "y";
	 r = preimage[root] != 0 ?  preimage[root] : root;
	 fprintf (present, "%s%d^%d", s, r, exponent);
      }
      if (definition[0] == COMMUTATOR) {

	 /* a "commutator" definition may be of the sort
	    [b, ..., b, a, a, a] where there are k occurrences
	    of the first term, b; in fact, this corresponds to 
	    a definition [b^(p^(k - 1)), a, a, a]; we must first
	    check to see if this is the case */
            
	 power = 1;
	 root = definition[1];
	 limit = WT (y[pcp->structure + gen]);
	 for (i = 2; i < limit && root == definition[i]; ++i)
	    ++power;
	 exponent = int_power (pcp->p, power - 1);
	 fprintf (present, "[");
	 s = preimage[root] != 0 ? "x" : "y";
	 r = preimage[root] != 0 ?  preimage[root] : root;
	 if (exponent != 1)
	    fprintf (present, "%s%d^%d,", s, r, exponent);
	 else 
	    fprintf (present, "%s%d,", s, r);

	 for (m = i; m <= limit; ++m) {
	    root = definition[m];
	    s = preimage[root] != 0 ? "x" : "y";
	    r = preimage[root] != 0 ? preimage[root] : root;
	    fprintf (present, " %s%d", s, r);
	    if (m != limit)
	       fprintf (present, ","); 
	    else 
	       fprintf (present, "]"); 
	 }
      }
      fprintf (present, ",\n");
   }
}
#endif 
