InstallMethod( AutomorphismGroup,
        "for associative algebras",
        [IsAlgebra],
        0,
        function( A )
    
    local isnil, b, dim, F, i, j, gens, auts, g, ims, aut, isaut;
    
    isaut := function ( A, a )
        local  i, j, b, dim;
        b := Basis( A );
        dim := Length( b );
        for i  in [ 1 .. dim ]  do
            for j  in [ i + 1 .. dim ]  do
                if
                  LinearCombination( b, Coefficients( b, b[i] * b[j] )^a ) <> 
                  LinearCombination( b, Coefficients( b, b[i] )^a )* 
                  LinearCombination( b, Coefficients( b, b[j] )^a ) then
                    return false;
                fi;
            od;
        od;
        return true;
    end;
    
    
    isnil := true;
    b := Basis( A );
    dim := Dimension( A );
    F := LeftActingDomain( A );
    
    if not IsFinite( F ) then
        Error( "The field must be finite" );
    fi;
    
    for i in b do
        for j in b do
            if i*j <> Zero( A ) then
                isnil := false;
                break;
            fi;
        od;
        if not isnil then
            break;
        fi;
    od;
    
    if isnil then
        gens := GeneratorsOfGroup( GL( dim, F ));
        auts := [];
        for g in gens do
            ims := List( b, x->LinearCombination( b, Coefficients( b, x )^g ));
            aut := LeftModuleHomomorphismByImages( A, A, b, ims );
            Add( auts, aut );
        od;            
        return Group( auts );
    fi;
    
    
    if Size( A ) <= 1000 then
        auts := Filtered( GL( dim, F ), x->isaut( A, x ));
        gens := SmallGeneratingSet( Group( auts ));
        gens := List( gens, z->LeftModuleHomomorphismByImages( A, A, b, 
                        List( b, x->LinearCombination( b, 
                                Coefficients( b, x )^z ))));
        return Group( gens );
    fi;
    
    return fail;
    
end );
