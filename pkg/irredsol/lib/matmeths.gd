############################################################################
##
##  matmeths.gd                    IRREDSOL                 Burkhard Höfling
##
##  @(#)$Id: matmeths.gd,v 1.4 2011/04/07 07:58:08 gap Exp $
##
##  Copyright © Burkhard Höfling (burkhard@hoefling.name)
##


############################################################################
##
#P  IsIrreducibleMatrixGroup(<G>)
#O  IsIrreducibleMatrixGroup(<G>, <F>)
#O  IsIrreducible(<G>, <F>)
##
##  see IRREDSOL documentation
##
##  IsIrreducible(<G>) is declared in the GAP library
##
DeclareProperty ("IsIrreducibleMatrixGroup", IsMatrixGroup);
KeyDependentOperation ("IsIrreducibleMatrixGroup", IsMatrixGroup, IsField, ReturnTrue);
DECLARE_IRREDSOL_SYNONYMS ("IsIrreducibleMatrixGroup");
DeclareOperation ("IsIrreducible", [IsMatrixGroup, IsField]);

############################################################################
##
#O  IsAbsolutelyIrreducible(<G>)
#P  IsAbsolutelyIrreducibleMatrixGroup(<G>)
##
##  see IRREDSOL documentation
##  
DeclareOperation ("IsAbsolutelyIrreducible", [IsMatrixGroup]);
DeclareProperty ("IsAbsolutelyIrreducibleMatrixGroup", IsMatrixGroup);
DECLARE_IRREDSOL_SYNONYMS ("IsAbsolutelyIrreducibleMatrixGroup");


############################################################################
##
#P  IsPrimitiveMatrixGroup(<G>)
#O  IsPrimitiveMatrixGroup(<G>, <F>)
#P  IsPrimitive(<G>)
#O  IsPrimitive(<G>, <F>)
##
##  see IRREDSOL documentation
##  
DeclareProperty ("IsPrimitiveMatrixGroup", IsMatrixGroup);
KeyDependentOperation ("IsPrimitiveMatrixGroup", IsMatrixGroup, IsField, ReturnTrue);
DECLARE_IRREDSOL_SYNONYMS ("IsPrimitiveMatrixGroup");
DeclareProperty ("IsPrimitive", IsMatrixGroup); # already a property elsewhere in the library
DeclareOperation ("IsPrimitive", [IsMatrixGroup, IsField]);


############################################################################
##
#A  MinimalBlockDimensionOfMatrixGroup(<G>)
#A  MinimalBlockDimensionOfMatrixGroup(<G>, <F>)
#O  MinimalBlockDimension(<G>, <F>)
##
##  see IRREDSOL documentation
##  
##  MinimalBlockDImension(<G>) is an attribute declared in the GAP library
##
DeclareAttribute ("MinimalBlockDimensionOfMatrixGroup", IsMatrixGroup);
KeyDependentOperation ("MinimalBlockDimensionOfMatrixGroup", IsMatrixGroup, IsField, ReturnTrue);
DECLARE_IRREDSOL_SYNONYMS ("MinimalBlockDimensionOfMatrixGroup");
DeclareOperation ("MinimalBlockDimension", [IsMatrixGroup, IsField]);


############################################################################
##
#A  CharacteristicOfField(<G>)
##
##  see IRREDSOL documentation
##  
##  Characteristic(<G>) is defined in the GAP library
##
DeclareAttribute ("CharacteristicOfField", IsMatrixGroup);


############################################################################
##
#A  RepresentationIsomorphism
##
##  see IRREDSOL documentation
##  
DeclareAttribute ("RepresentationIsomorphism", IsMatrixGroup);


############################################################################
##
#P  IsMaximalAbsolutelyIrreducibleSolvableMatrixGroup(<G>)
##
##  see IRREDSOL documentation
##  
DeclareProperty ("IsMaximalAbsolutelyIrreducibleSolvableMatrixGroup", IsMatrixGroup);
DECLARE_IRREDSOL_SYNONYMS ("IsMaximalAbsolutelyIrreducibleSolvableMatrixGroup");


############################################################################
##
#F  SmallBlockDimensionOfRepresentation(G, hom, F, limit)
##
##  G is a group, F a field, hom a homomorphism G -> GL(n, F), limit an integer
##  The function returns an integer k such that Im hom has a block system 
##  of block dimension k, where k < limit, or k >= limit and G has no
##  block system of block dimesnion < limit
##  
DeclareGlobalFunction ("SmallBlockDimensionOfRepresentation");


############################################################################
##
#F  ImprimitivitySystemsForRepresentation(G, rep, F, limit)
##  
##  G is a group, F a finite field, rep: G -> GL(n, F)
##  
##  If G has no block system with block dimension <= limit, the function 
##  computes a list of all imprimitivity systems of Im rep as a 
##  subgroup of GL(n, F). Otherwise, the function computes systems of imprimitivity,
##  one of which will have block dimension <= limit.
##
##  Each imprimitivity system is represented by a record with the following entries:
##  bases: a list of lists of vectors, each list of vectors being a basis of a block 
##            in the imprimitivity system
##  stab1: the stabilizer in G of the first block (i. e., the block with basis bases[1])
##  min:    true if the block system is a minimal block system amongst the systems returned
##
DeclareGlobalFunction ("ImprimitivitySystemsForRepresentation");


############################################################################
##
#A  ImprimitivitySystems(<G>)
#O  ImprimitivitySystems(<G>, <F>)
##
##  see IRREDSOL documentation
##  
DeclareAttribute ("ImprimitivitySystems", IsMatrixGroup);
KeyDependentOperation ("ImprimitivitySystems", IsMatrixGroup, IsField, ReturnTrue);


############################################################################
##
#A  TraceField(<G>)
##
##  see IRREDSOL documentation
##  
DeclareAttribute ("TraceField", IsMatrixGroup);


############################################################################
##
#A  SplittingField(<G>)
##
##  see IRREDSOL documentation
##  
DeclareAttribute ("SplittingField", IsMatrixGroup);


############################################################################
##
#A  ConjugatingMatTraceField(<G>)
##
##  returns a matrix x such that the matrix entries of G^x lie in the
##  trace field of G.
##  
DeclareAttribute ("ConjugatingMatTraceField", IsMatrixGroup);


############################################################################
##
#E
##
