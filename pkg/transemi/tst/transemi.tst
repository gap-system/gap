#############################################################################
##
#W  transemi.tst        GAP Semiroups         Andrew Solomon 
##
#H  @(#)$Id: transemi.tst,v 1.3 2002/09/09 11:45:09 gap Exp $
##
#Y  Copyright (C)  1999,  University of St. Andrews
##

gap> START_TEST("$Id: transemi.tst,v 1.3 2002/09/09 11:45:09 gap Exp $");
gap> RequirePackage("transemi");
true
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
gap> c := SemigroupCongruenceByGeneratingPairs( o4, [[s2*s1,t1*s2]]);
<semigroup congruence with 1 generating pairs>
gap> eq :=EquivalenceRelationPartition( c );;
gap> t := [ [ Transformation( [ 1, 1, 1, 1 ] ), 
> Transformation( [ 1, 1, 1, 2 ] ), Transformation( [ 1, 1, 1, 3 ] ), 
> Transformation( [ 1, 1, 1, 4 ] ), Transformation( [ 1, 1, 2, 2 ] ), 
> Transformation( [ 1, 1, 3, 3 ] ), Transformation( [ 1, 1, 4, 4 ] ), 
> Transformation( [ 1, 2, 2, 2 ] ), Transformation( [ 1, 3, 3, 3 ] ), 
> Transformation( [ 1, 4, 4, 4 ] ), Transformation( [ 2, 2, 2, 2 ] ), 
> Transformation( [ 2, 2, 2, 3 ] ), Transformation( [ 2, 2, 2, 4 ] ), 
> Transformation( [ 2, 2, 3, 3 ] ), Transformation( [ 2, 2, 4, 4 ] ), 
> Transformation( [ 2, 3, 3, 3 ] ), Transformation( [ 2, 4, 4, 4 ] ), 
> Transformation( [ 3, 3, 3, 3 ] ), Transformation( [ 3, 3, 3, 4 ] ), 
> Transformation( [ 3, 3, 4, 4 ] ), Transformation( [ 3, 4, 4, 4 ] ), 
> Transformation( [ 4, 4, 4, 4 ] ) ] ];; 
gap> Set(Flat(eq))=Set(Flat(t));
true
gap> IsReesCongruence( c );
true
gap> IsRegularSemigroup( o4 );
true
gap> dcl := GreensDClasses( o4 );;
gap> t := [ Transformation( [ 1, 1, 3, 4 ] ), 
> Transformation( [ 1, 1, 1, 4 ] ), 
> Transformation( [ 1, 1, 1, 1 ] ) ];;
gap> ForAll(t, x->GreensDClassOfElement(o4,x) in dcl);
true
gap> IsGreensLessThanOrEqual( GreensDClassOfElement(o4,t[2]),
> GreensDClassOfElement(o4,t[1]));
true
gap> IsGreensLessThanOrEqual( GreensDClassOfElement(o4,t[3]),
> GreensDClassOfElement(o4,t[2]));
true
#gap> DisplayEggBoxOfDClass( dcl[1] );
#[ [  1,  0,  1,  0 ],
#  [  1,  1,  0,  0 ],
#  [  0,  1,  0,  1 ] ]
gap> s := Transformation( [1,1,3,4,5] );
Transformation( [ 1, 1, 3, 4, 5 ] )
gap> c := Transformation( [2,3,4,5,1] );
Transformation( [ 2, 3, 4, 5, 1 ] )
gap> op5 := Semigroup( s,c );
<semigroup with 2 generators>
gap> Size( op5 );
610
gap> dcl := GreensDClasses(op5);;
gap> t:= [ Transformation( [ 1, 1, 3, 4, 5 ] ), 
> Transformation( [ 2, 3, 4, 5, 1 ] ),Transformation( [ 1, 1, 4, 5, 1 ] ),
> Transformation( [ 1, 1, 5, 1, 1 ] ), Transformation( [ 1, 1, 1, 1, 1 ] )];;
gap> ForAll(t, x->GreensDClassOfElement(op5,x) in dcl);
true
gap> d4 := dcl[1];;
gap> rms := AssociatedReesMatrixSemigroupOfDClass(d4);
Rees Zero Matrix Semigroup over Monoid( [ (), (1,5,4,3), 0 ], ... )
gap> rcl := GreensRClasses(op5);;
gap> t:= [Transformation( [ 1, 1, 3, 4, 5 ] ), 
> Transformation( [ 1, 3, 4, 5, 1 ] ), Transformation( [ 3, 4, 5, 1, 1 ] ),
> Transformation( [ 4, 5, 1, 1, 3 ] ), Transformation( [ 5, 1, 1, 3, 4 ] ),
> Transformation( [ 2, 3, 4, 5, 1 ] ), 
> Transformation( [ 1, 1, 4, 5, 1 ] ), Transformation( [ 1, 4, 5, 1, 1 ] ),
> Transformation( [ 4, 4, 5, 1, 1 ] ), 
> Transformation( [ 4, 5, 1, 1, 1 ] ), Transformation( [ 4, 5, 1, 1, 4 ] ),
> Transformation( [ 1, 1, 4, 4, 5 ] ), 
> Transformation( [ 5, 1, 1, 1, 4 ] ), Transformation( [ 5, 1, 1, 4, 4 ] ),
> Transformation( [ 1, 4, 4, 5, 1 ] ), 
> Transformation( [ 1, 1, 1, 4, 5 ] ), Transformation( [ 1, 1, 5, 1, 1 ] ),
> Transformation( [ 1, 5, 1, 1, 1 ] ), 
> Transformation( [ 1, 1, 5, 5, 5 ] ), Transformation( [ 1, 1, 5, 5, 1 ] ),
> Transformation( [ 5, 1, 1, 1, 1 ] ), 
> Transformation( [ 1, 5, 5, 5, 1 ] ), Transformation( [ 1, 5, 5, 1, 1 ] ),
> Transformation( [ 1, 1, 1, 1, 5 ] ), 
> Transformation( [ 5, 5, 5, 1, 1 ] ), Transformation( [ 1, 1, 1, 5, 1 ] ),
> Transformation( [ 1, 1, 1, 1, 1 ] ) ];;
gap> ForAll(t, x->GreensRClassOfElement(op5,x) in rcl);
true
gap> lcl := GreensLClasses(op5);;
gap> t :=[ Transformation( [ 1, 1, 3, 4, 5 ] ), 
> Transformation( [ 2, 2, 4, 5, 1 ] ), Transformation( [ 3, 3, 5, 1, 2 ] ), 
> Transformation( [ 4, 4, 1, 2, 3 ] ), Transformation( [ 5, 5, 2, 3, 4 ] ),
> Transformation( [ 2, 3, 4, 5, 1 ] ), 
> Transformation( [ 1, 1, 4, 5, 1 ] ), Transformation( [ 2, 2, 5, 1, 2 ] ),
> Transformation( [ 3, 3, 1, 2, 3 ] ), 
> Transformation( [ 4, 4, 2, 3, 4 ] ), Transformation( [ 4, 4, 1, 3, 4 ] ),
> Transformation( [ 5, 5, 3, 4, 5 ] ), 
> Transformation( [ 5, 5, 2, 4, 5 ] ), Transformation( [ 1, 1, 3, 5, 1 ] ),
> Transformation( [ 2, 2, 4, 1, 2 ] ), 
> Transformation( [ 3, 3, 5, 2, 3 ] ), Transformation( [ 1, 1, 5, 1, 1 ] ),
> Transformation( [ 2, 2, 1, 2, 2 ] ), 
> Transformation( [ 3, 3, 2, 3, 3 ] ), Transformation( [ 3, 3, 1, 3, 3 ] ),
> Transformation( [ 4, 4, 3, 4, 4 ] ), 
> Transformation( [ 4, 4, 2, 4, 4 ] ), Transformation( [ 5, 5, 4, 5, 5 ] ),
> Transformation( [ 4, 4, 1, 4, 4 ] ), 
> Transformation( [ 5, 5, 3, 5, 5 ] ), Transformation( [ 5, 5, 2, 5, 5 ] ),
> Transformation( [ 1, 1, 1, 1, 1 ] ), 
> Transformation( [ 2, 2, 2, 2, 2 ] ), Transformation( [ 3, 3, 3, 3, 3 ] ),
> Transformation( [ 4, 4, 4, 4, 4 ] ), 
> Transformation( [ 5, 5, 5, 5, 5 ] ) ];;
gap> ForAll(t, x->GreensLClassOfElement(op5,x) in lcl);
true
gap> GenSchutzenbergerGroup(dcl[1]);
Group([ (), (1,5,4,3) ])
gap> GenSchutzenbergerGroup(dcl[2]);
Group([ (1,2,3,4,5) ])
gap> GenSchutzenbergerGroup(dcl[3]);
Group([ (), (1,4,5), (1,5,4) ])
gap> STOP_TEST( "transemi.tst", 30000000 );

#############################################################################
##
#E  transemi.tst . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##


