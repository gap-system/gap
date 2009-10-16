/****************************************************************************
**
*A  read_value.c                ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: read_value.c,v 1.5 2001/06/15 14:31:52 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

#include "pq_defs.h"
#include "constants.h"
#include "pcp_vars.h"

/* function to read line */

void read_line ()
{
   int c;

   while ((c = getchar()) != EOF && c != '\n')
      ;
}

/* continue to read parameter until its value is at least lower_bound */

void read_value (newline, string, value, lower_bound) 
Logical newline;
char *string;
int *value;
int lower_bound;
{
   char response[MAXWORD];
   Logical error;
   Logical reading = TRUE;
   int nmr_items;

   while (reading) {
      printf ("%s", string);
      nmr_items = scanf ("%s", response);
      verify_read (nmr_items, 1);

      /* read past any comments */
      while (response[0] == COMMENT) {
	 read_line ();
	 nmr_items = scanf ("%s", response);
	 verify_read (nmr_items, 1);
      }
      if (!isatty (0)) printf ("%s ", response);
      if (!isatty (0) && newline) printf ("\n");
      *value = string_to_int (response, &error);
      if (error) 
	 printf ("Error in input -- must be integer only\n");
      else if (reading = (*value < lower_bound)) 
	 printf ("Error: supplied value must be at least %d\n", lower_bound);

   }
}

/* convert string s to integer */

int string_to_int (s, error)
char *s;
Logical *error;
{
   int i, n, sign;

   *error = FALSE;

   for (i = 0; isspace (s[i]); i++) /* skip white space */
      ;
   sign = (s[i] == '-') ? -1 : 1;
   if (s[i] == '+' || s[i] == '-') /* skip sign */
      i++;
   for (n = 0; s[i] != '\0'; i++) {
      if (isdigit (s[i])) {
	 n = 10 * n + (s[i] - '0'); 
      }
      else {
	 *error = TRUE;
	 return 0;
      }
   }

   return sign * n;
}

/* read in string */
 
char* GetString (string)
char *string;
{
   int nmr_items;
   char *s = (char *) malloc (MAXIDENT * sizeof (char));

   printf ("%s", string);

   nmr_items = scanf ("%s", s);
   verify_read (nmr_items, 1);
   while (s[0] == COMMENT) {
      read_line ();
      nmr_items = scanf ("%s", s);
      verify_read (nmr_items, 1);
   }
   if (!isatty (0)) printf ("%s\n", s);

   return s;
}
