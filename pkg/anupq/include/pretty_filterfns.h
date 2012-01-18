/****************************************************************************
**
*A  pretty_filterfns.h          ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pretty_filterfns.h,v 1.5 2011/11/29 10:16:01 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* header file supplied by Sarah Rees */

#ifndef __PRETTY_FILTER__
#define __PRETTY_FILTER__

#include <stdlib.h>
typedef int gen_type; /*name for generator*/
#define anu_valloc(A,N) (A *)malloc((unsigned)(sizeof(A)*(N)))
#define vzalloc(A,N) (A *)calloc((unsigned)N,(unsigned)sizeof(A))
#define inv(g)          inv_of[(g)]
extern char word_delget_first(); 
extern char word_del_last(); 
extern char word_next();
extern char read_next_gen();
extern char read_next_word();
extern char word_get_last();
extern char find_keyword();
extern char read_next_string();
extern char read_next_int();
extern char word_eq();

typedef struct {
   gen_type *g;
   int first;	       /* the position of the first entry in the word */
   int last;	       /* position of last entry; if word is empty, 
                          define this to be position BEFORE first entry */
   int space;	       /* this should be a power of 2 */
   char type; /* initialised to 0, 'c' for commutator, or 's' for string */
   int n; /* used if the word is a power of that pointed to by the "g" field.
            0 means the same as 1, i.e. the word is not a proper power */
} word;

typedef struct word_link {
   word * wp;
   struct word_link * next;
} word_link;

word_link * word_link_create(void);
void word_link_init (word_link * wlp);
void word_link_clear (word_link * wlp);

void word_expand (word *wp);
void word2prog_word (word *user_wordp, word *prog_wordp);

void default_inverse_array (void);
int read_char (FILE *rfile);
void find_char (char c, FILE *rfile);

typedef struct word_traverser {
   word * wp;
   int posn;
} word_traverser;

#define word_length(wp)         (((wp)->last) + 1 - ((wp)->first))

extern int num_gens;
extern int paired_gens;
extern gen_type * inv_of;
extern int * pairnumber;
extern word * user_gen_name;
extern int gen_array_size;


#endif 
