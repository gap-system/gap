#############################################################################
##
#W  rwssmg.gd           GAP library                             Isabel Araujo
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the declarations for semigroups defined by rws.
##
Revision.rwssmg_gd :=
    "@(#)$Id$";


############################################################################
##
#A  ReducedConfluentRewritingSystem( <S> )
#A  ReducedConfluentRewritingSystem( <S> , <ordering> )
##
##  in the first form returns a reduced confluent rewriting system 
##  of the finitely presented semigroup or monoid <S> with respect 
##  to the length plus lexicographic ordering on words (also
##  called the shortlex ordering; for the definition see for example
##  Sims \cite{Sims94}).
##
##  In the second form it returns a reduced confluent rewriting system of
##  the finitely presented semigroup or monoid <S> with respect to the 
##  reduction ordering <ordering> (see "Orderings"). 
##
##  Notice that this might not terminate. In particular, if the semigroup or 
##  monoid <S> does not have a solvable word problem then it this will
##  certainly never end.
##  Also, in this case, the object returned is an immutable 
##  rewriting system, because once we have a confluent
##  rewriting system for a finitely presented semigroup or monoid we do 
##  not want to allow it to change (as it was most probably very time 
##  consuming to get it in the first place). Furthermore, this is also
##  an attribute storing object (see "Representation").
##
DeclareAttribute("ReducedConfluentRewritingSystem",IsSemigroup);

#############################################################################
##
#A  FreeMonoidOfRewritingSystem(<rws>)
##
##  returns the free monoid over which <rws> is
##  a rewriting system
##
DeclareAttribute("FreeMonoidOfRewritingSystem",
  IsRewritingSystem);

#############################################################################
##
#A  FamilyForRewritingSystem(<rws>)
##
##  returns the family of words over which <rws> is
##  a rewriting system
##
DeclareAttribute("FamilyForRewritingSystem",
  IsRewritingSystem);


#############################################################################
##
#A  FreeSemigroupOfRewritingSystem(<rws>)
##
##  returns the free semigroup over which <rws> is
##  a rewriting system
##
DeclareAttribute("FreeSemigroupOfRewritingSystem",
  IsRewritingSystem);

#############################################################################
##
#F  ReduceLetterRepWordsRewSys(<tzrules>,<w>)
##
##  Here <w> is  a  word  of  a  free  monoid  or  a  free  semigroup  in  tz
##  represenattion, and  <tzrules>  are  rules  in  tz  representation.  This
##  function returns the reduced word in tz representation.
##
##  All lists in <tzrules> as well as <w> must be plain lists, the entries
##  must be small integers. (The behaviour otherwise is unpredictable.)
##
DeclareGlobalFunction("ReduceLetterRepWordsRewSys");


#############################################################################
##
#E

