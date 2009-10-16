/****************************************************************************
**
*A  TemporaryFile.c             ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: TemporaryFile.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "pq_functions.h"
#include "constants.h"

/* set up a temporary file and return an appropriate FILE_TYPE indicator; 
   if in Unix environment, open temporary file in directory specified 
   by value of environment variable TMPDIR, else on /var/tmp */

FILE_TYPE TemporaryFile ()
{
   FILE_TYPE file;

#if defined (UNIX) && defined (NEXT) == FALSE 

   char *name;

#if defined (HAS_NO_TEMPNAM)
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
