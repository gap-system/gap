#############################################################################
##
#W  stbcbckt.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the basic   routines for permutation group   backtrack
##  algorithms that are based  on partitions. These  routines are used in the
##  calculation  of   set   stabilizers, normalizers,    centralizers     and
##  intersections.
##
Revision.stbcbckt_gi :=
    "@(#)$Id$";

if not IsBound( LARGE_TASK )  then  LARGE_TASK := false;   fi;


#############################################################################
##
#F  IsSymmetricGroupQuick( <G> )  . . . . . . . . . . . . . . . .  quick test
##
InstallGlobalFunction( IsSymmetricGroupQuick, function( G )
    return false;
    return ( HasIsNaturalSymmetricGroup( G )  or  NrMovedPoints( G ) <= 100 )
       and IsNaturalSymmetricGroup( G );
end );

#############################################################################
##
#F  YndexSymmetricGroup( <S>, <U> ) . . . . . . . . . . . yndex of <U> in <S>
##
InstallGlobalFunction( YndexSymmetricGroup, function( S, U )
    local   deg,  p,  e,  i,  f,  log;
    
    deg := NrMovedPoints( S );
    if not IsTrivial( U )  then
        for p  in Collected( FactorsInt( Size( U ) ) )  do
            e := 0;
            f := deg;  log := 0;
            while f mod p[ 1 ] = 0  do
                f := f / p[ 1 ];  log := log + 1;
            od;
            for i  in [ 1 .. log ]  do
                e := e + QuoInt( deg, p[ 1 ] ^ i );
                if e > p[ 2 ]  then
                    return p[ 1 ];
                fi;
            od;
        od;
    fi;
    return 1;
end );

#############################################################################
##
#F  IsSlicedPerm( <perm> )  . . . . . . . . . . . . . . . sliced permutations
##
DeclareRepresentation( "IsSlicedPerm", IsPerm,
                        [ "length", "word", "lftObj", "rgtObj", "opr" ] );

#############################################################################
##
#F  AsPerm( <perm> )  . . . . . . . . . . . . . . . . . . . . . . . . . local
##
InstallGlobalFunction( AsPerm, function( perm )
    local   prm,  i;
    
    if IsSlicedPerm( perm )  then
        prm := ();
        for i  in [ 1 .. perm!.length ]  do
            prm := LeftQuotient( perm!.word[ i ], prm );
        od;
        perm := prm;
    fi;
    return perm;
end );

InstallMethod( \^, "sliced perm",true, [ IsPerm, IsSlicedPerm ], 0,
    function( p, perm )  return p ^ AsPerm( perm );  end );
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

DeclareRepresentation( "IsSlicedPermInv", IsPerm,
                           [ "length", "word", "lftObj", "rgtObj", "opr" ] );

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
            t!.rgtObj := t!.opr( t!.rgtObj, edg );
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
InstallGlobalFunction( MeetPartitionStrat, function( arg )
    local   rbase,  image,  S,  cellno,  g,  strat,  P,  p;
    
    rbase := arg[ 1 ];
    image := arg[ 2 ];
    S     := arg[ 3 ];
    strat := arg[ Length( arg ) ];
    if Length( arg ) = 5  then  g := arg[ 4 ];
                          else  g := ();       fi;
    
    if Length( strat ) = 0  then
        return false;
    fi;
    
    P := image.partition;
    if IsPartition( S )  then
        cellno := S.cellno;
    else
        cellno := ListWithIdenticalEntries( Length( P.cellno ), 0 );
        cellno{ S } := 1 + 0 * S;
    fi;
    for p  in strat  do
        if p[1] =  0  and
           not ProcessFixpoint( image, p[2], FixpointCellNo( P, p[3] ) )
        or p[1] <> 0  and
           SplitCell( P, p[1], cellno, p[2], g, p[3] ) <> p[3]  then
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
            cellno, # list of cells in <S> to which the points belong
            p,  s,  # indices looping over the cells of <P> resp. <S>
            i,      # result of call to `SplitCell'
            pnt,    # fixpoint to be processed
            cellsP, #\
            blist,  #  >see explanation below
            blist2, #/
            rap,  cell,  nrcells;

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
    if g = ()  then
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
        cellno := S.cellno;
    else
        nrcells := 1;
        cellno := ListWithIdenticalEntries( Length( P.cellno ), 0 );
        cellno{ S } := 1 + 0 * S;
        blist := BlistList( [ 1 .. NumberCells( P ) ], cellsP{ S } );
        p := Position( blist, true );
        if p <> fail  then
            IntersectBlist( blist, BlistList( [ 1 .. NumberCells( P ) ],
                cellsP{ Difference( [ 1 .. Length( P.cellno ) ], S ) } ) );
            p := Position( blist, true );
        fi;
        S := false;
    fi;
    
    for s  in [ 1 .. nrcells ]  do
        if S <> false  then

            # <blist> is the  bit-list  version of  the set  of cell  numbers
            # mentioned above.
            rap := [ 1 .. NumberCells( P ) ];
            blist := BlistList( rap, cellsP{ Cell( S, s ) } );
            p := Position( blist, true );
            if p <> fail  then
                blist2 := BlistList( rap, cellsP{ S.points
                      { [ 1 .. S.firsts[ s ] - 1 ] } } );
                if s <= nrcells  then
                    UniteBlist( blist2, BlistList( rap, cellsP{ S.points
                      { [ S.firsts[ s ] + S.lengths[ s ] ..
                          Length( S.points ) ] } } ) );
                fi;
                IntersectBlist( blist, blist2 );
                p := Position( blist, true );
            fi;
            
        fi;
        while p <> fail  do
            
            # Last argument `true' means that the cell will split.
            i := SplitCell( P, p, cellno, s, g, true );
            if g <> ()  then
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
            p := Position( blist, true, p );
        od;
    od;
    return strat;
end );

#############################################################################
##
#F  Suborbits( <G>, <tofix>, <b>, <Omega> ) . . . . . . . . . . . . suborbits
##
##  Returns a record with the following components:
##
##     domain: the set <Omega>
##  stabChain: a stabilizer chain for  $G_tofix$ (pointwise stabilizer)  with
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
            perm,  omega,  P,  cell,  part,  p,  i;
    
    # Get the arguments.
    H := arg[ 1 ];
    if Length( arg ) > 1  then
        tofix := arg[ 2 ];
        b     := arg[ 3 ];
        Omega := arg[ 4 ];
        if b = 0  then  part := false;  b := Omega[ 1 ];
                  else  part := true;   fi;
    else
        tofix := [  ];
        Omega := MovedPoints( H );
        b     := Omega[ 1 ];
        part  := false;
    fi;
    G := StabChainMutable( H );
    conj := One( H );
    
    # Replace  <H> by  the stabilizer of  all elements  of <tofix> except the
    # last.
    len := Length( tofix );
    for i  in [ 1 .. len ]  do
        conj := conj * InverseRepresentative( G, tofix[ i ] ^ conj );
        G := G.stabilizer;
    od;

    if Omega <> MovedPoints( H )  then
        suborbits := [  ];
    elif len <> 0  then
      b := b ^ conj;
#        if not IsBound( H!.stabSuborbits )  then
#            H!.stabSuborbits       := [  ];
#            H!.stabSuborbitsLabels := [  ];
#        fi;
#        p := Position( H!.stabSuborbitsLabels, tofix );
#        if p = fail  then
#            Add( H!.stabSuborbitsLabels, tofix );
#            p := Length( H!.stabSuborbitsLabels );
##        fi;
#        tofix := p;
#        if not IsBound( H!.stabSuborbits[ tofix ] )  then
#            H!.stabSuborbits[ tofix ] := [  ];
#        fi;
#        if not IsBound( H!.stabSuborbits[ tofix ][ len ] )  then
#            H!.stabSuborbits[ tofix ][ len ] := [  ];
#        fi;
#        suborbits := H!.stabSuborbits[ tofix ][ len ];
        suborbits:=[];
    else
        if not IsBound( H!.suborbits )  then
            H!.suborbits := [  ];
        fi;
        suborbits := H!.suborbits;
    fi;
    
    # Replace <b> by the minimal element <a> in its <G>-orbit.
    GG := G;
    if not IsInBasicOrbit( GG, b )  then
        GG := EmptyStabChain( [  ], One( H ), b );
        AddGeneratorsExtendSchreierTree( GG, G.generators );
    fi;
    a := Minimum( GG.orbit );
    conj := conj * InverseRepresentative( GG, b ) /
                   InverseRepresentative( GG, a );
  
    ran := [ 1 .. Maximum( Omega ) ];
    # disabled. See also `suborbits' assignement below
    if IsBound( suborbits[ a ] )  then
        subs := suborbits[ a ];
    else
        
        # Construct the suborbits rooted at <a>.
        G := CopyStabChain( G );
        ChangeStabChain( G, [ a ], false );
        subs := rec( stabChain := G,
                        domain := Omega,
                         which := ListWithIdenticalEntries( Length(ran), 0 ),
                        blists := [ BlistList( ran, [ a ] ) ],
                          reps := [ G.identity ],
                       lengths := [ 1 ],
             orbitalPartitions := [  ] );
        subs.which[ a ] := 1;
        all := BlistList( ran, ran );
        SubtractBlist( all, BlistList( ran, Omega ) );  all[ a ] := true;
        k := 1;
        pnt := Position( all, false );
        while pnt <> fail  do
            k := k + 1;
            orb := [ pnt ];
            subs.blists[ k ] := BlistList( ran, orb );
            for p  in orb  do
                for gen  in G.stabilizer.generators  do
                    i := p ^ gen;
                    if not subs.blists[ k ][ i ]  then
                        Add( orb, i );
                        subs.blists[ k ][ i ] := true;
                    fi;
                od;
            od;
            subs.which{ orb } := k + 0 * orb;
            if IsInBasicOrbit( G, pnt )  then
                subs.reps[ k ] := true;
                subs.lengths[ k ] := Length( orb );
            else
                
                # Suborbits outside the root's orbit get negative length.
                subs.reps[ k ] := false;
                subs.lengths[ k ] := -Length( orb );
                
            fi;
            UniteBlist( all, subs.blists[ k ] );
            pnt := Position( all, false, pnt );
        od;
        suborbits[ a ] := subs;
    fi;
    
    if part  and  not IsBound( subs.partition )  then
        if not IsBound( subs.lengths )  then
            subs.lengths := [  ];
            for k  in [ 1 .. Length( subs.blists ) ]  do
                if subs.reps[ k ] = false  then
                    Add( subs.lengths, -SizeBlist( subs.blists[ k ] ) );
                else
                    Add( subs.lengths, SizeBlist( subs.blists[ k ] ) );
                fi;
            od;
        fi;
        perm := Sortex( subs.lengths ) ^ -1;
        
        # Determine the partition into unions of suborbits of equal length.
        subs.byLengths := [  ];
        P := [  ];  omega := Set( Omega );  cell := [  ];  bylen := [  ];
        for k  in [ 1 .. Length( subs.lengths ) ]  do
            Append( cell, ListBlist( ran, subs.blists[ k ^ perm ] ) );
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
           pos;  # position of cell with given <key> in <P>
    
    if    not IsInt( k )
       or not IsBound( subs.orbitalPartitions[ k ] )  then
        ran := [ 1 .. Length( subs.which ) ];
        d   := Length( subs.blists );
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
                sub := ListBlist( ran, subs.blists[ k ] );
                key[ k ] := 1;
                new := [ k ];
            fi;
        else
            sub := ListBlist( ran, UnionBlist( subs.blists{ k } ) );
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
                if subs.reps[ o ] = true  then
                    subs.reps[ o ] := InverseRepresentative( subs.stabChain,
                        Position( subs.blists[ o ], true ) ) ^ -1;
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
            od;
        od;

        if sub <> 0  then
            Key := Key * ( d + d * Length( sub ) ^ d ) + key;
        fi;
      od;

        # Partition  <dom> into unions   of  suborbits w.r.t. the  values  of
        # <Key>.
        if Key = 0  then
            P := [ subs.domain ];
        else
            dom := ShallowCopy( subs.domain );
            RemoveSet( dom, BasePoint( subs.stabChain ) );
            typ := Set( Key );
            P := List( typ, t -> [  ] );
            for i  in [ 1 .. Length( Key ) ]  do
                pos := Position( typ, Key[ i ] );
                sub := ListBlist( ran, subs.blists[ i ] );
                Append( P[ pos ], sub );
                SubtractSet( dom, sub );
            od;
            if Length( dom ) <> 0  then
                Add( P, dom );
            fi;
        fi;
        
        P := Partition( P );
        if not IsInt( k )  then
            return P;
        fi;
        subs.orbitalPartitions[ k ] := P;
    fi;
    return subs.orbitalPartitions[ k ];
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
            rbase.level2 := CopyStabChain( StabChainMutable( G[ 2 ] ) );
            rbase.lev2   := [  ];
        fi;
        G := G[ 1 ];
    else
        rbase.level2 := false;
    fi;
    if IsSymmetricGroupQuick( G )  then
        Info( InfoBckt, 1, "Searching in symmetric group" );
        rbase.fix   := [  ];
        rbase.level := NrMovedPoints( G );
    else
        rbase.chain := CopyStabChain( StabChainMutable( G ) );
        rbase.level := rbase.chain;
    fi;
    
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
        AddRefinement( rbase, "ProcessFixpoint", [ pnt, k ] );
    fi;
    if rbase.level2 <> false  then
        if rbase.level2 = true  then  lev := rbase.level;
                                else  lev := rbase.level2;  fi;
        if not IsInt( lev )  then
            O := OrbitsPartition( lev, rbase.domain );
            strat := StratMeetPartition( rbase, P, O );
            AddRefinement( rbase, "Intersection", [ O, strat ] );
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
                         lens[ P.cellno[ p ] ] <> 1 );
        else
            p := PositionProperty( order, p ->
                         lens[ P.cellno[ p ] ] <> 1
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
           i,  dd,  p;   # loop variables
    
#############################################################################
##
#F      PBEnumerate( ... )  . . . . . . . recursive enumeration of a subgroup
##
    PBEnumerate := function( d, wasTriv )
        local  undoto,   # number of cells of <P> wanted after undoing
               oldprm,   #\
               oldrgt,   #  > old values of <image>
               oldprm2,  #/
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
                                                oldrgt := image.perm!.rgtObj;
                                          else  oldprm := image.perm;
                                                oldrgt := false;          fi;
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
                        prm := AsPerm( prm );
                        if SiftedPermutation( image.level2,
                                   prm / AsPerm( image.perm2 ) )
                           = image.level2.identity  then
                            return prm;
                        fi;
                    elif Pr( prm )  then
                        return AsPerm( prm );
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
                        Info( InfoBckt, 2, d, ": point ", b,
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
                        image.perm!.rgtObj := oldrgt;
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
                    Info( InfoBckt, 2, d, ": point ", b,
                            " pruned by partition condition" );
                fi;
                
                # Recursion.
                if t = true  then
                    t := PBEnumerate( d + 1, false );
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
    
    # If necessary, convert <Pr> from a list to a function.
    if     IsList( Pr )
       and (    IsTrivial( G )
             or IsSymmetricGroupQuick( G ) )  then
        obj := rec( lftObj := Pr[ 1 ],
                    rgtObj := Pr[ 2 ],
                       opr := Pr[ 3 ],
                      prop := Pr[ 4 ] );
        Pr := gen -> obj.prop
              ( rec( lftObj := obj.lftObj,
                     rgtObj := obj.opr( obj.rgtObj, gen ^ -1 ) ) );
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
    if IsSymmetricGroupQuick( G )  then
        image.perm := true;
    else
        if IsList( Pr )  then
            image.perm := Objectify
                ( NewType( PermutationsFamily, IsSlicedPerm ),
                  rec( length := 0, word := [  ] ) );
            image.perm!.lftObj := Pr[ 1 ];
            image.perm!.rgtObj := Pr[ 2 ];
            image.perm!.opr    := Pr[ 3 ];
            Pr                 := Pr[ 4 ];
        else
            image.perm := One( G );
        fi;
        image.level := rbase.chain;
    fi;
    
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
        L := ListStabChain( CopyStabChain( StabChainMutable( L ) ) );
        R := ListStabChain( CopyStabChain( StabChainMutable( R ) ) );

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

#V  Refinements . . . . . . . . . . . . . . .  record of refinement processes
##
InstallValue( Refinements, rec() );

#############################################################################
##
#F  Refinements.ProcessFixpoint( <pnt>, <cellno> )  . . .  process a fixpoint
##
Refinements.ProcessFixpoint := function( rbase, image, pnt, cellno )
    local   img;
    
    img := FixpointCellNo( image.partition, cellno );
    return ProcessFixpoint( image, pnt, img );
end;

#############################################################################
##
#F  Refinements.Intersection( <O>, <strat> )  . . . . . . . . . . second type
##
Refinements.Intersection := function( rbase, image, O, strat )
    local   t;
    
    if image.level2 = false  then  t := image.perm;
                             else  t := image.perm2;  fi;
    if IsSlicedPerm( t )  then
        t := ShallowCopy( t );
        SET_TYPE_COMOBJ( t, NewType( PermutationsFamily, IsSlicedPermInv ) );
    else
        t := t ^ -1;
    fi;
    return MeetPartitionStrat( rbase, image, O, t, strat );
end;

#############################################################################
##
#F  Refinements.Centralizer(<no>,<g>,<pnt>,<strat>) . P meet Pz for one point
##
Refinements.Centralizer := function( rbase, image, cellno, g, pnt, strat )
    local   P,  img;
    
    P := image.partition;
    img := FixpointCellNo( P, cellno ) ^ image.data[ g + 1 ];
    return     IsolatePoint( P, img ) = strat
           and ProcessFixpoint( image, pnt, img );
end;

#############################################################################
##
#F  Refinements._MakeBlox( <rbase>, <image>, <len> )  . . . . . . . make blox
##
Refinements._MakeBlox := function( rbase, image, len )
    local   F;
    
    F := image.data[ 2 ];
    image.data[ 4 ] := Partition( Blocks( F, rbase.domain,
                               image.bimg{ [ 1, len ] } ) );
    return Collected( rbase.blox.lengths ) =
           Collected( image.data[ 4 ].lengths );
end;

#############################################################################
##
#F  Refinements.SplitOffBlock( <k>, <strat> ) . . . . . . . . split off block
##
Refinements.SplitOffBlock := function( rbase, image, k, strat )
    local   B,  a,  orb;
    
    B   := image.data[ 4 ];
    a   := FixpointCellNo( image.partition, k );
    orb := Cell( B, B.cellno[ a ] );
    if Length( orb ) = Length( rbase.domain )  then
        return false;
    else
        return MeetPartitionStrat( rbase, image, orb, strat );
    fi;
end;

#############################################################################
##
#F  Refinements._RegularOrbit1( <d>, <len> )  . . . . . . extend mapped orbit
##
##  Computes orbit and transversal `bF' for group <F>  = `data[6]' regular on
##  that orbit.
##
Refinements._RegularOrbit1 := function( rbase, image, d, len )
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
end;

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
Refinements.RegularOrbit2 := function( rbase, image, d, orbit, strat )
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
end;

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
Refinements.RegularOrbit3 := function( rbase, image, f, strat )
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
end;
    
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
Refinements.Suborbits0 := function( rbase, image, tra, f, lens, byLen, strat )
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
end;

#############################################################################
##
#F  Refinements.Suborbits1( <rbase>, <image>, <tra>, <f>, <k>, <strat> )  . .
##
##  Meets  the  image partition with the  orbital  partition of the  union of
##  orbital graphs of suborbits of length `subs.byLengths[ <k> ]'. (<tra> and
##  <f> as in `Suborbits0'.)
##
Refinements.Suborbits1 := function( rbase, image, tra, f, k, strat )
    local   F,  pnt,  subs,  Q;
    
    F    := image.data[ 2 ];
    pnt  := FixpointCellNo( image.partition, f );
    subs := Suborbits( F, image.bimg{ [ 1 .. tra - 1 ] }, pnt,
                    rbase.domain );
    Q := OrbitalPartition( subs, subs.byLengths[ k ] );
    return MeetPartitionStrat( rbase, image, Q, subs.conj, strat );
end;

#############################################################################
##
#F  Refinements.Suborbits2( <rbase>, <image>, <tra>, <f>, <start>, <coll> ) .
##
##  Computes  for each suborbit the  intersection sizes with cells <start> or
##  more in the image partition. Stores the  result in `data[3]' (needed only
##  on this level,  hence no  '_'). Returns  `true'  if the collected  result
##  equals <coll>.
##
Refinements.Suborbits2 := function( rbase, image, tra, f, start, coll )
    local   F,  types,  pnt,  subs,  i, k;
    
    F    := image.data[ 2 ];
    pnt  := FixpointCellNo( image.partition, f );
    subs := Suborbits( F, image.bimg{ [ 1 .. tra - 1 ] }, pnt,
                    rbase.domain );
    if start = 1  then
        image.data[ 3 ] := List( subs.blists, o -> [ -SizeBlist( o ) ] );
    fi;
    types := image.data[ 3 ];
    for i  in [ start .. NumberCells( image.partition ) ]  do
        for k  in Set( subs.which
          { OnTuples( Cell( image.partition, i ), subs.conj ) } )  do
            AddSet( types[ k ], i );
        od;
    od;
    return Collected( types ) = coll;
end;

#############################################################################
##
#F  Refinements.Suborbits3( <rbase>, <image>, <tra>, <f>, <typ>, <strat> )  .
##
##  Meets  the image  partition with  the orbital partition   of the union of
##  orbital  graphs of suborbits of type  <typ>. Returns `false' if there are
##  not <many> of them. (<tra> and <f> as in `Suborbits0'.)
##  
Refinements.Suborbits3 := function( rbase, image, tra, f, typ, many, strat )
    local   F,  types,  pnt,  subs,  k,  Q;
    
    F     := image.data[ 2 ];
    types := image.data[ 3 ];
    pnt   := FixpointCellNo( image.partition, f );
    subs  := Suborbits( F, image.bimg{ [ 1 .. tra - 1 ] }, pnt,
                     rbase.domain );
    k := Filtered( [ 1 .. Length( subs.blists ) ], k -> types[ k ] = typ );
    if Length( k ) <> many  then
        return false;
    else
        Q := OrbitalPartition( subs, k );
        return MeetPartitionStrat( rbase, image, Q, subs.conj, strat );
    fi;
end;

#############################################################################
##
#F  Refinements.TwoClosure( <G>, <Q>, <d>, <strat> )  . . . . . . two-closure
##
Refinements.TwoClosure := function( rbase, image, G, f, Q, strat )
    local   pnt,  t;
    
    pnt := FixpointCellNo( image.partition, f );
    t   := InverseRepresentative( rbase.suborbits.stabChain, pnt );
    return MeetPartitionStrat( rbase, image, Q, t, strat );
end;

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
        AddRefinement( rbase, "_RegularOrbit1", [ d, 1 ] );
    else
        tree := rbase.trees[ Length( rbase.trees ) ];
        if Length( tree.orbit ) < Length( rbase.regorb.orbit )  then
            p := PositionProperty( rbase.regorb.orbit, q ->
                         P.lengths[ P.cellno[ q ] ] <> 1
                     and (    IsInt( rbase.level )
                           or not IsFixedStabilizer( rbase.level, q ) ) );
            if p <> fail  then
                b := rbase.regorb.orbit[ p ];
                RegisterRBasePoint( P, rbase, b );
                gen := QuickInverseRepresentative( rbase.regorb, b ) ^ -1;
                tree := StructuralCopy( tree );
                AddGeneratorsExtendSchreierTree( tree, [ gen ] );
                AddRefinement( rbase, "_RegularOrbit1",
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
                AddRefinement( rbase, "RegularOrbit2",
                        [ d, tree.orbit, strat ] );
            fi;
        fi;
    fi;
    if p = fail  then
        NextRBasePoint( P, rbase );
    fi;
    
    # If the image of a point is known, the image of its <E>-orbit is known.
    # See sec. 3.7 of my thesis, read `y' for `\gamma'.
    fix := Set( P.cellno{ rbase.regorb.orbit } );
    f := FixcellPoint( P, fix );
    while f <> false  do
        y := FixpointCellNo( P, f );
        S := EmptyStabChain( [  ], rbase.regorb.identity, y );
                           # ^ rbase.regorb.labels
        AddGeneratorsExtendSchreierTree( S, rbase.regorb.generators );
        UniteSet( fix, P.cellno{ S.orbit } );
        strat := [  ];
        for yh  in S.orbit  do
            h := InverseRepresentativeWord( S, yh );
            bh := PreImageWord( rbase.regorb.orbit[ 1 ], h );
            i := P.cellno[ bh ];
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
        AddRefinement( rbase, "RegularOrbit3", [ f, strat ] );
        f := FixcellPoint( P, fix );
    od;
    
end );

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
           len,  i,  range;
    
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
        order := Maximum( List( GeneratorsOfGroup( E ), OrderPerm ) );
        if 2 * order < n  then  order := Cell( B, l );
                          else  order := Cell( B, L );  fi;
    fi;
    
    # Construct an  R-base. Start with  the partition into  <G>-orbits on the
    # cells of <B>. In the normalizer  case, only the factor group $N_G(E)/E$
    # acts on the cells.
    rbase := EmptyRBase( G, Omega, CollectedPartition( B, div ) );
    range := [ 1 .. rbase.domain[ Length( rbase.domain ) ] ];
    rbase.suborbits := [  ];
    
    if NumberCells( B ) = 1  then  rbase.blox := false;
                             else  rbase.blox := B;      fi;
        
    # See if <E> has a regular orbit or is affine.
    orbs := Orbits( E, Omega );
    reg := PositionProperty( orbs, orb -> Length( orb ) = Size( E ) );
    if reg <> fail  then
        Info( InfoBckt, 1, "Subgroup has regular orbit" );
        rbase.reggrp := function( E, Omega )  return E;  end;
        rbase.regorb := EmptyStabChain( [  ], One( E ),
                                orbs[ reg ][ 1 ] );
        AddGeneratorsExtendSchreierTree( rbase.regorb,
                GeneratorsOfGroup( E ) );
    elif IsPrimitive( E, Omega )  then
        reg := Earns( E, Omega );
        if reg <> fail  then
            Info( InfoBckt, 1, "Subgroup is affine" );
            rbase.reggrp := Earns;
            rbase.regorb := EmptyStabChain( [  ], One( reg ),
                                    Omega[ 1 ] );
            AddGeneratorsExtendSchreierTree( rbase.regorb,
                    GeneratorsOfGroup( reg ) );
        fi;
    fi;
        
    doneblox := [  ];
    doneroot := [  ];
        
    rbase.nextLevel := function( P, rbase )
        local   len,  a,  Q, strat,  orb,  f,  fpt,  subs,  k,  i,
                start,  oldstart,  types,  typ,  coll,  pnt,  done;

        if reg <> fail  then  NextLevelRegularGroups( P, rbase );
                        else  NextRBasePoint( P, rbase, order );   fi;
        len := Length( rbase.base );
        a := rbase.base[ len ];
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
              AddRefinement( rbase, "Suborbits0", [ tra, f, subs.lengths,
                      List( subs.byLengths, Length ), strat ] );

              # For each such   length, `Suborbits1' computes  and  meets the
              # `OrbitalPartition' of the   union of orbital  graphs for  the
              # suborbits of  that  length  (only   if there are  less   than
              # sqrt(subdegree) many and if they are  in the component of the
              # root).
              for k  in [ 1 .. Length( subs.byLengths ) ]  do
                  if Length( subs.byLengths[ k ] ) ^ 2
                   < Length( subs.blists )
                 and subs.reps[ subs.byLengths[ k ][ 1 ] ] <> false  then
                      strat := StratMeetPartition( rbase, P, OrbitalPartition
                               ( subs, subs.byLengths[ k ] ), subs.conj );
                      AddRefinement( rbase, "Suborbits1",
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
              types := List( subs.blists, o -> [ -SizeBlist( o ) ] );
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
                  k := Filtered( [ 1 .. Length( subs.blists ) ],
                         k -> types[ k ] = typ[ 1 ] );
                  if not k in done  then
                    AddSet( done, k );
                    Q := OrbitalPartition( subs, k );
                    strat := StratMeetPartition( rbase, P, Q, subs.conj );
                    if Length( strat ) <> 0  then

                      # `Suborbits2' computes the types  in the image (stored
                      # in `data[3]') and compares them with <coll> (only for
                      # new cells between <oldstart> and <start>).
                      if oldstart < start  then
                        AddRefinement( rbase, "Suborbits2",
                                [ tra, f, oldstart, coll ] );
                        oldstart := start;
                      fi;

                      # `Suborbits3' computes and meets the orbital partition
                      # for the image.
                      AddRefinement( rbase, "Suborbits3", [ tra, f,
                              typ[ 1 ], Length( k ), strat ] );
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
                  if P.lengths[ P.cellno[ pnt ] ] = 1  then
                      AddSet( doneroot, P.cellno[ pnt ] );
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
                AddRefinement( rbase, "_MakeBlox", [ len ] );
            fi;
        fi;
         
        # Split off blocks whose images are known.
        if rbase.blox <> false  then
            k := FixcellsCell( P, rbase.blox.cellno, (), doneblox );
            while k <> false  do
                for i  in [ 1 .. Length( k[ 1 ] ) ]  do
                    orb := Cell( rbase.blox, k[ 1 ][ i ] );
                    if Length( orb ) <> Length( Omega )  then
                        strat := StratMeetPartition( rbase, P, orb );
                        AddRefinement( rbase, "SplitOffBlock",
                                [ k[ 2 ][ i ], strat ] );
                        if IsTrivialRBase( rbase )  then
                            return;
                        fi;
                    fi;
                od;
                k := FixcellsCell( P, rbase.blox.cellno, (), doneblox );
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
            gens,  cell,  i;
    
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
                                       
    # Special treatment for the symmetric group.
    if IsSymmetricGroupQuick( G )  then
        if repr  then
            return MappingPermListList( Phi, Psi );
        else
            gens := [  ];
            for i  in [ 1 .. NumberCells( P ) ]  do
                cell := Cell( P, i );
                if Length( cell ) > 1  then
                    Add( gens, ( cell[ 1 ], cell[ 2 ] ) );
                    if Length( cell ) > 2  then
                        Add( gens, MappingPermListList( cell,
                                cell{ Concatenation( [ 2 .. Length( cell ) ],
                                        [ 1 ] ) } ) );
                    fi;
                fi;
            od;
            return GroupByGenerators( gens, () );
        fi;
    fi;
    
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

    Pr := gen -> IsSubsetSet( OnTuples( Phi, gen ), Psi );
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
           i, size; # loop/auxiliary variables
    
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
    
#    L := SubgroupNC( G, Concatenation( GeneratorsOfGroup( L ),
#                 Filtered( Concatenation( StrongGenerators( G ),
#                 Filtered( e, gen -> gen in G ) ),
#                 gen -> OnTuples( e, gen ) = e ) ) );
#    if repr  then
#        R := SubgroupNC( G, Concatenation( GeneratorsOfGroup( R ),
#                     Filtered( Concatenation( StrongGenerators( G ),
#                     Filtered( f, gen -> gen in G ) ),
#                     gen -> OnTuples( f, gen ) = f ) ) );
#    else
#        R := L;
#    fi;
    
    Omega := MovedPoints( Concatenation( GeneratorsOfGroup( G ), e, f ) );
    P := TrivialPartition( Omega );
    if repr  then  size := 1;
             else  size := Size( G );  fi;
    for i  in [ 1 .. Length( e ) ]  do
        cycles := Partition( Cycles( e[ i ], Omega ) );
        StratMeetPartition( P, CollectedPartition( cycles, size ) );
    od;
    
    # Find the order in which to process the points in the base choice.
    order := cycles.points{ cycles.firsts };
    SortParallel( ShallowCopy( -cycles.lengths ), order );

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
                    AddRefinement( rbase, "Centralizer",
                            [ P.cellno[ pnt ], g, img, strat ] );
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
    
    return PartitionBacktrack( G, [ e, f, OnTuples,
                   gen -> gen!.lftObj = gen!.rgtObj ],
                   repr, rbase, Concatenation( [ Q ], f ), L, R );
end );

#############################################################################
##
#F  IsomorphismPermGroups( <arg> )  . . . . isomorphism / conjugating element
##
InstallGlobalFunction( IsomorphismPermGroups, function( arg )
    local   G,  E,  F,  Pr,  L,  R,  Omega,  rbase,  data,
            Q,  BF;
    
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
    fi;
    Omega := MovedPoints( Concatenation( GeneratorsOfGroup( G ),
                     GeneratorsOfGroup( E ), GeneratorsOfGroup( F ) ) );

    # test whether we have a chance mapping the groups (as their orbits fit
    # together)
    if Collected(List(Orbits(E,Omega),Length))<>
       Collected(List(Orbits(F,Omega),Length)) then
      return fail;
    fi;

    Pr := gen -> ForAll( GeneratorsOfGroup( E ), g -> g ^ gen in F );
    if Length( arg ) > 3  then
        L := arg[ Length( arg ) - 1 ];
        R := arg[ Length( arg ) ];
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
        Add( data, rbase.reggrp( F, Omega ) );
    fi;

    return PartitionBacktrack( G, Pr, true, rbase, data, L, R );
end );

#############################################################################
##
#F  AutomorphismGroupPermGroup( <arg> ) . . . automorphism group / normalizer
##
InstallGlobalFunction( AutomorphismGroupPermGroup, function( arg )
local   G,  E,  div, Omega,  Pr, rbase,  data,  N,  B,  L;
    
    G := arg[ 1 ];
    E := arg[ 2 ];
    if IsTrivial( E )  then
        return G;
    elif Size( E ) = 2  then
        if Length( arg ) > 2  then  L := arg[ 3 ];
                              else  L := TrivialSubgroup( G );  fi;
        E := [ First( GeneratorsOfGroup( E ),
                     gen -> Order( gen ) <> 1 ) ];
        return RepOpElmTuplesPermGroup( false, G, E, E, L, L );
    fi;
    Omega := MovedPoints( Concatenation( GeneratorsOfGroup( G ),
                     GeneratorsOfGroup( E ) ) );
    Pr := gen -> ForAll( GeneratorsOfGroup( E ), g -> g ^ gen in E );
    if   Length( arg ) = 3  then  L := arg[ 3 ];
    elif IsSubset( G, E )   then  L := E;
    else                          L := TrivialSubgroup( G );  fi;
    
    if not IsTrivial( G )  then
        if IsSymmetricGroupQuick( G ) and
	  IsSubset(MovedPoints(G),MovedPoints(E)) then
            div := YndexSymmetricGroup( G, E );
        elif IsSubset( G, E )  then
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
    return N;
end );

InstallMethod( NormalizerOp,"perm group", IsIdenticalObj,
  [ IsPermGroup, IsPermGroup ], 0,
        AutomorphismGroupPermGroup );

InstallOtherMethod( NormalizerOp,"perm group", true,
  [ IsPermGroup, IsPermGroup,IsPermGroup ], 0,
        AutomorphismGroupPermGroup );

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
InstallGlobalFunction( PartitionStabilizerPermGroup, function(G,part)
local pl,i,p,W,op;

  # first separate the sets of different lengths
  pl:=Set(List(part,Length));
  for i in [1..Length(pl)] do
    pl[i]:=Filtered(part,j->Length(j)=pl[i]);
    G:=Stabilizer(G,Concatenation(pl[i]),OnSets);
  od;

  # now pl is a list of lists of sets of the same length, sorted in
  # ascending size.

  # stabilize the partitioning among sets of the same length
  for p in pl do
    # the trivial partitions are always stabilized.
    if Length(p)>1 and Length(p[1])>1 then

      # the stabilizer of p in S_n is a wreath product of symmetric groups
      # (It seems that computing the intersection is better than the
      # `SubgroupProperty' call commented out below, as `Intersection' uses
      # better refinements internally.
      op:=ActionHomomorphism(G,Concatenation(p)); #makes the blocks standard

      W:=WreathProduct(SymmetricGroup(Length(p[1])),SymmetricGroup(Length(p)));

      W:=Intersection(W,Image(op,G)); # the stabilizer

      G:=PreImage(op,W);

#    # because we want to keep the set property, we make p immutable
#    p:=Immutable(Set(p));
#    # the stabilizer is the set of all elements that map every set from p into
#    # another set from p.
#    # as a subgroup of the stabilizer compute the stabilizer on set tuples
#    S:=G;
#    for i in p do
#      S:=Stabilizer(S,i,OnSets);
#      Print(i," ",Size(S),"\n");
#    od;
#
#    G:=SubgroupProperty(G,function(gen)
#                          local i;
#			    for i in p do
#			      if not OnSets(i,gen) in p then
#				return false;
#			      fi;
#			    od;
#			    return true;
#			  end,
#			  S);


    fi;
  od;
  return G;

end );


#############################################################################
##
#M  Centralizer( <G>, <e> ) . . . . . . . . . . . . . . in permutation groups
##
InstallMethod( CentralizerOp, "perm group,elm",IsCollsElms,
  [ IsPermGroup, IsPerm ], 10,
    function( G, e )
    e := [ e ];
    return RepOpElmTuplesPermGroup( false, G, e, e,
                   TrivialSubgroup( G ), TrivialSubgroup( G ) );
end );

InstallMethod( CentralizerOp, "perm group, perm group", IsIdenticalObj, 
  [ IsPermGroup, IsPermGroup ], 10,
    function( G, E )
    return RepOpElmTuplesPermGroup( false, G,
                   GeneratorsOfGroup( E ), GeneratorsOfGroup( E ),
                   TrivialSubgroup( G ), TrivialSubgroup( G ) );
end );

InstallOtherMethod( CentralizerOp, "with given subgroup", true,
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
local   Omega,  P,  rbase,  L,mg,mh;
    
    if IsIdenticalObj( G, H )  then
        return G;
    fi;
    
    # align the acting domains
    mg:=MovedPoints(G);
    mh:=MovedPoints(H);
    if IsSubset(mg,mh) and IsSubset(G,H) then
      return H;
    elif IsSubset(mh,mg) and IsSubset(H,G) then
      return G;
    fi;

    G:=Stabilizer(G,Difference(mg,mh),OnTuples);
    H:=Stabilizer(H,Difference(mh,mg),OnTuples);

    Omega := Intersection(mg,mh);
    P := OrbitsPartition( H, Omega );
    rbase := EmptyRBase( [ G, H ], Omega, P );
    rbase.nextLevel := NextRBasePoint;
    
    # L := SubgroupNC( G, Concatenation
    #                 ( Filtered( GeneratorsOfGroup( G ), gen -> gen in H ),
    #                   Filtered( GeneratorsOfGroup( H ), gen -> gen in G ) ) );
    L := TrivialSubgroup( G );
    return PartitionBacktrack( G, H, false, rbase, [ P ], L, L );
end );

#############################################################################
##
#F  TwoClosure( <G> [, <merge> ] ) . . . . . . . . . two-closure
##
TwoClosurePermGroup := function( arg )
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
        Append( merge, Difference( [ 1 .. Length( rbase.suborbits.blists ) ],
                Concatenation( merge ) ) );
    else
        rbase.suborbits := Suborbits( G, [  ], 0, Omega );
        if rbase.suborbits <> false  then
            merge := [ 1 .. Length( rbase.suborbits.blists ) ];
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
            rep := InverseRepresentative( rbase.suborbits.stabChain, fpt );
            strat := StratMeetPartition( rbase, P, Q, rep );
            AddRefinement( rbase, "TwoClosure", [ G, f, Q, strat ] );
            if IsTrivialRBase( rbase )  then  f := false;
                                        else  f := FixcellPoint( P, doneroot );
            fi;
        od;
    end;
    
    Pr := false;
#    # If <G> is primitive and simple, often $G^[2] \le N(G)$.
#    if     IsPrimitive( G, Omega )
#       and IsSimpleGroup( G )  then
#        type := IsomorphismTypeFiniteSimpleGroup( G );
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
        
        adj := List( [ 0 .. LogInt(Length(rbase.suborbits.blists)-1,2) ],
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
                    Add( orb, Position( rbase.suborbits.blists[ i ], true ) );
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
            
            gen := AsPerm( gen );
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
end;

InstallMethod(TwoClosure,"permutation group",true,[IsPermGroup],0,
  TwoClosurePermGroup);


#############################################################################
##
#E

