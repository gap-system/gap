#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Lübeck.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  The  files  helpview.g{d,i} contain the configuration mechanism  for  the
##  different help viewer.
##

##  <#GAPDoc Label="HELP_VIEWER_INFO">
##  <ManSection>
##  <Var Name="HELP_VIEWER_INFO"/>

##  <Description>
##  The record <Ref Var="HELP_VIEWER_INFO"/> contains one component for each
##  help viewer. Each such component is a record with two components:
##  <C>.type</C> and <C>.show</C>.
##  <P/>
##  The component <C>.type</C> refers to one of the <C>type</C>s recognized
##  by the <C>HelpData</C> handler function explained in the previous
##  section (currently one of <C>"text"</C>, <C>"url"</C>, <C>"dvi"</C>,
##  or <C>"pdf"</C>).
##  <P/>
##  The component <C>.show</C> is a function which gets as input the result
##  of a corresponding <C>HelpData</C> handler call, if it was not <K>fail</K>.
##  This function has to perform the actual display of the data. (E.g., by
##  calling a function like <Ref Func="Pager"/> or by starting up an external
##  viewer program.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
BindGlobal("HELP_VIEWER_INFO", rec());

DeclareGlobalFunction("FindWindowId");
DeclareGlobalFunction("SetHelpViewer");

