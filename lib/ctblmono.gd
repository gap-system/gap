#############################################################################
##
#W  ctblmono.gd                 GAP library                     Thomas Breuer
#W                                                         & Erzsebet Horvath
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of the functions dealing with
##  monomiality questions for solvable groups.
##
Revision.ctblmono_gd :=
    "@(#)$Id$";


#############################################################################
##
#V  InfoMonomial
##
InfoMonomial := NewInfoClass( "InfoMonomial" );


#############################################################################
##
#A  Alpha( <G> )
##
##  For a group <G>, 'Alpha' returns a list whose <i>-th entry is the maximal
##  derived length of groups $<G> / \ker(\chi)$ for $\chi\in Irr(<G>)$ with
##  $\chi(1)$ at most the <i>-th irreducible degree of <G>.
##
Alpha := NewAttribute( "Alpha", IsGroup );
SetAlpha := Setter( Alpha );
HasAlpha := Tester( Alpha );


#############################################################################
##
#A  Delta( <G> )
##
##  is the list '[ 1, alp[2] - alp[1], ..., alp[<n>] - alp[<n>-1] ]',
##  where 'alp = Alpha( <G> )'.
##
Delta := NewAttribute( "Delta", IsGroup );
SetDelta := Setter( Delta );
HasDelta := Tester( Delta );


#############################################################################
##
#P  IsBergerCondition( <G> )
#P  IsBergerCondition( <chi> )
##
##  Called with a character <chi>, 'IsBergerCondition' returns 'true' if
##  \[ ( \bigcap\{\ker(\psi);\psi(1) \< 'Degree( <chi> )'\} )^{\prime}
##     \leq \ker(<chi>). \]
##
##  Called with a group <G>, 'IsBergerCondition' returns 'true' if all
##  irreducible characters of <G> satisfy
##  \[ ( \bigcap_{\psi(1) \leq f_i}  \ker(\psi) )^{\prime} \leq
##       \bigcap_{\chi(1) = f_{i+1}} \ker(\chi) \ \forall 1\leq i\leq n-1 \]
##  where $1 = f_1 \leq f_2 \leq\ldots \leq f_n$ are the distinct irreducible
##  degrees of <G>.
##
##  In the case that 'false' is returned 'InfoMonomial' tells about the
##  degree for that the inequality is violated.
##
IsBergerCondition := NewProperty( "IsBergerCondition", IsGroup );
SetIsBergerCondition := Setter( IsBergerCondition );
HasIsBergerCondition := Tester( IsBergerCondition );

BergerCondition := IsBergerCondition;
#T compat3!


#############################################################################
##
#F  TestHomogeneous( <chi>, <N> )
##
##  is a record with information whether the restriction of the group
##  character <chi> of the group $G$ to the normal subgroup <N> of $G$ is
##  homogeneous, i.e., is a multiple of an irreducible character.
##
##  <N> may be given also as list of conjugacy class positions w.r. to $G$.
##
TestHomogeneous := NewOperationArgs( "TestHomogeneous" );


#############################################################################
##
#A  TestQuasiPrimitive( <chi> )
##
##  is a record with information about quasiprimitivity of the group
##  character <chi>, i.e., whether <chi> restricts homogeneously to every
##  normal subgroup of <G>.
##
##  The record contains at least the component
##  'isQuasiPrimitive':  \\ 'true' or 'false'.
##
##  If <chi> is not quasiprimitive then there is a component
##
##  'character':  \\ an irreducible constituent of a nonhomogeneous
##                   restriction of <chi>.
##
##  *Note* that for solvable groups, quasiprimitivity is the same as
##  primitivity.
##
TestQuasiPrimitive := NewAttribute( "TestQuasiPrimitive", IsCharacter );
SetTestQuasiPrimitive := Setter( TestQuasiPrimitive );
HasTestQuasiPrimitive := Tester( TestQuasiPrimitive );


#############################################################################
##
#P  IsQuasiPrimitive( <chi> )
##
##  is 'true' if the character <chi> of the group $G$ is quasiprimitive,
##  i.e., restricts homogeneously to every normal subgroup of $G$,
##  and 'false' otherwise.
##
IsQuasiPrimitive := NewProperty( "IsQuasiPrimitive", IsCharacter );
SetIsQuasiPrimitive := Setter( IsQuasiPrimitive );
HasIsQuasiPrimitive := Tester( IsQuasiPrimitive );


#############################################################################
##
#P  IsMonomialCharacter( <chi> )
##
##  is 'true' if the character <chi> is induced from a linear character of a
##  subgroup, and 'false' otherwise.
##
IsMonomialCharacter := NewProperty( "IsMonomialCharacter", IsCharacter );
SetIsMonomialCharacter := Setter( IsMonomialCharacter );
HasIsMonomialCharacter := Tester( IsMonomialCharacter );


#############################################################################
##
#P  IsPrimitiveCharacter( <chi> )
##
##  is 'true' if the character <chi> is not induced from any proper subgroup,
##  and 'false' otherwise.
##
IsPrimitiveCharacter := NewProperty( "IsPrimitiveCharacter", IsCharacter );
SetIsPrimitiveCharacter := Setter( IsPrimitiveCharacter );
HasIsPrimitiveCharacter := Tester( IsPrimitiveCharacter );


#############################################################################
##
#F  TestInducedFromNormalSubgroup( <chi>, <N> )
#F  TestInducedFromNormalSubgroup( <chi> )
##
##  is a record with information about whether the irreducible group
##  character <chi> of the group $G$ is induced from a proper normal subgroup
##  of $G$.
##
##  If <chi> is the only argument then it is checked whether there is a
##  maximal normal subgroup of $G$ from that <chi> is induced.
##
##  A second argument <N> must be a normal subgroup of $G$ or the list of
##  class positions of a normal subgroup of $G$.  Then it is checked
##  whether <chi> is induced from <N>.
##
##  The result contains always a component 'comment', a string.
##  The component 'isInduced' is 'true' or 'false', depending on whether
##  <chi> is induced.  In the 'true' case the component 'character'
##  contains a character of a maximal normal subgroup from that <chi> is
##  induced.
##
#T problem! (attr.?)
##
TestInducedFromNormalSubgroup := NewOperationArgs(
    "TestInducedFromNormalSubgroup" );


#############################################################################
##
#P  IsInducedFromNormalSubgroup( <chi> )
##
##  is 'true' if the character <chi> of the group $G$ is induced from a
##  normal subgroup of $G$, and 'false' otherwise.
##
IsInducedFromNormalSubgroup := NewProperty( "IsInducedFromNormalSubgroup",
    IsCharacter );
SetIsInducedFromNormalSubgroup := Setter( IsInducedFromNormalSubgroup );
HasIsInducedFromNormalSubgroup := Tester( IsInducedFromNormalSubgroup );


#############################################################################
##
#A  TestSubnormallyMonomial( <G> )
#A  TestSubnormallyMonomial( <chi> )
##
##  is a record with information whether the group <G> or the
##  irreducible group character <chi> is subnormally monomial.
##
##  The result contains components 'comment' (a string)
##  and 'isSubnormallyMonomial' ('true' or 'false');
##  in the case that 'isSubnormallyMonomial' is 'false' there is also
##  a component 'character' that is not a SM character.
##
TestSubnormallyMonomial := NewAttribute( "TestSubnormallyMonomial",
    IsGroup );
SetTestSubnormallyMonomial := Setter( TestSubnormallyMonomial );
HasTestSubnormallyMonomial := Tester( TestSubnormallyMonomial );


#############################################################################
##
#P  IsSubnormallyMonomial( <G> )
#P  IsSubnormallyMonomial( <chi> )
##
IsSubnormallyMonomial := NewProperty( "IsSubnormallyMonomial",
    IsGroup );
SetIsSubnormallyMonomial := Setter( IsSubnormallyMonomial );
HasIsSubnormallyMonomial := Tester( IsSubnormallyMonomial );


#############################################################################
##
#A  IsMonomialNumber( <n> )
##
##  is 'true' if every solvable group of order <n> is monomial,
##  and 'false' otherwise.
##
##  Let $\nu_p(n)$ denote the multiplicity of the prime $p$ as
##  factor of $n$, and $ord(p,q)$ the multiplicative order of $p \pmod{q}$.
##
##  Then there exists a nomonomial group of order $n$ if and only if
##  one of the following conditions is satisfied.
##
##  \begin{enumerate}
##  \item $\nu_2(n) \geq 2$ and there is a $p$ such that
##        $\nu_p(n) \geq 3$ and $p \equiv -1 \pmod{4}$,
##  \item $\nu_2(n) \geq 3$ and there is a $p$ such that
##        $\nu_p(n) \geq 3$ and $p \equiv  1 \pmod{4}$,
##  \item there are odd prime divisors $p$ and $q$ of $n$ such that
##        $ord(p,q)$ is even and $ord(p,q) < \nu_p(n)$
##        (especially $\nu_p(n) \geq 3$),
##  \item there is a prime divisor $q$ of $n$ such that
##        $\nu_2(n) \geq 2 ord(2,q) + 2$
##        (especially $\nu_2(n) \geq 4$),
##  \item $\nu_2(n) \geq 2$ and there is a $p$ such that
##        $p \equiv  1 \pmod{4}$, $ord(p,q)$ is odd,
##        and $2 ord(p,q) < \nu_p(n)$
##        (especially $\nu_p(n) \geq 3$).
##  \end{enumerate}
##
##  These five possibilities correspond to the five types of minimal
##  nonmonomial groups that can occur as subgroup or factor group of
##  the group with order $n$.
##
IsMonomialNumber := NewAttribute( "IsMonomialNumber", IsInt and IsPosRat );


#############################################################################
##
#A  TestMonomialQuick( <obj> )
##
##  is a record with components
##
##  'isMonomial': \\ either 'true' or 'false' or '"?"'
##
##  The function sets the 'isMonomial' flag if (non)monomiality was proved.
##
TestMonomialQuick := NewAttribute( "TestMonomialQuick", IsCharacter );
SetTestMonomialQuick := Setter( TestMonomialQuick );
HasTestMonomialQuick := Tester( TestMonomialQuick );


#############################################################################
##
#A  TestMonomial( <chi> )
#A  TestMonomial( <G> )
##
##  is a record containing information about monomiality of the group
##  <G> or the group character <chi>, respectively.
##
##  If a character <chi> was proved to be monomial the result contains
##  components 'isMonomial' (then 'true'), 'comment' (a string telling a
##  reason for monomiality), and if it was necessary to compute a linear
##  character from that <chi> is induced, also a component 'character'.
##
##  If <chi> or <G> was proved to be nonmonomial the component 'isMonomial'
##  is 'false', and in the case of <G> a nonmonomial character is contained
##  in the component 'character' if it had been necessary to compute it.
##
##  If the program cannot prove or disprove monomiality, then the result
##  record contains the component 'isMonomial' with value '\"?\"'.
##
##  It can happen that for all normal subgroups to that the restriction is
##  not homogeneous the inertia groups in question do not contain a subgroup
##  from that the character is induced?
##
##  The algorithm proceeds as follows.
##  Called with a character <chi> as argument, 'TestMonomialQuick( <chi> )'
##  is inspected first.  If this did not decide the question, we test all
##  those normal subgroups of $G$ to that <chi> restricts nonhomogeneously
##  whether the interesting character of the inertia subgroup is monomial.
##  (If <chi> is quasiprimitive then it is nonmonomial.)
##
##  Called with a group <G> the program checks whether all representatives
##  of character orbits are monomial.
#T used e.g. by 'Irr' for supersolvable groups, function 'IrrConlon'!
##
TestMonomial := NewAttribute( "TestMonomial", IsCharacter );
SetTestMonomial := Setter( TestMonomial );
HasTestMonomial := Tester( TestMonomial );


#############################################################################
##
#F  TestRelativelySM( <G> )
#F  TestRelativelySM( <chi> )
#F  TestRelativelySM( <G>, <N> )
#F  TestRelativelySM( <chi>, <N> )
##
##  If the only argument is a SM group $G$ or an irreducible character of a
##  SM group $G$ then 'TestRelativelySM' returns a record with information
##  about whether the argument is relatively SM with respect to every normal
##  subgroup of $G$.
##
##  If there is a second argument, a normal subgroup <N> of $G$, then
##  'TestRelativelySM' returns a record with information whether the first
##  argument is relatively SM with respect to <N>, i.e, whether there is a
##  subnormal subgroup $H$ of $G$ that contains <N> such that the character
##  <chi> resp. every irreducible character of $G$ is induced from a character
##  $\psi$ of $H$ where the restriction of $\psi$ to <N> is irreducible.
##
##  The component 'isRelativelySM' is 'true' or 'false', the component
##  'comment' contains a string that describes the reason.
##  If the argument is <G>, and <G> is not relatively SM with respect to
##  a normal subgroup then the component 'character' contains a not
##  relatively SM character of such a normal subgroup.
##
##  *Note* that it is not checked whether $G$ is SM.
##
TestRelativelySM := NewOperationArgs( "TestRelativelySM" );


#############################################################################
##
#P  IsRelativelySM( <chi> )
#P  IsRelativelySM( <G> )
##
##  is 'true' if the group <G> resp. the irreducible character <chi>
##  of the group <G> is relatively subnormally monomial with respect to
##  every normal subgroup of <G>, and 'false' otherwise.
##
##  <G> must be subnormally monomial.  (This is *not* checked.)
##
IsRelativelySM := NewProperty( "IsRelativelySM", IsGroup );
SetIsRelativelySM := Setter( IsRelativelySM );
HasIsRelativelySM := Tester( IsRelativelySM );


#############################################################################
##
#P  IsMinimalNonmonomial( <G> )
##
##  is 'true' if the group <G> is a minimal nonmonomial group, and
##  'false' otherwise.
##
IsMinimalNonmonomial := NewProperty( "IsMinimalNonmonomial", IsGroup );
SetIsMinimalNonmonomial := Setter( IsMinimalNonmonomial );
HasIsMinimalNonmonomial := Tester( IsMinimalNonmonomial );


#############################################################################
##
#F  MinimalNonmonomialGroup( <p>, <factsize> )
##
##  is a minimal nonmonomial group described by the parameters <factsize> and
##  <p> if such a group exists, and 'false' otherwise.
##
##  Suppose that the required group $K$ exists.
##  <factsize> must be the size of the Fitting factor $K / F(K)$.
##  <p> denotes the number $s$ such that the centre $Z(K)$ has order $2^s$
##  in the case that <factsize> is twice an odd prime; in all other cases
##  <p> is the (unique) prime that divides the order of $F(K)$.
##
MinimalNonmonomialGroup := NewOperationArgs( "MinimalNonmonomialGroup" );


#############################################################################
##
#E  ctblmono.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



