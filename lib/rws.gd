#############################################################################
##
#W  rws.gd                      GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file  contains    the   operations for   rewriting   systems.    Any
##  implementation of a rewriting system must at least implement methods for
##
##    constructing such a rewriting system,
##    'CopyRws',
##    'IsConfluent',
##    'ReducedForm', and
##    'Rules'.
##
##  An  implementation might  also  want to  implement 'MakeConfluent' and/or
##  'ConfluentRws'.
##
##  The generic methods, which are defined in "rwsgen.g", for
##
##    'ReducedAdditiveInverse',
##    'ReducedComm',
##    'ReducedConjugate',
##    'ReducedDifference'
##    'ReducedInverse',
##    'ReducedLeftQuotient',
##    'ReducedOne',
##    'ReducedPower',
##    'ReducedProduct'
##    'ReducedScalarProduct',
##    'ReducedSum', and
##    'ReducedZero',
##
##  use 'ReducedForm'. Depending on the underlying  structure not all of them
##  will  work.  For example, for  a  monoid 'ReducedInverse' will produce an
##  error because  the generic methods  tries to  reduced  the inverse of the
##  given element.
##
##  As in  general  a rewriting system will    be first built   and then used
##  without   changing   it,  some   functions   (e.   g.  'GroupByRws') call
##  'ReduceRules'  to give the rewriting  system a chance to optimise itself.
##  The default method for 'ReduceRules' is "do nothing".
##
##  The underlying  structure is stored  in the  attribute 'UnderlyingFamily'
##  and  the  generators  used for  the  rewriting  system   in the attribute
##  'GeneratorsOfRws'.   The number  of  rws  generators   is stored in   the
##  attribute 'NumberGeneratorsOfRws'.
##
##  The family of a rewriting system also contains the underlying family, the
##  default    method for 'UnderlyingFamily'    uses  the family  to get  the
##  underlying family for a given rewriting system.
##
Revision.rws_gd :=
    "@(#)$Id$";


#############################################################################
##

#C  IsRewritingSystem( <obj> )
##
IsRewritingSystem := NewCategory(
    "IsRewritingSystem",
    IsCopyable );


#############################################################################
##

#P  IsBuiltFromAdditiveMagmaWithInverses( <obj> )
##
IsBuiltFromAdditiveMagmaWithInverses := NewProperty( 
    "IsBuiltFromAdditiveMagmaWithInverses",
    IsObject );


#############################################################################
##
#P  IsBuiltFromMagma( <obj> )
##
IsBuiltFromMagma := NewProperty(
    "IsBuiltFromMagma",
    IsObject );


#############################################################################
##
#P  IsBuiltFromMagmaWithOne( <obj> )
##
IsBuiltFromMagmaWithOne := NewProperty(
    "IsBuiltFromMagmaWithOne",
    IsObject );


#############################################################################
##
#P  IsBuiltFromMagmaWithInverses( <obj> )
##
IsBuiltFromMagmaWithInverses := NewProperty( 
    "IsBuiltFromMagmaWithInverses",
    IsObject );


#############################################################################
##
#P  IsBuiltFromGroup( <obj> )
##
IsBuiltFromGroup := NewProperty(
    "IsBuiltFromGroup",
    IsObject );


#############################################################################
##

#M  IsBuiltFromMagma( <obj> )
##
InstallTrueMethod( IsBuiltFromMagma, IsBuiltFromMagmaWithOne );


#############################################################################
##
#M  IsBuiltFromMagmaWithOne( <obj> )
##
InstallTrueMethod( IsBuiltFromMagmaWithOne, IsBuiltFromMagmaWithInverses );


#############################################################################
##
#M  IsBuiltFromGroup( <obj> )
##
InstallTrueMethod( IsBuiltFromMagmaWithInverses, IsBuiltFromGroup );


#############################################################################
##

#A  ConfluentRws( <rws> )
##
##  NOTE: this is an  attribute  *but* rewriting system   do not  store  this
##  attribute because they are mutable.
##
ConfluentRws := NewAttribute(
    "ConfluentRws",
    IsRewritingSystem );

SetConfluentRws := Setter(ConfluentRws);
HasConfluentRws := Tester(ConfluentRws);


#############################################################################
##
#A  GeneratorsOfRws( <rws> )
##
GeneratorsOfRws := NewAttribute(
    "GeneratorsOfRws",
    IsRewritingSystem );

HasGeneratorsOfRws := Tester( GeneratorsOfRws );
SetGeneratorsOfRws := Setter( GeneratorsOfRws );


#############################################################################
##
#A  NumberGeneratorsOfRws( <rws> )
##
NumberGeneratorsOfRws := NewAttribute(
    "NumberGeneratorsOfRws",
    IsRewritingSystem );

HasNumberGeneratorsOfRws := Tester( NumberGeneratorsOfRws );
SetNumberGeneratorsOfRws := Setter( NumberGeneratorsOfRws );


#############################################################################
##
#A  Rules( <rws> )
##
##  NOTE: this is an   attribute *but* rewriting  system  do not store   this
##  attribute.
##
Rules := NewAttribute(
    "Rules",
    IsRewritingSystem );

SetRules := Setter(Rules);
HasRules := Setter(Rules);


#############################################################################
##
#A  UnderlyingFamily( <rws> )
##
UnderlyingFamily := NewAttribute(
    "UnderlyingFamily",
    IsObject );

HasUnderlyingFamily := Tester(UnderlyingFamily);
SetUnderlyingFamily := Setter(UnderlyingFamily);


#############################################################################
##

#P  IsConfluent( <rws> )
##
##  NOTE:  this  is a  property  *but*  rewriting  system  do not store  this
##  attribute.
##
IsConfluent := NewProperty(
    "IsConfluent",
    IsRewritingSystem );

SetIsConfluent := Setter(IsConfluent);
HasIsConfluent := Tester(IsConfluent);


#############################################################################
##

#O  AddGenerators( <rws>, <gens> )
##
AddGenerators := NewOperation(
    "AddGenerators",
    [ IsRewritingSystem and IsMutable, IsHomogeneousList ] );


#############################################################################
##
#O  MakeConfluent( <rws> )
##
MakeConfluent := NewOperation(
    "MakeConfluent",
    [ IsRewritingSystem and IsMutable ] );


#############################################################################
##
#O  ReduceRules( <rws> )
##
ReduceRules := NewOperation(
    "ReduceRules",
    [ IsRewritingSystem and IsMutable ] );


#############################################################################
##

#O  ReducedAdditiveInverse( <rws>, <obj> )
##
ReducedAdditiveInverse := NewOperation(
    "ReducedAdditiveInverse",
    [ IsRewritingSystem,
      IsAdditiveElement ] );


#############################################################################
##
#O  ReducedComm( <rws>, <left>, <right> )
##
ReducedComm := NewOperation(
    "ReducedComm",
    [ IsRewritingSystem,
      IsMultiplicativeElement,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedConjugate( <rws>, <left>, <right> )
##
ReducedConjugate := NewOperation(
    "ReducedConjugate", 
    [ IsRewritingSystem,
      IsMultiplicativeElement,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedDifference( <rws>, <left>, <right> )
##
ReducedDifference := NewOperation(
    "ReducedDifference", 
    [ IsRewritingSystem,
      IsAdditiveElement,
      IsAdditiveElement ] );


#############################################################################
##
#O  ReducedForm( <rws>, <obj> )
##
ReducedForm := NewOperation(
    "ReducedForm", 
    [ IsRewritingSystem,
      IsObject ] );


#############################################################################
##
#O  ReducedInverse( <rws>, <obj> )
##
ReducedInverse := NewOperation(
    "ReducedInverse", 
    [ IsRewritingSystem,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedLeftQuotient( <rws>, <left>, <right> )
##
ReducedLeftQuotient := NewOperation(
    "ReducedLeftQuotient",
    [ IsRewritingSystem, 
      IsMultiplicativeElement,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedOne( <rws> )
##
ReducedOne := NewOperation(
    "ReducedOne", 
    [ IsRewritingSystem ] );


#############################################################################
##
#O  ReducedPower( <rws>, <obj>, <pow> )
##
ReducedPower := NewOperation(
    "ReducedPower",
    [ IsRewritingSystem, 
      IsMultiplicativeElement,
      IsInt ] );


#############################################################################
##
#O  ReducedProduct( <rws>, <left>, <right> )
##
ReducedProduct := NewOperation(
    "ReducedProduct", 
    [ IsRewritingSystem,
      IsMultiplicativeElement, 
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedQuotient( <rws>, <left>, <right> )
##
ReducedQuotient := NewOperation(
    "ReducedQuotient", 
    [ IsRewritingSystem,
      IsMultiplicativeElement,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedScalarProduct( <rws>, <left>, <right> )
##
ReducedScalarProduct := NewOperation(
    "ReducedScalarProduct", 
    [ IsRewritingSystem,
      IsScalar,
      IsAdditiveElement ] );


#############################################################################
##
#O  ReducedSum( <rws>, <left>, <right> )
##
ReducedSum := NewOperation(
    "ReducedSum",
    [ IsRewritingSystem,
      IsAdditiveElement,
      IsAdditiveElement ] );


#############################################################################
##
#O  ReducedZero( <rws> )
##
ReducedZero := NewOperation(
    "ReducedZero", 
    [ IsRewritingSystem ] );


#############################################################################
##

#V  InfoConfluence
##
InfoConfluence := NewInfoClass("InfoConfluence");


#############################################################################
##

#E  rws.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
