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
##  This file contains the basic   routines for permutation group   backtrack
##  algorithms that are based  on partitions. These  routines are used in the
##  calculation  of   set   stabilizers, normalizers,    centralizers     and
##  intersections.
##

if not IsBound( LARGE_TASK )  then  LARGE_TASK := false;   fi;

# set some global variables
BindGlobal("STBBCKT_STRING_CENTRALIZER",MakeImmutable("Centralizer"));
BindGlobal("STBBCKT_STRING_REGORB1",MakeImmutable("_RegularOrbit1"));
BindGlobal("STBBCKT_STRING_REGORB2",MakeImmutable("RegularOrbit2"));
BindGlobal("STBBCKT_STRING_REGORB3",MakeImmutable("RegularOrbit3"));
BindGlobal("STBBCKT_STRING_SPLITOFF",MakeImmutable("SplitOffBlock"));
BindGlobal("STBBCKT_STRING_INTERSECTION",MakeImmutable("Intersection"));
BindGlobal("STBBCKT_STRING_PROCESSFIX",MakeImmutable("ProcessFixpoint"));
BindGlobal("STBBCKT_STRING_MAKEBLOX",MakeImmutable("_MakeBlox"));
BindGlobal("STBBCKT_STRING_SUBORBITS0",MakeImmutable("Suborbits0"));
BindGlobal("STBBCKT_STRING_SUBORBITS1",MakeImmutable("Suborbits1"));
BindGlobal("STBBCKT_STRING_SUBORBITS2",MakeImmutable("Suborbits2"));
BindGlobal("STBBCKT_STRING_SUBORBITS3",MakeImmutable("Suborbits3"));
BindGlobal("STBBCKT_STRING_TWOCLOSURE",MakeImmutable("TwoClosure"));


#############################################################################
##
#V  Refinements . . . . . . . . . . . . . . .  record of refinement processes
##
BindGlobal( "Refinements", AtomicRecord() );


#############################################################################
##
#F  IsSlicedPerm( <perm> )  . . . . . . . . . . . . . . . sliced permutations
##
DeclareRepresentation( "IsSlicedPerm", IsPerm and IsComponentObjectRep,
                        [ "length", "word", "lftObj","opr" ] );

#############################################################################
##
#F  UnslicedPerm@( <perm> ) . . . . . . . . . . . . . . . . . . . . . . local
##
InstallGlobalFunction( UnslicedPerm@, function( perm )
    local   prm,  i;

    if IsSlicedPerm( perm )  then
        prm := ();
        for i  in [ 1 .. perm!.length ]  do
            prm := LeftQuotient( perm!.word[ i ], prm );
        od;
        return prm;
    else
        return perm;
    fi;
end );

InstallMethod( \^, "sliced perm",true, [ IsPerm, IsSlicedPerm ], 0,
    function( p, perm )  return p ^ UnslicedPerm@( perm );  end );
InstallMethod( \^, "sliced perm",true, [ IsInt, IsSlicedPerm ], 0,
    function( p, perm )
    local   i;

    for i  in Reversed( [ 1 .. perm!.length ] )  do
        p := p / perm!.word[ i ];
    od;
    return p;
end );

InstallOtherMethod( \/,"sliced perm", true, [ IsObject, IsSlicedPerm ], 0,
    function( p, perm )
    local   i;

    for i  in [ 1 .. perm!.length ]  do
        p := p ^ perm!.word[ i ];
    od;
    return p;
end );

InstallMethod( PrintObj,"sliced perm", true, [ IsSlicedPerm ], 0,
    function( perm )
    Print( "<perm word of length ", perm!.length, ">" );
end );

InstallMethod( ViewObj,"sliced perm", true, [ IsSlicedPerm ], 0,
    function( perm )
    Print( "<perm word of length ", perm!.length, ">" );
end );

DeclareRepresentation( "IsSlicedPermInv", IsPerm and IsComponentObjectRep,
                           [ "length", "word", "lftObj", "opr" ] );

InstallOtherMethod( \^,"sliced perm", true, [ IsObject, IsSlicedPermInv ], 0,
    function( p, perm )
    local   i;

    for i  in [ 1 .. perm!.length ]  do
        p := p ^ perm!.word[ i ];
    od;
    return p;
end );

InstallMethod( PrintObj,"sliced perm", true, [ IsSlicedPermInv ], 0,
    function( perm )
    Print( "<perm word of length ", perm!.length, ">" );
end );

InstallMethod( ViewObj,"sliced perm", true, [ IsSlicedPermInv ], 0,
    function( perm )
    Print( "<perm word of length ", perm!.length, ">" );
end );

#############################################################################
##
#F  PreImageWord( <p>, <word> ) . . . . . . preimage under sliced permutation
##
InstallGlobalFunction( PreImageWord, function( p, word )
    local   i;

    for i  in Reversed( [ 1 .. Length( word ) ] )  do
        p := p / word[ i ];
    od;
    return p;
end );

#############################################################################
##
#F  ExtendedT( <t>, <pnt>, <img>, <G> ) . .  prescribe one more image for <t>
##
InstallGlobalFunction( ExtendedT, function( t, pnt, img, simg, G )
    local   bpt,  len,  edg;

    # Map the image with the part <t> that is already known.
    if simg = 0  then  img := img / t;
                 else  img := simg;     fi;

    # If <G> fixes <pnt>, nothing more can  be changed, so test whether <pnt>
    # = <img>.
    bpt := BasePoint( G );
    if bpt <> pnt  then
        if pnt <> img  then
            return false;
        fi;

    elif not IsBound( G.translabels[ img ] )  then
        return false;
    elif IsSlicedPerm( t )  then
        len := t!.length;
        while img <> bpt  do
            len := len + 1;
            edg := G.transversal[ img ];
            img := img ^ edg;
#            t!.rgtObj := t!.opr( t!.rgtObj, edg );
            t!.word[ len ] := edg;
        od;
        t!.length := len;
    else
        t := LeftQuotient( InverseRepresentative( G, img ), t );
    fi;

    return t;
end );

#############################################################################
##
#F  MeetPartitionStrat( <rbase>,<image>,<S>,<strat> ) .  meet acc. to <strat>
##
InstallGlobalFunction( MeetPartitionStrat, function(rbase,image,S,g,strat )
local  P,  p;

  if Length( strat ) = 0  then
    return false;
  fi;

  P := image.partition;
  for p  in strat  do
    if p[1] =  0  and
      not ProcessFixpoint( image, p[2], FixpointCellNo( P, p[3] ) )
    or p[1] <> 0  and
      SplitCell( P, p[1], S, p[2], g, p[3] ) <> p[3]  then
      return false;
    fi;
  od;
  return true;
end );

#############################################################################
##
#F  StratMeetPartition( <rbase>, <P>, <S>, <g> )  . construct a meet strategy
##
##  Entries in <strat> have the following meaning:
##    [p,s,i] (p<>0) means that `0 < |P[p]\cap S[s]/g| = i < |P[p]|',
##            i.e., a new cell with <i> points was appended to <P>
##                  (and these <i> have been taken out of `P[p]'),
##    [0,a,p] means that fixpoint <a> was mapped to fixpoint in `P[p]',
##            i.e., `P[p]' has become a one-point cell.
##
InstallGlobalFunction( StratMeetPartition, function( arg )
    local   P,  S,  # first and second partition
            g,      # permutation such that <P> meet <S> / <g> is constructed
            rbase,  # R-base record, which records processing of fixpoints
            strat,  # meet strategy, the result
            p,  s,  # indices looping over the cells of <P> resp. <S>
            i,      # result of call to `SpliltCell'
            pnt,    # fixpoint to be processed
            cellsP, #\
            blist,  #/ see explanation below
            splits,
            lS,
            cell,  nrcells;

    if not IsPartition( arg[ 1 ] )  then  rbase := arg[ 1 ];  p := 2;
                                    else  rbase := false;     p := 1;  fi;
    P := arg[ p ];
    S := arg[ p + 1 ];
    if Length( arg ) = p + 2  then  g := arg[ p + 2 ];
                              else  g := ();            fi;
    strat := [  ];

    # <cellsP> is a   list whose <a>th entry is   <i> if `a^g  in P[p]'. Then
    # `Set(cellsP{S[s]})'  is  the set of    (numbers of) cells  of <P>  that
    # contain a point from `S[s]/g'. A cell splits iff it contains points for
    # two such values of <s>.
    if IsOne( g )  then
        cellsP := P.cellno;
    else
        cellsP := ListWithIdenticalEntries( Length( P.cellno ), 0 );
        for i  in [ 1 .. NumberCells( P ) ]  do
            cell := Cell( P, i );
            cellsP{ OnTuples( cell, g ) } := i + 0 * cell;
        od;
    fi;

    # If <S> is just a set, it is interpreted as partition ( <S>|<S>^compl ).
    if IsPartition( S )  then
        nrcells := NumberCells( S ) - 1;
        lS:=S;
    else
        nrcells := 1;
        blist := BlistList( [ 1 .. NumberCells( P ) ], cellsP{ S } );
        p := Position( blist, true );
        if p <> fail  then
            IntersectBlist( blist, BlistList( [ 1 .. NumberCells( P ) ],
                cellsP{ Difference( [ 1 .. Length( P.cellno ) ], S ) } ) );
            p := Position( blist, true );
        fi;
        lS:=S;
        S := false;
    fi;

    for s  in [ 1 .. nrcells ]  do
      # now split with cell number s of S.
      if S=false then
        p:=lS;
      else
        p:=Cell(S,s);
      fi;
      p:=cellsP{p}; # the affected P-cells
      p:=Collected(p);
      splits:=[];
      for i in p do
        # a cell will split iff it contains more points than are in the
        # s-cell
        if P.lengths[i[1]]>i[2] then
          Add(splits,i[1]);
        fi;
      od;

      # this code is new, the extensive construction of blists in the old
      # version was awfully slow in larger degrees. ahulpke 11-aug-00
      for p in splits do
            # Last argument `true' means that the cell will split.
            i := SplitCell( P, p, lS, s, g, true );
            if not IsOne( g )  then
                cell := Cell( P, NumberCells( P ) );
                cellsP{ OnTuples( cell, g ) } := NumberCells( P ) + 0 * cell;
            fi;

            if rbase <> false  then
                Add( strat, [ p, s, i ] );

                # If  we have one  or two  new fixpoints, put  them  into the
                # base.
                if i = 1  then
                    pnt := FixpointCellNo( P, NumberCells( P ) );
                    ProcessFixpoint( rbase, pnt );
                    Add( strat, [ 0, pnt, NumberCells( P ) ] );
                    if IsTrivialRBase( rbase )  then
                        return strat;
                    fi;
                fi;
                if P.lengths[ p ] = 1  then
                    pnt := FixpointCellNo( P, p );
                    ProcessFixpoint( rbase, pnt );
                    Add( strat, [ 0, pnt, p ] );
                    if IsTrivialRBase( rbase )  then
                        return strat;
                    fi;
                fi;

            fi;
#            p := Position( blist, true, p );
        od;
    od;
    return strat;
end );

# the following functions are for suborbits given by blists, by element
# lists, or as points (the latter are crucial to save memory)
InstallGlobalFunction(SuboLiBli,function(ran,b)
  if IsInt(b) then
    return [b];
  elif IsBlistRep(b) then
    return ListBlist(ran,b);
  fi;
  return b;
end);

InstallGlobalFunction(SuboSiBli,function(b)
  if IsInt(b) then
    return 1;
  elif IsBlistRep(b) then
    return SizeBlist(b);
  else
    return Length(b);
  fi;
end);

InstallGlobalFunction(SuboTruePos,function(ran,b)
  if IsInt(b) then
    return Position(ran,b);
  elif IsBlistRep(b) then
    return Position(b,true);
  elif HasIsSSortedList(b) and IsSSortedList(b) then
    return Position(ran,MinimumList(b));
  else
    return First([1..Length(ran)],i->ran[i] in b);
  fi;
end);

InstallGlobalFunction(SuboUniteBlist,function(ran,a,b)
  if IsInt(b) then
    a[Position(ran,b)]:=true;
  elif IsBlistRep(b) then
    UniteBlist(a,b);
  else
    #UniteBlist(a,BlistList(ran,b));
    UniteBlistList(ran,a,b);
  fi;
end);

# sb is a list of length 3: [points,subs,blists]. The function returns a
# cell as sorted list of points
InstallGlobalFunction(ConcatSubos,function(ran,sb)
local b,i;
  if Length(sb[3])>0 then
    # blists are used
    b:=ShallowCopy(sb[3][1]);
    for i in [2..Length(sb[3])] do
      UniteBlist(b,sb[3][i]);
    od;
    UniteBlistList(ran,b,sb[1]);
    for i in sb[2] do
      UniteBlistList(ran,b,i);
    od;
    return ListBlist(ran,b);
  elif Length(sb[2])>0 then
    # blists are not used but worth using
    b:=BlistList(ran,sb[1]);
    for i in sb[2] do
      UniteBlistList(ran,b,i);
    od;
    return ListBlist(ran,b);
  else
    b:=ShallowCopy(sb[1]);
    for i in sb[2] do
      UniteSet(b,i);
    od;
    return b;
  fi;
end);

#############################################################################
##
#F  Suborbits( <G>, <tofix>, <b>, <Omega> ) . . . . . . . . . . . . suborbits
##
##  Returns a record with the following components:
##
##     domain: the set <Omega>
##  stabChainTop: top level of stabilizer chain for  $G_tofix$ (pointwise stabilizer)  with
##             base point <a> (may be different from <b>)
##       conj: an element mapping <b> to <a>
##      which: a list  whose  <p>th entry   is the  number   of the  suborbit
##             containing <p>
##    lengths: a (not strictly) sorted list of suborbit lengths (subdegrees)
##  byLengths: a list whose <i>th entry is the set of numbers of suborbits of
##             the <i>th distinct length appearing in `lengths'
##  partition: the partition into unions of suborbits of equal length
##  The  next three entries  are lists  whose <k>  entry refers  to the <k>th
##  suborbit.
##     blists: the suborbits as boolean lists
##       reps: a transversal  in  <G> s.t.   $a.reps[k]$  lies in  the  <k>th
##             suborbit (reps[k] = `false' if this is impossible)
##  orbitalPartitions:
##             a list to store the `OrbitalPartition' for each suborbit in
##
InstallGlobalFunction( Suborbits, function( arg )
    local   H,  tofix,  b,  Omega,  suborbits,  len,  bylen,
            G,  GG,  a,  conj,  ran,  subs,  all,  k,  pnt,  orb,  gen,
            perm,  omega,  P,  cell,  part,  p,  i, la,bl,
            rep,rep2,te,stabgens;

    # Get the arguments.
    H := arg[ 1 ];
    tofix := arg[ 2 ];
    b     := arg[ 3 ];
    Omega := arg[ 4 ];
    IsRange(Omega);
    if b = 0  then  part := false;  b := Omega[ 1 ];
              else  part := true;   fi;

    G := StabChainMutable( H );
    bl:=Length(BaseStabChain(G));
    conj := One( H );

    # Replace  <H> by  the stabilizer of  all elements  of <tofix> except the
    # last.
    len := Length( tofix );
    for i  in [ 1 .. len ]  do
        conj := conj * InverseRepresentative( G, tofix[ i ] ^ conj );
        G := G.stabilizer;
    od;

    if len <> 0  then
      b := b ^ conj;
      suborbits:=[];
    else
      if not IsBound( H!.suborbits )  then
        H!.suborbits := [  ];
      fi;
      suborbits := H!.suborbits;
    fi;

    # Replace <b> by the minimal element <a> in its <G>-orbit.
    # rep 0 is an element that maps <b> to the orbits base point
    if not IsInBasicOrbit( G, b )  then
      GG := EmptyStabChain( [  ], One( H ), b );
      AddGeneratorsExtendSchreierTree( GG, G.generators );
    else
      GG := G;
    fi;
    a := Minimum( GG.orbit );

    rep:=InverseRepresentative(GG,b);
    rep2:=InverseRepresentative(GG,a)^-1;
    conj := conj * rep*rep2;

    # try whether a and b are in the same path
    #conj := conj * InverseRepresentative( GG, b ) /
    #               InverseRepresentative( GG, a );

    ran := Immutable([ 1 .. Maximum( Omega ) ]);
    IsSSortedList(ran);

    k:=1;
    while k<=Length(suborbits)
      and (suborbits[k][1]<>a or Omega<>suborbits[k][2]) do
      k:=k+1;
    od;
    if k<=Length(suborbits) and suborbits[k][1]=a and Omega=suborbits[k][2] then
      subs := suborbits[ k ][3];
      Info(InfoBckt,2,"Cached suborbits ",a);
    else
      Info(InfoBckt,2,"Enter suborbits ",Size(H),":",a);

        # Construct the suborbits rooted at <a>.
        # GG is a head of a stabilizer chain with base orbit containing
        # b with min elm a
        if not IsIdenticalObj(G,GG) then
          GG:=CopyStabChain( G );
          ChangeStabChain( GG, [ a ], false );
          te:=GG.transversal;
          stabgens:=GG.stabilizer.generators;
          Unbind(GG);
        else
          stabgens:=G.stabilizer.generators;
          # now conjugate with rep, so that we get things based at 'a'
          # rep2 maps the basepoint to a
          te:=ShallowCopy(G.transversal);
          te[G.orbit[1]]:=rep2; # just one mapper further
          te[a]:=G.identity;
          stabgens:=List(stabgens,i->i^rep2);
        fi;

        subs := rec( stabChainTop := rec(orbit:=[a],
                                         transversal:=te,
                                         identity:=G.identity),
                        domain := Omega,
                         which := ListWithIdenticalEntries( Length(ran), 0 ),
                          reps := [ G.identity ],
                          blists:=[],
                       lengths := [ 1 ],
             orbitalPartitions := [  ] );
        subs.blists[1]:=[a];
        subs.which[ a ] := 1;
        if IsRange(Omega) and 1 in Omega then
          all:=BlistList(ran,[]);
        else
          all := BlistList( ran, ran );
          SubtractBlist( all, BlistList( ran, Omega ) );
        fi;
        all[ a ] := true;
        la:=Length(all)-1;

        k := 1;
        pnt := Position( all, false );
        while pnt <> fail  do
          k := k + 1;
          orb := [ pnt ];
          all[ pnt ] := true;
          for p  in orb  do
            for gen  in stabgens  do
              i := p ^ gen;
              if not all[ i ]  then
                Add( orb, i );
                all[ i ] := true;
              fi;
            od;
          od;
          la:=la-Length(orb);
          subs.which{ orb } := k + 0 * orb;
          #if IsInBasicOrbit( G, pnt )  then
          if IsBound(te[pnt]) then
            subs.reps[ k ] := true;
            subs.lengths[ k ] := Length( orb );
          else
            # Suborbits outside the root's orbit get negative length.
            subs.reps[ k ] := false;
            subs.lengths[ k ] := -Length( orb );
          fi;
          #UniteBlist( all, sublique );
          if QuoInt(Length(ran),Length(orb))>100 then
            if Length(orb)=1 then
              subs.blists[ k ] := orb[1];
            else
              subs.blists[ k ] := Immutable(Set(orb));
            fi;
          else
            subs.blists[ k ] := BlistList(ran,orb);
          fi;
          if la=0 then
            pnt:=fail;
          else
            pnt := Position( all, false, pnt );
          fi;
        od;
        subs.sublilen:=Length(subs.blists);

        # store if not too many
        if Length(suborbits)>bl then
          for i in [1..Length(suborbits)-1] do
            suborbits[i]:=suborbits[i+1];
          od;
          suborbits[Length(suborbits)]:=[a,Omega,subs];
        else
          Add(suborbits,[a,Omega,subs]);
        fi;

    fi;

    if part  and  not IsBound( subs.partition )  then
        if not IsBound( subs.lengths )  then
Error("this should not happen 2719");
#            subs.lengths := [  ];
#            for k  in [ 1 .. subs.sublilen ]  do
#                if subs.reps[ k ] = false  then
#                    Add( subs.lengths, -SizeBlist( subs.blists[k] ) );
#                else
#                    Add( subs.lengths, SizeBlist( subs.blists[k] ) );
#                fi;
#            od;
        fi;
        perm := Sortex( subs.lengths ) ^ -1;

        # Determine the partition into unions of suborbits of equal length.
        subs.byLengths := [  ];
        P := [  ];  omega := Set( Omega );  cell := [  ];  bylen := [  ];
        for k  in [ 1 .. Length( subs.lengths ) ]  do
            Append( cell, SuboLiBli( ran, subs.blists[ k ^ perm ] ) );
            AddSet( bylen, k ^ perm );
            if    k = Length( subs.lengths )
               or subs.lengths[ k + 1 ] <> subs.lengths[ k ]  then
                Add( P, cell );  SubtractSet( omega, cell );  cell := [  ];
                Add( subs.byLengths, bylen );  bylen := [  ];
            fi;
        od;
        if Length( omega ) <> 0  then
            Add( P, omega );
        fi;
        subs.partition := Partition( P );
    fi;
    subs := ShallowCopy( subs );
    subs.conj := conj;
    return subs;
end );

#############################################################################
##
#F  OrbitalPartition( <subs>, <k> ) . . . . . . . . . . make a nice partition
##
##
## ahulpke, added aug-2-00: If there are only one or two cells, the function
## will return just one cell (the partitions split functions can treat this
## as a special case anyhow).
InstallGlobalFunction( OrbitalPartition, function( subs, k )
local  dom,  # operation domain for the group
        ran,  # range including <dom>, for blist construction
        d,    # number of suborbits, estimate for diameter
        len,  # current path length
        K,    # set of suborbits <k> to process
        Key,  # discriminating information for each suborbit
        key,  # discriminating information for suborbit number <k>
        old,  # farthest distance zone constructed so far
        new,  # new distance zone being constructed
        img,  # new endpoint of path with known predecessor
        o, i, # suborbit of predecessor resp. endpoint
        P,    # points ordered by <key> information, as partition
        typ,  # types of <key> information that occur
        sub,  # suborbit as list of integers
        csiz,
        pos;  # position of cell with given <key> in <P>

  if IsInt( k ) and IsBound( subs.orbitalPartitions[ k ] ) then
    Info(InfoBckt,2,"Orbital partition ",k," cached");
    P:=subs.orbitalPartitions[k];
  else
    ran := Immutable([ 1 .. Length( subs.which ) ]);
    IsSSortedList(ran);
    d   := subs.sublilen;
    if IsRecord( k )  then  K := k.several;
                      else  K := [ k ];      fi;
    Key := 0;
    for k  in K  do
      if IsList( k )  and  Length( k ) = 1  then
        k := k[ 1 ];
      fi;
      key := ListWithIdenticalEntries( d, 0 );

      # Initialize the flooding algorithm for the <k>th suborbit.
      if IsInt( k )  then
        if subs.reps[ k ] = false  then
          sub := 0;
          key[ k ] := -1;
          new := [  ];
        else
          sub := SuboLiBli( ran, subs.blists[ k ] );
          key[ k ] := 1;
          new := [ k ];
        fi;
      else
        #sub := ListBlist( ran, UnionBlist( subs.blists{ k } ) );
        if IsEmpty(k) then
          sub:=[];
        else
          sub:=subs.blists[k[1]];
          if IsInt(sub) then
            sub:=BlistList(ran,[sub]);
          elif not IsBool(sub[1]) then
            sub:=BlistList(ran,sub);
          else
            sub:=ShallowCopy(sub); # don't overwrite
          fi;
          for o in [2..Length(k)] do
            SuboUniteBlist(ran,sub,subs.blists[k[o]]);
          od;
          sub:=ListBlist(ran,sub);
        fi;

        key{ k } := 1 + 0 * k;
        new := Filtered( k, i -> subs.reps[ i ] <> false );
      fi;
      len := 1;

      # If no new points were found in the last round, stop.
      while Length( new ) <> 0  do
        len := len + 1;
        old := new;
        new := [  ];

        # Map the suborbit <sub> with each old representative.
        for o  in old  do
          if subs.reps[o]<>false then
            if subs.reps[ o ] = true  then
              subs.reps[ o ] := InverseRepresentative( subs.stabChainTop,
                  SuboTruePos(ran, subs.blists[ o ] ) ) ^ -1;
            fi;
            for img  in OnTuples( sub, subs.reps[ o ] )  do

              # Find the suborbit <i> of the image.
              i := subs.which[ img ];

              # If this suborbit is encountered for the first time, add
              # it to <new> and store its distance <len>.
              if key[ i ] = 0  then
                Add( new, i );
                key[ i ] := len;
              fi;

              # Store the arrow which starts at suborbit <o>.
              key[ o ] := key[ o ] + d *
                          Length( sub ) ^ ( key[ i ] mod d );
            od;
          else
            Info(InfoWarning,1,"suborbits variant triggered, check!");
          fi;
        od;
      od;

      if sub <> 0  then
        Key := Key * ( d + d * Length( sub ) ^ d ) + key;
      fi;
    od;

    # Partition  <dom> into unions   of  suborbits w.r.t. the  values  of
    # <Key>.
    if Key = 0  then
      P:=[];
      if IsInt( k )  then
        subs.orbitalPartitions[ k ] := P;
      fi;
      return P;
    else

#T1:=Runtime()-T1;
      typ := Set( Key );
      csiz:=ListWithIdenticalEntries(Length(typ),0);
      dom:=List(typ,i->[[],[],[]]);
      for i in [1..Length(Key)] do
        pos := Position( typ, Key[ i ] );
        csiz[pos]:=csiz[pos]+AbsInt(subs.lengths[i]);
        if IsInt(subs.blists[i]) then
          AddSet(dom[pos][1],subs.blists[i]);
        elif IsBlistRep(subs.blists[i]) then
          Add(dom[pos][3],subs.blists[i]);
        else
          Add(dom[pos][2],subs.blists[i]);
        fi;
      od;
      if Sum(csiz)=Length(subs.domain) and Length(typ)=1 then
        P:=[];
        if IsInt( k )  then
          subs.orbitalPartitions[ k ] := P;
        fi;
        return P;
      elif Sum(csiz)=Length(subs.domain) and Length(typ)=2 then
        # only two cells
        # we need to indicate the first cell, the trick to take the sorted
        # one does not work
        P:=ConcatSubos(ran,dom[1]);
        if IsInt( k )  then
          subs.orbitalPartitions[ k ] := P;
        fi;
        return P;
      fi;

      P:=[];
      for pos in [1..Length(typ)] do
        sub := ConcatSubos( ran, dom[pos] );
        Add(P,sub);
      od;
#fi;
#T1:=Runtime()-T1;


      if Sum(List(P,Length)) <> Length(subs.domain)  then
        # there are fixpoints missing
        Add( P, Difference(subs.domain,Union(P)));
      fi;

    fi;

    P := Partition( P );
    if IsInt( k )  then
      subs.orbitalPartitions[ k ] := P;
    fi;

  fi;
  return P;
end );

#############################################################################
##
#F  EmptyRBase( <G>, <Omega>, <P> ) . . . . . . . . . . . . initialize R-base
##
InstallGlobalFunction( EmptyRBase, function( G, Omega, P )
    local   rbase,  pnt;

    rbase := rec( domain := Omega,
                    base := [  ],
                   where := [  ],
                     rfm := [  ],
               partition := StructuralCopy( P ),
                     lev := [  ] );
    if IsList( G )  then
        if IsIdenticalObj( G[ 1 ], G[ 2 ] )  then
            rbase.level2 := true;
        else
            rbase.level2 := CopyStabChain( StabChainImmutable( G[ 2 ] ) );
            rbase.lev2   := [  ];
        fi;
        G := G[ 1 ];
    else
        rbase.level2 := false;
    fi;
#    if IsSymmetricGroupQuick( G )  then
#        Info( InfoBckt, 1, "Searching in symmetric group" );
#        rbase.fix   := [  ];
#        rbase.level := NrMovedPoints( G );
#    else
        rbase.chain := CopyStabChain( StabChainImmutable( G ) );
        rbase.level := rbase.chain;
#    fi;

    # Process all fixpoints in <P>.
    for pnt  in Fixcells( P )  do
        ProcessFixpoint( rbase, pnt );
    od;

    return rbase;
end );

#############################################################################
##
#F  IsTrivialRBase( <rbase> ) . . . . . . . . . . . . . .  is R-base trivial?
##
InstallGlobalFunction( IsTrivialRBase, function( rbase )
    return        IsInt( rbase.level )
              and rbase.level <= 1
           or     IsRecord( rbase.level )
              and Length( rbase.level.genlabels ) = 0;
end );

#############################################################################
##
#F  AddRefinement( <rbase>, <func>, <args> )  . . . . . register R-refinement
##
InstallGlobalFunction( AddRefinement, function( rbase, func, args )
    if    Length( args ) = 0
       or not IsList( args[ Length( args ) ] )
       or Length( args[ Length( args ) ] ) <> 0  then
        Add( rbase.rfm[ Length( rbase.rfm ) ], rec( func := func,
                                                    args := args ) );
        Info( InfoBckt, 1, "Refinement ", func, ": ",
                NumberCells( rbase.partition ), " cells" );
    fi;
end );

#############################################################################
##
#F  ProcessFixpoint( <rbase>|<image>, <pnt> [, <img> ] )  .  process fixpoint
##
##  `ProcessFixpoint( rbase, pnt )' puts in <pnt> as new base point and steps
##  down to the stabilizer, unless <pnt>  is redundant, in which case `false'
##  is returned.
##  `ProcessFixpoint( image, pnt, img )' prescribes <img> as image for <pnt>,
##  extends the permutation and steps down to  the stabilizer. Returns `true'
##  if this was successful and `false' otherwise.
##
InstallGlobalFunction( ProcessFixpoint, function( arg )
    local   rbase,  image,  pnt,  img,  simg,  t;

    if Length( arg ) = 2  then
        rbase := arg[ 1 ];
        pnt   := arg[ 2 ];
        if rbase.level2 <> false  and  rbase.level2 <> true  then
            ChangeStabChain( rbase.level2, [ pnt ] );
            if BasePoint( rbase.level2 ) = pnt  then
                rbase.level2 := rbase.level2.stabilizer;
            fi;
        fi;
        if IsInt( rbase.level )  then
            rbase.level := rbase.level - 1;
        else
            ChangeStabChain( rbase.level, [ pnt ] );
            if BasePoint( rbase.level ) = pnt  then
                rbase.level := rbase.level.stabilizer;
            else
                return false;
            fi;
        fi;
    else
        image := arg[ 1 ];
        pnt   := arg[ 2 ];
        img   := arg[ 3 ];
        if image.perm <> true  then
            if Length( arg ) = 4  then  simg := arg[ 4 ];
                                  else  simg := 0;         fi;
            t := ExtendedT( image.perm, pnt, img, simg, image.level );
            if t = false  then
                return false;
            elif BasePoint( image.level ) = pnt  then
                image.level := image.level.stabilizer;
            fi;
            image.perm := t;
        fi;
        if image.level2 <> false  then
            t := ExtendedT( image.perm2, pnt, img, 0, image.level2 );
            if t = false  then
                return false;
            elif BasePoint( image.level2 ) = pnt  then
                image.level2 := image.level2.stabilizer;
            fi;
            image.perm2 := t;
        fi;
    fi;
    return true;
end );

#############################################################################
##
#F  RegisterRBasePoint( <P>, <rbase>, <pnt> ) . . . . . register R-base point
##
InstallGlobalFunction( RegisterRBasePoint, function( P, rbase, pnt )
    local   O,  strat,  k,  lev;

    if rbase.level2 <> false  and  rbase.level2 <> true  then
        Add( rbase.lev2, rbase.level2 );
    fi;
    Add( rbase.lev, rbase.level );
    Add( rbase.base, pnt );
    k := IsolatePoint( P, pnt );
    Info( InfoBckt, 1, "Level ", Length( rbase.base ), ": ", pnt, ", ",
            P.lengths[ k ] + 1, " possible images" );
    if not ProcessFixpoint( rbase, pnt )  then
        Info(InfoWarning,2,"Warning: R-base point is already fixed" );
    fi;
    Add( rbase.where, k );
    Add( rbase.rfm, [  ] );
    if P.lengths[ k ] = 1  then
        pnt := FixpointCellNo( P, k );
        ProcessFixpoint( rbase, pnt );
        AddRefinement( rbase, STBBCKT_STRING_PROCESSFIX, [ pnt, k ] );
    fi;
    if rbase.level2 <> false  then
        if rbase.level2 = true  then  lev := rbase.level;
                                else  lev := rbase.level2;  fi;
        if not IsInt( lev )  then
            O := OrbitsPartition( lev, rbase.domain );
            strat := StratMeetPartition( rbase, P, O );
            AddRefinement( rbase, STBBCKT_STRING_INTERSECTION, [ O, strat ] );
        fi;
    fi;
end );

#############################################################################
##
#F  NextRBasePoint( <P>, <rbase> [, <order> ] ) . . .  find next R-base point
##
InstallGlobalFunction( NextRBasePoint, function( arg )
    local  rbase,    # R-base to be extended
           P,        # partition of <Omega> to be refined
           order,    # order in which to try the cells of <Omega>
           lens,     # sequence of cell lengths of <P>
           p,        # the next point chosen
           k,  l;    # loop variables

    # Get the arguments.
    P     := arg[ 1 ];
    rbase := arg[ 2 ];
    if Length( arg ) > 2  then  order := arg[ 3 ];
                          else  order := false;     fi;

    # When  this is called,   there is  a point  that   is neither  fixed  by
    # <rbase.level> nor in <P>.
    lens := P.lengths;
    p := fail;
    if order <> false  then
        if IsInt( rbase.level )  then
            p := PositionProperty( order, p ->
                         lens[ CellNoPoint(P,p ) ] <> 1 );
        else
            p := PositionProperty( order, p ->
                         lens[ CellNoPoint(P,p) ] <> 1
                     and not IsFixedStabilizer( rbase.level, p ) );
        fi;
    fi;

    if p <> fail  then
        p := order[ p ];
    else
        lens := ShallowCopy( lens );
        order := [ 1 .. NumberCells( P ) ];
        SortParallel( lens, order );
        k := PositionProperty( lens, x -> x <> 1 );
        l := fail;
        while l = fail  do
            if IsInt( rbase.level )  then
                l := 1;
            else
                l := PositionProperty
                     ( P.firsts[ order[ k ] ] - 1 + [ 1 .. lens[ k ] ],
                       i -> not IsFixedStabilizer( rbase.level,
                               P.points[ i ] ) );
            fi;
            k := k + 1;
        od;
        p := P.points[ P.firsts[ order[ k - 1 ] ] - 1 + l ];
    fi;

    RegisterRBasePoint( P, rbase, p );
end );

#############################################################################
##
#F  RRefine( <rbase>, <image>, <uscore> ) . . . . . . . . . apply refinements
##
InstallGlobalFunction( RRefine, function( rbase, image, uscore )
local  Rf,  t;

  if not uscore then
    for Rf  in rbase.rfm[ image.depth ]  do
      t := CallFuncList( Refinements.( Rf.func ), Concatenation
                    ( [ rbase, image ], Rf.args ) );
      if   t = false  then  return fail;
      elif t <> true  then  return t;     fi;
    od;
    return true;
  else
    for Rf  in rbase.rfm[ image.depth ]  do
      if Rf.func[ 1 ] = '_'  then
        t := CallFuncList( Refinements.( Rf.func ), Concatenation
                      ( [ rbase, image ], Rf.args ) );
        if   t = false  then  return fail;
        elif t <> true  then  return t;     fi;
      fi;
    od;
    return true;
  fi;

  #old code
  for Rf  in rbase.rfm[ image.depth ]  do
      if not uscore  or  Rf.func[ 1 ] = '_'  then
          t := CallFuncList( Refinements.( Rf.func ), Concatenation
                        ( [ rbase, image ], Rf.args ) );
          if   t = false  then  return fail;
          elif t <> true  then  return t;     fi;
      fi;
  od;
  return true;

end );

#############################################################################
##
#F  PBIsMinimal( <range>, <a>, <b>, <S> ) . . . . . . . . . . minimality test
##
InstallGlobalFunction( PBIsMinimal, function( range, a, b, S )
    local   orb,  old,  pnt,  l,  img;

    if IsInBasicOrbit( S, b )  then
        return ForAll( S.orbit, p -> a <= p );
    elif b < a                      then  return false;
    elif IsFixedStabilizer( S, b )  then  return true;   fi;

    orb := [ b ];
    old := BlistList( range, orb );
    for pnt  in orb  do
        for l  in S.genlabels  do
            img := pnt ^ S.labels[ l ];
            if not old[ img ]  then
                if img < a  then
                    return false;
                fi;
                old[ img ] := true;
                Add( orb, img );
            fi;
        od;
    od;
    return true;
end );

#############################################################################
##
#F  SubtractBlistOrbitStabChain( <blist>, <R>, <pnt> )  remove orbit as blist
##
InstallGlobalFunction( SubtractBlistOrbitStabChain, function( blist, R, pnt )
    local   orb,  gen,  img;

    orb := [ pnt ];
    blist[ pnt ] := false;
    for pnt  in orb  do
        for gen  in R.generators  do
            img := pnt ^ gen;
            if blist[ img ]  then
                blist[ img ] := false;
                Add( orb, img );
            fi;
        od;
    od;
end );

#############################################################################
##
#F  PartitionBacktrack( <G>, <Pr>, <repr>, <rbase>, <data>, <L>, <R> )  . . .
##
InstallGlobalFunction( PartitionBacktrack,
    function( G, Pr, repr, rbase, data, L, R )
    local  PBEnumerate,
           blen,         # length of R-base
           rep,          # representative or `false', the result
           branch,       # level where $Lstab\ne Rstab$ starts
           image,        # image information running through the tree
           oldcel,       # old value of <image.partition.cellno>
           orb,  org,    # intersected (mapped) basic orbits of <G>
           orB,          # backup of <orb>
           range,        # range for construction of <orb>
           fix,  fixP,   # fixpoints of partitions at root of search tree
           obj,  prm,    # temporary variables for constructed permutation
           nrback,       # backtrack counter
           bail,         # do we want to bail out quickly?
           i,  dd,  p;   # loop variables

#############################################################################
##
#F      PBEnumerate( ... )  . . . . . . . recursive enumeration of a subgroup
##
    PBEnumerate := function( d, wasTriv )
        local  undoto,   # number of cells of <P> wanted after undoing
               oldprm,   #\
               oldprm2,  #/  old values of <image>
               a,        # current R-base point
               m,        # initial number of candidates in <orb>
               max,      # maximal number of candidates still needed
               b,        # image of base point currently being considered
               t;        # group element constructed, to be handed upwards

        if image.perm = false  then
            return fail;
        fi;
        image.depth := d;

        # Store the original values of <image.*>.
        undoto := NumberCells( image.partition );
        if image.perm = true  then
            oldcel := image.partition;
        else
            oldcel := image.partition.cellno;
            if IsSlicedPerm( image.perm ) then  oldprm := image.perm!.length;
                                          else  oldprm := image.perm;
                                          fi;
        fi;
        if image.level2 <> false  then  oldprm2 := image.perm2;
                                  else  oldprm2 := false;        fi;

        # Recursion comes to an end  if all base  points have been prescribed
        # images.
        if d > Length( rbase.base )  then
            if IsTrivialRBase( rbase )  then
                blen := Length( rbase.base );

                # Do     not  add the   identity    element  in the  subgroup
                # construction.
                if wasTriv  then

                    # In the subgroup case, assign to  <L> and <R> stabilizer
                    # chains when the R-base is complete.
                    L := ListStabChain( CopyStabChain( StabChainOp( L,
                                 rec( base := rbase.base,
                                   reduced := false ) ) ) );
                    R := ShallowCopy( L );

                    if image.perm <> true  then
                        Info( InfoBckt, 1, "Stabilizer chain with depths ",
                                DepthSchreierTrees( rbase.chain ) );
                    fi;
                    Info( InfoBckt, 1, "Indices: ",
                          IndicesStabChain( L[ 1 ] ) );
                    return fail;

                else
                    if image.perm = true  then
                        prm := MappingPermListList
                               ( rbase.fix[ Length( rbase.base ) ],
                                 Fixcells( image.partition ) );
                    else
                        prm := image.perm;
                    fi;
                    if image.level2 <> false  then
                        prm := UnslicedPerm@( prm );
                        if SiftedPermutation( image.level2,
                                   prm / UnslicedPerm@( image.perm2 ) )
                           = image.level2.identity  then
                            return prm;
                        fi;
                    elif Pr( prm )  then
                        return UnslicedPerm@( prm );
                    fi;
                    return fail;
                fi;

            # Construct the   next refinement  level. This  also  initializes
            # <image.partition> for the case ``image = base point''.
            else
                if not repr  then
                    oldcel := StructuralCopy( oldcel );
                fi;
                rbase.nextLevel( rbase.partition, rbase );
                if image.perm = true  then
                    Add( rbase.fix, Fixcells( rbase.partition ) );
                fi;
                Add( org, ListWithIdenticalEntries( Length( range ), 0 ) );
                if repr  then

                    # In  the representative  case,  change  the   stabilizer
                    # chains of <L> and <R>.
                    ChangeStabChain( L[ d ], [ rbase.base[ d ] ], false );
                    L[ d + 1 ] := L[ d ].stabilizer;
                    ChangeStabChain( R[ d ], [ rbase.base[ d ] ], false );
                    R[ d + 1 ] := R[ d ].stabilizer;

                fi;
            fi;

        fi;
        a := rbase.base[ d ];
        Info(InfoBckt,3,Ordinal(d)," basepoint: ",a);

        # Intersect  the current cell of <P>  with  the mapped basic orbit of
        # <G> (and also with the one of <H> in the intersection case).
        if image.perm = true  then
            orb[ d ] := BlistList( range, Cell( oldcel, rbase.where[ d ] ) );
            if image.level2 <> false  then
                b := Position( orb[ d ], true );
                while b <> fail  do
                    if not IsInBasicOrbit( rbase.lev2[ d ], b / image.perm2 )
                       then
                        orb[ d ][ b ] := false;
                    fi;
                    b := Position( orb[ d ], true, b );
                od;
            fi;
        else
            orb[ d ] := BlistList( range, [  ] );
            for p  in rbase.lev[ d ].orbit  do
                b := p ^ image.perm;
                if oldcel[ b ] = rbase.where[ d ]
               and ( image.level2 = false
                  or IsInBasicOrbit( rbase.lev2[d], b/image.perm2 ) )  then
                    orb[ d ][ b ] := true;
                    org[ d ][ b ] := p;
                fi;
            od;
        fi;
        if d=1 and ForAll(GeneratorsOfGroup(G),x->a^x=a) then
          orb[d][a]:=true; # ensure a is a possible image (can happen if
                           # acting on permutations with more points)
        fi;

        orB[ d ] := StructuralCopy( orb[ d ] );

        # Loop  over the candidate images  for the  current base point. First
        # the special case ``image = base'' up to current level.
        if wasTriv  then
            image.bimg[ d ] := a;

            # Refinements that start with '_' must be executed even when base
            # = image since they modify `image.data' etc.
            RRefine( rbase, image, true );

            # Recursion.
            PBEnumerate( d + 1, true );
            image.depth := d;

            # Now we  can  remove  the  entire   <R>-orbit of <a>  from   the
            # candidate list.
            SubtractBlist( orb[ d ], BlistList( range, L[ d ].orbit ) );

        fi;

        # Only the early points of the orbit have to be considered.
        m := SizeBlist( orB[ d ] );
        if m < Length( L[ d ].orbit )  then
            return fail;
        fi;
        max := PositionNthTrueBlist( orB[ d ],
                       m - Length( L[ d ].orbit ) + 1 );
        if wasTriv  and  a > max  then
            m := m - 1;
            if m < Length( L[ d ].orbit )  then
                return fail;
            fi;
            max := PositionNthTrueBlist( orB[ d ],
                           m - Length( L[ d ].orbit ) + 1 );
        fi;

        # Now the other possible images.
        b := Position( orb[ d ], true );
        if b <> fail  and  b > max  then
            b := fail;
        fi;
        while b <> fail  do

            # Try to prune the node with prop 8(ii) of Leon's paper.
            if not repr  and  not wasTriv  and  IsBound( R[ d ].orbit )  then
                dd := branch;
                while dd < d  do
                    if IsInBasicOrbit( L[ dd ], a )  and  not PBIsMinimal
                       ( range, R[ dd ].orbit[ 1 ], b, R[ d ] )  then
                        Info( InfoBckt, 3, d, ": point ", b,
                                " pruned by minimality condition" );
                        dd := d + 1;
                    else
                        dd := dd + 1;
                    fi;
                od;
            else
                dd := d;
            fi;

            if dd = d  then

                # Undo the  changes made to  <image.partition>, <image.level>
                # and <image.perm>.
                for i  in [ undoto+1 .. NumberCells( image.partition ) ]  do
                    UndoRefinement( image.partition );
                od;
                if image.perm <> true  then
                    image.level := rbase.lev[ d ];
                    if IsSlicedPerm( image.perm )  then
                        image.perm!.length := oldprm;
                         # Here and below the code that refers to `rgtObj` was used to avoid multiplication
                         # of permutations. It has been commented out for a long time, but accidentally remained
                         # documented in `doc/ref/stbchain.xml` until its withdrawal in 2018.
#                        image.perm!.rgtObj := oldrgt;
                    else
                        image.perm := oldprm;
                    fi;
                fi;
                if image.level2 <> false  then
                    image.level2 := rbase.lev2[ d ];
                    image.perm2  := oldprm2;
                fi;

                # If <b> could not be prescribed as image for  <a>, or if the
                # refinement was impossible, give up for this image.
                image.bimg[ d ] := b;
                IsolatePoint( image.partition, b );

                if ProcessFixpoint( image, a, b, org[ d ][ b ] )  then
#Error(a," ",b," ",Cells(rbase.partition),Cells(image.partition));
                    t := RRefine( rbase, image, false );
                else
                    t := fail;
                fi;

                if t <> fail  then

                    # Subgroup case, base <> image   at current level:   <R>,
                    #   which until now is identical to  <L>, must be changed
                    #   without affecting <L>, so take a copy.
                    if wasTriv  and  IsIdenticalObj( L[ d ], R[ d ] )  then
                        R{ [ d .. Length( rbase.base ) ] } := List(
                        L{ [ d .. Length( rbase.base ) ] }, CopyStabChain );
                        branch := d;
                    fi;

                    if 2 * d <= blen  then
                        ChangeStabChain( R[ d ], [ b ], false );
                        R[ d + 1 ] := R[ d ].stabilizer;
                    else
                        if IsBound( R[ d ].stabilizer )  then
                            R[ d + 1 ] := StrongGeneratorsStabChain( R[ d ] );
                        else
                            R[ d + 1 ] := R[ d ].generators;
                        fi;
                        R[ d + 1 ] := rec( generators := Filtered
                            ( R[ d + 1 ], gen -> b ^ gen = b ) );
                    fi;

                else
                    Info( InfoBckt, 5, d, ": point ", b,
                            " pruned by partition condition" );
                fi;

                # Recursion.
                if t = true  then
                    t := PBEnumerate( d + 1, false );
                    nrback:=nrback+1;
                    if bail and nrback>500 then
                      return infinity; # bail out, this will bail out
                                       # recursively
                    fi;
                    image.depth := d;
                fi;

                # If   <t>   =   `fail', either   the   recursive   call  was
                #   unsuccessful,  or all new  elements   have been added  to
                #   levels  below  the current one   (this happens if  base =
                #   image up to current level).
                if t <> fail  then

                    # Representative case, element found: Return it.
                    # Subgroup case, base <> image  before current level:  We
                    #   need  only find  a representative  because we already
                    #   know the stabilizer of <L> at an earlier level.
                    if repr  or  not wasTriv  then
                        return t;

                    # Subgroup case, base  <> image at current level: Enlarge
                    #   <L>    with  <t>. Decrease <max>     according to the
                    #   enlarged <L>. Reset <R> to the enlarged <L>.
                    else
                        for dd  in [ 1 .. d ]  do
                            AddGeneratorsExtendSchreierTree( L[ dd ], [ t ] );
                        od;
                        Info( InfoBckt, 1, "Level ", d,
                                ": ", IndicesStabChain( L[ 1 ] ) );
                        if m < Length( L[ d ].orbit )  then
                            return fail;
                        fi;
                        max := PositionNthTrueBlist( orB[ d ],
                                       m - Length( L[ d ].orbit ) + 1 );
                        R{ [ d .. Length( rbase.base ) ] } := List(
                        L{ [ d .. Length( rbase.base ) ] }, CopyStabChain );
                    fi;

                fi;

                # Now  we can remove the   entire <R>-orbit  of <b> from  the
                # candidate list.
                if      IsBound( R[ d ].translabels )
                    and IsBound( R[ d ].translabels[ b ] )  then
                    SubtractBlist( orb[ d ],
                            BlistList( range, R[ d ].orbit ) );
                else
                    SubtractBlistOrbitStabChain( orb[ d ], R[ d ], b );
                fi;

            fi;

            b := Position( orb[ d ], true, b );
            if b <> fail  and  b > max  then
                b := fail;
            fi;
        od;

        return fail;
    end;

##
#F      main function . . . . . . . . . . . . . . . . . . . . . . . . . . . .
##

    nrback:=0; # count the number of times we jumped up
    bail:=repr and ValueOption("bailout")=true;

    # If necessary, convert <Pr> from a list to a function.
    if     IsList( Pr )
       and (    IsTrivial( G )
             #or IsSymmetricGroupQuick( G )
             ) then
        obj := rec( lftObj := Pr[ 1 ],
#                    rgtObj := Pr[ 2 ],
                       opr := Pr[ 3 ],
                      prop := Pr[ 4 ] );
        Pr := gen -> obj.prop
              ( rec( lftObj := obj.lftObj
#             ,
#                     rgtObj := obj.opr( obj.rgtObj, gen ^ -1 )
            ) );
    fi;

    # Trivial cases first.
    if IsTrivial( G )  then
        if   not repr        then  return G;
        elif Pr( One( G ) )  then  return One( G );
                             else  return fail;      fi;
    fi;

    # Construct the <image>.
    image := rec( data := data,
                  bimg := [  ],
                 depth := 1 );
    if repr  then  image.partition := data[ 1 ];
             else  image.partition := rbase.partition;  fi;
    if IsBool( rbase.level2 )  then
        image.level2 := false;
    else
        image.level2 := rbase.level2;
        image.perm2  := rbase.level2.identity;
    fi;

    # If  <Pr> is  function,   multiply  permutations. Otherwise, keep   them
    # factorized.
#    if IsSymmetricGroupQuick( G )  then
#        image.perm := true;
#    else
        if IsList( Pr )  then
            image.perm := Objectify
                ( NewType( PermutationsFamily, IsSlicedPerm ),
                  rec( length := 0, word := [  ] ) );
            image.perm!.lftObj := Pr[ 1 ];
#            image.perm!.rgtObj := Pr[ 2 ];
            image.perm!.opr    := Pr[ 3 ];
            Pr                 := Pr[ 4 ];
        else
            image.perm := One( G );
        fi;
        image.level := rbase.chain;
#    fi;

    if repr  then

        # In the representative case, map the  fixpoints of the partitions at
        # the root of the search tree.
        if rbase.partition.lengths <> image.partition.lengths  then
            image.perm := false;
        else
            fix  := Fixcells( rbase.partition );
            fixP := Fixcells( image.partition );
            for i  in [ 1 .. Length( fix ) ]  do
                ProcessFixpoint( image, fix[ i ], fixP[ i ] );
            od;
        fi;

        # In   the representative case,   assign  to <L>  and <R>  stabilizer
        # chains.
        L := ListStabChain( CopyStabChain( StabChainImmutable( L ) ) );
        R := ListStabChain( CopyStabChain( StabChainImmutable( R ) ) );

    fi;

    org := [  ];  orb := [  ];  orB := [  ];
    range := [ 1 .. rbase.domain[ Length( rbase.domain ) ] ];
    blen := infinity;
    rep := PBEnumerate( 1, not repr );
    if not repr  then
        ReduceStabChain( L[ 1 ] );
        return GroupStabChain( G, L[ 1 ], true );
    else
        return rep;
    fi;
end );

#############################################################################
##
#F  Refinements.ProcessFixpoint( <pnt>, <cellnum> )  . . .  process a fixpoint
##
InstallGlobalFunction(Refinements_ProcessFixpoint,
function( rbase, image, pnt, cellnum )
    local   img;

    img := FixpointCellNo( image.partition, cellnum );
    return ProcessFixpoint( image, pnt, img );
end);
Refinements.(STBBCKT_STRING_PROCESSFIX) := Refinements_ProcessFixpoint;

#############################################################################
##
#F  Refinements.Intersection( <O>, <strat> )  . . . . . . . . . . second type
##
InstallGlobalFunction(Refinements_Intersection,
function( rbase, image, Q, strat )
    local   t;

    if image.level2 = false  then  t := image.perm;
                             else  t := image.perm2;  fi;
    if IsSlicedPerm( t )  then
        t := ShallowCopy( t );
        SET_TYPE_COMOBJ( t, NewType( PermutationsFamily, IsSlicedPermInv ) );
    else
        t := t ^ -1;
    fi;
    return MeetPartitionStrat( rbase, image, Q, t, strat );
end);
Refinements.(STBBCKT_STRING_INTERSECTION) := Refinements_Intersection;

#############################################################################
##
#F  Refinements.Centralizer(<no>,<g>,<pnt>,<strat>) . P meet Pz for one point
##
InstallGlobalFunction(Refinements_Centralizer,
function( rbase, image, cellnum, g, pnt, strat )
    local   P,  img;

    P := image.partition;
    img := FixpointCellNo( P, cellnum ) ^ image.data[ g + 1 ];
    return     IsolatePoint( P, img ) = strat
           and ProcessFixpoint( image, pnt, img );
end);
Refinements.(STBBCKT_STRING_CENTRALIZER) := Refinements_Centralizer;

#############################################################################
##
#F  Refinements._MakeBlox( <rbase>, <image>, <len> )  . . . . . . . make blox
##
InstallGlobalFunction(Refinements__MakeBlox,
function( rbase, image, len )
    local   F;

    F := image.data[ 2 ];
    image.data[ 4 ] := Partition( Blocks( F, rbase.domain,
                               image.bimg{ [ 1, len ] } ) );
    return Collected( rbase.blox.lengths ) =
           Collected( image.data[ 4 ].lengths );
end);
Refinements.(STBBCKT_STRING_MAKEBLOX) := Refinements__MakeBlox;

#############################################################################
##
#F  Refinements.SplitOffBlock( <k>, <strat> ) . . . . . . . . split off block
##
InstallGlobalFunction(Refinements_SplitOffBlock,
function( rbase, image, k, strat )
    local   B,  a,  orb;

    B   := image.data[ 4 ];
    a   := FixpointCellNo( image.partition, k );
    orb := Cell( B, CellNoPoint(B,a) );
    if Length( orb ) = Length( rbase.domain )  then
        return false;
    else
        return MeetPartitionStrat( rbase, image, orb, (),strat );
    fi;
end);
Refinements.(STBBCKT_STRING_SPLITOFF) := Refinements_SplitOffBlock;

#############################################################################
##
#F  Refinements._RegularOrbit1( <d>, <len> )  . . . . . . extend mapped orbit
##
##  Computes orbit and transversal `bF' for group <F>  = `data[6]' regular on
##  that orbit.
##
InstallGlobalFunction(Refinements__RegularOrbit1,
function( rbase, image, d, len )
    local   F,  trees;

    trees := image.data[ 5 ];
    if d = 1  then
        F := image.data[ 6 ];
        image.regorb := EmptyStabChain( [  ], One( F ), image.bimg[ d ] );
        AddGeneratorsExtendSchreierTree( image.regorb,
                GeneratorsOfGroup( F ) );
        if Length( image.regorb.orbit ) <> Length( rbase.regorb.orbit )  then
            return false;
        fi;
        trees[ d ] := EmptyStabChain( [  ], One( F ),
                              image.regorb.orbit[ 1 ] );
    else
        trees[ d ] := StructuralCopy( trees[ d - 1 ] );
        AddGeneratorsExtendSchreierTree( trees[ d ],
          [ QuickInverseRepresentative
            ( image.regorb, image.bimg[ d ] ) ^ -1 ] );
        if Length( trees[ d ].orbit ) <> len  then
            return false;
        fi;
    fi;
    return true;
end);
Refinements.(STBBCKT_STRING_REGORB1) := Refinements__RegularOrbit1;

#############################################################################
##
#F  Refinements.RegularOrbit2( <d>, <orb>, <strat> )  . . . meet mapped orbit
##
##  Compute images `bhg' of `bh' under  $g$ in `trees[<d>].orbit = bE$ ($h\in
##  E$).
##  Entries in <strat> have the following meaning:
##    [i,j] means  that the image `bhg\in  P[j]' of  `bh  = orb[<i>]'  can be
##          calculated from `bg'.
##   [-p,j] means that fixpoint <p> was mapped to fixpoint in `P[j]',
##          i.e., `P[j]' has become a one-point cell.
##
InstallGlobalFunction(Refinements_RegularOrbit2,
function( rbase, image, d, orbit, strat )
    local   P,  trees,  orb,  i;

    P     := image.partition;
    trees := image.data[ 5 ];
    orb   := trees[ d ].orbit;
    for i  in strat  do
        if (   i[ 1 ] < 0
           and not ProcessFixpoint( image, -i[1], FixpointCellNo(P,i[2]) ) )
        or (   i[ 1 ] > 0
           and (    IsolatePoint( P, orb[ i[ 1 ] ] ) <> i[ 2 ]
                 or not ProcessFixpoint( image, orbit[i[1]], orb[i[1]] ) ) )
           then  return false;
        fi;
    od;
    return true;
end);
Refinements.(STBBCKT_STRING_REGORB2) := Refinements_RegularOrbit2;

#############################################################################
##
#F  Refinements.RegularOrbit3( <f>, <strat> ) . . . . .  find images of orbit
##
##  Register images `yhg' of `yh' under $g$ in an arbitrary orbit `yE' ($h\in
##  E$). `yg\in P[f]' is a one-point cell.
##  Entries in <strat> have the following meaning:
##    [yh,i,j] means that  the image `yhg\in P[j]' of  `yh' can be calculated
##             from `yg' and `bhg\in P[i]' (a one-point cell).
##      [-p,j] means that fixpoint <p> was mapped to fixpoint in `P[j]',
##             i.e., `P[j]' has become a one-point cell.
##
InstallGlobalFunction(Refinements_RegularOrbit3,
function( rbase, image, f, strat )
    local   P,  yg,  bhg,  hg,  yhg,  i;

    P   := image.partition;
    yg  := FixpointCellNo( P, f );
    for i  in strat  do
        if i[ 1 ] < 0  then
            if not ProcessFixpoint( image, -i[1], FixpointCellNo(P,i[2]) )
               then
                return false;
            fi;
        else
            bhg := FixpointCellNo( P, i[ 2 ] );
            hg  := InverseRepresentativeWord( image.regorb, bhg );
            yhg := PreImageWord( yg, hg );
            if    IsolatePoint( P, yhg ) <> i[ 3 ]
               or not ProcessFixpoint( image, i[ 1 ], yhg )  then
                return false;
            fi;
        fi;
    od;
    return true;
end);
Refinements.(STBBCKT_STRING_REGORB3) := Refinements_RegularOrbit3;

#############################################################################
##
#F  Refinements.Suborbits0( <tra>, <f>, <lens>, <byLen>, <strat> ) subdegrees
##
##  Computes   suborbits of the stabilizer in   <F> =  `image.data[2]' of the
##  fixpoint in cell no. <f>.  (If <F> is multiply  transitive, replace it by
##  the stabilizer of the first <tra>-1 images of R-base points.)
##
##  Returns `true' if (1)~the  list  of suborbit lengths (subdegrees)  equals
##  <lens>, (2)~the list of subdegree  frequencies equals <byLen> and (3)~the
##  meet  with  the  partition  into unions   of   suborbits of equal  length
##  succeeds.
##
InstallGlobalFunction(Refinements_Suborbits0,
function( rbase, image, tra, f, lens, byLen, strat )
    local   F,  pnt,  subs;

    F    := image.data[ 2 ];
    pnt  := FixpointCellNo( image.partition, f );
    subs := Suborbits( F, image.bimg{ [ 1 .. tra - 1 ] }, pnt,
                    rbase.domain );
    if    subs.lengths <> lens
       or List( subs.byLengths, Length ) <> byLen  then
        return false;
    else
        return MeetPartitionStrat( rbase, image, subs.partition, subs.conj,
                       strat );
    fi;
end);
Refinements.(STBBCKT_STRING_SUBORBITS0):=Refinements_Suborbits0;

#############################################################################
##
#F  Refinements.Suborbits1( <rbase>, <image>, <tra>, <f>, <k>, <strat> )  . .
##
##  Meets  the  image partition with the  orbital  partition of the  union of
##  orbital graphs of suborbits of length `subs.byLengths[ <k> ]'. (<tra> and
##  <f> as in `Suborbits0'.)
##
InstallGlobalFunction(Refinements_Suborbits1,
function( rbase, image, tra, f, k, strat )
    local   F,  pnt,  subs,  Q;

    F    := image.data[ 2 ];
    pnt  := FixpointCellNo( image.partition, f );
    subs := Suborbits( F, image.bimg{ [ 1 .. tra - 1 ] }, pnt,
                    rbase.domain );
    Q := OrbitalPartition( subs, subs.byLengths[ k ] );
    return MeetPartitionStrat( rbase, image, Q, subs.conj, strat );
end);
Refinements.(STBBCKT_STRING_SUBORBITS1) := Refinements_Suborbits1;

#############################################################################
##
#F  Refinements.Suborbits2( <rbase>, <image>, <tra>, <f>, <start>, <coll> ) .
##
##  Computes  for each suborbit the  intersection sizes with cells <start> or
##  more in the image partition. Stores the  result in `data[3]' (needed only
##  on this level,  hence no  '_'). Returns  `true'  if the collected  result
##  equals <coll>.
##
InstallGlobalFunction(Refinements_Suborbits2,
function( rbase, image, tra, f, start, coll )
    local   F,  types,  pnt,  subs,  i, k;

    F    := image.data[ 2 ];
    pnt  := FixpointCellNo( image.partition, f );
    subs := Suborbits( F, image.bimg{ [ 1 .. tra - 1 ] }, pnt,
                    rbase.domain );
    if start = 1  then
        image.data[ 3 ] := List( subs.blists, o -> [ -SuboSiBli( o ) ] );
    fi;
    types := image.data[ 3 ];
    for i  in [ start .. NumberCells( image.partition ) ]  do
        for k  in Set( subs.which
          { OnTuples( Cell( image.partition, i ), subs.conj ) } )  do
            AddSet( types[ k ], i );
        od;
    od;
    return Collected( types ) = coll;
end);
Refinements.(STBBCKT_STRING_SUBORBITS2) := Refinements_Suborbits2;

#############################################################################
##
#F  Refinements.Suborbits3( <rbase>, <image>, <tra>, <f>, <typ>, <strat> )  .
##
##  Meets  the image  partition with  the orbital partition   of the union of
##  orbital  graphs of suborbits of type  <typ>. Returns `false' if there are
##  not <many> of them. (<tra> and <f> as in `Suborbits0'.)
##
InstallGlobalFunction(Refinements_Suborbits3,
function( rbase, image, tra, f, typ, many, strat )
    local   F,  types,  pnt,  subs,  k,  Q;

    F     := image.data[ 2 ];
    types := image.data[ 3 ];
    pnt   := FixpointCellNo( image.partition, f );
    subs  := Suborbits( F, image.bimg{ [ 1 .. tra - 1 ] }, pnt,
                     rbase.domain );
    k := Filtered( [ 1 .. subs.sublilen ], k -> types[ k ] = typ );
    if Length( k ) <> many  then
        return false;
    else
        Q := OrbitalPartition( subs, k );
        return MeetPartitionStrat( rbase, image, Q, subs.conj, strat );
    fi;
end);
Refinements.(STBBCKT_STRING_SUBORBITS3) := Refinements_Suborbits3;

#############################################################################
##
#F  Refinements.TwoClosure( <G>, <Q>, <d>, <strat> )  . . . . . . two-closure
##
InstallGlobalFunction(Refinements_TwoClosure,
function( rbase, image, G, f, Q, strat )
    local   pnt,  t;

    pnt := FixpointCellNo( image.partition, f );
    t   := InverseRepresentative( rbase.suborbits.stabChainTop, pnt );
    return MeetPartitionStrat( rbase, image, Q, t, strat );
end);
Refinements.(STBBCKT_STRING_TWOCLOSURE):=Refinements_TwoClosure;


#############################################################################
##
#F  NextLevelRegularGroups( <P>, <rbase> )  . . . . . . . . . . . . . . local
##
InstallGlobalFunction( NextLevelRegularGroups, function( P, rbase )
    local   d,  b,  gen,  tree,  strat,  i,  j,  p,
            S,  f,  y,  yh,  h,  bh,  fix;

    d := Length( rbase.base ) + 1;
    p := fail;

    # All images of  a regular orbit are  known if $s$  are known  (where the
    # regular group has $s$ generators). See sec. 3.7  of my thesis, read `b'
    # for `\omega'.
    if d = 1  then
        p := rbase.regorb.orbit[ 1 ];
        RegisterRBasePoint( P, rbase, p );
        rbase.trees := [ EmptyStabChain( [  ], rbase.regorb.identity, p ) ];
        AddRefinement( rbase, STBBCKT_STRING_REGORB1, [ d, 1 ] );
    else
        tree := rbase.trees[ Length( rbase.trees ) ];
        if Length( tree.orbit ) < Length( rbase.regorb.orbit )  then
            p := PositionProperty( rbase.regorb.orbit, q ->
                         P.lengths[ CellNoPoint(P,q) ] <> 1
                     and (    IsInt( rbase.level )
                           or not IsFixedStabilizer( rbase.level, q ) ) );
            if p <> fail  then
                b := rbase.regorb.orbit[ p ];
                RegisterRBasePoint( P, rbase, b );
                gen := QuickInverseRepresentative( rbase.regorb, b ) ^ -1;
                tree := StructuralCopy( tree );
                AddGeneratorsExtendSchreierTree( tree, [ gen ] );
                AddRefinement( rbase, STBBCKT_STRING_REGORB1,
                        [ d, Length( tree.orbit ) ] );
                strat := [  ];
                for i  in [ 1 .. Length( tree.orbit ) ]  do
                    j := IsolatePoint( P, tree.orbit[ i ] );
                    if j <> false  then
                        ProcessFixpoint( rbase, tree.orbit[ i ] );
                        Add( strat, [ i, j ] );
                        if P.lengths[ j ] = 1  then
                            p := FixpointCellNo( P, j );
                            ProcessFixpoint( rbase, p );
                            Add( strat, [ -p, j ] );
                        fi;
                    fi;
                od;
                Add( rbase.trees, tree );
                AddRefinement( rbase, STBBCKT_STRING_REGORB2,
                        [ d, tree.orbit, strat ] );
            fi;
        fi;
    fi;
    if p = fail  then
        NextRBasePoint( P, rbase );
    fi;

    # If the image of a point is known, the image of its <E>-orbit is known.
    # See sec. 3.7 of my thesis, read `y' for `\gamma'.
    fix := Set( CellNoPoints(P,rbase.regorb.orbit));
    f := FixcellPoint( P, fix );
    while f <> false  do
        y := FixpointCellNo( P, f );
        S := EmptyStabChain( [  ], rbase.regorb.identity, y );
                           # ^ rbase.regorb.labels
        AddGeneratorsExtendSchreierTree( S, rbase.regorb.generators );
        UniteSet(fix,CellNoPoints(P,S.orbit));
        strat := [  ];
        for yh  in S.orbit  do
            h := InverseRepresentativeWord( S, yh );
            bh := PreImageWord( rbase.regorb.orbit[ 1 ], h );
            i := CellNoPoint(P,bh);
            if P.lengths[ i ] = 1  then
                j := IsolatePoint( P, yh );
                if j <> false  then
                    ProcessFixpoint( rbase, yh );
                    Add( strat, [ yh, i, j ] );
                    if P.lengths[ j ] = 1  then
                        p := FixpointCellNo( P, j );
                        ProcessFixpoint( rbase, p );
                        Add( strat, [ -p, j ] );
                    fi;
                fi;
            fi;
        od;
        AddRefinement( rbase, STBBCKT_STRING_REGORB3, [ f, strat ] );
        f := FixcellPoint( P, fix );
    od;

end );

BindGlobal("STBCTEARNS",function(G,Omega)
  G:=Earns(G,Omega);
  if Length(G)=0 then return fail;
  elif Length(G)=1 then return G[1];
  else Error("more than one Earns");fi;
end);

#############################################################################
##
#F  RBaseGroupsBloxPermGroup( ... ) . . . . .  opr. on groups respecting blox
##
InstallGlobalFunction( RBaseGroupsBloxPermGroup, function( repr, G, Omega, E, div, B )
    local  rbase,      # the R-base for the backtrack algorithm
           order,max,L,# order in which to process the base points
                 min,l,#
           n,          # degree of <G>
           reg,  orbs, # regular subgroup of <E> or `false'
           doneblox,   # blox already considered
           doneroot,   # roots of orbital graphs already considered
           tra,        # degree of transitivity of <E>
           cp,
           len,  i;

    # If  <E>  is a multiply  transitive  subgroup  of  <G>, consider orbital
    # graphs of the first non 2-transitive stabilizer.
    tra := Transitivity( E, Omega );
    if tra = 0  then
        tra := 1;
    elif tra > 1  then
        Info( InfoBckt, 1, "Subgroup is ", tra, "-transitive" );
    fi;

    # Find the order in which to process the points in the base choice.
    if NumberCells( B ) = 1  then
        order := false;
    else
        n := Length( Omega );
        max := 0;  min := infinity;  i := 0;
        while i < NumberCells( B )  do
            i := i + 1;  len := B.lengths[ i ];
            if len > max  then  max := len;  L := i;  fi;
            if len < min  then  min := len;  l := i;  fi;
        od;
        order := Maximum( List( GeneratorsOfGroup( E ), Order) );
        if 2 * order < n  then  order := Cell( B, l );
                          else  order := Cell( B, L );  fi;
    fi;

    # Construct an  R-base. Start with  the partition into  <G>-orbits on the
    # cells of <B>. In the normalizer  case, only the factor group $N_G(E)/E$
    # acts on the cells.
    rbase := EmptyRBase( G, Omega, CollectedPartition( B, div ) );
    rbase.suborbits := [  ];

    if NumberCells( B ) = 1  then  rbase.blox := false;
                             else  rbase.blox := B;      fi;

    # See if <E> has a regular orbit or is affine.
    orbs := OrbitsDomain( E, Omega );
    reg := PositionProperty( orbs, orb -> Length( orb ) = Size( E ) );
    if reg <> fail  then
        Info( InfoBckt, 1, "Subgroup has regular orbit" );
        rbase.reggrp := function( E, Omega )  return E;  end;
        rbase.regorb := EmptyStabChain( [  ], One( E ),
                                orbs[ reg ][ 1 ] );
        AddGeneratorsExtendSchreierTree( rbase.regorb,
                GeneratorsOfGroup( E ) );
    elif IsPrimitive( E, Omega )  then
        reg := STBCTEARNS( E, Omega );
        if reg <> fail  then
            Info( InfoBckt, 1, "Subgroup is affine" );
            rbase.reggrp := STBCTEARNS;
            rbase.regorb := EmptyStabChain( [  ], One( reg ),
                                    Omega[ 1 ] );
            AddGeneratorsExtendSchreierTree( rbase.regorb,
                    GeneratorsOfGroup( reg ) );
        fi;
    fi;

    doneblox := [  ];
    doneroot := [  ];

    rbase.nextLevel := function( P, rbase )
        local   len,   Q, strat,  orb,  f,  fpt,  subs,  k,  i,
                start,  oldstart,  types,  typ,  coll,  pnt,  done;

        if reg <> fail  then  NextLevelRegularGroups( P, rbase );
                        else  NextRBasePoint( P, rbase, order );   fi;
        len := Length( rbase.base );
        if len >= tra  then

            # For each  fixpoint  in   <P>,  consider  the orbits    of   its
            # stabilizer.
            f := FixcellPoint( P, doneroot );
            while f <> false  do
              fpt := FixpointCellNo( P, f );
              subs := Suborbits( E, rbase.base{ [ 1 .. tra - 1 ] },
                                fpt, Omega );

              # `Suborbits0' computes and  meets the partition into unions of
              # suborbits of equal length.
              strat := StratMeetPartition( rbase, P, subs.partition,
                               subs.conj );
              AddRefinement( rbase, STBBCKT_STRING_SUBORBITS0,
                     [ tra, f, subs.lengths,
                      List( subs.byLengths, Length ), strat ] );

              # For each such   length, `Suborbits1' computes  and  meets the
              # `OrbitalPartition' of the   union of orbital  graphs for  the
              # suborbits of  that  length  (only   if there are  less   than
              # sqrt(subdegree) many and if they are  in the component of the
              # root).
              for k  in [ 1 .. Length( subs.byLengths ) ]  do
                  if Length( subs.byLengths[ k ] ) ^ 2
                   < subs.sublilen
                 and subs.reps[ subs.byLengths[ k ][ 1 ] ] <> false  then
                      strat := StratMeetPartition( rbase, P,
                        OrbitalPartition( subs, subs.byLengths[ k ] ),
                        subs.conj );
                      AddRefinement( rbase, STBBCKT_STRING_SUBORBITS1,
                              [ tra, f, k, strat ] );
                      if IsTrivialRBase( rbase )  then
                          return;
                      fi;
                  fi;
              od;

              # Find   the types of the suborbits,   i.e., the sizes of their
              # intersections with the cells of <P>.
              if LARGE_TASK  then  start := NumberCells( P ) + 1;
                             else  start := 1;  oldstart := 1;     fi;
              types := List( subs.blists, o -> [ -SuboSiBli( o ) ] );
              done := Set( subs.byLengths );
              while start <= NumberCells( P )  do

                # Do not  consider a cell number  in <P> twice (consider only
                # cell numbers between <oldstart> and <start>).
                for i  in [ start .. NumberCells( P ) ]  do
                    for k  in Set( subs.which
                              { OnTuples( Cell( P, i ), subs.conj ) } )  do
                        AddSet( types[ k ], i );
                    od;
                od;
                coll := Collected( StructuralCopy( types ) );
                start := NumberCells( P ) + 1;

                # For each type, consider the `OrbitalPartition' of the union
                # of orbital graphs of that type.
                for typ  in coll  do
                  k := Filtered( [ 1 .. subs.sublilen ],
                         k -> types[ k ] = typ[ 1 ] );
                  if not k in done  then
                    AddSet( done, k );
                    strat := StratMeetPartition( rbase, P,
                                OrbitalPartition( subs, k ),
                                subs.conj );
                    if Length( strat ) <> 0  then

                      # `Suborbits2' computes the types  in the image (stored
                      # in `data[3]') and compares them with <coll> (only for
                      # new cells between <oldstart> and <start>).
                      if oldstart < start  then
                        AddRefinement( rbase, STBBCKT_STRING_SUBORBITS2,
                                [ tra, f, oldstart, coll ] );
                        oldstart := start;
                      fi;

                      # `Suborbits3' computes and meets the orbital partition
                      # for the image.
                      AddRefinement( rbase, STBBCKT_STRING_SUBORBITS3,
                         [ tra, f, typ[ 1 ], Length( k ), strat ] );
                      if IsTrivialRBase( rbase )  then
                        return;
                      fi;
                    fi;
                  fi;
                od;

              od;

              # Orbital graphs rooted at a point from the same <E>-orbit seem
              # to yield no extra progress.
              for pnt  in Orbit( E, fpt )  do
                  cp:=CellNoPoint(P,pnt);
                  if P.lengths[cp] = 1  then
                      AddSet( doneroot, cp);
                  fi;
              od;

              f := FixcellPoint( P, doneroot );
            od;
        fi;

        # Construct a block system for <E>.
        if len > 1  and  rbase.blox = false  then
            Q := Blocks( E, rbase.domain, rbase.base{ [ 1, len ] } );
            if Length( Q ) <> 1  then
                rbase.blox := Partition( Q );
                AddRefinement( rbase, STBBCKT_STRING_MAKEBLOX, [ len ] );
            fi;
        fi;

        # Split off blocks whose images are known.
        if rbase.blox <> false  then
            k := FixcellsCell( P, rbase.blox, doneblox );
            while k <> false  do
                for i  in [ 1 .. Length( k[ 1 ] ) ]  do
                    orb := Cell( rbase.blox, k[ 1 ][ i ] );
                    if Length( orb ) <> Length( Omega )  then
                        strat := StratMeetPartition( rbase, P, orb );
                        AddRefinement( rbase, STBBCKT_STRING_SPLITOFF,
                                [ k[ 2 ][ i ], strat ] );
                        if IsTrivialRBase( rbase )  then
                            return;
                        fi;
                    fi;
                od;
                k := FixcellsCell( P, rbase.blox, doneblox );
            od;
        fi;

    end;

    return rbase;
end );

#############################################################################
##
#F  RepOpSetsPermGroup( <arg> ) . . . . . . . . . . . . . . operation on sets
##
InstallGlobalFunction( RepOpSetsPermGroup, function( arg )
    local   G,  Phi,  Psi,  repr,  Omega,  rbase,  L,  R,  P,  Q,  p,  Pr,
            i,phitail;

    G   := arg[ 1 ];
    Phi := Set( arg[ 2 ] );
    if Length( arg ) > 2  and  IsList( arg[ 3 ] )  then
        p := 3;
        Psi := Set( arg[ 3 ] );
        repr := true;
    else
        p := 2;
        Psi := Phi;
        repr := false;
    fi;

    Omega := MovedPoints( G );
    if repr  and  Length( Phi ) <> Length( Psi )  then
        return fail;
    fi;

    Psi:=Immutable(Set(Psi));

    # Special case if <Omega> is entirely inside or outside <Phi>.
    if IsSubset( Phi, Omega )  or  ForAll( Omega, p -> not p in Phi )  then
        if repr  then
            if Difference( Phi, Omega ) <> Difference( Psi, Omega )  then
                return fail;
            else
                return One( G );
            fi;
        else
            return G;
        fi;
    elif repr and
     ( IsSubset( Psi, Omega )  or  ForAll( Omega, p -> not p in Psi ) )  then
        return fail;
    fi;

    P := Partition( [ Intersection( Omega, Phi ),
                        Difference( Omega, Phi ) ] );
    if repr  then  Q := Partition( [ Intersection( Omega, Psi ),
                                       Difference( Omega, Psi ) ] );
             else  Q := P;                                            fi;

#    # Special treatment for the symmetric group.
#    if IsSymmetricGroupQuick( G )  then
#        if repr  then
#            return MappingPermListList( Phi, Psi );
#        else
#            gens := [  ];
#            for i  in [ 1 .. NumberCells( P ) ]  do
#                cell := Cell( P, i );
#                if Length( cell ) > 1  then
#                    Add( gens, ( cell[ 1 ], cell[ 2 ] ) );
#                    if Length( cell ) > 2  then
#                        Add( gens, MappingPermListList( cell,
#                                cell{ Concatenation( [ 2 .. Length( cell ) ],
#                                        [ 1 ] ) } ) );
#                    fi;
#                fi;
#            od;
#            return GroupByGenerators( gens, () );
#        fi;
#    fi;

    if Length( arg ) > p  then
        L := arg[ p + 1 ];
    else
        L:=SubgroupNC(G,
             Filtered(StrongGeneratorsStabChain(StabChainMutable(G)),
                     gen -> OnSets( Phi, gen ) = Phi ) );
    fi;
    if repr  then
        if Length( arg ) > p + 1  then
            R := arg[ p + 2 ];
        else
            R:=SubgroupNC(G,
                 Filtered(StrongGeneratorsStabChain(StabChainMutable(G)),
                          gen->OnSets(Psi,gen)=Psi));
        fi;
    else
        R := L;
    fi;

    # Construct an R-base.
    rbase := EmptyRBase( [ G, G ], Omega, P );
    rbase.nextLevel := NextRBasePoint;

    #Pr := gen -> IsSubsetSet( OnTuples( Phi, gen ), Psi );

    phitail:=Phi{[2..Length(Phi)]};
    Pr:=function(gen)
        local i;
          if not Phi[1]^gen in Psi then
            return false;
          fi;
          for i in phitail do
            if not i^gen in Psi then
              return false;
            fi;
          od;
          return true;
        end;

    # Pr := [ Phi, Psi, OnTuples, gen ->
    #         IsSubsetSet( gen!.lftObj, gen!.rgtObj ) ];
    return PartitionBacktrack( G, Pr, repr, rbase, [ Q ], L, R );
end );

#############################################################################
##
#F  RepOpElmTuplesPermGroup( <repr>, <G>, <e>, <f>, <L>, <R> )  on elm tuples
##
InstallGlobalFunction( RepOpElmTuplesPermGroup,
function( repr, G, e, f, L, R )
local  Omega,      # a common operation domain for <G>, <E> and <F>
        order,      # orders of elements in <e>
        cycles,     # cycles of <e> on <Omega>
        P, Q,       # partition refined during construction of <rbase>
        rbase,      # the R-base for the backtrack algorithm
        Pr,         # property
        baspts,     # base for group
        eran,       # range
        map,
        bailout,
        i,j, size; # loop/auxiliary variables

  # Central elements and trivial subgroups.
  if ForAll( GeneratorsOfGroup( G ), gen -> OnTuples( e, gen ) = e )  then
      if not repr  then  return G;
      elif e = f   then  return One( G );
                    else  return fail;      fi;
  fi;

  if repr and
      ( Length( e ) <> Length( f )  or  ForAny( [ 1 .. Length( e ) ],
              i -> CycleStructurePerm( e[ i ] ) <>
                  CycleStructurePerm( f[ i ] ) ) )  then
      return fail;
  fi;

  bailout:=repr;
  if IsTrivial(L) then
    L:=SubgroupNC(G,Filtered( Concatenation(
            Filtered(e,gen->gen in G),
            StrongGeneratorsStabChain(StabChainMutable(G))),
          gen->OnTuples(e,gen)=e));
  else
    bailout:=false;
  fi;

  if IsTrivial(R) then
    if repr then
      R:=SubgroupNC(G,Filtered( Concatenation(
            Filtered(f,gen->gen in G),
            StrongGeneratorsStabChain(StabChainMutable(G))),
          gen->OnTuples(f,gen)=f));

    else
      R:=L;
    fi;
  fi;

  Omega := MovedPoints( Concatenation( GeneratorsOfGroup( G ), e, f ) );

  P := TrivialPartition( Omega );
  if repr  then  size := 1;
            else  size := Size( G );  fi;
  for i  in [ 1 .. Length( e ) ]  do
      cycles := Partition( Cycles( e[ i ], Omega ) );
      StratMeetPartition( P, CollectedPartition( cycles, size ) );
  od;

  # Find the order in which to process the points in the base choice.
  #SortParallel( ShallowCopy( -cycles.lengths ), order );

  # The criterion for selection of base points is to select them according
  # to (descending) cycle length of the permutation to be conjugated. At the
  # moment no other criterion is used (though experiments can observe a
  # significant impact on run time -- there is work TODO).
  # Beyond this choice, the base point order is determined as a side effect
  # of the sorting algorithm.
  # To avoid particular configurations falling repeatedly into a bad case,
  # we permute the base points to obtain a random ordering beyond the
  # criterion used. This can be turned off through an option for debugging
  # purposes.
  if ValueOption("norandom")=true then
    i:=[1..Length(cycles.firsts)];
  else
    i:=FLOYDS_ALGORITHM(RandomSource(IsMersenneTwister),
         Length(cycles.firsts),false);
  fi;
  order := cycles.points{ cycles.firsts{i} };
  SortParallel( -(cycles.lengths{i}), order );

  repeat

    # Construct an R-base.
    rbase := EmptyRBase( G, Omega, P );

    # Loop over the stabilizer chain of <G>.
    rbase.nextLevel := function( P, rbase )
        local   fix,  pnt,  img,  g,  strat;

        NextRBasePoint( P, rbase, order );

        # Centralizer refinement.
        fix := Fixcells( P );
        for pnt  in fix  do
            for g  in [ 1 .. Length( e ) ]  do
                img := pnt ^ e[ g ];
                strat := IsolatePoint( P, img );
                if strat <> false  then
                    Add( fix, img );
                    ProcessFixpoint( rbase, img );
                    AddRefinement( rbase, STBBCKT_STRING_CENTRALIZER,
                            [ CellNoPoint(P,pnt), g, img, strat ] );
                    if P.lengths[ strat ] = 1  then
                        pnt := FixpointCellNo( P, strat );
                        ProcessFixpoint( rbase, pnt );
                        AddRefinement( rbase, "ProcessFixpoint",
                                [ pnt, strat ] );
                    fi;
                fi;
            od;
        od;
    end;

    if repr  then
        Q := TrivialPartition( Omega );
        for i  in [ 1 .. Length( f ) ]  do
            StratMeetPartition( Q, CollectedPartition( Partition
                    ( Cycles( f[ i ], Omega ) ), 1 ) );
        od;
    else
        Q := P;
    fi;

    #Pr:=gen -> gen!.lftObj = gen!.rgtObj;
    baspts:=BaseStabChain(StabChainMutable(G));
    if not (ForAll(e,i->i in G) and ForAll(f,i->i in G)) then
      baspts:=Union(baspts,MovedPoints(Concatenation(e,f)));
    fi;

    eran:=[1..Length(e)];
    Pr:=function(gen)
        local i,j;

          for i in eran do
            for j in baspts do
              if not ((j/gen)^e[i])^gen=j^f[i] then
                return false;
              fi;
            od;
          od;
          return true;
        end;

    map:=PartitionBacktrack( G, [ e, f, OnTuples,Pr],
                   repr, rbase, Concatenation( [ Q ], f ),
                   L, R:bailout:=bailout );
    if not (bailout and map=infinity) then
      return map;
    fi;
    Info(InfoBckt,1,"\n#I  ------\n#I  First compute new L");

    L:=G;
    for i in e do
      L:=Centralizer(L,i);
    od;
    bailout:=false;
    # go back as we need to build the base anew
  until false;

end );

#############################################################################
##
#F  ConjugatorPermGroup( <arg> )  . . . . isomorphism / conjugating element
##
InstallGlobalFunction( ConjugatorPermGroup, function( arg )
local G, E, F, L, R, mpG, mpE, mpF, map, Omega, P, orb, comb, found, pos,
dom, et, ft, Pr, rbase, BF, Q, data,lc;

    G := arg[ 1 ];
    E := arg[ 2 ];
    F := arg[ 3 ];
    if   Size( E ) <> Size( F )  then  return fail;
    elif IsTrivial( E )          then  return ();
    elif Size( E ) = 2  then
        if Length( arg ) > 3  then
            L := arg[ 4 ];  R := arg[ 5 ];
        else
            L := TrivialSubgroup( G );  R := L;
        fi;
        E := First( GeneratorsOfGroup( E ), gen -> Order( gen ) <> 1 );
        F := First( GeneratorsOfGroup( F ), gen -> Order( gen ) <> 1 );
        return RepOpElmTuplesPermGroup( true, G, [ E ], [ F ], L, R );
    elif IsCyclic(E) then
      # special case of cyclic groups
      if not IsCyclic(F) then return fail;fi;
      if Length( arg ) > 3  then
          L := arg[ 4 ];  R := arg[ 5 ];
      else
          L := TrivialSubgroup( G );  R := L;
      fi;
      E:=MinimalGeneratingSet(E)[1];
      F:=MinimalGeneratingSet(F)[1];
      Q:=Order(E);
      for pos in Filtered([1..Q],x->Gcd(x,Q)=1) do
        found:=RepOpElmTuplesPermGroup( true, G, [ E ], [ F^pos ], L, R );
        if found<>fail then return found;fi;
      od;
      return fail;
    fi;
    # `Suborbits' uses all points. (AH, 7/17/02)
    mpG:=MovedPoints(GeneratorsOfGroup(G));
    mpE:=MovedPoints(GeneratorsOfGroup(E));
    mpF:=MovedPoints(GeneratorsOfGroup(F));

    map:=false;
    Omega := [1..Maximum(Maximum(mpG),Maximum(mpE),Maximum(mpF))];

    if IsSubset(mpG,mpE) and IsSubset(mpG,mpF) and not IsTransitive(G,mpG) then
      # is there a chance to use only some orbits?
      if not (IsSubset(G,E) and IsSubset(G,F)) then
        P:=Group(Concatenation(GeneratorsOfGroup(G),
                               GeneratorsOfGroup(E),GeneratorsOfGroup(F)));
      else
        P:=G;
      fi;
      orb:=Orbits(P,mpG);
      if Length(orb)>7 then
        # join orbits to make only a few
        orb:=ShallowCopy(orb);
        SortBy(orb, Length);
        comb:=Union(orb{[7..Length(orb)]});
        orb:=Concatenation(orb{[1..6]},[comb]);
      fi;
      comb:=Combinations(orb);
      SortBy(comb,a->Sum(a,Length));
      found:=false;
      pos:=0; # pos1 is empty
      lc:=Length(mpG)*2/3;
      while pos<Length(comb) and not found and pos<=Length(comb) do
        pos:=pos+1;
        if Sum(comb[pos],Length)<lc then
          dom:=Union(comb[pos]);
          if Size(Stabilizer(P,dom,OnTuples))=1 then
            # found faithful
            found:=true;
          fi;
        fi;
      od;
      if found then
        map:=ActionHomomorphism(P,dom,"surjective");
        SetIsInjective(map,true);
        G:=Image(map,G);
        E:=Image(map,E);
        F:=Image(map,F);
        Omega:=[1..Length(dom)];
      fi;
    fi;

    # test whether we have a chance mapping the groups (as their orbits fit
    # together)
    if Collected(List(OrbitsDomain(E,Omega),Length))<>
       Collected(List(OrbitsDomain(F,Omega),Length)) then
      return fail;
    fi;

    # The test uses special condition if primitive, thus rule out different
    # transitivity/primitivity first.
    if not IsIdenticalObj(E,F) then
      et:=IsTransitive(E,Omega);
      ft:=IsTransitive(F,Omega);
      if et<>ft then
        return fail;
      elif et and IsPrimitive(E,Omega)<>IsPrimitive(F,Omega) then
        return fail;
      fi;
    fi;

    Pr := gen -> ForAll( GeneratorsOfGroup( E ), g -> g ^ gen in F );
    if Length( arg ) > 3  then
      L := arg[ Length( arg ) - 1 ];
      R := arg[ Length( arg ) ];
      if map<>false then
        L:=Image(map,L);
        R:=Image(map,R);
      fi;
    elif IsSubset( G, E )  then
        L := E;
        if IsSubset( G, F )  then  R := F;
                             else  return fail;  fi;
    else
        L := TrivialSubgroup( G );
        R := TrivialSubgroup( G );
    fi;

    rbase := RBaseGroupsBloxPermGroup( true, G, Omega,
                     E, 1, OrbitsPartition( E, Omega ) );
    BF := OrbitsPartition( F, Omega );
    Q := CollectedPartition( BF, 1 );
    data := [ Q, F, [  ], BF, [  ] ];
    if IsBound( rbase.reggrp )  then
      P:=rbase.reggrp( F, Omega );
      if P=fail then
        # the first group has an EARNS, the second not.
        return fail;
      fi;
      Add( data, P );
    fi;

    found:=PartitionBacktrack( G, Pr, true, rbase, data, L, R );
    if IsPerm(found) and map<>false then
      found:=PreImagesRepresentative(map,found);
    fi;
    return found;
end );

#############################################################################
##
#F  NormalizerPermGroup( <arg> ) . . . automorphism group / normalizer
##

# the backtrack call
BindGlobal("DoNormalizerPermGroup",function(G,E,L,Omega)
local Pr, div, B, rbase, data, N;

  Pr := gen -> ForAll( GeneratorsOfGroup( E ), g -> g ^ gen in E );
  if not (IsTrivial( G ) or IsTrivial(E)) then
    if IsSubset( G, E )  then
      div := SmallestPrimeDivisor( Index( G, E ) );
    else
      div := SmallestPrimeDivisor( Size( G ) );
    fi;
    if Length(MovedPoints(G))>Size(G) and Length(MovedPoints(G))>500 then
      return SubgroupProperty(G,
        i->ForAll(GeneratorsOfGroup(E),j->j^i in E));
    fi;
    B := OrbitsPartition( E, Omega );
    rbase := RBaseGroupsBloxPermGroup( false, G, Omega, E, div, B );
    data := [ true, E, [  ], B, [  ] ];
    if IsBound( rbase.reggrp )  then
      Add( data, rbase.reggrp( E, Omega ) );
    fi;
    N := PartitionBacktrack( G, Pr, false, rbase, data, L, L );
  else
    N := ShallowCopy( G );
  fi;
  # remove cached information
  G!.suborbits:=[];
  E!.suborbits:=[];

  # bring the stabilizer chains back into a decent form
  ReduceStabChain(StabChainMutable(G));
  ReduceStabChain(StabChainMutable(E));
  ReduceStabChain(StabChainMutable(N));

  return N;
end );

InstallGlobalFunction( NormalizerPermGroup, function( arg )
local G, E, L, issub, mpG, mpE, cnt, P, Omega, orb, i, start, so, hom, Gh,
Eh, Lh, Nh,G0;

  G := arg[ 1 ];
  E := arg[ 2 ];
  G!.suborbits:=[]; # in case any remained from interruption
  E!.suborbits:=[];
  if IsTrivial( E ) or IsTrivial( G ) then
      return G;
  elif Size( E ) = 2  then
    if Length( arg ) > 2  then  L := arg[ 3 ];
                          else  L := TrivialSubgroup( G );  fi;
    E := [ First( GeneratorsOfGroup( E ),
                  gen -> Order( gen ) <> 1 ) ];
    return RepOpElmTuplesPermGroup( false, G, E, E, L, L );
  fi;

  if   Length( arg ) = 3  then
    L := arg[ 3 ];
    issub:=fail;
  elif IsSubset( G, E )   then
    if Size(G)=Size(E) then
      return G;
    fi;
    L := E;
    issub:=true;
  else
    L := TrivialSubgroup( G );
    issub:=false;;
  fi;

  if issub and HasFittingFreeLiftSetup(G) and NrMovedPoints(G)>1000
    # radical is at lest 3rd root of |G| -- avoid smallish radical
    and Size(FittingFreeLiftSetup(G).radical)^3>Size(G) then
    return NormalizerViaRadical(G,E);
  fi;

  mpG:=MovedPoints(GeneratorsOfGroup(G));
  mpE:=MovedPoints(GeneratorsOfGroup(E));
  if IsSubset(mpG,mpE) and not IsTransitive(G,mpG) then
    cnt:=0;
    if issub=false then
      issub:=IsSubset(G,E);
    fi;
    G0:=G;
    if issub then
      P:=G;
    else
      P:=Group(Concatenation(GeneratorsOfGroup(G), GeneratorsOfGroup(E)));
    fi;
    Omega:=ShallowCopy(mpG);

    while Length(Omega)>0
      # it is not unlikely that some orbits suffice. Thus we can just stop
      # then
      and not IsNormal(G,E) do

      orb:=ShallowCopy(Orbits(P,Omega));
      SortBy(orb,Length);
      i:=1;
      while i<=Length(orb) and Length(orb[i])=1 do
        Omega:=Difference(Omega,orb[i]);
        i:=i+1;
      od;
      if i<=Length(orb) then
        start:=i;
        cnt:=Length(orb[i]);
        i:=i+1;
        # don't bother with very short orbits -- they will give little
        # improvement.
        while i<=Length(orb) and cnt+Length(orb[i])<10 do
          cnt:=cnt+Length(orb[i]);
          i:=i+1;
        od;
        if cnt=Length(mpG) then
          # no orbits...
          Omega := [1..Maximum(Maximum(mpG),Maximum(mpE))];
          return DoNormalizerPermGroup(G,E,L,Omega);
        fi;
        so:=Union(orb{[start..i-1]});

        hom:=ActionHomomorphism(P,so,"surjective");
        Gh:=Image(hom,G);
        Eh:=Image(hom,E);
        Lh:=Image(hom,L);
        Nh:=DoNormalizerPermGroup(Gh,Eh,Lh,[1..Length(so)]);
        if Size(Nh)<Size(Gh) then
          # improvement!
          if not IsIdenticalObj(P,G) then
            P:=PreImage(hom,ClosureGroup(Nh,Eh));
          fi;
          G:=PreImage(hom,Nh);
          Info(InfoGroup,1,"Orbit ",Length(so)," reduces by ",Size(Gh)/Size(Nh));
        fi;
        Omega:=Difference(Omega,so);
      fi;
    od;

    if not issub then
      G:=Intersection(G,G0);
    fi;

    if Length(Omega)=0 and not IsNormal(G,E) then
      # we ran through all orbits and did not stop early because everything
      # normalized. We thus have to test the normalization on all orbits
      Nh:=DoNormalizerPermGroup(G,E,L,mpG);
      Info(InfoGroup,1,"Union reduces by ",Size(G)/Size(Nh));
    else
      Nh:=G; # we know that G normalizes
    fi;
    Assert(3,Nh=DoNormalizerPermGroup(G,E,L,
                  [1..Maximum(Maximum(mpG),Maximum(mpE))]));
    return Nh;

  else
    # `Suborbits' uses all points. (AH, 7/17/02)
    Omega := [1..Maximum(Maximum(mpG),Maximum(mpE))];
    return DoNormalizerPermGroup(G,E,L,Omega);
  fi;
end);

InstallMethod( NormalizerOp,"perm group", IsIdenticalObj,
  [ IsPermGroup, IsPermGroup ], 0,
        NormalizerPermGroup );

# this circumvents the FOA mechanism which got changed and does not permit
# three arguments any longer.
InstallOtherMethod( Normalizer,"perm group", true,
  [ IsPermGroup, IsPermGroup,IsPermGroup ], 0,
        NormalizerPermGroup );

#############################################################################
##
#F  ElementProperty( <G>, <Pr> [, <L> [, <R> ] ] )  one element with property
##
InstallGlobalFunction( ElementProperty, function( arg )
    local  G,  Pr,  L,  R,  Omega,  rbase,  P;

    # Get the arguments.
    G  := arg[ 1 ];
    Pr := arg[ 2 ];
    if Length( arg ) > 2  then  L := arg[ 3 ];
                          else  L := TrivialSubgroup( G );  fi;
    if Length( arg ) > 3  then  R := arg[ 4 ];
                          else  R := TrivialSubgroup( G );  fi;

    # Treat the trivial case.
    if IsTrivial( G )  then
        if Pr( One( G ) )  then  return One( G );
                           else  return fail;      fi;
    fi;

    # Construct an R-base.
    Omega := MovedPoints( G );
    P := TrivialPartition( Omega );
    rbase := EmptyRBase( G, Omega, P );
    rbase.nextLevel := NextRBasePoint;

    return PartitionBacktrack( G, Pr, true, rbase, [ P ], L, R );
end );

#############################################################################
##
#F  SubgroupProperty( <G>, <Pr> [, <L> ] )  . . . . . . . fulfilling subgroup
##
InstallGlobalFunction( SubgroupProperty, function( arg )
    local  G,  Pr,  L,  Omega,  rbase,  P;

    # Get the arguments.
    G  := arg[ 1 ];
    Pr := arg[ 2 ];
    if Length( arg ) > 2  then  L := arg[ 3 ];
                          else  L := TrivialSubgroup( G );  fi;

    # Treat the trivial case.
    if IsTrivial( G )  then
        return G;
    fi;

    # Construct an R-base.
    Omega := MovedPoints( G );
    P := TrivialPartition( Omega );
    rbase := EmptyRBase( G, Omega, P );
    rbase.nextLevel := NextRBasePoint;

    return PartitionBacktrack( G, Pr, false, rbase, [ P ], L, L );
end );


#############################################################################
##
#M  PartitionStabilizerPermGroup(<G>,<part>)
##
##  This really should be a backtrack on its own
InstallGlobalFunction( PartitionStabilizerPermGroup, function(G,part)
local pl,single,i,p,W,op,S;

  # first separate the sets of different lengths
  pl:=Set(part,Length);
  single:=[];
  for i in [1..Length(pl)] do
    pl[i]:=Filtered(part,j->Length(j)=pl[i]);
    Add(single,Set(Concatenation(pl[i])));
  od;
  SortBy(single,Length);
  for i in single do
    G:=Stabilizer(G,i,OnSets);
  od;

  # now pl is a list of lists of sets of the same length, sorted in
  # ascending size.

  # stabilize the partitioning among sets of the same length
  for p in pl do
    # the trivial partitions are always stabilized.
    if Length(p)>1 and Length(p[1])>1 then
      # the stabilizer is the set of all elements that map every set from p into
      # another set from p.
      # as a subgroup of the stabilizer compute the stabilizer on set tuples
      S:=G;
      for i in p do
        if ForAny(GeneratorsOfGroup(S),j->OnSets(i,j)<>j) then
          S:=Stabilizer(S,i,OnSets);
          #Info(InfoPermGroup,1,i," ",Size(S),"\n");
        fi;
      od;
      G:=Normalizer(G,S);

      # If S is trivial (or acts too small) things could still go wrong:
      if not ForAll(GeneratorsOfGroup(G),i->ForAll(p,j->OnSets(j,i) in p)) then
        # the stabilizer of p in S_n is a wreath product of symmetric groups
        # (It seems that computing the intersection is better than the
        # `SubgroupProperty' call commented out below, as `Intersection' uses
        # better refinements internally.
        op:=ActionHomomorphism(G,Concatenation(p),"surjective"); #makes the blocks standard
        W:=WreathProduct(SymmetricGroup(Length(p[1])),
             SymmetricGroup(Length(p)));
        if Size(W)<10^50 then
          W:=Intersection(W,Image(op,G)); # the stabilizer
          G:=PreImage(op,W);
        else

          # because we want to keep the set property, we make p immutable
          p:=Immutable(Set(p));
          # the stabilizer is the set of all elements that map every set from
          # p into another set from p.  as a subgroup of the stabilizer
          # compute the stabilizer on set tuples
          S:=G;
          for i in p do
            S:=Stabilizer(S,i,OnSets);
          od;

          G:=SubgroupProperty(G,function(gen)
                                local i;
                                  for i in p do
                                    if not OnSets(i,gen) in p then
                                      return false;
                                    fi;
                                  od;
                                  return true;
                                end,
                                S);
        fi;
      fi;
    fi;
  od;
  return G;

end );


#############################################################################
##
#M  Centralizer( <G>, <e> ) . . . . . . . . . . . . . . in permutation groups
##
InstallMethod( CentralizerOp, "perm group,elm",IsCollsElms,
  [ IsPermGroup, IsPerm ], 0,
    function( G, e )
    e := [ e ];
    return RepOpElmTuplesPermGroup( false, G, e, e,
                   TrivialSubgroup( G ), TrivialSubgroup( G ) );
end );

InstallMethod( CentralizerOp, "perm group, perm group", IsIdenticalObj,
  [ IsPermGroup, IsPermGroup ], 0,
    function( G, E )
    return RepOpElmTuplesPermGroup( false, G,
                   GeneratorsOfGroup( E ), GeneratorsOfGroup( E ),
                   TrivialSubgroup( G ), TrivialSubgroup( G ) );
end );

# this circumvents the FOA mechanism which got changed and does not permit
# three arguments any longer.
InstallOtherMethod( Centralizer, "with given subgroup", true,
        [ IsPermGroup, IsPerm, IsPermGroup ], 0,
    function( G, e, U )
    e := [ e ];
    return RepOpElmTuplesPermGroup( false, G, e, e, U, U );
end );

#############################################################################
##
#M  Intersection( <G>, <H> )  . . . . . . . . . . . . . of permutation groups
##
InstallMethod( Intersection2, "perm groups", IsIdenticalObj,
  [ IsPermGroup, IsPermGroup ], 0,
function( G, H )
local   omega, P, rbase, L, mg, mh, mg_minus_mh, mh_minus_mg;

    if IsIdenticalObj( G, H )  then
      return G;
    fi;

    # iterate taking stabilizer until G and H have the same set of moved points
    while true do
      # align the acting domains
      mg:=MovedPoints(G);
      mh:=MovedPoints(H);
      omega := Intersection(mg,mh);

      # no two points moved in common?
      if Length(omega)<=1 then
        return TrivialGroup(IsPermGroup);
      fi;

      mg_minus_mh:=Difference(mg,mh);
      if Length(mg_minus_mh) > 0 then
        G:=Stabilizer(G,mg_minus_mh,OnTuples);
        continue;
      fi;
      mh_minus_mg:=Difference(mh,mg);
      if Length(mh_minus_mg) > 0 then
        H:=Stabilizer(H,mh_minus_mg,OnTuples);
        continue;
      fi;
      break;
    od;

    if IsSubset(G,H) then
      return H;
    elif IsSubset(H,G) then
      return G;
    fi;


#    # the intersection must stabilize the other groups orbits.
#    # go through the orbits step by step
#    mg:=MovedPoints(G);
#    mg:=ShallowCopy(Orbits(H,mg));
#    SortBy(mg, Length);
#    for i in mg do
#      if Length(i)<5 then
#       G:=Stabilizer(G,Set(i),OnSets);
#      fi;
#    od;
#    mh:=MovedPoints(H);
#    mh:=ShallowCopy(Orbits(G,mh));
#    SortBy(mh, Length);
#    for i in mh do
#      if Length(i)<5 then
#       H:=Stabilizer(H,Set(i),OnSets);
#      fi;
#    od;

    P := OrbitsPartition( H, omega );
    rbase := EmptyRBase( [ G, H ], omega, P );
    rbase.nextLevel := NextRBasePoint;

    # L := SubgroupNC( G, Concatenation
    #                 ( Filtered( GeneratorsOfGroup( G ), gen -> gen in H ),
    #                   Filtered( GeneratorsOfGroup( H ), gen -> gen in G ) ) );
    L := TrivialSubgroup( G );
    L:=PartitionBacktrack( G, H, false, rbase, [ P ], L, L );
    return L;
end );

#############################################################################
##
#F  TwoClosure( <G> [, <merge> ] ) . . . . . . . . . two-closure
##
BindGlobal( "TwoClosurePermGroup", function( arg )
local   G,  merge,  n,  ran,  Omega,  Agemo,  opr,  S,
        adj,  tot,  k,  kk,  pnt,  orb,  o,  new,  gen,  p,  i,
        tra,  Q,  rbase,  doneroot,  P,  Pr;

    G := arg[ 1 ];
    if IsTrivial( G )  then
        return G;
    fi;
    Omega := MovedPoints( G );
    n := Length( Omega );
    S := SymmetricGroup( Omega );
    tra := Transitivity( G, Omega );
    if tra = 0  then
        Error( "2-closure: <G> must be transitive" );
    elif tra >= 2  then
        return S;
    fi;

    P := TrivialPartition( Omega );
    rbase := EmptyRBase( S, Omega, P );
    if Length( arg ) > 1  then
        rbase.suborbits := arg[ 2 ];
        merge := arg[ 3 ];
        Append( merge, Difference( [ 1 .. rbase.suborbits.sublilen ],
                Concatenation( merge ) ) );
    else
        rbase.suborbits := Suborbits( G, [  ], 0, Omega );
        if rbase.suborbits <> false  then
            merge := [ 1 .. rbase.suborbits.sublilen ];
        fi;
    fi;
    Q := OrbitalPartition( rbase.suborbits, rec( several := merge ) );

    doneroot := [  ];
    rbase.nextLevel := function( P, rbase )
        local   f,  fpt,  rep,  strat;

        NextRBasePoint( P, rbase, Omega );
        if rbase.suborbits = false  then  f := false;
                                    else  f := FixcellPoint( P, doneroot );
        fi;
        while f <> false  do
            AddSet( doneroot, f );
            fpt := FixpointCellNo( P, f );
            rep := InverseRepresentative( rbase.suborbits.stabChainTop, fpt );
            strat := StratMeetPartition( rbase, P, Q, rep );
            AddRefinement( rbase, STBBCKT_STRING_TWOCLOSURE,
              [ G, f, Q, strat ] );
            if IsTrivialRBase( rbase )  then  f := false;
                                        else  f := FixcellPoint( P, doneroot );
            fi;
        od;
    end;

    Pr := false;
#    # If <G> is primitive and simple, often $G^[2] \le N(G)$.
#    if     IsPrimitive( G, Omega )
#       and IsSimpleGroup( G )  then
#        type := IsomorphismTypeInfoFiniteSimpleGroup( G );
#        param := IsoTypeParam( type );
#        if param = false  and  not [ type, n ]  in
#           [ [ "M(11)",  55 ], [ "M(12)",  66 ], [ "M(23)", 253 ],
#             [ "M(24)", 276 ], [ "A(9)",  120 ] ]
#        or param <> false  and  not
#        (  param.type = "G(2"  and  param.q >= 3  and
#               n = param.q ^ 3 * ( param.q ^ 3 - 1 ) / 2
#        or param.type = "O(7"  and  n = param.q ^ 3 * ( param.q ^ 4 - 1 )
#               / GcdInt( 2, param.q - 1 ) )  then
#            Pr := function( gen )
#                local   k;
#
#                if not ForAll( GeneratorsOfGroup( G ),
#                           g -> g ^ gen in G )  then
#                    return false;
#                fi;
#                for k  in merge  do
#                    if IsInt( k ) and
#                       OnSuborbits( k, gen, rbase.suborbits ) <> k  then
#                        return false;
#                    elif IsList( k )  and  ForAny( k, i -> not
#                         OnSuborbits( i, gen, rbase.suborbits ) in k )  then
#                        return false;
#                    fi;
#                od;
#                return true;
#            end;
#        fi;
#    fi;

    if Pr = false  then
        ran := [ 1 .. n ^ 2 ];

        if Omega = [ 1 .. n ]  then
            opr := function( p, g )
                p := p - 1;
                return ( p mod n + 1 ) ^ g
                 + n * ( QuoInt( p, n ) + 1 ) ^ g - n;
            end;
        else
            Agemo := [  ];
            for i  in [ 1 .. n ]  do
                Agemo[ Omega[ i ] ] := i - 1;
            od;
            opr := function( p, g )
                p := p - 1;
                return 1 + Agemo[ Omega[ p mod n + 1 ] ^ g ]
                     + n * Agemo[ Omega[ QuoInt( p, n ) + 1 ] ^ g ];
            end;
        fi;

        adj := List( [ 0 .. LogInt(rbase.suborbits.sublilen-1,2) ],
                     i -> BlistList( ran, [  ] ) );
        tot := BlistList( ran, [  ] );
        k   := 0;
        pnt := Position( tot, false );
        while pnt <> fail  do

            # start with the singleton orbit
            orb := [ pnt ];
            p := PositionProperty( merge, m -> IsList( m )
                           and rbase.suborbits.which[ pnt ] in m );
            if p <> fail  then
                for i  in merge[ p ]  do
                    Add( orb, SuboTruePos(ran, rbase.suborbits.blists[ i ] ) );
                od;
            fi;
            orb := BlistList( ran, orb );
            o   := StructuralCopy( orb );
            new := BlistList( ran, ran );
            new[ pnt ] := false;

            # loop over all points found
            p := Position( o, true );
            while p <> fail  do
                o[ p ] := false;

                # apply all generators <gen>
                for gen  in GeneratorsOfGroup( G )  do
                    i := opr( p, gen );

                    # add the image <img> to the orbit if it is new
                    if new[ i ]  then
                        orb[ i ] := true;
                        o  [ i ] := true;
                        new[ i ] := false;
                    fi;

                od;

                p := Position( o, true );
            od;

            kk := k;
            i  := 0;
            while kk <> 0  do
                i := i + 1;
                if kk mod 2 = 1  then
                    UniteBlist( adj[ i ], orb );
                fi;
                kk := QuoInt( kk, 2 );
            od;
            UniteBlist( tot, orb );
            k := k + 1;
            pnt := Position( tot, false, pnt );
        od;
        Pr := function( gen )
            local   p,  i;

            gen := UnslicedPerm@( gen );
            for p  in ran  do
                i := opr( p, gen );
                if not ForAll( adj, bit -> bit[ i ] = bit[ p ] )  then
                    return false;
                fi;
            od;
            return true;
        end;
    fi;
    return PartitionBacktrack( S, Pr, false, rbase, [ true ], G, G );
end );

InstallMethod(TwoClosure,"permutation group",true,[IsPermGroup],0,
  TwoClosurePermGroup);
