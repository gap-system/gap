/****************************************************************************
**
*A  pretty_filter.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pretty_filter.c,v 1.5 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pq_functions.h"
#include "constants.h"
#include "pcp_vars.h"
#include "pretty_filterfns.h"

/* SIGNIFICANT is the number of significant characters in the 
   keyword strings; if you change this, you'll have to change 
   the calls to strcmp so that the strings being compared with 
   label continue to have length SIGNIFICANT */

#define SIGNIFICANT 3

FILE *rfile;
FILE *wfile; 

extern int num_gens;
extern gen_type *inv_of;
extern word *user_gen_name;
extern int gen_array_size;
extern int *pairnumber;
extern int paired_gens;
char gpname[MAXIDENT];
char filename[MAXIDENT];

/* process "pretty" presentation input from file using key words; 
   this is a modified version of code written by Sarah Rees */

int pretty_filter (file, max_class, output, pcp)
FILE *file;
int *max_class;
int *output; 
struct pcp_vars *pcp;
{
#include "define_y.h" 

   int prime = 0;
   int exponent = 0;
   int nrels = 0;
   int end = MAXIDENT - 1;

   int count, posn;
   int ptr, relp, length;
   int i = 1;
   char c;
   word w;
   word_link *root = word_link_create ();
   word_link *wlp = 0;
   word_link *next = 0;
   gen_type g;
   char label[SIGNIFICANT + 1];
   Logical metabelian_flag = FALSE;

   int degree; /* degree of multilinear condition for Lie Program */
   rfile = file;

   wfile = stdout;
   *max_class = 10;
   *output = 1;
   inv_of = 0;
   paired_gens = 0;

   strcpy (gpname, "G");
   wfile = stdout;
   
   pcp->cover = 0;

#if defined (LIE) 
   strcpy (gpname, "R");
   pcp->mlin_relations[0] = 0; 
#endif 

   while (read_next_string (label, SIGNIFICANT, rfile)) {
      if (strcmp (label, "nam")==0) {
	 read_next_string (gpname, end, rfile);
	 /* knock off the blank spaces at the end  */
	 i = end - 1; while (i >= 0 && gpname[i] == ' ') i-- ; 
	 gpname[i+1] = '\0'; 
      }
      else if (strcmp (label, "pri") == 0) {
	 read_next_int (&prime, rfile);
      }
      else if (strcmp (label, "cla") == 0) {
	 read_next_int (max_class, rfile);
      }
      else if (strcmp (label, "out") == 0) {
	 read_next_int (output, rfile);
      }
      else if (strcmp (label, "met") == 0) {
	 metabelian_flag = TRUE;
      }
      else if (strcmp (label, "exp") == 0) {
	 read_next_int (&exponent, rfile);
      }
#if defined (LIE)
      else if (strcmp (label, "deg") == 0) {
	 read_next_int (&degree, rfile);
	 pcp->mlin_relations[0] = degree; 
      }
#endif 
      else if (strcmp (label, "gen") == 0) {
	 read_gen_name_array (rfile);
	 default_inverse_array ();
	 pairnumber = valloc (int, num_gens + 1);
	 for (i = 1; i <= num_gens; i++){ 
	    if (i <= inv (i)){
	       paired_gens++;
	       pairnumber[i] = pairnumber[inv (i)] = paired_gens;
	    }
	 }
      }
      else if (strcmp (label, "rel") == 0) {
	 /* read in and store the relations/relators; every 
	    relator/relation is actually stored as a relation 
	    (i.e. two consecutive words in the list) */
	 find_char ('{', rfile);
	 pc_word_init (&w);
	 wlp = root;
	 while (read_next_word (&w, rfile)){
	    nrels++;
	    word_link_init (wlp);
	    word2prog_word (&w, wlp->wp);
	    wlp = wlp->next;
	    pc_word_reset (&w);
	    while ((c = read_char (rfile)) == ' ');
	    word_link_init (wlp);
	    if (c == '='){
	       count = 1;
	       posn = ftell(rfile); /* mark posn */
	       /* pick up the word at the end of the chain of '=''s as 
		  the right hand side of the equation */
	       do {
		  read_next_word (&w, rfile);
		  while ((c = read_char (rfile)) == ' ');
		  if (c == '='){ pc_word_reset (&w); count++;}
	       } while (c == '=');
	       ungetc(c,rfile);
	       word2prog_word (&w, wlp->wp);
	       pc_word_reset (&w);
	       if (count>1){
		  if (!isatty (0)) fseek (rfile,posn,0);
		  /* go back to the marker if there was more than one '=' */
		  else { 
		     /* we can't use fseek if we're inputting from stdin */
		     printf ("You may not input relations of the type u = v = w from terminal\n");
		     exit (FAILURE);
		  }
	       }
	    }
	    else ungetc (c, rfile);
	    wlp = wlp->next;
	 }
	 find_char ('}', rfile);
	 word_clear (&w);
      }
   }

   /* a single ; or one preceded by an unrecognised keyword 
      marks the end of the data */
   find_char (';', rfile);      /* pick up the terminating ';' */

   pcp->p = prime;
   pcp->ndgen = paired_gens;
   pcp->ndrel = nrels;
   pcp->extra_relations = exponent;
   strcpy (pcp->ident, gpname);
   pcp->diagn = (*output == MAX_PRINT);
   pcp->fullop = (*output >= INTERMEDIATE_PRINT);

   check_input (*output, max_class, pcp);
   if (!pcp->valid)
      return INPUT_ERROR;

   initialise_pcp (*output, pcp);

   /* set the metabelian flag appropriatedly */
   pcp->metabelian = metabelian_flag;

   setup (pcp);

   /* next set up each relation in the list, as left hand side followed
      by right hand side, after expressing each as a power if possible */
   wlp = root; ptr = pcp->lused;
   relp = pcp->relp;

   while (wlp->wp) {
      word * wp = wlp->wp;
      gen_type * gp = wp->g + wp->first;
      gen_type * ggp = wp->g + wp->last;
      ptr = pcp->lused + 1;

      length = 1;
      while (gp <= ggp) {
	 g = *gp;
	 y[ptr + (++length)] = 
	    (g <= inv (g)) ? pairnumber[g] : -pairnumber[g];
	 gp++;
      }
      
      /* set up exponent */
      if (wp->n) y[ptr + 1] = wp->n;
      else if (length==1) y[ptr + 1] = 0; 
      /* this deals with the trivial word */
      else y[ptr + 1] = 1;

      /* set up relation length */
      if (wp->type=='c') y[ptr] = -length;
      else y[ptr] = length;

      ++relp;
      y[relp] = ptr;
      pcp->lused += (length + 1);
      next = wlp->next;
      word_link_clear (wlp);
      wlp = next;
   }

   pcp->gspace = pcp->lused + 1;
   free ((char *) wlp);

   if (user_gen_name) {
      for (i = 0; i < gen_array_size; ++i) 
	 word_clear (user_gen_name + i);
      free ((char *) user_gen_name);
      user_gen_name = 0;
   }
   if (inv_of) {
      free ((char *) inv_of); 
      inv_of = 0;
   }

   return SUCCESS;
}

/* check the input supplied to the p-quotient calculation */

void check_input (output, max_class, pcp)
int output;
int *max_class;
struct pcp_vars *pcp;
{
   pcp->valid = TRUE;

   if (output < 0 || output > MAX_PRINT) {
      printf ("Print level must lie between %d and %d\n", MIN_PRINT, MAX_PRINT);
      pcp->valid = FALSE;
   }

   if (pcp->ndgen > MAXGENS) {
      printf ("The maximum number of defining generators is %d\n", MAXGENS);
      pcp->valid = FALSE;
   }

   if (pcp->ndgen < 1) {
      printf ("The minimum number of defining generators is 1\n");
      pcp->valid = FALSE;
   }

   if (pcp->p != 2 && MOD(pcp->p, 2) == 0) {
      printf ("%d is not a prime\n", pcp->p);
      pcp->valid = FALSE;
   }

   if (*max_class == 0) {
      *max_class = DEFAULT_CLASS;
      text (15, DEFAULT_CLASS, 0, 0, 0);
   }
   else if (*max_class > MAXCLASS) {
      *max_class = MAXCLASS;
      text (15, MAXCLASS, 0, 0, 0);
   }
   else if (*max_class < 0) {
      printf ("Class must be a non-negative integer\n");
      pcp->valid = FALSE;
   }
}

/* read the generator list */

int pretty_read_generators (pcp)
struct pcp_vars *pcp;
{
   Logical reading = TRUE;
   int i;

   rfile = stdin;
   wfile = stdout;

   while (reading) {

      printf ("Input generating set (in { }): ");

      paired_gens = 0;
      inv_of = 0;                  /* bug fix */
      read_gen_name_array (rfile);
      default_inverse_array ();
      pairnumber = valloc (int, num_gens + 1);
      for (i = 1; i <= num_gens; i++) { 
	 if (i <= inv (i)){
	    paired_gens++;
	    pairnumber[i] = pairnumber[inv (i)] = paired_gens;
	 }
      }
      pcp->ndgen = paired_gens;

      if (reading = (pcp->ndgen > MAXGENS)) 
	 printf ("The maximum number of defining generators is %d\n", MAXGENS);

      if (!isatty (0)) printf ("\n");
   }
}

/* read the list of relations (and the exponent) using pretty format */

void pretty_read_relations (output, max_class, pcp)
int output;
int *max_class;
struct pcp_vars *pcp;
{
#include "define_y.h" 

   int ptr, relp, length;
   int i = 1;
   char c;
   int nrels = 0;
   int count, posn, mlin;
   word w;
   word_link *root = word_link_create ();
   word_link *wlp = 0;
   word_link *next = 0;
   gen_type g;

   rfile = stdin;
   wfile = stdout;

   printf ("Input defining set of relations (in { }): ");

   /* read in and store the relations/relators; each relator/relation 
      is stored as a relation (two consecutive words in the list) */

   find_char ('{', rfile);
   pc_word_init (&w);
   wlp = root;
   while (read_next_word (&w, rfile)) {
      nrels++;
      word_link_init (wlp);
      word2prog_word (&w, wlp->wp);
      wlp = wlp->next;
      pc_word_reset (&w);
      while ((c = read_char (rfile)) == ' ');
      word_link_init (wlp);
      if (c == '=') {
	 count = 1;
	 posn = ftell(rfile);   /* mark position */
	 /* pick up the word at the end of the chain of '=''s as 
	    the right hand side of the equation */
	 do {
	    read_next_word (&w, rfile);
	    while ((c = read_char (rfile)) == ' ');
	    if (c == '=') { pc_word_reset (&w); count++;}
	 } while (c == '=');
	 ungetc (c,rfile);
	 word2prog_word (&w, wlp->wp);
	 pc_word_reset (&w);
	 if (count > 1){
	    if (!isatty (0)) fseek (rfile,posn,0);
	    /* go back to the marker if there was more than one '=' */
	    else { 
	       /* we can't use fseek if we're inputting from stdin */
	       printf ("You may not input relations of the type u = v = w from terminal\n");
	       exit (FAILURE);
	    }
	 }
      }
      else ungetc (c, rfile);
      wlp = wlp->next;
   }
   find_char ('}', rfile);

   if (!isatty (0)) printf ("\n");

   pcp->ndrel = nrels;

   check_input (output, max_class, pcp);
   if (!pcp->valid)
      return;

#if defined (GROUP) 
   read_value (TRUE, "Input exponent law (0 if none): ",
	       &pcp->extra_relations, 0);
#endif

#if defined (LIE)
   if (pcp->p != 2)
      read_value (TRUE, "Input degree of multilinear condition (0 if none): ", 
		  &pcp->mlin_relations[0], 0); 
   else {
      for (i = 0; i <= 3; i++)
	 pcp->mlin_relations[i] = 0;
      read_value (TRUE, "Enter number of multilinear relations to be imposed: ",
		  &mlin, 0); 
      if (mlin == 0)
	 pcp->mlin_relations[0] = mlin;
      else 
	 for (i = 0; i <= mlin - 1; ++i)
	    read_value (TRUE, "Input degree of multilinear condition (0 if none): ", 
			&pcp->mlin_relations[i], 0);
   }
#endif

   initialise_pcp (output, pcp);
   setup (pcp);

   /* next set up each relation in the list, as left hand side followed
      by right hand side, after expressing each as a power if possible */
   wlp = root; ptr = pcp->lused;
   relp = pcp->relp;

   while (wlp->wp) {
      word * wp = wlp->wp;
      gen_type * gp = wp->g + wp->first;
      gen_type * ggp = wp->g + wp->last;
      ptr = pcp->lused + 1;

      length = 1;
      while (gp <= ggp) {
	 g = *gp;
	 y[ptr + (++length)] = (g <= inv (g)) ? pairnumber[g] : -pairnumber[g];
	 gp++;
      }
      
      /* set up exponent */
      if (wp->n) y[ptr + 1] = wp->n;
      else if (length == 1) y[ptr + 1] = 0; 
      /* this deals with the trivial word */
      else y[ptr + 1] = 1;

      /* set up relation length */
      if (wp->type == 'c') y[ptr] = -length;
      else y[ptr] = length;

      ++relp;
      y[relp] = ptr;
      pcp->lused += (length + 1);
      next = wlp->next;
      word_link_clear (wlp);
      wlp = next;
   }

   pcp->gspace = pcp->lused + 1;
   free ((char *) wlp);

   if (user_gen_name) {
      for (i = 0; i < gen_array_size; ++i) 
	 word_clear (user_gen_name + i);
      free ((char *) user_gen_name);
      user_gen_name = 0;
   }
   if (inv_of) {
      free ((char *) inv_of); 
      inv_of = 0;
   }
}
