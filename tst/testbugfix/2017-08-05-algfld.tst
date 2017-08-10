#
# AlgebraicExtension used to fail for finite fields of size over 256
#
gap> algexttest := function(q, i1, i2)
>    local f,x,pol;    
>    f := GF(q);
>    x :=Indeterminate(f,"x");
>    pol := x^2+Z(q)^i1*x+Z(q)^i2;
>    AlgebraicExtension(f,pol);
> end;;
gap> algexttest(1009,108,864); # from bug report
gap> algexttest(1024,1023,5);  # prime under 256, field size over
gap> algexttest(65537,1,1);    # prime over 2^16
gap> algexttest(3^11,1,6);     # prime under 2^16, field over
