#############################################################################
##
#W  autoops.gi               AutPGrp package                     Bettina Eick
##
#H  @(#)$Id: autoops.gi,v 1.5 2003/08/18 12:10:28 gap Exp $
##
Revision.("autpgrp/gap/autoops_gi") :=
    "@(#)$Id: autoops.gi,v 1.5 2003/08/18 12:10:28 gap Exp $";


#############################################################################
##
#F PGAutomorphism( <G>, <gens>, <imgs> )
##
InstallMethod( PGAutomorphism,
   "for p-groups", true, [IsPGroup, IsList, IsList ], 0,

function( G, gens, imgs )
    local filter, type, r, p, pcgs, base, pcgsimgs, baseimgs, def, d;

    # cache the default type in the group
    if not IsBound( G!.PGAutomType ) then
        filter := IsPGAutomorphism and IsBijective;
        type   := TypeOfDefaultGeneralMapping( G, G, filter );
        G!.PGAutomType := type;
    else
        type := G!.PGAutomType;
    fi;

    # get images correct
    r := RankPGroup( G );
    p := PrimePGroup( G );
    pcgs := Pcgs( G );
    base := pcgs{[1..r]};
    
    if gens = pcgs then
        pcgsimgs := imgs;  
        baseimgs := imgs{[1..r]};
    elif gens = base then
        baseimgs := ShallowCopy( imgs );
        pcgsimgs := ShallowCopy( imgs );
        for d in G!.definitions do
            if not IsNegRat( d ) then
                Add( pcgsimgs, SubstituteDef( d, pcgsimgs, p ) );
            fi;
        od;
    else
        Print("# W computing pcgs in PGAutomorphism \n");
        pcgsimgs := CanonicalPcgsByGeneratorsWithImages( pcgs, gens, imgs );
        baseimgs := pcgsimgs{[1..r]};
    fi;

    # create homomorphism
    return Objectify( type, rec( pcgs := pcgs, pcgsimgs := pcgsimgs,
                                 base := base, baseimgs := baseimgs ) );
end);

#############################################################################
##
#F IdentityPGAutomorphism( <G> )
##
InstallGlobalFunction( IdentityPGAutomorphism, function( G )
    return PGAutomorphism( G, Pcgs(G), AsList(Pcgs(G)) );
end );

#############################################################################
##
#F PrintObj(auto)
##
InstallMethod( PrintObj,
               "for group automorphisms",
               true,
               [IsPGAutomorphism],
               SUM_FLAGS,
function( auto )
    if IsBound( auto!.mat ) then 
        Print("Aut + Mat: ",auto!.pcgsimgs);
    else
        Print("Aut: ",auto!.pcgsimgs);
    fi;
end);

#############################################################################
##
#F ViewObj(auto)
##
InstallMethod( ViewObj,
               "for group automorphisms",
               true,
               [IsPGAutomorphism],
               SUM_FLAGS,
function( auto )
    if IsBound( auto!.mat ) then 
        Print("Aut + Mat: ",auto!.pcgsimgs);
    else
        Print("Aut: ",auto!.pcgsimgs);
    fi;
end);

#############################################################################
##
#F \= 
##
InstallMethod( \=,
               "for group automorphisms",
               IsIdenticalObj,
               [IsPGAutomorphism, IsPGAutomorphism],
               0,
function( auto1, auto2 )
    return auto1!.base = auto2!.base and auto1!.baseimgs = auto2!.baseimgs;
end);

#############################################################################
##
#F ImagesRepresentative( auto, g )
##
InstallMethod( ImagesRepresentative,
               "for group automorphisms",
               true,
               [IsPGAutomorphism, IsObject],
               0,
function( auto, g )
    return MappedPcElement( g, auto!.pcgs, auto!.pcgsimgs );
end ); 

#############################################################################
##
#F PGMult( auto1, auto2 )
##
InstallMethod( PGMult, true, [IsPGAutomorphism, IsPGAutomorphism], 0,
function( auto1, auto2 )
    local new, aut;

    # 1. version
    new := List( auto1!.pcgsimgs, x -> ImagesRepresentative( auto2, x ) );
    if IsBound( auto1!.mat ) and IsBound( auto2!.mat ) then
	aut := PGAutomorphism( Source(auto1), auto1!.pcgs, new );
        aut!.mat := auto1!.mat * auto2!.mat;
    else
	aut := PGAutomorphism( Source(auto1), auto1!.pcgs, new );
    fi;
    return aut;

    # 2. version
    new  := List( auto2!.baseimgs, x -> ImagesRepresentative( auto1, x ) );
    return PGAutomorphism( Source(auto2), auto2!.base, new );
end );

#############################################################################
##
#F CompositionMapping2( auto1, auto2 )
##
InstallMethod( CompositionMapping2,
               "for group automorphisms",
               true,
               [IsPGAutomorphism, IsPGAutomorphism],
               0,
function( auto2, auto1 )
    return PGMult( auto1, auto2 );
end );
               
#############################################################################
##
#F PGMultList( autl ) 
##
InstallMethod( PGMultList, true, [IsList], 0,
function( autl )
    local l, r, new;
    if Length( autl ) = 1 then return autl[1]; fi;
    if Length( autl ) = 2 then return PGMult(autl[1],autl[2]); fi;
    l := Length( autl );
    r := QuoInt( l, 2 );
    new := List( [1..r], x -> PGMult( autl[2*x-1], autl[2*x] ));
    if not IsInt( l/2 ) then Add( new, autl[l] ); fi;
    return PGMultList( new );
end );

#############################################################################
##
#F PGPower( n, aut )
##
InstallMethod( PGPower, true, [IsInt, IsPGAutomorphism], 0,
function( n, aut )
    local c, l, i, j, new;

    if n <= 0 then return fail; fi;
    if n = 1 then return aut; fi;
    c := CoefficientsQadic( n, 2 );

    # create power list, if necessary 
    if not IsBound( aut!.power ) then aut!.power := []; fi;

    # add powers, if necessary
    l := Length( aut!.power );
    if l = 0 then
        new := aut;
    else
        new := aut!.power[l];
    fi;
    for i in [l+1..Length(c)-1] do
        new := PGMult( new, new );
        Add( aut!.power, new );
    od; 

    # multiply powers together
    if c[1] = 1 then
        new := [aut];
    else 
        new := [];
    fi;
    for i in [2..Length(c)] do
        if c[i] = 1 then
            Add( new, aut!.power[i-1] );
        fi;
    od;
    return PGMultList( new );
end );

#############################################################################
##
#F PGInverse( aut )
##
InstallMethod( PGInverse, true, [IsPGAutomorphism], 0,
function( aut )
    local new, inv;
    if not IsBound( aut!.inv ) then 
        new := CanonicalPcgsByGeneratorsWithImages( 
                aut!.pcgs, aut!.pcgsimgs, aut!.pcgs);
        inv := PGAutomorphism( Source( aut ), aut!.pcgs, new[2] );
    else 
        inv := aut!.inv;
    fi;

    if IsBound( aut!.mat ) and not IsBound( inv!.mat) then
        inv!.mat := aut!.mat^-1;
    fi;

    aut!.inv := inv;
    return aut!.inv;
end );

#############################################################################
##
#F InverseGeneralMapping(auto)
##
InstallOtherMethod( InverseGeneralMapping,
               "for group automorphism",
               true,
               [IsPGAutomorphism],
               SUM_FLAGS,
function( auto ) return PGInverse( auto ); end );

