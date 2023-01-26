#@local m, z, zm, mz;
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

#
gap> STOP_TEST("mat8bit.tst");
