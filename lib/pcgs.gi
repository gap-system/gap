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
##  This file contains the methods for polycyclic generating systems.
##

#############################################################################
##
#M  Pcgs( <A> ) . . . . . . . .  from independent generators of abelian group
##
InstallGlobalFunction( PcgsByIndependentGeneratorsOfAbelianGroup, function( A )
    local   pcgs,  pcs,  rel,  gen,  f;

    pcs := [  ];
    rel := [  ];
    for gen  in IndependentGeneratorsOfAbelianGroup( A )  do
        for f  in Factors(Integers, Order( gen ) )  do
            Add( pcs, gen );
            Add( rel, f );
            gen := gen ^ f;
        od;
    od;
    pcgs := PcgsByPcSequenceNC( FamilyObj( One( A ) ), pcs );
    SetOneOfPcgs( pcgs, One( A ) );
    SetRelativeOrders( pcgs, rel );
    SetIsPrimeOrdersPcgs( pcgs, true );
    return pcgs;
end );

InstallMethod( Pcgs, "from independent generators of abelian group", true,
    [ IsGroup and IsAbelian and HasIndependentGeneratorsOfAbelianGroup ], 0,
function(A)
  if HasHomePcgs(A) then
    TryNextMethod();
  else
    return PcgsByIndependentGeneratorsOfAbelianGroup(A);
  fi;
end);

InstallMethod( Pcgs, "from independent generators of abelian group", true,
    [ IsGroup and IsAbelian and CanEasilyComputeWithIndependentGensAbelianGroup ], 0,
function(A)
  if HasHomePcgs(A) then
    TryNextMethod();
  else
    return PcgsByIndependentGeneratorsOfAbelianGroup(A);
  fi;
end);

#############################################################################
##
#M  SetPcgs( <G>, fail )  . . . . . . . . . . . . . . . . .  never set `fail'
##
##  `HasPcgs' implies  `CanEasilyComputePcgs',  which implies `IsSolvable',
##  so a  pcgs cannot be set for insoluble permutation groups.
##  As Pcgs may return 'fail' for non-solvable permutation groups, this method
##  is necessary.
##
InstallMethod( SetPcgs, true, [ IsGroup, IsBool ], 0,
function( G, failval )
    SetIsSolvableGroup( G, false );
end );


#############################################################################
##
#M  IsBound[ <pos> ]
##
InstallMethod( IsBound\[\],
    "pcgs",
    true,
    [ IsPcgs,
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
    "pcgs",
    true,
    [ IsPcgs and IsPcgsDefaultRep ],
    0,
    pcgs -> Length(pcgs!.pcSequence) );

#############################################################################
##
#M  AsList( <pcgs> )
##
InstallMethod( AsList, "pcgs", true,
    [ IsPcgs and IsPcgsDefaultRep ], 0,
    pcgs -> pcgs!.pcSequence );

#############################################################################
##
#M  Position( <pcgs>, <elm>, <from> )
##
InstallMethod( Position,
    "pcgs, object, int",
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
InstallMethod( PrintObj, "pcgs", true, [ IsPcgs and IsPcgsDefaultRep ], 0,
function(pcgs)
  Print( "Pcgs(", pcgs!.pcSequence, ")" );
end );

#############################################################################
##
#M  ViewObj( <pcgs> )
##
InstallMethod( ViewObj, "pcgs", true, [ IsPcgs and IsPcgsDefaultRep ], 0,
function(pcgs)
  Print("Pcgs(");
  View(pcgs!.pcSequence);
  Print(")");
end );


#############################################################################
##
#M  <pcgs> [ <pos> ]
##
InstallMethod( \[\],
    "pcgs, pos int",
    true,
    [ IsPcgs and IsPcgsDefaultRep,
      IsPosInt ],
    0,

function( pcgs, pos )
    return pcgs!.pcSequence[pos];
end );

#############################################################################
##
#M  <pcgs>{[ <pos> ]}
##
InstallMethod( ELMS_LIST, "pcgs, range", true, [ IsPcgs, IsDenseList ], 0,
function( pcgs, ran )
    return pcgs!.pcSequence{ran};
end );

#############################################################################
##
#M  PcgsByPcSequenceCons( <req-filter>, <imp-filter>, <fam>, <pcs> )
##
InstallMethod( PcgsByPcSequenceCons, "generic constructor", true,
    [ IsPcgsDefaultRep, IsObject, IsFamily, IsList,IsList ], 0,
function( filter, imp, efam, pcs,attl )
    local   pcgs,  fam,one;

    imp:=filter and imp;
    # if the <efam> has a family pcgs check if the are equal
    if HasDefiningPcgs(efam) and DefiningPcgs(efam) = pcs  then
      imp := imp and IsFamilyPcgs;
    fi;
    imp:=imp and HasLength;

    # construct a pcgs object
    pcgs := rec(
      pcSequence := Immutable(pcs),
      zeroVector := Immutable(ListWithIdenticalEntries(Length(pcs),0)),
      powers:=[],
      conjugates:=List(pcs,i->[]));

    # get the pcgs family
    fam := CollectionsFamily(efam);

    # set a one
    if HasOne(efam)  then
      one:=One(efam);
    elif 0 < Length(pcs)  then
      one:=One(pcs[1]);
    else
      one:=fail;
    fi;
    if one<>fail then
      attl:=Concatenation([pcgs, NewType( fam, imp and HasOneOfPcgs),
                          Length,Length(pcs),OneOfPcgs,one],attl);
    else
      attl:=Concatenation([pcgs, NewType( fam, imp ),
                          Length,Length(pcs)],attl);
    fi;

    # convert record into component object
    CallFuncList( ObjectifyWithAttributes,attl );

    # a place to cache powers
    pcgs!.pcSeqPowers:=List(pcs,i->[]);
    pcgs!.pcSeqPowersInv:=List(pcs,i->[]);

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
    return ForAll( RelativeOrders(pcgs), IsPrimeInt );
end );

#############################################################################
##
#M RefinedPcGroup( <G> )
##
InstallMethod( RefinedPcGroup,
               "group with refined pcgs", true, [IsPcGroup], 0,
function( G )
  return Range(IsomorphismRefinedPcGroup(G));
end);

#############################################################################
##
#M IsomorphismRefinedPcGroup( <G> )
##
InstallMethod( IsomorphismRefinedPcGroup,
               "group with refined pcgs", true, [IsPcGroup], 0,
function( G )
    local word, expo, pcgs, rels, new, ord, i, facs, g, f, n, F, gens,
          rela, w, t, H, map, j;

    word := function( exp, gens, id )
        local h, i;
        h := id;
        for i in [1..Length(exp)] do
            h := h * gens[i]^exp[i];
        od;
        return h;
    end;

    expo := function( pcgs, g, map )
        local exp, new, i, c;
        exp := ExponentsOfPcElement( pcgs, g );
        new := [];
        for i in [1..Length(exp)] do
            c := CoefficientsMultiadic( Reversed(map[i]), exp[i] );
            Append( new, Reversed( c ) );
        od;
        return new;
    end;

    # get the pcgs of G
    pcgs := Pcgs(G);
    rels := RelativeOrders( pcgs );
    if ForAll( rels, IsPrime ) then return IdentityMapping(G); fi;

    # get the refined pcgs
    new := [];
    ord := [];
    map := [];
    for i in [1..Length(pcgs)] do
        facs := Factors(Integers, rels[i] );
        g    := pcgs[i];
        for f in facs do
            Add( new, g );
            Add( ord, f );
            g := g^f;
        od;
        Add( map, facs );
    od;

    # compute a group with respect to <new>
    n := Length( new );
    F := FreeGroup(IsSyllableWordsFamily, n );
    gens := GeneratorsOfGroup( F );
    rela := [];

    for i in [1..n] do

        # the power
        w := gens[i]^ord[i];
        t := expo( pcgs, new[i]^ord[i], map );
        t := word( t, gens, One(F) );
        Add( rela, w/t );

        for j in [i+1..n] do

            # the commutator
            w := Comm( gens[i], gens[j] );
            t := expo( pcgs, Comm( new[i], new[j] ), map );
            t := word( t, gens, One(F) );
            Add( rela, w/t );
        od;
    od;

    H := F/rela;
    H:=PcGroupFpGroup( H );
    return GroupHomomorphismByImagesNC(G,H,new,FamilyPcgs(H));
end );

#############################################################################
##
#M  IsFiniteOrdersPcgs( <pcgs> )
##
InstallTrueMethod( IsFiniteOrdersPcgs, IsPrimeOrdersPcgs );

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
    return PositionNonZero( ExponentsOfPcElement( pcgs, elm ) );
end );

#############################################################################
##
#M  DepthAndLeadingExponentOfPcElement( <pcgs>, <elm> )
##
InstallMethod( DepthAndLeadingExponentOfPcElement,
    "generic methods, ExponentsOfPcElement",
    IsCollsElms, [ IsModuloPcgs, IsObject ], 0,
function( pcgs, elm )
local e,p;
    e:=ExponentsOfPcElement( pcgs, elm );
    p:=PositionNonZero( e );
    if p>Length(e) then
      return [p,0];
    else
      return [p,e[p]];
    fi;
end );


#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <elm>, <min> )
##
InstallOtherMethod( DepthOfPcElement,
    "pcgs modulo pcgs, ignoring <min>",
    function(a,b,c) return IsCollsElms(a,b); end,
    [ IsPcgs,
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
    return PcElementByExponentsNC( pcgs,
        ExponentsOfPcElement(pcgs,left)-ExponentsOfPcElement(pcgs,right) );
end );


#############################################################################
##
#M  ExponentOfPcElement( <pcgs>, <elm>, <pos> )
##
InstallMethod( ExponentOfPcElement,
    "generic method, ExponentsOfPcElement",
    IsCollsElmsX,
    [ IsPcgs,
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
    "with positions, falling back to ExponentsOfPcElement",
    IsCollsElmsX,
    [ IsPcgs,
      IsObject,
      IsList ],
    0,

function( pcgs, elm, pos )
    return ExponentsOfPcElement(pcgs,elm){pos};
end );

#############################################################################
##
#M  ExponentsOfConjugate( <pcgs>, <i>, <j> )
##
InstallMethod( ExponentsOfConjugate,"generic: compute conjugate",true,
    [ IsModuloPcgs, IsPosInt,IsPosInt], 0,
function( pcgs, i, j )
  if not IsBound(pcgs!.conjugates[i][j]) then
    pcgs!.conjugates[i][j]:=ExponentsOfPcElement(pcgs,pcgs[i]^pcgs[j]);
  fi;
  return pcgs!.conjugates[i][j];
end );

#############################################################################
##
#M  ExponentsOfRelativePower( <pcgs>, <i> )
##
InstallMethod( ExponentsOfRelativePower,"generic: compute power",true,
    [ IsModuloPcgs, IsPosInt], 0,
function( pcgs, i )
  return ExponentsOfPcElement(pcgs,pcgs[i]^RelativeOrders(pcgs)[i]);
end );

#############################################################################
##
#M  ExponentsOfCommutator( <pcgs>, <i>, <j> )
##
InstallMethod( ExponentsOfCommutator,"generic: compute commutator",true,
    [ IsModuloPcgs, IsPosInt,IsPosInt], 0,
function( pcgs, i, j )
  return ExponentsOfPcElement(pcgs,Comm(pcgs[i],pcgs[j]));
end );


#############################################################################
##
#M  HeadPcElementByNumber( <pcgs>, <elm>, <num> )
##
InstallMethod( HeadPcElementByNumber,
    "using 'ExponentsOfPcElement', 'PcElementByExponents'",
    true,
    [ IsPcgs,
      IsObject,
      IsInt ],
    0,

function( pcgs, elm, pos )
    local   exp,  i;

    exp := ShallowCopy(ExponentsOfPcElement( pcgs, elm ));
    if pos < 1  then pos := 1;  fi;
    for i  in [ pos .. Length(exp) ]  do
        exp[i] := 0;
    od;
    return PcElementByExponentsNC( pcgs, exp );
end );

#############################################################################
##
#M  ParentPcgs( <pcgs> )
##
InstallOtherMethod( ParentPcgs, true, [ IsPcgs ], 0, IdFunc );

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
    dep := PositionNonZero( exp );
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
InstallGlobalFunction(PcElementByExponents,function(arg)
local i,ro;
  if Length(arg)=2 then
    if Length(arg[1])<>Length(arg[2]) then
      Error( "<list> and <pcgs> have different lengths" );
    fi;
    ro:=RelativeOrders(arg[1]);
    for i in [1..Length(ro)] do
      if ro[i]<>0 and IsRat(arg[2][i])
         and (arg[2][i]<0 or arg[2][i]>=ro[i]) then
        Error("Exponent out of range!");
      fi;
    od;
    return PcElementByExponentsNC(arg[1],arg[2]);
  else
    if Length(arg[3])<>Length(arg[2]) then
      Error( "<list> and <basis> have different lengths" );
    fi;
    return PcElementByExponentsNC(arg[1],arg[2],arg[3]);
  fi;
end);

InstallMethod( PcElementByExponentsNC,
    "generic method for empty lists",
    true,
    [ IsPcgs,
      IsList and IsEmpty ],
    0,

function( pcgs, list )
    return OneOfPcgs(pcgs);
end );

#############################################################################
##
#F  PowerPcgsElement( <pcgs>, <i>,<exp> )
##
InstallGlobalFunction(PowerPcgsElement,function( pcgs, i,exp )
local l,e;
  if exp=0 then
    return OneOfPcgs(pcgs);
  elif exp>0 then
    l:=pcgs!.pcSeqPowers[i];
    e:=exp;
  else
    l:=pcgs!.pcSeqPowersInv[i];
    e:=-exp;
  fi;
  if not IsBound(l[e]) then
    l[e]:=pcgs[i]^exp;
  fi;
  return l[e];
end );

#############################################################################
##
#F  LeftQuotientPowerPcgsElement( <pcgs>, <i>,<exp> )
##
InstallGlobalFunction(LeftQuotientPowerPcgsElement,function( pcgs, i,exp,elm )
  return LeftQuotient(PowerPcgsElement(pcgs,i,exp),elm);
# the following code seemed more clever, but somehow `LeftQuotient'
# performs better. 5-5-99, AH
#local e;
#  e:=pcgs[i];
#  if NumberSyllables(UnderlyingElement(e))=1 then
#    # single pc element (or its power): LeftQuotient is clever
#    return LeftQuotient(e^exp,elm);
#  else
#    # more complicated element: rather go via the inverse power
#    return PowerPcgsElement(pcgs,i,-exp)*elm;
#  fi;
end );

BindGlobal( "DoPcElementByExponentsGeneric", function(pcgs,basis,list)
local elm,i,a;

  elm := fail;

  for i  in [ 1 .. Length(list) ]  do
    a:=list[i];
    if IsFFE(a) then a:=Int(a);fi;
    if a=1  then
      if elm=fail then elm := basis[i];
      else elm := elm * basis[i];fi;
    elif a<> 0  then
      if elm=fail then elm := basis[i] ^ a;
      else elm := elm * basis[i] ^ a;fi;
    fi;
  od;

  if elm=fail then
    if IsPcgs(pcgs) then
      return OneOfPcgs(pcgs);
    else
      return One(pcgs[1]);
    fi;
  else
    return elm;
  fi;

end );

#############################################################################
##
#M  LinearCombinationPcgs( <pcgs>, <list> )
##
InstallGlobalFunction(LinearCombinationPcgs,function(arg)
  if Length(arg)=2 or Length(arg[1])>0 then
    return DoPcElementByExponentsGeneric(arg[1],arg[1],arg[2]);
  elif Length(arg[1])=0 then
    return arg[3];
  fi;
end);

#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <list> )
##
InstallOtherMethod( PcElementByExponentsNC,
    "generic method: call LinearCombinationPcgs",
    true,
    [ IsList, IsRowVector and IsCyclotomicCollection ], 0,
function(pcgs,list)
  return DoPcElementByExponentsGeneric(pcgs,pcgs,list);
end);

#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <ffe-list> )
##
InstallOtherMethod( PcElementByExponentsNC, "generic method", true,
    [ IsList, IsRowVector and IsFFECollection ], 0,
function( pcgs, list )
  return DoPcElementByExponentsGeneric(pcgs,pcgs,list);
end);

#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <basis>, <empty-list> )
##
InstallOtherMethod( PcElementByExponentsNC, "generic method for empty lists",
    true, [ IsPcgs, IsList and IsEmpty, IsList and IsEmpty ], 0,
function( pcgs, basis, list )
    return OneOfPcgs(pcgs);
end );


#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <basis>, <list> )
##
InstallOtherMethod( PcElementByExponentsNC,"multiply basis elements",
    IsFamFamX, [ IsPcgs, IsList, IsRowVector and IsCyclotomicCollection ], 0,
  DoPcElementByExponentsGeneric);

#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <basis>, <list> )
##
InstallOtherMethod( PcElementByExponentsNC,"multiply base elts., FFE",
    IsFamFamX, [ IsPcgs, IsList, IsRowVector and IsFFECollection ], 0,
  DoPcElementByExponentsGeneric);

#############################################################################
##
#M  PcElementByExponentsNC( <pcgs>, <basisindex>, <list> )
##
InstallOtherMethod( PcElementByExponentsNC,"index: defer to basis", true,
  [ IsModuloPcgs, IsRowVector and IsCyclotomicCollection,
    IsRowVector and IsFFECollection ], 0,
function( pcgs, ind, list )
  return DoPcElementByExponentsGeneric(pcgs,pcgs{ind},list);
end);

InstallOtherMethod( PcElementByExponentsNC,"index: defer to basis,FFE",true,
  [ IsModuloPcgs, IsRowVector and IsCyclotomicCollection,
    IsRowVector and IsCyclotomicCollection ], 0,
function( pcgs, ind, list )
  return DoPcElementByExponentsGeneric(pcgs,pcgs{ind},list);
end);


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
    "for IsPrimeOrdersPcgs using RelativeOrders",
    IsCollsElms,
    [ IsPcgs and IsPrimeOrdersPcgs,
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

InstallMethod( RelativeOrderOfPcElement,
    "general method using RelativeOrders",
    IsCollsElms,
    [ IsPcgs, IsObject ],
    0,

function( pcgs, elm )
    local   d,  e,  ro;

    d := DepthOfPcElement(pcgs,elm);
    if d > Length(pcgs)  then
         return 1;
    fi;

    e  := ExponentOfPcElement( pcgs, elm, d );
    ro := RelativeOrders(pcgs)[d];

    return ro / Gcd( e, ro );
end );


#############################################################################
##
#M  CleanedTailPcElement( <pcgs>, <elm>,<dep> )
##
InstallMethod( CleanedTailPcElement, "generic: do nothing", IsCollsElmsX,
    [ IsPcgs , IsMultiplicativeElementWithInverse, IsPosInt ], 0,
function( pcgs, elm,dep )
  return elm;
end);


#############################################################################
##
#M  SetRelativeOrders( <prime-orders-pcgs>, <orders> )
##

# the following is the system setter for `RelativeOrders'.
SET_RELATIVE_ORDERS := SETTER_FUNCTION(
    "RelativeOrders", HasRelativeOrders );


InstallMethod( SetRelativeOrders,
    "setting orders for prime orders pcgs",
    true,
    [ IsPcgs and IsComponentObjectRep and IsAttributeStoringRep and
        HasIsPrimeOrdersPcgs and HasIsFiniteOrdersPcgs,
      IsList ],
    1, #better than the following method
    # only call the system setter function
    SET_RELATIVE_ORDERS );


#############################################################################
##
#M  SetRelativeOrders( <pcgs>, <orders> )
##
InstallMethod( SetRelativeOrders,
    "setting orders and checking for prime orders",
    true,
    [ IsPcgs and IsComponentObjectRep and IsAttributeStoringRep,
      IsList ],
    0,

function( pcgs, orders )
    if not HasIsFiniteOrdersPcgs(pcgs)  then
        SetIsFiniteOrdersPcgs( pcgs,
            ForAll( orders, x -> x <> 0 and x <> infinity ) );
    fi;
    if IsFiniteOrdersPcgs(pcgs) and not HasIsPrimeOrdersPcgs(pcgs)  then
        SetIsPrimeOrdersPcgs( pcgs, ForAll( orders, IsPrimeInt ) );
    fi;
    # and call the system setter function
    SET_RELATIVE_ORDERS( pcgs, orders );
end );


#############################################################################
##
#M  SumOfPcElement( <pcgs>, <left>, <right> )
##
InstallMethod( SumOfPcElement,
    "generic methods, PcElementByExponents+ExponentsOfPcElement",
    IsCollsElmsElms,
    [ IsPcgs,
      IsObject,
      IsObject ],
    0,

function( pcgs, left, right )
    return PcElementByExponentsNC( pcgs,
        ExponentsOfPcElement(pcgs,left)+ExponentsOfPcElement(pcgs,right) );
end );


#############################################################################
##
#M  ExtendedPcgs( <N>, <no-gens> )
##
InstallMethod( ExtendedPcgs, "pcgs, empty list", true,
        [ IsPcgs, IsList and IsEmpty ], 0,
    ReturnFirst );


#############################################################################
##
#M  ExtendedIntersectionSumPcgs( <parent-pcgs>, <n>, <u>, <modpcgs> )
##
InstallMethod( ExtendedIntersectionSumPcgs,
    "generic method for modulo pcgs",
    true,
    #function(a,b,c) return IsIdenticalObj(a,b) and IsIdenticalObj(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs, IsList, IsList, IsObject ], 0,
function( pcgs, n, u, pcgsM )
    local   id,  ls,  rs,  is,  g,  z,  I,  ros,  al,  ar,  tmp,
            sum,  int;

    # set up
    id := OneOfPcgs( pcgs );

    # What  follows  is a Zassenhausalgorithm: <ls> and <rs> are the left and
    # rights  sides. They are initialized with [ n, n ] and [ u, 1 ]. <is> is
    # the  intersection.  <I>  contains  the  words  [ u, 1 ]  which  must be
    # Sifted through [ <ls>, <rs> ].

    ls := List( pcgs, x -> id );
    rs := List( pcgs, x -> id );
    is := List( pcgs, x -> id );

    for g in u do
        z := DepthOfPcElement( pcgs, g );
        ls[z] := g;
        rs[z] := g;
    od;

    I := [];
    for g in n do
        z := DepthOfPcElement( pcgs, g );
        if ls[z] = id  then
            ls[z] := g;
        else
            Add( I, g );
        fi;
    od;

    # enter the pairs [ u, 1 ] of <I> into [ <ls>, <rs> ]
    ros := RelativeOrders(pcgs);
    for al  in I  do
        ar := id;
        if IsInt(pcgsM) then
          if DepthOfPcElement(pcgs,al)>=pcgsM then
            al:=id;
          fi;
        elif not IsBool( pcgsM ) then
            al := SiftedPcElement( pcgsM, al );
        fi;
        z  := DepthOfPcElement( pcgs, al );

        # shift through and reduced from the left
        while al <> id and ls[z] <> id  do
            tmp := LeadingExponentOfPcElement( pcgs, al )
                   / LeadingExponentOfPcElement( pcgs, ls[z] )
                   mod ros[z];
            al := LeftQuotient( ls[z]^tmp, al );
            if IsInt(pcgsM) then
              if DepthOfPcElement(pcgs,al)>=pcgsM then
                al:=id;
              fi;
            elif not IsBool( pcgsM ) then
                al := SiftedPcElement( pcgsM, al );
            fi;
            ar := LeftQuotient( rs[z]^tmp, ar );
            z  := DepthOfPcElement( pcgs, al );
        od;

        # have we a new sum or intersection generator
        if al <> id  then
            ls[z] := al;
            rs[z] := ar;
        else
            z := DepthOfPcElement( pcgs, ar );
            while ar <> id and is[z] <> id  do
                ar := ReducedPcElement( pcgs, ar, is[z] );
                if IsInt(pcgsM) then
                  if DepthOfPcElement(pcgs,ar)>=pcgsM then
                    ar:=id;
                  fi;
                elif not IsBool( pcgsM ) then
                    ar := SiftedPcElement( pcgsM, ar );
                fi;
                z  := DepthOfPcElement( pcgs, ar );
            od;
            if ar <> id  then
                is[z] := ar;
            fi;
        fi;
    od;

    # Construct  the sum and intersection aggroups. Return left and right
    # sides, so one can decompose words of <N> * <U>.

    #sum := InducedPcgsByPcSequence( pcgs, Filtered( ls, x -> x <> id ) );
    #int := InducedPcgsByPcSequence( pcgs,
    #                    Filtered( is, x -> x <> id ) );
    sum := Filtered( ls, x -> x <> id );
    int := Filtered( is, x -> x <> id );

    return rec(
        leftSide     := ls,
        rightSide    := rs,
        sum          := sum,
        intersection := int );
end );


#############################################################################
##
#M  IntersectionSumPcgs( <parent-pcgs>, <n>, <u> )
##
InstallMethod( IntersectionSumPcgs,
    "using 'ExtendedIntersectionSumPcgs'",
    function(a,b,c) return IsIdenticalObj(a,b) and IsIdenticalObj(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs, IsList, IsList ], 0,
function( pcgs, n, u )
local e;
  e:=ExtendedIntersectionSumPcgs(pcgs, n, u, true);
  e.sum:=InducedPcgsByPcSequenceNC(pcgs,e.sum);
  e.intersection:=InducedPcgsByPcSequenceNC(pcgs,e.intersection);
  return e;
end );


#############################################################################
##
#M  NormalIntersectionPcgs( <parent-pcgs>, <n>, <u> )
##
InstallMethod( NormalIntersectionPcgs,
    "using 'ExtendedIntersectionSumPcgs'",
    function(a,b,c) return IsIdenticalObj(a,b) and IsIdenticalObj(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsList,
      IsList ],
    0,

function( p, n, u )
   return InducedPcgsByPcSequenceNC(p,
            ExtendedIntersectionSumPcgs(p,n,u,true).intersection);
end );


#############################################################################
##
#M  SumPcgs( <parent-pcgs>, <n>, <u> )
##
InstallMethod( SumPcgs,
    "generic method",
    function(a,b,c) return IsIdenticalObj(a,b) and IsIdenticalObj(a,c); end,
    [ IsPcgs and IsPrimeOrdersPcgs,
      IsList,
      IsList ],
    0,

function( pcgs, n, u )
    local   id,  ls,  g,  z,  I,  ros,  al,  tmp;

    if false and IsPcgs(u) and IsPcgs(n) and ParentPcgs(n)=pcgs
        and ParentPcgs(u)=pcgs then
      if ForAll(n,i->i in u) then
        return u;
      elif ForAll(u,i->i in n) then
        return n;
      fi;
    fi;

    # set up
    id := OneOfPcgs( pcgs );

    # what follows is a Zassenhausalgorithm
    ls := List( pcgs, x -> id );

    for g in u do
        z := DepthOfPcElement( pcgs, g );
        ls[z] := g;
    od;

    I := [];
    for g in n do
        z := DepthOfPcElement( pcgs, g );
        if ls[z] = id  then
            ls[z] := g;
        else
            Add( I, g );
        fi;
    od;

    # enter the elements of <I> into <ls>
    ros := RelativeOrders(pcgs);
    for al  in I  do
        z  := DepthOfPcElement( pcgs, al );

        # shift through and reduced from the left
        while al <> id and ls[z] <> id  do
            tmp := LeadingExponentOfPcElement( pcgs, al )
                   / LeadingExponentOfPcElement( pcgs, ls[z] )
                   mod ros[z];
            al := LeftQuotient( ls[z]^tmp, al );
            z  := DepthOfPcElement( pcgs, al );
        od;

        # have we a new sum or intersection generator
        if al <> id  then
            ls[z] := al;
        fi;
    od;

    return InducedPcgsByPcSequence( pcgs, Filtered( ls, x -> x <> id ) );

end );


#############################################################################
##
#M  SumFactorizationFunctionPcgs( <parent-pcgs>, <u>, <n>, <modpcgs> )
##
InstallMethod( SumFactorizationFunctionPcgs,
    "generic method",
    #function(a,b,c) return IsIdenticalObj(a,b) and IsIdenticalObj(a,c); end,
    true,
    [ IsPcgs and IsPrimeOrdersPcgs, IsList, IsList, IsObject ], 0,
function( pcgs, u, n, pcgsM )
    local   id,  S,  f;

    # do we want to prune the tails?
    if IsInt(pcgsM) and pcgsM<0 then
      pcgsM:=-pcgsM;
      # this will not affect the result -- as we have a tail we only want
      # the result modulo a normal subgroup
      u:=List(u,i->CleanedTailPcElement(pcgs,i,pcgsM));
      n:=List(n,i->CleanedTailPcElement(pcgs,i,pcgsM));
    fi;

    id := OneOfPcgs( pcgs );
    S  := ExtendedIntersectionSumPcgs( pcgs, n, u, pcgsM );

    # decomposition function
    f := function( un )
        local a, u, w, z;

        # Catch trivial case.
        if un = id  then
            return rec( u := id, n := id );
        fi;

        # Shift  through  'leftSide'  and  do  the  inverse  operations  with
        # 'rightSide'. This will give the <N> part.
        u := id;
        a := un;
        w := DepthOfPcElement( pcgs, a );
        while a <> id and S.leftSide[ w ] <> id  do
            z := LeadingExponentOfPcElement( pcgs, a )
                   / LeadingExponentOfPcElement( pcgs, S.leftSide[ w ] )
                 mod RelativeOrderOfPcElement( pcgs, a );
            a := LeftQuotient( S.leftSide[ w ] ^ z, a );
            u := u * S.rightSide[ w ] ^ z;
            w := DepthOfPcElement( pcgs, a );
        od;
        return rec( u := u, n := u^-1 * un );
    end;

    # Return the sum, intersection and the function.
    return rec( sum           := S.sum,
                intersection  := S.intersection,
                factorization := f );

end );


#############################################################################
##
#M  PcGroupWithPcgs( <pcgs> )
##
BindGlobal( "GROUP_BY_PCGS_FINITE_ORDERS", function( pcgs )
    local   f,  e,  m,  i,  type,  s,  id,  tmp,  j;

    # construct a new free group
    f := FreeGroup(IsSyllableWordsFamily, Length(pcgs) );
    e := ElementsFamily( FamilyObj(f) );

    # and a default type
    if 0 = Length(pcgs)  then
        m := 1;
    else
        m := Maximum(RelativeOrders(pcgs));
    fi;
    i := 1;
    while i < 4 and e!.expBitsInfo[i] <= m  do
        i := i + 1;
    od;
    type := e!.types[i];

    # and use a single collector
    s := SingleCollector( f, RelativeOrders(pcgs) );

    # compute the power relations
    id := pcgs!.zeroVector;
    for i  in [ 1 .. Length(pcgs) ]  do
        #tmp := pcgs[i]^RelativeOrderOfPcElement(pcgs,pcgs[i]);
        tmp := ExponentsOfRelativePower(pcgs,i);
        if tmp <> id  then
            #tmp := ExponentsOfPcElement( pcgs, tmp );
            tmp := ObjByVector( type, tmp );
            SetPowerNC( s, i, tmp );
        fi;
    od;

    # compute the conjugates
    for i  in [ 1 .. Length(pcgs) ]  do
        for j  in [ i+1 .. Length(pcgs) ]  do
            #tmp := pcgs[j] ^ pcgs[i];
            tmp := ExponentsOfConjugate(pcgs,j,i);
            if tmp <> id  then
                #tmp := ExponentsOfPcElement( pcgs, tmp );
                tmp := ObjByVector( type, tmp );
                SetConjugateNC( s, j, i, tmp );
            fi;
        od;
    od;

    # and return the new group
    return GroupByRwsNC(s);

end );


InstallMethod( PcGroupWithPcgs,
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

    tmp := GroupByGenerators( AsList( pcgs ), OneOfPcgs(pcgs) );
    if HasIsFiniteOrdersPcgs(pcgs) then
      SetIsFinite( tmp, IsFiniteOrdersPcgs(pcgs) );
    fi;
    SetPcgs(     tmp, pcgs                     );
    return tmp;
end );


#############################################################################
##
#R  IsEnumeratorByPcgsRep
##
DeclareRepresentation( "IsEnumeratorByPcgsRep",
    IsAttributeStoringRep, [ "pcgs", "sublist" ] );


#############################################################################
##
#M  EnumeratorByPcgs( <pcgs> )
##
InstallMethod( EnumeratorByPcgs,"pcgs", true, [ IsPcgs ], 0,
function( pcgs )
    return Objectify(
        NewType( FamilyObj(pcgs), IsList and IsEnumeratorByPcgsRep ),
        rec( pcgs := pcgs, sublist := [ 1 .. Length(pcgs) ],
             relativeOrders := RelativeOrders(pcgs),
             complementList := [] ) );
end );


#############################################################################
##
#M  EnumeratorByPcgs( <pcgs>, <sublist> )
##
InstallOtherMethod( EnumeratorByPcgs,"pcgs, sublist",true,[IsPcgs,IsList],0,
function( pcgs, sublist )
    return Objectify(
        NewType( FamilyObj(pcgs), IsList and IsEnumeratorByPcgsRep ),
        rec( pcgs := pcgs, sublist := sublist,
             relativeOrders := RelativeOrders(pcgs),
             complementList := Difference([1..Length(pcgs)],sublist) ) );
end );


#############################################################################
##
#M  Length( <enum-by-pcgs> )
##
InstallMethod( Length,"enum-by-pcgs", true,
    [ IsList and IsEnumeratorByPcgsRep ],
    0,
    enum -> Product(enum!.relativeOrders{enum!.sublist}) );


#############################################################################
##
#M  <enum-by-pcgs> [ <pos> ]
##
InstallMethod( \[\],"enum-by-pcgs",
    true,
    [ IsList and IsEnumeratorByPcgsRep,
      IsPosInt ],
    0,

function( enum, pos )
    local   pcgs,  elm,  i,  p;

    pcgs := enum!.pcgs;
    elm  := OneOfPcgs( pcgs );
    pos  := pos - 1;
    for i  in Reversed( enum!.sublist )  do
        p   := enum!.relativeOrders[i];
        elm := pcgs[ i ] ^ ( pos mod p ) * elm;
        pos := QuoInt( pos, p );
    od;
    return elm;
end );


#############################################################################
##
#M  Position( <enum-by-pcgs>, <elm>, <zero> )
##
InstallMethod( Position,"enum-by-pcgs",
    IsCollsElmsX,
    [ IsList and IsEnumeratorByPcgsRep,
      IsMultiplicativeElementWithInverse,
      IsZeroCyc ],
    0,

function( enum, elm, zero )
    local   pcgs,  exp,  pos,  i;

    pcgs := enum!.pcgs;
    if not elm in GroupOfPcgs (pcgs) then
       return fail;
    fi;
    exp  := ExponentsOfPcElement( pcgs, elm );
    pos  := 0;
    if ForAny( enum!.complementList, x -> 0 <> exp[x] )  then
      return fail;
    fi;
    for i  in enum!.sublist  do
      pos := pos * enum!.relativeOrders[i] + exp[i];
    od;
    Assert (1, elm = enum[pos+1], "enum-by-pcgs: wrong element found");
    return pos + 1;
end );


#############################################################################
##
#M  PositionCanonical( <enum-by-pcgs>, <elm> )
##
InstallMethod( PositionCanonical,"enum-by-pcgs",
    IsCollsElms,
    [ IsList and IsEnumeratorByPcgsRep,
      IsMultiplicativeElementWithInverse ],
    0,

function( enum, elm )
    local   pcgs,  exp,  pos,  i;


    pcgs := enum!.pcgs;
    if not elm in GroupOfPcgs (pcgs) then
       return fail;
    fi;
    exp  := ExponentsOfPcElement( pcgs, elm );
    pos  := 0;
    for i  in enum!.sublist  do
      pos := pos * enum!.relativeOrders[i] + exp[i];
    od;
    return pos + 1;
end );





#############################################################################
##
#M  IndicesNormalSteps( <pcgs> )
##
InstallMethod(IndicesNormalSteps,"generic",true, [IsPcgs],0,
function(pcgs)
local l,i;
  l:=PcSeries(pcgs);
  i:=Filtered([1..Length(l)],i->IsNormal(l[1],l[i]));
  return i;
end);



#############################################################################
##
#M  NormalSeriesByPcgs( <pcgs> )
##
InstallMethod(NormalSeriesByPcgs,"generic",true, [IsPcgs],0,
function(pcgs)
  return PcSeries(pcgs){IndicesNormalSteps(pcgs)};
end);


BindGlobal( "InstallPcgsSeriesFromIndices", function(series,indices)
  InstallMethod(series,"from indices",true,[Tester(indices) and IsPcgs],0,
  function(pcgs)
  local p,l,g,h,i,ipcgs,home;
    home:=ParentPcgs(pcgs);
    l:=indices(pcgs);
    p := GroupOfPcgs(pcgs);
    SetInducedPcgs(home,p,pcgs);
    g:=[p];
    for i in [2..Length(l)-1] do
      ipcgs:=InducedPcgsByPcSequenceNC(home,pcgs{[l[i]..Length(pcgs)]});
      h:=SubgroupByPcgs(p,ipcgs);
      SetInducedPcgs(home,h,ipcgs);
      Add(g,h);
    od;
    Add(g,TrivialSubgroup(p));
    return g;
  end);

  # for perm grps, the tail method is problematic
  InstallMethod(series,"from indices",true,
    [Tester(indices) and IsPcgs and IsPcgsPermGroupRep],0,
  function(pcgs)
  local p,l,g,h,i,ipcgs,home;
    home:=ParentPcgs(pcgs);
    l:=indices(pcgs);
    p := GroupOfPcgs(pcgs);
    SetInducedPcgs(home,p,pcgs);
    g:=[p];
    for i in [2..Length(l)-1] do
      ipcgs:=pcgs{[l[i]..Length(pcgs)]};
      h:=SubgroupNC(p,ipcgs);
      SetGroupOfPcgs (ipcgs, h);
      Add(g,h);
    od;
    Add(g,TrivialSubgroup(p));
    return g;
  end);

  InstallMethod(series,"from PcSeries",true,
    [IsPcgs and HasPcSeries and Tester(indices)],0,
  function(pcgs)
    return PcSeries(pcgs){indices(pcgs)};
  end);

  # workaround for old code
  InstallMethod(series,"compatibility only",true,
    [IsPcgs and HasIndicesNormalSteps],
     {} -> -RankFilter(HasIndicesNormalSteps),
  function(pcgs)
  local p,l,g,h,i,ipcgs,home;
    home:=ParentPcgs(pcgs);
    l:=IndicesNormalSteps(pcgs);
    Info(InfoWarning,1,
      "using (obsolete) `IndicesNormalSteps'. Might lead to problems");
    p := GroupOfPcgs(pcgs);
    SetInducedPcgs(home,p,pcgs);
    g:=[p];
    for i in [2..Length(l)-1] do
      ipcgs:=InducedPcgsByPcSequenceNC(home,pcgs{[l[i]..Length(pcgs)]});
      h:=SubgroupByPcgs(p,ipcgs);
      SetInducedPcgs(home,p,ipcgs);
      Add(g,h);
    od;
    Add(g,TrivialSubgroup(p));
    return g;
  end);

  InstallMethod(indices,"compatibility only",true,
    [IsPcgs and HasIndicesNormalSteps],
     {} -> -RankFilter(HasIndicesNormalSteps),
  function(pcgs)
  local l;
    l:=IndicesNormalSteps(pcgs);
    Info(InfoWarning,1,
      "using (obsolete) `IndicesNormalSteps'. Might lead to problems");
    return l;
  end);

end );

InstallPcgsSeriesFromIndices(EANormalSeriesByPcgs,IndicesEANormalSteps);
InstallPcgsSeriesFromIndices(ChiefNormalSeriesByPcgs,IndicesChiefNormalSteps);
InstallPcgsSeriesFromIndices(CentralNormalSeriesByPcgs,
  IndicesCentralNormalSteps);
InstallPcgsSeriesFromIndices(PCentralNormalSeriesByPcgsPGroup,
  IndicesPCentralNormalStepsPGroup);

#############################################################################
##
#M  IndicesEANormalStepsBounded( <pcgs>,<bound> )
##
InstallGlobalFunction(IndicesEANormalStepsBounded,function(pcgs,bound)
local rel,ind,gp,i,j,try;
  rel:=RelativeOrders(pcgs);
  ind:=IndicesEANormalSteps(pcgs);
  gp:=GroupOfPcgs(pcgs);
  i:=2;
  while i<=Length(ind) do
    if rel[ind[i-1]]^(ind[i]-ind[i-1])>bound then
      # too large, try to make smaller while keeping pcgs
      j:=ind[i-1]+1;
      try:=true;
      while try and j<ind[i] do
        if IsNormal(gp,SubgroupByPcgs(gp,
          InducedPcgsByPcSequenceNC(pcgs,pcgs{[j..Length(pcgs)]}))) then
          # found normal in between
          ind:=Concatenation(ind{[1..i-1]},[j],ind{[i..Length(ind)]});
          try:=false;
        else
          j:=j+1;
        fi;
      od;
      if try then i:=i+1;fi;
    else
      i:=i+1;
    fi;
  od;
  return ind;
end);

#############################################################################
##
#M  BoundedRefinementEANormalSeries( <home>,<bound> )
##
## try to make series factors smaller, even if at cost of changing pcgs
InstallGlobalFunction(BoundedRefinementEANormalSeries,function(home,ind,bound)
local pcgs,rel,gp,i,indp,inds,module,sub;
  pcgs:=home;
  rel:=RelativeOrders(pcgs);
  gp:=GroupOfPcgs(pcgs);
  i:=2;
  while i<=Length(ind) do
    if rel[ind[i-1]]^(ind[i]-ind[i-1])>bound then
      # too large, try to find submodule
      indp:=InducedPcgsByPcSequenceNC(pcgs,pcgs{[ind[i-1]..Length(pcgs)]});
      inds:=indp
        mod InducedPcgsByPcSequenceNC(pcgs,pcgs{[ind[i]..Length(pcgs)]});
      module:=GModuleByMats(LinearActionLayer(gp,inds),GF(rel[ind[i-1]]));
      if not MTX.IsIrreducible(module) then
        # the subbasis will be part of the pcgs
        sub:=MTX.Subbasis(module);
        sub:=List(sub,x->PcElementByExponentsNC(inds,x));
        Append(sub,pcgs{[ind[i]..Length(pcgs)]});
        sub:=InducedPcgsByPcSequenceNC(pcgs,sub);
        sub:=CanonicalPcgs(sub);
        inds:=indp mod sub;
        if Length(inds)=0 then Error("EE");fi;
        # make new pcgs indices, relative orders stay the same
        pcgs:=Concatenation(pcgs{[1..ind[i-1]-1]},inds!.pcSequence,sub);
        pcgs:=PcgsByPcSequence(ElementsFamily(FamilyObj(home)),pcgs);
        ind:=Concatenation(ind{[1..i-1]},[ind[i-1]+Length(inds)],
          ind{[i..Length(ind)]});
        SetIndicesChiefNormalSteps(pcgs,ind);
      else
        i:=i+1; # cannot do
        SetIndicesChiefNormalSteps(pcgs,ind);
      fi;
    else
      i:=i+1;
    fi;
  od;
  return [pcgs,ind];
end);



#############################################################################
##
#M  IsPcgsElementaryAbelianSeries( <pcgs> )
##
InstallMethod(IsPcgsElementaryAbelianSeries,"test if elm. abelian",true,
  [IsPcgs],0,
function(p)
local n, o, j, i, d, ro, n2, ea, ran;
  if HasIndicesEANormalSteps(p) then
    n:=IndicesEANormalSteps(p); # get the indices stored already
  else
    n:=[Length(p)+1];
    o:=Length(p); # next attempted normal level
    j:=o; # generator currently conjugated
    while j>0 do
      repeat
        i:=1; # conjugating generator
        while i<o do
          d:=DepthOfPcElement(p,p[j]^p[i]);
          if d<o then
            # NT is larger than expected
            o:=d;
          fi;
          i:=i+1;
        od;
        j:=j-1;
      until j<o;
      # we've found another normal step
      Add(n,o);
      o:=j;
    od;
    n:=Reversed(n);
  fi;
  ro:=RelativeOrders(p);
  n2:=[1];
  i:=1;
  while i<=Length(n)-1 do
    # test el ab and whether we can make it coarser
    j:=i;
    ea:=true;
    repeat
      j:=j+1;
      ran:=[n[i]..n[j]-1]; #pcgs range
      o:=Set(ro{ran});
      if Length(o)>1 then
        ea:=false; # could this ever happen anyhow?
      fi;
      o:=o[1];
      if ForAny(p{ran},x->DepthOfPcElement(p,x^o)<n[j]) then
        ea:=false; # not exponent p
      fi;
      if ForAny(p{ran},
                k->ForAny(p{ran},x->DepthOfPcElement(p,Comm(x,k))<n[j])) then
        ea:=false; # not abelian
      fi;
    until ea=false or j=Length(n);
    if ea=false then
      j:=j-1; # last ea step
      if j=i then
        return false; # not EA series, even first step failed.
      fi;
      Add(n2,n[j]);
      i:=j;
    else
      Add(n2,n[j]);
      i:=j+1;
    fi;
  od;

  SetIndicesEANormalSteps(p,n);
  return true;
end);

InstallGlobalFunction(LiftedPcElement,function(new,old,elm)
local e;
  e:=ShallowCopy(new!.zeroVector);
  e{[1..Length(old)]}:=ExponentsOfPcElement(old,elm);
  return PcElementByExponentsNC(new,e);
end);

InstallGlobalFunction(ProjectedPcElement,function(old,new,elm)
  return PcElementByExponentsNC(new,ExponentsOfPcElement(old,elm)
                                      {[1..Length(new)]});
end);

InstallGlobalFunction(ProjectedInducedPcgs,function(old,new,pcgs)
local p,i,e;
  p:=[];
  for i in pcgs!.pcSequence do
    e:=ProjectedPcElement(old,new,i);
    if not IsOne(e) then
      Add(p,e);
    fi;
  od;
  return InducedPcgsByPcSequenceNC(new,p);
end);

InstallGlobalFunction(LiftedInducedPcgs,function(new,old,pcgs,ker)
local p,i;
  p:=[];
  for i in pcgs do
    Add(p,LiftedPcElement(new,old,i));
  od;
  return InducedPcgsByPcSequenceNC(new,Concatenation(p,ker));
end);

#############################################################################
##
#M  IsPcgsElementaryAbelianSeries( <pcgs> )
##
BindGlobal("DoPcgsElementaryAbelianSeries",function(param)
local G,e,ind,s,m,i,p;
  if IsList(param) then
    G:=param[1];
    if HasPcgsElementaryAbelianSeries(G) then
      # can we use the known pcgs?
      p:=PcgsElementaryAbelianSeries(G);
      e:=EANormalSeriesByPcgs(p);
      if ForAll(param,i->i in e) then
        return p;
      fi;
    fi;
  else
    G:=param;
  fi;
  if not IsSolvableGroup(G) then
    Error("<G> must be solvable");
  fi;
  IsFinite(G); # trigger finiteness test
  e:=ElementaryAbelianSeriesLargeSteps(param);
  ind:=[];
  s:=[];
  for i in [1..Length(e)-1] do
    m:=ModuloPcgs(e[i],e[i+1]);
    Add(ind,Length(s)+1);
    Append(s,m);
  od;
  Add(ind,Length(s)+1);
  p:=PcgsByPcSequence(FamilyObj(One(G)),s);
  SetIsPcgsElementaryAbelianSeries(p,true);
  SetIsPrimeOrdersPcgs(p,true);
  SetIndicesEANormalSteps(p,ind);
  SetEANormalSeriesByPcgs(p,e);
  return p;
end);

#############################################################################
##
#M  PcgsElementaryAbelianSeries( <G> )
##
InstallMethod( PcgsElementaryAbelianSeries, "generic group", true, [ IsGroup ],
  1, # rank higher than package method to make behavior more predictable
  DoPcgsElementaryAbelianSeries);

InstallOtherMethod( PcgsElementaryAbelianSeries, "group list", true,
  [ IsList ], 0, DoPcgsElementaryAbelianSeries);


#############################################################################
##
#R  IsPcgsByPcgsRep
##
##  representation for a pcgs that calculates exponents wrt. one pcgs and
##  then determines the desired exponents in a shadowing pc group
##
DeclareRepresentation( "IsPcgsByPcgsRep",
    IsPcgsDefaultRep and IsFiniteOrdersPcgs, [ "usePcgs",
    "shadowFamilyPcgs", "shadowImagePcgs" ] );

InstallGlobalFunction(PcgsByPcgs,function(gens,use,family,images)
local pcgs;

  pcgs:=PcgsByPcSequenceCons(IsPcgsDefaultRep,
    IsPcgsByPcgsRep and IsPcgs and IsPrimeOrdersPcgs,
    FamilyObj(gens[1]),gens,[]);
  pcgs!.usePcgs:=use;
  pcgs!.shadowFamilyPcgs:=family;
  pcgs!.shadowImagePcgs:=images;
  SetRelativeOrders(pcgs,RelativeOrders(images));
  return pcgs;
end);

InstallMethod(ExponentsOfPcElement,"pcgs by pcgs",IsCollsElms,
  [IsPcgsByPcgsRep and IsPcgs,IsObject],
function(pcgs,elm)
local e;
  e:=ExponentsOfPcElement(pcgs!.usePcgs,elm);
  e:=PcElementByExponentsNC(pcgs!.shadowFamilyPcgs,e);
  e:=ExponentsOfPcElement(pcgs!.shadowImagePcgs,e);
  return e;
end);

InstallMethod(DepthOfPcElement,"pcgs by pcgs",IsCollsElms,
  [IsPcgsByPcgsRep and IsPcgs,IsObject],
function(pcgs,elm)
local e;
  e:=ExponentsOfPcElement(pcgs!.usePcgs,elm);
  e:=PcElementByExponentsNC(pcgs!.shadowFamilyPcgs,e);
  e:=DepthOfPcElement(pcgs!.shadowImagePcgs,e);
  return e;
end);
