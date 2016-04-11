#############################################################################
##
#W  trans.gd                 GAP library                       J. D. Mitchell
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2012 The GAP Group
##

# the documentation for the functions declared herein can be found in
# doc/ref/trans.xml

DeclareUserPreference(rec(
  name := ["TransformationDisplayLimit", "NotationForTransformations"],
  description := ["options for the display of transformations"],
  default := [100, "input"],
  check := function(a, b)
             return IsPosInt(a) or (IsString(b) and b in ["input", "fr"]);
           end)
);

DeclareOperation("Transformation", [IsList]);
DeclareOperation("Transformation", [IsList, IsList]);
DeclareOperation("TransformationListList", [IsList, IsList]);
DeclareOperation("TransformationList", [IsList]);
DeclareOperation("Transformation", [IsList, IsFunction]);

DeclareOperation("TransformationByImageAndKernel",
                 [IsCyclotomicCollection and IsDenseList,
                  IsCyclotomicCollection and IsDenseList]);

DeclareOperation("NumberTransformation", [IsTransformation, IsZeroCyc]);
DeclareOperation("NumberTransformation", [IsTransformation, IsPosInt]);
DeclareOperation("NumberTransformation", [IsTransformation]);
DeclareOperation("TransformationNumber", [IsPosInt, IsPosInt]);

DeclareAttribute("MovedPoints", IsTransformation);
DeclareAttribute("NrMovedPoints", IsTransformation);
DeclareAttribute("LargestMovedPoint", IsTransformation);
DeclareAttribute("LargestImageOfMovedPoint", IsTransformation);
DeclareAttribute("SmallestMovedPoint", IsTransformation);
DeclareAttribute("SmallestImageOfMovedPoint", IsTransformation);

DeclareAttribute("MovedPoints", IsTransformationCollection);
DeclareAttribute("NrMovedPoints", IsTransformationCollection);
DeclareAttribute("SmallestImageOfMovedPoint", IsTransformationCollection);
DeclareAttribute("LargestImageOfMovedPoint", IsTransformationCollection);
DeclareAttribute("LargestMovedPoint", IsTransformationCollection);
DeclareAttribute("SmallestMovedPoint", IsTransformationCollection);

DeclareAttribute("RankOfTransformation", IsTransformation);
DeclareOperation("RankOfTransformation", [IsTransformation, IsPosInt]);
DeclareOperation("RankOfTransformation", [IsTransformation, IsZeroCyc]);
DeclareOperation("RankOfTransformation", [IsTransformation, IsList]);

DeclareOperation("AsBinaryRelation", [IsTransformation]);
DeclareAttribute("AsPermutation", IsAssociativeElement);

DeclareAttribute("AsTransformation", IsAssociativeElement);
DeclareOperation("AsTransformation", [IsAssociativeElement, IsInt]);

DeclareOperation("ConstantTransformation", [IsPosInt, IsPosInt]);
DeclareAttribute("DegreeOfTransformationCollection",
                 IsTransformationCollection);
DeclareAttribute("FlatKernelOfTransformation", IsTransformation);
DeclareOperation("FlatKernelOfTransformation", [IsTransformation, IsPosInt]);
DeclareOperation("FlatKernelOfTransformation", [IsTransformation, IsZeroCyc]);

DeclareOperation("ImageListOfTransformation", [IsTransformation, IsPosInt]);
DeclareOperation("ImageListOfTransformation", [IsTransformation, IsZeroCyc]);
DeclareOperation("ImageListOfTransformation", [IsTransformation]);

DeclareSynonym("ListTransformation", ImageListOfTransformation);
DeclareAttribute("ImageSetOfTransformation", IsTransformation);
DeclareOperation("ImageSetOfTransformation", [IsTransformation, IsPosInt]);
DeclareOperation("ImageSetOfTransformation", [IsTransformation, IsZeroCyc]);

DeclareAttribute("KernelOfTransformation", IsTransformation);
DeclareOperation("KernelOfTransformation",
                 [IsTransformation, IsPosInt, IsBool]);
DeclareOperation("KernelOfTransformation", [IsTransformation, IsPosInt]);
DeclareOperation("KernelOfTransformation", [IsTransformation, IsZeroCyc]);
DeclareOperation("KernelOfTransformation", [IsTransformation, IsBool]);

DeclareOperation("PermLeftQuoTransformation",
                 [IsTransformation, IsTransformation]);
DeclareOperation("PreImagesOfTransformation", [IsTransformation, IsPosInt]);
DeclareSynonym("PreimagesOfTransformation", PreImagesOfTransformation);

DeclareOperation("RandomTransformation", [IsPosInt]);
DeclareOperation("RandomTransformation", [IsPosInt, IsPosInt]);

DeclareOperation("RestrictedTransformation", [IsTransformation, IsList]);
DeclareAttribute("SmallestIdempotentPower", IsAssociativeElement);
DeclareOperation("TrimTransformation", [IsTransformation, IsPosInt]);
DeclareOperation("TrimTransformation", [IsTransformation]);

DeclareOperation("Idempotent",
                 [IsCyclotomicCollection, IsCyclotomicCollection]);

DeclareOperation("TransformationOp", [IsObject, IsList, IsFunction]);
DeclareOperation("TransformationOp", [IsObject, IsDomain, IsFunction]);
DeclareOperation("TransformationOp", [IsObject, IsList]);
DeclareOperation("TransformationOp", [IsObject, IsDomain]);

DeclareOperation("TransformationOpNC", [IsObject, IsList, IsFunction]);
DeclareOperation("TransformationOpNC", [IsObject, IsDomain, IsFunction]);
DeclareOperation("TransformationOpNC", [IsObject, IsList]);
DeclareOperation("TransformationOpNC", [IsObject, IsDomain]);

DeclareAttribute("ComponentRepsOfTransformation", IsTransformation);
DeclareAttribute("NrComponentsOfTransformation", IsTransformation);
DeclareAttribute("ComponentsOfTransformation", IsTransformation);
DeclareOperation("ComponentTransformationInt", [IsTransformation, IsPosInt]);
DeclareOperation("CycleTransformationInt", [IsTransformation, IsPosInt]);
DeclareAttribute("CyclesOfTransformation", IsTransformation);
DeclareOperation("CyclesOfTransformation", [IsTransformation, IsList]);

DeclareAttribute("LeftOne", IsAssociativeElement);
DeclareAttribute("RightOne", IsAssociativeElement);
DeclareOperation("OnKernelAntiAction", [IsList, IsTransformation]);

BindGlobal("IdentityTransformation", TransformationNC([]));

# for legacy reasons only!
DeclareSynonym("BinaryRelationTransformation", AsBinaryRelation);
DeclareOperation("InverseOp", [IsTransformation]);

# not yet implemented
DeclareGlobalFunction("TransformationAction");
DeclareGlobalFunction("TransformationActionNC");
DeclareGlobalFunction("TransformationActionHomomorphism");
DeclareGlobalFunction("TransformationActionHomomorphismNC");
