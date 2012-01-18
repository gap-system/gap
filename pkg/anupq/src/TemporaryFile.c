/****************************************************************************
**
*A  TemporaryFile.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: TemporaryFile.c,v 1.5 2011/11/29 09:43:56 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pq_functions.h"
#include "constants.h"

/* set up a temporary file and return an appropriate FILE * indicator; 
   if in Unix environment, open temporary file in directory specified 
   by value of environment variable TMPDIR, else on /var/tmp */

FILE * TemporaryFile ()
{
   FILE * file;

/* TODO: Rewrite this, e.g. using tmpfile */

#if defined(HAVE_TEMPNAM) || defined(HAVE_TMPNAM)

   char *name;

#if !defined(HAVE_TEMPNAM)
   name = allocate_char_vector (L_tmpnam + 1, 0, FALSE);
   if ((name = tmpnam (name)) == NULL) {
      perror ("Cannot open temporary file");
      exit (FAILURE);
   }
#else
   if ((name = tempnam (NULL, "PQ")) == NULL) {
      perror ("Cannot open temporary file");
      exit (FAILURE);
   }
#endif

   file = OpenFile (name, "w+");

   if (unlink (name) != 0) {
      perror ("Cannot unlink temporary file");
      exit (FAILURE);
   }
  
   free(name);

#else

   if ((file = tmpfile ()) == NULL) {
      perror ("Cannot open temporary file");
      exit (FAILURE);
   }

#endif

   return file;
}
