#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Martin Schönert.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for rationals.
##


#############################################################################
##
#V  Rationals . . . . . . . . . . . . . . . . . . . . . .  field of rationals
##
BindGlobal( "Rationals", Objectify( NewType(
    CollectionsFamily( CyclotomicsFamily ),
    IsRationals and IsAttributeStoringRep ), rec() ) );
SetName( Rationals, "Rationals" );
SetLeftActingDomain( Rationals, Rationals );
SetSize( Rationals, infinity );
SetConductor( Rationals, 1 );
SetDimension( Rationals, 1 );
SetGaloisStabilizer( Rationals, [ 1 ] );
SetGeneratorsOfLeftModule( Rationals, [ 1 ] );
SetIsFinitelyGeneratedMagma( Rationals, false );
SetIsWholeFamily( Rationals, false );


#############################################################################
##
#M  \in( <x>, <Rationals> ) . . . . . . . . . . membership test for rationals
##
InstallMethod( \in,
    "for cyclotomic and Rationals",
    [ IsCyclotomic, IsRationals ],
    function( x, Rationals ) return IsRat( x ); end );


#############################################################################
##
#M  Random( Rationals ) . . . . . . . . . . . . . . . . . . . random rational
##
InstallMethodWithRandomSource( Random,
    "for a random source and Rationals",
    [ IsRandomSource, IsRationals ],
    function( rs, Rationals )
    local den;
    repeat den := Random( rs, Integers ); until den <> 0;
    return Random( rs, Integers ) / den;
    end );


#############################################################################
##
#M  Conjugates( Rationals, Rationals, <x> )   . . .  conjugates of a rational
##
InstallMethod( Conjugates,
    "for Rationals, Rationals, and a rational",
    IsCollsXElms,
    [ IsRationals, IsRationals, IsRat ],
    function( L, K, x )
    return [ x ];
    end );


#############################################################################
##
#R  IsCanonicalBasisRationals
##
DeclareRepresentation( "IsCanonicalBasisRationals",
    IsAttributeStoringRep,
    [] );
#T is this needed at all?


#############################################################################
##
#M  CanonicalBasis( Rationals )
##
InstallMethod( CanonicalBasis,
    "for Rationals",
    [ IsRationals ],
    function( Rationals )
    local B;
    B:= Objectify( NewType( FamilyObj( Rationals ),
                                IsFiniteBasisDefault
                            and IsCanonicalBasis
                            and IsCanonicalBasisRationals ),
                   rec() );
    SetUnderlyingLeftModule( B, Rationals );
    SetBasisVectors( B, [ 1 ] );
    return B;
    end );

InstallMethod( Coefficients,
    "method for canonical basis of Rationals",
    IsCollsElms,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisRationals, IsVector ],
    function( B, v )
    if IsRat( v ) then
      return [ v ];
    else
      return fail;
    fi;
    end );


############################################################################
##
#M  Iterator( Rationals )
##
##  Let $A_n = \{ \frac{p}{q} ; p,q \in\{ 1, \ldots, n \} \}$
##      $B_n = A_n \setminus \bigcup_{i<n} A_i$,
##      $B_0 = \{ 0 \}$, and
##      $B_{-n} = \{ -x; x\in B_n \}$ for $n \in\N$.
##  Then $\Q = \bigcup_{n\in\Z} B_n$ as a disjoint union.
##
##  $\|B_n\| = 2 ( n - 1 ) - 2 ( \tau(n) - 2 ) = 2 ( n - \tau(n) + 1 )$
##  where $\tau(n)$ denotes the number of divisors of $n$.
##  Now define the ordering on $\Q$ by the ordering of the sets $B_n$
##  as defined in 'IntegersOps.Iterator', by the natural ordering of
##  elements in each $B_n$ for positive $n$, and the reverse of this
##  ordering for negative $n$.
##
BindGlobal( "NextIterator_Rationals", function( iter )
    local value;

    if iter!.actualn = 1 then

      # Catch the special case that numerator and denominator are
      # allowed to be equal.
      value:= iter!.sign;
      if iter!.sign = -1 then
        iter!.actualn := 2;
        iter!.len     := 1;
        iter!.pos     := 1;
        iter!.coprime := [ 1 ];
      fi;
      iter!.sign:= - iter!.sign;

    elif iter!.up then

      # We are in the first half (proper fractions).
      value:= iter!.sign * iter!.coprime[ iter!.pos ] / iter!.actualn;

      # Check whether we reached the last element of the first half.
      if iter!.pos = iter!.len then
        iter!.up:= false;
      else
        iter!.pos:= iter!.pos + 1;
      fi;

    else

      # We are in the second half.
      value:= iter!.sign * iter!.actualn / iter!.coprime[ iter!.pos ];

      # Check whether we reached the last element of the second half.
      if iter!.pos = 1 then
        if iter!.sign = -1 then
          iter!.actualn := iter!.actualn + 1;
          iter!.coprime := PrimeResidues( iter!.actualn );
          iter!.len     := Length( iter!.coprime );
        fi;
        iter!.sign := - iter!.sign;
        iter!.up   := true;
      else
        iter!.pos:= iter!.pos - 1;
      fi;

    fi;

    return value;
    end );

BindGlobal( "ShallowCopy_Rationals",
    iter -> rec(
                actualn   := iter!.actualn,
                up        := iter!.up,
                sign      := iter!.sign,
                pos       := iter!.pos,
                coprime   := ShallowCopy( iter!.coprime ),
                len       := Length( iter!.coprime ) ) );

InstallMethod( Iterator,
    "for `Rationals'",
    [ IsRationals ],
    Rationals -> IteratorByFunctions( rec(
        NextIterator := NextIterator_Rationals,
        IsDoneIterator := ReturnFalse,
        ShallowCopy := ShallowCopy_Rationals,

        actualn   := 0,
        up        := false,
        sign      := -1,
        pos       := 1,
        coprime   := [ 1 ],
        len       := 1 ) ) );


#############################################################################
##
#M  Enumerator( Rationals )
##
BindGlobal( "NumberElement_Rationals",
    function( enum, elm )
    local num,
          den,
          max,
          number,
          residues;

    if not IsRat( elm ) then
      return fail;
    fi;
    num:= NumeratorRat( elm);
    den:= DenominatorRat( elm );
    max:= AbsInt( num );
    if max < den then
      max:= den;
    fi;

    if   elm =  0 then
      number:= 1;
    elif elm =  1 then
      number:= 2;
    elif elm = -1 then
      number:= 3;
    else

      # Take the sum over all inner squares.
      # For $i > 1$, the positive half of the $i$-th square has
      # $n_i = 2 \varphi(i)$ elements, $n_1 = 1$, so the sum is
      # \[ 1 + \sum_{j=1}^{max-1} 2 n_j =
      #    4 \sum_{j=1}^{max-1} \varphi(j) - 1 . \]
      number:= 4 * Sum( [ 1 .. max-1 ], Phi ) - 1;

      # Add the part in the actual square.
      residues:= PrimeResidues( max );
      if num < 0 then
        # Add $n_{max}$.
        number:= number + 2 * Length( residues );
        num:= - num;
      fi;
      if num > den then
        number:= number + 2 * Length( residues )
                 - Position( residues, den ) + 1;
      else
        number:= number + Position( residues, num );
      fi;

    fi;

    # Return the result.
    return number;
    end );

BindGlobal( "ElementNumber_Rationals",
    function( enum, number )
    local elm,
          max,
          4phi,
          sign;

    if number <= 3 then

      if   number = 1 then
        elm:=  0;
      elif number = 2 then
        elm:=  1;
      else
        elm:= -1;
      fi;

    else

      # Compute the maximum of numerator and denominator,
      # and subtract the number of inner squares from 'number'.

      number:= number - 3;

      max:= 2;
      4phi:= 4 * Phi( max );
      while number > 4phi do
        number := number - 4phi;
        max    := max + 1;
        4phi   := 4 * Phi( max );
      od;
      if number > 4phi / 2 then
        sign:= -1;
        number:= number - 4phi / 2;
      else
        sign:= 1;
      fi;
      if number > 4phi / 4 then
        elm:= sign * max / PrimeResidues( max )[ 4phi / 2 - number + 1 ];
      else
        elm:= sign * PrimeResidues( max )[ number ] / max;
      fi;

    fi;

    return elm;
    end );

InstallMethod( Enumerator,
    "for `Rationals'",
    [ IsRationals ],
    function( Rationals )
    return EnumeratorByFunctions( Rationals, rec(
               ElementNumber := ElementNumber_Rationals,
               NumberElement := NumberElement_Rationals ) );
    end );


#############################################################################
##
#F  EvalF(<number>) . . . . . .  floating point evaluation of rational number
##
BindGlobal( "EvalF", function(arg)
local r,f,i,s;
  r:=arg[1];
  if r<0 then
    r:=-r;
    s:=['-'];
  else
    s:=[];
  fi;
  if Length(arg)>1 then
    f:=arg[2];
  else
    f:=10;
  fi;
  i:=Int(r);
  s:=Concatenation(s,String(i));
  if r<>i then
    Add(s,'.');
    r:=String(Int((r-i)*10^f));
    while Length(r)<f do
      Add(s,'0');
      f:=f-1;
    od;
    s:=Concatenation(s,String(r));
  fi;
  ConvertToStringRep(s);
  return s;
end );


#############################################################################
##
#M  RoundCyc( <cyc> ) . . . . . . . . . . cyclotomic integer near to <cyc>
##
InstallMethod( RoundCyc,
    "Rational",
    [ IsRat],
    function( r )
    if r < 0  then
        return Int( r - 1 / 2 );
    else
        return Int( r + 1 / 2 );
    fi;
end );


#############################################################################
##
#M  RoundCycDown( <cyc> ) . . . . . . . . . . cyclotomic integer near to <cyc>
##
InstallMethod( RoundCycDown,
    "Rational",
    [ IsRat],
    function ( r )
    if DenominatorRat( r ) = 2  then
        return Int( r );
    fi;

    if r < 0  then
        return Int( r - 1 / 2 );
    else
        return Int( r + 1 / 2 );
    fi;
end );


#############################################################################
##
#M  PadicValuation( <rat>, <p> ) . . . . . . . . . . . . . . .  for rationals
##
InstallMethod( PadicValuation,
               "for rationals", ReturnTrue, [ IsRat, IsPosInt ], 0,

  function( rat, p )

    local  a, i;

    if not IsPrimeInt(p) then TryNextMethod(); fi;
    if rat = 0 then return infinity; fi;
    a := NumeratorRat(rat)/p;
    i := 0;
    while IsInt(a) do
      i := i+1;
      a := a/p;
    od;
    if i > 0 or IsInt(rat) then
      return i;
    fi;
    a := DenominatorRat(rat)/p;
    i := 0;
    while IsInt(a) do
      i := i+1;
      a := a/p;
    od;
    return -i;
  end );

# If someone tries to convert a rational into
# a rational, just return the number.
InstallMethod( Rat, [ IsRat ], IdFunc );

InstallMethod( ViewString, "for rationals", [IsRat], function(r)
  return Concatenation(ViewString(NumeratorRat(r)), "/\>\<",
                       ViewString(DenominatorRat(r)));
end);
