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


#############################################################################
##
#M  Orbit( <G>, <pnt>, <gens>, <acts>, <OnPoints> ) . . . . . . . on integers
##
InstallOtherMethod( OrbitOp,
        "G, int, gens, perms, act = `OnPoints'", true,
        [ IsPermGroup, IsInt,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, acts, act )
    if gens <> acts  or  act <> OnPoints  then
        TryNextMethod();
    fi;
    if HasStabChainMutable( G )
       and IsInBasicOrbit( StabChainMutable( G ), pnt ) then
        return Immutable(StabChainMutable( G ).orbit);
    else
        return Immutable( OrbitPerms( acts, pnt ) );
    fi;
end );

#############################################################################
##
#M  OrbitStabilizer( <G>, <pnt>, <gens>, <acts>, <OnPoints> ) . . on integers
##
InstallOtherMethod( OrbitStabilizerOp, "permgroup", true,
        [ IsPermGroup, IsInt,
          IsList,
          IsList,
          IsFunction ], 0,
    function( G, pnt, gens, acts, act )
    local   S;

    if gens <> acts  or  act <> OnPoints  then
        TryNextMethod();
    fi;
    S := StabChainOp( G, [ pnt ] );
    if BasePoint( S ) = pnt  then
        return Immutable( rec( orbit := S.orbit,
                          stabilizer := GroupStabChain
                                        ( G, S.stabilizer, true ) ) );
    else
        return Immutable( rec( orbit := [ pnt ],
                          stabilizer := G ) );
    fi;
end );


#############################################################################
##
#M  Orbits( <G>, <D>, <gens>, <acts>, <OnPoints> )  . . . . . . . on integers
##
BindGlobal( "ORBS_PERMGP_PTS", function( G, D, gens, acts, act )
  if act <> OnPoints  then
      TryNextMethod();
  fi;
  return Immutable( OrbitsPerms( acts, D ) );
end );

InstallMethod( Orbits, "permgroup on points", true,
    [ IsGroup, IsList and IsCyclotomicCollection, IsList,
      IsList and IsPermCollection, IsFunction ], 0,ORBS_PERMGP_PTS);

InstallMethod( OrbitsDomain, "permgroup on points", true,
    [ IsGroup, IsList and IsCyclotomicCollection, IsList,
      IsList and IsPermCollection, IsFunction ], 0,ORBS_PERMGP_PTS);


#############################################################################
##
#M  Cycle( <g>, <pnt>, <OnPoints> ) . . . . . . . . . . . . . . . on integers
##
InstallOtherMethod( CycleOp,"perm, int, act", true,
  [ IsPerm, IsInt, IsFunction ], 0,
    function( g, pnt, act )
    if act <> OnPoints  then
        TryNextMethod();
    fi;
    return CycleOp( g, pnt );
end );

InstallOtherMethod( CycleOp,"perm, int", true,
  [ IsPerm and IsInternalRep, IsInt ], 0,
    function( g, pnt )
    return Immutable( CYCLE_PERM_INT( g, pnt ) );
end );

#############################################################################
##
#M  CycleLength( <g>, <pnt>, <OnPoints> ) . . . . . . . . . . . . on integers
##
InstallOtherMethod( CycleLengthOp, "perm, int, act", true,
        [ IsPerm, IsInt, IsFunction ], 0,
    function( g, pnt, act )
    if act <> OnPoints  then
        TryNextMethod();
    fi;
    return CycleLengthOp( g, pnt );
end );

InstallOtherMethod( CycleLengthOp, "perm, int", true,
  [ IsPerm and IsInternalRep, IsInt ],0, CYCLE_LENGTH_PERM_INT);

#############################################################################
##
#M  Blocks( <G>, <D>, <gens>, <acts>, <OnPoints> )  . . . . find block system
##
InstallMethod( BlocksOp, "permgroup on integers",
        [ IsGroup, IsList and IsCyclotomicCollection, IsList and IsEmpty,
          IsList,
          IsList and IsPermCollection,
          IsFunction ],
    function( G, D, noseed, gens, acts, act )
    local   one,        # identity of `G'
            blocks,     # block system of <G>, result
            orbit,      # orbit of 1 under <G>
            trans,      # factored inverse transversal for <orbit>
            eql,        # '<i> = <eql>[<k>]' means $\beta(i)  = \beta(k)$,
            next,       # the points that are equivalent are linked
            last,       # last point on the list linked through 'next'
            leq,        # '<i> = <leq>[<k>]' means $\beta(i) <= \beta(k)$
            gen,        # one generator of <G> or 'Stab(<G>,1)'
            rnd,        # random element of <G>
            pnt,        # one point in an orbit
            img,        # the image of <pnt> under <gen>
            cur,        # the current representative of an orbit
            rep,        # the representative of a block in the block system
            block,      # the block, result
            changed,    # number of random Schreier generators
            nrorbs,     # number of orbits of subgroup $H$ of $G_1$
            d1g,        # D[1]^gen
            tr,         # transversal element
            i;          # loop variable

    if act <> OnPoints  then
        TryNextMethod();
    fi;

    # handle trivial group
    if Length( acts ) = 0 and Length(D)>1  then
        Error("<G> must operate transitively on <D>");
    fi;

    # handle trivial domain
    if Length( D ) = 1  or IsPrimeInt( Length( D ) )  then
        return Immutable( [ D ] );
    fi;

    # compute the orbit of $G$ and a factored transversal
    one:= One( G );
    orbit := [ D[1] ];
    trans := [];
    trans[ D[1] ] := one;
    for pnt  in orbit  do
        for gen  in acts  do
            if not IsBound( trans[ pnt / gen ] )  then
                Add( orbit, pnt / gen );
                trans[ pnt / gen ] := gen;
            fi;
        od;
    od;

    # check that the group is transitive
    if Length( orbit ) <> Length( D )  then
        Error("<G> must operate transitively on <D>");
    fi;
    Info( InfoAction, 1, "BlocksNoSeed transversal computed" );
    nrorbs := Length( orbit );

    # since $i \in k^{G_1}$ implies $\beta(i)=\beta(k)$,  we initialize <eql>
    # so that the connected components are orbits of some subgroup  $H < G_1$
    eql := [];
    leq := [];
    next := [];
    last := [];
    for pnt  in orbit  do
        eql[pnt]  := pnt;
        leq[pnt]  := pnt;
        next[pnt] := 0;
        last[pnt] := pnt;
    od;

    # repeat until we have a block system
    changed := 0;
    cur := orbit[2];
    rnd := one;
    repeat

        # compute such an $H$ by taking random  Schreier generators  of $G_1$
        # and stop if 2 successive generators dont change the orbits any more
        while changed < 2  do

            # compute a random Schreier generator of $G_1$
            i := Length( orbit );
            while 1 <= i  do
                rnd := rnd * Random( acts );
                i   := QuoInt( i, 2 );
            od;
            gen := rnd;
            d1g:=D[1]^gen;
            while d1g <> D[1]  do
                tr:=trans[ d1g ];
                gen := gen * tr;
                d1g:=d1g^tr;
            od;
            changed := changed + 1;
            Info( InfoAction, 3, "Changed: ",changed );

            # compute the image of every point under <gen>
            for pnt  in orbit  do
                img := pnt ^ gen;

                # find the representative of the orbit of <pnt>
                while eql[pnt] <> pnt  do
                    pnt := eql[pnt];
                od;

                # find the representative of the orbit of <img>
                while eql[img] <> img  do
                    img := eql[img];
                od;

                # if the don't agree merge their orbits
                if   pnt < img  then
                    eql[img] := pnt;
                    next[ last[pnt] ] := img;
                    last[pnt] := last[img];
                    nrorbs := nrorbs - 1;
                    changed := 0;
                elif img < pnt  then
                    eql[pnt] := img;
                    next[ last[img] ] := pnt;
                    last[img] := last[pnt];
                    nrorbs := nrorbs - 1;
                    changed := 0;
                fi;

            od;

        od;
        Info( InfoAction, 1, "BlocksNoSeed ",
                       "number of orbits of <H> < <G>_1 is ",nrorbs );

        # take arbitrary point <cur>,  and an element <gen> taking 1 to <cur>
        while eql[cur] <> cur  do
            cur := eql[cur];
        od;
        gen := [];
        img := cur;
        while img <> D[1]  do
            Add( gen, trans[img] );
            img := img ^ trans[img];
        od;
        gen := Reversed( gen );

        # compute an alleged block as orbit of 1 under $< H, gen >$
        pnt := cur;
        while pnt <> 0  do

            # compute the representative of the block containing the image
            img := pnt;
            for i  in gen  do
                img := img / i;
            od;
            while eql[img] <> img  do
                img := eql[img];
            od;

            # if it is not our current block but a minimal block
            if   img <> D[1]  and img <> cur  and leq[img] = img  then

                # then try <img> as a new start
                leq[cur] := img;
                cur := img;
                gen := [];
                img := cur;
                while img <> D[1]  do
                    Add( gen, trans[img] );
                    img := img ^ trans[img];
                od;
                gen := Reversed( gen );
                pnt := cur;

            # otherwise if it is not our current block but contains it
            # by construction a nonminimal block contains the current block
            elif img <> D[1]  and img <> cur  and leq[img] <> img  then

                # then merge all blocks it contains with <cur>
                while img <> cur  do
                    eql[img] := cur;
                    next[ last[cur] ] := img;
                    last[ cur ] := last[ img ];
                    img := leq[img];
                    while img <> eql[img]  do
                        img := eql[img];
                    od;
                od;
                pnt := next[pnt];

            # go on to the next point in the orbit
            else

                pnt := next[pnt];

            fi;

        od;

        # make the alleged block
        block := [ D[1] ];
        pnt := cur;
        while pnt <> 0  do
            Add( block, pnt );
            pnt := next[pnt];
        od;
        block := Set( block );
        blocks := [ block ];
        Info( InfoAction, 1, "BlocksNoSeed ",
                       "length of alleged block is ",Length(block) );

        # quick test to see if the group is primitive
        if Length( block ) = Length( orbit )  then
            Info( InfoAction, 1, "BlocksNoSeed <G> is primitive" );
            return Immutable( [ D ] );
        fi;

        # quick test to see if the orbit can be a block
        if Length( orbit ) mod Length( block ) <> 0  then
            Info( InfoAction, 1, "BlocksNoSeed ",
                           "alleged block is clearly not a block" );
            changed := -1000;
        fi;

        # '<rep>[<i>]' is the representative of the block containing <i>
        rep := [];
        for pnt  in orbit  do
            rep[pnt] := 0;
        od;
        for pnt  in block  do
            rep[pnt] := 1;
        od;

        # compute the block system with an orbit algorithm
        i := 1;
        while 0 <= changed  and i <= Length( blocks )  do

            # loop over the generators
            for gen  in acts  do

                # compute the image of the block under the generator
                img := OnSets( blocks[i], gen );

                # if this block is new
                if rep[ img[1] ] = 0  then

                    # add the new block to the list of blocks
                    Add( blocks, img );

                    # check that all points in the image are new
                    for pnt  in img  do
                        if rep[pnt] <> 0  then
                            Info( InfoAction, 1, "BlocksNoSeed ",
                                           "alleged block is not a block" );
                            changed := -1000;
                        fi;
                        rep[pnt] := img[1];
                    od;

                # if this block is old
                else

                    # check that all points in the image lie in the block
                    for pnt  in img  do
                        if rep[pnt] <> rep[img[1]]  then
                           Info( InfoAction, 1, "BlocksNoSeed ",
                                           "alleged block is not a block" );
                            changed := -1000;
                        fi;
                    od;

                fi;

            od;

            # on to the next block in the orbit
            i := i + 1;
        od;

    until 0 <= changed;

    # force sortedness
    if Length(blocks[1])>0 and CanEasilySortElements(blocks[1][1]) then
      blocks:=AsSSortedList(List(blocks,i->Immutable(Set(i))));
      IsSSortedList(blocks);
    fi;
    # return the block system
    return Immutable( blocks );
end );

#############################################################################
##
#M  Blocks( <G>, <D>, <seed>, <gens>, <acts>, <OnPoints> )   blocks with seed
##
InstallMethod( BlocksOp, "integers, with seed", true,
        [ IsGroup, IsList and IsCyclotomicCollection,
          IsList and IsCyclotomicCollection,
          IsList,
          IsList and IsPermCollection,
          IsFunction ], 0,
    function( G, D, seed, gens, acts, act )
    local   blks,       # list of blocks, result
            rep,        # representative of a point
            siz,        # siz[a] of the size of the block with rep <a>
            fst,        # first point still to be merged into another block
            nxt,        # next  point still to be merged into another block
            lst,        # last  point still to be merged into another block
            gen,        # generator of the group <G>
            nrb,        # number of blocks so far
            a, b, c, d; # loop variables for points

    if act <> OnPoints  then
        TryNextMethod();
    fi;

    nrb := Length(D) - Length(seed) + 1;

    # in the beginning each point <d> is in a block by itself
    rep := [];
    siz := [];
    for d  in D  do
        rep[d] := d;
        siz[d] := 1;
    od;

    # except the points in <seed>, which form one block with rep <seed>[1]
    fst := 0;
    nxt := siz;
    lst := 0;
    c   := seed[1];
    for d  in seed  do
        if d <> c  then
            rep[d] := c;
            siz[c] := siz[c] + siz[d];
            if fst = 0  then
                fst      := d;
            else
                nxt[lst] := d;
            fi;
            lst      := d;
            nxt[lst] := 0;
        fi;
    od;

    # while there are points still to be merged into another block
    while fst <> 0  do

        # get this point <a> and its repesentative <b>
        a := fst;
        b := rep[fst];

        # for each generator <gen> merge the blocks of <a>^<gen>, <b>^<gen>
        for gen  in acts  do
            c := a^gen;
            while rep[c] <> c  do
                c := rep[c];
            od;
            d := b^gen;
            while rep[d] <> d  do
                d := rep[d];
            od;
            if c <> d  then
                if Length(D) < 2*(siz[c] + siz[d])  then
                    return Immutable( [ D ] );
                fi;
                nrb := nrb - 1;
                if siz[d] <= siz[c]  then
                    rep[d]   := c;
                    siz[c]   := siz[c] + siz[d];
                    nxt[lst] := d;
                    lst      := d;
                    nxt[lst] := 0;
                else
                    rep[c]   := d;
                    siz[d]   := siz[d] + siz[c];
                    nxt[lst] := c;
                    lst      := c;
                    nxt[lst] := 0;
                fi;
            fi;
        od;

        # on to the next point still to be merged into another block
        fst := nxt[fst];
    od;

    # turn the list of representatives <rep> into a list of blocks <blks>
    blks := [];
    for d  in D  do
        c := d;
        while rep[c] <> c  do
           c := rep[c];
        od;
        if IsInt( nxt[c] )  then
            nxt[c] := [ d ];
            Add( blks, nxt[c] );
        else
            AddSet( nxt[c], d );
        fi;
    od;

    # return the set of blocks <blks>
    # force sortedness
    if Length(blks[1])>0 and CanEasilySortElements(blks[1][1]) then
      blks:=AsSSortedList(List(blks,i->Immutable(Set(i))));
      IsSSortedList(blks);
    fi;
    return Immutable( Set( blks ) );
end );

#############################################################################
##
#M  RepresentativesMinimalBlocks( <G>, <D>, <gens>, <acts>, <OnPoints> )
## Adaptation of the code for BlocksNoSeed to return _all_ minimal blocks
## containing D[1].
## By Graham Sharp (Oxford), August 1997
##
InstallOtherMethod( RepresentativesMinimalBlocksOp,
        "permgrp on points", true,
        [ IsGroup, IsList and IsCyclotomicCollection,
          IsList,
          IsList and IsPermCollection,
          IsFunction ], 0,
function( G, D, gens, acts, act )
local   blocks,   # block system of <G>, result
      orbit,    # orbit of 1 under <G>
      trans,    # factored inverse transversal for <orbit>
      eql,    # '<i> = <eql>[<k>]' means $\beta(i)  = \beta(k)$,
      next,     # the points that are equivalent are linked
      last,     # last point on the list linked through 'next'
      leq,    # '<i> = <leq>[<k>]' means $\beta(i) <= \beta(k)$
      gen,    # one generator of <G> or 'Stab(<G>,1)'
      rnd,    # random element of <G>
      pnt,    # one point in an orbit
      img,    # the image of <pnt> under <gen>
      cur,    # the current representative of an orbit
      rep,    # the representative of a block in the block system
      block,    # the block, result
      changed,  # number of random Schreier generators
      nrorbs,   # number of orbits of subgroup $H$ of $G_1$
      i,      # loop variable
      minblocks,  # set of minimal blocks, result
      poss,     # flag to indicate whether we might have a block
      iter,     # which points we've checked when
      start;    # index of first cur for this iteration (non-dec)

  if act<>OnPoints then
    TryNextMethod();
  fi;

  # handle trivial domain
  if Length( D ) = 1  or IsPrime( Length( D ) )  then
    return Immutable([ D ]);
  fi;

  # handle trivial group
  if Length( acts )=0  then
    Error( "<G> must act transitively on <D>" );
  fi;

  # compute the orbit of $G$ and a factored transversal
  orbit := [ D[1] ];
  trans := [];
  trans[ D[1] ] := One( acts[1] );  # note that `acts' is nonempty
  for pnt  in orbit  do
    for gen  in acts  do
      if not IsBound( trans[ pnt / gen ] )  then
        Add( orbit, pnt / gen );
        trans[ pnt / gen ] := gen;
      fi;
    od;
  od;

  # check that the group is transitive
  if Length( orbit ) <> Length( D )  then
    Error( "<G> must act transitively on <D>" );
  fi;
  Info(InfoAction,1,"RepresentativesMinimalBlocks transversal computed");
  nrorbs := Length( orbit );

  # since $i \in k^{G_1}$ implies $\beta(i)=\beta(k)$,  we initialize <eql>
  # so that the connected components are orbits of some subgroup  $H < G_1$
  eql := [];
  leq := [];
  next := [];
  last := [];
  iter := [];
  for pnt  in orbit  do
    eql[pnt]  := pnt;
    leq[pnt]  := pnt;
    next[pnt] := 0;
    last[pnt] := pnt;
    iter[pnt] := 0;
  od;

  # repeat until we run out of points
  minblocks := [];
  changed := 0;
  rnd := One( acts[1] );

  for start in orbit{[2..Length(D)]} do

    # repeat until we have a block system
    cur := start;
    # unless this is a new point, ignore and go on to the next
    # -we could do this by a linked list to avoid these checks but the
    #  O(n) overheads involved in setting it up are greater than those saved
    if iter[cur] = 0 then

    repeat

      # compute such an $H$ by taking random Schreier generators of $G_1$
      # and stop if 2 successive generators dont change the orbits any
      # more
      while changed < 2  do

        # compute a random Schreier generator of $G_1$
        i := Length( orbit );
        while 1 <= i  do
          rnd := rnd * Random( acts );
          i   := QuoInt( i, 2 );
        od;
        gen := rnd;
        while D[1] ^ gen <> D[1]  do
          gen := gen * trans[ D[1] ^ gen ];
        od;
        changed := changed + 1;

        # compute the image of every point under <gen>
        for pnt  in orbit  do
          img := pnt ^ gen;

          # find the representative of the orbit of <pnt>
          while eql[pnt] <> pnt  do
            pnt := eql[pnt];
          od;

          # find the representative of the orbit of <img>
          while eql[img] <> img  do
            img := eql[img];
          od;

          # if the don't agree merge their orbits
          if   pnt < img  then
            eql[img] := pnt;
            next[ last[pnt] ] := img;
            last[pnt] := last[img];
            nrorbs := nrorbs - 1;
            changed := 0;
          elif img < pnt  then
            eql[pnt] := img;
            next[ last[img] ] := pnt;
            last[img] := last[pnt];
            nrorbs := nrorbs - 1;
            changed := 0;
          fi;

        od;

      od;
      Info(InfoAction,1,"RepresentativesMinimalBlocks ",
               "number of orbits of <H> < <G>_1 is ",nrorbs);

      # take arbitrary point <cur>,  and an element <gen> taking 1 to <cur>
      while eql[cur] <> cur  do
        cur := eql[cur];
      od;
      # Mark the points in this new H-orbit as visited
      if iter[cur] <> start then
        img := cur;
        while img <> 0 do
        iter[img] := start;
        img := next[img];
        od;
      fi;
      gen := [];
      img := cur;
      while img <> D[1]  do
        Add( gen, trans[img] );
        img := img ^ trans[img];
      od;
      gen := Reversed( gen );

      # compute an alleged block as orbit of 1 under $< H, gen >$
      pnt := cur;
      poss := true;
      while pnt <> 0  do

        # compute the representative of the block containing the image
        img := pnt;
        for i  in gen  do
          img := img / i;
        od;
        while eql[img] <> img  do
          img := eql[img];
        od;

        # if it is not our current block but a new block
        if   img <> D[1]  and img <> cur and leq[img] = img
            and (iter[img] = 0 or iter[img] = start) then

          # then try <img> as a new start
          leq[cur] := img;
          cur := img;
          if iter[cur] <> start then
            img := cur;
            while img <> 0 do
            iter[img] := start;
            img := next[img];
            od;
          fi;
          gen := [];
          img := cur;
          while img <> D[1]  do
            Add( gen, trans[img] );
            img := img ^ trans[img];
          od;
          gen := Reversed( gen );
          pnt := cur;

        # otherwise if it is not our current block but contains it
        # by construction a nonminimal block contains the current block
        # - not any more it doesn't! Now we also have to check whether
        # the block appeared this time or earlier.
        elif img <> D[1]  and img <> cur
               and leq[img] <> img  and iter[img] = start then

          # then merge all blocks it contains with <cur>
          while img <> cur  do
            eql[img] := cur;
            next[ last[cur] ] := img;
            last[ cur ] := last[ img ];
            img := leq[img];
            while img <> eql[img]  do
              img := eql[img];
            od;
          od;
          pnt := next[pnt];

        # else if the block appeared in a previous iteration
        elif iter[img] <> start and iter[img] <> 0 then

           # then end this iteration as this is not a minimal block
          pnt := 0;
          poss := false;

        # otherwise go on to the next point in the orbit
        else

          pnt := next[pnt];

        fi;

      od;

      # Skip this bit if we know we haven't got a block
      if poss = true then
      # make the alleged block
      block := [ D[1] ];
      pnt := cur;
      while pnt <> 0  do
        Add( block, pnt );
        pnt := next[pnt];
      od;
      block := Set( block );
      blocks := [ block ];
      Info(InfoAction,1,"RepresentativesMinimalBlocks ",
               "length of alleged block is ",Length(block));

      # quick test to see if the group is primitive
      if Length( block ) = Length( orbit )  then
        Info(InfoAction,1,"RepresentativesMinimalBlocks <G> is primitive");
        return Immutable([ D ]);
      fi;

      # quick test to see if the orbit can be a block
      if Length( orbit ) mod Length( block ) <> 0  then
        Info(InfoAction,1,"RepresentativesMinimalBlocks ",
                 "alleged block is clearly not a block");
        changed := -1000;
      fi;

      # '<rep>[<i>]' is the representative of the block containing <i>
      rep := [];
      for pnt  in orbit  do
        rep[pnt] := 0;
      od;
      for pnt  in block  do
        rep[pnt] := 1;
      od;

      # compute the block system with an orbit algorithm
      i := 1;
      while 0 <= changed  and i <= Length( blocks )  do

        # loop over the generators
        for gen  in acts  do

          # compute the image of the block under the generator
          img := OnSets( blocks[i], gen );

          # if this block is new
          if rep[ img[1] ] = 0  then

            # add the new block to the list of blocks
            Add( blocks, img );

            # check that all points in the image are new
            for pnt  in img  do
              if rep[pnt] <> 0  then
                Info(InfoAction,1,
                "RepresentativesMinimalBlocks, alleged block is not a block");
                changed := -1000;
              fi;
              rep[pnt] := img[1];
            od;

          # if this block is old
          else

            # check that all points in the image lie in the block
            for pnt  in img  do
              if rep[pnt] <> rep[img[1]]  then
                Info(InfoAction,1,
                 "RepresentativesMinimalBlocks , alleged block is not a block");
                changed := -1000;
              fi;
            od;

          fi;

        od;

        # on to the next block in the orbit
        i := i + 1;
      od;
      fi;

    until 0 <= changed;
    if poss = true then AddSet(minblocks, block); fi;

    # loop back to get another minimal block
    fi;
  od;

  # return the block system
  return Immutable(minblocks);
end);

InstallOtherMethod( RepresentativesMinimalBlocksOp,
        "G, domain, noseed, gens, perms, act", true,
        [ IsGroup, IsList and IsCyclotomicCollection,IsEmpty,
          IsList,
          IsList and IsPermCollection,
          IsFunction ], 0,
function(G,D,noseed,gens,acts,act)
  return RepresentativesMinimalBlocksOp(G,D,gens,acts,act);
end);

InstallOtherMethod( RepresentativesMinimalBlocksOp,
        "general case: translate", true,
        [ IsGroup, IsList,
          IsList,
          IsList,
          IsFunction ],
          # lower ranked than perm method
          -1,
function( G, D, gens, acts, act )
local hom,r;
  hom:=ActionHomomorphism(G,D,gens,acts,act);
  G:=Image(hom,G);
  r:=RepresentativesMinimalBlocksOp(G,[1..Length(D)],
        GeneratorsOfGroup(G),GeneratorsOfGroup(G),OnPoints);
  return List(r,i->D{i});
end);

#############################################################################
##
#M  Earns( <G>, <D> ) . . . . . . . . . . . . earns of affine primitive group
##
InstallMethod( Earns, "G, ints, gens, perms, act", true,
    [ IsPermGroup, IsList,
      IsList,
      IsList,
      IsFunction ], 0,
    function( G, D, gens, acts, act )
    local   n,  fac,  p,  d,  alpha,  beta,  G1,  G2,  orb,
            Gamma,  M,  C,  f,  P,  Q,  Q0,  R,  R0,  pre,  gen,  g,
            ord,  pa,  a,  x,  y,  z;

    if gens <> acts  or  act <> OnPoints  then
        TryNextMethod();
    fi;

    n := Length( D );
    if not IsPrimePowerInt( n )  then
        return [];
    elif not IsPrimitive( G, D )  then
        TryNextMethod();
    fi;

#    # Try a shortcut for solvable groups (or if a solvable normal subgroup is
#    # found).
#    if DefaultStabChainOptions.tryPcgs  then
#        pcgs := TryPcgsPermGroup( G, false, false, true );
#        if not IsPcgs( pcgs )  then
#            pcgs := pcgs[ 1 ];
#        fi;
#T why do we know, that this will give us the EARNS and not just a smaller
# one? AH
#        if not IsEmpty( pcgs )  then
#            return ElementaryAbelianSeries( pcgs )
#                   [ Length( ElementaryAbelianSeries( pcgs ) ) - 1 ];
#        fi;
#    fi;

    fac := Factors(Integers, n );  p := fac[ 1 ];  d := Length( fac );
    alpha := BasePoint( StabChainMutable( G ) );
    G1 := Stabilizer( G, alpha );

    # If <G> is regular, it must be cyclic of prime order.
    if IsTrivial( G1 )  then
        return [G];
    fi;

    # If <G> is not a Frobenius group ...
    for orb  in OrbitsDomain( G1, D )  do
        beta := orb[ 1 ];
        if beta <> alpha  then
            G2 := Stabilizer( G1, beta );
            if not IsTrivial( G2 )  then
                Gamma := Filtered( D, p -> ForAll( GeneratorsOfGroup( G2 ),
                                 g -> p ^ g = p ) );
                if PrimeDivisors( Length( Gamma ) ) <> [ p ]  then
                    return [];
                fi;
                C := Centralizer( G, G2 );
                f := ActionHomomorphism( C, Gamma,"surjective" );
                P := PCore( ImagesSource( f ), p );
                if not IsTransitive( P, [ 1 .. Length( Gamma ) ] )  then
                    return [];
                fi;
                gens := [  ];
                for gen  in GeneratorsOfGroup( Centre( P ) )  do
                    pre := PreImagesRepresentative( f, gen );
                    ord := Order( pre );  pa := 1;
                    while ord mod p = 0  do
                        ord := ord / p;
                        pa := pa * p;
                    od;
                    pre := pre ^ ( ord * Gcdex( pa, ord ).coeff2 );
                    for g  in GeneratorsOfGroup( C )  do
                        z := Comm( g, pre );
                        if z <> One( C )  then
                            M := SolvableNormalClosurePermGroup( G, [ z ] );
                            if M <> fail  and  Size( M ) = n  then
                                return [M];
                            else
                                return [];
                            fi;
                        fi;
                    od;
                    Add( gens, pre );
                od;
                Q := SylowSubgroup( Centre( G2 ), p );

                # This is unnecessary  if   you trust the   classification of
                # finite simple groups.
                if Size( Q ) > p ^ ( d - 1 )  then
                    return [];
                fi;

                R := ClosureGroup( Q, gens );
                R0 := OmegaOp( R, p, 1 );
                y := First( GeneratorsOfGroup( R0 ),
                            y -> not # y in Q = Centre(G2)_p
                            (     alpha ^ y = alpha
                              and beta  ^ y = beta
                              and ForAll( GeneratorsOfGroup( G2 ),
                                      gen -> gen ^ y = gen ) ) );
                Q0 := OmegaOp( Q, p, 1 );
                for z  in Q0  do
                    M := SolvableNormalClosurePermGroup( G, [ y * z ] );
                    if M <> fail  and  Size( M ) = n  then
                        return [M];
                    fi;
                od;
                return [];
            fi;
        fi;
    od;

    # <G> is a Frobenius group.
    a := GeneratorsOfGroup( Centre( G1 ) )[ 1 ];
    x := First( GeneratorsOfGroup( G ), gen -> alpha ^ gen <> alpha );
    z := Comm( a, a ^ x );
    M := SolvableNormalClosurePermGroup( G, [ z ] );
    return [M];

end );


#############################################################################
##
#M  Transitivity( <G>, <D>, <gens>, <acts>, <act> ) . . . . . . . on integers
##
InstallMethod( Transitivity, "permgroup on numbers", true,
    [ IsPermGroup, IsList and IsCyclotomicCollection,
      IsList,
      IsList,
      IsFunction ], 0,
    function( G, D, gens, acts, act )
    if gens <> acts  or  act <> OnPoints  then
        TryNextMethod();

    elif not IsTransitive( G, D, gens, acts, act )  then
        return 0;
    else
        G := Stabilizer( G, D[ 1 ], act );
        gens := GeneratorsOfGroup( G );
        return Transitivity( G, D{ [ 2 .. Length( D ) ] },
                       gens, gens, act ) + 1;
    fi;
end );


#############################################################################
##
#M  IsTransitive( <G> )
#M  Transitivity( <G> )
##
##  For a group with known order, we use that the number of moved points
##  of a transitive permutation group divides the group order.
##  If this is not the case then this check avoids computing an orbit or of
##  a point stabilizer.
##  Note that the GAP library defines transitivity also on partial orbits.
##  (If this would be changed then also the five argument method that is
##  installed in the call of `OrbitsishOperation' could take advantage of
##  the divisibility criterion.)
##
InstallOtherMethod( IsTransitive,
    "for a permutation group (use shortcuts)",
    [ IsPermGroup ], 1,
    function( G )
    local n, gens;

    n:= NrMovedPoints( G );
    if n = 0 then
      return true;
    elif HasSize( G ) and Size( G ) mod n <> 0 then
      # Avoid computing an orbit if the (known) group order
      # is not divisible by the (known) number of points.
      return false;
    else
      # Avoid the `IsSubset' test that occurs in the generic method,
      # checking the orbit length suffices.
      # (And do not call `Orbit'!)
      gens:= GeneratorsOfGroup( G );
      return n = Length( OrbitOp( G, SmallestMovedPoint( G ), gens, gens,
                                  OnPoints ) );
    fi;
    end );

InstallOtherMethod( Transitivity,
    "for a permutation group with known size",
    [ IsPermGroup and HasSize ],
    function( G )
    local n, t, size;

    n:= NrMovedPoints( G );
    if n = 0 then
      # The trivial group is transitive on the empty set,
      # but has transitivity zero.
      return 0;
    elif IsNaturalSymmetricGroup( G ) then
      return n;
    elif IsNaturalAlternatingGroup( G ) then
      return n - 2;
    fi;
    t:= 0;
    size:= Size( G );
    while IsTransitive( G ) do
      t:= t + 1;
      size:= size / n;
      n:= n-1;
      if size mod n <> 0 then
        break;
      fi;
      G:= Stabilizer( G, SmallestMovedPoint( G ) );
      if NrMovedPoints( G ) <> n then
        if n = 1 then
          # The trivial group is transitive on a singleton set,
          # with transitivity one.
          t:= t + 1;
        fi;
        break;
      fi;
    od;
    return t;
    end );


#############################################################################
##
#M  IsSemiRegular( <G>, <D>, <gens>, <acts>, <act> )  . . . . for perm groups
##
InstallMethod( IsSemiRegular, "permgroup on numbers", true,
    [ IsGroup, IsList and IsCyclotomicCollection,
      IsList,
      IsList and IsPermCollection,
      IsFunction ], 0,
    function( G, D, gens, acts, act )
    local   used,       #
            perm,       #
            orbs,       # orbits of <G> on <D>
            gen,        # one of the generators of <G>
            orb,        # orbit of '<D>[1]'
            pnt,        # one point in the orbit
            new,        # image of <pnt> under <gen>
            img,        # image of '<prm>[<i>][<pnt>]' under <gen>
            p, n,       # loop variables
            i, l;       # loop variables

    if act <> OnPoints  then
        TryNextMethod();
    fi;

    # compute the orbits and check that they all have the same length
    orbs := OrbitsDomain( G, D, gens, acts, OnPoints );
    if Length( Set( orbs, Length ) ) <> 1  then
        return false;
    fi;

    # initialize the permutations that act like the generators
    used := [];
    perm := [];
    for i  in [ 1 .. Length( acts ) ]  do
        used[i] := [];
        perm[i] := [];
        for pnt  in orbs[1]  do
            used[i][pnt] := false;
        od;
        perm[i][ orbs[1][1] ] := orbs[1][1] ^ acts[i];
        used[i][ orbs[1][1] ^ acts[i] ] := true;
    od;

    # initialize the permutation that permutes the orbits
    l := Length( acts ) + 1;
    used[l] := [];
    perm[l] := [];
    for orb  in orbs  do
        for pnt  in orb  do
            used[l][pnt] := false;
        od;
    od;
    for i  in [ 1 .. Length(orbs)-1 ]  do
        perm[l][orbs[i][1]] := orbs[i+1][1];
        used[l][orbs[i+1][1]] := true;
    od;
    perm[l][orbs[Length(orbs)][1]] := orbs[1][1];
    used[l][orbs[1][1]] := true;

    # compute the orbit of the first representative
    orb := [ orbs[1][1] ];
    for pnt  in orb  do
        for gen  in acts  do

            # if the image is new
            new := pnt ^ gen;
            if not new in orb  then

                # add the new element to the orbit
                Add( orb, new );

                # extend the permutations that act like the generators
                for i  in [ 1 .. Length( acts ) ]  do
                    img := perm[i][pnt] ^ gen;
                    if used[i][img]  then
                        return false;
                    else
                        perm[i][new] := img;
                        used[i][img] := true;
                    fi;
                od;

                # extend the permutation that permutates the orbits
                p := pnt;
                n := new;
                for i  in [ 1 .. Length( orbs ) ]  do
                    img := perm[l][p] ^ gen;
                    if used[l][img]  then
                        return false;
                    else
                        perm[l][n] := img;
                        used[l][img] := true;
                    fi;
                    p := perm[l][p];
                    n := img;
                od;

            fi;

        od;
    od;

    # check that the permutations commute with the generators
    for i  in [ 1 .. Length( acts ) ]  do
        for gen  in acts  do
            for pnt  in orb  do
                if perm[i][pnt] ^ gen <> perm[i][pnt ^ gen]  then
                    return false;
                fi;
            od;
        od;
    od;

    # check that the permutation commutes with the generators
    for gen  in acts  do
        for orb  in orbs  do
            for pnt  in orb  do
                if perm[l][pnt] ^ gen <> perm[l][pnt ^ gen]  then
                    return false;
                fi;
            od;
        od;
    od;

    # everything is ok, the representation is semiregular
    return true;

end );

#############################################################################
##
#F  IsRegular(permgp)
##
InstallOtherMethod( IsRegular,"permgroup",true,[IsPermGroup],0,
function(G)
  if IsTransitive(G) and IsSemiRegular(G) then
    SetSize(G,NrMovedPoints(G));
    return true;
  else
    return false;
  fi;
end);

InstallOtherMethod( IsRegular,"permgroup with known size",true,
  [IsPermGroup and HasSize],0,
  G->Size(G)=NrMovedPoints(G) and IsTransitive(G));

# implications with regularity for permgroups.
InstallTrueMethod(IsSemiRegular,IsPermGroup and IsRegular);
InstallTrueMethod(IsTransitive,IsPermGroup and IsRegular);
InstallTrueMethod(IsRegular,IsPermGroup and IsSemiRegular and IsTransitive);

#############################################################################
##
#M  RepresentativeAction( <G>, <d>, <e>, <act> ) . . . . . for perm groups
##
InstallOtherMethod( RepresentativeActionOp, "permgrp",true, [ IsPermGroup,
        IsObject, IsObject, IsFunction ],
  # the objects might be group elements: rank up
  {} -> 2*RankFilter(IsMultiplicativeElementWithInverse),
    function ( G, d, e, act )
    local   rep,                # representative, result
            S,                  # stabilizer of <G>
            rep2,               # representative in <S>
            sel,
            dp,ep,              # point copies
            i,  f;              # loop variables

    # standard action on points, make a basechange and trace the rep
    if act = OnPoints and IsInt( d ) and IsInt( e )  then
        d := [ d ];  e := [ e ];
        S := true;
    elif     ( act = OnPairs or act = OnTuples )
         and IsPositionsList( d ) and IsPositionsList( e )  then
        S := true;
    fi;
    if IsBound( S )  then
        if d = e  then
            rep := One( G );
        elif Length( d ) <> Length( e ) then
            rep:= fail;
        else
            # can we use the current stab chain? (try to avoid rebuilding
            # one if called frequently)
            S:=StabChainMutable(G);
            # move the points already in the base in front
            sel:=List(BaseStabChain(S),i->Position(d,i));
            sel:=Filtered(sel,i->i<>fail);
            if Length(sel)>0 then
              # rearrange
              sel:=Concatenation(sel,Difference([1..Length(d)],sel));
              dp:=d{sel};
              ep:=e{sel};
              rep := S.identity;
              for i  in [ 1 .. Length( dp ) ]  do
                  if BasePoint( S ) = dp[ i ]  then
                      f := ep[ i ] / rep;
                      if not IsInBasicOrbit( S, f )  then
                          rep := fail;
                          break;
                      else
                          rep := LeftQuotient( InverseRepresentative( S, f ),
                                        rep );
                      fi;
                      S := S.stabilizer;
                  elif ep[ i ] <> dp[ i ] ^ rep  then
                      rep := fail;
                      break;
                  fi;
              od;
            else
              rep:=fail; # we did not yet get anything
            fi;

            if rep=fail then
              # did not work with the existing stabchain - do again
              S := StabChainOp( G, d );
              rep := S.identity;
              for i  in [ 1 .. Length( d ) ]  do
                  if BasePoint( S ) = d[ i ]  then
                      f := e[ i ] / rep;
                      if not IsInBasicOrbit( S, f )  then
                          rep := fail;
                          break;
                      else
                          rep := LeftQuotient( InverseRepresentative( S, f ),
                                        rep );
                      fi;
                      S := S.stabilizer;
                  elif e[ i ] <> d[ i ] ^ rep  then
                      rep := fail;
                      break;
                  fi;
              od;
            fi;

        fi;

    # action on (lists of) permutations, use backtrack
    elif act = OnPoints and IsPerm( d ) and IsPerm( e )  then
        rep := RepOpElmTuplesPermGroup( true, G, [ d ], [ e ],
                       TrivialSubgroup( G ), TrivialSubgroup( G ) );
    elif     ( act = OnPairs or act = OnTuples )
         and IsList( d ) and IsPermCollection( d )
         and IsList( e ) and IsPermCollection( e )  then
        rep := RepOpElmTuplesPermGroup( true, G, d, e,
                       TrivialSubgroup( G ), TrivialSubgroup( G ) );

    # action on permgroups, use backtrack
    elif act = OnPoints and IsPermGroup( d ) and IsPermGroup( e )  then

      if Size(G)<10^5 or NrMovedPoints(G)<500
        # cyclic is handled special by backtrack
        or IsCyclic(d) or IsCyclic(e) or
        # does the group have many short orbits? If so the cluster test
        # would do a lot of checking
        Length(Orbits(d,MovedPoints(G)))^2>NrMovedPoints(G)
        # Do not test for same orbit lengths -- this will be done by next
        # level routine
        then

        rep:=ConjugatorPermGroup(G,d,e);
      else
        S:=ClusterConjugacyPermgroups(G,[e,d]);
        if Length(S.clusters)>1 then return fail;fi;
        if S.gps[1]=S.gps[2] then
          rep:=One(G);
        else
          rep:=ConjugatorPermGroup(S.actors[1],S.gps[2],S.gps[1]);
        fi;
        if rep<>fail then
          rep:=S.conjugators[2]*rep;
        fi;
      fi;

    # action on pairs or tuples of other objects, iterate
    elif act = OnPairs  or act = OnTuples  then
        rep := One( G );
        S   := G;
        i   := 1;
        while i <= Length(d)  and rep <> fail  do
            if e[i] = fail  then
                rep := fail;
            else
                rep2 := RepresentativeActionOp( S, d[i], e[i]^(rep^-1),
                                OnPoints );
                if rep2 <> fail  then
                    rep := rep2 * rep;
                    S   := Stabilizer( S, d[i], OnPoints );
                else
                    rep := fail;
                fi;
            fi;
            i := i + 1;
        od;

    # action on sets of points, use backtrack
    elif act = OnSets and IsPositionsList( d ) and IsPositionsList( e )  then
      if Length(d)<>Length(e) then
        return fail;
      fi;
      if Length(d)=1 then
        rep:=RepresentativeActionOp(G,d[1],e[1],OnPoints);
      else
        rep := RepOpSetsPermGroup( G, d, e );
      fi;

    # action on tuples of sets
    elif act = OnTuplesSets
      and IsList(d) and ForAll(d,i->ForAll(i,IsInt))
      and IsList(e) and ForAll(e,i->ForAll(i,IsInt)) then

      if List(d,Length)<>List(e,Length) then return fail;fi;

      # conjugate one by one
      rep:=One(G);
      S:=G;
      for i in [1..Length(d)] do
        rep2:=RepresentativeAction(S,d[i],e[i],OnSets);
        if rep2=fail then return fail;fi;
        d:=List(d,x->OnSets(x,rep2));
        S:=Stabilizer(S,e[i],OnSets);
        rep:=rep*rep2;
      od;
      return rep;

    # other action, fall back on default representative
    else
        TryNextMethod();
    fi;

    # return the representative
    return rep;
end );

#############################################################################
##
#M  Stabilizer( <G>, <d>, <gens>, <gens>, <act> ) . . . . . . for perm groups
##

BindGlobal( "PermGroupStabilizerOp", function(arg)
    local   K,          # stabilizer <K>, result
            S,  base,
            G,d,gens,acts,act;

 # get arguments, ignoring a given domain
 G:=arg[1];
 K:=Length(arg);
 act:=arg[K];
 acts:=arg[K-1];
 gens:=arg[K-2];
 d:=arg[K-3];

    if gens <> acts  then
        #TODO: Check whether  acts is permutations and one could work in the
        #permutation image (even if G is not permgroups)
        TryNextMethod();
    fi;

    # standard action on points, make a stabchain beginning with <d>
    if act = OnPoints and IsInt( d )  then
        base := [ d ];
    elif     ( act = OnPairs or act = OnTuples )
         and IsPositionsList( d )  then
        base := d;
    fi;
    if IsBound( base )  then
        K := StabChainOp( G, base );
        S := K;
        while IsBound( S.orbit )  and  S.orbit[ 1 ] in base  do
            S := S.stabilizer;
        od;
        if IsIdenticalObj( S, K )  then  K := G;
                                else  K := GroupStabChain( G, S, true );  fi;

    # standard action on (lists of) permutations, take the centralizer
    elif act = OnPoints  and IsPerm( d )  then
        K := Centralizer( G, d );
    elif     ( act = OnPairs or act = OnTuples )
         and IsList( d ) and IsPermCollection( d )  then
        K := RepOpElmTuplesPermGroup( false, G, d, d,
                     TrivialSubgroup( G ), TrivialSubgroup( G ) );

    # standard action on a permutation group, take the normalizer
    elif act = OnPoints  and IsPermGroup(d)  then
        K := Normalizer( G, d );

    # action on sets of points, use a backtrack
    elif act = OnSets  and ForAll( d, IsInt )  then
      if Length(d)=1 then
        K:=Stabilizer(G,d[1]);
      else
        K := RepOpSetsPermGroup( G, d );
      fi;

    # action on sets of pairwise disjoint sets
    elif     act = OnSetsDisjointSets
         and IsList(d) and ForAll(d,i->ForAll(i,IsInt)) then
        K := PartitionStabilizerPermGroup( G, d );

    #T OnSetTuples? is hard

    # action on tuples of sets
    elif act = OnTuplesSets
      and IsList(d) and ForAll(d,i->ForAll(i,IsInt)) then
        K:=G;
        for S in d do
          K:=Stabilizer(K,S,OnSets);
        od;

    # action on tuples of tuples
    elif act = OnTuplesTuples
      and IsList(d) and ForAll(d,i->ForAll(i,IsInt)) then
        K:=G;
        for S in d do
          K:=Stabilizer(K,S,OnTuples);
        od;

    # other action
    else
        TryNextMethod();
    fi;

    # enforce size computation (unless the stabilizer did not cause a
    # StabChain to be computed.
    if HasStabChainMutable(K) then
      Size(K);
    fi;

    # return the stabilizer
    return K;
end );

InstallOtherMethod( StabilizerOp, "permutation group with generators list",
       true,
        [ IsPermGroup, IsObject,
          IsList,
          IsList,
          IsFunction ],
  # the objects might be a group element: rank up
  {} -> RankFilter(IsMultiplicativeElementWithInverse)
  # and we are better even if the group is solvable
  +RankFilter(IsSolvableGroup),
  PermGroupStabilizerOp);

InstallOtherMethod( StabilizerOp, "permutation group with domain",true,
        [ IsPermGroup, IsObject,
          IsObject,
          IsList,
          IsList,
          IsFunction ],
  # the objects might be a group element: rank up
  {} -> RankFilter(IsMultiplicativeElementWithInverse)
  # and we are better even if the group is solvable
  +RankFilter(IsSolvableGroup),
  PermGroupStabilizerOp);

#############################################################################
##
#F  StabilizerOfBlockNC( <G>, <B> )  . . . . block stabilizer for perm groups
##
InstallGlobalFunction( StabilizerOfBlockNC, function(G,B)
local S,j;
  S:=StabChainOp(G,rec(base:=[B[1]],reduced:=false));
  S:=StructuralCopy(S);

  # Make <S> the stabilizer of the block <B>.
  InsertTrivialStabilizer(S.stabilizer,B[1]);
  j := 1;
  while                                j < Length( B )
        and Length( S.stabilizer.orbit ) < Length( B )  do
      j := j + 1;
      if IsBound( S.translabels[ B[ j ] ] )  then
          AddGeneratorsExtendSchreierTree( S.stabilizer,
                  [ InverseRepresentative( S, B[ j ] ) ] );
      fi;
  od;
  return GroupStabChain(G,S.stabilizer,true);
end );


#############################################################################
##
#F  OnSetsSets( <set>, <g> )
##
InstallGlobalFunction( OnSetsSets, function( e, g )
    return Set( e, i -> OnSets( i, g ) );
end );


#############################################################################
##
#F  OnSetsDisjointSets( <set>, <g> )
##
##  `OnSetsDisjointSets' does the same as `OnSetsSets',
##  but since this special case is treated in a special way for example by
##  `StabilizerOp',
##  the function must be an object different from `OnSetsSets'.
##
InstallGlobalFunction( OnSetsDisjointSets, function( e, g )
    return Set( e, i -> OnSets( i, g ) );
end );


#############################################################################
##
#F  OnSetsTuples( <set>, <g> )
##
InstallGlobalFunction( OnSetsTuples, function(e,g)
  return Set(e,i->OnTuples(i,g));
end );

#############################################################################
##
#F  OnTuplesSets( <set>, <g> )
##
InstallGlobalFunction( OnTuplesSets, function(e,g)
  return List(e,i->OnSets(i,g));
end );

#############################################################################
##
#F  OnTuplesTuples( <set>, <g> )
##
InstallGlobalFunction( OnTuplesTuples, function(e,g)
  return List(e,i->OnTuples(i,g));
end );
