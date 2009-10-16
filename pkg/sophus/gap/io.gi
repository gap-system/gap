#############################################################################
##
#W  io.gi                   Sophus package                   Csaba Schneider 
##
#W The functions in this file implement the input-output methods of the Sophus
#W package.
##
#H  $Id: io.gi,v 1.8 2005/08/09 17:06:07 gap Exp $




#############################################################################
##
#F WriteLieAlgebraToFile( <L>, <name>, <file> ) 
##
##  Write the structure constants table of <L> to <file> under <name>.

WriteLieAlgebraToFile := function( L, name, file )
    
    AppendTo( file,  name, " := ", StructureConstantsTable( Basis( L )), ";\n");
 
end;



#############################################################################
##
#F WriteLieAlgebraToString( <L> ) 
##
##  Encodes <L> into a string.

WriteNilpotentLieAlgebraToString := function( L )
    local b, x, y, dim, coeffs, p, sum, i, base, d, string, q, r, digits;
    
    b := Basis( L );
    dim := Dimension( L );
    coeffs := [];
    for x in [1..dim] do
        for y in [x+1..dim] do
            Append( coeffs, Coefficients( 
                    Basis( Subspace( L, b{[y+1..dim]} )), b[y]*b[x] ));
            #Print( y, " ", x, " :", b[y]*b[x], "\n" );
        od;
    od;
    
    coeffs := List( coeffs, IntFFE );
    
    #Print( "Coeff list is: ", coeffs, "\n" );
    
    sum := 0;
    p := Characteristic( LeftActingDomain( L ));
    for i in [1..Length( coeffs )] do
        sum := sum + coeffs[i]*p^(i-1);
    od;
    
    #Print( "number is ", sum, "\n" );
    
    digits := ['0','1','2','3','4','5','6','7','8','9',
               'a','b','c','d','e','f','g','h','i','j',
               'k','l','m','n','o','p','q','r','s','t',
               'u','v','w','x','y','z','A','B','C','D',
               'E','F','G','H','I','J','K','L','M','N',
               'O','P','Q','R','S','T','U','V','W','X',
               'Y','Z'];
    
    base := 62;
    d := 1;
    while d*62 < sum do
      d := d*62;
    od;
    
    string := "";
    
    repeat
        q := QuoInt( sum, d );
        r := sum - q*d;
        Add( string, digits[q+1] );
        sum := sum - q*d;
        d := d/62;
    until d = 1/62;
    
    
            
    return string;
end;



#############################################################################
##
#F ReadStringToNilpotentLieAlgebra( <string>, <p>, <dim> ) 
##
##  Converts <string> to a <dim>-dimensional nilpotent Lie algebra over the
##  field of <p> elements.

ReadStringToNilpotentLieAlgebra := function( string, p, dim )
    local digits, d, sum, i, coeffs, no_coeffs, T, pos, a, b, scentry, r, q, L;
    
    digits := ['0','1','2','3','4','5','6','7','8','9',
               'a','b','c','d','e','f','g','h','i','j',
               'k','l','m','n','o','p','q','r','s','t',
               'u','v','w','x','y','z','A','B','C','D',
               'E','F','G','H','I','J','K','L','M','N',
               'O','P','Q','R','S','T','U','V','W','X',
               'Y','Z'];
    
    d := 62^(Length( string ) - 1 );
    sum := 0;
    for i in string do
        sum := sum + (Position( digits, i )-1)*d;
        d := d/62;
    od;
    
    #Print( "number is ", sum, "\n" );
    
    d := 1;
    while d*p <= sum do
      d := d*p;
    od;
    
    coeffs := [];
    
    repeat
        q := QuoInt( sum, d );
        r := sum - q*d;
        Add( coeffs, q );
        sum := sum - q*d;
        d := d/p;
    until d = 1/p;
    
    no_coeffs := Sum( Combinations( [1..dim], 2 ), x->(dim-x[2]));
    coeffs := Concatenation( List( [1..no_coeffs-Length( coeffs )], 
                      x->0 ), coeffs );
    
    #Print( "Coeff list is: ", coeffs, "\n" );
    
    T := EmptySCTable( dim, Zero( GF( p )), "antisymmetric" );
    
    pos := 1;
    
    for a in Reversed([1..dim-1]) do
        for b in Reversed([a+1..dim]) do
            scentry := [];
            for i in Reversed( [b+1..dim] ) do
                Append( scentry, [One(GF(p))*coeffs[pos], i] );
                pos := pos + 1;
            od;
            SetEntrySCTable( T, b, a, scentry );
            #Print( b, " ", a, ": ", scentry, "\n" );
        od;
    od;
    
    L := LieAlgebraByStructureConstants( GF(p), T );
    Setter( IsLieNilpotentOverFp )( L, true );
    return L;
end;



#############################################################################
##
#F WriteLieAlgebraListToFile( <list>, <name>, <file> ) 
##
##  Converts each Lie algebra in <list> into a string, and write the list 
##  of strings into <file> under <name>.


WriteLieAlgebraListToFile := function( list, name, file )
    
    local i;

    if list = [] then
       PrintTo( file, name, " := [];" );
       return;
    fi;
    
    PrintTo( file, name,  " := [ " );
    
    for i in [1..Length( list )-1] do 
        AppendTo( file, "\"", WriteNilpotentLieAlgebraToString( list[i] ), "\", " );
    od;
    
    	AppendTo( file, "\"", 
                  WriteNilpotentLieAlgebraToString( list[Length( list )] ), 
                  "\" ];" );
end;

      
#############################################################################
##
#F WriteDescendantsToFile( <l>, <step>, <name>, <filename> ) 
##
##  Converts the <step>-step descendants of <l> into strings, and writes 
##  the list of strings into <filename> under <name>.


WriteDescendantsToFile := function( l, step, name, filename )
    local i, d;
    
    
    PrintTo( filename, name, ":= [ " );
    Print( " mult has dim ", Dimension( LieMultiplicator( LieCover( l ))), "\n" );
    d := Descendants( l, step );
        if d <> [] then
            for l in d{[1..Length( d ) - 1]} do
                AppendTo( filename, "\"", WriteNilpotentLieAlgebraToString( l ), "\", " ); 
             od;
             AppendTo( filename, "\"", WriteNilpotentLieAlgebraToString( d[Length( d )] ), "\" ];" );
            else
                AppendTo( filename, " ];" );
            fi;
        end;
        
        

#############################################################################
##
#F  SophusBuildManual()
##

SophusBuildManual:=function()
	local sophus_path, sophus_main, sophus_files, sophus_bookname;

	sophus_path:=Concatenation(
               GAPInfo.PackagesInfo.("sophus")[1].InstallationPath,"/Doc/");

	sophus_main:="manual.xml";
	sophus_files:=["intro.xml", "functions.xml"];
	sophus_bookname:="Sophus";

	MakeGAPDocDoc(sophus_path, sophus_main, sophus_files, 
		sophus_bookname);  
end;



#############################################################################
##
#F  SophusBuildManualHTML()
##

SophusBuildManualHTML:=function()
	local sophus_path, sophus_main, sophus_files, str, r, h;

	sophus_path:=Concatenation(
               GAPInfo.PackagesInfo.("sophus")[1].InstallationPath,"/Doc/");

	sophus_main:="manual.xml";
	sophus_files:=["intro.xml", "functions.xml"];
	str:=ComposedXMLString(sophus_path, sophus_main, sophus_files);

	r := ParseTreeXMLString( str );
	CheckAndCleanGapDocTree( r );

	h := GAPDoc2HTML( r, sophus_path );
	GAPDoc2HTMLPrintHTMLFiles( h, sophus_path );
end;

        
        
