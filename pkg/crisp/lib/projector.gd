#############################################################################
##
##  projector.gd                     CRISP                   Burkhard Höfling
##
##  @(#)$Id: projector.gd,v 1.5 2011/05/15 19:17:57 gap Exp $
##
##  Copyright (C) 2000 Burkhard Höfling
##
Revision.projector_gd :=
    "@(#)$Id: projector.gd,v 1.5 2011/05/15 19:17:57 gap Exp $";


#############################################################################
##
#V  InfoProjector 
##
DeclareInfoClass ("InfoProjector");


#############################################################################
##
#O  Projector (<grp>, <class>)
##
KeyDependentOperation ("Projector", IsGroup, IsGroupClass, ReturnTrue);


#############################################################################
##
#M  CoveringSubgroup (<grp>, <class>)
##
KeyDependentOperation ("CoveringSubgroup", IsGroup, IsGroupClass,
      ReturnTrue);


#############################################################################
##
#O  ProjectorFromExtendedBoundaryFunction (<grp>, <data>, <inonly>) 
##
##  if inonly is false, this computes a projector of <grp> for the 
##  Schunck class described by <data>.
##  if inonly is true, it returns true or false depending whether <grp>
##  belongs to the Schunck class or not.
##
##  See PROJECTOR_FROM_BOUNDARY below for the meaning of <data>.
##
DeclareOperation ("ProjectorFromExtendedBoundaryFunction",
   [IsGroup, IsRecord, IsBool]);


#############################################################################
##
#F  PROJECTOR_FROM_BOUNDARY (<gpcgs>, <data>, <inonly>, <hom>, <conv>)
##
##  <gpcgs> is a pcgs of the group G for which the computation will be 
##  performed.
##
##  If the boolean inonly is true, the function returns true if G belongs to 
##  H, and false otherwise. If inonly is false, it returns the pcgs (an  
##  induced pcgs wrt. gpcgs) of a projector of G. 
##
##  hom and conv are booleans. If hom is true, computations will be carried 
##  out in factor groups, otherwise wrt to modulo pcgs. If hom or conv is  
##  true, computations will take place wrt a pcgs refining an elementary  
##  abelian series of G, otherwise wrt. the pcgs <gpcgs> supplied.
##
##  <data> must contain four components, dfunc, cfunc, kfunc, and bfunc,
##  each bound to a function. The purpose of these functions is as follows.
##
##  - data.dfunc takes four arguments, upcgs, npcgs, p, and data.
##  Here upcgs is a pcgs of the group U and npcgs is a modulo pcgs 
##  induced by upcgs which represents a p-chief factor N/L of U. Moreover, 
##  U/N belongs to the Schunck class H. data is just the argument of
##  PROJECTOR_FROM_BOUNDARY. data.dfunc may return true, false, or fail.
##  data.dfunc may  return true if U/L does not belong to H, and false if 
##  U/L belongs to H. (An example may be to use information on whether 
##  groups in H can have order divisible by p).
## 
##  - data.cfunc takes five arguments, upcgs, npcgs, p, cent, and data.
##  The meaning of the arguments and the purpose of the function is the
##  same as for data.dfunc, except there is one additional information
##  available: the subgroup D of U represented by upcgs{[cent..
##  Length(upcgs)]} centralises npcgs, and if D < U, then there exists a 
##  normal subgroup R of U such that R/D is elementary abelian and R does 
##  not centralise npcgs. (The obvious interpretation is that npcgs is 
##  central iff cent = 1). data.cfunc is only called when data.dfunc has
##  returned fail.
##
##  - data.kfunc has six arguments: upcgs, kpcgs, npcgs, p, cent, and data.
##  Except for kpcgs, the meaning is the same as for cfunc and dfunc.
##  In addition, kpcgs is a pcgs induced from upcgs for a normal subgroup K
##  of U such that K/L is a complement of N/L in D/L. Note that the 
##  existence of K implies that K/L is a complemented chief factor of U/L
##  (see the accompanying article "crisp.dvi" for details). data.kfunc is 
##  only called when cfunc and dfunc have both returned fail, and if K 
##  exists. One possible application is that if H is a local formation
##  defined by a formation function f, then U/L belongs to H if and only if 
##  the f(p)-residual of U centralises N/L.
##
##  - data.bfunc has arguments upcgs, cpcgs, kpcgs, npcgs, p, cent, and 
##              data. Except for cpcgs, they are the same as above. bfunc   
##    U         must either return true or false. it is only called if all 
##   / \        of the above functions have returned fail. cpcgs is a pcgs 
##  C   R       induced from upcgs for a maximal subgroup C of U which 
##   \   \      complements N/L and contains K. In this situation, it is
##    \   D     known that U/Core_U(C) is a primitive group with socle 
##     \ / \    N Core_U(C)/Core_U(C) which is U-isomorphic with N/L; 
##      K   N   moreover Core_U(C) = C_C(N/L) contains K. Also, U/L belongs 
##       \ /    to H if and only if U/Core_U(C) belongs to (the basis of) H, 
##        L     and otherwise U/Core_U(C) is in the boundary of H. Therefore 
##              information about the basis or boundary of H is sufficient 
##              for the test to be performed by bfunc.
##              
##  Note that it is a good idea only to perform cheap tests by data.dfunc and
##  data.cfunc, and leave expensive tests to data.kfunc and data.bfunc, 
##  because in that case, the expensive tests are only carried out if it is 
##  known that N/L is complemented in U. (Otherwise N/L is a Frattini chief 
##  factor, and U/L must belong to H - no further test is required.)
##
DeclareGlobalFunction ("PROJECTOR_FROM_BOUNDARY");


#############################################################################
##
#F  DFUNC_FROM_CHARACTERISTIC (<upcgs>, <npcgs>, <p>, <data>)
##
##  standard function to pass to PcgsProjectorFromExtendedBoundaryFunction
##  as data.dfunc, where the argument data must have a component char 
##  containing the characteristic of the formation. Every prime divisor of 
##  any group in the class must be in the characteristic. 
##
DeclareGlobalFunction ("DFUNC_FROM_CHARACTERISTIC");


#############################################################################
##
#F  DFUNC_FROM_MEMBER_FUNCTION (<upcgs>, <npcgs>, <p>, <data>)
##
##  standard function to pass to PcgsProjectorFromExtendedBoundaryFunction
##  as data.cfunc, where the argument data must have a component memberf 
##  containing a function which decides membership in the Schunck class.
##
DeclareGlobalFunction ("DFUNC_FROM_MEMBER_FUNCTION");


#############################################################################
##
#F  CFUNC_FROM_CHARACTERISTIC (<upcgs>, <npcgs>, <p>, <centind>, <data>)
##
##  standard function to pass to PcgsProjectorFromExtendedBoundaryFunction
##  as data.cfunc, where the argument data must have a component char 
##  containing the characteristic of the class. Every prime divisor of any 
##  group in the class must be in the characteristic. Otherwise 
##  CFUNC_FROM_CHARACTERISTIC_SCHUNCK may be used.
##
DeclareGlobalFunction ("CFUNC_FROM_CHARACTERISTIC");


#############################################################################
##
#F  KFUNC_FROM_LOCAL_DEFINITION (<upcgs>, <kpcgs>, <npcgs>, <p>, 
##     <centind>, <data>)
##
##  standard function to pass to PcgsProjectorFromExtendedBoundaryFunction
##  as data.kfunc. The argument data must have a component lfunc containing
##  a function taking three arguments: a group G, a prime p, and a record r. 
##  It must return a list of elements of G such that the smallest normal 
##  subgroup of G containing them is the f(p)-residual of G, or fail if  
##  f(p) is empty, where f is a local function for the formation for which 
##  the computation should be carried out. The argument data passed to 
##  PcgsProjectorFromExtendedBoundaryFunction will be in r when lfunc is 
##  called.
##
DeclareGlobalFunction ("KFUNC_FROM_LOCAL_DEFINITION");


#############################################################################
##
#F  CFUNC_FROM_CHARACTERISTIC_SCHUNCK (<upcgs>, <npcgs>, <p>, 
##     <centind>, <data>)
##
##  standard function to pass to PcgsProjectorFromExtendedBoundaryFunction
##  as data.dfunc, where the argument data must have a component char 
##  containing the characteristic of the Schunck class 
##
DeclareGlobalFunction ("CFUNC_FROM_CHARACTERISTIC_SCHUNCK");


#############################################################################
##
#F  BFUNC_FROM_TEST_FUNC_FAC (<upcgs>, <cpcgs>, <kpcgs>, <npcgs>, <p>, 
##     <centind>, <data>)
##
##  standard function to pass to PcgsProjectorFromExtendedBoundaryFunction
##  as data.bfunc. The argument data must have a component test containing 
##  a function taking two arguments, a primitive solvable group G such that
##  G/Socle(G) belongs to the Schunck class H in question, and a record r. 
##  data.test must return true if G is in the boundary of the Schunck class 
##  H, and false if it belongs to H.
##
DeclareGlobalFunction ("BFUNC_FROM_TEST_FUNC_FAC");


#############################################################################
##
#F  BFUNC_FROM_TEST_FUNC_MOD (<upcgs>, <cpcgs>, <kpcgs>, <npcgs>, <p>, 
##     <centind>, <data>)
##
##  this is the same as BFUNC_FROM_TEST_FUNC, except that it uses
##  CentralizerModulo to compute the centralizer of a chief factor. 
##
##  In ProjectorOp, we may want to use this function, rather than
##  BFUNC_FROM_TEST_FUNC_FAC because its performance seems to be the
##  same for pc groups, while it might work better for perm groups because
##  one does not have to work in factor groups. 
##
DeclareGlobalFunction ("BFUNC_FROM_TEST_FUNC_MOD");


#############################################################################
##
#F  BFUNC_FROM_TEST_FUNC (<upcgs>, <cpcgs>, <kpcgs>, <npcgs>, <p>, 
##     <centind>, <data>)
##
##  Presently, we only use BFUNC_FROM_TEST_FUNC_FAC because of a bug in 
##  CentralizerModulo in the released version  (4.2 fix 5) of GAP.
##
DeclareSynonym ("BFUNC_FROM_TEST_FUNC", BFUNC_FROM_TEST_FUNC_FAC);


############################################################################
##
#E
##
