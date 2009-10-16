InstallGlobalFunction( 
        AlgebraBimodule, 
        function( A, I, leftaction, rightaction )
    local F, T, B;
    
    F := NewFamily( "AlgebraBimodule" );
    T := NewType( F, IsAlgebraBimodule and IsAlgebraBimoduleRep );
    
    
    
    B := Objectify( T,
                 rec( actingalgebra := A, 
                      bimodule := I, 
                      leftaction := leftaction,
                      rightaction := rightaction ));
    
    return B;
end );

InstallGlobalFunction( 
        AlgebraBimoduleByIdeals,
        function( arg )
    local A, I, J, F, fIJ, fAI, lact, B, K, i, ims, j, ract, 
          leftaction, rightaction;
    
    A := arg[1];
    I := arg[2];
    
    if Length( arg ) >= 3 then
        J := arg[3];
    else
        J := Ideal( A, [] );
    fi;
    
    F := LeftActingDomain( A );
    
    fIJ := NaturalHomomorphismByIdeal( I, J );
    fAI := NaturalHomomorphismByIdeal( A, I );
    
    B := Image( fAI );
    K := Image( fIJ );
    
    lact := [];
    for i in Basis( B ) do
        ims := [];
        for j in Basis( K ) do
            Add( ims, Image( fIJ, PreImagesRepresentative( fAI, i )*
                    PreImagesRepresentative( fIJ, j )));
        od;
        Add( lact, ims );
    od;
    
    ract := [];
    for i in Basis( B ) do
        ims := [];
        for j in Basis( K ) do
            Add( ims, Image( fIJ, PreImagesRepresentative( fIJ, j )*
                 PreImagesRepresentative( fAI, i )));
        od;
        Add( ract, ims );
    od;
    
    ract := List( ract, x->LeftModuleHomomorphismByImages( K, K, 
                    Basis( K ), x ));
    lact := List( lact, x->LeftModuleHomomorphismByImages( K, K, 
                    Basis( K ), x ));
    
    leftaction := LeftModuleHomomorphismByImages( B, End( F, K ), 
                          Basis( B ), lact );
    rightaction := LeftModuleHomomorphismByImages( B, End( F, K ), 
                           Basis( B ), ract );
    
    return AlgebraBimodule( B, K, leftaction, rightaction );
end );

InstallMethod( PrintObj,
               "for algebra bimodules",
               true,
               [IsAlgebraBimodule],
        SUM_FLAGS,
function( m )
    Print( m!.actingalgebra );
    Print( " acting on the bimodule " );
    Print( m!.bimodule );
end);


InstallMethod( AActingAlgebra,
        "for algebra bimodules", 
        [IsAlgebraBimodule],
        function( B )
    return B!.actingalgebra;
end );

InstallMethod( Bimodule,
        "for algebra bimodules",
        [IsAlgebraBimodule],
        function( B )
    return B!.bimodule;
end );

InstallMethod( LLeftAction,
        "for algebra bimodules", 
        [IsAlgebraBimodule],
        function( B )
    return B!.leftaction;
end );

InstallMethod( RRightAction,
        "for algebra bimodules", 
        [IsAlgebraBimodule],
        function( B )
    return B!.rightaction;
end );


