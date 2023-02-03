#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Thomas Breuer.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains generic methods for free left modules.
##


#############################################################################
##
#M  \=( <V>, <W> )  . . . . . . . . . test if two free left modules are equal
##
##  This method is used also for algebras and algebras-with-one,
##  in particular also for infinite dimensional vector spaces.
##  Note that no generators are accessed here,
##  this happens in the method chosen for `IsSubset'.
##
InstallMethod( \=,
    "for two free left modules (at least one fin. dim.)",
    IsIdenticalObj,
    [ IsFreeLeftModule, IsFreeLeftModule ],
    function( V, W )

    # If the dimensions of the two free modules are known and are different
    # then we need not look at elements.
    if     HasDimension( V ) and HasDimension( W )
       and IsIdenticalObj( LeftActingDomain( V ), LeftActingDomain( W ) ) then
      if   Dimension( V ) <> Dimension( W ) then
        return false;
      elif IsInt( Dimension( V ) ) then
        # Only one inclusion must be tested.
        return IsSubset( V, W );
      fi;
    fi;

    # Check the inclusions.
    return IsSubset( V, W ) and IsSubset( W, V );
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
    "for two free left modules",
    IsIdenticalObj,
    [ IsFreeLeftModule, IsFreeLeftModule ],
    function( V, W )
    local inters;
    if LeftActingDomain( V ) <> LeftActingDomain( W ) then
      inters:= Intersection( LeftActingDomain( V ), LeftActingDomain( W ) );
      return AsLeftModule( inters, V ) < AsLeftModule( inters, W );
    elif Dimension( V ) <> Dimension( W ) then
      return Dimension( V ) < Dimension( W );
    else
      return   Reversed( BasisVectors( CanonicalBasis( V ) ) )
             < Reversed( BasisVectors( CanonicalBasis( W ) ) );
    fi;
    end );


#############################################################################
##
#M  \in( <v>, <V> ) . . . . . . . . . .  membership test for free left module
##
##  We delegate this task to a basis.
##
InstallMethod( \in,
    "for vector and fin. dim. free left module",
    IsElmsColls,
    [ IsVector, IsFreeLeftModule and IsFiniteDimensional ],
    function( v, V )
    return Coefficients( Basis( V ), v ) <> fail;
    end );


#############################################################################
##
#M  IsFinite( <V> ) . . . . . . . . . .  test if a free left module is finite
##
##  A free left module is finite if and only if it is trivial (that is, all
##  generators are zero) or if it is finite dimensional and the coefficients
##  domain is finite.
##
##  Note that we have to be careful not to delegate to `IsFinite' for the
##  left acting domain if the module is equal to its left acting domain,
##  which may occur for fields.
##  (Note that no special method for a FLMLOR, FLMLOR-with-one, or division
##  ring is needed since all generator dependent questions are handled in the
##  `IsTrivial' call.)
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
    "for a free left module",
    [ IsFreeLeftModule ],
    function( V )
    if not IsFiniteDimensional( V ) then
      return false;
    elif IsTrivial( V ) then
      return true;
    elif V <> LeftActingDomain( V ) then
      return IsFinite( LeftActingDomain( V ) );
    elif Characteristic( V ) = 0 then
      return false;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  IsTrivial( <V> )
##
InstallImmediateMethod( IsTrivial, IsFreeLeftModule and HasDimension, 0,
    V -> Dimension( V ) = 0 );

InstallMethod( IsTrivial,
    "for a free left module",
    [ IsFreeLeftModule ],
    V -> Dimension( V ) = 0 );


#############################################################################
##
#M  Size( <V> ) . . . . . . . . . . . . . . . . .  size of a free left module
##
InstallMethod( Size,
    "for a free left module",
    [ IsFreeLeftModule ],
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
#M  AsSSortedList( <V> ) . . . . . . . . . . .  elements of a free left module
##
##  is the set of elements of the free left module <V>,
##  computed from a basis of <V>.
##
##  Either this basis has been entered when the space was constructed, or a
##  basis is computed together with the elements list.
##
BindGlobal( "AsListOfFreeLeftModule", function( V )
    local elms,      # elements list, result
          B,         # $F$-basis of $V$
          new,       # intermediate elements list
          v,         # one generator of $V$
          i;         # loop variable

    if not IsFinite( V ) then
      Error( "cannot compute elements list of infinite domain <V>" );
    fi;

    B    := Basis( V );
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
end );

InstallMethod( AsList,
    "for a free left module",
    [ IsFreeLeftModule ],
    AsListOfFreeLeftModule );

InstallMethod( AsSSortedList,
    "for a free left module",
    [ IsFreeLeftModule ],
    AsListOfFreeLeftModule );
#T problem: may be called twice, but does the same job ...
#T Note that 'AsList' is not allowed to call 'AsSSortedList'!


#############################################################################
##
#M  Random( <V> ) . . . . . . . . . . . . random vector of a free left module
##
InstallMethodWithRandomSource( Random,
    "for a random source and a free left module",
    [ IsRandomSource, IsFreeLeftModule ],
    function( rs, V )
    local F;    # coefficient field of <V>

    if IsFiniteDimensional( V ) then
      F:= LeftActingDomain( V );
      return LinearCombination( Basis( V ),
                                List( [ 1 .. Dimension( V ) ],
                                      x -> Random( rs, F ) ) );
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#F  GeneratorsOverIntersection( <V>, <gens>, <K>, <L> )
##
##  Let <gens> be a list of (vector space, algebra, algebra-with-one, field)
##  generators of a <K>-free left module <V>,
##  and <L> be a field with the same prime field as <K>.
##  Furthermore, let $I$ be the intersection of <K> and <L>,
##  and let $B$ be an $I$-basis of <K>.
##  If <gens> is nonempty then `GeneratorsOverIntersection' returns
##  the list containing $\{ b \cdot a; b \in B, a \in <gens> \}$,
##  which is a set of generators (in the same sense) of <V> over <L>.
##  If <gens> is empty then the list containing the zero element of <V> is
##  returned.
##
##  This function is used for `IsSubset' methods for vector spaces, algebras,
##  algebras-with-one.
##  Note that in `IsSubset', we want to avoid delegating to structures with
##  equal `LeftActingDomain' value, mainly because we want to use the
##  membership test for the original arguments of `IsSubset' rather than for
##  newly created objects.
##
BindGlobal( "GeneratorsOverIntersection", function( V, gens, K, L )
    local I, B;

    if   IsEmpty( gens ) then
      return [ Zero( V ) ];
    elif IsSubset( L, K ) then
      return gens;
    elif IsSubset( K, L ) then
      I:= L;
    else
      I:= Intersection( K, L );
    fi;
    K:= AsField( I, K );
    Assert( 1, IsFiniteDimensional( K ) );
    B:= BasisVectors( Basis( K ) );
    return Concatenation( List( B, b -> List( gens, a -> b * a ) ) );
    end );


#############################################################################
##
#M  IsSubset( <V>, <U> )
##
##  This method is used also in situations where <U> is a (perhaps infinite
##  dimensional) algebra but <V> is not.
##
InstallMethod( IsSubset,
    "for two free left modules",
    IsIdenticalObj,
    [ IsFreeLeftModule, IsFreeLeftModule ],
    function( V, U )
    local K, L;
    K:= LeftActingDomain( U );
    L:= LeftActingDomain( V );
    if   IsFiniteDimensional( U ) then
#T does only work if the left acting domain is a field!
#T (would work for division rings or algebras, but general rings ?)
      return IsSubset( V, GeneratorsOverIntersection(
                              U, GeneratorsOfLeftModule( U ), K, L ) );
    elif     IsFiniteDimensional( V )
         and IsFiniteDimensional( AsField( Intersection2( K, L ), L ) ) then
      return false;
    else
      # For two infinite dimensional modules, we should have succeeded
      # in a more special method.
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#M  Dimension( <V> )
##
InstallMethod( Dimension,
    "for a free left module",
    [ IsFreeLeftModule ],
    function( V )
    if IsFiniteDimensional( V ) then
      return Length( BasisVectors( Basis( V ) ) );
    else
      return infinity;
    fi;
    end );


#############################################################################
##
#M  IsFiniteDimensional( <M> )  . for a free left module with known dimension
##
InstallMethod( IsFiniteDimensional,
    "for a free left module with known dimension",
    [ IsFreeLeftModule and HasDimension ],
    M -> IsInt( Dimension( M ) ) );


#############################################################################
##
#M  GeneratorsOfLeftModule( <V> ) . left module geners. of a free left module
##
InstallImmediateMethod( GeneratorsOfLeftModule,
    IsFreeLeftModule and HasBasis and IsAttributeStoringRep, 0,
    function( V )
    V:= Basis( V );
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
    "for free left module (delegate to 'EnumeratorByBasis')",
    [ IsFreeLeftModule ],
    V -> EnumeratorByBasis( Basis( V ) ) );


#############################################################################
##
#M  Iterator( <V> )
##
##  We delegate this task to a basis of <V>.
##  *Note* that anyhow we want the possibility to iterate w.r.t.
##  a prescribed basis.
##
InstallMethod( Iterator,
    "for free left module (delegate to 'IteratorByBasis')",
    [ IsFreeLeftModule ],
    V -> IteratorByBasis( Basis( V ) ) );


#############################################################################
##
#M  ClosureLeftModule( <V>, <a> ) . . . . . . . closure of a free left module
##
InstallMethod( ClosureLeftModule,
    "for free left module and vector",
    IsCollsElms,
    [ IsFreeLeftModule and HasBasis, IsVector ],
    function( V, w )
    local   B;  # basis of 'V'

    # We can test membership easily.
#T why easily?
    B:= Basis( V );
    if Coefficients( B, w ) = fail then
      return LeftModuleByGenerators( LeftActingDomain( V ),
                             Concatenation( BasisVectors( B ), [ w ] ) );
    else
      return V;
    fi;
    end );


#############################################################################
##
#F  FreeLeftModule( <R>, <gens>[, <zero>][, "basis"] )
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
      Error( "usage: FreeLeftModule( <R>, <gens>[, <zero>][, \"basis\"] )");
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
    "for a free left module and a homog. list",
    [ IsFreeLeftModule, IsHomogeneousList ],
    function( V, gens )
#T    local B;
    if not HasGeneratorsOfLeftModule( V ) then
      SetGeneratorsOfLeftModule( V, gens );
    fi;
    if not HasDimension( V ) then
      SetDimension( V, Length( gens ) );
    fi;
#T     if not HasBasis( V ) then
#T       B:= BasisNC( V, gens );
#T       if   IsSemiEchelonized( B ) then
#T         SetBasis( V, B );
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
    [ IsFreeLeftModule and HasDimension ],
    function( V )
    Print( "<free left module of dimension ", Dimension( V ),
           " over ", LeftActingDomain( V ), ">" );
    end );

InstallMethod( ViewObj,
    "for free left module with known generators",
    [ IsFreeLeftModule and HasGeneratorsOfLeftModule ],
    function( V )
    Print( "<free left module over ", LeftActingDomain( V ), ", with ",
           Pluralize( Length( GeneratorsOfLeftModule( V ) ), "generator" ),
           ">" );
    end );

InstallMethod( ViewObj,
    "for free left module",
    [ IsFreeLeftModule ],
    function( V )
    Print( "<free left module over ", LeftActingDomain( V ), ">" );
    end );


#############################################################################
##
#M  PrintObj( <A> ) . . . . . . . . . . . . . pretty print a free left module
##
InstallMethod( PrintObj,
    "for free left module with known generators",
    [ IsFreeLeftModule and HasGeneratorsOfLeftModule ],
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
    [ IsFreeLeftModule ],
    function( V )
    Print( "FreeLeftModule( ", LeftActingDomain( V ), ", ... )" );
    end );
