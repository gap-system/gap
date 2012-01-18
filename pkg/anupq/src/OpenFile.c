/****************************************************************************
**
*A  OpenFile.c                  ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: OpenFile.c,v 1.7 2011/11/29 09:43:56 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"

/* fopen file */

FILE* OpenFile (const char *file_name, const char *mode)
{
   FILE *fp; 
  
   if ((fp = fopen (file_name, mode)) == NULL) {
      printf ("Cannot open %s\n", file_name);
      if (!isatty (0))
	 exit (FAILURE);
   }

   return fp;
}

FILE* OpenFileOutput (const char *file_name)
{
   return OpenFile (file_name, "w");
}

FILE* OpenFileInput (const char *file_name)
{
   return OpenFile (file_name, "r");
}

/* open file for fread and fwrite */

FILE* OpenSystemFile (const char *file_name, const char *mode)
{
   FILE *fp; 
     
   if ((fp = fopen (file_name, mode)) == NULL) {
      perror (NULL);
      printf ("Cannot open %s\n", file_name);
      exit (FAILURE);
   }

   setbuf (fp, NULL);
   return fp;
}
