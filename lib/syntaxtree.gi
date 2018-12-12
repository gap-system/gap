#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##

InstallGlobalFunction( SyntaxTree,
function(func)
    return Objectify( SyntaxTreeType, rec( tree := SYNTAX_TREE(func) ) );
end);

InstallMethod( ViewString, "for a syntax tree"
               , [ IsSyntaxTree ]
               , t -> "<syntax tree>" );
