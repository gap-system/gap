#############################################################################
##
#W  frattext.gi                 GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
Revision.frattext_gi :=
    "@(#)$Id$";

#############################################################################
##
#F IntCoefficients( primes, vec )
##
IntCoefficients := function( primes, vec )
    local int, i;
    int := 0;
    for i in [1..Length(primes)] do
        int := int * primes[i] + vec[i];
    od;
    return int;
end;

#############################################################################
##
#F RandomIsomorphismTest( list, n )
##
InstallGlobalFunction( RandomIsomorphismTest, function( list, n )
    local codes, conds, code, found, i, j, k, l, rem, c;

    # catch trivial case
    if Length( list ) = 1 or Length( list ) = 0 then return list; fi;

    # unpack
    for i in [1..Length(list)] do
        list[i].group := PcGroupCode( list[i].code, list[i].order );
    od;

    # set up
    codes := List( list, x -> [x.code] );
    conds := List( list, x -> 0 );
    rem   := Length( list );
    c := 0;

    while Minimum( conds ) <= n and rem > 1 do
        for i in [1..Length(list)] do
            if Length( codes[i] ) > 0 then
                code := RandomSpecialPcgsCoded( list[i].group );
                if code in codes[i] then
                    conds[i] := conds[i]+1;
                fi;

                found := false;
                j     := 1;
                while not found and j <= Length( list ) do
                    if j <> i then
                        if code in codes[j] then
                            found := true;
                        else 
                            j := j + 1;
                        fi;
                    else 
                        j := j + 1;
                    fi;
                od;

                if found then
                    k := Minimum( i, j );
                    l := Maximum( i, j );
                    codes[k] := Union( codes[k], codes[l] );
                    codes[l] := [];
                    conds[k] := 0;
                    conds[l] := n+1;
                    rem := rem - 1;
                else
                    AddSet( codes[i], code );
                fi;
            fi;
        od;

		# just for information
        c := c+1;
        if c mod 10 = 0 then
            Info( InfoFrattExt, 5, "     ", c, " loops, ", 
                  rem, " groups ", 
                  conds{ Filtered( [ 1 .. Length( list ) ],
		  x -> Length( codes[ x ] ) > 0 ) }," doubles ",
	 	  List( codes{ Filtered( [ 1 .. Length( list ) ],
		  x -> Length( codes[ x ] ) > 0 ) }, Length ),
		  " presentations");
        fi;
    od;
    
    # cut out information
    for i in [1..Length(list)] do
        Unbind( list[i].group );
    od;

    # and return
    return list{ Filtered( [1..Length(codes)], x -> Length(codes[x])>0 ) };
end );

#############################################################################
##
#F ReducedByIsomorphisms( list ) 
##
ReducedByIsomorphisms := function( list )
    local subl, fins, i, fin, j, info, done, new, H;

    # the trivial cases
    if Length( list ) = 0 then return list; fi;

    if Length( list ) = 1 then 
        list[1].isUnique := true;
        return list; 
    fi;
 
    Info( InfoFrattExt, 3, "  reduce ", Length(list), " groups " );

    # first split the list
    Info( InfoFrattExt, 4, "   Iso: split list by invariants ");
    done  := [];
    subl  := [];
    fins  := [];
    for i in [1..Length(list)] do
        if list[i].isUnique then 
            Add( done, list[i] );
        else
            H   := PcGroupCode( list[i].code, list[i].order );
            fin := FingerprintFF( H );
            fin := Concatenation( list[i].extdim, fin ); 
            j   := Position( fins, fin );
            if IsBool( j ) then
                Add( subl, [list[i]] );
                Add( fins, fin );
            else
                Add( subl[j], list[i] );
            fi;
        fi;
    od;

    # now remove isomorphic copies
    for i in [1..Length(subl)] do
        Info( InfoFrattExt, 4, "   Iso: reduce list of length ", 
                               Length(subl[i]));
        subl[i] := RandomIsomorphismTest( subl[i], 10 );
        if Length( subl[i] ) = 1 then
            subl[i][1].isUnique := true;
            Add( done, subl[i][1] );
            Unbind( subl[i] );
        fi;
    od;

    subl := Compacted( subl );
    Sort( subl, function( x, y ) return Length(x)<Length(y); end );
   
    # return 
    return Concatenation( done, subl );
end;

#############################################################################
##
#F EnlargedModule( M, F, H )
##
EnlargedModule := function( M, F, H )
    local N, l, mats;
    N := ShallowCopy( M );
    l := Length( Pcgs( H ) ) - Length( Pcgs( F ) );
    mats := List( [1..l], x -> IdentityMat( M.dimension, M.field ) );
    N.generators := Concatenation( N.generators, mats );
    return N;
end;

#############################################################################
##
#F FindUniqueModules( modus )
##
FindUniqueModules := function( list )
    local modus, i, j, dims, cent;
        
    for modus in list do

        # find the ones with unique dimension
        dims := List( modus, x -> x.dimension );
        for j in [1..Length(modus)] do
            if Length( Filtered(dims, x -> x = modus[j].dimension) ) = 1
            then
                modus[j].unique := true;
            else
                modus[j].unique := false;
            fi;
            modus[j].central := false;
        od;

        # find the trivial module 
        for j in [1..Length(modus)] do
            if ForAll( modus[j].generators, x -> x = x^0 ) then
                modus[j].unique := true;
                modus[j].central := true;
            fi;
        od;
    od;
end;

#############################################################################
##
#F CentralModules( F, field, d )
##
CentralModules := function( F, field, d )
    local modus, i, mats, modu;
    modus := [];
    for i in [2..d] do
        mats := List( Pcgs(F), x -> IdentityMat( i, field ) );
        modu := GModuleByMats( mats, field );
        modu.unique := true;
        modu.central := true;
        Add( modus, modu );
    od;
    return modus;
end;

#############################################################################
##
#F IsCentralExtension( F, ext )
##
IsCentralExtension := function( F, ext )
    local pcgs, N;
    pcgs := Pcgs( ext );
    N := Subgroup( ext, pcgs{[Length(Pcgs(F))+1..Length(pcgs)]} );
    return IsElementaryAbelian(N) and IsCentral( ext, N );
end;

#############################################################################
##
#F FrattiniExtensionsOfCode( code, o )
##
FrattiniExtensionsOfCode := function( code, o )
    local primes, prim, modus, grps, exts, min, sub, H, rest, tup,
          j, modu, M, size, new, i, count, p, d, grp, F;

       
    # the trivial cases
    if code.order = o then return [code]; fi;

    # check size
    if not Set( FactorsInt( code.order ) ) = Set( FactorsInt( o ) ) or
       not IsInt( o/code.order ) then
        return []; 
    fi;

    # construct irreducible modules for F
    F      := PcGroupCodeRec( code );
    rest   := o / code.order;
    primes := Collected( FactorsInt( rest ) );
    prim   := List( primes, x -> x[1] );
    modus  := List( primes, x -> IrreducibleModules( F, GF(x[1]), x[2] ) );
    FindUniqueModules( modus );

    # set up
    grps := [];
    exts := [code]; 

    # start loop
    while Length( exts ) > 0 do

        min := Minimum( List( exts, x -> x.order ) );
        sub := Filtered( exts, x -> x.order = min );
        exts:= Filtered( exts, x -> x.order > min );
        sub := Flat( ReducedByIsomorphisms( sub ) );
        Info( InfoFrattExt, 2," next layer with ",Length(sub),
                              " groups of order ", min );
        
        # loop over elements in sub
        for i in [1..Length(sub)] do

            # the Frattini free group is a special case
            H := PcGroupCodeRec( sub[i] );

            rest := o / Size( H );
            tup  := Collected( FactorsInt( rest ) )[1];
            j    := Position( prim, tup[1] );
            modu := Filtered( modus[j], x -> x.dimension <= tup[2] );
            modu := List( modu, x -> EnlargedModule( x, F, H ) );

            Info( InfoFrattExt, 3,"  start ", i, " with ",
                                    Length(modu)," modules");

            # loop over modules
            count := 1;
            for M in modu do
                
                # create extensions
                d := M.dimension;
                p := Characteristic( M.field );
                size := Size( H ) * p^d; 
                new := NonSplitExtensions( H, M );

                # create grp records
                for j in [1..Length(new.groups)] do

                    grp := rec( code := CodePcGroup( new.groups[j] ),
                                order := size,
                                isFrattiniFree := false );
                    grp.first := code.first;
                    grp.socledim := code.socledim; 
                    grp.extdim := ShallowCopy( sub[i].extdim );
                    Add( grp.extdim, p^d );
                    Sort( grp.extdim );
                    grp.isUnique := (new.reduced and M.unique and
                                     sub[i].isFrattiniFree );

                    new.groups[j] := grp;
                    count := count + 1;
                od;
                
                if size = o then
                    Append( grps, new.groups );
                else
                    Append( exts, new.groups );
                fi;
                Unbind( new );
            od;
        od;
    od;
    grps := ReducedByIsomorphisms( grps );
    Info( InfoFrattExt, 2," determined ", Length( grps ),
                          " classes with groups of order ",o);
    return grps;
end;

#############################################################################
##
#F FrattiniExtensionsOfGroup( F, size )
##
FrattiniExtensionsOfGroup := function( F, size )
    local P, S, K, pcgs, code;

    P := FrattiniSubgroup( F );
    if not Size(P) = 1 then
        Error(" group must be Frattini free ");
    fi;
    S := FittingSubgroup( F );
    K := Complementclasses( F, S )[1];
    pcgs := PcgsByPcSequence( FamilyObj( One(F) ),
                              Concatenation( Pcgs( K ), Pcgs(S) ) );
    code := rec( code := CodePcgs( pcgs ),
                 order := Size( F ),
                 isFrattiniFree := true,
                 first := [1, Length(Pcgs(K))+1, Length(pcgs)+1],
                 socledim := false,
                 extdim := [],
                 exindent := [],
                 isUnique := true ); 
    return FrattiniExtensionsOfCode( code, size );
end;
        
#############################################################################
##
#F FrattiniExtensions( list, size [,uncoded] )
##
FrattiniExtensions := function( arg )
    local res, new, F, i;
    res := [];
    for i in [1..Length(arg[1])] do
        F := arg[1][i];
        if IsPcGroup( F ) then
            Info( InfoFrattExt, 1, "extend candidate number ",i,
                                   " of ",Length(arg[1]),
                                   " with size ",Size(F) );
            new := FrattiniExtensionsOfGroup( F, arg[2] );
            Append( res, new );
        else
            Info( InfoFrattExt, 1, "extend candidate number ",i,
                                   " of ",Length(arg[1]),
                                   " with size ",F.order );
            new := FrattiniExtensionsOfCode( F, arg[2] );
            Append( res, new );
        fi;
    od;

    if Length( arg ) = 3 and arg[3] then
        for i in [1..Length(res)] do
            if IsList( res[i] ) then
                res[i] := List( res[i], PcGroupCodeRec );
            else
                res[i] := PcGroupCodeRec( res[i] );
            fi;
        od;
    fi;
    return res;
end;

#############################################################################
##
#F FrattiniExtensionMethod( size [, flags, uncoded] )
##
FrattiniExtensionMethod := function( arg )
    local prop, code, free, ext, i;

    # catch the arguments
    if Length( arg ) = 1 then
        prop := rec();
        code := false;
    elif Length( arg ) = 2 then
        if IsBool( arg[2] ) then
            code := arg[2];
            prop := rec();
        else
            prop := arg[2];
            code := false;
        fi;
    else
        prop := arg[2];
        code := arg[3];
    fi;

    Info( InfoFrattExt, 1, "compute Frattini factors");
    free := FrattiniFactorCandidates( arg[1], prop );
    Info( InfoFrattExt, 1, "found ",Length( free )," candidates ");
    Info( InfoFrattExt, 1, "compute Frattini extensions ");
    ext  := FrattiniExtensions( free, arg[1] );
    Info( InfoFrattExt, 1, "found ", Length( Flat(ext) )," extensions ");

    if code then
        for i in [1..Length(ext)] do
            if IsList( ext[i] ) then
                ext[i] := List( ext[i], PcGroupCodeRec );
            else
                ext[i] := PcGroupCodeRec( ext[i] );
            fi;
        od;
    fi;
    return ext;
end;
