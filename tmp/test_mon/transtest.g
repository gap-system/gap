s := SemigroupByMultiplicationTable([[1,2],[2,2]]);
MultiplicativeNeutralElement(s);    
i1 := IsomorphismTransformationSemigroup(s); 
Elements(Range(i1)); # should have degree 2
DegreeOfTransformation(Elements(Range(i1))[1]) = 2;

s := SemigroupByMultiplicationTable([[1,2],[2,2]]);
i1 := IsomorphismTransformationSemigroup(s); 
Elements(Range(i1)); # should have degree 3
DegreeOfTransformation(Elements(Range(i1))[1]) = 3;

#############################################
a := Transformation( [ 2, 3, 4, 5, 6, 1 ] );
b := Transformation([2,1,3,4,5,6]);
m := Monoid([a,b]);                
Elements(m);;
time;


# Using {} for multiplication 

InstallMethod(\*,
"trans * trans", IsIdenticalObj,
[IsTransformation and IsTransformationRep,
IsTransformation and IsTransformationRep], 0,
function(x, y)

  local
    a, b;

  a := ImageListOfTransformation(x);
  b := ImageListOfTransformation(y);

  return Transformation(b{a});

end);

#times :13500 14090 13540 13570


############ using List for multiplication.
InstallMethod(\*,
"trans * trans", IsIdenticalObj,
[IsTransformation and IsTransformationRep,
IsTransformation and IsTransformationRep], 0,
function(x, y)

  local
    a, b;

  a := ImageListOfTransformation(x);
  b := ImageListOfTransformation(y);

  return Transformation(List([1 .. Length(a)], x->b[a[x]]));

end);

#times: 10610 10110 10640 10640 
