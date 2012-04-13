#############################################################################
##
#W  basicim.gi			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##


#############################################################################
#############################################################################
##
##  Creating groups and elements
##
#############################################################################
#############################################################################

#############################################################################
##
#M  IsGeneratorsOfMagmaWithInverses( <> )
##
InstallTrueMethod( IsGeneratorsOfMagmaWithInverses, IsBasicImageEltRepCollection );

#############################################################################
##
#F  ConvertToSiftGroup( <G>, <orbitGens>, <homFromFree> )
##
InstallGlobalFunction( ConvertToSiftGroup, 
    function( G, orbitGens, homFromFree )
	local freeGens, WordHomCoset, convG, transv, newTransv, backPntr, key, tmp;

	freeGens := GeneratorsOfGroup( Source( homFromFree ) );

	WordHomCoset := function( sgen )
	    local ret;
	    
	    ret := HomCoset( homFromFree, freeGens[ Position( orbitGens, sgen ) ] );
	    SetImageElt( ret, sgen );
	    return ret;
	end;

	if IsEmpty( GeneratorsOfGroup( G ) ) then
	    convG := TrivialSubgroup( G );
	else
	    convG := Group( GeneratorsOfGroup( G ) );
	fi;
	UseIsomorphismRelation( convG, G );
	if not HasChainSubgroup( G ) then
	    return convG;  # base of recursion
        fi;
	if HasTransversal( ChainSubgroup( G ) ) and 
	   IsTransvBySchreierTree( TransversalOfChainSubgroup( G ) ) then
	    transv := TransversalOfChainSubgroup( G );
	    newTransv := SchreierTransversal( 
		BasePointOfSchreierTransversal( transv ), transv!.Action,
                transv!.StrongGenerators );
	else
	    Error( "Not a stabiliser chain" );
	fi;

	newTransv!.OrbitGenerators := List( transv!.OrbitGenerators, WordHomCoset );
	for key in Iterator( transv!.HashTable ) do
	    backPntr := GetHashEntry( transv!.HashTable, key );
	    if backPntr = 0 then
		AddHashEntry( newTransv!.HashTable, key, 0 );
	    else
		AddHashEntry( newTransv!.HashTable, key, WordHomCoset( backPntr^(-1) ) );
	    fi;
	od;
	Info( InfoBasicImage, 2, "transversal ", newTransv );

	SetChainSubgroup( convG, ConvertToSiftGroup( ChainSubgroup( G ), orbitGens, homFromFree ) ); # recursion
	SetTransversal( ChainSubgroup( convG ), newTransv );

	return convG;
    end );



#############################################################################
##
#F  BasicImageGroup( <G> )
##
InstallGlobalFunction( BasicImageGroup, 
    function( G )
	local base, orbitGens, freeGroup, homFromFree, siftGroup, tmp, gens, 
	     sbG, chainG, transv, newTransv, key, backPntr;

	base := BaseOfGroup( G );
	orbitGens := OrbitGeneratorsOfGroup( G );
	freeGroup := FreeGroup( Length( orbitGens ) );
	homFromFree := GroupHomomorphismByImagesNC( freeGroup, G,
	    			orbitGens, GeneratorsOfGroup( freeGroup ) );
	siftGroup := ConvertToSiftGroup( G, orbitGens, homFromFree );
	Info( InfoBasicImage, 3, "base ", base, ", orbit generators ", orbitGens,
				"\nhom ", homFromFree );

	gens := List( GeneratorsOfGroup( G ), 
		      gen -> BasicImageGroupElement( siftGroup, homFromFree, orbitGens, gen ) );
	Info( InfoBasicImage, 2, "gens ", gens );
	sbG := Group( gens );
	chainG := sbG;
	
	repeat
	    gens := List( GeneratorsOfGroup( ChainSubgroup( G ) ), 
		      gen -> BasicImageGroupElement( siftGroup, homFromFree, orbitGens, gen ) );
	    if IsEmpty( gens ) then
		gens := One( chainG );
	    fi;

	    SetChainSubgroup( chainG, Group( gens ) );
	    transv := TransversalOfChainSubgroup( G );
	    newTransv := SchreierTransversal( 
		BasePointOfSchreierTransversal( transv ), transv!.Action,
                transv!.StrongGenerators );

	    newTransv!.OrbitGenerators := List( transv!.OrbitGenerators, 
		      gen -> BasicImageGroupElement( siftGroup, homFromFree, orbitGens, gen ) );
	    for key in Iterator( transv!.HashTable ) do
	    	backPntr := GetHashEntry( transv!.HashTable, key );
	    	if backPntr = 0 then
		    AddHashEntry( newTransv!.HashTable, key, 0 );
	    	else
		    AddHashEntry( newTransv!.HashTable, key, 
		  	 BasicImageGroupElement( siftGroup, homFromFree, orbitGens, backPntr ) );

	        fi;
	    od;
	    SetTransversal( ChainSubgroup( chainG ), newTransv );

	    SetOrbitGeneratorsOfGroup( chainG, orbitGens );
	    SetBaseOfBasicImageGroup( chainG, base );
	    SetFreeGroupOfBasicImageGroup( chainG, freeGroup );
	    SetSiftGroup( chainG, siftGroup );
	    SetHomFromFreeOfBasicImageGroup( chainG, homFromFree );

	    chainG := ChainSubgroup( chainG );
	    G := ChainSubgroup( G );
	until IsTrivial( G );	    

   	return sbG;
     end );

#############################################################################
##
#M  BasicImageGroupElement( <word>, <base>, <baseImage>, <orbitGenerators>, 
#M	<homFromFree> )
##
InstallMethod( BasicImageGroupElement, "for basic image group elt", true,
    [ IsWordWithInverse, IsList, IsList, IsList, IsGroupHomomorphism ], 0, 
    function( word, base, baseImage, orbitGenerators, homFromFree )
        local Type, Rec;
	Type := NewType( BasicImageEltRepFamily, IsBasicImageEltRep );
	Rec := rec( Word := word, Base := base, BaseImage := baseImage,
		    OrbitGenerators := orbitGenerators, HomFromFree := homFromFree );
	return Objectify( Type, Rec );
    end );

#############################################################################
##
#M  BasicImageGroupElement( <G>, <g> )
##
InstallMethod( BasicImageGroupElement, "for basic image group elt", true,
    [ IsBasicImageGroup, IsAssociativeElement ], 0, 
    function( G, g )
	return BasicImageGroupElement( SiftGroup( G ), HomFromFreeOfBasicImageGroup( G ), 
		OrbitGeneratorsOfGroup( G ), g );
    end );

#############################################################################
##
#M  BasicImageGroupElement( <siftGroup>, <homFromFree>, <orbitGens>, <g> )
##
InstallMethod( BasicImageGroupElement, "for basic image group elt", true,
    [ IsGroup and HasChainSubgroup, IsGroupHomomorphism, IsList, IsAssociativeElement ], 0, 
    function( siftGroup, homFromFree, orbitGens, g )
        local hcoset, word, base, baseImage, Type, Rec;

	hcoset := HomCoset( homFromFree, One( Source( homFromFree ) ) );
	SetImageElt( hcoset, g );
        hcoset := Sift( siftGroup, hcoset );
	
	word := SourceElt( hcoset )^(-1);
	base := BaseOfGroup( siftGroup );
	baseImage := List( base, b -> b^g );

	Type := NewType( BasicImageEltRepFamily, IsBasicImageEltRep );
	Rec := rec( Word := word, Base := base, BaseImage := baseImage,
		    OrbitGenerators := orbitGens, HomFromFree := homFromFree );
	return Objectify( Type, Rec );
    end );



#############################################################################
#############################################################################
##
##  Properties of basic image elements
##
#############################################################################
#############################################################################

#############################################################################
##
#M  Word( <elt> )
##
InstallMethod( Word, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0, elt -> elt!.Word );

#############################################################################
##
#M  BaseOfElt( <elt> )
##
##  
##
InstallMethod( BaseOfElt, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0, elt -> elt!.Base );

#############################################################################
##
#M  BaseImage( <elt> )
##
##  
##
InstallMethod( BaseImage, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0, elt -> elt!.BaseImage );

#############################################################################
##
#M  OrbitGenerators( <elt> )
##
##  
##
InstallMethod( OrbitGenerators, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0, elt -> elt!.OrbitGenerators );

#############################################################################
##
#M  HomFromFree( <elt> )
##
##  
##
InstallMethod( HomFromFree, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0, elt -> elt!.HomFromFree );

#############################################################################
##
#M  FreeGroupOfElt( <elt> )
##
##  
##
InstallMethod( FreeGroupOfElt, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0, elt -> Source( elt!.HomFromFree ) );

#############################################################################
##
#M  ViewObj( <elt> )
##
##  
##
InstallMethod( ViewObj, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0,
    function( elt )
        Print("( ");
	ViewObj( Word( elt ) ); Print(", ");
	ViewObj( BaseImage( elt ) ); Print(" )");
    end );

#############################################################################
##
#M  PrintObj( <elt> )
##
##  
##
InstallMethod( PrintObj, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0,
    function( elt )
	Print( "( ", Word( elt ), ", ", BaseImage( elt ), " )" );
    end );


#############################################################################
#############################################################################
##
##  Conversion to ordinary element
##
#############################################################################
#############################################################################

#############################################################################
##
#M  ConvertBasicImageGroupElement( <sb> )
##
InstallMethod( ConvertBasicImageGroupElement, "for basic image elt", true,
    [ IsBasicImageEltRep ], 0, 
    function( sb )
	local freeGens, ret, i, term;

	freeGens := GeneratorsOfGroup( Source( HomFromFree( sb ) ) );
	ret := One( Range( HomFromFree( sb ) ) );
	for i in [1..Length( Word( sb ) )] do
	    term := Subword( Word( sb ), i, i );
	    if term in freeGens then
		ret := ret * OrbitGenerators( sb )[ Position( freeGens, term ) ];
	    else
		ret := ret * OrbitGenerators( sb )[ Position( freeGens, term^(-1) ) ]^(-1);
	    fi;
     	od;
	return ret;
    end );	    

#############################################################################
#############################################################################
##
##  Basic operations
##
#############################################################################
#############################################################################

#############################################################################
##
#M  EQ( <elt1>, <elt2> )
##
InstallMethod( EQ, "for basic image group elts", true,
    [ IsBasicImageEltRep, IsBasicImageEltRep ], 0,
    function( elt1, elt2 )
        return  EQ( BaseImage(elt1), BaseImage(elt2) );
    end );

#############################################################################
##
#M  LT( <elt1>, <elt2> )
##
InstallMethod( LT, "for basic image group elts", true,
    [ IsBasicImageEltRep, IsBasicImageEltRep ], 0,
    function( elt1, elt2 )
    	return LT( BaseImage(elt1), BaseImage(elt2) );
    end );

#############################################################################
##
#M  ONE( <elt> )
##
InstallMethod( ONE, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0,
    function( elt )
	return BasicImageGroupElement( 
	    One( FreeGroupOfElt( elt ) ), BaseOfElt( elt ), BaseOfElt( elt ), 
	    OrbitGenerators( elt ), HomFromFree( elt ) );
    end );
#############################################################################
##
#M  One( <elt> )
##
InstallMethod( One, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0,
    function( elt )
	return BasicImageGroupElement( 
	    One( FreeGroupOfElt( elt ) ), BaseOfElt( elt ), BaseOfElt( elt ), 
	    OrbitGenerators( elt ), HomFromFree( elt ) );
    end );


#############################################################################
##
#M  PROD( <elt1>, <elt2> )
##
InstallMethod( PROD, "for basic image group elts", true,
    [ IsBasicImageEltRep, IsBasicImageEltRep ], 0, 
    function( elt1, elt2 )
	return BasicImageGroupElement(
	    Word(elt1) * Word(elt2), BaseOfElt(elt1), 
	    ImageUnderWord( BaseImage(elt1), Word(elt2), 
		OrbitGenerators(elt1), HomFromFree( elt1 ) ),
	    OrbitGenerators( elt1 ), HomFromFree( elt1 ) );
    end );

#############################################################################
##
#M  INV( <elt> )
##
InstallMethod( INV, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0,
    function( elt )
	return BasicImageGroupElement(
	    Word(elt)^(-1), BaseOfElt(elt), 
	    ImageUnderWord( BaseImage(elt), Word(elt)^(-1), 
		OrbitGenerators(elt), HomFromFree(elt) ),
	    OrbitGenerators(elt), HomFromFree(elt) );
    end );
#############################################################################
##
#M  Inverse( <elt> )
##
InstallMethod( Inverse, "for basic image group elt", true,
    [ IsBasicImageEltRep ], 0,
    function( elt )
	return BasicImageGroupElement(
	    Word(elt)^(-1), BaseOfElt(elt), 
	    ImageUnderWord( BaseImage(elt), Word(elt)^(-1), 
		OrbitGenerators(elt), HomFromFree(elt) ),
	    OrbitGenerators(elt), HomFromFree(elt) );
    end );

#############################################################################
##
#M  QUO( <elt1>, <elt2> )
##
InstallMethod( QUO, "for basic image group elts", true,
    [ IsBasicImageEltRep, IsBasicImageEltRep ], 0,
    function( elt1, elt2 )
	return BasicImageGroupElement(
	    Word(elt1) * Word(elt2)^(-1), BaseOfElt(elt1), 
	    ImageUnderWord( BaseImage( elt1 ), Word( elt2 )^(-1), 
		OrbitGenerators(elt1), HomFromFree( elt1 ) ),
	    OrbitGenerators( elt1 ), HomFromFree( elt1 ) );
    end );

#############################################################################
##
#M  POW( <elt1>, <elt2> )
##
InstallMethod( POW, "for basic image group elts", true,
    [ IsBasicImageEltRep, IsBasicImageEltRep ], 1,
    function( elt1, elt2 )
        return elt2 * elt1 * elt2^(-1); # is there a more efficient way
    end );

#############################################################################
##
#M  POW( <elt>, <int> )
##
InstallMethod( POW, "for basic image group elt and integer", true,
    [ IsBasicImageEltRep, IsInt ], 1,
    function( elt, int )
        return  BasicImageGroupElement(
	    Word(elt)^int, BaseOfElt(elt), 
	    ImageUnderWord( BaseOfElt(elt), Word(elt)^int, 
		OrbitGenerators(elt), HomFromFree(elt) ),
	    OrbitGenerators( elt ), HomFromFree( elt ) );
    end );

#############################################################################
##
#M  POW( <int>, <elt> )
##
InstallMethod( POW, "for integer and basic image group elt", true,
    [ IsInt, IsBasicImageEltRep ], 1,
    function( int, elt )
	if int in BaseOfElt( elt ) then
	    return BaseImage(elt)[ Position( BaseOfElt( elt ), int ) ];
	else
	    return ImageUnderWord( int, Word( elt ),
		OrbitGenerators(elt), HomFromFree(elt) );
	fi;
    end );

#############################################################################
##
#M  COMM( <elt1>, <elt2> )
##
InstallMethod( COMM, "for basic image group elts", true,
    [ IsBasicImageEltRep, IsBasicImageEltRep ], 0,
    function( elt1, elt2 )
        return elt1 * elt2 * elt1^(-1) * elt2^(-1); # is there a more efficient way
    end );


#############################################################################
#############################################################################
##
##  Computing presentations
##
#############################################################################
#############################################################################

#############################################################################
##
#M  Presentation( <G> )
##
InstallMethod( Presentation, "for chain type groups", true,
    [ IsGroup and IsChainTypeGroup ], 0,
    function( G )
     	local sbG, transv, pres, gen, elt;

    	RandomSchreierSims( G ); # make point stabilizer chain for G
    	sbG := BasicImageGroup( G );    

    	pres := [];
    	while not IsTrivial( G ) do
            transv := Enumerator( TransversalOfChainSubgroup( G ) );
	    for gen in GeneratorsOfGroup( G ) do
	    	for elt in transv do
		    Add( pres,
			Word( BasicImageGroupElement( sbG, elt ) ) *
			Word( BasicImageGroupElement( sbG, gen ) ) *
			Word( BasicImageGroupElement( sbG, (elt*gen)^(-1)  ) ) );
		od;
	    od;
	    G := ChainSubgroup( G );
    	od;

	return FreeGroupOfBasicImageGroup( sbG ) / pres;
    end );

#E