#############################################################################
##
#W  autos.gi                 AutPGrp package                     Bettina Eick
##
#H  @(#)$Id: autos.gi,v 1.13 2009/08/31 07:40:15 gap Exp $
##
Revision.("autpgrp/gap/autos_gi") :=
    "@(#)$Id: autos.gi,v 1.13 2009/08/31 07:40:15 gap Exp $";

#############################################################################
##
#F LinearActionPGAut( <P>, <M>, <aut> )
##
LinearActionPGAut := function( P, M, aut )
    local p, gensP, pcgsM, gensG, defn, imgs, mat, d;

    # set up
    p := PrimePGroup( P );
    gensP := GeneratorsOfGroup( P );
    pcgsM := Pcgs( M );
    gensG := DifferenceLists( gensP, pcgsM );

    # compute matrix
    defn := P!.definitions;
    imgs := List( aut!.baseimgs, x -> MappedPcElement( x, aut!.pcgs, gensG ));
    for d in defn do
        if not IsNegRat( d ) then
            Add( imgs, SubstituteDef( d, imgs, p ) );
        fi;
    od;
    imgs := imgs{List( pcgsM, x -> Position( gensP, x ) )};

    # two cases - the first for efficiency
    if imgs = pcgsM then
        aut!.mat := 1;
    else
	#AH: make the matrix FF *before* conpacting
        mat := List( imgs, x -> ExponentsOfPcElement( pcgsM, x)*One(M!.field) );
        ConvertToMatrixRep( mat,Size(M!.field) );
        mat := Immutable( mat );
        aut!.mat :=  mat;
    fi;
end;

#############################################################################
##
#F LinearActionAutGrp( <A>, <P>, <M> )
##
InstallGlobalFunction( LinearActionAutGrp,
  function( A, P, M )
    local aut;

    # add information
    for aut in A.glAutos do
        LinearActionPGAut( P, M, aut );
    od;
    for aut in A.agAutos do
        LinearActionPGAut( P, M, aut );
    od;
    A.field := M!.field;
    A.prime := PrimePGroup( P );
    A.one!.mat := 1;
  end);

#############################################################################
##
#F CentralAutos( <G>, <N> )
##
CentralAutos := function( G, N )
    local base, pcgs, cent, b, i, imgs, aut;

    base := Pcgs(N);
    pcgs := Pcgs(G);
    cent := [];
    for b in base do
        for i in [1..RankPGroup(G)] do
            imgs := ShallowCopy( pcgs );
            imgs[i] := imgs[i] * b;
            aut := PGAutomorphism( G, pcgs, imgs );
            Add( cent, aut );
        od;
    od;
    return cent;
end;

#############################################################################
##
#F InduceAuto( <F>, <aut> )
##
InduceAuto := function( F, aut )
    local pcgsF, baseF, imgsG, imgsF, hom;
    pcgsF := Pcgs( F );
    baseF := pcgsF{[1..RankPGroup(F)]};
    imgsG := aut!.baseimgs;
    imgsF := List( imgsG, x -> MappedPcElement( x, aut!.pcgs, pcgsF ) );
    if CHECK then 
        hom := GroupHomomorphismByImages( F, F, baseF, imgsF );
        if not IsGroupHomomorphism( hom ) then 
            Error("no hom");
        elif not IsBijective( hom ) then
            Error("no bijection");
        fi;
    fi;
    return PGAutomorphism( F, baseF, imgsF );
end;

#############################################################################
##
#F InduceAutGroup( <A>, <Q>, <P>, <M>, <U> )
##
InstallGlobalFunction( InduceAutGroup,
  function( A, Q, P, M, U )
    local p, r, F, s, t, pcgsF, pcgsL, L, B, central;

    # set up
    p := PrimePGroup( P );
    r := RankPGroup( P );

    # create factor
    F := Range( EpimorphismQuotientSystem(Q) );
    SetIsPGroup( F, true );
    SetPrimePGroup( F, p );
    SetRankPGroup( F, r );
    pcgsF := Pcgs(F);

    # get definitions for F
    F!.definitions := RewriteDef( pcgsF, Q!.definitions, p );

    # get p-centre of F
    s := Length( Pcgs(P) ) - Length( Pcgs(M) );
    t := s + Length( Pcgs(M) ) - Length( Pcgs(U) );
    pcgsL := InducedPcgsByPcSequenceNC( pcgsF, pcgsF{[s+1..t]} );
    L := SubgroupByPcgs( F, pcgsL );

    # induce autos
    B := rec();
    B.glAutos := List( A.glAutos, x -> InduceAuto( F, x ) );
    B.agAutos := List( A.agAutos, x -> InduceAuto( F, x ) );
    central   := CentralAutos( F, L );
    Append( B.agAutos, central );

    # add information
    B.glOrder := A.glOrder;
    B.agOrder := Concatenation( A.agOrder, List( central, x -> p ) );
    B.group   := F;
    B.one     := IdentityPGAutomorphism( F );
    B.size    := B.glOrder * Product( B.agOrder );

    # if possible add projective operation
    if IsBound( A.glOper ) then B.glOper := A.glOper; fi;

    # and return
    return B;
  end);

#############################################################################
##
#F ConvertAuto( <aut>, <iso> )
##
ConvertAuto := function( aut, iso )
    local G, pcgs, imgs, auto;
    
    G := Source( iso );
    pcgs := SpecialPcgs( G );
    imgs := List( pcgs, x -> ImagesRepresentative( iso, x ) );
    imgs := List( imgs, x -> ImagesRepresentative( aut, x ) );
    imgs := List( imgs, x -> PreImagesRepresentative( iso, x ) );
   
    if not CHECK then
        auto := GroupHomomorphismByImagesNC(G, G, pcgs, imgs );
        SetIsBijective( auto, true );
    else
        auto := GroupHomomorphismByImages( G, G, AsList(pcgs), imgs );
        if not IsGroupHomomorphism( auto ) then
            Error("automorphism is no homomorphism");
        elif not IsBijective( auto ) then
            Error("automorphism is not bijective");
        fi;
    fi;

    return auto;
end;

#############################################################################
##
#F ConvertAutGroup ( <A>, <G> )
##
InstallGlobalFunction( ConvertAutGroup,
  function( A, G )
    local r, gens, imgs, iso, C;

    r := RankPGroup( G );
    gens := SpecialPcgs( G ){[1..r]};
    imgs := Pcgs( A.group ){[1..r]};
    if not CHECK then 
        iso := GroupHomomorphismByImagesNC( G, A.group, gens, imgs );
        SetIsBijective( iso, true );
    else
        iso := GroupHomomorphismByImages( G, A.group, gens, imgs );
        if not IsGroupHomomorphism( iso ) then
            Error("isomorphism is no homomorphism");
        elif not IsBijective( iso ) then
            Error("isomorphism is not bijective");
        fi;
    fi;

    C := rec();
    C.glAutos := List( A.glAutos, x -> ConvertAuto( x, iso ) );
    C.glOrder := A.glOrder;
    C.agAutos := List( A.agAutos, x -> ConvertAuto( x, iso ) );
    C.agOrder := A.agOrder;
    C.one := IdentityMapping( G );
    C.group := G;
    C.size := A.size;

    # if possible add projective operation
    if IsBound( A.glOper ) then C.glOper := A.glOper; fi;

    return C;
  end);

#############################################################################
##
#F AddInfoCover( Q, P, M, U )
##
InstallGlobalFunction( AddInfoCover, 
  function( Q, P, M, U )
    local r, p, f, fam, gensP, pcgsP, gensM, pcgsM, gensU, pcgsU, pos, def; 
  
    r := Q!.RanksOfDescendingSeries;
    p := Q!.prime;
    f := Q!.field;
    fam := FamilyPcgs( P );

    # info for P
    gensP := GeneratorsOfGroup( P );
    pcgsP := InducedPcgsByPcSequenceNC( fam, gensP );
    SetPcgs( P, pcgsP );
    SetRankPGroup( P, r[1] );
    SetPrimePGroup( P, p );

    # info for M
    gensM := GeneratorsOfGroup( M );
    pcgsM := InducedPcgsByPcSequenceNC( fam, gensM );
    SetPcgs( M, pcgsM );
    SetPrimePGroup( M, p );
    M!.field := f;

    # info for U
    gensU := GeneratorsOfGroup( U );
    pcgsU := InducedPcgsByGeneratorsNC( fam, gensU );
    SetPcgs( U, pcgsU );
    
    # get definitions of M
    pos := List( pcgsP, x -> Position( fam, x ) );
    def := Q!.definitions{pos};
    P!.definitions := RewriteDef( pcgsP, def, p );
  end);

#############################################################################
##
#F AutomorphismGroupPGroup( <G>, <flag> ) . . . .automorphisms in hybird form
##
InstallGlobalFunction( AutomorphismGroupPGroup, function( arg )
    local p, r, G, pcgs, first, n, str, A, F, Q, i, s, t, P, N, M, U, B,
          baseU, baseN, epi, interrupt, f;

    # catch the trivial case
    G := arg[1];
    if Size( G ) = 1 then return Group( [], IdentityMapping(G) ); fi;

    # catch arguments
    if Length( arg ) = 1 then
        interrupt := false;

        # choose a initialisation
        p := PrimePGroup( G );
        r := RankPGroup( G );
        if IsHomoCyclic( G ) then
            InitAutGroup := InitAutomorphismGroupFull;
        elif (p^r - 1)/(p - 1) < 30000 then
            InitAutGroup := InitAutomorphismGroupOver;
        else   
            InitAutGroup := InitAutomorphismGroupChar;
        fi;

        # choose flags
        CHOP_MULT := true;
        NICE_STAB := true; 
        USE_LABEL := false;

    elif Length( arg ) = 2 then
        interrupt := arg[2];
    fi;

    # compute special pcgs 
    pcgs := SpecialPcgs( G );
    first := LGFirst( SpecialPcgs(G) );
    p := PrimePGroup( G );
    n := Length(pcgs);
    r := RankPGroup( G );
    f := GF(p);
    
    # init automorphism group - compute Aut(G/G_1)
    Info( InfoAutGrp, 1, 
          "step 1: ",p,"^", first[2]-1, " -- init automorphisms ");

    if interrupt or IsBool( InitAutGroup ) then
        str := Interrupt("choose initialisation (Over/Char/Full)");
        if str = "Over" then
            InitAutGroup := InitAutomorphismGroupOver;
        elif str = "Char" then
            InitAutGroup := InitAutomorphismGroupChar;
        elif str = "Full" then
            InitAutGroup := InitAutomorphismGroupFull;
        else
            Print("not a valid inititialisation \n");
            return;
        fi;
    fi;
    A := InitAutGroup( G );

    # loop over remaining steps
    F := Range( IsomorphismFpGroupByPcgs( pcgs, "f" ) );
    Q := PQuotient( F, p, 1 );
    for i in [2..Length(first)-1] do

        # print info
        s := first[i];
        t := first[i+1];
        Info( InfoAutGrp, 1, 
              "step ",i,": ",p,"^", t-s, " -- aut grp has size ", A.size );

        # the cover
        Info( InfoAutGrp, 2, "  computing cover");
        P := PCover( Q );
        M := PMultiplicator( Q, P );
        N := Nucleus( Q, P );
        U := AllowableSubgroup( Q, P );
        AddInfoCover( Q, P, M, U );

        # induced action of A on M
        Info( InfoAutGrp, 2, "  computing matrix action");
        LinearActionAutGrp( A, P, M );

        # compute stabilizer
        Info( InfoAutGrp, 2, "  computing stabilizer of U");
        baseN := GeneratorsOfGroup(N);
        baseU := GeneratorsOfGroup(U);
        baseN := List(baseN, x -> ExponentsOfPcElement(Pcgs(M), x)) * One(f);
        baseU := List(baseU, x -> ExponentsOfPcElement(Pcgs(M), x)) * One(f);
        baseU := EcheloniseMat( baseU );
        PGOrbitStabilizer( A, baseU, baseN, interrupt );

        # next step of p-quotient
        IncorporateCentralRelations( Q );
        RenumberHighestWeightGenerators( Q );

        # induce to next factor
        Info( InfoAutGrp, 2, "  induce autos and add central autos");
        A := InduceAutGroup( A, Q, P, M, U );

    od;

    # now get a real automorphism group
    Info( InfoAutGrp, 1, "final step: convert");
    return ConvertAutGroup( A, G );
end );

#############################################################################
##
#M ConvertHybridAutGroup( <A> )
##
InstallGlobalFunction( ConvertHybridAutGroup, function( A )
    local B, pcgs;
    B := Group( Concatenation( A.glAutos, A.agAutos ), A.one );
    SetSize( B, A.glOrder * Product( A.agOrder ) );
    if Length( A.glAutos ) = 0 then 
        SetIsSolvableGroup( B, true ); 
        pcgs := PcgsByPcSequenceNC( FamilyObj( A.one ), A.agAutos );
        SetRelativeOrders( pcgs, A.agOrder );
        SetOneOfPcgs( pcgs, A.one );
        SetGeneralizedPcgs( B, pcgs );
    fi;
    SetIsGroupOfAutomorphisms( B, true );
    return B;
end );

#############################################################################
##
#M AutomorphismGroup
##
InstallMethod( AutomorphismGroup,
               "for finite p-groups",
               true,
               [IsPGroup and IsFinite and CanEasilyComputePcgs],
               0,
function( G )
    local A;

    # the trivial case is a problem
    if Size( G ) = 1 then return Group( [], IdentityMapping(G) ); fi;

    # compute
    A :=  AutomorphismGroupPGroup( G );

    # translate and return
    A:=ConvertHybridAutGroup( A );
    SetIsAutomorphismGroup(A,true);
    if IsFinite(G) then
      SetIsGroupOfAutomorphismsFiniteGroup(A,true);
    fi;
    return A;
end );

               
