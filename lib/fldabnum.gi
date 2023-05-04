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
##  This file contains methods for fields consisting of cyclotomics.
##
##  Note that we must distinguish abelian number fields and fields
##  that consist of cyclotomics.
##  (The image of the natural embedding of the rational number field
##  into a field of rational functions is of course an abelian number field
##  but its elements are not cyclotomics since this would be a property given
##  by their family.)
##


#############################################################################
##
#M  IsFiniteDimensional( <A> )
##
##  A finitely generated algebra-with-one that consists of cyclotomics
##  has a finite conductor and hence is finite dimensional.
##  (Cyclotomic fields and their subfields get the 'IsFiniteDimensional'
##  filter from 'AbelianNumberFieldByReducedGaloisStabilizerInfo',
##  there is apparently no method for computing the value.)
##
InstallMethod( IsFiniteDimensional,
    "for an algebra-with-one of cyclotomics",
    [ IsAlgebraWithOne and IsCyclotomicCollection
      and HasGeneratorsOfAlgebraWithOne ],
    function( A )
    if IsFinite( GeneratorsOfAlgebraWithOne( A ) ) then
      return true;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#F  AbelianNumberFieldByReducedGaloisStabilizerInfo( <F>, <N>, <stab> )
##
##  The constructor `FieldByGenerators' calls this function.
##  Since `CyclotomicField' and `AbelianNumberField' generate first the
##  information about conductor and Galois stabilizer, it is useful for them
##  to call this function instead of constructing generators and calling
##  `FieldByGenerators', which would mean to construct <N> and <stab> again.
##
InstallGlobalFunction( AbelianNumberFieldByReducedGaloisStabilizerInfo,
    function( F, N, stab )

    local D, d;

    D:= Objectify( NewType( CollectionsFamily( CyclotomicsFamily ),
                                IsField
                            and IsFiniteDimensional
                            and IsAbelianNumberField
                            and IsAttributeStoringRep ),
                   rec() );

    d:= Phi(N) / Length( stab );

    SetIsCyclotomicField( D, Length( stab ) = 1 );
    SetLeftActingDomain( D, F );
    SetDegreeOverPrimeField( D, d );
    SetGaloisStabilizer( D, stab );
    SetConductor( D, N );
    SetIsFinite( D, false );
    SetSize( D, infinity );
    SetDimension( D, d / DegreeOverPrimeField( F ) );
    SetPrimeField( D, Rationals );
    SetIsWholeFamily( D, false );

    return D;
end );


#############################################################################
##
#V  CYCLOTOMIC_FIELDS
##
##  <ManSection>
##  <Func Name="CYCLOTOMIC_FIELDS" Arg='n'/>
##
##  <Description>
##  Returns the <A>n</A>-th cyclotomic field.
##  </Description>
##  </ManSection>
##
BindGlobal( "CYCLOTOMIC_FIELDS",
    MemoizePosIntFunction(
        function(xtension)
            return AbelianNumberFieldByReducedGaloisStabilizerInfo( Rationals,
                   xtension, [ 1 ] );
        end,
    rec( defaults := [ Rationals, Rationals,, GaussianRationals ] ) )
);


#############################################################################
##
#F  CyclotomicField( <n> )  . . . . . . .  create the <n>-th cyclotomic field
#F  CyclotomicField( <gens> )
#F  CyclotomicField( <subfield>, <n> )
#F  CyclotomicField( <subfield>, <gens> )
##
InstallGlobalFunction( CyclotomicField, function ( arg )

    local F, subfield, xtension;

    # If necessary split the arguments.
    if     Length( arg ) = 1
       and ( ( IsInt( arg[1] ) and 0 < arg[1] ) or IsList( arg[1] ) ) then

      # CF( <n> ) or CF( <gens> )
      subfield:= Rationals;
      xtension:= arg[1];

    elif     Length( arg ) = 2
         and IsField( arg[1] )
         and ( ( IsInt( arg[2] ) and 0 < arg[2] ) or IsList( arg[2] ) ) then

      # `CF( <subfield>, <n> )' or `CF( <subfield>, <gens> )'
      subfield:= arg[1];
      xtension:= arg[2];

    else
      Error("usage: CF( <n> ) or CF( <subfield>, <gens> )");
    fi;

    # Replace generators by their conductor.
    if not IsInt( xtension ) then
      xtension:= Conductor( xtension );
    fi;
    if xtension mod 2 = 0 and xtension mod 4 <> 0 then
      xtension:= xtension / 2;
    fi;

    # The subfield is given by `Rationals' denoting the prime field.
    if subfield = Rationals then

      # The standard field is required.  Look whether it is already stored.
      # If not, generate it and return it
      return CYCLOTOMIC_FIELDS( xtension );

    elif IsAbelianNumberField( subfield ) then

      # CF( subfield, N )
      if xtension mod Conductor( subfield ) <> 0 then
        Error( "<subfield> is not contained in CF( <xtension> )" );
      fi;

    else
      Error( "<subfield> must be `Rationals' or an abelian number field" );
    fi;

    F:= AbelianNumberFieldByReducedGaloisStabilizerInfo( subfield,
            xtension, [ 1 ] );

    # Return the field.
    return F;
end );


#############################################################################
##
#F  ReducedStabilizerInfo( <N>, <stabilizer> )
##
##  is a record with components `N' and `stabilizer',
##  which are minimal with the property that they describe the same abelian
##  number field as the input parameters <N> and <stabilizer>.
##
BindGlobal( "ReducedGaloisStabilizerInfo", function( N, stabilizer )

    local d,
          gens,
          NN,
          aut,
          pos,
          i,
          p;

    if N mod 2 = 0 and N mod 4 <> 0 then
      N:= N / 2;
    fi;
    if N <= 2 then
      return rec( N:= 1, stabilizer:= [ 1 ] );
    fi;

    stabilizer:= Set( stabilizer );
    AddSet( stabilizer, 1 );

    # Compute the elements of the group generated by `stabilizer'.
    for d in stabilizer do
      UniteSet( stabilizer, List( stabilizer, x -> ( x * d ) mod N ) );
    od;

    # reduce the pair `( N, stabilizer )' such that afterwards `N'
    # describes the conductor of the required field;

    gens:= GeneratorsPrimeResidues( N );
    NN:= 1;
    if gens.primes[1] = 2 then

      if gens.exponents[1] < 3 then
        if not gens.generators[1] in stabilizer then
          NN:= NN * 4;
        fi;

      else

        # the only case where `gens.generators[i]' is a list;
        # it contains the generators corresponding to `**' and `*5';
        # the first one is irrelevant for the conductor,
        # except if also the other generator is contained.
        if gens.generators[1][2] in stabilizer then
          if not gens.generators[1][1] in stabilizer then
            NN:= NN * 4;
          fi;
        else
          NN:= NN * 4;
          aut:= gens.generators[1][2];
          while not aut in stabilizer do
            aut:= ( aut ^ 2 ) mod N;
            NN:= NN * 2;
          od;
        fi;
      fi;
      pos:= 2;
    else
      pos:= 1;
    fi;

    for i in [ pos .. Length( gens.primes ) ] do
      p:= gens.primes[i];
      if not gens.generators[i] in stabilizer then
        NN:= NN * p;
        aut:= ( gens.generators[i] ^ ( p - 1 ) ) mod N;
        while not aut in stabilizer do
          aut:= ( aut ^ p ) mod N;
          NN:= NN * p;
        od;
      fi;
    od;

    N:= NN;
    if N <= 2 then
      stabilizer:= [ 1 ];
      N:= 1;
    else
      stabilizer:= Set( stabilizer, x -> x mod N );
    fi;

    return rec( N:= N, stabilizer:= stabilizer );
end );


#############################################################################
##
#F  AbelianNumberField( <N>, <stab> ) . . . .  create an abelian number field
##
##  fixed field of the group generated by <stab> (prime residues modulo <N>)
##  in the cyclotomic field with conductor <N>.
##
InstallGlobalFunction( AbelianNumberField, function ( N, stabilizer )

    local pos,     # position in a list
          F;       # the field, result

    # Check the arguments.
    if not ( IsInt( N ) and 0 < N and IsList( stabilizer ) ) then
      Error( "<N> must be a positive integer, <stabilizer> a list" );
    fi;

    # Compute the conductor and the reduced stabilizer.
    # Thus the Galois stabilizer component of the field will be minimal.
    stabilizer := ReducedGaloisStabilizerInfo( N, stabilizer );
    N          := stabilizer.N;
    stabilizer := stabilizer.stabilizer;

    if stabilizer = [ 1 ] then
      return CyclotomicField( N );
    fi;

    # The standard field is required.  Look whether it is already stored.
    return GET_FROM_SORTED_CACHE( ABELIAN_NUMBER_FIELDS, [N, stabilizer], function()

    # Construct the field.
    F:= AbelianNumberFieldByReducedGaloisStabilizerInfo( Rationals,
            N, stabilizer );

    # Return the number field.
    return F;

    end );
end );


#############################################################################
##
#M  ViewObj( <F> )  . . . . . . . . . . . . . .  view an abelian number field
##
InstallMethod( ViewObj,
    "for abelian number field of cyclotomics",
    [ IsAbelianNumberField and IsCyclotomicCollection ],
    function( F )
    if IsPrimeField( LeftActingDomain( F ) ) then
      Print( "NF(", Conductor( F ), ",",
              GaloisStabilizer( F ), ")" );
    else
      Print( "AsField( ", LeftActingDomain( F ),
             ", NF(", Conductor( F ), ",", GaloisStabilizer( F ), ") )" );
    fi;
    end );

InstallMethod( ViewObj,
    "for cyclotomic field of cyclotomics",
    [ IsCyclotomicField and IsCyclotomicCollection ],
    function( F )
    if IsPrimeField( LeftActingDomain( F ) ) then
      Print( "CF(", Conductor( F ), ")" );
    else
      Print( "AsField( ", LeftActingDomain( F ),
             ", CF(", Conductor( F ), ") )" );
    fi;
    end );


#############################################################################
##
#M  PrintObj( <F> ) . . . . . . . . . . . . . . print an abelian number field
##
InstallMethod( PrintObj,
    "for abelian number field of cyclotomics",
    [ IsAbelianNumberField and IsCyclotomicCollection ],
    function( F )
    if IsPrimeField( LeftActingDomain( F ) ) then
      Print( "NF(", Conductor( F ), ",",
              GaloisStabilizer( F ), ")" );
    else
      Print( "AsField( ", LeftActingDomain( F ),
             ", NF(", Conductor( F ), ",", GaloisStabilizer( F ), ") )" );
    fi;
    end );

InstallMethod( PrintObj,
    "for cyclotomic field of cyclotomics",
    [ IsCyclotomicField and IsCyclotomicCollection ],
    function( F )
    if IsPrimeField( LeftActingDomain( F ) ) then
      Print( "CF(", Conductor( F ), ")" );
    else
      Print( "AsField( ", LeftActingDomain( F ),
             ", CF(", Conductor( F ), ") )" );
    fi;
    end );


#############################################################################
##
#M  String( <F> ) . . . . . . . . . . . . . string of an abelian number field
##
InstallMethod( String,
    "for abelian number field of cyclotomics",
    [ IsAbelianNumberField and IsCyclotomicCollection ],
    function( F )
    if IsPrimeField( LeftActingDomain( F ) ) then
      return Concatenation( "NF(", String( Conductor( F ) ), ",",
                            String( GaloisStabilizer( F ) ), ")" );
    else
      return Concatenation( "AsField( ", String( LeftActingDomain( F ) ),
                            ", NF(", String( Conductor( F ) ), ",",
                            String( GaloisStabilizer( F ) ), ") )" );
    fi;
    end );

InstallMethod( String,
    "for cyclotomic field of cyclotomics",
    [ IsCyclotomicField and IsCyclotomicCollection ],
    function( F )

    local n;

    n:= Conductor( F );

    if IsPrimeField( LeftActingDomain( F ) ) then
      if   n = 1 then
        return "Rationals";
      elif n = 4 then
        return "GaussianRationals";
      else
        return Concatenation( "CF(", String( n ), ")" );
      fi;
    elif n = 4 then
      return Concatenation( "AsField( ", String( LeftActingDomain( F ) ),
                            ", GaussianRationals )" );
    else
      return Concatenation( "AsField( ", String( LeftActingDomain( F ) ),
                            ", CF(", String( n ), ") )" );
    fi;
    end );


#############################################################################
##
#M  \=( <F1>, <F2> )  . . . . . . . . . . comparison of abelian number fields
#M  \<( <F1>, <F2> )  . . . . . . . . . . comparison of abelian number fields
##
##  <F1> is smaller than <F2> if and only if <F1> has a smaller conductor,
##  or it has the same conductor as <F2> but its Galois stabilizer component
##  is smaller.
##
InstallMethod( \=,
    "for two abelian number fields",
    IsIdenticalObj,
    [ IsAbelianNumberField, IsAbelianNumberField ],
    function ( F1, F2 )
    return     Conductor( F1 ) = Conductor( F2 )
           and GaloisStabilizer( F1 ) = GaloisStabilizer( F2 );
    end );

InstallMethod( \<,
    "for two abelian number fields",
    IsIdenticalObj,
    [ IsAbelianNumberField, IsAbelianNumberField ],
    function ( F1, F2 )
    return    Conductor( F1 ) < Conductor( F2 )
           or (     Conductor( F1 ) = Conductor( F2 )
                and GaloisStabilizer( F1 ) < GaloisStabilizer( F2 ) );
    end );


#############################################################################
##
#M  \in( <z>, <F> ) . . . .  test if <z> lies in the abelian number field <F>
##
##  check whether <z> is a cyclotomic with conductor contained in the
##  conductor of <F>, and that <z> is fixed by `GaloisStabilizer( <F> )'.
##
InstallMethod( \in,
    "for cyclotomic and abelian number field",
    IsElmsColls,
    [ IsCyc, IsAbelianNumberField and IsCyclotomicCollection ],
    function ( z, F )
    return     Conductor( F ) mod Conductor( z ) = 0
           and ForAll( GaloisStabilizer( F ), x -> GaloisCyc( z, x ) = z );
    end );

InstallMethod( \in,
    "for cyclotomic and cyclotomic field",
    IsElmsColls,
    [ IsCyc, IsCyclotomicField and IsCyclotomicCollection ],
    function ( z, F )
    return Conductor( F ) mod Conductor( z ) = 0;
    end );


#############################################################################
##
#M  Intersection2( <F>, <G> ) . . . . . intersection of abelian number fields
##
InstallMethod( Intersection2,
    "for two cyclotomic fields of cyclotomics",
    IsIdenticalObj,
    [ IsCyclotomicField and IsCyclotomicCollection,
      IsCyclotomicField and IsCyclotomicCollection ],
    function ( F, G )
    return CyclotomicField( GcdInt( Conductor( F ), Conductor( G ) ) );
    end );

InstallMethod( Intersection2,
    "for cyclotomic field and abelian number field",
    IsIdenticalObj,
    [ IsCyclotomicField and IsCyclotomicCollection,
      IsAbelianNumberField and IsCyclotomicCollection ],
    function ( F, G )

    # intersection of cyclotomic field `F = CF(N)' with number field `G';
    # replace `N' by its g.c.d. with the conductor of `G',
    # and then take the elements of `GaloisStabilizer( G )' modulo `N'.
    # (If a reduction is necessary, `NF' will do.)

    F:= Gcd( Conductor( F ), Conductor( G ) );
    return AbelianNumberField( F, Set( GaloisStabilizer( G ),
                                             x -> x mod F ) );
    end );

InstallMethod( Intersection2,
    "for abelian number field and cyclotomic field",
    IsIdenticalObj,
    [ IsAbelianNumberField and IsCyclotomicCollection,
      IsCyclotomicField and IsCyclotomicCollection ],
    function ( G, F )

    # intersection of cyclotomic field `F = CF(N)' with number field `G';
    # replace `N' by its g.c.d. with the conductor of `G',
    # and then take the elements of `GaloisStabilizer( G )' modulo `N'.
    # (If a reduction is necessary, `NF' will do.)

    F:= Gcd( Conductor( F ), Conductor( G ) );
    return AbelianNumberField( F, Set( GaloisStabilizer( G ),
                                             x -> x mod F ) );
    end );

InstallMethod( Intersection2,
    "for two abelian number fields",
    IsIdenticalObj,
    [ IsAbelianNumberField and IsCyclotomicCollection,
      IsAbelianNumberField and IsCyclotomicCollection ],
    function ( F, G )

    local i, j, N, stab, stabF, stabG;

    # first compute `N' where `CF(N)' contains the intersection;
    # reduce the elements of the stabilizers modulo `N', i.e. intersect
    # `F' and `G' with `CF(N)';
    # then compute the corresponding stabilizer, i.e. the product of
    # stabilizers.
    N:= GcdInt( Conductor( F ), Conductor( G ) );
    stabF:= Set( GaloisStabilizer( F ), x -> x mod N );
    stabG:= Set( GaloisStabilizer( G ), x -> x mod N );
    stab:= [];
    for i in stabF do
      for j in stabG do
        AddSet( stab, ( i * j ) mod N );
      od;
    od;

    # (If a reduction is necessary, `NF' will do.)
    return AbelianNumberField( N, stab );
    end );


#############################################################################
##
#M  GeneratorsOfDivisionRing( <F> ) .  field gens. of an abelian number field
#M  GeneratorsOfAlgebraWithOne( <F> )
##
##  We have a primitive element of the field extension over the Rationals,
##  thus its powers form a basis.
##
Perform( [ GeneratorsOfDivisionRing, GeneratorsOfAlgebraWithOne ],
  function( op )
    InstallMethod( op,
    "for abelian number field of cyclotomics",
    [ IsAbelianNumberField and IsCyclotomicCollection ],
    function( F )
    local e;
    e:= E( Conductor( F ) );
    return [ Sum( GaloisStabilizer( F ), y -> GaloisCyc( e, y ) ) ];
    end );
  end );


#############################################################################
##
#M  Conductor( <F> )  . . . . . . . . .  conductor of an abelian number field
##
InstallOtherMethod( Conductor,
    "for abelian number field of cyclotomics",
    [ IsAbelianNumberField and IsCyclotomicCollection ],
    F -> Conductor( GeneratorsOfField( F ) ) );


#############################################################################
##
#M  Subfields( <F> )  . . . . . . . . .  subfields of an abelian number field
##
##  The Galois group of an abelian number field is abelian,
##  so the subfields are in bijection with the conjugacy classes of subgroups
##  of the Galois group.
##
InstallMethod( Subfields,
    "for abelian number field of cyclotomics",
    [ IsAbelianNumberField and IsCyclotomicCollection ],
    function( F )
    local n, stab;
    n:= Conductor( F );
    stab:= GaloisStabilizer( F );
    return Set( ConjugacyClassesSubgroups( GaloisGroup( F ) ),
                      x -> AbelianNumberField( n, Union( stab,
                             List( GeneratorsOfGroup( Representative( x ) ),
                                   y -> ExponentOfPowering( y ) ) ) ) );
    end );


#############################################################################
##
#M  PrimeField( <F> ) . . . . . . . . . . . . . . for an abelian number field
##
InstallMethod( PrimeField,
    "for abelian number field of cyclotomics",
    [ IsAbelianNumberField and IsCyclotomicCollection ],
    F -> Rationals );


#############################################################################
##
#M  FieldExtension( <subfield>, <poly> )  . .  extend an abelian number field
##
InstallOtherMethod( FieldExtension,
    "for field of cyclotomics, and univ. polynomial (degree <= 2)",
#T CollPoly
    [ IsAbelianNumberField and IsCyclotomicCollection,
      IsLaurentPolynomial ],
    function( F, poly )

    local coeffs, root;

    coeffs:= CoefficientsOfLaurentPolynomial( poly );
    coeffs:= ShiftedCoeffs( coeffs[1], coeffs[2] );

    if not IsSubset( F, coeffs ) then
      Error( "all coefficients of <poly> must lie in <F>" );
    elif 3 < Length( coeffs ) then
      TryNextMethod();
    elif Length( coeffs ) <= 1 then
      Error( "<poly> must have degree at least 1" );
    elif Length( coeffs ) = 2 then

      # `poly' is a linear polynomial.
      root:= - coeffs[1] / coeffs[2];
      F:= AsField( F, F );

    else

      # `poly' has degree 2.
      # The roots of `a*x^2 + b*x + c' are
      # $\frac{ -b \pm \sqrt{ b^2 - 4ac } }{2a}$.
      root:= coeffs[2]^2 - 4 * coeffs[1] * coeffs[3];
      if not IsRat( root ) then
        TryNextMethod();
      fi;
      root:= ( ER( root ) - coeffs[2] ) / ( 2 * coeffs[3] );
      F:= AsField( F, FieldByGenerators(
                       Concatenation( GeneratorsOfField( F ), [ root ] ) ) );

    fi;

    # Store the defining polynomial, and a root of it in the extension field.
    SetDefiningPolynomial( F, poly );
    SetRootOfDefiningPolynomial( F, root );

    return F;
    end );


#############################################################################
##
#M  Conjugates( <L>, <K>, <z> )
##
InstallMethod( Conjugates,
    "for two abelian number fields of cyclotomics, and cyclotomic",
    IsCollsXElms,
    [ IsAbelianNumberField and IsCyclotomicCollection,
      IsAbelianNumberField and IsCyclotomicCollection, IsCyc ],
    function( L, K, z )

    local N, gal, gens, conj, pnt;

    N:= Conductor( L );

    # automorphisms of the conductor
    gal:= PrimeResidues( N );

    if not IsPrimeField( K ) then

      # take only the subgroup of `gal' that fixes the subfield pointwise
      gens:= GeneratorsOfField( K );
      gal:= Filtered( gal,
                      x -> ForAll( gens, y -> GaloisCyc( y, x ) = y ) );
    fi;

    # get representatives of cosets of the Galois stabilizer
    conj:= [];
    gens:= GaloisStabilizer( L );
    while gal <> [] do
      pnt:= gal[1];
      Add( conj, GaloisCyc( z, pnt ) );
      SubtractSet( gal, List( gens, x -> ( x * pnt ) mod N ) );
    od;

    return conj;
    end );

InstallMethod( Conjugates,
    "for cycl. field of cyclotomics, ab. number field, and cyclotomic",
    IsCollsXElms,
    [ IsCyclotomicField and IsCyclotomicCollection,
      IsAbelianNumberField and IsCyclotomicCollection, IsCyc ],
    function( L, K, z )

    local conj, Kgens, i;

    if not z in L then
      Error( "<z> must lie in <L>" );
    fi;

    if IsPrimeField( K ) then
      conj:= List( PrimeResidues( Conductor( L ) ),
                   i -> GaloisCyc( z, i ) );
    else
      conj:= [];
      Kgens:= GeneratorsOfField( K );
      for i in PrimeResidues( Conductor( L ) ) do
        if ForAll( Kgens, x -> GaloisCyc( x, i ) = x ) then
          Add( conj, GaloisCyc( z, i ) );
        fi;
      od;
    fi;

    return conj;
    end );


#############################################################################
##
#M  Norm( <L>, <K>, <z> )
##
InstallMethod( Norm,
    "for two abelian number fields of cyclotomics, and cyclotomic",
    IsCollsXElms,
    [ IsAbelianNumberField and IsCyclotomicCollection,
      IsAbelianNumberField and IsCyclotomicCollection, IsCyc ],
    function( L, K, z )
    local N, gal, gens, result, pnt;

    N:= Conductor( L );

    # automorphisms of the conductor
    gal:= PrimeResidues( N );

    if not IsPrimeField( K ) then

      # take only the subgroup of `gal' that fixes the subfield pointwise
      gens:= GeneratorsOfField( K );
      gal:= Filtered( gal,
                      x -> ForAll( gens, y -> GaloisCyc( y, x ) = y ) );
    fi;

    # get representatives of cosets of `GaloisStabilizer( L )'
    result:= 1;
    gens:= GaloisStabilizer( L );
    while gal <> [] do
      pnt:= gal[1];
      result:= result * GaloisCyc( z, pnt );
      SubtractSet( gal, List( gens, x -> ( x * pnt ) mod N ) );
    od;

    return result;
    end );

InstallMethod( Norm,
    "for cycl. field of cyclotomics, ab. number field, and cyclotomic",
    IsCollsXElms,
    [ IsCyclotomicField and IsCyclotomicCollection,
      IsAbelianNumberField and IsCyclotomicCollection, IsCyc ],
    function( L, K, z )

    local i, result, Kgens;

    result:= 1;
    if IsPrimeField( K ) then
      for i in PrimeResidues( Conductor( L ) ) do
        result:= result * GaloisCyc( z, i );
      od;
    else
      Kgens:= GeneratorsOfField( K );
      for i in PrimeResidues( Conductor( L ) ) do
        if ForAll( Kgens, x -> GaloisCyc( x, i ) = x ) then
          result:= result * GaloisCyc( z, i );
        fi;
      od;
    fi;

    return result;
    end );


#############################################################################
##
#M  Trace( <L>, K>, <z> )
##
InstallMethod( Trace,
    "for two abelian number fields of cyclotomics, and cyclotomic",
    IsCollsXElms,
    [ IsAbelianNumberField and IsCyclotomicCollection,
      IsAbelianNumberField and IsCyclotomicCollection, IsCyc ],
    function( L, K, z )
    local N, gal, gens, result, pnt;

    N:= Conductor( L );

    # automorphisms of the conductor
    gens:= GeneratorsOfField( K );
    gal:= PrimeResidues( N );

    if not IsPrimeField( K ) then

      # take only the subgroup of `gal' that fixes the subfield pointwise
      gal:= Filtered( gal,
                      x -> ForAll( gens, y -> GaloisCyc( y, x ) = y ) );
    fi;

    # get representatives of cosets of `GaloisStabilizer( L )'
    result:= 0;
    gens:= GaloisStabilizer( L );
    while gal <> [] do
      pnt:= gal[1];
      result:= result + GaloisCyc( z, pnt );
      SubtractSet( gal, List( gens, x -> ( x * pnt ) mod N ) );
    od;

    return result;
    end );

InstallMethod( Trace,
    "for cycl. field of cyclotomics, ab. number field, and cyclotomic",
    IsCollsXElms,
    [ IsCyclotomicField and IsCyclotomicCollection,
      IsAbelianNumberField and IsCyclotomicCollection, IsCyc ],
    function( L, K, z )
    local i, result, Kgens;
    result:= 0;
    if IsPrimeField( K ) then
      for i in PrimeResidues( Conductor( L ) ) do
        result:= result + GaloisCyc( z, i );
      od;
    else
      Kgens:= GeneratorsOfField( K );
      for i in PrimeResidues( Conductor( L ) ) do
        if ForAll( Kgens, x -> GaloisCyc( x, i ) = x ) then
          result:= result + GaloisCyc( z, i );
        fi;
      od;
    fi;

    return result;
    end );


#############################################################################
##
#F  ZumbroichBase( <n>, <m> )
##
##  returns the set of exponents `e' for which `E(n)^e' belongs to the
##  (generalized) Zumbroich base of the cyclotomic field $Q_n$,
##  viewed as vector space over $Q_m$.
##
##  *Note* that for $n \equiv 2 \bmod 4$ we have
##  `ZumbroichBase( <n>, 1 ) = 2 * ZumbroichBase( <n>/2, 1 )' but
##  `List( ZumbroichBase(  <n>, 1  ), x -> E(  <n>  )^x ) =
##   List( ZumbroichBase( <n>/2, 1 ), x -> E( <n>/2 )^x )'.
##
InstallGlobalFunction( ZumbroichBase, function( n, m )

    local nn, base, basefactor, factsn, exponsn, factsm, exponsm, primes,
          p, pos, i, k;

    if not n mod m = 0 then
      Error( "<m> must be a divisor of <n>" );
    fi;

    factsn:= Factors(Integers, n );
    primes:= Set( factsn );
    exponsn:= List( primes, x -> 0 );   # Product(List( [1..Length(primes)],
                                        #         x->primes[i]^exponsn[i]))=n
    p:= factsn[1];
    pos:= 1;
    for i in factsn do
      if i > p then
        p:= i;
        pos:= pos + 1;
      fi;
      exponsn[ pos ]:= exponsn[ pos ] + 1;
    od;

    factsm:= Factors(Integers, m );
    exponsm:= List( primes, x -> 0 );    # Product(List( [1..Length(primes)],
                                         #         x->primes[i]^exponsm[i]))=m
    if m <> 1 then
      p:= factsm[1];
      pos:= Position( primes, p );
      for i in factsm do
        if i > p then
          p:= i;
          pos:= Position( primes, p );
        fi;
        exponsm[ pos ]:= exponsm[ pos ] + 1;
      od;
    fi;

    base:= [ 0 ];
    if n = 1 then
      return base;
    fi;

    if primes[1] = 2 then

      # special case: $J_{k,2} = \{ 0, 1 \}$
      if exponsm[1] = 0 then exponsm[1]:= 1; fi;    # $J_{0,2} = \{ 0 \}$

      nn:= n / 2^( exponsm[1] + 1 );

      for k in [ exponsm[1] .. exponsn[1] - 1 ] do
        Append( base, base + nn );
        nn:= nn / 2;
      od;
      pos:= 2;
    else
      pos:= 1;
    fi;

    for i in [ pos .. Length( primes ) ] do

      if m mod primes[i] <> 0 then
        basefactor:= [ 1 .. primes[i] - 1 ] * ( n / primes[i] );
        base:= Concatenation( List( base, x -> x + basefactor ) );
        exponsm[i]:= 1;
      fi;

      basefactor:= [ - ( primes[i] - 1 ) / 2 .. ( primes[i] - 1 ) / 2 ]
                     * n / primes[i]^exponsm[i];

      for k in [ exponsm[i] .. exponsn[i] - 1 ] do
        basefactor:= basefactor / primes[i];
        base:= Concatenation( List( base, x -> x + basefactor ) );
      od;
    od;
    return Set( base, x -> x mod n );
end );


#############################################################################
##
#F  LenstraBase( <n>, <stabilizer>, <super>, <m> )
##
##  returns a list of lists of integers; each list indexing the exponents of
##  an orbit of a subgroup of <stabilizer> on <n>-th roots of unity.
##
##  <super> is a list representing a supergroup of <stabilizer> which
##  shall act consistently with the action of <stabilizer>, i.e., each orbit
##  of <supergroup> is a union of orbits of <stabilizer>.
##
##  ( Shall there be a test if this is possible ? )
##
##  <m> is a positive integer.  The basis described by the returned list is
##  an integral basis over the cyclotomic field $\Q_m$.
##
##  *Note* that the elements are in general not sets, since the first element
##  is always an element of `ZumbroichBase( <n>, <m> )';
##  this property is used by `NF' and `Coefficients'.
##
##  *Note* that <stabilizer> must not contain the stabilizer of a proper
##  cyclotomic subfield of the <n>-th cyclotomic field.
##
##  We proceed as follows.
##
##  Let $n'$ be the biggest divisor of $n$ coprime to $m$.
##  First choose an integral basis $B$ for the extension $\Q_{n'} / \Q$
##  (equivalently, for $\Q_{n} / \Q_{n/n'}$).
##  For each element of $B$ choose an integral basis for $\Q_{n/n'} / \Q_m$,
##  namely a transversal of $E_m$ in $E_{n/n'}$ where $E_n$ denotes the
##  group of $n$-th roots of unity.
##
##  The products of elements in these bases form an integral $\Q_m$-basis
##  of $\Q_n$.
##  Now we choose the bases in such a way that ...
##
InstallGlobalFunction( LenstraBase, function( n, stabilizer, supergroup, m )

    local i,
          k,
          factors,           # factors of `n'
          primes,            # set of prime divisors of `n'
          coprimes,          # set of prime divisors of `n' coprime to `m'
          nprime,            # biggest divisor of `n' coprime to `m'
          NN,                # squarefree part of `n'
          zumb,              # exponents of roots in the basis of `CF(n)'
          N2,                # 2-part of `n'
          No,                # odd part of `n'
          transversal,       # roots in basis of `CF(n/nprime) / CF(m)',
                             # written as `n'-th roots
          orbits,
          pnt,
          orb,
          d,
          ppnt,
          ord,
          a,
          neworbits,
          rep,
          super,
          H1;

    # We may assume that either `m' is odd or $4$ divides `m'.
    if m mod 4 = 2 then
      m:= m / 2;
    fi;

    factors  := Factors(Integers, n );
    primes   := Set( factors );
    coprimes := Filtered( primes, x -> m mod x <> 0 );
    nprime   := Product( Filtered( factors, x -> m mod x <> 0 ) );

    NN:= Product( coprimes );
    zumb:= List( ZumbroichBase( nprime, 1 ), x -> x * ( n / nprime ) );
    transversal := List( ZumbroichBase( n / nprime, m ), x -> x * nprime );
    stabilizer:= Set( stabilizer );
    orbits:= [];

    if nprime = NN then

      # $n'$ is squarefree.
      # We have a normal basis, `stabilizer' acts on `zumb',
      # we do not consider equivalence classes since they are all trivial,
      # and `supergroup' is obsolete since `zumb' describes a normal basis.

      # *Note* that if $n'$ is even then `zumb' does not consist of
      # at least `NN'-th roots!

      while 0 < Length( zumb ) do

        # Compute the orbit of `stabilizer' of a point in `zumb'.
        pnt:= zumb[1];

        # For each root in `transversal', compute the orbit of `n'-th roots
        # under `stabilizer'.
        neworbits:= List( transversal,
                          root -> List( stabilizer,
                                        x -> ( root + pnt ) * x mod n ) );
        SubtractSet( zumb, neworbits[1] );
        Append( orbits, neworbits );

      od;

    else

      # Let $d(i)$ be the largest squarefree number whose square divides the
      # order of $e_{n'}^i$, that is $n' / \gcd( n', i )$.
      # Define an equivalence relation on the set $S$ of at least `NN'-th
      # roots of unity.
      # $i$ and $j$ are equivalent iff $n'$ divides $( i - j ) d(i)$.  The
      # equivalence class $(i)$ of $i$ is
      # $\{ i + k n' / d(i) ; 0 \leq k \< d(i) \}$.

      # For the case that `NN' is even, replace those roots in $S$ with order
      # not divisible by 4 by their negatives.
      # (Equivalently\: Replace *all* elements in $S$ by their negatives.)

      # If 8 does not divide $n'$ and $n' \not= 4$, `zumb' is a subset of $S$,
      # the intersection of $(i)$ with `zumb' is of order $\varphi( d(i) )$,
      # it is a basis for the $Z$--submodule spanned by $(i)$.
      # Furthermore, the minimality of `n' yields that `stabilizer' acts fixed
      # point freely on the set of equivalence classes.

      # More exactly, fixed points occur exactly if there is an element `s' in
      # `stabilizer' which is congruent $-1$ modulo `N2' and congruent $+1$
      # modulo `No'.

      # The base is constructed as follows\:
      #
      # Until all classes are touched:
      # 1. Take a point `pnt' (in `zumb').
      # 2. Choose a maximal linear independent set `pnts' in the equivalence
      #    class of `pnt' (the intersection of the class with `zumb').
      # 3. Take the `stabilizer'--orbits of `pnts' as base elements;
      #    remove the touched equivalence classes.
      # 4. For the representatives `rep' in `supergroup'\:
      #    If `rep' maps `pnt' to an equivalence class that was not yet
      #    touched, take the `stabilizer'--orbits of the images of `pnts'
      #    under `rep' as base elements;
      #    remove the touched equivalence classes.

      # Compute nontriv. representatives of `supergroup' over `stabilizer'.
      super:= Difference( supergroup, stabilizer );
      supergroup:= [];
      while 0 < Length( super ) do
        pnt:= super[1];
        Add( supergroup, pnt );
        SubtractSet( super, List( stabilizer, x -> ( x * pnt ) mod n ) );
      od;

      # Compute 2-part and odd part of $n'$.
      N2 := 1;
      No := nprime;
      while No mod 2 = 0 do
        N2:= N2 * 2;
        No:= No / 2;
      od;

      # Compute the subgroup `H1' of `stabilizer' that acts fixed point
      # freely on the set of equivalence classes,
      # and the element `a' that (if exists) fixes some classes pointwise.
      H1 := [];
      a  := 0;
      for k in stabilizer do
        if k mod 4 = 1 then
          Add( H1, k );
        elif ( k -1 ) mod No = 0
             and ( ( k + 1 ) mod N2 = 0 or ( k + 1 - N2/2 ) mod N2 = 0 ) then
          a:= k;
        fi;
      od;
      if a = 0 then
        H1:= stabilizer;
      fi;

      while 0 < Length( zumb ) do

        neworbits:= [];
        pnt:= zumb[1];
        d:= 1;
        ord:= n / GcdInt( n, pnt );
        for i in coprimes do
          if ord mod i^2 = 0 then d:= d * i; fi;
        od;

        if ( a = 0 ) or ( ord mod 8 = 0 ) then

          # No `H1'-orbit can be fixed by `a'.

          for k in [ 0 .. d-1 ] do

            # Loop over the equivalence class of `pnt',
            # consider only the points in `zumb'.

            ppnt:= pnt + k * n / d;
            if ppnt in zumb then

              orb:= List( stabilizer, x -> ( ppnt * x ) mod n );
              Append( neworbits,
                      List( transversal,
                            root -> List( stabilizer,
                                       x -> ( root + ppnt ) * x mod n ) ) );

            fi;
          od;

        elif ord mod 4 = 0 then

          # `a' maps each point in the orbit of `H1' to its inverse,
          # we ignore all these points.
          orb:= List( stabilizer, x -> ( pnt * x ) mod n );

        else

          # The orbit of `H1' is pointwise fixed by `a'.
          for k in [ 0 .. d-1 ] do
            ppnt:= pnt + k * n / d;
            if ppnt in zumb then

              orb:= List( H1, x -> ( ppnt * x ) mod n );
              Append( neworbits,
                      List( transversal,
                            root -> List( H1,
                                       x -> ( root + ppnt ) * x mod n ) ) );

            fi;
          od;

        fi;

        # Remove the equivalence classes of all new points from `zumb'.
        for pnt in orb do
          SubtractSet( zumb, List( [ 0 .. d-1 ],
                                   k -> ( pnt + k * n / d ) mod n ) );
        od;

        Append( orbits, neworbits );

        # use `supergroup'\:
        # Is there a point in `zumb' that is not equivalent to
        # `( pnt * rep ) mod nprime' ?
        # (Note that the factor group `supergroup / stabilizer' acts on the
        # set of unions of orbits with equivalent elements.)

        for rep in supergroup do

          # is there an `x' in `zumb' that is equivalent to `pnt * rep' ?
          if ForAny( zumb, x -> ( ( x - pnt * rep ) * d ) mod n = 0 ) then
            Append( orbits, List( neworbits,
                              x -> List( x, y -> (y*rep) mod n ) ) );
            for ppnt in orbits[ Length( orbits ) ] do
              SubtractSet( zumb, List( [ 0..d-1 ],
                              k -> ( ppnt + k * n / d ) mod n ) );
            od;
          fi;
        od;

      od;
    fi;

    # Return the list of orbits.
    return orbits;
end );


#############################################################################
##
#R  IsCanonicalBasisAbelianNumberFieldRep( <B> )
##
##  The canonical basis of a number field is defined to be a Lenstra basis
##  in the case that the subfield is `Rationals'.
#T extend this to the case where the subfield is a cyclotomic field!
##  In all other cases a normal basis is chosen.
##
DeclareRepresentation( "IsCanonicalBasisAbelianNumberFieldRep",
    IsAttributeStoringRep,
    [ "coeffslist", "coeffsmat", "lenstrabase", "conductor" ] );


#############################################################################
##
#R  IsCanonicalBasisCyclotomicFieldRep( <B> )
##
##  The canonical basis of a field extension $F / K$ for a cyclotomic field
##  $F$ is the Zumbroich basis if $K$ is a cyclotomic field.
##  Otherwise it is a normal basis.
##
DeclareRepresentation( "IsCanonicalBasisCyclotomicFieldRep",
    IsCanonicalBasisAbelianNumberFieldRep,
    [ "zumbroichbase" ] );


#############################################################################
##
#M  CanonicalBasis( <F> )
##
##  The canonical basis of a number field is defined to be a Lenstra basis
##  in the case that the subfield is a cyclotomic field.
##
##  In all other cases a normal basis is chosen.
##
InstallMethod( CanonicalBasis,
    "for abelian number field of cyclotomics",
    [ IsAbelianNumberField and IsCyclotomicCollection ],
    function ( F )

    local N,             # conductor of `F'
          k,
          lenst,
          i,
          B,
          BB,
          normalbase,
          subbase,
          m,
          j,
          C,
          coeffsmat,
          val,
          l;

    # Make the basis object.
    B:= Objectify( NewType( FamilyObj( F ),
                                IsFiniteBasisDefault
                            and IsCanonicalBasis
                            and IsCanonicalBasisAbelianNumberFieldRep ),
                   rec() );
    SetUnderlyingLeftModule( B, F );

    if IsCyclotomicField( LeftActingDomain( F ) ) then

      # Compute the standard Lenstra basis and the `coeffslist' component.
      # If `GaloisStabilizer( F )' acts fixed point freely on the
      # equivalence classes we must change from the Zumbroich basis to a
      # `GaloisStabilizer( F )'-normal basis,
      # and afterwards choose coefficients with respect to that basis.
      # In the case of fixed points, only the subgroup `H1' of index 2 in
      # `GaloisStabilizer( F )' acts fixed point freely;
      # we change to a `H1'-normal basis, and afterwards choose coefficients.

      # For this basis <B> we want a component `coeffslist' such that
      # in the special case of a field over the rationals we have
      # `CoeffsCyc( z, N ){ <B>!.coeffslist } = Coefficients( <B>, z )'.

      N:= Conductor( F );
      lenst:= LenstraBase( N, GaloisStabilizer( F ), GaloisStabilizer( F ),
                           Conductor( LeftActingDomain( F ) ) );

      # Fill in additional components.
      SetBasisVectors( B, List( lenst,
                                x -> Sum( List( x, y -> E(N)^y ) ) ) );
      B!.coeffslist  := MakeImmutable(List( lenst, x -> x[1] + 1 ));
      B!.lenstrabase := MakeImmutable(lenst);
      B!.conductor   := N;
#T better compute basis vectors only if necessary
#T (in the case of a normal basis the vectors are of course known ...)
      SetIsIntegralBasis( B, true );

    else

      # A basis of an extension of a number field is a normal basis.
#T handle extensions of cycl. fields specially!!
      # Coefficients can be computed using a tensor form basis for that
      # the base change relative to the Lenstra basis (relative to the
      # rationals) is computed.

      # Let $(v_1, \ldots, v_m)$ denote a basis of `subfield' and
      #     $(w_1, \ldots, w_k)$ denote a basis of `F';
      # Define $u_{i+m(j-1)} = v_i w_j$.  Then $(u_l; 1\leq l\leq mk)$
      # is a basis of `F' over the rationals.
      # First change from the Lenstra basis to this basis; the matrix is `C'.

      normalbase:= NormalBase( F );
      subbase:= BasisVectors( CanonicalBasis( LeftActingDomain( F ) ) );
      BB:= CanonicalBasis( AbelianNumberField( Conductor( F ),
                                               GaloisStabilizer( F ) ) );
      m:= Length( subbase );
      k:= Length( normalbase );
      N:= Conductor( normalbase );
      C:= [];
      for j in normalbase do

        # Compute the Lenstra basis coefficients.
        for i in subbase do
          Add( C, Coefficients( BB, i*j ) );
        od;

      od;
      C:= C^(-1);

      # Let $(c_1, \ldots, c_{mk})$ denote the coefficients with respect
      # to the new base.  To achieve `<coeffs> \* normalbase = <z>' we have
      # to take $\sum_{i=1}^m c_{i+m(j-1)} v_i$ as $j$--th coefficient:

      coeffsmat:= [];
      for i in [ 1 .. Length( C ) ] do     # for all rows
        coeffsmat[i]:= [];
        for j in [ 1 .. k ] do
          val:= 0;
          for l in [ 1 .. m ] do
            val:= val + C[i][ m*(j-1)+l ] * subbase[l];
          od;
          coeffsmat[i][j]:= val;
        od;
      od;

      # Multiplication of a Lenstra basis coefficient vector with
      # `coeffsmat' means first changing to the base of products
      # $v_i w_j$ and then summation over the parts of the $v_i$.

      SetIsNormalBasis( B, true );
      SetBasisVectors( B, normalbase );
      B!.coeffslist := BB!.coeffslist;
      B!.coeffsmat  := coeffsmat;
      B!.conductor  := N;

    fi;

    # Return the canonical basis.
    return B;
    end );


#############################################################################
##
#M  Basis( <F> )
##
InstallMethod( Basis,
    "for abelian number field of cyclotomics (delegate to `CanonicalBasis')",
    [ IsAbelianNumberField and IsCyclotomicCollection ],
    CANONICAL_BASIS_FLAGS,
    CanonicalBasis );


#############################################################################
##
#M  Coefficients( <B>, <z> )  . . . . .  for canon. basis of ab. number field
##
InstallMethod( Coefficients,
    "for canonical basis of abelian number field, and cyclotomic",
    IsCollsElms,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisAbelianNumberFieldRep,
      IsCyc ],
    function ( B, z )
    local V,
          F,
          coeffs,
          n,
          m,
          zumb,
          NN,
          Em;

    if not z in UnderlyingLeftModule( B ) then
      return fail;
    fi;

    V:= UnderlyingLeftModule( B );
    F:= LeftActingDomain( V );

    # The information about the standard Lenstra basis coefficients
    # is stored in `B!.coeffslist'.
    if   IsPrimeField( F ) then

      # Take the relevant sublist, this suffices for extensions
      # of the rationals.
      coeffs:= CoeffsCyc( z, B!.conductor ){ B!.coeffslist };

    elif IsCyclotomicField( F ) then

      # `B' is an integral basis of an extension of a cyclotomic field $\Q_m$,
      # the coefficient of the root $\zeta$ is
      # $\sum_{\eta\in\B_m} a_{\eta\zeta} \eta$.

      coeffs:= CoeffsCyc( z, B!.conductor );
      n:= Conductor( V );
      m:= Conductor( F );
      zumb:= CanonicalBasis( F )!.zumbroichbase;
      NN:= n/m;
      Em:= E(m);
      coeffs:= List( B!.coeffslist,
                j->Sum( zumb, k->coeffs[ ((k*NN+j-1) mod n )+1 ]*Em^k ) );

    fi;

    if IsBound( B!.coeffsmat ) then

      # Compute the coefficients with respect to the field extension.
      coeffs:= CoeffsCyc( z, B!.conductor ){ B!.coeffslist } * B!.coeffsmat;

    fi;

    # Return the coefficients list.
    return coeffs;
    end );


#############################################################################
##
#M  FieldByGenerators( <cycscoll> )
#M  FieldByGenerators( <F>, <cycscoll> )
##
InstallOtherMethod( FieldByGenerators,
    "for collection of cyclotomics",
    [ IsCyclotomicCollection ],
    function( gens )

    local N, stab;

    N:= Conductor( gens );

    # Handle trivial cases.
    if   N = 1 then
      return Rationals;
    elif N = 4 then
      return GaussianRationals;
    fi;

    # Compute the reduced stabilizer info.
    stab:= Filtered( PrimeResidues( N ),
                     x -> ForAll( gens,
                                  gen -> GaloisCyc( gen, x ) = gen ) );

    # Construct and return the field.
    return AbelianNumberFieldByReducedGaloisStabilizerInfo( Rationals, N,
               stab );
    end );

InstallMethod( FieldByGenerators,
    "for field and collection, both collections of cyclotomics",
    IsIdenticalObj,
    [ IsField and IsCyclotomicCollection, IsCyclotomicCollection ],
    function( F, gens )

    local N, stab;

    N:= Conductor( gens );

    if F = Rationals then

      # Handle trivial cases.
      if   N = 1 then
        return Rationals;
      elif N = 4 then
        return GaussianRationals;
      fi;

    else
      N:= Lcm( N, Conductor( F ) );
      gens:= Concatenation( gens, GeneratorsOfField( F ) );
    fi;

    # Compute the reduced stabilizer info.
    stab:= Filtered( PrimeResidues( N ),
                     x -> ForAll( gens,
                                  gen -> GaloisCyc( gen, x ) = gen ) );

    # Construct and return the field.
    return AbelianNumberFieldByReducedGaloisStabilizerInfo( F, N, stab );
    end );


#############################################################################
##
#M  DefaultFieldByGenerators( <cycscoll> )
##
InstallMethod( DefaultFieldByGenerators,
    "for collection of cyclotomics",
    [ IsCyclotomicCollection ],
    gens -> CyclotomicField( Conductor( gens ) ) );


#############################################################################
##
#M  CanonicalBasis( <F> )
##
##  The canonical basis of a field extension $F / K$ for a cyclotomic field
##  $F$ is the Zumbroich basis if $K$ is a cyclotomic field.
##  Otherwise it is the first normal basis.
##
InstallMethod( CanonicalBasis,
    "for cyclotomic field of cyclotomics",
    [ IsCyclotomicField and IsCyclotomicCollection ],
    function( F )

    local n,
          m,
          B,
          subfield,
          zumb,
          subvectors,
          vectors,
          i, j, k, l,
          C,
          coeffsmat,
          val;

    n:= Conductor( F );

    B:= Objectify( NewType( FamilyObj( F ),
                                IsFiniteBasisDefault
                            and IsCanonicalBasis
                            and IsCanonicalBasisCyclotomicFieldRep ),
                   rec() );
    SetUnderlyingLeftModule( B, F );
    B!.conductor:= n;

    subfield:= LeftActingDomain( F );

    if IsCyclotomicField( subfield ) then

      SetIsIntegralBasis( B, true );

      # Construct the Zumbroich basis.
      B!.zumbroichbase := MakeImmutable(ZumbroichBase( n, Conductor( subfield ) ));

    else

      # Compute a normal basis.

      # Let $(v_1, \ldots, v_m)$ denote `Basis( F.field ).vectors' and
      #     $(w_1, \ldots, w_k)$ denote `vectors'.
      # Define $u_{i+m(j-1)} = v_i w_j$.  Then $(u_l; 1\leq l\leq mk)$
      # is a $Q$-basis of `F'.  First change from the Zumbroich basis to
      # this basis; the matrix is `C'\:

      zumb       := ZumbroichBase( n, 1 ) + 1;
      subvectors := BasisVectors( Basis( subfield ) );
      vectors    := NormalBase( F );
      m:= Length( subvectors );
      k:= Length( vectors );
      C:= [];
      for j in vectors do
        for i in subvectors do
          Add( C, CoeffsCyc( i*j, n ){ zumb } );
        od;
      od;
      C:= C^(-1);

      # Let $(c_1, \ldots, c_{mk})$ denote the coefficients with respect
      # to the new basis.
      # To achieve `<coeffs> \* BasisVectors( <B> ) = <z>' we have
      # to take $\sum_{i=1}^m c_{i+m(j-1)} v_i$ as $j$--th coefficient\:

      coeffsmat:= [];
      for i in [ 1 .. Length( C ) ] do     # for all rows
        coeffsmat[i]:= [];
        for j in [ 1 .. k ] do
          val:= 0;
          for l in [ 1 .. m ] do
            val:= val + C[i][ m*(j-1)+l ] * subvectors[l];
          od;
          coeffsmat[i][j]:= val;
        od;
      od;

      SetBasisVectors( B, vectors );
      SetIsNormalBasis( B, true );

      B!.zumbroichbase := MakeImmutable(zumb - 1);
      B!.coeffsmat     := MakeImmutable(coeffsmat);

    fi;

    # Return the basis.
    return B;
    end );


#############################################################################
##
#M  BasisVectors( <B> )
##
InstallMethod( BasisVectors,
    "for canon. basis of cyclotomic field of cyclotomics",
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisCyclotomicFieldRep ],
    function( B )
    local e;
    # Basis vectors are bound if the subfield is not a cycl. field.
#T ??
    e:= E( Conductor( UnderlyingLeftModule( B ) ) );
    return List( B!.zumbroichbase, x -> e^x );
    end );


#############################################################################
##
#M  Coefficients( <B>, <z> )  . . . . . . . . for canon. basis of cycl. field
##
InstallMethod( Coefficients,
    "for canonical basis of cyclotomic field, and cyclotomic",
    IsCollsElms,
    [ IsBasis and IsCanonicalBasis and IsCanonicalBasisCyclotomicFieldRep,
      IsCyc ],
    function( B, z )
    local N,
          coeffs,
          F,
          m,
          zumb,
          NN,
          Em;

    F:= UnderlyingLeftModule( B );
    if not z in F then return fail; fi;

    N:= B!.conductor;

    # Get the Zumbroich basis representation of <z> in `N'-th roots.
    coeffs:= CoeffsCyc( z, N );
    if coeffs = fail then return fail; fi;

    F:= LeftActingDomain( F );

    if   IsPrimeField( F ) then

      # Get the Zumbroich basis coefficients (basis $B_{n,1}$)
      coeffs:= coeffs{ B!.zumbroichbase + 1 };

    elif IsCyclotomicField( F ) then

      # Get the Zumbroich basis coefficients (basis $B_{n,m}$) directly.
      m:= Conductor( F );
      zumb:= CanonicalBasis( F )!.zumbroichbase;
      NN:= N/m;
      Em:= E(m);
      coeffs:= List( B!.zumbroichbase,
                     j->Sum( zumb, k->coeffs[ ((k*NN+j) mod N )+1 ]*Em^k ) );

    else

      # The subfield is not a cyclotomic field.
      # The necessary information is stored in `B!.coeffsmat'.
      coeffs:= coeffs{ B!.zumbroichbase + 1 } * B!.coeffsmat;

    fi;

    # Return the list of coefficients.
    return coeffs;
    end );


#############################################################################
##
##  Automorphisms of abelian number fields
##


#############################################################################
##
#R  IsANFAutomorphismRep( <obj> )
##
DeclareRepresentation( "IsANFAutomorphismRep",
    IsAttributeStoringRep, [ "galois" ] );


#############################################################################
##
#P  IsANFAutomorphism( <obj> )
##
DeclareSynonym( "IsANFAutomorphism", IsANFAutomorphismRep
    and IsFieldHomomorphism
    and IsMapping
    and IsBijective );


#############################################################################
##
#M  ExponentOfPowering( <map> )
##
InstallMethod( ExponentOfPowering,
    "for an ANFAutomorphism",
    [ IsMapping and IsANFAutomorphismRep ],
    map -> map!.galois );

InstallMethod( ExponentOfPowering,
    "for an identity mapping",
    [ IsMapping and IsOne ],
    map -> 1 );

InstallMethod( ExponentOfPowering,
    "for a mapping (check whether it is the identity mapping)",
    [ IsMapping ],
    function( map )
    if IsOne( map ) then
      return 1;
    else
      TryNextMethod();
    fi;
    end );


#############################################################################
##
#F  ANFAutomorphism( <F>, <k> )  . .  automorphism of an abelian number field
##
InstallGlobalFunction( ANFAutomorphism, function ( F, k )

    local galois, aut;

    # check the arguments
    if not ( IsAbelianNumberField(F) and IsCyclotomicCollection(F) ) then
      Error("<F> must be an abelian number field consisting of cyclotomics");
    elif not IsRat( k ) then
      Error( "<k> must be an integer" );
    fi;
    if not IsInt( k ) then
#T this is a hack ...
      k:= k mod Conductor( F );
    fi;
    if Gcd( Conductor( F ), k ) <> 1 then
      Error( "<k> must be coprime to the conductor of <F>" );
    fi;

    # Let $F / K$ be a field extension where $Q_n$ is the conductor of $F$;
    # let $S(F)$ be the group of those prime residues mod $n$ that fix $F$
    # pointwise.  The Galois group of $F / K$ is in natural correspondence
    # to $S(K) / S(F)$.  Thus each automorphism of $F / K$ corresponds to
    # a coset $c$ of $S(K)$, and it acts on $F$ like each element of $c$.
    # The automorphism `ANFAutomorphism( F/K, k )' maps $x\in F / K$ to
    # `GaloisCyc( <x>, k )'.

    # Choose the smallest representative ...
    galois:= Set(GaloisStabilizer( F ), x->x*k mod Conductor( F ))[1];
    if galois = 1 then
      return IdentityMapping( F );
    fi;

    # make the mapping
    aut:= Objectify( TypeOfDefaultGeneralMapping( F, F,
                             IsSPGeneralMapping
                         and IsANFAutomorphism ),
                     rec() );

    aut!.galois:= galois;

    return aut;
end );


#############################################################################
##
#M  \=( <aut1>, <aut2> )  . . . .  for automorphisms of abelian number fields
#M  \=( <id>, <aut> ) . . . . . .  for automorphisms of abelian number fields
#M  \=( <aut>, <id> ) . . . . . .  for automorphisms of abelian number fields
##
InstallMethod( \=,
    "for two ANF automorphisms",
    IsIdenticalObj,
    [ IsFieldHomomorphism and IsANFAutomorphismRep,
      IsFieldHomomorphism and IsANFAutomorphismRep ],
    function ( aut1, aut2 )
    return     Source( aut1 ) = Source( aut2 )
           and aut1!.galois = aut2!.galois;
    end );

InstallMethod( \=,
    "for identity mapping and ANF automorphism",
    IsIdenticalObj,
    [ IsMapping and IsOne,
      IsFieldHomomorphism and IsANFAutomorphismRep ],
    function ( id, aut )
    return     Source( id ) = Source( aut )
           and aut!.galois = 1;
    end );

InstallMethod( \=,
    "for ANF automorphism and identity mapping",
    IsIdenticalObj,
    [ IsFieldHomomorphism and IsANFAutomorphismRep,
      IsMapping and IsOne ],
    function ( aut, id )
    return     Source( id ) = Source( aut )
           and aut!.galois = 1;
    end );


#############################################################################
##
#M  \<( <aut1>, <aut2> )  . . . .  for automorphisms of abelian number fields
##
InstallMethod( \<,
    "for two ANF automorphisms",
    IsIdenticalObj,
    [ IsFieldHomomorphism and IsANFAutomorphismRep,
      IsFieldHomomorphism and IsANFAutomorphismRep ],
    function ( aut1, aut2 )
    return    Source( aut1 ) < Source( aut2 )
           or (     Source( aut1 ) = Source( aut2 )
                and aut1!.galois < aut2!.galois );
    end );

InstallMethod( \<,
    "for identity mapping and ANF automorphism",
    IsIdenticalObj,
    [ IsMapping and IsOne,
      IsFieldHomomorphism and IsANFAutomorphismRep ],
    function ( id, aut )
    return    Source( id ) < Source( aut )
           or (     Source( id ) = Source( aut )
                and 1 < aut!.galois );
    end );

InstallMethod( \<,
    "for ANF automorphism and identity mapping",
    IsIdenticalObj,
    [ IsFieldHomomorphism and IsANFAutomorphismRep,
      IsMapping and IsOne ],
    function ( aut, id )
    return Source( aut ) < Source( id );
    end );


#############################################################################
##
#M  ImageElm( <aut>, <cyc> )  . .  for automorphisms of abelian number fields
##
InstallMethod( ImageElm,
    "for ANF automorphism and scalar",
    FamSourceEqFamElm,
    [ IsFieldHomomorphism and IsANFAutomorphismRep, IsCyc ],
    function ( aut, elm )
    return GaloisCyc( elm, aut!.galois );
    end );


#############################################################################
##
#M  ImagesElm( <aut>, <cyc> ) . .  for automorphisms of abelian number fields
##
InstallMethod( ImagesElm,
    "for ANF automorphism and scalar",
    FamSourceEqFamElm,
    [ IsFieldHomomorphism and IsANFAutomorphismRep, IsScalar ],
    function ( aut, elm )
    return [ GaloisCyc( elm, aut!.galois ) ];
    end );


#############################################################################
##
#M  ImagesSet( <aut>, <field> ) .  for automorphisms of abelian number fields
##
InstallMethod( ImagesSet,
    "for ANF automorphism and field",
    CollFamSourceEqFamElms,
    [ IsFieldHomomorphism and IsANFAutomorphismRep, IsField ],
    function ( aut, F )
    return F;
    end );


#############################################################################
##
#M  ImagesRepresentative( <aut>, <cyc> )  . . for autom. of ab. number fields
##
InstallMethod( ImagesRepresentative,
    "for ANF automorphism and scalar",
    FamSourceEqFamElm,
    [ IsFieldHomomorphism and IsANFAutomorphismRep, IsScalar ],
    function ( aut, elm )
    return GaloisCyc( elm, aut!.galois );
    end );


#############################################################################
##
#M  PreImageElm( <aut>, <cyc> ) . . . . . . . for autom. of ab. number fields
##
InstallMethod( PreImageElm,
    "for ANF automorphism and scalar",
    FamRangeEqFamElm,
    [ IsFieldHomomorphism and IsBijective and IsANFAutomorphismRep,
      IsScalar ],
    function ( aut, elm )
    return GaloisCyc( elm, ( 1 / aut!.galois )
                           mod Conductor( Range( aut ) ) );
    end );


#############################################################################
##
#M  PreImagesElm( <aut>, <cyc> )  . . . . . . for autom. of ab. number fields
##
InstallMethod( PreImagesElm,
    "for ANF automorphism and scalar",
    FamRangeEqFamElm,
    [ IsFieldHomomorphism and IsANFAutomorphismRep, IsScalar ],
    function ( aut, elm )
    return [ GaloisCyc( elm, ( 1 / aut!.galois )
                             mod Conductor( Range( aut ) ) ) ];
    end );


#############################################################################
##
#M  PreImagesSet( <aut>, <field> )  . . . . . for autom. of ab. number fields
##
InstallMethod( PreImagesSet,
    "for ANF automorphism and scalar",
    CollFamRangeEqFamElms,
    [ IsFieldHomomorphism and IsANFAutomorphismRep, IsField ],
    function ( aut, F )
    return F;
    end );


#############################################################################
##
#M  PreImagesRepresentative( <aut>, <cyc> ) . for autom. of ab. number fields
##
InstallMethod( PreImagesRepresentative,
    "for ANF automorphism and scalar",
    FamRangeEqFamElm,
    [ IsFieldHomomorphism and IsANFAutomorphismRep, IsScalar ],
    function ( aut, elm )
    return GaloisCyc( elm, ( 1 / aut!.galois )
                           mod Conductor( Range( aut ) ) );
    end );


#############################################################################
##
#M  CompositionMapping2( <aut2>, <aut1> ) . . for autom. of ab. number fields
##
InstallMethod( CompositionMapping2,
    "for two ANF automorphisms",
    FamSource1EqFamRange2,
    [ IsFieldHomomorphism and IsANFAutomorphismRep,
      IsFieldHomomorphism and IsANFAutomorphismRep ],
    function ( aut1, aut2 )
    return ANFAutomorphism( Source( aut1 ), aut1!.galois * aut2!.galois );
    end );


#############################################################################
##
#M  InverseGeneralMapping( <aut> )  . . . . . for autom. of ab. number fields
##
InstallOtherMethod( InverseGeneralMapping,
    "for ANF automorphism",
    [ IsFieldHomomorphism and IsANFAutomorphismRep ],
    aut -> ANFAutomorphism( Source( aut ), 1 / aut!.galois ) );


#############################################################################
##
#M  \^( <aut>, <n> )  . . . . . . . . . . . . for autom. of ab. number fields
##
InstallMethod( \^,
    "for ANF automorphism and integer",
    [ IsFieldHomomorphism and IsANFAutomorphismRep, IsInt ],
    function ( aut, i )
    return ANFAutomorphism( Source( aut ), aut!.galois^i );
    end );


#############################################################################
##
#M  PrintObj( <aut> ) . . . . . . . . . . . . for autom. of ab. number fields
##
InstallMethod( PrintObj,
    "for ANF automorphism",
    [ IsFieldHomomorphism and IsANFAutomorphismRep ],
    function ( aut )
    Print( "ANFAutomorphism( ", Source( aut ), ", ", aut!.galois, " )" );
    end );


#############################################################################
##
#M  GaloisGroup( <F> )  . . . . . . . Galois group of an abelian number field
##
##  The required group is a factor group of the Galois group $G$
##  of the enveloping cyclotomic field.
##  So the group $U$ generated by the actions of the generators of $G$ on <F>
##  is the Galois group of <F>, viewed as field over the rationals.
##
##  If <F> is a field over a proper extension of the rationals then we take
##  the pointwise stabilizer of the subfield in $U$.
##
InstallMethod( GaloisGroup,
    "for abelian number field ",
    [ IsAbelianNumberField ],
    function( F )
    local group;

    group:= GroupByGenerators( List( Flat(
                    GeneratorsPrimeResidues( Conductor( F ) ).generators ),
                        x -> ANFAutomorphism( F, x ) ),
                IdentityMapping( F ) );

    if not IsPrimeField( LeftActingDomain( F ) ) then
      group:= Stabilizer( group,
                  GeneratorsOfField( LeftActingDomain( F ) ), OnTuples );
    fi;

    return group;
end );


InstallMethod( Representative,
    [ IsAdditiveMagmaWithZero and IsCyclotomicCollection ],
    f -> 0 );
