#############################################################################
##
#W  rws.gd                      GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
##  The generic methods, which are defined in "rws.gi", for
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
DeclareCategory(
    "IsRewritingSystem",
    IsCopyable );


#############################################################################
##

#P  IsBuiltFromAdditiveMagmaWithInverses( <obj> )
##
DeclareProperty( 
    "IsBuiltFromAdditiveMagmaWithInverses",
    IsObject );


#############################################################################
##
#P  IsBuiltFromMagma( <obj> )
##
DeclareProperty(
    "IsBuiltFromMagma",
    IsObject );


#############################################################################
##
#P  IsBuiltFromMagmaWithOne( <obj> )
##
DeclareProperty(
    "IsBuiltFromMagmaWithOne",
    IsObject );


#############################################################################
##
#P  IsBuiltFromMagmaWithInverses( <obj> )
##
DeclareProperty( 
    "IsBuiltFromMagmaWithInverses",
    IsObject );


#############################################################################
##
#P  IsBuiltFromGroup( <obj> )
##
DeclareProperty(
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
DeclareAttribute(
    "ConfluentRws",
    IsRewritingSystem );



#############################################################################
##
#A  GeneratorsOfRws( <rws> )
##
DeclareAttribute(
    "GeneratorsOfRws",
    IsRewritingSystem );



#############################################################################
##
#A  NumberGeneratorsOfRws( <rws> )
##
DeclareAttribute(
    "NumberGeneratorsOfRws",
    IsRewritingSystem );



#############################################################################
##
#A  Rules( <rws> )
##
##  NOTE: this is an   attribute *but* rewriting  system  do not store   this
##  attribute.
##
DeclareAttribute(
    "Rules",
    IsRewritingSystem );



#############################################################################
##
#A  UnderlyingFamily( <rws> )
##
#T DeclareAttribute(
#T     "UnderlyingFamily",
#T     IsObject );
#T already in `liefam.gd'



#############################################################################
##

#P  IsConfluent( <rws> )
##
##  NOTE:  this  is a  property  *but*  rewriting  system  do not store  this
##  attribute.
##
DeclareProperty(
    "IsConfluent",
    IsRewritingSystem );



#############################################################################
##

#O  AddGenerators( <rws>, <gens> )
##
DeclareOperation(
    "AddGenerators",
    [ IsRewritingSystem and IsMutable, IsHomogeneousList ] );


#############################################################################
##
#O  MakeConfluent( <rws> )
##
DeclareOperation(
    "MakeConfluent",
    [ IsRewritingSystem and IsMutable ] );


#############################################################################
##
#O  ReduceRules( <rws> )
##
DeclareOperation(
    "ReduceRules",
    [ IsRewritingSystem and IsMutable ] );


#############################################################################
##

#O  ReducedAdditiveInverse( <rws>, <obj> )
##
DeclareOperation(
    "ReducedAdditiveInverse",
    [ IsRewritingSystem,
      IsAdditiveElement ] );


#############################################################################
##
#O  ReducedComm( <rws>, <left>, <right> )
##
DeclareOperation(
    "ReducedComm",
    [ IsRewritingSystem,
      IsMultiplicativeElement,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedConjugate( <rws>, <left>, <right> )
##
DeclareOperation(
    "ReducedConjugate", 
    [ IsRewritingSystem,
      IsMultiplicativeElement,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedDifference( <rws>, <left>, <right> )
##
DeclareOperation(
    "ReducedDifference", 
    [ IsRewritingSystem,
      IsAdditiveElement,
      IsAdditiveElement ] );


#############################################################################
##
#O  ReducedForm( <rws>, <obj> )
##
DeclareOperation(
    "ReducedForm", 
    [ IsRewritingSystem,
      IsObject ] );


#############################################################################
##
#O  ReducedInverse( <rws>, <obj> )
##
DeclareOperation(
    "ReducedInverse", 
    [ IsRewritingSystem,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedLeftQuotient( <rws>, <left>, <right> )
##
DeclareOperation(
    "ReducedLeftQuotient",
    [ IsRewritingSystem, 
      IsMultiplicativeElement,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedOne( <rws> )
##
DeclareOperation(
    "ReducedOne", 
    [ IsRewritingSystem ] );


#############################################################################
##
#O  ReducedPower( <rws>, <obj>, <pow> )
##
DeclareOperation(
    "ReducedPower",
    [ IsRewritingSystem, 
      IsMultiplicativeElement,
      IsInt ] );


#############################################################################
##
#O  ReducedProduct( <rws>, <left>, <right> )
##
DeclareOperation(
    "ReducedProduct", 
    [ IsRewritingSystem,
      IsMultiplicativeElement, 
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedQuotient( <rws>, <left>, <right> )
##
DeclareOperation(
    "ReducedQuotient", 
    [ IsRewritingSystem,
      IsMultiplicativeElement,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedScalarProduct( <rws>, <left>, <right> )
##
DeclareOperation(
    "ReducedScalarProduct", 
    [ IsRewritingSystem,
      IsScalar,
      IsAdditiveElement ] );


#############################################################################
##
#O  ReducedSum( <rws>, <left>, <right> )
##
DeclareOperation(
    "ReducedSum",
    [ IsRewritingSystem,
      IsAdditiveElement,
      IsAdditiveElement ] );


#############################################################################
##
#O  ReducedZero( <rws> )
##
DeclareOperation(
    "ReducedZero", 
    [ IsRewritingSystem ] );


#############################################################################
##

#V  InfoConfluence
##
DeclareInfoClass("InfoConfluence");


#############################################################################
##

#E  rws.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
