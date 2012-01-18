###########################################################################
##
#W  omput.gi                OpenMath Package           Andrew Solomon
#W                                                     Marco Costantini
##
#Y  Copyright (C) 1999, 2000, 2001, 2006
#Y  School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  High-level methods to output GAP objects in OpenMath 
## 


###########################################################################
#
# Functions and methods for OpenMathWriter
#
InstallGlobalFunction( OpenMathBinaryWriter, function( stream )
if IsStream( stream ) then
    return Objectify( OpenMathBinaryWriterType, [ stream ] );
else
    Error( "The argument of OpenMathBinaryWriter must be a stream" );
fi;                    
end);

InstallGlobalFunction( OpenMathXMLWriter, function( stream )
if IsStream( stream ) then
    return Objectify( OpenMathXMLWriterType, [ stream ] );
else
    Error( "The argument of OpenMathXMLWriter must be a stream" );
fi;                    
end);


###########################################################################
##
#M  PrintObj( <IsOpenMathBinaryWriter> )
##
InstallMethod( PrintObj, "for IsOpenMathBinaryWriter",
[ IsOpenMathBinaryWriter ],
function( obj )
    Print( "<OpenMath binary writer to ", obj![1], ">" );
end);


###########################################################################
##
#M  PrintObj( <IsOpenMathXMLWriter> )
##
InstallMethod( PrintObj, "for IsOpenMathXMLWriter",
[ IsOpenMathXMLWriter ],
function( obj )
    Print( "<OpenMath XML writer to ", obj![1], ">" );
end);


###########################################################################
#
# RandomString( <n> )
#
# This function generates a random string of the length n
# It is needed in particular to create references, 
# and also used in SCSCP package to generate random call identifiers
# Creation of OpenMathRealRandomSource is placed inside the function
# to avoid its early call when IO is not fully loaded (Error happens 
# if GAP is started with "gap -r -A" and then LoadPackage("scscp");
# is entered.
#
BindGlobal( "RandomString", function( n )
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
    

###########################################################################
##
## Compound OpenMath objects and main functionality
##


###########################################################################
##
#M  OMPutError( <OMWriter>, <cd>, <name>, <list> )
##
##  Input : cd, name as strings, list as a list
##  Output:
##        <OMA>
##                <OMS cd=<cd> name=<name> />
##                OMPut( <writer>, <list>[1] )
##                OMPut( <writer>, <list>[2] )
##                ...
##        </OMA>
##
InstallGlobalFunction(OMPutError, function ( writer, cd, name, list )
    local  obj;
    OMPutOME( writer );
    OMPutSymbol( writer, cd, name );
    for obj  in list  do
        OMPut( writer, obj );
    od;
    OMPutEndOME( writer );
end);


###########################################################################
##
#M  OMPutApplication( <OMWriter>, <cd>, <name>, <list> )
##
##  Input : cd, name as strings, list as a list
##  Output:
##        <OMA>
##                <OMS cd=<cd> name=<name> />
##                OMPut( <writer>, <list>[1] )
##                OMPut( <writer>, <list>[2] )
##                ...
##        </OMA>
##
InstallGlobalFunction(OMPutApplication, function ( writer, cd, name, list )
    local  obj;
    OMPutOMA( writer );
    OMPutSymbol( writer, cd, name );
    for obj  in list  do
        OMPut( writer, obj );
    od;
    OMPutEndOMA( writer );
end);


###########################################################################
##
#F  OMPutObject( <OMWriter>, <obj> ) 
##
##
InstallGlobalFunction(OMPutObject, function( writer, x )

	if IsClosedStream( writer![1] )  then
		Error( "closed stream" );
	fi;

	if IsOutputTextStream( writer![1] )  then
		SetPrintFormattingStatus( writer![1], false );
	fi;

    OMPutOMOBJ( writer );
		OMPut( writer, x );
    OMPutEndOMOBJ( writer );
end);


###########################################################################
##
#F  OMPutObjectNoOMOBJtags( <OMWriter>, <obj> ) 
##
##
InstallGlobalFunction(OMPutObjectNoOMOBJtags, function( writer, x )

	if IsClosedStream( writer![1] )  then
		Error( "closed stream" );
	fi;

	if IsOutputTextStream( writer![1] )  then
		SetPrintFormattingStatus( writer![1], false );
	fi;

	OMIndent := 0;
	OMPut(writer, x);
end);


###########################################################################
##
#F  OMPrint( <obj> ) ....................... Print <obj> as OpenMath object
##
##
InstallGlobalFunction( OMPrint, function( arg )
	local str, outstream, writer;
	str := "";
	outstream := OutputTextString(str, true);
	writer := OpenMathXMLWriter( outstream );
	if Length( arg ) = 1 then
		OMPutObject(writer, arg[1] );
	elif Length( arg ) = 2 then
		OMPutObject(writer, arg[1], arg[2] );
	else
		Error("OpenMath : OMPrint accepts only 1 or 2 arguments!!!\n");
	fi;
	CloseStream(outstream);
	Print(str);
end);


###########################################################################
## 
## OMString( <obj> ) .......... Return string with <obj> as OpenMath object
##
InstallGlobalFunction( OMString, function ( x )
local noomobj, str, outstream;
if ValueOption("noomobj") <> fail then
    noomobj := true;
else
    noomobj := false;
fi;
str := "";
outstream := OutputTextString( str, true );
if noomobj then
    OMPutObjectNoOMOBJtags( OpenMathXMLWriter(outstream), x );
else
    OMPutObject( OpenMathXMLWriter(outstream), x );
fi;
CloseStream( outstream );
NormalizeWhitespace( str );
return str;
end);


###########################################################################
## 
## Various methods for OMPut
## 

 
###########################################################################
##
#M  OMPut( <OMWriter>, <bool> )  
##
##  Printing for booleans: specified in CD nums # now logic1
## 
InstallMethod(OMPut, "for a boolean", true,
[ IsOpenMathWriter, IsBool ], 0,
function(writer, x)
    if not x in [ true, false ]  then
        TryNextMethod();
    fi;
    OMPutSymbol( writer, "logic1", String(x) );
end);


###########################################################################
##
#M  OMPut( <OMWriter>, <rat> )  
##
##  Printing for rationals
## 
InstallMethod( OMPut, "for a rational", true,
[ IsOpenMathWriter, IsRat ],0,
function( writer, x )
	OMPutApplication( writer, "nums1", "rational",
		[ NumeratorRat(x), DenominatorRat(x)] );
end);


###########################################################################
##
#M  OMPut( <OMWriter>, <resclass> )  
##
##  Printing for residue classes
## 
InstallMethod( OMPut, "for a residue class", true,
[ IsOpenMathWriter, IsZmodnZObj ],0,
function( writer, x )
	OMPutApplication( writer, "integer2", "class",
		[  x![1], FamilyObj(x)!.modulus ] );
end);


###########################################################################
##
#M  OMPut( <OMWriter>, <cyc> )  
##
##  Printing for cyclotomics
## 
InstallMethod( OMPut, "for a proper cyclotomic", true,
[ IsOpenMathWriter, IsCyc ],0,
function( writer, x )
	local
                real,
                imaginary,

		n, # Length(powlist)
		i,
		clist; # x = Sum_i clist[i]*E(n)^(i-1)

    if IsGaussRat( x )  then

        real := x -> (x + ComplexConjugate( x )) / 2;
        imaginary := x -> (x - ComplexConjugate( x )) * -1 / 2 * E( 4 );

        OMPutApplication( writer, "complex1", "complex_cartesian", 
            [ real(x), imaginary(x)] );

    else

	n := Conductor(x);
	clist := CoeffsCyc(x, n);

	OMPutOMA(writer);
	OMPutSymbol( writer, "arith1", "plus" );
	for i in [1 .. n] do
		if clist[i] <> 0 then

			OMPutOMA(writer); # times
			OMPutSymbol( writer, "arith1", "times" );
			OMPut(writer, clist[i]);

			OMPutApplication( writer, "algnums", "NthRootOfUnity", [ n, i-1 ] );

			OMPutEndOMA(writer); #times
		fi;
	od;
	OMPutEndOMA(writer); 

    fi;
end);


###########################################################################
##
#M  OMPut( <OMWriter>, <infinity> )
##
##  Printing for infinity: specified in nums1.ocd
##

InstallMethod(OMPut, "for infinity", true,
[ IsOpenMathWriter, IsInfinity ],0,
function(writer, x)
        OMPutSymbol( writer, "nums1", "infinity" );
end);


###########################################################################
##
#M  OMPut( <OMWriter>,  <vector> )  
##
##  Printing for vectors: specified in linalg2.ocd
##
#InstallMethod(OMPut, "for a row vector", true,
#[IsOpenMathWriter, IsRowVector],0,
#function(writer, x)
#
#  OMPutApplication( writer, "linalg2", "vector", x );
#
#end);


###########################################################################
##
#M  OMPut( <OMWriter>, <matrix> )  
##
##  Printing for matrices: specified in linalg2.ocd
##
InstallMethod(OMPut, "for a matrix", true,
[IsOpenMathWriter, IsMatrix],0,
function(writer, x)
	local  r;
	OMPutOMA(writer);
	if ValueOption( "OMignoreMatrices" ) = true or not IsRectangularTable(x) then
    	OMPutSymbol( writer, "list1", "list" );
    	for r  in x  do
    		OMPutApplication( writer, "list1", "list", r );
    	od;
    else
    	OMPutSymbol( writer, "linalg2", "matrix" );
    	for r  in x  do
    		OMPutApplication( writer, "linalg2", "matrixrow", r );
    	od;
    fi;
    OMPutEndOMA(writer);
end);


###########################################################################
##
#M  OMPut( <OMWriter>, NonnegativeIntegers )
##
##  Printing for the set N
##
InstallMethod(OMPut, "for NonnegativeIntegers", true,
[IsOpenMathWriter, IsNonnegativeIntegers],0,
function(writer, x)
        OMPutSymbol( writer, "setname1", "N" );
end);


###########################################################################
##
#M  OMPut( <OMWriter>, Integers )
##
##  Printing for the set Z
##
InstallMethod(OMPut, "for Integers", true,
[IsOpenMathWriter, IsIntegers],0,
function(writer, x)
        OMPutSymbol( writer, "setname1", "Z" );
end);


###########################################################################
##
#M  OMPut( <OMWriter>, Rationals )
##
##  Printing for the set Q
##
InstallMethod(OMPut, "for Rationals", true,
[IsOpenMathWriter, IsRationals],0,
function(writer, x)
        OMPutSymbol( writer, "setname1", "Q" );
end);


###########################################################################
##
#F  OMPutListVar( <stream>, <list> )  
##
##
BindGlobal("OMPutListVar", function(writer, x)
  local i;
  OMPutOMA( writer );
    OMPutSymbol( writer, "list1", "list" );
    for i in x do
      OMPutVar(writer, i); 
    od;
  OMPutEndOMA( writer );
end);


###########################################################################
##
#M  OMPut( <OMWriter>, <list> )  
##
##  Printing for finite lists or collection. Prints them as lists.
##
## 

InstallMethod(OMPut, "for a finite list or collection", true,
[IsOpenMathWriter, IsListOrCollection and IsFinite], 0,
function(writer, x)
  if IsBlist(x) then
    OMPutByteArray( writer, x);
  else
    OMPutApplication( writer, "list1", "list", x );
  fi;
end);


###########################################################################
##
#M  OMPut( <OMWriter>, <set> )  
##
##  Printing for finite set: specified in set1.ocd
##
InstallMethod(OMPut, "for a finite set", true,
[IsOpenMathWriter, IsDuplicateFreeList and IsFinite],0,
function(writer, x)

  if IsString(x) and Length(x)>0 or IsEmptyString(x)  then 
  # this doesn't include the empty list
    TryNextMethod();
  fi;

  if ValueOption( "OMignoreSets" ) = true then

    OMPutApplication( writer, "list1", "list", x );

  else

    if IsEmpty(x) then
      OMPutSymbol( writer, "set1", "emptyset" );
    else
      OMPutApplication( writer, "set1", "set", x );
    fi;

  fi;
  
end);


###########################################################################
##
#M  OMPut( <OMWriter>, <range> )
##
##  Printing for ranges: specified in interval1.ocd
##

InstallMethod(OMPut, "for a range", true,
[IsOpenMathWriter, IsRange and IsRangeRep],0,
function ( writer, x )

    if not x[2] - x[1] = 1  then
        TryNextMethod();
    fi;

    OMPutApplication( writer, "interval1", "integer_interval",
        [ x[1], x[Length( x )] ] );

end);


###########################################################################
##
#M  OMPut( <OMWriter>, <group> )  
##
##  Printing permutation group as specified in permgp1.group symbol
## 
InstallMethod(OMPut, "for a permutation group", true,
[IsOpenMathWriter, IsPermGroup],0,
function(writer, x)
	local g;
	OMPutOMA(writer);
    OMPutSymbol( writer, "permgp1", "group" );
    OMPutSymbol( writer, "permutation1", "right_compose" );
	for g in GeneratorsOfGroup(x) do
		OMPut( writer, g );
	od;
    OMPutEndOMA(writer);
end); 


###########################################################################
##
#M  OMPut( <OMWriter>, <semigrouphom> )  
##
##  this requires MONOID so will not work in GAP 4.5
if not CompareVersionNumbers( GAPInfo.Version, "4.5.0") then
InstallMethod(OMPut, "for a semigroup homomorphism given by images of generators", true,
[IsOpenMathWriter, IsSemigroupHomomorphism and IsSemigroupHomomorphismByImagesOfGensRep],0,
function(writer, x)
    local g;
	OMPutOMA(writer);
	OMPutSymbol( writer, "semigroup4", "homomorphism_by_generators" );
	OMPut(writer, Source(x) );
	OMPut(writer, Range(x) ); 
	if IsMonoid( Source(x) ) then
        OMPut(writer, List( GeneratorsOfMonoid( Source( x ) ), g -> [ g, g^x ] ) );
    elif IsSemigroup( Source(x) ) then
        OMPut(writer, List( GeneratorsOfSemigroup( Source( x ) ), g -> [ g, g^x ] ) );
    else
        Error( "OMPut for a semigroup homomorphism given by images of generators: can not output ", x );  
    fi;        
    OMPutEndOMA(writer);
end);
fi;

###########################################################################
#
# OMPut for a univariate polynomial (polyu.poly_u_rep)
#
# This was written for Mickael Gastineau to quickly achieve compatibility 
# with the TRIP system and later was commented out because of switching 
# to the 'polyd1' CD.
#
#InstallMethod( OMPut, "for a univariate polynomial (polyu.poly_u_rep)", 
#true,
#[ IsOpenMathWriter, IsUnivariatePolynomial ],
#0,
#function( writer, f )
#local coeffs, deg, nr;
#OMPutOMA(writer);
#OMPutSymbol( writer, "polyu", "poly_u_rep" );
#OMPutVar( writer, IndeterminateOfUnivariateRationalFunction(f) );
#coeffs := CoefficientsOfUnivariatePolynomial(f);
#deg := DegreeOfLaurentPolynomial(f);
#for nr in [ deg+1, deg .. 1 ] do
#  if coeffs[nr] <> 0 then
#    OMPutApplication( writer, "polyu", "term", [ nr-1, coeffs[nr] ] );
#  fi;
#od;  
#OMPutEndOMA(writer);
#end);


###########################################################################
#
# OMPut for an algebraic element of an algebraic extension
# (commented out because of switching to field4.field_by_poly_vector)
#
#InstallMethod( OMPut, "for an algebraic element of an algebraic extension", 
#true,
#[ IsOpenMathWriter, IsAlgebraicElement ],
#0,
#function( writer, a )
#local  fam, anam, ext, c, i, is_plus, is_times, is_power;
#fam := FamilyObj( a );
#anam := fam!.indeterminateName;
#ext := ExtRepOfObj(a);
#if Length( Filtered( ext, c -> not IsZero(c) ) ) > 1 then 
#    is_plus := true;
# 	 OMPutOMA(writer);
#    OMPutSymbol( writer, "arith1", "plus" );
#else
#  is_plus := false;    
#fi;
#for i  in [ 1 .. Length(ext) ]  do
#    if ext[i] <> fam!.baseZero  then
#        if i=1 then
#            OMPut( writer, ext[i] );
#        else
#            if ext[i] <> fam!.baseOne then
#                is_times := true;
# 	             OMPutOMA(writer);
#                OMPutSymbol( writer, "arith1", "times" );   
#                OMPut( writer, ext[i] );
#            else
#                is_times := false;
#            fi;    
#            if i>2 then
#                is_power:=true;
#                OMPutOMA(writer);
#                OMPutSymbol( writer, "arith1", "power" );  
#            else
#                is_power := false;    
#            fi;     
#            OMPutVar( writer, anam );
#            if is_power then
#                OMPut( writer, i-1 );
#                OMPutEndOMA(writer);
#            fi;
#            if is_times then
#                OMPutEndOMA(writer);
#            fi;
#        fi;
#    fi;
#od;       
#if is_plus then
#	OMPutEndOMA(writer);
#fi;                  
#end);


###########################################################################
##
#M  OMPut( <stream>, <hasse diagram> )
##
## Addendum to GAP OpenMath phrasebook.
##
InstallMethod(OMPut, "for a Hasse diagram", true,
[IsOpenMathWriter,IsHasseDiagram],0,
function(writer, x)
	local d, i;
	d := UnderlyingDomainOfBinaryRelation(x);
#	OMWriteLine(writer![1], ["<OMBIND>"]);
	OMPutOMBIND(writer);
	OMIndent := OMIndent +1;
	OMPutSymbol(writer, "fns2", "constant");
#	OMWriteLine(writer![1], ["<OMBVAR>"]);
	OMPutOMBVAR(writer);
	OMIndent := OMIndent +1;
	for i in d do
		OMPutVar(writer, i);
	od;
	OMIndent := OMIndent -1;
#	OMWriteLine(writer![1], ["</OMBVAR>"]);
	OMPutEndOMBVAR(writer);
    OMPutOMA( writer );
	OMPutSymbol(writer, "relation2", "hasse_diagram");
	
	for i in d do
        OMPutOMA( writer );
		OMPutSymbol(writer, "list1", "list");
		OMPutVar(writer, i);
		OMPutListVar(writer, ImagesElm(x, i));
        OMPutEndOMA( writer );
	od;
    OMPutEndOMA( writer );
	OMIndent := OMIndent -1;
#	OMWriteLine(writer![1], ["</OMBIND>"]);
	OMPutEndOMBIND(writer);
end);


###########################################################################
#
# OMPut for a polynomial ring (polyd1.poly_ring_d_named / polyd1.poly_ring_d)
#
InstallMethod( OMPut, "for a polynomial ring (polyd1.poly_ring_d_named or polyd1.poly_ring_d)",
true,
[ IsOpenMathWriter, IsPolynomialRing ],
0,
function( writer, r )
if Length( IndeterminatesOfPolynomialRing( r ) ) = 1 then

  SetOMReference( r, Concatenation("polyring", RandomString(16) ) );
  OMPutOMAWithId( writer, OMReference(r) );
  OMIndent := OMIndent + 1;
  OMPutSymbol( writer, "polyd1", "poly_ring_d_named" );
  OMPut( writer, CoefficientsRing( r ) );
  OMPutVar( writer, IndeterminatesOfPolynomialRing( r )[1] );
  OMPutEndOMA(writer);

else

  SetOMReference( r, Concatenation("polyring", RandomString(16) ) );
  OMPutOMAWithId( writer, OMReference(r) );
  OMIndent := OMIndent + 1;
  OMPutSymbol( writer, "polyd1", "poly_ring_d" );
  OMPut( writer, CoefficientsRing( r ) );
  OMPut( writer, Length( IndeterminatesOfPolynomialRing( r ) ) );
  OMPutEndOMA(writer);

fi;
end);
 

###########################################################################
#
# OMPut for a polynomial ring and a (uni/multivariate) polynomial (polyd1.DMP) 
#
InstallOtherMethod( OMPut, "for a polynomial ring and a (uni- or multivariate) polynomial (polyd1.DMP)", 
true,
[ IsOpenMathWriter, IsPolynomialRing, IsPolynomial ],
0,
function( writer, r, f )
local coeffs, deg, nr, coeffring, nrindet, extrep, nvars, pows, i, pos;

if not f in r then
  Error( "OMPut : the polynomial ", f, " is not in the polynomial ring ", r, "\n" );
fi;

coeffring := CoefficientsRing( r );
 
 
if Length( IndeterminatesOfPolynomialRing( r ) ) = 1 then

  OMPutOMA(writer);
  OMPutSymbol( writer, "polyd1", "DMP" );
  OMPutReference( writer, r );
  OMPutOMA(writer);
  OMPutSymbol( writer, "polyd1", "SDMP" );
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
	      OMPutOMA(writer);
          OMPutSymbol( writer, "polyd1", "term" );
          OMPut( writer, coeffring, coeffs[nr] );
          OMPut( writer, nr-1 );
          OMPutEndOMA(writer);
        fi;
      od; 
      
    else
    
      for nr in [ deg+1, deg .. 1 ] do
        if coeffs[nr] <> 0 then
	      OMPutOMA(writer);
          OMPutSymbol( writer, "polyd1", "term" );
          OMPut( writer, coeffs[nr] );
          OMPut( writer, nr-1 );
          OMPutEndOMA(writer);
        fi;
      od;       
    fi;  
  fi;
  OMPutEndOMA(writer);
  OMPutEndOMA(writer);

else

  nrindet := Length(IndeterminatesOfPolynomialRing( r ) );

  OMPutOMA(writer);
  OMPutSymbol( writer, "polyd1", "DMP" );
  OMPutReference( writer, r );
  OMPutOMA(writer);
  OMPutSymbol( writer, "polyd1", "SDMP" );
  extrep := ExtRepPolynomialRatFun( f );

  if IsField(coeffring) and IsFinite(coeffring) then
  
    # The part for polynomials over finite fields
    # to tell which field to use
    for nr in [ 1, 3 .. Length(extrep)-1 ] do
	  OMPutOMA(writer);
      OMPutSymbol( writer, "polyd1", "term" );
      OMPut( writer, coeffring, extrep[nr+1] ); # the coefficient
      nvars := extrep[nr]{[1,3..Length(extrep[nr])-1]};
      pows := extrep[nr]{[2,4..Length(extrep[nr])]};
      for i in [1..nrindet] do
        pos := Position( nvars, i );
        if pos=fail then
          OMPut( writer, 0 );
        else
          OMPut( writer, pows[pos] );
        fi;  
      od;
      OMPutEndOMA(writer);
    od; 
    
  else
  
    for nr in [ 1, 3 .. Length(extrep)-1 ] do
	  OMPutOMA(writer);
      OMPutSymbol( writer, "polyd1", "term" );
      OMPut( writer, extrep[nr+1] ); # the coefficient
      nvars := extrep[nr]{[1,3..Length(extrep[nr])-1]};
      pows := extrep[nr]{[2,4..Length(extrep[nr])]};
      for i in [1..nrindet] do
        pos := Position( nvars, i );
        if pos=fail then
          OMPut( writer, 0 );
        else
          OMPut( writer, pows[pos] );
        fi;  
      od;
      OMPutEndOMA(writer);
    od; 
    
  fi;
    
  OMPutEndOMA(writer);
  OMPutEndOMA(writer);

fi;

end);


###########################################################################
#
#  OpenMathDefaultPolynomialRing and tools for its resetting
#
BindGlobal( "OpenMathDefaultPolynomialRing", [ ] );

BindGlobal( "SetOpenMathDefaultPolynomialRing", function( R )
    if not IsPolynomialRing(R) then
    	Error("The argument must be a polynomial ring\n");
    fi;
   	MakeReadWriteGlobal( "OpenMathDefaultPolynomialRing" );
   	OpenMathDefaultPolynomialRing := R;
   	MakeReadOnlyGlobal( "OpenMathDefaultPolynomialRing" );
    end);
    

###########################################################################
#
# OMPut for a (uni/multivariate) polynomial in the default ring or 
# in OpenMathDefaultPolynomialRing, using polyd1.DMP 
#
InstallMethod( OMPut, "for a (uni- or multivariate) polynomial in the default ring (polyd1.DMP)", 
true,
[ IsOpenMathWriter, IsPolynomial ],
0,
function( writer, f )
if f in OpenMathDefaultPolynomialRing then
	OMPut( writer, OpenMathDefaultPolynomialRing, f );
else
	Print("#I  Warning : polynomial will be printed using its default ring \n",
	      "#I  because the default OpenMath polynomial ring is not specified \n",
	      "#I  or it is not contained in the default OpenMath polynomial ring.\n", 
	      "#I  You may ignore this or call SetOpenMathDefaultPolynomialRing to fix it.\n");
	OMPut( writer, DefaultRing( f ), f );
fi;	
end);


###########################################################################
#
# OMput for a two-sided ideal with known generators (ring3.ideal)
#
# This currently works only with polynomial rings!!!
#
InstallMethod( OMPut, "for a two-sided ideal with known generators (ring3.ideal)",
true,
[ IsOpenMathWriter, 
  IsRing and HasLeftActingRingOfIdeal and 
             HasRightActingRingOfIdeal and HasGeneratorsOfTwoSidedIdeal ],
0,
function( writer, r )
local f;
OMPutOMA(writer);
	OMPutSymbol( writer, "ring3", "ideal" );
	OMPut( writer, LeftActingRingOfIdeal( r ) );
	OMPutOMA(writer);
		OMPutSymbol( writer, "list1", "list" );
		for f in GeneratorsOfTwoSidedIdeal( r ) do
  			OMPut( writer, LeftActingRingOfIdeal( r ), f );
		od;
	OMPutEndOMA(writer);
OMPutEndOMA(writer);
end);


###########################################################################
#
# OMPut for algebraic extensions (field3.field_by_poly)
#
InstallMethod( OMPut, "for algebraic extensions (field3.field_by_poly)",
true,
[ IsOpenMathWriter, IsAlgebraicExtension ],
0,
function( writer, f )
OMPutOMA(writer);
OMPutSymbol( writer, "field3", "field_by_poly" );
OMPut( writer, LeftActingDomain( f ) );
OMPut( writer, DefiningPolynomial( f ) );
OMPutEndOMA(writer);  
end);    

###########################################################################
#
# OMPut for an algebraic element of an algebraic extension 
# (field4.field_by_poly_vector)
#
InstallMethod( OMPut, "for an algebraic element of an algebraic extension (field4.field_by_poly_vector)", 
true,
[ IsOpenMathWriter, IsAlgebraicElement ],
0,
function( writer, a )
OMPutOMA(writer);
OMPutSymbol( writer, "field4", "field_by_poly_vector" );
OMPutOMA(writer);
OMPutSymbol( writer, "field3", "field_by_poly" );
OMPut( writer, FamilyObj(a)!.baseField );
OMPut( writer, FamilyObj(a)!.poly );
OMPutEndOMA(writer);  
OMPut( writer, ExtRepOfObj(a) );
OMPutEndOMA(writer);  
end); 


###########################################################################
#
# OMPut for a finite field and its element using finfield1 CD
#
InstallOtherMethod( OMPut, "for for a finite field element using finfield1 CD", 
true,
[ IsOpenMathWriter, IsField and IsFinite, IsFFE ],
0,
function( writer, f, a )
if IsZero(a) then
        OMPutOMA(writer);
		OMPutSymbol( writer, "arith1", "times" );
            OMPutOMA(writer);
			OMPutSymbol( writer, "finfield1", "primitive_element" );
			OMPut( writer, Size( f ) );
        OMPutEndOMA(writer);  
		OMPut( writer, 0 );
    OMPutEndOMA(writer); 
else
    OMPutOMA(writer);
		OMPutSymbol( writer, "arith1", "power" );
            OMPutOMA(writer);
			OMPutSymbol( writer, "finfield1", "primitive_element" );
			OMPut( writer, Size( f ) );
        OMPutEndOMA(writer); 
		OMPut( writer, LogFFE( a, PrimitiveRoot( f ) ) );
    OMPutEndOMA(writer);
fi;
end); 


###########################################################################
#
# OMPut for a finite field element in its default field
#
InstallMethod( OMPut, "for for a finite field element using finfield1 CD", 
true,
[ IsOpenMathWriter, IsFFE ],
0,
function( writer, a )
	OMPut( writer, DefaultField( a ), a );
end); 


###########################################################################
#
# OMPut for a finite field using setname2.{GFp,GFpn}
#
InstallMethod( OMPut, "for for a finite field using setname2.GFp or setname2.GFpn", 
true,
[ IsOpenMathWriter, IsField ],
0,
function( writer, f )
    OMPutOMA(writer);
	if IsPrimeInt( Size( f ) ) then
		OMPutSymbol( writer, "setname2", "GFp" );
  		OMPut( writer, Size( f ) );
	else
		OMPutSymbol( writer, "setname2", "GFpn" );
  		OMPut( writer, Characteristic( f ) );
  		OMPut( writer, DegreeOverPrimeField( f ) );
	fi;
    OMPutEndOMA(writer);  
end); 


#######################################################################
##
#M  OMPut( <OMWriter>, <perm> )  
##
##  Printing for permutations: specified in permut1.ocd 
## 
InstallMethod(OMPut, "for a permutation", true,
[IsOpenMathWriter, IsPerm],0,
function(writer, x)
	OMPutApplication( writer, "permut1", "permutation", ListPerm(x) );
end);


# The method was commented out before OMsymTable was converted into 
# OMsymRecord, however, it was updated it as well to save the changes 
# for a case. Note that the search across all record components is very 
# inefficient.
# 
#InstallMethod(OMPut, "for a function", true,
#[IsOpenMathWriter, IsFunction],0,
#function ( writer, x )
#    local cd, name;
#    for cd in RecNames( OMsymRecord ) do
#        for  name in RecNames( OMsymRecord.(cd) ) do
#            if x = OMsymRecord.(cd).(name) then
#                OMPutSymbol( writer, cd, name );
#                return;
#            fi;
#        od;
#    od;
#    TryNextMethod();
#end);


###########################################################################
##
#M  OMPutList( <OMWriter>, <list> )  
##
##
InstallMethod(OMPutList, "for a list of any type", true,
[IsOpenMathWriter, IsList],0,
function(writer, x)
  local i;
    OMPutOMA(writer);
	OMPutSymbol( writer, "list1", "list" );
	for i in x do
		if IsString(i) then
			OMPut(writer, i); # no such thing as characters in OpenMath
		else
			OMPutList(writer, i);
		fi;
	od;
    OMPutEndOMA(writer);
end);


###########################################################################
##
#M  OMPutList( <OMWriter>, <list> )  
##
##
InstallMethod(OMPutList, "when we can find no way of regarding it as a list", 
true, [IsOpenMathWriter, IsObject],0,
function(writer, x)
	OMPut(writer, x);
end);


###########################################################################
#E
