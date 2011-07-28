#######################################################################
##
#W  omput.gi                OpenMath Package           Andrew Solomon
#W                                                     Marco Costantini
##
#H  @(#)$Id: private.gi,v 1.11 2010/11/12 13:18:24 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  Writes a GAP object to an output stream, as an OpenMath object
## 


#######################################################################
##
#M  OMPut( <OMWriter>, <cyc> )  
##
##  Printing for cyclotomics
## 
InstallMethod( OMPut, "for a proper cyclotomic", true,
[ IsOpenMathWriter, IsCyc ],0,
function(writer, x)
local real,
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

	OMPutOMA( writer );
	OMPutSymbol( writer, "arith1", "plus" );
	for i in [1 .. n] do
		if clist[i] <> 0 then
            OMPutOMA( writer );    #times
				OMPutSymbol( writer, "arith1", "times" );
				OMPut(writer, clist[i]);
				OMPutApplication( writer, "algnums", "NthRootOfUnity", [ n, i-1 ] );
            OMPutEndOMA( writer ); #times
		fi;
	od;
	OMPutEndOMA( writer );
  fi;
end);


#######################################################################
##
#M  OMPut( <writer>, <transformation> )  
##
##  Printing for transformations : specified in permut1.ocd 
## 
InstallMethod(OMPut, "for a transformation", true,
[IsOpenMathWriter, IsTransformation],0,
function(writer, x)
	OMPutApplication( writer, "transform1", "transformation", 
	                  ImageListOfTransformation(x) );
end);


#######################################################################
##
#M  OMPut( <writer>, <semigroup> )  
##
InstallMethod(OMPut, "for a semigroup", true,
[IsOpenMathWriter, IsSemigroup],0,
function(writer, x)
	OMPutApplication( writer, "semigroup1", "semigroup_by_generators", 
		              GeneratorsOfSemigroup(x) );
end);


#######################################################################
##
#M  OMPut( <writer>, <monoid> )  
##
## 
InstallMethod(OMPut, "for a monoid", true,
[IsOpenMathWriter, IsMonoid],0,
function(writer, x)
	OMPutApplication( writer, "monoid1", "monoid_by_generators", 
		              GeneratorsOfMonoid(x) );
end);


#######################################################################
##
#M  OMPut( <writer>, <free group> )  
##
## 
InstallMethod(OMPut, "for a free group", true,
[IsOpenMathWriter, IsFreeGroup],0,
function(writer, f)
#	SetOMReference( f, Concatenation("freegroup", RandomString(16) ) );
#	OMWriteLine( writer, [ "<OMA id=\"", OMReference( f ), "\" >" ] );
    OMPutOMA( writer );
	OMPutSymbol( writer, "fpgroup1", "free_groupn" );
	OMPut( writer, Rank( f ) );
    OMPutEndOMA( writer );
end);


#######################################################################
##
#M  OMPut( <writer>, <FpGroup> )  
##
## 
InstallMethod(OMPut, "for an FpGroup", true,
[IsOpenMathWriter, IsFpGroup],0,
function(writer, g)
	local x;
#	SetOMReference( g, Concatenation( "fpgroup", RandomString(16) ) );
#	OMWriteLine( writer, [ "<OMA id=\"", OMReference( g ), "\" >" ] );
    OMPutOMA( writer );
		OMPutSymbol( writer, "fpgroup1", "fpgroup" );
		OMPutReference( writer, FreeGroupOfFpGroup( g ) );
		for x in RelatorsOfFpGroup( g ) do
			OMPut( writer, ExtRepOfObj( x ) );
		od;
    OMPutEndOMA( writer );
end);


#######################################################################
##
#M  OMPut( <writer>, <record> )  
##
##  There is no OpenMath representation for records, though this might
##  be done within standard using OMATTR. However, for better efficiency
##  we introduce private symbol for the record, as records are native
##  objects in many programming languages. 
##
##  To minimise the number of OM tags in the resulting OM code, the
##  record with N components will be encoded as a list of the length 
##  2*N where strings with component names will be on odd places and
##  corresponding values will be on even ones.
##
##  As a practical application of this, we consider transmitting 
##  graphs given as records in the Grape package format, which stores
##  extra information not included in the default OpenMath encoding
##  for graphs.
##   
InstallMethod(OMPut, "for a record", true,
[IsOpenMathWriter, IsRecord], 0 ,
function(writer, x )
    local r;
    OMPutOMA( writer );
	OMPutSymbol( writer, "record1", "record" );
	for r in RecNames(x) do
	   OMPut( writer, r );
	   OMPut( writer, x.(r) );
	od;
    OMPutEndOMA( writer );	   
end);


#######################################################################
##
#M  OMPut( <writer>, <group> )  
##
##  Printing for groups as in openmath/cds/group1.ocd (Note that it 
##  differs from group1.group from the group1 CD at http://www.openmath.org,
##  since we just output the list of generators)
## 
InstallMethod(OMPut, "for a group", true,
[IsOpenMathWriter, IsGroup],0,
function(writer, x)
	OMPutApplication( writer, "group1", "group_by_generators", 
		GeneratorsOfGroup(x) );
end);


#######################################################################
##
#M  OMPut( <writer>, <pcgroup> )  
##
##  Printing for pcgroups as pcgroup1.pcgroup_by_pcgscode:
##  the 1st argument is pcgs code of the group, the 2nd is
##  its order. Note that OMTest will return fail in this
##  case, since the result of parsing the output will be
##  an isomorphic group but not equal to the original one.
## 
InstallMethod(OMPut, "for a pcgroup", true,
[IsOpenMathWriter, IsPcGroup],0,
function(writer, x)
    OMPutOMA( writer );
	OMPutSymbol( writer, "pcgroup1", "pcgroup_by_pcgscode" );
    OMPut( writer, CodePcGroup(x) );
	OMPut( writer, Size(x) );
    OMPutEndOMA( writer );	
end);


#######################################################################
##
#M  OMPut( <writer>, <subgroup lattice> )  
##
## 
InstallMethod(OMPut, "for a lattice of subgroups", true,
[IsOpenMathWriter, IsLatticeSubgroupsRep],0,
function(writer, L)
  local cls, sz, len, i, levels, j, class, max, levelnr, rep, k, z, t, 
        nr, class_size;
	
  cls:=ConjugacyClassesSubgroups(L);
  # set of orders of subgroups that appear in the group
  sz:=[];
  len:=[];
  for i in cls do
    Add(len,Size(i));
    AddSet(sz,Size(Representative(i)));
  od;
  # reverse it so G comes first, {1} last
  sz:=Reversed(sz);
   
  # create a list of records describing levels 
  levels := [];
  for i in [ 1 .. Length(sz) ] do
    levels[i] := rec( index := sz[1]/sz[i], classes:=rec() );
  od;

  # populate levels with classes
  for i in [1..Length(cls)] do
    class := rec( number := i, vertices := List( [1..len[i]], j -> [] ) );
	levels[ Position(sz,Size(Representative(cls[i]))) ].classes.(Concatenation("nr",String(i))) := class;
  od;
  
#  label:=0;
#  # assign labels
# for i in [ Length(sz), Length(sz)-1  .. 2 ] do
#   for nr in RecNames( levels[i].classes ) do
#     levels[i].classes.(nr).labels:=[];
#     for j in [ 1 .. Length( levels[i].classes.(nr).vertices) ] do
#       label:=label+1;   
#       Add( levels[i].classes.(nr).labels, String(label) );
#      od; 
#   od;
# od;   
# levels[1].classes.(RecNames( levels[1].classes )[1]).labels:=["G"];
  
  max:=MaximalSubgroupsLattice(L);
  for i in [1..Length(cls)] do
    levelnr := Position(sz,Size(Representative(cls[i])));
    for j in max[i] do
      rep:=ClassElementLattice(cls[i],1);
      for k in [1..len[i]] do
	    if k=1 then
	      z:=j[2];
	    else
	      t:=cls[i]!.normalizerTransversal[k];
	      z:=ClassElementLattice(cls[j[1]],1); # force computation of transv.
	      z:=cls[j[1]]!.normalizerTransversal[j[2]]*t;
	      z:=PositionCanonical(cls[j[1]]!.normalizerTransversal,z);
	    fi;
	    Add( levels[levelnr].classes.(Concatenation("nr",String(i))).vertices[k], [ j[1], z ] );
      od;
    od;
  od;
	
  OMPutOMA( writer );
  OMPutSymbol( writer, "poset1", "poset_diagram" );
    for i in [ 1 .. Length(levels) ] do
      OMPutOMA( writer );
      OMPutSymbol( writer, "poset1", "level" );
      OMPut( writer, levels[i].index );
      OMPutOMA( writer );
      OMPutSymbol( writer, "list1", "list" );         
      for nr in RecNames( levels[i].classes ) do
        OMPutOMA( writer );
        OMPutSymbol( writer, "poset1", "class" );     
        OMPutOMA( writer );
        OMPutSymbol( writer, "list1", "list" );   
        class_size := Length( levels[i].classes.(nr).vertices );
        for j in [ 1 .. class_size ] do
          OMPutOMA( writer );
          OMPutSymbol( writer, "poset1", "vertex" );  
          if i = 1 then
            OMPut( writer, "G" );
          elif class_size = 1 then
            OMPut( writer, String( levels[i].classes.(nr).number ) );    
          else
            OMPut( writer, Concatenation( String( levels[i].classes.(nr).number ), ".", String(j) ) );    
          fi;
          if Length( levels[i].classes.(nr).vertices[j] ) > 0 then
            OMPutOMA( writer );
            OMPutSymbol( writer, "list1", "list" );  
            for k in levels[i].classes.(nr).vertices[j] do
              if len[k[1]] = 1 then
                OMPut( writer, String( k[1] ) );    
              else
                OMPut( writer, Concatenation( String( k[1] ), ".", String( k[2] ) ) );    
              fi;            
            od;
			OMPutEndOMA( writer );  
          else
          	OMPutSymbol( writer, "set1", "emptyset" );  
          fi;       
		  OMPutEndOMA( writer );           
        od;
		OMPutEndOMA( writer );  
		OMPutEndOMA( writer );  
      od;
	  OMPutEndOMA( writer );  
	  OMPutEndOMA( writer ); 
    od;
    OMPutEndOMA( writer ); 
end);


#######################################################################
## 
## Experimental methods for OMPut for character tables"
##
#######################################################################
##
#F  OMIrredMatEntryPut( <writer>, <entry>, <data> )
##
##  <entry> is a (possibly unknown) cyclotomic
##  <data> is the record of information about names and values
##  used to substitute for complicated irreducible expressions.
##
##  This borrows heavily from Thomas Breuer's 
##  CharacterTableDisplayStringEntryDefault
##
BindGlobal("OMIrredMatEntryPut", function(writer, entry, data)
	local val, irrstack, irrnames, name, ll, i, letters, n;

  # OMPut(writer,entry);
	if IsCyc( entry ) and not IsInt( entry ) then
      # find shorthand for cyclo
      irrstack:= data.irrstack;
      irrnames:= data.irrnames;
      for i in [ 1 .. Length( irrstack ) ] do
        if entry = irrstack[i] then
          OMPutVar(writer, irrnames[i]);
					return;
        elif entry = -irrstack[i] then
                    OMPutOMA( writer );
					OMPutSymbol(writer, "arith1", "unary_minus");
          OMPutVar(writer, irrnames[i]);
                    OMPutEndOMA( writer ); 
					return;
        fi;
        val:= GaloisCyc( irrstack[i], -1 );
        if entry = val then
                    OMPutOMA( writer );
					OMPutSymbol(writer, "complex1", "conjugate");
          OMPutVar(writer, irrnames[i]);
                    OMPutEndOMA( writer ); 
					return;
        elif entry = -val then
                    OMPutOMA( writer );
					OMPutSymbol(writer, "arith1", "unary_minus");
                    OMPutOMA( writer );
					OMPutSymbol(writer, "complex1", "conjugate");
          OMPutVar(writer, irrnames[i]);
                    OMPutEndOMA( writer ); 
                    OMPutEndOMA( writer ); 
					return;
        fi;
        val:= StarCyc( irrstack[i] );
        if entry = val then
                    OMPutOMA( writer );
					OMPutSymbol(writer, "algnums", "star");
          OMPutVar(writer, irrnames[i]);
                    OMPutEndOMA( writer ); 
					return;
        elif -entry = val then
                    OMPutOMA( writer );
					OMPutSymbol(writer, "arith1", "unary_minus");
                    OMPutOMA( writer );
					OMPutSymbol(writer, "algnums", "star");
          OMPutVar(writer, irrnames[i]);
                    OMPutEndOMA( writer ); 
                    OMPutEndOMA( writer ); 
					return;
        fi;
        i:= i+1;
      od;
      Add( irrstack, entry );

      # Create a new name for the irrationality.
      name:= "";
      n:= Length( irrstack );
      letters:= data.letters;
      ll:= Length( letters );
      while 0 < n do
        name:= Concatenation( letters[(n-1) mod ll + 1], name );
        n:= QuoInt(n-1, ll);
      od;
      Add( irrnames, name );
      OMPutVar(writer, irrnames[ Length( irrnames ) ]);
			return;

		elif IsUnknown( entry ) then
			OMPutVar(writer, "?"); 
			return;
		else
			OMPut(writer, entry);
			return;
		fi;

end);


#######################################################################
##
#F  OMPutIrredMat( <writer>, <x> )
##
##  <x> is a character table
##
##  This borrows heavily from Thomas Breuer's 
##  character table Display routines -- see lib/ctbl.gi
##
BindGlobal("OMPutIrredMat", function(writer, x)
	local r,i, irredmat, data;

	data := CharacterTableDisplayStringEntryDataDefault( x );
  # irreducibles matrix
  irredmat :=  List(Irr(x), ValuesOfClassFunction);

	# OMPut(writer,irredmat);

  OMPutOMA( writer );

  OMPutSymbol( writer, "linalg2", "matrix" );
  for r in irredmat do
      OMPutOMA( writer );
      OMPutSymbol( writer, "linalg2", "matrixrow" );
      for i in r do
      		OMIrredMatEntryPut(writer, i, data);
      od;
      OMPutEndOMA( writer ); 
  od;

  OMPutEndOMA( writer ); 

	# Now output the list of (variable = value) pairs
    OMPutOMA( writer );
	OMPutSymbol(writer, "list1", "list");
	for i in [1 .. Length(data.irrstack)] do
        OMPutOMA( writer );
		OMPutSymbol(writer, "relation1", "eq");
		OMPutVar(writer, data.irrnames[i]);
		OMPut(writer, data.irrstack[i]);
        OMPutEndOMA( writer ); 
	od;
    OMPutEndOMA( writer ); 

end);



#######################################################################
##
#M  OMPut( <writer>, <character table> )  
##
##
InstallMethod(OMPut, "for a character table", true,
[IsOpenMathWriter, IsCharacterTable],0,
function(writer, c)
	local
		centralizersizes,
		centralizerindices,
		centralizerprimes,
		ordersclassreps,
		sizesconjugacyclasses,
		classnames,
		powmap;

  # the centralizer primes
  centralizersizes := SizesCentralizers(c);
  centralizerprimes := AsSSortedList(Factors(Product(centralizersizes)));

  # the indices which define the factorisation of the
  # centralizer orders
  centralizerindices := List(centralizersizes, z->
    List(centralizerprimes, x->Size(Filtered(Factors(z), y->y=x))));

	# ordersclassreps - every element of a conjugacy class has
	# the same order.
  ordersclassreps := OrdersClassRepresentatives( c );

	# SizesConjugacyClasses
	sizesconjugacyclasses := SizesConjugacyClasses( c );

  # the classnames
  classnames := ClassNames(c);

  # the powermap
  powmap := List(centralizerprimes,
    x->List(PowerMap(c, x),z->ClassNames(c)[z]));

  # irreducibles matrix
  # irredmat :=  List(Irr(c), ValuesOfClassFunction);

  OMPutOMA( writer );
  	OMPutSymbol( writer, "group1", "character_table" );
	OMPutList(writer, classnames);
	OMPutList(writer, centralizersizes);
	OMPutList(writer, centralizerprimes);
	OMPutList(writer, centralizerindices); 
	OMPutList(writer, powmap);
	OMPutList(writer, sizesconjugacyclasses);
	OMPutList(writer, ordersclassreps);
	# OMPut(writer, irredmat); # previous cd version
	OMPutIrredMat(writer, c);
  OMPutEndOMA( writer );
end);

#############################################################################
#E
