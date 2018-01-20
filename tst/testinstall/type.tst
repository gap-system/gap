#
gap> test := x -> List([IsFilter, IsCategory, IsRepresentation, IsAttribute, IsProperty, IsOperation], f -> f(x));;
gap> test(IsFinite);
[ true, false, false, false, true, true ]

#
gap> test(SetIsFinite);
[ false, false, false, false, false, true ]

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
gap> test(SetSize);
[ false, false, false, false, false, true ]

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
gap> test(Setter(IS_MUTABLE_OBJ));
[ false, false, false, false, false, true ]

#
gap> FilterByName("IsCommutative");
<Property "IsCommutative">
gap> CategoryByName("IsMagma");
<Category "IsMagma">

#
gap> atomic readonly FILTER_REGION do filters := Immutable(FILTERS); od;
gap> ForAll([1..Length(filters)], id -> id = IdOfFilter(filters[id]));
true

#
gap> TypeOfOperation(IsFilter);
Error, <oper> must be an operation

#
gap> TypeOfOperation(IsAbelian);
"Property"
gap> TypeOfOperation(HasIsAbelian);
"Filter"
gap> TypeOfOperation(SetIsAbelian);
"Setter"
gap> TypeOfOperation(IsMutable);
"Category"
gap> TypeOfOperation(\+);
"Operation"
gap> TypeOfOperation(Size);
"Attribute"
gap> TypeOfOperation(AbelianGroupCons);
"Constructor"
gap> TypeOfOperation(Setter(IS_MUTABLE_OBJ));
"Setter"

#
