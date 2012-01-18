#############################################################################
##
#W  matfield.gi     Alnuth - ALgebraic NUmber THeory           Bettina Eick
#W       					             Bjoern Assmann
#W                                                          Andreas Distler
##

#############################################################################
##
#P  IsNumberFieldByMatrices( <F> )
##
InstallSubsetMaintenance( IsNumberFieldByMatrices,
    IsField and IsNumberFieldByMatrices, IsField  );

#############################################################################
##
#F AL_SplitSemisimple( base )
##
AL_SplitSemisimple := function( base )
    local  d, b, f, s, i;
    d := Length( base );
    b := PrimitiveAlgebraElement( [  ], base );
    f := Factors( b.poly );
    if Length( f ) = 1  then
        return [ rec(
                basis := IdentityMat( Length( b.elem ) ),
                poly := f ) ];
    fi;
    s := List( f, function ( x )
            return NullspaceRatMat( Value( x, b.elem ) );
        end );
    s := List( [ 1 .. Length( f ) ], function ( x )
            return rec(
                basis := s[x],
                poly := f[x] );
        end );
    return s;
end;

#############################################################################
##
#F AL_RadicalOfAbelianRMGroup( mats, d )
##
## <mats> is an abelian rational matrix group
##
AL_RadicalOfAbelianRMGroup := function( mats, d )
    local coms, i, j, new, base, full, nath, indm, l, algb, newv, tmpb, subb,
          f, g, h, mat;
 
    base := [];
    full := IdentityMat( d );
    # nath is the natural hom. from V to V/W
    nath := NaturalHomomorphismBySemiEchelonBases( full, base );
    # indm for induced matrices
    indm := mats;
 
    # start spinning up basis and look for nilpotent elements
    i := 1;
    algb := [];
    while i <= Length( indm ) do
 
        # add next element to algebra basis
        l := Length( algb );
        newv := Flat( indm[i] );
        tmpb := SpinnUpEchelonBase(algb, [newv], indm{[1..i]},OnMatVector );
 
        # check whether we have added a non-semi-simple element
        subb := [];
        for j in [l+1..Length(tmpb)] do
            mat := MatByVector( tmpb[j], Length(indm[i]) );
            f := MinimalPolynomial( Rationals, mat );
            g := Collected( Factors( f ) );
            if ForAny( g, x -> x[2] > 1 ) then
                h := Product( List( g, x -> Value( x[1], mat ) ) );
                Append( subb, List( h, x -> ShallowCopy(x) ) );
            fi;
        od;
        #Print("found nilpotent submodule of dimension ", Length(subb),"\n");
 
        # spinn up new subspace of radical
        subb := SpinnUpEchelonBase( [], subb, indm, OnRight );
        if Length( subb ) > 0 then
            base := PreimageByNHSEB( subb, nath );
            if Length( base ) = d then
                # radical cannot be so big
                return fail;
            fi;
            nath := NaturalHomomorphismBySemiEchelonBases( full, base );
            indm := List( mats, x -> InducedActionFactorByNHSEB( x, nath ) );
            algb := [];
            i := 1;
        else
            i := i + 1;
        fi;
    od;
    return rec( radical := base, nathom := nath, algebra := algb );
end;

#############################################################################
##
#F AL_HomogeneousSeriesAbelianRMGroup( mats, d )
##
## <mats> is an abelian rational matrix group
##
AL_HomogeneousSeriesAbelianRMGroup := function( mats, d )
    local radb, splt, nath,inducedgens, l, sers, i, sub, full, acts, rads;

    # catch the trivial case and set up
    if d = 0 then
        return []; 
    fi;
    full := IdentityMat( d );
    if Length( mats ) = 0 then 
        return [full, []]; 
    fi;
    sers := [full];

    # get the radical 
    radb := AL_RadicalOfAbelianRMGroup( mats, d );
    if radb = fail then return fail; fi;
    splt := AL_SplitSemisimple( radb.algebra );
    nath := radb.nathom;

    # refine radical factor and initialize series
    l := Length( splt );
    for i in [2..l] do
        sub := Concatenation( List( [i..l], x -> splt[x].basis ) );
        TriangulizeMat( sub ); 
        Add( sers, PreimageByNHSEB( sub, nath ) );
    od;
    Add( sers, radb.radical );

    # induce action to radical
    nath := NaturalHomomorphismBySemiEchelonBases( full, radb.radical);
    acts := List( mats, x -> InducedActionSubspaceByNHSEB( x, nath ));
   
    # use recursive call to refine radical
    rads := AL_HomogeneousSeriesAbelianRMGroup( acts, Length(radb.radical) );
    if rads = fail then return fail; fi;
    rads := List( rads, function(x) if x=[] then return []; else
                            return x * radb.radical; fi;end );
    Append( sers, rads{[2..Length(rads)]} );
    return sers;
end;

#############################################################################
##
#F AL_MatricesGeneratingNumberField( gens )
##
AL_MatricesGeneratingNumberField := function( gens )
    local d, series, G;
    d := Length(gens[1]);
    if ForAny( gens, x -> Length(x) <> d ) then 
        Print("matrices must have same dimensions\n");
        return false;
    elif not ForAll( Flat( gens ), IsRat ) then
        Print("matrices must be rational\n");
        return false; 
    elif ForAny( gens, x -> RankMat(x) <> d ) then 
        Print("matrices must be invertible \n");
        return false;
    fi;
    G := Group( gens );
    if not IsAbelian( G ) then
        Print( "The algebra generated by the matrices is not abelian\n" );
        return false;
    fi;
    series := AL_HomogeneousSeriesAbelianRMGroup( gens, d );
    if Length( series ) > 2 then
        Print( "Matrices do not generate a field.\n" );
        Print( "The natural module Q^",d," is not homogeneous.\n" );
        return false;
    fi;
    return true;
end;

#############################################################################
##
#F FieldByMatrices( gens )
##
InstallGlobalFunction( FieldByMatricesNC, function( gens ) 
    local F;
    F := FieldByGenerators( gens);
    SetIsNumberField( F, true );
    SetIsNumberFieldByMatrices( F, true );
    return F;
end );  

InstallGlobalFunction( FieldByMatrices, function( gens )
    local F;
    if not AL_MatricesGeneratingNumberField( gens ) then return fail; fi;
    F := FieldByMatricesNC( gens );
    DegreeOverPrimeField( F );
    return F;
end );


#############################################################################
##
#F FieldByMatrixBasisNC( gens ) . . . MatFieldByAlgebraBasis
##
InstallGlobalFunction( FieldByMatrixBasisNC, function( gens ) 
    local F, B;
    F := FieldByMatricesNC( gens );
    B := Objectify(NewType(FamilyObj(F), IsBasisOfMatrixField), rec());
    SetUnderlyingLeftModule( B, F );
    SetBasisVectors( B, gens );
    SetBasis( F, B );
    DegreeOverPrimeField( F );
    return F;
end );

InstallGlobalFunction( FieldByMatrixBasis, function( gens )
    local V;
    if not AL_MatricesGeneratingNumberField( gens ) then return fail; fi;
    V := VectorSpace( Rationals, gens );
    # test linear independence
    if Length( Basis( V )) < Length( gens ) then
        Print("matrices must be linearly independent\n"); 
        return fail;
    fi;
    # test whether V = Field( gens )
    if Length( AlgebraBase( gens )) > Length( gens ) then
            Print("dimension of generated field is greater than vector space dimension\n"); 
            return fail; 
    fi;

    return FieldByMatrixBasisNC( gens );
end );

#############################################################################
##
#F BasisVectorsOfMatrixField( F )
#M CanonicalBasis( F )
#M Basis( F )
##
BasisVectorsOfMatrixField := function( F )
    return AlgebraBase( GeneratorsOfField(F) );
end;

InstallMethod( CanonicalBasis, "for matrix field", true, 
[IsNumberFieldByMatrices], 0, 
function( F ) 
    local B, b;
    B := Objectify(NewType(FamilyObj(F), IsBasisOfMatrixField), rec());
    b := BasisVectorsOfMatrixField( F );
    SetUnderlyingLeftModule( B, F );
    SetBasisVectors( B, b );
    return B;
end );

InstallMethod( Basis, "for matrix field", true,
[IsNumberFieldByMatrices], 0, 
function( F ) return CanonicalBasis( F ); end );


#############################################################################
##
#M Coefficients( B, a )
##
InstallMethod( Coefficients, "for basis of matrix field", true,
[IsBasisOfMatrixField, IsVector ], 15,
function( B, a )
    local b;
    b := BasisVectors( B );
    b := List( b, Flat );
    return SolutionMat( b, Flat(a) );
end );
 

#############################################################################
##
#M DegreeOverPrimeField( F )
##
InstallMethod( DegreeOverPrimeField, "for matrix field", true, 
[IsNumberFieldByMatrices], 0, function( F ) 
return Length( Basis( F ) ); end);


#############################################################################
##
#F IntegralMatrix
#F SuitablePrimitiveElementCheck( F, k )
##
IntegralMatrix := function( mat ) 
    local l,n,i,j,a;
    l := [];
    n := Length( mat );
    for i in [1..n] do
        for j in [1..n] do
            Add( l, DenominatorRat( mat[i][j]) );
        od;
    od;
    a := Lcm( l );
    return a*mat;
end;

SuitablePrimitiveElementCheck := function( F, k )
    local d, g, sumCoef;
    d := DegreeOverPrimeField( F );
    g := MinimalPolynomial( Rationals, k );
    if not Degree(g) = d then
        return false;
    elif ForAll( CoefficientsOfUnivariatePolynomial(g), IsInt ) then
        sumCoef := Sum(
	        List(CoefficientsOfUnivariatePolynomial(g),x->AbsInt(x)) 
                ); 
        Info( InfoAlnuth, 3, "sum of the coefficients is");
        Info( InfoAlnuth, 3, sumCoef );
        return rec( prim := k, min := g, sumCoef := sumCoef);
    else
        k := IntegralMatrix( k );
        g := MinimalPolynomial( Rationals, k );  
        sumCoef := Sum(
	        List(CoefficientsOfUnivariatePolynomial(g),x->AbsInt(x)) 
                ); 
        Info( InfoAlnuth, 3, "sum of the coefficients is");
        Info( InfoAlnuth, 3, sumCoef );
        return rec( prim := k, min := g, sumCoef := sumCoef);
    fi;
end; 


#############################################################################
##
#F SuitablePrimitiveElementOfMatrixField( F )
#M IntegerPrimitiveElement( F )
#M PrimitiveElement( F )
##
SuitablePrimitiveElementOfMatrixField := function( F )
    local k, d, b, l, i, c, primtmp,prim, poss; 
    # try to find a primitive element wiht small coeff in the minpol
    prim := rec( prim := [], min := [], sumCoef := infinity);
    poss := 0;
   
    #catch the trivial case 
    if DegreeOverPrimeField(F)=1 then
        return One(F);
    fi;
    # first try the generators of F
    for k in GeneratorsOfField(F) do
        primtmp := SuitablePrimitiveElementCheck( F, k );
        if not IsBool( primtmp ) then
            poss := poss + 1;
            if primtmp.sumCoef < prim.sumCoef then
                prim := primtmp;
            fi;
        fi;
    od;

    # otherwise try random elements 
    d := DegreeOverPrimeField( F );
    b := Basis(F);
    l := List( [1..d], x -> 0 ); Append( l, [1,1,-1] );
    i := 1;
    while poss < PRIM_TEST do
        Info( InfoAlnuth, 3, "another try to calculate primitive element");
        Info( InfoAlnuth, 3, i );
        c := List( [1..d], x -> RandomList( l ) );
        k := LinearCombination( b, c );
        primtmp := SuitablePrimitiveElementCheck( F, k );
        if not IsBool( primtmp ) then
            poss := poss + 1;
            if primtmp.sumCoef < prim.sumCoef then
                prim := primtmp;
            fi;
        fi;
        i := i + 1;
        Append( l, [i,i,-i] );
    od;
 
    SetDefiningPolynomial( F, prim.min );
    SetIntegerDefiningPolynomial( F, prim.min );
    Info( InfoAlnuth, 2, "prim is ", prim);
    return prim.prim;
end;

InstallMethod( IntegerPrimitiveElement, "for matrix field", true, 
[IsNumberFieldByMatrices], 0, function( F ) return 
SuitablePrimitiveElementOfMatrixField(F); end);

InstallMethod( PrimitiveElement, "for matrix field", true, 
[IsNumberFieldByMatrices], 0, function( F ) return 
IntegerPrimitiveElement(F); end);

InstallOtherMethod( DefiningPolynomial, "for matrix field", true, 
[IsNumberFieldByMatrices], 0, function( F )  
    return MinimalPolynomial( Rationals, PrimitiveElement(F) ); 
end);

#############################################################################
##
#M IntegerDefiningPolynomial( F )
##
InstallMethod( IntegerDefiningPolynomial, "for matrix field", true,
[IsNumberFieldByMatrices], 0, 
function( F )
    return MinimalPolynomial( Rationals, IntegerPrimitiveElement( F ) );
end );

#############################################################################
##
#F Norm(F,k)
##
InstallOtherMethod( Norm, "for matrix fields", true,
[IsNumberFieldByMatrices, IsMultiplicativeElement], SUM_FLAGS,
function( F, k ) 
    local l, d;
    l := Length(k);
    d := DegreeOverPrimeField(F);
    return Root( Determinant(k), l/d ); 
end );

#############################################################################
##
#M  PrintObj( F ) 
#M  ViewObj( F )
##
InstallMethod( PrintObj, "for a matrix field", true,
[IsNumberFieldByMatrices], 0, 
function( F )
    if HasDegreeOverPrimeField( F ) then
        Print( "<rational matrix field of degree ", 
               DegreeOverPrimeField( F ), ">" );
    else
        Print("<rational matrix field of unknown degree>");
    fi;
end );

InstallMethod( ViewObj, "for a matrix field", true,
[IsNumberFieldByMatrices], 0, 
function( F )
    if HasDegreeOverPrimeField( F ) then
        Print( "<rational matrix field of degree ", 
               DegreeOverPrimeField( F ), ">" );
    else
        Print("<rational matrix field of unknown degree>");
    fi;
end );


 















