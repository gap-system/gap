#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file should possibly be called mat8bit.g  (see also vecmat.gd)
##  It provides some things that the kernel needs from the library
##

#############################################################################
##
#R  Is8BitMatrixRep( <obj> ) . . . compressed vector over GFQ (3 <= q <= 256)
##
##  <#GAPDoc Label="Is8BitMatrixRep">
##  <ManSection>
##  <Filt Name="Is8BitMatrixRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="Is8BitMatrixRep"/> describes
##  a matrix object (see <Ref Filt="IsMatrixObj"/>) that behaves like the
##  list of its rows (see <Ref Filt="IsRowListMatrix"/>).
##  The base domain of <A>obj</A> is a field that contains all matrix
##  entries (but not necessarily the smallest such field),
##  it must be a finite field with <M>q</M> elements,
##  for <M>3 \leq q \leq 256</M>.
##  <P/>
##  <Ref Filt="Is8BitMatrixRep"/> implies <Ref Filt="IsCopyable"/>,
##  thus matrix objects in this representation can be mutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  <A>obj</A> is internally represented as a positional object
##  (see <Ref Filt="IsPositionalObjectRep"/>).
##  If the number of rows is <M>n</M> then this object stores <M>n+1</M>
##  entries,
##  <M>n</M> at position <M>1</M> and the <M>i</M>-th row at position
##  <M>i+1</M>.
##  The base domain is not stored explicitly in <A>obj</A>
##  but is determined by the common base domain of the rows of the matrix.
##
DeclareRepresentation( "Is8BitMatrixRep",
        IsPositionalObjectRep and IsRowListMatrix
    and IsCopyable
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain);


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
