############################################################################
##
##  access.gd                    IRREDSOL                 Burkhard Hoefling
##
##  @(#)$Id: access.gd,v 1.3 2005/07/06 09:52:13 gap Exp $
##
##  Copyright (C) 2003-2005 by Burkhard Hoefling, 
##  Institut fuer Geometrie, Algebra und Diskrete Mathematik
##  Technische Universitaet Braunschweig, Germany
##


############################################################################
##
#V  IRREDSOL_DATA
##
##  Data structures for caching the groups and fingerprints in the library,
##  the actual data will be loaded when required.
##  
BindGlobal ("IRREDSOL_DATA", rec(
   GROUPS := [],                  # group descriptions
   GUARDIANS := [],               # guardian data, each group in the library 
                                  # is a subgroup of a guardian
   GROUPS_LOADED := [],           # indicates which groups have been loaded
   GAL_PERM := [],                # permutation of grops in the library
                                  # induced by a Galois automorphism
   MAX := [],                     # indices of maximal subgroups of the relevant GL
   GROUPS_DIM1 := [],             # group info for dimension 1
   FP := [],                      # fingerprints of groups
   FP_INDEX := [],                # fingerprint index
   FP_ELMS := [],                 # fingerprints of elements
   FP_LOADED := []                # indicates which fingerprint files have been loaded
));


############################################################################
##
#F  PermCanonicalIndexIrreducibleSolvableMatrixGroup(<n>, <q>, <d>, <k>)
##
##  computes a record with entries perm, pow, orb, and min where perm is a 
##  permutation, orb is the orbit of k under perm, min is the smallest
##  integer in orb, and <k>^(<pi>^<pow>=<min>, such that [<n>, <q>, <d>, <min>]
##  is a valid id for the group obtained by rewriting
##  AbsolutelyIrreducibleSolvableMatrixGroup (n/d, q^d, k) as a matrix group
##  over F_p^n. The result is meaningless if 
##  AbsolutelyIrreducibleSolvableMatrixGroup (n/d, q^d, k) does not exist
##
DeclareGlobalFunction ("PermCanonicalIndexIrreducibleSolvableMatrixGroup"); 


############################################################################
##
#F  IndicesIrreducibleSolvableMatrixGroups(<n>, <q>, <d>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("IndicesIrreducibleSolvableMatrixGroups");


############################################################################
##
#F  IrreducibleSolvableMatrixGroup(<n>, <q>, <d>, <k>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("IrreducibleSolvableMatrixGroup");

############################################################################
##
#F  IndicesMaximalAbsolutelyIrreducibleSolvableMatrixGroups(<n>, <q>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("IndicesMaximalAbsolutelyIrreducibleSolvableMatrixGroups");
   

############################################################################
##
#E
##
