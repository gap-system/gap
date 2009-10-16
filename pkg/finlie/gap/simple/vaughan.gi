
VaughanLeeAlgebras := function(n)
    local S, L;

    if n = 1 then 
        S := EmptySCTable( 6, Zero(GF(2)), "antisymmetric" );

        SetEntrySCTable( S, 2, 1, [1, 3] );
        SetEntrySCTable( S, 3, 1, [1, 4] );
        SetEntrySCTable( S, 4, 1, [1, 5] );
        SetEntrySCTable( S, 5, 1, [1, 2, 1, 4] );

        SetEntrySCTable( S, 3, 2, [1, 1] );
        SetEntrySCTable( S, 5, 2, [1, 1, 1, 6] );
        SetEntrySCTable( S, 6, 2, [1, 3, 1, 5] );

        SetEntrySCTable( S, 4, 3, [1, 1, 1, 6] );
        SetEntrySCTable( S, 6, 3, [1, 2] );

        SetEntrySCTable( S, 5, 4, [1, 6] );
        SetEntrySCTable( S, 6, 4, [1, 3] );
        SetEntrySCTable( S, 6, 5, [1, 4] );

        if not TestJacobi(S)=true then Error("no Jacobi"); fi;
        L := AlgebraByStructureConstants( GF(2), S );
        SetName(L, "VL6");
    fi;

    if n = 2 then 
        S := EmptySCTable( 7, Zero(GF(2)), "antisymmetric" );

        SetEntrySCTable( S, 2, 1, [1,3] );
        SetEntrySCTable( S, 3, 1, [1,4] );
        SetEntrySCTable( S, 4, 1, [1,5] );
        SetEntrySCTable( S, 5, 1, [1,6] );
        SetEntrySCTable( S, 6, 1, [1,7] );

        SetEntrySCTable( S, 3, 2, [1,2] );
        SetEntrySCTable( S, 4, 2, [1,3] );
        SetEntrySCTable( S, 5, 2, [1,1,1,2,1,4] );
        SetEntrySCTable( S, 6, 2, [1,5] );
        SetEntrySCTable( S, 7, 2, [1,4] );

        SetEntrySCTable( S, 4, 3, [1,1,1,2] );
        SetEntrySCTable( S, 5, 3, [1,3] );
        SetEntrySCTable( S, 6, 3, [1,4,1,6] );
        SetEntrySCTable( S, 7, 3, [1,5] );

        SetEntrySCTable( S, 5, 4, [1,6] );
        SetEntrySCTable( S, 6, 4, [1,7] );
        SetEntrySCTable( S, 7, 4, [1,6] );

        SetEntrySCTable( S, 6, 5, [1,6] );
        SetEntrySCTable( S, 7, 5, [1,7] );

        if not TestJacobi(S)=true then Error("no Jacobi"); fi;
        L := AlgebraByStructureConstants( GF(2), S );
        SetName(L, "VL7_1");
    fi;

    if n = 3 then 
        S := EmptySCTable( 7, Zero(GF(2)), "antisymmetric" );

        SetEntrySCTable( S, 2, 1, [1,3] );
        SetEntrySCTable( S, 3, 1, [1,4] );
        SetEntrySCTable( S, 4, 1, [1,5] );
        SetEntrySCTable( S, 5, 1, [1,6] );
        SetEntrySCTable( S, 6, 1, [1,7] );
        SetEntrySCTable( S, 7, 1, [1,1] );

        SetEntrySCTable( S, 7, 2, [1,2] );

        SetEntrySCTable( S, 6, 3, [1,2] );

        SetEntrySCTable( S, 5, 4, [1,2] );
        SetEntrySCTable( S, 6, 4, [1,3] );
        SetEntrySCTable( S, 7, 4, [1,4] );

        SetEntrySCTable( S, 7, 6, [1,6] );

        if not TestJacobi(S)=true then Error("no Jacobi"); fi;
        L := AlgebraByStructureConstants( GF(2), S );
        SetName(L, "VL7_2");
    fi;

    if n = 4 then 
        S := EmptySCTable( 8, Zero(GF(2)), "antisymmetric" );

        SetEntrySCTable( S, 3, 1, [1,4] );
        SetEntrySCTable( S, 4, 1, [1,5] );
        SetEntrySCTable( S, 5, 1, [1,3,1,4] );
        SetEntrySCTable( S, 6, 1, [1,7] );
        SetEntrySCTable( S, 7, 1, [1,8] );
        SetEntrySCTable( S, 8, 1, [1,6,1,7] );

        SetEntrySCTable( S, 3, 2, [1,4,1,5] );
        SetEntrySCTable( S, 4, 2, [1,3,1,4,1,5] );
        SetEntrySCTable( S, 5, 2, [1,3,1,5] );
        SetEntrySCTable( S, 6, 2, [1,7,1,8] );
        SetEntrySCTable( S, 7, 2, [1,6,1,7,1,8] );
        SetEntrySCTable( S, 8, 2, [1,6,1,8] );

        SetEntrySCTable( S, 4, 3, [1,6] );
        SetEntrySCTable( S, 5, 3, [1,7] );
        SetEntrySCTable( S, 6, 3, [1,1] );
        SetEntrySCTable( S, 7, 3, [1,1,1,2,1,3] );
        SetEntrySCTable( S, 8, 3, [1,1,1,4] );

        SetEntrySCTable( S, 5, 4, [1,6,1,8] );
        SetEntrySCTable( S, 6, 4, [1,1,1,2,1,3] );
        SetEntrySCTable( S, 7, 4, [1,1] );
        SetEntrySCTable( S, 8, 4, [1,2,1,3,1,5] );

        SetEntrySCTable( S, 6, 5, [1,1,1,4] );
        SetEntrySCTable( S, 7, 5, [1,2,1,3,1,5] );
        SetEntrySCTable( S, 8, 5, [1,2] );

        SetEntrySCTable( S, 7, 6, [1,3,1,6] );
        SetEntrySCTable( S, 8, 6, [1,4,1,7] );

        SetEntrySCTable( S, 8, 7, [1,3,1,5,1,6,1,8] );

        if not TestJacobi(S)=true then Error("no Jacobi"); fi;
        L := AlgebraByStructureConstants( GF(2), S );
        SetName(L, "VL8");
    fi;

    if n = 5 then 
        S := EmptySCTable( 9, Zero(GF(2)), "antisymmetric" );

        SetEntrySCTable( S, 4, 1, [1,5] );
        SetEntrySCTable( S, 5, 1, [1,6] );
        SetEntrySCTable( S, 6, 1, [1,7] );
        SetEntrySCTable( S, 7, 1, [1,8] );
        SetEntrySCTable( S, 8, 1, [1,9] );
        SetEntrySCTable( S, 9, 1, [1,4,1,8] );

        SetEntrySCTable( S, 4, 2, [1,9] );
        SetEntrySCTable( S, 5, 2, [1,4,1,8] );
        SetEntrySCTable( S, 6, 2, [1,5,1,9] );
        SetEntrySCTable( S, 7, 2, [1,4,1,6,1,8] );
        SetEntrySCTable( S, 8, 2, [1,5,1,7,1,9] );
        SetEntrySCTable( S, 9, 2, [1,4,1,6] );

        SetEntrySCTable( S, 4, 3, [1,7] );
        SetEntrySCTable( S, 5, 3, [1,8] );
        SetEntrySCTable( S, 6, 3, [1,9] );
        SetEntrySCTable( S, 7, 3, [1,4,1,8] );
        SetEntrySCTable( S, 8, 3, [1,5,1,9] );
        SetEntrySCTable( S, 9, 3, [1,4,1,6,1,8] );

        SetEntrySCTable( S, 5, 4, [1,3] );
        SetEntrySCTable( S, 7, 4, [1,2] );
        SetEntrySCTable( S, 9, 4, [1,1,1,2] );

        SetEntrySCTable( S, 6, 5, [1,2] );
        SetEntrySCTable( S, 8, 5, [1,1,1,2] );

        SetEntrySCTable( S, 7, 6, [1,1,1,2] );
        SetEntrySCTable( S, 9, 6, [1,1,1,2,1,3] );

        SetEntrySCTable( S, 8, 7, [1,1,1,2,1,3] );

        SetEntrySCTable( S, 9, 8, [1,1,1,3] );

        if not TestJacobi(S)=true then Error("no Jacobi"); fi;
        L := AlgebraByStructureConstants( GF(2), S );
        SetName(L, "VL9");
    fi;

    return L;
end;

