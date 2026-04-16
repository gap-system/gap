ReadGapRoot("benchmark/matobj/bench.g");


TestExtractingSubvector := function(v)
    local cols;

    cols := [3..Length(v)-1];

    if not IsPlistVectorRep(v) then
        PrintHeadline("v{}");
        MyBench(function()
            local u, x;
            for u in [1..QuoInt(100000, Length(v))] do
                x := v{cols};
            od;
        end);
    fi;

    PrintHeadline("ExtractSubVector");
    MyBench(function()
        local u, x;
        for u in [1..QuoInt(100000, Length(v))] do
            x := ExtractSubVector(v, cols);
        od;
    end);
end;

TestCopyingSubvector := function(v)
    local x, cols;

    x := ShallowCopy(v);
    cols := [3..Length(v)-1];

    if not IsPlistVectorRep(v) then
        PrintHeadline("x{}:=v{}");
        MyBench(function()
            local u;
            for u in [1..QuoInt(100000, Length(v))] do
                x{cols} := v{cols};
            od;
        end);
    fi;

    PrintHeadline("CopySubVector");
    MyBench(function()
        local u;
        for u in [1..QuoInt(100000, Length(v))] do
            CopySubVector(v, x, cols, cols);
        od;
    end);
end;

RunVecTest := function(desc, v)
    Print("\n");
    PrintBoxed(Concatenation("Testing subvector extraction for ", desc));
    TestExtractingSubvector(v);
    Print(TextAttr.2, "...now testing subvector copying...\n", TextAttr.reset);
    TestCopyingSubvector(v);
end;

for dim in [10, 100] do
    PrintBoxed(Concatenation("Now testing in dimension ", String(dim)));

    v := [1..dim] * 0;;
    RunVecTest("integer vector: plain list", v);

    v := Vector(IsPlistVectorRep, Integers, [1..dim]);;
    RunVecTest("integer vector: IsPlistVectorRep", v);

    v := [1..dim] * One(GF(2));;
    RunVecTest("GF(2) row vector", v);

    v := NewVector(IsGF2VectorRep, GF(2), [1..dim] * One(GF(2)));;
    RunVecTest("GF(2) compressed vector", v);

    v := [1..dim] * One(GF(7));;
    RunVecTest("GF(7) row vector", v);

    v := NewVector(Is8BitVectorRep, GF(7), [1..dim] * One(GF(7)));;
    RunVecTest("GF(7) 8-bit vector", v);
od;
