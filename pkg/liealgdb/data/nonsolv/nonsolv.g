NS_3_char2 := function( F )
    local T;
    
    # Strade's W(1;2)^{(1)}. Basis is {d, x1d, x2d}
    
    T:= EmptySCTable( 3, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    return [ LieAlgebraByStructureConstants( F, T ) ];
end;

NS_3_charodd := function( F )
    local T;
    
    # sl(2,F). Basis [[0,1],[0,0]],[[0,0],[0,1]],[[1,0],[0,-1]] 
    
    T:= EmptySCTable( 3, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    SetEntrySCTable( T, 1, 3, [-2,1] );
    SetEntrySCTable( T, 2, 3, [2,2] );
    return [ LieAlgebraByStructureConstants( F, T ) ];
end;

NS_4_char2 := function( F )
    local T, list;
    
    # W(1;2)^{(1)} + F. Basis {d,x1d,x2d,z}
    
    T:= EmptySCTable( 4, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
        
    list := [ LieAlgebraByStructureConstants( F, T ) ];
    
    # W(1;2). Basis {d,x1d,x2d,x3d}
    
    T:= EmptySCTable( 4, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    return list;
    
end;

NS_4_charodd := function( F )
    local T;
    
    # gl(2,F)
    
    T:= EmptySCTable( 4, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,2] );
    SetEntrySCTable( T, 1, 3, [-1,3] );
    SetEntrySCTable( T, 2, 3, [1,1,-1,4] );
    SetEntrySCTable( T, 2, 4, [1,2] );
    SetEntrySCTable( T, 3, 4, [-1,3] );
        
    return [ LieAlgebraByStructureConstants( F, T ) ];
end;

NS_5_char2 := function( F )
    local T, list;
    
    list := [];
    
    # Der( W(1;2)^{(1)}. Basis {d,x1d,x2d,x3d,dd}
    
    T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
    SetEntrySCTable( T, 3, 5, [1,1] );
    SetEntrySCTable( T, 4, 5, [1,2] );
    
    Add( list,  LieAlgebraByStructureConstants( F, T ));
    
    # W(1,2) + F direct sum
    
    T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
        
    Add( list,  LieAlgebraByStructureConstants( F, T ));
    
    # W(1,2) + F not a direct sum
    
    T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
    SetEntrySCTable( T, 4, 5, [1,5] );
    
    
    Add( list,  LieAlgebraByStructureConstants( F, T ));
    
    # W(1,2)^{(1)} + 2-dim abelian
    
    T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
    
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
        
    Add( list,  LieAlgebraByStructureConstants( F, T ));
    
    # W(1,2)^{(1)} + 2-dim non-abelian
    
    T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
    
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 4, 5, [1,5] );
    
    Add( list,  LieAlgebraByStructureConstants( F, T ));
    
    return list;
end;

NS_5_charodd := function( F )
    local T, list;
    
    list := [];
    
    # if char = 5 then W(1;1)
    
    if Characteristic( F ) = 5 then
        T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 1, 2, [1,1] );
        SetEntrySCTable( T, 1, 3, [1,2] );
        SetEntrySCTable( T, 1, 4, [1,3] );
        SetEntrySCTable( T, 1, 5, [1,4] );
        SetEntrySCTable( T, 2, 3, [1,3] );
        SetEntrySCTable( T, 2, 4, [2,4] );
        SetEntrySCTable( T, 2, 5, [3,5] );
        SetEntrySCTable( T, 3, 4, [2,5] );
        Add( list, LieAlgebraByStructureConstants( F, T ));    
    fi;
            
    # sl(2,k) + Abelian
    
    T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    SetEntrySCTable( T, 1, 3, [-2,1] );
    SetEntrySCTable( T, 2, 3, [2,2] );
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # sl(2,k) + non-abelian
    T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    SetEntrySCTable( T, 1, 3, [-2,1] );
    SetEntrySCTable( T, 2, 3, [2,2] );
    SetEntrySCTable( T, 4, 5, [1,5] );
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # sl(2,k) semidirect natural module
    T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    SetEntrySCTable( T, 1, 3, [-2,1] );
    SetEntrySCTable( T, 2, 3, [2,2] );
    SetEntrySCTable( T, 4, 1, [1,5] );
    SetEntrySCTable( T, 4, 3, [1,4] );
    SetEntrySCTable( T, 5, 2, [1,4] );
    SetEntrySCTable( T, 5, 3, [-1,5] );
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # if char=3 then there is an additional one.
    
    if Characteristic( F ) = 3 then
        T:= EmptySCTable( 5, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 2, 1, [-1,1,1,5] );
        SetEntrySCTable( T, 2, 3, [1,3] );
        SetEntrySCTable( T, 1, 3, [1,2] );
        SetEntrySCTable( T, 2, 4, [1,4] );
        SetEntrySCTable( T, 2, 5, [-1,5] );
        SetEntrySCTable( T, 1, 5, [1,4] );
        SetEntrySCTable( T, 3, 4, [1,5] );
        Add( list, LieAlgebraByStructureConstants( F, T ));
    fi;
    
    return list;
end;

        
NS_6_char2 := function( F )
    local T, list, x, c, a, L, c12, c13, c23, b;
    
    list := [];
    
    # radical zero-dim
    
    # W(1,2)^{(1)}+W(1,2)^{(1)}
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    
    SetEntrySCTable( T, 4, 5, [1,4] );
    SetEntrySCTable( T, 4, 6, [1,5] );
    SetEntrySCTable( T, 5, 6, [1,6] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # W(1,2)^{(1)} x field extension of degree 2. 
    # Basis={d,xd,x^2d,d x xi, xd x xi, x^2d x xi }
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    x := Z( Size( F )^2 );
    c := Coefficients( Basis( VectorSpace( F, [ One( F ), x ])), x^2 );
    
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    
    SetEntrySCTable( T, 1, 5, [1,4] );
    SetEntrySCTable( T, 1, 6, [1,5] );
    SetEntrySCTable( T, 2, 4, [1,4] );
    SetEntrySCTable( T, 2, 6, [1,6] );
    SetEntrySCTable( T, 3, 4, [1,5] );
    SetEntrySCTable( T, 3, 5, [1,6] );
    
    SetEntrySCTable( T, 4, 5, [c[1],1,c[2],4] );
    SetEntrySCTable( T, 4, 6, [c[1],2,c[2],5] );
    SetEntrySCTable( T, 5, 6, [c[1],3,c[2],6] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # Der( W(1;2)^{(1)}) + F. Basis {d,x1d,x2d,x3d,dd,z}
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
    SetEntrySCTable( T, 3, 5, [1,1] );
    SetEntrySCTable( T, 4, 5, [1,2] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # Der( W(1;2)^{(1)} semidirect F. Basis {d,x1d,x2d,x3d,dd,u}
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
    SetEntrySCTable( T, 3, 5, [1,1] );
    SetEntrySCTable( T, 4, 5, [1,2] );
    SetEntrySCTable( T, 5, 6, [1,6] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # W(1,2) semidirect abelian: 4 + |F| Lie algebras, depending
    # on the action of W(1,2) on the abelian.
    # only x^3d acts on the abelian non-trivially.
    
    # 1st Lie algebra. action of x^3d is trivial.
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));

    # 2nd Lie algebra. action is [[0,1],[0,0]]
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
    SetEntrySCTable( T, 4, 5, [1,6] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # 3rd Lie algebra. Action is identity
      
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
    SetEntrySCTable( T, 4, 5, [1,5] );
    SetEntrySCTable( T, 4, 6, [1,6] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # 4th Lie algebra. Action is [[1,1],[0,1]]
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
    SetEntrySCTable( T, 4, 5, [1,5,1,6] );
    SetEntrySCTable( T, 4, 6, [1,6] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # an infinite family of Lie algebras. Action is [[0,a],[1,1]]
    
    for a in F do
        if a <> Zero( F ) then
            T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
            SetEntrySCTable( T, 1, 2, [1,1] );
            SetEntrySCTable( T, 1, 3, [1,2] );
            SetEntrySCTable( T, 2, 3, [1,3] );
            SetEntrySCTable( T, 1, 4, [1,3] );
            SetEntrySCTable( T, 4, 5, [a,6] );
            SetEntrySCTable( T, 4, 6, [1,5,1,6] );
            
            Add( list, LieAlgebraByStructureConstants( F, T ));
        fi;
    od;
    
    # W(1,2) semidirect non-abelian 
    # two lie algebras
    
    # 1st Lie algebra. W(1,2) + non-abelian
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 4, [1,3] );
    SetEntrySCTable( T, 5, 6, [1,6] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # 2nd Lie algebra. W(1,2) semidir non-abelian
    # it is isomorphic to the first one
    #T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    #SetEntrySCTable( T, 1, 2, [1,1] );
    #SetEntrySCTable( T, 1, 3, [1,2] );
    #SetEntrySCTable( T, 2, 3, [1,3] );
    #SetEntrySCTable( T, 1, 4, [1,3] );
    #SetEntrySCTable( T, 5, 6, [1,6] );
    #SetEntrySCTable( T, 4, 6, [1,6] );
    
    #Add( list, LieAlgebraByStructureConstants( F, T ));
            
    # 3-dim radical
    
    # W(1,2)^{(1)} + 3-dim solvable.
    
    for L in AllSolvableLieAlgebrasSLAC( F, 3 ) do
        b := Basis( L );
        c12 := Coefficients( b, b[1]*b[2] );
        c13 := Coefficients( b, b[1]*b[3] );
        c23 := Coefficients( b, b[2]*b[3] );
      
        T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 1, 2, [1,1] );
        SetEntrySCTable( T, 1, 3, [1,2] );
        SetEntrySCTable( T, 2, 3, [1,3] );
        SetEntrySCTable( T, 4, 5, [c12[1], 4, c12[2], 5, c12[3], 6] );
        SetEntrySCTable( T, 4, 6, [c13[1], 4, c13[2], 5, c13[3], 6] );
        SetEntrySCTable( T, 5, 6, [c23[1], 4, c23[2], 5, c23[3], 6] );
        
        Add( list, LieAlgebraByStructureConstants( F, T ));
    od;
    
    # W(1,2)^{(1)} + O(1,2)/k
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    
    SetEntrySCTable( T, 1, 5, [1,4] );
    SetEntrySCTable( T, 1, 6, [1,5] );
    SetEntrySCTable( T, 2, 4, [1,4] );
    SetEntrySCTable( T, 2, 6, [1,6] );
    SetEntrySCTable( T, 3, 4, [1,5] );
    SetEntrySCTable( T, 3, 5, [1,6] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # Non-split extension 0 -> O(1,2)/k -> L -> W(1,2)^{(1)} -> 0
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,1,1,6] );
    SetEntrySCTable( T, 2, 3, [1,3] );
    SetEntrySCTable( T, 1, 3, [1,2] );
    SetEntrySCTable( T, 2, 4, [1,4] );
    SetEntrySCTable( T, 2, 6, [1,6] );
    SetEntrySCTable( T, 1, 5, [1,4] );
    SetEntrySCTable( T, 1, 6, [1,5] );
    SetEntrySCTable( T, 3, 4, [1,5] );
    SetEntrySCTable( T, 3, 5, [1,6] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    return list;
    
end;

NS_6_charodd := function( F )
    local list, T, a, L, x, k, f, c12, c13, c23, b, l, i;
    
    list := [];
    
    # The algebras from Theorem 5.2
    
    # sl(2,F) + sl(2,F)
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    SetEntrySCTable( T, 1, 3, [-2,1] );
    SetEntrySCTable( T, 2, 3, [2,2] );
    
    SetEntrySCTable( T, 4, 5, [1,6] );
    SetEntrySCTable( T, 4, 6, [-2,4] );
    SetEntrySCTable( T, 5, 6, [2,5] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # sl(2,F<x>) where F<x> is a quadratic extension
    
    L := NonSolvableLieAlgebras( GF( Size( F )^2 ), 3 )[1];
    L := LieAlgebra( F, Basis( AsVectorSpace( F, L )));
    Setter( IsFiniteDimensional )( L, true );
    Add( list, L );
    
    if Characteristic( F ) = 5 then
        
        # W(1,1)+F
        
        T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 1, 2, [1,1] );
        SetEntrySCTable( T, 1, 3, [1,2] );
        SetEntrySCTable( T, 1, 4, [1,3] );
        SetEntrySCTable( T, 1, 5, [1,4] );
        SetEntrySCTable( T, 2, 3, [1,3] );
        SetEntrySCTable( T, 2, 4, [2,4] );
        SetEntrySCTable( T, 2, 5, [3,5] );
        SetEntrySCTable( T, 3, 4, [2,5] );
        Add( list, LieAlgebraByStructureConstants( F, T ));    
        
        # central, Frattini extension of W(1,1)
        
        T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 1, 2, [1,1] );
        SetEntrySCTable( T, 1, 3, [1,2] );
        SetEntrySCTable( T, 1, 4, [1,3] );
        SetEntrySCTable( T, 1, 5, [1,4] );
        SetEntrySCTable( T, 2, 3, [1,3] );
        SetEntrySCTable( T, 2, 4, [2,4] );
        SetEntrySCTable( T, 2, 5, [3,5] );
        SetEntrySCTable( T, 3, 4, [2,5] );
        SetEntrySCTable( T, 4, 5, [1,6] );
        Add( list, LieAlgebraByStructureConstants( F, T ));    
    fi;
    
    # The Lie algebras in Theorem 5.3
    
    # sl(2,F) + solvable
    
    for L in AllSolvableLieAlgebrasSLAC( F, 3 ) do
        b := Basis( L );
        c12 := Coefficients( b, b[1]*b[2] );
        c13 := Coefficients( b, b[1]*b[3] );
        c23 := Coefficients( b, b[2]*b[3] );
      
        T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 1, 2, [1,3] );
        SetEntrySCTable( T, 1, 3, [-2,1] );
        SetEntrySCTable( T, 2, 3, [2,2] );
        SetEntrySCTable( T, 4, 5, [c12[1], 4, c12[2], 5, c12[3], 6] );
        SetEntrySCTable( T, 4, 6, [c13[1], 4, c13[2], 5, c13[3], 6] );
        SetEntrySCTable( T, 5, 6, [c23[1], 4, c23[2], 5, c23[3], 6] );
        
        Add( list, LieAlgebraByStructureConstants( F, T ));
    od;
    
    # sl(2,F) semidirect V(1)+V(0)
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    SetEntrySCTable( T, 1, 3, [-2,1] );
    SetEntrySCTable( T, 2, 3, [2,2] );
    
    SetEntrySCTable( T, 4, 1, [1,5] );
    SetEntrySCTable( T, 5, 2, [1,4] );
    SetEntrySCTable( T, 4, 3, [1,4] );
    SetEntrySCTable( T, 5, 3, [-1,5] );
    
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # sl(2,F) semidirect V(2)
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    SetEntrySCTable( T, 1, 3, [-2,1] );
    SetEntrySCTable( T, 2, 3, [2,2] );
    
    SetEntrySCTable( T, 4, 1, [2,5] );
    SetEntrySCTable( T, 5, 1, [2,6] );
    SetEntrySCTable( T, 5, 2, [1,4] );
    SetEntrySCTable( T, 6, 2, [1,5] );
    SetEntrySCTable( T, 4, 3, [2,4] );
    SetEntrySCTable( T, 6, 3, [-2,6] );
    Add( list, LieAlgebraByStructureConstants( F, T ));
    
    # rad L abelian and char = 3
    
    if Characteristic( F ) = 3 then
        x := Indeterminate( F );
        for a in F do
            if not IsIrreducible( x^3+x^2-a ) then
                f := Factors( x^3+x^2-a );
                i := 1;
                repeat
                    k := CoefficientsOfUnivariatePolynomial( f[i] )[1];
                until Degree( f[i] ) = 1;
                l := k^3;
                
                T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
                SetEntrySCTable( T, 2, 1, [2,1] );
                SetEntrySCTable( T, 2, 3, [-2,3] );
                SetEntrySCTable( T, 1, 3, [1,2] );
                
                SetEntrySCTable( T, 4, 1, [-1,5] );
                SetEntrySCTable( T, 5, 1, [-1,6] );
                SetEntrySCTable( T, 6, 1, [-1,4] );
                
                
                SetEntrySCTable( T, 5, 2, [-2,5] );
                SetEntrySCTable( T, 6, 2, [-1,6] );
                
                SetEntrySCTable( T, 4, 3, [-l,6] );
                SetEntrySCTable( T, 5, 3, [-l,4] );
                SetEntrySCTable( T, 6, 3, [2-l,5] );
                Add( list, LieAlgebraByStructureConstants( F, T ));
            fi;
        od;
        
        # W( 1, 1 ) semidirect O(1,1)
        
        T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 1, 2, [1,1] );
        SetEntrySCTable( T, 1, 3, [1,2] );
        SetEntrySCTable( T, 2, 3, [1,3] );
        
        SetEntrySCTable( T, 1, 5, [1,4] );
        SetEntrySCTable( T, 1, 6, [1,5] );
        SetEntrySCTable( T, 2, 5, [1,5]);
        SetEntrySCTable( T, 2, 6, [2,6] );
        SetEntrySCTable( T, 3, 5, [1,6] );
        Add( list, LieAlgebraByStructureConstants( F, T ));
        
        # W( 1, 1 ) semidirect O(1,1)* (the dual action)
        
        T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 1, 2, [-1,1] );
        SetEntrySCTable( T, 1, 3, [-1,2] );
        SetEntrySCTable( T, 2, 3, [-1,3] );
        
        SetEntrySCTable( T, 1, 4, [1,5] );
        SetEntrySCTable( T, 1, 5, [1,6] );
        SetEntrySCTable( T, 2, 5, [1,5] );
        SetEntrySCTable( T, 2, 6, [2,6] );
        SetEntrySCTable( T, 3, 6, [1,5] );
        Add( list, LieAlgebraByStructureConstants( F, T ));
        
        #  W( 1, 1 ) semidirect O(1,1) and [x,x^2]=1 [L,1]=0
        
        T := EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 1, 2, [1,1] );
        SetEntrySCTable( T, 1, 3, [1,2] );
        SetEntrySCTable( T, 2, 3, [1,3] );
        
        SetEntrySCTable( T, 1, 5, [1,4] );
        SetEntrySCTable( T, 1, 6, [1,5] );
        SetEntrySCTable( T, 2, 5, [1,5]);
        SetEntrySCTable( T, 2, 6, [2,6] );
        SetEntrySCTable( T, 3, 5, [1,6] );
        SetEntrySCTable( T, 5, 6, [1,4] );
        Add( list, LieAlgebraByStructureConstants( F, T ));
        
        # The algebras from Proposition 4.5
        
        # a=b=0
        
        T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 2, 1, [-1,1,1,5] );        
        SetEntrySCTable( T, 2, 3, [1,3] );        
        SetEntrySCTable( T, 1, 3, [1,2] );        
        SetEntrySCTable( T, 2, 4, [1,4] );        
        SetEntrySCTable( T, 2, 5, [-1,5] );        
        SetEntrySCTable( T, 1, 5, [1,4] );        
        SetEntrySCTable( T, 3, 4, [1,5] );        
        Add( list, LieAlgebraByStructureConstants( F, T ));
        
        # a=0, b=1
        
        # T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        # SetEntrySCTable( T, 2, 1, [-1,1,1,5] );        
        # SetEntrySCTable( T, 2, 3, [1,3] );        
        # SetEntrySCTable( T, 1, 3, [1,2] );        
        # SetEntrySCTable( T, 2, 4, [1,4] );        
        # SetEntrySCTable( T, 2, 5, [-1,5] );        
        # SetEntrySCTable( T, 1, 5, [1,4] );        
        # SetEntrySCTable( T, 3, 4, [1,5] );        
        # SetEntrySCTable( T, 4, 5, [1,6] );        
        # Add( list, LieAlgebraByStructureConstants( F, T ));
        
        # a=1, b=0
        
        T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 2, 1, [-1,1,1,5] );        
        SetEntrySCTable( T, 2, 3, [1,3] );        
        SetEntrySCTable( T, 1, 3, [1,2] );        
        SetEntrySCTable( T, 2, 4, [1,4] );        
        SetEntrySCTable( T, 2, 5, [-1,5] );        
        SetEntrySCTable( T, 1, 5, [1,4] );        
        SetEntrySCTable( T, 3, 4, [1,5] );        
        SetEntrySCTable( T, 1, 4, [1,6] );        
        Add( list, LieAlgebraByStructureConstants( F, T ));
        
        # The two lie algebras from Theorem 5.4
        
        T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 2, 1, [-1,1,1,5] );        
        SetEntrySCTable( T, 2, 3, [1,3] );        
        SetEntrySCTable( T, 1, 3, [1,2] );        
        SetEntrySCTable( T, 2, 4, [1,4] );        
        SetEntrySCTable( T, 2, 5, [-1,5] );        
        SetEntrySCTable( T, 1, 5, [1,4] );        
        SetEntrySCTable( T, 3, 4, [1,5] );        
        
        SetEntrySCTable( T, 6, 1, [1,5] );        
        Add( list, LieAlgebraByStructureConstants( F, T ));
        
        # the other algebra
        
        T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
        SetEntrySCTable( T, 2, 1, [-1,1,1,5] );        
        SetEntrySCTable( T, 2, 3, [1,3] );        
        SetEntrySCTable( T, 1, 3, [1,2] );        
        SetEntrySCTable( T, 2, 4, [1,4] );        
        SetEntrySCTable( T, 2, 5, [-1,5] );        
        SetEntrySCTable( T, 1, 5, [1,4] );        
        SetEntrySCTable( T, 3, 4, [1,5] );        
        
        SetEntrySCTable( T, 6, 3, [1,4] );        
        Add( list, LieAlgebraByStructureConstants( F, T ));
    fi;
    
    # sl(2,F) semidirect Heisenberg
     
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    SetEntrySCTable( T, 1, 3, [-2,1] );
    SetEntrySCTable( T, 2, 3, [2,2] );
    
    SetEntrySCTable( T, 4, 1, [1,5] );
    SetEntrySCTable( T, 5, 2, [1,4] );
    SetEntrySCTable( T, 4, 3, [1,4] );
    SetEntrySCTable( T, 5, 3, [-1,5] );
    SetEntrySCTable( T, 4, 5, [1,6] );        
    Add( list, LieAlgebraByStructureConstants( F, T ));
     
    # sl(2,F) semidirect Rad( L ). Rad( L ) = Z(L)+V(1) and 
    # Rad( L ) = <d,u,v> [d,u]=u, [d,v]=v;
    
    T:= EmptySCTable( 6, Zero(F), "antisymmetric" );
    SetEntrySCTable( T, 1, 2, [1,3] );
    SetEntrySCTable( T, 1, 3, [-2,1] );
    SetEntrySCTable( T, 2, 3, [2,2] );
    
    SetEntrySCTable( T, 4, 1, [1,5] );
    SetEntrySCTable( T, 5, 2, [1,4] );
    SetEntrySCTable( T, 4, 3, [1,4] );
    SetEntrySCTable( T, 5, 3, [-1,5] );
    SetEntrySCTable( T, 6, 4, [1,4] );
    SetEntrySCTable( T, 6, 5, [1,5] );
    Add( list, LieAlgebraByStructureConstants( F, T ));
     
    return list;
end;

            
