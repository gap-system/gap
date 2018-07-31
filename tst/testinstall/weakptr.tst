#############################################################################
##
#W  weakptr.tst                GAP Library                       Steve Linton
##
##
#Y  Copyright (C)  1997, 
##
##
gap> START_TEST("weakptr.tst");

#
# Low level access functions
#
gap> w := WeakPointerObj([1,,2^40*10^10,Z(17),[2,3,4],fail,SymmetricGroup(5),]);;
gap> Print(w,"\n");
WeakPointerObj( [ 1, , 10995116277760000000000, Z(17), 
[ 2, 3, 4 ], fail, SymmetricGroup( [ 1 .. 5 ] ) ] )
gap> LengthWPObj(w);
7
gap> val := "cheese";;
gap> GetWithDefault(w, 1, "cheese");
1
gap> IsIdenticalObj(val, GetWithDefault(w, 2, val));
true
gap> IsIdenticalObj(val, GetWithDefault(w, 8, val));
true
gap> List([1..7],x->IsBoundElmWPObj(w,x));
[ true, false, true, true, true, true, true ]
gap> List([1..7],x->ElmWPObj(w,x)); 
[ 1, fail, 10995116277760000000000, Z(17), [ 2, 3, 4 ], fail, 
  Sym( [ 1 .. 5 ] ) ]
gap> SetElmWPObj(w,9,[]);
gap> Print(w,"\n");
WeakPointerObj( [ 1, , 10995116277760000000000, Z(17), 
[ 2, 3, 4 ], fail, SymmetricGroup( [ 1 .. 5 ] ), , [  ] ] )
gap> UnbindElmWPObj(w,4);
gap> Print(w,"\n");
WeakPointerObj( [ 1, , 10995116277760000000000, , 
[ 2, 3, 4 ], fail, SymmetricGroup( [ 1 .. 5 ] ), , [  ] ] )
gap> UnbindElmWPObj(w,9); LengthWPObj(w);
7
gap> 1;;2;;3;;
gap> truevec := [1,,2^40*10^10,(1,5,6),[2,3,4],fail,SymmetricGroup(5),];;
gap> wcopies := List([1..1000], x -> WeakPointerObj([1,,2^40*10^10,(1,5,6),[2,3,4],fail,SymmetricGroup(5),]));;
gap> GASMAN("collect");
gap> ForAll(wcopies, x -> LengthWPObj(x) = 6 or LengthWPObj(x) = 7);
true
gap> ForAny(wcopies, x -> LengthWPObj(x) = 6);
true
gap> ForAll(wcopies, x -> x[1] = 1 and x[6] = fail);
true
gap> ForAll([2,3,4,5,7], x -> ForAny(wcopies, y -> not(IsBound(y[x]))));
true
gap> ForAll([3,4,5,7], x -> ForAny(wcopies, y -> not(IsBound(y[x])) or y[x] = truevec[x]));
true
gap> # Take a filtered list
gap> w := First(wcopies, x -> ForAll([2,3,4,5,7], y -> not(IsBound(x[y])) ) );;
gap> Print(w,"\n");
WeakPointerObj( [ 1, , , , , fail ] )
gap> LengthWPObj(w);
6
gap> Print(ShallowCopy(w),"\n");
WeakPointerObj( [ 1, , , , , fail ] )
gap> List([1..8], x -> GetWithDefault(w, x, -1));
[ 1, -1, -1, -1, -1, fail, -1, -1 ]
gap> GetWithDefault(w, 1, "cheese");
1
gap> IsIdenticalObj(val, GetWithDefault(w, 2, val));
true
gap> IsIdenticalObj(val, GetWithDefault(w, 8, val));
true

#
# Access as lists
#
gap> w[1];
1
gap> l := [ 311 ];; # keep ref so that this list is not garbage collected
gap> w{[2..4]} := [[1,2],E(5),l]; 
[ [ 1, 2 ], E(5), [ 311 ] ]
gap> Print(w,"\n");
WeakPointerObj( [ 1, [ 1, 2 ], E(5), [ 311 ], , fail ] )
gap> Print(StructuralCopy(w),"\n");
WeakPointerObj( [ 1, [ 1, 2 ], E(5), [ 311 ], , fail ] )
gap> Immutable(w);
[ 1, [ 1, 2 ], E(5), [ 311 ],, fail ]
gap> IsBound(w[2]);
true
gap> GASMAN("collect");
gap> IsBound(w[5]);   
false
gap> Unbind(w[2]);
gap> Print(w,"\n");
WeakPointerObj( [ 1, , E(5), [ 311 ], , fail ] )
gap> Immutable(w);
[ 1,, E(5), [ 311 ],, fail ]
gap> w;
WeakPointerObj( [ 1, , E(5), [ 311 ], , fail ] )
gap> MakeImmutable(w);
[ 1,, E(5), [ 311 ],, fail ]
gap> w;
[ 1,, E(5), [ 311 ],, fail ]
gap> IsMutable(w);
false
gap> ForAny(w, IsMutable);
false

#
# test recursive MakeImmutable
#
gap> w := WeakPointerObj([ ~ ]);;
gap> MakeImmutable(w);
[ [ ~[1] ] ]

#
gap> w := WeakPointerObj([ 1 ]);;
gap> w[1] := w;;
gap> MakeImmutable(w);
[ ~ ]

#
gap> w := WeakPointerObj([ rec() ]);;
gap> w[1].self := w;;
gap> MakeImmutable(w);
[ rec( self := ~ ) ]

#
gap> STOP_TEST( "weakptr.tst", 1);
