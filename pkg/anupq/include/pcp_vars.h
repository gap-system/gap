/****************************************************************************
**
*A  pcp_vars.h                  ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pcp_vars.h,v 1.4 2001/06/15 14:39:21 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* definition file for structure used in computing 
   power-commutator presentation and for array y */

#ifndef __PCP_VARS__
#define __PCP_VARS__

#define MAXIDENT 100 

struct pcp_vars {

   int     p;			/* prime */
   int     pm1;			/* prime - 1 */
    
   int     m;                   /* number of automorphisms */

   int     cc;			/* current class */
   int     ccbeg;		/* begin current class */
   int     clend;		/* end current class */

   int     newgen;		/* number of generators of nucleus */
   int     multiplicator_rank;  /* rank of multiplicator */
   int     lastg;		/* last generator of group */
   int     first_pseudo;	/* first pseudo-generator */
   int     redgen;              /* redundant generator */

   int     fronty;		/* first storage position available in y */
   int     dgen;		/* storage location for generators */
   int     relp;		/* storage location for relations */
   int     lused;		/* last position used in y from front */
   int     gspace;		/* first garbage location available in y */
   int     words;		/* storage position of words in y */
   int     submlg;		/* position subgrp - lastg */
   int     subgrp;		/* storage position of subgroup information */
   int     structure;		/* storage position of structure information */
   int     ppower;		/* base position for power information */
   int     ppcomm;		/* base position for pointers to commutators */
   int     backy;		/* last storage place available in y */

   int     extra_relations;	/* indicate whether exponent law is imposed */
   int     start_wt;		/* start weight for exponent checking */
   int     end_wt;		/* end weight for exponent checking */

   int     ndgen;		/* number of defining generators */
   int     ndrel;		/* number of defining relations */
   int     ncomm;		/* number of commutators */
   int     nwords;		/* number of words */
   int     nsubgp;		/* number of subgroups */

   int     nocset;		/* number of occurrences parameter */
   int     complete;		/* is the group complete? */
   int     ncset;		/* is next class set up? */

   char    ident[MAXIDENT];	/* identifier of group */ 

   Logical middle_of_tails;     /* middle of tails calculation? */
   Logical update;              /* update of generators performed? */
   Logical dummy1;              /* dummy variables which can be used later */
   Logical dummy2;
   Logical dummy3;

   Logical metabelian;          /* is the group metabelian? */
   Logical fullop;		/* indicate nature of output */
   Logical diagn;		/* indicate nature of output */
   Logical eliminate_flag;	/* indicate that generator is eliminated */
   Logical valid;		/* indicate that input is valid */
   Logical overflow;		/* indicate integer or space overflow */
   Logical multiplicator;	/* p-multiplicator is to be computed */
   Logical cover;		/* p-covering group is to be computed */

#if defined (LIE) 
#define NRELS 3                    /* number of multilinear relations */
   int     mlin_relations[NRELS];  /* array storing degree of multilinear
                                      conditions to be imposed */
#endif

   /* variables that Magma needs */
#ifdef Magma
   t_handle group;		/* the group fed in at the top */
   t_handle y_handle;		/* handle to the work space */
   t_int output_level;		/* the actual output level */
   t_int group_type;            /* type of the group */
#endif

};

#ifndef Magma
int     *y_address;     /* definition of storage for presentation */
#endif

#endif
