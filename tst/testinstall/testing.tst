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

# if statements
gap> z := 0;;
#@if true
gap> z := 1;;
#@fi
gap> z;
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@fi
gap> z;
0

# if else statements
gap> z := 0;;
#@if true
gap> z := 1;;
#@else
gap> z := 2;;
#@fi
gap> z;
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@else
gap> z := 2;;
#@fi
gap> z;
2

# if elif statements
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif false
gap> z := 2;;
#@fi
gap> z; # FF
0
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif false
gap> z := 2;;
#@fi
gap> z; # TF
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif true
gap> z := 2;;
#@fi
gap> z; # FT
2
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif true
gap> z := 2;;
#@fi
gap> z; # TT
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif false
gap> z := 2;;
#@elif false
gap> z := 3;;
#@fi
gap> z; # FFF
0
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif false
gap> z := 2;;
#@elif false
gap> z := 3;;
#@fi
gap> z; # TFF
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif true
gap> z := 2;;
#@elif false
gap> z := 3;;
#@fi
gap> z; # FTF
2
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif true
gap> z := 2;;
#@elif false
gap> z := 3;;
#@fi
gap> z; # TTF
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif false
gap> z := 2;;
#@elif true
gap> z := 3;;
#@fi
gap> z; # FFT
3
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif false
gap> z := 2;;
#@elif true
gap> z := 3;;
#@fi
gap> z; # TFT
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif true
gap> z := 2;;
#@elif true
gap> z := 3;;
#@fi
gap> z; # FTT
2
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif true
gap> z := 2;;
#@elif true
gap> z := 3;;
#@fi
gap> z; # TTT
1

# if elif else statement
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif false
gap> z := 2;;
#@else
gap> z := 3;;
#@fi
gap> z; # FF
3
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif false
gap> z := 2;;
#@else
gap> z := 3;;
#@fi
gap> z; # TF
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif true
gap> z := 2;;
#@else
gap> z := 3;;
#@fi
gap> z; # FT
2
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif true
gap> z := 2;;
#@else
gap> z := 3;;
#@fi
gap> z; # TT
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif false
gap> z := 2;;
#@elif false
gap> z := 3;;
#@else
gap> z := 4;;
#@fi
gap> z; # FFF
4
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif false
gap> z := 2;;
#@elif false
gap> z := 3;;
#@else
gap> z := 4;;
#@fi
gap> z; # TFF
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif true
gap> z := 2;;
#@elif false
gap> z := 3;;
#@else
gap> z := 4;;
#@fi
gap> z; # FTF
2
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif true
gap> z := 2;;
#@elif false
gap> z := 3;;
#@else
gap> z := 4;;
#@fi
gap> z; # TTF
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif false
gap> z := 2;;
#@elif true
gap> z := 3;;
#@else
gap> z := 4;;
#@fi
gap> z; # FFT
3
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif false
gap> z := 2;;
#@elif true
gap> z := 3;;
#@else
gap> z := 4;;
#@fi
gap> z; # TFT
1
gap> z := 0;;
#@if false
gap> z := 1;;
#@elif true
gap> z := 2;;
#@elif true
gap> z := 3;;
#@else
gap> z := 4;;
#@fi
gap> z; # FTT
2
gap> z := 0;;
#@if true
gap> z := 1;;
#@elif true
gap> z := 2;;
#@elif true
gap> z := 3;;
#@else
gap> z := 4;;
#@fi
gap> z; # TTT
1

#
#
gap> STOP_TEST("testing.tst");
