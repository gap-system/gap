# The conservative stack scan of the garbage collector reads words at
# unaligned offsets, which UBSan builds reported as misaligned loads
gap> f := function(n)
>      local l;
>      l := List( [ 1 .. n ], i -> [ i ] );
>      GASMAN( "collect" );
>      return Sum( l, Sum );
>    end;;
gap> f(1000);
500500
