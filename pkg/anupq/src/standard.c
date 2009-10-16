/****************************************************************************
**
*A  standard.c                  ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: standard.c,v 1.7 2001/07/16 09:27:35 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#if defined (GROUP) 
#if defined (STANDARD_PCP)

#include "pq_defs.h"
#include "constants.h"
#include "pcp_vars.h"
#include "pga_vars.h"
#include "exp_vars.h"
#include "constants.h"
#include "pq_functions.h"
#include "menus.h"
#include "standard.h"

int map_array_size;
int output;
char *find_word ();

/* compute a standard presentation for a group;
   
   this procedure assumes that 
   -- an arbitary finite presentation has been 
      supplied; 
   -- a standard presentation has been computed 
      for the class c p-quotient; 
   -- a presentation for the p-covering group 
      computed using this standard presentation has 
      been set up before the call to this procedure;

   we will now compute the standard presentation for the 
   class c + 1 p-quotient */

void standard_presentation (identity_map, standard_output, auts, pga, pcp)
Logical *identity_map;
int standard_output;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{ 
   int i;
   int **map;
   int t;
   int lastg = pcp->lastg;

   output = standard_output;

#if defined (TIME)
   t = runTime ();
#endif 

   map = start_pga_run (identity_map, auts, pga, pcp);
   if (map == NULL) return;

#if defined (TIME) 
   printf ("time in start_pga is %.2f\n", (runTime () - t) * CLK_SCALE);
#endif

   if (output == MAX_STANDARD_PRINT) {
      printf ("The standard automorphism is:\n");
      for (i = 1; i <= pga->ndgen; ++i) {
	 printf ("%d ---> ", i);
	 print_array (map[i], 1, pcp->lastg + 1);
      }
   }

#if defined (DEBUG) 
   printf ("Map identity? %d\n", *identity_map);
#endif

   map_relations (map, pga, pcp);

   /* memory leakage September 1996 -- originally pcp->lastg */
   free_matrix (map, map_array_size, 1);
}

/* enforce the exponent law, if any, on the group */

void enforce_exp_law (pcp)
struct pcp_vars *pcp;
{
#include "define_y.h"

   struct exp_vars exp_flag;

   if (pcp->extra_relations != 0) {

      initialise_exponent (&exp_flag, pcp);

#if defined (Magma)
      extra_relations (&exp_flag, NULL_HANDLE, pcp);
#else
      extra_relations (&exp_flag, pcp);
#endif

      /* are there redundant defining generators? if so, be careful
	 about elimination -- see next_class for further information */

      if (pcp->ndgen > y[pcp->clend + 1])
	 eliminate (TRUE, pcp);
      else
	 eliminate (FALSE, pcp);
   }
}

/* commence a partial run of p-group generation in order
   to determine the standard presentation for this class */

int **start_pga_run (identity_map, auts, pga, pcp) 
Logical *identity_map;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   FILE_TYPE cover_file;        /* store complete p-cover of group */
   FILE_TYPE cover_tmp_file;    /* store (reduced) p-cover of group */
   FILE_TYPE group_file;        /* store class c + 1 quotient of group */
   int **map;                   /* automorphism to apply to presentation */
   int t;

#if defined (TIME)
   t = runTime ();
#endif

   /* save (reduced) p-covering group presentation to temporary file */
   cover_tmp_file = TemporaryFile ();
   save_pcp (cover_tmp_file, pcp);
   RESET (cover_tmp_file);

   /* we need compute the class c + 1 quotient only on the first
      time through or if the map applied to the previous presentation 
      was not the identity; in these cases, before 
      computing class c + 1 quotient, restore complete p-cover;
      we cannot use the reduced p-cover because a presentation having 
      redundant generators can cause difficulties with interaction 
      between update_generators and eliminate */
     
   if (*identity_map == FALSE) {

      cover_file = OpenFile ("ISOM_cover_file", "r");
      restore_pcp (cover_file, pcp);
      CloseFile (cover_file);

      /* enforce exponent law on complete p-cover */
      enforce_exp_law (pcp);

      /* now compute the presentation for the class c + 1 quotient */
      pcp->multiplicator = FALSE;
      update_generators (pcp);

      collect_relations (pcp);

      eliminate (FALSE, pcp);
      if (pcp->overflow || !pcp->valid)
	 exit (FAILURE);

      /* when relations are enforced, the group may complete */
      if (pcp->complete) {
	 map = group_completed (auts, pga, pcp);
	 *identity_map = TRUE;
	 CloseFile (cover_tmp_file);
	 return map;
      }

      /* save presentation for class c + 1 quotient to file */
      group_file = OpenFile ("ISOM_group_file", "w+");
      save_pcp (group_file, pcp);
   }
   else {
      /* we must restore the presentation to correctly determine step size */
      group_file = OpenFile ("ISOM_group_file", "r");
      restore_pcp (group_file, pcp);
   }

   RESET (group_file);

#if defined (TIME)
   t = runTime () - t;
   printf ("Time to compute class c + 1 is %.2f seconds\n", t * CLK_SCALE);
#endif

   /* note step size required for p-group generation */
   pga->step_size = pcp->lastg - pcp->ccbeg + 1;

   map = finish_pga_run (identity_map, cover_tmp_file, group_file, 
			 auts, pga, pcp);
   CloseFile (group_file);
   CloseFile (cover_tmp_file);

   return map;
}

/* the group has completed when the relations are imposed; we write 
   necessary files in order to have consistent behaviour pattern */

int **group_completed (auts, pga, pcp)
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   FILE_TYPE NextClass;
   FILE_TYPE Status;
   int i, j, k;
   int **standard;

   NextClass = OpenFile ("ISOM_NextClass", "w+");

   fprintf (NextClass, "%d\n", pga->m);
   fprintf (NextClass, "%d\n", pcp->lastg);
   for (i = 1; i <= pga->m; ++i) {
      for (j = 1; j <= pga->ndgen; ++j) {
	 for (k = 1; k <= pcp->lastg; ++k)
	    fprintf (NextClass, "%d ", auts[i][j][k]);
	 fprintf (NextClass, "\n");
      }
   }

   fprintf (NextClass, "%d\n", pga->fixed);
   fprintf (NextClass, "%d\n", pga->soluble);
#if defined (LARGE_INT) 
   mpz_out_str (NextClass, 10, &pga->aut_order);
   fprintf (NextClass, "\n");
#endif
   CloseFile (NextClass);

   Status = OpenFile ("ISOM_Status", "w");
   fprintf (Status, "%d ", END_OF_CLASS);
   fprintf (Status, "%d ", TERMINAL);
   CloseFile (Status);
 
   map_array_size = pcp->lastg;
   standard = allocate_matrix (pcp->lastg, pcp->lastg, 1, FALSE);

   for (i = 1; i <= pga->ndgen; ++i)
      for (j = 1; j <= pcp->lastg; ++j)
	 standard[i][j] = (i == j) ? 1 : 0;

   return standard;
}

/* complete pga run to compute standard presentation for this class */

int **finish_pga_run (identity_map, cover_tmp_file, group_file, auts, pga, pcp)
Logical *identity_map;
FILE_TYPE cover_tmp_file;
FILE_TYPE group_file;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   int **perms;

   FILE *LINK_input;
   int k;
   int upper_step;
   Logical soluble_group;
   Logical process_fork = FALSE; /* has GAP process forked? */
   int *a;
   int *b;
   char *c;
   int *orbit_length;
   int **subgroup_matrix; 
   int K;                       /* bit string representation of definition set */
   int *subset;                 /* definition set */
   int non_standard;            /* label for allowable subgroup defining
				   non-standard presentation */
   int **map;                   /* automorphism to apply to presentation */
   int t;
   char *s;

   restore_pcp (cover_tmp_file, pcp);
   RESET (cover_tmp_file);

#if defined (DEBUG)
   printf ("Now restore p-covering group\n");
   print_presentation (FALSE, pcp);
#endif 

   pga->exponent_law = pcp->extra_relations;
   /*
     enforce_laws (pga, pga, pcp);
     */
   extend_automorphisms (auts, pga->m, pcp);

   /* critical */
   /*
     read_subgroup_rank (&k);
     */

   /* if  you want something other than default, change value of k */
   k = 0;
   step_range (k, &pga->s, &upper_step, auts, pga, pcp);

   if (pga->s != upper_step) {
      pga->s = upper_step;

      /* first, find the valid relative step size, pga->s */
      find_allowable_subgroup (RELATIVE, cover_tmp_file, 
			       group_file, &K, &subset, pga, pcp);
   }

   /* now find allowable subgroup which determines the class c + 1 quotient */
   subgroup_matrix = find_allowable_subgroup (2, cover_tmp_file, 
					      group_file, &K, &subset, pga, pcp);

   restore_pcp (cover_tmp_file, pcp);
   RESET (cover_tmp_file);

#if defined (DEBUG)
   printf ("Now restore p-covering group\n");
   print_presentation (FALSE, pcp);
#endif

#if defined (DEBUG)
   printf ("Rank of characteristic subgroup is %d\n", pga->q); 
#endif

   store_definition_sets (pga->r, pga->s, pga->s, pga);
   get_definition_sets (pga);

#if defined (DEBUG)
   pga->print_degree = TRUE;
#endif 
   compute_degree (pga);
   pga->print_degree = FALSE;

   non_standard = subgroup_to_label (subgroup_matrix, K, subset, pga);

   /* memory leakage September 1996 */
   free_vector (subset, 0);
   free_matrix (subgroup_matrix, pga->s, 0);

   if (output == MAX_STANDARD_PRINT) {
      printf ("Non-standard label is %d\n", non_standard);
      printf ("Required step size is %d\n", pga->step_size);
      printf ("Relative step size is %d\n", pga->s);
      printf ("Rank of characteristic subgroup is %d\n", pga->q);
   }

   strip_identities (auts, pga, pcp);
   soluble_group = (pga->soluble || pga->Degree == 1 || 
		    pga->nmr_of_perms == 0);

   if (!soluble_group) {
#if defined (CAYLEY_LINK) 
      start_CAYLEY_file (&LINK_input, auts, pga);
#else
#if defined (Magma_LINK) 
      start_Magma_file (&LINK_input, auts, pga);
#else
#if defined (GAP_LINK)
      if (!process_fork) {
	 start_GAP_file (auts, pga, pcp);
	 process_fork = TRUE;
      }
      StartGapFile (pga);
#else
#if defined (GAP_LINK_VIA_FILE)
      start_GAP_file (&LINK_input, auts, pga, pcp);
#endif
#endif
#endif
#endif
   }

#if defined (DEBUG)
   /*
     pga->print_permutation = TRUE;
     */
#endif 

#if defined (TIME)
   t = runTime ();
#endif

   perms = permute_subgroups (LINK_input, &a, &b, &c, auts, pga, pcp); 

#if defined (TIME)
   t = runTime () - t;
   printf ("Time to compute permutations is %.2f seconds\n", t * CLK_SCALE);
#endif 
         
   orbit_option (STANDARDISE, perms, &a, &b, &c, &orbit_length, pga);
/* 
   printf ("orbit length is %d \n", orbit_length);
*/

#if defined (CAYLEY_LINK) || defined (Magma_LINK) || defined (GAP_LINK_VIA_FILE)
   if (!soluble_group) { 
      CloseFile (LINK_input);
   }
#endif

   map = find_stabiliser (identity_map, non_standard, auts, perms, a, b, c, 
			  orbit_length, pga, pcp);


   if (pga->final_stage && output >= DEFAULT_STANDARD_PRINT) {
      printf ("\nThe standard presentation for the class %d %d-quotient is\n",
	      pcp->cc, pcp->p);
      print_presentation (TRUE, pcp);
#if defined (LARGE_INT)
      s = pga->upper_bound ? "at most " : "";
      /* Originally pq checked the whole automorphism group.
       * Now it checks only coset reps. of inner automorphisms
       * i.e. those auts that are in 1-1 correspondence with outer auts. */
      printf ("Subset of automorphism group to check has order bound %s", s);
      mpz_out_str (stdout, 10, &(pga->aut_order));
      printf ("\n");
#endif
   }

#if defined (GAP_LINK)
   if (process_fork)
      QuitGap ();
#endif

   free_space (TRUE, perms, orbit_length, a, b, c, pga);

   /* memory leakage September 1996 */
   free_vector (pga->list, 0);
   free_vector (pga->available, 0);
   free_vector (pga->offset, 0);

   return map;
}

/* find the stabiliser of the representative of the orbit which 
   contains the non-standard allowable subgroup */

int **find_stabiliser (identity_map, non_standard, auts, perms, a, b, c, 
                       orbit_length, pga, pcp)
Logical *identity_map;
int non_standard;
int ***auts;
int **perms;
int *a;
int *b;
char *c;
int *orbit_length;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   FILE_TYPE Status;
   FILE_TYPE OutputFile;
   Logical soluble_group;
   int rep[2];
   int length[2];
   int **map;
   int i;
   int t;
   int word_length = 0;
   char *word_map;

#if defined (TIME)
   t = runTime ();
#endif

   soluble_group = (pga->soluble || pga->Degree == 1 || pga->nmr_of_perms == 0);

   /* what is the orbit representative of non_standard? */
   if (soluble_group) 
      rep[1] = abs (a[non_standard]);
   else  {
      if (a[non_standard] < 0)
	 rep[1] = pga->rep[abs (a[non_standard])] ;
      else 
	 rep[1] = abs (a[non_standard]);
   }

   /* find the length of the orbit having this representative */
   for (i = 1; i <= pga->nmr_orbits && pga->rep[i] != rep[1]; ++i)
      ;
   if (pga->rep[i] == rep[1]) {
      length[1] = orbit_length[i];
      if (output == MAX_STANDARD_PRINT) 
	 printf ("The non-standard subgroup %d has orbit representative %d\n", 
		 non_standard, pga->rep[i]);
   }
   else {
      printf ("%d is not an orbit representative\n", rep[1]);
      exit (FAILURE);
   }

   /*
     printf ("True Orbit length is %d\n", length[1]);
     */

   word_map = find_word (&word_length, soluble_group, perms, rep[1], 
			 non_standard, length[1], b, c, pga);

   /* now process this representative and find its stabiliser */

   OutputFile = OpenFile ("ISOM_XX", "w+");

   pga->final_stage = (pga->q == pga->multiplicator_rank);
   
   pga->nmr_of_descendants = 0;
   pga->nmr_of_capables = 0;

   pga->terminal = TRUE;
   setup_reps (rep, 1, length, perms, a, b, c, auts, 
	       OutputFile, OutputFile, pga, pcp); 

   /* now evaluate the action of standard map on pcp */
   map = standard_map (word_map, word_length, identity_map, rep[1], auts, pga, pcp);

#if defined (TIME) 
   t = runTime () - t;
   printf ("Time to process representative is %.2f seconds\n", t * CLK_SCALE);
#endif 

   RESET (OutputFile);
   restore_pcp (OutputFile, pcp);

   if (!pcp->complete) 
      last_class (pcp);

   Status = OpenFile ("ISOM_Status", "w");
   if (pga->final_stage)  
      fprintf (Status, "%d ", END_OF_CLASS);
   else
      fprintf (Status, "%d ", MIDDLE_OF_CLASS);
   if (pcp->newgen == 0) 
      fprintf (Status, "%d ", TERMINAL);
   else
      fprintf (Status, "%d ", CAPABLE);
     
   CloseFile (Status);
   CloseFile (OutputFile);

   return map;
}

void trace (word_map, depth, label, backptr, schreier)
char *word_map;
int *depth;
int label;
int *backptr;
char *schreier;
{
   if (schreier[label] != 0) {
      word_map[++*depth] = schreier[label];
      trace (word_map, depth, backptr[label], backptr, schreier);
   }
}

/* find word in defining permutations which maps orbit representative to label;
   store each component of the word of length word_length in array word */

char *find_word (word_length, soluble_group, perms, rep, 
                 non_standard, orbit_length, b, c, pga)
int *word_length;
Logical soluble_group;
int **perms;
int rep;
int non_standard;
int orbit_length;
int *b;
char *c;
struct pga_vars *pga;
{
   int perm_number;
   char *word_map;
   char *word_perm;
   int i, l;
   char *d; 
   char temp;

   word_map = allocate_char_vector (orbit_length, 1, FALSE);

   /* we store word which maps non-standard label to orbit representative;
      in image_of_generator, the word is evaluated starting from the 
      last letter -- hence after computing the word, we reverse it */

   if (soluble_group) {
      d = find_permutation (b, c, pga);
      l = non_standard;
      while (l != rep) {
	 word_map[++*word_length] = d[l];
	 if ((perm_number = pga->map[d[l]]) != 0) 
	    l = inverse_image (l, perms[perm_number], pga);
      }
      /* reverse word */
      for (i = 1; i <= *word_length / 2; ++i) {
	 temp = word_map[i];
	 word_map[i] = word_map [*word_length - i + 1];
	 word_map [*word_length - i + 1] = temp;
      }
      free_char_vector (d, 1);
   }
   else {
      word_perm = allocate_char_vector (orbit_length, 1, FALSE);
      trace (word_perm, word_length, non_standard, b, c);
      for (i = 1; i <= *word_length; ++i)
	 word_map[i] = preimage (word_perm[*word_length - i + 1], pga); 
      free_char_vector (word_perm, 1);
   }

   return word_map;
}

/* compute the automorphism which maps the non-standard subgroup, 
   non_standard, to the orbit representative, rep; the word and 
   its length are supplied as word_map and word_length  */

int **standard_map (word_map, word_length, identity_map, rep, auts, pga, pcp)
char *word_map;
int word_length;
Logical *identity_map;
int rep;
int ***auts;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
#include "define_y.h"

   int nmr_of_generators = y[pcp->clend + pcp->cc - 1] + pga->s;
   register int pointer = pcp->lused + 1;
   int cp = pcp->lused;
   int **standard;
   int i, j;

   /* copy the word into y */
   for (i = 1; i <= word_length; ++i)
      y[pointer + i] = word_map[i];
   free_char_vector (word_map, 1);

   y[pointer] = word_length;

#if defined (DEBUG)
   printf ("The word is ");
   print_array (y, pointer, pointer + word_length + 1);
#endif 

   pcp->lused += word_length + 1;
   cp = pcp->lused;
   
   map_array_size = pcp->lastg;
   standard = allocate_matrix (pcp->lastg, nmr_of_generators, 1, FALSE);

   if (word_length == 0) {
      for (i = 1; i <= pga->ndgen; ++i)
	 for (j = 1; j <= nmr_of_generators; ++j)
	    standard[i][j] = (i == j) ? 1 : 0;
      *identity_map = TRUE;
   }
   else {
      for (i = 1; i <= pga->ndgen; ++i) {
	 /* compute image of defining generator i under standard map */
	 image_of_generator (i, pointer, auts, pga, pcp);

	 /* copy restriction of result into standard array */
	 for (j = 1; j <= nmr_of_generators; ++j) {
	    standard[i][j] = y[cp + j];
	 }
      }
      *identity_map = FALSE;
   }
   y[pointer] = 0;

   if (!pga->final_stage) 
      list_subgroup (rep, pga, pcp);

   return standard;
}

/* find the image of l under the inverse of the supplied permutation */
   
int inverse_image (l, perms, pga) 
int l;
int *perms;
struct pga_vars *pga;
{
   register int i;

   for (i = 1; i <= pga->Degree && perms[i] != l; ++i) 
      ;

   return i;
}

/* write a description of the automorphism group of the 
   group presented by the standard presentation to file */

void print_aut_description (central, stabiliser, pga, pcp)
int ***central;
int ***stabiliser;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   FILE_TYPE NextClass;
   int i, j, k;

   NextClass = OpenFile ("ISOM_NextClass", "w+");

   fprintf (NextClass, "%d\n", pga->nmr_centrals + pga->nmr_stabilisers);
   fprintf (NextClass, "%d\n", pcp->lastg);
   for (i = 1; i <= pga->nmr_centrals; ++i) {
      for (j = 1; j <= pga->ndgen; ++j) {
	 for (k = 1; k <= pcp->lastg; ++k)
	    fprintf (NextClass, "%d ", central[i][j][k]);
	 fprintf (NextClass, "\n");
      }
   }

   for (i = 1; i <= pga->nmr_stabilisers; ++i) 
      for (j = 1; j <= pga->ndgen; ++j) {
	 for (k = 1; k <= pcp->lastg; ++k)
	    fprintf (NextClass, "%d ", stabiliser[i][j][k]);
	 fprintf (NextClass, "\n");
      }

   fprintf (NextClass, "%d\n", pga->fixed);
   fprintf (NextClass, "%d\n", pga->soluble);

#if defined (LARGE_INT) 
   mpz_out_str (NextClass, 10, &pga->aut_order);
   fprintf (NextClass, "\n");
#endif

   CloseFile (NextClass);
}

/* list orbit representative as generators of subgroup to 
   factor from p-covering group */

int list_subgroup (rep, pga, pcp)
int rep;
struct pga_vars *pga;
struct pcp_vars *pcp;
{
   register int lastg = pcp->lastg;
   register int i, j, k;
   FILE_TYPE Subgroup;
   int word[MAXWORD];
   int *subset;
   int **S;
   int index;
   int length = 0;
  
   if (pga->s == pga->q) return;

   Subgroup = OpenFile ("ISOM_Subgroup", "a+");
   S = label_to_subgroup (&index, &subset, rep, pga);

#if defined (DEBUG)
   printf ("The standard matrix is\n");
   print_matrix (S, pga->s, pga->q);
#endif

   for (i = 0; i < pga->q; ++i) {

      if  (1 << i & pga->list[index]) continue;

      for (j = 1; j <= lastg; ++j)
	 word[j] = 0;

      for (j = 0; j < pga->s; ++j)
	 if (S[j][i] != 0)
	    word[pcp->ccbeg + subset[j]] = pga->p - S[j][i];

      word[pcp->ccbeg + i] = 1;

#if defined (DEBUG)
      printf ("The subgroup generator is ");
      print_array (word, pcp->ccbeg, pcp->ccbeg + pga->q);
#endif
     
      length = 0;
      for (k = pcp->ccbeg; k <= lastg; ++k)
	 if (word[k] != 0)
	    ++length;

      fprintf (Subgroup, "%d\n", COLLECT);
      for (k = pcp->ccbeg; k <= lastg; ++k) {
	 if (word[k] != 0) {
	    fprintf (Subgroup, "x%d^%d", k, word[k]);
	    if (--length != 0)
	       fprintf (Subgroup, " * ");
	 }
      }
      fprintf (Subgroup, ";\n");
   }

   /* memory leakage September 1996 */
   free_matrix (S, pga->s, 0);
   free_vector (subset, 0);

   /* write out flag to indicate that we should now eliminate 
      redundant generators */
   fprintf (Subgroup, "%d\n", ELIMINATE);

   CloseFile (Subgroup);
}

/* for each automorphism in turn, read its actions on each 
   of the pcp generators of the Frattini quotient */

int*** read_auts_from_file (file, nmr_of_auts, pcp)
FILE *file;
int *nmr_of_auts;
struct pcp_vars *pcp;
{
#include "define_y.h"

   register int i, j, k;
   int ***auts;
   int nmr_of_exponents, nmr_of_generators; 
   int nmr_items;

   nmr_items = fscanf (file, "%d", nmr_of_auts); 
   verify_read (nmr_items, 1);
   
   nmr_items = fscanf (file, "%d", &nmr_of_exponents); 
   verify_read (nmr_items, 1);

   nmr_of_generators = y[pcp->clend + 1];

   auts = allocate_array (*nmr_of_auts, pcp->lastg, pcp->lastg, TRUE); 

   for (i = 1; i <= *nmr_of_auts; ++i) {
      for (j = 1; j <= nmr_of_generators; ++j) {
	 for (k = 1; k <= nmr_of_exponents; ++k)  
	    nmr_items = fscanf (file, "%d", &auts[i][j][k]);
	 verify_read (nmr_items, 1);
      }
   }

   return auts;
}

#endif 
#endif 
