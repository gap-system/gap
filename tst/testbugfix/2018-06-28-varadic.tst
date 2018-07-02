gap> f := atomic function(readwrite a, readwrite b...)
>     return b;
> end;;
gap> f(1);
[  ]
gap> f(1, 2);
[ 2 ]
