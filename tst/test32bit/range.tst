# 2005/08/23 (FL)
gap> a := 2^(8*GAPInfo.BytesPerVariable-4)-1;;
gap> Unbind( x );
gap> x := [-a..a];
Error, Range: the length of a range must be less than 2^28
gap> IsBound(x);
false
