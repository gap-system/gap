#############################################################################
##
#W present.gi              POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## pcp-presentations for matrix groups
##
#H  @(#)$Id: present.gi,v 1.12 2011/09/23 14:40:24 gap Exp $
##
#Y 2003
##

#############################################################################
##
#F POL_Exp2genList(exp);
##
POL_Exp2GenList:= function(exp)
    local n, genList,i;
    n:=Length(exp);
    genList:=[];
    for i in [1..n] do
        if exp[i] <> 0 then
            Append(genList,[i,exp[i]]);
        fi;
    od;
    return genList;
end;

#############################################################################
##
#F POL_SetPcPresentation_infinite(pcgs)
##
## pcgs is a constructive pc-Sequence,calculated by CPCS_PRMGroup
## this function calculates a PcPresentation for the group described
## by pcgs
##
POL_SetPcPresentation_infinite:= function(pcgs)
    local genList,ftl,n,ro,i,j,exp,conj,f_i,f_j,r_i,pcsInv;
    # Setup
    n:=Length(pcgs.pcs);
    ftl:=FromTheLeftCollector(n);
    #pcSeq:=StructuralCopy((pcgs.gens));
    pcsInv:=[];
    for i in [1..n] do
        pcsInv[i]:=pcgs.pcs[i]^-1;
    od;
    # the relative orders
    ro:= ( pcgs.rels );
    for i in [1..n] do
        if ro[i]<>0 then
            SetRelativeOrder(ftl,i,ro[i]);
        fi;
    od;

    Info( InfoPolenta, 1, "Compute power relations ..." );
    # Set power relations
    for i in [1..n] do
        if ro[i]<>0 then
            f_i:=pcgs.pcs[i];
            r_i:=ro[i];
            exp:=ExponentVector_CPCS_PRMGroup(  f_i^r_i,pcgs );
            if InfoLevel( InfoPolenta ) >= 2 then Print( "." ); fi;
            genList := POL_Exp2GenList(exp);
            SetPower(ftl,i,genList);
        fi;
    od;
    if InfoLevel( InfoPolenta ) >= 2 then Print( "\n" ); fi;
    Info( InfoPolenta, 1, "... finished." );

    Info( InfoPolenta, 1, "Compute conjugation relations ..." );
    # Set the conjugation relations
    for i in [1..n] do
        for j in [1..(i-1)] do
            # conjugation with g_j
            f_i:=pcgs.pcs[i];
            f_j:=pcgs.pcs[j];
            conj:=(pcsInv[j])*f_i*f_j;
            Assert(0, conj=f_i^f_j );
            exp:=ExponentVector_CPCS_PRMGroup( conj,pcgs);
            Assert(0, conj=Product(List([1..n],i->pcgs.pcs[i]^exp[i])) );
            if InfoLevel( InfoPolenta ) >= 2 then Print( "." ); fi;
            genList:=POL_Exp2GenList(exp);
            SetConjugate(ftl,i,j,genList);
            # conjugation with g_j^-1 if g_j has infinite order
            if ro[i] = 0 then
                conj:= f_j* f_i *(pcsInv[j]);
                Assert(0, conj=f_i^(f_j^-1) );
                exp:=ExponentVector_CPCS_PRMGroup( conj,pcgs);
                Assert(0, conj=Product(List([1..n],i->pcgs.pcs[i]^exp[i])) );
                if InfoLevel( InfoPolenta ) >= 2 then Print( "." ); fi;
                genList:=POL_Exp2GenList(exp);
                SetConjugate(ftl,i,-j,genList);
            fi;
        od;
    od;
    if InfoLevel( InfoPolenta ) >= 2 then Print( "\n" ); fi;
    Info( InfoPolenta, 1, "... finished." );

    Info( InfoPolenta, 1, "Update polycyclic collector ... " );
    UpdatePolycyclicCollector(ftl);
    Info( InfoPolenta, 1, "... finished." );

    return ftl;
end;
# remark: some of the information (i.e. parts of the exponents vectors)
# which we need in the last algorithm,
# arise naturally in the computation of the normal subgroup
# generators. It could be transferred from there.


#############################################################################
##
#F POL_PcpGroupByMatGroup_infinite( arg )
##
## arg[1]=G is a subgroup of GL(d, Q ). The algorithm returns a PcpGroup if G
## is polycyclic.
##
POL_PcpGroupByMatGroup_infinite := function( arg )
    local CPCS, pcp, K,G,p;
    G := arg[1];
    if Length(arg)=2 then
        p := arg[2];
        CPCS := CPCS_PRMGroup( G, p );
    else
        CPCS := CPCS_PRMGroup( G );
    fi;
    if CPCS = fail then return fail; fi;
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Compute the relations of the polycyclic\n",
          "    presentation of the group ..." );
    pcp := POL_SetPcPresentation_infinite( CPCS );
    Info( InfoPolenta, 1,"finished." );
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Construct the polycyclic presented group ..." );
    if AssertionLevel() = 0 then
        K := PcpGroupByCollectorNC( pcp );
    else
        K := PcpGroupByCollector( pcp );
    fi;
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, " " );

    return K;
end;

#############################################################################
##
#F POL_SetPcPresentation_finite(pcgs)
##
## pcgs is a constructive pc-sequence of a finite group, calculated
## by CPCS_finite.
## this function calculates a PcPresentation for the group described
## by pcgs
##
POL_SetPcPresentation_finite:= function(pcgs)
    local genList,ftl,n,ro,i,j,exp,conj,f_i,f_j,r_i,pcsInv, pcs;
    # setup
    n := Length(pcgs.gens);
    ftl := FromTheLeftCollector(n);

    # Attention: In pcgs.gens we have the pc-sequence in inverse order
    # because we built up the structure bottom up
    pcs := StructuralCopy(Reversed(pcgs.gens));
    pcsInv:=[];
    for i in [1..n] do
        pcsInv[i]:=pcs[i]^-1;
    od;

    # calculate the relative orders
    ro := RelativeOrdersPcgs_finite( pcgs );

    # set relative orders
    for i in [1..n] do
        SetRelativeOrder(ftl,i,ro[i]);
    od;
    # Set power relations
    for i in [1..n] do
        if ro[i]<>0 then
            f_i:=pcs[i];
            r_i:=ro[i];
            exp:= ExponentvectorPcgs_finite( pcgs,  f_i^r_i );
            genList := POL_Exp2GenList(exp);
            SetPower(ftl,i,genList);
        fi;
    od;
    # Set the conjugation relations
    for i in [1..n] do
        for j in [1..(i-1)] do
            f_i:=pcs[i];
            f_j:=pcs[j];
            conj:=(pcsInv[j])*f_i*f_j;
            exp:=ExponentvectorPcgs_finite( pcgs, conj );
            genList:=POL_Exp2GenList(exp);
            SetConjugate(ftl,i,j,genList);
        od;
    od;
    UpdatePolycyclicCollector(ftl);
    return ftl;
end;

#############################################################################
##
#F POL_PcpGroupByMatGroup_finite( G )
##
## G is a subgroup of GL(d, Q ). The algorithm returns a PcpGroup if G
## is polycyclic.
##
POL_PcpGroupByMatGroup_finite := function( G )
    local CPCS, pcp, K, gens, d, bound_derivedLength;

    Info( InfoPolenta, 1,"Determine a constructive polycyclic sequence\n",
           "    for the input group ...");
    # setup
    gens := GeneratorsOfGroup( G );
    d := Length(gens[1][1]);
    # determine an upper bound for the derived length of G
    bound_derivedLength := d+2;
    CPCS := CPCS_finite_word( gens, bound_derivedLength );
    if CPCS = fail then return fail; fi;
    Info( InfoPolenta, 1, "finished." );
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Compute the relations of the polycyclic\n",
          "    presentation of the group ..." );
    pcp := POL_SetPcPresentation_finite( CPCS );
    Info( InfoPolenta, 1,"finished." );
    Info( InfoPolenta, 1, " " );

    Info( InfoPolenta, 1,"Construct the polycyclic presented group ..." );
    K := PcpGroupByCollector( pcp );
    Info( InfoPolenta, 1,"finished.");
    Info( InfoPolenta, 1, " " );

    return K;
end;

#############################################################################
##
#M PcpGroupByMatGroup( G )
##
## G is a matrix group over the Rationals or a finite field.
## Returned is PcpGroup ( polycyclically presented group)
## which is isomorphic to G.
##
InstallMethod( PcpGroupByMatGroup,
               "for matrix groups over a finite field (Polenta)", true,
               [ IsFFEMatrixGroup ], 0,
               POL_PcpGroupByMatGroup_finite );

InstallMethod( PcpGroupByMatGroup,
               "for rational matrix groups (Polenta)", true,
               [ IsRationalMatrixGroup ], 0,
               POL_PcpGroupByMatGroup_infinite );

## Enforce rationality check for cyclotomic matrix groups
RedispatchOnCondition( PcpGroupByMatGroup, true,
    [ IsCyclotomicMatrixGroup ], [ IsRationalMatrixGroup ],
    RankFilter(IsCyclotomicMatrixGroup) );

InstallOtherMethod( PcpGroupByMatGroup, "for polycyclic matrix groups (Polenta)", true,
               [ IsCyclotomicMatrixGroup, IsInt ], 0,
function( G, p )
    if not IsPrime(p) then
        Print( "Second argument must be a prime number.\n" );
        return fail;
    fi;
    if IsRationalMatrixGroup(G) then
        return POL_PcpGroupByMatGroup_infinite( G, p );
    fi;
    TryNextMethod();
end );

#############################################################################
##
#E
