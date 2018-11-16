# Create a list-like object, to test functionality of GAP for objects which implement
# IsSmallList
gap> DeclareCategory("IsTestListObj", IsSmallList);;
gap> BindGlobal( "TestListObjFamily", NewFamily("TestListObjFamily") );;
gap> DeclareRepresentation( "IsTestListObjRep", IsTestListObj and IsComponentObjectRep, []);;
gap> BindGlobal( "TestListObjType", NewType(TestListObjFamily, IsTestListObjRep));;
gap> BindGlobal( "TestListObjTypeMutable", NewType(TestListObjFamily,
>                                        IsTestListObjRep and IsMutable));;
gap> wrap := {x} -> Objectify(TestListObjTypeMutable, rec(l := x));;
gap> InstallMethod(ViewString, [ IsTestListObjRep ], {x} -> STRINGIFY(x!.l));;
gap> InstallMethod(\[\], [ IsTestListObjRep, IsPosInt ], {x,i} -> x!.l[i]);;
gap> InstallMethod(\[\]\:\=, [ IsTestListObjRep and IsMutable, IsPosInt, IsObject ],
> function(x,i,o) x!.l[i] := o; end);
gap> InstallMethod( Length, [ IsTestListObjRep ], {x} -> Length(x!.l));
gap> InstallMethod( IsBound\[\], [ IsTestListObjRep, IsPosInt ], {x,i} -> IsBound(x!.l[i]));;
gap> x := [10,20,"cheese"];;
gap> y := [10,20,"cheese"];;
gap> a := wrap(x);;
gap> b := wrap(y);;
gap> a[2];
20
gap> a = b;
true
gap> a < b;
false
gap> a[2] := 15;
15
gap> x;
[ 10, 15, "cheese" ]
gap> a = b;
false
gap> a < b;
true
gap> Length(a);
3
gap> 1 in a;
false
gap> 10 in a;
true
gap> IsSet(a);
true
gap> IsSortedList(a);
true
gap> a[2] := 10;
10
gap> IsSet(a);
false
gap> IsSortedList(a);
true
gap> a[2] := 2;
2
gap> IsSet(a);
false
gap> IsSortedList(a);
false
gap> a;
[ 10, 2, "cheese" ]
gap> Sort(a);
gap> a;
[ 2, 10, "cheese" ]
gap> IsSet(a);
true
gap> x;
[ 2, 10, "cheese" ]
gap> SortBy(a, {z} -> z);
gap> a;
[ 2, 10, "cheese" ]
gap> SortParallel([3,2,1],a);
gap> a;
[ "cheese", 10, 2 ]
gap> l := [1,2,3];
[ 1, 2, 3 ]
gap> SortParallel(a,l);
gap> a;
[ 2, 10, "cheese" ]
gap> l;
[ 3, 2, 1 ]
gap> Unbind(x[2]);
gap> a;
[ 2,, "cheese" ]
gap> IsSet(a);
false
gap> IsSortedList(a);
false
