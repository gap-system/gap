#############################################################################
##
#W trans.gd                                                 Laurent Bartholdi
##
#H   @(#)$Id: trans.gd,v 1.16 2011/06/20 14:14:31 gap Exp $
##
#Y Copyright (C) 2006, Laurent Bartholdi
##
#############################################################################
##
##  This file declares transformations with no fixed acting domain
##
#############################################################################

DeclareCategory("IsTrans", IsMultiplicativeElementWithInverse and IsAssociativeElement);
DeclareCategoryCollections("IsTrans");
DeclareSynonym("IsTransMonoid", IsMonoid and IsTransCollection);
DeclareSynonym("IsTransSemigroup", IsSemigroup and IsTransCollection);
BindGlobal("TRANS_FAMILY",
        NewFamily("TransformationsFamily",IsTrans,CanEasilySortElements,CanEasilySortElements));
BindGlobal("TYPE_TRANS",
        NewType(TRANS_FAMILY,IsTrans));

#############################################################################
##
#F Transformations
##
## <#GAPDoc Label="Trans">
## <ManSection>
##   <Fam Name="TRANS_FAMILY"/>
##   <Filt Name="IsTrans"/>
##   <Description>
##     The family and filter of transformations of the FR's implementation
##     of transformations on the positive integers, see <Ref Func="Trans"/>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="Trans" Arg="list,..."/>
##   <Func Name="TransList" Arg="list,..."/>
##   <Func Name="TransNC" Arg="list"/>
##   <Description>
##     This function creates a new transformation, in the family
##     <C>TRANS_FAMILY</C>. These objects behave quite as usual
##     transformations (see <Ref Func="Transformation" BookName="ref"/>); the
##     differences are that these transformations do not have a bounded
##     set on which they operate; they are all part of one family, and
##     act on <C>PosInt</C>. The other difference is that, when they are
##     invertible, these transformations are simply permutations.
##
##     <P/> If one argument is passed, it is a list of images, as in
##     <Ref Func="PermList" BookName="ref"/>. If two arguments are passed
##     and both are lists, they are the source and range, as in
##     <Ref Func="PermListList" BookName="ref"/>. Finally, if two arguments
##     are passed and the second is a function, the first argument is
##     treated as the source and the range is computed with this function.
##
##     <P/> Transformations are printed, and converted to strings, as
##     <C>"&lt;x,y,...&gt;"</C>, where the <C>x,y,...</C> denote the images
##     of <C>1,2,...</C> under the transformation; the shortest possible
##     list is printed.
## <Example><![CDATA[
## gap> Trans();
## <>
## gap> Trans([1,,2]);
## <1,2,2>
## gap> 3^last;
## 2
## gap> Trans([1,3,3]);
## <1,3>
## gap> Trans([10,11],[11,12]);
## <1,2,3,4,5,6,7,8,9,11,12>
## gap> Trans([10,11],x->x^2);
## <1,2,3,4,5,6,7,8,9,100,121>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="AsTrans" Arg="perm"/>
##   <Returns>An FR transformation equivalent to <A>perm</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Cycle" Arg="trans, point"/>
##   <Returns>The cycle of integers that <A>point</A> eventually reaches under <A>trans</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="Cycles" Arg="trans, domain, [act]"/>
##   <Returns>The cycles that <A>domain</A> eventually reaches under <A>trans</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="FullTransMonoid" Arg="n"/>
##   <Returns>The monoid of transformations of <C>[1..n]</C> (if <A>n</A> is an integer)
##   or of <A>n</A> (if <A>n</A> is a collection).</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="ImageSetOfTrans" Arg="trans, coll"/>
##   <Returns>The images of <A>coll</A> under <A>trans</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="KernelOfTrans" Arg="trans"/>
##   <Returns>The non-trivial equivalence classes of integers identified under <A>trans</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="ListTrans" Arg="trans"/>
##   <Returns>A list of images describing <A>trans</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Var Name="OneTrans"/>
##   <Description>The identity FR transformation.</Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="PreImagesOfTrans" Arg="trans, i"/>
##   <Returns>The preimages of <A>i</A> under <A>trans</A>.</Returns>
## </ManSection>
##
## <ManSection>
##   <Oper Name="RandomTrans" Arg="n"/>
##   <Returns>A random FR transformation on the fist <A>n</A> positive integers.</Returns>
## </ManSection>
##
## <ManSection>
##   <Func Name="RankOfTrans" Arg="trans [list]"/>
##   <Returns>The (normalized) rank of the FR transformation <A>trans</A>.</Returns>
##   <Description>
##     If <A>list</A> is present, this computes the size of the image of
##     <A>list</A> under <A>trans</A>. Otherwise, this computes the limit,
##     as <M>n\to\infty</M>, of <C>RankOfTrans(trans,[1..n])-n</C>.
## <Example><![CDATA[
## gap> RankOfTrans(Trans([1,1]));
## gap> RankOfTrans(Trans([1,1]),[1..10]);
## 9
## -1
## gap> RankOfTrans(Trans());
## 0
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="RestrictedTrans" Arg="trans, coll"/>
##   <Returns>The FR transformation that agrees with <A>trans</A> on <A>coll</A>, and is the identity elsewhere.</Returns>
## </ManSection>
## <#/GAPDoc>
##
DeclareGlobalFunction("Trans");
DeclareGlobalFunction("TransNC");
DeclareGlobalVariable("OneTrans");
DeclareOperation("RandomTrans", [IsPosInt]);
DeclareAttribute("LargestMovedPoint", IsTrans);
DeclareAttribute("SmallestMovedPoint", IsTrans);
DeclareAttribute("NrMovedPoints", IsTrans);
DeclareAttribute("MovedPoints", IsTrans);
DeclareAttribute("RankOfTrans", IsTrans);
DeclareOperation("RankOfTrans", [IsTrans, IsList]);
DeclareOperation("ImageSetOfTrans", [IsTrans, IsList]);
DeclareAttribute("KernelOfTrans", IsTrans);
DeclareOperation("PreImagesOfTrans",[IsTrans, IsInt]);
DeclareOperation("RestrictedTrans", [IsTrans, IsListOrCollection]);
DeclareAttribute("ListTrans", IsTrans);
DeclareAttribute("ListTrans", IsTransformation);
DeclareAttribute("ListTrans", IsPerm);
DeclareOperation("ListTrans", [IsTrans, IsInt]);
DeclareOperation("ListTrans", [IsTransformation, IsInt]);
DeclareOperation("ListTrans", [IsPerm, IsInt]);
DeclareAttribute("TransList", IsList);
DeclareOperation("AsTrans", [IsObject]);
DeclareOperation("AsTransformation",[IsTrans,IsPosInt]);
DeclareOperation("FullTransMonoid",[IsInt]);
DeclareOperation("FullTransMonoid",[IsList]);
DeclareProperty("IsFullTransMonoid",IsSemigroup);
#############################################################################

#E trans.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
