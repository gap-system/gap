#############################################################################
##
#W  rss.gi			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id: rss.gi,v 4.6 2002/04/15 10:05:15 sal Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##
##   We use the options stack.  Possible options include:
##   
##   Random( G, S, opt ): the function used to generate random 
##	elements.  This may be set by the user, otherwise it will 
##	be set by InitRSS.
##   StoppingCondition( G, S, opt ): the stopping condition function.
##	This may be set by the user, otherwise it will be set by 
##	InitRSS.
##   NewBasePoint( G, S, opt ): the function used to produce new base
##	points.  This may be set by the user, otherwise it will be set by 
##	InitRSS.
##   newBasePoints: can be set by the user to specify which base points to 
##	use.  For matrix groups, just give vectors and the program will 
##	automatically alternate 1D subspace/vector.
##   numsift: total number of sifts.
##   numsiftto1: number of consecutive elements sifted to 1.
##
##  We probably should not be using the option stack in this way.
##  We will implement a better way of dealing with options in the next 
##  version.
##
##  Requires: chain, eigen
##  Exports: functions RandomSchreierSims and ChangedBaseGroup
##
Revision.rss_gi :=
    "@(#)$Id: rss.gi,v 4.6 2002/04/15 10:05:15 sal Exp $";


#############################################################################
#############################################################################
##
##  Functions to modify the options stack
##
#############################################################################
#############################################################################

#############################################################################
##
#F  SetValueOption( <fieldname>, <value> )
##
InstallGlobalFunction( SetValueOption,
function( fieldname, value )
    OptionsStack[ Length(OptionsStack) ].(fieldname) := value;
end );

#############################################################################
##
#F  ReturnPopOptions( <> )
##
InstallGlobalFunction( ReturnPopOptions,
function()
    local opt;
    opt := OptionsStack[ Length(OptionsStack) ];
    PopOptions();
    return opt;
end );


#############################################################################
#############################################################################
##
##   Random Schreier-Sims
##
#############################################################################
#############################################################################


#############################################################################
##
#F  RandomSchreierSims( <> )
##
InstallGlobalFunction( RandomSchreierSims,
function( G )
    local g, origG, tmp, numConsecSiftedTo1;

    if IsTrivial( G ) then return G; fi;
    # gdc - hack to avoid cost of computing field size in KeyIntSparse()
#    if IsFFEMatrixGroup( G ) then
#        FIELD_SIZE := Size(FieldOfMatrixGroup(G));
#    else FIELD_SIZE := -1;
#    fi;

    # gdc - There's a problem here.  If you interrupt a routine in
    #       the middle, the options stay on the stack, and are
    #       invoked the next time RandomSchreierSims() is called.
    #       This way, we allow stale options only if it's for the same group.
    #       In general, ValueOption() is just a global variable, and
    #       should be used only if using global variables is okay.
    if ValueOption( "RandomSchreierSimsOpt" ) <> fail and
       IsIdenticalObj( ValueOption( "Group" ), G ) then
	PushOptions( RSSDefaultOptions( G, ReturnPopOptions() ) );
    else
	PushOptions( RSSDefaultOptions( G, rec() ) );
    fi;

    # gdc - Scott, GetNewSiftee() had a bug if RandomSchreierSims()
    #  was interrupted while ValueOption("newsiftees") still existed,
    #  and the next call was to a different group.
    # In general, ValueOption(), should be completely re-initialized
    #  when starting RandomSchreierSims().  I removed GetNewSiftee(), since
    #  the 8 extra lines below do the same thing (and 2 lines are Info's).
    origG := G;
    for g in GeneratorsOfGroup(G) do
	Info( InfoRSS, 4, "newsiftee: generator ", g );
  	G := SiftForStrongGenerator( G, g )[1];
    od;

    # gdc - This used to be above sifting of strong gen's.
    #       Isn't that a bug?
    Info( InfoRSS, 1, "generators sifted, sifting random elements" );
    SetGeneratingSetIsComplete( G, true );

    numConsecSiftedTo1 := 0;
    while not ValueOption( "StoppingCondition" )( G ) do
        Info( InfoRSS, 4, "newsiftee: random ", g );
        # gdc - heuristic:  By numCons... = 3, probably have strong gen. set.
        if numConsecSiftedTo1 = 3 then
            Info( InfoRSS, 1, "completing transversals" );
            CompleteChain(G);
        fi;
        repeat g := ValueOption( "Random" )();
        until not IsOne( g );
  	tmp := SiftForStrongGenerator( G, g );
        G := tmp[1];
        if IsOne(tmp[2]) then
            numConsecSiftedTo1 := numConsecSiftedTo1 + 1;
##  if Set( Enumerator( TransversalOfChainSubgroup(G)!.HashTable ) )
##     <> Set( List( Enumerator( TransversalOfChainSubgroup(G)!.HashTable ), i->i^g ) )
##      and numConsecSiftedTo1 > 5 then
##  Print("WARNING: orbit should have been extended\n");
##  fi;
        else numConsecSiftedTo1 := 0;
        fi;
        # gdc - We shouldn't be using ValueOption() for this.
        #       We could pass it directly to "StoppingCondition".
        SetValueOption( "numConsecSiftedTo1", numConsecSiftedTo1 );
        Info( InfoRSS, 3, "Statistics:  ", ChainStatistics(G) );
        Info( InfoRSS, 2, "numConsecSiftedTo1:  ", numConsecSiftedTo1 );
    od;

    # Transversals may still have holes, although more than half pts reached
    # CompleteChain(G) already called at numConsecSiftedTo1 = 3
    # Info( InfoRSS, 1, "completing transversals" );
    # CompleteChain( G );

    PopOptions();

    # gdc - This needs to be cleaned up.
    origG!.ChainSubgroup := G!.ChainSubgroup;
#    SetSize(origG, Size(G));
    return origG;
end );


#############################################################################
#############################################################################
##
##   Base change
##
#############################################################################
#############################################################################

#############################################################################
##
#F  ChangedBaseGroup( <> )
##
InstallGlobalFunction( ChangedBaseGroup,
function( G, newBase )
    local H;

    H := Group( ShallowCopy ( GeneratorsOfGroup( G ) ) );
    SetSize( H, Size( G ) );
    
    return RandomSchreierSims( H :
	RandomSchreierSimsOpt,
        newBasePoints := newBase,
    	strictBaseOrder,
    	Random := function() return Random( G ); end,
	StoppingCondition := StopSize );
end );


#############################################################################
#############################################################################
##
##  Initialisation
##
#############################################################################
#############################################################################

#############################################################################
##
#F  RSSDefaultOptions( <G>, <opt> )
##
InstallGlobalFunction( RSSDefaultOptions,
function( G, opt )
    local S, gens, G2, ShadowNewBasePoint;

    Info( InfoRSS, 2, "Initialising");
    opt.RandomSchreierSimsOpt := true;
    opt.Group := G;
    if not IsBound( opt.Random ) then
	opt.Random := function()
            # GAP does only one prod. replacement.  Guarantee more randomness:
            PseudoRandom( G );
	    return PseudoRandom( G );
	end;
    fi;
    if not IsBound( opt.StoppingCondition ) then
	if HasSize( G ) then
	    opt.StoppingCondition := StopSize( Size(G) );
	else
	    opt.StoppingCondition := StopNumConsecSiftToOne(10);
	fi;
    fi;
    opt.numSifted := 0;
    opt.numConsecSiftedTo1 := 0;

    if not IsBound( opt.NewBasePoint ) then
	if IsPermGroup( G ) then
	    opt.NewBasePoint := PermNewBasePoint;
	elif IsFFEMatrixGroup( G ) then
	    opt.NewBasePoint := MatrixNewBasePoint;
	else
	    opt.NewBasePoint := fail;
	fi;
    fi;

    opt.newBasePoints := [];
    Unbind(opt.lastVec);
   
    return opt;
end );



#############################################################################
#############################################################################
##
##  Sifting
##
#############################################################################
#############################################################################

#############################################################################
##
#F  SiftForStrongGenerator( <G>, <newsg> )
##
InstallGlobalFunction( SiftForStrongGenerator,
function( G, newsg )
    local sifted, newBasePoint, tmp;

    Info( InfoRSS, 3, "sifting ", newsg, " into group" );

    if IsOne( newsg ) then return [G, newsg]; fi; # base of recursion

    if not HasChainSubgroup( G ) then
	tmp := ValueOption( "NewBasePoint" )( G, newsg );
        ChainSubgroupByStabiliser( G, tmp[1], tmp[2] );
    fi;

    sifted := SiftOneLevel( G, newsg );

##if HasChainSubgroup(G) and not IsOne(sifted) and IsTrivial(G) then Error("triv2"); fi;

    if sifted = fail then
        G := ExtendedGroup( G, newsg );
	SetValueOption( "numConsecSiftedTo1", 0 );
        SetValueOption( "numSifted", ValueOption( "numSifted" ) + 1 );
	return [ G, newsg ];
    elif IsOne( sifted ) then
        SetValueOption( "numConsecSiftedTo1",
                        ValueOption( "numConsecSiftedTo1" ) + 1 );
        SetValueOption( "numSifted", ValueOption( "numSifted" ) + 1 );
        return [ G, sifted ];
    elif HasChainSubgroup( G ) and not IsOne( sifted ) then
##if IsTrivial(ChainSubgroup(G)) then Error("triv1"); fi;
	tmp := SiftForStrongGenerator( ChainSubgroup( G ), sifted );
##This happens if base point of tmp[1] isn't moved, but sifted non-trivial:
##if IsTrivial(tmp[1]) then Error("trivial chain"); fi;
##TMP2 := tmp;
	G!.ChainSubgroup := tmp[1];
        sifted := tmp[2];
        # if not IsOne(sifted) then 
	#     G := ExtendedGroup( G, sifted ); 
	# fi;
	return [ G, sifted ];
    else 
	Error("Internal error : chain was created for non-triv newsg");
    fi;
end );			

#############################################################################
#############################################################################
##
##  Stopping conditions
##
#############################################################################
#############################################################################

#############################################################################
##
#F  StopNumConsecSiftToOne( <n> )
##
InstallGlobalFunction( StopNumConsecSiftToOne,
function( n )
    return function( G )
	return ValueOption( "numConsecSiftedTo1" ) > n;
    end;
end );

#############################################################################
##
#F  StopNumSift( <n> )
##
InstallGlobalFunction( StopNumSift,
function( n )
    return function( G )
	return ValueOption( "numSifted" ) > n;
    end;
end );

#############################################################################
##
#F  StopSize( <size> )
##
InstallGlobalFunction( StopSize,
function ( size )
    return function( G )
        if HasChainSubgroup( G ) and SizeOfChainOfGroup( G ) > size then
	    Error("Given size of G is incorrect\n");
	fi;
	return SizeOfChainOfGroup( G ) = size;
    end;
end );


#############################################################################
#############################################################################
##
##  NewBasePoint functions
##
#############################################################################
#############################################################################

#############################################################################
##
#F  ReturnNextBasePoint( <G>, <newsg> )
##
InstallGlobalFunction( ReturnNextBasePoint,
function( G, newsg )
    local newBasePoints, pos, pnt, i;

    newBasePoints := ValueOption( "newBasePoints" );
    if newBasePoints = fail then
        return fail;
    fi;
    for i in [1..Length( newBasePoints) ] do
	if IsBound(newBasePoints[i]) then
	    pnt := newBasePoints[i];
	    if pnt ^ newsg <> pnt or 
	       ValueOption( "strictBaseOrder" ) = true then
	        Unbind( newBasePoints[i] );
    		Info( InfoRSS, 2, "newbasepoint:  ", pnt );
		return pnt;
	    fi;
	fi;
    od;
    Error( "Cannot find point moved by the strong generator;",
           "perhaps due to interrupted routine.  Type:  ReturnPopOptions()",
           " a few times" );
end );

#############################################################################
##
#F  PermNewBasePoint( <G>, <newsg> )
##
InstallGlobalFunction( PermNewBasePoint,
function( G, newsg )
    local point, tmp;

    tmp := ValueOption( "newBasePoints" );
    if tmp = fail or Length(tmp) = 0 then
	SetValueOption( "newBasePoints", [1..LargestMovedPoint(G)] );
    fi;
    point := ReturnNextBasePoint( G, newsg );
    if point = fail then
	Error( "This should not happen" );
    fi;
    return [point, POW];
end );

#############################################################################
##
#F  MatrixNewBasePoint( <G>, <newsg> )
##
InstallGlobalFunction( MatrixNewBasePoint,
function( G, newsg )
    local V, basis, new, newBasePoints;

    V := FullRowSpace ( FieldOfMatrixGroup( G ), DimensionOfMatrixGroup( G ) );

    newBasePoints := ValueOption( "newBasePoints" );
#    if newBasePoints = [] then Print("empty newBasePoints\n"); fi;
    if newBasePoints = fail or newBasePoints = [] then
	newBasePoints := Concatenation( EvectBasePoints(G),
                                            BasisVectors(Basis(V)) ); 
    	SetValueOption( "newBasePoints", newBasePoints );
    fi;
    if not IsMutable( newBasePoints ) then # eg gotten from basis
        if newBasePoints = [] then Error("empty newBasePoints"); fi;
	SetValueOption( "newBasePoints", ShallowCopy( newBasePoints ));
    fi;
    if ValueOption( "lastVect" ) = fail and UnderlyingField( G ) = GF(2) then  
	# return vectors only for GF(2)
	return [ ReturnNextBasePoint(G, newsg), POW ];
    elif ValueOption( "lastVect" ) = fail then
	# return subspace first
	new := ReturnNextBasePoint( G, newsg );
	SetValueOption( "lastVect", new );
        return [Subspace(V, [ new ] ), POW];
    else  # then return vector
	new := ValueOption( "lastVect" );
	SetValueOption( "lastVect", fail );
	return [new, POW];
    fi;
end );


#############################################################################
#############################################################################
##
##  Matrix group base point functions
##
#############################################################################
#############################################################################

#############################################################################
##
#M  EspaceBasePoints( <G> )
##
InstallMethod( EspaceBasePoints, "for a matrix group", true,
    [ IsFFEMatrixGroup ], 0,
function( G )
    local F, evals, espaces, gen, gens, i, j, int, IsMore;

    F := FieldOfMatrixGroup(G);
    gens := ShallowCopy( GeneratorsOfGroup( G ) ); # Need copy for mutability
    while Length( gens ) < 10 do
	Add( gens, PseudoRandom( G ) );
    od;

    evals := [];  espaces := [];
    for gen in gens do
	evals := Concatenation( evals, GeneralisedEigenvalues(F,gen) );
	espaces := Concatenation( espaces, GeneralisedEigenspaces(F,gen) );
    od;

    IsMore := function( p, q ) # would be IsLess, but we reverse the list at the end
    	local c, d;
	if DegreeOfLaurentPolynomial(p) <>
	   DegreeOfLaurentPolynomial(q) then
	    return DegreeOfLaurentPolynomial(p) >
	      DegreeOfLaurentPolynomial(q);
	else
	    c := CoefficientsOfLaurentPolynomial(p);
	    d := CoefficientsOfLaurentPolynomial(q);
	    return Number( c[1], x -> x <> Zero(x) ) > Number( d[1], x -> x <> Zero(x) ); 
	fi;
    end;
    SortParallel( evals, espaces, IsMore );

##     for i in [ 1..Length( espaces ) ] do
##	for j in [ i+1..Length( espaces ) ] do
##	    int := Intersection( espaces[i], espaces[j] );
##	    if not IsTrivial( int ) then
##		Add( espaces, int );
##	    fi;
##	od;
##     od;

    return Reversed( DuplicateFreeList ( espaces ) );  # remove repetitions
end );

#############################################################################
##
#M  EvectBasePoints( <G> )
##
InstallMethod( EvectBasePoints, "for a matrix group", true,
    [ IsFFEMatrixGroup ], 0,
function( G )
    local evects, espaces, espace, subspace, evect, linIndepEvects, V, basis;

    V := FullRowSpace( FieldOfMatrixGroup(G), DimensionOfMatrixGroup(G) );
    
    evects := [];
    espaces := EspaceBasePoints( G );
    subspace := TrivialSubspace( V );
    for espace in espaces do
 	evects := Concatenation( evects, AsList( Basis( espace ) ) );
    od;
 
    linIndepEvects := [];
    for evect in evects do
	if not evect in subspace then
	    Add(linIndepEvects, evect);
	    basis := ShallowCopy( GeneratorsOfVectorSpace(subspace) );	# copy to make mutable
	    Add( basis, evect );
	    subspace := Subspace( V, basis );
	fi;
	if subspace = V then
	    return linIndepEvects;
	fi;
    od; 

    return linIndepEvects;  # remove repetitions
end );


#E
