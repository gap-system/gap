#############################################################################
##
#W  basis.gd                    GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares the operations for bases of free left modules.
#1
##  A *basis* of a free left $F$-module $V$ of dimension $n$, say,
##  is an ordered list of vectors $B = [ v_1, v_2, \ldots, v_n ]$ in $V$
##  such that $V$ is generated as a left module over $F$ by these vectors.
##  In {\GAP} bases behave like lists, i.e., their elements can be accessed
##  via [ ], and they have a length:
##  \beginexample
##  gap> V:= Rationals^3;
##  ( Rationals^3 )
##  gap> B:= Basis( V );
##  CanonicalBasis( ( Rationals^3 ) )
##  gap> B[1];
##  [ 1, 0, 0 ]
##  gap> Length( B );
##  3
##  \endexample
##
##  Besides the basic operations for lists
##  (see~"Basic Operations for Lists"),
##  the basic operations for bases are `BasisVectors', `Coefficients',
##  `LinearCombination', and `UnderlyingLeftModule'.
##
##  {\GAP} supports three kinds of bases, namely
##  \beginlist
##  \item{1.}
##    *relative bases* that delegate the work to another basis of the same
##    left module (via a basechange matrix),
##
##  \item{2.}
##    *bases handled by nice bases* that delegate the work to a basis
##    of an isomorphic left module over the same left acting domain
##    (see~"Vector Spaces Handled By Nice Bases"), and
##
##  \item{3.}
##    bases that really do the work.
##  \endlist
##
##  *Constructors* for bases are `RelativeBasis' and `RelativeBasisNC'
##  in the case of relative bases, and `NewBasis' in the other cases.
##  Note that the left module knows whether its bases use nice bases or bases
##  that do the work, so appropriate methods of `NewBasis' can be installed.
##
##  Examples:
##  \beginlist
##  \item{-}
##    In the case of Gaussian row and matrix spaces,
##    `Basis( <V> )'
##    computes a semi-echelonized basis that uses Gaussian elimination.
##    A basis constructed with user supplied vectors is either
##    semi-echelonized or is a relative basis.
##
##  \item{-}
##    In the case of handling by nice bases, *no* basechange matrix is used
##    (the nice basis, however, is allowed to use a basechange matrix).
##
##  \item{-}
##    Non-Gaussian row and matrix spaces are handled via nice bases.
##
##  \item{-}
##    Field element spaces occur in two situations.
##    For the fields themselves and subfields special bases are used.
##    For a subspace of a field the nice basis is constructed
##    relative to a basis of the enveloping field.
##  \endlist
##
Revision.basis_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsBasis( <obj> )
##
##  A basis of a free left module is an object that knows
##  how to compute coefficients w.r.t.~its basis vectors.
##  A basis is an immutable list,
##  the $i$-th entry being the $i$-th basis vector.
##
##  (See `IsMutableBasis' ("ref:ismutablebasis") for mutable bases.)
##
DeclareCategory( "IsBasis", IsHomogeneousList and IsDuplicateFreeList );


#############################################################################
##
#P  IsCanonicalBasis( <B> )
##
##  If the underlying free left module $V$ of the basis <B> supports a
##  canonical basis (see "CanonicalBasis") then `IsCanonicalBasis' returns
##  `true' if <B> is equal to the canonical basis of $V$,
##  and `false' otherwise.
##
DeclareProperty( "IsCanonicalBasis", IsBasis );


#############################################################################
##
#P  IsCanonicalBasisFullRowModule( <B> )
##
##  `IsCanonicalBasisFullRowModule' returns `true' if <B> is the canonical
##  basis (see~"IsCanonicalBasis") of a full row module
##  (see~"IsFullRowSpace"), and `false' otherwise.
##
DeclareProperty( "IsCanonicalBasisFullRowModule", IsBasis );

InstallTrueMethod( IsCanonicalBasis, IsCanonicalBasisFullRowModule );

InstallTrueMethod( IsSmallList,
    IsList and IsCanonicalBasisFullRowModule );


#############################################################################
##
#P  IsCanonicalBasisFullMatrixModule( <B> )
##
##  `IsCanonicalBasisFullMatrixModule' returns `true' if <B> is the canonical
##  basis (see~"IsCanonicalBasis") of a full matrix module
##  (see~"IsFullMatrixSpace"), and `false' otherwise.
##
DeclareProperty( "IsCanonicalBasisFullMatrixModule", IsBasis );

InstallTrueMethod( IsCanonicalBasis, IsCanonicalBasisFullMatrixModule );

InstallTrueMethod( IsSmallList,
    IsList and IsCanonicalBasisFullMatrixModule );


#############################################################################
##
#P  IsIntegralBasis( <B> )
##
##  is `true' if <B> is a basis for the ring of integers in the underlying
##  left module of <B>, which must be a field.
##
DeclareProperty( "IsIntegralBasis", IsBasis );


#############################################################################
##
#P  IsNormalBasis( <B> )
##
##  is `true' if <B> is invariant under the Galois group of the underlying
##  left module of <B>, which must be a field.
##
DeclareProperty( "IsNormalBasis", IsBasis );


#############################################################################
##
#P  IsSemiEchelonized( <B> )
##
##  Let <B> be a basis of a Gaussian row or matrix space $V$, say
##  (see~"IsGaussianSpace") over the field $F$.
##
##  If $V$ is a row space then <B> is semi-echelonized if the matrix formed
##  by its basis vectors has the property that the first nonzero element in
##  each row is the identity of $F$,
##  and all values exactly below these pivot elements are the zero of $F$
##  (cf.~"SemiEchelonMat").
##  
##  If $V$ is a matrix space then <B> is semi-echelonized if the matrix
##  obtained by replacing each basis vector by the concatenation of its rows
##  is semi-echelonized (see above, cf.~"SemiEchelonMats").
##
DeclareProperty( "IsSemiEchelonized", IsBasis );


#############################################################################
##
#A  BasisVectors( <B> )
##
##  is the (immutable) list of basis vectors of the basis <B>.
##
DeclareAttribute( "BasisVectors", IsBasis );


#############################################################################
##
#A  EnumeratorByBasis( <B> )
##
##  is an enumerator for the underlying left module of the basis <B> w.r.t.
##  this basis.
##
DeclareAttribute( "EnumeratorByBasis", IsBasis );


#############################################################################
##
#A  StructureConstantsTable( <B> )
##
##  is defined only if the underlying left module of the basis <B> is also
##  a ring.
##
##  In this case `StructureConstantsTable' returns a structure constants
##  table $T$ in sparse representation, as used for structure constants
##  algebras (see Section~"tut:Algebras" of the user's Tutorial).
##
##  The coefficients of the product $b_i b_j$ of basis vectors are stored in
##  $T[i][j]$ as a list of length 2; its first entry is the list of positions
##  of nonzero coefficients, the second entry is the list of the coefficients
##  themselves.
##
##  The multiplication in an algebra $A$ with vector space basis <B>
##  with basis vectors $( v_1, \ldots, v_n )$ is determined by the so-called
##  structure matrices $M_k = [ m_{ijk} ]_{ij}, 1 \leq i \leq n$.
##  The $M_k$ are defined by $v_i v_j = \sum_k m_{i,j,k} v_k$.
##  Let $a = [ a_1, \ldots, a_n ], b = [ b_1, \ldots, b_n ]$.  Then
##  $$ ( \sum_i a_i v_i ) ( \sum_j b_j v_j )
##     = \sum_{i,j} a_i b_j ( v_i v_j )
##     = \sum_k ( \sum_j ( \sum_i a_i m_{i,j,k} ) b_j ) v_k
##     = \sum_k ( a M_k b^{tr} ) v_k \ . $$
##
DeclareAttribute( "StructureConstantsTable", IsBasis );


#############################################################################
##
#A  UnderlyingLeftModule( <B> )
##
##  Is the left module of which <B> is a basis.
##
DeclareAttribute( "UnderlyingLeftModule", IsBasis );


#############################################################################
##
#O  Coefficients( <B>, <v> )  . . . coefficients of <v> w.r. to the basis <B>
##
##  Let $V$ be the underlying left module of the basis <B>, and <v> a vector
##  such that the family of <v> is the elements family of the family of <V>.
##  Then `Coefficients( <B>, <v> )' is the list of coefficients of <v> w.r.t.
##  <B> if <v> lies in $V$, and `fail' otherwise.
##
DeclareOperation( "Coefficients", [ IsBasis, IsVector ] );


#############################################################################
##
#O  LinearCombination( <B>, <coeff> ) . . . . linear combination w. r. to <B>
#O  LinearCombination( <vectors>, <coeff> )
##
##  is the vector $\sum_{i=1}^n <coeff>[i] \* `BasisVectors( <B> )'[i]$.
##
DeclareOperation( "LinearCombination", [ IsBasis, IsHomogeneousList ] );


#############################################################################
##
#O  SiftedVector( <B>, <v> ) . . . . . . residuum of <v> w.r.t. the basis <B>
##
##  Let <B> be a semi-echelonized basis (see~"IsSemiEchelonized") of a
##  Gaussian row or matrix space $V$ (see~"IsGaussianSpace"),
##  and <v> a row vector or matrix, respectively, of the same dimension as
##  the elements in $V$.
##  `SiftedVector' returns the *residuum* of <v> with respect to <B>, which
##  is obtained by successively cleaning the pivot positions in <v> by
##  subtracting multiples of the basis vectors in <B>.
##  So the result is the zero vector in $V$ if and only if <v> lies in $V$.
##
##  <B> may also be a mutable basis (see~"Mutable Bases") of a Gaussian row
##  or matrix space.
##
DeclareOperation( "SiftedVector", [ IsBasis, IsVector ] );


#############################################################################
##
#O  IteratorByBasis( <B> )
##
##  is an iterator for the underlying left module of the basis <B> w.r.t.
##  this basis.
##
DeclareOperation( "IteratorByBasis", [ IsBasis ] );


#############################################################################
##
#A  Basis( <V> )
#O  Basis( <V>, <vectors> )
#O  BasisNC( <V>, <vectors> )
##
##  Called with a free left module <V> as the only argument,
##  `Basis' returns an arbitrary basis of <V>.
##
##  If additionally a list <vectors> of vectors in <V> is given
##  that forms a basis of <V> then `Basis' returns this basis;
##  if <vectors> are not linearly independent or do not generate <V>
##  as a free left module over the left acting domain of <V>
##  then `fail' is returned.
##
##  `BasisNC' does the same as `Basis' for two arguments,
##  except that it is not checked whether <vectors> form a basis.
##
DeclareAttribute( "Basis", IsFreeLeftModule );
DeclareOperation( "Basis", [ IsFreeLeftModule, IsHomogeneousList ] );

DeclareOperation( "BasisNC", [ IsFreeLeftModule, IsHomogeneousList ] );


#############################################################################
##
#A  SemiEchelonBasis( <V> )
#O  SemiEchelonBasis( <V>, <vectors> )
#O  SemiEchelonBasisNC( <V>, <vectors> )
##
##  Let <V> be a Gaussian row or matrix vector space over the field $F$
##  (see~"IsGaussianSpace", "IsRowSpace", "IsMatrixSpace").
##
##  Called with <V> as the only argument,
##  `SemiEchelonBasis' returns a basis of <V> that has the property
##  `IsSemiEchelonized' (see~"IsSemiEchelonized").
##
##  If additionally a list <vectors> of vectors in <V> is given
##  that forms a semi-echelonized basis of <V> then `SemiEchelonBasis'
##  returns this basis;
##  if <vectors> do not form a basis of <V> then `fail' is returned.
##
##  `SemiEchelonBasisNC' does the same as `SemiEchelonBasis' for two
##  arguments,
##  except that it is not checked whether <vectors> form
##  a semi-echelonized basis.
##
DeclareAttribute( "SemiEchelonBasis", IsFreeLeftModule );
DeclareOperation( "SemiEchelonBasis",
    [ IsFreeLeftModule, IsHomogeneousList ] );

DeclareOperation( "SemiEchelonBasisNC",
    [ IsFreeLeftModule, IsHomogeneousList ] );
#T In fact they should be declared for `IsGaussianSpace', or at least for
#T `IsVectorSpace', but the files containing these categories are read later ..
#T (Change this!)


#############################################################################
##
#O  NewBasis( <V> )
#O  NewBasis( <V>, <gens> )
##
##  This operation is in principle obsolete.
##  The idea to introduce it was that its methods were allowed to call
##  `Objectify', whereas `Basis' methods were thought to call `NewBasis'.
##
DeclareOperation( "NewBasis", [ IsFreeLeftModule, IsCollection ] );


#############################################################################
##
#O  RelativeBasis( <B>, <vectors> )
#O  RelativeBasisNC( <B>, <vectors> )
##
##  A relative basis is a basis of the free left module <V> that delegates
##  the computation of coefficients etc. to another basis of <V> via
##  a basechange matrix.
##
##  Let <B> be a basis of the free left module <V>,
##  and <vectors> a list of vectors in <V>.
##
##  `RelativeBasis' checks whether <vectors> form a basis of <V>,
##  and in this case a basis is returned in which <vectors> are
##  the basis vectors; otherwise `fail' is returned.
##
##  `RelativeBasisNC' does the same, except that it omits the check.
##
DeclareOperation( "RelativeBasis", [ IsBasis, IsHomogeneousList ] );
DeclareOperation( "RelativeBasisNC", [ IsBasis, IsHomogeneousList ] );


#############################################################################
##
#F  DeclareHandlingByNiceBasis( <name>, <info> )
#F  InstallHandlingByNiceBasis( <name>, <record> )
##
##  These functions are used to implement a new kind of free left modules
##  that shall be handled via the mechanism of nice bases.
##  <name> must be a string, a filter $f$ with this name is created and
##  a logical implication from $f$ to `IsHandledByNiceBasis' is installed.
##  <record> must be a record with the following components.
##  \beginitems
##  `detect' &
##      a function of four arguments $R$, $l$, $V$, and $z$,
##      where $V$ is a free left module over the ring $R$ with generators
##      the list or collection $l$, and $z$ is either the zero element of
##      $V$ or `false' (then $l$ is nonempty);
##      the function returns `true' if $V$ shall lie in the filter $f$,
##      and `false' otherwise,
##      the return value may also be `fail', which indicates that $V$ is
##      *not* to be handled via the mechanism of nice bases at all,
##
##  `NiceFreeLeftModuleInfo' &
##      the `NiceFreeLeftModuleInfo' method for left modules in $f$,
##
##  `NiceVector' &
##      the `NiceVector' method for left modules $V$ in $f$;
##      called with $V$ and a vector $v \in V$, this function returns the
##      nice vector $r$ associated with $v$, and
##
##  `UglyVector' &
##      the `UglyVector' method for left modules $V$ in $f$;
##      called with $V$ and a vector $r$ in the `NiceFreeLeftModule' value
##      of $V$, this function returns the vector $v \in V$ to which $r$ is
##      associated.
##  \enditems
##
##  The idea is that all one has to do for implementing a new kind of free
##  left modules handled by the mechanism of nice bases is to call
##  `DeclareHandlingByNiceBasis' and `InstallHandlingByNiceBasis',
##  which causes the installation of the necessary methods and adds the pair
##  $[ f, `<record>\.detect' ]$ to the global list `NiceBasisFiltersInfo'.
##  The `LeftModuleByGenerators' methods call `CheckForHandlingByNiceBasis'
##  (see~"CheckForHandlingByNiceBasis"), which sets the appropriate filter
##  for the desired left module if applicable.
##
##  An overview of all kinds of vector spaces that are currently handled by
##  nice bases is given by the global list `NiceBasisFiltersInfo'.
##  Examples of such vector spaces are vector spaces of field elements
##  (but not the fields themselves) and non-Gaussian row and matrix spaces
##  (see~"IsGaussianSpace").
##
DeclareGlobalFunction( "DeclareHandlingByNiceBasis" );
DeclareGlobalFunction( "InstallHandlingByNiceBasis" );


#############################################################################
##
#F  CheckForHandlingByNiceBasis( <R>, <gens>, <M>, <zero> )
#V  NiceBasisFiltersInfo
##
##  Whenever a free left module is constructed for which the filter
##  `IsHandledByNiceBasis' may be useful, `CheckHandlingByNiceBasis' should
##  be called.
##  The arguments of this function are the coefficient ring <R>, the list
##  <gens> of generators, the constructed module <M> itself, and the zero
##  element <zero> of <M>;
##  if <gens> is nonempty then the <zero> value may also be `false'.
##
##  
#T ...
##
DeclareGlobalFunction( "CheckForHandlingByNiceBasis" );
BindGlobal( "NiceBasisFiltersInfo", [] );


InstallGlobalFunction( "DeclareHandlingByNiceBasis", function( name, info )
    local len, i;
    len:= Length( NiceBasisFiltersInfo );
    for i in [ len, len-1 .. 1 ] do
      NiceBasisFiltersInfo[ i+1 ]:= NiceBasisFiltersInfo[i];
    od;
    DeclareFilter( name );
    NiceBasisFiltersInfo[1]:= [ ValueGlobal( name ), info ];
end );


#############################################################################
##
#F  IsGenericFiniteSpace( <V> )
##
##  If an $F$-vector space <V> is in the filter `IsGenericFiniteSpace' then
##  this expresses that <V> consists of elements in a *finite* vector space,
##  and that <V> is handled via the mechanism of nice bases (see~"...") in
##  the following way.
##  (This is the generic treatment of finite vector spaces, better methods
##  are installed for various special kinds of finite vector spaces.)
##  Let $F$ be of order $q$, $e_F$ a list of the elements of $F$,
##  $B = [ b_0, b_1, \ldots, b_k ]$ an $F$-basis of $V$,
##  and let $e_V$ a list of elements of $V$ with the property that
##  $e_V[ 1 + \sum_{i=0}^k c_i q^i ] = \sum_{i=0}^k e_F[ c_i + 1 ] b_i$;
##  then the `NiceVector' value of $e_V[ 1 + \sum_{i=0}^k c_i q^i ]$ is the
##  row vector $[ r_0, r_1, \ldots, r_k ]$ with $r_i = e_F[ c_i + 1 ]$,
##  and the `UglyVector' value of $[ r_0, r_1, \ldots, r_k ]$ is
##  $\sum_{i=0}^k r_i b_i$.
##
##  The `NiceFreeLeftModuleInfo' value of $V$ is a record with the following
##  components.
##  \beginitems
##  `elements'  : \\
##      a *strictly sorted* list $\tilde{e}_V$ of elements of $V$,
##
##  `numbers'   : \\
##      a list $l$ of the positive integers up to $q^{k+1}$, such that
##      $e_V[ l[i] ] = \tilde{e}_V[i]$ holds for $1 \leq i \leq q^{k+1}$.
##
##  `q' &
##      the size of $F$,
##
##  `fieldelements' &
##      the list $e_F$,
##
##  `base' &
##      the list $B$.
##  \enditems
#T use that the nice module is a full row space!
#T (special method for NiceFreeLeftModule?)
##
#T  It is important that all other filters of this kind are installed *later*
#T  because otherwise the generic treatment may be chosen in cases for which
#T  a later filter indicates better methods.
##
DeclareHandlingByNiceBasis( "IsGenericFiniteSpace",
    "for finite vector spaces (generic)" );


#############################################################################
##
#C  IsBasisByNiceBasis( <B> )
##
##  Let $B$ be a basis of the free left $F$-module $V$.
##  Computations in $V$ may be easy as long as no basis dependent
##  calculations occur, but usually there is a canonical way to delegate the
##  computation of basis vectors, coefficients w.r.t. $B$ etc.
##  to a basis $C$ of an isomorphic ``nicer'' left $F$-module,
##  which usually is a Gaussian row vector space or a Gaussian matrix vector
##  space,
##  and thus allows one to apply Gaussian elimination.
##  $C$ is called the {\it nice basis} of $B$, its underlying space $W$
##  is called the {\it nice vector space} of $V$.
##  (It is *not* required that the nice vector space is a coefficient space.)
##
##  $B$ stores $C$ as value of the attribute `NiceBasis', and $B$ knows how
##  to convert elements of $V$ to the corresponding elements of $W$,
##  and vice versa.
##
##  Any object in `IsBasisByNiceBasis' must be a *small* list in the sense of
##  `IsSmallList' (see~"IsSmallList").
##
##  If left module generators for $V$ are known then the usual process is as
##  follows.
##  \beginlist
##  \item{1.}
##     `B:= Basis( <V> )'
##           computes a basis for <V>, without basis vectors.
##  \item{2.}
##     `NiceFreeLeftModuleInfo( <V> )'
##           computes the necessary data for the bijections
##  \item{3.}
##     `W:= NiceFreeLeftModule( <V> )'
##           computes the left module generated by the images of
##           left module generators of <V> under the homomorphism mentioned
##           above.
##           (There are two generic methods for this, namely for the cases
##           that either left module generators of <V> are known or that
##           <V> is a FLMLOR(-with-one) with known left operator
##           ring(-with-one) generators.)
##  \item{3.}
##     `C:= Basis( W )'
##           computes a basis of the nice module `W' (That this is possible
##           is a problem of `W' and must of course be assumed!).
##  \item{4.}
##     `BasisVectors( B )'
##           computes the preimages of `BasisVectors( C )' under the
##           homomorphism.
##  \endlist
##
##  The default of `NiceBasis( <B> )' is
##  `Basis( NiceFreeLeftModule( <V> ) )' if no basis vectors are bound in
##  <B>, and this will usually be a semi-echelonized basis;
##  thus such a basis will be chosen in the call `Basis( <V> )'.
##  If basis vectors are stored in <B> then the nice vectors of
##  these vectors are taken as basis vectors.
##  `NiceBasisNC( <B> )' does not check whether the basis vectors of
##  <B> really form a basis.
##
##  (The only situation where the `NC' version is not used is in the
##  construction of bases with prescribed vectors.)
##
##  If left module generators of <V> are known, and if <V> is finite
##  then there is a default method to compute a nice free left module,
##  namely computing all elements of the left module,
##  and in parallel computing a basis.
##
##  *Note* that `NiceVector' and `UglyVector' may yield
##  incorrect results if <v> resp. <r> is not an element of $V$ resp. $W$.
##
##  The computation of a basis of $V$ does *not* necessarily cause the
##  computation of basis vectors.  For that, the computation of the
##  nice module, its basis, its basis vectors,
##  and then the ugly vectors in $V$ may be necessary.
##  (example: spaces of polynomials)
##
DeclareCategory( "IsBasisByNiceBasis", IsBasis and IsSmallList );


#############################################################################
##
#A  NiceBasis( <B> )
##
##  Let <B> be a basis of a free left module <V> that is handled via
##  nice bases.
##  If <B> has no basis vectors stored at the time of the first call to
##  `NiceBasis' then `NiceBasis( <B> )' is obtained as
##  `Basis( NiceFreeLeftModule( <V> ) )'.
##  If basis vectors are stored then `NiceBasis( <B> )' is the result of the
##  call of `Basis' with arguments `NiceFreeLeftModule( <V> )'
##  and the `NiceVector' values of the basis vectors of <B>.
##
##  Note that the result is `fail' if and only if the ``basis vectors''
##  stored in <B> are in fact not basis vectors.
##
##  The attributes `GeneratorsOfLeftModule' of the underlying left modules
##  of <B> and the result of `NiceBasis' correspond via `NiceVector' and
##  `UglyVector'.
##
DeclareAttribute( "NiceBasis", IsBasisByNiceBasis );


#############################################################################
##
#O  NiceBasisNC( <B> )
##
##  If the basis <B> has basis vectors bound then the attribute `NiceBasis'
##  of <B> is set to `BasisNC( <W>, <nice> )'
##  where <W> is the value of `NiceFreeLeftModule' for the underlying
##  free left module of <B>.
##  This means that it is *not* checked whether <B> really is a basis.
##
DeclareOperation( "NiceBasisNC", [ IsBasisByNiceBasis ] );


#############################################################################
##
#A  NiceFreeLeftModule( <V> ) . . . . nice free left module isomorphic to <V>
##
##  For a free left module <V> that is handled via the mechanism of nice
##  bases, this attribute stores the associated free left module to which the
##  tasks are delegated via `NiceVector'.
##
DeclareAttribute( "NiceFreeLeftModule", IsFreeLeftModule );


#############################################################################
##
#A  NiceFreeLeftModuleInfo( <V> )
##
##  For a free left module <V> that is handled via the mechanism of nice
##  bases, this operation has to provide the necessary information (if any)
##  for calls of `NiceVector' and `UglyVector' (see~"NiceVector").
##
DeclareAttribute( "NiceFreeLeftModuleInfo",
    IsFreeLeftModule and IsHandledByNiceBasis );


#############################################################################
##
#O  NiceVector( <V>, <v> )
#O  UglyVector( <V>, <r> )
##
##  `NiceVector' and `UglyVector' provide the linear bijection between the
##  free left module <V> and `<W>:= NiceFreeLeftModule( <V> )'.
##
##  If <v> lies in the elements family of the family of <V> then
##  `NiceVector( <v> )' is either `fail' or an element in the elements family
##  of the family of <W>.
##
##  If <r> lies in the elements family of the family of <W> then
##  `UglyVector( <r> )' is either `fail' or an element in the elements family
##  of the family of <V>.
##
##  If <v> lies in <V> (which usually cannot be checked without using <W>)
##  then `UglyVector( <V>, NiceVector( <V>, <v> ) ) = <v>'.
##  If <r> lies in <W> (which usually can be checked)
##  then `NiceVector( <V>, UglyVector( <V>, <r> ) ) = <r>'.
##
##  (This allows one for example to implement a membership test for <V>
##  using the membership test in <W>.)
##
DeclareOperation( "NiceVector",
    [ IsFreeLeftModule and IsHandledByNiceBasis, IsObject ] );

DeclareOperation( "UglyVector",
    [ IsFreeLeftModule and IsHandledByNiceBasis, IsObject ] );


#############################################################################
##
#F  BasisWithReplacedLeftModule( <B>, <V> )
##
##  For a basis <B> and a left module <V> that is equal to the underlying
##  left module of <B>,
##  `BasisWithReplacedLeftModule' returns a basis equal to <B> except that
##  the underlying left module of this basis is <V>.
##
DeclareGlobalFunction( "BasisWithReplacedLeftModule" );


#############################################################################
##
#E

#############################################################################
##
#A  BasisOfDomain( <V> )
#O  BasisByGenerators( <V>, <vectors> )
#O  BasisByGeneratorsNC( <V>, <vectors> )
#A  SemiEchelonBasisOfDomain( <V> )
#O  SemiEchelonBasisByGenerators( <V>, <vectors> )
#O  SemiEchelonBasisByGeneratorsNC( <V>, <vectors> )
##
DeclareSynonymAttr( "BasisOfDomain", Basis );
DeclareSynonym( "BasisByGenerators", Basis );
DeclareSynonym( "BasisByGeneratorsNC", BasisNC );
DeclareSynonymAttr( "SemiEchelonBasisOfDomain", SemiEchelonBasis );
DeclareSynonym( "SemiEchelonBasisByGenerators", SemiEchelonBasis );
DeclareSynonym( "SemiEchelonBasisByGeneratorsNC", SemiEchelonBasisNC );
#T obsolete!


