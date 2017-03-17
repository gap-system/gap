#############################################################################
##
#W  grpreps.gi                  GAP library                      Bettina Eick
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen, Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##

#############################################################################
##
#M RegularModule( <G>, <F> ) . . . . . . . . . . .right regular F-module of G
##
InstallGlobalFunction( RegularModuleByGens, function( G, gens, F )
    local mats, elms, d, zero, i, mat, j, o;
    mats := List( gens, x -> false );
    elms := AsList( G );
    d    := Length(elms);
    zero := NullMat( d, d, F );
    for i in [1..Length( gens )] do
        mat := List( zero, ShallowCopy ); 
        for j in [1..d] do
            o := Position( elms, elms[j]*gens[i] );
            mat[j][o] := One( F );
        od;
        mats[i] := mat;
    od;
    return GModuleByMats( mats, F );
end );

InstallMethod( RegularModule,
    "generic method for groups",
    true, 
    [ IsGroup, IsField ],
    0,
function( G, F )
    return [GeneratorsOfGroup(G),
            RegularModuleByGens( G, GeneratorsOfGroup( G ), F )];
end);

#############################################################################
##
#M IrreducibleModules( <G>, <F>, <dim> ). . . .constituents of regular module
##
InstallMethod( IrreducibleModules,
    "generic method for groups and finite field",
    true, 
    [ IsGroup, IsField and IsFinite, IsInt ],
    0,
function( G, F, dim )
    local modu, modus,gens;
    modu := RegularModule( G, F );
    gens:=modu[1];
    modu:=modu[2];
    modus := List( MTX.CollectedFactors( modu ), x -> x[1] );
    if dim > 0 then
        modus := Filtered( modus, x -> MTX.Dimension(x) <= dim );
    fi;
    return [gens,modus];
end);


#############################################################################
##
#M AbsolutelyIrreducibleModules( <G>, <F>, <dim> ). . . .constituents of regular module
##
InstallMethod( AbsolutelyIrreducibleModules,
    "generic method for groups and finite field",
    true, 
    [ IsGroup, IsField and IsFinite, IsInt ],
    0,
function( G, F, dim )
    local modu, modus,gens;
    modu := RegularModule( G, F );
    gens:=modu[1];
    modu:=modu[2];
    modus := List( MTX.CollectedFactors( modu ), x -> x[1] );
    if dim > 0 then
        modus := Filtered( modus, x -> MTX.Dimension(x) <= dim and MTX.IsAbsolutelyIrreducible (x));
    fi;
    return [gens,modus];
end);


