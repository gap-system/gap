#############################################################################
##
#W  field.gd                    GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for division rings.
##
Revision.field_gd :=
    "@(#)$Id$";


#############################################################################
#1
##  A *division ring* is a ring (see Chapter~"Rings") in which every non-zero
##  element has an inverse.
##  The most important class of division rings are the commutative ones,
##  which are called *fields*.
##
##  {\GAP} supports finite fields (see Chapter~"Finite Fields") and
##  abelian number fields (see Chapter~"Abelian Number Fields"),
##  in particular the field of rationals (see Chapter~"Rational Numbers").
##
##  This chapter describes the general {\GAP} functions for fields and
##  division rings.
##
##  If a field <F> is a subfield of a commutative ring <C>,
##  <C> can be considered as a vector space over the (left) acting domain
##  <F> (see Chapter~"Vector Spaces").
##  In this situation, we call <F> the *field of definition* of <C>.
##
##  Each field in {\GAP} is represented as a vector space over a subfield
##  (see~"IsField"), thus each field is in fact a field extension in a
##  natural way, which is used by functions such as `Norm' and `Trace'
##  (see~"Galois Action").

#T Note that the families of a division ring and of its left acting domain
#T may be different!!


#############################################################################
##
#P  IsField( <D> )
##
##  A *field* is a commutative division ring
##  (see~"IsDivisionRing" and~"IsCommutative").
##
DeclareSynonymAttr( "IsField", IsDivisionRing and IsCommutative );

InstallTrueMethod( IsCommutative, IsDivisionRing and IsFinite );


#############################################################################
##
#A  PrimeField( <D> )
##
##  The *prime field* of a division ring <D> is the smallest field which is
##  contained in <D>.
##  For example, the prime field of any field in characteristic zero
##  is isomorphic to the field of rational numbers.
##
DeclareAttribute( "PrimeField", IsDivisionRing );


#############################################################################
##
#P  IsPrimeField( <D> )
##
##  A division ring is a prime field if it is equal to its prime field
##  (see~"PrimeField").
##
DeclareProperty( "IsPrimeField", IsDivisionRing );

InstallIsomorphismMaintenance( IsPrimeField,
    IsField and IsPrimeField, IsField );


#############################################################################
##
#A  DefiningPolynomial( <F> )
##
##  is the defining polynomial of the field <F> as a field extension
##  over the left acting domain of <F>.
##  A root of the defining polynomial can be computed with
##  `RootOfDefiningPolynomial' (see~"RootOfDefiningPolynomial").
##
DeclareAttribute( "DefiningPolynomial", IsField );


#############################################################################
##
#A  DegreeOverPrimeField( <F> )
##
##  is the degree of the field <F> over its prime field (see~"PrimeField").
##
DeclareAttribute( "DegreeOverPrimeField", IsDivisionRing );

InstallIsomorphismMaintenance( DegreeOverPrimeField,
    IsDivisionRing, IsDivisionRing );


#############################################################################
##
#A  GeneratorsOfDivisionRing( <D> )
##
##  generators with respect to addition, multiplication, and taking inverses
##  (the identity cannot be omitted ...)
##
DeclareAttribute( "GeneratorsOfDivisionRing", IsDivisionRing );


#############################################################################
##
#A  GeneratorsOfField( <F> )
##
##  generators with respect to addition, multiplication, and taking
##  inverses. This attribute is the same as `GeneratorsOfDivisionRing'
##  (see~"GeneratorsOfDivisionRing").
##
DeclareSynonymAttr( "GeneratorsOfField", GeneratorsOfDivisionRing );


#############################################################################
##
#A  NormalBase( <F> )
#O  NormalBase( <F>, <elm> )
##
##  Let <F> be a field that is a Galois extension of its subfield
##  `LeftActingDomain( <F> )'.
##  Then `NormalBase' returns a list of elements in <F> that form a normal
##  basis of <F>, that is, a vector space basis that is closed under the
##  action of the Galois group (see~"GaloisGroup!of field") of <F>.
##
##  If a second argument <elm> is given,
##  it is used as a hint for the algorithm to find a normal basis with the
##  algorithm described in~\cite{Art68}.
##
DeclareAttribute( "NormalBase", IsField );
DeclareOperation( "NormalBase", [ IsField, IsScalar ] );


#############################################################################
##
#A  PrimitiveElement( <D> )
##
##  is an element of <D> that generates <D> as a division ring together with
##  the left acting domain.
##
DeclareAttribute( "PrimitiveElement", IsDivisionRing );


#############################################################################
##
#A  PrimitiveRoot( <F> )
##
##  A *primitive root* of a finite field is a generator of its multiplicative
##  group.
##  A primitive root is always a primitive element (see~"PrimitiveElement"),
##  the converse is in general not true.
##  % For example, `Z(9)^2' is a primitive element for `GF(9)' but not a
##  % primitive root.
##
DeclareAttribute( "PrimitiveRoot", IsField and IsFinite );


#############################################################################
##
#A  RootOfDefiningPolynomial( <F> )
##
##  is a root in the field <F> of its defining polynomial as a field
##  extension over the left acting domain of <F>.
##  The defining polynomial can be computed with
##  `DefiningPolynomial' (see~"DefiningPolynomial").
##
DeclareAttribute( "RootOfDefiningPolynomial", IsField );


#############################################################################
##
#O  AsDivisionRing( <C> )
#O  AsDivisionRing( <F>, <C> )
#O  AsField( <C> )
#O  AsField( <F>, <C> )
##
##  If the collection <C> can be regarded as a division ring then
##  `AsDivisionRing( <C> )' is the division ring that consists of the
##  elements of <C>, viewed as a vector space over its prime field;
##  otherwise `fail' is returned.
##
##  In the second form, if <F> is a division ring contained in <C> then
##  the returned division ring is viewed as a vector space over <F>.
##
##  `AsField' is just a synonym for `AsDivisionRing'.
##
DeclareOperation( "AsDivisionRing", [ IsCollection ] );
DeclareOperation( "AsDivisionRing", [ IsDivisionRing, IsCollection ] );

DeclareSynonym( "AsField", AsDivisionRing );


#############################################################################
##
#O  ClosureDivisionRing( <D>, <obj> )
##
##  `ClosureDivisionRing' returns the division ring generated by the elements
##  of the division ring <D> and <obj>,
##  which can be either an element or a collection of elements,
##  in particular another division ring.
##  The left acting domain of the result equals that of <D>.
##
DeclareOperation( "ClosureDivisionRing", [ IsDivisionRing, IsObject ] );

DeclareSynonym( "ClosureField", ClosureDivisionRing );


#############################################################################
##
#A  Subfields( <F> )
##
##  is the set of all subfields of the field <F>.
#T or shall we allow to ask, e.g., for subfields of quaternion algebras?
##
DeclareAttribute( "Subfields", IsField );


#############################################################################
##
#O  FieldExtension( <F>, <poly> )
##
##  is the field obtained on adjoining a root of the irreducible polynomial
##  <poly> to the field <F>.
##
DeclareOperation( "FieldExtension", [ IsField, IsUnivariatePolynomial ] );


#############################################################################
#2
##  Let $L > K$ be a field extension of finite degree.
##  Then to each element $\alpha \in L$, we can associate a $K$-linear
##  mapping $\varphi_{\alpha}$ on $L$, and for a fixed $K$-basis of $L$,
##  we can associate to $\alpha$ the matrix $M_{\alpha}$ (over $K$)
##  of this mapping.
##
##  The *norm* of $\alpha$ is defined as the determinant of $M_{\alpha}$,
##  the *trace* of $\alpha$ is defined as the trace of $M_{\alpha}$,
##  the *minimal polynomial* $\mu_{\alpha}$ and the
##  *trace polynomial* $\chi_{\alpha}$ of $\alpha$
##  are defined as the minimal polynomial (see~"MinimalPolynomial!over a field")
##  and the characteristic polynomial (see~"CharacteristicPolynomial" and
##  "TracePolynomial") of $M_{\alpha}$.
##  (Note that $\mu_{\alpha}$ depends only on $K$ whereas $\chi_{\alpha}$
##  depends on both $L$ and $K$.)
##
##  Thus norm and trace of $\alpha$ are elements of $K$,
##  and $\mu_{\alpha}$ and $\chi_{\alpha}$ are polynomials over $K$,
##  $\chi_{\alpha}$ being a power of $\mu_{\alpha}$,
##  and the degree of $\chi_{\alpha}$ equals the degree of the field
##  extension $L > K$.
##
##  The *conjugates* of $\alpha$ in $L$ are those roots of $\chi_{\alpha}$
##  (with multiplicity) that lie in $L$;
##  note that if only $L$ is given, there is in general no way to access
##  the roots outside $L$.
##
##  Analogously, the *Galois group* of the extension $L > K$ is defined as
##  the group of all those field automorphisms of $L$ that fix $K$
##  pointwise.
##
##  If $L > K$ is a Galois extension then the conjugates of $\alpha$ are
##  all roots of $\chi_{\alpha}$ (with multiplicity),
##  the set of conjugates equals the roots of $\mu_{\alpha}$,
##  the norm of $\alpha$ equals the product and the trace of $\alpha$
##  equals the sum of the conjugates of $\alpha$,
##  and the Galois group in the sense of the above definition equals
##  the usual Galois group,
##
##  Note that `MinimalPolynomial( <F>, <z> )' is a polynomial *over* <F>,
##  whereas `Norm( <F>, <z> )' is the norm of the element <z> *in* <F>
##  w.r.t.~the field extension $<F> > `LeftActingDomain( <F> )'$.
##


#############################################################################
#3
##  The default methods for field elements are as follows.
##  `MinimalPolynomial' solves a system of linear equations,
##  `TracePolynomial' computes the appropriate power of the minimal
##  polynomial,
##  `Norm' and `Trace' values are obtained as coefficients of the
##  characteristic polynomial,
##  and `Conjugates' uses the factorization of the characteristic polynomial.
##
##  For elements in finite fields and cyclotomic fields, one wants to do the
##  computations in a different way since the field extensions in question
##  are Galois extensions, and the Galois groups are well-known in these
##  cases.
##  More general,
##  if a field is in the category `IsFieldControlledByGaloisGroup' then
##  the default methods are the following.
##  `Conjugates' returns the sorted list of images (with multiplicity) of the
##  element under the Galois group,
##  `Norm' computes the product of the conjugates,
##  `Trace' computes the sum of the conjugates,
##  `TracePolynomial' and `MinimalPolynomial' compute the product of
##  linear factors $x - c$ with $c$ ranging over the conjugates and the set
##  of conjugates, respectively.
##


#############################################################################
##
#C  IsFieldControlledByGaloisGroup( <obj> )
##
##  (The meaning is explained above.)
##
DeclareCategory( "IsFieldControlledByGaloisGroup", IsField );


#############################################################################
##
#M  IsFieldControlledByGaloisGroup( <finfield> )
##
##  For finite fields and abelian number fields
##  (independent of the representation of their elements),
##  we know the Galois group and have a method for `Conjugates' that does
##  not use `MinimalPolynomial'.
##
InstallTrueMethod( IsFieldControlledByGaloisGroup, IsField and IsFinite );


#############################################################################
##
#A  Conjugates( <z> ) . . . . . . . . . . . . . conjugates of a field element
#O  Conjugates( <L>, <z> )
#O  Conjugates( <L>, <K>, <z> )
##
##  `Conjugates' returns the list of *conjugates* of the field element <z>.
##  If two fields <L> and <K> are given then the conjugates are computed
##  w.r.t.~the field extension $<L> > <K>$,
##  if only one field <L> is given then `LeftActingDomain( <L> )' is taken as
##  default for the subfield <K>,
##  and if no field is given then `DefaultField( <z> )' is taken as default
##  for <L>.
##
##  The result list will contain duplicates if <z> lies in a proper subfield
##  of <L>, respectively of the default field of <z>.
##  The result list need not be sorted.
#T Do we want to guarantee sorted lists?
#T In GAP 3, the lists were not nec. sorted.
##
DeclareAttribute( "Conjugates", IsScalar );
DeclareOperation( "Conjugates", [ IsField, IsField, IsScalar ] );
DeclareOperation( "Conjugates", [ IsField, IsScalar ] );


#############################################################################
##
#A  Norm( <z> )  . . . . . . . . . . . . . . . . . .  norm of a field element
#O  Norm( <L>, <z> ) . . . . . . . . . . . . . . . .  norm of a field element
#O  Norm( <L>, <K>, <z> )  . . . . . . . . . . . . .  norm of a field element
##
##  `Norm' returns the norm of the field element <z>.
##  If two fields <L> and <K> are given then the norm is computed
##  w.r.t.~the field extension $<L> > <K>$,
##  if only one field <L> is given then `LeftActingDomain( <L> )' is taken as
##  default for the subfield <K>,
##  and if no field is given then `DefaultField( <z> )' is taken as default
##  for <L>.
##
DeclareAttribute( "Norm", IsScalar );
DeclareOperation( "Norm", [ IsField, IsScalar ] );
DeclareOperation( "Norm", [ IsField, IsField, IsScalar ] );


#############################################################################
##
#A  Trace( <z> )  . . . . . . . . . . . . . . . . .  trace of a field element
#A  Trace( <mat> )  . . . . . . . . . . . . . . . . . . . . trace of a matrix
#O  Trace( <L>, <z> ) . . . . . . . . . . . . . . .  trace of a field element
#O  Trace( <L>, <K>, <z> )  . . . . . . . . . . . .  trace of a field element
##
##  `Trace' returns the trace of the field element <z>.
##  If two fields <L> and <K> are given then the trace is computed
##  w.r.t.~the field extension $<L> > <K>$,
##  if only one field <L> is given then `LeftActingDomain( <L> )' is taken as
##  default for the subfield <K>,
##  and if no field is given then `DefaultField( <z> )' is taken as default
##  for <L>.
##
##  The *trace of a matrix* is the sum of its diagonal entries.
##  Note that this is *not* compatible with the definition of `Trace' for
##  field elements,
##  so the one-argument version is not suitable when matrices shall be
##  regarded as field elements.
#T forbid `Trace' as short form for `TraceMat'?
#T crossref. to `TraceMat'?
##
DeclareAttribute( "Trace", IsScalar );
DeclareAttribute( "Trace", IsMatrix );
DeclareOperation( "Trace", [ IsField, IsScalar ] );
DeclareOperation( "Trace", [ IsField, IsField, IsScalar ] );


#############################################################################
##
#O  TracePolynomial( <L>, <K>, <z>[, <inum>] )
##
##  returns the polynomial that is the product of $(X - c)$ where $c$ runs
##  over the conjugates of <z> in the field extension <L> over <K>.
##  The polynomial is returned as a univariate polynomial over <K> in the
##  indeterminate number <inum> (defaulting to 1).
##
##  This polynomial is sometimes also called the *characteristic polynomial*
##  of <z> w.r.t.~the field extension $<L> > <K>$.
##  Therefore methods are installed for `CharacteristicPolynomial'
##  (see~"CharacteristicPolynomial")
##  that call `TracePolynomial' in the case of field extensions.
##
DeclareOperation( "TracePolynomial", [ IsField, IsField, IsScalar ] );
DeclareOperation( "TracePolynomial",
    [ IsField, IsField, IsScalar, IsPosInt ] );


#############################################################################
##
#A  GaloisGroup( <F> )
##
##  The *Galois group* of a field <F> is the group of all field automorphisms
##  of <F> that fix the subfield $K = `LeftActingDomain( <F> )'$ pointwise.
##
##  Note that the field extension $<F> > K$ need *not* be a Galois extension.
##
DeclareAttribute( "GaloisGroup", IsField );


#############################################################################
##
#A  ComplexConjugate( <z> )
#A  RealPart( <z> )
#A  ImaginaryPart( <z> )
##
##  For a cyclotomic number <z>, `ComplexConjugate' returns
##  `GaloisCyc( <z>, -1 )', see~"GaloisCyc".
##  For a quaternion $<z> = c_1 e + c_2 i + c_3 j + c_4 k$,
##  `ComplexConjugate' returns $c_1 e - c_2 i - c_3 j - c_4 k$,
##  see~"IsQuaternion".
##
##  When `ComplexConjugate' is called with a list then the result is the list
##  of return values of `ComplexConjugate' for the list entries in the
##  corresponding positions.
##
##  When `ComplexConjugate' is defined for an object <z> then `RealPart'
##  and `ImaginaryPart' return $(<z> + `ComplexConjugate( <z> )') / 2$ and
##  $(<z> - `ComplexConjugate( <z> )') / 2 i$, respectively,
##  where $i$ denotes the corresponding imaginary unit.
##
DeclareAttribute( "ComplexConjugate", IsScalar );
DeclareAttribute( "ComplexConjugate", IsList );
DeclareAttribute( "RealPart", IsScalar );
DeclareAttribute( "RealPart", IsList );
DeclareAttribute( "ImaginaryPart", IsScalar );
DeclareAttribute( "ImaginaryPart", IsList );


#############################################################################
##
#O  DivisionRingByGenerators( [ <z>, ... ] )  . . . . div. ring by generators
#O  DivisionRingByGenerators( <F>, [ <z>, ... ] ) . . div. ring by generators
##
##  The first version returns a division ring as vector space over
##  `FieldOverItselfByGenerators( <gens> )'.
##
DeclareOperation( "DivisionRingByGenerators",
        [ IsDivisionRing, IsCollection ] );

DeclareSynonym( "FieldByGenerators", DivisionRingByGenerators );


#############################################################################
##
#O  FieldOverItselfByGenerators( [ <z>, ... ] )
##
##  This  operation is  needed for  the  call of `Field' or
##  `FieldByGenerators'
##  without  explicitly given subfield, in  order to construct  a left acting
##  domain for such a field.
##
DeclareOperation( "FieldOverItselfByGenerators", [ IsCollection ] );


#############################################################################
##
#O  DefaultFieldByGenerators( [ <z>, ... ] )  . . default field by generators
##
##  returns the default field containing the elements <z>,$\ldots$.
##  This field may be bigger than the smallest field containing these
##  elements.
##
DeclareOperation( "DefaultFieldByGenerators", [ IsCollection ] );


#############################################################################
##
#F  Field( <z>, ... ) . . . . . . . . . field generated by a list of elements
#F  Field( <list> )
#F  Field( <F>, <list> )
##
##  `Field' returns the smallest field $K$ that contains all the elements
##  $<z>, \ldots$,
##  or the smallest field $K$ that contains all elements in the list <list>.
##  If no subfield <F> is given, $K$ is constructed as a field over itself,
##  i.e. the left acting domain of $K$ is $K$.
##  In the third form, `Field' constructs the field generated by the
##  field <F> and the elements in the list <list>,
##  as a vector space over <F>.
##
DeclareGlobalFunction( "Field" );
#T why not `DivisionRing', and `Field' as a (more or less) synonym?


#############################################################################
##
#F  DefaultField( <z>, ... )  . . . . . default field containing a collection
#F  DefaultField( <list> )
##
##  `DefaultField' returns a field $K$ that contains all the elements
##  $<z>, \ldots$,
##  or a field $K$ that contains all elements in the list <list>.
##
##  This field need not be the smallest field in which the elements lie,
##  cf.~`Field' (see~"Field").
##  For example, for elements from cyclotomic fields `DefaultField' returns
##  the smallest cyclotomic field in which the elements lie,
##  but the elements may lie in a smaller number field
##  which is not a cyclotomic field.
##
DeclareGlobalFunction( "DefaultField" );


#############################################################################
##
#F  Subfield( <F>, <gens> ) . . . . . . . subfield of <F> generated by <gens>
#F  SubfieldNC( <F>, <gens> )
##
##  Constructs the subfield of <F> generated by <gens>.
##
DeclareGlobalFunction( "Subfield" );
DeclareGlobalFunction( "SubfieldNC" );


#############################################################################
##
#A  FrobeniusAutomorphism( <F> )  .  Frobenius automorphism of a finite field
##
##  returns the Frobenius automorphism of the finite
##  field <F> as a field homomorphism (see~"Ring Homomorphisms").
##
##  \atindex{Frobenius automorphism}{@Frobenius automorphism}
##  The *Frobenius automorphism* $f$ of a finite field $F$ of characteristic
##  $p$ is the function that takes each element $z$ of $F$ to its $p$-th
##  power.
##  Each automorphism of $F$ is a power of $f$.
##  Thus $f$ is a generator for the Galois group of $F$ relative to the prime
##  field of $F$,
##  and an appropriate power of $f$ is a generator of the Galois group of $F$
##  over a subfield (see~"GaloisGroup!of field").
##
##  \beginexample
##  gap> f := GF(16);
##  GF(2^4)
##  gap> x := FrobeniusAutomorphism( f );
##  FrobeniusAutomorphism( GF(2^4) )
##  gap> Z(16) ^ x;
##  Z(2^4)^2
##  gap> x^2;
##  FrobeniusAutomorphism( GF(2^4) )^2
##  \endexample
##
##  The image of an element $z$ under the $i$-th power of $f$ is computed
##  as the $p^i$-th power of $z$.
##  The product of the $i$-th power and the $j$-th power of $f$ is the $k$-th
##  power of $f$, where $k$ is $i j \pmod{`Size(<F>)'-1}$.
##  The zeroth power of $f$ is `IdentityMapping( <F> )'.
##
DeclareAttribute( "FrobeniusAutomorphism", IsField );


#############################################################################
##
#F  IsFieldElementsSpace( <V> )
##
##  If an $F$-vector space <V> is in the filter `IsFieldElementsSpace' then
##  this expresses that <V> consists of elements in a field, and that <V> is
##  handled via the mechanism of nice bases (see~"...") in the following way.
##  Let $K$ be the default field generated by the vector space generators of
##  <V>.
##  Then the `NiceFreeLeftModuleInfo' value of <V> is an $F$-basis $B$ of $K$,
##  and the `NiceVector' value of $v \in <V>$ is defined as
##  $`Coefficients'( B, v )$.
##
##  So it is assumed that methods for computing a basis for the
##  $F$-vector space $K$ are known;
##  for example, one can compute a Lenstra basis (see~"...") if $K$ is an
##  abelian number field,
##  and take successive powers of a primitive root if $K$ is a finite field
##  (see~"...").
##
DeclareHandlingByNiceBasis( "IsFieldElementsSpace",
    "for free left modules of field elements" );

#############################################################################
##
#O  NthRoot( <F>, <a>, <n> )
##
##  returns one <n>th root of <a> if such a root exists in <F> and returns
##  `fail' otherwise.
DeclareOperation( "NthRoot", [ IsField, IsScalar, IsPosInt ] );


#############################################################################
##
#E

