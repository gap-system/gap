#############################################################################
##
#W  frattfree.gi                GrpConst                         Bettina Eick
#W                                                         Hans Ulrich Besche
##
Revision.("grpconst/gap/fratfree_gi") :=
    "@(#)$Id: fratfree.gi,v 1.13 2005/02/15 12:19:24 gap Exp $";

#############################################################################
##
#F CheckFlags( flags )
##
## Possible flags:
##   nilpotent = true             - nilpotent groups
##   nonnilpot = true             - non-nilpotent groups
##   supersol  = true             - supersoluble groups
##   nonsupsol = true             - non-supersoluble groups
##   pnormal   = list of primes   - groups with normal Sylowgroup
##   nonpnorm  = list of primes   - groups without normal Sylowgroup
##
## If a flag is bound, then the algorithm constructs the groups with 
## this property only. Otherwise the flag should be unbound.
## Note: only the positive flags yield an improved efficiency of the method.
##
## This function checks the consistency of the given flags.
##
InstallGlobalFunction( CheckFlags, function( flags )

    # first a consistency check
    if
    (IsBound( flags.nilpotent ) and flags.nilpotent <> true ) or
    (IsBound( flags.nonnilpot ) and flags.nonnilpot <> true ) or
    (IsBound( flags.supersol ) and flags.supersol <> true ) or
    (IsBound( flags.nonsupsol ) and flags.nonsupsol <> true ) or
    (IsBound( flags.pnormal ) and not IsList( flags.pnormal ) ) or
    (IsBound( flags.nonpnorm ) and not IsList( flags.nonpnorm ) ) 
    then
        Error("not a possible flags record");
    fi;

    # nilpotent
    if IsBound( flags.nilpotent ) then
        flags.supersol := true;
        if IsBound( flags.nonnilpot ) then return false; fi;
        if IsBound( flags.nonsupsol ) then return false; fi;
        if IsBound( flags.nonpnorm ) then return false; fi;
    fi;

    # supersol
    if IsBound( flags.supersol ) then
        if IsBound( flags.nonsupsol ) then return false; fi;
    fi;

    # nonsupsol
    if IsBound( flags.nonsupsol ) then
        flags.nonnilpot := true;
    fi;

    # pnormal 
    if IsBound( flags.pnormal ) and IsBound( flags.nonpnorm ) then
        if Length(Intersection( flags.pnormal, flags.nonpnorm ))>0 then
            return false;
        fi;
    fi;

    # nonpnorm
    if IsBound( flags.nonpnorm ) then
        flags.nonnilpot := true;
    fi;
  
    return true;
end );
    
#############################################################################
##
#F CompareFlagsAndSize( size, flags )
##
## Returns a reduces size or false.
##
InstallGlobalFunction( CompareFlagsAndSize, function( size, flags )

    # compare with nilpotent
    if size = 1 and IsBound( flags.nonnilpot) then
        return false;
    fi;
    if IsBound( flags.nilpotent ) then
        size := 1;
    fi;

    # compare with pnormal
    if IsBound( flags.nonpnorm ) and
       not ForAll( flags.nonpnorm, x -> IsInt(size/x) ) then
        return false;
    fi;
    if IsBound( flags.pnormal ) then
        size := FactorsInt( size );
        size := Filtered( size, x -> not x in flags.pnormal );
        size := Product( size );
    fi;

    return size;
end );

#############################################################################
##
#F FilterByFlags( grps, flags )
##
FilterByFlags := function( grps, flags )
    local p;
    if IsBound( flags.nonnilpot ) then
        grps := Filtered( grps, x -> Size( x ) > 1 );
    fi;
    if IsBound( flags.nonpnorm ) then
        for p in flags.nonpnorm do
            grps := Filtered( grps, x -> IsInt(Size(x)/p) );
        od;
    fi;
    if IsBound( flags.nonsupsol ) then
        grps := Filtered( grps, x -> Set( SocleDimensions(x) ) <> [1] );
    fi;
    return grps;
end;

#############################################################################
##
#F RunSubdirectProductInfo( U ) 
##
InstallGlobalFunction( RunSubdirectProductInfo, function( U )
    local info, proj, new, dims;
 
    info := SubdirectProductInfo( U );
    proj := [];
    if HasProjections( info.groups[1] ) then
        new  := Projections( info.groups[1] );
        Append( proj, List( new, x -> info.projections[1] * x ) );
    fi;
    if HasProjections( info.groups[2] ) then
        new  := Projections( info.groups[2] );
        Append( proj, List( new, x -> info.projections[2] * x ) );
    fi;
    if Length( proj ) > 0 then
        SetProjections( U, proj );
    fi;
    dims := [];
    if HasSocleDimensions( info.groups[1] ) then
        Append( dims, SocleDimensions( info.groups[1] ) );
    fi;
    if HasSocleDimensions( info.groups[2] ) then
        Append( dims, SocleDimensions( info.groups[2] ) );
    fi;
    if Length( dims ) > 0 then 
        SetSocleDimensions( U, dims );
    fi;
end );

#############################################################################
##
#F SocleComplements( semi, sizes )
##
## Construct socle complements from semisimle groups using subdirect prods.
##
InstallGlobalFunction( SocleComplements, function( semi, sizes )
    local all, i, tmp, U, V, sub, j;

    # for technical reasons
    if IsInt( sizes ) then sizes := [sizes]; fi;

    # create subdirect products
    all := semi[1];
    for i in [2..Length(semi)] do
        tmp := [];
        for U in all do
            for V in semi[i] do
                sub := SubdirectProducts( U, V );
                sub := Filtered( sub, 
                       x -> ForAny( sizes, y -> IsInt( y / Size(x) ) ) );
                Append( tmp, sub );
            od;
        od;
        all := tmp;
        for j in [1..Length(all)] do
            RunSubdirectProductInfo( all[j] );
        od;
    od;
    return all;
end );
   
#############################################################################
##
#F ExtensionBySocle( U )
##
## Compute extension of socle complement by sockel as pc-group codes.
##
InstallGlobalFunction( ExtensionBySocle, function( U ) 
    local iso, n, inv, H, proj, pr, imgs, new, fac, pcgs, L; 

    iso := IsomorphismPcGroup( U );
    #inv := GroupHomomorphismByImagesNC( Range(iso), Source(iso),
    #       iso!.genimages, AsList( iso!.generators ) );
    inv := InverseGeneralMapping( iso );
    H   := Image( iso );
    n   := Length( Pcgs( H ) )+1;
    fac := IdentityMapping( H );
    proj := Projections( U );
    for pr in proj do
        inv  := fac * inv;
        imgs := List( Pcgs(H), x -> Image( inv, x ) );
        imgs := List( imgs, x -> Image( pr, x ) );
        new  := GroupHomomorphismByImagesNC( H, Range( pr ), 
                AsList( Pcgs(H) ), imgs );
        H    := SemidirectProduct( H, new );
        fac  := Projection( H );
    od;

    return rec( code := CodePcGroup( H ),
                order := Size( H ),
                isFrattiniFree := true,
                first := [1, n, Length(Pcgs(H))+1],
                socledim := SocleDimensions( U ),
                extdim := [],
                isUnique := true );
end );

#############################################################################
##
#F FrattiniFreeBySocle( sizeA, sizeF, flags ) . . . compute ff groups to a
##                                                   given socle
##
InstallGlobalFunction( FrattiniFreeBySocle, function( sizeA, sizeF, flags )
    local A, sizeK, max, semi, all, i;

    Info( InfoGrpCon, 2, "  compute ff groups with socle ", 
                              sizeA," and size ",sizeF );

    # check the sizes
    if not IsInt( sizeF/sizeA ) then return []; fi;

    # check the flags 
    if not CheckFlags( flags ) then return []; fi;

    # set up and compute sizes
    A := List( Collected(FactorsInt(sizeA)), x -> [x[2], x[1]] );
    max := Product( List( A, x -> SizeOfGL( x[1], x[2] ) ) );
    if not IsBool( sizeF ) then
        sizeK := Gcd( sizeF / sizeA, max );
    else
        sizeK := max;
    fi;

    # compare flags with sizeK 
    sizeK := CompareFlagsAndSize( sizeK, flags );
    if IsBool( sizeK ) then return []; fi;
    
    # construct semisimple groups
    semi := List( A, x -> SemiSimpleGroups( x[1], x[2], sizeK, flags ) );

    # now construct corresponding pc-groups
    all := SocleComplements( semi, sizeK );
    all := FilterByFlags( all, flags );
    for i in [1..Length( all )] do
        all[i] := ExtensionBySocle( all[i] );
    od;
    return all;
end );


   
#############################################################################
##
#F FrattiniFreeBySize( size, flags ) . . . compute ff groups of dividing size
##
InstallGlobalFunction( FrattiniFreeBySize, function( size, flags )
    local socs, grps, soc, max, siz, tmp;

    # check the flags 
    if not CheckFlags( flags ) then return []; fi;

    # get all possible sockes
    socs := DivisorsInt( size );
    socs := Filtered( socs, x -> x > 1 );

    # for each socle get the sizes and compute groups
    grps := [];
    for soc in socs do
        max := MaximalAutSize( soc );
        siz := Gcd( max*soc, size );

        # now construct groups
        tmp := FrattiniFreeBySocle( soc, siz, flags );
        Append( grps, tmp );
    od;
    return grps;
end );
            
#############################################################################
##
#F DecodeList( list ) . . . . . . . . . . . . . . . . .decode a list of codes 
##
DecodeList := function( list )
    return List( list, x -> PcGroupCodeRec( x ) );
end;

#############################################################################
##
#F FrattiniFactorCandidates( size, flags, code ) . . . candidates
##
InstallGlobalFunction( FrattiniFactorCandidates, function( arg )
    local size, flags, code, fflist, pr;
    size := arg[1];
    flags := arg[2];
    fflist := FrattiniFreeBySize( size, flags );
    pr     := Product( Set( FactorsInt( size ) ) );
    fflist :=  Filtered( fflist, 
               x -> IsInt( x.order/pr ) and IsInt(size/x.order));
    if Length( arg ) = 2 then
        return fflist;
    else
        return DecodeList( fflist );
    fi;
end );

#############################################################################
##
#F FrattFreeNonNilUpToSize( soc, limit ) . .  compute non-nilpotent ff groups
##
FrattiniFreeNonNilUpToSize := function( soc, limit )
    local sizs, pos, rem, new, grps, i, j, tmp, flags, max;
   
    # all possible sizes
    sizs := [];
    max := MaximalAutSize( soc );
    if max*soc <= limit then
        sizs := [max*soc];
    else
        pos  := List( [1..limit], x -> x/soc );
        rem  := Filtered( pos, x -> IsInt( x ) );
        rem  := List( rem, x -> Gcd( x, max ) );
        sizs := MinimizeList( rem );
        if sizs = [1] then return []; fi;
        sizs := sizs*soc;
    fi;

    # the flags 
    flags := rec( nonnilpot := true );

    # now construct groups
    grps := [];
    for j in [1..Length(sizs)] do
        tmp := FrattiniFreeBySocle( soc, sizs[j], flags );
        tmp := Filtered( tmp, 
               x -> UnknownSize( sizs{[1..j-1]}, x.order ) );
        Append( grps, tmp );
    od;
            
    return grps;
end;

#############################################################################
##
#F CheckFrattFreeNonNil( limit ) . . . . . . . . . . . . . . .a check routine
##
CheckFrattFreeNonNil := function( n )
    local socs, erg1, soc, new, erg2;

    socs := [2..QuoInt(n,2)];
    erg1 := [];
    for soc in socs do
        new := FrattiniFreeNonNilUpToSize( soc, n );
        new := DecodeList( new );
        new := List( new, x -> IdGroup( x ) );
        Append( erg1, new );
    od;
    Sort( erg1 );
    Print( erg1, "\n");

    erg2 := List( Difference( [2..n], [512] ), x -> 
            IdsOfAllGroups( x, FrattinifactorSize, x, 
                               IsAbelian, false,
                               IsSolvableGroup, true ) );
    erg2 := Concatenation( erg2 );
    Sort( erg2 );
    Print( erg2, "\n");
  
    return erg1 = erg2;

end;

