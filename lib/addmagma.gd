#############################################################################
##
#W  addmagma.gd                 GAP library                     Thomas Breuer
##
#W  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
DeclareCategory( "IsAdditiveMagma", IsDomain );


#############################################################################
##
#C  IsAdditiveMagmaWithZero( <A> )
##
##  An additive-magma-with-zero in {\GAP} is an additive magma $S$ with
##  an operation '0*' that yields the zero of the magma.
##
DeclareCategory( "IsAdditiveMagmaWithZero", IsAdditiveMagma );


#############################################################################
##
#C  IsAdditiveMagmaWithInverses( <A> )
##
##  An additive-magma-with-inverses in {\GAP} is an additive-magma-with-zero
##  $S$ with an operation
##  $'-1*' \: S \rightarrow S$ that maps each element of the magma to its
##  additive inverse.
##
DeclareCategory( "IsAdditiveMagmaWithInverses", IsAdditiveMagmaWithZero );

IsAdditiveGroup := IsAdditiveMagmaWithInverses;


#############################################################################
##
#F  AdditiveMagma(<generators>)
#F  AdditiveMagma(<Fam>,<generators>)
##
DeclareGlobalFunction( "AdditiveMagma" );


#############################################################################
##
#F  SubadditiveMagma( <M>, <generators> )
##
DeclareGlobalFunction( "SubadditiveMagma" );


#############################################################################
##
#F  SubadditiveMagmaNC( <M>, <generators> )
##
DeclareGlobalFunction( "SubadditiveMagmaNC" );


#############################################################################
##
#F  AdditiveMagmaWithZero(<generators>)
#F  AdditiveMagmaWithZero(<Fam>,<generators>)
##
DeclareGlobalFunction( "AdditiveMagmaWithZero" );


#############################################################################
##
#F  SubadditiveMagmaWithZero( <M>, <generators> )
##
DeclareGlobalFunction( "SubadditiveMagmaWithZero" );


#############################################################################
##
#F  SubadditiveMagmaWithZeroNC( <M>, <generators> )
##
DeclareGlobalFunction( "SubadditiveMagmaWithZeroNC" );


#############################################################################
##
#F  AdditiveMagmaWithInverses(<generators>)
#F  AdditiveMagmaWithInverses(<Fam>,<generators>)
##
DeclareGlobalFunction( "AdditiveMagmaWithInverses" );


#############################################################################
##
#F  SubadditiveMagmaWithInverses( <M>, <generators> )
##
DeclareGlobalFunction( "SubadditiveMagmaWithInverses" );


#############################################################################
##
#F  SubadditiveMagmaWithInversesNC( <M>, <generators> )
##
DeclareGlobalFunction( "SubadditiveMagmaWithInversesNC" );


#############################################################################
##
#O  AdditiveMagmaByGenerators(<generators>)
#O  AdditiveMagmaByGenerators(<Fam>,<generators>)
##
DeclareOperation( "AdditiveMagmaByGenerators", [ IsCollection ] );


#############################################################################
##
#O  AdditiveMagmaWithZeroByGenerators(<generators>)
#O  AdditiveMagmaWithZeroByGenerators(<Fam>,<generators>)
##
DeclareOperation( "AdditiveMagmaWithZeroByGenerators", [ IsCollection ] );


#############################################################################
##
#O  AdditiveMagmaWithInversesByGenerators(<generators>)
#O  AdditiveMagmaWithInversesByGenerators(<Fam>,<generators>)
##
DeclareOperation( "AdditiveMagmaWithInversesByGenerators",
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
DeclareAttribute( "GeneratorsOfAdditiveMagma", IsAdditiveMagma );


#############################################################################
##
#A  GeneratorsOfAdditiveMagmaWithZero( <A> )
##
DeclareAttribute( "GeneratorsOfAdditiveMagmaWithZero",
    IsAdditiveMagmaWithZero );


#############################################################################
##
#A  GeneratorsOfAdditiveMagmaWithInverses( <A> )
##
DeclareAttribute( "GeneratorsOfAdditiveMagmaWithInverses",
    IsAdditiveMagmaWithInverses );


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
DeclareAttribute( "TrivialSubadditiveMagmaWithZero",
    IsAdditiveMagmaWithZero );


#############################################################################
##
#A  AdditiveNeutralElement( <A> )
##
##  is an element of the additive magma <A> that behaves as a zero (but need
##  not be obtained by 'Zero( <A> )') if exists, and 'fail' otherwise.
##
DeclareAttribute( "AdditiveNeutralElement", IsAdditiveMagma );


#############################################################################
##
#O  ClosureAdditiveGroup( <A>, <a> )  . . . . . .  for add. group and element
#O  ClosureAdditiveGroup( <A>, <B> )  . . . . . . . . . . for two add. groups
##
DeclareOperation( "ClosureAdditiveGroup",
    [ IsAdditiveGroup, IsAdditiveElement ] );


#############################################################################
##
#E  addmagma.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



