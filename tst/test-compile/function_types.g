f1 := function(a)
    Print("f1:",a,"\n");
end;

f2 := function(a,b)
    Print("f2:",a,":",b,"\n");
end;

f3 := function(a...)
    Print("f3:",a,"\n");
end;

f4 := function(a,b...)
    Print("f4:",a, ":",b, "\n");
end;

runtest := function()
    f1(2);
    f2(2,3);
    f3();
    f3(2);
    f3(2,3,4);
    f4(1);
    f4(1,2);
    f4(1,2,3);

    BreakOnError := false;

    CALL_WITH_CATCH({} -> f1(), []);
    CALL_WITH_CATCH({} -> f1(1,2), []);
    CALL_WITH_CATCH({} -> f2(1,2,3), []);
    CALL_WITH_CATCH({} -> f4(), []);

end;
