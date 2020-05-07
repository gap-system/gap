f := function() local x; x := f(); return x; end;
y := f();
return; # try once more
