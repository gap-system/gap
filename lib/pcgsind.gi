#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This  file  contains  the operations   for  induced polycyclic  generating
##  systems.
##


#############################################################################
##
#R  IsInducedPcgsRep
##
DeclareRepresentation(
    "IsInducedPcgsRep",
    IsPcgsDefaultRep, [ "depthsInParent", "depthMapFromParent" ] );


#############################################################################
##
#R  IsSubsetInducedPcgsRep
##
DeclareRepresentation(
    "IsSubsetInducedPcgsRep",
    IsInducedPcgsRep, ["parentZeroVector"] );


#############################################################################
##
#R  IsTailInducedPcgsRep
##
DeclareRepresentation(
    "IsTailInducedPcgsRep",
    IsSubsetInducedPcgsRep, [] );


#############################################################################
##
#M  InducedPcgsByPcSequenceNC( <pcgs>, <empty-list> )
##
InstallMethod( InducedPcgsByPcSequenceNC, "pcgs, empty list",
    true, [ IsPcgs, IsList and IsEmpty ], 0,
function( pcgs, pcs )
    local  efam,  igs;

    # get family
    efam := FamilyObj( OneOfPcgs( pcgs ) );

    # construct a pcgs from <pcs>
    igs := PcgsByPcSequenceCons(
               IsPcgsDefaultRep,
               IsPcgs and IsInducedPcgs and IsInducedPcgsRep,
               efam,
               pcs,[] );

    # we know the relative orders
    SetIsPrimeOrdersPcgs( igs, true );
    #AH implied by true method: SetIsFiniteOrdersPcgs( igs, true );
    SetRelativeOrders( igs, [] );

    # store the parent
    SetParentPcgs( igs, pcgs );

    # check for special pcgs
    if HasIsSpecialPcgs( pcgs ) and IsSpecialPcgs( pcgs ) then
        SetIsInducedPcgsWrtSpecialPcgs( igs, true );
    fi;

    # store depthMap
    igs!.depthMapFromParent := [];
    igs!.depthMapFromParent[Length(pcgs)+1] := 1;
    igs!.depthsInParent := [];
    igs!.tailStart := Length(pcgs)+1;
    SetLeadCoeffsIGS(igs,[]);

    # and return
    return igs;

end );

InstallOtherMethod( InducedPcgsByPcSequenceNC, "pcgs, empty list,depths",
    true, [ IsPcgs, IsList and IsEmpty,IsList ], 0,
function( pcgs, pcs,dep )
  return InducedPcgsByPcSequenceNC(pcgs,pcs);
end);


#############################################################################
##
#M  InducedPcgsByPcSequenceNC( <pcgs>, <pcs> )
##
BindGlobal("DoInducedPcgsByPcSequenceNC",
function(arg)
local   pcgs,pcs,depths,efam,  filter,  j,  l,  i,  m,  d,  igs,  tmp,
        susef,attl, igsdepthMapFromParent,igsdepthsInParent;

    pcgs:=arg[1];
    pcs:=arg[2];
    if Length(arg)>2 then
      depths:=arg[3];
    else
      depths:=fail;
    fi;
    # get the elements family
    efam := FamilyObj( OneOfPcgs( pcgs ) );

    # check which filter to use
    filter := IsPcgs and IsInducedPcgsRep and IsInducedPcgs;
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
        susef:=true;
        filter := filter and IsCanonicalPcgs and IsSubsetInducedPcgsRep;
        if 0 < Length(pcgs) and pcgs[Length(pcgs)-Length(pcs)+1]=pcs[1]  then
            filter := filter and IsTailInducedPcgsRep;
        fi;
    else
      susef:=false;
    fi;
    if HasIsFamilyPcgs(pcgs) and IsFamilyPcgs(pcgs)  then
        filter := filter and IsParentPcgsFamilyPcgs;
    fi;

    if HasIsPrimeOrdersPcgs(pcgs) and IsPrimeOrdersPcgs(pcgs)  then
        filter := filter and HasIsPrimeOrdersPcgs and IsPrimeOrdersPcgs
                         and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
    elif HasIsFiniteOrdersPcgs(pcgs) and IsFiniteOrdersPcgs(pcgs)  then
        filter := filter and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
    fi;

    # store the parent
    attl:=[ParentPcgs,pcgs];
    filter:=filter and HasParentPcgs;

    # check for special pcgs
    if HasIsSpecialPcgs( pcgs ) and IsSpecialPcgs( pcgs ) then
      filter:=filter and IsInducedPcgsWrtSpecialPcgs;
    fi;

    # construct a pcgs from <pcs>
    igs := PcgsByPcSequenceCons(
               IsPcgsDefaultRep,
               filter,
               efam,
               pcs,attl );

    # store other useful information
    igsdepthMapFromParent := [];
    igsdepthsInParent := [];
    if susef then
        igsdepthsInParent := d;
        for i  in [ 1 .. Length(pcs) ]  do
            igsdepthMapFromParent[d[i]] := i;
        od;
    else
      for i  in [ 1 .. Length(pcs) ]  do
        if depths=fail then
          tmp := DepthOfPcElement( pcgs, pcs[i] );
        else
          tmp:=depths[i];
        fi;
        igsdepthsInParent[i] := tmp;
        igsdepthMapFromParent[tmp] := i;
      od;
    fi;
    igsdepthMapFromParent[Length(pcgs)+1] := Length(pcs)+1;

    # the depth must be compatible with the parent
    tmp := 0;
    for i  in [ 1 .. Length(igsdepthsInParent) ]  do
        if tmp >= igsdepthsInParent[i]  then
            Error( "depths are not compatible with parent pcgs" );
        fi;
        tmp := igsdepthsInParent[i];
    od;

    # if we know the relative orders use them
    if HasRelativeOrders(pcgs)  then
      tmp := RelativeOrders(pcgs);
      tmp := tmp{igsdepthsInParent};
      SetRelativeOrders(igs,tmp);
      #Add(attl,RelativeOrders);
      #Add(attl,tmp);
      #filter:=filter and HasRelativeOrders;
    fi;

    igs!.depthMapFromParent := igsdepthMapFromParent;
    igs!.depthsInParent := igsdepthsInParent;
    if susef then
      igs!.parentZeroVector:= pcgs!.zeroVector;
    fi;

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

    # and return
    return igs;

end );

InstallMethod( InducedPcgsByPcSequenceNC, "pcgs, homogeneous list",
    IsIdenticalObj, [ IsPcgs, IsCollection and IsHomogeneousList ], 0,
    DoInducedPcgsByPcSequenceNC);

InstallOtherMethod(InducedPcgsByPcSequenceNC,"pcgs, homogeneous list, depths",
    IsFamFamX, [ IsPcgs, IsCollection and IsHomogeneousList,
      IsList ], 0,
    DoInducedPcgsByPcSequenceNC);

#############################################################################
##
#M  LeadCoeffsIGS( <igs> )
##
InstallMethod(LeadCoeffsIGS,"generic",true,
  [IsInducedPcgs and IsInducedPcgsRep and IsPrimeOrdersPcgs],0,
function(igs)
local i,lc;
  lc := [];
  for i in [1..Length(ParentPcgs(igs))] do
    if IsBound(igs!.depthMapFromParent[i]) then
      lc[i] := LeadingExponentOfPcElement(ParentPcgs(igs),
                                      igs[igs!.depthMapFromParent[i]]);
    fi;
  od;
  return lc;
end);

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
        if not IsIdenticalObj( FamilyObj(pcgs), FamilyObj(sub) )  then
            Error( "<pcgs> and <gens> have different families" );
        fi;
    fi;
    if not IsEmpty(gens)  then
        if not IsIdenticalObj( FamilyObj(pcgs), FamilyObj(gens) )  then
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
    pcgs:=InducedPcgsByPcSequenceNC( pcgs, igs );
    return pcgs;

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
           d, i, j, f,nonab;

    # do family check here to avoid problems with the empty list
    if not IsIdenticalObj( FamilyObj(pcgs), FamilyObj(gens) )  then
        Error( "<pcgs> and <gens> have different families" );
    fi;
    if Length( gens ) <> Length( imgs ) then
        Error( "<gens> and <imgs> must have equal length");
    fi;

    # get the trivial case first
    if gens = AsList( pcgs ) then return [pcgs, imgs]; fi;

    #catch special case: abelian
    f:=ValueOption("abeliandomain");
    if not (f in [true,false]) then
      f:=IsAbelian(Group(pcgs,OneOfPcgs(pcgs)));
    fi;
    nonab:=not f;

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
    new := List( [1..Length(gens)], i -> [gens[i], imgs[i]]);
    f   := function( x, y ) return DepthOfPcElement( pcgs, x[1] )
                                   < DepthOfPcElement( pcgs, y[1] ); end;
    Sort( new, f );

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
                        if nonab and x[1] <> id[1]
                           and ( DepthOfPcElement(pcgs,x[1]) + 1 < chain
                              or DepthOfPcElement(pcgs,u[1]) + 1 < chain )
                        then
                            c := Comm( u[1], x[1] );
                            if not c in seen  then
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

                if nonab then
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
            fi;
        od;
    od;

    # now return
    igs := Filtered( igs, x -> x <> id );
    igs := [List( igs, x -> x[1] ), List( igs, x -> x[2] )];
    igs[1] := InducedPcgsByPcSequenceNC( pcgs, igs[1] );
    return igs;
end );

InstallOtherMethod( InducedPcgsByGeneratorsWithImages,
    true,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsList and IsEmpty,
      IsList and IsEmpty ],
    0,

function( pcgs, gens, imgs )
    local igs;
    igs := InducedPcgsByPcSequenceNC( pcgs, gens );
    return [igs, imgs];
end );

#############################################################################
##
#M  CanonicalPcgsByGeneratorsWithImages( <pcgs>, <gens>, <imgs> )
##
InstallMethod( CanonicalPcgsByGeneratorsWithImages,
    true,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsCollection,
      IsCollection ],
    0,

function( pcgs, gens, imgs )
    local new, ros, cgs, img, i, exp, j;

    # in most cases we are mapping the pcgs itself
    if gens=pcgs then
      # nothing needs to be done
      return [pcgs,imgs];
    fi;

    # get the induced one first
    new := InducedPcgsByGeneratorsWithImages( pcgs, gens, imgs );

    # normalize leading exponents
    ros := RelativeOrders(new[1]);
    cgs := [];
    img := [];
    for i  in [ 1 .. Length(new[1]) ]  do
        exp := LeadingExponentOfPcElement( pcgs, new[1][i] );
        cgs[i] := new[1][i] ^ (1/exp mod ros[i]);
        img[i] := new[2][i] ^ (1/exp mod ros[i]);
    od;

    # make zeros above the diagonal
    for i  in [ 1 .. Length(cgs)-1 ]  do
        for j  in [ i+1 .. Length(cgs) ]  do
            exp := ExponentOfPcElement( pcgs, cgs[i], DepthOfPcElement(
                pcgs, cgs[j] ) );
            if exp <> 0  then
                cgs[i] := cgs[i] * cgs[j] ^ ( ros[j] - exp );
                img[i] := img[i] * img[j] ^ ( ros[j] - exp );
            fi;
        od;
    od;

    # construct the cgs
    cgs := InducedPcgsByPcSequenceNC( pcgs, cgs );
    SetIsCanonicalPcgs( cgs, true );

    # and return
    return [cgs, img];
end );

InstallOtherMethod( CanonicalPcgsByGeneratorsWithImages,
    true,
#   [ IsPcgs and IsPrimeOrdersPcgs,
#     IsList and IsEmpty,
#     IsList and IsEmpty ],
#   0,
#T this caused problems when one of the lists did not know that it is empty
#T (this happened for example if the list `gens' is a pcgs)
    [ IsPcgs, IsList, IsList ], 0,
function( pcgs, gens, imgs )
    local igs;

    if IsPrimeOrdersPcgs( pcgs ) and IsEmpty( gens ) and IsEmpty( imgs ) then
      igs := InducedPcgsByPcSequenceNC( pcgs, gens );
      return [igs, imgs];
    else
      TryNextMethod();
    fi;
end );


#############################################################################
##
#M  InducedPcgsByGeneratorsNC( <pcgs>, <gen> )
##


#############################################################################
InstallOtherMethod( InducedPcgsByGeneratorsNC,"pcgs, empty list",
    true, [ IsPcgs, IsList and IsEmpty ], 0,
function( pcgs, gens )
    return InducedPcgsByPcSequenceNC( pcgs, [] );
end );


#############################################################################
InstallMethod( InducedPcgsByGeneratorsNC,"prime order pcgs, collection",
    function( p, l )
        return IsIdenticalObj( ElementsFamily(p), ElementsFamily(l) );
    end,
    [ IsPcgs and IsPrimeOrdersPcgs, IsCollection ], 0,
function( pcgs, gens )
local l;
  # test the (apparently frequent) case of generators that are a subset of
  # the pcgs. This test requires only to compare elements, so it should be
  # comparatively cheap. AH
  if IsSubset(pcgs!.pcSequence,gens) then
    l:=List(gens,i->Position(pcgs!.pcSequence,i));
    # ordered, duplicate-free?
    if l=Set(l) and IsSubset(l,[l[1]..Length(pcgs!.pcSequence)]) then
      return InducedPcgsByPcSequenceNC( pcgs, gens );
    fi;
  fi;
  return InducedPcgsByPcSequenceAndGenerators( pcgs, [], gens );
end );

RedispatchOnCondition( InducedPcgsByGeneratorsNC, true,
    [ IsPcgs,IsCollection ], [ IsPrimeOrdersPcgs ], 0 );



#############################################################################
##
#M  InducedPcgsByGenerators( <pcgs>, <gen> )
##


#############################################################################
InstallOtherMethod( InducedPcgsByGenerators, true,
    [ IsPcgs, IsList and IsEmpty ], 0,

function( pcgs, gens )
    return InducedPcgsByPcSequenceNC( pcgs, [] );
end );


#############################################################################
InstallMethod( InducedPcgsByGenerators,"pcgs, collection",
    function( p, l )
        return IsIdenticalObj( ElementsFamily(p), ElementsFamily(l) );
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
    IsIdenticalObj,
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
BindGlobal( "HOMOMORPHIC_IGS", function( arg )
    local   pcgs,  list,  id,  pag,  g,  dg,  obj;

    Info(InfoWarning,1,"HOMOMORPHIC_IGS is potentially wrong! Do not use!");

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

end );


#############################################################################
##
#F  NORMALIZE_IGS( <pcgs>, <list> )
##
InstallGlobalFunction(NORMALIZE_IGS,function( pcgs, list )
    local   ros,  dep,  i,  j,  exp;

    Info(InfoWarning,1,"NORMALIZE_IGS is potentially wrong! Do not use!");

    # normalize the leading exponents to one
    ros := RelativeOrders(pcgs);
    dep := List( list, x -> DepthOfPcElement( pcgs, x ) );
    for i  in [ 1 .. Length(list) ]  do
        list[i] := list[i] ^ ( 1 / LeadingExponentOfPcElement(pcgs,list[i])
                   mod ros[dep[i]] );
    od;

    # make zeros above the diagonal
    for i  in [ 1 .. Length(list) - 1 ]  do
        for j  in [ i+1 .. Length(list) ]  do
            exp := ExponentOfPcElement( pcgs, list[i], dep[j] );
            if exp <> 0  then
                list[i] := list[i] * list[j] ^ ( ros[j] - exp );
            fi;
        od;
    od;

end);


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

    # make zeros above the diagonal
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

RedispatchOnCondition( CanonicalPcgs, true,
    [ IsInducedPcgs],[IsPrimeOrdersPcgs ], 0 );


#############################################################################
##
#M  CanonicalPcgs( <cgs> )
##
InstallOtherMethod( CanonicalPcgs,"of a canonical pcgs",
    true, [ IsCanonicalPcgs ],
    SUM_FLAGS, # the best we can do
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
    IsIdenticalObj,
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
    function(a,b,c) return IsIdenticalObj(a,b); end,
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
    function(a,b,c) return IsIdenticalObj(a,b); end,
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
    "prime orders pcgs, tail-pcgs, list",IsFamFamFam,
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
    "prime orders pcgs, tail-pcgs, list",IsFamFamFam,
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
    "prime orders pcgs, tail-pcgs, induced-pcgs",IsFamFamFam,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsInducedPcgs and IsTailInducedPcgsRep,
      IsInducedPcgs and IsInducedPcgsRep ],
    0,

function( pcgs, n, u )
    local   len,  first,  pos,  dep;

    # the parent must match
    if pcgs <> ParentPcgs(n) or pcgs <> ParentPcgs(u)
      # and the depthsInParent given
      or not IsBound(u!.depthsInParent) then
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
BindGlobal( "CANONICAL_PC_ELEMENT", function( pcgs, elm )
    local   pa,  ros,  tal,  g,  d,  ll,  lr;

    # catch empty case
    if IsEmpty(pcgs) then
      return elm;
    fi;
    pa  := ParentPcgs(pcgs);
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
end );


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
      IsPosInt ],
    0,

function( pcgs, elm, pos )
    local   pa,  map,  id,  exp,  ros,  d,  ll,  lr,lc;

    pa  := ParentPcgs(pcgs);
    map := pcgs!.depthMapFromParent;
    lc  := LeadCoeffsIGS(pcgs);
    id  := OneOfPcgs(pcgs);
    exp := ListWithIdenticalEntries(Length( pcgs),0);
    ros := RelativeOrders(pa);
    while elm <> id  do
        d := DepthOfPcElement( pa, elm );
        if not IsBound(map[d])  then
            Error( "<elm> lies not in group defined by <pcgs>" );
        elif map[d]>Length(pcgs) then
          return exp;
        fi;
        ll := LeadingExponentOfPcElement( pa, elm );
        #lr := LeadingExponentOfPcElement( pa, pcgs[map[d]] );
        lr := lc[d];
        exp := ll / lr mod ros[d];
        if map[d] = pos  then
            return exp;
        else
            #elm := LeftQuotient( pcgs[map[d]]^exp, elm );
            elm := LeftQuotientPowerPcgsElement( pcgs,map[d],exp, elm );
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
    local   pa,  map,  id,  exp,  ros,  d,  ll,  lr,lc;

    pa  := ParentPcgs(pcgs);
    map := pcgs!.depthMapFromParent;
    lc  := LeadCoeffsIGS(pcgs);
    id  := OneOfPcgs(pcgs);
    exp := ListWithIdenticalEntries(Length( pcgs),0);
    ros := RelativeOrders(pa);
    while elm <> id  do
        d := DepthOfPcElement( pa, elm );
        if not IsBound(map[d])  then
            Error( "<elm> lies not in group defined by <pcgs>" );
        elif map[d]>Length(pcgs) then
          return exp;
        fi;
        ll := LeadingExponentOfPcElement( pa, elm );
        #lr := LeadingExponentOfPcElement( pa, pcgs[map[d]] );
        lr := lc[d];
        exp[map[d]] := ll / lr mod ros[d];
        #elm := LeftQuotient( pcgs[map[d]]^exp[map[d]], elm );
        elm := LeftQuotientPowerPcgsElement( pcgs,map[d],exp[map[d]], elm );
    od;
    return exp;
end );

#############################################################################
##
#M  ExponentsOfPcElement( <igs>, <elm>, <subrange> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "induced pcgs, subrange",
    IsCollsElmsX,
    [ IsInducedPcgs and IsInducedPcgsRep and IsPrimeOrdersPcgs,
      IsObject,IsList ], 0,

function( pcgs, elm,range )
    local   pa,  map,  id,  exp,  ros,  d,  ll,  lr,lc,max;

    if not IsSSortedList(range) then
      TryNextMethod(); # the range may be unsorted or contain duplicates,
      # then we would have to be more clever.
    fi;
    if Length(range)=0 then return [];fi;
    max:=Maximum(range);

    pa  := ParentPcgs(pcgs);
    map := pcgs!.depthMapFromParent;
    lc  := LeadCoeffsIGS(pcgs);
    id  := OneOfPcgs(pcgs);
    exp := ListWithIdenticalEntries(Length( pcgs),0);
    ros := RelativeOrders(pa);
    while elm <> id  do
        d := DepthOfPcElement( pa, elm );
        if not IsBound(map[d])  then
          Error( "<elm> lies not in group defined by <pcgs>" );
        elif map[d]>max then
          # we have reached the maximum of the range we asked for. Thus we
          # can stop calculating exponents now, all further exponents would
          # be discarded anyhow
          elm:=id;
        else
          ll := LeadingExponentOfPcElement( pa, elm );
          #lr := LeadingExponentOfPcElement( pa, pcgs[map[d]] );
          lr := lc[d];
          exp[map[d]] := ll / lr mod ros[d];
          #elm := LeftQuotient( pcgs[map[d]]^exp[map[d]], elm );
          elm := LeftQuotientPowerPcgsElement( pcgs,map[d],exp[map[d]], elm );
        fi;
    od;
    exp:=exp{range};
    return exp;
end );

#############################################################################
##
#M  SiftedPcElement( <igs>, <elm> )
##
InstallMethod( SiftedPcElement,"for induced pcgs", IsCollsElms,
    [ IsInducedPcgs and IsInducedPcgsRep and IsPrimeOrdersPcgs,
      IsObject ], 0,
function( pcgs, elm )
local   pa, l, map,  d,lc,ro,tail;

  pa  := ParentPcgs(pcgs);
  l:=Length(pa);
  d := DepthOfPcElement( pa, elm );
  if d>l then
    return elm; # no depth in parent => elm is one
  fi;

  map := pcgs!.depthMapFromParent;
  lc  := LeadCoeffsIGS(pcgs);
  ro  := RelativeOrders(pa);

  # stop level for tails
  if IsTailInducedPcgsRep(pcgs) then
    tail:=pcgs!.tailStart;
  else
    tail:=infinity;
  fi;

  while d<=l do
    if not IsBound(map[d])  then
        return elm;
    elif d>=tail then
      # from this level on every level in the parent is also in the pcgs,
      # so we can clean out completely
      return OneOfPcgs(pcgs);
    fi;
    elm := LeftQuotientPowerPcgsElement(pcgs,map[d],
                  (LeadingExponentOfPcElement(pa,elm)/lc[d] mod ro[d])
            ,elm);
    d := DepthOfPcElement( pa, elm );
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
      IsObject ], 0,
function( pcgs, elm )
    return ExponentsOfPcElement(ParentPcgs(pcgs),elm,pcgs!.depthsInParent);
end );


#############################################################################
##
#M  ExponentsOfPcElement( <sub-igs>, <elm>, <subrange> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "subset of induced pcgs, subrange",
    IsCollsElmsX,
    [ IsPcgs and IsSubsetInducedPcgsRep and IsPrimeOrdersPcgs,
      IsObject,IsList ], 0,
function( pcgs, elm,range )
    return
      ExponentsOfPcElement(ParentPcgs(pcgs),elm,pcgs!.depthsInParent{range});
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
InstallMethod( ExtendedPcgs, "induced pcgs", IsIdenticalObj,
    [ IsInducedPcgs, IsList ], 0,
function( kern, img )
local p;
  p:=ParentPcgs(kern);
  img:=Concatenation(img,kern);
  return InducedPcgsByPcSequenceNC( p, img );
end );


#############################################################################
##
#F  CorrespondingGeneratorsByModuloPcgs( <mpcgs>, <imgs> )
##
##  computes a list of elements in the span of <imgs> that form a cgs with
##  respect to <mpcgs> (The calculation of induced generating sets is not
##  possible for some modulo pcgs).
InstallGlobalFunction( CorrespondingGeneratorsByModuloPcgs,
    function(pcgs,l)
local e,s,d,o,j,bj,bjo,ro,max,id,seen,wseen,igs,chain,new,old,u,up,uw,cw,x,c;

  # start with a non-commutative Gauss

  # get relative orders and composition length
  ro  := RelativeOrders(pcgs);
  max := Length(pcgs);

  # get the identity
  id := OneOfPcgs(pcgs);

  # and keep a list of seen weights
  wseen := BlistList( [ 1 .. max ], [] );

  # the induced generating sequence will be collected into <igs>
  igs := List( [ 1 .. max ], x -> id );

  # <chain> gives a chain of trailing weights
  chain := max+1;

  # <new> contains a list of generators
  new := Reversed( Difference( Set(l), [id] ) );
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
#T we may not replace by elements of pcgs because that might change the
#T group.
#           if chain <= uw+1  then
#             # all powers would be cancelled out
#             u := id;
#           else
              u:=u/igs[uw]^((LeadingExponentOfPcElement(pcgs,u)
                             / LeadingExponentOfPcElement(pcgs,igs[uw]))
                      mod ro[uw] );
#           fi;
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
          for x in igs  do
            if x<>id and ( DepthOfPcElement(pcgs,x) + 1 < chain
                        or DepthOfPcElement(pcgs,u) + 1 < chain ) then
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

#T we may not replace by elements of pcgs because that might change the
#T group.
#       # update the chain
#       while 1 < chain and wseen[chain-1]  do
#         chain := chain-1;
#       od;
#
#       for i  in [ chain .. max ]  do
#         if igs[i] = id  then
#           igs[i] := pcgs[i];
#           for j  in [ 1 .. chain-1 ]  do
#             c := Comm( igs[i], igs[j] );
#             if not c in seen  then
#               AddSet( seen, c );
#               AddSet( new, c );
#               wseen[DepthOfPcElement(pcgs,c)] := true;
#             fi;
#           od;
#         fi;
#       od;

      fi;
    od;
  od;

    igs := Filtered( igs, x -> x <> id );

#T we may not replace by elements of pcgs because that might change the
#T group.
#
# if <chain> has reached one, we have the whole group
#  for i  in [ chain .. max ]  do
#      igs[i] := pcgs[i]; # on the lowermost levels we can even get the
#      # original pcgs elements
#  od;
#  if chain = 1  then
#    igs := List( [ 1 .. max ], x -> pcgs[x] );
#  else
#  fi;

  e:=List(igs,i->ExponentsOfPcElement(pcgs,i));
  s:=0;
  d:=1;
  while d<=Length(pcgs) do
    o:=RelativeOrderOfPcElement(pcgs,pcgs[d]);

    # find pivot
    j:=s+1;
    bj:=0;
    bjo:=o;
    while j<=Length(e) do
      if e[j][d]<>0 and e[j][d]<bjo then
        bj:=j;
        bjo:=e[j][d];
      fi;
      j:=j+1;
    od;
    if bj<>0 then
      # we found a pivot, move to top
      s:=s+1;
      j:=igs[bj]; igs[bj]:=igs[s];igs[s]:=j;
      j:=e[bj]; e[bj]:=e[s];e[s]:=j;
      #change norm
      if bjo<>1 then
        bjo:=1/bjo mod o; # inverse order
        igs[s]:=igs[s]^bjo;
        e[s]:=ExponentsOfPcElement(pcgs,igs[s]);
      fi;
      # clean out
      for j in [1..Length(e)] do
        if j<>s and e[j][d]<>0 then
          igs[j]:=igs[j]/igs[s]^e[j][d];
          e[j]:=ExponentsOfPcElement(pcgs,igs[j]);
        fi;
      od;
    fi;
    d:=d+1;
  od;
  return igs{[1..s]};
end );

#############################################################################
##
#M  IndicesEANormalSteps( <ipcgs> )
##
InstallMethod(IndicesEANormalSteps,"inherit from parent",true,
  [IsInducedPcgs and HasParentPcgs],0,
function(pcgs)
local i,p,ind,a,b,d;
  p:=ParentPcgs(pcgs);
  if not HasIndicesEANormalSteps(p) then
    TryNextMethod();
  fi;
  d:=pcgs!.depthsInParent;
  ind:=[];
  a:=1;
  for i in IndicesEANormalSteps(p) do
    b:=First([a..Length(d)],x->d[x]>=i);
    if b<>fail then
      if not b in ind then
        Add(ind,b);
      fi;
      a:=b;
    fi;
  od;
  Add(ind,Length(pcgs)+1);
  return ind;
end);
