#############################################################################
##
#W  vecmat.gd                   GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the basic operations for creating and doing arithmetic
##  with vectors.
##
Revision.vecmat_gd :=
    "@(#)$Id$";


#############################################################################
##
#v  GF2One  . . . . . . . . . . . . . . . . . . . . . . . . . .  one of GF(2)
##
BIND_GLOBAL( "GF2One", Z(2) );


#############################################################################
##
#v  GF2Zero . . . . . . . . . . . . . . . . . . . . . . . . . . zero of GF(2)
##
BIND_GLOBAL( "GF2Zero", 0*Z(2) );


#############################################################################
##
#R  IsGF2VectorRep( <obj> ) . . . . . . . . . . . . . . . . . vector over GF2
##
DeclareRepresentation(
    "IsGF2VectorRep",
    IsDataObjectRep, [],
    IsRowVector );


#############################################################################
##
#V  TYPE_LIST_GF2VEC  . . . . . . . . . . . . . . type of mutable GF2 vectors
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2VEC",
    "type of a packed GF2 vector" );


#############################################################################
##
#V  TYPE_LIST_GF2VEC_IMM  . . . . . . . . . . . type of immutable GF2 vectors
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2VEC_IMM",
    "type of a packed, immutable GF2 vector" );

#############################################################################
##
#V  TYPE_LIST_GF2VEC_IMM_LOCKED . . . . . . . . type of immutable GF2 vectors
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2VEC_IMM_LOCKED",
    "type of a packed, immutable GF2 vector with representation lock" );

#############################################################################
##
#V  TYPE_LIST_GF2VEC_LOCKED . . . . . . . . type of mutable GF2 vectors
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2VEC_LOCKED",
    "type of a packed, mutable GF2 vector with representation lock" );


#############################################################################
##
#F  ConvertToGF2VectorRep( <vector> ) . . . . . . . .  convert representation
##
DeclareSynonym( "ConvertToGF2VectorRep", CONV_GF2VEC );

#############################################################################
##
#F  ConvertToVectorRep( <list> )
#F  ConvertToVectorRep( <list> , <field> )
#F  ConvertToVectorRep( <list> , <fieldsize> )
##
##  `ConvertToVectorRep( <list> )' converts <list> to an internal
##  vector representation if possible.
##
##  `ConvertToVectorRep( <list> , <field> )' converts <list> to an
##  internal vector representation appropriate for a vector over
##  <field>.
##  It is forbidden to call this function unless <list> is a plain
##  list or a vector, <field> a field, and all elements
##  of <list> lie in <field>, violation of this condition can lead to
##  unpredictable behaviour or a system crash.
##
##  Instead of a <field> also its size <fieldsize> may be given.
##
##  <list> may already be a compressed vector. In this case, if no
##  <field> or <fieldsize> is given, then nothing happens. If one is
##  given then the vector is rewritten as a compressed vector over the
##  given <field> unless it has the filter
##  `IsLockedRepresentationVector', in which case it is not changed.
##
##  The return value is the size of the field over which the vector
##  ends up written, if it is written in a compressed representation.
##  Otherwise it is `true' if the vector does consist entirely of elements
##  of finite fields and `fail' otherwise.
##  
##
DeclareGlobalFunction( "ConvertToVectorRep");

#############################################################################
##
#F  ConvertToMatrixRep( <list> )
#F  ConvertToMatrixRep( <list>, <field> )
#F  ConvertToMatrixRep( <list>, <fieldsize> )
##
##  `ConvertToMatrixRep( <list> )' converts <list> to an internal
##  matrix representation if possible.  `ConvertToMatrixRep( <list> ,
##  <field> )' converts <list> to an internal matrix representation
##  appropriate for a matrix over <field>. It is forbidden to call
##  this function unless all elements of <list> are vectors with
##  entries in  <field>.
##
##  Instead of a <field> also its size <fieldsize> may be given.
##
##  <list> may already be a compressed matrix. In this case, if no
##  <field> or <fieldsize> is given, then nothing happens.
##
##  <list> itself may be mutable, but its entries must be immutable.
##
##  The return value is the size of the field over which the matrix
##  ends up written, if it is written in a compressed representation.
##  Otherwise it is `fail'. 
##
##

DeclareGlobalFunction( "ConvertToMatrixRep");

#############################################################################
##
#F  ImmutableGF2VectorRep( <vector> ) . . . . . . . .  convert representation
##
BIND_GLOBAL( "ImmutableGF2VectorRep", function( vector )
    if ForAny( vector, x -> x <> GF2Zero and x <> GF2One )  then
        return fail;
    fi;
    vector := ShallowCopy(vector);
    CONV_GF2VEC(vector);
    SET_TYPE_DATOBJ( vector, TYPE_LIST_GF2VEC_IMM );
    return vector;
end );


#############################################################################
##

#R  IsGF2MatrixRep( <obj> ) . . . . . . . . . . . . . . . . . matrix over GF2
##
DeclareRepresentation(
    "IsGF2MatrixRep",
    IsPositionalObjectRep, [],
    IsMatrix );


#############################################################################
##
#M  IsOrdinaryMatrix( <obj> )
#M  IsConstantTimeAccessList( <obj> )
#M  IsSmallList( <obj> )
##
##  Lists in `IsGF2VectorRep' and `IsGF2MatrixRep' are (at least) as good
##  as lists in `IsInternalRep' w.r.t.~the above filters.
##
InstallTrueMethod( IsConstantTimeAccessList, IsList and IsGF2VectorRep );
InstallTrueMethod( IsSmallList, IsList and IsGF2VectorRep );

InstallTrueMethod( IsOrdinaryMatrix, IsMatrix and IsGF2MatrixRep );
InstallTrueMethod( IsConstantTimeAccessList, IsList and IsGF2MatrixRep );
InstallTrueMethod( IsSmallList, IsList and IsGF2MatrixRep );


#############################################################################
##
#V  TYPE_LIST_GF2MAT  . . . . . . . . . . . . .  type of mutable GF2 matrices
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2MAT",
    "type of a packed GF2 matrix" );


#############################################################################
##
#V  TYPE_LIST_GF2MAT_IMM  . . . . . . . . . .  type of immutable GF2 matrices
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2MAT_IMM",
    "type of a packed, immutable GF2 matrix" );



#############################################################################
##
#F  ConvertToGF2MatrixRep( <matrix> ) . . . . . . . .  convert representation
##

DeclareSynonym( "ConvertToGF2MatrixRep", CONV_GF2MAT);


#############################################################################
##
#F  ImmutableGF2MatrixRep( <matrix> ) . . . . . . . .  convert representation
##
BIND_GLOBAL( "ImmutableGF2MatrixRep", function(matrix)
    local   new,  i,  row;

    # put length at position 1
    new := [ Length(matrix) ];
    for i  in matrix  do
        row := ImmutableGF2VectorRep(i);
        if row = fail  then
            return fail;
        fi;
        Add( new, row );
    od;

    # convert
    Objectify( TYPE_LIST_GF2MAT_IMM, new );

    # and return new matrix
    return new;

end );


#############################################################################
##
#F  ConvertedMatrix( <field>, <matrix> [, <imm>] )
##
##  returns a matrix equal to <matrix> which is in the most
##  compact representation possible over <field>. If <imm> is true, the
##  result is immutable. The input matrix <matrix> or
##  its rows might change the representation or become immutable in this
##  process, however the result of `ConvertedMatrix' is not necessarily
##  *identical* to <matrix> if a conversion is not possible.
##  
##  Note: Because the input can be of all possible forms, calling
##  `ConvertToMatrixRep' on a matrix obtained as input might lead to
##  problems.
DeclareGlobalFunction( "ConvertedMatrix");

#############################################################################
##
#F  ImmutableMatrix( <field>, <matrix> ) . convert into "best" representation
##
##  returns `ConvertedMatrix(<field>,<matrix>,<true>)'.
DeclareGlobalFunction( "ImmutableMatrix");


#############################################################################
##
#O  NumberFFVector(<vec>,<sz>)
##
##  returns an integer that gives the position of the finite field row vector
##  (<vec>) in the sorted list of all row vectors over the field with <sz>
##  elements in the same dimension as <vec>. `NumberFFVector' returns `fail'
##  if the vector cannot be represented over the field with <sz> elements.
DeclareOperation("NumberFFVector", [IsRowVector,IsPosInt]);
  
  
#############################################################################
##
#E

