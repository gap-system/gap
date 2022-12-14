#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file  contains    the   operations for   rewriting   systems.    Any
##  implementation of a rewriting system must at least implement methods for
##  <P/>
##    constructing such a rewriting system,
##    <C>CopyRws</C>,
##    <C>IsConfluent</C>,
##    <C>ReducedForm</C>, and
##    <C>Rules</C>.
##  <P/>
##  An  implementation might  also  want to  implement <C>MakeConfluent</C> and/or
##  <C>ConfluentRws</C>.
##  <P/>
##  The generic methods, which are defined in <F>rws.gi</F>, for
##  <P/>
##    <C>ReducedAdditiveInverse</C>,
##    <C>ReducedComm</C>,
##    <C>ReducedConjugate</C>,
##    <C>ReducedDifference</C>
##    <C>ReducedInverse</C>,
##    <C>ReducedLeftQuotient</C>,
##    <C>ReducedOne</C>,
##    <C>ReducedPower</C>,
##    <C>ReducedProduct</C>
##    <C>ReducedScalarProduct</C>,
##    <C>ReducedSum</C>, and
##    <C>ReducedZero</C>,
##  <P/>
##  use <C>ReducedForm</C>. Depending on the underlying  structure not all of them
##  will  work.  For example, for  a  monoid <C>ReducedInverse</C> will produce an
##  error because  the generic methods  tries to  reduced  the inverse of the
##  given element.
##  <P/>
##  As in  general  a rewriting system will    be first built   and then used
##  without   changing   it,  some   functions    (e.g.  <C>GroupByRws</C>)   call
##  <C>ReduceRules</C>  to give the rewriting  system a chance to optimise itself.
##  The default method for <C>ReduceRules</C> is <Q>do nothing</Q>.
##  <P/>
##  The underlying  structure is stored  in the  attribute <C>UnderlyingFamily</C>
##  and  the  generators  used for  the  rewriting  system   in the attribute
##  <C>GeneratorsOfRws</C>.   The number  of  rws  generators   is stored in   the
##  attribute <C>NumberGeneratorsOfRws</C>.
##  <P/>
##  The family of a rewriting system also contains the underlying family, the
##  default    method for <C>UnderlyingFamily</C>    uses  the family  to get  the
##  underlying family for a given rewriting system.
##
##  <#GAPDoc Label="[2]{rws}">
##  The key point to note about rewriting systems is that they have
##  properties such as
##  <Ref Prop="IsConfluent" Label="for a rewriting system"/>
##  and attributes such as <Ref Attr="Rules"/>, however
##  they are rarely stored, but rather computed afresh each time they
##  are asked for, from data stored in the private members of the rewriting
##  system object.  This is because a rewriting system often evolves
##  through a session, starting with some rules which define the
##  algebra <A>A</A> as relations, and then adding more rules to make
##  the system confluent.
##  For example, in the case of Knuth-Bendix rewriting systems (see
##  Chapter&nbsp;<Ref Chap="Finitely Presented Semigroups and Monoids"/>),
##  the function <C>CreateKnuthBendixRewritingSystem</C> creating the
##  rewriting system (in the file <F>lib/kbsemi.gi</F>) uses
##  <P/>
##  <Log><![CDATA[
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
##  ]]></Log>
##  <P/>
##  In particular, since we don't use the filter
##  <C>IsAttributeStoringRep</C>
##  in the <Ref Func="Objectify"/>,
##  whenever <Ref Prop="IsConfluent" Label="for a rewriting system"/> is
##  called,
##  the appropriate method to determine confluence is called.
##  <#/GAPDoc>
##


#############################################################################
##
#C  IsRewritingSystem( <obj> )
##
##  <#GAPDoc Label="IsRewritingSystem">
##  <ManSection>
##  <Filt Name="IsRewritingSystem" Arg='obj' Type='Category'/>
##
##  <Description>
##  This is the category in which all rewriting systems lie.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory(
    "IsRewritingSystem",
    IsCopyable );

#############################################################################
##
#C  IsReducedConfluentRewritingSystem( <obj> )
##
##  <ManSection>
##  <Filt Name="IsReducedConfluentRewritingSystem" Arg='obj' Type='Category'/>
##
##  <Description>
##  This is a subcategory of <Ref Func="IsRewritingSystem"/> for (immutable)
##  rws which are reduced and confluent.
##  </Description>
##  </ManSection>
##
DeclareCategory(
    "IsReducedConfluentRewritingSystem",
    IsRewritingSystem);

#############################################################################
##
#P  IsBuiltFromAdditiveMagmaWithInverses( <obj> )
##
##  <ManSection>
##  <Prop Name="IsBuiltFromAdditiveMagmaWithInverses" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareProperty(
    "IsBuiltFromAdditiveMagmaWithInverses",
    IsObject );


#############################################################################
##
#P  IsBuiltFromMagma( <obj> )
##
##  <ManSection>
##  <Prop Name="IsBuiltFromMagma" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareProperty(
    "IsBuiltFromMagma",
    IsObject );


#############################################################################
##
#P  IsBuiltFromMagmaWithOne( <obj> )
##
##  <ManSection>
##  <Prop Name="IsBuiltFromMagmaWithOne" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareProperty(
    "IsBuiltFromMagmaWithOne",
    IsObject );


#############################################################################
##
#P  IsBuiltFromMagmaWithInverses( <obj> )
##
##  <ManSection>
##  <Prop Name="IsBuiltFromMagmaWithInverses" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareProperty(
    "IsBuiltFromMagmaWithInverses",
    IsObject );


#############################################################################
##
#P  IsBuiltFromGroup( <obj> )
##
##  <ManSection>
##  <Prop Name="IsBuiltFromGroup" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Prop Name="IsBuiltFromSemigroup" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareProperty( "IsBuiltFromSemigroup", IsObject );

#############################################################################
##
#P  IsBuiltFromMonoid( <obj> )
##
##  <ManSection>
##  <Prop Name="IsBuiltFromMonoid" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
#A  MonoidOfRewritingSystem( <rws> )
##
##  <#GAPDoc Label="SemigroupOfRewritingSystem">
##  <ManSection>
##  <Attr Name="SemigroupOfRewritingSystem" Arg='rws'/>
##  <Attr Name="MonoidOfRewritingSystem" Arg='rws'/>
##
##  <Description>
##  returns the semigroup or monoid over which <A>rws</A> is
##  a rewriting system.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("SemigroupOfRewritingSystem",IsRewritingSystem);
DeclareAttribute("MonoidOfRewritingSystem",IsRewritingSystem);


#############################################################################
##
#O  FreeStructureOfRewritingSystem( <obj> )
##
##  <ManSection>
##  <Oper Name="FreeStructureOfRewritingSystem" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "FreeStructureOfRewritingSystem", [IsRewritingSystem]);

#############################################################################
##
#A  ConfluentRws( <rws> )
##
##  <#GAPDoc Label="ConfluentRws">
##  <ManSection>
##  <Attr Name="ConfluentRws" Arg='rws'/>
##
##  <Description>
##  Return a new rewriting system defining the same algebra as <A>rws</A>
##  which is confluent.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

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
##  <#GAPDoc Label="GeneratorsOfRws">
##  <ManSection>
##  <Attr Name="GeneratorsOfRws" Arg='rws'/>
##
##  <Description>
##  Returns the list of generators of the rewriting system <A>rws</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute(
    "GeneratorsOfRws",
    IsRewritingSystem );



#############################################################################
##
#A  NumberGeneratorsOfRws( <rws> )
##
##  <ManSection>
##  <Attr Name="NumberGeneratorsOfRws" Arg='rws'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute(
    "NumberGeneratorsOfRws",
    IsRewritingSystem );



#############################################################################
##
#A  Rules( <rws> )
##
##  <#GAPDoc Label="Rules">
##  <ManSection>
##  <Attr Name="Rules" Arg='rws'/>
##
##  <Description>
##  The rules comprising the rewriting system. Note that these may
##  change through the life of the rewriting system, however they
##  will always be a set of defining relations of the algebra
##  described by the rewriting system.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

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
##  <#GAPDoc Label="OrderOfRewritingSystem">
##  <ManSection>
##  <Attr Name="OrderOfRewritingSystem" Arg='rws'/>
##  <Attr Name="OrderingOfRewritingSystem" Arg='rws'/>
##
##  <Description>
##  return the ordering of the rewriting system <A>rws</A>.
##  <!-- %the synonym here guarantees compatibility with &GAP;&nbsp;4.1 and &GAP;&nbsp;4.2. -->
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("OrderingOfRewritingSystem", IsRewritingSystem);
DeclareSynonym("OrderOfRewritingSystem", OrderingOfRewritingSystem);

#############################################################################
##
#P  IsConfluent( <rws> )
#P  IsConfluent( <A> )
##
##  <#GAPDoc Label="IsConfluent">
##  <ManSection>
##  <Heading>IsConfluent</Heading>
##  <Prop Name="IsConfluent" Arg='rws' Label="for a rewriting system"/>
##  <Prop Name="IsConfluent" Arg='A'
##   Label="for an algebra with canonical rewriting system"/>
##
##  <Description>
##  For a rewriting system <A>rws</A>,
##  <Ref Prop="IsConfluent" Label="for a rewriting system"/> returns
##  <K>true</K> if and only if <A>rws</A> is confluent.
##  A rewriting system is <E>confluent</E> if, for every two words
##  <M>u</M> and <M>v</M> in the free algebra <M>T</M> which represent the
##  same element  of the algebra <M>A</M> defined by <A>rws</A>,
##  <C>ReducedForm( <A>rws</A>, </C><M>u</M> <C>) =
##  ReducedForm( <A>rws</A>, </C><M>v</M><C>)</C> as words in the
##  free algebra <M>T</M>.
##  This element is the <E>unique normal form</E>
##  of the element represented by <M>u</M>.
##  <P/>
##  For an algebra <A>A</A> with a canonical rewriting system associated
##  with it,
##  <Ref Prop="IsConfluent" Label="for an algebra with canonical rewriting system"/>
##  checks whether that rewriting system is confluent.
##  <P/>
##  Also see&nbsp;<Ref Prop="IsConfluent" Label="for pc groups"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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
##  <#GAPDoc Label="IsReduced">
##  <ManSection>
##  <Prop Name="IsReduced" Arg='rws'/>
##
##  <Description>
##  A rewriting system is reduced if for each rule <M>(l, r)</M>,
##  <M>l</M> and <M>r</M> are both reduced.
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty( "IsReduced", IsRewritingSystem and IsMutable );




#############################################################################
##
#O  AddRule(<rws>, <rule>)
##
##  <#GAPDoc Label="AddRule">
##  <ManSection>
##  <Oper Name="AddRule" Arg='rws, rule'/>
##
##  <Description>
##  Add  <A>rule</A> to a rewriting system <A>rws</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "AddRule",
    [ IsRewritingSystem and IsMutable , IsHomogeneousList ] );

#############################################################################
##
#O  AddRuleReduced(<rws>, <rule>)
##
##  <#GAPDoc Label="AddRuleReduced">
##  <ManSection>
##  <Oper Name="AddRuleReduced" Arg='rws, rule'/>
##
##  <Description>
##  Add <A>rule</A> to rewriting system <A>rws</A>.
##  Performs a reduction operation on the resulting system,
##  so that if <A>rws</A> is reduced it will remain reduced.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "AddRuleReduced",
    [ IsRewritingSystem and IsMutable , IsHomogeneousList ] );



#############################################################################
##
#O  AddGenerators( <rws>, <gens> )
##
##  <ManSection>
##  <Oper Name="AddGenerators" Arg='rws, gens'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "AddGenerators",
    [ IsRewritingSystem and IsMutable, IsHomogeneousList ] );


#############################################################################
##
#O  MakeConfluent( <rws> )
##
##  <#GAPDoc Label="MakeConfluent">
##  <ManSection>
##  <Oper Name="MakeConfluent" Arg='rws'/>
##
##  <Description>
##  Add rules (and perhaps reduce) in order to make <A>rws</A> confluent
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "MakeConfluent",
    [ IsRewritingSystem and IsMutable ] );


#############################################################################
##
#O  ReduceRules( <rws> )
##
##  <#GAPDoc Label="ReduceRules">
##  <ManSection>
##  <Oper Name="ReduceRules" Arg='rws'/>
##
##  <Description>
##  Reduce rules and remove redundant rules to make <A>rws</A> reduced.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "ReduceRules",
    [ IsRewritingSystem and IsMutable ] );


#############################################################################
##
#O  ReducedAdditiveInverse( <rws>, <obj> )
##
##  <ManSection>
##  <Oper Name="ReducedAdditiveInverse" Arg='rws, obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "ReducedAdditiveInverse",
    [ IsRewritingSystem,
      IsAdditiveElement ] );


#############################################################################
##
#O  ReducedComm( <rws>, <left>, <right> )
##
##  <ManSection>
##  <Oper Name="ReducedComm" Arg='rws, left, right'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Oper Name="ReducedConjugate" Arg='rws, left, right'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Oper Name="ReducedDifference" Arg='rws, left, right'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <#GAPDoc Label="ReducedForm">
##  <ManSection>
##  <Oper Name="ReducedForm" Arg='rws, u'/>
##
##  <Description>
##  Given an element <A>u</A> in the free (or term) algebra <M>T</M> over
##  which <A>rws</A> is defined,
##  rewrite <A>u</A> by successive applications of the
##  rules of <A>rws</A> until no further rewriting is possible, and return
##  the resulting element of <M>T</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation(
    "ReducedForm",
    [ IsRewritingSystem,
      IsObject ] );

#############################################################################
##
#O  IsReducedForm( <rws>, <u> )
##
##  <ManSection>
##  <Oper Name="IsReducedForm" Arg='rws, u'/>
##
##  <Description>
##  Given an element <A>u</A> in the free (or term) algebra over which
##  <A>rws</A> is defined,
##  returns <C><A>u</A> = ReducedForm(<A>rws</A>, <A>u</A>)</C>.
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "IsReducedForm",
    [ IsRewritingSystem,
      IsObject ] );



#############################################################################
##
#O  ReducedInverse( <rws>, <obj> )
##
##  <ManSection>
##  <Oper Name="ReducedInverse" Arg='rws, obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "ReducedInverse",
    [ IsRewritingSystem,
      IsMultiplicativeElement ] );


#############################################################################
##
#O  ReducedLeftQuotient( <rws>, <left>, <right> )
##
##  <ManSection>
##  <Oper Name="ReducedLeftQuotient" Arg='rws, left, right'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Oper Name="ReducedOne" Arg='rws'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "ReducedOne",
    [ IsRewritingSystem ] );


#############################################################################
##
#O  ReducedPower( <rws>, <obj>, <pow> )
##
##  <ManSection>
##  <Oper Name="ReducedPower" Arg='rws, obj, pow'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Oper Name="ReducedProduct" Arg='rws, u, v'/>
##
##  <Description>
##  The result is <M>w</M> where <M>[w]</M> equals [<A>u</A>][<A>v</A>] in
##  <M>A</M> and <M>w</M> is in reduced form.
##  <P/>
##  The remaining operations are defined similarly when they
##  are defined (as determined by the signature of the term algebra).
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Oper Name="ReducedQuotient" Arg='rws, left, right'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Oper Name="ReducedScalarProduct" Arg='rws, left, right'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Oper Name="ReducedSum" Arg='rws, left, right'/>
##
##  <Description>
##  </Description>
##  </ManSection>
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
##  <ManSection>
##  <Oper Name="ReducedZero" Arg='rws'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation(
    "ReducedZero",
    [ IsRewritingSystem ] );


#############################################################################
##
#V  InfoConfluence
##
DeclareInfoClass("InfoConfluence");
