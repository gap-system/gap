/****************************************************************************
**
*A  exponent_auts.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: exponent_auts.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pcp_vars.h"
#include "pq_functions.h"

/* save description of automorphisms used in exponent checking to file */

void save_auts (ofp, head, list, pcp)
FILE_TYPE ofp;
int *head;
int *list; 
struct pcp_vars *pcp;
{
   register int alpha;
   register int offset;
   register int required_offset;
   register int prev = 0;

   register int m = pcp->m;
   register int required_ptr, stored_ptr;
   int required_length, stored_length;
   register int original, diff;
   register int j;
   int list_length;
   int retain;

   int nmr_items;
   int *copy_head;

   /* the action on more than lastg generators may be stored in 
      list; if this is the case, establish how many entries from 
      the array list must be stored in order to retain the 
      description of the automorphisms on lastg generators */

   original = head[0];

   if (head[0] > pcp->lastg) {
      copy_head = allocate_vector (pcp->lastg * m + 1, 0, FALSE);
      list_length = 0;
      retain = pcp->lastg;
      diff = 0;
      for (alpha = 1; alpha <= m; ++alpha) {
	 offset = (alpha - 1) * original;
	 required_offset = (alpha - 1) * retain;
	 for (j = 1; j <= retain; ++j)
	    copy_head[required_offset + j] = head[offset + j] - diff;

	 required_ptr = head[offset + retain];
	 stored_ptr = head[offset + original];
	 stored_length = stored_ptr + list[stored_ptr + 1] + 1 - prev;
	 required_length = required_ptr + list[required_ptr + 1] + 1 - prev;

	 diff += stored_length - required_length;

	 list_length += required_length;
	 prev += stored_length;
      }
   }
   else {
      copy_head = head;
      retain = head[0]; 
      list_length = list[0];
   }

   prev = 0;

   nmr_items = fwrite (&retain, sizeof (int), 1, ofp);
   verify_read (nmr_items, 1); 
   nmr_items = fwrite (&list_length, sizeof (int), 1, ofp);
   verify_read (nmr_items, 1); 

   for (alpha = 1; alpha <= m; ++alpha) {
      offset = (alpha - 1) * original;
      required_offset = (alpha - 1) * retain;
      nmr_items = fwrite (copy_head + required_offset + 1, sizeof (int), retain, ofp);
      verify_read (nmr_items, retain); 
      required_ptr = head[offset + retain];
      stored_ptr = head[offset + original];
      stored_length = stored_ptr + list[stored_ptr + 1] + 1 - prev;
      required_length = required_ptr + list[required_ptr + 1] + 1 - prev;
      nmr_items = fwrite (&required_length, sizeof (int), 1, ofp);
      verify_read (nmr_items, 1); 
      nmr_items = fwrite (list + prev + 1, sizeof (int), required_length, ofp);
      verify_read (nmr_items, required_length); 
      prev += stored_length;
   }

   if (original != retain) 
      free_vector (copy_head, 0);

   RESET(ofp);
}

/* restore automorphisms used in exponent checking from file ifp;
   nmr_saved = nmr of generators whose images have been saved to file;
   retain    = nmr of generators whose images are to be retained;
   new_index = index of last used position in array list */

int restore_auts (ifp, offset, nmr_saved, retain, new_index, head, list)
FILE_TYPE ifp;
int offset;
int nmr_saved;
int retain;
int *new_index;
int *head;
int *list;
{
   int alpha_length;            /* length of the automorphism description */
   int i, add;
   int nmr_items;

   nmr_items = fread (head + offset + 1, sizeof (int), nmr_saved, ifp);
   verify_read (nmr_items, nmr_saved);

   add = *new_index - head[offset + 1];
   for (i = 1; i <= nmr_saved; ++i)
      head[offset + i] += add;

   nmr_items = fread (&alpha_length, sizeof (int), 1, ifp);
   verify_read (nmr_items, 1);
   nmr_items = fread (list + *new_index + 1, sizeof (int), alpha_length, ifp);
   verify_read (nmr_items, alpha_length);

   *new_index = head[offset + retain] + list[head[offset + retain] + 1] + 1;
   
   return alpha_length;
}

/* restore automorphisms used in exponent checking from file */

void restore_automorphisms (ifp, head, list, pcp)
FILE_TYPE ifp;
int **head;
int **list;
struct pcp_vars *pcp;
{
   int new_index = 0;
   int offset;
   register int alpha;
   int nmr_saved;
   int list_length;
   int retain;
   int nmr_items;

   nmr_items = fread (&nmr_saved, sizeof (int), 1, ifp);
   verify_read (nmr_items, 1);
   nmr_items = fread (&list_length, sizeof (int), 1, ifp);
   verify_read (nmr_items, 1);

   *head = allocate_vector (nmr_saved * pcp->m + 1, 0, FALSE);
   (*head)[0] = nmr_saved;

   *list = allocate_vector (list_length + 1, 0, FALSE);
   (*list)[0] = list_length;
 
   retain = MIN (pcp->lastg, nmr_saved);
   for (alpha = 1; alpha <= pcp->m; ++alpha) {
      offset = (alpha - 1) * retain;
      restore_auts (ifp, offset, nmr_saved, retain, &new_index, *head, *list);
   }
   (*head)[0] = retain;

   printf ("Automorphisms read from file\n");
}
