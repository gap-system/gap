gap> START_TEST("HexStringBlist.tst");

# Test corner cases
gap> HexStringBlist([]);
""
gap> HexStringBlistEncode([]);
""
gap> BlistStringDecode("");
[  ]

# De- and encode without "run length compression"
gap> for i in [0..9] do
>   tups := Tuples([true,false],i);
>   Sort(tups);
>   for j in [1..Length(tups)] do
>     str := HexStringBlist(tups[j]);
>     tup := BlistStringDecode(str);
>     len := QuoInt(i+7, 8) * 8;
>     tup2 := Concatenation(tups[j], ListWithIdenticalEntries(len-i,false));
>     if tup <> tup2 then
>       Error("BlistStringDecode(HexStringBlist(",tups[j],")) = ",tup,"\n");
>     fi;
>     str2 := HexStringBlist(tup);
>     if str <> str2 then
>       Error("HexStringBlist(BlistStringDecode(",str,")) = ",str2,"\n");
>     fi;
>   od;
> od;

# Test "run length encoding"
gap> BlistStringDecode("s01");
[ false, false, false, false, false, false, false, false ]
gap> BlistStringDecode("s02");
[ false, false, false, false, false, false, false, false, false, false, 
  false, false, false, false, false, false ]
gap> HexStringBlistEncode(BlistStringDecode("s03"));
""
gap> HexStringBlistEncode(BlistStringDecode("10000000F1"));
"10s03F1"

#
gap> STOP_TEST("HexStringBlist.tst", 1);
