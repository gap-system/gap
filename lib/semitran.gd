#############################################################################
##
#W  semitran.gd           GAP library         Isabel Araújo and Robert Arthur 
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for basics of transformation semigroup 
##


#############################################################################
##
#P  IsTransformationSemigroup( <obj> )
#P  IsTransformationMonoid( <obj> )
##
##  <#GAPDoc Label="IsTransformationSemigroup">
##  <ManSection>
##  <Prop Name="IsTransformationSemigroup" Arg='obj'/>
##  <Prop Name="IsTransformationMonoid" Arg='obj'/>
##
##  <Description>
##  A transformation semigroup (resp. monoid) is a subsemigroup
##  (resp. submonoid) of the full transformation monoid.
##  Note that for a transformation semigroup to be a transformation monoid
##  we necessarily require the identity transformation to be an element.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareSynonymAttr("IsTransformationSemigroup", IsSemigroup and
	IsTransformationCollection);
DeclareProperty("IsTransformationMonoid", IsTransformationSemigroup);

#############################################################################
##
#P  IsFullTransformationSemigroup(<obj>)
##
##  <#GAPDoc Label="IsFullTransformationSemigroup">
##  <ManSection>
##  <Prop Name="IsFullTransformationSemigroup" Arg='obj'/>
##
##  <Description>
##  checks whether <A>obj</A> is a full transformation semigroup.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareProperty("IsFullTransformationSemigroup", IsSemigroup);

#############################################################################
##
#F  FullTransformationSemigroup(<degree>)
##
##  <#GAPDoc Label="FullTransformationSemigroup">
##  <ManSection>
##  <Func Name="FullTransformationSemigroup" Arg='degree'/>
##
##  <Description>
##  Returns the full transformation semigroup of degree <A>degree</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("FullTransformationSemigroup");

#############################################################################
##
#A  DegreeOfTransformationSemigroup( <S> )
##
##  <#GAPDoc Label="DegreeOfTransformationSemigroup">
##  <ManSection>
##  <Attr Name="DegreeOfTransformationSemigroup" Arg='S'/>
##
##  <Description>
##  The number of points the semigroup <A>S</A> acts on.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("DegreeOfTransformationSemigroup",
	IsTransformationSemigroup);


############################################################################
##
#A  IsomorphismTransformationSemigroup(<S>)
#O  HomomorphismTransformationSemigroup(<S>,<r>)
##
##  <#GAPDoc Label="IsomorphismTransformationSemigroup">
##  <ManSection>
##  <Attr Name="IsomorphismTransformationSemigroup" Arg='S'/>
##  <Oper Name="HomomorphismTransformationSemigroup" Arg='S, r'/>
##
##  <Description>
##  <Ref Func="IsomorphismTransformationSemigroup"/> is a generic attribute
##  which is a transformation semigroup isomorphic to <A>S</A> (if such can 
##  be computed).
##  In the case of an fp-semigroup, a Todd-Coxeter approach
##  will be attempted. For a semigroup of endomorphisms of a finite 
##  domain of <M>n</M> elements, it will be to a semigroup of transformations
##  of <M>\{ 1, 2, \ldots, n \}</M>. Otherwise, it will be the right regular 
##  representation on <A>S</A> or <M><A>S</A>^1</M> if <A>S</A> has no 
##  multiplicative neutral element,
##  see <Ref Func="MultiplicativeNeutralElement"/>.
##  <P/>
##  <Ref Func="HomomorphismTransformationSemigroup"/>
##  finds a representation of <A>S</A> as transformations of the set of
##  equivalence classes of the right congruence <A>r</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("IsomorphismTransformationSemigroup",
  IsSemigroup);

DeclareOperation("HomomorphismTransformationSemigroup",
  [IsSemigroup,IsRightMagmaCongruence]);


#############################################################################
##
#E

