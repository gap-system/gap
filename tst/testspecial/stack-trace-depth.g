f11 := function()
    Error("foo");
end;;
f10 := function()
    return f11();
end;;
f9 := function()
    return f10();
end;;
f8 := function()
    return f9();
end;;
f7 := function()
    return f8();
end;;
f6 := function()
    return f7();
end;;
f5 := function()
    return f6();
end;;
f4 := function()
    return f5();
end;;
f3 := function()
    return f4();
end;;
f2 := function()
    return f3();
end;;
f1 := function()
    return f2();
end;;
f1();
Where(12);
quit;
