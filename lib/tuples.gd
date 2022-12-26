#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for direct product elements.
##
##  Direct product elements are immutable finite type-safe lists.
##


#############################################################################
##
#V  InfoDirectProductElements  . . . . . . . . . . . . . . . . . . Info Class
##
DeclareInfoClass( "InfoDirectProductElements" );


#############################################################################
##
#C  IsDirectProductElement( <obj> )  . .  category of direct product elements
##
##  <#GAPDoc Label="IsDirectProductElement">
##  <ManSection>
##  <Filt Name="IsDirectProductElement" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Ref Filt="IsDirectProductElement"/> is a subcategory of the meet of
##  <Ref Filt="IsDenseList"/>,
##  <Ref Filt="IsMultiplicativeElementWithInverse"/>,
##  <Ref Filt="IsAdditiveElementWithInverse"/>,
##  and <Ref Filt="IsCopyable"/>,
##  where the arithmetic operations (addition, zero, additive inverse,
##  multiplication, powering, one, inverse) are defined componentwise.
##  <P/>
##  Note that each of these operations will cause an error message if
##  its result for at least one component cannot be formed.
##  <P/>
##  For an object in the filter <Ref Filt="IsDirectProductElement"/>,
##  <Ref Oper="ShallowCopy"/> returns a mutable plain list with the same
##  entries.
##  The sum and the product of a direct product element and a list in
##  <Ref Filt="IsListDefault"/> is the list of sums and products,
##  respectively.
##  The sum and the product of a direct product element and an object
##  that is neither a list nor a collection
##  is the direct product element of componentwise sums and products,
##  respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsDirectProductElement",
        IsDenseList
    and IsSmallList
    and IsCopyable
    and IsMultiplicativeElementWithInverse
    and IsAdditiveElementWithInverse );


#############################################################################
##
#C  IsDirectProductElementFamily( <family> ) . . . category of direct product
#C                                                           element families
##
##  <ManSection>
##  <Filt Name="IsDirectProductElementFamily" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategoryFamily( "IsDirectProductElement" );


#############################################################################
##
#C  IsDirectProductElementCollection( <coll> )  .  category of direct product
#C                                                        element collections
##
##  <ManSection>
##  <Filt Name="IsDirectProductElementCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareCategoryCollections( "IsDirectProductElement" );


#############################################################################
##
#O  DirectProductElementsFamily( <famlist> ) . . . . family of direct product
#O                                                                   elements
##
##  <ManSection>
##  <Oper Name="DirectProductElementsFamily" Arg='famlist'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "DirectProductElementsFamily", [ IsCollection ] );


#############################################################################
##
#A  ComponentsOfDirectProductElementsFamily( <fam> )  . .  component families
##
##  <ManSection>
##  <Attr Name="ComponentsOfDirectProductElementsFamily" Arg='fam'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareAttribute( "ComponentsOfDirectProductElementsFamily",
    IsDirectProductElementFamily );


#############################################################################
##
#R  IsDefaultDirectProductElementRep( <obj> )  . . . . .  representation as a
#R                                                           component object
##
DeclareRepresentation( "IsDefaultDirectProductElementRep",
    IsPositionalObjectRep and IsDirectProductElement, [] );


#############################################################################
##
#V  EmptyDirectProductElementsFamily
##
BindGlobal( "EmptyDirectProductElementsFamily",
    NewFamily( "DirectProductElementsFamily([])", IsDirectProductElement,
               IsDirectProductElement ) );


#############################################################################
##
#O  DirectProductElement( [<fam>, ]<objlist> )
#O  DirectProductElementNC( <fam>, <objlist> )  . . . . omits check on object
#O                                                families and objlist length
##
##  <ManSection>
##  <Oper Name="DirectProductElement" Arg='[fam, ]objlist'/>
##  <Oper Name="DirectProductElementNC" Arg='fam, objlist'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareOperation( "DirectProductElement", [ IsList ]);
DeclareOperation( "DirectProductElementNC",
    [ IsDirectProductElementFamily, IsList ]);


#############################################################################
##
##
##  <#GAPDoc Label="DirectProductFamily">
##  <ManSection>
##  <Func Name="DirectProductFamily" Arg='args'/>
##
##  <Description>
##  <A>args</A> must be a dense list of <Ref Attr="CollectionsFamily"/>
##  families, otherwise the function raises an error.
##  <P/>
##  <Ref Func="DirectProductFamily"/> returns <C>fam</C>, a collections
##  family of <Ref Filt="IsDirectProductElement"/> objects.
##  <P/>
##  <C>fam</C> is the <Ref Attr="CollectionsFamily"/> of
##  <Ref Filt="IsDirectProductElement"/> objects
##  whose <C>i</C>-th component is in <C>ElementsFamily(args[i])</C>.
##  <P/>
##  Note that a collection in <C>fam</C> may not itself be a
##  direct product; it just is a subcollection of a direct product.
##  <P/>
##  <Example><![CDATA[
##  gap> D8 := DihedralGroup(IsPermGroup, 8);;
##  gap> FamilyObj(D8) = CollectionsFamily(PermutationsFamily);
##  true
##  gap> fam := DirectProductFamily([FamilyObj(D8), FamilyObj(D8)]);;
##  gap> ComponentsOfDirectProductElementsFamily(ElementsFamily(fam));
##  [ <Family: "PermutationsFamily">, <Family: "PermutationsFamily"> ]
##  ]]></Example>
##  Also note that not all direct products in &GAP; are created via these
##  families. For example if the arguments to <Ref Func="DirectProduct"/>
##  are permutation groups, then it returns a permutation group as well, whose
##  elements are not <Ref Filt="IsDirectProductElement"/> objects.
##  <P/>
##  <Example><![CDATA[
##  gap> fam = FamilyObj(DirectProduct(D8, D8));
##  false
##  gap> D4 := DihedralGroup(IsPcGroup, 4);;
##  gap> fam2 := DirectProductFamily([FamilyObj(D8), FamilyObj(D4)]);;
##  gap> fam2 = FamilyObj(DirectProduct(D8, D4));
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction( "DirectProductFamily" );
