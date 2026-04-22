ReadGapRoot("benchmark/matobj/bench.g");


TestExtractingSubmatrix := function(m)
    local rows, cols;

    rows := [2..NrRows(m)-2];
    cols := [3..NrCols(m)-1];

    if not IsPlistMatrixRep(m) then
        PrintHeadline("m{}{}");
        MyBench(function()
            local u, x;
            for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
                x:=m{rows}{cols};
            od;
        end);
    fi;

    PrintHeadline("ExtractSubMatrix");
    MyBench(function()
        local u, x;
        for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
            x:=ExtractSubMatrix(m, rows, cols);
        od;
    end);

end;

TestCopyingSubmatrix := function(m)
    local x, rows, cols;

    x := MutableCopyMat(m);
    rows := [2..NrRows(m)-2];
    cols := [3..NrCols(m)-1];

    if not IsPlistMatrixRep(m) then
        PrintHeadline("m{}{}:=n{}{}");
        MyBench(function()
            local u;
            for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
                x{rows}{cols}:=m{rows}{cols};
            od;
        end);
    fi;

    PrintHeadline("CopySubMatrix");
    MyBench(function()
        local u;
        for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
            CopySubMatrix(m, x, rows, cols, rows, cols);
        od;
    end);

end;

RunMatTest := function(desc, m)
    Print("\n");
    PrintBoxed(Concatenation("Testing submatrix extraction for ", desc));
    TestExtractingSubmatrix(m);
    Print(TextAttr.2, "...now testing submatrix copying...\n", TextAttr.reset);
    TestCopyingSubmatrix(m);
end;

for dim in [10, 100] do
    PrintBoxed(Concatenation("Now testing in dimension ", String(dim)));

    m:=IdentityMat(dim);;
    RunMatTest("integer matrix: list of lists", m);

    m:=IdentityMatrix(Integers, dim);;
    RunMatTest("integer matrix: IsPlistMatrixRep", m);

    m:=IdentityMat(dim,GF(2));;
    RunMatTest("GF(2) rowlist", m);

    m:=IdentityMatrix(GF(2), dim);;
    RunMatTest("GF(2) compressed matrix", m);

    m:=IdentityMat(dim,GF(7));;
    RunMatTest("GF(7) rowlist", m);

    m:=IdentityMatrix(GF(8), dim);;
    RunMatTest("GF(7) compressed matrix", m);

# TODO: also add cvec matrices
od;
