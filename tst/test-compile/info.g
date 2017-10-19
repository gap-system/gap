runtest := function()
    Print(InfoLevel(InfoDebug),"\n");
    Info(InfoDebug, 2, "Do not print");
    Info(InfoDebug, 1, "print this A");
    SetInfoLevel(InfoDebug, 2);
    Print(InfoLevel(InfoDebug),"\n");
    Info(InfoDebug, 3, "Do not print");
    Info(InfoDebug, 2, "print this B");
    Info(InfoDebug, 1, "print this C");
end;
