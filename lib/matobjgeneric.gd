#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

############################################################################
#
# Dense matrix objects backed by plain lists of plain row lists.
#

#############################################################################
##
##  <#GAPDoc Label="IsGenericMatrixRep">
##  <ManSection>
##  <Filt Name="IsGenericMatrixRep" Arg='obj' Type="Representation"/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="IsGenericMatrixRep"/> describes
##  a matrix object (see <Ref Filt="IsMatrixObj"/>) whose entries are stored
##  as a dense plain list of dense plain row lists.
##  <P/>
##  This representation is optimized for efficient entry access via
##  <M>M[i,j]</M>. Unlike <Ref Filt="IsPlistMatrixRep"/>, it is not a row
##  list matrix, so direct row access via <M>M[i]</M> is not supported.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsGenericMatrixRep",
        IsMatrixObj and IsPositionalObjectRep
    and IsCopyable
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );


# Internal positions for flat plist matrices.
BindConstant( "FBDPOS", 1 );
BindConstant( "FCOLSPOS", 2 );
BindConstant( "FROWSPOS", 3 );
