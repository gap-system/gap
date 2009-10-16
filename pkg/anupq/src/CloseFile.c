/****************************************************************************
**
*A  CloseFile.c                 ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: CloseFile.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"

/* close file */

void CloseFile (file)
FILE_TYPE file;
{
   if (CLOSE(file) != 0) {
      perror (NULL);
      exit (FAILURE);
   }
}
