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

# Test INIT_TRANS4 (for the special case of degree 0)
gap> x := AsTransformation((2, 65537) * (1, 65537) * (2, 65537));;
gap> ImageSetOfTransformation(x);
[ 1, 2 ]

# Test for the issue with caching the degree of a transformation in PR #384
gap> x := Transformation([1, 1]) ^ (1,2)(3,70000);
Transformation( [ 2, 2 ] )
gap> IsTrans4Rep(x);
true
gap> HASH_FUNC_FOR_TRANS(x, 101);;
gap> x;
Transformation( [ 2, 2 ] )

#
gap> SetUserPreference("TransformationDisplayLimit", display);;
gap> SetUserPreference("NotationForTransformations", notation);;

#
gap> STOP_TEST( "trans.tst", 74170000);
