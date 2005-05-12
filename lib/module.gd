#############################################################################
##
#W  module.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file declares the operations for left modules, right modules,
##  and bimodules.
##
Revision.module_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsLeftOperatorAdditiveGroup( <D> )
##
##  A domain <D> lies in `IsLeftOperatorAdditiveGroup' if it is an additive
##  group that is closed under scalar multplication from the
##  left, and such that $\lambda*(x+y)=\lambda*x+\lambda*y$ for all
##  scalars $\lambda$ and elements $x,y\in D$.
##
DeclareSynonym( "IsLeftOperatorAdditiveGroup",
        IsAdditiveGroup
    and IsExtLSet
    and IsDistributiveLOpDSum );


#############################################################################
##
#C  IsLeftModule( <M> )
##
##  A domain <M> lies in `IsLeftModule' if it lies in
##  `IsLeftOperatorAdditiveGroup', {\it and} the set of scalars forms a ring,
##  {\it and} $(\lambda+\mu)*x=\lambda*x+\mu*x$ for scalars $\lambda,\mu$
##  and $x\in M$, {\it and} scalar multiplication satisfies $\lambda*(\mu*x)=
##  (\lambda*\mu)*x$ for scalars $\lambda,\mu$ and $x\in M$.
##
DeclareSynonym( "IsLeftModule",
        IsLeftOperatorAdditiveGroup
    and IsLeftActedOnByRing
    and IsDistributiveLOpESum
    and IsAssociativeLOpEProd
    and IsTrivialLOpEOne );


#############################################################################
##
#C  IsRightOperatorAdditiveGroup( <D> )
##
##  A domain <D> lies in `IsRightOperatorAdditiveGroup' if it is an additive
##  group that is closed under scalar multplication from the
##  right, and such that $(x+y)*\lambda=x*\lambda+y*\lambda$ for all
##  scalars $\lambda$ and elements $x,y\in D$.
##
DeclareSynonym( "IsRightOperatorAdditiveGroup",
        IsAdditiveGroup
    and IsExtRSet
    and IsDistributiveROpDSum );


#############################################################################
##
#C  IsRightModule( <M> )
##
##  A domain <M> lies in `IsRightModule' if it lies in
##  `IsRightOperatorAdditiveGroup', {\it and} the set of scalars forms a ring,
##  {\it and} $x*(\lambda+\mu) = x*\lambda+x*\mu$ for scalars $\lambda,\mu$
##  and $x\in M$, {\it and} scalar multiplication satisfies $(x*\mu)*\lambda=
##  x*(\mu*\lambda)$ for scalars $\lambda,\mu$ and $x\in M$.
##
DeclareSynonym( "IsRightModule",
        IsRightOperatorAdditiveGroup
    and IsRightActedOnByRing
    and IsDistributiveROpESum
    and IsAssociativeROpEProd
    and IsTrivialROpEOne );


#############################################################################
##
#C  IsFreeLeftModule( <M> )
##
##  A left module is free as module if it is isomorphic to a direct sum of
##  copies of its left acting domain.
##
##  Free left modules can have bases.
##
##  The characteristic (see~"Characteristic") of a free left module
##  is defined as the characteristic of its left acting domain
##  (see~"LeftActingDomain").
##
DeclareCategory( "IsFreeLeftModule", IsLeftModule );


#############################################################################
##
#P  IsFiniteDimensional( <M> )
##
##  is `true' if <M> is a free left module that is finite dimensional
##  over its left acting domain, and `false' otherwise.
##
DeclareProperty( "IsFiniteDimensional", IsFreeLeftModule );

InstallSubsetMaintenance( IsFiniteDimensional,
    IsFreeLeftModule and IsFiniteDimensional, IsFreeLeftModule );

InstallFactorMaintenance( IsFiniteDimensional,
    IsFreeLeftModule and IsFiniteDimensional,
    IsObject, IsFreeLeftModule );

InstallTrueMethod( IsFiniteDimensional, IsFreeLeftModule and IsFinite );


#############################################################################
##
#P  IsFullRowModule( <M> )
##
##  A *full row module* is a module $R^n$,
##  for a ring $R$ and a nonnegative integer $n$.
##
##  More precisely, a full row module is a free left module over a ring $R$
##  such that the elements are row vectors with entries in $R$ and such that
##  the dimension is equal to the length of the row vectors.
##
##  Several functions delegate their tasks to full row modules,
##  for example `Iterator' and `Enumerator'.
##
DeclareProperty( "IsFullRowModule", IsFreeLeftModule, 20 );


#############################################################################
##
#P  IsFullMatrixModule( <M> )
##
##  A *full matrix module* is a module $R^{[m,n]}$,
##  for a ring $R$ and two nonnegative integers $m$, $n$.
##
##  More precisely, a full matrix module is a free left module over a ring
##  $R$ such that the elements are matrices with entries in $R$
##  and such that the dimension is equal to the number of entries in each
##  matrix.
##
DeclareProperty( "IsFullMatrixModule", IsFreeLeftModule, 20 );


#############################################################################
##
#C  IsHandledByNiceBasis( <M> )
##
##  For a free left module <M> in this category, essentially all operations
##  are performed using a ``nicer'' free left module,
##  which is usually a row module.
##
DeclareCategory( "IsHandledByNiceBasis",
    IsFreeLeftModule and IsAttributeStoringRep );
#T individually choose for each repres. in this category?
#T why not `DeclareFilter' ?


#############################################################################
##
#A  Dimension( <M> )
##
##  A free left module has dimension $n$ if it is isomorphic to a direct sum
##  of $n$ copies of its left acting domain.
##
##  (We do *not* mark `Dimension' as invariant under isomorphisms
##  since we want to call `UseIsomorphismRelation' also for free left modules
##  over different left acting domains.)
##
DeclareAttribute( "Dimension", IsFreeLeftModule );


############################################################################
##
#A  GeneratorsOfLeftOperatorAdditiveGroup( <D> )
##
##  returns a list of elements of <D> that generates <D> as a left operator
##  additive group.
##
DeclareAttribute( "GeneratorsOfLeftOperatorAdditiveGroup",
    IsLeftOperatorAdditiveGroup );


############################################################################
##
#A  GeneratorsOfLeftModule( <M> )
##
##  returns a list of elements of <M> that generate <M> as a left module.
##
DeclareSynonymAttr( "GeneratorsOfLeftModule",
    GeneratorsOfLeftOperatorAdditiveGroup );


#############################################################################
##
#A  GeneratorsOfRightOperatorAdditiveGroup( <D> )
##
##  returns a list of elements of <D> that generates <D> as a right operator
##  additive group.
##
DeclareAttribute( "GeneratorsOfRightOperatorAdditiveGroup",
    IsRightOperatorAdditiveGroup );


#############################################################################
##
#A  GeneratorsOfRightModule( <M> )
##
##  returns a list of elements of <M> that generate <M> as a left module.
##
DeclareSynonymAttr( "GeneratorsOfRightModule",
    GeneratorsOfRightOperatorAdditiveGroup );


#############################################################################
##
#A  TrivialSubmodule( <M> )
##
##  returns the zero submodule of <M>.
##
DeclareSynonymAttr( "TrivialSubmodule", TrivialSubadditiveMagmaWithZero );


#############################################################################
##
#O  AsLeftModule( <R>, <D> )
##
##  if the domain <D> forms an additive group and is closed under left
##  multiplication by the elements of <R>, then `AsLeftModule( <R>, <D> )'
##  returns the domain <D> viewed as a left module.
##
DeclareOperation( "AsLeftModule", [ IsRing, IsCollection ] );


#############################################################################
##
#O  AsFreeLeftModule( <F>, <D> )  . . . . .  view <D> as free left <F>-module
##
##  if the domain <D> is a free left module over <F>, then
##  `AsFreeLeftModule( <F>, <D> )' returns the domain <D> viewed as free
##   left module over <F>.
##
DeclareOperation( "AsFreeLeftModule", [ IsRing, IsCollection ] );


#############################################################################
##
#O  ClosureLeftModule( <M>, <m> )
##
##  is the left module generated by the left module generators of <M> and the
##  element <m>.
##
DeclareOperation( "ClosureLeftModule", [ IsLeftModule, IsVector ] );


#############################################################################
##
#O  LeftModuleByGenerators( <R>, <gens> ) .  left <R>-module gener. by <gens>
#O  LeftModuleByGenerators( <R>, <gens>, <zero> )
##
##  returns the left module over <R> generated by <gens>.
##
DeclareOperation( "LeftModuleByGenerators", [ IsRing, IsCollection ] );
DeclareOperation( "LeftModuleByGenerators",
    [ IsRing, IsListOrCollection, IsObject ] );


#############################################################################
##
#O  UseBasis( <V>, <gens> )
##
##  The vectors in the list <gens> are known to form a basis of the
##  free left module <V>.
##  `UseBasis' stores information in <V> that can be derived form this fact,
##  namely
##  \beginlist%unordered
##  \item{--}
##    <gens> are stored as left module generators if no such generators were
##    bound (this is useful especially if <V> is an algebra),
##  \item{--}
##    the dimension of <V> is stored.
##  \endlist
##
DeclareOperation( "UseBasis", [ IsFreeLeftModule, IsHomogeneousList ] );


#############################################################################
##
#F  FreeLeftModule( <R>, <gens> )
#F  FreeLeftModule( <R>, <gens>, <zero> )
#F  FreeLeftModule( <R>, <gens>, "basis" )
#F  FreeLeftModule( <R>, <gens>, <zero>, "basis" )
##
##  `FreeLeftModule( <R>, <gens> )' is the free left module over the ring
##  <R>, generated by the vectors in the collection <gens>.
##
##  If there are three arguments, a ring <R> and a collection <gens>
##  and an element <zero>,
##  then `FreeLeftModule( <R>, <gens>, <zero> )' is the <R>-free left module
##  generated by <gens>, with zero element <zero>.
##
##  If the last argument is the string `"basis"' then the vectors in
##  <gens> are known to form a basis of the free module.
##
##  It should be noted that the generators <gens> must be vectors,
##  that is, they must support an addition and a scalar action of <R>
##  via left multiplication.
##  (See also Section~"Constructing Domains" for the general meaning of
##  ``generators'' in {\GAP}.)
##  In particular, `FreeLeftModule' is *not* an equivalent of commands
##  such as `FreeGroup' (see~"FreeGroup") in the sense of a constructor of
##  a free group on abstract generators;
##  Such a construction seems to be unnecessary for vector spaces,
##  for that one can use for example row spaces (see~"FullRowSpace")
##  in the finite dimensional case
##  and polynomial rings (see~"PolynomialRing") in the infinite dimensional
##  case.
##  Moreover, the definition of a ``natural'' addition for elements of a
##  given magma (for example a permutation group) is possible via the
##  construction of magma rings (see Chapter "ref:Magma Rings").
##
DeclareGlobalFunction( "FreeLeftModule" );


#############################################################################
##
#F  FullRowModule( <R>, <n> )
##
##  is the row module `<R>^<n>',
##  for a ring <R> and a nonnegative integer <n>.
##
DeclareGlobalFunction( "FullRowModule" );


#############################################################################
##
#F  FullMatrixModule( <R>, <m>, <n> )
##
##  is the row module `<R>^[<m>,<n>]',
##  for a ring <R> and nonnegative integers <m> and <n>.
##
DeclareGlobalFunction( "FullMatrixModule" );


#############################################################################
##
#F  StandardGeneratorsOfFullMatrixModule( <M> )
##
DeclareGlobalFunction( "StandardGeneratorsOfFullMatrixModule" );


#############################################################################
##
#F  Submodule( <M>, <gens> )  . . . . .  submodule of <M> generated by <gens>
#F  Submodule( <M>, <gens>, "basis" )
##
##  is the left module generated by the collection <gens>,
##  with parent module <M>.
##  The second form generates the submodule of <M> for that the list <gens>
##  is known to be a list of basis vectors;
##  in this case, it is *not* checked whether <gens> really are linearly
##  independent and whether all in <gens> lie in <M>.
##
DeclareGlobalFunction( "Submodule" );


#############################################################################
##
#F  SubmoduleNC( <M>, <gens> )
#F  SubmoduleNC( <M>, <gens>, "basis" )
##
##  `SubmoduleNC' does the same as `Submodule', except that it does not check
##  whether all in <gens> lie in <M>.
##
DeclareGlobalFunction( "SubmoduleNC" );


#############################################################################
##
#P  IsRowModule( <V> )
##
##  A *row module* is a free left module whose elements are row vectors.
##
DeclareProperty( "IsRowModule", IsFreeLeftModule );

InstallTrueMethod( IsRowModule, IsFullRowModule );


#############################################################################
##
#P  IsMatrixModule( <V> )
##
##  A *matrix module* is a free left module whose elements are matrices.
##
DeclareProperty( "IsMatrixModule", IsFreeLeftModule );

InstallTrueMethod( IsMatrixModule, IsFullMatrixModule );


#############################################################################
##
#A  DimensionOfVectors( <M> ) . . . . . . . . . .  for row and matrix modules
##
##  For a left module <M> that consists of row vectors (see~"IsRowModule"),
##  `DimensionOfVectors' returns the common length of all row vectors in <M>.
##  For a left module <M> that consists of matrices (see~"IsMatrixModule"),
##  `DimensionOfVectors' returns the common matrix dimensions
##  (see~"DimensionsMat") of all matrices in <M>.
##
DeclareAttribute( "DimensionOfVectors", IsFreeLeftModule );


#############################################################################
##
#M  IsFiniteDimensional( <M> )  . . . . . .  row modules are always fin. dim.
#M  IsFiniteDimensional( <M> )  . . . . . matrix modules are always fin. dim.
##
##  Any free left module in the filter `IsRowModule' or `IsMatrixModule'
##  is finite dimensional.
##
InstallTrueMethod( IsFiniteDimensional, IsRowModule and IsFreeLeftModule );
InstallTrueMethod( IsFiniteDimensional,
    IsMatrixModule and IsFreeLeftModule );


#############################################################################
##
#E

