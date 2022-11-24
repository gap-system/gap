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
# This is a minimal implementation for nxm matrices 
# stored as a flat n*m element list. In this 
# file the representation, types and global 
# functions are declared.
# This implementation should not be used for actual computations. It serves
# as an example for a minimal MatrixObj implementation and can be used to test
# various things.


#############################################################################
##
##  <#GAPDoc Label="IsMinimalBROKENMatrixRep">
##  <ManSection>
##  <Filt Name="IsMinimalBROKENMatrixRep" Arg='obj' Type="representation"/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="IsMinimalBROKENMatrixRep"/> describes
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
##  It implements the MatrixObj specification in a minimal way, that is it 
##  implements exactly the required methods. This is intended for testing and
##  development and should not be used for actual calculations!
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
# Here we declare the new representation and tell GAP which properties it
# implies. This minimal example is implemented as a positional object 
# like IsFlistMatrixRep and IsPlistMatrixRep.
DeclareRepresentation( "IsMinimalBROKENMatrixRep",
        IsMatrixObj and IsMatrixOrMatrixObj and IsPositionalObjectRep
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );

# If we implement our object as a positional object we often have to access its
# properties in the code. To make that more readable we declare global
# variables. If you do this too make sure you use variables that are unique and
# unlikely to be used someplace else, even though that might mean using longer
# names. Here we prefixed the names with the name of the representation. See
# also Reference Manual Chapter 79 for more information about Objects.

# Some constants for matrix access:
# Position in the positional object of the base domain
BindConstant( "MINREP_BDPOS", 1 );
# Position in the positional object of the number of rows
BindConstant( "MINREP_NRPOS", 2 );
# Position in the positional object of the number of columns
BindConstant( "MINREP_NCPOS", 3 );
# Position in the positional object of the list of entries
BindConstant( "MINREP_ELSPOS", 4 );
