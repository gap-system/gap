#############################################################################
##
#W  grppcatr.gi                 GAP Library                      Frank Celler
#W                                                             & Bettina Eick
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for attributes of polycylic groups.
##
Revision.grppcatr_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  AsListSorted( <pcgrp> )
##
InstallMethod( AsListSorted,
    "pcgs computable groups",
    true,
    [ IsGroup and IsPcgsComputable and IsFinite ],
    0,

function( grp )
    local   elms,  pcgs,  g,  u,  e,  i;

    elms := [ One(grp) ];
    pcgs := Pcgs(grp);

    for g  in pcgs  do
        u := One(grp);
        e := ShallowCopy(elms);
        for i  in [ 1 .. RelativeOrderOfPcElement(pcgs,g)-1 ]  do
            u := u * g;
            UniteSet( elms, e * u );
        od;
    od;

    return elms;

end );


#############################################################################
##
#M  CompositionSeries( <G> )
##
InstallMethod( CompositionSeries,
    "pcgs computable groups",
    true, 
    [ IsGroup and IsPcgsComputable and IsFinite ],
    0,

function( G )
    local   pcgsG,  m,  S,  parent,  i,  igs,  U;

    # get a pcgs of <G>
    pcgsG := Pcgs(G);
    m     := Length(pcgsG);
    S     := [];

    # if <pcgsG> is induced use the parent
    if IsInducedPcgs(pcgsG)  then
        parent := ParentPcgs(pcgsG);
    else
        parent := pcgsG;
    fi;

    # compute the pcgs of the composition subgroups
    for i  in [ 1 .. m+1 ]  do
        igs := InducedPcgsByPcSequence( parent, pcgsG{[i..m]} );
        U   := Subgroup( G, igs );
        SetPcgs( U, igs );
        Add( S, U );
    od;

    # and return
    return S;

end );


#############################################################################
##
#M  DerivedSubgroup( <G> )
##
InstallMethod( DerivedSubgroup,
    "pcgs computable groups",
    true, 
    [ IsGroup and IsPcgsComputable and IsFinite ],
    0,

function( U )
    local   pcgsU,  C,  i,  j,  tmp;

    # compute the commutators of the elements of a pcgs
    pcgsU := Pcgs(U);
    C := [];
    for i  in [ 1 .. Length(pcgsU) ]  do
        for j  in [ i+1 .. Length(pcgsU) ]  do
            AddSet( C, Comm( pcgsU[j], pcgsU[i] ) );
        od;
    od;

    # if <pcgsU> is induced use the parent
    if IsInducedPcgs(pcgsU)  then
        tmp := InducedPcgsByGeneratorsNC( ParentPcgs(pcgsU), C );
    else
        tmp := InducedPcgsByGeneratorsNC( pcgsU, C );
    fi;
    C := Subgroup( U, tmp );
    SetPcgs( C, tmp ); 
    return C;
end);

    
#############################################################################
##
#M  ElementaryAbelianSeries( <G> )
##
InstallMethod( ElementaryAbelianSeries,
    "pcgs computable groups using special pcgs",
    true, 
    [ IsGroup and IsPcgsComputable and IsFinite ],
    0,

function( G )
    local   spec,  first,  m,  S,  i,  igs,  U;

    spec  := SpecialPcgs( G );
    first := LGFirst( spec );
    m     := Length( spec );
    S     := [G];
    for i  in [ 2 .. Length(first) ]  do
        igs := InducedPcgsByPcSequenceNC( spec, spec{[first[i]..m]} );
        U   := Subgroup( G, igs );
        SetPcgs( U, igs );
        Add( S, U );
    od;
    return S;
end);

#############################################################################
##
#M  FrattiniSubgroup( <G> )
##
InstallMethod( FrattiniSubgroup,
    "pcgs computable groups using prefrattini and core",
    true, 
    [ IsGroup and IsPcgsComputable and IsFinite ],
    0,

function( G )
    return Core( G, PrefrattiniSubgroup( G ) );
end);


#############################################################################
##
#M  HallSubgroupOp( <G>, <pi> )
##
##  compute and use special pcgs of <G>.
##
InstallMethod( HallSubgroupOp, 
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and IsPcgsComputable and IsFinite,
      IsList ],
    0,

function( G, pi )
    local pcgs, spec, weights, gens, i, S;

    spec := SpecialPcgs( G );
    weights := LGWeights( spec );
    gens := [];
    for i in [1..Length(spec)] do
        if weights[i][3] in pi then Add( gens, spec[i] ); fi;
    od;
    gens := InducedPcgsByPcSequenceNC( spec, gens );
    S := Subgroup( G, gens );
    SetPcgs( S, gens );
    return S;
end );


#############################################################################
##
#M  PrefrattiniSubgroup( <G> )
##
InstallMethod( PrefrattiniSubgroup,
    "pcgs computable groups using special pcgs",
    true, 
    [ IsGroup and IsPcgsComputable and IsFinite ],
    0,

function( G )
    local   pcgs,  spec,  first,  weights,  m,  pref,  i,  start,  
            next,  p,  pcgsS,  pcgsN,  pcgsL,  mats,  modu,  rad,  
            elms,  P;

    pcgs    := Pcgs(G);
    spec    := SpecialPcgs( pcgs );
    first   := LGFirst( spec );
    weights := LGWeights( spec );
    m       := Length( spec );
    pref    := [];
    for i in [1..Length(first)-1] do
        start := first[i];
        next  := first[i+1];
        p     := weights[start][3];
        if weights[start][1] > 1 and weights[start][2] = 1 and 
           start-next > 1 then
         
            pcgsS := InducedPcgsByPcSequenceNC( pcgs, pcgs{[start..m]} );
            pcgsN := InducedPcgsByPcSequenceNC( pcgs, pcgs{[next..m]} );
            pcgsL := pcgsS mod pcgsN;

            mats  := LinearOperationLayer( G, pcgsL );
            modu  := GModuleByMats( mats, GF(p) );
            rad   := MTX.BasesRadical( modu );
            elms  := List( rad, x -> PcElementByExponents( pcgsL, x ) );
            Append( pref, elms );

        elif weights[start][2] > 1 then
            Append(pref, spec{[start..next-1]} );
        fi;
    od;
    pref := InducedPcgsByPcSequenceNC( spec, pref );
    P    := Subgroup( G, pref );
    SetPcgs( P, pref );
    return P;
end);

#############################################################################
##
#M  Size( <pcgrp> )
##
InstallMethod( Size,
    "pcgs computable groups",
    true,
    [ IsGroup and IsPcgsComputable ],
    0,

function( grp )
    local   ords;

    ords := RelativeOrders(Pcgs(grp));
    if 0 in ords  then
        return infinity;
    else
        return Product(ords);
    fi;
end );


#############################################################################
##
#M  SylowComplementOp( <G>, <p> )
##
##  compute and use special pcgs of <G>.
##
InstallMethod( SylowComplementOp, 
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and IsPcgsComputable and IsFinite,
      IsPosRat and IsInt ],
    0,

function( G, p )
    local   spec,  weights,  gens,  i,  S;

    spec := SpecialPcgs( G );
    weights := LGWeights( spec );
    gens := [];
    for i in [1..Length(spec)] do
        if weights[i][3] <> p then Add( gens, spec[i] ); fi;
    od;
    gens := InducedPcgsByPcSequenceNC( spec, gens );
    S := Subgroup( G, gens );
    SetPcgs( S, gens );
    return S;
end );


#############################################################################
##
#M  SylowSubgroupOp( <G>, <p> )
##  
##  compute and use special pcgs of <G>.
##
InstallMethod( SylowSubgroupOp, 
    "pcgs computable groups using special pcgs",
    true,
    [ IsGroup and IsPcgsComputable and IsFinite,
      IsPosRat and IsInt ],
    0,

function( G, p )
    local   spec,  weights,  gens,  i,  S;

    spec := SpecialPcgs( G );
    weights := LGWeights( spec );
    gens := [];
    for i  in [1..Length(spec)]  do
        if weights[i][3] = p then Add( gens, spec[i] ); fi;
    od;
    gens := InducedPcgsByPcSequenceNC( spec, gens );
    S := Subgroup( G, gens );
    SetPcgs( S, gens );
    return S;
end );


#############################################################################
##

#F  MaximalSubgroupClassesRepsLayer( <pcgs>, <layer> )
##
MaximalSubgroupClassesRepsLayer := function( pcgs, l )
    local first, weights, m, start, next, pcgsS, pcgsN, pcgsL, p, mats, 
          modu, maxi, i, elms, sub, M, G;

    first   := LGFirst( pcgs );
    weights := LGWeights( pcgs );
    m       := Length( pcgs );
    start   := first[l];
    next    := first[l+1];
    G       := GroupOfPcgs( pcgs );

    # catch the trivial case
    if weights[start][2] <> 1 then
        return [];
    fi;

    pcgsS := InducedPcgsByPcSequenceNC( pcgs, pcgs{[start..m]} );
    pcgsN := InducedPcgsByPcSequenceNC( pcgs, pcgs{[next..m]} );
    pcgsL := pcgsS mod pcgsN;
    p     := weights[start][3];

    mats  := LinearOperationLayer( G, pcgsL );
    modu  := GModuleByMats( mats,  GF(p) );
    maxi  := MTX.BasesMaximalSubmodules( modu );

    for i in [1..Length( maxi )] do
        elms := List( maxi[i], x -> PcElementByExponents( pcgsL, x ) );
        sub  := Concatenation( pcgs{[1..start-1]}, elms, pcgsN );
        sub  := InducedPcgsByPcSequenceNC( pcgs, sub );
        M    := Subgroup( G, sub );
        SetPcgs( M, sub );
        maxi[i] := M;
    od;
    return maxi;
end;


#############################################################################
##
#M  MaximalSubgroupClassReps( <G> )
##
InstallMethod( MaximalSubgroupClassReps,
    "pcgs computable groups using special pcgs",
    true, 
    [ IsGroup and IsPcgsComputable ],
    0,

function( G )
    local pcgs, spec, first, max, i, new;

    spec  := SpecialPcgs(G);
    first := LGFirst( spec );
    max   := [];
    for i in [1..Length(first)-1] do
        new := MaximalSubgroupClassesRepsLayer( spec, i );
        Append( max, new );
    od;
    return max;

end );


#############################################################################
##
#M  MaximalSubgroups( <G> )
##
InstallMethod( MaximalSubgroups,
    "pcgs computable groups using special pcgs",
    true, 
    [ IsGroup and HasFamilyPcgs ],
    0,

function( G )
    local pcgs, spec, first, m, max, i, U, new, M;

    spec  := SpecialPcgs(G);
    first := LGFirst( spec );
    m     := Length( spec );
    max   := [];
    for i in [1..Length(first)-1] do
        U   := Subgroup( G, spec{[first[i]..m]} );
        new := MaximalSubgroupClassesRepsLayer( spec, i );
        for M in new do
            Append( max, ConjugateSubgroups( U, M ) );
        od; 
    od;
    return max;

end );


#############################################################################
##
#M  ConjugacyClassesMaximalSubgroups( <G> )
##
#T InstallMethod( ConjugacyClassesMaximalSubgroups,
#T     "generic method for groups with pcgs",
#T    true, 
#T    [ IsGroup and IsPcgsComputable ],
#T    0,
#T
#T function( G )
#T    return List( MaximalSubgroupClassReps(G), 
#T           x -> ConjugacyClassSubgroup( G, x ) );
#T end);


#############################################################################
##
#M  NormalMaximalSubgroups( <G> )
##
InstallMethod( NormalMaximalSubgroups,
    "pcgs computable groups using special pcgs",
    true, 
    [ IsGroup and IsPcgsComputable ],
    0,

function( G )
    local   spec,  first,  weights,  max,  i,  new;

    spec    := SpecialPcgs( G );
    first   := LGFirst( spec );
    weights := LGWeights( spec );
    max     := [];
    for i in [1..Length(first)-1] do
        if weights[first[i]][1] = 1 then
            new := MaximalSubgroupClassesRepsLayer( spec, i );
            Append( max, new );
        fi;
    od;
    return max;

end );


#############################################################################
##

#F  ModifyMinimalGeneratingSet( <pcgsG>, <pcgsS>, <pcgsN>, <pcgsU>, <min> )
##
ModifyMinimalGeneratingSet := function( pcgs, pcgsS, pcgsN, pcgsU, mingens )
    local M, pcgsF, g, i, newgens, pcgsT;

    M := ZassenhausIntersection( pcgs, pcgsS, pcgsU );
    pcgsF := pcgsS mod Pcgs(M);
    for g in pcgsF do
        for i in [1..Length( mingens )] do 
            newgens := ShallowCopy( mingens );
            newgens[i] := mingens[i] * g;
            pcgsT := InducedPcgsByPcSequenceAndGenerators( 
                                                     pcgs, pcgsN, newgens );
            if Length( pcgsT ) > Length( pcgsU ) then
                mingens[i] := mingens[i] * g;
                return pcgsT;
            fi;
        od;
    od;
    Add( mingens, pcgsF[1] );
    return InducedPcgsByPcSequenceAndGenerators( pcgs, pcgsN, mingens );
end;


#############################################################################
##
#M  MinimalGeneratingSet( <G> )
##
InstallMethod( MinimalGeneratingSet,
    "pcgs computable groups using special pcgs",
    true, 
    [ IsGroup and IsPcgsComputable ],
    0,

function( G )
    local spec, weights, first, m, mingens, i, start, next, j,
          pcgsN, pcgsS, pcgsU;

    if IsTrivial(G)  then
        return [];
    fi;
    spec    := SpecialPcgs( G );
    weights := LGWeights( spec );
    first   := LGFirst( spec );
    m       := Length( spec );

    # the first head
    mingens := spec{[1..first[2]-1]};
    i := 2;
    while i <= Length( first ) -1 and
          weights[first[i]][1] = 1 and weights[first[i]][2] = 1 do
        start := first[i];
        next  := first[i+1];
        for j in [1..next-start]  do
            if j <= Length(mingens)  then
                mingens[j] := mingens[j] * spec[ first+j-1 ];
            else
                Add(mingens, spec[ first+j-1 ] );
            fi;
        od;
        i := i + 1;
    od;
             
    # the other heads
    while i <= Length( first ) -1 do
        if weights[first[i]][2] = 1 then
            start := first[i];
            next  := first[i+1];
            pcgsS := InducedPcgsByPcSequenceNC( spec, spec{[start..m]} );
            pcgsN := spec{[next..m]};
            pcgsU := InducedPcgsByPcSequenceAndGenerators( 
                                                   spec, pcgsN, mingens );
            while Length( pcgsU ) < Length( spec ) do
                pcgsU := ModifyMinimalGeneratingSet( spec, pcgsS, pcgsN, 
                                                     pcgsU, mingens );
            od;
        fi;
        i := i + 1;
    od;
    return Set(mingens);
end );


#############################################################################
##
#M  SmallGeneratingSet(<G>) 
##
InstallMethod(SmallGeneratingSet,"using minimal generating set",true,
  [IsPcGroup],0,
function (G)
  return MinimalGeneratingSet(G);
end);


#############################################################################
##

#F  NextStepCentralizer( <gens>, <cent>, <pcgsF>, <field> )
##
NextStepCentralizer := function( gens, cent, pcgsF, field )
    local h, g, newgens, matlist, comm, null, elm, j;
  
    for g in gens do
        if Length( cent ) = 0 then return []; fi;

        newgens := [];
        matlist := [];
        for h in cent do
            comm := ExponentsOfPcElement( pcgsF, Comm( h, g ) ) * One(field);
            if comm = Zero( field ) * comm  then
                Add( newgens, h );
            else
                Add( matlist, comm );
            fi;
        od;
        cent := Difference( cent, newgens );
       
        if Length( matlist ) > 0  then
    
            # get nullspace
            null := NullspaceMat( matlist );

            # calculate elements corresponding to null
            for j  in [1..Length(null)]  do
                elm := PcElementByExponents( pcgsF, cent, null[j] );
                Add( newgens, elm );
            od;
        fi;
        cent := newgens;
    od;
    return cent;
end;


#############################################################################
##
#F  GeneratorsCentrePGroup( <U> )
##
GeneratorsCentrePGroup := function( U )
    local pcgs, p, ser, gens, cent, i, field, pcgsF;

    # catch the trivial case
    pcgs := Pcgs(U);
    if Length( pcgs ) = 0 then return []; fi;

    # set up series
    p     := RelativeOrderOfPcElement( pcgs, pcgs[1] );
    field := GF(p);
    ser   := List( PCentralSeries( U, p ), 
             x -> InducedPcgsByGeneratorsNC( pcgs, GeneratorsOfGroup(x) ) );
    gens  := AsList( ser[1] mod ser[2] );
    cent  := gens;
    for i in [2..Length(ser)-1] do
        pcgsF := ser[i] mod ser[i+1];
        cent := NextStepCentralizer( gens, cent, pcgsF, field );
        Append( cent, AsList( pcgsF ) );
    od;
    return cent;
end; 


#############################################################################
##
#M  Centre( <G> )
##
InstallMethod( Centre,
    "pcgs computable groups using special pcgs",
    true, 
    [ IsGroup and IsPcgsComputable ],
    0,

function( G )
    local   spec,  first,  weights,  m,  primes,  cent,  i,  gens,  
            start,  next,  p,  j,  field,  pcgsS,  pcgsN,  pcgsF,  q,  
            N,  hom,  F,  centF,  gensF,  U,  newgens,  matlist,  g,  
            conj,  expo,  order,  eigen,  null,  n,  elm;

    # get special pcgs
    spec    := SpecialPcgs( G );
    first   := LGFirst( spec );
    weights := LGWeights( spec );
    m       := Length( spec );

    # get primes and set up
    primes   := Set( List( weights, x -> x[3] ) );
    cent     := List( primes, x -> [] );

    # the first nilpotent factor
    i := 1;
    gens := [];
    while i <= Length( first ) - 1 and weights[first[i]][1] = 1 do
Print(i,"th layer\n");
        start := first[i];
        next  := first[i+1];
        p     := weights[start][3];
        j     := Position( primes, p );
        if weights[start][2] = 1 then
            gens[j] := spec{[start..next-1]};
            cent[j] := spec{[start..next-1]};
        elif weights[start][3] = p then
            field   := GF(p);
            pcgsS   := InducedPcgsByPcSequenceNC( spec, spec{[start..m]} );
            pcgsN   := InducedPcgsByPcSequenceNC( spec, spec{[next..m]} );
            pcgsF   := pcgsS mod pcgsN;
            cent[j] := NextStepCentralizer( gens[j], cent[j], pcgsF, field );
            Append( cent[j], AsList( pcgsF ) );
        fi;
        i := i + 1;
    od;

    # the remaining layers
    while i <= Length( first ) - 1 do
        start := first[i];
        next  := first[i+1];
Print(i,"th layer\n");
        q     := weights[start][3];
        field := GF(q); 
        gens := spec{[start..m]};
        pcgsS := InducedPcgsByPcSequenceNC( spec, spec{[start..m]} );
        pcgsN := InducedPcgsByPcSequenceNC( spec, spec{[next..m]} );
        pcgsF := pcgsS mod pcgsN;
       
        for j in [1..Length(primes)] do
            p := primes[j]; 
            if p = q and (weights[start][2] > 1 or Length( cent[j] ) > 0) then
Print("case p = q \n");
                
                N   := Subgroup( G, pcgsN );
                hom := NaturalHomomorphismByNormalSubgroup( G, N );
                F   := Range( hom );
                centF := List( cent[j], x -> Image( hom, x ) );
                gensF := List( pcgsF, x -> Image( hom, x ) );
                Append( centF, gensF );
               
                # calculate centre of centF 
                U     := Subgroup( F, centF );
                centF := GeneratorsCentrePGroup( U );
                cent[j] := List( centF, 
                                 x -> PreImagesRepresentative( hom, x ) );

                # get centralizer
                gens := spec{Filtered([1..start-1], x -> weights[x][2] = 1
                                                    and weights[x][3] <> p)};
                cent[j] := NextStepCentralizer( gens, cent[j], pcgsF, field ); 

            # case p <> q
            elif Length( cent[j] ) > 0 then
Print("case p <> q \n");
                # get operation of centF on M
                newgens := [];
                matlist := [];
                for g in cent[j] do
                    conj := List( pcgsF, 
                            x -> ExponentsOfPcElement( pcgsF, x^g ) ) 
                            * One( field );
                    if conj = conj^0  then
                        AddSet( newgens, g );
                    else
                        Add( matlist, conj );  
                    fi;
                od;       
                cent[j] := Difference( cent[j], newgens );

                if Length( matlist ) > 0  then

                    # get exponent of <cent[j]> mod N 
                    expo := 1;
                    for g in cent[j] do
                        order := 1;
                        while SiftedPcElement( pcgsN, g ) <> Identity(G) do
                            g := g ^ p;
                            order := order * p;
                        od;
                        expo := Maximum( expo, order );
                    od;

                    # calculate simultaneous eigenvalues
                    eigen := SimultaneousEigenvalues( matlist, expo );
    
                    # solve system
                    null := NullspaceModQ( eigen, expo );

                    # calculate elements corresponding to null
                    for n in null do
                        elm := PcElementByExponents( pcgsF, cent[j], n );
                        if elm <> Identity( G ) then
                            AddSet( newgens, elm );
                        fi;
                    od;
                fi;
                cent[j] := newgens;
            fi;
        od;
        i := i + 1;
    od;

    # return centre as direct product of p-parts
    return Subgroup( G, Concatenation( cent ) );
end );


#############################################################################
##

#E  grppcpatr.gi  . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
