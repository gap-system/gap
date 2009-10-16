/****************************************************************************
**
*A  read_relator_file.c         ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: read_relator_file.c,v 1.3 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"
#include "pcp_vars.h"
#include "pq_functions.h"
#include "word_types.h"

/* collect and echelonise the relators supplied in named 
   file and add any redundancies to queue;

   it is assumed that the relators file has the following format:
   its first entry is the number of elements in the file; 
   each relator is given as a word supplied in standard 
   word/relation format -- that is, exponent followed by list 
   of generators and terminated by the END_OF_WORD symbol;
  
   the word need NOT be in normal form */

void read_relator_file (queue, queue_length, pcp)
int *queue;
int *queue_length;
struct pcp_vars *pcp;
{
#include "define_y.h"

   FILE_TYPE relation_file;
   int nmr_relations;
   int format = BASIC;
   char *name;
   int type;

   int cp;

   register int i, k;
   register int lastg = pcp->lastg;
   
   int nmr_items;

   name = GetString ("Enter relation file name: ");
   relation_file = OpenFile (name, "r+");
   if (relation_file == NULL) return;

   nmr_items = fscanf (relation_file, "%d", &nmr_relations);
   verify_read (nmr_items, 1);

   type = WORD;
   for (i = 1; i <= nmr_relations; ++i) {
      if (pcp->complete) break;
      if (!is_space_exhausted (3 * lastg + 2, pcp)) {
	 cp = pcp->lused;
	 setup_word_to_collect (relation_file, format, type, cp, pcp);
	 if (pcp->diagn) 
	    setup_word_to_print ("collected word", cp, cp + pcp->lastg + 1, pcp);
	 for (k = 1; k <= lastg; ++k)  
	    y[cp + lastg + k] = 0; 
      }

      echelon (pcp);
      if (pcp->redgen != 0 && pcp->m != 0)
	 queue[++*queue_length] = pcp->redgen;
   }
  
   CloseFile (relation_file);
}
