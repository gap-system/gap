f := function()
    local i;
    for i in 1 do
        return 1;
    od;
    return 2;
end;;
f();
ContentsLVars(CurrentEnv());
DownEnv(); ContentsLVars(CurrentEnv());
DownEnv(); ContentsLVars(CurrentEnv());
quit;
