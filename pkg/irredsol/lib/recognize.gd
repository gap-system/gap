############################################################################
##
##  recognize.gd                 IRREDSOL                  Burkhard Höfling
##
##  @(#)$Id: recognize.gd,v 1.5 2011/04/07 07:58:09 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#F  IsAvailableIdIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
DECLARE_IRREDSOL_FUNCTION ("IsAvailableIdIrreducibleSolvableMatrixGroup");


############################################################################
##
#F  IsAvailableIdAbsolutelyIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
DECLARE_IRREDSOL_FUNCTION ("IsAvailableIdAbsolutelyIrreducibleSolvableMatrixGroup");


############################################################################
##
#A  FingerprintMatrixGroup(<G>)
##
##  construct some data which is invariant under conjugation by an element
##  of the containing GL
##  
DeclareAttribute ("FingerprintMatrixGroup", IsMatrixGroup);
DECLARE_IRREDSOL_SYNONYMS ("FingerprintMatrixGroup");


############################################################################
##
#F  ConjugatingMatIrreducibleOrFail(G, H, F)
##
##  G and H must be irreducible matrix groups over the finite field F
##
##  computes a matrix x such that G^x = H or returns fail if no such x exists
##
DeclareGlobalFunction ("ConjugatingMatIrreducibleOrFail");


############################################################################
##
#F  ConjugatingMatImprimitiveOrFail(G, H, d, F)
##
##  G and H must be irreducible matrix groups over the finite field F
##  H must be block monomial with block dimension d
##
##  computes a matrix x such that G^x = H or returns fail if no such x exists
##
##  The function works best if d is small. Irreducibility is only requried 
##  if ConjugatingMatIrreducibleOrFail is used
##
DeclareGlobalFunction ("ConjugatingMatImprimitiveOrFail");


############################################################################
##
#F  RecognitionAISMatrixGroup(G, inds, wantmat, wantgroup)
##
##  version of RecognitionIrreducibleSolvableMatrixGroupNC which 
##  only works for absolutely irreducible groups G. This version
##  allows to prescribe a set of absolutely irreducible subgroups
##  to which G is compared. This set is described as a subset <inds> of 
##  IndicesAbsolutelyIrreducibleSolvableMatrixGroups (n, q), where n is the
##  degree of G and q is the order of the trace field of G. if inds is fail,
##  all groups in the IRREDSOL library are considered.
##
##  WARNING: The result may be wrong if G is not among the groups
##  described by <inds>.
##
DeclareGlobalFunction ("RecognitionAISMatrixGroup");


############################################################################
##
#F  RecognitionIrreducibleSolvableMatrixGroup(G, wantmat, wantgroup)
##
##  Let G be an irreducible solvable matrix group over a finite field. 
##  This function identifies a conjugate H of G group in the library. 
##
##  It returns a record which has the following entries:
##  id:                contains the id of H (and thus of G), 
##                     cf. IdIrreducibleSolvableMatrixGroup
##  mat: (optional)    a matrix x such that G^x = H
##  group: (optional)  the group H
##
##  The entries mat and group are only present if the booleans wantmat and/or
##  wantgroup are true, respectively.
##
##  Currently, wantmat may only be true if G is absolutely irreducible.
##
##  Note that in most cases, the function will be much slower if wantmat
##  is set to true.  
##
DECLARE_IRREDSOL_FUNCTION ("RecognitionIrreducibleSolvableMatrixGroup");


############################################################################
##
#F  RecognitionIrreducibleSolvableMatrixGroupNC(G, wantmat, wantgroup)
##
##  version of RecognitionIrreducibleSolvableMatrixGroup which does not check
##  its arguments and returns fail if G is not within the scope of the 
##  IRREDSOL library
##
DECLARE_IRREDSOL_FUNCTION ("RecognitionIrreducibleSolvableMatrixGroupNC");


############################################################################
##
#A  IdIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
DeclareAttribute ("IdIrreducibleSolvableMatrixGroup", IsMatrixGroup);
DECLARE_IRREDSOL_SYNONYMS ("IdIrreducibleSolvableMatrixGroup");

############################################################################
##
#F  IdIrreducibleSolvableMatrixGroupIndexMS(<n>, <p>, <k>)
##
##  see the IRREDSOL manual
##  
DECLARE_IRREDSOL_FUNCTION ("IdIrreducibleSolvableMatrixGroupIndexMS");


############################################################################
##
#F  IndexMSIdIrreducibleSolvableMatrixGroup(<n>, <q>, <d>, <k>)
##
##  see the IRREDSOL manual
##  
DECLARE_IRREDSOL_FUNCTION ("IndexMSIdIrreducibleSolvableMatrixGroup");


############################################################################
##
#E
##
