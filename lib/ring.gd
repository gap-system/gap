#############################################################################
##
#W  ring.gd                     GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for rings.
##
Revision.ring_gd :=
    "@(#)$Id$";


#############################################################################
##
#P  IsLDistributive( <R> )
##
##  is 'true' if the relation $a \* ( b + c ) = ( a \* b ) + ( a \* c )$
##  holds for all elements $a$, $b$, $c$ in the ring <R>,
##  and 'false' otherwise.
##
IsLDistributive := NewProperty( "IsLDistributive", IsRingElementCollection );
SetIsLDistributive := Setter( IsLDistributive );
HasIsLDistributive := Tester( IsLDistributive );

InstallSubsetMaintainedMethod( IsLDistributive,
    IsRingElementCollection and IsLDistributive,
    IsRingElementCollection );

InstallFactorMaintainedMethod( IsLDistributive,
    IsRingElementCollection and IsLDistributive,
    IsRingElementCollection,
    IsRingElementCollection );


#############################################################################
##
#P  IsRDistributive( <R> )
##
##  is 'true' if the relation $( a + b ) \* c = ( a \* c ) + ( b \* c )$
##  holds for all elements $a$, $b$, $c$ in the ring <R>,
##  and 'false' otherwise.
##
IsRDistributive := NewProperty( "IsRDistributive", IsRingElementCollection );
SetIsRDistributive := Setter( IsRDistributive );
HasIsRDistributive := Tester( IsRDistributive );

InstallSubsetMaintainedMethod( IsRDistributive,
    IsRingElementCollection and IsRDistributive,
    IsRingElementCollection );

InstallFactorMaintainedMethod( IsRDistributive,
    IsRingElementCollection and IsRDistributive,
    IsRingElementCollection,
    IsRingElementCollection );


#############################################################################
##
#P  IsDistributive( <D> )
##
IsDistributive := IsLDistributive and IsRDistributive;
SetIsDistributive := Setter( IsDistributive );
HasIsDistributive := Tester( IsDistributive );


#############################################################################
##
#C  IsRing( <R> )
##
##  A ring in {\GAP} is an additive group that is also a magma,
##  such that addition and multiplication are distributive.
##  (The multiplication need *not* be associative.)
##
IsRing := IsAdditiveGroup and IsMagma and IsDistributive;
SetIsRing := Setter( IsRing );
HasIsRing := Tester( IsRing );


#############################################################################
##
#C  IsRingWithOne( <R> )
##
##  A ring-with-one in {\GAP} is an additive group that is also a
##  magma-with-one,
##  such that addition and multiplication are distributive.
##  (The multiplication need not be associative.)
##
##  Note that the identity and the zero of a ring-with-one need *not* be
##  distinct.
##  This means that a ring that consists only of its zero element can be
##  regarded as a ring-with-one.
#T shall we force *every* trivial ring to be a ring-with-one
#T by installing an implication?
##  This is especially useful in the case of finitely presented rings,
##  in the sense that each factor of a ring-with-one is again a
##  ring-with-one.
##
IsRingWithOne := IsAdditiveGroup and IsMagmaWithOne and IsDistributive;
SetIsRingWithOne := Setter( IsRingWithOne );
HasIsRingWithOne := Tester( IsRingWithOne );


#############################################################################
##
#C  IsUniqueFactorizationRing( <R> )
##
##  A ring <R> is  called a *unique factorization ring* if it is an integral
##  ring, and every element has a unique factorization into irreducible
##  elements, i.e., a  unique representation as product  of irreducibles (see
##  "IsIrreducible").
##  Unique in this context means unique up to permutations of the factors and
##  up to multiplication of the factors by units (see "Units").
##  
IsUniqueFactorizationRing := NewCategory( "IsUniqueFactorizationRing",
    IsRing );

#T InstallSubsetMaintainedMethod( IsUniqueFactorizationRing,
#T     IsRing and IsUniqueFactorizationRing, IsRing );
#T ???


#############################################################################
##
#C  IsEuclideanRing( <R> )
##  
##  A ring $R$ is called a Euclidean ring if it is an integral ring and there
##  exists a function $\delta$, called the Euclidean degree, from $R-\{0_R\}$
##  to the nonnegative integers, such that for every pair $r \in R$ and
##  $s \in  R-\{0_R\}$ there exists an element $q$ such that either
##  $r - q s = 0_R$ or $\delta(r - q s) \< \delta( s )$.
##  The existence of this division with remainder implies that the Euclidean
##  algorithm can be applied to compute a greatest common divisor of two
##  elements, which in turn implies that $R$ is a unique factorization ring.
##
#T new category ``valuated domain''?
##
IsEuclideanRing := NewCategory( "IsEuclideanRing",
    IsRingWithOne and IsUniqueFactorizationRing );


#############################################################################
##
#P  IsAnticommutative( <R> )
##
##  is 'true' if the relation $a \* b = - b \* a$
##  holds for all elements $a$, $b$ in the ring <R>,
##  and 'false' otherwise.
##
IsAnticommutative := NewProperty( "IsAnticommutative", IsRing );
SetIsAnticommutative := Setter( IsAnticommutative );
HasIsAnticommutative := Tester( IsAnticommutative );

InstallSubsetMaintainedMethod( IsAnticommutative,
    IsRing and IsAnticommutative, IsRing );

InstallFactorMaintainedMethod( IsAnticommutative,
    IsRing and IsAnticommutative, IsRing, IsRing );


#############################################################################
##
#P  IsIntegralRing( <R> )
##
##  A ring-with-one <R> is integral if it is commutative, contains no
##  nontrivial zero divisors,
##  and if its identity is distinct from its zero.
##
IsIntegralRing := NewProperty( "IsIntegralRing", IsRing );
SetIsIntegralRing := Setter( IsIntegralRing );
HasIsIntegralRing := Tester( IsIntegralRing );

InstallSubsetMaintainedMethod( IsIntegralRing,
    IsRing and IsIntegralRing, IsRing and IsNonTrivial );

#T method that fetches this from the family if possible?

InstallTrueMethod( IsIntegralRing,
    IsRing and IsMagmaWithInversesIfNonzero and IsNonTrivial );
InstallTrueMethod( IsIntegralRing,
    IsUniqueFactorizationRing and IsNonTrivial );


#############################################################################
##
#P  IsJacobianRing( <R> )
##
##  is 'true' if and only if the Jacobi identity holds in <R>, that is,
##  $x \* y \* z + z \* x \* y + y \* z \* x$ is the zero element of <R>,
##  for all elements $x$, $y$, $z$ in <R>.
##
IsJacobianRing := NewProperty( "IsJacobianRing", IsRing );
SetIsJacobianRing := Setter( IsJacobianRing );
HasIsJacobianRing := Tester( IsJacobianRing );

InstallTrueMethod( IsJacobianRing,
    IsJacobianElementCollection and IsRing );

InstallSubsetMaintainedMethod( IsJacobianRing,
    IsRing and IsJacobianRing, IsRing );

InstallFactorMaintainedMethod( IsJacobianRing,
    IsRing and IsJacobianRing, IsRing, IsRing );


#############################################################################
##
#P  IsZeroSquaredRing( <R> )
##
##  is 'true' if $a \* a$ is the zero element of the ring <R>
##  for all $a$ in <R>, and 'false' otherwise.
##
IsZeroSquaredRing := NewProperty( "IsZeroSquaredRing", IsRing );
SetIsZeroSquaredRing := Setter( IsZeroSquaredRing );
HasIsZeroSquaredRing := Tester( IsZeroSquaredRing );

InstallTrueMethod( IsAnticommutative, IsRing and IsZeroSquaredRing );

InstallTrueMethod( IsZeroSquaredRing,
    IsZeroSquaredElementCollection and IsRing );

InstallSubsetMaintainedMethod( IsZeroSquaredRing,
    IsRing and IsZeroSquaredRing, IsRing );

InstallFactorMaintainedMethod( IsZeroSquaredRing,
    IsRing and IsZeroSquaredRing, IsRing, IsRing );


#############################################################################
##
#A  AsRing( <R> )
##
AsRing := NewAttribute( "AsRing", IsRingElementCollection );
SetAsRing := Setter( AsRing );
HasAsRing := Tester( AsRing );


#############################################################################
##
#A  GeneratorsOfRing( <R> )
##
GeneratorsOfRing := NewAttribute( "GeneratorsOfRing", IsRing );
SetGeneratorsOfRing := Setter( GeneratorsOfRing );
HasGeneratorsOfRing := Tester( GeneratorsOfRing );


#############################################################################
##
#A  GeneratorsOfRingWithOne( <R> )
##
GeneratorsOfRingWithOne := NewAttribute( "GeneratorsOfRingWithOne",
    IsRingWithOne );
SetGeneratorsOfRingWithOne := Setter( GeneratorsOfRingWithOne );
HasGeneratorsOfRingWithOne := Tester( GeneratorsOfRingWithOne );


#############################################################################
##
#A  Units( <R> )
##
##  'Units' returns the group of units of the ring <R>.
##  This may either be returned as a list or as a group.
##  
##  An element $r$ is called a *unit* of a ring $R$, if $r$ has an inverse in
##  $R$.
##  It is easy to see that the set of units forms a multiplicative group.
##  
Units := NewAttribute( "Units", IsRing );
SetUnits := Setter( Units );
HasUnits := Tester( Units );


#############################################################################
##
#O  ClosureRing( <R>, <r> )
#O  ClosureRing( <R>, <S> )
##
##  For a ring <R> and either an element <r> of its elements family or a ring
##  <S>, 'ClosureLeftOperatorRing' returns the ring generated by
##  both arguments.
##
ClosureRing := NewOperation( "ClosureRing",
    [ IsRing, IsObject ] );


#############################################################################
##
#O  Factors( <r> )
#O  Factors( <R>, <r> )
##
##  In the first form 'Factors' returns the factorization of the ring element
##  <r> in its default ring (see "DefaultRing").
##  In the second form 'Factors' returns the factorization of the ring
##  element <r> in the ring <R>.
##  The factorization is returned as a list of primes (see "IsPrime").
##  Each element in the list is a standard associate (see
##  "StandardAssociate") except the first one, which is multiplied by a unit
##  as necessary to have 'Product( Factors( <R>, <r> )  )  = <r>'.
##  This list is usually also sorted, thus smallest prime factors come first.
##  If <r> is a unit or zero, 'Factors( <R>, <r> ) = [ <r> ]'.
##  
Factors:= NewOperation( "Factors", [ IsRing, IsRingElement ] );
#T who does really need the additive structure?


#############################################################################
##
#O  IsAssociated( <r>, <s> )
#O  IsAssociated( <R>, <r>, <s> )
##
##  In the first form 'IsAssociated' returns 'true' if the two ring elements
##  <r> and <s> are associated in their default ring (see "DefaultRing") and
##  'false' otherwise.
##  In the second form 'IsAssociated' returns 'true' if the two ring elements
##  <r> and <s> are associated in the ring <R> and 'false' otherwise.
##  
##  Two elements $r$ and $s$ of a ring $R$ are called *associates* if there
##  is a unit $u$ of $R$ such that $r u = s$.
##  
IsAssociated := NewOperation( "IsAssociated",
    [ IsRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  Associates( <r> )
#O  Associates( <R>, <r> )
##  
##  In the first form 'Associates' returns the set of associates of the ring
##  element <r> in its default ring (see "DefaultRing").
##  In the second form 'Associates' returns the set of associates of <r> in
##  the ring <R>.
##  
##  Two elements $r$ and $s$ of a ring $R$ are called *associate* if there is
##  a unit $u$ of $R$ such that $r u = s$.
##  
Associates := NewOperation( "Associates",
    [ IsRing, IsRingElement ] );


#############################################################################
##
#F  Ideal( <R>, <gens> ) . . . . . two-sided ideal in <R> generated by <gens>
#F  LeftIdeal( <R>, <gens> ) . . . . .  left ideal in <R> generated by <gens>
#F  RightIdeal( <R>, <gens> )  . . . . right ideal in <R> generated by <gens>
##
##  is the two-sided resp. left resp. right ideal in the ring <R>
##  that is generated by <gens>, with parent <R>.
##
#F  Ideal( <R>, <gens>, "basis" )
#F  LeftIdeal( <R>, <gens>, "basis" )
#F  RightIdeal( <R>, <gens>, "basis" )
##
##  is the ideal in <R> for that <gens> is a list of basis vectors.
##  It is *not* checked whether <gens> really are linearly independent
##  and whether all in <gens> lie in <R>.
##
Ideal := NewOperationArgs( "Ideal" );
LeftIdeal := NewOperationArgs( "LeftIdeal" );
RightIdeal := NewOperationArgs( "RightIdeal" );


#############################################################################
##
#F  IdealNC( <R>, <gens>, "basis" )
#F  IdealNC( <R>, <gens> )
##
#F  LeftIdealNC( <R>, <gens>, "basis" )
#F  LeftIdealNC( <R>, <gens> )
##
#F  RightIdealNC( <R>, <gens>, "basis" )
#F  RightIdealNC( <R>, <gens> )
##
##  'IdealNC' does not check whether all in <gens> lie in <R>.
##
IdealNC := NewOperationArgs( "IdealNC" );
LeftIdealNC := NewOperationArgs( "LeftIdealNC" );
RightIdealNC := NewOperationArgs( "RightIdealNC" );


#############################################################################
##
#O  IsIdeal( <R>, <I> )
#O  IsLeftIdeal( <R>, <I> )
#O  IsRightIdeal( <R>, <I> )
##
IsIdeal:= NewOperation( "IsIdeal", [ IsRing, IsRing ] );
IsLeftIdeal:= NewOperation( "IsLeftIdeal", [ IsRing, IsRing ] );
IsRightIdeal:= NewOperation( "IsRightIdeal", [ IsRing, IsRing ] );


#############################################################################
##
#P  IsLeftIdealInParent( <R> )
##
IsLeftIdealInParent := NewProperty( "IsLeftIdealInParent", IsRing );
SetIsLeftIdealInParent := Setter( IsLeftIdealInParent );
HasIsLeftIdealInParent := Tester( IsLeftIdealInParent );


#############################################################################
##
#P  IsRightIdealInParent( <R> )
##
IsRightIdealInParent := NewProperty( "IsRightIdealInParent", IsRing );
SetIsRightIdealInParent := Setter( IsRightIdealInParent );
HasIsRightIdealInParent := Tester( IsRightIdealInParent );


#############################################################################
##
#P  IsIdealInParent( <R> )
##
IsIdealInParent := IsLeftIdealInParent and IsRightIdealInParent;
SetIsIdealInParent := Setter( IsIdealInParent );
HasIsIdealInParent := Tester( IsIdealInParent );


#############################################################################
##
#O  IdealByGenerators( <R>, <gens> )  . . .  ideal in <R> generated by <gens>
##
##  is a subring with parent <R> that knows that it is an ideal
##  in its parent and that has <gens> as ideal generators.
##
IdealByGenerators := NewOperation( "IdealByGenerators",
    [ IsRing, IsCollection ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  LeftIdealByGenerators( <R>, <gens> )
##
##  is a subring with parent <R> that knows that it is a left ideal
##  in its parent and that has <gens> as left ideal generators.
##
LeftIdealByGenerators := NewOperation( "LeftIdealByGenerators",
    [ IsRing, IsCollection ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  RightIdealByGenerators( <R>, <gens> )
##
##  is a subring with parent <R> that knows that it is a right ideal
##  in its parent and that has <gens> as right ideal generators.
##
RightIdealByGenerators := NewOperation( "RightIdealByGenerators",
    [ IsRing, IsCollection ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#A  GeneratorsOfIdeal( <I> )
##
##  is the list of generators for <I> as ideal in its parent.
##
GeneratorsOfIdeal:= NewAttribute( "GeneratorsOfIdeal", IsRing );
SetGeneratorsOfIdeal:= Setter( GeneratorsOfIdeal );
HasGeneratorsOfIdeal:= Tester( GeneratorsOfIdeal );


#############################################################################
##
#A  GeneratorsOfLeftIdeal( <I> )
##
##  is the list of generators for <I> as left ideal in its parent.
##
GeneratorsOfLeftIdeal:= NewAttribute( "GeneratorsOfLeftIdeal", IsRing );
SetGeneratorsOfLeftIdeal:= Setter( GeneratorsOfLeftIdeal );
HasGeneratorsOfLeftIdeal:= Tester( GeneratorsOfLeftIdeal );


#############################################################################
##
#A  GeneratorsOfRightIdeal( <I> )
##
##  is the list of generators for <I> as right ideal in its parent.
##
GeneratorsOfRightIdeal:= NewAttribute( "GeneratorsOfRightIdeal", IsRing );
SetGeneratorsOfRightIdeal:= Setter( GeneratorsOfRightIdeal );
HasGeneratorsOfRightIdeal:= Tester( GeneratorsOfRightIdeal );


#############################################################################
##
#O  IsUnit( <R>, <r> )  . . . . . . . . .  check whether <r> is a unit in <R>
#O  IsUnit( <r> ) . . . . . . check whether <r> is a unit in its default ring
##
##  In the first form 'IsUnit' returns 'true' if the ring element <r> is a
##  unit in its default ring (see "DefaultRing").
##  In the second form 'IsUnit' returns 'true' if <r> is a unit in the ring
##  <R>.
##  
##  An element $r$ is called a *unit* in a ring $R$, if $r$ has an inverse in
##  $R$.
##
##  'IsUnit' may call 'Quotient'.
##
IsUnit := NewOperation( "IsUnit", [ IsRing, IsRingElement ] );


#############################################################################
##
#O  InterpolatedPolynomial( <R>, <x>, <y> ) . . . . . . . . . . interpolation
##
##  'InterpolatedPolynomial' returns, for given lists <x>, <y> of elements in
##  a ring <R> of the same length $n$, say, the unique  polynomial of  degree
##  less than $n$ which has value <y>[i] at <x>[i], for all $i=1,...,n$. Note
##  that the elements in <x> must be distinct.
##
InterpolatedPolynomial := NewOperation( "InterpolatedPolynomial",
    [ IsRing, IsHomogeneousList, IsHomogeneousList ] );


#############################################################################
##
#O  Quotient( <r>, <s> )
#O  Quotient( <R>, <r>, <s> )
##
##  In the first form 'Quotient' returns the quotient of the two ring
##  elements <r> and <s> in  their default ring.
##  In the second form 'Quotient' returns the quotient of the two ring
##  elements <r> and <s> in the ring <R>.
##  It returns 'fail' if the quotient does not exist in the respective ring.
##  
##  (To perform the division in the quotient field of a ring, use the
##  quotient operator '/'.)
##
Quotient := NewOperation( "Quotient",
    [ IsRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  StandardAssociate( <r> )
#O  StandardAssociate( <R>, <r> )
##
##  In the first form 'StandardAssociate' returns the standard associate of
##  the ring element <r> in its default ring (see "DefaultRing").
##  In the second form 'StandardAssociate' returns the standard associate of
##  the ring element <r> in the ring <R>.
##  
##  The *standard associate* of a ring element $r$ of $R$ is an associated
##  element of $r$ which is, in a ring dependent way, distinguished among the
##  set of associates of $r$.
##  For example, in the ring of integers the standard associate is the
##  absolute value.
##  
StandardAssociate := NewOperation( "StandardAssociate",
    [ IsRing, IsRingElement ] );


#############################################################################
##
#O  IsPrime( <r> )
#O  IsPrime( <R>, <r> )
##
##  In the first form 'IsPrime' returns 'true' if the ring element <r> is a
##  prime in its default ring (see "DefaultRing") and 'false' otherwise.
##  In the second form 'IsPrime' returns 'true' if the ring element <r> is a
##  prime in the ring <R> and 'false' otherwise.
##  
##  An element $r$ of a ring $R$ is called *prime* if for each pair $s$ and
##  $t$ such that $r$ divides $s t$ the element $r$ divides either $s$ or
##  $t$.
##  Note that there are rings where not every irreducible element
##  (see "IsIrreducible") is a prime.
##
IsPrime := NewOperation( "IsPrime", [ IsRing, IsRingElement ] );


#############################################################################
##
#O  IsIrreducible( <r> )
#O  IsIrreducible( <R>, <r> )
##
##  In the first form 'IsIrreducible' returns 'true' if the ring element <r>
##  is irreducible in its default ring (see "DefaultRing") and 'false'
##  otherwise.
##  In the second form 'IsIrreducible' returns 'true' if the ring element <r>
##  is irreducible in the ring <R> and 'false' otherwise.
##  
##  An element $r$ of a ring $R$ is called *irreducible* if there is no
##  nontrivial factorization of $r$ in $R$, i.e., if there is no
##  representation of $r$ as product $s t$ such that neither $s$ nor $t$ is a
##  unit (see "IsUnit").
##  Each prime element (see "IsPrime") is irreducible.
##  
IsIrreducible := NewOperation( "IsIrreducible", [ IsRing, IsRingElement ] );


#############################################################################
##
#O  EuclideanDegree( <r> )
#O  EuclideanDegree( <R>, <r> )
##
##  In the first form 'EuclideanDegree' returns the Euclidean degree of the
##  ring element <r> in its default ring.
##  In the second form 'EuclideanDegree' returns the Euclidean degree of the
##  ring element in the ring <R>.
##  <R> must of course be a Euclidean ring (see "IsEuclideanRing").
##  
EuclideanDegree := NewOperation( "EuclideanDegree",
    [ IsEuclideanRing, IsRingElement ] );


#############################################################################
##
#O  EuclideanRemainder( <r>, <m> )
#O  EuclideanRemainder( <R>, <r>, <m> )
##
##  In the first form 'EuclideanRemainder' returns the remainder of the ring
##  element <r> modulo the ring element <m> in their default ring.
##  In the second form 'EuclideanRemainder' returns the remainder of the ring
##  element <r> modulo the ring element <m> in the ring <R>.
##  The ring <R> must be a Euclidean ring (see "IsEuclideanRing") otherwise
##  an error is signalled.
##  
EuclideanRemainder := NewOperation( "EuclideanRemainder",
    [ IsEuclideanRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  EuclideanQuotient( <r>, <m> )
#O  EuclideanQuotient( <R>, <r>, <m> )
##
##  In the first form 'EuclideanQuotient' returns the Euclidean quotient of
##  the ring elements <r> and <m> in their default ring.
##  In the second form 'EuclideanQuotient' returns the Euclidean quotient of
##  the ring elements <r>and <m> in the ring <R>.
##  The ring <R> must be a Euclidean ring (see "IsEuclideanRing") otherwise
##  an error is signalled.
##  
EuclideanQuotient := NewOperation( "EuclideanQuotient",
    [ IsEuclideanRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  QuotientRemainder( <r>, <s> )
#O  QuotientRemainder( <R>, <r>, <s> )
##
##  In the first form 'QuotientRemainder' returns the Euclidean quotient and
##  the Euclidean remainder of the ring elements <r> and <m> in their default
##  ring as pair of ring elements.
##  In the second form 'QuotientRemainder' returns the Euclidean quotient
##  and the Euclidean remainder of the ring elements <r> and <m> in the ring
##  <R>.
##  The ring <R> must be a Euclidean ring (see "IsEuclideanRing") otherwise
##  an error is signalled.
##  
QuotientRemainder := NewOperation( "QuotientRemainder",
    [ IsRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  QuotientMod( <r>, <s>, <m> )
#O  QuotientMod( <R>, <r>, <s>, <m> )
##
##  In the first form 'QuotientMod' returns the quotient of the ring elements
##  <r> and  <s> modulo the ring element <m> in their default ring (see
##  "DefaultRing").
##  In the second form 'QuotientMod' returns the quotient of the ring
##  elements <r> and <s> modulo the ring element <m> in the ring <R>.
##  <R> must be a Euclidean ring (see "IsEuclideanRing") so that
##  'EuclideanRemainder' (see "EuclideanRemainder") can be applied.
##  If the modular quotient does not exist, 'fail' is returned.
##  
##  The quotient $q$ of $r$ and $s$ modulo $m$ is an element of $R$ such that
##  $q s = r$ modulo $m$, i.e., such that $q s - r$ is divisible by $m$ in
##  $R$ and that $q$ is either 0 (if $r$ is divisible by $m$) or the
##  Euclidean degree of $q$ is strictly smaller than the Euclidean degree of
##  $m$.
##  
QuotientMod := NewOperation( "QuotientMod",
    [ IsRing, IsRingElement, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  PowerMod( <r>, <e>, <m> )
#O  PowerMod( <R>, <r>, <e>, <m> )
##
##  In the first form 'PowerMod' returns the <e>-th power of the ring element
##  <r> modulo the ring element <m> in their default ring (see
##  "DefaultRing").
##  In the second form 'PowerMod' returns the <e>-th power of the ring
##  element <r> modulo the ring element <m> in the ring <R>.
##  <e> must be an integer.
##  <R> must be a Euclidean ring (see "IsEuclideanRing") so that
##  'EuclideanRemainder' (see "EuclideanRemainder") can be applied to its
##  elements.
##  
##  If $e$ is positive the result is $r^e$ modulo $m$.
##  If $e$ is negative then 'PowerMod' first tries to find the inverse of $r$
##  modulo $m$, i.e., $i$ such that $i r = 1$ modulo $m$.
##  If the inverse does not exist an error is signalled.
##  If the inverse does exist 'PowerMod' returns
##  'PowerMod( <R>, <i>, -<e>, <m> )'.
##  
##  'PowerMod' reduces the intermediate values modulo $m$, improving
##  performance drastically when <e> is large and <m> small.
##  
PowerMod := NewOperation( "PowerMod",
    [ IsRing, IsRingElement, IsInt, IsRingElement ] );


#############################################################################
##
#F  Gcd( <r1>, <r2>, ... )
#F  Gcd( <list> )
#F  Gcd( <R>, <r1>, <r2>, ... )
#F  Gcd( <R>, <list> )
##
##  In the first two forms 'Gcd' returns the greatest common divisor of the
##  ring elements `<r1>, <r2>, ...' resp. of the ring elements in the list
##  <list> in their default ring (see "DefaultRing").
##  In the second two forms 'Gcd' returns the greatest common divisor of the
##  ring elements `<r1>, <r2>, ...' resp. of the ring elements in the list
##  <list> in the ring <R>.
##  <R> must be a Euclidean ring (see "IsEuclideanRing") so that
##  'QuotientRemainder' (see "QuotientRemainder") can be applied to its
##  elements.
##  'Gcd' returns the standard associate (see "StandardAssociate") of the
##  greatest common divisors.
##  
##  A greatest common divisor of the elements $r_1$, $r_2$... etc. of the
##  ring $R$ is an element of largest Euclidean degree (see
##  "EuclideanDegree") that is a divisor of $r_1$, $r_2$... etc.
##  We define $gcd( r, 0_R ) = gcd( 0_R, r ) = StandardAssociate( r )$
##  and $gcd( 0_R, 0_R ) = 0_R$.
##  
#O  GcdOp( <r>, <s> )
#O  GcdOp( <R>, <r>, <s> )
##
##  `GcdOp' is the operation to compute the greatest common divisor of
##  two ring elements <r>, <s> in their default ring or in the ring <R>.
##
Gcd := NewOperationArgs( "Gcd" );

GcdOp := NewOperation( "GcdOp",
    [ IsEuclideanRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#F  GcdRepresentation( <r1>, <r2>, ... )
#F  GcdRepresentation( <list> )
#F  GcdRepresentation( <R>, <r1>, <r2>, ... )
#F  GcdRepresentation( <R>, <list> )
##
##  In the first two forms 'GcdRepresentation' returns the representation of
##  the greatest common divisor of the ring elements `<r1>, <r2>, ...' resp.
##  of the ring elements in the list <list> in their default ring
##  (see "DefaultRing").
##  In the second two forms 'GcdRepresentation' returns the representation of
##  the greatest common divisor of the ring elements `<r1>, <r2>, ...' resp.
##  of the ring elements in the list <list> in the ring <R>.
##  <R> must be a Euclidean ring (see "IsEuclideanRing") so that
##  'Gcd' (see "Gcd") can be applied to its elements.
##  
##  The representation of the gcd  $g$ of  the elements $r_1$, $r_2$...  etc.
##  of a ring $R$ is a list of ring elements $s_1$, $s_2$... etc. of $R$,
##  such that $g = s_1 r_1 + s_2  r_2 ...$.
##  That this representation exists can be shown using the Euclidean
##  algorithm, which in fact can compute those coefficients.
##  
#O  GcdRepresentationOp( <r>, <s> )
#O  GcdRepresentationOp( <R>, <r>, <s> )
##
##  `GcdRepresentationOp' is the operation to compute the representation of
##  the greatest common divisor of two ring elements <r>, <s> in their
##  default ring or in the ring <R>.
##
GcdRepresentation := NewOperationArgs( "GcdRepresentation" );

GcdRepresentationOp := NewOperation( "GcdRepresentationOp",
    [ IsEuclideanRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#F  Lcm( <r1>, <r2>, ... )
#F  Lcm( <list> )
#F  Lcm( <R>, <r1>, <r2>, ... )
#F  Lcm( <R>, <list> )
##
##  In the first two forms 'Lcm' returns the least common multiple of the
##  ring elements `<r1>, <r2>, ...' resp. of the ring elements in the list
##  <list> in their default ring (see "DefaultRing").
##  In the second two forms 'Lcm' returns the least common multiple of the
##  ring elements `<r1>, <r2>, ...' resp. of the ring elements in the list
##  <list> in the ring <R>.
##
##  <R> must be a Euclidean ring (see "IsEuclideanRing") so that 'Gcd'
##  (see "Gcd") can be applied to its elements.
##  'Lcm' returns the standard associate (see "StandardAssociate") of the
##  least common multiples.
##  
##  A least common multiple of the elements $r_1$, $r_2$... etc. of the
##  ring $R$ is an element of smallest Euclidean degree
##  (see "EuclideanDegree") that is a multiple of $r_1$, $r_2$... etc.
##  We define $lcm( r, 0_R ) = lcm( 0_R, r ) = StandardAssociate( r )$
##  and $Lcm( 0_R, 0_R ) = 0_R$.
##  
##  'Lcm' uses the equality $lcm(m,n) = m\*n / gcd(m,n)$ (see "Gcd").
##  
#O  LcmOp( <r>, <s> )
#O  LcmOp( <R>, <r>, <s> )
##
##  `LcmOp' is the operation to compute the least common multiple of
##  two ring elements <r>, <s> in their default ring or in the ring <R>.
##
Lcm := NewOperationArgs( "Lcm" );

LcmOp := NewOperation( "LcmOp",
    [ IsEuclideanRing, IsRingElement, IsRingElement ] );


#############################################################################
##
#O  RingByGenerators( [ <z>, ... ] )  . .  ring gener. by elements in a coll.
##
RingByGenerators := NewOperation( "RingByGenerators",
    [ IsCollection ] );


#############################################################################
##
#O  DefaultRingByGenerators( [ <z>, ... ] ) . default ring containing a coll.
##
DefaultRingByGenerators := NewOperation( "DefaultRingByGenerators",
    [ IsCollection ] );


#############################################################################
##
#F  Ring( <r> ,<s>, ... )  . . . . . . . . . . ring generated by a collection
#F  Ring( <coll> ) . . . . . . . . . . . . . . ring generated by a collection
##
##  In the first form 'Ring' returns the smallest ring that
##  contains all the elements <r>, <s>... etc.
##  In the second form 'Ring' returns the smallest ring that
##  contains all the elements in the collection <coll>.
##  If any element is not an element of a ring or if the elements lie in no
##  common ring an error is raised.
##  
##  'Ring' differs from 'DefaultRing' (see "DefaultRing") in that it returns
##  the smallest ring in which the elements lie, while 'DefaultRing' may
##  return a larger ring if that makes sense.
##
Ring := NewOperationArgs( "Ring" );


#############################################################################
##
#O  RingWithOneByGenerators( [ <z>, ... ] )
##
RingWithOneByGenerators := NewOperation( "RingWithOneByGenerators",
    [ IsCollection ] );


#############################################################################
##
#F  RingWithOne( <r>, <s>, ... )  . . ring-with-one generated by a collection
#F  RingWithOne( <coll> ) . . . . . . ring-with-one generated by a collection
##
##  In the first form 'RingWithOne' returns the smallest ring with one that
##  contains all the elements <r>, <s>... etc.
##  In the second form 'RingWithOne' returns the smallest ring with one that
##  contains all the elements in the collection <coll>.
##  If any element is not an element of a ring or if the elements lie in no
##  common ring an error is raised.
##  
RingWithOne := NewOperationArgs( "RingWithOne" );


#############################################################################
##
#F  DefaultRing( <r> ,<s>, ... )  . . .  default ring containing a collection
#F  DefaultRing( <coll> ) . . . . . . .  default ring containing a collection
##
##  In the first form 'DefaultRing' returns a ring that contains
##  all the elements <r>, <s>, ... etc.
##  In the second form 'DefaultRing' returns a ring that contains
##  all the elements in the collection <coll>.
##  If any element is not an element of a ring or if the elements lie in no
##  common ring an error is raised.
##  
##  The ring returned by 'DefaultRing' need not be the smallest ring in which
##  the elements lie.
##  For example for elements from cyclotomic fields 'DefaultRing' may return
##  the ring of integers of the smallest cyclotomic field in which the elements
##  lie, which need not be the smallest ring overall, because the elements may
##  in fact lie in a smaller number field which is not a cyclotomic field.
##  
##  (For the exact definition of the default ring of a certain type of elements
##  look at the corresponding method installation.)
##  
##  'DefaultRing' is used by the ring functions like 'Quotient', 'IsPrime',
##  'Factors', or 'Gcd' if no explicit ring is given.
##  
##  'Ring' (see "Ring") differs from 'DefaultRing' in that it returns the
##  smallest ring in which the elements lie, while 'DefaultRing' may return a
##  larger ring if that makes sense.
##
DefaultRing := NewOperationArgs( "DefaultRing" );


#############################################################################
##
#F  Subring( <R>, <gens> ) . . . . . . . . subring of <R> generated by <gens>
#F  SubringNC( <R>, <gens> ) . . . . . . . subring of <R> generated by <gens>
##
Subring := NewOperationArgs( "Subring" );
SubringNC := NewOperationArgs( "SubringNC" );


#############################################################################
##
#F  SubringWithOne( <R>, <gens> )   .  subring-with-one of <R> gen. by <gens>
#F  SubringWithOneNC( <R>, <gens> ) .  subring-with-one of <R> gen. by <gens>
##
SubringWithOne := NewOperationArgs( "SubringWithOne" );
SubringWithOneNC := NewOperationArgs( "SubringWithOneNC" );


#############################################################################
##
#E  ring.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



