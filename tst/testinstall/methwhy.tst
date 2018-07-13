gap> START_TEST("methwy.tst");

#
gap> ApplicableMethod();
Error, usage: ApplicableMethod(<opr>,<arglist>[,<verbosity>[,<nr>]])

#
gap> foobar := NewOperation("foobar", [IsObject]);
<Operation "foobar">
gap> InstallMethod(foobar, "for an integer", [IsInt], 1-RankFilter(IsInt), x -> 1);
gap> InstallMethod(foobar, "for a list", [IsList], 42-RankFilter(IsList), Length);
gap> InstallMethod(foobar, "for a string", [IsString], 2*SUM_FLAGS+1-RankFilter(IsString), x -> StartsWith(x, "foo"));
gap> InstallMethod(foobar, [IsObject], x -> fail); # fallback with no info string

# also install multi argument methods, to make sure that there
# is no bug which just happens to work with 1 argument
gap> InstallOtherMethod(foobar, "for two lists", [IsList, IsList], 17-2*RankFilter(IsList), Concatenation);
gap> InstallOtherMethod(foobar, "for no argument", [], {}->1);

# small trick to ensure the various methods get different locations
gap> Read(InputTextString("""
> InstallOtherMethod(foobar, "for 2 integers", [IsInt, IsInt], -2*RankFilter(IsInt), {x,y...}->1);
> InstallOtherMethod(foobar, "for 3 integers", [IsInt, IsInt, IsInt], -3*RankFilter(IsInt), {x,y...}->1);
> InstallOtherMethod(foobar, "for 4 integers", [IsInt, IsInt, IsInt, IsInt], -4*RankFilter(IsInt), {x,y...}->1);
> InstallOtherMethod(foobar, "for 5 integers", [IsInt, IsInt, IsInt, IsInt, IsInt], -5*RankFilter(IsInt), {x,y...}->1);
> InstallOtherMethod(foobar, "for 6 integers", [IsInt, IsInt, IsInt, IsInt, IsInt, IsInt], -6*RankFilter(IsInt), {x,y...}->1);
> """));

#
#
#
gap> Display(ApplicableMethod(foobar, [1]));
function ( x )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [ ['a'] ], 1));
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries
#I  Method 1: ``foobar: for a string'' at stream:1 , value: 2*SUM_FLAGS+1
function ( x )
    return StartsWith( x, "foo" );
end
gap> Display(ApplicableMethod(foobar, [ ['a'] ], 1, 2));
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries
#I  Method 1: ``foobar: for a string'' at stream:1 , value: 2*SUM_FLAGS+1
#I  Skipped:
#I  Method 2: ``foobar: for a list'' at stream:1 , value: 42
<Attribute "Length">
gap> Display(ApplicableMethod(foobar, [fail], 1));
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries
#I  Method 4: ``foobar'' at stream:1 , value: 0
function ( x )
    return fail;
end
gap> Display(ApplicableMethod(foobar, [fail], 4));
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries
#I  Method 1: ``foobar: for a string'' at stream:1, value: 2*SUM_FLAGS+1
#I   - 1st argument needs [ "IsString" ]
#I  Method 2: ``foobar: for a list'' at stream:1, value: 42
#I   - 1st argument needs [ "IsList" ]
#I  Method 3: ``foobar: for an integer'' at stream:1, value: 1
#I   - 1st argument needs [ "IsInt" ]
#I  Method 4: ``foobar'' at stream:1, value: 0
function ( x )
    return fail;
end
gap> ApplicableMethod(foobar, [fail], 6);; Print("\n");
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries
#I  Method 1: ``foobar: for a string'' at stream:1, value: 2*SUM_FLAGS+1
#I   - 1st argument needs [ "IsString" ]
#I  Method 2: ``foobar: for a list'' at stream:1, value: 42
#I   - 1st argument needs [ "IsList" ]
#I  Method 3: ``foobar: for an integer'' at stream:1, value: 1
#I   - 1st argument needs [ "IsInt" ]
#I  Method 4: ``foobar'' at stream:1, value: 0
#I  Function Body:
function ( x )
    return fail;
end

#
# Test other methods with two args
#
gap> Display(ApplicableMethod(foobar, [1, 2]));
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1, 2], 1));
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries
#I  Method 2: ``foobar: for 2 integers'' at stream:2 , value: 0
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1, 2], 2));
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries
#I  Method 1: ``foobar: for two lists'' at stream:1, value: 17
#I  Method 2: ``foobar: for 2 integers'' at stream:2, value: 0
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1, 2], 3));
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries
#I  Method 1: ``foobar: for two lists'' at stream:1, value: 17
#I   - 1st argument needs [ "IsList" ]
#I  Method 2: ``foobar: for 2 integers'' at stream:2, value: 0
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1, 2], 4));
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries
#I  Method 1: ``foobar: for two lists'' at stream:1, value: 17
#I   - 1st argument needs [ "IsList" ]
#I   - 2nd argument needs [ "IsList" ]
#I  Method 2: ``foobar: for 2 integers'' at stream:2, value: 0
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1, 2], 5));
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries
#I  Method 1: ``foobar: for two lists'' at stream:1, value: 17
#I   - 1st argument needs [ "IsList" ]
#I   - 2nd argument needs [ "IsList" ]
#I  Method 2: ``foobar: for 2 integers'' at stream:2, value: 0
function ( x, y... )
    return 1;
end

# check the method for two lists
gap> ApplicableMethod(foobar, [[1], []], 5);;
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries
#I  Method 1: ``foobar: for two lists'' at stream:1, value: 17

# no method found
gap> ApplicableMethod(foobar, [1, []], 5);
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries
#I  Method 1: ``foobar: for two lists'' at stream:1, value: 17
#I   - 1st argument needs [ "IsList" ]
#I  Method 2: ``foobar: for 2 integers'' at stream:2, value: 0
#I   - 2nd argument needs [ "IsInt" ]
fail

#
# check 0-6 arguments
#
gap> Display(ApplicableMethod(foobar, [], 5));
#I  Searching Method for foobar with 0 arguments:
#I  Total: 1 entries
#I  Method 1: ``foobar: for no argument'' at stream:1, value: 0
function (  )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1], 5));
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries
#I  Method 1: ``foobar: for a string'' at stream:1, value: 2*SUM_FLAGS+1
#I   - 1st argument needs [ "IsString" ]
#I  Method 2: ``foobar: for a list'' at stream:1, value: 42
#I   - 1st argument needs [ "IsList" ]
#I  Method 3: ``foobar: for an integer'' at stream:1, value: 1
function ( x )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1,2], 5));
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries
#I  Method 1: ``foobar: for two lists'' at stream:1, value: 17
#I   - 1st argument needs [ "IsList" ]
#I   - 2nd argument needs [ "IsList" ]
#I  Method 2: ``foobar: for 2 integers'' at stream:2, value: 0
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1..3], 5));
#I  Searching Method for foobar with 3 arguments:
#I  Total: 1 entries
#I  Method 1: ``foobar: for 3 integers'' at stream:3, value: 0
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1..4], 5));
#I  Searching Method for foobar with 4 arguments:
#I  Total: 1 entries
#I  Method 1: ``foobar: for 4 integers'' at stream:4, value: 0
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1..5], 5));
#I  Searching Method for foobar with 5 arguments:
#I  Total: 1 entries
#I  Method 1: ``foobar: for 5 integers'' at stream:5, value: 0
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1..6], 5));
#I  Searching Method for foobar with 6 arguments:
#I  Total: 1 entries
#I  Method 1: ``foobar: for 6 integers'' at stream:6, value: 0
function ( x, y... )
    return 1;
end

#
gap> STOP_TEST("methwy.tst");
