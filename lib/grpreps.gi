#############################################################################
##
#W  grpreps.gi                  GAP library                      Bettina Eick
##
Revision.grpreps_gi :=
    "@(#)$Id:";

#############################################################################
##
#M RegularModule( <G>, <F> ) . . . . . . . . . . .right regular F-module of G
##
RegularModuleByGens := function( G, gens, F )
    local mats, elms, d, zero, i, mat, j, o;
    mats := List( gens, x -> false );
    elms := AsList( G );
    d    := Length(elms);
    zero := NullMat( d, d, F );
    for i in [1..Length( gens )] do
        mat := DeepCopy( zero ); 
        for j in [1..d] do
            o := Position( elms, elms[j]*gens[i] );
            mat[j][o] := One( F );
        od;
        mats[i] := mat;
    od;
    return GModuleByMats( mats, F );
end;

InstallMethod( RegularModule,
    "generic method for groups",
    true, 
    [ IsGroup, IsField ],
    0,
function( G, F )
    return RegularModuleByGens( G, GeneratorsOfGroup( G ), F );
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
    local modu, modus;
    modu := RegularModule( G, F );
    modus := List( MTX.CollectedFactors( modu ), x -> x[1] );
    if dim > 0 then
        modus := Filtered( modus, x -> x.dimension <= dim );
    fi;
    return modus;
end);

