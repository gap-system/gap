#############################################################################
##
#W  algebra.gd                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares the operations for `FLMLOR's and algebras.
##
Revision.algebra_gd :=
    "@(#)$Id$";


#1 
##  An algebra is a vector space equipped with a bilinear map (multiplication).
##  This chapter describes the functions in {\GAP} that deal with 
##  general algebras and associative algebras. 
##
##  Algebras in {\GAP} are vector spaces in a natural way. So all the
##  functionality for vector spaces (see Chapter "ref:vector spaces") is also 
##  applicable to algebras.
##

#############################################################################
##
#V  InfoAlgebra
##
##  is the info class for the functions dealing with algebras
##  (see~"Info Functions").
##
DeclareInfoClass( "InfoAlgebra" );



#############################################################################
##
#C  IsFLMLOR( <obj> )
##
##  A FLMLOR (``free left module left operator ring'') in {\GAP} is a ring
##  that is also a free left module.
##
##  Note that this means that being a FLMLOR is not a property a
##  ring can get,
##  since a ring is usually not represented as an external left set.
##
##  Examples are magma rings (e.g. over the integers) or algebras.
##
DeclareSynonym( "IsFLMLOR", IsFreeLeftModule and IsLeftOperatorRing );


#############################################################################
##
#C  IsFLMLORWithOne( <obj> )
##
##  A FLMLOR-with-one in {\GAP} is a ring-with-one that is also a free left
##  module.
##
##  Note that this means that being a FLMLOR-with-one is not a property a
##  ring-with-one can get,
##  since a ring-with-one is usually not represented as an external left set.
##
##  Examples are magma rings-with-one or algebras-with-one (but also over the
##  integers).
##
DeclareSynonym( "IsFLMLORWithOne",
    IsFreeLeftModule and IsLeftOperatorRingWithOne );


#############################################################################
##
#C  IsAlgebra( <obj> )
##
##  An algebra in {\GAP} is a ring that is also a left vector space.
##  Note that this means that being an algebra is not a property a ring can
##  get, since a ring is usually not represented as an external left set.
##
DeclareSynonym( "IsAlgebra", IsLeftVectorSpace and IsLeftOperatorRing );


#############################################################################
##
#C  IsAlgebraWithOne( <obj> )
##
##  An algebra-with-one in {\GAP} is a ring-with-one that is also
##  a left vector space.
##  Note that this means that being an algebra-with-one is not a property a
##  ring-with-one can get,
##  since a ring-with-one is usually not represented as an external left set.
##
DeclareSynonym( "IsAlgebraWithOne",
    IsLeftVectorSpace and IsLeftOperatorRingWithOne );


#############################################################################
##
#P  IsLieAlgebra( <A> )
##
##  An algebra <A> is called Lie algebra if $a * a = 0$ for all $a$ in <A>
##  and $( a * ( b * c ) ) + ( b * ( c * a ) ) + ( c * ( a * b ) ) = 0$
##  for all $a, b, c$ in <A> (Jacobi identity).
##
DeclareSynonymAttr( "IsLieAlgebra",
    IsAlgebra and IsZeroSquaredRing and IsJacobianRing );


#############################################################################
##
#P  IsSimpleAlgebra( <A> )
##
##  is `true' if the algebra <A> is simple, and `false' otherwise. This 
##  function is only implemented for the cases where <A> is an associative or
##  a Lie algebra.
##
DeclareProperty( "IsSimpleAlgebra", IsAlgebra );


#############################################################################
##
#A  GeneratorsOfLeftOperatorRing
##
DeclareAttribute( "GeneratorsOfLeftOperatorRing", IsLeftOperatorRing );


#############################################################################
##
#A  GeneratorsOfLeftOperatorRingWithOne
##
DeclareAttribute( "GeneratorsOfLeftOperatorRingWithOne",
    IsLeftOperatorRingWithOne );


#############################################################################
##
#A  GeneratorsOfAlgebra( <A> )
##
##  returns a list of elements that generate <A> as an algebra.
##
DeclareSynonymAttr( "GeneratorsOfAlgebra", GeneratorsOfLeftOperatorRing );
DeclareSynonymAttr( "GeneratorsOfFLMLOR", GeneratorsOfLeftOperatorRing );


#############################################################################
##
#A  GeneratorsOfAlgebraWithOne( <A> )
##
##  returns a list of elements of <A> that generate <A> as an algebra with
##  one. 
##
DeclareSynonymAttr( "GeneratorsOfAlgebraWithOne",
    GeneratorsOfLeftOperatorRingWithOne );
DeclareSynonymAttr( "GeneratorsOfFLMLORWithOne",
    GeneratorsOfLeftOperatorRingWithOne );


#############################################################################
##
#A  PowerSubalgebraSeries( <A> )
##
##  returns a list of subalgebras of <A>, the first term of which is <A>;
##  and every next term is the product space of the previous term with itself.
##
DeclareAttribute( "PowerSubalgebraSeries", IsAlgebra );


#############################################################################
##
#A  AdjointBasis( <B> )
##
##  Let $x$ be an element of an algebra $A$. Then the adjoint map
##  of $x$ is the left multiplication by $x$. It is a linear map of $A$.
##  For the basis <B> of an algebra $A$, this function returns a
##  particular basis $C$ of the matrix space generated by $ad A$,
##  (the matrix spaces spanned by the matrices of the left multiplication);
##  namely a basis consisting of elements of the form $ad x_i$,
##  where $x_i$ is a basis element of <B>.
##
DeclareAttribute( "AdjointBasis", IsBasis );


#############################################################################
##
#A  IndicesOfAdjointBasis( <B> )
##
##   Let <A> be an algebra and let <B>
##   be the basis that is output by `AdjointBasis( Basis( <A> ) )'. 
##   This function 
##   returns a list of indices. If $i$ is an index belonging to this
##   list, then $ad x_{i}$ is a basis vector of the matrix space spanned
##   by $ad A$, where $x_{i}$ is the $i$-th basis vector of the basis <B>.
##
DeclareAttribute( "IndicesOfAdjointBasis", IsBasis );


#############################################################################
##
#A  RadicalOfAlgebra( <A> )
##
##  is the maximal nilpotent ideal of <A>, where <A> is an associative 
##  algebra.
##
DeclareAttribute( "RadicalOfAlgebra", IsAlgebra );

#############################################################################
##
#A  DirectSumDecomposition( <L> )
##
##  This function calculates a list of ideals of the algebra <L> such
##  that <L> is equal to their direct sum. Currently this is only implemented
##  for semisimple associative algebras, and Lie algebras (semisimple or not).
##
DeclareAttribute( "DirectSumDecomposition", IsAlgebra );


#############################################################################
##
#A  TrivialSubalgebra( <A> )
##
##  The zero dimensional subalgebra of the algebra <A>.
##
DeclareSynonymAttr( "TrivialSubFLMLOR", TrivialSubadditiveMagmaWithZero );
DeclareSynonymAttr( "TrivialSubalgebra", TrivialSubFLMLOR );


#############################################################################
##
#A  NullAlgebra( <R> )  . . . . . . . . . . zero dimensional algebra over <R>
##
##  The zero-dimensional algebra over <R>.
#T or store this in the family ?
##
DeclareAttribute( "NullAlgebra", IsRing );


#############################################################################
##
#O  ProductSpace( <U>, <V> )
##
##  is the vector space $\langle u * v ; u \in U, v \in V \rangle$,
##  where $U$ and $V$ are subspaces of the same algebra.
##
##  If $<U> = <V>$ is known to be an algebra then the product space is also
##  an algebra, moreover it is an ideal in <U>.
##  If <U> and <V> are known to be ideals in an algebra $A$
##  then the product space is known to be an algebra and an ideal in $A$.
##
DeclareOperation( "ProductSpace", [ IsFreeLeftModule, IsFreeLeftModule ] );


#############################################################################
##
#O  DirectSumOfAlgebras( <A1>, <A2> )
#O  DirectSumOfAlgebras( <list> )
##
##  is the direct sum of the two algebras <A1> and <A2> respectively of the 
##  algebras in the list <list>.
##
##  If all involved algebras are associative algebras then the result is also
##  known to be associative.
##  If all involved algebras are Lie algebras then the result is also known
##  to be a Lie algebra.
##
##  All involved algebras must have the same left acting domain.
##
##  The default case is that the result is a structure constants algebra.
##  If all involved algebras are matrix algebras, and either both are Lie
##  algebras or both are associative then the result is again a
##  matrix algebra of the appropriate type.
##
DeclareOperation( "DirectSumOfAlgebras", [ IsDenseList ] );


#############################################################################
##
#F  FullMatrixAlgebraCentralizer( <F>, <lst> )
##
##  Compute the centralizer of the list of matrices in the list <lst> in the 
##  full matrix algebra over the ring <F>. 
##
DeclareGlobalFunction( "FullMatrixAlgebraCentralizer" );


#############################################################################
##
#O  AsAlgebra( <F>, <A> ) . . . . . . . . . . .  view <A> as algebra over <F>
##
##  Returns the algebra over <F> generated by <A>.
##
DeclareOperation( "AsFLMLOR", [ IsRing, IsCollection ] );

DeclareSynonym( "AsAlgebra", AsFLMLOR );


#############################################################################
##
#O  AsAlgebraWithOne( <F>, <A> )  . . . view <A> as algebra-with-one over <F>
##
##  If the algebra <A> has an identity, then it can be viewed as an
##  algebra with one over <F>. This function returns this algebra with one.
##
DeclareOperation( "AsFLMLORWithOne", [ IsRing, IsCollection ] );

DeclareSynonym( "AsAlgebraWithOne", AsFLMLORWithOne );


#############################################################################
##
#O  AsSubalgebra( <A>, <B> )  . . . . . . . . . view <B> as subalgebra of <A>
##
##  If all elements of the algebra <B> happen to be contained in the
##  algebra <A>, then <B> can be viewed as a subalgebra of <A>. This 
##  function returns this subalgebra.
##
DeclareOperation( "AsSubFLMLOR", [ IsFLMLOR, IsFLMLOR ] );

DeclareSynonym( "AsSubalgebra", AsSubFLMLOR );


#############################################################################
##
#O  AsSubalgebraWithOne( <A>, <B> ) . . view <B> as subalgebra-wth-one of <A>
##
##  If <B> is an algebra with one, all elements of which happen to be
##  contained in the algebra with one <A>, then <B> can be viewed as a
##  subalgebra with one of <A>. This function returns this subalgebra
##  with one.
##
DeclareOperation( "AsSubFLMLORWithOne", [ IsFLMLOR, IsFLMLOR ] );

DeclareSynonym( "AsSubalgebraWithOne", AsSubFLMLORWithOne );

#2 
## For an introduction into structure constants and how they are handled
## by {\GAP}, we refer to Section "tut:Algebras" of the user's tutorial.

#############################################################################
##
#F  EmptySCTable( <dim>, <zero> )
#F  EmptySCTable( <dim>, <zero>, \"symmetric\" )
#F  EmptySCTable( <dim>, <zero>, \"antisymmetric\" )
##
##  `EmptySCTable' returns a structure constants table for an algebra of
##  dimension <dim>, describing trivial multiplication.
##  <zero> must be the zero of the coefficients domain.
##  If the multiplication is known to be (anti)commutative then
##  this can be indicated by the optional third argument.
##
##  For filling up the structure constants table, see "SetEntrySCTable".
##
DeclareGlobalFunction( "EmptySCTable" );


#############################################################################
##
#F  SetEntrySCTable( <T>, <i>, <j>, <list> )
##
##  sets the entry of the structure constants table <T> that describes the
##  product of the <i>-th basis element with the <j>-th basis element to the
##  value given by the list <list>.
##
##  If <T> is known to be antisymmetric or symmetric then also the value
##  `<T>[<j>][<i>]' is set.
##
##  <list> must be of the form
##  $[ c_{ij}^{k_1}, k_1, c_{ij}^{k_2}, k_2, ... ]$.
##
##  The entries at the odd positions of <list> must be compatible with the
##  zero element stored in <T>.
##  For convenience, these entries may also be rational numbers that are
##  automatically replaced by the corresponding elements in the appropriate
##  prime field in finite characteristic if necessary.
##
DeclareGlobalFunction( "SetEntrySCTable" );


#############################################################################
##
#F  ReducedSCTable( <T>, <one> )
##
##  returns an immutable structure constants table obtained by reducing the
##  (rational) coefficients of the structure constants table <T> by
##  multiplication with <one>.
##
DeclareGlobalFunction( "ReducedSCTable" );


#############################################################################
##
#F  GapInputSCTable( <T>, <varname> )
##
##  is a string that describes the structure constants table <T> in terms of
##  `EmptySCTable' and `SetEntrySCTable'.
##  The assignments are made to the variable <varname>.
##
DeclareGlobalFunction( "GapInputSCTable" );


#############################################################################
##
#F  IdentityFromSCTable( <T> )
##
##  Let <T> be a structure constants table of an algebra $A$ of dimension $n$.
##  `IdentityFromSCTable( <T> )' is either `fail' or the vector of length
##  $n$ that contains the coefficients of the multipicative identity of $A$
##  with respect to the basis that belongs to <T>.
##
DeclareGlobalFunction( "IdentityFromSCTable" );


#############################################################################
##
#F  QuotientFromSCTable( <T>, <num>, <den> )
##
##  Let <T> be a structure constants table of an algebra $A$ of dimension $n$.
##  `QuotientFromSCTable( <T> )' is either `fail' or the vector of length
##  $n$ that contains the coefficients of the quotient of <num> and <den>
##  with respect to the basis that belongs to <T>.
##
##  We solve the equation system $<num> = x <den>$.
##  If no solution exists, `fail' is returned.
##
##  In terms of the basis $B$ with vectors $b_1, \ldots, b_n$ this means
##  for $<num> = \sum_{i=1}^n a_i b_i$,
##      $<den> = \sum_{i=1}^n c_i b_i$,
##      $x     = \sum_{i=1}^n x_i b_i$ that
##  $a_k = \sum_{i,j} c_i x_j c_{ijk}$ for all $k$.
##  Here $c_{ijk}$ denotes the structure constants with respect to $B$.
##  This means that (as a vector) $a=xM$ with
##  $M_{jk} = \sum_{i=1}^n c_{ijk} c_i$.
##
DeclareGlobalFunction( "QuotientFromSCTable" );


#############################################################################
##
#F  TestJacobi( <T> )
##
##  tests whether the structure constants table <T> satisfies the Jacobi
##  identity
##  $v_i*(v_j*v_k)+v_j*(v_k*v_i)+v_k*(v_i*v_j)=0$
##  for all basis vectors $v_i$ of the underlying algebra,
##  where $i \leq j \leq k$.
##  (Thus antisymmetry is assumed.)
##
##  The function returns `true' if the Jacobi identity is satisfied,
##  and a failing triple `[ i, j, k ]' otherwise.
##
DeclareGlobalFunction( "TestJacobi" );


#############################################################################
##
#O  ClosureLeftOperatorRing( <A>, <a> )
#O  ClosureLeftOperatorRing( <A>, <S> )
##
##  For a left operator ring <A> and either an element <a> of its elements
##  family or a left operator ring <S> (over the same left acting domain),
##  `ClosureLeftOperatorRing' returns the left operator ring generated by
##  both arguments.
##
DeclareOperation( "ClosureLeftOperatorRing",
    [ IsLeftOperatorRing, IsObject ] );

DeclareSynonym( "ClosureAlgebra", ClosureLeftOperatorRing );


#############################################################################
##
#F  MutableBasisOfClosureUnderAction( <F>, <Agens>, <from>, <init>, <opr>,
#F                                    <zero>, <maxdim> )
##
##  Let <F> be a ring, <Agens> a list of generators for an <F>-algebra $A$,
##  and <from> one of `"left"', `"right"', `"both"'; (this means that elements
##  of $A$ act via multiplication from the respective side(s).)
##  <init> must be a list of initial generating vectors,
##  and <opr> the operation (a function of two arguments).
##
##  `MutableBasisOfClosureUnderAction' returns a mutable basis of the
##  <F>-free left module generated by the vectors in <init>
##  and their images under the action of <Agens> from the respective side(s).
##
##  <zero> is the zero element of the desired module.
##  <maxdim> is an upper bound for the dimension of the closure; if no such
##  upper bound is known then the value of <maxdim> must be `infinity'.
##
##  `MutableBasisOfClosureUnderAction' can be used to compute a basis of an
##  *associative* algebra generated by the elements in <Agens>. In this 
##  case <from> may be `"left"' or `"right"', <opr> is the multiplication `\*',
##  and <init> is a list containing either the identity of the algebra or a
##  list of algebra generators.
##  (Note that if the algebra has an identity then it is in general not
##  sufficient to take algebra-with-one generators as <init>,
##  whereas of course <Agens> need not contain the identity.)
## 
##  (Note that bases of *not* necessarily associative algebras can be
##  computed using `MutableBasisOfNonassociativeAlgebra'.)
##
##  Other applications of `MutableBasisOfClosureUnderAction' are the
##  computations of bases for (left/ right/ two-sided) ideals $I$ in an
##  *associative* algebra $A$ from ideal generators of $I$;
##  in these cases <Agens> is a list of algebra generators of $A$,
##  <from> denotes the appropriate side(s),
##  <init> is a list of ideal generators of $I$, and <opr> is again `\*'.
##
##  (Note that bases of ideals in *not* necessarily associative algebras can
##  be computed using `MutableBasisOfIdealInNonassociativeAlgebra'.)
##
##  Finally, bases of right $A$-modules also can be computed using
##  `MutableBasisOfClosureUnderAction'.
##  The only difference to the ideal case is that <init> is now a list of
##  right module generators, and <opr> is the operation of the module.
##
#T  (Remark:
#T  It would be possible to use vector space generators of the algebra $A$
#T  if they are known; but in the associative case, it is cheaper to multiply
#T  only with generators until the vector space  becomes stable.)
##
DeclareGlobalFunction( "MutableBasisOfClosureUnderAction" );


#############################################################################
##
#F  MutableBasisOfNonassociativeAlgebra( <F>, <Agens>, <zero>, <maxdim> )
##
##  is a mutable basis of the (not necessarily associative) <F>-algebra that
##  is generated by <Agens>, has zero element <zero>, and has dimension at
##  most <maxdim>.
##  If no finite bound for the dimension is known then `infinity' must be
##  the value of <maxdim>.
##
##  The difference to `MutableBasisOfClosureUnderAction' is that in general
##  it is not sufficient to multiply just with algebra generators.
##  (For special cases of nonassociative algebras, especially for Lie
##  algebras, multiplying with algebra generators suffices.)
##
DeclareGlobalFunction( "MutableBasisOfNonassociativeAlgebra" );


#############################################################################
##
#F  MutableBasisOfIdealInNonassociativeAlgebra( <F>, <Vgens>, <Igens>,
#F                                              <zero>, <from>, <maxdim> )
##
##  is a mutable basis of the ideal generated by <Igens> under the action of
##  the (not necessarily associative) <F>-algebra with vector space
##  generators <Vgens>.
##  The zero element of the ideal is <zero>,
##  <from> is one of `"left"', `"right"', `"both"' (with the same meaning as
##  in `MutableBasisOfClosureUnderAction'),
##  and <maxdim> is a known upper bound on the dimension of the ideal;
##  if no finite bound for the dimension is known then `infinity' must be
##  the value of <maxdim>.
##
##  The difference to `MutableBasisOfClosureUnderAction' is that in general
##  it is not sufficient to multiply just with algebra generators.
##  (For special cases of nonassociative algebras, especially for Lie
##  algebras, multiplying with algebra generators suffices.)
##
DeclareGlobalFunction( "MutableBasisOfIdealInNonassociativeAlgebra" );


#############################################################################
##
##  Domain constructors
##

#############################################################################
##
#O  AlgebraByGenerators(<F>,<gens>) . . . . . . . . <F>-algebra by generators
#O  AlgebraByGenerators( <F>, <gens>, <zero> )
##
DeclareOperation( "FLMLORByGenerators",
    [ IsRing, IsCollection ] );

DeclareSynonym( "AlgebraByGenerators", FLMLORByGenerators );


#############################################################################
##
#F  Algebra( <F>, <gens> )
#F  Algebra( <F>, <gens>, <zero> )
#F  Algebra( <F>, <gens>, "basis" )
#F  Algebra( <F>, <gens>, <zero>, "basis" )
##
##  `Algebra( <F>, <gens> )' is the algebra over the division ring
##  <F>, generated by the vectors in the list <gens>.
##
##  If there are three arguments, a division ring <F> and a list <gens>
##  and an element <zero>,
##  then `Algebra( <F>, <gens>, <zero> )' is the <F>-algebra
##  generated by <gens>, with zero element <zero>.
##
##  If the last argument is the string `\"basis\"' then the vectors in
##  <gens> are known to form a basis of the algebra (as an <F>-vector space).
##
DeclareGlobalFunction( "FLMLOR" );

DeclareSynonym( "Algebra", FLMLOR );


#############################################################################
##
#F  Subalgebra( <A>, <gens> ) . . . . . subalgebra of <A> generated by <gens>
#F  Subalgebra( <A>, <gens>, "basis" )
##
##  is the $F$-algebra generated by <gens>, with parent algebra <A>, where
##  $F$ is the left acting domain of <A>.
##
##  *Note* that being a subalgebra of <A> means to be an algebra, to be
##  contained in <A>, *and* to have the same left acting domain as <A>.
##
##  An optional argument `\"basis\"' may be added if it is known that
##  the generators already form a basis of the algebra.
##  Then it is *not* checked whether <gens> really are linearly independent
##  and whether all elements in <gens> lie in <A>.
##
DeclareGlobalFunction( "SubFLMLOR" );

DeclareSynonym( "Subalgebra", SubFLMLOR );


#############################################################################
##
#F  SubalgebraNC( <A>, <gens> )
#F  SubalgebraNC( <A>, <gens>, "basis" )
##
##  `SubalgebraNC' constructs the subalgebra generated by <gens>, only it 
##  does not check whether all elements in <gens> lie in <A>.
##
DeclareGlobalFunction( "SubFLMLORNC" );

DeclareSynonym( "SubalgebraNC", SubFLMLORNC );


#############################################################################
##
#O  AlgebraWithOneByGenerators(<F>,<gens>)  . <F>-alg.-with-one by generators
#O  AlgebraWithOneByGenerators( <F>, <gens>, <zero> )
##
DeclareOperation( "FLMLORWithOneByGenerators",
    [ IsRing, IsCollection ] );

DeclareSynonym( "AlgebraWithOneByGenerators", FLMLORWithOneByGenerators );


#############################################################################
##
#F  AlgebraWithOne( <F>, <gens> )
#F  AlgebraWithOne( <F>, <gens>, <zero> )
#F  AlgebraWithOne( <F>, <gens>, "basis" )
#F  AlgebraWithOne( <F>, <gens>, <zero>, "basis" )
##
##  `AlgebraWithOne( <F>, <gens> )' is the algebra-with-one over the division
##  ring <F>, generated by the vectors in the list <gens>.
##
##  If there are three arguments, a division ring <F> and a list <gens>
##  and an element <zero>,
##  then `AlgebraWithOne( <F>, <gens>, <zero> )' is the <F>-algebra-with-one
##  generated by <gens>, with zero element <zero>.
##
##  If the last argument is the string `\"basis\"' then the vectors in
##  <gens> are known to form a basis of the algebra (as an <F>-vector space).
##
DeclareGlobalFunction( "FLMLORWithOne" );

DeclareSynonym( "AlgebraWithOne", FLMLORWithOne );


#############################################################################
##
#F  SubalgebraWithOne( <A>, <gens> )   subalg.-with-one of <A> gen. by <gens>
#F  SubalgebraWithOne( <A>, <gens>, "basis" )
##
##  is the algebra-with-one generated by <gens>, with parent algebra <A>.
##
##  The optional third argument `\"basis\"' may be added if it is
##  known that the elements from <gens> are linearly independent.
##  Then it is *not* checked whether <gens> really are linearly independent
##  and whether all elements in <gens> lie in <A>.
##
DeclareGlobalFunction( "SubFLMLORWithOne" );

DeclareSynonym( "SubalgebraWithOne", SubFLMLORWithOne );


#############################################################################
##
#F  SubalgebraWithOneNC( <A>, <gens>  )
#F  SubalgebraWithOneNC( <A>, <gens>, "basis" )
##
##  `SubalgebraWithOneNC' does not check whether all elements in <gens> lie
##  in <A>.
##
DeclareGlobalFunction( "SubFLMLORWithOneNC" );

DeclareSynonym( "SubalgebraWithOneNC", SubFLMLORWithOneNC );


#############################################################################
##
#F  LieAlgebra( <L> )
#F  LieAlgebra( <F>, <gens> )
#F  LieAlgebra( <F>, <gens>, <zero> )
#F  LieAlgebra( <F>, <gens>, "basis" )
#F  LieAlgebra( <F>, <gens>, <zero>, "basis" )
##
##  For an associative algebra <L>, `LieAlgebra( <L> )' is the Lie algebra
##  isomorphic to <L> as a vector space but with the Lie bracket as product.
##
##  `LieAlgebra( <F>, <gens> )' is the Lie algebra over the division ring
##  <F>, generated *as Lie algebra* by the Lie objects corresponding to the
##  vectors in the list <gens>.
##
##  *Note* that the algebra returned by `LieAlgebra' does not contain the
##  vectors in <gens>. The elements in <gens> are wrapped up as Lie objects
##  (see "ref:lie objects").
##  This allows one to create Lie algebras from ring elements with respect to
##  the Lie bracket as product.  But of course the product in the Lie
##  algebra is the usual `\*'.
##
##  If there are three arguments, a division ring <F> and a list <gens>
##  and an element <zero>,
##  then `LieAlgebra( <F>, <gens>, <zero> )' is the corresponding <F>-Lie
##  algebra with zero element the Lie object corresponding to <zero>.
##
##  If the last argument is the string `\"basis\"' then the vectors in
##  <gens> are known to form a basis of the algebra (as an <F>-vector space).
##
##  *Note* that even if each element in <gens> is already a Lie element,
##  i.e., is of the form `LieElement( <elm> )' for an object <elm>,
##  the elements of the result lie in the Lie family of the family that
##  contains <gens> as a subset.
##
DeclareGlobalFunction( "LieAlgebra" );


#############################################################################
##
#A  LieAlgebraByDomain( <A> )
##
##  is a Lie algebra isomorphic to the algebra <A> as a vector space,
##  but with the Lie bracket as product.
##
DeclareAttribute( "LieAlgebraByDomain", IsAlgebra );


#############################################################################
##
#O  AsLieAlgebra( <F>, <A> ) . . . . . . . . view <A> as Lie algebra over <F>
##
##  Note that the multiplication in <A> is the same as in the result.
##
DeclareOperation( "AsLieAlgebra", [ IsDivisionRing, IsCollection ] );


#############################################################################
##
#F  FreeAlgebra( <R>, <rank> )
#F  FreeAlgebra( <R>, <rank>, <name> )
#F  FreeAlgebra( <R>, <name1>, <name2>, ... )
##
##  is a free (nonassociative) algebra of rank <rank> over the ring <R>.
##  Here <name>, and <name1>, <name2>,... are optional strings that can be used
##  to provide names for the generators.
##
DeclareGlobalFunction( "FreeAlgebra" );


#############################################################################
##
#F  FreeAlgebraWithOne( <R>, <rank> )
#F  FreeAlgebraWithOne( <R>, <rank>, <name> )
#F  FreeAlgebraWithOne( <R>, <name1>, <name2>, ... )
##
##  is a free (nonassociative) algebra-with-one of rank <rank> over the ring
##  <R>.
##  Here <name>, and <name1>, <name2>,... are optional strings that can be used
##  to provide names for the generators.
##
DeclareGlobalFunction( "FreeAlgebraWithOne" );


#############################################################################
##
#F  FreeAssociativeAlgebra( <R>, <rank> )
#F  FreeAssociativeAlgebra( <R>, <rank>, <name> )
#F  FreeAssociativeAlgebra( <R>, <name1>, <name2>, ... )
##
##  is a free associative algebra of rank <rank> over the ring <R>.
##  Here <name>, and <name1>, <name2>,... are optional strings that can be used
##  to provide names for the generators.
##
DeclareGlobalFunction( "FreeAssociativeAlgebra" );


#############################################################################
##
#F  FreeAssociativeAlgebraWithOne( <R>, <rank> )
#F  FreeAssociativeAlgebraWithOne( <R>, <rank>, <name> )
#F  FreeAssociativeAlgebraWithOne( <R>, <name1>, <name2>, ... )
##
##  is a free associative algebra-with-one of rank <rank> over the ring <R>.
##  Here <name>, and <name1>, <name2>,... are optional strings that can be used
##  to provide names for the generators.
##
DeclareGlobalFunction( "FreeAssociativeAlgebraWithOne" );


#############################################################################
##
#F  AlgebraByStructureConstants( <R>, <sctable> )
#F  AlgebraByStructureConstants( <R>, <sctable>, <name> )
#F  AlgebraByStructureConstants( <R>, <sctable>, <names> )
#F  AlgebraByStructureConstants( <R>, <sctable>, <name1>, <name2>, ... )
##
##  returns a free left module $A$ over the ring <R>,
##  with multiplication defined by the structure constants table <sctable>.
##  Here <name> and <name1>, <name2>, `...' are optional strings
##  that can be used to provide names for the elements of the canonical basis
##  of $A$.
##  <names> is a list of strings that can be entered instead of the specific
##  names <name1>, <name2>, `...'.
##  The vectors of the canonical basis of $A$ correspond to the vectors of
##  the basis given by <sctable>.
##
#%  The algebra generators of $A$ are linearly independent
#%  abstract vector space generators
#%  $x_1, x_2, \ldots, x_n$ which are multiplied according to the formula
#%  $ x_i x_j = \sum_{k=1}^n c_{ijk} x_k$
#%  where `$c_{ijk}$ = <sctable>[i][j][1][i_k]'
#%  and `<sctable>[i][j][2][i_k] = k'.
##
##  It is *not* checked whether the coefficients in <sctable> are really
##  elements in <R>.
##
DeclareGlobalFunction( "AlgebraByStructureConstants" );


#############################################################################
##
#F  LieAlgebraByStructureConstants( <R>, <sctable> )
#F  LieAlgebraByStructureConstants( <R>, <sctable>, <name> )
#F  LieAlgebraByStructureConstants( <R>, <sctable>, <name1>, <name2>, ... )
##
##  `LieAlgebraByStructureConstants' does the same as
##  `AlgebraByStructureConstants', except that the result is assumed to be
##  a Lie algebra. Note that the function does not check whether
##  <sctable> satisfies the Jacobi identity. (So if one creates a Lie
##  algebra this way with a table that does not satisfy the Jacobi identity,
##  errors may occur later on.)
##
DeclareGlobalFunction( "LieAlgebraByStructureConstants" );


#############################################################################
##
#C  IsQuaternion( <obj> )
#C  IsQuaternionCollection(<obj>)
#C  IsQuaternionCollColl(<obj>)
##
##  `IsQuaternion' is the category of elements in an algebra constructed by 
##  `QuaternionAlgebra'. A collection of quaternions lies in the category
##  `IsQuaternionCollection'. Finally, a collection of quaternion collections
##  (e.g., a matrix) lies in the category `IsQuaternionCollColl'.
##
DeclareCategory( "IsQuaternion", IsScalar and IsAssociative );
DeclareCategoryCollections( "IsQuaternion" );
DeclareCategoryCollections( "IsQuaternionCollection" );


#############################################################################
##
#F  QuaternionAlgebra( <F> )
#F  QuaternionAlgebra( <F>, <a>, <b> )
##
##  is a quaternion algebra over the field <F> with parameters <a> and <b> in
##  <F>, i.e., a four-dimensional associative <F>-algebra with basis
##  $(e,i,j,k)$ and multiplication defined by
##  $e e = e$, $e i = i e = i$, $e j = j e = j$, $e k = k e = k$,
##  $i i = <a> e$, $i j = - j i = k$, $i k = - k i = <a> j$,
##  $j j = <b> e$, $j k = - k j = <b> i$,
##  $k k = - <a> <b> e$.
##  The default values for <a> and <b> are $-1$ in <F>.
##
##  The embedding of the field `GaussianRationals' into a quaternion algebra
##  $A$ over `Rationals' is not uniquely determined.
##  One can specify one as a vector space homomorphism that maps `1' to the
##  first algebra generator of $A$, and `E(4)' to one of the others.
##
DeclareGlobalFunction( "QuaternionAlgebra" );


#############################################################################
##
#F  ComplexificationQuat( <vector> )
#F  ComplexificationQuat( <matrix> )
##
##  Let $A = e F \oplus i F \oplus j F \oplus k F$ be a quaternion algebra
##  over the field $F$ of cyclotomics, with basis $(e,i,j,k)$.
##
##  If $v = v_1 + v_2 j$ is a row vector over $A$ with $v_1 = e w_1 + i w_2$
##  and $v_2 = e w_3 + i w_4$ then `ComplexificationQuat( $v$ )' is the
##  concatenation of $w_1 + `E(4)' w_2$ and $w_3 + `E(4)' w_4$.
##
##  If $M = M_1 + M_2 j$ is a matrix over $A$ with $M_1 = e N_1 + i N_2$
##  and $M_2 = e N_3 + i N_4$ then `ComplexificationQuat( <M> )' is the
##  block matrix $A$ over $e F \oplus i F$ such that $A(1,1)=N_1 + `E(4)' N_2$,
##  $A(2,2)=N_1 - `E(4)' N_2$, $A(1,2)=N_3 + `E(4)' N_4$ and $A(2,1)=
##   - N_3 + `E(4)' N_4$.
#%  \[ \left( \begin{array}{rr}
#%                  N_1 + `E(4)' N_2 & N_3 + `E(4)' N_4           \\
#%                - N_3 + `E(4)' N_4 & N_1 - `E(4)' N_2
#%            \end{array} \right) \]
##
##  Then `ComplexificationQuat(<v>)*ComplexificationQuat(<M>)=
##        ComplexificationQuat(<v>*<M>)', since
##  $$ v M = v_1 M_1 + v_2 j M_1 + v_1 M_2 j + v_2 j M_2 j
##         =   ( v_1 M_1 - v_2 \overline{M_2} )
##           + ( v_1 M_2 + v_2 \overline{M_1} ) j . $$
##             
DeclareGlobalFunction( "ComplexificationQuat" );


#############################################################################
##
#F  OctaveAlgebra( <F> )
##
##  The algebra of octonions over <F>.
##
DeclareGlobalFunction( "OctaveAlgebra" );


#############################################################################
##
##  FullMatrixFLMLOR( <R>, <n> )
#F  FullMatrixAlgebra( <R>, <n> )
#F  MatrixAlgebra( <R>, <n> )
#F  MatAlgebra( <R>, <n> )
##
##  is the full matrix algebra $<R>^{<n>\times <n>}$, for a ring <R> and a 
##  nonnegative integer <n>.
##
DeclareGlobalFunction( "FullMatrixFLMLOR" );

DeclareSynonym( "FullMatrixAlgebra", FullMatrixFLMLOR );
DeclareSynonym( "MatrixAlgebra", FullMatrixFLMLOR );
DeclareSynonym( "MatAlgebra", FullMatrixFLMLOR );


#############################################################################
##
#F  FullMatrixLieAlgebra( <R>, <n> )
#F  MatrixLieAlgebra( <R>, <n> )
#F  MatLieAlgebra( <R>, <n> )
##
##  is the full matrix Lie algebra $<R>^{<n>\times <n>}$, for a ring <R> and a 
##  nonnegative integer <n>.
##

DeclareGlobalFunction( "FullMatrixLieFLMLOR" );

DeclareSynonym( "FullMatrixLieAlgebra", FullMatrixLieFLMLOR );
DeclareSynonym( "MatrixLieAlgebra", FullMatrixLieFLMLOR );
DeclareSynonym( "MatLieAlgebra", FullMatrixLieFLMLOR );



#############################################################################
##
#C  IsMatrixFLMLOR( <obj> ) . . . . . .  test if an object is a matrix FLMLOR
##
DeclareSynonym( "IsMatrixFLMLOR", IsFLMLOR and IsRingElementCollCollColl );


#############################################################################
##
#M  IsFiniteDimensional( <A> )  . . . . matrix FLMLORs are finite dimensional
##
InstallTrueMethod( IsFiniteDimensional, IsMatrixFLMLOR );


#############################################################################
##
#A  CentralIdempotentsOfAlgebra( <A> )
##
##  For an associative algebra <A>, this function returns
##  a list of central primitive idempotents such that their sum is
##  the identity element of <A>. Therefore <A> is required to have an
##  identity.
##
##  (This is a synonym of `CentralIdempotentsOfSemiring'.)
#T add crossref. as soon as this is available
##
DeclareSynonym( "CentralIdempotentsOfAlgebra",
    CentralIdempotentsOfSemiring );


#############################################################################
##
#A  LeviMalcevDecomposition( <L> )
##
##  A Levi-Malcev subalgebra of the algebra <L> is a semisimple subalgebra
##  complementary to the radical of <L>. This function returns
##  a list with two components. The first component is a Levi-Malcev 
##  subalgebra, the second the radical. This function is implemented for 
##  associative and Lie algebras. 
##
DeclareAttribute( "LeviMalcevDecomposition", IsAlgebra );


#############################################################################
##
#F  CentralizerInFiniteDimensionalAlgebra( <A>, <S>, <issubset> )
##
##  is the centralizer of the list <S> in the algebra <A>, that is, the set
##  $\{ a \in A; a s = s a \forall s \in S \}$.
##
##  <issubset> must be either `true' or `false', where the former means that
##  <S> is known to be contained in <A>.
##  If <S> is not known to be contained in <A> then the centralizer of <S> in
##  the closure of <A> and <S> is computed, the result is the intersection of
##  this with <A>.
##
DeclareGlobalFunction( "CentralizerInFiniteDimensionalAlgebra" );


#############################################################################
##
#O  IsNilpotentElement( <L>, <x> )
##
##  <x> is nilpotent in <L> if its adjoint matrix is a nilpotent matrix.
##
##
DeclareOperation( "IsNilpotentElement",
    [ IsAlgebra, IsRingElement ] );
DeclareSynonym( "IsLieNilpotentElement", IsNilpotentElement);

#############################################################################
##
#A  Grading( <A> )
##
##  Let $G$ be an Abelian group and $A$ an algebra. Then $A$ is said to 
##  be graded over $G$ if for every $g\in G$ there is a subspace $A_g$
##  of $A$ such that $A_g\cdot A_h\subset A_{g+h}$ for $g,h\in G$. 
##  In \GAP~ a Grading of an algebra is a record containg a the following
##  components: 
##  \beginlist
##  \item{-} `source'
##    the Abelian group over which the algebra is graded.
##  \item{-} `hom_components'
##    a function assigning to each element from the
##    source a subspace of the algebra.
##  \item{-} `min_degree' 
##    in the case where the algebra is graded over the integers
##    this is the minimum number for which `hom_components' returns a nonzero
##    subspace.
##  \item{-} `max_degree'
##    is analogous to `min_degree'.
##  \endlist
##  We note that there are no methods to compute a grading of an 
##  arbitrary algebra; however some algebras get a natural grading when
##  they are constructed (see "ref:jenningsliealgebra", 
##  "ref:nilpotentquotientoffpliealgebra").
##
DeclareAttribute( "Grading", IsAlgebra );


#############################################################################
##
#E  algebra.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

