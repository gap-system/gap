#@local a, c, H, b, cls, pc, norm, chi
######################################################################
gap> START_TEST( "example_2.5.18.tst" );

######################################################################
gap> a := (1,11)(2,7)(3,5)(4,6);; c:= (1,2,7,12,11,8,4,10,6,9,3);;
gap> H := Group(a,c);;   IsSimple(H) and Size(H) = 11*10*9*8;
true
gap> repeat b := Random(H); until Order(b) = 4 and Order(a*b) = 11 and
>                                       Order(a*b*a*b^2*a*b^3)= 5;
gap> b;
(1,5,10,8)(2,3,9,7)(4,12)(6,11)
gap> cls := [ a^2, a, a*b^2*a*b^2, b, a*b*a*b^2*a*b^-1, a*b^2,
>                    a*b*a*b^2*a*b^2,a*b^-1*a*b^2*a*b^2, a*b, a*b^-1 ];;
gap> pc := List( cls, x -> 12 - NrMovedPoints(x) );
[ 12, 4, 3, 0, 2, 1, 0, 0, 1, 1 ]
gap> norm:=List(pc, x-> x^2) * List(cls, g -> 1/Size(Centralizer(H,g)));
2
gap> chi := pc - List( pc, x -> 1 );;
gap> Position( Irr( CharacterTable("M11") ), chi );
5

######################################################################
gap> STOP_TEST( "example_2.5.18.tst" );
