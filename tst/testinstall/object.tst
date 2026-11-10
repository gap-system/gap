#
# Tests for objectify
#
gap> START_TEST("object.tst");

# test some standard object types
# GAP code cannot create a kernel object, so retype a list
gap> r := [];; SET_TYPE_DATOBJ(r,TYPE_KERNEL_OBJECT);
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

# Objectify adds the base representation if the type lacks it
gap> fam := NewFamily("ObjectifyTestFamily");;
gap> type := NewType(fam, IsObject);;
gap> x := Objectify(type, []);;
gap> IsPositionalObjectRep(x); IsComponentObjectRep(x);
true
false
gap> y := Objectify(type, rec());;
gap> IsPositionalObjectRep(y); IsComponentObjectRep(y);
false
true

# ... and leaves the type alone otherwise
gap> type := NewType(fam, IsPositionalObjectRep);;
gap> IsIdenticalObj(TypeObj(Objectify(type, [])), type);
true
gap> type := NewType(fam, IsComponentObjectRep);;
gap> IsIdenticalObj(TypeObj(Objectify(type, rec())), type);
true

# Objectify rejects data which does not fit the type
gap> Objectify(NewType(fam, IsComponentObjectRep), []);
Error, <type> implies IsComponentObjectRep but <obj> requires IsPositionalObje\
ctRep
gap> Objectify(NewType(fam, IsPositionalObjectRep), rec());
Error, <type> implies IsPositionalObjectRep but <obj> requires IsComponentObje\
ctRep
gap> Objectify(TYPE_KERNEL_OBJECT, rec());
Error, <type> implies IsDataObjectRep but <obj> requires IsComponentObjectRep
gap> Objectify(NewType(fam, IsInternalRep), []);
Error, <type> implies IsInternalRep but <obj> requires IsPositionalObjectRep
gap> Objectify(NewType(fam, IsObject), 1);
Error, <obj> must be a list or a record
gap> Objectify(NewType(fam, IsObject), x);
Error, <obj> must be a list or a record
gap> STOP_TEST("object.tst");
