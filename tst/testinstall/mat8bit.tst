#@local m, z, zm, mz, mm;
gap> START_TEST("mat8bit.tst");

##
##  Test ConvertToMatrixRep
##

# GF(2)
gap> m := [[1,0,1,1],[0,1,1,1]]*Z(2);; IsPlistRep(m);
true
gap> ConvertToMatrixRep( m, GF(2) );
2
gap> IsGF2MatrixRep(m);
true
gap> m;
<a 2x4 matrix over GF2>
gap> Display(m);
 1 . 1 1
 . 1 1 1
gap> ConvertToMatrixRep( m, GF(7) );
fail
gap> ConvertToMatrixRep( [[1,0,1,1],[0,1,1,1]]*Z(2), 7 );
Error, ConvertToVectorRepNC: Vector cannot be written over GF(7)
gap> ConvertToMatrixRep( [[1,0,1,1],[0,1,1,1]]*Z(2), 4 );
4
gap> ConvertToMatrixRep( [[1,0,1,1],[0,1,1,1]]*Z(2), 512 );
fail

# GF(3)
gap> m := [[1,0,1,1],[0,1,1,1]]*Z(3);; IsPlistRep(m);
true
gap> ConvertToMatrixRep( m, GF(3) );
3
gap> Is8BitMatrixRep(m);
true
gap> m;
[ [ Z(3), 0*Z(3), Z(3), Z(3) ], [ 0*Z(3), Z(3), Z(3), Z(3) ] ]
gap> Display(m);
 2 . 2 2
 . 2 2 2
gap> ConvertToMatrixRep( m, GF(5) );
fail
gap> ConvertToMatrixRep( [[1,0,1,1],[0,1,1,1]]*Z(3), 2 );
Error, ConvertToVectorRepNC: Vector cannot be written over GF(2)
gap> ConvertToMatrixRep( [[1,0,1,1],[0,1,1,1]]*Z(3), 9 );
9
gap> ConvertToMatrixRep( [[1,0,1,1],[0,1,1,1]]*Z(3), 729 );
fail

# GF(4)
gap> m := [[1,0,1,1],[0,1,1,1]]*Z(4);; IsPlistRep(m);
true
gap> ConvertToMatrixRep( m, 4 );
4
gap> Is8BitMatrixRep(m);
true
gap> Display(m);
z = Z(4)
 z^1   . z^1 z^1
   . z^1 z^1 z^1
gap> ConvertToMatrixRep( m, GF(7) );
fail
gap> ConvertToMatrixRep( [[1,0,1,1],[0,1,1,1]]*Z(4), 7 );
Error, ConvertToVectorRepNC: Vector cannot be written over GF(7)
gap> ConvertToMatrixRep( [[1,0,1,1],[0,1,1,1]]*Z(4), 16 );
16
gap> ConvertToMatrixRep( [[1,0,1,1],[0,1,1,1]]*Z(4), 512 );
fail

##
##  Test ConvertToMatrixRepNC
##

# GF(2)
gap> m := [[1,0,1,1],[0,1,1,1]]*Z(2);; IsPlistRep(m);
true
gap> ConvertToMatrixRepNC( m, GF(2) );
2
gap> IsGF2MatrixRep(m);
true
gap> m;
<a 2x4 matrix over GF2>
gap> Display(m);
 1 . 1 1
 . 1 1 1
gap> ConvertToMatrixRepNC( m, GF(7) );
2
gap> ConvertToMatrixRepNC( [[1,0,1,1],[0,1,1,1]]*Z(2), 7 );
Error, ConvertToVectorRepNC: Vector cannot be written over GF(7)
gap> ConvertToMatrixRepNC( [[1,0,1,1],[0,1,1,1]]*Z(2), 4 );
4
gap> ConvertToMatrixRepNC( [[1,0,1,1],[0,1,1,1]]*Z(2), 512 );
fail

# GF(3)
gap> m := [[1,0,1,1],[0,1,1,1]]*Z(3);; IsPlistRep(m);
true
gap> ConvertToMatrixRepNC( m, GF(3) );
3
gap> Is8BitMatrixRep(m);
true
gap> m;
[ [ Z(3), 0*Z(3), Z(3), Z(3) ], [ 0*Z(3), Z(3), Z(3), Z(3) ] ]
gap> Display(m);
 2 . 2 2
 . 2 2 2
gap> ConvertToMatrixRepNC( m, GF(5) );
3
gap> ConvertToMatrixRepNC( [[1,0,1,1],[0,1,1,1]]*Z(3), 2 );
Error, ConvertToVectorRepNC: Vector cannot be written over GF(2)
gap> ConvertToMatrixRepNC( [[1,0,1,1],[0,1,1,1]]*Z(3), 9 );
9
gap> ConvertToMatrixRepNC( [[1,0,1,1],[0,1,1,1]]*Z(3), 729 );
fail

# GF(4)
gap> m := [[1,0,1,1],[0,1,1,1]]*Z(4);; IsPlistRep(m);
true
gap> ConvertToMatrixRepNC( m, 4 );
4
gap> Is8BitMatrixRep(m);
true
gap> Display(m);
z = Z(4)
 z^1   . z^1 z^1
   . z^1 z^1 z^1
gap> ConvertToMatrixRepNC( m, GF(7) );
4
gap> ConvertToMatrixRepNC( [[1,0,1,1],[0,1,1,1]]*Z(4), 7 );
Error, ConvertToVectorRepNC: Vector cannot be written over GF(7)
gap> ConvertToMatrixRepNC( [[1,0,1,1],[0,1,1,1]]*Z(4), 16 );
16
gap> ConvertToMatrixRepNC( [[1,0,1,1],[0,1,1,1]]*Z(4), 512 );
fail

##
##
##

# FFE * 8 bit matrix
gap> m:= [ [ Z(3)^0 ] ];;
gap> ConvertToMatrixRep( m, 3 );;
gap> Is8BitMatrixRep( m );
true
gap> z:= Z(3);;  # internal FFE in the field of 'm'
gap> zm:= z * m;;
gap> Is8BitMatrixRep( zm );
true
gap> Zero( zm ) = Zero( z ) * m;
true
gap> z:= Z(9);;  # internal FFE not in the field of 'm'
gap> zm:= z * m;;
gap> Is8BitMatrixRep( zm );
false
gap> Zero( zm ) = Zero( z ) * m;
true
gap> z:= Zero( Z(3,11) );;  # non-internal FFE in the field of 'm'
gap> IsInternalRep( z );
false
gap> zm:= z * m;;
gap> Is8BitMatrixRep( zm );
true
gap> Zero( zm ) = Zero( z ) * m;
true
gap> z:= Z(3,11);;  # non-internal FFE not in the field of 'm'
gap> IsInternalRep( z );
false
gap> zm:= z * m;;
gap> Is8BitMatrixRep( zm );
false
gap> Zero( zm ) = Zero( z ) * m;
true

# 8 bit matrix * FFE
gap> m:= [ [ Z(3)^0 ] ];;
gap> ConvertToMatrixRep( m, 3 );;
gap> Is8BitMatrixRep( m );
true
gap> z:= Z(3);;  # internal FFE in the field of 'm'
gap> mz:= m * z;;
gap> Is8BitMatrixRep( mz );
true
gap> Zero( mz ) = m * Zero( z );
true
gap> z:= Z(9);;  # internal FFE not in the field of 'm'
gap> mz:= m * z;;
gap> Is8BitMatrixRep( mz );
false
gap> Zero( mz ) = m * Zero( z );
true
gap> z:= Zero( Z(3,11) );;  # non-internal FFE in the field of 'm'
gap> IsInternalRep( z );
false
gap> mz:= m * z;;
gap> Is8BitMatrixRep( mz );
true
gap> Zero( mz ) = m * Zero( z );
true
gap> z:= Z(3,11);;  # non-internal FFE not in the field of 'm'
gap> IsInternalRep( z );
false
gap> mz:= m * z;;
gap> Is8BitMatrixRep( mz );
false
gap> Zero( mz ) = m * Zero( z );
true

# PostMakeImmutable bug
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> m;
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> IsMutable(m);
true
gap> MakeImmutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> IsMutable(m);
false
gap> IsMutable(m[1]);
false
gap> IsMutable(m[2]); # previously returned true!
false

# Unbind for IsMutable and Is8BitMatrixRep
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);;
gap> ConvertToMatrixRepNC(m, 4);;
gap> Is8BitMatrixRep(m);
true
gap> m;
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> Unbind(m[1]);
gap> m;
[ , [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> Is8BitMatrixRep(m);
false
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);;
gap> ConvertToMatrixRepNC(m, 4);;
gap> Unbind(m[2]);
gap> m;
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ] ]
gap> Is8BitMatrixRep(m);
true

# ViewObj for Is8BitMatrixRep where r * c > 25 or r = 0 or c = 0
gap> m := List([1 .. 7], x -> [0, 1, 1, 1] * Z(4));;
gap> ConvertToMatrixRep(m);;
gap> m;
< mutable compressed matrix 7x4 over GF(4) >
gap> MakeImmutable(m);
< immutable compressed matrix 7x4 over GF(4) >

# ShallowCopy for Is8BitMatrixRep
gap> m := List([1 .. 7], x -> [0, 1, 1, 1] * Z(4));;
gap> ConvertToMatrixRep(m);;
gap> mm := ShallowCopy(m);;
gap> IsIdenticalObj(m, mm);
false
gap> m = mm;
true
gap> IsMutable(mm);
true
gap> MakeImmutable(m);
< immutable compressed matrix 7x4 over GF(4) >
gap> mm := ShallowCopy(m);
< mutable compressed matrix 7x4 over GF(4) >
gap> IsIdenticalObj(m, mm);
false
gap> m = mm;
true
gap> IsMutable(mm);
true

# PositionCanonical for Is8BitMatrixRep and IsObject
gap> m := List([1 .. 7], x -> [0, 1, 1, 1] * Z(4));;
gap> ConvertToMatrixRep(m);;
gap> PositionCanonical(m, fail);
fail
gap> PositionCanonical(m, m[1]);
1
gap> PositionCanonical(m, m[2]);
1

# AdditiveInverseMutable for Is8BitMatrixRep
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> Is8BitMatrixRep(m) and IsMutable(m);
true
gap> mm := AdditiveInverseMutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> m + mm = ZeroMutable(m);
true
gap> ForAll(mm, IsMutable);
true
gap> MakeImmutable(m[1]);
[ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ]
gap> IsMutable(m);
true
gap> IsMutable(m[1]);
false
gap> mm := AdditiveInverseMutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ForAll(mm, IsMutable);
true
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> MakeImmutable(m);;
gap> Is8BitMatrixRep(m) and not IsMutable(m);
true
gap> ForAny(m, IsMutable);
false
gap> mm := AdditiveInverseMutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> m + mm = ZeroMutable(m);
true
gap> ForAll(mm, IsMutable);
true
gap> mm := AdditiveInverseMutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ForAll(mm, IsMutable);
true

# AdditiveInverseImmutable for Is8BitMatrixRep
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> Is8BitMatrixRep(m);
true
gap> mm := AdditiveInverseImmutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> m + mm = ZeroMutable(m);
true
gap> ForAny(mm, IsMutable);
false
gap> MakeImmutable(m[1]);
[ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ]
gap> IsMutable(m);
true
gap> IsMutable(m[1]);
false
gap> mm := AdditiveInverseImmutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ForAny(mm, IsMutable);
false
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> MakeImmutable(m);;
gap> Is8BitMatrixRep(m) and not IsMutable(m);
true
gap> ForAny(m, IsMutable);
false
gap> mm := AdditiveInverseImmutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> m + mm = ZeroMutable(m);
true
gap> ForAny(mm, IsMutable);
false
gap> mm := AdditiveInverseImmutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ForAny(mm, IsMutable);
false

# AdditiveInverseSameMutability for Is8BitMatrixRep
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> Is8BitMatrixRep(m);
true
gap> mm := AdditiveInverseSameMutability(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ForAll(mm, IsMutable);
true
gap> MakeImmutable(m[2]);
[ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ]
gap> mm := AdditiveInverseSameMutability(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> List(mm, IsMutable);
[ true, true ]
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> MakeImmutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> Is8BitMatrixRep(m);
true
gap> mm := AdditiveInverseSameMutability(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ForAny(mm, IsMutable);
false
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> Is8BitMatrixRep(m);
true
gap> MakeImmutable(m[1]);
[ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ]
gap> mm := AdditiveInverseSameMutability(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> List(mm, IsMutable);
[ false, false ]

# ZeroSameMutability for Is8BitMatrixRep
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> Is8BitMatrixRep(m);
true
gap> mm := ZeroSameMutability(m);
[ [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ] ]
gap> IsMutable(mm);
true
gap> ForAll(mm, IsMutable);
true
gap> MakeImmutable(m[2]);
[ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ]
gap> mm := ZeroSameMutability(m);
[ [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ] ]
gap> IsMutable(mm);
true
gap> List(mm, IsMutable);
[ true, true ]
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> MakeImmutable(m[1]);
[ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ]
gap> Is8BitMatrixRep(m);
true
gap> mm := ZeroSameMutability(m);
[ [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ] ]
gap> IsMutable(mm);
true
gap> List(mm, IsMutable);
[ false, false ]
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> MakeImmutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> Is8BitMatrixRep(m);
true
gap> mm := ZeroSameMutability(m);
[ [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ] ]
gap> IsMutable(mm);
false
gap> ForAny(mm, IsMutable);
false

# OneSameMutability for Is8BitMatrixRep
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> Is8BitMatrixRep(m);
true
gap> mm := OneSameMutability(m);
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2) ] ]
gap> IsMutable(mm);
true
gap> ForAll(mm, IsMutable);
true
gap> MakeImmutable(m[2]);
[ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ]
gap> mm := OneSameMutability(m);
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2) ] ]
gap> IsMutable(mm);
true
gap> List(mm, IsMutable);
[ true, true ]
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> MakeImmutable(m[1]);
[ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ]
gap> Is8BitMatrixRep(m);
true
gap> mm := OneSameMutability(m);
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2) ] ]
gap> IsMutable(mm);
true
gap> List(mm, IsMutable);
[ false, false ]
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> MakeImmutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> Is8BitMatrixRep(m);
true
gap> mm := OneSameMutability(m);
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2) ] ]
gap> IsMutable(mm);
false
gap> ForAny(mm, IsMutable);
false

# OneMutable/OneImmutable for Is8BitMatrixRep
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> Is8BitMatrixRep(m);
true
gap> mm := OneMutable(m);
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2) ] ]
gap> IsMutable(mm);
true
gap> ForAll(mm, IsMutable);
true
gap> mm := OneImmutable(m);
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2) ] ]
gap> IsMutable(mm);
false
gap> ForAny(mm, IsMutable);
false

# ConvertToMatrixRep
gap> ConvertToMatrixRep(fail, CyclotomicField(10));
fail
gap> ConvertToMatrixRep(fail, fail);
fail
gap> ConvertToMatrixRep([], fail);
fail
gap> ConvertToMatrixRep([]);
fail
gap> ConvertToMatrixRep([], 16);
16
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> ConvertToMatrixRep(m, 16);
fail
gap> ConvertToMatrixRep(m);
4
gap> ConvertToMatrixRep(m, 4);
4
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(2);;
gap> ConvertToMatrixRepNC(m);;
gap> IsGF2MatrixRep(m);
true
gap> ConvertToMatrixRep(m, 2);
2
gap> ConvertToMatrixRep(m);
2
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> ConvertToMatrixRepNC(m);;
gap> mm := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(2);;
gap> ConvertToMatrixRepNC(mm);;
gap> m := [m[1], mm[1], m[2], mm[2]];
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], <a GF2 vector of length 4>, 
  [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ], <a GF2 vector of length 4> ]
gap> ConvertToMatrixRep(m, 5);
fail
gap> ConvertToMatrixRep(m, 8);
Error, ConvertToMatrixRep( <mat>, <q> ): not all entries of <mat> written over\
 <q>
gap> ConvertToMatrixRep(m);
#I  ConvertToVectorRep: locked vector not converted to different field
fail
gap> m := [m[1], mm[1], m[2], mm[2],[]];
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], <a GF2 vector of length 4>, 
  <a GF2 vector of length 4>, <a GF2 vector of length 4>, [  ] ]
gap> ConvertToMatrixRep(m);
fail

# ConvertToMatrixRepNC
gap> ConvertToMatrixRepNC([], 3);
3

# DefaultFieldOfMatrix
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1]] * Z(4);;
gap> ConvertToMatrixRepNC(m);;
gap> DefaultFieldOfMatrix(m);
GF(2^2)

# SemiEchelonMat
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1], [0, 1, 0, 0], [1, 1, 1, 1]] * Z(4);;
gap> ConvertToMatrixRepNC(m);;
gap> mm := SemiEchelonMat(m);
rec( heads := [ 1, 2, 3, 0 ], 
  vectors := [ [ Z(2)^0, 0*Z(2), Z(2)^0, Z(2)^0 ], 
      [ 0*Z(2), Z(2)^0, Z(2)^0, Z(2)^0 ], [ 0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0 ] 
     ] )
gap> Is8BitMatrixRep(mm.vectors);
true
gap> m;
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ], 
  [ 0*Z(2), Z(2^2), 0*Z(2), 0*Z(2) ], [ Z(2^2), Z(2^2), Z(2^2), Z(2^2) ] ]

# TriangulizeMat
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1], [0, 1, 0, 0], [1, 1, 1, 1]] * Z(4);;
gap> ConvertToMatrixRepNC(m);;
gap> Is8BitMatrixRep(m) and IsMutable(m);
true
gap> TriangulizeMat(m);
gap> m;
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0 ], [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ] ]
gap> Is8BitMatrixRep(m) and IsMutable(m);
true
gap> ForAll(m, IsMutable);
true
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1], [0, 1, 0, 0], [1, 1, 1, 1]] * Z(4);;
gap> ConvertToMatrixRepNC(m);;
gap> MakeImmutable(m[1]);
[ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ]
gap> Is8BitMatrixRep(m) and IsMutable(m);
true
gap> TriangulizeMat(m);
gap> m;
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0 ], [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ] ]
gap> Is8BitMatrixRep(m) and IsMutable(m);
true
gap> ForAny(m, IsMutable);
false
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1], [0, 1, 0, 0], [1, 1, 1, 1]] * Z(4);;
gap> ConvertToMatrixRepNC(m);;
gap> MakeImmutable(m[2]);
[ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ]
gap> Is8BitMatrixRep(m) and IsMutable(m);
true
gap> TriangulizeMat(m);
gap> m;
[ [ Z(2)^0, 0*Z(2), 0*Z(2), 0*Z(2) ], [ 0*Z(2), Z(2)^0, 0*Z(2), 0*Z(2) ], 
  [ 0*Z(2), 0*Z(2), Z(2)^0, Z(2)^0 ], [ 0*Z(2), 0*Z(2), 0*Z(2), 0*Z(2) ] ]
gap> Is8BitMatrixRep(m) and IsMutable(m);
true
gap> ForAll(m, IsMutable);
true
gap> m := [[1, 0, 1, 1], [0, 1, 1, 1], [0, 1, 0, 0], [1, 1, 1, 1]] * Z(4);;
gap> ConvertToMatrixRepNC(m);;
gap> MakeImmutable(m);
[ [ Z(2^2), 0*Z(2), Z(2^2), Z(2^2) ], [ 0*Z(2), Z(2^2), Z(2^2), Z(2^2) ], 
  [ 0*Z(2), Z(2^2), 0*Z(2), 0*Z(2) ], [ Z(2^2), Z(2^2), Z(2^2), Z(2^2) ] ]
gap> TriangulizeMat(m);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `TriangulizeMat' on 1 arguments

#
gap> STOP_TEST("mat8bit.tst");
