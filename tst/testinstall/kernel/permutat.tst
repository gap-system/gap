#
# Tests for functions defined in src/permutat.cc
#
gap> START_TEST("kernel/permutat.tst");

# Reduce the amount printed by CYCLE_STRUCT_PERM by skipping unbound values
gap> CycleStructPermShort := function(p)
>  local ret, i, l;
>  l := CYCLE_STRUCT_PERM(p);
>  ret := [];
>  for i in [1..Length(l)] do
>    if IsBound(l[i]) then
>      Add(ret, [i,l[i]]);
>    fi;
> od;
> return ret;
> end;;
gap> permprops := function(p)
>  local name;
>  for name in ["LARGEST_MOVED_POINT_PERM",
>               "ORDER_PERM", "SIGN_PERM"] do
>      PrintFormatted("{}:{}\n", name, ValueGlobal(name)(p));
>  od;
>  PrintFormatted("CYCLE_SHORT_PERM (short output): {}\n", CycleStructPermShort(p));
> end;;
gap> permprops(());
LARGEST_MOVED_POINT_PERM:0
ORDER_PERM:1
SIGN_PERM:1
CYCLE_SHORT_PERM (short output): [  ]
gap> permprops((1,2));
LARGEST_MOVED_POINT_PERM:2
ORDER_PERM:2
SIGN_PERM:-1
CYCLE_SHORT_PERM (short output): [ [ 1, 1 ] ]
gap> permprops((1,2)(3,4));
LARGEST_MOVED_POINT_PERM:4
ORDER_PERM:2
SIGN_PERM:1
CYCLE_SHORT_PERM (short output): [ [ 1, 2 ] ]
gap> permprops((1,5,4,3,2));
LARGEST_MOVED_POINT_PERM:5
ORDER_PERM:5
SIGN_PERM:1
CYCLE_SHORT_PERM (short output): [ [ 4, 1 ] ]
gap> permprops((1,2)(3,4)(5,6));
LARGEST_MOVED_POINT_PERM:6
ORDER_PERM:2
SIGN_PERM:-1
CYCLE_SHORT_PERM (short output): [ [ 1, 3 ] ]
gap> permprops((1,2^20));
LARGEST_MOVED_POINT_PERM:1048576
ORDER_PERM:2
SIGN_PERM:-1
CYCLE_SHORT_PERM (short output): [ [ 1, 1 ] ]
gap> permprops((1,2,3,4,5)^5);
LARGEST_MOVED_POINT_PERM:0
ORDER_PERM:1
SIGN_PERM:1
CYCLE_SHORT_PERM (short output): [  ]
gap> permprops(PermList(Concatenation([2^17], [1..2^17-1])));
LARGEST_MOVED_POINT_PERM:131072
ORDER_PERM:131072
SIGN_PERM:-1
CYCLE_SHORT_PERM (short output): [ [ 131071, 1 ] ]

# Test the boundary between PERM2 and PERM4
gap> permprops((2^16-1, 2^16));
LARGEST_MOVED_POINT_PERM:65536
ORDER_PERM:2
SIGN_PERM:-1
CYCLE_SHORT_PERM (short output): [ [ 1, 1 ] ]
gap> permprops((2^16-2, 2^16-1));
LARGEST_MOVED_POINT_PERM:65535
ORDER_PERM:2
SIGN_PERM:-1
CYCLE_SHORT_PERM (short output): [ [ 1, 1 ] ]
gap> permprops((2^16-2, 2^16-3));
LARGEST_MOVED_POINT_PERM:65534
ORDER_PERM:2
SIGN_PERM:-1
CYCLE_SHORT_PERM (short output): [ [ 1, 1 ] ]
gap> permprops(PermList(Concatenation([2^16+1], [1..2^16])));
LARGEST_MOVED_POINT_PERM:65537
ORDER_PERM:65537
SIGN_PERM:1
CYCLE_SHORT_PERM (short output): [ [ 65536, 1 ] ]
gap> permprops(PermList(Concatenation([2^16], [1..2^16-1])));
LARGEST_MOVED_POINT_PERM:65536
ORDER_PERM:65536
SIGN_PERM:-1
CYCLE_SHORT_PERM (short output): [ [ 65535, 1 ] ]
gap> permprops(PermList(Concatenation([2^16-1], [1..2^16-2])));
LARGEST_MOVED_POINT_PERM:65535
ORDER_PERM:65535
SIGN_PERM:1
CYCLE_SHORT_PERM (short output): [ [ 65534, 1 ] ]
gap> permprops(PermList(Concatenation([2^16-2], [1..2^16-3])));
LARGEST_MOVED_POINT_PERM:65534
ORDER_PERM:65534
SIGN_PERM:-1
CYCLE_SHORT_PERM (short output): [ [ 65533, 1 ] ]
gap> permprops(PermList(Concatenation([2,1,2^16], [3..2^16-1])));
LARGEST_MOVED_POINT_PERM:65536
ORDER_PERM:65534
SIGN_PERM:1
CYCLE_SHORT_PERM (short output): [ [ 1, 1 ], [ 65533, 1 ] ]
gap> permprops(PermList(Concatenation(List([1,3..2^16-1], x -> [x+1,x]))));
LARGEST_MOVED_POINT_PERM:65536
ORDER_PERM:2
SIGN_PERM:1
CYCLE_SHORT_PERM (short output): [ [ 1, 32768 ] ]

#
gap> RESTRICTED_PERM((1,2), fail, fail);
fail

#
gap> SCR_SIFT_HELPER(fail, fail, fail);
Error, SCR_SIFT_HELPER: <stb> must be a plain record (not the value 'fail')

#
gap> STOP_TEST("kernel/permutat.tst", 1);
