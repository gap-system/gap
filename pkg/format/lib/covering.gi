#############################################################################
##
#W  covering.gi                     FORMAT                       Bettina Eick
#W                                      conversion from GAP3 by C.R.B. Wright 
##
Revision.("format/lib/covering.gi") :=
    "@(#)$Id: covering.gi,v 1.10 2000/10/31 17:58:37 gap Exp $";

## Both methods exploit the fact that an F-covering subgroup of a pi-Hall 
## subgroup of G is an (F meet pi-groups)-covering subgroup of G.

#############################################################################
#M  CoveringSubgroup1Op( G, form ) . . . . . .<form>-covering subgroup of <G>
##

InstallMethod( CoveringSubgroup1Op, "for locally induced formation", true,
  [IsGroup and IsFinite, IsFormation and HasScreenOfFormation], 0,
function( G, form )

  local iso,          # onto special pc group
        g,            # its image
        spg,          # pcgs of g
        newform,      # formation without support
        U,            # approximate cover, eventually the answer
        system,       # system for normalizer mod less and less
        head, tail,   # of nilpotent factor
        hhead,        # next nilpotent factor
        locals,       # local residuals
        localspcgs,   # pcgses for these
        ffirst,       # correction factor
        first, next,  # of layer
        p,            # prime
        primes,       # list of primes
        reflayer,     # refined layer
        index,        # to cut out eccentric elements
        j, k,         # positions 
        i;            # loop variable
  
  # catch trivial case
  if Length( Pcgs( G ) ) = 0 then return G; fi;

  iso := IsomorphismSpecialPcGroup( G );
  g := Image( iso );
  spg := SpecialPcgs( g );

  if HasSupportOfFormation( form ) then
    newform := rec( );
    newform.name := "temporary";
    if HasScreenOfFormation(form) then 
      newform.fScreen := ScreenOfFormation(form);
    fi;
    if HasResidualFunctionOfFormation(form) then
      newform.fResidual := ResidualFunctionOfFormation(form);
    fi;
    if HasIsIntegrated(form) and IsIntegrated(form) then
      newform.isIntegrated := true;
    fi;
    newform := Formation( newform );
    U := CoveringSubgroup1Op( HallSubgroup( g, SupportOfFormation( form ) ),
        newform );
    return PreImage( iso, U );
  fi;


  form := Integrated(form); # can be tricked by setting IsIntegrated

  # set up system record
  head := LGHeads( spg )[2];
  index := [1..head-1];
  system          := rec();
  system.H        := g;
  ## to pass spg on to ChangeGenerator
  system.sph      := spg;
  system.base     := spg{ index };
  system.weights  := LGWeights( spg ){ index };
  system.Fcentral := List( index, x -> true );
  system.Ffirst   := Filtered( LGFirst( spg ){[ 1..Position( 
                         LGFirst( spg ), head) ]}, x -> x in index );
#  Add(system.Ffirst, LGHeads(spg)[2] - LGFirst(spg)[2] + Length(index));

  # set up the cover
  U := SubgroupNC( g, Concatenation( system.base, 
      spg{[ head..Length(spg) ]} ) );

  Info( InfoForm, 2, "1 head done \n");

  # run down lower nilpotent series (the first factor is trivial)
  for i  in [ 2..Length(LGHeads( spg ))-1 ]  do
    head  := LGHeads( spg )[ i ];
    tail  := LGTails( spg )[ i ];
    hhead := LGHeads( spg )[ i+1 ];

    # get local residuals
    primes := Set( List( LGWeights( spg ){[head..tail-1]}, x -> x[3] ) );
    locals := List( primes, x -> ScreenOfFormation( form )( U, x ) );
    ## Here's where we cut down to U. Locals is just a list of normal
    ## subgroups of U. Nothing special.
    localspcgs := [ ];
    for i in [1..Length( locals )] do
      if locals[i] = [ ] then
        localspcgs[i] := [ ];
      else
        localspcgs[i] := NormalizedPcgs( spg, InducedPcgs( spg, locals[i] ) );
      fi;
    od;

    # compute correction factor
    ffirst := head - Length( system.base ) - 1;

    # refine nilpotent layer
    j := Position( LGFirst( spg ), head );
    while LGFirst( spg )[j] < hhead do
      first := LGFirst( spg )[j];
      next  := LGFirst( spg )[j+1];
      p := LGWeights( spg )[ first ][3];

      if not HasSupportOfFormation( form ) or (HasSupportOfFormation(
          form ) and p in SupportOfFormation( form )) then
        k := Position( primes, p );
        reflayer := RefinedBaseLayer( g, locals[k], localspcgs[k], j );
        Append( system.base, reflayer.base );
        Append( system.Fcentral, reflayer.central );
        Append( system.Ffirst, 
            List( reflayer.firsts, x -> x - ffirst ) );
      else
        Append( system.base, spg{[ first..next-1 ]} ); 
        Append( system.Fcentral, List( [first..next-1], x -> false ));
        Append( system.Ffirst, [next - ffirst] );
      fi;
      Append( system.weights, LGWeights( spg ){[ first..next-1 ]} );
      j := j + 1;
    od;
    system.depths := List( system.base, x -> DepthOfPcElement( spg, x ) );

    # compute layers relative to first for full base
    system.Flayers := List( system.base, x -> false );
    j := 1;
    for k in [1..Length( system.base )] do
      if system.Ffirst[j] = k then
        j := j + 1;
      fi;
      system.Flayers[k] := j-1;
    od;

    # calculate p-complements of residuals
    for j in [1..Length(primes)] do
      if not HasSupportOfFormation( form ) or (HasSupportOfFormation(
          form ) and primes[j] in SupportOfFormation( form )) then
        if Length( InducedPcgs( spg, locals[j] ) ) > 0 then
          locals[j] := NormalIntersection(locals[j],
            SylowComplement(g,primes[j]));
        fi;
        localspcgs[j] := NormalizedPcgs( spg, InducedPcgs( spg, locals[j] ) );
      fi;
    od;

    j := Length( system.base );
    while j >= 1  and system.Fcentral[ j ]  do
        j := j - 1;
    od;
    while j >= 1  do
      if system.Fcentral[ j ]  then
        p := system.weights[ j ][ 3 ];
        k := Position( primes, p );
        if not IsBool( k ) then
          ChangeGenerator( system, localspcgs[ k ], j );
            ## If this gives an error message, it's a problem
            ## with alignment of pcgs's for setting up the
            ## system of equations.
        fi;
      fi;
      j := j - 1;
    od;

    # set up for next head
    index := Filtered( [1..Length(system.Fcentral)], 
                       x -> system.Fcentral[x] );
    system.base := system.base{ index };
    system.weights := system.weights{ index };
    system.Fcentral := List( index, x -> true );

    system.Ffirst  := [ ];
    k := 1;
    for j in [1..Length(system.base)] do
      if DepthOfPcElement( spg, system.base[j] ) >= 
                                    LGFirst( spg )[k] then
        k := k + 1;
        Add( system.Ffirst, j );
      fi;
    od;
    Add( system.Ffirst, Length( system.base ) + 1 );
        
    U := SubgroupNC( g, Concatenation( system.base, 
         spg{[ hhead..Length(spg) ]} ) );

    Info( InfoForm, 2, i," head done \n");
  od;
  return PreImage( iso, U );
end);

#############################################################################
#M  CoveringSubgroup1Op( G, form ) . . . . . .<form>-covering subgroup of <G>
##

SubgpMethodByNiceMonomorphismCollOther(CoveringSubgroup1Op, [IsGroup, 
    IsFormation]);

#############################################################################
##                         Second strategy                                 ##
############################################################################# 

#############################################################################
#M  CoveringSubgroup2Op( G, formation ) . . . . . . . . . . . . 2nd strategy
##

InstallMethod( CoveringSubgroup2Op, 
  "second strategy for locally induced formation", true,
  [IsGroup and IsFinite, IsFormation and HasScreenOfFormation], 0,
function( G, form )
  local iso,          # onto special pc group
        g,            # its image
        spg,          # pcgs of g
        newform,      # formation without support
        U,            # the covering group
        max,          # composition length of g
        head,         # the first nilpotent factor of g
        system,       # system of cover
        first, next,  # of a layer
        wt, p,        # corresponding weight and prime
        pcgsN, pcgsM, # corresponding normal subgroup pcgses
        loc,          # local residual 
        comp, ncomp,  # p-complement and O^p of loc
        residual,     # pcgs of residual modulo M
        gens,         # some new system elements
        layer,        # number of layer
        Ffirst,       # first of layer
        q,            # prime of element
        index,        # to cut out eccentric elements
        i, j, k;      # indices
  
  # catch trivial case
  if Length( Pcgs( G ) ) = 0 then return G; fi;

  iso := IsomorphismSpecialPcGroup( G );
  g := Image( iso );
  spg := SpecialPcgs( g );
  max := Length( spg );

  if HasSupportOfFormation( form ) then
    newform := rec( );
    newform.name := "temporary";
    if HasScreenOfFormation(form) then 
      newform.fScreen := ScreenOfFormation(form);
    fi;
    if HasResidualFunctionOfFormation(form) then
      newform.fResidual := ResidualFunctionOfFormation(form);
    fi;
    if HasIsIntegrated(form) and IsIntegrated(form) then
      newform.isIntegrated := true;
    fi;
    newform := Formation( newform );
    U := CoveringSubgroup1Op( HallSubgroup( g, SupportOfFormation( form ) ),
        newform );
    return PreImage( iso, U );
  fi;

  form := Integrated(form); # can be tricked by setting IsIntegrated

  # set up system record
  head := LGHeads( spg )[2];
  index := [1..head-1];
  system          := rec();
  system.H        := g;
  ## to pass spg on to ChangeGenerator
  system.sph      := spg;
  system.base     := spg{ index };
  system.weights  := LGWeights( spg ){ index };
  system.Fcentral := List( index, x -> true );
  system.Ffirst   := LGFirst( spg ){[ 1..Position( 
                         LGFirst( spg ), head) ]};
  # compute layers allowing for support
  system.Flayers := List( system.base, x -> false );
  j := 1;
  for k in [1..Length( system.base )] do
    if system.Ffirst[j] = k then
      j := j + 1;
    fi;
    system.Flayers[k] := j-1;
  od;

  # set up the cover
  U := SubgroupNC( g, Concatenation( system.base, 
      spg{[ head..Length(spg) ]} ) );

  Info( InfoForm, 2, "1 head done \n");

  # run down elementary abelian series (the first factor is trivial)
  for i  in [Position(LGFirst( spg ), head)..Length(LGFirst( spg ))-1]  do
    first := LGFirst( spg )[ i ];
    next  := LGFirst( spg )[ i+1 ];
    wt    := LGWeights( spg )[ first ];
    p     := wt[ 3 ];
    if not HasSupportOfFormation( form ) or (HasSupportOfFormation(
      form ) and p in SupportOfFormation( form )) then
      pcgsN := InducedPcgsByPcSequenceNC( spg, spg{[first..max]} );
      pcgsM := InducedPcgsByPcSequenceNC( spg, spg{[next..max]} );

      # get local residual
      loc   := ScreenOfFormation( form )( U, p );
      ## Here's where U comes in.

      # compute p-complement and O^p
      comp := InducedPcgsByPcSequenceNC( spg,
          Filtered( InducedPcgs( spg, loc ), x ->
          not ( RelativeOrderOfPcElement( spg, x ) = p ) ) );
#      ncomp := Pcgs( NormalClosure( loc, SubgroupByPcgs( loc, comp ) ) );

      ## If we didn't need comp itself later on, we could use 
       ncomp := Pcgs( PResidual( loc, p ) ); # which would be lots faster.

      # compute residual
      residual := NormalizedPcgs( spg, 
          FCommutatorPcgs( g, ncomp, pcgsN, pcgsM ) );  
              ## ncomp need not be induced wrt spg.

      # update system record for normalizer
      gens := pcgsN mod residual;

      if Length( gens ) > 0 then
        Append( system.base, gens );
        Append( system.Fcentral, List( gens, x -> true ) );
        Append( system.weights, List( gens, x -> wt ) );
        if system.Flayers = [ ] then
          system.Flayers := List( system.base, x -> 1 );
        else
          layer := system.Flayers[ Length( system.Flayers ) ];
          Append( system.Flayers, List( gens, x -> layer + 1 ) );
        fi;
        if Length(system.Ffirst) = 0 then
          Ffirst := Length(gens);
        else
          Ffirst := system.Ffirst[Length(system.Ffirst)] + Length(gens);
        fi;
        Add( system.Ffirst, Ffirst );
      fi;

      gens := residual mod pcgsM;

      if Length( gens ) > 0 then
        Append( system.base, gens );
        Append( system.Fcentral, List( gens, x -> false ) );
        Append( system.weights, List( gens, x -> wt ) );
        layer := system.Flayers[ Length( system.Flayers ) ];
        Append( system.Flayers, List( gens, x -> layer + 1 ) );
        Ffirst := system.Ffirst[Length(system.Ffirst)] + Length(gens);
        Add( system.Ffirst, Ffirst );

        ## Next line added to allow use of ChangeGenerator
        system.depths := List( system.base,
            x -> DepthOfPcElement( spg, x ) );

        # modify central elements
        j := system.Ffirst[ Length( system.Ffirst ) - 1 ] - 1;
        while j >= 1  do
          q := system.weights[ j ][ 3 ];
          if p = q then
            ChangeGenerator( system, NormalizedPcgs( spg, comp ), j );
          fi;
          j := j - 1;
        od;

        # cut out eccentric part
        Unbind( system.Ffirst[ Length( system.Ffirst ) ] );
        j := system.Ffirst[ Length( system.Ffirst ) ] - 1;
        system.base := system.base{[1..j]};
        system.Fcentral := system.Fcentral{[1..j]};
        system.weights := system.weights{[1..j]};
        system.Flayers := system.Flayers{[1..j]};

      fi;
    fi;
    # change U
    U := SubgroupNC( g, 
        Concatenation( system.base, spg{[ next..max ]} ) );
    Info( InfoForm, 2, i," layer done \n");
  od;
  return PreImage( iso, U );
end);

#############################################################################
#M  CoveringSubgroup2Op( G, form ) . . . . . .<form>-covering subgroup of <G>
##

SubgpMethodByNiceMonomorphismCollOther(CoveringSubgroup2Op, [IsGroup, 
    IsFormation]);

#############################################################################
#M  CoveringSubgroupWrtFormation( G, form ) . . .<form>-covering group of <G>
##
## CoveringSubgroup1 seems to be somewhat faster than CoveringSubgroup2 in
## general, to judge from experiments.

InstallMethod( CoveringSubgroupWrtFormation, 
      "integrated", true,
  [IsGroup, IsFormation and HasScreenOfFormation], 0,
function( G, form )
  if HasComputedCoveringSubgroup1s( G ) and 
      Integrated( form ) in ComputedCoveringSubgroup2s( G ) then
    return CoveringSubgroup2( G, Integrated( form ) );
  else
    return CoveringSubgroup1( G, Integrated( form ) );
  fi;
end);

#############################################################################
#M  CarterSubgroup( G ) . . . . . . . . . .nilpotent-covering subgroup of <G>
##

InstallMethod( CarterSubgroup, "solvable", true, [IsGroup], 0,
function( G )
  return CoveringSubgroupWrtFormation( G, Formation("Nilpotent") );
end);


#E  End of covering.gi
