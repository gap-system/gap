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
#V  GF2One  . . . . . . . . . . . . . . . . . . . . . . . . . .  one of GF(2)
##
GF2One := Z(2);


#############################################################################
##
#V  GF2Zero . . . . . . . . . . . . . . . . . . . . . . . . . . zero of GF(2)
##
GF2Zero := 0*Z(2);


#############################################################################
##
#R  IsGF2VectorRep  . . . . . . . . . . . . . . . . . . . . . vector over GF2
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
#F  ConvertToGF2VectorRep( <vector> ) . . . . . . . .  convert representation
##
ConvertToGF2VectorRep := CONV_GF2VEC;


#############################################################################
##
#F  ImmutableGF2VectorRep( <vector> ) . . . . . . . .  convert representation
##
ImmutableGF2VectorRep := function( vector )
    if ForAny( vector, x -> x <> GF2Zero and x <> GF2One )  then
        return fail;
    fi;
    vector := ShallowCopy(vector);
    CONV_GF2VEC(vector);
    SET_TYPE_DATOBJ( vector, TYPE_LIST_GF2VEC_IMM );
    return vector;
end;


#############################################################################
##

#R  IsGF2MatrixRep  . . . . . . . . . . . . . . . . . . . . . matrix over GF2
##
DeclareRepresentation(
    "IsGF2MatrixRep",
    IsPositionalObjectRep, [],
    IsMatrix );


#############################################################################
##
#M  IsOrdinaryMatrix
#M  IsConstantTimeAccessList
#M  IsSmallList
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
#F  SET_LEN_GF2MAT( <list>, <len> ) . . . . .  set the length of a GF2 matrix
##
SET_LEN_GF2MAT := function( list, len )
    list![1] := len;
end;


#############################################################################
##
#F  ConvertToGF2MatrixRep( <matrix> ) . . . . . . . .  convert representation
##
ConvertToGF2MatrixRep := function(matrix)
    local   i;

    if not IsMutable(matrix)  then
        return;
    fi;

    #T 1997/11/3 fceller replace this by `CONV_PLIST'
    if not IsPlistRep(matrix)  then
        return;
    fi;

    # check that we can convert the entries
    for i  in [ 1 .. Length(matrix) ]  do
        if IsMutable(matrix[i]) or not IsGF2VectorRep(matrix[i])  then
            return;
        fi;
    od;

    # put length at position 1
    for i  in [ Length(matrix), Length(matrix)-1 .. 1 ]  do
        matrix[i+1] := matrix[i];
    od;
    matrix[1] := Length(matrix)-1;

    # and convert
    Objectify( TYPE_LIST_GF2MAT, matrix );

end;


#############################################################################
##
#F  ImmutableGF2MatrixRep( <matrix> ) . . . . . . . .  convert representation
##
ImmutableGF2MatrixRep := function(matrix)
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

end;


#############################################################################
##

#F  ImmutableMatrix( <field>, <matrix> ) . convert into "best" representation
##
ImmutableMatrix := function( field, matrix )

    # matrix over GF2
    if IsFinite(field) and Size(field) = 2  then
        return ImmutableGF2MatrixRep(matrix);

    # everything else
    else
        return Immutable(matrix);
    fi;
end;


#############################################################################
##

#E  vecmat.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
