#############################################################################
##
#W  magma.gd                    GAP library                     Thomas Breuer
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
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
#C  IsMagmaWithInverses(<obj>)test whether an object is a magma-with-inverses
##
##  A magma-with-inverses in {\GAP} is a magma-with-one $S$ with an operation
##  $'\^-1' \: S \rightarrow  S$ that maps each element  of the magma  to its
##  inverse.
##
IsMagmaWithInverses :=
    NewCategory( "IsMagmaWithInverses",
        IsMagmaWithOne and IsMultiplicativeElementWithInverseCollection );

InstallCollectionsTrueMethod( IsMagmaWithInverses,
    IsFiniteOrderElement, IsMagma );

InstallTrueMethod( IsMagmaWithInverses, IsMagmaWithOne and IsTrivial );


#############################################################################
##
#C  IsMagmaWithInversesAndZero(<obj>)
##
##  A magma with inverses and zero in  {\GAP} is a magma with  one $S$ with a
##  zero element $z$ and with an operation
##  $'\^-1' \: S\setminus \{ z \} \rightarrow S \setminus \{ z \}$ that  maps
##  each nonzero element of the magma to its inverse.
##
IsMagmaWithInversesAndZero :=
    NewCategory( "IsMagmaWithInversesAndZero",
        IsMagmaWithOne and IsMultiplicativeElementWithOneCollection );


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

InstallCollectionsTrueMethod( IsAssociative,
    IsAssociativeElement, IsMagma );

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

InstallCollectionsTrueMethod( IsCommutative,
    IsCommutativeElement, IsMagma );

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
Centralizer :=
    NewOperation( "Centralizer",
        [ IsMagma, IsObject ] );


#############################################################################
##
#A  CentralizerInParent(<M>)  . . . . .  centralizer of a magma in its parent
##
CentralizerInParent :=
    NewAttribute( "CentralizerInParent",
        IsMagma );
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
#F  IsCommutativeFromGenerators( <GeneratorsOfStruct> )
##
##  is a function that takes one domain argument <D> and checks whether
##  '<GeneratorsOfStruct>( <D> )' commute.
##
IsCommutativeFromGenerators := NewOperationArgs(
    "IsCommutativeFromGenerators" );


#############################################################################
##
#E  magma.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here



