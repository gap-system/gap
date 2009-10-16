#############################################################################
##
#W  compat3a.g                  GAP library                     Thomas Breuer
##
#H  @(#)$Id: compat3a.g,v 4.45 2007/02/06 22:28:08 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the non-destructive part of the {\GAP}~3 compatibility
##  mode,
##  where non-destructive means that no functionality of {\GAP}~4 is lost
##  when this file is read.
##  The file consists of the following parts.
##
##  - For functions whose names have changed,
##    the old names are made available.
##  - Methods and functions are added to allow functionality
##    that is not really intended for {\GAP}~4.
##
##  This file is *not* read as part of the {\GAP}~4 library.
##
Revision.compat3a_g :=
    "@(#)$Id: compat3a.g,v 4.45 2007/02/06 22:28:08 gap Exp $";


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
BindGlobal( "AbstractGeneratorIterator", 0 );

BindGlobal( "AbstractGenerator", function( name )
    if AbstractGeneratorIterator = 0 then
      MakeReadWriteGlobal( "AbstractGeneratorIterator" );
      BindGlobal( "AbstractGeneratorIterator",
          Iterator( GeneratorsOfGroup( FreeGroup( infinity ) ) ) );
    fi;
    return NextIterator( AbstractGeneratorIterator );
end );

#T what about the name of the generator?
## this would be tediously hard to fix -- would have to alter the
## "infinite list of names" to allow a finite list of overrides
## if this was done, it would be worth doing in general -- build a
##  construct for a (finitely) mutable infinite list


#############################################################################
##
#F  ApplyFunc( <func>, <args> ) . . . . . . . . . . . result of function call
##
DeclareSynonym( "ApplyFunc", CallFuncList );


#############################################################################
##
#F  Base( <G> )
##
DeclareSynonym( "Base", BaseOfGroup );


#############################################################################
##
#F  BergerCondition( <G> )
##
DeclareSynonym( "BergerCondition", IsBergerCondition );


#############################################################################
##
#F  CartesianProduct( <D>,... ) . . . . . .  cartesian product of collections
##
BindGlobal( "CartesianProduct", function ( arg )
    local   i;

    # unravel the arguments
    if Length(arg) = 1  and IsList( arg[1] )  then
        arg := ShallowCopy( arg[1] );
    fi;

    # make all domains into sets
    for i  in [1..Length(arg)]  do
        arg[i] := AsSSortedList( arg[i] );
    od;

    # make the cartesian product
    return Cartesian( arg );
end );


#############################################################################
##
#F  CentralChar( <tbl>, <char> )
##
DeclareSynonym( "CentralChar", CentralCharacter );


#############################################################################
##
#F  CharDegAgGroup( <G> ) . . . . . . . . . . . . . . . . . character degrees
##
DeclareSynonym( "CharDegAgGroup", CharacterDegrees );


#############################################################################
##
#F  CharFFE( <ffe> )  . . . . . . . . . . . . . . . . . characteristic of FFE
##
DeclareSynonym( "CharFFE", Characteristic );


#############################################################################
##
##  Some functions are declared in the character table library.
##
LoadPackage( "ctbllib" );


#############################################################################
##
#F  CharTable( <G> )
#F  CharTableHead( <G> )
#F  CharTableRegular( <tbl>, <p> )
#F  CharTableDirectProduct( <tbl1>, <tbl2> )
#F  CharTableFactorGroup( <tbl>, <classes> )
#F  CharTableNormalSubgroup( <tbl>, <classes> )
#F  CharTableIsoclinic( <tbl>, <classes> )
#F  CharTableWreathSymmetric( <tbl>, <n> )
#F  CharTableQuaternionic( <4n> )
##
DeclareSynonym( "CharTable", CharacterTable );
DeclareSynonym( "CharTableHead", CharacterTable );
DeclareSynonym( "CharTableRegular", CharacterTableRegular );
DeclareSynonym( "CharTableDirectProduct", CharacterTableDirectProduct );
DeclareSynonym( "CharTableFactorGroup", CharacterTableFactorGroup );
DeclareSynonym( "CharTableNormalSubgroup", CharacterTableOfNormalSubgroup );
DeclareSynonym( "CharTableIsoclinic", CharacterTableIsoclinic );
DeclareSynonym( "CharTableWreathSymmetric", CharacterTableWreathSymmetric );
DeclareSynonym( "CharTableQuaternionic", CharacterTableQuaternionic );


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
##  One can use `IrrBaumClausen' to compute the irreducible characters via
##  the algorithm of Baum and Clausen, which is a non-recursive form of the
##  algorithm used by `CharTablePGroup' in {\GAP}~3.
##  The calculation of irreducible characters via the algorithm that was
##  used by `CharTableSSGroup' is available in {\GAP}~4 as `IrrConlon'.
##
BindGlobal( "CharTablePGroup", function( G )
    Error( "this function is not supported in GAP 4.\n",
           "Use `IrrBaumClausen' if you want to compute the irreducible\n",
           "characters of <G> by an algorithm similar to the one\n",
           "that was used by `CharTablePGroup' in GAP 3," );
end );

BindGlobal( "CharTableSSGroup", function( G )
    Error( "this function is not supported in GAP 4.\n",
           "Use `IrrConlon' if you want to compute the irreducible\n",
           "characters of <G> by the algorithm that was used by\n",
           "`CharTableSSGroup' in GAP 3," );
end );


#############################################################################
##
#F  CharPol( <F>, <z> ) . . . .  coeffs. of char. polynomial of a field elm.
#F  CharPol( <z> )
##
DeclareOperation( "CharPol", [ IsField, IsScalar ] );

InstallOtherMethod( CharPol,
    "for a scalar",
    [ IsScalar ],
    z -> CharPol( DefaultField( z ), z ) );

InstallMethod( CharPol,
    "for a field, and a scalar",
    IsCollsElms,
    [ IsField, IsScalar ],
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
#F  ClassesNormalSubgroup( <tbl>, <N> )
##
DeclareSynonym( "ClassesNormalSubgroup", ClassPositionsOfNormalSubgroup );


#############################################################################
##
#F  ClassMultCoeffCharTable( <tbl>, <i>, <j>, <k> )
##
DeclareSynonym( "ClassMultCoeffCharTable", ClassMultiplicationCoefficient );


#############################################################################
##
#F  ClassNamesCharTable( <tbl> )
##
DeclareSynonym( "ClassNamesCharTable", ClassNames );


#############################################################################
##
#F  ClassOrbitCharTable( <tbl>, <c> )
##
DeclareSynonym( "ClassOrbitCharTable", ClassOrbit );


#############################################################################
##
#F  ClassRootsCharTable( <tbl> )
##
DeclareSynonym( "ClassRootsCharTable", ClassRoots );


#############################################################################
##
#F  Closure( <G>, <g> )
#F  Closure( <G>, <U> )
##
##  Handle the different closures for groups, modules, algebras,
##  and vector spaces.
##
BindGlobal( "Closure", function( D, E )
    if   IsAlgebra( D ) then
        return ClosureAlgebra( D, E );
    elif IsGroup( D ) then
        return ClosureGroup( D, E );
    elif IsVectorSpace( D ) then
        return ClosureLeftModule( D, E );
    fi;
end );


#############################################################################
##
#F  ConcatenationString( <strings> )
##
DeclareSynonym( "ConcatenationString", Concatenation );


#############################################################################
##
#F  ConsiderSmallerPowermaps( ... )
##
DeclareSynonym( "ConsiderSmallerPowermaps", ConsiderSmallerPowerMaps );


#############################################################################
##
#F  COEFFSCYC( <cyc> )
##
DeclareSynonym( "COEFFSCYC", COEFFS_CYC );


#############################################################################
##
#F  Copy( <obj> )
##
DeclareSynonym( "Copy", StructuralCopy );


#############################################################################
##
#F  Denominator( <rat> )
##
DeclareSynonym( "Denominator", DenominatorRat );


#############################################################################
##
#F  DepthVector( <vec> )
##
##  This variable is also defined in the `autpgrp' package.
##
if not IsBound( DepthVector ) then
  DeclareSynonym( "DepthVector", PositionNonZero );
fi;


#############################################################################
##
#F  DeterminantChar( <tbl>, <chi> )
##
DeclareSynonym( "DeterminantChar", DeterminantOfCharacter );


#############################################################################
##
#F  DisplayCharTable( <tbl> )
#F  DisplayCharTable( <tbl>, <options> )
##
DeclareSynonym( "DisplayCharTable", Display );


#############################################################################
##
#F  DisplayTom( <tbl> )
#F  DisplayTom( <tbl>, <options> )
##
DeclareSynonym( "DisplayTom", Display );


#############################################################################
##
#F  ElementOrdersPowermap( <powermap> )
##
DeclareSynonym( "ElementOrdersPowermap", ElementOrdersPowerMap );


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
BindGlobal( "Equivalenceclasses", function( list, isequal )

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
end );


#############################################################################
##
#F  IncludeIrreducibles( <D>, <list> )
##
DeclareSynonym( "IncludeIrreducibles", DxIncludeIrreducibles );


#############################################################################
##
#F  InducedActionSpaceMats( <basis>, <mats> )
##
BindGlobal( "InducedActionSpaceMats", function( basis, mats )
    return List( mats, m -> InducedLinearAction( basis, m, OnRight ) );
end );


#############################################################################
##
#F  InitClassesCharTable( <tbl> )  . . initialize classes of character tables
##
BindGlobal( "InitClassesCharTable", function( tbl )
    local initclasses;
  # if not IsInt( tbl.centralizers[1] ) then return; fi; # generic tables
    initclasses:= SizesConjugacyClasses( tbl );
    if not ForAll( initclasses, IsInt ) then
      Print( "#E InitClassesCharTable: not all centralizer orders divide",
             " the group order\n" );
    fi;
    return initclasses;
end );


#############################################################################
##
#F  InitPowermap( <tbl>, <p> )
##
DeclareSynonym( "InitPowermap", InitPowerMap );


#############################################################################
##
#F  IntCyc( <cyc> )
##
DeclareSynonym( "IntCyc", Int );


#############################################################################
##
#F  InverseClassesCharTable( <tbl> )
##
DeclareSynonym( "InverseClassesCharTable", InverseClasses );


#############################################################################
##
#F  InverseMapping( <map> )
##
DeclareSynonym( "InverseMapping", Inverse );


#############################################################################
##
#F  IsBijection( <map> )
##
DeclareSynonym( "IsBijection", IsBijective );


#############################################################################
##
#F  IsCharTable( <tbl> )
#F  IsCharTableHead( <tbl> )
##
DeclareSynonym( "IsCharTable", IsNearlyCharacterTable );
DeclareSynonym( "IsCharTableHead", IsNearlyCharacterTable );


#############################################################################
##
#F  IsCommutativeRing( <R> )
##
DeclareSynonym( "IsCommutativeRing", IsCommutative and IsRing );


#############################################################################
##
#F  IsFiniteField( <obj> )  . . .  test if an object is a finite field record
##
BindGlobal( "IsFiniteField", function ( obj )
    return ( IsField( obj ) and IsFinite( obj ) )
           or ( IsRecord( obj )
       and IsBound( obj.isField  )  and obj.isField
       and IsBound( obj.isFinite )  and obj.isFinite );
end );


#############################################################################
##
#F  IsFiniteFieldElement( <obj> )
##
BindGlobal( "IsFiniteFieldElement", function ( obj )
    return IsFFE( obj )
           or ( IsRecord( obj ) and IsBound( obj.isFiniteFieldElement )
                             and obj.isFiniteFieldElement );
end );


#############################################################################
##
#F  IsFunc( <obj> )
##
DeclareSynonym( "IsFunc", IsFunction );


#############################################################################
##
#F  IsIdentical( <a>, <b> )
##
DeclareSynonym( "IsIdentical", IsIdenticalObj );


#############################################################################
##
#F  IsMat( <obj> )
##
DeclareSynonym( "IsMat", IsMatrix );


#############################################################################
##
#F  IsRec( <obj> )
##
DeclareSynonym( "IsRec", IsRecord );


#############################################################################
##
#A  KernelChar( <char> )
##
DeclareSynonym( "KernelChar", ClassPositionsOfKernel );


#############################################################################
##
#A  LengthWord( <word> )
##
DeclareSynonymAttr( "LengthWord", Length );


#############################################################################
##
#M  ListOp( <obj> ) . . . . . . . . . . . . . . . . . . . . convert to a list
#M  ListOp( <perm> )  . . . . . . . . . . . . . . . . . . . convert to a list
##
##  In this version, <obj> may be a list, or a permutation, or any
##  object for that a method for `ListOp' is installed.
##
##  (Note the different behaviour in {\GAP}~3 if the argument is a string;
##  but fortunately this was never documented.)
##
InstallMethod( ListOp,
    "method for a list (compatibility mode)",
    [ IsList ],
    IdFunc );

InstallOtherMethod( ListOp,
    "method for a permutation (compatibility mode)",
    [ IsPerm ],
    ListPerm );


#############################################################################
##
#F  Marks( <tom> ) . . . . . . . . . . . . . . . .  marks of a table of marks
##
DeclareSynonym( "Marks", MarksTom );


#############################################################################
##
#F  MatAutomorphisms( <mat>, <maps>, <subgroup> )
##
DeclareSynonym( "MatAutomorphisms", MatrixAutomorphisms );


#############################################################################
##
#F  MatRepresenatationsPGroup( <G> )  . irred. repr. of a supersolvable group
##
BindGlobal( "MatRepresentationsPGroup", function( G )
    local reps;
    reps:= IrreducibleRepresentationsByBaumClausen( G );
    if Sum( reps, x -> DimensionOfMatrixGroup( Range(x) )^2 ) < Size(G) then
      Print( "#W  RepresentationsPGroup:not all representations known\n" );
    fi;
    return reps;
end );


#############################################################################
##
#F  MinPol( <F>, <z> )  . . . . coeffs. of min. polynomial of a field element
#F  MinPol( <z> )
##
DeclareOperation( "MinPol", [ IsField, IsScalar ] );

InstallOtherMethod( MinPol,
    "for a scalar",
    [ IsScalar ],
    z -> MinPol( DefaultField( z ), z ) );

InstallMethod( MinPol,
    "for a field, and a scalar",
    IsCollsElms,
    [ IsField, IsScalar ],
    function( F, z )

    local   pol,        # minimal polynom of <z> in <F>, result
            deg,        # degree of <pol>
            con,        # conjugate of <z> in <F>
            i;          # loop variable

    # compute the trace simply by multiplying $x-cnj$
    pol := [ One( F ) ];
    deg := 0;
    for con  in SSortedList( Conjugates( F, z ) )  do
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
##  (was already obsolete in {\GAP}~3)
##
DeclareSynonym( "Mod", EuclideanRemainder );


#############################################################################
##
#F  NofCyc( <cyc> )
##
DeclareSynonym( "NofCyc", Conductor );


#############################################################################
##
#F  NrSubs( <tom> )  . . . . . . . . . . subgroup numbers of a table of marks
##
DeclareSynonym( "NrSubs", NrSubsTom );


#############################################################################
##
#F  NumberConjugacyClasses( <G> )
#F  NumberConjugacyClasses( <U>, <G> )
##
BindGlobal( "NumberConjugacyClasses", function( arg )

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

end );


#############################################################################
##
#F  Numerator( <rat> )
##
DeclareSynonym( "Numerator", NumeratorRat );


#############################################################################
##
#F  OrbitPowermaps( <powermaps>, <matautomorphisms> )
##
DeclareSynonym( "OrbitPowermaps", OrbitPowerMaps );


#############################################################################
##
#M  Order( <D>, <elm> ) . . . . . . . . . . . . . . two argument order method
##
InstallOtherMethod( Order,
    "two-argument method, ignore first argument",
    [ IsObject, IsObject ],
    function( D, elm )
    return Order( elm );
    end );


#############################################################################
##
#M  PermutationCharacter( <P> ) . . . . . . . . . . . for a permutation group
##
##  Note that the manual of {\GAP}~3 did *not* require <P> to be transitive,
##  although the text presupposed this.
##
InstallOtherMethod( PermutationCharacter,
    "method for a permutation group (compatibility mode)",
    [ IsPermGroup ],
    NaturalCharacter );


#############################################################################
##
#F  Polynomial( <coeffs> )
#F  Polynomial( <coeffs>, <val> )
##
BindGlobal( "Polynomial", function( arg )
    local fam;
    fam:= FamilyObj( One( arg[1] ) );
    if Length( arg ) = 2 then
      return LaurentPolynomialByCoefficients(fam,arg[2],1);
    else
      return LaurentPolynomialByCoefficients(fam,arg[2],arg[3],1);
    fi;
end );


#############################################################################
##
#F  Powermap( <tbl>, <p> )
##
DeclareSynonym( "Powermap", PossiblePowerMaps );


#############################################################################
##
#F  PowerMapping( <map>, <n> )
##
DeclareSynonym( "PowerMapping", \^ );


#############################################################################
##
#F  Powmap( <powermap>, <n> )
#F  Powmap( <powermap>, <n>, <class> )
##
BindGlobal( "Powmap", function( arg )
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
end );


#############################################################################
##
#F  Power( <powermap>, <characters>, <n> )
##
##  the indirections of <characters> by the <n>-th power map;
##  this map is calculated from the power map of the prime divisors of <n>.
##
BindGlobal( "Power", function( powermap, characters, n )
    local nth_powermap;
    nth_powermap:= Powmap( powermap, n );
    return List( characters, x -> Indirected( x, nth_powermap ) );
end );


#############################################################################
##
#F  PowermapsAllowedBySymmetrisations( ... )
##
DeclareSynonym( "PowermapsAllowedBySymmetrisations",
    PowerMapsAllowedBySymmetrisations );


#############################################################################
##
#F  PrintCharTable( <tbl> )
##
BindGlobal( "PrintCharTable", function( tbl )
    PrintCharacterTable( tbl, "t" );
end );


#############################################################################
##
#F  PrintToCAS( <filename>, <tbl> )
#F  PrintToCAS( <tbl>, <filename> )
##
##  prints a CAS library table of the {\GAP} table <tbl> to the file
##  <filename>, with linelength 'SizeScreen()[1]'.
##
BindGlobal( "PrintToCAS", function( filename, tbl )

    # Allow both successions of arguments.
    if IsString( tbl ) then
      PrintTo( tbl, CASString( filename ) );
    else
      PrintTo( filename, CASString( tbl ) );
    fi;
end );


#############################################################################
##
#F  PrintToMOC( <moctbl> )
#F  PrintToMOC( <moctbl>, <chars> )
##
BindGlobal( "PrintToMOC", function( arg )
    Print( CallFuncList( MOCString, arg ) );
end );


#############################################################################
##
#F  RandomInvertableMat( <n>, <F> )
##
DeclareSynonym( "RandomInvertableMat", RandomInvertibleMat );


#############################################################################
##
#F  RealClassesCharTable( <tbl> )
##
DeclareSynonym( "RealClassesCharTable", RealClasses );


#############################################################################
##
#F  RepresentativesPowermaps( <listofpowermaps>, <matautomorphisms> )
##
DeclareSynonym( "RepresentativesPowermaps", RepresentativesPowerMaps );


#############################################################################
##
#F  SortCharactersCharTable( <arg> )
#F  SortClassesCharTable( <arg> )
#F  SortCharTable( <arg> )
##
BindGlobal( "SortCharactersCharTable", function( arg )
    Error( "character tables must not be sorted in GAP 4,",
           "please use `CharacterTableWithSortedCharacters' or ",
           "`SortedCharacters' instead" );
end );

BindGlobal( "SortClassesCharTable", function( arg )
    Error( "character tables must not be sorted in GAP 4,",
           "please use `CharacterTableWithSortedClasses' instead" );
end );

BindGlobal( "SortCharTable", function( arg )
    Error( "character tables must not be sorted in GAP 4,",
           "please use `SortedCharacterTable' instead" );
end );


#############################################################################
##
#F  StringInt( <obj> )
#F  StringRat( <obj> )
#F  StringCyc( <obj> )
#F  StringFFE( <obj> )
#F  StringPerm( <obj> )
#F  StringAgWord( <obj> )
#F  StringBool( <obj> )
#F  StringList( <obj> )
#F  StringRec( <obj> )
##
DeclareSynonym( "StringInt", String );
DeclareSynonym( "StringRat", String );
DeclareSynonym( "StringCyc", String );
DeclareSynonym( "StringFFE", String );
DeclareSynonym( "StringPerm", String );
DeclareSynonym( "StringAgWord", String );
DeclareSynonym( "StringBool", String );
DeclareSynonym( "StringList", String );
DeclareSynonym( "StringRec", String );


#############################################################################
##
#F  StrongGenerators( <G> )
##
BindGlobal( "StrongGenerators", function(G)
  return ShallowCopy(StrongGeneratorsStabChain(StabChainMutable(G)));
end );


#############################################################################
##
#F  SubgroupFusions( <tbl> )
##
DeclareSynonym( "SubgroupFusions", PossibleClassFusions );


#############################################################################
##
#F  Sublist( <list>, <list> ) . . . . . . . . . . .  extract a part of a list
##
DeclareSynonym( "Sublist", ELMS_LIST );


#############################################################################
##
#F  TestCharTable( <tbl> )  . . . . . . consistency check for character table
##
DeclareSynonym( "TestCharTable", IsInternallyConsistent );


#############################################################################
##
#F  TestTom( <tom> )  . . . . . . . . .  consistency check for table of marks
##
DeclareSynonym( "TestTom", IsInternallyConsistent );


#############################################################################
##
#F  TomCyclic( <n> )
##
DeclareSynonym( "TomCyclic", TableOfMarksCyclic );


#############################################################################
##
#F  TomDihedral( <m> )
##
DeclareSynonym( "TomDihedral", TableOfMarksDihedral );


#############################################################################
##
#F  TomFrobenius( <p>, <q> )
##
DeclareSynonym( "TomFrobenius", TableOfMarksFrobenius );


#############################################################################
##
#F  TomMat( <mat> ) . . . . . . . . . . . . . . .  table of marks from matrix
##
DeclareSynonym( "TomMat", TableOfMarks );


#############################################################################
##
#F  TransformingPermutationsCharTables( <tbl> )
##
DeclareSynonym( "TransformingPermutationsCharTables",
    TransformingPermutationsCharacterTables );


#############################################################################
##
##  The following functions had been in `lib/obsolete.g' in {\GAP}~4.3,
##  and were sorted out with the release of {\GAP}~4.4.)
##

#############################################################################
##
##  Obsolete synonyms, see the functions with names where ``Operation'' is
##  replaced by ``Action''.
##
DeclareSynonym( "RepresentativeOperation", RepresentativeAction );
DeclareSynonym( "RepresentativeOperationOp", RepresentativeActionOp );
DeclareSynonym( "Operation", Action );
DeclareSynonym( "IsOperationHomomorphism", IsActionHomomorphism );
DeclareSynonym( "IsOperationHomomorphismByOperators",
    IsActionHomomorphismByActors);
DeclareSynonym( "IsOperationHomomorphismSubset",
    IsActionHomomorphismSubset);
DeclareSynonym( "IsOperationHomomorphismByBase",
    IsActionHomomorphismByBase);
DeclareSynonym( "IsLinearOperationHomomorphism",
    IsLinearActionHomomorphism);
DeclareSynonymAttr( "FunctionOperation", FunctionAction );
DeclareSynonym( "OperationHomomorphism", ActionHomomorphism );
DeclareSynonymAttr( "OperationHomomorphismAttr", ActionHomomorphismAttr );
DeclareSynonym( "OperationHomomorphismConstructor",
    ActionHomomorphismConstructor);
DeclareSynonymAttr( "SurjectiveOperationHomomorphismAttr",
    SurjectiveActionHomomorphismAttr );
DeclareSynonym( "ImageElmOperationHomomorphism", ImageElmActionHomomorphism );
DeclareSynonym( "SparseOperationHomomorphism", SparseActionHomomorphism );
DeclareSynonym( "SortedSparseOperationHomomorphism",
    SortedSparseActionHomomorphism );


#############################################################################
##
##  relics of vector space basis stuff (from times when only unary methods
##  could be installed for attributes and thus additional non-attributes had
##  been introduced)
##

#############################################################################
##
#A  BasisOfDomain( <V> )
#O  BasisByGenerators( <V>, <vectors> )
#O  BasisByGeneratorsNC( <V>, <vectors> )
#A  SemiEchelonBasisOfDomain( <V> )
#O  SemiEchelonBasisByGenerators( <V>, <vectors> )
#O  SemiEchelonBasisByGeneratorsNC( <V>, <vectors> )
##
DeclareSynonymAttr( "BasisOfDomain", Basis );
DeclareSynonym( "BasisByGenerators", Basis );
DeclareSynonym( "BasisByGeneratorsNC", BasisNC );
DeclareSynonymAttr( "SemiEchelonBasisOfDomain", SemiEchelonBasis );
DeclareSynonym( "SemiEchelonBasisByGenerators", SemiEchelonBasis );
DeclareSynonym( "SemiEchelonBasisByGeneratorsNC", SemiEchelonBasisNC );


#############################################################################
##
#O  NewBasis( <V>[, <gens>] )
##
##  This operation is obsolete.
##  The idea to introduce it was that its methods were allowed to call
##  `Objectify', whereas `Basis' methods were thought to call `NewBasis'.
##
DeclareSynonym( "NewBasis", Basis );


#############################################################################
##
#O  MutableBasisByGenerators( <F>, <gens>[, <zero>] )
##
DeclareSynonym( "MutableBasisByGenerators", MutableBasis );

#############################################################################
##
#A  UnderlyingField( <obj> )
##
##  Underlying field of a vector space or an algebra.
##
DeclareAttribute( "UnderlyingField", IsVectorSpace );
InstallMethod(UnderlyingField,"vector space",true,[IsVectorSpace],0,
  LeftActingDomain);
DeclareAttribute( "UnderlyingField", IsFFEMatrixGroup );
InstallMethod(UnderlyingField,"generic",true,[IsFFEMatrixGroup],0,
  FieldOfMatrixGroup);

#############################################################################
##
##  Some relics of the old primitive groups library.
##
BindGlobal( "AffinePermGroupByMatrixGroup", function( arg )
    return AffineActionByMatrixGroup( arg[1] );
end );

DeclareSynonym( "PrimitiveAffinePermGroupByMatrixGroup",
    AffineActionByMatrixGroup );

#############################################################################
##
#S  PrimeOfPGroup
##
##  Prime of p-group.
##  was replaced by PrimePGroup.
##
DeclareSynonym( "PrimeOfPGroup", PrimePGroup );

#############################################################################
##
#S  MatrixDimension
##
##  Dimension of matrices in an algebra.
##  was replaced by DimensionOfMatrixGroup.
##
DeclareSynonym( "MatrixDimension", DimensionOfMatrixGroup);

#############################################################################
##
#S  MonomialTotalDegreeLess
##
##  monomial ordering: the function was badly defined, name is now obsolete
##  was replaced by MonomialExtGrlexLess.
##
DeclareSynonym( "MonomialTotalDegreeLess", MonomialExtGrlexLess );

#############################################################################
##
#E

