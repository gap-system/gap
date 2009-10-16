/****************************************************************************
**
*A  Extend_Auts.c               ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: Extend_Auts.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"
#define SIZE 100
#define DEFAULT_SIZE 100000
#define DEBUG1

/* for each automorphism, compute its action on each of the generators;

   this code is a modified version of the code to be found in the file  
   extend_automorphisms -- the modifications are introduced in order 
   to store the automorphims much more efficiently than the 3-dimensional 
   array used in that code; the efficiency is achieved by storing the 
   description using two 1-dimensional arrays, head and list; 

   these vectors are organised as follows --
   ptr = head[(alpha - 1) * lastg + i] is a pointer to action of 
         automorphism alpha on generator i;
   length = list[ptr + 1] = length of generator-exponent string 
         storing action;
   list[ptr + 2] ... list[ptr + 1 + length] contains the string */

void Extend_Auts (head, list, start, pcp)
int **head;
int **list;
int start;
struct pcp_vars *pcp;
{
#include "define_y.h" 
   register int lastg = pcp->lastg;
   register int offset; 
   register int alpha;
   int index = 0;
   int max_length;
   FILE_TYPE fp;
   int nmr_saved;
   int list_length;

   int saved_length;            /* total length of description saved to file */
   int restored_length = 0;     /* amount of description restored from file */
   int new;                     /* new storage requirement */

   int i, total, gen;

   /* this used to be 5 * lastg + 4 -- April 1994 */
   if (is_space_exhausted (7 * lastg + 4, pcp))
      return;

   fp = TemporaryFile ();

   save_auts (fp, *head, *list, pcp);

   fread (&nmr_saved, sizeof (int), 1, fp);
   fread (&saved_length, sizeof (int), 1, fp);

   max_length = MIN(SIZE, lastg) * lastg; 
   list_length = max_length + DEFAULT_SIZE;

   if (pcp->cc != 1) {
      if ((*head)[0] < lastg) 
	 *head = reallocate_vector (*head, 1 + (*head)[0] * pcp->m, 
				    1 + lastg * pcp->m, 0, FALSE);
      if ((*list)[0] < list_length) 
	 *list = reallocate_vector (*list, (*list)[0] + 1, 
				    list_length + 1, 0, FALSE);
      else list_length = (*list)[0]; 
   }

   for (alpha = 1; alpha <= pcp->m; ++alpha) {
      offset = (alpha - 1) * lastg;
      restored_length += restore_auts (fp, offset, nmr_saved, 
				       start - 1, &index, *head, *list);
      Extend_Aut (start, max_length, &list_length, *head, list, 
		  offset, &index, pcp);
#ifdef DEBUG
      if (alpha != pcp->m) {
	 printf ("*** After automorphism %d, allocation is %d\n", 
		 alpha, list_length);
	 printf ("*** Value of index is now %d\n", index);
      }
#endif

      if ((new = saved_length - restored_length + index) > list_length) {
	 *list = reallocate_vector (*list, list_length + 1, new + 1, 0, FALSE);
	 list_length = new; 
#ifdef DEBUG
	 printf ("*** Allocation is increased to %d\n", list_length);
#endif
      }
   }

   (*head)[0] = lastg;
   (*list)[0] = list_length;

   CloseFile (fp);

#ifdef DEBUG1
   printf ("*** Final allocated space for automorphisms is %d\n", list_length);
   printf ("*** Final amount used is %d\n", index);
#if defined (LIE) 
   /* appoximate space used to store images of generators of highest weight */
   total = 0; gen = y[pcp->clend + pcp->cc - 1];
   for (alpha = 1; alpha <= pcp->m; ++alpha)
       total += ((*head)[alpha * lastg] - (*head)[(alpha - 1) * lastg + gen]);
   printf ("*** Space for automorphism action on last class is %d\n", total);
#endif
#endif
}

/* list the action of each automorphism on each of the 
   pcp generators, first .. last, by their image */

void List_Auts (head, list, first, last, pcp)
int *head;
int *list;
int first;
int last;
struct pcp_vars *pcp;
{
   register int alpha, i, j, ptr, length;
   int offset = 0;
#include "access.h"

   for (alpha = 1; alpha <= pcp->m; ++alpha) {
      for (i = first; i <= MIN(last, pcp->lastg); ++i) {
	 ptr = head[offset + i];
	 length = list[ptr + 1];
	 printf ("%d --> ", i);
	 for (j = ptr + 2; j <= ptr + length + 1; ++j) {
	    printf ("%d^%d ", FIELD2 (list[j]), FIELD1 (list[j]));
	 }
	 printf ("\n");
      }
      offset += pcp->lastg;
   }
}

/* write out action of each automorphism on each of the pcp generators, 
   first .. last, as an exponent matrix in Magma format */

void Magma_Auts (head, list, start, first, last, pcp)
int *head;
int *list;
int start;
int first;
int last;
struct pcp_vars *pcp;
{
   register int alpha, i, j, k, ptr, length;
   int lastg = pcp->lastg;
   int offset = 0;
   int *vec;
   FILE *Magma_Auts;
#include "access.h"

   Magma_Auts = OpenFile ("Magma_Auts", "a+");
   for (alpha = 1; alpha <= pcp->m; ++alpha) {
      fprintf (Magma_Auts, "A%d := \\[", alpha);
      for (i = first; i <= MIN(last, lastg); ++i) {
	 ptr = head[offset + i];
	 length = list[ptr + 1];
	 vec = allocate_vector (lastg, 1, TRUE);
	 for (j = ptr + 2; j <= ptr + length + 1; ++j) {
	    vec[FIELD2 (list[j])] = FIELD1 (list[j]);
	 }
	 for (k = start; k <= lastg; ++k) {
	    if ((i == MIN(last, lastg)) && (k == lastg)) 
	       fprintf (Magma_Auts, "%d", vec[k]); 
	    else 
	       fprintf (Magma_Auts, "%d,", vec[k]);
	    if (k % 40 == 0) fprintf (Magma_Auts, "\n");
	 }
	 free_vector (vec, 1);
      }
      fprintf (Magma_Auts, "];\n");
      offset += lastg;
   }
   CloseFile (Magma_Auts);
}

/* set up description of action of automorphisms on defining generators */

void Setup_Action (head, list, auts, nmr_of_exponents, pcp)
int **head;
int **list;
int ***auts;
int nmr_of_exponents;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i, generator;
   int position, max_length, exp, alpha, offset;
   int lastg = pcp->lastg;
   int fq_rank = y[pcp->clend + 1];
   int list_length;
   int index = 0;

#include "access.h"

   *head = allocate_vector (fq_rank * pcp->m + 1, 0, FALSE);
   max_length = MIN(SIZE, lastg) * lastg; 
   list_length = max_length + DEFAULT_SIZE; 
   *list = allocate_vector (list_length + 1, 0, FALSE);

   for (alpha = 1; alpha <= pcp->m; ++alpha) {
      offset = (alpha - 1) * fq_rank;
      for (generator = 1; generator <= fq_rank; ++generator) { 
	 position = (*head)[offset + generator] = index;
	 (*list)[++position] = 0;
	 ++index;
	 for (i = 1; i <= nmr_of_exponents; ++i) {
	    if ((exp = auts[alpha][generator][i]) != 0) {
	       ++(*list)[position]; 
	       (*list)[++index] = PACK2 (exp, i);
	    }
	 }
      }
   }

   (*head)[0] = fq_rank;
   (*list)[0] = list_length;
}

/* extend the automorphism whose action on the defining generators 
   of the group is described in the two 1-dimensional arrays, head
   and list, to act on the generators of the group; the first 
   generator whose image is computed is start */

void Extend_Aut (start, max_length, list_length, head, list, offset, index, pcp)
int start;
int max_length;
int *list_length;
int *head;
int **list;
int offset;
int *index;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i, generator;
   register int lastg = pcp->lastg;
   register int structure = pcp->structure;
   int cp1 = pcp->submlg - lastg - 2;
   int cp2 = cp1 - lastg;
   int result = cp2 - lastg;
   register int value;
   int u, v;
   int exp;
   int position, new;

#include "access.h"

   /* update submlg because of possible call to power */
   pcp->submlg -= (3 * lastg + 2);

   /* for each specified generator, compute its image under 
      the action of the automorphism */

   for (generator = start; generator <= lastg; ++generator) {

#ifdef DEBUG
      if (generator % 100 == 0)
	 printf ("Processed generator %d\n", generator);
#endif

      /* check if there is sufficient space allocated */
      if (generator % SIZE == 1 && (new = *index + max_length) > *list_length) {
	 *list = reallocate_vector (*list, *list_length + 1, new + 1, 0, FALSE);
	 *list_length = new; 
      }

      /* examine the definition of generator */
      value = y[structure + generator];
   
      if (value <= 0) {
	 evaluate_image (head, *list, offset, -value, result, pcp);
      }
      else { 

	 u = PART2 (value);
	 v = PART3 (value);

	 if (v == 0)  
	    Extend_Pow (cp1, cp2, u, offset, head, *list, pcp);
	 else  
	    Extend_Comm (cp1, cp2, u, v, offset, head, *list, pcp);

#if defined (GROUP) 
	 /* solve the appropriate equation, storing the image 
	    of generator under the action of alpha at result;
	    in the Lie Program, Extend_Comm has already 
	    set up the answer at location result */

	 solve_equation (cp1, cp2, result, pcp);

#endif 
      }

      /* now copy the result to list */

      position = head[offset + generator] = *index;
      (*list)[++position] = 0;
      ++*index;


      for (i = 1; i <= lastg; ++i) {
	 if ((exp = y[result + i]) != 0) {
	    ++(*list)[position]; 
	    (*list)[++*index] = PACK2 (exp, i);
	 }
      }
   }

   /* reset value of submlg */
   pcp->submlg += (3 * lastg + 2);

}

void evaluate_image (head, list, offset, ptr, cp, pcp)
int *head;
int *list;
int offset;
int ptr;
int cp;
struct pcp_vars *pcp;
{ 
#include "define_y.h"

   int lastg = pcp->lastg;
   int i, j, start, u;
   int pointer;
   int exp;
   int image_length, relation_length;
   int next_gen, next_exp;
   int p = pcp->p;
#include "access.h"
   
   for (i = 1; i <= lastg; ++i)  
      y[cp + i] = 0;

   if (ptr == 0) return;
 
   /* length of redundant relation */
   relation_length = y[ptr + 1];

   /* first generator in redundant relation */
   u = FIELD2 (y[ptr + 1 + 1]);

   /* its exponent */
   exp = FIELD1 (y[ptr + 1 + 1]);

   /* set up exp power of the image of u under alpha as exponent vector at cp */
   traverse_list (exp, head[offset + u], list, cp, pcp);

   /* now reduce the entries mod p */
   for (i = 1; i <= lastg; ++i)
      y[cp + i] %= p;
   
   /* now set up image of second generator as word with 
      base address pointer */
   
   pointer = pcp->lused + 1;
   for (i = 2; i <= relation_length; ++i) {
      next_gen = FIELD2 (y[ptr + 1 + i]);
      next_exp = FIELD1 (y[ptr + 1 + i]);
      start = head[offset + next_gen];
      image_length = list[++start];
      y[pointer + 1] = image_length;
      for (j = 1; j <= image_length; ++j)
	 y[pointer + 1 + j] = list[start + j];
      for ( ; next_exp > 0; --next_exp) 
	 collect (-pointer, cp, pcp);
   }
}

/* given generator t of the p-multiplicator, whose definition is 
   u^p; hence, we have the equation
   
                      u^p = W * t

   where W is a word (possibly trivial) in the generators of the group;
   find the image of t under alpha by setting up (W)alpha at cp1, 
   ((u)alpha)^p at cp2, and then call solve_equation */

void Extend_Pow (cp1, cp2, u, offset, head, list, pcp)
int cp1, cp2;
int u; 
int offset;
int *head;
int *list;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int value;
   register int lastg = pcp->lastg;

   for (i = 1; i <= lastg; ++i)  
      y[cp1 + i] = y[cp2 + i] = 0;

   /* set up the image of u under alpha at cp2 */
   traverse_list (1, head[offset + u], list, cp2, pcp);

   /* raise the image of u under alpha to its pth power */
   power (pcp->p, cp2, pcp);

   /* set up image of W under alpha at cp1 */
   if ((value = y[pcp->ppower + u]) < 0)  
      Collect_Image_Of_Str (-value, cp1, offset, head, list, pcp);
}

#if defined (GROUP) 

/* given generator t of the p-multiplicator, whose definition is 
   [u, v]; hence, we have the equation  
    
   [u, v] = W * t, or equivalently, u * v = v * u * W * t 

   where W is a word (possibly trivial) in the generators of the group;
   find the image of t under alpha by setting up 
   (v)alpha * (u)alpha * (W)alpha at cp1, (u)alpha * (v)alpha at cp2 
   and then call solve_equation */

void Extend_Comm (cp1, cp2, u, v, offset, head, list, pcp)
int cp1, cp2;
int u;
int v;
int offset;
int *head;
int *list;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int pointer, value;
   register int lastg = pcp->lastg;

   for (i = 1; i <= lastg; ++i)  
      y[cp1 + i] = y[cp2 + i] = 0;

   /* set up the image of u under alpha at cp2 */
   traverse_list (1, head[offset + u], list, cp2, pcp);

   /* collect image of v under alpha at cp2 */
   Collect_Image_Of_Gen (cp2, head[offset + v], list, pcp);

   /* set up image of v under alpha at cp1 */
   traverse_list (1, head[offset + v], list, cp1, pcp);

   /* collect image of u under alpha at cp1 */
   Collect_Image_Of_Gen (cp1, head[offset + u], list, pcp);

   /* collect image of W under alpha at cp1 */
   pointer = y[pcp->ppcomm + u];
   if ((value = y[pointer + v]) < 0)
      Collect_Image_Of_Str (-value, cp1, offset, head, list, pcp);
}

#endif 

/* there may be a case where each of the exponent and p is large 
   to use the power routine to compute the exp power of the 
   image of generator under automorphism -- it does not seem to 
   be worthwhile where p = 5 -- needs further investigation */

void Pq_Collect_Image_Of_Gen (exp, cp, head, list, pcp)
int cp;
int head;
int *list;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lused = pcp->lused;
   int str = lused + pcp->lastg;
   register int i;

   for (i = 1; i <= pcp->lastg; ++i)  
      y[lused + i] = 0;

   traverse_list (1, head, list, lused, pcp);
   power (exp, lused, pcp);
   vector_to_string (lused, str, pcp);

   collect (-str, cp, pcp);
}

/* collect image of a generator under the 
   action of an automorphism and store the result at cp */

void Collect_Image_Of_Gen (cp, head, list, pcp)
int cp;
int head;
int *list;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int lused = pcp->lused;
   register int length = list[++head];
   register int i;

   y[lused + 1] = length;

   for (i = 1; i <= length; ++i)  
      y[lused + 1 + i] = list[head + i];

   collect (-lused, cp, pcp);
}

/* collect image of supplied string under the action of 
   supplied automorphism and store the result at cp */

void Collect_Image_Of_Str (string, cp, offset, head, list, pcp)
int string;
int cp;
int offset;
int *head;
int *list;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
   register int generator, exp;
   register int value;
   register int length = y[string + 1] - 1; /* last element of string
					       is in p-multiplicator */
#include "access.h"

   /* process the string generator by generator, collecting exp 
      copies of the image of generator under action of automorphism 
      -- should power routine be used? */

   for (i = 1; i <= length; ++i) {
      value = y[string + 1 + i];
      generator = FIELD2 (value);
      exp = FIELD1 (value);
      while (exp > 0) {
	 Collect_Image_Of_Gen (cp, head[offset + generator], list, pcp);
	 --exp;
      }
   } 
}
