#############################################################################
##
#W  semicong.gi                  GAP library   	               Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains generic methods for semigroup congruences.
##
##  Maintenance and further development by:
##  Robert F. Morse
##  Andrew Solomon
##
Revision.semicong_gi :=
    "@(#)$Id$";

######################################################################
##
##
#P  LeftSemigroupCongruenceByGeneratingPairs( <semigroup>, <gens> )
#P  RightSemigroupCongruenceByGeneratingPairs( <semigroup>, <gens> )
#P  SemigroupCongruenceByGeneratingPairs( <semigroup>, <gens> )
##
##
######################################################################

InstallMethod( LeftSemigroupCongruenceByGeneratingPairs,
    "for a Semigroup  and a list of pairs of its elements",
    IsElmsColls,
    [ IsSemigroup, IsList ], 0,
    function( M, gens )
        local cong;
        cong := LR2MagmaCongruenceByGeneratingPairsCAT(M, gens, 
                    IsLeftMagmaCongruence);
        SetIsLeftSemigroupCongruence(cong,true);
        return cong;
    end );

InstallMethod( LeftSemigroupCongruenceByGeneratingPairs,
    "for a Semigroup and an empty list",
    true,
    [ IsSemigroup, IsList and IsEmpty ], 0,
    function( M, gens )
        local cong;
        cong := LR2MagmaCongruenceByGeneratingPairsCAT(M, gens, 
                    IsLeftMagmaCongruence);
        SetIsLeftSemigroupCongruence(cong,true);
        SetEquivalenceRelationPartition(cong,[]);
        return cong;
    end );

InstallMethod( RightSemigroupCongruenceByGeneratingPairs,
    "for a Semigroup and a list of pairs of its elements",
    IsElmsColls,
    [ IsSemigroup, IsList ], 0,
    function( M, gens )
        local cong;
        cong := LR2MagmaCongruenceByGeneratingPairsCAT(M, gens, 
                    IsRightSemigroupCongruence);
        SetIsRightSemigroupCongruence(cong,true);
        return cong;
    end );

InstallMethod( RightSemigroupCongruenceByGeneratingPairs,
    "for a Semigroup and an empty list",
    true,
    [ IsSemigroup, IsList and IsEmpty ], 0,
    function( M, gens )
        local cong;
        cong := LR2MagmaCongruenceByGeneratingPairsCAT(M, gens, 
                    IsRightMagmaCongruence);
        SetIsRightSemigroupCongruence(cong,true);
        SetEquivalenceRelationPartition(cong,[]);
        return cong;
    end );

InstallMethod( SemigroupCongruenceByGeneratingPairs,
    "for a semigroup and a list of pairs of its elements",
    IsElmsColls,
    [ IsSemigroup, IsList ], 0,
    function( M, gens )
        local cong;
        cong := LR2MagmaCongruenceByGeneratingPairsCAT(M, gens, 
                    IsMagmaCongruence);
        SetIsSemigroupCongruence(cong,true);
        return cong;
    end );

InstallMethod( SemigroupCongruenceByGeneratingPairs,
    "for a semigroup and an empty list",
    true,
    [ IsSemigroup, IsList and IsEmpty], 0,
    function( M, gens )
        local cong;
        cong := LR2MagmaCongruenceByGeneratingPairsCAT(M, gens, 
                    IsMagmaCongruence);
        SetIsSemigroupCongruence(cong,true);
        SetEquivalenceRelationPartition(cong,[]);
        return cong;
    end );

#############################################################################
##
#P  IsLeftSemigroupCongruence(<c>)
#P  IsRightSemigroupCongruence(<c>)
#P  IsSemigroupCongruence(<c>)
##
InstallMethod( IsLeftSemigroupCongruence, 
    "test whether a left magma congruence is a semigroup a congruence", 
    true,
    [ IsLeftMagmaCongruence ], 0,
    function(c)
        return IsSemigroup(Source(c)); 
    end);            

InstallMethod( IsRightSemigroupCongruence, 
    "test whether a right magma congruence is a semigroup a congruence",
    true,
    [ IsRightMagmaCongruence ], 0,
    function(c)
        return IsSemigroup(Source(c)); 
    end);            

InstallMethod( IsSemigroupCongruence, 
    "test whether a magma congruence is a semigroup a congruence",
    true,
    [ IsMagmaCongruence ], 0,
    function(c)
        return IsSemigroup(Source(c)); 
    end);            

#############################################################################
##
#P  IsReesCongruence(<c>)
##
##  True precisely when the congruence has at most one
##  nonsingleton congruence class.
##
InstallMethod( IsReesCongruence,
    "for a semigroup congruence",
    true,
    [ IsSemigroupCongruence ], 0,
    function( cong )
        # recall - the partition contains only nonsingleton blocks
        return Length(EquivalenceRelationPartition(cong)) in [0,1];
    end);

InstallImmediateMethod(IsReesCongruence,
    IsSemigroupCongruence and HasEquivalenceRelationPartition, 0,
    function( c )
        return Size(EquivalenceRelationPartition(c)) = 1;
    end );


#############################################################################
##
#M  PrintObj( <smg cong> ) 
##

##  left semigroup congruence

InstallMethod( PrintObj,
    "for a left semigroup congruence",
    true,
    [ IsLeftSemigroupCongruence ], 0,
    function( S )
        Print( "LeftSemigroupCongruence( ... )" );
    end );

InstallMethod( PrintObj,
    "for a left semigroup congruence with known generating pairs",
    true,
    [ IsLeftSemigroupCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "LeftSemigroupCongruence( ", 
               GeneratingPairsOfMagmaCongruence( S ), " )" );
    end );

##  right semigroup congruence

InstallMethod( PrintObj,
    "for a right semigroup congruence",
    true,
    [ IsRightSemigroupCongruence ], 0,
    function( S )
        Print( "RightSemigroupCongruence( ... )" );
    end );

InstallMethod( PrintObj,
    "for a right semigroup congruence with known generating pairs",
    true,
    [ IsRightSemigroupCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "RightSemigroupCongruence( ", 
                   GeneratingPairsOfMagmaCongruence( S ), " )" );
    end );

##  two sided semigroup congruence

InstallMethod( PrintObj,
    "for a semigroup congruence",
    true,
    [ IsSemigroupCongruence ], 0,
    function( S )
        Print( "SemigroupCongruence( ... )" );
    end );

InstallMethod( PrintObj,
    "for a semigroup Congruence with known generating pairs",
    true,
    [ IsSemigroupCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "SemigroupCongruence( ",
               GeneratingPairsOfMagmaCongruence( S ), " )" );
    end );


#############################################################################
##
#M  ViewObj( <smg cong> ) 
##

##  left semigroup congruence

InstallMethod( ViewObj,
    "for a LeftSemigroupCongruence",
    true,
    [ IsLeftSemigroupCongruence ], 0,
    function( S )
        Print( "<LeftSemigroupCongruence>" );
    end );

InstallMethod( ViewObj,
    "for a LeftSemigroupCongruence with known generating pairs",
    true,
    [ IsLeftSemigroupCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "<LeftSemigroupCongruence with ", 
               Length( GeneratingPairsOfMagmaCongruence( S ) ), 
               " generating pairs>" );
    end );

##  right semigroup congruence

InstallMethod( ViewObj,
    "for a RightSemigrouCongruence",
    true,
    [ IsRightSemigroupCongruence ], 0,
    function( S )
        Print( "<RightSemigroupCongruence>" );
    end );

InstallMethod( ViewObj,
    "for a RightSemigroupCongruence with generators",
    true,
    [ IsRightSemigroupCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "<RightSemigroupCongruence with ", 
               Length( GeneratingPairsOfMagmaCongruence( S ) ), 
               " generating pairs>" );
    end );

## two sided semigroup congruence

InstallMethod( ViewObj,
    "for a semigroup congruence",
    true,
    [ IsSemigroupCongruence ], 0,
    function( S )
        Print( "<semigroup congruence>" );
    end );

InstallMethod( ViewObj,
    "for a semigroup Congruence with known generating pairs",
    true,
    [ IsSemigroupCongruence and HasGeneratingPairsOfMagmaCongruence ], 0,
    function( S )
        Print( "<semigroup congruence with ",
               Length(GeneratingPairsOfMagmaCongruence( S )), 
               " generating pairs>" );
    end );

#############################################################################
##
#E

