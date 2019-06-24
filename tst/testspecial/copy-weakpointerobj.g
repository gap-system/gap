# This test is in 'testspecial' as it allocates large objects
# so can cause a memory overflow in normal testing

f := function(l)
    l := List([1..l], x -> List([1..x], x -> x*x));
    return WeakPointerObj(l);
end;

tryImmutable := function(len)
    local w,l;
    GASMAN("collect");
    w := f(len);
    # Hope a GC occurs during this call
    l := Immutable(w);
    if Size(l) < len then
        # Caught mid-GC
        if ForAny([1..len], i -> IsBound(l[i]) and IsBound(w[i]) and l[i]<>w[i]) then
            Print("Invalid copy!\n");
        fi;
        # Exit test early
        QUIT_GAP();
    fi;
end;

len := 1000;
for loop in [1..10] do
    tryImmutable(len);
    len := len * 3;
od;

# If we never found a GC mid-copy, just exit. This could be bad luck,
# or we are not using GASMAN.
