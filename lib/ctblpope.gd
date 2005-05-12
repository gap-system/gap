#############################################################################
##
#W  ctblpope.gd                 GAP library                     Thomas Breuer
#W                                                           & Goetz Pfeiffer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declaration of those functions that are needed to
##  compute and test possible permutation characters.
##
#T  TODO:
#T  - use roots in `PermCandidates' (cf. `PermCandidatesFaithful'),
#T    in order to guarantee property (d) already in the construction!
#T  - check and document `PermCandidatesFaithful'
#T  - `IsPermChar( <tbl>, <pc> )'
#T    (check whether <pc> can be a permutation character of <tbl>;
#T     use also the kernel of <pc>, i.e., check whether the kernel factor
#T     of <pc> can be a permutation character of the factor of <tbl> by the
#T     kernel; one example where this helps is the sum of characters of S3
#T     in O8+(2).3.2)
#T  - `Constituent' und `Maxdeg' - Optionen in `PermComb'

#1
##  For groups $H$ and $G$ with $H \leq G$,
##  the induced character $(1_G)^H$ is called the *permutation character*
##  of the operation of $G$ on the right cosets of $H$.
##  If only the character table of $G$ is available and not the group $G$
##  itself, one can try to get information about possible subgroups of $G$
##  by inspection of those $G$-class functions that might be
##  permutation characters, using that such a class function $\pi$ must have
##  at least the following properties.
##  (For details, see~\cite{Isa76}, Theorem~5.18.)
##  \beginlist%ordered{a}
##  \item{(a)}
##      $\pi$ is a character of $G$,
##  \item{(b)}
##      $\pi(g)$ is a nonnegative integer for all $g \in G$,
##  \item{(c)}
##      $\pi(1)$ divides $|G|$,
##  \item{(d)}
##      $\pi(g^n) \geq \pi(g)$ for $g \in G$ and integers $n$,
##  \item{(e)}
##      $[\pi,1_G] = 1$,
##  \item{(f)}
##      the multiplicity of any rational irreducible $G$-character $\psi$
##      as a constituent of $\pi$ is at most $\psi(1)/[\psi,\psi]$,
##  \item{(g)}
##      $\pi(g) = 0$ if the order of $g$ does not divide $|G|/\pi(1)$,
##  \item{(h)}
##      $\pi(1) |N_G(g)|$ divides $\pi(g) |G|$ for all $g \in G$,
##  \item{(i)}
##      $\pi(g) \leq (|G| - \pi(1)) / (|g^G| |Gal_G(g)|)$ for all nonidentity
##      $g \in G$, where $|Gal_G(g)|$ denotes the number of conjugacy classes
##      of $G$ that contain generators of the group $\langle g \rangle$,
##  \item{(j)}
##      if $p$ is a prime that divides $|G|/\pi(1)$ only once then $s/(p-1)$
##      divides $|G|/\pi(1)$ and is congruent to $1$ modulo $p$,
##      where $s$ is the number of elements of order $p$ in the
##      (hypothetical) subgroup $H$ for which $\pi = (1_H)^G$ holds.
##      (Note that $s/(p-1)$ equals the number of Sylow $p$ subgroups in
##      $H$.)
##  \endlist
##  Any $G$-class function with these properties is called a
##  *possible permutation character* in {\GAP}.
##
##  (Condition (d) is checked only for those power maps that are stored in
##  the character table of $G$;
##  clearly (d) holds for all integers if it holds for all prime divisors of
##  the group order $|G|$.)
##
##  {\GAP} provides some algorithms to compute
##  possible permutation characters (see~"PermChars"),
##  and also provides functions to check a few more criteria whether a
##  given character can be a transitive permutation character
##  (see~"TestPerm1").
##
##  Some information about the subgroup $U$ can be computed from the
##  permutation character $(1_U)^G$ using `PermCharInfo'
##  (see~"PermCharInfo").
##
Revision.ctblpope_gd :=
    "@(#)$Id$";


#############################################################################
##
#F  PermCharInfo( <tbl>, <permchars>[, \"LaTeX\" ] )
#F  PermCharInfo( <tbl>, <permchars>[, \"HTML\" ] )
##
##  Let <tbl> be the ordinary character table of the group $G$,
##  and `permchars' either the permutation character $(1_U)^G$,
##  for a subgroup $U$ of $G$, or a list of such permutation characters.
##  `PermCharInfo' returns a record with the following components.
##  \beginitems
##  `contained': &
##    a list containing, for each character $\psi = (1_U)^G$ in <permchars>,
##    a list containing at position $i$ the number
##    $\psi[i] |U| / `SizesCentralizers( <tbl> )'[i]$,
##    which equals the number of those elements of $U$
##    that are contained in class $i$ of <tbl>,
##
##  `bound': &
##    a list containing, for each character $\psi = (1_U)^G$ in <permchars>,
##    a list containing at position $i$ the number
##    $|U| / \gcd( |U|, `SizesCentralizers( <tbl> )'[i] )$,
##    which divides the class length in $U$ of an element in class $i$
##    of <tbl>,
##
##  `display': &
##    a record that can be used as second argument of `Display'
##    to display each permutation character in <permchars> and the
##    corresponding components `contained' and `bound',
##    for those classes where at least one character of <permchars> is
##    nonzero,
##
##  `ATLAS': &
##    a list of strings describing the decomposition of the permutation
##    characters in <permchars> into the irreducible characters of <tbl>,
##    given in an {\ATLAS}-like notation.
##    This means that the irreducible constituents are indicated by their
##    degrees followed by lower case letters `a', `b', `c', $\ldots$,
##    which indicate the successive irreducible characters of <tbl>
##    of that degree, in the order in which they appear in `Irr( <tbl> )'.
##    A sequence of small letters (not necessarily distinct) after a single
##    number indicates a sum of irreducible constituents all of the same
##    degree, an exponent <n> for the letter <lett> means that <lett>
##    is repeated <n> times.
##    The default notation for exponentiation is `<lett>^{<n>}',
##    this is also chosen if the optional third argument is the string
##    `\"LaTeX\"';
##    if the third argument is the string `\"HTML\"' then exponentiation is
##    denoted by `<lett>\<sup><n>\<\/sup>'.
##  \enditems
##
DeclareGlobalFunction( "PermCharInfo" );


#############################################################################
##
#F  PermCharInfoRelative( <tbl>, <tbl2>, <permchars> )
##
##  Let <tbl> and <tbl2> be the ordinary character tables of two groups $H$
##  and $G$, respectively, where $H$ is of index $2$ in $G$,
##  and <permchars> either the permutation character $(1_U)^G$,
##  for a subgroup $U$ of $G$, or a list of such permutation characters.
##  `PermCharInfoRelative' returns a record with the same components as
##  `PermCharInfo' (see~"PermCharInfo"), the only exception is that the
##  entries of the `ATLAS' component are names relative to <tbl>.
##
##  More precisely, the $i$-th entry of the `ATLAS' component is a string
##  describing the decomposition of the $i$-th entry in <permchars>.
##  The degrees and distinguishing letters of the constituents refer to
##  the irreducibles of <tbl>, as follows.
##  The two irreducible characters of <tbl2> of degree $N$, say, that extend
##  the irreducible character $N `a'$ of <tbl> are denoted by $N `a'^+$ and
##  $N `a'^-$.
##  The irreducible character of <tbl2> of degree $2N$, say, whose
##  restriction to <tbl> is the sum of the irreducible characters $N `a'$ and
##  $N `b'$ is denoted as $N `ab'$.
##  Multiplicities larger than $1$ of constituents are denoted by exponents.
##
##  (This format is useful mainly for multiplicity free permutation
##  characters.)
##
DeclareGlobalFunction( "PermCharInfoRelative" );


#############################################################################
##
#F  TestPerm1( <tbl>, <char> ) . . . . . . . . . . . . . . . .  test permchar
#F  TestPerm2( <tbl>, <char> ) . . . . . . . . . . . . . . . .  test permchar
#F  TestPerm3( <tbl>, <chars> )  . . . . . . . . . . . . . . . test permchars
#F  TestPerm4( <tbl>, <chars> )  . . . . . . . . . . . . . . . test permchars
#F  TestPerm5( <tbl>, <chars>, <modtbl> ) . . . . . . . . . .  test permchars
##
##  The first three of these functions implement tests of the properties of
##  possible permutation characters listed in
##  Section~"Possible Permutation Characters",
##  The other two implement test of additional properties.
##  Let <tbl> be the ordinary character table of a group $G$, say,
##  <char> a rational character of <tbl>,
##  and <chars> a list of rational characters of <tbl>.
##  For applying `TestPerm5', the knowledge of a $p$-modular Brauer table
##  <modtbl> of $G$ is required.
##  `TestPerm4' and `TestPerm5' expect the characters in <chars> to satisfy
##  the conditions checked by `TestPerm1' and `TestPerm2' (see below).
##
##  The return values of the functions were chosen parallel to the tests
##  listed in~\cite{NPP84}.
##
##  `TestPerm1' return `1' or `2' if <char> fails because of (T1) or (T2),
##  respectively; this corresponds to the criteria (b) and (d).
##  Note that only those power maps are considered that are stored on <tbl>.
##  If <char> satisfies the conditions, `0' is returned.
##
##  `TestPerm2' returns `1' if <char> fails because of the criterion (c),
##  it returns `3', `4', or `5' if <char> fails because of (T3), (T4),
##  or (T5), respectively;
##  these tests correspond to (g), a weaker form of (h), and (j).
##  If <char> satisfies the conditions, `0' is returned.
##
##  `TestPerm3' returns the list of all those class functions in the list
##  <chars> that satisfy criterion (h); this is a stronger version of (T6).
##
##  `TestPerm4' returns the list of all those class functions in the list
##  <chars> that satisfy (T8) and (T9) for each prime divisor $p$ of the
##  order of $G$;
##  these tests use modular representation theory but do not require the
##  knowledge of decomposition matrices (cf.~`TestPerm5' below).
##
##  (T8) implements the test of the fact that in the case that $p$ divides
##  $|G|$ and the degree of a transitive permutation character $\pi$ exactly
##  once,
##  the projective cover of the trivial character is a summand of $\pi$.
##  (This test is omitted if the projective cover cannot be identified.)
##
##  Given a permutation character $\pi$ of a group $G$ and a prime integer
##  $p$, the restriction $\pi_B$ to a $p$-block $B$ of $G$ has the following
##  property, which is checked by (T9).
##  For each $g\in G$ such that $g^n$ is a $p$-element of $G$,
##  $\pi_B(g^n)$ is a nonnegative integer that satisfies
##  $|\pi_B(g)| \leq \pi_B(g^n) \leq \pi(g^n)$.
##  (This is Corollary~A on p.~113 of~\cite{Sco73}.)
##
##  `TestPerm5' requires the $p$-modular Brauer table <modtbl> of $G$,
##  for some prime $p$ dividing the order of $G$,
##  and checks whether those characters in the list <chars> whose degree is
##  divisible by the $p$-part of the order of $G$ can be decomposed into
##  projective indecomposable characters;
##  `TestPerm5' returns the sublist of all those characters in <chars>
##  that either satisfy this condition or to which the test does not apply.
##
#T Say a word about (T7)?
#T This is the check whether the cycle structure of elements is well-defined;
#T the check is superfluous (at least) for elements of prime power order
#T or order equal to the product of two primes (see~\cite{NPP84});
#T note that by construction, the numbers of ``cycles'' are always integral,
#T the only thing to test is whether they are nonnegative.
##
DeclareGlobalFunction( "TestPerm1" );
DeclareGlobalFunction( "TestPerm2" );
DeclareGlobalFunction( "TestPerm3" );
DeclareGlobalFunction( "TestPerm4" );
DeclareGlobalFunction( "TestPerm5" );


#############################################################################
##
#F  PermChars( <tbl> )
#F  PermChars( <tbl>, <degree> )
#F  PermChars( <tbl>, <arec> )
##
##  {\GAP} provides several algorithms to determine
##  possible permutation characters from a given character table.
##  They are described in detail in~\cite{BP98}.
##  The algorithm is selected from the choice of the record components of the
##  optional argument record <arec>.
##  The user is encouraged to try different approaches,
##  especially if one choice fails to come to an end.
##
##  Regardless of the algorithm used in a specific case,
##  `PermChars' returns a list of *all* possible permutation characters
##  with the properties described by <arec>.
##  There is no guarantee that a character of this list is in fact
##  a permutation character.
##  But an empty list always means there is no permutation character
##  with these properties (e.g., of a certain degree).
##
##  In the first form `PermChars' returns the list of all
##  possible permutation characters of the group with character table <tbl>.
##  This list might be rather long for big groups,
##  and its computation might take much time.
##  The algorithm is described in Section~3.2 in~\cite{BP98};
##  it depends on a preprocessing step, where the inequalities
##  arising from the condition $\pi(g) \geq 0$ are transformed into
##  a system of inequalities that guides the search (see~"Inequalities").
##  So the following commands compute the list of 39 possible permutation
##  characters of the Mathieu group $M_{11}$.
##  \beginexample
##  gap> m11:= CharacterTable( "M11" );;
##  gap> SetName( m11, "m11" );
##  gap> perms:= PermChars( m11 );;
##  gap> Length( perms );
##  39
##  \endexample
##  There are two different search strategies for this algorithm.
##  The default strategy simply constructs all characters with nonnegative
##  values and then tests for each such character whether its degree
##  is a divisor of the order of the group.
##  The other strategy uses the inequalities to predict
##  whether a character of a certain degree can lie
##  in the currently searched part of the search tree.
##  To choose this strategy, use the third form of `PermChars'
##  and set the component `degree' to the range of degrees
##  (which might also be a range containing all divisors of the group order)
##  you want to look for;
##  additionally, the record component `ineq' can take the inequalities
##  computed by `Inequalities' if they are needed more than once.
##
##  In the second form `PermChars' returns the list of all
##  possible permutation characters of <tbl> that have degree <degree>.
##  For that purpose, a preprocessing step is performed where
##  essentially the rational character table is inverted
##  in order to determine boundary points for the simplex
##  in which the possible permutation characters of the given degree
##  must lie (see~"PermBounds").
##  The algorithm is described at the end of Section~3.2 in~\cite{BP98};
##  Note that inverting big integer matrices needs a lot of time and space.
##  So this preprocessing is restricted to groups with less than 100 classes,
##  say.
##  \beginexample
##  gap> deg220:= PermChars( m11, 220 );
##  [ Character( m11, [ 220, 4, 4, 0, 0, 4, 0, 0, 0, 0 ] ), 
##    Character( m11, [ 220, 12, 4, 4, 0, 0, 0, 0, 0, 0 ] ), 
##    Character( m11, [ 220, 20, 4, 0, 0, 2, 0, 0, 0, 0 ] ) ]
##  \endexample
##
##  In the third form `PermChars' returns the list of all
##  possible permutation characters that have the properties described by
##  the argument record <arec>.
##  One such situation has been mentioned above.
##  If <arec> contains a degree as value of the record component `degree'
##  then `PermChars' will behave exactly as in the second form.
##  \beginexample
##  gap> deg220 = PermChars( m11, rec( degree:= 220 ) );
##  true
##  \endexample
##  For the meaning of additional components of <arec> besides `degree',
##  see~"PermComb".
##
##  Instead of `degree', <arec> may have the component `torso' bound
##  to a list that contains some known values of the required characters
##  at the right positions;
##  at least the degree `<arec>.torso[1]' must be an integer.
##  In this case, the algorithm described in Section~3.3 in~\cite{BP98}
##  is chosen.
##  The component `chars', if present, holds a list of all those *rational*
##  irreducible characters of <tbl> that might be constituents of the
##  required characters.
##
##  (*Note*: If `<arec>.chars' is bound and does not contain *all* rational
##  irreducible characters of <tbl>, {\GAP} checks whether the scalar
##  products of all class functions in the result list with the omitted
##  rational irreducible characters of <tbl> are nonnegative;
##  so there should be nontrivial reasons for excluding a character
##  that is known to be not a constituent of the desired possible permutation
##  characters.)
##  \beginexample
##  gap> PermChars( m11, rec( torso:= [ 220 ] ) );
##  [ Character( m11, [ 220, 4, 4, 0, 0, 4, 0, 0, 0, 0 ] ), 
##    Character( m11, [ 220, 20, 4, 0, 0, 2, 0, 0, 0, 0 ] ), 
##    Character( m11, [ 220, 12, 4, 4, 0, 0, 0, 0, 0, 0 ] ) ]
##  gap> PermChars( m11, rec( torso:= [ 220,,,,, 2 ] ) );
##  [ Character( m11, [ 220, 20, 4, 0, 0, 2, 0, 0, 0, 0 ] ) ]
##  \endexample
##
##  An additional restriction on the possible permutation characters computed
##  can be forced if <arec> contains, in addition to `torso',
##  the components `normalsubgroup' and `nonfaithful',
##  with values a list of class positions of a normal subgroup $N$ of the
##  group $G$ of <tbl> and a possible permutation character $\pi$ of $G$,
##  respectively, such that $N$ is contained in the kernel of $\pi$.
##  In this case, `PermChars' returns the list of those possible permutation
##  characters $\psi$ of <tbl> coinciding with `torso' wherever its values
##  are bound
##  and having the property that no irreducible constituent of $\psi-\pi$
##  has $N$ in its kernel.
##  If the component `chars' is bound in <arec> then the above statements
##  apply.
##  An interpretation of the computed characters is the following.
##  Suppose there exists a subgroup $V$ of $G$ such that $\pi = (1_V)^G$;
##  Then $N \leq V$, and if a computed character is of the form $(1_U)^G$
##  for a subgroup $U$ of $G$ then $V = UN$.
##  \beginexample
##  gap> s4:= CharacterTable( "Symmetric", 4 );;
##  gap> nsg:= ClassPositionsOfDerivedSubgroup( s4 );;
##  gap> pi:= TrivialCharacter( s4 );;
##  gap> PermChars( s4, rec( torso:= [ 12 ], normalsubgroup:= nsg,
##  >                        nonfaithful:= pi ) );
##  [ Character( CharacterTable( "Sym(4)" ), [ 12, 2, 0, 0, 0 ] ) ]
##  gap> pi:= Sum( Filtered( Irr( s4 ),
##  >              chi -> IsSubset( ClassPositionsOfKernel( chi ), nsg ) ) );
##  Character( CharacterTable( "Sym(4)" ), [ 2, 0, 2, 2, 0 ] )
##  gap> PermChars( s4, rec( torso:= [ 12 ], normalsubgroup:= nsg,
##  >                        nonfaithful:= pi ) );
##  [ Character( CharacterTable( "Sym(4)" ), [ 12, 0, 4, 0, 0 ] ) ]
##  \endexample
##
##  The class functions returned by `PermChars' have the properties tested by
##  `TestPerm1', `TestPerm2', and `TestPerm3'.
##  So they are possible permutation characters.
##  See~"TestPerm1" for criteria whether a possible permutation character can
##  in fact be a permutation character.
##
DeclareGlobalFunction( "PermChars" );


#############################################################################
##
#O  Inequalities( <tbl>, <chars>[, <option>] )
##
##  Let <tbl> be the ordinary character table of a group $G$.
##  The condition $\pi(g) \geq 0$ for every possible permutation character
##  $\pi$ of $G$ places restrictions on the multiplicities $a_i$
##  of the irreducible constituents $\chi_i$
##  of $\pi = \sum_{i=1}^r a_i \chi_i$.
##  For every element $g \in G$, we have $\sum_{i=1}^r a_i \chi_i(g) \geq 0$.
##  The power maps provide even stronger conditions.
##
##  This system of inequalities is kind of diagonalized,
##  resulting in a system of inequalities restricting $a_i$
##  in terms of $a_j$, $j \< i$.
##  These inequalities are used to construct characters with nonnegative
##  values (see~"PermChars").
##  `PermChars' either calls `Inequalities' or takes this information
##  from the `ineq' component of its argument record.
##
##  The number of inequalities arising in the process of diagonalization may
##  grow very strongly.
##
##  There are two ways to organize the projection.
##  The first, which is chosen if no <option> argument is present,
##  is the straight approach which takes the rational irreducible
##  characters in their original order and by this guarantees the character
##  with the smallest degree to be considered first.
##  The other way, which is chosen if the string `\"small\"' is entered as
##  third argument <option>, tries to keep the number of intermediate
##  inequalities small by eventually changing the order of characters.
##
DeclareOperation( "Inequalities", [ IsOrdinaryTable, IsList ] );
DeclareOperation( "Inequalities", [ IsOrdinaryTable, IsList, IsObject ] );


#############################################################################
##
#F  Permut( <tbl>, <arec> )
##
##  `Permut' computes possible permutation characters of the character table
##  <tbl> by the algorithm that solves a system of inequalities.
##  This is described in Section~3.2 in~\cite{BP98}.
##
##  <arec> must be a record.
##  Only the following components are used in the function.
##  \beginitems
##  `ineq' &
##      the result of `Inequalities' (see~"Inequalities"),
##      will be computed if it is not present,
##  `degree' &
##      the list of degrees for which the possible permutation characters
##      shall be computed,
##      this will lead to a speedup only if the range of degrees is
##      restricted.
##  \enditems
##
DeclareGlobalFunction( "Permut" );


#############################################################################
##
#F  PermBounds( <tbl>, <d> ) . . . . . . . . . .  boundary points for simplex
##
##  Let <tbl> be the ordinary character table of the group $G$.
##  All $G$-characters $\pi$ satisfying $\pi(g) > 0$ and $\pi(1) = <d>$,
##  for a given degree <d>, lie in a simplex described by these conditions.
##  `PermBounds' computes the boundary points of this simplex for  $d = 0$,
##  from which the boundary points for any other <d> are easily derived.
##  (Some conditions from the power maps of <tbl> are also involved.)
##  For this purpose, a matrix similar to the rational character table of $G$
##  has to be inverted.
##  These boundary points are used by `PermChars' (see~"PermChars")
##  to construct all possible permutation characters
##  (see~"Possible Permutation Characters") of a given degree.
##  `PermChars' either calls `PermBounds' or takes this information from the
##  `bounds' component of its argument record.
##
DeclareGlobalFunction( "PermBounds" );


#############################################################################
##
#F  PermComb( <tbl>, <arec> ) . . . . . . . . . . . .  permutation characters
##
##  `PermComb' computes possible permutation characters of the character
##  table <tbl> by the improved combinatorial approach
##  described at the end of Section~3.2 in~\cite{BP98}.
##
##  For computing the possible linear combinations *without* prescribing
##  better bounds (i.e., when the computation of bounds shall be suppressed),
##  enter `<arec>:= rec( degree := <degree>, bounds := false )',
##  where <degree> is the character degree;
##  this is useful if the multiplicities are expected to be small,
##  and if this is forced by high irreducible degrees.
##
##  A list of upper bounds on the multiplicities of the rational irreducibles
##  characters can be explicitly prescribed as a `maxmult' component in
##  <arec>.
##
DeclareGlobalFunction( "PermComb" );


#############################################################################
##
#F  PermCandidates( <tbl>, <characters>, <torso> )
##
##  `PermCandidates' computes possible permutation characters of the
##  character table <tbl> with the strategy using Gaussian elimination,
##  which is described in Section~3.3 in~\cite{BP98}.
##
##  The class functions in the result have the additional properties that
##  only the (necessarily rational) characters <characters> occur as
##  constituents, and that they are all completions of <torso>.
##  (Note that scalar products with rational irreducible characters of <tbl>
##  that are omitted in <characters> may be negative,
##  so not all class functions in the result list are necessarily characters
##  if <characters> does not contain all rational irreducible characters of
##  <tbl>.)
##
##  Known values of the candidates must be nonnegative integers in <torso>,
##  the other positions of <torso> are unbound;
##  at least the degree `<torso>[1]' must be an integer.
#T what about choice lists ??
##
DeclareGlobalFunction( "PermCandidates" );


#############################################################################
##
#F  PermCandidatesFaithful( <tbl>, <chars>, <norm_subgrp>, <nonfaithful>,
#F                          <lower>, <upper>, <torso> )
##
##  computes certain possible permutation characters of the character table
##  <tbl> with a generalization of the strategy using Gaussian elimination
##  (see~"PermCandidates").
##  These characters are all with the following properties.
##  \beginlist%ordered
##  \item{1.}
##     Only the (necessarily rational) characters <chars> occur as
##     constituents,
##
##  \item{2.}
##     they are completions of <torso>, and
##
##  \item{3.}
##     have the character <nonfaithful> as maximal constituent with kernel
##     <norm_subgrp>.
##  \endlist
##
##  Known values of the candidates must be nonnegative integers in <torso>,
##  the other positions of <torso> are unbound;
##  at least the degree `<torso>[1]' must be an integer.
##
DeclareGlobalFunction( "PermCandidatesFaithful" );


#############################################################################
##
#E

