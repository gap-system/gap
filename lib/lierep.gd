#############################################################################
##
#W  lierep.gd                   GAP library               Willem de Graaf
#W                                                    and Craig A. Struble
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declaration of attributes, properties, and
##  operations for modules over Lie algebras.
##
Revision.lierep_gd :=
    "@(#)$Id$";


#1
##
##  An $s$-cochain of a module $V$ over a Lie algebra $L$, is an $s$-linear
##  map
##  $$
##  c: L\times\cdots\times L \to V  \hbox{ ($s$ factors $L$)}
##  $$
##  that is skew-symmetric (meaning that if any of the arguments are
##  interchanged, $c$ changes to $-c$).
##
##  Let $\{x_1,\ldots,x_n\}$ be a basis of $L$. Then any $s$-cochain is 
##  determined by the values $c( x_{i_1},\ldots, x_{i_s} )$, where
##  $1\le i_1 \< i_2 \< \cdots \< i_s \le \dim L$.
##  Now this value again is a linear combination of basis elements of $V$:
##  $c( x_{i_1},\ldots, x_{i_s} ) = \sum \lambda^k_{i_1,\ldots, i_s} v_k$.
##  Denote the dimension of $V$ by $r$.
##  Then we represent an $s$-cocycle by a list of $r$ lists.
##  The $j$-th of those lists consists of entries of the form
##  $$
##  [  [i_1,i_2,\ldots,i_s], \lambda^j_{i_1,\ldots, i_s} ]
##  $$
##  where the coefficient on the second position is non-zero.
##  (We only store those entries for which this coefficient is non-zero.)
##  It follows that every $s$-tuple $(i_1,\ldots,i_s)$ gives rise to $r$ 
##  basis elements.
##
##  So the zero cochain is represented by a list of the form
##  $[ [ ], [ ], \ldots , [ ] ]$. Furthermore, if $V$ is, e.g., 
##  $4$-dimensional, then the $2$-cochain represented by
##
##  \begintt
##  [  [ [ [1,2], 2] ], [ ], [ [ [1,2], 1/2 ] ], [ ] ]
##  \endtt
##
##  maps the pair $(x_1,x_2)$ to $2v_1+1/2 v_3$ (where $v_1$ is the first
##  basis element of $V$, and $v_3$ the third), and all other pairs to zero.
##
##  By definition, $0$-cochains are constant maps $c( x ) = v_c\in V$ for all
##  $x \in L$. So $0$-cochains have a different representation: they are just
##  represented by the list $[ v_c ]$.
##
##  Cochains are constructed using the function `Cochain' (see~"Cochain"),
##  if <c> is a cochain, then its corresponding list is returned by
##  `ExtRepOfObj( <c> )'.
##


##############################################################################
##
#C  IsCochain( <obj> )
#C  IsCochainCollection( <obj> )
##
##  Categories of cochains and of collections of cochains.
##
DeclareCategory( "IsCochain", IsVector );
DeclareCategoryCollections( "IsCochain" );

#############################################################################
##
#O  Cochain( <V>, <s>, <obj> )
##
##  Constructs a <s>-cochain given by the data in <obj>, with respect to
##  the Lie algebra module <V>. If <s> is non-zero, then <obj> must be
##  a list.
##
DeclareOperation( "Cochain", [ IsLeftModule, IsInt, IsObject ] );

#############################################################################
##
#O  CochainSpace( <V>, <s> )
##
##  Returns the space of all <s>-cochains with respect to <V>.
##
DeclareOperation( "CochainSpace", [ IsAlgebraModule, IS_INT ] );

#############################################################################
##
#F  ValueCochain( <c>, <y1>, <y2>,...,<ys> )
##
##  Here <c> is an <s>-cochain. This function returns the value of
##  <c> when applied to the <s> elements <y1> to <ys> (that lie in the
##  Lie algebra acting on the module corresponding to <c>). It is also
##  possible to call this function with two arguments: first <c> and then
##  the list containing `<y1>,...,<ys>'.
##
DeclareGlobalFunction( "ValueCochain" );

#############################################################################
##
#V  LieCoboundaryOperator( <c> )
##
##  This is a function that takes an <s>-cochain, and returns an <s+1>-cochain.
##  The coboundary operator is applied.
##
DeclareGlobalFunction( "LieCoboundaryOperator", "Lie coboundary operator" );

#############################################################################
##
#O  Cocycles( <V>, <s> )
##
##  is the space of all <s>-cocycles with respect to the Lie algebra module
##  <V>. That is the kernel of the coboundary operator when  restricted to
##  the space of <s>-cochains.
##
DeclareOperation( "Cocycles", [ IsAlgebraModule, IS_INT  ] );

#############################################################################
##
#O  Coboundaries( <V>, <s> )
##
##  is the space of all <s>-coboundaries with respect to the Lie algebra
##  module <V>. That is the image of the coboundary operator, when applied
##  to the space of <s-1>-cochains. By definition the space of all
##  0-coboundaries is zero.
##
DeclareOperation( "Coboundaries", [ IsAlgebraModule, IS_INT ] );


############################################################################
##
#P  IsWeylGroup( <G> )
##
##  A Weyl group is a group generated by reflections, with the attribute
##  `SparseCartanMatrix' set.
##
DeclareProperty( "IsWeylGroup", IsGroup );

############################################################################
##
#A  WeylGroup( <R> )
##
##  The Weyl group of the root system <R>. It is generated by the simple
##  reflections. A simple reflection is represented by a matrix, and the
##  result of letting a simple reflection `m' act on a weight `w' is obtained
##  by `w*m'.
##
##
DeclareAttribute( "WeylGroup", IsRootSystem );

############################################################################
##
#A  SparseCartanMatrix( <W> )
##
##  This is a sparse form of the Cartan matrix of the
##  corresponding root system. If we denote the Cartan matrix by `C',
##  then the sparse Cartan matrix of <W> is a list (of length equal to the
##  length of the Cartan matrix), where the `i'-th entry is a list
##  consisting of elements `[ j, C[i][j] ]', where `j' is such that
##  `C[i][j]' is non-zero.
##
##
DeclareAttribute( "SparseCartanMatrix", IsWeylGroup );

############################################################################
##
#O  ApplySimpleReflection( <SC>, <i>, <wt> )
##
##  Here <SC> is the sparse Cartan matrix of a Weyl group. This
##  function applies the <i>-th simple reflection to the weight
##  <wt>, thus changing <wt>.
##
DeclareOperation( "ApplySimpleReflection", [ IsList, IS_INT, IsList ] );

############################################################################
##
#A  LongestWeylWordPerm( <W> )
##
##  Let $g_0$ be the longest element in the Weyl group <W>, and let
##  $\{\alpha_1,\ldots, \alpha_l\}$ be a simple system of the corresponding
##  root system. Then $g_0$ maps $\alpha_i$ to $-\alpha_{\sigma(i)}$, where
##  $\sigma$ is a permutation of $(1,\ldots ,l)$. This function returns
##  that permutation.
##
DeclareAttribute( "LongestWeylWordPerm", IsWeylGroup );

############################################################################
##
#O  ConjugateDominantWeight( <W>, <wt> )
#O  ConjugateDominantWeightWithWord( <W>, <wt> )
##
##  Here <W> is a Weyl group and <wt> a weight (i.e., a list of integers).
##  This function returns the unique dominant weight conjugate to <wt>
##  under <W>.
##
##  `ConjugateDominantWegihtWithWord( <W>, <wt> )' returns a list of two
##  elements. The first of these is the dominant weight conjugate do <wt>.
##  The second element is a list of indices of simple reflections that
##  have to be applied to <wt> in order to get the dominant weight conjugate
##  to it.
##
DeclareOperation( "ConjugateDominantWeight", [ IsWeylGroup, IsList ] );
DeclareOperation( "ConjugateDominantWeightWithWord", [ IsWeylGroup, IsList ]);


############################################################################
##
#O  WeylOrbitIterator( <W>, <wt> )
##
##  Returns an iterator for the orbit of the weight <wt> under the
##  action of the Weyl group <W>.
##
DeclareOperation( "WeylOrbitIterator", [ IsWeylGroup, IsList ] );

############################################################################
##
#A  PositiveRootsAsWeights( <R> )
##
##  Returns the list of positive roots of <R>, represented in the basis
##  of fundamental weights.
##
DeclareAttribute( "PositiveRootsAsWeights", IsRootSystem );

############################################################################
##
#O  DominantWeights( <R>, <maxw> )
##
##  Returns a list consisting of two lists. The first of these contains
##  the dominant weights (written on the basis of fundamental weights)
##  of the irreducible highest-weight module over the Lie algebra with
##  root system <R>. The $i$-th element of the second list is the
##  level of the $i$-th dominant weight. (Where level is defined as follows.
##  For a weight $\mu$ we write $\mu=\lambda-\sum_i k_i \alpha_i$, where
##  the $\alpha_i$ are the simple roots, and $\lambda$ the highest weight.
##  Then the level of $\mu$ is $\sum_i k_i$.
##
DeclareOperation( "DominantWeights", [ IsRootSystem, IsList ] );


############################################################################
##
#O  DominantCharacter( <L>, <maxw> )
#O  DominantCharacter( <R>, <maxw> )
##
##  For a highest weight <maxw> and a semisimple Lie algebra <L>, this
##  returns the dominant weights of the highest-weight module over <L>,
##  with highest weight <maxw>. The output is a list of two lists, the
##  first list contains the dominant weights; the second list contains
##  their multiplicities.
##
##  The first argument can also be a root system, in which case 
##  the dominant character of the highest-weight module over the
##  corresponding semisimple Lie algebra is returned. 
##
DeclareOperation( "DominantCharacter", [ IsRootSystem, IsList ] );


#############################################################################
##
#O  DecomposeTensorProduct( <L>, <w1>, <w2> )
##
##  Here <L> is a semisimple Lie algebra and <w1>, <w2> are dominant
##  weights. Let $V_i$ be the irreducible highest-weight module over <L>
##  with highest weight $w_i$ for $i=1,2$. Let $W=V_1\otimes V_2$. Then in
##  general $W$ is a reducible <L>-module. Now this function
##  returns a list of two lists. The first of these is the list of highest
##  weights of the irreducible modules occurring in the decomposition of
##  $W$ as a direct sum of irreducible modules. The second list contains
##  the multiplicities of these weights (i.e., the number of copies of
##  the irreducible module with the corresponding highest weight that occur
##  in $W$). The algorithm uses Klimyk's formula (see~\cite{Klimyk68} or
##  \cite{Klimyk66} for the original Russian version).
##
DeclareOperation( "DecomposeTensorProduct", [ IsLieAlgebra, IsList, IsList ] );


#############################################################################
##
#O  DimensionOfHighestWeightModule( <L>, <w> )
##
##  Here <L> is a semisimple Lie algebra, and <w> a dominant weight.
##  This function returns the dimension of the highest-weight module
##  over <L> with highest weight <w>. The algorithm
##  uses Weyl's dimension formula.
##
DeclareOperation( "DimensionOfHighestWeightModule", [ IsLieAlgebra, IsList ] );

#2
##  Let $L$ be a semisimple Lie algebra over a field of characteristic $0$,
##  and let $R$ be its root system. For a positive root $\alpha$ we let
##  $x_{\alpha}$ and $y_{\alpha}$ be positive and negative root vectors
##  respectively, both from a fixed Chevalley basis of $L$. Furthermore,
##  $h_1,\ldots, h_l$ are the Cartan elements from the same Chevalley
##  basis. Also we set
##  $$
##  x_{\alpha}^{(n)} = {x_{\alpha}^n \over n!}, \qquad
##  y_{\alpha}^{(n)} = {y_{\alpha}^n \over n!}\.
##  $$
##  Furthermore, let $\alpha_1,\ldots, \alpha_s$ denote the positive roots
##  of $R$. For multi-indices $N=(n_1,\ldots, n_s)$, $M=(m_1,\ldots, m_s)$
##  and $K=(k_1,\ldots, k_s)$ (where $n_i,m_i,k_i\geq 0$) set
##  $$
##  \matrix{
##  x^N &=& x_{\alpha_1}^{(n_1)}\cdots x_{\alpha_s}^{(n_s)},\cr
##  y^M &=& y_{\alpha_1}^{(m_1)}\cdots y_{\alpha_s}^{(m_s)},\cr
##  h^K &=& {h_1\choose k_1}\cdots {h_l\choose k_l}\cr
##  }
##  $$
##  Then by a theorem of Kostant, the $x_{\alpha}^{(n)}$ and
##  $y_{\alpha}^{(n)}$ generate a subring of the universal enveloping algebra
##  $U(L)$ spanned (as a free $Z$-module) by the elements
##  $$
##  y^Mh^Kx^N
##  $$
##  (see, e.g., \cite{Hum72} or \cite{Hum78}, Section 26)
##  So by the Poincare-Birkhoff-Witt theorem
##  this subring is a lattice in $U(L)$. Furthermore, this lattice is
##  invariant under the $x_{\alpha}^{(n)}$ and $y_{\alpha}^{(n)}$.
##  Therefore, it is called an admissible lattice in $U(L)$.
##
##  The next functions enable us to construct the generators of such an
##  admissible lattice.

##############################################################################
##
#C  IsUEALatticeElement( <obj> )
#C  IsUEALatticeElementCollection( <obj> )
#C  IsUEALatticeElementFamily( <fam> )
##
##  is the category of elements of an admissible lattice in the universal
##  enveloping algebra of a semisimple Lie algebra `L'.
##
DeclareCategory( "IsUEALatticeElement", IsVector and IsRingElement and
                     IsMultiplicativeElementWithOne );
DeclareCategoryCollections( "IsUEALatticeElement" );
DeclareCategoryFamily( "IsUEALatticeElement" );


##############################################################################
##
#A  LatticeGeneratorsInUEA( <L> )
##
##  Here <L> must be a semisimple Lie algebra of characteristic $0$.
##  This function returns a list of generators of an admissible lattice
##  in the universal enveloping algebra of <L>, relative to
##  the Chevalley basis contained in `ChevalleyBasis( <L> )'.
##  First are listed the negative root vectors (denoted by $y_1,\ldots, y_s$),
##  then the positive root vectors (denoted by $x_1,\ldots, x_s$). At the
##  end of the list there are the Cartan elements. They are printed as
##  `( hi/1 )', which means
##  $$
##  {h_i\choose 1}\.
##  $$
##  In general the printed form `( hi/ k )' means 
##  $$
##  {h_i\choose k}\.
##  $$
##
##  Also $y_i^{(m)}$ is printed as `yi^(m)', which means that entering
##  `yi^m' at the {\GAP} prompt results in the output `m!*yi^(m)'.
##
##  Products of lattice generators are collected using the following order:
##  first come the $y_i^{(m_i)}$ (in the same order as the positive roots),
##  then
##  the ${h_i\choose k_i},$ and then the $x_i^{(n_i)}$ (in the same order as
##  the positive roots).
##
DeclareAttribute( "LatticeGeneratorsInUEA", IsLieAlgebra );

##############################################################################
##
#F  CollectUEALatticeElement( <noPosR>, <BH>, <f>, <vars>, <Rvecs>, <RT>,
##                                                          <posR>, <lst> )
##
DeclareGlobalFunction( "CollectUEALatticeElement" );


##############################################################################
##
#C  IsWeightRepElement( <obj> )
#C  IsWeightRepElementCollection( <obj> )
#C  IsWeightRepElementFamily( <fam> )
##
##  Is a category of vectors, that is used to construct elements of
##  highest-weight modules (by `HighestWeightModule').
##
##  WeightRepElements are represented by a list of the form
##  `[ v1, c1, v2, c2, ....]', where the `v<i>' are basis vectors, and
##  the `c<i>' coefficients. Furthermore a basis vector `v' is a weight vector.
##  It is represented by a list of
##  form `[ <k>, <mon>, <wt> ]', where <k> is an integer (the basis vectors
##  are numbered from $1$ to $\dim V$, where $V$ is the highest weight
##  module), <mon> is an UEALatticeElement (which means that the result of
##  applying <mon> to a highest weight vector is `v') and <wt> is the weight
##  of <v>. A WeightRepElement is printed as `<mon>*v0', where `v0'
##  denotes a fixed highest weight vector.
##
##  If <v> is a WeightRepElement, then `ExtRepOfObj( <v> )' returns
##  the corresponding list, and if <list> is such a list and <fam> a
##  WeightRepElementFamily, then `ObjByExtRep( <list>, <fam> )' returns
##  the corresponding WeightRepElement.
##
DeclareCategory( "IsWeightRepElement", IsVector );
DeclareCategoryCollections( "IsWeightRepElement" );
DeclareCategoryFamily( "IsWeightRepElement" );

##############################################################################
##
#C  IsBasisOfWeightRepElementSpace( <B> )
##
##  A basis that lies in this category is a basis of a space of weight
##  rep elements. If a basis <B> lies in this category, then it has the
##  record components `<B>!.echelonBasis' (a list of basis vectors of
##  the same module as where <B> is a basis of, but in echelon form),
##  `<B>!.heads' (if `<B>!.heads[i] = k', then the number of the first
##  weight vector of `<B>!.echelonBasis[i]' is `k'; recall that all weight
##  vectors carry a number), and `<B>!.baseChange' (if `<B>!.baseChange[i]=
##  [ [m1,c1],...,[ms,cs] ]' then the `i'-th element of `<B>!.echelonBasis'
##  is of the form $c1 v_{m1}+\cdots +cs v_{ms}$, where the $v_j$ are the
##  basis vectors of <B>.
##
DeclareCategory( "IsBasisOfWeightRepElementSpace", IsBasis );


#############################################################################
##
#F  HighestWeightModule( <L>, <wt> )
##
##  returns the highest weight module with highest weight <wt> of the
##  semisimple Lie algebra <L> of characteristic $0$.
##
##  Note that the elements of such a module lie in the category
##  `IsLeftAlgebraModuleElement' (and in particular they do not lie
##  in the category `IsWeightRepElement'). However, if `v' is an element
##  of such a module, then `ExtRepOfObj( v )' is a WeightRepElement.
##
DeclareOperation( "HighestWeightModule", [ IsAlgebra, IsList ] );

#############################################################################
##
#F  LeadingUEALatticeMonomial( <novar>, <f> )
##
##  Here <f> is an `UEALatticeElement', and <novar> the number of generators
##  of the algebra containing <f>. This function returns a list of four
##  elements. The first element is the leading monomial of <f> (as it
##  occurs in the external representation of <f>). The second element is the
##  leading monomial of <f> represented as a list of length <novar>. The
##  i-th entry in this list is the exponent of the i-th generator in
##  the leading monomial. The third and fourth elements are, respectively,
##  the coefficient of the leading monomial and the index at which it
##  occurs in <f> (so that <f>!.[1][ind] is equal to the first element of
##  the output).
##
DeclareOperation( "LeadingUEALatticeMonomial",
                                   [ IsInt, IsUEALatticeElement ] );

##############################################################################
##
#F  LeftReduceUEALatticeElement( <novar>, <G>, <lms>, <p> )
##
##
DeclareGlobalFunction( "LeftReduceUEALatticeElement" );


##############################################################################
##
#F  ExtendRepresentation( <L>, <newelts>, <I>, <mats> )
##
DeclareGlobalFunction( "ExtendRepresentation" );


#############################################################################
##
#F  IsCochainsSpace( <V> )
##
##  ...
##
DeclareHandlingByNiceBasis( "IsCochainsSpace",
    "for free left modules of cochains" );


#############################################################################
##
#V  InfoSearchTable
##
##  is the info class for methods and functions applicable to search tables.
##  (see~"Info Functions").
##
DeclareInfoClass( "InfoSearchTable" );

#############################################################################
##
#C  IsSearchTable( <obj> )
##
##  A search table stores elements and provides methods for efficient
##  search of particular kinds of elements.
##
DeclareCategory( "IsSearchTable", IsObject );


#############################################################################
##
#O  Search( <T>, <key> )
##
##  is the operation for finding element labelled with <key> in table <T>.
##  The return value depends on the specific implementation of the search
##  table, but this will always return `fail' if an element in $T$ does not
##  satisfy the necessary criterion for <key>.
##
DeclareOperation( "Search", [ IsSearchTable, IsObject ] );

#############################################################################
##
#O  Insert( <T>, <key>, <data> )
##
##  is the operation for inserting data into the search table. 
##  The data <data> is stored in the table under the key <key>.
##  The operation returns `true' if the insertion occurs, and
##  `false' otherwise.
##
DeclareOperation( "Insert", [ IsSearchTable, IsObject, IsObject ] );


#############################################################################
##
#C  IsVectorSearchTable( <obj> )
##
##  is a search table encoding integer vectors representing a 
##  variable/exponent pair for monomials in a commutative polynomial ring
##  or in a semisimple Lie algebra given by a PBW basis.
##
DeclareCategory( "IsVectorSearchTable", IsSearchTable );


#############################################################################
##
#F VectorSearchTable( )
#F VectorSearchTable( <keys>, <data> )
##
## construct an empty search table or a search table containing <data> 
## keyed by <keys>. The list <keys> must contain integer lists which are
## interpreted as exponents for variables. 
##
## The lists <keys> and <data> must be the same length as well.
## 
DeclareGlobalFunction( "VectorSearchTable" );


#############################################################################
##
#E

