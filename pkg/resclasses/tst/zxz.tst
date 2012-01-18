#############################################################################
##
#W  zxz.tst               GAP4 Package `ResClasses'               Stefan Kohl
##
##  This file contains automated tests of ResClasses' functionality for
##  computing with residue class unions of Z^2.
##
#############################################################################

gap> START_TEST( "zxz.tst" );
gap> ResClassesDoThingsToBeDoneBeforeTest();
gap> R := Integers^2;
( Integers^2 )
gap> Difference(R,R);
[  ]
gap> Union(R,R);
( Integers^2 )
gap> Intersection(R,R);
( Integers^2 )
gap> Difference(R,[]);
( Integers^2 )
gap> Difference(R,[[0,0]]);
Z^2 \ [ [ 0, 0 ] ]
gap> Union(last,[[1,-1]]);
Z^2 \ [ [ 0, 0 ] ]
gap> Union(last,[[0,0]]);
( Integers^2 )
gap> R+[1,0];
( Integers^2 )
gap> Difference(R,[[0,0],[1,1]]);
Z^2 \ [ [ 0, 0 ], [ 1, 1 ] ]
gap> Difference(last,[[0,0],[1,1]]);
Z^2 \ [ [ 0, 0 ], [ 1, 1 ] ]
gap> Difference(last,[[5,-5],[4,9]]);
Z^2 \ <set of cardinality 4>
gap> Difference(last,R);
[  ]
gap> empty := Intersection(R,[]);
[  ]
gap> empty = [];
true
gap> IsEmpty(empty);
true
gap> Length(empty);
0
gap> IsSubset(R,empty);
true
gap> IsSubset(empty,R);
false
gap> empty = [];
true
gap> []+[1,1];
[ 1, 1 ]
gap> 2*empty;
[  ]
gap> empty*[[2,0],[0,3]];
[  ]
gap> l := Intersection(R,[[1,0],[7,-3]]);;
gap> l = [ [ 1, 0 ], [ 7, -3 ] ];
true
gap> IsSubset(R,l);
true
gap> IsSubset(l,R);
false
gap> IsSubset(empty,l);
false
gap> IsSubset(l,empty);
true
gap> Length(l);
2
gap> l[2];
[ 7, -3 ]
gap> l+[1,1];
[ [ 2, 1 ], [ 8, -2 ] ]
gap> l*[[2,0],[0,3]];
[ [ 2, 0 ], [ 14, -9 ] ]
gap> AsList(l);
[ [ 1, 0 ], [ 7, -3 ] ]
gap> IsList(last);
true
gap> [7,-3] in l;
true
gap> [7,-3] in empty;
false
gap> ResidueClassUnionViewingFormat("long");;
gap> 2*R;
The residue class (0,0)+(2,0)Z+(0,2)Z of Z^2
gap> 3*last;
The residue class (0,0)+(6,0)Z+(0,6)Z of Z^2
gap> last/2;
The residue class (0,0)+(3,0)Z+(0,3)Z of Z^2
gap> 2*R+[1,-1];
The residue class (1,1)+(2,0)Z+(0,2)Z of Z^2
gap> last+[1,1];
The residue class (0,0)+(2,0)Z+(0,2)Z of Z^2
gap> 3*R-[3,4];
The residue class (0,2)+(3,0)Z+(0,3)Z of Z^2
gap> 2*last;
The residue class (0,4)+(6,0)Z+(0,6)Z of Z^2
gap> last+[0,2];
The residue class (0,0)+(6,0)Z+(0,6)Z of Z^2
gap> Union(last2,[[8,10]]);
(The residue class (0,4)+(6,0)Z+(0,6)Z of Z^2) U [ [ 8, 10 ] ]
gap> S := Difference(Union(2*R,[[2,0],[1,6]]),[[-4,6]]);
(The residue class (0,0)+(2,0)Z+(0,2)Z of Z^2) U [ [ 1, 6 ] ] \ [ [ -4, 6 ] ]
gap> 2*S;
(The residue class (0,0)+(4,0)Z+(0,4)Z of Z^2) U [ [ 2, 12 ] ] \ 
[ [ -8, 12 ] ]
gap> -S;
(The residue class (0,0)+(2,0)Z+(0,2)Z of Z^2) U [ [ -1, -6 ] ] \ 
[ [ 4, -6 ] ]
gap> Difference(S,[[1,6]]);
(The residue class (0,0)+(2,0)Z+(0,2)Z of Z^2) \ [ [ -4, 6 ] ]
gap> last/2;
Z^2 \ [ [ -2, 3 ] ]
gap> S := Union(3*R,2*R+[1,1]);
<union of 12 residue classes (mod (6,0)Z+(0,6)Z) of Z^2>
gap> Display(S);
Union of the residue classes (1,1)+(2,0)Z+(0,2)Z, (0,3)+(3,3)Z+(0,6)Z
 and (0,0)+(6,0)Z+(0,6)Z of Z^2
gap> cls := AsUnionOfFewClasses(S);
[ The residue class (1,1)+(2,0)Z+(0,2)Z of Z^2, 
  The residue class (0,3)+(3,3)Z+(0,6)Z of Z^2, 
  The residue class (0,0)+(6,0)Z+(0,6)Z of Z^2 ]
gap> List(cls,Density);
[ 1/4, 1/18, 1/36 ]
gap> Union(cls) = S;
true
gap> I := Intersection(3*R,2*R+[1,1]);
The residue class (3,3)+(6,0)Z+(0,6)Z of Z^2
gap> Density(I);
1/36
gap> S1 := Difference(3*R,2*R+[1,1]);
<union of 3 residue classes (mod (6,0)Z+(0,6)Z) of Z^2>
gap> S2 := Difference(2*R+[1,1],3*R);
<union of 8 residue classes (mod (6,0)Z+(0,6)Z) of Z^2>
gap> S = Union(S1,S2,I);
true
gap> Union(S,[[4,0]]);
<union of 12 residue classes (mod (6,0)Z+(0,6)Z) of Z^2> U [ [ 4, 0 ] ]
gap> Difference(S,[[0,0]]);
<union of 12 residue classes (mod (6,0)Z+(0,6)Z) of Z^2> \ [ [ 0, 0 ] ]
gap> Display(last2);
(Union of the residue classes (1,1)+(2,0)Z+(0,2)Z, (0,3)+(3,3)Z+(0,6)Z
 and (0,0)+(6,0)Z+(0,6)Z of Z^2) U [ [ 4, 0 ] ]
gap> Display(last);
(Union of the residue classes (1,1)+(2,0)Z+(0,2)Z, (0,3)+(3,3)Z+(0,6)Z
 and (0,0)+(6,0)Z+(0,6)Z of Z^2) \ [ [ 0, 0 ] ]
gap> Difference(Union(S,[[4,0]]),[[0,0]]);
<union of 12 residue classes (mod (6,0)Z+(0,6)Z) of Z^2> U [ [ 4, 0 ] ] \ 
[ [ 0, 0 ] ]
gap> Display(last);
(Union of the residue classes (1,1)+(2,0)Z+(0,2)Z, (0,3)+(3,3)Z+(0,6)Z
 and (0,0)+(6,0)Z+(0,6)Z of Z^2) U [ [ 4, 0 ] ] \ [ [ 0, 0 ] ]
gap> S := 2*R;
The residue class (0,0)+(2,0)Z+(0,2)Z of Z^2
gap> Union(S,S+[1,0]);
The residue class (0,0)+(1,0)Z+(0,2)Z of Z^2
gap> Union(S,S+[1,0],S+[0,1]);
Z^2 \ The residue class (1,1)+(2,0)Z+(0,2)Z of Z^2
gap> Union(S,S+[1,0],S+[0,1],S+[1,1]);
( Integers^2 )
gap> ResidueClassUnionViewingFormat("short");;
gap> 2*R;
(0,0)+(2,0)Z+(0,2)Z
gap> 3*last;
(0,0)+(6,0)Z+(0,6)Z
gap> S := Difference(Union(2*R,[[2,0],[1,3],[1,6]]),[[2,2],[-4,6]]);
(0,0)+(2,0)Z+(0,2)Z U [ [ 1, 3 ], [ 1, 6 ] ] \ [ [ -4, 6 ], [ 2, 2 ] ]
gap> Modulus(S);
[ [ 2, 0 ], [ 0, 2 ] ]
gap> Residues(S);
[ [ 0, 0 ] ]
gap> IncludedElements(S);
[ [ 1, 3 ], [ 1, 6 ] ]
gap> ExcludedElements(S);
[ [ -4, 6 ], [ 2, 2 ] ]
gap> Density(S);
1/4
gap> Density(R);
1
gap> Density(7*R);
1/49
gap> S = Union(S,S);
true
gap> 2*S;
(0,0)+(4,0)Z+(0,4)Z U [ [ 2, 6 ], [ 2, 12 ] ] \ [ [ -8, 12 ], [ 4, 4 ] ]
gap> -S;
(0,0)+(2,0)Z+(0,2)Z U [ [ -1, -6 ], [ -1, -3 ] ] \ [ [ -2, -2 ], [ 4, -6 ] ]
gap> Difference(S,R);
[  ]
gap> Difference(S,2*R);
[ [ 1, 3 ], [ 1, 6 ] ]
gap> ResidueClass(R,[[1,0],[0,1]],[7,8]);
( Integers^2 )
gap> ResidueClass(R,[[2,0],[0,2]],[7,8]);
(1,0)+(2,0)Z+(0,2)Z
gap> ResidueClass(R,[[2,0],[0,2]],[1,0]);
(1,0)+(2,0)Z+(0,2)Z
gap> last=last2;
true
gap> ResidueClass(R,[[2,0],[0,3]],[1,0]);
(1,0)+(2,0)Z+(0,3)Z
gap> ResidueClass(R,[[2,0],[0,3]],[1,2]);
(1,2)+(2,0)Z+(0,3)Z
gap> ResidueClass(R,[[2,1],[0,3]],[1,2]);
(1,2)+(2,1)Z+(0,3)Z
gap> L := [[2,1],[-1,2]];
[ [ 2, 1 ], [ -1, 2 ] ]
gap> ResidueClass(R,L,[0,0]);
(0,0)+(1,3)Z+(0,5)Z
gap> ResidueClass(R,L,[0,1]);
(0,1)+(1,3)Z+(0,5)Z
gap> ResidueClass(R,L,[1,0]);
(0,2)+(1,3)Z+(0,5)Z
gap> ResidueClass(R,L,[1,2]);
(0,4)+(1,3)Z+(0,5)Z
gap> ResidueClass(R,L,[3,2]);
(0,3)+(1,3)Z+(0,5)Z
gap> Intersection(ResidueClass(R,L,[0,0]),ResidueClass(R,L,[0,1]));
[  ]
gap> S := Union(ResidueClass(R,L,[0,0]),ResidueClass(R,L,[0,1]));
(0,0)+(1,3)Z+(0,5)Z U (0,1)+(1,3)Z+(0,5)Z
gap> S = ResidueClassUnion(R,L,[[0,0],[0,1]]);
true
gap> S*[[1,1],[0,1]];
(0,0)+(1,4)Z+(0,5)Z U (0,1)+(1,4)Z+(0,5)Z
gap> Difference(Union(S,[[2,3]]),[[2,2]])*[[1,1],[0,1]];
(0,0)+(1,4)Z+(0,5)Z U (0,1)+(1,4)Z+(0,5)Z U [ [ 2, 5 ] ] \ [ [ 2, 4 ] ]
gap> 5*S;
(0,0)+(5,15)Z+(0,25)Z U (0,5)+(5,15)Z+(0,25)Z
gap> Union(last,[[7,7]]);
(0,0)+(5,15)Z+(0,25)Z U (0,5)+(5,15)Z+(0,25)Z U [ [ 7, 7 ] ]
gap> Difference(last,[[0,0]]);
(0,0)+(5,15)Z+(0,25)Z U (0,5)+(5,15)Z+(0,25)Z U [ [ 7, 7 ] ] \ [ [ 0, 0 ] ]
gap> last = ResidueClassUnion(R,5*L,[[0,0],[0,5]],[[7,7]],[[0,0]]);
true
gap> [0,0] in S;
true
gap> [0,1] in S;
true
gap> [0,2] in S;
false
gap> Intersection(S,Cartesian([0..9],[0..9]));
[ [ 0, 0 ], [ 0, 1 ], [ 0, 5 ], [ 0, 6 ], [ 1, 3 ], [ 1, 4 ], [ 1, 8 ], 
  [ 1, 9 ], [ 2, 1 ], [ 2, 2 ], [ 2, 6 ], [ 2, 7 ], [ 3, 0 ], [ 3, 4 ], 
  [ 3, 5 ], [ 3, 9 ], [ 4, 2 ], [ 4, 3 ], [ 4, 7 ], [ 4, 8 ], [ 5, 0 ], 
  [ 5, 1 ], [ 5, 5 ], [ 5, 6 ], [ 6, 3 ], [ 6, 4 ], [ 6, 8 ], [ 6, 9 ], 
  [ 7, 1 ], [ 7, 2 ], [ 7, 6 ], [ 7, 7 ], [ 8, 0 ], [ 8, 4 ], [ 8, 5 ], 
  [ 8, 9 ], [ 9, 2 ], [ 9, 3 ], [ 9, 7 ], [ 9, 8 ] ]
gap> last = Intersection(Cartesian([0..9],[0..9]),S);
true
gap> Collected(List(last2,l->l mod HermiteNormalFormIntegerMat(L)));
[ [ [ 0, 0 ], 20 ], [ [ 0, 1 ], 20 ] ]
gap> AllResidueClassesModulo(R,L);
[ (0,0)+(1,3)Z+(0,5)Z, (0,1)+(1,3)Z+(0,5)Z, (0,2)+(1,3)Z+(0,5)Z, 
  (0,3)+(1,3)Z+(0,5)Z, (0,4)+(1,3)Z+(0,5)Z ]
gap> List(last,Representative);
[ [ 0, 0 ], [ 0, 1 ], [ 0, 2 ], [ 0, 3 ], [ 0, 4 ] ]
gap> Union(last2);
( Integers^2 )
gap> L := [[6,2],[0,6]];
[ [ 6, 2 ], [ 0, 6 ] ]
gap> cls := AllResidueClassesModulo(R,L);
[ (0,0)+(6,2)Z+(0,6)Z, (0,1)+(6,2)Z+(0,6)Z, (0,2)+(6,2)Z+(0,6)Z, 
  (0,3)+(6,2)Z+(0,6)Z, (0,4)+(6,2)Z+(0,6)Z, (0,5)+(6,2)Z+(0,6)Z, 
  (1,0)+(6,2)Z+(0,6)Z, (1,1)+(6,2)Z+(0,6)Z, (1,2)+(6,2)Z+(0,6)Z, 
  (1,3)+(6,2)Z+(0,6)Z, (1,4)+(6,2)Z+(0,6)Z, (1,5)+(6,2)Z+(0,6)Z, 
  (2,0)+(6,2)Z+(0,6)Z, (2,1)+(6,2)Z+(0,6)Z, (2,2)+(6,2)Z+(0,6)Z, 
  (2,3)+(6,2)Z+(0,6)Z, (2,4)+(6,2)Z+(0,6)Z, (2,5)+(6,2)Z+(0,6)Z, 
  (3,0)+(6,2)Z+(0,6)Z, (3,1)+(6,2)Z+(0,6)Z, (3,2)+(6,2)Z+(0,6)Z, 
  (3,3)+(6,2)Z+(0,6)Z, (3,4)+(6,2)Z+(0,6)Z, (3,5)+(6,2)Z+(0,6)Z, 
  (4,0)+(6,2)Z+(0,6)Z, (4,1)+(6,2)Z+(0,6)Z, (4,2)+(6,2)Z+(0,6)Z, 
  (4,3)+(6,2)Z+(0,6)Z, (4,4)+(6,2)Z+(0,6)Z, (4,5)+(6,2)Z+(0,6)Z, 
  (5,0)+(6,2)Z+(0,6)Z, (5,1)+(6,2)Z+(0,6)Z, (5,2)+(6,2)Z+(0,6)Z, 
  (5,3)+(6,2)Z+(0,6)Z, (5,4)+(6,2)Z+(0,6)Z, (5,5)+(6,2)Z+(0,6)Z ]
gap> SplittedClass(R,[1,2]);
[ (0,0)+(1,0)Z+(0,2)Z, (0,1)+(1,0)Z+(0,2)Z ]
gap> SplittedClass(R,[2,1]);
[ (0,0)+(2,0)Z+(0,1)Z, (1,0)+(2,0)Z+(0,1)Z ]
gap> SplittedClass(R,[2,2]);
[ (0,0)+(2,0)Z+(0,2)Z, (0,1)+(2,0)Z+(0,2)Z, (1,0)+(2,0)Z+(0,2)Z, 
  (1,1)+(2,0)Z+(0,2)Z ]
gap> SplittedClass(R,[2,3]);
[ (0,0)+(2,0)Z+(0,3)Z, (0,1)+(2,0)Z+(0,3)Z, (0,2)+(2,0)Z+(0,3)Z, 
  (1,0)+(2,0)Z+(0,3)Z, (1,1)+(2,0)Z+(0,3)Z, (1,2)+(2,0)Z+(0,3)Z ]
gap> Union(last);
( Integers^2 )
gap> cl := last2[5];
(1,1)+(2,0)Z+(0,3)Z
gap> SplittedClass(cl,[1,1]);
[ (1,1)+(2,0)Z+(0,3)Z ]
gap> SplittedClass(cl,[1,2]);
[ (1,1)+(2,0)Z+(0,6)Z, (1,4)+(2,0)Z+(0,6)Z ]
gap> SplittedClass(cl,[2,1]);
[ (1,1)+(4,0)Z+(0,3)Z, (3,1)+(4,0)Z+(0,3)Z ]
gap> Union(last) = cl;
true
gap> SplittedClass(cl,[2,3]);
[ (1,1)+(4,0)Z+(0,9)Z, (1,4)+(4,0)Z+(0,9)Z, (1,7)+(4,0)Z+(0,9)Z, 
  (3,1)+(4,0)Z+(0,9)Z, (3,4)+(4,0)Z+(0,9)Z, (3,7)+(4,0)Z+(0,9)Z ]
gap> Union(last) = cl;
true
gap> ResClassesDoThingsToBeDoneAfterTest();
gap> STOP_TEST( "zxz.tst", 200000000 );

#############################################################################
##
#E  zxz.tst . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here