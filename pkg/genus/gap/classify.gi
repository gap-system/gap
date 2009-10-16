#############################################################################
##
#W  classify.gd            GAP 4 package `genus'                Thomas Breuer
##
#H  @(#)$Id: classify.gi,v 1.3 2001/09/21 16:16:31 gap Exp $
##
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
Revision.( "pkg/genus/classify_gi" ) :=
    "@(#)$Id: classify.gi,v 1.3 2001/09/21 16:16:31 gap Exp $";


#############################################################################
##
#F  RHInfo( <tbl> )
##
InstallGlobalFunction( RHInfo, function( tbl )

    local repcycsub,    # list of representatives of cyclic subgroups
          classes,
          orb,
          ind,
          rho,
          i,
          rat,
          inv,
          v;

    # Compute representatives of cyclic subgroups,
    # and the normalizers of the centralizer in the normalizer.
    repcycsub:= [ 1 ];
    classes:= [ 2 .. NrConjugacyClasses( tbl ) ];
    while not IsEmpty( classes ) do
      orb:= ClassOrbit( tbl, classes[1] );
      SubtractSet( classes, orb );
      Add( repcycsub, orb[1] );
    od;

    ind:= Concatenation( List( repcycsub, i -> InducedCyclic( tbl, [i] ) ) );
    ind:= List( ind, x -> x{ repcycsub } );
    rho:= ind[1];
    ind[1]:= 2 * rho;
    for i in [ 2 .. Length( ind ) ] do
      ind[i]:= rho - ind[i];
    od;

    rat:= List( RationalizedMat( Irr( tbl ) ), x -> x{ repcycsub } );
    inv:= rat^-1;

    v:= List( repcycsub, x -> 2 );
    v[1]:= 2 - 2 * Size( tbl );

    # Return the info record.
    return rec( repcycsub := repcycsub,
                T         := ind * inv,
                v         := v * inv    );
end );


#############################################################################
##
#F  InfiniteSeriesOfExceptions( <tbl>, <repcycsub> )
##
InstallGlobalFunction( InfiniteSeriesOfExceptions, function( tbl, repcycsub )
    local der,
          nsg,
          case1,
          tbl_classes,
          result,
          list,
          p, i;

    # Compute the classes of the derived subgroup.
    der:= ClassPositionsOfDerivedSubgroup( tbl );

    # Compute the classes of nontrivial normal subgroups.
    nsg:= ShallowCopy( ClassPositionsOfNormalSubgroups( tbl ) );
    Sort( nsg, function( a, b ) return Length( a ) < Length( b ); end );
    nsg:= nsg{ [ 2 .. Length( nsg ) ] };

    # Check whether case 1 can occur.
    if not IsAbelian( tbl ) then
      case1:= true;
    elif ForAll( Irr( tbl ), chi -> ForAll( chi, IsInt ) ) then
      case1:= 8 < Size( tbl );
    else
      Error( "implemented only for ambivalent groups" );
    fi;

    tbl_classes:= SizesConjugacyClasses( tbl );
    result:= [];
    for list in nsg do

      p:= Length( list );
      if case1 and IsPrimeInt( p )
               and ForAll( list, x -> tbl_classes[x] = 1 ) then
        AddSet( result, list );
      elif IsSubset( der, list ) and der <> list then
        for i in [ 1 .. Length( result ) ] do
          if IsSubset( list, result[i] ) then
            Unbind( result[i] );
          fi;
        od;
        result:= Set( result );
        AddSet( result, list );
      fi;

    od;

    # Return the result.
    return List( result, list -> Filtered( [ 1 .. Length( repcycsub ) ],
                                           i -> not repcycsub[i] in list ) );
end );


#############################################################################
##
#F  NextVectorSameL1Norm( <v> )
##
InstallGlobalFunction( NextVectorSameL1Norm, function( v )
    local s, n;

    n:= Length( v );
    s:= n;
    while 0 < s and v[s] = 0 do
      s:= s-1;
    od;
    if s <= 1 then
      return fail;
    fi;
    v:= ShallowCopy( v );
    v[ s-1 ]:= v[ s-1 ] + 1;
    v[  n  ]:= v[  s  ] - 1;
    if s < n then
      v[s]:= 0;
    fi;
    return v;
end );


#############################################################################
##
#F  ClassifyCharactersFromRiemannSurfaces( <G> )
#F  ClassifyCharactersFromRiemannSurfaces( <G>, <range> )
##
InstallGlobalFunction( ClassifyCharactersFromRiemannSurfaces, function( arg )
    local G,
          range,
          starttime,
          tbl,
          rhinfo,
          T,
          repcycsub,
          classes,
          g_min,
          q,
          i, j,
          Delta,
          C,
          a,
          rep,
          globalV,  # global list $V$ of exceptions
          V,        # list $V$ of exceptions for current $g_0$
          g0,
          norm,
          L,
          w,
          g,
          series,
          list,
          degrees,
          checkvector, negfail,
          globalS,  # global list $S$ of vectors that fail because of (iii)
          S,        # list $S$ for current $g_0$
          I, N, l, len, pos, v, E, nsg, ok, b, n, diff;

    # Get and check the arguments.
    if Length( arg ) = 1 and IsGroup( arg[1] ) then
      G:= arg[1];
    elif Length( arg ) = 2 and IsGroup( arg[1] ) and IsList( arg[2] ) then
      G:= arg[1];
      range:= arg[2];
    else
      Error( "usage: ClassifyCharactersFromRiemannSurfaces( <G>[, <range>] )" );
    fi;

    starttime:= Runtime();
    negfail:= 0;

    tbl:= CharacterTable( G );

    # Check that <G> is ambivalent.
    if ForAny( Irr( tbl ),
               chi -> ForAny( chi, x -> x <> GaloisCyc( x, -1 ) ) ) then
      Error( "<G> must be ambivalent" );
    fi;

    # Compute a genus `g_min' such that all {\RH}-characters $\chi$
    # with $[1_G,\chi] \geq `g_min'$ come from Riemann surfaces.
    if not IsBound( range ) then
      g_min:= CommutatorLength( tbl ) + Int( ( Length( GeneratorsOfGroup( G ) )+1 )/2 );
      range:= [ 0 .. g_min - 1 ];
    fi;
    Print( "#I consider g0 in ", range , "\n" );

    # Compute the {\RH} info.
    rhinfo:= RHInfo( tbl );
    T:= rhinfo.T;
    repcycsub:= rhinfo.repcycsub;
    classes:= [ [ 1 ] ];
    for i in [ 2 .. Length( repcycsub ) ] do
      classes[i]:= ClassOrbit( tbl, repcycsub[i] );
    od;
    Print( "#I T = ", T, "\n" );

    # Prepare the data structure for the checks of vectors.
    # (Note that representatives found for $g_0$ are also valid for
    # $g_0 + 1$, $g_0 + 2$ etc.)
    # `Delta[i]' is the smallest number $n$ such that increasing
    # $l[i] > 0$ by $n$ transfers {\RH}-vectors to {\RH}-vectors
    # (one element in class $i$ can be replaced by $`Delta[i]' + 1$).
    # `Delta[i]' is either $1$ or $2$.
    rep:= [];
    degrees:= List( RationalizedMat( Irr( tbl ) ), x -> x[1] );
    Delta:= [ 0 ];
    for i in [ 2 .. Length( repcycsub ) ] do
      C:= classes[i];
      L:= [ C, C, C ];
      while CardinalityOfHom( L, 0, tbl ) = 0 do
        Add( L, C );
      od;
      Delta[i]:= Length( L ) - 2;
    od;
    Print( "#I Delta: ", Delta, "\n" );

    # The local function `checkvector' takes a vector $l$
    # and checks whether it lies in $I$ (then nothing is done),
    # or has to be added to $S$ or $V$ (then it is added).
    # The function returns `false' if $l$ is added to $S$ or $V$,
    # and `true' otherwise (that is, if $l$ is an {\RH}-vector that
    # comes from a Riemann surface or if $l$ is not an {\RH}-vector
    # and fails because of 24.1 (i) or (ii)).
    checkvector:= function( l )

      local a, g, L, i, j, info, C;
  
      # First inspect whether $l$ is known to come from a Riemann surface
      # because of the representatives in `rep' we know already.
      if g0 = 1 and ForAny( series, list -> Sum( l{ list } ) = 0 ) then
        Print( "#I vector ", l, " in infinite series\n" );
        return true;
      elif ForAny( rep, 
              v -> ForAll( [ 2 .. Length( repcycsub ) ],
                      i -> l[i] >= v[i] and 
                        ( ( v[i] > 0 and ( l[i] - v[i] ) mod Delta[i] = 0 )
                        or ( ( l[i] - v[i] ) mod 2 = 0 ) ) ) ) then
        return true;
      fi;
  
      # Check whether $l$ is in $S$ or $V$.
      if l in S or l in V then
        return false;
      fi;
  
      # Here $l$ is not yet known to be realizable.
      # Is $l$ an {\RH}-vector?
      # If it fails because of condition (iii) then add $l$ to $S$.
      a:= rhinfo.v + l * T;
      g:= ( a * degrees ) / 2;
      if not ForAll( a, x -> ( x >= 0 ) and ( x mod 2 = 0 ) ) then
        negfail:= negfail + 1;
        return true;
      elif g < 2 then
        Add( S, l );
        return false;
      fi;
  
      # $l$ is an {\RH}-vector.
# Print( "try RH-vector ", l, "\n" );
      L:= [];
      for i in [ 2 .. Length( repcycsub ) ] do
        for j in [ 1 .. l[i] ] do
          Add( L, classes[i] );
        od;
      od;
  
      for C in ContainedMaps( L ) do
#T Here we have to enter a proper class structure!
#T nur f"ur C von ungeordneten Tupeln n"otig !!
        info:= WeakTestGeneration( C, g0, G );
        if    info = true
           or ( info = fail and
                not IsBool( HardTestGeneration( C, g0, G ) ) ) then
          Add( rep, l );
          Info( InfoSignature, 1,
                "new representative: ", l, ", g = ", g );
          return true;
        fi;
      od;
      Add( V, l );
      Print( "#I exceptional vector ", l, " with g = ", g, "\n" );
      return false;
    end;

    # Loop over the interesting genera $g_0$.
    I:= [];
    globalV:= [];
    globalS:= [];
    for g0 in range do

      Print( "#I start to consider g0 = ", g0, "\n" );

      # Step 1.
      # If $g_0 = 1$ then compute the set $I$ of vectors $l$ corresponding
      # to the infinite series of exceptions.
      # for $g_0 \not= 1$ set $I = \emptyset$.
      if g0 = 1 then

        series:= InfiniteSeriesOfExceptions( tbl, repcycsub );
        if series = [] then
          Print( "#I no infinite series of exceptions\n" );
        else
          Print( "#I infinite series of exceptions:\n" );
          Print( "#I " );
          for i in repcycsub do
            Print( String( ClassNames( tbl )[i], 5 ) );
          od;
          for list in series do
    
            # Print the information.
            Print( "\n#I " );
            for i in repcycsub do
              if i = 1 then
                Print( String( "1", 5 ) );
              elif i in list then
                Print( String( "0", 5 ) );
              else
                Print( String( "*", 5 ) );
              fi;
            od;
    
            # Prepare the information for the output.
            w:= List( repcycsub, x -> 0 );
            w[1]:= 1;
            for i in Difference( [ 2 .. Length( repcycsub ) ], list ) do
              w[i]:= Unknown();
            od;
            Add( I, w );
    
          od;
          Print( "\n" );
        fi;
      fi;

      # Step 2.
      # Compute the numbers $q(H)$.
      # Set $N = \min\{ q(H) \mid H \in CY(G) \}$,
      # $V = \emptyset$, $S = \emptyset$.
      # (Note that these variables are initialized for each $g_0$.)
      q:= List( repcycsub, x -> 1 );
      if g0 = 0 then
        for i in [ 2 .. Length( repcycsub ) ] do
          for j in [ 1 .. Length( repcycsub ) ] do
            if T[i][j] <> 0 and T[1][j]/T[i][j] > q[i] then
              q[i]:= Int( T[1][j]/T[i][j] );
            fi;
          od;
        od;
      fi;
      Print( "#I q: ", q, "\n" );
      N:= Minimum( q{ [ 2 .. Length( repcycsub ) ] } );
      V:= [];
      S:= [];

      # Step 3.
      # Loop over all vectors $l$ with $0 \leq l(H) \leq q(H) + 1$ for all $H$.
      # Add those to $S$ that fail to be {\RH}-vectors because of
      # condition 24.1 (iii).
      # Add those to $V$ that are {\RH}-vectors, not contained in $I$,
      # and such that the corresponding character does not come from a
      # Riemann surface.
      Print( "#I starting step 3, loop over ",
             Product( q{ [ 2 .. Length( q ) ] } + 2 ), " vectors\n" );
      l:= 0 * repcycsub;
      l[1]:= g0;
      len:= Length( repcycsub );
      pos:= len;
      while pos > 1 do

        # Check $l$.
        checkvector( ShallowCopy( l ) );

        # Increase $l$.
        pos:= len;
        while pos > 1 and l[ pos ] = q[ pos ] + 1 do
          l[ pos ]:= 0;
          pos:= pos - 1;
        od;
        l[ pos ]:= l[ pos ] + 1;

      od;

      # Step 4.
      # If $V \cup S$ contains no vector of norm $N$ or $N+1$ then
      # return $V$ and terminate the algorithm.
      w:= 0 * repcycsub + 1;
      w[1]:= 0;
      i:= 1;
      ok:= true;
      while ok and i <= Length( V ) do
        v:= V[i];
        norm:= v * w;
        if norm = N or norm = N+1 then
          ok:= false;
        fi;
        i:= i+1;
      od;
      i:= 1;
      while ok and i <= Length( S ) do
        v:= S[i];
        norm:= v * w;
        if norm = N or norm = N+1 then
          ok:= false;
        fi;
        i:= i+1;
      od;
      if ok then
        Print( "#I termination for g0 = ", g0, " in step 4\n" );
      else

        # Step 5.
        # Compute the set $E \subseteq CY(G)/\sim_G$ of those groups
        # that are not contained in any proper normal subgroup of $G$.
        # For each $H \in E$, compute the smallest value $b(H) \geq q(H)$
        # such that $M(b(H),H)$ satisfies the assumptions of Lemma 24.2.
        nsg:= Difference( ClassPositionsOfNormalSubgroups( tbl ),
                          [ [ 1 .. NrConjugacyClasses( tbl ) ] ] );
        E:= Difference( [ 1 .. NrConjugacyClasses( tbl ) ], Flat( nsg ) );
        E:= List( repcycsub, x -> x in E );
        b:= [];
        Print( "#I starting step 5, check positions in ",
               Filtered( [ 1 .. Length( E ) ], x -> E[x] ), "\n" );
        for i in [ 2 .. Length( repcycsub ) ] do
          if E[i] then

            n:= q[i] - 1;
            diff:= 0 * repcycsub;
            diff[1]:= g0;

            repeat

              n:= n + 1;
              ok:= true;

              # Test $M(n,H_i)$.
              v:= 0 * repcycsub;
              diff[i]:= n;
              pos:= len;
  
              while pos > 1 and ok do
  
                # Check $l$.
                ok:= ok and checkvector( v + diff );
  
                # Increase $l$.
                pos:= len;
                while pos > 1 and v[ pos ] = 1 do
                  v[ pos ]:= 0;
                  pos:= pos - 1;
                od;
                v[ pos ]:= 1;
  
              od;

            until ok;

            b[i]:= n;
            Print( "#I b[", i, "] = ", b[i], "\n" );

          fi;
        od;

        # Step 6.
        # Increase $N$ by $1$.
        # Loop over all those vectors of norm $N + 1$ with
        # $l(H) > q(H) + 1$ for at least one $H \in CY(G)/\sim_G$
        # and with $l(H) < b(H)$ for all $H \in E$.
        # Add those $l$ to $S$ that fail to be {\RH}-vectors
        # because of 24.1 (iii).
        # Add those $l$ to $V$ that are {\RH}-vectors,
        # not contained in $I$, and such that the corresponding character
        # does not come from a Riemann surface.
        Print( "#I Enter Step 6 with N = ", N, ".\n" );

        repeat

          N:= N + 1;
          Print( "#I Step 6 with N = ", N, "\n" );
  
          # Loop over all vectors $l$ of norm $N + 1$.
          l:= 0 * [ 1 .. Length( repcycsub ) ];
          l[1]:= g0;
          l[ Length( repcycsub ) ]:= N + 1;
          
          repeat
  
            # If $l$ satisfies the conditions then we check it.
            if     ForAny( [ 2 .. len ], i -> l[i] > q[i] + 1 )
               and ForAll( [ 2 .. len ],
                           i -> ( not E[i] ) or l[i] < b[i] ) then
              checkvector( l );
            fi;
  
            # Take the next vector of norm $N + 1$.
            l:= NextVectorSameL1Norm( l );
  
          until l = fail or l[1] <> g0;

          # Step 7.
          # If $V \cup S$ contains no vector of norm $N$ or $N+1$ then
          # return $V$ and terminate the algorithm.
          # Otherwise go to Step 6.

        until     ForAll( S, v -> w * v <> N and w * v <> N+1 )
              and ForAll( V, v -> w * v <> N and w * v <> N+1 );

      fi;

      Append( globalV, V );
      Append( globalS, S );

    od;

    # Return the exceptions.
    return rec( rep    := rep,
                V      := globalV,
                I      := I,
                S      := Length( globalS ),
                nreps  := Length( rep ),
                negfail:= negfail,
                time   := Runtime() - starttime );
end );


#############################################################################
##
#F  MyInducedCyclic( <tbl> )
#F  MyInducedCyclic( <tbl>, \"all\" )
#F  MyInducedCyclic( <tbl>, <classes> )
#F  MyInducedCyclic( <tbl>, <classes>, \"all\" )
##
#T  *not* returning a set!
##
MyInducedCyclic := function( arg )

    local i, j, k, x, fusion, tbl, powermap, orders, inducedcyclic, single,
          approxpowermap, independent, classes, upper;

    if not ( Length( arg ) in [ 1, 2, 3 ] and IsCharacterTable( arg[1] ) ) or
       ( Length(arg) = 2 and not ( arg[2] = "all" or IsList(arg[2]) ) ) or
       ( Length(arg) = 3 and not ( arg[3] = "all" and IsList(arg[2]) ) ) then
      Error( "usage: InducedCyclic( tbl ) resp.\n",
      "              InducedCyclic( tbl, \"all\" ) resp.\n",
      "              InducedCyclic( tbl, classes ) resp.\n",
      "              InducedCyclic( tbl, classes, \"all\" )");
    fi;
    tbl:= arg[1];
    powermap:= ComputedPowerMaps( tbl );
    orders:= OrdersClassRepresentatives( tbl );
    inducedcyclic:= [];
    independent:= [];
    for i in [ 1 .. Length( orders ) ] do independent[i]:= true; od;
    if Length( arg ) = 1 or ( Length( arg ) = 2 and arg[2] = "all" ) then
      classes:= [ 1 .. Length( orders ) ];
    else
      classes:= arg[2];
    fi;
    if classes <> Filtered( classes, x -> IsInt( orders[x] ) ) then
      Print( "#I InducedCyclic: will consider only classes",
             " with unique orders\n" );
      classes:= Filtered( classes, x -> IsInt( orders[x] ) );
    fi;
    if arg[ Length( arg ) ] = "all" then
      upper:= orders;
    else                           # only permutation characters
      upper:= [];
      for i in classes do upper[i]:= 1; od;
    fi;
    # check powermaps:
    for i in [ 1 .. Maximum( CompositionMaps( orders, classes ) ) ] do
      if IsPrimeInt( i ) and not IsBound( powermap[i] ) then
        Print( "#I InducedCyclic: powermap for prime ", i, " not available,\n",
               "#I      calling Powermap( ., ", i,
               ", rec( quick:= true ) )\n" );
        approxpowermap:= Parametrized( PossiblePowerMaps(tbl,i,rec(quick:= true)) );
        if ForAny( approxpowermap, IsSet ) then
          Print( "#I InducedCyclic: powermap for prime ", i,
                 " not determined\n" );
        fi;
        tbl.powermap[i]:= approxpowermap;
        Print( "#I InducedCyclic: ", Ordinal(i),
               " powermap stored on table\n" );
      fi;
    od;
    inducedcyclic:= [];
    for i in classes do                         # induce from i-th class
      if independent[i] then
        fusion:= [ i ];
        for j in [ 2 .. orders[i] ] do
          fusion[j]:= PowerMap( tbl, j, i ); # j-th powermap at class i
        od;
        for k in [ 0 .. upper[i] - 1 ] do       # induce k-th character
          single:= [ ];
          for j in [ 1 .. Length( orders ) ] do single[j]:= 0; od;
          single[i]:= E( orders[i] ) ^ ( k );
          for j in [ 2 .. orders[i] ] do
            if IsInt( fusion[j] ) then
              if orders[ fusion[j] ] = orders[i] then

                # pos. is galois conj. class
                independent[ fusion[j] ]:= false;
              fi;
              single[ fusion[j] ]:=
                  single[ fusion[j] ] + E( orders[i] )^( k*j mod orders[i] );
            else
              for x in fusion[j] do single[x]:= Unknown(); od;
            fi;
          od;
          for j in [ 1 .. Length( orders ) ] do
            single[j]:= single[j] * SizesCentralizers( tbl )[j] / orders[i];
            if not IsCycInt( single[j] ) then
              single[j]:= Unknown();
              Print( "#I InducedCyclic: subgroup order not dividing sum",
                     " (induce from class ", i, ")\n" );
            fi;
          od;
          Add( inducedcyclic, single );
        od;
      fi;
    od;
    return inducedcyclic;
    end;


psi:= function( tbl, i )
local indcyc, fun, orders, n, k;

indcyc:= MyInducedCyclic( tbl, [ i ], "all" );
fun:= 0;
orders:= OrdersClassRepresentatives( tbl );
n:= orders[i];
for k in [ 1 .. n-1 ] do
  fun:= fun + k * indcyc[ n-k+1 ];
od;
return fun/n;
end;


Ttilde:= function( tbl )
    local mat, i, psih;

    mat:= [ ListWithIdenticalEntries( NrConjugacyClasses( tbl ), 1 ) ];
    for i in [ 2 .. NrConjugacyClasses( tbl ) ] do
      psih:= psi( tbl, i );
      mat[i]:= List( Irr( tbl ), x -> ScalarProduct( tbl, psih, x ) );
    od;

    return mat;
end;


#############################################################################
##
##  ClassifyCharactersFromRiemannSurfaces2( <G> )
##
InstallGlobalFunction( ClassifyCharactersFromRiemannSurfaces2, function( arg )
    local G,
          range,
          starttime,
          tbl,
          rhinfo,
          TT,
          vector,
          reals, inv, donereals,
          coll, charschoice, orb, qm,
          repclasses,
          classes,
          g_min,
          q,
          i, j,
          Delta,
          m,
          mm,
          C,
          a,
          rep,
          globalV,  # global list $V$ of exceptions
          V,        # list $V$ of exceptions for current $g_0$
          g0,
          norm,
          L,
          w,
          g,
          series,
          list,
          degrees,
          checkvector, negfail,
          globalS,  # global list $S$ of vectors that fail because of (iii)
          S,        # list $S$ for current $g_0$
          I, N, l, len, pos, v, E, nsg, ok, b, n, diff;

    starttime:= Runtime();
    negfail:= 0;

    # Get and check the arguments.
    if Length( arg ) = 1 and IsGroup( arg[1] ) then
      G:= arg[1];
    elif Length( arg ) = 2 and IsGroup( arg[1] ) and IsList( arg[2] ) then
      G:= arg[1];
      range:= arg[2];
    fi;

    tbl:= CharacterTable( G );

    # Compute the {\RHT} info.
    TT:= Ttilde( tbl );
    reals:= RealClasses( tbl );
    inv:= InverseClasses( tbl );
    donereals:= [];
    classes:= [ [ 1 ] ];
    repclasses:= [ 1 ];
    for i in [ 2 .. NrConjugacyClasses( tbl ) ] do
      if i in reals then
        if not i in donereals then
          Add( repclasses, i );
          orb:= ClassOrbit( tbl, i );
          Add( classes, orb );
          UniteSet( donereals, orb );
        fi;
      else
        Add( repclasses, i );
        Add( classes, [ i ] );
      fi;
    od;

    for i in [ 1 .. Length( classes ) ] do
      if Length( Set( TT{ classes[i] } ) ) > 1 then
        Error( "impossible!" );
      fi;
    od;
    TT:= TT{ repclasses };

    coll:= CollapsedMat( TT, [] );
    TT:= coll.mat;
    charschoice:= InverseMap( coll.fusion );
    for i in [ 1 .. Length( charschoice ) ] do
      if IsInt( charschoice[i] ) then
        charschoice[i]:= [ charschoice[i] ];
      fi;
    od;

    # Check that the matrix $\hat{T}$ is invertible.
    if Length( TT ) <> Length( TT[1] )
       or RankMat( TT ) < Length( TT ) then
      Error( "noninvertible matrix TT!" );
    fi;
    Print( "#I TT = ", TT, "\n" );
    vector:= - TT[1];
    vector[1]:= 0;

    # Compute a genus `g_min' such that all {\RH}-characters $\chi$
    # with $[1_G,\chi] \geq `g_min'$ come from Riemann surfaces.
    if not IsBound( range ) then
      g_min:= CommutatorLength( tbl ) + Int( ( Length( GeneratorsOfGroup( G ) )+1 )/2 );
      range:= [ 0 .. g_min - 1 ];
    fi;
    Print( "#I consider g0 in ", range , "\n" );

    # Prepare the data structure for the checks of vectors.
    # (Note that representatives found for $g_0$ are also valid for
    # $g_0 + 1$, $g_0 + 2$ etc.)
    # `Delta[i]' is the smallest number $n$ such that increasing
    # $l[i] > 0$ by $n$ transfers {\RHT}-vectors to {\RHT}-vectors
    # (one element in class $i$ can be replaced by $`Delta[i]' + 1$).
    # `Delta[i]' is in the range from $1$ to the element order.
    rep:= [];
    degrees:= List( charschoice,
        x -> Sum( List( Irr( tbl ){ x }, y -> y[1] ) ) );
    Delta:= [ 0 ];
    for i in [ 2 .. Length( repclasses ) ] do
      C:= classes[i];
      if Length( C ) = 1 then
        L:= [ [ inv[ C[1] ] ], C, C ];
      else
        L:= [ C, C, C ];
      fi;
      while CardinalityOfHom( L, 0, tbl ) = 0 do
        Add( L, C );
      od;
      Delta[i]:= Length( L ) - 2;
    od;
    Print( "#I Delta: ", Delta, "\n" );

    m:= [ 0 ];
    for i in [ 2 .. Length( repclasses ) ] do
      C:= classes[i];
      if Length( C ) = 1 then
        L:= [ C, C ];
        while CardinalityOfHom( L, 0, tbl ) = 0 do
          Add( L, C );
        od;
        m[i]:= Length( L );
      else
        m[i]:= 2;
      fi;
    od;
    Print( "#I m: ", m, "\n" );

    mm:= Maximum( m );

    # The local function `checkvector' takes a vector $l$
    # and checks whether it lies in $I$ (then nothing is done),
    # or has to be added to $S$ or $V$ (then it is added).
    # The function returns `false' if $l$ is added to $S$ or $V$,
    # and `true' otherwise (that is, if $l$ is an {\RH}-vector that
    # comes from a Riemann surface or if $l$ is not an {\RH}-vector
    # and fails because of 24.1 (i) or (ii)).
    checkvector:= function( l )

      local a, g, L, i, j, info, C;
  
      # First inspect whether $l$ is known to come from a Riemann surface
      # because of the representatives in `rep' we know already.
      if g0 = 1 and ForAny( series, list -> Sum( l{ list } ) = 0 ) then
        Print( "#I vector ", l, " in infinite series\n" );
        return true;
      elif ForAny( rep, 
              v -> ForAll( [ 2 .. Length( repclasses ) ],
                      i -> l[i] >= v[i] and 
                        ( ( v[i] > 0 and ( l[i] - v[i] ) mod Delta[i] = 0 )
                        or ( ( l[i] - v[i] ) mod m[i] = 0 ) ) ) ) then
#T here v[i] = 0 can be assumed!
        return true;
      fi;
  
      # Check whether $l$ is in $S$ or $V$.
      if l in S or l in V then
        return false;
      fi;
  
      # Here $l$ is not yet known to be realizable.
      # Is $l$ an {\RHT}-vector?
      # If it fails because of condition (iii) then add $l$ to $S$.
      a:= vector + l * TT;
      g:= a * degrees;
      if not ForAll( a, x -> ( x >= 0 ) and IsInt( x ) ) then
        negfail:= negfail + 1;
        return true;
      elif g < 2 then
        Add( S, l );
        return false;
      fi;
  
      # $l$ is an {\RHT}-vector.
# Print( "try RHT-vector ", l, "\n" );
      L:= [];
      for i in [ 2 .. Length( repclasses ) ] do
        for j in [ 1 .. l[i] ] do
          Add( L, classes[i] );
        od;
      od;
  
      for C in ContainedMaps( L ) do
#T Here we have to enter a proper class structure!
#T nur f"ur C von ungeordneten Tupeln n"otig !!
        info:= WeakTestGeneration( C, g0, G );
        if    info = true
           or ( info = fail and
                not IsBool( HardTestGeneration( C, g0, G ) ) ) then
          Add( rep, l );
          Info( InfoSignature, 1,
                "new representative: ", l, ", g = ", g );
          return true;
        fi;
      od;
      Add( V, l );
      Print( "#I exceptional vector ", l, " with g = ", g, "\n" );
      return false;
    end;

    # Loop over the interesting genera $g_0$.
    I:= [];
    globalV:= [];
    globalS:= [];
    for g0 in range do

      Print( "#I start to consider g0 = ", g0, "\n" );

      # Step 1.
      # If $g_0 = 1$ then compute the set $I$ of vectors $l$ corresponding
      # to the infinite series of exceptions.
      # for $g_0 \not= 1$ set $I = \emptyset$.
      if g0 = 1 then

        series:= InfiniteSeriesOfExceptions( tbl, repclasses );
        if series = [] then
          Print( "#I no infinite series of exceptions\n" );
        else
          Print( "#I infinite series of exceptions:\n" );
          Print( "#I " );
          for i in repclasses do
            Print( String( ClassNames( tbl )[i], 5 ) );
          od;
          for list in series do
    
            # Print the information.
            Print( "\n#I " );
            for i in repclasses do
              if i = 1 then
                Print( String( "1", 5 ) );
              elif i in list then
                Print( String( "0", 5 ) );
              else
                Print( String( "*", 5 ) );
              fi;
            od;
    
            # Prepare the information for the output.
            w:= List( repclasses, x -> 0 );
            w[1]:= 1;
            for i in Difference( [ 2 .. Length( repclasses ) ], list ) do
              w[i]:= Unknown();
            od;
            Add( I, w );
    
          od;
          Print( "\n" );
        fi;
      fi;

      # Step 2.
      # Compute the numbers $q(h)$.
      # Set $N = \min\{ q(h) \mid h \in S(G) \}$,
      # $V = \emptyset$, $S = \emptyset$.
      # (Note that these variables are initialized for each $g_0$.)
      q:= List( repclasses, x -> 1 );
      if g0 = 0 then
        for i in [ 2 .. Length( repclasses ) ] do
          for j in [ 1 .. Length( repclasses ) ] do
            if TT[i][j] <> 0 and TT[1][j] / TT[i][j] > q[i] then
              q[i]:= Int( TT[1][j] / TT[i][j] );
            fi;
          od;
        od;
      fi;
      Print( "#I q: ", q, "\n" );
      N:= Minimum( q{ [ 2 .. Length( repclasses ) ] } );
      V:= [];
      S:= [];

      # Step 3.
      # Loop over all vectors $l$ with $0 \leq l(h) \leq q(H)h+m(h)-1$
      # for all $h$.
      # Add those to $S$ that fail to be {\RHT}-vectors because of
      # condition 33.1 (iii).
      # Add those to $V$ that are {\RHT}-vectors, not contained in $I$,
      # and such that the corresponding character does not come from a
      # Riemann surface.
      qm:= q + m;
      Print( "#I starting step 3, loop over ",
             Product( qm{ [ 2 .. Length( q ) ] } ), " vectors\n" );
      l:= 0 * repclasses;
      l[1]:= g0;
      len:= Length( repclasses );
      pos:= len;
      while pos > 1 do

        # Check $l$.
        checkvector( ShallowCopy( l ) );

        # Increase $l$.
        pos:= len;
        while pos > 1 and l[ pos ] = q[ pos ] + m[ pos ] - 1 do
          l[ pos ]:= 0;
          pos:= pos - 1;
        od;
        l[ pos ]:= l[ pos ] + 1;

      od;

      # Step 4.
      # If $V \cup S$ contains no vector of norm $N$, $N+1$, \ldots,
      # $N+m-1$ then return $V$ and terminate the algorithm.
      w:= 0 * repclasses + 1;
      w[1]:= 0;
      i:= 1;
      ok:= true;
      while ok and i <= Length( V ) do
        if V[i] * w in [ N .. N+mm-1 ] then
          ok:= false;
        fi;
        i:= i+1;
      od;
      i:= 1;
      while ok and i <= Length( S ) do
        if S[i] * w in [ N .. N+mm-1 ] then
          ok:= false;
        fi;
        i:= i+1;
      od;
      if ok then
        Print( "#I termination for g0 = ", g0, " in step 4\n" );
      else

        # Step 5.
        # Compute the set $E \subseteq S(G)$ of those class representatives
        # that are not contained in any proper normal subgroup of $G$.
        # For each $h \in E$, compute the smallest value $b(h) \geq q(h)$
        # such that $\hat{M}(b(h),h)$ satisfies the assumptions of Lemma 33.2.
        nsg:= Difference( ClassPositionsOfNormalSubgroups( tbl ),
                          [ [ 1 .. NrConjugacyClasses( tbl ) ] ] );
        E:= Difference( [ 1 .. NrConjugacyClasses( tbl ) ],
                        Flat( nsg ) );
        E:= List( repclasses, x -> x in E );
        b:= [];
        Print( "#I starting step 5, check positions in ",
               Filtered( [ 1 .. Length( E ) ], x -> E[x] ), "\n" );
        for i in [ 2 .. Length( repclasses ) ] do
          if E[i] then

            n:= q[i] - 1;
            diff:= 0 * repclasses;
            diff[1]:= g0;

            repeat

              n:= n + 1;
              ok:= true;

              # Test $\hat{M}(n,h_i)$.
              v:= 0 * repclasses;
              diff[i]:= n;
              pos:= len;
  
              while pos > 1 and ok do
  
                # Check $l$.
                ok:= ok and checkvector( v + diff );
  
                # Increase $l$.
                pos:= len;
                while pos > 1 and v[ pos ] = m[ pos ] - 1 do
                  v[ pos ]:= 0;
                  pos:= pos - 1;
                od;
                v[ pos ]:= v[ pos ] + 1;
  
              od;

            until ok;

            b[i]:= n;
            Print( "#I b[", i, "] = ", b[i], "\n" );

          fi;
        od;

        # Step 6.
        # Increase $N$ by $1$.
        # Loop over all those vectors of norm $N + 1$ with
        # $l(H) > q(H) + 1$ for at least one $H \in CY(G)/\sim_G$
        # and with $l(H) < b(H)$ for all $H \in E$.
        # Add those $l$ to $S$ that fail to be {\RH}-vectors
        # because of 24.1 (iii).
        # Add those $l$ to $V$ that are {\RH}-vectors,
        # not contained in $I$, and such that the corresponding character
        # does not come from a Riemann surface.
        Print( "#I Enter Step 6 with N = ", N, ".\n" );

        repeat

          N:= N + 1;
          Print( "#I Step 6 with N = ", N, "\n" );
  
          # Loop over all vectors $l$ of norm $N + 1$.
          l:= 0 * [ 1 .. Length( repclasses ) ];
          l[1]:= g0;
          l[ Length( repclasses ) ]:= N + 1;
          
          repeat
  
            # If $l$ satisfies the conditions then we check it.
            if     ForAny( [ 2 .. len ], i -> l[i] > q[i] + m[i] - 1 )
               and ForAll( [ 2 .. len ],
                           i -> ( not E[i] ) or l[i] < b[i] ) then
              checkvector( l );
            fi;
  
            # Take the next vector of norm $N + 1$.
            l:= NextVectorSameL1Norm( l );
  
          until l = fail or l[1] <> g0;

          # Step 7.
          # If $V \cup S$ contains no vector of norm $N$, $N+1$, \ldots,
          # $N+m-1$ then return $V$ and terminate the algorithm.
          # Otherwise go to Step 6.

        until     ForAll( S, v -> not ( w * v in [ N .. N+mm-1 ] ) )
              and ForAll( V, v -> not ( w * v in [ N .. N+mm-1 ] ) );

      fi;

      Append( globalV, V );
      Append( globalS, S );

    od;

    # Return the exceptions.
    return rec( 
                rep    := rep,
                V      := globalV,
                I      := I,
                S      := Length( globalS ),
                nreps  := Length( rep ),
                negfail:= negfail,
                time   := Runtime() - starttime
               );
end );


#############################################################################
##
#E

