#############################################################################
##
#W  compat3a.g                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the non-destructive part of the {\GAP} 3 compatibility
##  mode,
##  where non-destructive means that no functionality of {\GAP} 4 is lost
##  when this file is read.
##  The file consists of the following parts.
##
##  - For functions whose names have changed,
##    the old names are made available.
##  - Methods and functions are added to allow functionality
##    that is not really intended for {\GAP} 4.
##
##  This file is *not* read as part of the {\GAP} 4 library.
##
Revision.compat3a_g :=
    "@(#)$Id$";


#############################################################################
##
##  1. For functions whose names have changed,
##     the old names are made available.
##


#############################################################################
##
#V  AbstractGeneratorIterator
#F  AbstractGenerator( <name> )
##
AbstractGeneratorIterator := 0;

AbstractGenerator := function( name )
    if AbstractGeneratorIterator = 0 then
      AbstractGeneratorIterator:= Iterator( GeneratorsOfGroup(
                                                FreeGroup( infinity ) ) );
    fi;
    return NextIterator( AbstractGeneratorIterator );
end;

#T what about the name of the generator?
## this would be tediously hard to fix -- would have to alter the
## "infinite list of names" to allow a finite list of overrides
## if this was done, it would be worth doing in general -- build a
##  construct for a (finitely) mutable infinite list 


#############################################################################
##
#F  ApplyFunc( <func>, <args> ) . . . . . . . . . . . result of function call
##
ApplyFunc := CallFuncList;


#############################################################################
##
#F  Base( <G> ) . . . . . . . . . . . result of function call
##
Base := BaseOfGroup;

#############################################################################
##
#F  CartesianProduct( <D>,... ) . . . . . .  cartesian product of collections
##
CartesianProduct := function ( arg )
    local   i;

    # unravel the arguments
    if Length(arg) = 1  and IsList( arg[1] )  then
        arg := ShallowCopy( arg[1] );
    fi;

    # make all domains into sets
    for i  in [1..Length(arg)]  do
        arg[i] := AsListSorted( arg[i] );
    od;

    # make the cartesian product
    return Cartesian( arg );
end;


#############################################################################
##
#F  CharDegAgGroup( <G> ) . . . . . . . . . . . . . . . . . character degrees
##
CharDegAgGroup := CharacterDegrees;


#############################################################################
##
#F  CharFFE( <ffe> )  . . . . . . . . . . . . . . . . . characteristic of FFE
##
CharFFE := Characteristic;


#############################################################################
##
#F  CharTable( <G> )
#F  CharTableHead( <G> )
#F  CharTableRegular( <tbl>, <p> )
#F  CharTableDirectProduct( <tbl1>, <tbl2> )
#F  CharTableFactorGroup( <tbl>, <classes> )
#F  CharTableNormalSubgroup( <tbl>, <classes> )
#F  CharTableIsoclinic( <tbl>, <classes> )
#F  CharTableQuaternionic( <4n> )
##
CharTable := CharacterTable;
CharTableHead := CharacterTable;
CharTableRegular := CharacterTableRegular;
CharTableDirectProduct := CharacterTableDirectProduct;
CharTableFactorGroup := CharacterTableFactorGroup;
CharTableNormalSubgroup := CharacterTableOfNormalSubgroup;
CharTableIsoclinic := CharacterTableIsoclinic;
CharTableQuaternionic := CharacterTableQuaternionic;


#############################################################################
##
#F  CharTablePGroup( <G> )
#F  CharTableSSGroup( <G> )
##
##  In {\GAP}~4, the different methods to compute the irreducible characters
##  of a group are not installed for the computation of the whole character
##  table but of its attribute `Irr'.
##
##  So the commands `CharTablePGroup' and `CharTableSSGroup' do not
##  make sense anymore.
##  One can use `IrrBaumClausen' to cmopute the irreducible characters via
##  the algorithm of Baum and Clausen, which is a non-recursive form of the
##  algorithm used by `CharTablePGroup' in {GAP}~3.
##  The calculation of irreducible characters via the algorithm that was
##  used by `CharTableSSGroup' is available in {\GAP}~4 as `IrrConlon'.
##
CharTablePGroup := function( G )
    Error( "this function is not supported in GAP 4.\n",
           "Use `IrrBaumClausen' if you want to compute the irreducible\n",
           "characters of <G> by an algorithm similar to the one\n",
           "that was used by `CharTablePGroup' in GAP 3," );
end;

CharTableSSGroup := function( G )
    Error( "this function is not supported in GAP 4.\n",
           "Use `IrrConlon' if you want to compute the irreducible\n",
           "characters of <G> by the algorithm that was used by\n",
           "`CharTableSSGroup' in GAP 3," );
end;


#############################################################################
##
#F  Character( <tbl>, <values> )
#F  ClassFunction( <tbl>, <values> )
##
Character := CharacterByValues;
ClassFunction := ClassFunctionByValues;


#############################################################################
##
#F  CharPol( <F>, <z> ) . . . .  coeffs. of char. polynomial of a field elm.
#F  CharPol( <z> )
##
DeclareOperation( "CharPol", [ IsField, IsScalar ] );

InstallOtherMethod( CharPol,
    "for a scalar",
    true,
    [ IsScalar ], 0,
    z -> CharPol( DefaultField( z ), z ) );

InstallMethod( CharPol,
    "for a field, and a scalar",
    IsCollsElms,
    [ IsField, IsScalar ], 0,
    function( F, z )

    local   pol,        # characteristic polynom of <z> in <F>, result
            deg,        # degree of <pol>
            con,        # conjugate of <z> in <F>
            i;          # loop variable

    # compute the trace simply by multiplying $x-cnj$
    pol := [ One( F ) ];
    deg := 0;
    for con  in Conjugates( F, z )  do
        pol[deg+2] := pol[deg+1];
        for i  in Reversed([2..deg+1])  do
            pol[i] := pol[i-1] -  con * pol[i];
        od;
        pol[1] := Zero( F ) - con * pol[1];
        deg := deg + 1;
    od;

    # return the coefficients list of the characteristic polynomial
    return pol;
    end );


#############################################################################
##
#F  ClassMultCoeffCharTable( <tbl>, <i>, <j>, <k> )
##
ClassMultCoeffCharTable := ClassMultiplicationCoefficient;


#############################################################################
##
#F  ClassNamesCharTable( <tbl> )
##
ClassNamesCharTable := ClassNames;


#############################################################################
##
#F  Closure( <G>, <g> )
#F  Closure( <G>, <U> )
##
##  Handle the different closures for groups, modules, algebras,
##  and vector spaces.
##
Closure := function( D, E )
    if   IsAlgebra( D ) then
        return ClosureAlgebra( D, E );
    elif IsGroup( D ) then
        return ClosureGroup( D, E );
    elif IsVectorSpace( D ) then
        return ClosureLeftModule( D, E );
    fi;
end;


#############################################################################
##
#F  ConsiderSmallerPowermaps( ... )
##
ConsiderSmallerPowermaps := ConsiderSmallerPowerMaps;


#############################################################################
##
#F  COEFFSCYC( <cyc> )
##
COEFFSCYC := COEFFS_CYC;


#############################################################################
##
#F  Denominator( <rat> )
##
Denominator := DenominatorRat;


#############################################################################
##
#F  DepthVector( <vec> )
##
DepthVector := vec -> PositionNot( vec, Zero( vec[1] ) );


#############################################################################
##
#F  DisplayCharTable( <tbl> )
#F  DisplayCharTable( <tbl>, <options> )
##
DisplayCharTable := Display;


#############################################################################
##
#F  ElementOrdersPowermap( <powermap> )
##
ElementOrdersPowermap := ElementOrdersPowerMap;


#############################################################################
##
#F  Elements( <D> )
##
Elements := AsListSorted;


#############################################################################
##
#F  Equivalenceclasses( <list>, <function> )  . calculate equivalence classes
##
#T who invented this name? (fortunately, there is no help section)
#T (used only in 'agclass.g', with second argument 'IsIdenticalObj')
##
##  returns
##
##      rec(
##          classes := <list>,
##          indices := <list>
##      )
##
Equivalenceclasses := function( list, isequal )

    local ecl, idx, len, new, i, j;

    len := 0;
    ecl := [];
    idx := [];
    for i in [1..Length( list )] do
        new := true;
        j   := 1;
        while new and j <= len do
            if isequal( list[i], ecl[j][1] ) then
                Add( ecl[j], list[i] );
                Add( idx[j], i );
                new := false;
            fi;
            j := j + 1;
        od;
        if new then
            len := len + 1;
            ecl[len] := [ list[i] ];
            idx[len] := [ i ];
        fi;
    od;
    return rec( classes := ecl, indices := idx );
end;


#############################################################################
##
#F  InducedActionSpaceMats( <basis>, <mats> )
##
InducedActionSpaceMats := function( basis, mats )
    return List( mats, m -> InducedLinearAction( basis, m, OnRight ) );
end;


#############################################################################
##
#F  InitClassesCharTable( <tbl> )  . . initialize classes of character tables
##
InitClassesCharTable := function( tbl )
    local initclasses;
  # if not IsInt( tbl.centralizers[1] ) then return; fi; # generic tables
    initclasses:= SizesConjugacyClasses( tbl );
    if not ForAll( initclasses, IsInt ) then
      Print( "#E InitClassesCharTable: not all centralizer orders divide",
             " the group order\n" );
    fi;
    return initclasses;
end;


#############################################################################
##
#F  IntCyc( <cyc> )
##
IntCyc := Int;


#############################################################################
##
#F  InverseClassesCharTable( <tbl> )
##
InverseClassesCharTable := InverseClasses;


#############################################################################
##
#F  InverseMapping( <map> )
##
InverseMapping := Inverse;


#############################################################################
##
#F  IsBijection( <map> )
##
IsBijection := IsBijective;


#############################################################################
##
#F  IsCharTable( <tbl> )
#F  IsCharTableHead( <tbl> )
##
IsCharTable := IsNearlyCharacterTable;
IsCharTableHead := IsNearlyCharacterTable;


#############################################################################
##
#F  IsCommutativeRing( <R> )
##
IsCommutativeRing := IsCommutative and IsRing;


#############################################################################
##
#F  IsFiniteField( <obj> )  . . .  test if an object is a finite field record
##
IsFiniteField := function ( obj )
    return ( IsField( obj ) and IsFinite( obj ) )
           or ( IsRecord( obj )
       and IsBound( obj.isField  )  and obj.isField
       and IsBound( obj.isFinite )  and obj.isFinite );
end;


#############################################################################
##
#F  IsFiniteFieldElement( <obj> )
##
IsFiniteFieldElement := function ( obj )
    return IsFFE( obj )
           or ( IsRecord( obj ) and IsBound( obj.isFiniteFieldElement )
                             and obj.isFiniteFieldElement );
end;


#############################################################################
##
#F  IsFunc( <obj> )
##
IsFunc := IsFunction;


#############################################################################
##
#F  IsMat( <obj> )
##
IsMat := IsMatrix;


#############################################################################
##
#F  IsRec( <obj> )
##
IsRec := IsRecord;


#############################################################################
##
#F  IsSet( <obj> )
##
IsSet := IsSSortedList;


#############################################################################
##
#M  LengthWord( <word> )
##
LengthWord := Length;


#############################################################################
##
#M  ListOp( <obj> ) . . . . . . . . . . . . . . . . . . . . convert to a list
#M  ListOp( <perm> )  . . . . . . . . . . . . . . . . . . . convert to a list
##
##  In this version, <obj> may be a list, or a permutation, or any
##  object for that a method for `ListOp' is installed.
##
##  (Note the different behaviour in {\GAP-3} if the argument is a string;
##  but fortunately this was never documented.)
##
InstallOtherMethod( ListOp,
    "method for a list (compatibility mode)",
    true,
    [ IsList ], 0,
    IdFunc );

InstallOtherMethod( ListOp,
    "method for a permutation (compatibility mode)",
    true,
    [ IsPerm ], 0,
    ListPerm );


#############################################################################
##
#F  MatRepresenatationsPGroup( <G> )  . irred. repr. of a supersolvable group
##
MatRepresentationsPGroup := function( G )
    G:= IrreducibleRepresentations( G );
    if not IsTrivial( G.kernel ) then
      Print( "#W  RepresentationsPGroup:not all representations known\n" );
    fi;
    return G.representations;
end;


#############################################################################
##
#F  MinPol( <F>, <z> )  . . . . coeffs. of min. polynomial of a field element
#F  MinPol( <z> )
##
DeclareOperation( "MinPol", [ IsField, IsScalar ] );

InstallOtherMethod( MinPol,
    "for a scalar",
    true,
    [ IsScalar ], 0,
    z -> MinPol( DefaultField( z ), z ) );

InstallMethod( MinPol,
    "for a field, and a scalar",
    IsCollsElms,
    [ IsField, IsScalar ], 0,
    function( F, z )

    local   pol,        # minimal polynom of <z> in <F>, result
            deg,        # degree of <pol>
            con,        # conjugate of <z> in <F>
            i;          # loop variable

    # compute the trace simply by multiplying $x-cnj$
    pol := [ One( F ) ];
    deg := 0;
    for con  in ListSorted( Conjugates( F, z ) )  do
        pol[deg+2] := pol[deg+1];
        for i  in Reversed([2..deg+1])  do
            pol[i] := pol[i-1] -  con * pol[i];
        od;
        pol[1] := Zero( F ) - con * pol[1];
        deg := deg + 1;
    od;

    # return the coefficients list of the minimal polynomial
    return pol;
    end );


#############################################################################
##
#F  Mod( <R>, <r>, <s> )
##
##  (was already obsolete in {\GAP}-3)
##
Mod := EuclideanRemainder;


#############################################################################
##
#F  NofCyc( <cyc> )
##
NofCyc := Conductor;


#############################################################################
##
#F  NumberConjugacyClasses( <G> )
#F  NumberConjugacyClasses( <U>, <G> )
##
NumberConjugacyClasses := function( arg )

    # check that the argument is a group
    if not IsGroup( arg[1] )  then
      Error("<G> must be a group");
    fi;

    if Length( arg ) = 1 then

      # return number of conjugacy classes of 'arg[1]'
      return NrConjugacyClasses( arg[1] );

    elif Length( arg ) = 2 then

      # number of conjugacy classes of 'arg[2]' under the action of 'arg[1]'
      return NrConjugacyClassesInSupergroup( arg[1], arg[2] );

    else
      Error( "usage: NumberConjugacyClasses( [<U>, ]<H> )" );
    fi;

end;


#############################################################################
##
#F  Numerator( <rat> )
##
Numerator := NumeratorRat;


#############################################################################
##
#F  OrbitPowermaps( <powermaps>, <matautomorphisms> )
##
OrbitPowermaps := OrbitPowerMaps;


#############################################################################
##
#M  Order( <D>, <elm> ) . . . . . . . . . . . . . . two argument order method
##
InstallOtherMethod( Order,
    "two-argument method, ignore first argument",
    true,
    [ IsObject, IsObject ], 0,
    function( D, elm )
    return Order( elm );
    end );


#############################################################################
##
#F  OrderCyc( <cyc> ) . . . . . . . . . . . . . . . . . order of a cyclotomic
##
OrderCyc := Order;


#############################################################################
##
#M  PermutationCharacter( <P> ) . . . . . . . . . . . for a permutation group
##
##  Note that the manual of {\GAP-3} did *not* require <P> to be transitive,
##  although the text presupposed this.
##
InstallOtherMethod( PermutationCharacter,
    "method for a permutation group (compatibility mode)",
    true,
    [ IsPermGroup ], 0,
    NaturalCharacter );


#############################################################################
##
#F  Polynomial( <coeffs> )
#F  Polynomial( <coeffs>, <val> )
##
Polynomial := function( arg )
    local fam;
    fam:= FamilyObj( One( arg[1] ) );
    if Length( arg ) = 2 then
      return UnivariateLaurentPolynomialByCoefficients(fam,arg[2],1);
    else
      return UnivariateLaurentPolynomialByCoefficients(fam,arg[2],arg[3],1);
    fi;
end;


#############################################################################
##
#F  Powermap( <tbl>, <p> )
##
Powermap := PossiblePowerMaps;


#############################################################################
##
#F  PowerMapping( <map>, <n> )
##
PowerMapping := \^;


#############################################################################
##
#F  Powmap( <powermap>, <n> )
#F  Powmap( <powermap>, <n>, <class> )
##
Powmap := function( arg )
    local powermap, n, i, nth_powermap, class;
    if arg[1] = [] then
      Error( "empty powermap" );
    elif Length( arg ) = 2 and IsInt( arg[2] ) then
      powermap:= arg[1];
      n:= arg[2];
      if IsBound( powermap[n] ) then
        return powermap[n];
      else
        nth_powermap:= [ 1 .. Length( powermap[ Length( powermap ) ] ) ];
        for i in FactorsInt( n ) do
          if not IsBound( powermap[i] ) then
            Error( "power map of prime factor ", i, " not available" );
          fi;
          nth_powermap:= CompositionMaps( powermap[i], nth_powermap );
        od;
        return nth_powermap;
      fi;
    elif Length( arg ) = 3 and IsInt( arg[2] ) and IsInt( arg[3] ) then
      powermap:= arg[1];
      n:= arg[2];
      class:= arg[3];
      if IsBound( powermap[n] ) then
        return powermap[n][ class ];
      else
        nth_powermap:= [ class ];
        for i in FactorsInt( n ) do
          if not IsBound( powermap[i] ) then
            Error( "power map of prime factor ", i, " not available");
          fi;
          nth_powermap[1]:= CompositionMaps( powermap[i], nth_powermap, 1 );
        od;
        return nth_powermap[1];
      fi;
    fi;
    Error( "usage: Powmap(powermap,n) resp. Powmap(powermap,n,class)" );
end;


#############################################################################
##
#F  Power( <powermap>, <characters>, <n> )
##
##  the indirections of <characters> by the <n>-th power map;
##  this map is calculated from the power map of the prime divisors of <n>.
##
Power := function( powermap, characters, n )
    local nth_powermap;
    nth_powermap:= Powmap( powermap, n );
    return List( characters, x -> Indirected( x, nth_powermap ) );
end;


#############################################################################
##
#F  PowermapsAllowedBySymmetrisations( ... )
##
PowermapsAllowedBySymmetrisations := PowerMapsAllowedBySymmetrisations;


#############################################################################
##
#F  PrintToCAS( <filename>, <tbl> )
#F  PrintToCAS( <tbl>, <filename> )
##
##  prints a CAS library table of the GAP table <tbl> to the file <filename>,
##  with linelength 'SizeScreen()[1]'.
##
PrintToCAS := function( filename, tbl )

    # Allow both successions of arguments.
    if IsString( tbl ) then
      PrintTo( tbl, CASString( filename ) );
    else
      PrintTo( filename, CASString( tbl ) );
    fi;
end;


#############################################################################
##
#F  RandomInvertableMat( <n>, <F> )
##
RandomInvertableMat := RandomInvertibleMat;


#############################################################################
##
#F  RecFields( <record> )
##
RecFields := RecNames;


#############################################################################
##
#F  SortCharactersCharTable( <arg> )
#F  SortClassesCharTable( <arg> )
#F  SortCharTable( <arg> )
##
SortCharactersCharTable := function( arg )
    Error( "character tables must not be sorted in GAP 4,",
           "please use `CharacterTableWithSortedCharacters' or ",
           "`SortedCharacters' instead" );
end;

SortClassesCharTable := function( arg )
    Error( "character tables must not be sorted in GAP 4,",
           "please use `CharacterTableWithSortedClasses' instead" );
end;

SortCharTable := function( arg )
    Error( "character tables must not be sorted in GAP 4,",
           "please use `SortedCharacterTable' instead" );
end;


#############################################################################
##
#F  String( <obj>, <width> )
##
InstallOtherMethod( String,
    "two-argument method, delegate to `FormattedString'",
    true,
    [ IsObject, IsInt ], 0,
    FormattedString );

StringInt    := String;
StringRat    := String;
StringCyc    := String;
StringFFE    := String;
StringPerm   := String;
StringAgWord := String;
StringBool   := String;
StringList   := String;
StringRec    := String;


#############################################################################
##
#F  StrongGenerators( <G> )
##
StrongGenerators := function(G)
  return ShallowCopy(StrongGeneratorsStabChain(StabChainMutable(G)));
end;


#############################################################################
##
#F  SubgroupFusions( <tbl> )
##
SubgroupFusions := PossibleClassFusions;


#############################################################################
##
#F  Sublist( <list>, <list> ) . . . . . . . . . . .  extract a part of a list
##
Sublist := ELMS_LIST;


#############################################################################
##
#F  TestCharTable( <tbl> )
##
TestCharTable := IsInternallyConsistent;


#############################################################################
##
#F  TransformingPermutationsCharTables( <tbl> )
##
TransformingPermutationsCharTables :=
    TransformingPermutationsCharacterTables;


#############################################################################
##
#F  VirtualCharacter( <tbl>, <values> )
##
VirtualCharacter := VirtualCharacterByValues;


#############################################################################
##
#F  X( <R> )
##
X := Indeterminate;


#############################################################################
##
#F  IsIdentical( <a>,<b> )
##
IsIdentical :=IsIdenticalObj;


#############################################################################
##
#F  Copy( <obj> )
##
Copy := StructuralCopy;

#############################################################################
##
#F  RandomList( <list> )
##
RandomList := Random;

#############################################################################
##
#F  ConcatenationString( <strings> )
##
ConcatenationString := Concatenation;

#############################################################################
##
#F  AllCharTableNames( ... )
#F  CharTableSpecialized( <gentbl>, <param> )
#F  FirstNameCharTable( <tblname> )
#F  FileNameCharTable( <tblname> )
##
##  The following functions make sense only if the character table library
##  is available.
##
if TBL_AVAILABLE then
  AllCharTableNames := AllCharacterTableNames;
  CharTableSpecialized := CharacterTableSpecialized;
  FirstNameCharTable := name -> LibInfoCharacterTable( name ).firstName;
  FileNameCharTable  := name -> LibInfoCharacterTable( name ).fileName;
fi;


#############################################################################
##
#E  compat3a.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

