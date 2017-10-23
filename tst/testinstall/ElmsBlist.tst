gap> START_TEST("ElmsBlist.tst");
gap> doTests := function(startrange, lengthrange)
>    local source, s, l, copy, i;    
>    source := BlistStringDecode("DEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEFDEADBEEF");
>    for s in startrange do
>       for l in lengthrange do
>            copy := source{[s..s+l-1]};
>            for i in [1..l] do
>                if copy[i] <> source[s+i-1] then
>                    Error("Test failed");
>                fi;
>            od;
>        od;
>    od;
> end;;
gap> doTests([1..64],[0..128]);
gap> STOP_TEST("ElmsBlist.tst", 1);
