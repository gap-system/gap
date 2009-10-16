#############################################################################
##
#A  codegen.gd              GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains info/functions for generating codes
##
#H  @(#)$Id: codegen.gd,v 1.5 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/codegen_gd") :=
    "@(#)$Id: codegen.gd,v 1.5 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  IsCode( <v> ) . . . . . . . . . . . . . . . . . . . . . .  code category
##
DeclareCategory("IsCode", IsListOrCollection);

#############################################################################
##
#F  ElementsCode( <L> [, <name> ], <F> )  . . . . . . code from list of words
##
DeclareOperation("ElementsCode", [IsList,IsString,IsField]);

#############################################################################
##
#F  RandomCode( <n>, <M> [, <F>] )  . . . . . . . .  random unrestricted code
##
DeclareOperation("RandomCode", [IsInt, IsInt, IsField]);

#############################################################################
##
#F  HadamardCode( <H | n> [, <t>] ) . Hadamard code of <t>'th kind, order <n>
##
DeclareOperation("HadamardCode", [IsMatrix, IsInt]); 

#############################################################################
##
#F  ConferenceCode( <n | M> ) . . . . . . . . . . code from conference matrix
##
DeclareOperation("ConferenceCode", [IsMatrix]); 

#############################################################################
##
#F  MOLSCode( [ <n>, ] <q> )  . . . . . . . . . . . . . . . .  code from MOLS
##
##  MOLSCode([n, ] q) returns a (n, q^2, n-1) code over GF(q)
##  by creating n-2 mutually orthogonal latin squares of size q.
##  If n is omitted, a wordlength of 4 will be set.
##  If there are no n-2 MOLS known, the code will return an error
##
DeclareOperation("MOLSCode", [IsInt, IsInt]);  

#############################################################################
##
#F  QuadraticCosetCode( <Q> ) . . . . . . . . . .  coset of RM(1,m) in R(2,m)
##
##  QuadraticCosetCode(Q) returns a coset of the ReedMullerCode of
##  order 1 (R(1,m)) in R(2,m) where m is the size of square matrix Q.
##  Q is the upper triangular matrix that defines the quadratic part of
##  the boolean functions that are in the coset.
##
#QuadraticCosetCode := function(arg)

#############################################################################
##
#F  GeneratorMatCode( <G> [, <name> ], <F> )  . .  code from generator matrix
##
DeclareOperation("GeneratorMatCode", [IsMatrix, IsString, IsField]);  

#############################################################################
##
#F  GeneratorMatCodeNC( <G> [, <name> ], <F> )  . .  code from generator matrix
## 
## same as GeneratorMatCode but does not compute upper + lower bounds
##  for the minimum distance or covering radius
DeclareOperation("GeneratorMatCodeNC", [IsMatrix, IsField]);  

#############################################################################
##
#F  CheckMatCode( <H> [, <name> ], <F> )  . . . . . .  code from check matrix
##
DeclareOperation("CheckMatCode", [IsMatrix, IsString, IsField]); 

#############################################################################
##
#F  RandomLinearCode( <n>, <k> [, <F>] )  . . . . . . . .  random linear code
##
DeclareOperation("RandomLinearCode", [IsInt, IsInt, IsField]); 

#############################################################################
##
#F  HammingCode( <r> [, <F>] )  . . . . . . . . . . . . . . . .  Hamming code
##
DeclareOperation("HammingCode", [IsInt, IsField]); 

#############################################################################
##
#F  SimplexCode( <r>, <F> ) .  The SimplexCode is the Dual of the HammingCode
##
DeclareOperation("SimplexCode", [IsInt, IsField]); 

#############################################################################
##
#F  ReedMullerCode( <r>, <k> )  . . . . . . . . . . . . . .  Reed-Muller code
##
##  ReedMullerCode(r, k) creates a binary Reed-Muller code of dimension k,
##  order r; 0 <= r <= k
##
DeclareOperation("ReedMullerCode", [IsInt, IsInt]); 

#############################################################################
##
#F  LexiCode( <M | n>, <d>, <F> )  . . . . .  Greedy code with standard basis
##
DeclareOperation("LexiCode", [IsMatrix,IsInt,IsField]); 

#############################################################################
##
#F  GreedyCode( <M>, <d> [, <F>] )  . . . . Greedy code from list of elements
##
DeclareOperation("GreedyCode", [IsMatrix,IsInt,IsField]);

#############################################################################
##
#F  AlternantCode( <r>, <Y> [, <alpha>], <F> )  . . . . . . .  Alternant code
##
DeclareOperation("AlternantCode", [IsInt, IsList, IsList, IsField]);  

#############################################################################
##
#F  GoppaCode( <G>, <L | n> ) . . . . . . . . . . . . . . . . . .  Goppa code
##
DeclareGlobalFunction("GoppaCode"); 

#############################################################################
##
#F  CordaroWagnerCode( <n> )  . . . . . . . . . . . . . . Cordaro-Wagner code
##
DeclareOperation("CordaroWagnerCode", [IsInt]); 

#############################################################################
##
#F  GeneralizedSrivastavaCode( <a>, <w>, <z> [, <t>] [, <F>] )  . . . . . .  
##
DeclareOperation("GeneralizedSrivastavaCode",[IsList, IsList, IsList, IsInt, IsField]); 

#############################################################################
##
#F  SrivastavaCode( <a>, <w> [, <mu>] [, <F>] ) . . . . . . . Srivastava code
##
DeclareOperation("SrivastavaCode",[IsList, IsList, IsInt, IsField]);

#############################################################################
##
#F  ExtendedBinaryGolayCode( )  . . . . . . . . .  extended binary Golay code
##
DeclareOperation("ExtendedBinaryGolayCode", []); 

#############################################################################
##
#F  ExtendedTernaryGolayCode( ) . . . . . . . . . extended ternary Golay code
##
DeclareOperation("ExtendedTernaryGolayCode", []); 

#############################################################################
##
#F  BestKnownLinearCode( <n>, <k> [, <F>] ) .  returns best known linear code
#F  BestKnownLinearCode( <rec> )
##
DeclareOperation("BestKnownLinearCode", [IsRecord]); 

#############################################################################
##
#F  GeneratorPolCode( <G>, <n> [, <name> ], <F> ) .  code from generator poly
##
DeclareOperation("GeneratorPolCode", 
	[IsUnivariatePolynomial, IsInt, IsString, IsField]);  

#############################################################################
##
#F  CheckPolCode( <H>, <n> [, <name> ], <F> ) . .  code from check polynomial
##
DeclareOperation("CheckPolCode", 
	[IsUnivariatePolynomial, IsInt, IsString, IsField]);  

#############################################################################
##
#F  RepetitionCode( <n> [, <F>] ) . . . . . . . repetition code of length <n>
##
DeclareOperation("RepetitionCode", [IsInt, IsField]); 

#############################################################################
##
#F  WholeSpaceCode( <n> [, <F>] ) . . . . . . . . . . returns <F>^<n> as code
##
DeclareOperation("WholeSpaceCode", [IsInt, IsField]); 

#############################################################################
##
#F  CyclicCodes( <n> )  . .  returns a list of all cyclic codes of length <n>
##
DeclareOperation("CyclicCodes", [IsInt,IsField]); 

#############################################################################
##
#F  NrCyclicCodes( <n>, <F>)  . . .  number of cyclic codes of length <n>
##
DeclareOperation("NrCyclicCodes", [IsInt, IsField]); 

#############################################################################
##
#F  BCHCode( <n> [, <b>], <delta> [, <F>] ) . . . . . . . . . . . .  BCH code
##
DeclareOperation("BCHCode", [IsInt, IsInt, IsInt, IsInt]); 

#############################################################################
##
#F  ReedSolomonCode( <n>, <d> ) . . . . . . . . . . . . . . Reed-Solomon code
##
##  ReedSolomonCode (n, d) returns a primitive narrow sense BCH code with
##  wordlength n, over alphabet q = n+1, designed distance d
DeclareOperation("ReedSolomonCode", [IsInt, IsInt]); 

#############################################################################
##
#F  RootsCode( <n>, <list> )  . . . code constructed from roots of polynomial
##
##  RootsCode (n, rootlist) or RootsCode (n, <powerlist>, F) returns the
##  code with generator polynomial equal to the least common multiplier of
##  the minimal polynomials of the n'th roots of unity in the list.
##  The code has wordlength n
##
DeclareOperation("RootsCode", [IsInt, IsList, IsField]); 

#############################################################################
##
#F  QRCode( <n> [, <F>] ) . . . . . . . . . . . . . .  quadratic residue code
##
DeclareOperation("QRCode", [IsInt, IsInt]); 

#############################################################################
##
#F  NullCode( <n> [, <F>] ) . . . . . . . . . . .  code consiting only of <0>
##
DeclareOperation("NullCode", [IsInt, IsField]); 

#############################################################################
##
#F  FireCode( <G>, <b> )  . . . . . . . . . . . . . . . . . . . . . Fire code
##
##  FireCode (G, b) constructs the Fire code that is capable of correcting any
##  single error burst of length b or less.
##  G is a primitive polynomial of degree m
##
DeclareOperation("FireCode", [IsUnivariatePolynomial, IsInt]); 

#############################################################################
##
#F  BinaryGolayCode( )  . . . . . . . . . . . . . . . . . . binary Golay code
##
DeclareOperation("BinaryGolayCode", []); 

#############################################################################
##
#F  TernaryGolayCode( ) . . . . . . . . . . . . . . . . .  ternary Golay code
##
DeclareOperation("TernaryGolayCode", []); 

#############################################################################
##
#F  EvaluationCode( <P>, <L>, <R> )
##
##   P is a list of n points in F^r
##   L is a list of rational functions in r variables
##   EvaluationCode returns the image of the evaluation map f->[f(P1),...,f(Pn)],
##   as f ranges over the vector space of functions spanned by L.
##   The output is the code whose generator matrix has rows (f(P1)...f(Pn)) where
##   f is in L and P={P1,..,Pn}
##
DeclareOperation("EvaluationCode",[IsList, IsList, IsRing]);

#############################################################################
##
#F  GeneralizedReedSolomonCode( <P>, <k>, <R> )
##
##   P is a list of n points in F
##   k is an integer
##   GRSCode returns the image of the evaluation map f->[f(P1),...,f(Pn)],
##   as f ranges over the vector space of polynomials in 1 variable
##   of degree < k in the ring R. 
##   The output is the code whose generator matrix has rows (f(P1)...f(Pn)) where
##   f = x^j, j<k, and P={P1,..,Pn}
##
DeclareOperation("GeneralizedReedSolomonCode",[IsList, IsInt, IsRing]);

#############################################################################
##
#F  OnePointAGCode( <crv>, <pts>, <m>, <R> )
##
## R = F[x,y] is a polynomial ring over a finite field F
## crv is a polynomial in R representing a plane curve
## pts is a list of points on the curve
## Computes the AG codes associated to the RR space
## L(m*infinity) using Proposition VI.4.1 in Stichtenoth
##
##
DeclareOperation("OnePointAGCode",[IsPolynomial,IsList, IsInt, IsRing]);