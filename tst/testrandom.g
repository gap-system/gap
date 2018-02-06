randomTest := function(collection, method, checkin...)
    local test1, test2, test3, test4, test5, test6, localgen, checkmethod;
    if Length(checkin) = 0 then
        checkmethod := \in;
    else
        checkmethod := checkin[1];
    fi;

    # We do a single call first, to deal with calling Random causing extra attributes
    # of 'collection' to be set, changing the dispatch
    method(collection);

    # Firstly, we will generate a base list
    Init(GlobalMersenneTwister, 6);
    test1 := List([1..1000], x -> method(collection));
    # test2 should = test1
    Init(GlobalMersenneTwister, 6);
    test2 := List([1..1000], x -> method(collection));
    # test3 should also = test1
    Init(GlobalMersenneTwister, 6);
    test3 := List([1..1000], x -> method(GlobalMersenneTwister, collection));
    # test4 should be different (as it came from a different seed)
    Init(GlobalMersenneTwister, 8);
    test4 := List([1..1000], x -> method(collection));
    # test5 should be the same as test4, as it is made from seed 8
    # test6 should be the same as test1. Also, it checks that making test5
    # did not touch the global source at all.
    Init(GlobalMersenneTwister, 8);
    localgen :=  RandomSource(IsMersenneTwister, 6);
    test5 := List([1..1000], x -> method(localgen, collection));
    test6 := List([1..1000], x -> method(collection));
    if ForAny(Concatenation(test1, test2, test3, test4, test5, test6), x -> not (checkmethod(x, collection)) ) then
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
        Print("Random with a passed in seed affected the global generator: ", collection, "\n");
    fi;
end;;

# A special test for collections of size 1
randomTestForSizeOneCollection := function(collection, method)
    local i, val, localgen, intlist1, intlist2;
    if Size(collection) <> 1 then
        Print("randomTestForSizeOneCollection is only for collections of size 1");
        return;
    fi;

    val := Representative(collection);

    Init(GlobalMersenneTwister, 6);
    intlist1 := List([1..1000], x -> Random([1..10]));

    for i in [1..1000] do
        if method(collection) <> val then
            Print("Random returned something outside collection :", collection, ":", val);
        fi;
    od;

    for i in [1..1000] do
        if method(GlobalMersenneTwister, collection) <> val then
            Print("Random returned something outside collection :", collection, ":", val);
        fi;
    od;

    localgen := RandomSource(IsMersenneTwister, 6);

    Init(GlobalMersenneTwister, 6);
    for i in [1..1000] do
        if method(localgen, collection) <> val then
            Print("Random returned something outside collection :", collection, ":", val);
        fi;
    od;

    # The previous loop should not have affected GlobalMersenneTwister,
    # so this should be the same as intlist1
    intlist2 := List([1..1000], x -> Random([1..10]));

    if intlist1 <> intlist2 then
        Print("Random read from local gen affected global gen: ", collection);
    fi;
end;;
