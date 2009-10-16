/****************************************************************************
**
*A  extra_relations.c           ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: extra_relations.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (GROUP) 

#include "pq_defs.h"
#include "pcp_vars.h"
#include "constants.h"
#include "pq_functions.h"
#include "exp_vars.h"

#ifdef Magma
#include "dyn_arr.h"
#endif

/* this procedure collect extra relations which hold in the group;

   it may be used as an exponent check routine for certain 
   Burnside computations; 

   if pcp->extra_relations = 0 there are no extra relations;

   if pcp->extra_relations > 0, the extra relations specify that  
   certain pcp words have exponent pcp->extra_relations -- those 
   normal pcp words with weights from pcp->start_wt to end_class;

   if pcp->end_wt > 0, end_class is set to the minimum of pcp->cc and 
   this value;

   if both pcp->end_wt and pcp->start_wt are 0, this ensures that the 
   group has exponent pcp->extra_relations; 

   if ALL_WORDS is chosen, then the routine generates a complete
   list of the normal words needed in exponent checking whose
   weights lie within the chosen bounds;

   if REDUCED_LIST is chosen, it is assumed that all redundant 
   relations in the queue are later closed under supplied 
   automorphisms which must contain a generating set for the 
   appropriate general linear group;
   
   if INITIAL_SEGMENT is chosen, the routine will read in a word 
   and only generate all those words needed for exponent checking 
   which have this word as a proper initial segment; 

   any redundancies obtained by echelonising the members of this
   list are added to the supplied queue; 

   there are a number of options in this code which are selected
   according to the value of the following variables:

   if exp_flag->process is FALSE, generate the list of words but do 
   not process the elements; if diagnostic output, then print out
   all words which will be collected;

   if exp_flag->complete is TRUE and diagnostic output is chosen,
   then print out all of the words of the appropriate weight 
   generated and not just those which survive the conjugacy and 
   other tests;

   hence, if you want a listing of all of the words generated using the
   back-track search, you should set both flags TRUE;

   if exp_flag->partitions is TRUE, print the weight partitions 
   of the generated words; */ 


#define MCLASS 10000 

int initial_length;       /* length of initial segment */
int least_weight;         /* lower bound on weight of remaining letters */
int max_weight;           /* upper bound on weight of remaining letters */
int initial_weight;       /* weight of initial segment */
int first_entry;          /* lower bound on new letters in word */
int least_entry;          /* lower bound on remaining new letters in word */
int max_entry;            /* upper bound on new letters in word */

/* read in the initial segment to be used in generating the words */

#ifdef Magma
void read_initial_segment (word, initial, initial_coeff, pcp)
t_handle word;
int *initial;
int *initial_coeff;
struct pcp_vars *pcp;
#else
void read_initial_segment (initial, initial_coeff, pcp)
int *initial;
int *initial_coeff;
struct pcp_vars *pcp;
#endif
{
#include "define_y.h"

   register int i;
   int lower_bound;             /* lower bound on next letter in word */
   int lower_bound_weight;      /* lower bound on weight of next letter */

#include "access.h"

#ifdef Magma
   initial_length = word == NULL_HANDLE ? 0 : dyn_arr_curr_length (word) / 2;
   for (i = 0; i < initial_length; i++)
   {
      initial[i + 1] = dyn_arr_element (word, 2 * i);
      initial_coeff[i + 1] = dyn_arr_element (word, 2 * i + 1);
   }
   if (word == NULL_HANDLE)
      lower_bound = 0;
   else
      lower_bound = initial[initial_length];
#else
   /* read in details of the initial segment of the words to be processed */ 
   read_value (TRUE, "Input length of initial segment of words: ",
	       &initial_length, 0);
   
   lower_bound = 0;
   if (initial_length != 0) {
      printf ("Input initial segment of words as a generator exponent list: ");
      for (i = 1; i < initial_length; ++i) {
	 read_value (FALSE, "", &initial[i], lower_bound + 1);
	 read_value (FALSE, "", &initial_coeff[i], 1);
	 lower_bound = initial[i];
      }
      read_value (FALSE, "", &initial[i], lower_bound + 1);
      read_value (TRUE, "", &initial_coeff[i], 1);
      lower_bound = initial[i];
   }
#endif

   /* find initial weight */
   initial_weight = 0;
   for (i = 1; i <= initial_length; ++i)
      initial_weight += initial_coeff[i] * WT (y[pcp->structure + initial[i]]);

   /* all other entries in this word must have weight as least 
      as great as the last letter of the initial segment */
   if (lower_bound == 0)
      lower_bound_weight = 1;
   else 
      lower_bound_weight = MAX (1, WT (y[pcp->structure + lower_bound]));

#ifdef Magma
   least_weight = lower_bound_weight;
#else
   read_value (TRUE, "Input lower bound for weight of remaining letters: ",
	       &least_weight, lower_bound_weight);
#endif

   /* first entry in the remainder of word */
   first_entry = y[pcp->clend + MIN (least_weight - 1, pcp->cc)];

   /* the first new letter must be larger than the last letter 
      of the initial segment */ 
   first_entry = MAX (lower_bound, first_entry);
 
   /* if using automorphisms and initial segment has length 0, 
      we skip all but first of those pcp generators of weight 1 */
   least_entry = (pcp->m != 0 && initial_length == 0) ? 
      y[pcp->clend + 1] : first_entry; 

#ifdef Magma
   max_weight = pcp->cc;
#else
   read_value (TRUE, "Input upper bound for weight of remaining letters: ",
	       &max_weight, least_weight);
#endif

   max_entry = pcp->ccbeg;
   if (max_weight < pcp->cc) 
      max_entry = y[pcp->clend + max_weight] + 1;
}

#ifdef Magma
void extra_relations (exp_flag, word, pcp)
struct exp_vars *exp_flag;
t_handle word;
struct pcp_vars *pcp;
#else
void extra_relations (exp_flag, pcp)
struct exp_vars *exp_flag;
struct pcp_vars *pcp;
#endif
{
#include "define_y.h"

   register int nmr_words;      /* number of normal words powered in class */
   register int length;         /* number of generators in normal word */
   register int exp_length;     /* sum of exponents in normal word */
   register int nextg;          /* next generator added to normal word */
   register int w;              /* weight of generator in normal word */
   register int weight;         /* weight of normal word */
   register int wt_gen1;        /* weight of first generator in normal word */
   register int gen_i;          /* ith generator in normal word */
   register Logical exit;       /* exit from loop? */

   int gen[MCLASS + 1];           /* generators of normal word */
   int coeff[MCLASS + 1];         /* exponents of these generators */
   int initial[MCLASS + 1];       /* generators of initial normal word */
   int initial_coeff[MCLASS + 1]; /* exponents of these generators */

   register int extra_relations = pcp->extra_relations;
   register int structure = pcp->structure; 
   register int lastg = pcp->lastg;
   register int prime = pcp->p;
   register int pm1 = pcp->pm1;

   register int end_class;      /* end class for check */
   register int class;
   register int entry;
   register int i, j;
   int  *queue;
   char *s;

   FILE_TYPE RelationList;

#include "access.h"

   if (extra_relations == 0)
      return;

   /* relation file */
   if (exp_flag->word_list) 
      RelationList = OpenFile ("Relation_list", "w");

   /* determine whether the supplied exponent is 
      valid and what classes must be checked */
   i = 0;
   j = extra_relations;
   while (j > 1) {
      if (MOD(j, prime) != 0) {
	 text (14, extra_relations, 0, 0, 0);
	 pcp->valid = FALSE;
	 return;
      }
      ++i;
      j /= prime;
   }

   if (pcp->cc <= i)
      return;
   end_class = pcp->cc;
   if (pcp->end_wt != 0)
      end_class = MIN(end_class, pcp->end_wt);

   if (exp_flag->list == ALL_WORDS || exp_flag->list == REDUCED_LIST) {
      initial_length = 0;
      initial_weight = 0;
      first_entry = 0;
      least_entry = (exp_flag->list == REDUCED_LIST) ? y[pcp->clend + 1] : 0; 
      max_entry = pcp->ccbeg;
   }
   else {
#ifdef Magma
      read_initial_segment (word, initial, initial_coeff, pcp);
#else
      read_initial_segment (initial, initial_coeff, pcp);
#endif
   }
   queue = exp_flag->queue;

   /* process each relevant class in turn --
      using a backtrack process, build up normal words in the pcp 
      generators of the group which have weight equal to class; 
      each word has the general form 
      
      gen[1]^coeff[1] * gen[2]^coeff[2] * ... * gen[length]^coeff[length]  
      
      where gen[1], ..., gen[length] are pcp generators with 
      gen[1] < gen[2] < ... < gen[length], coeff[1] = 1,
      and 0 < coeff[i] < prime for i = 2,...,length; 
      
      we generate only all words with weight equal to class and 
      coeff[1] = 1; normal words with coeff[1] > 1 are powers 
      of normal words with coeff[1] = 1, and so they have the 
      same orders as those with coeff[1] = 1;
      
      if REDUCED_LIST is chosen, we enforce the additional 
      requirement that gen[i] has weight at least 2 for 
      all i >= 2, and gen[1] = 1 or gen[1] has weight at least 2;
      
      if INITIAL_SEGMENT is chosen, we enforce the additional 
      requirement that each word has the supplied proper 
      initial segment; 
      
      we apply some commutator calculus to eliminate some of 
      the words; those not eliminated are raised to the power 
      extra_relations and then the result is echelonised */

   for (class = MAX(1, pcp->start_wt); class <= end_class; ++class) {

      nmr_words = 0;
      length = initial_length;
      weight = initial_weight;
  
      /* set up the initial-segment of the word */
      for (i = 1; i <= initial_length; ++i) {
	 gen[i] = initial[i];
	 coeff[i] = initial_coeff[i];
      }

      nextg = first_entry + 1;
      w = WT (y[structure + nextg]);

      do { 
	 /* backtrack process -- start to construct the next normal word */
	 exit = FALSE;
	 while (weight + w > class || nextg >= max_entry) {

	    /* if length = 0, we have finished this class */
	    exit = (length == initial_length);  
	    if (exit) break;

	    /* strip off last generator from the normal word and
	       decrease the weight of the word accordingly */
	    nextg = gen[length];
	    if (--coeff[length] == 0)
	       --length;
	    weight -= WT(y[structure + nextg]);

	    if (nextg >= 1 && nextg < least_entry)
	       /* nextg should now start with first generator of next weight */
	       nextg = least_entry + 1;
	    else
	       ++nextg;

	    w = WT(y[structure + nextg]);
	 }
	 if (exit) break;

	 /* add in nextg as last pcp generator with exponent 
	    one of normal word; increase weight accordingly */
	 coeff[++length] = 1;
	 if (nextg > 1 && nextg <= least_entry) {
	    /* nextg should now start with first generator of weight 2 */
	    nextg = least_entry + 1;
	    w = WT(y[structure + nextg]);
	 }
	 gen[length] = nextg;
	 weight += w; 
  
	 /* keep extending normal word as long as its weight is < class */
	 while (weight < class) {
	    if (coeff[length] == pm1 || length == 1) {
	       /* add in a new pcp generator with exponent 1 */
	       coeff[++length] = 1;
	       ++nextg;
	       if (nextg > 1 && nextg <= least_entry)
		  /* nextg now starts with first generator of next weight */
		  nextg = least_entry + 1;
	       gen[length] = nextg;
	       w = WT(y[structure + nextg]);
	    }
	    else  
	       /* add in another copy of nextg */
	       ++coeff[length];

	    /* update weight for new word */
	    weight += w;
	 }

	 /* if weight > class, we have extended the normal 
	    word too far, and we need to backtrack */
	 if (weight > class) continue;

	 /* if appropriate, print out weight partitions */

	 if (exp_flag->partitions) {
	    printf ("seq (");
	    for (i = 1; i < length; ++i)
	       for (j = 1; j <= coeff[i]; ++j)
		  printf ("%d, ", WT (y[structure + gen[i]]));

	    for (j = 1; j < coeff[length]; ++j)
	       printf ("%d, ", WT (y[structure + gen[length]]));
	    printf ("%d),\n", WT (y[structure + gen[length]]));
	 }

	 if (exp_flag->complete) {
	    printf ("Seek to collect power %d of the following word: ",
		    extra_relations);
	    for (i = 1; i <= length; ++i)
	       printf ("%d^%d ", gen[i], coeff[i]);
	    printf ("\n");
	 }

	 /* we now have a normal word of weight class; run a number of 
	    checks to establish if it is necessary to exponentiate it; 
	    first, use commutator identities to possibly eliminate it; 
            
	    if the conditions in the if clause below are satisfied, 
	    then the normal closure of nextg has prime exponent;
            
	    if this is the case, we can express the normal word in 
	    the form u * nextg, where u is a normal word of lower weight; 
	    we assume by induction that u^extra_relations = 1,
	    and this, together with the fact that the normal
	    closure of nextg has exponent prime, implies that
	    (u * nextg)^extra_relations is a product of commutators 
	    which have length at least extra_relations and which have 
	    entries gen[1],..., gen[length]; we may also assume that 
	    gen[i] occurs at least coeff[i] times for i = 1, ..., length 
	    in each of these commutators;
            
	    let exp_length = sum of coeff[i] for i = 1, ..., length;
	    if extra_relations > exp_length then these commutators 
	    have extra entries of weight at least wt_gen1; check whether
	    the extra entries make the total weight of the commutators 
	    exceed the current class; if so, the power of this word 
	    is trivial */ 

	 wt_gen1 = WT(y[structure + gen[1]]);

	 if (prime * w >= pcp->cc && y[pcp->ppower + nextg] == 0) {
	    /* find the sum of the coefficients */
	    for (i = 1, exp_length = 0; i <= length; ++i)
	       exp_length += coeff[i];
	    if (weight + (extra_relations - exp_length) * wt_gen1 > pcp->cc) {
	       if (exp_flag->filter) {
		  printf ("Filtered from list using normal closure\n");
	       }
	       continue;
	    }
	 }

	 /* seek to eliminate conjugates and powers of words 
	    which are tested at other times;
            
	    the Felsch-Neubueser conjugacy class algorithm provides
	    a list of class representatives for a group described
	    by a pcp; these representatives have the property that 
	    if a word occurs in the list, then any of its subwords 
	    also occurs as a representative; the calculations listed 
	    below allow us to recognise that certain words would 
	    not occur in the list; if we can deduce that our
	    normal word, w, would not occur, we do not power w; 
            
	    in the iteration listed below, if gen_i = PART2(entry) or 
	    PART3(entry) then gen[j] is a commutator or power of gen_i; 
	    this means that our normal word, w, is a conjugate or a power 
	    of another normal word which starts off with the same first 
	    i generator-exponent pairs as w, but which does not have 
	    gen[j] anywhere in it; 
            
	    note that this reduction is critically sensitive to 
	    the way in which generators are numbered, and to the 
	    way eliminations are carried out in this program;
            
	    Michael Vaughan-Lee provided this refinement */

	 /* first, find last generator in normal word with weight = wt_gen1 */
	 for (i = length; WT(y[structure + gen[i]]) > wt_gen1; --i)
	    ;

	 if (i != length) {
	    exit = FALSE;
	    gen_i = gen[i];
	    for (j = i + 1; j <= length && !exit; ++j) {
	       entry = y[structure + gen[j]];
	       exit = (gen_i == PART2(entry) || gen_i == PART3(entry));
	    }
	    if (exit) {
	       if (exp_flag->filter == TRUE) 
		  printf ("Filtered from list using conjugacy checks\n");
	       continue;
	    }
	 }

	 /* we have a word to exponentiate */
	 ++nmr_words;

	 /* we may want to save all test words generated to 
	    a relation file for later processing */
	 if (exp_flag->word_list) {
	    fprintf (RelationList, "%d ", extra_relations);
	    for (i = 1; i <= length; ++i)
	       for (j = 1; j <= coeff[i]; ++j)
		  fprintf (RelationList, "%d ", gen[i]);
	    fprintf (RelationList, ";\n");
	 }

	 /* space is required for three collected parts set up in power */
	 if (is_space_exhausted (6 * lastg + 6, pcp))
	    return;

	 structure = pcp->structure; 

	 /* put one copy of word into collected part in exponent-vector form */
	 for (i = 1; i <= lastg; ++i)  
	    y[pcp->lused + i] = 0;

	 for (i = 1; i <= length; ++i) {
	    nextg = gen[i];
	    y[pcp->lused + nextg] = coeff[i];
	 }

	 /* if process flag is true, and the number of the word is higher 
	    than supplied value, power the word and echelonise the result */

	 if (exp_flag->process && nmr_words >= exp_flag->start_process) {

	    power (extra_relations, pcp->lused, pcp);

	    /* is the result trivial? if not, group has larger exponent */
	    if (exp_flag->check_exponent == TRUE) {
	       i = 1;
	       while (i <= lastg && exp_flag->all_trivial) {
		  exp_flag->all_trivial = (y[pcp->lused + i] == 0);
		  ++i;
	       }
	       if (exp_flag->all_trivial == FALSE) return;
	    }

	    /* set second collected part trivial for echelonisation */
	    for (i = 1; i <= lastg; ++i)  
	       y[pcp->lused + lastg + i] = 0;

	    echelon (pcp);
	 }

	 /* if appropriate, print out the normal word */
	 if (((pcp->fullop && pcp->eliminate_flag) || 
	      (pcp->diagn && exp_flag->process) ||
	      (pcp->diagn && !exp_flag->process && !exp_flag->filter)) && 
	     nmr_words >= exp_flag->start_process) {
	    s = exp_flag->process ? "Collected" : "Will collect";
	    printf ("%s power %d of the following word: ",
		    s, extra_relations); 
	    for (i = 1; i <= length; ++i) 
	       printf ("%d^%d ", gen[i], coeff[i]);
	    printf ("\n");
	 }

	 if (pcp->redgen != 0 && pcp->m != 0) 
	    queue[++exp_flag->queue_length] = pcp->redgen;

	 /* report intermediate statistics */
	 if (exp_flag->report_unit && nmr_words % exp_flag->report_unit == 0) {
	    s = nmr_words == 1 ? "" : "s";
	    printf ("%d relation%s of class %d collected\n", nmr_words, s, class);
	 }

	 if (pcp->overflow || pcp->complete != 0 || pcp->newgen == 0)
	    return;

      } while (length != 0); 

      /* if appropriate, report the number of words raised to power */
      if (!exp_flag->process || exp_flag->report_unit || 
	  pcp->fullop || pcp->diagn) 
	 text (13, nmr_words, class, exp_flag->process, 0);
   } 

   if (exp_flag->word_list) 
      CloseFile (RelationList);
}

#endif 
