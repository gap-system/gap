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
Error, Jacobi: <n> must be an integer (not a boolean or fail)
gap> JACOBI_INT(1, fail);
Error, Jacobi: <m> must be an integer (not a boolean or fail)

#
gap> STOP_TEST( "numtheor.tst", 1);
