# 2006/02/14 (SK)
gap> testG :=
>    function ( a, b )
>      local  M1;
>       M1 := [ [ [      0, -E(a)^-1 ], [ -E(a),       0 ] ],
>               [ [      0,       -1 ], [     1,       0 ] ],
>               [ [ E(4*b),        0 ], [     0, -E(4*b) ] ],
>               [ [     -1,        0 ], [     0,      -1 ] ]];
>       return (Group(M1));
>    end;;
gap> StructureDescription(testG(8,2):nice);
"(C8 x C4) : C2"
gap> StructureDescription(testG(8,3));
"C3 x QD16"
gap> StructureDescription(testG(8,4):nice);
"(C16 x C4) : C2"
