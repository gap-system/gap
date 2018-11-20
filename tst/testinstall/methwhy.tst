gap> START_TEST("methwhy.tst");

#
gap> ApplicableMethod();
#I  ApplicableMethod requires at least two arguments
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
#I  Total: 4 entries, of which 3 are applicable:
#I  Method 1, applicable method number 1, value: 2*SUM_FLAGS+1
#I  ``foobar: for a string''
#I   at stream:1
function ( x )
    return StartsWith( x, "foo" );
end
gap> ApplicableMethod(foobar, [ ['a'] ], 1, 2);
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries, of which 3 are applicable:
#I  Method 2, applicable method number 2, value: 42
#I  ``foobar: for a list''
#I   at stream:1
<Attribute "Length">
gap> ApplicableMethod(foobar, [ ['a'] ], 1, 3);
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries, of which 3 are applicable:
#I  Method 4, applicable method number 3, value: 0
#I  ``foobar''
#I   at stream:1
function( x ) ... end
gap> ApplicableMethod(foobar, [ ['a'] ], 1, 4);
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries, of which 3 are applicable:
#I  there are only 3 applicable methods
fail
gap> ApplicableMethod(foobar, [ ['a'] ], 1, "all");
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries, of which 3 are applicable:
#I  Method 1, applicable method number 1, value: 2*SUM_FLAGS+1
#I  ``foobar: for a string''
#I   at stream:1
#I  Method 2, applicable method number 2, value: 42
#I  ``foobar: for a list''
#I   at stream:1
#I  Method 4, applicable method number 3, value: 0
#I  ``foobar''
#I   at stream:1
[ function( x ) ... end, <Attribute "Length">, function( x ) ... end ]

#
gap> Display(ApplicableMethod(foobar, [fail], 1));
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries, of which 1 is applicable:
#I  Method 4, applicable method number 1, value: 0
#I  ``foobar''
#I   at stream:1
function ( x )
    return fail;
end
gap> Display(ApplicableMethod(foobar, [fail], 4));
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries, of which 1 is applicable:
#I  Method 1, value: 2*SUM_FLAGS+1
#I  ``foobar: for a string''
#I   at stream:1
#I   - 1st argument needs [ "IsString" ]
#I  Method 2, value: 42
#I  ``foobar: for a list''
#I   at stream:1
#I   - 1st argument needs [ "IsList" ]
#I  Method 3, value: 1
#I  ``foobar: for an integer''
#I   at stream:1
#I   - 1st argument needs [ "IsInt" ]
#I  Method 4, applicable method number 1, value: 0
#I  ``foobar''
#I   at stream:1
function ( x )
    return fail;
end
gap> ApplicableMethod(foobar, [fail], 6);; 
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries, of which 1 is applicable:
#I  Method 1, value: 2*SUM_FLAGS+1
#I  ``foobar: for a string''
#I   at stream:1
#I   - 1st argument needs [ "IsString" ]
#I  Method 2, value: 42
#I  ``foobar: for a list''
#I   at stream:1
#I   - 1st argument needs [ "IsList" ]
#I  Method 3, value: 1
#I  ``foobar: for an integer''
#I   at stream:1
#I   - 1st argument needs [ "IsInt" ]
#I  Method 4, applicable method number 1, value: 0
#I  ``foobar''
#I   at stream:1

#
# Test other methods with two args
#
gap> Display(ApplicableMethod(foobar, [1, 2]));
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1, 2], 1));
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries, of which 1 is applicable:
#I  Method 2, applicable method number 1, value: 0
#I  ``foobar: for 2 integers''
#I   at stream:2
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1, 2], 2));
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries, of which 1 is applicable:
#I  Method 1, value: 17
#I  ``foobar: for two lists''
#I   at stream:1
#I  Method 2, applicable method number 1, value: 0
#I  ``foobar: for 2 integers''
#I   at stream:2
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1, 2], 3));
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries, of which 1 is applicable:
#I  Method 1, value: 17
#I  ``foobar: for two lists''
#I   at stream:1
#I   - 1st argument needs [ "IsList" ]
#I  Method 2, applicable method number 1, value: 0
#I  ``foobar: for 2 integers''
#I   at stream:2
function ( x, y... )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1, 2], 4));
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries, of which 1 is applicable:
#I  Method 1, value: 17
#I  ``foobar: for two lists''
#I   at stream:1
#I   - 1st argument needs [ "IsList" ]
#I   - 2nd argument needs [ "IsList" ]
#I  Method 2, applicable method number 1, value: 0
#I  ``foobar: for 2 integers''
#I   at stream:2
function ( x, y... )
    return 1;
end

# check the method for two lists
gap> ApplicableMethod(foobar, [[1], []], 5);;
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries, of which 1 is applicable:
#I  Method 1, applicable method number 1, value: 17
#I  ``foobar: for two lists''
#I   at stream:1

# no method found
gap> ApplicableMethod(foobar, [1, []], 1);   
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries, of which 0 are applicable:
#I  there are no applicable methods with these parameters
fail
gap> ApplicableMethod(foobar, [1, []], 2);
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries, of which 0 are applicable:
#I  there are no applicable methods with these parameters
#I  Method 1, value: 17
#I  ``foobar: for two lists''
#I   at stream:1
#I  Method 2, value: 0
#I  ``foobar: for 2 integers''
#I   at stream:2
fail
gap> ApplicableMethod(foobar, [1, []], 4);
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries, of which 0 are applicable:
#I  there are no applicable methods with these parameters
#I  Method 1, value: 17
#I  ``foobar: for two lists''
#I   at stream:1
#I   - 1st argument needs [ "IsList" ]
#I  Method 2, value: 0
#I  ``foobar: for 2 integers''
#I   at stream:2
#I   - 2nd argument needs [ "IsInt" ]
fail

#
# check 0-6 arguments
#
gap> Display(ApplicableMethod(foobar, [], 4));
#I  Searching Method for foobar with 0 arguments:
#I  Total: 1 entries, of which 1 is applicable:
#I  Method 1, applicable method number 1, value: 0
#I  ``foobar: for no argument''
#I   at stream:1
function (  )
    return 1;
end
gap> Display(ApplicableMethod(foobar, [1], 4, 1));
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries, of which 2 are applicable:
#I  Method 1, value: 2*SUM_FLAGS+1
#I  ``foobar: for a string''
#I   at stream:1
#I   - 1st argument needs [ "IsString" ]
#I  Method 2, value: 42
#I  ``foobar: for a list''
#I   at stream:1
#I   - 1st argument needs [ "IsList" ]
#I  Method 3, applicable method number 1, value: 1
#I  ``foobar: for an integer''
#I   at stream:1
function ( x )
    return 1;
end
gap> ApplicableMethod(foobar, [1], 4, 2);
#I  Searching Method for foobar with 1 arguments:
#I  Total: 4 entries, of which 2 are applicable:
#I  Method 4, applicable method number 2, value: 0
#I  ``foobar''
#I   at stream:1
function( x ) ... end
gap> ApplicableMethod(foobar, [1,2], 4);   
#I  Searching Method for foobar with 2 arguments:
#I  Total: 2 entries, of which 1 is applicable:
#I  Method 1, value: 17
#I  ``foobar: for two lists''
#I   at stream:1
#I   - 1st argument needs [ "IsList" ]
#I   - 2nd argument needs [ "IsList" ]
#I  Method 2, applicable method number 1, value: 0
#I  ``foobar: for 2 integers''
#I   at stream:2
function( x, y... ) ... end
gap> ApplicableMethod(foobar, [1..3], 4);
#I  Searching Method for foobar with 3 arguments:
#I  Total: 1 entries, of which 1 is applicable:
#I  Method 1, applicable method number 1, value: 0
#I  ``foobar: for 3 integers''
#I   at stream:3
function( x, y... ) ... end
gap> ApplicableMethod(foobar, [1..4], 4);
#I  Searching Method for foobar with 4 arguments:
#I  Total: 1 entries, of which 1 is applicable:
#I  Method 1, applicable method number 1, value: 0
#I  ``foobar: for 4 integers''
#I   at stream:4
function( x, y... ) ... end
gap> ApplicableMethod(foobar, [1..5], 2);
#I  Searching Method for foobar with 5 arguments:
#I  Total: 1 entries, of which 1 is applicable:
#I  Method 1, applicable method number 1, value: 0
#I  ``foobar: for 5 integers''
#I   at stream:5
function( x, y... ) ... end
gap> ApplicableMethod(foobar, [1..6], 1);
#I  Searching Method for foobar with 6 arguments:
#I  Total: 1 entries, of which 1 is applicable:
#I  Method 1, applicable method number 1, value: 0
#I  ``foobar: for 6 integers''
#I   at stream:6
function( x, y... ) ... end

#
# check ApplicableMethod when applied to a function 
#
gap> foobar := function(a,b,c) return 1; end;; 
gap> ApplicableMethod( foobar, [4,5,6], 1, 1 );       
#I  foobar is a function, not an operation
#I  and is located at: stream:1
function( a, b, c ) ... end
gap> ApplicableMethod( foobar, [7,8], 1, 1 );  
#I  foobar is a function, not an operation
#I  and requires 3 arguments
fail
gap> foobar := function(x,arg...) return x*arg[1]; end;;
gap> ApplicableMethod( foobar, [7,8], 1, 1 );           
#I  foobar is a function, not an operation
#I  and is located at: stream:1
function( x, arg... ) ... end
gap> ApplicableMethod( foobar, [9], 1, 1 );  
#I  foobar is a function, not an operation
#I  and requires at least 2 arguments
fail

#
# now not returning 'fail' when the second argument fails to be a list, 
# but replacing arg2 by [arg2] and then carrying on:
#
gap> g := Group(());;
gap> Display(ApplicableMethod(Size,g));
#I  replacing second argument arg2 by the list [arg2]
function ( C )
    if IsFinite( C ) then
        TryNextMethod();
    fi;
    return infinity;
end

#
gap> STOP_TEST("methwhy.tst");
