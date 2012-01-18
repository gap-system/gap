############################################################################
##
#W  factors.gi     Alnuth - ALgebraic NUmber THeory        Andreas Distler
##


#############################################################################
##
#M  IrrFacsAlgExtPol(<f>) . . . . . lists of irreducible factors of rational 
##                  polynomial over algebraic extensions, initialize default
##
InstallOtherMethod(IrrFacsAlgExtPol,true,[IsPolynomial],0,f -> []);
                                                                               

#############################################################################
##
#F  StoreFactorsAlgExtPol( <pring>, <upol>, <factlist> ) . store factors list
##
InstallGlobalFunction(StoreFactorsAlgExtPol,function(R,f,fact)
local irf;
  irf:=IrrFacsAlgExtPol(f);
  if not ForAny(irf,i->i[1]=R) then
    Add(irf,[R,fact]);
  fi;
end);
                                                                               
#############################################################################
##
#F  FactorsPolynomialAlgExt, function( <H>, <poly> )
##
##  Factorizes the rational polynomial <poly> over the field <H>, a proper
##  algebraic extension of the rationals, using PARI/GP
##
InstallGlobalFunction( FactorsPolynomialAlgExt, function( H, poly )
    local faktoren, irf, i;

    if not ForAll( CoefficientsOfUnivariatePolynomial( poly ), IsRat ) then
        Error( "polynomial has to be defined over the Rationals" );
    fi;

    if H = Rationals then 
        return Factors( poly );
    fi;

    irf := IrrFacsAlgExtPol( poly );
    i := PositionProperty( irf, k -> k[1] = H );
    if i <> fail  then
        return irf[i][2];
    fi;

    faktoren := FactorsPolynomialPari( AlgExtEmbeddedPol( H, poly ));
    StoreFactorsAlgExtPol( H, poly, faktoren );

    return faktoren;
end );


#############################################################################
##
#F  FactorsPolynomialPari, function( <poly> )
##
##  Factorizes the polynomial <poly> defined over an algebraic extension of
##  the rationals using PARI/GP
##
##  As a method of 'Factors' ? AD
##
InstallGlobalFunction(FactorsPolynomialPari, function( poly )
    local faktoren, fak, coeff, c, lcoeff, irf, i, coeffs, H;

    H := CoefficientsRing( DefaultRing( poly ));
    irf := IrrFacsAlgExtPol( poly );

    i := PositionProperty( irf, k -> k[1] = H );
    if i <> fail  then
        return irf[i][2];
    fi;

    if DegreeOfLaurentPolynomial( poly ) < 2 then
        faktoren := [ poly ];
        StoreFactorsPol( H, poly, faktoren );
        return faktoren;
    fi;
      
    faktoren := [ ];
    lcoeff := LeadingCoefficient( poly );
    coeffs := CoefficientsOfUnivariatePolynomial( poly / lcoeff );
    coeffs := List( Reversed( coeffs ), ExtRepOfObj );
    for fak in PolynomialFactorsDescriptionPari( H, coeffs ) do
        coeff := [ ];
        for c in Reversed( fak ) do
            if ( c in Rationals ) then
                Add( coeff, c );
            else
                Add( coeff, LinearCombination( EquationOrderBasis(H), c ) );
            fi;
        od;
        Add( faktoren, UnivariatePolynomial( H, One(H)*coeff ) );
    od;
    faktoren[1] := lcoeff * faktoren[1];
    StoreFactorsPol( H, poly, faktoren );

    return faktoren;
end );
                                                                       
#############################################################################
##
#E
