#
# Tests for functions defined in src/ariths.c
#
gap> START_TEST("kernel/ariths.tst");

# InUndefined
gap> 1 in 2;
Error, operations: IN of integer and integer is not defined

# SUM, DIFF, PROD, QUO
gap> SUM(1,1);
2
gap> DIFF(1,1);
0
gap> PROD(1,1);
1
gap> QUO(1,1);
1
gap> MOD(1,1);
0

#
# suppress paths in trace output
#
gap> old_VMETHOD_PRINT_INFO:=VMETHOD_PRINT_INFO;;
gap> old_NEXT_VMETHOD_PRINT_INFO:=NEXT_VMETHOD_PRINT_INFO;;
gap> MakeReadWriteGlobal("VMETHOD_PRINT_INFO");
gap> MakeReadWriteGlobal("NEXT_VMETHOD_PRINT_INFO");
gap> VMETHOD_PRINT_INFO:=function(methods, i, arity)
>     local offset;
>     offset := (arity+BASE_SIZE_METHODS_OPER_ENTRY)*(i-1)+arity;
>     Print("#I  ", methods[offset+4]);
>     Print("\n");
> end;;
gap> NEXT_VMETHOD_PRINT_INFO:=function(methods, i, arity)
>     local offset;
>     offset := (arity+BASE_SIZE_METHODS_OPER_ENTRY)*(i-1)+arity;
>     Print("#I Trying next: ", methods[offset+4]);
>     Print("\n");
> end;;

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
>   ZeroSameMutability,
>   AdditiveInverse,
>   AdditiveInverseMutable,
>   AdditiveInverseSameMutability,
>   One,
>   OneMutable,
>   OneSameMutability,
>   Inverse,
>   InverseMutable,
>   InverseSameMutability,
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
gap> 0*a;
true
gap> Zero(a);
true
gap> ZeroMutable(a);
true
gap> ZeroSameMutability(a);
true
gap> -a;
true
gap> AdditiveInverse(a);
true
gap> AdditiveInverseMutable(a);
true
gap> AdditiveInverseSameMutability(a);
true
gap> a^0;
true
gap> One(a);
true
gap> OneMutable(a);
true
gap> OneSameMutability(a);
true
gap> a^-1;
true
gap> Inverse(a);
true
gap> InverseMutable(a);
true
gap> InverseSameMutability(a);
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
gap> 0*a;
#I  *: zero integer * additive element with zero
#I  ZeroSameMutability
#I Trying next: ZeroSameMutability
true
gap> Zero(a);
#I  ZeroImmutable
#I Trying next: ZeroImmutable
#I  SetZeroImmutable
true
gap> ZeroMutable(a);
#I  ZeroMutable
#I Trying next: ZeroMutable
true
gap> ZeroSameMutability(a);
#I  ZeroSameMutability
#I Trying next: ZeroSameMutability
true
gap> -a;
#I  AdditiveInverseSameMutability
#I Trying next: AdditiveInverseSameMutability
true
gap> AdditiveInverse(a);
#I  AdditiveInverseImmutable
#I Trying next: AdditiveInverseImmutable
#I  SetAdditiveInverseImmutable
true
gap> AdditiveInverseMutable(a);
#I  AdditiveInverseMutable
#I Trying next: AdditiveInverseMutable
true
gap> AdditiveInverseSameMutability(a);
#I  AdditiveInverseSameMutability
#I Trying next: AdditiveInverseSameMutability
true
gap> a^0;
#I  ^: for mult. element-with-one, and zero
#I  OneSameMutability
#I Trying next: OneSameMutability
true
gap> One(a);
#I  OneImmutable
#I Trying next: OneImmutable
#I  SetOneImmutable
true
gap> OneMutable(a);
#I  OneMutable
#I Trying next: OneMutable
true
gap> OneSameMutability(a);
#I  OneSameMutability
#I Trying next: OneSameMutability
true
gap> a^-1;
#I  ^: for mult. element-with-inverse, and negative integer
#I  InverseSameMutability
#I Trying next: InverseSameMutability
true
gap> Inverse(a);
#I  InverseImmutable
#I Trying next: InverseImmutable
#I  SetInverseImmutable
true
gap> InverseMutable(a);
#I  InverseMutable
#I Trying next: InverseMutable
true
gap> InverseSameMutability(a);
#I  InverseSameMutability
#I Trying next: InverseSameMutability
true
gap> a = b;
#I  =
#I Trying next: =
true
gap> a < b;
#I  <
#I Trying next: <
true
gap> a in b;
#I  in
#I Trying next: in
true
gap> a + b;
#I  +
#I Trying next: +
true
gap> a - b;
#I  -
#I Trying next: -
true
gap> a * b;
#I  *
#I Trying next: *
true
gap> a / b;
#I  /
#I Trying next: /
true
gap> LeftQuotient(a, b);
true
gap> a ^ b;
#I  ^
#I Trying next: ^
true
gap> Comm(a, b);
#I  Comm
#I Trying next: Comm
true
gap> a mod b;
#I  mod
#I Trying next: mod
true

#
gap> UntraceMethods(meths);

#
# test "method should have returned a value" checks
#
gap> for m in unary do InstallMethod(m, [cat], 2, ReturnNothing); od;
gap> for m in binary do InstallMethod(m, [cat, cat], 2, ReturnNothing); od;

#
gap> 0*a;
Error, ZEROOp: method should have returned a value
gap> Zero(a);
Error, Method for an attribute must return a value
gap> ZeroMutable(a);
Error, ZeroOp: method should have returned a value
gap> ZeroSameMutability(a);
Error, ZEROOp: method should have returned a value
gap> -a;
Error, AInvOp: method should have returned a value
gap> AdditiveInverse(a);
Error, Method for an attribute must return a value
gap> AdditiveInverseMutable(a);
Error, AdditiveInverseOp: method should have returned a value
gap> AdditiveInverseSameMutability(a);
Error, AInvOp: method should have returned a value
gap> a^0;
Error, ONEOp: method should have returned a value
gap> One(a);
Error, Method for an attribute must return a value
gap> OneMutable(a);
Error, OneOp: method should have returned a value
gap> OneSameMutability(a);
Error, ONEOp: method should have returned a value
gap> a^-1;
Error, INVOp: method should have returned a value
gap> Inverse(a);
Error, Method for an attribute must return a value
gap> InverseMutable(a);
Error, InvOp: method should have returned a value
gap> InverseSameMutability(a);
Error, INVOp: method should have returned a value
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
gap> 0*a;
#I  *: zero integer * additive element with zero
#I  ZeroSameMutability
Error, ZEROOp: method should have returned a value
gap> Zero(a);
#I  ZeroImmutable
Error, Method for an attribute must return a value
gap> ZeroMutable(a);
#I  ZeroMutable
Error, ZeroOp: method should have returned a value
gap> ZeroSameMutability(a);
#I  ZeroSameMutability
Error, ZEROOp: method should have returned a value
gap> -a;
#I  AdditiveInverseSameMutability
Error, AInvOp: method should have returned a value
gap> AdditiveInverse(a);
#I  AdditiveInverseImmutable
Error, Method for an attribute must return a value
gap> AdditiveInverseMutable(a);
#I  AdditiveInverseMutable
Error, AdditiveInverseOp: method should have returned a value
gap> AdditiveInverseSameMutability(a);
#I  AdditiveInverseSameMutability
Error, AInvOp: method should have returned a value
gap> a^0;
#I  ^: for mult. element-with-one, and zero
#I  OneSameMutability
Error, ONEOp: method should have returned a value
gap> One(a);
#I  OneImmutable
Error, Method for an attribute must return a value
gap> OneMutable(a);
#I  OneMutable
Error, OneOp: method should have returned a value
gap> OneSameMutability(a);
#I  OneSameMutability
Error, ONEOp: method should have returned a value
gap> a^-1;
#I  ^: for mult. element-with-inverse, and negative integer
#I  InverseSameMutability
Error, INVOp: method should have returned a value
gap> Inverse(a);
#I  InverseImmutable
Error, Method for an attribute must return a value
gap> InverseMutable(a);
#I  InverseMutable
Error, InvOp: method should have returned a value
gap> InverseSameMutability(a);
#I  InverseSameMutability
Error, INVOp: method should have returned a value
gap> a = b;
#I  =
false
gap> a < b;
#I  <
false
gap> a in b;
#I  in
false
gap> a + b;
#I  +
Error, SUM: method should have returned a value
gap> a - b;
#I  -
Error, DIFF: method should have returned a value
gap> a * b;
#I  *
Error, PROD: method should have returned a value
gap> a / b;
#I  /
Error, QUO: method should have returned a value
gap> LeftQuotient(a, b);
Error, LeftQuotient: method should have returned a value
gap> a ^ b;
#I  ^
Error, POW: method should have returned a value
gap> Comm(a, b);
#I  Comm
Error, Comm: method should have returned a value
gap> a mod b;
#I  mod
Error, mod: method should have returned a value

#
gap> UntraceMethods(meths);

#
# restore previous state
#
gap> NEXT_VMETHOD_PRINT_INFO:=old_NEXT_VMETHOD_PRINT_INFO;;
gap> VMETHOD_PRINT_INFO:=old_VMETHOD_PRINT_INFO;;
gap> MakeReadOnlyGlobal("VMETHOD_PRINT_INFO");
gap> MakeReadOnlyGlobal("NEXT_VMETHOD_PRINT_INFO");

#
gap> STOP_TEST("kernel/ariths.tst", 1);
