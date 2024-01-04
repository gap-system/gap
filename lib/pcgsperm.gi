#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file  contains    functions which deal with   polycyclic  generating
##  systems of solvable permutation groups.
##

#############################################################################
##
#R  IsMemberPcSeriesPermGroup . . . . . . . . . . . . .  members of pc series
##
DeclareRepresentation( "IsMemberPcSeriesPermGroup",
    IsPermGroup, [ "noInSeries" ] );

#############################################################################
##
#F  AddNormalizingElementPcgs( <G>, <z> ) . . . . . cyclic extension for pcgs
##
InstallGlobalFunction( AddNormalizingElementPcgs, function( G, z )
  local   S,  A,  pos,  relord,
            pnt,  orb,  l,  L,  n,  m,  img,  i,  f,  p,  edg;

    StretchImportantSLPElement(z);
    S := G;
    A := G;
    pos := 1;
    L := [  ];
    if IsBound( G.relativeOrders )  then  relord := G.relativeOrders;
                                    else  relord := false;             fi;

    # Loop over the stabilizer chain.
    while z <> S.identity  do

        # If necessary, extend the stabilizer chain.
        if IsBound( G.base )  then
            ChooseNextBasePoint( S, G.base, [ z ] );
        elif not IsBound( S.stabilizer )  then
            InsertTrivialStabilizer( S, SmallestMovedPoint( z ) );
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
            for p  in Factors(Integers, m )  do
                if relord <> false  then
                    Add( relord, p, pos );
                fi;
                pos := pos + 1;
                Add( S.labels, z, pos );
                edg := ListWithIdenticalEntries( l, -pos );
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
        for z in S.generators do
          StretchImportantSLPElement(z);
        od;
        S := S.stabilizer;
    od;

    return true;
end );

#############################################################################
##
#F  ExtendSeriesPermGroup( ... )  . . . . . . extend a series of a perm group
##
InstallGlobalFunction( ExtendSeriesPermGroup, function(
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
            series[ lev + 2 ] := StructuralCopy( series[ lev + 1 ] );
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
        M0 := StructuralCopy( M1 );
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

        ord := Order( s );
        if not IsEmpty( X )  then
            gcd := GcdInt( ord, Order( X[ 1 ] ) );
            if gcd <> 1  then
                ord := gcd;
            fi;
        fi;
        p := Factors(Integers, ord )[ 1 ];
    fi;

    # Loop over all conjugates of <s>.
    C := [ s ];
    while not IsEmpty( C )  do
        t := C[ 1 ];
        C := C{ [ 2 .. Length( C ) ] };
        if not MembershipTestKnownBase( M0, G, t )  then

            # Form  all necessary  commutators with  <t>   and for elementary
            # abelian factors also a <p>th power.
            if cent  then  T := SSortedList( GeneratorsOfGroup( G ) );
                     else  T := SSortedList( X );                       fi;
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
                    M0 := StructuralCopy( M1 );
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
            Remove( series, lev + 2 );
        fi;
    else
        if not IsEmpty( X )  then
            Add( series, M0, 1 );
        fi;
    fi;

    return true;
end );

#############################################################################
##
#F  TryPcgsPermGroup(<Act>[, <G>] , <cent>, <desc>, <elab>) . . try for pcgs
##
InstallGlobalFunction(TryPcgsPermGroup,function(arg)
    local   grp,  pcgs,  U,  oldlen,  series,  y,  w,  whole,
            bound,  deg,  step,  i,  S,  filter,A,G,cent,desc,elab;

    A:=arg[1];
    cent:=arg[Length(arg)-2];
    desc:=arg[Length(arg)-1];
    elab:=arg[Length(arg)];

    # If the last member <U> of the series <G> already has a pcgs, start with
    # its stabilizer chain.
    if IsList( A )  then
        G:=A;
        A:=A[1];
        U := G[ Length( G ) ];
        if HasPcgs( U )  and  IsPcgsPermGroupRep( Pcgs( U ) )  then
            U := CopyStabChain( Pcgs( U )!.stabChain );
        fi;
    elif Length(arg)>4 then
      G:=arg[2];
      U := TrivialSubgroup( G );
      if ForAll(GeneratorsOfGroup(G),IsOne) then G:=[G];
                                      else G:=[G,U];fi;
    else
      G:=A;
      U := TrivialSubgroup( G );
      if IsTrivial( G )  then  G := [ G ];
                          else  G := [ G, U ];  fi;
    fi;

    # Otherwise start  with stabilizer chain  of  <U> with identical `labels'
    # components on all levels.
    if IsGroup( U )  then
        if IsTrivial( U )  and  not HasStabChainMutable( U )  then
            U := EmptyStabChain( [  ], One( U ) );
        else
            S:=U;
            U := StabChainMutable( U );
            if IsBound( U.base )  and Length(U.base)>0  then  i := U.base;
                                  else  i := fail;   fi;

            # ensure compatible bases
            if HasBaseOfGroup(G[1])
               and not IsSubset(BaseOfGroup(G[1]),BaseStabChain(U)) then

              # ensure compatible bases

              # compute a new stab chain without touching the stab chain
              # stored in S
              #T this is less than satisficial but I don't see how otherwise
              #T to avoid those %$#@ side effects. AH
              U:= StabChainOp( GroupByGenerators(GeneratorsOfGroup(S),One(S) ),
                             rec(base:=BaseOfGroup(G[1]),size:=Size(S)));
            else
              U := StabChainBaseStrongGenerators( BaseStabChain( U ),
                           StrongGeneratorsStabChain( U ),U.identity );
              if i <> fail  then
                  U.base := i;
              fi;
           fi;
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

    oldlen := Length( U.labels );
    series := [ U ];
    series[ 1 ].relativeOrders := [  ];

    if not IsTrivial( grp )  then

        # The derived  length of  <G> was  bounded by  Dixon. The  nilpotency
        # class of <G> is at most Max( log_p(d)-1 ).
        deg := NrMovedPoints( grp );
        if cent  then
            bound := Maximum( List( Collected( Factors(Integers, deg ) ), p ->
                             p[ 1 ] ^ ( LogInt( deg, p[ 1 ] ) ) ) );
        else
            bound := Int( LogInt( deg ^ 5, 3 ) / 2 );
        fi;
        # avoid recursion trap through Size
        if bound>4900 then Size(grp); fi;
        if     HasSize( grp )
           and Length( Factors(Integers, Size( grp ) ) ) < bound  then
            bound := Length( Factors(Integers, Size( grp ) ) );
        fi;

        for step  in Reversed( [ 1 .. Length( G ) - 1  ] )  do
            for y  in GeneratorsOfGroup( G[ step ] )  do
                if not y in GeneratorsOfGroup( G[ step + 1 ] )  then
                    w := ExtendSeriesPermGroup( A, series, cent,
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
#T this should be cleaned up.
                        return [ PcgsStabChainSeries( IsPcgsPermGroupRep,
                                 GroupStabChain( grp, series[ 1 ], true ),
                                 series, oldlen,false ),
                                 w ];

                    fi;
                fi;
            od;
        od;
    fi;

    # Construct the pcgs object.
    if whole  then  filter := IsPcgsPermGroupRep;
              else  filter := IsModuloPcgsPermGroupRep;  fi;

    if elab=true then
      filter:=filter and IsPcgsElementaryAbelianSeries;
    fi;

    if cent then
      filter:=filter and IsPcgsCentralSeries;
    fi;

    pcgs := PcgsStabChainSeries( filter, grp, series, oldlen,
      (elab=true) or cent);

    if whole  then
        SetIsSolvableGroup( grp, true );
        SetPcgs( grp, pcgs );
        if not HasHomePcgs( grp ) then
          SetHomePcgs( grp, pcgs );
        fi;
        SetGroupOfPcgs (pcgs, grp);
        if cent  then
            SetIsNilpotentGroup( grp, true );
        fi;
    else
        pcgs!.denominator := G[ Length( G ) ];
        if     HasIsSolvableGroup( G[ Length( G ) ] )
           and IsSolvableGroup( G[ Length( G ) ] )  then
            SetIsSolvableGroup( grp, true );
        fi;
    fi;
    return pcgs;
end);

## Based on `TryPcgsPermGroup', a method for PcgsByPcSequence

BindGlobal("ExtendSeriesPGParticular", function(
            G,       # the group in which factors are to be normal
            series,  # the series being constructed
            adds)     # the elements to be added to `series[ <lev> ]'

  local   M0,  M1,  C,  X,  oldX,  T,  t,  u,  w,  r,  done,
          ord,  p,ap,s;

  # As series  need not be   fastest-descending, prepare to add  a new
  # group to the list.
  M1 := series[ 1 ];
  M0 := StructuralCopy( M1 );
  X := [  ];
  r := 1;

  # find next elt to add
  ap:=1;
  while MembershipTestKnownBase(M0,G,adds[ap])=true do
    ap:=ap+1;
    if ap>Length(adds) then
      return fail; # nothing to add
    fi;
  od;
  s:=adds[ap];

  # find prime.
  ord:=Factors(Order( s ));
  p:=First(Set(ord),x->MembershipTestKnownBase(M0,G,s^x)=true);

  # Loop over adds
  ap:=ap-1;
  C := [s];
  while not IsEmpty( C )  do
    t := C[ 1 ];
    if not MembershipTestKnownBase( M0, G, t )  then

      # Form  all necessary  commutators with  <t>   and for elementary
      # abelian factors also a <p>th power.
      T := SSortedList( X );
      done := false;
      while not done  and  not IsEmpty( T ) do
        if not IsEmpty( T )  then
          u := T[ 1 ];        RemoveSet( T, u );
          w := Comm( t, u );
        else
          done := true;
          w := t ^ p;
        fi;

        # If   the commutator or  power  is not  in <M1>,
        # it was not a proper pcgs
        if not MembershipTestKnownBase( M1, G, w )  then
          return w;
        fi;

      od;

      ap:=ap+1;
      t:=adds[ap];

      # Add <t> to <M0> and register its conjugates.
      if AddNormalizingElementPcgs( M0, t )  then
        Add( X, t );
      fi;
      Append( C, List( GeneratorsOfGroup( G ), g -> t ^ g ) );

    else
      # this t is done with
      C := C{ [ 2 .. Length( C ) ] };
    fi;
  od;

  if not IsEmpty( X )  then
    Add( series, M0, 1 );
  fi;

  return true;
end );

InstallGlobalFunction(PermgroupSuggestPcgs,function(G,pcseq)
local   grp,  pcgs,  U,  series,   w, bound,  deg,  S,  filter;

  U := TrivialSubgroup( G );
  G := [ G, U ];
  # Otherwise start  with stabilizer chain  of  <U> with identical `labels'
  # components on all levels.
  U := EmptyStabChain( [  ], One( U ) );

  # The `genlabels' at every level of $U$ must be sets.
  S := U;
  while not IsEmpty( S.genlabels )  do
    Sort( S.genlabels );
    S := S.stabilizer;
  od;

  grp := G[ 1 ];

  series := [ U ];
  series[ 1 ].relativeOrders := [  ];

  # The derived  length of  <G> was  bounded by  Dixon. The  nilpotency
  # class of <G> is at most Max( log_p(d)-1 ).
  deg := NrMovedPoints( grp );
  bound := Int( LogInt( deg ^ 5, 3 ) / 2 );
  if HasSize( grp ) and Length( Factors(Integers, Size( grp ) ) ) < bound  then
    bound:=Length( Factors(Integers, Size( grp ) ) );
  fi;

  pcseq:=Reversed(pcseq); # build up

  # can do repeat-until as group is not trivial
  repeat
    w := ExtendSeriesPGParticular( G[1], series, pcseq);
    if w <> true  and w<>fail then
      # if it fails the pcgs does not fit an elementary
      # abelian series. In this case we need to defer to the
      # generic approach.
      return fail;
    fi;
    #Print(List(series,SizeStabChain),":",Length(series[1].labels),":",List(series[1].labels,x->Position(pcseq,x)),"\n");
  until w=fail;

  # Construct the pcgs object.
  filter := IsPcgsPermGroupRep and IsPcgsElementaryAbelianSeries;

  pcgs := PcgsStabChainSeries( filter, grp, series, 1,true);

  if Set(GeneratorsOfGroup(grp))=Set(pcseq) then
    SetIsSolvableGroup( grp, true );
    SetPcgs( grp, pcgs );
    SetHomePcgs( grp, pcgs );
  fi;
  SetGroupOfPcgs (pcgs, grp);
  return pcgs;
end);

# arbitrary pc sequence pcgs for perm group. Construct pcgs from it using
# variant of sims' algorithm, then use translation of exponents.
InstallMethod(PcgsByPcSequenceNC,"perm group, Sims' algorithm",true,
  [IsFamily,IsHomogeneousList and IsPermCollection],0,

function( efam, pcs )
    local   pfa,  pcgs,  pag,  id,  g,  dg,  i,  new,
    ord,codepths,pagpow,sorco,filter;

    # quick check
    if not IsIdenticalObj( efam, ElementsFamily(FamilyObj(pcs)) )  then
        Error( "elements family of <pcs> does not match <efam>" );
    fi;

    if ForAll(pcs,IsOne) then
      TryNextMethod(); # degenerate case
    fi;

    pfa := PermgroupSuggestPcgs(Group(pcs),pcs);
    if pfa=fail then
      TryNextMethod();
    fi;

    if pfa=pcs then
      # is it by happenstance the one we want?
      return pfa;

    else
      # make a sorted/unsorted pcgs

      # sort the elements according to the depth wrt pfa
      pag := [];
      new := [];
      ord := [];
      id  := One(pcs[1]);
      for i  in [ Length(pcs), Length(pcs)-1 .. 1 ]  do
        g  := pcs[i];
        dg := DepthOfPcElement( pfa, g );
        while g <> id and IsBound(pag[dg])  do
          g  := ReducedPcElement( pfa, g, pag[dg] );
          dg := DepthOfPcElement( pfa, g );
        od;
        if g <> id  then
          pag[dg] := g;
          new[dg] := i;
          ord[i]  := RelativeOrderOfPcElement( pfa, g );
        fi;
      od;
      if not IsHomogeneousList(ord) then
        Error("not all relative orders given");
      fi;

      filter:=IsPcgs;

      if IsSSortedList(new) and Length(new)=Length(pfa) then
        filter:=filter and IsSortedPcgsRep;
      else
        filter:=filter and IsUnsortedPcgsRep;
      fi;

      # we have the same sequence, same depths, just changed by
      # multiplying elements of a lower level
      pcgs := PcgsByPcSequenceCons( IsPcgsDefaultRep, filter,
                  efam, pcs,[] );

      pcgs!.sortedPcSequence := pag;
      pcgs!.newDepths        := new;
      pcgs!.sortingPcgs      := pfa;

      # Precompute the leading coeffs and the powers of pag up to the
      # relative order
      pagpow:=[];
      sorco:=[];
      for i in [1..Length(pag)] do
        if IsBound(pag[i]) then
          pagpow[i]:=
            List([1..RelativeOrderOfPcElement(pfa,pag[i])-1],j->pag[i]^j);
          sorco[i]:=LeadingExponentOfPcElement(pfa,pag[i]);
        fi;
      od;
      pcgs!.sortedPcSeqPowers:=pagpow;
      pcgs!.sortedPcSequenceLeadCoeff:=sorco;

      # codepths[i]: the minimum pcgs-depth that can be implied by pag-depth i
      codepths:=[];
      for dg in [1..Length(new)] do
        g:=Length(new)+1;
        for i in [dg..Length(new)] do
          if IsBound(new[i]) and new[i]<g then
            g:=new[i];
          fi;
        od;
        codepths[dg]:=g;
      od;
      pcgs!.minimumCodepths:=codepths;
      SetRelativeOrders( pcgs, ord );
      if IsSortedPcgsRep(pcgs) then
        pcgs!.inversePowers:=
                      List([1..Length(pfa)],i->(1/sorco[i]) mod ord[i]);
      fi;
  fi;

  return pcgs;

end );

#############################################################################
##
#F  PcgsStabChainSeries( <filter>, <G>, <series>, <oldlen>,<iselab> )
##
InstallGlobalFunction(PcgsStabChainSeries,
function(filter,G,series,oldlen,iselab)
    local   pcgs,  first,  i,attr;

    first := [  ];
    for i  in [ 1 .. Length( series ) ]  do
      Add( first, Length( series[ i ].labels ) );
    od;
    first:=first[ 1 ] - first + 1;


    filter:=filter and IsPcgs and IsPrimeOrdersPcgs;
    attr:=[];
    if iselab=true then
      filter:=filter and HasIndicesEANormalSteps;
      attr:=[IndicesEANormalSteps, first];
    fi;
    pcgs := PcgsByPcSequenceCons( IsPcgsDefaultRep,filter,
                ElementsFamily( FamilyObj( G ) ),
                series[ 1 ].labels
                { 1 + [ 1 .. Length(series[ 1 ].labels) - oldlen ] },
                attr );

    SetRelativeOrders(pcgs, series[ 1 ].relativeOrders);
    pcgs!.stabChain := series[ 1 ];
    pcgs!.generatingSeries:=series;
    pcgs!.permpcgsNormalSteps:=first;

#    if HasHomePcgs(G) and HomePcgs(G)<>pcgs then
#      G:=Group(series[1].generators,());
#    fi;
#    SetGroupOfPcgs( pcgs, G );

    return pcgs;
end );

BindGlobal("NorSerPermPcgs",function(pcgs)
local ppcgs,series,stbc,G,i;
  ppcgs := ParentPcgs (pcgs);
  G:=GroupOfPcgs(pcgs);
  series:=EmptyPlist( Length(pcgs!.generatingSeries) );
  for i  in [ 1 .. Length( pcgs!.generatingSeries ) ]  do
    stbc := ShallowCopy (pcgs!.generatingSeries[i]);
    Unbind( stbc.relativeOrders );
    Unbind( stbc.base           );
    series[ i ] := GroupStabChain( G, stbc, true );
    if (not HasHomePcgs(series[i]) ) or HomePcgs(series[i]) = ppcgs then
      SetHomePcgs ( series[ i ], ppcgs );
      SetFilterObj( series[ i ], IsMemberPcSeriesPermGroup );
      series[ i ]!.noInSeries := i;
    fi;
  od;
  return series;
end);

InstallMethod(EANormalSeriesByPcgs,"perm group rep",true,
   [IsPcgs and IsPcgsElementaryAbelianSeries and IsPcgsPermGroupRep],0,
   NorSerPermPcgs);

InstallOtherMethod(EANormalSeriesByPcgs,"perm group modulo rep",true,
  [IsModuloPcgsPermGroupRep and IsPcgsElementaryAbelianSeries],0,
  NorSerPermPcgs);

#############################################################################
##
#F  PcgsMemberPcSeriesPermGroup( <U> ) . . . . pcgs for a group in the series
##
InstallGlobalFunction( PcgsMemberPcSeriesPermGroup, function( U )
    local   home,  pcgs,npf;

    home := HomePcgs( U );
    npf:=home!.permpcgsNormalSteps;

    if U!.noInSeries>Length(npf) then
      # special treatment for the trivial subgroup
      pcgs:=InducedPcgsByGenerators(home,GeneratorsOfGroup(U));
    else
      pcgs := TailOfPcgsPermGroup( home,
                      npf[ U!.noInSeries ] );
    fi;
    SetGroupOfPcgs( pcgs, U );
    return pcgs;
end );

#############################################################################
##
#F  ExponentsOfPcElementPermGroup( <pcgs>, <g>, <min>, <max>, <mode> )  local
##
InstallGlobalFunction( ExponentsOfPcElementPermGroup,
    function( pcgs, g, mindepth, maxdepth, mode )
    local   exp,  base,  bimg,  r,  depth,  img,  H,  bpt,  gen,  e,  i;

    if mode = 'e'  then
        exp := ListWithIdenticalEntries( maxdepth - mindepth + 1, 0 );
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
            elif mode='s' then
              return [depth-1,e];
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
    elif mode = 's'  then  return [maxdepth+1,0];
    else                   return exp;  fi;
end );

#############################################################################
##
#F  PermpcgsPcGroupPcgs( <pcgs>, <index>, <isPcgsCentral> )
##
##  different than `PcGroupWithPcgs' since extra parameters for shortcut.
##
InstallGlobalFunction( PermpcgsPcGroupPcgs, function( pcgs, index, isPcgsCentral )
    local   m,  sc,  gens,  p,  i,  i2,  n,  n2;

    m := Length( pcgs );
    sc := SingleCollector( FreeGroup(IsSyllableWordsFamily, m ),
                           RelativeOrders( pcgs ) );
    gens := GeneratorsOfRws( sc );

    # Find the relations of the p-th powers. Use  the  vector space structure
    # of the elementary abelian factors.
    for i  in [ 1 .. Length( index ) - 1 ]  do
        p := RelativeOrders( pcgs )[ index[ i ] ];
        for n  in [ index[ i ] .. index[ i + 1 ] - 1 ]  do
            SetPowerNC( sc, n, LinearCombinationPcgs
                    ( gens, ExponentsOfPcElement
                      ( pcgs, pcgs[ n ] ^ p ) ) );
        od;
    od;

    # Find the relations of the conjugates.
    for i  in [ 1 .. Length( index ) - 1 ]  do
        for n  in [ index[ i ] .. index[ i + 1 ] - 1 ]  do
            for i2  in [ 1 .. i - 1 ]  do
                if isPcgsCentral then
                    for n2  in [ index[ i2 ] .. index[ i2 + 1 ] - 1 ]  do
                        SetConjugateNC( sc, n, n2,
                            GeneratorsOfRws( sc )[ n ]*
                        LinearCombinationPcgs( gens,
                            ExponentsOfPcElement( pcgs, Comm
                            ( pcgs[ n ], pcgs[ n2 ] ) ) ) );
                    od;
                else
                    for n2  in [ index[ i2 ] .. index[ i2 + 1 ] - 1 ]  do
                        SetConjugateNC( sc, n, n2, LinearCombinationPcgs( gens,
                            ExponentsOfPcElement
                            ( pcgs,
                              pcgs[ n ] ^ pcgs[ n2 ]) ) );
                    od;
                fi;
            od;
            for n2  in [ index[ i ] .. n - 1 ]  do
                SetConjugateNC( sc, n, n2,
                    GeneratorsOfRws( sc )[ n ]*LinearCombinationPcgs( gens,
                      ExponentsOfPcElement( pcgs, Comm
                      ( pcgs[ n ], pcgs[ n2 ] ) ) ) );
            od;
        od;
    od;
    UpdatePolycyclicCollector( sc );
    m:=GroupByRwsNC( sc );
    SetParentAttr(m,m); # some other routines are obnocious otherwise.
    return m;
end );

#############################################################################
##
#F  SolvableNormalClosurePermGroup( <G>, <H> )  . . . solvable normal closure
##
InstallGlobalFunction( SolvableNormalClosurePermGroup, function( G, H )
    local   U,  oldlen,  series,  bound,  z,  S;

    U := CopyStabChain( StabChainImmutable( TrivialSubgroup( G ) ) );
    oldlen := Length( U.labels );

    # The `genlabels' at every level of $U$ must be sets.
    S := U;
    while not IsEmpty( S.genlabels )  do
        Sort( S.genlabels );
        S := S.stabilizer;
    od;

    if HasBaseOfGroup(G) and not IsSubset(G,BaseStabChain(U)) then
      Error("incompatible bases");
    fi;

    U.relativeOrders := [  ];
    series := [ U ];

    # The derived length of <G> is at most (5 log_3(deg(<G>)))/2 (Dixon).
    bound := Int( LogInt( Maximum(1,NrMovedPoints( G ) ^ 5), 3 ) / 2 );
    if     HasSize( G )
       and Length( Factors(Integers, Size( G ) ) ) < bound  then
        bound := Length( Factors(Integers, Size( G ) ) );
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
    SetIsSolvableGroup( U, true );
    SetIsNormalInParent( U, true );

    # remember the pcgs
    SetPcgs(U,PcgsStabChainSeries(IsPcgsPermGroupRep,U,series,oldlen,false));

    return U;
end );

#############################################################################
##
#M  NumeratorOfModuloPcgs( <pcgs> ) . . . . . . . . . .  for perm modulo pcgs
##
InstallOtherMethod( NumeratorOfModuloPcgs, true,
    [ IsModuloPcgsPermGroupRep ], 0,
    pcgs -> Pcgs( GroupOfPcgs( pcgs ) ) );

#############################################################################
##
#M  DenominatorOfModuloPcgs( <pcgs> ) . . . . . . . . .  for perm modulo pcgs
##
InstallOtherMethod( DenominatorOfModuloPcgs, true,
    [ IsModuloPcgsPermGroupRep ], 0,
    pcgs -> Pcgs( pcgs!.denominator ) );

#############################################################################
##
#M  Pcgs( <G> ) . . . . . . . . . . . . . . . . . . . .  pcgs for perm groups
##
InstallMethod( Pcgs, "Sims's method", true, [ IsPermGroup ],
        100,  # to override method ``from indep. generators of abelian group''
    function( G )
    local   pcgs;

    pcgs := TryPcgsPermGroup( G, false, false, true );
    if not IsPcgs( pcgs )  then
      return fail;
    else
      if not HasPcgsElementaryAbelianSeries(G) then
        SetPcgsElementaryAbelianSeries(G,pcgs);
      fi;
      return pcgs;
    fi;
end );

InstallMethod( Pcgs, "tail of perm pcgs", true,
        [ IsMemberPcSeriesPermGroup ], 100,
        PcgsMemberPcSeriesPermGroup );


#############################################################################
##
#M  HomePcgs( <G> ) . . . . . . . . . . . . . . . . home pcgs for perm groups
##
InstallMethod( HomePcgs, "use a perm pcgs if possible", true,
    [ IsPermGroup and HasPcgs ],
    function( G )
    local   pcgs;

    pcgs := Pcgs( G );
    if IsPcgsPermGroupRep( pcgs ) then
        if HasParentPcgs( pcgs ) then
            return ParentPcgs( pcgs );
        else
            return pcgs;
        fi;
    else
        TryNextMethod();
    fi;
end);


InstallMethod( HomePcgs, "try to compute a perm pcgs", true,
    [ IsPermGroup ],
    function( G )
    local   pcgs;

    pcgs := TryPcgsPermGroup( G, false, false, true );

    if not IsPcgs( pcgs )  then
        TryNextMethod();
    else
      if not HasPcgsElementaryAbelianSeries(G) then
        SetPcgsElementaryAbelianSeries(G,pcgs);
      fi;
      return pcgs;
    fi;
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
    local   series,  G,  N,  i;

    G := GroupOfPcgs( pcgs );
    N := CopyStabChain( StabChainImmutable( TrivialSubgroup( G ) ) );
    series := [ GroupStabChain( G, CopyStabChain( N ), true ) ];
    for i  in Reversed( [ 1 .. Length( pcgs ) ] )  do
        AddNormalizingElementPcgs( N, pcgs[ i ] );
        Add( series, GroupStabChain( G, CopyStabChain( N ), true ) );
    od;
    return Reversed( series );
end );

#############################################################################
##
#F  TailOfPcgsPermGroup( <pcgs>, <from> ) . . . . . . . . construct tail pcgs
##
InstallGlobalFunction( TailOfPcgsPermGroup, function( pcgs, from )
local   tail,  i,ins,pins,ran,filt,attr;

  i := 1;
  pins:=pcgs!.permpcgsNormalSteps;
  while pins[ i ] < from  do
      i := i + 1;
  od;
  ran:=[pins[i]..Length(pcgs)];

  ins:=pins{[i..Length(pins)]}-from+1;

  filt:=IsPcgs
        #NOT PcgsPermGroupRep -- otherwise we get wrong exponents!
        #and IsPcgsPermGroupRep
        and IsPrimeOrdersPcgs
        and IsInducedPcgs and IsInducedPcgsRep and IsTailInducedPcgsRep
        and HasParentPcgs;
  attr:=[ParentPcgs,pcgs];

  if HasIndicesEANormalSteps(pcgs) then
    filt:=filt and HasIndicesEANormalSteps;
    Append(attr,[IndicesEANormalSteps,ins]);
  fi;
  if HasEANormalSeriesByPcgs(pcgs) then
    filt:=filt and HasEANormalSeriesByPcgs;
    Append(attr,[EANormalSeriesByPcgs,
                 EANormalSeriesByPcgs(pcgs){[i..Length(pins)]}]);
  fi;

  tail := PcgsByPcSequenceCons(
          IsPcgsDefaultRep,
          filt,
          FamilyObj( OneOfPcgs( pcgs ) ),
          pcgs{[pins[i]..Length(pcgs)]},
          attr);

  tail!.permpcgsNormalSteps:=ins;

  SetRelativeOrders(tail,RelativeOrders(pcgs){[from..Length(pcgs)]});
  tail!.stabChain := StabChainMutable( EANormalSeriesByPcgs( pcgs )[ i ] );
  if from < pins[ i ]  then
    tail := ExtendedPcgs( tail,
                    pcgs{ [ from .. pins[ i ] - 1 ] } );
  fi;
  tail!.tailStart := from;
  # information many InducedPcgs methods use
  tail!.depthsInParent:=ran;
  tail!.depthMapFromParent:=[];
  tail!.depthMapFromParent{ran}:=[1..Length(tail)];
  tail!.depthMapFromParent[Length(pcgs)+1]:=Length(tail)+1;
  return tail;

end );

#############################################################################
##
#M  InducedPcgsByPcSequenceNC( <pcgs>, <pcs> )  . . . . . . . .  as perm pcgs
##
InstallMethod( InducedPcgsByPcSequenceNC, "tail of perm pcgs", true,
  [ IsPcgsPermGroupRep and IsPrimeOrdersPcgs and IsPcgs,
    IsList and IsPermCollection ], 0,
function( pcgs, pcs )
local   l,i,ran;

  l := Length( pcgs )-Length( pcs );
  i := Position( pcgs!.permpcgsNormalSteps, l+1 );
  ran:=[ l + 1 .. Length( pcgs ) ];
  if i = fail  or pcgs{ ran } <> pcs  then
    TryNextMethod();
  fi;
  return TailOfPcgsPermGroup(pcgs,ran[1]);
end );

#############################################################################
##
#M  InducedPcgsWrtHomePcgs( <U> ) . . . . . . . . . . . . . . . via home pcgs
##
InstallMethod( InducedPcgsWrtHomePcgs, "tail of perm pcgs", true,
        [ IsMemberPcSeriesPermGroup and HasHomePcgs ], 0,
function( U )
local   pcgs,par,ran;

  pcgs := PcgsMemberPcSeriesPermGroup( U );
  par:=HomePcgs(U);
  SetFilterObj( pcgs, IsInducedPcgs and IsInducedPcgsRep);
  SetParentPcgs( pcgs,par ) ;
  # information many InducedPcgs methods use
  ran:=[par!.permpcgsNormalSteps[U!.noInSeries]..Length(par)];
  pcgs!.depthsInParent:=ran;
  pcgs!.depthMapFromParent:=[];
  pcgs!.depthMapFromParent{ran}:=[1..Length(pcgs)];
  pcgs!.depthMapFromParent[Length(par)+1]:=Length(pcgs)+1;
  pcgs!.tailStart:=par!.permpcgsNormalSteps[U!.noInSeries];
  return pcgs;
end );

#############################################################################
##
#M  ExtendedPcgs( <N>, <gens> ) . . . . . . . . . . . . . . .  in perm groups
##
InstallMethod( ExtendedPcgs, "perm pcgs", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
          IsList and IsPermCollection ], 0,
    function( N, gens )
    local   S,  gen,  pcs,  pcgs;

    S := CopyStabChain( N!.stabChain );
    S.relativeOrders := ShallowCopy( RelativeOrders( N ) );
    for gen  in Reversed( gens )  do
        AddNormalizingElementPcgs( S, gen );
    od;
    pcs := S.labels{ [ 2 .. Length( S.labels ) -
                   Length( N!.stabChain.labels ) + Length( N ) + 1 ] };
    if IsInducedPcgs( N )  then
        pcgs := InducedPcgsByPcSequenceNC( ParentPcgs( N ), pcs );
    else
        pcgs := PcgsByPcSequenceCons( IsPcgsDefaultRep,
                        IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs,
                        FamilyObj( OneOfPcgs( N ) ), pcs,[] );
    fi;
    pcgs!.stabChain := S;
    SetRelativeOrders( pcgs, S.relativeOrders );
    Unbind( S.relativeOrders );
    pcgs!.permpcgsNormalSteps:=Concatenation([1],N!.permpcgsNormalSteps+1);
    SetEANormalSeriesByPcgs( pcgs, Concatenation( [ GroupStabChain( S ) ],
            EANormalSeriesByPcgs( N ) ) );
    return pcgs;
end );

#############################################################################
##
#M  DepthOfPcElement( <pcgs>, <g> [ , <from> ] )  . . . . . . for perm groups
##
InstallMethod( DepthOfPcElement,"permpcgs", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm ], 0,
    function( pcgs, g )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Length( pcgs ), 'd' );
end );

InstallMethod( DepthAndLeadingExponentOfPcElement,"permpcgs", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm ], 0,
    function( pcgs, g )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Length( pcgs ), 's' );
end );

InstallOtherMethod( DepthOfPcElement,"permpcgs,start", true,
        [ IsPcgs and IsPcgsPermGroupRep and IsPrimeOrdersPcgs, IsPerm,
          IsPosInt ], 0,
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
          IsList and IsCyclotomicCollection ], 0,
    function( pcgs, g, poss )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, Maximum( poss ), 'e' )
           { poss };
           # was: { poss - Minimum( poss ) + 1 };
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
          IsPosInt ], 0,
    function( pcgs, g, pos )
    return ExponentsOfPcElementPermGroup( pcgs, g, 1, pos, 'e' )[ pos ];
end );

#############################################################################
##
#M  RepresentativeAction( <G>, <d>, <e>, OnPoints )   first compare cycles
##
InstallOtherMethod( RepresentativeActionOp,
  "cycle structure comparison for solvable perm groups", true,
  [ IsPermGroup and CanEasilyComputePcgs, IsPerm, IsPerm, IsFunction ], 0,
function( G, d, e, opr )
    if opr <> OnPoints  or not (d in G and e in G) then
        TryNextMethod();
    elif Collected( CycleLengths( d, MovedPoints( G ) ) ) <>
         Collected( CycleLengths( e, MovedPoints( G ) ) )  then
        return fail;
    else
        TryNextMethod();
    fi;
end );

BIND_GLOBAL( "CYCLICACHE", NEW_SORTED_CACHE(false) );

InstallGlobalFunction(CreateIsomorphicPcGroup,function(pcgs,needindices,flag)
local r,i,p,A,f,a;
  r:=RelativeOrders(pcgs);
  if Length(r)<=1 then
    p:=Product(r);
    return GET_FROM_SORTED_CACHE(CYCLICACHE, p,
        {} -> PermpcgsPcGroupPcgs( pcgs, IndicesEANormalSteps(pcgs), flag ));
  fi;

  # is the group in the mappings families cache?
  f:=FamiliesOfGeneralMappingsAndRanges(FamilyObj(OneOfPcgs(pcgs)));
  i:=1;
  atomic readonly GENERAL_MAPPING_REGION do # for HPC-GAP; does nothing in plain GAP
  while i<=Length(f) do
    a:=ElmWPObj(f,i);
    if a<>fail and IsBound(a!.DefiningPcgs)
       and RelativeOrders(a!.DefiningPcgs)=r then
      # right type PCGS -- test relations
      a:=a!.DefiningPcgs;
      if (needindices=false or  (not HasIndicesEANormalSteps(a)) or
        IndicesEANormalSteps(a)=IndicesEANormalSteps(pcgs)) and
        ForAll([1..Length(r)-1],x->
        ExponentsOfPcElement(a,a[x]^r[x])
        =ExponentsOfPcElement(pcgs,pcgs[x]^r[x])) and
        ForAll([1..Length(r)],x->ForAll([x+1..Length(r)],y->
          ExponentsOfPcElement(a,a[y]^a[x])
          =ExponentsOfPcElement(pcgs,pcgs[y]^pcgs[x]))) then

        # indeed the group is OK
        if not HasIndicesEANormalSteps(a) then
          SetIndicesEANormalSteps(a,IndicesEANormalSteps(pcgs));
        fi;
        A:=GroupOfPcgs(a);
        return A;
      fi;
    fi;
    i:=i+2;
  od;
  od; # end of atomic
  A := PermpcgsPcGroupPcgs( pcgs, IndicesEANormalSteps(pcgs), flag );
  return A;
end);



#############################################################################
##
#M  IsomorphismPcGroup( <G> ) . . . . . . . . . . . .  perm group as pc group
##
InstallMethod( IsomorphismPcGroup, true, [ IsPermGroup ], 0,
    function( G )
    local   iso,  A,  pcgs;

    # Make  a pcgs   based on  an  elementary   abelian series (good  for  ag
    # routines).
    pcgs:=PcgsElementaryAbelianSeries(G);
    if not IsPcgs( pcgs )  then
        return fail;
    fi;

    # Construct the pcp group <A> and the bijection between <A> and <G>.
    A:=CreateIsomorphicPcGroup(pcgs,false,false);

    iso := GroupHomomorphismByImagesNC( G, A, pcgs, GeneratorsOfGroup( A ) );
    SetIsBijective( iso, true );

    return iso;
end );

#############################################################################
##
#M  ModuloPcgs( <G>, <N> )
##
InstallMethod( ModuloPcgs, "for permutation groups", IsIdenticalObj,
        [ IsPermGroup, IsPermGroup ], 0,
function( G, N )
local   pcgs;

  # Make  a pcgs   based on  an  elementary   abelian series (good  for  ag
  # routines).
  pcgs := TryPcgsPermGroup( [ G, N ], false, false, true );

  if not IsModuloPcgs( pcgs )  then
      return fail;
  fi;

  # set nomerator and denominator appropriately
  SetNumeratorOfModuloPcgs(pcgs,GeneratorsOfGroup(G));
  SetDenominatorOfModuloPcgs(pcgs,GeneratorsOfGroup(N));

  return pcgs;
end);

#############################################################################
##
#M  PcgsElementaryAbelianSeries( <G> )
##
InstallMethod( PcgsElementaryAbelianSeries, "perm group", true,
  [ IsPermGroup ], 0,
function(G)
local pcgs;
  if HasPcgs(G) and IsPcgsElementaryAbelianSeries(Pcgs(G)) then
    return Pcgs(G);
  fi;
  pcgs:=TryPcgsPermGroup( G, false, false, true );
  if IsPcgs(pcgs) and not HasPcgs(G) then
       SetPcgs(G,pcgs);
  fi;
  return pcgs;
end);


#############################################################################
##
#M  MaximalSubgroupClassReps( <G> )
##
##  method for solvable perm groups -- it is cheaper to translate to a pc
##  group
InstallMethod( CalcMaximalSubgroupClassReps,"solvable perm group",true,
    [ IsPermGroup and CanEasilyComputePcgs and IsFinite ], 0,
function(G)
local hom,m;
  hom:=IsomorphismPcGroup(G);
  m:=MaximalSubgroupClassReps(Image(hom));
  List(m,Size); # force
  return List(m,i->PreImage(hom,i));
end);
