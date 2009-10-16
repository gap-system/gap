#############################################################################
####
##
#W  Strings.gi                RADIROOT package                Andreas Distler
##
##  Installation file for the functions that generate Tex-strings
##
#H  $Id: Strings.gi,v 1.3 2008/01/22 11:57:43 gap Exp $
##
#Y  2006
##


#############################################################################
##
#F  RR_Radikalbasis( <erw>, <elements>, <stream> ) 
##
##  Produces a basis for the matrixfield in the record <erw> from the
##  generating matrices <elements> and returns a Tex-readable strings
##  for the basis as well 
##
InstallGlobalFunction( RR_Radikalbasis, function( erw, elements, stream )
    local k, basis, elm, mat, i, ll, basstr, elmstr, m;

    k := DegreeOverPrimeField(erw.K) / Product(erw.degs);
    basis := Basis(erw.K){[ 1..k ]};
    if k =1 then
        basstr := [""];
    else
        basstr := ["",Concatenation("\\zeta_{",String(Order(erw.unity)),"}")];
    fi;
    for i in [ 3..k ] do
        Add( basstr, Concatenation("\\zeta_{", String(Order(erw.unity)),
                                   "}^{", String(i),"}"));
    od;
    AppendTo( stream,"\\\\\n");

    for m in [ 1..Length(elements) ] do
        mat := List( basis, Flat );;
        elm := elements[m][1];
        k := elements[m][2]; 
        elmstr := RR_WurzelAlsString( k,SolutionMat(mat, Flat(elm^k)), 
                                      basstr );
        AppendTo( stream, "$\\omega_", String(m)," = ", elmstr, "$,\\\\\n");
        basis := Concatenation( List( [1..k], i -> elm^(i-1) * basis));;
        ll := [ basstr, List( basstr, str -> 
                              Concatenation( str,"\\omega_",String(m) ) ) ];
        for i in [ 3..k ] do
            ll[i] := List( basstr, str -> Concatenation( str,
                Concatenation( "\\omega_", String(m), "^", String(i-1) ) ) ); 
        od;
        basstr := Concatenation( ll );
    od;
    AppendTo( stream, "\\\\\n");    

    return [ basis, basstr ];
end );


#############################################################################
##
#F  RR_BruchAlsString( <bruch> ) 
##
##  Creates a Tex-readable String for the rational <bruch>
##
InstallGlobalFunction( RR_BruchAlsString, function( bruch )
    local str, num, den, sgn;

    if IsInt( bruch ) then
        str := String( AbsInt( bruch ) );
    else
        num := String( AbsInt( NumeratorRat( bruch ) ) );
        den := String( DenominatorRat( bruch ) );
        str := Concatenation("\\frac{", num, "}{", den, "}" );
    fi;
    if IsNegRat( bruch ) then str := Concatenation( " - ", str ); fi;

    return str;
end );


#############################################################################
##
#F  RR_KoeffizientAlsString( <coeff>, <anf> ) 
##
##  Creates a Tex-readable String for the cyclotomic <coeff>; if <anf>
##  is true, positive signs of rationals will be omitted; if <coeff> is a
##  sum, it will be included in brackets; finitely an empty string
##  will be returned, if <coeff> is equal to 1
##
InstallGlobalFunction( RR_KoeffizientAlsString, function( coeff, anf )
    local cstr;

    if coeff = 1 then
        cstr := "";
    elif coeff = -1 then
        cstr := "-";
    else
        cstr := RR_ZahlAlsString( coeff );
        if not IsRat( coeff ) then
            cstr := Concatenation( "\\left(",cstr,"\\right)" );
        fi;
    fi;
    if not anf then
        if IsPosRat( coeff ) then
            cstr := Concatenation( " + ", cstr );
        elif not IsRat( coeff ) then
            cstr := Concatenation( " + ", cstr );
        fi;
    fi;
    
    return cstr;
end );


#############################################################################
##
#F  RR_WurzelAlsString( <k>, <coeffs>, <basstr> ) 
##
##  Creates a Tex-readable String for the <k>-th root of the element
##  described by <coeffs> and <basstr>
##
InstallGlobalFunction( RR_WurzelAlsString, function( k, coeffs, basstr )
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
                                  RR_KoeffizientAlsString( coeffs[i], anf ),
                                  basstr[i]);
            anf := false;
        fi;
    od;
    if k <> 1 then
        str := Concatenation( "\\sqrt[", String(k), "]{", str, "}" );
    fi;

    return str;
end );


#############################################################################
##
#F  RR_ZahlAlsString( <zahl> ) 
##
##  Creates a Tex-readable String for the cyclotomic <zahl>
##
InstallGlobalFunction( RR_ZahlAlsString, function( zahl )
    local bas, basstr, cond, i;

    if IsRat( zahl ) then

        return RR_BruchAlsString( zahl );
    else
        cond := Conductor( zahl );
        bas := Basis( CF( cond ) );
        basstr := [ Concatenation( "\\zeta_{", String(cond), "}" ) ];
        for i in Filtered( [ 2..cond ], x -> Gcd( x, cond ) = 1 ) do
            Add( basstr,
                 Concatenation("\\zeta_{",String(cond),"}^{", String(i), "}"));
        od;

        return RR_WurzelAlsString( 1, Coefficients( bas, zahl ), basstr ); 
    fi;    
end );


#############################################################################
##
#F  RR_PolyAlsString( <poly> ) 
##
##  Creates a Tex-readable String for the polynomial <poly>
##
InstallGlobalFunction( RR_PolyAlsString, function( poly )
    local coeffs, polybasis, i;

    coeffs := CoefficientsOfUnivariatePolynomial( poly );
    polybasis := [ "", "x" ];
    for i in [ 3..Length(coeffs) ] do
        polybasis[i] := Concatenation( "x^{", String(i-1), "}" );
    od;

    return RR_WurzelAlsString( 1, Reversed(coeffs), Reversed(polybasis) );
end );


#############################################################################
##
#F  RR_TexFile( <f>, <erw>, <elements>, <dir>, <file> ) 
##
##  Creates a Tex-file for a radical expression of the roots of the
## polynomial <f>.
##
InstallGlobalFunction( RR_TexFile, function( poly, erw, elements, dir, file )
    local i,cstr,bas,root,coeffs,B,k,offset,str,min,stream;

    # Create tex-Code and write to file, using stream because of linebreaks
    Info( InfoRadiroot, 2, "    creating tex-file." );
    file := Filename( dir, file );
    stream := OutputTextFile( file, false );
    SetPrintFormattingStatus( stream, false );
    AppendTo(stream, "\\documentclass[fleqn]{article} \n",
                     "\\setlength{\\paperwidth}{84cm} \n",
                     "\\setlength{\\textwidth}{80cm} \n",
                     "\\setlength{\\paperheight}{59.5cm} \n",
                     "\\setlength{\\textheight}{57cm} \n", 
                     "\\begin{document} \n",
                     "\\noindent\n",
                     "An expression by radicals for the roots of the polynomial $",
                      RR_PolyAlsString( poly ),
                      "$ with the $n$-th root of unity $\\zeta_n$ and\n");
    bas := RR_Radikalbasis( erw, elements, stream );;
    AppendTo( stream, "is:\n\\\\\n\\noindent\n$" );
    offset := CoefficientsOfUnivariatePolynomial(poly)[Degree(poly)] / 
              (Degree(poly) * LeadingCoefficient(poly));
    k := Degree(poly) / Length(erw.roots);
    if k <> 1 and offset <> 0 then
        AppendTo( stream, RR_ZahlAlsString(-offset), "+");
    fi;
    B := Basis( erw.K, bas[1] );
    coeffs := List([1..Length(erw.roots)], i->Coefficients(B, erw.roots[i]));
    str := List([ 1..Length(erw.roots) ], 
                i -> RR_WurzelAlsString(k, coeffs[i], bas[2]));
    min := First( [ 1..Length(erw.roots) ],
                   i -> Length(str[i]) = Minimum( List( str, Length )));
    if Length( str[min] ) = 0 then
        AppendTo( stream, "0" );
    elif Length( str[min] ) < 1400 then
        AppendTo( stream, str[min] );
    else
        AppendTo( stream, RR_NstInDatei( k, coeffs[min], bas[2] ));
    fi;
    AppendTo(stream, "$\n\\end{document}\n");
#             "$\n\\\\$",String(Length(str[min])),
    CloseStream( stream );

    return file;
end );


#############################################################################
##
#F  RR_Display( <file>, <dir> ) 
##
##  Displays the latex-file <file> from the directory <dir>
##
InstallGlobalFunction( RR_Display, function( file, dir )
    local dvi, latex;

    # Execute latex and open the created document
    latex := Filename( DirectoriesSystemPrograms( ), "latex" );
    Process( dir, latex, InputTextNone( ), OutputTextNone( ), 
             [ Concatenation( file, ".tex" ) ] );
    dvi := Filename( DirectoriesSystemPrograms( ), "xdvi" );
    Process( dir, dvi, InputTextNone( ), OutputTextNone( ), 
             ["-paper","a1r",Concatenation( file, ".dvi" ) ] );

end );


#############################################################################
##
#F  RR_NstInDatei( <k>, <coeffs>, <basstr> ) 
##
##  Creates a Tex-output containing a string for the <k>-th root of the
##  element described by <coeffs> and <basstr> 
##
InstallGlobalFunction( RR_NstInDatei, function( k, coeffs, basstr )
    local str, i, anf;

    str := "";
    if k <> 1 then
        str := Concatenation( str, "(" );
    fi;
    anf := true;
    repeat
        i := 0;
        while Length( coeffs ) >= i+1 and
              Length(RR_WurzelAlsString(1,coeffs{[1..i+1]},basstr{[1..i+1]})) 
              < 1400 do
            i := i+1;
        od;
        if not anf then 
            str := Concatenation(str, "$\\\\\n$+" ); 
        fi;
        anf := false;
        str := Concatenation(str, RR_WurzelAlsString(1, coeffs{[1..i]}, 
                                                        basstr{[1..i]}));
        coeffs := coeffs{[i+1..Length(coeffs)]};
        basstr := basstr{[i+1..Length(basstr)]};
    until coeffs = [ ];  
    if k <> 1 then
        str := Concatenation( str, ")^{\\frac{1}{",String(k),"}}");
    fi;

    return str;
end );


#############################################################################
##
#E


