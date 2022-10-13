#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Alexander Hulpke.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  This file contains the methods for finitely presented algebras.
##  So far, there are not many.
##


#############################################################################
##
#M  ElementOfFpAlgebra( <Fam>, <elm> )  . . . .  for family of f.p. alg.elms.
##
InstallMethod(ElementOfFpAlgebra,
    "for family of fp. alg. elements and ring element",
    true,
    [ IsElementOfFpAlgebraFamily, IsRingElement ], 0,
    function( fam, elm )
    return Objectify( fam!.defaultType, [ Immutable( elm ) ] );
    end );


#############################################################################
##
#M  ElementOfFpAlgebra( <Fam>, <elm> )  . .  for family with nice normal form
##
InstallMethod( ElementOfFpAlgebra,
    "for fp. alg. elms. family with normal form, and ring element",
    true,
    [ IsElementOfFpAlgebraFamily and HasNiceNormalFormByExtRepFunction,
      IsRingElement ], 0,
    function( Fam, elm )
    return NiceNormalFormByExtRepFunction( Fam )( Fam, ExtRepOfObj( elm ) );
    end );


#############################################################################
##
#M  ExtRepOfObj( <elm> )  . . . . . . . . . . . . .  for f.p. algebra element
##
##  The external representation of elements in an f.p. algebra is defined as
##  a list of length 2, the first entry being the zero coefficient,
##  the second being a zipped list containing the external representations
##  of the monomials and their coefficients.
##
InstallMethod( ExtRepOfObj,
    "for f.p. algebra element",
    true,
    [ IsElementOfFpAlgebra and IsPackedElementDefaultRep ], 0,
    elm -> ExtRepOfObj( elm![1] ) );


#############################################################################
##
#M  ObjByExtRep( <Fam>, <descr> ) . for f.p. alg. elms. fam. with normal form
##
InstallMethod( ObjByExtRep,
    "for family of f.p. algebra elements with normal form",
    true,
    [ IsElementOfFpAlgebraFamily and HasNiceNormalFormByExtRepFunction,
      IsList ], 0,
    function( Fam, descr )
    return NiceNormalFormByExtRepFunction( Fam )( Fam, descr );
    end );


############################################################################
##
#M  MappedExpression( <expr>, <gens1>, <gens2> )
##
BindGlobal( "MappedExpressionForElementOfFreeAssociativeAlgebra",
    function( expr, gens1, gens2 )

    local mapped,      # the mapped expression, result
          gen,         # one in `gens1'
          one,         # 1 of the coefficients field
          MappedWord,  # local function to map words
          i,           # loop over summands
          pos;         # position in a list

    expr:= ExtRepOfObj( expr )[2];
    if IsEmpty( expr ) then
      return Zero( gens2[1] );
    fi;

    # Get the numbers corresponding to the generators.
    gens1:= List( gens1, x -> ExtRepOfObj( x )[2] );
    for i in [ 1 .. Length( gens1 ) ] do
      gen:= gens1[i];
      if Length( gen ) = 2 and IsOne( gen[2] ) then
        gen:= gen[1];
        if Length( gen ) = 0 then
          gens1[i]:= 0;
        elif Length( gen ) = 2 and gen[2] = 1 then
          gens1[i]:= gen[1];
        else
          Error( "<gens1> must be list of generators or identity" );
        fi;
      else
        Error( "<gens1> must be list of generators or identity" );
      fi;
    od;
#T This was quite expensive.
#T Better introduce `MappedExpressions' to do this work not so often?

    one:= One( expr[2] );

    MappedWord:= function( word )
    local mapped, i;
    mapped:= gens2[ Position( gens1, word[1], 0 ) ] ^ word[2];
    for i in [ 4, 6 .. Length( word ) ] do
      if word[i] = 1 then
        mapped:= mapped * gens2[ Position( gens1, word[i-1], 0 ) ];
      else
        mapped:= mapped * gens2[ Position( gens1, word[i-1], 0 ) ] ^ word[i];
      fi;
    od;
    return mapped;
    end;

    # The empty word can be at most at the first position.
    if IsEmpty( expr[1] ) then
      pos:= Position( gens1, 0, 0 );
      if pos <> fail then
        mapped:= gens2[ pos ];
      else
        mapped:= One( gens2[1] );
      fi;
    else
      mapped:= MappedWord( expr[1] );
    fi;

    # Avoid to multiply explicitly with 1 in order to avoid deep trees.
    if expr[2] <> one then
      mapped:= expr[2] * mapped;
    fi;

    for i in [ 4, 6 .. Length( expr ) ] do
      if expr[i] = one then
        mapped:= mapped + MappedWord( expr[ i-1 ] );
      else
        mapped:= mapped + expr[i] * MappedWord( expr[ i-1 ] );
      fi;
    od;

    return mapped;
end );
#T special method for expression trees! (see GAP 3.5)

InstallMethod( MappedExpression,
    "for element of f.p. algebra, and two lists of generators",
    IsElmsCollsX,
    [ IsElementOfFpAlgebra, IsHomogeneousList, IsHomogeneousList ], 0,
#T install same method for free ass. algebra elements!
    MappedExpressionForElementOfFreeAssociativeAlgebra );


#############################################################################
##
#M  \=( <x>, <y> )  . . . . . . . .  for two normalized f.p. algebra elements
##
InstallMethod( \=,
    "for two normalized f.p. algebra elements",
    IsIdenticalObj,
    [ IsElementOfFpAlgebra and IsNormalForm,
      IsElementOfFpAlgebra and IsNormalForm ], 0,
    function( x, y )
    return ExtRepOfObj( x ) = ExtRepOfObj( y );
    end );

#T missing: \= method to look for normal form in the family


#############################################################################
##
#M  \=( <x>, <y> )  . . . . . . . . . . . . . . for two f.p. algebra elements
##
InstallMethod( \=,
    "for two f.p. algebra elements (try nice monomorphism)",
    IsIdenticalObj,
    [ IsElementOfFpAlgebra,
      IsElementOfFpAlgebra ], 0,
    function( x, y )
    local hom;
    hom:= NiceAlgebraMonomorphism( FamilyObj( x )!.wholeAlgebra );
    if hom = fail then
      TryNextMethod();
    fi;
    return ImagesRepresentative( hom, x ) = ImagesRepresentative( hom, y );
    end );


#############################################################################
##
#M  \<( <x>, <y> )  . . . . . . . .  for two normalized f.p. algebra elements
##
##  The ordering is defined as follows.
##  Expressions with less summands are shorter,
##  and for expressions with the same number of summands,
##  the words in algebra generators and the coefficients are compared
##  according to the ordering in the external representation.
##
InstallMethod( \<,
    "for two normalized f.p. algebra elements",
    IsIdenticalObj,
    [ IsElementOfFpAlgebra and IsNormalForm,
      IsElementOfFpAlgebra and IsNormalForm ], 0,
    function( x, y )
    local lenx, leny, i;

    x:= ExtRepOfObj( x )[2];
    y:= ExtRepOfObj( y )[2];
    lenx:= Length( x );
    leny:= Length( y );

    # Compare the lengths.
    if lenx < leny then
      return true;
    elif leny < lenx then
      return false;
    fi;

    # For expressions of same length, compare the summands.
    for i in [ 1 .. lenx ] do
      if x[i] < y[i] then
        return true;
      elif y[i] < x[i] then
        return false;
      fi;
    od;

    # The operands are equal.
    return false;
    end );


#############################################################################
##
#M  \<( <x>, <y> )  . . . . . . . . . . . . . . for two f.p. algebra elements
##
InstallMethod( \<,
    "for two f.p. algebra elements (try nice monomorphism)",
    IsIdenticalObj,
    [ IsElementOfFpAlgebra,
      IsElementOfFpAlgebra ], 0,
    function( x, y )
    local hom;
    hom:= NiceAlgebraMonomorphism( FamilyObj( x )!.wholeAlgebra );
    if hom = fail then
      TryNextMethod();
    fi;
    return ImagesRepresentative( hom, x ) < ImagesRepresentative( hom, y );
    end );


#############################################################################
##
#M  FactorFreeAlgebraByRelators( <F>, <rels> )  . . .  factor of free algebra
##
InstallGlobalFunction( FactorFreeAlgebraByRelators, function( F, rels )
    local A, fam;

    # Create a new family.
    fam := NewFamily( "FamilyElementsFpAlgebra", IsElementOfFpAlgebra );

    # Create the default type for the elements.
    fam!.defaultType := NewType( fam,
                       IsElementOfFpAlgebra and IsPackedElementDefaultRep );

    fam!.freeAlgebra := F;
    fam!.relators := Immutable( rels );
    fam!.familyRing := FamilyObj(LeftActingDomain(F));

    # We do not set the characteristic since this depends on the fact
    # whether or not we are 0-dimensional.

    # Create the algebra.
    if IsAlgebraWithOne( F ) then

      A := Objectify(
          NewType( CollectionsFamily( fam ),
                       IsSubalgebraFpAlgebra
                   and IsAlgebraWithOne
                   and IsWholeFamily
                   and IsAttributeStoringRep ),
          rec() );

      SetLeftActingDomain( A, LeftActingDomain( F ) );
      SetGeneratorsOfAlgebraWithOne( A,
          List( GeneratorsOfAlgebraWithOne( F ),
                i -> ElementOfFpAlgebra( fam, i ) ) );

    else

      A := Objectify(
          NewType( CollectionsFamily( fam ),
                       IsSubalgebraFpAlgebra
                   and IsWholeFamily
                   and IsAttributeStoringRep ),
          rec() );

      SetLeftActingDomain( A, LeftActingDomain( F ) );
      SetGeneratorsOfAlgebra( A,
          List( GeneratorsOfAlgebra( F ),
                i -> ElementOfFpAlgebra( fam, i ) ) );

    fi;

    SetZero( fam, ElementOfFpAlgebra( fam, Zero( F ) ) );
    UseFactorRelation( F, rels, A );
    SetIsFullFpAlgebra( A, true );
    fam!.wholeAlgebra:= A;

    return A;
end );


#############################################################################
##
#M  Characteristic( <A> )
#M  Characteristic( <algelm> )
#M  Characteristic( <algelmfam> )
##
##  (via delegations)
##
InstallMethod( Characteristic, "for an elements family of an fp subalgebra",
  [ IsElementOfFpAlgebraFamily ],
  function( fam )
    local A,n,one,x;
    A := fam!.wholeAlgebra;
    if IsAlgebraWithOne(A) then
        one := One(A);
        if Zero(A) = one then return 1; fi;
    else
        if Dimension(A) = 0 then return 1; fi;
    fi;
    if IsField(LeftActingDomain(A)) then
        return Characteristic(LeftActingDomain(A));
    else
        if not IsAlgebraWithOne(A) then return fail; fi;
        # This might be horribly slow and might not terminate if the
        # characteristic is 0:
        n := 2;
        x := one+one;
        while not(IsZero(x)) do
            x := x + one;
            n := n + 1;
        od;
        return n;
    fi;
  end );


#############################################################################
##
#M  FreeGeneratorsOfFpAlgebra( <A> )
##
InstallMethod( FreeGeneratorsOfFpAlgebra,
    "for a full f.p. algebra",
    true,
    [ IsSubalgebraFpAlgebra and IsFullFpAlgebra ], 0,
    function( A )
    A:= ElementsFamily( FamilyObj( A ) )!.freeAlgebra;
    if IsMagmaWithOne( A ) then
      return GeneratorsOfAlgebraWithOne( A );
    else
      return GeneratorsOfAlgebra( A );
    fi;
    end );


############################################################################
##
#M  RelatorsOfFpAlgebra( <A> )
##
InstallMethod( RelatorsOfFpAlgebra,
    "for a full f.p. algebra",
    true,
    [ IsSubalgebraFpAlgebra and IsFullFpAlgebra ], 0,
    A -> ElementsFamily( FamilyObj( A ) )!.relators );


#############################################################################
##
#A  FreeAlgebraOfFpAlgebra( <A> )
##
InstallMethod( FreeAlgebraOfFpAlgebra,
    "for a full f.p. algebra",
    true,
    [ IsSubalgebraFpAlgebra and IsFullFpAlgebra ], 0,
    A -> ElementsFamily( FamilyObj( A ) )!.freeAlgebra );


#############################################################################
##
#M  IsFullFpAlgebra( <A> )
##
InstallOtherMethod( IsFullFpAlgebra,
    "for f. p. algebra",
    true,
    [ IsAlgebra and IsSubalgebraFpAlgebra ], 0,
    function( A )
    local Fam;
    Fam:= ElementsFamily( FamilyObj( A ) );
    return IsSubset( A, List( GeneratorsOfAlgebra( Fam!.freeAlgebra ),
                              a -> ElementOfFpAlgebra( Fam, a ) ) );
    end );


#############################################################################
##
#M  NaturalHomomorphismByIdeal( <F>, <I> )  . . . . . for free alg. and ideal
##
##  The algebra <F> can be also a free magma ring.
##  If it is finite dimensional then we prefer not to regard it as a
##  f.p. algebra (modulo relations);
##  there is a method for  but to work with bases of <A> and <I>.
##
InstallMethod( NaturalHomomorphismByIdeal,
    "for free algebra and ideal",
    IsIdenticalObj,
    [ IsMagmaRingModuloRelations, IsFLMLOR ],
    function( F, I )

    local image, hom;

    if IsInt( Dimension( F ) ) then
      TryNextMethod();
    fi;
    image:= FactorFreeAlgebraByRelators( F, GeneratorsOfIdeal( I ) );

    if IsMagmaWithOne( F ) then
      hom:= AlgebraWithOneHomomorphismByImagesNC( F, image,
                GeneratorsOfAlgebraWithOne( F ),
                GeneratorsOfAlgebraWithOne( image ) );
    else
      hom:= AlgebraHomomorphismByImagesNC( F, image,
                GeneratorsOfAlgebra( F ),
                GeneratorsOfAlgebra( image ) );
    fi;

    SetIsSurjective( hom, true );

    return hom;
    end );


#############################################################################
##
#M  Print(<fp alg elm>)
##
InstallMethod(PrintObj,
    "fp algebra elements",
    true,
    [ IsElementOfFpAlgebra and IsPackedElementDefaultRep ], 0,
    function( e )
    Print( "[", e![1], "]" );
    end );


#############################################################################
##
#M  \+( <fp alg elm>, <fp alg elm> )
##
InstallMethod( \+,
    "fp algebra elements",
    IsIdenticalObj,
    [ IsElementOfFpAlgebra and IsPackedElementDefaultRep,
      IsElementOfFpAlgebra and IsPackedElementDefaultRep ], 0,
    function( a, b )
    return ElementOfFpAlgebra( FamilyObj( a ), a![1] + b![1] );
    end );


#############################################################################
##
#M  \-( <fp alg elm>, <fp alg elm> )
##
InstallMethod( \-,
    "fp algebra elements",
    IsIdenticalObj,
    [ IsElementOfFpAlgebra and IsPackedElementDefaultRep,
      IsElementOfFpAlgebra and IsPackedElementDefaultRep ], 0,
    function( a, b )
    return ElementOfFpAlgebra( FamilyObj( a ), a![1] - b![1] );
    end );


#############################################################################
##
#M  AdditiveInverseOp( <fp alg elm> )
##
InstallMethod( AdditiveInverseOp,
    "fp algebra element",
    true,
    [ IsElementOfFpAlgebra and IsPackedElementDefaultRep ], 0,
    function( a )
    return ElementOfFpAlgebra( FamilyObj( a ), AdditiveInverse( a![1] ) );
    end );


#############################################################################
##
#M  OneOp( <fp alg elm> )
##
InstallOtherMethod( OneOp,
    "for an f.p. algebra element",
    true,
    [ IsElementOfFpAlgebra and IsPackedElementDefaultRep ], 0,
    function( elm )
    local one;
    one:= One( elm![1] );
    if one <> fail then
      one:= ElementOfFpAlgebra( FamilyObj( elm ), one );
    fi;
    return one;
    end );


#############################################################################
##
#M  ZeroOp( <fp alg elm>)
##
InstallMethod( ZeroOp,
    "for an f.p. algebra element",
    true,
    [ IsElementOfFpAlgebra and IsPackedElementDefaultRep ], 0,
    elm -> ElementOfFpAlgebra( FamilyObj( elm ), Zero( elm![1] ) ) );


#############################################################################
##
#M  \*( <fp alg elm>, <fp alg elm> )
##
InstallMethod( \*,
    "fp algebra elements",
    IsIdenticalObj,
    [ IsElementOfFpAlgebra and IsPackedElementDefaultRep,
      IsElementOfFpAlgebra and IsPackedElementDefaultRep ], 0,
    function( a, b )
    return ElementOfFpAlgebra( FamilyObj( a ), a![1] * b![1] );
    end);


#############################################################################
##
#M  \*( <ring el>, <fp alg elm> )
##
InstallMethod( \*,"ring el *fp algebra el",IsRingsMagmaRings,
    [ IsRingElement, IsElementOfFpAlgebra and IsPackedElementDefaultRep ], 0,
    function( a, b )
    return ElementOfFpAlgebra( FamilyObj( b ), a * b![1] );
    end);


#############################################################################
##
#M  \*( <fp alg elm>, <ring el> )
##
InstallMethod( \*,"fp algebra el*ring el",IsMagmaRingsRings,
    [ IsElementOfFpAlgebra and IsPackedElementDefaultRep, IsRingElement ], 0,
    function( a, b )
    return ElementOfFpAlgebra( FamilyObj( a ), a![1] * b );
    end);

#AH  Embedding can only be defined reasonably if a `One' different from
#AH  the zero is present
#AH  (The factor may collapse).
#T The `One' of the factor may be equal to the `Zero',
#T so the ``embedding'' can be defined as a mapping from the ring
#T to the algebra,
#T but it is injective only if the `One' is not the `Zero'.


#############################################################################
##
#M  IsomorphismMatrixFLMLOR( <A> )  . . . . . . . . . . . . for a f.p. FLMLOR
##
InstallMethod( IsomorphismMatrixFLMLOR,
    "for a f.p. FLMLOR",
    true,
    [ IsFLMLOR and IsSubalgebraFpAlgebra ], 0,
    A -> Error( "sorry, no method to compute a matrix algebra\n",
                "for a (not nec. associative) f.p. algebra" ) );


#############################################################################
##
#M  IsomorphismMatrixFLMLOR( <A> )  . . . . . . for a full f.p. assoc. FLMLOR
##
##  We compute the operation homomorphism for <A> acting on itself from the
##  right.
##
InstallMethod( IsomorphismMatrixFLMLOR,
    "for a full f.p. associative FLMLOR",
    true,
    [ IsFLMLORWithOne and IsSubalgebraFpAlgebra and IsAssociative
      and IsFullFpAlgebra ], 0,
    A  -> OperationAlgebraHomomorphism( A, [ [ Zero( A ) ] ], OnRight ) );
#T change this: second argument should be the <A>-module itself!


#############################################################################
##
#M  OperationAlgebraHomomorphism( <A>, <C>, <opr> )
##
InstallOtherMethod( OperationAlgebraHomomorphism,
    "for a full f.p. associative FLMLOR, a collection, and a function",
    true,
    [ IsFLMLORWithOne and IsSubalgebraFpAlgebra and IsAssociative
      and IsFullFpAlgebra, IsCollection, IsFunction ], 0,
    function( A, C, opr )
    Error( "this case will eventually be handled by the Vector Enumerator\n",
           "which is not available yet" );
    end );


#############################################################################
##
#M  NiceAlgebraMonomorphism( <A> )  . . . . . . for a full f.p. assoc. FLMLOR
##
##  We delegate to `IsomorphismMatrixFLMLOR'.
##
InstallMethod( NiceAlgebraMonomorphism,
    "for a full f.p. associative FLMLOR (call `IsomorphismMatrixFLMLOR')",
    true,
    [ IsFLMLORWithOne and IsSubalgebraFpAlgebra and IsAssociative
      and IsFullFpAlgebra ], 0,
    IsomorphismMatrixFLMLOR );


#############################################################################
##
#M  IsFiniteDimensional( <A> )
#M  Dimension( <A> )
##
#M  NiceVector( <A>, <a> )
#M  UglyVector( <A>, <r> )
##
##  Provided the f.~p. algebra <A> knows its `NiceAlgebraMonomorphism' value,
##  it is handled via nice bases.
##  So we have to treat the case that this value is not (yet) known.
##  Note that `Dimension' may ask whether <A> is finite dimensional,
##  so we must provide a (partial) method for it.
##
##  The family of elements of <A> stores its whole algebra,
##  so it is reasonable to look whether this algebra knows already a
##  nice monomorphism.
##
InstallMethod( IsFiniteDimensional,
    "for f.p. algebra",
    true,
    [ IsSubalgebraFpAlgebra ], 0,
    function( A )
    local iso;
    if HasNiceAlgebraMonomorphism(
           ElementsFamily( FamilyObj( A ) )!.wholeAlgebra ) then
      iso:= NiceAlgebraMonomorphism(
                ElementsFamily( FamilyObj( A ) )!.wholeAlgebra );
    else
      iso:= IsomorphismMatrixFLMLOR( A );
    fi;
    if iso <> fail then
      if IsAlgebraHomomorphismFromFpRep( iso ) then
        SetNiceAlgebraMonomorphism( A, iso );
      fi;
      return true;
    fi;
    TryNextMethod();
    end );


#############################################################################
##
#M  NiceFreeLeftModuleInfo( <V> )
#M  NiceVector( <V>, <v> )
#M  UglyVector( <V>, <r> )
##
InstallHandlingByNiceBasis( "IsFpAlgebraElementsSpace", rec(
    detect := function( F, gens, V, zero )
      return IsElementOfFpAlgebraCollection( V ) and IsFreeLeftModule( V );
      end,

    NiceFreeLeftModuleInfo := ReturnTrue,

    NiceVector := function( A, a )
      local hom;
      hom:= NiceAlgebraMonomorphism( FamilyObj( a )!.wholeAlgebra );
      if hom = fail then
        TryNextMethod();
      fi;
      return ImagesRepresentative( hom, a );
      end,

    UglyVector := function( A, r )
      local hom;
      hom:= NiceAlgebraMonomorphism(
                ElementsFamily( FamilyObj( A ) )!.wholeAlgebra );
      if hom = fail then
        TryNextMethod();
      fi;
      return PreImagesRepresentative( hom, r );
      end ) );


#############################################################################
##
#F  FpAlgebraByGeneralizedCartanMatrix( <F>, <A> )
##
InstallGlobalFunction( FpAlgebraByGeneralizedCartanMatrix, function( F, A )

    local n,            # dimension of the matrix `A'
          i, j, k,      # loop variables
          gensstrings,  # names of algebra generators
          a,            # algebra, result
          gens,         # algebra generators
          e, h, f,      # different portions of generators
          LieBracket,   # function that computes the commutator
          rels,         # list of relators
          rel;          # one relator

    if not IsField( F ) then
      Error( "<F> must be a field" );
    elif not IsGeneralizedCartanMatrix( A ) then
      Error( "<A> must be a generalized Cartan matrix" );
    fi;

    n:= Length( A );
    gensstrings:= [];
    for i in [ 1 .. n ] do
      gensstrings[       i ]:= Concatenation( "e", String(i) );
    od;
    for i in [ 1 .. n ] do
      gensstrings[   n + i ]:= Concatenation( "h", String(i) );
    od;
    for i in [ 1 .. n ] do
      gensstrings[ 2*n + i ]:= Concatenation( "f", String(i) );
    od;
    a:= FreeAssociativeAlgebraWithOne( F, gensstrings );
    gens:= GeneratorsOfAlgebraWithOne( a );
    e:= gens{ [       1 ..   n ] };
    h:= gens{ [   n + 1 .. 2*n ] };
    f:= gens{ [ 2*n + 1 .. 3*n ] };

    LieBracket:= function( A, B )
      return A*B - B*A;
    end;

    rels:= [];
    for i in [ 1 .. n ] do
      for j in [ i+1 .. n ] do
        Add( rels, LieBracket( h[i], h[j] ) );
      od;
    od;

    for i in [ 1 .. n ] do
      for j in [ 1 .. n ] do
        if i = j then
          Add( rels, LieBracket( e[i], f[i] ) - h[i] );
        else
          Add( rels, LieBracket( e[i], f[j] ) );
        fi;
      od;
    od;

    for i in [ 1 .. n ] do
      for j in [ 1 .. n ] do
        Add( rels, LieBracket( h[i], e[j] ) - A[i][j] * e[j] );
        Add( rels, LieBracket( h[i], f[j] ) + A[i][j] * f[j] );
      od;
    od;

    for i in [ 1 .. n ] do
      for j in [ i+1 .. n ] do
        if A[i][j] = 0 then
          Add( rels, LieBracket( e[i], e[j] ) );
          Add( rels, LieBracket( f[i], f[j] ) );
        fi;
      od;
    od;

    for i in [ 1 .. n ] do
      for j in [ 1 .. n ] do
        if i <> j then
          rel:= e[j];
          for k in [ 1 .. 1 - A[i][j] ] do
            rel:= LieBracket( e[i], rel );
          od;
          Add( rels, rel );
          rel:= f[j];
          for k in [ 1 .. 1 - A[i][j] ] do
            rel:= LieBracket( f[i], rel );
          od;
          Add( rels, rel );
        fi;
      od;
    od;

    # Return the algebra.
    return a / rels;
end );
