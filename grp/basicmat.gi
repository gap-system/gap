#############################################################################
##
#W  basicmat.gi                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file  contains the methods for the  construction of the basic matrix
##  group types.
##
Revision.basicmat_gi :=
    "@(#)$Id$";


#############################################################################
##

#M  CyclicGroupCons( <IsMatrixGroup>, <field>, <n> )
##
InstallOtherMethod( CyclicGroupCons,
    "matrix group for given field",
    true,
    [ IsMatrixGroup and IsFinite,
      IsField,
      IsInt and IsPosRat ],
    0,

function( filter, fld, n )
    local   o,  m,  i;

    o := One(fld);
    m := List( NullMat( n, n, fld ), ShallowCopy );
    for i  in [ 1 .. n-1 ]  do
        m[i][i+1] := o;
    od;
    m[n][1] := o;
    m := Group( Immutable(m) );
    SetSize( m, n );
    return m;
    
end );


#############################################################################
##
#M  CyclicGroupCons( <IsMatrixGroup>, <n> )
##
InstallMethod( CyclicGroupCons,
    "matrix group for default field",
    true,
    [ IsMatrixGroup and IsFinite,
      IsInt and IsPosRat ],
    0,

function( filter, n )
    local   m,  i;

    m := List( NullMat( n, n, Rationals ), ShallowCopy );
    for i  in [ 1 .. n-1 ]  do
        m[i][i+1] := 1;
    od;
    m[n][1] := 1;
    m := Group( Immutable(m) );
    SetSize( m, n );
    return m;
    
end );


#############################################################################
##

#E  basicmat.gd	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
