#############################################################################
##
#W  trans.tst
#Y  James D. Mitchell
##
#############################################################################
##

#
gap> START_TEST("trans.tst");
gap> display := UserPreference("TransformationDisplayLimit");;
gap> notation := UserPreference("NotationForTransformations");;
gap> SetUserPreference("TransformationDisplayLimit", 100);;
gap> SetUserPreference("NotationForTransformations", "input");;

# Test the kernel code 
#
# Test TransformationNC
gap> TransformationNC([2, 1, 1]);
Transformation( [ 2, 1, 1 ] )
gap> TransformationNC([1 .. 3]);
IdentityTransformation
gap> TransformationNC(List([1 .. 65537], i -> 1));
<transformation on 65537 pts with rank 1>
gap> IsTrans4Rep(last);
true
gap> TransformationNC(List([1 .. 65536], i -> 1));
<transformation on 65536 pts with rank 1>
gap> IsTrans2Rep(last);
true

# Test TransformationListListNC 
gap> TransformationListListNC("a", [1, 2, 3]);
Error, TransformationListListNC: <src> and <ran> must have equal length,
gap> TransformationListListNC([1], [1, 2, 3]);
Error, TransformationListListNC: <src> and <ran> must have equal length,
gap> TransformationListListNC("abc", [1, 2, 3]);
Error, TransformationListListNC: <src>[3] must be a small integer (not a chara\
cter)
gap> TransformationListListNC([1, 2, 3], "abc");
Error, TransformationListListNC: <ran>[3] must be a small integer (not a chara\
cter)
gap> TransformationListListNC([-1, 2, 3], [4, 5, 6]);
Error, TransformationListListNC: <src>[1] must be greater than 0
gap> TransformationListListNC([1, 2, 3], [4, -5, 6]);
Error, TransformationListListNC: <ran>[2] must be greater than 0
gap> TransformationListListNC([1, 2, 3], [4, 5, 6]);
Transformation( [ 4, 5, 6, 4, 5, 6 ] )
gap> TransformationListListNC([1, 2, 3], [65536, 65536, 65536]);
<transformation on 65536 pts with rank 65533>
gap> TransformationListListNC([1, 2, 3], [65537, 65537, 65537]);
<transformation on 65537 pts with rank 65534>
gap> TransformationListListNC([2, 1, 3], [4, 4, 4]);
Transformation( [ 4, 4, 4, 4 ] )
gap> TransformationListListNC((), ());
Error, TransformationListListNC: <src> must be a list (not a permutation (smal\
l))
gap> TransformationListListNC([], ());
Error, TransformationListListNC: <ran> must be a list (not a permutation (smal\
l))
gap> TransformationListListNC([], []);
IdentityTransformation

# Test DegreeOfTransformation
gap> f := TransformationListListNC([1, 2], [1, 1]) ^ (3, 4);;
gap> DegreeOfTransformation(f);
2
gap> f := TransformationListListNC([1, 2], [1, 1]) ^ (3, 65537);;
gap> DegreeOfTransformation(f);
2
gap> DegreeOfTransformation(());
Error, DegreeOfTransformation: the argument must be a transformation (not a pe\
rmutation (small))

# Test RANK_TRANS
gap> RANK_TRANS(Transformation([1, 2, 3]));
0
gap> RANK_TRANS(Transformation([1, 2, 1]));
2
gap> RANK_TRANS(Transformation([1, 2, 1]) ^ (4, 65537));
2
gap> RANK_TRANS("a");
Error, RANK_TRANS: the argument must be a transformation (not a list (string))
gap> RANK_TRANS(IdentityTransformation);
0
gap> RANK_TRANS(Transformation([1 .. 10]));
0

# Test RANK_TRANS_INT
gap> RANK_TRANS_INT(Transformation([1, 2, 1]), 0);
0
gap> RANK_TRANS_INT(Transformation([1, 2, 1]), 2);
2
gap> RANK_TRANS_INT(Transformation([1, 2, 1]), -2);
Error, RANK_TRANS_INT: <n> must be a non-negative integer
gap> RANK_TRANS_INT(Transformation([1, 2, 1]), "a");
Error, RANK_TRANS_INT: <n> must be a non-negative integer
gap> RANK_TRANS_INT("a", 2);
Error, RANK_TRANS_INT: <f> must be a transformation (not a list (string))
gap> RANK_TRANS_INT(Transformation([65537], [1]), 10);
10

# Test RANK_TRANS_LIST
gap> RANK_TRANS_LIST(Transformation([1, 2, 1]), 2);
Error, RANK_TRANS_LIST: the second argument must be a list (not a integer)
gap> RANK_TRANS_LIST(Transformation([1, 2, 1]), "a");
Error, RANK_TRANS_LIST: the second argument <list> must be a list of positive \
integers (not a character)
gap> RANK_TRANS_LIST(Transformation([1, 2, 1]) ^ (1, 65537), "a");
Error, RANK_TRANS_LIST: the second argument <list> must be a list of positive \
integers (not a character)
gap> RANK_TRANS_LIST(Transformation([1, 2, 1]), [1, 3]);
1
gap> RANK_TRANS_LIST(Transformation([1, 2, 1, 5, 5]), [1 .. 10]);
8
gap> RANK_TRANS_LIST(Transformation([1, 2, 1, 5, 5]), []);
0
gap> RANK_TRANS_LIST("a", [1, 3]);
Error, RANK_TRANS_LIST: the first argument must be a transformation (not a lis\
t (string))
gap> RANK_TRANS_LIST(Transformation([65537], [1]), 
>                    Concatenation([1], [65536 .. 70000]));
4465
gap> RANK_TRANS_LIST(Transformation([65537], [1]), []);
0

# Test IS_ID_TRANS
gap> IS_ID_TRANS(IdentityTransformation);
true
gap> IS_ID_TRANS(Transformation([2, 1]) ^ 2);
true
gap> IS_ID_TRANS(Transformation([65537, 1], [1, 65537]) ^ 2);
true
gap> IS_ID_TRANS(());
Error, IS_ID_TRANS: the first argument must be a transformation (not a permuta\
tion (small))

# Test LARGEST_MOVED_PT_TRANS
gap> LARGEST_MOVED_PT_TRANS(IdentityTransformation);
0
gap> LARGEST_MOVED_PT_TRANS(Transformation([1, 2, 1, 4, 5]));
3
gap> LARGEST_MOVED_PT_TRANS(Transformation([65537], [1]));
65537
gap> LARGEST_MOVED_PT_TRANS("a");
Error, LARGEST_MOVED_PT_TRANS: the first argument must be a transformation (no\
t a list (string))

# Test LARGEST_IMAGE_PT
gap> LARGEST_IMAGE_PT(IdentityTransformation);
0
gap> LARGEST_IMAGE_PT(Transformation([1, 2, 1, 4, 5]));
2
gap> LARGEST_IMAGE_PT(Transformation([65537], [1]));
65536
gap> LARGEST_IMAGE_PT("a");
Error, LARGEST_IMAGE_PT: the first argument must be a transformation (not a li\
st (string))

# Test SMALLEST_MOVED_PT_TRANS
gap> SMALLEST_MOVED_PT_TRANS(IdentityTransformation);
fail
gap> SMALLEST_MOVED_PT_TRANS(Transformation([1, 2, 1, 4, 5]));
3
gap> SMALLEST_MOVED_PT_TRANS(Transformation([65537], [1]));
65537
gap> SMALLEST_MOVED_PT_TRANS("a");
Error, SMALLEST_MOVED_PTS_TRANS: the first argument must be a transformation (\
not a list (string))

# Test SMALLEST_IMAGE_PT
gap> SMALLEST_IMAGE_PT(IdentityTransformation);
fail
gap> SMALLEST_IMAGE_PT(Transformation([1, 2, 1, 4, 5]));
1
gap> SMALLEST_IMAGE_PT(Transformation([65537], [1]));
1
gap> SMALLEST_IMAGE_PT("a");
Error, SMALLEST_IMAGE_PT: the first argument must be a transformation (not a l\
ist (string))

# Test NR_MOVED_PTS_TRANS
gap> NR_MOVED_PTS_TRANS(IdentityTransformation);
0
gap> NR_MOVED_PTS_TRANS(Transformation([1, 2, 1, 4, 5]));
1
gap> NR_MOVED_PTS_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]));
7
gap> NR_MOVED_PTS_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1));
4464
gap> NR_MOVED_PTS_TRANS("a");
Error, NR_MOVED_PTS_TRANS: the first argument must be a transformation (not a \
list (string))

# Test MOVED_PTS_TRANS
gap> MOVED_PTS_TRANS(IdentityTransformation);
[  ]
gap> MOVED_PTS_TRANS(Transformation([1, 2, 1, 4, 5]));
[ 3 ]
gap> MOVED_PTS_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]));
[ 3, 6, 7, 8, 9, 10, 11 ]
gap> MOVED_PTS_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1)) 
> = [65537 .. 70000];
true
gap> MOVED_PTS_TRANS(Transformation([2, 3, 1]) ^ 3);
[  ]
gap> MOVED_PTS_TRANS("a");
Error, MOVED_PTS_TRANS: the first argument must be a transformation (not a lis\
t (string))

# Test FLAT_KERNEL_TRANS
gap> FLAT_KERNEL_TRANS(IdentityTransformation);
[  ]
gap> FLAT_KERNEL_TRANS(Transformation([1, 2, 1, 4, 5]));
[ 1, 2, 1, 3, 4 ]
gap> FLAT_KERNEL_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]));
[ 1, 2, 1, 3, 4, 1, 1, 1, 1, 1, 1 ]
gap> FLAT_KERNEL_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1)) 
> = Concatenation([1 .. 65536], [65537 .. 70000] * 0 + 1);
true
gap> FLAT_KERNEL_TRANS("a");
Error, FLAT_KERNEL_TRANS: the first argument must be a transformation (not a l\
ist (string))

# Test FLAT_KERNEL_TRANS_INT
gap> FLAT_KERNEL_TRANS_INT(IdentityTransformation, -1);
Error, FLAT_KERNEL_TRANS_INT: the second argument must be a non-negative integ\
er
gap> FLAT_KERNEL_TRANS_INT(IdentityTransformation, "a");
Error, FLAT_KERNEL_TRANS_INT: the second argument must be a non-negative integ\
er
gap> FLAT_KERNEL_TRANS_INT(IdentityTransformation, 10);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> FLAT_KERNEL_TRANS_INT(IdentityTransformation, 0);
[  ]
gap> FLAT_KERNEL_TRANS_INT(Transformation([1, 2, 1, 4, 5]), 0);
[  ]
gap> FLAT_KERNEL_TRANS_INT(Transformation([1, 2, 1, 4, 5]), 3);
[ 1, 2, 1 ]
gap> FLAT_KERNEL_TRANS_INT(Transformation([1, 2, 1, 4, 5]), 10);
[ 1, 2, 1, 3, 4, 5, 6, 7, 8, 9 ]
gap> FLAT_KERNEL_TRANS_INT(Transformation([1, 2, 1, 4, 5]), 5);
[ 1, 2, 1, 3, 4 ]
gap> FLAT_KERNEL_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 0);
[  ]
gap> FLAT_KERNEL_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 7);
[ 1, 2, 1, 3, 4, 1, 1 ]
gap> FLAT_KERNEL_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 14);
[ 1, 2, 1, 3, 4, 1, 1, 1, 1, 1, 1, 5, 6, 7 ]
gap> FLAT_KERNEL_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 11);
[ 1, 2, 1, 3, 4, 1, 1, 1, 1, 1, 1 ]
gap> FLAT_KERNEL_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 70000) 
> = Concatenation([1 .. 65536], [65537 .. 70000] * 0 + 1);
true
gap> FLAT_KERNEL_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 65555) 
> = Concatenation([1 .. 65536], [65537 .. 65555] * 0 + 1);
true
gap> FLAT_KERNEL_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 70010) 
> = Concatenation([1 .. 65536], [65537 .. 70000] * 0 + 1, List([1 .. 10], x -> x + 65536));
true
gap> FLAT_KERNEL_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 10);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> FLAT_KERNEL_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 0);
[  ]
gap> FLAT_KERNEL_TRANS_INT("a", 2);
Error, FLAT_KERNEL_TRANS_INT: the first argument must be a transformation (not\
 a list (string))

# Test IMAGE_SET_TRANS
gap> IMAGE_SET_TRANS(IdentityTransformation);
[  ]
gap> IMAGE_SET_TRANS(Transformation([1, 2, 1, 4, 5]));
[ 1, 2, 4, 5 ]
gap> IsSet(last);
true
gap> IMAGE_SET_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]));
[ 1, 2, 4, 5 ]
gap> IsSet(last);
true
gap> IMAGE_SET_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1)) 
> = [1 .. 65536];
true
gap> IMAGE_SET_TRANS("a");
Error, UNSORTED_IMAGE_SET_TRANS: the argument must be a transformation (not a \
list (string))
gap> IMAGE_SET_TRANS(Transformation([2, 1, 2, 4, 5]));
[ 1, 2, 4, 5 ]
gap> IsSet(last);
true
gap> IMAGE_SET_TRANS(Transformation([4, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]));
[ 1, 2, 4, 5 ]
gap> IsSet(last);
true
gap> IMAGE_SET_TRANS(Transformation([1], [65537])) 
> = [2 .. 65537];
true
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> IMAGE_SET_TRANS(f);
[  ]
gap> FLAT_KERNEL_TRANS(f);
[  ]

# Test IMAGE_SET_TRANS_INT
gap> IMAGE_SET_TRANS_INT(IdentityTransformation, -1);
Error, IMAGE_SET_TRANS_INT: the second argument must be a non-negative integer
gap> IMAGE_SET_TRANS_INT(IdentityTransformation, "a");
Error, IMAGE_SET_TRANS_INT: the second argument must be a non-negative integer
gap> IMAGE_SET_TRANS_INT(IdentityTransformation, 10);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> IMAGE_SET_TRANS_INT(IdentityTransformation, 0);
[  ]
gap> IMAGE_SET_TRANS_INT(Transformation([1, 2, 1, 4, 5]), 0);
[  ]
gap> IMAGE_SET_TRANS_INT(Transformation([2, 1, 1, 4, 5]), 3);
[ 1, 2 ]
gap> IMAGE_SET_TRANS_INT(Transformation([2, 1, 1, 4, 5]), 10);
[ 1, 2, 4, 5, 6, 7, 8, 9, 10 ]
gap> IMAGE_SET_TRANS_INT(Transformation([1, 2, 1, 4, 5]), 5);
[ 1, 2, 4, 5 ]
gap> IMAGE_SET_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 0);
[  ]
gap> IMAGE_SET_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 7);
[ 1, 2, 4, 5 ]
gap> IMAGE_SET_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 14);
[ 1, 2, 4, 5, 12, 13, 14 ]
gap> IMAGE_SET_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 11);
[ 1, 2, 4, 5 ]
gap> IMAGE_SET_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 70000) 
> = [1 .. 65536];
true
gap> IMAGE_SET_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 65555) 
> = [1 .. 65536];
true
gap> IMAGE_SET_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 70010) 
> = Concatenation([1 .. 65536], List([1 .. 10], x -> x + 70000));
true
gap> IMAGE_SET_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 10);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> IMAGE_SET_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 0);
[  ]
gap> IMAGE_SET_TRANS_INT("a", 2);
Error, IMAGE_SET_TRANS_INT: the first argument must be a transformation (not a\
 list (string))

# Test IMAGE_LIST_TRANS_INT
gap> IMAGE_LIST_TRANS_INT(IdentityTransformation, -1);
Error, IMAGE_LIST_TRANS_INT: the second argument must be a non-negative intege\
r
gap> IMAGE_LIST_TRANS_INT(IdentityTransformation, "a");
Error, IMAGE_LIST_TRANS_INT: the second argument must be a non-negative intege\
r
gap> IMAGE_LIST_TRANS_INT(IdentityTransformation, 10);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> IMAGE_LIST_TRANS_INT(IdentityTransformation, 0);
[  ]
gap> IMAGE_LIST_TRANS_INT(Transformation([1, 2, 1, 4, 5]), 0);
[  ]
gap> IMAGE_LIST_TRANS_INT(Transformation([2, 1, 1, 4, 5]), 3);
[ 2, 1, 1 ]
gap> IMAGE_LIST_TRANS_INT(Transformation([2, 1, 1, 4, 5]), 10);
[ 2, 1, 1, 4, 5, 6, 7, 8, 9, 10 ]
gap> IMAGE_LIST_TRANS_INT(Transformation([1, 2, 1, 4, 5]), 5);
[ 1, 2, 1, 4, 5 ]
gap> IMAGE_LIST_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 0);
[  ]
gap> IMAGE_LIST_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 7);
[ 1, 2, 1, 4, 5, 1, 1 ]
gap> IMAGE_LIST_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 14);
[ 1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1, 12, 13, 14 ]
gap> IMAGE_LIST_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 11);
[ 1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1 ]
gap> IMAGE_LIST_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 70000) 
> = Concatenation([1 .. 65536], [65537 .. 70000] * 0 + 1);
true
gap> IMAGE_LIST_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 65555) 
> = Concatenation([1 .. 65536], [65537 .. 65555] * 0 + 1);
true
gap> IMAGE_LIST_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 70010) 
> = Concatenation([1 .. 65536], [65537 .. 70000] * 0 + 1, List([1 .. 10], x -> x + 70000));
true
gap> IMAGE_LIST_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 10);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> IMAGE_LIST_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 0);
[  ]
gap> IMAGE_LIST_TRANS_INT("a", 2);
Error, IMAGE_LIST_TRANS_INT: the first argument must be a transformation (not \
a list (string))

# Test KERNEL_TRANS 1
gap> KERNEL_TRANS(IdentityTransformation, -1);
Error, KERNEL_TRANS: the second argument must be a non-negative integer
gap> KERNEL_TRANS(IdentityTransformation, "a");
Error, KERNEL_TRANS: the second argument must be a non-negative integer
gap> KERNEL_TRANS(IdentityTransformation, 10);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]
gap> KERNEL_TRANS(IdentityTransformation, 0);
[  ]
gap> KERNEL_TRANS(Transformation([1, 2, 1, 4, 5]), 0);
[  ]
gap> KERNEL_TRANS(Transformation([1, 2, 1, 4, 5]), 3);
[ [ 1, 3 ], [ 2 ] ]
gap> KERNEL_TRANS(Transformation([1, 2, 1, 4, 5]), 10);
[ [ 1, 3 ], [ 2 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]
gap> KERNEL_TRANS(Transformation([1, 2, 1, 4, 5]), 5);
[ [ 1, 3 ], [ 2 ], [ 4 ], [ 5 ] ]
gap> KERNEL_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 0);
[  ]
gap> KERNEL_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 7);
[ [ 1, 3, 6, 7 ], [ 2 ], [ 4 ], [ 5 ] ]
gap> KERNEL_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 14);
[ [ 1, 3, 6, 7, 8, 9, 10, 11 ], [ 2 ], [ 4 ], [ 5 ], [ 12 ], [ 13 ], [ 14 ] ]
gap> KERNEL_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 11);
[ [ 1, 3, 6, 7, 8, 9, 10, 11 ], [ 2 ], [ 4 ], [ 5 ] ]
gap> KERNEL_TRANS("a", 2);
Error, KERNEL_TRANS: the first argument must be a transformation (not a list (\
string))
gap> KERNEL_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 10);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]
gap> KERNEL_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 0);
[  ]

# Test KERNEL_TRANS 2
gap> f := Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1);; 
gap> ker := KERNEL_TRANS(f, 70000);;
gap> Length(ker) = RankOfTransformation(f, 70000);
true
gap> Union(ker) = [1 .. 70000];
true
gap> max := Maximum(List(ker, Length));
4465
gap> tmp := First(ker, x -> Length(x) = max);;                  
gap> ForAll(tmp, x -> x ^ f = tmp[1] ^ f);
true
gap> Filtered([1 .. DegreeOfTransformation(f)], x -> x ^ f = tmp[1] ^ f) = tmp;
true

# Test KERNEL_TRANS 3
gap> f := Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1);; 
gap> ker := KERNEL_TRANS(f, 65555);;
gap> Length(ker) = RankOfTransformation(f, 65555);
true
gap> Union(ker) = [1 .. 65555];
true
gap> max := Maximum(List(ker, Length));
20
gap> tmp := First(ker, x -> Length(x) = max);;                   
gap> ForAll(tmp, x -> x ^ f = tmp[1] ^ f);
true
gap> Filtered([1 .. 65555], x -> x ^ f = tmp[1] ^ f) = tmp;
true

# Test KERNEL_TRANS 4
gap> f := Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1);; 
gap> ker := KERNEL_TRANS(f, 70010);;
gap> Length(ker) = RankOfTransformation(f, 70010);
true
gap> Union(ker) = [1 .. 70010];
true
gap> max := Maximum(List(ker, Length));
4465
gap> tmp := First(ker, x -> Length(x) = max);;
gap> ForAll(tmp, x -> x ^ f = tmp[1] ^ f);
true
gap> Filtered([1 .. 70010], x -> x ^ f = tmp[1] ^ f) = tmp;
true

# Test PREIMAGES_TRANS_INT
gap> PREIMAGES_TRANS_INT(IdentityTransformation, 0);
Error, PREIMAGES_TRANS_INT: the second argument must be a positive integer
gap> PREIMAGES_TRANS_INT(IdentityTransformation, -1);
Error, PREIMAGES_TRANS_INT: the second argument must be a positive integer
gap> PREIMAGES_TRANS_INT(IdentityTransformation, "a");
Error, PREIMAGES_TRANS_INT: the second argument must be a positive integer
gap> PREIMAGES_TRANS_INT("a", 2);
Error, PREIMAGES_TRANS_INT: the first argument must be a transformation (not a\
 list (string))
gap> PREIMAGES_TRANS_INT(IdentityTransformation, 10);
[ 10 ]
gap> PREIMAGES_TRANS_INT(Transformation([2, 1, 1, 4, 5]), 3);
[  ]
gap> PREIMAGES_TRANS_INT(Transformation([2, 1, 1, 4, 5]), 1);
[ 2, 3 ]
gap> PREIMAGES_TRANS_INT(Transformation([2, 1, 1, 4, 5]), 10);
[ 10 ]
gap> PREIMAGES_TRANS_INT(Transformation([1, 2, 1, 4, 5]), 2);
[ 2 ]
gap> PREIMAGES_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 1);
[ 1, 3, 6, 7, 8, 9, 10, 11 ]
gap> PREIMAGES_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 14);
[ 14 ]
gap> PREIMAGES_TRANS_INT(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 11);
[  ]
gap> PREIMAGES_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 1) 
> = Concatenation([1], [65537 .. 70000]);
true
gap> PREIMAGES_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 2);
[ 2 ]
gap> PREIMAGES_TRANS_INT(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 65555);
[  ]

# Test AS_TRANS_PERM_INT
gap> AS_TRANS_PERM_INT((1, 2, 3), "a");
Error, AS_TRANS_PERM_INT: the second argument must be a non-negative integer
gap> AS_TRANS_PERM_INT((1, 2, 3), -1);
Error, AS_TRANS_PERM_INT: the second argument must be a non-negative integer
gap> AS_TRANS_PERM_INT("a", 3);
Error, AS_TRANS_PERM_INT: the first argument must be a permutation (not a list\
 (string))
gap> AS_TRANS_PERM_INT((1, 2, 3), 0);
IdentityTransformation
gap> AS_TRANS_PERM_INT((1, 2, 3), 1);
Transformation( [ 2, 2 ] )
gap> AS_TRANS_PERM_INT((1, 2, 3), 2);
Transformation( [ 2, 3, 3 ] )
gap> AS_TRANS_PERM_INT((1, 2, 3), 3);
Transformation( [ 2, 3, 1 ] )
gap> AsPermutation(last) = (1, 2, 3);
true
gap> AS_TRANS_PERM_INT((1, 65537), 0);
IdentityTransformation
gap> AS_TRANS_PERM_INT((1, 65537), 1);
<transformation on 65537 pts with rank 65536>
gap> f := AS_TRANS_PERM_INT((1, 65537), 2);
<transformation on 65537 pts with rank 65536>
gap> PREIMAGES_TRANS_INT(f, 65537);
[ 1, 65537 ]
gap> last in KernelOfTransformation(f);
true
gap> AS_TRANS_PERM_INT((1, 65537), 3);
<transformation on 65537 pts with rank 65536>
gap> AS_TRANS_PERM_INT((1, 65537), 65537);
<transformation on 65537 pts with rank 65537>
gap> AsPermutation(last) = (1, 65537);
true
gap> AS_TRANS_PERM_INT((1, 2)(3, 65537), 2);
Transformation( [ 2, 1 ] )

# Test AS_TRANS_PERM
gap> AS_TRANS_PERM((1, 2, 3));
Transformation( [ 2, 3, 1 ] )
gap> AS_TRANS_PERM("a");
Error, AS_TRANS_PERM: the first argument must be a permutation (not a list (st\
ring))
gap> AS_TRANS_PERM((1, 65537));
<transformation on 65537 pts with rank 65537>
gap> AS_TRANS_PERM((1, 65537) * (1, 65537));
IdentityTransformation
gap> AS_TRANS_PERM((1, 37) * (1, 37));
IdentityTransformation

# Test AS_PERM_TRANS
gap> AS_PERM_TRANS(Transformation([2, 3, 1]));
(1,2,3)
gap> AS_PERM_TRANS(Transformation([2, 3, 2]));
fail
gap> AS_PERM_TRANS(Transformation([1, 65537], [65537, 1]));
(1,65537)
gap> AS_PERM_TRANS(Transformation([1, 65537], [65537, 65537]));
fail
gap> AS_PERM_TRANS(());
Error, AS_PERM_TRANS: the first argument must be a transformation (not a permu\
tation (small))

# Test PermutationOfImage
gap> PermutationOfImage(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]));
fail
gap> PermutationOfImage(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6]));
fail
gap> PermutationOfImage(Transformation([65537], [1]));
()
gap> PermutationOfImage(Transformation([1, 2, 3, 4, 5, 6, 7, 8, 9, 1]));
()
gap> PermutationOfImage(Transformation([2, 3, 1, 4, 5, 6, 7, 8, 9, 2]));
(1,2,3)
gap> PermutationOfImage(Transformation([1 .. 65537], x -> x + 1));
fail
gap> PermutationOfImage(1);
Error, PermutationOfImage: the first argument must be a transformation (not a \
integer)

# Test RestrictedTransformation
gap> RestrictedTransformation(IdentityTransformation, [1, -1]);
Error, RestrictedTransformation: <list>[2] must be a positive  integer (not a \
integer)
gap> RestrictedTransformation(IdentityTransformation, "a");
Error, RestrictedTransformation: <list>[1] must be a positive  integer (not a \
character)
gap> RestrictedTransformation(IdentityTransformation, [1,, 3]);
Error, List Element: <list>[2] must have an assigned value
gap> RestrictedTransformation(IdentityTransformation, [1 .. 10]);
IdentityTransformation
gap> RestrictedTransformation(IdentityTransformation, [0]);
Error, RestrictedTransformation: <list>[1] must be a positive  integer (not a \
integer)
gap> RestrictedTransformation(Transformation([1, 2, 1, 4, 5]), [1, 3, 5]);
Transformation( [ 1, 2, 1 ] )
gap> RestrictedTransformation(Transformation([2, 1, 1, 4, 5]), [1 .. 3]);
Transformation( [ 2, 1, 1 ] )
gap> RestrictedTransformation(Transformation([2, 1, 1, 4, 5]), [1 .. 10]);
Transformation( [ 2, 1, 1 ] )
gap> RestrictedTransformation(Transformation([1, 2, 1, 4, 5]), [1 .. 5]);
Transformation( [ 1, 2, 1 ] )
gap> RestrictedTransformation(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 0);
Error, RestrictedTransformation: the second argument must be a list (not a int\
eger)
gap> RestrictedTransformation(Transformation([65537 .. 70000], 
>                                    [65537 .. 70000] * 0 + 1), [1 .. 65536]);
IdentityTransformation
gap> RestrictedTransformation(Transformation([65537 .. 70000], 
>                                    [65537 .. 70000] * 0 + 1), [65537 .. 65555]);
<transformation on 65555 pts with rank 65536>
gap> RestrictedTransformation(Transformation([65537 .. 70000], 
>                                    [65537 .. 70000] * 0 + 1), [1, -1]);
Error, RestrictedTransformation: <list>[2] must be a positive  integer (not a \
integer)
gap> RestrictedTransformation("a", [1 .. 10]);
Error, RestrictedTransformation: the first argument must be a transformation (\
not a list (string))
gap> RestrictedTransformation(Transformation([3, 2, 3]), [1]);
Transformation( [ 3, 2, 3 ] )
gap> RestrictedTransformation(Transformation([1], [65537]), [1]);
<transformation on 65537 pts with rank 65536>

# Test AS_TRANS_TRANS
gap> AS_TRANS_TRANS(IdentityTransformation, -1);
Error, AS_TRANS_TRANS: the second argument must be a non-negative integer (not\
 a integer)
gap> AS_TRANS_TRANS(IdentityTransformation, "a");
Error, AS_TRANS_TRANS: the second argument must be a non-negative integer (not\
 a list (string))
gap> AS_TRANS_TRANS(IdentityTransformation, 3);
IdentityTransformation
gap> AS_TRANS_TRANS(IdentityTransformation, 10);
IdentityTransformation
gap> AS_TRANS_TRANS(IdentityTransformation, 0);
IdentityTransformation
gap> AS_TRANS_TRANS(Transformation([1, 2, 1, 4, 5]), 3);
Transformation( [ 1, 2, 1 ] )
gap> AS_TRANS_TRANS(Transformation([1, 2, 1, 4, 5]), 7);
Transformation( [ 1, 2, 1 ] )
gap> AS_TRANS_TRANS(Transformation([2, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 1);
fail
gap> AS_TRANS_TRANS(Transformation([65537 .. 70000], 
>                                  [65537 .. 70000] * 0 + 1), 65536);
IdentityTransformation
gap> AS_TRANS_TRANS(Transformation([65537 .. 70000], 
>                                  [65537 .. 70000] * 0 + 1), 65555);
<transformation on 65555 pts with rank 65536>
gap> AS_TRANS_TRANS(Transformation([65537 .. 70000], 
>                                  [65537 .. 70000] * 0 + 1), 70010);
<transformation on 70000 pts with rank 65536>
gap> AS_TRANS_TRANS(Transformation([65537 .. 70000], 
>                                  [65537 .. 70000] * 0 + 1), 0);
IdentityTransformation
gap> AS_TRANS_TRANS(Transformation([65537], [70000]), 65537); 
fail
gap> AS_TRANS_TRANS(Transformation([1], [65537]), 1);
fail
gap> AS_TRANS_TRANS(Transformation([1], [65537]), 0);
IdentityTransformation
gap> AS_TRANS_TRANS("a", 10);
Error, AS_TRANS_TRANS: the first argument must be a transformation (not a list\
 (string))

# Test TRIM_TRANS
gap> TRIM_TRANS(IdentityTransformation, -1);
Error, TRIM_TRANS: the second argument must be a non-negative integer (not a i\
nteger)
gap> TRIM_TRANS(IdentityTransformation, "a");
Error, TRIM_TRANS: the second argument must be a non-negative integer (not a l\
ist (string))
gap> TRIM_TRANS(IdentityTransformation, 3);
gap> TRIM_TRANS(IdentityTransformation, 10);
gap> TRIM_TRANS(IdentityTransformation, 0);
gap> TRIM_TRANS(Transformation([1, 2, 1, 1, 1]), 3);
gap> TRIM_TRANS(Transformation([1, 2, 1, 1, 1]), 7);
gap> TRIM_TRANS(Transformation([65537 .. 70000], 
>                              [65537 .. 70000] * 0 + 1), 65536);
gap> TRIM_TRANS(Transformation([65537 .. 70000], 
>                              [65537 .. 70000] * 0 + 1), 10);
gap> TRIM_TRANS(Transformation([65537 .. 70000], 
>                              [65537 .. 70000] * 0 + 1), 65555);
gap> TRIM_TRANS(Transformation([65537 .. 70000], 
>                              [65537 .. 70000] * 0 + 1), 70010);
gap> TRIM_TRANS(Transformation([65537 .. 70000], 
>                              [65537 .. 70000] * 0 + 1), 0);
gap> TRIM_TRANS("a", 10);
Error, TRIM_TRANS: the first argument must be a transformation (not a list (st\
ring))

# Test for the issue with caching the degree of a transformation in PR #384
gap> x := Transformation([1, 1]) ^ (1,2)(3,70000);
Transformation( [ 2, 2 ] )
gap> IsTrans4Rep(x);
true
gap> HASH_FUNC_FOR_TRANS(x, 101);;
gap> x;
Transformation( [ 2, 2 ] )
gap> x := Transformation([1, 1]) ^ (1,70000);
<transformation on 70000 pts with rank 69999>
gap> IsTrans4Rep(x);
true
gap> HASH_FUNC_FOR_TRANS(x, 101);;

# Test IsInjectiveListTrans
gap> f := Transformation([9, 3, 2, 3, 1, 8, 2, 7, 8, 3, 12, 10]);;
gap> IsInjectiveListTrans([1, 2, 3, 6, 5], f);
true
gap> IsInjectiveListTrans([1 .. 5], f);     
false
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> IsInjectiveListTrans(ImageSetOfTransformation(f), f);
true
gap> IsInjectiveListTrans([1 .. RankOfTransformation(f) + 1], f);   
false
gap> IsInjectiveListTrans([1 .. RankOfTransformation(f) + 1], 
>                            ImageListOfTransformation(f));
false
gap> f := Transformation([12, 3, 4, 12, 1, 2, 12, 1, 5, 1, 10, 7]);;
gap> IsInjectiveListTrans([1 .. 3], f);                    
true
gap> IsInjectiveListTrans([1 .. 4], f);
false
gap> IsInjectiveListTrans([1 .. 4], ImageListOfTransformation(f));
false
gap> IsInjectiveListTrans([1 .. 3], ImageListOfTransformation(f));
true
gap> f := Transformation([11, 9, 3, 8, 10, 11, 6, 1, 8, 8, 4, 11]);;
gap> RankOfTransformation(f);
8
gap> IsInjectiveListTrans([1 .. 5], f);                           
true
gap> IsInjectiveListTrans([1 .. 6], f);
false
gap> f := Transformation([5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6]);;
gap> IsInjectiveListTrans([2, 3], f);
true
gap> IsInjectiveListTrans([2, 3, 4, 7], f);
true
gap> IsInjectiveListTrans([2, 3, 4, 5, 7], f);
false
gap> IsInjectiveListTrans([65536], f);
true
gap> IsInjectiveListTrans([1 .. 65536], f);
false
gap> IsInjectiveListTrans([1 .. 65536], ImageListOfTransformation(f));
false
gap> IsInjectiveListTrans([65536], ImageListOfTransformation(f));
true

# Test PermLeftQuoTransformationNC
gap> f := Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6]);;
gap> PermLeftQuoTransformationNC(f, f);
()
gap> p := (1, 9, 10, 8)(4, 5, 6);;
gap> PermLeftQuoTransformationNC(f * p, f);
(1,8,10,9)(4,6,5)
gap> PermLeftQuoTransformationNC(f * p, f ^ (20, 21));
(1,8,10,9)(4,6,5)
gap> PermLeftQuoTransformationNC(f, f * p);   
(1,9,10,8)(4,5,6)
gap> p := (1, 8, 4, 6, 3, 10, 5);;
gap> PermLeftQuoTransformationNC(f, f * p);
(1,8,4,6,3,10,5)
gap> PermLeftQuoTransformationNC(f * p, f);                     
(1,5,10,3,6,4,8)
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1) 
>         * (1,65, 1414, 13485)(139, 1943, 858, 65536);;
gap> p := (1, 10, 20)(414, 1441, 59265);; 
gap> PermLeftQuoTransformationNC(f * p, f) = p ^ -1;
true
gap> PermLeftQuoTransformationNC(f, f * p) = p;   
true
gap> f := Transformation([2, 6, 7, 2, 6, 9, 9, 1, 11, 1, 12, 5]);;
gap> PermLeftQuoTransformationNC(f, f * (1, 2, 3));
(1,2,3)
gap> g := f * (1, 2, 5);;
gap> PermLeftQuoTransformationNC(f, g);
(1,2,5)
gap> PermLeftQuoTransformationNC(g, f);
(1,5,2)
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> g := f * (12849, 19491, 3501, 1593)(1341, 19414, 194)(1413, 19);;
gap> p := PermLeftQuoTransformationNC(f, g);
(19,1413)(194,1341,19414)(1593,12849,19491,3501)
gap> p := PermLeftQuoTransformationNC(f, g ^ (70001, 70002));
(19,1413)(194,1341,19414)(1593,12849,19491,3501)
gap> q := PermLeftQuoTransformationNC(g, f);
(19,1413)(194,19414,1341)(1593,3501,19491,12849)
gap> p = q ^ -1;
true
gap> q = p ^ -1;
true
gap> PermLeftQuoTransformationNC((), IdentityTransformation);
Error, PermLeftQuoTransformationNC: the arguments must both be transformations\
 (not permutation (small) and transformation (small))
gap> PermLeftQuoTransformationNC(IdentityTransformation, ());
Error, PermLeftQuoTransformationNC: the arguments must both be transformations\
 (not transformation (small) and permutation (small))
gap> PermLeftQuoTransformationNC((), ());
Error, PermLeftQuoTransformationNC: the arguments must both be transformations\
 (not permutation (small) and permutation (small))
gap> g := Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6]);;
gap> f := (g ^ (2, 20)) * (1, 3, 8)(6, 9);;
gap> PermLeftQuoTransformationNC(f, g);
(1,20)(2,8,3)(6,9)
gap> f := Transformation([3, 8, 1, 9, 1, 3, 10, 5, 10, 6]);;
gap> g := (f ^ (2, 65537)) *  (1, 3, 8)(6, 9);;
gap> PermLeftQuoTransformationNC(f, g);
(1,3,8,2)(6,9)
gap> PermLeftQuoTransformationNC(g, f);
(1,65537)(2,8,3)(6,9)
gap> g := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> f := g ^ (70001, 70002);;
gap> PermLeftQuoTransformationNC(f, g);
()

# Test TRANS_IMG_KER_NC
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> g := TRANS_IMG_KER_NC(ImageSetOfTransformation(f),
>                          FlatKernelOfTransformation(f));;
gap> g = TRANS_IMG_KER_NC(ImageSetOfTransformation(g), 
>                         FlatKernelOfTransformation(g));
true
gap> f := Transformation([4, 6, 9, 3, 9, 5, 11, 6, 3, 8, 7, 1]);;
gap> g := TRANS_IMG_KER_NC(ImageSetOfTransformation(f),
>                          FlatKernelOfTransformation(f));
Transformation( [ 1, 3, 4, 5, 4, 6, 7, 3, 5, 8, 9, 11 ] )
gap> FlatKernelOfTransformation(g) = FlatKernelOfTransformation(f);
true
gap> ImageSetOfTransformation(g) = ImageSetOfTransformation(f);
true
gap> f := Transformation([7, 1, 4, 5, 4, 2, 5, 7, 6, 4, 1, 4]);;
gap> g := TRANS_IMG_KER_NC(ImageSetOfTransformation(f),
> FlatKernelOfTransformation(f));
Transformation( [ 1, 2, 4, 5, 4, 6, 5, 1, 7, 4, 2, 4 ] )
gap> KernelOfTransformation(g) = KernelOfTransformation(f);
true
gap> ImageSetOfTransformation(f) = ImageSetOfTransformation(g);
true
gap> g ^ 2 = g;
false
gap> TRANS_IMG_KER_NC([5, 4 .. 1], [1 .. 5]);
Transformation( [ 5, 4, 3, 2, 1 ] )

# Test IDEM_IMG_KER_NC
gap> f := AsTransformation((4,21,13,62,7,56,9,77,91,43,99)
>                          (14,27,87,72,57,85));;
gap> g := IDEM_IMG_KER_NC(ImageSetOfTransformation(f),
>                         FlatKernelOfTransformation(f));;
gap> g = f ^ 0;
true
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> g := IDEM_IMG_KER_NC(ImageSetOfTransformation(f),
>                          FlatKernelOfTransformation(f));;
gap> g ^ 2 = g;
true
gap> f := Transformation([4, 6, 9, 3, 9, 5, 11, 6, 3, 8, 7, 1]) ^ 4;;
gap> g := IDEM_IMG_KER_NC(ImageSetOfTransformation(f),
>                         FlatKernelOfTransformation(f));
Transformation( [ 3, 3, 3, 9, 3, 9, 7, 3, 9, 9, 11, 9 ] )
gap> g ^ 2 = g;
true
gap> f = g;
true
gap> FlatKernelOfTransformation(g) = FlatKernelOfTransformation(f);
true
gap> ImageSetOfTransformation(g) = ImageSetOfTransformation(f);
true
gap> f := Transformation([9, 1, 4, 5, 4, 2, 5, 9, 6, 4, 1, 4]);;
gap> g := IDEM_IMG_KER_NC(ImageSetOfTransformation(f),
>                         FlatKernelOfTransformation(f));
Transformation( [ 1, 2, 5, 4, 5, 6, 4, 1, 9, 5, 2, 5 ] )
gap> g ^ 2 = g;
true
gap> KernelOfTransformation(g) = KernelOfTransformation(f);
true
gap> ImageSetOfTransformation(f) = ImageSetOfTransformation(g);
true
gap> g ^ 2 = g;
true
gap> IDEM_IMG_KER_NC([5, 4 .. 1], [1 .. 5]);
IdentityTransformation

# Test InverseOfTransformation
gap> InverseOfTransformation(IdentityTransformation);
IdentityTransformation
gap> f := Transformation( [ 5, 9, 1, 7, 9, 5, 2, 8, 4, 1 ] );;
gap> g := InverseOfTransformation(f);
Transformation( [ 3, 7, 1, 9, 1, 1, 4, 8, 2, 1 ] )
gap> f * g * f = f and g * f * g = g;
true
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> g := InverseOfTransformation(f);;
gap> f * g * f = f and g * f * g = g;
true
gap> g := InverseOfTransformation(1);
Error, InverseOfTransformation: the argument must be a transformation (not a i\
nteger)

# Test INV_LIST_TRANS
gap> f := Transformation([9, 3, 2, 3, 1, 8, 2, 7, 8, 3, 12, 10]);;
gap> g := INV_LIST_TRANS([1, 2, 3, 6, 5], f);
Transformation( [ 5, 3, 2, 4, 5, 6, 7, 6, 1 ] )
gap> ForAll([1, 2, 3, 6, 5], i -> (i ^ f) ^ g = i);
true
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> g := INV_LIST_TRANS(ImageSetOfTransformation(f), f);
IdentityTransformation
gap> ForAll(ImageSetOfTransformation(f), i -> (i ^ f) ^ g = i);
true
gap> f := Transformation([12, 3, 4, 12, 1, 2, 12, 1, 5, 1, 10, 7]);;
gap> g := INV_LIST_TRANS([1 .. 3], f);                    
Transformation( [ 1, 2, 2, 3, 5, 6, 7, 8, 9, 10, 11, 1 ] )
gap> ForAll([1 .. 3], i -> (i ^ f) ^ g = i);
true
gap> f := Transformation([11, 9, 3, 8, 10, 11, 6, 1, 8, 8, 4, 11]);;
gap> g := INV_LIST_TRANS([1 .. 5], f);                           
Transformation( [ 1, 2, 3, 4, 5, 6, 7, 4, 2, 5, 1 ] )
gap> ForAll([1 .. 5], i -> (i ^ f) ^ g = i);
true
gap> f := Transformation([5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6]);;
gap> g := INV_LIST_TRANS([2, 3], f);
Transformation( [ 1, 2, 3, 4, 2 ] )
gap> ForAll([2, 3], i -> (i ^ f) ^ g = i);
true
gap> g := INV_LIST_TRANS([2, 3, 4, 7], f);
Transformation( [ 1, 7, 3, 4, 2, 6, 7, 8, 9, 4 ] )
gap> ForAll([2, 3, 4, 7], i -> (i ^ f) ^ g = i);
true
gap> g := INV_LIST_TRANS([65536], f);
IdentityTransformation
gap> INV_LIST_TRANS([1, -1], f);
Error, INV_LIST_TRANS: <list>[2] must be a positive integer (not a integer)
gap> INV_LIST_TRANS("a", f);
Error, INV_LIST_TRANS: <list>[1] must be a positive integer (not a character)
gap> INV_LIST_TRANS(0, f);
Error, INV_LIST_TRANS: the first argument must be a list (not a integer)
gap> INV_LIST_TRANS([1, 2], "a");
Error, INV_LIST_TRANS: the second argument must be a transformation (not a lis\
t (string))
gap> INV_LIST_TRANS([1, -1], Transformation([1], [65537]));
Error, INV_LIST_TRANS: <list>[2] must be a positive integer (not a integer)

# IndexPeriodOfTransformation
gap> f := Transformation([4, 3, 8, 9, 3, 5, 8, 10, 5, 6, 2, 8]);;
gap> val := IndexPeriodOfTransformation(f);
[ 3, 5 ]
gap> ind := val[1];; per := val[2];;
gap> RankOfTransformation(f ^ (ind - 1), DegreeOfTransformation(f)) > 
>    RankOfTransformation(f ^ ind, DegreeOfTransformation(f));
true
gap> f ^ (ind + per) = f ^ ind;
true
gap> ForAny([1 .. per - 1], m -> f ^ (ind + m) = f ^ ind);
false
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1) 
>         * (14918, 184, 141)(14140, 124);;
gap> val := IndexPeriodOfTransformation(f);
[ 1, 6 ]
gap> ind := val[1];; per := val[2];;
gap> RankOfTransformation(f ^ (ind - 1), DegreeOfTransformation(f)) > 
>    RankOfTransformation(f ^ ind, DegreeOfTransformation(f));
true
gap> f ^ (ind + per) = f ^ ind;
true
gap> ForAny([1 .. per - 1], m -> f ^ (ind + m) = f ^ ind);
false
gap> f := Transformation([1, 65537, 2, 4, 6], 
>                        [65537, 2, 3, 5, 7]);;
gap> IndexPeriodOfTransformation(f);
[ 3, 1 ]
gap> f := Transformation(
> [5, 23, 27, 8, 21, 49, 36, 33, 4, 44, 3, 49, 48, 18, 10, 30, 47, 3, 41, 35, 
>  33, 15, 39, 19, 37, 24, 26, 2, 16, 47, 9, 7, 28, 47, 25, 21, 50, 23, 18, 42, 26, 
>  40, 40, 4, 43, 27, 45, 35, 40, 14]);;
gap> val := IndexPeriodOfTransformation(f);
[ 14, 4 ]
gap> ind := val[1];; per := val[2];;
gap> RankOfTransformation(f ^ (ind - 1), DegreeOfTransformation(f)) > 
>    RankOfTransformation(f ^ ind, DegreeOfTransformation(f));
true
gap> f ^ (ind + per) = f ^ ind;
true
gap> ForAny([1 .. per - 1], m -> f ^ (ind + m) = f ^ ind);
false
gap> f ^ 18 = f ^ 14;
true
gap> f :=
> Transformation( [ 74, 33, 77, 60, 65, 37, 24, 22, 16, 49, 58, 16, 62, 7, 69,
>  38, 97, 44, 56, 5, 3, 74, 89, 28, 95, 94, 56, 6, 38, 58, 45, 63, 32, 32,
>  38, 27, 36, 28, 81, 41, 85, 95, 55, 19, 58, 16, 65, 55, 61, 87, 40, 37, 89,
>  47, 48, 42, 82, 37, 34, 25, 26, 19, 44, 13, 15, 27, 41, 99, 15, 69, 8, 19,
>  85, 8, 96, 8, 69, 97, 31, 22, 71, 39, 91, 13, 76, 53, 37, 78, 27, 91, 46,
>  32, 64, 70, 84, 92, 37, 68, 10, 68 ] );;
gap> val := IndexPeriodOfTransformation(f);
[ 10, 42 ]
gap> ind := val[1];; per := val[2];;
gap> RankOfTransformation(f ^ (ind - 1), DegreeOfTransformation(f)) > 
>    RankOfTransformation(f ^ ind, DegreeOfTransformation(f));
true
gap> f ^ (ind + per) = f ^ ind;
true
gap> ForAny([1 .. per - 1], m -> f ^ (ind + m) = f ^ ind);
false
gap> f :=
> Transformation( [ 45, 51, 70, 26, 87, 94, 23, 19, 86, 46, 45, 51, 57, 13, 67,
>  5, 38, 20, 51, 25, 67, 91, 38, 29, 43, 44, 84, 71, 11, 39, 52, 40, 12, 58,
>  1, 83, 9, 27, 1, 25, 86, 83, 15, 38, 86, 61, 43, 16, 55, 16, 96, 46, 46,
>  70, 29, 11, 13, 8, 14, 67, 84, 17, 79, 44, 59, 19, 35, 19, 61, 49, 32, 24,
>  45, 71, 2, 90, 12, 4, 43, 61, 63, 64, 34, 92, 77, 19, 8, 23, 85, 26, 87, 8,
>  76, 18, 48, 33, 8, 7, 38, 39 ] );;
gap> val := IndexPeriodOfTransformation(f);
[ 13, 4 ]
gap> ind := val[1];; per := val[2];;
gap> RankOfTransformation(f ^ (ind - 1), DegreeOfTransformation(f)) > 
>    RankOfTransformation(f ^ ind, DegreeOfTransformation(f));
true
gap> f ^ (ind + per) = f ^ ind;
true
gap> ForAny([1 .. per - 1], m -> f ^ (ind + m) = f ^ ind);
false
gap> f :=
> Transformation( [ 14, 24, 70, 1, 50, 72, 13, 64, 65, 68, 54, 20, 69, 32, 88,
>  60, 93, 100, 37, 27, 15, 7, 84, 95, 84, 36, 8, 20, 90, 55, 78, 48, 93, 10,
>  51, 76, 26, 83, 29, 39, 93, 48, 51, 93, 50, 92, 95, 51, 31, 17, 76, 43, 5,
>  19, 94, 11, 70, 84, 22, 95, 5, 44, 44, 6, 7, 56, 4, 57, 94, 100, 86, 30,
>  38, 80, 77, 60, 45, 99, 38, 11, 60, 62, 76, 50, 13, 48, 27, 82, 68, 99, 17,
>  81, 16, 3, 14, 90, 22, 71, 41, 98 ] );;
gap> val := IndexPeriodOfTransformation(f);
[ 16, 7 ]
gap> ind := val[1];; per := val[2];;
gap> RankOfTransformation(f ^ (ind - 1), DegreeOfTransformation(f)) > 
>    RankOfTransformation(f ^ ind, DegreeOfTransformation(f));
true
gap> f ^ (ind + per) = f ^ ind;
true
gap> ForAny([1 .. per - 1], m -> f ^ (ind + m) = f ^ ind);
false
gap> IndexPeriodOfTransformation(IdentityTransformation);
[ 1, 1 ]
gap> IndexPeriodOfTransformation("a");
Error, IndexPeriodOfTransformation: the argument must be a transformation (not\
 a list (string))
gap> IndexPeriodOfTransformation(Transformation([2, 1]));
[ 1, 2 ]

# Test SMALLEST_IDEM_POW_TRANS
gap> f := Transformation([4, 3, 8, 9, 3, 5, 8, 10, 5, 6, 2, 8]);;
gap> m := SMALLEST_IDEM_POW_TRANS(f);
5
gap> IsIdempotent(f ^ m);
true
gap> f ^ (2 * m) = f ^ m;
true
gap> f := Transformation([5, 23, 27, 8, 21, 49, 36, 33, 4, 44, 3, 49, 48, 18,
> 10, 30, 47, 3, 41, 35, 33, 15, 39, 19, 37, 24, 26, 2, 16, 47, 9, 7, 28, 47,
> 25, 21, 50, 23, 18, 42, 26, 40, 40, 4, 43, 27, 45, 35, 40, 14]);;
gap> SMALLEST_IDEM_POW_TRANS(f);
16
gap> f ^ 32 = f ^ 16;
true
gap> ForAny([1 .. 15], x -> f ^ (2 * x) = f ^ x);
false

# POW_KER_PERM 
gap> POW_KER_PERM([], (1,2,3));
[  ]
gap> POW_KER_PERM([1 .. 5], (1,2,3));
[ 1, 2, 3, 4, 5 ]
gap> POW_KER_PERM([1 .. 5] * 1, (1,2,3));
[ 1, 2, 3, 4, 5 ]
gap> POW_KER_PERM([1 .. 5] * 0 + 1, (1,2,3));
[ 1, 1, 1, 1, 1 ]
gap> POW_KER_PERM([1 .. 3], (1,2,3)(4,5));
[ 1, 2, 3 ]
gap> POW_KER_PERM([1 .. 3] * 1, (1,2,3)(4,5));
[ 1, 2, 3 ]
gap> POW_KER_PERM([1 .. 3] * 0 + 1, (1,2,3)(4,5));
[ 1, 1, 1 ]
gap> POW_KER_PERM([1 .. 3], (1,2,3)(4,5));
[ 1, 2, 3 ]
gap> POW_KER_PERM([1 .. 65537], (1, 65537)) = [1 .. 65537];
true
gap> POW_KER_PERM([1 .. 65537] * 1, (1, 65537)) = [1 .. 65537];
true
gap> POW_KER_PERM([1 .. 65538] * 0 + 1, (1, 65537)) = [1 .. 65538] * 0 + 1;
true
gap> POW_KER_PERM([1 .. 100], (1,2,3)(65537, 65538)) = [1 .. 100];
true
gap> POW_KER_PERM([1 .. 100] * 1, (1,2,3)(65537, 65538)) = [1 .. 100];
true
gap> POW_KER_PERM([1 .. 100] * 0 + 1, (1,2,3)(65537, 65538)) = [1 .. 100] * 0 + 1;
true
gap> POW_KER_PERM([1, 2], 1);
Error, POW_KER_TRANS: the argument must be a permutation (not a integer)
gap> POW_KER_PERM(1, 2);
Error, Length: <list> must be a list (not a integer)
gap> Set(SymmetricGroup(3), p -> POW_KER_PERM([1, 1, 2], p)); 
[ [ 1, 1, 2 ], [ 1, 2, 1 ], [ 1, 2, 2 ] ]
gap> Set(SymmetricGroup(3), p -> POW_KER_PERM([1, 2, 3], p)); 
[ [ 1, 2, 3 ] ]
gap> Set(SymmetricGroup(3), p -> POW_KER_PERM([1, 1, 1], p)); 
[ [ 1, 1, 1 ] ]

# ON_KERNEL_ANTI_ACTION
gap> f := Transformation([84, 99, 9, 73, 33, 70, 77, 69, 41, 18, 63, 29, 42,
>  33, 75, 56, 79, 63, 89, 90, 64, 98, 49, 35, 89, 71, 3, 70, 20, 2, 26, 11,
> 39, 9, 7, 89, 90, 48, 89, 85, 8, 56, 42, 10, 61, 25, 98, 55, 39, 92, 62, 21,
> 34, 57, 44, 14, 14, 92, 53, 64, 59, 84, 12, 87, 78, 10, 83, 30, 32, 53, 44, 68,
> 73, 2, 86, 23, 48, 47, 14, 79, 93, 15, 23, 76, 34, 97, 77, 55, 11, 33, 47, 91,
> 87, 87, 67, 93, 18, 59, 86]);;
gap> g := Transformation([16, 99, 73, 60, 74, 17, 95, 85, 49, 79, 4, 33, 66,
> 15, 44, 77, 73, 41, 55, 93, 84, 67, 68, 69, 94, 31, 2, 29, 5, 42, 10, 63, 58,
> 34, 72, 4, 53, 93, 89, 67, 34, 15, 57, 29, 4, 62, 76, 20, 34, 52, 22, 35,
> 75, 29, 98, 22, 29, 78, 40, 46, 28, 6, 15, 55, 6, 90, 16, 12, 12, 65, 55, 26,
> 66, 89, 36, 36, 25, 61, 57, 83, 38, 41, 93, 2, 39, 87, 85, 26, 17, 83, 92, 97,
> 43, 30, 15, 5, 13, 94, 44]);;
gap> ON_KERNEL_ANTI_ACTION(FlatKernelOfTransformation(g), f, 0);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 11, 5, 13, 14, 15, 11, 16, 17, 18, 
  19, 9, 20, 16, 18, 21, 6, 22, 23, 24, 25, 26, 3, 27, 16, 17, 28, 16, 29, 
  30, 14, 11, 31, 32, 19, 19, 33, 26, 34, 35, 36, 9, 37, 37, 11, 11, 34, 38, 
  18, 39, 1, 40, 30, 41, 31, 22, 42, 43, 38, 37, 8, 4, 23, 44, 45, 28, 46, 
  11, 15, 47, 2, 45, 13, 9, 48, 7, 33, 25, 5, 46, 49, 30, 30, 50, 47, 10, 39, 
  44 ]
gap> last = FlatKernelOfTransformation(f * g);
true
gap> f := Transformation([2, 12, 11, 8, 18, 14, 6, 2, 9, 17, 3, 15, 2, 18,
> 17, 1, 20, 4, 19, 12]) ^ (1, 65537);;
gap> g := Transformation([11, 12, 9, 13, 20, 20, 2, 14, 18, 20, 7, 3, 19, 9,
> 18, 20, 18, 11, 5, 16]);;
gap> ON_KERNEL_ANTI_ACTION(FlatKernelOfTransformation(g, 65537), f, 0)
> = FlatKernelOfTransformation(f * g, 65537);
true
gap> ON_KERNEL_ANTI_ACTION([1 .. 65538], f, 0) 
> = FlatKernelOfTransformation(f, 65538);
true
gap> h := f * g ^ 3 * f * g * f ^ 10;
<transformation on 65537 pts with rank 65522>
gap> ON_KERNEL_ANTI_ACTION(FlatKernelOfTransformation(g), h, 0)
> = FlatKernelOfTransformation(h * g);
Error, ON_KERNEL_ANTI_ACTION: the length of the first argument must be at leas\
t 65537
gap> ON_KERNEL_ANTI_ACTION([1 .. 10], 
>                          Transformation([7, 1, 4, 3, 2, 7, 7, 6, 6, 5]), 0);
[ 1, 2, 3, 4, 5, 1, 1, 6, 6, 7 ]
gap> ON_KERNEL_ANTI_ACTION([0], 
>                          Transformation([7, 1, 4, 3, 2, 7, 7, 6, 6, 5]), 15);
[ 1, 2, 3, 4, 5, 1, 1, 6, 6, 7, 8, 9, 10, 11, 12 ]
gap> ON_KERNEL_ANTI_ACTION([0], 
>                          Transformation([7, 1, 4, 3, 2, 7, 7, 6, 6, 5]), 5);
[ 1, 2, 3, 4, 5 ]
gap> ON_KERNEL_ANTI_ACTION([0], 
>                          Transformation([7, 1, 4, 3, 2, 7, 7, 6, 6, 5]), 10);
[ 1, 2, 3, 4, 5, 1, 1, 6, 6, 7 ]
gap> ON_KERNEL_ANTI_ACTION([1 .. 15], 
>                          Transformation([7, 1, 4, 3, 2, 7, 7, 6, 6, 5]), 0);
[ 1, 2, 3, 4, 5, 1, 1, 6, 6, 7, 8, 9, 10, 11, 12 ]
gap> ON_KERNEL_ANTI_ACTION([1 .. 5], 
>                          Transformation([5, 1, 5, 3, 2, 7, 7, 6, 6, 5]), 0);
Error, ON_KERNEL_ANTI_ACTION: the length of the first argument must be at leas\
t 10
gap> ON_KERNEL_ANTI_ACTION([1 .. 5], IdentityTransformation, 0); 
[ 1, 2, 3, 4, 5 ]
gap> ON_KERNEL_ANTI_ACTION([1 .. 5], (), 0);
Error, ON_KERNEL_ANTI_ACTION: the argument must be a transformation (not a per\
mutation (small))
gap> ON_KERNEL_ANTI_ACTION([], IdentityTransformation, 10);
[  ]
gap> ON_KERNEL_ANTI_ACTION([], IdentityTransformation, 10);
[  ]
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> ON_KERNEL_ANTI_ACTION([], f, 10);
[  ]
gap> ON_KERNEL_ANTI_ACTION([], f, 10);
[  ]

# INV_KER_TRANS
gap> f := Transformation([9, 5, 3, 5, 10, 3, 1, 9, 6, 7]);;
gap> g := RightOne(f) * (2,4)(3,6,5);                                   
Transformation( [ 1, 1, 6, 6, 3, 5, 7, 7 ] )
gap> ker := FlatKernelOfTransformation(g, DegreeOfTransformation(f));
[ 1, 1, 2, 2, 3, 4, 5, 5, 6, 7 ]
gap> h := INV_KER_TRANS(ker, f);
Transformation( [ 7, 7, 6, 6, 4, 9, 10, 10, 8, 5 ] )
gap> OnKernelAntiAction(OnKernelAntiAction(ker, f), h) = ker;
true
gap> h * f * g = g;
true
gap> ker := FlatKernelOfTransformation(g, DegreeOfTransformation(f) + 2);
[ 1, 1, 2, 2, 3, 4, 5, 5, 6, 7, 8, 9 ]
gap> h := INV_KER_TRANS(ker, f);
Transformation( [ 7, 7, 6, 6, 4, 9, 10, 10, 8, 5 ] )
gap> OnKernelAntiAction(OnKernelAntiAction(ker, f), h) = ker;
true
gap> h * f * g = g;
true
gap> f := AsTransformation((1,2,3));;
gap> h := INV_KER_TRANS([1 .. 65537], f);
Transformation( [ 3, 1, 2 ] )
gap> OnKernelAntiAction(OnKernelAntiAction([1 .. 65537], f), h) = [1 .. 65537];
true
gap> h * f * IdentityTransformation = IdentityTransformation;
true
gap> f := Transformation([9, 5, 3, 5, 10, 3, 1, 9, 6, 7]) ^ (1, 65537);;
gap> g := RightOne(f) * (2,4)(3,6,5);;
gap> ker := FlatKernelOfTransformation(g, DegreeOfTransformation(f));;
gap> h := INV_KER_TRANS(ker, f);
<transformation on 65537 pts with rank 65534>
gap> OnKernelAntiAction(OnKernelAntiAction(ker, f), h) = ker;
true
gap> h * f * g = g;
true
gap> ker := FlatKernelOfTransformation(g, DegreeOfTransformation(f) + 2);;
gap> h := INV_KER_TRANS(ker, f);
<transformation on 65537 pts with rank 65534>
gap> OnKernelAntiAction(OnKernelAntiAction(ker, f), h) = ker;
true
gap> h * f * g = g;
true
gap> f := AsTransformation((1,2,65537));;
gap> h := INV_KER_TRANS([1 .. 65537], f);
<transformation on 65537 pts with rank 65537>
gap> OnKernelAntiAction(OnKernelAntiAction([1 .. 65537], f), h) = [1 .. 65537];
true
gap> h * f * IdentityTransformation = IdentityTransformation;
true
gap> f := AsTransformation((1,2)(3,65537));;
gap> h := INV_KER_TRANS([1, 2], f);
Transformation( [ 2, 1 ] )
gap> h := INV_KER_TRANS([1, 2], [1]);
Error, INV_KER_TRANS: the argument must be a transformation (not a list (plain\
,cyc))

# IS_IDEM_TRANS
gap> IS_IDEM_TRANS(IdentityTransformation);
true
gap> IS_IDEM_TRANS(Transformation([1, 2, 1]));
true
gap> IS_IDEM_TRANS(Transformation([1, 1, 2]));
false
gap> IS_IDEM_TRANS(Transformation([65537], [1]));
true
gap> IS_IDEM_TRANS(Transformation([1, 65537], [2, 1]));
false
gap> IS_IDEM_TRANS(());
Error, IS_IDEM_TRANS: the argument must be a transformation (not a permutation\
 (small))

# COMPONENT_REPS_TRANS
gap> COMPONENT_REPS_TRANS(Transformation([1, 2, 1]));
[ [ 3 ], [ 2 ] ]
gap> COMPONENT_REPS_TRANS(Transformation([1, 1, 1]));
[ [ 2, 3 ] ]
gap> COMPONENT_REPS_TRANS(Transformation([1, 1, 2]));
[ [ 3 ] ]
gap> f := Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]);;
gap> COMPONENT_REPS_TRANS(f);
[ [ 3, 4, 8, 10 ] ]
gap> f := Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12, 11, 14, 13, 15,
>                         16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28,
>                         31, 30, 29]);;
gap> COMPONENT_REPS_TRANS(f);
[ [ 2, 7 ], [ 1 ], [ 11 ], [ 13 ], [ 15 ], [ 16 ], [ 17 ], [ 18 ], [ 19 ], 
  [ 20 ], [ 21 ], [ 22 ], [ 23 ], [ 24 ], [ 25 ], [ 26 ], [ 27 ], [ 28 ], 
  [ 29 ], [ 30 ] ]
gap> COMPONENT_REPS_TRANS(IdentityTransformation);
[  ]
gap> f :=
> Transformation([9, 45, 53, 15, 42, 97, 71, 66, 7, 88, 6, 98, 95, 36, 20, 59,
> 94, 6, 81, 70, 65, 29, 78, 37, 74, 48, 52, 4, 32, 93, 18, 13, 55, 94, 49, 42,
> 99, 46, 35, 84, 52, 79, 80, 7, 85, 53, 89, 70, 79, 27, 84, 99, 9, 73, 33, 70,
> 77, 69, 41, 18, 63, 29, 42, 33, 75, 56, 79, 63, 89, 90, 64, 98, 49, 35, 100,
> 89, 71, 3, 70, 20, 2, 26, 11, 39, 9, 7, 89, 90, 48, 89, 85, 8, 56, 42, 10,
> 61, 25, 98, 55, 39]);;
gap> COMPONENT_REPS_TRANS(f);
[ [ 1, 16, 19, 23, 24, 38, 44, 50, 57, 86, 91 ], 
  [ 5, 14, 17, 21, 22, 28, 30, 31, 34, 40, 43, 47, 51, 54, 58, 60, 62, 67, 
      68, 76, 82, 83, 87, 92, 96 ], [ 12, 72 ] ]
gap> Set(List(ComponentRepsOfTransformation(f), x ->
> Union(List(x, i -> ComponentTransformationInt(f, i)))))
> = Set(List(ComponentsOfTransformation(f), AsSSortedList));
true
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1) 
>         * (14918, 184, 141)(14140, 124);;
gap> COMPONENT_REPS_TRANS(f);;
gap> COMPONENT_REPS_TRANS("a");
Error, COMPONENT_REPS_TRANS: the argument must be a transformation (not a list\
 (string))

# NR_COMPONENTS_TRANS
gap> NR_COMPONENTS_TRANS(Transformation([1, 2, 1]));
2
gap> NR_COMPONENTS_TRANS(Transformation([1, 1, 1]));
1
gap> NR_COMPONENTS_TRANS(Transformation([1, 1, 2]));
1
gap> f := Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]);;
gap> NR_COMPONENTS_TRANS(f);
1
gap> f := Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12, 11, 14, 13, 15,
>                         16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28,
>                         31, 30, 29]);;
gap> NR_COMPONENTS_TRANS(f);
20
gap> NR_COMPONENTS_TRANS(IdentityTransformation);
0
gap> f :=
> Transformation([9, 45, 53, 15, 42, 97, 71, 66, 7, 88, 6, 98, 95, 36, 20, 59,
> 94, 6, 81, 70, 65, 29, 78, 37, 74, 48, 52, 4, 32, 93, 18, 13, 55, 94, 49, 42,
> 99, 46, 35, 84, 52, 79, 80, 7, 85, 53, 89, 70, 79, 27, 84, 99, 9, 73, 33, 70,
> 77, 69, 41, 18, 63, 29, 42, 33, 75, 56, 79, 63, 89, 90, 64, 98, 49, 35, 100,
> 89, 71, 3, 70, 20, 2, 26, 11, 39, 9, 7, 89, 90, 48, 89, 85, 8, 56, 42, 10,
> 61, 25, 98, 55, 39]);;
gap> NR_COMPONENTS_TRANS(f);
3
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1) 
>         * (14918, 184, 141)(14140, 124);;
gap> NR_COMPONENTS_TRANS(f);
65533
gap> NR_COMPONENTS_TRANS("a");
Error, NR_COMPONENTS_TRANS: the argument must be a transformation (not a list \
(string))

# COMPONENTS_TRANS
gap> COMPONENTS_TRANS(Transformation([1, 2, 1]));
[ [ 1, 3 ], [ 2 ] ]
gap> COMPONENTS_TRANS(Transformation([1, 1, 1]));
[ [ 1, 2, 3 ] ]
gap> COMPONENTS_TRANS(Transformation([1, 1, 2]));
[ [ 1, 2, 3 ] ]
gap> COMPONENTS_TRANS(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]));
[ [ 1, 2, 6, 9, 3, 7, 4, 5, 8, 10 ] ]
gap> COMPONENTS_TRANS(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12, 11,
>                                     14, 13, 15, 16, 17, 18, 19, 20, 21, 22,
>                                     23, 24, 25, 26, 27, 28, 31, 30, 29]));;
gap> COMPONENTS_TRANS(IdentityTransformation);
[  ]
gap> COMPONENTS_TRANS(Transformation([9, 45, 53, 15, 42, 97, 71, 66, 7, 88, 6,
>                                     98, 95, 36, 20, 59, 94, 6, 81, 70, 65,
>                                     29, 78, 37, 74, 48, 52, 4, 32, 93, 18,
>                                     13, 55, 94, 49, 42, 99, 46, 35, 84, 52,
>                                     79, 80, 7, 85, 53, 89, 70, 79, 27, 84,
>                                     99, 9, 73, 33, 70, 77, 69, 41, 18, 63,
>                                     29, 42, 33, 75, 56, 79, 63, 89, 90, 64,
>                                     98, 49, 35, 100, 89, 71, 3, 70, 20, 2,
>                                     26, 11, 39, 9, 7, 89, 90, 48, 89, 85, 8,
>                                     56, 42, 10, 61, 25, 98, 55, 39]));
[ [ 1, 9, 7, 71, 64, 33, 55, 2, 45, 85, 3, 53, 16, 59, 41, 52, 99, 19, 81, 
      23, 78, 24, 37, 27, 38, 46, 44, 50, 57, 77, 86, 91 ], 
  [ 4, 15, 20, 70, 90, 89, 48, 5, 42, 79, 6, 97, 25, 74, 35, 49, 8, 66, 56, 
      10, 88, 11, 13, 95, 14, 36, 17, 94, 18, 21, 65, 75, 100, 39, 22, 29, 
      32, 26, 28, 30, 93, 31, 34, 40, 84, 43, 80, 47, 51, 54, 73, 58, 69, 60, 
      61, 63, 62, 67, 68, 76, 82, 83, 87, 92, 96 ], [ 12, 98, 72 ] ]
gap> comps := COMPONENTS_TRANS(Transformation([65537 .. 70000], 
>                                             [65537 .. 70000] * 0 + 1) 
>                              * (14918, 184, 141)(14140, 124));;
gap> Length(comps);
65533
gap> Union(comps) = [1 .. 70000];
true
gap> COMPONENTS_TRANS("a");
Error, COMPONENTS_TRANS: the argument must be a transformation (not a list (st\
ring))

# COMPONENT_TRANS_INT
gap> COMPONENT_TRANS_INT(Transformation([1, 2, 1]), 1);
[ 1 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 2, 1]), 2);
[ 2 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 2, 1]), 3);
[ 3, 1 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 2, 1]), 5);
[ 5 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 1, 1]), 1);
[ 1 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 1, 1]), 2);
[ 2, 1 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 1, 1]), 3);
[ 3, 1 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 1, 1]), 5);
[ 5 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 1, 2]), 1);
[ 1 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 1, 2]), 2);
[ 2, 1 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 1, 2]), 3);
[ 3, 2, 1 ]
gap> COMPONENT_TRANS_INT(Transformation([1, 1, 2]), 5);
[ 5 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 1);
[ 1, 2, 6, 9 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 2);
[ 2, 6, 9, 1 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 3);
[ 3, 7, 9, 1, 2, 6 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 4);
[ 4, 2, 6, 9, 1 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 5);
[ 5, 6, 9, 1, 2 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 6);
[ 6, 9, 1, 2 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 7);
[ 7, 9, 1, 2, 6 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 8);
[ 8, 1, 2, 6, 9 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 9);
[ 9, 1, 2, 6 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 10);
[ 10, 5, 6, 9, 1, 2 ]
gap> COMPONENT_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 20);
[ 20 ]
gap> COMPONENT_TRANS_INT(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12,
>                                        11, 14, 13, 15, 16, 17, 18, 19, 20,
>                                        21, 22, 23, 24, 25, 26, 27, 28, 31,
>                                        30, 29]), 10);
[ 10, 6, 4, 9 ]
gap> COMPONENT_TRANS_INT(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12,
>                                        11, 14, 13, 15, 16, 17, 18, 19, 20,
>                                        21, 22, 23, 24, 25, 26, 27, 28, 31,
>                                        30, 29]), 40);
[ 40 ]
gap> COMPONENT_TRANS_INT(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12,
>                                        11, 14, 13, 15, 16, 17, 18, 19, 20,
>                                        21, 22, 23, 24, 25, 26, 27, 28, 31,
>                                        30, 29]), 1);
[ 1, 3 ]
gap> COMPONENT_TRANS_INT(IdentityTransformation, 10);
[ 10 ]
gap> COMPONENT_TRANS_INT(IdentityTransformation, 0);
Error, COMPONENT_TRANS_INT: the second argument must be a positive integer (no\
t a integer)
gap> COMPONENT_TRANS_INT(IdentityTransformation, "a");
Error, COMPONENT_TRANS_INT: the second argument must be a positive integer (no\
t a list (string))
gap> COMPONENT_TRANS_INT((), 1);
Error, COMPONENT_TRANS_INT: the first argument must be a transformation (not a\
 permutation (small))
gap> COMPONENT_TRANS_INT(Transformation([9, 45, 53, 15, 42, 97, 71, 66, 7, 88, 6,
>                                     98, 95, 36, 20, 59, 94, 6, 81, 70, 65,
>                                     29, 78, 37, 74, 48, 52, 4, 32, 93, 18,
>                                     13, 55, 94, 49, 42, 99, 46, 35, 84, 52,
>                                     79, 80, 7, 85, 53, 89, 70, 79, 27, 84,
>                                     99, 9, 73, 33, 70, 77, 69, 41, 18, 63,
>                                     29, 42, 33, 75, 56, 79, 63, 89, 90, 64,
>                                     98, 49, 35, 100, 89, 71, 3, 70, 20, 2,
>                                     26, 11, 39, 9, 7, 89, 90, 48, 89, 85, 8,
>                                     56, 42, 10, 61, 25, 98, 55, 39]), 1);
[ 1, 9, 7, 71, 64, 33, 55 ]
gap> COMPONENT_TRANS_INT(Transformation([65537 .. 70000], 
>                                       [65537 .. 70000] * 0 + 1) 
>                        * (14918, 184, 141)(14140, 124), 1);
[ 1 ]
gap> COMPONENT_TRANS_INT(Transformation([65537 .. 70000], 
>                                       [65537 .. 70000] * 0 + 1) 
>                        * (14918, 184, 141)(14140, 124), 14918);
[ 14918, 184, 141 ]
gap> COMPONENT_TRANS_INT(Transformation([65537 .. 70000], 
>                                       [65537 .. 70000] * 0 + 1) 
>                        * (14918, 184, 141)(14140, 124), 69999);
[ 69999, 1 ]

# CYCLE_TRANS_INT
gap> CYCLE_TRANS_INT(Transformation([1, 2, 1]), 1);
[ 1 ]
gap> CYCLE_TRANS_INT(Transformation([1, 2, 1]), 2);
[ 2 ]
gap> CYCLE_TRANS_INT(Transformation([1, 2, 1]), 3);
[ 1 ]
gap> CYCLE_TRANS_INT(Transformation([1, 2, 1]), 5);
[ 5 ]
gap> CYCLE_TRANS_INT(Transformation([1, 1, 1]), 1);
[ 1 ]
gap> CYCLE_TRANS_INT(Transformation([1, 1, 1]), 2);
[ 1 ]
gap> CYCLE_TRANS_INT(Transformation([1, 1, 1]), 3);
[ 1 ]
gap> CYCLE_TRANS_INT(Transformation([1, 1, 1]), 5);
[ 5 ]
gap> CYCLE_TRANS_INT(Transformation([1, 1, 2]), 1);
[ 1 ]
gap> CYCLE_TRANS_INT(Transformation([1, 1, 2]), 2);
[ 1 ]
gap> CYCLE_TRANS_INT(Transformation([1, 1, 2]), 3);
[ 1 ]
gap> CYCLE_TRANS_INT(Transformation([1, 1, 2]), 5);
[ 5 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 1);
[ 1, 2, 6, 9 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 2);
[ 2, 6, 9, 1 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 3);
[ 9, 1, 2, 6 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 4);
[ 2, 6, 9, 1 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 5);
[ 6, 9, 1, 2 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 6);
[ 6, 9, 1, 2 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 7);
[ 9, 1, 2, 6 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 8);
[ 1, 2, 6, 9 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 9);
[ 9, 1, 2, 6 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 10);
[ 6, 9, 1, 2 ]
gap> CYCLE_TRANS_INT(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 20);
[ 20 ]
gap> CYCLE_TRANS_INT(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12,
>                                        11, 14, 13, 15, 16, 17, 18, 19, 20,
>                                        21, 22, 23, 24, 25, 26, 27, 28, 31,
>                                        30, 29]), 10);
[ 10, 6, 4, 9 ]
gap> CYCLE_TRANS_INT(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12,
>                                        11, 14, 13, 15, 16, 17, 18, 19, 20,
>                                        21, 22, 23, 24, 25, 26, 27, 28, 31,
>                                        30, 29]), 40);
[ 40 ]
gap> CYCLE_TRANS_INT(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12,
>                                        11, 14, 13, 15, 16, 17, 18, 19, 20,
>                                        21, 22, 23, 24, 25, 26, 27, 28, 31,
>                                        30, 29]), 1);
[ 1, 3 ]
gap> CYCLE_TRANS_INT(IdentityTransformation, 10);
[ 10 ]
gap> CYCLE_TRANS_INT(IdentityTransformation, 0);
Error, CYCLE_TRANS_INT: the second argument must be a positive integer (not a \
integer)
gap> CYCLE_TRANS_INT(IdentityTransformation, "a");
Error, CYCLE_TRANS_INT: the second argument must be a positive integer (not a \
list (string))
gap> CYCLE_TRANS_INT((), 1);
Error, CYCLE_TRANS_INT: the first argument must be a transformation (not a per\
mutation (small))
gap> CYCLE_TRANS_INT(Transformation([9, 45, 53, 15, 42, 97, 71, 66, 7, 88, 6,
>                                     98, 95, 36, 20, 59, 94, 6, 81, 70, 65,
>                                     29, 78, 37, 74, 48, 52, 4, 32, 93, 18,
>                                     13, 55, 94, 49, 42, 99, 46, 35, 84, 52,
>                                     79, 80, 7, 85, 53, 89, 70, 79, 27, 84,
>                                     99, 9, 73, 33, 70, 77, 69, 41, 18, 63,
>                                     29, 42, 33, 75, 56, 79, 63, 89, 90, 64,
>                                     98, 49, 35, 100, 89, 71, 3, 70, 20, 2,
>                                     26, 11, 39, 9, 7, 89, 90, 48, 89, 85, 8,
>                                     56, 42, 10, 61, 25, 98, 55, 39]), 1);
[ 33, 55 ]
gap> CYCLE_TRANS_INT(Transformation([65537 .. 70000], 
>                                   [65537 .. 70000] * 0 + 1) 
>                    * (14918, 184, 141)(14140, 124), 1);
[ 1 ]
gap> CYCLE_TRANS_INT(Transformation([65537 .. 70000], 
>                                   [65537 .. 70000] * 0 + 1) 
>                    * (14918, 184, 141)(14140, 124), 14918);
[ 14918, 184, 141 ]
gap> CYCLE_TRANS_INT(Transformation([65537 .. 70000], 
>                                   [65537 .. 70000] * 0 + 1) 
>                    * (14918, 184, 141)(14140, 124), 69999);
[ 1 ]

# CYCLES_TRANS
gap> CYCLES_TRANS(Transformation([1, 2, 1]));
[ [ 1 ], [ 2 ] ]
gap> CYCLES_TRANS(Transformation([1, 1, 1]));
[ [ 1 ] ]
gap> CYCLES_TRANS(Transformation([1, 1, 2]));
[ [ 1 ] ]
gap> CYCLES_TRANS(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]));
[ [ 1, 2, 6, 9 ] ]
gap> CYCLES_TRANS(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12,
>                                        11, 14, 13, 15, 16, 17, 18, 19, 20,
>                                        21, 22, 23, 24, 25, 26, 27, 28, 31,
>                                        30, 29]));
[ [ 1, 3 ], [ 9, 10, 6, 4 ], [ 11, 12 ], [ 13, 14 ], [ 15 ], [ 16 ], [ 17 ], 
  [ 18 ], [ 19 ], [ 20 ], [ 21 ], [ 22 ], [ 23 ], [ 24 ], [ 25 ], [ 26 ], 
  [ 27 ], [ 28 ], [ 29, 31 ], [ 30 ] ]
gap> CYCLES_TRANS(IdentityTransformation);
[  ]
gap> CYCLES_TRANS(Transformation([9, 45, 53, 15, 42, 97, 71, 66, 7, 88, 6,
>                                 98, 95, 36, 20, 59, 94, 6, 81, 70, 65,
>                                 29, 78, 37, 74, 48, 52, 4, 32, 93, 18,
>                                 13, 55, 94, 49, 42, 99, 46, 35, 84, 52,
>                                 79, 80, 7, 85, 53, 89, 70, 79, 27, 84,
>                                 99, 9, 73, 33, 70, 77, 69, 41, 18, 63,
>                                 29, 42, 33, 75, 56, 79, 63, 89, 90, 64,
>                                 98, 49, 35, 100, 89, 71, 3, 70, 20, 2,
>                                 26, 11, 39, 9, 7, 89, 90, 48, 89, 85, 8,
>                                 56, 42, 10, 61, 25, 98, 55, 39]));
[ [ 33, 55 ], [ 70, 90, 89, 48 ], [ 98 ] ]
gap> f := Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1)
>         * (14918, 184, 141)(14140, 124);;
gap> comps := CYCLES_TRANS(f);;
gap> Length(comps) = NR_COMPONENTS_TRANS(f);
true
gap> Filtered(comps, x -> Size(x) > 1);
[ [ 124, 14140 ], [ 141, 14918, 184 ] ]
gap> CYCLES_TRANS(0);
Error, CYCLES_TRANS: the argument must be a transformation (not a integer)

# CYCLES_TRANS_LIST
gap> CYCLES_TRANS_LIST(Transformation([1, 2, 1]), []);
[  ]
gap> CYCLES_TRANS_LIST(Transformation([1, 2, 1]), [1, 3]);
[ [ 1 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 2, 1]), [1, 2, 3]);
[ [ 1 ], [ 2 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 2, 1]), [1 .. 3]);
[ [ 1 ], [ 2 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 2, 1]), [1 .. 10]);
[ [ 1 ], [ 2 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 1, 1]), [1]);
[ [ 1 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 1, 1]), [2]);
[ [ 1 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 1, 1]), [3]);
[ [ 1 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 1, 1]), [1 .. 3]);
[ [ 1 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 1, 1]), [3 .. 10]);
[ [ 1 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 1, 2]), [1]);
[ [ 1 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 1, 2]), [2]);
[ [ 1 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 1, 2]), [3]);
[ [ 1 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 1, 2]), [1 .. 3]);
[ [ 1 ] ]
gap> CYCLES_TRANS_LIST(Transformation([1, 1, 2]), [3 .. 10]);
[ [ 1 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]
gap> CYCLES_TRANS_LIST(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 
>                                     [1 .. 10]);
[ [ 1, 2, 6, 9 ] ]
gap> CYCLES_TRANS_LIST(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 
>                                     [1 .. 3]);
[ [ 1, 2, 6, 9 ] ]
gap> CYCLES_TRANS_LIST(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 
>                                     [1, 5, 3, 7]);
[ [ 1, 2, 6, 9 ] ]
gap> CYCLES_TRANS_LIST(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]), 
>                                     [1, 5, 3, 7, 12, 13, 14]);
[ [ 1, 2, 6, 9 ], [ 12 ], [ 13 ], [ 14 ] ]
gap> CYCLES_TRANS_LIST(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6, 12,
>                                        11, 14, 13, 15, 16, 17, 18, 19, 20,
>                                        21, 22, 23, 24, 25, 26, 27, 28, 31,
>                                        30, 29]), [4 .. 100]);
[ [ 4, 9, 10, 6 ], [ 11, 12 ], [ 13, 14 ], [ 15 ], [ 16 ], [ 17 ], [ 18 ], 
  [ 19 ], [ 20 ], [ 21 ], [ 22 ], [ 23 ], [ 24 ], [ 25 ], [ 26 ], [ 27 ], 
  [ 28 ], [ 29, 31 ], [ 30 ], [ 32 ], [ 33 ], [ 34 ], [ 35 ], [ 36 ], [ 37 ], 
  [ 38 ], [ 39 ], [ 40 ], [ 41 ], [ 42 ], [ 43 ], [ 44 ], [ 45 ], [ 46 ], 
  [ 47 ], [ 48 ], [ 49 ], [ 50 ], [ 51 ], [ 52 ], [ 53 ], [ 54 ], [ 55 ], 
  [ 56 ], [ 57 ], [ 58 ], [ 59 ], [ 60 ], [ 61 ], [ 62 ], [ 63 ], [ 64 ], 
  [ 65 ], [ 66 ], [ 67 ], [ 68 ], [ 69 ], [ 70 ], [ 71 ], [ 72 ], [ 73 ], 
  [ 74 ], [ 75 ], [ 76 ], [ 77 ], [ 78 ], [ 79 ], [ 80 ], [ 81 ], [ 82 ], 
  [ 83 ], [ 84 ], [ 85 ], [ 86 ], [ 87 ], [ 88 ], [ 89 ], [ 90 ], [ 91 ], 
  [ 92 ], [ 93 ], [ 94 ], [ 95 ], [ 96 ], [ 97 ], [ 98 ], [ 99 ], [ 100 ] ]
gap> CYCLES_TRANS_LIST(IdentityTransformation, [1 .. 10]);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]
gap> CYCLES_TRANS_LIST(IdentityTransformation, [100, 200]);
[ [ 100 ], [ 200 ] ]
gap> CYCLES_TRANS_LIST(IdentityTransformation, [5, 1, 2]);
[ [ 5 ], [ 1 ], [ 2 ] ]
gap> f := Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1)
>         * (14918, 184, 141)(14140, 124);;
gap> CYCLES_TRANS_LIST(f, [1 .. 10]);
[ [ 1 ], [ 2 ], [ 3 ], [ 4 ], [ 5 ], [ 6 ], [ 7 ], [ 8 ], [ 9 ], [ 10 ] ]
gap> CYCLES_TRANS_LIST(f, [10, 1, 3]);
[ [ 10 ], [ 1 ], [ 3 ] ]
gap> CYCLES_TRANS_LIST(f, [65535 .. 70000]);
[ [ 65535 ], [ 65536 ], [ 1 ] ]
gap> CYCLES_TRANS_LIST(f, [65535 .. 70001]);
[ [ 65535 ], [ 65536 ], [ 1 ], [ 70001 ] ]
gap> CYCLES_TRANS_LIST(f, [1, , 3]);
Error, List Element: <list>[2] must have an assigned value
gap> CYCLES_TRANS_LIST(f, [-1]);
Error, CYCLES_TRANS_LIST: the second argument must be a positive integer (not \
a integer)
gap> CYCLES_TRANS_LIST(0, [1 .. 10]);
Error, CYCLES_TRANS_LIST: the first argument must be a transformation (not a i\
nteger)
gap> CYCLES_TRANS_LIST(IdentityTransformation, "a");
Error, CYCLES_TRANS_LIST: the second argument must be a list of positive integ\
er (not a character)
gap> CYCLES_TRANS_LIST(IdentityTransformation, ());
Error, CYCLES_TRANS_LIST: the second argument must be a list (not a transforma\
tion (small))
gap> CYCLES_TRANS_LIST(IdentityTransformation, [0, -1]);
Error, CYCLES_TRANS_LIST: the second argument must be a list of positive integ\
er (not a integer)

# LEFT_ONE_TRANS
gap> f := Transformation([7, 7, 7, 9, 5, 3, 9, 7, 5, 6]);;
gap> e := LEFT_ONE_TRANS(f);
Transformation( [ 1, 1, 1, 4, 5, 6, 4, 1, 5 ] )
gap> IsIdempotent(e);
true
gap> KernelOfTransformation(e, 10) = KernelOfTransformation(f);
true
gap> e * f = f;
true
gap> f := Transformation([1, 6, 9, 7, 8, 8, 4, 7, 3]);;
gap> e := LEFT_ONE_TRANS(f);
Transformation( [ 1, 2, 3, 4, 5, 5, 7, 4 ] )
gap> IsIdempotent(e);
true
gap> KernelOfTransformation(e, 9) = KernelOfTransformation(f);
true
gap> e * f = f;
true
gap> f := Transformation([1, 5, 9, 9, 6, 6, 4, 10, 7, 6]);
Transformation( [ 1, 5, 9, 9, 6, 6, 4, 10, 7, 6 ] )
gap> e := LEFT_ONE_TRANS(f);
Transformation( [ 1, 2, 3, 3, 5, 5, 7, 8, 9, 5 ] )
gap> IsIdempotent(e);
true
gap> KernelOfTransformation(e, 10) = KernelOfTransformation(f);
true
gap> e * f = f;
true
gap> f := Transformation( [ 6, 3, 3, 5, 6, 9, 1, 8, 6, 1 ] )
>  * (65534,65535)(65537,65538)(65539,65540);
<transformation on 65540 pts with rank 65536>
gap> e := LEFT_ONE_TRANS(f);
Transformation( [ 1, 2, 2, 4, 1, 6, 7, 8, 1, 7 ] )
gap> IsIdempotent(e);
true
gap> KernelOfTransformation(e, 65540) = KernelOfTransformation(f);
true
gap> e * f = f;
true
gap> f := Transformation( [ 9, 7, 8, 2, 8, 5, 4, 10, 7, 8 ] )
> * (912,11041,3297,7593,8859)(3214,66460,7897)(70310,8320);
<transformation on 70310 pts with rank 70307>
gap> e := LEFT_ONE_TRANS(f);
Transformation( [ 1, 2, 3, 4, 3, 6, 7, 8, 2, 3 ] )
gap> IsIdempotent(e);
true
gap> KernelOfTransformation(e, 70310) = KernelOfTransformation(f);
true
gap> e * f = f;
true
gap> LEFT_ONE_TRANS("a");
Error, LEFT_ONE_TRANS: the first argument must be a transformation (not a list\
 (string))

# RIGHT_ONE_TRANS
gap> f := Transformation([7, 7, 7, 9, 5, 3, 9, 7, 5, 6]);;
gap> e := RIGHT_ONE_TRANS(f);
Transformation( [ 3, 3, 3, 3, 5, 6, 7, 7, 9, 9 ] )
gap> IsIdempotent(e);
true
gap> ImageSetOfTransformation(e, 10) = ImageSetOfTransformation(f);
true
gap> f * e = f;
true
gap> f := Transformation([1, 6, 9, 7, 8, 8, 4, 7, 3]);;
gap> e := RIGHT_ONE_TRANS(f);
Transformation( [ 1, 1, 3, 4, 4 ] )
gap> IsIdempotent(e);
true
gap> ImageSetOfTransformation(e, 9) = ImageSetOfTransformation(f);
true
gap> f * e = f;
true
gap> f := Transformation([1, 5, 9, 9, 6, 6, 4, 10, 7, 6]);
Transformation( [ 1, 5, 9, 9, 6, 6, 4, 10, 7, 6 ] )
gap> e := RIGHT_ONE_TRANS(f);
Transformation( [ 1, 1, 1, 4, 5, 6, 7, 7 ] )
gap> IsIdempotent(e);
true
gap> ImageSetOfTransformation(e, 10) = ImageSetOfTransformation(f);
true
gap> f * e = f;
true
gap> f := Transformation( [ 6, 3, 3, 5, 6, 9, 1, 8, 6, 1 ] )
>  * (65534,65535)(65537,65538)(65539,65540);
<transformation on 65540 pts with rank 65536>
gap> e := RIGHT_ONE_TRANS(f);
Transformation( [ 1, 1, 3, 3, 5, 6, 6, 8, 9, 9 ] )
gap> IsIdempotent(e);
true
gap> ImageSetOfTransformation(e, 65540) = ImageSetOfTransformation(f);
true
gap> f * e = f;
true
gap> f := Transformation( [ 9, 7, 8, 2, 8, 5, 4, 10, 7, 8 ] )
> * (912,11041,3297,7593,8859)(3214,66460,7897)(70310,8320);
<transformation on 70310 pts with rank 70307>
gap> e := RIGHT_ONE_TRANS(f);
Transformation( [ 2, 2, 2, 4, 5, 5 ] )
gap> IsIdempotent(e);
true
gap> ImageSetOfTransformation(e, 70310) = ImageSetOfTransformation(f);
true
gap> f * e = f;
true
gap> RIGHT_ONE_TRANS("a");
Error, RIGHT_ONE_TRANS: the first argument must be a transformation (not a lis\
t (string))

# TRANS_IMG_CONJ
gap> f := Transformation([1, 2, 1]);;
gap> g := Transformation([3, 2, 3, 1]);;
gap> p := TRANS_IMG_CONJ(f, g);
(1,3,4)
gap> OnTuples(ImageListOfTransformation(f, 4), p);
[ 3, 2, 3, 1 ]
gap> ImageListOfTransformation(g);
[ 3, 2, 3, 1 ]
gap> TRANS_IMG_CONJ(g, f);
(1,4,3)
gap> g := Transformation([3, 2, 3, 1]) ^ (5, 65537);;
gap> TRANS_IMG_CONJ(f, g);
(1,3,4)
gap> TRANS_IMG_CONJ(g, f);
(1,4,3)
gap> f := Transformation([1, 2, 1]) ^ (5, 65538);;
gap> TRANS_IMG_CONJ(f, g);
(1,3,4)
gap> TRANS_IMG_CONJ(g, f);
(1,4,3)
gap> TRANS_IMG_CONJ((), 1);
Error, TRANS_IMG_CONJ: the arguments must both be transformations (not permuta\
tion (small) and integer)
gap> TRANS_IMG_CONJ(f, 1);
Error, TRANS_IMG_CONJ: the arguments must both be transformations (not transfo\
rmation (large) and integer)
gap> f := Transformation([11, 9, 10, 6, 7, 7, 10, 7, 10, 9, 7, 4]);;
gap> TRANS_IMG_CONJ(f, LeftOne(f));
(1,6,4,12,11)(2,7,5,9)(3,8,10)
gap> TRANS_IMG_CONJ(LeftOne(f), f);
(1,11,12,4,6)(2,9,5,7)(3,10,8)
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> TRANS_IMG_CONJ(Transformation([2, 1, 3]), f);
(1,2)
gap> TRANS_IMG_CONJ(f, Transformation([2, 1, 3]));
(1,2)

# One, IsOne, IdentityTransformation
gap> f := Transformation([11, 9, 10, 6, 7, 7, 10, 7, 10, 9, 7, 4]);;
gap> One(f);
IdentityTransformation
gap> IdentityTransformation;
IdentityTransformation
gap> One(f) = IdentityTransformation;
true
gap> f ^ 0;
IdentityTransformation
gap> IsOne(f ^ 0);
true
gap> IsOne(IdentityTransformation);
true
gap> IsOne(One(f));
true
gap> f := Transformation([65537, 1], [1, 65537]);;
gap> One(f);
IdentityTransformation
gap> IdentityTransformation;
IdentityTransformation
gap> One(f) = IdentityTransformation;
true
gap> f ^ 0;
IdentityTransformation
gap> IsOne(f ^ 0);
true
gap> IsOne(IdentityTransformation);
true
gap> IsOne(One(f));
true

# \=, equality, EQ
gap> f := Transformation([2, 6, 7, 2, 6, 13, 9, 9, 13, 1, 11, 1, 13, 12]);;
gap> g := Transformation([5, 3, 8, 12, 1, 11, 9, 9, 4, 14, 10, 5, 10, 6]);;
gap> f = f;
true
gap> f = g;
false
gap> g = f;
false
gap> f := Transformation([1, 2, 1]);
Transformation( [ 1, 2, 1 ] )
gap> g := Transformation([1, 2, 1, 3, 5]);
Transformation( [ 1, 2, 1, 3 ] )
gap> f = g;
false
gap> f := Transformation([1, 2, 1]);
Transformation( [ 1, 2, 1 ] )
gap> g := Transformation([1, 2, 1, 4, 5]);
Transformation( [ 1, 2, 1 ] )
gap> f = g;
true
gap> g = f;
true
gap> f := Transformation([1, 2, 1, 4, 5]);
Transformation( [ 1, 2, 1 ] )
gap> g := Transformation([1, 3, 1]);
Transformation( [ 1, 3, 1 ] )
gap> f = g;
false
gap> f := Transformation([65537], [1]);;
gap> g := Transformation([1], [65537]);;
gap> f = f;
true
gap> f = g;
false
gap> g = f;
false
gap> f ^ (2, 65537) = Transformation([1, 1]);
true
gap> Transformation([1, 1]) = f ^ (2, 65537);
true
gap> f ^ (3, 65537) = Transformation([1, 1]);
false
gap> Transformation([1, 1]) = f ^ (3, 65537);
false
gap> f ^ (3, 65537) = Transformation([1, 1, 2, 2]);
false
gap> Transformation([1, 1, 2, 2]) = f ^ (3, 65537);
false
gap> f := Transformation([65538], [1]);;
gap> g := Transformation([1], [65537]);;
gap> f = g;
false
gap> g = f;
false
gap> f := Transformation([1], [65537]);;
gap> g := AsTransformation((65535, 65536, 65537, 65538)(65539, 65540)) ^ 2;;
gap> g = f;
false
gap> f = g;
false
gap> f := AsTransformation((65535, 2, 65537)(65539, 65540)) ^ 2;;
gap> g := AsTransformation((65535, 65536, 65537));;
gap> g = f;
false
gap> f = g;
false
gap> f = f;
true
gap> f = f;
true
gap> f := Transformation([1, 2, 1]);;
gap> g := Transformation([1, 2, 3, 4, 5, 6], [1, 2, 1, 5, 4, 65537]);;
gap> f = g;
false
gap> g = f;
false
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> Transformation([1, 2, 3, 5, 4]) = f * (1, 2);
false
gap> f * (1, 2) = Transformation([1, 2, 3, 5, 4]);
false
gap> Transformation([2, 1, 3, 4, 5]) = f * (1, 2);
true
gap> f * (1, 2) = Transformation([2, 1, 3, 4, 5]);
true
gap> Transformation([2, 1, 3, 5, 4]) = f * (1, 2);
false
gap> f * (1, 2) = Transformation([2, 1, 3, 5, 4]);
false

# \<, less than, LT
gap> f := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9]);;
gap> g := Transformation([3, 7, 3, 4, 10, 9, 4, 7, 1, 5, 3, 1]);;
gap> f < f;
false
gap> g < g;
false
gap> f < g;
false
gap> g < f;
true
gap> f := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9, 13, 14]);;
gap> g := Transformation([3, 7, 3, 4, 10, 9, 4, 7, 1, 5, 3, 1]);;
gap> f < g;
false
gap> g < f;
true
gap> f := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9]);;
gap> g := Transformation([3, 7, 3, 4, 10, 9, 4, 7, 1, 5, 3, 1, 13, 14]);;
gap> f < g;
false
gap> g < f;
true
gap> f := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9]);;
gap> g := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9, 9]);;
gap> f < g;
false
gap> g < f;
true
gap> f := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9]);;
gap> g := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9, 14, 13]);;
gap> f < g;
true
gap> g < f;
false
gap> f := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9, 9]);;
gap> g := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9]);;
gap> f < g;
true
gap> g < f;
false
gap> f := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9, 13]);;
gap> g := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9]);;
gap> f < g;
false
gap> g < f;
false
gap> f := Transformation([1, 2, 1]);;
gap> g := Transformation([1], [65537]);;
gap> f < g;
true
gap> g < f;
false
gap> f := Transformation([2, 2, 1]);;
gap> g := Transformation([65537], [1]);;
gap> f < g;
false
gap> g < f;
true
gap> f := Transformation([2, 2, 1]);;
gap> g := Transformation([1, 2, 3, 65537], [2, 2, 1, 1]);;
gap> f < g;
false
gap> g < f;
true
gap> f := Transformation([1, 2, 1]);
Transformation( [ 1, 2, 1 ] )
gap> g := Transformation([1, 2, 3, 4], [1, 2, 1, 65537]);
<transformation on 65537 pts with rank 65535>
gap> f < g;
true
gap> g < f;
false
gap> f := Transformation([1, 2, 1]);
Transformation( [ 1, 2, 1 ] )
gap> g := Transformation([1, 2, 3, 65538, 65537], [1, 2, 1, 65537, 65538]) ^ 2;
Transformation( [ 1, 2, 1 ] )
gap> f < g;
false
gap> g < f;
false
gap> g := Transformation([1, 2, 3, 65538, 65537], 
>                        [1, 2, 1, 65537, 65538]) ^ 2;;
gap> g < g;
false
gap> f := Transformation([1, 2, 3, 65537, 65538], 
>                        [1, 1, 1, 65538, 65539]);;
gap> f < g;
true
gap> g < f;
false
gap> f := Transformation([1, 2, 3, 65537, 65538], 
>                        [1, 2, 1, 65538, 65538]);;
gap> g := Transformation([1, 2, 3, 65537, 65538, 65539], 
>                        [1, 2, 1, 65538, 65538, 65537]);;
gap> f < g;
false
gap> g < f;
true
gap> g := Transformation([1, 2, 3, 65537, 65538, 65539], 
>                        [1, 2, 1, 65538, 65538, 65539]);;
gap> f < g;
false
gap> g < f;
false
gap> f := Transformation([1, 2, 3, 65537, 65538], 
>                        [1, 2, 1, 65538, 65538]);;
gap> g := Transformation([1, 2, 3, 65537, 65538, 65539, 65540], 
>                        [1, 2, 1, 65538, 65538, 65540, 65539]) ^ 2;;
gap> f < g;
false
gap> g < f;
false
gap> f := Transformation([1, 2, 3, 65537, 65538], 
>                        [1, 2, 1, 65538, 65538]);;
gap> g := Transformation([1, 2, 3, 65537, 65538], 
>                        [2, 2, 1, 65538, 65538]);;
gap> f < g;
true
gap> g < f;
false
gap> f := Transformation([1, 2, 3, 65537, 65538], 
>                        [1, 2, 1, 65538, 65538]);;
gap> g := Transformation([1, 2, 3, 65537, 65538, 65539, 65540], 
>                        [1, 2, 1, 65538, 65538, 65540, 65540]);;
gap> f < g;
true
gap> g < f;
false
gap> f := Transformation([1, 2, 3, 65537, 65538, 65539, 65540], 
>                        [1, 3, 1, 65538, 65538, 65540, 65540]);;
gap> g := Transformation([1, 2, 3, 65537, 65538], 
>                        [1, 2, 1, 65538, 65538]);;
gap> f < g;
false
gap> g < f;
true
gap> x := (2 ^ 16, 2 ^ 16 + 1);
(65536,65537)
gap> y := AsTransformation(x);
<transformation on 65537 pts with rank 65537>
gap> IsTrans4Rep(y);
true
gap> x := y ^ 2;
IdentityTransformation
gap> IsTrans4Rep(x);
true
gap> x < Transformation([2, 1, 3]);
true
gap> x < Transformation([1, 1, 3]);
false
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> Transformation([1, 2, 3, 5, 4]) < f * (1, 2);
true
gap> Transformation([3, 2, 3, 5, 4]) < f * (1, 2);
false
gap> f * (1, 2) < Transformation([1, 2, 3, 5, 4]);
false
gap> f * (1, 2) < Transformation([3, 2, 3, 5, 4]);
true
gap> f * (1, 2) < Transformation([1, 2, 3, 5, 4]);
false
gap> Transformation([2, 1, 3, 4, 5]) < f * (1, 2);
false
gap> Transformation([2, 1, 4, 4, 5]) < f * (1, 2);
false
gap> Transformation([2, 1, 1, 4, 5]) < f * (1, 2);
true
gap> f * (1, 2) < Transformation([2, 1, 3, 4, 5]);
false
gap> f * (1, 2) < Transformation([2, 1, 4, 4, 5]);
true
gap> f * (1, 2) < Transformation([2, 1, 1, 4, 5]);
false

# \*, product, PROD: transformation and transformation
gap> f := Transformation([8, 8, 2, 7, 9, 11, 7, 7, 6, 3, 1, 9, 13, 14]);;
gap> g := Transformation([3, 7, 3, 4, 10, 9, 4, 7, 1, 5, 3, 1]);;
gap> f * g;
Transformation( [ 7, 7, 7, 4, 1, 3, 4, 4, 9, 3, 3, 1 ] )
gap> g * f;
Transformation( [ 2, 7, 2, 7, 3, 6, 7, 7, 8, 9, 2, 8 ] )
gap> f := Transformation([1, 2, 1]);;
gap> g := Transformation([1], [65537]);;
gap> f * g;
<transformation on 65537 pts with rank 65535>
gap> g * f;
<transformation on 65537 pts with rank 65536>
gap> g ^ 2;
<transformation on 65537 pts with rank 65536>
gap> f := Transformation([1], [65537]);;
gap> g := Transformation([1], [65538]);;
gap> h := f * g;
<transformation on 65537 pts with rank 65536>
gap> ForAll([1 .. 65537], i -> (i ^ f) ^ g = i ^ h);  
true
gap> h := g * h;
<transformation on 65538 pts with rank 65537>
gap> ForAll([1 .. 65538], i -> (i ^ g) ^ f = i ^ h);  
true
gap> f := Transformation([3, 2, 4, 4]);;
gap> g := Transformation([2, 1, 2, 1]);;
gap> f * g;
Transformation( [ 2, 1, 1, 1 ] )
gap> g * f;
Transformation( [ 2, 3, 2, 3 ] )
gap> f * g * f * g * f * g; 
Transformation( [ 2, 1, 1, 1 ] )
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> Transformation([1, 2, 3, 5, 4]) * (f * (1, 2));
Transformation( [ 2, 1, 3, 5, 4 ] )
gap> Transformation([3, 2, 3, 5, 4]) * (f * (1, 2));
Transformation( [ 3, 1, 3, 5, 4 ] )
gap> (f * (1, 2)) * Transformation([1, 2, 3, 5, 4]);
Transformation( [ 2, 1, 3, 5, 4 ] )
gap> (f * (1, 2)) * Transformation([3, 2, 3, 5, 4]);
Transformation( [ 2, 3, 3, 5, 4 ] )
gap> (f * (1, 2)) * Transformation([1, 2, 3, 5, 4]);
Transformation( [ 2, 1, 3, 5, 4 ] )
gap> Transformation([2, 1, 3, 4, 5]) * (f * (1, 2));
IdentityTransformation
gap> Transformation([2, 1, 4, 4, 5]) * (f * (1, 2));
Transformation( [ 1, 2, 4, 4 ] )
gap> Transformation([2, 1, 1, 4, 5]) * (f * (1, 2));
Transformation( [ 1, 2, 2 ] )
gap> (f * (1, 2)) * Transformation([2, 1, 3, 4, 5]);
IdentityTransformation
gap> (f * (1, 2)) * Transformation([2, 1, 4, 4, 5]);
Transformation( [ 1, 2, 4, 4 ] )
gap> (f * (1, 2)) * Transformation([2, 1, 1, 4, 5]);
Transformation( [ 1, 2, 1 ] )

# \*, PROD, product: for a transformation and a permutation
gap> Transformation([1, 4, 2, 1]) * (1, 2);
Transformation( [ 2, 4, 1, 2 ] )
gap> Transformation([1, 4, 2, 1]) * (1, 2, 5);
Transformation( [ 2, 4, 5, 2, 1 ] )
gap> Transformation([1, 4, 2, 1]) * (1, 65537);
<transformation on 65537 pts with rank 65536>
gap> Transformation([1, 4, 2, 1]) * (1, 2, 5);
Transformation( [ 2, 4, 5, 2, 1 ] )
gap> Transformation([1], [65537]) * (1, 2, 5);
<transformation on 65537 pts with rank 65536>
gap> Transformation([1], [65537]) * (65537, 2);
<transformation on 65537 pts with rank 65536>
gap> Transformation([1], [65538]) * (65537, 2);
<transformation on 65538 pts with rank 65537>
gap> Transformation([1], [65537]) * (65538, 2);
<transformation on 65538 pts with rank 65537>
gap> f := Transformation([8, 1, 9, 7, 7, 6, 4, 2, 2, 4]);;
gap> p := (1, 2)(7, 9, 6, 5, 1100);;
gap> g := f * p;
<transformation on 1100 pts with rank 1097>
gap> ForAll([1 .. 10], i -> (i ^ f) ^ p = i ^ g);  
true
gap> f * (1, 7, 9, 4, 6);
Transformation( [ 8, 7, 4, 9, 9, 1, 6, 2, 2, 6 ] )
gap> f * (1, 10, 7, 9, 4, 6);
Transformation( [ 8, 10, 4, 9, 9, 1, 6, 2, 2, 6 ] )
gap> f * (1, 11, 7, 9, 4, 6);
Transformation( [ 8, 11, 4, 9, 9, 1, 6, 2, 2, 6, 7 ] )
gap> f * (1, 12, 7, 8);
Transformation( [ 1, 12, 9, 8, 8, 6, 4, 2, 2, 4, 11, 7 ] )
gap> f * (1, 9, 8, 5)(2, 7, 4, 3, 6, 10);
Transformation( [ 5, 9, 8, 4, 4, 10, 3, 7, 7, 3 ] )
gap> f := Transformation([5, 5, 2, 10, 10, 10, 1, 12, 11, 9, 3, 6]);;
gap> f * (1, 2, 3);
Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] )
gap> p := (1, 4, 12, 8)(2, 16, 15, 5, 7, 9, 20, 14, 11, 17, 10)(3, 13, 6, 19);;
gap> g := f * p;
Transformation( [ 7, 7, 16, 2, 2, 2, 4, 8, 17, 20, 13, 19, 6, 11, 5, 15, 10,
  18, 3, 14 ] )
gap> ForAll([1 .. 20], i -> (i ^ f) ^ p = i ^ g);
true
gap> p := (2, 7, 5, 10, 3, 4, 12, 11, 6)(8, 9);;
gap> f * p;
Transformation( [ 10, 10, 7, 3, 3, 3, 1, 11, 6, 8, 4, 2 ] )
gap> p := (1, 2, 3);;
gap> f * p;
Transformation( [ 5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6 ] )
gap> f := Transformation([8, 1, 9, 7, 7, 6, 4, 2, 2, 4]);;
gap> f * (1, 10, 2, 3, 6, 7)(11, 15)(12, 17, 19, 16, 20, 18);
Transformation( [ 8, 10, 9, 1, 1, 7, 4, 3, 3, 4, 15, 17, 13, 14, 11, 20, 19,
  12, 16, 18 ] )
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> p := AS_PERM_TRANS(f);;
gap> IsPerm4Rep(p);
true
gap> Transformation([2, 1, 4, 4, 5]) * p; 
Transformation( [ 2, 1, 4, 4 ] )
gap> p * Transformation([2, 1, 4, 4, 5]); 
Transformation( [ 2, 1, 4, 4 ] )
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> (f * (1, 2)) * (1, 2, 3);
Transformation( [ 3, 2, 1 ] )
gap> (1, 2, 3) * (f * (1, 2));
Transformation( [ 1, 3, 2 ] )
gap> p := AS_PERM_TRANS(f) * (1,2);;
gap> IsPerm4Rep(p);
true
gap> p * Transformation([2, 1, 4, 4, 5]);
Transformation( [ 1, 2, 4, 4 ] )
gap> Transformation([2, 1, 4, 4, 5]) * p;
Transformation( [ 1, 2, 4, 4 ] )

# \*, PROD, product: for a permutation and a transformation
gap> (1, 2) * Transformation([1, 4, 2, 1]);
Transformation( [ 4, 1, 2, 1 ] )
gap> (1, 2, 5) * Transformation([1, 4, 2, 1]);
Transformation( [ 4, 5, 2, 1, 1 ] )
gap> (1, 65537) * Transformation([1, 4, 2, 1]);
<transformation on 65537 pts with rank 65536>
gap> (1, 2, 5) * Transformation([1, 4, 2, 1]);
Transformation( [ 4, 5, 2, 1, 1 ] )
gap> (1, 2, 3) * Transformation([1], [65537]);
<transformation on 65537 pts with rank 65536>
gap> (65537, 2) * Transformation([1], [65537]);
<transformation on 65537 pts with rank 65536>
gap> (65537, 2) * Transformation([1], [65538]);
<transformation on 65538 pts with rank 65537>
gap> (65538, 2) * Transformation([1], [65537]);
<transformation on 65538 pts with rank 65537>
gap> f := Transformation([6, 7, 9, 7, 4, 7, 5, 4, 9, 4]);;
gap> p := (1, 4, 9, 10, 3, 2, 8)(5, 7);;
gap> g := p * f;
Transformation( [ 7, 4, 7, 9, 5, 7, 4, 6, 4, 9 ] )
gap> () * f = f; 
true
gap> p ^ -1 * (p * f) = f;
true
gap> ImageSetOfTransformation(f) = ImageSetOfTransformation(g);
true
gap> ForAll([1 .. 10], i -> (i ^ p) ^ f = i ^ g);  
true
gap> p := (2, 10, 5, 9, 8, 4, 7, 6, 3)(11, 12);;
gap> p * f = (p * (11, 12)) * f;
false
gap> () * f = f; 
true
gap> p ^ -1 * (p * f) = f;
true

# \^, conjugation: for a transformation and a permutation
gap> Transformation([1, 4, 2, 1]) ^ (1, 2);
Transformation( [ 4, 2, 1, 2 ] )
gap> Transformation([1, 4, 2, 1]) ^ (1, 2, 5);
Transformation( [ 1, 2, 5, 2, 4 ] )
gap> Transformation([1, 4, 2, 1]) ^ (1, 65537);
<transformation on 65537 pts with rank 65536>
gap> Transformation([1, 4, 2, 1]) ^ (1, 2, 5);
Transformation( [ 1, 2, 5, 2, 4 ] )
gap> Transformation([1], [65537]) ^ (1, 2, 5);
<transformation on 65537 pts with rank 65536>
gap> Transformation([1], [65537]) ^ (65537, 2);
Transformation( [ 2, 2 ] )
gap> Transformation([1], [65538]) ^ (65537, 2);
<transformation on 65538 pts with rank 65537>
gap> f := Transformation([10, 4, 9, 4, 3, 4, 2, 1, 6, 9]);;
gap> p := (1, 4, 6)(2, 8)(3, 7, 5);;
gap> f ^ p;
Transformation( [ 6, 4, 7, 10, 8, 6, 9, 6, 1, 9 ] )
gap> f ^ p = p ^ -1 * f * p;
true
gap> p := (1, 4, 3, 5)(2, 10, 8)(7, 9)(11, 15, 12, 20, 13)(16, 19, 18, 17);;
gap> f ^ p;
Transformation( [ 5, 4, 3, 8, 7, 3, 6, 7, 10, 3 ] )
gap> f ^ p = p ^ -1 * f * p;
true
gap> p := (1, 3, 6, 11, 7, 10, 5, 2)(4, 8, 9);;
gap> f ^ p;
Transformation( [ 8, 6, 5, 11, 4, 4, 7, 8, 3, 1, 8 ] )
gap> f := Transformation([10, 4, 9, 4, 3, 4, 2, 1, 6, 9]);;
gap> p := (1, 4, 6)(2, 8)(3, 7, 5) * (1, 65537) * (1, 65537);;
gap> f ^ p;
Transformation( [ 6, 4, 7, 10, 8, 6, 9, 6, 1, 9 ] )
gap> f ^ p = p ^ -1 * f * p;
true
gap> p := (1,4,3,5)(2,10,8)(7,9)(11,15,12,20,13)(16,19,18,17)*(65536,65537);;
gap> f ^ p;
Transformation( [ 5, 4, 3, 8, 7, 3, 6, 7, 10, 3 ] )
gap> f ^ p = p ^ -1 * f * p;
true
gap> Transformation([1, 2, 1]) ^ (1, 2, 3);
Transformation( [ 2, 2 ] )
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> p := AS_PERM_TRANS(f) * (1,2);;
gap> IsPerm4Rep(p);
true
gap> Transformation([2, 1]) ^ p;
Transformation( [ 2, 1 ] )
gap> (f * (1, 2)) ^ (1, 2);
Transformation( [ 2, 1 ] )

# \/, quotient, QUO: for a transformation and a permutation
gap> f := Transformation([8, 2, 6, 6, 7, 10, 8, 2, 1, 10]);;
gap> p := (1, 10, 9, 4, 6, 3, 8)(5, 7);;
gap> f / p;
Transformation( [ 3, 2, 4, 4, 5, 1, 3, 2, 8, 1 ] )
gap> f / p = f * p ^ -1;
true
gap> f / ();
Transformation( [ 8, 2, 6, 6, 7, 10, 8, 2, 1, 10 ] )
gap> f / () = f;
true
gap> p := p * (11, 12);;
gap> f / p;
Transformation( [ 3, 2, 4, 4, 5, 1, 3, 2, 8, 1, 12, 11 ] )
gap> p := (1, 2, 3);;
gap> f / p;
Transformation( [ 8, 1, 6, 6, 7, 10, 8, 1, 3, 10 ] )
gap> f / p = f * p ^ -1;
true
gap> f := Transformation([8, 2, 6, 6, 7, 10, 8, 2, 1, 10]);;
gap> p := (1, 65537) ^ 2;;
gap> f / p;
Transformation( [ 8, 2, 6, 6, 7, 10, 8, 2, 1, 10 ] )
gap> f / p = f * p ^ -1;
true
gap> p := (1, 10, 3, 6, 4)(2, 7, 5, 8, 9) * (1, 65537) ^ 2;;
gap> f / p;
Transformation( [ 5, 9, 3, 3, 2, 1, 5, 9, 4, 1 ] )
gap> f / p = f * p ^ -1;
true
gap> p := (1, 2, 3) * (1, 65537) ^ 2;;
gap> f / p;
Transformation( [ 8, 1, 6, 6, 7, 10, 8, 1, 3, 10 ] )
gap> p := (1, 2, 3) * (11, 12) * (1, 65537) ^ 2;;
gap> f / p;
Transformation( [ 8, 1, 6, 6, 7, 10, 8, 1, 3, 10, 12, 11 ] )
gap> f := Transformation([1], [65538]) / (1, 65537);
<transformation on 65538 pts with rank 65537>
gap> MovedPoints(f);
[ 1, 65537 ]
gap> OnTuples(MovedPoints(f), f);
[ 65538, 1 ]
gap> Transformation([1], [65538]) / (1, 65537) 
> = Transformation([1], [65538]) * (1, 65537);
true
gap> Transformation([1], [65537]) / (1, 65538) 
> = Transformation([1], [65537]) * (1, 65538);
true
gap> f := Transformation([1], [65537]) / (1, 65537);
<transformation on 65537 pts with rank 65536>
gap> MovedPoints(f);
[ 65537 ]
gap> OnTuples(MovedPoints(f), f);
[ 1 ]
gap> Transformation([1], [65537]) / (1, 65537) 
> = Transformation([1], [65537]) * (1, 65537);
true
gap> f := Transformation([1], [65537]) / (1, 2);
<transformation on 65537 pts with rank 65536>
gap> MovedPoints(f);
[ 1, 2 ]
gap> OnTuples(MovedPoints(f), f);
[ 65537, 1 ]
gap> Transformation([1], [65537]) / (1, 2) 
> = Transformation([1], [65537]) * (1, 2);
true
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> p := AS_PERM_TRANS(f);;
gap> IsPerm4Rep(p);
true
gap> Transformation([2, 1]) / p;
Transformation( [ 2, 1 ] )
gap> (f * (1, 2)) / (1, 2, 3);
Transformation( [ 1, 3, 2 ] )

# left quotient, LQUO: for a permutation and a transformation
gap> f := Transformation([8, 2, 6, 6, 7, 10, 8, 2, 1, 10]);;
gap> p := (1, 10, 9, 4, 6, 3, 8)(5, 7);;
gap> LQUO(p, f);
Transformation( [ 2, 2, 10, 1, 8, 6, 7, 6, 10, 8 ] )
gap> LQUO(p, f) = p ^ -1 * f;
true
gap> LQUO((), f);
Transformation( [ 8, 2, 6, 6, 7, 10, 8, 2, 1, 10 ] )
gap> LQUO((), f) = f;
true
gap> p := p * (11, 12);;
gap> LQUO(p, f);
Transformation( [ 2, 2, 10, 1, 8, 6, 7, 6, 10, 8, 12, 11 ] )
gap> p := (1, 2, 3);;
gap> LQUO(p, f);
Transformation( [ 6, 8, 2, 6, 7, 10, 8, 2, 1, 10 ] )
gap> LQUO(p, f) = p ^ -1 * f;
true
gap> f := Transformation([8, 2, 6, 6, 7, 10, 8, 2, 1, 10]);;
gap> p := (1, 65537) ^ 2;;
gap> LQUO(p, f);
Transformation( [ 8, 2, 6, 6, 7, 10, 8, 2, 1, 10 ] )
gap> LQUO(p, f) = p ^ -1 * f;
true
gap> p := (1, 10, 3, 6, 4)(2, 7, 5, 8, 9) * (1, 65537) ^ 2;;
gap> LQUO(p, f);
Transformation( [ 6, 1, 10, 10, 8, 6, 2, 7, 2, 8 ] )
gap> LQUO(p, f) = p ^ -1 * f;
true
gap> p := (1, 2, 3) * (1, 65537) ^ 2;;
gap> LQUO(p, f);
Transformation( [ 6, 8, 2, 6, 7, 10, 8, 2, 1, 10 ] )
gap> p := (1, 2, 3) * (11, 12) * (1, 65537) ^ 2;;
gap> LQUO(p, f);
Transformation( [ 6, 8, 2, 6, 7, 10, 8, 2, 1, 10, 12, 11 ] )
gap> f := LQUO((1, 65537), Transformation([1], [65538]));
<transformation on 65538 pts with rank 65537>
gap> MovedPoints(f);
[ 1, 65537 ]
gap> OnTuples(MovedPoints(f), f);
[ 65537, 65538 ]
gap> LQUO((1, 65537), Transformation([1], [65538]))
> = (1, 65537) * Transformation([1], [65538]);
true
gap> f := LQUO((1, 65537), Transformation([1], [65537]));
<transformation on 65537 pts with rank 65536>
gap> MovedPoints(f);
[ 1 ]
gap> OnTuples(MovedPoints(f), f);
[ 65537 ]
gap> LQUO((1, 65537), Transformation([1], [65537])) 
> = (1, 65537) * Transformation([1], [65537]);
true
gap> f := LQUO((1, 2), Transformation([1], [65537]));
<transformation on 65537 pts with rank 65536>
gap> MovedPoints(f);
[ 1, 2 ]
gap> OnTuples(MovedPoints(f), f);
[ 2, 65537 ]
gap> LQUO((1, 2), Transformation([1], [65537]))
> = (1, 2) * Transformation([1], [65537]);
true
gap> LQUO((1, 65538), Transformation([1], [65537]));
<transformation on 65538 pts with rank 65537>
gap> f := Transformation([1, 6, 9, 5, 1, 4, 6, 1, 1, 2]);;
gap> p := (1, 2, 3);;
gap> LQUO(p, f);
Transformation( [ 9, 1, 6, 5, 1, 4, 6, 1, 1, 2 ] )
gap> LQUO(p, f) = p ^ -1 * f;
true
gap> p := (1, 2, 3)(10, 11);;
gap> LQUO(p, f) = p ^ -1 * f;
true
gap> p := (1, 6, 7, 5, 2, 9, 4, 10, 3, 8);;
gap> LQUO(p, f) = p ^ -1 * f;
true
gap> f := Transformation([7, 3, 10, 3, 6, 10, 5, 2, 8, 7]);;
gap> p := (1, 9, 7, 8, 6, 10, 2, 5, 4, 3);
(1,9,7,8,6,10,2,5,4,3)
gap> p := p * (1, 65538) ^ 2;
(1,9,7,8,6,10,2,5,4,3)
gap> LQUO(p, f) = p ^ -1 * f;
true
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> p := AS_PERM_TRANS(f);;
gap> IsPerm4Rep(p);
true
gap> LQUO(p, Transformation([2, 1]));
Transformation( [ 2, 1 ] )
gap> LQUO(p * (1, 2), Transformation([2, 1]));
IdentityTransformation
gap> LQUO((1,2,3), f * (1, 2));
Transformation( [ 3, 2, 1 ] )

# ^, POW: for a positive integer and a transformation
gap> 2 ^ Transformation([1, 1]);
1
gap> 10 ^ Transformation([1, 1]);
10
gap> (2 ^ 60) ^ Transformation([1, 1]);
1152921504606846976
gap> (-1) ^ Transformation([1, 1]);
Error, Tran. Operations: <point> must be a positive integer (not -1)
gap> 65535 ^ Transformation([65535], [65537]);
65537
gap> 1 ^ Transformation([65535], [65537]);
1
gap> 65538 ^ Transformation([65535], [65537]);
65538
gap> (2 ^ 60) ^ Transformation([65535], [65537]);
1152921504606846976
gap> (-1) ^ Transformation([65535], [65537]);
Error, Tran. Operations: <point> must be a positive integer (not -1)

# OnSetsTrans: for a transformation
gap> OnSets([], Transformation([1, 1]));
[  ]
gap> OnSets([1, 2], Transformation([1, 1]));
[ 1 ]
gap> OnSets([1, 2, 10], Transformation([1, 1]));
[ 1, 10 ]
gap> OnSets([1, 2, 10, (2 ^ 60)], Transformation([1, 1]));
[ 1, 10, 1152921504606846976 ]
gap> OnSets([-1, 1, 2], Transformation([1, 1]));
Error, Tran. Operations: <point> must be a positive integer (not -1)
gap> OnSets([65535, 65536, 65537], Transformation([65535], [65537]));
[ 65536, 65537 ]
gap> OnSets([1, 2, 10], Transformation([65535], [65537]));
[ 1, 2, 10 ]
gap> OnSets([1, 65535, 65538], Transformation([65535], [65537]));
[ 1, 65537, 65538 ]
gap> OnSets([1, 2, 10, 65537, (2 ^ 60)], Transformation([65537], [1]));
[ 1, 2, 10, 1152921504606846976 ]
gap> OnSets([-1, 1, 2], Transformation([65535], [65537]));
Error, Tran. Operations: <point> must be a positive integer (not -1)
gap> OnSets([1, 2, 10, 65535, (2 ^ 60)], Transformation([65535], [5]));
[ 1, 2, 5, 10, 1152921504606846976 ]
gap> OnSets([1 .. 20], Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]));
[ 1, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ]
gap> OnSets([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 324, 4124, 123124, 2 ^ 60],
>           Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]));
[ 1, 5, 7, 8, 9, 10, 11, 19, 324, 4124, 123124, 1152921504606846976 ]
gap> f := Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]);;
gap> OnSets([1 .. 11], f);
[ 1, 2, 5, 6, 7, 9, 11 ]
gap> OnSets([1 .. 10], f);
[ 1, 2, 5, 6, 7, 9 ]

# OnTuplesTrans: for a transformation
gap> OnTuples([], Transformation([1, 1]));
[  ]
gap> OnTuples([1, 2], Transformation([1, 1]));
[ 1, 1 ]
gap> OnTuples([1, 2, 1, 2, 3, 3, 3, 4], Transformation([1, 1]));
[ 1, 1, 1, 1, 3, 3, 3, 4 ]
gap> OnTuples([1, 2, 10], Transformation([1, 1]));
[ 1, 1, 10 ]
gap> OnTuples([1, 2, 10, (2 ^ 60)], Transformation([1, 1]));
[ 1, 1, 10, 1152921504606846976 ]
gap> OnTuples([-1, 1, 2], Transformation([1, 1]));
Error, Tran. Operations: <point> must be a positive integer (not -1)
gap> OnTuples([65535, 65536, 65537], Transformation([65535], [65537]));
[ 65537, 65536, 65537 ]
gap> OnTuples([1, 2, 10], Transformation([65535], [65537]));
[ 1, 2, 10 ]
gap> OnTuples([1, 65535, 65538], Transformation([65535], [65537]));
[ 1, 65537, 65538 ]
gap> OnTuples([1, 2, 10, 65537, (2 ^ 60)], Transformation([65537], [1]));
[ 1, 2, 10, 1, 1152921504606846976 ]
gap> OnTuples([-1, 1, 2], Transformation([65535], [65537]));
Error, Tran. Operations: <point> must be a positive integer (not -1)
gap> OnTuples([1, 2, 10, 65535, (2 ^ 60)], Transformation([65535], [5]));
[ 1, 2, 10, 5, 1152921504606846976 ]
gap> OnTuples([1 .. 20], Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]));
[ 10, 7, 10, 8, 8, 7, 5, 9, 1, 9, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ]
gap> OnTuples([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 324, 4124, 123124, 2 ^ 60],
>           Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]));
[ 10, 7, 10, 8, 8, 7, 5, 9, 1, 9, 11, 19, 324, 4124, 123124, 
  1152921504606846976 ]
gap> OnTuples([1, , 3], Transformation([1, 1]));
Error, OnTuples for transformation: list must not contain holes
gap> OnTuples([1, , 3], Transformation([1], [65537]));
Error, OnTuples for transformation: list must not contain holes
gap> f := Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]);;
gap> OnTuples([1 .. 10], f);
[ 2, 6, 7, 2, 6, 9, 9, 1, 1, 5 ]

# OnPosIntSetsTrans: for a transformation
gap> OnPosIntSetsTrans([], Transformation([1, 1]), 0);
[  ]
gap> OnPosIntSetsTrans([1, 2], Transformation([1, 1]), 0);
[ 1 ]
gap> OnPosIntSetsTrans([1, 2, 10], Transformation([1, 1]), 0);
[ 1, 10 ]
gap> OnPosIntSetsTrans([1, 2, 10], Transformation([65535], [65537]), 0);
[ 1, 2, 10 ]
gap> OnPosIntSetsTrans([1, 65535, 65538], Transformation([65535], [65537]), 0);
[ 1, 65537, 65538 ]
gap> OnPosIntSetsTrans([1, 2, 10, 65537], Transformation([65537], [1]), 0);
[ 1, 2, 10 ]
gap> OnPosIntSetsTrans([1, 2, 10, 65535], Transformation([65535], [5]), 0);
[ 1, 2, 5, 10 ]
gap> OnPosIntSetsTrans([1 .. 20], 
>                      Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]), 0);
[ 1, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ]
gap> OnPosIntSetsTrans([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 324, 4124, 123124],
>                      Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]), 0);
[ 1, 5, 7, 8, 9, 10, 11, 19, 324, 4124, 123124 ]
gap> OnPosIntSetsTrans([], Transformation([1, 1]), 10);
[  ]
gap> OnPosIntSetsTrans([1, 2], Transformation([1, 1]), 10);
[ 1 ]
gap> OnPosIntSetsTrans([1, 2, 10], Transformation([1, 1]), 10);
[ 1, 10 ]
gap> OnPosIntSetsTrans([1, 2, 10], Transformation([65535], [65537]), 10);
[ 1, 2, 10 ]
gap> OnPosIntSetsTrans([1, 65535, 65538], Transformation([65535], [65537]), 10);
[ 1, 65537, 65538 ]
gap> OnPosIntSetsTrans([1, 2, 10, 65537], Transformation([65537], [1]), 12);
[ 1, 2, 10 ]
gap> OnPosIntSetsTrans([1, 2, 10, 65535], Transformation([65535], [5]), 130);
[ 1, 2, 5, 10 ]
gap> OnPosIntSetsTrans([1 .. 20], 
>                      Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]), 10);
[ 1, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ]
gap> OnPosIntSetsTrans([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 19, 324, 4124, 123124],
>                      Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]), 10);
[ 1, 5, 7, 8, 9, 10, 11, 19, 324, 4124, 123124 ]
gap> OnPosIntSetsTrans([0],
>           Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]), 0);
[  ]
gap> OnPosIntSetsTrans([0],
>           Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]), 10);
[ 1, 5, 7, 8, 9, 10 ]
gap> OnPosIntSetsTrans([0],
>           Transformation([10, 7, 10, 8, 8, 7, 5, 9, 1, 9]), 20);
[ 1, 5, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20 ]
gap> OnPosIntSetsTrans([1], "a", 20);
Error, OnPosIntSetsTrans: the argument must be a transformation (not a list (s\
tring))
gap> OnPosIntSetsTrans([0], "a", 20);
Error, IMAGE_SET_TRANS_INT: the first argument must be a transformation (not a\
 list (string))
gap> OnPosIntSetsTrans(1, "a", 20);
Error, Length: <list> must be a list (not a integer)

# MarkSubbags2
gap> f := Transformation([2, 2, 4, 2, 8, 5, 10, 10, 4, 3, 9, 9]);;
gap> ImageSetOfTransformation(f);
[ 2, 3, 4, 5, 8, 9, 10 ]
gap> FlatKernelOfTransformation(f);
[ 1, 1, 2, 1, 3, 4, 5, 5, 2, 6, 7, 7 ]
gap> KernelOfTransformation(f);
[ [ 1, 2, 4 ], [ 3, 9 ], [ 5 ], [ 6 ], [ 7, 8 ], [ 10 ], [ 11, 12 ] ]
gap> g := One(f);;
gap> ImageSetOfTransformation(g);
[  ]
gap> FlatKernelOfTransformation(g);
[  ]
gap> KernelOfTransformation(g);
[  ]
gap> GASMAN("collect");
gap> ImageSetOfTransformation(f);
[ 2, 3, 4, 5, 8, 9, 10 ]
gap> FlatKernelOfTransformation(f);
[ 1, 1, 2, 1, 3, 4, 5, 5, 2, 6, 7, 7 ]
gap> KernelOfTransformation(f);
[ [ 1, 2, 4 ], [ 3, 9 ], [ 5 ], [ 6 ], [ 7, 8 ], [ 10 ], [ 11, 12 ] ]
gap> KernelOfTransformation(g);
[  ]
gap> FlatKernelOfTransformation(g);
[  ]
gap> ImageSetOfTransformation(g);
[  ]

# MarkTrans4SubBags
gap> f := Transformation([65535 .. 65538], [65535 .. 65538] * 0 + 1);;
gap> imglist := ImageListOfTransformation(f);;
gap> imgset := ShallowCopy(ImageSetOfTransformation(f));;
gap> ker := ShallowCopy(FlatKernelOfTransformation(f));;
gap> GASMAN("collect");
gap> ImageSetOfTransformation(f) = imgset;
true
gap> ImageListOfTransformation(f) = imglist;   
true
gap> FlatKernelOfTransformation(f) = ker;
true

# IS_TRANS
gap> IS_TRANS(IdentityTransformation);
true
gap> IS_TRANS(());
false
gap> IS_TRANS(FreeSemigroup(1).1);
false

################################################################################
# Test GAP level functions
################################################################################
#
# NumberTransformation
gap> NumberTransformation(Transformation([8, 5, 6, 1, 5, 4, 3, 6, 4, 2]));
7450432532
gap> NumberTransformation(Transformation([8, 5, 6, 1, 5, 4, 3, 6, 4, 2]), 0);
1
gap> NumberTransformation(IdentityTransformation, 0);
1
gap> NumberTransformation(IdentityTransformation, 10);
123456790
gap> List(FullTransformationMonoid(3), x -> NumberTransformation(x, 3));
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 
  22, 23, 24, 25, 26, 27 ]
gap> NumberTransformation(Transformation([1, 2, 1]), 2);
Error, the second argument must be greater than or equal to the degree of the \
first argument (a transformation)

# TransformationNumber
gap> List([1 .. 27], x -> TransformationNumber(x, 3)) =
> AsSet(FullTransformationMonoid(3));
true
gap> TransformationNumber(7450432532, 10);
Transformation( [ 8, 5, 6, 1, 5, 4, 3, 6, 4, 2 ] )
gap> TransformationNumber(1, 0);
IdentityTransformation
gap> TransformationNumber(123456790, 10);
IdentityTransformation
gap> TransformationNumber(5, 2);
Error, the first argument must be at most 4
gap> TransformationNumber(2, 0);
Error, the first argument must be at most 1

# IsGeneratorsOfMagmaWithInverses
gap> IsGeneratorsOfMagmaWithInverses([Transformation([1, 2, 1])]);
false
gap> IsGeneratorsOfMagmaWithInverses([IdentityTransformation,
>                                     Transformation([1, 2, 1])]);
false
gap> IsGeneratorsOfMagmaWithInverses([IdentityTransformation]);
true
gap> IsGeneratorsOfMagmaWithInverses([Transformation([2, 3, 1])]);
true
gap> IsGeneratorsOfMagmaWithInverses([Transformation([2, 3, 1]), 
>                                     Transformation([2, 4, 1, 3])]);
true

# Transformation
gap> Transformation([4]);
Error, the argument does not describe a transformation
gap> Transformation([1, 2, 4]);
Error, the argument does not describe a transformation

# TransformationListList
gap> Transformation([-11, 2], [1, 1]);
Error, the argument does not describe a transformation
gap> Transformation([1, 2], [1, -1]);
Error, the argument does not describe a transformation
gap> Transformation([1, 2], [1]);
Error, the argument does not describe a transformation
gap> Transformation([1, , 2], [1, 2, 3]);
Error, the argument does not describe a transformation
gap> Transformation([1, 2, 2], [1, , 3]);
Error, the argument does not describe a transformation
gap> Transformation([1, 2, 2], [1, 2, 3]);
Error, the argument does not describe a transformation
gap> Transformation([3, 2, 1], [1, 1, 2]);
Transformation( [ 2, 1, 1 ] )

# TrimTransformation
gap> f := Transformation([1 .. 65537]);
IdentityTransformation
gap> IsTrans4Rep(f);
true
gap> TrimTransformation(f);
gap> IsTrans4Rep(f);
false

# OnKernelAntiAction
gap> OnKernelAntiAction([1, ,3], Transformation([1, 3, 4, 1, 3, 5]));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `OnKernelAntiAction' on 2 arguments
gap> OnKernelAntiAction([], Transformation([1, 3, 4, 1, 3, 5]));
Error, the first argument does not describe the flat kernel of a transformatio\
n
gap> OnKernelAntiAction([-1], Transformation([1, 3, 4, 1, 3, 5]));
Error, the first argument does not describe the flat kernel of a transformatio\
n
gap> OnKernelAntiAction([1, "a"], Transformation([1, 3, 4, 1, 3, 5]));
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `OnKernelAntiAction' on 2 arguments
gap> OnKernelAntiAction([1, 3], Transformation([1, 3, 4, 1, 3, 5]));
Error, the first argument does not describe the flat kernel of a transformatio\
n
gap> OnKernelAntiAction([1, 2, 1, 4], Transformation([1, 3, 4, 1, 3, 5]));
Error, the first argument does not describe the flat kernel of a transformatio\
n

# SmallestMovedPoint
gap> SmallestMovedPoint(IdentityTransformation);
infinity
gap> SmallestMovedPoint(Transformation([1 .. 5]));
infinity
gap> SmallestMovedPoint(Transformation([1, 2, 1]));
3

# SmallestImagePoint
gap> SmallestImageOfMovedPoint(IdentityTransformation);
infinity
gap> SmallestImageOfMovedPoint(Transformation([1 .. 5]));
infinity
gap> SmallestImageOfMovedPoint(Transformation([1, 2, 1]));
1
gap> SmallestImageOfMovedPoint(Transformation([3, 3, 3]));
3

# MovedPoints: for a transformation collection
gap> S := Semigroup(Transformation([1, 3, 4, 1, 3]),
>                   Transformation([5, 5, 1, 1, 3]));;
gap> MovedPoints(S);
[ 1 .. 5 ]
gap> MovedPoints(GreensRClassOfElement(S, Transformation([1, 3, 4, 1, 3])));
[ 2, 3, 4, 5 ]
gap> MovedPoints(GeneratorsOfSemigroup(S));
[ 1 .. 5 ]

# NrMovedPoints: for a transformation collection
gap> S := Semigroup(Transformation([1, 3, 4, 1, 3]),
>                   Transformation([5, 5, 1, 1, 3]));;
gap> NrMovedPoints(S);
5
gap> NrMovedPoints(GreensRClassOfElement(S, Transformation([1, 3, 4, 1, 3])));
4
gap> NrMovedPoints(GeneratorsOfSemigroup(S));
5

# LargestMovedPoint: for a transformation collection
gap> S := Semigroup(Transformation([1, 3, 4, 1, 3]),
>                   Transformation([5, 5, 1, 1, 3]));;
gap> LargestMovedPoint(S);
5
gap> LargestMovedPoint(GreensRClassOfElement(S, Transformation([1, 3, 4, 1, 3])));
5
gap> LargestMovedPoint(GeneratorsOfSemigroup(S));
5

# SmallestMovedPoint: for a transformation collection
gap> S := Semigroup(Transformation([1, 3, 4, 1, 3]),
>                   Transformation([5, 5, 1, 1, 3]));;
gap> SmallestMovedPoint(S);
1
gap> SmallestMovedPoint(GreensRClassOfElement(S, Transformation([1, 3, 4, 1, 3])));
2
gap> SmallestMovedPoint(GeneratorsOfSemigroup(S));
1

# LargestImageOfMovedPoint: for a transformation collection
gap> S := Semigroup(Transformation([1, 3, 4, 1, 3]),
>                   Transformation([5, 5, 1, 1, 3]));;
gap> LargestImageOfMovedPoint(S);
5
gap> LargestImageOfMovedPoint(GreensRClassOfElement(S, 
> Transformation([1, 3, 4, 1, 3])));
4
gap> LargestImageOfMovedPoint(GeneratorsOfSemigroup(S));
5

# SmallestImageOfMovedPoint: for a transformation collection
gap> S := Semigroup(Transformation([1, 3, 4, 1, 3]),
>                   Transformation([5, 5, 1, 1, 3]));;
gap> SmallestImageOfMovedPoint(S);
1
gap> SmallestImageOfMovedPoint(GreensRClassOfElement(S, 
> Transformation([1, 3, 4, 1, 3])));
1
gap> SmallestImageOfMovedPoint(GeneratorsOfSemigroup(S));
1

# ConstantTransformation
gap> ConstantTransformation(1, 10);
Error, the first argument (a positive integer) must be greater than or equal t\
o the second (a positive integer)
gap> ConstantTransformation(10, 1);
Transformation( [ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 ] )

# Order 
gap> f := Transformation([3, 12, 14, 4, 11, 18, 17, 2, 2, 9, 5, 15, 2, 18,
>                         17, 8, 20, 10, 19, 12]);;
gap> Order(f);
10
gap> Size(Semigroup(f));
10
gap> Size(Semigroup(f, f));
10

# KernelOfTransformation
gap> f := Transformation([2, 6, 7, 2, 6, 9, 9, 1, 11, 1, 12, 5]);;
gap> KernelOfTransformation(f);
[ [ 1, 4 ], [ 2, 5 ], [ 3 ], [ 6, 7 ], [ 8, 10 ], [ 9 ], [ 11 ], [ 12 ] ]
gap> KernelOfTransformation(f, 5);
[ [ 1, 4 ], [ 2, 5 ], [ 3 ] ]
gap> KernelOfTransformation(f, 5, false);
[ [ 1, 4 ], [ 2, 5 ] ]
gap> KernelOfTransformation(f, 5, true);
[ [ 1, 4 ], [ 2, 5 ], [ 3 ] ]
gap> KernelOfTransformation(f, 15);
[ [ 1, 4 ], [ 2, 5 ], [ 3 ], [ 6, 7 ], [ 8, 10 ], [ 9 ], [ 11 ], [ 12 ], 
  [ 13 ], [ 14 ], [ 15 ] ]
gap> KernelOfTransformation(f, false);
[ [ 1, 4 ], [ 2, 5 ], [ 6, 7 ], [ 8, 10 ] ]

# OneMutable: for a transformation collection
gap> S := Semigroup(Transformation([1, 3, 4, 1, 3]),
>                   Transformation([5, 5, 1, 1, 3]));;
gap> OneMutable(S);
IdentityTransformation
gap> OneMutable(GreensRClassOfElement(S, Transformation([1, 3, 4, 1, 3])));
IdentityTransformation
gap> OneMutable(GeneratorsOfSemigroup(S));
IdentityTransformation

# PermLeftQuoTransformation
gap> f := Transformation([2, 6, 7, 2, 6, 9, 9, 1, 11, 1, 12, 5]);;
gap> PermLeftQuoTransformation(f, f);
()
gap> PermLeftQuoTransformation(f, f ^ (1, 2)); # wrong kernel
Error, the arguments (transformations) must have equal image set and kernel
gap> PermLeftQuoTransformation(f, f * (7, 8)); # wrong image
Error, the arguments (transformations) must have equal image set and kernel
gap> PermLeftQuoTransformation(f, f * (2,11,5,6,9));
(2,11,5,6,9)
gap> f := ID_TRANS4;;
gap> IsTrans4Rep(f);
true
gap> PermLeftQuoTransformation(Transformation([2, 1, 3]), f);
(1,2)
gap> PermLeftQuoTransformation(f, Transformation([2, 1, 3]));
(1,2)

# String
gap> String(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 11, 1, 12, 5]));
"Transformation( [ 2, 6, 7, 2, 6, 9, 9, 1, 11, 1, 12, 5 ] )"
gap> String(IdentityTransformation);
"IdentityTransformation"

# ViewString: for fr style viewing
gap> SetUserPreference("NotationForTransformations", "fr");
gap> Transformation([10, 11], x -> x ^ 2);
<transformation: 1,2,3,4,5,6,7,8,9,100,121>
gap> Transformation([2, 6, 7, 2, 6, 9, 9, 1, 11, 1, 12, 5]);
<transformation: 2,6,7,2,6,9,9,1,11,1,12,5>
gap> IdentityTransformation;
<identity transformation>
gap> SetUserPreference("NotationForTransformations", "input");

# RandomTransformation
gap> RandomTransformation(10);;
gap> f := RandomTransformation(10, 3);;
gap> RankOfTransformation(f, 10);
3

# TransformationByImageAndKernel
gap> TransformationByImageAndKernel([1, 2, 4, 4], [1, 2, 3]);
fail
gap> TransformationByImageAndKernel([1, 3, 2, 2], [1, 2, 3]);
fail
gap> TransformationByImageAndKernel([1, 2, 2, 3], [1, 2, 3]);
fail
gap> TransformationByImageAndKernel([1, 2, 3], [1, 2, 4, 4]);
fail
gap> TransformationByImageAndKernel([1, 2, 3], [1, 2, 3, 3]);
Transformation( [ 1, 2, 3, 3 ] )
gap> TransformationByImageAndKernel([1, 2, 3], [1, 3, 2, 2]);
fail
gap> TransformationByImageAndKernel([2, 1, 3], [1, 2, 3, 3]);
Transformation( [ 2, 1, 3, 3 ] )
gap> f := TransformationByImageAndKernel([2, 1, 3], [1, 2, 3, 3]);
Transformation( [ 2, 1, 3, 3 ] )
gap> FlatKernelOfTransformation(f);
[ 1, 2, 3, 3 ]
gap> ImageSetOfTransformation(f);
[ 1, 2, 3 ]
gap> TransformationByImageAndKernel([2, 1, 3], [1, 3, 2, 2]);
fail
gap> TransformationByImageAndKernel([1 .. 2], [1, 2, 3, 2]);
fail
gap> TransformationByImageAndKernel([1 .. 4], [1, 2, 3, 2]);
fail
gap> TransformationByImageAndKernel([1, 2, 4], [1, 2, 3, 2]);
Transformation( [ 1, 2, 4, 2 ] )
gap> TransformationByImageAndKernel([1, 2, 5], [1, 2, 3, 2]);
fail
gap> TransformationByImageAndKernel([1, 1, 5], [1, 2, 3, 2]);
fail
gap> TransformationByImageAndKernel([1, 1, -5], [1, 2, 3, 2]);
fail
gap> TransformationByImageAndKernel([1, 1, -5], [1, 2, -3, 2]);
fail

# Idempotent 
gap> Idempotent([1, 2, 4, 4], [1, 2, 3]);
fail
gap> Idempotent([1, 3, 2, 2], [1, 2, 3]);
fail
gap> Idempotent([1, 2, 2, 3], [1, 2, 3]);
fail
gap> Idempotent([1, 2, 3], [1, 2, 4, 4]);
fail
gap> Idempotent([1, 2, 3], [1, 2, 3, 3]);
Transformation( [ 1, 2, 3, 3 ] )
gap> Idempotent([1, 2, 3], [1, 3, 2, 2]);
fail
gap> Idempotent([2, 1, 3], [1, 2, 3, 3]);
fail
gap> f := Idempotent([2, 1, 3], [1, 2, 3, 3]);
fail
gap> f := Idempotent([1, 2, 3], [1, 2, 3, 3]);
Transformation( [ 1, 2, 3, 3 ] )
gap> FlatKernelOfTransformation(f);
[ 1, 2, 3, 3 ]
gap> ImageSetOfTransformation(f);
[ 1, 2, 3 ]
gap> Idempotent([2, 1, 3], [1, 3, 2, 2]);
fail
gap> Idempotent([1 .. 2], [1, 2, 3, 2]);
fail
gap> Idempotent([1 .. 4], [1, 2, 3, 2]);
fail
gap> Idempotent([1, 2, 4], [1, 2, 3, 2]);
fail
gap> Idempotent([1, 2, 5], [1, 2, 3, 2]);
fail
gap> Idempotent([1, 1, 5], [1, 2, 3, 2]);
fail
gap> Idempotent([1, 1, -5], [1, 2, 3, 2]);
fail
gap> Idempotent([1, 1, -5], [1, 2, -3, 2]);
fail

# TransformationOp, TransformationOpNC
gap> f := Transformation([10, 2, 3, 10, 5, 10, 7, 2, 5, 6]);
Transformation( [ 10, 2, 3, 10, 5, 10, 7, 2, 5, 6 ] )
gap> TransformationOp(f, [2, 3]);
IdentityTransformation
gap> TransformationOp(f, [1, 2, 3]);
fail
gap> S := SemigroupByMultiplicationTable([[1, 1, 1], [1, 1, 1], [1, 1, 2]]);;
gap> TransformationOp(Elements(S)[1], S, OnRight);
Transformation( [ 1, 1, 1 ] )
gap> TransformationOp(Elements(S)[3], S, OnRight);
Transformation( [ 1, 1, 2 ] )
gap> f := TransformationOp(Transformation([1, 3, 1]), ["b", "a", "c"],
> function(i, f) 
>   return "a";
> end);
Transformation( [ 2, 2, 2 ] )
gap> f := TransformationOp(Transformation([1, 3, 1]), ["c", "b", "a"],
> function(i, f) 
>   return "a";
> end);
Transformation( [ 3, 3, 3 ] )
gap> f := TransformationOp(Transformation([1, 3, 1]), [[1, 2], [2, 3], [1, 3]],
> OnSets);
fail
gap> f := TransformationOp(Transformation([1, 2, 1]), [[1, 2], [2, 3]],
> OnSets);
Transformation( [ 1, 1 ] )
gap> f := TransformationOp(Transformation([1, 2, 1]), [[2, 3], [1, 2], [4, 5]],
> OnSets);
Transformation( [ 2, 2 ] )
gap> f := Transformation([10, 2, 3, 10, 5, 10, 7, 2, 5, 6]);
Transformation( [ 10, 2, 3, 10, 5, 10, 7, 2, 5, 6 ] )
gap> TransformationOpNC(f, [2, 3]);
IdentityTransformation
gap> S := SemigroupByMultiplicationTable([[1, 1, 1], [1, 1, 1], [1, 1, 2]]);;
gap> TransformationOpNC(Elements(S)[1], S, OnRight);
Transformation( [ 1, 1, 1 ] )
gap> TransformationOpNC(Elements(S)[3], S, OnRight);
Transformation( [ 1, 1, 2 ] )
gap> f := TransformationOpNC(Transformation([1, 3, 1]), ["b", "a", "c"],
> function(i, f) 
>   return "a";
> end);
Transformation( [ 2, 2, 2 ] )
gap> f := TransformationOpNC(Transformation([1, 3, 1]), ["c", "b", "a"],
> function(i, f) 
>   return "a";
> end);
Transformation( [ 3, 3, 3 ] )
gap> f := TransformationOpNC(Transformation([1, 2, 1]), [[1, 2], [2, 3]],
> OnSets);
Transformation( [ 1, 1 ] )
gap> f := TransformationOpNC(Transformation([1, 2, 1]), [[2, 3], [1, 2], [4, 5]],
> OnSets);
Transformation( [ 2, 2 ] )

# InverseMutable
gap> InverseMutable(Transformation([2, 2]));
fail
gap> InverseMutable(Transformation([2, 3, 1]));
Transformation( [ 3, 1, 2 ] )
gap> InverseMutable(IdentityTransformation);
IdentityTransformation

# AsBinaryRelation
gap> b := AsBinaryRelation(Transformation([10, 5, 9, 10, 9, 6, 3, 8, 4, 6]));
Binary Relation on 10 points
gap> Successors(b);
[ [ 10 ], [ 5 ], [ 9 ], [ 10 ], [ 9 ], [ 6 ], [ 3 ], [ 8 ], [ 4 ], [ 6 ] ]
gap> AsTransformation(b);
Transformation( [ 10, 5, 9, 10, 9, 6, 3, 8, 4, 6 ] )
gap> AsTransformation(b ^ -1);
Error, the argument must be a binary relation which is a mapping

#
gap> SetUserPreference("TransformationDisplayLimit", display);;
gap> SetUserPreference("NotationForTransformations", notation);;

#
gap> STOP_TEST("trans.tst", 1);
