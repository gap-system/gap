#############################################################################
##
#W  compat3a.g                  GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
      AbstractGeneratorIterator:= GeneratorsOfGroup( FreeGroup( infinity ) );
    fi;
    return NextIterator( AbstractGeneratorIterator );
end;
#T what about the name of the generator?


#############################################################################
##
#F  Apply( <list>, <func> ) . . . . . . . .  apply a function to list entries
##
##  `Apply' applies <func> to every member of <list> and replaces an entry by
##  the corresponding return value.
##  Warning:  The previous contents of <list> will be lost.
##
Apply := function( list, func )
    local i;

    for i in [1..Length( list )] do
        list[i] := func( list[i] );
    od;
end;


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
#F  CharTableSpecialized( <gentbl>, <param> )
##
CharTable := CharacterTable;
CharTableHead := CharacterTable;
CharTableRegular := CharacterTableRegular;
CharTableDirectProduct := CharacterTableDirectProduct;
CharTableFactorGroup := CharacterTableFactorGroup;
CharTableNormalSubgroup := CharacterTableOfNormalSubgroup;
CharTableIsoclinic := CharacterTableIsoclinic;
CharTableQuaternionic := CharacterTableQuaternionic;
CharTableSpecialized := CharacterTableSpecialized;


#############################################################################
##
#F  Character( <tbl>, <values> )
##
Character := CharacterByValues;


#############################################################################
##
#F  ClassFunction( <tbl>, <values> )
##
ClassFunction := ClassFunctionByValues;


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
#F  DisplayCharTable( <tbl> )
#F  DisplayCharTable( <tbl>, <options> )
##
DisplayCharTable := Display;


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
#T (used only in 'agclass.g', with second argument 'IsIdentical')
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
#F  FirstNameCharTable( <tblname> )
##
FirstNameCharTable := name -> LibInfoCharacterTable( name ).firstName;


#############################################################################
##
#F  FileNameCharTable( <tblname> )
##
FileNameCharTable  := name -> LibInfoCharacterTable( name ).fileName;


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
#F  IsFunc( <list> )
##
IsFunc := IsFunction;


#############################################################################
##
#F  IsRec( <list> )
##
IsRec := IsRecord;


#############################################################################
##
#F  IsSet( <list> )
##
IsSet := IsSSortedList;


#############################################################################
##
#M  List( <obj> ) . . . . . . . . . . . . . . . . . . . . . convert to a list
#M  List( <perm> )  . . . . . . . . . . . . . . . . . . . . convert to a list
##
##  In this version, <obj> may be a list, or a permutation, or any
##  object for that a method for 'List' is installed.
##
##  (Note the different behaviour in {\GAP-3} if the argument is a string;
##  but fortunately this was never documented.)
##
InstallOtherMethod( List,
    "method for a list (compatibility mode)",
    true,
    [ IsList ], 0,
    IdFunc );

InstallOtherMethod( List,
    "method for a permutation (compatibility mode)",
    true,
    [ IsPerm ], 0,
    ListPerm );


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
#F  PowerMapping( <map>, <n> )
##
PowerMapping := \^;


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
#F  VirtualCharacter( <tbl>, <values> )
##
VirtualCharacter := VirtualCharacterByValues;


#############################################################################
##
#E  compat3a.g  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

