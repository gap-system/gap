#2016/5/2 (MP)
gap> S := FullTransformationMonoid(2);;
gap> D := GreensDClassOfElement(S, IdentityTransformation);;
gap> Intersection(D, []);
[  ]
gap> Intersection([], D);
[  ]
