#
# Test the GAP function coder
#
gap> START_TEST("coding.tst");

#
# Test coding of if-statements in which some conditions are true or false
#
#

# test if-statements with single branch
gap> f:=function(x) if x then return 1; fi; end;; Display(f);
function ( x )
    if x then
        return 1;
    fi;
    return;
end
gap> f:=function(x) if true then return 1; fi; end;; Display(f);
function ( x )
    return 1;
end
gap> f:=function(x) if false then return 1; fi; end;; Display(f);
function ( x )
    ;
    return;
end

# test if-statements with two branches (note that 'else' is equivalent to 'elif true'),
# first condition is neither true nor false
gap> f:=function(x) if x then return 1; else return 2; fi; end;; Display(f);
function ( x )
    if x then
        return 1;
    else
        return 2;
    fi;
    return;
end
gap> f:=function(x) if x then return 1; elif x then return 2; fi; end;; Display(f);
function ( x )
    if x then
        return 1;
    elif x then
        return 2;
    fi;
    return;
end
gap> f:=function(x) if x then return 1; elif false then return 2; fi; end;; Display(f);
function ( x )
    if x then
        return 1;
    fi;
    return;
end

# test if-statements with two branches (note that 'else' is equivalent to 'elif true'),
# first condition is true
gap> f:=function(x) if true then return 1; else return 2; fi; end;; Display(f);
function ( x )
    return 1;
end
gap> f:=function(x) if true then return 1; elif x then return 2; fi; end;; Display(f);
function ( x )
    return 1;
end
gap> f:=function(x) if true then return 1; elif false then return 2; fi; end;; Display(f);
function ( x )
    return 1;
end

# test if-statements with two branches (note that 'else' is equivalent to 'elif true'),
# first condition is false
gap> f:=function(x) if false then return 1; else return 2; fi; end;; Display(f);
function ( x )
    return 2;
end
gap> f:=function(x) if false then return 1; elif x then return 2; fi; end;; Display(f);
function ( x )
    if x then
        return 2;
    fi;
    return;
end
gap> f:=function(x) if false then return 1; elif false then return 2; fi; end;; Display(f);
function ( x )
    ;
    return;
end

# test some if-statements with three branches
gap> f:=function(x) if true then return 1; elif true then return 2; else return 3; fi; end;; Display(f);
function ( x )
    return 1;
end
gap> f:=function(x) if true then return 1; elif x then return 2; else return 3; fi; end;; Display(f);
function ( x )
    return 1;
end
gap> f:=function(x) if x then return 1; elif true then return 2; else return 3; fi; end;; Display(f);
function ( x )
    if x then
        return 1;
    else
        return 2;
    fi;
    return;
end
gap> f:=function(x) if x then return 1; elif false then return 2; else return 3; fi; end;; Display(f);
function ( x )
    if x then
        return 1;
    else
        return 3;
    fi;
    return;
end
gap> f:=function(x) if false then return 1; elif true then return 2; else return 3; fi; end;; Display(f);
function ( x )
    return 2;
end
gap> f:=function(x) if false then return 1; elif x then return 2; else return 3; fi; end;; Display(f);
function ( x )
    if x then
        return 2;
    else
        return 3;
    fi;
    return;
end

#
gap> STOP_TEST("coding.tst", 1);
