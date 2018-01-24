#############################################################################
##
#W  ctblmono.tst               GAP Library                      Thomas Breuer
#W                                                         & Erzsébet Horváth
##
##
#Y  Copyright (C)  1998,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
gap> START_TEST("ctblmono.tst");

##
gap> S4:= SymmetricGroup( 4 );;  SetName( S4, "S4");
gap> Sl23:= SL( 2, 3 );;

##
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

##
gap> chi:= Irr( Sl23 )[7];
Character( CharacterTable( SL(2,3) ), [ 3, 0, 0, 3, 0, 0, -1 ] )
gap> n:= DerivedSubgroup( Sl23 );;
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

##
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

##
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

##
gap> Filtered( [ 1 .. 200 ], i -> not IsMonomial( i ) );
[ 24, 48, 72, 96, 108, 120, 144, 160, 168, 192 ]

##
gap> irr:= Irr( SymmetricGroup( 4 ) );;
gap> SetIsMonomialCharacter( irr[1], true );
gap> TestMonomialQuick( irr[1] );
rec( comment := "was already stored", isMonomial := true )
gap> TestMonomial( irr[1] );
rec( comment := "was already stored", isMonomial := true )
gap> IsMonomial( irr[1] );
true
gap> TestMonomialQuick( irr[5] );
rec( comment := "linear character", isMonomial := true )
gap> TestMonomial( irr[5] );
rec( comment := "linear character", isMonomial := true )
gap> IsMonomial( irr[5] );
true
gap> TestMonomial( 5 * irr[1] );
rec( comment := "degree does not divide group order", isMonomial := false )
gap> IsMonomial( 5 * irr[5] );
false
gap> TestMonomialQuick( irr[2] );
rec( comment := "whole group is monomial", isMonomial := true )
gap> TestMonomial( irr[2] );
rec( comment := "whole group is monomial", isMonomial := true )
gap> IsMonomial( irr[2] );
true
gap> irr:= Irr( SL(2,3) );;
gap> chi:= First( irr, x -> x[1] = 3 );;
gap> TestMonomialQuick( chi );
rec( comment := "codegree is prime power", isMonomial := true )
gap> TestMonomial( chi );
rec( comment := "codegree is prime power", isMonomial := true )
gap> IsMonomial( chi );
true
gap> irr:= Irr( SmallGroup( 120, 15 ) );;
gap> chi:= First( irr, x -> x[1] = 3 and
>                           Length( ClassPositionsOfKernel( x ) ) = 2 );;
gap> TestMonomialQuick( chi );
rec( comment := "degree is index of Hall subgroup", isMonomial := true )
gap> TestMonomial( chi );
rec( comment := "degree is index of Hall subgroup", isMonomial := true )
gap> IsMonomial( chi );
true
gap> irr:= Irr( SmallGroup( 240, 109 ) );;
gap> chi:= First( irr, x -> x[1] = 6 );;
gap> TestMonomialQuick( chi );
rec( comment := "induced from monomial Hall subgroup", isMonomial := true )
gap> TestMonomial( chi );
rec( comment := "induced from monomial Hall subgroup", isMonomial := true )
gap> IsMonomial( chi );
true
gap> g:= DirectProduct( AlternatingGroup(5), SymmetricGroup(3),
>                       SymmetricGroup(3) );;
gap> chi:= First( Irr( g ), x -> x[1] = 2 and
>                           Length( ClassPositionsOfKernel( x ) ) = 10 );;
gap> TestMonomialQuick( chi );
rec( comment := "kernel factor group is supersolvable", isMonomial := true )
gap> TestMonomial( chi );
rec( comment := "kernel factor group is supersolvable", isMonomial := true )
gap> IsMonomial( chi );
true
gap> irr:= Irr( SmallGroup( 144, 31 ) );;
gap> chi:= First( irr, x -> x[1] = 6 );;
gap> TestMonomialQuick( chi );
rec( comment := "kernel factor group is monomial", isMonomial := true )
gap> TestMonomial( chi );
rec( comment := "kernel factor group is monomial", isMonomial := true )
gap> IsMonomial( chi );
true
gap> irr:= Irr( SL(2,3) );;
gap> chi:= First( irr, x -> x[1] = 2 );;
gap> TestMonomialQuick( chi );
rec( comment := "no decision by cheap tests", isMonomial := "?" )
gap> TestMonomial( chi );
rec( comment := "quasiprimitive character", isMonomial := false )
gap> IsMonomial( chi );
false
gap> irr:= Irr( AlternatingGroup( 5 ) );;
gap> chi:= First( irr, x -> x[1] = 5 );;
gap> TestMonomialQuick( chi );
rec( comment := "no decision by cheap tests", isMonomial := "?" )
gap> TestMonomial( chi ).comment;
"induced from 'character'"
gap> IsMonomial( chi );
true
gap> TestMonomialUseLattice_Orig:= TestMonomialUseLattice;;
gap> TestMonomialUseLattice:= 20;;
gap> chi:= First( irr, x -> x[1] = 4 );;
gap> TestMonomialQuick( chi );
rec( comment := "no decision by cheap tests", isMonomial := "?" )
gap> TestMonomial( chi ).comment;
"no criterion for nonsolvable group"
gap> TestMonomial( chi, true ).comment;
"lattice checked"
gap> IsMonomial( chi );
false
gap> irr:= Irr( SmallGroup( 96, 204 ) );;
gap> chi:= First( irr, x -> x[1] = 4 );;
gap> TestMonomialQuick( chi );
rec( comment := "no decision by cheap tests", isMonomial := "?" )
gap> TestMonomial( chi ).comment;
"induced from 'character'"
gap> IsMonomial( chi );
true
gap> chi:= First( Irr( SmallGroup( 144, 31 ) ), x -> x[1] = 4 );;
gap> TestMonomialQuick( chi );
rec( comment := "no decision by cheap tests", isMonomial := "?" )
gap> TestMonomial( chi ).comment;
"all inertia subgroups checked, no result"
gap> TestMonomial( chi, true ).comment;
"induced from 'character'"
gap> IsMonomial( chi );
true
gap> chi:= 0 * [ 1 .. NrConjugacyClasses( S4 ) ];;
gap> chi[1]:= Size( S4 );;
gap> chi:= ClassFunction( S4, chi );;
gap> TestMonomial( chi ).comment;
"no criterion for reducible character"
gap> TestMonomial( chi, true ).comment;
"induced from 'character'"
gap> IsMonomial( chi );
true
gap> TestMonomialUseLattice:= TestMonomialUseLattice_Orig;;
gap> chi:= First( Irr( SmallGroup( 48, 28 ) ), x -> x[1] = 4 );;
gap> TestMonomialQuick( chi );
rec( comment := "no decision by cheap tests", isMonomial := "?" )
gap> TestMonomial( chi ).comment;
"induced from 'character'"
gap> IsMonomial( chi );
true

##
gap> TestMonomialQuick( S4 );
rec( comment := "abelian by supersolvable group", isMonomial := true )
gap> TestMonomial( S4 );
rec( comment := "abelian by supersolvable group", isMonomial := true )
gap> IsMonomial( S4 );
true
gap> TestMonomialQuick( Sl23 );
rec( comment := "no decision by cheap tests", isMonomial := "?" )
gap> TestMonomial( Sl23 );
rec( comment := "list Delta( G ) contains entry > 1", isMonomial := false )
gap> IsMonomial( Sl23 );
false
gap> g:= SmallGroup( 96, 204 );;
gap> TestMonomialQuick( g );
rec( comment := "no decision by cheap tests", isMonomial := "?" )
gap> TestMonomial( g );
rec( comment := "all characters checked", isMonomial := true )
gap> IsMonomial( g );
true
gap> TestMonomialUseLattice_Orig:= TestMonomialUseLattice;;
gap> TestMonomialUseLattice:= 50;;
gap> test:= TestMonomial( SmallGroup( 96, 190 ) );;
gap> test.isMonomial;  test.comment;
"?"
"(possibly) nonmon. characters found"
gap> test:= TestMonomial( SmallGroup( 96, 190 ), true );;
gap> test.isMonomial;  test.comment;
false
"nonmonomial character found"
gap> TestMonomialUseLattice:= TestMonomialUseLattice_Orig;;
gap> g:= SmallGroup( 16, 3 );;
gap> TestMonomialQuick( g );  # implication
rec( comment := "was already stored", isMonomial := true )
gap> TestMonomial( g );
rec( comment := "was already stored", isMonomial := true )
gap> IsMonomial( g );
true
gap> g:= AlternatingGroup( 5 );;
gap> TestMonomialQuick( g );
rec( comment := "non-solvable group", isMonomial := false )
gap> TestMonomial( g );
rec( comment := "non-solvable group", isMonomial := false )
gap> IsMonomial( g );
false
gap> g:= SmallGroup( 56, 10 );;
gap> TestMonomialQuick( g );
rec( comment := "group order is monomial", isMonomial := true )
gap> TestMonomial( g );
rec( comment := "group order is monomial", isMonomial := true )
gap> IsMonomial( g );
true
gap> g:= SmallGroup( 24, 10 );;
gap> TestMonomialQuick( g );
rec( comment := "nilpotent group", isMonomial := true )
gap> TestMonomial( g );
rec( comment := "nilpotent group", isMonomial := true )
gap> IsMonomial( g );
true
gap> g:= SmallGroup( 24, 4 );;
gap> TestMonomialQuick( g );
rec( comment := "supersolvable group", isMonomial := true )
gap> TestMonomial( g );
rec( comment := "supersolvable group", isMonomial := true )
gap> IsMonomial( g );
true
gap> g:= SmallGroup( 324, 160 );;
gap> TestMonomialQuick( g );
rec( comment := "Sylow abelian by supersolvable group", isMonomial := true )
gap> TestMonomial( g );
rec( comment := "Sylow abelian by supersolvable group", isMonomial := true )
gap> IsMonomial( g );
true

##
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

##
gap> TestRelativelySM( DerivedSubgroup( S4 ) );
rec( comment := "normal subgroups are abelian or have nilpotent factor group",
  isRelativelySM := true )

##
gap> g1:= MinimalNonmonomialGroup(  2,  3 ); # the group SL(2,3)
2^(1+2):3
gap> g2:= MinimalNonmonomialGroup(  3,  4 );
3^(1+2):4
gap> g3:= MinimalNonmonomialGroup(  5,  8 );
5^(1+2):Q8
gap> g4:= MinimalNonmonomialGroup( 13, 12 );
13^(1+2):2.D6
gap> g5:= MinimalNonmonomialGroup(  1, 14 );
2^(1+6):D14
gap> g6:= MinimalNonmonomialGroup(  2, 14 );
(2^(1+6)Y4):D14
gap> MinimalNonmonomialGroup(  3,  3 );
fail
gap> MinimalNonmonomialGroup(  2,  4 );
fail
gap> MinimalNonmonomialGroup(  2,  8 );
fail
gap> MinimalNonmonomialGroup(  1, 10 );
fail
gap> MinimalNonmonomialGroup(  5,  9 );
fail

##
gap> IsMinimalNonmonomial( Sl23 );
true
gap> for g in [ g1, g2, g3, g4, g5, g6 ] do
>      # Make sure that the value is not yet stored.
>      if not IsMinimalNonmonomial( Group( GeneratorsOfGroup( g ) ) ) then
>        Error( "wrong result of IsMinimalNonmonomial" );
>      fi;
>    od;
gap> IsMinimalNonmonomial( S4 );
false

##
gap> STOP_TEST( "ctblmono.tst", 1);

#############################################################################
##
#E

