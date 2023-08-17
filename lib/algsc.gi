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
##  This file contains methods for elements of algebras given by structure
##  constants (s.~c.).
##
##  The family of s.~c. algebra elements has the following components.
##
##  `sctable' :
##        the structure constants table,
##  `names' :
##        list of names of the basis vectors (for printing only),
##  `zerocoeff' :
##        the zero coefficient (needed already for the s.~c. table),
##  `defaultTypeDenseCoeffVectorRep' :
##        the type of s.~c. algebra elements that are represented by
##        a dense list of coefficients.
##
##  If the family has *not* the category `IsFamilyOverFullCoefficientsFamily'
##  then it has the component `coefficientsDomain'.
##


#T need for the norm of a quaternion?
#T (note: returns an element in the coefficients domain, not in the algebra!
#T f( a b[1] + b b[2] + c b[3] + d b[4] ) = a^2 +b^2 +c^2 + d^2.)
#T
#T     NormQuat := function( quat )
#T         if not IsQuaternion( quat ) then
#T           Error( "<quat> must be a quaternion" );
#T         fi;
#T         return Sum( List( ExtRepOfObj( quat ), c -> c^2 ) );
#T     end;

#############################################################################
##
#M  IsWholeFamily( <V> )  . . . . . . . for s.~c. algebra elements collection
##
InstallMethod( IsWholeFamily,
    "for s. c. algebra elements collection",
    [ IsSCAlgebraObjCollection and IsLeftModule and IsFreeLeftModule ],
    function( V )
    local Fam;
    Fam:= ElementsFamily( FamilyObj( V ) );
    if IsFamilyOverFullCoefficientsFamily( Fam ) then
      return     IsWholeFamily( LeftActingDomain( V ) )
             and IsFullSCAlgebra( V );
    else
      return     LeftActingDomain( V ) = Fam!.coefficientsDomain
             and IsFullSCAlgebra( V );
    fi;
    end );


#############################################################################
##
#M  IsFullSCAlgebra( <V> )  . . . . . . for s.~c. algebra elements collection
##
InstallMethod( IsFullSCAlgebra,
    "for s. c. algebra elements collection",
    [ IsSCAlgebraObjCollection and IsAlgebra ],
    V -> Dimension(V) = Length( ElementsFamily( FamilyObj( V ) )!.names ) );


#############################################################################
##
#R  IsDenseCoeffVectorRep( <obj> )
##
##  This representation uses a coefficients vector
##  w.r.t. the basis that is known for the whole family.
##
##  The external representation is the coefficients vector,
##  which is stored at position 1 in the object.
##
if IsHPCGAP then
DeclareRepresentation( "IsDenseCoeffVectorRep",
    IsAtomicPositionalObjectRep, [ 1 ] );
else
DeclareRepresentation( "IsDenseCoeffVectorRep",
    IsPositionalObjectRep, [ 1 ] );
fi;


#############################################################################
##
#M  ObjByExtRep( <Fam>, <descr> ) . . . . . . . .  for s.~c. algebra elements
##
##  Check whether the coefficients list <coeffs> has the right length,
##  and lies in the correct family.
##  If the coefficients family of <Fam> has a uniquely determined zero
##  element, we need to check only whether the family of <descr> is the
##  collections family of the coefficients family of <Fam>.
##
InstallMethod( ObjByExtRep,
    "for s. c. algebra elements family",
    [ IsSCAlgebraObjFamily, IsHomogeneousList ],
    function( Fam, coeffs )
    if    IsFamilyOverFullCoefficientsFamily( Fam )
       or not IsBound( Fam!.coefficientsDomain ) then
      TryNextMethod();
    elif Length( coeffs ) <> Length( Fam!.names ) then
      Error( "<coeffs> must be a list of length ", Length( Fam!.names ) );
    elif not ForAll( coeffs, c -> c in Fam!.coefficientsDomain ) then
      Error( "all in <coeffs> must lie in `<Fam>!.coefficientsDomain'" );
    fi;
    return Objectify( Fam!.defaultTypeDenseCoeffVectorRep,
                      [ Immutable( coeffs ) ] );
    end );

InstallMethod( ObjByExtRep,
    "for s. c. alg. elms. family with coefficients family",
    [ IsSCAlgebraObjFamily and IsFamilyOverFullCoefficientsFamily,
      IsHomogeneousList ],
    function( Fam, coeffs )
    if not IsIdenticalObj( CoefficientsFamily( Fam ),
                        ElementsFamily( FamilyObj( coeffs ) ) ) then
      Error( "family of <coeffs> does not fit to <Fam>" );
    elif Length( coeffs ) <> Length( Fam!.names ) then
      Error( "<coeffs> must be a list of length ", Length( Fam!.names ) );
    fi;
    return Objectify( Fam!.defaultTypeDenseCoeffVectorRep,
                      [ Immutable( coeffs ) ] );
    end );


#############################################################################
##
#M  ExtRepOfObj( <elm> )  . . . . . . . . . . . .  for s.~c. algebra elements
##
InstallMethod( ExtRepOfObj,
    "for s. c. algebra element in dense coeff. vector rep.",
    [ IsSCAlgebraObj and IsDenseCoeffVectorRep ],
    elm -> elm![1] );


#############################################################################
##
#M  Print( <elm> )  . . . . . . . . . . . . . . .  for s.~c. algebra elements
##
InstallMethod( PrintObj,
    "for s. c. algebra element",
    [ IsSCAlgebraObj ],
    function( elm )

    local F,      # family of `elm'
          names,  # generators names
          len,    # dimension of the algebra
          zero,   # zero element of the ring
          depth,  # first nonzero position in coefficients list
          one,    # identity element of the ring
          i;      # loop over the coefficients list

    F     := FamilyObj( elm );
    names := F!.names;
    elm   := ExtRepOfObj( elm );
    len   := Length( elm );

    # Treat the case that the algebra is trivial.
    if len = 0 then
      Print( "<zero of trivial s.c. algebra>" );
      return;
    fi;

    depth := PositionNonZero( elm );

    if len < depth then

      # Print the zero element.
      # (Note that the unique element of a zero algebra has a name.)
      Print( "0*", names[1] );

    else

      one:= One(  elm[1] );
      zero:= Zero( elm[1] );

      if elm[ depth ] <> one then
        Print( "(", elm[ depth ], ")*" );
      fi;
      Print( names[ depth ] );

      for i in [ depth+1 .. len ] do
        if elm[i] <> zero then
          Print( "+" );
          if elm[i] <> one then
            Print( "(", elm[i], ")*" );
          fi;
          Print( names[i] );
        fi;
      od;

    fi;
    end );

#############################################################################
##
#M  String( <elm> )  . . . . . . . . . . . . . . .  for s.~c. algebra elements
##
InstallMethod( String,
    "for s. c. algebra element",
    [ IsSCAlgebraObj ],
    function( elm )

    local F,      # family of `elm'
          s,      # string
          names,  # generators names
          len,    # dimension of the algebra
          zero,   # zero element of the ring
          depth,  # first nonzero position in coefficients list
          one,    # identity element of the ring
          i;      # loop over the coefficients list

    F     := FamilyObj( elm );
    names := F!.names;
    elm   := ExtRepOfObj( elm );
    len   := Length( elm );

    # Treat the case that the algebra is trivial.
    if len = 0 then
      return "<zero of trivial s.c. algebra>";
    fi;

    depth := PositionNonZero( elm );

    s:="";
    if len < depth then

      # Print the zero element.
      # (Note that the unique element of a zero algebra has a name.)
      Append(s, "0*");
      Append(s,names[1]);

    else

      one:= One(  elm[1] );
      zero:= Zero( elm[1] );

      if elm[ depth ] <> one then
        Add(s,'(');
        Append(s,String(elm[ depth ]));
        Append(s, ")*" );
      fi;
      Append(s, names[ depth ] );

      for i in [ depth+1 .. len ] do
        if elm[i] <> zero then
          Add(s, '+' );
          if elm[i] <> one then
            Add(s,'(');
            Append(s,String(elm[ i ]));
            Append(s, ")*" );
          fi;
          Append(s, names[ i ] );
        fi;
      od;

    fi;
    return s;
    end );


#############################################################################
##
#M  One( <Fam> )
##
##  Compute the identity (if exists) from the s.~c. table.
##
InstallMethod( One,
    "for family of s. c. algebra elements",
    [ IsSCAlgebraObjFamily ],
    function( F )
    local one;
    one:= IdentityFromSCTable( F!.sctable );
    if one <> fail then
      one:= ObjByExtRep( F, one );
    fi;
    return one;
    end );


#############################################################################
##
#M  \=( <x>, <y> )  . . . . . . . . . . equality of two s.~c. algebra objects
#M  \<( <x>, <y> )  . . . . . . . . . comparison of two s.~c. algebra objects
#M  \+( <x>, <y> )  . . . . . . . . . . . .  sum of two s.~c. algebra objects
#M  \-( <x>, <y> )  . . . . . . . . . difference of two s.~c. algebra objects
#M  \*( <x>, <y> )  . . . . . . . . . .  product of two s.~c. algebra objects
#M  Zero( <x> ) . . . . . . . . . . . . . .  zero of an s.~c. algebra element
#M  AdditiveInverse( <x> )  . .  additive inverse of an s.~c. algebra element
#M  Inverse( <x> )  . . . . . . . . . . . inverse of an s.~c. algebra element
##
InstallMethod( \=,
    "for s. c. algebra elements",
    IsIdenticalObj,
    [ IsSCAlgebraObj, IsSCAlgebraObj ],
    function( x, y ) return ExtRepOfObj( x ) = ExtRepOfObj( y ); end );

InstallMethod( \=,
    "for s. c. algebra elements in dense vector rep.",
    IsIdenticalObj,
    [ IsSCAlgebraObj and IsDenseCoeffVectorRep,
      IsSCAlgebraObj and IsDenseCoeffVectorRep ],
    function( x, y ) return x![1] = y![1]; end );

InstallMethod( \<,
    "for s. c. algebra elements",
    IsIdenticalObj,
    [ IsSCAlgebraObj, IsSCAlgebraObj ],
    function( x, y ) return ExtRepOfObj( x ) < ExtRepOfObj( y ); end );

InstallMethod( \<,
    "for s. c. algebra elements in dense vector rep.",
    IsIdenticalObj,
    [ IsSCAlgebraObj and IsDenseCoeffVectorRep,
      IsSCAlgebraObj and IsDenseCoeffVectorRep ], 0,
    function( x, y ) return x![1] < y![1]; end );

InstallMethod( \+,
    "for s. c. algebra elements",
    IsIdenticalObj,
    [ IsSCAlgebraObj, IsSCAlgebraObj ],
    function( x, y )
    return ObjByExtRep( FamilyObj(x), ExtRepOfObj(x) + ExtRepOfObj(y) );
    end );

InstallMethod( \+,
    "for s. c. algebra elements in dense vector rep.",
    IsIdenticalObj,
    [ IsSCAlgebraObj and IsDenseCoeffVectorRep,
      IsSCAlgebraObj and IsDenseCoeffVectorRep ],
    function( x, y )
    return ObjByExtRep( FamilyObj( x ), x![1] + y![1] );
    end );

InstallMethod( \-,
    "for s. c. algebra elements",
    IsIdenticalObj,
    [ IsSCAlgebraObj, IsSCAlgebraObj ],
    function( x, y )
    return ObjByExtRep( FamilyObj(x), ExtRepOfObj(x) - ExtRepOfObj(y) );
    end );

InstallMethod( \-,
    "for s. c. algebra elements in dense vector rep.",
    IsIdenticalObj,
    [ IsSCAlgebraObj and IsDenseCoeffVectorRep,
      IsSCAlgebraObj and IsDenseCoeffVectorRep ],
    function( x, y )
    return ObjByExtRep( FamilyObj( x ), x![1] - y![1] );
    end );

InstallMethod( \*,
    "for s. c. algebra elements",
    IsIdenticalObj,
    [ IsSCAlgebraObj, IsSCAlgebraObj ],
    function( x, y )
    local F;
    F:= FamilyObj( x );
    return ObjByExtRep( F, SCTableProduct( F!.sctable,
                        ExtRepOfObj( x ), ExtRepOfObj( y ) ) );
    end );

InstallMethod( \*,
    "for s. c. algebra elements in dense vector rep.",
    IsIdenticalObj,
    [ IsSCAlgebraObj and IsDenseCoeffVectorRep,
      IsSCAlgebraObj and IsDenseCoeffVectorRep ],
    function( x, y )
    local F;
    F:= FamilyObj( x );
    return ObjByExtRep( F, SCTableProduct( F!.sctable, x![1], y![1] ) );
    end );

InstallMethod( \*,
    "for ring element and s. c. algebra element",
    IsCoeffsElms,
    [ IsRingElement, IsSCAlgebraObj ],
    function( x, y )
    return ObjByExtRep( FamilyObj( y ), x * ExtRepOfObj( y ) );
    end );

InstallMethod( \*,
    "for ring element and s. c. algebra element in dense vector rep.",
    IsCoeffsElms,
    [ IsRingElement, IsSCAlgebraObj and IsDenseCoeffVectorRep ],
    function( x, y )
    return ObjByExtRep( FamilyObj( y ), x * y![1] );
    end );

InstallMethod( \*,
    "for s. c. algebra element and ring element",
    IsElmsCoeffs,
    [ IsSCAlgebraObj, IsRingElement ],
    function( x, y )
    return ObjByExtRep( FamilyObj( x ), ExtRepOfObj( x ) * y );
    end );

InstallMethod( \*,
    "for s. c. algebra element in dense vector rep. and ring element",
    IsElmsCoeffs,
    [ IsSCAlgebraObj and IsDenseCoeffVectorRep, IsRingElement ],
    function( x, y )
    return ObjByExtRep( FamilyObj( x ), x![1] * y );
    end );

InstallMethod( \*,
    "for integer and s. c. algebra element",
    [ IsInt, IsSCAlgebraObj ],
    function( x, y )
    return ObjByExtRep( FamilyObj( y ), x * ExtRepOfObj( y ) );
    end );

InstallMethod( \*,
    "for integer and s. c. algebra element in dense vector rep.",
    [ IsInt, IsSCAlgebraObj and IsDenseCoeffVectorRep ],
    function( x, y )
    return ObjByExtRep( FamilyObj( y ), x * y![1] );
    end );

InstallMethod( \*,
    "for s. c. algebra element and integer",
    [ IsSCAlgebraObj, IsInt ],
    function( x, y )
    return ObjByExtRep( FamilyObj( x ), ExtRepOfObj( x ) * y );
    end );

InstallMethod( \*,
    "for s. c. algebra element in dense vector rep. and integer",
    [ IsSCAlgebraObj and IsDenseCoeffVectorRep, IsInt ],
    function( x, y )
    return ObjByExtRep( FamilyObj( x ), x![1] * y );
    end );

InstallMethod( \/,
    "for s. c. algebra element and scalar",
    IsElmsCoeffs,
    [ IsSCAlgebraObj, IsScalar ],
    function( x, y )
    return ObjByExtRep( FamilyObj( x ), ExtRepOfObj( x ) / y );
    end );

InstallMethod( \/,
    "for s. c. algebra element in dense vector rep. and scalar",
    IsElmsCoeffs,
    [ IsSCAlgebraObj and IsDenseCoeffVectorRep, IsScalar ],
    function( x, y )
    return ObjByExtRep( FamilyObj( x ), x![1] / y );
    end );

InstallMethod( ZeroOp,
    "for s. c. algebra element",
    [ IsSCAlgebraObj ],
    x -> ObjByExtRep( FamilyObj( x ), Zero( ExtRepOfObj( x ) ) ) );

InstallMethod( AdditiveInverseOp,
    "for s. c. algebra element",
    [ IsSCAlgebraObj ],
    x -> ObjByExtRep( FamilyObj( x ),
                      AdditiveInverse( ExtRepOfObj( x ) ) ) );

InstallOtherMethod( OneOp,
    "for s. c. algebra element",
    [ IsSCAlgebraObj ],
    function( x )
    local F, one;
    F:= FamilyObj( x );
    one:= IdentityFromSCTable( F!.sctable );
    if one <> fail then
      one:= ObjByExtRep( F, one );
    fi;
    return one;
    end );

InstallOtherMethod( InverseOp,
    "for s. c. algebra element",
    [ IsSCAlgebraObj ],
    function( x )
    local one, F;
    one:= One( x );
    if one <> fail then
      F:= FamilyObj( x );
      one:= QuotientFromSCTable( F!.sctable, ExtRepOfObj( one ),
                                             ExtRepOfObj( x ) );
      if one <> fail then
        one:= ObjByExtRep( F, one );
      fi;
    fi;
    return one;
    end );


#############################################################################
##
#M  \in( <a>, <A> )
##
InstallMethod( \in,
    "for s. c. algebra element, and full s. c. algebra",
    IsElmsColls,
    [ IsSCAlgebraObj, IsFullSCAlgebra ],
    function( a, A )
    return IsSubset( LeftActingDomain( A ), ExtRepOfObj( a ) );
    end );


#############################################################################
##
#F  AlgebraByStructureConstants( <R>, <sctable> )
#F  AlgebraByStructureConstants( <R>, <sctable>, <name> )
#F  AlgebraByStructureConstants( <R>, <sctable>, <names> )
#F  AlgebraByStructureConstants( <R>, <sctable>, <name1>, <name2>, ... )
##
##  is an algebra $A$ over the ring <R>, defined by the structure constants
##  table <sctable> of length $n$.
##
##  The generators of $A$ are linearly independent abstract space generators
##  $x_1, x_2, \ldots, x_n$ which are multiplied according to the formula
##  $ x_i x_j = \sum_{k=1}^n c_{ijk} x_k$
##  where `$c_{ijk}$ = <sctable>[i][j][1][i_k]'
##  and `<sctable>[i][j][2][i_k] = k'.
##
BindGlobal( "AlgebraByStructureConstantsArg",
    function( arglist, filter, one_coeffs... )
    local T,      # structure constants table
          n,      # dimensions of structure matrices
          R,      # coefficients ring
          zero,   # zero of `R'
          names,  # names of the algebra generators
          Fam,    # the family of algebra elements
          A,      # the algebra, result
          gens,   # algebra generators of `A'
          one;    # multiplicative identity, if available

    # Check the argument list.
    if not 1 < Length( arglist ) and IsRing( arglist[1] )
                                 and IsList( arglist[2] ) then
      Error( "usage: AlgebraByStructureConstantsArg([<R>,<sctable>]) or \n",
             "AlgebraByStructureConstantsArg([<R>,<sctable>,<name1>,...])" );
    fi;

    # Check the s.~c. table.
#T really do this?
    R    := arglist[1];
    zero := Zero( R );
    T    := arglist[2];

    if zero = T[ Length( T ) ] then
      T:= Immutable( T );
    else
      if T[ Length( T ) ] = 0 then
        T:= ReducedSCTable( T, One( zero ) );
      else
        Error( "<R> and <T> are not compatible" );
      fi;
    fi;

    if Length( T ) = 2 then
      n:= 0;
    else
      n:= Length( T[1] );
    fi;

    # Construct names of generators (used for printing only).
    if   Length( arglist ) = 2 then
      names:= List( [ 1 .. n ],
                    x -> Concatenation( "v.", String(x) ) );
      MakeImmutable( names );
    elif Length( arglist ) = 3 and IsString( arglist[3] ) then
      names:= List( [ 1 .. n ],
                    x -> Concatenation( arglist[3], String(x) ) );
      MakeImmutable( names );
    elif Length( arglist ) = 3 and IsHomogeneousList( arglist[3] )
                               and Length( arglist[3] ) = n
                               and ForAll( arglist[3], IsString ) then
      names:= Immutable( arglist[3] );
    elif Length( arglist ) = 2 + n then
      names:= Immutable( arglist{ [ 3 .. Length( arglist ) ] } );
    else
      Error( "usage: AlgebraByStructureConstantsArg([<R>,<sctable>]) or \n",
             "AlgebraByStructureConstantsArg([<R>,<sctable>,<name1>,...])" );
    fi;

    # If the coefficients know to be additively commutative then
    # also the s.c. algebra will know this.
    if IsAdditivelyCommutativeElementFamily( FamilyObj( zero ) ) then
      filter:= filter and IsAdditivelyCommutativeElement;
    fi;

    # Construct the family of elements of our algebra.
    # If the elements family of `R' has a uniquely determined zero element,
    # then all coefficients in this family are admissible.
    # Otherwise only coefficients from `R' itself are allowed.
    Fam:= NewFamily( "SCAlgebraObjFamily", filter );
    if Zero( ElementsFamily( FamilyObj( R ) ) ) <> fail then
      SetFilterObj( Fam, IsFamilyOverFullCoefficientsFamily );
    else
      Fam!.coefficientsDomain:= R;
    fi;

    Fam!.sctable   := T;
    Fam!.names     := names;
    Fam!.zerocoeff := zero;

    # Construct the default type of the family.
    Fam!.defaultTypeDenseCoeffVectorRep :=
        NewType( Fam, IsSCAlgebraObj and IsDenseCoeffVectorRep );

    SetCharacteristic( Fam, Characteristic( R ) );
    SetCoefficientsFamily( Fam, ElementsFamily( FamilyObj( R ) ) );

    # Make the generators and the algebra.
    if 0 < n then
      SetZero( Fam, ObjByExtRep( Fam, List( [ 1 .. n ], x -> zero ) ) );
      gens:= Immutable( List( IdentityMat( n, R ),
                              x -> ObjByExtRep( Fam, x ) ) );
      A:= FLMLORByGenerators( R, gens );
      UseBasis( A, gens );
    else
      SetZero( Fam, ObjByExtRep( Fam, EmptyRowVector( FamilyObj(zero) ) ) );
      gens:= Immutable( [] );
      A:= FLMLORByGenerators( R, gens, Zero( Fam ) );
      SetIsTrivial( A, true );
      SetDimension( A, 0 );
    fi;
    if Length( one_coeffs ) = 1 then
      # We want to construct an algebra-with_one.
      one:= ObjByExtRep( Fam, one_coeffs[1] );
      SetOne( Fam, one );
      SetOne( A, one );
      SetFilterObj( A, IsMagmaWithOne );
      SetGeneratorsOfAlgebraWithOne( A, gens );
    fi;
    Fam!.basisVectors:= gens;
#T where is this needed?

    # Store the algebra in the family of the elements,
    # for accessing the full algebra, e.g., in `DefaultFieldOfMatrixGroup'.
    Fam!.fullSCAlgebra:= A;

    SetIsFullSCAlgebra( A, true );

    # Return the algebra.
    return A;
end );

InstallGlobalFunction( AlgebraByStructureConstants, function( arg )
    return AlgebraByStructureConstantsArg( arg, IsSCAlgebraObj );
end );

InstallGlobalFunction( AlgebraWithOneByStructureConstants, function( arg )
    return AlgebraByStructureConstantsArg( arg{ [ 1 .. Length( arg )-1 ] },
               IsSCAlgebraObj, arg[ Length( arg ) ] );
end );

InstallGlobalFunction( LieAlgebraByStructureConstants, function( arg )
    local A;
    A:= AlgebraByStructureConstantsArg( arg, IsSCAlgebraObj and IsJacobianElement );
    SetIsLieAlgebra( A, true );
    return A;
end );

InstallGlobalFunction( RestrictedLieAlgebraByStructureConstants, function( arg )
    local A, fam, pmap, i, j, v;
    A := AlgebraByStructureConstantsArg( arg{[1..Length(arg)-1]}, IsSCAlgebraObj and IsRestrictedJacobianElement );
    SetIsLieAlgebra( A, true );
    SetIsRestrictedLieAlgebra( A, true );
    fam := FamilyObj(Representative(A));
    fam!.pMapping := [];
    pmap := arg[Length(arg)];
    while Length(pmap)<>Dimension(A) do
        Error("Pth power images list should have length ",Dimension(A));
    od;
    for i in [1..Length(pmap)] do
        v := List(pmap,i->fam!.zerocoeff);
        for j in [2,4..Length(pmap[i])] do
            v[pmap[i][j]] := One(v[1])*pmap[i][j-1];
        od;
        v := ObjByExtRep(fam,v);
#        while AdjointMatrix(Basis(A),A.(i))^Characteristic(A)<>AdjointMatrix(Basis(A),v) do
#            Error("p-mapping at position ",i," doesn't satisfy the axioms of a restricted Lie algebra");
#        od;
        Add(fam!.pMapping,v);
    od;
    SetPthPowerImages(Basis(A),fam!.pMapping);
    return A;
end );

#############################################################################
##
#M  \.( <A>, <n> )  . . . . . . . access to generators of a full s.c. algebra
##
InstallAccessToGenerators( IsSCAlgebraObjCollection and IsFullSCAlgebra,
    "s.c. algebra containing the whole family",
    GeneratorsOfAlgebra );


#############################################################################
##
#F  QuaternionAlgebra( <F>[, <a>, <b>] )
##
InstallGlobalFunction( QuaternionAlgebra, function( arg )
    local F, a, b, e, z, stored, filter, A;

    if   Length( arg ) = 1 and IsRing( arg[1] ) then
      F:= arg[1];
      a:= AdditiveInverse( One( F ) );
      b:= a;
    elif Length( arg ) = 1 and IsCollection( arg[1] ) then
      F:= Field( arg[1] );
      a:= AdditiveInverse( One( F ) );
      b:= a;
    elif Length( arg ) = 3 and IsRing( arg[1] ) then
      F:= arg[1];
      a:= arg[2];
      b:= arg[3];
    elif Length( arg ) = 3 and IsCollection( arg[1] ) then
      F:= Field( arg[1] );
      a:= arg[2];
      b:= arg[3];
    else
      Error( "usage: QuaternionAlgebra( <F>[, <a>, <b>] ) for a ring <F>" );
    fi;
    e:= One( F );
    if e = fail then
      Error( "<F> must have an identity element" );
    fi;
    z:= Zero( F );

    # Generators in the right family may be already available.
    stored := GET_FROM_SORTED_CACHE( QuaternionAlgebraData, [ a, b, FamilyObj( F ) ],
    function()
      # Construct a filter describing element properties,
      # which will be stored in the family.
      filter:= IsSCAlgebraObj and IsQuaternion;
      if HasIsAssociative( F ) and IsAssociative( F ) then
        filter:= filter and IsAssociativeElement;
      fi;
      if     IsNegRat( a ) and IsNegRat( b )
#T it suffices if the parameters are real and negative
         and IsCyclotomicCollection( F ) and IsField( F )
         and ForAll( GeneratorsOfDivisionRing( F ),
                     x -> x = ComplexConjugate( x ) ) then
        filter:= filter and IsZDFRE;
      fi;

      # Construct the algebra.
      return AlgebraByStructureConstantsArg(
              [ F,
                [ [ [[1],[e]], [[2],[ e]], [[3],[ e]], [[4],[   e]] ],
                  [ [[2],[e]], [[1],[ a]], [[4],[ e]], [[3],[   a]] ],
                  [ [[3],[e]], [[4],[-e]], [[1],[ b]], [[2],[  -b]] ],
                  [ [[4],[e]], [[3],[-a]], [[2],[ b]], [[1],[-a*b]] ],
                  0, z ],
                "e", "i", "j", "k" ],
              filter, [ e, z, z, z ] );
    end );

    A:= AlgebraWithOne( F, GeneratorsOfAlgebra( stored ), "basis" );
    SetGeneratorsOfAlgebra( A, GeneratorsOfAlgebraWithOne( A ) );
    SetIsFullSCAlgebra( A, true );

    # A quaternion algebra with negative parameters over a real field
    # is a division ring.
    if     IsNegRat( a ) and IsNegRat( b )
       and IsCyclotomicCollection( F ) and IsField( F )
       and ForAll( GeneratorsOfDivisionRing( F ),
                   x -> x = ComplexConjugate( x ) ) then
      SetFilterObj( A, IsDivisionRing );
#T better use `DivisionRingByGenerators'?
      SetGeneratorsOfDivisionRing( A, GeneratorsOfAlgebraWithOne( A ) );
    fi;

    # Return the quaternion algebra.
    return A;
end );


#############################################################################
##
#M  OneOp( <quat> ) . . . . . . . . . . . . . . . . . . . .  for a quaternion
##
InstallMethod( OneOp,
    "for a quaternion",
    [ IsQuaternion and IsSCAlgebraObj ],
    quat -> ObjByExtRep( FamilyObj( quat ),
                         [ 1, 0, 0, 0 ] * One( ExtRepOfObj( quat )[1] ) ) );


#############################################################################
##
#M  InverseOp( <quat> ) . . . . . . . . . . . . . . . . . .  for a quaternion
##
##  Let $a$ and $b$ be the parameters from which the algebra of <quat> was
##  constructed.
##  The inverse of $c_1 e + c_2 i + c_3 j + c_4 k$ is
##  $c_1/z e - c_2/z i - c_3/z j - c_4/z k$
##  where $z = c_1^2 - c_2^2 a - c_3^2 b + c_4^2 a b$.
##
InstallMethod( InverseOp,
    "for a quaternion",
    [ IsQuaternion and IsSCAlgebraObj ],
    function( quat )
    local data, z, a, b;
    data:= ExtRepOfObj( quat );
    a:= FamilyObj( quat )!.sctable[2][2][2][1];
    b:= FamilyObj( quat )!.sctable[3][3][2][1];
    z:= data[1]^2 - data[2]^2 * a - data[3]^2 * b + data[4]^2 * a * b;
    if IsZero( z ) then
      return fail;
    fi;
    return ObjByExtRep( FamilyObj( quat ),
               [ data[1]/z, AdditiveInverse( data[2]/z ),
                            AdditiveInverse( data[3]/z ),
                            AdditiveInverse( data[4]/z ) ] );
    end );


#############################################################################
##
#M  ComplexConjugate( <quat> )  . . . . . . . . . . . . . .  for a quaternion
##
InstallMethod( ComplexConjugate,
    "for a quaternion",
    [ IsQuaternion and IsSCAlgebraObj ],
    function( quat )
    local v;

    v:= ExtRepOfObj( quat );
    return ObjByExtRep( FamilyObj( quat ), [ v[1], -v[2], -v[3], -v[4] ] );
    end );


#############################################################################
##
#M  RealPart( <quat> )  . . . . . . . . . . . . . . . . . .  for a quaternion
##
InstallMethod( RealPart,
    "for a quaternion",
    [ IsQuaternion and IsSCAlgebraObj ],
    function( quat )
    local v, z;

    v:= ExtRepOfObj( quat );
    z:= Zero( v[1] );
    return ObjByExtRep( FamilyObj( quat ), [ v[1], z, z, z ] );
    end );


#############################################################################
##
#M  ImaginaryPart( <quat> ) . . . . . . . . . . . . . . . .  for a quaternion
##
InstallMethod( ImaginaryPart,
    "for a quaternion",
    [ IsQuaternion and IsSCAlgebraObj ],
    function( quat )
    local v, z, a;

    v:= ExtRepOfObj( quat );
    z:= Zero( v[1] );
    a:= FamilyObj( quat )!.sctable[2][2][2][1];  # the first parameter
    return ObjByExtRep( FamilyObj( quat ), [ v[2], z, -v[4], -v[3]/a ] );
    end );


#############################################################################
##
#F  ComplexificationQuat( <vector> )
#F  ComplexificationQuat( <matrix> )
##
InstallGlobalFunction( ComplexificationQuat, function( matrixorvector )
    local result,
          i, e,
          M,
          m,
          n,
          j, k,
          v,
          coeff;

    result:= [];
    i:= E(4);
    e:= 1;

    if   IsQuaternionCollColl( matrixorvector ) then

      M:= matrixorvector;
      m:= Length( M );
      n:= Length( M[1] );
      for j in [ 1 .. 2*m ] do
        result[j]:= [];
      od;
      for j in [ 1 .. m ] do
        for k in [ 1 .. n ] do
          coeff:= ExtRepOfObj( M[j][k] );
          result[  j  ][  k  ]:=   e * coeff[1] + i * coeff[2];
          result[  j  ][ n+k ]:=   e * coeff[3] + i * coeff[4];
          result[ m+j ][  k  ]:= - e * coeff[3] + i * coeff[4];
          result[ m+j ][ n+k ]:=   e * coeff[1] - i * coeff[2];
        od;
      od;

    elif IsQuaternionCollection( matrixorvector ) then

      v:= matrixorvector;
      n:= Length( v );
      for j in [ 1 .. n ] do
        coeff:= ExtRepOfObj( v[j] );
        result[  j  ]:= e * coeff[1] + i * coeff[2];
        result[ n+j ]:= e * coeff[3] + i * coeff[4];
      od;

    else
      Error( "<matrixorvector> must be a vector or matrix of quaternions" );
    fi;

    return result;
end );


#############################################################################
##
#F  OctaveAlgebra( <F> )
##
InstallGlobalFunction( OctaveAlgebra, F -> AlgebraByStructureConstants(
    F,
    [ [ [[1],[1]],[[],[]],[[3],[1]],[[],[]],[[5],[1]],[[],[]],[[],[]],
        [[8],[1]] ],
      [ [[],[]],[[2],[1]],[[],[]],[[4],[1]],[[],[]],[[6],[1]],[[7],[1]],
        [[],[]] ],
      [ [[],[]],[[3],[1]],[[],[]],[[1],[1]],[[7],[1]],[[],[]],[[],[]],
        [[6],[1]] ],
      [ [[4],[1]],[[],[]],[[2],[1]],[[],[]],[[],[]],[[8],[1]],[[5],[1]],
        [[],[]] ],
      [ [[],[]],[[5],[1]],[[7],[-1]],[[],[]],[[],[]],[[1],[1]],[[],[]],
        [[4],[-1]] ],
      [ [[6],[1]],[[],[]],[[],[]],[[8],[-1]],[[2],[1]],[[],[]],[[3],[-1]],
        [[],[]] ],
      [ [[7],[1]],[[],[]],[[],[]],[[5],[-1]],[[],[]],[[3],[1]],[[],[]],
        [[2],[-1]] ],
      [ [[],[]],[[8],[1]],[[6],[-1]],[[],[]],[[4],[1]],[[],[]],[[1],[-1]],
        [[],[]] ],
      0, 0 ],
    "s1", "t1", "s2", "t2", "s3", "t3", "s4", "t4" ) );


#############################################################################
##
#M  NiceFreeLeftModuleInfo( <V> )
#M  NiceVector( <V>, <v> )
#M  UglyVector( <V>, <r> )
##
InstallHandlingByNiceBasis( "IsSCAlgebraObjSpace", rec(
    detect := function( R, gens, V, zero )
      return IsSCAlgebraObjCollection( V );
      end,

    NiceFreeLeftModuleInfo := ReturnTrue,

    NiceVector := function( V, v )
      return ExtRepOfObj( v );
      end,

    UglyVector := function( V, r )
      local F;
      F:= ElementsFamily( FamilyObj( V ) );
      if Length( r ) <> Length( F!.names ) then
        return fail;
      fi;
      return ObjByExtRep( F, r );
      end ) );


#############################################################################
##
#M  MutableBasis( <R>, <gens> )
#M  MutableBasis( <R>, <gens>, <zero> )
##
##  We choose a mutable basis that stores a mutable basis for a nice module.
##
InstallMethod( MutableBasis,
    "for ring and collection of s. c. algebra elements",
    [ IsRing, IsSCAlgebraObjCollection ],
    MutableBasisViaNiceMutableBasisMethod2 );

InstallOtherMethod( MutableBasis,
    "for ring, (possibly empty) list, and zero element",
    [ IsRing, IsList, IsSCAlgebraObj ],
    MutableBasisViaNiceMutableBasisMethod3 );


#############################################################################
##
#M  Coefficients( <B>, <v> )  . . . . . . coefficients w.r.t. canonical basis
##
InstallMethod( Coefficients,
    "for canonical basis of full s. c. algebra",
    IsCollsElms,
    [ IsBasis and IsCanonicalBasisFullSCAlgebra, IsSCAlgebraObj ],
    function( B, v )
    return ExtRepOfObj( v );
    end );


#############################################################################
##
#M  LinearCombination( <B>, <coeffs> )  . . . . . . . . . for canonical basis
##
InstallMethod( LinearCombination,
    "for canonical basis of full s. c. algebra",
    [ IsBasis and IsCanonicalBasisFullSCAlgebra, IsRowVector ],
    function( B, coeffs )
    return ObjByExtRep( ElementsFamily( FamilyObj( B ) ), coeffs );
    end );


#############################################################################
##
#M  BasisVectors( <B> ) . . . . . . for canonical basis of full s.~c. algebra
##
InstallMethod( BasisVectors,
    "for canonical basis of full s. c. algebra",
    [ IsBasis and IsCanonicalBasisFullSCAlgebra ],
    B -> ElementsFamily( FamilyObj(
             UnderlyingLeftModule( B ) ) )!.basisVectors );


#############################################################################
##
#M  Basis( <A> )  . . . . . . . . . . . . . . . basis of a full s.~c. algebra
##
InstallMethod( Basis,
    "for full s. c. algebra (delegate to `CanonicalBasis')",
    [ IsFreeLeftModule and IsSCAlgebraObjCollection and IsFullSCAlgebra ],
    CANONICAL_BASIS_FLAGS,
    CanonicalBasis );


#############################################################################
##
#M  CanonicalBasis( <A> ) . . . . . . . . . . . basis of a full s.~c. algebra
##
InstallMethod( CanonicalBasis,
    "for full s. c. algebras",
    [ IsFreeLeftModule and IsSCAlgebraObjCollection and IsFullSCAlgebra ],
    function( A )
    local B;
    B:= Objectify( NewType( FamilyObj( A ),
                                IsCanonicalBasisFullSCAlgebra
                            and IsAttributeStoringRep
                            and IsFiniteBasisDefault
                            and IsCanonicalBasis ),
                   rec() );
    SetUnderlyingLeftModule( B, A );
    SetStructureConstantsTable( B,
        ElementsFamily( FamilyObj( A ) )!.sctable );
    return B;
    end );


#############################################################################
##
#M  IsCanonicalBasisFullSCAlgebra( <B> )
##
InstallMethod( IsCanonicalBasisFullSCAlgebra,
    "for a basis",
    [ IsBasis ],
    function( B )
    local A;
    A:= UnderlyingLeftModule( B );
    return     IsSCAlgebraObjCollection( A )
           and IsFullSCAlgebra( A )
           and IsCanonicalBasis( B );
    end );

#T change implementation: bases of their own right, as for Gaussian row spaces,
#T if the algebra is Gaussian


#############################################################################
##
#M  Intersection2( <V>, <W> )
##
##  Contrary to the generic case that is handled by `Intersection2Spaces',
##  we know initially a (finite dimensional) common coefficient space,
##  so we can avoid the intermediate construction of such a space.
##
InstallMethod( Intersection2,
    "for two spaces in a common s.c. algebra",
    IsIdenticalObj,
    [ IsVectorSpace and IsSCAlgebraObjCollection,
      IsVectorSpace and IsSCAlgebraObjCollection ],
    function( V, W )
    local F,       # coefficients field
          gensV,   # list of generators of 'V'
          gensW,   # list of generators of 'W'
          Fam,     # family of an element
          inters;  # intersection, result

    F:= LeftActingDomain( V );
    if F <> LeftActingDomain( W ) then
      # The generic method is good enough for this.
      TryNextMethod();
    fi;

    gensV:= GeneratorsOfLeftModule( V );
    gensW:= GeneratorsOfLeftModule( W );
    if IsEmpty( gensV ) or IsEmpty( gensW ) then
      inters:= [];
    else
      gensV:= List( gensV, ExtRepOfObj );
      gensW:= List( gensW, ExtRepOfObj );
      if not (     ForAll( gensV, v -> IsSubset( F, v ) )
               and ForAll( gensW, v -> IsSubset( F, v ) ) ) then
        # We are not in a Gaussian situation.
        TryNextMethod();
      fi;
      Fam:= ElementsFamily( FamilyObj( V ) );
      inters:= List( SumIntersectionMat( gensV, gensW )[2],
                     x -> ObjByExtRep( Fam, x ) );
    fi;

    # Construct the intersection space, if possible with a parent,
    # and with as much structure as possible.
    if IsEmpty( inters ) then
      inters:= TrivialSubFLMLOR( V );
    elif IsFLMLOR( V ) and IsFLMLOR( W ) then
      inters:= FLMLOR( F, inters, "basis" );
    else
      inters:= VectorSpace( F, inters, "basis" );
    fi;
    if     HasParent( V ) and HasParent( W )
       and IsIdenticalObj( Parent( V ), Parent( W ) ) then
      SetParent( inters, Parent( V ) );
    fi;

    # Run implications by the subset relation.
    UseSubsetRelation( V, inters );
    UseSubsetRelation( W, inters );

    # Return the result.
    return inters;
    end );

# analogous for closure?
