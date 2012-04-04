LoadPackage("io");

# This is silly, since the communication dominates everything timewise,
# and in actual fact we serialise this. But nevertheless, it works:

l := [1..1000000]*2;

ll := ParListByFork(l,function(x) return x^2; end,
                    rec( NumberJobs := 3 ));
if ll <> List(l,x->x^2) then
    Error("did not work");
fi;

