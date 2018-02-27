# Perform a variety of tests on Random Sources and functions which create
# random objects.
#
# This function is used for a variety is different tests:
#
# Test that 'Random(C)' and 'Random(GlobalMersenneTwister, C)' produce 
# the same answer.
#
# Test that 'Random(rs,C)' only uses 'rs', and no other source of random
#
# Test Random and RandomList
#
# Where there is a global instance of a random source
# (GlobalMersenneTwister and GlobalRandomSource), they produce the same
# sequence of answers as a new instance of the same random source.

# filter: The type of random source we are testing.
# global_rs: A pre-existing object of type 'filter'.
# randfunc(rs, C): A two argument function which creates random elements of C using
#              'rs' as the source.
# global_randfunc(C): A one argument function which is equivalent to 
#             {x} -> rand(global_rs, x). This lets us check 'Random(C)' and
#             'Random(GlobalMersenneTwister,C)' produce the same answer when testing
#             GlobalMersenneTwister. For other random sources, this can just
#             be set to {x} -> rand(global_rs,x).
# collection: The object (usually a collection) to find random members of.
# checkin(e, C): returns if e is in C (usually checkin is '\in').

randomTestInner := function(filter, global_rs, global_randfunc, randfunc, collection, checkin)
    local test1, test2, test3, test4, test5, test6, local_rs;

    # We do a single call first, to deal with calling Random causing extra attributes
    # of 'collection' to be set, changing the dispatch
    randfunc(collection);

    # Firstly, we will generate a base list
    Init(global_rs, 6);
    test1 := List([1..1000], x -> global_randfunc(collection));
    # test2 should equal test1
    Init(global_rs, 6);
    test2 := List([1..1000], x -> global_randfunc(collection));
    # test3 should also = test1
    Init(global_rs, 6);
    test3 := List([1..1000], x -> randfunc(global_rs, collection));
    # test4 should be different (as it came from a different seed)
    Init(global_rs, 8);
    test4 := List([1..1000], x -> global_randfunc(collection));
    # test5 should be the same as test4, as it is made from seed 8
    # test6 should be the same as test1. Also, it checks that making test5
    # did not touch the global source at all.
    Init(global_rs, 8);
    local_rs :=  RandomSource(filter, 6);
    test5 := List([1..1000], x -> randfunc(local_rs, collection));
    test6 := List([1..1000], x -> global_randfunc(collection));
    if ForAny(Concatenation(test1, test2, test3, test4, test5, test6), x -> not (checkin(x, collection)) ) then
        Print("Random member outside collection: ", collection,"\n");
    fi;
    if test1 <> test2 then
        Print("Random not repeatable: ", collection, "\n");
    fi;
    if test2 <> test3 then
        Print("Random 2-arg vs 1-arg broken: ", collection, "\n");
    fi;
    if test1 = test4 then
        Print("Random not changing with random seed: ", collection, "\n");
    fi;
    if test1 <> test5 then
        Print("Alt gen broken: ", collection, "\n");
    fi;
    if test4 <> test6 then
        Print("Random with a passed in seed affected the global source: ", collection, "\n");
    fi;
end;;


# A special test for collections of size 1
# Here we can't check different seeds produce different answers
# We do check that the random source is not used, for efficency.
randomTestForSizeOneCollectionInner := function(filter, global_rs, global_randfunc, randfunc, collection, checkin)
    local i, val, local_rs, intlist1, intlist2;

    val := Representative(collection);

    Init(global_rs, 6);
    intlist1 := List([1..10], x -> global_randfunc([1..1000]));

    for i in [1..100] do
        if global_randfunc(collection) <> val then
            Print("Random returned something outside collection :", collection, ":", val);
        fi;
    od;

    for i in [1..100] do
        if randfunc(global_rs, collection) <> val then
            Print("Random returned something outside collection :", collection, ":", val);
        fi;
    od;

    local_rs := RandomSource(filter, 6);

    Init(global_rs, 6);
    for i in [1..100] do
        if randfunc(local_rs, collection) <> val then
            Print("Random returned something outside collection :", collection, ":", val);
        fi;
    od;

    # The previous loop should not have affected global_rs,
    # so this should be the same as intlist1
    intlist2 := List([1..10], x -> global_randfunc([1..1000]));

    if intlist1 <> intlist2 then
        Print("Random read from local gen affected global gen: ", collection);
    fi;
end;;


randomTest := function(collection, randfunc, checkin...)
    local sizeone, randchecker;
    if Length(checkin) = 0 then
        checkin := \in;
    else
        checkin := checkin[1];
    fi;

    # Make a best attempt to find if the collection is size 1.
    # There are implementations of random for objects which do not support
    # Size or IsTrivial, e.g. PadicExtensionNumberFamily
    if IsList(collection) then
        sizeone := (Size(collection) = 1);
    elif IsCollection(collection) then
        sizeone := IsTrivial(collection);
    else
        sizeone := false;
    fi;

    if sizeone then
        randchecker := randomTestForSizeOneCollectionInner;
    else
        randchecker := randomTestInner;
    fi;

    randchecker(IsMersenneTwister,
        GlobalMersenneTwister, x -> randfunc(x), randfunc, collection, checkin);
    randchecker(IsGAPRandomSource,
        GlobalRandomSource, x -> randfunc(GlobalRandomSource, x), randfunc,
        collection, checkin);
end;
