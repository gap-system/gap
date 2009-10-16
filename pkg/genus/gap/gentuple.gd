#############################################################################
##
#W  gentuple.gd            GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: gentuple.gd,v 1.3 2002/05/24 15:06:47 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains some functions dealing with questions of generation
##  of class structures.
##
Revision.( "genus/gap/gentuple_gd" ) :=
    "@(#)$Id: gentuple.gd,v 1.3 2002/05/24 15:06:47 gap Exp $";


#T function that computes all signatures in decreasing order of the
#T group, starting with (2,3,7); 
#T a refined version could take a group order, and periods are allowed only
#T for divisors of this order
#T (this is used for computing the strong symm. genus then, start with the
#T most optimistic signatures)


#############################################################################
##
#V  InfoGenTuple
##
DeclareInfoClass( "InfoGenTuple" );


#############################################################################
##
#V  STATISTICS
#F  IncreaseSTAT( <component> )
##
if not IsBound( STATISTICS ) then
    STATISTICS := false;
fi;

IncreaseSTAT := function( component )
    if STATISTICS <> false then
      STATISTICS.( component ):= STATISTICS.( component ) + 1;
    fi;
end;


#############################################################################
##
#F  CardinalityOfHomToSubgroup( <tbl>, <subtbl>, <g0>, <tuple> )
##
##  is the number of tuples in the group $S$ with table <subtbl> that fuse
##  into <tuple> in the group $G$ with table <tbl>.
#T what is <g0> ??
##
DeclareGlobalFunction( "CardinalityOfHomToSubgroup" );


#############################################################################
##
#F  NongenerationByEichlerCriterion( <tbl>, <tuple> )
##
DeclareGlobalFunction( "NongenerationByEichlerCriterion" );


#############################################################################
##
#F  IsGeneratingTuple( <tbl>, <g0>, <tuple>, <maxesdata>, <super> )
##
##  better change name to `TestGeneratingTuple'?
##
##  Let <tbl> be the ordinary character table of the group $G$, say,
##  <g0> a nonnegative integer, <tuple> a vector of class positions of <tbl>,
##  <maxesdata> a list that describes *all* (conjugacy classes of)
##  maximal subgroups of $G$,
##  and <super> a (possibly empty) list of ordinary character tables
##  of supergroups $U$ of $G$ with the property that $C_U(G) = Z(G)$
##  (this is always true if $G$ is maximal and not normal in $U$).
##
##  The $i$-th entry of <maxesdata> must be either the primitive permutation
##  character of the action of $G$ on the cosets of the $i$-th maximal
##  subgroup, or the character table of the $i$-th maximal subgroup,
##  or `false'.
##
##  The class fusions from <tbl> into the tables in <super>
##  and the class fusions from the maximal subgroups into <tbl> must be
##  stored or uniquely determined (see~"ref:FusionConjugacyClasses" in the
##  {\GAP} Reference Manual).
##
##  Called with these arguments, `IsGeneratingTuple' returns `true' if
##  $\Epi_{<tuple>}( <g0>, G )$ is proved to be nonempty, `false' if the set
##  is proved to be empty, and `fail' if the criteria used do not admit a
##  decision.
##
##  The following tests for nongeneration are performed.
##
##  1. $|\Hom_{<tuple>}(0,G)| \geq [ G \colon Z(G) ]$ if the tuple
##     generates $G$.
##
##  2. Scott's trick (Matrices and cohomology, Ann. of Math. 1977):
##
##     Let $V$ be a $G$-module of dimension $n$,
##     $G = \langle g_1, g_2, \ldots, g_m \rangle$ with
##     $g_1 g_2 \cdots g_m = 1$, and $v(g,V)$ the dimension of the
##     fixed space of $\langle g \rangle$ on $V$.
##     Then $\sum_{i=1}^m v(g_i,V) \leq (m-2) n + v(G,V) + v(G,v^{\ast})$.
##
##     (Note that Ree's trick (A theorem on permutations,
##     J. Combin. Theory Ser. A 1971) is just a special case, as well as
##     Conder's trick (...).)
##
##  3. If the third argument <maxes> is a list of tables of maximal subgroups
##     then it is checked whether a single maximal subgroup contains enough
##     tuples to exclude generation together with criterion 1.
##
##  4. For each table $T$ in the list <super>,
##     $|\Hom_K(0,U)| \geq [ U \colon Z(G) ]$ if <tuple> generates $G$,
##     where $U$ is the group of $T$, and $K$ is a class structure of $U$
##     that covers <tuple>.
##
##  The following criteria are used for proving generation.
##
##  1. If <tuple> generates then $|\Hom_{<tuple>}(0,G)|\geq [G\colon Z(G)]$.
#T better criterion for g0 > 0 ?
##  2. If each permutation character is zero on at least one of the classes
##     of <tuple> and if 1. is satisfied then <tuple> generates.
##  3. If the sum of tuples of all maximal subgroups fusing into <tuple> is
##     smaller than $|\Hom_{<tuple>}(<g0>,G)|$ then <tuple> generates.
##
##  (Note that 1. just needs the table, 2. needs all primitive permutation
##  characters of the table, and 3. needs the ordinary character tables
##  of all those maximal subgroups of $G$ for which the permutation character
##  is nonzero on all classes of <tuple>.)
##
DeclareGlobalFunction( "IsGeneratingTuple" );


#############################################################################
##
#F  ApplyShiftLemma( <tbl>, <info> )
##
DeclareGlobalFunction( "ApplyShiftLemma" );


#############################################################################
##
#F  GeneratingTuplesInfo( <tbl>, <r>, <primitives>, <super> )
##
##  <tbl> character table of group $G$,
##  <r> : consider <r>-tuples,
##  <primitives> : either list of tables of all maxes of $G$ or `false',
##  <super> : list of tables of overgroups $U$ of $G$ such that $C_U(G)$
##            is trivial
##
##  returns a record with components `possible', `necessary', and `complete'.
##  The first two are lists of <r>-tuples $(i_1, i_2, \ldots, i_{<r>})$,
##  with $i_1 \leq i_2 \leq \ldots \leq i_{<r>}$.
##  The `complete' component is `true',
##  this means that the record contains information about *all* <r>-tuples
##  for <tbl>.
##
##  The `possible' list contains all <r>-tuples that possibly generate the
##  group $G$ with character table <tbl>
##  (in the sense of `IsGeneratingTuple').
##
##  The `necessary' list contains all those <r>-tuples that necessarily
##  generate $G$, see `IsGeneratingTuple'.
##  For finding such <r>-tuples, the list <primitives> must describe 
##  *all* classes of maximal subgroups of $G$.
##  The $i$-th entry must be either the $i$-th permutation character
##  or the character table of the $i$-th maximal subgroup,
##  or a string that is an admissible name of this table in the {\GAP} table
##  library.
##
DeclareGlobalFunction( "GeneratingTuplesInfo" );


#############################################################################
##
#F  IsGeneratingTriple( <grp>, <classlist>, <triple> )
##
##  ...
##
DeclareGlobalFunction( "IsGeneratingTriple" );


#############################################################################
##
#F  GeneratingTriples( <classlist> )
##
##  is the list of triples $[ i, j, k ]$ for that there is at least one pair
##  in the $i$-th and $j$-th class of <classlist> with product in class $k$
##  such that the underlying group is generated by these elements.
##
DeclareGlobalFunction( "GeneratingTriples" );


#############################################################################
##
#F  RandomFindGeneration( <G>, <tbl>, <ijk>, <g_ig_j>, <n> )
##
##  Try to find $(i,j,k)$ generation of the group <G>, using random methods.
##
##  <tbl> is the character table of <G>.
##  It is *not* required that the conjugacy classes of <tbl> are sorted
##  consistently with those of <G>, or that the conjugacy classes of <G>
##  are already computed.
##
##  <ijk> is a list of either positions or class names, to be understood
##  w.r.t. <tbl>.
##  (also possible to have a list of possible positions for <k>)
##
##  <gigj> is a list of elements of <G>, containing one element of
##  class $i$ and one element of class $j$.
##  (if unbound then these elements are constructed using random
##  methods)
##
##  <n> is the maximal number of tries to be carried out.
##
##  The containment in a particular class is identified by element order
##  and centralizer order.
#T  (use power maps if necessary?)
##
DeclareGlobalFunction( "RandomFindGeneration" );


#############################################################################
##
#F  MonodromyGenus( <tbl>, <permchar>, <listoftuples> )
##
##  Let $G$ be a group with character table <tbl>, and <permchar> a
##  transitive permutation character of $G$.
##  Each entry in the list <listoftuples> is of the form
##  $[ i_1, i_2, \ldots, i_t ]$, and denotes a (generating) tuple of $G$;
##  this defines a branched covering of the Riemann sphere.
##  The list of genera $\gamma$ of the corresponding Riemann surfaces
##  is returned.
##
##  $\gamma$ is defined as $1 - n + \frac{1}{2} B$ where $n$ is the
##  degree of the permutation action, and $B = \sum_{i=1}^t ( n - \nu(g_i) )$
##  where $\nu(g_i)$ is the number of orbits of $g_i$ on
##  $\{ 1, 2, \ldots, n \}$.
##
DeclareGlobalFunction( "MonodromyGenus" );


#############################################################################
##
#F  UpperBoundMonodromyGenus( <tbl>, <permchars>, <info> )
##
##  is an upper bound of the monodromy genus of the group $G$ with character
##  table <tbl>.
##  This is the minimum of genera obtained from necessary generation of $G$
##  as denoted in `<info>.necessary', and minimized over the primitive
##  permutation characters in the list <permchars> (not necessarily all
##  primitive permutation characters for $G$).
##
DeclareGlobalFunction( "UpperBoundMonodromyGenus" );


#############################################################################
##
#F  UpperBoundStrongSymmetricGenus( <tbl>, <info> )
##
##  is an upper bound of the strong symmetric genus of the group $G$ with
##  character table <tbl>.
##  <info> must be a record with components `necessary' and `possible',
##  as computed by `GeneratingTuplesInfo'.
##
##  If `<info>.complete' is `true' then
##  the result is the minimum of genera obtained from necessary generation of
##  $G$ as denoted in `<info>.necessary'.
##
#T  Otherwise the minimum of genera for the entries of `<info>.necessary' is
#T  taken, and tuples that might yield smaller genus are listed and checked.
##
DeclareGlobalFunction( "UpperBoundStrongSymmetricGenus" );


#############################################################################
##
#F  MinimalCyclicGenus( <n> )
##
##  is the minimal genus $\geq 2$ of a compact Riemann surface that admits
##  an automorphism of order <n>.
##
##  The proof of this bound can be found in
##  W.J. Harvey,
##  Cyclic Groups of Automorphisms of a Compact Riemann Surface,
##  Quart. J. Math. Oxford (2), 17 (1966), 86-97.
##
DeclareGlobalFunction( "MinimalCyclicGenus" );


#############################################################################
##
#F  NongenerationBySingleSubgroup( <tbl>, <subtbl>, <tuple> )
##
##  is `true' if Lemma~15.19 yields nongeneration for the group with
##  character table <grp> and the class structure $H$ given by the list
##  <tuple> of class positions in <tbl>,
##  where <subtbl> is the character table of the subgroup $H$.
##
DeclareGlobalFunction( "NongenerationBySingleSubgroup" );


#############################################################################
##
#F  OptimisticBoundStrongSymmetricGenus( arg )
##
DeclareGlobalFunction( "OptimisticBoundStrongSymmetricGenus" );


#############################################################################
##
#P  IsHurwitzGroup( <G> )
##
##  ... some text ...
##
DeclareProperty( "IsHurwitzGroup", IsGroup );


#############################################################################
##
#E

