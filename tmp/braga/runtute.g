#############################################################################
##
#W  braga.tst                  GAP 							Andrew Solomon
##
#H  @(#)$Id: runtute.g,v 1.2 1999/05/18 20:02:32 andrews Exp $
##
#Y  Copyright (C)  1998,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id: runtute.g,v 1.2 1999/05/18 20:02:32 andrews Exp $");

gap> Binomial(7,3)-1;
34
gap> s1 := Transformation([1,1,3,4]);
Transformation( [ 1, 1, 3, 4 ] )
gap> s2 := Transformation([1,2,2,4]);
Transformation( [ 1, 2, 2, 4 ] )
gap> s3 := Transformation([1,2,3,3]);
Transformation( [ 1, 2, 3, 3 ] )
gap> t1 := Transformation([2,2,3,4]);
Transformation( [ 2, 2, 3, 4 ] )
gap> t2 := Transformation([1,3,3,4]);
Transformation( [ 1, 3, 3, 4 ] )
gap> t3 := Transformation([1,2,4,4]);
Transformation( [ 1, 2, 4, 4 ] )
gap> o4 := Semigroup( s1,s2,s3,t1,t2,t3 );
<semigroup with 6 generators>
gap> Size(o4);
34
gap> 
gap> c := SemigroupCongruenceByGeneratingPairs( o4, [[s2*s1,t1*s2]]);
<semigroup congruence with 1 generating pairs>
gap> EquivalenceRelationPartition( c );
[ [ Transformation( [ 1, 1, 1, 4 ] ), Transformation( [ 2, 2, 2, 4 ] ), 
      Transformation( [ 2, 2, 2, 2 ] ), Transformation( [ 1, 1, 1, 1 ] ), 
      Transformation( [ 2, 2, 2, 3 ] ), Transformation( [ 1, 1, 1, 3 ] ), 
      Transformation( [ 2, 2, 4, 4 ] ), Transformation( [ 1, 1, 4, 4 ] ), 
      Transformation( [ 3, 3, 3, 4 ] ), Transformation( [ 3, 3, 3, 3 ] ), 
      Transformation( [ 3, 3, 4, 4 ] ), Transformation( [ 4, 4, 4, 4 ] ), 
      Transformation( [ 1, 1, 1, 2 ] ), Transformation( [ 1, 1, 3, 3 ] ), 
      Transformation( [ 1, 4, 4, 4 ] ), Transformation( [ 1, 1, 2, 2 ] ), 
      Transformation( [ 1, 3, 3, 3 ] ), Transformation( [ 2, 2, 3, 3 ] ), 
      Transformation( [ 2, 4, 4, 4 ] ), Transformation( [ 2, 3, 3, 3 ] ), 
      Transformation( [ 3, 4, 4, 4 ] ), Transformation( [ 1, 2, 2, 2 ] ) ] ]
gap> IsReesCongruence( c );
true
gap> IsRegularSemigroup( o4 );
true
gap> DisplayTransformationSemigroup( o4 );
Rank 3: *[H size = 1, 4 L classes, 3 R classes]
Rank 2: *[H size = 1, 6 L classes, 3 R classes]
Rank 1: *[H size = 1, 4 L classes, 1 R classes]
gap> dcl := GreensDClasses( o4 );
[ {Transformation( [ 1, 1, 3, 4 ] )}, {Transformation( [ 1, 1, 1, 4 ] )}, 
  {Transformation( [ 1, 1, 1, 1 ] )} ]
gap> IsGreensLessThanOrEqual( dcl[2], dcl[1]);
true
gap> IsGreensLessThanOrEqual( dcl[3], dcl[2]);
true
gap> DisplayEggBoxOfDClass( dcl[1] );
[ [  1,  0,  1,  0 ],
  [  1,  1,  0,  0 ],
  [  0,  1,  0,  1 ] ]
gap> s := Transformation( [1,1,3,4,5] );
Transformation( [ 1, 1, 3, 4, 5 ] )
gap> c := Transformation( [2,3,4,5,1] );
Transformation( [ 2, 3, 4, 5, 1 ] )
gap> op5 := Semigroup( s,c );
<semigroup with 2 generators>
gap> DisplayTransformationSemigroup( op5 );
Rank 5: *[H size = 5, 1 L classes, 1 R classes]
Rank 4: *[H size = 4, 5 L classes, 5 R classes]
Rank 3: *[H size = 3, 10 L classes, 10 R classes]
Rank 2: *[H size = 2, 10 L classes, 10 R classes]
Rank 1: *[H size = 1, 5 L classes, 1 R classes]
gap> Size( op5 );
610
gap> dcl := GreensDClasses(op5);
[ {Transformation( [ 1, 1, 3, 4, 5 ] )}, {Transformation( [ 2, 3, 4, 5, 1 ] )}
    , {Transformation( [ 1, 1, 4, 5, 1 ] )}, 
  {Transformation( [ 1, 1, 5, 1, 1 ] )}, 
  {Transformation( [ 1, 1, 1, 1, 1 ] )} ]
gap> d4 := dcl[1];
{Transformation( [ 1, 1, 3, 4, 5 ] )}
gap> rms := AssociatedReesMatrixSemigroupOfDClass(d4);
Rees Matrix Semigroup over Monoid( [ (1,3,4,5), 0 ], ... )
gap> s := Transformation( [1,1,3] );
Transformation( [ 1, 1, 3 ] )
gap> c := Transformation( [2,3,1] );
Transformation( [ 2, 3, 1 ] )
gap> op3 := Semigroup( s,c );
<semigroup with 2 generators>
gap> IsRegularSemigroup( op3 );
true
gap> dcl := GreensDClasses( op3 );
[ {Transformation( [ 1, 1, 3 ] )}, {Transformation( [ 2, 3, 1 ] )}, 
  {Transformation( [ 1, 1, 1 ] )} ]
gap> d2 := dcl[1];
{Transformation( [ 1, 1, 3 ] )}
gap> d1 := dcl[3];
{Transformation( [ 1, 1, 1 ] )}
gap> i2 := SemigroupIdealByGenerators( op3, [Representative( d2 )] );
<SemigroupIdeal with 1 generators>
gap> i1 := SemigroupIdealByGenerators( i2, [Representative( d1 )] );
<SemigroupIdeal with 1 generators>
gap> c1 := ReesCongruenceOfSemigroupIdeal( i1 );
<semigroup congruence>
gap> q := i2/c1;
<quotient of SemigroupIdeal( [ Transformation( [ 1, 1, 3 ] ) 
 ] ) by SemigroupCongruence( ... )>
gap> IsZeroSimpleSemigroup( q );
true
gap> irms := IsomorphismReesMatrixSemigroup( q );
MappingByFunction( Rees Matrix Semigroup over Monoid( 
[ (), (1,2), 0 ], ... ), <quotient of SemigroupIdeal( 
[ Transformation( [ 1, 1, 3 ] ) 
 ] ) by SemigroupCongruence( ... )>, function( x ) ... end )
gap> Source( irms);
Rees Matrix Semigroup over Monoid( [ (), (1,2), 0 ], ... )
gap> q = Range( irms );
true
gap> SandwichMatrixOfReesMatrixSemigroup( Source(irms) );
[ [ (), 0, () ], [ 0, (), () ], [ (), (1,2), 0 ] ]
gap> JoinSetElementSpec :=
>   rec( ElementName := "JoinSet",
>   Multiplication := function(a,b) return Union(a,b); end,
>   MathInfo := IsCommutativeElement);
rec( ElementName := "JoinSet", Multiplication := function( a, b ) ... end, 
  MathInfo := <Operation "IsCommutativeElement"> )
gap> MakeJoinSet := ArithmeticElementCreator( JoinSetElementSpec );
function( x ) ... end
gap> a := MakeJoinSet( [1,2] );
[ 1, 2 ]
gap> b := MakeJoinSet( [2,3] );
[ 2, 3 ]
gap> c := MakeJoinSet( [3,4] );
[ 3, 4 ]
gap> a*b;
[ 1, 2, 3 ]
gap> a*b*c;
[ 1, 2, 3, 4 ]
gap> s := Semigroup( a,b,c );
<semigroup with 3 generators>
gap> Elements( s );
[ [ 1, 2 ], [ 1, 2, 3 ], [ 1, 2, 3, 4 ], [ 2, 3 ], [ 2, 3, 4 ], [ 3, 4 ] ]
gap> f := FreeSemigroup( "x", "y", "z" );
<free semigroup on the generators [ x, y, z ]>
gap> x := GeneratorsOfSemigroup( f )[ 1 ];
x
gap> y := GeneratorsOfSemigroup( f )[ 2 ];
y
gap> z := GeneratorsOfSemigroup( f )[ 3 ];
z
gap> rels := [ [x^2,x], [y^2,y], [z^2, z],
>   [x*y,y*x], [x*z,z*x], [x*y*z, x*z], [y*z, z*y] ];
[ [ x^2, x ], [ y^2, y ], [ z^2, z ], [ x*y, y*x ], [ x*z, z*x ], 
  [ x*y*z, x*z ], [ y*z, z*y ] ]
gap> g := f/rels;
<fp semigroup on the generators [ x, y, z ]>
gap> psi := NaturalHomomorphismByGenerators( g, s);
MappingByFunction( <fp semigroup on the generators 
[ x, y, z ]>, <semigroup with 3 generators>, function( e ) ... end )
gap> gx := GeneratorsOfSemigroup( g )[ 1 ];
x
gap> gy := GeneratorsOfSemigroup( g )[ 2 ];
y
gap> gz := GeneratorsOfSemigroup( g )[ 3 ];
z
gap> gx^psi;
[ 1, 2 ]
gap> gy^psi;
[ 2, 3 ]
gap> gz^psi;
[ 3, 4 ]
gap> Size( g );
6
gap> tci := IsomorphismTransformationSemigroup( g );
MappingByFunction( <fp semigroup on the generators 
[ x, y, z ]>, <semigroup with 3 generators>, function( x ) ... end )
gap> Size( Range(tci) );
6
gap> s5 := SymmetricGroup( 5 );
Sym( [ 1 .. 5 ] )
gap> a5 := AlternatingGroup( 5 );
Alt( [ 1 .. 5 ] )
gap> endo1 := GroupHomomorphismByFunction( s5, s5,
>   x-> (1,2,3,4,5)^-1 * x * (1,2,3,4,5) );
MappingByFunction( Sym( [ 1 .. 5 ] ), Sym( 
[ 1 .. 5 ] ), function( x ) ... end )
gap> endo2 := GroupHomomorphismByFunction( s5, s5,
>   x-> (1,2)^-1 * x * (1,2) );
MappingByFunction( Sym( [ 1 .. 5 ] ), Sym( 
[ 1 .. 5 ] ), function( x ) ... end )
gap> endo3 := GroupHomomorphismByFunction( s5, s5,
>   function( x )
>   if x in a5 then return ();
>   else return (1,2); fi; end);;
gap> endo4 := GroupHomomorphismByFunction( s5, s5,
>   function( x )
>   if x in a5 then return ();
>   else return (1,2)*(3,4); fi; end);;
gap> endo1 := TransformationRepresentation( endo1 );
<mapping: SymmetricGroup( [ 1 .. 5 ] ) -> SymmetricGroup( [ 1 .. 5 ] ) >
gap> endo2 := TransformationRepresentation( endo2 );
<mapping: SymmetricGroup( [ 1 .. 5 ] ) -> SymmetricGroup( [ 1 .. 5 ] ) >
gap> endo3 := TransformationRepresentation( endo3 );
<mapping: SymmetricGroup( [ 1 .. 5 ] ) -> SymmetricGroup( [ 1 .. 5 ] ) >
gap> endo4 := TransformationRepresentation( endo4 );
<mapping: SymmetricGroup( [ 1 .. 5 ] ) -> SymmetricGroup( [ 1 .. 5 ] ) >
gap> semiendos := Semigroup( endo1, endo2, endo3, endo4 );
<semigroup with 4 generators>
gap> Size( semiendos );
146
gap> phi := IsomorphismTransformationSemigroup( semiendos );
MappingByFunction( <semigroup with 4 generators>, <semigroup with 
4 generators>, function( a ) ... end )
gap> tsemiendos := Range( phi );
<semigroup with 4 generators>
gap> dcl := GreensDClasses( tsemiendos );;
gap> DisplayTransformationSemigroup( tsemiendos );
Rank 120: *[H size = 120, 1 L classes, 1 R classes]
Rank 2: *[H size = 1, 10 L classes, 1 R classes]
Rank 2: [H size = 1, 15 L classes (1 image types), 1 R classes (1 kernel types)]
Rank 1: *[H size = 1, 1 L classes, 1 R classes]
gap> IsGreensLessThanOrEqual( dcl[3], dcl[2] );
true
gap> d2 := dcl[2];;
gap> x := Representative( d2 );;
gap> a := PreImageElm( phi, x);
<mapping: SymmetricGroup( [ 1 .. 5 ] ) -> SymmetricGroup( [ 1 .. 5 ] ) >
gap> a^phi;;
gap> (1,2)^a;
(1,2)
gap> f := FreeGroup( "gamma", "beta", "alpha" );
<free group on the generators [ gamma, beta, alpha ]>
gap> g := GeneratorsOfGroup( f )[ 1 ];
gamma
gap> b := GeneratorsOfGroup( f )[ 2 ];
beta
gap> a := GeneratorsOfGroup( f )[ 3 ];
alpha
gap> relators := [ Comm(a,b)*g^-1, Comm(a,g), Comm(b,g) ];
[ alpha^-1*beta^-1*alpha*beta*gamma^-1, alpha^-1*gamma^-1*alpha*gamma, 
  beta^-1*gamma^-1*beta*gamma ]
gap> h := f/relators;
<fp group on the generators [ gamma, beta, alpha ]>
gap> phi := IsomorphismFpSemigroup( h );
MappingByFunction( <fp group on the generators [ gamma, beta, alpha 
 ]>, <fp semigroup on the generators [ <identity ...>, gamma^-1, gamma, 
  beta^-1, beta, alpha^-1, alpha ]>, function( x ) ... end )
gap> s := Range( phi );
<fp semigroup on the generators [ <identity ...>, gamma^-1, gamma, beta^-1, 
  beta, alpha^-1, alpha ]>
gap> rws := KnuthBendixRewritingSystem( s,
>   IsBasicWreathLessThanOrEqual );;
gap> MakeConfluent( rws );
gap> sgens := GeneratorsOfSemigroup( s );
[ <identity ...>, gamma^-1, gamma, beta^-1, beta, alpha^-1, alpha ]
gap> sgens[2] * sgens[7] = sgens[7] * sgens[2];
true
gap> fgens := FreeGeneratorsOfFpSemigroup( s );
[ <identity ...>, gamma^-1, gamma, beta^-1, beta, alpha^-1, alpha ]
gap> ReducedForm( rws, fgens[2]*fgens[7]);
alpha*gamma^-1
gap> ReducedForm( rws, fgens[7]*fgens[2]);
alpha*gamma^-1
gap> aq := Abelianization(s);
<fp semigroup on the generators [ <identity ...>, gamma^-1, gamma, beta^-1, 
  beta, alpha^-1, alpha ]>
gap> IsFinite(aq);
false



gap> STOP_TEST( "alghom.tst", 60470599 );


#############################################################################
##
#E  braga.tst  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


