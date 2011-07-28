#############################################################################
##
##  compl.gd                         CRISP                   Burkhard Höfling
##
##  @(#)$Id: compl.gd,v 1.6 2011/05/15 19:17:52 gap Exp $
##
##  Copyright (C) 2000, 2002 Burkhard Höfling
##
Revision.compl_gi :=
    "@(#)$Id: compl.gd,v 1.6 2011/05/15 19:17:52 gap Exp $";


#############################################################################
##
#F  PcgsComplementOfChiefFactor (<pcgs>, <hpcgs>, <first>, <npcgs>, <kpcgs>)
##
##  The arguments of PcgsComplementOfChiefFactor represent the following 
##            situation. Let H be a group, K < N < R, such that N/K is a
##    H       p-chief factor of H, and R is a normal subgroup of H which does   
##   : \      not centralise H/K, and such that R/N is elementary abelian 
##  ?   R     of exponent q (<> p). 
##   : / \       
##    Q   N   hpcgs is a pc sequence (i.e, a list of elements forming a pcgs,  
##     \ /    but not necessarily a modulo pcgs) representing the factor  
##      K     group H/N, such that hpcgs{[first..Length (hpcgs)]} represents 
##            R/N. npcgs is a modulo pcgs representing N/K. kpcgs is a pc 
##  sequence which generates K. All pc sequences and pcgses above must be  
##  induced with respect to pcgs, that is, the depths wrt. pcgs of their  
##  elements must be strictly increasing. Moreover, the depths (wrt pcgs) of   
##  the elementsin kpcgs must be strictly larger than the depths of the  
##  elements in hpcgs.
##
##  PcgsComplementOfChiefFactor returns a pcgs (induced wrt pcgs) for a
##  complement C of N/K in H. C is computed as the normaliser of Q, where
##  Q/K is a Sylow q-subgroup of R/K, which will be computed in the course
##  of the algorithm.
##
DeclareGlobalFunction ("PcgsComplementOfChiefFactor");


#############################################################################
##
#F  COMPLEMENT_SOLUTION_FUNCTION
##
##  function used to compute a particular invariant complement 
DeclareGlobalFunction ("COMPLEMENT_SOLUTION_FUNCTION");


#############################################################################
##
#F  ExtendedPcgsComplementsOfCentralModuloPcgsUnderAction (
##      <act>, <pcgs>, <gpcgs>, <npcgs>, <kpcgs>, <all>)
##
##  Let G be a group and <act> a set which acts on G via the caret operator.
##  Moreover, let N and K be normal subgroups of G which are invariant under
##  <act>, and assume that N/K is central in G. if <all> is true, 
##  ExtendedPcgsComplementsOfCentralModuloPcgsUnderAction computes the set
##  of all normal subgroups C of G such that C/K complements N/K in G/K.
##  If <all> is false, only one such complement is computed.
##
##  <pcgs> is the pcgs wrt. to which all computations are carried out. 
##  <gpcgs> and <npcgs> are modulo pcgs of G/N and N/K, respectively,
##  induced by <pcgs>, and <kpcgs> is a pcgs of K induced by <pcgs>.
##
##  ExtendedPcgsComplementsOfCentralModuloPcgsUnderAction returns a
##  record <rec> with components nrSolutions and solutionFunction.
##  Each call <rec>.solutionFunction (<rec>, n) with an integer n
##  with 1 <= n <= <rec>.nrSolutions gives the pcgs (induced wrt. to
##  <pcgs>) of one possible subgroup C.
##
DeclareGlobalFunction ("ExtendedPcgsComplementsOfCentralModuloPcgsUnderAction");


#############################################################################
##
#F  PcgsInvariantComplementsOfElAbModuloPcgs (
##      <act>, <numpcgs>, <pcgs>, <mpcgs>, <denpcgs>, <all>)
##
##  computes invariant complements of the elementary abelian section 
##  N/L in G/L which are invariant under act.
##  N/L is represented by the modulo pcgs <mpcgs>, G/N is in <pcgs>,
##  G is in <numpcgs>, <L> is in <denpcgs>.
##  If all is true, all such complements are computed, otherwise just one.
##  If no complement exists, an empty list is returned.
##
DeclareGlobalFunction ("PcgsInvariantComplementsOfElAbModuloPcgs"); 
   

#############################################################################
##
#F  PcgsComplementsOfCentralModuloPcgsUnderActionNC (<act>,<pcgs>, <mpcgs>,<all>)
##
##  similar to PcgsInvariantComplementsOfElAbModuloPcgs, except that it
##  presumes that pcgs centralises mpcgs (and will probably produce an
##  error if not).
##  
DeclareGlobalFunction ("PcgsComplementsOfCentralModuloPcgsUnderActionNC");
#   [IsListOrCollection, IsModuloPcgs, IsModuloPcgs, IsBool]);
   
   
#############################################################################
##
#O  InvariantComplementsOfElAbSection (<act>,<G>,<N>,<L>,<all>)
##
##  computes complements of N/L in G/L which are invariant under act.
##  act can be a collection of elements of a supergroup of G, or a collection 
##  of automorphisms of G which must fix G, L, N; however this is not checked. 
##  If all is true, all such complements are computed, otherwise just one.
##  If no complement exists, or if N/L is not central in G/L, an empty 
##  list is returned if all is true, and fail is returned if all is false.
##
DeclareOperation ("InvariantComplementsOfElAbSection", 
   [IsListOrCollection, IsGroup, IsGroup, IsGroup, IsBool]);

#############################################################################
##
#F  ComplementsOfCentralSectionUnderAction (<act>,<G>,<N>,<L>,<all>)
#O  ComplementsOfCentralSectionUnderActionNC (<act>,<G>,<N>,<L>,<all>)
##
##  similar to ComplementsOfElAbSectionUnderAction; however G is expected
##  to act centrally on N/L. ComplementsOfCentralSectionUnderActionNC
##  does not check this.
##
DeclareGlobalFunction ("ComplementsOfCentralSectionUnderAction");
   
DeclareOperation ("ComplementsOfCentralSectionUnderActionNC", 
   [IsListOrCollection, IsGroup, IsGroup, IsGroup, IsBool]);

   
#############################################################################
##
#F  ComplementsMaximalUnderAction (<act>, <ser>, <i>, <j>, <k>, <all>) 
## 
##  computes subgroups C of ser[i] such that C/ser[k] is a act-invariant 
##  complement of ser[j]/ser[k] in ser[i]/ser[k], where i <= j <= k.
##  
##  ser[k]/ser[k] < ser[k-1]/ser[k] < ... < ser[i]/ser[k] 
##  must be a act-composition series of ser[i]/ser[k]. act must induce
##  all inner automorphisms on ser[i].
##
##  If all is true, it returns a list containing all such C.
##  Otherwise it returns one C if it exists, or fail if no such C exists. 
##
DeclareGlobalFunction ("ComplementsMaximalUnderAction");


#############################################################################
##
#F  PcgsComplementsMaximalUnderAction (<act>, <U>, <ser>,  <j>, <k>, <all>) 
## 
##  does the nontrivial work for ComplementsMaximalUnderAction above
##
DeclareGlobalFunction ("PcgsComplementsMaximalUnderAction");


############################################################################
##
#E
##
