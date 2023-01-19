ReadGapRoot("benchmark/matobj/bench.g");

# test for old-style matrix constructors, as reference
TestCreatingMatrix := function(ring)
    PrintHeadline("NullMat");
    MyBench(function()
        local m, n, mat;
        for m in [1..10] do
            for n in [1..10] do
                mat := NullMat(m, n, ring);
            od;
        od;
    end);

    PrintHeadline("IdentityMat");
    MyBench(function()
        local n, mat;
        for n in [1..100] do
            mat := IdentityMat(n, ring);
        od;
    end);
end;

# test for matriobj constructors
TestCreatingMatrixObj := function(filter, ring)
    local example_mat;

    example_mat := NewZeroMatrix(filter, ring, 1, 1);

    PrintHeadline("NewZeroMatrix");
    MyBench(function()
        local m, n, mat;
        for m in [1..10] do
            for n in [1..10] do
                mat := NewZeroMatrix(filter, ring, m, n);
            od;
        od;
    end);

    PrintHeadline("ZeroMatrix( filt, R, m, n )");
    MyBench(function()
        local m, n, mat;
        for m in [1..10] do
            for n in [1..10] do
                mat := ZeroMatrix(filter, ring, m, n);
            od;
        od;
    end);

    PrintHeadline("ZeroMatrix( m, n, M )");
    MyBench(function()
        local m, n, mat;
        for m in [1..10] do
            for n in [1..10] do
                mat := ZeroMatrix(m, n, example_mat);
            od;
        od;
    end);

    PrintHeadline("NewIdentityMatrix");
    MyBench(function()
        local n, mat;
        for n in [1..100] do
            mat := NewIdentityMatrix(filter, ring, n);
        od;
    end);

    PrintHeadline("IdentityMatrix( filt, R, n )");
    MyBench(function()
        local n, mat;
        for n in [1..100] do
            mat := IdentityMatrix(filter, ring, n);
        od;
    end);

    PrintHeadline("IdentityMatrix( n, M )");
    MyBench(function()
        local n, mat;
        for n in [1..100] do
            mat := IdentityMatrix(n, example_mat);
        od;
    end);

    # TODO: NewMatrix
    # TODO: Matrix
end;

RunMatTest := function(desc, ring)
    Print("\n");
    PrintBoxed(Concatenation("Testing ", desc));
    TestCreatingMatrix(ring);
end;

RunMatTest("GF(2)", GF(2));
RunMatTest("Rationals", Rationals);

RunMatObjTest := function(desc, filter, ring)
    Print("\n");
    PrintBoxed(Concatenation("Testing ", desc));
    TestCreatingMatrixObj(filter, ring);
end;

RunMatObjTest("GF(2) IsPlistMatrixRep", IsPlistMatrixRep, GF(2));
RunMatObjTest("integer IsPlistMatrixRep", IsPlistMatrixRep, Integers);
RunMatObjTest("rational IsPlistMatrixRep", IsPlistMatrixRep, Rationals);

# TODO: other reps
# TODO: other compare with creating plist-of-plist
