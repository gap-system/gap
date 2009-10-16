#############################################################################
##
#W  fpcomsmg.gd           COMMSEMI library   Isabel Araujo and Andrew Solomon
##
#H  @(#)$Id: fpcomsmg.gd,v 1.3 2000/06/01 15:43:59 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  
##
Revision.fpcomsmg_gd :=
    "@(#)$Id: fpcomsmg.gd,v 1.3 2000/06/01 15:43:59 gap Exp $";


############################################################################
##
#F  AssocWordToVector(<w>)
##  
##  for an associative word <w>. 
##  Returns the vector of exponents of each generator in <word>.
##
DeclareGlobalFunction("AssocWordToVector");

############################################################################
##
#F  ElementOfFpSemigroupAsVector(<e>)
##  
##  for an element <e> of a finitely presented semigroup. 
##  Returns the vector of exponents of the underlying word.
##
DeclareGlobalFunction("ElementOfFpSemigroupAsVector");

############################################################################
##
#F  ElementOfFpMonoidAsVector(<e>)
##  
##  for an element <e> of a finitely presented monoid. 
##  Returns the vector of exponents of the underlying word.
##
DeclareGlobalFunction("ElementOfFpMonoidAsVector");

############################################################################
##
#F  VectorToElementOfCommutativeFpSemigroup(<S>,<v>)
##  
##  for a commutative semigroup <S> and a vector <v>. Returns the
##  element of <S> which has as underlying word the product
##  of the free generators with the exponents the entries of the vector.
##
DeclareGlobalFunction("VectorToElementOfCommutativeFpSemigroup");

########################################################################
##
#F  VectorToElementOfCommutativeFpMonoid(<S>,<v>)
##  
##  for a commutative semigroup <S> and a vector <v>. Returns the
##  element of <S> which has as underlying word the product
##  of the free generators with the exponents the entries of the vector.
##
DeclareGlobalFunction("VectorToElementOfCommutativeFpMonoid");

############################################################################
##
#F  SizeOfFpCommutativeSemigroupOrMonoid(<S>)
##  
##  for a finitely presented commutative semigroup <S>.
##
DeclareGlobalFunction("SizeOfFpCommutativeSemigroupOrMonoid");

#############################################################################
##
#A  EpimorphismAbelianization(<S>)
##
##  returns an epimorphism from an fp semigroup to its abelianization.
##
DeclareAttribute("EpimorphismAbelianization", IsSemigroup);

#############################################################################
##
#A  Abelianization(<S>)
##
##  returns the abelianization of the finitely presented semigroup <S>.
##
DeclareAttribute("Abelianization", IsSemigroup);

############################################################################
##
#F  VectorOfSupOfEntriesOfElementsOfCommutativeFpSemigroupOrFpMonoid(<S>) 
##
##  for a commutative finitely presented semigroup <S> and a vector <v>.
##  Returns fail if the semigroup is infinite. Otherwise returns a
##  vector, each entry of which is the minimum exponent to
##  which the corresponding generator has to be raised to get a non-reduced
##  word.
##  Note that, when <S> is finite, this gives an upper
##  bound for the number of elements of <S> (since any element
##  of <S> is represented by a reduced word and any reduced word has
##  to be represented as a vector with entries less than the ones
##  of the vector returned by this function).
##
DeclareGlobalFunction(
    "VectorOfSupOfEntriesOfElementsOfCommutativeFpSemigroupOrFpMonoid");

#############################################################################
##
#E  fpcomsmg.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
