#############################################################################
##
#W  mgmhom.gi                    GAP library                  Andrew Solomon
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
	
	if not IsMagma(G) and IsMagma(H) and IsFunction(imgfn) then
		Error("Usage:  MagmaHomomorphismByFunctionNC(<Magma>,<Magma>,<fn>)");
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
	
	if not IsMagma(G) and IsMagma(H) and IsFunction(imgfn) 
		and IsFunction(preimgfn) then
		Error("Usage:  MagmaIsomorphismByFunctionsNC(<Magma>,<Magma>,<fn>,<inv>)");
	fi;

	hom := MappingByFunction(G, H, imgfn,preimgfn);
	SetIsMagmaHomomorphism(hom, true);
	return hom;
end );

#############################################################################
##
#E

