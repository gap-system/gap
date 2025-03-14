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

m:=IdentityMat(10);;
RunMatTest("integer matrix", m);

m:=IdentityMat(10,GF(2));;
RunMatTest("GF(2) rowlist", m);

m:=IdentityMat(10,GF(2));; ConvertToMatrixRep(m);;
RunMatTest("GF(2) compressed matrix", m);

m:=IdentityMat(10,GF(7));;
RunMatTest("GF(7) rowlist", m);

m:=IdentityMat(10,GF(7));; ConvertToMatrixRep(m);;
RunMatTest("GF(7) compressed matrix", m);
