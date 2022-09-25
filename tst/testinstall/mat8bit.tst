#@local m, z, zm, mz;
gap> START_TEST("mat8bit.tst");

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

#
gap> STOP_TEST("mat8bit.tst");
