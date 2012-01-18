#############################################################################
##
#W  trans.gd                 GAP library                       Andrew Solomon
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for transformations
##
##  Further maintenance and development by:
##    Andrew Solomon
##    Robert F. Morse


##  <#GAPDoc Label="[1]{trans}"> 
##  A <E>transformation</E> in &GAP; is an endomorphism of a set of integers
##  of the form <M>\{ 1, \ldots, n \}</M>.
##  Transformations are taken to act on the right, which defines the
##  composition <M>i^{(\alpha \beta)} = (i^\alpha)^\beta</M>
##  for <M>i</M> in <M>\{ 1, \ldots, n \}</M>.
##  <P/>
##  For a transformation <M>\alpha</M> on the set <M>\{ 1, \ldots, n \}</M>,
##  we define its <E>degree</E> to be <M>n</M>,
##  its <E>image list</E> to be the list
##  <M>[1 \alpha, \ldots, n \alpha]</M>, its <E>image</E> to be the image 
##  list considered as a set,
##  and its <E>rank</E> to be the size of the image.
##  We also define the <E>kernel</E> of <M>\alpha</M> to be the
##  equivalence relation containing the pair <M>(i, j)</M> if and only if
##  <M>i^\alpha = j^\alpha</M>.
##  <P/>
##  Note that unlike permutations, we do not consider
##  unspecified points to be fixed by a transformation.
##  Therefore multiplication is only defined on two transformations of the same
##  degree.
##  <#/GAPDoc>
##

############################################################################
##
#C  IsTransformation(<obj>)
#C  IsTransformationCollection(<obj>)
##
##  <#GAPDoc Label="IsTransformation">
##  <ManSection>
##  <Filt Name="IsTransformation" Arg='obj' Type='Category'/>
##  <Filt Name="IsTransformationCollection" Arg='obj' Type='Category'/>
##
##  <Description>
##  We declare it as <Ref Func="IsMultiplicativeElementWithOne"/> since
##  the identity automorphism of <M>\{ 1, \ldots, n \}</M> is a
##  multiplicative two sided identity for any transformation on the same set.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategory("IsTransformation", 
	IsMultiplicativeElementWithOne and IsAssociativeElement);
DeclareCategoryCollections("IsTransformation");

############################################################################
##
#R  IsTransformationRep(<obj>)
##
##  <ManSection>
##  <Filt Name="IsTransformationRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  A transformation is an endomorphism of a set of integers
##  of the form <C>[1 .. n]</C>. 
##  <P/>
##  A transformation is completely specified by a list of images
##  the ith element is the image of i under the transformation.
##  </Description>
##  </ManSection>
##
DeclareRepresentation("IsTransformationRep", IsPositionalObjectRep ,[1]);

#############################################################################
##
#F  Transformation(<images>)
#F  TransformationNC(<images>)
##
##  <#GAPDoc Label="Transformation">
##  <ManSection>
##  <Func Name="Transformation" Arg='images'/>
##  <Func Name="TransformationNC" Arg='images'/>
##
##  <Description>
##  both return a transformation with the image list <A>images</A>.
##  The first version checks that the all the elements of the given list
##  lie within the range <M>\{ 1, \ldots, n \}</M> where <M>n</M> is
##  the length of <A>images</A>,
##  but for speed purposes, a non-checking version is also supplied.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("Transformation");
DeclareGlobalFunction("TransformationNC");

#############################################################################
##
#F  IdentityTransformation(<n>)
##
##  <#GAPDoc Label="IdentityTransformation">
##  <ManSection>
##  <Func Name="IdentityTransformation" Arg='n'/>
##
##  <Description>
##  returns the identity transformation of degree <A>n</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction("IdentityTransformation");

#############################################################################
##
#F  RandomTransformation(<n>)
##
##  <#GAPDoc Label="RandomTransformation">
##  <ManSection>
##  <Func Name="RandomTransformation" Arg='n'/>
##
##  <Description>
##  returns a random transformation of degree <A>n</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("RandomTransformation", 
    [IsPosInt]);

############################################################################
##
#A  DegreeOfTransformation(<trans>)
##
##  <#GAPDoc Label="DegreeOfTransformation">
##  <ManSection>
##  <Attr Name="DegreeOfTransformation" Arg='trans'/>
##
##  <Description>
##  returns the degree of <A>trans</A>.
##  <Example><![CDATA[
##  gap> t:= Transformation([2, 3, 4, 2, 4]);
##  Transformation( [ 2, 3, 4, 2, 4 ] )
##  gap> DegreeOfTransformation(t);
##  5
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("DegreeOfTransformation", IsTransformation);

#############################################################################
##
#A  ImageListOfTransformation(<trans>)
##
##  <#GAPDoc Label="ImageListOfTransformation">
##  <ManSection>
##  <Attr Name="ImageListOfTransformation" Arg='trans'/>
##
##  <Description>
##  returns the image list of <A>trans</A>.
##  <Example><![CDATA[
##  gap> ImageListOfTransformation(t);
##  [ 2, 3, 4, 2, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("ImageListOfTransformation", IsTransformation);

#############################################################################
##
#A  ImageSetOfTransformation(<trans>)
##
##  <#GAPDoc Label="ImageSetOfTransformation">
##  <ManSection>
##  <Attr Name="ImageSetOfTransformation" Arg='trans'/>
##
##  <Description>
##  returns the image of <A>trans</A> as a set.
##  <Example><![CDATA[
##  gap> ImageSetOfTransformation(t);
##  [ 2, 3, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("ImageSetOfTransformation", IsTransformation);

#############################################################################
##
#A  RankOfTransformation( <trans> )
##
##  <#GAPDoc Label="RankOfTransformation">
##  <ManSection>
##  <Attr Name="RankOfTransformation" Arg='trans'/>
##
##  <Description>
##  returns the rank of <A>trans</A>.
##  <Example><![CDATA[
##  gap> RankOfTransformation(t);
##  3
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("RankOfTransformation", IsTransformation);

#############################################################################
##
#A  KernelOfTransformation(<trans>)
##
##  <#GAPDoc Label="KernelOfTransformation">
##  <ManSection>
##  <Attr Name="KernelOfTransformation" Arg='trans'/>
##
##  <Description>
##  returns the kernel of <A>trans</A> as an equivalence relation,
##  see <Ref Sect="General Binary Relations"/>).
##  <Example><![CDATA[
##  gap> KernelOfTransformation(t);         
##  [ [ 1, 4 ], [ 2 ], [ 3, 5 ] ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute("KernelOfTransformation", IsTransformation);

#############################################################################
##
#O  PreimagesOfTransformation(<trans>, <i>)
##
##  <#GAPDoc Label="PreimagesOfTransformation">
##  <ManSection>
##  <Oper Name="PreimagesOfTransformation" Arg='trans, i'/>
##
##  <Description>
##  returns the subset of <M>\{ 1, \ldots, n \}</M>  which maps to <A>i</A>
##  under <A>trans</A>.
##  <Example><![CDATA[
##  gap> PreimagesOfTransformation(t, 2);
##  [ 1, 4 ]
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("PreimagesOfTransformation",[IsTransformation, IsInt]);

#############################################################################
##
#O  RestrictedTransformation(<trans>, <alpha>)
##
##  <#GAPDoc Label="RestrictedTransformation">
##  <ManSection>
##  <Oper Name="RestrictedTransformation" Arg='trans, alpha'/>
##
##  <Description>
##  The transformation <A>trans</A> is restricted to only those points of
##  <A>alpha</A>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("RestrictedTransformation", 
    [IsTransformation, IsListOrCollection]);

############################################################################
##
#O  AsTransformation( <O>[, <n>] )
#O  AsTransformationNC( <O>, <n> )
##
##  <#GAPDoc Label="AsTransformation">
##  <ManSection>
##  <Oper Name="AsTransformation" Arg='O[, n]'/>
##  <Oper Name="AsTransformationNC" Arg='O, n'/>
##
##  <Description>
##  returns the object <A>O</A> as a transformation.
##  Supported objects are permutations and binary relations on points.
##  Called with two arguments, the operation returns a transformation of
##  degree <A>n</A>,
##  signalling an error if such a representation is not possible.
##  <Ref Func="AsTransformationNC"/> does not perform this check.
##  <Example><![CDATA[
##  gap> AsTransformation((1, 3)(2, 4));
##  Transformation( [ 3, 4, 1, 2 ] )
##  gap> AsTransformation((1, 3)(2, 4), 10);
##  Transformation( [ 3, 4, 1, 2, 5, 6, 7, 8, 9, 10 ] )
##  ]]></Example>
##  <P/>
##  <Log><![CDATA[
##  gap> AsTransformation((1, 3)(2, 4), 3);
##  Error, Permutation moves points over the degree specified called from
##  <function>( <arguments> ) called from read-eval-loop
##  Entering break read-eval-print loop ...
##  you can 'quit;' to quit to outer loop, or
##  you can 'return;' to continue
##  brk> quit;
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("AsTransformation", [IsObject]);
DeclareOperation("AsTransformationNC", [IsObject]);
DeclareOperation("AsPermutation",[IsObject]);

############################################################################
##
#O  TransformationRelation( <R> )
##
##  <#GAPDoc Label="TransformationRelation">
##  <ManSection>
##  <Oper Name="TransformationRelation" Arg='R'/>
##
##  <Description>
##  returns the binary relation <A>R</A> when considered as a transformation.
##  Only makes sense for injective binary relations over <C>[1..n]</C>.
##  An error is signalled if the relation is not over <C>[1..n]</C>,
##  and <K>fail</K> if it is not injective.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("TransformationRelation", [IsGeneralMapping]);

#############################################################################
##
#O  BinaryRelationTransformation( <trans> )
##
##  <#GAPDoc Label="BinaryRelationTransformation">
##  <ManSection>
##  <Oper Name="BinaryRelationTransformation" Arg='trans'/>
##
##  <Description>
##  returns <A>trans</A> when considered as a binary relation.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("BinaryRelationTransformation", [IsTransformation]);

DeclareOperation("InverseOp", [IsTransformation]);


#############################################################################
##  
#O  PermLeftQuoTransformation(<tr1>, <tr2>)
##
##  <#GAPDoc Label="PermLeftQuoTransformation">
##  <ManSection>
##  <Oper Name="PermLeftQuoTransformation" Arg='tr1, tr2'/>
##
##  <Description>
##  Given transformations <A>tr1</A> and <A>tr2</A> with equal kernel and
##  image, we compute the permutation induced by
##  (<A>tr1</A>)<M>^{{-1}} *</M> <A>tr2</A> on the set of images of
##  <A>tr1</A>.
##  If the kernels and images are not equal, an error is signaled.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("PermLeftQuoTransformation", 
    [IsTransformation, IsTransformation]);

#############################################################################
##
#F  TransformationFamily(n) 
#F  TransformationType(n) 
#F  TransformationData(n)
##
##  <#GAPDoc Label="TransformationFamily">
##  <ManSection>
##  <Func Name="TransformationFamily" Arg='n'/>
##  <Func Name="TransformationType" Arg='n'/>
##  <Func Name="TransformationData" Arg='n'/>
##
##  <Description>
##  For each <C><A>n</A> > 0</C> there is a single family and type of
##  transformations on <A>n</A> points.
##  To speed things up, we store these in  a database of types.
##  The three functions above a then  access functions.
##  If the <A>n</A>th entry isn't yet created, they trigger creation as well.
##  <P/>
##  For <C><A>n</A> > 0</C>, element <A>n</A> of the type database is
##  <C>[TransformationFamily(</C><A>n</A><C>), TransformationType(</C><A>n</A><C>)]</C>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##

DeclareGlobalFunction("TransformationFamily");
DeclareGlobalFunction("TransformationType");
DeclareGlobalFunction("TransformationData");
_TransformationFamiliesDatabase := [];


#############################################################################
##
#E

