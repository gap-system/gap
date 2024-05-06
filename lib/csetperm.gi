#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke, Heiko Theißen.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the operations for cosets of permutation groups
##

#############################################################################
##
#F  MinimizeExplicitTransversal( <U>, <maxmoved> )  . . . . . . . . . . local
##
InstallGlobalFunction( MinimizeExplicitTransversal, function( U, maxmoved )
    local   explicit,  lenflock,  flock,  lenblock,  index,  s;

    if     IsBound( U.explicit )
       and IsBound( U.stabilizer )  then
        explicit := U.explicit;
        lenflock := U.stabilizer.index * U.lenblock / Length( U.orbit );
        flock    := U.flock;
        lenblock := U.lenblock;
        index    := U.index;
        ChangeStabChain( U, [ 1 .. maxmoved ] );
        for s  in [ 1 .. Length( explicit ) ]  do
            explicit[ s ] := MinimalElementCosetStabChain( U, explicit[ s ] );
        od;
        Sort( explicit );
        U.explicit := explicit;
        U.lenflock := lenflock;
        U.flock    := flock;
        U.lenblock := lenblock;
        U.index    := index;
    fi;
end );

#############################################################################
##
#F  RightTransversalPermGroupConstructor( <filter>, <G>, <U> )  . constructor
##
MAX_SIZE_TRANSVERSAL := 100000;

# so far only orbits and perm groups -- TODO: Other deduced actions
InstallGlobalFunction(ActionRefinedSeries,function(G,U)
local o,A,ser,act,i;
  o:=List(Orbits(U,MovedPoints(G)),Set);
  SortBy(o,Length);
  A:=G;
  ser:=[A];
  act:=[0]; # dummy entry
  i:=1;
  while i<=Length(o) and Size(A)>Size(U) do
    A:=Stabilizer(A,o[i],OnSets);
    if Size(A)<Size(ser[Length(ser)]) then
      Add(ser,A);
      Add(act,[o[i],OnSets]);
    fi;
    i:=i+1;
  od;
  if Size(A)>Size(U) then
    Add(ser,U);
    Add(act,fail);
  fi;
  # refine large step?
  for i in [1..Length(ser)-1] do
    if IndexNC(ser[i],ser[i+1])>MAX_SIZE_TRANSVERSAL then
      A:=IntermediateGroup(ser[i],ser[i+1]:cheap);
      if A<>fail then
        # refine with action
        o:=ActionRefinedSeries(ser[i],A);
        ser:=Concatenation(ser{[1..i]},o[1]{[1..Length(o[1])-1]},
          ser{[i+1..Length(ser)]});
        act:=Concatenation(act{[1..i]},o[2]{[1..Length(o[2])-1]},
          act{[i+1..Length(act)]});
      else
        # no refinement, next step
        i:=i+1;
      fi;
    else
      # no refinement needed, next step
      i:=i+1;
    fi;
  od;
  # make ascending like AscendingSeries
  return [Reversed(ser),Reversed(act)];
end);

BindGlobal( "RightTransversalPermGroupConstructor", function( filter, G, U )
  local GC, UC, noyet, orbs, domain, GCC, UCC, ac, nc, bpt, enum, i,
    actions,nct;

    GC := CopyStabChain( StabChainImmutable( G ) );
    UC := CopyStabChain( StabChainImmutable( U ) );
    noyet:=ValueOption("noascendingchain")<>true;
    if not IsTrivial( G )  then
        orbs := ShallowCopy( OrbitsDomain( U, MovedPoints( G ) ) );
        Sort( orbs, function( o1, o2 )
            return Length( o1 ) < Length( o2 ); end );
        domain := Concatenation( orbs );
        GCC:=GC;
        UCC:=UC;
        while    Length( GCC.genlabels ) <> 0
              or Length( UCC.genlabels ) <> 0  do
#Print(SizeStabChain(GCC),"/",SizeStabChain(UCC),":",
#  SizeStabChain(GCC)/SizeStabChain(UCC),"\n");
          if noyet and (
          (SizeStabChain(GCC)/SizeStabChain(UCC) >MAX_SIZE_TRANSVERSAL) or
          (Length(UCC.genlabels)=0 and
            SizeStabChain(GCC)>MAX_SIZE_TRANSVERSAL)
            ) then

            # first get a factorization through actions
            ac:=ActionRefinedSeries(G,U);
            actions:=ac[2];
            ac:=ac[1];

            # go in biggish steps through the chain
            nc:=[ac[1]];
            nct:=[actions[1]];
            for i in [3..Length(ac)] do
              if Size(ac[i])/Size(nc[Length(nc)])>MAX_SIZE_TRANSVERSAL then
                Add(nc,ac[i-1]);
                Add(nct,actions[i-1]);
              fi;
            od;
            Add(nc,ac[Length(ac)]);
            Add(nct,actions[Length(actions)]);
            if Length(nc)>2 then
              ac:=[];
              for i in [Length(nc),Length(nc)-1..2] do
                Info(InfoCoset,4,"Recursive [",Size(nc[i]),",",Size(nc[i-1]));
                Add(ac,RightTransversal(nc[i],nc[i-1]
                      # do not try to factor again
                      :noascendingchain));
              od;
              return FactoredTransversal(G,U,ac);
            fi;
            noyet:=false;

          fi;
          bpt := First( domain, p -> not IsFixedStabilizer( GCC, p ) );
          ChangeStabChain( GCC, [ bpt ], true  );  GCC := GCC.stabilizer;
          ChangeStabChain( UCC, [ bpt ], false );  UCC := UCC.stabilizer;
        od;
    fi;

    AddCosetInfoStabChain(GC,UC,LargestMovedPoint(G));
    MinimizeExplicitTransversal(UC,LargestMovedPoint(G));

    enum := Objectify( NewType( FamilyObj( G ),
                           filter and IsList and IsDuplicateFreeList
                           and IsAttributeStoringRep ),
          rec( group := G,
            subgroup := U,
      stabChainGroup := GC,
   stabChainSubgroup := UC ) );

    return enum;
end );


#############################################################################
##
#R  IsRightTransversalPermGroupRep( <obj> ) . right transversal of perm group
##
DeclareRepresentation( "IsRightTransversalPermGroupRep",
    IsRightTransversalRep,
    [ "stabChainGroup", "stabChainSubgroup" ] );

InstallMethod( \[\],
    "for right transversal of perm. group, and pos. integer",
    true,
    [ IsList and IsRightTransversalPermGroupRep, IsPosInt ], 0,
    function( cs, num )
    return CosetNumber( cs!.stabChainGroup, cs!.stabChainSubgroup, num );
end );

InstallMethod( PositionCanonical,
    "for right transversal of perm. group, and permutation",
    IsCollsElms,
    [ IsList and IsRightTransversalPermGroupRep, IsPerm ], 0,
    function( cs, elm )
    return NumberCoset( cs!.stabChainGroup,
                        cs!.stabChainSubgroup,
                        elm );
end );

#############################################################################
##
#M  RightTransversalOp( <G>, <U> )  . . . . . . . . . . . . . for perm groups
##
InstallMethod( RightTransversalOp,
    "for two perm. groups",
    IsIdenticalObj,
    [ IsPermGroup, IsPermGroup ], 0,
    function( G, U )
    return RightTransversalPermGroupConstructor(
               IsRightTransversalPermGroupRep, G, U );
end );


#############################################################################
##
#F  AddCosetInfoStabChain( <G>, <U>, <maxmoved> ) . . . . . .  add coset info
##

InstallGlobalFunction( AddCosetInfoStabChain, function( G, U, maxmoved )
    local   orb,  pimg,  img,  vert,  s,  t,  index,
            block,  B,  blist,  pos,  sliced,  lenflock,  i,  j,
            ss,  tt,t1,t1lim,found,tl,vimg,
            sel,shortsel,gorpo,pisel,prepi,transinv;

    # iterated image
    vimg:=function(point,list)
    local i;
      for i in list do
        point:=point^i;
      od;
      return point;
    end;

    Info(InfoCoset,5,"AddCosetInfoStabChain [",
          SizeStabChain(G),",",SizeStabChain(U),"]");
    if IsEmpty( G.genlabels )  then
        U.index    := 1;
        U.explicit := [ U.identity ];
        U.lenflock := 1;
        U.flock    := U.explicit;
    else
        AddCosetInfoStabChain( G.stabilizer, U.stabilizer, maxmoved );

        # U.index := [G_1:U_1];
        U.index := U.stabilizer.index * Length( G.orbit ) / Length( U.orbit );
        Info(InfoCoset,5,"U.index=",U.index);

        # block := 1 ^ <U,G_1>; is a block for G.
        block := OrbitPerms( Concatenation( U.generators,
                 G.stabilizer.generators ), G.orbit[ 1 ] );
        U.lenblock := Length( block );
        lenflock := Length( G.orbit ) / U.lenblock;

        # For small indices,  permutations   are multiplied,  so  we  need  a
        # multiplied transversal.
        if     IsBound( U.stabilizer.explicit )
           and U.lenblock * maxmoved <= MAX_SIZE_TRANSVERSAL
           and U.index    * maxmoved <= MAX_SIZE_TRANSVERSAL * lenflock  then
            U.explicit := [  ];
            U.flock    := [ G.identity ];
            tt := [  ];  tt[ G.orbit[ 1 ] ] := G.identity;
            for t  in G.orbit  do
                tt[ t ] := tt[ t ^ G.transversal[ t ] ] /
                           G.transversal[ t ];
            od;
        fi;

        # flock := { G.transversal[ B[1] ] | B in block system };
        blist := BlistList( G.orbit, block );
        pos := Position( blist, false );
        while pos <> fail  do
            img := G.orbit[ pos ];
            B := block{ [ 1 .. U.lenblock ] };
            sliced := [  ];
            while img <> G.orbit[ 1 ]  do
                Add( sliced, G.transversal[ img ] );
                img := img ^ G.transversal[ img ];
            od;
            for i  in Reversed( [ 1 .. Length( sliced ) ] )  do
                for j  in [ 1 .. Length( B ) ]  do
                    B[ j ] := B[ j ] / sliced[ i ];
                od;
            od;
            Append( block, B );
            if IsBound( U.explicit )  then
                Add( U.flock, tt[ B[ 1 ] ] );
            fi;
            #UniteBlist( blist, BlistList( G.orbit, B ) );
            UniteBlistList(G.orbit, blist, B );
            pos := Position( blist, false, pos );
        od;
        G.orbit := block;

        # Let <s> loop over the transversal elements in the stabilizer.
        U.repsStab := List( [ 1 .. U.lenblock ], x ->
                           BlistList( [ 1 .. U.stabilizer.index ], [  ] ) );
        U.repsStab[ 1 ] := BlistList( [ 1 .. U.stabilizer.index ],
                                      [ 1 .. U.stabilizer.index ] );
        index := U.stabilizer.index * lenflock;
        s := 1;

        # For  large  indices, store only   the  numbers of  the  transversal
        # elements needed.
        if not IsBound( U.explicit )  then

            # If  the   stabilizer   is the   topmost  level   with  explicit
            # transversal, this must contain minimal coset representatives.
            MinimizeExplicitTransversal( U.stabilizer, maxmoved );

            # if there are over 200 points, do a cheap test first.
            t1lim:=Length(G.orbit);
            if t1lim>200 then
              t1lim:=50;
            fi;

            sel:=Filtered([1..Maximum(G.orbit)],x->IsBound(U.translabels[x]));
            shortsel:=Length(sel)<t1lim;

            if shortsel then
              # inverse transversal elements
              t1:=ShallowCopy(G.generators);
              Add(t1,G.identity);
              vert:=List(t1,x->x^-1);
              # inverses of transversal, stored compact
              # TODO: Instead of `Position`, use translabels entry
              #transinv:=List(G.transversal,x->vert[Position(t1,x)]);
              transinv:=[];
              for i in [1..Length(G.transversal)] do
                if IsBound(G.transversal[i]) then
                  t:=Position(t1,G.transversal[i]);
                  if t=fail then
                    Add(t1,G.transversal[i]);
                    Add(vert,G.transversal[i]^-1);
                    t:=Length(t1);
                  fi;
                  transinv[i]:=vert[t];
                fi;
              od;
              # Position in orbit
              gorpo:=[];
              for i in [1..Length(G.orbit)] do
                gorpo[G.orbit[i]]:=i;
              od;
            fi;

            orb := G.orbit{ [ 1 .. U.lenblock ] };
            pimg := [  ];
            while index < U.index  do

                pimg{ orb } := CosetNumber( G.stabilizer, U.stabilizer, s,
                                       orb );
                t := 2;

                if shortsel then

                  # test for the few wrong values, mapping backwards

                  pisel:=Filtered([1..Length(pimg)],
                    x->IsBound(pimg[x]) and pimg[x] in sel);

                  while t <= U.lenblock  and  index < U.index  do

                    # For this point  in the  block,  find the images  of the
                    # earlier points under the representative.
                    vert := G.orbit{ [ 1 .. t-1 ] };
                    img := G.orbit[ t ];
                    tl:=[];
                    while img <> G.orbit[ 1 ]  do
                      Add(tl,transinv[img]);
                      img  := img           ^ G.transversal[ img ];
                    od;
                    prepi:=pisel;
                    for t1 in [Length(tl),Length(tl)-1..1] do
                      prepi:=OnTuples(prepi,tl[t1]);
                    od;

                    # If $Ust = Us't'$ then $1t'/t/s in 1U$. Also if $1t'/t/s
                    # in 1U$ then $st/t' =  u.g_1$ with $u  in U, g_1 in G_1$
                    # and $g_1  =  u_1.s'$ with $u_1  in U_1,  s' in S_1$, so
                    # $Ust = Us't'$.
                    #if ForAll( [ 1 .. t-1 ], i -> not
                    #     vert[ i ] in prepi  )  then
                    if not ForAny(gorpo{prepi},x->x>=1 and x<=t-1) then
                      U.repsStab[ t ][ s ] := true;
                      index := index + lenflock;

                    fi;

                    t := t + 1;
                  od;

                else

                  while t <= U.lenblock  and  index < U.index  do

                    # do not test all points first if not necessary
                    # (test only at most t1lim points, if the test succeeds,
                    # test the rest)
                    # this gives a major speedup.
                    t1:=Minimum(t-1,t1lim);
                    # For this point  in the  block,  find the images  of the
                    # earlier points under the representative.
                    vert := G.orbit{ [ 1 .. t1 ] };
                    img := G.orbit[ t ];
                    while img <> G.orbit[ 1 ]  do
                      vert := OnTuples( vert, G.transversal[ img ] );
                      img  := img           ^ G.transversal[ img ];
                    od;

                    # If $Ust = Us't'$ then $1t'/t/s in 1U$. Also if $1t'/t/s
                    # in 1U$ then $st/t' =  u.g_1$ with $u  in U, g_1 in G_1$
                    # and $g_1  =  u_1.s'$ with $u_1  in U_1,  s' in S_1$, so
                    # $Ust = Us't'$.
                    if ForAll( [ 1 .. t1 ], i -> not IsBound
                        ( U.translabels[ pimg[ vert[ i ] ] ] ) )  then

                      # do all points
                      if t1<t-1 then
                        img := G.orbit[ t ];
                        if t<=10*t1lim then
                          vert := G.orbit{ [ 1 .. t - 1 ] };
                          while img <> G.orbit[ 1 ]  do
                            vert := OnTuples( vert, G.transversal[ img ] );
                            img  := img           ^ G.transversal[ img ];
                          od;
                          found:=ForAll( [ t1+1 .. t - 1 ], i -> not IsBound
                            ( U.translabels[ pimg[ vert[ i ] ] ] ) );
                        else
                          # avoid calculating tons of images of a long list
                          # instead calculate images on the fly
                          # this implicitly assumes that, if we get to so
                          # long a list, failure will happen quickly.
                          tl:=[];
                          while img <> G.orbit[ 1 ]  do
                            Add(tl,G.transversal[img]);
                            img  := img           ^ G.transversal[ img ];
                          od;
                          found:=ForAll( [ t1+1 .. t - 1 ], i -> not IsBound
                            ( U.translabels[ pimg[ vimg(G.orbit[ i ],tl) ] ] ) );
                        fi;

                        if found then
                          U.repsStab[ t ][ s ] := true;
                          index := index + lenflock;
                        fi;

                      else
                        U.repsStab[ t ][ s ] := true;
                        index := index + lenflock;
                      fi;
                    fi;

                    t := t + 1;
                  od;
                fi;

                s := s + 1;
            od;

        # For small indices, store a transversal explicitly.
        else
            for ss  in U.stabilizer.flock  do
                Append( U.explicit, U.stabilizer.explicit * ss );
            od;
            while index < U.index  do
                t := 2;
                while t <= U.lenblock  and  index < U.index  do
                    ss := U.explicit[ s ] * tt[ G.orbit[ t ] ];
                    if ForAll( [ 1 .. t - 1 ], i -> not IsBound
                           ( U.translabels[ G.orbit[ i ] / ss ] ) )  then
                        U.repsStab[ t ][ s ] := true;
                        Add( U.explicit, ss );
                        index := index + lenflock;
                    fi;
                    t := t + 1;
                od;
                s := s + 1;
            od;
            Unbind( U.stabilizer.explicit );
            Unbind( U.stabilizer.flock    );
        fi;

    fi;
end );

#############################################################################
##
#F  NumberCoset( <G>, <U>, <r> )  . . . . . . . . . . . . . . coset to number
##
InstallGlobalFunction( NumberCoset, function( G, U, r )
    local   num,  b,  t,  u,  g1,  pnt,  bpt;

    if IsEmpty( G.genlabels )  or  U.index = 1  then
        return 1;
    fi;

    # Find the block number of $r$.
    bpt := G.orbit[ 1 ];
    b := QuoInt( Position( G.orbit, bpt ^ r ) - 1, U.lenblock );

    # For small indices, look at the explicit transversal.
    if IsBound( U.explicit )  then
        return b * U.lenflock + Position( U.explicit,
               MinimalElementCosetStabChain( U, r / U.flock[ b + 1 ] ) );
    fi;

    pnt := G.orbit[ b * U.lenblock + 1 ];
    while pnt <> bpt  do
        r   := r   * G.transversal[ pnt ];
        pnt := pnt ^ G.transversal[ pnt ];
    od;

    # Now $r$ stabilises the block. Find the first $t in G/G_1$ such that $Ur
    # = Ust$ for $s in G_1$. In this code, G.orbit[ <t> ] = bpt ^ $t$.
    num := b * U.stabilizer.index * U.lenblock / Length( U.orbit );
             # \_________This is [<U,G_1>:U] = U.lenflock_________/
    t := 1;
    pnt := G.orbit[ t ] / r;
    while not IsBound( U.translabels[ pnt ] )  do
        num := num + SizeBlist( U.repsStab[ t ] );
        t := t + 1;
        pnt := G.orbit[ t ] / r;
    od;

    # $r/t = u.g_1$ with $u in U, g_1 in G_1$, hence $t/r.u = g_1^-1$.
    u := U.identity;
    while pnt ^ u <> bpt  do
        u := u * U.transversal[ pnt ^ u ];
    od;
    g1 := LeftQuotient( u, r );  # Now <g1> = $g_1.t = u mod r$.
    while bpt ^ g1 <> bpt  do
        g1 := g1 * G.transversal[ bpt ^ g1 ];
    od;

    # The number of $r$  is the number of $g_1$  plus an offset <num> for
    # the earlier values of $t$.
    return num + SizeBlist( U.repsStab[ t ]{ [ 1 ..
                   NumberCoset( G.stabilizer, U.stabilizer, g1 ) ] } );

end );

#############################################################################
##
#F  CosetNumber( <arg> )  . . . . . . . . . . . . . . . . . . number to coset
##
InstallGlobalFunction( CosetNumber, function( arg )
    local   G,  U,  num,  tup,  b,  t,  rep,  pnt,  bpt,  index,  len;

    # Get the arguments.
    G := arg[ 1 ];  U := arg[ 2 ];  num := arg[ 3 ];
    if Length( arg ) > 3  then  tup := arg[ 4 ];
                          else  tup := false;     fi;

    if num = 1  then
        if tup = false  then  return G.identity;
                        else  return tup;         fi;
    fi;

    # Find the block $b$ addressed by <num>.
    if IsBound( U.explicit )  then
        index := U.lenflock;
    else
        index := U.stabilizer.index * U.lenblock / Length( U.orbit );
               # \_________This is [<U,G_1>:U] = U.lenflock_________/
    fi;
    b := QuoInt( num - 1, index );
    num := ( num - 1 ) mod index + 1;

    # For small indices, look at the explicit transversal.
    if IsBound( U.explicit )  then
        if tup = false  then
            return U.explicit[ num ] * U.flock[ b + 1 ];
        else
            return List( tup, t -> t / U.flock[ b + 1 ] / U.explicit[ num ] );
        fi;
    fi;

    # Otherwise, find the point $t$ addressed by <num>.
    t := 1;
    len := SizeBlist( U.repsStab[ t ] );
    while num > len  do
        num := num - len;
        t := t + 1;
        len := SizeBlist( U.repsStab[ t ] );
    od;
    if len < U.stabilizer.index  then
        num := PositionNthTrueBlist( U.repsStab[ t ], num );
    fi;

    # Find the representative $s$ in   the stabilizer addressed by <num>  and
    # return $st$.
    rep := G.identity;
    bpt := G.orbit[ 1 ];
    if tup = false  then
        pnt := G.orbit[ b * U.lenblock + 1 ];
        while pnt <> bpt  do
            rep := rep * G.transversal[ pnt ];
            pnt := pnt ^ G.transversal[ pnt ];
        od;
        pnt := G.orbit[ t ];
        while pnt <> bpt  do
            rep := rep * G.transversal[ pnt ];
            pnt := pnt ^ G.transversal[ pnt ];
        od;
        return CosetNumber( G.stabilizer, U.stabilizer, num ) / rep;
    else
        pnt := G.orbit[ b * U.lenblock + 1 ];
        while pnt <> bpt  do
            tup := OnTuples( tup, G.transversal[ pnt ] );
            pnt := pnt ^ G.transversal[ pnt ];
        od;
        pnt := G.orbit[ t ];
        while pnt <> bpt  do
            tup := OnTuples( tup, G.transversal[ pnt ] );
            pnt := pnt ^ G.transversal[ pnt ];
        od;
        return CosetNumber( G.stabilizer, U.stabilizer, num, tup );
    fi;
end );

#############################################################################
##
#M  AscendingChainOp(<G>,<pnt>) . . . approximation of
##
InstallMethod( AscendingChainOp, "PermGroup", IsIdenticalObj,
  [IsPermGroup,IsPermGroup],0,
function(G,U)
local s,c,mp,o,i,step,a;
  s:=G;
  c:=[G];
  repeat
    mp:=MovedPoints(s);
    o:=ShallowCopy(OrbitsDomain(s,mp));
    SortBy(o,Length);
    i:=1;
    step:=false;
    while i<=Length(o) and step=false do
      if not IsTransitive(U,o[i]) then
        Info(InfoCoset,2,"AC: orbit");
        o:=ShallowCopy(OrbitsDomain(U,o[i]));
        SortBy(o,Length);
        # union of same length -- smaller index
        a:=Union(Filtered(o,x->Length(x)=Length(o[1])));
        if Length(a)=Sum(o,Length) then
          a:=Set(o[1]);
        fi;
        s:=Stabilizer(s,a,OnSets);
        step:=true;
      elif Index(G,U)>NrMovedPoints(U)
          and IsPrimitive(s,o[i]) and not IsPrimitive(U,o[i]) then
        Info(InfoCoset,2,"AC: blocks");
        s:=Stabilizer(s,Set(MaximalBlocks(U,o[i]),Set),
                      OnSetsDisjointSets);
        step:=true;
      else
        i:=i+1;
      fi;
    od;
    if step then
      Add(c,s);
    fi;
  until step=false or Index(s,U)=1; # we could not refine better
  if Index(s,U)>1 then
    Add(c,U);
  fi;
  Info(InfoCoset,2,"Indices",List([1..Length(c)-1],i->Index(c[i],c[i+1])));
  return RefinedChain(G,Reversed(c));
end);

InstallMethod(CanonicalRightCosetElement,"Perm",IsCollsElms,
  [IsPermGroup,IsPerm],0,
function(U,e)
  return MinimalElementCosetStabChain(MinimalStabChain(U),e);
end);

InstallMethod(\<,"RightCosets of perm group",IsIdenticalObj,
  [IsRightCoset and IsPermCollection,IsRightCoset and IsPermCollection],0,
function(a,b)
  # for permutation groups the canonical rep is the smallest element of the
  # coset
  if ActingDomain(a)<>ActingDomain(b) then
    return ActingDomain(a)<ActingDomain(b);
  fi;
  return CanonicalRepresentativeOfExternalSet(a)
         <CanonicalRepresentativeOfExternalSet(b);
end);



InstallMethod(Intersection2, "perm cosets", IsIdenticalObj,
  [IsRightCoset and IsPermCollection,IsRightCoset and IsPermCollection],0,
function(cos1,cos2)
    local H1, H2, x1, x2, shift, sigma, listMoved_H1, listMoved_H2,
          listMoved_sigma, U, repr, H1_sigma, H2_sigma, H12, swap, rho, diff;
    # We set cosInt = cos1 \cap cos2 = H1 x1 \cap H2 x2
    H1:=ActingDomain(cos1);
    H2:=ActingDomain(cos2);
    x1:=Representative(cos1);
    x2:=Representative(cos2);
    if H1=H2 then
        if cos1=cos2 then
            return cos1;
        else
            return [];
        fi;
    fi;
    # We are using that
    #    H1*x1 \cap H2*x2 = (H1 \cap H2*x2/x1)*x1 = (H1 \cap H2*sigma)*shift,
    # where shift and sigma are defined as below:
    shift:=x1;
    sigma:=x2 / x1;

    # Reducing as much as possible in advance by using various relatively
    # cheap to compute criteria
    while true do
        listMoved_H1:=MovedPoints(H1);
        listMoved_H2:=MovedPoints(H2);
        listMoved_sigma:=MovedPoints(sigma);

        # If the coset intersection is non-empty, then there is h1 \in H1 and
        # h2 \in H2 such that h1 = h2*sigma. Therefore sigma is contained in
        # the group generated by H1 and H2. A necessary condition for this is
        # that the points moved by sigma are a subset of the points moved by
        # H1 and H2.
        if not IsSubset(Union(listMoved_H1, listMoved_H2), listMoved_sigma) then
            return [];
        fi;

        # Suppose x is an element of H1 \cap H2*sigma. Then for any positive
        # integer n, we know that n^x is contained in n^H1 but also in
        # (n^H2)^\sigma. Thus if the intersection of n^H1 and (n^H2)^\sigma is
        # empty, then the intersection of the cosets is also empty. Clearly
        # the orbit intersection contains n whenever n is fixed by sigma, so
        # we only have to consider this for n moved by sigma.
        if ForAny(listMoved_sigma, n -> IsEmpty(Intersection(Orbit(H1,n), OnTuples(Orbit(H2,n),sigma)))) then
            return [];
        fi;

        # If there are points that are moved by sigma and by H2 but not by H1,
        # then there must be an element in H2 which matches the action of sigma
        # on these points, or else the intersection is empty
        diff:=Difference(Intersection(listMoved_H2, listMoved_sigma), listMoved_H1);
        if Length(diff) > 0 then
            repr:=RepresentativeAction(H2, diff, OnTuples(diff, Inverse(sigma)), OnTuples);
            if repr=fail then
                return [];
            fi;
            # Since repr is in H2, we can replace sigma by repr*sigma
            # without changing the coset H2*sigma. The new sigma then fixes
            # all points in diff, as does H1. Hence replacing H2 by the
            # stabilizer in H2 of diff does not change H1 \cap H2 sigma.
            sigma:=repr * sigma;
            H2:=Stabilizer(H2, diff, OnTuples);
            continue;
        fi;

        # Mirror to the previous check:
        # If there are points that are moved by sigma and by H1 but not by H2,
        # then there must be an element in H1 which matches the action of sigma
        # on these points, or else the intersection is empty
        diff:=Difference(Intersection(listMoved_H1, listMoved_sigma), listMoved_H2);
        if Length(diff) > 0 then
            repr:=RepresentativeAction(H1, diff, OnTuples(diff, sigma), OnTuples);
            if repr=fail then
                return [];
            fi;
            # Again this is similar to the case before, except that we are adjusting
            # H1 now and thus also need to take `shift` into account. The situation
            # is as follows:
            #
            # cosInt = (H1 \cap H2 sigma) shift
            #        = (H1 sigma^{-1} \cap H2) sigma shift
            #        = (Stab_{H1}(diff) repr sigma^{-1} \cap H2) sigma shift
            #        = (Stab_{H1}(diff) \cap H2 sigma repr^{-1} ) repr shift
            H1:=Stabilizer(H1, diff, OnTuples);
            sigma:=sigma / repr;
            shift:=repr * shift;
            continue;
        fi;

        # easy termination criterion: reduction to group intersection
        if sigma in H2 then
            U:=Intersection(H1, H2);
            return RightCoset(U, shift);
        fi;

        # easy termination criterion: reduction to group intersection
        if sigma in H1 then
            # cosInt = (H1 \cap H2 sigma) shift
            #        = (H1 sigma^{-1} \cap H2) sigma shift
            U:=Intersection(H1, H2);
            return RightCoset(U, sigma * shift);
        fi;

        # any element of H1 which moves points not moved by sigma or anything
        # in H2 can not be in the intersection, so we may as well remove them
        # by a stabilizer computation
        diff:=Difference(listMoved_H1, Union(listMoved_H2, listMoved_sigma));
        if Length(diff) > 0 then
            H1:=Stabilizer(H1, diff, OnTuples);
            continue;
        fi;

        # the same but with the roles of H1 and H2 reversed
        diff:=Difference(listMoved_H2, Union(listMoved_H1, listMoved_sigma));
        if Length(diff) > 0 then
            H2:=Stabilizer(H2, diff, OnTuples);
            continue;
        fi;

        # More general but more expensive than previous check
        H1_sigma:=ClosureGroup(H1, sigma);
        if not IsSubgroup(H1_sigma, H2) then
            H2:=Intersection(H1_sigma, H2);
            continue;
        fi;
        H2_sigma:=ClosureGroup(H2, sigma);
        if not IsSubgroup(H2_sigma, H1) then
            H1:=Intersection(H2_sigma, H1);
            continue;
        fi;
        # No more reduction tricks available
        break;
    od;

    # A final termination criterion
    H12:=ClosureGroup(H1, H2);
    if not sigma in H12 then
        return [];
    fi;

    # We are now inspired by the algorithm from
    # Lazlo Babai, Coset Intersection in Moderately Exponential Time
    #
    # We use the algorithm from Page 10 of coset analysis and we reformulate
    # it here in order to avoid errors:
    # --- The naive algorithm for computing H1 \cap H2 sigma is to iterate
    # over elements of H1 and testing if one belongs to H2 sigma. If we find
    # one such z then the result is the coset RightCoset(U, z). If not
    # then it is empty.
    # --- Since the result is independent of the cosets U, what we can
    # do is iterate over the RightCosets(H1, U). The algorithm is the
    # one of Proposition 3.2
    # for r in RightCosets(H1, U) do
    #   if r in H1*sigma then
    #     return RightCoset(U, r * shift)
    #   fi;
    # od;
    # --- (TODO for future work): The question is how to make it faster.
    # One idea is to use an ascending chain between U and H1.
    # Section 3.4 of above paper gives statement related to that but not a
    # useful algorithm. The question deserves further exploration.
    #
    # We select the smallest group for that computation in order to have
    # as few cosets as possible
    if Order(H2) < Order(H1) then
        # cosInt = (H1 \cap H2 sigma) shift
        #        = (H1 sigma^{-1} \cap H2) sigma shift
        swap:=H1;
        H1:=H2;
        H2:=swap;
        shift:=sigma * shift;
        sigma:=Inverse(sigma);
    fi;
    # So now Order(H1) <= Order(H2)
    U:=Intersection(H1, H2);
    for rho in RightTransversal(H1, U) do
        if rho / sigma in H2 then
            return RightCoset(U, rho * shift);
        fi;
    od;
    return [];
end);


#############################################################################
##
#F  FactorCosetAction( <G>, <U>, [<N>] )  operation on the right cosets Ug
##                                        with possibility to indicate kernel
##
BindGlobal("DoFactorCosetActionPerm",function(arg)
local G,u,op,h,N,rt,ac,actions,hom,i,q;
  G:=arg[1];
  u:=arg[2];
  if Length(arg)>2 then
    N:=arg[3];
  else
    N:=false;
  fi;
  if IsList(u) and Length(u)=0 then
    u:=G;
    Error("only trivial operation ?  I Set u:=G;");
  fi;
  if N=false then
    N:=Core(G,u);
  fi;

  ac:=ActionRefinedSeries(G,u);
  actions:=ac[2];
  ac:=ac[1];
  hom:=false;
  for i in [2..Length(ac)] do
    if actions[i-1]<>fail
      # allow 2GB memory use for writing down orbit
      and SIZE_OBJ(actions[i-1][1])*IndexNC(ac[i],ac[i-1])<2*10^9 then

      op:=rec();
      h:=Orbit(ac[i],actions[i-1][1],actions[i-1][2]:permutations:=op);
      if IsBound(op.permutations) then
        rt:=List(op.permutations,PermList);
        q:=Group(rt);
        SetSize(q,IndexNC(G,N));
        h:=GroupHomomorphismByImagesNC(ac[i],Group(rt),
          op.generators,rt);
      else
        h:=ActionHomomorphism(ac[i],h,actions[i-1][2],"surjective");
      fi;
    else
      rt:=RightTransversal(ac[i],ac[i-1]);
      if not IsRightTransversalRep(rt) then
        # the right transversal has no special `PositionCanonical' method.
        rt:=List(rt,i->RightCoset(ac[i-1],i));
      fi;
      h:=ActionHomomorphism(ac[i],rt,OnRight,"surjective");

    fi;
    Unbind(op);
    Unbind(rt);
    if i=2 then
      hom:=h;
    else
      hom:=KuKGenerators(ac[i],h,hom);;
      q:=Group(hom);
      StabChainOptions(q).limit:=Size(ac[i]);
      hom:=GroupHomomorphismByImagesNC(ac[i],q,GeneratorsOfGroup(ac[i]),hom);;
    fi;
  od;

  op:=Image(hom,G);
  SetSize(op,IndexNC(G,N));

  # and note our knowledge
  SetKernelOfMultiplicativeGeneralMapping(hom,N);
  AddNaturalHomomorphismsPool(G,N,hom);
  return hom;
end);

InstallMethod(FactorCosetAction,"by right transversal operation",
  IsIdenticalObj,[IsPermGroup,IsPermGroup],0,
function(G,U)
  return DoFactorCosetActionPerm(G,U);
end);

InstallOtherMethod(FactorCosetAction,
  "by right transversal operation, given kernel",IsFamFamFam,
  [IsPermGroup,IsPermGroup,IsPermGroup],0,
function(G,U,N)
  return DoFactorCosetActionPerm(G,U,N);
end);

