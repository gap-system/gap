#############################################################################
##
#W  modfree.gi                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains generic methods for free modules.
##
Revision.modfree_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  \=( <V>, <W> )  . . . . . . . . . test if two free left modules are equal
##
InstallMethod( \=,
    "method for two free left modules (at least one fin. dim.)",
    IsIdenticalObj,
    [ IsFreeLeftModule, IsFreeLeftModule ], 0,
    function( V, W )
    local inter;
    if IsFiniteDimensional( V ) then
      if IsFiniteDimensional( W ) then
        if LeftActingDomain( V ) <> LeftActingDomain( W ) then
          inter:= Intersection2( LeftActingDomain(V), LeftActingDomain(W) );
          V:= AsVectorSpace( inter, V );
          W:= AsVectorSpace( inter, W );
        fi;
        return     Dimension( V ) = Dimension( W )
               and ForAll( GeneratorsOfLeftModule( V ), x -> x in W );
      else
        return false;
      fi;
    elif IsFiniteDimensional( W ) then
      return false;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  \<( <V>, <W> )  . . . . . . . . . . . . . .  test if <V> is less than <W>
##
##  If the left acting domains are different, compare the free modules viewed
##  over their intersection.
##  Otherwise compare the dimensions, and if both are equal,
##  delegate to canonical bases.
##
##  (Note that modules over different left acting domains can be equal,
##  so we are not allowed to compare first w.r.t. the left acting domains.)
##
InstallMethod( \<,
    "method for two free left modules",
    IsIdenticalObj,
    [ IsFreeLeftModule, IsFreeLeftModule ], 0,
    function( V, W )
    local inters, BV, BW, i;
    if LeftActingDomain( V ) <> LeftActingDomain( W ) then
      inters:= Intersection( LeftActingDomain( V ), LeftActingDomain( W ) );
      return AsLeftModule( inters, V ) < AsLeftModule( inters, W );
    elif Dimension( V ) <> Dimension( W ) then
      return Dimension( V ) < Dimension( W );
    else
      BV:= Reversed( BasisVectors( CanonicalBasis( V ) ) );
      BW:= Reversed( BasisVectors( CanonicalBasis( W ) ) );
      for i in [ 1 .. Length( BV ) ] do
        if BV[i] < BW[i] then
          return true;
        fi;
      od;
      return false;
    fi;
    end );


#############################################################################
##
#M  \in( <v>, <V> ) . . . . . . . . . .  membership test for free left module
##
##  We delegate this task to a basis.
##
InstallMethod( \in,
    "method for vector and fin. dim. free left module",
    IsElmsColls,
    [ IsVector, IsFreeLeftModule and IsFiniteDimensional ], 0,
    function( v, V )
    return Coefficients( BasisOfDomain( V ), v ) <> fail;
    end );


#############################################################################
##
#M  IsFinite( <V> ) . . . . . . . . . .  test if a free left module is finite
##
##  A free left module is finite if and only if it is trivial (that is, all
##  generators are zero) or if it is finite dimensional and the coefficients
##  domain is finite.
##
InstallImmediateMethod( IsFinite,
    IsFreeLeftModule and HasIsFiniteDimensional, 0,
    function( V )
    if not IsFiniteDimensional( V ) then
      return false;
    else
      TryNextMethod();
    fi;
    end );

InstallMethod( IsFinite,
    "method for a free left module",
    true, [ IsFreeLeftModule ], 0,
    V -> IsFiniteDimensional( V )
         and ( IsFinite( LeftActingDomain( V ) ) or IsTrivial( V ) ) );


#############################################################################
##
#M  IsTrivial( <V> )
##
InstallImmediateMethod( IsTrivial, IsFreeLeftModule and HasDimension, 0,
    V -> Dimension( V ) = 0 );

InstallMethod( IsTrivial,
    "method for a free left module",
    true, [ IsFreeLeftModule ], 0,
    V -> Dimension( V ) = 0 );


#############################################################################
##
#M  Size( <V> ) . . . . . . . . . . . . . . . . .  size of a free left module
##
InstallMethod( Size,
    "method for a free left module",
    true, [ IsFreeLeftModule ], 0,
    function( V )
    if IsFiniteDimensional( V ) then
      if   IsFinite( LeftActingDomain( V ) ) then
        return Size( LeftActingDomain( V ) ) ^ Dimension( V );
      elif IsTrivial( V ) then
        return 1;
      fi;
    fi;
    return infinity;
    end );


#############################################################################
##
#M  AsList( <V> ) . . . . . . . . . . . . . .  elements of a free left module
#M  AsListSorted( <V> ) . . . . . . . . . . .  elements of a free left module
##
##  is the set of elements of the free left module <V>,
##  computed from a basis of <V>.
##
##  Either this basis has been entered when the space was constructed, or a
##  basis is computed together with the elements list.
##
AsListOfFreeLeftModule := function( V )

    local elms,      # elements list, result
          B,         # $F$-basis of $V$
          new,       # intermediate elements list
          v,         # one generator of $V$
          i;         # loop variable

    if not IsFinite( V ) then
      Error( "cannot compute elements list of infinite domain <V>" );
    fi;

    B    := BasisOfDomain( V );
    elms := [ Zero( V ) ];
#T check whether we have the elements now ?
    for v in BasisVectors( B ) do
      new:= [];
      for i in AsList( LeftActingDomain( V ) ) do
        Append( new, List( elms, x -> x + i * v ) );
      od;
      elms:= new;
    od;
    Sort( elms );

    # Return the elements list.
    return elms;
end;

InstallMethod( AsList,
    "method for a free left module",
    true, [ IsFreeLeftModule ], 0,
    AsListOfFreeLeftModule );

InstallMethod( AsListSorted,
    "method for a free left module",
    true, [ IsFreeLeftModule ], 0,
    AsListOfFreeLeftModule );
#T problem: may be called twice, but does the same job ...
#T Note that 'AsList' is not allowed to call 'AsListSorted'!


#############################################################################
##
#M  Random( <V> ) . . . . . . . . . . . . random vector of a free left module
##
InstallMethod( Random,
    "method for a free left module",
    true, [ IsFreeLeftModule ], 0,
    function( V )

    local F;    # coefficient field of <V>

    if IsFiniteDimensional( V ) then
      F:= LeftActingDomain( V );
      return LinearCombination( BasisOfDomain( V ),
                                List( [ 1 .. Dimension( V ) ],
                                      x -> Random( F ) ) );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsSubset( <V>, <U> )
##
InstallMethod( IsSubset,
    "method for two free left modules",
    IsIdenticalObj,
    [ IsFreeLeftModule, IsFreeLeftModule ], 0,
    function( V, U )

    local base;

    if IsSubset( LeftActingDomain( V ), LeftActingDomain( U ) ) then
      return ForAll( GeneratorsOfLeftModule( U ), v -> v in V );
    else
      base:= BasisVectors( BasisOfDomain(
#T does only work if the left acting domain is a field!
#T (would work for division rings or algebras, but general rings ?)
               AsField( Intersection( LeftActingDomain( V ),
                                      LeftActingDomain( U ) ),
                        LeftActingDomain( U ) ) ) );
      return ForAll( GeneratorsOfLeftModule( U ),
                     v -> ForAll( base, x -> x * v in V ) );
    fi;
    end );


#############################################################################
##
#M  Dimension( <V> )
##
InstallMethod( Dimension,
    "method for a free left module",
    true,
    [ IsFreeLeftModule ], 0,
    function( V )
    if IsFiniteDimensional( V ) then
      return Length( BasisVectors( BasisOfDomain( V ) ) );
    else
      return infinity;
    fi;
    end );


#############################################################################
##
#M  IsFiniteDimensional( <M> )  . for a free left module with known dimension
##
InstallMethod( IsFiniteDimensional,
    "method for a free left module with known dimension",
    true,
    [ IsFreeLeftModule and HasDimension ], 0,
    M -> IsInt( Dimension( M ) ) );


#############################################################################
##
#M  GeneratorsOfLeftModule( <V> ) . left module geners. of a free left module
##
InstallImmediateMethod( GeneratorsOfLeftModule,
    IsFreeLeftModule and HasBasisOfDomain, 0,
    function( V )
    V:= BasisOfDomain( V );
    if HasBasisVectors( V ) then
      return BasisVectors( V );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Enumerator( <V> )
##
##  We delegate this task to a basis of <V>.
##  *Note* that anyhow we want the possibility to enumerate w.r.t.
##  a prescribed basis.
##
InstallMethod( Enumerator,
    "method for free left module (delegate to 'EnumeratorByBasis')",
    true,
    [ IsFreeLeftModule ], 0,
    V -> EnumeratorByBasis( BasisOfDomain( V ) ) );


#############################################################################
##
#M  Iterator( <V> )
##
##  We delegate this task to a basis of <V>.
##  *Note* that anyhow we want the possibility to iterate w.r.t.
##  a prescribed basis.
##
InstallMethod( Iterator,
    "method for free left module (delegate to 'IteratorByBasis')",
    true,
    [ IsFreeLeftModule ], 0,
    V -> IteratorByBasis( BasisOfDomain( V ) ) );


#############################################################################
##
#M  ClosureLeftModule( <V>, <a> ) . . . . . . . closure of a free left module
##
InstallMethod( ClosureLeftModule,
    "method for free left module and vector",
    IsCollsElms,
    [ IsFreeLeftModule and HasBasisOfDomain, IsVector ], 0,
    function( V, w )
    local   B;  # basis of 'V'

    # We can test membership easily.
#T why easily?
    B:= BasisOfDomain( V );
    if Coefficients( B, w ) = fail then
      return LeftModuleByGenerators( LeftActingDomain( V ),
                             Concatenation( BasisVectors( B ), [ w ] ) );
    else
      return V;
    fi;
    end );


#############################################################################
##
#F  FreeLeftModule( <R>, <gens> )
#F  FreeLeftModule( <R>, <gens>, <zero> )
#F  FreeLeftModule( <R>, <gens>, "basis" )
#F  FreeLeftModule( <R>, <gens>, <zero>, "basis" )
##
InstallGlobalFunction(FreeLeftModule,function( arg )

#T check that the families have the same characteristic?
#T 'CharacteristicFamily' ?
    local V;

    # ring and list of generators
    if Length( arg ) = 2 and IsRing( arg[1] )
                         and IsHomogeneousList( arg[2] ) then
      V:= LeftModuleByGenerators( arg[1], arg[2] );
      SetFilterObj( V, IsFreeLeftModule );

    # ring, list of generators plus zero
    elif Length( arg ) = 3 and IsRing( arg[1] )
                           and IsList( arg[2] ) then
      if arg[3] = "basis" then
        V:= LeftModuleByGenerators( arg[1], arg[2] );
        SetFilterObj( V, IsFreeLeftModule );
        UseBasis( V, arg[2] );
      else
        V:= LeftModuleByGenerators( arg[1], arg[2], arg[3] );
        SetFilterObj( V, IsFreeLeftModule );
      fi;

    # ring, list of generators plus zero
    elif Length( arg ) = 4 and IsRing( arg[1] )
                           and IsList( arg[2] )
                           and arg[4] = "basis" then
      V:= LeftModuleByGenerators( arg[1], arg[2], arg[3] );
      SetFilterObj( V, IsFreeLeftModule );
      UseBasis( V, arg[2] );

    # no argument given, error
    else
      Error( "usage: FreeLeftModule( <R>, <gens> ) ",
             "resp. FreeLeftModule( <R>, <gens>, <zero> )");
    fi;

    # Return the result.
    return V;
end);


##############################################################################
##
#M  UseBasis( <V>, <gens> )
##
##  The vectors in the list <gens> are known to form a basis of the free left
##  module <V>.
##  'UseBasis' stores information in <V> that can be derived form this fact,
##  namely
##  - <gens> are stored as left module generators if no such generators were
##    bound (this is useful especially if <V> is an algebra),
##  - the dimension of <V> is stored,
##  - a basis record is constructed from the vectors in <gens>, and if this
##    basis is semi-echelonized, or if it knows about a semi-echelonized
##    basis (this means that the basis itself is a relative basis),
##    then the nice basis is stored as '<V>.basis'.
#T Shall the overhead be avoided to compute a relative basis and then to
#T decide here that we want to forget about it ?
##
InstallMethod( UseBasis,
    "method for a free left module and a homog. list",
    true,
    [ IsFreeLeftModule, IsHomogeneousList ], 0,
    function( V, gens )
    local B;
    if not HasGeneratorsOfLeftModule( V ) then
      SetGeneratorsOfLeftModule( V, gens );
    fi;
    if not HasDimension( V ) then
      SetDimension( V, Length( gens ) );
    fi;
#T     if not IsBound( V.basis ) then
#T       B:= Basis( V, gens, true );
#T       if   IsSemiEchelonized( B ) then
#T         V.basis:= B;
#T       elif IsBound( B.basis ) then
#T         V.basis:= B.basis;
#T       fi;
#T     fi;
    end );


#############################################################################
##
#M  ViewObj( <V> )  . . . . . . . . . . . . . . . . . view a free left module
##
##  print left acting domain, if known also dimension or no. of generators
##
InstallMethod( ViewObj,
    "for free left module with known dimension",
    true,
    [ IsFreeLeftModule and HasDimension ], 0,
    function( V )
    Print( "<free left module of dimension ", Dimension( V ),
           " over ", LeftActingDomain( V ), ">" );
    end );

InstallMethod( ViewObj,
    "for free left module with known generators",
    true,
    [ IsFreeLeftModule and HasGeneratorsOfLeftModule ], 0,
    function( V )
    Print( "<free left module over ", LeftActingDomain( V ), ", with ",
           Length( GeneratorsOfLeftModule( V ) ), " generators>" );
    end );

InstallMethod( ViewObj,
    "for free left module",
    true,
    [ IsFreeLeftModule ], 0,
    function( V )
    Print( "<free left module over ", LeftActingDomain( V ), ">" );
    end );


#############################################################################
##
#M  PrintObj( <A> ) . . . . . . . . . . . . . pretty print a free left module
##
InstallMethod( PrintObj,
    "for free left module with known generators",
    true,
    [ IsFreeLeftModule and HasGeneratorsOfLeftModule ], 0,
    function( V )
    if IsEmpty( GeneratorsOfLeftModule( V ) ) then
      Print( "FreeLeftModule( ", LeftActingDomain( V ), ", [], ",
             Zero( V ), " )" );
    else
      Print( "FreeLeftModule( ", LeftActingDomain( V ), ", ",
             GeneratorsOfLeftModule( V ), " )" );
    fi;
    end );

InstallMethod( PrintObj,
    "for free left module",
    true,
    [ IsFreeLeftModule ], 0,
    function( V )
    Print( "FreeLeftModule( ", LeftActingDomain( V ), ", ... )" );
    end );


#############################################################################
##
#E  modfree.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

