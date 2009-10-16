/****************************************************************************
**
*A  pga_vars.h                  ANUPQ source                   Eamonn O'Brien
**
*A  @(#)$Id: pga_vars.h,v 1.4 2003/12/01 11:08:28 werner Exp $
**
*Y  Copyright 1995-2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
*Y  Copyright 1995-2001,  School of Mathematical Sciences, ANU,     Australia
**
*/

/* definition file for structure used in p-group generation */

#ifndef __PGA_VARS__
#define __PGA_VARS__

struct pga_vars {
   int     p;			/* prime */

   int     ndgen;               /* rank of Frattini quotient */

   int     multiplicator_rank;  /* rank of p-multiplicator */
   int     nuclear_rank;	/* rank of nucleus */
   int     step_size;		/* step size */

   /* values of the above parameters relative to 
      chosen characteristic subgroup */
   int     q;   
   int     r;    
   int     s;    

   Logical final_stage;		/* indicates whether in intermediate stage */
   Logical capable;		/* indicates whether group is capable */

   int    fixed;		/* number of generators of the p-multiplicator
				   which cannot be eliminated */

   int     m;			/* number of automorphisms */
   int     nmr_centrals;	/* number of central automorphisms */
   int     nmr_stabilisers;	/* number of generators for stabiliser */
   int     Degree;		/* degree of permutation group */
   int    *powers;		/* store powers of prime */
   int    *inverse_modp;	/* store inverses of 0 .. p - 1 */
   int    *list;		/* list of definition sets */
   int    *available;		/* number of available positions for each set */
   int    *offset;		/* offset for each definition set */
   int    nmr_def_sets;		/* number of definition sets */
   int    nmr_subgroups;	/* number of subgroups processed */

   int    *rep;                 /* list of orbit representatives */
   int    nmr_orbits;           /* number of orbits */
   int    nmr_of_descendants;   /* number of immediate descendants */
   int    nmr_of_capables;      /* number of capable immediate descendants */

   int    *relative;
   int    nmr_soluble;

   int    *map;                 /* map from automorphisms to permutations */
   int    nmr_of_perms;         /* number of permutations */

   /* series of print flags */

   Logical print_extensions;
   Logical print_automorphism_matrix;

   Logical print_degree;
   Logical print_permutation;

   Logical print_subgroup;
   Logical print_reduced_cover;
   Logical print_group;
   Logical print_nuclear_rank;
   Logical print_multiplicator_rank;

   Logical print_orbits;
   Logical print_orbit_summary;
   Logical print_orbit_arrays;

   Logical print_commutator_matrix;
   Logical print_automorphisms;
   Logical print_automorphism_order;
   Logical print_stabiliser_array;

   Logical trace;               /* trace details of algorithm */

   /* algorithm flags */
   Logical space_efficient; 
   Logical soluble;
   Logical combined;
   Logical terminal;        /* completely process terminal descendants */
   Logical metabelian;      /* ensure descendant is metabelian */

   int exponent_law;        /* ensure descendant satisfies exponent law */

   int orbit_size;          /* total orbit size in constructing group */

   Logical dummy1;          /* dummy variables */ 
   Logical dummy2;   

   Logical upper_bound;     /* only automorphism group order upper 
                               bound stored */

#ifdef LARGE_INT 
   MP_INT aut_order;        /* order of automorphism group */
#endif 
};

#endif
