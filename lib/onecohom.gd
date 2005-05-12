#############################################################################
##
#W  onecohom.gd                     GAP library                  Frank Celler
##                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations of operations for the 1-Cohomology
##
Revision.onecohom_gd:=
  "@(#)$Id$";


#############################################################################
##
#V  InfoCoh
##
##  The info class for the cohomology calculations is `InfoCoh'.
DeclareInfoClass("InfoCoh");


#############################################################################
##
#O  TriangulizedGeneratorsByMatrix( <gens>, <M>, <F> ) 
##                                                  triangulize and make base
##  AKA `AbstractBaseMat'
##
DeclareGlobalFunction("TriangulizedGeneratorsByMatrix");


##  For all following functions, the group is given as second argument to
##  allow dispatching after the group type

#############################################################################
##
#O  OCAddGenerators( <ocr>, <G> ) . . . . . . . . . . . add generators, local
##
DeclareGlobalFunction( "OCAddGenerators" );

#############################################################################
##
#O  OCAddMatrices( <ocr>, <gens> )  . . . . . . add operation matrices, local
##
DeclareGlobalFunction( "OCAddMatrices" );

#############################################################################
##
#O  OCAddToFunctions( <ocr> )  . . . . add operation matrices, local
##
DeclareGlobalFunction( "OCAddToFunctions" );
DeclareOperation( "OCAddToFunctions2", [IsRecord, IsListOrCollection] );


#############################################################################
##
#O  OCAddRelations( <ocr>,<gens> ) . . . . . . . . . .  add relations, local
##
DeclareOperation( "OCAddRelations",
  [IsRecord, IsListOrCollection] );

#############################################################################
##
#O  OCNormalRelations( <ocr>,<G>,<gens> )  rels for normal complements, local
##
DeclareOperation( "OCNormalRelations",
  [IsRecord,IsGroup,IsListOrCollection] );


#############################################################################
##
#O  OCAddSumMatrices( <ocr>, <gens> )  . . . . . . . . . . . add sums, local
##
DeclareOperation("OCAddSumMatrices",
  [IsRecord,IsListOrCollection]);


#############################################################################
##
#O  OCAddBigMatrices( <ocr>, <gens> )  . . . . . . . . . . . . . . . . local
##
DeclareOperation( "OCAddBigMatrices",
  [IsRecord,IsListOrCollection] );


#############################################################################
##
#O  OCCoprimeComplement( <ocr>, <gens> ) . . . . . . . .  coprime complement
##
DeclareOperation( "OCCoprimeComplement",
  [IsRecord,IsListOrCollection] );


#############################################################################
##
#O  OneCoboundaries( <G>, <M> )	. . . . . . . . . . one cobounds of <G> / <M>
##
##  computes the group of 1-coboundaries. Syntax of input and output
##  otherwise is the same as with `OneCocycles' except that entries that
##  refer to cocycles are not computed.
DeclareGlobalFunction( "OneCoboundaries" );


#############################################################################
##
#O  OneCocycles( <G>, <M> )
#O  OneCocycles( <gens>, <M> )
#O  OneCocycles( <G>, <mpcgs> )
#O  OneCocycles( <gens>, <mpcgs> )
##
##  Computes the group of 1-Cocycles $Z^1(<G>/<M>,<M>)$. The normal subgroup
##  <M> may be given by a (Modulo)Pcgs <mpcgs>. In this case the whole
##  calculation is performed modulo the normal subgroup defined by the
##  `DenominatorOfModuloPcgs(<mpcgs>)' (see~"Polycyclic Generating
##  Systems").  Similarly the group <G> may instead be specified by a set of
##  elements <gens> that are representatives for a generating system for
##  the factor group <G>/<M>. If this is done the 1-Cocycles are computed
##  with respect to these generators (otherwise the routines try to select
##  suitable generators themselves).
DeclareGlobalFunction( "OneCocycles" );


#############################################################################
##
#O  OCOneCoboundaries( <ocr> )	. . . . . . . . . . one cobounds main routine
##
DeclareGlobalFunction("OCOneCoboundaries");


#############################################################################
##
#O  OCConjugatingWord( <ocr>, <c1>, <c2> )  . . . . . . . . . . . . . . local
##
##  Compute a Word n in <ocr.module> such that <c1> ^ n = <c2>.
##
DeclareGlobalFunction("OCConjugatingWord");


#############################################################################
##
#O  OCEquationMatrix( <ocr>, <r>, <n> )  . . . . . . . . . . . . . . .  local
##
DeclareGlobalFunction("OCEquationMatrix");


#############################################################################
##
#O  OCSmallEquationMatrix( <ocr>, <r>, <n> )  . . . . . . . . . . . . . local
##
DeclareGlobalFunction("OCSmallEquationMatrix");


#############################################################################
##
#O  OCEquationVector( <ocr>, <r> )  . . . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("OCEquationVector");


#############################################################################
##
#O  OCSmallEquationVector( <ocr>, <r> )	. . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("OCSmallEquationVector");


#############################################################################
##
#O  OCAddComplement( <ocr>, <ocr.group>, <K> ) . . . . . . . . . . . . . local
##
DeclareOperation("OCAddComplement",
  [IsRecord,IsGroup,IsListOrCollection]);


#############################################################################
##
#O  OCOneCocycles( <ocr>, <onlySplit> ) . . . . . . one cocycles main routine
##
##  is the more technical function to compute 1-cocycles. It takes an record
##  <ocr> as first argument which must contain at least the components
##  `group' for $G$ and `modulePcgs' for a (modulo) pcgs of <M>. This record
##  will also be returned with components as described under `OneCocycles'
##  (with the exception of `isSplitExtension' which is indicated by the
##  existence of a `complement')
##  but components such as `oneCoboundaries' will only be
##  computed if not already present.
##
##  If <onlySplit> is `true', `OneCocyclesOC' returns `false' as soon as
##  possible if the extension does not split.
##
DeclareGlobalFunction("OCOneCocycles");


#############################################################################
##
#O  ComplementclassesEA(<G>,<N>) . complement classes to el.ab. N by 1-Cohom.
##
##  computes `Complementclasses' to an elementary abelian normal subgroup
##  <N> via 1-Cohomology. Normally, a user program should call
##  `Complementclasses' (see~"Complementclasses") instead, which also works
##  for a solvable (not necessarily elementary abelian) <N>.
DeclareGlobalFunction("ComplementclassesEA");


#############################################################################
##
#o  OCPPrimeSets( <U> ) . . . . . . . . . . . . . . . . . . . . . . . . local
##
##  Construct  a  generating  set, which has the generators of Hall-subgroups
##  of a sylowcomplement system as sublist.
##
#T DeclareGlobalFunction("OCPPrimeSets");
#T up to now no function is installed


#############################################################################
##
#E  onecohom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
