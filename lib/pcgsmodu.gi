#############################################################################
##
#W  pcgsmodu.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
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
DeclareRepresentation(
    "IsModuloPcgsRep",
    IsPcgsDefaultRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap" ] );


#############################################################################
##
#R  IsModuloTailPcgsRep
##
DeclareRepresentation(
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
      IsPosInt ],
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
    Print( "(", NumeratorOfModuloPcgs(obj), " mod ",
           DenominatorOfModuloPcgs(obj), ")" );
end );


#############################################################################
##
#M  <pcgs> [ <pos> ]
##
InstallMethod( \[\],
    true,
    [ IsModuloPcgs and IsModuloPcgsRep,
      IsPosInt ],
    0,

function( pcgs, pos )
    return pcgs!.pcSequence[pos];
end );


#############################################################################
##

#M  ModuloParentPcgs( <pcgs> )
##
InstallMethod( ModuloParentPcgs,
    true,
    [ IsPcgs ],
    0,
    pcgs -> ParentPcgs( pcgs ) mod pcgs );


#############################################################################
##
#M  ModuloPcgsByPcSequenceNC( <home>, <pcs>, <modulo> )
##
InstallMethod( ModuloPcgsByPcSequenceNC,
    "generic method",
    true,
    [ IsPcgs,
      IsList,
      IsInducedPcgs ],
    0,

function( home, list, modulo )
    local   pcgs,  wm,  wp,  wd,  pcs,  filter,  new,  i;

    # <list> is a pcgs for the sum of <list> and <modulo>
    if IsPcgs(list) and ParentPcgs(modulo) = list  then
        pcgs := list;
        wm   := List( modulo, x -> DepthOfPcElement( pcgs, x ) );
        wp   := [ 1 .. Length(list) ];
        wd   := Difference( wp, wm );
        pcs  := list{wd};

    # otherwise compute the sum
    else
        pcgs := SumPcgs( home, modulo, list );
        wm   := List( modulo, x -> DepthOfPcElement( pcgs, x ) );
        wp   := List( list,   x -> DepthOfPcElement( pcgs, x ) );
        if not IsSubset( pcgs, list )  then
            pcgs := List(pcgs);
            for i  in [ 1 .. Length(list) ]  do
                pcgs[wp[i]] := list[i];
            od;
            pcgs := InducedPcgsByPcSequenceNC( home, pcgs );
        fi;
        wd   := Difference( wp, wm );
        pcs  := list{ List( wd, x -> Position( wp, x ) ) };
    fi;

    # check which filter to use
    filter := IsModuloPcgs;
    if IsEmpty(wd) or wd[Length(wd)] = Length(wd)  then
        filter := filter and IsModuloTailPcgsRep;
    else
        filter := filter and IsModuloPcgsRep;
    fi;
    if IsFiniteOrdersPcgs(pcgs)  then
        filter := filter and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
    fi;
    if IsPrimeOrdersPcgs(pcgs)  then
        filter := filter and HasIsPrimeOrdersPcgs and IsPrimeOrdersPcgs;
    fi;

    # construct a pcgs from <pcs>
    new := PcgsByPcSequenceCons(
               IsPcgsDefaultRep,
               filter,
               FamilyObj(OneOfPcgs(pcgs)),
               pcs );

    # store the one and other information
    SetOneOfPcgs( new, OneOfPcgs(pcgs) );
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
#M  ModuloPcgsByPcSequence( <home>, <pcs>, <modulo> )
##
InstallMethod( ModuloPcgsByPcSequence,
    "generic method",
    true,
    [ IsPcgs,
      IsList,
      IsInducedPcgs ],
    0,

function( home, list, modulo )
    return ModuloPcgsByPcSequenceNC( home, list, modulo );
end );


#############################################################################
##
#M  <pcgs1> mod <induced-pcgs2>
##
InstallMethod( MOD,"parent pcgs mod induced pcgs",
    IsIdenticalObj,
    [ IsPcgs,
      IsInducedPcgs ],
    0,

function( pcgs, modulo )
    if ParentPcgs(modulo) <> pcgs  then
        TryNextMethod();
    fi;
    return ModuloPcgsByPcSequenceNC( pcgs, pcgs, modulo );
end );

#############################################################################
##
#M  <pcgs1> mod <pcgs2>
##
InstallMethod( MOD,"two parent pcgs",
    IsIdenticalObj,
    [ IsPcgs,
      IsPcgs ],
    0,

function( pcgs, modulo )
    if modulo <> pcgs  then
        TryNextMethod();
    fi;
    return ModuloPcgsByPcSequenceNC( pcgs, pcgs, modulo );
end );


#############################################################################
##
#M  <induced-pcgs1> mod <induced-pcgs2>
##
InstallMethod( MOD,"two induced pcgs",
    IsIdenticalObj,
    [ IsInducedPcgs,
      IsInducedPcgs ],
    0,

function( pcgs, modulo )
    if ParentPcgs(modulo) <> ParentPcgs(pcgs)  then
        TryNextMethod();
    fi;
    return ModuloPcgsByPcSequenceNC( ParentPcgs(pcgs), pcgs, modulo );
end );


#############################################################################
##
#M  <modulo-pcgs1> mod <modulo-pcgs2>
##
InstallMethod( MOD,"two modulo pcgs",
    IsIdenticalObj,
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
#M  <(induced)pcgs1> mod <(induced)pcgs 2>
##
InstallMethod( MOD,"two induced pcgs",
    IsIdenticalObj, [ IsPcgs, IsPcgs ], 0,
function( pcgs, modulo )

  # enforce the same parent pcgs
  if ParentPcgs(modulo) <> ParentPcgs(pcgs)  then
    modulo:=InducedPcgsByGeneratorsNC(ParentPcgs(pcgs),AsList(modulo));
  fi;

  return ModuloPcgsByPcSequenceNC( ParentPcgs(pcgs), pcgs, modulo );
end);

#############################################################################
##

#M  DepthOfPcElement( <modulo-pcgs>, <elm>, <min> )
##
InstallOtherMethod( DepthOfPcElement,
    "pcgs modulo pcgs, ignoring <min>",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsModuloPcgs,
      IsObject,
      IsInt ],
    0,

function( pcgs, elm, min )
    local   dep;

    dep := DepthOfPcElement( pcgs, elm );
    if dep < min  then
        Error( "minimal depth <min> is incorrect" );
    fi;
    return dep;
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
      IsPosInt ],
    0,

function( pcgs, elm, pos )
    return ExponentsOfPcElement(pcgs,elm)[pos];
end );


#############################################################################
##
#M  ExponentsOfPcElement( <pcgs>, <elm>, <poss> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "pcgs modulo pcgs with positions, falling back to ExponentsOfPcElement",
    IsCollsElmsX,
    [ IsModuloPcgs,
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
    dep := PositionNot( exp, 0 );
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
      IsRowVector and IsCyclotomicCollection ],
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
      IsRowVector and IsCyclotomicCollection ],
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
    local   elm,  i,  z;

    elm := OneOfPcgs(pcgs);
    if Length(list) <> Length(basis)  then
        Error( "<list> and <basis> have different lengths" );
    fi;

    for i  in [ 1 .. Length(list) ]  do
        z := IntFFE(list[i]);
        if z <> 0  then
            elm := elm * basis[i] ^ z;
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
    # as we fall back on the code for pcgs, we must be sure that the method
    # has lower value
    SIZE_FLAGS(FLAGS_FILTER(IsModuloPcgs))
    -SIZE_FLAGS(FLAGS_FILTER(IsModuloPcgs and IsPrimeOrdersPcgs)),

function( pcgs, elm )
    return RelativeOrderOfPcElement( NumeratorOfModuloPcgs(pcgs), elm );
end );

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
        return PositionNot( ExponentsOfPcElement( pcgs, elm ), 0 );
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
#M  NumeratorOfModuloPcgs( <pcgs> )
##
InstallMethod(NumeratorOfModuloPcgs,"for pcgs",true,[IsPcgs],0,
function(pcgs)
if IsModuloPcgs(pcgs) and not IsPcgs(pcgs) then
  TryNextMethod();
fi;
return pcgs;
end);


#############################################################################
##
#M  DenominatorOfModuloPcgs( <pcgs> )
##
InstallMethod(DenominatorOfModuloPcgs,"for pcgs",true,[IsPcgs],0,
function(pcgs)
if IsModuloPcgs(pcgs) and not IsPcgs(pcgs) then
  TryNextMethod();
fi;
return InducedPcgsByGeneratorsNC(pcgs,[]);
end);



#############################################################################
##
#M  ModuloPcgs( <G>,<H> )
##
InstallMethod(ModuloPcgs,"for groups",IsIdenticalObj,[IsGroup,IsGroup],0,
function(G,H)
  G:=InducedPcgsWrtHomePcgs(G);
  return G mod InducedPcgs(G,H);
end);

#############################################################################
##

#E  pcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
