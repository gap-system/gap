#############################################################################
##
#W  partitio.gi                 GAP library                    Heiko Thei"sen
##
#H  @(#)$Id$
##
##  This    file contains the  functions that    construct and modify ordered
##  partitions. These  functions  are used in  the backtrack  algorithms  for
##  permutation groups.
##
##  A partition is a record with the following components.
##  points : a list of all points contained in the partition, such that
##           points from the same cell are neighboured
##  cellno : a list whose <i>th entry is the number of the cell which
##           contains the point <i>
##  firsts : a list such that <points[firsts[j]]> is the first point in
##           <points> which is in cell <j>
##  lengths: a list of the cell lengths
##
##  This file also contains the general partition backtracking function.
##
#H  $Log$
#H  Revision 4.5  1997/01/20 17:00:26  htheisse
#H  re-introduced `generators'
#H
#H  Revision 4.4  1996/12/19 09:59:10  htheisse
#H  added revision lines
#H
#H  Revision 4.3  1996/11/27 15:32:56  htheisse
#H  replaced `Copy' by `DeepCopy'
#H
#H  Revision 4.2  1996/11/21 16:50:50  htheisse
#H  allowed stabilizer chains as arguments for `OrbitsPartition'
#H
#H  Revision 4.1  1996/09/23 16:47:37  htheisse
#H  added files for permutation groups (incl. backtracking)
#H                  stabiliser chains
#H                  group homomorphisms (of permutation groups)
#H                  operation homomorphisms
#H                  polycyclic generating systems of soluble permutation groups
#H                     (general concept tentatively)
#H
##
Revision.partitio_gi :=
    "@(#)$Id$";

#############################################################################
##
#F  Partition( <list> ) . . . . . . . . . . . . . . . . partition constructor
##
Partition := function( list )
    local   P,  i,  c;
    
    P := rec( points := Concatenation( list ),
              firsts := [  ],
             lengths := [  ] );
    P.cellno := 0 * [ 1 .. Maximum( P.points ) ];
    i := 1;
    for c  in [ 1 .. Length( list ) ]  do
        if Length( list[ c ] ) = 0  then
            Error( "Partition: cells must not be empty" );
        fi;
        Add( P.firsts, i );
        Add( P.lengths, Length( list[ c ] ) );
        i := i + Length( list[ c ] );
        P.cellno{ list[ c ] } := c + 0 * list[ c ];
    od;
    return P;
end;

#############################################################################
##
#F  IsEqualPartition( <P>, <Q> )  . . . . . . . . . . . . . . . equality test
##
IsEqualPartition := function( P, Q )
    return P.cellno = Q.cellno;
end;

#############################################################################
##
#F  OnPartitions( <P>, <g> )  . . . . . . . permutations acting on partitions
##
OnPartitions := function( P, g )
    local   Q,  i;
    
    Q := DeepCopy( P );
    Q.points := OnTuples( P.points, g );
    Q.cellno := [  ];
    for i  in [ 1 .. Length( P.cellno ) ]  do
        if IsBound( P.cellno[ i ] )  then
            Q.cellno[ i ^ g ] := P.cellno[ i ];
        fi;
    od;
    return Q;
end;
      
#############################################################################
##
#F  IsPartition( <P> )  . . . . . . . . . . . . test if object is a partition
##
IsPartition := function( P )
    return IsRecord( P )  and  IsBound( P.cellno );
end;

#############################################################################
##
#F  PointsPartition( <P> )  . . . . . . . . .  points involved in a partition
##
PointsPartition := function( P )
    return Set( P.points );
end;

#############################################################################
##
#F  NumberCells( <P> )  . . . . . . . . . . . . . . . . . . . number of cells
##
NumberCells := function( P )
    return Length( P.firsts );
end;

#############################################################################
##
#F  Cell( <P>, <m> )  . . . . . . . . . . . . . . . . . . . . .  cell as list
##
Cell := function( P, m )
    return P.points{ [ P.firsts[m] .. P.firsts[m] + P.lengths[m] - 1 ] };
end;

#############################################################################
##
#F  Fixcells( <P> ) . . . . . . . . . . . . . . . . . . . .  fixcells as list
##
Fixcells := function( P )
    local   fix,  i;
    
    fix := [  ];
    for i  in [ 1 .. Length( P.lengths ) ]  do
        if P.lengths[ i ] = 1  then
            Add( fix, P.points[ P.firsts[ i ] ] );
        fi;
    od;
    return fix;
end;

#############################################################################
##
#F  SplitCell( <P>, <i>, <Q>, <j>, <g> )  . . . . . . . . . . .  split a cell
##
SplitCell := function( P, i, Q, j, g, out )
    local   a,  b,  l,  B,  tmp,  m,  x,  k;

    a := P.firsts[ i ];
    b := a + P.lengths[ i ];
    l := b - 1;
    
    # If none or  all  points are  moved out,  do  not change <P>  and return
    # 'false'.
    if out <> true  then
        x := Q{ OnTuples( P.points{ [ a .. l ] }, g ) };
        if x = j + 0 * x  or  ForAll( x, i -> i <> j )  then
            return false;
        fi;
    fi;

    # Collect  the points to  be moved out of  the <i>th  cell  of <P> at the
    # right.
    a := a - 1;
    if out <> true  then  B := l - out;
                    else  B := 0;        fi;
    if B > 0  then
        while a < b  do
            repeat
                b := b - 1;
                if b < B  then
                    return false;
                fi;
            until Q[ P.points[ b ] ^ g ] <> j;
            repeat
                a := a + 1;
            until Q[ P.points[ a ] ^ g ] =  j;
            if a < b  then
                tmp := P.points[ a ];
                P.points[ a ] := P.points[ b ];
                P.points[ b ] := tmp;
            fi;
        od;
    else
        while a < b  do
            repeat
                b := b - 1;
            until Q[ P.points[ b ] ^ g ] <> j;
            repeat
                a := a + 1;
            until Q[ P.points[ a ] ^ g ] =  j;
            if a < b  then
                tmp := P.points[ a ];
                P.points[ a ] := P.points[ b ];
                P.points[ b ] := tmp;
            fi;
        od;
    fi;

    # Split the cell and introduce a new cell into <P>.
    m := Length( P.firsts ) + 1;
    P.cellno{ P.points{ [ a .. l ] } } := m + 0 * [ a .. l ];
    P.firsts[ m ] := a;
    P.lengths[ m ] := l - a + 1;
    P.lengths[ i ] := P.lengths[ i ] - P.lengths[ m ];
    
    return P.lengths[ m ];
end;

#############################################################################
##
#F  IsolatePoint( <P>, <a> )  . . . . . . . . . . . . . . . . isolate a point
##
IsolatePoint := function( P, a )
    local   i,  pos,  l,  m;
    
    i := P.cellno[ a ];
    if P.lengths[ i ] = 1  then
        return false;
    fi;
    
    pos := Position( P.points, a, P.firsts[ i ] - 1 );
    l := P.firsts[ i ] + P.lengths[ i ] - 1;
    P.points[ pos ] := P.points[ l ];
    P.points[ l ] := a;
    
    m := Length( P.firsts ) + 1;
    P.cellno[ a ] := m;
    P.firsts[ m ] := l;
    P.lengths[ m ] := 1;
    P.lengths[ i ] := P.lengths[ i ] - 1;
    return i;
end;

#############################################################################
##
#F  UndoRefinement( <P> ) . . . . . . . . . . . . . . . . . undo a refinement
##
UndoRefinement := function( P )
    local   M,  m;
    
    M := Length( P.firsts );
    if P.firsts[ M ] = 1  then
        return false;
    fi;
    
    m := P.cellno[ P.points[ P.firsts[ M ] - 1 ] ];
    P.lengths[ m ] := P.lengths[ m ] + P.lengths[ M ];
    P.cellno{ P.points
            { [ P.firsts[ M ] .. P.firsts[ M ] + P.lengths[ M ] - 1 ] } }
      := m + 0 * [ 1 .. P.lengths[ M ] ];
    Unbind( P.firsts[ M ] );
    Unbind( P.lengths[ M ] );
    
    return m;
end;

#############################################################################

#F  Cells( <Pi> ) . . . . . . . . . . . . . . . . . partition as list of sets
##
Cells := function( Pi )
    local  cells,  i;
    
    cells := [  ];
    for i  in Reversed( [ 1 .. NumberCells( Pi ) ] )  do
        cells[ i ] := Cell( Pi, i );
    od;
    return cells;
end;

#############################################################################
##
#F  FixpointCellNo( <P>, <i> )  . . . . . . . . .  fixpoint from cell no. <i>
##
FixpointCellNo := function( P, i )
    return P.points[ P.firsts[ i ] ];
end;

#############################################################################
##
#F  FixcellPoint( <P>, <old> )  . . . . . . . . . . . . . . . . . . . . local
##
FixcellPoint := function( P, old )
    local   lens,  poss,  p;
    
    lens := P.lengths;
    poss := Filtered( [ 1 .. Length( lens ) ], i ->
                    not i in old  and  lens[ i ] = 1 );
    if Length( poss ) = 0  then
        return false;
    else
        p := Random( poss );
        AddSet( old, p );
        return p;
    fi;
end;

#############################################################################
##
#F  FixcellsCell( <P>, <cellno>, <conj>, <old> )  . . . . . . . . . . . local
##
FixcellsCell := function( P, cellno, conj, old )
    local   K,  I,  i,  k,  start;
    
    K := [  ];  I := [  ];
    for i  in [ 1 .. NumberCells( P ) ]  do
        start := P.firsts[ i ];
        k := cellno[ P.points[ start ] ^ conj ];
        if     not k in old
           and ForAll( start + [ 1 .. P.lengths[ i ] - 1 ], j ->
                       cellno[ P.points[ j ] ^ conj ] = k ) then
            AddSet( old, k );
            Add( K, k );  Add( I, i );
        fi;
    od;
    if Length( K ) = 0  then  return false;
                        else  return [ K, I ];  fi;
end;

#############################################################################
##

#F  TrivialPartition( <Omega> ) . . . . . . . . . one-cell partition of a set
##
TrivialPartition := function( Omega )
    return Partition( [ Omega ] );
end;

#############################################################################
##
#F  OrbitsPartition( <G>, <Omega> ) partition determined by the orbits of <G>
##
OrbitsPartition := function( G, Omega )
    if IsGroup( G )  then
        return Partition( Orbits( G, Omega ) );
    else
        return Partition( OrbitsPerms( G.generators, Omega ) );
    fi;
end;

#############################################################################
##
#F  SmallestPrimeDivisor( <size> )  . . . . . . . . .  smallest prime divisor
##
SmallestPrimeDivisor := function( size )
    local   i;
    
    i := 0;
    if size = 1  then
        return 1;
    else
        repeat
            i := i + 1;
        until i > Length( Primes )  or  size mod Primes[ i ] = 0;
        if i > Length( Primes )  then  return FactorsInt( size )[ 1 ];
                                 else  return Primes[ i ];              fi;
    fi;
end;

#############################################################################
##
#F  CollectedPartition( <P>, <size> ) . orbits on cells under group of <size>
##
CollectedPartition := function( P, size )
    local   lens,  C,  div,  typ,  p,  i;

    lens := P.lengths;
    C    := [  ];
    div  := SmallestPrimeDivisor( size );
    for typ  in Collected( lens )  do
        p := [  ];
        for i  in [ 1 .. Length( lens ) ]  do
            if lens[ i ] = typ[ 1 ]  then
                Add( p, Cell( P, i ) );
            fi;
        od;
        if typ[ 2 ] < div  then
            Append( C, p );
        else
            Add( C, Concatenation( p ) );
        fi;
    od;
    return Partition( C );
end;

#############################################################################
##

#E  Emacs variables . . . . . . . . . . . . . . local variables for this file
##  Local Variables:
##  mode:             gap
##  mode:             outline-minor
##  outline-regexp:   "#[AEFTV]"
##  fill-column:      77
##  End:
#############################################################################
