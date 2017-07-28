TimeDiff := function(t,t2)
    return (t2-t)*1.E-9;
end;

Bench := function(f)
    local tstart, tend;
    tstart := NanosecondsSinceEpoch();
    f();
    tend := NanosecondsSinceEpoch();
    return TimeDiff(tstart, tend);
end;
