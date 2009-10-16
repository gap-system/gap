############################################################################
##
##  recognize.gd                 IRREDSOL                 Burkhard Hoefling
##
##  @(#)$Id: recognize.gd,v 1.4 2005/06/28 11:35:19 gap Exp $
##
##  Copyright (C) 2003-2005 by Burkhard Hoefling, 
##  Institut fuer Geometrie, Algebra und Diskrete Mathematik
##  Technische Universitaet Braunschweig, Germany
##


############################################################################
##
#F  IsAvailableIdIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("IsAvailableIdIrreducibleSolvableMatrixGroup");


############################################################################
##
#F  IsAvailableIdAbsolutelyIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("IsAvailableIdAbsolutelyIrreducibleSolvableMatrixGroup");


############################################################################
##
#A  FingerprintMatrixGroup(<G>)
##
##  construct some data which is invariant under conjugation by an element
##  of the containing GL
##  
DeclareAttribute ("FingerprintMatrixGroup", IsMatrixGroup);


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
DeclareGlobalFunction ("RecognitionIrreducibleSolvableMatrixGroup");


############################################################################
##
#F  RecognitionIrreducibleSolvableMatrixGroupNC(G, wantmat, wantgroup)
##
##  version of RecognitionIrreducibleSolvableMatrixGroup which does not check
##  its arguments and returns fail if G is not within the scope of the 
##  IRREDSOL library
##
DeclareGlobalFunction ("RecognitionIrreducibleSolvableMatrixGroupNC");


############################################################################
##
#A  IdIrreducibleSolvableMatrixGroup(<G>)
##
##  see the IRREDSOL manual
##  
DeclareAttribute ("IdIrreducibleSolvableMatrixGroup", IsMatrixGroup);


############################################################################
##
#F  IdIrreducibleSolvableMatrixGroupIndexMS(<n>, <p>, <k>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("IdIrreducibleSolvableMatrixGroupIndexMS");


############################################################################
##
#F  IndexMSIdIrreducibleSolvableMatrixGroup(<n>, <q>, <d>, <k>)
##
##  see the IRREDSOL manual
##  
DeclareGlobalFunction ("IndexMSIdIrreducibleSolvableMatrixGroup");


############################################################################
##
#E
##
