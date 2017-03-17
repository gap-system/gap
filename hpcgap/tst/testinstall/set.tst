#############################################################################
##
#W  set.tst                   GAP Library                    Alexander Hulpke
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
##
##  Exclude from testinstall.g: why?
##
gap> START_TEST("set.tst");
gap> a:=Set([(1,3,2),(4,5)]);;
gap> b:=[(1,2),(5,9,7)];;
gap> UniteSet(a,b);
gap> a;  
[ (5,9,7), (4,5), (1,2), (1,3,2) ]
gap> HasIsSSortedList(a);
true
gap> IsSSortedList(a);
true
gap> c:=Union(a,[(5,3,7),(1,2)]);
[ (5,9,7), (4,5), (3,7,5), (1,2), (1,3,2) ]
gap> HasIsSSortedList(c) and IsSSortedList(c);
true
gap> SubtractSet(c,[(1,2),(1,2,3)]);
gap> c;
[ (5,9,7), (4,5), (3,7,5), (1,3,2) ]
gap> HasIsSSortedList(c) and IsSSortedList(c);
true
gap> AddSet(c,5);  
gap> c;
[ 5, (5,9,7), (4,5), (3,7,5), (1,3,2) ]
gap> HasIsSSortedList(c) and IsSSortedList(c);
true
gap> AddSet(a,(5,6));

#gap> HasIsSSortedList(a) and IsSSortedList(a);
#true
gap> c:=Union(a,[(1,2),(1,2,3)]);
[ (5,6), (5,9,7), (4,5), (1,2), (1,2,3), (1,3,2) ]
gap> HasIsSSortedList(c) and IsSSortedList(c);
true
gap> g:=Group((3,11)(4,7)(6,8)(9,10),(1,3)(2,8,10,12)(4,5,6,7)(9,11));;        
gap> l:=AsSortedList(g);;
gap> HasIsSSortedList(l) and IsSSortedList(l);
true
gap> c:=Difference(l,[(3,11)( 4, 7)( 6, 8)( 9,10)]);;
gap> HasIsSSortedList(c) and IsSSortedList(c);
true
gap> Length(c);
7919
gap> c:=Difference(l,a);;                            
gap> c=l;
true
gap> [1..10000] = Set([1..10000], x -> x);
true
gap> [1..10000] = Set([-10000..-1], x -> -x);
true
gap> [0..2016] = Set([1..2017], x -> (x * 503) mod 2017);
true
gap> [0..2016] = Set([1..5000], x -> (x * 503) mod 2017);
true
gap> STOP_TEST( "set.tst", 1);

#############################################################################
##
#E
