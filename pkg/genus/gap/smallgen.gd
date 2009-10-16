#############################################################################
##
#W  smallgen.gd            GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: smallgen.gd,v 1.4 2002/05/24 15:06:47 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.( "pkg/genus/smallgen_gd" ) :=
    "@(#)$Id: smallgen.gd,v 1.4 2002/05/24 15:06:47 gap Exp $";


#############################################################################
##
#F  WeakTestGeneration( <C>, <g>, <G> )
##
##  We are interested in the question whether $\Epi_{<C>}( <g>, <G> )$ is
##  empty, where <C> is a class structure of the group <G>.
##
##  `WeakTestGeneration' returns
##  `true'
##       if $\Epi_{<C>}( <g>, <G> )$ is necessarily nonempty,
##  `false'
##       if $\Epi_{<C>}( <g>, <G> )$ is necessarily empty,
##  `fail'
##       if no decision is possible,
##
##  according to the following criteria.
##
##  1. $|\Epi_{<C>}(<g>,<G>)|$ is a multiple of $|<G>|/|Z(<G>)|$,
##     and we compute $|\Hom_{<C>}(<g>,<G>)|$ via the character table of <G>.
##
##  2. Scott's criterion of nongeneration is used if $<g> = 0$.
##     (Note that this criterion does also cover the criterion that all
##     classes of <C> except one are contained in a proper normal subgroup.)
##
##  3. If <C> covers all maximal cyclic subgroups of <G> then we have
##     $\Epi_{<C>}( <g>, <G> ) = \Hom_{<C>}( <g>, <G> )$.
##
#T other criteria of nongeneration?
#T allow nonconstructive tests (if permchars/maxes are known)
#T all these criteria are char. theoretic;
#T why enter group and not table as argument?
##
DeclareGlobalFunction( "WeakTestGeneration" );


#############################################################################
##
#F  HardTestGeneration( <C>, <g>, <G> )
#F  HardTestGeneration( <C>, <g>, <G>, "single" )
##
##  Let <G> be a group, let <C> be a list of positive integers denoting
##  positions of conjugacy classes of <G>, and let <g> be a nonnegative
##  integer.
##
##  `HardTestGeneration' returns `fail' if $\Epi_{<C>}( <g>, <G> )$ is empty.
##  Otherwise, in the first case the result is a list of vectors of the form
##  $$
##     [ a_1, b_1, a_2, b_2,\ldots, a_{<g>}, b_{<g>}, c_1, c_2,\ldots, c_r ]
##  $$
##  describing elements in $\Epi_{<C>}( <g>, <G> )$;
##  in the second case the result is one such vector.
##
##  (The test is done by looping over orbits of candidate vectors, under
##  conjugation action of <G>.)
##
DeclareGlobalFunction( "HardTestGeneration" );


#############################################################################
##
#F  RepresentativesEpimorphisms( <signature>, <G>[, <arec>] )
##
##  Let <signature> be the signature $(g_0; m_1, m_2, \ldots, m_r)$,
##  with $m_1 \leq m_2 \leq \cdots m_r$, and <G> a finite group.
##  `RepresentativesEpimorphisms' returns a list of records (each describing
##  a surface kernel epimorphism from the group $\Gamma$ with signature
##  <signature> onto <G>), with the following components. 
##  \beginitems
##  `signature' &
##      <signature>,
##
##  `group' &
##      <G>,
##
##  `classes' &
##      a list $[ i_1, i_2, \ldots, i_r ]$ of class positions for <G>
##      such that the image of the $k$-th elliptic generator of $\Gamma$ lies
##      in class $i_k$, and
##
##  `images' &
##      a list $[ h_1, h_2, \ldots, h_{2g}, g_1, g_2, \ldots, g_r ]$
##      of elements in <G> such that mapping the hyperbolic generators of
##      $\Gamma$ to the $h_i$ and mapping the elliptic generators of $\Gamma$
##      to the $g_i$ defines an epimorphism.
##  \enditems
##
##  If only the arguments <signature> and <G> are given then the return value
##  is a list of representatives of surface kernel epimorphisms from $\Gamma$
##  to $G$, up to $G$-conjugacy.
#T Well, the `classes' vector is always *sorted*!
##  If a record <arec> is given as the third argument then the following
##  components influence the output value.
##  \beginitems
##  `single' &
##      if the value is `true' then only one record describing an epimorphism
##      is returned if exists,
##  `action' &
##      a permutation group that describes an action on the conjugacy classes
##      of <G>; only representatives modulo the action of this group are
##      computed,
#T is this sufficient to describe outer automorphisms on the orbits?
##  `noreps' &
##      if the value is `true' then the returned records have no component
##      `images'.
##  \enditems
#T Allow more specific input,
#T for example how many periods are mapped into certain classes of cyclic
#T subgroups!
##
DeclareGlobalFunction( "RepresentativesEpimorphisms" );


#############################################################################
##
#F  AdmissibleGroups( <g>, <n>, <sign> )
##
##  is the list of all groups of order <n> that can be epimorphic images of a
##  Fuchsian group $\Gamma$ with signature
##  $<sign> = [ g_0, m_1, m_2, \ldots, m_r ]$, with torsion-free kernel.
##  (The kernel has then orbit genus <g>.)
##
##  The following criteria are used.
##
##  1. If one of the $m_i$ is equal to $n$ then the group must be cyclic.
##
##  2. The signature $[ 0, 2, 2(g+1), 2(g+1) ]$ allows for even $g$
##     only the group $2 \times 2(g+1)$.
##
##  3. Otherwise we use the library of small groups $G$.
##
##  4. The elementary divisors of $\Gamma$ and $G$ must be compatible.
##
DeclareGlobalFunction( "AdmissibleGroups" );


#############################################################################
##
#F  AllCRSAutomorphismGroupsInfo( <g> )
#F  AllCRSAutomorphismGroupsInfo( <g>, <sign> )
#F  AllCRSAutomorphismGroupsInfo( <g>, <sign>, "generators" )
##
##  Let <g> be a positive integer between $2$ and $\MAXGENUS$,
##  and <sign> a compact signature.
##
##  In the first form, `AllCRSAutomorphismGroups' returns a list of all those
##  groups, up to isomorphism, that occur as surface kernel images of
##  Fuchsian groups with signature <sign>,
##  where the kernel has orbit genus <g>.
##  (If <g> is larger than $\MAXGENUS$ then `fail' is returned.)
##
##  In the second form, the string `"generators"' must be given as the third
##  argument.
##  Then `AllCRSAutomorphismGroups' returns a list of pairs $[ G, l ]$ where
##  the first entries $G$ are the groups returned by the first form,
##  and the second entries $l$ are the corresponding lists of vectors
#T  ...
##  up to conjugacy in $G$.
#T  (or in Aut(G)?)
##
DeclareGlobalFunction( "AllCRSAutomorphismGroupsInfo" );


#############################################################################
##
#F  EichlerCharactersInfo( <g> )
##
##  is a list of pairs $[ G, \chi ]$ where $\chi$ is a character of the group
##  $G$ that comes from a Riemann surface of genus <g>.
##  (We must have $<g> \geq 2$.)
##
##  The pairs are ordered w.r.t. descending orbit genus $g_0$,
##  ascending group order $n$,
##
DeclareGlobalFunction( "EichlerCharactersInfo" );

#T is that meaningful?


#############################################################################
##
#F  DescribesFullAutomorphismGroup( <sign>, <G> )
##
##  Let <sign> be a signature, $\Gamma = \Gamma( <sign> )$,
##  and <G> be a group that is a surface kernel image of $\Gamma$;
##  furthermore let $K$ denote the kernel of the epimorphism.
##  `DescribesFullAutomorphismGroup' returns `true' if <sign> and <G>
##  describe a *full* automorphism group of a compact Riemann surface,
##  that is, if there is a Fuchsian group $\tilde{\Gamma} \< \Aut(\HH)$
##  such that $\tilde{\Gamma}$ is the full normalizer of $K$ in $\Aut(\HH)$.
##  Otherwise `false' is returned.
##
##  The idea of the algorithm is as follows.
##  \cite{Sin72} lists all those pairs $(\sigma,\sigma_0)$ of compact
##  signatures with the property that each Fuchsian group isomorphic with
##  $\Gamma(\sigma)$ is contained in a Fuchsian group isomorphic with
##  $\Gamma(\sigma_0)$.
##  If <sign> does not occur as $\sigma$ in this list then <sign> and <G>
##  necessarily describe a full automorphism group.
##  Now suppose that <sign> occurs as $\sigma$ in this list.
##  Then we check the corresponding signatures $\sigma_0$ and all groups $S$
##  that are surface kernel images of $\Gamma(\sigma_0)$ whether there is an
##  embedding $\iota \colon \Gamma(\sigma) \hookrightarrow \Gamma(\sigma_0)$
##  that induces an embedding of $G$ into $S$ compatible with the surface
##  kernel epimorphisms;
##  <sign> and <G> describe a full automorphism group if and only if
##  there is no such embedding.
##  
DeclareGlobalFunction( "DescribesFullAutomorphismGroup" );


#############################################################################
##
#E

