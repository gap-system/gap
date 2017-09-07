gap> f := function() if true then return 1; elif true then return 2; else return 3; fi; end;;
gap> Print(f, "\n");
function (  )
    if true then
        return 1;
    elif true then
        return 2;
    else
        return 3;
    fi;
    return;
end
gap> f := function() if false then return 4; elif false then return 5; else return 6; fi; end;;
gap> Print(f, "\n");
function (  )
    if false then
        return 4;
    elif false then
        return 5;
    else
        return 6;
    fi;
    return;
end
