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
##  a matrix object (see <Ref Filt="IsMatrixObj"/>) that behaves similar to
##  a list of its rows, in the sense defined in
##  Section <Ref Sect="Operations for Row List Matrix Objects"/>.
##  It is internally represented as a positional object
##  (see <Ref Filt="IsPositionalObjectRep"/> that stores four entries:
##  <Enum>
##  <Item>
##    its base domain
##    (see <Ref Attr="BaseDomain" Label="for a matrix object"/>),
##  </Item>
##  <Item>
##    the number of rows
##    (see <Ref Attr="NumberRows" Label="for a matrix object"/>), and
##  </Item>
##  <Item>
##    the number of columns
##    (see <Ref Attr="NumberColumns" Label="for a matrix object"/>), and
##  </Item>
##  <Item>
##    a plain list (see <Ref Filt="IsPlistRep"/> of its rows,
##    each of them being an object in <Ref Filt="IsPlistVectorRep"/>.
##  </Item>
##  </Enum>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsPlistMatrixRep",
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
