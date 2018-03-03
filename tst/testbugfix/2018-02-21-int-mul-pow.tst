# in the past, the kernel functions IsNegInt ProdIntObj and PowObjInt were
# applicable to almost arbitrary objects, which lead to some strange
# expressions being evaluated by GAP. Here we verify that these now produce
# errors instead.
gap> f:=x->x;;

#
gap> rec() ^ 1;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `^' on 2 arguments
gap> 'x' ^ 1;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `^' on 2 arguments
gap> [true] ^ 1;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `^' on 2 arguments
gap> f ^ 1;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `^' on 2 arguments

#
gap> 1 * Immutable(rec());
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `*' on 2 arguments
gap> 1 * 'x';
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `*' on 2 arguments
gap> 1 * [true];
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `*' on 2 arguments
gap> 1 * f;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `*' on 2 arguments

# the following always gave errors, but let's check them for completeness
gap> Immutable(rec()) * 1;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `*' on 2 arguments
gap> 'x' * 1;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `*' on 2 arguments
gap> [true] * 1;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `*' on 2 arguments
gap> f * 1;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `*' on 2 arguments

# in contrast, one can still power vectors by a positive integer, with the
# understanding that vec^1=vec, and vec^2 is the standard scalar product of
# the vector with itself, and larger powers are derived from this.
gap> [1..3]^1;
[ 1 .. 3 ]
gap> [1..3]^2;
14
gap> [1..3]^3;
[ 14, 28, 42 ]
gap> [1..3]^4;
196
gap> [1..3]^0;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 3rd choice method found for `OneSameMutability' on 1 arguments
gap> [1..3]^-1;
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 2nd choice method found for `InverseSameMutability' on 1 arguments

# multiplication of int*float and float*int used to behave inconsistently
gap> 10^400 * 10.^-300; # used to return 1.e+100
inf
gap> 10.^-300 * 10^400;
inf
