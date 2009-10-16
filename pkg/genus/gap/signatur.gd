#############################################################################
##
#W  signatur.gd            GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: signatur.gd,v 1.5 2002/05/24 15:06:47 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations concerning signatures.
##
##  1. Definition of Signatures
##  2. Creating Signatures
##  3. Operations for Signatures
##  4. Computing Admissible Signatures for Fixed Genus of a Surface Kernel
##
Revision.( "pkg/genus/signatur_gd" ) :=
    "@(#)$Id: signatur.gd,v 1.5 2002/05/24 15:06:47 gap Exp $";


#############################################################################
##
##  1. Definition of Signatures
#1
##  A *compact signature* consists of a nonnegative integer $g$
##  and a vector $(m_1, m_2, \ldots, m_r)$ of integers, $r \geq 0$,
##  such that $2 \leq m_1 \leq m_2 \leq \cdots \leq m_r$ holds.
##  If $r > 0$ then we denote this signature by $(g; m_1, m_2, \ldots, m_r)$;
##  for $r = 0$, we write $(g; -)$.
##  The number $g$ is called the *orbit genus* (or simply the *genus*),
##  and the $m_i$ are called the *periods* of the signature.
##
##  We associate to the signature $(g; m_1, m_2, \ldots, m_r)$
##  the finitely presented group
##  $\Gamma(g; m_1, m_2, \ldots, m_r) =$
##  $$
##    \langle a_1, b_1, a_2, b_2, \ldots, a_g, b_g, c_1, c_2, \ldots, c_r |
##            c_1^{m_1}, c_2^{m_2}, \ldots, c_r^{m_r},
##            [a_1,b_1] [a_2,b_2] \cdots [a_g,b_g] c_1 c_2 \cdots c_r \rangle
##  $$
##  which we call a *group with signature*.
##
##  In the following, we exclude the signatures $(0; m)$ and $(0; m_1, m_2)$
##  for the case $m_1 \not= m_2$,
##  since $\Gamma(0; m) \cong \Gamma(0; -)$ and
##  $\Gamma(0; m_1, m_2) \cong \Gamma(0; d, d)$ where $d$ is the g.c.d.~of
##  $m_1$ and $m_2$.
##  With this normalization, we get that the signature of a group with
##  signature is uniquely determined (see Section~3.3 in~\cite{Bre00}).
##
##  The set of signatures can be distributed into three classes,
##  depending on the the quantity $2 (1-g) - \sum_{i=1}^r (1-1/m_i)$,
##  the *curvature* \index{curvature} (see~"Curvature") of the signature.
##  If this value is positive then $\Gamma(g; m_1, m_2, \ldots, m_r)$ is
##  finite, and the possibilities are
##  \beginlist
##  \item{(a)}
##      the trivial group $\Gamma(0; -)$,
##  \item{(b)}
##      the cyclic group $\Gamma(0; d, d)$ of order $d$,
##  \item{(c)}
##      the dihedral group $\Gamma(0; 2, 2, d)$ of order $2 d$,
##  \item{(d)}
##      the alternating group $\Gamma(0; 2, 3, 3)$ of degree $4$,
##  \item{(e)}
##      the symmetric group $\Gamma(0; 2, 3, 4)$ of degree $4$, and
##  \item{(f)}
##      the alternating group $\Gamma(0; 2, 3, 5)$ of degree $5$.
##  \endlist
##  Groups with signatures of zero curvature are
##  \beginlist
##  \item{(a)}
##      the free abelian group $\Gamma(1; -) \cong \Z \times \Z$,
##  \item{(b)}
##      the group $\Gamma(1; 2, 3, 6) \cong (\Z \times \Z) \colon 6$,
##  \item{(c)}
##      the group $\Gamma(1; 2, 4, 4) \cong (\Z \times \Z) \colon 4$,
##  \item{(d)}
##      the group $\Gamma(1; 3, 3, 3) \cong (\Z \times \Z) \colon 3$, and
##  \item{(e)}
##      the group $\Gamma(1; 2, 2, 2, 2) \cong (\Z \times \Z) \colon 2$.
##  \endlist
##  All other signatures have negative curvature.
##
##  See `IsGroupOfGenusZero', `IsGroupOfGenusOne'!
##
##  The functions in this {\GAP} package deal mainly with signatures of
##  negative curvature.
##  The corresponding groups describe compact Riemann surfaces,
##  in the sense that for each group $\Gamma$ with signature of negative
##  curvature, the group of automorphisms (that is, biholomorphic
##  homeomorphisms) of the complex upper half plane contains a discrete
##  subgroup isomorphic to $\Gamma$ --such a group is also called a
##  *Fuchsian group*-- \index{Fuchsian group}\index{group!Fuchsian}
##  such that the orbit space of the upper half plane modulo the group action
##  is a compact Riemann surface.
##  Conversely, each compact Riemann surface arises this way
##  (up to isomorphism).
##
##  This package is concerned with groups of automorphisms
##  of compact Riemann surfaces,
##  mainly surfaces of genus at least $2$.
##  The connection between these groups of automorphisms and groups with
##  signature is the following.
##
##  Given a compact Riemann surface $X$ of genus $g \geq 2$
##  together with a group $G$ of automorphisms of $X$,
##  there is a group $\Gamma$ with signature $(g'; m_1, m_2, \ldots, m_r)$
##  and a normal subgroup $K$ of $\Gamma$ such that $\Gamma / K \cong G$
##  and $K$ has signature $(g; -)$.
##  The two signatures are related by the Riemann-Hurwitz Formula,\index{Riemann-Hurwitz Formula}
##  $$
##  g - 1 = |G| \left( g' - 1
##          + \frac{1}{2} \sum_{i=1}^r \left( 1-\frac{1}{m_i} \right) \right).
##  $$
##
##  Conversely, for a group $\Gamma$ and a normal subgroup $K$
##  with signatures as above that satisfy the Riemann-Hurwitz Formula
##  with $g \geq 2$,
##  there is a compact Riemann surface $X$ of genus $g$ that admits a group
##  of automorphisms isomorphic to $\Gamma / K$.
##
##  Groups with signature of the form $(g; -)$, i.e., without periods,
##  are *torsion-free*.
##  So the question for pairs $(X, G)$ as above can be translated into the
##  question for epimorphisms $\Gamma \rightarrow G$ where $\Gamma$ is a
##  group with signature and the kernel is a torsion-free normal subgroup
##  of $\Gamma$;
##  such an epimorphism is called a *surface kernel epimorphism*.
##
##  literature!!
##


#############################################################################
##
#V  InfoSignature
##
DeclareInfoClass( "InfoSignature" );


#############################################################################
##
#C  IsCompactSignature( <obj> )
##
##  In {\GAP}, a compact signature is represented by an object
##  in the category `IsCompactSignature'.
##  Defining operations for compact signatures are `GenusOfSignature'
##  (see~"GenusOfSignature")
##  and `PeriodsOfSignature' (see~"PeriodsOfSignature").
##  Signatures can be created using `Signature' (see~"Signature").
##
DeclareCategory( "IsCompactSignature", IsObject );


#############################################################################
##
#V  SignaturesFamily
#V  DefaultTypeOfSignature
##
##  All compact signatures lie in the family `IsSignaturesFamily'.
##
##  ...
##
BindGlobal( "SignaturesFamily",
    NewFamily( "SignaturesFamily", IsCompactSignature ) );

BindGlobal( "DefaultTypeOfSignature",
    NewType( SignaturesFamily,
             IsCompactSignature and IsAttributeStoringRep ) );


#############################################################################
#2
##  Two signatures are *equal* if and only if their orbit genera are equal and
##  their lists of periods are equal.
##  The *ordering* of signatures via `\<' is defined lexicographically;
##  that is, first the orbit genera are compared, and for signatures with
##  the same orbit genus, the vectors of periods are compared.
##  (This ordering is not a natural ordering but cheap ...)
##
##  where in the manual is the partial ordering used?
##
#T why not order according to the curvature?
#T then for fixed genus or group order the right ordering!
#T whenever a finite number of signatures is considered, this is o.k.
#T for a series with negative curvature, consider (0;2,2,2,n) for n > 2
##
##  The default `PrintObj' method for signatures prints a call to
##  `Signature', such that the output is {\GAP} readable.
##  The default `ViewObj' and `String' methods output the notation for
##  signatures introduced above.
##


#############################################################################
##
#A  GenusOfSignature( <sign> )
#A  PeriodsOfSignature( <sign> )
##
##  For a signature $<sign> = (g; m_1, m_2, \ldots, m_r )$,
##  `GenusOfSignature' returns the nonnegative integer $g$,
##  and `PeriodsOfSignature' returns the list $[ m_1, m_2, \ldots, m_r ]$.
##  (Note that the $m_i$ are sorted ...)
##
##  better call this `OrbitGenusOfSignature'?
##
##  There are no default methods to compute genus and periods of a signature,
##  the values are supposed to be entered upon creation of a signature.
##
DeclareAttribute( "GenusOfSignature", IsCompactSignature );

DeclareAttribute( "PeriodsOfSignature", IsCompactSignature );


#############################################################################
##
##  2. Creating Signatures
##


#############################################################################
##
#O  Signature( <genus>, <periods> )
##
##  For a nonnegative integer <genus> and a list <periods> of nonnegative
##  integers as described in the introduction to the chapter,
##  `Signature' returns the signature defined by these data.
##  Note that the periods of the result are sorted also if <periods> is not
##  sorted, and the excluded signatures $(0; m)$ and $(0; m_1, m_2)$ with
##  $m_1 \not= m_2$ are replaced by the normalized ones.
##
DeclareOperation( "Signature", [ IsInt, IsHomogeneousList ] );


#############################################################################
##
#A  SignatureOfEichlerCharacter( <chi> )
#O  SignatureOfEichlerCharacter( <tbl>, <chi> )
##
##  Let <chi> be an ordinary character $\chi$ of the group $G$, say.
##  If <chi> is given only by its values list then let <tbl> be the ordinary
##  character table of $G$.
##
##  Suppose that $\chi$ has degree $g$ and satisfies
##  $$
##  \chi(\sigma) = 1 + \sum a_u \frac{\zeta_m^u}{1-\zeta_m^u}
##  $$
##  for $\sigma \in G$ of order $m > 1$ and $\zeta_m = \exp(2 \pi i / m)$,
##  where the summation runs over the prime residues $u$ mod $m$.
##
#T ...
##
##  is the signature of the group ...
##
##  according to the Eichler Trace Formula (for example, see~\cite{...})
##
##  well-defined:
##  signature of $\chi$, depends only on $\chi + \overline{\chi}$.
##
DeclareAttribute( "SignatureOfEichlerCharacter", IsClassFunction );
DeclareOperation( "SignatureOfEichlerCharacter",
    [ IsOrdinaryTable, IsHomogeneousList ] );


#############################################################################
##
##  3. Operations for Signatures
##


#############################################################################
##
#A  Curvature( <sign> )
##
##  For a signature $<sign> = (g; m_1, m_2, \ldots, m_r)$,
##  `Curvature' returns the rational number
##  $2 (1-g) - \sum_{i=1}^r (1-1/m_i)$.
##
DeclareAttribute( "Curvature", IsCompactSignature );


#############################################################################
##
#F  GenusOfSurfaceKernel( <sign>, <n> )
##
##  For a signature <sign> corresponding to the group $\Gamma$
##  and a positive integer <n> such that $\Gamma$ has a torsion-free normal
##  subgroup of index <n>,
##  `GenusOfSurfaceKernel' returns the orbit genus of this kernel.
##  This can be computed using the Riemann-Hurwitz formula,
##
##  see the introduction to the chapter?
##
DeclareGlobalFunction( "GenusOfSurfaceKernel" );


#############################################################################
##
#F  GroupOrderOfSurfaceKernelFactor( <sign>, <g> )
##
##  For a signature <sign> corresponding to the group $\Gamma$
##  and a nonnegative integer <g> such that $\Gamma$ has a torsion-free
##  normal subgroup $N$ of orbit genus <g>,
##  `GroupOrderOfSurfaceKernelFactor' returns the index of $N$ in $\Gamma$.
##  This can be computed using the Riemann-Hurwitz formula,
##
##  see the introduction to the chapter?
##
DeclareGlobalFunction( "GroupOrderOfSurfaceKernelFactor" );


#############################################################################
##
#A  AbelianInvariants( <sign> )
##
##  Let <sign> be a compact signature, and $\Gamma$ a group with signature
##  <sign>.
##  `AbelianInvariants' returns the list of abelian invariants
##  of the commutator factor group of $\Gamma$
##  (see~"ref:AbelianInvariants!for groups" in the {\GAP} Reference Manual).
##
##  in particular format of the result!!
##
##  crossref. to Lemma~A.3 in~\cite{Bre00}!
##
DeclareAttribute( "AbelianInvariants", IsCompactSignature );


#############################################################################
##
#P  IsPerfectSignature( <sign> )
##
##  is `true' if the commutator factor group of any group with signature <sign>
##  is trivial, and `false' otherwise.
##
##  The commutator factor group of $\Gamma(g_0; m_1, m_2, \ldots, m_r)$
##  is trivial if and only if $g_0 = 0$ and the periods $m_i$ are pairwise
##  coprime.
##
##  (admit `IsPerfect'?)
##
DeclareProperty( "IsPerfectSignature", IsCompactSignature );


#############################################################################
##
#F  IsCyclicSignature( <sign>, <n> )
##
##  For a signature <sign> and a positive integer <n>,
##  `IsCyclicSignature' returns `true' if and only if any group with signature
##  <sign> admits a surface kernel epimorphism to a cyclic group of order
##  <n>.
##
##  (admit `IsCyclic'?)
##
##  The implementation uses Corollary~9.4 in~\cite{Bre00}.
##  (cite also~\cite{Har66}?)
##
DeclareGlobalFunction( "IsCyclicSignature" );


#############################################################################
##
#F  InvariantsOfAbelianSurfaceKernelFactors( <sign>, <n> )
##
##  For a signature <sign> and a positive integer <n>,
##  `InvariantsOfAbelianSurfaceKernelFactors' returns the list of all vectors
##
##  no, just the *normed* ones (in general not unique; how defined in GAP?)
##
##  of abelian invariants (see ...) of abelian groups of order <n>
##  that are factor
##  groups of a group with signature <sign>, with torsion-free kernel.
##
#T  (see ... for the criterion how to compute this)
##
DeclareGlobalFunction( "InvariantsOfAbelianSurfaceKernelFactors" );


#############################################################################
##
#F  IsAbelianSignature( <sign>, <m> )
##
##  `IsAbelianSignature' returns `true' if the group with signature <sign>
##  has an abelian surface kernel factor of order <m>, and `false' otherwise.
##
DeclareGlobalFunction( "IsAbelianSignature" );


#############################################################################
##
#F  SignaturesOfPrimeIndex( <sign>, <p> )
##
##  `SignaturesOfPrimeIndex' returns the strictly sorted list of signatures
##  of all normal subgroups of prime index <p> in the group with signature
##  <sign>.
##
##  only those for $g = 0$? (what about my algorithm if $g > 0$?)
##
DeclareGlobalFunction( "SignaturesOfPrimeIndex" );


#############################################################################
##
##  4. Computing Admissible Signatures for Fixed Genus of a Surface Kernel
#3
##  motivation:
##  not for each signature there is a group, for example ...
##
##  The following functions deal with the admissibility of signatures.
##  A signature is called *admissible* for a given positive integer $m$
##
##  formulation?
##
##  if the criteria stated in~\cite{Bre00}
##
##  where exactly?
##
##  do not exclude the signature.
##  The idea behind is that if the signature $(g_0; m_1, m_2, \ldots, m_r)$
##  is not admissible for $m$ then the group
##  $\Gamma(g_0; m_1, m_2, \ldots, m_r)$ has no surface kernel factor
##  of order $m$, see~\cite{...}.
##


#############################################################################
##
#V  PRE_SIGNATURES
#V  CYC_SIGNATURES
#V  ADM_SIGNATURES
#V  CYCLIC_ORDERS
#V  CYCLIC_PERIODS
##
##  Computed values of calls to `PreSignatures', `CyclicSignatures',
##  `AdmissibleSignatures', `CyclicOrders', `CyclicPeriods' are stored.
##
DeclareGlobalVariable( "PRE_SIGNATURES" );
DeclareGlobalVariable( "CYC_SIGNATURES" );
DeclareGlobalVariable( "ADM_SIGNATURES" );
DeclareGlobalVariable( "CYCLIC_ORDERS" );
DeclareGlobalVariable( "CYCLIC_PERIODS" );


#############################################################################
##
#F  PreSignatures( <g>, <g0>, <n> )
#F  PreSignatures( <g>, <g0> )
#F  PreSignatures( <g> )
##
##  In the first form, <g> and <g0> must be nonnegative integers,
##  $<g> \geq 2$, and <n> a positive integer;
##  `PreSignatures' then returns the strictly sorted list of all signatures
#T what does sorted mean??
##  $(<g0>; m_1, m_2, \ldots, m_r)$ with the properties that the periods
##  $m_i$ divide <n> and the equality
##  $<g>-1 = <n> (<g0>-1) + <n>/2 \sum_{i=1}^r (1 - 1/m_i)$ holds.
##
##  Note that there are such signatures only if $<n> \leq 84 (<g>-1)$ and
##  if $<g0>-1 \leq (<g>-1)/<n>$.
##
##  In the second form, `PreSignatures' returns the list that contains the
##  value `PreSignatures( <g>, <g0>, <n> )' at position <n>,
##  for $2 \leq <n> \leq 84 (<g>-1)$ (see ...).
#T really??
##
##  In the third form, `PreSignatures' returns the list that contains the
##  value `PreSignatures( <g>, <g0> )' at position $<g0>+1$,
##  for $0 \leq <g0> \leq <g>$.
##
##  The signatures returned by `PreSignatures' are all combinatorially
##  possible signatures for which the corresponding groups may have a
##  surface kernel factor of order <n>.
##  See~"AdmissibleSignatures" for the subset of admissible signatures.
##
##  Computed values of `PreSignatures' are stored using the global variable
##  `PRE_SIGNATURES'.
##
DeclareGlobalFunction( "PreSignatures" );


#############################################################################
##
#F  CyclicSignatures( <g>, <g0>, <n> )
#F  CyclicSignatures( <g>, <g0> )
#F  CyclicSignatures( <g> )
##
##  In the first form, <g> and <g0> must be nonnegative integers,
##  $<g> \geq 2$, and <n> a positive integer;
##  `CyclicSignatures' then returns the list of signatures
##  $(<g0>; m_1, m_2, \ldots, m_r)$ such that the corresponding group
##  has a cyclic surface kernel factor of order <n>,
##  where the kernel has orbit genus <g>.
##
##  In the second form, `CyclicSignatures' returns the list that contains the
##  value `CyclicSignatures( <g>, <g0>, <n> )' at position <n>,
##  for $2 \leq <n> \leq 4<g>+2$ (see ...).
##
##  In the third form, `CyclicSignatures' returns the list that contains the
##  value `CyclicSignatures( <g>, <g0> )' at position $<g0>+1$,
##  for $0 \leq <g0> \leq <g>$.
##
DeclareGlobalFunction( "CyclicSignatures" );


#############################################################################
##
#F  CyclicOrders( <g> )
##
##  For an integer <g> $\geq 2$, `CyclicOrders' returns the strictly sorted
##  list of all orders of nonidentity automorphisms of compact Riemann
##  surfaces of genus <g>.
##
DeclareGlobalFunction( "CyclicOrders" );


#############################################################################
##
#F  CyclicPeriods( <g> )
##
##  For an integer <g> $\geq 2$, `CyclicPeriods' returns the strictly sorted
##  list of all periods that occur in signatures of groups that have a
##  torsion-free normal subgroup of orbit genus <g>.
##
DeclareGlobalFunction( "CyclicPeriods" );


#############################################################################
##
#F  IsSignatureOnlyForAbelianGroup( <periods>, <n> )
##
##  `IsSignatureOnlyForAbelianGroup' returns `true' if every surface kernel
##  factor of order <n> of a group with signature given by orbit genus zero
##  and periods in the list <periods> can be proved by the following
##  criteria, and `false' otherwise.
##
##  \beginlist
##  \item{1.}
##      If <n> is among the periods then the group must be cyclic
##      hence abelian.
##  \item{2.}
##      Every group of order $p$ or $p^2$, for a prime $p$, is abelian.
##  \item{3.}
##      Every group of order $p q$ or $p^2 q$, for primes $p \< q$
##      with $p$ not dividing $(q-1)$, is abelian.
##  \endlist
##
##  Note that a `true' result does not mean that an abelian surface kernel
##  factor of order <n> exists.
##  But together with the classification of signatures for abelian factors
##  (see~"IsAbelianSignature") it may be possible to prove with
##  `IsSignatureOnlyForAbelianGroup' that a given signature is *not*
##  admissible (see~"TestAdmissibleSignature").
##
##  What about `IsAbelianNumber' in item 1.?
##
##  see Jones: if more primes are involved, with power $\leq 2$ ...
##
##  note: if n is divisible by a third power but this power is among the
##  periods then a `true' result might be possible!
##
DeclareGlobalFunction( "IsSignatureOnlyForAbelianGroup" );


#############################################################################
##
#F  TestAdmissibleSignature( <sign>, <n> )
##
##  For a signature <sign> and a positive integer <n>,
##  `TestAdmissibleSignature' returns a record with the following components.
##  \beginitems
##  `isAdmissibleSignature' &
##       is `true' if <sign> is admissible for <n> (see~\cite{Bre00} where??),
##       and `false' otherwise,
##
##  `solvable' &
##       is `true' if <sign> is admissible also for *solvable* groups of order
##       <n>, and `false' otherwise (Note ...),
##
##  `comment' &
##       is a string with information about the values of the above
##       components.
##  \enditems
##
##  Let <sign> be the signature of a group $\Gamma$, say, and <n> a positive
##  integer.
##  <sign> is called *admissible* for <n> w.r.t. a set of criteria
##  if none of these criteria excludes the possibility of a surface kernel
##  epimorphism from $\Gamma$ onto a group of order <n>.
##
##  The criteria are described by ...
##  *third argument, with default given by a global variable!*
##
##  In Def.~17.1 in~\cite{Bre00}, admissibility is defined only for the case
##  that the criteria used are those stated in 17.2, 17.4, 17.6, 17.10,
##  17.11, 17.12, 17.14, 17.15, and 17.16.
##  This admissibility can be studied by setting ... to `"book"'.
##
DeclareGlobalFunction( "TestAdmissibleSignature" );


#############################################################################
##
#F  IsAdmissibleSignature( <sign>, <n> )
##
##  Let <sign> be a compact signature, and <n> a positive integer;
##  `IsAdmissibleSignature' returns `true' if <sign> is admissible for <n>,
##  and `false' otherwise.
##
DeclareGlobalFunction( "IsAdmissibleSignature" );


#############################################################################
##
#F  AdmissibleSignatures( <g>, <g0>, <n> )
#F  AdmissibleSignatures( <g>, <g0> )
#F  AdmissibleSignatures( <g> )
##
##  In the first form, <g> and <g0> must be nonnegative integers,
##  $<g> \geq 2$, and <n> a positive integer;
##  `AdmissibleSignatures' then returns the strictly sorted list of all
##  signatures
##
##  what does sorted mean??
##
##  $(<g0>; m_1, m_2, \ldots, m_r)$ with the properties that the periods
##  $m_i$ divide <n> and the equality
##  $<g>-1 = <n> (<g0>-1) + <n>/2 \sum_{i=1}^r (1 - 1/m_i)$ holds.
##
##  Note that there are such signatures only if $<n> \leq 84 (<g>-1)$ and
##  if $<g0>-1 \leq (<g>-1)/<n>$.
##
##  In the second form, `AdmissibleSignatures' returns the list that contains
##  the value `AdmissibleSignatures( <g>, <g0>, <n> )' at position <n>,
##  for $2 \leq <n> \leq 84 (<g>-1)$ (see ...).
##
##  really??
##
##  In the third form, `AdmissibleSignatures' returns the list that contains
##  the value `AdmissibleSignatures( <g>, <g0> )' at position $<g0>+1$,
##  for $0 \leq <g0> \leq <g>$.
##
##  The signatures returned by `AdmissibleSignatures' are ...
##
DeclareGlobalFunction( "AdmissibleSignatures" );


#############################################################################
##
#E

