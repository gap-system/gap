#############################################################################
##
#W  tuples.gd                   GAP library                      Steve Linton
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
##  <Ref Func="IsDirectProductElement"/> is a subcategory of the meet of
##  <Ref Func="IsDenseList"/>,
##  <Ref Func="IsMultiplicativeElementWithInverse"/>,
##  <Ref Func="IsAdditiveElementWithInverse"/>,
##  and <Ref Func="IsCopyable"/>,
##  where the arithmetic operations (addition, zero, additive inverse,
##  multiplication, powering, one, inverse) are defined componentwise.
##  <P/>
##  Note that each of these operations will cause an error message if
##  its result for at least one component cannot be formed.
##  <P/>
##  For an object in the filter <Ref Func="IsDirectProductElement"/>,
##  <Ref Func="ShallowCopy"/> returns a mutable plain list with the same
##  entries.
##  The sum and the product of a direct product element and a list in
##  <Ref Func="IsListDefault"/> is the list of sums and products,
##  respectively.
##  The sum and the product of a direct product element and a non-list
##  is the direct product element of componentwise sums and products,
##  respectively.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory( "IsDirectProductElement",
        IsDenseList
    and IsCopyable
    and IsMultiplicativeElementWithInverse
    and IsAssociativeElement
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
#V  DIRECT_PRODUCT_ELEMENT_FAMILIES . . . all direct product element families
#V                                                             so far created
##
##  <ManSection>
##  <Var Name="DIRECT_PRODUCT_ELEMENT_FAMILIES"/>
##
##  <Description>
##  <Ref Var="DIRECT_PRODUCT_ELEMENT_FAMILIES"/> is a list whose <M>i</M>-th
##  component is a weak pointer object containing all currently known
##  families of <M>i+1</M> component direct product elements.
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable( "DIRECT_PRODUCT_ELEMENT_FAMILIES",
    "list, at position i the list of known i+1 component \
direct product elements families" );


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
#E

