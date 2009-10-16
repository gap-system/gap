a := (1,2,3,4);
g := Group(a);

s1 := GeneralMappingByElements(g, g, 
[Tuple([a^1, a^1]), Tuple([a^2, a^1]), Tuple([a^3, a^3]), Tuple([a^4, a^4])]); 
s1 := TransformationRepresentation(s1);

t1 := GeneralMappingByElements(g, g, 
[Tuple([a^1, a^2]), Tuple([a^2, a^2]), Tuple([a^3, a^3]), Tuple([a^4, a^4])]); 
t1 := TransformationRepresentation(t1);

s2 := GeneralMappingByElements(g, g, 
[Tuple([a^1, a^1]), Tuple([a^2, a^2]), Tuple([a^3, a^2]), Tuple([a^4, a^4])]); 
s2 := TransformationRepresentation(s2);

t2 := GeneralMappingByElements(g, g, 
[Tuple([a^1, a^1]), Tuple([a^2, a^3]), Tuple([a^3, a^3]), Tuple([a^4, a^4])]); 
t2 := TransformationRepresentation(t2);

s3 := GeneralMappingByElements(g, g, 
[Tuple([a^1, a^1]), Tuple([a^2, a^2]), Tuple([a^3, a^3]), Tuple([a^4, a^3])]); 
s3 := TransformationRepresentation(s3);

t3 := GeneralMappingByElements(g, g, 
[Tuple([a^1, a^1]), Tuple([a^2, a^2]), Tuple([a^3, a^4]), Tuple([a^4, a^4])]); 
t3 := TransformationRepresentation(t3);

o4 := Semigroup([s1,s2,s3,t1,t2,t3]);
Size(o4);
time; 

IsSimpleSemigroup(o4);
time; 


# sanity check:

for x in [s1,t1,s2,t2,s3,t3] do
	for y in [s1,t1,s2,t2,s3,t3] do
		for el in g do
			if el^(x*y) <> (el^x)^y then
				Error("action problem");
			fi;
		od;
	od;
od;



j := IsomorphismTransformationSemigroup(o4);
Elements(Range(j)); # the semigroup should have degree 4, not 34

