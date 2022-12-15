#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer, Frank Celler.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains methods for records.
##  Compared to &GAP; 3, where records were used to represent domains and
##  all kinds of external arithmetic objects, in &GAP; 4 there is no
##  important role for records.
##  So the standard library provides only methods for `PrintObj', `String',
##  `=', and `<', and the latter two are not installed to compare records
##  with objects in other families.
##


#############################################################################
##
#C  IsRecord( <obj> )
#C  IsRecordCollection( <obj> )
#C  IsRecordCollColl( <obj> )
##
##  <#GAPDoc Label="IsRecord">
##  <ManSection>
##  <Filt Name="IsRecord" Arg='obj' Type='Category'/>
##  <Filt Name="IsRecordCollection" Arg='obj' Type='Category'/>
##  <Filt Name="IsRecordCollColl" Arg='obj' Type='Category'/>
##
##  <Description>
##  <Index Subkey="for records">test</Index>
##  <Example><![CDATA[
##  gap> IsRecord( rec( a := 1, b := 2 ) );
##  true
##  gap> IsRecord( IsRecord );
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsRecord", IsObject, IS_REC );
DeclareCategoryCollections( "IsRecord" );
DeclareCategoryCollections( "IsRecordCollection" );


#############################################################################
##
#V  RecordsFamily . . . . . . . . . . . . . . . . . . . . . family of records
##
##  <ManSection>
##  <Var Name="RecordsFamily"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "RecordsFamily", NewFamily( "RecordsFamily", IS_REC ) );


#############################################################################
##
#V  TYPE_PREC_MUTABLE . . . . . . . . . . . type of a mutable internal record
##
##  <ManSection>
##  <Var Name="TYPE_PREC_MUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_PREC_MUTABLE",
    NewType( RecordsFamily, IS_MUTABLE_OBJ and IS_REC and IsInternalRep ) );


#############################################################################
##
#V  TYPE_PREC_IMMUTABLE . . . . . . . .  type of an immutable internal record
##
##  <ManSection>
##  <Var Name="TYPE_PREC_IMMUTABLE"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_PREC_IMMUTABLE",
    NewType( RecordsFamily, IS_REC and IsInternalRep ) );


#############################################################################
##
#o  \.( <rec>, <name> ) . . . . . . . . . . . . . . . . get a component value
##
DeclareOperationKernel( ".", [ IsObject, IsObject ], ELM_REC );


#############################################################################
##
#o  IsBound\.( <rec>, <name> )  . . . . . . . . . . . . . .  test a component
##
DeclareOperationKernel( "IsBound.", [ IsObject, IsObject ], ISB_REC );


#############################################################################
##
#o  \.\:\=( <rec>, <name>, <val> )  . . . . . . . . . . . . .  assign a value
##
DeclareOperationKernel( ".:=", [ IsObject, IsObject, IsObject ], ASS_REC );


#############################################################################
##
#o  Unbind\.( <rec>, <name> ) . . . . . . . . . . . . . . .  unbind component
##
DeclareOperationKernel( "Unbind.", [ IsObject, IsObject ], UNB_REC );


#############################################################################
##
#A  RecNames( <record> )
##
##  <#GAPDoc Label="RecNames">
##  <ManSection>
##  <Attr Name="RecNames" Arg='record'/>
##
##  <Description>
##  returns a duplicate-free list of strings corresponding to the names of
##  the record components of the record <A>record</A>.
##  <P/>
##  The list is sorted by <Ref Func="RNamObj" Label="for a string"/>
##  for reasons of efficiency; see <Ref Oper="SortBy"/>.
##  Therefore the ordering is consistent within one &GAP; session,
##  but it is not necessarily consistent across different sessions.
##  To obtain a result that is consistent across &GAP; sessions,
##  apply <Ref Oper="Set"/> to the returned list.
##  <P/>
##  Note that given a string <C>name</C> containing the name of a record
##  component, you can access the record component via
##  <C><A>record</A>.(name)</C>,
##  see Sections&nbsp;<Ref Sect="Accessing Record Elements"/>
##  and&nbsp;<Ref Sect="Record Assignment"/>.
##  <P/>
##  <Example><![CDATA[
##  gap> r := rec( a := 1, b := 2 );;
##  gap> Set(RecNames( r )); # 'Set' because ordering depends on GAP session
##  [ "a", "b" ]
##  gap> Set(RecNames( r ), x -> r.(x));
##  [ 1, 2 ]
##  ]]></Example>
##  <P/>
##  Note that it is most efficient to assign components to a (new or old)
##  record in the order given by <Ref Attr="RecNames" Style="Text"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareAttribute( "RecNames", IsRecord );

#############################################################################
##
#F  NamesOfComponents( <comobj> )
##
##  <#GAPDoc Label="NamesOfComponents">
##  <ManSection>
##  <Func Name="NamesOfComponents" Arg='comobj'/>
##
##  <Description>
##  For a component object <A>comobj</A>,
##  <Ref Func="NamesOfComponents"/> returns a list of strings,
##  which are the names of components currently bound in <A>comobj</A>.
##  <P/>
##  For a record <A>comobj</A> in internal representation,
##  <Ref Func="NamesOfComponents"/> returns the result of
##  <Ref Attr="RecNames"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalFunction( "NamesOfComponents" );

#############################################################################
##
#V  IdentifierLetters . . . . . . . .characters allowed in normal identifiers
##
##  This is used to produce warning messages when the XxxxGlobal functions
##  are applied to a name which could not be read in by the parser without
##  escapes
##

BIND_GLOBAL( "IdentifierLetters",
  Immutable("0123456789@ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz") );

IsSet( IdentifierLetters ); # ensure GAP knows that this is a set

#############################################################################
##
#F  SetNamesForFunctionsInRecord( <rec-name>[, <record> ][, <field-names>])
##
##  set the names of functions bound to components of a record.
##
DeclareGlobalFunction("SetNamesForFunctionsInRecord");
