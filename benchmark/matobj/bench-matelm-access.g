ReadGapRoot("benchmark/matobj/bench.g");


TestReadingMatrix := function(m)
    local f;

    PrintHeadline("m[i][j]");
    MyBench(function()
        local u, i, j, rows, cols, x;
        rows := [1..NrRows(m)];
        cols := [1..NrCols(m)];
        for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
            for i in rows do
                for j in cols do
                    x:=m[i][j];
                od;
            od;
        od;
    end);

    PrintHeadline("m[i,j]");
    MyBench(function()
        local u, i, j, rows, cols, x;
        rows := [1..NrRows(m)];
        cols := [1..NrCols(m)];
        for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
            for i in rows do
                for j in cols do
                    x:=m[i,j];
                od;
            od;
        od;
    end);

    PrintHeadline("MatElm(m,i,j)");
    MyBench(function()
        local u, i, j, rows, cols, x;
        rows := [1..NrRows(m)];
        cols := [1..NrCols(m)];
        for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
            for i in rows do
                for j in cols do
                    x:=MatElm(m,i,j);
                od;
            od;
        od;
    end);

    PrintHeadline("MatElm(m,i,j) with prefetched method");
    f:=ApplicableMethod(MatElm, [m,1,1]);;
    MyBench(function()
        local u, i, j, rows, cols, x;
        rows := [1..NrRows(m)];
        cols := [1..NrCols(m)];
        for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
            for i in rows do
                for j in cols do
                    x:=f(m,i,j);
                od;
            od;
        od;
    end);

end;

TestWritingMatrix := function(m)
    local f;

    PrintHeadline("m[i][j]:=elm");
    MyBench(function()
        local u, i, j, rows, cols, x;
        x:=m[1][1];
        rows := [1..NrRows(m)];
        cols := [1..NrCols(m)];
        for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
            for i in rows do
                for j in cols do
                    m[i][j]:=x;
                od;
            od;
        od;
    end);

    PrintHeadline("m[i,j]:=elm");
    MyBench(function()
        local u, i, j, rows, cols, x;
        x:=m[1][1];
        rows := [1..NrRows(m)];
        cols := [1..NrCols(m)];
        for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
            for i in rows do
                for j in cols do
                    m[i,j]:=x;
                od;
            od;
        od;
    end);

    PrintHeadline("SetMatElm(m,i,j,elm)");
    MyBench(function()
        local u, i, j, rows, cols, x;
        x:=m[1][1];
        rows := [1..NrRows(m)];
        cols := [1..NrCols(m)];
        for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
            for i in rows do
                for j in cols do
                    SetMatElm(m,i,j,x);
                od;
            od;
        od;
    end);

    PrintHeadline("SetMatElm(m,i,j,elm) with prefetched method");
    f:=ApplicableMethod(SetMatElm, [m,1,1,m[1][1]]);;
    MyBench(function()
        local u, i, j, rows, cols, x;
        x:=m[1][1];
        rows := [1..NrRows(m)];
        cols := [1..NrCols(m)];
        for u in [1..QuoInt(100000,NrRows(m)*NrCols(m))] do
            for i in rows do
                for j in cols do
                    f(m,i,j,x);
                od;
            od;
        od;
    end);
end;

RunMatTest := function(desc, m)
    Print("\n");
    PrintBoxed(Concatenation("Testing ", desc));
    TestReadingMatrix(m);
    Print(TextAttr.2, "...now testing write access...\n", TextAttr.reset);
    TestWritingMatrix(m);
end;

m:=IdentityMat(10,GF(257));;    # plain list of plain lists
RunMatTest("GF(257) plist-of-plist matrix", m);

m:=IdentityMatrix(GF(257), 10); # IsPlistMatrixRep
RunMatTest("GF(257) IsPlistMatrixRep", m);

m:=IdentityMatrix(GF(257), 10); # IsGenericMatrixRep
RunMatTest("GF(257) IsGenericMatrixRep", m);

m:=IdentityMat(10,GF(2));;      # plain list of IsGF2VectorRep
RunMatTest("GF(2) rowlist", m);

m:=IdentityMatrix(GF(2), 10);   # IsGF2MatrixRep
RunMatTest("GF(2) compressed matrix", m);

m:=IdentityMat(10,GF(7));;      # plain list of Is8BitVectorRep
RunMatTest("GF(7) rowlist", m);

m:=IdentityMatrix(GF(7), 10);   # Is8BitMatrixRep
RunMatTest("GF(7) compressed matrix", m);
