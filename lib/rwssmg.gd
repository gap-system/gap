#############################################################################
##
#W  rwssmg.gd           GAP library          										Isabel Araujo
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for semigroups defined by rws.
##
Revision.rwssmg_gd :=
    "@(#)$Id$";


#############################################################################
##
#A  SemigroupOfRewritingSystem( <rws> )
##
##  returns the semigroup over which <rws> is
##  a rewriting system
##
DeclareAttribute("SemigroupOfRewritingSystem",IsRewritingSystem and 
IsBuiltFromSemigroup);


############################################################################
##
#A  ReducedConfluentRewritingSystem( <S> )
#A  ReducedConfluentRewritingSystem( <S> , <lessthanorequal> )
##
##  returns a reduced confluent rewriting system of the finitely presented  semigroup
##  <S> with respect to the lexicorgraphic ordering on words.
##
##  In the second form it returns a reduced confluent rewriting system of the 
##  finitely presented  semigroup <S> with respect to the
##  reduction ordering given by <lessthanorequal>
##  (<lessthanorequal>(<a>,<b>) returns true iff <a> is less than  <b> in the order
##  corresponding to <lessthanorequal>).
##
##  Note that, in this case, the object returned is an immutable 
##  rewriting system. This is so because once we have a confluent
##	rewriting system for a finitely presented semigroup we do not want
##	to allow it to change (it was most probably very time consuming to
##  get it in the first place). Furthermore, this is also
##  an attribute storing object.
##  Also this might not terminate. In particular, if the semigroup
##  <S> does not have a solvable word problem then it this will
##  certainly never end.
##
DeclareAttribute("ReducedConfluentRewritingSystem",IsFpSemigroup);


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
#E

