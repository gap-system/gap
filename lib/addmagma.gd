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
#T ?


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
#E  addmagma.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



