#############################################################################
##
#W  pcgsmodu.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the   methods for polycylic generating  systems modulo
##  another such system.
##
Revision.pcgsmodu_gi :=
    "@(#)$Id$";


#############################################################################
##

#R  IsModuloPcgsRep
##
IsModuloPcgsRep := NewRepresentation(
    "IsModuloPcgsRep",
    IsPcgsDefaultRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap" ] );

IsModuloTailPcgsRep := NewRepresentation(
    "IsModuloTailPcgsRep",
    IsModuloPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap" ] );
                               
#############################################################################
##

#M  <pcgs1> mod <pcgs2>
##
InstallMethod( MOD,
    IsIdentical,
    [ IsPcgs,
      IsPcgs ],
    0,

function( pcgs, modulo )
    local   wm,  pcs,  filter,  new,  wd,  i;

    # compute the weights in <modulo>
    wm := List( modulo, x -> DepthOfPcElement( pcgs, x ) );

    # remove these elements from <pcgs>
    wd  := Difference( [1..Length(pcgs)], wm );
    pcs := pcgs{wd};

    # check which filter to use
    if IsEmpty( wd )  or  wd[ Length( wd ) ] = Length( wd )  then
        filter := IsModuloTailPcgsRep;
    else
        filter := IsModuloPcgsRep;
    fi;

    # construct a pcgs from <pcs>
    new := PcgsByPcSequenceNC( FamilyObj(OneOfPcgs(pcgs)), filter, pcs );

    # store the one and other information
    SetOneOfPcgs( new, OneOfPcgs(pcgs) );
    if IsFiniteOrdersPcgs(pcgs)  then
        SetIsFiniteOrdersPcgs( pcgs, true );
    fi;
    if IsPrimeOrdersPcgs(pcgs)  then
        SetIsPrimeOrdersPcgs( pcgs, true );
    fi;
    SetRelativeOrders( new, RelativeOrders(pcgs){wd} );

    # store other useful information
    new!.moduloDepths := wm;
    new!.denominator  := modulo;
    new!.numerator    := pcgs;

    # setup the maps
    new!.moduloMap := [];
    for i  in [ 1 .. Length(wm) ]  do
        new!.moduloMap[wm[i]] := i;
    od;
    new!.depthMap := [];
    for i  in [ 1 .. Length(wd) ]  do
        new!.depthMap[wd[i]] := i;
    od;

    # and return
    return new;

end );


#############################################################################
##

#M  ExponentsOfPcElement( <pcgs>, <elm> )
##
InstallMethod( ExponentsOfPcElement,
    "pcgs modulo pcgs",
    IsCollsElms,
    [ IsPcgs and IsModuloPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    local   id,  exp,  ros,  den,  num,  wm,  mm,  pm,  d,  ll,  lr;

    id  := OneOfPcgs(pcgs);
    exp := List( pcgs, x -> 0 );
    den := pcgs!.denominator;
    num := pcgs!.numerator;
    wm  := pcgs!.moduloDepths;
    mm  := pcgs!.moduloMap;
    pm  := pcgs!.depthMap;
    ros := RelativeOrders(num);
    while elm <> id  do
        d := DepthOfPcElement( num, elm );
        if IsBound(mm[d])  then
            ll  := LeadingExponentOfPcElement( num, elm );
            lr  := LeadingExponentOfPcElement( num, den[mm[d]] );
            elm := LeftQuotient( den[mm[d]]^(ll / lr mod ros[d]), elm );
        else
            ll := LeadingExponentOfPcElement( num, elm );
            lr := LeadingExponentOfPcElement( num, pcgs[pm[d]] );
            exp[pm[d]] := ll / lr mod ros[d];
            elm := LeftQuotient( pcgs[pm[d]]^exp[pm[d]], elm );
        fi;
    od;
    return exp;
end );

InstallMethod( ExponentsOfPcElement,
    "pcgs modulo tail-pcgs",
    IsCollsElms,
    [ IsPcgs and IsModuloTailPcgsRep,
      IsObject ],
    0,
        
function( pcgs, elm )
    return ExponentsOfPcElement( pcgs!.numerator, elm, pcgs!.depthMap );
end );

#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "pcgs modulo pcgs",
    IsCollsElms,
    [ IsPcgs and IsModuloPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    local   d;

    d := DepthOfPcElement( pcgs!.numerator, elm );
    if d in pcgs!.moduloDepths  then
        TryNextMethod();
    else
        return pcgs!.depthMap[d];
    fi;
end );


#############################################################################
##

#E  pcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
