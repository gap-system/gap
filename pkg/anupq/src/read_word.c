/****************************************************************************
**
*A  read_word.c                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: read_word.c,v 1.4 2001/11/15 16:00:31 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#include "pq_functions.h"
#include "pretty_filterfns.h"
#include "word_types.h"

#ifdef Magma
#include "dyn_arr.h"
#endif

/* display the appropriate input message */

void display_message (type)
int type;
{
   switch (type) {
   case LHS:
      printf ("Input left-hand side of relation:\n");
      break;

   case RHS:
      printf ("Input right-hand side of relation:\n");
      break;

   case WORD:
      printf ("Input the word for collection:\n" );
      printf ("(use generators x1,x2,... and terminate with a semicolon)\n");
      break;

   case VALUE_A:
      printf ("Input the value of a:\n");
      printf ("(use generators x1,x2,... and terminate with a semicolon)\n");
      break;

   case VALUE_B:
      printf ("Input the value of b:\n");
      break;

   case FIRST_ENTRY:
      printf ("Input the first component of commutator:\n");
      break;

   case NEXT_ENTRY:
      printf ("Input the next component of commutator:\n");
      break;
   case ACTION:
      break;
   }
}

/* set up array of generators x1, x2, .., xlastg and their
   inverses to represent the pcp generators of the group; 
   this permits words to be input using the pretty format */

void setup_symbols (pcp)
struct pcp_vars *pcp;
{
   int i, j, k, m;
   int log, digit;

   /* space for this array may have been previously allocated */
   /* memory leak September 1996 */

   if (user_gen_name != NULL) {
      num_gens = user_gen_name[0].first;
     
      for (i = 1; i <= num_gens; ++i) {
         free_vector (user_gen_name[i].g, 0);
      }
      free_vector (user_gen_name, 0);
      user_gen_name = NULL;
      free_vector (inv_of, 0);
      free_vector (pairnumber, 0);
   }

   paired_gens = pcp->lastg;
   num_gens = 2 * paired_gens;
   user_gen_name = valloc (word, num_gens + 1);
   inv_of = valloc (gen_type, num_gens + 1);
   pairnumber = valloc (int, num_gens + 1);

   /* memory leak September 1996 */
   user_gen_name[0].first = num_gens;

   for (i = 1; i <= paired_gens; i++){
      j = i;
      word_init (user_gen_name + 2 * i - 1);
      word_init (user_gen_name + 2 * i);
      word_put_last (user_gen_name + 2 * i - 1, 'x');
      word_put_last (user_gen_name + 2 * i, 'x');
      /* extract the digits of the number, i, from left to right */
      log = log10 ((double) j);
      for (k = log; k >= 0; --k) {
	 m = int_power (10, k);
	 digit = j / m;
	 word_put_last (user_gen_name + 2 * i - 1, digit + '0');
	 word_put_last (user_gen_name + 2 * i, digit + '0');
	 j %= m;
      } 
      word_put_last (user_gen_name + 2 * i, '^');
      word_put_last (user_gen_name + 2 * i, '-');
      word_put_last (user_gen_name + 2 * i, '1');
      inv_of[2 * i - 1] = 2 * i;
      inv_of[2 * i] = 2 * i - 1;
      pairnumber[2 * i] = pairnumber[2 * i - 1] = i;
   }
}

/* read in a word using the basic format; 
   type determines the message printed out;
   store the word with address ptr which has value lused + 1 + disp;
   y[ptr] is the length of the word (includes exponent);

   if the word is one side of a relation, and it is a commutator,
   then y[ptr] is the negative of the length, as this allows
   collect_relations to recognise that this word is a commutator;

   y[ptr + 1] is the exponent;

   y[ptr + 2] .. y[ptr + length] are generators (either defining or pcp) 
   or their inverses */

void read_word (file, disp, type, pcp)
FILE_TYPE file;
int disp; 
int type;
struct pcp_vars *pcp; 
{
   Logical finish = FALSE;
   Logical commutator = FALSE;
   char s[MAXWORD];
   int t[MAXWORD];
   int integer, temp;
   int length = 0;
   int nmr_items;

   display_message (type);

   while (!finish && (nmr_items = fscanf (file, "%s", s)) != EOF) {

      verify_read (nmr_items, 1);

      while (s[0] == COMMENT) {
	 read_line ();
	 nmr_items = fscanf (file, "%s", s);
	 verify_read (nmr_items, 1);
      }
 
      /* check for end of relation marker */
      if (check_for_symbol (s))
	 finish = TRUE;

      /* check for commutator symbol */
      if (!commutator)
	 commutator = check_for_commutator (s);

      /* convert string to integer */
      integer = 0;
      temp = string_to_integer (s, &integer);
      
      if (integer == 0 && !(commutator || finish || *s == ',')) {
	 printf ("Error in input data -- %s\n", s); 
	 if (!isatty (0))
	    exit (FAILURE);
      }

      if (integer != 0) {
	 if ((length == 0 && temp == 0) || temp != 0) {
	    t[length] = temp;
	    ++length;
	 }
      }
   }

   setup_relation (disp, length, type, commutator, t, pcp);
}

/* read word using pretty format */

void pretty_read_word (file, disp, type, pcp)
FILE *file;
int disp; 
int type;
struct pcp_vars *pcp; 
{
#include "define_y.h"

   int ptr = pcp->lused + 1 + disp;
   word w1, w2, w3;
   gen_type g;
   int i, exp;
   int length;

   if (file == stdin)
      display_message (type);

   word_init (&w1); word_init (&w2); word_init (&w3);
   read_next_word (&w1, file);
   find_char (';', file);
   word2prog_word (&w1, &w2);
   word_factor (&w2, &w3, &exp);
   
   y[ptr] = length = 0;
   y[ptr + 1] = exp;
   while (word_delget_first (&w3, &g))
      if (g != 0)
	 y[ptr + 1 + (++length)] = (g <= inv(g)) ? pairnumber[g]: -pairnumber[g]; 
   word_clear (&w1); word_clear (&w2); word_clear (&w3);

   if (length != 0)  
      y[ptr] = ++length;
      
   if (file != stdin) 
      return;

   printf ("The input word is ");
   for (i = 1; i <= length; ++i)
      printf ("%d ", y[ptr + i]);
   printf ("\n");
}

/* process the input word and set it up as an entry in y */

#ifdef Magma
void setup_relation (disp, length, type, commutator, th, pcp)
#else
void setup_relation (disp, length, type, commutator, t, pcp)
#endif
int disp;
int length;
int type;
Logical commutator;
#ifdef Magma
t_handle th;
#else
int *t;
#endif
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i;
#ifdef Magma
   int *u, *t;
   t_handle uh;
#else
   int u[MAXWORD];
#endif
   register int total;
   register int ptr;
   Logical commutator_relation; 

   /* currently, only a commutator which is one side of a 
      relation is not expanded -- this may be changed later */
   commutator_relation = (commutator && (type == LHS || type == RHS));

#ifdef Magma
   t = dyn_arr_elt0_ptr (th);
#endif
   /* is the word trivial? */
   if (t[0] == 0 || length == 1) {
      length = 1;
      ptr = pcp->lused + 1 + disp;
      y[ptr + 1] = 0;
   }
   else {
      /* set up relation */
#ifdef Magma
      if (commutator && !commutator_relation)
	 i = integer_power (2, length) + integer_power (2, length - 1);
      else
	 i = length + 2;
      uh = dyn_arr_alloc (i);
      dyn_arr_set_zero (uh, i);
      t = dyn_arr_elt0_ptr (th);
      u = dyn_arr_elt0_ptr (uh);
#else
      for (i = 1; i < MAXWORD; ++i)
	 u[i] = 0;
#endif
      u[0] = t[1];

      if (length >= MAXWORD) {
	 text (18, 0, 0, 0, 0);
	 exit (FAILURE);
      }

      if (commutator_relation || !commutator)
	 for (i = 1; i < length - 1; ++i)
	    u[i] = t[i + 1];
      else {      
	 for (i = 2; i < length; ++i)  
	    expand_commutator (u, t[i]);
      }

      /* check how much space is required to store the word in y */ 
      total = 2;
      while (u[total] != 0)
	 ++total;

      /* the length of the relation is total */
      if (total >= MAXWORD) {
	 text (18, 0, 0, 0, 0);
	 exit (FAILURE);
      }

      /* is there enough room in array y to store the word? */
      if (is_space_exhausted (total, pcp))
	 return;

      ptr = pcp->lused + 1 + disp;

      /* copy expanded word and set up as relation stored in y */
      y[ptr + 1] = t[0];
      length = 0;
      while (u[length] != 0) {
	 y[ptr + 2 + length] = u[length];
	 ++length;
      }
      ++length;
#ifdef Magma
      dyn_arr_delete (&uh);
#endif
   }

   /* set up the length */
   if (commutator_relation) 
      y[ptr] = -length;
   else
      y[ptr] = length;

   PRINT ("The input word is ");
   PRINT ("%d ", y[ptr + 1]);
   if (commutator_relation) 
      PRINT ("[ ");
   for (i = 2; i <= length; ++i)
      PRINT ("%d ", y[ptr + i]);
   if (commutator_relation) 
      PRINT ("]");
   PRINT ("\n");
}

/* check whether relation is a commutator */

int check_for_commutator (s)
char *s;
{
   int not_found;
   register int length = strlen (s);

   while (length > 0 && (not_found = 
			 (s[length - 1] != LHS_COMMUTATOR && s[length - 1] != RHS_COMMUTATOR)))  
      --length;

   return !not_found;
}

/* check for occurrence of END_OF_WORD in word */

int check_for_symbol (s)
char *s;
{
   int not_found;
   register int length = strlen (s);

   while (length > 0 && (not_found = (s[length - 1] != END_OF_WORD)))
      --length;

   return !not_found;
}

/* convert string s to integer */

int string_to_integer (s, integer)
char *s;
int *integer;
{
   int i, n, sign;

   for (i = 0; isspace (s[i]); i++) /* skip white space */
      ;
   sign = (s[i] == '-') ? -1 : 1;
   if (s[i] == '+' || s[i] == '-') /* skip sign */
      i++;
   for (n = 0; s[i] != '\0'; i++) {
      if (isdigit (s[i])) {
	 *integer = 1;
	 n = 10 * n + (s[i] - '0'); 
      }
   }

   return sign * n;
}
