#############################################################################
##
#W  ctblmono.tst               GAP Library                      Thomas Breuer
#W                                                         & Erzsébet Horváth
##
##
#Y  Copyright (C)  1998,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  To be listed in testinstall.g
##
gap> START_TEST("ctblmono.tst");
gap> S4:= SymmetricGroup( 4 );;  SetName( S4, "S4");
gap> Sl23:= SL( 2, 3 );;
gap> Alpha( Sl23 );
[ 1, 3, 3 ]
gap> Alpha( S4 );
[ 1, 2, 3 ]
gap> Delta( Sl23 );
[ 1, 2, 0 ]
gap> Delta( S4 );
[ 1, 1, 1 ]
gap> IsBergerCondition( S4 );
true
gap> IsBergerCondition( Sl23 );
false
gap> List( Irr( Sl23 ), IsBergerCondition );
[ true, true, true, false, false, false, true ]
gap> List( Irr( Sl23 ), Degree );
[ 1, 1, 1, 2, 2, 2, 3 ]
gap> n:= DerivedSubgroup( Sl23 );;      
gap> chi:= Irr( Sl23 )[7];
Character( CharacterTable( SL(2,3) ), [ 3, 0, 0, 3, 0, 0, -1 ] )
gap> test:= TestHomogeneous( chi, n );;
gap> test.isHomogeneous;  test.comment;  test.multiplicity;
false
"restriction checked"
1
gap> chi:= Irr( Sl23 )[4];
Character( CharacterTable( SL(2,3) ), [ 2, 1, 1, -2, -1, -1, 0 ] )
gap> cln:= ClassPositionsOfNormalSubgroup( CharacterTable( Sl23 ), n );
[ 1, 4, 7 ]
gap> TestHomogeneous( chi, cln );
rec( comment := "restricts irreducibly", isHomogeneous := true )
gap> chi:= Irr( Sl23 )[4];;
gap> TestQuasiPrimitive( chi );
rec( comment := "all restrictions checked", isQuasiPrimitive := true )
gap> chi:= Irr( Sl23 )[7];;
gap> test:= TestQuasiPrimitive( chi );;
gap> test.isQuasiPrimitive;  test.comment;
false
"restriction checked"
gap> IsPrimitive( Irr( Sl23 )[4] );
true
gap> IsPrimitive( Irr( Sl23 )[7] );
false
gap> List( Irr( Sl23 ), IsInducedFromNormalSubgroup );
[ false, false, false, false, false, false, true ]
gap> List( Irr( S4 ){ [ 1, 3, 4 ] },
>          TestInducedFromNormalSubgroup );
[ rec( comment := "linear character", isInduced := false ), 
  rec( character := Character( CharacterTable( Alt( [ 1 .. 4 ] ) ),
      [ 1, 1, E(3)^2, E(3) ] ), 
      comment := "induced from component '.character'", isInduced := true ), 
  rec( comment := "all maximal normal subgroups checked", isInduced := false 
     ) ]
gap> TestMonomial( S4 );
rec( comment := "abelian by supersolvable group", isMonomial := true )
gap> TestMonomial( Sl23 );
rec( comment := "list Delta( G ) contains entry > 1", isMonomial := false )
gap> Filtered( [ 1 .. 111 ], x -> not IsMonomial( x ) );
[ 24, 48, 72, 96, 108 ]
gap> TestMonomialQuick( Irr( S4 )[3] );
rec( comment := "whole group is monomial", isMonomial := true )
gap> TestMonomialQuick( S4 );
rec( comment := "abelian by supersolvable group", isMonomial := true )
gap> TestMonomialQuick( Sl23 );
rec( comment := "no decision by cheap tests", isMonomial := "?" )
gap> TestSubnormallyMonomial( S4 );
rec( character := Character( CharacterTable( S4 ), [ 3, -1, -1, 0, 1 ] ), 
  comment := "found non-SM character", isSubnormallyMonomial := false )
gap> TestSubnormallyMonomial( Irr( S4 )[4] );
rec( comment := "all subnormal subgroups checked", 
  isSubnormallyMonomial := false )
gap> TestSubnormallyMonomial( DerivedSubgroup( S4 ) );
rec( comment := "all irreducibles checked", isSubnormallyMonomial := true )
gap> IsSubnormallyMonomial( DerivedSubgroup( S4 ) );
true
gap> TestRelativelySM( DerivedSubgroup( S4 ) );
rec( comment := "normal subgroups are abelian or have nilpotent factor group",
  isRelativelySM := true )
gap> IsMinimalNonmonomial( Sl23 );                  
true
gap> IsMinimalNonmonomial( S4 );
false
gap> MinimalNonmonomialGroup(  2,  3 ); # the group SL(2,3)
2^(1+2):3
gap> MinimalNonmonomialGroup(  3,  4 );
3^(1+2):4
gap> MinimalNonmonomialGroup(  5,  8 );
5^(1+2):Q8
gap> MinimalNonmonomialGroup( 13, 12 );                              
13^(1+2):2.D6
gap> MinimalNonmonomialGroup(  1, 14 );
2^(1+6):D14
gap> MinimalNonmonomialGroup(  2, 14 );
(2^(1+6)Y4):D14
gap> STOP_TEST( "ctblmono.tst", 1);

#############################################################################
##
#E
