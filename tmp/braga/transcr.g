##################################################
#
# Tutorial- Computing with semigroups in GAP
#
##################################################

####################################
# 1. Endomorphisms of a finite chain

Binomial(7,3)-1;
s1 := Transformation([1,1,3,4]);
s2 := Transformation([1,2,2,4]);
s3 := Transformation([1,2,3,3]);
t1 := Transformation([2,2,3,4]);
t2 := Transformation([1,3,3,4]);
t3 := Transformation([1,2,4,4]);
o4 := Semigroup( s1,s2,s3,t1,t2,t3 );
Size(o4);

# 1.1 On has only Rees congruences

c := SemigroupCongruenceByGeneratingPairs( o4, [[s2*s1,t1*s2]]);
EquivalenceRelationPartition( c );
IsReesCongruence( c );

# 1.2 Green's structure of On

IsRegularSemigroup( o4 );
DisplayTransformationSemigroup( o4 );
dcl := GreensDClasses( o4 );
IsGreensLessThanOrEqual( dcl[2], dcl[1]);
IsGreensLessThanOrEqual( dcl[3], dcl[2]);
DisplayEggBoxOfDClass( dcl[1] );


####################################
# 2. Orientation preserving mappings

# 2.1 Fast transformation semigroup algorithms

s := Transformation( [1,1,3,4,5] );
c := Transformation( [2,3,4,5,1] );
op5 := Semigroup( s,c );
DisplayTransformationSemigroup( op5 );
Size( op5 );
dcl := GreensDClasses(op5);
d4 := dcl[1];
rms := AssociatedReesMatrixSemigroupOfDClass(d4);


# 2.2 Quotient semigroups and Rees matrix semigroups

s := Transformation( [1,1,3] );
c := Transformation( [2,3,1] );
op3 := Semigroup( s,c );
IsRegularSemigroup( op3 );
dcl := GreensDClasses( op3 );
d2 := dcl[1];
d1 := dcl[3];
i2 := SemigroupIdealByGenerators( op3, [Representative( d2 )] );
i1 := SemigroupIdealByGenerators( i2, [Representative( d1 )] );
c1 := ReesCongruenceOfSemigroupIdeal( i1 );
q := i2/c1;
IsZeroSimpleSemigroup( q );
irms := IsomorphismReesMatrixSemigroup( q );
Source( irms);
q = Range( irms );
SandwichMatrixOfZeroReesMatrixSemigroup( Source(irms) );


############################
# 3. The power set semigroup

JoinSetElementSpec :=
	rec( ElementName := "JoinSet",
	Multiplication := function(a,b) return Union(a,b); end,
	MathInfo := IsCommutativeElement);
MakeJoinSet := ArithmeticElementCreator( JoinSetElementSpec );
a := MakeJoinSet( [1,2] );
b := MakeJoinSet( [2,3] );
c := MakeJoinSet( [3,4] );
a*b;
a*b*c;
s := Semigroup( a,b,c );
Elements( s );
f := FreeSemigroup( "x", "y", "z" );
x := GeneratorsOfSemigroup( f )[ 1 ];
y := GeneratorsOfSemigroup( f )[ 2 ];
z := GeneratorsOfSemigroup( f )[ 3 ];
rels := [ [x^2,x], [y^2,y], [z^2, z],
	[x*y,y*x], [x*z,z*x], [x*y*z, x*z], [y*z, z*y] ];
g := f/rels;
psi := NaturalHomomorphismByGenerators( g, s);
gx := GeneratorsOfSemigroup( g )[ 1 ];
gy := GeneratorsOfSemigroup( g )[ 2 ];
gz := GeneratorsOfSemigroup( g )[ 3 ];
gx^psi;
gy^psi;
gz^psi;
Size( g );
tci := IsomorphismTransformationSemigroup( g );
Size( Range(tci) );


#########################################
# 4. Endomorphisms of the symmetric group

s5 := SymmetricGroup( 5 );
a5 := AlternatingGroup( 5 );
endo1 := GroupHomomorphismByFunction( s5, s5,
	x-> (1,2,3,4,5)^-1 * x * (1,2,3,4,5) );
endo2 := GroupHomomorphismByFunction( s5, s5,
	x-> (1,2)^-1 * x * (1,2) );
endo3 := GroupHomomorphismByFunction( s5, s5,
	function( x )
	if x in a5 then return ();
	else return (1,2); fi; end);;
endo4 := GroupHomomorphismByFunction( s5, s5,
	function( x )
	if x in a5 then return ();
	else return (1,2)*(3,4); fi; end);;
endo1 := TransformationRepresentation( endo1 );
endo2 := TransformationRepresentation( endo2 );
endo3 := TransformationRepresentation( endo3 );
endo4 := TransformationRepresentation( endo4 );
semiendos := Semigroup( endo1, endo2, endo3, endo4 );
Size( semiendos );

# 4.1 Finding the Green's structure of End(S5)

phi := IsomorphismTransformationSemigroup( semiendos );
tsemiendos := Range( phi );
dcl := GreensDClasses( tsemiendos );;
DisplayTransformationSemigroup( tsemiendos );
IsGreensLessThanOrEqual( dcl[3], dcl[2] );
d2 := dcl[2];;
x := Representative( d2 );;
a := PreImageElm( phi, x);
a^phi;;
(1,2)^a;


############################################
# 5. An infinite example - The Heisenberg group

# 5.1 Solving the word problem

f := FreeGroup( "gamma", "beta", "alpha" );
g := GeneratorsOfGroup( f )[ 1 ];
b := GeneratorsOfGroup( f )[ 2 ];
a := GeneratorsOfGroup( f )[ 3 ];
relators := [ Comm(a,b)*g^-1, Comm(a,g), Comm(b,g) ];
h := f/relators;
phi := IsomorphismFpSemigroup( h );
s := Range( phi );
rws := KnuthBendixRewritingSystem( s,
	IsBasicWreathLessThanOrEqual );;
MakeConfluent( rws );
sgens := GeneratorsOfSemigroup( s );
sgens[2] * sgens[7] = sgens[7] * sgens[2];
fgens := FreeGeneratorsOfFpSemigroup( s );
ReducedForm( rws, fgens[2]*fgens[7]);
ReducedForm( rws, fgens[7]*fgens[2]);

# 5.2 The Heisenberg group is infinite
aq := Abelianization(s);
IsFinite(aq);
