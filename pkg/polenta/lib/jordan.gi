#############################################################################
##
#W jordan.gi               POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## the multiplicative jordan decomposition.
##
#H  @(#)$Id: jordan.gi,v 1.8 2011/09/23 13:36:32 gap Exp $
##
#Y 2003
##

## IN: matrix g.
## OUT:: g_s, g_u.
##
##      Maybe later: Install a method for this.
##
POL_MultiplicativeJordanDecomposition := function( g )
    local ll, semi, uni;

    # get semisimple part via the additive jordan decomposition
    ll := JordanDecomposition( g );
    semi := ll[1];

    # get unipotent part
    uni := semi^-1 * g;

    # do some tests
    if not Comm( semi, uni ) = semi^0  then
        Error( "don't commute" );
    fi;

    return [ semi, uni ];
end;

# get some exams
# gens := POL_AbelianIrreducibleGens( 2 );
#
if false then
    n_blocks := 2;
    n_gens := 2;
    gens := POL_TriangularizableGens( n_blocks, n_gens );


    mat :=
     [ [ 6, 8, 6, -11, 1/2, 0, 0, 0 ], [ -7, -9, -8, 11, 0, 0, 1/2, 0 ],
       [ -6, -9, -7, 11, 0, 0, 1/2, 0 ], [ -3, -4, -4, 4, 0, 1/2, 0, 0 ],
       [ 0, 0, 0, 0, -23, -34, -26, 44 ], [ 0, 0, 0, 0, 36, 53, 42, -66 ],
       [ 0, 0, 0, 0, 36, 52, 41, -66 ], [ 0, 0, 0, 0, 22, 32, 26, -39 ] ];

    x := Indeterminate(Rationals,"x": old );
    pol := x^2+1;
    pol := x^3+2*x+2;
    pol := x^3-x +7;
    pol := x^2 + 1/2;

    mat := CompanionMat( pol );
    mat2 := mat * One( F );

    F := AlgebraicExtension( Rationals, pol );
    pol2 := AlgExtEmbeddedPol(F,pol);
    Factors( pol2 );

    #or use FactorsPolynomialAlgExt( F, pol );

    a := RootOfDefiningPolynomial( F );
    id := IdentityMat( 2, F );
    NullspaceIntMat(  mat2 - a*id );

fi;


## IN: args[1]=mat ..................... semisimple rational matrix.
##     args[2]=pol ..................... minimal or char polynomial of
##                                       mat. (optional parameter)
## Comment: Several strategies are possible.
## We could first compute a homogeneous series for the
## <mat>-module Q^d and then diagonalize these.
##
## For the moment we do it in an easier way.
## Compute an extension field that contains all roots
## of the (possible non-irreducible) minimal polynomial of mat.
##
## We probably need that field anyway later when we use
## it for symbolic collection.
##
POL_DiagonalizeMat := function( args )
    local pol, F, factors, eigen_values, eigen_spaces, id, space, T, e,fil,mat;

    # setup
    mat := args[1];
    if Length( args ) = 2 then
        pol := args[2];
    else
        pol := CharacteristicPolynomial( Rationals, Rationals, mat );
    fi;

    # compute the extension field of the rationals that contains
    # all eigenvalues of mat.
    # SplittingField over the rationals requires the radiroot GAP package!
    F := SplittingField(  pol );
    factors := FactorsPolynomialAlgExt( F, pol );

    # check whether all factors have degree one
    fil := Filtered( factors, x->Degree(x) > 1 );
    if Length( fil ) > 0 then
        Error( "There are non-linear factors" );
    fi;

    # get Eigen values
    eigen_values := List( factors, f-> -1*Value(f,0) );

    # compute the according eigenspaces
    eigen_spaces := [];
    id := mat^0;
    for e in eigen_values do
        space := NullspaceMat( mat - e*id );
        Add( eigen_spaces, space );
    od;

    # get base change matrix from eigen vector basis to standard basis
    # T*mat*T^-1 is in diagonal form
    T := Concatenation( eigen_spaces );

    # attach info to matrix
    # ?

    return rec( diagonalmat := T*mat*T^-1,
                eigen_values := eigen_values,
                eigen_spaces := eigen_spaces,
                baseChange := T,
                splitField := F );
end;

POL_AlgebraBase := function( mats )
    local base, flat;
     if Length( mats ) = 0 then return []; fi;
     flat := List( mats, Flat );
     base := SpinnUpEchelonBase( [], flat, mats, OnMatVector);
     return base;
end;


if false then
    mat1 := [ [ 0, 0, -2 ], [ 1, 0, -2 ], [ 0, 1, 0 ] ];
    mat2 := 2* mat1;
    mats := [mat1,mat2];
fi;

## IN mats ............. semisimple and commuting matrices over Q
##
POL_DiagonalizeMatsSimultaneously := function( mats )
    local basis, g_rec, g, pol, diag_rec, T, Tinv, primitiveElm;

    # get primitive element g for the Q-algebra Q[mats]
    basis := POL_AlgebraBase( mats );
    g_rec := PrimitiveAlgebraElement( mats, basis );
    g := g_rec.elem;
    pol := g_rec.poly;

    # diagonalize this element g
    diag_rec := POL_DiagonalizeMat( [g, pol] );
    T := diag_rec.baseChange;
    Tinv := T^-1;

    # return list of diagonalized matrices,
    # and full information for T.
    return rec( diagonalmats := List( mats, x->T*x*Tinv ),
                basis := basis,
                primitiveElm := g,
                pol := pol,
                diag_rec := diag_rec,
                T := T,
                Tinv := Tinv );

end;


## IN: Triangularizable group G = <g1,...,gr>
## OUT: attached to each gi the decomposition.
##      the all should use the same base change (that is coming
##      from the same radical series.
##      Attach to G the radical series all other meta information that you
##      to decompose.
##      Then you should have a second function that does
##      the decomposition for an arbitrary element.
##

# RereadPackage( "polenta", "lib/jordan.gi" );
#############################################################################
##
#E
