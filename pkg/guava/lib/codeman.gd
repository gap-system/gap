#############################################################################
##
#A  codeman.gd              GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains functions for manipulating codes
##
#H  @(#)$Id: codeman.gd,v 1.5 2004/12/20 21:26:06 gap Exp $
##
Revision.("guava/lib/codeman_gd") :=
    "@(#)$Id: codeman.gd,v 1.5 2004/12/20 21:26:06 gap Exp $";

#############################################################################
##
#F  DualCode( <C> ) . . . . . . . . . . . . . . . . . . . .  dual code of <C>
##
DeclareOperation("DualCode", [IsCode]); 

#############################################################################
##
#F  AugmentedCode( <C> [, <L>] )  . . .  add words to generator matrix of <C>
##
DeclareOperation("AugmentedCode", [IsCode, IsObject]); 

#############################################################################
##
#F  EvenWeightSubcode( <C> )  . . .  code of all even-weight codewords of <C>
##
DeclareOperation("EvenWeightSubcode", [IsCode]); 

#############################################################################
##
#F  ConstantWeightSubcode( <C> [, <w>] )  .  all words of <C> with weight <w>
##
DeclareOperation("ConstantWeightSubcode", [IsCode, IsInt]);  

#############################################################################
##
#F  ExtendedCode( <C> [, <i>] ) . . . . . code with added parity check symbol
##
DeclareOperation("ExtendedCode", [IsCode, IsInt]); 

#############################################################################
##
#F  ShortenedCode( <C> [, <L>] )  . . . . . . . . . . . . . .  shortened code
##
DeclareOperation("ShortenedCode", [IsCode, IsList]);  

#############################################################################
##
#F  PuncturedCode( <C> [, <list>] ) . . . . . . . . . . . . .  punctured code
##
##  PuncturedCode(C [, remlist]) punctures a code by leaving out the
##  coordinates given in list remlist. If remlist is omitted, then
##  the last coordinate will be removed.
##
DeclareOperation("PuncturedCode", [IsCode, IsList]); 

#############################################################################
##
#F  ExpurgatedCode( <C>, <L> )  . . . . .  removes codewords in <L> from code
##
##  The usual way of expurgating a code is removing all words of odd weight.
##
DeclareOperation("ExpurgatedCode", [IsCode, IsList]); 

#############################################################################
##
#F  AddedElementsCode( <C>, <L> ) . . . . . . . . . .  adds words in list <L>
##
DeclareOperation("AddedElementsCode", [IsCode, IsList]); 

#############################################################################
##
#F  RemovedElementsCode( <C>, <L> ) . . . . . . . . removes words in list <L>
##
DeclareOperation("RemovedElementsCode", [IsCode, IsList]);  

#############################################################################
##
#F  LengthenedCode( <C> [, <i>] ) . . . . . . . . . . . . . .  lengthens code
##
DeclareOperation("LengthenedCode", [IsCode, IsInt]); 

#############################################################################
##
#F  ResidueCode( <C> [, <w>] )  . .  takes residue of <C> with respect to <w>
##
##  If w is omitted, a word from C of minimal weight is used
##
DeclareOperation("ResidueCode", [IsCode, IsCodeword]); 

#############################################################################
##
#F  ConstructionBCode( <C> )  . . . . . . . . . . .  code from construction B
##
##  Construction B (See M&S, Ch. 18, P. 9) assumes that the check matrix has
##  a first row of weight d' (the dual distance of C). The new code has a
##  check matrix equal to this matrix, but with columns removed where the
##  first row is 1.
##
DeclareOperation("ConstructionBCode", [IsCode]); 

#############################################################################
##
#F  PermutedCode( <C>, <P> )  . . . . . . . permutes coordinates of codewords
##
DeclareOperation("PermutedCode", [IsCode, IsPerm]); 

#############################################################################
##
#F  StandardFormCode( <C> ) . . . . . . . . . . . . standard form of code <C>
##
DeclareOperation("StandardFormCode", [IsCode]); 

#############################################################################
##
#F  ConversionFieldCode( <C> )  . . . . . converts code from GF(q^m) to GF(q)
##
DeclareOperation("ConversionFieldCode", [IsCode]); 

#############################################################################
##
#F  CosetCode( <C>, <f> ) . . . . . . . . . . . . . . . . . . .  coset of <C>
##
DeclareOperation("CosetCode", [IsCode, IsCodeword]); 

#############################################################################
##
#F  DirectSumCode( <C1>, <C2> ) . . . . . . . . . . . . . . . . .  direct sum
##
##  DirectSumCode(C1, C2) creates a (n1 + n2 , M1 M2 , min{d1 , d2} ) code
##  by adding each codeword of the second code to all the codewords of the
##  first code.
##
DeclareOperation("DirectSumCode", [IsCode, IsCode]); 

#############################################################################
##
#F  ConcatenationCode( <C1>, <C2> ) . . . . .  concatenation of <C1> and <C2>
##
DeclareOperation("ConcatenationCode", [IsCode, IsCode]); 

#############################################################################
##
#F  DirectProductCode( <C1>, <C2> ) . . . . . . . . . . . . .  direct product
##
##  DirectProductCode constructs a new code from the direct product of two
##  codes by taking the Kronecker product of the two generator matrices
##
DeclareOperation("DirectProductCode", [IsCode, IsCode]); 

#############################################################################
##
#F  UUVCode( <C1>, <C2> ) . . . . . . . . . . . . . . .  u | u+v construction
##
##  Uuvcode(C1, C2) # creates a ( 2n , M1 M2 , d = min{2 d1 , d2} ) code
##  with codewords  (u | u + v) for all u in C1 and v in C2
##
DeclareOperation("UUVCode", [IsCode, IsCode]);  

#############################################################################
##
#F  UnionCode( <C1>, <C2> ) . . . . . . . . . . . . .  union of <C1> and <C2>
##
DeclareOperation("UnionCode", [IsCode, IsCode]); 

#############################################################################
##
#F  IntersectionCode( <C1>, <C2> )  . . . . . . intersection of <C1> and <C2>
## 
DeclareOperation("IntersectionCode", [IsCode, IsCode]); 


