#
# Tests for functions defined in src/ariths.c
#
gap> START_TEST("kernel/ariths.tst");

# InUndefined
gap> 1 in 2;
Error, operations: IN of integer and integer is not defined

#
# Test the various "VerboseFOO" handlers; to this end, create a mock family,
# category and type, and two instances of that, so that we can safely test all
# involved unary and binary operations
#
gap> fam := NewFamily("MockFamily");;
gap> cat := NewCategory("IsMockObj",
>               IsMultiplicativeElementWithInverse and
>               IsAdditiveElementWithInverse and
>               IsCommutativeElement and
>               IsAssociativeElement and
>               IsAdditivelyCommutativeElement);;
gap> type := NewType(fam, cat and IsPositionalObjectRep);;
gap> a := Objectify(type,[2]);;
gap> b := Objectify(type,[3]);;

# unary
gap> unary := [
>   Zero,
>   ZeroMutable,
>   AdditiveInverse,
>   AdditiveInverseMutable,
>   One,
>   OneMutable,
>   Inverse,
>   InverseMutable,
> ];;

# binary
gap> binary := [
>   \=,
>   \<,
>   \in,
>   \+,
>   \-,
>   \*,
>   \/,
>   LeftQuotient,
>   \^,
>   Comm,
>   \mod,
> ];;

#
# test with regular methods
#
gap> for m in unary do InstallMethod(m, [cat], ReturnTrue); od;
gap> for m in binary do InstallMethod(m, [cat, cat], ReturnTrue); od;
gap> InstallMethod(SetZeroImmutable, [cat, IsObject], ReturnNothing);
gap> InstallMethod(SetAdditiveInverseImmutable, [cat, IsObject], ReturnNothing);
gap> InstallMethod(SetOneImmutable, [cat, IsObject], ReturnNothing);
gap> InstallMethod(SetInverseImmutable, [cat, IsObject], ReturnNothing);

# ... and also involving TryNextMethod
gap> for m in unary do InstallMethod(m, [cat], 1, function(x) TryNextMethod(); end); od;
gap> for m in binary do InstallMethod(m, [cat, cat], 1, function(x,y) TryNextMethod(); end); od;

#
gap> Zero(a);
true
gap> ZeroMutable(a);
true
gap> -a;
true
gap> AdditiveInverseMutable(a);
true
gap> One(a);
true
gap> OneMutable(a);
true
gap> Inverse(a);
true
gap> InverseMutable(a);
true
gap> a = b;
true
gap> a < b;
true
gap> a in b;
true
gap> a + b;
true
gap> a - b;
true
gap> a * b;
true
gap> a / b;
true
gap> LeftQuotient(a, b);
true
gap> a ^ b;
true
gap> Comm(a, b);
true
gap> a mod b;
true

#
gap> meths := Concatenation(unary, binary);;
gap> TraceMethods(meths);

#
gap> Zero(a);
#I  ZeroImmutable at stream:1
#I Trying next: ZeroImmutable at stream:1
#I  SetZeroImmutable at stream:1
true
gap> ZeroMutable(a);
#I  ZeroMutable at stream:1
#I Trying next: ZeroMutable at stream:1
true
gap> -a;
#I  AdditiveInverseImmutable at stream:1
#I Trying next: AdditiveInverseImmutable at stream:1
#I  SetAdditiveInverseImmutable at stream:1
true
gap> AdditiveInverseMutable(a);
#I  AdditiveInverseMutable at stream:1
#I Trying next: AdditiveInverseMutable at stream:1
true
gap> One(a);
#I  OneImmutable at stream:1
#I Trying next: OneImmutable at stream:1
#I  SetOneImmutable at stream:1
true
gap> OneMutable(a);
#I  OneMutable at stream:1
#I Trying next: OneMutable at stream:1
true
gap> Inverse(a);
#I  InverseImmutable at stream:1
#I Trying next: InverseImmutable at stream:1
#I  SetInverseImmutable at stream:1
true
gap> InverseMutable(a);
#I  InverseMutable at stream:1
#I Trying next: InverseMutable at stream:1
true
gap> a = b;
#I  = at stream:1
#I Trying next: = at stream:1
true
gap> a < b;
#I  < at stream:1
#I Trying next: < at stream:1
true
gap> a in b;
#I  in at stream:1
#I Trying next: in at stream:1
true
gap> a + b;
#I  + at stream:1
#I Trying next: + at stream:1
true
gap> a - b;
#I  - at stream:1
#I Trying next: - at stream:1
true
gap> a * b;
#I  * at stream:1
#I Trying next: * at stream:1
true
gap> a / b;
#I  / at stream:1
#I Trying next: / at stream:1
true
gap> LeftQuotient(a, b);
true
gap> a ^ b;
#I  ^ at stream:1
#I Trying next: ^ at stream:1
true
gap> Comm(a, b);
#I  Comm at stream:1
#I Trying next: Comm at stream:1
true
gap> a mod b;
#I  mod at stream:1
#I Trying next: mod at stream:1
true

#
gap> UntraceMethods(meths);

#
# test "method should have returned a value" checks
#
gap> for m in unary do InstallMethod(m, [cat], 2, ReturnNothing); od;
gap> for m in binary do InstallMethod(m, [cat, cat], 2, ReturnNothing); od;

#
gap> Zero(a);
Error, Method for an attribute must return a value
gap> ZeroMutable(a);
Error, ZeroOp: method should have returned a value
gap> -a;
Error, Method for an attribute must return a value
gap> AdditiveInverseMutable(a);
Error, AdditiveInverseOp: method should have returned a value
gap> One(a);
Error, Method for an attribute must return a value
gap> OneMutable(a);
Error, OneOp: method should have returned a value
gap> Inverse(a);
Error, Method for an attribute must return a value
gap> InverseMutable(a);
Error, InvOp: method should have returned a value
gap> a = b;
false
gap> a < b;
false
gap> a in b;
false
gap> a + b;
Error, SUM: method should have returned a value
gap> a - b;
Error, DIFF: method should have returned a value
gap> a * b;
Error, PROD: method should have returned a value
gap> a / b;
Error, QUO: method should have returned a value
gap> LeftQuotient(a, b);
Error, LeftQuotient: method should have returned a value
gap> a ^ b;
Error, POW: method should have returned a value
gap> Comm(a, b);
Error, Comm: method should have returned a value
gap> a mod b;
Error, mod: method should have returned a value

#
gap> meths := Concatenation(unary, binary);;
gap> TraceMethods(meths);

#
gap> Zero(a);
#I  ZeroImmutable at stream:1
Error, Method for an attribute must return a value
gap> ZeroMutable(a);
#I  ZeroMutable at stream:1
Error, ZeroOp: method should have returned a value
gap> -a;
#I  AdditiveInverseImmutable at stream:1
Error, Method for an attribute must return a value
gap> AdditiveInverseMutable(a);
#I  AdditiveInverseMutable at stream:1
Error, AdditiveInverseOp: method should have returned a value
gap> One(a);
#I  OneImmutable at stream:1
Error, Method for an attribute must return a value
gap> OneMutable(a);
#I  OneMutable at stream:1
Error, OneOp: method should have returned a value
gap> Inverse(a);
#I  InverseImmutable at stream:1
Error, Method for an attribute must return a value
gap> InverseMutable(a);
#I  InverseMutable at stream:1
Error, InvOp: method should have returned a value
gap> a = b;
#I  = at stream:1
false
gap> a < b;
#I  < at stream:1
false
gap> a in b;
#I  in at stream:1
false
gap> a + b;
#I  + at stream:1
Error, SUM: method should have returned a value
gap> a - b;
#I  - at stream:1
Error, DIFF: method should have returned a value
gap> a * b;
#I  * at stream:1
Error, PROD: method should have returned a value
gap> a / b;
#I  / at stream:1
Error, QUO: method should have returned a value
gap> LeftQuotient(a, b);
Error, LeftQuotient: method should have returned a value
gap> a ^ b;
#I  ^ at stream:1
Error, POW: method should have returned a value
gap> Comm(a, b);
#I  Comm at stream:1
Error, Comm: method should have returned a value
gap> a mod b;
#I  mod at stream:1
Error, mod: method should have returned a value

#
gap> UntraceMethods(meths);

#
gap> STOP_TEST("kernel/ariths.tst", 1);
