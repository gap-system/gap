#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Andrew Solomon.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains generic methods for magma homomorphisms
##

#############################################################################
##
#F  MagmaHomomorphismByFunctionNC( <G>, <H>, <fn> )
##
##  Creates the homomorphism from G to H without checking
##  that <fn> is a homomorphism.
##
InstallGlobalFunction( MagmaHomomorphismByFunctionNC,
function( G, H, imgfn )
  local   hom;

  if not (IsMagma(G) and IsMagma(H) and IsFunction(imgfn)) then
    Error("Usage: MagmaHomomorphismByFunctionNC(<Magma>,<Magma>,<fn>)");
  fi;

  hom := MappingByFunction(G, H, imgfn);
  SetIsMagmaHomomorphism(hom, true);
  return hom;
end );

#############################################################################
##
#F  MagmaIsomorphismByFunctionsNC( <G>, <H>, <fn>, <inv> )
##
##  Creates the isomorphism from G to H without checking
##  that <fn> or <inv> are a homomorphisms or bijective or inverse.
##
InstallGlobalFunction( MagmaIsomorphismByFunctionsNC,
function( G, H, imgfn, preimgfn )
  local   hom;

  if not (IsMagma(G) and IsMagma(H) and IsFunction(imgfn)
    and IsFunction(preimgfn)) then
    Error("Usage: MagmaIsomorphismByFunctionsNC(<Magma>,<Magma>,<fn>,<inv>)");
  fi;

  hom := MappingByFunction(G, H, imgfn,preimgfn);
  SetIsMagmaHomomorphism(hom, true);
  return hom;
end );
