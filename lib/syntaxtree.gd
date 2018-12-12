#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

DeclareCategory("IsSyntaxTree", IsObject);
BindGlobal("SyntaxTreeType", NewType( NewFamily( "SyntaxTreeFamily" )
                                    , IsSyntaxTree and IsComponentObjectRep ) );

##  <#GAPDoc Label="SyntaxTree">
##  <ManSection>
##  <Func Name="SyntaxTree" Arg='f'/>
##
##  <Description>
##  Takes a GAP function <A>f</A> and returns its syntax tree.
##
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
DeclareGlobalFunction("SyntaxTree");
