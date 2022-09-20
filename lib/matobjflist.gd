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
# This is an implementation for nxm matrices 
# stored as a flat n*m element list. In this 
# file the representation, types and global 
# functions are declared.


#############################################################################
##
##  <#GAPDoc Label="IsFlistMatrixRep">
##  <ManSection>
##  <Filt Name="IsFlistMatrixRep" Arg='obj' Type="representation"/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="IsFlistMatrixRep"/> describes
##  a matrix object that stores the matrix entries as a flat lost. It is 
##  internally represented as a positional object
##  (see <Ref Filt="IsPositionalObjectRep"/> that stores 4 entries:
##  <Enum>
##  <Item>
##    its base domain
##    (see <Ref Attr="BaseDomain" Label="for a matrix object"/>),
##  </Item>
##  <Item>
##    the number of rows (see <Ref Attr="NumberRows" Label="for a matrix object"/>), 
##  </Item>
##  <Item>
##    the number of columns
##    (see <Ref Attr="NumberColumns" Label="for a matrix object"/>), and
##  </Item>
##  <Item>
##    a plain list (see <Ref Filt="IsPlistRep"/> of its entries.
##  </Item>
##  </Enum>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareRepresentation( "IsFlistMatrixRep",
        IsPositionalObjectRep
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );


# Some constants for matrix access:
# Position in the positional object of the base domain
BindGlobal( "FLISTREP_BDPOS", 1 );
# Position in the positional object of the number of rows
BindGlobal( "FLISTREP_NRPOS", 2 );
# Position in the positional object of the number of columns
BindGlobal( "FLISTREP_NCPOS", 3 );
# Position in the positional object of the list of entries
BindGlobal( "FLISTREP_ELSPOS", 4 );

############################################################################
# Constructors:
############################################################################

#T Should this be documented?
#T It seems to be just an auxiliary function for the documented constructors.
#DeclareGlobalFunction( "MakeFlistVectorType" );

