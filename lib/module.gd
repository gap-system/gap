#############################################################################
##
#W  module.gd                   GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
IsLeftOperatorAdditiveGroup :=     IsAdditiveGroup
                               and IsExtLSet
                               and IsDistributiveLOpDSum;


#############################################################################
##
#C  IsLeftModule( <M> )
##
IsLeftModule :=     IsLeftOperatorAdditiveGroup
                and IsLeftActedOnByRing
                and IsDistributiveLOpESum
                and IsAssociativeLOpEProd
                and IsTrivialLOpEOne;


#############################################################################
##
#C  IsRightOperatorAdditiveGroup( <D> )
##
IsRightOperatorAdditiveGroup :=     IsAdditiveGroup
                                and IsExtRSet
                                and IsDistributiveROpDSum;


#############################################################################
##
#C  IsRightModule( <M> )
##
IsRightModule :=     IsRightOperatorAdditiveGroup
                 and IsRightActedOnByRing
                 and IsDistributiveROpESum
                 and IsAssociativeROpEProd
                 and IsTrivialROpEOne;


#############################################################################
##
#C  IsFreeLeftModule( <M> )
##
##  A left module is free as module if it is isomorphic to a direct sum of
##  copies of its left acting domain.
##
##  Free left modules can have bases.
##
IsFreeLeftModule := NewCategory( "IsFreeLeftModule", IsLeftModule );


#############################################################################
##
#P  IsFiniteDimensional( <M> )
##
##  is 'true' if <M> is a free left module that is finite dimensional
##  over its left acting domain, and 'false' otherwise.
##
IsFiniteDimensional := NewProperty( "IsFiniteDimensional",
    IsFreeLeftModule );
SetIsFiniteDimensional := Setter( IsFiniteDimensional );
HasIsFiniteDimensional := Tester( IsFiniteDimensional );

InstallSubsetMaintainedMethod( IsFiniteDimensional,
    IsFreeLeftModule and IsFiniteDimensional, IsFreeLeftModule );

InstallFactorMaintainedMethod( IsFiniteDimensional,
    IsFreeLeftModule and IsFiniteDimensional,
    IsFreeLeftModule, IsFreeLeftModule );

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
##  for example 'Iterator' and 'Enumerator'.
##
IsFullRowModule := NewProperty( "IsFullRowModule", IsFreeLeftModule );
SetIsFullRowModule := Setter( IsFullRowModule );
HasIsFullRowModule := Tester( IsFullRowModule );


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
IsFullMatrixModule := NewProperty( "IsFullMatrixModule", IsFreeLeftModule );
SetIsFullMatrixModule := Setter( IsFullMatrixModule );
HasIsFullMatrixModule := Tester( IsFullMatrixModule );


#############################################################################
##
#C  IsHandledByNiceBasis( <M> )
##
##  A free left module that supports the mechanism of associated bases
##  must know this.
##
IsHandledByNiceBasis := NewCategory( "IsHandledByNiceBasis",
    IsFreeLeftModule and IsAttributeStoringRep );
#T individually choose for each repres. in this category?


#############################################################################
##
#A  Dimension( <M> )
##
##  A free left module has dimension $n$ if it is isomorphic to a direct sum
##  of $n$ copies of its left acting domain.
##
Dimension := NewAttribute( "Dimension", IsFreeLeftModule );
SetDimension := Setter( Dimension );
HasDimension := Tester( Dimension );


############################################################################
##
#A  GeneratorsOfLeftOperatorAdditiveGroup( <D> )
##
GeneratorsOfLeftOperatorAdditiveGroup := NewAttribute(
    "GeneratorsOfLeftOperatorAdditiveGroup", IsLeftOperatorAdditiveGroup );
SetGeneratorsOfLeftOperatorAdditiveGroup := Setter(
    GeneratorsOfLeftOperatorAdditiveGroup );
HasGeneratorsOfLeftOperatorAdditiveGroup := Tester(
    GeneratorsOfLeftOperatorAdditiveGroup );


############################################################################
##
#A  GeneratorsOfLeftModule( <M> )
##
GeneratorsOfLeftModule := GeneratorsOfLeftOperatorAdditiveGroup;
SetGeneratorsOfLeftModule := SetGeneratorsOfLeftOperatorAdditiveGroup;
HasGeneratorsOfLeftModule := HasGeneratorsOfLeftOperatorAdditiveGroup;


#############################################################################
##
#A  GeneratorsOfRightOperatorAdditiveGroup( <D> )
##
GeneratorsOfRightOperatorAdditiveGroup := NewAttribute(
    "GeneratorsOfRightOperatorAdditiveGroup", IsRightOperatorAdditiveGroup );
SetGeneratorsOfRightOperatorAdditiveGroup := Setter(
    GeneratorsOfRightOperatorAdditiveGroup );
HasGeneratorsOfRightOperatorAdditiveGroup := Tester(
    GeneratorsOfRightOperatorAdditiveGroup );


#############################################################################
##
#A  GeneratorsOfRightModule( <M> )
##
GeneratorsOfRightModule := GeneratorsOfRightOperatorAdditiveGroup;
SetGeneratorsOfRightModule := SetGeneratorsOfRightOperatorAdditiveGroup;
HasGeneratorsOfRightModule := HasGeneratorsOfRightOperatorAdditiveGroup;


#############################################################################
##
#A  TrivialSubmodule( <M> )
##
TrivialSubmodule := TrivialSubadditiveMagmaWithZero;
SetTrivialSubmodule := SetTrivialSubadditiveMagmaWithZero;
HasTrivialSubmodule := HasTrivialSubadditiveMagmaWithZero;

#T Submodule := NewOperation( "Submodule", [ IsLeftModule or IsRightModule ] );
#T belongs to left or right or bimodules ?


#############################################################################
##
#O  AsLeftModule( <R>, <D> )
##
AsLeftModule := NewOperation( "AsModule", [ IsRing, IsDomain ] );


#############################################################################
##
#O  AsFreeLeftModule( <F>, <D> )  . . . . .  view <D> as free left <F>-module
##
AsFreeLeftModule := NewOperation( "AsFreeLeftModule",
    [ IsRing, IsCollection ] );


#############################################################################
##
#O  ClosureLeftModule( <M>, <m> )
##
##  is the left module generated by the left module generators of <M> and the
##  element <m>.
##
ClosureLeftModule := NewOperation( "ClosureLeftModule",
    [ IsLeftModule, IsVector ] );


#############################################################################
##
#O  LeftModuleByGenerators( <R>, <gens> ) .  left <R>-module gener. by <gens>
#O  LeftModuleByGenerators( <R>, <gens>, <zero> )
##
LeftModuleByGenerators := NewOperation( "LeftModuleByGenerators",
    [ IsRing, IsCollection ] );
#T 1997/01/16 fceller was old 'NewConstructor'


#############################################################################
##
#O  UseBasis( <V>, <gens> )
##
##  The vectors in the list <gens> are known to form a basis of the
##  free left module <V>.
##  'UseBasis' stores information in <V> that can be derived form this fact.
##
UseBasis := NewOperation( "UseBasis",
    [ IsFreeLeftModule, IsHomogeneousList ] );


#############################################################################
##
#F  FreeLeftModule( <R>, <gens> )
#F  FreeLeftModule( <R>, <gens>, <zero> )
#F  FreeLeftModule( <R>, <gens>, "basis" )
#F  FreeLeftModule( <R>, <gens>, <zero>, "basis" )
##
##  'FreeLeftModule( <R>, <gens> )' is the free left module over the ring
##  <R>, generated by the vectors in the collection <gens>.
##
##  If there are three arguments, a ring <R> and a collection <gens>
##  and an element <zero>,
##  then 'FreeLeftModule( <R>, <gens>, <zero> )' is the <R>-free left module
##  generated by <gens>, with zero element <zero>.
##
##  If the last argument is the string '\"basis\"' then the vectors in
##  <gens> are known to form a basis of the free module.
##
FreeLeftModule := NewOperationArgs( "FreeLeftModule" );


#############################################################################
##
#F  FullRowModule( <R>, <n> )
##
##  is the row module $<R>^<n>$, for a ring <R> and a nonnegative integer
##  <n>.
##
FullRowModule := NewOperationArgs( "FullRowModule" );


#############################################################################
##
#F  FullMatrixModule( <R>, <m>, <n> )
##
##  is the row module $<R>^[<m>,<n>]$, for a ring <R> and nonnegative
##  integers <m> and <n>.
##
FullMatrixModule := NewOperationArgs( "FullMatrixModule" );


#############################################################################
##
#F  Submodule( <M>, <gens> )  . . . . .  submodule of <M> generated by <gens>
##
##  is the left module generated by <gens>, with parent module <M>.
##
#F  Submodule( <M>, <gens>, "basis" )
##
##  is the submodule of <M> for that <gens> is a list of basis vectors.
##  It is *not* checked whether <gens> really are linearly independent
##  and whether all in <gens> lie in <V>.
##
Submodule := NewOperationArgs( "Submodule" );


#############################################################################
##
#F  SubmoduleNC( <V>, <gens> )
#F  SubmoduleNC( <V>, <gens>, "basis" )
##
##  'SubmoduleNC' does the same as 'Submodule', except that it does not check
##  whether all in <gens> lie in <V>.
##
SubmoduleNC := NewOperationArgs( "SubmoduleNC" );


#############################################################################
##
#E  module.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



