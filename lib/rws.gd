#############################################################################
##
#W  rws.gd                      GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##

#1  
##  This file  contains    the   operations for   rewriting   systems.    Any
##  implementation of a rewriting system must at least implement methods for
##
##    constructing such a rewriting system,
##    `CopyRws',
##    `IsConfluent',
##    `ReducedForm', and
##    `Rules'.
##
##  An  implementation might  also  want to  implement `MakeConfluent' and/or
##  `ConfluentRws'.
##
##  The generic methods, which are defined in "rws.gi", for
##
##    `ReducedAdditiveInverse',
##    `ReducedComm',
##    `ReducedConjugate',
##    `ReducedDifference'
##    `ReducedInverse',
##    `ReducedLeftQuotient',
##    `ReducedOne',
##    `ReducedPower',
##    `ReducedProduct'
##    `ReducedScalarProduct',
##    `ReducedSum', and
##    `ReducedZero',
##
##  use `ReducedForm'. Depending on the underlying  structure not all of them
##  will  work.  For example, for  a  monoid `ReducedInverse' will produce an
##  error because  the generic methods  tries to  reduced  the inverse of the
##  given element.
##
##  As in  general  a rewriting system will    be first built   and then used
##  without   changing   it,  some   functions    (e.g.  `GroupByRws')   call
##  `ReduceRules'  to give the rewriting  system a chance to optimise itself.
##  The default method for `ReduceRules' is "do nothing".
##
##  The underlying  structure is stored  in the  attribute `UnderlyingFamily'
##  and  the  generators  used for  the  rewriting  system   in the attribute
##  `GeneratorsOfRws'.   The number  of  rws  generators   is stored in   the
##  attribute `NumberGeneratorsOfRws'.
##
##  The family of a rewriting system also contains the underlying family, the
##  default    method for `UnderlyingFamily'    uses  the family  to get  the
##  underlying family for a given rewriting system.
##

#2
##  The key point to note about rewriting systems is that they have 
##  properties such as `IsConfluent' and attributes such as `Rules', however
##  they are rarely stored, but rather computed afresh each time they
##  are asked for, from data stored in the private members of the rewriting
##  system object.  This is because a rewriting system often evolves
##  through a session, starting with some rules which define the
##  algebra <A> as relations, and then adding more rules to make
##  the system confluent.
##  For example, in the case of Knuth-Bendix rewriting systems
##  (see Chapter~"Finitely Presented Semigroups and Monoids"), the function
##  `CreateKnuthBendixRewritingSystem' creating the
##  rewriting system (in `kbsemi.gi') uses
##  
##  \begintt
##  kbrws := Objectify(NewType(rwsfam, 
##    IsMutable and IsKnuthBendixRewritingSystem and 
##    IsKnuthBendixRewritingSystemRep), 
##    rec(family:= fam,
##    reduced:=false,
##    tzrules:=List(relwco,i->
##     [LetterRepAssocWord(i[1]),LetterRepAssocWord(i[2])]),
##    pairs2check:=CantorList(Length(r)),
##    ordering:=wordord,
##    freefam:=freefam));
##  \endtt
##  
##  In particular, since we don't use the filter `IsAttributeStoringRep'
##  in the `Objectify', whenever `IsConfluent' is called, the appropriate
##  method to determine confluence is called. 

Revision.rws_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsRewritingSystem( <obj> )
##
##  This is the category in which all rewriting systems lie.
##
DeclareCategory(
    "IsRewritingSystem",
    IsCopyable );

#############################################################################
##
#C  IsReducedConfluentRewritingSystem( <obj> )
##
##  This is a subcategory of `IsRewritingSystem' for (immutable) rws which
##  are reduced and confluent.
##
DeclareCategory(
    "IsReducedConfluentRewritingSystem",
    IsRewritingSystem);

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
#P  IsBuiltFromSemigroup( <obj> )
##
DeclareProperty( "IsBuiltFromSemigroup", IsObject );

#############################################################################
##
#P  IsBuiltFromMonoid( <obj> )
##
DeclareProperty( "IsBuiltFromMonoid", IsObject );


#############################################################################
##
#M  IsBuiltFromGroup( <obj> )
##
InstallTrueMethod( IsBuiltFromMagmaWithInverses, IsBuiltFromGroup );

#############################################################################
##
#A  SemigroupOfRewritingSystem( <rws> )
##
##  returns the semigroup over which <rws> is
##  a rewriting system
##
DeclareAttribute("SemigroupOfRewritingSystem",IsRewritingSystem);

#############################################################################
##
#A  MonoidOfRewritingSystem( <rws> )
##  
##  returns the monoid over which <rws> is a rewriting system
##
DeclareAttribute("MonoidOfRewritingSystem",IsRewritingSystem);


#############################################################################
##
#O  FreeStructureOfRewritingSystem( <obj> )
##
DeclareOperation( "FreeStructureOfRewritingSystem", [IsRewritingSystem]);

#############################################################################
##
#A  ConfluentRws( <rws> )
##
##  Return a new rewriting system defining the same algebra as <rws> 
##  which is confluent.

#  NOTE: this is an  attribute  *but* rewriting system   do not  store  this
#  attribute because they are mutable.
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
##  The rules comprising the rewriting system. Note that these may 
##  change through the life of the rewriting system, however they
##  will always be a set of defining relations of the algebra
##  described by the rewriting system.

##  NOTE: this is an   attribute *but*, normally, rewriting  system  
##  do not store this attribute.
##
DeclareAttribute(
    "Rules",
    IsRewritingSystem );



#############################################################################
##
#a  UnderlyingFamily( <rws> )
##
#T DeclareAttribute(
#T     "UnderlyingFamily",
#T     IsObject );
#T already in `liefam.gd'

#############################################################################
##
#A  OrderOfRewritingSystem(<rws>)
#A  OrderingOfRewritingSystem(<rws>)
##
##  return the ordering of the rewriting system <rws>.
##  %the synonym here guarantees compatibility with {\GAP}~4.1 and {\GAP}~4.2.
##
DeclareAttribute("OrderingOfRewritingSystem", IsRewritingSystem);
DeclareSynonym("OrderOfRewritingSystem", OrderingOfRewritingSystem);

#############################################################################
##
#P  IsConfluent( <rws> )
#P  IsConfluent( <A> )
##
##  return `true' if and only if the rewriting system <rws> is confluent. 
##  A rewriting system is *confluent* if, for every two words 
##  <u> and <v> in the free algebra <T> which represent the same element 
##  of the algebra <A> defined by <rws>,
##  `ReducedForm(<rws>,<u>) =  ReducedForm(<rws>,<v>)' as words in the
##  free algebra <T>. This element is the *unique normal form*
##  of the element represented by <u>.
##
##  In its second
##  form, if <A> is an algebra with a canonical rewriting system associated
##  with it, `IsConfluent' checks whether that rewriting system is confluent.
##
##  Also see~"IsConfluent!for pc groups".
##

#  NOTE: this is a property *but* the rewriting system does not store  this
#  attribute.
##
DeclareProperty(
    "IsConfluent",
    IsRewritingSystem );



#############################################################################
##
#P  IsReduced( <rws> )
##
##  A rewriting system is reduced if for each rule (<l>, <r>), 
##  <l> and <r> are both reduced.
##  
##
DeclareProperty( "IsReduced", IsRewritingSystem and IsMutable );




#############################################################################
##
#O  AddRule(<rws>, <rule>)
##
##
##  Add  <rule> to a rewriting system <rws>. 
##
DeclareOperation(
    "AddRule",
    [ IsRewritingSystem and IsMutable , IsHomogeneousList ] );

#############################################################################
##
#O  AddRuleReduced(<rws>, <rule>)
##
##  Add <rule> to rewriting system <rws>. Performs a reduction operation
##  on the resulting system, so that if <rws> is reduced it will remain reduced.
##
DeclareOperation(
    "AddRuleReduced",
    [ IsRewritingSystem and IsMutable , IsHomogeneousList ] );



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
##  Add rules (and perhaps reduce) in order to make <rws> confluent
##
DeclareOperation(
    "MakeConfluent",
    [ IsRewritingSystem and IsMutable ] );


#############################################################################
##
#O  ReduceRules( <rws> )
##
##  Reduce rules and remove redundant rules to make <rws> reduced.
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
#O  ReducedForm( <rws>, <u> )
##
##  Given an element <u> in the free (or term) algebra over which
##  <rws> is defined, rewrite <u> by successive applications of the
##  rules of <rws> until no further rewriting is possible, and return
##  the resulting element of <T>.
##
DeclareOperation(
    "ReducedForm", 
    [ IsRewritingSystem,
      IsObject ] );

#############################################################################
##
#O  IsReducedForm( <rws>, <u> )
##
##  Given an element <u> in the free (or term) algebra over which
##  <rws> is defined, returns `<u> = ReducedForm(<rws>, <u>)'. 
##
DeclareOperation(
    "IsReducedForm",
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
#O  ReducedProduct( <rws>, <u>, <v> )
##
##  The result is  <w> where <[w]> = <[u]><[v]> in <A> and
##  <w> is  in reduced form.
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

