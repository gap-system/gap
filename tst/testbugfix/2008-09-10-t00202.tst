# 2008/09/10 (TB)
gap> Display( StraightLineProgram( "a(ab)", [ "a", "b" ] ) );
# input:
r:= [ g1, g2 ];
# program:
r[3]:= r[1];
r[4]:= r[1]*r[2];
r[5]:= r[3]*r[4];
# return value:
r[5]
