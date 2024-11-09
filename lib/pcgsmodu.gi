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
##  This file contains the   methods for polycyclic generating  systems modulo
##  another such system.
##


#############################################################################
##
#R  IsModuloPcgsRep
##
DeclareRepresentation( "IsModuloPcgsRep", IsPcgsDefaultRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap" ] );


#############################################################################
##
#R  IsModuloTailPcgsRep
##
DeclareRepresentation( "IsModuloTailPcgsRep", IsModuloPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap" ] );

#############################################################################
##
#R  IsSubsetInducedNumeratorModuloTailPcgsRep(<obj>)
##
DeclareRepresentation( "IsSubsetInducedNumeratorModuloTailPcgsRep",
    IsModuloTailPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap","depthsInParent","numeratorParent","parentZeroVector" ] );

#############################################################################
##
#R  IsModuloTailPcgsByListRep(<obj>)
##
DeclareRepresentation( "IsModuloTailPcgsByListRep", IsModuloTailPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap","depthsInParent","numeratorParent","parentZeroVector" ] );

#############################################################################
##
#R  IsNumeratorParentForExponentsRep(<obj>)
##
##  modulo pcgs in this representation can use the numerator parent for
##  computing exponents
DeclareRepresentation( "IsNumeratorParentForExponentsRep",
    IsModuloPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap","depthsInParent","numeratorParent","parentZeroVector" ] );

#############################################################################
##
#R  IsNumeratorParentLayersForExponentsRep(<obj>)
##
##  modulo pcgs in this representation can use the numerator parent for
##  computing exponents by working in elementary abelian layers (but not in
##  one chunk, as there are cofactors).
DeclareRepresentation( "IsNumeratorParentLayersForExponentsRep",
    IsModuloPcgsRep,
    [ "moduloDepths", "moduloMap", "numerator", "denominator",
      "depthMap","depthsInParent","numeratorParent","parentZeroVector" ] );

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
InstallMethod( Length,"modulo pcgs",
    true,
    [ IsModuloPcgs ],
    0,
    pcgs -> Length(pcgs!.pcSequence) );


#############################################################################
##
#M  Position( <pcgs>, <elm>, <from> )
##
InstallMethod( Position,"modulo pcgs",
    true,
    [ IsModuloPcgs ,
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
InstallMethod( PrintObj,"modulo pcgs",
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
InstallMethod( \[\],"modulo pcgs",
    true,
    [ IsModuloPcgs,
      IsPosInt ],
    0,

function( pcgs, pos )
    return pcgs!.pcSequence[pos];
end );

#############################################################################
##
#M  ModuloTailPcgsByList( <home>, <list>, <taildepths> )
##
InstallGlobalFunction( ModuloTailPcgsByList,
function( home, factor, wm )
local   wd,  filter,  new,  i;

  if IsSubset(home,factor) then
    wd:=List(factor,i->Position(home,i));
  else
    wd:=List(factor,i->DepthOfPcElement(home,i));
  fi;

  # check which filter to use
  filter := IsModuloPcgs and IsModuloTailPcgsRep
            and IsModuloTailPcgsByListRep;

  if IsSubset(home,factor) then
    filter:=filter and IsSubsetInducedNumeratorModuloTailPcgsRep;
  fi;

  if Length(wd)=Length(Set(wd)) then
    # the depths are all different. We can get the exponetnts from the
    # parent pcgs
    filter:=filter and IsNumeratorParentForExponentsRep;
  fi;

  # this can be more messy -- do not use
  if HasIsFamilyPcgs(home)
      and IsFamilyPcgs(home) then
    filter:=filter and IsNumeratorParentPcgsFamilyPcgs;
  fi;

  if IsPrimeOrdersPcgs(home)  then
      filter := filter and HasIsPrimeOrdersPcgs and IsPrimeOrdersPcgs
                       and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
  elif IsFiniteOrdersPcgs(home)  then
      filter := filter and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
  fi;

  # construct a pcgs from <pcs>
  new := PcgsByPcSequenceCons(
              IsPcgsDefaultRep,
              filter,
              FamilyObj(OneOfPcgs(home)),
              factor,[]);

  SetRelativeOrders(new,RelativeOrders(home){wd});
  # store other useful information
  new!.moduloDepths := wm;

  # setup the maps
  new!.moduloMap := [];
  for i  in [ 1 .. Length(wm) ]  do
      new!.moduloMap[wm[i]] := i;
  od;
  new!.depthMap := [];
  for i  in [ 1 .. Length(wd) ]  do
      new!.depthMap[wd[i]] := i;
  od;

  new!.numeratorParent:=home;
  new!.depthsInParent:=wd;
  new!.parentZeroVector:=home!.zeroVector;

  # and return
  return new;
end);

#############################################################################
##
#M  ModuloPcgsByPcSequenceNC( <home>, <pcs>, <modulo> )
##
InstallMethod( ModuloPcgsByPcSequenceNC, "generic method for pcgs mod pcgs",
    true, [ IsPcgs, IsList, IsPcgs ], 0,

function( home, list, modulo )
    local   pcgs,  wm,  wp,  wd,  pcs,  filter,  new,
    i,depthsInParent,dd,par,sel,
    pcsexp,denexp,bascha,idx,sep,sed,mat;

    # <list> is a pcgs for the sum of <list> and <modulo>
    if IsPcgs(list) and (ParentPcgs(modulo) = list or IsSubset(list,modulo))
      then
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
    filter := IsModuloPcgs and
              HasDenominatorOfModuloPcgs and HasNumeratorOfModuloPcgs;

    depthsInParent:=fail; # do not set by default
    dd:=fail; # do not set by default
    if IsEmpty(wd) or wd[Length(wd)] = Length(wd)  then
        filter := filter and IsModuloTailPcgsRep;
        # are we even: tail mod further tail?
        if IsSubsetInducedPcgsRep(pcgs) and IsModuloTailPcgsRep(pcgs)
          and IsBound(pcgs!.depthsInParent) then
          filter:=filter and IsSubsetInducedNumeratorModuloTailPcgsRep;
          depthsInParent:=pcgs!.depthsInParent{wd};
          # is everything even family induced?
          if HasIsParentPcgsFamilyPcgs(pcgs)
             and IsParentPcgsFamilyPcgs(pcgs) then
            filter:=filter and IsNumeratorParentPcgsFamilyPcgs;
          fi;
        elif HasIsFamilyPcgs(pcgs) and IsFamilyPcgs(pcgs) then
          # the same if the enumerator is not induced but actually the
          # familypcgs
          filter:=filter and IsSubsetInducedNumeratorModuloTailPcgsRep
                  and IsNumeratorParentPcgsFamilyPcgs;
          depthsInParent:=[1..Length(pcgs)]; # not stored in FamilyPcgs
          depthsInParent:=depthsInParent{wd};
        fi;
    else
      if Length(wd)=Length(Set(wd)) and IsSubset(list,modulo) then
        # the depths are all different and the modulus is just a tail. We
        # can get the exponents from the parent pcgs.
        filter:=filter and IsNumeratorParentForExponentsRep;
        if not IsBound(pcgs!.depthsInParent) then
          pcgs!.depthsInParent:=List(pcgs,i->DepthOfPcElement(Parent(pcgs),i));
        fi;
        depthsInParent:=pcgs!.depthsInParent{wd};
      else
        if HasParentPcgs(pcgs) and
          IsPcgsElementaryAbelianSeries(ParentPcgs(pcgs)) then
          par:=ParentPcgs(pcgs);
          depthsInParent:=List(pcs,x->DepthOfPcElement(par,x));
          dd:=List(modulo,x->DepthOfPcElement(par,x));
          if
            Length(Union(depthsInParent,dd))=Length(depthsInParent)+Length(dd)
            then

            # we can use the parent layers to calculate exponents
            filter:=filter and IsNumeratorParentLayersForExponentsRep;
          else
            depthsInParent:=fail;
          fi;

        fi;

        filter := filter and IsModuloPcgsRep;
      fi;
    fi;
    if IsPrimeOrdersPcgs(home)  then
        filter := filter and HasIsPrimeOrdersPcgs and IsPrimeOrdersPcgs
                        and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
    elif IsFiniteOrdersPcgs(home)  then
        filter := filter and HasIsFiniteOrdersPcgs and IsFiniteOrdersPcgs;
    fi;

    # store the one and other information

    # construct a pcgs from <pcs>
    new := PcgsByPcSequenceCons(
               IsPcgsDefaultRep,
               filter,
               FamilyObj(OneOfPcgs(pcgs)),
               pcs,
               [DenominatorOfModuloPcgs, modulo,
                NumeratorOfModuloPcgs, pcgs ]);

    SetRelativeOrders(new,RelativeOrders(pcgs){wd});
    # store other useful information
    new!.moduloDepths := wm;

    # setup the maps
    new!.moduloMap := [];
    for i  in [ 1 .. Length(wm) ]  do
        new!.moduloMap[wm[i]] := i;
    od;
    new!.depthMap := [];
    for i  in [ 1 .. Length(wd) ]  do
        new!.depthMap[wd[i]] := i;
    od;

    if depthsInParent<>fail then
      new!.numeratorParent:=ParentPcgs(pcgs);
      new!.depthsInParent:=depthsInParent;
      new!.parentZeroVector:=ParentPcgs(pcgs)!.zeroVector;
    fi;

    if dd<>fail then
      new!.denpardepths:=dd;
      wm:=[];
      for i in [1..Length(dd)] do
        wm[dd[i]]:=i;
      od;
      new!.parentDenomMap:=wm;

      wm:=[];
      for i in [1..Length(depthsInParent)] do
        wm[depthsInParent[i]]:=i;
      od;
      new!.parentDepthMap:=wm;

      if HasIndicesEANormalSteps(par) then
        i:=IndicesEANormalSteps(par);
      else
        i:=IndicesNormalSteps(par);
      fi;
      new!.layranges:=List([1..Length(i)-1],x->[i[x]..i[x+1]-1]);

      pcsexp:=List(pcs,x->ExponentsOfPcElement(par,x));
      denexp:=List(modulo,x->ExponentsOfPcElement(par,x));
      bascha:=List(new!.layranges,x->fail);
      new!.basechange:=bascha;
      idx:=[];
      new!.indices:=idx;
      for i in [1..Length(new!.layranges)] do
        if new!.layranges[i][1]<=Length(wm) then
          dd:=GF(RelativeOrders(par)[new!.layranges[i][1]]);
          sep:=Filtered([1..Length(pcs)],
            x->PositionNonZero(pcsexp[x]) in new!.layranges[i]);
          sed:=Filtered([1..Length(modulo)],
            x->PositionNonZero(denexp[x]) in new!.layranges[i]);
          if Length(sep)>0 or Length(sed)>0 then
            mat:=Concatenation(pcsexp{sep}{new!.layranges[i]},
                  denexp{sed}{new!.layranges[i]})*One(dd);
            mat:=ImmutableMatrix(dd,mat);
            if Length(mat)<Length(mat[1]) then
              # add identity mat vectors at non-pivot positions
              sel:=List(TriangulizedMat(mat),PositionNonZero);
              sel:=Difference([1..Length(mat[1])],sel);
              mat:=Concatenation(mat,IdentityMat(Length(mat[1]),dd){sel});
              mat:=ImmutableMatrix(dd,mat);
            fi;;
            bascha[i]:=mat^-1;
            idx[i]:=[sep,sed];
          fi;
        fi;
      od;

    fi;

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
    "pcgs modulo pcgs, ExponentsOfPcElement", IsCollsElmsX,
    [ IsModuloPcgs, IsObject, IsPosInt ], 0,
function( pcgs, elm, pos )
    return ExponentsOfPcElement(pcgs,elm)[pos];
end );


#############################################################################
##
#M  ExponentsOfPcElement( <pcgs>, <elm>, <poss> )
##
InstallOtherMethod( ExponentsOfPcElement,
  "pcgs mod. pcgs,range, falling back to Exp.OfPcElement", IsCollsElmsX,
    [ IsModuloPcgs, IsObject, IsList ], 0,
function( pcgs, elm, pos )
    return ExponentsOfPcElement(pcgs,elm){pos};
end );


#############################################################################
##
#M  IsFiniteOrdersPcgs( <modulo-pcgs> )
##
InstallOtherMethod( IsFiniteOrdersPcgs, true, [ IsModuloPcgs ], 0,
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
    return ForAll( RelativeOrders(pcgs), IsPrimeInt );
end );



#############################################################################
##
#M  LeadingExponentOfPcElement( <modulo-pcgs>, <elm> )
##
InstallOtherMethod( LeadingExponentOfPcElement,
    "pcgs modulo pcgs, use ExponentsOfPcElement", IsCollsElms,
    [ IsModuloPcgs, IsObject ], 0,
function( pcgs, elm )
    local   exp,  dep;

    exp := ExponentsOfPcElement( pcgs, elm );
    dep := PositionNonZero( exp );
    if Length(exp) < dep  then
        return fail;
    else
        return exp[dep];
    fi;
end );



#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <empty-list> )
##
InstallOtherMethod( PcElementByExponentsNC, "generic method for empty lists",
    true, [ IsModuloPcgs, IsList and IsEmpty ], 0,
function( pcgs, list )
    return OneOfPcgs(pcgs);
end );


#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <list> )
##

InstallOtherMethod( PcElementByExponentsNC, "generic method: modulo", true,
    [ IsModuloPcgs, IsRowVector and IsCyclotomicCollection ], 0,
function( pcgs, list )
  return DoPcElementByExponentsGeneric(pcgs,pcgs,list);
end);


#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <ffe-list> )
##
InstallOtherMethod( PcElementByExponentsNC, "generic method: modulo, FFE",
    true, [ IsModuloPcgs, IsRowVector and IsFFECollection ], 0,
function( pcgs, list )
  return DoPcElementByExponentsGeneric(pcgs,pcgs,list);
end);


#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <basis>, <empty-list> )
##
InstallOtherMethod( PcElementByExponentsNC,
    "generic method for empty list as basis or basisindex, modulo", true,
    [ IsModuloPcgs, IsList and IsEmpty, IsList ],
    SUM_FLAGS, #this is better than everything else

function( pcgs, basis, list )
    return OneOfPcgs(pcgs);
end );


#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <basis>, <list> )
##
InstallOtherMethod( PcElementByExponentsNC, "generic method: modulo, basis",
    IsFamFamX, [IsModuloPcgs,IsList,IsRowVector and IsCyclotomicCollection], 0,
    DoPcElementByExponentsGeneric );


#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <basis>, <list> )
##
InstallOtherMethod( PcElementByExponentsNC,
    "generic method: modulo, basis, FFE", IsFamFamX,
    [ IsModuloPcgs, IsList, IsRowVector and IsFFECollection ], 0,
    DoPcElementByExponentsGeneric );


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
    # Avoid infinite recursion
    if IsIdenticalObj(NumeratorOfModuloPcgs(pcgs),pcgs) then
      TryNextMethod();
    fi;
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
    {} -> RankFilter(IsModuloPcgs)
    -RankFilter(IsModuloPcgs and IsPrimeOrdersPcgs),

function( pcgs, elm )
    # Avoid infinite recursion
    if IsIdenticalObj(NumeratorOfModuloPcgs(pcgs),pcgs) then
      TryNextMethod();
    fi;
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
    # Avoid infinite recursion
    if IsIdenticalObj(NumeratorOfModuloPcgs(pcgs),pcgs) then
      TryNextMethod();
    fi;

    num := NumeratorOfModuloPcgs(pcgs);
    d := DepthOfPcElement( num, elm );
    if d > Length(num)  then
        return Length(pcgs)+1;
    elif d in pcgs!.moduloDepths  then
        return PositionNonZero( ExponentsOfPcElement( pcgs, elm ) );
    else
        return pcgs!.depthMap[d];
    fi;
end );

#############################################################################
##
#M  ExponentsOfPcElement( <modulo-pcgs>, <elm> )
##
InstallOtherMethod( ExponentsOfPcElement, "pcgs modulo pcgs", IsCollsElms,
    [ IsModuloPcgs and IsModuloPcgsRep, IsObject ], 0,
function( pcgs, elm )
    local   id,  exp,  ros,  den,  num,  mm,  pm,  d,  ll,  lr,lede;

    # Avoid infinite recursion
    if IsIdenticalObj(NumeratorOfModuloPcgs(pcgs),pcgs) then
      TryNextMethod();
    fi;

    id  := OneOfPcgs(pcgs);
    exp := ListWithIdenticalEntries(Length(pcgs),0);
    if not IsBound(pcgs!.lede) then pcgs!.lede:=[];fi;
    lede:=pcgs!.lede;
    den := DenominatorOfModuloPcgs(pcgs);
    num := NumeratorOfModuloPcgs(pcgs);
    if not IsPrimeOrdersPcgs(num)  then TryNextMethod();  fi;

    mm  := pcgs!.moduloMap;
    pm  := pcgs!.depthMap;
    ros := RelativeOrders(num);

    while elm <> id  do
        d := DepthOfPcElement( num, elm );
        if d>Length(pm) then
          # all lower will only be in denominator
          return exp;
        fi;

        ll  := LeadingExponentOfPcElement( num, elm );
        if IsBound(mm[d])  then
            if not IsBound(lede[d]) then
              lede[d]:=LeadingExponentOfPcElement( num, den[mm[d]] );
            fi;
            lr  := lede[d];
            elm := LeftQuotient( den[mm[d]]^(ll / lr mod ros[d]), elm );
        else
            #ll := LeadingExponentOfPcElement( num, elm );
            if not IsBound(lede[d]) then
              lede[d]:=LeadingExponentOfPcElement( num, pcgs[pm[d]] );
            fi;
            lr := lede[d];
            exp[pm[d]] := ll / lr mod ros[d];
            elm := LeftQuotient( pcgs[pm[d]]^exp[pm[d]], elm );
        fi;
    od;
    return exp;
end );

#############################################################################
##
#M  ExponentsOfPcElement( <modulo-pcgs>, <elm> )
##
InstallOtherMethod( ExponentsOfPcElement, "modpcgs numerator parent layers",
   IsCollsElms,
    [ IsModuloPcgs and IsModuloPcgsRep and
      IsNumeratorParentLayersForExponentsRep, IsObject ], 0,
function( pcgs, elm )
local   id,exp,den,par,ll,lr,idx,bascha,e,ee,prd,i,la,lap,pm;

    #elm0:=elm;
    id  := OneOfPcgs(pcgs);
    exp := ListWithIdenticalEntries(Length(pcgs),0);
    if not IsBound(pcgs!.lede) then pcgs!.lede:=[];fi;
    den := DenominatorOfModuloPcgs(pcgs);
    par := ParentPcgs(NumeratorOfModuloPcgs(pcgs));
    if not IsPrimeOrdersPcgs(par)  then TryNextMethod();  fi;

    idx:=pcgs!.indices;
    bascha:=pcgs!.basechange;
    pm:=Length(pcgs!.parentDepthMap);

    for lap in [1..Length(pcgs!.layranges)] do
      if bascha[lap]<>fail then
        la:=pcgs!.layranges[lap];
        ee:=ExponentsOfPcElement(par,elm,la);
        ee:=ee*bascha[lap]; # coefficients as needed

        if lap<Length(pcgs!.layranges) and pcgs!.layranges[lap+1][1]<=pm then
          prd:=id;
        else
          prd:=fail;
        fi;
        ll:=idx[lap][1];
        for i in [1..Length(ll)] do
          e:=Int(ee[i]);
          exp[ll[i]]:=e;
          if prd<>fail and not IsZero(e) then
            prd:=prd*pcgs[ll[i]]^e;
          fi;
        od;

        if prd<>fail then
          ll:=Length(ll);
          lr:=idx[lap][2];
          for i in [1..Length(lr)] do
            e:=Int(ee[i+ll]);
            if not IsZero(e) then;
              prd:=prd*den[lr[i]]^e;
            fi;
          od;
        fi;

        if prd<>fail and not IsIdenticalObj(prd,id) then
          # divide off
          elm:=LeftQuotient(prd,elm);
        fi;
        if prd=fail then
  #if exp<>basiccmp(pcgs,elm0) then Error("err1");fi;
          return exp;
        fi;
      fi;

    od;
  #if exp<>basiccmp(pcgs,elm0) then Error("err2");fi;
    return exp;

end );

#############################################################################
##
#M  ExponentsOfPcElement( <modulo-pcgs>, <elm>, <subrange> )
##

# this methoid ought to be obsolete
InstallOtherMethod( ExponentsOfPcElement, "pcgs modulo pcgs, subrange",
    IsCollsElmsX, [ IsModuloPcgs and IsModuloPcgsRep, IsObject,IsList ], 0,
function( pcgs, elm,range )
    local   id,  exp,  ros,  den,  num,  mm,  pm,  d,  ll,  lr,max;

    # Avoid infinite recursion
    if IsIdenticalObj(NumeratorOfModuloPcgs(pcgs),pcgs) then
      TryNextMethod();
    fi;

    Info(InfoWarning,1,"Obsolete exponents method");
    if not IsSSortedList(range) then
      TryNextMethod(); # the range may be unsorted or contain duplicates,
      # then we would have to be more clever.
    fi;
    max:=Maximum(range);

    id  := OneOfPcgs(pcgs);
    exp := ListWithIdenticalEntries(Length(pcgs),0);
    den := DenominatorOfModuloPcgs(pcgs);
    num := NumeratorOfModuloPcgs(pcgs);
    if not IsPrimeOrdersPcgs(num)  then TryNextMethod();  fi;

    mm  := pcgs!.moduloMap;
    pm  := pcgs!.depthMap;
    ros := RelativeOrders(num);

    while elm <> id  do
      d := DepthOfPcElement( num, elm );
      if IsBound(pm[d]) and pm[d]>max then
        # we have reached the maximum of the range we asked for. Thus we
        # can stop calculating exponents now, all further exponents would
        # be discarded anyhow.
        # Note that the depthMap is sorted!
        elm:=id;
      else
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
      fi;
    od;
    exp:=exp{range};
    return exp;
end );


#############################################################################
##
#M  ExponentsOfPcElement( <tail-pcgs>, <elm> )
##
InstallOtherMethod( ExponentsOfPcElement, "pcgs modulo tail-pcgs", IsCollsElms,
    [ IsModuloPcgs and IsModuloTailPcgsRep, IsObject ], 0,
function( pcgs, elm )
    return ExponentsOfPcElement(
        NumeratorOfModuloPcgs(pcgs), elm, pcgs!.depthMap );
end );

#############################################################################
##
#M  ExponentsOfPcElement( <tail-pcgs>, <elm>, <subrange> )
##
InstallOtherMethod( ExponentsOfPcElement, "pcgs modulo tail-pcgs, subrange",
    IsCollsElmsX, [ IsModuloPcgs and IsModuloTailPcgsRep, IsObject,IsList ], 0,
function( pcgs, elm,range )
    return ExponentsOfPcElement(
        NumeratorOfModuloPcgs(pcgs), elm, pcgs!.depthMap{range} );
end );

#############################################################################
##
#M  ExponentOfPcElement( <tail-pcgs>, <elm>, <pos> )
##
InstallOtherMethod( ExponentOfPcElement,
    "pcgs modulo tail-pcgs, ExponentsOfPcElement",IsCollsElmsX,
    [ IsModuloPcgs and IsModuloTailPcgsRep,
      IsObject,
      IsPosInt ], 0,
function( pcgs, elm, pos )
    return ExponentOfPcElement(
        NumeratorOfModuloPcgs(pcgs), elm, pcgs!.depthMap[pos] );
end );

#############################################################################
##
#M  ExponentsConjugateLayer( <mpcgs>,<elm>,<e> )
##
InstallMethod( ExponentsConjugateLayer,"default: compute brute force",
  IsCollsElmsElms,[IsModuloPcgs,IsMultiplicativeElementWithInverse,
                   IsMultiplicativeElementWithInverse],0,
function(m,elm,e)
  return ExponentsOfPcElement(m,elm^e);
end);

#############################################################################
##
#M  PcGroupWithPcgs( <modulo-pcgs> )
##
InstallMethod( PcGroupWithPcgs, "pcgs modulo pcgs", true, [ IsModuloPcgs ], 0,

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
InstallOtherMethod( GroupOfPcgs, true, [ IsModuloPcgs ], 0,
function( pcgs )
  return GroupOfPcgs( NumeratorOfModuloPcgs( pcgs ) );
end );

#############################################################################
##
#M  NumeratorOfModuloPcgs( <modolo-tail-pcgs-by-list-rep> )
##
InstallMethod( NumeratorOfModuloPcgs,
    "modolo-tail-pcgs-by-list-rep", true,
    [ IsModuloPcgs and IsModuloTailPcgsByListRep],0,
function( mpcgs )
local home;
  home:=mpcgs!.numeratorParent;
  return InducedPcgsByPcSequenceNC(home,
           Concatenation(mpcgs!.pcSequence,home{mpcgs!.moduloDepths}));
end );

#############################################################################
##
#M  DenominatorOfModuloPcgs( <modolo-tail-pcgs-by-list-rep> )
##
InstallMethod( DenominatorOfModuloPcgs,
    "modolo-tail-pcgs-by-list-rep", true,
    [ IsModuloPcgs and IsModuloTailPcgsByListRep],0,
function( mpcgs )
local home;
  home:=mpcgs!.numeratorParent;
  return InducedPcgsByPcSequenceNC(home,home{mpcgs!.moduloDepths});
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
local home;
  home:=HomePcgs(G);
  RelativeOrders(home);
  G:=InducedPcgs(home,G);
  return G mod InducedPcgs(home,H);
end);

#############################################################################
##
#M  PcElementByExponentsNC( <family pcgs modulo>, <list> )
##
InstallMethod( PcElementByExponentsNC,
    "modulo subset induced wrt family pcgs", true,
    [ IsModuloPcgs and
      IsSubsetInducedNumeratorModuloTailPcgsRep and IsPrimeOrdersPcgs
      and IsNumeratorParentPcgsFamilyPcgs,
      IsRowVector and IsCyclotomicCollection ], 0,
function( pcgs, list )
local exp;
  exp:=ShallowCopy(pcgs!.parentZeroVector);
  exp{pcgs!.depthsInParent}:=list;
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),exp);
end);

InstallOtherMethod( PcElementByExponentsNC,
    "modulo subset induced wrt family pcgs,index", true,
    [ IsModuloPcgs and
      IsSubsetInducedNumeratorModuloTailPcgsRep and IsPrimeOrdersPcgs
      and IsNumeratorParentPcgsFamilyPcgs,
      IsRowVector and IsCyclotomicCollection,
      IsRowVector and IsCyclotomicCollection ], 0,
function( pcgs,ind, list )
local exp;
  #Assert(1,ForAll(list,i->i>=0));
  exp:=ShallowCopy(pcgs!.parentZeroVector);
  exp{pcgs!.depthsInParent{ind}}:=list;
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),exp);
end);

#############################################################################
##
#M  PcElementByExponentsNC( <family pcgs modulo>, <list> )
##
InstallMethod( PcElementByExponentsNC,
    "modulo subset induced wrt family pcgs, FFE", true,
    [ IsModuloPcgs and
      IsSubsetInducedNumeratorModuloTailPcgsRep and IsPrimeOrdersPcgs
      and IsNumeratorParentPcgsFamilyPcgs,
      IsRowVector and IsFFECollection ], 0,
function( pcgs, list )
local exp;
  list:=IntVecFFE(list);
  exp:=ShallowCopy(pcgs!.parentZeroVector);
  exp{pcgs!.depthsInParent}:=list;
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),exp);
end);

InstallOtherMethod( PcElementByExponentsNC,
    "modulo subset induced wrt family pcgs, FFE, index", true,
    [ IsModuloPcgs and
      IsSubsetInducedNumeratorModuloTailPcgsRep and IsPrimeOrdersPcgs
      and IsNumeratorParentPcgsFamilyPcgs,
      IsRowVector and IsCyclotomicCollection,
      IsRowVector and IsFFECollection ], 0,
function( pcgs,ind, list )
local exp;
  list:=IntVecFFE(list);
  exp:=ShallowCopy(pcgs!.parentZeroVector);
  exp{pcgs!.depthsInParent{ind}}:=list;
  return ObjByVector(TypeObj(OneOfPcgs(pcgs)),exp);
end);

InstallMethod( ExponentsConjugateLayer,"subset induced modulo pcgs",
  IsCollsElmsElms,
  [ IsModuloPcgs and
    IsSubsetInducedNumeratorModuloTailPcgsRep and IsPrimeOrdersPcgs
    and IsNumeratorParentPcgsFamilyPcgs,
  IsMultiplicativeElementWithInverse,IsMultiplicativeElementWithInverse],0,
function(m,e,c)
  return DoExponentsConjLayerFampcgs(m!.numeratorParent,m,e,c);
end);

#############################################################################
##
#M  ExponentsOfPcElement( <subset-induced,modulo-tail-pcgs>,<elm>,<subrange> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "subset induced pcgs modulo tail-pcgs, subrange",
    IsCollsElmsX,
    [ IsModuloPcgs and IsModuloTailPcgsRep
      and IsNumeratorParentForExponentsRep, IsObject,IsList ], 0,
function( pcgs, elm, range )
    return
      ExponentsOfPcElement(pcgs!.numeratorParent,elm,pcgs!.depthsInParent{range});
end );

#############################################################################
##
#M  ExponentsOfPcElement( <subset-induced,modulo-tail-pcgs>, <elm> )
##
InstallOtherMethod( ExponentsOfPcElement,
    "subset induced pcgs modulo tail-pcgs", IsCollsElms,
    [ IsModuloPcgs and IsModuloTailPcgsRep
      and IsNumeratorParentForExponentsRep, IsObject ], 0,
function( pcgs, elm )
    return
      ExponentsOfPcElement(pcgs!.numeratorParent,elm,pcgs!.depthsInParent);
end );

#############################################################################
##
#M  ExponentsOfConjugate( <subset-induced,modulo-tail-pcgs>, <> )
##
InstallOtherMethod( ExponentsOfConjugate,
    "subset induced pcgs modulo tail-pcgs", true,
    [ IsModuloPcgs and IsModuloTailPcgsRep
      and IsNumeratorParentForExponentsRep, IsPosInt,IsPosInt ], 0,
function( pcgs, i,j )
  return ExponentsOfConjugate(ParentPcgs(pcgs!.numeratorParent),
    pcgs!.depthsInParent[i], # depth of the element in the parent
    pcgs!.depthsInParent[j]) # depth of the element in the parent
                                {pcgs!.depthsInParent};
end );

#############################################################################
##
#M  ExponentsOfRelativePower( <subset-induced,modulo-tail-pcgs>, <> )
##
InstallOtherMethod( ExponentsOfRelativePower,
    "subset induced pcgs modulo tail-pcgs", true,
    [ IsModuloPcgs and IsModuloTailPcgsRep
      and IsNumeratorParentForExponentsRep, IsPosInt ], 0,
function( pcgs, ind )
  return ExponentsOfRelativePower(ParentPcgs(pcgs!.numeratorParent),
    pcgs!.depthsInParent[ind]) # depth of the element in the parent
                                {pcgs!.depthsInParent};
end );
