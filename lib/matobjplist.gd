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
# This file is a sample implementation for new style vectors and matrices.
# It stores matrices as dense lists of lists with wrapping.
# This part declares the representations and other type related things,
# and declares some global functions.
#


#############################################################################
##
##  <#GAPDoc Label="IsPlistVectorRep">
##  <ManSection>
##  <Filt Name="IsPlistVectorRep" Arg='obj' Type="representation"/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="IsPlistVectorRep"/> describes
##  a vector object (see <Ref Filt="IsVectorObj"/>) that can occur as a row
##  in a row list matrix
##  (see Section <Ref Subsect="Operations for Row List Matrix Objects"/>).
##  It is internally represented as a positional object
##  (see <Ref Filt="IsPositionalObjectRep"/> that stores two entries:
##  <Enum>
##  <Item>
##    its base domain
##    (see <Ref Attr="BaseDomain" Label="for a vector object"/>)
##    and
##  </Item>
##  <Item>
##    a plain list (see <Ref Filt="IsPlistRep"/> of its entries.
##  </Item>
##  </Enum>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsPlistVectorRep",
        IsVectorObj and IsPositionalObjectRep
    and IsNoImmediateMethodsObject
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );


#############################################################################
##
##  <#GAPDoc Label="IsPlistMatrixRep">
##  <ManSection>
##  <Filt Name="IsPlistMatrixRep" Arg='obj' Type="representation"/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="IsPlistMatrixRep"/> describes
##  a matrix object (see <Ref Filt="IsMatrixObj"/>) that internal stores its
##  entries as a classic GAP matrix, that is as a plain list (see
##  <Ref Filt="IsPlistRep"/>) of plain lists. Therefore any such GAP matrix
##  can be represented as a <Ref Filt="IsPlistMatrixRep"/>, making this
##  representation very versatile, and a good place to start if one wants to
##  adapt code which previously produced such classic GAP matrices to instead
##  produce matrix objects.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Implementation note: a matrix in IsPlistMatrixRep is internally
##  represented as a positional object that stores four entries:
##  - its base domain
#   - the number of rows
##  - the number of columns
##  - a plain list of its rows, each also a plain list
DeclareRepresentation( "IsPlistMatrixRep",
        IsListMatrix and IsPositionalObjectRep
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );


#############################################################################
##
##  <#GAPDoc Label="IsRowPlistMatrixRep">
##  <ManSection>
##  <Filt Name="IsRowPlistMatrixRep" Arg='obj' Type="representation"/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="IsRowPlistMatrixRep"/> describes
##  a matrix object (see <Ref Filt="IsMatrixObj"/>) that behaves similar to
##  a list of its rows, in the sense defined in
##  Section <Ref Sect="Operations for Row List Matrix Objects"/>.
##  Its rows can be accessed as objects in <Ref Filt="IsPlistVectorRep"/>,
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsRowPlistMatrixRep",
        IsRowListMatrix and IsPositionalObjectRep
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );


# Some constants for matrix access:
# TODO rename these so that one can quickly see that they belong to IsPlist*Rep
BindConstant( "BDPOS", 1 );
BindConstant( "NUM_ROWS_POS", 2 );
BindConstant( "NUM_COLS_POS", 3 );
BindConstant( "ROWSPOS", 4 );

# For vector access:
#BindConstant( "BDPOS", 1 );   # see above
BindConstant( "ELSPOS", 2 );

# Two filters to speed up some methods:
DeclareFilter( "IsIntVector" );
DeclareFilter( "IsFFEVector" );
