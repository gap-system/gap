#############################################################################
##
#W  trans.gi           GAP library                    Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementation for transformations
##

Revision.trans_gi :=
    "@(#)$Id$";

############################################################################
##
#R  IsTransformationRep(<obj>)
## 
##  A transformation is an endomorphism of a set of integers
##  of the form [1 .. n]. 
##
##  A transformation is completely specified by a list of images
##  the ith element is the image of i under the transformation.
##
DeclareRepresentation("IsTransformationRep", IsPositionalObjectRep ,[1]);


#############################################################################
##  
#F  Transformation(<images>) - create a Transformation in IsTransformationRep
#F  TransformationNC( <images> )
#A  ImageListOfTransformation(<trans>)
## 
##  <images> is a list of the images defining the element
##  These two notions are mutually inverse.
##
##  These two functions should be the only piece of representation
##  specific code.
## 

InstallGlobalFunction(Transformation,
function(images)
	local n, X, i;

	n := Length(images);
	#check that it is a transformation.
	X :=  [1 .. n];
	for i in X do
		if not images[i] in X then
			Error ("<images> does not describe a transformation");
		fi;
	od;

	return(Objectify(TransformationType(n), [Immutable(images)]));
end);

InstallGlobalFunction(TransformationNC,
function(images)
	return(Objectify(TransformationType(Length(images)), 
		[Immutable(images)]));
end);

InstallMethod(ImageListOfTransformation, 
"<trans>", true, 
[IsTransformation and IsTransformationRep], 0,
function(x)
  return x![1];
end);

#############################################################################
##
#A  ImageSetOfTransformation(<trans>)
##  
##  Returns the set of images of a transformation
##  
InstallMethod(ImageSetOfTransformation, 
"<trans>", true,
[IsTransformation], 0,
function(x) 
	return Set(ImageListOfTransformation(x));
end);



#############################################################################
##
#A  RankOfTransformation(<trans>)
##  
##   Size of image set
##  
InstallMethod(RankOfTransformation, 
"<trans>", true,
[IsTransformation], 0,
function(x) 
	return Size(Set(ImageListOfTransformation(x)));
end);


#############################################################################
##
#F  PreimagesOfTransformation(<trans>, <i>)
##  
##  subset of [1 .. n]  which maps to <i> under <trans>
##  
InstallMethod(PreimagesOfTransformation, 
"<trans>", true,
[IsTransformation, IsInt], 0,
function(x,i) 
	return Filtered([1 .. DegreeOfTransformation(x)], j->j^x =i);
end);


#############################################################################
##
#A  KernelOfTransformation(<trans>)
##  
##  Equivalence relation on [1 .. n] 
##  
InstallMethod(KernelOfTransformation, 
"<trans>", true,
[IsTransformation and IsTransformationRep], 0,
function(trans) 

	local ker, imgs, i, range, rel, typ;

    # initialize.
    ker:= []; imgs:= trans![1];
    for i in imgs do
        ker[i]:= [];
    od;

    range:= [1..Length(imgs)];

    # compute preimages.
    for i in range do
        Add(ker[imgs[i]], i);
    od;

    # create the kernel.
    return EquivalenceRelationByPartitionNC(range, ker);

end);


#############################################################################
##  
#F  TransformationFamily(n)
#F  TransformationType(n)
#F  TransformationData(n)
#V  _TransformationFamiliesDatabase
## 
##  For each n > 0 there is a single family and type of transformations
##  on n points. To speed things up, we store these in
##  _TransformationFamiliesDatabase. The three functions above a then
##  access functions. If the nth entry isn't yet created, they trigger
##  creation as well.
##
##  For n > 0, element n  of _TransformationFamiliesDatabase is
##  [TransformationFamily(n), TransformationType(n)]

InstallGlobalFunction(TransformationData,
function(n)
	local Fam;
	
	if (n <= 0) then
		Error ("Transformations must be on a positive number of points");
	fi;
	if IsBound(_TransformationFamiliesDatabase[n]) then
		return _TransformationFamiliesDatabase[n];
	fi;

	Fam := NewFamily(
		Concatenation("Transformations of the set [",String(n),"]"),
		IsTransformation);
	# Putting IsTransformation in the NewFamily means that when you make, 
	# say [a] it picks up the Category from the Family object and makes 
	# sure that [a] has CollectionsCategory(IsTransformation)

	_TransformationFamiliesDatabase[n] := 
		[Fam, NewType(Fam,IsTransformation and IsTransformationRep, n)];

	 return _TransformationFamiliesDatabase[n];
end);

InstallGlobalFunction(TransformationType,
function(n)
	return TransformationData(n)[2];
end);

InstallGlobalFunction(TransformationFamily,
function(n)
	return TransformationData(n)[1];
end);

############################################################################
##
#A  Print(<trans>)
##
##  Just print the list of images.
##

InstallMethod(PrintObj, "for transformations", true,
[IsTransformation], 0, 
function(x) 
	Print("Transformation( ",ImageListOfTransformation(x)," )");
end);

############################################################################
##
#A  DegreeOfTransformation(<trans>)
##
##  When a  transformation is an endomorphism of the set of integers
##  [1 .. n] its degree is n.
## 

InstallMethod(DegreeOfTransformation, "for a transformation", true, [IsTransformation and IsTransformationRep], 0, 
function(x)
	return  DataType(TypeObj(x));
end);

############################################################################
##
#M  <i> ^ <trans>
##
##  Image of a point under a transformation
## 
InstallOtherMethod(\^, 
"i ^ trans", true,
[IsInt, IsTransformation and IsTransformationRep], 0, 
function(i, x) 
	return x![1][i];
end);

############################################################################
##
#M	AsTransformation( <perm> )
##
#M	AsTransformation( <perm>, <n> )
#M	AsTransformationNC( <perm>, <n> )
##
##	returns the <perm> as a transformation.   In the second form, it
##  returns <perm> as a transformation of degree <n>, signalling an error
##  if <perm> moves points greater than <n>
##
InstallMethod(AsTransformation, "for a permutation", true,
	[IsPerm], 0,
		perm->TransformationNC(ListPerm(perm)));

InstallOtherMethod(AsTransformation, "for a permutation and degree", true,
	[IsPerm, IsPosInt], 0,
function(perm, n)
	if perm = () then
		return TransformationNC([1..n]);
	fi;
	if n < LargestMovedPoint(perm) then
		Error("Permutation moves points over the degree specified");
	fi;
	return TransformationNC(OnTuples([1..n], perm));
end);
InstallOtherMethod(AsTransformationNC, "for a permutation and degree", true,
	[IsPerm, IsPosInt], 0,
function(perm, n)
	return TransformationNC(OnTuples([1..n], perm));
end);

############################################################################
##
#M  TransformationRelation( <rel> )
##
InstallMethod(TransformationRelation, "for relation over [1..n]", true,
    [IsGeneralMapping], 0,
function(rel)
    local ims;

	if not IsEndoGeneralMapping(rel) then
		Error(rel, " is not a binary relation");
	fi;
    ims:= ImagesListOfBinaryRelation(rel);
    if not ForAll(ims, x->Length(x) = 1) then
        return fail;
    fi;

    return Transformation(List(ims, x->x[1]));
end);

#############################################################################
##
#M  BinaryRelationTransformation( <trans> )
##
InstallMethod( BinaryRelationTransformation, "for a transformation", true,
    [IsTransformation], 0,
        t->BinaryRelationByListOfImagesNC(
            List(ImageListOfTransformation(t), x->[x])));

############################################################################
##
#M  <trans> * <trans>
##
##  Can only multiply transformations of the same degree.
##  Note:  Transformations act on the right, so that i (a*b) = (i a)b,
##  or in functional notation, (a*b)(i) = b(a(i)), which is to say
##  that transformations act on the set [1 .. n] on the right.
## 

InstallMethod(\*, 
"trans * trans", IsIdenticalObj,
[IsTransformation and IsTransformationRep, 
IsTransformation and IsTransformationRep], 0, 
function(x, y) 
	local a,b;

	a:= x![1]; b := y![1];
	return TransformationNC(List([1 .. Length(a)], i -> b[a[i]]));
end);

############################################################################
##
#M  <trans> * <perm>
##
InstallMethod(\*, "trans * perm", true,
	[IsTransformation and IsTransformationRep, IsPerm], 0,
function(t, p)
	return t * AsTransformation(p, DegreeOfTransformation(t));
end);

############################################################################
##
#M  <perm> * <trans>
##
InstallMethod(\*, "trans * perm", true,
	[IsPerm, IsTransformation and IsTransformationRep], 0,
function(p, t)
	return AsTransformation(p, DegreeOfTransformation(t)) * t;
end);

############################################################################
##
#M  <map> * <trans>
##
InstallMethod( \*, "binary relation * trans", true,
    [IsGeneralMapping, IsTransformation], 0,
function(r, t)
    return r * BinaryRelationTransformation(t);
end);

############################################################################
##
#M  <trans> * <map>
##
InstallMethod( \*, "trans * binary relation", true,
    [IsTransformation, IsGeneralMapping], 0,
function(t, r)
    return BinaryRelationTransformation(t) * r;
end);


############################################################################
##
#M  <trans> < <trans>
##
##  Lexicographic ordering on image lists.
## 

InstallMethod(\<, 
"<trans> < <trans>", 
IsIdenticalObj,
[IsTransformation and IsTransformationRep, 
IsTransformation and IsTransformationRep], 0, 
function(x, y) 
	return x![1] < y![1];
end);



############################################################################
##
#M  One(<trans>)
##
##  The identity transformation on the set [1 .. n] where
##  n is the degree of <trans>.
## 

InstallMethod(One, 
"One(<trans>)", true,
[IsTransformation and IsTransformationRep], 0, 
function(x) 
	return TransformationNC([1 .. DegreeOfTransformation(x)]);
end);

############################################################################
##
#M  <trans> = <trans>
##
##  Two transformations are equal if their image lists are equal.
## 

InstallMethod(\=, "for two transformations of the same set", 
IsIdenticalObj,
[IsTransformation and IsTransformationRep, 
IsTransformation and IsTransformationRep], 0, 
function(x, y) 
	return  x![1] = y![1];
end);

