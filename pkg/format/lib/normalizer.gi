#############################################################################
##
#W  normalizer.gi                   FORMAT                       Bettina Eick
#W                                      conversion from GAP3 by C.R.B. Wright 
##
Revision.("format/gap/normalizer.gi") :=
    "@(#)$Id: normalizer.gi,v 1.8 2000/10/31 17:58:37 gap Exp $";

#############################################################################
#F  NormalizedPcgs( spg, pcgs ). . . . . . . . sets leading coefficients to 1
##  Need to be careful; igs should surely be induced and a prime pcgs.

InstallGlobalFunction( NormalizedPcgs,
function( spg, pcgs )
    local ros, cgs, i, exp;
    ros := RelativeOrders(pcgs);
    cgs := [];
    for i  in [ 1 .. Length(pcgs) ]  do
        exp := LeadingExponentOfPcElement( spg, pcgs[i] );
        cgs[i] := pcgs[i] ^ (1/exp mod ros[i]);
    od;
    return InducedPcgsByPcSequenceNC( spg, cgs );
end);

#############################################################################
#F  LeastBadFNormalizerIndex( system, pcgsR, i ) . . . . . . . . . . . .local
##  [requires system.depths to use FExponents]

InstallGlobalFunction( LeastBadFNormalizerIndex, 
function( system, pcgsR, i )
  local bad,       # least bad  index
        w,         # commutator
        exponents, # exponent vector of w  in layer
        max,       # composition length
        g, pg,     # some element with its prime
        k;         # index

Info( InfoForm, 1, "starting LeastBadFNormalizerIndex\n" );

  max  := Length( system.base );

  bad := max + 1;
  for g  in pcgsR  do
    w := Comm( g, system.base[ i ] );

    # get prime
    pg := RelativeOrderOfPcElement( pcgsR, g );
    if w <> One( system.H )   then
      exponents := FExponents( system, w, Integers, i+1, max );
      k := 1;

      # run through exponent list until bad entry is found
      while k <= Length( exponents )  do
        if exponents[ k ] <> 0 and 
           system.weights[ i ][ 3 ] = system.weights[ k+i ][ 3 ]  
           and  not system.Fcentral[ k+i ] 
        then
          if k+i < bad  then
            bad := k+i;
          fi;
          k := Length( exponents ) + 1;
        else
          k := k + 1;
        fi;
      od;
    fi;

    # if bad is minimal return; otherwise go on
    if i = bad - 1  then
        return bad;
    fi;
  od;
  return bad;
end);

#############################################################################
#F  ChangeGenerator( system, pcgsR, i ) . . . . . . . . . . . . . . . . local
##  [requires system.depths to use FExponents and LeastBadFNormalizerIndex]

InstallGlobalFunction( ChangeGenerator,
function ( system, pcgsR, i )
  local max,               # composition length
        k,                 # smallest bad index
        layer,             # layer with bad  index
        first,             # first index of this layer
        next,              # first index of next layer
        size,              # size of layer
        gensNM,            # gens of layer 
        pk, field,         # involved prime and field
        idmat,             # identity matrix
        e,                 # generator of R
        aij,               # operating element
        g,                 # commutator
        A, v,              # one equation system
        E, V,              # simultaneous linear equation system
        solution,          # one solution of simultaneous system or false
        l;                 # index

  Info( InfoForm, 1, "starting ChangeGenerator \n" );

  max := Length( system.base );

  k   := LeastBadFNormalizerIndex( system, pcgsR, i );

  # trivial case
  if k > max  then
    Info( InfoForm, 2,"change gens: ", i, " has no bad index\n");
    return;
  fi;
  Info( InfoForm, 2,"change gens: ", i, " has bad index = ", k, "\n");

  # get the layer
  layer  := system.Flayers[ k ];
  first  := system.Ffirst[ layer ];
  next   := system.Ffirst[ layer+1 ];
  size   := next - first;
  gensNM := system.base{[first..next-1]};

  # initialize inhomogenous system  
  V := [ ];
  E := List( [ 1 .. size ], x -> [ ] );

  # get prime and field
  pk    := system.weights[ k ][ 3 ];
  field := GF( pk );
  idmat := IdentityMat( size, field );

  # run through commutators
  for e in pcgsR do

    # operation matrix
    aij := e ^ system.base[ i ];
    A := List( gensNM, 
        x -> FExponents( system, x^aij, field, first, next-1 ) );
    if A <> idmat then
      A := A - idmat;

      # inhomogeneous part
      g := Comm( e, system.base[ i ] );
      v := FExponents( system, g, field, i+1, next-1 ){
                    [ first-i..next-1-i] };

      # append to system 
      for l  in [ 1 .. size ]  do
        Append( E[ l ], A[ l ] );
      od;
      Append( V, v );
    fi;
  od;

  # try to solve inhomogenous systems simultaneously
  solution := SolutionMat( E, V );

  # calculate new i-th base element
  g := system.base[i];
  for l  in [ 1..size ]  do
    g := g * gensNM[l] ^ Int(solution[l]);
  od;

  system.base[i] := g;

  # and recur

  ChangeGenerator( system, pcgsR, i );
end);

#############################################################################
#F  InducedNilpotentSeries( G, U ) .subgroup nilpotent series by intersection
##  Pcgses of intersections of U with normal series of its parent that has 
##  nilpotent factors.
##  Need to be careful; surely Pcgs(U) should be induced and a prime pcgs.

InstallGlobalFunction( InducedNilpotentSeries, 
function( G, U )
  local  spg,            # pcgs of G
         gens, max,      # pcgs of U and length
         series,         # induced nilpotent series
         head,           # run through nilpotent series of G
         found,          # flag
         i;              # index

  if IsBound( U!.nilpotentSeries ) then
    return U!.nilpotentSeries;
  fi;  

# set up
  spg    := SpecialPcgs( G );
  gens   := InducedPcgs( spg, U );   max    := Length( gens );
  i      := 1;
  series := [ gens ];

  # loop over nilpotent series of G
  for head  in LGHeads( spg ){ [ 2 .. Length( LGHeads( spg ) ) ] }  do
    # get first generator of next subgroup
    found := false;
    while i <= max and DepthOfPcElement( spg, gens[ i ] ) < head  do
      found := true;
      i     := i + 1;
    od;

    # if there is a new subgroup
    if found then
      Add( series, InducedPcgsByPcSequenceNC( spg, gens{ [ i .. max ] } ) );
    fi;
  od;

  # store and return result
  U!.nilpotentSeries := series;
  return series;
end);

#############################################################################
#F  RefinedBaseLayer( G, R, pcgsR, layer ) . . . . . . . . . . . . . . .local
##  Separates R-central from R-hypereccentric factors. R is an arbitrary 
##  normal subgroup of G. Does not return a record with depths. spg is a 
##  special pcgs of G.

InstallGlobalFunction( RefinedBaseLayer,
function( G, R, pcgsR, layer )
  local spg,                   # special pcgs of G
        max,                   # length of pcgs of G
        first, next, wt,       # of layer
        head, tail, hhead,     # catch part of nilpotent head series 
        firsts, base, central, # components of output record
        depths,                # depths of pcgs of R
        pcgsN, pcgsM,          # actual layer pcgses
        pcgsU,                 # pcgs of subgroup
        index,                 # to check the progress
        series, h;             # nilpotent series of Res  

  # check argument
  if IsList( R ) then    # R = [ ] in this case
      Error("support and local residuals not consistent \n");
  fi;

  # set up
  spg    := SpecialPcgs( G ); 
  max    := Length( spg );

  Info( InfoForm, 1, "getting layer in RefinedBaseLayer, layer = i = ", layer, " \n" );

  # get the layer
  first  := LGFirst( spg )[ layer ];
  next   := LGFirst( spg )[ layer+1 ];
  wt     := LGWeights( spg )[ first ];

  # get the nilpotent factor
  head   := LGHeads( spg )[ wt[1] ];
  tail   := LGTails( spg )[ wt[1] ];

  # set up result
  firsts := [ ];
  base   := [ ];
  central:= [ ];

  # first check whether we know that R centralises layer
  if Length( pcgsR ) = 0 or DepthOfPcElement( spg, pcgsR[1] ) 
          >= head or wt[1] = 1  then
    return rec( base    := spg{ [first..next-1] },
                firsts  := [ next ],
                central := List( [first..next-1], x -> true ) );
  fi;

  Info( InfoForm, 2, "check if layer is R-hypereccentric \n" );


  # now check whether we know that the layer is R-hypereccentric 
  depths := List( pcgsR, x -> DepthOfPcElement( spg, x ) );
  hhead  := LGHeads( spg )[ wt[1]-1 ];
  if wt[2] = 1 and ForAll([hhead..head-1], x -> x in depths) then 
      return rec( base    := spg{ [first..next-1] },
                  firsts  := [ next ],
                  central := List( [first..next-1], x -> false ) );
  fi;

  Info( InfoForm, 2, "starting to compute layers \n" );

  # now start to compute layers
  pcgsN := InducedPcgsByPcSequenceNC( spg, spg{[first..max]} ); 
  pcgsM := InducedPcgsByPcSequenceNC( spg, spg{[next..max]} ); 
  while first < next  do

  Info( InfoForm, 2, "first = ", first, "\n" );

    # first catch a trivial case
    if next - first = 1  then
      Append( base, pcgsN mod pcgsM );
      Add( firsts, next );
      Add( central, FCentralTest( G, pcgsR, pcgsN, pcgsM ) );

  Info( InfoForm, 2, "hit a layer of prime order \n");  # 12/26/99

      return rec( base := base,
                  firsts := firsts,
                  central := central );
    fi;

    # try to find a central factor
    pcgsU := FCommutatorPcgs( G, pcgsR, pcgsN, pcgsM );
    index := Length( pcgsN ) - Length( pcgsU);

    # if U is a proper subgroup we obtain a central factor
    if index > 0  then

      Info( InfoForm, 2, "there is a central factor; index = ", index, " \n" );

      Append( base, pcgsN mod pcgsU ); 
      first := first + index;
      Add( firsts, first );
      Append( central, List( [ 1 .. index ], x -> true ) );
      pcgsN := pcgsU;

    # there is no central factor, check whether it is semisimple
    elif not wt[3] in List( LGWeights( spg ){[1..head-1]}, x -> x[3]) then

      Info( InfoForm, 2, "there is no central factor \n" );

      Append( base, pcgsN mod pcgsM );
      Append( central, List( [ 1 .. next-first ], x -> false ) );
      Add( firsts, next );
      first := next;

    # now we need to compute a hypereccentric factor
    else

      Info( InfoForm, 2, "not semisimple \n" );

      # compute induced nilpotent series with large factors of R
      series := InducedNilpotentSeries( G, R );  

      # loop over it 
      h := 2;
      while index = 0  do
        pcgsU := FCommutatorPcgs( G, series[ h ], pcgsN, pcgsM );
        index := Length( pcgsN ) - Length( pcgsU );
        h := h + 1;
      od;   

      # now we have it
      Append( base, pcgsN mod pcgsU );
      Append( central, List( [ 1 .. index ], x -> false ) );
      first := first + index;
      Add( firsts, first );
      pcgsN := pcgsU;
    fi;
  od;

  return rec( base    := base, 
              firsts  := firsts, 
              central := central );
end);
    
#############################################################################
#F  FSystem( G, form ) . . . . . . . . . . . . . . . . . <form>-system of <G>
##  

InstallGlobalFunction( FSystem,
function( G, form )
  local spg,              # special pcgs of G
        max,              # length of cgs of G
        system,           # system record to store information
        primes,           # of the group
        locals,           # local residuals or their p-complements
        localspcgs,       # their pcgses
        p, j,             # prime and position
        reflayer,         # refined layer
        head, tail, next, # indicate layers
        gens,             # generators of normalizer
        i,                # indices
        head2;            # where the action starts

  spg := SpecialPcgs( G );
  max := Length( spg );

  # set up local residuals
  primes := RelativeOrders( spg );
  locals     := List( primes, x -> ScreenOfFormation( form )(G, x) );
  localspcgs := [ ];
  for i in [1..Length( locals )] do
    if locals[i] = [ ] then
      localspcgs[i] := [ ];
    else
      localspcgs[i] := NormalizedPcgs( spg, InducedPcgs( spg, locals[i] ) );
    fi;
  od;
    ## Now spg has a ParentPcgs, with which it is identical, and it's the
    ## parent pcgs for each nonempty member of localspcgs.

  # set up system record with new base
  head2 := LGHeads( spg )[2];
  i := Position( LGFirst( spg ), head2 );
  system         := rec();
  system.H       := G;

  # pass spg through to ChangeGenerator and its friends
  system.sph     := spg;

  system.base    := spg{ [ 1 .. head2 - 1 ] };
  system.Flayers := LGLayers( spg ){[ 1 .. head2 - 1 ]};
  system.Ffirst  := LGFirst( spg ){ [ 1 .. i ] };
  if HasSupportOfFormation( form ) then
    system.Fcentral := List( [1..head2 -1], 
        x -> LGWeights( spg )[x][3] in SupportOfFormation( form ) );
  else
    system.Fcentral := List( [1..head2-1], x -> true );
  fi;

  # refine elementary abelian series of G
  Info( InfoForm, 2,"refine series \n");
  while i < Length( LGFirst( spg ) ) do
    p := LGWeights( spg )[LGFirst( spg )[i]][3];

    if not HasSupportOfFormation( form ) or (HasSupportOfFormation(form) 
        and p in SupportOfFormation(form))  then
      j := Position( primes, p );
      reflayer := RefinedBaseLayer( G, locals[j], localspcgs[j], i );

      # append result
      Append( system.base, reflayer.base );
      Append( system.Ffirst, reflayer.firsts );
      Append( system.Fcentral, reflayer.central );
      i := i + 1;

      # if a head is completely central, then the whole layer must be
      if LGFirst( spg )[i] in LGTails( spg ) then

  Info( InfoForm, 2, "completely central layer \n");

        j := Position( LGTails( spg ), LGFirst( spg )[i] );
        head  := LGHeads( spg )[j];
        tail  := LGTails( spg )[j];
        next  := LGHeads( spg )[j+1];
        if ForAll( system.Fcentral{[head..tail-1]}, x -> x ) 
            and next > tail then
          Append( system.base, spg{[tail..next-1]} );
          Append( system.Fcentral, List([tail..next-1], x -> true));
          j := Position( LGFirst( spg ), next );
          Append( system.Ffirst, LGFirst( spg ){[i+1..j]}); 
              ## CRBW 6-12-00 Formerly [i..j].
          i := j;
        fi;
      fi;
    else
      next   := LGFirst( spg )[ i+1 ];
      Append( system.base, spg{[LGFirst( spg )[i]..next-1]});
      Append( system.Ffirst, [next] );
      Append(system.Fcentral,List([LGFirst( spg )[i]..next-1], x -> false));
      i := i + 1;
    fi;
  od;

  # compute depths
  system.depths := List( system.base, x -> DepthOfPcElement( spg, x ) );

  # compute layers
  system.Flayers := List( system.base, x -> false );
  j := 1;
  for i in [1..Length( system.base )] do
    if system.Ffirst[j] = i then
      j := j + 1;
    fi;
    system.Flayers[i] := j-1;
  od;

  # add weights
  system.weights := LGWeights( spg );

  # calculate p-complements of residuals
  for i in [1..Length(primes)] do
    if not HasSupportOfFormation( form ) or (HasSupportOfFormation( form )
        and primes[i] in SupportOfFormation( form )) then
      p := primes[i];
      locals[i] := Filtered( localspcgs[i], x ->
          not ( RelativeOrderOfPcElement( spg, x ) = p ) );
      localspcgs[i] := InducedPcgsByPcSequenceNC( spg, locals[i] );
    fi;
  od;

  # run through series and change F-central factors
  gens := [ ];
  i := max;
  while i >= 1  and system.Fcentral[ i ]  do
      i := i - 1;
  od;
  while i >= 1  do
    if system.Fcentral[ i ]  then
      p := LGWeights( spg )[ i ][ 3 ];
      j := Position( primes, p );

      Info( InfoForm, 2, "about to change generators: i = ",
          i," j = ",j,"\n" );

      ChangeGenerator( system, localspcgs[ j ], i );
    fi;
    i := i - 1;
  od;

  return system;
end);

#############################################################################
#M  FNormalizerWrtFormationOp( G, form ) . . . . . . <form>-normalizer of <G>
##

InstallMethod( FNormalizerWrtFormationOp, "for local formation", true,
  [IsGroup and IsFinite, IsFormation and HasScreenOfFormation], 0,
function( G, form )
    local iso,       # onto special pc group
          g,         # its image
          system,    # form-system of g
          spg,       # special pcgs of g
          gens,      # good generators
          ans;       # image of the answer

    # catch trivial case
    if Size( G ) = 1 then return G; fi;

    iso := IsomorphismSpecialPcGroup( G );
    g := Image( iso );

    form := Integrated(form); # can be tricked by setting IsIntegrated
    spg := SpecialPcgs( g );
    system := FSystem( g, form ); 
    gens := Set( system.base{ Filtered( [1..Length(system.Fcentral)], 
                         x -> system.Fcentral[x] ) } );
    Sort( gens, function(x, y) return DepthOfPcElement( spg, x) <
        DepthOfPcElement( spg, y); end );
    ans := SubgroupByPcgs(g, InducedPcgsByPcSequenceNC(spg,gens));
    return PreImage( iso, ans );

end);

#M  FNormalizerWrtFormationOp( G, form ) . . . . . . . . . . . . <form>-normalizer of <G>
##
SubgpMethodByNiceMonomorphismCollOther(FNormalizerWrtFormationOp, 
    [IsGroup, IsFormation]);

#############################################################################
#M  SystemNormalizer( G ) . . . . . . . . . . . . . .system normalizer of <G>
##

InstallMethod( SystemNormalizer, "for Hall system", true,
  [IsGroup], 0,
function( G ) return FNormalizerWrtFormation( G, Formation("Nilpotent") ); end);


#E  End of normalizer.gi (for FORMAT)
