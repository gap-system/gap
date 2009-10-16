#############################################################################
##
#W  gptransv.gi			GAP Library		       Gene Cooperman
#W							     and Scott Murray
##
#H  @(#)$Id: gptransv.gi,v 4.7 2002/04/15 10:04:43 sal Exp $
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1999 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
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
##  A consequence of this is that the test file gptransv.tst does not 
##  currently work.
##
Revision.gptransv_gi :=
    "@(#)$Id: gptransv.gi,v 4.7 2002/04/15 10:04:43 sal Exp $";


#############################################################################
#############################################################################
##
##  Transversals by Schreier trees
##
#############################################################################
#############################################################################

#############################################################################
##
#M  Size( <ss> ) for Schreier trees
##
InstallMethod( Size, "for Schreier trees", true,
    [ IsRightTransversal and IsTransvBySchreierTree ], 0,
    function( ss )
	return Size( ss!.HashTable );
    end );

#############################################################################
##
#M  ViewObj( <ss> ) for Schreier trees
##
InstallMethod( ViewObj, "for Schreier trees", true, 
    [ IsTransvBySchreierTree ], 0,
    function( ss )
	Print( "Schreier tree with basepoint ", ss!.BasePoint );
    end );

#############################################################################
##
#M  PrintObj( <ss> ) for Schreier trees
##
InstallMethod( PrintObj, "for Schreier trees", true,
    [ IsTransvBySchreierTree ], 0,
    function( ss )
	Print( "Schreier tree with basepoint ", ss!.BasePoint, "\n" );
	Print( "Orbit generators: ", ss!.OrbitGenerators, "\n");
	PrintHashWithNames( ss!.HashTable, "Orbit", "Backpointers" );
	Print( "\n" );
    end );

#############################################################################
##
#F  SchreierTransversal( <basePoint>, <Action>, <strongGens> )
##
InstallGlobalFunction( SchreierTransversal, 
    function( basePoint, Action, strongGens ) 
        local hashTable, hashDepth, Type, Rec, ss, fun;
	if IsInt( basePoint ) then
    	    hashTable := DenseHashTable();
    	    hashDepth := DenseHashTable();
	elif IsVector( basePoint ) then
	### This is a hack
	    fun := SparseIntKey( VectorSpace( DefaultFieldOfMatrixGroup( strongGens.Group ), [basePoint] ), 
				 basePoint );
	    hashTable := SparseHashTable( fun );
	    hashDepth := SparseHashTable( fun );
	else
	    hashTable := SparseHashTable();
	    hashDepth := SparseHashTable();
	fi;
	AddHashEntry( hashTable, basePoint, "at base point" );
        AddHashEntry( hashDepth, basePoint, 0 );
	Type := NewType( TransvBySchreierTreeFamily,
                         IsRightTransversal and IsTransvBySchreierTree );
	Rec := rec( OrbitGenerators := [],
                    StrongGenerators := strongGens,
                    BasePoint := basePoint,
                    Action := Action,
	            HashTable := hashTable,
                    HashDepth := hashDepth,
                    Depth := 0,
                    # Can set this lower; It increments by 1 each ExtSchrTrans
                    DepthThreshold := 1,
                    NumberSifted := 0 );
        return Objectify( Type, Rec );
    end );
    
#############################################################################
##
#M  OrbitGenerators( <ss> )
##
InstallMethod( OrbitGenerators, "for Schreier trees", true,
    [ IsTransvBySchreierTree ], 0,
    ss -> ss!.StrongGenerators.gens[ss!.StrongGenerators.level] );

#############################################################################
##
#M  OrbitGeneratorsInv( <ss> )
##
InstallMethod( OrbitGeneratorsInv, "for Schreier trees", true,
    [ IsTransvBySchreierTree ], 0,
    ss -> ss!.StrongGenerators.gensinv[ss!.StrongGenerators.level] );

#############################################################################
##
#M  BasePointOfSchreierTransversal( <ss> )
##
InstallMethod( BasePointOfSchreierTransversal, "for Schreier trees", true,
    [ IsTransvBySchreierTree ], 0,
    ss -> ss!.BasePoint );

## 
##  These two functions are used by all the Extend... functions
##
ApplyGeneratorsToPoint := function( ss, point, gens, gensinv,
                                    max_depth, newPoints )
    local i, image, depth;
    depth := GetHashEntry( ss!.HashDepth, point ) + 1;
    if depth > max_depth then return; fi;
    for i in [1..Length(gens)] do
        if ss!.Depth > ss!.DepthThreshold then return; fi;
        image := ss!.Action(point, gens[i]);
        if GetHashEntry( ss!.HashTable, image ) = fail then
            AddHashEntry( ss!.HashTable, image, gensinv[i] );
            AddHashEntry( ss!.HashDepth, image, depth );
            ss!.Depth := Maximum(ss!.Depth, depth);
            Add( newPoints, image );
        elif GetHashEntryAtLastIndex( ss!.HashDepth ) > depth then
            SetHashEntryAtLastIndex( ss!.HashDepth, depth );
            Add( newPoints, image );
        fi;
    od;
end;
ApplyGeneratorsToPointsList := function( ss, points, gens, gensinv,
                                         iterations, max_depth )
    local i, idx, next_idx, newPoints;
    idx := 1;
    next_idx := Length(points);
    newPoints := [];
    while iterations > 0 and next_idx >= idx do
        for i in [idx..next_idx] do
            ApplyGeneratorsToPoint( ss, points[i], gens, gensinv,
                                    max_depth, newPoints );
            iterations := iterations - 1;
        od;
        idx := next_idx + 1;
        if not IsIdenticalObj( points, newPoints) then
            points := newPoints;
            idx := 1;
        fi;
        next_idx := Length(points);
    od;
    return newPoints;
end;

#############################################################################
##
#F  ExtendSchreierTransversal( <ss>, <newGens> )
#F  ExtendSchreierTransversal( <ss>, <newGens>, <newGensInv> )
##
##  This is the new function with the cube control tree
##  REFERENCE:
##   ``Combinatorial Tools for Computational Group Theory'',
##  G.~Cooperman and L.~Finkelstein, Proceedings of DIMACS Workshop on
##  Groups and Computation, DIMACS-AMS 11, AMS Press,
##  Providence, RI, 1993, pp.~53--86
##
InstallGlobalFunction( ExtendSchreierTransversal, # Cube
    function( arg )
    local ss, newGens, newGensInv, newPoints, i, gens, gensinv, len;

        ss := arg[1]; newGens := arg[2];
        if Length(arg)>2 then newGensInv := arg[3];
        else newGensInv := List( newGens, INV );
        fi;
        ss!.DepthThreshold := ss!.DepthThreshold + 1;
        Append( ss!.StrongGenerators.gens[ss!.StrongGenerators.level],
                newGens );
        Append( ss!.StrongGenerators.gensinv[ss!.StrongGenerators.level],
                newGensInv );

        # View cube as C = T^(n)T^(n-1)...T^(level);  g is new gen at level.
        # Then extended Schreier tree should cover:  g^-1 C^-1 C g
        #Extend by g^-1
        newPoints := ApplyGeneratorsToPointsList
                         ( ss, [ss!.BasePoint], newGensInv, newGens, 1, 1 );
        #Extend by C^-1
        gens := ss!.StrongGenerators.gens;
        gensinv := ss!.StrongGenerators.gensinv;
        for i in [ss!.StrongGenerators.level..Length(gens)] do
            newPoints := ApplyGeneratorsToPointsList
                           ( ss, newPoints, gensinv[i], gens[i], 1, 1000000 );
            # and can concatenate to newPoints, stuff reached by
            # oldPoints not yet applied.
        od;
        #Extend by C
        len := Length(gens);
        for i in [0 .. Length(gens) - ss!.StrongGenerators.level] do
            newPoints := ApplyGeneratorsToPointsList
                   ( ss, newPoints, gens[len-i], gensinv[len-i], 1, 1000000 );
        od;
        #Extend by g
        ApplyGeneratorsToPointsList
          ( ss, HashKeyEnumerator( ss!.HashTable ), newGens, newGensInv, 1, 1000000 );
        Info( InfoTransversal, 2, "Transversal # ", ss!.StrongGenerators.level,
               " at depth ", ss!.DepthThreshold, " and size ", Size(ss) );
              
        return ss;
end);

#############################################################################
##
#F  ExtendSchreierTransversalShortCube( <ss>, <newGens> )
#F  ExtendSchreierTransversalShortCube( <ss>, <newGens>, <newGensInv> )
##
InstallGlobalFunction( ExtendSchreierTransversalShortCube, # ShortCube
    function( arg )
    local ss, newGens, newGensInv, newPoints, i, gens, gensinv, len;

        ss := arg[1]; newGens := arg[2];
        if Length(arg)>2 then newGensInv := arg[3];
        else newGensInv := List( newGens, INV );
        fi;
        ss!.DepthThreshold := ss!.DepthThreshold + 1;
        Append( ss!.StrongGenerators.gens[ss!.StrongGenerators.level],
                newGens );
        Append( ss!.StrongGenerators.gensinv[ss!.StrongGenerators.level],
                newGensInv );
        
        #View cube as C = T^(n)T^(n-1)...T^(level);  g is new gen at level.
        # Then extended Schreier tree should cover:  g^-1 C^-1 C g
        # Modified version re-computes oldPoints^(g^-1C^-1)
        #Since g^-1D^-1 doubles in size, we heuristically assume that
        # oldPoints^(g^-1C^-1) grows by a constant factor, and so the
        # amortized coset of this modification is a constant factor.
        #In return, the Schreier tree is much shallower:
        #  approximately r^r in depth instead of 2^r for r generators.
        #Extend by oldPoints^(g^-1)
        ApplyGeneratorsToPointsList
                         ( ss, [ss!.BasePoint], newGensInv, newGens, 1, 1 );
        newPoints := Difference( HashKeyEnumerator(ss!.HashTable), [ss!.BasePoint] );
        len := Length(ss!.StrongGenerators.gens);
        #Extend by C^-1
        gens := Concatenation( ss!.StrongGenerators.gens
                        {[ss!.StrongGenerators.level..len]} );
        gensinv := Concatenation( ss!.StrongGenerators.gensinv
                        {[ss!.StrongGenerators.level..len]} );
        newPoints := ApplyGeneratorsToPointsList
             ( ss, newPoints, gensinv, gens, ss!.DepthThreshold, 1000000 );
        #Extend by C
        newPoints := ApplyGeneratorsToPointsList
             ( ss, newPoints, gens, gensinv, 2*ss!.DepthThreshold-1, 1000000 );
        #Extend by g
        ApplyGeneratorsToPointsList( ss, HashKeyEnumerator( ss!.HashTable ),
                       newGens, newGensInv, 2*ss!.DepthThreshold, 1000000 );
        Info( InfoTransversal, 2, "Transversal # ", ss!.StrongGenerators.level,
               " at depth ", ss!.DepthThreshold, " and size ", Size(ss) );
              
        return ss;
end);

#############################################################################
##
#F  ExtendSchreierTransversalShortTree( <ss>, <newGens> )
#F  ExtendSchreierTransversalShortTree( <ss>, <newGens>, <newGensInv> )
##
##  REFERENCE:  ``A Random Base Change Algorithm for Permutation Groups'',
##  G.~Cooperman and L.~Finkelstein, J. of Symbolic Computation 17, 1994,
##  pp.~513--528
##
InstallGlobalFunction( ExtendSchreierTransversalShortTree,
    function( arg )
    local ss, newGens, newGensInv,
          point, oldPGens, oldPGensInv, oldNPGens, oldNPGensInv, newPGens,
          newPGensInv, i, j,
          oldss, newss, newNPGens, newNPGensInv, oldPoints, newPoints,
          tmp, OrbitGens, OrbitGensInv;

        ss := arg[1]; newGens := arg[2];
        if Length(arg)>2 then newGensInv := arg[3];
        else newGensInv := List( newGens, INV );
        fi;
        OrbitGens := OrbitGenerators(ss);
        OrbitGensInv := OrbitGeneratorsInv(ss);
        if Length(OrbitGens) <> Length(OrbitGensInv) then
            Error("error:  OrbitGens lengths");
        fi;
        ss!.DepthThreshold := ss!.DepthThreshold + 1;
        if Length(newGens) = 0 then Error("no gens to extend"); fi;

	if HasPreferredGenerators( ss ) then
	    oldPGens := PreferredGenerators( ss )[1];
	    oldPGensInv := PreferredGenerators( ss )[2];
	else
	    oldPGens := [];
	    oldPGensInv := [];
	fi;
	oldNPGens := Difference( OrbitGens, oldPGens );
	oldNPGensInv := Difference( OrbitGensInv, oldPGensInv );

        tmp := ValueOption( "PreferredGenerators" );
	if tmp = fail then
	    newPGens := [];
	    newPGensInv := [];
        else
	    newPGens := tmp[1];
	    newPGensInv := tmp[2];
	fi;
	newNPGens := Difference( newGens, newPGens );
	newNPGensInv := Difference( newGensInv, newPGensInv );
	Info( InfoTransversal, 2, "oldPGens: ", oldPGens, 
	  "\noldNPGens: ", oldNPGens, "\nnewPGens: ", newPGens,
	  "\nnewNPGens: ", newNPGens );

        # gdc - This part currently doesn't help much, because the
        #  code tends to fill out each fundamental orbit before
        #  sifting any lower.  In the future, when I implement
        #  better versions (deep sift), this code will help more.
        for i in [ss!.StrongGenerators.level+1
                  ..Length(ss!.StrongGenerators.gens)] do
            if not IsBound(ss!.StrongGenerators.lastOldGens[i]) then
                ss!.StrongGenerators.lastOldGens[i] := 0;
            fi;
            for j in [ss!.StrongGenerators.lastOldGens[i]+1
                      ..Length(ss!.StrongGenerators.gens[i]) ] do
                Add( newNPGens, ss!.StrongGenerators.gens[i][j] );
                Add( newNPGensInv, ss!.StrongGenerators.gensinv[i][j] );
            od;
            ss!.StrongGenerators.lastOldGens[i] :=
                     Length(ss!.StrongGenerators.gens[i]);
        od;
   # gdc - should extend generators of group  by newNPGens
   #     This code is currently buggy.
   # if not IsMutable(ss!.StrongGenerators.Group!.GeneratorsOfMagmaWithInverses)
   #    then
   #        ss!.StrongGenerators.Group!.GeneratorsOfMagmaWithInverses :=
   #           List(ss!.StrongGenerators.Group!.GeneratorsOfMagmaWithInverses);
   #    fi;
   #    Append(ss!.StrongGenerators.Group!.GeneratorsOfMagmaWithInverses,
   #           newNPGens);

        if not IsEmpty( newPGens ) and not IsEmpty( oldNPGens ) then
	    Info( InfoTransversal, 2, "Discarding old orbit" );
            oldss := ss;
            ss := SchreierTransversal( BasePointOfSchreierTransversal( ss ),
                                       Action( ss ), ss!.StrongGenerators );
            if HasPreferredGenerators( oldss ) then
                SetPreferredGenerators( ss, oldss );
            fi;
   	fi;

        # gdc - Add to OrbitGens _before_ ApplyGenerators()
	# Append( OrbitGens, newGens );
	# Append( OrbitGensInv, newGensInv );
        if Length(newGens) <> Length(newGensInv) then
            Error("error: newGens lengths");
        fi;
        # This extends both ss!.StrongGenerators.gens and group gen's and inv's
	Append( OrbitGenerators(ss), newGens );
	Append( OrbitGeneratorsInv(ss), newGensInv );

        #TO BE IMPLEMENTED:  WRAP AROUND TO KEEP GOING WHILE MAKING PROGRESS
        # repeat do oldSize := Size(ss); ...;
        #    newNPGens := []; newNPGensInv := []; until Size(ss)<2*oldSize;

        oldPoints := HashKeyEnumerator( ss!.HashTable );
        # oldPoints := List( HashKeyEnumerator( ss!.HashTable ) ); # List => mutable
        # Sort( oldPoints,
        #       function(x,y) return GetHashEntry( ss!.HashDepth, x )
        #                            < GetHashEntry( ss!.HashDepth, y );
        #       end );
	newPoints := [];

    	# for point in oldPoints do
	#    ApplyGeneratorsToPoint( ss, point, newPGens, newPGensInv,
        #                            ss!.DepthThreshold, newPoints );
    	# od;
        newPoints := ApplyGeneratorsToPointsList
            ( ss, oldPoints, newPGens, newPGensInv, 1, ss!.DepthThreshold );
    	# for point in newPoints do
	#     ApplyGeneratorsToPoint( ss, point, oldPGens, oldPGensInv,
        #                             ss!.DepthThreshold, newPoints );
	#     ApplyGeneratorsToPoint( ss, point, newPGens, newPGensInv,
        #                             ss!.DepthThreshold, newPoints );
    	# od;
        newPoints := ApplyGeneratorsToPointsList
            ( ss, newPoints, Concatenation( oldPGens, newPGens ),
                     Concatenation( oldPGensInv, newPGensInv ), 1000000,
                     ss!.DepthThreshold );
    	# for point in oldPoints do
	#    ApplyGeneratorsToPoint( ss, point, newNPGens, newNPGensInv,
        #                            ss!.DepthThreshold, newPoints );
    	# od;
        newPoints := Concatenation( newPoints, ApplyGeneratorsToPointsList
             ( ss, oldPoints, newNPGens, newNPGensInv, 1000000,
                     ss!.DepthThreshold ) );
        # ApplyGenerators() adds to end of newPoints
    	# for point in newPoints do
	#     ApplyGeneratorsToPoint( ss, point, oldNPGens, oldNPGensInv,
        #                             ss!.DepthThreshold, newPoints);
	#     ApplyGeneratorsToPoint( ss, point, newNPGens, newNPGensInv,
        #                             ss!.DepthThreshold, newPoints);
    	# od;
        ApplyGeneratorsToPointsList
            ( ss, newPoints, Concatenation( oldNPGens, newNPGens ),
                     Concatenation( oldNPGensInv, newNPGensInv ), 1000000,
              ss!.DepthThreshold );
        # STILL DEBUGGING:
        if -1 * ss!.Depth > ss!.DepthThreshold then
	     Info( InfoTransversal, 1,
                   "Remaking Schreier tree of size ", Size(ss),
                   ":  depth beyond threshold, ", ss!.DepthThreshold );
             newss := ExtendSchreierTransversal(
                            SchreierTransversal( ss!.BasePoint, ss!.Action,
						 ss!.StrongGenerators ),
                            ss!.OrbitGenerators );
             ss!.HashTable := newss!.HashTable;
             ss!.HashDepth := newss!.HashDepth;
             ss!.Depth := newss!.Depth;
        fi;

	if HasPreferredGenerators( ss ) then
	    Append( ss!.PreferredGenerators[1], newPGens );
	    Append( ss!.PreferredGenerators[2], newPGensInv );
	elif not IsEmpty( newPGens ) then
	    SetPreferredGenerators( ss, [ newPGens, newPGensInv ] );
	fi;

        if Length(OrbitGenerators(ss)) <> Length(OrbitGeneratorsInv(ss)) then
            Error("generators and inverses are of different lengths");
        fi;

        return ss;
    end );

#############################################################################
##
#F  ExtendTransversalOrbitGenerators(  <ss>, <newGens> )
#F  ExtendTransversalOrbitGenerators(  <ss>, <newGens>, <newGensInv> )
##
##  gdc - This shouldn't be used.
##
#InstallGlobalFunction( ExtendTransversalOrbitGenerators,
#    function( arg )
#        local ss, newGens, newGensInv;
#        ss := arg[1]; newGens := arg[2];
#        if Length(arg)>2 then newGensInv := arg[3];
#        else newGensInv := List( newGens, INV );
#        fi;
#        Append( OrbitGenerators( ss ), newGens );
#        Append( OrbitGeneratorsInv( ss ), newGensInv );
#        return ss;
#    end );

#############################################################################
##
#F  CompleteSchreierTransversal( ss )
##
InstallGlobalFunction( CompleteSchreierTransversal, 
function( ss )
    local gen, gens, sgens, gensinv, G, newPoints;
    # need better randomness than GAP's default:
    sgens := ss!.StrongGenerators;
    gens := Concatenation( List( [sgens.level..Length(sgens.gens)], i->sgens.gens[i] ) );
    gensinv := Concatenation( List( [sgens.level..Length(sgens.gens)], i->sgens.gensinv[i] ) );
    G := Group(gens);
    PseudoRandom(G); PseudoRandom(G); PseudoRandom(G);
    gen := PseudoRandom(G);
    newPoints := ApplyGeneratorsToPointsList
                 ( ss, HashKeyEnumerator( ss!.HashTable ), [gen], [gen^(-1)],
                   1, 1000000 ); # iterations = 1, max_depth = 1000000
    # gdc - hack:
    #IT WOULD BE BETTER TO SAVE newPoints FROM LAST ExtendSchreierTransversal()
    #  AS PART OF ss, AND USE IT HERE, DIRECTLY.
    if Length( newPoints ) > 0 then
        Add( gens, gen );
        Add( gensinv, gen^(-1) );
        ApplyGeneratorsToPointsList
            ( ss, newPoints, gens, gensinv, 1000000, 1000000 );
    fi;
    return Length( newPoints ) > 0;
end);

##
##  This recursive function is used by Enumerator, Random and SiftOneLevel. 
##  SiftOneLevel(ss,elt) = RecurseSchreierTree(ss,elt,ss!.BasePoint^elt)
##
RecurseSchreierTree := function( ss, elt, point )
    local backelt;
    if ss!.BasePoint = point then
        return elt;
    else
	backelt := GetHashEntry( ss!.HashTable, point );
	if backelt = fail then
	    return fail; 
	fi;
#   if GetHashEntry( ss!.HashDepth, point )
#    <> GetHashEntry( ss!.HashDepth, point^backelt ) + 1
#   then Error("bad backelt");
#   fi;
        return RecurseSchreierTree( ss, elt * backelt, point ^ backelt );
    fi;
end;

#############################################################################
##
#M  One( <ss> ) for Schreier trees
##
InstallMethod( One, "for Schreier trees", true,
    [ IsTransvBySchreierTree ], NICE_FLAGS,
    ss -> One( ss!.StrongGenerators.gens[1][1] ) );

#############################################################################
##
#M  Random( <ss> ) for Schreier trees
##
InstallMethod( Random, "for Schreier trees", true,
    [ IsRightTransversal and IsTransvBySchreierTree ], NICE_FLAGS,
    function( ss )
	local pnt;
	pnt := RandomHashKey( ss!.HashTable );
	Info( InfoTransversal, 2, "Random point: ", pnt );
	return RecurseSchreierTree( ss, One( ss ), pnt );
    end );
    
#############################################################################
##
#M  Enumerator( <ss> ) for Schreier trees
##
InstallMethod( Enumerator, "for Schreier trees", true,
    [ IsRightTransversal and IsTransvBySchreierTree ], NICE_FLAGS,
    function( ss )
	return List( HashKeyEnumerator( ss!.HashTable ),
		     pnt -> RecurseSchreierTree( ss, One( ss ), pnt ) );
    end );
    
#############################################################################
##
#M  SiftOneLevel( <ss>, <elt> ) for Schreier trees
##
InstallMethod( SiftOneLevel, "for Schreier trees", true,
    [ IsTransvBySchreierTree, IsAssociativeElement ], 0,
    function( ss, elt )
        ss!.NumberSifted := ss!.NumberSifted + 1;
	return RecurseSchreierTree( ss, elt, ss!.BasePoint ^ elt );
    end );
    
#############################################################################
##
#M  TransversalElt( <ss>, <elt> ) for Schreier trees
##
InstallMethod( TransversalElt, "for Schreier trees", true,
    [ IsRightTransversal and IsTransvBySchreierTree, IsAssociativeElement ], 0,
    function( ss, elt )    
	return SiftOneLevel( ss, elt )^(-1) * elt;
    end );
 
#############################################################################
##
#F  SchreierTreeDepth( <ss> )
##
InstallGlobalFunction( SchreierTreeDepth, ss -> ss!.Depth );

##
##  For debugging only  
##
SchreierTreeInternalConsistencyCheck := function(ss)
    local image;
    for image in Enumerator(ss!.HashTable!.KeyArray) do # for all points do
        if image <> ss!.BasePoint
           and GetHashEntry( ss!.HashDepth, image )
               <> GetHashEntry( ss!.HashDepth,
                                image^GetHashEntry(ss!.HashTable,image) ) + 1
        then Error("bad Schreier tree");
       fi;
    od;
    for image in Enumerator(ss!.HashTable!.ValueArray) do # for all points do
        if image <> "at base point" and
              ss!.BasePoint ^ image = ss!.BasePoint then
            Error("base point moved");
        fi;
    od;
    return "okay";
end;
CheckSchreierTreeInternalConsistency := function(ss)
   local i, g;
   for i in [ss!.StrongGenerators.level+1
             ..Length(ss!.StrongGenerators.gens)] do
       for g in ss!.StrongGenerators[i] do
           if ss!.BasePoint^g <> ss!.BasePoint then
               Error("bad Schreier tree");
           fi;
       od;
   od;
end;


#############################################################################
#############################################################################
###
### Transversal by homomorphism
###
#############################################################################
#############################################################################
    
#############################################################################
##
#F  HomTransversal( <h> )
##
InstallGlobalFunction( HomTransversal,
    function( h )
    local quo, Type, Rec, obj;
    quo := QuotientGroupByHomomorphism( h );
    Type := NewType( TransvByHomomorphismFamily, IsRightTransversal 
                    and IsTransvByHomomorphism );
    Rec := rec( Homomorphism := h,
                NumberSifted := 0 );
    obj := Objectify( Type, Rec );
    # gdc - QuotientGroup is now an attribute; must use SetQuotientGroup()
    SetQuotientGroup( obj, quo );
    return obj;
end );

    
#############################################################################
##
#M  ViewObj( <homtr> ) for hom transversal
##
InstallMethod( ViewObj, "for hom transversal", true, 
    [ IsTransvByHomomorphism ], 0,
    function( homtr )
	Print( "Hom transversal for ");
        ViewObj( homtr!.Homomorphism );
    end );

#############################################################################
##
#M  PrintObj( <homtr> ) for hom transversal
##
InstallMethod( PrintObj, "for hom transversals", true,
    [ IsTransvByHomomorphism ], 0,
    function( homtr )
	Print( "Hom transversal for ");
        PrintObj( homtr!.Homomorphism );
	Print("\n");
    end );
    

#############################################################################
##
#M  Homomorphism( <homtr> ) for hom transversal
##
InstallMethod( Homomorphism, "for hom transversals", true,
    [ IsTransvByHomomorphism ], 0,
    homtr -> homtr!.Homomorphism );

#############################################################################
##
#M  ImageGroup( <homtr> ) for hom transversal
##
InstallMethod( ImageGroup, "for hom transversals", true,
    [ IsTransvByHomomorphism ], 0,
    homtr -> Image( Homomorphism( homtr ) ) );

#############################################################################
##
#M  Size( <homtr> ) for hom transversal
##
InstallMethod( Size, "for hom transversals", true,
    [ IsRightTransversal and IsTransvByHomomorphism ], 0,
    function( homtr )
	return Size( ImageGroup( homtr ) );
    end );
    
#############################################################################
##
#M  Random( <homtr> ) for hom transversal
##
InstallMethod( Random, "for hom transversals", true,
    [ IsTransvByHomomorphism ], NICE_FLAGS,
    homtr -> CanonicalElt( Random( QuotientGroup( homtr ) ) ) );

#############################################################################
##
#M  Enumerator( <homtr> ) for hom transversal
##
InstallMethod( Enumerator, "for hom transversals", true,
    [ IsTransvByHomomorphism ], NICE_FLAGS,
    homtr -> List( Enumerator( QuotientGroup( homtr ) ), 
		   hcoset -> CanonicalElt( hcoset ) ) );

##  default iterator is fine


#############################################################################
##
#M  TransversalElt( <homtr>, <elt> ) for hom transversal
##
InstallMethod( TransversalElt, "for hom transversals", true,
        [ IsRightTransversal and IsTransvByHomomorphism, IsAssociativeElement ], 0,
    function(homtr, elt) 
        local elt2;
        elt2 := SiftOneLevel( homtr, elt );
        if elt2 = fail then return fail; fi;
        return elt * elt2^(-1);
 	return CanonicalElt( HomCoset( Homomorphism( homtr ), elt ) );
    end );

#############################################################################
##
#M  SiftOneLevel( <homtr>, <g> ) for hom transversal
##
InstallMethod( SiftOneLevel, "for hom transversals", true,
    [ IsRightTransversal and IsTransvByHomomorphism, IsAssociativeElement ], 0,
    function( homtr, elt )
    	local sh;
        homtr!.NumberSifted := homtr!.NumberSifted + 1;
    	sh := HomCoset( Homomorphism(homtr), elt );
    	sh := Sift( QuotientGroup(homtr), sh );
    	if not IsOne(sh) then return fail; fi;
    	return SourceElt(sh);
    end );
    

#############################################################################
#############################################################################
##
##  Transversal by direct product
##
#############################################################################
#############################################################################


#############################################################################
##
#F  DirProdTransversal( <proj>, <inj> )
##
InstallGlobalFunction( DirProdTransversal, 
function( proj, inj )
    local Type, Rec;
    if Source( proj ) <> Range( inj ) or Range( proj ) <> Source( inj ) then
	Error("incorrect proj and inj");
    fi;
    Type := NewType( TransvByDirProdFamily, IsRightTransversal 
                    and IsTransvByDirProd );
    Rec := rec( Projection := proj,
                Injection := inj,
                NumerSifted := 0 );
    return Objectify( Type, Rec );
end );

#############################################################################
##
#M  Projection( <dpt> ) for dir prod transversal
##
InstallMethod( Projection, "for dir prod transversals", true,
    [ IsTransvByDirProd ], 0, dpt -> dpt!.Projection );

#############################################################################
##
#M  Injection( <dpt> ) for dir prod transversal
##
InstallMethod( Injection, "for dir prod transversals", true,
    [ IsTransvByDirProd ], 0, dpt -> dpt!.Injection );


#############################################################################
##
#M  ViewObj( <dpt> ) for dir prod transversal
##
InstallMethod( ViewObj, "for dir prod transversals", true,
    [ IsTransvByDirProd ], 0,
    function( dpt )
	Print( "Direct product transversal with projection " );
	ViewObj( Projection( dpt ) );
    end );


#############################################################################
##
#M  PrintObj( <dpt> ) for dir prod transversal
##
InstallMethod( PrintObj, "for dir prod transversals", true,
    [ IsTransvByDirProd ], 0,
    function( dpt )
	Print( "Direct product transversal with projection " );
	PrintObj( Projection( dpt ) );
	Print( " and injection " );
	PrintObj( Injection( dpt ) );
	Print( "\n" );
    end );

#############################################################################
##
#M  Size( <dpt> ) for dir prod transversal
##
InstallMethod( Size, "for dir prod transversals", true,
    [ IsTransvByDirProd ], 0,
    dpt -> Size( Source( dpt!.Injection ) ) );

#############################################################################
##
#M  Enumerator( <dpt> ) for dir prod transversal
##
InstallMethod( Enumerator, "for dir prod transversals", true,
    [ IsTransvByDirProd ], 0,
    function( dpt )
	return List( Enumerator( Source( dpt!.Injection ) ), 
	             x -> ImageElm( dpt!.Injection, x ) ); 
    end );

#############################################################################
##
#M  Random( <dpt> ) for dir prod transversal
##
InstallMethod( Random, "for dir prod transversals", true,
    [ IsTransvByDirProd ], 0,
    dpt -> ImageElm( dpt!.Injection, Random( Source( dpt!.Injection ) ) ) );

#############################################################################
##
#M  TransversalElt( <dpt>, <elt> ) for dir prod transversal
##
InstallMethod( TransversalElt, "for dir prod transversals", true,
    [ IsTransvByDirProd, IsAssociativeElement ], 0,
    function( dpt, elt )
	return ImageElm( dpt!.Injection, Image( dpt!.Projection, elt ) );
    end );    

#############################################################################
##
#M  SiftOneLevel( <dpt>, <elt> ) for dir prod transversal
##
InstallMethod( SiftOneLevel, "for dir prod transversals", true,
    [ IsTransvByDirProd, IsAssociativeElement ], 0,
    function( dpt, elt )
        dpt!.NumberSifted := dpt!.NumberSifted + 1;
	return elt / TransversalElt( dpt, elt );
    end );    


#############################################################################
#############################################################################
##
##  Transversal by Trivial subgroup
##
#############################################################################
#############################################################################

#############################################################################
##
#F  TransversalByTrivial( <G> )
##
InstallGlobalFunction( TransversalByTrivial,
function( G )
    local Type, Rec;
    Enumerator( G );
#    if not HasSize(G) then Print("WARNING:  creating transversal by",
#        " trivial group\n  without knowing size of original group\n");
#    fi;
    Type := NewType( TransvByTrivSubgrpFamily, IsRightTransversal 
                    and IsTransvByTrivSubgrp );
    Rec := rec( Group := G, NumberSifted := 0 );
    return Objectify( Type, Rec );
end );

#############################################################################
##
#M  ViewObj( <tr> ) for transversal by trivial subgroup
##
InstallMethod( ViewObj, "for transversal by trivial subgroup", true,
    [ IsTransvByTrivSubgrp ], 0,
    function( tr )
	Print( "Transversal by trivial subgroup" );
    end );

#############################################################################
##
#M  PrintObj( <tr> ) for transversal by trivial subgroup
##
InstallMethod( PrintObj, "for transversal by trivial subgroup", true,
    [ IsTransvByTrivSubgrp ], 0,
    function( tr )
	Print( "Transversal by trivial subgroup for group ", tr!.Group, "\n" );
    end );

#############################################################################
##
#M  Enumerator( <tr> ) for transversal by trivial subgroup
##
InstallMethod( Enumerator, "for transversal by trivial subgroup", true,
    [ IsTransvByTrivSubgrp ], 0,
    tr -> Enumerator( tr!.Group ) );

#############################################################################
##
#M  Iterator( <tr> ) for transversal by trivial subgroup
##
InstallMethod( Iterator, "for transversal by trivial subgroup", true,
    [ IsTransvByTrivSubgrp ], 0,
    tr -> Iterator( tr!.Group ) );

#############################################################################
##
#M  Size( <tr> ) for transversal by trivial subgroup
##
InstallMethod( Size, "for transversal by trivial subgroup", true,
    [ IsTransvByTrivSubgrp ], 0,
    tr -> Size( tr!.Group ) );

#############################################################################
##
#M  Random( <tr> ) for transversal by trivial subgroup
##
InstallMethod( Random, "for transversal by trivial subgroup", true,
    [ IsTransvByTrivSubgrp ], 0,
    tr -> Random( tr!.Group ) );

#############################################################################
##
#M  TransversalElt( <tr>, <elt> ) for transversal by trivial subgroup
##
InstallMethod( TransversalElt, "for transversal by trivial subgroup", true,
    [ IsTransvByTrivSubgrp, IsAssociativeElement ], 0,
    function( tr, elt )
	return elt;
    end );

#############################################################################
##
#M  SiftOneLevel( <tr>, <elt> ) for transversal by trivial subgroup
##
InstallMethod( SiftOneLevel, "for transversal by trivial subgroup", true,
    [ IsTransvByTrivSubgrp, IsAssociativeElement ], 0,
    function( tr, elt )
        tr!.NumberSifted := tr!.NumberSifted + 1;
	return One( elt );
    end );

#############################################################################
#############################################################################
##
##  Transversal by sift function
##
#############################################################################
#############################################################################

#############################################################################
##
#F  TransversalBySiftFunction( <supergroup>, <subgroup>, <sift> )
##
InstallGlobalFunction( TransversalBySiftFunction,
function( supergroup, subgroup, sift )
    local Type, Rec;
    Type := NewType( TransvBySiftFunctFamily, IsRightTransversal 
                    and IsTransvBySiftFunct );
    Rec := rec( Sift := sift, ParentGroup := supergroup,
                Subgroup := subgroup, NumberSifted := 0 );
    return Objectify( Type, Rec );
end );

#############################################################################
##
#M  ViewObj( <tr> ) for transversal by sift subgroup
##
InstallMethod( ViewObj, "for transversal by sift subgroup", true,
    [ IsTransvBySiftFunct ], 0,
    function( tr )
	Print( "< transversal by sift subgroup >" );
    end );

#############################################################################
##
#M  PrintObj( <tr> ) for transversal by sift subgroup
##
InstallMethod( PrintObj, "for transversal by sift subgroup", true,
    [ IsTransvBySiftFunct ], 0,
    function( tr )
	Print( "Transversal by sift subgroup for ", tr!.Sift, "\n" );
    end );

#############################################################################
##
#M  Enumerator( <tr> ) for transversal by sift subgroup
##
InstallMethod( Enumerator, "for transversal by sift subgroup", true,
    [ IsTransvBySiftFunct ], 0,
    # gdc - ISSUE:  Enumerating group depends on enumerating transversal.
    #               So, this should not call Enumerator( tr!.ParentGroup )
    tr -> Error("not implemented") );
    # tr -> List( Enumerator( tr!.ParentGroup ), tr!.Sift ) );

##  built in iterator works fine.

#############################################################################
##
#M  Size( <tr> ) for transversal by sift subgroup
##
InstallMethod( Size, "for transversal by sift subgroup", true,
    [ IsTransvBySiftFunct ], 0,
    function( tr )
        if IsBound( tr!.Subgroup ) and HasSize( tr!.Subgroup )
           and IsBound( tr!.ParentGroup) and HasSize( tr!.ParentGroup ) then
            return Size( tr!.ParentGroup ) / Size( tr!.Subgroup );
        else TryNextMethod();  # probably will call Size(Enumerator())
        fi;
    end );

#############################################################################
##
#M  Random( <tr> ) for transversal by sift subgroup
##
InstallMethod( Random, "for transversal by sift subgroup", true,
    [ IsTransvBySiftFunct ], 0,
    tr -> tr!.Sift( Random( tr!.Group ) ) );

#############################################################################
##
#M  TransversalElt( <tr>, <elt> ) for transversal by sift subgroup
##
InstallMethod( TransversalElt, "for transversal by sift subgroup", true,
    [ IsTransvBySiftFunct, IsAssociativeElement ], 0,
    function( tr, elt )
	return elt * tr!.Sift( elt )^(-1);
    end );

#############################################################################
##
#M  SiftOneLevel( <tr>, <elt> ) for transversal by sift subgroup
##
InstallMethod( SiftOneLevel, "for transversal by sift subgroup", true,
    [ IsTransvBySiftFunct, IsAssociativeElement ], 0,
    function( tr, elt )
        tr!.NumberSifted := tr!.NumberSifted + 1;
	return tr!.Sift( elt );
    end );

#E
