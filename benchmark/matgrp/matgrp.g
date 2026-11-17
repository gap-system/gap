#############################################################################
##
##  Deciding finiteness of cyclotomic matrix groups.
##
##  'IsFinite' for such a group reduces it modulo a prime, builds a
##  presentation of the congruence image and evaluates that presentation's
##  relators back in the group.  Both the reduction and the presentation are
##  randomised, and the spread is large: one group in this corpus takes
##  between 1.0 and 7.2 seconds on the same code depending only on the random
##  seed.  A single timing therefore says very little, so every case is run at
##  each of several seeds, with the seed set immediately before 'IsFinite' so
##  that two GAP versions see the same presentation.
##
##  Expected answers follow from how each group is built -- the finite
##  families are subgroups of finite groups, the infinite ones contain a
##  transvection, a scaling, or a free subgroup -- so they stay valid even if
##  the random number generator changes.
##

MatGrpCases := [];

AddMatGrpCase := function( name, expected, f )
    Add( MatGrpCases, rec( name := name, expected := expected, f := f ) );
end;

FreshImf := function( n, q, z )
    return Group( GeneratorsOfGroup( ImfMatrixGroup( n, q, z ) ) );
end;

# Maker functions: each closure must capture its own parameters, so the
# groups may not be built inline in the loops below.

MakeImf := function( n, q, z )
    return function() return FreshImf( n, q, z ); end;
end;

MakeCyc := function( n, q, z, k )       # finite, not rational: forces a blow-up
    return function()
        return Group( Concatenation( GeneratorsOfGroup( ImfMatrixGroup( n, q, z ) ),
                                     [ E(k) * IdentityMat( n ) ] ) );
    end;
end;

MakeRep := function( id1, id2 )         # finite cyclotomic, from a representation
    return function()
        local G, reps;
        G := SmallGroup( id1, id2 );
        reps := IrreducibleRepresentations( G );
        return Group( List( GeneratorsOfGroup( G ),
                            g -> ImageElm( Last( reps ), g ) ) );
    end;
end;

MakeTransvection := function( n, q, z )  # infinite, rational
    return function()
        local m;
        m := IdentityMat( n );  m[1][2] := 1;
        return Group( Concatenation( GeneratorsOfGroup( ImfMatrixGroup( n, q, z ) ),
                                     [ m ] ) );
    end;
end;

MakeScaling := function( n, q, z )       # infinite, with non-integral inverses
    return function()
        return Group( Concatenation( GeneratorsOfGroup( ImfMatrixGroup( n, q, z ) ),
                                     [ 2 * IdentityMat( n ) ] ) );
    end;
end;

MakeCycInf := function( n, q, z, k )     # infinite and not rational
    return function()
        local m;
        m := IdentityMat( n );  m[1][2] := 1;
        return Group( Concatenation( GeneratorsOfGroup( ImfMatrixGroup( n, q, z ) ),
                                     [ E(k) * IdentityMat( n ), m ] ) );
    end;
end;

MakeRandSub := function( n, q, z, seed ) # finite, but varied presentations
    return function()
        local G;
        Reset( GlobalMersenneTwister, seed );
        G := ImfMatrixGroup( n, q, z );
        return Group( List( [ 1, 2 ], i -> PseudoRandom( G ) ) );
    end;
end;

#  irreducible maximal finite subgroups of GL(n,Z): finite and rational
for n in [ 2 .. 9 ] do
  for q in [ 1 .. ImfNumberQClasses( n ) ] do
    for z in [ 1 .. ImfNumberZClasses( n, q ) ] do
      AddMatGrpCase( Concatenation( "imf-", String(n), "-", String(q), "-", String(z) ),
                     true, MakeImf( n, q, z ) );
    od;
  od;
od;
for t in [ [10,1,1], [10,5,1], [10,15,2], [11,1,1], [11,2,3],
           [12,1,1], [12,7,1], [13,1,1] ] do
  AddMatGrpCase( Concatenation( "imf-", String(t[1]), "-", String(t[2]), "-", String(t[3]) ),
                 true, MakeImf( t[1], t[2], t[3] ) );
od;

#  finite, but not rational
for t in [ [2,1,1,3], [2,1,1,5], [2,2,1,8], [3,1,1,7], [3,1,2,5], [4,1,1,3],
           [4,3,1,5], [4,5,1,12], [5,1,1,3], [6,1,1,4], [6,6,1,3], [8,1,1,3] ] do
  AddMatGrpCase( Concatenation( "cyc-imf-", String(t[1]), "-", String(t[2]), "-",
                                String(t[3]), "-E", String(t[4]) ),
                 true, MakeCyc( t[1], t[2], t[3], t[4] ) );
od;

#  finite cyclotomic, from ordinary representations of small groups
for t in [ [8,3], [12,3], [16,13], [20,3], [24,3], [24,12], [36,9], [48,28],
           [60,5], [64,138] ] do
  AddMatGrpCase( Concatenation( "rep-", String(t[1]), "-", String(t[2]) ),
                 true, MakeRep( t[1], t[2] ) );
od;

#  infinite, rational
AddMatGrpCase( "SL2Z", false,
    function() return Group( [[1,1],[0,1]], [[0,-1],[1,0]] ); end );
AddMatGrpCase( "SL3Z", false,
    function() return Group( [[1,1,0],[0,1,0],[0,0,1]], [[0,0,1],[1,0,0],[0,1,0]],
                            [[-1,0,0],[0,-1,0],[0,0,1]] ); end );
AddMatGrpCase( "sanov-free", false,
    function() return Group( [[1,2],[0,1]], [[1,0],[2,1]] ); end );
AddMatGrpCase( "heisenberg", false,
    function() return Group( [[1,1,0],[0,1,0],[0,0,1]], [[1,0,0],[0,1,1],[0,0,1]] ); end );
AddMatGrpCase( "scaling-2I", false,
    function() return Group( [[2,0],[0,1]], [[0,1],[1,0]] ); end );
for t in [ [4,1,1], [6,1,1], [8,1,1], [9,1,1] ] do
  AddMatGrpCase( Concatenation( "imf+transvection-", String(t[1]) ), false,
                 MakeTransvection( t[1], t[2], t[3] ) );
  AddMatGrpCase( Concatenation( "imf+scaling-", String(t[1]) ), false,
                 MakeScaling( t[1], t[2], t[3] ) );
od;

#  infinite and not rational -- the shape reported in issue #6563
AddMatGrpCase( "cyc-infinite-E3", false,
    function() return Group( [[E(3),0],[0,1]], [[1,1],[0,1]] ); end );
AddMatGrpCase( "cyc-infinite-E5", false,
    function() return Group( [[E(5),0],[0,1]], [[1,2],[0,1]] ); end );
for t in [ [4,1,1,3], [6,1,1,3], [4,3,1,5] ] do
  AddMatGrpCase( Concatenation( "cyc-imf+transvection-", String(t[1]), "-E", String(t[4]) ),
                 false, MakeCycInf( t[1], t[2], t[3], t[4] ) );
od;

#  the group of issue #6563; see tst/testbugfix/2026-09-08-issue-6563.tst
AddMatGrpCase( "issue6563", false, function()
    local mats;
    mats:= [];;
    mats[1]:= [[-1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]];;
    mats[2]:= [
      [-1/2*E(7)-1/2*E(7)^6,1/2*E(28)^3-1/2*E(28)^11,0,0],
      [1/2*E(28)^3-1/2*E(28)^11,1/2*E(7)+1/2*E(7)^6,0,0],
      [0,0,1,0],[0,0,0,1]];;
    mats[3]:= [
    [1/2,
     -5/14*E(28)^3+5/14*E(28)^11+3/14*E(28)^15+1/14*E(28)^19-1/14*E(28)^23
     -3/14*E(28)^27,
     4/7*E(56)^5+9/14*E(56)^13-9/14*E(56)^15-4/7*E(56)^23+9/14*E(56)^29
     -15/28*E(56)^31+4/7*E(56)^37-15/28*E(56)^39+15/28*E(56)^45-4/7*E(56)^47
     +15/28*E(56)^53-9/14*E(56)^55,
     -3/7*E(56)^5-5/14*E(56)^13+5/14*E(56)^15+3/7*E(56)^23-5/14*E(56)^29
     +13/28*E(56)^31-3/7*E(56)^37+13/28*E(56)^39-13/28*E(56)^45+3/7*E(56)^47
     -13/28*E(56)^53+5/14*E(56)^55],
    [-5/14*E(28)^3+5/14*E(28)^11+3/14*E(28)^15+1/14*E(28)^19-1/14*E(28)^23
     -3/14*E(28)^27,
     -9/14*E(7)-1/14*E(7)^2+3/14*E(7)^3+3/14*E(7)^4-1/14*E(7)^5-9/14*E(7)^6,
     1/7*E(56)^5+5/14*E(56)^13-5/14*E(56)^15-1/7*E(56)^23-5/14*E(56)^29
     -1/28*E(56)^31-1/7*E(56)^37+1/28*E(56)^39-1/28*E(56)^45+1/7*E(56)^47
     +1/28*E(56)^53+5/14*E(56)^55,
     -2/7*E(56)^5-5/14*E(56)^13+5/14*E(56)^15+2/7*E(56)^23+5/14*E(56)^29
     +3/28*E(56)^31+2/7*E(56)^37-3/28*E(56)^39+3/28*E(56)^45-2/7*E(56)^47
     -3/28*E(56)^53-5/14*E(56)^55],
    [4/7*E(56)^5+9/14*E(56)^13-9/14*E(56)^15-4/7*E(56)^23+9/14*E(56)^29
     -15/28*E(56)^31+4/7*E(56)^37-15/28*E(56)^39+15/28*E(56)^45-4/7*E(56)^47
     +15/28*E(56)^53-9/14*E(56)^55,
     1/7*E(56)^5+5/14*E(56)^13-5/14*E(56)^15-1/7*E(56)^23-5/14*E(56)^29
     -1/28*E(56)^31-1/7*E(56)^37+1/28*E(56)^39-1/28*E(56)^45+1/7*E(56)^47
     +1/28*E(56)^53+5/14*E(56)^55,
     19/28*E(7)+5/14*E(7)^2+3/14*E(7)^3+3/14*E(7)^4+5/14*E(7)^5+19/28*E(7)^6,
     -25/28*E(7)-13/14*E(7)^2-13/14*E(7)^3-13/14*E(7)^4-13/14*E(7)^5
     -25/28*E(7)^6],
    [3/7*E(56)^5+5/14*E(56)^13-5/14*E(56)^15-3/7*E(56)^23+5/14*E(56)^29
     -13/28*E(56)^31+3/7*E(56)^37-13/28*E(56)^39+13/28*E(56)^45-3/7*E(56)^47
     +13/28*E(56)^53-5/14*E(56)^55,
     2/7*E(56)^5+5/14*E(56)^13-5/14*E(56)^15-2/7*E(56)^23-5/14*E(56)^29
     -3/28*E(56)^31-2/7*E(56)^37+3/28*E(56)^39-3/28*E(56)^45+2/7*E(56)^47
     +3/28*E(56)^53+5/14*E(56)^55,
     25/28*E(7)+13/14*E(7)^2+13/14*E(7)^3+13/14*E(7)^4+13/14*E(7)^5
     +25/28*E(7)^6,
     -43/28*E(7)-25/14*E(7)^2-27/14*E(7)^3-27/14*E(7)^4-25/14*E(7)^5
     -43/28*E(7)^6]];;
    return Group( mats );
end );

#  random 2-generator subgroups: finite, with varied presentations
for t in [ [6,1,1], [8,1,1], [8,3,1], [9,1,1], [10,1,1], [6,4,1], [7,1,1], [5,2,1] ] do
  for seed in [ 1, 2 ] do
    AddMatGrpCase( Concatenation( "randsub-", String(t[1]), "-", String(t[2]), "-",
                                  String(t[3]), "-s", String(seed) ),
                   true, MakeRandSub( t[1], t[2], t[3], seed ) );
  od;
od;

#############################################################################
##
#F  RunMatGrpBenchmark( <seeds> )
##
##  Run every case once per seed, reporting a wrong answer as '*** FAIL'.
##  Returns 'true' if all answers were as expected.
##
RunMatGrpBenchmark := function( seeds )
    local ok, c, seed, G, t, r;
    ok := true;
    for c in MatGrpCases do
        for seed in seeds do
            G := c.f();
            # seed what 'IsFinite' itself consumes, so that two GAP versions
            # build the same presentation and are actually comparable
            Reset( GlobalMersenneTwister, seed );
            Reset( GlobalRandomSource, seed );
            t := Runtime();
            r := IsFinite( G );
            t := Runtime() - t;
            Print( c.name, " seed ", seed, ": ", r, " ", t, " ms\n" );
            if r <> c.expected then
                Print( "*** FAIL ", c.name, " seed ", seed,
                       ": expected ", c.expected, ", got ", r, "\n" );
                ok := false;
            fi;
        od;
    od;
    return ok;
end;
