#############################################################################
##
#W  module.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
DeclareSynonym( "IsLeftOperatorAdditiveGroup",
        IsAdditiveGroup
    and IsExtLSet
    and IsDistributiveLOpDSum );


#############################################################################
##
#C  IsLeftModule( <M> )
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
DeclareSynonym( "IsRightOperatorAdditiveGroup",
        IsAdditiveGroup
    and IsExtRSet
    and IsDistributiveROpDSum );


#############################################################################
##
#C  IsRightModule( <M> )
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
DeclareCategory( "IsFreeLeftModule", IsLeftModule );


#############################################################################
##
#P  IsFiniteDimensional( <M> )
##
##  is `true' if <M> is a free left module that is finite dimensional
##  over its left acting domain, and `false' otherwise.
##
DeclareProperty( "IsFiniteDimensional", IsFreeLeftModule );

InstallSubsetMaintainedMethod( IsFiniteDimensional,
    IsFreeLeftModule and IsFiniteDimensional, IsFreeLeftModule );

InstallFactorMaintainedMethod( IsFiniteDimensional,
    IsFreeLeftModule and IsFiniteDimensional,
    IsCollection, IsFreeLeftModule );

InstallTrueMethod( IsFiniteDimensional, IsFreeLeftModule and IsFinite );


#############################################################################
##
#P  IsFullRowModule( M )
##
##  A *full row module* is a module $R^n$, for a ring $R$.
##
##  More precisely, a full row module is a free left module over a ring $R$
##  such that the elements are row vectors with entries in $R$ and such that
##  the dimension is equal to the length of the row vectors.
##
##  Several functions delegate their tasks to full row modules,
##  for example `Iterator' and `Enumerator'.
##
DeclareProperty( "IsFullRowModule", IsFreeLeftModule );


#############################################################################
##
#P  IsFullMatrixModule( M )
##
##  A *full matrix module* is a module $R^[m,n]$, for a ring $R$.
##
##  More precisely, a full matrix module is a free left module over a ring
##  $R$ such that the elements are matrices with entries in $R$
##  and such that the dimension is equal to the number of entries in each
##  matrix.
##
DeclareProperty( "IsFullMatrixModule", IsFreeLeftModule );


#############################################################################
##
#C  IsHandledByNiceBasis( <M> )
##
##  For a free left module in this category, essentially all operations are
##  performed using a left row module, corresponding to a `NiceBasis' (see
##  "NiceBasis") of <M>.
##  A free left module that supports the mechanism of associated bases
##  must know this.
##
DeclareCategory( "IsHandledByNiceBasis",
    IsFreeLeftModule and IsAttributeStoringRep );
#T individually choose for each repres. in this category?


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
DeclareAttribute( "GeneratorsOfLeftOperatorAdditiveGroup",
    IsLeftOperatorAdditiveGroup );


############################################################################
##
#A  GeneratorsOfLeftModule( <M> )
##
DeclareSynonymAttr( "GeneratorsOfLeftModule",
    GeneratorsOfLeftOperatorAdditiveGroup );


#############################################################################
##
#A  GeneratorsOfRightOperatorAdditiveGroup( <D> )
##
DeclareAttribute( "GeneratorsOfRightOperatorAdditiveGroup",
    IsRightOperatorAdditiveGroup );


#############################################################################
##
#A  GeneratorsOfRightModule( <M> )
##
DeclareSynonymAttr( "GeneratorsOfRightModule",
    GeneratorsOfRightOperatorAdditiveGroup );


#############################################################################
##
#A  TrivialSubmodule( <M> )
##
DeclareSynonymAttr( "TrivialSubmodule", TrivialSubadditiveMagmaWithZero );


#############################################################################
##
#O  AsLeftModule( <R>, <D> )
##
DeclareOperation( "AsLeftModule", [ IsRing, IsCollection ] );


#############################################################################
##
#O  AsFreeLeftModule( <F>, <D> )  . . . . .  view <D> as free left <F>-module
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
DeclareOperation( "LeftModuleByGenerators", [ IsRing, IsCollection ] );


#############################################################################
##
#O  UseBasis( <V>, <gens> )
##
##  The vectors in the list <gens> are known to form a basis of the
##  free left module <V>.
##  `UseBasis' stores information in <V> that can be derived form this fact.
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
DeclareGlobalFunction( "FreeLeftModule" );


#############################################################################
##
#F  FullRowModule( <R>, <n> )
##
##  is the row module $<R>^<n>$, for a ring <R> and a nonnegative integer
##  <n>.
##
DeclareGlobalFunction( "FullRowModule" );


#############################################################################
##
#F  FullMatrixModule( <R>, <m>, <n> )
##
##  is the row module $<R>^[<m>,<n>]$, for a ring <R> and nonnegative
##  integers <m> and <n>.
##
DeclareGlobalFunction( "FullMatrixModule" );
DeclareSynonym( "FullMatrixSpace", FullMatrixModule );
DeclareSynonym( "MatrixSpace", FullMatrixModule );
DeclareSynonym( "MatSpace", FullMatrixModule );


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
##  is the left module generated by <gens>, with parent module <M>.
##  The second form generates
##  the submodule of <M> for that <gens> is a list of basis vectors.
##  It is *not* checked whether <gens> really are linearly independent
##  and whether all in <gens> lie in <V>.
##
DeclareGlobalFunction( "Submodule" );


#############################################################################
##
#F  SubmoduleNC( <V>, <gens> )
#F  SubmoduleNC( <V>, <gens>, "basis" )
##
##  `SubmoduleNC' does the same as `Submodule', except that it does not check
##  whether all in <gens> lie in <V>.
##
DeclareGlobalFunction( "SubmoduleNC" );


#############################################################################
##
#R  IsRowModuleRep( <M> )
##
##  A *row module* is a free left module whose elements are lists of scalars.
##
DeclareRepresentation( "IsRowModuleRep", IsComponentObjectRep,
    [ "vectordim" ] );


#############################################################################
##
#M  IsFiniteDimensional( <M> )  . . . . . .  row modules are always fin. dim.
##
InstallTrueMethod( IsFiniteDimensional,
    IsRowModuleRep and IsFreeLeftModule );


#############################################################################
##
#R  IsMatrixModuleRep( <V> )
##
##  A *matrix module* is a free left module whose elements are matrices.
##
DeclareRepresentation( "IsMatrixModuleRep", IsComponentObjectRep,
    [ "vectordim" ] );


#############################################################################
##
#M  IsFiniteDimensional( <M> )  . . . . . matrix modules are always fin. dim.
##
InstallTrueMethod( IsFiniteDimensional,
    IsMatrixModuleRep and IsFreeLeftModule );


#############################################################################
##
#E  module.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

