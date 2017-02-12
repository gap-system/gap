# 2005/08/23 (FL)
# commented out the test and the error message,
# since a different message is printed on 32 bit systems and 64 bit systems
gap> a := 2^(8*GAPInfo.BytesPerVariable-4)-1;;
gap> Unbind( x );
gap> x := [-a..a];
Error, Range: the length of a range must be less than 2^60
gap> IsBound(x);
false
