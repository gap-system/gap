#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the basic operations for creating and doing arithmetic
##  with vectors.
##


#############################################################################
##
#v  GF2One  . . . . . . . . . . . . . . . . . . . . . . . . . .  one of GF(2)
##
BIND_GLOBAL( "GF2One", Z(2) );


#############################################################################
##
#v  GF2Zero . . . . . . . . . . . . . . . . . . . . . . . . . . zero of GF(2)
##
BIND_GLOBAL( "GF2Zero", 0*Z(2) );


#############################################################################
##
#R  IsGF2VectorRep( <obj> ) . . . . . . . . . . . . . . . . . vector over GF2
##
##  <#GAPDoc Label="IsGF2VectorRep">
##  <ManSection>
##  <Filt Name="IsGF2VectorRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="IsGF2VectorRep"/> describes
##  a vector object (see <Ref Filt="IsVectorObj"/>) with entries in the
##  finite field with <M>2</M> elements.
##  <P/>
##  <Ref Filt="IsGF2VectorRep"/> implies <Ref Filt="IsCopyable"/>,
##  thus vector objects in this representation can be mutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  <Ref Filt="IsGF2VectorRep"/> is a subrepresentation of
##  <Ref Filt="IsDataObjectRep"/>, the entries are packed into bits.
##
DeclareRepresentation( "IsGF2VectorRep",
        IsDataObjectRep and IsVectorObj
    and IsCopyable
    and IsNoImmediateMethodsObject
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain);


#############################################################################
##
#F  ConvertToGF2VectorRep( <vector> ) . . . . . . . .  convert representation
##
##  <ManSection>
##  <Func Name="ConvertToGF2VectorRep" Arg='vector'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareSynonym( "ConvertToGF2VectorRep", CONV_GF2VEC );


#############################################################################
##
#F  ConvertToVectorRep( <list>[, <field>] )
#F  ConvertToVectorRep( <list>[, <fieldsize>] )
#F  ConvertToVectorRepNC( <list>[, <field>] )
#F  ConvertToVectorRepNC( <list>[, <fieldsize>] )
##
##  <#GAPDoc Label="ConvertToVectorRep">
##  <ManSection>
##  <Heading>ConvertToVectorRep</Heading>
##  <Func Name="ConvertToVectorRep" Arg='list[, field]'
##   Label="for a list (and a field)"/>
##  <Func Name="ConvertToVectorRep" Arg='list[, fieldsize]'
##   Label="for a list (and a prime power)"/>
##  <Func Name="ConvertToVectorRepNC" Arg='list[, field]'
##   Label="for a list (and a field)"/>
##  <Func Name="ConvertToVectorRepNC" Arg='list[, fieldsize]'
##   Label="for a list (and a prime power)"/>
##
##  <Description>
##  Called with one argument <A>list</A>,
##  <Ref Func="ConvertToVectorRep" Label="for a list (and a field)"/>
##  converts <A>list</A> to an internal row vector representation
##  if possible.
##  <P/>
##  Called with a list <A>list</A> and a finite field <A>field</A>,
##  <Ref Func="ConvertToVectorRep" Label="for a list (and a field)"/>
##  converts <A>list</A> to an internal row vector representation appropriate
##  for a row vector over <A>field</A>.
##  <P/>
##  Instead of a <A>field</A> also its size <A>fieldsize</A> may be given.
##  <P/>
##  It is forbidden to call this function unless <A>list</A> is a plain
##  list or a row vector, <A>field</A> is a field, and all elements
##  of <A>list</A> lie in <A>field</A>.
##  Violation of this condition can lead to unpredictable behaviour or a
##  system crash.
##  (Setting the assertion level to at least 2 might catch some violations
##  before a crash, see&nbsp;<Ref Func="SetAssertionLevel"/>.)
##  <P/>
##  <A>list</A> may already be a compressed vector. In this case, if no
##  <A>field</A> or <A>fieldsize</A> is given, then nothing happens. If one is
##  given then the vector is rewritten as a compressed vector over the
##  given <A>field</A> unless it has the filter
##  <C>IsLockedRepresentationVector</C>, in which case it is not changed.
##  <P/>
##  The return value is the size of the field over which the vector
##  ends up written, if it is written in a compressed representation.
##  <P/>
##  In this example, we first create a row vector and then ask &GAP; to
##  rewrite it, first over <C>GF(2)</C> and then over <C>GF(4)</C>.
##  <P/>
##  <Example><![CDATA[
##  gap> v := [Z(2)^0,Z(2),Z(2),0*Z(2)];
##  [ Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2) ]
##  gap> RepresentationsOfObject(v);
##  [ "IsPlistRep", "IsInternalRep" ]
##  gap> ConvertToVectorRep(v);
##  2
##  gap> v;
##  <a GF2 vector of length 4>
##  gap> ConvertToVectorRep(v,4);
##  4
##  gap> v;
##  [ Z(2)^0, Z(2)^0, Z(2)^0, 0*Z(2) ]
##  gap> RepresentationsOfObject(v);
##  [ "IsDataObjectRep", "Is8BitVectorRep" ]
##  ]]></Example>
##  <P/>
##  A vector in the special representation over <C>GF(2)</C> is always viewed
##  as <C>&lt;a GF2 vector of length ...></C>.
##  Over fields of orders 3 to 256, a vector of length 10 or less is viewed
##  as the list of its coefficients, but a longer one is abbreviated.
##  <P/>
##  Arithmetic operations (see&nbsp;<Ref Sect="Arithmetic for Lists"/> and
##  the following sections) preserve the compression status of row vectors in
##  the sense that if all arguments are compressed row vectors written over
##  the same field and the result is a row vector then also the result is a
##  compressed row vector written over this field.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConvertToVectorRepNC");
DeclareSynonym( "ConvertToVectorRep",ConvertToVectorRepNC);

# TODO: The following two functions only exist in HPC-GAP, but we always
# declare them so that other code can access them conditionally, inside
# an "if IsHPCGAP", without triggering syntax warnings about
# unbound global variables.
DeclareGlobalFunction( "CopyToVectorRep");
DeclareGlobalFunction( "CopyToVectorRepNC");


#############################################################################
##
#F  ConvertToMatrixRep( <list>[, <field>] )
#F  ConvertToMatrixRep( <list>[, <fieldsize>] )
#F  ConvertToMatrixRepNC( <list>[, <field>] )
#F  ConvertToMatrixRepNC( <list>[, <fieldsize>] )
##
##  <#GAPDoc Label="ConvertToMatrixRep">
##  <ManSection>
##  <Func Name="ConvertToMatrixRep" Arg='list[, field]'
##   Label="for a list (and a field)"/>
##  <Func Name="ConvertToMatrixRep" Arg='list[, fieldsize]'
##   Label="for a list (and a prime power)"/>
##  <Func Name="ConvertToMatrixRepNC" Arg='list[, field]'
##   Label="for a list (and a field)"/>
##  <Func Name="ConvertToMatrixRepNC" Arg='list[, fieldsize]'
##   Label="for a list (and a prime power)"/>
##
##  <Description>
##
##  This function is more technical version of <Ref Oper="ImmutableMatrix"/>,
##  which will never copy a matrix (or any rows of it) but may fail if it
##  encounters rows locked in the wrong representation, or various other
##  more technical problems. Most users should use <Ref Oper="ImmutableMatrix"/>
##  instead. The NC versions of the function do less checking of the
##  argument and may cause unpredictable results or crashes if given
##  unsuitable arguments.
##
##  Called with one argument <A>list</A>,
##  <Ref Func="ConvertToMatrixRep" Label="for a list (and a field)"/>
##  converts <A>list</A> to an internal matrix representation
##  if possible.
##  <P/>
##  Called with a list <A>list</A> and a finite field <A>field</A>,
##  <Ref Func="ConvertToMatrixRep" Label="for a list (and a field)"/>
##  converts <A>list</A> to an internal matrix representation appropriate
##  for a matrix over <A>field</A>.
##  <P/>
##  Instead of a <A>field</A> also its size <A>fieldsize</A> may be given.
##  <P/>
##  It is forbidden to call this function unless all elements of <A>list</A>
##  are row vectors with entries in the field <A>field</A>.
##  Violation of this condition can lead to unpredictable behaviour or a
##  system crash.
##  (Setting the assertion level to at least 2 might catch some violations
##  before a crash, see&nbsp;<Ref Func="SetAssertionLevel"/>.)
##  <P/>
##  <A>list</A> may already be a compressed matrix. In this case, if no
##  <A>field</A> or <A>fieldsize</A> is given, then nothing happens.
##  <P/>
##  The return value is the size of the field over which the matrix
##  ends up written, if it is written in a compressed representation.
##  <P/>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "ConvertToMatrixRepNC" );
DeclareGlobalFunction( "ConvertToMatrixRep" );


#############################################################################
##
#R  IsGF2MatrixRep( <obj> ) . . . . . . . . . . . . . . . . . matrix over GF2
##
##  <#GAPDoc Label="IsGF2MatrixRep">
##  <ManSection>
##  <Filt Name="IsGF2MatrixRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  An object <A>obj</A> in <Ref Filt="IsGF2MatrixRep"/> describes
##  a matrix object (see <Ref Filt="IsMatrixObj"/>) with entries in the
##  finite field with <M>2</M> elements, which behaves like the
##  list of its rows (see <Ref Filt="IsRowListMatrix"/>).
##  The base domain of <A>obj</A> is the field with <M>2</M> elements.
##  <P/>
##  <Ref Filt="IsGF2MatrixRep"/> implies <Ref Filt="IsCopyable"/>,
##  thus vector objects in this representation can be mutable.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  <A>obj</A> is internally represented as a positional object
##  (see <Ref Filt="IsPositionalObjectRep"/>).
##  If the number of rows is <M>n</M> then this object stores <M>n+1</M>
##  entries,
##  <M>n</M> at position <M>1</M> and the <M>i</M>-th row at position
##  <M>i+1</M>.
##
DeclareRepresentation( "IsGF2MatrixRep",
        IsPositionalObjectRep and IsRowListMatrix
    and IsCopyable
    and IsNoImmediateMethodsObject
    and HasNumberRows and HasNumberColumns
    and HasBaseDomain and HasOneOfBaseDomain and HasZeroOfBaseDomain);


#############################################################################
##
#M  IsOrdinaryMatrix( <obj> )
#M  IsConstantTimeAccessList( <obj> )
#M  IsSmallList( <obj> )
##
##  Lists in `IsGF2VectorRep' and `IsGF2MatrixRep' are (at least) as good
##  as lists in `IsInternalRep' w.r.t.~the above filters.
##
InstallTrueMethod( IsConstantTimeAccessList, IsList and IsGF2VectorRep );
InstallTrueMethod( IsSmallList, IsList and IsGF2VectorRep );

InstallTrueMethod( IsOrdinaryMatrix, IsMatrix and IsGF2MatrixRep );
InstallTrueMethod( IsConstantTimeAccessList, IsList and IsGF2MatrixRep );
InstallTrueMethod( IsSmallList, IsList and IsGF2MatrixRep );


#############################################################################
##
#F  ConvertToGF2MatrixRep( <matrix> ) . . . . . . . .  convert representation
##
##  <ManSection>
##  <Func Name="ConvertToGF2MatrixRep" Arg='matrix'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##

DeclareSynonym( "ConvertToGF2MatrixRep", CONV_GF2MAT);


#############################################################################
##
#F  ImmutableMatrix( <field>, <matrix>[, <change>] ) . convert into "best" representation
##
##  <#GAPDoc Label="ImmutableMatrix">
##  <ManSection>
##  <Oper Name="ImmutableMatrix" Arg='field, matrix[, change]'/>
##
##  <Description>
##  Let <A>matrix</A> be an object for which either <Ref Filt="IsMatrix"/> or
##  <Ref Filt="IsMatrixObj"/> returns <K>true</K>.
##  In the former case, <A>matrix</A> is a list of lists,
##  and <Ref Oper="ImmutableMatrix"/> returns an immutable object for which
##  <Ref Filt="IsMatrix"/> returns <K>true</K> (in particular again a list of
##  lists), which is equal to <A>matrix</A>,
##  and which is in the optimal (concerning space and runtime) representation
##  for matrices defined over <A>field</A>,
##  provided that the entries of <A>matrix</A> lie in <A>field</A>.
##  In the latter case, <Ref Oper="ImmutableMatrix"/> returns an immutable
##  object that is equal to the result of
##  <Ref Oper="ChangedBaseDomain" Label="for a matrix object"/>
##  when this is called with <A>matrix</A> and <A>field</A>.
##  <P/>
##  This means that matrices obtained by several calls of
##  <Ref Oper="ImmutableMatrix"/> for the same <A>field</A> are compatible
##  for fast arithmetic without need for field conversion.
##  <P/>
##  If the input matrix <A>matrix</A> is in <Ref Filt="IsMatrix"/>
##  then it or its rows might change their representation as a side effect
##  of this function.
##  However, one cannot rely on this side effect.
##  Also, if <A>matrix</A> is already immutable and the result of
##  <Ref Oper="ImmutableMatrix"/> has the same internal representation as
##  <A>matrix</A>, the result is not necessarily <E>identical</E> to
##  <A>matrix</A>.
##  <P/>
##  If <A>change</A> is <K>true</K>, <A>matrix</A> or its rows (if there are
##  subobjects that represent rows) may be changed to become immutable;
##  otherwise the rows of <A>matrix</A> are copied first.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ImmutableMatrix",[IsObject,IsMatrix]);


#############################################################################
##
#F  ImmutableVector( <field>, <vector>[, <change>] ) . convert into "best" representation
##
##  <#GAPDoc Label="ImmutableVector">
##  <ManSection>
##  <Oper Name="ImmutableVector" Arg='field, vector[, change]'/>
##
##  <Description>
##  Let <A>vector</A> be an object for which <Ref Filt="IsRowVector"/>
##  or <Ref Filt="IsVectorObj"/> returns <K>true</K>.
##  In the former case, <A>vector</A> is a list,
##  and <Ref Oper="ImmutableVector"/> returns an immutable object for which
##  <Ref Filt="IsRowVector"/> returns <K>true</K> (in particular again a list),
##  which is equal to <A>vector</A>,
##  and which is in the optimal (concerning space and runtime) representation
##  for vectors defined over <A>field</A>,
##  provided that the entries of <A>vector</A> lie in <A>field</A>.
##  In the latter case, if <A>vector</A> is not in <Ref Filt="IsRowVector"/>,
##  <Ref Oper="ImmutableVector"/> returns an immutable object that is equal
##  to the result of
##  <Ref Oper="ChangedBaseDomain" Label="for a vector object"/>
##  when this is called with <A>vector</A> and <A>field</A>.
##  <P/>
##  This means that vectors obtained by several calls of
##  <Ref Oper="ImmutableVector"/> for the same <A>field</A> are compatible
##  for fast arithmetic without need for field conversion.
##  <P/>
##  If the input vector <A>vector</A> is in <Ref Filt="IsRowVector"/>
##  then it might change its representation as a side effect
##  of this function.
##  However, one cannot rely on this side effect.
##  Also, if <A>vector</A> is already immutable and the result of
##  <Ref Oper="ImmutableVector"/> has the same internal representation as
##  <A>vector</A>, the result is not necessarily <E>identical</E> to
##  <A>vector</A>.
##  <P/>
##  If <A>change</A> is <K>true</K>, then <A>vector</A> may be changed to
##  become immutable; otherwise it is copied first.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "ImmutableVector",[IsObject,IsRowVector]);


#############################################################################
##
#O  NumberFFVector( <vec>, <sz> )
##
##  <#GAPDoc Label="NumberFFVector">
##  <ManSection>
##  <Oper Name="NumberFFVector" Arg='vec, sz'/>
##
##  <Description>
##  returns an integer that gives the position minus one of the finite field row vector
##  <A>vec</A> in the sorted list of all row vectors over the field with
##  <A>sz</A> elements in the same dimension as <A>vec</A>.
##  <Ref Oper="NumberFFVector"/> returns <K>fail</K> if the vector cannot be
##  represented over the field with <A>sz</A> elements.
##  <P/>
##  <Example><![CDATA[
##  gap> v:=[0,1,2,0]*Z(3);;
##  gap> NumberFFVector(v, 3);
##  21
##  gap> NumberFFVector(Zero(v),3);
##  0
##  gap> V:=EnumeratorSorted(GF(3)^4);
##  <enumerator of ( GF(3)^4 )>
##  gap> V[21+1] = v;
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("NumberFFVector", [IsRowVector,IsPosInt]);
