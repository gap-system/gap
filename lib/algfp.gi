#############################################################################
##
#W  algfp.gi                   GAP library                   Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the methods for finitely presented algebras.
##  So far, there are not many.
##
Revision.algfp_gi :=
    "@(#)$Id$";


#############################################################################
##
#R  IsPackedAlgebraElmDefaultRep
##
IsPackedAlgebraElmDefaultRep := NewRepresentation(
    "IsPackedAlgebraElmDefaultRep",
    IsPositionalObjectRep and IsRingElement, [ 1 ] );


#############################################################################
##
#M  ElementOfFpAlgebra( <Fam>, <elm> )  . . . .  for family of f.p. alg.elms.
##
InstallMethod(ElementOfFpAlgebra,
    "for family of fp. alg. elements and ring element",
    true,
    [ IsFamilyOfFpAlgebraElements, IsRingElement ], 0,
    function( fam, elm )
    return Objectify( fam!.defaultType, [ Immutable( elm ) ] );
    end );


#############################################################################
##
#M  ElementOfFpAlgebra( <Fam>, <elm> )  . .  for family with nice normal form
##
InstallMethod( ElementOfFpAlgebra,
    "method for fp. alg. elms. family with normal form, and ring element",
    true,
    [ IsFamilyOfFpAlgebraElements and HasNiceNormalFormByExtRepFunction,
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
    "method for f.p. algebra element",
    true,
    [ IsElementOfFpAlgebra and IsPackedAlgebraElmDefaultRep ], 0,
    elm -> ExtRepOfObj( elm![1] ) );


#############################################################################
##
#M  ObjByExtRep( <Fam>, <descr> ) . for f.p. alg. elms. fam. with normal form
##
InstallMethod( ObjByExtRep,
    "method for family of f.p. algebra elements with normal form",
    true,
    [ IsFamilyOfFpAlgebraElements and HasNiceNormalFormByExtRepFunction,
      IsList ], 0,
    function( Fam, descr )
    return NiceNormalFormByExtRepFunction( Fam )( Fam, descr );
    end );


############################################################################
##
#M  MappedExpression( <expr>, <gens1>, <gens2> )
##
InstallMethod( MappedExpression,
    "method for element of f.p. algebra, and two lists of generators",
    IsElmsCollsX,
    [ IsElementOfFpAlgebra, IsHomogeneousList, IsHomogeneousList ], 0,
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

    # Get the numbers of generators.
    gens1:= List( gens1, x -> ExtRepOfObj( x )[2] );
    for i in [ 1 .. Length( gens1 ) ] do
      gen:= gens1[i];
      if Length( gen ) = 2 and gen[2] = 1 then
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


#############################################################################
##
#M  \=( <x>, <y> )  . . . . . . . .  for two normalized f.p. algebra elements
##
InstallMethod( \=,
    "method for two normalized f.p. algebra elements",
    IsIdentical,
    [ IsElementOfFpAlgebra and IsNormalForm,
      IsElementOfFpAlgebra and IsNormalForm ], 0,
    function( x, y )
    return ExtRepOfObj( x ) = ExtRepOfObj( y );
    end );

#T missing: \= method to look for normal form in the family


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
    "method for two normalized f.p. algebra elements",
    IsIdentical,
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
#M  FactorFreeAlgebraByRelators( <F>, <rels> )  . . .  factor of free algebra
##
FactorFreeAlgebraByRelators := function( F, rels )
    local A, fam;

    # Create a new family.
    fam := NewFamily( "FamilyElementsFpAlgebra", IsElementOfFpAlgebra );

    # Create the default type for the elements.
    fam!.defaultType := NewType( fam, IsPackedAlgebraElmDefaultRep );

    fam!.freeAlgebra := F;
    fam!.relators := Immutable( rels );
    fam!.familyRing := FamilyObj(LeftActingDomain(F));

    # Create the algebra.
    if IsAlgebraWithOne( F ) then
#T Do we want to support free algebras without one?

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
    UseFactorRelation(F,rels,A);

    return A;
end;


#############################################################################
##
#M  \/( <F>, <rels> )  . . . . . . . for free algebra and list of relators
##
InstallOtherMethod( \/,
    "method for free algebra and relators",
    IsIdentical,
    [ IsFreeMagmaRing, IsCollection ], 0,
    FactorFreeAlgebraByRelators );

InstallOtherMethod( \/,
    "method for free algebra and empty list",
    IsIdentical,
    [ IsFreeMagmaRing, IsEmpty ], 0,
    FactorFreeAlgebraByRelators );


#############################################################################
##
#M  Print(<fp alg elm>)
##
InstallMethod(PrintObj,"fp algebra elements",true,
  [IsPackedAlgebraElmDefaultRep],0,
function(e)
  Print("[",e![1],"]");
end);


#############################################################################
##
#M  \+(<fp alg elm>,<fp alg elm>)
##
InstallMethod(\+,"fp algebra elements",IsIdentical,
  [IsPackedAlgebraElmDefaultRep,IsPackedAlgebraElmDefaultRep],0,
function(a,b)
  return ElementOfFpAlgebra(FamilyObj(a),a![1]+b![1]);
end);

#############################################################################
##
#M  \-(<fp alg elm>,<fp alg elm>)
##
InstallMethod(\-,"fp algebra elements",IsIdentical,
  [IsPackedAlgebraElmDefaultRep,IsPackedAlgebraElmDefaultRep],0,
function(a,b)
  return ElementOfFpAlgebra(FamilyObj(a),a![1]-b![1]);
end);

#############################################################################
##
#M  AdditiveInverse(<fp alg elm>)
##
InstallMethod(AdditiveInverse,"fp algebra elements",true,
  [IsPackedAlgebraElmDefaultRep],0,
function(a)
  return ElementOfFpAlgebra(FamilyObj(a),AdditiveInverse(a![1]));
end);


#############################################################################
##
#M  One( <fp alg elm> )
##
InstallOtherMethod( One,
    "method for an f.p. algebra element",
    true,
    [ IsElementOfFpAlgebra and IsPackedAlgebraElmDefaultRep ], 0,
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
#M  Zero( <fp alg elm>)
##
InstallMethod( Zero,
    "method for an f.p. algebra element",
    true,
    [ IsElementOfFpAlgebra and IsPackedAlgebraElmDefaultRep ], 0,
    elm -> ElementOfFpAlgebra( FamilyObj( elm ), Zero( elm![1] ) ) );


#############################################################################
##
#M  \*(<fp alg elm>,<fp alg elm>)
##
InstallMethod(\*,"fp algebra elements",IsIdentical,
  [IsPackedAlgebraElmDefaultRep,IsPackedAlgebraElmDefaultRep],0,
function(a,b)
  return ElementOfFpAlgebra(FamilyObj(a),a![1]*b![1]);
end);

#############################################################################
##
#M  \*(<ring el>,<fp alg elm>)
##
InstallMethod(\*,"ring el *fp algebra el",IsRingsMagmaRings,
  [IsRingElement,IsPackedAlgebraElmDefaultRep],0,
function(a,b)
  return ElementOfFpAlgebra(FamilyObj(b),a*b![1]);
end);

#############################################################################
##
#M  \*(<fp alg elm>,<ring el>)
##
InstallMethod(\*,"fp algebra el*ring el",IsMagmaRingsRings,
  [IsPackedAlgebraElmDefaultRep,IsRingElement],0,
function(a,b)
  return ElementOfFpAlgebra(FamilyObj(a),a![1]*b);
end);

#AH  Embedding can only be defined reasonably if a 'One' different from
#AH  the zero is present
#AH  (The factor may collaps).


#############################################################################
##
#M  PrepareNiceFreeLeftModule( <A> )
##
##  We set the left module generators.
##
InstallMethod( PrepareNiceFreeLeftModule,
    "method for f.p. algebra with known basis info",
    true,
    [ IsSubalgebraFpAlgebra and IsHandledByNiceBasis
                            and HasBasisInfoFpAlgebra ], 0,
    function( A )
    SetGeneratorsOfLeftModule( A, BasisInfoFpAlgebra( A ).basiselms );
    end );


#############################################################################
##
#M  NiceFreeLeftModule( <A> )
##
##  We avoid to map the module generators, then to form the module,
##  and then to compute a basis for it.
##
InstallMethod( NiceFreeLeftModule,
    "method for a f.p. algebra with known basis info",
    true,
    [ IsSubalgebraFpAlgebra and IsHandledByNiceBasis
                            and HasBasisInfoFpAlgebra ], 0,
    A -> UnderlyingLeftModule( BasisInfoFpAlgebra( A ).basisimages ) );


#############################################################################
##
#M  NiceVector( <A>, <a> )
##
InstallMethod( NiceVector,
    "method for f.p. algebra with known basis info, and a ring element",
    IsCollsElms,
    [ IsSubalgebraFpAlgebra and IsHandledByNiceBasis
                            and HasBasisInfoFpAlgebra,
      IsRingElement ], 0,
    function( A, a )
    local info;
    info:= BasisInfoFpAlgebra( A );
    return MappedExpression( a, info.generators, info.genimages );
    end );
    

#############################################################################
##
#M  UglyVector( <A>, <r> )
##
InstallMethod( UglyVector,
    "method for f.p. algebra with known basis info, and a ring element",
    true,
    [ IsSubalgebraFpAlgebra and IsHandledByNiceBasis
                            and HasBasisInfoFpAlgebra,
      IsRingElement ], 0,
    function( A, r )
    local info;
    info:= BasisInfoFpAlgebra( A );
    r:= Coefficients( info.basisimages, r );
    if r <> fail then
      r:= LinearCombination( info.basiselms, r );
    fi;
    return r;
    end );


#############################################################################
##
#M  IsGeneralizedCartanMatrix( <A> )
##
InstallMethod( IsGeneralizedCartanMatrix,
    "method for a matrix",
    true,
    [ IsMatrix ], 0,
    function( A )

    local n, i, j;

    if Length( A ) <> Length( A[1] ) then
      Error( "<A> must be a square matrix" );
    fi;

    n:= Length( A );
    for i in [ 1 .. n ] do
      if A[i][i] <> 2 then
        return false;
      fi;
    od;
    for i in [ 1 .. n ] do
      for j in [ i+1 .. n ] do
        if not IsInt( A[i][j] ) or not IsInt( A[j][i] )
           or 0 < A[i][j] or 0 < A[j][i] then
          return false;
        elif  ( A[i][j] = 0 and A[j][i] <> 0 )
           or ( A[j][i] = 0 and A[i][j] <> 0 ) then
          return false;
        fi;
      od;
    od;
    return true;
    end );


#############################################################################
##
#F  FpAlgebraByGeneralizedCartanMatrix( <F>, <A> )
##
FpAlgebraByGeneralizedCartanMatrix := function( F, A )

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
    a:= FreeAssociativeAlgebra( F, gensstrings );
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
end;


#############################################################################
##
#E  algfp.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##

