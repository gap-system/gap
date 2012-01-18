#############################################################################
##
#W  convert.gi                   Polycyc                         Bettina Eick
##                                                              Werner Nickel

#############################################################################
##
## Convert finite pcp groups to pc groups.
##
PcpGroupToPcGroup := function( G )
    local pcp, rel, n, F, f, i, rws, h, e, w, j;

    pcp := Pcp( G );
    rel := RelativeOrdersOfPcp( pcp );
    if ForAny( rel, x -> x = 0 ) then return fail; fi;
 
    n := Length( pcp );
    F := FreeGroup( n );
    f := GeneratorsOfGroup( F );
    
    rws := SingleCollector( F, rel );
    for i in [1..n] do

        # set power
        h := pcp[i] ^ rel[i];
        e := ExponentsByPcp( pcp, h );
        w := MappedVector( e, f );
        SetPower( rws, i, w );

        # set conjugates
        for j in [1..i-1] do
            h := pcp[i]^pcp[j];
            e := ExponentsByPcp( pcp, h );
            w := MappedVector( e, f );
            SetConjugate( rws, i, j, w );
        od;
    od;
    return GroupByRwsNC( rws );
end;

InstallMethod( IsomorphismPcGroup, true, [IsPcpGroup], 0, 
function( G )
    local K, H, g, k, h, hom;
    if not IsFinite(G) then TryNextMethod(); fi;
    K := RefinedPcpGroup(G);
    H := PcpGroupToPcGroup(K);
    g := Igs(G);
    k := List(g, x -> Image(K!.bijection,x));
    h := List(k, x -> MappedVector(Exponents(x), Pcgs(H)));
    hom := GroupHomomorphismByImagesNC( G, H, g, h);
    SetIsBijective( hom, true );
    SetIsGroupHomomorphism( hom, true );
    return hom;
end );

#############################################################################
##
## Convert pcp groups to fp groups.
##
PcpGroupToFpGroup := function( G )
    local pcp, rel, n, F, f, r, i, j, e, w, v;

    pcp := Pcp( G );
    rel := RelativeOrdersOfPcp( pcp );
    n := Length( pcp );
    F := FreeGroup( n );
    f := GeneratorsOfGroup( F );
    r := [];

    for i in [1..n] do

        # set power
        e := ExponentsByPcp( pcp, pcp[i]^rel[i] );
        w := MappedVector( e, f );
        v := f[i]^rel[i];
        Add( r, v/w );

        # set conjugates
        for j in [1..i-1] do
            e := ExponentsByPcp( pcp, pcp[i]^pcp[j] );
            w := MappedVector( e, f );
            v := f[i]^f[j];
            Add( r, v/w );
 
            if rel[j] = 0 then 
                e := ExponentsByPcp( pcp, pcp[i]^(pcp[j]^-1) );
                w := MappedVector( e, f );
                v := f[i]^(f[j]^-1);
                Add( r, v/w );
            fi;
        od;
    od;
    return F/r;
end;

InstallMethod( IsomorphismFpGroup, true, [IsPcpGroup], 0,
function( G )
    local H, hom;
    H := PcpGroupToFpGroup( G );
    hom := GroupHomomorphismByImagesNC( G, H, AsList(Pcp(G)), 
           GeneratorsOfGroup(H));
    SetIsBijective( hom, true );
    return hom;
end );

#############################################################################
##
## Convert pc groups to pcp groups.
##
PcGroupToPcpGroup := function( G )
    local g, r, n, i, coll, h, e, w, j;

    g := Pcgs( G );
    r := RelativeOrders( g ); 
    n := Length( g );

    coll := FromTheLeftCollector( n );
    for i in [1..n] do

        # set power
        h := g[i] ^ r[i];
        e := ExponentsOfPcElement( g, h );
        w := ObjByExponents( coll, e );
        SetRelativeOrder( coll, i, r[i] );
        SetPower( coll, i, w );

        # set conjugates
        for j in [1..i-1] do
            h := g[i]^g[j];
            e := ExponentsOfPcElement( g, h );
            w := ObjByExponents( coll, e );
            SetConjugate( coll, i, j, w );

            h := g[i]^(g[j]^-1);
            e := ExponentsOfPcElement( g, h );
            w := ObjByExponents( coll, e );
            SetConjugate( coll, i, -j, w );
        od;
    od;

    return PcpGroupByCollector( coll );
end;

InstallMethod( IsomorphismPcpGroup, [IsPcGroup],
function( G )
    local H, hom;
    H := PcGroupToPcpGroup( G );
    hom := GroupHomomorphismByImagesNC( G, H, AsList(Pcgs(G)), AsList(Pcp(H)));
    SetIsBijective( hom, true );
    return hom;
end );

InstallMethod( IsomorphismPcpGroup,
    [ IsPcpGroup ],
    IdentityMapping );


#############################################################################
##
## Convert perm groups to pcp groups.
##
InstallMethod( IsomorphismPcpGroup, [IsPermGroup],
function( G )
    local iso, F,H, gens, hom;
    if not IsSolvableGroup( G ) then return fail; fi;
    iso  := IsomorphismPcGroup( G );
    F    := Image( iso );
    H    := PcGroupToPcpGroup( F );
    gens := List( Pcgs(F), x -> PreImagesRepresentative( iso, x ) );
    hom  := GroupHomomorphismByImagesNC( G, H, gens, AsList(Pcp(H)) );
    SetIsBijective( hom, true );
    return hom;
end );

#############################################################################
##
## Convert abelian groups to pcp groups.
##
if IsBound(CanEasilyComputeWithIndependentGensAbelianGroup) then
# CanEasilyComputeWithIndependentGensAbelianGroup was introduced in GAP 4.5.x

InstallMethod( IsomorphismPcpGroup,
    [ IsGroup and IsAbelian and CanEasilyComputeWithIndependentGensAbelianGroup ],
    # this method is better than the one for perm groups
    RankFilter(IsPermGroup),
    G -> IsomorphismAbelianGroupViaIndependentGenerators( IsPcpGroup, G )
    );

fi;

#############################################################################
##
## Convert special fp groups to pcp groups.
##
ClassifyRelationsOfFpGroup := function( fpgroup )
    local   gens,  rels,  allpowers,  conflicts,  relations,  rel,  n,  
            l,  g1,  e1,  g2,  e2,  g3,  e3,  g4,  e4;

    gens := GeneratorsOfGroup( FreeGroupOfFpGroup(fpgroup) );
    rels := RelatorsOfFpGroup( fpgroup );

    allpowers := [];        # list to collect power relations
    conflicts := [];        # conflicts are collected and tested later

    relations := rec();

    # power relations
    relations.rods    := List( gens, x -> 0 );
    relations.powersp := [];                     # positive exponent
    relations.powersn := [];                     # negative exponent

    # commutator relations
    relations.commpp := List( gens, x -> [] );   # [b,a]
    relations.commpn := List( gens, x -> [] );   # [b,a^-1]
    relations.commnp := List( gens, x -> [] );   # [b^-1,a]
    relations.commnn := List( gens, x -> [] );   # [b^-1,a^-1]

    # conjugate pos, pos
    relations.conjpp := List( gens, x -> [] );   # b^a
    relations.conjpn := List( gens, x -> [] );   # b^(a^-1)
    relations.conjnp := List( gens, x -> [] );   # (b^-1)^a
    relations.conjnn := List( gens, x -> [] );   # (b^-1)^(a^-1)

    # sort relators into power and commutator/conjugate relators
    for rel  in rels  do
        n := NumberSyllables( rel );
        l := Length( rel );

        if n = 1 or n = 2 then
            Add( allpowers, rel );
            
        # ignore the trivial word
        elif 2 < n  then

            # extract the first four entries
            g1 := GeneratorSyllable( rel, 1 );
            e1 := ExponentSyllable(  rel, 1 );
            g2 := GeneratorSyllable( rel, 2 );
            e2 := ExponentSyllable(  rel, 2 );
            g3 := GeneratorSyllable( rel, 3 );
            e3 := ExponentSyllable(  rel, 3 );
            if 3 < n  then 
                g4 := GeneratorSyllable( rel, 4 ); 
                e4 := ExponentSyllable(  rel, 4 );
            fi;

            # a word starting with  a^-1 x a  is a conjugate or commutator
            if e1 = -1 and e3 = 1 and g1 = g3 then

                # a^-1 b^-1 a b is a commutator
                if 3 < n and e2 = -1 and e4 = 1 and g2 = g4 and g2 < g1  then
                    if IsBound( relations.commpp[g1][g2] )  or 
                       IsBound( relations.conjpp[g1][g2] ) then
                        Add( conflicts, rel );
                    else
                        #Print( rel, " -> [", g1, ", ", g2, "]\n" );
                        relations.commpp[g1][g2] := Subword( rel, 5, l )^-1;
                    fi;
                    
                # a^-1 b a b^-1 is a commutator
                elif 3 < n and e2 = 1 and e4 = -1 and g2 = g4 and g2 < g1  then
                    if IsBound(relations.commpn[g1][g2]) or
                       IsBound(relations.conjpn[g1][g2])  then
                        Add( conflicts, rel );
                    else
                        #Print( rel, " -> [", g1, ", ", -g2, "]\n" );
                        relations.commpn[g1][g2] :=  Subword( rel, 5, l )^-1;
                    fi;

                # a^-1 b a is a conjugate
                elif e2 = 1 and g1 < g2  then
                    if IsBound(relations.conjpp[g2][g1]) or
                       IsBound(relations.commpp[g2][g1]) then
                        Add( conflicts, rel );
                    else
                        #Print( rel, " -> ", g2, "^", g1, "\n" );
                        relations.conjpp[g2][g1] := Subword( rel, 4, l )^-1;
                    fi;

                # a^-1 b^-1 a is a conjugate
                elif e2 = -1 and g1 < g2  then
                    if IsBound(relations.conjnp[g2][g1]) or
                       IsBound(relations.commnp[g2][g1]) then
                        Add( conflicts, rel );
                    else
                        #Print( rel, " -> ", -g2, "^", g1, "\n" );
                        relations.conjnp[g2][g1] := Subword( rel, 4, l )^-1;
                    fi;

                else
                    Error( "not a power/commutator/conjugate relator ", rel );
                fi;

            # a word starting with a b a^-1 is a conjugate or commutator
            elif e1 = 1 and e3 = -1 and g1 = g3  then

                # a b a^-1 b^-1 is a commutator
                if 3 < n and e2 = 1 and e4 = -1 and g2 = g4 and g2 < g1  then
                    if IsBound(relations.commnn[g1][g2]) or
                       IsBound(relations.conjnn[g1][g2]) then
                        Add( conflicts, rel );
                    else
                        #Print( rel, " -> [", -g1, ", ", -g2, "]\n" );
                        relations.commnn[g1][g2] := Subword( rel, 5, l )^-1;
                    fi;

                # a b^-1 a^-1 b is a commutator
                elif 3 < n and e2 = -1 and e4 = 1 and g2 = g4 and g2 < g1  then
                    if IsBound(relations.commnp[g1][g2]) or
                       IsBound(relations.conjnp[g1][g2]) then
                        Add( conflicts, rel );
                    else
                        #Print( rel, " -> [", -g1, ", ", g2, "]\n" );
                        relations.commnp[g1][g2] := Subword( rel, 5, l )^-1;
                    fi;

                # a b a^-1 is a conjugate
                elif e2 = 1 and g1 < g2  then
                    if IsBound(relations.conjpn[g2][g1]) or
                       IsBound(relations.commpn[g2][g1]) then
                        Add( conflicts, rel );
                    else
                        #Print( rel, " -> ", g2, "^", -g1, "\n" );
                        relations.conjpn[g2][g1] := Subword( rel, 4, l )^-1;
                    fi;

                # a b^-1 a^-1 b is a conjugate
                elif e2 = -1 and g1 < g2  then
                    if IsBound(relations.conjnp[g2][g1]) or
                       IsBound(relations.commnp[g2][g1]) then
                        Add( conflicts, rel );
                    else
                        #Print( rel, " -> ", -g2, "^", -g1, "\n" );
                        relations.conjnn[g2][g1] := Subword( rel, 4, l )^-1;
                    fi;

                else
                    Error( "not a power/commutator/conjugate relator ", rel );
                fi;

            # it must be a power
            else
                Add( allpowers, rel );
            fi;
        fi;
    od;

    # now check the powers
    for rel in allpowers do
        g1 := GeneratorSyllable( rel, 1 );
        e1 := ExponentSyllable(  rel, 1 );
        l  := Length( rel );
        
        if e1 > 0 then
            if (relations.rods[g1] <> 0 and relations.rods[g1] <> e1) 
               or IsBound(relations.powersp[g1]) then
                Add( conflicts, rel );
            fi;
            relations.rods[g1]     := e1;
            relations.powersp[g1] := Subword( rel, e1+1, l )^-1;
        else
            if (relations.rods[g1] <> 0 and relations.rods[g1] <> -e1) 
               or IsBound(relations.powersp[g1]) then
                Add( conflicts, rel );
            fi;
            relations.rods[g1]     := -e1;
            relations.powersn[ g1] := Subword( rel, -e1+1, l )^-1;
        fi;
    od;

    relations.conflicts := conflicts;
    return relations;
end;

FromTheLeftCollectorByRelations := function( gens, rels )
    local   ftl,  j,  i;

    ftl := FromTheLeftCollector( Length(gens) );

    for i in [ 1 .. Length(gens) ] do
        SetRelativeOrder( ftl, i, rels.rods[i] );
        if IsBound( rels.powersp[i] ) then
           SetPower( ftl, i, rels.powersp[i] );
           Unbind( rels.powersp[i] );
        fi;
    od;

    for j  in [ 1 .. Length(gens) ]  do
        for i  in [ 1 .. j-1 ]  do
            if IsBound( rels.conjpp[j][i] )  then
                SetConjugate( ftl, j, i, rels.conjpp[j][i] );
                #Print( "conjpp", [j,i], ": ", rels.conjpp[j][i], "\n" );
                Unbind( rels.conjpp[j][i] );
            elif IsBound( rels.commpp[j][i] )  then
                SetConjugate( ftl, j, i, gens[j]*rels.commpp[j][i] );
                #Print( "commpp", [j,i], ": ", gens[j]*rels.commpp[j][i], "\n" );
                Unbind( rels.commpp[j][i] );
            elif IsBound( rels.conjnp[j][i] )  then
                SetConjugate( ftl, j, i, rels.conjnp[j][i]^-1 );
                #Print( "conjnp", [j,i], ": ", rels.conjnp[j][i]^-1, "\n" );
                Unbind( rels.conjnp[j][i] );
            elif IsBound( rels.commnp[j][i] )  then
                SetConjugate( ftl, j, i, (gens[j] * rels.commnp[j][i])^-1 );
                #Print( "commnp", [j,i], ": ", (gens[j] * rels.commnp[j][i])^-1, "\n" );
                Unbind( rels.commnp[j][i] );
            fi;
        od;
    od;
    return ftl;
end;

PcpGroupFpGroupPcPres := function( G )
    local   gens,  rels,  ftl,  ev,  rel;

    gens := GeneratorsOfGroup( FreeGroupOfFpGroup( G ) );
    rels := ClassifyRelationsOfFpGroup( G );
    ftl  := FromTheLeftCollectorByRelations( gens, rels );

    ev := List( gens, g->0 );
    for rel in rels.conflicts do
        while CollectWordOrFail( ftl, ev, ExtRepOfObj( rel ) ) = fail do
        od;

        if ev <> ev * 0 then
            Error( "finitely presented group is not a pcp group" );
        fi;
    od;

    return PcpGroupByCollector( ftl );
end;

IsomorphismPcpGroupFromFpGroupWithPcPres := function(G)
    local H, hom;

    H := PcpGroupFpGroupPcPres( G );
    hom := GroupHomomorphismByImagesNC( G, H, 
                   GeneratorsOfGroup( G ), GeneratorsOfGroup(H) );
    SetIsBijective( hom, true );
    return hom;
end;

