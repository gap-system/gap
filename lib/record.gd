#############################################################################
##
#W  record.gd                    GAP library                     Thomas Breuer
#W                                                             & Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains methods for records.
##  Compared to &GAP; 3, where records were used to represent domains and
##  all kinds of external arithmetic objects, in &GAP; 4 there is no
##  important role for records.
##  So the standard library provides only methods for `PrintObj', `String',
##  `=', and `<', and the latter two are not installed to compare records
##  with objects in other families.
##
##  In order to achieve a special behaviour of records as in &GAP; 3 such
##  that a record can be regarded as equal to objects in other families
##  or such that a record can be compared via `<' with objects in other
##  families, one can load the file `compat3c.g'.
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
#o  \.( <rec>, <name> )	. . . . . . . . . . . . . . . . get a component value
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
##  returns a list of strings corresponding to the names of the record
##  components of the record <A>record</A>.
##  <P/>
##  <Example><![CDATA[
##  gap> r := rec( a := 1, b := 2 );;
##  gap> Set(RecNames( r )); # 'Set' because ordering depends on GAP session
##  [ "a", "b" ]
##  ]]></Example>
##  <P/>
##  Note that you cannot use the string result in the ordinary way to access
##  or change a record component.
##  You can use the <C><A>record</A>.(<A>name</A>)</C> construct for that,
##  see <Ref Sect="Accessing Record Elements"/> and
##  <Ref Sect="Record Assignment"/>.
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
##  For a record <A>comobj</A>,
##  <Ref Func="NamesOfComponents"/> returns the result of
##  <Ref Func="RecNames"/>.
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
