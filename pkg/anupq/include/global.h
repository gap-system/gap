/****************************************************************************
**
*A  global.h                    ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: global.h,v 1.4 2001/06/21 23:04:21 gap Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* global variables used in main and setup_reps */

#ifndef __GLOBALS__
#define __GLOBALS__

#define CAYLEY_LIBRARY 1
#define GAP_LIBRARY 2
#define Magma_LIBRARY 3

int Group_library;
int Compact_Description;
int Compact_Order;
char *Group_library_file;

extern Logical GAP4iostream;

#endif
