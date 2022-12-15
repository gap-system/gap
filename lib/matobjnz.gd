#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

# represent vectors/matrices over Z/nZ by nonnegative integer lists
# in the range [0..n-1], but reduce after
# arithmetic. This way avoid always wrapping all entries separately

#############################################################################
##
#R  IsZmodnZVectorRep( <obj> )
##
##  <#GAPDoc Label="IsZmodnZVectorRep">
##  <ManSection>
##  <Filt Name="IsZmodnZVectorRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="IsZmodnZVectorRep"/> describes
##  a vector object (see <Ref Filt="IsVectorObj"/>) with entries in a
##  residue class ring of the ring of integers (see <Ref Func="ZmodnZ"/>).
##  This ring is the base domain
##  (see <Ref Attr="BaseDomain" Label="for a vector object"/>)
##  of <A>obj</A>.
##  <P/>
##  <Ref Filt="IsZmodnZVectorRep"/> implies <Ref Filt="IsCopyable"/>,
##  thus matrix objects in this representation can be mutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  <A>obj</A> is internally represented as a positional object
##  (see <Ref Filt="IsPositionalObjectRep"/>) which stores the base domain
##  (see <Ref Attr="BaseDomain" Label="for a vector object"/>)
##  at position <M>1</M> and a plain list of integers at position <M>2</M>.
##
DeclareRepresentation( "IsZmodnZVectorRep",
        IsVectorObj and IsPositionalObjectRep
    and IsCopyable
    and IsNoImmediateMethodsObject
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );


#############################################################################
##
#R  IsZmodnZMatrixRep( <obj> )
##
##  <#GAPDoc Label="IsZmodnZMatrixRep">
##  <ManSection>
##  <Filt Name="IsZmodnZMatrixRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="IsZmodnZMatrixRep"/> describes
##  a matrix object (see <Ref Filt="IsMatrixObj"/>) that behaves like the
##  list of its rows (see <Ref Filt="IsRowListMatrix"/>).
##  The matrix entries lie in a residue class ring of the ring of integers
##  (see <Ref Func="ZmodnZ"/>).
##  This ring is the base domain
##  (see <Ref Attr="BaseDomain" Label="for a vector object"/>)
##  of <A>obj</A>.
##  <P/>
##  <Ref Filt="IsZmodnZMatrixRep"/> implies <Ref Filt="IsCopyable"/>,
##  thus matrix objects in this representation can be mutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  <A>obj</A> is internally represented as a positional object
##  (see <Ref Filt="IsPositionalObjectRep"/>) with <M>4</M> entries.
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
##    each of them being an object in <Ref Filt="IsZmodnZVectorRep"/>.
##  </Item>
##  </Enum>
##
DeclareRepresentation( "IsZmodnZMatrixRep",
        IsRowListMatrix and IsPositionalObjectRep
    and IsCopyable
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );
