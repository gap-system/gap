#############################################################################
##
#W  pcgsind.gi                  GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file  contains  the operations   for  induced polycylic  generating
##  systems.
##
Revision.pcgsind_gi :=
    "@(#)$Id$";


#############################################################################
##

#R  IsInducedPcgsRep
##
IsInducedPcgsRep := NewRepresentation(
    "IsInducedPcgsRep",
    IsPcgsDefaultRep, [ "depthsInParent", "depthMapFromParent" ] );


#############################################################################
##
#R  IsSubsetInducedPcgsRep
##
IsSubsetInducedPcgsRep := NewRepresentation(
    "IsSubsetInducedPcgsRep",
    IsInducedPcgsRep, [] );


#############################################################################
##
#R  IsTailInducedPcgsRep
##
IsTailInducedPcgsRep := NewRepresentation(
    "IsTailInducedPcgsRep",
    IsSubsetInducedPcgsRep, [] );


#############################################################################
##

#M  InducedPcgsByPcSequenceNC( <pcgs>, <empty-list> )
##
InstallMethod( InducedPcgsByPcSequenceNC,
    "pcgs, empty list",
    true,
    [ IsPcgs,
      IsList and IsEmpty ],
    0,

function( pcgs, pcs )
    local  efam, filter,  igs;
    
    # check which filter to use
    filter := IsEmpty;

    # get family
    efam := FamilyObj( OneOfPcgs( pcgs ) );

    # construct a pcgs from <pcs>
    igs := PcgsByPcSequenceCons(
               IsPcgsDefaultRep,
               IsPcgs and IsInducedPcgs and IsInducedPcgsRep,
               efam,
               pcs );

    # we know the relative orders
    SetIsPrimeOrdersPcgs( igs, true );
    #AH implied by true method: SetIsFiniteOrdersPcgs( igs, true );
    SetRelativeOrders( igs, [] );

    # store the parent
    SetParentPcgs( igs, pcgs );
    igs!.depthMapFromParent := [];
    igs!.depthMapFromParent[Length(pcgs)+1] := 1;
    igs!.depthsInParent := [];

    # and return
    return igs;
    
end );


#############################################################################
##
#M  InducedPcgsByPcSequenceNC( <pcgs>, <pcs> )
##
InstallMethod( InducedPcgsByPcSequenceNC,
    "pcgs, homogeneous list",
    IsIdentical,
    [ IsPcgs,
      IsCollection and IsHomogeneousList ],
    0,

function( pcgs, pcs )
    local   efam,  filter,  j,  l,  i,  m,  d,  igs,  tmp;

    # get the elements family
    efam := FamilyObj( OneOfPcgs( pcgs ) );

    # check which filter to use
    filter := IsPcgs and IsInducedPcgsRep;
    j := 1;
    l := Length(pcgs);
    i := 1;
    m := Length(pcs);
    d := [];
    while i <= m and j <= l  do
        if pcgs[j] = pcs[i]  then
            d[i] := j;
            j := j + 1;
            i := i + 1;
        else
            j := j + 1;
        fi;
    od;
    if m < i  then
        filter := filter and IsCanonicalPcgs and IsSubsetInducedPcgsRep;
        if 0 < Length(pcgs) and pcgs[Length(pcgs)-Length(pcs)+1]=pcs[1]  then
            filter := filter and IsTailInducedPcgsRep;
        fi;
    fi;
    if HasIsFamilyPcgs(pcgs) and IsFamilyPcgs(pcgs)  then
        filter := filter and IsParentPcgsFamilyPcgs;
    fi;
    filter := filter and IsInducedPcgs;
    if HasIsPrimeOrdersPcgs(pcgs) and IsPrimeOrdersPcgs(pcgs)  then
        filter := filter and HasIsPrimeOrdersPcgs and IsPrimeOrdersPcgs;
    fi;
    if HasIsFiniteOrdersPcgs(pcgs) and IsFiniteOrdersPcgs(pcgs)  then
        filter := filter and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
    fi;

    # construct a pcgs from <pcs>
    igs := PcgsByPcSequenceCons(
               IsPcgsDefaultRep,
               filter,
               efam,
               pcs );

    # store the parent
    SetParentPcgs( igs, pcgs );

    # store other useful information
    igs!.depthMapFromParent := [];
    igs!.depthsInParent := [];
    if IsSubsetInducedPcgsRep(igs)  then
        igs!.depthsInParent := d;
        for i  in [ 1 .. Length(pcs) ]  do
            igs!.depthMapFromParent[d[i]] := i;
        od;
    else
        for i  in [ 1 .. Length(pcs) ]  do
            tmp := DepthOfPcElement( pcgs, pcs[i] );
            igs!.depthsInParent[i] := tmp;
            igs!.depthMapFromParent[tmp] := i;
        od;
    fi;
    igs!.depthMapFromParent[Length(pcgs)+1] := Length(pcs)+1;

    # store tail start
    if IsTailInducedPcgsRep(igs)  then
        igs!.tailStart := d[1];
    else
        i := Length(igs!.depthMapFromParent);
        while 2 <= i and IsBound(igs!.depthMapFromParent[i-1])  do
            i := i-1;
        od;
        igs!.tailStart := i;
    fi;

    # the depth must be compatible with the parent
    tmp := 0;
    for i  in [ 1 .. Length(igs!.depthsInParent) ]  do
        if tmp >= igs!.depthsInParent[i]  then
            Error( "depths are not compatible with parent pcgs" );
        fi;
        tmp := igs!.depthsInParent[i];
    od;

    # if we know the relative orders use them
    if HasRelativeOrders(pcgs)  then
        tmp := RelativeOrders(pcgs);
        tmp := tmp{igs!.depthsInParent};
        SetRelativeOrders( igs, tmp );
    fi;

    # and return
    return igs;
    
end );


#############################################################################
##
#M  InducedPcgsByPcSequence( <pcgs>, <empty-list> )
##
InstallMethod( InducedPcgsByPcSequence,
    true,
    [ IsPcgs,
      IsList and IsEmpty ],
    0,

function( pcgs, pcs )
    #T 1996/09/26 fceller do some checks
    return InducedPcgsByPcSequenceNC( pcgs, pcs );
end );


#############################################################################
##
#M  InducedPcgsByPcSequence( <pcgs>, <pcs> )
##
InstallMethod( InducedPcgsByPcSequence,
    true,
    [ IsPcgs,
      IsCollection and IsHomogeneousList ],
    0,

function( pcgs, pcs )
    #T 1996/09/26 fceller do some checks
    return InducedPcgsByPcSequenceNC( pcgs, pcs );
end );


#############################################################################
##

#M  InducedPcgsByPcSequenceAndGenerators( <pcgs>, <ind>, <gens> )
##
InstallMethod( InducedPcgsByPcSequenceAndGenerators,
    true,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsList,
      IsList ],
    0,

function( pcgs, sub, gens )
    local   max,  id,  wseen,  igs,  chain,  new,  seen,  old,  
            u,  uw,  up,  x,  c,  cw,  i,  j,  ro;

    # do family checks here to avoid problems with the empty list
    if not IsEmpty(sub)  then
        if not IsIdentical( FamilyObj(pcgs), FamilyObj(sub) )  then
            Error( "<pcgs> and <gens> have different families" );
        fi;
    fi;
    if not IsEmpty(gens)  then
        if not IsIdentical( FamilyObj(pcgs), FamilyObj(gens) )  then
            Error( "<pcgs> and <gens> have different families" );
        fi;
    fi;

    # get relative orders and composition length
    ro  := RelativeOrders(pcgs);
    max := Length(pcgs);

    # get the identity
    id := OneOfPcgs(pcgs);

    # and keep a list of seen weights
    wseen := BlistList( [ 1 .. max ], [] );

    # the induced generating sequence will be collected into <igs>
    igs := List( [ 1 .. max ], x -> id );
    for i  in sub  do
        igs[DepthOfPcElement(pcgs,i)] := i;
    od;

    # <chain> gives a chain of trailing weights
    chain := max+1;
    while 1 < chain and igs[chain-1] <> id  do
        chain := chain-1;
    od;

    # <new> contains a list of generators
    new := Reversed( Difference( Set(gens), [id] ) );
    # <seen> holds a list of words already seen
    seen := Union( new, [id] );

    # start putting <new> into <igs>
    while 0 < Length(new)  do
        old := Reversed(new);
        new := [];
        for u  in old  do
            uw := DepthOfPcElement( pcgs, u );

            # if <uw> has reached <chain>, we can ignore <u>
            if uw < chain  then
                up := [];
                repeat
                    if igs[uw] <> id  then
                        if chain <= uw+1  then
                            u := id;
                        else
                            u := u / igs[uw] ^ ( (
                                 LeadingExponentOfPcElement(pcgs,u)
                                 / LeadingExponentOfPcElement(pcgs,igs[uw]) )
                                 mod ro[uw] );
                        fi;
                    else
                        AddSet( seen, u );
                        wseen[uw] := true;
                        Add( up, u );
                        if chain <= uw+1  then
                            u := id;
                        else
                            u := u ^ ro[uw];
                        fi;
                    fi;
                    if u <> id  then
                        uw := DepthOfPcElement( pcgs, u );
                    fi;
                until u = id or chain <= uw;

                # add the commutators with the powers of <u>
                for u  in up  do
                    for x  in igs  do
                        if     x <> id 
                           and ( DepthOfPcElement(pcgs,x) + 1 < chain
                              or DepthOfPcElement(pcgs,u) + 1 < chain )
                        then
                            c := Comm( u, x );
                            if not c in seen  then
                                cw := DepthOfPcElement( pcgs, c );
                                wseen[cw] := true;
                                AddSet( new, c );
                                AddSet( seen, c );
                            fi;
                        fi;
                    od;
                od;

                # enter the generators <up> into <igs>
                for x  in up  do
                    igs[DepthOfPcElement(pcgs,x)] := x;
                od;

                # update the chain
                while 1 < chain and wseen[chain-1]  do
                    chain := chain-1;
                od;

                for i  in [ chain .. max ]  do
                    if igs[i] = id  then
                        igs[i] := pcgs[i];
                        for j  in [ 1 .. chain-1 ]  do
                            c := Comm( igs[i], igs[j] );
                            if not c in seen  then
                                AddSet( seen, c );
                                AddSet( new, c );
                                wseen[DepthOfPcElement(pcgs,c)] := true;
                            fi;
                        od;
                    fi;
                od;
            fi;
        od;
    od;

    # if <chain> has reached one, we have the whole group
    for i  in [ chain .. max ]  do
        igs[i] := pcgs[i];
    od;
    if chain = 1  then
        igs := List( [ 1 .. max ], x -> pcgs[x] );
    else
        igs := Filtered( igs, x -> x <> id );
    fi;
    return InducedPcgsByPcSequenceNC( pcgs, igs );

end );

#############################################################################
##
#M  InducedPcgsByGeneratorsWithImages( <pcgs>, <gens>, <imgs> )
##
InstallMethod( InducedPcgsByGeneratorsWithImages,
    true,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsCollection,
      IsCollection ],
    0,

function( pcgs, gens, imgs )
    local  ro, max, id, igs, chain, new, seen, old, u, uw, up, e, x, c, 
           cw, d, i, j;

    # do family check here to avoid problems with the empty list
    if not IsEmpty(gens)  then
        if not IsIdentical( FamilyObj(pcgs), FamilyObj(gens) )  then
            Error( "<pcgs> and <gens> have different families" );
        fi;
    fi;
    if Length( gens ) <> Length( imgs ) then
        Error( "<gens> and <imgs> must have equal length");
    fi;

    # catch the trivial case
    if Length( gens ) = 0 then
        return [ ];
    fi;

    # get relative orders and composition length
    ro  := RelativeOrders(pcgs);
    max := Length(pcgs);

    # get the identity
    id := [gens[1]^0, imgs[1]^0];

    # the induced generating sequence will be collected into <igs>
    igs := List( [ 1 .. max ], x -> id );

    # <chain> gives a chain of trailing weights
    chain := max+1;

    # <new> contains a list of generators and images
    new := List( Reversed([1..Length(gens)]), i -> [gens[i], imgs[i]]);

    # <seen> holds a list of words already seen
    seen := Union( Set( gens ), [id[1]] );

    # start putting <new> into <igs>
    while 0 < Length(new)  do
        old := Reversed( new );
        new := [];
        for u in old do
            uw := DepthOfPcElement( pcgs, u[1] );

            # if <uw> has reached <chain>, we can ignore <u>
            if uw < chain  then
                up := [];
                repeat
                    if igs[uw][1] <> id[1]  then
                        if chain <= uw+1  then
                            u := id;
                        else
                            e := LeadingExponentOfPcElement(pcgs,u[1])
                                / LeadingExponentOfPcElement(pcgs,igs[uw][1])
                                mod ro[uw];
                            u[1] := u[1] / igs[uw][1] ^ e;
                            u[2] := u[2] / igs[uw][2] ^ e;
                        fi;
                    else
                        AddSet( seen, u[1] );
                        Add( up, ShallowCopy( u ) );
                        if chain <= uw+1  then
                            u := id;
                        else
                            u[1] := u[1] ^ ro[uw];
                            u[2] := u[2] ^ ro[uw];
                        fi;
                    fi;
                    if u[1] <> id[1]  then
                        uw := DepthOfPcElement( pcgs, u[1] );
                    fi;
                until u[1] = id[1] or chain <= uw;

                # add the commutators with the powers of <u>
                for u in up do
                    for x in igs do
                        if x[1] <> id[1] 
                           and ( DepthOfPcElement(pcgs,x[1]) + 1 < chain
                              or DepthOfPcElement(pcgs,u[1]) + 1 < chain )
                        then
                            c := Comm( u[1], x[1] );
                            if not c in seen  then
                                cw := DepthOfPcElement( pcgs, c );
                                AddSet( new, [c, Comm( u[2], x[2] )] );
                                AddSet( seen, c );
                            fi;
                        fi;
                    od;
                od;

                # enter the generators <up> into <igs>
                for u in up do
                    d := DepthOfPcElement( pcgs, u[1] );
                    igs[d] := u;
                od;

                # update the chain
                while 1 < chain and igs[chain-1][1] <> id[1] do
                    chain := chain-1;
                od;

                for i  in [ chain .. max ]  do
                    for j  in [ 1 .. chain-1 ]  do
                        c := Comm( igs[i][1], igs[j][1] );
                        if not c in seen  then
                            AddSet( seen, c );
                            AddSet( new, [c, Comm( igs[i][2], igs[j][2] )] );
                        fi;
                    od;
                od;
            fi;
        od;
    od;

    # now return
    igs := Filtered( igs, x -> x <> id );
    igs := [List( igs, x -> x[1] ), List( igs, x -> x[2] )];
    igs[1] := InducedPcgsByPcSequenceNC( pcgs, igs[1] );
    return igs;
end );


#############################################################################
##
#M  InducedPcgsByGeneratorsNC( <pcgs>, <gen> )
##


#############################################################################
InstallMethod( InducedPcgsByGeneratorsNC,
    true,
    [ IsPcgs,
      IsList and IsEmpty ],
    0,

function( pcgs, gens )
    return InducedPcgsByPcSequenceNC( pcgs, [] );
end );


#############################################################################
InstallMethod( InducedPcgsByGeneratorsNC,
    function( p, l )
        return IsIdentical( ElementsFamily(p), ElementsFamily(l) );
    end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsCollection ],
    0,

function( pcgs, gens )
    return InducedPcgsByPcSequenceAndGenerators(
        pcgs, [], gens );
end );


#############################################################################
##
#M  InducedPcgsByGenerators( <pcgs>, <gen> )
##


#############################################################################
InstallMethod( InducedPcgsByGenerators,
    true,
    [ IsPcgs,
      IsList and IsEmpty ],
    0,

function( pcgs, gens )
    return InducedPcgsByPcSequenceNC( pcgs, [] );
end );


#############################################################################
InstallMethod( InducedPcgsByGenerators,
    function( p, l )
        return IsIdentical( ElementsFamily(p), ElementsFamily(l) );
    end,
    [ IsPcgs,
      IsCollection ],
    0,

function( pcgs, gens )
    #T 1996/09/26 fceller do some checks
    return InducedPcgsByGeneratorsNC( pcgs, gens );
end );


#############################################################################
##
#M  AsInducedPcgs( <parent>, <pcgs> )
##
InstallMethod( AsInducedPcgs,
    true,
    [ IsPcgs,
      IsEmpty and IsList ],
    0,

function( parent, pcgs )
    return InducedPcgsByGeneratorsNC( parent, [] );
end );


InstallMethod( AsInducedPcgs,
    IsIdentical,
    [ IsPcgs,
      IsHomogeneousList ],
    0,

function( parent, pcgs )
    return HomomorphicInducedPcgs( parent, pcgs );
end );


#############################################################################
##

#F  HOMOMORPHIC_IGS( <pcgs>, <list> )
##
HOMOMORPHIC_IGS := function( arg )
    local   pcgs,  list,  id,  pag,  g,  dg,  obj;

    pcgs := arg[1];
    list := arg[2];
    id   := OneOfPcgs(pcgs);
    pag  := [];
    if Length(arg) = 2  then
        for g  in Reversed(list)  do
            dg := DepthOfPcElement( pcgs, g );
            while g <> id  and IsBound(pag[dg])  do
                g  := ReducedPcElement( pcgs, g, pag[dg] );
                dg := DepthOfPcElement( pcgs, g );
            od;
            if g <> id  then
                pag[dg] := g;
            fi;
        od;
    elif IsFunction(arg[3])  then
        obj := arg[3];
        for g  in Reversed(list)  do
            g  := obj(g);
            dg := DepthOfPcElement( pcgs, g );
            while g <> id  and IsBound(pag[dg])  do
                g  := ReducedPcElement( pcgs, g, pag[dg] );
                dg := DepthOfPcElement( pcgs, g );
            od;
            if g <> id  then
                pag[dg] := g;
            fi;
        od;
    else
        obj := arg[3];
        for g  in Reversed(list)  do
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
    fi;
    return Compacted(pag);

end;


#############################################################################
##
#F  NORMALIZE_IGS( <pcgs>, <list> )
##
NORMALIZE_IGS := function( pcgs, list )
    local   ros,  dep,  i,  j,  exp;

    # normalize the leading exponents to one
    ros := RelativeOrders(pcgs);
    dep := List( list, x -> DepthOfPcElement( pcgs, x ) );
    for i  in [ 1 .. Length(list) ]  do
        list[i] := list[i] ^ ( 1 / LeadingExponentOfPcElement(pcgs,list[i])
                   mod ros[dep[i]] );
    od;

    # make zeros above the diagonale
    for i  in [ 1 .. Length(list) - 1 ]  do
        for j  in [ i+1 .. Length(list) ]  do
            exp := ExponentOfPcElement( pcgs, list[i], dep[j] );
            if exp <> 0  then
                list[i] := list[i] * list[j] ^ ( ros[j] - exp );
            fi;
        od;
    od;

end;


#############################################################################
##

#M  CanonicalPcgs( <igs> )
##
InstallMethod( CanonicalPcgs,
    "induced prime orders pcgs",
    true,
    [ IsInducedPcgs and IsPrimeOrdersPcgs ],
    0,

function( pcgs )
    local   pa,  ros,  cgs,  i,  exp,  j;

    # normalize leading exponent to one
    pa  := ParentPcgs(pcgs);
    ros := RelativeOrders(pcgs);
    cgs := [];
    for i  in [ 1 .. Length(pcgs) ]  do
        exp := LeadingExponentOfPcElement( pa, pcgs[i] );
        cgs[i] := pcgs[i] ^ (1/exp mod ros[i]);
    od;

    # make zeros above the diagonale
    for i  in [ 1 .. Length(cgs)-1 ]  do
        for j  in [ i+1 .. Length(cgs) ]  do
            exp := ExponentOfPcElement( pa, cgs[i], DepthOfPcElement(
                pa, cgs[j] ) );
            if exp <> 0  then
                cgs[i] := cgs[i] * cgs[j] ^ ( ros[j] - exp );
            fi;
        od;
    od;

    # construct the cgs
    cgs := InducedPcgsByPcSequenceNC( pa, cgs );
    SetIsCanonicalPcgs( cgs, true );

    # and return
    return cgs;

end );


#############################################################################
##
#M  CanonicalPcgs( <cgs> )
##
InstallMethod( CanonicalPcgs,
    "canonical pcgs",
    true,
    [ IsInducedPcgs and IsCanonicalPcgs ],
    SUM_FLAGS,
    x -> x );


#############################################################################
##
#M  HomomorphicCanonicalPcgs( <pcgs>, <imgs> )
##
InstallMethod( HomomorphicCanonicalPcgs,
    "pcgs, list",
    true,
    [ IsPcgs,
      IsList ],
    0,

function( pcgs, imgs )
    return CanonicalPcgs( HomomorphicInducedPcgs( pcgs, imgs ) );
end );


#############################################################################
##
#M  HomomorphicCanonicalPcgs( <pcgs>, <imgs>, <obj> )
##
InstallOtherMethod( HomomorphicCanonicalPcgs,
    "pcgs, list, object",
    true,
    [ IsPcgs,
      IsList,
      IsObject ],
    0,

function( pcgs, imgs, obj )
    return CanonicalPcgs( HomomorphicInducedPcgs( pcgs, imgs, obj ) );
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
InstallMethod( HomomorphicInducedPcgs,
    true,
    [ IsPcgs,
      IsEmpty and IsList ],
    0,

function( pcgs, imgs )
    return InducedPcgsByPcSequenceNC( pcgs, [] );
end );


InstallMethod( HomomorphicInducedPcgs,
    IsIdentical,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsHomogeneousList ],
    0,

function( pcgs, imgs )
    return InducedPcgsByPcSequenceNC(
        pcgs, 
        HOMOMORPHIC_IGS( pcgs, imgs ) );
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
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsHomogeneousList,
      IsFunction ],
    0,

function( pcgs, imgs, func )
    return InducedPcgsByPcSequenceNC(
        pcgs, 
        HOMOMORPHIC_IGS( pcgs, imgs, func ) );
end );


#############################################################################
##
#M  HomomorphicInducedPcgs( <pcgs>, <imgs>, <obj> )
##
InstallOtherMethod( HomomorphicInducedPcgs,
    true,
    [ IsPcgs,
      IsEmpty and IsList,
      IsObject ],
    0,

function( pcgs, imgs, obj )
    return InducedPcgsByPcSequenceNC( pcgs, [] );
end );


InstallOtherMethod( HomomorphicInducedPcgs,
    function(a,b,c) return IsIdentical(a,b); end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsHomogeneousList,
      IsObject ],
    0,

function( pcgs, imgs, obj )
    return InducedPcgsByPcSequenceNC(
        pcgs, 
        HOMOMORPHIC_IGS( pcgs, imgs, obj ) );
end );


#############################################################################
##

#M  ElementaryAbelianSubseries( <pcgs> )
##
InstallMethod( ElementaryAbelianSubseries,
    "generic method",
    true,
    [ IsPcgs ],
    0,

function( pcgs )
    local   id,  coms,  lStp,  eStp,  minSublist,  ros,  k,  l,  i,  
            z,  j;

    # try to construct an elementary abelian series through the agseries
    id := OneOfPcgs(pcgs);
    coms := List( [ 1 .. Length(pcgs) ],
              x -> List( [ 1 .. x-1 ],
                y -> DepthOfPcElement( pcgs, Comm(pcgs[x],pcgs[y])) ) );

    # make a list with step of the composition we can take
    lStp := Length(pcgs) + 1;
    eStp := [ lStp ];

    # as we do not want to generate a mess of sublist:
    minSublist := function( list, upto )
        local min, i;
        if upto = 0  then return 1;  fi;
        min := list[ 1 ];
        for i  in [ 2 .. upto ]  do
            if min > list[ i ]  then min := list[ i ];  fi;
        od;
        return min;
    end;

    # if <lStp> reaches 1, we are can stop
    ros := RelativeOrders(pcgs);
    repeat

        # look for a normal composition subgroup
        k := lStp;
        l := k - 1;
        repeat
            k := k - 1;
            l := Minimum( l, minSublist( coms[k], k-1 ) );
        until l = k;

        # we have found a normal composition subgroup
        for i  in [ k .. lStp-1 ]  do
            z := pcgs[i] ^ ros[i];
            if z <> id and DepthOfPcElement(pcgs,z) < lStp  then
                return fail;
            fi;
        od;
        for i  in [ k .. lStp-2 ]  do
            for j  in [ i+1 .. lStp-1 ]  do
                if coms[j][i] < lStp  then
                    return fail;
                fi;
            od;
        od;

        # ok, we have an elementary normal step
        Add( eStp, k );
        lStp := k;
    until k = 1;

    # return the list found
    eStp := List( Reversed(eStp), x -> pcgs{[x..Length(pcgs)]} );
    l := [];
    for i  in eStp  do
        k := InducedPcgsByPcSequenceNC( pcgs, i );
        SetIsCanonicalPcgs( k, true );
        Add( l, k );
    od;
    return l;

end );


#############################################################################
##
#M  IntersectionSumPcgs( <parent-pcgs>, <tail-pcgs>, <u> )
##
InstallMethod( IntersectionSumPcgs,
    "prime orders pcgs, tail-pcgs, list",
    function(a,b,c) return IsIdentical(a,b) and IsIdentical(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsInducedPcgs and IsTailInducedPcgsRep,
      IsList ],
    0,

function( pcgs, n, u )
    local   first,  sum,  int,  pos,  len;

    # the parent must match
    if pcgs <> ParentPcgs(n)  then
        TryNextMethod();
    fi;

    # get first depth of <n>
    first := n!.tailStart;

    # smaller depth elems of <u> yield the sum, the other the intersection
    sum := [];
    int := [];
    pos := 1;
    len := Length(u);
    while pos <= len and DepthOfPcElement(pcgs,u[pos]) < first  do
        Add( sum, u[pos] );
        pos := pos+1;
    od;
    while pos <= len  do
        Add( int, u[pos] );
        pos := pos+1;
    od;
    Append( sum, n );
   
    sum := InducedPcgsByPcSequenceNC( pcgs, sum );
    int := InducedPcgsByPcSequenceNC( pcgs, int );
    return rec( sum := sum, intersection := int );

end );


#############################################################################
##
#M  NormalIntersectionPcgs( <parent-pcgs>, <tail-pcgs>, <u> )
##
InstallMethod( NormalIntersectionPcgs,
    "prime orders pcgs, tail-pcgs, list",
    function(a,b,c) return IsIdentical(a,b) and IsIdentical(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsInducedPcgs and IsTailInducedPcgsRep,
      IsList ],
    0,

function( pcgs, n, u )
    local   first,  len,  pos;

    # the parent must match
    if pcgs <> ParentPcgs(n)  then
        TryNextMethod();
    fi;

    # if <u> is empty return it
    len := Length(u);
    if 0 = len  then
        if IsInducedPcgs(u) and ParentPcgs(u) = pcgs  then
            return u;
        else
            return InducedPcgsByPcSequenceNC( pcgs, ShallowCopy(u) );
        fi;
    fi;

    # get first depth of <n> (tail induced is never trivial!)
    first := n!.tailStart;

    # smaller depth elems of <u> yield the sum, the other the intersection
    pos := 1;
    while pos <= len and DepthOfPcElement(pcgs,u[pos]) < first  do
        pos := pos+1;
    od;
    return InducedPcgsByPcSequenceNC( pcgs, u{[pos..len]} );

end );


#############################################################################
##
#M  NormalIntersectionPcgs( <parent-pcgs>, <tail-pcgs>, <induced-pcgs> )
##
InstallMethod( NormalIntersectionPcgs,
    "prime orders pcgs, tail-pcgs, induced-pcgs",
    function(a,b,c) return IsIdentical(a,b) and IsIdentical(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsInducedPcgs and IsTailInducedPcgsRep,
      IsInducedPcgs and IsInducedPcgsRep ],
    0,

function( pcgs, n, u )
    local   len,  first,  pos,  dep;

    # the parent must match
    if pcgs <> ParentPcgs(n) or pcgs <> ParentPcgs(u)  then
        TryNextMethod();
    fi;

    # if <u> is empty return it
    len := Length(u);
    if 0 = len  then
        return u;
    fi;

    # get first depth of <n> (tail induced is never trivial)
    first := n!.tailStart;

    # smaller depth elems of <u> yield the sum, the other the intersection
    pos := 1;
    dep := u!.depthsInParent;
    while pos <= len and dep[pos] < first  do
        pos := pos+1;
    od;
    return InducedPcgsByPcSequenceNC( pcgs, u{[pos..len]} );

end );


#############################################################################
##

#M  CanonicalPcElement( <igs>, <elm> )
##
CANONICAL_PC_ELEMENT := function( pcgs, elm )
    local   pa,  map,  ros,  tal,  g,  d,  ll,  lr;

    pa  := ParentPcgs(pcgs);
    map := pcgs!.depthMapFromParent;
    ros := RelativeOrders(pa);
    tal := pcgs!.tailStart;
    for g  in pcgs  do
        d := DepthOfPcElement( pa, g );
        if tal <= d  then
            return HeadPcElementByNumber( pa, elm, tal );
        fi;
        ll := ExponentOfPcElement( pa, elm, d );
        if ll <> 0  then
            lr  := LeadingExponentOfPcElement( pa, g );
            elm := elm / g^( ll / lr mod ros[d] );
        fi;
    od;
    if elm = OneOfPcgs(pa)  then
        return elm;
    else
        d := DepthOfPcElement( pa, elm );
        return elm ^ (1/LeadingExponentOfPcElement(pa,elm) mod ros[d]);
    fi;
end;


InstallMethod( CanonicalPcElement,
    "generic method",
    IsCollsElms,
    [ IsInducedPcgs and IsInducedPcgsRep and IsPrimeOrdersPcgs,
      IsObject ],
    0,
    CANONICAL_PC_ELEMENT );


#############################################################################
##
#M  DepthOfPcElement( <igs>, <elm> )
##
InstallMethod( DepthOfPcElement,
    "induced pcgs",
    IsCollsElms,
    [ IsInducedPcgs and IsInducedPcgsRep,
      IsObject ],
    0,

function( pcgs, elm )
    return pcgs!.depthMapFromParent[DepthOfPcElement(ParentPcgs(pcgs),elm)];
end );


#############################################################################
##
#M  ExponentOfPcElement( <igs>, <elm>, <pos> )
##
InstallMethod( ExponentOfPcElement,
    "induced pcgs",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsInducedPcgs and IsInducedPcgsRep and IsPrimeOrdersPcgs,
      IsObject,
      IsInt and IsPosRat ],
    0,

function( pcgs, elm, pos )
    local   pa,  map,  id,  exp,  ros,  d,  ll,  lr;

    pa  := ParentPcgs(pcgs);
    map := pcgs!.depthMapFromParent;
    id  := OneOfPcgs(pcgs);
    exp := List( pcgs, x -> 0 );
    ros := RelativeOrders(pa);
    while elm <> id  do
        d := DepthOfPcElement( pa, elm );
        if not IsBound(map[d])  then
            Error( "<elm> lies not in group defined by <pcgs>" );
        fi;
        ll := LeadingExponentOfPcElement( pa, elm );
        lr := LeadingExponentOfPcElement( pa, pcgs[map[d]] );
        exp := ll / lr mod ros[d];
        if map[d] = pos  then
            return exp;
        else
            elm := LeftQuotient( pcgs[map[d]]^exp, elm );
        fi;
    od;
    return 0;
end );


#############################################################################
##
#M  ExponentsOfPcElement( <igs>, <elm> )
##
InstallMethod( ExponentsOfPcElement,
    "induced pcgs",
    IsCollsElms,
    [ IsInducedPcgs and IsInducedPcgsRep and IsPrimeOrdersPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    local   pa,  map,  id,  exp,  ros,  d,  ll,  lr;

    pa  := ParentPcgs(pcgs);
    map := pcgs!.depthMapFromParent;
    id  := OneOfPcgs(pcgs);
    exp := List( pcgs, x -> 0 );
    ros := RelativeOrders(pa);
    while elm <> id  do
        d := DepthOfPcElement( pa, elm );
        if not IsBound(map[d])  then
            Error( "<elm> lies not in group defined by <pcgs>" );
        fi;
        ll := LeadingExponentOfPcElement( pa, elm );
        lr := LeadingExponentOfPcElement( pa, pcgs[map[d]] );
        exp[map[d]] := ll / lr mod ros[d];
        elm := LeftQuotient( pcgs[map[d]]^exp[map[d]], elm );
    od;
    return exp;
end );


#############################################################################
##
#M  SiftedPcElement( <igs>, <elm> )
##
InstallMethod( SiftedPcElement,
    IsCollsElms,
    [ IsInducedPcgs and IsInducedPcgsRep and IsPrimeOrdersPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    local   pa,  map,  id,  d;

    pa  := ParentPcgs(pcgs);
    map := pcgs!.depthMapFromParent;
    id  := OneOfPcgs(pcgs);
    while elm <> id  do
        d := DepthOfPcElement( pa, elm );
        if not IsBound(map[d])  then
            return elm;
        fi;
        elm := ReducedPcElement( pa, elm, pcgs[map[d]] );
    od;
    return elm;
end );


#############################################################################
##

#M  ExponentsOfPcElement( <sub-igs>, <elm> )
##
InstallMethod( ExponentsOfPcElement,
    "subset of induced pcgs",
    IsCollsElms,
    [ IsPcgs and IsSubsetInducedPcgsRep and IsPrimeOrdersPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    return ExponentsOfPcElement(ParentPcgs(pcgs), elm){pcgs!.depthsInParent};
end );


#############################################################################
##
#M  LeadingExponentOfPcElement( <sub-igs>, <elm> )
##
InstallMethod( LeadingExponentOfPcElement,
    "subset induced pcgs",
    IsCollsElms,
    [ IsPcgs and IsSubsetInducedPcgsRep and IsPrimeOrdersPcgs,
      IsObject ],
    0,

function( pcgs, elm )
    return LeadingExponentOfPcElement( ParentPcgs(pcgs), elm );
end );


#############################################################################
##

#M  ExtendedPcgs( <pcgs>, <img> )
##
InstallMethod( ExtendedPcgs,
    "induced pcgs",
    IsIdentical,
    [ IsInducedPcgs,
      IsList and IsMultiplicativeElementWithInverseCollection ],
    0,

function( kern, img )
    return InducedPcgsByPcSequenceAndGenerators(
        ParentPcgs(kern), kern, img );
end );


#############################################################################
##

#E  pcgsind.gi 	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
