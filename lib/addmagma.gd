#############################################################################
##
#W  addmagma.gd                 GAP library                     Thomas Breuer
##
#W  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file declares the operations for additive magmas,
##  Note that the meaning of generators for the three categories
##  additive magma, additive-magma-with-zero,
##  and additive-magma-with-inverses is different.
##
Revision.addmagma_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsAdditiveMagma( <M> )
##
##  An additive magma in {\GAP} is a domain $S$ with an associative and
##  commutative addition $'+' \: S \times S \rightarrow S$.
##
IsAdditiveMagma := NewCategory( "IsAdditiveMagma", IsDomain );


#############################################################################
##
#C  IsAdditiveMagmaWithZero( <A> )
##
##  An additive-magma-with-zero in {\GAP} is an additive magma $S$ with
##  an operation '0*' that yields the zero of the magma.
##
IsAdditiveMagmaWithZero := NewCategory( "IsAdditiveMagmaWithZero",
    IsAdditiveMagma );


#############################################################################
##
#C  IsAdditiveMagmaWithInverses( <A> )
##
##  An additive-magma-with-inverses in {\GAP} is an additive-magma-with-zero
##  $S$ with an operation
##  $'-1*' \: S \rightarrow S$ that maps each element of the magma to its
##  additive inverse.
##
IsAdditiveMagmaWithInverses := NewCategory( "IsAdditiveMagmaWithInverses",
    IsAdditiveMagmaWithZero );

IsAdditiveGroup := IsAdditiveMagmaWithInverses;


#############################################################################
##
#F  AdditiveMagma(<generators>)
#F  AdditiveMagma(<Fam>,<generators>)
##
AdditiveMagma := NewOperationArgs( "AdditiveMagma" );


#############################################################################
##
#F  SubadditiveMagma( <M>, <generators> )
##
SubadditiveMagma := NewOperationArgs( "SubadditiveMagma" );


#############################################################################
##
#F  SubadditiveMagmaNC( <M>, <generators> )
##
SubadditiveMagmaNC := NewOperationArgs( "SubadditiveMagmaNC" );


#############################################################################
##
#F  AdditiveMagmaWithZero(<generators>)
#F  AdditiveMagmaWithZero(<Fam>,<generators>)
##
AdditiveMagmaWithZero := NewOperationArgs( "AdditiveMagmaWithZero" );


#############################################################################
##
#F  SubadditiveMagmaWithZero( <M>, <generators> )
##
SubadditiveMagmaWithZero := NewOperationArgs( "SubadditiveMagmaWithZero" );


#############################################################################
##
#F  SubadditiveMagmaWithZeroNC( <M>, <generators> )
##
SubadditiveMagmaWithZeroNC := NewOperationArgs(
    "SubadditiveMagmaWithZeroNC" );


#############################################################################
##
#F  AdditiveMagmaWithInverses(<generators>)
#F  AdditiveMagmaWithInverses(<Fam>,<generators>)
##
AdditiveMagmaWithInverses := NewOperationArgs( "AdditiveMagmaWithInverses" );


#############################################################################
##
#F  SubadditiveMagmaWithInverses( <M>, <generators> )
##
SubadditiveMagmaWithInverses := NewOperationArgs(
    "SubadditiveMagmaWithInverses" );


#############################################################################
##
#F  SubadditiveMagmaWithInversesNC( <M>, <generators> )
##
SubadditiveMagmaWithInversesNC := NewOperationArgs(
    "SubadditiveMagmaWithInversesNC" );


#############################################################################
##
#O  AdditiveMagmaByGenerators(<generators>)
#O  AdditiveMagmaByGenerators(<Fam>,<generators>)
##
AdditiveMagmaByGenerators := NewOperation( "AdditiveMagmaByGenerators",
    [ IsCollection ] );


#############################################################################
##
#O  AdditiveMagmaWithZeroByGenerators(<generators>)
#O  AdditiveMagmaWithZeroByGenerators(<Fam>,<generators>)
##
AdditiveMagmaWithZeroByGenerators := NewOperation(
    "AdditiveMagmaWithZeroByGenerators",
    [ IsCollection ] );


#############################################################################
##
#O  AdditiveMagmaWithInversesByGenerators(<generators>)
#O  AdditiveMagmaWithInversesByGenerators(<Fam>,<generators>)
##
AdditiveMagmaWithInversesByGenerators := NewOperation(
    "AdditiveMagmaWithInversesByGenerators",
    [ IsCollection ] );


#############################################################################
##
#O  AdditiveGroupByGenerators(<generators>)
#O  AdditiveGroupByGenerators(<Fam>,<generators>)
##
AdditiveGroupByGenerators := AdditiveMagmaWithInversesByGenerators;


#############################################################################
##
#A  GeneratorsOfAdditiveMagma( <A> )
##
GeneratorsOfAdditiveMagma := NewAttribute( "GeneratorsOfAdditiveMagma",
    IsAdditiveMagma );
SetGeneratorsOfAdditiveMagma := Setter( GeneratorsOfAdditiveMagma );
HasGeneratorsOfAdditiveMagma := Tester( GeneratorsOfAdditiveMagma );


#############################################################################
##
#A  GeneratorsOfAdditiveMagmaWithZero( <A> )
##
GeneratorsOfAdditiveMagmaWithZero := NewAttribute(
    "GeneratorsOfAdditiveMagmaWithZero", IsAdditiveMagmaWithZero );
SetGeneratorsOfAdditiveMagmaWithZero :=
    Setter( GeneratorsOfAdditiveMagmaWithZero );
HasGeneratorsOfAdditiveMagmaWithZero :=
    Tester( GeneratorsOfAdditiveMagmaWithZero );


#############################################################################
##
#A  GeneratorsOfAdditiveMagmaWithInverses( <A> )
##
GeneratorsOfAdditiveMagmaWithInverses := NewAttribute(
    "GeneratorsOfAdditiveMagmaWithInverses", IsAdditiveMagmaWithInverses );
SetGeneratorsOfAdditiveMagmaWithInverses :=
    Setter( GeneratorsOfAdditiveMagmaWithInverses );
HasGeneratorsOfAdditiveMagmaWithInverses :=
    Tester( GeneratorsOfAdditiveMagmaWithInverses );


#############################################################################
##
#A  GeneratorsOfAdditiveGroup( <A> )
##
GeneratorsOfAdditiveGroup := GeneratorsOfAdditiveMagmaWithInverses;
SetGeneratorsOfAdditiveGroup := SetGeneratorsOfAdditiveMagmaWithInverses;
HasGeneratorsOfAdditiveGroup := HasGeneratorsOfAdditiveMagmaWithInverses;


#############################################################################
##
#A  TrivialSubadditiveMagmaWithZero( <M> )  . . . for an add.-magma-with-zero
##
TrivialSubadditiveMagmaWithZero := NewAttribute(
    "TrivialSubadditiveMagmaWithZero",
    IsAdditiveMagmaWithZero );
SetTrivialSubadditiveMagmaWithZero := Setter(
    TrivialSubadditiveMagmaWithZero );
HasTrivialSubadditiveMagmaWithZero := Tester(
    TrivialSubadditiveMagmaWithZero );


#############################################################################
##
#A  AdditiveNeutralElement( <A> )
##
##  is an element of the additive magma <A> that behaves as a zero (but need
##  not be obtained by 'Zero( <A> )') if exists, and 'fail' otherwise.
##
AdditiveNeutralElement := NewAttribute( "AdditiveNeutralElement",
    IsAdditiveMagma );
SetAdditiveNeutralElement := Setter( AdditiveNeutralElement );
HasAdditiveNeutralElement := Tester( AdditiveNeutralElement );


#############################################################################
##
#O  ClosureAdditiveGroup( <A>, <a> )  . . . . . .  for add. group and element
#O  ClosureAdditiveGroup( <A>, <B> )  . . . . . . . . . . for two add. groups
##
ClosureAdditiveGroup := NewOperation( "ClosureAdditiveGroup",
    [ IsAdditiveGroup, IsAdditiveElement ] );


#############################################################################
##
#E  addmagma.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



