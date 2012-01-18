#############################################################################
####
##
#W  Manipulations.gi          RADIROOT package                Andreas Distler
##
##  Installation file for the functions that do various manipulations
##  to special elements of a splitting field and to the permutations
##  in its Galois group   
##
#H  $Id: Manipulations.gi,v 1.3 2011/10/27 18:23:30 gap Exp $
##
#Y  2006
##


#############################################################################
##
#M  GaloisGroupOnRoots( <f> )
#M  GaloisType( <f> )
##
##  Computes the Galois group of the rational polynomial <f> with respect to
##  its roots, created as matrices
##
InstallMethod( GaloisGroupOnRoots, "for rational polynomial",
[ IsUnivariateRationalFunction and IsPolynomial ], function( f )
    local erw, galgrp;
    
    if not ForAll( CoefficientsOfUnivariatePolynomial( f ), IsRat ) then
        TryNextMethod( );
    fi;

    if not IsSeparablePolynomial( f ) then
        Error("f must be separable");
    fi;

    erw := RR_Zerfaellungskoerper( f, rec( roots := [ ],
                                           degs := [ ],
                                           coeffs := [ ],
                                           K:=FieldByMatrices([ [[ 1 ]] ]),
                                           H:=Rationals ));;

    erw.roots := RR_Roots( [ [], erw.roots[1], erw.roots[2] ], erw );;
    Add( erw.roots, 
         -CoefficientsOfUnivariatePolynomial(f)[Degree(f)]*One(erw.K)
         -Sum( erw.roots ) );

    # neccessary to use RR_Produkt in the computation of the Galois group
    erw.unity := 1;
 
    galgrp := RR_ConstructGaloisGroup( erw );

    return galgrp;
end );

InstallMethod(GaloisType,"for polynomials",true,[IsUnivariateRationalFunction
    and IsPolynomial and HasGaloisGroupOnRoots],0,
    function( f )

    if not(IsIrreducibleRingElement(f)) then
        Error("f must be irreducible");
    fi;

    return TransitiveIdentification( GaloisGroupOnRoots( f ));
end );

#############################################################################
##
#F  RR_DegreeConclusion( <B>, <roots> )
##
InstallGlobalFunction( RR_DegreeConclusion, function( B, roots )
    local i, degs;

    degs := [ ];
    roots := Filtered( roots, root -> root in B ); 
    for i in [ 1..Length( roots )-1 ] do
        degs[i] := (Position( B, roots[i+1] ) - 1) / Product(degs);
    od;
    degs[ Length( roots ) ] := Length( B ) / Product(degs);

    return degs;
end );


#############################################################################
##
#F  RR_PrimElImg( <erw>, <perm> )
##
##  Calculates the result for apllying the permutation <perm> to the
##  primitive element of the field in the record <erw>
##
InstallGlobalFunction( RR_PrimElImg, function( erw, perm )

    # basefield = rationals
    if Length(erw.degs) = Length(erw.coeffs) then
        return Sum( [ 1..Length(erw.coeffs) ],
                    i -> erw.coeffs[i] * erw.roots[i^perm] );;
    # basefield = cyclotomic field
    else
        return Sum( [ 2..Length(erw.coeffs) ],
                    i -> erw.coeffs[i] * erw.roots[(i-1)^perm] ) +
               erw.coeffs[1] * erw.unity;;
    fi;
end );


#############################################################################
##
#F  RR_Produkt( <erw>, <elm>, <perm> )
##
##  Calculates the result for apllying the permutation <perm> to the
##  field element <elm>
##
InstallGlobalFunction( RR_Produkt, function( erw, elm, perm )
    local i, k, mat, coeff, degprod, prod;

    mat := 0*One(erw.K);
    coeff := Coefficients( Basis(erw.K), elm );

    # computation with respect to the known order of the basis
    for i in [ 1..Length(coeff) ] do
        if coeff[i] <> 0 then
	        # Einheitswurzel bleibt erhalten
	        # Size(elm)/Product(erw.degs) ist 1, wenn keine
	        # Einheitswurzel adjungiert wurde
	        degprod := Length( coeff ) / Product( erw.degs );
	        prod := erw.unity^RemInt( i-1, degprod );
                # One( erw.K );
                # the roots that built the basis are permuted
	        for k in [ 1..Length(erw.degs) ] do
	            prod := prod * erw.roots[ k^perm ]^QuoInt(
                    RemInt( i-1, degprod * erw.degs[k] ), degprod );
	            degprod := degprod * erw.degs[k];
	        od;
	        mat := mat + coeff[i] * prod;
	    fi;    
    od;

    return mat;
end );


#############################################################################
##
#F  RR_CompositionSeries( <G>, <N> )
##
##  Computes a composition series of <G> through its normal subgroup <N>
##  
InstallGlobalFunction( RR_CompositionSeries, function( G, N )
    local hom, genN, grps, gens;

    if G = N then
        return CompositionSeries( G ); 
    elif Order( G ) / Order( N ) in Primes then
        return Concatenation([ G ], CompositionSeries( N ));
    else
        Info( InfoRadiroot, 3, "        computation of compositon series" );
        hom := NaturalHomomorphismByNormalSubgroupNC( G, N );
        # Generators of Composition Series G/N as free group
        gens := List( CompositionSeries(Range(hom)), GeneratorsOfGroup );
        Unbind( gens[ Length( gens ) ] );
        # Preimages of the Generators in G
        gens := List(gens, ll->List(ll, x->PreImagesRepresentative(hom, x)));
        genN := GeneratorsOfGroup( N );
        grps := List( gens, x -> Group( Concatenation( genN, x )));
    fi;

    return Concatenation( grps, CompositionSeries( N ) );
end );


#############################################################################
##
#F  RR_Potfree( <rat>, <exp> )
##
##  Computes the smallest integer <rat> * q^<exp> with q in the rationals and
##  returns q
##  
InstallGlobalFunction( RR_Potfree, function( rat, exp )
    local num, den;

    num := Product( Collected( Factors( AbsInt( NumeratorRat( rat )))),
                    pe -> pe[1]^( exp * (QuoInt( pe[2], exp ) ) ) );
    den := Product( Collected( Factors( AbsInt( DenominatorRat( rat )))),
                    pe -> pe[1]^( exp * (QuoInt( pe[2], exp ) ) ) );

    return Root( num, exp ) / Root( den, exp );
end );


#############################################################################
##
#F  RR_Resolvent( <G>, <N>, <elm>, <erw> )
##
##  Computes the Lagrange resolvent for the element <elm> and a
##  generator of the factor group of <G> and <N>
##
InstallGlobalFunction( RR_Resolvent, function( G, N, elm, erw )
    local unity, gen, p;

    p := Order( G ) / Order( N );
    # determine gen with G/N = <genN>
    gen := First( Elements( G ), x -> not x in N );
    # p-th root of unity
    if IsInt( Order( erw.unity ) / p ) then
        unity := erw.unity^( Order( erw.unity ) / p );
    else # if RR_SplittField has been used this distinction is necessary
        unity := E( p ) * One( erw.K );
    fi;

    return Sum([ 0..p-1 ], k -> unity^k * RR_Produkt( erw, elm, gen^k ) )/p;
end );


#############################################################################
##
#F  RR_CyclicElements( <erw>, <compser> )
##
##  It is <compser> a composition series for the Galois group of the
##  field in the record <erw>. The function returns a list of elements
##  that generate the corresponding tower of fields. Each element is
##  cyclic in the direct subfield.
##
InstallGlobalFunction( RR_CyclicElements, function( erw, compser )
    local i, k, elements, elm, primEllist, L, n, potelm, primEl;

    if erw.H = Rationals then return [ ]; fi;
    elements := [ ];
    if Length(erw.degs) = Length(erw.coeffs) then
        L := FieldByMatricesNC( [ One( erw.K ) ] );
    else
        L := FieldByMatricesNC( [ erw.unity ] );
    fi;
    for i in [ 2..Length(compser)-1 ] do
        primEllist := List( AsList( compser[i] ),
	                    perm -> RR_PrimElImg( erw, perm ));;
        for k in Flat(List([ 1..Length(primEllist) ],
                           i -> [i, Length(primEllist) + 1 - i ])) do
            elm := Sum( Combinations( [ 1..Length(primEllist) ], k),
                        subset -> Product( subset, x -> primEllist[x]));;
            if not (elm in L) then 
                Info( InfoRadiroot, 3,
                      "        found element of field with degree ",
                      DegreeOverPrimeField( erw.K ) / Order( compser[i] ) );
                break;
            fi;
        od;
        n := Order( compser[i-1] ) / Order( compser[i] );
        for k in [ 1..n ] do
            elements[i-1]:=RR_Resolvent(compser[i-1],compser[i],elm^k,erw);
            if elements[i-1] <> 0 * One( erw.K ) then break; fi;
        od;
        potelm := elements[i-1]^n;;
        if IsDiagonalMat( potelm ) and IsRat( potelm[1][1] ) then
            elements[i-1] := elements[i-1] / RR_Potfree( potelm[1][1], n );
        fi;
        elements[i-1] := [elements[i-1], n];
        if i <> Length(compser)-1 then
          L := FieldByMatricesNC( Concatenation( GeneratorsOfField(L), 
                                                 [ elements[i-1][1] ]));
        fi;
    od;
    i := Length( compser );
    n := Order( compser[i-1] ) / Order( compser[i] );
    for k in [ 1..n ] do
        elements[i-1]:=RR_Resolvent(compser[i-1],compser[i],
                                    PrimitiveElement(erw.K)^k,erw);
        if elements[i-1] <> 0 * One( erw.K ) then break; fi;
    od;
    if i = 2 then
        potelm := elements[i-1]^n;
        if IsDiagonalMat( potelm ) and IsRat( potelm[1][1] ) then
            elements[i-1] := elements[i-1] / RR_Potfree( potelm[1][1], n );
        fi;
    fi;
    elements[i-1] := [elements[i-1], n];

    return elements;
end );


#############################################################################
##
#F  RR_IsInGalGrp( <erw>, <perm> )
##
##  Tests if the permutation <perm> is in the Galois group that
##  belongs to the roots in the record <erw>
##  
InstallGlobalFunction( RR_IsInGalGrp, function( erw, perm )
    local i;

    for i in [ 1..Length(erw.roots) ] do
        if RR_Produkt( erw, erw.roots[i], perm ) <> erw.roots[ i^perm ] then
            return false;
        fi;
    od;

    return true;
end );


#############################################################################
##
#F  RR_ConstructGaloisGroup( <erw> )
##
##  Constructs the Galois group for the roots in the record <erw> with
##  respect to their order 
##
InstallGlobalFunction( RR_ConstructGaloisGroup, function( erw )
    local Sn, rt, ggelm, p, B, imgs, oldgroup;

    Info( InfoRadiroot, 2, "    Construction of the Galoisgroup" );
    ggelm := [ () ];
    oldgroup := [ ];
    if erw.H = Rationals then return Group( ggelm ); fi;
    Sn := SymmetricGroup( Length( erw.roots ) );
    rt := RightTransversal( Sn, Stabilizer( Sn, [ 1..Length(erw.degs) ], 
                                            OnTuples ) );
    imgs := List( rt, perm -> RR_PrimElImg( erw, perm ));;
    if IsDuplicateFreeList( imgs ) then
        Info( InfoRadiroot, 3, "        using fast Galoisgroup computation" );
        repeat
            # sort out already known permutations
            rt := Difference(rt,
                             List(Difference(AsList(Group(ggelm)),oldgroup),
                                  p -> First(rt,
                                             prm->ForAll([1..Length(erw.degs)],
                                                         i->i^prm = i^p))));;
            oldgroup := AsList(Group(ggelm));
            p := Permutation( Remove(rt,1), 
                              erw.roots, 
                              function(x, g) 
                                  return RR_Produkt(erw, x, g);
                              end );
            if p <> fail and Value( DefiningPolynomial(erw.K),
                                    RR_PrimElImg( erw, p )) = 0 * One(erw.K)
            then                
                Add( ggelm, p );
            fi;
        until Order(Group(ggelm)) = Product(erw.degs);
    else
        Info( InfoRadiroot, 3, "        using slow Galoisgroup computation" );
        imgs := DuplicateFreeList(imgs);
        repeat
            imgs := Difference(imgs,
                               List(Difference(AsList(Group(ggelm)),oldgroup),
                                    p->RR_PrimElImg( erw, p )));;
            oldgroup := AsList(Group(ggelm));
            if Value(DefiningPolynomial(erw.K), imgs[1]) = 0 * One(erw.K) then
                B := Basis(erw.K,ListElmPower([0..Size(imgs[1])-1],imgs[1]));;
                p := Permutation( (), erw.roots,
                                  function( x, g )
                                      return LinearCombination( B,
     Coefficients( EquationOrderBasis( erw.K, PrimitiveElement(erw.K) ), x ));
                                  end );
                Add( ggelm, p );
            else
                imgs := imgs{[ 2..Length(imgs) ]};
            fi;
        until Order(Group(ggelm)) = DegreeOverPrimeField(erw.K);           
    fi;

    return Group( Difference( ggelm, [ () ] ));
end );


#############################################################################
##
#F  RR_FindGaloisGroup( <erw>, <poly>, <galgrp> )
##
##  This function searchs the Galois group of the rational polynomial
##  <poly> that is compatible to the numbering of the roots of <poly>
##  in <erw>; it is recommended to use RR_ConstructGaloisGroup if there
##  exist many groups conjugated to <galgrp> 
## 
InstallGlobalFunction( RR_FindGaloisGroup, function( erw, poly, galgrp )
    local G, H, perm, k, gens, newgens, Sn;

    k := 1;
    gens := [ ];
    Sn := SymmetricGroup( Degree(poly) );
    for G in ConjugacyClassSubgroups( Sn, galgrp ) do
        newgens := Filtered( GeneratorsOfGroup( G ),
                             gen -> RR_IsInGalGrp( erw, gen ) );
        gens := DuplicateFreeList( Concatenation( gens, newgens ) );
        H := Subgroup( Sn, gens );
        if Order(galgrp) = Order( H ) then
            return H;
        fi;
    od;
end );


#############################################################################
##
#E

