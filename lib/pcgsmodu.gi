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


#############################################################################
##
#R  IsModuloTailPcgsRep
##
IsModuloTailPcgsRep := NewRepresentation(
    "IsModuloTailPcgsRep",
    IsModuloPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap" ] );

                               
#############################################################################
##

#M  IsBound[ <pos> ]
##
InstallMethod( IsBound\[\],
    true,
    [ IsModuloPcgs,
      IsInt and IsPosRat ],
    0,

function( pcgs, pos )
    return pos <= Length(pcgs);
end );


#############################################################################
##
#M  Length( <pcgs> )
##
InstallMethod( Length,
    true,
    [ IsModuloPcgs and IsModuloPcgsRep ],
    0,
    pcgs -> Length(pcgs!.pcSequence) );


#############################################################################
##
#M  Position( <pcgs>, <elm>, <from> )
##
InstallMethod( Position,
    true,
    [ IsModuloPcgs and IsModuloPcgsRep,
      IsObject,
      IsInt ],
    0,

function( pcgs, obj, from )
    return Position( pcgs!.pcSequence, obj, from );
end );


#############################################################################
##
#M  PrintObj( <modulo-pcgs> )
##
InstallMethod( PrintObj,
    true,
    [ IsModuloPcgs ],
    0,

function( obj )
    Print( "(", NumeratorOfModuloPcgs(obj), "/",
           DenominatorOfModuloPcgs(obj), ")" );
end );


#############################################################################
##
#M  <pcgs> [ <pos> ]
##
InstallMethod( \[\],
    true,
    [ IsModuloPcgs and IsModuloPcgsRep,
      IsInt and IsPosRat ],
    0,

function( pcgs, pos )
    return pcgs!.pcSequence[pos];
end );


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
    filter := IsModuloPcgs;
    if IsEmpty(wd)  or  wd[Length(wd)] = Length(wd)  then
        filter := filter and IsModuloTailPcgsRep;
    else
        filter := filter and IsModuloPcgsRep;
    fi;

    # construct a pcgs from <pcs>
    new := PcgsByPcSequenceNC( FamilyObj(OneOfPcgs(pcgs)), filter, pcs );

    # store the one and other information
    SetOneOfPcgs( new, OneOfPcgs(pcgs) );
    if IsFiniteOrdersPcgs(pcgs)  then
        SetIsFiniteOrdersPcgs( new, true );
    fi;
    if IsPrimeOrdersPcgs(pcgs)  then
        SetIsPrimeOrdersPcgs( new, true );
    fi;
    SetRelativeOrders( new, RelativeOrders(pcgs){wd} );

    # store other useful information
    new!.moduloDepths := wm;
    SetDenominatorOfModuloPcgs( new, modulo );
    SetNumeratorOfModuloPcgs(   new, pcgs   );

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
#M  <modulo-pcgs1> mod <modulo-pcgs2>
##
InstallMethod( MOD,
    IsIdentical,
    [ IsModuloPcgs,
      IsModuloPcgs ],
    0,

function( pcgs, modulo )
    if DenominatorOfModuloPcgs(pcgs) <> DenominatorOfModuloPcgs(modulo)  then
        Error( "denominators of <pcgs> and <modulo> are not equal" );
    fi;
    return NumeratorOfModuloPcgs(pcgs) mod NumeratorOfModuloPcgs(modulo);
end );


#############################################################################
##

#M  DepthOfPcElement( <modulo-pcgs>, <elm>, <from> )
##
InstallOtherMethod( DepthOfPcElement,
    "pcgs modulo pcgs, ExponentsOfPcElement",
    function(F1,F2,F3) return IsCollsElms(F1,F2); end,
    [ IsModuloPcgs,
      IsObject,
      IsInt ],
    0,

function( pcgs, elm, from )
    return DepthVector( ExponentsOfPcElement( pcgs, elm ), from );
end );


#############################################################################
##
#M  ExponentOfPcElement( <modulo-pcgs>, <elm>, <pos> )
##
InstallOtherMethod( ExponentOfPcElement,
    "pcgs modulo pcgs, ExponentsOfPcElement",
    function(F1,F2,F3) return IsCollsElms(F1,F2); end,
    [ IsModuloPcgs,
      IsObject,
      IsInt and IsPosRat ],
    0,

function( pcgs, elm, pos )
    return ExponentsOfPcElement(pcgs,elm)[pos];
end );


#############################################################################
##
#M  ExponentsOfPcElement( <pcgs>, <elm>, <poss> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "with positions, falling back to ExponentsOfPcElement",
    function(F1,F2,F3) return IsCollsElms(F1,F2); end,
    [ IsPcgs,
      IsObject,
      IsList ],
    0,

function( pcgs, elm, pos )
    return ExponentsOfPcElement(pcgs,elm){pos};
end );


#############################################################################
##
#M  IsFiniteOrdersPcgs( <modulo-pcgs> )
##
InstallOtherMethod( IsFiniteOrdersPcgs,
    true,
    [ IsModuloPcgs ],
    0,

function( pcgs )
    return ForAll( RelativeOrders(pcgs), x -> x <> 0 and x <> infinity );
end );


#############################################################################
##
#M  IsPrimeOrdersPcgs( <modulo-pcgs> )
##
InstallOtherMethod( IsPrimeOrdersPcgs,
    true,
    [ IsModuloPcgs ],
    0,

function( pcgs )
    return ForAll( RelativeOrders(pcgs), x -> IsPrimeInt(x) );
end );



#############################################################################
##
#M  LeadingExponentOfPcElement( <modulo-pcgs>, <elm> )
##
InstallOtherMethod( LeadingExponentOfPcElement,
    "pcgs modulo pcgs, ExponentsOfPcElement",
    IsCollsElms,
    [ IsModuloPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    local   exp,  dep;

    exp := ExponentsOfPcElement( pcgs, elm );
    dep := DepthVector(exp);
    if Length(exp) < dep  then
        return fail;
    else
        return exp[dep];
    fi;
end );



#############################################################################
##
#M  PcElementByExponents( <pcgs>, <empty-list> )
##
InstallOtherMethod( PcElementByExponents,
    "generic method for empty lists",
    true,
    [ IsModuloPcgs,
      IsList and IsEmpty ],
    0,

function( pcgs, list )
    if Length(list) <> Length(pcgs)  then
        Error( "<list> and <pcgs> have different lengths" );
    fi;
    return OneOfPcgs(pcgs);
end );


#############################################################################
##
#M  PcElementByExponents( <pcgs>, <list> )
##
InstallOtherMethod( PcElementByExponents,
    "generic method",
    true,
    [ IsModuloPcgs,
      IsRowVector and IsCyclotomicsCollection ],
    0,

function( pcgs, list )
    local   elm,  i;

    elm := OneOfPcgs(pcgs);
    if Length(list) <> Length(pcgs)  then
        Error( "<list> and <pcgs> have different lengths" );
    fi;

    for i  in [ 1 .. Length(list) ]  do
        if list[i] <> 0  then
            elm := elm * pcgs[i] ^ list[i];
        fi;
    od;

    return elm;

end );


#############################################################################
##
#M  PcElementByExponents( <pcgs>, <ffe-list> )
##
InstallOtherMethod( PcElementByExponents,
    "generic method",
    true,
    [ IsModuloPcgs,
      IsRowVector and IsFFECollection ],
    0,

function( pcgs, list )
    local   elm,  i;

    elm := OneOfPcgs(pcgs);
    if Length(list) <> Length(pcgs)  then
        Error( "<list> and <pcgs> have different lengths" );
    fi;

    for i  in [ 1 .. Length(list) ]  do
        if list[i] <> 0  then
            elm := elm * pcgs[i] ^ IntFFE(list[i]);
        fi;
    od;

    return elm;

end );


#############################################################################
##
#M  PcElementByExponents( <pcgs>, <basis>, <empty-list> )
##
InstallOtherMethod( PcElementByExponents,
    "generic method for empty lists",
    true,
    [ IsModuloPcgs,
      IsList and IsEmpty,
      IsList and IsEmpty ],
    0,

function( pcgs, basis, list )
    return OneOfPcgs(pcgs);
end );


#############################################################################
##
#M  PcElementByExponents( <pcgs>, <basis>, <list> )
##
InstallOtherMethod( PcElementByExponents,
    "generic method",
    true,
    [ IsModuloPcgs,
      IsList,
      IsRowVector and IsCyclotomicsCollection ],
    0,

function( pcgs, basis, list )
    local   elm,  i;

    elm := OneOfPcgs(pcgs);
    if Length(list) <> Length(basis)  then
        Error( "<list> and <basis> have different lengths" );
    fi;

    for i  in [ 1 .. Length(list) ]  do
        if list[i] <> 0  then
            elm := elm * basis[i] ^ list[i];
        fi;
    od;

    return elm;

end );


#############################################################################
##
#M  PcElementByExponents( <pcgs>, <basis>, <list> )
##
InstallOtherMethod( PcElementByExponents,
    "generic method",
    true,
    [ IsModuloPcgs,
      IsList,
      IsRowVector and IsFFECollection ],
    0,

function( pcgs, basis, list )
    local   elm,  i;

    elm := OneOfPcgs(pcgs);
    if Length(list) <> Length(basis)  then
        Error( "<list> and <basis> have different lengths" );
    fi;

    for i  in [ 1 .. Length(list) ]  do
        if list[i] <> 0  then
            elm := elm * basis[i] ^ IntFFE(list[i]);
        fi;
    od;

    return elm;

end );


#############################################################################
##
#M  ReducedPcElement( <pcgs>, <left>, <right> )
##
InstallOtherMethod( ReducedPcElement,
    "pcgs modulo pcgs",
    IsCollsElmsElms,
    [ IsModuloPcgs,
      IsObject,
      IsObject ],
    0,

function( pcgs, left, right )
    return ReducedPcElement( NumeratorOfModuloPcgs(pcgs), left, right );
end );


#############################################################################
##
#M  RelativeOrderOfPcElement( <pcgs>, <elm> )
##
InstallOtherMethod( RelativeOrderOfPcElement,
    "pcgs modulo pcgs",
    IsCollsElms,
    [ IsModuloPcgs and IsPrimeOrdersPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    return RelativeOrderOfPcElement( NumeratorOfModuloPcgs(pcgs), elm );
end );

#############################################################################
##
#M  ModuloParentPcgs( <pcgs> ) 	. . . . . . . . . . . . . . delegate the task
##
InstallMethod( ModuloParentPcgs,
    true,
    [ IsPcgs ],
    0,
    pcgs -> ParentPcgs( pcgs ) mod pcgs );


#############################################################################
##

#M  DepthOfPcElement( <modulo-pcgs>, <elm> )
##
InstallOtherMethod( DepthOfPcElement,
    "pcgs modulo pcgs",
    IsCollsElms,
    [ IsModuloPcgs and IsModuloPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    local   d,  num;

    num := NumeratorOfModuloPcgs(pcgs);
    d := DepthOfPcElement( num, elm );
    if d > Length(num)  then
        return Length(pcgs)+1;
    elif d in pcgs!.moduloDepths  then
        return DepthVector( ExponentsOfPcElement( pcgs, elm ) );
    else
        return pcgs!.depthMap[d];
    fi;
end );


#############################################################################
##
#M  ExponentsOfPcElement( <modulo-pcgs>, <elm> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "pcgs modulo pcgs",
    IsCollsElms,
    [ IsModuloPcgs and IsModuloPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    local   id,  exp,  ros,  den,  num,  wm,  mm,  pm,  d,  ll,  lr;

    id  := OneOfPcgs(pcgs);
    exp := List( pcgs, x -> 0 );
    den := DenominatorOfModuloPcgs(pcgs);
    num := NumeratorOfModuloPcgs(pcgs);
    if not IsPrimeOrdersPcgs(num)  then TryNextMethod();  fi;

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


#############################################################################
##
#M  ExponentsOfPcElement( <tail-pcgs>, <elm> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "pcgs modulo tail-pcgs",
    IsCollsElms,
    [ IsModuloPcgs and IsModuloTailPcgsRep,
      IsObject ],
    0,
        
function( pcgs, elm )
    return ExponentsOfPcElement(
        NumeratorOfModuloPcgs(pcgs), elm, pcgs!.depthMap );
end );


#############################################################################
##

#M  HomomorphicCanonicalPcgs( <pcgs>, <imgs> )
##
InstallOtherMethod( HomomorphicCanonicalPcgs,
    true,
    [ IsModuloPcgs,
      IsList ],
    0,

function( pcgs, imgs )
    local   tmp;
    
    tmp := HomomorphicInducedPcgs( pcgs, imgs );
    return CanonicalPcgs(NumeratorOfModuloPcgs(tmp))
           mod DenominatorOfModuloPcgs(pcgs);
end );


#############################################################################
##
#M  HomomorphicCanonicalPcgs( <pcgs>, <imgs>, <obj> )
##
InstallOtherMethod( HomomorphicCanonicalPcgs,
    true,
    [ IsModuloPcgs,
      IsList,
      IsObject ],
    0,

function( pcgs, imgs, obj )
    local   tmp;

    tmp := HomomorphicInducedPcgs( pcgs, imgs, obj );
    return CanonicalPcgs(NumeratorOfModuloPcgs(tmp))
           mod DenominatorOfModuloPcgs(pcgs);
end );


#############################################################################
##
#M  HomomorphicInducedPcgs( <pcgs>, <imgs> )
##
##  It  is important that  <imgs>  are the images of  in  induced  generating
##  system  in their natural order, ie.  they must not be sorted according to
##  their  depths in the new group,  they must be  sorted according to  their
##  depths in the old group.
##
InstallOtherMethod( HomomorphicInducedPcgs,
    true,
    [ IsModuloPcgs,
      IsEmpty and IsList ],
    0,

function( pcgs, imgs )
    return InducedPcgsByPcSequenceNC( pcgs, [] );
end );


InstallOtherMethod( HomomorphicInducedPcgs,
    IsIdentical,
    [ IsModuloPcgs,
      IsHomogeneousList ],
    0,

function( pcgs, imgs )
    local   id,  pag,  g,  dg;

    id  := OneOfPcgs(pcgs);
    pag := [];
    for g  in Reversed(imgs)  do
        dg := DepthOfPcElement( pcgs, g );
        while g <> id  and IsBound(pag[dg])  do
            g  := ReducedPcElement( pcgs, g, pag[dg] );
            dg := DepthOfPcElement( pcgs, g );
        od;
        if g <> id  then
            pag[dg] := g;
        fi;
    od;
    return ExtendedIntersectionSumPcgs(
               NumeratorOfModuloPcgs(pcgs),
               DenominatorOfModuloPcgs(pcgs),
               Compacted(pag) ).sum
           mod DenominatorOfModuloPcgs(pcgs);
end );


#############################################################################
##
#M  HomomorphicInducedPcgs( <pcgs>, <imgs>, <func> )
##
InstallOtherMethod( HomomorphicInducedPcgs,
    true,
    [ IsPcgs,
      IsEmpty and IsList,
      IsFunction ],
    0,

function( pcgs, imgs, func )
    return InducedPcgsByPcSequenceNC( pcgs, [] );
end );


InstallOtherMethod( HomomorphicInducedPcgs,
    function(a,b,c) return IsIdentical(a,b); end,
    [ IsModuloPcgs and IsPrimeOrdersPcgs,
      IsHomogeneousList,
      IsFunction ],
    0,

function( pcgs, imgs, func )
    local   id,  pag,  g,  dg;

    id  := OneOfPcgs(pcgs);
    pag := [];
    for g  in Reversed(imgs)  do
        g  := func(g);
        dg := DepthOfPcElement( pcgs, g );
        while g <> id  and IsBound(pag[dg])  do
            g  := ReducedPcElement( pcgs, g, pag[dg] );
            dg := DepthOfPcElement( pcgs, g );
        od;
        if g <> id  then
            pag[dg] := g;
        fi;
    od;
    return ExtendedIntersectionSumPcgs(
               NumeratorOfModuloPcgs(pcgs),
               DenominatorOfModuloPcgs(pcgs),
               Compacted(pag) ).sum
           mod DenominatorOfModuloPcgs(pcgs);
end );


#############################################################################
##
#M  HomomorphicInducedPcgs( <pcgs>, <imgs>, <obj> )
##
InstallOtherMethod( HomomorphicInducedPcgs,
    true,
    [ IsModuloPcgs,
      IsEmpty and IsList,
      IsObject ],
    0,

function( pcgs, imgs, obj )
    return InducedPcgsByPcSequenceNC( pcgs, [] );
end );


InstallOtherMethod( HomomorphicInducedPcgs,
    function(a,b,c) return IsIdentical(a,b); end,
    [ IsModuloPcgs and IsPrimeOrdersPcgs,
      IsHomogeneousList,
      IsObject ],
    0,

function( pcgs, imgs, obj )
    local   id,  pag,  g,  dg;

    id  := OneOfPcgs(pcgs);
    pag := [];
    for g  in Reversed(imgs)  do
        g  := g^obj;
        dg := DepthOfPcElement( pcgs, g );
        while g <> id  and IsBound(pag[dg])  do
            g  := ReducedPcElement( pcgs, g, pag[dg] );
            dg := DepthOfPcElement( pcgs, g );
        od;
        if g <> id  then
            pag[dg] := g;
        fi;
    od;
    return ExtendedIntersectionSumPcgs(
               NumeratorOfModuloPcgs(pcgs),
               DenominatorOfModuloPcgs(pcgs),
               Compacted(pag) ).sum
           mod DenominatorOfModuloPcgs(pcgs);
end );


#############################################################################
##

#M  GroupByPcgs( <modulo-pcgs> )
##
InstallOtherMethod( GroupByPcgs,
    "pcgs modulo pcgs",
    true,
    [ IsModuloPcgs ],
    0,

function( pcgs )

    # the following only works for finite orders
    if not IsFiniteOrdersPcgs(pcgs)  then
        TryNextMethod();
    fi;
    return GROUP_BY_PCGS_FINITE_ORDERS(pcgs);

end );



#############################################################################
##
#M  GroupOfPcgs( <modulo-pcgs> )
##
InstallOtherMethod( GroupOfPcgs,
    true,
    [ IsModuloPcgs ],
    0,

function( pcgs )
    return GroupOfPcgs( NumeratorOfModuloPcgs( pcgs ) );
end );


#############################################################################
##

#E  pcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
