#############################################################################
##
#W  galois.gd                   GAP library                  Alexander Hulpke
##
##
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for the computation of Galois Groups.
##


#############################################################################
##
#V  InfoGalois
##
##  <ManSection>
##  <InfoClass Name="InfoGalois"/>
##
##  <Description>
##  is the info class for the Galois group recognition functions.
##  </Description>
##  </ManSection>
##
DeclareInfoClass("InfoGalois");

#############################################################################
##
#F  GaloisType(<f>[,<cand>])
##
##  <#GAPDoc Label="GaloisType">
##  <ManSection>
##  <Func Name="GaloisType" Arg='f[,cand]'/>
##
##  <Description>
##  Let <A>f</A> be an irreducible polynomial with rational coefficients. This
##  function returns the type of Gal(<A>f</A>) 
##  (considered as a transitive permutation group of the roots of <A>f</A>). It
##  returns a number <A>i</A> if Gal(<A>f</A>) is permutation isomorphic to
##  <C>TransitiveGroup(<A>n</A>,<A>i</A>)</C> where <A>n</A> is the degree of <A>f</A>.
##  <P/>
##  Identification is performed by factoring
##  appropriate Galois resolvents as proposed in <Cite Key="MS85"/>.  This function
##  is provided for rational polynomials of degree up to 15.  However, in some
##  cases the required calculations become unfeasibly large.
##  <P/>
##  For a few polynomials of degree 14, a complete discrimination is not yet
##  possible, as it would require computations, that are not feasible with
##  current factoring methods.
##  <P/>
##  This function requires the transitive groups library to be installed (see
##  <Ref Sect="Transitive Permutation Groups"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("GaloisType",IsRationalFunction);

#############################################################################
##
#F  ProbabilityShapes(<f>)
##
##  <#GAPDoc Label="ProbabilityShapes">
##  <ManSection>
##  <Func Name="ProbabilityShapes" Arg='f'/>
##
##  <Description>
##  Let <A>f</A> be an irreducible polynomial with rational coefficients. This
##  function returns a list of the most likely type(s) of Gal(<A>f</A>)
##  (see <Ref Func="GaloisType"/>), based
##  on factorization modulo a set of primes.
##  It is very fast, but the result is only probabilistic.
##  <P/>
##  This function requires the transitive groups library to be installed (see
##  <Ref Sect="Transitive Permutation Groups"/>).
##  <Example><![CDATA[
##  gap> f:=x^9-9*x^7+27*x^5-39*x^3+36*x-8;;
##  gap> GaloisType(f);
##  25
##  gap> TransitiveGroup(9,25);
##  [1/2.S(3)^3]3
##  gap> ProbabilityShapes(f);
##  [ 25 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("ProbabilityShapes");

DeclareGlobalFunction("SumRootsPol");
DeclareGlobalFunction("ProductRootsPol");
DeclareGlobalFunction("Tschirnhausen");
DeclareGlobalFunction("TwoSeqPol");
DeclareGlobalFunction("GaloisSetResolvent");
DeclareGlobalFunction("GaloisDiffResolvent");
DeclareGlobalFunction("ParityPol");


#############################################################################
##
#E

