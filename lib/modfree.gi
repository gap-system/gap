#############################################################################
##
#W  modfree.gi                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains generic methods for free modules.
##
Revision.modfree_gi :=
    "@(#)$Id$";


#############################################################################
##
#M  \=( <V>, <W> )  . . . . . . . . . test if two free left modules are equal
##
InstallMethod( \=, IsIdentical, [ IsFreeLeftModule, IsFreeLeftModule ], 0,
    function( V, W )

    if IsFiniteDimensional( V ) then
      if LeftActingDomain( V ) = LeftActingDomain( W ) then
        return     Dimension( V ) = Dimension( W )
               and ForAll( GeneratorsOfLeftModule( V ), x -> x in W );
      else
        return   Dimension( V ) * DegreeOverPrimeField( LeftActingDomain(V) )
               = Dimension( W ) * DegreeOverPrimeField( LeftActingDomain(W) )
            and ForAll( GeneratorsOfLeftModule( V ), x -> x in W );
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
    IsIdentical,
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

InstallMethod( IsFinite, true, [ IsFreeLeftModule ], 0,
    V -> IsFiniteDimensional( V )
         and ( IsFinite( LeftActingDomain( V ) ) or IsTrivial( V ) ) );


#############################################################################
##
#M  IsTrivial( <V> )
##
InstallImmediateMethod( IsTrivial, IsFreeLeftModule and HasDimension, 0,
    V -> Dimension( V ) = 0 );

InstallMethod( IsTrivial, true, [ IsFreeLeftModule ], 0,
    V ->     IsFiniteDimensional( V )
         and ForAll( GeneratorsOfLeftModule( V ), IsZero ) );
#T check HasGeneratorsOfLeftModule ?


#############################################################################
##
#M  Size( <V> ) . . . . . . . . . . . . . . . . .  size of a free left module
##
InstallMethod( Size, true, [ IsFreeLeftModule ], 0,
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

InstallMethod( AsList, true, [ IsFreeLeftModule ], 0,
    AsListOfFreeLeftModule );

InstallMethod( AsListSorted, true, [ IsFreeLeftModule ], 0,
    AsListOfFreeLeftModule );
#T problem: may be called twice, but does the same job ...
#T Note that 'AsList' is not allowed to call 'AsListSorted'!


#############################################################################
##
#M  Random( <V> ) . . . . . . . . . . . . random vector of a free left module
##
InstallMethod( Random, true, [ IsFreeLeftModule ], 0,
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
InstallMethod( IsSubset, IsIdentical,
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
InstallMethod( Dimension, true, [ IsFreeLeftModule ], 0,
    function( V )
    if IsFiniteDimensional( V ) then
      return Length( BasisVectors( BasisOfDomain( V ) ) );
    else
      return infinity;
    fi;
    end );


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
InstallMethod( Enumerator, true, [ IsFreeLeftModule ], 0,
    V -> EnumeratorByBasis( BasisOfDomain( V ) ) );


#############################################################################
##
#M  Iterator( <V> )
##
##  We delegate this task to a basis of <V>.
##  *Note* that anyhow we want the possibility to iterate w.r.t.
##  a prescribed basis.
##
InstallMethod( Iterator, true, [ IsFreeLeftModule ], 0,
    V -> IteratorByBasis( BasisOfDomain( V ) ) );


#############################################################################
##
#M  ClosureLeftModule( <V>, <a> ) . . . . . . . closure of a free left module
##
InstallMethod( ClosureLeftModule, IsCollsElms,
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
FreeLeftModule := function( arg )

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
end;


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
    IsIdentical,
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
#M  PrintObj( <M> ) . . . . . . . . . . . . . . . . . .  for free left module
##
InstallMethod( PrintObj,
    "method for free left module with parent and generators",
    true,
    [ IsFreeLeftModule and HasParent and HasGeneratorsOfLeftModule ], 0,
    function( M )
    Print( "Submodule( ", Parent( M ), ", ",
           GeneratorsOfLeftModule( M ), " )" );
    end );

InstallMethod( PrintObj,
    "method for free left module with parent",
    true,
    [ IsFreeLeftModule and HasParent ], 0,
    function( M )
    Print( "Submodule( ", Parent( M ), ", ... )" );
    end );

InstallMethod( PrintObj,
    "method for free left module with generators",
    true,
    [ IsFreeLeftModule and HasGeneratorsOfLeftModule ], 0,
    function( M )
    Print( "FreeLeftModule( ", LeftActingDomain( M ), ", ",
           GeneratorsOfLeftModule( M ) );
    if IsEmpty( GeneratorsOfLeftModule( M ) ) and HasZero( M ) then
      Print( ", ", Zero( M ), " )" );
    else
      Print( " )" );
    fi;
    end );

InstallMethod( PrintObj,
    "method for free left module",
    true,
    [ IsFreeLeftModule ], 0,
    function( M )
    Print( "FreeLeftModule( ", LeftActingDomain( M ), ", ... )" );
    end );


#############################################################################
##
#R  IsRowModuleRep( <V> )
##
##  A *row module* is a free left module whose elements are lists of scalars.
##
IsRowModuleRep := NewRepresentation( "IsRowModuleRep",
    IsComponentObjectRep,
    [ "vectordim" ] );

InstallTrueMethod( IsFiniteDimensional,
    IsRowModuleRep and IsFreeLeftModule );


#############################################################################
##
#M  LeftModuleByGenerators( <R>, <mat> )  . . . . . .  construct a row module
##
InstallMethod( LeftModuleByGenerators,
    "method for ring and matrix (over the ring)",
    IsElmsColls,
    [ IsRing, IsMatrix ], 0,
    function( R, mat )
    local V;

    V:= Objectify( NewKind( FamilyObj( mat ),
                                IsLeftModule
                            and IsRowModuleRep
                            and IsAttributeStoringRep ),
                   rec() );
    SetLeftActingDomain( V, R );
    SetGeneratorsOfLeftModule( V, AsList( mat ) );
    V!.vectordim:= Length( mat[1] );

    return V;
    end );


#############################################################################
##
#M  LeftModuleByGenerators( <R>, <mat>, <zero> )  . .  construct a row module
##
InstallOtherMethod( LeftModuleByGenerators,
    "method for ring, matrix (over the ring), and row vector",
    true,
#T explicit 2nd argument above!
    [ IsRing, IsMatrix, IsRowVector ], 0,
    function( R, mat, zero )
    local V;

    # Check whether this method is the right one.
    if    not HasCollectionsFamily( FamilyObj( R ) )
       or not IsIdentical( CollectionsFamily( FamilyObj( R ) ),
                           FamilyObj( mat ) ) then
      TryNextMethod();
    fi;

    V:= Objectify( NewKind( FamilyObj( mat ),
                                IsLeftModule
                            and IsRowModuleRep
                            and IsAttributeStoringRep ),
                   rec() );
    SetLeftActingDomain( V, R );
    SetGeneratorsOfLeftModule( V, AsList( mat ) );
    SetZero( V, zero );
    V!.vectordim:= Length( mat[1] );

    return V;
    end );


#############################################################################
##
#F  FullRowModule( <R>, <n> )
##
FullRowModule := function( R, n )

    local M;   # the free module record, result

    if not ( IsRing( R ) and IsInt( n ) and 0 <= n ) then
      Error( "usage: FullRowModule( <R>, <n> ) for ring <R>" );
    fi;

    if IsDivisionRing( R ) then
      M:= Objectify( NewKind( CollectionsFamily( FamilyObj( R ) ),
                                  IsFreeLeftModule
                              and IsGaussianSpace
                              and IsRowModuleRep
                              and IsFullRowModule
                              and IsAttributeStoringRep ),
                     rec() );
    else
      M:= Objectify( NewKind( CollectionsFamily( FamilyObj( R ) ),
                                  IsFreeLeftModule
                              and IsRowModuleRep
                              and IsFullRowModule
                              and IsAttributeStoringRep ),
                     rec() );
    fi;
    SetLeftActingDomain( M, R );
    M!.vectordim:= n;

    return M;
end;


#############################################################################
##
#M  \^( <R>, <n> )  . . . . . . . . . . . . . . . full row module over a ring
#M  \^( <M>, [ <n>, <m> ] ) . . . . . . . . .  full matrix module over a ring
##
InstallOtherMethod( \^, true, [ IsRing, IsInt ], 0, FullRowModule );

#T InstallMethod( \^, true, [ IsRing, IsCyclotomicsCollection ], 0,
#T     function( R, n )
#T     if     Length( n ) = 2
#T        and IsInt( n[1] ) and 0 <= n[1]
#T        and IsInt( n[2] ) and 0 <= n[2] then
#T       if n[1] = n[2] then
#T         return FullMatrixAlgebra( R, n[1] );
#T       else
#T         return FullMatrixSpace( R, n[1], n[2] );
#T       fi;
#T     fi;
#T     TryNextMethod();
#T     end );


#############################################################################
##
#M  IsFullRowModule( M )
##
InstallMethod( IsFullRowModule,
    true,
    [ IsFreeLeftModule and IsRowModuleRep ], 0,
    M ->     Dimension( M ) = M!.vectordim
         and ForAll( GeneratorsOfLeftModule( M ),
                     v -> IsSubset( LeftActingDomain( M ), v ) ) );
     

#############################################################################
##
#M  Dimension( <M> )
##
InstallMethod( Dimension,
    "method for full row module",
    true, [ IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], 0,
    M -> M!.vectordim );


#############################################################################
##
#M  Random( <M> )
##
InstallMethod( Random,
    "method for full row module",
    true, [ IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], 0,
    function( M )
    local R;
    R:= LeftActingDomain( M );
    return List( [ 1 .. M!.vectordim ], x -> Random( R ) );
    end );


#############################################################################
##
#M  GeneratorsOfLeftModule( <V> )
##
InstallMethod( GeneratorsOfLeftModule,
    "method for full row module",
    true, [ IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], 0,
    M -> IdentityMat( M!.vectordim, LeftActingDomain( M ) ) );


#############################################################################
##
#M  Print( <M> )
##
InstallMethod( PrintObj,
    "method for full row module",
    true, [ IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], 0,
    function( M )
    Print( "( ", LeftActingDomain( M ), "^", M!.vectordim, " )" );
    end );


#############################################################################
##
#M  \in( <v>, <V> )
##
InstallMethod( \in,
    "method for full row module",
    IsElmsColls,
    [ IsRowVector, IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], 0,
    function( v, M )
    return     Length( v ) = M!.vectordim
           and IsSubset( LeftActingDomain( M ), v );
    end );


#############################################################################
##
#M  BasisVectors( <B> ) . . . . .  for a canonical basis of a full row module
##
InstallMethod( BasisVectors,
    "method for canonical basis of a full row module",
    true,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisFullRowModule ], 0,
    function( B )
    B:= UnderlyingLeftModule( B );
    return IdentityMat( B!.vectordim, LeftActingDomain( B ) );
    end );


#############################################################################
##
#M  CanonicalBasis( <V> )
##
InstallMethod( CanonicalBasis, true,
    [ IsFreeLeftModule and IsFullRowModule ], 0,
    function( V )
    local B;
    B:= Objectify( NewKind( FamilyObj( V ),
                                IsBasis
                            and IsCanonicalBasis
                            and IsCanonicalBasisFullRowModule
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    return B;
    end );


#############################################################################
##
#M  Coefficients( <B>, <v> )  . .  for a canonical basis of a full row module
##
InstallMethod( Coefficients,
    "method for canonical basis of a full row module",
    IsCollsElms,
    [ IsBasis and IsCanonicalBasisFullRowModule, IsRowVector ], 0,
    function( B, v )
    local V, R;
    V:= UnderlyingLeftModule( B );
    R:= LeftActingDomain( V );
    if Length( v ) = V!.vectordim and ForAll( v, x -> x in R ) then
      return ShallowCopy( v );
    else
      return fail;
    fi;
    end );


#############################################################################
##
#R  IsEnumeratorOfFiniteFullRowModuleRep( <iter> )
##
IsEnumeratorOfFiniteFullRowModuleRep := NewRepresentation(
    "IsEnumeratorOfFiniteFullRowModuleRep",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "coeffsenum", "q", "zerovector" ] );


#############################################################################
##
#M  Position( <enum>, <elm>, 0 )  .  for enumerator of finite full row module
##
InstallOtherMethod( Position,
    "method for enumerator via canonical basis of a finite full row module",
    true,
#T ?
#T    [ IsList and IsEnumeratorOfFiniteFullRowModuleRep, IsRowVector,
    [ IsList and IsEnumeratorOfFiniteFullRowModuleRep, IsList,
      IsZeroCyc ], 0,
    function( e, v, zero )
    local n, i;
    n:= 0;
    for i in [ PositionNot( v, zero ) .. Length( v ) ] do
      n:= e!.q * n + Position( e!.coeffsenum, v[i], 0 ) - 1;
    od;
    return n + 1;
    end );


#############################################################################
##
#M  \[\]( <enum>, <n> ) . . . . . .  for enumerator of finite full row module
##
InstallMethod( \[\],
    "method for enumerator via canonical basis of a finite full row module",
    true,
    [ IsList and IsEnumeratorOfFiniteFullRowModuleRep,
      IsPosRat and IsInt ], 0,
    function( e, n )
    local v, i;
    v:= ShallowCopy( e!.zerovector );
    i:= Length( v );
    n:= n-1;
    while 0 < n do
      v[i]:= e!.coeffsenum[ RemInt( n, e!.q ) + 1 ];
      n:= QuoInt( n, e!.q );
      i:= i-1;
    od;
    return v;
    end );


#############################################################################
##
#R  IsEnumeratorOfInfiniteFullRowModuleRep( <iter> )
##
IsEnumeratorOfInfiniteFullRowModuleRep := NewRepresentation(
    "IsEnumeratorOfInfiniteFullRowModuleRep",
    IsDomainEnumerator and IsAttributeStoringRep,
    [ "dim", "coeffsenum" ] );


#############################################################################
##
#M  Position( <enum>, <elm>, 0 )  . .  for enumerator of inf. full row module
##
InstallOtherMethod( Position,
    "method for enumerator via canonical basis of a inf. full row module",
    true,
    [ IsList and IsEnumeratorOfInfiniteFullRowModuleRep, IsRowVector,
      IsZeroCyc ], 0,
    function( enum, vector, zero )
    local n,
          i,
          max,
          maxpos,
          pos,
          len;

    n:= Length( vector );
    if n <> enum!.dim then
      return fail;
    fi;

    # Replace the entries of 'vector' by their positions.
    vector:= List( vector, x -> Position( enum!.coeffsenum, x, 0 ) - 1 );

    # Find the maximal entry in the vector, and its number.
    max:= vector[1];
    for i in [ 2 .. n ] do
      if max < vector[i] then
        max:= vector[i];
      fi;
    od;
    if max = 0 then
      return 1;
    fi;

    # Compute the positions of 'max' in 'vector',
    maxpos:= [];
    for i in [ 1 .. n ] do
      if vector[i] = max then
        Add( maxpos, i-1 );
      fi;
    od;

    # Compute the number of those elements with same distribution
    # of 'max' as in 'vector' that come before 'vector'.
    pos:= 0;
    for i in [ n, n-1 .. 1 ] do
      if vector[i] <> max then
        pos:= pos * max + vector[i];
      fi;
    od;
    pos:= pos + 1;

    # Compute the number of those elements with smaller distribution
    # of 'max'.
    # Consider the following example.
    # 1   3 4     7
    # m ? m m ? ? m ? ... ?       ('vector', the '?' mean entries < 'm')
    # * * * * * * ? ? ... ?       gives (m+1)^6 m^{n-6}
    # * * * ? ? ? m ? ... ?       gives (m+1)^3 m^{n-3-1}
    # * * ? m ? ? m ? ... ?       gives (m+1)^2 m^{n-2-2}
    # ? ? m m ? ? m ? ... ?       gives (m+1)^0 m^{n-0-3}

    len:= Length( maxpos );
    for i in [ len, len-1 .. 1 ] do
      pos:= pos + ( max + 1 )^maxpos[i] * max^( n - len - maxpos[i] + i );
    od;

    return pos;
    end );


#############################################################################
##
#M  \[\]( <enum>, <n> ) . . . . .  for enumerator of infinite full row module
##
InstallMethod( \[\],
    "method for enumerator via canonical basis of a inf. full row module",
    true,
    [ IsList and IsEnumeratorOfInfiniteFullRowModuleRep,
      IsPosRat and IsInt ], 0,
    function( enum, N )

    local n,
          val,
          max,
          maxpos,
          pos,
          vector,
          i,
          quorem;

    # Catch the special case.
    n:= enum!.dim;
    if N = 1 then
      val:= enum!.coeffsenum[1];
      return List( [ 1 .. n ], x -> val );
    fi;

    # Compute the maximal entry of the element.
    max:= 1;
    while max^n < N do
      max:= max + 1;
    od;

    # Compute the positions of the maximal entry.
    maxpos:= [];
    repeat
      pos:= 0;
      val:= (max-1)^( n - Length( maxpos ) );
      while val < N do
        pos:= pos + 1;
        val:= val * max / ( max - 1 );
      od;
      if 0 < pos then
        N:= N - val * ( max - 1 ) / max;
        Add( maxpos, pos );
      fi;
    until pos = 0;
    maxpos:= Reversed( maxpos );

    # Compute the values of the element that are strictly smaller than 'max'.
    vector:= [];
    N:= N - 1;
    for i in [ 1 .. n ] do
      if i in maxpos then
        vector[i]:= max;
      else
        quorem:= QuotientRemainder( Integers, N, max-1 );
        vector[i]:= quorem[2] + 1;
        N:= quorem[1];
      fi;
    od;

    # Translate the positions to values.
    for i in [ 1 .. n ] do
      vector[i]:= enum!.coeffsenum[ vector[i] ];
    od;

    # Return the element.
    return vector;
    end );


#############################################################################
##
#M  EnumeratorByBasis( <B> )  . . . .  for canonical basis of full row module
##
InstallMethod( EnumeratorByBasis,
    "method for enumerator via canonical basis of a full row module",
    true,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisFullRowModule ], 0,
    function( B )

    local V, F;

    V:= UnderlyingLeftModule( B );
    F:= LeftActingDomain( V );

    if IsFinite( F ) then

      F:= Objectify( NewKind( FamilyObj( V ),
                              IsEnumeratorOfFiniteFullRowModuleRep ),
                     rec(
                          coeffsenum := Enumerator( F ),
                          q          := Size( F ),
                          zerovector := Zero( V )
                         ) );
      SetUnderlyingCollection( F, V );
      return F;

    elif IsFiniteDimensional( V ) then

      # The ring is infinite, use the canonical ordering of $\N_0^n$
      # as defined for the iterator.
      F:= Objectify( NewKind( FamilyObj( V ),
                              IsEnumeratorOfInfiniteFullRowModuleRep ),
                     rec(
                          dim        := Dimension( V ),
                          coeffsenum := Enumerator( F )
                         ) );
      SetUnderlyingCollection( F, V );
      return F;

    else
      Error( "not implemented for infinite dimensional free modules" );
    fi;

    end );


#############################################################################
##
#R  IsIteratorOfFiniteFullRowModuleRep( <iter> )
##
IsIteratorOfFiniteFullRowModuleRep := NewRepresentation(
    "IsIteratorOfFiniteFullRowModuleRep",
    IsComponentObjectRep,
    [ "dimension", "counter", "position", "q", "limit", "ringelements" ] );


#############################################################################
##
#M  NextIterator( <iter> )  . . . . .  for iterator of finite full row module
##
InstallMethod( NextIterator,
    "method for iterator w.r.t. canonical basis of finite full row module",
    true,
    [ IsIterator and IsIteratorOfFiniteFullRowModuleRep ], 0,
    function( iter )
    local pos;

    # Increase the counter.
    pos:= iter!.dimension;
    while iter!.counter[ pos ] = iter!.q do
      iter!.counter[ pos ]:= 1;
      pos:= pos - 1;
    od;
    iter!.counter[ pos ]:= iter!.counter[ pos ] + 1;

    # Return the linear combination.
    return iter!.ringelements{ iter!.counter };
    end );


#############################################################################
##
#M  IsDoneIterator( <iter> )  . . . .  for iterator of finite full row module
##
InstallMethod( IsDoneIterator, true,
    [ IsIterator and IsIteratorOfFiniteFullRowModuleRep ], 0,
    iter -> iter!.counter = iter!.limit );


#############################################################################
##
#R  IsIteratorOfInfiniteFullRowModuleRep( <iter> )
##
IsIteratorOfInfiniteFullRowModuleRep := NewRepresentation(
    "IsIteratorOfInfiniteFullRowModuleRep",
    IsComponentObjectRep,
    [ "dim", "maxentry", "vector", "coeffsenum" ] );


#############################################################################
##
#M  NextIterator( <iter> )  . . . . .  for iterator of finite full row module
##
InstallMethod( NextIterator,
    "method for iterator w.r.t. canonical basis of infinite full row module",
    true,
    [ IsIterator and IsIteratorOfInfiniteFullRowModuleRep ], 0,
    function( iter )
    local dim,        # dimension of the free module
          vector,     # positions of the coefficients in 'iter!.coeffsenum'
                      # of the previous element
          result,     # coefficients of the previous element
          max1,       # one less than the maximal entry in 'vector'
          max,        # maximal entry in 'vector'
          firstval,   # first entry in 'iter!.coeffsenum'
          i;          # loop variable

    # (Increase the counter.)

    dim      := iter!.dim;
    vector   := iter!.vector;
    result   := iter!.result;
    max1     := iter!.maxentry - 1;
    firstval := iter!.firstval;

    # If not all entries in 'vector' are 'max1' or 'max1 + 1' then
    # increase the counter formed by the positions with entry
    # different from 'max1 + 1', and return the result.
    for i in [ 1 .. dim ] do
      if vector[i] < max1 then
        vector[i]:= vector[i] + 1;
        result[i]:= iter!.coeffsenum[ vector[i] ];
        return ShallowCopy( result );
      elif vector[i] = max1 then
        vector[i]:= 1;
        result[i]:= firstval;
      fi;
    od;

    # Otherwise if all entries are 'max1 + 1', increase the maximum.
    max:= iter!.maxentry;
    if dim < PositionNot( vector, max ) then
      max:= max + 1;
      iter!.maxentry:= max;
      vector[1]:= max;
      iter!.maxval:= iter!.coeffsenum[ max ];
      result[1]:= iter!.maxval;
      for i in [ 2 .. dim ] do
        vector[i]:= 1;
        result[i]:= firstval;
      od;
      return ShallowCopy( result );
    fi;

    # Otherwise get the next start configuration with maximum 'max'.
    # (The entries of 'vector' are now either '1' or 'max'.)
    for i in [ 1 .. dim ] do
      if vector[i] = max then
        vector[i]:= 1;
        result[i]:= firstval;
      else
        vector[i]:= max;
        result[i]:= iter!.maxval;
        return ShallowCopy( result );
      fi;
    od;

    Assert( 2, true,
            "there should be a position with value different from 'max'" );
    end );


#############################################################################
##
#M  IsDoneIterator( <iter> )  . . . .  for iterator of finite full row module
##
InstallMethod( IsDoneIterator, true,
    [ IsIterator and IsIteratorOfInfiniteFullRowModuleRep ], 0,
    ReturnFalse );


#############################################################################
##
#M  IteratorByBasis( <B> )  . . . . . . for canon. basis of a full row module
##
InstallMethod( IteratorByBasis,
    "method for canonical basis of a full row module",
    true,
    [ IsCanonicalBasisFullRowModule ],
    0,
    function( B )

    local V,
          F,
          dim,
          counter,
          q,
          enum,
          vector,
          firstval,
          result;

    V:= UnderlyingLeftModule( B );
    dim:= Dimension( V );

    if dim = 0 then

      return TrivialIterator( Zero( V ) );

    elif IsFinite( LeftActingDomain( V ) ) then

      F:= LeftActingDomain( V );
      counter := List( [ 1 .. dim ], x -> 1 );
      counter[ Length( counter ) ]:= 0;
      q:= Size( F );

      return Objectify( NewKind( IteratorsFamily,
                                     IsIterator
                                 and IsIteratorOfFiniteFullRowModuleRep ),
                        rec(
                            dimension    := dim,
                            counter      := counter,
                            position     := 1,
                            q            := q,
                            limit        := List( [ 1 .. dim ], x -> q ),
                            ringelements := EnumeratorSorted( F )
                           ) );

    else

      enum:= Enumerator( LeftActingDomain( V ) );
      vector:= List( [ 1 .. dim ], x -> 0 );
#     vector[1]:= -1;
      firstval:= enum[1];
      result:= List( [ 1 .. dim ], x -> firstval );

      return Objectify( NewKind( IteratorsFamily,
                                     IsIterator
                                 and IsIteratorOfInfiniteFullRowModuleRep ),
                        rec(
                             dim        := dim,
                             vector     := vector,
                             result     := result,
                             coeffsenum := enum,
                             maxentry   := 0,
                             firstval   := firstval,
                             maxval     := firstval
                           ) );

    fi;
    end );


#############################################################################
##
#M  BasisOfDomain( <M> )  . . . . . . . . . . . . . . . . for full row module
##
InstallMethod( BasisOfDomain,
    "method for full row module",
    true,
    [ IsFreeLeftModule and IsRowModuleRep and IsFullRowModule ], SUM_FLAGS,
    CanonicalBasis );


#############################################################################
##
#E  modfree.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



