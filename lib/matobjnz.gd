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
##
##  Dense vector objects over rings 'Integers mod n',
##  backed by plain lists of integers.
##  Dense matrix objects over rings 'Integers mod n',
##  backed by plain lists of plain lists of integers.
##
##  The code for vectors and matrices in the filters
##  <Ref Filt="IsZmodnZVectorRep"/> and <Ref Filt="IsZmodnZMatrixRep"/>
##  was adapted from that for the filters
##  <Ref Filt="IsPlistVectorRep"/> and <Ref Filt="IsGenericMatrixRep"/>.
##  <P/>
##  the idea is that a vector in <Ref Filt="IsZmodnZVectorRep"/> is given by
##  a plain list of reduced integers,
##  and that a matrix in <Ref Filt="IsZmodnZMatrixRep"/> is given by
##  a plain list of plain lists of reduced integers.
##  <P/>
##  In particular, a matrix in <Ref Filt="IsZmodnZMatrixRep"/> does not store
##  rows that are in <Ref Filt="IsZmodnZVectorRep"/>.
##  <P/>
##  The main differences between <Ref Filt="IsZmodnZVectorRep"/> and
##  <Ref Filt="IsPlistVectorRep"/>
##  (and between <Ref Filt="IsZmodnZMatrixRep"/> and
##  <Ref Filt="IsGenericMatrixRep"/>) are as follows.
##  <P/>
##  <List>
##  <Item>
##   The <Ref Attr="BaseDomain"/> for an <Ref Filt="IsZmodnZVectorRep"/>
##   object is <C>Integers mod n</C> for some positive integer <C>n</C>,
##   hence no special handling of certain base domains is needed.
##  </Item>
##  <Item>
##   The entries of a <Ref Filt="IsZmodnZVectorRep"/> or
##   <Ref Filt="IsZmodnZMatrixRep"/> object are elements of the base domain,
##   but integers are stored internally.
##   This means that fetching or setting single entries requires a
##   conversion from an integer to a <Ref Filt="IsZmodnZObj"/> or vice versa.
##  </Item>
##  <Item>
##   Moreover, the stored integers are assumed to lie in range
##   <C>[ 0 .. n-1 ]</C>.
##   This means that all functions that create or modify the objects must
##   perform the necessary reductions.
##   In particular, <C>MakeIsZmodnZVectorRep</C> and
##   <C>MakeIsZmodnZMatrixRep</C> check this property
##   if the argument <A>check</A> is 'true'.
##  </Item>
##  <Item>
##   The functions <Ref Oper="NewVector"/>, <Ref Oper="Vector"/>,
##   <Ref Oper="NewMatrix"/>, and <Ref Oper="Matrix"/> admit
##   (nested) lists of integers or of <Ref Filt="IsZmodnZObj"/> objects,
##   and the former is actually preferred because it avoids the creation of
##   lots of <Ref Filt="IsZmodnZObj"/> objects.
##   <P/>
##   Note that the integers in the input must lie in <C>[ 0 .. n-1 ]</C>,
##   this is checked if the global option <C>"check"</C> is not set to
##   <K>false</K>.
##   (Always automatically reducing the entries of the input modulo <C>n</C>
##   would not be a good idea since the input is often expected to be
##   reduced.)
##  </Item>
##  <Item>
##   We assume that the entries are in
##   <Ref Filt="CanEasilyCompareElements"/>, hence we need not deal with the
##   question whether this filter shall be set (depending on the base domain).
##  </Item>
##  <Item>
##   In order to do the computations really only with lists of integers
##   whenever possible, we have to avoid calls to <C>Unpack</C> as well as
##   access to entries of the vectors or matrices.
##   This means that many of the default methods must be overloaded.
##  </Item>
##  </List>


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
##  thus vector objects in this representation can be mutable.
##  <P/>
##  <Ref Filt="IsZmodnZVectorRep"/> is the default representation that is
##  chosen by <Ref Oper="Vector" Label="for base domain and list"/> and
##  <Ref Oper="ZeroVector" Label="for base domain and length"/> if the
##  given <Ref Attr="BaseDomain" Label="for a vector object"/> <M>R</M>
##  consists of objects in <Ref Filt="IsZmodnZObj"/>, that is,
##  if <M>R</M> is of the form <C>Integers mod </C><M>n</M> for some integer
##  <M>n</M> that is either not a prime or a prime larger than <M>2^{16}</M>.
##  In the latter case, <C>Integers mod </C><M>n</M> can be obtained also
##  as <C>GF</C><M>(n)</M>.
##  For prime <M>n</M> smaller than <M>2^{16}</M>,
##  one can create vector objects in <Ref Filt="IsZmodnZVectorRep"/> over
##  <C>Integers mod </C><M>n</M> by entering <Ref Filt="IsZmodnZVectorRep"/>
##  as the first argument of
##  <Ref Oper="Vector" Label="for filter, base domain, and list"/> and
##  <Ref Oper="ZeroVector" Label="for filter, base domain and length"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  <A>obj</A> is internally represented as a positional object
##  (see <Ref Filt="IsPositionalObjectRep"/>) which stores the base domain
##  (see <Ref Attr="BaseDomain" Label="for a vector object"/>)
##  at position <C>ZBDPOS</C> and a plain list of reduced integers at position
##  <C>ZELSPOS</C>.
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
##  a matrix object (see <Ref Filt="IsMatrixObj"/>) with entries in a
##  residue class ring of the ring of integers (see <Ref Func="ZmodnZ"/>).
##  This ring is the base domain
##  (see <Ref Attr="BaseDomain" Label="for a matrix object"/>)
##  of <A>obj</A>.
##  <P/>
##  <Ref Filt="IsZmodnZMatrixRep"/> implies <Ref Filt="IsCopyable"/>,
##  thus matrix objects in this representation can be mutable.
##  <P/>
##  <Ref Filt="IsZmodnZMatrixRep"/> does not imply
##  <Ref Filt="IsRowListMatrix"/>,
##  so direct row access via <M>M[i]</M> is not supported.
##  <P/>
##  <Ref Filt="IsZmodnZMatrixRep"/> is the default representation that is
##  chosen by <Ref Oper="Matrix" Label="for base domain, list, ncols"/> and
##  <Ref Oper="ZeroMatrix" Label="for base domain and dimensions"/> if the
##  given <Ref Attr="BaseDomain" Label="for a matrix object"/> <M>R</M>
##  consists of objects in <Ref Filt="IsZmodnZObj"/>, that is,
##  if <M>R</M> is of the form <C>Integers mod </C><M>n</M> for some integer
##  <M>n</M> that is either not a prime or a prime larger than <M>2^{16}</M>.
##  In the latter case, <C>Integers mod </C><M>n</M> can be obtained also
##  as <C>GF</C><M>(n)</M>.
##  For prime <M>n</M> smaller than <M>2^{16}</M>,
##  one can create vector objects in <Ref Filt="IsZmodnZMatrixRep"/> over
##  <C>Integers mod </C><M>n</M> by entering <Ref Filt="IsZmodnZMatrixRep"/>
##  as the first argument of
##  <Ref Oper="Matrix" Label="for filter, base domain, list, ncols"/> and
##  <Ref Oper="ZeroMatrix" Label="for filter, base domain, and dimensions"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  <A>obj</A> is internally represented as a positional object
##  (see <Ref Filt="IsPositionalObjectRep"/>) with <M>3</M> entries.
##  <Enum>
##  <Item>
##    its base domain
##    (see <Ref Attr="BaseDomain" Label="for a matrix object"/>)
##    at position <C>ZBDPOS</C>,
##  </Item>
##  <Item>
##    the number of columns
##    (see <Ref Attr="NumberColumns" Label="for a matrix object"/>)
##    at position <C>ZCOLSPOS</C>, and
##  </Item>
##  <Item>
##    a plain list (see <Ref Filt="IsPlistRep"/> of plain lists,
##    each representing a row of the matrix, at position <C>ZROWSPOS</C>.
##  </Item>
##  </Enum>
##
DeclareRepresentation( "IsZmodnZMatrixRep",
        IsMatrixObj and IsPositionalObjectRep
    and IsCopyable
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain,
    [] );

Add( ConstructingFiltersForMatrixGroupElements, IsZmodnZMatrixRep );

# Internal positions for vector access.
BindConstant( "ZBDPOS", 1 );
BindConstant( "ZELSPOS", 2 );

# Internal positions for matrix access.
#BindConstant( "ZBDPOS", 1 );
BindConstant( "ZCOLSPOS", 2 );
BindConstant( "ZROWSPOS", 3 );
