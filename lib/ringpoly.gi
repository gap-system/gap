#############################################################################
##
#W  ringpoly.gi                 GAP Library                      Frank Celler
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the methods  for attributes, properties and operations
##  for polynomial rings.
##
Revision.ringpoly_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  GiveNumbersNIndeterminates(<ratfunfam>,<count>,<names>,<avoid>)
BindGlobal("GiveNumbersNIndeterminates",function(rfam,cnt,nam,avoid)
local idn,i,nbound;
  avoid:=List(avoid,IndeterminateNumberOfLaurentPolynomial);
  idn:=[];
  i:=1;
  while Length(idn)<cnt do
    nbound:=IsBound(nam[Length(idn)+1]);
    # skip unwanted indeterminates
    while (i in avoid) or (nbound and HasIndeterminateName(rfam,i)) do
      i:=i+1;
    od;
    Add(idn,i);
    if nbound then
      SetIndeterminateName(rfam,i,nam[Length(idn)]);
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
      r!.univariateRings:=[];
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

  R -> Concatenation(String(LeftActingDomain(R)),
                     Filtered(String(IndeterminatesOfPolynomialRing(R)),
                              ch -> ch <> ' ')) );

#############################################################################
##
#M  ViewObj( <pring> ) . . . . . . . . . . . . . . . .  for a polynomial ring
##
InstallMethod( ViewObj,
              "for a polynomial ring", true, [ IsPolynomialRing ],
              # override the higher ranking FLMLOR method
              RankFilter(IsFLMLOR),

  function( R )
    Print(ViewString(R));
  end );

#############################################################################
##
#M  String( <pring> ) . . . . . . . . . . . . . . . . . for a polynomial ring
##
InstallMethod( String,
               "for a polynomial ring", true, [ IsPolynomialRing ],
               RankFilter(IsFLMLOR),
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
    RankFilter(IsFLMLOR),

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
InstallMethod(\.,"pring indeterminates",true,[IsPolynomialRing,IsPosInt],
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
    inds := Set( List( IndeterminatesOfPolynomialRing(R),
                       x -> ExtRepPolynomialRatFun(x)[1][1] ) );

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
	     i->DegreeOfUnivariateLaurentPolynomial(i)>-1 and
		DegreeOfUnivariateLaurentPolynomial(i)<infinity);

    gens:=ogens{Difference([1..Length(ogens)],g)};

    # univariate indeterminates set
    ind := Set(List(univ,IndeterminateNumberOfUnivariateRationalFunction));
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
#M  MinimalPolynomial( <ring>, <elm> )
##
InstallOtherMethod( MinimalPolynomial,"supply indeterminate 1",
    [ IsRing, IsMultiplicativeElement and IsAdditiveElement ],
function(r,e)
  return MinimalPolynomial(r,e,1);
end);


#############################################################################
##
#M  StandardAssociate( <pring>, <upol> )
##
InstallMethod(StandardAssociate,"normalize leading coefficient",IsCollsElms,
  [IsPolynomialRing, IsPolynomial],0,
function(R,f)
local c;
  c:=LeadingCoefficient(f);
  return f*StandardAssociate(CoefficientsRing(R),c)/c;
end);


#############################################################################
##
#E

