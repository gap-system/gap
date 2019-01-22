range2 := {a,b} -> [a..b];
range3 := {a,b,c} -> [a,b..c];

runtest := function()

    # ensure we don't abort after an error
    BreakOnError := false;

    CALL_WITH_CATCH(range2, [1, 2^80]);
    CALL_WITH_CATCH(range2, [-2^80, 0]);

    CALL_WITH_CATCH(range3, [1,2, 2^80]);
    CALL_WITH_CATCH(range3, [-2^80,0, 1]);
    CALL_WITH_CATCH(range3, [0,2^80,2^81]);

    Display([1,2..2]);
    CALL_WITH_CATCH(range3, [2,2,2]);
    Display([2,4..6]);
    CALL_WITH_CATCH(range3, [2,4,7]);
    Display([2,4..2]);
    Display([2,4..0]);
    CALL_WITH_CATCH(range3, [4,2,1]);
    Display([4,2..0]);
    Display([4,2..8]);

end;
