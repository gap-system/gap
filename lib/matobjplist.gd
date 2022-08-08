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
##  (see <Ref Filt="IsPositionalObjectRep"/> that stores 2 entries:
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
##  (see <Ref Filt="IsPositionalObjectRep"/> that stores 4 entries:
##  <Enum>
##  <Item>
##    its base domain
##    (see <Ref Attr="BaseDomain" Label="for a matrix object"/>),
##  </Item>
##  <Item>
##    an empty vector in the representation of each row, 
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
BindGlobal( "BDPOS", 1 );
BindGlobal( "EMPOS", 2 );
BindGlobal( "RLPOS", 3 );
BindGlobal( "ROWSPOS", 4 );

# For vector access:
#BindGlobal( "BDPOS", 1 );   # see above
BindGlobal( "ELSPOS", 2 );

# Two filters to speed up some methods:
DeclareFilter( "IsIntVector" );
DeclareFilter( "IsFFEVector" );

############################################################################
# Constructors:
############################################################################

#T Should this be documented?
#T It seems to be just an auxiliary function for the documented constructors.
DeclareGlobalFunction( "MakePlistVectorType" );

