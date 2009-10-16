#############################################################################
##
#A  wygraph.gi                Cryst library                      Bettina Eick
#A                                                              Franz G"ahler
#A                                                              Werner Nickel
##
#Y  Copyright 1997-1999  by  Bettina Eick,  Franz G"ahler  and  Werner Nickel
##
##  Routines for the determination and the display of a Wyckoff graph
##

#############################################################################
##
#M  CompareLevels( param1, param2 ) . . . . . . . . . . . . . . CompareLevels 
##
InstallMethod( CompareLevels, true,
    [ IsGraphicPosetRep and IsWyckoffGraph, IsList, IsList ], 0,
function( graph, level1, level2 )
    # a smaller dimension is higher
    if   level1[1] < level2[1] then
        return -1;
    elif level1[1] > level2[1] then
        return 1;
    else
        # for equal dimension, the bigger size is higher
        if   level1[2] > level2[2] then
            return -1;
        elif level1[2] > level2[2] then
            return 1;
        else
            return 0;
        fi;
    fi;
end );

#############################################################################
##
#F  WyckoffPosRelations( <W> ) . . . incidence relations of Wyckoff positions
##
WyckoffPosRelations := function( W )
    local S, T, d, len, gens, G, L, m, O, o, i, j, k, Si, Sj, index, lst;

    S := WyckoffSpaceGroup( W[1] );
    T := TranslationBasis( S );
    d := DimensionOfMatrixGroup( S ) - 1;
    len  := Length( W );
    gens := GeneratorsOfGroup( S );
    gens := Filtered( gens, g -> g{[1..d]}{[1..d]} <> IdentityMat( d ) );
    if IsAffineCrystGroupOnLeft( S ) then
        gens := List( gens, TransposedMat );
    fi;
    G := GroupByGenerators( gens, One( S ) );
    L := List( W, w -> rec( translation := WyckoffTranslation( w ),
                            basis       := WyckoffBasis( w ),
                            spaceGroup  := S ) );

    m := NullMat( len, len );
    for i in [1..len] do
        O := Orbit( G, L[i], ImageAffineSubspaceLattice );
        for j in [1..len] do
            Sj := WyckoffStabilizer( W[j] );
            Si := WyckoffStabilizer( W[i] );
            index := Size(Sj) / Size(Si);
            if Length(L[j].basis) < Length(L[i].basis) and IsInt(index) then
                lst := Filtered(O,o->IsSubspaceAffineSubspaceLattice(o,L[j]));
                m[j][i] := Length( lst );
            fi;
        od;
    od;

    for i in Reversed([1..Length(W)]) do
        for j in Reversed([1..i-1]) do
            if m[j][i]<>0 then
                for k in [1..j-1] do
                    if m[k][j]<>0 then m[k][i]:=0; fi;
                od;
            fi;
        od;
    od;

    return m;

end;

#############################################################################
##
#F  WyckoffGraphRecord( <lst> ) . . . . . . . Create record for Wyckoff graph
##
WyckoffGraphRecord := function( lst )

    local L, m, R, i, level, j;

    L := List( lst, w -> rec( wypos := w, 
                              dim   := Length( WyckoffBasis(w) ), 
                              size  := Size( WyckoffStabilizer(w) ),
                              class := w!.class ) );
    Sort( L, function(a,b) return a.size > b.size; end );

    m := WyckoffPosRelations( List( L, x -> x.wypos ) );

    R := rec( levels   := [],
              classes  := [],
              vertices := [],
              edges    := [] );

    for i in [1..Length(L)] do
        level := [ L[i].dim, L[i].size ];
        AddSet( R.levels, level );
        AddSet( R.classes, [ L[i].class, level ] );
        Add( R.vertices, [ L[i].wypos, level, L[i].class ] );
        for j in [1..i-1] do
            if m[j][i]<>0 then Add( R.edges, [ i, j, m[j][i] ] ); fi;
        od;
    od;

    return R;

end;

#############################################################################
##
#M  WyckoffGraphFun( W, def ) . . . . . . . . . . . . display a Wyckoff graph 
##
InstallGlobalFunction( WyckoffGraphFun, function( W, def )

    local S, defaults, R, wygr, x, vertices, i, v, info, data, v1, v2;

    # set up defaults
    S := WyckoffSpaceGroup( W[1] );
    defaults := rec(width := 800,
                    height := 600,
                    title := "WyckoffGraph");
    if HasName(S) then
        defaults.title := Concatenation( defaults.title, " of ", Name(S) );
    fi;
  
    if IsBound(def.width)  then defaults.width  := def.width;  fi;
    if IsBound(def.height) then defaults.height := def.height; fi;
    if IsBound(def.title)  then defaults.title  := def.title;  fi;

    R := WyckoffGraphRecord( W );

    # open a graphic poset and make it a Wyckoff graph
    wygr := GraphicPoset( defaults.title, defaults.width, defaults.height );
    SetFilterObj( wygr, IsWyckoffGraph );

    # create levels
    for x in R.levels do
        CreateLevel( wygr, x, String( x ) );
    od;

    # create classes
    for x in R.classes do
        CreateClass( wygr, x[2], x[1] );
    od;

    # create vertices
    vertices := [];
    for i in [1..Length(R.vertices)] do
        v := R.vertices[i];
        info := rec( label := String(i),
                     levelparam := v[2],
                     classparam := v[3] );
        data := rec( wypos := v[1], info := rec() );
        Add( vertices, Vertex( wygr, data, info ) );
    od;

    # create edges
    for x in R.edges do
        v1 := vertices[ x[1] ];
        v2 := vertices[ x[2] ];
        Edge( wygr, v1, v2, rec( label := String( x[3]) ) );
    od;

    # Install the info method
    wygr!.selector := false;
    wygr!.infodisplays := WyckoffInfoDisplays;
    InstallPopup( wygr, GGLRightClickPopup );

    return wygr;

end );



