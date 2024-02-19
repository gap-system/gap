#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Lübeck.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the implementation part of functions and data around
##  Conway polynomials.
##


###############################################################################
##
#F  PowerModEvalPol( <f>, <g>, <xpownmodf> )
##
InstallGlobalFunction( PowerModEvalPol, function( f, g, xpownmodf )
    local l, res, reslen, powlen, i;

    l:= Length( g );
    res:= [ g[l] ];
    reslen:= 1;
    powlen:= Length( xpownmodf );
    ConvertToVectorRep( res );
    for i in [ 1 .. l-1 ] do
      res:= ProductCoeffs( res, reslen, xpownmodf,
                powlen );                      # `res:= res * x^n;'
      reslen:= ReduceCoeffs( res, f );         # `res:= res mod f;'
      if reslen = 0 then
        res[1]:= g[l-i];                       # `res:= res + g_{l-i+1};'
        reslen:= 1;
      else
        res[1]:= res[1] + g[l-i];              # `res:= res + g_{l-i+1};'
      fi;
    od;
    ShrinkRowVector( res );
    return res;
end );


############################################################################
##
#V  CONWAYPOLYNOMIALS
##
##  This variable was used in GAP 4, version <= 4.4.4 for storing
##  coefficients of (pre)computed Conway polynomials. It is no longer used.
##


############################################################################
##
#V  CONWAYPOLYNOMIALSINFO
##
##  strings describing the origin of precomputed Conway polynomials, can be
##  accessed by 'InfoText'
##
##  also used to remember which data files were read
##
BindGlobal("CONWAYPOLYNOMIALSINFO",  AtomicRecord(rec(
 RP := MakeImmutable("original list by Richard Parker (from 1980's)\n"),
 GAP := MakeImmutable("computed with the GAP function by Thomas Breuer, just checks\n\
conditions starting from 'smallest' polynomial\n"),
 FL := MakeImmutable("computed by a parallelized program by Frank Lübeck, computes\n\
minimal polynomial of all compatible elements (~2001)\n"),
 KM := MakeImmutable("computed by Kate Minola, a parallelized program for p=2, considering\n\
minimal polynomials of all compatible elements (~2004-2005)\n"),
 RPn := MakeImmutable("computed by Richard Parker (2004)\n"),
 3\,21 := MakeImmutable("for p=3, n=21 there appeared a polynomial in some lists/systems\n\
which was not the Conway polynomial; the current one in GAP is correct\n"),
 JB := MakeImmutable("computed by John Bray using minimal polynomials of consistent \
elements, respectively a similar algorithm as in GAP (~2005)\n"),
 conwdat1 := false,
 conwdat2 := false,
 conwdat3 := false,
 # cache for p > 110000
 cache := MakeWriteOnceAtomic(rec())

) ) );

############################################################################
##
#V  CONWAYPOLDATA
##
##  List of lists caching (pre-)computed Conway polynomials.
##
##  Format: The ConwayPolynomial(p, n) is cached in CONWAYPOLDATA[p][n].
##          The entry has the format [num, fld]. Here fld is one of the
##          component names of CONWAYPOLYNOMIALSINFO and describes the
##          origin of the polynomial. num is an integer, encoding the
##          polynomial as follows:
##          Let (a0 + a1 X + a2 X^2 + ... + X^n)*One(GF(p)) be the polynomial
##          where a0, a1, ... are integers in the range 0..p-1. Then
##              num = a0 + a1 p + a2 p^2 + ... + a<n-1> p^(n-1).
##
BindGlobal("CONWAYPOLDATA", MakeWriteOnceAtomic([]));

##  a utility function, checks consistency of a polynomial with Conway
##  polynomials of proper subfield. (But  doesn't check that it is the
##  "smallest" such polynomial  in the ordering used  to define Conway
##  polynomials.
BindGlobal( "IsConsistentPolynomial", function( pol )
  local n, p, ps, x, null, f;
  n := DegreeOfLaurentPolynomial(pol);
  p := Characteristic(pol);
  ps := PrimeDivisors(n);
  x := IndeterminateOfLaurentPolynomial(pol);
  null := 0*pol;
  f := function(k)
    local kpol;
    kpol := ConwayPolynomial(p, k);
    return Value(kpol, PowerMod(x, (p^n-1)/(p^k-1), pol)) mod pol = null;
  end;

  if IsPrimitivePolynomial(GF(p), pol) then
    return ForAll(ps, p-> f(n/p));
  else
    return false;
  fi;
end);

##  This is now incorporated more intelligently in the 'FactInt' package.
##  Commented out, since it wasn't documented anyway.
##  BRENT_FACTORS_LIST := "not loaded, call `AddBrentFactorList();'";
##  AddBrentFactorList := function(    )
##    local str, get, comm, res, n, p, z, pos;
##    Print(
##    "Copying many prime factors of numbers a^n+1 / a^n-1 from Richard Brent's\n",
##    "list `factors.gz' (in \n",
##    "ftp://ftp.comlab.ox.ac.uk/pub/Documents/techpapers/Richard.Brent/factors/factors.gz\n");
##    str := "";
##    get := OutputTextString(str, false);
##    comm := "wget -q ftp://ftp.comlab.ox.ac.uk/pub/Documents/techpapers/Richard.Brent/factors/factors.gz -O - | gzip -dc ";
##    Process(DirectoryCurrent(), Filename(DirectoriesSystemPrograms(),"sh"),
##            InputTextUser(), get, ["-c", comm]);
##    res := [[],[]];
##    n := 0;
##    p := Position(str, '\n', 0);
##    while p <> fail do
##      z := str{[n+1..p-1]};
##      pos := Position(z, '-');
##      if pos = fail then
##        pos := Position(z, '+');
##      fi;
##      if pos <> fail then
##        Add(res[1], NormalizedWhitespace(z{[1..pos]}));
##        Add(res[2], Int(NormalizedWhitespace(z{[pos+2..Length(z)]})));
##      fi;
##      n := p;
##      p := Position(str, '\n', n);
##    od;
##    for p in res[2] do
##      AddSet(Primes2,p);
##    od;
##    SortParallel(res[1], res[2]);
##    BRENT_FACTORS_LIST := res;
##  end;

##  A consistency check for the data, loading AddBrentFactorList() is useful
##  for the primitivity tests.
##
##  # for 41^41-1
##  AddSet(Primes2, 5926187589691497537793497756719);
##  # for 89^89-1
##  AddSet(Primes2, 4330075309599657322634371042967428373533799534566765522517);
##  # for 97^97-1
##  AddSet(Primes2, 549180361199324724418373466271912931710271534073773);
##  AddSet(Primes2,  85411410016592864938535742262164288660754818699519364051241927961077872028620787589587608357877);
##  for p in [2,113,1009] do IsCheapConwayPolynomial(p,1); od;
##  cp:=CONWAYPOLDATA;;
##  test := [];
##  for i in [1..Length(cp)] do
##    if IsBound(cp[i]) then
##      for j in [1..Length(cp[i])] do
##        if IsBound(cp[i][j]) then
##          a := IsConsistentPolynomial(ConwayPolynomial(i,j));
##          Print(i,"   ",j,"   ", a,"\n");
##          Add(test, [i, j, a]);
##        fi;
##      od;
##    fi;
##  od;

##  number of polynomials for GF(p^n) compatible with Conway polynomials for
##  all proper subfields.
BindGlobal("NrCompatiblePolynomials", function(p, n)
  local ps, lcm;
  ps := PrimeDivisors(n);
  lcm := Lcm(List(ps, r-> p^(n/r)-1));
  return (p^n-1)/lcm;
end);

##  list of all cases with less than 100*10^9 compatible polynomials, sorted
##  w.r.t. this number
BindGlobal( "ConwayCandidates", function()
  local cand, p, i;
  # read data
  for p in [2,113,1009] do
    ConwayPolynomial(p,1);
  od;
  cand := [];;
  for p in Primes{[1..31]} do
    for i in [1..200] do
      if NrCompatiblePolynomials(p,i) < 100000000000 then
        Add(cand, [NrCompatiblePolynomials(p,i), p, i]);
      fi;
    od;
  od;
  Sort(cand);
  cand := Filtered(cand, a-> not IsBound(CONWAYPOLDATA[a[2]][a[3]]));
  return cand;
end );

##
##
####################   end of list of new polynomials   ####################

BIND_GLOBAL("SET_CONWAYPOLDATA", function(p, list)
    local x;
    for x in list do
        MakeImmutable(x);
    od;
    CONWAYPOLDATA[p]:=MakeWriteOnceAtomic(list);
end);

BIND_GLOBAL("LOAD_CONWAY_DATA", function(p)
    if 1 < p and p <= 109 and CONWAYPOLYNOMIALSINFO.conwdat1 = false then
      ReadLib("conwdat1.g");
    elif 109 < p and p < 1000 and CONWAYPOLYNOMIALSINFO.conwdat2 = false then
      ReadLib("conwdat2.g");
    elif 1000 < p and p < 110000 and CONWAYPOLYNOMIALSINFO.conwdat3 = false then
      ReadLib("conwdat3.g");
    fi;
end);

############################################################################
##
#F  ConwayPol( <p>, <n> ) . . . . . <n>-th Conway polynomial in charact. <p>
##
InstallGlobalFunction( ConwayPol, function( p, n )

    local F,          # `GF(p)'
          one,        # `One( F )'
          zero,       # `Zero( F )'
          eps,        # $(-1)^n$ in `F'
          x,          # indeterminate over `F', as coefficients list
          cpol,       # actual candidate for the Conway polynomial
          nfacs,      # all `n/d' for prime divisors `d' of `n'
          cpols,      # Conway polynomials for `d' in `nfacs'
          pp,         # $p^n-1$
          quots,      # list of $(p^n-1)/(p^d-1)$, for $d$ in `nfacs'
          lencpols,   # `Length( cpols )'
          ppmin,      # list of $(p^n-1)/d$, for prime factors $d$ of $p^n-1$
          found,      # is the actual candidate compatible?
          onelist,    # `[ one ]'
          pow,        # powers of several polynomials
          i,          # loop over `ppmin'
          xpownmodf,  # power of `x', modulo `cpol'
          c,          # loop over `cpol'
          e,          # 1 or -1, used to compute the next candidate
          linfac,     # for a quick precheck
          cachelist,  # list of known Conway pols for given p
          StoreConwayPol;  # maybe move out?

    # Check the arguments.
    if not ( IsPrimeInt( p ) and IsPosInt( n ) ) then
      Error( "<p> must be a prime, <n> a positive integer" );
    fi;

    # read data files if necessary
    LOAD_CONWAY_DATA(p);

    if p < 110000 then
      if not IsBound( CONWAYPOLDATA[p] ) then
        CONWAYPOLDATA[p] := MakeWriteOnceAtomic([]);
      fi;
      cachelist := CONWAYPOLDATA[p];
    else
      if not IsBound( CONWAYPOLYNOMIALSINFO.cache.(String(p)) ) then
        CONWAYPOLYNOMIALSINFO.cache.(String(p)) := MakeWriteOnceAtomic([]);
      fi;
      cachelist := CONWAYPOLYNOMIALSINFO.cache.(String(p));
    fi;
    if not IsBound( cachelist[n] ) then

      Info( InfoWarning, 2,
            "computing Conway polynomial for p = ", p, " and n = ", n );

      F:= GF(p);
      one:= One( F );
      zero:= Zero( F );

      if n mod 2 = 1 then
        eps:= AdditiveInverse( one );
      else
        eps:= one;
      fi;

      # polynomial `x' (as coefficients list)
      x:= [ zero, one ];
      ConvertToVectorRep(x, p);

      # Initialize the smallest polynomial of degree `n' that is a candidate
      # for being the Conway polynomial.
      # This is `x^n + (-1)^n \*\ z' for the smallest primitive root `z'.
      # If the field can be realized in {\GAP} then `z' is just `Z(p)'.

      # Note that we enumerate monic polynomials with constant term
      # $(-1)^n \alpha$ where $\alpha$ is the smallest primitive element in
      # $GF(p)$ by the compatibility condition (and by existence of such a
      # polynomial).

      cpol:= ListWithIdenticalEntries( n, zero );
      cpol[ n+1 ]:= one;
      cpol[1]:= eps * PrimitiveRootMod( p );
      ConvertToVectorRep(cpol, p);

      if n > 1 then

        # Compute the list of all `n / l' for `l' a prime divisor of `n'
        nfacs:= List( PrimeDivisors( n ), d -> n / d );

        if nfacs = [ 1 ] then

          # `n' is a prime, we have to check compatibility only with
          # the degree 1 Conway polynomial.
          # But this condition is satisfied by choice of the constant term
          # of the candidates.
          cpols:= [];

        else

          # Compute the Conway polynomials for all values $<n> / d$
          # where $d$ is a prime divisor of <n>.
          # They are used for checking compatibility.
          cpols:= List( nfacs, d -> ConwayPol( p, d ) * one );
          List(cpols, f-> ConvertToVectorRep(f, p));
        fi;

        pp:= p^n-1;

        quots:= List( nfacs, x -> pp / ( p^x -1 ) );
        lencpols:= Length( cpols );
        ppmin:= List( PrimeDivisors( pp ), d -> pp/d );

        found:= false;
        onelist:= [ one ];
        # many random polynomials have linear factors, for small p we check
        # this before trying to check primitivity
        if p < 256 then
          linfac := List([0..p-2], i-> List([0..n], k-> Z(p)^(i*k)));
          List(linfac, a-> ConvertToVectorRep(a,p));
        else
          linfac := [];
        fi;
        while not found do

          # Test whether `cpol' is primitive.
          #  $f$ is primitive if and only if
          #  0. (check first for small p) there is no zero in GF(p),
          #  1. $f$ divides $X^{p^n-1} -1$, and
          #  2. $f$ does not divide $X^{(p^n-1)/l} - 1$ for every
          #     prime divisor $l$ of $p^n - 1$.
          found := ForAll(linfac, a-> a * cpol <> zero);
          if found then
            pow:= PowerModCoeffs( x, 2, pp, cpol, n+1 );
            ShrinkRowVector( pow );
            found:= ( pow = onelist );
          fi;

          i:= 1;
          while found and ( i <= Length( ppmin ) ) do
            pow:= PowerModCoeffs( x, 2, ppmin[i], cpol, n+1 );
            ShrinkRowVector( pow );
            found:= pow <> onelist;
            i:= i+1;
          od;

          # Test compatibility with polynomials in `cpols'.
          i:= 1;
          while found and i <= lencpols do

            # Compute $`cpols[i]'( x^{\frac{p^n-1}{p^m-1}} ) mod `cpol'$.
            xpownmodf:= PowerModCoeffs( x, quots[i], cpol );
            pow:= PowerModEvalPol( cpol, cpols[i], xpownmodf );
            # Note that we need *not* call `ShrinkRowVector'
            # since the list `cpols[i]' has always length at least 2,
            # and a final `ShrinkRowVector' call is done by `PowerModEvalPol'.
            # ShrinkRowVector( pow );
            found:= IsEmpty( pow );
            i:= i+1;

          od;

          if not found then

            # Compute the next candidate according to the chosen ordering.

            # We have $f$ smaller than $g$ for two polynomials $f$, $g$ of
            # degree $n$ with
            # $f = \sum_{i=0}^n (-1)^{n-i} f_i x^i$ and
            # $g = \sum_{i=0}^n (-1)^{n-i} g_i x^i$ if and only if exists
            # $m\leq n$ such that $f_m \< g_m$,
            # and $f_i = g_i$ for all $i > m$.
            # (Note that the thesis of W. Nickel gives a wrong definition.)

            c:= 0;
            e:= eps;
            repeat
              c:= c+1;
              e:= -1*e;
              cpol[c+1]:= cpol[c+1] + e;
            until cpol[c+1] <> zero;

          fi;

        od;

      fi;

      StoreConwayPol := function(cpol, cachelist)
        local found, p, n;
        if IsUnivariatePolynomial(cpol) then
          cpol := CoefficientsOfUnivariatePolynomial(cpol);
        fi;
        p := Characteristic(cpol[1]);
        n := Length(cpol)-1;
        cpol:= List( cpol, IntFFE );

        # Subtract `x^n', strip leading zeroes,
        # and store this polynomial in the global list.
        found:= ShallowCopy( cpol );
        Unbind( found[ n+1 ] );
        ShrinkRowVector( found );
        cachelist[n]:= MakeImmutable([List([0..Length(found)-1], k-> p^k) * found,
                              "GAP"]);
      end;
      StoreConwayPol(cpol, cachelist);
    else

      # Decode the polynomial stored in the list (see description of
      # CONWAYPOLDATA above).
      c := cachelist[n][1];
      cpol:= [];
      while c <> 0 do
        Add(cpol, c mod p);
        c := (c - cpol[Length(cpol)]) / p;
      od;
      while Length( cpol ) < n do
        Add( cpol, 0 );
      od;
      Add( cpol, 1 );

    fi;

    # Return the coefficients list.
    return cpol;
end );


############################################################################
##
#F  ConwayPolynomial( <p>, <n> ) .  <n>-th Conway polynomial in charact. <p>
##
InstallGlobalFunction( ConwayPolynomial, function( p, n )
    local F, res;
    if IsPrimeInt( p ) and IsPosInt( n ) then
      F:= GF(p);
      res := UnivariatePolynomial( F, One( F ) * ConwayPol( p, n ) );
      if p < 110000 then
          Setter(InfoText)(res, CONWAYPOLYNOMIALSINFO.(
                  CONWAYPOLDATA[p][n][2]));
      else
          Setter(InfoText)(res, CONWAYPOLYNOMIALSINFO.cache.(
                 String(p))[n][2]);
      fi;
      return res;
    else
      Error( "<p> must be a prime, <n> a positive integer" );
    fi;
end );

InstallGlobalFunction( IsCheapConwayPolynomial, function( p, n )
  local cacheentry;

  if not ( IsPrimeInt( p ) and IsPosInt( n ) ) then
    return false;
  fi;

  # read data files if necessary
  LOAD_CONWAY_DATA(p);
  if p < 110000 and IsBound(CONWAYPOLDATA[p]) and IsBound(CONWAYPOLDATA[p][n]) then
    return true;
  fi;
  if p >= 110000 and IsBound(CONWAYPOLYNOMIALSINFO.cache.(String(p))) then
      cacheentry := CONWAYPOLYNOMIALSINFO.cache.(String(p));
      if IsBound(cacheentry[n]) then
          return true;
      fi;
  fi;
  # this is not very precise, hopefully good enough for the moment
  if p < 41 then
    if n < 100 and (n = 1 or IsPrimeInt(n)) then
      return true;
    fi;
  elif p < 100 then
    if n < 40 and (n = 1 or IsPrimeInt(n)) then
      return true;
    fi;
  elif p < 1000 then
    if n < 14 and (n = 1 or IsPrimeInt(n)) then
      return true;
    fi;
  elif p < 2^48 then
    if n in [1,2,3,5,7] then
      return true;
    fi;
  elif p < 2^60 then
    if n in [1,2,3,5] then
      return true;
    fi;
  elif p < 2^120 then
    if n in [1,2,3] then
      return true;
    fi;
  elif p < 2^200 then
    if n in [1,2] then
      return true;
    fi;
  elif n = 1 then
    return false;
  fi;
  return false;
end );

# arg: F, n[, i]
InstallGlobalFunction( RandomPrimitivePolynomial, function(F, n, varnum...)
  local i, pol, FF, one, fac, a, zero;
  if Length(varnum) > 0 then
    i := varnum[1];
  else
    i := 1;
  fi;
  if IsUnivariatePolynomial(i) then
    i := IndeterminateNumberOfUnivariateRationalFunction(i);
  fi;
  if IsInt(F) then
    F := GF(F);
  fi;
  if n=1 and Size(F)=2 then
    return Indeterminate(F, i) + One(F);
  fi;
  repeat pol := RandomPol(F, n);
  until IsIrreducibleRingElement(PolynomialRing(F), pol);
  FF := AlgebraicExtension(F, pol);
  one := One(FF);
  zero := Zero(FF);
  fac:=List(PrimeDivisors(Size(FF)-1), p-> (Size(FF)-1)/p);
  repeat
    a := Random(FF);
  until a <> zero and ForAll(fac, d-> a^d <> one);
  return MinimalPolynomial(F, a, i);
end);

##  # utility to write new data files in case of extensions
##  printConwayData := function(f)
##    local i, j, v;
##    for i in [1..Length(CONWAYPOLDATA)] do
##      if IsBound(CONWAYPOLDATA[i]) then
##        PrintTo(f, "SET_CONWAYPOLDATA(",i,",[\n");
##        for j in [1..Length(CONWAYPOLDATA[i])] do
##          if IsBound(CONWAYPOLDATA[i][j]) then
##            PrintTo(f,"[",CONWAYPOLDATA[i][j][1],",\"",CONWAYPOLDATA[i][j][2],
##                  "\"]");
##          fi;
##          PrintTo(f,",");
##        od;
##        PrintTo(f,"]);\n");
##      fi;
##    od;
##  end;
##  f := OutputTextFile("guck.g", false);
##  SetPrintFormattingStatus(f, false);
##  printConwayData(f);
##  CloseStream(f);
##  # and then distribute into conwdat?.g
