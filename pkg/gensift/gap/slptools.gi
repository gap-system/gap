#############################################################################
##
#W    slptools.gi           The GenSift package               Max Neunhoeffer
##                                                             Cheryl Praeger
##                                                            Csaba Schneider
##
##    @(#)$Id: slptools.gi,v 1.2 2005/01/12 21:38:52 gap Exp $
##
##  This file contains code to work with straight line programs,
##  escecially to produce random elements in groups together with slps
##  to describe them.
##

############################################################################
# Random elements by product replacement remembering words:
############################################################################

InstallValue( PseudoRandomSLPDefaults, rec(
      AddSlots := 10,
      Scramble := 100,
      ScrambleFactor := 10,
));

# In the following variable we count the number of multiplications done:
PseudoRandomSLPMultiplications := 0;

InstallGlobalFunction( Group_InitPseudoRandomSLP, 
function( grp, len, scramble )
    local   gens,  seed,  i, j;

    # we need at least as many seeds as generators
    gens := GeneratorsOfGroup(grp);
    if 0 = Length(gens)  then
        SetPseudoRandomSeedSLP( grp, [[],[]] );
        return;
    fi;
    len := Maximum( len, Length(gens), 2 );

    # add random generators
    seed := ShallowCopy(gens);
    SetPseudoRandomSeedSLP( grp, [seed,len,[]] );

    # scramble seed
    for i  in [ 1 .. scramble+len-Length(GeneratorsOfGroup(grp)) ]  do
        # the +len-Length(GeneratorsOfGroup(grp)) is for compatibility
        PseudoRandomSLP(grp);
    od;
    
    SetPseudoRandomSeedSLPStart( grp, StructuralCopy(PseudoRandomSeedSLP(grp)));
end);

InstallGlobalFunction( Group_ResetPseudoRandomSLP, function( grp )
    local l;
    if HasPseudoRandomSeedSLPStart( grp ) then
        SetPseudoRandomSeedSLP( grp, 
                StructuralCopy(PseudoRandomSeedSLPStart(grp)));
    else
        l := Length(GeneratorsOfGroup(grp));
        Group_InitPseudoRandomSLP( grp, l+PseudoRandomSLPDefaults.AddSlots, 
                           Maximum( l*PseudoRandomSLPDefaults.ScrambleFactor, 
                                    PseudoRandomSLPDefaults.Scramble ) );
    fi;
end);

InstallGlobalFunction( Group_PseudoRandomSLP, function( grp )
    local   seed,  i,  j, l;

    # set up the seed
    l := Length(GeneratorsOfGroup(grp));
    if not HasPseudoRandomSeedSLP(grp)  then
        i := Length(GeneratorsOfGroup(grp));
        Group_InitPseudoRandomSLP( grp, l+PseudoRandomSLPDefaults.AddSlots, 
                          Maximum( l*PseudoRandomSLPDefaults.ScrambleFactor, 
                                   PseudoRandomSLPDefaults.Scramble ) );
    fi;
    seed := PseudoRandomSeedSLP(grp);
    if 0 = Length(seed[1])  then
        return [One(grp),[]];
    fi;

    # construct the next element
    i := Random([ 1 .. Length(seed[1]) ]);

    if Length(seed[1]) < seed[2] then
        # Not yet completely initialized, so append new product:
        j := Random([ 1 .. Length(seed[1]) ]);
        if Random([true,false]) then
            Add(seed[1],seed[1][i] * seed[1][j]);
            PseudoRandomSLPMultiplications := PseudoRandomSLPMultiplications+1;
            Add(seed[3],[i,1,j,1]);
        else
            Add(seed[1],seed[1][j] * seed[1][i]);
            PseudoRandomSLPMultiplications := PseudoRandomSLPMultiplications+1;
            Add(seed[3],[j,1,i,1]);
        fi;
    else
        # Completely initialized, so do product replacement:
        j := Random([ 1 .. Length(seed[1])-1 ]);
        if j >= i then
            j := j + 1;
        fi;
        if Random([true,false])  then
            seed[1][j] := seed[1][i] * seed[1][j];
            PseudoRandomSLPMultiplications := PseudoRandomSLPMultiplications+1;
            Add(seed[3],[[i,1,j,1],j]);
        else
            seed[1][j] := seed[1][j] * seed[1][i];
            PseudoRandomSLPMultiplications := PseudoRandomSLPMultiplications+1;
            Add(seed[3],[[j,1,i,1],j]);
        fi;
    fi;

    return seed[1][j];
end);

InstallGlobalFunction( Group_PseudoRandomAsSLP, function( grp )
    return StraightLineProgramNC(PseudoRandomSeedSLP(grp)[3],
                                 Length(GeneratorsOfGroup(grp)));
end);

InstallMethod( PseudoRandomSLP, "product replacement with remembering words",
    [ IsGroup and HasGeneratorsOfGroup ], Group_PseudoRandomSLP );
InstallMethod( ResetPseudoRandomSLP, "reinitialization",
    [ IsGroup and HasGeneratorsOfGroup ], 
    Group_ResetPseudoRandomSLP );
InstallMethod( PseudoRandomAsSLP, "gets last pseudo random element as slp",
    [ IsGroup and HasGeneratorsOfGroup and HasPseudoRandomSeedSLP ],
    Group_PseudoRandomAsSLP );


