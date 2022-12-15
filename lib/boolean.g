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
##  This file deals with booleans.
##


#############################################################################
##
#C  IsBool(<obj>) . . . . . . . . . . . . . . . . . . .  category of booleans
##
##  <#GAPDoc Label="IsBool">
##  <ManSection>
##  <Filt Name="IsBool" Arg='obj' Type='Category'/>
##
##  <Description>
##  tests whether <A>obj</A> is <K>true</K>, <K>false</K> or <K>fail</K>.
##  <Example><![CDATA[
##  gap> IsBool( true );  IsBool( false );  IsBool( 17 );
##  true
##  true
##  false
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareCategoryKernel( "IsBool", IsObject, IS_BOOL );


#############################################################################
##
#V  BooleanFamily . . . . . . . . . . . . . . . . . . . .  family of booleans
##
##  <ManSection>
##  <Var Name="BooleanFamily"/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "BooleanFamily",
    NewFamily(  "BooleanFamily", IS_BOOL ) );


#############################################################################
##
#F  TYPE_BOOL . . . . . . . . . . . . . . . . . . . type of internal booleans
##
##  <ManSection>
##  <Func Name="TYPE_BOOL" Arg='obj'/>
##
##  <Description>
##  </Description>
##  </ManSection>
##
BIND_GLOBAL( "TYPE_BOOL",
    NewType( BooleanFamily, IS_BOOL and IsInternalRep ) );


#############################################################################
##
#M  String( <bool> )  . . . . . . . . . . . . . . . . . . . . . for a boolean
##
InstallMethod( String,
    "for a boolean",
    true,
    [ IsBool ], 0,
    function( bool )
    if bool = true then
      return "true";
    elif bool = false  then
      return "false";
    elif bool = fail  then
      return "fail";
    else
      Error( "unknown boolean <bool>" );
    fi;
    end );

InstallMethod( ViewString, "for a boolean",
    true, [ IsBool ], 5,
    String );
