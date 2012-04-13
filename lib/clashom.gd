#############################################################################
##
#W  clashom.gd                  GAP library                  Alexander Hulpke
##
##
#Y  (C) 1999 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains functions that compute the conjugacy classes of a
##  finite group by homomorphic images.
##  Literature: A.H: Conjugacy classes in finite permutation groups via
##  homomorphic images, MathComp, to appear.
##

#############################################################################
##
#V  InfoHomClass
##
##  the info class for the conjugacy class computation via homomorphic
##  images.
DeclareInfoClass("InfoHomClass");

#############################################################################
##
#F  ConjugacyClassesSubwreath(<F>,<M>,<n>,<autT>,<T>,<Lloc>,<comp>,<emb>,<proj>)
##
##  This function computes the classes of a subwreath groiup. The interface
##  is quite technical because the subwreath decomposition is passed already
##  with it: <F> is the factor group, <FM> the normal subgroup in it (direct
##  product of the <n> groups isomorphic <T>). <T> is one of these and
##  <autT> the action of <FM> on the first component, the components are
##  given in <comp>, <emb> and <proj> are embeddings and projectios for the
##  direct product.
DeclareGlobalFunction("ConjugacyClassesSubwreath");

#############################################################################
##
#F  ConjugacyClassesFittingFreeGroup(<G>)
##
##  computes the classes of a group <G> which has no solvable normal
##  subgroups. It returns a list whose entries are of the form
##  [<rep>,<centralizer>].
DeclareGlobalFunction("ConjugacyClassesFittingFreeGroup");

#############################################################################
##
#F  ConjugacyClassesViaRadical(<G>)
##
##  computes the classes of a group <G> by lifting the classes of G/Rad(G)
##  using affine actions. It returns a list of conjugacy classes.
DeclareGlobalFunction("ConjugacyClassesViaRadical");

#############################################################################
##
#E  clashom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
