#############################################################################
##
#W  onecohom.gi                  Polycyc                         Bettina Eick
##

#############################################################################
##
#F OneCocyclesEX( A )
#F OneCocyclesCR( A )
##
InstallGlobalFunction( OneCocyclesEX, function( A )
    local sys, c, w;

    # add equations for relators
    sys := CRSystem( A.dim, Length(A.mats), A.char );
    for c in A.enumrels do
        w := CollectedRelatorCR( A, c[1], c[2] );
        if IsBound( A.extension) then
            AddEquationsCR( sys, w[1], w[2], false );
        else
            AddEquationsCR( sys, w[1], w[2], true );
        fi;
    od;

    # solve system
	return rec( basis := KernelCR( A, sys ), transl := SpecialSolutionCR( A, sys ) );
end );

InstallGlobalFunction( OneCocyclesCR, function( A )
    return OneCocyclesEX( A ).basis;
end );

#############################################################################
##
#F OneCoboundariesEX( A ) . . . . . . . . . . one cobounds and transformation
#F OneCoboundariesCR( A ) 
##
InstallGlobalFunction( OneCoboundariesEX, function( A )
    local n, mat, i, v, j;

    # create a matrix
    mat := [];
    if not IsBound( A.central ) or not A.central then
        n   := Length( A.mats );
        for i in [1..A.dim] do
            v := [];
            for j in [1..n] do
                Append( v, A.mats[j][i] - A.one[i] );
            od;
            Add( mat, v );
        od;
    fi;

    # compute the space spanned by the matrix
    return ImageCR( A, rec( base := mat ) );
end );

InstallGlobalFunction( OneCoboundariesCR, function( A )
    return OneCoboundariesEX( A ).basis;
end );

#############################################################################
##
#F OneCohomologyCR( C ) . . . . . . . . . . . . . . . . . . .extended version
##
InstallGlobalFunction( OneCohomologyCR, function( C )
    local cc, cb;
    cc  := OneCocyclesCR( C );
    cb  := OneCoboundariesCR( C );
    return rec( gcc := cc, gcb := cb,
                factor := AdditiveFactorPcp( cc, cb, C.char ) );
end );

#############################################################################
##
#F InverseCohMapping( coh, base )
##
InverseCohMapping := function( coh, base )
    local l, mat, new, dep, i;

    # for the empty space we do not need to do this
    if Length( base ) = 0 then return false; fi;

    # compute full basis
    l := Length( coh.sol );
    mat := MutableIdentityMat( l );
    if not IsBool( coh.fld ) then mat := mat * One( coh.fld ); fi;

    # extend base to full lattice
    dep := List( base, PositionNonZero );
    new := List( base, x -> MutableCopyMat(x) );
    for i in [1..l] do
        if not i in dep then Add( new, mat[i] ); fi;
    od;

    # return inverse
    return new^-1;
end;

#############################################################################
##
#F OneCohomologyEX( C ) . . . . . . . . . . . . . . . . . . .extended version
##
InstallGlobalFunction( OneCohomologyEX, function( C )
    local cc, cb, coh;

    # compute cocycles and cobounds
    cc := OneCocyclesEX( C );
    if IsBool( cc.transl ) then return fail; fi;
    cb := OneCoboundariesEX( C );

    # set up cohomology record
    coh := rec( gcc := cc.basis,              # 1-cocycles
                gcb := cb.basis,              # 1-coboundaries
                sol := cc.transl,             # special solution
                trf := cb.transf,             # convertion A -> cb
                rls := cb.fixpts );           # the fixed points

    # add the field
    if C.char > 0 then coh.fld := GF( C.char ); fi;
    if C.char = 0 then coh.fld := true; fi;

    # add decription of the factor gcc/gcb
    coh.factor := AdditiveFactorPcp( coh.gcc, coh.gcb, C.char );

    # compute linear mapping extend coh.gcc to an full basis
    coh.invgcc := InverseCohMapping( coh, coh.gcc );

    # add conversion functions 
    coh.CocToCCElement := function( coh, coc )
        local new;
        if Length( coh.gcc ) = 0 then return []; fi;
        new := coc * coh.invgcc;
        return new{[ 1..Length(coh.gcc)]};
    end;

    # add conversion functions 
    coh.CocToCBElement := function( coh, coc )
        local new;
        if Length( coh.gcb ) = 0 then return []; fi;
        if IsBool( coh.fld ) then
            return PcpSolutionIntMat( coh.gcb, coc );
        else
            return SolutionMat( coh.gcb, coc );
        fi;
        new := coc * coh.invgcb;
        return new{[ 1..Length(coh.gcb)]};
    end;

    coh.ElementToCoc := function( gc, elm )
        return IntVector( elm * gc );
    end;

    coh.CocToFactor := function( coh, coc )
        local elm, i;
        elm := coh.CocToCCElement( coh, coc );
        elm := elm * coh.factor.imgs;
        if IsBool( coh.fld ) then
            for i in [1..Length(elm)] do
                if coh.factor.rels[i] > 0 then 
                    elm[i] := elm[i] mod coh.factor.rels[i];
                fi;
            od;
        fi;
        return elm;
    end;        

    coh.FactorToCoc := function( coh, elm )
        return elm * coh.factor.prei;
    end;

    # return
    return coh;
end );

#############################################################################
##
#F ComplementCR( C, c ) . . . . . . . . . . . . . . . .for c an affine vector
##
ComplementCR := function( A, c )
    local pcpK, l, vec, K, all;

    # if A has no group, then we want the split extension
    if not IsBound( A.group ) then
        A.group  := ExtensionCR( A, false );
        A.factor := Pcp( A.group, A.group!.module );
        A.normal := Pcp( A.group!.module, "snf" );
    fi;

    # compute complement corresponding to c
    l    := Length( A.factor );
    vec  := CutVector( IntVector( c ), l );
    pcpK := List([1..l], i -> A.factor[i] * MappedVector(vec[i], A.normal));
    all  := AddIgsToIgs( pcpK, DenominatorOfPcp( A.normal ) );
    #K    := SubgroupByIgs( A.group, all );
    K    := Subgroup( A.group, all );
    K!.compgens := pcpK;
    K!.cocycle := vec;
    return K;
end;

#############################################################################
##
#F ComplementByH1Element( A, coh, elm )
##
ComplementByH1Element := function( A, coh, elm )
    local coc;
    coc := coh.FactorToCoc( coh, elm ) + coh.sol;
    return ComplementCR( A, coc );
end;

