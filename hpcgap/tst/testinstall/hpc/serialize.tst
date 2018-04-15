#
# Test the HPC-GAP serialization code
#

#
gap> CheckSerialization := function(x)
>   local err, x2;
>   x2 := DeserializeNativeString(SerializeToNativeString(x));
>   if TNUM_OBJ(x) <> TNUM_OBJ(x2) or x2 <> x then
>     err := "Serialization error: ";
>     Append(err, String(x));
>   fi;
> end;;
gap> CheckSerialization2 := function(x, f)
>   local err;
>   if not f(DeserializeNativeString(SerializeToNativeString(x))) then
>     err := "Serialization error: ";
>     Append(err, String(x));
>   fi;
> end;;

#
# integers (note that the serialization code switches behaviour
# depending on bit size: 5 bits (~32), 14 bits (~8192), or more
#
gap> for i in [-1000..1000] do CheckSerialization(i); od;
gap> for i in [8190, 8191, 8192, 8193, 2^30, 2^60, 2^100] do
>   CheckSerialization(i);
>   CheckSerialization(-i);
> od;

#
# rationals
#
gap> CheckSerialization(1/2);
gap> CheckSerialization(-1/2);

# verify numerator and denominator are stored correctly; in particular,
# that serialization didn't just encode the pointers, which of course
# would be invalid when deserializing in a different GAP session
# (previous versions of the serialization code had this bug).
gap> r1:=3^130/2^130;;
gap> str:=SerializeToNativeString(r1);;
gap> r2:=DeserializeNativeString(str);;
gap> IsIdenticalObj(NumeratorRat(r1), NumeratorRat(r2));
false
gap> IsIdenticalObj(DenominatorRat(r1), DenominatorRat(r2));
false

#
# cyclotomics
#
gap> CheckSerialization(E(3));
gap> CheckSerialization(E(3)+E(2));

#
# FFEs
#
gap> for q in Filtered([2..100], IsPrimePowerInt) do
>   CheckSerialization(Z(q));
> od;

#
# macfloats
#
gap> CheckSerialization(3.14);
gap> CheckSerialization(-3.14);
gap> CheckSerialization(+1.0/0.0); # inf
gap> CheckSerialization(-1.0/0.0); # -inf
gap> CheckSerialization(0.0/0.0); # -nan

#
# permutations
#
gap> CheckSerialization((1,2));
gap> CheckSerialization(());
gap> CheckSerialization((1,65537));
gap> CheckSerialization((1,65537)^2); # identity as T_PERM4

#
# TODO: transformations
#
gap> t:=Transformation( [ 10, 11 ],[ 11, 12 ] );;
gap> SerializeToNativeString(t);
Error, Cannot serialize object of type transformation (small)

#
# TODO: partial permutations
#
gap> p:=PartialPerm([1,5],[20,2]);;
gap> SerializeToNativeString(p);
Error, Cannot serialize object of type partial perm (small)

#
# booleans
#
gap> CheckSerialization(true);
gap> CheckSerialization(false);
gap> CheckSerialization(fail);

#
# chars
#
gap> for i in [0..255] do CheckSerialization(CHAR_INT(i)); od;

#
# records
#
gap> CheckSerialization(rec());
gap> CheckSerialization(rec(x := 1, y := "abc"));

#
# strings
#
gap> CheckSerialization("abc");
gap> CheckSerialization(MakeImmutable("abc"));

#
# ranges
#
gap> CheckSerialization([-2..2]);
gap> CheckSerialization([0,3..30]);

#
# blists
#
gap> CheckSerialization([true,false,true]);

#
# general lists
#
gap> for i in [-100..100] do CheckSerialization([i]); od;
gap> CheckSerialization([]);
gap> CheckSerialization(MakeImmutable([]));
gap> CheckSerialization(["abc", MakeImmutable("abc")]);
gap> CheckSerialization([1,2,,3,,,4,"x","y"]);
gap> CheckSerialization2([~], x->IsIdenticalObj(x, x[1]));
gap> CheckSerialization2(["abc", ~[1]], x->IsIdenticalObj(x[1], x[2]));

#
# object set
#
gap> CheckSerialization(OBJ_SET([]));
gap> CheckSerialization(OBJ_SET([17, -4, 17]));
gap> CheckSerialization(OBJ_SET([true, false]));

#
# object map
#
gap> CheckSerialization(OBJ_MAP([]));
gap> CheckSerialization(OBJ_MAP([17, -4, 21, 17]));
gap> CheckSerialization(OBJ_SET([false, 0, true, 1]));

#
# TODO: component object
#

#
# TODO: positional object
#
gap> x := ZmodnZObj(1,6);;
gap> TNAM_OBJ(x);
"object (positional)"
gap> SerializeToNativeString(x);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `SerializableRepresentation' on 1 arguments

#
# data object
#
gap> m:=IdentityMat(2,GF(2));
[ <a GF2 vector of length 2>, <a GF2 vector of length 2> ]
gap> IsDataObjectRep(m[1]);
true
gap> CheckSerialization(m);
gap> ConvertToMatrixRep(m);
2
gap> m;
<a 2x2 matrix over GF2>
gap> CheckSerialization(m);

#
gap> v:=ImmutableVector(GF(2),[1,0]*Z(2));
<an immutable GF2 vector of length 2>
gap> IsDataObjectRep(v);
true

# TODO: the following test fails! due to "equal" but not identical types
#gap> CheckSerialization(v);

#
# TODO: atomic component object
#
gap> G:=SymmetricGroup(3);;
gap> TNAM_OBJ(G);
"atomic component object"
gap> SerializeToNativeString(G);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `SerializableRepresentation' on 1 arguments

#
# TODO: atomic positional object
#

#
# input validation
#
gap> DeserializeNativeString("");
Error, Bad deserialization input
gap> DeserializeNativeString("\000");
Error, Bad deserialization input
gap> DeserializeNativeString("\000\377");
Error, Bad deserialization input
gap> DeserializeNativeString("\000\205");
1
