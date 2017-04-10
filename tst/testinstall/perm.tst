gap> START_TEST("perm.tst");

# Permutations come in two flavors in GAP, with two TNUMs: T_PERM2 for
# permutations of degree up to 2^16, and T_PERM4 for permutations of degree up
# to 2^32. Here is an example:
gap> TNUM_OBJ((1000,2^16));
[ 6, "permutation (small)" ]
gap> x:=(1000,2^16+1); TNUM_OBJ(x);
(1000,65537)
[ 7, "permutation (large)" ]

# Note that permutations are not necessarily stored with minimized degree, so
# e.g. the transposition (1,2) can in principle be stored with either TNUM.
gap> TNUM_OBJ((1,2));
[ 6, "permutation (small)" ]
gap> y:=(1,2)^x; TNUM_OBJ(x);
(1,2)
[ 7, "permutation (large)" ]

# The GAP kernel implements many functions in multiple variants, e.g. to
# compare permutations for equality, there are actually four functions in the
# kernel that deal with the various combinations of types of input arguments.
# Thus, our tests need to take this into account, too.
# #
# For this, we use the elements of Sym(3), once as T_PERM2 and once as T_PERM4.
gap> permSml := [ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ];
[ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ]
gap> n := Length(permSml);
6
gap> IsSet(permSml);
true
gap> permBig := List(permSml, g -> g^x);
[ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ]
gap> IsSet(permBig);
true

#
# PrintPerm
#
gap> Print(permSml, "\n");
[ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ]
gap> Print(permSml * (5,99), "\n");
[ ( 5,99), ( 2, 3)( 5,99), ( 1, 2)( 5,99), ( 1, 2, 3)( 5,99), 
  ( 1, 3, 2)( 5,99), ( 1, 3)( 5,99) ]
gap> Print(permSml * (5,999), "\n");
[ (  5,999), (  2,  3)(  5,999), (  1,  2)(  5,999), (  1,  2,  3)(  5,999), 
  (  1,  3,  2)(  5,999), (  1,  3)(  5,999) ]
gap> Print(permSml * (5,9999), "\n");
[ (   5,9999), (   2,   3)(   5,9999), (   1,   2)(   5,9999), 
  (   1,   2,   3)(   5,9999), (   1,   3,   2)(   5,9999), 
  (   1,   3)(   5,9999) ]

#
gap> Print(permBig, "\n");
[ (), (    2,    3), (    1,    2), (    1,    2,    3), (    1,    3,    2), 
  (    1,    3) ]
gap> Print(permBig * (5,99), "\n");
[ (    5,   99), (    2,    3)(    5,   99), (    1,    2)(    5,   99), 
  (    1,    2,    3)(    5,   99), (    1,    3,    2)(    5,   99), 
  (    1,    3)(    5,   99) ]
gap> Print(permBig * (5,999), "\n");
[ (    5,  999), (    2,    3)(    5,  999), (    1,    2)(    5,  999), 
  (    1,    2,    3)(    5,  999), (    1,    3,    2)(    5,  999), 
  (    1,    3)(    5,  999) ]
gap> Print(permBig * (5,9999), "\n");
[ (    5, 9999), (    2,    3)(    5, 9999), (    1,    2)(    5, 9999), 
  (    1,    2,    3)(    5, 9999), (    1,    3,    2)(    5, 9999), 
  (    1,    3)(    5, 9999) ]
gap> Print(permBig * (5,99999), "\n");
[ (    5,99999), (    2,    3)(    5,99999), (    1,    2)(    5,99999), 
  (    1,    2,    3)(    5,99999), (    1,    3,    2)(    5,99999), 
  (    1,    3)(    5,99999) ]
gap> Print(permBig * (5,999999), "\n");
[ (    5,999999), (    2,    3)(    5,999999), (    1,    2)(    5,999999), 
  (    1,    2,    3)(    5,999999), (    1,    3,    2)(    5,999999), 
  (    1,    3)(    5,999999) ]

#
# EqPerm
#
gap> ForAll([1..n], i -> ForAll([1..n], j-> (permSml[i] = permSml[j]) = (i = j)));
true
gap> ForAll([1..n], i -> ForAll([1..n], j-> (permSml[i] = permBig[j]) = (i = j)));
true
gap> ForAll([1..n], i -> ForAll([1..n], j-> (permBig[i] = permSml[j]) = (i = j)));
true
gap> ForAll([1..n], i -> ForAll([1..n], j-> (permBig[i] = permBig[j]) = (i = j)));
true

#
# LtPerm
#
gap> ForAll([1..n], i -> ForAll([1..n], j-> (permSml[i] < permSml[j]) = (i < j)));
true
gap> ForAll([1..n], i -> ForAll([1..n], j-> (permSml[i] < permBig[j]) = (i < j)));
true
gap> ForAll([1..n], i -> ForAll([1..n], j-> (permBig[i] < permSml[j]) = (i < j)));
true
gap> ForAll([1..n], i -> ForAll([1..n], j-> (permBig[i] < permBig[j]) = (i < j)));
true

#
# ProdPerm
#
gap> List(permSml,x->List(permSml,y->x*y));
[ [ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ], 
  [ (2,3), (), (1,2,3), (1,2), (1,3), (1,3,2) ], 
  [ (1,2), (1,3,2), (), (1,3), (2,3), (1,2,3) ], 
  [ (1,2,3), (1,3), (2,3), (1,3,2), (), (1,2) ], 
  [ (1,3,2), (1,2), (1,3), (), (1,2,3), (2,3) ], 
  [ (1,3), (1,2,3), (1,3,2), (2,3), (1,2), () ] ]
gap> List(permSml,x->List(permBig,y->x*y));
[ [ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ], 
  [ (2,3), (), (1,2,3), (1,2), (1,3), (1,3,2) ], 
  [ (1,2), (1,3,2), (), (1,3), (2,3), (1,2,3) ], 
  [ (1,2,3), (1,3), (2,3), (1,3,2), (), (1,2) ], 
  [ (1,3,2), (1,2), (1,3), (), (1,2,3), (2,3) ], 
  [ (1,3), (1,2,3), (1,3,2), (2,3), (1,2), () ] ]
gap> List(permBig,x->List(permSml,y->x*y));
[ [ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ], 
  [ (2,3), (), (1,2,3), (1,2), (1,3), (1,3,2) ], 
  [ (1,2), (1,3,2), (), (1,3), (2,3), (1,2,3) ], 
  [ (1,2,3), (1,3), (2,3), (1,3,2), (), (1,2) ], 
  [ (1,3,2), (1,2), (1,3), (), (1,2,3), (2,3) ], 
  [ (1,3), (1,2,3), (1,3,2), (2,3), (1,2), () ] ]
gap> List(permBig,x->List(permBig,y->x*y));
[ [ (), (2,3), (1,2), (1,2,3), (1,3,2), (1,3) ], 
  [ (2,3), (), (1,2,3), (1,2), (1,3), (1,3,2) ], 
  [ (1,2), (1,3,2), (), (1,3), (2,3), (1,2,3) ], 
  [ (1,2,3), (1,3), (2,3), (1,3,2), (), (1,2) ], 
  [ (1,3,2), (1,2), (1,3), (), (1,2,3), (2,3) ], 
  [ (1,3), (1,2,3), (1,3,2), (2,3), (1,2), () ] ]

#
# PermList
#
gap> PermList([1,2,3]) = ();
true
gap> () = PermList([1,2,3]);
true
gap> (1,2) = PermList([2,1,3]);
true
gap> PermList([2,1,3]) = (1,2);
true
gap> checklens := Concatenation([1..20], [2^15-10..2^15+10],
>                               [2^16-10..2^16+10], [2^17-10..2^17+10]);;
gap> ForAll(checklens, n -> PermList(Concatenation([1..n-1], [n+1,n])) =
>                           PermList(Concatenation([1..n-1],[n+1,n,n+2])));
true
gap> ForAll(checklens, n -> not(
>  PermList(Concatenation([1..n-1], [n+1,n,n+2,n+4,n+3])) =
>  PermList(Concatenation([1..n-1], [n+1,n+2,n,n+4,n+3]))));
true

#
# MappingPermListList
#
gap> MappingPermListList([1,1], [2,2]);
(1,2)
gap> MappingPermListList([1,2], [2,1]);
(1,2)
gap> MappingPermListList([1,2], [3,4]);
(1,3)(2,4)
gap> (1,128000) = ();
false
gap> (1,128000) * (129000, 129002);
(1,128000)(129000,129002)
gap> (1,128000) * (128000,128001);
(1,128001,128000)
gap> (128000,256000,512000) ^ (-1);
(128000,512000,256000)
gap> (1,2) * (128000,128001);
(1,2)(128000,128001)
gap> STOP_TEST("perm.tst", 1);
