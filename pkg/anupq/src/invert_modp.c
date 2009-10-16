/****************************************************************************
**
*A  invert_modp.c               ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: invert_modp.c,v 1.3 2001/06/15 14:31:51 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* compute the multiplicative inverse of x modulo p
   using the forward extended euclidean algorithm */

int invert_modp (x, p)
int x;
int p;
{
   register int q;
   register int a1 = p;
   register int a2 = x;
   register int a3;
   register int y1 = 0;
   register int y2 = 1;
   register int y3;

   while (a2 != 1) {
      q = a1 / a2;
      a3 = a1 - a2 * q;
      y3 = y1 - y2 * q;
      a1 = a2;
      a2 = a3;
      y1 = y2;
      y2 = y3;
   }

   if (y2 < 0)
      y2 += p;

   return y2;
}
