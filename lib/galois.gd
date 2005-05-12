#############################################################################
##
#A  galois.gd                   GAP library                  Alexander Hulpke
##
#A  @(#)$Id$
##
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for the computation of Galois Groups.
Revision.galois_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  InfoGalois
##
##  is the info class for the Galois group recognition functions.
DeclareInfoClass("InfoGalois");

#############################################################################
##
#F  GaloisType(<f>[,<cand>])
##
##  Let <f> be an irreducible polynomial with rational coefficients. This
##  function returns the type of Gal(<f>) 
##  (considered as a transitive permutation group of the roots of <f>). It
##  returns a number <i> if Gal(<f>) is permutation isomorphic to
##  `TransitiveGroup(<n>,<i>)' where <n> is the degree of <f>.
##
##  Identification is performed by factoring
##  appropriate Galois resolvents as proposed in \cite{MS85}.  This function
##  is provided for rational polynomials of degree up to 15.  However, in some
##  cases the required calculations become unfeasibly large.
##
##  For a few polynomials of degree 14, a complete discrimination is not yet
##  possible, as it would require computations, that are not feasible with
##  current factoring methods.
##
##  This function requires the transitive groups library to be installed (see
##  "Transitive Permutation Groups").
##
DeclareAttribute("GaloisType",IsRationalFunction);

#############################################################################
##
#F  ProbabilityShapes(<f>)
##
##  Let <f> be an irreducible polynomial with rational coefficients. This
##  function returns a list of the most likely type(s) of Gal(<f>)
##  (see~`GaloisType' -- "GaloisType"), based
##  on factorization modulo a set of primes.
##  It is very fast, but the result is only probabilistic.
##
##  This function requires the transitive groups library to be installed (see
##  "Transitive Permutation Groups").
##
DeclareGlobalFunction("ProbabilityShapes");

DeclareGlobalFunction("SumRootsPol");
DeclareGlobalFunction("ProductRootsPol");
DeclareGlobalFunction("Tschirnhausen");
DeclareGlobalFunction("TwoSeqPol");
DeclareGlobalFunction("GaloisSetResolvent");
DeclareGlobalFunction("GaloisDiffResolvent");
DeclareGlobalFunction("ParityPol");

