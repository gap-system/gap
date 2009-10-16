#############################################################################
##
#W  grpconst.gi                 GrpConst                         Bettina Eick
#W                                                         Hans Ulrich Besche
##
Revision.("grpconst/gap/grpconst_gi") :=
    "@(#)$Id: grpconst.gi,v 1.3 1999/11/07 19:28:45 gap Exp $";

#############################################################################
##
#F AllNonSolublePerfectGroups( size ) . . . . . . . . . . . . . . . . . local
##
InstallGlobalFunction( AllNonSolublePerfectGroups, function( size )
    local n;
    n := NrPerfectGroups(size);
    if n = 0 or size = 1 then 
        return [];
    elif IsBool( n ) then
        return n;
    else
        return List( [1..n], x -> PerfectGroup(IsPermGroup, size, x) );
    fi;
end );

#############################################################################
##
#F ConstructAllGroups( size ) . . . . . .  construct all groups of given size
##
InstallGlobalFunction( ConstructAllGroups, function( size )
    local pr, grps, p, n, new, tmp, G, H, cl, flags, d; 

    # trivial case
    pr := Factors( size );
    if Length( pr ) <= 3 then return AllSmallGroups( size ); fi;

    # nilpotent groups come from the SmallGroups library
    grps := [PcGroupCode( 0,1 )];
    for p in Set( pr ) do
        n := Length( Filtered( pr, x -> x = p ) );
        if (p^n <> 512 and p^n <= 1000) or n <= 3  then
            new := AllSmallGroups( p^n, IsNilpotent, true );
        else
            Print("sorry - prime powers in order are too large \n");
            return fail;
        fi;
        tmp := [];
        for G in grps do
            for H in new do
                Add( tmp, DirectProduct( G, H ) );
            od;
        od;
        grps := tmp; 
    od;

    # if size is of  type p^n * q
    cl := Collected( pr );
    if Length( cl ) = 2 and cl[1][2] = 1 then
        new := CyclicSplitExtensionMethod(cl[2][1],cl[2][2],cl[1][1],true);
        Append( grps, new.up );
        Append( grps, new.down );
        flags := rec( nonpnorm := Set( pr ) );
    elif Length( cl ) = 2 and cl[2][2] = 1 then
        new := CyclicSplitExtensionMethod(cl[1][1],cl[1][2],cl[2][1],true);
        Append( grps, new.up );
        Append( grps, new.down );
        flags := rec( nonpnorm := Set( pr ) );
    else
        flags := rec( nonnilpot := true );
    fi;

    # remaining soluble groups
    new := FrattiniExtensionMethod( size, flags, true );
    Append( grps, new );

    # non-soluble groups
    tmp := [];
    for d in DivisorsInt( size ) do
        new := AllNonSolublePerfectGroups( d );
        if IsBool( new ) then 
            Print("sorry - perfect groups are not available \n");
            return fail;
        fi;
        Append( tmp, new );
    od;
    for G in tmp do
        if Size(Centre(G)) = 1 then 
            new := UpwardsExtensionsNoCentre( G, size/Size(G) );
        else
            new := UpwardsExtensions( G, size / Size(G) );
            new := new[Length(new)];
        fi;
        Append( grps, new );
    od;
 
    # now we got them all
    return grps;
end );
  
