#@local g,h,l,l2,p2,perm,t,filt,lcpy,permsp,old_paras,G,U,tr
gap> START_TEST("listgen.tst");
gap> List( [ 1 .. 10 ], x -> x^2 );
[ 1, 4, 9, 16, 25, 36, 49, 64, 81, 100 ]
gap> List( [ 2, 1, 2, 1 ], x -> x - 1 );
[ 1, 0, 1, 0 ]
gap> List();
Error, usage: List( <C>[, <func>] )
gap> List([1..10], x->x^2, "extra argument");
Error, usage: List( <C>[, <func>] )
gap> List([,1,,3,4], x->x>2);
[ , false,, true, true ]
gap> IsMutable(List([1,2,3],x->x^2));
true
gap> Flat( List( [ 1 .. 5 ], x -> [ 1 .. x ] ) );
[ 1, 1, 2, 1, 2, 3, 1, 2, 3, 4, 1, 2, 3, 4, 5 ]
gap> Reversed( [ 1, 2, 1, 2 ] );
[ 2, 1, 2, 1 ]
gap> Print(Reversed( [ 1 .. 10 ] ),"\n");
[ 10, 9 .. 1 ]
gap> filt:= Filtered( [ 1 .. 10 ], x -> x < 5 );
[ 1, 2, 3, 4 ]
gap> HasIsSSortedList( filt );
true
gap> filt:= Filtered( [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ], x -> x < 5 );
[ 1, 2, 3, 4 ]
gap> HasIsSSortedList( filt );
false
gap> Number( [ 1 .. 10 ], x -> x < 5 );
4
gap> Number( [ 1 .. 10 ] );
10
gap> Compacted( [ 1,, 2,, 3,, 4 ] );
[ 1, 2, 3, 4 ]
gap> Collected( [ 1, 2, 3, 4, 1, 2, 3, 1, 2, 1 ] );
[ [ 1, 4 ], [ 2, 3 ], [ 3, 2 ], [ 4, 1 ] ]
gap> ForAll( [ 1 .. 10 ], IsInt );
true
gap> ForAny( [ 1 .. 10 ], x -> x > 5 );
true
gap> First( [ 1 .. 10 ], x -> x > 5 );
6
gap> PositionProperty( [ 1, 3 .. 9 ], x -> x > 4 );
3
gap> PositionBound( [ ,,,, 1 ] );
5
gap> PositionBound( [] );
fail
gap> PositionNot( [ 2, 1 ], 1 );
1
gap> PositionNot( [ 1, 2 ], 1 );
2
gap> PositionNot( [ 1, 1 ], 1 );
3
gap> PositionNot( [ 1, 1 ], 1, 3 );
4
gap> PositionNonZero( [ 1, 1 ] );
1
gap> PositionNonZero( [ 0, 1 ] );
2
gap> PositionNonZero( [ 0, 0 ] );
3
gap> PositionNonZero( [ 0, 0 ], 3 );
4
gap> l:= [ 1 .. 10 ];;
gap> SortParallel( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ], l );
gap> l;
[ 4, 1, 2, 3, 5, 10, 8, 9, 7, 6 ]
gap> SortParallel( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ], l,
>               function( x, y ) return y < x; end );
gap> l;
[ 10, 8, 7, 9, 6, 5, 2, 1, 4, 3 ]
gap> l :=  [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ];;
gap> SortBy(l,AdditiveInverseSameMutability);
gap> l;
[ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]
gap> l2 := [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ];;
gap> lcpy := List(l2);;
gap> permsp := SortingPerm(l2);
(1,2,3,4)(6,10)(7,9,8)
gap> l2 = lcpy;
true
gap> perm:= Sortex(l2);
(1,2,3,4)(6,10)(7,9,8)
gap> SortingPerm(l2);
()
gap> Sortex(l2);
()
gap> IsSet(l2);
true
gap> Permuted( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ], perm );
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> Product( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ] );
3628800
gap> Product( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ], x -> x^2 );
13168189440000
gap> Sum( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ] );
55
gap> Sum( [ 2, 3, 4, 1, 5, 10, 9, 7, 8, 6 ], x -> x^2 );
385
gap> Iterated( l, \+ );
55
gap> Iterated( l, \* );
3628800
gap> ListN( [1,2], [3,4], \+ );
[ 4, 6 ]
gap> MaximumList( l );
10
gap> MaximumList( [ 1, 2 .. 20 ] );
20
gap> MaximumList( [ 10, 8 .. 2 ] );
10
gap> MinimumList( l );
1
gap> MinimumList( [ 1, 2 .. 20 ] );
1
gap> MinimumList( [ 10, 8 .. 2 ] );
2
gap> PositionMaximum([2,4,6,4,2,6]);
3
gap> PositionMaximum([2,4,6,4,2,6], x -> -x);
1
gap> PositionMinimum([2,4,6,4,2,6]);
1
gap> PositionMinimum([2,4,6,4,2,6], x -> -x);
3
gap> PositionMaximum();
Error, Usage: PositionMaximum(<list>, [<func>])
gap> PositionMaximum(2);
Error, Usage: PositionMaximum(<list>, [<func>])
gap> PositionMaximum([1,2], 2);
Error, Usage: PositionMaximum(<list>, [<func>])
gap> PositionMaximum([1,2], x -> x, 2);
Error, Usage: PositionMaximum(<list>, [<func>])
gap> PositionMinimum();
Error, Usage: PositionMinimum(<list>, [<func>])
gap> PositionMinimum([1,2], 2);
Error, Usage: PositionMinimum(<list>, [<func>])
gap> PositionMinimum(2);
Error, Usage: PositionMinimum(<list>, [<func>])
gap> PositionMinimum([1,2], x -> x, 2);
Error, Usage: PositionMinimum(<list>, [<func>])
gap> PositionMaximum([]);
fail
gap> PositionMaximum([,,,]);
fail
gap> PositionMaximum([2,,4,,6]);
5
gap> PositionMinimum([2,,4,,6]);
1
gap> PositionMinimum([,,,]);
fail
gap> PositionMinimum([]);
fail
gap> String( l );
"[ 10, 9, 8, 7, 6, 5, 4, 3, 2, 1 ]"
gap> String( [ 1 .. 10 ] );
"[ 1 .. 10 ]"

# right transversals
gap> g:=Group((1,5)(2,6)(3,7)(4,8),(1,3)(2,4)(5,7)(6,8),(1,2)(3,4)(5,6)(7,8), 
> (5,6)(7,8), (5,7)(6,8), (3,4)(7,8), (3,5)(4,6), (2,3)(6,7));;
gap> h:=Subgroup(g,[(5,6)(7,8),(5,7)(6,8),(2,4)(6,8),(2,5)(4,7),(1,2)(3,4)]);;
gap> t:=RightTransversal(g,h);;
gap> Position(t,(5,7)(6,8));
fail
gap> IsSSortedList(t);
true
gap> p2:=Position(t,(5,7)(6,8));
fail

# right transversals, see pull request #6114
gap> old_paras:= [ BITLIST_LIMIT_TRANSVERSAL, MAX_SIZE_TRANSVERSAL ];;
gap> BITLIST_LIMIT_TRANSVERSAL:= 59;;
gap> MAX_SIZE_TRANSVERSAL:= 59;;
gap> G:= Group( [   # the group is equal to AtlasGroup( "J1" )
>   (  1,262)(  2,107)(  3, 21)(  4,213)(  5,191)(  6, 22)(  7,133)
>   (  8,234)(  9,232)( 10,151)( 11,139)( 12,176)( 13,202)( 14,253)( 15,222)
>   ( 17,195)( 18,206)( 19, 68)( 20, 55)( 23,179)( 24,217)( 25,216)( 26,256)
>   ( 27, 87)( 28, 70)( 29,131)( 30, 44)( 31,105)( 32,170)( 33, 77)( 34,104)
>   ( 35,198)( 36,137)( 37,243)( 38, 56)( 39,124)( 40,223)( 41,134)( 43,174)
>   ( 46, 51)( 47,128)( 48, 94)( 49,250)( 50,264)( 52,183)( 53,231)( 54,115)
>   ( 57, 85)( 58,233)( 59,261)( 60, 95)( 61,235)( 62,177)( 63,249)( 64, 91)
>   ( 65,247)( 66,155)( 69,219)( 71,237)( 72,211)( 73, 84)( 74,192)( 75,130)
>   ( 76,251)( 79,260)( 80,112)( 81,193)( 82,156)( 83,242)( 86,238)( 88,143)
>   ( 89,168)( 90,148)( 92,119)( 93,212)( 96,150)( 97,199)( 98,140)( 99,189)
>   (100,180)(101,147)(102,111)(103,159)(106,162)(108,194)(109,166)(110,200)
>   (113,120)(114,141)(116,182)(117,181)(118,225)(121,254)(122,125)(123,146)
>   (126,208)(127,221)(129,210)(132,255)(136,175)(138,207)(142,240)(144,172)
>   (145,185)(149,224)(152,169)(153,241)(154,190)(157,214)(158,161)(160,236)
>   (163,239)(164,229)(165,230)(167,188)(171,258)(173,186)(178,245)(184,205)
>   (187,228)(197,203)(201,252)(209,248)(215,259)(218,246)(220,227)(257,263)
>   (265,266), (  1,146, 21)(  2,132, 82)(  4,156,166)(  5,242,253)
>   (  6,107, 28)(  7,125, 76)(  8,245,130)(  9,174, 42)( 10,241,244)
>   ( 11,264, 63)( 12,248,234)( 13, 36, 44)( 14,116,128)( 15, 47, 25)
>   ( 16,178,112)( 17,170,110)( 18,197, 74)( 19,233,180)( 20,121, 96)
>   ( 22,228,155)( 23, 48,173)( 24,201,187)( 26,136,190)( 27,212, 94)
>   ( 29,175, 52)( 30, 77, 32)( 31,237, 34)( 33,226, 90)( 35,129, 54)
>   ( 37,161,114)( 38,232, 87)( 39,219,192)( 40, 78,159)( 41,139, 71)
>   ( 43,211,251)( 45,222,240)( 46, 97,135)( 49, 70,131)( 50,153,200)
>   ( 51,186,209)( 53,203,216)( 55,169, 64)( 56,140,230)( 57,260,118)
>   ( 58, 91,243)( 59,199,227)( 60,108,164)( 61,208,101)( 62,206,106)
>   ( 65,103, 66)( 67, 95,205)( 68, 73,225)( 69,151,113)( 72,221,152)
>   ( 75,143,202)( 79,217,254)( 80, 93,122)( 81,181,252)( 83,258,126)
>   ( 84,163,177)( 85,154,213)( 86,182,196)( 88,133,215)( 89,117,247)
>   ( 92,191,160)( 99,229,263)(100,138,188)(102,194,157)(105,149,184)
>   (109,123,193)(111,137,183)(115,238,235)(119,167,147)(120,134,189)
>   (124,185,265)(127,218,261)(141,231,210)(142,239,236)(144,224,249)
>   (145,158,220)(148,214,172)(150,250,259)(162,257,256)(165,179,246)
>   (176,195,266)(198,204,207)(223,262,255) ] );;
gap> U:= TrivialSubgroup( G );;
gap> tr:= RightTransversalPermGroupConstructor(
>           IsRightTransversalPermGroupRep, G, U );;
gap> Length( tr ) = Size( G );
true
gap> PositionCanonical( tr, GeneratorsOfGroup( G )[1] ) <= Length( tr );
true
gap> BITLIST_LIMIT_TRANSVERSAL:= old_paras[1];;
gap> MAX_SIZE_TRANSVERSAL:= old_paras[2];;

# that's all, folks
gap> STOP_TEST("listgen.tst");
