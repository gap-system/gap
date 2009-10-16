Revision.("monoid/gap/monoid_g") :=
    "@(#)$Id: monoid.g,v 1.1 1998/10/19 16:51:28 andrews Exp $";


# This file is andrew.g with a whole lot of stuff removed because the
# relevant functionality is  inherited.

DeclareCategory("IsTransformation", IsMultiplicativeElementWithOne);
DeclareRepresentation("IsTransformationRep",IsPositionalObjectRep,[1]);

DeclareGlobalFunction("Transformation");
DeclareGlobalFunction("TransformationFamily");
DeclareGlobalFunction("TransformationType");
DeclareGlobalFunction("TransformationData");

InstallGlobalFunction(Transformation,
function(images)
#images is a list of the images of the element as an endo function of [len(images)]
	local n, X, i;

	n := Length(images);
	#check that it is a transformation.
	X :=  [1 .. n];
	for i in X do
		if not images[i] in X then
			Error ("This isn't a transformation");
		fi;
	od;

	return(Objectify(TransformationType(n), [images]));

end
);



# For n > 0, element n is [Family of transformations of n points, Type of transformations of n points]

#DeclareGlobalVariable("_TransformationFamiliesDatabase", "Holds for each n [family_n, type_n] for transformations of n points");
#InstallValue("_TransformationFamiliesDatabase", []);
_TransformationFamiliesDatabase := [];

InstallGlobalFunction(TransformationData,
function(n)

	local Fam;

	
	if (n <= 0) then
		Error ("Transformations must be on a positive number of points");
	fi;
	if IsBound(_TransformationFamiliesDatabase[n]) then
		return _TransformationFamiliesDatabase[n];
	fi;
	Fam := NewFamily(Concatenation("Transformations of the set [",String(n),"]"),IsTransformation);
	# Putting IsTransformation in the NewFamily means that when you make, say [a] it 
	# picks up the Category from the Family object and makes sure that [a] has CollectionsCategory(IsTransformation)
	_TransformationFamiliesDatabase[n] := [Fam, NewType(Fam,IsTransformation and IsTransformationRep, n)];
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

InstallMethod(PrintObj, "for transformations", true,
[IsTransformation and IsTransformationRep], 0, 
function(x) 
	Print(x![1]);
end);

InstallMethod(Degree, "for a transformation", true, [IsTransformation and IsTransformationRep], 0, 
function(x)
	local a; # the list of images
	a := x![1];
	return Length(a);
end);

InstallMethod(\*, "for two transformations of the same set", IsIdenticalObj,
[IsTransformation and IsTransformationRep, IsTransformation and IsTransformationRep], 0, 
function(x, y) 
	local a,b;

	a := x![1]; b := y![1];
	return Transformation(List([1 .. Length(a)], i -> b[a[i]]));
end);

InstallMethod(\<, "for two transformations of the same set", IsIdenticalObj,
[IsTransformation and IsTransformationRep, IsTransformation and IsTransformationRep], 0, 
function(x, y) 
	local a,b, i;

	a := x![1]; b := y![1];


	for i in [1 .. Length(a)] do
		if (a[i] < b[i]) then
			return true;
		fi;
		if (a[i] > b[i]) then
			return false;
		fi;
	od;
	return false;
end);




InstallMethod(One, "for transformations", true,
[IsTransformation and IsTransformationRep], 0, 
function(x) 


	return Transformation([1 .. Degree(x)]);
end);


InstallMethod(\=, "for two transformations of the same set", IsIdenticalObj,
[IsTransformation and IsTransformationRep, IsTransformation and IsTransformationRep], 0, 
function(x, y) 
	local a,b, i;

	a := x![1]; b := y![1];


	for i in [1 .. Length(a)] do
		if not(a[i] = b[i]) then
			return false;
		fi;
	od;
	return true;
end);


#Transformation Monoid section

IsTransformationsColl := CategoryCollections(IsTransformation);
IsTransformationMonoid := IsTransformationsColl and IsMonoid;

