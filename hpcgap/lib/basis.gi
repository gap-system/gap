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
##  This file contains generic methods for bases.
##


#############################################################################
##
#M  IsSmallList( <B> )  . . . . . . . . . . . . . . . . . . . . for any basis
##
#T  preliminary fix:
#T  Set `IsSmallList' whenever a `BasisVectors' value is entered that knows
#T  whether it is in `IsSmallList', and whenever a `UnderlyingLeftModule' is
#T  entered that knows its dimension.
#T  (This is not sufficient, since immediate methods may be switched off,
#T  but I do not like the idea to add this kind of code in each method that
#T  creates a basis object.)
##
InstallImmediateMethod( IsSmallList,
    IsBasis and HasBasisVectors and IsAttributeStoringRep, 0,
    function( B )
    B:= BasisVectors( B );
    if HasIsSmallList( B ) then
      return IsSmallList( B );
    fi;
    TryNextMethod();
    end );

InstallImmediateMethod( IsSmallList,
    IsBasis and HasUnderlyingLeftModule and IsAttributeStoringRep, 0,
    function( B )
    B:= UnderlyingLeftModule( B );
    if HasDimension( B ) then
      return Dimension( B ) <= MAX_SIZE_LIST_INTERNAL;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  IsCanonicalBasis( <B> ) . . . . . . . . . . . . . . . . . . for any basis
##
##  Note that we run into an error if no canonical basis is defined for the
##  underlying left module of <B>.
##
InstallMethod( IsCanonicalBasis,
    "for a basis",
    [ IsBasis ],
    B -> B = CanonicalBasis( UnderlyingLeftModule( B ) ) );


#############################################################################
##
#M  \[\]( <B>, <i> )
#M  Position( <B>, <v> )
#M  Length( <B> )
##
##  Bases are immutable homogeneous lists.
##
InstallMethod( \[\],
    "for a basis and a positive integer",
    [ IsBasis, IsPosInt ],
    function( B, i ) return BasisVectors( B )[i]; end );

InstallMethod( Position,
    "for a basis, an object, and a nonnegative integer",
    [ IsBasis, IsObject, IsInt ],
    function( B, v, from )
    return Position( BasisVectors( B ), v, from );
    end );

InstallMethod( Length,
    "for a basis",
    [ IsBasis ],
    B -> Length( BasisVectors( B ) ) );

InstallMethod( NumberRows,
    "for a basis that is a matrix",
    [ IsBasis and IsMatrix ],
    B -> Length( BasisVectors( B ) ) );


#############################################################################
##
#R  IsRelativeBasisDefaultRep( <obj> )
##
##  A relative basis <B> is a basis of the free left module <V>
##  that delegates the computation of coefficients etc. to another basis <C>
##  of <V> via a basechange matrix.
##
##  Relative bases in the representation `IsRelativeBasisDefaultRep' need the
##  components `basis' (with value <C>) and
##  `basechangeMatrix' (with value the base change from <C> to <B>).
##  Relative bases in this representation are allowed only for finite
##  dimensional modules.
##
##  (Also the attribute `BasisVectors' is always present, since relative
##  bases are always constructed with explicitly given basis vectors.)
##
DeclareRepresentation( "IsRelativeBasisDefaultRep",
    IsAttributeStoringRep,
    [ "basis", "basechangeMatrix" ] );

InstallTrueMethod( IsFinite, IsBasis and IsRelativeBasisDefaultRep );


#############################################################################
##
#M  RelativeBasis( <B>, <vectors> )
##
InstallMethod( RelativeBasis,
    "for a basis and a homogeneous list",
    IsIdenticalObj,
    [ IsBasis, IsHomogeneousList ],
    function( B, vectors )

    local M,   # basechange matrix
          V,   # underlying module of `B'
          R;   # the relative basis, result

    # Check that the module is finite dimensional.
    if not IsFinite( vectors ) or not IsFinite( B ) then
      Error( "<B> and <vectors> must be finite" );
    fi;

    # Compute the basechange matrix.
    M:= List( vectors, x -> Coefficients( B, x ) );
    if not IsEmpty( vectors ) then
      if fail in M or Length( vectors ) <> Length( M[1] ) then
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
    R:= Objectify( NewType( FamilyObj( vectors ),
                                IsFiniteBasisDefault
                            and IsRelativeBasisDefaultRep ),
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
InstallMethod( RelativeBasisNC,
    "for a basis and a homogeneous list",
    IsIdenticalObj,
    [ IsBasis, IsHomogeneousList ],
    function( B, vectors )

    local M,   # basechange matrix
          R;   # the relative basis, result

    # Compute the basechange matrix.
    if IsEmpty( vectors ) then
      M:= [];
    else
      M:= List( vectors, x -> Coefficients( B, x ) )^-1;
    fi;

    # Construct the relative basis.
    R:= Objectify( NewType( FamilyObj( vectors ),
                                IsFiniteBasisDefault
                            and IsRelativeBasisDefaultRep ),
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
    "for a basis with basis vectors",
    [ IsBasis and HasBasisVectors ],
    function( B )
    Print( "Basis( ", UnderlyingLeftModule( B ), ", ",
           BasisVectors( B ), " )" );
    end );

InstallMethod( PrintObj,
    "for a basis",
    [ IsBasis ],
    function( B )
    Print( "Basis( ", UnderlyingLeftModule( B ), ", ... )" );
    end );
#T install better method for quotient spaces, in order to print
#T representatives only ?

InstallMethod( PrintObj,
    "for a semi-echelonized basis with basis vectors",
    [ IsBasis and HasBasisVectors and IsSemiEchelonized ],
    function( B )
    Print( "SemiEchelonBasis( ", UnderlyingLeftModule( B ), ", ",
           BasisVectors( B ), " )" );
    end );

InstallMethod( PrintObj,
    "for a semi-echelonized basis",
    [ IsBasis and IsSemiEchelonized ],
    function( B )
    Print( "SemiEchelonBasis( ", UnderlyingLeftModule( B ), ", ... )" );
    end );

InstallMethod( PrintObj,
    "for a canonical basis",
    [ IsBasis and IsCanonicalBasis ], SUM_FLAGS,
    function( B )
    Print( "CanonicalBasis( ", UnderlyingLeftModule( B ), " )" );
    end );


#############################################################################
##
#M  ViewObj( <B> )  . . . . . . . . . . . . . . . . . . . . . .  view a basis
##
##  print whether the basis is known to be semi-echelonized,
##  instead of the basis vectors tell the dimension.
##
InstallMethod( ViewObj,
    "for a basis with basis vectors",
    [ IsBasis and HasBasisVectors ],
    function( B )
    Print( "Basis( " );
    View( UnderlyingLeftModule( B ) );
    Print( ", " );
    View( BasisVectors( B ) );
    Print( " )" );
    end );

InstallMethod( ViewObj,
    "for a basis",
    [ IsBasis ],
    function( B )
    Print( "Basis( " );
    View( UnderlyingLeftModule( B ) );
    Print( ", ... )" );
    end );

InstallMethod( ViewObj,
    "for a semi-echelonized basis with basis vectors",
    [ IsBasis and HasBasisVectors and IsSemiEchelonized ],
    function( B )
    Print( "SemiEchelonBasis( " );
    View( UnderlyingLeftModule( B ) );
    Print( ", " );
    View( BasisVectors( B ) );
    Print( " )" );
    end );

InstallMethod( ViewObj,
    "for a semi-echelonized basis",
    [ IsBasis and IsSemiEchelonized ],
    function( B )
    Print( "SemiEchelonBasis( " );
    View( UnderlyingLeftModule( B ) );
    Print( ", ... )" );
    end );

InstallMethod( ViewObj,
    "for a canonical basis",
    [ IsBasis and IsCanonicalBasis ], SUM_FLAGS,
    function( B )
    Print( "CanonicalBasis( " );
    View( UnderlyingLeftModule( B ) );
    Print( " )" );
    end );


#############################################################################
##
#M  Basis( <D> )
##
InstallImmediateMethod( Basis,
    IsFreeLeftModule and HasCanonicalBasis and IsAttributeStoringRep, 0,
    CanonicalBasis );


#############################################################################
##
#M  CanonicalBasis( <D> ) . . . . . . . . . . . . . .  default, return `fail'
##
InstallMethod( CanonicalBasis,
    "default method, return `fail'",
    [ IsFreeLeftModule ],
    ReturnFail );


#############################################################################
##
#M  LinearCombination( <B>, <coeff> ) . . . . . . . . lin. comb. w.r.t. basis
##
InstallMethod( LinearCombination,
    "for a basis and a homogeneous list",
    [ IsBasis, IsHomogeneousList ],
    function( B, coeff )

    local vec,   # list of basis vectors of `B'
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

InstallOtherMethod( LinearCombination,
    "for two lists",
    [ IsList, IsList ],
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
# why not PROD_LIST_LIST_DEFAULT or PROD_LIST_LIST_TRY ??
# (cf. method in fieldfin.gi)
# note that coeff and B may be empty, then the zero vector is returned!
# (document this for the operation!)


#############################################################################
##
#M  EnumeratorByBasis( <B> )  . . . . . . . . . . . enumerator w.r.t. a basis
##
##  An enumerator w.r.t. a basis <B> that is *not* (known to be) the
##  canonical basis of a full row space delegates the task to an enumerator
##  <E> for the canonical basis of the corresponding coefficient space;
##  a special method is installed for this case.
##
##  For this purpose, the following components are provided.
##  `coeffspaceenum':
##        (with value <E>)
##  `basis':
##        (with value <B>)
##
BindGlobal( "ElementNumber_Basis", function( enum, n )
    if Length( enum!.coeffspaceenum ) < n then
      Error( "<enum>[", n, "] must have an assigned value" );
    fi;
    return LinearCombination( enum!.basis, enum!.coeffspaceenum[ n ] );
    end );

BindGlobal( "NumberElement_Basis", function( enum, elm )
    elm:= Coefficients( enum!.basis, elm );
    if elm <> fail then
      elm:= Position( enum!.coeffspaceenum, elm );
    fi;
    return elm;
    end );

BindGlobal( "Membership_Basis", function( enum, elm )
    elm:= Coefficients( enum!.basis, elm );
    return elm <> fail;
    end );

InstallMethod( EnumeratorByBasis,
    "for basis of a finite dimensional left module",
    [ IsBasis ],
    function( B )
    local V;

    V:= UnderlyingLeftModule( B );
    if not IsFiniteDimensional( V ) then
      TryNextMethod();
    fi;

    # Return the enumerator.
    return EnumeratorByFunctions( V,
               rec( ElementNumber  := ElementNumber_Basis,
                    NumberElement  := NumberElement_Basis,
                    Membership     := Membership_Basis,

                    basis          := B,
                    coeffspaceenum := EnumeratorByBasis( CanonicalBasis(
                     FullRowModule( LeftActingDomain(V), Dimension(V) ) ) ) )
                   );
    end );


#############################################################################
##
#M  IteratorByBasis( <B> )  . . . . . . . . . . . . . iterator w.r.t. a basis
##
##  An iterator of a free left module w.r.t. a basis <B> that is *not*
##  (known to be) the basis of a full row space delegates the task to an
##  iterator <E> for the corresponding coefficient space;
##  a special method is installed for this case.
##
##  For this purpose, the following components are provided.
##  `coeffspaceiter':
##        (with value <E>)
##  `basis':
##        (with value <B>)
##
BindGlobal( "IsDoneIterator_Basis",
    iter -> IsDoneIterator( iter!.coeffspaceiter ) );

BindGlobal( "NextIterator_Basis",
    iter -> LinearCombination( iter!.basis,
                NextIterator( iter!.coeffspaceiter ) ) );

BindGlobal( "ShallowCopy_Basis",
    iter -> rec( basis          := iter!.basis,
                 coeffspaceiter := ShallowCopy(
                                       iter!.coeffspaceiter ) ) );

InstallMethod( IteratorByBasis,
    "for basis of a finite dimensional left module",
    [ IsBasis ],
    function( B )
    local V;

    # We delegate to the canonical basis of a full row module,
    # in order to avoid infinite recursion, we must guarantee
    # that `B' is not itself such a basis.
    if     ( not HasIsCanonicalBasisFullRowModule( B ) )
       and IsCanonicalBasisFullRowModule( B )
       and HasIsCanonicalBasisFullRowModule( B ) then
      return IteratorByBasis( B );
    fi;

    V:= UnderlyingLeftModule( B );
    if not IsFiniteDimensional( V ) then
      TryNextMethod();
    fi;

    return IteratorByFunctions( rec(
               IsDoneIterator := IsDoneIterator_Basis,
               NextIterator   := NextIterator_Basis,
               ShallowCopy    := ShallowCopy_Basis,

               basis          := B,
               coeffspaceiter := IteratorByBasis( CanonicalBasis(
                                     FullRowModule( LeftActingDomain( V ),
                                         Dimension( V ) ) ) ) )
                     );
    end );


#############################################################################
##
#M  StructureConstantsTable( <B> )
##
InstallMethod( StructureConstantsTable,
    "for a basis",
    [ IsBasis ],
    function( B )
    local A,        # underlying algebra
          vectors,  # basis vectors of `A'
          dim,      # dimension (length of basis)
          zero,     # zero of the field
          sctable,  # structure constants table, result
          empty,    # zero product, this entry is shared in the table
          symmetry, # symmetry flag
          calc_val, # local function
          triv,     # is the multiplication trivial?
          i, j;     # loop variables

    A:= UnderlyingLeftModule( B );
    vectors:= BasisVectors( B );
    dim:= Length( vectors );
    zero:= Zero( LeftActingDomain( A ) );

    if     HasIsZeroMultiplicationRing( A )
       and IsZeroMultiplicationRing( A ) then
      return EmptySCTable( dim, zero, "symmetric" );
    fi;

    sctable:= [];
    empty:= Immutable( [ [], [] ] );

    # Obtain (anti)symmetry information.
    if   HasIsCommutative( A ) and IsCommutative( A ) then
      symmetry:= 1;
    elif HasIsAnticommutative( A ) and IsAnticommutative( A ) then
      symmetry:= -1;
    else
      symmetry:= 0;
    fi;

    calc_val:= function ( i, j )
      local prod, pos;
      prod:= vectors[i] * vectors[j];
      prod:= Coefficients( B, prod );
      if prod = fail  then
        Error( "the module of the basis <B> must be closed ",
               "under multiplication" );
      fi;
      pos:= Filtered( [ 1 .. dim ], x -> prod[x] <> zero );
      if IsEmpty( pos ) then
        sctable[i][j]:= empty;
        return true;
      else
        sctable[i][j]:= Immutable( [ pos, prod{ pos } ] );
        return false;
      fi;
    end;

    # Compute the table entries above the diagonal.
    triv:= true;
    for i in [ 1 .. dim ] do
      sctable[i]:= [];
      for j  in [ i+1 .. dim ]  do
        triv:= calc_val( i, j ) and triv;
      od;
    od;

    # Compute the table entries on the diagonal if necessary.
    if HasIsZeroSquaredRing( A ) and IsZeroSquaredRing( A ) then
#T or (characteristic <> 2 and anticommutative)!
      for i in [ 1 .. dim ] do
        sctable[i][i] := empty;
      od;
    else
      for i in [ 1 .. dim ] do
        triv:= calc_val( i, i ) and triv;
      od;
    fi;

    # Compute/set the table entries below the diagonal.
    if   symmetry = 1 then
      for i in [ 1 .. dim ] do
        for j in [ 1 .. i-1 ] do
          sctable[i][j]:= sctable[j][i];
        od;
      od;
    elif symmetry = -1 then
      for i in [ 1 .. dim ] do
        for j in [ 1 .. i-1 ] do
          sctable[i][j]:= Immutable(
                              [ sctable[j][i][1], -sctable[j][i][2] ] );
        od;
      od;
    else
      for i in [ 1 .. dim ] do
        for j in [ 1 .. i-1 ] do
          triv:= calc_val( i, j ) and triv;
        od;
      od;
    fi;

    # If the multiplication is trivial then the table is symmetric.
    if triv then
      SetIsZeroMultiplicationRing( A, true );
      symmetry:= 1;
    fi;

    # Add the identification entries (symmetry flag and zero).
    sctable[ dim+1 ]:= symmetry;
    sctable[ dim+2 ]:= zero;

    # Return the table.
    MakeImmutable( sctable );
    return sctable;
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
    "for relative basis and vector",
    IsCollsElms,
    [ IsBasis and IsRelativeBasisDefaultRep, IsVector ],
    function( B, v )
    v:= Coefficients( B!.basis, v );
    if v <> fail then
      v:= v * B!.basechangeMatrix;
    fi;
    return v;
    end );


#############################################################################
##
#M  Basis( <V>, <gens> )
#M  BasisNC( <V>, <gens> )
##
##  The default for this is a relative basis.
##
InstallMethod( Basis,
    "method returning a relative basis",
    IsIdenticalObj,
    [ IsFreeLeftModule, IsHomogeneousList ],
    function( V, gens )
    return RelativeBasis( Basis( V ), gens );
    end );

InstallMethod( BasisNC,
    "method returning a relative basis",
    IsIdenticalObj,
    [ IsFreeLeftModule, IsHomogeneousList ],
    function( V, gens )
    UseBasis( V, gens );
    return RelativeBasisNC( Basis( V ), gens );
    end );


#############################################################################
##
##  Default methods for bases handled by nice bases
##

#############################################################################
##
#F  InstallHandlingByNiceBasis( <name>, <record> )
##
InstallGlobalFunction( "InstallHandlingByNiceBasis",
    function( name, record )

    local filter, entry;

    # Check the arguments.
    if not IsString( name ) then
      Error( "<name> must be a string" );
    elif not IsSubset( RecNames( record ),
                       [ "detect",
                         "NiceFreeLeftModuleInfo",
                         "NiceVector", "UglyVector" ] ) then
      Error( "<record> has not all necessary components" );
    fi;

    # Get the filter.
    filter:= ValueGlobal( name );

    # Install the detection of the filter.
    # The mechanism is safe only if the domain can store
    # its nice variant, thus we will install it only for cases where
    # 'IsAttributeStoringRep' is guaranteed.
    atomic readwrite NiceBasisFiltersInfo do
      entry:= First( NiceBasisFiltersInfo,
                     x -> IsIdenticalObj( filter, x[1] ) );
      entry[3] := record.detect;
    od;
    filter:= filter and IsAttributeStoringRep;
    InstallTrueMethod( IsHandledByNiceBasis, filter );

    # Install the methods.
    InstallMethod( NiceFreeLeftModuleInfo,
        Concatenation( "for left module in `", name, "'" ),
        [ filter ],
        record.NiceFreeLeftModuleInfo );

    InstallMethod( NiceVector,
        Concatenation( "for left module in `", name, "', and object" ),
        [ filter, IsObject ],
        record.NiceVector );

    InstallMethod( UglyVector,
        Concatenation( "for left module in `", name, "', and object" ),
        [ filter, IsObject ],
        record.UglyVector );
end );


#############################################################################
##
#F  CheckForHandlingByNiceBasis( <F>, <gens>, <V>, <zero> )
##
InstallGlobalFunction( "CheckForHandlingByNiceBasis",
    function( F, gens, V, zero )
    local triple, value;
    if not IsHandledByNiceBasis( V ) then
      atomic readonly NiceBasisFiltersInfo do
        for triple in NiceBasisFiltersInfo do
          value:= triple[3]( F, gens, V, zero );
          if value = true then
            SetFilterObj( V, triple[1] );
            return;
          elif value = fail then
            return;
          fi;
        od;
      od;
    fi;
end );


#############################################################################
##
#F  NiceFreeLeftModuleInfo( <V> )
#F  NiceVector( <V>, <v> )
#F  UglyVector( <V>, <r> )
##
##  A finite vector space can be handled via the mechanism of nice bases.
##  We exclude the situation that all given generators are zero (and thus the
##  vector space is trivial) because such a space should be handled be the
##  mechanism that deals with nontrivial spaces caontaining it,
##  for example in order to admit a consistent ordering of spaces via `\<'.
##
InstallHandlingByNiceBasis( "IsGenericFiniteSpace", rec(
    detect:= function( R, gens, V, zero )
      return not IsMagma( V ) and IsFinite( R ) and IsFinite( gens );
      end,

    NiceFreeLeftModuleInfo:= function( V )
      local elms,      # set of elements, result
            base,      # list of basis vectors
            fieldelms, # elements set of the coefficients field of `V'
            gen,       # loop over generators
            i,         # loop over field elements
            new,       # intermediate elements list
            numbers,   # list of positions of elements w.r. to construction
            B;         # basis record, result

      elms := [ Zero( V ) ];
      base := [];

      fieldelms:= Enumerator( LeftActingDomain( V ) );

      # Form all linear combinations of the generators.
      for gen in GeneratorsOfLeftModule( V ) do
        if not gen in elms then

          # Form the closure with `gen'
          Add( base, gen );
          new:= [];
          for i in fieldelms do
            Append( new, List( elms, x -> x + i * gen ) );
          od;
          elms:= new;

        fi;
      od;

      # Compute the coefficients information.
      numbers:= [ 1 .. Length( elms ) ];
      SortParallel( elms, numbers );

      return rec( elements         := elms,
                  numbers          := numbers,
                  q                := Length( fieldelms ),
                  fieldelements    := fieldelms,
                  base             := base );
      end,

    NiceVector:= function( V, v )
      local info, pos, n, coeffs, q, i;

      info:= NiceFreeLeftModuleInfo( V );

      # Compute the $q$-adic expression.
      pos:= Position( info.elements, v );
      if pos = fail then
        return fail;
      fi;
      n:= info.numbers[ pos ] - 1;
      coeffs:= [];
      q:= info.q;
      for i in [ 1 .. Length( info.base ) ] do
        Add( coeffs, RemInt( n, q ) + 1 );
        n:= QuoInt( n, q );
      od;

      # Compute and return the coefficients vector itself.
      return info.fieldelements{ coeffs };
      end,

    UglyVector:= function( V, r )
      local vectors;
      vectors:= NiceFreeLeftModuleInfo( V ).base;
      if Length( vectors ) = Length( r ) then
        return LinearCombination( r, vectors );
      else
        return fail;
      fi;
      end ) );


#############################################################################
##
#M  NiceFreeLeftModule( <V> )
##
##  This is the rare case where the `NiceFreeLeftModule' value is a full row
##  space.
##
InstallMethod( NiceFreeLeftModule,
    "for generic finite space (use that this is a full row module)",
    [ IsFreeLeftModule and IsGenericFiniteSpace ],
    V -> FullRowSpace( LeftActingDomain( V ),
                       Length( NiceFreeLeftModuleInfo( V ).base ) ) );


#############################################################################
##
#M  NiceFreeLeftModuleInfo( <V> )
#M  NiceVector( <V>, <v> )
#M  UglyVector( <V>, <r> )
##
##  A finite dimensional vector space of rational functions is handled via
##  the mechanism of nice bases.
##
InstallHandlingByNiceBasis( "IsSpaceOfRationalFunctions", rec(
    detect := function( F, gens, V, zero )
      return     IsRationalFunctionCollection( V ) and
         ( not IsFLMLOR( V ) or ( HasGeneratorsOfFLMLOR( V )
               and ForAll( GeneratorsOfFLMLOR( V ),
                           IsConstantRationalFunction ) ) );
      end,

    NiceFreeLeftModuleInfo := function( V )
      local gens,
            nums,
            dens,
            denom,
            monomials,
            gen,
            list,
            i,
            zero,
            info;

      gens:= GeneratorsOfLeftModule( V );

      # Compute the product of denominators.
      nums:= List( gens, NumeratorOfRationalFunction );
      dens:= List( gens, DenominatorOfRationalFunction );
      denom:= Product( dens, One( Zero( V ) ) );

      monomials:= [];

      for gen in gens do
        list:= ExtRepPolynomialRatFun( gen * denom );
        UniteSet( monomials, list{ [ 1, 3 .. Length( list ) - 1 ] } );
      od;

      zero:= Zero( LeftActingDomain( V ) );
      info:= rec( monomials := monomials,
                  denom     := denom,
                  zerocoeff := zero,
                  family    := ElementsFamily( FamilyObj( V ) ) );

      # For the zero row vector, catch the case of empty `monomials' list.
      if IsEmpty( monomials ) then
        info.zerovector := [ zero ];
      else
        info.zerovector := ListWithIdenticalEntries( Length( monomials ),
                                                     zero );
      fi;
      MakeImmutable( info.zerovector );

      return info;
      end,

    NiceVector := function( V, v )
      local info, c, monomials, i, pos;
      info:= NiceFreeLeftModuleInfo( V );
      c:= ShallowCopy( info.zerovector );
      v:= v * info.denom;
      if not IsPolynomial( v ) then
        return fail;
      fi;
      v:= ExtRepPolynomialRatFun( v );
      monomials:= info.monomials;
      for i in [ 2, 4 .. Length( v ) ] do
        pos:= Position( monomials, v[ i-1 ] );
        if pos = fail then
          return fail;
        fi;
        c[ pos ]:= v[i];
      od;
      return c;
      end,

    UglyVector := function( V, r )
      local info, list, i;
      info:= NiceFreeLeftModuleInfo( V );
      if Length( r ) <> Length( info.zerovector ) then
        return fail;
      elif IsEmpty( info.monomials ) then
        if IsZero( r ) then
          return Zero( V );
        else
          return fail;
        fi;
      fi;
      list:= [];
      for i in [ 1 .. Length( r ) ] do
        if r[i] <> info.zerocoeff then
          Add( list, info.monomials[i] );
          Add( list, r[i] );
        fi;
      od;
      return PolynomialByExtRep( info.family, list ) / info.denom;
      end ) );


#############################################################################
##
#M  NiceBasis( <B> )
##
InstallMethod( NiceBasis,
    "for basis by nice basis",
    [ IsBasisByNiceBasis ],
    function( B )
    local V;
    V:= UnderlyingLeftModule( B );
    if HasBasisVectors( B ) then
      return Basis( NiceFreeLeftModule( V ),
                    List( BasisVectors( B ), v -> NiceVector( V, v ) ) );
    else
      return Basis( NiceFreeLeftModule( V ) );
    fi;
    end );


#############################################################################
##
#M  NiceBasisNC( <B> )
##
InstallMethod( NiceBasisNC,
    "for basis by nice basis with precomputed basis",
    [ IsBasisByNiceBasis and HasNiceBasis ],
    NiceBasis );

InstallMethod( NiceBasisNC,
    "for basis by nice basis",
    [ IsBasisByNiceBasis ],
    function( B )
    local A, V;
    V:= UnderlyingLeftModule( B );
    if HasBasisVectors( B ) then
      A:= BasisNC( NiceFreeLeftModule( V ),
                   List( BasisVectors( B ), v -> NiceVector( V, v ) ) );
    else
      A:= Basis( NiceFreeLeftModule( V ) );
    fi;
    SetNiceBasis( B, A );
    return A;
    end );
#T is this operation meaningful at all??


#############################################################################
##
#M  BasisVectors( <B> )
##
InstallMethod( BasisVectors,
    "for basis by nice basis",
    [ IsBasisByNiceBasis ],
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
    "for basis handled by nice basis, and vector",
    IsCollsElms,
    [ IsBasisByNiceBasis, IsVector ],
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
#M  CanonicalBasis( <V> ) . . . . . . . for free module handled by nice basis
##
##  For a free left module that is handled via nice bases, the canonical
##  basis is defined as the preimage of the canonical basis of the
##  nice free left module.
##
InstallMethod( CanonicalBasis,
    "for free module that is handled by a nice basis",
    [ IsFreeLeftModule and IsHandledByNiceBasis ],
    function( V )

    local N,   # associated nice space of `V'
          B;   # canonical basis of `V', result

    N:= NiceFreeLeftModule( V );
    B:= BasisNC( V, List( BasisVectors( CanonicalBasis( N ) ),
                              v -> UglyVector( V, v ) ) );
    SetIsCanonicalBasis( B, true );
    return B;
    end );


#############################################################################
##
#M  IsCanonicalBasis( <B> ) . . . . . . . . . for basis handled by nice basis
##
InstallMethod( IsCanonicalBasis,
    "for a basis handled by a nice basis",
    [ IsBasisByNiceBasis ],
    function( B )
    local V;
    V:= UnderlyingLeftModule( B );
    B:= BasisNC( V, List( BasisVectors( B ), v -> NiceVector( V, v ) ) );
    return IsCanonicalBasis( B );
    end );


#############################################################################
##
#M  Basis( <V> )  . . . . . . . . . . . for free module handled by nice basis
##
BindGlobal( "BasisForFreeModuleByNiceBasis", function( V )
    local B;
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsBasisByNiceBasis
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    return B;
end );

InstallMethod( Basis,
    "for free module that is handled by a nice basis",
    [ IsFreeLeftModule and IsHandledByNiceBasis ],
    BasisForFreeModuleByNiceBasis );


#############################################################################
##
#M  Basis( <V>, <vectors> )
#M  BasisNC( <V>, <vectors> )
##
InstallMethod( Basis,
    "for free module that is handled by a nice basis, and hom. list",
    IsIdenticalObj,
    [ IsFreeLeftModule and IsHandledByNiceBasis, IsHomogeneousList ],
    function( V, vectors )
    local B;

    # Create the basis object.
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsBasisByNiceBasis
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, vectors );

    # Check whether the vectors in fact form a basis.
    if NiceBasis( B ) = fail then
      return fail;
    fi;

    # Use the basis information.
    UseBasis( V, vectors );

    # Return the result.
    return B;
    end );

InstallMethod( BasisNC,
    "for free module that is handled by a nice basis, and hom. list",
    IsIdenticalObj,
    [ IsFreeLeftModule and IsHandledByNiceBasis, IsHomogeneousList ],
    function( V, vectors )
    local B;

    # Create the basis object.
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsBasisByNiceBasis
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, vectors );

    # Use the basis information.
    UseBasis( V, vectors );

    # Return the result.
    return B;
    end );


#############################################################################
##
#M  NiceFreeLeftModule( <V> )
##
##  There are two default methods.
##
##  The first is available if left module generators for <V> are known;
##  it returns the free left module generated by the nice vectors
##  of the left module generators of <V>.
##
##  The second is available if <V> is a FLMLOR for which left operator
##  ring(-with-one) generators are known;
##  it computes left module generators of <V> via the process of
##  closing a basis under multiplications.
##
InstallMethod( NiceFreeLeftModule,
    "for free module that is handled by a nice basis",
    [ IsFreeLeftModule and HasGeneratorsOfLeftModule
                       and IsHandledByNiceBasis ],
    function( V )
    local gens;

    gens:= GeneratorsOfLeftModule( V );
    if IsEmpty( gens ) or ForAll( gens, IsZero ) then
      return LeftModuleByGenerators( LeftActingDomain( V ), [],
                          NiceVector( V, Zero( V ) ) );
    else
      return LeftModuleByGenerators( LeftActingDomain( V ),
                          List( gens, v -> NiceVector( V, v ) ) );
    fi;
    end );

BindGlobal( "NiceFreeLeftModuleForFLMLOR", function( A, side )

    local Agens,     # algebra generators of `A'
          F,         # left acting domain of `A'
          MB,        # mutable basis, result
          Vgens,     # left module generators
          v;         # loop variable

    # No closure under action is necessary if module generators are known.
    if HasGeneratorsOfLeftModule( A ) then
      TryNextMethod();
    fi;

    # Get the algebra generators.
    Agens:= GeneratorsOfLeftOperatorRing( A );
    F:= LeftActingDomain( A );

    # Compute a mutable basis for `A'.
    # If `A' is associative or a Lie algebra then we may use
    # `MutableBasisOfClosureUnderAction', otherwise we need
    # `MutableBasisOfNonassociativeAlgebra'.
    if ( HasIsAssociative( A ) and IsAssociative( A ) )
       or ( HasIsLieAlgebra( A ) and IsLieAlgebra( A ) ) then
      MB:= MutableBasisOfClosureUnderAction( F,
                                             Agens,
                                             side,
                                             Agens,
                                             \*,
                                             Zero( A ),
                                             infinity );
    else
      MB:= MutableBasisOfNonassociativeAlgebra( F,
                                                Agens,
                                                Zero( A ),
                                                infinity );
    fi;

    # Store left module generators.
    Vgens:= BasisVectors( ImmutableBasis( MB ) );
    UseBasis( A, Vgens );

    # (Now `A' knows left module generators.)
    if IsEmpty( Vgens ) then
      return LeftModuleByGenerators( F, [],
                          NiceVector( A, Zero( A ) ) );
    else
      return LeftModuleByGenerators( F,
                          List( Vgens, v -> NiceVector( A, v ) ) );
    fi;
end );

InstallMethod( NiceFreeLeftModule,
    "for FLMLOR that is handled by a nice basis",
    [ IsFLMLOR and IsHandledByNiceBasis ],
    A -> NiceFreeLeftModuleForFLMLOR( A, "both" ) );

InstallMethod( NiceFreeLeftModule,
    "for associative FLMLOR that is handled by a nice basis",
    [ IsFLMLOR and IsAssociative and IsHandledByNiceBasis ],
    A -> NiceFreeLeftModuleForFLMLOR( A, "left" ) );

InstallMethod( NiceFreeLeftModule,
    "for anticommutative FLMLOR that is handled by a nice basis",
    [ IsFLMLOR and IsAnticommutative and IsHandledByNiceBasis ],
    A -> NiceFreeLeftModuleForFLMLOR( A, "left" ) );

InstallMethod( NiceFreeLeftModule,
    "for commutative FLMLOR that is handled by a nice basis",
    [ IsFLMLOR and IsCommutative and IsHandledByNiceBasis ],
    A -> NiceFreeLeftModuleForFLMLOR( A, "left" ) );


#############################################################################
##
#M  \in( <v>, <V> )
##
InstallMethod( \in,
    "for vector and free left module that is handled by a nice basis",
    IsElmsColls,
    [ IsVector, IsFreeLeftModule and IsHandledByNiceBasis ],
    function( v, V )
    local W, a;
    W:= NiceFreeLeftModule( V );
    a:= NiceVector( V, v );
    if a = fail then
      return false;
    elif IsZero(a) then
      return true;
    else
      return a in W and v = UglyVector( V, a );
    fi;
    end );


#############################################################################
##
##  Methods for empty bases.
##
##  For the construction of empty bases, default methods are sufficient.
##  Note that we would need extra methods for each representation of bases
##  otherwise, because of the family predicate.
##
##  The methods that access empty bases are there mainly to keep this
##  special case away from other bases (installation with `SUM_FLAGS').
#T is this allowed?
#T (strictly speaking, may other bases assume that these special methods
#T will catch the special situation?)
##
InstallMethod( Basis,
    "for trivial free left module",
    [ IsFreeLeftModule and IsTrivial ],
    function( V )
    local B;
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsEmpty
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    return B;
    end );

InstallMethod( Basis,
    "for free left module and empty list",
    [ IsFreeLeftModule, IsList and IsEmpty ],
    function( V, empty )
    local B;

    if not IsTrivial( V ) then
      Error( "<V> is not trivial" );
    fi;

    # Construct an empty basis.
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsEmpty
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, empty );

    # Return the basis.
    return B;
    end );

InstallMethod( BasisNC,
    "for free left module and empty list",
    [ IsFreeLeftModule, IsList and IsEmpty ],
    function( V, empty )
    local B;

    # Construct an empty basis.
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsEmpty
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, empty );

    # Return the basis.
    return B;
    end );

InstallMethod( SemiEchelonBasis,
    "for free left module and empty list",
    [ IsFreeLeftModule, IsList and IsEmpty ],
    function( V, empty )
    local B;

    if not IsTrivial( V ) then
      Error( "<V> is not trivial" );
    fi;

    # Construct an empty basis.
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
                            and IsEmpty
                            and IsSemiEchelonized
                            and IsAttributeStoringRep ),
                   rec() );
    SetUnderlyingLeftModule( B, V );
    SetBasisVectors( B, empty );

    # Return the basis.
    return B;
    end );

InstallMethod( SemiEchelonBasisNC,
    "for free left module and empty list",
    [ IsFreeLeftModule, IsList and IsEmpty ],
    function( V, empty )
    local B;

    # Construct an empty basis.
    B:= Objectify( NewType( FamilyObj( V ),
                                IsFiniteBasisDefault
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
    "for empty basis",
    [ IsBasis and IsEmpty ], SUM_FLAGS,
    B -> [] );

InstallMethod( Coefficients,
    "for empty basis and vector",
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
    "for empty basis and empty list",
    [ IsBasis and IsEmpty, IsList and IsEmpty ], SUM_FLAGS,
    function( B, v )
    return Zero( UnderlyingLeftModule( B ) );
    end );

InstallMethod( SiftedVector,
    "for empty basis and vector",
    IsCollsElms,
    [ IsBasis and IsEmpty, IsVector ], SUM_FLAGS,
    function( B, v )
    return v;
    end );


#############################################################################
##
#R  IsBasisWithReplacedLeftModuleRep( <B> )
##
DeclareRepresentation( "IsBasisWithReplacedLeftModuleRep",
    IsAttributeStoringRep, [ "basisWithWrongModule" ] );


#############################################################################
##
#F  BasisWithReplacedLeftModule( <B>, <V> )
##
InstallGlobalFunction( BasisWithReplacedLeftModule, function( B, V )
    local new;

    new:= Objectify( NewType( FamilyObj( B ),
                                  IsFiniteBasisDefault
                              and IsBasisWithReplacedLeftModuleRep ),
                     rec() );
    SetUnderlyingLeftModule( new, V );
    new!.basisWithWrongModule:= B;

    return new;
end );


#############################################################################
##
#M  BasisVectors( <B> )
##
InstallMethod( BasisVectors,
    "for a basis with replaced left module",
    [ IsBasis and IsBasisWithReplacedLeftModuleRep ],
    B -> BasisVectors( B!.basisWithWrongModule ) );


#############################################################################
##
#M  Coefficients( <B>, <v> )
##
InstallMethod( Coefficients,
    "for a basis with replaced left module, and a vector",
    IsCollsElms,
    [ IsBasis and IsBasisWithReplacedLeftModuleRep, IsVector ],
    function( B, v )
    return Coefficients( B!.basisWithWrongModule, v );
    end );


#############################################################################
##
#M  LinearCombination( <B>, <v> )
##
InstallMethod( LinearCombination,
    "for a basis with replaced left module, and a hom. list",
    [ IsBasis and IsBasisWithReplacedLeftModuleRep, IsHomogeneousList ],
    function( B, v )
    return LinearCombination( B!.basisWithWrongModule, v );
    end );


#############################################################################
##
#M  IsCanonicalBasis( <B> )
##
InstallMethod( IsCanonicalBasis,
    "for a basis with replaced left module, and a vector",
    [ IsBasis and IsBasisWithReplacedLeftModuleRep ],
    B -> IsCanonicalBasis( B!.basisWithWrongModule ) );
