#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include James D Mitchell.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the declarations for equivalence relations on
##  semigroups. Of particular interest are Green's relations,
##  congruences, and Rees congruences.
##

#############################################################################
##
##  GREEN'S RELATIONS
##
##  <#GAPDoc Label="[1]{semirel}">
##  Green's equivalence relations play a very important role in semigroup
##  theory. In this section we describe how they can be used in &GAP;.
##  <P/>
##  The five Green's relations are <M>R</M>, <M>L</M>, <M>J</M>, <M>H</M>,
##  <M>D</M>:
##  two elements <M>x</M>, <M>y</M> from a semigroup <M>S</M> are
##  <M>R</M>-related if and only if <M>xS^1 = yS^1</M>,
##  <M>L</M>-related if and only if <M>S^1 x = S^1 y</M>
##  and <M>J</M>-related if and only if <M>S^1 xS^1 = S^1 yS^1</M>;
##  finally, <M>H = R \wedge L</M>, and <M>D = R \circ L</M>.
##  <P/>
##  Recall that relations <M>R</M>, <M>L</M> and <M>J</M> induce a partial
##  order among the elements of the semigroup <M>S</M>:
##  for two elements <M>x</M>, <M>y</M> from <M>S</M>,
##  we say that <M>x</M> is less than or equal to <M>y</M> in the order on
##  <M>R</M> if <M>xS^1 \subseteq yS^1</M>;
##  similarly, <M>x</M> is less than or equal to <M>y</M> under <M>L</M> if
##  <M>S^1x \subseteq S^1y</M>;
##  finally <M>x</M> is less than or equal to <M>y</M> under <M>J</M> if
##  <M>S^1 xS^1 \subseteq S^1 tS^1</M>.
##  We extend this preorder to a partial order on equivalence classes in
##  the natural way.
##  <#/GAPDoc>
##


#############################################################################
##
#P  IsGreensRelation(<bin-relation>)
#P  IsGreensRRelation(<equiv-relation>)
#P  IsGreensLRelation(<equiv-relation>)
#P  IsGreensJRelation(<equiv-relation>)
#P  IsGreensHRelation(<equiv-relation>)
#P  IsGreensDRelation(<equiv-relation>)
##
##  <#GAPDoc Label="IsGreensRelation">
##  <ManSection>
##  <Filt Name="IsGreensRelation" Arg='bin-relation'/>
##  <Filt Name="IsGreensRRelation" Arg='equiv-relation'/>
##  <Filt Name="IsGreensLRelation" Arg='equiv-relation'/>
##  <Filt Name="IsGreensJRelation" Arg='equiv-relation'/>
##  <Filt Name="IsGreensHRelation" Arg='equiv-relation'/>
##  <Filt Name="IsGreensDRelation" Arg='equiv-relation'/>
##
##  <Description>
##  Categories for the Green's relations.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsGreensRelation", IsEquivalenceRelation);
DeclareCategory("IsGreensRRelation", IsGreensRelation);
DeclareCategory("IsGreensLRelation", IsGreensRelation);
DeclareCategory("IsGreensJRelation", IsGreensRelation);
DeclareCategory( "IsGreensHRelation", IsGreensRelation);
DeclareCategory( "IsGreensDRelation", IsGreensRelation);

DeclareProperty("IsFiniteSemigroupGreensRelation", IsGreensRelation);

#############################################################################
##
#A  GreensRRelation(<semigroup>)
#A  GreensLRelation(<semigroup>)
#A  GreensJRelation(<semigroup>)
#A  GreensDRelation(<semigroup>)
#A  GreensHRelation(<semigroup>)
##
##  <#GAPDoc Label="GreensRRelation">
##  <ManSection>
##  <Attr Name="GreensRRelation" Arg='semigroup'/>
##  <Attr Name="GreensLRelation" Arg='semigroup'/>
##  <Attr Name="GreensJRelation" Arg='semigroup'/>
##  <Attr Name="GreensDRelation" Arg='semigroup'/>
##  <Attr Name="GreensHRelation" Arg='semigroup'/>
##
##  <Description>
##  The Green's relations (which are equivalence relations)
##  are attributes of the semigroup <A>semigroup</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareAttribute("GreensRRelation", IsSemigroup);
DeclareAttribute("GreensLRelation", IsSemigroup);
DeclareAttribute("GreensJRelation", IsSemigroup);
DeclareAttribute("GreensDRelation", IsSemigroup);
DeclareAttribute("GreensHRelation", IsSemigroup);

#############################################################################
##
#O  GreensRClassOfElement(<S>, <a>)
#O  GreensLClassOfElement(<S>, <a>)
#O  GreensDClassOfElement(<S>, <a>)
#O  GreensJClassOfElement(<S>, <a>)
#O  GreensHClassOfElement(<S>, <a>)
##
##  <#GAPDoc Label="GreensRClassOfElement">
##  <ManSection>
##  <Oper Name="GreensRClassOfElement" Arg='S, a'/>
##  <Oper Name="GreensLClassOfElement" Arg='S, a'/>
##  <Oper Name="GreensDClassOfElement" Arg='S, a'/>
##  <Oper Name="GreensJClassOfElement" Arg='S, a'/>
##  <Oper Name="GreensHClassOfElement" Arg='S, a'/>
##
##  <Description>
##  Creates the <M>X</M> class of the element <A>a</A>
##  in the semigroup <A>S</A> where <M>X</M> is one of
##  <M>L</M>, <M>R</M>, <M>D</M>, <M>J</M>, or <M>H</M>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareOperation("GreensRClassOfElement", [IsSemigroup, IsObject]);
DeclareOperation("GreensLClassOfElement", [IsSemigroup, IsObject]);
DeclareOperation("GreensDClassOfElement", [IsSemigroup, IsObject]);
DeclareOperation("GreensJClassOfElement", [IsSemigroup, IsObject]);
DeclareOperation("GreensHClassOfElement", [IsSemigroup, IsObject]);

#######################
#######################

DeclareOperation("FroidurePinSimpleAlg", [IsMonoid]);
DeclareOperation("FroidurePinExtendedAlg", [IsSemigroup]);

DeclareAttribute("AssociatedConcreteSemigroup", IsFpSemigroup);
DeclareAttribute("AssociatedFpSemigroup", IsSemigroup);

DeclareSynonymAttr("LeftCayleyGraphSemigroup", CayleyGraphDualSemigroup);
DeclareSynonymAttr("RightCayleyGraphSemigroup", CayleyGraphSemigroup);

#############################################################################
##
#P  IsGreensClass(<equiv-class>)
#P  IsGreensRClass(<equiv-class>)
#P  IsGreensLClass(<equiv-class>)
#P  IsGreensJClass(<equiv-class>)
#P  IsGreensHClass(<equiv-class>)
#P  IsGreensDClass(<equiv-class>)
##
##  <#GAPDoc Label="IsGreensClass">
##  <ManSection>
##  <Filt Name="IsGreensClass" Arg='equiv-class'/>
##  <Filt Name="IsGreensRClass" Arg='equiv-class'/>
##  <Filt Name="IsGreensLClass" Arg='equiv-class'/>
##  <Filt Name="IsGreensJClass" Arg='equiv-class'/>
##  <Filt Name="IsGreensHClass" Arg='equiv-class'/>
##  <Filt Name="IsGreensDClass" Arg='equiv-class'/>
##
##  <Description>
##  return <K>true</K> if the equivalence class <A>equiv-class</A> is
##  a Green's class of any type, or of <M>R</M>, <M>L</M>, <M>J</M>,
##  <M>H</M>, <M>D</M> type, respectively, or <K>false</K> otherwise.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareCategory("IsGreensClass", IsEquivalenceClass);
DeclareCategory("IsGreensRClass", IsGreensClass);
DeclareCategory("IsGreensLClass", IsGreensClass);
DeclareCategory("IsGreensJClass", IsGreensClass);
DeclareCategory("IsGreensHClass", IsGreensClass);
DeclareCategory("IsGreensDClass", IsGreensClass);

#############################################################################
##
#A  AssociatedSemigroup(<greens-class>) . . . . . . . . .   for Green's class
##
##  <ManSection>
##  <Attr Name="AssociatedSemigroup" Arg='greens-class'/>
##
##  <Description>
##  A Greens class needs what semigroup it is associated with
##  </Description>
##  </ManSection>
##

DeclareSynonymAttr("AssociatedSemigroup", ParentAttr);

#############################################################################
##
#A  GreensRClasses(<S>)
#A  GreensLClasses(<S>)
#A  GreensHClasses(<S>)
#A  GreensJClasses(<S>)
#A  GreensDClasses(<S>)
##
##  <#GAPDoc Label="GreensRClasses">
##  <ManSection>
##  <Attr Name="GreensRClasses" Arg="S"/>
##  <Attr Name="GreensLClasses" Arg="S"/>
##  <Attr Name="GreensHClasses" Arg="S"/>
##  <Attr Name="GreensJClasses" Arg="S"/>
##  <Attr Name="GreensDClasses" Arg="S"/>
##
##  <Description>
##  If <A>S</A> is a semigroup, then these attributes return the Green's
#   <M>R</M>-, <M>L</M>-, <M>H</M>-, <M>J</M>-, or
##  <M>D</M>-classes, respectively for the semigroup <A>S</A>.
##  <P/>
##  Additionally, if <A>S</A> is a Green's <M>D</M>-class of a semigroup, then
##  <C>GreensRClasses</C> and <C>GreensLClasses</C> return the Green's <M>R</M>-
##  or <M>L-</M>classes of the semigroup, respectively, contained in the
##  <M>D</M>-class <A>S</A>;
##  if <A>S</A> is a Green's <M>D</M>-, <M>R</M>-, or <M>L</M>-class of a
##  semigroup, then <C>GreensHClasses</C> returns the Green's <M>H</M>-classes
##  of the semigroup contained in the Green's class <A>S</A>.
##  <P/>
##  <Ref Attr="EquivalenceClasses" Label="attribute"/> for a Green's relation
##  lead to one of these functions.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareAttribute("GreensRClasses", IsSemigroup);
DeclareAttribute("GreensLClasses", IsSemigroup);
DeclareAttribute("GreensJClasses", IsSemigroup);
DeclareAttribute("GreensDClasses", IsSemigroup);
DeclareAttribute("GreensHClasses", IsSemigroup);

DeclareAttribute("GreensHClasses", IsGreensClass);
DeclareAttribute("GreensRClasses", IsGreensDClass);
DeclareAttribute("GreensLClasses", IsGreensDClass);

#############################################################################
##
#O  IsGreensLessThanOrEqual( <C1>, <C2> )
##
##  <#GAPDoc Label="IsGreensLessThanOrEqual">
##  <ManSection>
##  <Oper Name="IsGreensLessThanOrEqual" Arg='C1, C2'/>
##
##  <Description>
##  returns <K>true</K> if the Green's class <A>C1</A> is less than or equal
##  to <A>C2</A>  under the respective ordering (as defined above),
##  and <K>false</K> otherwise.
##  <P/>
##  Only defined for <M>R</M>, <M>L</M> and <M>J</M> classes.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("IsGreensLessThanOrEqual", [IsGreensClass, IsGreensClass]);

#############################################################################
##
#A  RClassOfHClass( <H> )
#A  LClassOfHClass( <H> )
##
##  <#GAPDoc Label="RClassOfHClass">
##  <ManSection>
##  <Attr Name="RClassOfHClass" Arg='H'/>
##  <Attr Name="LClassOfHClass" Arg='H'/>
##
##  <Description>
##  are attributes reflecting the natural ordering over the various Green's
##  classes. <Ref Attr="RClassOfHClass"/> and <Ref Attr="LClassOfHClass"/>
##  return the <M>R</M> and <M>L</M> classes, respectively,
##  in which an <M>H</M> class is contained.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareAttribute("RClassOfHClass", IsGreensHClass);
DeclareAttribute("LClassOfHClass", IsGreensHClass);
DeclareAttribute("DClassOfHClass", IsGreensHClass);
DeclareAttribute("DClassOfLClass", IsGreensLClass);
DeclareAttribute("DClassOfRClass", IsGreensRClass);

############################################################################
##
#A  GroupHClassOfGreensDClass( <Dclass> )
##
##  <#GAPDoc Label="GroupHClassOfGreensDClass">
##  <ManSection>
##  <Attr Name="GroupHClassOfGreensDClass" Arg='Dclass'/>
##
##  <Description>
##  for a <M>D</M> class <A>Dclass</A> of a semigroup,
##  returns a group <M>H</M> class of the <M>D</M> class,
##  or <K>fail</K> if there is no group <M>H</M> class.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("GroupHClassOfGreensDClass",IsGreensDClass);


#############################################################################
##
#P  IsRegularDClass( <Dclass> )
##
##  <#GAPDoc Label="IsRegularDClass">
##  <ManSection>
##  <Prop Name="IsRegularDClass" Arg='Dclass'/>
##
##  <Description>
##  returns <K>true</K> if the Greens <M>D</M> class <A>Dclass</A> is
##  regular.
##  A <M>D</M> class is regular if and only if each of its elements is
##  regular, which in turn is true if and only if any one element of
##  <A>Dclass</A> is regular.
##  Idempotents are regular since <M>eee = e</M> so it follows that a Green's
##  <M>D</M> class containing an idempotent is regular.
##  Conversely, it is true that a regular <M>D</M> class must contain
##  at least one idempotent.
##  (See&nbsp;<Cite Key="Howie76" Where="Prop. 3.2"/>.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsRegularDClass", IsGreensDClass);


#############################################################################
##
#P  IsGroupHClass( <Hclass> )
##
##  <#GAPDoc Label="IsGroupHClass">
##  <ManSection>
##  <Prop Name="IsGroupHClass" Arg='Hclass'/>
##
##  <Description>
##  returns <K>true</K> if the Green's <M>H</M> class <A>Hclass</A> is a
##  group, which in turn is true if and only if <A>Hclass</A><M>^2</M>
##  intersects <A>Hclass</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsGroupHClass", IsGreensHClass);


#############################################################################
##
#A  EggBoxOfDClass( <Dclass> )
##
##  <#GAPDoc Label="EggBoxOfDClass">
##  <ManSection>
##  <Attr Name="EggBoxOfDClass" Arg='Dclass'/>
##
##  <Description>
##  returns for a Green's <M>D</M> class <A>Dclass</A> a matrix whose rows
##  represent <M>R</M> classes and columns represent <M>L</M> classes.
##  The entries are the <M>H</M> classes.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("EggBoxOfDClass", IsGreensDClass);


#############################################################################
##
#F  DisplayEggBoxOfDClass( <Dclass> )
##
##  <#GAPDoc Label="DisplayEggBoxOfDClass">
##  <ManSection>
##  <Func Name="DisplayEggBoxOfDClass" Arg='Dclass'/>
##
##  <Description>
##  displays a <Q>picture</Q> of the <M>D</M> class <A>Dclass</A>,
##  as an array of 1s and 0s.
##  A 1 represents a group <M>H</M> class.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("DisplayEggBoxOfDClass");


#######################
#######################

DeclareAttribute("InternalRepGreensRelation", IsGreensRelation);
DeclareAttribute("CanonicalGreensClass", IsGreensClass);
#JDM Should be IsTransformationSemigroup
DeclareOperation("DisplayEggBoxesOfSemigroup", [IsSemigroup]);


#############################################################################
##
#P  IsSemigroupGeneralMapping( <mapp> )
#P  IsSemigroupHomomorphism( <mapp> )
##
##  <ManSection>
##  <Prop Name="IsSemigroupGeneralMapping" Arg='mapp'/>
##  <Prop Name="IsSemigroupHomomorphism" Arg='mapp'/>
##
##  <Description>
##  A <E>semigroup general mapping</E> is a mapping which respects
##  multiplication.
##  If it is total and single valued it is called a
##  <E>semigroup homomorphism</E>.
##  </Description>
##  </ManSection>
##
DeclareSynonymAttr( "IsSemigroupGeneralMapping",
    IsSPGeneralMapping and IsGeneralMapping and RespectsMultiplication);

DeclareSynonymAttr( "IsSemigroupHomomorphism",
    IsSemigroupGeneralMapping and IsMapping);

DeclareRepresentation( "IsSemigroupGeneralMappingRep",
      IsSemigroupGeneralMapping and IsSPGeneralMapping and IsAttributeStoringRep, [] );

#DeclareSynonymAttr( "IsSemigroupGeneralMapping", IsGeneralMapping);
#DeclareSynonymAttr("IsSemigroupHomomorphism", IsSemigroupGeneralMapping and #RespectsMultiplication and IsTotal and IsSingleValued and #IsEndoGeneralMapping);


#############################################################################
##
#F  IsSemigroupHomomorphismByImagesRep( <mapp> )
##
##  <ManSection>
##  <Func Name="IsSemigroupHomomorphismByImagesRep" Arg='mapp'/>
##
##  <Description>
##  a <C>SemigroupHomomorphism</C> represented by a list of images of <E>all</E>
##  elements.
##  </Description>
##  </ManSection>
##

#JDM include IsSemigroupGeneralMappingRep?

DeclareRepresentation( "IsSemigroupHomomorphismByImagesRep", IsAttributeStoringRep, ["imgslist"] );

#############################################################################
##
#O  SemigroupHomomorphismByImagesNC( <mapp> )
##
##  <ManSection>
##  <Oper Name="SemigroupHomomorphismByImagesNC" Arg='mapp'/>
##
##  <Description>
##  returns a <C>SemigroupHomomorphism</C> represented by
##  <C>IsSemigroupHomomorphismByImagesRep</C>.
##  </Description>
##  </ManSection>
##
DeclareOperation("SemigroupHomomorphismByImagesNC", [IsSemigroup, IsSemigroup, IsList]);

#HACKS

DeclareProperty("IsFpSemigpReducedElt", IsElementOfFpSemigroup);
DeclareProperty("IsFpMonoidReducedElt", IsElementOfFpMonoid);

