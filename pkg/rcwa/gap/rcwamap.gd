#############################################################################
##
#W  rcwamap.gd                GAP4 Package `RCWA'                 Stefan Kohl
##
##  This file contains declarations of functions, operations etc. for
##  computing with rcwa mappings.
##
##  Let R be an infinite euclidean ring which is not a field and all of whose
##  proper residue class rings are finite.
##      We call a mapping f: R -> R *residue-class-wise affine*, or for short
##  an *rcwa* mapping,  if there is a nonzero m in R such that f is affine on
##  residue classes (mod m).
##      This means that for any residue class r(m) in R/mR there are  coeffi-
##  cients a_r(m), b_r(m), c_r(m) in R  such that the restriction of f to the
##  set r(m) = { r + km | k in R } is given by
##
##                                a_r(m) * n + b_r(m)
##                      n  |-->   -------------------
##                                       c_r(m)      .
##
##  We always assume that  c_r(m) is normalized to a certain  "standard asso-
##  ciate"  (e.g. for R = Z this means that  c_r(m) > 0),  that all fractions
##  are reduced,  i.e. that gcd( a_r(m), b_r(m), c_r(m) ) = 1,  and that m is
##  chosen multiplicatively minimal.
##      Apart from the restrictions  imposed by the condition that  the image
##  of any residue class r(m) under f must be a subset of R and that one can-
##  not divide by 0,  the coefficients  a_r(m), b_r(m) and c_r(m)  can be any
##  ring elements.
##      We call m the  *modulus* of f.  By *products* of rcwa mappings we al-
##  ways mean their compositions as mappings,  and by the *inverse* of  a bi-
##  jective rcwa mapping we mean its inverse mapping.
##      The set Rcwa(R) of all rcwa mappings of R forms a monoid under multi-
##  plication.  We call a submonoid of Rcwa(R)  a *residue-class-wise affine*
##  monoid, or for short an *rcwa* monoid.
##      The set RCWA(R)  :=  { g in Sym(R) | g is residue-class-wise affine }
##  is closed under multiplication and taking inverses  (this can be verified
##  easily), hence forms a subgroup of Sym(R).  We call a subgroup of RCWA(R)
##  a *residue-class-wise affine* group, or for short an *rcwa* group.
##      While computing with infinite permutation groups in general is a very
##  difficult task, the rcwa groups form a class of groups which are accessi-
##  ble to computations.
##
##  An rcwa mapping object stores the following data:
##
##  - Underlying Ring: The source and range R of the mapping,  hence its "un-
##                     derlying ring",  is stored as the  `UnderlyingRing' of
##                     the family  the rcwa mapping object belongs to.  It is
##                     also available as the value of the attribute `Source'.
##
##  - Modulus:         The modulus m is stored  as a component  <modulus>  in
##                     any rcwa mapping object. 
##
##  - Coefficients:    The coefficient list is stored as a component <coeffs>
##                     in any rcwa mapping object.  The component <coeffs> is
##                     a list of  |R/mR| lists of three elements of R,  each,
##                     giving the coefficients a_r(m), b_r(m) and c_r(m)  for
##                     r(m) running through all residue classes (mod m).
##                         The ordering  of these triples  is defined  by the
##                     ordering  of the residues  r mod m  in the sorted list
##                     `AllResidues( <R>, <m> )'.
##
##  It is always taken care that the entries of the stored  coefficient trip-
##  les of an rcwa mapping are coprime,  that the third entry of any  coeffi-
##  cient triple equals its standard conjugate  and that the number of stored
##  coefficient triples equals the number of residue classes modulo the modu-
##  lus of the mapping.  Given this,  an rcwa mapping determines its internal
##  representation uniquely.  Thus testing rcwa mappings for equality is very
##  cheap.  The reduction of coefficient lists mentioned above  prevents also
##  unnecessary coefficient explosion.
##
##  We use the notation for the modulus and the coefficients  of an rcwa map-
##  ping introduced above throughout this file.
##
##  Algorithms and methods for computing with  rcwa mappings  and -groups are
##  described in the author's article
##
##  Algorithms for a Class of Infinite Permutation Groups.
##  J. Symb. Comput. 43(2008), no. 8, 545-581, DOI: 10.1016/j.jsc.2007.12.001
##
#############################################################################

#############################################################################
##
#V  InfoRCWA . . . . . . . . . . . . . . . . . .  info class for RCWA package
#F  RCWAInfo . . . . . . . . . . . . . . . . . . set info level of `RcwaInfo'
##
##  This is the Info class of the RCWA package.
##
##  For convenience: `RCWAInfo( <n> )' is a shorthand for
##  `SetInfoLevel( RcwaInfo, <n> )'.
##
##  See Section "Info Functions" in the GAP Reference Manual for
##  a description of the Info mechanism.
##
DeclareInfoClass( "InfoRCWA" );
DeclareGlobalFunction( "RCWAInfo" );

#############################################################################
##
#S  Rcwa mappings: Definitions. /////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#C  IsRcwaMapping . . . . . . . . . . . . . . . . . . . . . all rcwa mappings
#C  IsRcwaMonoid  . . . . . . . . . . . . . . . . . . . . .  all rcwa monoids
#C  IsRcwaGroup . . . . . . . . . . . . . . . . . . . . . . . all rcwa groups
##
##  The category of all rcwa mappings / -monoids / -groups.
##
DeclareCategory( "IsRcwaMapping", IsRingElement );
DeclareSynonym( "IsRcwaMonoid",
                 CategoryCollections(IsRcwaMapping) and IsMonoid );
DeclareSynonym( "IsRcwaGroup",
                 CategoryCollections(IsRcwaMapping) and IsGroup );

#############################################################################
##
#C  IsRcwaMappingOfZ  . . . . . . . . . . . . . . . . . .  rcwa mappings of Z
#C  IsRcwaMappingOfZxZ  . . . . . . . . . . . . . . . .  rcwa mappings of Z^2
#C  IsRcwaMappingOfZ_pi . . . . . . . . . . . . . . . rcwa mappings of Z_(pi)
#C  IsRcwaMappingOfGFqx . . . . . . . . . . . . . . rcwa mappings of GF(q)[x]
#C  IsRcwaMappingOfZOrZ_pi  . . . . . . . . . .  rcwa mappings of Z or Z_(pi)
##
##  The category of all rcwa mappings of the ring Z of integers, of Z^2, of
##  (semi-) localizations of Z or of polynomial rings in one variable over a
##  finite field, respectively. The category `IsRcwaMappingOfZOrZ_pi' is the
##  union of the categories `IsRcwaMappingOfZ' and `IsRcwaMappingOfZ_pi'.
##
DeclareCategory( "IsRcwaMappingOfZ", IsRingElement );
DeclareCategory( "IsRcwaMappingOfZxZ", IsRingElement );
DeclareCategory( "IsRcwaMappingOfZ_pi", IsRingElement );
DeclareCategory( "IsRcwaMappingOfGFqx", IsRingElement );
DeclareCategory( "IsRcwaMappingOfZOrZ_pi", IsRingElement );

#############################################################################
##
#F  RcwaMappingsFamily( <R> ) . . . . family of rcwa mappings of the ring <R>
#F  RcwaMappingsOfZ_piFamily( <pi> )   "          "        of the ring Z_(pi)
#F  RcwaMappingsOfGFqxFamily( <R> )    "          "  of the ring R = GF(q)[x]
##
DeclareGlobalFunction( "RcwaMappingsFamily" );
DeclareGlobalFunction( "RcwaMappingsOfZ_piFamily" );
DeclareGlobalFunction( "RcwaMappingsOfGFqxFamily" );

#############################################################################
##
#R  IsRcwaMappingStandardRep . . . "standard" representation of rcwa mappings
##
##  This is the representation of rcwa mappings by modulus <modulus>
##  (in the following denoted by m (ring element) or L (lattice in Z^2),
##  respectively) and coefficient list <coeffs>.
##
##  Rcwa mappings of Z, Z_pi or GF(q)[x]:
##
##  The component <coeffs> is a list of |R/mR| lists of three coprime ele-
##  ments of the underlying ring R, each, containing the coefficients a_r(m),
##  b_r(m) and c_r(m) for r(m) running through all residue classes (mod m).
##
##  The ordering of these triples is defined by the ordering of the residues
##  r mod m in the sorted list returned by `AllResidues( <R>, <m> )'.
##
##  Rcwa mappings of Z^2:
##
##  The matrix L whose rows span the lattice is always stored in Hermite
##  normal form.
##
##  The component <coeffs> is a list of det(L) coefficient triples
##  ( a_r(m), b_r(m), c_r(m) ), each consisting of
##
##   - an invertible 2x2 matrix a_r(m) with integer entries,
##
##   - a vector b_r(m) in Z^2, and
##
##   - a positive integer c_r(m),
##
##  for r(m) running through all residue classes r(m) in Z^2/L.
##
##  The ordering of these triples is defined by the ordering of the residues
##  in the sorted list returned by `AllResidues( Integers^2, <L> )'.
##
DeclareRepresentation( "IsRcwaMappingStandardRep",
                       IsComponentObjectRep and IsAttributeStoringRep,
                       [ "modulus", "coeffs" ] );

#############################################################################
##
##                                            Construction of an rcwa mapping
##
#M  RcwaMapping  ( <R>, <m>, <coeffs> ) . . by ring, modulus and coefficients
#M  RcwaMappingNC( <R>, <m>, <coeffs> )
#M  RcwaMapping  ( <R>, <coeffs> )  . . . . . . . .  by ring and coefficients
#M  RcwaMappingNC( <R>, <coeffs> )
#M  RcwaMapping  ( <coeffs> ) . . . . . . . . . . . . . . . . by coefficients
#M  RcwaMappingNC( <coeffs> )
#M  RcwaMapping  ( <perm>, <range> )  . . . . . . .  by permutation and range
#M  RcwaMappingNC( <perm>, <range> )
#M  RcwaMapping  ( <m>, <values> )  . . . . . . . . . . by modulus and values
#M  RcwaMappingNC( <m>, <values> )
#M  RcwaMapping  ( <pi>, <coeffs> )  by noninvertible primes and coefficients
#M  RcwaMappingNC( <pi>, <coeffs> )
#M  RcwaMapping  ( <q>, <m>, <coeffs> ) .  by field size, modulus and coeff's
#M  RcwaMappingNC( <q>, <m>, <coeffs> )
#M  RcwaMapping  ( P1, P2 ) . . . . . . . . . . . . . by two class partitions
#M  RcwaMappingNC( P1, P2 )
#M  RcwaMapping  ( <cycles> ) . . . . . . . . . . . . . . . . by class cycles
#M  RcwaMappingNC( <cycles> )
##
##  Construction of the rcwa mapping 
##
##  (a) of <R> with modulus <m> and coefficients <coeffs>, resp.
##
##  (b) of <R> = Z or <R> = Z_(pi) with modulus Length( <coeffs> )
##      and coefficients <coeffs>, resp.
##
##  (c) of R = Z with modulus Length( <coeffs> ) and coefficients
##      <coeffs>, resp.
##
##  (d) of R = Z, acting on any set <range> + k * Length(<range>) like the
##      permutation <perm> on <range>, resp.
##
##  (e) of R = Z with modulus <m> and values given by a list <values> of
##      2 pairs [preimage,image] per residue class (mod <m>), resp.
##
##  (f) of R = Z_(pi) with with modulus Length( <coeffs> ) and coefficients
##      <coeffs>, resp.
##
##  (g) of GF(q)[x] with modulus <m> and coefficients <coeffs>, resp.
##
##  (h) a bijective rcwa mapping which induces a bijection between the
##      partitions <P1> and <P2> of R into residue classes and which is
##      affine on the elements of <P1>, resp.
##
##  (i) a bijective rcwa mapping with "residue  class cycles" as given by
##      <cycles>.  The latter is a list of lists of pairwise disjoint residue
##      classes which the mapping should permute cyclically, each.
##
##  The difference between `RcwaMapping' and `RcwaMappingNC' is that the
##  former performs some argument checks which are omitted in the latter,
##  where just anything may happen if wrong or inconsistent arguments
##  are given.
##
DeclareOperation( "RcwaMapping", [ IsObject ] );
DeclareOperation( "RcwaMapping", [ IsObject, IsObject ] );
DeclareOperation( "RcwaMapping", [ IsObject, IsObject, IsObject ] );
DeclareOperation( "RcwaMappingNC", [ IsObject ] );
DeclareOperation( "RcwaMappingNC", [ IsObject, IsObject ] );
DeclareOperation( "RcwaMappingNC", [ IsObject, IsObject, IsObject ] );

#############################################################################
##
#F  LocalizedRcwaMapping( <f>, <p> )
#F  SemilocalizedRcwaMapping( <f>, <pi> )
##
##  These functions return the rcwa mapping of Z_(p) resp. Z_(pi) with the
##  same coefficients as <f>.
##
DeclareGlobalFunction( "LocalizedRcwaMapping" );
DeclareGlobalFunction( "SemilocalizedRcwaMapping" );

#############################################################################
##
#A  ProjectionsToCoordinates( <f> )
##
##  Projections of an rcwa mapping of Z^2 to the coordinates.
##
DeclareAttribute( "ProjectionsToCoordinates", IsRcwaMappingOfZxZ );

#############################################################################
##
#O  Modulus( <f> ) . . . . . . . . . . .  the modulus of the rcwa mapping <f>
#O  Modulus( <M> ) . . . . . . . . . . .  the modulus of the rcwa monoid <M>
##
##  See also the attribute `ModulusOfRcwaMonoid'.
##
DeclareOperation( "Modulus", [ IsRcwaMapping ] );
DeclareOperation( "Modulus", [ IsRcwaMonoid ] );

#############################################################################
##
#O  Coefficients( <f> ) . . . . . .  the coefficients of the rcwa mapping <f>
##
DeclareOperation( "Coefficients", [ IsRcwaMapping ] );

#############################################################################
##
#A  UnderlyingField( <f> ) . . . . . . coefficient field of the source of <f>
##
DeclareAttribute( "UnderlyingField", IsRcwaMappingOfGFqx );

#############################################################################
##
#V  ZeroRcwaMappingOfZ . . . . . . . . . . . . . . . . zero rcwa mapping of Z
#V  ZeroRcwaMappingOfZxZ . . . . . . . . . . . . . . zero rcwa mapping of Z^2
#V  IdentityRcwaMappingOfZ . . . . . . . . . . . . identity rcwa mapping of Z
#V  IdentityRcwaMappingOfZxZ . . . . . . . . . . identity rcwa mapping of Z^2
##
DeclareGlobalVariable( "ZeroRcwaMappingOfZ" );
DeclareGlobalVariable( "ZeroRcwaMappingOfZxZ" );
DeclareGlobalVariable( "IdentityRcwaMappingOfZ" );
DeclareGlobalVariable( "IdentityRcwaMappingOfZxZ" );

#############################################################################
##
#S  Special types of rcwa permutations. /////////////////////////////////////
##
#############################################################################

#############################################################################
##
#F  ClassShift( <R>, <r>, <m> ) . . . . . . . . . . . . . class shift nu_r(m)
#F  ClassShift( <r>, <m> )  . . . . . . . . . . . . . . . . . . . . .  (dito)
#F  ClassShift( <R>, <cl> ) . . . . . .  class shift nu_r(m), where cl = r(m)
#F  ClassShift( <cl> )  . . . . . . . . . . . . . . . . . . . . . . .  (dito)
#F  ClassShift( <R> ) . . . . . . . . . . . . .  class shift nu_R: n -> n + 1
#F  ClassShiftOfZxZ( ... )  . . . . . . . . . . . . . . .  class shift of Z^2
#P  IsClassShift( <sigma> )
#P  IsPowerOfClassShift( <sigma> )
##
##  Returns the class shift nu_r(m).
##
##  The *class shift* nu_r(m) is the rcwa permutation which maps n in r(m)
##  to n + m and which fixes the complement of the residue class r(m)
##  pointwise.
##
##  Enclosing the argument list in list brackets is permitted.
##
DeclareGlobalFunction( "ClassShift" );
DeclareGlobalFunction( "ClassShiftOfZxZ" );
DeclareProperty( "IsClassShift", IsRcwaMapping );
DeclareProperty( "IsPowerOfClassShift", IsRcwaMapping );

#############################################################################
##
#F  ClassReflection( <R>, <r>, <m> )  . . . .  class reflection varsigma_r(m)
#F  ClassReflection( <r>, <m> ) . . . . . . . . . . . . . . . . . . .  (dito)
#F  ClassReflection( <R>, <cl> )  . class reflection varsigma_r(m), cl = r(m)
#F  ClassReflection( <cl> ) . . . . . . . . . . . . . . . . . . . . .  (dito)
#F  ClassReflection( <R> )  . . . . . .  class reflection varsigma_R: n -> -n
#P  IsClassReflection( <sigma> )
##
##  Returns the class reflection varsigma_r(m).
##
##  The *class reflection* varsigma_r(m) is the rcwa permutation which maps
##  n in r(m) to -n + 2r and which fixes the complement of the residue class
##  r(m) pointwise, where it is understood that 0 <= r < m in the ordering
##  used by GAP.
##
##  Enclosing the argument list in list brackets is permitted.
##
DeclareGlobalFunction( "ClassReflection" );
DeclareProperty( "IsClassReflection", IsRcwaMapping );

#############################################################################
##
#F  ClassRotation( <R>, <r>, <m>, <u> ) . . . . . class rotation rho_(r(m),u)
#F  ClassRotation( <r>, <m>, <u> )  . . . . . . . . . . . . . . . . .  (dito)
#F  ClassRotation( <R>, <cl>, <u> ) .  class rotation rho_(r(m),u), cl = r(m)
#F  ClassRotation( <cl>, <u> )  . . . . . . . . . . . . . . . . . . .  (dito)
#F  ClassRotation( <R>, <u> ) . . . . . . . class rotation rho_(R,u): n -> un
#F  ClassRotationOfZxZ( ... ) . . . . . . . . . . . . . class rotation of Z^2
#P  IsClassRotation( <sigma> )
##
##  Returns the class rotation rho_(r(m),u).
##
##  The *class rotation* rho_(r(m),u) is the rcwa permutation which maps
##  n in r(m) to un + r(1-u) and which fixes the complement of the residue
##  class r(m) pointwise, where it is understood that 0 <= r < m in the
##  ordering used by GAP. Class rotations generalize class reflections --
##  we have varsigma_r(m) = rho_(r(m),-1).
##
##  Enclosing the argument list in list brackets is permitted.
##
DeclareGlobalFunction( "ClassRotation" );
DeclareGlobalFunction( "ClassRotationOfZxZ" );
DeclareProperty( "IsClassRotation", IsRcwaMapping );
DeclareAttribute( "RotationFactor", IsRcwaMapping );

#############################################################################
##
#F  ClassTransposition( <R>, <r1>, <m1>, <r2>, <m2> ) . . class transposition
#F  ClassTransposition( <r1>, <m1>, <r2>, <m2> )            tau_r1(m1),r2(m2)
#F  ClassTransposition( <R>, <cl1>, <cl2> ) . . . dito, cl1=r1(m1) cl2=r2(m2)
#F  ClassTransposition( <cl1>, <cl2> )  . . . . . . . . . . . . . . .  (dito)
#F  ClassTranspositionOfZxZ( ... ) . . . . . . . . class transposition of Z^2
#F  GeneralizedClassTransposition( ... )  . .  allows ri < 0, ri > mi, mi < 0
#P  IsClassTransposition( <sigma> )
#P  IsGeneralizedClassTransposition( <sigma> )
#A  TransposedClasses( <ct> )
##
##  Returns the class transposition tau_(r1(m1),r2(m2)).
##
##  Given two disjoint residue classes r1(m1) and r2(m2) of the base ring R,
##  the *class transposition* tau_(r1(m1),r2(m2)) in RCWA(R) is defined by
##
##                     /
##                    | (m2*n + m1*r2 - m2*r1)/m1 if n in r1(m1),
##         n  |--->  <  (m1*n + m2*r1 - m1*r2)/m2 if n in r2(m2),
##                    | otherwise,
##                     \
##
##  where it is understood that 0 <= r1 < m1 and 0 <= r2 < m2 in the ordering
##  used by GAP. The class transposition tau_(r1(m1),r2(m2)) is an involution
##  which interchanges the residue classes r1(m1) and r2(m2) and which fixes
##  the complement of their union pointwise.
##
##  Enclosing the argument list in list brackets is permitted.
##
DeclareGlobalFunction( "ClassTransposition" );
DeclareGlobalFunction( "ClassTranspositionOfZxZ" );
DeclareSynonym( "GeneralizedClassTransposition", ClassTransposition );
DeclareProperty( "IsClassTransposition", IsRcwaMapping );
DeclareProperty( "IsGeneralizedClassTransposition", IsRcwaMapping );
DeclareAttribute( "TransposedClasses", IsRcwaMapping );

#############################################################################
##
#O  SplittedClassTransposition( <ct>, <k>, <cross> )
##
##  Returns a decomposition of the class transposition <ct> into a product
##  of <k> class transpositions.
##
##  Class transpositions can be written as products of any given number <k>
##  of class transpositions, as long as the underlying ring has a residue
##  class ring of cardinality <k>.
##
DeclareOperation( "SplittedClassTransposition",
                  [ IsRcwaMapping and IsClassTransposition, IsObject ] );
DeclareOperation( "SplittedClassTransposition",
                  [ IsRcwaMapping and IsClassTransposition,
                    IsObject, IsBool ] );

#############################################################################
##
#F  ClassPairs( <m> )
#F  ClassPairs( <R>, <m> )
#F  NumberClassPairs( <m> )
#F  NrClassPairs( <m> )
#V  CLASS_PAIRS
#V  CLASS_PAIRS_LARGE
##
##  In its one-argument form, the function `ClassPairs' returns a list of
##  4-tuples (r1,m1,r2,m2) of integers corresponding to the unordered pairs
##  of disjoint residue classes r1(m1) and r2(m2) with m1, m2 <= <m>.
##  In its two-argument form, it does basically "the same" for the ring <R>.
##
##  The function `NumberClassPairs' returns the number of unordered pairs of
##  disjoint residue classes r1(m1) and r2(m2) with m1, m2 <= <m>.
##  While this is just Length(ClassPairs(m)), `NumberClassPairs' computes
##  this number much faster, and without generating a list of all tuples.
##  `NrClassPairs' is a synonym for `NumberClassPairs'.
##
##  The variables `CLASS_PAIRS' and `CLASS_PAIRS_LARGE' are used to cache
##  lists computed by `ClassPairs'. These caches are mainly used to generate
##  random class transpositions.
##
DeclareGlobalFunction( "ClassPairs" );
DeclareGlobalFunction( "NumberClassPairs" );
DeclareSynonym( "NrClassPairs", NumberClassPairs );
DeclareGlobalVariable( "CLASS_PAIRS" );
DeclareGlobalVariable( "CLASS_PAIRS_LARGE" );

#############################################################################
##
#F  PrimeSwitch( <p> ) . . product of ct's, with multiplier <p> and divisor 2
#F  PrimeSwitch( <p>, <k> )
#P  IsPrimeSwitch( <sigma> )
##
##  Returns the prime switch sigma_p.
##
##  For an odd prime p, the *prime switch* sigma_p is defined by the product
##    tau_(0(8), 1(2p)) * tau_(4(8),-1(2p)) * tau_(0(4),    1(2p))
##  * tau_(2(4),-1(2p)) * tau_(2(2p),1(4p)) * tau_(4(2p),2p+1(4p))
##  of 6 class transpositions.
##
##  The prime switch sigma_p is a bijective rcwa mapping of Z with
##  modulus 4p, multiplier p and divisor 2.
##
DeclareGlobalFunction( "PrimeSwitch" );
DeclareProperty( "IsPrimeSwitch", IsRcwaMapping );

#############################################################################
##
#F  mKnot( <m> ) . . . . . . . . . . rcwa mapping of Timothy P. Keller's type
##
##  Given an odd integer <m>, this function returns the bijective rcwa
##  mapping g_<m> as defined in
##
##  Timothy P. Keller. Finite Cycles of Certain Periodically Linear
##  Permutations. Missouri J. Math. Sci. 11(1999), no. 3, 152-157.
##
DeclareGlobalFunction( "mKnot" );

#############################################################################
##
#F  ClassUnionShift( <S> ) . . shift of residue class union <S> by Mod( <S> )
##
##  Returns the rcwa mapping which maps <S> to <S> + Modulus(<S>) and which
##  fixes the complement of <S> pointwise.
##
DeclareGlobalFunction( "ClassUnionShift" );

#############################################################################
##
#A  FactorizationIntoCSCRCT( <g> )
#A  FactorizationIntoElementaryCSCRCT( <g> )
##
##  A factorization of an rcwa permutation into class shifts,
##  class reflections and class transpositions. The latter operation
##  decomposes into factors with particularly small moduli -- for
##  elements of CT_P(Z), where P is some finite set of odd primes,
##  the factors are taken from a finite set of generators.
##
DeclareAttribute( "FactorizationIntoCSCRCT", IsMultiplicativeElement );
DeclareAttribute( "FactorizationIntoElementaryCSCRCT",
                  IsMultiplicativeElement );
DeclareSynonym( "FactorizationIntoGenerators", FactorizationIntoCSCRCT );

#############################################################################
##
#S  Attributes and properties derived from the coefficients. ////////////////
##
#############################################################################

#############################################################################
##
#A  Multiplier( <f> ) . . . . . . . .  the multiplier of the rcwa mapping <f>
#A  Multiplier( <M> ) . . . . . . . . . the multiplier of the rcwa monoid <M>
#A  Divisor( <f> )  . . . . . . . . . . . the divisor of the rcwa mapping <f>
#A  Divisor( <M> )  . . . . . . . . . . .  the divisor of the rcwa monoid <M>
#A  PrimeSet( <f> ) . . . . . . . . . . the prime set of the rcwa mapping <f>
#A  PrimeSet( <M> ) . . . . . . . . . .  the prime set of the rcwa monoid <M>
#A  MaximalShift( <f> ) . . . .  maximum of the absolute values of the b_r(m)
#P  IsBalanced( <f> ) . .  indicates whether the rcwa mapping <f> is balanced
#P  IsIntegral( <f> ) . . . . . indicates whether the divisor of <f> equals 1
#P  IsIntegral( <M> ) . .  indicates whether all elements of <M> are integral
#P  IsClassWiseTranslating( <f> ) .  indicates whether <f> is class-wise trs.
#P  IsClassWiseTranslating( <M> ) indicates whether all elements of <M> are "
#P  IsClassWiseOrderPreserving( <f> ) . . . .  indicates whether <f> is cwop.
#P  IsClassWiseOrderPreserving( <M> ) . . . .  indicates whether <M> is cwop.
#P  IsSignPreserving( <f> )  indicates whether the rcwa mapping <f> fixes N_0
#P  IsSignPreserving( <M> ) . indicates whether the rcwa monoid <M> fixes N_0
##
##  We define the *multiplier* of an rcwa mapping <f> by the least common
##  multiple of the coefficients a_r(m), and we define its *divisor* by the
##  least common multiple of the coefficients c_r(m).
##
##  We define the *multiplier* / *divisor* of an rcwa group or -monoid by the
##  lcm of the multipliers / divisors of its elements, if such an lcm exists,
##  and by infinity otherwise.
##
##  We define the *prime set* of an rcwa mapping <f> by the set of all primes
##  dividing its modulus or its multiplier, and we define the *prime set* of
##  an rcwa group or -monoid by the union of the prime sets of its elements.
##
##  We define the *maximal shift* of an rcwa mapping <f> of Z as the maximum
##  of the absolute values of the coefficients b_r(m).
##
##  We say that an rcwa mapping is *balanced* if its multiplier and its
##  divisor have the same prime divisors.
##
##  We say that an rcwa mapping is *integral* if its divisor is 1, and we say
##  that an rcwa group / -monoid is *integral* if all of its elements are so.
##
##  We say that an rcwa mapping is *class-wise translating* if all of its
##  affine partial mappings are translations. We say that an rcwa group
##  or -monoid is *class-wise translating* if all of its elements are so.
##
##  We say that an rcwa mapping of Z or Z_(pi) is *class-wise order-preser-
##  ving* if all coefficients a_r(m) are positive, and we say that an rcwa
##  group or -monoid is *class-wise order-preserving* if all of its elements
##  are so.
##
##  We say that an rcwa mapping of Z or Z_(pi) is *sign-preserving* if it
##  does not map nonnegative integers to negative integers or vice versa.
##
DeclareAttribute( "Multiplier", IsRcwaMapping );
DeclareAttribute( "Multiplier", IsRcwaMonoid );
DeclareSynonym( "Mult", Multiplier );
DeclareAttribute( "Divisor", IsRcwaMapping );
DeclareAttribute( "Divisor", IsRcwaMonoid );
DeclareSynonym( "Div", Divisor );
DeclareAttribute( "PrimeSet", IsRcwaMapping );
DeclareAttribute( "PrimeSet", IsRcwaMonoid );
DeclareAttribute( "MaximalShift", IsRcwaMapping );
DeclareProperty( "IsBalanced", IsRcwaMapping );
DeclareProperty( "IsIntegral", IsRcwaMapping );
DeclareProperty( "IsIntegral", IsRcwaMonoid );
DeclareProperty( "IsClassWiseTranslating", IsRcwaMapping );
DeclareProperty( "IsClassWiseTranslating", IsRcwaMonoid );
DeclareProperty( "IsClassWiseOrderPreserving", IsRcwaMapping ); 
DeclareProperty( "IsClassWiseOrderPreserving", IsRcwaMonoid );
DeclareProperty( "IsSignPreserving", IsRcwaMapping );
DeclareProperty( "IsSignPreserving", IsRcwaMonoid );

#############################################################################
##
#A  ClassWiseOrderPreservingOn( <f> )
#A  ClassWiseOrderReversingOn( <f> )
#A  ClassWiseConstantOn( <f> )
##
##  The union of the residue classes r(m) for which a_r(m) > 0, a_r(m) < 0
##  or a_r(m) = 0, respectively.
##
DeclareAttribute( "ClassWiseOrderPreservingOn", IsRcwaMapping );
DeclareAttribute( "ClassWiseOrderReversingOn", IsRcwaMapping );
DeclareAttribute( "ClassWiseConstantOn", IsRcwaMapping );

#############################################################################
##
#A  IncreasingOn( <f> ) . . . . . . . . . . . set of n such that |n^f| >> |n|
#A  DecreasingOn( <f> ) . . . . . . . . . . . set of n such that |n^f| << |n|
##
##  The union of all residue classes r(m) such that |R/a_r(m)R|>|R/c_r(m)R|
##  respectively |R/a_r(m)R|<|R/c_r(m)R|.
##
DeclareAttribute( "IncreasingOn", IsRcwaMapping );
DeclareAttribute( "DecreasingOn", IsRcwaMapping );

#############################################################################
##
#A  ShiftsUpOn( <f> ) . . . union of residue classes S s.th. f|_S: n -> n + c
#A  ShiftsDownOn( <f> ) . . union of residue classes S s.th. f|_S: n -> n - c
##
##  Let f be an rcwa mapping of Z with modulus m.
##
##  ShiftsUpOn(f) denotes the union of all residue classes r(m) such that
##  the restriction f|_r(m) is given by n -> n + b_r(m) for positive b_r(m).
##
##  ShiftsDownOn(f) denotes the union of all residue classes r(m) such that
##  the restriction f|_r(m) is given by n -> n + b_r(m) for negative b_r(m).
##
DeclareAttribute( "ShiftsUpOn", IsRcwaMappingOfZ );
DeclareAttribute( "ShiftsDownOn", IsRcwaMappingOfZ );

#############################################################################
##
#O  Multpk( <f>, <p>, <k> )  the elements multiplied by a multiple of <p>^<k>
##
##  Returns the union of the residue classes r(m) such that 
##
##    - p^k||a_r(m) if k > 0, resp.
##    - p^-k||c_r(m) if k < 0, resp.
##    - p \nmid a_r(m), c_r(m) if k = 0.
##
DeclareOperation( "Multpk", [ IsRcwaMapping, IsInt, IsInt ] );

#############################################################################
##
#A  MultDivType( <f> ) . distribution of coeff's in numerators & denominators
##
DeclareAttribute( "MultDivType", IsRcwaMapping );

#############################################################################
##
#A  FixedPointsOfAffinePartialMappings( <f> )
##
##  The fixed points of the affine partial mappings of the rcwa mapping <f>
##  in the quotient field of the source.
##
DeclareAttribute( "FixedPointsOfAffinePartialMappings", IsRcwaMapping );

#############################################################################
##
#A  LargestSourcesOfAffineMappings( <f> ) .  partition on which <f> is affine
##
##  The coarsest partition of the base ring R on whose elements the rcwa
##  mapping <f> is affine.
##
DeclareAttribute( "LargestSourcesOfAffineMappings", IsRcwaMapping );

#############################################################################
##
#A  ImageDensity( <f> ) . . . . . . . . . . . . . . . .  image density of <f>
##
##  We define the *image density* of an rcwa mapping <f>
##  by (sum_(r(m) in R/mR) |R/c_r(m)R|/|R/a_r(m)R|)/m.
##  
##  The image density of an rcwa mapping measures how "dense" its image is:
##
##  An image density > 1 implies that there need to be "overlaps", i.e.
##  that the mapping cannot be injective, while an image density < 1 implies
##  that the images of the residue classes r(m) do not entirely cover R, i.e.
##  that the mapping cannot be surjective.
##
##  The image density of any bijective rcwa mapping is 1.
##
DeclareAttribute( "ImageDensity", IsRcwaMapping );

#############################################################################
##
#A  MappedPartitions( <g> )
##
DeclareAttribute( "MappedPartitions", IsRcwaMapping );

#############################################################################
##
#S  The notion of tameness. /////////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#P  IsTame( <f> ) . . . . indicates whether or not <f> is a tame rcwa mapping
#P  IsTame( <M> ) . . . . indicates whether or not <M> is a tame rcwa monoid
##
##  We say that an rcwa mapping <f> is *tame* if and only if the moduli
##  of its powers are bounded, and *wild* otherwise. We say that an rcwa
##  group or an rcwa monoid is *tame* if and only if the moduli of its
##  elements are bounded.
##
DeclareProperty( "IsTame", IsRcwaMapping );
DeclareProperty( "IsTame", IsRcwaMonoid );

#############################################################################
##
#O  CheckForWildness( <f> )
#O  CheckForWildness( <M>, <max_r>, <cheap> )
##
##  Performs checks for wildness, and sets `IsTame' to `false' if wildness
##  can be established. It is not guaranteed that a wild mapping or monoid
##  is always recognized as such. In the operation for rcwa monoids, <max_r>
##  is the search radius, i.e. it is attempted to find a wild element within
##  the ball of radius <max_r> around 1. If <cheap> is true, the elements of
##  the ball are only checked for balancedness and loops, whereas if <cheap>
##  is false, `IsTame' is applied to them. 
##
DeclareOperation( "CheckForWildness", [ IsRcwaMapping ] );
DeclareOperation( "CheckForWildness", [ IsRcwaMonoid, IsPosInt, IsBool ] );

#############################################################################
##
#S  Support, images, preimages and the action of an rcwa mapping on R. //////
##
#############################################################################

#############################################################################
##
#A  Support( <f> ) . . . . . . . . . . .  the support of the rcwa mapping <f>
#A  Support( <M> ) . . . . . . . . . . . . the support of the rcwa monoid <M>
#A  MovedPoints( <f> )
#A  MovedPoints( <M> )
##
##  For rcwa mappings, -groups and -monoids, `Support' and `MovedPoints' are
##  synonyms.
##
DeclareAttribute( "Support", IsRcwaMapping );
DeclareAttribute( "Support", IsRcwaMonoid );
DeclareAttribute( "MovedPoints", IsRcwaMapping );
DeclareAttribute( "MovedPoints", IsRcwaMonoid );

#############################################################################
##
#O  ImagesSet( <f>, <S> ) . . . . . . image of <S> under the rcwa mapping <f>
#O  \^( <S>, <f> )  . . . . . . . . . image of <S> under the rcwa mapping <f>
#O  PreImagesSet( <f>, <S> )  . .  preimage of <S> under the rcwa mapping <f>
##
DeclareOperation( "ImagesSet", [ IsRcwaMapping, IsListOrCollection ] );
DeclareOperation( "\^", [ IsListOrCollection, IsRcwaMapping ] );
DeclareOperation( "PreImagesSet", [ IsRcwaMapping, IsList ] );

#############################################################################
##
#F  InjectiveAsMappingFrom( <f> ) . . . .  some set on which <f> is injective
##
##  Returns some subset S of Source(<f>) such that the restriction of <f>
##  to S is injective.
##
DeclareGlobalFunction( "InjectiveAsMappingFrom" );

#############################################################################
##
#O  ShortCycles( <f>, <S>, <maxlng> ) .  short cycles of the rcwa mapping <f>
#O  ShortCycles( <f>, <S>, <maxlng>, <maxn> )
#O  ShortCycles( <f>, <maxlng> )
##
##  In the 3-argument case, `ShortCycles' returns a list of all finite cycles
##  of the rcwa mapping <f> of length <= <maxlng> which intersect nontri-
##  vially with the set <S>. In the 4-argument case, it does the same except
##  that <f> must be an rcwa mapping of Z and that cycles exceeding <maxn>
##  are dropped. In the 2-argument case, it returns a list of all "single"
##  finite cycles of the rcwa mapping <f> of length <= <maxlng>.
##
DeclareOperation( "ShortCycles", [ IsRcwaMapping, IsListOrCollection,
                                   IsPosInt ] );
DeclareOperation( "ShortCycles", [ IsRcwaMapping, IsListOrCollection,
                                   IsPosInt, IsPosInt ] );
DeclareOperation( "ShortCycles", [ IsRcwaMapping, IsPosInt ] );

#############################################################################
##
#O  ShortResidueClassCycles( <g>, <modulusbound>, <maxlng> )
##
##  Returns a list of all cycles of residue classes of the rcwa
##  permutation <g> which contain a residue class r(m) such that m divides
##  <modulusbound>, and which are not longer than <maxlng>.
## 
##  Note that we are only talking about a cycle of residue classes
##  of an rcwa permutation g if the restrictions of g to all contained
##  residue classes are affine.
##
DeclareOperation( "ShortResidueClassCycles", [ IsRcwaMapping, IsRingElement,
                                               IsPosInt ] );

#############################################################################
##
#O  CycleRepresentativesAndLengths( <g>, <S> )
##
##  Returns a list of pairs (cycle representative, length of cycle) for all
##  cycles of the rcwa permutation <g> which have a nontrivial intersection
##  with the set <S>, where fixed points are omitted. The rcwa permutation
##  <g> is assumed to have only finite cycles. If <g> has an infinite cycle
##  which intersects nontrivially with <S>, this may cause an infinite loop.
##
DeclareOperation( "CycleRepresentativesAndLengths",
                  [ IsRcwaMapping, IsListOrCollection ] );

#############################################################################
##
#O  RestrictedPerm( <g>, <S> ) . . . . . . . . . .  restriction of <g> to <S>
#O  PermutationOpNC( <g>, <P>, <act> ) . .  permutation induced by <g> on <P>
##
##  Returns the restriction of the rcwa permutation <g> to the residue class
##  union <S>, respectively the permutation induced by <g> on the partition
##  <P> of <R> into residue classes.
##
DeclareOperation( "RestrictedPerm", [ IsRcwaMapping, IsListOrCollection ] );
DeclareOperation( "PermutationOpNC",
                  [ IsObject, IsListOrCollection, IsFunction ] );

#############################################################################
##
#S  Right inverses of injective rcwa mappings. //////////////////////////////
##
#############################################################################

#############################################################################
##
#A  RightInverse( <f> ) . . . . . . . . . . . . . . . .  right inverse of <f>
##
##  The right inverse of <f>, i.e. a mapping g such that fg = 1.
##  The mapping <f> must be injective.
##
DeclareAttribute( "RightInverse", IsRcwaMapping );

#############################################################################
##
#O  CommonRightInverse( <l>, <r> ) . . . . .  mapping d such that ld = rd = 1
##
##  Returns a mapping d such that ld = rd = 1.
##  The mappings <l> and <r> must be injective, and their images must form
##  a partition of the underlying ring.
##
DeclareOperation( "CommonRightInverse", [ IsRcwaMapping, IsRcwaMapping ] );

#############################################################################
##
#S  Transition graphs and transition matrices. //////////////////////////////
##
#############################################################################

#############################################################################
##
#O  TransitionGraph( <f>, <m> ) . .  transition graph of the rcwa mapping <f>
##
##  Returns the transition graph for modulus <m> of the rcwa mapping <f>.
##
##  We define the *transition graph* Gamma_(f,m) for modulus m of an
##  rcwa mapping f as follows:
##
##  - The vertices are the residue classes (mod m).
##
##  - There is an edge from r1(m) to r2(m) if and only if there is some
##    n1 in r1(m) such that n1^f in r2(m).
##
DeclareOperation( "TransitionGraph", [ IsRcwaMapping, IsRingElement ] );

#############################################################################
##
#O  TransitionMatrix( <f>, <m> ) . . transition matrix of <f> for modulus <m>
##
##  Returns the *transition matrix* T of <f> for modulus <m>.
##
##  The entry T_(i,j) is the "proportion" of the elements of the <i>th
##  residue class which are mapped to the <j>th residue class under <f>.
##  The numbering of the residue classes is the same as in the corresponding
##  return value of the function `AllResidues'.
##
DeclareOperation( "TransitionMatrix", [ IsRcwaMapping, IsRingElement ] );

#############################################################################
##
#A  Sources( <f> )
#A  Sinks( <f> )
#A  Loops( <f> )
##
##  Let <f> be an rcwa mapping with modulus m. 
##  Then `Sources(<f>)' and `Sinks(<f>)' are lists of unions of residue
##  classes (mod m), and `Loops(<f>)' is a list of residue classes (mod m).
##
##  The list `Sources(<f>)' contains an entry for any strongly connected
##  component of the transition graph of <f> for modulus m which has only
##  outgoing edges. The list entry corresponding to a given such strongly
##  connected component is just the union of its vertices. The description of
##  the list `Sinks(<f>)' is obtained by replacing "outgoing" by "ingoing".
##
##  The entries of the list `Loops(<f>)' are the residue classes (mod m)
##  which <f> does not fix setwise, but which intersect nontrivially
##  with their images under <f>.
##
DeclareAttribute( "Sources", IsRcwaMapping );
DeclareAttribute( "Sinks", IsRcwaMapping );
DeclareAttribute( "Loops", IsRcwaMapping );

#############################################################################
##
#O  OrbitsModulo( <M>, <m>, <d> ) "orbit" partition of (R/<m>R)^<d> under <M>
#O  OrbitsModulo( <M>, <m> ) . . . . . . . . . . . . . . . . . . case <d> = 1
#O  OrbitsModulo( <f>, <m>, <d> )  .  case <M> = Group(<f>) resp. Monoid(<f>)
#O  OrbitsModulo( <f>, <m> ) . . . . . . . . . . . . . . . dito, case <d> = 1
##
##  The definition given below is a generalization of the one given in the
##  manual, and it should be taken with notable caution: it is not clear yet
##  whether it makes sense in the given form, and it is likely to be changed
##  or withdrawn.
##
##  The operation `OrbitsModulo' returns a partition of (R/<m>R)^<d> into
##  "orbits" under the action of the rcwa monoid <M>, in the sense that two
##  tuples (a_1,...,a_<d>) and (b_1,...,b_<d>) of residues (mod <m>) lie in
##  the same "orbit" if and only if there is an f in <M> such that one of the
##  following hold:
##
##    1.   ((a_1)^f mod <m>,...,(a_<d>)^f mod <m>)
##       = ((b_1)^f mod <m>,...,(b_<d>)^f mod <m>).
##    2.   ((b_1)^f mod <m>,...,(b_<d>)^f mod <m>)
##       = ((a_1)^f mod <m>,...,(a_<d>)^f mod <m>).
##
##  In case R = Z, the residues (mod <m>) are the integers 0,...,<m>-1.
##  1-tuples are represented by the ring element they contain.
##
##  If the first argument is an rcwa mapping <f>, then <M> is the group
##  generated by <f> if <f> is bijective, and the monoid generated by <f>
##  otherwise. If <d> is not given, it defaults to 1.
##
##  If the first argument is an rcwa mapping <f> and <d> = 1, then the
##  return value as described above equals the set of the sets of vertices
##  of the weakly-connected components of the transition graph
##  Gamma_(<f>,<m>).
##
DeclareOperation( "OrbitsModulo", [ IsRcwaMonoid, IsRingElement ] );
DeclareOperation( "OrbitsModulo", [ IsRcwaMonoid, IsRingElement,
                                    IsPosInt ] );
DeclareOperation( "OrbitsModulo", [ IsRcwaMapping, IsRingElement ] );
DeclareOperation( "OrbitsModulo", [ IsRcwaMapping, IsRingElement,
                                    IsPosInt ] );

#############################################################################
##
#O  FactorizationOnConnectedComponents( <f>, <m> )
##
##  Returns the set of restrictions of the rcwa mapping <f> to the weakly-
##  connected components of its transition graph Gamma_(<f>,<m>).
##  These mappings have pairwise disjoint supports, hence any two of them
##  commute, and their product equals <f>.
##
DeclareOperation( "FactorizationOnConnectedComponents",
                  [ IsRcwaMapping, IsRingElement ] );

#############################################################################
##
#F  TransitionSets( <f>, <m> ) . . . . . . . . . . . .  set transition matrix
##
##  Returns the *set transition matrix* <T> of <f> for modulus <m>.
##
##  The entry T_(i,j) is the subset of the <i>th residue class which is
##  mapped to the <j>th residue class under <f>. The numbering of the residue
##  classes is the same as in the corresponding return value of the function
##  `AllResidues'.
##
DeclareGlobalFunction( "TransitionSets" );

#############################################################################
##
#S  Trajectories. ///////////////////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#O  Trajectory( <f>, <n>, <length> ) . . .  trajectory of <f> starting at <n>
#O  Trajectory( <f>, <n>, <length>, <m> )
#O  Trajectory( <f>, <n>, <length>, <whichcoeffs> )
#O  Trajectory( <f>, <n>, <terminal> )
#O  Trajectory( <f>, <n>, <terminal>, <m> )
#O  Trajectory( <f>, <n>, <terminal>, <whichcoeffs> )
##
##  In the first case, this operation returns a list of the first <length>
##  iterates in the trajectory of the rcwa mapping <f> starting at <n>.
##  In the forth case it returns the initial part of the trajectory of <f>
##  starting at <n> which ends at the first occurence of an iterate in the
##  set <terminal>.
##  In place of the ring element <n>, a finite set of ring elements or a
##  union of residue classes can be given. In the second and fifth case the
##  iterates are reduced (mod <m>) to save memory.
##
##  In the third and sixth case the operation returns a list of "accumulated
##  coefficients" on the trajectory of <n> under the rcwa mapping <f>.
##  The term "accumulated coefficients" denotes the list c of coefficient
##  triples such that for any k we have <n>^(<f>^(k-1)) = (c[k][1]*<n> +
##  c[k][2])/c[k][3]. The argument <whichcoeffs> can either be "AllCoeffs" or
##  "LastCoeffs", and determines whether the entire list of triples or only
##  the last triple is computed.
##
DeclareOperation( "Trajectory", [ IsRcwaMapping, IsObject, IsObject ] );
DeclareOperation( "Trajectory", [ IsRcwaMapping, IsObject, IsObject,
                                                 IsObject ] );

#############################################################################
##
#F  GluckTaylorInvariant( <l> ) . .  Gluck-Taylor invariant of trajectory <l>
##
##  Returns the Gluck-Taylor invariant of the list <l> of integers,
##  interpreted as the trajectory of an rcwa mapping. See
##
##  David Gluck and Brian D. Taylor: A New Statistic for the 3x+1 Problem,
##  Proc. Amer. Math. Soc. 130 (2002), 1293-1301.
##
DeclareGlobalFunction( "GluckTaylorInvariant" );

#############################################################################
##
#F  TraceTrajectoriesOfClasses( <f>, <classes> ) . residue class trajectories
##
##  Traces the trajectories of the residue classes in the residue class union
##  <classes> under the mapping <f>. All iterates are written as a list of
##  single residue classes. This list is computed using the function
##  `AsUnionOfFewClasses' from the `ResClasses' package.
##
##  The function stops once it detects a cycle or it detects that a timeout
##  given as option "timeout" has expired.
##
##  The resulting list of lists of residue classes is returned.
##
##  Caution: All classes are traced separately, thus a cycle in the
##           trajectory usually does only cause a cycle in the list of
##           *unions* of the returned sets of residue classes!
##
DeclareGlobalFunction( "TraceTrajectoriesOfClasses" );

#############################################################################
##
#S  Further attributes of rcwa mappings. ////////////////////////////////////
##
#############################################################################

#############################################################################
##
#A  SmallestRoot( <f> ) . . . . . . . . smallest root of the rcwa mapping <f>
#A  PowerOverSmallestRoot( <f> )
#A  BaseRoot( <f> )
#A  PowerOverBaseRoot( <f> )
##
##  We say that g is a *smallest root* of f if for some k we have f = g^k,
##  but h^l = g implies that l is coprime to the order of g. Smallest roots
##  are in general obviously not unique, and also do not need to exist.
##  The second-mentioned attribute stores the value of k.
##  The third- and fourth-mentioned attributes are technical "equivalents"
##  where no minimality is guaranteed.
##
DeclareAttribute( "SmallestRoot", IsRcwaMapping );
DeclareAttribute( "PowerOverSmallestRoot", IsRcwaMapping );
DeclareAttribute( "BaseRoot", IsRcwaMapping );
DeclareAttribute( "PowerOverBaseRoot", IsRcwaMapping );

#############################################################################
##
#S  Probabilistic guesses. //////////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#O  LikelyContractionCentre( <f>, <maxn>, <bound> ) likely contraction centre
##
##  Returns a guess of what the *contraction centre* of the rcwa mapping <f>
##  might be.
##
##  Assuming its existence, the *contraction centre* is the unique finite
##  subset S_0 of the base ring R which <f> maps bijectively to itself and
##  which intersects nontrivially with any trajectory of <f>.
##
##  The mapping <f> is assumed to be contracting.
##
##  As in general contraction centres are likely not computable, methods
##  will be probabilistic. The argument <maxn> is a bound on the starting 
##  value and <bound> is a bound on the elements of the sequence to be
##  searched. If the limit <bound> is exceeded, an Info message on Info
##  level 3 of InfoRCWA is given.
##
DeclareOperation( "LikelyContractionCentre",
                  [ IsRcwaMapping, IsRingElement, IsPosInt ] );
DeclareSynonym( "LikelyContractionCenter", LikelyContractionCentre );

#############################################################################
##
#O  GuessedDivergence( <f> ) . . . . . . . . . . .  guessed divergence of <f>
##
##  Returns a guess of what one might call the "divergence" of the rcwa
##  mapping <f>. This should give a rough hint on how fast the rcwa mapping
##  <f> contracts (if its divergence is smaller than 1) or how fast its
##  trajectories diverge (if its divergence is larger than 1).
##  Nothing particular is guaranteed, and no mathematical conclusions can
##  be made from the return values. 
##
DeclareOperation( "GuessedDivergence", [ IsRcwaMapping ] );

#############################################################################
##
#S  LaTeX output. ///////////////////////////////////////////////////////////
##
#############################################################################

#############################################################################
##
#A  LaTeXString( <obj> ) . . . . . . . . . . .  LaTeX string for object <obj>
##
DeclareAttribute( "LaTeXString", IsObject );

#############################################################################
##
#O  LaTeXStringRcwaMapping( <f> )
#O  LaTeXStringRcwaGroup( <G> )
##
##  Returns a LaTeX string for an rcwa mapping <f>, resp. an rcwa group <G>.
##  Methods for `LaTeXStringRcwaMapping' recognize options "Factorization",
##  "Indentation", "German" and "VarName" / "VarNames".
##
DeclareOperation( "LaTeXStringRcwaMapping", [ IsRcwaMapping ] );
DeclareOperation( "LaTeXStringRcwaGroup", [ IsRcwaGroup ] );

#############################################################################
##
#O  LaTeXAndXDVI( <obj> ) .  write LaTeX string to file, LaTeX & show by xdvi
##
DeclareOperation( "LaTeXAndXDVI", [ IsObject ] );

#############################################################################
##
#E  rcwamap.gd . . . . . . . . . . . . . . . . . . . . . . . . . .  ends here