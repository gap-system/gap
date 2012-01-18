#############################################################################
##
#W series.gi               POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## radical series, homogeneous series and composition series of matrix groups
##
#H  @(#)$Id: series.gi,v 1.14 2011/09/23 14:33:22 gap Exp $
##
#Y 2003
##

#############################################################################
##
#F POL_SplitSemisimple( base )
##
POL_SplitSemisimple := function( base )
    local  d, b, f, s, i;
    d := Length( base );
    b := PrimitiveAlgebraElement( [  ], base );
    f := Factors( b.poly );
    if Length( f ) = 1  then
        return [ rec(
                basis := IdentityMat( Length( b.elem ) ),
                poly := f ) ];
    fi;
    s := List( f,
               x -> NullspaceRatMat( Value( x, b.elem ) )
             );
    s := List( [ 1 .. Length( f ) ],
               x -> rec( basis := s[x], poly := f[x] )
             );
    return s;
end;


#############################################################################
##
#F RadicalOfAbelianRMGroup( mats, d )
##
## <mats> is an abelian rational matrix group
##
RadicalOfAbelianRMGroup := function( mats, d )
    local coms, i, j, new, base, full, nath, indm, l, algb, newv, tmpb, subb,
          f, g, h, mat;

    base := [];
    full := IdentityMat( d );
    # nath is the natural hom. from V to V/W
    nath := NaturalHomomorphismBySemiEchelonBases( full, base );
    # indm for induced matrices
    indm := mats;

    # start spinning up basis and look for nilpotent elements
    i := 1;
    algb := [];
    while i <= Length( indm ) do

        # add next element to algebra basis
        l := Length( algb );
        newv := Flat( indm[i] );
        tmpb := SpinnUpEchelonBase(algb, [newv], indm{[1..i]},OnMatVector );

        # check whether we have added a non-semi-simple element
        subb := [];
        for j in [l+1..Length(tmpb)] do
            mat := MatByVector( tmpb[j], Length(indm[i]) );
            f := MinimalPolynomial( Rationals, mat );
            g := Collected( Factors( f ) );
            if ForAny( g, x -> x[2] > 1 ) then
                h := Product( List( g, x -> Value( x[1], mat ) ) );
                Append( subb, List( h, x -> ShallowCopy(x) ) );
            fi;
        od;
        #Print("found nilpotent submodule of dimension ", Length(subb),"\n");

        # spin up new subspace of radical
        subb := SpinnUpEchelonBase( [], subb, indm, OnRight );
        if Length( subb ) > 0 then
            base := PreimageByNHSEB( subb, nath );
            if Length( base ) = d then
                # radical cannot be so big
                return fail;
            fi;
            nath := NaturalHomomorphismBySemiEchelonBases( full, base );
            indm := List( mats, x -> InducedActionFactorByNHSEB( x, nath ) );
            algb := [];
            i := 1;
        else
            i := i + 1;
        fi;
    od;
    return rec( radical := base, nathom := nath, algebra := algb );
end;


#############################################################################
##
#F POL_RadicalNormalGens( gens, mats, d )
##
##
## mats are normal subgroup generators for the Kernel K_p in G =<gens>
##
## returned is
## radical  .... a basis for the radical
## nathom  ..... homomorphism for Q^d to Q^d/radical
## algebra .... basis for the algebra Q[K_p^G] in flat form
##              where K_p and G are induced to Q^d/radical
##
POL_RadicalNormalGens := function( gens, mats, d )
    local coms, i, j, new, base, full, nath, indm, l, algb,
          newv, tmpb, subb, f, g, h, mat,k,a,left,inducedk,right,
          commutes,extended,comElement,a2,y;

    # get commutators
    # because Q^d ( k-1 ) \subset Rad, where k in the commutator
    # subgroup <mats>'
    coms := [];
    for i in [1..Length( mats )] do
        for j in [i+1..Length( mats )] do
            new := mats[i] * mats[j] - mats[j] * mats[i];
            Append(coms, new );
        od;
    od;

    # base is a basis for the module W, the radical
    base := SpinnUpEchelonBase( [], coms, gens, OnRight );
    if Length( base ) = d then
        # for a radical to big
        return fail;
    fi;
    full := IdentityMat( d );
    # nath is the natural hom. from V to V/W
    nath := NaturalHomomorphismBySemiEchelonBases( full, base );
    # indm for induced matrices
    indm := List( mats, x -> InducedActionFactorByNHSEB( x, nath ) );

    # start spinning up basis and look for nilpotent elements
    i := 1;
    algb := [];
    while i <= Length( indm ) do
         # check if the new element commutes with all elements in algb
        # if not we get a nontrivial element of the commutator
        commutes:=true;
        for a in algb do
            a2 := MatByVector( a, Length(indm[i]) );
            left := indm[i]*a2;
            right := a2*indm[i];
            if not left=right then
               commutes:=false;
               break;
            fi;
        od;
        # if it doesn't commute with all, spin up new subspace of
        # the radical
        extended := false;
        if not commutes then
            subb := left-right;
            subb := SpinnUpEchelonBase( [], subb, indm, OnRight );
            if Length( subb ) > 0 then
                base := PreimageByNHSEB( subb, nath );
                # Rad_K_p(Q^d) = Rad_G(Q^d)
                # therefore <base> must be also a G-module
                base := SpinnUpEchelonBase( [], base, gens, OnRight );
                if Length( base ) = d then
                    # radical cannot be so big
                    return fail;
                fi;
                nath := NaturalHomomorphismBySemiEchelonBases( full, base );
                indm := List( mats, x ->InducedActionFactorByNHSEB(x,nath ));
                algb := [];
                i := 1;
                extended:=true;
              fi;
        fi;
        if not extended then
            # add next element to algebra basis
            l := Length( algb );
            newv := Flat( indm[i] );
            tmpb := SpinnUpEchelonBase(algb, [newv], indm{[1..i]},
                                      OnMatVector );
            # close the basis under the conjugation action of G
            for k in gens do
                inducedk:=InducedActionFactorByNHSEB(k,nath);
                y:=indm[i]^inducedk;
                newv:=Flat(y);
                tmpb := SpinnUpEchelonBase( algb, [newv], indm{[1..i]},
                                          OnMatVector );
            od;
            # check whether we have added a non-semi-simple element
            subb := [];
            for j in [l+1..Length(tmpb)] do
                mat := MatByVector( tmpb[j], Length(indm[i]) );
                f := MinimalPolynomial( Rationals, mat );
                g := Collected( Factors( f ) );
                if ForAny( g, x -> x[2] > 1 ) then
                    h := Product( List( g, x -> Value( x[1], mat ) ) );
                    Append( subb, List( h, x -> ShallowCopy(x) ) );
                fi;
            od;
            # spin up new subspace of radical
            subb := SpinnUpEchelonBase( [], subb, indm, OnRight );
            if Length( subb ) > 0 then
                base := PreimageByNHSEB( subb, nath );
                # Rad_K_p(Q^d) = Rad_G(Q^d)
                # therefore <base> must be also a G-module
                base := SpinnUpEchelonBase( [], base, gens, OnRight );
                if Length( base ) = d then
                    # radical cannot be so big
                    return fail;
                fi;
                nath := NaturalHomomorphismBySemiEchelonBases( full, base );
                indm := List( mats,x->InducedActionFactorByNHSEB( x, nath ));
                algb := [];
                i := 1;
            else
                i := i + 1;
            fi;
        fi;
    od;
    return rec( radical := base, nathom := nath, algebra := algb );
end;

#############################################################################
##
#F POL_HomogeneousSeriesNormalGens(gens, mats, d )
##
## mats are normal subgroup generators for the Kernel K_p in G =<gens>
## returned is a homogeneous series of of K_p module Q^d
##
POL_HomogeneousSeriesNormalGens := function(gens, mats, d )
    local radb, splt, nath,inducedgens, l, sers, i, sub, full, acts, rads;

    # catch the trivial case and set up
    if d = 0 then
        return [];
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then
        return [full, []];
    fi;
    sers := [full];

    # get the radical
    radb := POL_RadicalNormalGens(gens, mats, d );
    if radb = fail then return fail; fi;
    splt := POL_SplitSemisimple( radb.algebra );
    nath := radb.nathom;

    # refine radical factor and initialize series
    l := Length( splt );
    for i in [2..l] do
        sub := Concatenation( List( [i..l], x -> splt[x].basis ) );
        TriangulizeMat( sub );
        Add( sers, PreimageByNHSEB( sub, nath ) );
    od;
    Add( sers, radb.radical );

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));
    inducedgens:=List( gens, x -> InducedActionSubspaceByNHSEB( x, nath ) );

    # use recursive call to refine radical
    rads := POL_HomogeneousSeriesNormalGens(inducedgens,acts,
                                            Length(radb.radical) );
    if rads = fail then return fail; fi;
    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F POL_RadicalSeriesNormalGens(gens, mats, d )
##
## mats are normal subgroup generators for the Kernel K_p in G=<gens>,
## which is a rational polycyclic matrix group.
## returned is a radical series of Q^d
##
POL_RadicalSeriesNormalGens := function(gens, mats, d )
    local radb, splt, nath,inducedgens, l, sers, i, sub, full, acts, rads;

    # catch the trivial case and set up
    if d = 0 then
        return [];
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then
        return [full, []];
    fi;
    sers := [full];

    # get the radical
    radb := POL_RadicalNormalGens(gens, mats, d );
    if radb = fail then return fail; fi;
    nath := radb.nathom;
    Add( sers, radb.radical );

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));
    inducedgens:=List( gens, x -> InducedActionSubspaceByNHSEB( x, nath ) );

    # use recursive call to refine radical
    rads := POL_RadicalSeriesNormalGens(inducedgens,acts,
                                            Length(radb.radical) );
    if rads = fail then return fail; fi;
    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F POL_RadicalSeriesNormalGensFullData(gens, mats, d )
##
## mats are normal subgroup generators for the Kernel K_p in G=<gens>,
## which is a rational polycyclic matrix group.
## returned is a radical series of Q^d
## and full data of the used homomorphisms and algebras
##
POL_RadicalSeriesNormalGensFullData := function(gens, mats, d )
    local radb, splt, nath,inducedgens, l, sers, i, sub, full, acts,
          sersFullData, rads, radsFullData, record;

    # catch the trivial case and set up
    if d = 0 then
        return rec( sers := [], sersFullData := [] );
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then
        sers := [full, []];
        sersFullData :=
             [ rec(radical := [], nathom := [], algebra := []) ];
        return rec( sers:= sers, sersFullData := sersFullData );
    fi;
    sers := [full];

    # get the radical
    radb := POL_RadicalNormalGens(gens, mats, d );
    if radb = fail then return fail; fi;
    nath := radb.nathom;
    Add( sers, radb.radical );
    sersFullData := [radb ];

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));
    inducedgens:=List( gens, x -> InducedActionSubspaceByNHSEB( x, nath ) );

    # use recursive call to refine radical
    record := POL_RadicalSeriesNormalGensFullData(inducedgens,acts,
                                            Length(radb.radical) );

    if record = fail then return fail; fi;
    rads := record.sers;
    radsFullData := record.sersFullData;


    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    Append( sersFullData , radsFullData );

    return rec( sers := sers, sersFullData := sersFullData );
end;

#############################################################################
##
#F RadicalSeriesAbelianRMGroup( mats, d )
##
## G is an abelian rational matrix group
##
RadicalSeriesAbelianRMGroup := function( mats, d )
    local radb, splt, nath, l, sers, i, sub, full, acts, rads;

    # catch the trivial case and set up
    if d = 0 then
        return [];
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then
        return [full, []];
    fi;
    sers := [full];

    # get the radical
    radb := RadicalOfAbelianRMGroup( mats, d );
    if radb = fail then return fail; fi;
    nath := radb.nathom;
    Add( sers, radb.radical );

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));

    # use recursive call to refine radical
    rads := RadicalSeriesAbelianRMGroup(acts, Length(radb.radical) );
    if rads = fail then return fail; fi;
    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F POL_HomogeneousSeriesAbelianRMGroup( mats, d )
##
## <mats> is an abelian rational matrix group
##
POL_HomogeneousSeriesAbelianRMGroup := function( mats, d )
    local radb, splt, nath,inducedgens, l, sers, i, sub, full, acts, rads;

    # catch the trivial case and set up
    if d = 0 then
        return [];
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then
        return [full, []];
    fi;
    sers := [full];

    # get the radical
    radb := RadicalOfAbelianRMGroup( mats, d );
    if radb = fail then return fail; fi;
    splt := POL_SplitSemisimple( radb.algebra );
    nath := radb.nathom;

    # refine radical factor and initialize series
    l := Length( splt );
    for i in [2..l] do
        sub := Concatenation( List( [i..l], x -> splt[x].basis ) );
        TriangulizeMat( sub );
        Add( sers, PreimageByNHSEB( sub, nath ) );
    od;
    Add( sers, radb.radical );

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));

    # use recursive call to refine radical
    rads := POL_HomogeneousSeriesAbelianRMGroup( acts, Length(radb.radical) );
    if rads = fail then return fail; fi;
    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F HomogeneousSeriesAbelianMatGroup( G )
##
## <G> is an abelian rational matrix group
##
# FIXME: This function is documented and should be turned into a GlobalFunction
HomogeneousSeriesAbelianMatGroup := function( G )
    local mats,d;
    if not IsRationalMatrixGroup( G ) or not IsAbelian( G ) then
        Print( "input must be an abelian rational matrix group.\n" );
    return fail;
    fi;
    mats := GeneratorsOfGroup( G );
    d := Length( mats[1] );
    return POL_HomogeneousSeriesAbelianRMGroup( mats, d );
end;

#############################################################################
##
#F RadicalSeriesPRMGroup( G )
##
## G is a rational polycyclic matrix group
##
RadicalSeriesPRMGroup := function( G )
    local   p,d,gens_p,bound_derivedLength,pcgs_I_p,gens_K_p,
            radicalSeries,gens_K_p_m, gens, gens_K_p_mutableCopy;

    gens := GeneratorsOfGroup( G );
    d := Length(gens[1][1]);

    # determine an admissible prime
    p := DetermineAdmissiblePrime(gens);
    Info( InfoPolenta, 1, "Chosen admissible prime: " , p );
    Info( InfoPolenta, 1, "  " );


    # calculate the gens of the group phi_p(<gens>) where phi_p is
    # natural homomorphism to GL(d,p)
    gens_p := InducedByField( gens, GF(p) );

    # determine an upper bound for the derived length of G
    bound_derivedLength := d+2;
    Info( InfoPolenta, 1,"Determine a constructive polycyclic sequence\n",
          "    for the image under the p-congruence homomorphism ..." );
    pcgs_I_p := CPCS_finite_word( gens_p, bound_derivedLength );
    if pcgs_I_p = fail then return fail; fi;
    Info(InfoPolenta,1,"finished.");
    Info( InfoPolenta, 1, "Finite image has relative orders ",
                           RelativeOrdersPcgs_finite( pcgs_I_p ), "." );
    Info( InfoPolenta, 1, " " );

    # compute the normal the subgroup gens. for the kernel of phi_p
    Info( InfoPolenta, 1,"Compute normal subgroup generators for the kernel\n",
          "    of the p-congruence homomorphism ...");
    gens_K_p := POL_NormalSubgroupGeneratorsOfK_p( pcgs_I_p, gens );
    gens_K_p := Filtered( gens_K_p, x -> not x = IdentityMat(d) );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 2,"The normal subgroup generators are" );
    Info( InfoPolenta, 2, gens_K_p );
    Info( InfoPolenta, 1, "  " );

    # radical series
    gens_K_p_mutableCopy := CopyMatrixList( gens_K_p );
    radicalSeries := POL_RadicalSeriesNormalGens( gens,
                                                  gens_K_p_mutableCopy,
                                                  d );
    if radicalSeries=fail then return fail; fi;

    return radicalSeries;
end;

#############################################################################
##
#F POL_HomogeneousSeriesPRMGroup( G )
##
## G is a rational polycyclic matrix group,
## returned is a homogeneous series of the natural K_p-module Q^d
##
POL_HomogeneousSeriesPRMGroup := function( G )
    local   p,d,gens_p,bound_derivedLength,pcgs_I_p,gens_K_p,
            homSeries,gens_K_p_m, gens, gens_K_p_mutableCopy;

    gens := GeneratorsOfGroup( G );
    d := Length(gens[1][1]);

    # determine an admissible prime
    p := DetermineAdmissiblePrime(gens);

    # calculate the gens of the group phi_p(<gens>) where phi_p is
    # natural homomorphism to GL(d,p)
    gens_p := InducedByField( gens, GF(p) );

    # determine an upper bound for the derived length of G
    bound_derivedLength := d+2;

    Info( InfoPolenta, 1,"determine a constructive polycyclic  sequence");
    Info( InfoPolenta, 1,"for the image under the p-congruence homomorph.");
    pcgs_I_p := CPCS_finite_word( gens_p, bound_derivedLength );
    Info( InfoPolenta, 1, "finite image has relative orders ",
                           RelativeOrdersPcgs_finite( pcgs_I_p ) );

    gens_K_p := POL_NormalSubgroupGeneratorsOfK_p( pcgs_I_p, gens );
    # Print( "gens_K_p is equal to", gens_K_p, "\n" );

    # step 4
    Info( InfoPolenta, 1, "compute the radical series \n");
    gens_K_p_mutableCopy := CopyMatrixList( gens_K_p );
    homSeries := POL_HomogeneousSeriesNormalGens( gens,
                                                  gens_K_p_mutableCopy,
                                                   d );
    return homSeries;
end;

#############################################################################
##
#F POL_InducedActionToSeries (gens_K_p, radicalSeries)
##
## returns the action of the matrices in gens_K_p induced to the
## factors of radicalSeries
##
POL_InducedActionToSeries := function(gens_K_p,radicalSeries)
    local action,blockGens,sizeOfBlock,d,homs,l,i,g,
          actionParts,hom,image_of_g,c,a,j;

    d:=Length(gens_K_p[1][1]);
    homs:=[];
    blockGens:=[];
    l:=Length(radicalSeries)-1;
    for i in [1..l] do
        radicalSeries[i] := SemiEchelonMat(  radicalSeries[i] ).vectors;
        #TriangulizeMat( radicalSeries[i] );
        # we cannot use TriangulizeMat, because
        # TriangulizeMat( radicalSeries[i] ) can change
        # radicalSeries[i+1]! Then radicalSeries[i+1] can fail to be
        # a module.
    od;
    for i in [1..l] do
       homs[i]:=NaturalHomomorphismBySemiEchelonBases( radicalSeries[i],
                                                       radicalSeries[i+1]);
    od;
    for hom in homs do
        actionParts:=[];
        for g in gens_K_p do
            action:=InducedActionFactorByNHSEB( g, hom );
            Add(actionParts,action);
        od;
        Add(blockGens,actionParts);
    od;
    return blockGens;
end;

#############################################################################
##
#M RadicalSeriesSolvableMatGroup( G )
##
## G is a matrix group over the Rationals
##
InstallMethod( RadicalSeriesSolvableMatGroup, "for solvable matrix groups (Polenta)",
               true, [ IsCyclotomicMatrixGroup ], 0,
function( G )
    local mats, d;
    if not IsRationalMatrixGroup( G ) then
        Print( "matrix groups must defined over the rationals" );
        return fail;
    fi;
    if IsAbelian( G ) then
        mats := GeneratorsOfGroup( G );
        d := Length( mats[1] );
        return RadicalSeriesAbelianRMGroup( mats, d );
    else
        return RadicalSeriesPRMGroup( G );
    fi;
end );

#############################################################################
##
#F POL_SplitHomogeneous( base, mats )
##
## split the homogeneous module <base> into irreducibles
##
POL_SplitHomogeneous := function( base, mats )
    local IrreducibleList,b,space_basis, space, basis;
    IrreducibleList :=[];
    # spinn up new irreducible module
    basis := SpinnUpEchelonBase( [], [base[1]], mats, OnRight );
    Add( IrreducibleList, basis );
    # check if basis is already big enough
    if Length( basis ) = Length( base ) then
        # <base> = <basis> but base has nicer form
        return [base];
    fi;

    for b in base do
        # check if b is not already contained in one of the irreducible
        # modules in IrreducibleList
        space_basis := Concatenation( IrreducibleList );
        space := VectorSpace( Rationals, space_basis, "basis" );
        if  not b in space then
           # spin up new irreducible module
           basis := SpinnUpEchelonBase( [], [b], mats, OnRight );
           Add( IrreducibleList, basis );
        fi;
    od;
    return IrreducibleList;
end;


#############################################################################
##
#F POL_IsRationalModule( base, mats )
##
POL_IsRationalModule := function( base, mats )
    local V, b, m;
    if Length( base ) = 0 then
        return true;
    fi;
    V := VectorSpace( Rationals, base );
    for b in base do
        for m in mats do
            if not b*m in V then
                return false;
            fi;
        od;
    od;
    return true;
end;


#############################################################################
##
#F POL_CompositionSeriesNormalGens(gens, mats, d )
##
## mats are normal subgroup generators for the Kernel K_p in G =<gens>
## returned is composition series of the K_p-module Q^d
##
POL_CompositionSeriesNormalGens := function(gens, mats, d )
    local radb, splt, nath,inducedgens, l, sers, i,j, sub, full, acts,
          preImageSub, irreducibleList, k, rads, induced,
          irreducibles, factorMats, isomIrreds, basis, sub2;

    # catch the trivial case and set up
    if d = 0 then
        return [];
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then
        return [full, []];
    fi;
    sers := [full];

    # get the radical
    radb := POL_RadicalNormalGens(gens, mats, d );
    if radb = fail then return fail; fi;
    splt := POL_SplitSemisimple( radb.algebra );
    nath := radb.nathom;

    # refine radical factor to irreducible components
     l := Length( splt );
     irreducibles := [];
     # induce action to factor
     factorMats := List( mats, x -> InducedActionFactorByNHSEB( x, nath ));
     for i in [1..l] do
         # split i^th homogeneous component into isomorphic comp.
         basis := POL_CopyVectorList( splt[i].basis );
         Assert( 2, POL_IsRationalModule( basis, factorMats ),
                    "hom. component fails to be a module" );
         isomIrreds := POL_SplitHomogeneous( basis, factorMats );
         for j in [1..Length( isomIrreds )] do
             Assert( 2, POL_IsRationalModule( isomIrreds[j], factorMats ),
                    "irred. component fails to be a module" );
         od;
         irreducibles := Concatenation( irreducibles, isomIrreds );
     od;

    # initialize series
    k := Length( irreducibles );
    for i in [2..k] do
        sub := Concatenation( List( [i..k], x -> irreducibles[x] ) );
        sub2 := POL_CopyVectorList( sub );
        TriangulizeMat( sub2 );
        Assert( 2, POL_IsRationalModule( sub2, factorMats ),
                    "sum of irred. components fails to be a module\n" );
        preImageSub := PreimageByNHSEB( sub2, nath );
        Assert( 2, POL_IsRationalModule( preImageSub, mats ),
                    "sum of irred. components fails to be a module\n" );
        Add( sers, preImageSub );
    od;
    Add( sers, radb.radical );

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));
    inducedgens:=List( gens, x -> InducedActionSubspaceByNHSEB( x, nath ) );

    # use recursive call to refine radical
    rads := POL_CompositionSeriesNormalGens(inducedgens,acts,
                                            Length(radb.radical) );
    if rads = fail then return fail; fi;
    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F POL_CompositionSeriesByRadicalSeries( mats , d, sersFullData, pos )
##
## mats are generators of a triangularizable matrix group
## sersFullData contains the full data, which were obtained in the
## computation of the radical series
## returned is composition series of the <mats>-module Q^d
##
POL_CompositionSeriesByRadicalSeries := function( mats, d, sersFullData, pos)
    local radb, splt, nath,inducedgens, l, sers, i,j, sub, full, acts,
          preImageSub, irreducibleList, k, rads, induced,
          irreducibles, factorMats, isomIrreds, basis, sub2, indm,
          indm_flat, algebra;

    # catch the trivial case and set up
    if d = 0 then
        return [];
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then
        return [full, []];
    fi;
    sers := [full];

    # get the radical
    radb := sersFullData[pos];
    if radb = fail then return fail; fi;
    nath := radb.nathom;
    splt := POL_SplitSemisimple( radb.algebra );

    # refine radical factor to irreducible components
     l := Length( splt );
     irreducibles := [];
     # induce action to factor
     factorMats := List( mats, x -> InducedActionFactorByNHSEB( x, nath ));
     for i in [1..l] do
         # split i^th homogeneous component into isomorphic comp.
         basis := POL_CopyVectorList( splt[i].basis );
         Assert( 2, POL_IsRationalModule( basis, factorMats ),
                    "hom. component fails to be a module" );
         isomIrreds := POL_SplitHomogeneous( basis, factorMats );
         for j in [1..Length( isomIrreds )] do
             Assert( 2, POL_IsRationalModule( isomIrreds[j], factorMats ),
                    "irred. component fails to be a module" );
         od;
         irreducibles := Concatenation( irreducibles, isomIrreds );
     od;

    # initialize series
    k := Length( irreducibles );
    for i in [2..k] do
        sub := Concatenation( List( [i..k], x -> irreducibles[x] ) );
        sub2 := POL_CopyVectorList( sub );
        TriangulizeMat( sub2 );
        Assert( 2, POL_IsRationalModule( sub2, factorMats ),
                    "sum of irred. components fails to be a module\n" );
        preImageSub := PreimageByNHSEB( sub2, nath );
        Assert( 2, POL_IsRationalModule( preImageSub, mats ),
                    "sum of irred. components fails to be a module\n" );
        Add( sers, preImageSub );
    od;
    Add( sers, radb.radical );

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));

    # use recursive call to refine radical
    rads := POL_CompositionSeriesByRadicalSeries(acts,
                                                 Length(radb.radical),
                                                 sersFullData,
                                                 pos +1 );
    if rads = fail then return fail; fi;
    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F POL_CompositionSeriesByRadicalSeriesRecalAlg( mats , d, sersFullData, pos )
##
## mats are generators of a triangularizable matrix group
## sersFullData contains the full data, which were obtained in the
## computation of the radical series
## returned is composition series of the <mats>-module Q^d
##
## the algebras which are used for the splitting are recalculated in this
## version. This is for example necessary if the algebra basis in
## sersFullData are computed with a different group (for example K_p(<mats>))
## than <mats>.
##
POL_CompositionSeriesByRadicalSeriesRecalAlg
                               := function( mats, d, sersFullData, pos)
    local radb, splt, nath,inducedgens, l, sers, i,j, sub, full, acts,
          preImageSub, irreducibleList, k, rads, induced,
          irreducibles, factorMats, isomIrreds, basis, sub2, indm,
          indm_flat, algebra;

    # catch the trivial case and set up
    if d = 0 then
        return [];
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then
        return [full, []];
    fi;
    sers := [full];

    # get the radical
    radb := sersFullData[pos];
    if radb = fail then return fail; fi;
    nath := radb.nathom;

    #compute a base for the algebra Q[ indmats ] where
    #indmats is the induced action  of Q^d/radical
    #and bring it in flat format
    indm := List( mats, x ->InducedActionFactorByNHSEB(x,nath ));
    indm_flat := List( indm, x-> Flat( x ));
    algebra := SpinnUpEchelonBase( [  ], indm_flat, indm, OnMatVector );


    #splt := POL_SplitSemisimple( radb.algebra );
    splt := POL_SplitSemisimple( algebra );

    # refine radical factor to irreducible components
     l := Length( splt );
     irreducibles := [];
     # induce action to factor
     factorMats := List( mats, x -> InducedActionFactorByNHSEB( x, nath ));
     for i in [1..l] do
         # split i^th homogeneous component into isomorphic comp.
         basis := POL_CopyVectorList( splt[i].basis );
         Assert( 2, POL_IsRationalModule( basis, factorMats ),
                    "hom. component fails to be a module" );
         isomIrreds := POL_SplitHomogeneous( basis, factorMats );
         for j in [1..Length( isomIrreds )] do
             Assert( 2, POL_IsRationalModule( isomIrreds[j], factorMats ),
                    "irred. component fails to be a module" );
         od;
         irreducibles := Concatenation( irreducibles, isomIrreds );
     od;

    # initialize series
    k := Length( irreducibles );
    for i in [2..k] do
        sub := Concatenation( List( [i..k], x -> irreducibles[x] ) );
        sub2 := POL_CopyVectorList( sub );
        TriangulizeMat( sub2 );
        Assert( 2, POL_IsRationalModule( sub2, factorMats ),
                    "sum of irred. components fails to be a module\n" );
        preImageSub := PreimageByNHSEB( sub2, nath );
        Assert( 2, POL_IsRationalModule( preImageSub, mats ),
                    "sum of irred. components fails to be a module\n" );
        Add( sers, preImageSub );
    od;
    Add( sers, radb.radical );

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));

    # use recursive call to refine radical
    rads := POL_CompositionSeriesByRadicalSeriesRecalAlg(acts,
                                                 Length(radb.radical),
                                                 sersFullData,
                                                 pos +1 );
    if rads = fail then return fail; fi;
    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;


#############################################################################
##
#F POL_CompositionSeriesAbelianRMGroup( mats, d )
##
## <mats> is an abelian rational matrix group
## returned is a composition series for the natrual <mats>-module Q^d
##
POL_CompositionSeriesAbelianRMGroup := function( mats, d )
    local radb, splt, nath,inducedgens, l, sers, i, sub, full, acts,
          rads, preImageSub, irreducibleList, k,
          irreducibles, factorMats, isomIrreds, basis, sub2;

    # catch the trivial case and set up
    if d = 0 then
        return [];
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then
        return [full, []];
    fi;
    sers := [full];

    # get the radical
    radb := RadicalOfAbelianRMGroup( mats, d );
    if radb = fail then return fail; fi;
    splt := POL_SplitSemisimple( radb.algebra );
    nath := radb.nathom;

    # refine radical factor to irreducible components
     l := Length( splt );
     irreducibles := [];
     # induce action to factor
     factorMats := List( mats, x -> InducedActionFactorByNHSEB( x, nath ));
     for i in [1..l] do
         # split i^th homogeneous component into isomorphic comp.
         basis := POL_CopyVectorList( splt[i].basis );
         isomIrreds := POL_SplitHomogeneous( basis, factorMats );
         irreducibles := Concatenation( irreducibles, isomIrreds );
     od;

    # initialize series
    k := Length( irreducibles );
    for i in [2..k] do
        sub := Concatenation( List( [i..k], x -> irreducibles[x] ) );
        sub2 := POL_CopyVectorList( sub );
        TriangulizeMat( sub2 );
        Assert( 2, POL_IsRationalModule( sub2, factorMats ),
                    "sum of irred. components fails to be a module\n" );
        preImageSub := PreimageByNHSEB( sub2, nath );
        Add( sers, preImageSub );
    od;
    Add( sers, radb.radical );

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));

    # use recursive call to refine radical
    rads := POL_CompositionSeriesAbelianRMGroup( acts, Length(radb.radical) );
    if rads = fail then return fail; fi;
    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F CompositionSeriesAbelianMatGroup( G )
##
## <G> is an abelian rational matrix group
##
# FIXME: This function is documented and should be turned into a GlobalFunction
CompositionSeriesAbelianMatGroup := function( G )
    local mats,d;
    if not IsRationalMatrixGroup( G ) or not IsAbelian( G ) then
        Print( "input must be an abelian rational matrix group.\n" );
        return fail;
    fi;
    mats := GeneratorsOfGroup( G );
    d := Length( mats[1] );
    return POL_CompositionSeriesAbelianRMGroup( mats, d );
end;


#############################################################################
##
#F POL_CompositionSeriesTriangularizablRMGroup( gens, d )
##
## <mats> is a triang. rational matrix group
## returned is a composition series for the natural <gens>-module Q^d
##
POL_CompositionSeriesTriangularizableRMGroup := function( gens, d )
  local     p, gens_p,G, bound_derivedLength, pcgs_I_p, gens_K_p,
            gens_K_p_m, gens_K_p_mutableCopy, pcgs,
            gensOfBlockAction,
            radSeries, comSeries, recordSeries, isTriang,gens_mutableCopy;

    # determine an admissible prime
    p := DetermineAdmissiblePrime(gens);
    Info( InfoPolenta, 1, "Chosen admissible prime: " , p );
    Info( InfoPolenta, 1, "  " );

    # calculate the gens of the group phi_p(<gens>) where phi_p is
    # natural homomorphism to GL(d,p)
    gens_p := InducedByField( gens, GF(p) );

    # determine an upper bound for the derived length of G
    bound_derivedLength := d+2;

    # finite part
    Info( InfoPolenta, 1,"Determine a constructive polycyclic sequence\n",
          "    for the image under the p-congruence homomorphism ..." );
    pcgs_I_p := CPCS_finite_word( gens_p, bound_derivedLength );
    if pcgs_I_p = fail then return fail; fi;
    Info(InfoPolenta,1,"finished.");
    Info( InfoPolenta, 1, "Finite image has relative orders ",
                           RelativeOrdersPcgs_finite( pcgs_I_p ), "." );
    Info( InfoPolenta, 1, " " );

    # compute the normal the subgroup gens. for the kernel of phi_p
    Info( InfoPolenta, 1,"Compute normal subgroup generators for the kernel\n",
         "    of the p-congruence homomorphism ...");
    gens_K_p := POL_NormalSubgroupGeneratorsOfK_p( pcgs_I_p, gens );
    gens_K_p := Filtered( gens_K_p, x -> not x = IdentityMat(d) );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 2,"The normal subgroup generators are" );
    Info( InfoPolenta, 2, gens_K_p );
    Info( InfoPolenta, 1, "  " );

    # radical series
    Info( InfoPolenta, 1, "Compute the radical series ...");
    gens_K_p_mutableCopy := CopyMatrixList( gens_K_p );
    recordSeries := POL_RadicalSeriesNormalGensFullData( gens,
                                                      gens_K_p_mutableCopy,
                                                      d );
    if recordSeries=fail then return fail; fi;
    radSeries := recordSeries.sers;
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, "The radical series has length ",
                          Length( radSeries ), "." );
    Info( InfoPolenta, 2, "The radical series is" );
    Info( InfoPolenta, 2, radSeries );
    Info( InfoPolenta, 1, " " );

    # test if G is unipotent by abelian
    isTriang := POL_TestIsUnipotenByAbelianGroupByRadSeries( gens, radSeries );
    if isTriang then
        Info( InfoPolenta, 1, "Group is triangularizable!" );
        gens_mutableCopy := CopyMatrixList( gens );

        # compositions series
        comSeries := POL_CompositionSeriesByRadicalSeriesRecalAlg(
                                                      gens_mutableCopy,
                                                       d,
                                                   recordSeries.sersFullData,
                                                       1  );
        if comSeries=fail then return fail; fi;
        return comSeries;
    else
        Print( "The input group is not triangularizable.\n" );
        return fail;
    fi;
end;

#############################################################################
##
#F CompositionSeriesTriangularizableMatGroup( G )
##
## <G> is a triangularizable  rational matrix group
##
# FIXME: This function is documented and should be turned into a GlobalFunction
CompositionSeriesTriangularizableMatGroup := function( G )
    local mats,d;
    if not IsRationalMatrixGroup( G ) then
        Print( "input must be a rational matrix group.\n" );
        return fail;
    fi;
    mats := GeneratorsOfGroup( G );
    d := Length( mats[1] );
    if IsAbelian( G ) then
       return POL_CompositionSeriesAbelianRMGroup( mats, d );
    else
       return POL_CompositionSeriesTriangularizableRMGroup( mats, d );
    fi;

end;

#############################################################################
##
#F POL_HomogeneousSeriesByRadicalSeriesRecalAlg( mats , d, sersFullData, pos )
##
## mats are generators of a triangularizable matrix group
## sersFullData contains the full data, which were obtained in the
## computation of the radical series
## returned is homog. series of the <mats>-module Q^d
##
## the algebras which are used for the splitting are recalculated in this
## version. This is for example necessary if the algebra basis in
## sersFullData are computed with a different group (for example K_p(<mats>))
## than <mats>.
##
POL_HomogeneousSeriesByRadicalSeriesRecalAlg
                               := function( mats, d, sersFullData, pos)
    local radb, splt, nath,inducedgens, l, sers, i,j, sub, full, acts,
          preImageSub, irreducibleList, k, rads, induced,
          irreducibles, factorMats, isomIrreds, basis, sub2, indm,
          indm_flat, algebra;

    # catch the trivial case and set up
    if d = 0 then
        return [];
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then
        return [full, []];
    fi;
    sers := [full];

    # get the radical
    radb := sersFullData[pos];
    if radb = fail then return fail; fi;
    nath := radb.nathom;

    #compute a base for the algebra Q[ indmats ] where
    #indmats is the induced action  of Q^d/radical
    #and bring it in flat format
    indm := List( mats, x ->InducedActionFactorByNHSEB(x,nath ));
    indm_flat := List( indm, x-> Flat( x ));
    algebra := SpinnUpEchelonBase( [  ], indm_flat, indm, OnMatVector );

    #splt := POL_SplitSemisimple( radb.algebra );
    splt := POL_SplitSemisimple( algebra );

    # refine radical factor and initialize series
    l := Length( splt );
    for i in [2..l] do
        sub := Concatenation( List( [i..l], x -> splt[x].basis ) );
        TriangulizeMat( sub );
        Add( sers, PreimageByNHSEB( sub, nath ) );
    od;
    Add( sers, radb.radical );

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));

    # use recursive call to refine radical
    rads := POL_HomogeneousSeriesByRadicalSeriesRecalAlg(acts,
                                                 Length(radb.radical),
                                                 sersFullData,
                                                 pos +1 );
    if rads = fail then return fail; fi;
    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F POL_HomogeneousSeriesTriangularizablRMGroup( gens, d )
##
## <mats> is a triang. rational matrix group
## returned is a homogeneous series for the natural <gens>-module Q^d
##
POL_HomogeneousSeriesTriangularizableRMGroup := function( gens, d )
  local     p, gens_p,G, bound_derivedLength, pcgs_I_p, gens_K_p,
            gens_K_p_m, gens_K_p_mutableCopy, pcgs,
            gensOfBlockAction,
            radSeries, comSeries, recordSeries, isTriang,gens_mutableCopy;

    # determine an admissible prime
    p := DetermineAdmissiblePrime(gens);
    Info( InfoPolenta, 1, "Chosen admissible prime: " , p );
    Info( InfoPolenta, 1, "  " );

    # calculate the gens of the group phi_p(<gens>) where phi_p is
    # natural homomorphism to GL(d,p)
    gens_p := InducedByField( gens, GF(p) );

    # determine an upper bound for the derived length of G
    bound_derivedLength := d+2;

    # finite part
    Info( InfoPolenta, 1,"Determine a constructive polycyclic sequence\n",
          "    for the image under the p-congruence homomorphism ..." );
    pcgs_I_p := CPCS_finite_word( gens_p, bound_derivedLength );
    if pcgs_I_p = fail then return fail; fi;
    Info(InfoPolenta,1,"finished.");
    Info( InfoPolenta, 1, "Finite image has relative orders ",
                           RelativeOrdersPcgs_finite( pcgs_I_p ), "." );
    Info( InfoPolenta, 1, " " );

    # compute the normal the subgroup gens. for the kernel of phi_p
    Info( InfoPolenta, 1,"Compute normal subgroup generators for the kernel\n",
          "    of the p-congruence homomorphism ...");
    gens_K_p := POL_NormalSubgroupGeneratorsOfK_p( pcgs_I_p, gens );
    gens_K_p := Filtered( gens_K_p, x -> not x = IdentityMat(d) );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 2,"The normal subgroup generators are" );
    Info( InfoPolenta, 2, gens_K_p );
    Info( InfoPolenta, 1, "  " );

    # radical series
    Info( InfoPolenta, 1, "Compute the radical series ...");
    gens_K_p_mutableCopy := CopyMatrixList( gens_K_p );
    recordSeries := POL_RadicalSeriesNormalGensFullData( gens,
                                                      gens_K_p_mutableCopy,
                                                      d );

    if recordSeries=fail then return fail; fi;
    radSeries := recordSeries.sers;
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, "The radical series has length ",
                          Length( radSeries ), "." );
    Info( InfoPolenta, 2, "The radical series is" );
    Info( InfoPolenta, 2, radSeries );
    Info( InfoPolenta, 1, " " );

    # test if G is unipotent by abelian
    isTriang := POL_TestIsUnipotenByAbelianGroupByRadSeries( gens, radSeries );
    if isTriang then
        Info( InfoPolenta, 1, "Group is triangularizable!" );
        gens_mutableCopy := CopyMatrixList( gens );

        # homogeneous series
        comSeries := POL_HomogeneousSeriesByRadicalSeriesRecalAlg(
                                                      gens_mutableCopy,
                                                       d,
                                                   recordSeries.sersFullData,
                                                       1  );
        if comSeries=fail then return fail; fi;
        return comSeries;
    else
        Print( "The input group is not triangularizable.\n" );
        return fail;
    fi;
end;

#############################################################################
##
#F HomogeneousSeriesTriangularizableMatGroup( G )
##
## <G> is a triangularizable  rational matrix group
##
# FIXME: This function is documented and should be turned into a GlobalFunction
HomogeneousSeriesTriangularizableMatGroup := function( G )
    local mats,d;
    if not IsRationalMatrixGroup( G ) then
        Print( "input must be a rational matrix group.\n" );
        return fail;
    fi;
    mats := GeneratorsOfGroup( G );
    d := Length( mats[1] );
    if IsAbelian( G ) then
       return POL_HomogeneousSeriesAbelianRMGroup( mats, d );
    else
       return POL_HomogeneousSeriesTriangularizableRMGroup( mats, d );
    fi;

end;

#############################################################################
##
#E
