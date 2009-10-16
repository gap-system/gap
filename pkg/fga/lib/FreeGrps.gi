#############################################################################
##
#W  FreeGroups.gi            FGA package                    Christian Sievers
##
##  Main installation file for the FGA package
##
#H  @(#)$Id: FreeGrps.gi,v 1.2 2005/03/01 21:29:33 gap Exp $
##
#Y  2003
##
Revision.("fga/lib/FreeGroups_gi") :=
    "@(#)$Id: FreeGrps.gi,v 1.2 2005/03/01 21:29:33 gap Exp $";


#############################################################################
##
#M  FreeGroupAutomaton( <G> )
##
##  returns the automaton representing <G>.
##
InstallMethod( FreeGroupAutomaton,
    "for a subgroup of a free group",
    [ CanComputeWithInverseAutomaton ],
    function(G)
        return FGA_FromGroupWithGenerators(G);
    end );


#############################################################################
##
#M  FreeGroupExtendedAutomaton( <G> )
##
##  return the extended automaton representing <G>.
InstallMethod( FreeGroupExtendedAutomaton,
    "for a subgroup of a free group",
    [ CanComputeWithInverseAutomaton ],
    function(G)
        return FGA_FromGroupWithGeneratorsX(G);
    end );


#############################################################################
##
#M  \in( <elm>, <group> )
##
##  tests whether <elm> is in the finitely generated free group <group>.
##
InstallMethod( \in,
    "for a subgroup of a free group",
    IsElmsColls,
    [ IsElementOfFreeGroup, CanComputeWithInverseAutomaton ],
    function( g, G )
        return g in FreeGroupAutomaton(G);
    end );


#############################################################################
##
#M  FreeGeneratorsOfGroup( <G> )
##
##  returns a list of free generators of the group <G>.
##  This is a minimal generating set, but is also guarantied to
##  be N-reduced.
##
InstallMethod( FreeGeneratorsOfGroup,
    "for a subgroup of a free group",
    [ CanComputeWithInverseAutomaton ],
    function(G)
        return List(FGA_GeneratorsLetterRep(FreeGroupAutomaton(G)),
                    l -> AssocWordByLetterRep
                            (ElementsFamily(FamilyObj(G)), l) );
    end );


#############################################################################
##
#M  GeneratorsOfGroup( <group> )
##
InstallMethod( GeneratorsOfGroup,
    "for a subgroup of a free group having a FreeGroupAutomaton",
    [ HasFreeGroupAutomaton ],
    FreeGeneratorsOfGroup );


##
##  FreeGeneratorsOfGroup are GeneratorsOfGroup
##
InstallImmediateMethod( GeneratorsOfGroup,
    HasFreeGeneratorsOfGroup,
    0,
    FreeGeneratorsOfGroup);


#############################################################################
##
#M  MinimalGeneratingSet( <group> )
##
##  returns <group>'s FreeGeneratorsOfGroup
##
InstallMethod( MinimalGeneratingSet,
    "for a subgroup of a free group",
    [ CanComputeWithInverseAutomaton ],
    FreeGeneratorsOfGroup );


#############################################################################
##
#M  SmallGeneratingSet( <group> )
##
##  returns <group>'s FreeGeneratorsOfGroup
##
InstallMethod( SmallGeneratingSet,
    "for a subgroup of a free group",
    [ CanComputeWithInverseAutomaton ],
    FreeGeneratorsOfGroup );


#############################################################################
##
#M  IsWholeFamily( <group> )
##
InstallMethod( IsWholeFamily,
    "for a finitely generated free group",
    [ CanComputeWithInverseAutomaton ],
    G -> ForAll( FreeGeneratorsOfWholeGroup( G ), gen -> gen in G) );


#############################################################################
##
#M  RankOfFreeGroup( <G> )
##
##  returns the rank of a free group.
##
InstallMethod( RankOfFreeGroup,
    "for a subgroup of a free group",
    [ CanComputeWithInverseAutomaton ],
    G -> Size(MinimalGeneratingSet(G)) );

InstallMethod( RankOfFreeGroup,
    "for a whole free group",
    [ IsFreeGroup and IsWholeFamily ],
    G -> Size(FreeGeneratorsOfWholeGroup(G)) );


#############################################################################
##
#M  Rank( <group> )
##
##  a convenient name for RankOfFreeGroup
##
InstallMethod( Rank,
    "for a subgroup of a free group",
    [ IsFreeGroup ],
    RankOfFreeGroup );


#############################################################################
##
#M  IsSubset( <group1>, <group2> )
##
InstallMethod( IsSubset,
    "for subgroups of free groups",
    IsIdenticalObj,
    [ CanComputeWithInverseAutomaton, CanComputeWithInverseAutomaton ],
    function(G,U)
    local gens;
    if HasFreeGeneratorsOfGroup(U) then
        gens := FreeGeneratorsOfGroup(U);
    else
        gens := GeneratorsOfGroup(U);
    fi;
    return ForAll(gens, u -> u in G);
    end );


#############################################################################
##
#M  \=( <group1>, <group2> )
##
InstallMethod( \=,
    "for subgroups of free groups",
    IsIdenticalObj,
    [ CanComputeWithInverseAutomaton, CanComputeWithInverseAutomaton ],
    function( G, H )
    return IsSubset(G,H) and IsSubset(H,G);
    end );


#############################################################################
##
#M  AsWordLetterRepInFreeGenerators( <g>, <G> )
##
##  returns the unique list <l> representing a word in letter representation
##  such that
##  <g> = Product( <l>, 
##                 x -> FreeGeneratorsOfGroup(<G>)[AbsInt(x)]^(SignInt(x)),
##                 One(<G>) )
##  or fail, if <g> is not in <G>.
##
InstallMethod( AsWordLetterRepInFreeGenerators,
    "for an element in a free group",
    IsElmsColls,
    [ IsElementOfFreeGroup, CanComputeWithInverseAutomaton ],
    function( g, G )
        return FGA_AsWordLetterRepInFreeGenerators(
                   LetterRepAssocWord(g), FreeGroupAutomaton(G) );
    end );


#############################################################################
##
#M  AsWordLetterRepInGenerators( <g>, <G> )
##
##  returns a list <l> representing a word in letter representation such that
##  <g> = Product( <l>, 
##                 x -> GeneratorsOfGroup(<G>)[AbsInt(x)]^(SignInt(x)),
##                 One(<G>) )
##  or fail, if <g> is not in <G>.
##
InstallMethod( AsWordLetterRepInGenerators,
    "for an element in a free group",
    IsElmsColls,
    [ IsElementOfFreeGroup,
      CanComputeWithInverseAutomaton and HasGeneratorsOfGroup ],
    function( g, G )
        return FGA_AsWordLetterRepInGenerators( 
                              LetterRepAssocWord( g ),
                              FreeGroupExtendedAutomaton( G ) );
    end );


#############################################################################
##
#O  CyclicallyReducedWord( <g> )
##
##  returns the the cyclically reduced form of <g>
##
InstallMethod( CyclicallyReducedWord,
    "for an element in a free group",
    [ IsElementOfFreeGroup ],
    function( g )
    local rep, len, i;
    if IsOne( g ) then
       return g;
    fi;
    rep := LetterRepAssocWord( g );
    len := Length( rep );
    i := 1;
    while rep[i] = -rep[len-i+1] do
       i := i+1;
    od;
    return AssocWordByLetterRep( FamilyObj( g ), rep{[i..len-i+1]} );
    end );


#############################################################################
##
#E
