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
##  a matrix object that stores the matrix entries as a flat list. It is 
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
# Here we declare the new representation and tell GAP which properties it
# implies. FListMatrices e.g. are positional objects and so on.
DeclareRepresentation( "IsFlistMatrixRep",
        IsMatrixObj and IsMatrixOrMatrixObj and IsPositionalObjectRep
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );

# If we implement our object a a positional object we often have to access its
# properties in the code. To make that more readable we declare global
# variables. If you do this too make sure you use variables that are unique and
# unlikely to be used someplace else, even though that might mean using longer
# names. Here we prefixed the names with the name of the representation. See
# also Reference Manual Chapter 79 for more information about Objects.

# Some constants for matrix access:
# Position in the positional object of the base domain
BindGlobal( "FLISTREP_BDPOS", 1 );
# Position in the positional object of the number of rows
BindGlobal( "FLISTREP_NRPOS", 2 );
# Position in the positional object of the number of columns
BindGlobal( "FLISTREP_NCPOS", 3 );
# Position in the positional object of the list of entries
BindGlobal( "FLISTREP_ELSPOS", 4 );