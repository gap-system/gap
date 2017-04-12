#
gap> test := x -> List([IsFilter, IsCategory, IsRepresentation, IsAttribute, IsProperty, IsOperation], f -> f(x));;
gap> test(IsFinite);
[ true, false, false, false, true, true ]

#
gap> test(IsMagma);
[ true, true, false, false, false, true ]

#
gap> test(IsCommutative);
[ true, false, false, false, true, true ]

#
gap> test(Size);
[ false, false, false, true, false, true ]

#
gap> test(Group);
[ false, false, false, false, false, false ]

#
gap> test((1,2,3));
[ false, false, false, false, false, false ]

#
gap> test("hello, world");
[ false, false, false, false, false, false ]

#
gap> FilterByName("IsCommutative");
<Property "IsCommutative">
gap> CategoryByName("IsMagma");
<Category "IsMagma">

#
gap> ForAll([1..Length(FILTERS)], id -> id = IdOfFilter(FILTERS[id]));
true
