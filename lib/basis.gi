#############################################################################
##
#W  basis.gi                    GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains generic methods for bases.
##
Revision.basis_gi :=
    "@(#)$Id$";


#############################################################################
##
#F  Basis( <V> )
#F  Basis( <V>, <vectors> )
##
Basis := function( arg )
    if Length( arg ) = 1 and IsFreeLeftModule( arg[1] ) then
      return BasisOfDomain( arg[1] );
    elif Length( arg ) = 2 and IsFreeLeftModule( arg[1] )
                           and IsHomogeneousList( arg[2] ) then
      return BasisByGenerators( arg[1], arg[2] );
    else
      Error( "usage: Basis( <V> ) or Basis( <V>, <vectors> )" );
    fi;
end;


#############################################################################
##
#F  SemiEchelonBasis( <V> )
#F  SemiEchelonBasis( <V>, <vectors> )
##
SemiEchelonBasis := function( arg )
    if Length( arg ) = 1 and IsFreeLeftModule( arg[1] ) then
      return SemiEchelonBasisOfDomain( arg[1] );
    elif Length( arg ) = 2 and IsFreeLeftModule( arg[1] )
                           and IsHomogeneousList( arg[2] ) then
      return SemiEchelonBasisByGenerators( arg[1], arg[2] );
    else
      Error( "usage: SemiEchelonBasis( <V> ) or \n",
             "SemiEchelonBasis( <V>, <vectors> )" );
    fi;
end;


#############################################################################
##
#M  \[\]( <B>, <i> )
#M  Position( <B>, <v> )
#M  Length( <B> )
##
##  Bases are immutable lists.
##
InstallMethod( \[\], true, [ IsBasis, IsInt and IsPosRat ], 0,
    function( B, i ) return BasisVectors( B )[i]; end );

InstallMethod( Position, true, [ IsBasis, IsObject, IsInt ], 0,
    function( B, v, from )
    return Position( BasisVectors( B ), v, from );
    end );

InstallMethod( Length, true, [ IsBasis ], 0,
    B -> Length( BasisVectors( B ) ) );


#############################################################################
##
#R  IsRelativeBasis( <obj> )
##
##  A relative basis <B> is a basis of the free left module <V>
##  that delegates the computation of coefficients etc. to another basis <C>
##  of <V> via a basechange matrix.
##
##  Relative bases need the components
##  'basis' (with value <C>) and
##  'basechangeMatrix' (with value the base change from <C> to <B>).
##
##  (Also the attribute 'BasisVectors' is always present, since relative
##  bases are always constructed with explicitly given basis vectors.)
##
IsRelativeBasis := NewRepresentation( "IsRelativeBasis",
    IsAttributeStoringRep,
    [ "basis", "basechangeMatrix" ] );


#############################################################################
##
#M  RelativeBasis( <B>, <vectors> )
##
InstallMethod( RelativeBasis, IsIdentical, [ IsBasis, IsHomogeneousList ], 0,
    function( B, vectors )

    local M,   # basechange matrix
          V,   # underlying module of 'B'
          R;   # the relative basis, result

    # Compute the basechange matrix.
    M:= List( vectors, x -> Coefficients( B, x ) );
    if 0 < Length( vectors ) then
      if    fail in M
         or Length( vectors ) <> Length( M[1] ) then
        return fail;
      fi;
      M:= M^-1;
      if M = fail then
        return fail;
      fi;
    fi;

    # If the module is not a vector space,
    # check that the base change is well-defined for the coefficients ring.
    V:= UnderlyingLeftModule( B );
    if not IsVectorSpace( V ) then
      R:= LeftActingDomain( V );
      if ForAny( M, row -> not IsSubset( R, row ) ) then
        return fail;
      fi;
    fi;

    # Construct the relative basis.
    R:= Objectify( NewKind( FamilyObj( vectors ),
                            IsBasis and IsRelativeBasis ),
                   rec() );
    SetUnderlyingLeftModule( R, V );
    SetBasisVectors( R, AsList( vectors ) );

    R!.basis            := B;
    R!.basechangeMatrix := Immutable( M );

    # Return the relative basis.
    return R;
    end );


#############################################################################
##
#M  RelativeBasisNC( <B>, <vectors> )
##
InstallMethod( RelativeBasisNC, IsIdentical,
    [ IsBasis, IsHomogeneousList ], 0,
    function( B, vectors )

    local M,   # basechange matrix
          R;   # the relative basis, result

    # Compute the basechange matrix.
    if 0 = Length( vectors ) then
      M:= [];
    else
      M:= List( vectors, x -> Coefficients( B, x ) )^-1;
    fi;

    # Construct the relative basis.
    R:= Objectify( NewKind( FamilyObj( vectors ),
                            IsBasis and IsRelativeBasis ),
                   rec() );
    SetUnderlyingLeftModule( R, UnderlyingLeftModule( B ) );
    SetBasisVectors( R, AsList( vectors ) );
    R!.basis            := B;
    R!.basechangeMatrix := Immutable( M );

    # Return the relative basis.
    return R;
    end );


#############################################################################
##
#M  PrintObj( <B> ) . . . . . . . . . . . . . . . . . . . . . . print a basis
##
##  print whether the basis is known to be semi-echelonized,
##  print the basis vectors if they are known.
##
InstallMethod( PrintObj,
    "method for a basis with basis vectors",
    true,
    [ IsBasis and HasBasisVectors ], 0,
    function( B )
    Print( "Basis( ", UnderlyingLeftModule( B ), ", ",
           BasisVectors( B ), " )" );
    end );

InstallMethod( PrintObj,
    "method for a basis",
    true,
    [ IsBasis ], 0,
    function( B )
    Print( "Basis( ", UnderlyingLeftModule( B ), ", ... )" );
    end );
#T install better method for quotient spaces, in order to print
#T representatives only ?

InstallMethod( PrintObj,
    "method for a semi-echelonized basis with basis vectors",
    true,
    [ IsBasis and HasBasisVectors and IsSemiEchelonized ], 0,
    function( B )
    Print( "SemiEchelonBasis( ", UnderlyingLeftModule( B ), ", ",
           BasisVectors( B ), " )" );
    end );

InstallMethod( PrintObj,
    "method for a semi-echelonized basis",
    true,
    [ IsBasis and IsSemiEchelonized ], 0,
    function( B )
    Print( "SemiEchelonBasis( ", UnderlyingLeftModule( B ), ", ... )" );
    end );

InstallMethod( PrintObj,
    "method for a canonical basis",
    true,
    [ IsBasis and IsCanonicalBasis ], SUM_FLAGS,
    function( B )
    Print( "CanonicalBasis( ", UnderlyingLeftModule( B ), " )" );
    end );


#############################################################################
##
#M  BasisOfDomain( <D> )
##
InstallImmediateMethod( BasisOfDomain,
    IsFreeLeftModule and HasCanonicalBasis, 0,
    CanonicalBasis );


#############################################################################
##
#M  LinearCombination( <B>, <coeff> ) . . . . . . . . lin. comb. w.r.t. basis
##
InstallMethod( LinearCombination, true, [ IsBasis, IsHomogeneousList ], 0,
    function( B, coeff )

    local vec,   # list of basis vectors of 'B'
          zero,  # zero coefficient
          v,     # linear combination, result
          i;     # loop over the basis vectors

    vec:= BasisVectors( B );
    v:= Zero( UnderlyingLeftModule( B ) );
    zero:= Zero( LeftActingDomain( UnderlyingLeftModule( B ) ) );
    for i in [ 1 .. Length( coeff ) ] do
      if coeff[i] <> zero then
        v:= v + coeff[i] * vec[i];
      fi;
    od;
    return v;
    end );

InstallOtherMethod( LinearCombination, true, [ IsList, IsList ], 0,
    function( B, coeff )
    local lincomb,
          i;
    if Length( B ) > 0 and Length( B ) = Length( coeff ) then
      lincomb:= coeff[1] * B[1];
      for i in [ 2 .. Length( B ) ] do
        lincomb:= lincomb + coeff[i] * B[i];
      od;
      return lincomb;
    else
      Error( "sorry, can't compute linear combination w.r. to <B>" );
    fi;
    end );


#############################################################################
##
#R  IsBasisSpaceEnumeratorRep
##
##  An enumerator of a basis <B> that is *not* basis of a full row space
##  delegates the task to an enumerator <E> for the corresponding coefficient
##  space (which is a full row space).
##
##  For this new representation, the following components are provided.
##  'coeffspaceenum'\:
##        (with value <E>)
##  'basis'\:
##        (with value <B>)
##
IsBasisSpaceEnumeratorRep := NewRepresentation( "IsBasisSpaceEnumeratorRep",
    IsAttributeStoringRep,
    [ "coeffsspaceenum", "basis" ] );


#############################################################################
##
#M  EnumeratorByBasis( <B> )  . . . . . . . . . . . enumerator w.r.t. a basis
##
InstallMethod( Position, true,
    [ IsDomainEnumerator and IsBasisSpaceEnumeratorRep,
      IsVector, IsZeroCyc ], 0,
    function( enum, elm, zero )
    elm:= Coefficients( enum!.basis, elm );
    if elm <> fail then
      elm:= Position( enum!.coeffspaceenum, elm );
    fi;
    return elm;
    end );

InstallMethod( \[\], true,
    [ IsDomainEnumerator and IsBasisSpaceEnumeratorRep,
      IsPosRat and IsInt ], 0,
    function( enum, n )
    n:= enum!.coeffspaceenum[ n ];
    return LinearCombination( enum!.basis, n );
    end );

InstallMethod( EnumeratorByBasis,
    "method for basis of a finite dimensional left module",
    true,
    [ IsBasis ], 0,
    function( B )
    local V;

    V:= UnderlyingLeftModule( B );
    if not IsFiniteDimensional( V ) then
      TryNextMethod();
    fi;

    # Return the enumerator.
    B:= Objectify( NewKind( FamilyObj( V ),
                                IsDomainEnumerator
                            and IsBasisSpaceEnumeratorRep ),
                   rec(
                        basis          := B,
                        coeffspaceenum := Enumerator(
                     FullRowModule( LeftActingDomain(V), Dimension(V) ) ) )
                   );
    SetUnderlyingCollection( B, V );

    return B;
    end );


#############################################################################
##
#R  IsBasisSpaceIteratorRep
##
##  An iterator of a free left module w.r.t. a basis <B> that is *not* basis
##  of a full row space delegates the task to an iterator <E> for the
##  corresponding coefficient space (which is a full row space).
##
##  For this new representation, the components
##  'coeffspaceiter' (with value <E>)
##  and 'basis' (with value <B>)
##  are provided.
##
IsBasisSpaceIteratorRep := NewRepresentation( "IsBasisSpaceIteratorRep",
    IsComponentObjectRep,
    [ "coeffspaceiter", "basis" ] );


#############################################################################
##
#M  IteratorByBasis( <B> )  . . . . . . . . . . . . . iterator w.r.t. a basis
##
InstallMethod( IsDoneIterator, true,
    [ IsIterator and IsBasisSpaceIteratorRep ], 0,
    iter -> IsDoneIterator( iter!.coeffspaceiter ) );

InstallMethod( NextIterator, true,
    [ IsIterator and IsBasisSpaceIteratorRep ], 0,
    iter -> LinearCombination( iter!.basis,
                               NextIterator( iter!.coeffspaceiter ) ) );

InstallMethod( IteratorByBasis,
    true, [ IsBasis ], 0,
    function( B )
    local V;
    V:= UnderlyingLeftModule( B );
    return Objectify(
                      NewKind( IteratorsFamily,
                               IsIterator and IsBasisSpaceIteratorRep ),
                      rec( basis          := B,
                           coeffspaceiter := IteratorByBasis( CanonicalBasis(
                                  FullRowModule( LeftActingDomain( V ),
                                                Dimension( V ) ) ) ) )
                     );
    end );


#############################################################################
##
#M  StructureConstantsTable( <B> )
##
InstallMethod( StructureConstantsTable, true, [ IsBasis ], 0,
    function( B )

    local A,        # underlying algebra
          vectors,  # basis vectors of 'A'
          i, j,
          n,
          zero,     # zero of the field
          prod,
          pos,
          empty,    # zero product, this entry is shared in the table
          sctable;  # structure constants table, result

    A:= UnderlyingLeftModule( B );

    vectors:= BasisVectors( B );
    n:= [ 1 .. Length( vectors ) ];
    zero:= Zero( LeftActingDomain( A ) );
    sctable:= [];
    empty:= [ [], [] ];

    # Fill the table.
    for i in n do
      sctable[i]:= [];
      for j in n do
        prod:= vectors[i] * vectors[j];
        prod:= Coefficients( B, prod );
        if prod = fail then
          Error( "the module of the basis <B> must be closed ",
                 "under multiplication" );
        fi;
        pos:= Filtered( n, x -> prod[x] <> zero );
        if Length( pos ) = 0 then
          sctable[i][j]:= empty;
        else
          sctable[i][j]:= Immutable( [ pos, prod{ pos } ] );
        fi;
      od;
    od;

    # Add the identification entries (symmetry flag and zero).
    n:= Length( n );
    sctable[ n+1 ]:= 0;
#T remove this flag ?
    sctable[ n+2 ]:= zero;

    # Return the table.
    return Immutable( sctable );
#T how to avoid this copy?
    end );


#############################################################################
##
##  Default methods for relative bases
##

#############################################################################
##
#M  Coefficients( <B>, <v> )  . . . . . . . . . . . . . .  for relative basis
##
InstallMethod( Coefficients,
    "method for relative basis",
    IsCollsElms,
    [ IsBasis and IsRelativeBasis, IsVector ], 0,
    function( B, v )
    v:= Coefficients( B!.basis, v );
    if v <> fail then
      v:= v * B!.basechangeMatrix;
    fi;
    return v;
    end );


#############################################################################
##
#M  BasisByGenerators( <V>, <gens> )
#M  BasisByGeneratorsNC( <V>, <gens> )
##
##  The default for this is a relative basis.
##
InstallMethod( BasisByGenerators,
    "method returning a relative basis",
    IsIdentical,
    [ IsFreeLeftModule, IsHomogeneousList ], 0,
    function( V, gens )
    return RelativeBasis( BasisOfDomain( V ), gens );
    end );

InstallMethod( BasisByGeneratorsNC,
    "method returning a relative basis",
    IsIdentical,
    [ IsFreeLeftModule, IsHomogeneousList ], 0,
    function( V, gens )
    return RelativeBasisNC( BasisOfDomain( V ), gens );
    end );


#############################################################################
##
##  Default methods for bases handled by nice bases
##

#############################################################################
##
#M  NewBasis( <V> ) . . . . . . . . . . create a basis for a free left module
#M  NewBasis( <V>, <vectors> )  . . . . create a basis for a free left module
##
InstallOtherMethod( NewBasis, true,
    [ IsFreeLeftModule and IsHandledByNiceBasis ], 0,
    function( V )
    local B;
    NiceFreeLeftModule( V );
    B:= Objectify( NewKind( FamilyObj( V ),
                            IsBasisByNiceBasis and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    return B;
    end );

InstallMethod( NewBasis, IsIdentical,
    [ IsFreeLeftModule and IsHandledByNiceBasis, IsCollection ], 0,
    function( V, vectors )
    local B;
    NiceFreeLeftModule( V );
    B:= Objectify( NewKind( FamilyObj( V ),
                            IsBasisByNiceBasis and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, AsList( vectors ) );
    return B;
    end );


#############################################################################
##
#M  NiceBasis( <B> )
##
InstallMethod( NiceBasis,
    "method for basis by nice basis",
    true,
    [ IsBasisByNiceBasis ], 0,
    function( B )
    local V;
    V:= UnderlyingLeftModule( B );
    if HasBasisVectors( B ) then
      return BasisByGenerators( NiceFreeLeftModule( V ),
                      List( BasisVectors( B ),
                            v -> NiceVector( V, v ) ) );
    else
      return BasisOfDomain( NiceFreeLeftModule( V ) );
    fi;
    end );


#############################################################################
##
#M  NiceBasisNC( <B> )
##
InstallMethod( NiceBasisNC,
    "method for basis by nice basis",
    true,
    [ IsBasisByNiceBasis ], 0,
    function( B )
    local A;
    A:= UnderlyingLeftModule( B );
    if HasBasisVectors( B ) then
      A:= BasisByGeneratorsNC( NiceFreeLeftModule( A ),
                     List( BasisVectors( B ),
                           v -> NiceVector( A, v ) ) );
    else
      A:= BasisOfDomain( NiceFreeLeftModule( A ) );
    fi;
    SetNiceBasis( B, A );
    return A;
    end );


#############################################################################
##
#M  BasisVectors( <B> )
##
InstallMethod( BasisVectors,
    "method for basis by nice basis",
    true,
    [ IsBasisByNiceBasis ], 0,
    function( B )
    local V;
    V:= UnderlyingLeftModule( B );
    return List( BasisVectors( NiceBasis( B ) ),
                 v -> UglyVector( V, v ) );
    end );


#############################################################################
##
#M  Coefficients( <B>, <v> )  . . . . . . . . for basis handled by nice basis
##
##  delegates this task to the associated basis of the nice free left module.
##
InstallMethod( Coefficients,
    "method for basis handled by nice basis, and vector",
    IsCollsElms,
    [ IsBasisByNiceBasis, IsVector ], 0,
    function( B, v )
    local n;
    n:= NiceVector( UnderlyingLeftModule( B ), v );
    if n = fail then
      return fail;
    fi;
    n:= Coefficients( NiceBasisNC( B ), n );
    if n = fail then
      return fail;
    fi;
    if LinearCombination( B, n ) = v then
      return n;
    else
      return fail;
    fi;
    end );


#############################################################################
##
#M  CanonicalBasis( <V> )
##
##  For a free left module that is handled via nice bases, the canonical
##  basis is defined as the preimage of the canonical basis of the
##  nice free left module.
##
InstallMethod( CanonicalBasis,
    "method for free module that is handled by a nice basis",
    true,
    [ IsFreeLeftModule and IsHandledByNiceBasis ], 0,
    function( V )

    local N,   # associated nice space of 'V'
          B;   # canonical basis of 'V', result

    N:= NiceFreeLeftModule( V );
    B:= BasisByGeneratorsNC( V, List( BasisVectors( CanonicalBasis( N ) ),
                              v -> UglyVector( V, v ) ) );
    SetIsCanonicalBasis( B, true );
    return B;
    end );


#############################################################################
##
#M  BasisOfDomain( <V> )
##
InstallMethod( BasisOfDomain,
    "method for free module that is handled by a nice basis",
    true,
    [ IsFreeLeftModule and IsHandledByNiceBasis ], 10,
    NewBasis );


#############################################################################
##
#M  BasisByGenerators( <V>, <gens> )
#M  BasisByGeneratorsNC( <V>, <gens> )
##
InstallMethod( BasisByGenerators,
    "method for free module that is handled by a nice basis, and hom. list",
    IsIdentical,
    [ IsFreeLeftModule and IsHandledByNiceBasis, IsHomogeneousList ], 10,
    function( V, gens )
    local B;
    B:= NewBasis( V, gens );
    if NiceBasis( B ) = fail then
      return fail;
    fi;
    return B;
    end );

InstallMethod( BasisByGeneratorsNC,
    "method for free module that is handled by a nice basis, and hom. list",
    IsIdentical,
    [ IsFreeLeftModule and IsHandledByNiceBasis, IsHomogeneousList ], 10,
    NewBasis );


#############################################################################
##
#M  NiceFreeLeftModule( <V> )
##
##  There are two default methods.
##
##  The first is available if left module generators for <V> are known;
##  it calls 'PrepareNiceFreeLeftModule( <V> )'
##  and then returns the free left module generated by the nice vectors
##  of the left module generators of <V>.
##
##  The second is available if <V> is a FLMLOR for that left operator
##  ring(-with-one) generators are known;
##  it calls 'PrepareNiceFreeLeftModule( <V> )'
##  and then computes left module generators of <V> via the process of
##  closing a basis under multiplications.
#T better treatment is needed!!
#T Compute a (mutable) basis first, and from this get the NiceFLM !!
##
InstallMethod( NiceFreeLeftModule,
    "method for free module that is handled by a nice basis",
    true,
    [ IsFreeLeftModule and IsHandledByNiceBasis ], 0,
    function( V )
    local gens;

    # Provide the necessary individual data.
    PrepareNiceFreeLeftModule( V );

    gens:= GeneratorsOfLeftModule( V );
    if IsEmpty( gens ) then
      return LeftModuleByGenerators( LeftActingDomain( V ), [],
                          NiceVector( V, Zero( V ) ) );
    else
      return LeftModuleByGenerators( LeftActingDomain( V ),
                          List( gens, v -> NiceVector( V, v ) ) );
    fi;
    end );

NiceFreeLeftModuleForFLMLOR := function( A, side )
    local Agens,     # algebra generators of 'A'
          MB;        # mutable basis, result

    # No closure under action is necessary if module generators are known.
    if HasGeneratorsOfLeftModule( A ) then
      TryNextMethod();
    fi;

    # Provide the necessary individual data.
    PrepareNiceFreeLeftModule( A );

    # Get the appropriate algebra generators.
    if HasGeneratorsOfLeftOperatorRingWithOne( A ) then
      Agens:= GeneratorsOfLeftOperatorRingWithOne( A );
    else
      Agens:= GeneratorsOfLeftOperatorRing( A );
    fi;

    # Compute a mutable basis for the closure.
    MB:= MutableBasisOfClosureUnderAction( LeftActingDomain( A ),
                                           Agens, Agens, side,
                                           Agens, Zero( A ), infinity );
      
    # Return the nice free left module.
    return NiceFreeLeftModule( UnderlyingLeftModule(
                                  ImmutableBasis( MB ) ) );
end;

InstallMethod( NiceFreeLeftModule,
    "method for FLMLOR that is handled by a nice basis",
    true,
    [ IsFLMLOR and IsHandledByNiceBasis ], 0,
    A -> NiceFreeLeftModuleForFLMLOR( A, "both" ) );

InstallMethod( NiceFreeLeftModule,
    "method for associative FLMLOR that is handled by a nice basis",
    true,
    [ IsFLMLOR and IsAssociative and IsHandledByNiceBasis ], 0,
    A -> NiceFreeLeftModuleForFLMLOR( A, "left" ) );

InstallMethod( NiceFreeLeftModule,
    "method for anticommutative FLMLOR that is handled by a nice basis",
    true,
    [ IsFLMLOR and IsAnticommutative and IsHandledByNiceBasis ], 0,
    A -> NiceFreeLeftModuleForFLMLOR( A, "left" ) );

InstallMethod( NiceFreeLeftModule,
    "method for commutative FLMLOR that is handled by a nice basis",
    true,
    [ IsFLMLOR and IsCommutative and IsHandledByNiceBasis ], 0,
    A -> NiceFreeLeftModuleForFLMLOR( A, "left" ) );


#############################################################################
##
#M  \in( <v>, <V> )
##
InstallMethod( \in,
    "method for vector and free left module that is handled by a nice basis",
    IsElmsColls,
    [ IsVector, IsFreeLeftModule and IsHandledByNiceBasis ], 0,
    function( v, V )
    local W, a;
    W:= NiceFreeLeftModule( V );
    a:= NiceVector( V, v );
    if a = fail then
      return false;
    else
      return a in W and v = UglyVector( V, a );
    fi;
    end );


#T ##########################################################################
#T ##
#T #F  SiftedVector( <B>, <v> )
#T ##
#T ##  delegates this task to the associated basis of the nice space.
#T ##
#T InstallMethod( SiftedVector, true, [ IsBasisByNiceBasis, IsObject ], 0,
#T     function( B, v )
#T     return UglyVector( B,
#T                              SiftedVector( NiceBasisNC( B ),
#T                                            NiceVector( B, v ) ) );
#T     end );


#############################################################################
##
##  Methods for empty bases.
##
##  For the construction of empty bases, default methods are sufficient.
##  Note that we would need extra methods for each representation of bases
##  otherwise, because of the family predicate.
##
##  The methods that access empty bases are there mainly to keep this
##  special case away from other bases (installation with 'SUM_FLAGS').
#T is this allowed?
#T (strictly speaking, may other bases assume that these special methods
#T will catch the special situation?)
##
InstallMethod( BasisOfDomain,
    "method for trivial free left module",
    true,
    [ IsFreeLeftModule and IsTrivial ], 0,
    function( V )
    local B;
    B:= Objectify( NewKind( FamilyObj( V ), 
                                IsBasis
                            and IsEmpty
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    return B;
    end );
    
InstallMethod( BasisByGenerators,
    "method for free left module and empty list",
    true,
    [ IsFreeLeftModule, IsList and IsEmpty ], 0,
    function( V, empty )
    local B;

    if not IsTrivial( V ) then
      Error( "<V> is not trivial" );
    fi;

    # Construct an empty basis.
    B:= Objectify( NewKind( FamilyObj( V ),
                                IsBasis
                            and IsEmpty
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, empty );

    # Return the basis.
    return B;
    end );

InstallMethod( BasisByGeneratorsNC,
    "method for free left module and empty list",
    true,
    [ IsFreeLeftModule, IsList and IsEmpty ], 0,
    function( V, empty )
    local B;

    # Construct an empty basis.
    B:= Objectify( NewKind( FamilyObj( V ),
                                IsBasis
                            and IsEmpty
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, empty );

    # Return the basis.
    return B;
    end );

InstallMethod( SemiEchelonBasisByGenerators,
    "method for free left module and empty list",
    true,
    [ IsFreeLeftModule, IsList and IsEmpty ], 0,
    function( V, empty )
    local B;

    if not IsTrivial( V ) then
      Error( "<V> is not trivial" );
    fi;

    # Construct an empty basis.
    B:= Objectify( NewKind( FamilyObj( V ),
                                IsBasis
                            and IsEmpty
                            and IsSemiEchelonized
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, empty );

    # Return the basis.
    return B;
    end );

InstallMethod( SemiEchelonBasisByGeneratorsNC,
    "method for free left module and empty list",
    true,
    [ IsFreeLeftModule, IsList and IsEmpty ], 0,
    function( V, empty )
    local B;

    # Construct an empty basis.
    B:= Objectify( NewKind( FamilyObj( V ),
                                IsBasis
                            and IsEmpty
                            and IsSemiEchelonized
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, empty );

    # Return the basis.
    return B;
    end );

InstallMethod( BasisVectors,
    "method for empty basis",
    true,
    [ IsBasis and IsEmpty ], SUM_FLAGS,
    B -> [] );

InstallMethod( Coefficients,
    "method for empty basis and vector",
    IsCollsElms,
    [ IsBasis and IsEmpty, IsVector ], SUM_FLAGS,
    function( B, v )
    if v = Zero( UnderlyingLeftModule( B ) ) then
      return [];
    else
      return fail;
    fi;
    end );

InstallMethod( LinearCombination,
    "method for empty basis and empty list",
    true,
    [ IsBasis and IsEmpty, IsList and IsEmpty ], SUM_FLAGS,
    function( B, v )
    return Zero( UnderlyingLeftModule( B ) );
    end );


#############################################################################
##
#E  basis.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



#T methods for ``generic spaces'' (works only if finite)

#T #############################################################################
#T ##
#T #F  BasisSpaceOps.AssociatedNiceSpace( <B> )
#T ##
#T ##  If space generators of the space are known, and if the space is finite
#T ##  then there is a default method to compute an associated nice space,
#T ##  namely computing all elements of the space,
#T ##  and in parallel computing a basis.
#T ##
#T ##  Otherwise there is no generic method.
#T ##
#T ##  The following components are bound in the underlying space
#T ##  after the call.
#T ##
#T ##  'elements'  : \\
#T ##          set of elements of the space,
#T ##
#T ##  'numbers'   : \\
#T ##          for each, ...
#T ##
#T ##  'exponents' : \\
#T ##          list with length the dimension of the space,
#T ##          at each position containing the size of the field,
#T ##
#T ##  'fieldelements' : \\
#T ##          elements list of the coefficients field,
#T ##
#T ##  'canonicalvectors' : \\
#T ##          elements of the underlying space that correspond to the
#T ##          canonical basis of the row space.
#T ##
#T BasisSpaceOps.AssociatedNiceSpace := function( B )
#T 
#T     local V,         # the underlying space of 'B'
#T           elms,      # set of elements, result
#T           base,      # list of basis vectors
#T           fieldelms, # elements set of the coefficients field of 'V'
#T           gen,       # loop over generators
#T           i,         # loop over field elements
#T           new,       # intermediate elements list
#T           numbers,   # list of positions of elements w.r. to construction
#T           B;         # basis record, result
#T 
#T     V    := B.structure;
#T     elms := [ Zero( V ) ];
#T     base := [];
#T 
#T     if     not IsFinite( V.field )
#T        and ForAny( SpaceGenerators( V ), x -> not x in elms ) then
#T       Error( "sorry, there is no generic method to compute\n",
#T              "an associated nice space of an infinite vector space" );
#T     fi;
#T 
#T     fieldelms:= Elements( V.field );
#T 
#T     # Form all linear combinations of the generators.
#T     # Note that we must not use known basis vectors because
#T     # otherwise we cannot check whether they really form a basis.
#T     for gen in SpaceGenerators( V ) do
#T       if not gen in elms then
#T 
#T         # Form the closure with 'gen'
#T         Add( base, gen );
#T         new:= [];
#T         for i in fieldelms do
#T           Append( new, List( elms, x -> x + i * gen ) );
#T         od;
#T         elms:= new;
#T 
#T       fi;
#T     od;
#T 
#T     # Compute the coefficients information.
#T     numbers:= [ 1 .. Length( elms ) ];
#T     SortParallel( elms, numbers );
#T 
#T     V.elements         := elms;
#T     V.numbers          := numbers;
#T     V.exponents        := List( base, x -> Length( fieldelms ) );
#T     V.fieldelements    := fieldelms;
#T     V.canonicalvectors := Reversed( base );
#T 
#T     # Return the associated space.
#T     return FullRowModule( V.field, Length( base ) );
#T     end;
#T 
#T #############################################################################
#T ##
#T #F  BasisSpaceOps.AssociatedNiceVector( <B>, <v> )
#T ##
#T BasisSpaceOps.AssociatedNiceVector := function( B, v )
#T 
#T     local V,        # underlying space
#T           pos,      # position of 'v' in the elements list
#T           coeffs;   # coefficients vector, result
#T 
#T     V:= B.structure;
#T 
#T     # Compute the $q$-adic expression.
#T     pos:= PositionSorted( V.elements, v );
#T     if pos = false then
#T       return fail;
#T     fi;
#T     coeffs:= CoefficientsInt( V.exponents, V.numbers[ pos ] - 1 ) + 1;
#T 
#T     # Compute the coefficients vector itself.
#T     coeffs:= V.fieldelements{ coeffs };
#T 
#T     # Return the coefficients vector;
#T     return coeffs;
#T     end;
#T 
#T ##############################################################################
#T ##
#T #F  BasisSpaceOps.AssociatedVector( <B>, <r> )
#T ##
#T BasisSpaceOps.AssociatedVector := function( B, r )
#T 
#T     local v,
#T           i;
#T 
#T     v:= Zero( B.structure );
#T     for i in [ 1 .. Length( r ) ] do
#T       v:= v + B.structure.canonicalvectors[i] * r[i];
#T     od;
#T     return v;
#T     end;
#T 
