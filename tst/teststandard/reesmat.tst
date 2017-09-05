#############################################################################
##
#W  reemat.tst                  GAP library                 J. D. Mitchell
##
##
#Y  Copyright (C) 2013 The GAP Group
##
gap> START_TEST("reesmat.tst");

#
#gap> S:=FullTransformationSemigroup(5);;
#gap> d:=GreensDClasses(S)[3];;
#gap> R:=AssociatedReesMatrixSemigroupOfDClass(d);;
gap> mat:=
> [ [ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, (), (), (), (), (), (), 
>      (), (), () ], 
>  [ 0, 0, 0, 0, 0, 0, 0, 0, (), (), (), 0, 0, (), (), (), 0, 0, 0, 0, 0, 0, 
>      (), (), () ], 
>  [ 0, 0, 0, 0, 0, 0, (), (), 0, 0, (), (), (), 0, 0, (), 0, 0, (), 0, 0, (), 
>      0, 0, () ], 
>  [ 0, 0, 0, (), (), (), 0, 0, 0, 0, 0, 0, 0, (), (), (), 0, 0, 0, 
>      (1,2)(3,5)(4,6), (1,2)(3,5)(4,6), (1,2)(3,5)(4,6), 0, 0, 0 ], 
>  [ 0, (), (), 0, 0, (), 0, 0, 0, 0, 0, (), (), 0, 0, (), 0, (1,2)(3,5)(4,6), 
>      0, 0, (1,2)(3,5)(4,6), 0, 0, (1,2)(3,5)(4,6), 0 ], 
>  [ (), 0, (), 0, (1,2)(3,5)(4,6), 0, 0, (), 0, (1,2)(3,5)(4,6), 0, 0, (), 0, 
>      (1,2)(3,5)(4,6), 0, 0, 0, 0, 0, 0, (), 0, (1,2)(3,5)(4,6), 0 ], 
>  [ 0, 0, 0, (), (), (), 0, 0, (1,3)(2,4)(5,6), (1,3)(2,4)(5,6), 
>      (1,3)(2,4)(5,6), 0, 0, 0, 0, 0, (1,4,5)(2,3,6), (1,4,5)(2,3,6), 
>      (1,4,5)(2,3,6), 0, 0, 0, 0, 0, 0 ], 
>  [ 0, (), (), 0, 0, (), (1,3)(2,4)(5,6), (1,3)(2,4)(5,6), 0, 0, 
>      (1,3)(2,4)(5,6), 0, 0, 0, 0, 0, (1,4,5)(2,3,6), 0, 0, (1,4,5)(2,3,6), 
>      0, 0, (1,4,5)(2,3,6), 0, 0 ], 
>  [ (), 0, (), 0, (1,2)(3,5)(4,6), 0, (1,3)(2,4)(5,6), 0, (1,4,5)(2,3,6), 0, 
>      0, (1,3)(2,4)(5,6), 0, (1,4,5)(2,3,6), 0, 0, 0, 0, (1,3)(2,4)(5,6), 0, 
>      0, 0, (1,4,5)(2,3,6), 0, 0 ], 
>  [ (), (1,3)(2,4)(5,6), 0, (1,4,5)(2,3,6), 0, 0, 0, (), 0, (1,2)(3,5)(4,6), 
>      0, (1,3)(2,4)(5,6), 0, (1,4,5)(2,3,6), 0, 0, 0, (1,5,4)(2,6,3), 0, 
>      (1,6)(2,5)(3,4), 0, 0, 0, 0, 0 ] ];;
gap> R:=ReesZeroMatrixSemigroup(Group([ (1,2)(3,5)(4,6), (1,3)(2,4)(5,6) ]), 
> mat);
<Rees 0-matrix semigroup 25x10 over Group([ (1,2)(3,5)(4,6), (1,3)(2,4)
(5,6) ])>
gap> Size(R);
1501
gap> ForAll(R, x-> x in R);
true
gap> Representative(R) in R;
true
gap> RMSElement(R, 25, (), 10);
(25,(),10)
gap> RMSElement(R, 25, (), 10) in R;
true
gap> RMSElement(R, 25, (), 11) in R;
Error, the fourth argument (a positive integer) does not belong to the columns\
 of the first argument (a Rees (0-)matrix semigroup)
gap> U:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(R, 
> [1..20], Group(()), [5,6,7,8,10]));
<subsemigroup of 25x10 Rees 0-matrix semigroup with 24 generators>
gap> V:=Semigroup(RMSElement(R, 24,(1,6)(2,5)(3,4),4), 
> RMSElement(R, 19,(1,6)(2,5)(3,4),8), RMSElement(R, 16,(1,4,5)(2,3,6),3), 
> RMSElement(R, 9,(1,5,4)(2,6,3),2), RMSElement(R, 2,(1,4,5)(2,3,6),6));
<subsemigroup of 25x10 Rees 0-matrix semigroup with 5 generators>
gap> Size(V);
124
gap> IsReesMatrixSemigroup(V);
false
gap> Rows(V);
fail
gap> IsSimpleSemigroup(V);
false
gap> MultiplicativeZero(R) in V;
true
gap> IsZeroSimpleSemigroup(V);
false
gap> MultiplicativeZero(V);
0
gap> IsReesZeroMatrixSemigroup(V);
false
gap> V:=Semigroup(RMSElement(R, 13,(),1), RMSElement(R, 3,(1,6)(2,5)(3,4),8),
> RMSElement(R, 11,(1,3)(2,4)(5,6),1), RMSElement(R, 11,(1,6)(2,5)(3,4),3), 
> RMSElement(R, 21,(1,4,5)(2,3,6),9));
<subsemigroup of 25x10 Rees 0-matrix semigroup with 5 generators>
gap> HasIsSimpleSemigroup(V); HasIsZeroSimpleSemigroup(V);
false
false
gap> MultiplicativeZero(V);
0
gap> Elements(V);
[ 0, (3,(),1), (3,(),3), (3,(),8), (3,(),9), (3,(1,2)(3,5)(4,6),1), 
  (3,(1,2)(3,5)(4,6),3), (3,(1,2)(3,5)(4,6),8), (3,(1,2)(3,5)(4,6),9), 
  (3,(1,3)(2,4)(5,6),1), (3,(1,3)(2,4)(5,6),3), (3,(1,3)(2,4)(5,6),8), 
  (3,(1,3)(2,4)(5,6),9), (3,(1,4,5)(2,3,6),1), (3,(1,4,5)(2,3,6),3), 
  (3,(1,4,5)(2,3,6),8), (3,(1,4,5)(2,3,6),9), (3,(1,5,4)(2,6,3),1), 
  (3,(1,5,4)(2,6,3),3), (3,(1,5,4)(2,6,3),8), (3,(1,5,4)(2,6,3),9), 
  (3,(1,6)(2,5)(3,4),1), (3,(1,6)(2,5)(3,4),3), (3,(1,6)(2,5)(3,4),8), 
  (3,(1,6)(2,5)(3,4),9), (11,(),1), (11,(),3), (11,(),8), (11,(),9), 
  (11,(1,2)(3,5)(4,6),1), (11,(1,2)(3,5)(4,6),3), (11,(1,2)(3,5)(4,6),8), 
  (11,(1,2)(3,5)(4,6),9), (11,(1,3)(2,4)(5,6),1), (11,(1,3)(2,4)(5,6),3), 
  (11,(1,3)(2,4)(5,6),8), (11,(1,3)(2,4)(5,6),9), (11,(1,4,5)(2,3,6),1), 
  (11,(1,4,5)(2,3,6),3), (11,(1,4,5)(2,3,6),8), (11,(1,4,5)(2,3,6),9), 
  (11,(1,5,4)(2,6,3),1), (11,(1,5,4)(2,6,3),3), (11,(1,5,4)(2,6,3),8), 
  (11,(1,5,4)(2,6,3),9), (11,(1,6)(2,5)(3,4),1), (11,(1,6)(2,5)(3,4),3), 
  (11,(1,6)(2,5)(3,4),8), (11,(1,6)(2,5)(3,4),9), (13,(),1), (13,(),3), 
  (13,(),8), (13,(),9), (13,(1,2)(3,5)(4,6),1), (13,(1,2)(3,5)(4,6),3), 
  (13,(1,2)(3,5)(4,6),8), (13,(1,2)(3,5)(4,6),9), (13,(1,3)(2,4)(5,6),1), 
  (13,(1,3)(2,4)(5,6),3), (13,(1,3)(2,4)(5,6),8), (13,(1,3)(2,4)(5,6),9), 
  (13,(1,4,5)(2,3,6),1), (13,(1,4,5)(2,3,6),3), (13,(1,4,5)(2,3,6),8), 
  (13,(1,4,5)(2,3,6),9), (13,(1,5,4)(2,6,3),1), (13,(1,5,4)(2,6,3),3), 
  (13,(1,5,4)(2,6,3),8), (13,(1,5,4)(2,6,3),9), (13,(1,6)(2,5)(3,4),1), 
  (13,(1,6)(2,5)(3,4),3), (13,(1,6)(2,5)(3,4),8), (13,(1,6)(2,5)(3,4),9), 
  (21,(),1), (21,(),3), (21,(),8), (21,(),9), (21,(1,2)(3,5)(4,6),1), 
  (21,(1,2)(3,5)(4,6),3), (21,(1,2)(3,5)(4,6),8), (21,(1,2)(3,5)(4,6),9), 
  (21,(1,3)(2,4)(5,6),1), (21,(1,3)(2,4)(5,6),3), (21,(1,3)(2,4)(5,6),8), 
  (21,(1,3)(2,4)(5,6),9), (21,(1,4,5)(2,3,6),1), (21,(1,4,5)(2,3,6),3), 
  (21,(1,4,5)(2,3,6),8), (21,(1,4,5)(2,3,6),9), (21,(1,5,4)(2,6,3),1), 
  (21,(1,5,4)(2,6,3),3), (21,(1,5,4)(2,6,3),8), (21,(1,5,4)(2,6,3),9), 
  (21,(1,6)(2,5)(3,4),1), (21,(1,6)(2,5)(3,4),3), (21,(1,6)(2,5)(3,4),8), 
  (21,(1,6)(2,5)(3,4),9) ]
gap> IsReesZeroMatrixSemigroup(V);
true
gap> IsSimpleSemigroup(V);
false
gap> Length(GreensDClasses(V));
2

#
gap> U:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(R, [1,6,18,20],
> Group(()), [5,6,7,8,10]));
<subsemigroup of 25x10 Rees 0-matrix semigroup with 8 generators>
gap> Size(U);
121
gap> Rows(U);
[ 1, 6, 18, 20 ]
gap> Columns(U);
[ 5, 6, 7, 8, 10 ]
gap> IsReesZeroMatrixSemigroup(U);
true
gap> IsZeroSimpleSemigroup(U);
true
gap> UU:=Semigroup(GeneratorsOfSemigroup(U));
<subsemigroup of 25x10 Rees 0-matrix semigroup with 8 generators>
gap> Size(UU);
121
gap> Length(Enumerator(U));
121
gap> U=UU;
true
gap> Rows(UU);               
[ 1, 6, 18, 20 ]
gap> Columns(UU);
[ 5, 6, 7, 8, 10 ]
gap> UnderlyingSemigroup(UU);
Group([ (1,2)(3,5)(4,6), (1,3)(2,4)(5,6) ])
gap> UnderlyingSemigroup(U); 
Group([ (1,2)(3,5)(4,6), (1,3)(2,4)(5,6) ])
gap> UU:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(U, [1,18], Group(()), 
> [6,10]));;
gap> Size(UU);
13
gap> Length(Elements(UU));
13
gap> ForAll(UU, x-> x in UU);
true
gap> IsWholeFamily(UU);
false

#
gap> IsSubsemigroup(R, V);
true
gap> MultiplicativeZero(V);
0
gap> ForAll(V, x-> x in R);
true
gap> VV:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(V, [3,13], 
> Group(()), [1,3,9]));
<subsemigroup of 25x10 Rees 0-matrix semigroup with 4 generators>

#
gap> V:=Monoid(Random(R));
Error, Usage: Monoid(<gen>,...), Monoid(<gens>), Monoid(<D>),

#
gap> x:=Random(UnderlyingSemigroup(R));;
gap> f:=RMSElement(R, 24, x, 4);;
gap> RowOfReesZeroMatrixSemigroupElement(f);
24
gap> ColumnOfReesZeroMatrixSemigroupElement(f);
4
gap> f[1];
24
gap> f[3];
4
gap> f[2]=x;
true
gap> f[4];
Error, the second argument must be 1, 2, or 3

#
gap> gens:=[Transformation([3,3,2,6,2,4,4,6]),
> Transformation([5,1,7,8,7,5,8,1])];;
gap> s:=Semigroup(gens);
<transformation semigroup of degree 8 with 2 generators>
gap> IsSimpleSemigroup(s);
true
gap> IsomorphismReesMatrixSemigroup(s);;

#check that subsemigroup works even when all matrix entries are 0...
gap> i:=Position(Matrix(R)[7], 0);;
gap> Semigroup(GeneratorsOfReesZeroMatrixSemigroup(R, [i], Group(()), [1]));
<subsemigroup of 25x10 Rees 0-matrix semigroup with 1 generator>

#
gap> U:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(R, [1,3,4,5], 
> Group((1,3)), [1,9]));
Error, the third argument must be a subsemigroup of the underlying semigroup o\
f the first argument (a Rees 0-matrix semigroup)
gap> U:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(R, [1,3,4,5], Group(()),
> [1,9]));
<subsemigroup of 25x10 Rees 0-matrix semigroup with 5 generators>
gap> IsReesZeroMatrixSemigroup(U);
true
gap> UU:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(U, [1], Group(()), [6]));
Error, the fourth argument must be a non-empty subset of the columns of the fi\
rst argument (a Rees 0-matrix semigroup)
gap> UU:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(R, [1], Group(()),
> [9]), MultiplicativeZero(R));;
gap> V:=Range(IsomorphismTransformationSemigroup(UU));;
gap> IsReesZeroMatrixSemigroup(UU);
true
gap> UU;
<Rees 0-matrix semigroup 1x1 over Group(())>
gap> MultiplicativeZero(UU);
0
gap> Size(UU);
2
gap> Elements(UU);
[ 0, (1,(),9) ]
gap> Rows(UU);
[ 1 ]
gap> Columns(UU);
[ 9 ]
gap> RMSElement(UU, 1, (), 9);
(1,(),9)
gap> Set(Idempotents(UU));
[ 0, (1,(),9) ]
gap> IsReesMatrixSubsemigroup(UU);
false
gap> IsReesZeroMatrixSubsemigroup(UU);
true
gap> IsSimpleSemigroup(UU);
false
gap> IsReesZeroMatrixSemigroup(UU);
true
gap> Matrix(UU)=Matrix(R);
true
gap> Representative(UU);
(1,(),9)
gap> GeneratorsOfSemigroup(UU);
[ (1,(),9), 0 ]
gap> enum:=Enumerator(UU);;
gap> enum[1];
0
gap> enum[2];
(1,(),9)
gap> UnderlyingSemigroup(UU);
Group(())
gap> IsReesMatrixSemigroupElement(enum[1]);
false
gap> IsReesZeroMatrixSemigroupElement(enum[1]);
true
gap> enum[1]*enum[1];
0
gap> RMSElement(UU, 1, (), 9);
(1,(),9)
gap> RMSElement(UU, 1, (), 9) in UU;
true
gap> RMSElement(UU, 1, (), 9)^10 in UU;
true
gap> IsWholeFamily(UU);
false

# Rees 0-matrix semigroups where some of the rows or columns in the matrix
# consist entirely of 0s
gap> UU:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(R, [1], Group(()), 
> [1]));
<subsemigroup of 25x10 Rees 0-matrix semigroup with 1 generator>
gap> Elements(UU);
[ 0, (1,(),1) ]
gap> IsZeroSimpleSemigroup(UU);
false
gap> UU:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(R, [1], 
> Group((1,2)(3,5)(4,6)), [1]));;
gap> IsZeroSimpleSemigroup(UU);
false
gap> Length(GreensDClasses(UU));
3
gap> IsReesZeroMatrixSemigroup(UU);
true
gap> g:=Group((1,2,3));
Group([ (1,2,3) ])
gap> HasIsSimpleSemigroup(g);
true
gap> R;
<Rees 0-matrix semigroup 25x10 over Group([ (1,2)(3,5)(4,6), (1,3)(2,4)
(5,6) ])>
gap> mat:=[[0,0,0], [(1,2), 0, (3,4)]];
[ [ 0, 0, 0 ], [ (1,2), 0, (3,4) ] ]
gap> R:=ReesZeroMatrixSemigroup(SymmetricGroup(4), mat);                    
<Rees 0-matrix semigroup 3x2 over Sym( [ 1 .. 4 ] )>
gap> IsZeroSimpleSemigroup(R);
false
gap> Length(GreensDClasses(UU));
3
gap> Length(GreensDClasses(R)); 
28
gap> Size(R);
145

# check that IsomorphismReesMatrixSemigroup works for 0-simple subsemigroups of
# a Rees (0-)matrix semigroup
gap> mat:=[ [ 0, (), () ], [ (), 0, () ], [ (), (1,2), 0 ] ];;
gap> R:=ReesZeroMatrixSemigroup(Group((1,2)), mat);
<Rees 0-matrix semigroup 3x3 over Group([ (1,2) ])>
gap> S:=Semigroup(RMSElement(R, 1,(1,2),3), RMSElement(R, 3,(1,2),2), 
> RMSElement(R, 3,(1,2),2), RMSElement(R, 2,(1,2),2), 
> RMSElement(R, 1,(),2));
<subsemigroup of 3x3 Rees 0-matrix semigroup with 5 generators>
gap> Size(S);
13
gap> MultiplicativeZero(S);
0
gap> IsZeroSimpleSemigroup(S);
true
gap> Rows(S); Columns(S);
[ 1, 2, 3 ]
[ 2, 3 ]
gap> T:=Range(IsomorphismReesZeroMatrixSemigroup(S));;
gap> Rows(T); Columns(T);
[ 1 .. 3 ]
[ 1, 2 ]
gap> mat:=[ [ (), (), () ], [ (), (1,2), () ], [ (), (1,2), (1,2) ] ];;
gap> R:=ReesMatrixSemigroup(Group((1,2),(1,2,3)), mat);
<Rees matrix semigroup 3x3 over Group([ (1,2), (1,2,3) ])>
gap> S:=Semigroup(RMSElement(R, 2,(1,2,3),3), RMSElement(R, 3,(1,3,2),3), 
> RMSElement(R, 3,(1,2),2));;
gap> IsReesMatrixSemigroup(S);
true
gap> S;
<Rees matrix semigroup 2x2 over Group([ (2,3), (1,2) ])>
gap> Rows(S); Columns(S);
[ 2, 3 ]
[ 2, 3 ]
gap> T:=Range(IsomorphismReesMatrixSemigroup(S));;
gap> Rows(T); Columns(T);                                                      
[ 1, 2 ]
[ 1, 2 ]

# Rees matrix semigroups over groups
gap> mat:=
> [ [ (), (1,3,5,7)(2,4,6,8), (1,2,3,4,5,6,7,8), (), (1,2,3,4,5,6,7,8), 
>       (1,7,5,3)(2,8,6,4), (1,8,7,6,5,4,3,2), (1,2,3,4,5,6,7,8), 
>       (1,2,3,4,5,6,7,8) ], 
>   [ (1,5)(2,6)(3,7)(4,8), (1,2,3,4,5,6,7,8), (), (1,3,5,7)(2,4,6,8), 
>       (1,6,3,8,5,2,7,4), (1,6,3,8,5,2,7,4), (1,5)(2,6)(3,7)(4,8), (), 
>       (1,7,5,3)(2,8,6,4) ], 
>   [ (1,7,5,3)(2,8,6,4), (), (), (1,7,5,3)(2,8,6,4), (1,5)(2,6)(3,7)(4,8), 
>       (1,8,7,6,5,4,3,2), (1,4,7,2,5,8,3,6), (), (1,3,5,7)(2,4,6,8) ], 
>   [ (1,2,3,4,5,6,7,8), (), (1,2,3,4,5,6,7,8), (1,5)(2,6)(3,7)(4,8), 
>       (1,8,7,6,5,4,3,2), (1,7,5,3)(2,8,6,4), (1,2,3,4,5,6,7,8), 
>       (1,6,3,8,5,2,7,4), () ], 
>   [ (1,2,3,4,5,6,7,8), (1,6,3,8,5,2,7,4), (1,2,3,4,5,6,7,8), 
>       (1,4,7,2,5,8,3,6), (1,4,7,2,5,8,3,6), (1,8,7,6,5,4,3,2), 
>       (1,3,5,7)(2,4,6,8), (1,3,5,7)(2,4,6,8), (1,3,5,7)(2,4,6,8) ], 
>   [ (1,8,7,6,5,4,3,2), (1,5)(2,6)(3,7)(4,8), (1,8,7,6,5,4,3,2), 
>       (1,6,3,8,5,2,7,4), (1,3,5,7)(2,4,6,8), (), (), (1,4,7,2,5,8,3,6), 
>       (1,3,5,7)(2,4,6,8) ], 
>   [ (), (1,3,5,7)(2,4,6,8), (), (1,4,7,2,5,8,3,6), (1,6,3,8,5,2,7,4), 
>       (1,8,7,6,5,4,3,2), (1,7,5,3)(2,8,6,4), (1,5)(2,6)(3,7)(4,8), 
>       (1,4,7,2,5,8,3,6) ], 
>   [ (1,6,3,8,5,2,7,4), (1,2,3,4,5,6,7,8), (1,2,3,4,5,6,7,8), 
>       (1,7,5,3)(2,8,6,4), (1,3,5,7)(2,4,6,8), (1,3,5,7)(2,4,6,8), 
>       (1,8,7,6,5,4,3,2), (1,3,5,7)(2,4,6,8), (1,3,5,7)(2,4,6,8) ], 
>   [ (1,3,5,7)(2,4,6,8), (1,7,5,3)(2,8,6,4), (), (1,8,7,6,5,4,3,2), 
>       (1,8,7,6,5,4,3,2), (1,5)(2,6)(3,7)(4,8), (1,8,7,6,5,4,3,2), 
>       (1,7,5,3)(2,8,6,4), (1,4,7,2,5,8,3,6) ], 
>   [ (1,4,7,2,5,8,3,6), (1,3,5,7)(2,4,6,8), (1,4,7,2,5,8,3,6), 
>       (1,4,7,2,5,8,3,6), (1,5)(2,6)(3,7)(4,8), (1,8,7,6,5,4,3,2), 
>       (1,6,3,8,5,2,7,4), (1,8,7,6,5,4,3,2), (1,7,5,3)(2,8,6,4) ], 
>   [ (1,6,3,8,5,2,7,4), (1,6,3,8,5,2,7,4), (1,2,3,4,5,6,7,8), 
>       (1,3,5,7)(2,4,6,8), (1,4,7,2,5,8,3,6), (1,3,5,7)(2,4,6,8), 
>       (1,8,7,6,5,4,3,2), (1,4,7,2,5,8,3,6), (1,2,3,4,5,6,7,8) ] ];;
gap> R:=ReesMatrixSemigroup(DihedralGroup(IsPermGroup, 16), mat); 
<Rees matrix semigroup 9x11 over Group([ (1,2,3,4,5,6,7,8), (2,8)(3,7)
(4,6) ])>
gap> Size(R);
1584
gap> Representative(R);
(1,(),1)
gap> Representative(R) in R;
true
gap> RMSElement(R, 8, (), 11);
(8,(),11)
gap> RMSElement(R, 8, (), 11) in R;
true
gap> RMSElement(R, 8, (), 12) in R;
Error, the fourth argument (a positive integer) does not belong to the columns\
 of the first argument (a Rees (0-)matrix semigroup)
gap> U:=Semigroup(GeneratorsOfReesMatrixSemigroup(R, [5], Group(()), 
> [1,8,11]));
<subsemigroup of 9x11 Rees matrix semigroup with 3 generators>
gap> UnderlyingSemigroup(U)=UnderlyingSemigroup(ParentAttr(U));
false
gap> V:=Semigroup(RMSElement(R, 9,(1,6,3,8,5,2,7,4),4), 
> RMSElement(R, 6,(2,8)(3,7)(4,6),2), RMSElement(R, 2,(),11));
<subsemigroup of 9x11 Rees matrix semigroup with 3 generators>
gap> Size(V);
144
gap> Rows(V);
[ 2, 6, 9 ]
gap> IsSimpleSemigroup(V);
true
gap> IsZeroSimpleSemigroup(V);
false
gap> HasIsReesMatrixSemigroup(V);
true
gap> IsReesMatrixSemigroup(V);
true
gap> Elements(V);
[ (2,(),2), (2,(),4), (2,(),11), (2,(2,8)(3,7)(4,6),2), (2,(2,8)(3,7)(4,6),4),
  (2,(2,8)(3,7)(4,6),11), (2,(1,2)(3,8)(4,7)(5,6),2), 
  (2,(1,2)(3,8)(4,7)(5,6),4), (2,(1,2)(3,8)(4,7)(5,6),11), 
  (2,(1,2,3,4,5,6,7,8),2), (2,(1,2,3,4,5,6,7,8),4), (2,(1,2,3,4,5,6,7,8),11), 
  (2,(1,3)(4,8)(5,7),2), (2,(1,3)(4,8)(5,7),4), (2,(1,3)(4,8)(5,7),11), 
  (2,(1,3,5,7)(2,4,6,8),2), (2,(1,3,5,7)(2,4,6,8),4), 
  (2,(1,3,5,7)(2,4,6,8),11), (2,(1,4)(2,3)(5,8)(6,7),2), 
  (2,(1,4)(2,3)(5,8)(6,7),4), (2,(1,4)(2,3)(5,8)(6,7),11), 
  (2,(1,4,7,2,5,8,3,6),2), (2,(1,4,7,2,5,8,3,6),4), (2,(1,4,7,2,5,8,3,6),11), 
  (2,(1,5)(2,4)(6,8),2), (2,(1,5)(2,4)(6,8),4), (2,(1,5)(2,4)(6,8),11), 
  (2,(1,5)(2,6)(3,7)(4,8),2), (2,(1,5)(2,6)(3,7)(4,8),4), 
  (2,(1,5)(2,6)(3,7)(4,8),11), (2,(1,6)(2,5)(3,4)(7,8),2), 
  (2,(1,6)(2,5)(3,4)(7,8),4), (2,(1,6)(2,5)(3,4)(7,8),11), 
  (2,(1,6,3,8,5,2,7,4),2), (2,(1,6,3,8,5,2,7,4),4), (2,(1,6,3,8,5,2,7,4),11), 
  (2,(1,7)(2,6)(3,5),2), (2,(1,7)(2,6)(3,5),4), (2,(1,7)(2,6)(3,5),11), 
  (2,(1,7,5,3)(2,8,6,4),2), (2,(1,7,5,3)(2,8,6,4),4), 
  (2,(1,7,5,3)(2,8,6,4),11), (2,(1,8,7,6,5,4,3,2),2), (2,(1,8,7,6,5,4,3,2),4),
  (2,(1,8,7,6,5,4,3,2),11), (2,(1,8)(2,7)(3,6)(4,5),2), 
  (2,(1,8)(2,7)(3,6)(4,5),4), (2,(1,8)(2,7)(3,6)(4,5),11), (6,(),2), 
  (6,(),4), (6,(),11), (6,(2,8)(3,7)(4,6),2), (6,(2,8)(3,7)(4,6),4), 
  (6,(2,8)(3,7)(4,6),11), (6,(1,2)(3,8)(4,7)(5,6),2), 
  (6,(1,2)(3,8)(4,7)(5,6),4), (6,(1,2)(3,8)(4,7)(5,6),11), 
  (6,(1,2,3,4,5,6,7,8),2), (6,(1,2,3,4,5,6,7,8),4), (6,(1,2,3,4,5,6,7,8),11), 
  (6,(1,3)(4,8)(5,7),2), (6,(1,3)(4,8)(5,7),4), (6,(1,3)(4,8)(5,7),11), 
  (6,(1,3,5,7)(2,4,6,8),2), (6,(1,3,5,7)(2,4,6,8),4), 
  (6,(1,3,5,7)(2,4,6,8),11), (6,(1,4)(2,3)(5,8)(6,7),2), 
  (6,(1,4)(2,3)(5,8)(6,7),4), (6,(1,4)(2,3)(5,8)(6,7),11), 
  (6,(1,4,7,2,5,8,3,6),2), (6,(1,4,7,2,5,8,3,6),4), (6,(1,4,7,2,5,8,3,6),11), 
  (6,(1,5)(2,4)(6,8),2), (6,(1,5)(2,4)(6,8),4), (6,(1,5)(2,4)(6,8),11), 
  (6,(1,5)(2,6)(3,7)(4,8),2), (6,(1,5)(2,6)(3,7)(4,8),4), 
  (6,(1,5)(2,6)(3,7)(4,8),11), (6,(1,6)(2,5)(3,4)(7,8),2), 
  (6,(1,6)(2,5)(3,4)(7,8),4), (6,(1,6)(2,5)(3,4)(7,8),11), 
  (6,(1,6,3,8,5,2,7,4),2), (6,(1,6,3,8,5,2,7,4),4), (6,(1,6,3,8,5,2,7,4),11), 
  (6,(1,7)(2,6)(3,5),2), (6,(1,7)(2,6)(3,5),4), (6,(1,7)(2,6)(3,5),11), 
  (6,(1,7,5,3)(2,8,6,4),2), (6,(1,7,5,3)(2,8,6,4),4), 
  (6,(1,7,5,3)(2,8,6,4),11), (6,(1,8,7,6,5,4,3,2),2), (6,(1,8,7,6,5,4,3,2),4),
  (6,(1,8,7,6,5,4,3,2),11), (6,(1,8)(2,7)(3,6)(4,5),2), 
  (6,(1,8)(2,7)(3,6)(4,5),4), (6,(1,8)(2,7)(3,6)(4,5),11), (9,(),2), 
  (9,(),4), (9,(),11), (9,(2,8)(3,7)(4,6),2), (9,(2,8)(3,7)(4,6),4), 
  (9,(2,8)(3,7)(4,6),11), (9,(1,2)(3,8)(4,7)(5,6),2), 
  (9,(1,2)(3,8)(4,7)(5,6),4), (9,(1,2)(3,8)(4,7)(5,6),11), 
  (9,(1,2,3,4,5,6,7,8),2), (9,(1,2,3,4,5,6,7,8),4), (9,(1,2,3,4,5,6,7,8),11), 
  (9,(1,3)(4,8)(5,7),2), (9,(1,3)(4,8)(5,7),4), (9,(1,3)(4,8)(5,7),11), 
  (9,(1,3,5,7)(2,4,6,8),2), (9,(1,3,5,7)(2,4,6,8),4), 
  (9,(1,3,5,7)(2,4,6,8),11), (9,(1,4)(2,3)(5,8)(6,7),2), 
  (9,(1,4)(2,3)(5,8)(6,7),4), (9,(1,4)(2,3)(5,8)(6,7),11), 
  (9,(1,4,7,2,5,8,3,6),2), (9,(1,4,7,2,5,8,3,6),4), (9,(1,4,7,2,5,8,3,6),11), 
  (9,(1,5)(2,4)(6,8),2), (9,(1,5)(2,4)(6,8),4), (9,(1,5)(2,4)(6,8),11), 
  (9,(1,5)(2,6)(3,7)(4,8),2), (9,(1,5)(2,6)(3,7)(4,8),4), 
  (9,(1,5)(2,6)(3,7)(4,8),11), (9,(1,6)(2,5)(3,4)(7,8),2), 
  (9,(1,6)(2,5)(3,4)(7,8),4), (9,(1,6)(2,5)(3,4)(7,8),11), 
  (9,(1,6,3,8,5,2,7,4),2), (9,(1,6,3,8,5,2,7,4),4), (9,(1,6,3,8,5,2,7,4),11), 
  (9,(1,7)(2,6)(3,5),2), (9,(1,7)(2,6)(3,5),4), (9,(1,7)(2,6)(3,5),11), 
  (9,(1,7,5,3)(2,8,6,4),2), (9,(1,7,5,3)(2,8,6,4),4), 
  (9,(1,7,5,3)(2,8,6,4),11), (9,(1,8,7,6,5,4,3,2),2), (9,(1,8,7,6,5,4,3,2),4),
  (9,(1,8,7,6,5,4,3,2),11), (9,(1,8)(2,7)(3,6)(4,5),2), 
  (9,(1,8)(2,7)(3,6)(4,5),4), (9,(1,8)(2,7)(3,6)(4,5),11) ]
gap> Length(GreensDClasses(V));
1

#
gap> Size(U);
24
gap> Rows(U);
[ 5 ]
gap> Columns(U);
[ 1, 8, 11 ]
gap> IsReesMatrixSemigroup(U);
true
gap> IsZeroSimpleSemigroup(U);
false
gap> UU:=Semigroup(GeneratorsOfSemigroup(U));
<subsemigroup of 9x11 Rees matrix semigroup with 3 generators>
gap> Size(UU);
24
gap> Length(Enumerator(U));
24
gap> U=UU;
true
gap> Rows(UU);               
[ 5 ]
gap> Columns(UU);
[ 1, 8, 11 ]
gap> UnderlyingSemigroup(UU);
Group([ (1,2,3,4,5,6,7,8) ])
gap> UnderlyingSemigroup(U); 
Group([ (1,2,3,4,5,6,7,8) ])
gap> ForAll(UU, x-> x in UU);
true
gap> IsWholeFamily(UU);
false

# test that IsWholeFamily is working correctly, i.e. not with reference to
# ParentAttr.
gap> UUU:=Semigroup(GeneratorsOfReesMatrixSemigroup(U, Rows(U),
> UnderlyingSemigroup(U), Columns(U)));
<subsemigroup of 9x11 Rees matrix semigroup with 3 generators>
gap> IsWholeFamily(UU);
false

#
gap> IsSubsemigroup(R, V);
true
gap> ForAll(V, x-> x in R);
true
gap> VV:=Semigroup(GeneratorsOfReesMatrixSemigroup(V, [1,3], Group(()), 
> [1,8,9]));
Error, the second argument must be a non-empty subset of the rows of the first\
 argument (a Rees matrix semigroup)

#
gap> x:=Random(UnderlyingSemigroup(R));;
gap> f:=RMSElement(R, 4, x, 4);;
gap> RowOfReesMatrixSemigroupElement(f);
4
gap> ColumnOfReesMatrixSemigroupElement(f);
4
gap> f[1];
4
gap> f[3];
4
gap> f[2]=x;
true
gap> f[4];
Error, the second argument must equal 1, 2, or 3

# more general tests
gap> mat:=[ [ 0, 0, 0, (), (), (), () ], [ 0, (), (), 0, 0, (), () ], 
>  [ (), 0, (), 0, (), 0, () ], [ 0, (), (), (1,2), (1,2), 0, 0 ], 
>  [ (), 0, (), (1,2), 0, (1,2), 0 ], [ (), (1,2), 0, 0, (), (1,2), 0 ] ];;
gap> R:=ReesZeroMatrixSemigroup(Group((1,2)), mat);
<Rees 0-matrix semigroup 7x6 over Group([ (1,2) ])>
gap> Size(R);
85
gap> S:=Semigroup(GeneratorsOfSemigroup(R));
<subsemigroup of 7x6 Rees 0-matrix semigroup with 12 generators>
gap> Size(S);
85
gap> S=R;
true
gap> U:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(R, [1,2,4], Group(()), 
> [3..6]));
<subsemigroup of 7x6 Rees 0-matrix semigroup with 6 generators>
gap> V:=Semigroup(RMSElement(R, 7,(),4), RMSElement(R, 7,(),3), 
> RMSElement(R,2,(),1), RMSElement(R,4,(1,2),6), RMSElement(R,1,(1,2),6));
<subsemigroup of 7x6 Rees 0-matrix semigroup with 5 generators>
gap> UU:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(U, [2], Group(()), [5]));
<subsemigroup of 7x6 Rees 0-matrix semigroup with 1 generator>
gap> UU:=Semigroup(GeneratorsOfReesZeroMatrixSemigroup(U, [1,2], Group(()), 
> [5,6]));
<subsemigroup of 7x6 Rees 0-matrix semigroup with 3 generators>
gap> Size(UU);
9
gap> Matrix(UU)=Matrix(R);
true
gap> UUU:=Semigroup(MultiplicativeZero(UU), RMSElement(UU, 1,(),5), 
> RMSElement(UU, 2,(),6), RMSElement(UU, 2,(),6), RMSElement(UU, 2,(),5));
<subsemigroup of 7x6 Rees 0-matrix semigroup with 5 generators>
gap> ParentAttr(UUU)=R;
true
gap> VV:=Semigroup(RMSElement(V, 7,(),1), RMSElement(V, 1,(1,2),1), 
> RMSElement(V,1,(),4), RMSElement(V,2,(),3), RMSElement(V,1,(1,2),3) );
<subsemigroup of 7x6 Rees 0-matrix semigroup with 5 generators>
gap> Size(R)=85;
true
gap> Size(U);
25
gap> Size(UU);
9
gap> Size(UUU);
6
gap> UUU;
<subsemigroup of 7x6 Rees 0-matrix semigroup with 5 generators>
gap> Size(UUU);
6
gap> Elements(UUU);
[ 0, (1,(),5), (2,(),5), (2,(),6), (2,(1,2),5), (2,(1,2),6) ]
gap> Length(GreensDClasses(UUU));
4
gap> Size(V);
33
gap> Vt:=Range(IsomorphismTransformationSemigroup(V));;
gap> Length(GeneratorsOfSemigroup(Vt));
5
gap> DegreeOfTransformationSemigroup(Vt);
34
gap> Size(Vt);
33
gap> Representative(R) in R;
true
gap> Representative(S);
(1,(1,2),3)
gap> Representative(S) in S;
true
gap> Representative(U);
(1,(),3)
gap> Columns(U);
[ 3, 4, 5, 6 ]
gap> Representative(U) in U;
true
gap> Rows(U);
[ 1, 2, 4 ]
gap> RMSElement(R, 3, (), 5) in U;
false
gap> RMSElement(U, 3, (), 5) in U;
Error, the second argument (a positive integer) does not belong to the rows of\
 the first argument (a Rees (0-)matrix semigroup)
gap> RMSElement(V, 4, (), 3);
(4,(),3)
gap> Representative(UU);
(1,(),5)
gap> Representative(UU) in UU;
true
gap> UU;
<Rees 0-matrix semigroup 2x2 over Group([ (1,2) ])>
gap> Rows(UU); Columns(UU);
[ 1, 2 ]
[ 5, 6 ]
gap> Representative(UUU);
0
gap> Representative(UUU) in UU;
true
gap> Size(UUU);
6
gap> Size(UU);
9
gap> MultiplicativeZero(UUU);
0
gap> MultiplicativeZero(UU);
0
gap> Elements(UUU);
[ 0, (1,(),5), (2,(),5), (2,(),6), (2,(1,2),5), (2,(1,2),6) ]
gap> Elements(UU);
[ 0, (1,(),5), (1,(),6), (1,(1,2),5), (1,(1,2),6), (2,(),5), (2,(),6), 
  (2,(1,2),5), (2,(1,2),6) ]
gap> Elements(UUU)[2]*Elements(UUU)[4];
0
gap> Representative(V);
(7,(),4)
gap> V;
<subsemigroup of 7x6 Rees 0-matrix semigroup with 5 generators>
gap> IsReesMatrixSemigroup(V);
false
gap> Size(V);
33
gap> IsSimpleSemigroup(V);
false
gap> enum:=Enumerator(R);;
gap> ForAll(enum, x-> x in R);
true
gap> Length(enum);
85
gap> Size(R);
85
gap> ForAll(enum, x-> enum[Position(enum, x)]=x);
true
gap> ForAll([1..Length(enum)], i-> Position(enum, enum[i])=i);
true
gap> enum[1];;
gap> enum:=Enumerator(S);
<enumerator of <subsemigroup of 7x6 Rees 0-matrix semigroup with 12 generators
  >>
gap> enum[1];;
gap> enum:=Enumerator(U);;
gap> ForAll(enum, x-> x in U);
true
gap> Length(enum);
25
gap> Size(U);
25
gap> ForAll([1..Length(enum)], i-> Position(enum, enum[i])=i);
true
gap> ForAll(enum, x-> enum[Position(enum, x)]=x);
true
gap> enum:=Enumerator(UU);;
gap> ForAll(enum, x-> enum[Position(enum, x)]=x);
true
gap> ForAll([1..Length(enum)], i-> Position(enum, enum[i])=i);
true
gap> Size(UU);
9
gap> Length(enum);
9
gap> ForAll(enum, x-> x in UU);
true
gap> enum:=Enumerator(V);;
gap> Length(enum);
33
gap> Size(V);
33
gap> ForAll(enum, x-> x in V);
true
gap> ForAll([1..Length(enum)], i-> Position(enum, enum[i])=i);
true
gap> ForAll(enum, x-> enum[Position(enum, x)]=x);
true
gap> Size(U);
25
gap> Size(UU);
9
gap> Elements(UU);
[ 0, (1,(),5), (1,(),6), (1,(1,2),5), (1,(1,2),6), (2,(),5), (2,(),6), 
  (2,(1,2),5), (2,(1,2),6) ]
gap> RMSElement(UU, 1, (), 5);
(1,(),5)
gap> last=Elements(UU)[2];
true
gap> IsMultiplicativeZero(UU, last2);
false
gap> Elements(UU)*last3;
[ 0, (1,(),5), (1,(),5), (1,(1,2),5), (1,(1,2),5), (2,(),5), (2,(),5), 
  (2,(1,2),5), (2,(1,2),5) ]
gap> RMSElement(UU, 1, (1,2), 5);
(1,(1,2),5)
gap> RMSElement(UU, 10000, (), 5);
Error, the second argument (a positive integer) does not belong to the rows of\
 the first argument (a Rees (0-)matrix semigroup)
gap> RMSElement(UU, 1, (), 10);
Error, the fourth argument (a positive integer) does not belong to the columns\
 of the first argument (a Rees (0-)matrix semigroup)
gap> RMSElement(V, 1, (), 10);
Error, the arguments do not describe an element of the first argument (a Rees \
(0-)matrix semigroup)
gap> RMSElement(V, 1, (), 1);
(1,(),1)
gap> x:=RMSElement(V, 7, (), 4);; y:=RMSElement(V, x[1], x[2], x[3]);;
gap> x in V; y in V;
true
true
gap> RowOfReesZeroMatrixSemigroupElement(x)
> =RowOfReesZeroMatrixSemigroupElement(y);
true
gap> ColumnOfReesZeroMatrixSemigroupElement(x)
> =ColumnOfReesZeroMatrixSemigroupElement(y);
true
gap> UnderlyingElementOfReesZeroMatrixSemigroupElement(x)
> =UnderlyingElementOfReesZeroMatrixSemigroupElement(y);
true
gap> ForAll(R, x-> IsMultiplicativeZero(R, x) or x[2] in
> UnderlyingSemigroup(R));
true
gap> x;
(7,(),4)
gap> Zero(x);
0
gap> Zero(x) in V;
true
gap> Zero(x) in U;
true
gap> Zero(x) in S;
true
gap> Zero(x) in UU;
true
gap> Zero(x) in UUU;
true
gap> MultiplicativeZero(R); 
0
gap> MultiplicativeZero(U);
0
gap> MultiplicativeZero(S);
0
gap> MultiplicativeZero(UU);
0
gap> MultiplicativeZero(V);
0
gap> MultiplicativeZero(UUU);
0
gap> One(R);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `OneMutable' on 1 arguments
gap> One(U);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `OneMutable' on 1 arguments
gap> One(UU);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `OneMutable' on 1 arguments
gap> One(UUU);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `OneMutable' on 1 arguments
gap> One(S);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `OneMutable' on 1 arguments
gap> One(V);
Error, no method found! For debugging hints type ?Recovery from NoMethodFound
Error, no 1st choice method found for `OneMutable' on 1 arguments
gap> ParentAttr(R);
<Rees 0-matrix semigroup 7x6 over Group([ (1,2) ])>
gap> ParentAttr(U);
<Rees 0-matrix semigroup 7x6 over Group([ (1,2) ])>
gap> ParentAttr(UU);
<Rees 0-matrix semigroup 7x6 over Group([ (1,2) ])>
gap> ParentAttr(UUU);
<Rees 0-matrix semigroup 7x6 over Group([ (1,2) ])>
gap> U;
<Rees 0-matrix semigroup 3x4 over Group([ (1,2) ])>
gap> ParentAttr(V);
<Rees 0-matrix semigroup 7x6 over Group([ (1,2) ])>
gap> IsWholeFamily(R);
true
gap> IsWholeFamily(S);
true
gap> IsWholeFamily(U);
false
gap> IsWholeFamily(UU);
false
gap> IsWholeFamily(UUU);
false
gap> IsWholeFamily(V);
false
gap> IsReesZeroMatrixSemigroup(R);
true
gap> IsReesZeroMatrixSemigroup(U);
true
gap> IsReesZeroMatrixSemigroup(UU);
true
gap> IsReesZeroMatrixSemigroup(UUU);
false
gap> IsReesZeroMatrixSemigroup(V);
true
gap> IsReesZeroMatrixSemigroup(S);
true
gap> S;
<Rees 0-matrix semigroup 7x6 over Group([ (1,2) ])>
gap> Size(S);
85
gap> Size(R);
85
gap> IsomorphismReesZeroMatrixSemigroup(S);;
gap> V;
<Rees 0-matrix semigroup 4x4 over Group([ (1,2) ])>
gap> IsSimpleSemigroup(V);
false
gap> Length(GreensDClasses(V));
2
gap> Vt;
<transformation semigroup of size 33, degree 34 with 5 generators>
gap> VV:=AssociatedReesMatrixSemigroupOfDClass(
> First(GreensDClasses(Vt), x-> RankOfTransformation(Representative(x))=1));
<Rees matrix semigroup 1x1 over Group(())>
gap> Size(VV);
1
gap> Size(V);
33
gap> VV=V;
false
gap> V;
<Rees 0-matrix semigroup 4x4 over Group([ (1,2) ])>
gap> IsZeroSimpleSemigroup(V);
true
gap> IsomorphismReesZeroMatrixSemigroup(V);;

#over semigroups not groups!
gap> ReesZeroMatrixSemigroup(FullTransformationSemigroup(3), [[,0],[0,0]]);
Error, the second argument must be a non-empty list, whose entries are non-emp\
ty lists of equal length
gap> ReesZeroMatrixSemigroup(FullTransformationSemigroup(3), [[0],[0,0]]);
Error, the second argument must be a non-empty list, whose entries are non-emp\
ty lists of equal length
gap> mat:=List([1..3], x-> List([1..4], x->
> Random(FullTransformationSemigroup(4))));;
gap> ReesZeroMatrixSemigroup(FullTransformationSemigroup(3), mat);
Error, the entries of the second argument must be 0 or belong to the first arg\
ument (a semigroup)
gap> mat:=List([1..3], x-> List([1..4], x->
> Random(FullTransformationSemigroup(3))));;
gap> R:=ReesZeroMatrixSemigroup(FullTransformationSemigroup(3), mat);
<Rees 0-matrix semigroup 4x3 over <full transformation monoid of degree 3>>
gap> IsSimpleSemigroup(R);
false
gap> S:=Semigroup(Transformation([4,4,4,1,1,6,7,8,9,10,11,1]),
> Transformation([6,6,6,7,7,1,4,8,9,10,11,7]),
> Transformation([8,8,8,9,9,10,11,1,4,6,7,9]),
> Transformation([2,2,2,4,4,6,7,8,9,10,11,4]),
> Transformation([1,1,1,5,5,6,7,8,9,10,11,5]),
> Transformation([1,1,4,4,4,6,7,8,9,10,11,1]),
> Transformation([1,1,7,4,4,6,7,8,9,10,11,6]));;
gap> mat:=[ [ Transformation( [ 7, 7, 2, 6, 6, 4, 2, 8, 9, 11, 10, 4 ] ), 
>      Transformation( [ 4, 4, 4, 1, 1, 7, 6, 11, 10, 8, 9, 1 ] ), 
>      Transformation( [ 10, 10, 10, 11, 11, 9, 8, 1, 5, 7, 6, 11 ] ), 
>      Transformation( [ 9, 9, 11, 8, 8, 10, 11, 6, 7, 4, 2, 10 ] ) ], 
>  [ Transformation( [ 1, 1, 1, 4, 4, 6, 7, 9, 8, 10, 11, 4 ] ), 
>      Transformation( [ 10, 10, 8, 11, 11, 9, 8, 4, 2, 6, 7, 9 ] ), 
>      Transformation( [ 11, 11, 10, 10, 10, 9, 8, 4, 2, 7, 6, 11 ] ), 
>      Transformation( [ 7, 7, 6, 6, 6, 2, 4, 9, 8, 11, 10, 7 ] ) ], 
>  [ Transformation( [ 8, 8, 8, 9, 9, 11, 10, 6, 7, 5, 1, 9 ] ), 
>      Transformation( [ 9, 9, 9, 8, 8, 10, 11, 4, 2, 6, 7, 8 ] ), 
>      Transformation( [ 8, 8, 9, 9, 9, 11, 10, 6, 7, 2, 4, 8 ] ), 
>      Transformation( [ 4, 4, 4, 1, 1, 6, 7, 9, 8, 10, 11, 1 ] ) ] ];;
gap> R:=ReesMatrixSemigroup(S, mat);               
<Rees matrix semigroup 4x3 over <transformation semigroup of degree 12 with 7 
  generators>>
gap> IsSimpleSemigroup(R);
true
gap> IsWholeFamily(R);
true
gap> Size(R);
13824
gap> Rows(R);
[ 1 .. 4 ]
gap> Columns(R);
[ 1 .. 3 ]
gap> Representative(R);
(1,Transformation( [ 4, 4, 4, 1, 1, 6, 7, 8, 9, 10, 11, 1 ] ),1)
gap> HasGeneratorsOfSemigroup(R);
false
gap> Semigroup(GeneratorsOfReesMatrixSemigroup(R, [1,2],
> Semigroup(Transformation([4,4,4,1,1,6,7,8,9,10,11,1])), [2]));
<subsemigroup of 4x3 Rees matrix semigroup with 4 generators>
gap> IsSimpleSemigroup(last);
true
gap> Semigroup(GeneratorsOfReesMatrixSemigroup(R, [1],  
> Semigroup(Transformation([4,4,4,1,1,6,7,8,9,10,11,1])), [2]));
<subsemigroup of 4x3 Rees matrix semigroup with 2 generators>
gap> IsSimpleSemigroup(last);
true
gap> Elements(last2);
[ (1,Transformation( [ 1, 1, 1, 4, 4, 6, 7, 8, 9, 10, 11, 4 ] ),2), 
  (1,Transformation( [ 1, 1, 1, 4, 4, 6, 7, 9, 8, 10, 11, 4 ] ),2), 
  (1,Transformation( [ 4, 4, 4, 1, 1, 6, 7, 8, 9, 10, 11, 1 ] ),2), 
  (1,Transformation( [ 4, 4, 4, 1, 1, 6, 7, 9, 8, 10, 11, 1 ] ),2) ]
gap> S:=Semigroup(last);
<subsemigroup of 4x3 Rees matrix semigroup with 4 generators>
gap> Size(S);
4
gap> S=Semigroup(GeneratorsOfReesMatrixSemigroup(R, [1],  
> Semigroup(Transformation([4,4,4,1,1,6,7,8,9,10,11,1])), [2]));;
gap> S=Semigroup(GeneratorsOfReesMatrixSemigroup(R, [1],
> Semigroup(Transformation([4,4,4,1,1,6,7,8,9,10,11,1])), [2]));;
gap> S=Semigroup(GeneratorsOfReesMatrixSemigroup(R,
> [1], Semigroup(Transformation([4,4,4,1,1,6,7,8,9,10,11,1])), [2])); 
true
gap> IsWholeFamily(S);
false
gap> RMSElement(S, 1, Transformation([4,4,4,1,1,6,7,8,9,10,11,1]), 2);
(1,Transformation( [ 4, 4, 4, 1, 1, 6, 7, 8, 9, 10, 11, 1 ] ),2)
gap> last in S;
true
gap> last2 in R;
true
gap> MultiplicativeZero(S);
fail
gap> MultiplicativeZero(R);
fail

#
gap> R:=ReesMatrixSemigroup(Group((1,2), (1,2,3)), [[(), (1,2), (1,2,3), ()]]);
<Rees matrix semigroup 4x1 over Group([ (1,2), (1,2,3) ])>
gap> elts:=Elements(last);
[ (1,(),1), (1,(2,3),1), (1,(1,2),1), (1,(1,2,3),1), (1,(1,3,2),1), 
  (1,(1,3),1), (2,(),1), (2,(2,3),1), (2,(1,2),1), (2,(1,2,3),1), 
  (2,(1,3,2),1), (2,(1,3),1), (3,(),1), (3,(2,3),1), (3,(1,2),1), 
  (3,(1,2,3),1), (3,(1,3,2),1), (3,(1,3),1), (4,(),1), (4,(2,3),1), 
  (4,(1,2),1), (4,(1,2,3),1), (4,(1,3,2),1), (4,(1,3),1) ]
gap> x:=RMSElement(R, 3, (1,3,2), 1);
(3,(1,3,2),1)
gap> S:=Semigroup(x);
<subsemigroup of 4x1 Rees matrix semigroup with 1 generator>
gap> IsReesMatrixSemigroup(S);
false
gap> Elements(S);
[ (3,(1,3,2),1) ]
gap> y:=RMSElement(R, 4, (1,2), 1);
(4,(1,2),1)
gap> S:=Semigroup(x,y);
<subsemigroup of 4x1 Rees matrix semigroup with 2 generators>
gap> IsReesMatrixSemigroup(S);
false
gap> Elements(S);
[ (3,(1,3,2),1), (3,(1,3),1), (4,(),1), (4,(1,2),1) ]
gap> GeneratorsOfReesMatrixSemigroup(R, [3,4], Group((1,2), (1,2,3)), [1]);   
[ (3,(2,3),1), (3,(),1), (4,(),1) ]
gap> V:=Semigroup(last);
<subsemigroup of 4x1 Rees matrix semigroup with 3 generators>
gap> IsReesMatrixSemigroup(V);
true
gap> Size(V);
12
gap> Elements(V);
[ (3,(),1), (3,(2,3),1), (3,(1,2),1), (3,(1,2,3),1), (3,(1,3,2),1), 
  (3,(1,3),1), (4,(),1), (4,(2,3),1), (4,(1,2),1), (4,(1,2,3),1), 
  (4,(1,3,2),1), (4,(1,3),1) ]

# IsomorphismReesMatrixSemigroup for a RZMS or RMS, which is not 0-simple/simple
gap> R:=ReesZeroMatrixSemigroup(Group(()),                     
> [ [ (), (), () ], [ (), 0, 0 ], [ (), 0, 0 ] ]);;
gap> R:=ReesZeroMatrixSubsemigroup(R, [2,3], Group(()), [2,3]);  
<Rees 0-matrix semigroup 2x2 over Group(())>
gap> IsZeroSimpleSemigroup(R);
false
gap> IsomorphismReesZeroMatrixSemigroup(R);
MappingByFunction( <Rees 0-matrix semigroup 2x2 over Group(())>, 
<Rees 0-matrix semigroup 2x2 over Group(())>
 , function( u ) ... end, function( v ) ... end )
gap> Matrix(R);
[ [ (), (), () ], [ (), 0, 0 ], [ (), 0, 0 ] ]
gap> Matrix(Range(last2));
[ [ 0, 0 ], [ 0, 0 ] ]

#
gap> R:=ReesMatrixSemigroup(Group(()),                     
> [ [ (), (), () ], [ (), (), () ], [ (), (), () ] ]);;
gap> IsomorphismReesMatrixSemigroup(R);
MappingByFunction( <Rees matrix semigroup 3x3 over Group(())>, 
<Rees matrix semigroup 3x3 over Group(())>
 , function( object ) ... end, function( object ) ... end )
gap> R:=ReesMatrixSubsemigroup(R, [1,3], Group(()), [2,3]);
<Rees matrix semigroup 2x2 over Group(())>
gap> f:=IsomorphismReesMatrixSemigroup(R);
MappingByFunction( <Rees matrix semigroup 2x2 over Group(())>, 
<Rees matrix semigroup 2x2 over Group(())>
 , function( u ) ... end, function( v ) ... end )
gap> ForAll(R, x-> ForAll(R, y-> x^f*y^f=(x*y)^f));
true
gap> g:=InverseGeneralMapping(f);;
gap> ForAll(R, x-> (x^f)^g=x);
true
gap> U:=Semigroup(Transformation([1,1]));;
gap> R:=ReesMatrixSemigroup(U, List([1..3], x-> List([1..3], x-> Random(U))));;
gap> R:=ReesMatrixSubsemigroup(R, [1,3], U, [2,3]);;
gap> IsZeroSimpleSemigroup(R);
false
gap> f:=IsomorphismReesMatrixSemigroup(R);;
gap> g:=InverseGeneralMapping(f);;
gap> ForAll(R, x-> (x^f)^g=x);
true
gap> ForAll(R, x-> ForAll(R, y-> x^f*y^f=(x*y)^f));
true

#
gap> R := ReesZeroMatrixSemigroup( Group(
> [ ( 1, 2)( 3, 5)( 4, 6)( 7, 8)( 9,11)(10,12)(13,19)(14,20)(15,21)(16,22)(17,23)
>     (18,24), ( 1, 3)( 2, 4)( 5, 6)( 7,13)( 8,14)( 9,15)(10,16)(11,17)(12,18)(19,20)
>     (21,23)(22,24), ( 1, 7)( 2, 8)( 3, 9)( 4,10)( 5,11)( 6,12)(13,15)(14,16)(17,18)
>     (19,21)(20,22)(23,24) ] ), [ [ 0, 0, 0, 0, 0, 0, (), (), (), () ],
>   [ 0, 0, 0, (), (), (), 0, 0, 0, () ],
>   [ 0, (), (), 0, 0, (), 0, 0, ( 1, 2)( 3, 5)( 4, 6)( 7, 8)( 9,11)(10,12)(13,19)
>         (14,20)(15,21)(16,22)(17,23)(18,24), 0 ],
>   [ (), 0, (), 0, ( 1, 3)( 2, 4)( 5, 6)( 7,13)( 8,14)( 9,15)(10,16)(11,17)(12,18)
>         (19,20)(21,23)(22,24), 0, 0, ( 1, 4, 5)( 2, 3, 6)( 7,14,19)( 8,13,20)
>         ( 9,17,21)(10,18,22)(11,15,23)(12,16,24), 0, 0 ],
>   [ (), ( 1, 7)( 2, 8)( 3, 9)( 4,10)( 5,11)( 6,12)(13,15)(14,16)(17,18)(19,21)(20,22)
>         (23,24), 0, ( 1, 9,13)( 2,10,14)( 3, 7,15)( 4, 8,16)( 5,12,17)( 6,11,18)
>         (19,22,23)(20,21,24), 0, 0, ( 1,10,17,19)( 2, 9,18,20)( 3,12,14,21)
>         ( 4,11,13,22)( 5, 7,16,23)( 6, 8,15,24), 0, 0, 0 ] ] );;
gap> HasIsFinite(R);
true
gap> IsFinite(R);
true
gap> S := Semigroup(GeneratorsOfSemigroup(R)[1],
> GeneratorsOfSemigroup(R)[2]);
<subsemigroup of 10x5 Rees 0-matrix semigroup with 2 generators>
gap> HasIsFinite(R);
true
gap> HasIsFinite(S);
true
gap> IsFinite(S);
true

# Test bug in IsFinite for RMS or RZMS created over a free group
gap> S := FreeGroup(1);;
gap> R := ReesMatrixSemigroup(S, [[S.1]]);;
gap> IsFinite(R);
false
gap> R := ReesZeroMatrixSemigroup(S, [[S.1]]);;
gap> IsFinite(R);
false

# Test bug in creation of RZMS over a free semigroup
gap> S := FreeSemigroup(1);;
gap> R := ReesZeroMatrixSemigroup(S, [[S.1]]);;

# Test IsomorphismReesZeroMatrixSemigroup 
gap> BruteForceIsoCheck := function(iso)
>   local x, y;
>   if not IsInjective(iso) or not IsSurjective(iso) then
>     return false;
>   fi;
>   for x in GeneratorsOfSemigroup(Source(iso)) do
>     for y in GeneratorsOfSemigroup(Source(iso)) do
>       if x ^ iso * y ^ iso <> (x * y) ^ iso then
>         return false;
>       fi;
>     od;
>   od;
>   return true;
> end;;
gap> BruteForceInverseCheck := function(map)
> local inv;
>   inv := InverseGeneralMapping(map);
>   return ForAll(Source(map), x -> x = (x ^ map) ^ inv)
>     and ForAll(Range(map), x -> x = (x ^ inv) ^ map);
> end;;
gap> S := Semigroup(Transformation([1, 2, 1, 4, 1, 2]),
>                   Transformation([1, 3, 1, 5, 1, 3]), 
>                   Transformation([1, 1, 2, 1, 4, 4]));;
gap> IsZeroSimpleSemigroup(S);
true
gap> map := IsomorphismReesZeroMatrixSemigroup(S);;
gap> BruteForceIsoCheck(map);
true
gap> BruteForceInverseCheck(map);
true

#
gap> STOP_TEST( "reesmat.tst", 1);

#############################################################################
##
#E
