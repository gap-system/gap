gap> START_TEST("method-reordering.tst");
gap> CheckReorder := function(explicit)
>    local  f1, f2, f3, myOp, fam, t, o, o2, myC;
>    CHECK_ALL_METHOD_RANKS();
>    f1 := NewFilter("filter1",100);
>    f2 := NewFilter("filter1",10);
>    f3 := NewFilter("filter1",1);
>    myOp := NewOperation("myOp", [IsObject]);
>    myC := NewConstructor("myC", [IsObject]);
>    InstallMethod(myOp, "meth1", [f2], x ->1);
>    InstallMethod(myOp, "meth2", [f3], x ->2);
>    fam := NewFamily("myFam");
>    t := NewType(fam, IsComponentObjectRep and f2 and f3);
>    o := Objectify(t, rec());
>    o2 := Objectify(t, rec());
>    InstallMethod(myC, "cons1", [f2], x ->o);
>    InstallMethod(myC, "cons2", [f3], x ->o2);
>    if myOp(o) <> 1 or not IsIdenticalObj(myC(IsObject),o2) then
>        Error("Initial method selection wrong");
>    fi;
>    InstallTrueMethod(f1,f3);
>    if explicit then
>        RECALCULATE_ALL_METHOD_RANKS();
>    fi;
>    return IsIdenticalObj(myC(IsObject),o) and myOp(o) = 2;
> end;;
gap> CheckReorder(false);
true
gap> SuspendMethodReordering();
gap> CheckReorder(false);
false
gap> CheckReorder(true);
true
gap> CHECK_ALL_METHOD_RANKS();
true
gap> ResumeMethodReordering();
gap> CHECK_ALL_METHOD_RANKS();
true
gap> Unbind(CheckReorder);
gap> STOP_TEST("method-reordering.tst");
