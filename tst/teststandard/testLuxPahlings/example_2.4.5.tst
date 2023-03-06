#@local G, g, cl, M2, j, w, k, p, F, e, ev, evecs, dom, sp, c, v, scp
#@local d, i, a, b, d1, d2, epsq, phi, x, m
######################################################################
gap> START_TEST( "example_2.4.5.tst" );

######################################################################
gap> G := AlternatingGroup(6);;
gap> g := [ (), (1,2)(3,4), (1,2,3), (1,2,3)(4,5,6), (1,2,3,4)(5,6),
>             (1,2,3,4,5), (1,3,5,2,4) ];;
gap> cl := List( g, x -> ConjugacyClass(G,x) );; M2:=[];;
gap> for j in [1..Length(cl)] do M2[j]:=[];
>     w := List( Cartesian(cl[2],cl[j]), x->x[1]*x[2] );
>     for k in [1..Length(cl)] do M2[j][k]:=Length(Positions(w,g[k]));od;
>    od;

######################################################################
gap> p := 61;; F := GF(p);; e := Identity(F);; ev := Eigenvalues(F,M2*e);;
gap> evecs := List( Eigenspaces(F,M2*e), GeneratorsOfVectorSpace );;

######################################################################
gap> dom := function( p, x )
> return( Position(List([-(p-1)/2..(p-1)/2], i->i*e), x) - (p+1)/2 );end;;

######################################################################
gap> for sp in evecs do
> for c in ev do
> if sp[1] * M2*e = sp[1]*c then Print("\n",dom(p,c),":  "); fi;
> od;
> for v in sp do Print( List(v , x -> dom(p,x)), " ," ); od;
> od;  Print( "\n" );

0:  [ 1, 0, -23, -23, 0, 0, 23 ] ,[ 0, 0, 0, 0, 0, 1, -1 ] ,
-16:  [ 1, 1, 1, 1, 1, 1, 1 ] ,
-9:  [ 1, 12, -6, -6, 0, 0, 0 ] ,
9:  [ 1, -12, 0, -12, 12, 0, 0 ] ,[ 0, 0, 1, -1, 0, 0, 0 ] ,
5:  [ 1, -27, 0, 0, -27, 27, 27 ] ,

######################################################################
gap> scp := function (v,w)
> return(Sum( List([1..Length(cl)], i->Size(cl[i])*v[i]*w[i]) )/Size(G));
> end;;
gap> for v in Concatenation(evecs) do
>      d := Filtered( [1..(p-1)/2], x -> (x*e)^2 = scp(v,v)^-1 );
>      Print( [dom( p, scp(v,v)^-1 ), d] , "," );
>    od;  Print( "\n" );
[ 5, [ 26 ] ],[ -28, [  ] ],[ 1, [ 1 ] ],[ -22, [ 10 ] ],[ -16, [ 17 ] ],
[ -26, [  ] ],[ 20, [ 9 ] ],

######################################################################
gap> for i in [1,4] do           # we consider the 1. and 4. eigenspace
> for a in [0..p-1] do for b in [a..p-1] do
> v := evecs[i][1] + a* evecs[i][2];  w := evecs[i][1] + b* evecs[i][2];
>  if IsSubset( List([1..(p-1)/2], x -> (x*e)^2), [scp(v,v),scp(w,w)] )
>  then d1 :=  Filtered( [1..(p-1)/2], x -> (x*e)^2 = scp(v,v)^-1)[1];
>       d2 :=  Filtered( [1..(p-1)/2], x -> (x*e)^2 = scp(w,w)^-1)[1];
>   if IsInt(Size(G)/d1) and IsInt(Size(G)/d2) and scp(v,w) = 0 * Z(p)
>    and d1^2 + d2^2 < Size(G) - 9^2 - 10^2 then
>          Print([a,b],",",List(d1*v,x-> dom(p,x)),",",
>          List(d2*w,x-> dom(p,x)),"\n");
>   fi;
>  fi;
> od;od;
>    od;
[ 36, 48 ],[ 8, 0, -1, -1, 0, -17, 18 ],[ 8, 0, -1, -1, 0, 18, -17 ]
[ 12, 37 ],[ 5, 1, -1, 2, -1, 0, 0 ],[ 5, 1, 2, -1, -1, 0, 0 ]

######################################################################
gap> epsq := Z(p)^((p-1)/5);; phi := [ 8, 0, -1, -1, 0, -17, 18 ]*e;;
gap> for x in g{[6,7]} do
>  m := List( [0..4] , i -> dom( p, (5*e)^-1 * Sum( List( [0..4], j ->
>            phi[Position(cl,ConjugacyClass(G,x^j))] * epsq^(-i*j))) ) );
>  Print("chi(g_",Position(g,x),") = ", m*List([0..4],i->E(5)^i),"    ");
>  od;  Print( "\n" );
chi(g_6) = -E(5)^2-E(5)^3    chi(g_7) = -E(5)-E(5)^4    

######################################################################
gap> STOP_TEST( "example_2.4.5.tst" );
