ReadGapRoot("benchmark/matobj/bench.g");


TestCreatingVector := function(v)
    Error("TODO");
end;

# test for old-style vector constructors, as reference
TestCreatingVector := function(ring)
    PrintHeadline("ListWithIdenticalEntries");
    MyBench(function()
        local n, vec;
        for n in [1..10] do
            vec := ListWithIdenticalEntries(n, Zero(ring));
        od;
    end);

    PrintHeadline("ListWithIdenticalEntries + ConvertToVectorRepNC");
    MyBench(function()
        local n, vec;
        for n in [1..10] do
            vec := ListWithIdenticalEntries(n, Zero(ring));
            ConvertToVectorRepNC(vec, ring);
        od;
    end);
end;

# test for VectorObj constructors
TestCreatingVectorObj := function(filter, ring)
    local example_vec;

    example_vec := NewZeroVector(filter, ring, 1);

    PrintHeadline("NewZeroVector( filt, R, n )");
    MyBench(function()
        local n, vec;
        for n in [1..10] do
            vec := NewZeroVector(filter, ring, n);
        od;
    end);

    PrintHeadline("ZeroVector( filt, R, n )");
    MyBench(function()
        local n, vec;
        for n in [1..10] do
            vec := ZeroVector(filter, ring, n);
        od;
    end);

    PrintHeadline("ZeroVector( n, M )");
    MyBench(function()
        local n, vec;
        for n in [1..10] do
            vec := ZeroVector(n, example_vec);
        od;
    end);

    # TODO: NewVector
    # TODO: Vector
end;

RunMatTest := function(desc, ring)
    Print("\n");
    PrintBoxed(Concatenation("Testing ", desc));
    TestCreatingVector(ring);
end;

RunMatTest("GF(2)", GF(2));
RunMatTest("Rationals", Rationals);

RunMatObjTest := function(desc, filter, ring)
    Print("\n");
    PrintBoxed(Concatenation("Testing ", desc));
    TestCreatingVectorObj(filter, ring);
end;

RunMatObjTest("GF(2) IsPlistVectorRep", IsPlistVectorRep, GF(2));
RunMatObjTest("integer IsPlistVectorRep", IsPlistVectorRep, Integers);
RunMatObjTest("rational IsPlistVectorRep", IsPlistVectorRep, Rationals);

# TODO: other reps
# TODO: other compare with creating plist-of-plist
