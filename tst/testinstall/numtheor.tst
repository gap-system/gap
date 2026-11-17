#@local JACOBI_INT_GAP,c,d,jac,k,m,n,oldLevel,t
gap> START_TEST("numtheor.tst");

# RootMod, RootsMod
#
# Check issue #758: do not force full factorization for RootMod.
# It suffices to factor into strong Fermat primes.
gap> oldLevel := InfoLevel(InfoPrimeInt);;
gap> SetInfoLevel(InfoPrimeInt, 0); # turn off warnings
gap> c := 87665785060273447596735547586847436354365986897267;;
gap> d := 5676193656034756392656593936564928264920283748503726385950382638505826243749593626948538293405737101;;
gap> RootMod(c,d); 
fail
gap> n:=2^2203-1;; RootMod(39,n);
fail

#
# RootsUnityMod, also for composite k and moduli where p divides k
gap> RootsUnityMod( 4, 15 );
[ 1, 2, 4, 7, 8, 11, 13, 14 ]
gap> RootsUnityMod( 6, 7 );
[ 1, 2, 3, 4, 5, 6 ]
gap> RootsUnityMod( 6, 9 );
[ 1, 2, 4, 5, 7, 8 ]
gap> RootsUnityMod( 1, 1 );
[ 0 ]
gap> ForAll( [ 1 .. 130 ], m -> ForAll( [ 1 .. 66 ], k -> RootsUnityMod( k, m )
>      = Filtered( [ 0 .. m - 1 ], r -> PowerModInt( r, k, m ) = 1 mod m ) ) );
true
gap> ForAll( [ 2^9, 3^5, 5^4, 7^3, 2^4 * 3^3 * 5 ], m -> ForAll( [ 1 .. 50 ],
>      k -> RootsUnityMod( k, m )
>      = Filtered( [ 0 .. m - 1 ], r -> PowerModInt( r, k, m ) = 1 ) ) );
true
gap> RootsUnityMod( 2^100, 3^50 ) = [ 1, 3^50 - 1 ];
true
gap> Length( RootsUnityMod( 8, 2^100 ) );
16
gap> Length( RootsUnityMod( 12, 1009 * 2^20 ) );
96

#
# PValuation
#
gap> PValuation(0,2);
infinity
gap> PValuation(0,3);
infinity

#
gap> PValuation(100,2);
2
gap> PValuation(100,3);
0
gap> PValuation(13/85,5);
-1

#
# Compare GAP and C implementations of Jacobi()
#
gap> JACOBI_INT_GAP := function ( n, m )
>     local  jac, t;
> 
>     # check the argument
>     if m <= 0  then Error("<m> must be positive");  fi;
> 
>     # compute the Jacobi symbol similar to Euclid's algorithm
>     jac := 1;
>     while m <> 1  do
> 
>         # if the gcd of $n$ and $m$ is $>1$ Jacobi returns $0$
>         if n = 0 or (n mod 2 = 0 and m mod 2 = 0)  then
>             jac := 0;  m := 1;
> 
>         # $J(n,2*m) = J(n,m) * J(n,2) = J(n,m) * (-1)^{(n^2-1)/8}$
>         elif m mod 2 = 0  then
>             if n mod 8 = 3  or  n mod 8 = 5  then jac := -jac;  fi;
>             m := m / 2;
> 
>         # $J(2*n,m) = J(n,m) * J(2,m) = J(n,m) * (-1)^{(m^2-1)/8}$
>         elif n mod 2 = 0  then
>             if m mod 8 = 3  or  m mod 8 = 5  then jac := -jac;  fi;
>             n := n / 2;
> 
>         # $J(-n,m) = J(n,m) * J(-1,m) = J(n,m) * (-1)^{(m-1)/2}$
>         elif n < 0  then
>             if m mod 4 = 3  then jac := -jac;  fi;
>             n := -n;
> 
>         # $J(n,m) = J(m,n) * (-1)^{(n-1)*(m-1)/4}$ (quadratic reciprocity)
>         else
>             if n mod 4 = 3  and m mod 4 = 3  then jac := -jac;  fi;
>             t := n;  n := m mod n;  m := t;
> 
>         fi;
>     od;
> 
>     return jac;
> end;;
gap> ForAll([-100 .. 100], a-> ForAll([1 .. 100], b -> JACOBI_INT_GAP(a,b)=JACOBI_INT(a,b)));
true
gap> JACOBI_INT(fail, 1);
Error, JACOBI_INT: <n> must be an integer (not the value 'fail')
gap> JACOBI_INT(1, fail);
Error, JACOBI_INT: <m> must be an integer (not the value 'fail')

#
gap> STOP_TEST("numtheor.tst");
