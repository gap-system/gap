#############################################################################
##
#W  pcgs.gi                     GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for polycylic generating systems.
##
Revision.pcgs_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  SetPcgs( <G>, fail )  . . . . . . . . . . . . . . . . .  never set `fail'
##
##  `HasPcgs' implies  `IsPcgsComputable',  which implies `IsSolvable',  so a
##  pcgs cannot be set for insoluble permutation groups.
##
InstallMethod( SetPcgs, true, [ IsGroup, IsBool ], SUM_FLAGS, Ignore );


#############################################################################
##

#M  IsBound[ <pos> ]
##
InstallMethod( IsBound\[\],
    true,
    [ IsPcgs,
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
    [ IsPcgs and IsPcgsDefaultRep ],
    0,
    pcgs -> Length(pcgs!.pcSequence) );


#############################################################################
##
#M  Position( <pcgs>, <elm>, <from> )
##
InstallMethod( Position,
    true,
    [ IsPcgs and IsPcgsDefaultRep,
      IsObject,
      IsInt ],
    0,

function( pcgs, obj, from )
    return Position( pcgs!.pcSequence, obj, from );
end );


#############################################################################
##
#M  PrintObj( <pcgs> )
##
InstallMethod( PrintObj,
    true,
    [ IsPcgs and IsPcgsDefaultRep ],
    0,

function(pcgs)
    Print( "Pcgs(", pcgs!.pcSequence, ")" );
end );


#############################################################################
##
#M  <pcgs> [ <pos> ]
##
InstallMethod( \[\],
    true,
    [ IsPcgs and IsPcgsDefaultRep,
      IsInt and IsPosRat ],
    0,

function( pcgs, pos )
    return pcgs!.pcSequence[pos];
end );


#############################################################################
##

#M  PcgsByPcSequenceNC( <fam>, <filter>, <pcs> )
##
InstallOtherMethod( PcgsByPcSequenceNC,
    "generic constructor",
    true,
    [ IsFamily,
      IsObject,
      IsList ],
    0,

function( efam, filter, pcs )
    local   pcgs,  fam,  rws;

    # construct a pcgs object
    pcgs := rec();
    pcgs.pcSequence := Immutable(pcs);

    # if the <efam> has a family pcgs check if the are equal
    if HasDefiningPcgs(efam) and DefiningPcgs(efam) = pcgs!.pcSequence  then
        filter := filter and IsFamilyPcgs;
    fi;

    # get the pcgs family
    fam := CollectionsFamily(efam);

    # convert record into component object
    Objectify( NewKind( fam, filter ), pcgs );

    # set a one
    if HasOne(efam)  then
        SetOneOfPcgs( pcgs, One(efam) );
    elif 0 < Length(pcs)  then
        SetOneOfPcgs( pcgs, One(pcs[1]) );
    fi;

    # and return
    return pcgs;

end );


#############################################################################
##

#M  IsPrimeOrdersPcgs( <pcgs> )
##
InstallMethod( IsPrimeOrdersPcgs,
    true,
    [ IsPcgs ],
    0,

function( pcgs )
    return ForAll( RelativeOrders(pcgs), x -> IsPrimeInt(x) );
end );



#############################################################################
##
#M  IsFiniteOrdersPcgs( <pcgs> )
##
InstallMethod( IsFiniteOrdersPcgs,
    true,
    [ IsPcgs ],
    0,

function( pcgs )
    return ForAll( RelativeOrders(pcgs), x -> x <> 0 and x <> infinity );
end );


#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "generic methods, ExponentsOfPcElement",
    IsCollsElms,
    [ IsPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    return DepthVector( ExponentsOfPcElement( pcgs, elm ) );
end );


#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <elm>, <from> )
##
InstallOtherMethod( DepthOfPcElement,
    "generic method, ExponentsOfPcElement",
    function(F1,F2,F3) return IsCollsElms(F1,F2); end,
    [ IsPcgs,
      IsObject,
      IsInt ],
    0,

function( pcgs, elm, from )
    return DepthVector( ExponentsOfPcElement( pcgs, elm ), from );
end );


#############################################################################
##
#M  DifferenceOfPcElement( <pcgs>, <left>, <right> )
##
InstallMethod( DifferenceOfPcElement,
    "generic methods, PcElementByExponents/ExponentsOfPcElement",
    IsCollsElmsElms,
    [ IsPcgs,
      IsObject,
      IsObject ],
    0,

function( pcgs, left, right )
    return PcElementByExponents( pcgs,
        ExponentsOfPcElement(pcgs,left)-ExponentsOfPcElement(pcgs,right) );
end );


#############################################################################
##
#M  ExponentOfPcElement( <pcgs>, <elm>, <pos> )
##
InstallMethod( ExponentOfPcElement,
    "generic method, ExponentsOfPcElement",
    function(F1,F2,F3) return IsCollsElms(F1,F2); end,
    [ IsPcgs,
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
#M  LeadingExponentOfPcElement( <pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "generic methods, ExponentsOfPcElement",
    IsCollsElms,
    [ IsPcgs,
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
InstallMethod( PcElementByExponents,
    "generic method for empty lists",
    true,
    [ IsPcgs,
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
InstallMethod( PcElementByExponents,
    "generic method",
    true,
    [ IsPcgs,
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
InstallMethod( PcElementByExponents,
    "generic method",
    true,
    [ IsPcgs,
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
    [ IsPcgs,
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
    [ IsPcgs,
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
    [ IsPcgs,
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
InstallMethod( ReducedPcElement,
    "generic method",
    IsCollsElmsElms,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsObject,
      IsObject ],
    0,

function( pcgs, left, right )
    local   d,  ll,  lr,  ord;

    d := DepthOfPcElement( pcgs, left );
    if d <> DepthOfPcElement( pcgs, right )  then
        Error( "pc elms <left> and <right> have different depth" );
    fi;
    ll  := LeadingExponentOfPcElement( pcgs, left );
    lr  := LeadingExponentOfPcElement( pcgs, right );
    ord := RelativeOrderOfPcElement( pcgs, left );
    return LeftQuotient( right^(ll/lr mod ord), left );
end );


#############################################################################
##
#M  RelativeOrderOfPcElement( <pcgs>, <elm> )
##
InstallMethod( RelativeOrderOfPcElement,
    "generic method using RelativeOrders",
    IsCollsElms,
    [ IsPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    local   d;

    d := DepthOfPcElement(pcgs,elm);
    if d > Length(pcgs)  then
        return 1;
    else
        return RelativeOrders(pcgs)[d];
    fi;
end );


#############################################################################
##
#M  SetRelativeOrders( <pcgs>, <orders> )
##
InstallMethod( SetRelativeOrders,
    "setting orders and checking for prime orders",
    true,
    [ IsPcgs and IsComponentObjectRep and IsAttributeStoringRep,
      IsList ],
    SUM_FLAGS,

function( pcgs, orders )
    if not HasIsPrimeOrdersPcgs(pcgs)  then
        SetIsPrimeOrdersPcgs( pcgs, ForAll( orders, x -> IsPrimeInt(x) ) );
    fi;
    if not HasIsFiniteOrdersPcgs(pcgs)  then
        SetIsFiniteOrdersPcgs( pcgs,
            ForAll( orders, x -> x <> 0 and x <> infinity ) );
    fi;
    TryNextMethod();
end );


#############################################################################
##
#M  SumOfPcElement( <pcgs>, <left>, <right> )
##
InstallMethod( SumOfPcElement,
    "generic methods, PcElementByExponents/ExponentsOfPcElement",
    IsCollsElmsElms,
    [ IsPcgs,
      IsObject,
      IsObject ],
    0,

function( pcgs, left, right )
    return PcElementByExponents( pcgs,
        ExponentsOfPcElement(pcgs,left)+ExponentsOfPcElement(pcgs,right) );
end );


#############################################################################
##

#M  GroupByPcgs( <pcgs> )
##
GROUP_BY_PCGS_FINITE_ORDERS := function( pcgs )
    local   f,  e,  m,  i,  kind,  s,  id,  tmp,  j;

    # construct a new free group
    f := FreeGroup( Length(pcgs) );
    e := ElementsFamily( FamilyObj(f) );

    # and a default kind
    if 0 = Length(pcgs)  then
        m := 1;
    else
        m := Maximum(RelativeOrders(pcgs));
    fi;
    i := 1;
    while i < 4 and e!.expBitsInfo[i] <= m  do
        i := i + 1;
    od;
    kind := e!.kinds[i];

    # and use a single collector
    s := SingleCollector( f, RelativeOrders(pcgs) );

    # compute the power relations
    id := OneOfPcgs(pcgs);
    for i  in [ 1 .. Length(pcgs) ]  do
        tmp := pcgs[i]^RelativeOrderOfPcElement(pcgs,pcgs[i]);
        if tmp <> id  then
            tmp := ExponentsOfPcElement( pcgs, tmp );
            tmp := ObjByVector( kind, tmp );
            SetPowerNC( s, i, tmp );
        fi;
    od;

    # compute the conjugates
    for i  in [ 1 .. Length(pcgs) ]  do
        for j  in [ i+1 .. Length(pcgs) ]  do
            tmp := pcgs[j] ^ pcgs[i];
            if tmp <> id  then
                tmp := ExponentsOfPcElement( pcgs, tmp );
                tmp := ObjByVector( kind, tmp );
                SetConjugateNC( s, j, i, tmp );
            fi;
        od;
    od;

    # and return the new group
    return GroupByRwsNC(s);

end;


InstallMethod( GroupByPcgs,
    true,
    [ IsPcgs ],
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
#M  GroupOfPcgs( <pcgs> )
##
InstallMethod( GroupOfPcgs,
    true,
    [ IsPcgs ],
    0,

function( pcgs )
    local   tmp;

    tmp := Group( List( pcgs, x -> x ), OneOfPcgs(pcgs) );
    SetIsFinite( tmp, IsFiniteOrdersPcgs(pcgs) );
    return tmp;
end );


#############################################################################
##

#E  pcgs.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
