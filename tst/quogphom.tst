#############################################################################
##
#W  quogphom.tst                   GAP library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1998,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##

gap> START_TEST("$Id$");
# quogphom

gap> G := Group( [ (1,2), (3,4) ] ); 
Group([ (1,2), (3,4) ])
gap> H := Group( [ (1,2) ] );
Group([ (1,2) ])
gap> h := GroupHomomorphismByImages( G, H, [(1,2), (3,4)], [(1,2), (1,2)] );
[ (1,2), (3,4) ] -> [ (1,2), (1,2) ]
gap> Q := QuotientGroupByImages( G, H, [(1,2), (3,4)], [(1,2), (1,2)] );
Group([ ( (1,2) <- (1,2) ), ( (1,2) <- (3,4) ) ])
gap> Q.1; Q.2;
( (1,2) <- (1,2) )
( (1,2) <- (3,4) )
gap> IsPerm(Q.1); IsHomCosetOfPerm(Q.1); 
true
true
gap> IsPermGroup(Q); IsHomQuotientGroup(Q);
true
true
gap> Q.1=Q.2;
true
gap> one := Q.1*Q.2;
( () <- (1,2)(3,4) )
gap> IsOne(one);
true
gap> One(Q);
( () <- () )
gap> 1^Q.1;  Q.1^Q.2;  Comm(Q.1, Q.2);
2
( (1,2) <- (1,2) )
( () <- () )
gap> Q.1^2; Q.1^0; Q.1^-1;
( () <- () )
( () <- () )
( (1,2) <- (1,2) )
gap> Order(Q.1);
2
gap> SmallestMovedPointPerm(Q.1);  LargestMovedPointPerm(Q.2);
1
2
#CanonicalElt(Q.1); -- doesn't work with current settings of control vars
#
#Check that Canonical elt indep of elt in coset
#Q := QuotientGroupByImages( SymmetricGroup(5), Group( [ (1,2) ] ),
#	[ (1,2), (1,2,3,4,5) ], [ (1,2), () ] );
#for i in [1..10] do
#    r := Random(Q);
#    Print( r, "\t", CanonicalElt(r), "\n" );
#od;
gap> G := Group( [ (1,2), (3,4) ] );
Group([ (1,2), (3,4) ])
gap> H := GL(2,2);
SL(2,2)
gap> Q := QuotientGroupByImages( G, H, [(1,2), (3,4)], [One(H), One(H)] );
Group([ ( <an immutable 2x2 matrix over GF2> <- (1,2) ), 
  ( <an immutable 2x2 matrix over GF2> <- (3,4) ) ])
gap> IsMatrix(Q.1); IsMatrixGroup(Q);
true
true
gap> Q.1[2];
<an immutable GF2 vector of length 2>
gap> One(Q) = One(H);
false
gap> Length(Q.1);
2

gap> STOP_TEST( "quogphom.tst", 17600000 );


#############################################################################
##
#E  
##
