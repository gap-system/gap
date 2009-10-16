#############################################################################
##
#W trans.gd                                                 Laurent Bartholdi
##
#H   @(#)$Id: trans.gd,v 1.13 2009/03/27 19:28:53 gap Exp $
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
##   <Func Name="Trans" Arg="list,..."/>
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
DeclareAttribute("ImageSetOfTrans", IsTrans);
DeclareAttribute("KernelOfTrans", IsTrans);
DeclareOperation("PreimagesOfTrans",[IsTrans, IsInt]);
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
DeclareOperation("PermLeftQuoTrans", [IsTrans, IsTrans]);
DeclareOperation("FullTransMonoid",[IsInt]);
DeclareOperation("FullTransMonoid",[IsList]);
DeclareProperty("IsFullTransMonoid",IsSemigroup);
#############################################################################

#E trans.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
