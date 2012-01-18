/****************************************************************************
**
*A  CloseFile.c                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: CloseFile.c,v 1.4 2011/11/29 09:43:56 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"

/* close file */

void CloseFile (FILE* file)
{
   if (fclose(file) != 0) {
      perror (NULL);
      exit (FAILURE);
   }
}
