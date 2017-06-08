#############################################################################
##
#W  vecmat.gd                   GAP Library                      Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
##  <ManSection>
##  <Filt Name="IsGF2VectorRep" Arg='obj' Type='Representation'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareRepresentation(
    "IsGF2VectorRep",
    IsDataObjectRep and IsRowVectorObj, [],
    IsRowVector );


#############################################################################
##
#V  TYPE_LIST_GF2VEC  . . . . . . . . . . . . . . type of mutable GF2 vectors
##
##  <ManSection>
##  <Var Name="TYPE_LIST_GF2VEC"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2VEC",
    "type of a packed GF2 vector" );


#############################################################################
##
#V  TYPE_LIST_GF2VEC_IMM  . . . . . . . . . . . type of immutable GF2 vectors
##
##  <ManSection>
##  <Var Name="TYPE_LIST_GF2VEC_IMM"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2VEC_IMM",
    "type of a packed, immutable GF2 vector" );


#############################################################################
##
#V  TYPE_LIST_GF2VEC_IMM_LOCKED . . . . . . . . type of immutable GF2 vectors
##
##  <ManSection>
##  <Var Name="TYPE_LIST_GF2VEC_IMM_LOCKED"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2VEC_IMM_LOCKED",
    "type of a packed, immutable GF2 vector with representation lock" );


#############################################################################
##
#V  TYPE_LIST_GF2VEC_LOCKED . . . . . . . . type of mutable GF2 vectors
##
##  <ManSection>
##  <Var Name="TYPE_LIST_GF2VEC_LOCKED"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2VEC_LOCKED",
    "type of a packed, mutable GF2 vector with representation lock" );


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
##  This function is more technical version of <Ref Func="ImmutableMatrix"/>,
##  which will never copy a matrix (or any rows of it) but may fail if it
##  encounters rows locked in the wrong representation, or various other
##  more technical problems. Most users should use <Ref Func="ImmutableMatrix"/>
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
#F  ImmutableGF2VectorRep( <vector> ) . . . . . . . .  convert representation
##
##  <ManSection>
##  <Func Name="ImmutableGF2VectorRep" Arg='vector'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "ImmutableGF2VectorRep", function( vector )
    if ForAny( vector, x -> x <> GF2Zero and x <> GF2One )  then
        return fail;
    fi;
    vector := COPY_GF2VEC(vector);
    SET_TYPE_DATOBJ( vector, TYPE_LIST_GF2VEC_IMM );
    return vector;
end );


#############################################################################
##
#R  IsGF2MatrixRep( <obj> ) . . . . . . . . . . . . . . . . . matrix over GF2
##
DeclareRepresentation(
    "IsGF2MatrixRep",
    IsPositionalObjectRep and IsRowListMatrix, [],
    IsMatrix );


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
#V  TYPE_LIST_GF2MAT  . . . . . . . . . . . . .  type of mutable GF2 matrices
##
##  <ManSection>
##  <Var Name="TYPE_LIST_GF2MAT"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2MAT",
    "type of a packed GF2 matrix" );


#############################################################################
##
#V  TYPE_LIST_GF2MAT_IMM  . . . . . . . . . .  type of immutable GF2 matrices
##
##  <ManSection>
##  <Var Name="TYPE_LIST_GF2MAT_IMM"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
DeclareGlobalVariable(
    "TYPE_LIST_GF2MAT_IMM",
    "type of a packed, immutable GF2 matrix" );



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
#F  ImmutableGF2MatrixRep( <matrix> ) . . . . . . . .  convert representation
##
##  <ManSection>
##  <Func Name="ImmutableGF2MatrixRep" Arg='matrix'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "ImmutableGF2MatrixRep", function(matrix)
    local   new,  i,  row;

    # put length at position 1
    new := [ Length(matrix) ];
    for i  in matrix  do
        row := ImmutableGF2VectorRep(i);
        if row = fail  then
            return fail;
        fi;
        Add( new, row );
    od;

    # convert
    Objectify( TYPE_LIST_GF2MAT_IMM, new );

    # and return new matrix
    return new;

end );

#############################################################################
##
#F  ImmutableMatrix( <field>, <matrix>[, <change>] ) . convert into "best" representation
##
##  <#GAPDoc Label="ImmutableMatrix">
##  <ManSection>
##  <Oper Name="ImmutableMatrix" Arg='field, matrix[, change]'/>
##
##  <Description>
##  returns an immutable matrix equal to <A>matrix</A> which is in the optimal
##  (concerning space and runtime) representation for matrices defined over
##  <A>field</A>. This means that matrices obtained by several calls of
##  <Ref Oper="ImmutableMatrix"/> for the same <A>field</A> are compatible
##  for fast arithmetic without need for field conversion.
##  <P/>
##  The input matrix <A>matrix</A> or its rows might change their
##  representation as a side effect of this function,
##  however the result of <Ref Oper="ImmutableMatrix"/> is not necessarily
##  <E>identical</E> to <A>matrix</A> if a conversion is not possible.
##  <P/>
##  If <A>change</A> is <K>true</K>, the rows of <A>matrix</A>
##  (or <A>matrix</A> itself) may be changed to become immutable;
##  otherwise they are copied first.
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
##  returns an immutable vector equal to <A>vector</A> which is in the optimal
##  (concerning space and runtime) representation for vectors defined over
##  <A>field</A>. This means that vectors obtained by several calls of
##  <Ref Oper="ImmutableVector"/> for the same <A>field</A> are compatible
##  for fast arithmetic without need for field conversion.
##  <P/>
##  The input vector <A>vector</A> might change its representation
##  as a side effect of this function,
##  however the result of <Ref Oper="ImmutableVector"/> is not necessarily
##  <E>identical</E> to <A>vector</A> if a conversion is not possible.
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
##  returns an integer that gives the position of the finite field row vector
##  <A>vec</A> in the sorted list of all row vectors over the field with
##  <A>sz</A> elements in the same dimension as <A>vec</A>.
##  <Ref Func="NumberFFVector"/> returns <K>fail</K> if the vector cannot be
##  represented over the field with <A>sz</A> elements.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation("NumberFFVector", [IsRowVector,IsPosInt]);
  
  
#############################################################################
##
#E

