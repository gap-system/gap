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
Error, TransformationListListNC: <src>[3] must be a list (not a character)
gap> TransformationListListNC([1, 2, 3], "abc");
Error, TransformationListListNC: <ran>[3] must be a list (not a character)
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
Error, DegreeOfTransformation: <f> must be a transformation (not a permutation\
 (small))

# Test RANK_TRANS
gap> RANK_TRANS(Transformation([1, 2, 3]));
0
gap> RANK_TRANS(Transformation([1, 2, 1]));
2
gap> RANK_TRANS(Transformation([1, 2, 1]) ^ (4, 65537));
2
gap> RANK_TRANS("a");
Error, RANK_TRANS: <f> must be a transformation (not a list (string))

# Test RANK_TRANS_INT
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

# Test RANK_TRANS_INT
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
7
gap> RANK_TRANS_LIST("a", [1, 3]);
Error, RANK_TRANS_LIST: the first argument must be a transformation (not a lis\
t (string))
gap> RANK_TRANS_LIST(Transformation([65537], [1]), 
>                    Concatenation([1], [65536 .. 70000]));
4464

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
gap> IMAGE_SET_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]));
[ 1, 2, 4, 5 ]
gap> IMAGE_SET_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1)) 
> = [1 .. 65536];
true
gap> IMAGE_SET_TRANS("a");
Error, IMAGE_SET_TRANS: the first argument must be a transformation (not a lis\
t (string))
gap> IMAGE_SET_TRANS(Transformation([2, 1, 2, 4, 5]));
[ 1, 2, 4, 5 ]
gap> IMAGE_SET_TRANS(Transformation([4, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]));
[ 1, 2, 4, 5 ]
gap> IMAGE_SET_TRANS(Transformation([1], [65537])) 
> = [2 .. 65537];
true

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

# Test IMAGE_TRANS
gap> IMAGE_TRANS(IdentityTransformation, -1);
Error, IMAGE_TRANS: the second argument must be a non-negative integer
gap> IMAGE_TRANS(IdentityTransformation, "a");
Error, IMAGE_TRANS: the second argument must be a non-negative integer
gap> IMAGE_TRANS(IdentityTransformation, 10);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> IMAGE_TRANS(IdentityTransformation, 0);
[  ]
gap> IMAGE_TRANS(Transformation([1, 2, 1, 4, 5]), 0);
[  ]
gap> IMAGE_TRANS(Transformation([2, 1, 1, 4, 5]), 3);
[ 2, 1, 1 ]
gap> IMAGE_TRANS(Transformation([2, 1, 1, 4, 5]), 10);
[ 2, 1, 1, 4, 5, 6, 7, 8, 9, 10 ]
gap> IMAGE_TRANS(Transformation([1, 2, 1, 4, 5]), 5);
[ 1, 2, 1, 4, 5 ]
gap> IMAGE_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 0);
[  ]
gap> IMAGE_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 7);
[ 1, 2, 1, 4, 5, 1, 1 ]
gap> IMAGE_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 14);
[ 1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1, 12, 13, 14 ]
gap> IMAGE_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 11);
[ 1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1 ]
gap> IMAGE_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 70000) 
> = Concatenation([1 .. 65536], [65537 .. 70000] * 0 + 1);
true
gap> IMAGE_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 65555) 
> = Concatenation([1 .. 65536], [65537 .. 65555] * 0 + 1);
true
gap> IMAGE_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 70010) 
> = Concatenation([1 .. 65536], [65537 .. 70000] * 0 + 1, List([1 .. 10], x -> x + 70000));
true
gap> IMAGE_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 10);
[ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
gap> IMAGE_TRANS(Transformation([65537 .. 70000], [65537 .. 70000] * 0 + 1), 0);
[  ]
gap> IMAGE_TRANS("a", 2);
Error, IMAGE_TRANS: the first argument must be a transformation (not a list (s\
tring))

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

# Test PERM_IMG_TRANS
gap> PERM_IMG_TRANS(Transformation([2, 6, 7, 2, 6, 9, 9, 1, 1, 5]));
fail
gap> PERM_IMG_TRANS(Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6]));
fail
gap> PERM_IMG_TRANS(Transformation([65537], [1]));
()
gap> PERM_IMG_TRANS(Transformation([1, 2, 3, 4, 5, 6, 7, 8, 9, 1]));
()
gap> PERM_IMG_TRANS(Transformation([2, 3, 1, 4, 5, 6, 7, 8, 9, 2]));
(1,2,3)
gap> PERM_IMG_TRANS(Transformation([1 .. 65537], x -> x + 1));
fail
gap> PERM_IMG_TRANS(1);
Error, PERM_IMG_TRANS: the first argument must be a transformation (not a inte\
ger)

# Test RESTRICTED_TRANS
gap> RESTRICTED_TRANS(IdentityTransformation, [1, -1]);
Error, RESTRICTED_TRANS: <list>[2] must be a positive integer (not a integer)
gap> RESTRICTED_TRANS(IdentityTransformation, "a");
Error, RESTRICTED_TRANS: <list>[1] must be a positive integer (not a character\
)
gap> RESTRICTED_TRANS(IdentityTransformation, [1,, 3]);
Error, List Element: <list>[2] must have an assigned value
gap> RESTRICTED_TRANS(IdentityTransformation, [1 .. 10]);
IdentityTransformation
gap> RESTRICTED_TRANS(IdentityTransformation, [0]);
Error, RESTRICTED_TRANS: <list>[1] must be a positive integer (not a integer)
gap> RESTRICTED_TRANS(Transformation([1, 2, 1, 4, 5]), [1, 3, 5]);
Transformation( [ 1, 2, 1 ] )
gap> RESTRICTED_TRANS(Transformation([2, 1, 1, 4, 5]), [1 .. 3]);
Transformation( [ 2, 1, 1 ] )
gap> RESTRICTED_TRANS(Transformation([2, 1, 1, 4, 5]), [1 .. 10]);
Transformation( [ 2, 1, 1 ] )
gap> RESTRICTED_TRANS(Transformation([1, 2, 1, 4, 5]), [1 .. 5]);
Transformation( [ 1, 2, 1 ] )
gap> RESTRICTED_TRANS(Transformation([1, 2, 1, 4, 5, 1, 1, 1, 1, 1, 1]), 0);
Error, RESTRICTED_TRANS: the second argument must be a list (not a integer)
gap> RESTRICTED_TRANS(Transformation([65537 .. 70000], 
>                                    [65537 .. 70000] * 0 + 1), [1 .. 65536]);
IdentityTransformation
gap> RESTRICTED_TRANS(Transformation([65537 .. 70000], 
>                                    [65537 .. 70000] * 0 + 1), [65537 .. 65555]);
<transformation on 65555 pts with rank 65536>
gap> RESTRICTED_TRANS(Transformation([65537 .. 70000], 
>                                    [65537 .. 70000] * 0 + 1), [1, -1]);
Error, RESTRICTED_TRANS: <list>[2] must be a positive integer (not a integer)
gap> RESTRICTED_TRANS("a", [1 .. 10]);
Error, RESTRICTED_TRANS: the first argument must be a transformation (not a li\
st (string))

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

# Test IS_INJECTIVE_LIST_TRANS
gap> f := Transformation([9, 3, 2, 3, 1, 8, 2, 7, 8, 3, 12, 10]);;
gap> IS_INJECTIVE_LIST_TRANS([1, 2, 3, 6, 5], f);
true
gap> IS_INJECTIVE_LIST_TRANS([1 .. 5], f);     
false
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> IS_INJECTIVE_LIST_TRANS(ImageSetOfTransformation(f), f);
true
gap> IS_INJECTIVE_LIST_TRANS([1 .. RankOfTransformation(f) + 1], f);   
false
gap> IS_INJECTIVE_LIST_TRANS([1 .. RankOfTransformation(f) + 1], 
>                            ImageListOfTransformation(f));
false
gap> f := Transformation([12, 3, 4, 12, 1, 2, 12, 1, 5, 1, 10, 7]);;
gap> IS_INJECTIVE_LIST_TRANS([1 .. 3], f);                    
true
gap> IS_INJECTIVE_LIST_TRANS([1 .. 4], f);
false
gap> IS_INJECTIVE_LIST_TRANS([1 .. 4], ImageListOfTransformation(f));
false
gap> IS_INJECTIVE_LIST_TRANS([1 .. 3], ImageListOfTransformation(f));
true
gap> f := Transformation([11, 9, 3, 8, 10, 11, 6, 1, 8, 8, 4, 11]);;
gap> RankOfTransformation(f);
8
gap> IS_INJECTIVE_LIST_TRANS([1 .. 5], f);                           
true
gap> IS_INJECTIVE_LIST_TRANS([1 .. 6], f);
false
gap> f := Transformation([5, 5, 3, 10, 10, 10, 2, 12, 11, 9, 1, 6]);;
gap> IS_INJECTIVE_LIST_TRANS([2, 3], f);
true
gap> IS_INJECTIVE_LIST_TRANS([2, 3, 4, 7], f);
true
gap> IS_INJECTIVE_LIST_TRANS([2, 3, 4, 5, 7], f);
false
gap> IS_INJECTIVE_LIST_TRANS([65536], f);
true
gap> IS_INJECTIVE_LIST_TRANS([1 .. 65536], f);
false
gap> IS_INJECTIVE_LIST_TRANS([1 .. 65536], ImageListOfTransformation(f));
false
gap> IS_INJECTIVE_LIST_TRANS([65536], ImageListOfTransformation(f));
true

# Test PERM_LEFT_QUO_TRANS_NC
gap> f := Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6]);;
gap> PERM_LEFT_QUO_TRANS_NC(f, f);
()
gap> p := (1, 9, 10, 8)(4, 5, 6);;
gap> PERM_LEFT_QUO_TRANS_NC(f * p, f);
(1,8,10,9)(4,6,5)
gap> PERM_LEFT_QUO_TRANS_NC(f, f * p);   
(1,9,10,8)(4,5,6)
gap> p := (1, 8, 4, 6, 3, 10, 5);;
gap> PERM_LEFT_QUO_TRANS_NC(f, f * p);
(1,8,4,6,3,10,5)
gap> PERM_LEFT_QUO_TRANS_NC(f * p, f);                     
(1,5,10,3,6,4,8)
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1) 
>         * (1,65, 1414, 13485)(139, 1943, 858, 65536);;
gap> p := (1, 10, 20)(414, 1441, 59265);; 
gap> PERM_LEFT_QUO_TRANS_NC(f * p, f) = p ^ -1;
true
gap> PERM_LEFT_QUO_TRANS_NC(f, f * p) = p;   
true
gap> f := Transformation([2, 6, 7, 2, 6, 9, 9, 1, 11, 1, 12, 5]);;
gap> PERM_LEFT_QUO_TRANS_NC(f, f * (1, 2, 3));
(1,2,3)
gap> g := f * (1, 2, 5);;
gap> PERM_LEFT_QUO_TRANS_NC(f, g);
(1,2,5)
gap> PERM_LEFT_QUO_TRANS_NC(g, f);
(1,5,2)
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> g := f * (12849, 19491, 3501, 1593)(1341, 19414, 194)(1413, 19);;
gap> p := PERM_LEFT_QUO_TRANS_NC(f, g);
(19,1413)(194,1341,19414)(1593,12849,19491,3501)
gap> q := PERM_LEFT_QUO_TRANS_NC(g, f);
(19,1413)(194,19414,1341)(1593,3501,19491,12849)
gap> p = q ^ -1;
true
gap> q = p ^ -1;
true
gap> PERM_LEFT_QUO_TRANS_NC((), IdentityTransformation);
Error, PERM_LEFT_QUO_TRANS_NC: the arguments must both be transformations (not\
 permutation (small) and transformation (small))
gap> PERM_LEFT_QUO_TRANS_NC(IdentityTransformation, ());
Error, PERM_LEFT_QUO_TRANS_NC: the arguments must both be transformations (not\
 transformation (small) and permutation (small))
gap> PERM_LEFT_QUO_TRANS_NC((), ());
Error, PERM_LEFT_QUO_TRANS_NC: the arguments must both be transformations (not\
 permutation (small) and permutation (small))
gap> g := Transformation([3, 8, 1, 9, 9, 4, 10, 5, 10, 6]);;
gap> f := (g ^ (2, 20)) * (1, 3, 8)(6, 9);;
gap> PERM_LEFT_QUO_TRANS_NC(f, g);
(1,20)(2,8,3)(6,9)
gap> f := Transformation([3, 8, 1, 9, 1, 3, 10, 5, 10, 6]);;
gap> g := (f ^ (2, 65537)) *  (1, 3, 8)(6, 9);;
gap> PERM_LEFT_QUO_TRANS_NC(f, g);
(1,3,8,2)(6,9)
gap> PERM_LEFT_QUO_TRANS_NC(g, f);
(1,65537)(2,8,3)(6,9)
gap> g := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> f := g ^ (70001, 70002);;
gap> PERM_LEFT_QUO_TRANS_NC(f, g);
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

# Test INV_TRANS
gap> INV_TRANS(IdentityTransformation);
IdentityTransformation
gap> f := Transformation( [ 5, 9, 1, 7, 9, 5, 2, 8, 4, 1 ] );;
gap> g := INV_TRANS(f);
Transformation( [ 3, 7, 1, 9, 1, 1, 4, 8, 2, 1 ] )
gap> f * g * f = f and g * f * g = g;
true
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1);;
gap> g := INV_TRANS(f);;
gap> f * g * f = f and g * f * g = g;
true
gap> g := INV_TRANS(1);
Error, INV_TRANS: the argument must be a transformation (not a integer)

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
gap> x := INDEX_PERIOD_TRANS(f);
[ 3, 5 ]
gap> f ^ (x[1] + x[2]) = f ^ x[1];
true
gap> f := Transformation([65537 .. 70000], 
>                        [65537 .. 70000] * 0 + 1) 
>         * (14918, 184, 141)(14140, 124);;
gap> x := INDEX_PERIOD_TRANS(f);
[ 1, 6 ]
gap> f ^ (x[1] + x[2]) = f ^ x[1];
true
gap> f := Transformation(
> [5, 23, 27, 8, 21, 49, 36, 33, 4, 44, 3, 49, 48, 18, 10, 30, 47, 3, 41, 35, 
>  33, 15, 39, 19, 37, 24, 26, 2, 16, 47, 9, 7, 28, 47, 25, 21, 50, 23, 18, 42, 26, 
>  40, 40, 4, 43, 27, 45, 35, 40, 14]);;
gap> INDEX_PERIOD_TRANS(f);
[ 14, 4 ]
gap> f ^ 18 = f ^ 14;
true
gap> f :=
> Transformation( [ 74, 33, 77, 60, 65, 37, 24, 22, 16, 49, 58, 16, 62, 7, 69,
>  38, 97, 44, 56, 5, 3, 74, 89, 28, 95, 94, 56, 6, 38, 58, 45, 63, 32, 32,
>  38, 27, 36, 28, 81, 41, 85, 95, 55, 19, 58, 16, 65, 55, 61, 87, 40, 37, 89,
>  47, 48, 42, 82, 37, 34, 25, 26, 19, 44, 13, 15, 27, 41, 99, 15, 69, 8, 19,
>  85, 8, 96, 8, 69, 97, 31, 22, 71, 39, 91, 13, 76, 53, 37, 78, 27, 91, 46,
>  32, 64, 70, 84, 92, 37, 68, 10, 68 ] );;
gap> INDEX_PERIOD_TRANS(f);
[ 10, 42 ]
gap> f :=
> Transformation( [ 45, 51, 70, 26, 87, 94, 23, 19, 86, 46, 45, 51, 57, 13, 67,
>  5, 38, 20, 51, 25, 67, 91, 38, 29, 43, 44, 84, 71, 11, 39, 52, 40, 12, 58,
>  1, 83, 9, 27, 1, 25, 86, 83, 15, 38, 86, 61, 43, 16, 55, 16, 96, 46, 46,
>  70, 29, 11, 13, 8, 14, 67, 84, 17, 79, 44, 59, 19, 35, 19, 61, 49, 32, 24,
>  45, 71, 2, 90, 12, 4, 43, 61, 63, 64, 34, 92, 77, 19, 8, 23, 85, 26, 87, 8,
>  76, 18, 48, 33, 8, 7, 38, 39 ] );;
gap> INDEX_PERIOD_TRANS(f);
[ 13, 4 ]
gap> f:=
> Transformation( [ 14, 24, 70, 1, 50, 72, 13, 64, 65, 68, 54, 20, 69, 32, 88,
>  60, 93, 100, 37, 27, 15, 7, 84, 95, 84, 36, 8, 20, 90, 55, 78, 48, 93, 10,
>  51, 76, 26, 83, 29, 39, 93, 48, 51, 93, 50, 92, 95, 51, 31, 17, 76, 43, 5,
>  19, 94, 11, 70, 84, 22, 95, 5, 44, 44, 6, 7, 56, 4, 57, 94, 100, 86, 30,
>  38, 80, 77, 60, 45, 99, 38, 11, 60, 62, 76, 50, 13, 48, 27, 82, 68, 99, 17,
>  81, 16, 3, 14, 90, 22, 71, 41, 98 ] );;
gap> INDEX_PERIOD_TRANS(f);
[ 16, 7 ]
gap> INDEX_PERIOD_TRANS(IdentityTransformation);
[ 0, 0 ]
gap> INDEX_PERIOD_TRANS("a");
Error, INDEX_PERIOD_TRANS: the argument must be a transformation (not a list (\
string))

#
gap> SetUserPreference("TransformationDisplayLimit", display);;
gap> SetUserPreference("NotationForTransformations", notation);;

#
gap> STOP_TEST( "trans.tst", 74170000);
