#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Hans Ulrich Besche, Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains character table methods for solvable groups.
##

##  We take advantage of knowing conjugacy class representatives
##  as words in generators.
InstallMethod(LinearCharacters, ["CanEasilyComputePcgs"], function(G)
  local pcgs, hom, Gab, abinv, exp, e, Ee, genexp,
        clexps, tab, irgens, a, lin, c, res, j, i, sz;
  if Size(G) = 1 then
    return [TrivialCharacter(G)];
  fi;
  pcgs := Pcgs(G);
  # this yields the homomorphism onto G/G'
  hom := MaximalAbelianQuotient(G);
  # G/G'
  Gab := Image(hom);
  abinv := AbelianInvariants(Gab);
  sz := Product(abinv);
  # all character values are powers of e
  exp := Lcm(abinv);
  e := E(exp);
  Ee := [1];
  for i in [1..exp-1] do
    Add(Ee, Ee[i]*e);
  od;
  # write generators of G mod G' as in abelian generators of G/G'
  IndependentGeneratorsOfAbelianGroup(Gab);
  genexp := List(pcgs, x-> IndependentGeneratorExponents(Gab, x^hom));
  # exponent vectors of class representatives of G
  clexps := List(ConjugacyClasses(G),
                 c-> ExponentsOfPcElement(pcgs, Representative(c)));
  # irgens are the dual generators of G/G'
  tab := CharacterTable(G);
  irgens := [];
  for i in [1..Length(abinv)] do
    a := exp/abinv[i];
    Add(irgens, List(genexp, g-> g[i]*a));
  od;
  # now it is easy to find values of all linear characters on generators of G
  # -> and so on class representatives
  lin := 0*[1..Length(pcgs)];
  res := [];
  # c is the abinv-adic decomposition of i in [0..sz-1], used as
  # coefficients of a linear combination of irgens
  c := 0*[1..Length(abinv)];
  for i in [1..sz] do
    Add(res, Character(tab, Ee{((clexps * lin) mod exp)+1}));
    if i < sz then
      c[1] := c[1]+1;
      lin := lin + irgens[1];
      j := 1;
      while c[j] >= abinv[j] do
        c[j] := 0;
        lin := lin - abinv[j]*irgens[j];
        j := j+1;
        c[j] := c[j]+1;
        lin := lin + irgens[j];
      od;
    fi;
  od;
  return res;
end);

#############################################################################
##
#M  CharacterDegrees( <G>, <p> )  . . . . . . . . . . .  for an abelian group
##
InstallMethod( CharacterDegrees,
    "for an abelian group, and an integer p (just strip off the p-part)",
    [ IsGroup and IsAbelian, IsInt ],
    {} -> RankFilter(IsZeroCyc), # There is a method for groups for
                           # the integer zero which is worse
    function( G, p )
    G:= Size( G );
    if p <> 0 then
      while G mod p = 0 do
        G:= G / p;
      od;
    fi;
    return [ [ 1, G ] ];
    end );


#############################################################################
##
#F  AppendCollectedList( <list1>, <list2> )
##
BindGlobal( "AppendCollectedList", function( list1, list2 )
    local pair1, pair2, toadd;
    for pair2 in list2 do
      toadd:= true;
      for pair1 in list1 do
        if pair1[1] = pair2[1] then
          pair1[2]:= pair1[2] + pair2[2];
          toadd:= false;
          break;
        fi;
      od;
      if toadd then
        AddSet( list1, pair2 );
      fi;
    od;
end );


#############################################################################
##
#F  KernelUnderDualAction( <N>, <Npcgs>, <v> )  . . . . . . .  local function
##
##  <Npcgs> is a PCGS of an elementary abelian group <N>.
##  <v> is a vector in the dual space of <N>, w.r.t. <Npcgs>.
##  The kernel of <v> is returned.
##
BindGlobal( "KernelUnderDualAction", function( N, Npcgs, v )
    local gens, # generators list
          i, j;

    gens:= [];
    for i in Reversed( [ 1 .. Length( v ) ] ) do
      if IsZero( v[i] ) then
        Add( gens, Npcgs[i] );
      else
        # `i' is the position of the last nonzero entry of `v'.
        for j in Reversed( [ 1 .. i-1 ] ) do
          Add( gens, Npcgs[j]*Npcgs[i]^( Int(-v[j]/v[i]) ) );
        od;
        return SubgroupNC( N, Reversed( gens ) );
      fi;
    od;
end );


#############################################################################
##
#F  ProjectiveCharDeg( <G> ,<z> ,<q> )
##
InstallGlobalFunction( ProjectiveCharDeg, function( G, z, q )
    local oz,       # the order of `z'
          N,        # normal subgroup of `G'
          t,
          r,        # collected list of character degrees, result
          h,        # natural homomorphism
          img,
          k,
          c,
          ci,
          zn,
          i,
          p,        # prime divisor of the size of `N'
          P,        # Sylow `p' subgroup of `N'
          O,
          L,
          Gpcgs,    # PCGS of `G'
          Ppcgs,    # PCGS of `P'
          Opcgs,    # PCGS of `O'
          mats,
          orbs,
          orb,      # loop over `orbs'
          stab;     # stabilizer of canonical representative of `orb'

    oz:= Order( z );

    # For abelian groups, there are only linear characters.
    if IsAbelian( G ) then
      G:= Size( G );
      if q <> 0 then
        while G mod q = 0 do
          G:= G / q;
        od;
      fi;
      return [ [ 1, G/oz ] ];
    fi;

    # Now `G' is not abelian.
    h:= NaturalHomomorphismByNormalSubgroupNC( G, SubgroupNC( G, [ z ] ) );
    img:= ImagesSource( h );
    N:= ElementaryAbelianSeriesLargeSteps( img );
    N:= N[ Length( N )-1 ];
    if not IsPrime( Size( N ) ) then
      N:= ChiefSeriesUnderAction( img, N );
      N:= N[ Length( N )-1 ];
    fi;

    # `N' is a normal subgroup such that `N/<z>' is a chief factor of `G'
    # of order `i' which is a power of `p'.
    N:= PreImagesSet( h, N );
    i:= Size( N ) / oz;
    p:= Factors( i )[1];

    if not IsAbelian( N ) then

      h:= NaturalHomomorphismByNormalSubgroupNC( G, SubgroupNC( G, [ z ] ) );

      # `c' is a list of complement classes of `N' modulo `z'
      c:= List( ComplementClassesRepresentatives( ImagesSource( h ), ImagesSet( h, N ) ),
                x -> PreImagesSet( h, x ) );
      r:= Centralizer( G, N );
      for L in c do
        if IsSubset( L, r ) then

          # L is a complement to N in G modulo <z> which centralizes N
          r:= RootInt( Size(N) / oz );
          return List( ProjectiveCharDeg( L, z, q ),
                       x -> [ x[1]*r, x[2] ] );

        fi;
      od;
      Error( "this should not happen" );

    fi;

    # `N' is abelian, `P' is its Sylow `p' subgroup.
    P:= SylowSubgroup( N, p );

    if p = q then

      # Factor out `P' (lies in the kernel of the repr.)
      h:= NaturalHomomorphismByNormalSubgroupNC( G, P );
      return ProjectiveCharDeg( ImagesSource( h ), ImageElm( h, z ), q );

    elif i = Size( P ) then

      # `z' is a p'-element, `P' is elementary abelian.
      # Find the characters of the factor group needed.
      h:= NaturalHomomorphismByNormalSubgroupNC( G, P );
      r:= ProjectiveCharDeg( ImagesSource( h ), ImageElm( h, z ), q );

      if p = i then

        # `P' has order `p'.
        zn:= First( GeneratorsOfGroup( P ), g -> not IsOne( g ) );
        t:=  Stabilizer( G, zn );
        i:= Size(G) / Size(t);
        AppendCollectedList( r,
            List( ProjectiveCharDeg( t, zn*z, q ),
                  x -> [ x[1]*i, x[2]*(p-1)/i ] ) );
        return r;

      else

        # `P' has order strictly larger than `p'.
        # `mats' describes the contragredient operation of `G' on `P'.
        Gpcgs:= Pcgs( G );
        Ppcgs:= Pcgs( P );
        mats:= List( List( Gpcgs, Inverse ),
                   x -> TransposedMat( List( Ppcgs,
                   y -> ExponentsConjugateLayer( Ppcgs, y,x ) )*Z(p)^0 ) );
        orbs:= ExternalOrbitsStabilizers( G,
                   NormedRowVectors( GF(p)^Length( Ppcgs ) ),
                   Gpcgs, mats, OnLines );
        orbs:= Filtered( orbs,
              o -> not IsZero( CanonicalRepresentativeOfExternalSet( o ) ) );

        for orb in orbs do

          # `k' is the kernel of the character.
          stab:= StabilizerOfExternalSet( orb );
          h:= NaturalHomomorphismByNormalSubgroupNC( stab,
                  KernelUnderDualAction( P, Ppcgs,
                      CanonicalRepresentativeOfExternalSet( orb ) ) );
          img:= ImagesSource( h );

          # `zn' is an element of `img'.
          # Note that the image of `P' under `h' has order `p'.
          zn:= First( GeneratorsOfGroup( ImagesSet( h, P) ),
                      g -> not IsOne( g ) )
               * ImageElm( h, z );

          # `c' is stabilizer of the character,
          # `ci' is the number of orbits of characters with equal kernels
          if p = 2 then
            c  := img;
            ci := 1;
          else
            c  := Stabilizer( img, zn );
            ci := Size( img ) / Size( c );
          fi;
          k:= Size( G ) / Size( stab ) * ci;
          AppendCollectedList( r,
              List( ProjectiveCharDeg( c, zn, q ),
                    x -> [ x[1]*k, x[2]*(p-1)/ci ] ) );

        od;
        return r;

      fi;

    elif IsCyclic( P ) then

      # Choose a generator `zn' of `P'.
      zn := Pcgs( P )[1];
      t  := Stabilizer( G, zn, OnPoints );
      if G = t then
        # `P' is a central subgroup of `G'.
        return List( ProjectiveCharDeg( G, zn*z, q ),
                     x -> [ x[1], x[2]*p ] );
      else
        # `P' is not central in `G'.
        return List( ProjectiveCharDeg( t, zn*z, q ),
                     x -> [ x[1]*p, x[2] ] );
      fi;

    fi;

    # `P' is the direct product of the Sylow `p' subgroup of `z'
    # and an elementary abelian `p' subgroup.
    O:= Omega( P, p );
    Opcgs:= Pcgs( O );
    Gpcgs:= Pcgs( G );

    # `zn' is a generator of the intersection of <z> and `O'
    zn := z^(oz/p);
    r  := [];
    mats:= List( List( Gpcgs, Inverse ),
                 x -> TransposedMat( List( Opcgs,
                      y -> ExponentsConjugateLayer( Opcgs, y,x ) ) * Z(p)^0 ) );
    orbs:= ExternalOrbitsStabilizers( G,
               NormedRowVectors( GF(p)^Length( Opcgs ) ),
               Gpcgs, mats, OnLines );
    orbs:= Filtered( orbs,
              o -> not IsZero( CanonicalRepresentativeOfExternalSet( o ) ) );

    # In this case the stabilzers of the kernels are already the
    # stabilizers of the characters.
    for orb in orbs do
      k:= KernelUnderDualAction( O, Opcgs,
              CanonicalRepresentativeOfExternalSet( orb ) );
      if not zn in k then
        # The kernel avoids `zn'.
        t:= StabilizerOfExternalSet( orb );
        h:= NaturalHomomorphismByNormalSubgroupNC( t, k );
        img:= ImagesSource( h );
        t:= Size(G) / Size(t);
        AppendCollectedList( r, List( ProjectiveCharDeg( img,
                                          ImageElm( h, z ), q ),
                                      x -> [ x[1]*t, x[2] ] ) );
      fi;
    od;
    return r;
end );


#############################################################################
##
#M  CharacterDegrees( <G>, <p> )  . . . . . . . . . . .  for a solvable group
##
##  The algorithm used is based on~\cite{Con90b},
##  its main tool is Clifford theory.
##
##  Given a solvable group $G$ and a nonnegative integer $q$,
##  we first choose an elementary abelian normal subgroup $N$.
##  (Note that $N$ need not be a *minimal* normal subgroup, this requirement
##  in~\cite{Con90b} applies only to the computation of projective degrees
##  where nonabelian normal subgroups $N$ occur.)
##  By recursion, the $q$-modular character degrees of the factor group $G/N$
##  are computed next.
##  So it remains to compute the degrees of those $q$-modular irreducible
##  characters whose kernels do not contain $N$.
##  This last step follows~\cite{Con90b}, for the special case of a *trivial*
##  central subgroup $Z$.
##  Namely, we compute the $G$-orbits on the linear spaces of the nontrivial
##  irreducible characters of $N$, under projective action.
##  (The orbit consisting of the trivial character corresponds to those
##  $q$-modular irreducible $G$-characters with $N$ in their kernels.)
##  For each orbit, we use the function `ProjectiveCharDeg' to compute the
##  degrees arising from a representative $\chi$,
##  in the group $S/K$ with central cyclic subgroup $N/K$,
##  where $S$ is the (subspace) stabilizer of $\chi$ and $K$ is the kernel of
##  $\chi$.
##
##  One recursive step of the algorithm is described in the following.
##
##  Let $G$ be a solvable group, $z$ a central element in $G$,
##  and let $q$ be the characteristic of the algebraic closed field $F$.
##  Without loss of generality, we may assume that $G$ is nonabelian.
##  Consider a faithful linear character $\lambda$ of $\langle z \rangle$.
##  We calculate the character degrees $(G,z,q)$ of those absolutely
##  irreducible characters of $G$ whose restrictions to $\langle z \rangle$
##  are a multiple of $\lambda$.
##
##  We choose a normal subgroup $N$ of $G$ such that the factor
##  $N / \langle z \rangle$ is a chief factor in $G$, and consider
##  the following cases.
##
##  If $N$ is nonabelian then we calculate a subgroup $L$ of $G$ such that
##  $N \cap L = \langle z \rangle$, $L$ centralizes $N$, and $N L = G$.
##  One can show that the order of $N / \langle z \rangle$ is a square $r^2$,
##  and that the degrees $(G,z,q)$ are obtained from the degrees $(L,z,q)$
##  on multiplying each with $r$.
##
##  If $N$ is abelian then the order of $N / \langle z \rangle$ is a prime
##  power $p^i$.
##  Let $P$ denote the Sylow $p$ subgroup of $N$.
##  Following Clifford's theorem, we calculate orbit representatives and
##  inertia subgroups with respect to the action of $G$ on those irreducible
##  characters of $P$ that restrict to multiples of $\lambda_P$.
##  For that, we distinguish three cases.
##  \beginlist
##  \item{(a)}
##      $z$ is a $p^{\prime}$ element.
##      Then we compute first the character degrees $(G/P,zP,q)$,
##      corresponding to the (orbit of the) trivial character.
##      The action on the nontrivial irreducible characters of $P$
##      is dual to the action on the nonzero vectors of the vector space
##      $P$.
##      For each representative, we compute the kernel $K$, and the degrees
##      $(S/K,zK,q)$, where $S$ denotes the inertia subgroup.
##
##  \item{(b)}
##      $z$ is not a $p^{\prime}$ element, and $P$ cyclic (not prime order).
##      Let $y$ be a generator of $P$.
##      If $y$ is central in $G$ then we have to return $p$ copies of the
##      degrees $(G,zy,q)$.
##      Otherwise we compute the degrees $(C_G(y),zy,q)$, and multiply
##      each with $p$.
##
##  \item{(c)}
##      $z$ is not a $p^{\prime}$ element, and $P$ is not cyclic.
##      We compute $O = \Omega(P)$.
##      As above, we consider the dual operation to that in $O$,
##      and for each orbit representative we check whether its restriction
##      to $O$ is a multiple of $\lambda_O$, and if yes compute the degrees
##      $(S/K,zK,q)$.
##  \endlist
##
BindGlobal( "CharacterDegreesConlon", function( G, q )
    local r,      # list of degrees, result
          N,      # elementary abelian normal subgroup of `G'
          p,      # prime divisor of the order of `N'
          z,      # one generator of `N'
          t,      # stabilizer of `z' in `G'
          i,      # index of `t' in `G'
          Gpcgs,  # PCGS of `G'
          Npcgs,  # PCGS of `N'
          mats,   # matrices describing the action of `Gpcgs' w.r.t. `Npcgs'
          orbs,   # orbits of the action
          orb,    # loop over `orbs'
          rep,    # canonical representative of `orb'
          stab,   # stabilizer of `rep'
          h,      # nat. hom. by the kernel of a character
          img,    # image of `h'
          c,
          ci,
          k;

    Info( InfoCharacterTable, 1,
          "CharacterDegrees: called for group of order ", Size( G ) );

    # If the group is abelian, we must give up because this method
    # needs a proper elementary abelian normal subgroup for its
    # reduction step.
    # (Note that we must not call `TryNextMethod' because the method
    # for abelian groups has higher rank.)
    if IsAbelian( G ) then
      r:= CharacterDegrees( G, q );
      Info( InfoCharacterTable, 1,
            "CharacterDegrees: returns ", r );
      return r;
    elif not ( q = 0 or IsPrimeInt( q ) ) then
      Error( "<q> mut be zero or a prime" );
    fi;

    # Choose a normal elementary abelian `p'-subgroup `N',
    # not necessarily minimal.
    N:= ElementaryAbelianSeriesLargeSteps( G );
    N:= N[ Length( N ) - 1 ];
    r:= CharacterDegrees( G / N, q );
    p:= Factors( Size( N ) )[1];

    if p = q then

      # If `N' is a `q'-group we are done.
      Info( InfoCharacterTable, 1,
            "CharacterDegrees: returns ", r );
      return r;

    elif Size( N ) = p then

      # `N' is of prime order.
      z:= Pcgs( N )[1];
      t:= Stabilizer( G, z, OnPoints );
      i:= Size( G ) / Size( t );
      AppendCollectedList( r, List( ProjectiveCharDeg( t, z, q ),
                                    x -> [ x[1]*i, x[2]*(p-1)/i ] ) );

    else

      # `N' is an elementary abelian `p'-group of nonprime order.
      Gpcgs:= Pcgs( G );
      Npcgs:= Pcgs( N );
      mats:= List( Gpcgs, x -> TransposedMat( List( Npcgs,
                 y -> ExponentsConjugateLayer( Npcgs, y,x ) ) * Z(p)^0 )^-1 );
      orbs:= ExternalOrbitsStabilizers( G,
                 NormedRowVectors( GF( p )^Length( Npcgs ) ),
                 Gpcgs, mats, OnLines );
#T may fail because the list is too long!
      orbs:= Filtered( orbs,
              o -> not IsZero( CanonicalRepresentativeOfExternalSet( o ) ) );

      for orb in orbs do

        stab:= StabilizerOfExternalSet( orb );
        rep:= CanonicalRepresentativeOfExternalSet( orb );
        h:= NaturalHomomorphismByNormalSubgroupNC( stab,
                KernelUnderDualAction( N, Npcgs, rep ) );
        img:= ImagesSource( h );

        # The kernel has index `p' in `stab'.
        z:= First( GeneratorsOfGroup( ImagesSet( h, N ) ),
                   g -> not IsOne( g ) );
        if p = 2 then
          c  := img;
          ci := 1;
        else
          c  := Stabilizer( img, z );
          ci := Size( img ) / Size( c );
        fi;
        k:= Size( G ) / Size( stab ) * ci;
        AppendCollectedList( r, List( ProjectiveCharDeg( c, z, q ),
                                      x -> [ x[1]*k, x[2]*(p-1)/ci ] ) );

      od;

    fi;

    Info( InfoCharacterTable, 1,
          "CharacterDegrees: returns ", r );
    return r;
    end );

InstallMethod( CharacterDegrees,
    "for a solvable group and an integer (Conlon's algorithm)",
    [ IsGroup and IsSolvableGroup, IsInt ],
    {} -> RankFilter(IsZeroCyc), # There is a method for groups for
                           # the integer zero which is worse
    function( G, q )
    if HasIrr( G ) then
      # Use the known irreducibles.
      TryNextMethod();
    else
      return CharacterDegreesConlon( G, q );
    fi;
    end );


#############################################################################
##
#F  CoveringTriplesCharacters( <G>, <z> ) . . . . . . . . . . . . . . . local
##
InstallGlobalFunction( CoveringTriplesCharacters, function( G, z )
    local oz,
          h,
          img,
          N,
          t,
          r,
          k,
          c,
          zn,
          i,
          p,
          P,
          O,
          Gpcgs,
          Ppcgs,
          Opcgs,
          mats,
          orbs,
          orb;

    # The trivial character will be dealt with separately.
    if IsTrivial( G ) then
      return [];
    fi;

    oz:= Order( z );
    if Size( G ) = oz then
      return [ [ G, TrivialSubgroup( G ), z ] ];
    fi;

    h:= NaturalHomomorphismByNormalSubgroupNC( G, SubgroupNC( G, [ z ] ) );
    img:= ImagesSource( h );
    N:= ElementaryAbelianSeriesLargeSteps( img );
    N:= N[ Length( N ) - 1 ];
    if not IsPrime( Size( N ) ) then
      N:= ChiefSeriesUnderAction( img, N );
      N:= N[ Length( N ) - 1 ];
    fi;
    N:= PreImagesSet( h, N );

    if not IsAbelian( N ) then
      Info( InfoCharacterTable, 2,
            "#I misuse of `CoveringTriplesCharacters'!\n" );
      return [];
    fi;

    i:= Size( N ) / oz;
    p:= Factors( i )[1];
    P:= SylowSubgroup( N, p );

    if i = Size( P ) then

      # `z' is a p'-element, `P' is elementary abelian.
      # Find the characters of the factor group needed.
      h:= NaturalHomomorphismByNormalSubgroupNC( G, P );
      r:= List( CoveringTriplesCharacters( ImagesSource( h ),
                                           ImageElm( h, z ) ),
                x -> [ PreImagesSet( h, x[1] ),
                       PreImagesSet( h, x[2] ),
                       PreImagesRepresentative( h, x[3] ) ] );

      if p = i then

        # `P' has order `p'.
        zn:= First( GeneratorsOfGroup( P ), g -> not IsOne( g ) );
        return Concatenation( r,
                   CoveringTriplesCharacters( Stabilizer( G, zn ), zn*z ) );

      else

        Gpcgs:= Pcgs( G );
        Ppcgs:= Pcgs( P );
        mats:= List( List( Gpcgs, Inverse ),
                   x -> TransposedMat( List( Ppcgs,
                   y -> ExponentsConjugateLayer( Ppcgs, y,x ) )*Z(p)^0 ) );
        orbs:= ExternalOrbitsStabilizers( G,
                   NormedRowVectors( GF(p)^Length( Ppcgs ) ),
                   Gpcgs, mats, OnLines );
        orbs:= Filtered( orbs,
              o -> not IsZero( CanonicalRepresentativeOfExternalSet( o ) ) );

        for orb in orbs do
          h:= NaturalHomomorphismByNormalSubgroupNC(
                  StabilizerOfExternalSet( orb ),
                  KernelUnderDualAction( P, Ppcgs,
                      CanonicalRepresentativeOfExternalSet( orb ) ) );
          img:= ImagesSource( h );
          zn:= First( GeneratorsOfGroup( ImagesSet( h, P ) ),
                      g -> not IsOne( g ) )
               * ImageElm( h, z );

          if p = 2 then
            c:= img;
          else
            c:= Stabilizer( img, zn );
          fi;
          Append( r, List( CoveringTriplesCharacters( c, zn ),
                           x -> [ PreImagesSet( h, x[1] ),
                                  PreImagesSet( h, x[2] ),
                                  PreImagesRepresentative( h, x[3] ) ] ) );
        od;
        return r;

      fi;

    elif IsCyclic( P ) then

      zn:= Pcgs( P )[1];
      return CoveringTriplesCharacters( Stabilizer( G, zn ), zn*z );

    fi;

    O:= Omega( P, p );
    Opcgs:= Pcgs( O );
    Gpcgs:= Pcgs( G );

    zn := z^(oz/p);
    r  := [];
    mats:= List( List( Gpcgs, Inverse ),
                 x -> TransposedMat( List( Opcgs,
                      y -> ExponentsConjugateLayer( Opcgs, y,x ) )*Z(p)^0 ) );
    orbs:= ExternalOrbitsStabilizers( G,
               NormedRowVectors( GF(p)^Length( Opcgs ) ),
               Gpcgs, mats, OnLines );
    orbs:= Filtered( orbs,
              o -> not IsZero( CanonicalRepresentativeOfExternalSet( o ) ) );

    for orb in orbs do
      k:= KernelUnderDualAction( O, Opcgs,
              CanonicalRepresentativeOfExternalSet( orb ) );
      if not zn in k then
        t:= StabilizerOfExternalSet( orb );
        Assert( 1, IsIdenticalObj( Parent( t ), G ) );
        h:= NaturalHomomorphismByNormalSubgroupNC( t, k );
        img:= ImagesSource( h );
        Append( r,
            List( CoveringTriplesCharacters( img, ImageElm( h, z ) ),
                  x -> [ PreImagesSet( h, x[1] ),
                         PreImagesSet( h, x[2] ),
                         PreImagesRepresentative( h, x[3] ) ] ) );
      fi;
    od;
    return r;
end );


#############################################################################
##
#M  IrrConlon( <G> )
##
##  This algorithm is a generalization of the algorithm to compute the
##  absolutely irreducible degrees of a solvable group to the computation
##  of the absolutely irreducible characters of a supersolvable group,
##  using an idea like in
##
##      S. B. Conlon, J. Symbolic Computation (1990) 9, 535-550.
##
##  The function `CoveringTriplesCharacters' is used to compute a list of
##  triples describing linear representations of subgroups of <G>.
##  These linear representations are induced to <G> and then evaluated on
##  representatives of the conjugacy classes.
##
##  For every irreducible character the monomiality information is stored as
##  value of the attribute `TestMonomial'.
##
InstallMethod( IrrConlon, [ "IsGroup" ],
function( G )
  local pcgs, clreps, ct, irr, tr, Cs, normal, N, hom, Cab, abgens,
        ind, coreps, evals, xg, K, sz, h, qu, genqu, multi, mods,
        ch, c, ms, vals, cval, k, C, x, g, t, i, j, r, tm, new;
  pcgs := Pcgs(G);
  # return no characters if G is not solvable
  if pcgs = fail then
    return [];
  fi;
  clreps := List( ConjugacyClasses( G ), Representative );
  ct := CharacterTable( G );
  irr := [];
  # linear characters without covering triples
  Append( irr, LinearCharacters( G ) );
  tm := rec( isMonomial := true, comment := "linear character" );
  for ch in irr do
    SetTestMonomial( ch, tm );
  od;
  tm := rec( isMonomial := true, comment := "induced from given subgroup" );

  # we now only need the triples for proper subgroups
  tr := Filtered( CoveringTriplesCharacters( G, One( G ) ), a-> a[1] <> G );
  # subgroups to induce from
  Cs := Set( List(tr, a-> a[1] ) );
  for C in Cs do
    # monomiality information
    tm := ShallowCopy(tm);
    tm.subgroup := C;
    # only classes in N can have non-zero values
    if IsNormal( G, C ) then
      normal := true;
      N := C;
    else
      normal := false;
      N := NormalClosure( G, C );
    fi;
    # only linear characters of C are induced, need homomorphism onto C/C'
    hom := MaximalAbelianQuotient( C );
    Cab := Image( hom );
    abgens := IndependentGeneratorsOfAbelianGroup( Cab );
    # we compute the generic induced linear character from C,
    # eigenvalues expressed as product of values on generators of C/C'
    ind := [];
    coreps := List( RightCosets( G, C ), Representative );
    for x in clreps do
      if x in N then
        evals := [];
        for g in coreps do
          xg := x^(g^-1);
          if normal or xg in C then
            # if true then x^((cg)^-1) is in the same C-class for all c in C
            Add( evals, IndependentGeneratorExponents( Cab, xg^hom ));
          fi;
        od;
        if Length(evals) > 0 then
          Add( ind, evals );
        else
          Add( ind, 0 );
        fi;
      else
        Add( ind, 0 );
      fi;
    od;
    # now we evaluate ind at the relevant linear characters of C
    for t in tr do
      if t[1] = C then
        # C/K is cyclic of order sz
        # this triple is for all characters of order sz with kernel K
        K := t[2];
        sz := Size( C ) / Size( K );
        # find the characters with kernel K
        #    (maybe better with Hermite normal form?)
        h := NaturalHomomorphismByNormalSubgroupNC( Cab,
               SubgroupNC( Cab, List( GeneratorsOfGroup( K ), y-> y^hom ) ) );
        qu := Image( h );
        # if sz is not a prime power there are several generators
        genqu := IndependentGeneratorsOfAbelianGroup( qu );
        if Length(genqu) > 1 then
          multi := true;
          mods := List(genqu, Order);
        else
          multi := false;
        fi;
        ch := [];
        for g in abgens do
          c := IndependentGeneratorExponents( qu, g^h );
          if multi then
            Add( ch, ChineseRem( mods, c ) );
          else
            Add( ch, c[1] );
          fi;
        od;
        # these multiples of ch are needed
        ms := Filtered( [1..sz-1], m-> Gcd( m, sz ) = 1 );
        vals := List( ms, m-> [] );
        for i in [1..Length(ind)] do
          if ind[i] = 0 then
            for j in [ 1..Length(ms) ] do
              Add( vals[j], 0 );
            od;
          else
            cval := 0*[1..sz];
            for r in ind[i] do
              k := (r * ch) mod sz + 1;
              cval[k] := cval[k] + 1;
            od;
            cval := CycList( cval );
            Add( vals[1], cval );
            for j in [2..Length(ms)] do
              Add( vals[j], GaloisCyc( cval, ms[j] ) );
            od;
          fi;
        od;
        new := List( vals, l-> Character( ct, l ) );
        for ch in new do
          SetTestMonomial( ch, tm );
        od;
        Append( irr, new );
      fi;
    od;
  od;
  return irr;
end);

#############################################################################
##
#M  Irr( <G>, 0 ) . . . . . .  for a supersolvable group (Conlon's algorithm)
##
InstallMethod( Irr,
    "for a supersolvable group (Conlon's algorithm)",
    [ IsGroup and IsSupersolvableGroup, IsZeroCyc ],
    function( G, zero )
    local irr;
    irr:= IrrConlon( G );
    SetIrr( OrdinaryCharacterTable( G ), irr );
    return irr;
    end );

InstallMethod( Irr,
    "for a supersolvable group with known `IrrConlon'",
    [ IsGroup and IsSupersolvableGroup and HasIrrConlon, IsZeroCyc ],
    function( G, zero )
    local irr;
    irr:= IrrConlon( G );
    SetIrr( OrdinaryCharacterTable( G ), irr );
    return irr;
    end );


#############################################################################
##
#M  Irr( <G>, 0 ) . . . .  for a supersolvable group (Baum-Clausen algorithm)
##
InstallMethod( Irr,
    "for a supersolvable group (Baum-Clausen algorithm)",
    [ IsGroup and IsSupersolvableGroup, IsZeroCyc ],
    function( G, zero )
    local irr;
    irr:= IrrBaumClausen( G );
    SetIrr( OrdinaryCharacterTable( G ), irr );
    return irr;
    end );

InstallMethod( Irr,
    "for a supersolvable group with known `IrrBaumClausen'",
    [ IsGroup and IsSupersolvableGroup and HasIrrBaumClausen, IsZeroCyc ],
    function( G, zero )
    local irr;
    irr:= IrrBaumClausen( G );
    SetIrr( OrdinaryCharacterTable( G ), irr );
    return irr;
    end );


#############################################################################
##
#V  BaumClausenInfoDebug  . . . . . . . . . . . . . . testing BaumClausenInfo
##
BindGlobal( "BaumClausenInfoDebug", rec(
    makemat:= function( record, e )
        local dim, mat, diag, gcd, i;
        dim:= Length( record.diag );
        mat:= NullMat( dim, dim );
        diag:= record.diag;
        gcd:= Gcd( diag );
        if gcd = 0 then
          e:= 1;
        else
          gcd:= GcdInt( gcd, e );
          e:= E( e / gcd );
          diag:= diag / gcd;
        fi;
        for i in [ 1 .. dim ] do
          mat[i][ record.perm[i] ]:= e^diag[ record.perm[i] ];
        od;
        return mat;
    end,

    testrep:= function( pcgs, rep, e )
        local images, hom;
        images:= List( rep,
                       record -> BaumClausenInfoDebug.makemat( record, e ) );
        hom:= GroupGeneralMappingByImagesNC( Group( pcgs ), Group( images ),
                                           pcgs, images );
        return IsGroupHomomorphism( hom );
    end,

    checkconj:= function( pcgs, i, lg, j, rep1, rep2, X, e )
        local ii, exps, mat, jj;
        X:= BaumClausenInfoDebug.makemat( X, e );
        for ii in [ i .. lg ] do
          exps:= ExponentsOfPcElement( pcgs, pcgs[ii]^pcgs[j], [ i .. lg ] );
          mat:= One( X );
          for jj in [ 1 .. lg-i+1 ] do
            mat:= mat * BaumClausenInfoDebug.makemat( rep1[jj], e )^exps[jj];
          od;
          if X * mat <>
             BaumClausenInfoDebug.makemat( rep2[ ii-i+1 ], e ) * X then
            return false;
          fi;
        od;
        return true;
    end ) );

MakeImmutable(BaumClausenInfoDebug);


#############################################################################
##
#M  BaumClausenInfo( <G> )  . . . . .  info about irreducible representations
##
#T generalize to characteristic p !!
##
InstallMethod( BaumClausenInfo,
    "for a (solvable) group",
    [ IsGroup ],
    function( G )
    local e,             # occurring roots of unity are `e'-th roots
          pcgs,          # Pcgs of `G'
          lg,            # length of `pcgs'
          cs,            # composition series of `G' corresp. to `pcgs'
          abel,          # position of abelian normal comp. subgroup
          ExtLinRep,     # local function
          indices,       # sizes of composition factors in `cs'
          linear,        # list of linear representations
          i,             # current position in the iteration: $G_i$
          p,             # size of current composition factor
          pexp,          # exponent vector of `pcgs[i]^p'
          root,          # value of an extension
          roots,         # list of $p$-th roots (relative to `e')
          mulmoma,       # product of two monomial matrices
          poweval,       # representing matrix for power of generator
          pilinear,      # action of $g_1, \ldots, g_i$ on `linear'
          d, j, k, l,    # loop variables
          u, v, w,       # loop variables
          M,             #
          pos,           # position in a list
          nonlin,        # list of nonlinear representations
          pinonlin,      # action of $g_1, \ldots, g_i$ on `nonlin'
          Xlist,         # conjugating matrices:
                         # for $X = `Xlist[j][k]'$, we have
                         # $X \cdot {`nonlin[k]'}^{g_j} \cdot X^{-1} =
                         #    `nonlin[ pinonlin[j][k] ]'$
          min,           #
          minval,        #
          ssr,           #
          X,             # one matrix for `Xlist'
          nextlinear,    # extensions of `linear'
          nextnonlin1,   # nonlinear repr. arising from `linear'
          nextnonlin2,   # nonlinear repr. arising from `nonlin'
          pinextlinear,  # action of $g_1, \ldots, g_i$ on `nextlinear'
          pinextnonlin1, # action of $g_1, \ldots, g_i$ on `nextnonlin1'
          pinextnonlin2, # action of $g_1, \ldots, g_i$ on `nextnonlin2'
          nextXlist1,    # conjugating matrices for `nextnonlin1'
          nextXlist2,    # conjugating matrices for `nextnonlin2'
          cexp,          # exponent vector of `pcgs[i]^pcgs[j]'
          poli,          # list that encodes `pexp'
          rep,           # one representation
          D, C,          #
          value,         #
          image,         #
          used,          # boolean list
          Dpos1,         # positions of extension resp. induced repres.
                         # that arise from linear representations
          Dpos2,         # positions of extension resp. induced repres.
                         # that arise from nonlinear representations
          dim,           # dimension of the current representation
          invX,          # inverse of `X'
          D_gi,          #
          hom,           # homomorphism to adjust the composition series
          orb,           #
          Forb,          #
          sigma, pi,     # permutations needed in the fusion case
          constants,     # vector $(c_0, c_1, \ldots, c_{p-1})$
          kernel;        # kernel of `hom'

    if not IsSolvableGroup( G ) then
      Error( "<G> must be solvable" );
    fi;


    # Step 0:
    # Treat the case of the trivial group,
    # and initialize some variables.

    pcgs:= SpecialPcgs( G );
#T because I need a ``prime orders pcgs''
    lg:= Length( pcgs );

    if lg = 0 then
      return rec( pcgs     := pcgs,
                  kernel   := G,
                  exponent := 1,
                  nonlin   := [],
                  lin      := [ [] ]
                  );
    fi;

    cs:= PcSeries( pcgs );

    if HasExponent( G ) then
      e:= Exponent( G );
    else
      e:= Size(G);
#T better adjust on the fly
    fi;


    # Step 1:
    # If necessary then adjust the composition series of $G$
    # and get the largest factor group of $G$ that has an abelian normal
    # subgroup such that the factor group modulo this subgroup is
    # supersolvable.

    abel:= 1;
    while IsNormal( G, cs[ abel ] ) and not IsAbelian( cs[ abel ] ) do
      abel:= abel + 1;
    od;

    # If `cs[ abel ]' is abelian then we compute its representations first,
    # and then loop over the initial part of the composition series;
    # note that the factor group is supersolvable.
    # If `cs[ abel ]' is not abelian then we try to switch to a better
    # composition series, namely one through the derived subgroup of the
    # supersolvable residuum.

    if not IsNormal( G, cs[ abel ] ) then

      # We have reached a non-normal nonabelian composition subgroup
      # so we have to adjust the composition series.

      Info( InfoGroup, 2,
            "BaumClausenInfo: switching to a suitable comp. ser." );

      ssr:= SupersolvableResiduumDefault( G );
      hom:= NaturalHomomorphismByNormalSubgroupNC( G,
                DerivedSubgroup( ssr.ssr ) );

      # `SupersolvableResiduumDefault' contains a component `ds',
      # a list of subgroups such that any composition series through
      # `ds' from `G' down to the residuum is a chief series.
      pcgs:= [];
      for i in [ 2 .. Length( ssr.ds ) ] do
        j:= NaturalHomomorphismByNormalSubgroupNC( ssr.ds[ i-1 ], ssr.ds[i] );
        Append( pcgs, List( SpecialPcgs( ImagesSource( j ) ),
                            x -> PreImagesRepresentative( j, x ) ) );
      od;
      Append( pcgs, SpecialPcgs( ssr.ds[ Length( ssr.ds ) ]) );
      G:= ImagesSource( hom );
      pcgs:= List( pcgs, x -> ImagesRepresentative( hom, x ) );
      pcgs:= Filtered( pcgs, x -> Order( x ) <> 1 );
      pcgs:= PcgsByPcSequence( ElementsFamily( FamilyObj( G ) ), pcgs );
      cs:= PcSeries( pcgs );
      lg:= Length( pcgs );

      # The image of `ssr' under `hom' is abelian,
      # compute its position in the composition series.
      abel:= Position( cs, ImagesSet( hom, ssr.ssr ) );

      # If `G' is supersolvable then `abel = lg+1',
      # but the last *nontrivial* member of the chain is normal and abelian,
      # so we choose this group.
      # (Otherwise we would have the technical problem in step 4 that the
      # matrix `M' would be empty.)
      if lg < abel then
        abel:= lg;
      fi;

    fi;

    # Step 2:
    # Compute the representations of `cs[ abel ]',
    # each a list of images of $g_{abel}, \ldots, g_{lg}$.

    # The local function `ExtLinRep' computes the extensions of the
    # linear $G_{i+1}$-representations $F$ in the list `linear' to $G_i$.
    # The only condition that must be satisfied is that
    # $F(g_i)^p = F(g_i^p)$.
    # (Roughly speaking, we just compute $p$-th roots.)

    ExtLinRep:= function( i, linear, pexp, roots )

      local nextlinear, rep, j, shift;

      nextlinear:= [];
      if IsZero( pexp ) then

        # $g_i^p$ is the identity
        for rep in linear do
          for j in roots do
            Add( nextlinear, Concatenation( [ j ], rep ) );
          od;
        od;

      else

        pexp:= pexp{ [ i+1 .. lg ] };
#T cut this outside the function!
        for rep in linear do

          # Compute the value of `rep' on $g_i^p$.
          shift:= pexp * rep;

          if shift mod p <> 0 then
            # We must enlarge the exponent.
            Error("wrong exponent");
#T if not integral then enlarge the exponent!
#T (is this possible here at all?)
          fi;
          shift:= shift / p;
          for j in roots do
            Add( nextlinear, Concatenation( [ (j+shift) mod e ], rep ) );
          od;

        od;

      fi;

      return nextlinear;
    end;


    indices:= RelativeOrders( pcgs );
#T here set the exponent `e' to `indices[ lg ]' !
    Info( InfoGroup, 2,
          "BaumClausenInfo: There are ", lg, " steps" );

    linear:= List( [ 0 .. indices[lg]-1 ] * ( e / indices[lg] ),
                   x -> [ x ] );

    for i in [ lg-1, lg-2 .. abel ] do

      Info( InfoGroup, 2,
            "BaumClausenInfo: Compute repres. of step ", i,
            " (central case)" );

      p:= indices[i];

      # `pexp' describes $g_i^p$.
      pexp:= ExponentsOfRelativePower( pcgs,i);
# { ? } ??

      root:= e/p;
#T enlarge the exponent if necessary!
      roots:= [ 0, root .. (p-1)*root ];
      linear:= ExtLinRep( i, linear, pexp, roots );

    od;

    # We are done if $G$ is abelian.
    if abel = 1 then
      return rec( pcgs     := pcgs,
                  kernel   := TrivialSubgroup( G ),
                  exponent := e,
                  nonlin   := [],
                  lin      := linear
                  );
    fi;


    # Step 3:
    # Define some local functions.
    # (We did not need them for abelian groups.)

    # `mulmoma' returns the product of two monomial matrices.
    mulmoma:= function( a, b )
      local prod, i;
      prod:= rec( perm := b.perm{ a.perm },
                  diag := [] );
      for i in [ 1 .. Length( a.perm ) ] do
        prod.diag[ b.perm[i] ]:= ( b.diag[ b.perm[i] ] + a.diag[i] ) mod e;
      od;
      return prod;
    end;

    # `poweval' evaluates the representation `rep' on the $p$-th power of
    # the conjugating element.
    # This $p$-th power is described by `poli'.
    poweval:= function( rep, poli )
      local pow, i;
      if IsEmpty( poli ) then
        return rec( perm:= [ 1 .. Length( rep[1].perm ) ],
                    diag:= [ 1 .. Length( rep[1].perm ) ] * 0 );
      fi;
      pow:= rep[ poli[1] ];
      for i in [ 2 .. Length( poli ) ] do
        pow:= mulmoma( pow, rep[ poli[i] ] );
      od;
      return pow;
    end;


    # Step 4:
    # Compute the actions of $g_j$, $j < abel$, on the representations
    # of $G_{abel}$.
    # Let $g_i^{g_j} = \prod_{k=1}^n g_k^{\alpha_{ik}^j}$,
    # and set $A_j = [ \alpha_{ik}^j} ]_{i,k}$.
    # Then the representation that maps $g_i$ to the root $\zeta_e^{c_i}$
    # is mapped to the representation that has images exponents
    # $A_j * (c_1, \ldots, c_n)$ under $g_j$.

    Info( InfoGroup, 2,
          "BaumClausenInfo: Initialize actions on abelian normal subgroup" );

    pilinear:= [];
    for j in [ 1 .. abel-1 ] do

      # Compute the matrix $A_j$.
      M:= List( [ abel .. lg ],
                i -> ExponentsOfPcElement( pcgs, pcgs[i]^pcgs[j],
                                           [ abel .. lg ] ) );

      # Compute the permutation corresponding to the action of $g_j$.
      pilinear[j]:= List( linear,
                          rep -> Position( linear,
                                           List( M * rep, x -> x mod e ) ) );

    od;


    # Step 5:
    # Run up the composition series from `abel' to `1',
    # and compute extensions resp. induced representations.
    # For each index, we have to update `linear', `pilinear',
    # `nonlin', `pinonlin', and `Xlist'.

    nonlin   := [];
    pinonlin := [];
    Xlist    := [];

    for i in [ abel-1, abel-2 .. 1 ] do

      p:= indices[i];

      # `poli' describes $g_i^p$.
      #was pexp:= ExponentsOfPcElement( pcgs, pcgs[i]^p );
      pexp:= ExponentsOfRelativePower( pcgs, i );
      poli:= Concatenation( List( [ i+1 .. lg ],
                                  x -> List( [ 1 .. pexp[x] ],
                                             y -> x-i ) ) );

      # `p'-th roots of unity
      roots:= [ 0 .. p-1 ] * ( e/p );

      Info( InfoGroup, 2,
            "BaumClausenInfo: Compute repres. of step ", i );

      # Step A:
      # Compute representations of $G_i$ arising from *linear*
      # representations of $G_{i+1}$.

      used        := BlistList( [ 1 .. Length( linear ) ], [] );
      nextlinear  := [];
      nextnonlin1 := [];
      d           := 1;

      pexp:= pexp{ [ i+1 .. lg ] };

      # At position `d', store the position of either the first extension
      # of `linear[d]' in `nextlinear' or the position of the induced
      # representation of `linear[d]' in `nextnonlin1'.
      Dpos1:= [];

      while d <> fail do

        rep:= linear[d];
        used[d]:= true;

        # `root' is the value of `rep' on $g_i^p$.
        root:= ( pexp * rep ) mod e;

        if pilinear[i][d] = d then

          # `linear[d]' extends to $G_i$.
          Dpos1[d]:= Length( nextlinear ) + 1;

          # Take a `p'-th root.
          root:= root / p;
#T enlarge the exponent if necessary!

          for j in roots do
            Add( nextlinear, Concatenation( [ root+j ], rep ) );
          od;

        else

          # We must fuse the representations in the orbit of `d'
          # under `pilinear[i]';
          # so we construct the induced representation `D'.

          Dpos1[d]:= Length( nextnonlin1 ) + 1;

          D:= List( rep, x -> rec( perm := [ 1 .. p ],
                                   diag := [ x ]
                                  ) );
          pos:= d;
          for j in [ 2 .. p ] do

            pos:= pilinear[i][ pos ];
            for k in [ 1 .. Length( rep ) ] do
              D[k].diag[j]:= linear[ pos ][k];
            od;
            used[ pos ]:= true;
            Dpos1[ pos ]:= Length( nextnonlin1 ) + 1;

          od;

          Add( nextnonlin1,
               Concatenation( [ rec( perm := Concatenation( [p], [1..p-1]),
                                     diag := Concatenation( [ 1 .. p-1 ] * 0,
                                                            [ root ] ) ) ],
                              D ) );
          Assert( 2, BaumClausenInfoDebug.testrep( pcgs{ [ i .. lg ] },
                              nextnonlin1[ Length( nextnonlin1 ) ], e ),
                  Concatenation( "BaumClausenInfo: failed assertion in ",
                      "inducing linear representations ",
                      "(i = ", String( i ), ")\n" ) );

        fi;

        d:= Position( used, false, d );

      od;


      # Step B:
      # Now compute representations of $G_i$ arising from *nonlinear*
      # representations of $G_{i+1}$ (if there are some).

      used:= BlistList( [ 1 .. Length( nonlin ) ], [] );
      nextnonlin2:= [];
      if Length( nonlin ) = 0 then
        d:= fail;
      else
        d:= 1;
      fi;

      # At position `d', store the position of the first extension resp.
      # of the induced representation of `nonlin[d]'in `nextnonlin2'.
      Dpos2:= [];

      while d <> fail do

        used[d]:= true;
        rep:= nonlin[d];

        if pinonlin[i][d] = d then

          # The representation $F = `rep'$ has `p' different extensions.
          # For `X = Xlist[i][d]', we have $`rep ^ X' = `rep'^{g_i}$,
          # i.e., $X^{-1} F X = F^{g_i}$.
          # Representing matrix $F(g_i)$ is $c X$ with $c^p X^p = F(g_i^p)$,
          # so $c^p X^p.diag[k] = F(g_i^p).diag[k]$ for all $k$ ;
          # for determination of $c$ we look at `k = X^p.perm[1]'.

          X:= Xlist[i][d];
          image:= X.perm[1];
          value:= X.diag[ image ];
          for j in [ 2 .. p ] do

            image:= X.perm[ image ];
            value:= X.diag[ image ] + value;
            # now `image = X^j.perm[1]', `value = X^j.diag[ image ]'

          od;

          # Subtract this from $F(g_i^p).diag[k]$;
          # note that `image' is the image of 1 under `X^p', so also
          # under $F(g_i^p)$.
          value:= - value;
          image:= 1;
          for j in poli do
            image:= rep[j].perm[ image ];
            value:= rep[j].diag[ image ] + value;
          od;

          value:= ( value / p ) mod e;
#T enlarge the exponent if necessary!

          Dpos2[d]:= Length( nextnonlin2 ) + 1;

          # Compute the `p' extensions.
          for k in roots do
            Add( nextnonlin2, Concatenation(
                    [ rec( perm := X.perm,
                      diag := List( X.diag,
                             x -> ( x  + k + value ) mod e ) ) ], rep ) );
            Assert( 2, BaumClausenInfoDebug.testrep( pcgs{ [ i .. lg ] },
                                nextnonlin2[ Length( nextnonlin2 ) ], e ),
                    Concatenation( "BaumClausenInfo: failed assertion in ",
                        "extending nonlinear representations ",
                        "(i = ", String( i ), ")\n" ) );
          od;

        else

          # `$F$ = nonlin[d]' fuses with `p-1' partners given by the orbit
          # of `d' under `pinonlin[i]'.
          # The new irreducible representation of $G_i$ will be
          # $X Ind( F ) X^{-1}$ with $X$ the block diagonal matrix
          # consisting of blocks $X_{i,F}^{(k)}$ defined by
          # $X_{i,F}^{(0)} = Id$,
          # and $X_{i,F}^{(k)} = X_{i,\pi_i^{k-1} F} X_{i,F}^{(k-1)}$
          # for $k > 0$.

          # The matrix for $g_i$ in the induced representation $Ind( F )$ is
          # of the form
          #       | 0   F(g_i^p) |
          #       | I      0     |
          # Thus $X Ind(F) X^{-1} ( g_i )$ is the block diagonal matrix
          # consisting of the blocks
          # $X_{i,F}, X_{i,\pi_i F}, \ldots, X_{i,\pi_i^{p-2} F}$, and
          # $F(g_i^p) \cdot ( X_{i,F}^{(p-1)} )^{-1}$.

          dim:= Length( rep[1].diag );
          Dpos2[d]:= Length( nextnonlin2 ) + 1;

          # We make a copy of `rep' because we want to change it.
          D:= List( rep, record -> rec( perm := ShallowCopy( record.perm ),
                                        diag := ShallowCopy( record.diag )
                                       ) );

          # matrices for $g_j, i\< j \leq n$
          pos:= d;
          for j in [ 1 .. p-1 ] * dim do
            pos:= pinonlin[i][ pos ];
            for k in [ 1 .. Length( rep ) ] do
              Append( D[k].diag, nonlin[ pos ][k].diag );
              Append( D[k].perm, nonlin[ pos ][k].perm + j );
            od;

            used[ pos ]:= true;
            Dpos2[ pos ]:= Length( nextnonlin2 ) + 1;

          od;

          # The matrix of $g_i$ is a block-cycle with blocks
          # $X_{i,\pi_i^k(F)}$ for $0 \leq k \leq p-2$,
          # and $F(g_i^p) \cdot (X_{i,F}^{(p-1)})^{-1}$.

          X:= Xlist[i][d];      # $X_{i,F}$
          pos:= d;
          for j in [ 1 .. p-2 ] do
            pos:= pinonlin[i][ pos ];
            X:= mulmoma( Xlist[i][ pos ], X );
          od;

          # `invX' is the inverse of `X'.
          invX:= rec( perm := [], diag := [] );
          for j in [ 1 .. Length( X.diag ) ] do
            invX.perm[ X.perm[j] ]:= j;
            invX.diag[j]:= e - X.diag[ X.perm[j] ];
          od;
#T improve this using the {} operator!

          X:= mulmoma( poweval( rep, poli ), invX );
          D_gi:= rec( perm:= List( X.perm, x -> x  + ( p-1 ) * dim ),
                      diag:= [] );

          pos:= d;
          for j in [ 0 .. p-2 ] * dim do

            # $X_{i,\pi_i^j F}$
            Append( D_gi.diag, Xlist[i][ pos ].diag);
            Append( D_gi.perm, Xlist[i][ pos ].perm + j);
            pos:= pinonlin[i][ pos ];

          od;

          Append( D_gi.diag, X.diag );

          Add( nextnonlin2, Concatenation( [ D_gi ], D ) );
          Assert( 2, BaumClausenInfoDebug.testrep( pcgs{ [ i .. lg ] },
                              nextnonlin2[ Length( nextnonlin2 ) ], e ),
                  Concatenation( "BaumClausenInfo: failed assertion in ",
                      "inducing nonlinear representations ",
                      "(i = ", String( i ), ")\n" ) );

        fi;

        d:= Position( used, false, d );

      od;


      # Step C:
      # Compute `pilinear', `pinonlin', and `Xlist'.

      pinextlinear  := [];
      pinextnonlin1 := [];
      nextXlist1    := [];

      pinextnonlin2 := [];
      nextXlist2    := [];

      for j in [ 1 .. i-1 ] do

        pinextlinear[j]  := [];
        pinextnonlin1[j] := [];
        nextXlist1[j]    := [];

        # `cexp' describes $g_i^{g_j}$.
        cexp:= ExponentsOfPcElement( pcgs, pcgs[i]^pcgs[j], [ i .. lg ] );

        # Compute `pilinear', and the parts of `pinonlin', `Xlist'
        # arising from *linear* representations for the next step,
        # that is, compute the action of $g_j$ on `nextlinear' and
        # `nextnonlin1'.

        for k in [ 1 .. Length( linear ) ] do

          if pilinear[i][k] = k then

            # Let $F = `linear[k]'$ extend to
            # $D = D_0, D_1, \ldots, D_{p-1}$,
            # $C$ the first extension of $\pi_j(F)$.
            # We have $D( g_i^{g_j} ) = D^{g_j}(g_i) = ( C \chi^l )(g_i)$
            # where $\chi^l(g_i)$ is the $l$-th power of the chosen
            # primitive $p$-th root of unity.

            D:= nextlinear[ Dpos1[k] ];

            # `pos' is the position of $C$ in `nextlinear'.
            pos:= Dpos1[ pilinear[j][k] ];
            l:= ( (  cexp * D                   # $D( g_i^{g_j} )$
                     - nextlinear[ pos ][1] )   # $C(g_i)$
                  * p / e ) mod p;

            for u in [ 0 .. p-1 ] do
              Add( pinextlinear[j], pos + ( ( l + u * cexp[1] ) mod p ) );
            od;

          elif not IsBound( pinextnonlin1[j][ Dpos1[k] ] ) then

            # $F$ fuses with its conjugates under $g_i$,
            # the conjugating matrix describing the action of $g_j$
            # is a permutation matrix.
            # Let $D = F^{g_j}$, then the permutation corresponds to
            # the mapping between the lists
            # $[ D, (F^{g_i})^{g_j}, \ldots, (F^{g_i^{p-1}})^{g_j} ]$
            # and $[ D, D^{g_i}, \ldots, D^{g_i^{p-1}} ]$;
            # The constituents in the first list are the images of
            # the induced representation of $F$ under $g_j$,
            # and those in the second list are the constituents of the
            # induced representation of $D$.

            # While `u' runs from $1$ to $p$,
            # `pos' runs over the positions of $(F^{g_i^u})^{g_j}$ in
            # `linear'.
            # `orb' is the list of positions of the $(F^{g_j})^{g_i^u}$,
            # cyclically permuted such that the smallest entry is the
            # first.

            pinextnonlin1[j][ Dpos1[k] ]:= Dpos1[ pilinear[j][k] ];
            pos:= pilinear[j][k];
            orb:= [ pos ];
            min:= 1;
            minval:= pos;
            for u in [ 2 .. p ] do
              pos:= pilinear[i][ pos ];
              orb[u]:= pos;
              if pos < minval then
                minval:= pos;
                min:= u;
              fi;
            od;
            if 1 < min then
              orb:= Concatenation( orb{ [ min .. p ] },
                                   orb{ [ 1 .. min-1 ] } );
            fi;

            # Compute the conjugating matrix `X'.
            # Let $C$ be the stored representation $\tau_j D$
            # equivalent to $D^{g_j}$.
            # Compute the position of $C$ in `pinextnonlin1'.

            C:= nextnonlin1[ pinextnonlin1[j][ Dpos1[k] ] ];
            D:= nextnonlin1[ Dpos1[k] ];

            # `sigma' is the bijection of constituents in the restrictions
            # of $D$ and $\tau_j D$ to $G_{i-1}$.
            # More precisely, $\pi_j(\pi_i^{u-1} F) = \Phi_{\sigma(u-1)}$.
            sigma:= [];
            pos:= k;
            for u in [ 1 .. p ] do
              sigma[u]:= Position( orb, pilinear[j][ pos ] );
              pos:= pilinear[i][ pos ];
            od;

            # Compute $\pi = \sigma^{-1} (1,2,\ldots,p) \sigma$.
            pi:= [];
            pi[ sigma[p] ]:= sigma[1];
            for u in [ 1 .. p-1 ] do
              pi[ sigma[u] ]:= sigma[ u+1 ];
            od;

            # Compute the values $c_{\pi^u(0)}$, for $0 \leq u \leq p-1$.
            # Note that $c_0 = 1$.
            # (Here we encode of course the exponents.)
            constants:= [ 0 ];
            l:= 1;

            for u in [ 1 .. p-1 ] do

              # Compute $c_{\pi^u(0)}$.
              # (We have $`l' = 1 + \pi^{u-1}(0)$.)
              # Note that $B_u = [ [ 1 ] ]$ for $0\leq u\leq p-2$,
              # and $B_{p-1} = \Phi_0(g_i^p)$.

              # Next we compute the image under $A_{\pi^{u-1}(0)}$;
              # this matrix is in the $(\pi^{u-1}(0)+1)$-th column block
              # and in the $(\pi^u(0)+1)$-th row block of $D^{g_j}$.
              # Since we do not have this matrix explicitly,
              # we use the conjugate representation and the action
              # encoded by `cexp'.
              # Note the necessary initial shift because we use the
              # whole representation $D$ and not a single constituent;
              # so we shift by $\pi^u(0)+1$.
#T `perm' is nontrivial only for v = 1, this should make life easier.
              value:= 0;
              image:= pi[l];
              for v in [ 1 .. lg-i+1 ] do
                for w in [ 1 .. cexp[v] ] do
                  image:= D[v].perm[ image ];
                  value:= value + D[v].diag[ image ];
                od;
              od;

              # Next we divide by the corresponding value in
              # the image of the first standard basis vector under
              # $B_{\sigma\pi^{u-1}(0)}$.
              value:= value - C[1].diag[ sigma[l] ];
              constants[ pi[l] ]:= ( constants[l] - value ) mod e;
              l:= pi[l];

            od;

            # Put the conjugating matrix together.
            X:= rec( perm := [],
                     diag := constants );
            for u in [ 1 .. p ] do
              X.perm[ sigma[u] ]:= u;
            od;

            Assert( 2, BaumClausenInfoDebug.checkconj( pcgs, i, lg, j,
                         nextnonlin1[ Dpos1[k] ],
                         nextnonlin1[ pinextnonlin1[j][ Dpos1[k] ] ],
                         X, e ),
                  Concatenation( "BaumClausenInfo: failed assertion on ",
                      "conjugating matrices for linear repres. ",
                      "(i = ", String( i ), ")\n" ) );
            nextXlist1[j][ Dpos1[k] ]:= X;

          fi;

        od;


        # Compute the remaining parts of `pinonlin' and `Xlist' for
        # the next step, namely for those *nonlinear* representations
        # arising from *nonlinear* ones.

        nextXlist2[j]    := [];
        pinextnonlin2[j] := [];

        # `cexp' describes $g_i^{g_j}$.
        cexp:= ExponentsOfPcElement( pcgs, pcgs[i]^pcgs[j], [ i .. lg ] );

        # Compute the action of $g_j$ on `nextnonlin2'.

        for k in [ 1 .. Length( nonlin ) ] do

          if pinonlin[i][k] = k then

            # Let $F = `nonlin[k]'$ extend to
            # $D = D_0, D_1, \ldots, D_{p-1}$,
            # $C$ the first extension of $\pi_j(F)$.
            # We have $X_{j,F} \cdot F^{g_j} = \pi_j(F) \cdot X_{j,F}$,
            # thus $X_{j,F} \cdot D( g_i^{g_j} )
            # = X_{j,F} \cdot D^{g_j}(g_i)
            # = ( C \chi^l )(g_i) \cdot X_{j,F}$
            # where $\chi^l(g_i)$ is the $l$-th power of the chosen
            # primitive $p$-th root of unity.

            D:= nextnonlin2[ Dpos2[k] ];

            # `pos' is the position of $C$ in `nextnonlin2'.
            pos:= Dpos2[ pinonlin[j][k] ];

            # Find a nonzero entry in $X_{j,F} \cdot D( g_i^{g_j} )$.
            image:= Xlist[j][k].perm[1];
            value:= Xlist[j][k].diag[ image ];
            for u in [ 1 .. lg-i+1 ] do
              for v in [ 1 .. cexp[u] ] do
                image:= D[u].perm[ image ];
                value:= value + D[u].diag[ image ];
              od;
            od;

            # Subtract the corresponding value in $C(g_i) \cdot X_{j,F}$.
            C:= nextnonlin2[ pos ];
            Assert( 2, image = Xlist[j][k].perm[ C[1].perm[1] ],
                    "BaumClausenInfo: failed assertion on conj. matrices" );
            value:= value -
                ( C[1].diag[ C[1].perm[1] ] + Xlist[j][k].diag[ image ] );
            l:= ( value * p / e ) mod p;

            for u in [ 0 .. p-1 ] do
              pinextnonlin2[j][ Dpos2[k] + u ]:=
                     pos + ( ( l + u * cexp[1] ) mod p );
              nextXlist2[j][ Dpos2[k] + u ]:= Xlist[j][k];
            od;

            Assert( 2, BaumClausenInfoDebug.checkconj( pcgs, i, lg, j,
                         nextnonlin2[ Dpos2[k] ],
                         nextnonlin2[ pinextnonlin2[j][ Dpos2[k] ] ],
                         Xlist[j][k], e ),
                  Concatenation( "BaumClausenInfo: failed assertion on ",
                      "conjugating matrices for nonlinear repres. ",
                      "(i = ", String( i ), ")\n" ) );

          elif not IsBound( pinextnonlin2[j][ Dpos2[k] ] ) then

            # $F$ fuses with its conjugates under $g_i$, yielding $D$.

            dim:= Length( nonlin[k][1].diag );

            # Let $C$ be the stored representation $\tau_j D$
            # equivalent to $D^{g_j}$.
            # Compute the position of $C$ in `pinextnonlin2'.
            pinextnonlin2[j][ Dpos2[k] ]:= Dpos2[ pinonlin[j][k] ];

            C:= nextnonlin2[ pinextnonlin2[j][ Dpos2[k] ] ];
            D:= nextnonlin2[ Dpos2[k] ];

            # Compute the positions of the constituents;
            # `orb[k]' is the position of $\Phi_{k-1}$ in `nonlin'.
            pos:= pinonlin[j][k];
            orb:= [ pos ];
            min:= 1;
            minval:= pos;
            for u in [ 2 .. p ] do
              pos:= pinonlin[i][ pos ];
              orb[u]:= pos;
              if pos < minval then
                minval:= pos;
                min:= u;
              fi;
            od;
            if 1 < min then
              orb:= Concatenation( orb{ [ min .. p ] },
                                   orb{ [ 1 .. min-1 ] } );
            fi;

            # `sigma' is the bijection of constituents in the restrictions
            # of $D$ and $\tau_j D$ to $G_{i-1}$.
            # More precisely, $\pi_j(\pi_i^{u-1} F) = \Phi_{\sigma(u-1)}$.
            sigma:= [];
            pos:= k;
            for u in [ 1 .. p ] do
              sigma[u]:= Position( orb, pinonlin[j][ pos ] );
              pos:= pinonlin[i][ pos ];
            od;

            # Compute $\pi = \sigma^{-1} (1,2,\ldots,p) \sigma$.
            pi:= [];
            pi[ sigma[p] ]:= sigma[1];
            for u in [ 1 .. p-1 ] do
              pi[ sigma[u] ]:= sigma[ u+1 ];
            od;

            # Compute the positions of the constituents
            # $F_0, F_{\pi(0)}, \ldots, F_{\pi^{p-1}(0)}$.
            Forb:= [ k ];
            pos:= k;
            for u in [ 2 .. p ] do
              pos:= pinonlin[i][ pos ];
              Forb[u]:= pos;
            od;

            # Compute the values $c_{\pi^u(0)}$, for $0 \leq u \leq p-1$.
            # Note that $c_0 = 1$.
            # (Here we encode of course the exponents.)
            constants:= [ 0 ];
            l:= 1;

            for u in [ 1 .. p-1 ] do

              # Compute $c_{\pi^u(0)}$.
              # (We have $`l' = 1 + \pi^{u-1}(0)$.)
              # Note that $B_u = X_{j,\pi_j^u \Phi_0}$ for $0\leq u\leq p-2$,
              # and $B_{p-1} =
              #      \Phi_0(g_i^p) \cdot ( X_{j,\Phi_0}^{(p-1)} )^{-1}$

              # First we get the image and diagonal value of
              # the first standard basis vector under $X_{j,\pi^u(0)}$.
              image:= Xlist[j][ Forb[ pi[l] ] ].perm[1];
              value:= Xlist[j][ Forb[ pi[l] ] ].diag[ image ];

              # Next we compute the image under $A_{\pi^{u-1}(0)}$;
              # this matrix is in the $(\pi^{u-1}(0)+1)$-th column block
              # and in the $(\pi^u(0)+1)$-th row block of $D^{g_j}$.
              # Since we do not have this matrix explicitly,
              # we use the conjugate representation and the action
              # encoded by `cexp'.
              # Note the necessary initial shift because we use the
              # whole representation $D$ and not a single constituent;
              # so we shift by `dim' times $\pi^u(0)+1$.
              image:= dim * ( pi[l] - 1 ) + image;
              for v in [ 1 .. lg-i+1 ] do
                for w in [ 1 .. cexp[v] ] do
                  image:= D[v].perm[ image ];
                  value:= value + D[v].diag[ image ];
                od;
              od;

              # Next we divide by the corresponding value in
              # the image of the first standard basis vector under
              # $B_{\sigma\pi^{u-1}(0)} X_{j,\pi^{u-1}(0)}$.
              # Note that $B_v$ is in the $(v+2)$-th row block for
              # $0 \leq v \leq p-2$, in the first row block for $v = p-1$,
              # and in the $(v+1)$-th column block of $C$.
              v:= sigma[l];
              if v = p then
                image:= C[1].perm[1];
              else
                image:= C[1].perm[ v*dim + 1 ];
              fi;
              value:= value - C[1].diag[ image ];
              image:= Xlist[j][ Forb[l] ].perm[ image - ( v - 1 ) * dim ];
              value:= value - Xlist[j][ Forb[l] ].diag[ image ];
              constants[ pi[l] ]:= ( constants[l] - value ) mod e;
              l:= pi[l];

            od;

            # Put the conjugating matrix together.
            X:= rec( perm:= [],
                     diag:= [] );
            pos:= k;
            for u in [ 1 .. p ] do
              Append( X.diag, List( Xlist[j][ pos ].diag,
                                    x -> ( x + constants[u] ) mod e ) );
              X.perm{ [ ( sigma[u] - 1 )*dim+1 .. sigma[u]*dim ] }:=
                  Xlist[j][ pos ].perm + (u-1) * dim;
              pos:= pinonlin[i][ pos ];
            od;

            Assert( 2, BaumClausenInfoDebug.checkconj( pcgs, i, lg, j,
                         nextnonlin2[ Dpos2[k] ],
                         nextnonlin2[ pinextnonlin2[j][ Dpos2[k] ] ],
                         X, e ),
                  Concatenation( "BaumClausenInfo: failed assertion on ",
                      "conjugating matrices for nonlinear repres. ",
                      "(i = ", String( i ), ")\n" ) );
            nextXlist2[j][ Dpos2[k] ]:= X;

          fi;

        od;

      od;

      # Finish the update for the next index.
      linear   := nextlinear;
      pilinear := pinextlinear;

      nonlin   := Concatenation( nextnonlin1, nextnonlin2 );
      pinonlin := List( [ 1 .. i-1 ],
                       j -> Concatenation( pinextnonlin1[j],
                         pinextnonlin2[j] + Length( pinextnonlin1[j] ) ) );
      Xlist    := List( [ 1 .. i-1 ],
                    j -> Concatenation( nextXlist1[j], nextXlist2[j] ) );

    od;


    # Step 6: If necessary transfer the representations back to the
    #         original group.

    if     IsBound( hom )
       and not IsTrivial( KernelOfMultiplicativeGeneralMapping( hom ) ) then
      Info( InfoGroup, 2,
            "BaumClausenInfo: taking preimages in the original group" );

      kernel:= KernelOfMultiplicativeGeneralMapping( hom );
      k:= Pcgs( kernel );
      pcgs:= PcgsByPcSequence( ElementsFamily( FamilyObj( kernel ) ),
               Concatenation( List( pcgs,
                                    x -> PreImagesRepresentative( hom, x ) ),
                              k ) );
      k:= ListWithIdenticalEntries( Length( k ), 0 );

      linear:= List( linear, rep -> Concatenation( rep, k ) );

      for rep in nonlin do
        dim:= Length( rep[1].perm );
        M:= rec( perm:= [ 1 .. dim ],
                 diag:= [ 1 .. dim ] * 0 );
        for i in k do
          Add( rep, M );
        od;
      od;

    else
      kernel:= TrivialSubgroup( G );
    fi;

    # Return the result (for nonabelian groups).
    return Immutable( rec( pcgs     := pcgs,
                           kernel   := kernel,
                           exponent := e,
                           nonlin   := nonlin,
                           lin      := linear
                          ) );
    end );


#############################################################################
##
#F  IrreducibleRepresentationsByBaumClausen( <G> )  .  for a supersolv. group
##
BindGlobal( "IrreducibleRepresentationsByBaumClausen", function( G )
    local mrep,    # list of images lists for the result
          info,    # result of `BaumClausenInfo'
          lg,      # composition length of `G'
          rep,     # loop over the representations
          gcd,     # g.c.d. of the exponents in `rep'
          Ee,      # complex root of unity needed for `rep'
          images,  # one list of images
          dim,     # current dimension
          i, k,    # loop variables
          mat;     # one representing matrix

    mrep:= [];
    info:= BaumClausenInfo( G );
    lg:= Length( info.pcgs );

    if info.lin=[[]] then # trivial group
        return [GroupHomomorphismByImagesNC(G,Group([[1]]),[],[])];
    fi;

    # Compute the images of linear representations on the pcgs.
    for rep in info.lin do
      gcd := Gcd( rep );
      if gcd = 0 then
        Add( mrep, List( rep, x -> [ [ 1 ] ] ) );
      else
        gcd:= GcdInt( gcd, info.exponent );
        Ee:= E( info.exponent / gcd );
        Add( mrep, List( rep / gcd, x -> [ [ Ee^x ] ] ) );
      fi;
    od;

    # Compute the images of nonlinear representations on the pcgs.
    for rep in info.nonlin do
      images:= [];
      dim:= Length( rep[1].perm );
      gcd:= GcdInt( Gcd( List( rep, x -> Gcd( x.diag ) ) ), info.exponent );
      Ee:= E( info.exponent / gcd );
      for i in [ 1 .. lg ] do
        mat:= NullMat( dim, dim, Rationals );
        for k in [ 1 .. dim ] do
          mat[k][ rep[i].perm[k] ]:=
              Ee^( rep[i].diag[ rep[i].perm[k] ] / gcd );
        od;
        images[i]:= mat;
      od;
      Add( mrep, images );
    od;

    return List( mrep, images -> GroupHomomorphismByImagesNC( G,
                     GroupByGenerators( images ), info.pcgs, images ) );
    end );


#############################################################################
##
#M  IrreducibleRepresentations( <G> ) . for an abelian by supersolvable group
##
InstallMethod( IrreducibleRepresentations,
    "(abelian by supersolvable) finite group",
    [ IsGroup and IsFinite ], 1, # higher than Dixon's method
    function( G )
    if IsAbelian( SupersolvableResiduum( G ) ) then
      return IrreducibleRepresentationsByBaumClausen( G );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IrreducibleRepresentations( <G>, <F> )  . . for a group and `Cyclotomics'
##
InstallMethod( IrreducibleRepresentations,
    "finite group, Cyclotomics",
    [ IsGroup and IsFinite, IsCyclotomicCollection and IsField ],
    function( G, F )
    if F <> Cyclotomics then
      TryNextMethod();
    else
      return IrreducibleRepresentations( G );
    fi;
    end );


#############################################################################
##
#M  IrreducibleRepresentations( <G>, <f> )
##
InstallMethod( IrreducibleRepresentations,
    "for a finite group over a finite field",
    [ IsGroup and IsFinite, IsField and IsFinite ],
    function( G, f )
    local md, hs, gens, M, mats, H, hom;

    md := IrreducibleModules( G, f, 0 );
    gens:=md[1];
    md:=md[2];
    hs := [];
    for M in md do
        mats := M.generators;
        H    := Group( mats, IdentityMat( M.dimension, f ) );
        hom  := GroupHomomorphismByImagesNC( G, H, gens, mats );
        Add( hs, hom );
    od;
    return hs;
    end );


#############################################################################
##
#M  IrrBaumClausen( <G>)  . . . .  irred. characters of a supersolvable group
##
InstallMethod( IrrBaumClausen,
    "for a (solvable) group",
    [ IsGroup ],
    function( G )
    local mulmoma,        # local function  to multiply monomial matrices
          ccl,            # conjugacy classes of `G'
          tbl,            # character table of `G'
          info,           # result of `BaumClausenInfo'
          pcgs,           # value of `info.pcgs'
          lg,             # composition length
          exps,           # exponents of class representatives
          cr,             # exps sorted
          i, j, jj, k,    # loop variables
          irreducibles,   # list of irreducible characters
          rep,            # loop over the representations
          l,              # list of monomial matrices
          gcd,            # g.c.d. of the exponents in `rep'
          q,              #
          o,              # order of root of unity
          e,              # exponent
          Ee,             # complex root of unity needed for `rep'
          chi,            # one character values list
          deg,            # character degree
          idmat,          # identity matrix
          perm,           # entries of monomial matrix
          diag,
          trace;          # trace of a matrix

    mulmoma:= function( a, b )
      local prod;
      prod:= rec( perm := b.perm{ a.perm },
                  diag := [] );
      prod.diag{b.perm} := b.diag{b.perm} + a.diag;
      return prod;
    end;
    tbl:= CharacterTable( G );
    ccl:= ConjugacyClasses( tbl );
    SetExponent( G, Exponent( tbl ) );
    info:= BaumClausenInfo( G );

    # The trivial group does not admit matrix arithmetic for evaluations.
    if IsTrivial( G ) then
      return [ Character( G, [ 1 ] ) ];
    fi;

    pcgs:= info.pcgs;
    lg:= Length( pcgs );

    exps:= List( ccl,
                 c -> ExponentsOfPcElement( pcgs, Representative( c ) ) );

    # Compute the linear irreducibles.
    # Compute the roots of unity only once for all linear characters.
    # ($q$-th roots suffice, where $q$ divides the number of linear
    # characters and the known exponent; we do *not* compute the smallest
    # possible roots for each representation.)
    q:= Gcd( info.exponent, Length( info.lin ) );
    gcd:= info.exponent / q;
    Ee:= E(q);
    Ee:= List( [ 0 .. q-1 ], i -> Ee^i );

    if IsPcGroup( G ) then
      # We can efficiently compute the linear characters independently (and
      # take advantage if they were computed before)
      irreducibles := ShallowCopy( LinearCharacters( G ) );
    else
      irreducibles:= List( info.lin, rep ->
          Character( tbl, Ee{ ( ( exps * rep ) / gcd mod q ) + 1 } ) );
    fi;

    # Compute the nonlinear irreducibles.
    if not IsEmpty( info.nonlin ) then
      cr := SortedList(exps);
      for rep in info.nonlin do
        gcd:= GcdInt( Gcd( List( rep, x -> Gcd( x.diag ) ) ), info.exponent );
        o := info.exponent / gcd;
        deg:= Length( rep[1].perm );
        idmat:= rec( perm := [ 1 .. deg ], diag := [ 1 .. deg ] * 0 );
        Add(cr[1], deg);
        l := List([1..lg], i-> idmat);
        # We go through sorted list of exponents and reuse
        # partial product from previous representative.
        for i in [2..Length(cr)] do
          j := 1;
          while cr[i-1][j] = cr[i][j] do
            j := j+1;
          od;
          for k in [cr[i-1][j]+1..cr[i][j]] do
            l[j] := mulmoma(l[j], rep[j]);
          od;
          for jj in [j+1..lg] do
            l[jj] := l[jj-1];
            for k in [1..cr[i][jj]] do
              l[jj] := mulmoma(l[jj], rep[jj]);
            od;
          od;
          # Compute the character value.
          trace:= 0*[1..o];
          perm := l[lg].perm;
          diag := l[lg].diag;
          for k in [ 1 .. deg ] do
            if perm[k] = k then
              e := (diag[k] / gcd) mod o;
              trace[e+1]:= trace[e+1] + 1;
            fi;
          od;
          # We append the character values to the exponents lists
          # and remove them (in the right order) after this loop.
          Add(cr[i], CycList(trace));
        od;
        chi := List(exps, Remove);
        Add( irreducibles, Character( tbl, chi ) );
      od;
    fi;

    # Return the result.
    return irreducibles;
    end );


#############################################################################
##
#F  InducedRepresentationImagesRepresentative( <rep>, <H>, <R>, <g> )
##
##  Let $<rep>_H$ denote the restriction of the group homomorphism <rep> to
##  the group <H>, and $\phi$ the induced representation of $<rep>_H$ to $G$,
##  where <R> is a transversal of <H> in $G$.
##  `InducedRepresentationImagesRepresentative' returns the image of the
##  element <g> of $G$ under $\phi$.
##
InstallGlobalFunction( InducedRepresentationImagesRepresentative,
    function( rep, H, R, g )
    local len, blocks, i, k, kinv, j;

    len:= Length( R );
    blocks:= [];

    for i in [ 1 .. len ] do
      k:= R[i] * g;
      kinv:= Inverse( k );
      j:= PositionProperty( R, r -> r * kinv in H );
      blocks[i]:= [ i, j, ImagesRepresentative( rep, k / R[j] ) ];
    od;

    return BlockMatrix( blocks, len, len );
end );


#############################################################################
##
#F  InducedRepresentation( <rep>, <G> ) . . . . induced matrix representation
#F  InducedRepresentation( <rep>, <G>, <R> )
#F  InducedRepresentation( <rep>, <G>, <R>, <H> )
##
##  Let <rep> be a matrix representation of the group $H$, which is a
##  subgroup of the group <G>.
##  `InducedRepresentation' returns the induced matrix representation of <G>.
##
##  The optional third argument <R> is a right transversal of $H$ in <G>.
##  If the fourth optional argument <H> is given then it must be a subgroup
##  of the source of <rep>, and the induced representation of the restriction
##  of <rep> to <H> is computed.
##
InstallGlobalFunction( InducedRepresentation, function( arg )
    local rep, G, H, R, gens, images, map;

    # Get and check the arguments.
    if   Length( arg ) = 2 and IsGroupHomomorphism( arg[1] )
                           and IsGroup( arg[2] ) then
      rep := arg[1];
      G   := arg[2];
      H   := Source( rep );
      R   := RightTransversal( G, H );

    elif Length( arg ) = 3 and IsGroupHomomorphism( arg[1] )
                           and IsGroup( arg[2] )
                           and IsHomogeneousList( arg[3] ) then
      rep := arg[1];
      G   := arg[2];
      R   := arg[3];
      H   := Source( rep );

    elif Length( arg ) = 4 and IsGroupHomomorphism( arg[1] )
                           and IsGroup( arg[2] )
                           and IsHomogeneousList( arg[3] )
                           and IsGroup( arg[4] ) then
      rep := arg[1];
      G   := arg[2];
      R   := arg[3];
      H   := arg[4];

    else
      Error( "usage: InducedRepresentation(<rep>,<G>[,<R>[,<H>]])" );
    fi;

    # Handle a trivial case.
    if Length( R ) = 1 then
      return rep;
    fi;

    # Construct the images of the generators of <G>.
    gens:= GeneratorsOfGroup( G );
    images:= List( gens,
        g -> InducedRepresentationImagesRepresentative( rep, H, R, g ) );

    # Construct and return the homomorphism.
    map:= GroupHomomorphismByImagesNC( G, GroupByGenerators( images ),
                                     gens, images );
    SetIsSurjective( map, true );
    return map;
end );


#############################################################################
##
#M  <rep> ^ <G>
##
InstallOtherMethod( \^,
    "for group homomorphism and group (induction)",
    [ IsGroupHomomorphism, IsGroup ],
    function( rep, G )
    if IsMatrixGroup( Range( rep ) ) and IsSubset( Source( rep ), G ) then
      return InducedRepresentation( rep, G );
    else
      TryNextMethod();
    fi;
    end );
