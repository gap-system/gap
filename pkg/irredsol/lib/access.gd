############################################################################
##
##  access.gd                      IRREDSOL                 Burkhard Höfling
##
##  @(#)$Id: access.gd,v 1.5 2011/05/18 16:25:44 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#V  IRREDSOL_DATA
##
##  Data structures for caching the groups and fingerprints in the library,
##  the actual data will be loaded when required.
##  
BindGlobal ("IRREDSOL_DATA", rec(
    GROUPS := [],             # group descriptions
    GUARDIANS := [],          # guardian data, each group in the library 
                              # is a subgroup of a guardian
    GROUPS_LOADED := [],      # indicates which groups have been loaded
    GAL_PERM := [],           # permutation of grops in the library
                              # induced by the Frobenius automorphism
    MAX := [],                # indices of maximal subgroups of the relevant GL
    GROUPS_DIM1 := [],        # group info for dimension 1
    PRIM_GUARDIANS := [],     # primitive groups corresponding to guardians,
                              # each primitive pc group in the library will be a subgroup 
                              # of this guardian
    FP := [],                 # fingerprints of groups
    FP_INDEX := [],           # fingerprint index
    FP_ELMS := [],            # fingerprints of elements
    FP_LOADED := []           # indicates which fingerprint files have been loaded
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
DECLARE_IRREDSOL_FUNCTION ("PermCanonicalIndexIrreducibleSolvableMatrixGroup"); 


############################################################################
##
#F  IndicesIrreducibleSolvableMatrixGroups(<n>, <q>, <d>)
##
##  see the IRREDSOL manual
##  
DECLARE_IRREDSOL_FUNCTION ("IndicesIrreducibleSolvableMatrixGroups");


############################################################################
##
#F  IrreducibleSolvableMatrixGroup(<n>, <q>, <d>, <k>)
##
##  see the IRREDSOL manual
##  
DECLARE_IRREDSOL_FUNCTION ("IrreducibleSolvableMatrixGroup");
  

############################################################################
##
#F  IndicesMaximalAbsolutelyIrreducibleSolvableMatrixGroups(<n>, <q>)
##
##  see the IRREDSOL manual
##  
DECLARE_IRREDSOL_FUNCTION ("IndicesMaximalAbsolutelyIrreducibleSolvableMatrixGroups");


############################################################################
##
#E
##
