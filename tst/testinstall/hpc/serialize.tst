#@if IsHPCGAP
gap> START_TEST("hpc/serialize.tst");

#
# Test the HPC-GAP serialization code
#

#
gap> CheckSerializationGeneric := function(x, f)
>   local err, x2;
>   x2 := DeserializeNativeString(SerializeToNativeString(x));
>   if not f(x2) then
>     Error("Serialization error: ", x, " versus ", x2);
>   fi;
> end;;
gap> CheckSerializationBy := function(x, f)
>   CheckSerializationGeneric(x, y -> f(x) = f(y));
> end;;
gap> CheckSerialization := function(x)
>   CheckSerializationBy(x, y -> [TNUM_OBJ(y), y]);
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
gap> CheckSerializationBy(0.0/0.0, IsNaN); # -nan

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
Error, Cannot serialize objects of type transformation (small), tnum 9

#
# TODO: partial permutations
#
gap> p:=PartialPerm([1,5],[20,2]);;
gap> SerializeToNativeString(p);
Error, Cannot serialize objects of type partial perm (small), tnum 11

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
gap> CheckSerializationGeneric([~], x->IsIdenticalObj(x, x[1]));

#
# object set
#
gap> CheckSerializationBy(OBJ_SET([]), x->SortedList(OBJ_SET_VALUES(x)));
gap> CheckSerializationBy(OBJ_SET([17, -4, 17]), x->SortedList(OBJ_SET_VALUES(x)));
gap> CheckSerializationBy(OBJ_SET([true, false]), x->SortedList(OBJ_SET_VALUES(x)));

#
# object map
#
gap> cmp := function(x)
>   local keys, vals;
>   keys := OBJ_MAP_KEYS(x);
>   vals := OBJ_MAP_VALUES(x);
>   SortParallel(keys, vals);
>   return [keys, vals];
> end;;
gap> CheckSerializationBy(OBJ_MAP([]), cmp);
gap> CheckSerializationBy(OBJ_MAP([17, -4, 21, 17]), cmp);
gap> CheckSerializationBy(OBJ_MAP([false, 0, true, 1]), cmp);

#
# TODO: component object
#

#
# TODO: positional object
#
gap> x := ZmodnZObj(1,6);;
gap> TNAM_OBJ(x);
"positional object"
gap> SerializeToNativeString(x);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `SerializableRepresentation' on 1 argume\
nts

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
Error, no 1st choice method found for `SerializableRepresentation' on 1 argume\
nts

#
# TODO: atomic positional object
#

#
# input validation
#
gap> DeserializeNativeString("");
Error, ReadBytesNativeString: Bad deserialization input
gap> DeserializeNativeString("\000");
Error, ReadBytesNativeString: Bad deserialization input
gap> DeserializeNativeString("\000\377");
Error, DeserializeInt: Bad deserialization input (n = 255)
gap> DeserializeNativeString("\000\205");
1

#
# verify that stuff that gets serialized twice is
# deserialized into the same object each time
#
# FIXME: this is currently wrong for most TNUMs <= LAST_CONSTANT_TNUM
#
gap> CheckRepeatedSerialization := function(y)
>   CheckSerializationGeneric([y, y], x->IsIdenticalObj(x[1], x[2]));
>   CheckSerializationGeneric(rec(a:=y,b:=y), x->IsIdenticalObj(x.a, x.b));
> end;;
gap> CheckRepeatedSerialization(1); # T_INT
gap> CheckRepeatedSerialization(2^100); # T_INTPOS # FIXME buggy
Error, Serialization error: [ 1267650600228229401496703205376, 
  1267650600228229401496703205376 ] versus [ 1267650600228229401496703205376, 
  1267650600228229401496703205376 ]
gap> CheckRepeatedSerialization(-2^100); # T_INTNEG # FIXME buggy
Error, Serialization error: [ -1267650600228229401496703205376, 
  -1267650600228229401496703205376 ] versus 
[ -1267650600228229401496703205376, -1267650600228229401496703205376 ]
gap> CheckRepeatedSerialization(2/3); # T_RAT # FIXME buggy
Error, Serialization error: [ 2/3, 2/3 ] versus [ 2/3, 2/3 ]
gap> CheckRepeatedSerialization(E(4)); # T_CYC # FIXME buggy
Error, Serialization error: [ E(4), E(4) ] versus [ E(4), E(4) ]
gap> CheckRepeatedSerialization(Z(2)); # T_FFE
gap> CheckRepeatedSerialization(1.23); # T_MACFLOAT # FIXME buggy
Error, Serialization error: [ 1.23, 1.23 ] versus [ 1.23, 1.23 ]
gap> CheckRepeatedSerialization((1,2,3)); # T_PERM2 # FIXME buggy
Error, Serialization error: [ (1,2,3), (1,2,3) ] versus [ (1,2,3), (1,2,3) ]
gap> CheckRepeatedSerialization((80000,80001)); # T_PERM4 # FIXME buggy
Error, Serialization error: [ (80000,80001), (80000,80001) ] versus 
[ (80000,80001), (80000,80001) ]
gap> # TODO: T_TRANS2
gap> # TODO: T_TRANS4
gap> # TODO: T_PPERM2
gap> # TODO: T_PPERM4
gap> CheckRepeatedSerialization("abc"); # T_STRING
gap> CheckRepeatedSerialization([1,2,3]); # T_PLIST
#@fi

#
gap> STOP_TEST("hpc/serialize.tst", 1);
