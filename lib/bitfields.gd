#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Steve Linton.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file declares the operations for bitfields
##


#############################################################################
##
#F  MakeBitfields(<width>[, <width>[, <width>...]]])
##  <#GAPDoc Label="MakeBitfields">
##  <ManSection>
##  <Func Name="MakeBitfields" Arg='width....'/>
##
##  <Description>
##
##  This function sets up the machinery for a set of bitfields of the given
##  widths. All bitfield values are treated as unsigned.
##  The total of the widths must not exceed 60 bits on 64-bit architecture
##  or 28 bits on a 32-bit architecture. For performance
##  reasons some checks that one might wish to do are omitted. In particular,
##  the builder and setter functions do not check if the value[s] passed to them are
##  negative or too large (unless &GAP; is specially compiled for debugging).
##  Behaviour when such arguments are passed is undefined.
##
##  You can tell which type of architecture you are running on by accessing
##  <C>GAPInfo.BytesPerVariable</C> which is 8 on 64-bits and 4 on 32.
##
##
##  The return value  when <M>n</M> widths are given is a record whose fields are
##  <List>
##  <Mark><C>widths</C></Mark> <Item>a copy of the arguments, for convenience,</Item>
##  <Mark><C>getters</C></Mark> <Item> a list of <M>n</M> functions of one
##  argument each of which extracts one of the fields from an immediate integer</Item>
##  <Mark><C>setters</C></Mark> <Item> a list of <M>n</M> functions each taking
##  two arguments: a packed value and a new value for one of its fields and
##  returning a new packed value. The
##  <M>i</M>th function returned the new packed value in which the <M>i</M>th
##  field has been replaced by the new value.
##   Note that this does NOT modify the original packed value.</Item>
##
##  </List>
##
##  Two additional fields may be present if any of the field widths is
##  one. Each is a list and only has entried bound in the positions
##  corresponding to the width 1 fields.
##  <List> <Mark><C>booleanGetters</C></Mark> <Item>if the <M>i</M>th position of
##  this list is set, it contains a function which extracts the <M>i</M>th
##  field (which will have width one) and returns <K>true</K> if it contains 1
##  and <K>false</K> if it contains 0</Item>
##  <Mark><C>booleanSetters</C></Mark> <Item>if the <M>i</M>th position of
##  this list is set, it contains a function of two arguments. The first
##  argument is a packed value, the second is <K>true</K> or <K>false</K>. It returns a
##  new packed value in which the <M>i</M>th field is set to 1 if the second
##  argument was <K>true</K> and 0 if it was <K>false</K>. Behaviour for any
##  other value is undefined.</Item></List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

DeclareGlobalFunction( "MakeBitfields" );

##
#############################################################################
##
#F  BuildBitfields( <widths>[, <val1>, [<val2>...]])
##  <#GAPDoc Label="BuildBitfields">
##  <ManSection>
##  <Func Name="BuildBitfields" Arg='widths, vals...'/>
##  <Description>
##
##  This function takes one or more argument. Its first argument is a list
##  of field widths, as found in the <C>widths</C> entry of a record returned
##  by <C>MakeBitfields</C>. The remaining arguments are unsigned integer
##  values, equal in number to the entries of the list of field widths. It returns
##  a small integer in which those entries are packed into bitfields of the
##  given widths. The first entry occupies the least significant bits.
##
##

DeclareGlobalFunction("BuildBitfields");

##
##  <Example><![CDATA[
##  gap> bf := MakeBitfields(1,2,3);
##  rec( booleanGetters := [ function( data ) ... end ],
##    booleanSetters := [ function( data, val ) ... end ],
##    getters := [ function( data ) ... end, function( data ) ... end,
##        function( data ) ... end ],
##    setters := [ function( data, val ) ... end, function( data, val ) ... end,
##        function( data, val ) ... end ], widths := [ 1, 2, 3 ] )
##  gap> x := BuildBitfields(bf.widths,0,3,5);
##  46
##  gap> bf.getters[3](x);
##  5
##  gap> y := bf.setters[1](x,1);
##  47
##  gap> x;
##  46
##  gap> bf.booleanGetters[1](x);
##  false
##  gap> bf.booleanGetters[1](y);
##  true
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
