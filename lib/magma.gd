#############################################################################
##
#W  magma.gd                    GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This  file   declares   the categories   of  magmas,   their  properties,
##  attributes, and operations.  Note that the  meaning of generators for the
##  three categories  magma,   magma-with-one, and    magma-with-inverses  is
##  different.
##
Revision.magma_gd:=
    "@(#)$Id$";


#############################################################################
##
#C  IsMagma(<obj>)  . . . . . . . . . . . . test whether an object is a magma
##
##  A magma  in {\GAP}  is a  domain  $S$ with (not  necessarily associative)
##  multiplication $'\*' \: S \times S \rightarrow S$.
##
IsMagma :=
    NewCategory( "IsMagma",
        IsDomain and IsMultiplicativeElementCollection );


#############################################################################
##
#C  IsMagmaWithOne(<obj>) . . . .  test whether an object is a magma-with-one
##
##  A  magma-with-one in  {\GAP} is a magma $S$   with an operation '^0' that
##  yields the identity of the magma.
##
IsMagmaWithOne :=
    NewCategory( "IsMagmaWithOne",
        IsMagma and IsMultiplicativeElementWithOneCollection );


#############################################################################
##
#C  IsMagmaWithInversesIfNonzero(<obj>)
##
##  A magma with inverses and zero in {\GAP} is a magma-with-one $S$
##  and with an operation
##  $'\^-1' \: S\setminus Z \rightarrow S \setminus Z$,
##  with $Z$ either empty or containing the zero element of $S$,
##  that maps each nonzero element of $S$ to its inverse.
##
IsMagmaWithInversesIfNonzero :=
    NewCategory( "IsMagmaWithInversesIfNonzero",
        IsMagmaWithOne and IsMultiplicativeElementWithOneCollection );


#############################################################################
##
#C  IsMagmaWithInverses(<obj>)test whether an object is a magma-with-inverses
##
##  A magma-with-inverses in {\GAP} is a magma-with-one $S$ with an operation
##  $'\^-1' \: S \rightarrow  S$ that maps each element  of the magma  to its
##  inverse.
##
##  Note that not every trivial magma is a magma-with-one.
##  But every trivial magma-with-one is a magma-with-inverses.
##  This holds also if the identity of the magma-with-one is a zero element.
##  So a magma-with-inverses-if-nonzero can be a magma-with-inverses
##  if either it contains no zero element or consists of a zero element that
##  has itself as zero-th power.
##
IsMagmaWithInverses :=
    NewCategory( "IsMagmaWithInverses",
            IsMagmaWithInversesIfNonzero
        and IsMultiplicativeElementWithInverseCollection );

InstallTrueMethod( IsMagmaWithInverses,
    IsFiniteOrderElementCollection and IsMagma );

InstallTrueMethod( IsMagmaWithInverses, IsMagmaWithOne and IsTrivial );


#############################################################################
##
#F  Magma( <F>, <generators> )
##
Magma := NewOperationArgs( "Magma" );


#############################################################################
##
#F  Submagma( <M>, <generators> )
##
Submagma := NewOperationArgs( "Submagma" );


#############################################################################
##
#F  SubmagmaNC( <M>, <generators> )
##
SubmagmaNC := NewOperationArgs( "SubmagmaNC" );


#############################################################################
##
#F  MagmaWithOne(<F>,<generators>)
##
MagmaWithOne := NewOperationArgs( "MagmaWithOne" );


#############################################################################
##
#F  SubmagmaWithOne( <M>, <generators> )
##
SubmagmaWithOne := NewOperationArgs( "SubmagmaWithOne" );


#############################################################################
##
#F  SubmagmaWithOneNC( <M>, <generators> )
##
SubmagmaWithOneNC := NewOperationArgs( "SubmagmaWithOneNC" );


#############################################################################
##
#F  MagmaWithInverses(<F>,<generators>)
##
MagmaWithInverses := NewOperationArgs( "MagmaWithInverses" );


#############################################################################
##
#F  SubmagmaWithInverses( <M>, <generators> )
##
SubmagmaWithInverses := NewOperationArgs( "SubmagmaWithInverses" );


#############################################################################
##
#F  SubmagmaWithInversesNC( <M>, <generators> )
##
SubmagmaWithInversesNC := NewOperationArgs( "SubmagmaWithInversesNC" );


#############################################################################
##
#O  MagmaByGenerators(<generators>)
#O  MagmaByGenerators(<F>,<generators>)
##
MagmaByGenerators := NewOperation( "MagmaByGenerators", [ IsCollection ] );


#############################################################################
##
#O  MagmaWithOneByGenerators(<generators>)
#O  MagmaWithOneByGenerators(<F>,<generators>)
##
MagmaWithOneByGenerators := NewOperation(
    "MagmaWithOneByGenerators", [ IsCollection ] );


#############################################################################
##
#O  MagmaWithInversesByGenerators(<generators>)
#O  MagmaWithInversesByGenerators(<F>,<generators>)
##
MagmaWithInversesByGenerators := NewOperation(
    "MagmaWithInversesByGenerators", [ IsCollection ] );


#############################################################################
##
#A  GeneratorsMagmaFamily( <F> )
##
GeneratorsMagmaFamily := NewAttribute( "GeneratorsMagmaFamily", IsFamily );


#############################################################################
##
#A  GeneratorsOfMagma(<M>)
##
GeneratorsOfMagma    :=
    NewAttribute( "GeneratorsOfMagma",
        IsMagma );
SetGeneratorsOfMagma := Setter( GeneratorsOfMagma );
HasGeneratorsOfMagma := Tester( GeneratorsOfMagma );


#############################################################################
##
#A  GeneratorsOfMagmaWithOne(<M>)
##
GeneratorsOfMagmaWithOne :=
    NewAttribute( "GeneratorsOfMagmaWithOne",
        IsMagmaWithOne );
SetGeneratorsOfMagmaWithOne := Setter( GeneratorsOfMagmaWithOne );
HasGeneratorsOfMagmaWithOne := Tester( GeneratorsOfMagmaWithOne );


#############################################################################
##
#A  GeneratorsOfMagmaWithInverses(<M>)
##
GeneratorsOfMagmaWithInverses :=
    NewAttribute( "GeneratorsOfMagmaWithInverses",
        IsMagmaWithInverses );
SetGeneratorsOfMagmaWithInverses := Setter( GeneratorsOfMagmaWithInverses );
HasGeneratorsOfMagmaWithInverses := Tester( GeneratorsOfMagmaWithInverses );


#############################################################################
##
#A  TrivialSubmagmaWithOne( <M> ) . . . . . . . . . . .  for a magma-with-one
##
TrivialSubmagmaWithOne := NewAttribute( "TrivialSubmagmaWithOne",
    IsMagmaWithOne );
SetTrivialSubmagmaWithOne := Setter( TrivialSubmagmaWithOne );
HasTrivialSubmagmaWithOne := Tester( TrivialSubmagmaWithOne );


#############################################################################
##
#P  IsAssociative(<M>)  . . . . . . . . . test whether a magma is associative
##
##  A magma  <M> is associative  if  for all elements   $a, b, c  \in M$  the
##  equality $( a \* b ) \* c = a \* ( b \* c )$ holds.
##
IsAssociative :=
    NewProperty( "IsAssociative",
        IsMagma );
SetIsAssociative := Setter( IsAssociative );
HasIsAssociative := Tester( IsAssociative );

InstallTrueMethod( IsAssociative,
    IsAssociativeElementCollection and IsMagma );

InstallSubsetMaintainedMethod( IsAssociative,
    IsMagma and IsAssociative, IsMagma );

InstallFactorMaintainedMethod( IsAssociative,
    IsMagma and IsAssociative, IsMagma, IsMagma );

InstallTrueMethod( IsAssociative, IsMagma and IsTrivial );


#############################################################################
##
#P  IsCommutative(<M>)  . . . . . . . . . test whether a magma is commutative
##
##  A magma <M> is commutative if for all elements $a,  b \in M$ the equality
##  $a \* b = b \* a$ holds.
##
IsCommutative :=
    NewProperty( "IsCommutative",
        IsMagma );
SetIsCommutative := Setter( IsCommutative );
HasIsCommutative := Tester( IsCommutative );

IsAbelian    := IsCommutative;
SetIsAbelian := SetIsCommutative;
HasIsAbelian := HasIsCommutative;

InstallTrueMethod( IsCommutative,
    IsCommutativeElementCollection and IsMagma );

InstallSubsetMaintainedMethod( IsCommutative,
    IsMagma and IsCommutative, IsMagma );

InstallFactorMaintainedMethod( IsCommutative,
    IsMagma and IsCommutative, IsMagma, IsMagma );

InstallTrueMethod( IsCommutative, IsMagma and IsTrivial );


#############################################################################
##
#A  MultiplicativeNeutralElement(<M>) . . . . . . . . . . identity of a magma
##
##  A magma  that is not a  magma-with-one can have a  multiplicative neutral
##  element although this cannot be obtained as 0-th power of elements.
##
MultiplicativeNeutralElement :=
    NewAttribute(  "MultiplicativeNeutralElement",
        IsMagma );
SetMultiplicativeNeutralElement := Setter( MultiplicativeNeutralElement );
HasMultiplicativeNeutralElement := Tester( MultiplicativeNeutralElement );


#############################################################################
##
#A  Centre(<M>) . . . . . . . . . . . . . . . . . . . . . . centre of a magma
##
##  'Centre' returns  the centre of  the  magma <M>, i.e.,   the set of those
##  elements $m \in <M>$ that commute with all elements of <M>.
##
Centre :=
    NewAttribute( "Centre",
        IsMagma );
SetCentre := Setter( Centre );
HasCentre := Tester( Centre );


#############################################################################
##
#O  IsCentral(<M>,<obj>)  . . .  test whether an object is central in a magma
##
##  'IsCentral' returns true if the  object <obj>,  which  must either be  an
##  element of a subset of the magma <M>, commutes with all elements in <M>.
##
IsCentral :=
    NewOperation( "IsCentral",
        [ IsMagma, IsObject ] );


#############################################################################
##
#O  Centralizer(<M>,<obj>) . . . . . . . . . . . . . . centralizer in a magma
##
##  is the centralizer of  <obj>, which must be  an element or a substructure
##  of the magma <M>.  This is the domain of those elements  $m \in <M>$ that
##  commute with <obj>.
##
tmp:= InParentFOA( "Centralizer", IsMagma, IsObject, NewAttribute );
Centralizer         := tmp[1];
CentralizerOp       := tmp[2];
CentralizerInParent := tmp[3];
SetCentralizerInParent := Setter( CentralizerInParent );
HasCentralizerInParent := Tester( CentralizerInParent );


#############################################################################
##
#O  SquareRoots( <M>, <elm> )
##
##  is the set of all elements <r> in the magma <M>
##  such that '<r> \* <r> = <elm>'.
##
SquareRoots := NewOperation( "SquareRoots",
    [ IsMagma, IsMultiplicativeElement ] );


#############################################################################
##
#F  FreeMagma( <rank> )
#F  FreeMagma( <rank>, <name> )
#F  FreeMagma( <name1>, <name2>, ... )
#F  FreeMagma( <names> )
##
FreeMagma := NewOperationArgs( "FreeMagma" );


#############################################################################
##
#F  IsCommutativeFromGenerators( <GeneratorsOfStruct> )
##
##  is a function that takes one domain argument <D> and checks whether
##  '<GeneratorsOfStruct>( <D> )' commute.
##
IsCommutativeFromGenerators := function( GeneratorsStruct )
    return function( D )

    local gens,   # list of generators
          i, j;   # loop variables

    # Test if every element commutes with all the others.
    gens:= GeneratorsStruct( D );
    for i in [ 2 .. Length( gens ) ] do
      for j in [ 1 .. i-1 ] do
        if gens[i] * gens[j] <> gens[j] * gens[i] then
          return false;
        fi;
      od;
    od;

    # All generators commute.
    return true;
    end;
end;


#############################################################################
##
#F  IsCentralFromGenerators( <GeneratorsStruct1>, <GeneratorsStruct2> )
##
##  is a function that takes two domain arguments <D1>, <D2> and checks
##  whether `<GeneratorsStruct1>( <D1> )' and `<GeneratorsStruct2>( <D2> )'
##  commute.
##
IsCentralFromGenerators := function( GeneratorsStruct1, GeneratorsStruct2 )
    return function( D1, D2 )
    local g1, g2;
    for g1 in GeneratorsStruct1( D1 ) do
      for g2 in GeneratorsStruct2( D2 ) do
        if g1 * g2 <> g2 * g1 then
          return false;
        fi;
      od;
    od;
    return true;
    end;
end;


#############################################################################
##
#A  AsMagma( <C> )  . . . . . . . . . . . . . .  view a collection as a magma
##
AsMagma := NewAttribute( "AsMagma", IsCollection );
SetAsMagma := Setter( AsMagma );
HasAsMagma := Tester( AsMagma );


#############################################################################
##
#O  AsSubmagma( <M>, <N> )  . . . view a magma as a submagma of another magma
##
AsSubmagma := NewOperation( "AsSubmagma", [ IsMagma, IsMagma ] );


#############################################################################
##
#E  magma.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



