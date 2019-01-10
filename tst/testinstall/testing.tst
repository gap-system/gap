# Some very basic tests of GAP's Test function
gap> START_TEST("testing.tst");
gap> Print("cheese\n"); Print("bacon"); Print("egg\n");
cheese
baconegg
gap> 2;
2
gap> x := 4;
4
gap> x;
4

#
# Statements where input + output are mixed
# Checks test can handle output directly cut+pasted from GAP's output
#
gap> x :=
> 2;
2
gap> x :=
> 2; y :=
2
> 3;
3
gap> if x = 2 then
>   Print("pass\n");
pass
> else
>   Print("fail\n");
> fi;

#
#
gap> STOP_TEST("testing.tst", 1);
