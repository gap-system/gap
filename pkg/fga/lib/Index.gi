#############################################################################
##  
#W Index.gi                    FGA package                  Christian Sievers
##
## Method installations for index computations in free groups
##
#H @(#)$Id: Index.gi,v 1.3 2005/04/07 18:00:43 gap Exp $
##
#Y 2003
##
Revision.("fga/lib/Index_gi") :=
    "@(#)$Id: Index.gi,v 1.3 2005/04/07 18:00:43 gap Exp $";


#############################################################################
##
#M  IndexInWholeGroup( <group> )
##
InstallMethod( IndexInWholeGroup,
    "for a free group",
    [ CanComputeWithInverseAutomaton ],
    function(G)

    if HasIsWholeFamily(G) and IsWholeFamily(G) then
        return 1;
    fi;

    # let the gap lib handle this case:
    if IsSubgroupOfWholeGroupByQuotientRep(G) then
        TryNextMethod();
    fi;

    return FGA_Index(FreeGroupAutomaton(G));
    end );


#############################################################################
##
#M  IndexOp( <group>, <subgroup>, <flag> )
##
##  computes the index of <subgroup> in <group>.
##  If <flag> is true, checks whether the subgroup relation really holds
##  and returns fail otherwise.
##  Some of the checks will even be performed when <flag> is false.
##
InstallOtherMethod( IndexOp,
    "for free groups",
    IsFamFamX,
    [ CanComputeWithInverseAutomaton, 
      CanComputeWithInverseAutomaton, 
      IsBool ],
    function( G, U, check )
    local indexG, indexU, index, rankG, gensU, gen, w, genwords;
    indexG := IndexInWholeGroup( G );
    indexU := IndexInWholeGroup( U );
    if indexG <> infinity then
        if check and not IsSubset( G, U ) then
            return fail;
        fi;
        if indexU = infinity then
            return infinity;
        else
            index := indexU / indexG;
            if IsInt( index ) then
               return index;
            else
               return fail;
            fi;
        fi;
    fi;

    # one more cheap test:
    if indexU <> infinity then
        return fail;
    fi;

    # now we must work harder
    rankG := RankOfFreeGroup( G );
    gensU := FreeGeneratorsOfGroup( U );
    genwords := [];
    for gen in gensU do
        w := AsWordLetterRepInFreeGenerators( gen, G );
        if w = fail then
            return fail;
        fi;
        Add( genwords, w );
    od;

    return FGA_Index(
           FGA_FromGeneratorsLetterRep( genwords, FreeGroup(rankG) ) );
    end );


#############################################################################
##
#M  IndexOp( <group>, <subgroup> )
##
InstallMethod( IndexOp,
    "for free groups",
    IsIdenticalObj,
    [ CanComputeWithInverseAutomaton, CanComputeWithInverseAutomaton ],
    function( G, H )
    return IndexOp( G, H, true);
    end );


#############################################################################
##
#M  IndexNC( <group>, <subgroup> )
##
InstallMethod( IndexNC,
    "for free groups",
    IsIdenticalObj,
    [ CanComputeWithInverseAutomaton, CanComputeWithInverseAutomaton ],
    function( G, H )
    return IndexOp( G, H, false);
    end );


#############################################################################
##
#E
