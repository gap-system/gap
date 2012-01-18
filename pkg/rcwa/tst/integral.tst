#############################################################################
##
#W  integral.tst               GAP4 Package `RCWA'                Stefan Kohl
##
##  This file contains automated tests of RCWA's functionality for
##  rcwa mappings of and rcwa groups over the ring of integers.
##
#############################################################################

gap> START_TEST( "integral.tst" );
gap> RCWADoThingsToBeDoneBeforeTest();
gap> IdentityRcwaMappingOfZ;
IdentityMapping( Integers )
gap> ZeroRcwaMappingOfZ;
ZeroMapping( Integers, Integers )
gap> Order(IdentityRcwaMappingOfZ);
1
gap> RcwaMapping(Integers,[[2,0,1]]);
Rcwa mapping of Z: n -> 2n
gap> RcwaMapping(Integers,1,[[2,0,1]]);
Rcwa mapping of Z: n -> 2n
gap> f := RcwaMapping((1,2,3)(8,9),[4..20]);
<bijective rcwa mapping of Z with modulus 17, of order 2>
gap> f * One(f) = f and One(f) * f = f;
true
gap> f * Zero(f) = Zero(f) and Zero(f) * f = Zero(f);
true
gap> Action(Group(f),[4..20]) = Group([(5,6)]);
true
gap> IsIdenticalObj(f!.coeffs,Coefficients(f));
true
gap> T := RcwaMapping([[1,0,2],[3,1,2]]);
<rcwa mapping of Z with modulus 2>
gap> Print(T,"\n");
RcwaMapping( [ [ 1, 0, 2 ], [ 3, 1, 2 ] ] )
gap> IsInjective(T);
false
gap> IsSurjective(T);
true
gap> Coefficients(T);
[ [ 1, 0, 2 ], [ 3, 1, 2 ] ]
gap> InjectiveAsMappingFrom(T);
0(2)
gap> Display(T^3);

Surjective rcwa mapping of Z with modulus 8

        /
        | n/8        if n in 0(8)
        | (9n+7)/8   if n in 1(8)
        | (3n+2)/8   if n in 2(8)
        | (9n+5)/8   if n in 3(8)
 n |-> <  (3n+4)/8   if n in 4(8)
        | (3n+1)/8   if n in 5(8)
        | (9n+10)/8  if n in 6(8)
        | (27n+19)/8 if n in 7(8)
        |
        \

gap> Length(Trajectory(RcwaMapping([[1,0,2],[5,-1,2]]),19,[1]));
307
gap> cl1 := ResidueClass(Integers,3,2);
2(3)
gap> Image(T,cl1);
1(3) U 8(9)
gap> PreImage(T,cl1);
Z \ 0(6) U 2(6)
gap> cl2 := ResidueClass(Integers,3,1);;
gap> M := Union(Difference(cl2,[1,4,10]),[2,5,14]);
1(3) U [ 2, 5, 14 ] \ [ 1, 4, 10 ]
gap> Display(Image(T,M));
2(3) U [ 1, 7 ] \ [ 2, 5 ]
gap> PreImage(T,M);
2(6) U [ 1, 3, 4, 9, 10, 28 ] \ [ 2, 8, 20 ]
gap> Display(last);
2(6) U [ 1, 3, 4, 9, 10, 28 ] \ [ 2, 8, 20 ]
gap> 2*RcwaMapping([[0,1,1]]);
Constant rcwa mapping of Z with value 2
gap> t := RcwaMapping([[-1,0,1]]);
Rcwa mapping of Z: n -> -n
gap> Order(t);
2
gap> LaTeXStringRcwaMapping(t);
"n \\ \\mapsto \\ -n"
gap> MovedPoints(t);
Z \ [ 0 ]
gap> k := RcwaMapping([[-4,-8,1]]);;
gap> IsBijective(k);
false
gap> Image(k);
0(4)
gap> cl3 := Difference(Integers,Union(cl1,cl2));;
gap> Image(k,cl3);
4(12)
gap> k := RcwaMapping([[-2,0,1]]);
Rcwa mapping of Z: n -> -2n
gap> Display(k);
Rcwa mapping of Z: n -> -2n
gap> IsInjective(k);
true
gap> IsSurjective(k);
false
gap> k := RcwaMapping([[-2,0,1],[1,0,1]]);;
gap> IsInjective(k);
true
gap> IsSurjective(k);
false
gap> k := RcwaMapping([[-2,0,1],[-1,1,1]]);;
gap> IsSurjective(k);
false
gap> IsInjective(k);
false
gap> k := RcwaMapping([[2,3,1]]);
Rcwa mapping of Z: n -> 2n + 3
gap> Display(k);
Rcwa mapping of Z: n -> 2n + 3
gap> k := RcwaMapping([[-2,3,1]]);
Rcwa mapping of Z: n -> -2n + 3
gap> Display(k);
Rcwa mapping of Z: n -> -2n + 3
gap> k := RcwaMapping([[-1,3,1]]);
Rcwa mapping of Z: n -> -n + 3
gap> k := RcwaMapping([[-1,-3,1]]);
Rcwa mapping of Z: n -> -n - 3
gap> k := RcwaMapping([[2,0,1],[0,3,1]]);
<rcwa mapping of Z with modulus 2>
gap> PreImage(k,[0,1,4,8,16]);
[ 0, 2, 4, 8 ]
gap> PreImage(k,[0,1,3,4,8,14]);
1(2) U [ 0, 2, 4 ]
gap> ZeroOne := RcwaMapping([[0,0,1],[0,1,1]]);;
gap> PreImagesElm(ZeroOne,6);
[  ]
gap> PreImagesElm(ZeroOne,1);
1(2)
gap> Image(ZeroOne);
[ 0, 1 ]
gap> e1 := RcwaMapping([[1,4,1],[2,0,1],[1,0,2],[2,0,1]]);;
gap> S := Difference(Integers,[1,2,3]);;
gap> im := Image(e1,S);
Z \ [ 1, 2, 6 ]
gap> pre := PreImage(e1,im);
Z \ [ 1, 2, 3 ]
gap> f5 := RcwaMapping([[7,0,5],[7,-2,5],[3,-1,5],[3,1,5],[7,2,5]]);;
gap> InjectiveAsMappingFrom(f5);
<union of 79 residue classes (mod 105)>
gap> last^f5 = Image(f5);
true
gap> perm := RcwaMapping([List([[0,4],[1,6],[2,12],[11,12],[3,6]],
>                              ResidueClass)]);
<bijective rcwa mapping of Z with modulus 12, of order 5>
gap> Factorization(perm);
[ ClassTransposition(1,6,3,6), ClassTransposition(2,12,11,12), 
  ClassTransposition(3,6,2,12), ClassTransposition(0,4,1,6) ]
gap> Cycle(perm,ResidueClass(0,4));
[ 0(4), 1(6), 2(12), 11(12), 3(6) ]
gap> u := RcwaMapping([[3,0,5],[9,1,5],[3,-1,5],[9,-2,5],[9,4,5]]);;
gap> IsBijective(u);
true
gap> Modulus(u);
5
gap> Display(u^-1);

Bijective rcwa mapping of Z with modulus 9

        /
        | 5n/3     if n in 0(3)
        | (5n+1)/3 if n in 1(3)
 n |-> <  (5n-1)/9 if n in 2(9)
        | (5n+2)/9 if n in 5(9)
        | (5n-4)/9 if n in 8(9)
        \

gap> Display(u^-1:table);

Bijective rcwa mapping of Z with modulus 9

                n mod 9                |             Image of n
---------------------------------------+--------------------------------------
  0 3 6                                | 5n/3
  1 4 7                                | (5n + 1)/3
  2                                    | (5n - 1)/9
  5                                    | (5n + 2)/9
  8                                    | (5n - 4)/9

gap> Modulus(T^u);
18
gap> PrimeSet(T^(u^-1));
[ 2, 3, 5 ]
gap> Order(u);
infinity
gap> 15^T; 
23
gap> PreImageElm(u,8);
4
gap> PreImagesElm(T,8);
[ 5, 16 ]
gap> PreImagesElm(ZeroRcwaMappingOfZ,0);
Integers
gap> d := RcwaMapping([[0,0,1],[0,1,1]]);;
gap> PreImagesRepresentative(d,1);
1
gap> ClassShift(0,1)^17 in Group(ClassShift(0,1));
true
gap> u in RCWA(Integers);
true
gap> t in RCWA(Integers);
true
gap> T in RCWA(Integers);
false
gap> if not IsBound(rc) then
>      rc := function(r,m) return ResidueClass(DefaultRing(m),m,r); end;
>    fi;
gap> a := RcwaMapping([[3,0,2],[3, 1,4],[3,0,2],[3,-1,4]]);;
gap> b := RcwaMapping([[3,0,2],[3,13,4],[3,0,2],[3,-1,4]]);;
gap> c := RcwaMapping([[3,0,2],[3, 1,4],[3,0,2],[3,11,4]]);;
gap> a = RcwaMapping([rc(0,2),rc(1,4),rc(3,4)],[rc(0,3),rc(1,3),rc(2,3)]);
true
gap> MovedPoints(a);
Z \ [ -1, 0, 1 ]
gap> cl := ResidueClass(Integers,3,1);
1(3)
gap> im := Image(a,cl);
1(9) U 5(9) U 6(9)
gap> PreImage(a,im);
1(3)
gap> pre := PreImage(a,cl);
1(4)
gap> PreImage(a,last);
6(8) U 1(16) U 7(16)
gap> Image(a,pre);
1(3)
gap> cl := ResidueClass(Integers,2,0);;
gap> Image(a,cl);
0(3)
gap> PreImage(a,cl);
0(4) U 3(8) U 5(8)
gap> Image(a,PreImage(a,cl)) = cl;
true
gap> PreImage(a,Image(a,cl)) = cl;
true
gap> cl := ResidueClass(Integers,5,3);;
gap> Image(a,PreImage(a,cl)) = cl;
true
gap> PreImage(a,Image(a,cl)) = cl;
true
gap> Trajectory(a,8,20,4) = Trajectory(a,8,20) mod 4;
true
gap> Trajectory(a,8,100,10);
[ 8, 2, 8, 7, 0, 0, 5, 4, 1, 8, 7, 3, 2, 8, 2, 8, 2, 3, 2, 3, 5, 4, 1, 3, 0, 
  5, 6, 9, 4, 6, 9, 7, 8, 2, 8, 2, 3, 0, 5, 9, 7, 0, 0, 5, 4, 6, 9, 4, 6, 4, 
  6, 9, 7, 5, 1, 1, 1, 3, 2, 3, 2, 3, 7, 3, 5, 4, 1, 8, 7, 0, 5, 1, 8, 2, 3, 
  5, 4, 1, 1, 6, 9, 9, 4, 1, 6, 4, 1, 8, 7, 5, 1, 3, 5, 4, 1, 6, 4, 6, 9, 2 ]
gap> ab := Comm(a,b);;
gap> ac := Comm(a,c);;
gap> bc := Comm(b,c);;
gap> Order(ab);
6
gap> Order(ac);
6
gap> Order(bc);
12
gap> Display(ab);

Bijective rcwa mapping of Z with modulus 18, of order 6

        /
        | n+3     if n in 4(9) U 7(9)
        | 2n-5    if n in 1(9)
        | 2n-4    if n in 5(9)
 n |-> <  (n+2)/2 if n in 6(18)
        | (n-5)/2 if n in 15(18)
        | n       if n in 0(9) U 2(9) U 3(9) U 8(9)
        |
        \

gap> Print(LaTeXStringRcwaMapping(ab));
n \ \mapsto \
\begin{cases}
  n       & \text{if} \ n \in 0(9) \cup 2(9) \cup 3(9) \cup 8(9), \\
  n+3     & \text{if} \ n \in 4(9) \cup 7(9), \\
  2n-5    & \text{if} \ n \in 1(9), \\
  2n-4    & \text{if} \ n \in 5(9), \\
  (n+2)/2 & \text{if} \ n \in 6(18), \\
  (n-5)/2 & \text{if} \ n \in 15(18).
\end{cases}
gap> Print(LaTeXStringRcwaMapping(a:Indentation:=2));
  n \ \mapsto \
  \begin{cases}
    3n/2     & \text{if} \ n \in 0(2), \\
    (3n+1)/4 & \text{if} \ n \in 1(4), \\
    (3n-1)/4 & \text{if} \ n \in 3(4).
  \end{cases}
gap> Print(LaTeXStringRcwaMapping(a:german));
n \ \mapsto \
\begin{cases}
  3n/2     & \text{falls} \ n \in 0(2), \\
  (3n+1)/4 & \text{falls} \ n \in 1(4), \\
  (3n-1)/4 & \text{falls} \ n \in 3(4).
\end{cases}
gap> OrbitsModulo(ab,9);
[ [ 0 ], [ 1, 4, 5, 6, 7 ], [ 2 ], [ 3 ], [ 8 ] ]
gap> G := Group(ab,ac);
<rcwa group over Z with 2 generators>
gap> Display(G);

Rcwa group over Z, generated by

[

Bijective rcwa mapping of Z with modulus 18, of order 6

        /
        | n+3     if n in 4(9) U 7(9)
        | 2n-5    if n in 1(9)
        | 2n-4    if n in 5(9)
 n |-> <  (n+2)/2 if n in 6(18)
        | (n-5)/2 if n in 15(18)
        | n       if n in 0(9) U 2(9) U 3(9) U 8(9)
        |
        \


Bijective rcwa mapping of Z with modulus 18, of order 6

        /
        | n+3     if n in 2(9) U 5(9)
        | 2n-5    if n in 4(9)
        | 2n-4    if n in 8(9)
 n |-> <  (n+1)/2 if n in 3(18)
        | (n-4)/2 if n in 12(18)
        | n       if n in 0(9) U 1(9) U 6(9) U 7(9)
        |
        \

]

gap> TrivialSubgroup(G);
Trivial rcwa group over Z
gap> orb := Orbit(G,1);
[ -15, -12, -7, -6, -5, -4, -3, -2, -1, 1 ]
gap> MovedPoints(G);
Z \ 0(9)
gap> OrbitsModulo(G,9);
[ [ 0 ], [ 1, 2, 3, 4, 5, 6, 7, 8 ] ]
gap> H := Action(G,orb);;
gap> H = Group([(1,2,3,4,6,8),(3,5,7,6,9,10)]);
true
gap> Size(H);
3628800
gap> Size(G);
3628800
gap> Modulus(G);
18
gap> Order(a);
infinity
gap> Comm(a,t);
IdentityMapping( Integers )
gap> x := ab*ac*ab^2*ac^3;
<bijective rcwa mapping of Z with modulus 18>
gap> x in G;
true
gap> u in G;
false
gap> ShortOrbits(G,[-20..20],100) =
>    [[-51,-48,-42,-39,-25,-23,-22,-20,-19,-17], [-18], 
>     [-33,-30,-24,-21,-16,-14,-13,-11,-10,-8], 
>     [-15,-12,-7,-6,-5,-4,-3,-2,-1,1], [-9], [0], 
>     [2,3,4,5,6,7,8,10,12,15], [9], 
>     [11,13,14,16,17,19,21,24,30,33], [18], 
>     [20,22,23,25,26,28,39,42,48,51]];
true
gap> IsPerfect(Group(a,b));
false
gap> g := RcwaMapping([[2,2,1],[1, 4,1],[1,0,2],[2,2,1],[1,-4,1],[1,-2,1]]);;
gap> h := RcwaMapping([[2,2,1],[1,-2,1],[1,0,2],[2,2,1],[1,-1,1],[1, 1,1]]);;
gap> Order(g);
7
gap> Order(h);
12
gap> Order(Comm(g,h));
infinity
gap> h in G;
false
gap> std := StandardConjugate(g);
<bijective rcwa mapping of Z with modulus 7, of order 7>
gap> tostd := StandardizingConjugator(g);
<bijective rcwa mapping of Z with modulus 12>
gap> g^tostd = std;
true
gap> std := StandardConjugate(ab);
<bijective rcwa mapping of Z with modulus 7, of order 6>
gap> tostd := StandardizingConjugator(ab);
<bijective rcwa mapping of Z with modulus 18>
gap> ab^tostd = std;
true
gap> r := g^ab;
<bijective rcwa mapping of Z with modulus 36, of order 7>
gap> HasStandardConjugate(r) and HasStandardizingConjugator(r);
true
gap> r^StandardizingConjugator(r)/StandardConjugate(r);
IdentityMapping( Integers )
gap> k := RcwaMapping([[1,1,1],[1, 4,1],[1,1,1],[2,-2,1],
>                      [1,0,2],[1,-5,1],[1,1,1],[2,-2,1]]);;
gap> std := StandardConjugate(k);
<bijective rcwa mapping of Z with modulus 3, of order 3>
gap> tostd := StandardizingConjugator(k);
<bijective rcwa mapping of Z with modulus 8>
gap> k^tostd = std;
true
gap> v := RcwaMapping([[-1,2,1],[1,-1,1],[1,-1,1]]);;
gap> w := RcwaMapping([[-1,3,1],[1,-1,1],[1,-1,1],[1,-1,1]]);;
gap> k := RcwaMapping([[-1,2,1],[1,-1,1],[1,-1,1],[1,1,1],[1,-1,1]]);;
gap> Image(k,ResidueClass(Integers,3,2));
1(15) U 9(15) U 10(15) U 12(15) U 13(15)
gap> PreImage(k,last);
2(3)
gap> PreImage(k,last);
0(15) U 6(15) U 9(15) U 12(15) U 13(15)
gap> PreImage(k,last);
1(15) U 5(15) U 7(15) U 8(15) U 14(15)
gap> Image(k,last);
0(15) U 6(15) U 9(15) U 12(15) U 13(15)
gap> cls := List([0..2],r->ResidueClass(Integers,3,r));
[ 0(3), 1(3), 2(3) ]
gap> Union(List(cls,cl->Image(k,cl)));
Integers
gap> cls := List([0..6],r->ResidueClass(Integers,7,r));;
gap> Union(List(cls,cl->Image(k,cl)));
Integers
gap> Union(List(cls,cl->Image(a,cl)));
Integers
gap> Union(List(cls,cl->Image(u,cl)));
Integers
gap> F := ResidueClassUnion(Integers,5,[1,2],[3,8],[-4,1]);;
gap> im := Image(a,Image(a,F));
<union of 18 residue classes (mod 45)> U [ 3, 18 ] \ [ -9, 1 ]
gap> pre := PreImage(a,PreImage(a,im));
1(5) U 2(5) U [ 3, 8 ] \ [ -4, 1 ]
gap> C7 := Group(g);; 
gap> orb := Orbit(C7,F);
[ 1(5) U 2(5) U [ 3, 8 ] \ [ -4, 1 ], 
  <union of 12 residue classes (mod 30)> U [ 4, 8 ] \ [ -2, 5 ], 
  <union of 24 residue classes (mod 60)> U [ 0, 4 ] \ [ -6, 3 ], 
  <union of 24 residue classes (mod 60)> U [ 0, 2 ] \ [ -10, 8 ], 
  <union of 24 residue classes (mod 60)> U [ 1, 2 ] \ [ -5, 4 ], 
  <union of 24 residue classes (mod 60)> U [ 1, 5 ] \ [ -1, 0 ], 
  <union of 12 residue classes (mod 30)> U [ 3, 5 ] \ [ -3, 2 ] ]
gap> Union(orb{[1,2]});
<union of 19 residue classes (mod 30)> U [ 3, 4, 8 ] \ [ -2, 5 ]
gap> Union(orb{[1,2,3]});
<union of 44 residue classes (mod 60)> U [ 0, 4, 8 ] \ [ -6 ]
gap> Union(orb{[1,2,3,4]});
<union of 25 residue classes (mod 30)> U [ 0, 4 ] \ [ -10 ]
gap> Union(orb{[1,2,3,4,5]});
<union of 28 residue classes (mod 30)> U [ 0 ] \ [ -5 ]
gap> Union(orb{[1,2,3,4,5,6]});
Z \ [ -1 ]
gap> Union(orb{[1,2,3,4,5,6,7]});
Integers
gap> z := RcwaMapping([[2,  1, 1],[1,  1,1],[2, -1,1],[2, -2,1],
>                      [1,  6, 2],[1,  1,1],[1, -6,2],[2,  5,1],
>                      [1,  6, 2],[1,  1,1],[1,  1,1],[2, -5,1],
>                      [1,  0, 1],[1, -4,1],[1,  0,1],[2,-10,1]]);;
gap> set := Image(a,PreImage(h,Image(z,F)));
<union of 576 residue classes (mod 1440)> U [ 12, 21 ] \ [ -2, 0 ]
gap> control := PreImage(z,Image(h,PreImage(a,set)));;
gap> control = F;
true
gap> nb := RcwaMapping([[3,2,2],[2,-2,3],[3,2,2],[1,0,1],[3,2,2],[1,0,1]]);;
gap> Difference(Integers,Image(nb));
2(12) U 6(12)
gap> pc := RcwaMapping([[3,2,2],[2,-2,3],[3,2,2],[1,0,1],[3,2,2],[0,2,1]]);;
gap> im := Image(pc);
1(3) U 3(6) U 0(12) U 8(12) U [ 2 ]
gap> PreImage(pc,Difference(im,[4]));
Z \ [ 2, 7 ]
gap> CompositionMapping(a,b) = b*a;
true
gap> CompositionMapping(g,h) = h*g;
true
gap> x := RcwaMapping([[ 16,  2,  1], [ 16, 18,  1],
>                      [  1, 16,  1], [ 16, 18,  1],
>                      [  1, 16,  1], [ 16, 18,  1],
>                      [  1, 16,  1], [ 16, 18,  1],
>                      [  1, 16,  1], [ 16, 18,  1],
>                      [  1, 16,  1], [ 16, 18,  1],
>                      [  1, 16,  1], [ 16, 18,  1],
>                      [  1, 16,  1], [ 16, 18,  1],
>                      [  1,  0, 16], [ 16, 18,  1],
>                      [  1,-14,  1], [ 16, 18,  1],
>                      [  1,-14,  1], [ 16, 18,  1],
>                      [  1,-14,  1], [ 16, 18,  1],
>                      [  1,-14,  1], [ 16, 18,  1],
>                      [  1,-14,  1], [ 16, 18,  1],
>                      [  1,-14,  1], [ 16, 18,  1],
>                      [  1,-14,  1], [  1,-31,  1]]);
<rcwa mapping of Z with modulus 32>
gap> Order(x);
257
gap> 1^x;
34
gap> Display(a + b);

Rcwa mapping of Z with modulus 4

        /
        | 3n       if n in 0(2)
 n |-> <  (3n+7)/2 if n in 1(4)
        | (3n-1)/2 if n in 3(4)
        \

gap> Display(a - b);

Rcwa mapping of Z with modulus 4

        /
        | 0  if n in 0(2) U 3(4)
 n |-> <  -3 if n in 1(4)
        |
        \

gap> TransitionGraph(a,4) 
>  = rec( isGraph := true, order := 4, group := Group(()), 
>         schreierVector := [ -1, -2, -3, -4 ], 
>         adjacencies := [ [ 1, 3 ], [ 1, 2, 3, 4 ],
>                          [ 2, 4 ], [ 1, 2, 3, 4 ] ], 
>         representatives := [ 1, 2, 3, 4 ],
>         names := [ 1, 2, 3, 4 ] );
true
gap> a*(bc*f) = (a*bc)*f;
true
gap> h*(a*b) = (h*a)*b;
true
gap> u*(ac^-1*g) = (u*ac^-1)*g;
true
gap> u*g*(u*g)^-1 = IdentityRcwaMappingOfZ;
true
gap> a*(b+c) = a*b + a*c;
true
gap> g*(a+u) = g*a + g*u;
true
gap> h*(b-t) = h*b - h*t;
true
gap> List([0..7],i->Modulus(g^i));
[ 1, 6, 12, 12, 12, 12, 6, 1 ]
gap> List([0..3],i->Modulus(u^i));
[ 1, 5, 25, 125 ]
gap> s := RcwaMapping([[1,0,1],[1,1,1],[3,  6,1],
>                      [1,0,3],[1,1,1],[3,  6,1],
>                      [1,0,1],[1,1,1],[3,-21,1]]);;
gap> List([0..9],i->Modulus(s^i));
[ 1, 9, 9, 27, 27, 27, 27, 27, 27, 1 ]
gap> G := Group(a*b,u^f,Comm(a,b));
<rcwa group over Z with 3 generators>
gap> PrimeSet(G);
[ 2, 3, 5, 17 ]
gap> g1 := RcwaMapping((1,2),[1..2]);
<bijective rcwa mapping of Z with modulus 2, of order 2>
gap> g2 := RcwaMapping((1,2,3),[1..3]);
<bijective rcwa mapping of Z with modulus 3, of order 3>
gap> g3 := RcwaMapping((1,2,3,4,5),[1..5]);
<bijective rcwa mapping of Z with modulus 5, of order 5>
gap> G := Group(g1,g2);
<rcwa group over Z with 2 generators>
gap> phi := IsomorphismPermGroup(G);
[ <bijective rcwa mapping of Z with modulus 2, of order 2>, 
  <bijective rcwa mapping of Z with modulus 3, of order 3> ] -> 
[ (1,6)(2,3)(4,5), (1,5,6)(2,3,4) ]
gap> IsBijective(phi);
true
gap> Size(Image(phi));
24
gap> IdGroup(G);
[ 24, 12 ]
gap> G;
<rcwa group over Z with 2 generators, of isomorphism type [ 24, 12 ]>
gap> Modulus(G);
6
gap> A4 := DerivedSubgroup(G);
<rcwa group over Z with 3 generators, of size 12>
gap> IsBijective(IsomorphismGroups(AlternatingGroup(4),A4));
true
gap> H := Image(IsomorphismRcwaGroup(Group((1,2),(3,4),(5,6),(7,8),
>                                          (1,3)(2,4),(1,3,5,7)(2,4,6,8)),
>                                    Integers));
<tame rcwa group over Z with 6 generators>
gap> Size(H);
384
gap> IsSolvable(H);
true
gap> List(DerivedSeries(H),Size);
[ 384, 96, 32, 2, 1 ]
gap> Modulus(H);
8
gap> IsTame(T);
false
gap> IsTame(ab);
true
gap> IsTame(G);
true
gap> IsTame(Group(ab,ac));
true
gap> nu := RcwaMapping([[1,1,1]]);
Rcwa mapping of Z: n -> n + 1
gap> IsTame(nu);
true
gap> IsTame(Group(nu));
true
gap> Size(Group(nu));
infinity
gap> tau := ClassTransposition(0,2,1,2);
ClassTransposition(0,2,1,2)
gap> x := RcwaMapping([[-1,2,1],[1,-1,1],[1,-1,1]]);
<rcwa mapping of Z with modulus 3>
gap> Order(x);
6
gap> List([-10..10],n->Length(Orbit(Group(x),n)));
[ 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 3, 3, 3, 6, 6, 6, 6, 6, 6, 6, 6 ]
gap> y := RcwaMapping([[-1,3,1],[1,-1,1],[1,-1,1],[1,-1,1]]);
<rcwa mapping of Z with modulus 4>
gap> Order(y);
8
gap> List([-10..10],n->Length(Orbit(Group(y),n)));
[ 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 4, 4, 4, 4, 8, 8, 8, 8, 8, 8, 8 ]
gap> Order(x*y);
24
gap> Order(Comm(x,y));
20
gap> IsIntegral(f);
true
gap> IsIntegral(u);
false
gap> IsIntegral(T);
false
gap> IsIntegral(nu);
true
gap> IsIntegral(nu^a);
false
gap> IsIntegral((nu^a)^2);
true
gap> IsIntegral(Group(a,b));
false
gap> IsIntegral(Group(g));
false
gap> IsIntegral(t);
true
gap> IsIntegral(RcwaMapping([[2,0,1]]));
true
gap> IsIntegral(RcwaMapping([[2,0,1],[3,5,1]]));
true
gap> IsIntegral(RcwaMapping([[1,0,2],[3,5,1]]));
false
gap> IsBalanced(t);
true
gap> IsBalanced(a);
false
gap> IsBalanced(nu*nu^a);
true
gap> IsBalanced(ab);
true
gap> IsClassWiseOrderPreserving(u);
true
gap> IsClassWiseOrderPreserving(T);
true
gap> IsClassWiseOrderPreserving(t);
false
gap> IsClassWiseOrderPreserving(nu);
true
gap> IsClassWiseOrderPreserving(nu^RcwaMapping([[-1,0,1],[1,0,1]]));
false
gap> IsClassWiseOrderPreserving(Group(a,b));
true
gap> IsClassWiseOrderPreserving(G);
true
gap> IsClassWiseOrderPreserving(Group(t,g,h));
false
gap> IsSignPreserving(ClassShift(0,2));            
false
gap> IsSignPreserving(ClassReflection(0,1));       
false
gap> IsSignPreserving(ClassShift(1,2));     
false
gap> IsSignPreserving(ClassTransposition(0,2,1,2));
true
gap> IsSignPreserving(Group(ClassTransposition(0,2,1,4),
>                           ClassTransposition(1,2,0,6)));                          
true
gap> IsSignPreserving(Group(ClassTransposition(0,2,1,4),ClassShift(7,8)));
false
gap> y := RcwaMapping([[28,   0, 9], [ 7, -16, 9], [28,   7, 9],
>                      [28,  42, 9], [ 7,   8, 9], [ 7, -17, 9],
>                      [ 7,  12,18], [ 7,  -4, 9], [28, -35, 9],
>                      [28,   0, 9], [ 7, -16, 9], [28,   7, 9],
>                      [28,  42, 9], [ 7,   8, 9], [ 7, -17, 9],
>                      [ 7, -87,18], [ 7,  -4, 9], [28, -35, 9]]);;
gap> ab^y = RcwaMapping((1,2,3,4,5,6),[1..7]);
true
gap> ShortOrbits(Group(u),[-30..30],100) = 
>    [[-13,-8,-7,-5,-4,-3,-2], [-10,-6], [-1], [0], [1,2], [3,5],
>     [24,36,39,40,44,48,60,65,67,71,80,86,93,100,112, 
>      128,138,155,167,187,230,248,312,446,520,803,867,1445]];
true
gap> ShortCycles(u,2);
[ [ 0 ], [ -1 ], [ 1, 2 ], [ 3, 5 ], [ -10, -6 ] ]
gap> ShortCycles(a,1);
[ [ 0 ], [ 1 ], [ -1 ] ]
gap> ShortCycles(a,2);
[ [ 0 ], [ 1 ], [ -1 ], [ 2, 3 ], [ -3, -2 ] ]
gap> DeterminantMat(TransitionMatrix(T,13));
-1/256
gap> TransitionMatrix(T^3,11) = TransitionMatrix(T,11)^3;
true
gap> Display(TransitionMatrix(a,7));
[ [  1/2,    0,  1/4,    0,    0,  1/4,    0 ],
  [    0,  1/4,    0,    0,  1/4,  1/2,    0 ],
  [  1/4,    0,    0,  3/4,    0,    0,    0 ],
  [    0,  1/2,  1/4,    0,    0,    0,  1/4 ],
  [    0,  1/4,    0,    0,    0,  1/4,  1/2 ],
  [  1/4,    0,    0,    0,  3/4,    0,    0 ],
  [    0,    0,  1/2,  1/4,    0,    0,  1/4 ] ]
gap> Display(TransitionMatrix(ab,20)*One(GF(7)));
 2 2 . 1 . . . . . . . 2 . . . 4 4 . . .
 . 2 . . 1 . . . 2 . . . . . . . . 4 6 .
 4 . 4 . . 1 . . . . . . 2 . . . . . . 4
 . 4 4 2 . . 1 . . 2 . . . . . . . . . 2
 . . . 6 6 . . 1 . . . . . 2 . . . . . .
 2 . . . . 6 4 . 1 . 2 . . . . . . . . .
 . . . . 2 . 2 4 4 1 . . . . 2 . . . . .
 . 2 . . . . . 2 . 4 5 2 . . . . . . . .
 . . . . . 2 . . 2 . . 5 4 . . 2 . . . .
 . . 2 . . . . . . 2 . . 3 4 4 . . . . .
 . . . . . . 2 . . . 2 . . 1 . 4 6 . . .
 . . . 2 . . . . . . . 2 . 2 1 . . 4 4 .
 4 . . . . . . 2 . . . . 2 . . 1 . 2 . 4
 . 4 4 . 2 . . . . . . . . 2 2 . 1 . . .
 . . . 4 4 . . . 2 . . . . . 2 . . 1 2 .
 . . . . . 6 4 . . . . . . . . 4 . . 1 .
 . . . . . . . 4 4 2 . . . . . . 2 . . 3
 1 . . . . . 2 . . 4 4 . . . . . 2 2 . .
 2 1 . . . . . . . . 2 4 4 . . . . . 2 .
 . . 1 . . . . 2 . . . . . 4 4 . . 2 . 2
gap> sigma1 := RcwaMapping([[1,0,1],[1,1,1],[1,1,1],[1,-2,1]]);;;
gap> sigma2 := RcwaMapping(
>                [[1, 0,1],[3,3,2],[1,0,1],[2,0,1],[1,0,1],[1,0,1],
>                 [1,-3,3],[3,3,2],[1,0,1],[1,0,1],[1,0,1],[1,0,1],
>                 [2, 0,1],[3,3,2],[1,0,1],[1,0,1],[1,0,1],[1,0,1]]);;
gap> sigma1 = StandardConjugate(sigma2);
true
gap> sigma := sigma1*sigma2;;
gap> fact := FactorizationOnConnectedComponents(sigma,36);;
gap> List(fact,MovedPoints);
[ 33(36) U 34(36) U 35(36), 9(36) U 10(36) U 11(36), 
  <union of 23 residue classes (mod 36)> \ [ -6, 3 ] ]
gap> Trajectory(T,27,[1],"LastCoeffs");
[ 36472996377170786403, 195820718533800070543, 1180591620717411303424 ]
gap> Trajectory(T,ResidueClass(Integers,3,0),Integers);
[ 0(3), 0(3) U 5(9), 0(3) U 5(9) U 7(9) U 8(27), 
  <union of 20 residue classes (mod 27)>, 
  <union of 73 residue classes (mod 81)>, Z \ 10(81) U 37(81), Integers ]
gap> List(Trajectory(sigma,37,37^(sigma^-1),"AllCoeffs"),
>         c->(c[1]*37+c[2])/c[3]){[1..23]} = Cycle(sigma,37);
true
gap> Trajectory(a,8,10,"AllCoeffs");
[ [ 1, 0, 1 ], [ 3, 0, 2 ], [ 9, 0, 4 ], [ 27, 0, 8 ], [ 81, -8, 32 ], 
  [ 243, -24, 64 ], [ 729, -72, 128 ], [ 2187, -88, 512 ], 
  [ 6561, -264, 1024 ], [ 19683, -1816, 4096 ] ]
gap> G := Group(g,h);;
gap> P := RespectedPartition(G);
[ 0(6), 1(6), 3(6), 4(6), 5(6), 2(12), 8(12) ]
gap> SymmetricGroup(P);
<rcwa group over Z with 2 generators, of size 5040>
gap> phi := IsomorphismMatrixGroup(G);;
gap> M := Image(phi);
<matrix group with 2 generators>
gap> H := ActionOnRespectedPartition(G);
Group([ (1,6,2,5,3,7,4), (1,6,2,5)(3,7,4) ])
gap> StructureDescription(H);
"S7"
gap> RankOfKernelOfActionOnRespectedPartition(G);
6
gap> K := KernelOfActionOnRespectedPartition(G);
<rcwa group over Z with 6 generators>
gap> IsAbelian(K);
true
gap> g in G;
true
gap> g*h^3*g^-2*h in G;
true
gap> a in G;
false
gap> Multiplier(G);
2
gap> Divisor(G);
2
gap> DihedralGroup(ResidueClass(3,4));
<tame rcwa group over Z with 2 generators>
gap> GeneratorsOfGroup(last);
[ ClassShift(3,4), ClassReflection(3,4) ]
gap> Divisor(Group(ClassTransposition(0,2,1,6)));
3
gap> Multiplier(Group(a,b));
infinity
gap> G := Group(ab,ac);
<rcwa group over Z with 2 generators>
gap> One(G) in G;
true
gap> ab in G;
true
gap> ac^-1 in G;
true
gap> ab*bc^2*ac^-3 in G;
true
gap> a in G;
false
gap> t in G;
false
gap> u in G;
false
gap> T in G;
false
gap> nu^a in G;
false
gap> g in G;
false
gap> G := Group(a,b);
<rcwa group over Z with 2 generators>
gap> a*b in G;
true
gap> u in G;
false
gap> S0 := LikelyContractionCentre(T,100,1000);
[ -136, -91, -82, -68, -61, -55, -41, -37, -34, -25, -17, -10, -7, -5, -1, 0, 
  1, 2 ]
gap> f1 := RcwaMapping([[2,0,1]]);
Rcwa mapping of Z: n -> 2n
gap> f2 := RcwaMapping([[2,1,1]]);
Rcwa mapping of Z: n -> 2n + 1
gap> a_1 := Restriction(a,f1);
<wild bijective rcwa mapping of Z with modulus 8>
gap> a_2 := Restriction(a,f2);
<wild bijective rcwa mapping of Z with modulus 8>
gap> G := Group(a_1,a_2);
<rcwa group over Z with 2 generators>
gap> IsAbelian(G);
true
gap> Set(FactorizationOnConnectedComponents(a_1*a_2,2)) = Set([a_1,a_2]);
true
gap> List([-2..2],k->Multpk(a,2,k));
[ 1(2), 0(2), [  ], [  ], [  ] ]
gap> List([-2..2],k->Multpk(a,3,k));
[ [  ], [  ], [  ], Integers, [  ] ]
gap> List([-2..2],k->Multpk(a,5,k));
[ [  ], [  ], Integers, [  ], [  ] ]
gap> rc := function(r,m) return ResidueClass(Integers,m,r); end;;
gap> md := f -> [Multiplier(f),Divisor(f)];;
gap> c1 := Restriction(a^-1,RcwaMapping([[2,0,1]]));;
gap> c2 := RcwaMapping([[1,0,2,],[2,1,1],[1,-1,1],[2,1,1]]);;
gap> md(Comm(c1,c2));
[ 4, 3 ]
gap> Order(RcwaMapping([[rc(1,2),rc(36,72)]]));
2
gap> f1 := RcwaMapping([[rc(0,4),rc(1,6)],[rc(2,4),rc(5,6)]]);
<bijective rcwa mapping of Z with modulus 12, of order 2>
gap> Cycle(f1,rc(0,4));
[ 0(4), 1(6) ]
gap> Cycle(f1,rc(5,6));
[ 5(6), 2(4) ]
gap> G := Restriction(Group(a,b),RcwaMapping([[5,3,1]]));
<rcwa group over Z with 2 generators>
gap> MovedPoints(G);
3(5) \ [ -2, 3 ]
gap> GuessedDivergence(g);
1.
gap> GuessedDivergence(a);
1.06066
gap> GuessedDivergence(u);
1.15991
gap> G := Group(g,h);
<rcwa group over Z with 2 generators>
gap> IsTransitive(G,Integers);
true
gap> H := Restriction(G,RcwaMapping([[3,2,1]]));
<tame rcwa group over Z with 2 generators, of size infinity>
gap> MovedPoints(H);
2(3)
gap> IsTransitive(H,MovedPoints(H));
true
gap> G := Group(a,b);
<rcwa group over Z with 2 generators>
gap> IsTransitive(G,Integers);
false
gap> H := Restriction(G,RcwaMapping([[3,2,1]]));
<rcwa group over Z with 2 generators>
gap> IsTransitive(H,MovedPoints(H));
false
gap> SetName(g,"g"); SetName(h,"h");
gap> D := DirectProduct(Group(a,b),Group(g,h),Group(nu,t));
<rcwa group over Z with 6 generators>
gap> Projection(D,1);;
gap> Embedding(D,2);
[ g, h ] -> [ <bijective rcwa mapping of Z with modulus 18, of order 7>, 
  <bijective rcwa mapping of Z with modulus 18, of order 12> ]
gap> G := Group(g,h);;
gap> IsSolvable(G);
false
gap> IsPerfect(G);
false
gap> IsPerfect(TrivialSubgroup(G));
true
gap> g1 := RcwaMapping([[1,0,1],[2,0,1],[1,0,2],[2,0,1]]);;
gap> g2 := RcwaMapping([[1,0,1],[2,4,1],[1,0,2],[2,4,1]]);;
gap> IsSolvable(Group(g1,g2));
true
gap> ImageDensity(T);
4/3
gap> ImageDensity(a);
1
gap> ImageDensity(u);
1
gap> ImageDensity(RcwaMapping([[2,0,1]]));
1/2
gap> f0 := RcwaMapping([[2,0,1]]);;
gap> f1 := RcwaMapping([[2,1,1]]);
Rcwa mapping of Z: n -> 2n + 1
gap> f0 := RcwaMapping([[2,0,1]]);
Rcwa mapping of Z: n -> 2n
gap> f1 := RcwaMapping([[2,1,1]]);
Rcwa mapping of Z: n -> 2n + 1
gap> f := Restriction(g,f0)*Restriction(h,f1);
<bijective rcwa mapping of Z with modulus 12>
gap> Order(f);
84
gap> RestrictedPerm(f,ResidueClass(Integers,2,0));
<rcwa mapping of Z with modulus 12>
gap> Order(last);
7
gap> RestrictedPerm(f,ResidueClass(Integers,2,1));
<rcwa mapping of Z with modulus 12>
gap> Order(last);
12
gap> kappa := RcwaMapping([[1,0,1],[1,0,1],[3,2,2],[1,-1,1],
>                          [2,0,1],[1,0,1],[3,2,2],[1,-1,1],
>                          [1,1,3],[1,0,1],[3,2,2],[2,-2,1]]);;
gap> kappatilde := RcwaMapping([[2,-4,1],[3, 33,1],[3,2,2],[1,-1,1],
>                               [2, 0,1],[3,-39,1],[3,2,2],[1,-1,1],
>                               [1, 1,3],[3, 33,1],[3,2,2],[1, 4,3]]);;
gap> kappa^2 in Group(a,b);
false
gap> List([-2..2],k->Determinant(a^k));
[ 0, 0, 0, 0, 0 ]
gap> List([-2..2],k->Determinant(b^k));
[ -2, -1, 0, 1, 2 ]
gap> Determinant(a^g);
0
gap> Determinant(b^g);
1
gap> Determinant(b^u);
1
gap> Determinant(a^kappa);
0
gap> Determinant(b^kappa);
1
gap> Determinant(b^kappatilde);
1
gap> Determinant(b^2*b^kappatilde*g^-1);
3
gap> Determinant(sigma);
0
gap> Determinant(sigma*b^-1);
-1
gap> Determinant(sigma*b^-1*nu);
0
gap> Determinant(sigma*b^-1*nu^2);
1
gap> Determinant(PseudoRandom(Group(g,h)));
0
gap> Sign(nu);
-1
gap> Sign(nu^2);
1
gap> Sign(nu^3);
-1
gap> Sign(t);
-1
gap> Sign(nu^3*t);
1
gap> Sign(a);
1
gap> Sign(a*b);
-1
gap> Sign((a*b)^2);
1
gap> Sign(Comm(a,b));
1
gap> ClassWiseOrderPreservingOn(T);
Integers
gap> ClassWiseOrderPreservingOn(u);
Integers
gap> ClassWiseOrderReversingOn(t);
Integers
gap> ClassWiseOrderPreservingOn(t);
[  ]
gap> ClassWiseConstantOn(RcwaMapping([[2,0,1],[0,4,1]]));
1(2)
gap> LargestSourcesOfAffineMappings(a);
[ 0(2), 1(4), 3(4) ]
gap> LargestSourcesOfAffineMappings(One(a)); 
[ Integers ]
gap> LargestSourcesOfAffineMappings(T);
[ 0(2), 1(2) ]
gap> LargestSourcesOfAffineMappings(kappa);
[ 2(4), 1(4) U 0(12), 3(12) U 7(12), 4(12), 8(12), 11(12) ]
gap> cl := ResidueClassWithFixedRepresentative(2,1);
[1/2]
gap> cl^T;
[2/3]
gap> last^T;
[1/3] U [8/9]
gap> last^T;
[2/3] U [2/9] U [4/9] U [26/27]
gap> last^T;
[1/3] U [1/9] U [2/9] U [8/9] U [13/27] U [17/27] U [20/27] U [80/81]
gap> AsOrdinaryUnionOfResidueClasses(last);
Z \ 0(3) U 5(9)
gap> PreImagesSet(T,cl);
[2/4] U [3/4]
gap> AsOrdinaryUnionOfResidueClasses(last);
2(4) U 3(4)
gap> PreImagesSet(T,last2);
[1/8] U [4/8] U [6/8] U [7/8]
gap> Delta(last);            
1/4
gap> PreImagesSet(T,last2);
[2/16] U [8/16] U [9/16] U [11/16] U [12/16] U [13/16] U [14/16] U [15/16]
gap> Delta(last);            
5/4
gap> AsOrdinaryUnionOfResidueClasses(last2);
<union of 8 residue classes (mod 16)>
gap> Residues(last);
[ 2, 8, 9, 11, 12, 13, 14, 15 ]
gap> P2 := AllResidueClassesWithFixedRepsModulo(2);;
gap> P3 := AllResidueClassesWithFixedRepsModulo(3);;
gap> Product(List(P2,cl->Rho(cl)));
-E(4)
gap> Product(List(P3,cl->Rho(cl)));
-E(4)
gap> Product(List(P2,cl->Rho(cl^t)));
E(4)
gap> Product(List(P3,cl->Rho(cl^t)));
E(4)
gap> Product(List(P2,cl->Rho(cl^a)));
-E(4)
gap> Product(List(P3,cl->Rho(cl^a)));
-E(4)
gap> Product(List(P2,cl->Rho(cl^ClassReflection(0,2))));
E(4)
gap> Product(List(P3,cl->Rho(cl^ClassReflection(0,2))));
E(4)
gap> Product(List(P2,cl->Rho(cl^ClassTransposition(0,2,1,6))));
-E(4)
gap> Product(List(P3,cl->Rho(cl^ClassTransposition(0,2,1,6))));
-E(4)
gap> DecreasingOn(T);
0(2)
gap> DecreasingOn(T^2);
Z \ 3(4)
gap> DecreasingOn(T^3);
0(4) U 2(8) U 5(8)
gap> DecreasingOn(a);
1(2)
gap> DecreasingOn(a^2);
1(8) U 7(8)
gap> DecreasingOn(a^3);
<union of 8 residue classes (mod 16)>
gap> FactorizationIntoCSCRCT(ab);
[ ClassShift(7,9), ClassShift(1,9)^-1, ClassTransposition(1,9,4,9), 
  ClassTransposition(1,9,7,9), ClassTransposition(6,18,15,18), 
  ClassTransposition(5,9,15,18), ClassTransposition(4,9,15,18), 
  ClassTransposition(5,9,6,18), ClassTransposition(4,9,6,18) ]
gap> Product(last) = ab;
true
gap> Factorization(Comm(g,h));
[ ClassShift(3,6)^2, ClassShift(2,3)^-2, ClassTransposition(0,6,3,6) ]
gap> Product(last) = Comm(g,h);
true
gap> FactorizationIntoGenerators(nu*nu^a);
[ ClassShift(5,6), ClassShift(4,6), ClassTransposition(0,6,1,6), 
  ClassTransposition(0,6,5,6), ClassTransposition(0,6,3,6), 
  ClassTransposition(0,6,4,6), ClassTransposition(0,6,2,6), 
  ClassTransposition(2,3,3,6), ClassTransposition(1,3,3,6), 
  ClassTransposition(2,3,0,6), ClassTransposition(1,3,0,6) ]
gap> List([t,nu,tau,nu^2,nu^-1,t*nu],Factorization);
[ [ ClassReflection(0,1) ], [ ClassShift(0,1) ], 
  [ ClassTransposition(0,2,1,2) ], [ ClassShift(0,1)^2 ], 
  [ ClassShift(0,1)^-1 ], [ ClassReflection(0,1), ClassShift(0,1) ] ]
gap> Factorization(g^ClassReflection(0,4));
[ ClassShift(8,12), ClassShift(3,6), ClassTransposition(1,6,5,6), 
  ClassTransposition(1,6,3,6), ClassTransposition(0,12,10,12), 
  ClassTransposition(0,12,6,12), ClassTransposition(0,12,8,12), 
  ClassTransposition(10,12,16,24), ClassTransposition(8,12,16,24), 
  ClassTransposition(10,12,4,24), ClassTransposition(8,12,4,24), 
  ClassTransposition(1,6,4,12), ClassTransposition(1,6,2,12), 
  ClassReflection(4,6), ClassReflection(2,24) ]
gap> FactorizationIntoCSCRCT((ClassShift(1,3)*ClassReflection(0,2))^a);
[ ClassShift(15,18), ClassTransposition(1,9,5,9), 
  ClassTransposition(5,9,15,18), ClassTransposition(1,9,15,18), 
  ClassTransposition(5,9,6,18), ClassTransposition(1,9,6,18), 
  ClassReflection(0,3) ]
gap> 2*a*RightInverse(2*a);
IdentityMapping( Integers )
gap> Display(CommonRightInverse(RcwaMapping([[2,0,1]]),
>                               RcwaMapping([[2,1,1]])));

Rcwa mapping of Z with modulus 2

        /
        | n/2     if n in 0(2)
 n |-> <  (n-1)/2 if n in 1(2)
        |
        \

gap> Induction(Restriction(kappa,RcwaMapping([[5,3,1],[5,2,1]])),
>              RcwaMapping([[5,3,1],[5,2,1]])) = kappa;
true
gap> Induction(Restriction(Group(a,b),RcwaMapping([[5,3,1]])),
>              RcwaMapping([[5,3,1]])) = Group(a,b);
true
gap> Ball(Group((1,2),(2,3),(3,4),(4,5),(5,6)),(),2);
[ (), (5,6), (4,5), (4,5,6), (4,6,5), (3,4), (3,4)(5,6), (3,4,5), (3,5,4), 
  (2,3), (2,3)(5,6), (2,3)(4,5), (2,3,4), (2,4,3), (1,2), (1,2)(5,6), 
  (1,2)(4,5), (1,2)(3,4), (1,2,3), (1,3,2) ]
gap> Ball(Group((1,2),(2,3),(3,6)),1,3,OnPoints);
[ 1, 2, 3, 6 ]
gap> Ball(Group((1,2),(2,3),(3,4),(4,5),(5,6)),[1,2,3],1,OnTuples);
[ [ 1, 2, 3 ], [ 1, 2, 4 ], [ 1, 3, 2 ], [ 2, 1, 3 ] ]
gap> Ball(G,[1,2,3],2,OnTuples);
[ [ -5, 2, 3 ], [ -3, 5, 4 ], [ -1, 1, 8 ], [ 0, -1, 4 ], [ 0, -1, 7 ], 
  [ 0, -1, 8 ], [ 0, 4, 1 ], [ 0, 4, 8 ], [ 1, 2, 0 ], [ 1, 2, 3 ], 
  [ 1, 2, 6 ], [ 2, 0, 4 ], [ 2, 0, 5 ], [ 3, 5, 4 ], [ 5, 1, 8 ], 
  [ 6, -1, 4 ], [ 7, 2, 3 ] ]
gap> Length(Ball(G,[1,2,3],4,OnTuples));
133
gap> Length(Ball(G,[1,2,3],4,OnSets));
130
gap> FixedPointsOfAffinePartialMappings(ClassShift(0,2));
[ [  ], Rationals ]
gap> List([1..3],k->FixedPointsOfAffinePartialMappings(T^k));
[ [ [ 0 ], [ -1 ] ], [ [ 0 ], [ 1 ], [ 2 ], [ -1 ] ], 
  [ [ 0 ], [ -7 ], [ 2/5 ], [ -5 ], [ 4/5 ], [ 1/5 ], [ -10 ], [ -1 ] ] ]
gap> FixedPointsOfAffinePartialMappings(a^-3);
[ [ 0 ], [ 1 ], [ -17/5 ], [ 6/11 ], [ 13/37 ], [ -2/5 ], [ 3/5 ], [ -4/11 ], 
  [ -14/5 ], [ -9/11 ], [ 19/37 ], [ 1/5 ], [ -21/5 ], [ -5/37 ], [ 5/37 ], 
  [ 21/5 ], [ -1/5 ], [ -19/37 ], [ 9/11 ], [ 14/5 ], [ 4/11 ], [ -3/5 ], 
  [ 2/5 ], [ -13/37 ], [ -6/11 ], [ 17/5 ], [ -1 ] ]
gap> Cycle(LocalizedRcwaMapping(T,2),131/13);
[ 131/13, 203/13, 311/13, 473/13, 716/13, 358/13, 179/13, 275/13, 419/13, 
  635/13, 959/13, 1445/13, 2174/13, 1087/13, 1637/13, 2462/13, 1231/13, 
  1853/13, 2786/13, 1393/13, 2096/13, 1048/13, 524/13, 262/13 ]
gap> last = Cycle(SemilocalizedRcwaMapping(T,[2,3]),131/13);
true
gap> Length(Cycle(mKnot(7),1621));
265
gap> Sources(kappa);
[  ]
gap> Sources(a);
[  ]
gap> Sources(nu*nu^a);
[ 2(6) ]
gap> [ Sinks(kappa), Sinks(a) ];
[ [  ], [  ] ]
gap> Sinks(nu*nu^a);
[ 3(6) ]
gap> Sinks(Product(List([[1,4,2,4],[1,4,3,4],[3,6,7,12],[2,4,3,6]],
>                       ClassTransposition)));
[ 3(6) U 1(12) ]
gap> Loops(kappa);
[ 10(12) ]
gap> Loops(a);
[ 0(4), 1(4), 3(4) ]
gap> Loops(nu*nu^a);
[ 2(6), 3(6) ]
gap> G := Group(ClassTransposition(0,3,1,3)*ClassTransposition(0,3,2,3),
>               ClassTransposition(0,3,1,3),ClassReflection(0,3));;
gap> Size(G);
48
gap> IsomorphismRcwaGroup(Group(()));
[ () ] -> [ IdentityMapping( Integers ) ]
gap> IsomorphismRcwaGroup(SmallGroup(1,1));
[ <identity> of ... ] -> [ IdentityMapping( Integers ) ]
gap> phi := IsomorphismRcwaGroup(SmallGroup(6,1),Integers);;
gap> StructureDescription(Image(phi));
"S3"
gap> M11 := MathieuGroup(11);;
gap> Action(Image(IsomorphismRcwaGroup(M11))^ClassShift(0,1),
>           [1..LargestMovedPoint(M11)]) = M11;
true
gap> phi := IsomorphismRcwaGroup(FreeGroup(2)); F2 := Image(phi);;
[ f1, f2 ] -> [ <wild bijective rcwa mapping of Z with modulus 8>, 
  <wild bijective rcwa mapping of Z with modulus 8> ]
gap> Difference(Integers,ResidueClass(0,4))^F2.1;
1(4)
gap> Difference(Integers,ResidueClass(2,4))^F2.2;
3(4)
gap> G := Group(g,h);;
gap> IsTame(G); Size(G);
true
infinity
gap> H := DirectProduct(G,G);
<tame rcwa group over Z with 4 generators, of size infinity>
gap> H1 := Action(H,ResidueClass(0,2));
<rcwa group over Z with 4 generators>
gap> Induction(H1,RcwaMapping([[2,0,1]])) = G;
true
gap> Action(H1,ResidueClass(1,2));
Trivial rcwa group over Z
gap> H := WreathProduct(G,AlternatingGroup(5));
<tame rcwa group over Z with 4 generators, of size infinity>
gap> Embedding(H,1);
[ g, h ] -> [ <bijective rcwa mapping of Z with modulus 30, of order 7>, 
  <bijective rcwa mapping of Z with modulus 30, of order 12> ]
gap> Embedding(H,2);
[ (1,2,3,4,5), (3,4,5) ] -> 
[ <bijective rcwa mapping of Z with modulus 5, of order 5>, 
  <bijective rcwa mapping of Z with modulus 5, of order 3> ]
gap> H := WreathProduct(G,Group(ClassShift(0,1)));
<wild rcwa group over Z with 3 generators>
gap> Support(Image(Embedding(H,1)));
3(4)
gap> Embedding(H,2);
[ ClassShift(0,1) ] -> [ <wild bijective rcwa mapping of Z with modulus 4> ]
gap> TransposedClasses(ClassTransposition(1,2,2,6));
[ 1(2), 2(6) ]
gap> TransposedClasses(RcwaMapping([[1,2,1],[1,0,1],[1,-2,1],[1,0,1]]));
[ 0(4), 2(4) ]
gap> TransposedClasses(RcwaMapping([[1,1,1],[1,-1,1]]));
[ 0(2), 1(2) ]
gap> IsClassTransposition(ClassTransposition(1,2,2,6));
true
gap> IsClassTransposition(g);
false
gap> IsClassTransposition(RcwaMapping([[1,1,1],[1,-1,1]]));
true
gap> IsClassTransposition(RcwaMapping([[1,2,1],[1,0,1],[1,-2,1],[1,0,1]]));
true
gap> IsClassShift(ClassShift(8,9)); IsClassShift(RcwaMapping([[1,1,1]]));
true
true
gap> IsClassShift(h);
false
gap> IsClassReflection(RcwaMapping([[-1,0,1]]));
true
gap> IsClassReflection(a);
false
gap> HasIsClassReflection(ClassReflection(6,7));
true
gap> IsPrimeSwitch(ab);
false
gap> IsPrimeSwitch(PrimeSwitch(3));
true
gap> IsPrimeSwitch(Product(Factorization(PrimeSwitch(5))));
true
gap> CyclicGroup(IsRcwaGroupOverZ,1);
Trivial rcwa group over Z
gap> CyclicGroup(IsRcwaGroupOverZ,2);
<rcwa group over Z with 1 generator, of size 2>
gap> CyclicGroup(IsRcwaGroupOverZ,7);
<rcwa group over Z with 1 generator, of size 7>
gap> Display(last);

Rcwa group over Z of size 7, generated by

[

Bijective rcwa mapping of Z with modulus 7, of order 7

        /
        | n+1 if n in 0(7) U 1(7) U 2(7) U 3(7) U 4(7) U 5(7)
 n |-> <  n-6 if n in 6(7)
        |
        \

]

gap> CyclicGroup(IsRcwaGroupOverZ,infinity);
<tame rcwa group over Z with 1 generator, of size infinity>
gap> GeneratorsOfGroup(last);
[ ClassShift(0,1) ]
gap> DihedralGroup(IsRcwaGroupOverZ,infinity);
<tame rcwa group over Z with 2 generators, of size infinity>
gap> GeneratorsOfGroup(last);
[ ClassShift(0,1), ClassReflection(0,1) ]
gap> G := AbelianGroup(IsRcwaGroupOverZ,[2,2,3,7,infinity]);
<tame rcwa group over Z with 5 generators, of size infinity>
gap> List(GeneratorsOfGroup(G),Order);
[ 2, 2, 3, 7, infinity ]
gap> List(GeneratorsOfGroup(G),Support);
[ 0(5), 1(5), 2(5), 3(5), 4(5) ]
gap> F := FreeProduct(Group((1,2)(3,4),(1,3)(2,4)),Group((1,2,3)),
>                     SymmetricGroup(3));
<fp group on the generators [ f1, f2, f3, f4, f5 ]>
gap> phi := IsomorphismRcwaGroup(F);
[ f1, f2, f3, f4, f5 ] -> [ <bijective rcwa mapping of Z with modulus 12>, 
  <bijective rcwa mapping of Z with modulus 24>, 
  <bijective rcwa mapping of Z with modulus 12>, 
  <bijective rcwa mapping of Z with modulus 72>, 
  <bijective rcwa mapping of Z with modulus 36> ]
gap> G := Image(phi);
<wild rcwa group over Z with 5 generators>
gap> ForAll([ G.1^2, G.1^-1*G.2*G.1*G.2^-1, G.2^2, G.3^3,
>             G.4^2, G.5^2, (G.4*G.5)^3 ], IsOne);
true
gap> S := AllResidueClassesModulo(3);
[ 0(3), 1(3), 2(3) ]
gap> nonids := grp->Difference(AsList(grp),[One(grp)]);;
gap> List(S{[2,3]},Si->List(nonids(Group(G.1,G.2)),g->Si^g));
[ [ 3(12), 6(24), 0(24) ], [ 9(12), 18(24), 12(24) ] ]
gap> Union(Flat(last));
0(3)
gap> List(S{[1,3]},Si->List(nonids(Group(G.3)),g->Si^g));
[ [ 1(12), 4(12) ], [ 7(12), 10(12) ] ]
gap> Union(Flat(last));
1(3)
gap> List(S{[1,2]},Si->List(nonids(Group(G.4,G.5)),g->Si^g));
[ [ 8(24), 5(36), 17(36), 2(24), 11(36) ], 
  [ 20(24), 23(36), 35(36), 14(24), 29(36) ] ]
gap> Union(Flat(last));
2(3)
gap> psl := FreeProduct(Group((1,2,3)),Group((1,2)));
<fp group on the generators [ f1, f2 ]>
gap> phi := IsomorphismRcwaGroup(psl);
[ f1, f2 ] -> [ <bijective rcwa mapping of Z with modulus 4>, 
  <bijective rcwa mapping of Z with modulus 2> ]
gap> G := Image(phi);
<wild rcwa group over Z with 2 generators>
gap> S := AllResidueClassesModulo(2);
[ 0(2), 1(2) ]
gap> S[2]^G.1;
0(4)
gap> S[2]^(G.1^2);
2(4)
gap> S[1]^G.2;
1(2)
gap> Length(Ball(G,One(G),5));
34
gap> Length(Ball(G,One(G),8));
106
gap> F := FreeProduct(CyclicGroup(2),CyclicGroup(2));;
gap> phi := IsomorphismRcwaGroup(F);
[ f1, f2 ] -> 
[ ClassReflection(0,1), Bijective rcwa mapping of Z: n -> -n + 1 ]
gap> F := FreeProduct(CyclicGroup(2),CyclicGroup(2),CyclicGroup(2));
<fp group on the generators [ f1, f2, f3 ]>
gap> phi := IsomorphismRcwaGroup(F);
[ f1, f2, f3 ] -> [ <bijective rcwa mapping of Z with modulus 6>, 
  <bijective rcwa mapping of Z with modulus 6>, 
  <bijective rcwa mapping of Z with modulus 6> ]
gap> G := Image(phi);
<wild rcwa group over Z with 3 generators>
gap> List(GeneratorsOfGroup(G),Order);
[ 2, 2, 2 ]
gap> gens := GeneratorsOfGroup(G);;
gap> List([1..3],
>         i->Permutation(gens[i],
>                        [ResidueClass(i-1,3),
>                         Difference(Integers,ResidueClass(i-1,3))]));
[ (1,2), (1,2), (1,2) ]
gap> List(GeneratorsOfGroup(G),Factorization);
[ [ ClassTransposition(1,3,2,3), ClassTransposition(0,6,3,6), 
      ClassTransposition(2,3,3,6), ClassTransposition(1,3,3,6), 
      ClassTransposition(2,3,0,6), ClassTransposition(1,3,0,6) ], 
  [ ClassTransposition(0,3,2,3), ClassTransposition(1,6,4,6), 
      ClassTransposition(2,3,4,6), ClassTransposition(0,3,4,6), 
      ClassTransposition(2,3,1,6), ClassTransposition(0,3,1,6) ], 
  [ ClassTransposition(0,3,1,3), ClassTransposition(2,6,5,6), 
      ClassTransposition(1,3,5,6), ClassTransposition(0,3,5,6), 
      ClassTransposition(1,3,2,6), ClassTransposition(0,3,2,6) ] ]
gap> List([1..3],k->Length(Ball(G,One(G),k)));
[ 4, 10, 22 ]
gap> [ g^2, g^8 ];
[ g^2, g ]
gap> g^2;
g^2
gap> last^6;
g^5
gap> ClassShift(0,1)^3;
ClassShift(0,1)^3
gap> last^17;
ClassShift(0,1)^51
gap> [ Root(g,2), Root(g,8) ];
[ g^4, g ]
gap> Root(g,7);
<bijective rcwa mapping of Z with modulus 84>
gap> last^7 = g;
true
gap> Root(h,10);
<bijective rcwa mapping of Z with modulus 24>
gap> last^10 = h;
true
gap> SplittedClassTransposition(ClassTransposition(0,2,1,4),3);
[ ClassTransposition(0,6,1,12), ClassTransposition(2,6,5,12), 
  ClassTransposition(4,6,9,12) ]
gap> SplittedClassTransposition(ClassTransposition(0,2,1,2),3,false);
[ ClassTransposition(0,6,1,6), ClassTransposition(2,6,3,6), 
  ClassTransposition(4,6,5,6) ]
gap> SplittedClassTransposition(ClassTransposition(0,2,1,2),2,true);
[ ClassTransposition(0,4,1,4), ClassTransposition(0,4,3,4), 
  ClassTransposition(1,4,2,4), ClassTransposition(2,4,3,4) ]
gap> SplittedClassTransposition(ClassTransposition(1,2,4,6),2,false);
[ ClassTransposition(1,4,4,12), ClassTransposition(3,4,10,12) ]
gap> D := DihedralPcpGroup(0);
Pcp-group with orders [ 2, 0 ]
gap> DirectProduct(D,D,D);
Pcp-group with orders [ 2, 0, 2, 0, 2, 0 ]
gap> G := Group(ClassTransposition(0,2,1,2),
>               ClassReflection(0,2),ClassShift(1,2));;
gap> ActionOnRespectedPartition(G);
Group([ (1,2), (), () ])
gap> RankOfKernelOfActionOnRespectedPartition(G);
2
gap> K := KernelOfActionOnRespectedPartition(G);;
gap> List([ClassShift(0,1),ClassReflection(0,1),
>          ClassShift(0,1)*ClassReflection(0,1),
>          ClassShift(0,1)^7*ClassReflection(0,1),
>          ClassTransposition(0,2,1,4),ClassReflection(1,2)],
>         elm->elm in G);
[ true, true, true, true, false, true ]
gap> G := Group(g,h);;
gap> P := RespectedPartition(G);;
gap> RespectsPartition(G,P);
true
gap> List([1,4,6,12],m->RespectsPartition(ClassShift(0,m),P));
[ false, false, true, false ]
gap> List([1,2,6,12],m->RespectsPartition(ClassReflection(0,m),P));
[ false, false, true, false ]
gap> List([g,h,g*h,a,ab],elm->RespectsPartition(elm,P));
[ true, true, true, false, false ]
gap> G := Group(ClassTransposition(0,2,1,2),ClassShift(3,4));;
gap> ProjectionsToInvariantUnionsOfResidueClasses(G,8);
[ [ ClassTransposition(0,2,1,2), ClassShift(3,4) ] -> 
    [ <bijective rcwa mapping of Z with modulus 8>, 
      IdentityMapping( Integers ) ], 
  [ ClassTransposition(0,2,1,2), ClassShift(3,4) ] -> 
    [ <bijective rcwa mapping of Z with modulus 4>, 
      <bijective rcwa mapping of Z with modulus 4> ], 
  [ ClassTransposition(0,2,1,2), ClassShift(3,4) ] -> 
    [ <bijective rcwa mapping of Z with modulus 8>, 
      IdentityMapping( Integers ) ] ]
gap> List(last,phi->Support(Image(phi)));
[ 0(8) U 1(8), 2(4) U 3(4), 4(8) U 5(8) ]
gap> List(last2,phi->Size(Image(phi)));
[ 2, infinity, 2 ]
gap> G := Group(ClassShift(0,1),ClassReflection(0,1));;
gap> StructureDescription(G);
"D0"
gap> G := Group(ClassShift(0,2),ClassReflection(1,2));;
gap> StructureDescription(G);
"Z x C2"
gap> G := Group(ClassShift(0,2),ClassReflection(0,2),
>               ClassShift(1,2),ClassReflection(1,2));;
gap> StructureDescription(G);
"D0 x D0"
gap> G := Group(ClassTransposition(0,4,1,4),ClassShift(0,4),
>               ClassReflection(2,4),ClassShift(3,4));;
gap> StructureDescription(G);
"(Z x Z) . C2 x C2 x Z"
gap> G := Group(ClassTransposition(0,4,1,4),ClassTransposition(2,4,3,4),
>               ClassTransposition(0,2,1,2));;
gap> StructureDescription(G);
"C2 x C2"
gap> G := Group(ClassTransposition(0,4,1,4),ClassShift(0,4),
>               ClassReflection(1,4),ClassReflection(2,4),ClassShift(3,4));;
gap> StructureDescription(G:short);
"Z^2.((S3xS3):2)x2xZ"
gap> G := Group(ClassTransposition(0,2,1,4),
>               ClassShift(2,4),ClassReflection(1,2));;
gap> StructureDescription(G:short);
"Z^2.((S3xS3):2)"
gap> G := Group(ClassTransposition(0,2,1,4),ClassShift(0,5));;
gap> StructureDescription(G);
"(Z x Z x Z x Z x Z x Z x Z) . (C2 x S7)"
gap> F2 := Image(IsomorphismRcwaGroup(FreeGroup(2)));;
gap> PSL2Z := Image(IsomorphismRcwaGroup(FreeProduct(CyclicGroup(3),
>                                                    CyclicGroup(2))));;
gap> G := DirectProduct(PSL2Z,F2);
<wild rcwa group over Z with 4 generators>
gap> StructureDescription(G);
"(C3 * C2) x F2"
gap> G := WreathProduct(G,CyclicGroup(IsRcwaGroupOverZ,infinity));
<wild rcwa group over Z with 5 generators>
gap> StructureDescription(G);
"((C3 * C2) x F2) wr Z"
gap> Collatz := RcwaMapping([[2,0,3],[4,-1,3],[4,1,3]]);;
gap> G := Group(Collatz,ClassShift(0,1));;
gap> StructureDescription(G:short);
"<unknown>.Z"
gap> G := Group(ClassShift(0,2),ClassReflection(0,2),
>               ClassTransposition(0,2,1,2));;
gap> N := Subgroup(G,[ClassShift(0,2),ClassShift(1,2)]);;
gap> IsNormal(G,N);
true
gap> Index(G,N);
8
gap> G/N;
Group([ (), (1,2)(3,5)(4,6)(7,8), (1,3)(2,4)(5,7)(6,8) ])
gap> StructureDescription(last);
"D8"
gap> Exponent(G);
infinity
gap> G := Group(ClassTransposition(0,2,1,2),ClassTransposition(0,3,1,3));
<rcwa group over Z with 2 generators>
gap> Exponent(G);
4
gap> (1,2,3,4,5,6,7,8,9,10,11,12)^Collatz;
(1,3,2,5,7,4,9,11,6,13,15,8)
gap> C := RcwaMapping([[1,0,2],[3,1,1]]);;
gap> gt := List([3,5..99],n->GluckTaylorInvariant(Trajectory(C,n,[1])));;
gap> Minimum(gt) > 9/13 and Maximum(gt) < 5/7;
true
gap> P := RandomPartitionIntoResidueClasses(Integers,5,[2,3]);;
gap> Permuted(P,RcwaMapping([P])) = Permuted(P,(1,2,3,4,5));
true
gap> G := WreathProduct(Group(ClassShift(0,1)),Group(ClassShift(0,1)));
<wild rcwa group over Z with 2 generators>
gap> elm := First(G,g->Density(Support(g))>0 and Density(Support(g))<1/4);
<bijective rcwa mapping of Z with modulus 8>
gap> Support(elm);
5(8)
gap> Factorization(elm);
[ ClassShift(5,8)^-1 ]
gap> g := RcwaMapping([[2,2,1],[1, 4,1],[1,0,2],[2,2,1],[1,-4,1],[1,-2,1]]);;
gap> h := RcwaMapping([[2,2,1],[1,-2,1],[1,0,2],[2,2,1],[1,-1,1],[1, 1,1]]);;
gap> SetName(g,"g"); SetName(h,"h");
gap> G := Group(g,h);;
gap> H := Stabilizer(G,0);;
gap> IsTrivial(H);
false
gap> ClassTransposition(1,3,2,3) in H;
false
gap> g in H;
false
gap> h/g in H;
true
gap> First(H,h->not IsOne(h));
<bijective rcwa mapping of Z with modulus 6>
gap> phi := EpimorphismFromFreeGroup(G);
[ g, h ] -> [ g, h ]
gap> l := [];;
gap> for h in H do Add(l,h); if Length(l) = 10 then break; fi; od;
gap> List(l,h->0^h);
[ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 ]
gap> List(l,h->PreImagesRepresentative(phi,h));
[ <identity ...>, h*g^-1, g*h^-1, h*g^-1*h*g^-1, g^-1*h^-1*g^2, g^-2*h*g, 
  g*h^-1*g*h^-1, h^-3*g^-1, h*g*h^2, h^-4 ]
gap> l := ExtRepOfObj(Collatz);
[ 3, [ [ 2, 0, 3 ], [ 4, -1, 3 ], [ 4, 1, 3 ] ] ]
gap> Collatz2 := ObjByExtRep(FamilyObj(Collatz),l);
<rcwa mapping of Z with modulus 3>
gap> Collatz2 = Collatz;
true
gap> ShiftsUpOn(ClassShift(0,1));
Integers
gap> ShiftsDownOn(ClassShift(0,1)^-1);
Integers
gap> ShiftsUpOn(ClassShift(2,3));
2(3)
gap> ShiftsDownOn(ClassShift(2,3));
[  ]
gap> ShiftsUpOn(ClassShift(2,3)^-1);
[  ]
gap> ShiftsDownOn(ClassShift(2,3)^-1);
2(3)
gap> ShiftsUpOn(ClassReflection(0,1));
[  ]
gap> ShiftsDownOn(ClassReflection(0,1));
[  ]
gap> ShiftsUpOn(Collatz);
[  ]
gap> ShiftsDownOn(Collatz);
[  ]
gap> a := ClassTransposition(2,4,3,4);; SetName(a,"a");
gap> b := ClassTransposition(4,6,8,12);; SetName(b,"b");
gap> c := ClassTransposition(3,4,4,6);; SetName(c,"c");
gap> G := Group(a,b,c);
<rcwa group over Z with 3 generators>
gap> phi := EpimorphismFromFpGroup(G,3);
[ a, b, c ] -> [ a, b, c ]
gap> Length(RelatorsOfFpGroup(Source(phi))) >= 4;
true
gap> G := Group(ClassShift(0,2),ClassTransposition(0,3,1,3));
<rcwa group over Z with 2 generators>
gap> Orbit(G,0);
Z \ 5(6)
gap> Orbit(G,5);
[ 5 ]
gap> Orbit(G,ResidueClass(0,2));
[ 0(2), 1(6) U 2(6) U 3(6), 1(3) U 3(6), 0(3) U 1(6), 0(3) U 4(6), 
  1(3) U 0(6), 0(3) U 2(6), 0(6) U 1(6) U 2(6), 2(6) U 3(6) U 4(6), 
  1(3) U 2(6) ]
gap> Union(last);
Z \ 5(6)
gap> G := Group(Collatz,ClassTransposition(0,2,1,6));
<rcwa group over Z with 2 generators>
gap> orb1 := Orbit(G,0);
[ 0, 1 ]
gap> orb2 := Orbit(G,2);
<orbit of 2 under <wild rcwa group over Z with 2 generators>>
gap> orb3 := Orbit(G,37);
<orbit of 37 under <wild rcwa group over Z with 2 generators>>
gap> orb2 = orb3;
true
gap> orb1 = orb2;
false
gap> orb3 = orb1;
false
gap> UnderlyingGroup(orb2) = G;
true
gap> Representative(orb3);
37
gap> Iterator(orb2);
Iterator of <orbit of 2 under <wild rcwa group over Z with 2 generators>>
gap> IsDoneIterator(last);
false
gap> First(orb2,n->n>1000);
1099
gap> 0 in orb2;
false
gap> 1 in orb2;
false
gap> 2 in orb2;
true
gap> 6754 in orb2;
true
gap> Intersection(orb2,[-1..5]);
[ 2, 3, 4, 5 ]
gap> cl := ResidueClassWithFixedRep(-4,23);
[23/-4]
gap> U := RepresentativeStabilizingRefinement(cl,3);
[15/-12] U [19/-12] U [23/-12]
gap> l := AsListOfClasses(U);
[ [15/-12], [19/-12], [23/-12] ]
gap> cyc3 := RcwaMapping([l]);
<bijective rcwa mapping of Z with modulus 12, of order 3>
gap> Permutation(cyc3,l);
(1,2,3)
gap> G := CT(Integers);
CT(Z)
gap> S1 := ResidueClass(0,2);; S2 := ResidueClass(1,2);;
gap> g := RepresentativeAction(G,S1,S2);
<bijective rcwa mapping of Z with modulus 2>
gap> S1^g;
1(2)
gap> RepresentativeAction(G,S1,S1);
IdentityMapping( Integers )
gap> S1 := ResidueClass(0,4);; S2 := ResidueClass(1,2);;
gap> g := RepresentativeAction(G,S1,S2);
<bijective rcwa mapping of Z with modulus 4>
gap> S1^g;
1(2)
gap> S1 := ResidueClass(0,4);; S2 := ResidueClass(0,2);;
gap> g := RepresentativeAction(G,S1,S2);
<bijective rcwa mapping of Z with modulus 4>
gap> S1^g;
0(2)
gap> S2 := ResidueClassUnion(Integers,4,[1,2,3]);;
gap> g := RepresentativeAction(G,S1,S2);
<bijective rcwa mapping of Z with modulus 8>
gap> S1^g;
Z \ 0(4)
gap> S2 := ResidueClassUnion(Integers,4,[0,1,2]);;
gap> g := RepresentativeAction(G,S1,S2);
<bijective rcwa mapping of Z with modulus 8>
gap> S1^g;
Z \ 3(4)
gap> S2 := ResidueClassUnion(Integers,5,[0,1,2]);;
gap> g := RepresentativeAction(G,S1,S2);
<bijective rcwa mapping of Z with modulus 400>
gap> S1^g;
Z \ 3(5) U 4(5)
gap> MaximalShift(ClassShift(4,10));
10
gap> MaximalShift(ClassReflection(2,7));
4
gap> IsClassWiseTranslating(ClassShift(4,10));
true
gap> IsClassWiseTranslating(ClassReflection(2,7));
false
gap> g := RcwaMapping("((3(4),4(6))*(4,6))^3/((2,3)^-1*[5,6])");
<bijective rcwa mapping of Z with modulus 36>
gap> g = (ClassTransposition(3,4,4,6)*ClassShift(4,6))^3/
>        (ClassShift(2,3)^-1*ClassReflection(5,6));
true
gap> g = RcwaMapping("((3(4),4(6))*(4,6))^3/((2,3)^-1*[5(6)])");
true
gap> G := GroupByResidueClasses(List([[0,2],[0,4],[1,4],[2,4],[3,4]],
>                                    ResidueClass));
<rcwa group over Z with 8 generators>
gap> H := Group(List([[0,2,1,2],[1,2,2,4],[0,2,1,4],[1,4,2,4]],
>                    ClassTransposition)); # (first) Higman-Thompson group
<rcwa group over Z with 4 generators>
gap> G = H;
true
gap> cts := Filtered(List(ClassPairs(4),ClassTransposition),
>                    ct->Mod(ct) in [2,4]);;
gap> G := Group(cts);
<rcwa group over Z with 11 generators>
gap> gens := SmallGeneratingSet(G);
[ ClassTransposition(0,2,1,2), ClassTransposition(0,2,1,4), 
  ClassTransposition(0,2,3,4), ClassTransposition(0,4,1,4) ]
gap> G := Group(gens);
<rcwa group over Z with 4 generators>
gap> Br := List([1..10],r->RestrictedBall(G,One(G),r,4));;
gap> List(Br,Length);
[ 5, 14, 27, 39, 51, 71, 99, 118, 120, 120 ]
gap> List([1..4],m->Length(AllElementsOfCTZWithGivenModulus(m)));
[ 1, 1, 17, 238 ]
gap> g := ClassTransposition(0,2,1,2)*ClassTransposition(0,4,1,6);
<bijective rcwa mapping of Z with modulus 12>
gap> ShortResidueClassCycles(g,Mod(g)^2,20);
[ [ 2(12), 3(12) ], [ 10(12), 11(12) ], [ 4(24), 5(24), 7(36), 6(36) ], 
  [ 20(24), 21(24), 31(36), 30(36) ], 
  [ 8(48), 9(48), 13(72), 19(108), 18(108), 12(72) ], 
  [ 40(48), 41(48), 61(72), 91(108), 90(108), 60(72) ] ]
gap> CycleRepresentativesAndLengths(g,[0..50]);
[ [ 2, 2 ], [ 4, 4 ], [ 8, 6 ], [ 10, 2 ], [ 14, 2 ], [ 16, 8 ], [ 20, 4 ], 
  [ 22, 2 ], [ 26, 2 ], [ 28, 4 ], [ 32, 10 ], [ 34, 2 ], [ 38, 2 ], 
  [ 40, 6 ], [ 44, 4 ], [ 46, 2 ], [ 50, 2 ] ]
gap> RCWADoThingsToBeDoneAfterTest();
gap> STOP_TEST( "integral.tst", 8000000000 );

#############################################################################
##
#E  integral.tst . . . . . . . . . . . . . . . . . . . . . . . . .  ends here