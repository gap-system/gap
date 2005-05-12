#############################################################################
##
#W  ctblmono.gd                 GAP library                     Thomas Breuer
#W                                                         & Erzsebet Horvath
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations of the functions dealing with
##  monomiality questions for finite (solvable) groups.
##
##  1. Character Degrees and Derived Length
##  2. Primitivity of Characters
##  3. Testing Monomiality
##  4. Minimal Nonmonomial Groups

#1
##  All these functions assume *characters* to be class function objects
##  as described in Chapter~"Class Functions",
##  lists of character *values* are not allowed.
##
##  The usual *property tests* of {\GAP} that return either `true'
##  or `false' are not sufficient for us.
##  When we ask whether a group character $\chi$ has a certain property,
##  such as quasiprimitivity,
##  we usually want more information than just yes or no.
##  Often we are interested in the reason *why* a group character $\chi$ was
##  proved to have a certain property,
##  e.g., whether monomiality of $\chi$ was proved by the observation
##  that the underlying group is nilpotent,
##  or whether it was necessary to construct a linear character of a subgroup
##  from which $\chi$ can be induced.
##  In the latter case we also may be interested in this linear character.
##  Therefore we need test functions that return a record containing such
##  useful information.
##  For example, the record returned by the function `TestQuasiPrimitive'
##  (see~"TestQuasiPrimitive") contains the component `isQuasiPrimitive'
##  (which is the known boolean property flag),
##  and additionally the component `comment',
##  a string telling the reason for the value of the `isQuasiPrimitive'
##  component,
##  and in the case that the argument $\chi$ was *not* quasiprimitive
##  also the component `character',
##  which is an irreducible constituent of a nonhomogeneous restriction
##  of $\chi$ to a normal subgroup.
##  Besides these test functions there are also the known properties,
##  e.g., the property `IsQuasiPrimitive' which will call the attribute
##  `TestQuasiPrimitive',
##  and return the value of the `isQuasiPrimitive' component of the result.
##
##  A few words about how to use the monomiality functions seem to be
##  necessary.
##  Monomiality questions usually involve computations in many subgroups
##  and factor groups of a given group,
##  and for these groups often expensive calculations such as that of
##  the character table are necessary.
##  So one should be careful not to construct the same group over and over
##  again, instead the same group object should be reused,
##  such that its character table need to be computed only once.
##  For example,
##  suppose you want to restrict a character to a normal subgroup
##  $N$ that was constructed as a normal closure of some group elements,
##  and suppose that you have already computed with normal subgroups
##  (by calls to `NormalSubgroups' or `MaximalNormalSubgroups')
##  and their character tables.
##  Then you should look in the lists of known normal subgroups
##  whether $N$ is contained,
##  and if so you can use the known character table.
##  A mechanism that supports this for normal subgroups is described in
##  "Storing Normal Subgroup Information".
##
##  Also the following hint may be useful in this context.
##  If you know that sooner or later you will compute the character table of
##  a group $G$ then it may be advisable to compute it as soon as possible.
##  For example, if you need the normal subgroups of $G$ then they can be
##  computed more efficiently if the character table of $G$ is known,
##  and they can be stored compatibly to the contained $G$-conjugacy classes.
##  This correspondence of classes list and normal subgroup can be used very
##  often.
##
Revision.ctblmono_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  InfoMonomial
##
##  Most of the functions described in this chapter print some
##  (hopefully useful) *information* if the info level of the info class
##  `InfoMonomial' is at least 1 (see~"Info Functions" for details).
##
DeclareInfoClass( "InfoMonomial" );


#############################################################################
##
##  1. Character Degrees and Derived Length
##


#############################################################################
##
#A  Alpha( <G> )
##
##  For a group <G>, `Alpha' returns a list whose <i>-th entry is the maximal
##  derived length of groups $<G> / \ker(\chi)$ for $\chi\in Irr(<G>)$ with
##  $\chi(1)$ at most the <i>-th irreducible degree of <G>.
##
DeclareAttribute( "Alpha", IsGroup );


#############################################################################
##
#A  Delta( <G> )
##
##  For a group <G>, `Delta' returns the list
##  `[ 1, alp[2] - alp[1], ..., alp[<n>] - alp[<n>-1] ]',
##  where `alp = Alpha( <G> )' (see~"Alpha").
##
DeclareAttribute( "Delta", IsGroup );


#############################################################################
##
#P  IsBergerCondition( <G> )
#P  IsBergerCondition( <chi> )
##
##  Called with an irreducible character <chi> of the group $G$,
##  `IsBergerCondition' returns `true' if <chi> satisfies
##  $M^{\prime} \leq \ker(\chi)$ for every normal subgroup $M$ of $G$
##  with the property that $M \leq \ker(\psi)$ for all $\psi \in Irr(G)$ with
##  $\psi(1) \< \chi(1)$,
##  and `false' otherwise.
##
##  Called with a group <G>, `IsBergerCondition' returns `true' if
##  all irreducible characters of <G> satisfy the inequality above,
##  and `false' otherwise.
##
##  For groups of odd order the result is always `true' by a theorem of
##  T.~R.~Berger (see~\cite{Ber76}, Thm.~2.2).
##
##  In the case that `false' is returned `InfoMonomial' tells about a
##  degree for which the inequality is violated.
##
DeclareProperty( "IsBergerCondition", IsGroup );
DeclareProperty( "IsBergerCondition", IsClassFunction );


#############################################################################
##
##  2. Primitivity of Characters
##


#############################################################################
##
#F  TestHomogeneous( <chi>, <N> )
##
##  For a group character <chi> of the group $G$, say, and a normal subgroup
##  <N> of $G$,
##  `TestHomogeneous' returns a record with information whether the
##  restriction of <chi> to <N> is homogeneous,
##  i.e., is a multiple of an irreducible character.
##
##  <N> may be given also as list of conjugacy class positions w.r.t.~the
##  character table of $G$.
##
##  The components of the result are
##
##  \beginitems
##  `isHomogeneous' & `true' or `false',
##
##  `comment' & a string telling a reason for the value of the
##                       `isHomogeneous' component,
##
##  `character' & irreducible constituent of the restriction, only
##                       bound if the restriction had to be checked,
##
##  `multiplicity' & multiplicity of the `character' component in the
##                       restriction of <chi>.
##  \enditems
##
DeclareGlobalFunction( "TestHomogeneous" );


#############################################################################
##
#P  IsPrimitiveCharacter( <chi> )
##
##  For a character <chi> of the group $G$, say,
##  `IsPrimitiveCharacter' returns `true' if <chi> is not induced from any
##  proper subgroup, and `false' otherwise.
##
DeclareProperty( "IsPrimitiveCharacter", IsClassFunction );


#############################################################################
##
#A  TestQuasiPrimitive( <chi> )
#P  IsQuasiPrimitive( <chi> )
##
##  `TestQuasiPrimitive' returns a record with information about
##  quasiprimitivity of the group character <chi>,
##  i.e., whether <chi> restricts homogeneously to every normal subgroup
##  of its group.
##  The result record contains at least the components
##  `isQuasiPrimitive' (with value either `true' or `false') and
##  `comment' (a string telling a reason for the value of the component
##  `isQuasiPrimitive').
##  If <chi> is not quasiprimitive then there is additionally a component
##  `character', with value an irreducible constituent of a nonhomogeneous
##  restriction of <chi>.
##
##  `IsQuasiPrimitive' returns `true' or `false',
##  depending on whether the character <chi> is quasiprimitive.
##
##  Note that for solvable groups, quasiprimitivity is the same as
##  primitivity (see~"IsPrimitiveCharacter").
##
DeclareAttribute( "TestQuasiPrimitive", IsClassFunction );

DeclareProperty( "IsQuasiPrimitive", IsClassFunction );


#############################################################################
##
#F  TestInducedFromNormalSubgroup( <chi>[, <N>] )
#P  IsInducedFromNormalSubgroup( <chi> )
##
##  `TestInducedFromNormalSubgroup' returns a record with information
##  whether the irreducible character <chi> of the group $G$, say,
##  is induced from a proper normal subgroup of $G$.
##  If the second argument <N> is present, which must be a normal subgroup of
##  $G$ or the list of class positions of a normal subgroup of $G$,
##  it is checked whether <chi> is induced from <N>.
##
##  The result contains always the components
##  `isInduced' (either `true' or `false') and
##  `comment' (a string telling a reason for the value of the component
##  `isInduced').
##  In the `true' case there is a  component `character' which
##  contains a character of a maximal normal subgroup from which <chi> is
##  induced.
##
##  `IsInducedFromNormalSubgroup' returns `true' if <chi> is induced from a
##  proper normal subgroup of $G$, and `false' otherwise.
##
DeclareGlobalFunction( "TestInducedFromNormalSubgroup" );

DeclareProperty( "IsInducedFromNormalSubgroup", IsClassFunction );


#############################################################################
##
##  3. Testing Monomiality
#2
##  A character $\chi$ of a finite group $G$ is called *monomial* if $\chi$
##  is induced from a linear character of a subgroup of $G$.
##  A finite group $G$ is called *monomial* (or *$M$-group*) if each
##  ordinary irreducible character of $G$ is monomial.
##
##  There are {\GAP} properties `IsMonomialGroup' (see~"IsMonomialGroup")
##  and `IsMonomialCharacter', but one can use `IsMonomial' instead.
##  \indextt{IsMonomial!for groups}\indextt{IsMonomial!for characters}
##


#############################################################################
##
#P  IsMonomialCharacter( <chi> )
##
##  is `true' if the character <chi> is induced from a linear character of a
##  subgroup, and `false' otherwise.
##
DeclareProperty( "IsMonomialCharacter", IsClassFunction );


#############################################################################
##
#P  IsMonomialNumber( <n> )
##
##  For a positive integer <n>, `IsMonomialNumber' returns `true' if every
##  solvable group of order <n> is monomial, and `false' otherwise.
##  One can also use `IsMonomial' instead.
##  \indextt{IsMonomial!for positive integers}
##
##  Let $\nu_p(n)$ denote the multiplicity of the prime $p$ as
##  factor of $n$, and $ord(p,q)$ the multiplicative order of $p \pmod{q}$.
##
##  Then there exists a solvable nonmonomial group of order $n$
##  if and only if one of the following conditions is satisfied.
##
##  \beginlist
##  \item{1.}
##       $\nu_2(n) \geq 2$ and there is a $p$ such that
##       $\nu_p(n) \geq 3$ and $p \equiv -1 \pmod{4}$,
##
##  \item{2.}
##       $\nu_2(n) \geq 3$ and there is a $p$ such that
##       $\nu_p(n) \geq 3$ and $p \equiv  1 \pmod{4}$,
##
##  \item{3.}
##       there are odd prime divisors $p$ and $q$ of $n$ such that
##       $ord(p,q)$ is even and $ord(p,q) \< \nu_p(n)$
##       (especially $\nu_p(n) \geq 3$),
##
##  \item{4.}
##       there is a prime divisor $q$ of $n$ such that
##       $\nu_2(n) \geq 2 ord(2,q) + 2$
##       (especially $\nu_2(n) \geq 4$),
##
##  \item{5.}
##       $\nu_2(n) \geq 2$ and there is a $p$ such that
##       $p \equiv  1 \pmod{4}$, $ord(p,q)$ is odd,
##       and $2 ord(p,q) \< \nu_p(n)$
##       (especially $\nu_p(n) \geq 3$).
##  \endlist
##
##  These five possibilities correspond to the five types of solvable minimal
##  nonmonomial groups (see~"MinimalNonmonomialGroup") that can occur as
##  subgroups and factor groups of groups of order <n>.
##
DeclareProperty( "IsMonomialNumber", IsPosInt );


#############################################################################
##
#A  TestMonomialQuick( <chi> )
#A  TestMonomialQuick( <G> )
##
##  `TestMonomialQuick' does some cheap tests whether the irreducible
##  character <chi> resp.~the group <G> is monomial.
##  Here ``cheap'' means in particular that no computations of character
##  tables are involved.
##  The return value is a record with components
##  \beginitems
##  `isMonomial' & either `true' or `false' or the string `\"?\"',
##       depending on whether (non)monomiality could be proved, and
##
##  `comment' & a string telling the reason for the value of the
##       `isMonomial' component.
##  \enditems
##
##  A group <G> is proved to be monomial by `TestMonomialQuick' if
##  <G> is nilpotent or Sylow abelian by supersolvable,
##  or if <G> is solvable and its order is not divisible by the third power
##  of a prime,
##  Nonsolvable groups are proved to be nonmonomial by `TestMonomialQuick'.
##
##  An irreducible character <chi> is proved to be monomial if
##  it is linear, or if its codegree is a prime power,
##  or if its group knows to be monomial,
##  or if the factor group modulo the kernel can be proved to be monomial by
##  `TestMonomialQuick'.
##
DeclareAttribute( "TestMonomialQuick", IsClassFunction );
DeclareAttribute( "TestMonomialQuick", IsGroup );


#############################################################################
##
#A  TestMonomial( <chi> )
#A  TestMonomial( <G> )
#O  TestMonomial( <chi>, <uselattice> )
#O  TestMonomial( <G>, <uselattice> )
##
##  Called with a group character <chi> of a group <G>, `TestMonomial'
##  returns a record containing information about monomiality of the group
##  <G> or the group character <chi>, respectively.
##
##  If `TestMonomial' proves the character <chi> to be monomial then
##  the result contains components `isMonomial' (with value `true'),
##  `comment' (a string telling a reason for monomiality),
##  and if it was necessary to compute a linear character from which <chi> is
##  induced, also a component `character'.
##
##  If `TestMonomial' proves <chi> or <G> to be nonmonomial then the value of
##  the component `isMonomial' is `false',
##  and in the case of <G> a nonmonomial character is the value
##  of the component `character' if it had been necessary to compute it.
##
##  A Boolean can be entered as the second argument <uselattice>;
##  if the value is `true' then the subgroup lattice of the underlying group
##  is used if necessary,
##  if the value is `false' then the subgroup lattice is used only for groups
##  of order at most `TestMonomialUseLattice' (see~"TestMonomialUseLattice").
##  The default value of <uselattice> is `false'.
##
##  For a group whose lattice must not be used, it may happen that 
##  `TestMonomial' cannot prove or disprove monomiality; then the result
##  record contains the component `isMonomial' with value `\"?\"'.
##  This case occurs in the call for a character <chi> if and only if
##  <chi> is not induced from the inertia subgroup of a component of any
##  reducible restriction to a normal subgroup.
##  It can happen that <chi> is monomial in this situation.
##  For a group, this case occurs if no irreducible character can be proved
##  to be nonmonomial, and if no decision is possible for at least one
##  irreducible character.
##
DeclareAttribute( "TestMonomial", IsClassFunction );
DeclareAttribute( "TestMonomial", IsGroup );
DeclareOperation( "TestMonomial", [ IsClassFunction, IsBool ] );
DeclareOperation( "TestMonomial", [ IsGroup, IsBool ] );


#############################################################################
##
#V  TestMonomialUseLattice
##
##  This global variable controls for which groups the operation
##  `TestMonomial' (see~"TestMonomial") may compute the subgroup lattice.
##  The value can be set to a positive integer or `infinity',
##  the default is $1000$.
##
TestMonomialUseLattice := 1000;


#############################################################################
##
#A  TestSubnormallyMonomial( <G> )
#A  TestSubnormallyMonomial( <chi> )
#P  IsSubnormallyMonomial( <G> )
#P  IsSubnormallyMonomial( <chi> )
##
##  A character of the group $G$ is called *subnormally monomial*
##  (SM for short) if it is induced from a linear character of a subnormal
##  subgroup of $G$.
##  A group $G$ is called SM if all its irreducible characters are SM.
##
##  `TestSubnormallyMonomial' returns a record with information whether the
##  group <G> or the irreducible character <chi> of <G> is SM.
##
##  The result has components
##  `isSubnormallyMonomial' (either `true' or `false') and
##  `comment' (a string telling a reason for the value of the component
##  `isSubnormallyMonomial');
##  in the case that the `isSubnormallyMonomial' component has value `false'
##  there is also a component `character',
##  with value an irreducible character of $G$ that is not SM.
##
##  `IsSubnormallyMonomial' returns `true' if the group <G> or the
##  group character <chi> is subnormally monomial, and `false' otherwise.
##
DeclareAttribute( "TestSubnormallyMonomial", IsGroup );
DeclareAttribute( "TestSubnormallyMonomial", IsClassFunction );

DeclareProperty( "IsSubnormallyMonomial", IsGroup );
DeclareProperty( "IsSubnormallyMonomial", IsClassFunction );


#############################################################################
##
#A  TestRelativelySM( <G> )
#A  TestRelativelySM( <chi> )
#O  TestRelativelySM( <G>, <N> )
#O  TestRelativelySM( <chi>, <N> )
#P  IsRelativelySM( <chi> )
#P  IsRelativelySM( <G> )
##
##  In the first two cases, `TestRelativelySM' returns a record with
##  information whether the argument, which must be a SM group <G> or
##  an irreducible character <chi> of a SM group $G$,
##  is relatively SM with respect to every normal subgroup of <G>.
##
##  In the second two cases, a normal subgroup <N> of <G> is the second
##  argument.
##  Here `TestRelativelySM' returns a record with information whether the
##  first argument is relatively SM with respect to <N>,
##  i.e, whether there is a subnormal subgroup $H$ of $G$ that contains <N>
##  such that the character <chi> resp.~every irreducible character of $G$
##  is induced from a character $\psi$ of $H$ such that the restriction of
##  $\psi$ to <N> is irreducible.
##
##  The result record has the components
##  `isRelativelySM' (with value either `true' or `false') and
##  `comment' (a string that describes a reason).
##  If the argument is a group <G> that is not relatively SM with respect to
##  a normal subgroup then additionally the component `character' is bound,
##  with value a not relatively SM character of such a normal subgroup.
##
##  `IsRelativelySM' returns `true' if the SM group <G> or the irreducible
##  character <chi> of the SM group <G> is relatively SM with respect to
##  every normal subgroup of <G>, and `false' otherwise.
##
##  *Note* that it is *not* checked whether <G> is SM.
##
DeclareAttribute( "TestRelativelySM", IsGroup );
DeclareAttribute( "TestRelativelySM", IsClassFunction );

DeclareOperation( "TestRelativelySM", [ IsClassFunction, IsGroup ] );
DeclareOperation( "TestRelativelySM", [ IsGroup, IsGroup ] );

DeclareProperty( "IsRelativelySM", IsClassFunction );
DeclareProperty( "IsRelativelySM", IsGroup );


#############################################################################
##
##  4. Minimal Nonmonomial Groups
##

#############################################################################
##
#P  IsMinimalNonmonomial( <G> )
##
##  A group <G> is called *minimal nonmonomial* if it is nonmonomial,
##  and all proper subgroups and factor groups are monomial.
##
DeclareProperty( "IsMinimalNonmonomial", IsGroup );


#############################################################################
##
#F  MinimalNonmonomialGroup( <p>, <factsize> )
##
##  is a solvable minimal nonmonomial group described by the parameters
##  <factsize> and <p> if such a group exists, and `false' otherwise.
##
##  Suppose that the required group $K$ exists.
##  Then <factsize> is the size of the Fitting factor $K / F(K)$,
##  and this value is 4, 8, an odd prime, twice an odd prime,
##  or four times an odd prime.
##  In the case that <factsize> is twice an odd prime, the centre $Z(K)$ is
##  cyclic of order $2^{<p>+1}$.
##  In all other cases <p> is the (unique) prime that divides
##  the order of $F(K)$.
##
##  The solvable minimal nonmonomial groups were classified by van der Waall,
##  see~\cite{vdW76}.
##
DeclareGlobalFunction( "MinimalNonmonomialGroup" );


#############################################################################
##
#E

