# Test all kinds of basic features of the compiler, e.g.
# whether it compiles constants correctly.
runtest := function()
    local x, y;
    
    # integer constants between 2^28 and 2^60
    x := 10^10;
    Print(x, "\n");
    y := 10000000000;
    Print(y, "\n");
    Print(x = y, "\n");
    
    # integer constants > 2^60
    x := 10^20;
    Print(x, "\n");
    y := 100000000000000000000;
    Print(y, "\n");
    Print(x = y, "\n");

end;
