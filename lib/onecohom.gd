#############################################################################
##
#W  onecohom.gd                     GAP library                  Frank Celler
##                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the declarations of operations for the 1-Cohomology
##
Revision.onecohom_gd:=
  "@(#)$Id$";


#############################################################################
##
#V  InfoCoh
##
InfoCoh := NewInfoClass("InfoCoh");


#############################################################################
##
#O  TriangulizedGeneratorsByMatrix( <gens>, <M>, <F> ) 
##                                                  triangulize and make base
##  AKA 'AbstractBaseMat'
##
TriangulizedGeneratorsByMatrix :=
  NewOperationArgs("TriangulizedGeneratorsByMatrix");


##  For all following functions, the group is given as second argument to
##  allow dispatching after the group type

#############################################################################
##
#O  OCAddGenerators( <ocr>, <G> ) . . . . . . . . . . . add generators, local
##
OCAddGenerators := NewOperationArgs( "OCAddGenerators" );

#############################################################################
##
#O  OCAddMatrices( <ocr>, <gens> )  . . . . . . add operation matrices, local
##
OCAddMatrices := NewOperationArgs( "OCAddMatrices" );

#############################################################################
##
#O  OCAddToFunctions( <ocr> )  . . . . add operation matrices, local
##
OCAddToFunctions := NewOperationArgs( "OCAddToFunctions" );
OCAddToFunctions2 := NewOperation( "OCAddToFunctions2",
  [IsRecord, IsListOrCollection] );


#############################################################################
##
#O  OCAddRelations( <ocr>,<gens> ) . . . . . . . . . .  add relations, local
##
OCAddRelations := NewOperation( "OCAddRelations",
  [IsRecord, IsListOrCollection] );

#############################################################################
##
#O  OCNormalRelations( <ocr>,<G>,<gens> )  rels for normal complements, local
##
OCNormalRelations := NewOperation( "OCNormalRelations",
  [IsRecord,IsGroup,IsListOrCollection] );


#############################################################################
##
#O  OCAddSumMatrices( <ocr>, <gens> )  . . . . . . . . . . . add sums, local
##
OCAddSumMatrices := NewOperation("OCAddSumMatrices",
  [IsRecord,IsListOrCollection]);


#############################################################################
##
#O  OCAddBigMatrices( <ocr>, <gens> )  . . . . . . . . . . . . . . . . local
##
OCAddBigMatrices := NewOperation( "OCAddBigMatrices",
  [IsRecord,IsListOrCollection] );


#############################################################################
##
#O  OCCoprimeComplement( <ocr>, <gens> ) . . . . . . . .  coprime complement
##
OCCoprimeComplement := NewOperation( "OCCoprimeComplement",
  [IsRecord,IsListOrCollection] );


#############################################################################
##
#O  OneCoboundaries( <G>, <M> )	. . . . . . . . . . one cobounds of <G> / <M>
##
OneCoboundaries := NewOperationArgs( "OneCoboundaries" );


#############################################################################
##
#O  OneCocycles( <G>, <M> )	. . . . . . . . . . one cocycles of <G> / <M>
##
OneCocycles := NewOperationArgs( "OneCocycles" );


#############################################################################
##
#O  OCOneCoboundaries( <ocr> )	. . . . . . . . . . one cobounds main routine
##
OCOneCoboundaries := NewOperationArgs("OCOneCoboundaries");


#############################################################################
##
#O  OCConjugatingWord( <ocr>, <c1>, <c2> )  . . . . . . . . . . . . . . local
##
##  Compute a Word n in <ocr.module> such that <c1> ^ n = <c2>.
##
OCConjugatingWord := NewOperationArgs("OCConjugatingWord");


#############################################################################
##
#O  OCEquationMatrix( <ocr>, <r>, <n> )  . . . . . . . . . . . . . . .  local
##
OCEquationMatrix := NewOperationArgs("OCEquationMatrix");


#############################################################################
##
#O  OCSmallEquationMatrix( <ocr>, <r>, <n> )  . . . . . . . . . . . . . local
##
OCSmallEquationMatrix := NewOperationArgs("OCSmallEquationMatrix");


#############################################################################
##
#O  OCEquationVector( <ocr>, <r> )  . . . . . . . . . . . . . . . . . . local
##
OCEquationVector := NewOperationArgs("OCEquationVector");


#############################################################################
##
#O  OCSmallEquationVector( <ocr>, <r> )	. . . . . . . . . . . . . . . . local
##
OCSmallEquationVector := NewOperationArgs("OCSmallEquationVector");


#############################################################################
##
#O  OCAddComplement( <ocr>, <K> ) . . . . . . . . . . . . . . . . . . . local
##
OCAddComplement := NewOperationArgs("OCAddComplement");


#############################################################################
##
#O  OCOneCocycles( <ocr>, <onlySplit> ) . . . . . . one cocycles main routine
##
##  If <onlySplit>, 'OneCocyclesOC' returns 'false' as soon  as  possibly  if
##  the extension does not split.
##
OCOneCocycles := NewOperationArgs("OCOneCocycles");


#############################################################################
##
#O  ComplementclassesEA(<G>,<N>) . complement classes to el.ab. N by 1-Cohom.
##
ComplementclassesEA := NewOperationArgs("ComplementclassesEA");


#############################################################################
##
#O  OCPPrimeSets( <U> ) . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Construct  a  generating  set, which has the generators of Hall-subgroups
##  of a sylowcomplement system as sublist.
##
OCPPrimeSets := NewOperationArgs("OCPPrimeSets");


#############################################################################
##
#E  onecohom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
