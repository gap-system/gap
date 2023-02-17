#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Lukas Maas, Jack Schmidt.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the implementation for Schur covers of symmetric and
##  alternating groups on Coxeter or standard generators.
##

#############################################################################
##
##  Faithful, irreducible representations of minimal degree of the double
##  covers of symmetric groups can be constructed inductively using the
##  methods of https://arxiv.org/abs/0911.3794
##
##  The inductive formulation uses a number of helper routines which are
##  wrapped inside a function call to keep from declaring a large number
##  of (private) global variables.
##

BindGlobal("BasicSpinRepSym", CallFuncList(function()
  local S, S1, coeffS2, S2, coeffS3, S3, bmat, spinsteps, SpinDimSym,
    BasicSpinRepSymPos, BasicSpinRepSymNeg,
    SanityCheckPos, SanityCheckNeg;

  ##  let 2S+(n) = < t_1, ..., t_(n-1) > subject to the relations
  ##    (t_i)^2 = z for 1 <= i <= n-1,
  ##    z^2 = 1,
  ##    ( t_i*t_(i+1) )^3 = z for 1 <= i <= n-2,
  ##    t_i*t_j = z*t_j*t_i for 1 <= i, j <= n-1 with | i - j | > 1.
  ##
  ##  The following functions allow the construction of basic spin
  ##  representations of 2S+(n) over fields of any characteristic.

  ##  SpinDimSym
  ##  IN   integers n >= 4, p >= 0
  ##  OUT  the degree of a basic spin repr. of 2S(n) over a field of
  ##       characteristic p
  SpinDimSym:= function( n, p )
      local r;
      r:= n mod 2;
      if r = 0 then
          return 2^((n-2)/2);
      elif p = 0 then
          return 2^((n-1)/2);
      elif r = 1 and n mod p = 0 then
          return 2^((n-3)/2);
      else
          return 2^((n-1)/2);
      fi;
  end;

  ##  SanityCheckPos
  ##  IN  A record containing the matrices in T, the degree of the symmetric
  ##      group n, and the characteristic f the field p
  ##  OUT true if the matrices in T are the right size, over the right field, and
  ##      satisfy the presentation for 2S(n) given above.  Also checks the
  ##      components Sym and Alt if present.
  SanityCheckPos := function( input )
    local i, j;

      if input.n <> Length( input.T ) + 1 then
        Print("#I SanityCheckPos: Wrong degree: ",input.n," vs. ",Length(input.T)+1,"\n");
        return false;
      fi;

      if input.p <> Characteristic( input.T[1] ) then
        Print("#I SanityCheckPos: Wrong characteristic: ",input.p," vs. ",Characteristic(input.T[1]),"\n");
        return false;
      fi;

      if SpinDimSym( input.n, input.p ) <> Length( input.T[1] ) then
          Print( "#I SanityCheckPos: Wrong degree: ",SpinDimSym( input.n, input.p )," vs. ",Length( input.T[1] ),"\n" );
          return false;
      fi;

      if not ForAll( input.T, mat -> Size(mat) = Size(mat[1]) and Size(mat)=Size(input.T[1])) then
        Print("#I SanityCheckPos: Matrices not all same size\n");
        return false;
      fi;

      for i in [ 1 .. input.n-1 ] do
          if not IsOne(-input.T[i]^2) then
              Print( "#I SanityCheckPos: Wrong order for T[",i,"]\n");
              return false;
          fi;
      od;
      for i in [ 1 .. input.n-2 ] do
          if not IsOne( -( input.T[i]*input.T[i+1] )^3 ) then
              Print( "#I SanityCheckPos: Braid relation failed at position ", i, "\n" );
              return false;
          fi;
          for j in [ i+2 .. input.n-1 ] do
              if not IsOne( - ( input.T[i]*input.T[j] )^2 ) then
                  Print( "#I SanityCheckPos: Commutator relation failed for ( ", i, ", ", j ," )\n" );
                  return false;
              fi;
          od;
      od;

      if IsBound( input.Sym ) then
        if not input.Sym[1] = Product( Reversed( input.T ) ) then
          Print( "SanityCheckPos: Wrong Sym[1]\n" );
          return false;
        fi;

        if not input.Sym[2] = input.T[1] then
          Print( "SanityCheckPos: Wrong Sym[2]\n" );
          return false;
        fi;
      fi;

      if IsBound( input.Alt ) then
        if not input.Alt[1] = Product( Reversed( input.T{[1..2*Int((input.n-1)/2)]} ) ) then
          Print( "SanityCheckPos: Wrong Alt[1]\n" );
          return false;
        fi;

        if not input.Alt[2] = input.T[input.n-1]*input.T[input.n-2] then
          Print( "SanityCheckPos: Wrong Alt[2]\n" );
          return false;
        fi;
      fi;

      return true;
  end;

  ##  SanityCheckNeg
  ##  IN  A record containing the matrices in T, the degree of the symmetric
  ##      group n, and the characteristic f the field p
  ##  OUT true if the matrices in T are the right size, over the right field, and
  ##      satisfy the presentation for 2S-(n) given above.  Also checks the
  ##      components Sym and Alt if present.
  SanityCheckNeg := function( S, p )
      local d, deg, i, j;

      d:= Length( S );
      deg:= Length( S[1] );
      if SpinDimSym( d+1, p ) <> deg then
          Print( "#I SanityCheckNeg: wrong degree!\n" );
          return false;
      fi;
      #Print( "#I SanityCheckNeg: degree: ", deg , "\n" );
      for i in [ 1 .. d ] do
          if not IsOne( S[i]^2 ) then
              Print( "#I SanityCheckNeg: order failed at position ", i, "\n" );
              return false;
          fi;
      od;
      for i in [ 1 .. d-1 ] do
          if not IsOne( ( S[i]*S[i+1] )^3 ) then
              Print( "#I SanityCheckNeg: braid relation failed at position ", i, "\n" );
              return false;
          fi;
          for j in [ i+2 .. d ] do
              if S[i]*S[j] <> -S[j]*S[i] then
                  Print( "#I SanityCheckNeg: commuting relation failed for ( ", i, ", ", j ," )\n" );
                  return false;
              fi;
          od;
      od;
      #Print( "#I SanityCheckNeg: all relations satisfied\n" );
      return true;
  end;

  ##  bmat -- blck matrix maker
  ##  IN  the blocks a,b,c,d of the matrix [[a,b],[c,d]]
  ##  OUT a normal matrix with the same entries as the corresponding block
  ##      matrix.
  bmat := function(a,b,c,d)
    local mat;
    mat := DirectSumMat( a, d );
    if b <> 0 then mat{[1..Length(a)]}{[1+Length(a[1])..Length(mat[1])]} := b; fi;
    if c <> 0 then mat{[1+Length(a)..Length(mat)]}{[1..Length(a[1])]} := c; fi;
    return mat;
  end;

  ##  construction S of Definition 4 / Lemma 5
  ##  IN  an input record with n,p,T and optionally Sym and/or Alt,
  ##      where n,p satisfy the hypothesis of Def 4 / Lemma 5
  ##  OUT the same, but for 2S(n+1)
  S:= function( old )
    local new, I, z, i;

    #Print("S from ",old.n," to ",new.n,"\n");
    new := rec( n := old.n+1, p:=old.p, T:=[] );

    for i in [ 1 .. new.n-3 ] do
      new.T[i] := DirectSumMat( old.T[i], -old.T[i] );
    od;
    I := old.T[1]^0;
    z := 0*old.T[1];
    new.T[new.n-2] := bmat( old.T[new.n-2], -I, 0, -old.T[new.n-2] );
    new.T[new.n-1] := bmat( z, I, -I, z );

    if IsBound( old.Sym ) then
      new.Sym := [];
      if new.n < 5
      then new.Sym[1] := Product(Reversed(new.T));
      else new.Sym[1] := bmat( 0*old.Sym[1], (-1)^new.n*old.Sym[1], -old.Sym[1], (-1)^new.n*old.T[new.n-2]*old.Sym[1] );
      fi;
      new.Sym[2] := new.T[1];
    fi;

    if IsBound( old.Alt ) then
      new.Alt := [];
      if IsOddInt(new.n)
      then new.Alt[1] := new.Sym[1];
      else new.Alt[1] := -new.T[new.n-1]*new.Sym[1];
      fi;
      new.Alt[2] := new.T[new.n-1]*new.T[new.n-2];
    fi;

    Assert( 1, SanityCheckPos( new ) );
    return new;
  end;

  ##  construction S1 of Lemma 7
  ##  IN  an input record with n,p,T and optionally Sym and/or Alt,
  ##      where n,p satisfy the hypothesis of Lemma 7
  ##  OUT the same, but for 2S(n+1)
  S1:= function( old )
    local new, J;

    #Print("S1 from ",old.n," to ",new.n,"\n");
    new := rec( n := old.n + 1, p := old.p, T := ShallowCopy( old.T ) );

    J := Sum( [1..new.n-2], k -> k*old.T[k] );
    if new.p = 2 and 2 = new.n mod 4 then
      new.T[new.n-1] := J + J^0;
    else
      new.T[new.n-1] := J;
    fi;

    if IsBound( old.Sym ) then
      new.Sym := [];
      new.Sym[1] := new.T[new.n-1]*old.Sym[1];
      new.Sym[2] := old.Sym[2];
    fi;

    if IsBound( old.Alt ) then
      new.Alt := [];
      if IsOddInt(new.n)
      then new.Alt[1] := new.Sym[1];
      else new.Alt[1] := old.Alt[1];
      fi;
      new.Alt[2] := new.T[new.n-1]*new.T[new.n-2];
    fi;

    Assert( 1, SanityCheckPos( new ) );
    return new;
  end;

  ## return alpha ( = alpha^+ ) and beta as in Lemma 10
  ## here n(n-1)(n-2) must not be divisible by p
  coeffS2:= function( n, p )
      local one, a, b, c, alpha;
      if p = 0 then
          c:= n-2;
          alpha:= (n-1)^-1*( 1 + Sqrt( -n*c^-1 ) );
      else
          one:= Z( p )^0;
          c:= (n-2) mod p;
          a:= -n*c^-1 mod p;
          a:= LogFFE( a*one, Z(p^2) ) / 2;
          b:= (n-1)^-1 mod p;
          alpha:= b*(one+Z(p^2)^a);
      fi;
      return rec( alpha:= alpha, beta:= alpha*c );
  end;

  ##  construction S2 of Lemma 10
  ##  IN  an input record with n,p,T and optionally Sym and/or Alt,
  ##      where n,p satisfy the hypothesis of Lemma 10
  ##  OUT the same, but for 2S(n+2)
  S2:= function( old )
    local mid, new, coeffs, a, b, J, I;

    #Print("S2 from ",old.n," to ",old.n+2," via S\n");

    mid := S( old );

    new := rec( n := mid.n + 1, p := mid.p, T := ShallowCopy( mid.T ) );

    coeffs:= coeffS2( new.n, new.p );
    a := coeffs.alpha;
    b := coeffs.beta;
    J := Sum( [ 1 .. new.n-3 ], k-> k*old.T[k] );
    I := old.T[1]^0;
    new.T[new.n-1] := bmat( -a*J, (b-1)*I, b*I, a*J );

    if IsBound( old.Sym ) then
      new.Sym := [];
      new.Sym[1] := new.T[new.n-1]*mid.Sym[1];
      new.Sym[2] := mid.Sym[2];
    fi;

    if IsBound( old.Alt ) then
      new.Alt := [];
      if IsOddInt( new.n )
      then new.Alt[1] := new.Sym[1];
      else new.Alt[1] := mid.Sym[1];
      fi;
      new.Alt[2] := new.T[new.n-1]*new.T[new.n-2];
    fi;

    Assert( 1, SanityCheckPos( new ) );
    return  new;
  end;

  ##  coeffS3 - a needed coefficient
  ##  IN  A prime p, or p = 0
  ##  OUT Sqrt(-1) in GF(p^2) or CF(4)
  coeffS3:= function( p )
    if 0 = p then return E(4);
    elif 2 = p then return Z(2);
    elif 1 = p mod 4 then return Z(p)^((p-1)/4);
    else return Z(p^2)^((p^2-1)/4);
    fi;
  end;

  ##  construction S3 of Lemma 11
  ##  IN  an input record with n,p,T and optionally Sym and/or Alt,
  ##      where n,p satisfy the hypothesis of Lemma 11
  ##  OUT the same, but for 2S(n+4)
  S3:= function( old )
    local mid, new, a, J0, I, J;
    #Print("S3 from ",old.n," to ",old.n+4," via S,S1,S\n");

    mid := S( S1( S( old ) ) ); # now at n-1

    new := rec( n := mid.n + 1, p := mid.p, T := ShallowCopy( mid.T ) );

    a := coeffS3( old.p );
    J0:= Sum( [1..new.n-5], k-> k*old.T[k] );
    I := old.T[1]^0;
    J := a*bmat(J0, 2*I, 2*I, -J0);
    new.T[new.n-1] := bmat( J, -J^0, 0, -J );

    if IsBound( old.Sym ) then
      new.Sym := [];
      new.Sym[1] := new.T[new.n-1]*mid.Sym[1];
      new.Sym[2] := mid.Sym[2];
    fi;

    if IsBound( old.Alt ) then
      new.Alt := [];
      if IsOddInt( new.n )
      then new.Alt[1] := new.Sym[1];
      else new.Alt[1] := mid.Alt[1];
      fi;
      new.Alt[2] := new.T[new.n-1]*new.T[new.n-2];
    fi;

    Assert( 1, SanityCheckPos( new ) );
    return new;
  end;

  ##  spinsteps
  ##  IN  the degree n and characteristic p > 2
  ##  OUT a list which describes the steps of construction
  spinsteps:= function( n, p )
    local d, k, kmodp, parity;
    d:= [];
    k:= n;
    while k > 4 do
      kmodp:= k mod p;
      parity:= k mod 2;
      if kmodp > 2 then
        if parity = 1 then
          Add( d, 0 );
          k:= k-1;
        else
          Add( d, 2 );
          k:= k-2;
        fi;
      elif kmodp = 0 then
        Add( d, 1 );
        k:= k-1;
      elif kmodp = 1 then
        Add( d, 0 );
        k:= k-1;
      else
        if parity = 1 then
          Add( d, 0 );
          k:= k-1;
        else
          Add( d, 3 );
          k:= k-4;
        fi;
      fi;
    od;
    return Reversed( d );
  end;

  ##  construction of a basic spin rep. of 2S+(n) in characteristic p
  BasicSpinRepSymPos := function( n, p )
    local z, M, k, i, steps;
    if not IsPosInt(n) or not IsInt(p) or n < 4 or not ( p = 0 or IsPrime( p ) ) then
        return fail;
    fi;
    ## get the spin reps for 2S(4)
    z := coeffS3(p);
    if p = 0 then
        M:= rec(
          n := 2,
          p := 0,
          T := [ [ [ z ] ] ],
          Sym := [~.T[1]],
          Alt :=[]
        );
        M:= S2( M );
    elif p = 2 then
        M:= rec(
          n := 2,
          p := 2,
          T := [ [ [ z ] ] ],
          Sym := [~.T[1]],
          Alt :=[]
        );
        M:= S1( S( M ) );
    elif p = 3 then
        M:= rec(
          n := 3,
          p := 3,
          T := [ [ [ z ] ], [ [ z ] ] ],
          Sym := [ [ [ z^2 ] ], ~.T[1] ],
          Alt:=[ ~.Sym[1] ]
        );
        M:= S( M );
    else # p>3
        M:= rec(
           n := 2,
           p := p,
           T := [ [ [ z ] ] ],
           Sym := [ ~.T[1]],
           Alt:=[]
        );
        M:= S2( M );
    fi;
    if n = 4 then return M; fi;
    if ValueOption("Sym") <> true and ValueOption("Alt")<>true then Unbind(M.Sym); fi;
    if ValueOption("Alt") <> true then Unbind(M.Alt); fi;
    if p = 0 then
        if n mod 2 = 0 then
            k:= (n-4)/2;
            for i in [ 1 .. k ] do
                M:= S2( M );
            od;
        else
            k:= (n-5)/2;
            for i in [ 1 .. k ] do
                M:= S2( M );
            od;
            # now M is a b.s.r. of 2S( n-1 )
            M:= S( M );
        fi;
    elif p = 2 then
        k:= 5;
        while k <= n do
            if k mod 2 = 1 then
                M:= S( M );
            else
                M:= S1( M );
            fi;
            k:= k+1;
        od;
    else # p >= 3
        steps:= spinsteps( n, p );
        for k in steps do
            if k = 0 then
                M := S( M );
            elif k = 1 then
                M := S1( M );
            elif k = 2 then
                M := S2( M );
            else
                M := S3( M );
            fi;
        od;
    fi;
    Assert( 1, SanityCheckPos( M ) );
    return M;
  end;

  BasicSpinRepSymNeg := function( n, p )
    local T, S;
    T := BasicSpinRepSymPos( n, p );
    S := rec( n := T.n, p := T.p, T := coeffS3( p ) * T.T );
    if IsBound( T.Sym ) then S.Sym := [ coeffS3( p )^(n-1) * T.Sym[1], S.T[1] ]; fi;
    if IsBound( T.Alt ) then S.Alt := [ (-1)^Int((n-1)/2)*T.Alt[1], -T.Alt[2] ]; fi;
    Assert( 1, SanityCheckNeg( S.T, p ) );
    return S;
  end;

  return function( n, p, sign )
    if sign in [ 1, '+', "+", 4 ] then return BasicSpinRepSymPos(n,p);
    elif sign in [ -1, '-', "-", 2 ] then return BasicSpinRepSymNeg(n,p);
    else Error("<sign> should be +1 or -1");
    fi;
  end;

end, [] ) );


##########################################################################
##
##  Method Installations
##

InstallGlobalFunction( BasicSpinRepresentationOfSymmetricGroup,
function(arg)
  local n, p, s, mats;
  if Length(arg) < 1 then Error("Usage: BasicSpinRepresentationOfSymmetricGroup( <n>, <p>, <sign> );"); fi;
  n := arg[1];
  if Length(arg) < 2 then p := 3; else p := arg[2]; fi;
  if Length(arg) < 3 then s := 1; else s := arg[3]; fi;
  mats := BasicSpinRepSym(n,p,s).T;
  if p = 2 then return List( mats, mat -> ImmutableMatrix( GF(p), mat ) );
  elif p > 0 then return List( mats, mat -> ImmutableMatrix( GF(p^2), mat ) ); fi;
  return mats;
end );

InstallMethod( SchurCoverOfSymmetricGroup,
  "Use Lukas Maas's inductive construction of a basic spin rep",
  [ IsPosInt, IsInt, IsInt ],
function( n, p, s )
  local mats, grp;

  if p = 2 then return fail; fi; # need a faithful rep

  if n < 4 then TryNextMethod(); fi;

  mats := BasicSpinRepSym(n,p,s:Sym);

  mats.Z := -mats.T[1]^0;

  grp := Group( mats.Sym );

  Assert( 3, Size( grp ) = 2*Factorial( n ) );
  SetSize( grp, 2*Factorial(n) );

  Assert( 3, Center( grp ) = Subgroup( grp, [ mats.Z ] ) );
  SetCenter( grp, SubgroupNC( grp, [ mats.Z ] ) );

  Assert( 3, IsAbelian( Center( grp ) ) );
  SetIsAbelian( Center( grp ), true );

  Assert( 3, Size( Center( grp ) ) = 2 );
  SetSize( Center( grp ), 2 );

  Assert( 3, AbelianInvariants( Center( grp ) ) = [ 2 ] );
  SetAbelianInvariants( Center( grp ), [ 2 ] );

  return grp;
end );

InstallMethod( DoubleCoverOfAlternatingGroup,
  "Use Lukas Maas's inductive construction of a basic spin rep",
  [ IsPosInt, IsInt ],
function( n, p )
  local mats, grp;

  if p = 2 then return fail; fi; # need a faithful rep

  mats := BasicSpinRepSym(n,p,1:Alt);

  mats.Z := -mats.T[1]^0;

  grp := Group( mats.Alt );

  Assert( 3, Size( grp ) = Factorial( n ) );
  SetSize( grp, Factorial(n) );

  Assert( 3, Center( grp ) = Subgroup( grp, [ mats.Z ] ) );
  SetCenter( grp, SubgroupNC( grp, [ mats.Z ] ) );

  Assert( 3, IsAbelian( Center( grp ) ) );
  SetIsAbelian( Center( grp ), true );

  Assert( 3, Size( Center( grp ) ) = 2 );
  SetSize( Center( grp ), 2 );

  Assert( 3, AbelianInvariants( Center( grp ) ) = [ 2 ] );
  SetAbelianInvariants( Center( grp ), [ 2 ] );

  if n >= 5 then
    Assert( 3, IsPerfectGroup( grp ) );
    SetIsPerfectGroup( grp, true );
  fi;

  return grp;
end );

#############################################################################
##
##  Other method installations that do not require direct access to the
##  inductive procedure.
##


#############################################################################
##
##  Convenience routines that supply default values.
##

InstallOtherMethod( SchurCoverOfSymmetricGroup,
  "Sign=+1 by default",
  [ IsPosInt, IsInt ],
function( n, p )
  return SchurCoverOfSymmetricGroup( n, p, 1 );
end );

InstallOtherMethod( SchurCoverOfSymmetricGroup,
  "P=3, Sign=+1 by default",
  [ IsPosInt ],
function( n )
  return SchurCoverOfSymmetricGroup( n, 3, 1 );
end );

InstallOtherMethod( DoubleCoverOfAlternatingGroup,
  "P=3 by default",
  [ IsPosInt ],
function( n )
  return DoubleCoverOfAlternatingGroup( n, 3 );
end );

#############################################################################
##
##  Quickly setup the standard epimorphisms
##

InstallMethod( EpimorphismSchurCover,
  "Use library copy of double cover",
  [ IsNaturalSymmetricGroup ],
function( sym )
  local dom, deg, cox, chr, grp, hom, img;
  dom := MovedPoints( sym );
  deg := Size( dom );
  if deg < 4 then return IdentityMapping( sym ); fi;
  cox := List( [1..deg-1], i -> (dom[i],dom[i+1]) );
  Assert( 1, ForAll( cox, gen -> gen in sym ) );
  #chr := First( [3,5,7], p -> 0 = deg mod p );
  #if chr = fail then chr := 3; fi;
  chr := 3; # appears to be the best choice regardless of deg
  grp := SchurCoverOfSymmetricGroup( deg, chr, 1 );
  img := [ Product( Reversed( cox ) ), cox[1] ];
  if AssertionLevel() > 2 then
    hom := GroupHomomorphismByImages( grp, sym, GeneratorsOfGroup( grp ), img );
    Assert( 3, KernelOfMultiplicativeGeneralMapping( hom ) = Center( grp ) );
  else
    dom := RUN_IN_GGMBI; RUN_IN_GGMBI := true;
    hom := GroupHomomorphismByImagesNC( grp, sym, GeneratorsOfGroup( grp ), img );
    RUN_IN_GGMBI := dom;
    SetKernelOfMultiplicativeGeneralMapping( hom, Center( grp ) );
  fi;
  return hom;
end );

InstallMethod( EpimorphismSchurCover,
  "Use library copy of double cover",
  [ IsNaturalAlternatingGroup ],
function( alt )
  local dom, deg, cox, chr, grp, hom, img;
  dom := MovedPoints( alt );
  deg := Size( dom );
  if deg < 4 then return IdentityMapping( alt ); fi;
  if deg in [6,7] then TryNextMethod(); fi;
  cox := List( [1..deg-1], i -> (dom[i],dom[i+1]) );
  Assert( 1, ForAll( [1..deg-2], i -> cox[i]*cox[i+1] in alt ) );
  chr := 3;
  grp := DoubleCoverOfAlternatingGroup( deg, chr );
  img := [ Product( Reversed( cox{[1..2*Int((deg-1)/2)]} ) ), cox[deg-1]*cox[deg-2] ];
  if AssertionLevel() > 2 then
    hom := GroupHomomorphismByImages( grp, alt, GeneratorsOfGroup( grp ), img );
    Assert( 3, KernelOfMultiplicativeGeneralMapping( hom ) = Center( grp ) );
  else
    dom := RUN_IN_GGMBI; RUN_IN_GGMBI := true;
    hom := GroupHomomorphismByImagesNC( grp, alt, GeneratorsOfGroup( grp ), img );
    RUN_IN_GGMBI := dom;
    SetKernelOfMultiplicativeGeneralMapping( hom, Center( grp ) );
  fi;
  return hom;
end );

###########################################################################
##
##   Special cases just handled explicitly
##

InstallMethod( SchurCoverOfSymmetricGroup,
  "Use explicit matrix reps for degrees 1,2,3",
  [ IsPosInt, IsInt, IsInt ],
  1,
function( n, p, ignored )
  local R;
  if p = 0 then R := Integers; else R:=GF(p); fi;
  if n = 1 then return TrivialSubgroup( GL(1,R) );
  elif n = 2 and p<>2 then return Group( -One(GL(1,R)) );
  elif n = 3 and p<>3 then return Group( [ [[0,1],[-1,-1]], [[0,1],[1,0]] ]*One(R) );
  elif n = 2 and p = 2 then return Group( [[1,1],[0,1]]*One(R) ); # indecomposable, not irreducible
  elif n = 3 and p = 3 then return Group( [ [[0,1],[-1,-1]], [[0,1],[1,0]] ]*One(R) ); # indecomposable, not irreducible
  else TryNextMethod();
  fi;
end );

InstallMethod( EpimorphismSchurCover,
  "Use copy of AtlasRep's 6-fold cover",
  [ IsNaturalAlternatingGroup ],
  1,
function( alt )
  local dom, deg, cox, img, z, gen, grp, cen, hom;
  dom := MovedPoints( alt );
  deg := Size( dom );
  if deg = 6 then
    z := Z(25);
    gen := [
      [ [ z^ 0, z^16, z^22, z^ 8, z^ 8, z^13 ],
        [ z^ 0, z^22, z^ 0, z^ 7, z^11, z^16 ],
        [ z^11, z^ 7, z^ 0, z^ 6, z^10, z^ 7 ],
        [ z^ 2, z^ 0, z^ 3, z* 0, z^18, z^21 ],
        [ z^21, z^ 9, z^ 2, z^12, z^ 5, z^20 ],
        [ z   , z^ 5, z^ 2, z^ 4, z^16, z^ 6 ] ],
      [ [ z^18, z^23, z^ 0, z^ 2, z^23, z^17 ],
        [ z^ 2, z^10, z^17, z* 0, z^ 0, z^18 ],
        [ z^17, z^ 4, z^12, z^23, z^22, z^ 4 ],
        [ z   , z^12, z   , z^18, z^11, z^ 2 ],
        [ z^21, z^ 4, z^15, z^ 8, z^19, z* 0 ],
        [ z^ 8, z^ 6, z^14, z^18, z^18, z^ 9 ] ] ];
    grp := Group( gen );

    Assert( 2, Size( grp ) = 6*5*4*3*2/2 * 6 );
    SetSize( grp, 6*5*4*3*2/2 * 6 );

    cen := SubgroupNC( grp, [ DiagonalMat( [ z^4, z^4, z^4, z^4, z^4, z^4 ] ) ] );

    Assert( 1, Size( cen ) = 6 );
    SetSize( cen, 6 );

    Assert( 1, IsAbelian( cen ) );
    SetIsAbelian( cen, true );

    Assert( 1, AbelianInvariants( cen ) = [ 2, 3 ] );
    SetAbelianInvariants( cen, [ 2, 3 ] );

    Assert( 2, Center(grp) = cen );
    SetCenter( grp, cen );
  elif deg = 7 then
    z := Z(25);
    gen := [
      [ [ z* 0, z^14, z^10, z^19, z^11, z^ 6 ],
        [ z^19, z^12, z^ 9, z   , z^ 0, z    ],
        [ z^ 8, z^18, z^10, z^ 2, z^20, z^15 ],
        [ z^ 2, z^ 0, z^23, z^ 0, z^12, z^ 5 ],
        [ z^20, z^ 8, z^20, z^23, z^16, z^ 0 ],
        [ z^10, z^ 2, z^13, z^ 5, z^20, z^11 ] ],
      [ [ z^ 7, z^ 6, z^10, z^23, z^ 6, z^ 0 ],
        [ z^14, z^19, z^ 9, z^22, z^ 2, z^ 0 ],
        [ z^10, z^16, z^17, z^15, z^17, z^14 ],
        [ z^ 0, z^17, z^10, z^13, z   , z^ 6 ],
        [ z^13, z^ 9, z^ 2, z^12, z^ 8, z^ 7 ],
        [ z^ 8, z^ 8, z^16, z^23, z^ 4, z^19 ] ] ];

    grp := Group( gen );

    Assert( 2, Size( grp ) = 7*6*5*4*3*2/2 * 6 );
    SetSize( grp, 7*6*5*4*3*2/2 * 6 );

    cen := SubgroupNC( grp, [ DiagonalMat( [ z^4, z^4, z^4, z^4, z^4, z^4 ] ) ] );

    Assert( 1, Size( cen ) = 6 );
    SetSize( cen, 6 );

    Assert( 1, IsAbelian( cen ) );
    SetIsAbelian( cen, true );

    Assert( 1, AbelianInvariants( cen ) = [ 2, 3 ] );
    SetAbelianInvariants( cen, [ 2, 3 ] );

    Assert( 2, Center(grp) = cen );
    SetCenter( grp, cen );

  else TryNextMethod();
  fi;
  cox := List( [1..deg-1], i -> (dom[i],dom[i+1]) );
  img := [ Product( Reversed( cox{[1..2*Int((deg-1)/2)]} ) ), cox[deg-1]*cox[deg-2] ];
  Assert( 1, ForAll( img, i -> i in alt ) );
  if AssertionLevel() > 1 then
    hom := GroupHomomorphismByImages( grp, alt, gen, img );
    Assert( 2, KernelOfMultiplicativeGeneralMapping( hom ) = Center( grp ) );
  else
    hom := GroupHomomorphismByImagesNC( grp, alt, gen, img );
    SetKernelOfMultiplicativeGeneralMapping( hom, Center( grp ) );
  fi;
  return hom;
end );
