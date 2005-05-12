#############################################################################
##
#W  basis.gd                    GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for bases of free left modules.
##


#############################################################################
#1
##  In {\GAP}, a *basis* of a free left $F$-module $V$ is a list of vectors
##  $B = [ v_1, v_2, \ldots, v_n ]$ in $V$ such that $V$ is generated as a
##  left $F$-module by these vectors and such that $B$ is linearly
##  independent over $F$.
##  The integer $n$ is the dimension of $V$ (see~"Dimension").
##  In particular, as each basis is a list (see Chapter~"Lists"),
##  it has a length (see~"Length"), and the $i$-th vector of $B$ can be
##  accessed as $B[i]$.
##  \beginexample
##  gap> V:= Rationals^3;
##  ( Rationals^3 )
##  gap> B:= Basis( V );
##  CanonicalBasis( ( Rationals^3 ) )
##  gap> Length( B );
##  3
##  gap> B[1];
##  [ 1, 0, 0 ]
##  \endexample
##
##  The operations described below make sense only for bases of *finite*
##  dimensional vector spaces.
##  (In practice this means that the vector spaces must be *low* dimensional,
##  that is, the dimension should not exceed a few hundred.)
##
##  Besides the basic operations for lists
##  (see~"Basic Operations for Lists"),
##  the *basic operations for bases* are `BasisVectors' (see~"BasisVectors"),
##  `Coefficients' (see~"Coefficients"),
##  `LinearCombination' (see~"LinearCombination"),
##  and `UnderlyingLeftModule' (see~"UnderlyingLeftModule").
##  These and other operations for arbitrary bases are described
##  in~"Operations for Vector Space Bases".
##
##  For special kinds of bases, further operations are defined
##  (see~"Operations for Special Kinds of Bases").
##
##  {\GAP} supports the following three kinds of bases.
##
##  *Relative bases* delegate the work to other bases of the same
##  free left module, via basechange matrices (see~"RelativeBasis").
##
##  *Bases handled by nice bases* delegate the work to bases
##  of isomorphic left modules over the same left acting domain
##  (see~"Vector Spaces Handled By Nice Bases").
##
##  Finally, of course there must be bases in {\GAP} that really do the work.
##
##  For example, in the case of a Gaussian row or matrix space <V>
##  (see~"Row and Matrix Spaces"),
##  `Basis( <V> )' is a semi-echelonized basis (see~"IsSemiEchelonized")
##  that uses Gaussian elimination; such a basis is of the third kind.
##  `Basis( <V>, <vectors> )' is either semi-echelonized or a relative basis.
##  Other examples of bases of the third kind are canonical bases of finite
##  fields and of abelian number fields.
##
##  Bases handled by nice bases are described
##  in~"Vector Spaces Handled By Nice Bases".
##  Examples are non-Gaussian row and matrix spaces, and subspaces of finite
##  fields and abelian number fields that are themselves not fields.
##  
Revision.basis_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsBasis( <obj> )
##
##  In {\GAP}, a *basis* of a free left module is an object that knows how to
##  compute coefficients w.r.t.~its basis vectors (see~"Coefficients").
##  Bases are constructed by `Basis' (see~"Basis").
##  Each basis is an immutable list,
##  the $i$-th entry being the $i$-th basis vector.
##
##  (See~"Mutable Bases" for mutable bases.)
##
DeclareCategory( "IsBasis", IsHomogeneousList and IsDuplicateFreeList );


#############################################################################
##
#C  IsFiniteBasisDefault( <obj> )
##
##  Objects in this category are in `IsListDefault', that is, addition and
##  multiplication for them is defined as for internally represented lists,
##  the result presumably being an internally represented list.
##
DeclareSynonym( "IsFiniteBasisDefault",
    IsBasis and IsCopyable and IsListDefault );


#############################################################################
##
#P  IsCanonicalBasis( <B> )
##
##  If the underlying free left module $V$ of the basis <B> supports a
##  canonical basis (see~"CanonicalBasis") then `IsCanonicalBasis' returns
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
##  (see~"IsFullRowModule"), and `false' otherwise.
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
##  (see~"IsFullMatrixModule"), and `false' otherwise.
##
DeclareProperty( "IsCanonicalBasisFullMatrixModule", IsBasis );

InstallTrueMethod( IsCanonicalBasis, IsCanonicalBasisFullMatrixModule );

InstallTrueMethod( IsSmallList,
    IsList and IsCanonicalBasisFullMatrixModule );


#############################################################################
##
#P  IsIntegralBasis( <B> )
##
##  Let <B> be an $S$-basis of a *field* $F$, say, for a subfield $S$ of $F$,
##  and let $R$ and $M$ be the rings of algebraic integers in $S$ and $F$,
##  respectively.
##  `IsIntegralBasis' returns `true' if <B> is also an $R$-basis of $M$,
##  and `false' otherwise.
##
DeclareProperty( "IsIntegralBasis", IsBasis );


#############################################################################
##
#P  IsNormalBasis( <B> )
##
##  Let <B> be an $S$-basis of a *field* $F$, say, for a subfield $S$ of $F$.
##  `IsNormalBasis' returns `true' if <B> is invariant under the Galois group
##  (see~"GaloisGroup!of field") of the field extension $F / S$,
##  and `false' otherwise.
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
##  For a vector space basis <B>, `BasisVectors' returns the list of basis
##  vectors of <B>.
##  The lists <B> and `BasisVectors( <B> )' are equal; the main purpose of
##  `BasisVectors' is to provide access to a list of vectors that does *not*
##  know about an underlying vector space.
##
DeclareAttribute( "BasisVectors", IsBasis );


#############################################################################
##
#A  EnumeratorByBasis( <B> )
##
##  For a basis <B> of the free left $F$-module $V$ of dimension $n$, say,
##  `EnumeratorByBasis' returns an enumerator that loops over the elements of
##  $V$ as linear combinations of the vectors of <B> with coefficients the
##  row vectors in the full row space (see~"FullRowSpace") of dimension $n$
##  over $F$, in the succession given by the default enumerator of this row
##  space.
##
DeclareAttribute( "EnumeratorByBasis", IsBasis );


#############################################################################
##
#A  StructureConstantsTable( <B> )
##
##  Let <B> be a basis of a free left module $R$, say, that is also a ring.
##  In this case `StructureConstantsTable' returns a structure constants
##  table $T$ in sparse representation, as used for structure constants
##  algebras (see Section~"tut:Algebras" of the {\GAP} User's Tutorial).
##
##  If <B> has length $n$ then $T$ is a list of length $n+2$.
##  The first $n$ entries of $T$ are lists of length $n$.
##  $T[ n+1 ]$ is one of $1$, $-1$, or $0$;
##  in the case of $1$ the table is known to be symmetric,
##  in the case of $-1$ it is known to be antisymmetric,
##  and $0$ occurs in all other cases.
##  $T[ n+2 ]$ is the zero element of the coefficient domain.
##
##  The coefficients w.r.t.~<B> of the product of the $i$-th and $j$-th basis
##  vector of <B> are stored in $T[i][j]$ as a list of length $2$;
##  its first entry is the list of positions of nonzero coefficients,
##  the second entry is the list of these coefficients themselves.
##
##  The multiplication in an algebra $A$ with vector space basis <B>
##  with basis vectors $[ v_1, \ldots, v_n ]$ is determined by the so-called
##  structure matrices $M_k = [ m_{ijk} ]_{ij}, 1 \leq k \leq n$.
##  The $M_k$ are defined by $v_i v_j = \sum_k m_{i,j,k} v_k$.
##  Let $a = [ a_1, \ldots, a_n ]$ and $b = [ b_1, \ldots, b_n ]$.
##  Then
##  $$
##  ( \sum_i a_i v_i ) ( \sum_j b_j v_j )
##     = \sum_{i,j} a_i b_j ( v_i v_j )
##     = \sum_k ( \sum_j ( \sum_i a_i m_{i,j,k} ) b_j ) v_k
##     = \sum_k ( a M_k b^{tr} ) v_k\.
##  $$
##
DeclareAttribute( "StructureConstantsTable", IsBasis );


#############################################################################
##
#A  UnderlyingLeftModule( <B> )
##
##  For a basis <B> of a free left module $V$, say,
##  `UnderlyingLeftModule' returns $V$.
##
##  The reason why a basis stores a free left module is that otherwise one
##  would have to store the basis vectors and the coefficient domain
##  separately.
##  Storing the module allows one for example to deal with bases whose basis
##  vectors have not yet been computed yet (see~"Basis");
##  furthermore, in some cases it is convenient to test membership of a
##  vector in the module before computing coefficients w.r.t.~a basis.
#T this happens for example for finite fields and cyclotomic fields
##
DeclareAttribute( "UnderlyingLeftModule", IsBasis );


#############################################################################
##
#O  Coefficients( <B>, <v> )  . . . coefficients of <v> w.r. to the basis <B>
##
##  Let $V$ be the underlying left module of the basis <B>, and <v> a vector
##  such that the family of <v> is the elements family of the family of $V$.
##  Then `Coefficients( <B>, <v> )' is the list of coefficients of <v> w.r.t.
##  <B> if <v> lies in $V$, and `fail' otherwise.
##
DeclareOperation( "Coefficients", [ IsBasis, IsVector ] );


#############################################################################
##
#O  LinearCombination( <B>, <coeff> ) . . . .  linear combination w. r.t. <B>
#O  LinearCombination( <vectors>, <coeff> )
##
##  If <B> is a basis of length $n$, say, and <coeff> is a row vector of the
##  same length as <B>, `LinearCombination' returns the vector
##  $\sum_{i=1}^n <coeff>[i] \* <B>[i]$.
##
##  If <vectors> and <coeff> are homogeneous lists of the same length <n>,
##  say, `LinearCombination' returns the vector
##  $\sum_{i=1}^n <coeff>[i]\*<vectors>[i]$.
##  Perhaps the most important usage is the case where <vectors> forms a 
##  basis.
##
DeclareOperation( "LinearCombination",
    [ IsHomogeneousList, IsHomogeneousList ] );


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
##  For a basis <B> of the free left $F$-module $V$ of dimension $n$, say,
##  `IteratorByBasis' returns an iterator that loops over the elements of $V$
##  as linear combinations of the vectors of <B> with coefficients the row
##  vectors in the full row space (see~"FullRowSpace") of dimension $n$ over
##  $F$, in the succession given by the default enumerator of this row space.
##
DeclareOperation( "IteratorByBasis", [ IsBasis ] );


#############################################################################
##
#A  Basis( <V> )
#O  Basis( <V>, <vectors> )
#O  BasisNC( <V>, <vectors> )
##
##  Called with a free left $F$-module <V> as the only argument,
##  `Basis' returns an $F$-basis of <V> whose vectors are not further
##  specified.
##
##  If additionally a list <vectors> of vectors in <V> is given
##  that forms an $F$-basis of <V> then `Basis' returns this basis;
##  if <vectors> is not linearly independent over $F$ or does not generate
##  <V> as a free left $F$-module then `fail' is returned.
##
##  `BasisNC' does the same as `Basis' for two arguments,
##  except that it does not check whether <vectors> form a basis.
##
##  If no basis vectors are prescribed then `Basis' need not compute
##  basis vectors; in this case, the vectors are computed in the first call
##  to `BasisVectors'.
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
#2
##  There are kinds of free $R$-modules for which efficient computations are
##  possible because the elements are ``nice'', for example subspaces of full
##  row modules or of full matrix modules.
##  In other cases, a ``nice'' canonical basis is known that allows one to do
##  the necessary computations in the corresponding row module,
##  for example algebras given by structure constants.
##
##  In many other situations, one knows at least an isomorphism from the
##  given module $V$ to a ``nicer'' free left module $W$,
##  in the sense that for each vector in $V$, the image in $W$ can easily be
##  computed, and analogously for each vector in $W$, one can compute the
##  preimage in $V$.
##
##  This allows one to delegate computations w.r.t.~a basis $B$, say, of $V$
##  to the corresponding basis $C$, say, of $W$.
##  We call $W$ the *nice free left module* of $V$, and $C$ the *nice basis*
##  of $B$.
##  (Note that it may happen that also $C$ delegates questions to a ``nicer''
##  basis.)
##  The basis $B$ indicates the intended behaviour by the filter
##  `IsBasisByNiceBasis' (see~"IsBasisByNiceBasis"),
##  and stores $C$ as value of the attribute `NiceBasis' (see~"NiceBasis").
##  $V$ indicates the intended behaviour by the filter `IsHandledByNiceBasis'
##  (see~"IsHandledByNiceBasis!for vector spaces"), and stores $W$  as  value
##  of the attribute `NiceFreeLeftModule' (see~"NiceFreeLeftModule").
##
##  The bijection between $V$ and $W$ is implemented by the functions
##  `NiceVector' (see~"NiceVector") and `UglyVector' (see~"UglyVector");
##  additional data needed to compute images and preimages can be stored
##  as value of `NiceFreeLeftModuleInfo' (see~"NiceFreeLeftModuleInfo").
##


#############################################################################
##
#F  DeclareHandlingByNiceBasis( <name>, <info> )
#F  InstallHandlingByNiceBasis( <name>, <record> )
##
##  These functions are used to implement a new kind of free left modules
##  that shall be handled via the mechanism of nice bases
##  (see~"Vector Spaces Handled By Nice Bases").
##
##  <name> must be a string, a filter $f$ with this name is created, and
##  a logical implication from $f$ to `IsHandledByNiceBasis'
##  (see~"IsHandledByNiceBasis!for vector spaces") is installed.
##
##  <record> must be a record with the following components.
##  \beginitems
##  `detect' &
##      a function of four arguments $R$, $l$, $V$, and $z$,
##      where $V$ is a free left module over the ring $R$ with generators
##      the list or collection $l$, and $z$ is either the zero element of
##      $V$ or `false' (then $l$ is nonempty);
##      the function returns `true' if $V$ shall lie in the filter $f$,
##      and `false' otherwise;
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
DeclareGlobalFunction( "DeclareHandlingByNiceBasis" );
DeclareGlobalFunction( "InstallHandlingByNiceBasis" );


#############################################################################
##
#V  NiceBasisFiltersInfo
##
##  An overview of all kinds of vector spaces that are currently handled by
##  nice bases is given by the global list `NiceBasisFiltersInfo'.
##  Examples of such vector spaces are vector spaces of field elements
##  (but not the fields themselves) and non-Gaussian row and matrix spaces
##  (see~"IsGaussianSpace").
##
BindGlobal( "NiceBasisFiltersInfo", [] );


#############################################################################
##
#F  CheckForHandlingByNiceBasis( <R>, <gens>, <M>, <zero> )
##
##  Whenever a free left module is constructed for which the filter
##  `IsHandledByNiceBasis' may be useful,
##  `CheckForHandlingByNiceBasis' should be called.
##  (This is done in the methods for `VectorSpaceByGenerators',
##  `AlgebraByGenerators', `IdealByGenerators' etc.~in the {\GAP} library.)
##
##  The arguments of this function are the coefficient ring <R>, the list
##  <gens> of generators, the constructed module <M> itself, and the zero
##  element <zero> of <M>;
##  if <gens> is nonempty then the <zero> value may also be `false'.
##
DeclareGlobalFunction( "CheckForHandlingByNiceBasis" );


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
#F  IsSpaceOfRationalFunctions( <V> )
##
##  If an $F$-vector space <V> is in the filter `IsSpaceOfRationalFunctions'
##  then this expresses that <V> consists of rational functions,
##  and that <V> is handled via the mechanism of nice bases in the following
##  way.
##  Let $v_1, v_2, \ldots, v_k$ be vector space generators of <V>,
##  let $d$ be a polynomial such that all $d \cdot v_i$ are polynomials,
##  and let $S$ be the set of monomials that occur in these polynomials.
##  Then the `NiceFreeLeftModuleInfo' value of <V> is a record with the
##  following components.
##  \beginitems
##  `family' &
##     the elements family of <V>,
##
##  `monomials' &
##     the list $S$,
##
##  `denom' &
##     the polynomial $d$,
##
##  `zerocoeff' &
##     the zero coefficient of elements in <V>,
##
##  `zerovector' &
##     the zero row vector in the nice free left module.
##  \enditems
##  The `NiceVector' value of $v \in <V>$ is defined as the row vector of
##  coefficients of $v$ w.r.t.~$S$.
##
##  Finite dimensional free left modules of rational functions
##  are by default handled via the mechanism of nice bases.
##
DeclareHandlingByNiceBasis( "IsSpaceOfRationalFunctions",
    "for free left modules of rational functions" );


#############################################################################
##
#C  IsBasisByNiceBasis( <B> )
##
##  This filter indicates that the basis <B> delegates tasks such as the
##  computation of coefficients (see~"Coefficients") to a basis of an
##  isomorphisc ``nicer'' free left module.
#T  Any object in `IsBasisByNiceBasis' must be a *small* list in the sense of
#T  `IsSmallList' (see~"IsSmallList").
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
##  tasks are delegated.
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
##  If <v> lies in <V> (which usually *cannot* be checked without using <W>)
##  then `UglyVector( <V>, NiceVector( <V>, <v> ) ) = <v>'.
##  If <r> lies in <W> (which usually *can* be checked)
##  then `NiceVector( <V>, UglyVector( <V>, <r> ) ) = <r>'.
##
##  (This allows one to implement for example a membership test for <V>
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

