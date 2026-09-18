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
##  Unlike <Ref Filt="IsPlistMatrixRep"/>, this representation is not a row
##  list matrix, so direct row access via <M>M[i]</M> is not supported.
##  Instead, it is intended as the general-purpose representation for
##  matrix objects.
##  <P/>
##  This representation supports the usual matrix operations and is often more
##  efficient than <Ref Filt="IsPlistMatrixRep"/>. If existing code uses row
##  access, it is often possible to replace this by the operations from
##  Section <Ref Sect="Basic operations for row/column reductions"/>.
##  <P/>
##  Use <Ref Filt="IsPlistMatrixRep"/> instead if you need the rows to be
##  available as vector objects in <Ref Filt="IsPlistVectorRep"/>.
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


# Internal positions for IsGenericMatrixRep:
BindConstant( "GEN_MAT_REP_BASEDOMAIN_POS", 1 ); # BaseDomain
BindConstant( "GEN_MAT_REP_NCOLS_POS", 2 ); # number of columns (needed to represent 0 x m matrices)
BindConstant( "GEN_MAT_REP_ROWS_POS", 3 ); # "rows" as a plist-of-plists
