#
# Tests for objectify
#
gap> START_TEST("object.tst");

# test some standard object types
gap> r := Objectify(TYPE_KERNEL_OBJECT, rec());
<kernel object>
gap> KnownAttributesOfObject(r);
[  ]
gap> KnownAttributesOfObject((1,2));
[  ]
gap> SortedList(KnownPropertiesOfObject((1,2)));
[ "CanEasilyCompareElements", "CanEasilySortElements" ]
gap> KnownAttributesOfObject([]);
[ "LENGTH" ]
gap> SortedList(KnownPropertiesOfObject([]));
[ "IS_SSORT_LIST", "IsDuplicateFree", "IsEmpty", "IsFinite", "IsNonTrivial", 
  "IsSmallList", "IsSortedList", "IsTrivial" ]
gap> SortedList(KnownTruePropertiesOfObject([]));
[ "IsDuplicateFree", "IsEmpty", "IsFinite", "IsNonTrivial", "IsSSortedList", 
  "IsSmallList", "IsSortedList" ]
gap> KnownAttributesOfObject([3,2]);
[ "LENGTH" ]
gap> SortedList(KnownPropertiesOfObject([3,2]));
[ "IsFinite", "IsSmallList" ]
gap> SortedList(KnownTruePropertiesOfObject([3,2]));
[ "IsFinite", "IsSmallList" ]
gap> SortedList(KnownAttributesOfObject(Group((1,2,3))));
[ "GeneratorsOfMagmaWithInverses", "MultiplicativeNeutralElement" ]

# Only check some members of these lists are they are too prone to change
gap> p := KnownPropertiesOfObject(Group((1,2,3)));;
gap> truep := KnownTruePropertiesOfObject(Group((1,2,3)));;
gap> ForAll(["IsEmpty", "IsTrivial" ], x -> (x in p and not x in truep));
true
gap> ForAll(["IsNonTrivial", "IsFinite"], x -> x in p and x in truep);
true
gap> SetName(p, 2);
Error, SetName: <name> must be a string
gap> STOP_TEST("object.tst");
