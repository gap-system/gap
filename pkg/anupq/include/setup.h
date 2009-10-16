/****************************************************************************
**
*A  setup.h                     ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: setup.h,v 1.3 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* in general pointers have the following format: 
   if non-negative then they have that value; otherwise -pointer 
   points to the base address of an exponent-generator string; 
   these strings are made up of a header block consisting of a 
   pointer and length followed by exponent-generator pair(s) 
   stored in array y in the following format

   pointer   length   exp-gen   exp-gen    exp-gen   ...  

   By default, the program has the following limits:
   the maximum no of pc generators is 2^16 - 1 = 65535; 
   the maximum no of defining generators is 2^9 - 1 = 511; 
   the maximum class is 2^6 - 1 = 63; 
   the maximum exponent is 2^15 - 1;

   The program can be compiled in two modes; in fixed mode
   the above limits are enforced; in runtime mode, these are 
   also the default; however, the limit on the number of defining 
   generators and the class can be altered by the user via 
   on-line options "-d" and "-c"; if such selections are made, 
   the maximum number of pc generators is consequently altered; 
   a user must decide the limit on *each* of the number of 
   defining generators and the class;

   The default limits are set in the header files: 
   storage_fixed.h (for the fixed version)
   runtime.h       (for the runtime version).

   If you wish to compile the runtime mode version, then set
   the RUN_TIME compiler flag in the Makefile.

   for i positive --
   y[pcp->dgen + i] is a pointer for defining generator i 
   y[pcp->dgen + i] = j (positive) if defining generator i is not redundant
   and is assigned generator number j in pcp;
   y[pcp->dgen + i] = 0 if defining generator i is currently trivial;
   y[pcp->dgen + i] = -ptr if defining generator i is redundant 
   where ptr is the base address for its value relative to y[0];

   for i negative --
   y[pcp->dgen + i] is a pointer for inverse of defining generator i;
   y[pcp->dgen + i] = 1 if inverse of defining generator i not needed;
   y[pcp->dgen + i] = 0 if inverse is needed and is currently trivial;
   y[pcp->dgen + i] = -ptr if inverse of defining generator is needed
   where ptr is the base address for its value relative to y[0];

   y[pcp->dgen + pcp->ndgen + i] contains the maximum number of 
   occurrences of defining generator i in the structure of a
   pcp-generator or 0;

   y[pcp->relp + 2 * i - 1] is a pointer to lhs of defining relation i;
   y[pcp->relp + 2 * i] is a pointer to rhs of defining relation i;
   y[pcp->relp + 2 * i(-1)] = 0 if this side of relation is trivial, 
   else y[pcp->relp + 2 * i(-1)] = ptr where ptr is the base address 
   of this side of relation;

   a base address, ba say, of a value of a redundant defining
   generator, inverse of a defining generator, side of a defining
   relation, power or commutator table entry is such that 
   y[ba] is the start of a header block of length 2; 
   y[ba] contains a pointer, ptr say, which is the y-index of the 
   cell referring to this value (that is, y[ptr] = -ba); 
   y[ba + 1] contains the length of the following string
   (the string starting in y[ba + 2] and ending in y[ba + 1 + y[ba + 1]);

   when a string is no longer needed, y[ba] is set to 0 and y[ptr] is
   changed to point to its new value; when only 1 word is to be taken
   off of a string there is not a sufficient gap left to form a new
   2 word header block and this is overcome by forming a 1 word header
   block containing the value -1 (this is only needed for subroutine
   compact); 
   
   allocation of storage in the array y is made in both directions; 

   the following data is stored at the front of y
   1) y[pcp->clend + i] i = 0 .. MAXCLASS
   2) y[pcp->dgen + i]  i = -pcp->ndgen .. pcp->ndgen .. 2 * pcp->ndgen
   3) y[pcp->relp + i]  i = 1 .. 2 * pcp->ndrel
   4) the group defining relations (with only a 1 word header block
      containing the total length of the following exponent and side 
      of a group defining relation);
   5) garbage collectable space (y[pcp->gspace] to y[pcp->lused])
      after initialisation the data 1) to 4) is stable in size;
      the garbage collectable space comprises strings of data with 
      each string preceded by a header block; temporary storage is 
      available in y[pcp->lused + 1] to y[pcp->subgrp] to do collections, 
      assemble strings, etc;

   the following data is stored at the back of y
   1) subgroup information (y[pcp->subgrp + i])
   2) word information (y[pcp->words + i])
   3) structure information (y[structure + i])
   4) pointers to powers (y[pcp->ppower + i])
   5) pointers to pointers to commutators (y[pcp->ppcomm + i])
   6) pointers to commutators; to find the value of the commutator
      (b,a) say one looks up y[y[pcp->ppcomm + b] + a];

   the storage allocated for the data (3) to (6) changes at the
   beginning of each class (in subroutine setup), destroying the
   data (1) and (2);

   most storage allocation is checked via calls to is_space_exhausted */
