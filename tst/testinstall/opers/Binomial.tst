gap> START_TEST("Binomial.tst");

#
gap> Binomial_GAP := function ( n, k )
>     local   bin, i, j;
>     if   k < 0  then
>         bin := 0;
>     elif k = 0  then
>         bin := 1;
>     elif n < 0  then
>         bin := (-1)^k * Binomial_GAP( -n+k-1, k );
>     elif n < k  then
>         bin := 0;
>     elif n = k  then
>         bin := 1;
>     elif n-k < k  then
>         bin := Binomial_GAP( n, n-k );
>     else
>         bin := 1;  j := 1;
>         for i  in [0..k-1]  do
>             bin := bin * (n-i) / j;
>             j := j + 1;
>         od;
>     fi;
>     return bin;
> end;;

# compared C Binomial against GAP version
gap> ForAll([-100..100], n->ForAll([-1..100],
>       k->Binomial_GAP(n,k) = BINOMIAL_INT(n,k)));
true

#
gap> STOP_TEST("Binomial.tst", 1);
