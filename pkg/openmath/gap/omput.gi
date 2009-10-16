#######################################################################
##
#W  omput.gi                OpenMath Package           Andrew Solomon
#W                                                     Marco Costantini
##
#H  @(#)$Id: omput.gi,v 1.54 2009/10/14 13:13:06 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  Writes a GAP object to an output stream, as an OpenMath object
## 

Revision.("openmath/gap/omput.gi") := 
    "@(#)$Id: omput.gi,v 1.54 2009/10/14 13:13:06 alexk Exp $";



# The Gap function AppendTo (used by OMWriteLine) uses
# PrintFormattingStatus and, before Gap 4.4.7, PrintFormattingStatus was
# defined only for text streams.

if not CompareVersionNumbers( VERSION, "4.4.7" )  then
    InstallOtherMethod( PrintFormattingStatus, "for non-text output stream",
      true, [IsOutputStream], 0,
      function ( str )
        if IsOutputTextStream( str )  then
            TryNextMethod();
        fi;
        return false;
    end);
fi;


#############################################################################
#
# This function generates a random string of the length n
# It is needed in particular to create references, 
# and also used in SCSCP package to generate random call identifiers
# Creation of OpenMathRealRandomSource is placed inside the function
# to avoid its early call when IO is not fully loaded (Error happens 
# if GAP is started with "gap -r -A" and then LoadPackage("scscp");
# is entered.

BindGlobal( "RandomString",
    function( n )
    local symbols, i;
    symbols := "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";
    if IsBound( OpenMathRealRandomSource ) then 
        if IsRandomSource( OpenMathRealRandomSource ) then
            return List( [1..n], i -> Random( OpenMathRealRandomSource, symbols) );
        fi;    
    fi;
    MakeReadWriteGlobal( "OpenMathRealRandomSource" );
    UnbindGlobal( "OpenMathRealRandomSource" );
    BindGlobal( "OpenMathRealRandomSource", RandomSource( IsRealRandomSource, "urandom" ));
    return List( [1..n], i -> Random( OpenMathRealRandomSource, symbols) );
    end);
    
    
#######################################################################
##  
#F  OMWriteLine( <stream>, <list> )
##
##  Input : List of arguments to print
##  Output: \t ^ OMIndent, arguments
##

InstallGlobalFunction(OMWriteLine,
function(stream, alist)
	local i;

	# do the indentation
	AppendTo( stream, ListWithIdenticalEntries( OMIndent, '\t' ) );

	for i in alist do
		AppendTo(stream, i);
	od;
	AppendTo(stream, "\n");
end);


#######################################################################
## Basic OpenMath objects and main functionality



#######################################################################
##
#F  OMPutVar( <stream>, <name> )
##
##  Input : name as string
##  Output: <OMV name="<name>" />
##
InstallGlobalFunction(OMPutVar,
function(stream, name)
  OMWriteLine(stream, ["<OMV name=\"", name, "\"/>"]);
end);



#######################################################################
##
#F  OMPutSymbol( <stream>, <cd>, <name> )
##
##  Input : cd, name as strings
##  Output: <OMS cd="<cd>" name="<name>" />
##
InstallGlobalFunction(OMPutSymbol,
function(stream, cd, name)
    OMWriteLine(stream, ["<OMS cd=\"", cd, "\" name=\"", name, "\"/>"]);
end);



#######################################################################
##
#M  OMPutApplication( <stream>, <cd>, <name>, <list> )
##
##  Input : cd, name as strings, list as a list
##  Output:
##        <OMA>
##                <OMS cd=<cd> name=<name>/>
##                OMPut(<stream>, <list>[1])
##                OMPut(<stream>, <list>[2])
##                ...
##        </OMA>
##


InstallGlobalFunction(OMPutApplication,
function ( stream, cd, name, list )
    local  obj;
    OMWriteLine( stream, [ "<OMA>" ] );
    OMIndent := OMIndent + 1;
    OMPutSymbol( stream, cd, name );
    for obj  in list  do
        OMPut( stream, obj );
    od;
    OMIndent := OMIndent - 1;
    OMWriteLine( stream, [ "</OMA>" ] );
end);




#######################################################################
##
#F  OMPutObject( <stream>, <obj> ) 
##
##
InstallGlobalFunction(OMPutObject,
function(stream, x)

	if IsClosedStream( stream )  then
		Error( "closed stream" );
	fi;

	if IsOutputTextStream( stream )  then
		SetPrintFormattingStatus( stream, false );
	fi;

	OMIndent := 0;
	OMWriteLine(stream, ["<OMOBJ>"]);
	OMIndent:= OMIndent+1;
	OMPut(stream, x);
	OMIndent:=OMIndent-1;
	OMWriteLine(stream, ["</OMOBJ>"]);
end);


#######################################################################
##
#F  OMPutObjectNoOMOBJtags( <stream>, <obj> ) 
##
##
InstallGlobalFunction(OMPutObjectNoOMOBJtags,
function(stream, x)

	if IsClosedStream( stream )  then
		Error( "closed stream" );
	fi;

	if IsOutputTextStream( stream )  then
		SetPrintFormattingStatus( stream, false );
	fi;

	OMIndent := 0;
	# OMIndent:= OMIndent+1;
	OMPut(stream, x);
	# OMIndent:=OMIndent-1;
end);


#############################################################################
#
# OMPutReference( stream, x );
#
# This method prints OpenMath references and can be used for printing complex 
# objects, for example, ideals of polynomial rings (the ideal will carry the
# ring R, and each polynomial generating the ideal will also refer to the 
# ring R). The method uses OMR, if the object x already has the attribute 
# OMReference, and prints the object x otherwise. 
#
# The concept of references implies that the author of the code is able to
# decide which objects needs references, and assign references to them, e.g.
# using
# SetOMReference( r, Concatenation("polyring", RandomString(16)));
#
# Once an object obtained a reference, it can not be changed, therefore, the
# same reference will be used in communication with all other CASs. 
#
# However, the reference will be not printed automatically for an object
# having it - otherwise, you will not be able to send the same object to
# multiple CASs. Instead of this, the reference will be printed only when
# this will be enforced by the usage of OMPutReference.
#
# If the SuppressOpenMathReferences is set to true, then 
# OMPutReference (lib/openmath.gi) will put the actual 
# OpenMath code for an object whenever it has id or not.
#
InstallMethod( OMPutReference, 
"for a stream and an object with reference",
true,
[ IsOutputStream, IsObject ],
0,
function( stream, x )
if HasOMReference( x ) and not SuppressOpenMathReferences then
   OMWriteLine( stream, [ "<OMR href=\"\043", OMReference( x ), "\" />" ] );
else   
   OMPut( stream, x );
fi;
end);


#############################################################################
##
#F  OMPrint( <obj> ) .......................   Print <obj> as OpenMath object
##
##
InstallGlobalFunction( OMPrint,
function( arg )
	local str, outstream;
	str := "";
	outstream := OutputTextString(str, true);
	if Length( arg ) = 1 then
		OMPutObject(outstream, arg[1] );
	elif Length( arg ) = 2 then
		OMPutObject(outstream, arg[1], arg[2] );
	else
		Error("OpenMath : OMPrint accepts only 1 or 2 arguments!!!\n");
	fi;
	CloseStream(outstream);
	Print(str);
end);


#############################################################################
## 
## OMString( <obj> ) ............ Return string with <obj> as OpenMath object
##
InstallGlobalFunction( OMString,
function ( x )
local noomobj, str, outstream;
if ValueOption("noomobj") <> fail then
    noomobj := true;
else
    noomobj := false;
fi;
str := "";
outstream := OutputTextString( str, true );
if noomobj then
    OMPutObjectNoOMOBJtags( outstream, x );
else
    OMPutObject( outstream, x );
fi;
CloseStream( outstream );
NormalizeWhitespace( str );
return str;
end);


#############################################################################
## Various methods for OMPut


BindGlobal( "OMINT_LIMIT", 2^15936 );

#######################################################################
##
#M  OMPut( <stream>, <int> )  
##
##  Printing for integers: specified in the standard
## 
InstallMethod(OMPut, "for an integer", true,
[IsOutputStream, IsInt],0,
function(stream, x)
    if x >= OMINT_LIMIT then
  		OMWriteLine(stream, ["<OMI>", String(x), "</OMI>"]);
	else
  		OMWriteLine(stream, ["<OMI>", x, "</OMI>"]);
	fi;
end);


#######################################################################
##
#M  OMPut( <stream>, <string> )  
##
##  specified in the standard
## 
InstallMethod(OMPut, "for a string", true,
[IsOutputStream, IsString],0,
function(stream, x)
	if IsEmpty(x) and not IsEmptyString(x) then
		TryNextMethod();
	fi;

  # convert XML escaped chars
  x := ReplacedString( x, "&", "&amp;" );
  x := ReplacedString( x, "<", "&lt;" );

	OMWriteLine(stream, ["<OMSTR>",x,"</OMSTR>"]);
end);


#######################################################################
##
#M  OMPut( <stream>, <float> )
##
##  Printing for floats: specified in the standard
##
if IsBound( IsFloat )  then
InstallMethod(OMPut, "for a float", true,
[IsOutputStream, IsFloat],0,
function(stream, x)
    local  string;
    # treatment of x=0 separately was added when discovered
    # that Float("-0") returns -0, but it is also faster.
    if IsZero(x) then
    	OMWriteLine( stream, [ "<OMF dec=\"0\"/>" ] );
    else
    	string := String( x );
    	# the OpenMath standard requires floats encoded in this way, see
    	# section 3.1.2
    	string := ReplacedString( string, "e+", "e" );
    	string := ReplacedString( string, "inf", "INF" );
    	string := ReplacedString( string, "nan", "NaN" );
    	OMWriteLine( stream, [ "<OMF dec=\"", string, "\"/>" ] );
	fi;
end);
fi;


#######################################################################
##
#M  OMPut( <stream>, <float> )
##
##  Printing for floats: specified in the standard
##
if IsBound( IS_MACFLOAT )  then
InstallMethod(OMPut, "for a float", true,
[IsOutputStream, IS_MACFLOAT],0,
function(stream, x)
    local  string;
    # treatment of x=0 separately was added when discovered
    # that Float("-0") returns -0, but it is also faster.
    if IsZero(x) then
    	OMWriteLine( stream, [ "<OMF dec=\"0\"/>" ] );
    else
    	string := String( x );
    	# the OpenMath standard requires floats encoded in this way, see
    	# section 3.1.2
    	string := ReplacedString( string, "e+", "e" );
    	string := ReplacedString( string, "inf", "INF" );
    	string := ReplacedString( string, "nan", "NaN" );
    	OMWriteLine( stream, [ "<OMF dec=\"", string, "\"/>" ] );
	fi;
end);
fi;


#######################################################################
##
#M  OMPut( <stream>, <bool> )  
##
##  Printing for booleans: specified in CD nums # now logic1
## 
InstallMethod(OMPut, "for a boolean", true,
[IsOutputStream, IsBool],0,
function(stream, x)
    if not x in [ true, false]  then
        TryNextMethod();
    fi;
    OMPutSymbol( stream, "logic1", x );
end);


#######################################################################
##
#M  OMPut( <stream>, <rat> )  
##
##  Printing for rationals
## 
InstallMethod(OMPut, "for a rational", true,
[IsOutputStream, IsRat],0,
function(stream, x)
	OMPutApplication( stream, "nums1", "rational",
		[ NumeratorRat(x), DenominatorRat(x)] );
end);


#######################################################################
##
#M  OMPut( <stream>, <resclass> )  
##
##  Printing for rationals
## 
InstallMethod(OMPut, "for a residue class", true,
[IsOutputStream, IsZmodnZObj],0,
function(stream, x)
	OMPutApplication( stream, "integer2", "class",
		[  x![1], FamilyObj(x)!.modulus ] );
end);


#######################################################################
##
#M  OMPut( <stream>, <cyc> )  
##
##  Printing for cyclotomics
## 
InstallMethod(OMPut, "for a proper cyclotomic", true,
[IsOutputStream, IsCyc],0,
function(stream, x)
	local
                real,
                imaginary,

		n, # Length(powlist)
		i,
		clist; # x = Sum_i clist[i]*E(n)^(i-1)

    if IsGaussRat( x )  then

        real := x -> (x + ComplexConjugate( x )) / 2;
        imaginary := x -> (x - ComplexConjugate( x )) * -1 / 2 * E( 4 );

        OMPutApplication( stream, "complex1", "complex_cartesian", 
            [ real(x), imaginary(x)] );

    else

	n := Conductor(x);
	clist := CoeffsCyc(x, n);

	OMWriteLine(stream, ["<OMA>"]);
	OMIndent := OMIndent+1;
	OMPutSymbol( stream, "arith1", "plus" );
	for i in [1 .. n] do
		if clist[i] <> 0 then

			OMWriteLine(stream, ["<OMA>"]); # times
			OMIndent := OMIndent+1;
			OMPutSymbol( stream, "arith1", "times" );
			OMPut(stream, clist[i]);

			OMPutApplication( stream, "algnums", "NthRootOfUnity", [ n, i-1 ] );

			OMIndent := OMIndent-1;
			OMWriteLine(stream, ["</OMA>"]); #times
		fi;
	od;
	OMIndent := OMIndent-1;
	OMWriteLine(stream, ["</OMA>"]);

    fi;
end);



#######################################################################
##
#M  OMPut( <stream>, <infinity> )
##
##  Printing for infinity: specified in nums1.ocd
##

InstallMethod(OMPut, "for infinity", true,
[IsOutputStream, IsInfinity],0,
function(stream, x)
        OMPutSymbol( stream, "nums1", x );
end);




#######################################################################
##
#M  OMPut( <stream>,  <vector> )  
##
##  Printing for vectors: specified in linalg2.ocd
##
#InstallMethod(OMPut, "for a row vector", true,
#[IsOutputStream, IsRowVector],0,
#function(stream, x)
#
#  OMPutApplication( stream, "linalg2", "vector", x );
#
#end);



#######################################################################
##
#M  OMPut( <stream>, <matrix> )  
##
##  Printing for matrices: specified in linalg2.ocd
##
InstallMethod(OMPut, "for a matrix", true,
[IsOutputStream, IsMatrix],0,
function(stream, x)
    local  r;

    OMWriteLine( stream, [ "<OMA>" ] );
    OMIndent := OMIndent + 1;

    OMPutSymbol( stream, "linalg2", "matrix" );
    for r  in x  do

        OMPutApplication( stream, "linalg2", "matrixrow", r );

    od;

    OMIndent := OMIndent - 1;
    OMWriteLine( stream, [ "</OMA>" ] );

end);



#######################################################################
##
#M  OMPut( <stream>, NonnegativeIntegers )
##
##  Printing for the set N
##
InstallMethod(OMPut, "for NonnegativeIntegers", true,
[IsOutputStream, IsNonnegativeIntegers],0,
function(stream, x)
        OMPutSymbol( stream, "setname1", "N" );
end);



#######################################################################
##
#M  OMPut( <stream>, Integers )
##
##  Printing for the set Z
##
InstallMethod(OMPut, "for Integers", true,
[IsOutputStream, IsIntegers],0,
function(stream, x)
        OMPutSymbol( stream, "setname1", "Z" );
end);


#######################################################################
##
#M  OMPut( <stream>, Rationals )
##
##  Printing for the set Q
##
InstallMethod(OMPut, "for Rationals", true,
[IsOutputStream, IsRationals],0,
function(stream, x)
        OMPutSymbol( stream, "setname1", "Q" );
end);




#######################################################################
##
#M  OMPut( <stream>, <list> )  
##
##  Printing for finite lists or collection. Prints them as lists.
##
## 

InstallMethod(OMPut, "for a finite list or collection", true,
[IsOutputStream, IsListOrCollection and IsFinite], 0,
function(stream, x)

  OMPutApplication( stream, "list1", "list", x );

end);


#######################################################################
##
#M  OMPut( <stream>, <set> )  
##
##  Printing for finite set: specified in set1.ocd
##
InstallMethod(OMPut, "for a finite set", true,
[IsOutputStream, IsDuplicateFreeList and IsFinite],0,
function(stream, x)

  if IsString(x) and Length(x)>0 or IsEmptyString(x)  then 
  # this doesn't include the empty list
    TryNextMethod();
  fi;

  if IsEmpty(x) then
    OMPutSymbol( stream, "set1", "emptyset" );
  else
    OMPutApplication( stream, "set1", "set", x );
  fi;

end);




#######################################################################
##
#M  OMPut( <stream>, <range> )
##
##  Printing for ranges: specified in interval1.ocd
##

InstallMethod(OMPut, "for a range", true,
[IsOutputStream, IsRange and IsRangeRep],0,
function ( stream, x )

    if not x[2] - x[1] = 1  then
        TryNextMethod();
    fi;

    OMPutApplication( stream, "interval1", "integer_interval",
        [ x[1], x[Length( x )] ] );

end);


#######################################################################
##
#M  OMPut( <stream>, <group> )  
##
##  Printing permutation group as specified in permgp1.group symbol
## 
InstallMethod(OMPut, "for a permutation group", true,
[IsOutputStream, IsPermGroup],0,
function(stream, x)
	local g;
    OMWriteLine(stream, ["<OMA>"]);
    OMIndent := OMIndent +1;
    OMPutSymbol( stream, "permgp1", "group" );
    OMPutSymbol( stream, "permutation1", "right_compose" );
	for g in GeneratorsOfGroup(x) do
		OMPut( stream, g );
	od;
    OMIndent := OMIndent -1;
    OMWriteLine(stream, ["</OMA>"]);
end); 

if LoadPackage("monoid") <> fail then

#######################################################################
##
#M  OMPut( <stream>, <semigrouphom> )  
##
## 
InstallMethod(OMPut, "for a semigroup homomorphism given by images of generators", true,
[IsOutputStream, IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesOfGensRep],0,
function(stream, x)
    local g;
    OMWriteLine(stream, ["<OMA>"]);
	OMIndent := OMIndent+1;
	OMPutSymbol( stream, "semigroup4", "homomorphism_by_generators" );
	OMPut(stream, Source(x) );
	OMPut(stream, Range(x) ); 
	if IsMonoid( Source(x) ) then
        OMPut(stream, List( GeneratorsOfMonoid( Source( x ) ), g -> [ g, g^x ] ) );
    elif IsSemigroup( Source(x) ) then
        OMPut(stream, List( GeneratorsOfSemigroup( Source( x ) ), g -> [ g, g^x ] ) );
    else
        Error( "OMPut for a semigroup homomorphism given by images of generators: can not output ", x );  
    fi;        
	OMIndent := OMIndent-1;
    OMWriteLine(stream, ["</OMA>"]);
end);

fi;

#############################################################################
#
# OMPut for a univariate polynomial (polyu.poly_u_rep)
#
# This was written for Mickael Gastineau to quickly achieve compatibility 
# with the TRIP system and later was commented out because of switching 
# to the 'polyd1' CD.
#
#InstallMethod( OMPut, 
#"for a univariate polynomial (polyu.poly_u_rep)", 
#true,
#[ IsOutputStream, IsUnivariatePolynomial ],
#0,
#function( stream, f )
#local coeffs, deg, nr;
#OMWriteLine( stream, [ "<OMA>" ] );
#OMIndent := OMIndent + 1;
#OMPutSymbol( stream, "polyu", "poly_u_rep" );
#OMPutVar( stream, IndeterminateOfUnivariateRationalFunction(f) );
#coeffs := CoefficientsOfUnivariatePolynomial(f);
#deg := DegreeOfLaurentPolynomial(f);
#for nr in [ deg+1, deg .. 1 ] do
#  if coeffs[nr] <> 0 then
#    OMPutApplication( stream, "polyu", "term", [ nr-1, coeffs[nr] ] );
#  fi;
#od;  
#OMIndent := OMIndent - 1;
#OMWriteLine( stream, [ "</OMA>" ] );
#end);


#############################################################################
#
# OMPut for an algebraic element of an algebraic extension
# (commented out because of switching to field4.field_by_poly_vector)
#
#InstallMethod( OMPut, 
#"for an algebraic element of an algebraic extension", 
#true,
#[ IsOutputStream, IsAlgebraicElement ],
#0,
#function( stream, a )
#local  fam, anam, ext, c, i, is_plus, is_times, is_power;
#fam := FamilyObj( a );
#anam := fam!.indeterminateName;
#ext := ExtRepOfObj(a);
#if Length( Filtered( ext, c -> not IsZero(c) ) ) > 1 then 
#    is_plus := true;
#    OMWriteLine( stream, [ "<OMA>" ] );
#    OMIndent := OMIndent + 1;
#    OMPutSymbol( stream, "arith1", "plus" );
#else
#  is_plus := false;    
#fi;
#for i  in [ 1 .. Length(ext) ]  do
#    if ext[i] <> fam!.baseZero  then
#        if i=1 then
#            OMPut( stream, ext[i] );
#        else
#            if ext[i] <> fam!.baseOne then
#                is_times := true;
#                OMWriteLine( stream, [ "<OMA>" ] );
#                OMIndent := OMIndent + 1;
#                OMPutSymbol( stream, "arith1", "times" );   
#                OMPut( stream, ext[i] );
#            else
#                is_times := false;
#            fi;    
#            if i>2 then
#                is_power:=true;
#                OMWriteLine( stream, [ "<OMA>" ] );
#                OMIndent := OMIndent + 1;
#                OMPutSymbol( stream, "arith1", "power" );  
#            else
#                is_power := false;    
#            fi;     
#            OMPutVar( stream, anam );
#            if is_power then
#                OMPut( stream, i-1 );
#                OMIndent := OMIndent - 1;
#                OMWriteLine( stream, [ "</OMA>" ] );
#            fi;
#            if is_times then
#                OMIndent := OMIndent - 1;
#                OMWriteLine( stream, [ "</OMA>" ] );              
#            fi;
#        fi;
#    fi;
#od;       
#if is_plus then
#    OMIndent := OMIndent - 1;
#    OMWriteLine( stream, [ "</OMA>" ] );  
#fi;                  
#end);


#############################################################################
#
# OMPut for a polynomial ring (polyd1.poly_ring_d_named / polyd1.poly_ring_d)
#
InstallMethod( OMPut,
"for a polynomial ring (polyd1.poly_ring_d_named or polyd1.poly_ring_d)",
true,
[ IsOutputStream, IsPolynomialRing ],
0,
function( stream, r )

if Length( IndeterminatesOfPolynomialRing( r ) ) = 1 then

  SetOMReference( r, Concatenation("polyring", RandomString(16) ) );
  OMWriteLine( stream, [ "<OMA id=\"", OMReference( r ), "\" >" ] );
  OMIndent := OMIndent + 1;
  OMPutSymbol( stream, "polyd1", "poly_ring_d_named" );
  OMPut( stream, CoefficientsRing( r ) );
  OMPutVar( stream, IndeterminatesOfPolynomialRing( r )[1] );
  OMIndent := OMIndent - 1;
  OMWriteLine( stream, [ "</OMA>" ] );

else

  SetOMReference( r, Concatenation("polyring", RandomString(16) ) );
  OMWriteLine( stream, [ "<OMA id=\"", OMReference( r ), "\" >" ] );
  OMIndent := OMIndent + 1;
  OMPutSymbol( stream, "polyd1", "poly_ring_d" );
  OMPut( stream, CoefficientsRing( r ) );
  OMPut( stream, Length( IndeterminatesOfPolynomialRing( r ) ) );
  OMIndent := OMIndent - 1;
  OMWriteLine( stream, [ "</OMA>" ] );

fi;
end);
 

#############################################################################
#
# OMPut for a polynomial ring and a (uni/multivariate) polynomial (polyd1.DMP) 
#
InstallOtherMethod( OMPut, 
"for a polynomial ring and a (uni- or multivariate) polynomial (polyd1.DMP)", 
true,
[ IsOutputStream, IsPolynomialRing, IsPolynomial ],
0,
function( stream, r, f )
local coeffs, deg, nr, coeffring, nrindet, extrep, nvars, pows, i, pos;

if not f in r then
  Error( "OMPut : the polynomial ", f, " is not in the polynomial ring ", r, "\n" );
fi;

coeffring := CoefficientsRing( r );
 
 
if Length( IndeterminatesOfPolynomialRing( r ) ) = 1 then

  OMWriteLine( stream, [ "<OMA>" ] );
  OMIndent := OMIndent + 1;
  OMPutSymbol( stream, "polyd1", "DMP" );
  OMPutReference( stream, r );
  OMWriteLine( stream, [ "<OMA>" ] );
  OMIndent := OMIndent + 1;
  OMPutSymbol( stream, "polyd1", "SDMP" );
  coeffs := CoefficientsOfUnivariatePolynomial( f );
  deg := DegreeOfLaurentPolynomial( f );
  # The zero polynomial is represented by an SDMP with no terms.
  if deg<>infinity then
    if IsField(coeffring) and IsFinite(coeffring) then
    
      # The part for polynomials over finite fields
      # to tell which field to use. To speed up, the 
      # check is outside the loop
      for nr in [ deg+1, deg .. 1 ] do
        if coeffs[nr] <> 0 then
          OMWriteLine( stream, [ "<OMA>" ] );
          OMIndent := OMIndent + 1;
          OMPutSymbol( stream, "polyd1", "term" );
          OMPut( stream, coeffring, coeffs[nr] );
          OMPut( stream, nr-1 );
          OMIndent := OMIndent - 1;   
          OMWriteLine( stream, [ "</OMA>" ] );     
        fi;
      od; 
      
    else
    
      for nr in [ deg+1, deg .. 1 ] do
        if coeffs[nr] <> 0 then
          OMWriteLine( stream, [ "<OMA>" ] );
          OMIndent := OMIndent + 1;
          OMPutSymbol( stream, "polyd1", "term" );
          OMPut( stream, coeffs[nr] );
          OMPut( stream, nr-1 );
          OMIndent := OMIndent - 1;   
          OMWriteLine( stream, [ "</OMA>" ] );     
        fi;
      od;       
    fi;  
  fi;
  OMIndent := OMIndent - 1;
  OMWriteLine( stream, [ "</OMA>" ] );
  OMIndent := OMIndent - 1;
  OMWriteLine( stream, [ "</OMA>" ] );

else

  nrindet := Length(IndeterminatesOfPolynomialRing( r ) );

  OMWriteLine( stream, [ "<OMA>" ] );
  OMIndent := OMIndent + 1;
  OMPutSymbol( stream, "polyd1", "DMP" );
  OMPutReference( stream, r );
  OMWriteLine( stream, [ "<OMA>" ] );
  OMIndent := OMIndent + 1;
  OMPutSymbol( stream, "polyd1", "SDMP" );
  extrep := ExtRepPolynomialRatFun( f );

  if IsField(coeffring) and IsFinite(coeffring) then
  
    # The part for polynomials over finite fields
    # to tell which field to use
    for nr in [ 1, 3 .. Length(extrep)-1 ] do
      OMWriteLine( stream, [ "<OMA>" ] );
      OMIndent := OMIndent + 1;
      OMPutSymbol( stream, "polyd1", "term" );
      OMPut( stream, coeffring, extrep[nr+1] ); # the coefficient
      nvars := extrep[nr]{[1,3..Length(extrep[nr])-1]};
      pows := extrep[nr]{[2,4..Length(extrep[nr])]};
      for i in [1..nrindet] do
        pos := Position( nvars, i );
        if pos=fail then
          OMPut( stream, 0 );
        else
          OMPut( stream, pows[pos] );
        fi;  
      od;
      OMIndent := OMIndent - 1;   
      OMWriteLine( stream, [ "</OMA>" ] ); 
    od; 
    
  else
  
    for nr in [ 1, 3 .. Length(extrep)-1 ] do
      OMWriteLine( stream, [ "<OMA>" ] );
      OMIndent := OMIndent + 1;
      OMPutSymbol( stream, "polyd1", "term" );
      OMPut( stream, extrep[nr+1] ); # the coefficient
      nvars := extrep[nr]{[1,3..Length(extrep[nr])-1]};
      pows := extrep[nr]{[2,4..Length(extrep[nr])]};
      for i in [1..nrindet] do
        pos := Position( nvars, i );
        if pos=fail then
          OMPut( stream, 0 );
        else
          OMPut( stream, pows[pos] );
        fi;  
      od;
      OMIndent := OMIndent - 1;   
      OMWriteLine( stream, [ "</OMA>" ] ); 
    od; 
    
  fi;
    
  OMIndent := OMIndent - 1;
  OMWriteLine( stream, [ "</OMA>" ] );
  OMIndent := OMIndent - 1;
  OMWriteLine( stream, [ "</OMA>" ] );

fi;

end);


#############################################################################
#
#  OpenMathDefaultPolynomialRing and tools for its resetting
#
BindGlobal( "OpenMathDefaultPolynomialRing", [ ] );

BindGlobal( "SetOpenMathDefaultPolynomialRing",
    function( R )
    if not IsPolynomialRing(R) then
    	Error("The argument must be a polynomial ring\n");
    fi;
   	MakeReadWriteGlobal( "OpenMathDefaultPolynomialRing" );
   	OpenMathDefaultPolynomialRing := R;
   	MakeReadOnlyGlobal( "OpenMathDefaultPolynomialRing" );
    end);
    

#############################################################################
#
# OMPut for a (uni/multivariate) polynomial in the default ring or 
# in OpenMathDefaultPolynomialRing, using polyd1.DMP 
#
InstallMethod( OMPut, 
"for a (uni- or multivariate) polynomial in the default ring (polyd1.DMP)", 
true,
[ IsOutputStream, IsPolynomial ],
0,
function( stream, f )
if f in OpenMathDefaultPolynomialRing then
	OMPut( stream, OpenMathDefaultPolynomialRing, f );
else
	Print("#I  Warning : polynomial will be printed using its default ring \n",
	      "#I  because the default OpenMath polynomial ring is not specified \n",
	      "#I  or it is not contained in the default OpenMath polynomial ring.\n", 
	      "#I  You may ignore this or call SetOpenMathDefaultPolynomialRing to fix it.\n");
	OMPut( stream, DefaultRing( f ), f );
fi;	
end);


#############################################################################
#
# OMput for a two-sided ideal with known generators (ring3.ideal)
#
# This currently works only with polynomial rings!!!
#
InstallMethod( OMPut, 
"for a two-sided ideal with known generators (ring3.ideal)",
true,
[ IsOutputStream, 
  IsRing and HasLeftActingRingOfIdeal and 
             HasRightActingRingOfIdeal and HasGeneratorsOfTwoSidedIdeal ],
0,
function( stream, r )
local f;

OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;

OMPutSymbol( stream, "ring3", "ideal" );
OMPut( stream, LeftActingRingOfIdeal( r ) );

OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "list1", "list" );
for f in GeneratorsOfTwoSidedIdeal( r ) do
  OMPut( stream, LeftActingRingOfIdeal( r ), f );
od;
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );

OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );  

end);


#############################################################################
#
# OMPut for algebraic extensions (field3.field_by_poly)
#
InstallMethod( OMPut,
"for algebraic extensions (field3.field_by_poly)",
true,
[ IsOutputStream, IsAlgebraicExtension ],
0,
function( stream, f )
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "field3", "field_by_poly" );
OMPut( stream, LeftActingDomain( f ) );
OMPut( stream, DefiningPolynomial( f ) );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );  
end);    

#############################################################################
#
# OMPut for an algebraic element of an algebraic extension 
# (field4.field_by_poly_vector)
#
InstallMethod( OMPut, 
"for an algebraic element of an algebraic extension (field4.field_by_poly_vector)", 
true,
[ IsOutputStream, IsAlgebraicElement ],
0,
function( stream, a )
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "field4", "field_by_poly_vector" );
OMWriteLine( stream, [ "<OMA>" ] );
OMIndent := OMIndent + 1;
OMPutSymbol( stream, "field3", "field_by_poly" );
OMPut( stream, FamilyObj(a)!.baseField );
OMPut( stream, FamilyObj(a)!.poly );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );  
OMPut( stream, ExtRepOfObj(a) );
OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );  
end); 


#############################################################################
#
# OMPut for a finite field and its element using finfield1 CD
#
InstallOtherMethod( OMPut, 
"for for a finite field element using finfield1 CD", 
true,
[ IsOutputStream, IsField and IsFinite, IsFFE ],
0,
function( stream, f, a )
if IsZero(a) then
	OMWriteLine( stream, [ "<OMA>" ] );
		OMIndent := OMIndent + 1;
		OMPutSymbol( stream, "arith1", "times" );
		OMWriteLine( stream, [ "<OMA>" ] );
			OMIndent := OMIndent + 1;
			OMPutSymbol( stream, "finfield1", "primitive_element" );
			OMPut( stream, Size( f ) );
			OMIndent := OMIndent - 1;
		OMWriteLine( stream, [ "</OMA>" ] );  
		OMPut( stream, 0 );
		OMIndent := OMIndent - 1;
	OMWriteLine( stream, [ "</OMA>" ] );  
else
	OMWriteLine( stream, [ "<OMA>" ] );
		OMIndent := OMIndent + 1;
		OMPutSymbol( stream, "arith1", "power" );
		OMWriteLine( stream, [ "<OMA>" ] );
			OMIndent := OMIndent + 1;
			OMPutSymbol( stream, "finfield1", "primitive_element" );
			OMPut( stream, Size( f ) );
			OMIndent := OMIndent - 1;
		OMWriteLine( stream, [ "</OMA>" ] );  
		OMPut( stream, LogFFE( a, PrimitiveRoot( f ) ) );
		OMIndent := OMIndent - 1;
	OMWriteLine( stream, [ "</OMA>" ] );  
fi;
end); 


#############################################################################
#
# OMPut for a finite field element in its default field
#
InstallMethod( OMPut, 
"for for a finite field element using finfield1 CD", 
true,
[ IsOutputStream, IsFFE ],
0,
function( stream, a )
	OMPut( stream, DefaultField( a ), a );
end); 


#############################################################################
#
# OMPut for a finite field using setname2.{GFp,GFpn}
#
InstallMethod( OMPut, 
"for for a finite field using setname2.GFp or setname2.GFpn", 
true,
[ IsOutputStream, IsField ],
0,
function( stream, f )
OMWriteLine( stream, [ "<OMA>" ] );
	OMIndent := OMIndent + 1;
	if IsPrimeInt( Size( f ) ) then
		OMPutSymbol( stream, "setname2", "GFp" );
  		OMPut( stream, Size( f ) );
	else
		OMPutSymbol( stream, "setname2", "GFpn" );
  		OMPut( stream, Characteristic( f ) );
  		OMPut( stream, DegreeOverPrimeField( f ) );
	fi;
	OMIndent := OMIndent - 1;
OMWriteLine( stream, [ "</OMA>" ] );  
end); 


#######################################################################
##
#M  OMPut( <stream>, <perm> )  
##
##  Printing for permutations: specified in permut1.ocd 
## 
InstallMethod(OMPut, "for a permutation", true,
[IsOutputStream, IsPerm],0,
function(stream, x)
	OMPutApplication( stream, "permut1", "permutation", ListPerm(x) );
end);


# The method was commented out before OMsymTable was converted into OMsymRecord,
# however, it was updated it as well to save the changes for a case. Note that
# the search across all record components is very inefficient.
# 
#InstallMethod(OMPut, "for a function", true,
#[IsOutputStream, IsFunction],0,
#function ( stream, x )
#    local cd, name;
#    for cd in RecNames( OMsymRecord ) do
#        for  name in RecNames( OMsymRecord.(cd) ) do
#            if x = OMsymRecord.(cd).(name) then
#                OMPutSymbol( stream, cd, name );
#                return;
#            fi;
#        od;
#    od;
#    TryNextMethod();
#end);



#######################################################################
##
#M  OMPutList( <stream>, <list> )  
##
##
InstallMethod(OMPutList, "for a list of any type", true,
[IsOutputStream, IsList],0,
function(stream, x)
  local i;

  OMWriteLine(stream, ["<OMA>"]);
  OMIndent := OMIndent +1;

	OMPutSymbol( stream, "list1", "list" );
	for i in x do
		if IsString(i) then
			OMPut(stream, i); # no such thing as characters in OpenMath
		else
			OMPutList(stream, i);
		fi;
	od;

	OMIndent := OMIndent -1;
	OMWriteLine(stream, ["</OMA>"]);
end);


#######################################################################
##
#M  OMPutList( <stream>, <list> )  
##
##
InstallMethod(OMPutList, "when we can find no way of regarding it as a list", 
true, [IsOutputStream, IsObject],0,
function(stream, x)
	OMPut(stream, x);
end);


#############################################################################
#
# Functions and methods for OMPlainString
#
InstallGlobalFunction( OMPlainString,
function( string )
local pos;
if IsString( string ) then
    # note that we do not validate the string!
    return Objectify( OMPlainStringDefaultType, [ string ] );
else
    Error( "The argument of OMPlainString must be a string" );
fi;                    
end);


#############################################################################
##
#M  PrintObj( <IsOMPlainString> )
##
InstallMethod( PrintObj, "for IsOMPlainString",
[ IsOMPlainStringRep and IsOMPlainString ],
function( obj )
    Print( obj![1] );
end);


#############################################################################
##
#M  OMPut( <IsOMPlainString> )
##
InstallMethod( OMPut, "for IsOMPlainString",
true,
[ IsOutputStream, IsOMPlainString ],
0,
function( stream, s )
    OMWriteLine( stream, [ s ] );
end); 


#############################################################################
#E
