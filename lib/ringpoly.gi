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
##  This file contains the methods  for attributes, properties and operations
##  for polynomial rings and function fields.
##


#############################################################################
##
#M  GiveNumbersNIndeterminates(<ratfunfam>,<count>,<names>,<avoid>)
BindGlobal("GiveNumbersNIndeterminates",function(rfam,cnt,nam,avoid)
local reuse, idn, nbound, p, i,str;
  reuse:=true;
  # TODO: The following check could be simplified if we are willing to
  # change semantics of the options "new" and "old" a bit: Currently,
  # "old" has precedence, which is the why this check is a bit more
  # complicated than one might expect. But perhaps we would like to
  # get rid of option "old" completely?
  if ValueOption("old")<>true and ValueOption("new")=true then
    reuse:=false;
  fi;

  #avoid:=List(avoid,IndeterminateNumberOfLaurentPolynomial);
  avoid:=ShallowCopy(avoid);
  for i in [1..Length(avoid)] do
    if not IsInt(avoid[i]) then
      avoid[i]:=IndeterminateNumberOfLaurentPolynomial(avoid[i]);
    fi;
  od;
  idn:=[];
  i:=1;
  while Length(idn)<cnt do
    nbound:=IsBound(nam[Length(idn)+1]);
    if nbound then
      str:=nam[Length(idn)+1];
    else
      str:=fail;
    fi;
    if nbound and Length(str)>2 and str[1]='x' and str[2]='_'
     and ForAll(str{[3..Length(str)]},IsDigitChar) then
      p:=Int(str{[3..Length(str)]});
      if IsPosInt(p) then
        Add(idn,p);
      else
        p:=fail;
      fi;
    elif nbound and reuse and IsBound(rfam!.namesIndets) then
      # is the indeterminate already used?
      atomic rfam!.namesIndets do # for HPC-GAP only; ignored in GAP
      p:=Position(rfam!.namesIndets,str);
      if p<>fail then
        if p in avoid then
          Info(InfoWarning,1,
  "A variable with the name '", str, "' already exists, yet the variable\n",
  "#I  with this name was explicitly to be avoided. I will create a\n",
  "#I  new variables with the same name.");

          p:=fail;
        else
          # reuse the old variable
          Add(idn,p);
        fi;
      fi;
      od; # end of atomic
    else
      p:=fail;
    fi;

    if p=fail then
      # skip unwanted indeterminates
      while (i in avoid) or (nbound and HasIndeterminateName(rfam,i)) do
        i:=i+1;
      od;
      Add(idn,i);

      if nbound then
        SetIndeterminateName(rfam,i,str);
      fi;
    fi;
    i:=i+1;
  od;
  return idn;
end);

#############################################################################
##
#M  PolynomialRing( <ring>, <rank> )  . . .  full polynomial ring over a ring
##
#T polynomial rings should be special cases of free magma rings!  one needs
#T to set an underlying magma with one, and modify the type to be
#T AlgebraWithOne and FreeMagmaRingWithOne.  (for example, ring generators in
#T the case of polynomial rings over finite fields are then automatically
#T computable ...)
##

#############################################################################
InstallMethod( PolynomialRing,"indetlist", true, [ IsRing, IsList ],
# force higher ranking than following (string) method
  1,
function( r, n )
    local   efam,  rfun,  zero,  one,  ind,  i,  type,  prng;

    if IsPolynomialFunctionCollection(n) and ForAll(n,IsLaurentPolynomial) then
      n:=List(n,IndeterminateNumberOfLaurentPolynomial);
    fi;
    if IsEmpty(n) or not IsInt(n[1]) then
      TryNextMethod();
    fi;

    # get the elements family of the ring
    efam := ElementsFamily( FamilyObj(r) );

    # get the rational functions of the elements family
    rfun := RationalFunctionsFamily(efam);

    # cache univariate rings - they might be created often
    if not IsBound(r!.univariateRings) then
      if IsHPCGAP then
        r!.univariateRings:=MakeWriteOnceAtomic([]);
      else
        r!.univariateRings:=[];
      fi;
    fi;

    if Length(n)=1
      # some bozo might put in a ridiculous number
      and n[1]<10000
      # only cache for the prime field
      and IsField(r)
      and IsBound(r!.univariateRings[n[1]]) then
      return r!.univariateRings[n[1]];
    fi;

    # first the indeterminates
    zero := Zero(r);
    one  := One(r);
    ind  := [];
    for i  in n  do
        Add( ind, UnivariatePolynomialByCoefficients(efam,[zero,one],i) );
    od;

    # construct a polynomial ring
    type := IsPolynomialRing and IsAttributeStoringRep and IsFreeLeftModule;
    # over a field the ring should be an algebra with one.
    if HasIsField(r) and IsField(r)  then
      type:=type and IsAlgebraWithOne;
    elif HasIsRingWithOne(r) and IsRingWithOne(r) then
      type:=type and IsRingWithOne;
    fi;

    if Length(n) = 1 and HasIsField(r) and IsField(r)  then
        type := type and IsUnivariatePolynomialRing and IsEuclideanRing;
                     #and IsAlgebraWithOne; # done above already
    elif Length(n) = 1 and IsRingWithOne(r) then
        type := type and IsUnivariatePolynomialRing and IsFLMLORWithOne;
    elif Length(n) = 1  then
        type := type and IsUnivariatePolynomialRing;
    fi;

    # Polynomial rings over commutative rings are themselves commutative.
    if HasIsCommutative( r ) and IsCommutative( r ) then
      type:= type and IsCommutative;
    fi;

    # Polynomial rings over commutative rings are themselves commutative.
    if HasIsAssociative( r ) and IsAssociative( r ) then
      type:= type and IsAssociative;
    fi;

    # set categories to allow method selection according to base ring
    if HasIsField(r) and IsField(r) then
        if IsFinite(r) then
            type := type and IsFiniteFieldPolynomialRing;
          if IsAlgebraicExtension(r) then
            type:= type and IsAlgebraicExtensionPolynomialRing;
          fi;
        elif IsRationals(r) then
            type := type and IsRationalsPolynomialRing;
        elif # catch algebraic extensions
          IsIdenticalObj(One(r),1) and IsAbelianNumberField( r ) then
          type:= type and IsAbelianNumberFieldPolynomialRing;
        elif IsAlgebraicExtension(r) then
          type:= type and IsAlgebraicExtensionPolynomialRing;
        fi;
    fi;
    prng := Objectify( NewType( CollectionsFamily(rfun), type ), rec() );

    # set the left acting domain
    SetLeftActingDomain( prng, r );

    # set the indeterminates
    SetIndeterminatesOfPolynomialRing( prng, ind );

    # set known properties
    SetIsFinite( prng, false );
    SetIsFiniteDimensional( prng, false );
    SetSize( prng, infinity );

    # set the coefficients ring
    SetCoefficientsRing( prng, r );

    # set one and zero
    SetOne(  prng, ind[1]^0 );
    SetZero( prng, ind[1]*Zero(r) );

    # set the generators left operator ring-with-one if the rank is one
    if IsRingWithOne(r) then
        SetGeneratorsOfLeftOperatorRingWithOne( prng, ind );
    fi;


    if Length(n)=1 and n[1]<10000
      # only cache for the prime field
      and IsField(r) then
      r!.univariateRings[n[1]]:=prng;
    fi;

    # and return
    return prng;

end );

InstallMethod( PolynomialRing,"name",true, [ IsRing, IsString ], 0,
function( r, nam )
  return PolynomialRing( r, [nam]);
end );

InstallMethod( PolynomialRing,"names",true, [ IsRing, IsList ], 0,
function( r, nam )
  if not IsString(nam[1]) then
    TryNextMethod();
  fi;
  return PolynomialRing( r, GiveNumbersNIndeterminates(
            RationalFunctionsFamily(ElementsFamily(FamilyObj(r))),
                                     Length(nam),nam,[]));
end );


InstallMethod( PolynomialRing,"rank",true, [ IsRing, IsPosInt ], 0,
function( r, n )
  return PolynomialRing( r, [ 1 .. n ] );
end );

InstallOtherMethod( PolynomialRing,"rank,avoid",true,
  [ IsRing, IsPosInt,IsList ], 0,
function( r, n,a )
  return PolynomialRing( r, GiveNumbersNIndeterminates(
           RationalFunctionsFamily(ElementsFamily(FamilyObj(r))),n,[],a));
end );

InstallOtherMethod(PolynomialRing,"names,avoid",true,[IsRing,IsList,IsList],0,
function( r, nam,a )
  return PolynomialRing( r, GiveNumbersNIndeterminates(
            RationalFunctionsFamily(ElementsFamily(FamilyObj(r))),
                                     Length(nam),nam,a));
end );


#############################################################################
InstallOtherMethod( PolynomialRing,
    true,
    [ IsRing ],
    0,

function( r )
    return PolynomialRing(r,[1]);
end );


#############################################################################
##
#M  UnivariatePolynomialRing( <ring> )  . .  full polynomial ring over a ring
##
InstallMethod( UnivariatePolynomialRing,"indet 1", true, [ IsRing ], 0,
function( r )
  return PolynomialRing( r, [1] );
end );

InstallOtherMethod(UnivariatePolynomialRing,"indet number",true,
  [ IsRing,IsPosInt ], 0,
function( r,n )
  return PolynomialRing( r, [n] );
end );

InstallOtherMethod(UnivariatePolynomialRing,"name",true,
  [ IsRing,IsString], 0,
function( r,n )
  if not IsString(n) then
    TryNextMethod();
  fi;
  return PolynomialRing( r, GiveNumbersNIndeterminates(
            RationalFunctionsFamily(ElementsFamily(FamilyObj(r))),1,[n],[]));
end);

InstallOtherMethod(UnivariatePolynomialRing,"avoid",true,
  [ IsRing,IsList], 0,
function( r,a )
  if not IsRationalFunction(a[1]) then
    TryNextMethod();
  fi;
  return PolynomialRing( r, GiveNumbersNIndeterminates(
            RationalFunctionsFamily(ElementsFamily(FamilyObj(r))),1,[],a));
end);

InstallOtherMethod(UnivariatePolynomialRing,"name,avoid",true,
  [ IsRing,IsString,IsList], 0,
function( r,n,a )
  if not IsString(n[1]) then
    TryNextMethod();
  fi;
  return PolynomialRing( r, GiveNumbersNIndeterminates(
            RationalFunctionsFamily(ElementsFamily(FamilyObj(r))),1,[n],a));
end);

#############################################################################
##
#M  ViewString( <pring> ) . . . . . . . . . . . . . . . for a polynomial ring
##
InstallMethod( ViewString,
               "for a polynomial ring", true,  [ IsPolynomialRing ], 0,

  R -> Concatenation(ViewString(LeftActingDomain(R)),
                     Filtered(String(IndeterminatesOfPolynomialRing(R)),
                              ch -> ch <> ' ')) );

#############################################################################
##
#M  ViewObj( <pring> ) . . . . . . . . . . . . . . . .  for a polynomial ring
##
InstallMethod( ViewObj,
              "for a polynomial ring", true, [ IsPolynomialRing ],
              # override the higher ranking FLMLOR method
              {} -> RankFilter(IsFLMLOR),

  function( R )
    Print(ViewString(R));
  end );

#############################################################################
##
#M  String( <pring> ) . . . . . . . . . . . . . . . . . for a polynomial ring
##
InstallMethod( String,
               "for a polynomial ring", true, [ IsPolynomialRing ],
               {} -> RankFilter(IsFLMLOR),
               R -> Concatenation("PolynomialRing( ",
                                   String(LeftActingDomain(R)),", ",
                                   String(IndeterminatesOfPolynomialRing(R)),
                                  " )") );

#############################################################################
##
#M  PrintObj( <pring> )
##
InstallMethod( PrintObj,
    "for a polynomial ring",
    true,
    [ IsPolynomialRing ],
    # override the higher ranking FLMLOR method
    {} -> RankFilter(IsFLMLOR),

function( obj )
local i,f;
    Print( "PolynomialRing( ", LeftActingDomain( obj ), ", [");
    f:=false;
    for i in IndeterminatesOfPolynomialRing(obj) do
      if f then Print(", ");fi;
      Print("\"",i,"\"");
      f:=true;
    od;
    Print("] )" );
end );


#############################################################################
##
#M  Indeterminate( <ring>,<nr> )
##
InstallMethod( Indeterminate,"number", true, [ IsRing,IsPosInt ],0,
function( r,n )
  return UnivariatePolynomialByCoefficients(ElementsFamily(FamilyObj(r)),
           [Zero(r),One(r)],n);
end);

InstallOtherMethod(Indeterminate,"fam,number",true,[IsFamily,IsPosInt],0,
function(fam,n)
  return UnivariatePolynomialByCoefficients(fam,[Zero(fam),One(fam)],n);
end);

InstallOtherMethod( Indeterminate,"number 1", true, [ IsRing ],0,
function( r )
  return UnivariatePolynomialByCoefficients(ElementsFamily(FamilyObj(r)),
           [Zero(r),One(r)],1);
end);

InstallOtherMethod( Indeterminate,"number, avoid", true, [ IsRing,IsList ],0,
function( r,a )
  if not IsRationalFunction(a[1]) then
    TryNextMethod();
  fi;
  r:=ElementsFamily(FamilyObj(r));
  return UnivariatePolynomialByCoefficients(r,[Zero(r),One(r)],
          GiveNumbersNIndeterminates(RationalFunctionsFamily(r),1,[],a)[1]);
end);

InstallOtherMethod( Indeterminate,"number, name", true, [ IsRing,IsString ],0,
function( r,n )
  if not IsString(n) then
    TryNextMethod();
  fi;
  r:=ElementsFamily(FamilyObj(r));
  return UnivariatePolynomialByCoefficients(r,[Zero(r),One(r)],
          GiveNumbersNIndeterminates(RationalFunctionsFamily(r),1,[n],[])[1]);
end);

InstallOtherMethod( Indeterminate,"number, name, avoid",true,
  [ IsRing,IsString,IsList ],0,
function( r,n,a )
  if not IsString(n) then
    TryNextMethod();
  fi;
  r:=ElementsFamily(FamilyObj(r));
  return UnivariatePolynomialByCoefficients(r,[Zero(r),One(r)],
          GiveNumbersNIndeterminates(RationalFunctionsFamily(r),1,[n],a)[1]);
end);

#############################################################################
##
#M  \.   Access to indeterminates
##
InstallMethod(\.,"polynomial ring indeterminates",true,[IsPolynomialRing,IsPosInt],
function(r,n)
local v, fam, a, i;
  v:=IndeterminatesOfPolynomialRing(r);
  n:=NameRNam(n);
  if ForAll(n,i->i in CHARS_DIGITS) then
    # number
    n:=Int(n);
    if Length(v)>=n then
      return v[n];
    fi;
  else
    fam:=ElementsFamily(FamilyObj(r));
    for i in v do
      a:=IndeterminateNumberOfLaurentPolynomial(i);
      if HasIndeterminateName(fam,a) and IndeterminateName(fam,a)=n then
        return i;
      fi;
    od;
  fi;
  TryNextMethod();
end);

#############################################################################
##
#M  <poly> in <polyring>
##
InstallMethod( \in,
    "polynomial in polynomial ring",
    IsElmsColls,
    [ IsPolynomialFunction,
      IsPolynomialRing ],
    0,

function( p, R )
    local   ext,  crng,  inds,  exp,  i;

    # <p> must at least be a polynomial
    if not IsPolynomial(p)  then
        return false;
    fi;

    # get the external representation
    ext := ExtRepPolynomialRatFun(p);

    # and the indeterminates and coefficients ring of <R>
    crng := CoefficientsRing(R);
    inds := Set( IndeterminatesOfPolynomialRing(R),
                       x -> ExtRepPolynomialRatFun(x)[1][1] );

    # first check the indeterminates
    for exp  in ext{[ 1, 3 .. Length(ext)-1 ]}  do
        for i  in exp{[ 1, 3 .. Length(exp)-1 ]}  do
            if not i in inds  then
                return false;
            fi;
        od;
    od;

    # then the coefficients
    for i  in ext{[ 2, 4 .. Length(ext) ]}  do
        if not i in crng  then
            return false;
        fi;
    od;
    return true;

end );

#############################################################################
##
#M  IsSubset(<polring>,<collection>)
##
InstallMethod(IsSubset,
    "polynomial rings",
    IsIdenticalObj,
    [ IsPolynomialRing,IsCollection ],
    100, # rank higher than FLMOR method
function(R,C)
  if IsPolynomialRing(C) then
    if not IsSubset(LeftActingDomain(R),LeftActingDomain(C)) then
      return false;
    fi;
    return IsSubset(R,IndeterminatesOfPolynomialRing(C));
  fi;
  if not IsPlistRep(C) or (HasIsFinite(C) and IsFinite(C)) then
    TryNextMethod();
  fi;
  return ForAll(C,x->x in R);
end);


#############################################################################
##
#M  DefaultRingByGenerators( <gens> )   . . . .  ring containing a collection
##
InstallMethod( DefaultRingByGenerators,
    true,
    [ IsRationalFunctionCollection ],
    0,

function( ogens )
    local   gens,ind,  cfs,  g,  ext,  exp,  i,univ;

    if not ForAll( ogens, IsPolynomial )  then
        TryNextMethod();
    fi;
    # the indices of the non-constant functions that have an indeterminate
    # number
    g:=Filtered([1..Length(ogens)],
      i->HasIndeterminateNumberOfUnivariateRationalFunction(ogens[i]) and
         HasCoefficientsOfLaurentPolynomial(ogens[i]));

    univ:=Filtered(ogens{g},
             i->DegreeOfUnivariateLaurentPolynomial(i)>=0 and
                DegreeOfUnivariateLaurentPolynomial(i)<>DEGREE_ZERO_LAURPOL);

    gens:=ogens{Difference([1..Length(ogens)],g)};

    # univariate indeterminates set
    ind := Set(univ,IndeterminateNumberOfUnivariateRationalFunction);
    cfs := []; # univariate coefficients set
    for g in univ do
      UniteSet(cfs,CoefficientsOfUnivariateLaurentPolynomial(g)[1]);
    od;

    # the nonunivariate ones
    for g  in gens  do
        ext := ExtRepPolynomialRatFun(g);
        for exp  in ext{[ 1, 3 .. Length(ext)-1 ]}  do
            for i  in exp{[ 1, 3 .. Length(exp)-1 ]}  do
                AddSet( ind, i );
            od;
        od;
        for i  in ext{[ 2, 4 .. Length(ext) ]}  do
            Add( cfs, i );
        od;
    od;

    if Length(cfs)=0 then
      # special case for zero polynomial
      Add(cfs,Zero(CoefficientsFamily(FamilyObj(ogens[1]))));
    fi;

    if Length(ind)=0 then
      # this can only happen if the polynomials are constant. Enforce Index 1
      return PolynomialRing( DefaultField(cfs), [1] );
    else
      return PolynomialRing( DefaultField(cfs), ind );
    fi;
end );

#############################################################################
##
#M  PseudoRandom
##
InstallMethod(PseudoRandom,"polynomial ring",true,
    [IsPolynomialRing],0,
function(R)
  local inds, F, n, nrterms, degbound, ran, p, m, i, j;
  inds:=IndeterminatesOfPolynomialRing(R);
  F:=LeftActingDomain(R);
  if IsFinite(inds) then
    n:=Length(inds);
  else
    n:=1000;
  fi;
  nrterms:=20+Random(-19,100+n);
  degbound:=RootInt(nrterms,n)+3;
  ran:=Concatenation([0,0],[0..degbound]);
  p:=Zero(R);
  for i in [1..nrterms] do
    m:=One(R);
    for j in inds do
      m:=m*j^Random(ran);
    od;
    p:=p+Random(F)*m;
  od;
  return p;
end);

#############################################################################
##
#M  MinimalPolynomial( <ring>, <elm> )
##
InstallOtherMethod( MinimalPolynomial,"supply indeterminate 1",
    [ IsRing, IsMultiplicativeElement and IsAdditiveElement ],
function(r,e)
  return MinimalPolynomial(r,e,1);
end);


#############################################################################
##
#M  StandardAssociateUnit( <pring>, <upol> )
##
InstallMethod(StandardAssociateUnit,
  "for a polynomial ring and a polynomial",
  IsCollsElms,
  [IsPolynomialRing, IsPolynomial],
function(R,f)
  local c;
  c:=LeadingCoefficient(f);
  return StandardAssociateUnit(CoefficientsRing(R),c) * One(R);
end);

InstallMethod(FunctionField,"indetlist",true,[IsRing,IsList],
# force higher ranking than following (string) method
  1,
function(r,n)
  local efam,rfun,zero,one,ind,type,fcfl,i;
  if not IsIntegralRing(r) then
    Error("function fields can only be generated over integral rings");
  fi;
  if IsRationalFunctionCollection(n) and ForAll(n,IsLaurentPolynomial) then
    n:=List(n,IndeterminateNumberOfLaurentPolynomial);
  fi;
  if IsEmpty(n) or not IsInt(n[1]) then
    TryNextMethod();
  fi;

  # get the elements family of the ring
  efam := ElementsFamily(FamilyObj(r));

  # get the rational functions of the elements family
  rfun := RationalFunctionsFamily(efam);

  # first the indeterminates
  zero := Zero(r);
  one  := One(r);
  ind  := [];
  for i  in n  do
    Add(ind,UnivariatePolynomialByCoefficients(efam,[zero,one],i));
  od;

  # construct a polynomial ring
  type := IsFunctionField and IsAttributeStoringRep and IsLeftModule
          and IsAlgebraWithOne;

  fcfl := Objectify(NewType(CollectionsFamily(rfun),type),rec());;

  # The function field is commutative if and only if the coefficient ring is.
  if HasIsCommutative(r) then
    SetIsCommutative(fcfl, IsCommutative(r));
  fi;
  # ... same for associative ...
  if HasIsAssociative(r) then
    SetIsAssociative(fcfl, IsAssociative(r));
  fi;

  # set the left acting domain
  SetLeftActingDomain(fcfl,r);

  # set the indeterminates
  Setter(IndeterminatesOfFunctionField)(fcfl,ind);

  # set known properties
  SetIsFiniteDimensional(fcfl,false);
  SetSize(fcfl,infinity);

  # set the coefficients ring
  SetCoefficientsRing(fcfl,r);

  # set one and zero
  SetOne( fcfl,ind[1]^0);
  SetZero(fcfl,ind[1]*Zero(r));

  # set the generators left operator ring-with-one if the rank is one
  SetGeneratorsOfLeftOperatorRingWithOne(fcfl,ind);

  # and return
  return fcfl;

end);

InstallMethod(FunctionField,"names",true,[IsRing,IsList],0,
function(r,nam)
  if not IsString(nam[1]) then
    TryNextMethod();
  fi;
  return FunctionField(r,GiveNumbersNIndeterminates(
            RationalFunctionsFamily(ElementsFamily(FamilyObj(r))),
                                     Length(nam),nam,[]));
end);


InstallMethod(FunctionField,"rank",true,[IsRing,IsPosInt],0,
function(r,n)
  return FunctionField(r,[1 .. n]);
end);

InstallOtherMethod(FunctionField,"rank,avoid",true,
  [IsRing,IsPosInt,IsList],0,
function(r,n,a)
  return FunctionField(r,GiveNumbersNIndeterminates(
           RationalFunctionsFamily(ElementsFamily(FamilyObj(r))),n,[],a));
end);

InstallOtherMethod(FunctionField,"names,avoid",true,[IsRing,IsList,IsList],0,
function(r,nam,a)
  return FunctionField(r,GiveNumbersNIndeterminates(
            RationalFunctionsFamily(ElementsFamily(FamilyObj(r))),
                                     Length(nam),nam,a));
end);


#############################################################################
InstallOtherMethod(FunctionField,
    true,
    [IsRing],
    0,

function(r)
    return FunctionField(r,[1]);
end);

#############################################################################
##
#M  ViewObj(<fctfld>)
##
InstallMethod(ViewObj,"for function field",true,[IsFunctionField],
    # override the higher ranking FLMLOR method
    {} -> RankFilter(IsFLMLOR),
function(obj)
    Print("FunctionField(...,",
        IndeterminatesOfFunctionField(obj),")");
end);


#############################################################################
##
#M  PrintObj(<fctfld>)
##
InstallMethod(PrintObj,"for a function field",true,[IsFunctionField],
    # override the higher ranking FLMLOR method
    {} -> RankFilter(IsFLMLOR),
function(obj)
local i,f;
    Print("FunctionField(",LeftActingDomain(obj),",[");
    f:=false;
    for i in IndeterminatesOfFunctionField(obj) do
      if f then Print(",");fi;
      Print("\"",i,"\"");
      f:=true;
    od;
    Print("])");
end);

#############################################################################
##
#M  <ratfun> in <ffield>
##
InstallMethod(\in,"ratfun in fctfield",IsElmsColls,
    [IsRationalFunction,IsFunctionField],0,
function(f,R)
  local crng,inds,ext,exp,i;

  # and the indeterminates and coefficients ring of <R>
  crng := CoefficientsRing(R);
  inds := Set(IndeterminatesOfFunctionField(R),
                      x -> ExtRepPolynomialRatFun(x)[1][1]);

  for ext in [ExtRepNumeratorRatFun(f),ExtRepDenominatorRatFun(f)] do
    # first check the indeterminates
    for exp  in ext{[1,3 .. Length(ext)-1]}  do
      for i  in exp{[1,3 .. Length(exp)-1]}  do
        if not i in inds  then
          return false;
        fi;
      od;
    od;

    # then the coefficients
    for i  in ext{[2,4 .. Length(ext)]}  do
      if not i in crng  then
        return false;
      fi;
    od;
  od;
  return true;

end);

# homomorphisms -- cf alghom.gi

BindGlobal("PolringHomPolgensSetup",function(map)
local gi,p;
  if not IsBound(map!.polgens) then
    gi:=MappingGeneratorsImages(map);
    p:=Filtered([1..Length(gi[1])],x->gi[1][x] in
        IndeterminatesOfPolynomialRing(Source(map)));
    map!.polgens:=[gi[1]{p},gi[2]{p}];
  fi;
end);

#############################################################################
##
#M  ImagesRepresentative( <map>, <elm> )  . . . . . . .  for polring g.m.b.i.
##
InstallMethod( ImagesRepresentative,
    "for polring g.m.b.i., and element",
    FamSourceEqFamElm,
    [ IsGeneralMapping and IsPolynomialRingDefaultGeneratorMapping,
      IsObject ],
    function( map, elm )
    local gi;
      PolringHomPolgensSetup(map);
      gi:=map!.polgens;
      return Value(elm,gi[1],gi[2],One(Range(map)));
    end );

#############################################################################
##
#M  ImagesSet( <map>, <r> )  . . . . . . .  for polring g.m.b.i.
##
InstallMethod( ImagesSet,
    "for polring g.m.b.i., and ring",
    CollFamSourceEqFamElms,
    [ IsGeneralMapping and IsPolynomialRingDefaultGeneratorMapping,
      IsRing ],
    function( map, sub )
      if HasGeneratorsOfTwoSidedIdeal(sub)
        and (HasLeftActingRingOfIdeal(sub) and
            IsSubset(LeftActingRingOfIdeal(sub),Source(map)) )
        and (HasRightActingRingOfIdeal(sub) and
            IsSubset(RightActingRingOfIdeal(sub),Source(map)) ) then
        return Ideal(Image(map),
                         List(GeneratorsOfTwoSidedIdeal(sub),
                              x->ImagesRepresentative(map,x)));

      elif HasGeneratorsOfRing(sub) then
        return SubringNC(Range(map),
                         List(GeneratorsOfRing(sub),
                              x->ImagesRepresentative(map,x)));
      fi;

      TryNextMethod();
    end );
