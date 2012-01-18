#############################################################################
##
#W  grpchain.gi			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
##
#Y  Copyright (C)  1996,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  Requires: transversal, rss (for ChainSubgroup only)
##  Exports: Group _mutable_ attribute ChainSubgroup.  This stores the
##     next group down in the chain (ie. the structure is recursive)
##     The ChainSubgroup should have an attribute Transversal, as
##     described in transversal.[gd,gi]
##     StrongGens(grp), returns in format:
##      rec(level:=LEVEL, gens:=GENS, gensinv:=GENSINV, Group:=GROUP,
##          lastOldGens:=OLD)
##      and GENS  and GENSINV are lists of lists of generators,
##      and LEVEL is index of list for this level.
##      OLD is a list recording the last generator that had been
##      applied to all old points.
##  Defines:  Size, Random, IN, Enumerator, Iterator for ChainSubgroup
##  Exports:  TransversalOfChainSubgroup, CompleteChain, ExtendedSubgroup,
##  	Sift, SiftOneLevel, ChainSubgroupByXXX
##
##  Note on strong generators:  The data type for strong generators 
##  (currently a record) should be considered a work in progress.  
##  The current data type makes gptransv dependent on grpchain,
##  which should not be the case.  Also the current data type is inductive
##  while all our other structures are recursive -- this is necessary for
##  efficiency, although it should probably be hidden from the user to
##  retain the desired level of flexibility in the code.  In particular,
##  this means that creating mixed chains (with different kinds of 
##  transversal), may have unpredictable results.
##

##
##  For debugging only:
##
NthChainSubgroup := function(G,n)
    if n = 0 then return G;
    elif HasChainSubgroup(G) then
       return NthChainSubgroup(ChainSubgroup(G),n-1);
    else Error("no chain subgroup");
    fi;
end;
NthSchreierTransversalOfChainSubgroup := function(G,n)
    return TransversalOfChainSubgroup(NthChainSubgroup(G,n-1));
end;
NthFundamentalOrbit := function(arg)
    local G, n;
    G := arg[1]; if Length(arg)>1 then n := arg[2]; else n := 1; fi;
    return TransversalOfChainSubgroup(NthChainSubgroup(G,n-1))!.HashTable!.KeyArray;
end;
NthSiftOneLevel := function(G,g,n)
    if n = 1 then return SiftOneLevel(G,g);
    elif HasChainSubgroup(G) then
       return NthSiftOneLevel(ChainSubgroup(G),SiftOneLevel(G,g),n-1);
    else Error("no chain subgroup");
    fi;
end;

##  Returns list of pairs [transvsersalElt, groupInChain]
##     where elt is in group
SiftedWord := function(grp, elt)
    local word, elt2;
    word := [];
    while HasChainSubgroup(grp) do
        elt2 := TransversalElt(Transversal(ChainSubgroup(grp)),elt);
        if elt*elt2^(-1) <> SiftOneLevel(grp,elt) then Error("bad sift"); fi;
        Add( word, [ elt2, grp ] );
        grp := ChainSubgroup(grp);
        elt := elt * elt2^(-1);
    od;
    Add(word,[elt,grp]);
    return word;
end ;

##  gdc - this is slow for something like NiceObj(GL(10,2))
##        and it still doesn't complete everything.
##  BECAUSE IT DOES Extending complete stabilizer chain subgroup
CompleteChain := function( G )
    local size, oldSize, origG;
    origG := G;
    size := SizeOfChainOfGroup(G);
    repeat
        G := origG;
        oldSize := size;
        while HasChainSubgroup(G) do
            if IsTransvBySchreierTree(TransversalOfChainSubgroup(G)) then
                SetGeneratingSetIsComplete(G, true);
                CompleteSchreierTransversal(TransversalOfChainSubgroup( G ) );
            fi;
            G := ChainSubgroup(G);
        od;
        size := SizeOfChainOfGroup(origG);
        Info( InfoChain, 2, "Completing chain from size ", oldSize,
              " to size ", size);
    until oldSize = size;
end;


#############################################################################
#############################################################################
##
##  General group utilities done via chains
##
#############################################################################
#############################################################################

#############################################################################
##
#M  ChainSubgroup( <G> )
##
InstallMethod( ChainSubgroup, "for chain type groups", true,
    [ IsGroup and IsChainTypeGroup and HasChainSubgroup ], NICE_FLAGS,
    G -> G!.ChainSubgroup );
InstallMethod( ChainSubgroup, "for chain type groups", true,
    [ IsGroup and IsChainTypeGroup ], NICE_FLAGS,
    function( G )
	if IsTrivial( G ) then
            SetIsTrivial( G, true );
	    Error( "Cannot compute chain subgroup of trivial group" );
        # Else test IsAbelian().  It's cheap.
        elif IsFFEMatrixGroup(G)
             and (IsAbelian(G)
                  or (HasIsNilpotentGroup(G) and IsNilpotentGroup(G))
                  or HasNilpotentClassTwoElement(G)) then
            MakeHomChain(G);
        else
#	    Print("Warning: Monte-Carlo algorithm; chain may be incomplete\n");
            RandomSchreierSims( G );
        fi;
	return G!.ChainSubgroup;
    end );
InstallMethod( ChainSubgroup, "for chain type groups", true,
    [ IsGroup and IsFFEMatrixGroup and IsChainTypeGroup ], NICE_FLAGS+1,
    function(G)
        if IsTrivial(G) then
            SetIsTrivial(G,true);
            SetSize(G,1);
            Error("Group is trivial.  It has no ChainSubgroup.");
        fi;
        if HasIsCyclic(G) and IsCyclic(G) and
           not HasSize(G) and Length(GeneratorsOfGroup(G)) = 1 then
            # GAP can leave this out.  We need this info.
            SetIsCyclicWithSize( G, GeneratorsOfGroup(G)[1],
                                    Order(GeneratorsOfGroup(G)[1]) );
            MakeHomChain(G);
        fi;
        if IsAbelian(G) then
            MakeHomChain(G);
            CompleteChain(G);
            # These are the two base cases:
            if not HasChainSubgroup(G)  # and maybe we're in base case
               and ( (IsCyclic(G) and IsPGroup(G))
                      or IsQuotientToAdditiveGroup(G) ) then
                return TrivialSubgroup(G);
            else return ChainSubgroup(G);
            fi;
        elif (HasIsNilpotentGroup(G) and IsNilpotentGroup(G))
             or CanFindNilpotentClassTwoElement(G) then
            return MakeHomChain(G); CompleteChain(G);
        # elif IsSolvable(G) then return MakeHomChain(G); CompleteChain(G);
        else TryNextMethod();
        fi;
end );

#############################################################################
##
#M  IN( <g>, <G> )
##
InstallMethod( IN, "for chain type group", true,
    [ IsMultiplicativeElementWithInverse, IsGroup and IsChainTypeGroup ],
    NICE_FLAGS,
    function( g, G )
        if IsTrivial(G) then return IsOne(g); fi;
	if not HasChainSubgroup( G ) then
	    Info( InfoChain, 2, "Creating chain subgroup" );
	    ChainSubgroup( G );
	fi;
	Info( InfoChain, 2, "Sifting to test membership" );
        return Sift( G, g ) = One( G );
    end );

#############################################################################
##
#M  Size( <G> )
##
InstallMethod( Size, "for chain type group", true,
    [ IsGroup and IsChainTypeGroup and IsTrivial ],
    NICE_FLAGS+10, # + 10 for matrix groups
    G -> 1 );
InstallMethod( Size, "for chain type group", true,
    [ IsGroup and IsChainTypeGroup ], NICE_FLAGS+10, # + 10 for matrix groups
    function( G )
        # Note that in GAP4r1, IsTrivial() calls Size().  Don't use IsTrivial()
        if not HasIsTrivial(G) or IsTrivial(G) then
            if IsTrivial(G) then
                SetIsTrivial(G,true);
                return Size(G);
            else SetIsTrivial(G,false);
            fi;
        fi;
	if not HasChainSubgroup( G ) then
	    Info( InfoChain, 2, "Creating chain subgroup" );
	    ChainSubgroup( G );
	fi;
        return Size( TransversalOfChainSubgroup( G ) )
               * Size( ChainSubgroup( G ) );
    end );

#############################################################################
##
#M  Random( <G> )
##
InstallMethod( Random, "for chain type group", true,
    [ IsGroup and IsChainTypeGroup ], NICE_FLAGS,
    function( G )
	if not HasChainSubgroup( G ) then
	    Info( InfoChain, 2, "Creating chain subgroup" );
	    ChainSubgroup( G );
	fi;
	return Random( TransversalOfChainSubgroup( G ) ) *
		Random( ChainSubgroup( G ) );
    end );
InstallMethod( Random, "for trivial chain type group", true,
    [ IsGroup and IsChainTypeGroup and IsTrivial ], NICE_FLAGS,
    function( G )
	return One( G );
    end );

#############################################################################
##
#M  Enumerator( <G> )
##
InstallMethod( Enumerator, "for chain type group", true,
    [ IsGroup and IsChainTypeGroup ], NICE_FLAGS,
    function( G )
	local newG;
        if not HasIsTrivial( G ) then
            SetIsTrivial( G, IsTrivial(G) );
            if IsTrivial( G ) then return Enumerator(G); fi;
        fi;
	if not HasChainSubgroup( G ) then
	    Info( InfoChain, 2, "Creating chain subgroup" );
	    ChainSubgroup( G );
	fi;
        if IsTransvByTrivSubgrp( TransversalOfChainSubgroup( G ) ) then
            TryNextMethod();
            return;
	    newG := Group( GeneratorsOfGroup( G ) );
	    UseIsomorphismRelation( G, newG );
	    return Enumerator(newG);
	fi;
	return ListX( Enumerator( TransversalOfChainSubgroup( G ) ),
		      Enumerator( ChainSubgroup( G ) ), PROD );
    end );
InstallMethod( Enumerator, "for trivial chain type group", true,
    [ IsGroup and IsChainTypeGroup and IsTrivial ], NICE_FLAGS,
    function( G )  #base of recursion -- probably unnecessary
	return [ One( G ) ];
    end );


##  still to write: Iterator


#############################################################################
#############################################################################
##
##  General group with chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#M  GeneratingSetIsComplete( <G> )
##
InstallMethod( GeneratingSetIsComplete, "for group", true,
    [ IsGroup ], 0, G -> false ); 
    #generating sets assumed incomplete unless set to true. Should be 
    #replaced by verifier.

#############################################################################
##
#M  SiftOneLevel( <G>, <g> )
##
InstallMethod( SiftOneLevel, "for group with chain and element", true,
    [ IsGroup and HasChainSubgroup, IsAssociativeElement ], 0,
    function( G, g )
	if HasTransversal( ChainSubgroup( G ) ) then
	    Info( InfoChain, 3, "Sifting ", g );
	    return SiftOneLevel( TransversalOfChainSubgroup( G ), g );
	else
	    return fail;
	fi;
    end );

#############################################################################
##
#M  Sift( <G>, <g> )
##
InstallMethod( Sift, "for group with chain and element", true,
    [ IsGroup and HasChainSubgroup, IsAssociativeElement ], 0,
    function( G, g )
	local s;
	s := SiftOneLevel( G, g );
	if s = fail then # base case for incomplete chain
	    return g;
	fi;
        return Sift( ChainSubgroup( G ), s );
    end );
InstallMethod( Sift, "for group without chain and element", true,
    [ IsGroup, IsAssociativeElement ], 0,
    function( G, g ) #base case of recursion
        return g;
    end );

#############################################################################
##
#F  SizeOfChainOfGroup( <> )
##
##  If chain stops at non-trivial subgroup with HasSize() false,
##      this will assume subgroup is trivial.  This is useful,
##      for programs that construct a chain, and wish to test the
##      "current size" to see if the chain is complete.
##
InstallGlobalFunction( SizeOfChainOfGroup, 
    function( G )
        if not HasChainSubgroup( G ) then # base case
            if HasSize(G) then
                return Size(G);
            #Gene: BasisOfHomCosetAddMatrixGroup(G) computes Size() of
            #  additive group more efficiently.  A method for Size()
            #  of additive groups should be based on this.  But this
            #  was added after "feature freeze".
            elif IsAdditiveGroup(G) or IsQuotientToAdditiveGroup(G) then
                BasisOfHomCosetAddMatrixGroup(G);
                if HasSize(G) then return Size(G); else return 1; fi;
	    else return 1;  #Note: may be incorrect for incomplete chains
            fi;
	fi;
        return Size( TransversalOfChainSubgroup( G ) )
	        * SizeOfChainOfGroup( ChainSubgroup( G ) );
    end );


#############################################################################
##
#F  ChainStatistics( <G> )
##
InstallGlobalFunction( ChainStatistics, function( G )
    local stats, transv;
    stats := rec( Size := 1, TransversalSizes := [],
              SchreierTreeDepths := [], DepthThreshold := [],
              NumberSifted := [], basePoints := [] );
    while HasChainSubgroup( G ) do  
        transv := TransversalOfChainSubgroup( G );
        stats.Size := stats.Size * Size( transv );
        Add( stats.TransversalSizes, Size( transv ) );
        Add( stats.NumberSifted, transv!.NumberSifted );
	if IsTransvBySchreierTree( transv ) then
            Add( stats.SchreierTreeDepths, SchreierTreeDepth( transv ) );
            Add( stats.DepthThreshold, transv!.DepthThreshold );
            Add( stats.basePoints, BasePointOfSchreierTransversal( transv ) );
	else
	    Add( stats.SchreierTreeDepths, "not Schr. tree" );
	    Add( stats.DepthThreshold, "not Schr. tree" );
	    Add( stats.basePoints, "not Schr. tree" );
	fi;
        G := ChainSubgroup( G );
    od;
    return stats;    
end );

#############################################################################
##
#F  TransversalOfChainSubgroup( <G> )
##
InstallGlobalFunction( TransversalOfChainSubgroup, function( G )
    if not HasChainSubgroup( G ) then
        Error("Sorry this group does not have a chain subgroup");
    fi;
    return Transversal( ChainSubgroup( G ) );
end );

#############################################################################
##
#F  HasChainHomomorphicImage( <G> )
##
InstallGlobalFunction( HasChainHomomorphicImage,
    G -> HasChainSubgroup(G) and
    HasTransversal(ChainSubgroup(G)) and
    IsBound(TransversalOfChainSubgroup(G)!.Homomorphism) and
    HasImagesSource(Homomorphism(TransversalOfChainSubgroup(G))) );

#############################################################################
##
#F  ChainHomomorphicImage( <G> )
##
InstallGlobalFunction( ChainHomomorphicImage, 
    G -> Image(Homomorphism(TransversalOfChainSubgroup(G))) );


#############################################################################
#############################################################################
##
##  Stabiliser chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#F  StrongGens( <G> )
##
##  gdc - This should be converted into a method.
##       It should then operate on a group or on a IsTransvBySchreierTree
##  StrongGens will be a list of lists.
##
InstallGlobalFunction( StrongGens,
    function( G )
        if not IsBound( G!.strongGens ) then
            if IsIdenticalObj( G, Parent(G) ) then
                G!.strongGens :=
                    rec( Group := G, level := 1,
                         gens := [ List( GeneratorsOfGroup(G) ) ],
                         gensinv := [ List( GeneratorsOfGroup(G), INV ) ],
                         lastOldGens := [0] );
            else G!.strongGens := StrongGens(Parent(G));
                 Add( G!.strongGens.gens, [] );
                 Add( G!.strongGens.gensinv, [] );
                 G!.strongGens :=
                    rec( Group := G, level := Length( G!.strongGens.gens),
                         gens := G!.strongGens.gens,
                         gensinv := G!.strongGens.gensinv,
                         lastOldGens := List(G!.strongGens.gens, i->0) );
            fi;
        fi;
        return G!.strongGens;
    end );

#############################################################################
##
#F  ChainSubgroupByStabiliser( <G>, <basePoint>, <Action> )
##
InstallGlobalFunction( ChainSubgroupByStabiliser,
    function( G, basePoint, Action )
	local subgp, ss;

    	Info( InfoChain, 1, "Making stabiliser chain subgroup for basepoint ",
              basePoint );
	subgp := TrivialSubgroup( G );
	ss := SchreierTransversal( basePoint, Action,
                                   # computed from Parent(subgp)
                                   StrongGens(subgp) );
        if Length( GeneratorsOfGroup(G) ) > 0 then
	    ExtendSchreierTransversal( ss, GeneratorsOfGroup( G ) );
        fi;
	SetTransversal( subgp, ss );
	SetChainSubgroup( G, subgp );
	return subgp;
    end );

#############################################################################
##
#M  BaseOfGroup( <G> )
##
InstallMethod( BaseOfGroup, "for group with chain", true,
    [ IsGroup and HasChainSubgroup ], 40,
    function( G )
	return Concatenation( 
	[ BasePointOfSchreierTransversal( TransversalOfChainSubgroup( G ) ) ],
		BaseOfGroup( ChainSubgroup( G ) ) );
    end );
InstallMethod( BaseOfGroup, "for trivial group", true,
    [ IsTrivial and IsGroup and IsInChain ], 40,
    function( G ) #base case of recursion
	return [ ];
    end );

##  gdc - These are experimental.
#############################################################################
##
#M  StabChainMutable( <G> )
##
#InstallMethod( StabChainMutable, "Stab chain via chain subgroup", true,
#    [ IsPermGroup and IsChainTypeGroup and IsStabChainViaChainSubgroup], 0,
#    function(G)
#        RandomSchreierSims(G);
#        StabChainBaseStrongGenerators(Base(G), StrongGens(G),One(G));
#        return StabChain(G);
#    end );
#############################################################################
##
#M  StabChainOp( <G> )
##
#InstallMethod( StabChainOp, "Stab chain via chain subgroup", true,
#    [ IsPermGroup and IsChainTypeGroup and IsStabChainViaChainSubgroup,
#      IsRecord], 0,
#    function(G,opt) return StabChainMutable(G); end );

#############################################################################
##
#M  ExtendedGroup( <G>, <g> )
##
##  gdc - These functions should really call ExtendTransversal()
##    and let ExtendTransversal() and ExtendTransversalOrbitGenerators()
##    be a method for different kinds
##    of transversals.  For example, given an initial homomorphism transversal
##    for a block action, why not extend such a transversal by taking
##    the homomorphic image of the element, and then taking a stabilizer
##    chain through the action on blocks, first.?
##
InstallMethod( ExtendedGroup, "for group in chain", true,
    [ IsGroup and IsInChain, IsAssociativeElement ], 0,
    function( G, g )
    	local newG;
    	Info( InfoChain, 1, "Extending stabiliser chain subgroup" );
	newG := Group( Concatenation( GeneratorsOfGroup( G ), [g] ) ); 
	if HasChainSubgroup( G ) then
	    SetChainSubgroup( newG , ChainSubgroup( G ) );
	    if HasTransversal( ChainSubgroup( G ) ) and
	       IsTransvBySchreierTree( TransversalOfChainSubgroup( newG ) ) then
	    	ExtendSchreierTransversal( TransversalOfChainSubgroup( newG ), [g] );
	    fi;
	fi;
	if HasTransversal( G ) then
	    SetTransversal( newG, Transversal( G ) );
	fi;
        # Really, want to transfer info from G to newG via SupersetRelation
	UseSubsetRelation( newG, G );
	
        return newG;
    end );
InstallMethod( ExtendedGroup, "for group in chain", true,
    [ IsGroup and IsInChain and GeneratingSetIsComplete, 
	IsAssociativeElement ], 0,
    function( G, g )
    	Info( InfoChain, 1, "Extending complete stabiliser chain subgroup" );
	if HasChainSubgroup( G ) and HasTransversal( ChainSubgroup( G ) ) and
	   IsTransvBySchreierTree( TransversalOfChainSubgroup( G ) ) then
	    ExtendSchreierTransversal( TransversalOfChainSubgroup( G ), [g] );
	    # To make sure strong generators go up the chain,
	    # in case we want to make a shallower tree.
	fi;
        return G;
    end );
    
#############################################################################
##
#M  OrbitGeneratorsOfGroup( <G> )
##
InstallMethod( OrbitGeneratorsOfGroup, "for groups with chain", true,
    [ IsGroup and HasChainSubgroup ], 0,
    function( G )
	return Union( OrbitGenerators( TransversalOfChainSubgroup( G ) ),
		      OrbitGeneratorsOfGroup( ChainSubgroup ( G ) ) );
    end );
InstallMethod( OrbitGeneratorsOfGroup, "for trivial groups", true,
    [ IsGroup and IsTrivial ], 0,
    function( G )
	return []; # base of recursion
    end );


 
#############################################################################
#############################################################################
##
##  Hom coset chains
##
#############################################################################
#############################################################################

#############################################################################
##
#F  ChainSubgroupByHomomorphism( <hom> )
##
InstallGlobalFunction( ChainSubgroupByHomomorphism,
function( hom )
    local transv, quotient;

    Info( InfoChain, 1, "Making homomorphism chain subgroup");
    Info( InfoChain, 3, "    for ", hom );
    transv := HomTransversal( hom );
    if HasKernelOfMultiplicativeGeneralMapping( hom ) then
        SetGeneratingSetIsComplete( KernelOfMultiplicativeGeneralMapping(hom),
	                            true );
        SetTransversal( KernelOfMultiplicativeGeneralMapping(hom), transv );
        SetChainSubgroup( Source(hom),
	  KernelOfMultiplicativeGeneralMapping(hom) );
        # These Use...Relation may be redundant.  Don't know if GAP does it.
        UseSubsetRelation( Source(hom),
	  KernelOfMultiplicativeGeneralMapping(hom) );
        UseFactorRelation( Source(hom),
	  KernelOfMultiplicativeGeneralMapping(hom), Image(hom) );
        quotient := QuotientGroup( transv );
        UseIsomorphismRelation( Image(hom), quotient );
    else # else kernel has incomplete generating set
        SetChainSubgroup( Source(hom), SubgroupNC(Source(hom), []) );
        SetTransversal( ChainSubgroup(Source(hom)), transv );
        quotient := QuotientGroup( transv );
    fi;
    return ChainSubgroup( Source( hom ) );
end );

#############################################################################
##
#F  ChainSubgroupByProjectionFunction( <> )
##
InstallGlobalFunction( ChainSubgroupByProjectionFunction,
function( G, kernelSubgp, imgSubgp, projFnc )
    local hom;

    Info( InfoChain, 1, "Making homomorphism chain subgroup for projection", projFnc );
    hom := GroupHomomorphismByFunction( G, imgSubgp, projFnc, g->g );
    SetImagesSource( hom, imgSubgp );
    if kernelSubgp <> fail then
        SetKernelOfMultiplicativeGeneralMapping( hom, kernelSubgp );
    fi;
    #PERFORMANCE BUG:  GAP doesn't know to use projFnc to quickly compute image
    #  in ImageElm(hom, elt);
    # It lost projFnc.
    # It prefers to use NiceMonomorphism instead of DirectProductInfo
    return ChainSubgroupByHomomorphism( hom );
end );

#############################################################################
##
#F  QuotientGroupByChainHomomorphicImage( <quo>[, <quo2>] )
##
##  This function creates quotient groups of quotient groups.
##
InstallGlobalFunction( QuotientGroupByChainHomomorphicImage, 
function( arg )
    local quo, quo2, hom, hom1, hom2, kernel;

    quo := arg[1];
    if Length(arg) > 1 then quo2 := arg[2]; fi; # Homomorphic image of quo
    if not IsHomQuotientGroup(quo) then Error("group must be quotient group"); fi;
    if not HasChainHomomorphicImage(quo) and Length(arg) = 1 then
        Error("no homomorphic image");
    fi;
    # compose homomorphisms;
    #  Note Source(Hom(HomIm(quo)) = Im(Hom(quo)) by construction of quo
    # Composition:  Needed so GAP won't complain about compatibility.
    hom1 := Homomorphism(quo);
    if Length(arg) > 1 then
        hom2 := Homomorphism(quo2);
    else
        hom2 := Homomorphism(TransversalOfChainSubgroup(quo));
    fi;
    hom := GroupHomomorphismByFunction( Source(hom1), Range(hom2),
                                        g->hom2!.fun(hom1!.fun(g)) );
    if HasImagesSource( hom2 ) then
        SetImagesSource( hom, ImagesSource(hom2) );
    fi;
    quo := QuotientGroupByHomomorphism( hom );
    if HasImagesSource( hom2 )
       and HasGeneratorOfCyclicGroup(ImagesSource(hom2)) then
        SetGeneratorOfCyclicGroup(quo,
           HomCoset(hom,SourceElt(GeneratorOfCyclicGroup(ImagesSource(hom2)))));
    fi;
    return quo;
end );


#############################################################################
#############################################################################
##
##  Direct sum chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#F  ChainSubgroupByDirectProduct( <proj>, <inj > )
##
InstallGlobalFunction( ChainSubgroupByDirectProduct, 
function( proj, inj )
    local transv, quotient;

##  I probably need more Use commands here

    Info( InfoChain, 1, "Making direct sum chain subgroup for projection", proj );
    transv := DirProdTransversal( proj, inj );
    if HasKernelOfMultiplicativeGeneralMapping( proj ) then
        SetGeneratingSetIsComplete( KernelOfMultiplicativeGeneralMapping( proj ), true );
        SetTransversal( KernelOfMultiplicativeGeneralMapping( proj ), transv );
        SetChainSubgroup( Source( proj ),
	KernelOfMultiplicativeGeneralMapping( proj ) );
        # These Use...Relation may be redundant.  Don't know if GAP does it.
        UseSubsetRelation( Source( proj ),
	KernelOfMultiplicativeGeneralMapping( proj ) );
        UseFactorRelation( Source( proj ),
	KernelOfMultiplicativeGeneralMapping( proj ), Image( proj ) );

    elif HasImagesSource( inj ) then
        SetGeneratingSetIsComplete( Image( inj ), true );
        SetTransversal( Image( inj ), transv );
        SetChainSubgroup( Source( proj ), Image( inj ) );
        # These Use...Relation may be redundant.  Don't know if GAP does it.
        UseSubsetRelation( Source( proj ), Image( inj ) );

    else # else kernel has incomplete generating set
        SetChainSubgroup( Source( proj ), SubgroupNC(Source( proj ), []) );
        SetTransversal( ChainSubgroup(Source( proj )), transv );
    fi;
    return ChainSubgroup( Source( proj ) );
end );

#############################################################################
##
#F  ChainSubgroupByPSubgroupOfAbelian( <G>, <p> )
##
InstallGlobalFunction( ChainSubgroupByPSubgroupOfAbelian, 
function( G, p )
    local PPart, imgGroup, kerGroup, proj, inj;

    PPart := function( g )
	local o;
	o := Order(g);
	while o mod p = 0 do o := o/p; od;
	return g ^ o;
    end;

    imgGroup := Group( List( GeneratorsOfGroup( G ), PPart ) );
    kerGroup := Group( List( GeneratorsOfGroup( G ), g -> g * PPart(g)^(-1) ) );

    proj := GroupHomomorphismByFunction( G, imgGroup, x -> PPart( x ) );
    SetImagesSource( proj, imgGroup );
    SetKernelOfMultiplicativeGeneralMapping( proj, kerGroup );

    inj := GroupHomomorphismByFunction( imgGroup, G, x -> x );
    SetImagesSource( proj, imgGroup );
    SetKernelOfMultiplicativeGeneralMapping( inj, TrivialSubgroup( imgGroup ) );

    return ChainSubgroupByDirectProduct( proj, inj );
end );

#############################################################################
#############################################################################
##
##  Trivial subgroup chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#F  ChainSubgroupByTrivialSubgroup( <G> )
##
InstallGlobalFunction( ChainSubgroupByTrivialSubgroup, 
function( G )
    local triv;

    Info( InfoChain, 1, "Making trivial chain subgroup" );
    triv := TrivialSubgroup( G );
    SetChainSubgroup( G, triv );
    SetTransversal( triv, TransversalByTrivial( G ) );
    SetGeneratingSetIsComplete( triv, true );
    return triv;
end );

#############################################################################
#############################################################################
##
##  Sift function chain utilities
##
#############################################################################
#############################################################################

#############################################################################
##
#F  ChainSubgroupBySiftFunction( <G>, <subgroup>, <siftFnc> )
##
InstallGlobalFunction( ChainSubgroupBySiftFunction, 
function( G, subgroup, siftFnc )
    Info( InfoChain, 1, "Making sift function subgroup" );
    SetChainSubgroup( G, subgroup );
    SetTransversal( subgroup,
                   TransversalBySiftFunction( G, subgroup, siftFnc ) );
    if HasSize(G) and HasSize(subgroup) then
        Transversal(subgroup)!.Size := Size(G)/Size(subgroup);
    fi;
    # gdc - If you set this false, you can't set it true later.
    # SetGeneratingSetIsComplete( subgroup, false );
    return subgroup;
end );


#E
