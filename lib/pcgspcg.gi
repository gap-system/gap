#############################################################################
##
#W  pcgspcg.gi                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file   contains the methods  for polycylic  generating systems of pc
##  groups.
##
Revision.pcgspcg_gi :=
    "@(#)$Id$";


#############################################################################
##

#R  IsUnsortedPcgsRep
##
IsUnsortedPcgsRep := NewRepresentation(
    "IsUnsortedPcgsRep",
    IsPcgsDefaultRep, [] );


#############################################################################
##

#M  PcgsByPcSequenceNC( <fam>, <pcs> )
##


#############################################################################
InstallMethod( PcgsByPcSequenceNC,
    "elements family by rws with defining pcgs",
    true,
    [ IsElementsFamilyByRws and HasDefiningPcgs,
      IsHomogeneousList ],
    0,

function( efam, pcs )
    local   rws,  pfa,  pcgs,  pag,  id,  g,  dg,  i,  new,  ord;

    # quick check
    if not IsIdentical( efam, ElementsFamily(FamilyObj(pcs)) )  then
        Error( "elements family of <pcs> does not match <efam>" );
    fi;

    # check if it is the defining sequence
    rws := efam!.rewritingSystem;
    pfa := DefiningPcgs(efam);
    if List( pcs, UnderlyingElement ) = GeneratorsOfRws(rws)  then
        pcgs := PcgsByPcSequenceCons(
                    IsPcgsDefaultRep,
                    IsPcgs,
                    efam,
                    pcs );
        SetIsFamilyPcgs( pcgs, true );
        SetRelativeOrders( pcgs, RelativeOrders(rws) );

    # otherwise check if we can used an induced system
    elif IsSSortedList( List( pcs, x -> DepthOfPcElement(pfa,x) ) )  then
        pcgs := InducedPcgsByPcSequenceNC( pfa, pcs );

    # make an unsorted pcgs
    else
        pcgs := PcgsByPcSequenceCons(
                    IsPcgsDefaultRep,
                    IsPcgs and IsUnsortedPcgsRep,
                    efam,
                    pcs );

        # sort the elements according to the depth wrt pfa
        pag := [];
        new := [];
        ord := [];
        id  := One(pcs[1]);
     	for i  in [ Length(pcs), Length(pcs)-1 .. 1 ]  do
            g  := pcs[i];
      	    dg := DepthOfPcElement( pfa, g );
            while g <> id and IsBound(pag[dg])  do
          	g  := ReducedPcElement( pfa, g, pag[dg] );
     	    	dg := DepthOfPcElement( pfa, g );
            od;
            if g <> id  then
           	pag[dg] := g;
                new[dg] := i;
                ord[i]  := RelativeOrderOfPcElement( pfa, g );
            fi;
     	od;
        pcgs!.sortedPcSequence := pag;
        pcgs!.newDepths        := new;
        pcgs!.sortingPcgs      := pfa;
        SetRelativeOrders( pcgs, ord );

    fi;

    # that it
    return pcgs;

end );


#############################################################################
InstallMethod( PcgsByPcSequenceNC,
    "elements family by rws",
    true,
    [ IsElementsFamilyByRws,
      IsHomogeneousList ],
    0,

function( efam, pcs )
    local   pcgs,  rws;

    # quick check
    if not IsIdentical( efam, ElementsFamily(FamilyObj(pcs)) )  then
        Error( "elements family of <pcs> does not match <efam>" );
    fi;

    # check if it is the defining sequence
    rws := efam!.rewritingSystem;
    if List( pcs, UnderlyingElement ) = GeneratorsOfRws(rws)  then
        pcgs := PcgsByPcSequenceCons(
                    IsPcgsDefaultRep,
                    IsPcgs,
                    efam,
                    pcs );
        SetIsFamilyPcgs( pcgs, true );
        SetRelativeOrders( pcgs, RelativeOrders(rws) );

    # make an ordinary pcgs
    else
        pcgs := PcgsByPcSequenceCons(
                    IsPcgsDefaultRep,
                    IsPcgs,
                    efam,
                    pcs );
    fi;

    # that it
    return pcgs;

end );


#############################################################################
InstallMethod( PcgsByPcSequenceNC,
    "elements family by rws, empty sequence",
    true,
    [ IsElementsFamilyByRws,
      IsList and IsEmpty ],
    0,

function( efam, pcs )
    local   pcgs,  rws;

    # construct a pcgs
    pcgs := PcgsByPcSequenceCons(
                IsPcgsDefaultRep,
                IsPcgs,
                efam,
                pcs );

    # check if it is the defining sequence
    rws := efam!.rewritingSystem;
    if 0 = NumberGeneratorsOfRws(rws)  then
        SetIsFamilyPcgs( pcgs, true );
        SetRelativeOrders( pcgs, []   );
    fi;

    # that it
    return pcgs;

end );


#############################################################################
##
#M  PcgsByPcSequence( <fam>, <pcs> )
##


#############################################################################
InstallMethod( PcgsByPcSequence,
    true,
    [ IsElementsFamilyByRws,
      IsHomogeneousList ],
    0,

function( efam, pcs )
    #T  96/09/26 fceller  do some checks
    return PcgsByPcSequenceNC( efam, pcs );
end );
    

#############################################################################
InstallMethod( PcgsByPcSequence,
    true,
    [ IsElementsFamilyByRws,
      IsList and IsEmpty ],
    0,

function( efam, pcs )
    #T  96/09/26 fceller  do some checks
    return PcgsByPcSequenceNC( efam, pcs );
end );


#############################################################################
##

#M  DepthOfPcElement( <fam-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "family pcgs",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws ],
    100,

function( pcgs, elm )
    local   rep;

    rep := ExtRepOfObj( UnderlyingElement(elm) );
    if 0 = Length(rep)  then
        return Length(pcgs)+1;
    else
        return rep[1];
    fi;

end );


#############################################################################
##
#M  ExponentsOfPcElement( <fam-pcgs>, <elm> )
##
InstallMethod( ExponentsOfPcElement,
    "family pcgs",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws ],
    100,

function( pcgs, elm )
    local   exp,  rep,  i;

    exp := ListWithIdenticalEntries( Length( pcgs ), 0 );
    rep := ExtRepOfObj( UnderlyingElement(elm) );
    for i  in [ 1, 3 .. Length(rep)-1 ]  do
        exp[rep[i]] := rep[i+1];
    od;
    return exp;

end );


#############################################################################
##
#M  LeadingExponentOfPcElement( <fam-pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "family pcgs",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws ],
    100,

function( pcgs, elm )
    local   rep;

    rep := ExtRepOfObj( UnderlyingElement(elm) );
    if 0 = Length(rep)  then
        return fail;
    else
        return rep[2];
    fi;

end );


#############################################################################
##

#M  CanonicalPcElement( <igs>, <8bits-word> )
##
InstallMethod( CanonicalPcElement,
    "tail induced pcgs, 8bits word",
    IsCollsElms,
    [ IsInducedPcgs and IsTailInducedPcgsRep and IsParentPcgsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep ],
    100,

function( pcgs, elm )
    return 8Bits_HeadByNumber( elm, pcgs!.tailStart );
end );


#############################################################################
##
#M  DepthOfPcElement( <8bits-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "family pcgs (8 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep ],
    100,
    8Bits_DepthOfPcElement );


#############################################################################
##
#M  ExponentOfPcElement( <8bits-pcgs>, <elm> )
##
InstallMethod( ExponentOfPcElement,
    "family pcgs (8bits)",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep,
      IsInt and IsPosRat ],
    100,
    8Bits_ExponentOfPcElement );


#############################################################################
##
#M  HeadPcElementByNumber( <8bits-pcgs>, <8bits-word>, <num> )
##
InstallMethod( HeadPcElementByNumber,
    "family pcgs (8bits)",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep,
      IsInt ],
    100,

function( pcgs, elm, pos )
    return 8Bits_HeadByNumber( elm, pos );
end );


#############################################################################
##
#M  LeadingExponentOfPcElement( <8bits-pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "family pcgs (8 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is8BitsPcWordRep ],
    100,
    8Bits_LeadingExponentOfPcElement );


#############################################################################
##

#M  CanonicalPcElement( <igs>, <16bits-word> )
##
InstallMethod( CanonicalPcElement,
    "tail induced pcgs, 16bits word",
    IsCollsElms,
    [ IsInducedPcgs and IsTailInducedPcgsRep and IsParentPcgsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep ],
    100,

function( pcgs, elm )
    return 16Bits_HeadByNumber( elm, pcgs!.tailStart );
end );


#############################################################################
##
#M  DepthOfPcElement( <16bits-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "family pcgs (16 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep ],
    100,
    16Bits_DepthOfPcElement );


#############################################################################
##
#M  ExponentOfPcElement( <16bits-pcgs>, <elm> )
##
InstallMethod( ExponentOfPcElement,
    "family pcgs (16bits)",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep,
      IsInt and IsPosRat ],
    100,
    16Bits_ExponentOfPcElement );


#############################################################################
##
#M  HeadPcElementByNumber( <16bits-pcgs>, <16bits-word>, <num> )
##
InstallMethod( HeadPcElementByNumber,
    "family pcgs (16bits)",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep,
      IsInt ],
    100,

function( pcgs, elm, pos )
    return 16Bits_HeadByNumber( elm, pos );
end );


#############################################################################
##
#M  LeadingExponentOfPcElement( <16bits-pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "family pcgs (16 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is16BitsPcWordRep ],
    100,
    16Bits_LeadingExponentOfPcElement );


#############################################################################
##

#M  CanonicalPcElement( <igs>, <32bits-word> )
##
InstallMethod( CanonicalPcElement,
    "tail induced pcgs, 32bits word",
    IsCollsElms,
    [ IsInducedPcgs and IsTailInducedPcgsRep and IsParentPcgsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep ],
    100,

function( pcgs, elm )
    return 32Bits_HeadByNumber( elm, pcgs!.tailStart-1 );
end );


#############################################################################
##
#M  DepthOfPcElement( <32bits-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "family pcgs (32 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep ],
    100,
    32Bits_DepthOfPcElement );


#############################################################################
##
#M  ExponentOfPcElement( <32bits-pcgs>, <elm> )
##
InstallMethod( ExponentOfPcElement,
    "family pcgs (32bits)",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep,
      IsInt and IsPosRat ],
    100,
    32Bits_ExponentOfPcElement );


#############################################################################
##
#M  HeadPcElementByNumber( <32bits-pcgs>, <32bits-word>, <num> )
##
InstallMethod( HeadPcElementByNumber,
    "family pcgs (32bits)",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep,
      IsInt ],
    100,

function( pcgs, elm, pos )
    return 32Bits_HeadByNumber( elm, pos );
end );


#############################################################################
##
#M  LeadingExponentOfPcElement( <32bits-pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "family pcgs (32 bits)",
    IsCollsElms,
    [ IsPcgs and IsFamilyPcgs,
      IsMultiplicativeElementWithInverseByRws and Is32BitsPcWordRep ],
    100,
    32Bits_LeadingExponentOfPcElement );


#############################################################################
##

#M  DepthOfPcElement( <unsorted-pcgs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "unsorted pcgs",
    IsCollsElms,
    [ IsPcgs and IsUnsortedPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    local   pfa,  pcs,  new,  dep,  id,  dg;

    pfa := pcgs!.sortingPcgs;
    pcs := pcgs!.sortedPcSequence;
    new := pcgs!.newDepths;
    dep := Length(pcgs)+1;
    id  := OneOfPcgs(pcgs);

    # if <elm> is the identity return the composition length plus one
    if elm = id  then
        return Length(pcgs)+1;
    fi;
        
    # sift element through the sorted system
    while elm <> id  do
        dg := DepthOfPcElement( pfa, elm );
        if IsBound(pcs[dg])  then
            elm := ReducedPcElement( pfa, elm, pcs[dg] );
            if new[dg] < dep  then
                dep := new[dg];
            fi;
        else
            Error( "<elm> must lie in group defined by <pcgs>" );
        fi;
    od;
    return dep;
end );


#############################################################################
##
#M  ExponentOfPcElement( <unsorted-pcgs>, <elm>, <pos> )
##
InstallMethod( ExponentOfPcElement,
    "unsorted pcgs",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsPcgs and IsUnsortedPcgsRep,
      IsObject,
      IsInt and IsPosRat ],
    0,

function( pcgs, elm, pos )
    local   pfa,  pcs,  new,  dep,  id,  g,  dg,  ll,  lr,  ord, led;

    pfa := pcgs!.sortingPcgs;
    pcs := pcgs!.sortedPcSequence;
    new := pcgs!.newDepths;
    id  := OneOfPcgs(pcgs);

    # if <elm> is the identity return the null
    if elm = id  then
        return 0;
    fi;
        
    # sift element through the sorted system
    while elm <> id  do
        g   := elm;
        dep := Length(pcgs)+1;
        while g <> id  do
            dg := DepthOfPcElement( pfa, g );
            if IsBound(pcs[dg])  then
                ll  := LeadingExponentOfPcElement( pfa, g );
                lr  := LeadingExponentOfPcElement( pfa, pcs[dg] );
                ord := RelativeOrderOfPcElement( pfa, g );
                ll  := (ll/lr mod ord);
                g   := LeftQuotient( pcs[dg]^ll, g );
                if new[dg] < dep  then
                    dep := new[dg];
                    led := ll;
                fi;
            else
                Error( "<elm> must lie in group defined by <pcgs>" );
            fi;
        od;
        if dep = pos  then
            return led;
        fi;
        elm := LeftQuotient( pcgs[dep]^led, elm );
    od;
    return 0;
end );


#############################################################################
##
#M  ExponentsOfPcElement( <unsorted-pcgs>, <elm> )
##
InstallMethod( ExponentsOfPcElement,
    "unsorted pcgs",
    IsCollsElms,
    [ IsPcgs and IsUnsortedPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    local   pfa,  pcs,  new,  dep,  id,  exp,  g,  dg,  ll,  lr,  ord,  
            led;

    pfa := pcgs!.sortingPcgs;
    pcs := pcgs!.sortedPcSequence;
    new := pcgs!.newDepths;
    id  := OneOfPcgs(pcgs);
    exp := List( pcgs, x -> 0 );

    # if <elm> is the identity return the null vector
    if elm = id  then
        return exp;
    fi;
        
    # sift element through the sorted system
    while elm <> id  do
        g   := elm;
        dep := Length(pcgs)+1;
        while g <> id  do
            dg := DepthOfPcElement( pfa, g );
            if IsBound(pcs[dg])  then
                ll  := LeadingExponentOfPcElement( pfa, g );
                lr  := LeadingExponentOfPcElement( pfa, pcs[dg] );
                ord := RelativeOrderOfPcElement( pfa, g );
                ll  := (ll/lr mod ord);
                g   := LeftQuotient( pcs[dg]^ll, g );
                if new[dg] < dep  then
                    dep := new[dg];
                    led := ll;
                fi;
            else
                Error( "<elm> must lie in group defined by <pcgs>" );
            fi;
        od;
        exp[dep] := led;
        elm := LeftQuotient( pcgs[dep]^led, elm );
    od;
    return exp;
end );


#############################################################################
##
#M  LeadingExponentOfPcElement( <unsorted-pcgs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "unsorted pcgs",
    IsCollsElms,
    [ IsPcgs and IsUnsortedPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    local   pfa,  pcs,  new,  dep,  id,  dg,  ll,  lr,  ord,  led;

    pfa := pcgs!.sortingPcgs;
    pcs := pcgs!.sortedPcSequence;
    new := pcgs!.newDepths;
    dep := Length(pcgs)+1;
    id  := OneOfPcgs(pcgs);

    # if <elm> is the identity return fail
    if elm = id  then
        return fail;
    fi;
        
    # sift element through the sorted system
    while elm <> id  do
        dg := DepthOfPcElement( pfa, elm );
        if IsBound(pcs[dg])  then
            ll  := LeadingExponentOfPcElement( pfa, elm );
            lr  := LeadingExponentOfPcElement( pfa, pcs[dg] );
            ord := RelativeOrderOfPcElement( pfa, elm );
            ll  := (ll/lr mod ord);
            elm := LeftQuotient( pcs[dg]^ll, elm );
            if new[dg] < dep  then
                dep := new[dg];
                led := ll;
            fi;
        else
            Error( "<elm> must lie in group defined by <pcgs>" );
        fi;
    od;
    return led;
end );

#############################################################################
##

#M  Order( <obj> )  . . . . . . . . . . . . . . . . . . order of a pc-element
##

#############################################################################
InstallMethod( Order,
        "method for a pc-element",
        HasDefiningPcgs,
        [ IsMultiplicativeElementWithOne ], 3,
        function( g )
    local   pcgs,  rorders,  one,  ord,  d,  rord;

    pcgs := DefiningPcgs( FamilyObj( g ) );
    rorders := RelativeOrders( pcgs );
    
    one := g^0;
    ord := 1;

    if IsPrimeOrdersPcgs( pcgs ) then
        while g <> one do
            d    := DepthOfPcElement( pcgs, g );
            rord := rorders[ d ];
            ord  := ord * rord;
            g    := g^rord;
        od;
    else
        while g <> one do
            d    := DepthOfPcElement( pcgs, g );
            if not IsBound( rorders[d] ) or rorders[ d ] = 0 then
                return infinity;
            fi;
            rord := rorders[ d ];
            rord := rord / Gcd( ExponentOfPcElement( pcgs, g, d ), rord );
            ord  := ord * rord;
            g    := g^rord;
        od;
    fi;
    return ord;
end );



#############################################################################
##

#E  pcgspcg.gi	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
