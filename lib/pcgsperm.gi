#############################################################################
##
#W  pcgsperm.gi                 GAP library                              HThe
##
#H  @(#)$Id$
##
##  This file  contains    functions which deal with   polycyclic  generating
##  systems of solvable permutation groups.
##
Revision.pcgsperm_gi :=
    "@(#)$Id$";

#############################################################################
##
#R  IsMemberPcSeriesPermGroup . . . . . . . . . . . . .  members of pc series
##
IsMemberPcSeriesPermGroup := NewRepresentation( "IsMemberPcSeriesPermGroup",
    IsPermGroup, [ "noInSeries" ] );

#############################################################################
##
#F  WordVector( <gens>, <id>, <v> ) . . . . . .  make word from exponent list
##
WordVector := function( gens, id, v )
    local  word,  ll,  z;
    
    word := id;
    for ll  in [ 1 .. Length( v ) ]  do
        z := Int( v[ ll ] );
        if z <> 0  then
            word := word * gens[ ll ] ^ z;
        fi;
    od;
    return word;
end;

#############################################################################
##
#F  WordNumber( <gens>, <id>, <num>, <p> )  . . . . . . make word from number
##
WordNumber := function( gens, id, num, p )
    local word,  gen;
    
    word := id;
    num := num - 1;
    for gen  in gens  do
        word := word * gen ^ ( num mod p );
        num := QuoInt( num, p );
    od;
    return word;
end;

#############################################################################
##

#F  AddNormalizingElementPcgs( <G>, <z> ) . . . . . cyclic extension for pcgs
##
AddNormalizingElementPcgs := function( G, z )
    local   S,  A,  oldpos,  pos,  relord,
            pnt,  orb,  l,  L,  n,  m,  img,  i,  f,  p,  edg;

    S := G;
    A := G;
    pos := 1;
    L := [  ];
    if IsBound( G.relativeOrders )  then  relord := G.relativeOrders;
                                    else  relord := false;             fi;
    
    # Loop over the stabilizer chain.
    while z <> S.identity  do

	# If necessary, extend the stabilizer chain.
	if not IsBound( S.stabilizer )  then
            InsertTrivialStabilizer( S, SmallestMovedPointPerm( z ) );
            Unbind( S.stabilizer.relativeOrders );
        fi;
        
        # Extend the orbit.
        orb := S.orbit;
        pnt := orb[ 1 ];
        l := Length( orb );  Add( L, l );
        n := l;
        m := 1;
        img := pnt / z;
        while not IsBound( S.translabels[ img ] )  do
            orb[ n + 1 ] := img;
            for i  in [ 2 .. l ]  do
                orb[ n + i ] := orb[ n - l + i ] / z;
            od;
            n := n + l;
            m := m + 1;
            img := img / z;
        od;
        
        # Let  $m   =  p_1p_2...p_l$.  Then  instead   of  entering <z>  into
        # '<G>.translabels' <d> times, enter $z^d$ once, for $d=p_1p_2...p_k$
        # (where $k<=l$).
        if m > 1  then
            
            # If <m> = 1, the current level <A> has not been extended and <z>
            # has been shifted  into <w> in  the next level. <w> or something
            # further down, which will extend a  future level, must be put in
            # as a generator here.
            AddSet( S.genlabels, 1 - pos );
            while A.orbit[ 1 ] <> S.orbit[ 1 ]  do
                AddSet( A.genlabels, 1 - pos );
                A := A.stabilizer;
            od;
            A := A.stabilizer;
            
            f := 1;
            for p  in FactorsInt( m )  do
                if relord <> false  then
                    InsertElmList( relord, pos, p );
                fi;
                pos := pos + 1;
                InsertElmList( S.labels, pos, z );
                edg := 0 * [ 1 .. l ] - pos;
                for i  in f * [ 1 .. m / f - 1 ]  do
                    S.translabels{ orb{ i * l + [ 1 .. l ] } } := edg;
                od;
                f := f * p;
                z := z ^ p;
            od;
    
        fi;

        # Find a cofactor to <z> such that the product fixes <pnt>.
        edg := S.translabels[ pnt ^ z ];
        while edg <> 1  do
            if edg > 1  then  z := z * S.labels[ edg + pos - 1 ];
                        else  z := z * S.labels[ -edg ];       fi;
            edg := S.translabels[ pnt ^ z ];
        od;
    
	# Go down one step in the stabilizer chain.
	S := S.stabilizer;
 
    od;
    
    if pos = 1  then
        return false;
    fi;
    
    # Correct   the `genlabels' and   `translabels'  entries and  install the
    # `generators'.
    S := G;  i := 0;  pos := pos - 1;
    while IsBound( S.stabilizer )  do
        p := PositionSorted( S.genlabels, 2 );
        if not IsEmpty( S.genlabels )
           and S.genlabels[ 1 ] < 1  then
            S.genlabels[ 1 ] := 2 - S.genlabels[ 1 ];
        fi;
        orb := [ p .. Length( S.genlabels ) ];
        S.genlabels{ orb } := S.genlabels{ orb } + pos;
        if i < Length( L )  then  i := i + 1;  l := L[ i ];
                            else  l := Length( S.orbit );    fi;
        orb := S.orbit{ [ 2 .. l ] };
        S.translabels{ orb } := S.translabels{ orb } + pos;
        orb := S.orbit{ [ l + 1 .. Length( S.orbit ) ] };
        S.translabels{ orb } := -S.translabels{ orb };
        S.transversal := [  ];
        S.transversal{ S.orbit } := S.labels{ S.translabels{ S.orbit } };
        S.generators := S.labels{ S.genlabels };
        S := S.stabilizer;
    od;
    
    return true;
end;

#############################################################################
##
#F  ExtendSeriesPermGroup( ... )  . . . . . . extend a series of a perm group
##
ExtendSeriesPermGroup := function(
            G,       # the group in which factors are to be normal/central
            series,  # the series being constructed
            cent,    # flag: true if central factors are wanted
            desc,    # flag: true if a fastest-descending series is wanted
            elab,    # flag: true if elementary abelian factors are wanted
            s,       # the element to be added to `series[ <lev> ]'
            lev,     # the level of the series which is to be extended
            dep,     # the depth of <s> in <G>
            bound )  # a bound on the depth, for solvability/nilpotency tests
                         
    local   M0,  M1,  C,  X,  oldX,  T,  t,  u,  w,  r,  done,
            ndep,  ord,  gcd,  p;
    
    # If we are too deep in the derived series, give up.
    if dep > bound  then
        return s;
    fi;
    
    if desc  then
        
        # If necessary, add a new (trivial) subgroup to the series.
        if lev + 2 > Length( series )  then
            series[ lev + 2 ] := DeepCopy( series[ lev + 1 ] );
        fi;
    
        M0 := series[ lev + 1 ];
        M1 := series[ lev + 2 ];
        X := M0.labels{ [ 2 .. Length( M0.labels )
                             - Length( M1.labels ) + 1 ] };
        r := lev + 2;
        
    # If the  series  need not be   fastest-descending, prepare to add  a new
    # group to the list.
    else
        M1 := series[ 1 ];
        M0 := DeepCopy( M1 );
        X := [  ];
        r := 1;
    fi;
    
    # For elementary abelian factors, find a suitable prime.
    if IsInt( elab )  then
        p := elab;
    elif elab  then
        
        # For central series, the prime must be given.
        if cent  then
          Error("cannot construct central el ab series with varying primes");
        fi;
      
        ord := OrderPerm( s );
        if not IsEmpty( X )  then
            gcd := GcdInt( ord, OrderPerm( X[ 1 ] ) );
            if gcd <> 1  then
                ord := gcd;
            fi;
        fi;
        p := FactorsInt( ord )[ 1 ];
    fi;
    
    # Loop over all conjugates of <s>.
    C := [ s ];
    while not IsEmpty( C )  do
        t := C[ 1 ];
        C := C{ [ 2 .. Length( C ) ] };
        if not MembershipTestKnownBase( M0, G, t )  then
            
            # Form  all necessary  commutators with  <t>   and for elementary
            # abelian factors also a <p>th power.
            if cent  then  T := ListSorted( GeneratorsOfGroup( G ) );
                     else  T := ListSorted( X );                       fi;
            done := false;
            while not done  and  ( not IsEmpty( T )  or  elab <> false )  do
                if not IsEmpty( T )  then
                    u := T[ 1 ];        RemoveSet( T, u );
                    w := Comm( t, u );  ndep := dep + 1;
                else
                    done := true;
                    w := t ^ p;         ndep := dep;
                fi;
            
                # If   the commutator or  power  is not  in <M1>, recursively
                # extend <M1>.
                if not MembershipTestKnownBase( M1, G, w )  then
                    w := ExtendSeriesPermGroup( G, series, cent,
                                 desc, elab, w, lev + 1, ndep, bound );
                    if w <> true  then
                        return w;
                    fi;
                    M1 := series[ r ];
                    
                    # The enlarged <M1> also pushes up <M0>.
                    M0 := DeepCopy( M1 );
                    oldX := X;
                    X := [  ];
                    for u  in oldX  do
                        if AddNormalizingElementPcgs( M0, u )  then
                            Add( X, u );
                        else
                            RemoveSet( T, u );
                        fi;
                    od;
                    if MembershipTestKnownBase( M0, G, t )  then
                        done := true;
                    fi;
                fi;
                
            od;
            
            # Add <t> to <M0> and register its conjugates.
            if AddNormalizingElementPcgs( M0, t )  then
                Add( X, t );
            fi;
            UniteSet( C, List( GeneratorsOfGroup( G ), g -> t ^ g ) );
            
        fi;
    od;
    
    # For a fastest-descending series,  replace the old group. Otherwise, add
    # the new group to the list.
    if desc  then
        series[ lev + 1 ] := M0;
        if IsEmpty( X )  then
            RemoveElmList( series, lev + 2 );
        fi;
    else
        if not IsEmpty( X )  then
            InsertElmList( series, 1, M0 );
        fi;
    fi;
    
    return true;
end;

#############################################################################
##
#F  TryPcgsPermGroup(<G>, <cent>, <desc>, <elab>) . . try to construct a pcgs
##
TryPcgsPermGroup := function( G, cent, desc, elab )
    local   grp,  pcgs,  U,  oldlen,  series,  y,  w,  whole,
            bound,  deg,  step,  seriesAttr,  i,  S,  filter;

    # If the last member <U> of the series <G> already has a pcgs, start with
    # its stabilizer chain.
    if not IsGroup( G )  then
        U := G[ Length( G ) ];
        if HasPcgs( U )  and  IsPcgsPermGroupRep( Pcgs( U ) )  then
            if IsFactorGroup( U )  then
                U := DeepCopy( Pcgs( U )!.preimage!.stabChain );
            else
                U := DeepCopy( Pcgs( U )!.stabChain );
            fi;
        fi;
    else
        U := TrivialSubgroup( G );
        if IsTrivial( G )  then  G := [ G ];
                           else  G := [ G, U ];  fi;
    fi;
    
    # Otherwise start  with stabilizer chain  of  <U> with identical `labels'
    # components on all levels.
    if IsGroup( U )  then                               
        if IsFactorGroup( U )  then
            U := U.factorNum;
        fi;
        if IsTrivial( U )  and  not HasStabChain( U )  then
            U := EmptyStabChain( [  ], One( U ) );
        else
            U := StabChainAttr( U );
            U := StabChainBaseStrongGenerators( BaseStabChain( U ),
                         StrongGeneratorsStabChain( U ) );
        fi;
    fi;
    
    # The `genlabels' at every level of $U$ must be sets.
    S := U;
    while not IsEmpty( S.genlabels )  do
        Sort( S.genlabels );
        S := S.stabilizer;
    od;

    grp := G[ 1 ];
    whole := IsTrivial( G[ Length( G ) ] );
    
    # Deal with the factor group case.
    if IsFactorGroup( grp )  then
        for i  in [ 1 .. Length( G ) ]  do
            G[ i ] := G[ i ].factorNum;
        od;
        Add( G, grp.factorDen );
    fi;
    
    oldlen := Length( U.labels );
    series := [ U ];
    series[ 1 ].relativeOrders := [  ];

    if not IsTrivial( grp )  then
        
        # The derived  length of  <G> was  bounded by  Dixon. The  nilpotency
        # class of <G> is at most Max( log_p(d)-1 ).
        deg := NrMovedPoints( grp );
        if cent  then
            bound := Maximum( List( Collected( FactorsInt( deg ) ), p ->
                             p[ 1 ] ^ ( LogInt( deg, p[ 1 ] ) - 1 ) ) );
        else
            bound := Int( LogInt( deg ^ 5, 3 ) / 2 );
        fi;
        if     HasSize( grp )
           and Length( FactorsInt( Size( grp ) ) ) < bound  then
            bound := Length( FactorsInt( Size( grp ) ) );
        fi;
        
        for step  in Reversed( [ 1 .. Length( G ) - 1  ] )  do
            for y  in GeneratorsOfGroup( G[ step ] )  do
                if not y in GeneratorsOfGroup( G[ step + 1 ] )  then
                    w := ExtendSeriesPermGroup( G[ step ], series, cent,
                                 desc, elab, y, 0, 0, bound );
                    if w <> true  then
                        SetIsNilpotentGroup( grp, false );
                        if not cent  then
                            SetIsSolvableGroup( grp, false );
                        fi;
                        
                        # In case of  failure, return two ``witnesses'':  The
                        # pcgs   of   the solvable  normal   subgroup  of <G>
                        # constructed    so   far,     and   an  element   in
                        # $G^{(\infty)}$.
                        return [ PcgsStabChainSeries( IsPcgsPermGroupRep,
                                 GroupStabChain( grp, series[ 1 ], true ),
                                 ElementaryAbelianSeries, series, oldlen ),
                                 w ];
                        
                    fi;
                fi;
            od;
        od;
    fi;
    
    # Construct the pcgs object.
    if whole  then  filter := IsPcgsPermGroupRep;
              else  filter := IsPcgsFactorGroupPermGroupRep;  fi;
    if desc  and  elab = false  then
        if cent         then  seriesAttr := LowerCentralSeriesOfGroup;
                        else  seriesAttr := DerivedSeriesOfGroup;     fi;
    elif elab <> false  then  seriesAttr := ElementaryAbelianSeries;
    else                      seriesAttr := false;                    fi;
    pcgs := PcgsStabChainSeries( filter, grp, seriesAttr, series, oldlen );
    if whole  then
        if not HasPcgs( grp )  then
            SetPcgs( grp, pcgs );
        fi;
        SetIsSolvableGroup( grp, true );
        if cent  then
            SetIsNilpotentGroup( grp, true );
        fi;
        if seriesAttr <> false  and  not Tester( seriesAttr )( grp )  then
            Setter( seriesAttr )( grp, series );
        fi;
    else
        pcgs!.denominator := G[ Length( G ) ];
        if     HasIsSolvableGroup( pcgs!.denominator )
           and IsSolvableGroup( pcgs!.denominator )  then
            SetIsSolvableGroup( grp, true );
        fi;
    fi;
    return pcgs;
end;

#############################################################################
##
#F  PcgsStabChainSeries( <filter>, <G>, <seriesAttr>, <series>, <oldlen> )  .
##
PcgsStabChainSeries := function( filter, G, seriesAttr, series, oldlen )
    local   pcgs,  i;
    
    pcgs := PcgsByPcSequenceCons(
                    IsPcgsDefaultRep,
                    IsPcgs and filter and IsPrimeOrdersPcgs,
                    ElementsFamily( FamilyObj( G ) ),
                    series[ 1 ].labels
                    { 1 + [ 1 .. Length(series[ 1 ].labels) - oldlen ] } );
    pcgs!.stabChain := series[ 1 ];
    SetGroupOfPcgs( pcgs, G );
    SetRelativeOrders( pcgs, series[ 1 ].relativeOrders );
    if not HasStabChain( G )  then
        SetStabChain( G, series[ 1 ] );
    fi;
    pcgs!.nrGensSeries := [  ];
    for i  in [ 1 .. Length( series ) ]  do
        Add( pcgs!.nrGensSeries, Length( series[ i ].genlabels ) );
        Unbind( series[ i ].relativeOrders );
        series[ i ] := GroupStabChain( G, series[ i ], true );
        SetHomePcgs ( series[ i ], pcgs );
        SetFilterObj( series[ i ], IsMemberPcSeriesPermGroup );
        series[ i ]!.noInSeries := i;
    od;
    pcgs!.nrGensSeries := pcgs!.nrGensSeries -
                          pcgs!.nrGensSeries[ Length( series ) ];
    SetPcSeries( pcgs, series );
    if seriesAttr <> false  then
        Setter( seriesAttr )( pcgs, series );
    fi;
    return pcgs;
end;

#############################################################################
##
#F  TailOfPcgsPermGroup( <pcgs>, <from> ) . . . . . . . . construct tail pcgs
##
TailOfPcgsPermGroup := function( pcgs, from )
    local   tail,  i,  ffrom;
    
    i := 1;
    ffrom := Length( pcgs ) - pcgs!.nrGensSeries[ i ] + 1;
    while ffrom < from  do
        i := i + 1;
        ffrom := Length( pcgs ) - pcgs!.nrGensSeries[ i ] + 1;
    od;
    tail := PcgsByPcSequenceCons(
                    IsPcgsDefaultRep,
                    IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
                    FamilyObj( OneOfPcgs( pcgs ) ),
                    pcgs{ [ ffrom .. Length( pcgs ) ] } );
    tail!.stabChain := StabChainAttr( PcSeries( pcgs )[ i ] );
    SetRelativeOrders( tail, RelativeOrders( pcgs )
            { [ from .. Length( pcgs ) ] } );
    SetPcSeries( tail, PcSeries( pcgs ){[i..Length(pcgs!.nrGensSeries)]} );
    tail!.nrGensSeries := pcgs!.nrGensSeries{[i..Length(pcgs!.nrGensSeries)]};
    if from < ffrom  then
        tail := ExtendedPcgs( tail, pcgs{ [ from .. ffrom - 1 ] } );
    fi;
    return tail;
end;

#############################################################################
##
#F  PcgsMemberPcSeriesPermGroup( <U> )  . . . . . . . . . . . . . .  the same
##
PcgsMemberPcSeriesPermGroup := function( U )
    local   home,  pcgs;

    home := HomePcgs( U );
    pcgs := TailOfPcgsPermGroup( home,
                Length( home ) - home!.nrGensSeries[ U!.noInSeries ] + 1 );
    SetGroupOfPcgs( pcgs, U );
    return pcgs;
end;

#############################################################################
##
#F  ExponentsOfPcElementPermGroup( <pcgs>, <g>, <min>, <max>, <mode> )  local
##
ExponentsOfPcElementPermGroup := function( pcgs, g, mindepth, maxdepth, mode )
    local   exp,  base,  bimg,  r,  depth,  img,  H,  bpt,  gen,  e,  i;
    
    if mode = 'e'  then
        exp := 0 * [ mindepth .. maxdepth ];
    fi;
    base  := BaseStabChain( pcgs!.stabChain );
    bimg  := OnTuples( base, g );
    r     := Length( base );
    depth := mindepth;
    
    while depth <= maxdepth  do
        
        # Determine the depth of <g>.
        repeat
            img := ShallowCopy( bimg );
            gen := pcgs!.pcSequence[ depth ];
            depth := depth + 1;
        
            # Find the base level of the <depth>th generator, remove the part
            # of <g> moving the earlier basepoints.
            H := pcgs!.stabChain;
            bpt := H.orbit[ 1 ];
            i := 1;
            while bpt ^ gen = bpt  do
                while img[ i ] <> bpt  do
                    img{ [ i .. r ] } := OnTuples( img{ [ i .. r ] },
                                                 H.transversal[ img[ i ] ] );
                od;
                H := H.stabilizer;
                bpt := H.orbit[ 1 ];
                i := i + 1;
            od;
            
        until depth > maxdepth  or  H.translabels[ img[ i ] ] = depth;
        
        # If  `H.translabels[  img[  i ] ]  =   depth', then <g>  is  not the
        # identity.
        if H.translabels[ img[ i ] ] = depth  then
            if mode = 'd'  then
                return depth - 1;
            fi;
           
            # Determine the <depth>th exponent.
            e := RelativeOrders( pcgs )[ depth - 1 ];
            i := img[ i ];
            repeat
                e := e - 1;
                i := i ^ gen;
            until H.translabels[ i ] <> depth;
            
            if mode = 'l'  then
                return e;
            fi;
            
            # Remove the appropriate  power  of the <depth>th  generator  and
            # iterate.
            exp[ depth - mindepth ] := e;
            g := LeftQuotient( gen ^ e, g );
            bimg := OnTuples( base, g );
            
        fi;
    od;
    if   mode = 'd'  then  return maxdepth + 1;
    elif mode = 'l'  then  return fail;
    else                   return exp;  fi;
end;

#############################################################################
##
#F  PcGroupPcgs( <pcgs>, <index>, <isNilp> ) . . . . . .  pcp group from pcgs
##
PcGroupPcgs := function( pcgs, index, isNilp )
    local   m,  sc,  gens,  p,  start,  i,  i2,  n,  n2;

    m := Length( pcgs );
    sc := SingleCollector( FreeGroup( m ), RelativeOrders( pcgs ) );

    # Find the relations of the p-th powers. Use  the  vector space structure
    # of the elementary abelian factors.
    for i  in [ 1 .. Length( index ) - 1 ]  do
        p := RelativeOrders( pcgs )[ index[ i ] ];
        start := index[ i + 1 ];
        gens := GeneratorsOfRws( sc ){ [ start .. m ] };
        for n  in [ index[ i ] .. index[ i + 1 ] - 1 ]  do
            SetPowerNC( sc, n, WordVector
                    ( gens, ReducedOne( sc ), ExponentsOfPcElementPermGroup
                      ( pcgs, pcgs[ n ] ^ p, start, m, 'e' ) ) );
        od;
    od;

    # Find the relations of the conjugates.
    for i  in [ 1 .. Length( index ) - 1 ]  do
        for n  in [ index[ i ] .. index[ i + 1 ] - 1 ]  do
            for i2  in [ 1 .. i - 1 ]  do
                if isNilp then
                    start := index[ i + 1 ];
                    gens := GeneratorsOfRws( sc ){ [ start .. m ] };
                    for n2  in [ index[ i2 ] .. index[ i2 + 1 ] - 1 ]  do
                        SetConjugateNC( sc, n, n2, WordVector( gens,
                            GeneratorsOfRws( sc )[ n ],
                            ExponentsOfPcElementPermGroup( pcgs, Comm
                            ( pcgs[ n ], pcgs[ n2 ] ), start, m, 'e' ) ) );
                    od;
                else
                    start := index[ i2 + 1 ];
                    gens := GeneratorsOfRws( sc ){ [ start .. m ] };
                    for n2  in [ index[ i2 ] .. index[ i2 + 1 ] - 1 ]  do
                        SetConjugateNC( sc, n, n2, WordVector( gens,
                            ReducedOne( sc ), ExponentsOfPcElementPermGroup
                            ( pcgs,
                              pcgs[ n ] ^ pcgs[ n2 ], start, m, 'e' ) ) );
                    od;
                fi;
            od;
            start := index[ i + 1 ];
            gens := GeneratorsOfRws( sc ){ [ start .. m ] };
            for n2  in [ index[ i ] .. n - 1 ]  do
                SetConjugateNC( sc, n, n2, WordVector
                    ( gens, GeneratorsOfRws( sc )[ n ],
                      ExponentsOfPcElementPermGroup( pcgs, Comm
                      ( pcgs[ n ], pcgs[ n2 ] ), start, m, 'e' ) ) );
            od;
        od;
    od;
    UpdatePolycyclicCollector( sc );
    return GroupByRwsNC( sc );
end;

#############################################################################
##
#F  SolvableNormalClosurePermGroup( <G>, <H> )  . . . solvable normal closure
##
SolvableNormalClosurePermGroup := function( G, H )
    local   U,  oldlen,  series,  bound,  z,  S;
    
    U := DeepCopy( StabChainAttr( TrivialSubgroup( G ) ) );
    oldlen := Length( U.labels );
    
    # The `genlabels' at every level of $U$ must be sets.
    S := U;
    while not IsEmpty( S.genlabels )  do
        Sort( S.genlabels );
        S := S.stabilizer;
    od;

    U.relativeOrders := [  ];
    series := [ U ];
    
    # The derived length of <G> is at most (5 log_3(deg(<G>)))/2 (Dixon).
    bound := Int( LogInt( NrMovedPoints( G ) ^ 5, 3 ) / 2 );
    if     HasSize( G )
       and Length( FactorsInt( Size( G ) ) ) < bound  then
        bound := Length( FactorsInt( Size( G ) ) );
    fi;
    
    if IsGroup( H )  then
        H := GeneratorsOfGroup( H );
    fi;
    for z  in H  do
        if ExtendSeriesPermGroup( G, series, false, false, false, z, 0, 0,
                   bound ) <> true  then
            return fail;
        fi;
    od;
    
    U := GroupStabChain( G, series[ 1 ], true );
    SetPcgs( U, PcgsStabChainSeries( IsPcgsPermGroupRep, G,
            ElementaryAbelianSeries, series, oldlen ) );
    SetIsSolvableGroup( U, true );
    SetIsNormalInParent( U, true );
    return U;
end;

#############################################################################
##
#M  <pcgsG> mod <pcgsN> . . . . . . . . . . . . . . . . .  of perm group pcgs
##
InstallMethod( \mod, "perm group pcgs", IsIdentical,
        [ IsPcgs and IsPcgsPermGroupRep,
          IsPcgs and IsPcgsPermGroupRep ], 20,
    function( G, N )
    local   pcgs,  i;

    if G{ [ Length( G ) - Length( N ) + 1 .. Length( G ) ] } = N  then
        pcgs := PcgsByPcSequenceCons(
                IsPcgsDefaultRep,
                IsPcgs and IsModuloPcgs and IsPcgsFactorGroupPermGroupRep
                                        and IsPrimeOrdersPcgs,
                FamilyObj( OneOfPcgs( G ) ),
                G{ [ 1 .. Length( G ) - Length( N ) ] } );
        pcgs!.stabChain := G!.stabChain;
        SetRelativeOrders( pcgs, RelativeOrders( G ){ [ 1..Length(pcgs) ] } );
        i := 1;
        while G!.nrGensSeries[ i ] > Length( N )  do
            i := i + 1;
        od;
        pcgs!.nrGensSeries := Concatenation
            ( G!.nrGensSeries{ [ 1 .. i - 1 ] }, [ Length( N ) ] );
        SetPcSeries( pcgs, Concatenation
            ( PcSeries( G ){ [ 1 .. i - 1 ] }, [ GroupOfPcgs( N ) ] ) );
    else
        pcgs := PcgsByPcSequenceCons(
                IsPcgsDefaultRep,
                IsPcgs and IsModuloPcgs and IsPcgsFactorGroupPermGroupRep
                                        and IsPrimeOrdersPcgs,
                FamilyObj( OneOfPcgs( G ) ),
                [  ] );
        pcgs!.stabChain := N!.stabChain;
        pcgs!.nrGensSeries := [ Length( N ) ];
        SetPcSeries( pcgs, [ GroupOfPcgs( N ) ] );
        pcgs := ExtendedPcgs( pcgs, Reversed( G ) );
    fi;
    SetGroupOfPcgs( pcgs, GroupOfPcgs( G ) );
    SetNumeratorOfModuloPcgs  ( pcgs, G );
    SetDenominatorOfModuloPcgs( pcgs, N );
    pcgs!.denominator := GroupOfPcgs( N );
    pcgs!.nrGensSeries := pcgs!.nrGensSeries - Length( N );
    return pcgs;
end );

#############################################################################
##

#M  IsPcgsComputable( <G> ) . . . . . . . . . . . . . . . . . .  return false
##
InstallMethod( IsPcgsComputable, true, [ IsPermGroup ], 0, ReturnFalse );

#############################################################################
##
#M  Pcgs( <G> ) . . . . . . . . . . . . . . . . . . . .  pcgs for perm groups
##
InstallMethod( Pcgs, "fail if insolvable", true,
        [ HasIsSolvableGroup ], SUM_FLAGS,
    function( G )
    if not IsSolvableGroup( G )  then  return fail;
                                 else  TryNextMethod();  fi;
end );

InstallMethod( Pcgs, "take induced pcgs", true,
        [ IsPermGroup and HasInducedPcgsWrtHomePcgs ], 0,
    InducedPcgsWrtHomePcgs );

InstallMethod( Pcgs, "Sims's method", true, [ IsPermGroup ], 0,
    function( G )
    local   pcgs;
    
    pcgs := TryPcgsPermGroup( G, false, false, false );
    if not IsPcgs( pcgs )  then  return fail;
                           else  return pcgs;  fi;
end );

InstallMethod( Pcgs, "tail of perm pcgs", true,
        [ IsMemberPcSeriesPermGroup ], 0,
        PcgsMemberPcSeriesPermGroup );

#############################################################################
##
#M  HomePcgs( <G> ) . . . . . . . . . . . . . . . . . . . . . for perm groups
##
InstallMethod( HomePcgs, true, [ IsPermGroup ], 0,
    function( G )
    local   pcgs;
    
    pcgs := Pcgs( G );
    if IsPcgsPermGroupRep( pcgs )  then  return pcgs;
                                   else  TryNextMethod();  fi;
end );

#############################################################################
##
#M  GroupOfPcgs( <pcgs> ) . . . . . . . . . . . . . . . . . . for perm groups
##
InstallMethod( GroupOfPcgs, true, [ IsPcgs and IsPcgsPermGroupRep ], 0,
    function( pcgs )
    local   G;
    
    G := GroupStabChain( pcgs!.stabChain );
    SetPcgs( G, pcgs );
    return G;
end );

#############################################################################
##
#M  PcSeries( <pcgs> )  . . . . . . . . . . . . . . . . . . . for perm groups
##
InstallMethod( PcSeries, true, [ IsPcgs and IsPcgsPermGroupRep ], 0,
    function( pcgs )
    local   series,  N,  i;
    
    N := DeepCopy( StabChainAttr( TrivialSubgroup
                 ( GroupOfPcgs( pcgs ) ) ) );
    series := [ DeepCopy( N ) ];
    for i  in Reversed( [ 2 .. Length( pcgs ) ] )  do
        AddNormalizingElementPcgs( N, pcgs[ i ] );
        InsertElmList( series, 1, DeepCopy( N ) );
    od;
    InsertElmList( series, 1, ShallowCopy( GroupOfPcgs( pcgs ) ) );
    for i  in [ 2 .. Length( series ) ]  do
        series[ i ] := GroupStabChain( GroupOfPcgs( pcgs ), series[ i ],
                               true );
        N := series[ i - 1 ];
#        N.cspgNormal := series[ i ];
#        N.cspgFactor := CyclicGroup( RelativeOrders( pcgs )[ i - 1 ] );
    od;
    return series;
end );        

InstallOtherMethod( ElementaryAbelianSeries, true, [ IsPcgs ], 0,
    pcgs -> ElementaryAbelianSeries( GroupOfPcgs( pcgs ) ) );
InstallOtherMethod( DerivedSeriesOfGroup, true, [ IsPcgs ], 0,
    pcgs -> DerivedSeriesOfGroup( GroupOfPcgs( pcgs ) ) );
InstallOtherMethod( LowerCentralSeriesOfGroup, true, [ IsPcgs ], 0,
    pcgs -> LowerCentralSeriesOfGroup( GroupOfPcgs( pcgs ) ) );

#############################################################################
##
#M  InducedPcgsByPcSequenceNC( <pcgs>, <pcs> )  . . . . . . . .  as perm pcgs
##
InstallMethod( InducedPcgsByPcSequenceNC, "tail of perm pcgs", true,
    [ IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
      IsList and IsPermCollection ], 0,
    function( pcgs, pcs )
    local   igs,  i;

    i := Position( pcgs!.nrGensSeries, Length( pcs ) );
    if i = fail  or
       pcgs{ [ Length( pcgs ) - Length( pcs ) + 1 .. Length( pcgs ) ] } <>
       pcs  then
        TryNextMethod();
    fi;
    igs := PcgsByPcSequenceCons(
        IsPcgsDefaultRep,
        IsPcgs and IsInducedPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
        FamilyObj( OneOfPcgs( pcgs ) ),
        pcgs{ [ Length( pcgs ) - Length( pcs ) + 1 .. Length( pcgs ) ] } );
    igs!.stabChain := StabChainAttr( PcSeries( pcgs )[ i ] );
    SetRelativeOrders( igs, RelativeOrders( pcgs )
            { [ Length( pcgs ) - Length( pcs ) + 1 .. Length( pcgs ) ] } );
    SetPcSeries( igs, PcSeries( pcgs ){[i..Length(pcgs!.nrGensSeries)]} );
    igs!.nrGensSeries := pcgs!.nrGensSeries{[i..Length(pcgs!.nrGensSeries)]};
    SetParentPcgs( igs, pcgs );
    return igs;
end );

#InstallMethod( InducedPcgsByPcSequenceNC, "perm group", true,
#    [ IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
#      IsList and IsPermCollection ], 0,
#    function( pcgs, pcs )
#    local   igs,  i,  l;
#
#    i := 1;  l := pcgs!.nrGensSeries[ i ];
#    while pcs { [ Length( pcs  ) - l + 1 .. Length( pcs  ) ] } <>
#          pcgs{ [ Length( pcgs ) - l + 1 .. Length( pcgs ) ] }  do
#        i := i + 1;  l := pcgs!.nrGensSeries[ i ];
#    od;
#    igs := PcgsByPcSequenceNC( FamilyObj( OneOfPcgs( pcgs ) ),
#                    IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
#                    pcgs{ [ Length( pcgs ) - l + 1 .. Length( pcgs ) ] } );
#    igs!.stabChain := StabChainAttr( PcSeries( pcgs )[ i ] );
#    SetRelativeOrders( igs, RelativeOrders( pcgs )
#            { [ Length( pcgs ) - l + 1 .. Length( pcgs ) ] } );
#    SetPcSeries( igs, PcSeries( pcgs ){[i..Length(pcgs!.nrGensSeries)]} );
#    igs!.nrGensSeries := pcgs!.nrGensSeries{[i..Length(pcgs!.nrGensSeries)]};
#    igs := ExtendedPcgs( igs, pcs{ [ 1 .. Length( pcs ) - l ] } );
#    SetFilterObj( igs, IsInducedPcgs );
#    SetParentPcgs( igs, pcgs );
#    return igs;
#end );
    
#############################################################################
##
#M  InducedPcgsWrtHomePcgs( <U> ) . . . . . . . . . . . . . . . via home pcgs
##
InstallMethod( InducedPcgsWrtHomePcgs, "tail of perm pcgs", true,
        [ IsMemberPcSeriesPermGroup and HasHomePcgs ], 0,
    function( U )
    local   pcgs;
    
    pcgs := PcgsMemberPcSeriesPermGroup( U );
    SetFilterObj( pcgs, IsInducedPcgs );
    SetParentPcgs( pcgs, HomePcgs( U ) );
    return pcgs;
end );

InstallMethod( InducedPcgsWrtHomePcgs, "without home pcgs", true,
        [ IsPermGroup ], 0,
    function( G )
    local   home;
    
    home := HomePcgs( G );
    if IsIdentical( home, Pcgs( G ) )  then
        return InducedPcgsByPcSequenceNC( home, home );
    else
        return InducedPcgsByGenerators( home, GeneratorsOfGroup( G ) );
    fi;
end );

#############################################################################
##
#M  ExtendedPcgs( <N>, <gens> ) . . . . . . . . . . . . . . .  in perm groups
##
InstallMethod( ExtendedPcgs, "perm group", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
          IsList and IsPermCollection ], 10,
    function( N, gens )
    local   pcgs,  S,  gen;

    S := DeepCopy( N!.stabChain );
    S.relativeOrders := ShallowCopy( RelativeOrders( N ) );
    for gen  in Reversed( gens )  do
        AddNormalizingElementPcgs( S, gen );
    od;
    pcgs := PcgsByPcSequenceCons( 
         IsPcgsDefaultRep,
         IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
         FamilyObj( OneOfPcgs( N ) ),
         S.labels{ [ 2 .. Length( S.labels ) -
                    Length( N!.stabChain.labels ) + Length( N ) + 1 ] } );
    pcgs!.stabChain := S;
    SetRelativeOrders( pcgs, S.relativeOrders );
    Unbind( S.relativeOrders );
    SetGroupOfPcgs( pcgs, GroupStabChain( S ) );
    SetPcSeries( pcgs, Concatenation( [ GroupOfPcgs( pcgs ) ],
            PcSeries( N ) ) );
    pcgs!.nrGensSeries := Concatenation( [ Length( pcgs ) ],
            N!.nrGensSeries );
    return pcgs;
end );

#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <g> [ , <from> ] )  . . . . . . for perm groups
##
InstallMethod( DepthOfPcElement, true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm ], 0,
    function( pcgs, g )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Length( pcgs ), 'd' );
end );

InstallOtherMethod( DepthOfPcElement, true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm,
          IsInt ], 0,
    function( pcgs, g, depth )
    return ExponentsOfPcElementPermGroup( pcgs, g, depth, Length( pcgs ),
                   'd' );
end );
    
#############################################################################
##
#M  LeadingExponentOfPcElement( <pcgs>, <g> ) . . . . . . . . for perm groups
##
InstallMethod( LeadingExponentOfPcElement, true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm ], 0,
    function( pcgs, g )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Length( pcgs ), 'l' );
end );
    
#############################################################################
##
#M  ExponentsOfPcElement( <pcgs>, <g> [ , <poss> ] )  . . . . for perm groups
##
InstallMethod( ExponentsOfPcElement, "perm group", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm ], 0,
    function( pcgs, g )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Length( pcgs ), 'e' );
end );

InstallOtherMethod( ExponentsOfPcElement, "perm group with positions", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm,
          IsList ], 0,
    function( pcgs, g, poss )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Maximum( poss ), 'e' )
           { poss - Minimum( poss ) + 1 };
end );

InstallOtherMethod( ExponentsOfPcElement, "perm group with 0 positions", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm,
          IsList and IsEmpty ], 0,
    function( pcgs, g, poss )
    return [  ];
end );

#############################################################################
##
#M  ExponentOfPcElement( <pcgs>, <g>, <pos> ) . . . . . . . . for perm groups
##
InstallMethod( ExponentOfPcElement, true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm,
          IsPosRat and IsInt ], 0,
    function( pcgs, g, pos )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, pos, 'e' )[ pos ];
end );

#############################################################################
##
#M  RepresentativeOperation( <G>, <d>, <e>, OnPoints )   first compare cycles
##
InstallOtherMethod( RepresentativeOperationOp,
    "cycle structure comparison",
    true,
    [ IsPermGroup and IsPcgsComputable,
      IsPerm,
      IsPerm,
      IsFunction ],
    0,

function( G, d, e, opr )
    if opr <> OnPoints  then
        TryNextMethod();
    elif Collected( CycleLengths( d, MovedPoints( G ) ) ) <>
         Collected( CycleLengths( e, MovedPoints( G ) ) )  then
        return fail;
    else
        TryNextMethod();
    fi;
end );

#############################################################################
##

#M  NiceMonomorphism( <G> ) . . . . . . . . . . . . .  perm group as pc group
##
InstallMethod( NiceMonomorphism, true, [ IsPermGroup ], 0,
    IsomorphismPcGroup );

#############################################################################
##
#M  IsomorphismPcGroup( <G> ) . . . . . . . . . . . .  perm group ac pc group
##
InstallMethod( IsomorphismPcGroup, true, [ IsPermGroup ], 0,
    function( G )
    local   iso,  A,  pcgs,  index;
    
    # Make  a pcgs   based on  an  elementary   abelian series (good  for  ag
    # routines).
    if HasPcgs( G )  and  IsPcgsPermGroupRep( Pcgs( G ) )
                     and  HasElementaryAbelianSeries( Pcgs( G ) )  then
        pcgs := Pcgs( G );
    else
        pcgs := TryPcgsPermGroup( G, false, false, true );
        if not IsPcgs( pcgs )  then
            return fail;
        fi;
    fi;
    index := Length( pcgs ) + 1 - pcgs!.nrGensSeries;

    # Construct the pcp group <A> and the bijection between <A> and <G>.
    A := PcGroupPcgs( pcgs, index, false );
    iso := GroupHomomorphismByImages( G, A, pcgs, GeneratorsOfGroup( A ) );
    SetIsBijective( iso, true );
    
    return iso;
end );

#############################################################################
##
#M  NaturalHomomorphismByNormalSubgroup( <G>, <N> ) . .  for solvable factors
##
InstallMethod( NaturalHomomorphismByNormalSubgroup, IsIdentical,
        [ IsPermGroup, IsPermGroup ], 0,
    function( G, N )
    local   map,  pcgs,  A,  index;
    
    # Make  a pcgs   based on  an  elementary   abelian series (good  for  ag
    # routines).
    pcgs := TryPcgsPermGroup( [ G, N ], false, false, true );
    if not IsPcgs( pcgs )  then
        TryNextMethod();
    fi;
    index := Length( pcgs ) + 1 - pcgs!.nrGensSeries;

    # Construct the pcp group <A> and the bijection between <A> and <G>.
    A := PcGroupPcgs( pcgs, index, false );
    map := GroupHomomorphismByImages( G, A, pcgs, GeneratorsOfGroup( A ) );
    SetIsSurjective( map, true );
    SetKernelOfMonoidGeneralMapping( map, N );
    
    return map;
end );

#############################################################################
##
##  Local Variables:
##  mode:             outline-minor
##  outline-regexp:   "#[WCROAPMFVE]"
##  fill-column:      77
##  End:

#############################################################################
##
#E  pcgsperm.gi . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
