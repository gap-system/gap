#############################################################################
##
#W  mat8bit.gd                   GAP Library                     Steve Linton
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file should possibly be called mat8bit.g  (see also vecmat.gd)
##  It provides some things that the kernel needs from the library 
##

#############################################################################
##
#R  Is8BitMatrixRep( <obj> ) . . . compressed vector over GFQ (3 <= q <= 256)
##
DeclareRepresentation( "Is8BitMatrixRep", 
        IsPositionalObjectRep and IsRowListMatrix,[],
        IsMatrix );

#############################################################################
##
#v  TYPES_MAT8BIT . . . . . . . . prepared types for compressed GF(q) vectors
##
##  A length 2 list of length 257 lists. TYPES_MAT8BIT[1][q] will be the type
##  of mutable vectors over GF(q), TYPES_MAT8BIT[2][q] is the type of 
##  immutable vectors. The 257th position is bound to 1 to stop the lists
##  shrinking.
##
##  It is accessed directly by the kernel, so the format cannot be changed
##  without changing the kernel.
##
DeclareGlobalVariable( "TYPES_MAT8BIT" );

#############################################################################
##
#F  TYPE_MAT8BIT( <q>, <mut> ) . .  computes type of compressed GF(q) vectors
##
##  Normally called by the kernel, caches results in TYPES_MAT8BIT
##
DeclareGlobalFunction( "TYPE_MAT8BIT" );


#############################################################################
##
#M  IsConstantTimeAccessList( <obj> )
#M  IsSmallList( <obj> )
#M  IsListDefault( <obj> )
##
##  All compressed GF(q) vectors are small and constant-time access,
##  and support the default list arithmetic (multiplication and addition).
##

InstallTrueMethod( IsConstantTimeAccessList, IsList and Is8BitMatrixRep );
InstallTrueMethod( IsSmallList, IsList and Is8BitMatrixRep );
InstallTrueMethod( IsListDefault, IsList and Is8BitMatrixRep );

#############################################################################
##
#F  RepresentationsOfMatrix( <mat/vec> )
##
##  This function is envisaged as a debugging tool. It prints a description
##  of the storage of the argument matrix or vector, indicating
##  whether the matrix and/or its rows are compressed, over what fields,
##  whether they are mutable or immutable and whether they are locked.
##

DeclareGlobalFunction( "RepresentationsOfMatrix" );

#############################################################################
##
#E

