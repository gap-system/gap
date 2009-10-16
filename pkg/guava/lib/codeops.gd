#############################################################################
##
#A  codeops.gd               GUAVA                              Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  All the code operations 
##
#H  @(#)$Id: codeops.gd,v 1.7 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/codeops_gd") :=
    "@(#)$Id: codeops.gd,v 1.7 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  WordLength( <C> ) . . . . . . . . . . . .  length of the codewords of <C>
##

#############################################################################
##
#F  IsLinearCode( <C> ) . . . . . . . . . . . . . . . checks if <C> is linear
##
## If so, the record fields will be adjusted to the linear representation 
##
DeclareProperty("IsLinearCode", IsCode);

#############################################################################
##
#F  Redundancy( <C> ) . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
##
DeclareAttribute("Redundancy", IsCode);


#############################################################################
##
#F  GeneratorMat(C) . . . . .  finds the generator matrix belonging to code C
##
##  Pre: C should contain a generator or check matrix
##
DeclareAttribute("GeneratorMat", IsCode);

#############################################################################
##
#F  CheckMat( <C> ) . . . . . . .  finds the check matrix belonging to code C
##
##  Pre: <C> should be a linear code
##
DeclareAttribute("CheckMat", IsCode);


#############################################################################
##
#F  IsCyclicCode( <C> ) . . . . . . . . . . . . . . . . . . . . . . . . . .
##
DeclareProperty("IsCyclicCode", IsLinearCode);


#############################################################################
##
#F  GeneratorPol( <C> ) . . . . . . . . returns the generator polynomial of C
##
##  Pre: C must have a generator or check polynomial
##
DeclareAttribute("GeneratorPol", IsCode);


#############################################################################
##
#F  CheckPol( <C> ) . . . . . . . .  returns the parity check polynomial of C
##
##  Pre: C must have a generator or check polynomial
##
DeclareAttribute("CheckPol", IsCode);


#############################################################################
##
#F  MinimumDistance( <C> [, <w>] )  . . . .  determines the minimum distance
##
##  MinimumDistance( <C> ) determines the minimum distance of <C>
##  MinimumDistance( <C>, <w> ) determines the minimum distance to a word <w>
##
DeclareAttribute("MinimumDistance", IsCode);

#############################################################################
##
##  MinimumDistanceLeon( <C> ) determines the minimum distance of <C>
##
DeclareAttribute("MinimumDistanceLeon", IsLinearCode);

#############################################################################
##
#F  DesignedDistance( arg )  . . . . . . . . . . . . . . . . . . . . . . . .
## 
##  Cannot be calculated.  Must be set at creation, if at all. 
DeclareAttribute("DesignedDistance", IsCode);


#############################################################################
##
#F  LowerBoundMinimumDistance( arg )  . . . . . . . . . . . . . . . . . . .
##
DeclareOperation("LowerBoundMinimumDistance", [IsCode]);  


#############################################################################
##
#F  UpperBoundMinimumDistance( arg )  . . . . . . . . . . . . . . . . . . .
##
DeclareOperation("UpperBoundMinimumDistance", [IsCode]); 

#############################################################################
##
#F  UpperBoundOptimalMinimumDistance( arg )  . . . . . . . . . . . . . . . .
## 
##  UpperBoundMinimumDistance of optimal code with same parameters 
## 
DeclareAttribute("UpperBoundOptimalMinimumDistance", IsCode);


#############################################################################
##
#F  MinimumWeightOfGenerators( arg )  . . . . . . . . . . . . . . . . . . . .
##
##
DeclareAttribute("MinimumWeightOfGenerators", IsCode); 


#############################################################################
##
#F  MinimumWeightWords( <C> ) . . .  returns the code words of minimum weight
##
DeclareAttribute("MinimumWeightWords", IsCode);


#############################################################################
##
#F  WeightDistribution( <C> ) . . . returns the weight distribution of a code
##
DeclareAttribute("WeightDistribution", IsCode);


#############################################################################
##
#F  InnerDistribution( <C> )  . . . . . .  the inner distribution of the code
##
##  The average distance distribution of distances between all codewords
##
DeclareAttribute("InnerDistribution", IsCode);


#############################################################################
##
#F  OuterDistribution( <C> )  . . . . . . . . . . . . . . . . . . . . . . .
##
##  the number of codewords on a distance i from all elements of GF(q)^n
##
DeclareAttribute("OuterDistribution", IsCode);


#############################################################################
##
#F  CodewordVector( <l>, <C> ) 
##
##  returns the element of the code <C> corresponding to the coefficient
##  list <l>. This is a synonym for \* for codes
DeclareOperation("CodewordVector", [IsList, IsCode]); 


#############################################################################
##
#F  InformationWord( C, c )  . . . . . . . "decodes" a codeword in C to the 
##                                information "message" word m, so m*C=c
##
DeclareOperation("InformationWord", [IsCode,IsCodeword]); 


#############################################################################
##
#F  IsSelfDualCode( <C> ) . . . . . . . . . determines whether C is self dual
##
##  i.o.w. each codeword is orthogonal to all codewords (including itself)
##
DeclareProperty("IsSelfDualCode", IsCode);


#############################################################################
##
#F  \*( <l>, <C> )  . . . . .  the codeword belonging to information vector x
##
##  only valid if C is linear! 
##


#############################################################################
##
#F  \+( <l>, <C> )  . . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
##


#############################################################################
##
#F  \in( <l>, <C> ) . . . . . .  true if the vector is an element of the code
##
##


#############################################################################
##
#F  \=( <C1>, <C2> )  . . . . .  tests if Set(Elements(C1))=Set(Elements(C2))
##
##  Post: returns a boolean
##


#############################################################################
##
#F  SyndromeTable ( <C> ) . . . . . . . . . . . . . . . a Syndrome table of C
##
DeclareAttribute("SyndromeTable", IsCode);


#############################################################################
##
#F  StandardArray( <C> )  . . . . . . . . . . . . a standard array for code C
##
##  Post: returns a 3D-matrix. The first row contains all the codewords of C.
##  The other rows contain the cosets, preceded by their coset leaders.
##
DeclareAttribute("StandardArray", IsCode);


#############################################################################
##
#F  AutomorphismGroup( <C> )  . . . . . . . .  the automorphism group of code
##
##  The automorphism group is the largest permutation group of degree n such
##  that for each permutation in the group C' = C. Binary codes only. Calls
##  Leon's C code.
##
DeclareAttribute("AutomorphismGroup", IsCode);

#############################################################################
##
#F  PermutationGroup( <C> )  . . . . . . . .  the permutation group of code
##
##  The largest permutation group of degree n such
##  that for each permutation pn in the group pC = C. Written in GAP.
##  May be removed in future versions.
##
DeclareAttribute("PermutationGroup", IsCode);


#############################################################################
##
#F  PermutationAutomorphismGroup( <C> )  . . . . the permutation group of code
##
##  The largest permutation group of degree n such
##  that for each permutation pn in the group pC = C. Written in GAP.
##
DeclareAttribute("PermutationAutomorphismGroup", IsCode);

#############################################################################
##
#F  IsSelfOrthogonalCode( <C> ) . . . . . . . . . . . . . . . . . . . . . .
##
DeclareProperty("IsSelfOrthogonalCode", IsCode);


#############################################################################
##
#F  CodeIsomorphism( <C1>, <C2> ) . . the permutation that translates C1 into
#F                         C2 if C1 and C2 are equivalent, or false otherwise
##
DeclareOperation("CodeIsomorphism", [IsCode, IsCode]); 


#############################################################################
##
#F  IsEquivalent( <C1>, <C2> )  . . . . . .  true if C1 and C2 are equivalent
##
##  that is if there exists a permutation that transforms C1 into C2.
##  If returnperm is true, this permutation (if it exists) is returned;
##  else the function only returns true or false. 
##
DeclareOperation("IsEquivalent", [IsCode, IsCode]); 


#############################################################################
##
#F  RootsOfCode( <C> )  . . . .  the roots of the generator polynomial of <C>
##
##  It finds the roots by trying all elements of the extension field
##
DeclareAttribute("RootsOfCode", IsCode);


#############################################################################
##
#F  DistancesDistribution( <C>, <w> ) . . .  distribution of distances from a
#F                                               word w to all codewords of C
##
DeclareOperation("DistancesDistribution", [IsCode, IsCodeword]);  


#############################################################################
##
#F  Syndrome( <C>, <c> )  . . . . . . .  the syndrome of word <c> in code <C>
##
DeclareOperation("Syndrome", [IsCode, IsCodeword]); 


#############################################################################
##
#F  CodewordNr( <C>, <i> )  . . . . . . . . . . . . . . . . .  elements(C)[i]
##
DeclareOperation("CodewordNr", [IsCode, IsList]); 


#############################################################################
##
#F  String( <C> ) . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
##
##


#############################################################################
##
#F  CodeDescription( <C> )  . . . . . . . . . . . . . . . . . . . . . . . . . 
##
DeclareOperation("CodeDescription", [IsCode]); 


#############################################################################
##
#F  Print( <C> )  . . . . . . . . . . . . .  prints short information about C
##
##


#############################################################################
##
#F  Display( <C> )  . . . . . . . . . . . .  prints the history of the code C
##
##


#############################################################################
##
#F  Save( <filename>, <C>, <var-name> ) . . . . . writes the code C to a file
##
##  with variable name var-name. It can be read back by calling
##  Read (filename); the code then has the name var-name.
##  All fields of the code record are stored except, 
##  in case of a linear or cyclic code, the elements.
##  Pre: filename is accessible for writing
##
DeclareOperation("Save", [IsString, IsCode, IsString]); 


#############################################################################
##
#F  History( <C> )  . . . . . . . . . . . . . . . shows the history of a code
## 
DeclareOperation("History", [IsCode]); 


######################################################################################
#F           MinimumDistanceRandom( <C>, <num>, <s> )
##
## This is a simpler version than Leon's method, which does not put G in st form.
## (this works welland is in some cases faster than the st form one)
## Input: C is a linear code 
##        num is an integer >0 which represents the number of iterations
##        s is an integer between 1 and n which represents the columns considered
##           in the algorithm.
## Output: an integer >= min dist(C), and hopefully equal to it!
##         a codework of that weight
##
## Algorithm: randomly permute the columns of the gen mat G of C
##              by a permutation rho - call new mat Gp
##            break Gp into (A,B), where A is kxs and B is kx(n-s)
##            compute code C_A generated by rows of A
##            find min weight codeword c_A of C_A and w_A=wt(c_A)
##              using AClosestVectorCombinationsMatFFEVecFFECoords
##            extend c_A to a corresponding codeword c_p in C_Gp
##            return c=rho^(-1)(c_p) and wt=wt(c_p)=wt(c)
##
DeclareOperation("MinimumDistanceRandom",[IsCode,IsInt,IsInt]); 