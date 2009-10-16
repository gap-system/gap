#############################################################################
####
##
#W  Maple.gi                RADIROOT package                Andreas Distler
##
##  Installation file for the functions that generate Maple expressions
##
#H  $Id: Maple.gi,v 1.2 2006/10/30 13:51:30 gap Exp $
##
#Y  2006
##


#############################################################################
##
#F  RR_M_Radikalbasis( <erw>, <elements>, <file> ) 
##
##  Produces a basis for the matrixfield in the record <erw> from the
##  generating matrices <elements> and returns Maple-readable strings
##  for the basis as well 
##
InstallGlobalFunction( RR_M_Radikalbasis, function( erw, elements, file )
    local k, basis, elm, mat, i, ll, basstr, elmstr, m;

    k := DegreeOverPrimeField(erw.K) / Product(erw.degs);
    basis := Basis(erw.K){[ 1..k ]};
    if k = 1 then
        basstr := [""];
    else
        basstr := ["",Concatenation("E(",String(Order(erw.unity)),")")];
    fi;
    for i in [ 3..k ] do
        Add( basstr, Concatenation( basstr[2], "^", String(i) ) );
    od;

    for m in [ 1..Length(elements) ] do
        mat := List( basis, Flat );;
        elm := elements[m][1];
        k := elements[m][2];
        elmstr := RR_M_WurzelAlsString( k,SolutionMat(mat, Flat(elm^k)), 
                                      basstr );
        AppendTo( file, "w", String(m)," := ", elmstr, ";\n");
        basis := Concatenation( List( [1..k], i -> elm^(i-1) * basis));;
        ll := [ basstr, List( basstr, str -> 
                              Concatenation( str,"*w",String(m) ) ) ];
        for i in [ 3..k ] do
            ll[i] := List( basstr, str -> Concatenation( str,
                Concatenation( "*w", String(m), "^", String(i-1) ) ) ); 
        od;
        basstr := Concatenation( ll );
    od;
    AppendTo( file, "\n");    

    return [ basis, basstr ];
end );


#############################################################################
##
#F  RR_M_KoeffizientAlsString( <coeff>, <anf> ) 
##
##  Creates a Maple-readable String for the cyclotomic <coeff>; if <anf>
##  is true, positive signs of rationals will be omitted; if <coeff> is a
##  sum, it will be included in brackets; finitely an empty string
##  will be returned, if <coeff> is equal to 1
##
InstallGlobalFunction( RR_M_KoeffizientAlsString, function( coeff, anf )
    local cstr;

    cstr := String( coeff );
    if not IsInt( coeff ) then
        cstr := Concatenation( "(",cstr,")" );
    fi;

    if not anf then
        if IsPosInt( coeff ) then
            cstr := Concatenation( " + ", cstr );
        elif not IsInt( coeff ) then
            cstr := Concatenation( " + ", cstr );
        fi;
    fi;
    
    return cstr;
end );


#############################################################################
##
#F  RR_M_WurzelAlsString( <k>, <coeffs>, <basstr> ) 
##
##  Creates a Maple-readable String for the <k>-th root of the element
##  described by <coeffs> and <basstr>
##
InstallGlobalFunction( RR_M_WurzelAlsString, function( k, coeffs, basstr )
    local i, str, anf;

    str := ""; anf := true;
    for i in [ 1..Length(coeffs) ] do
        if coeffs[i] in [ -1, 1 ] and basstr[i] = "" then
            if not anf and coeffs[i] = 1 then
                str := Concatenation( str, " + ", String( coeffs[i] ) );
            else
               str := Concatenation( str, String( coeffs[i] ) );
            fi;
            anf := false;
        elif coeffs[i] <> 0 then
            str := Concatenation( str,
                                  RR_M_KoeffizientAlsString( coeffs[i], anf ),
                                  basstr[i]);
            anf := false;
        fi;
    od;
    if k <> 1 then
        str := Concatenation( "(", str, ")^(1/", String(k),")" );
    fi;

    return str;
end );


#############################################################################
##
#F  RR_MapleFile( <f>, <erw>, <elements>, <file> ) 
##
##  Creates a file for a radical expression of the roots of the polynomial
##  <f> which can be read into Maple.
##
InstallGlobalFunction( RR_MapleFile, function( poly, erw, elements, file )
    local i,cstr,bas,root,coeffs,B,k,offset,str,min;

    Info( InfoRadiroot, 2, "    creating maple file" );
    # Create maple code and write to file
    bas := RR_M_Radikalbasis( erw, elements, file );;

    offset := CoefficientsOfUnivariatePolynomial(poly)[Degree(poly)] / 
              (Degree(poly) * LeadingCoefficient(poly));
    k := Degree(poly) / Length(erw.roots);
    AppendTo( file, "a := " );
    if k <> 1 and offset <> 0 then
        AppendTo( file, String(-offset), "+");
    fi;
    B := Basis( erw.K, bas[1] );
    coeffs := List([1..Length(erw.roots)], i->Coefficients(B, erw.roots[i]));
    str := List([ 1..Length(erw.roots) ], 
                i -> RR_M_WurzelAlsString(k, coeffs[i], bas[2]));
    min := First( [ 1..Length(erw.roots) ],
                   i -> Length(str[i]) = Minimum( List( str, Length )));
    if Length( str[min] ) < 1400 then
      AppendTo( file, str[min] );
    else
      AppendTo( file, RR_M_NstInDatei( k, coeffs[min], bas[2] ));
    fi;
    AppendTo( file, ";\n" );

    return file;
end );


#############################################################################
##
#F  RR_M_NstInDatei( <k>, <coeffs>, <basstr> ) 
##
##  Creates a Maple-output containing a string for the <k>-th root of the
##  element described by <coeffs> and <basstr> 
##
InstallGlobalFunction( RR_M_NstInDatei, function( k, coeffs, basstr )
    local str, i, anf;

    str := "";
    if k <> 1 then
        str := Concatenation( str, "(" );
    fi;
    repeat
        i := 0;
        while Length( coeffs ) >= i+1 and
              Length(RR_M_WurzelAlsString(1,coeffs{[1..i+1]},basstr{[1..i+1]})) 
              < 1400 do
            i := i+1;
        od;
        str := Concatenation(str, RR_M_WurzelAlsString(1, coeffs{[1..i]}, 
                                                        basstr{[1..i]}));
        coeffs := coeffs{[i+1..Length(coeffs)]};
        basstr := basstr{[i+1..Length(basstr)]};
    until coeffs = [ ];  
    if k <> 1 then
        str := Concatenation( str, ")^(1/",String(k),")");
    fi;

    return str;
end );


#############################################################################
##
#E


