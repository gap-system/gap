#############################################################################
##
#W  semirel.gd                  GAP library                   Andrew Solomon
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for equivalence relations on 
##  semigroups. Of particular interest are Green's relations, 
##  congruences, and Rees congruences.
##
Revision.semirel_gd :=
    "@(#)$Id$";

#############################################################################
##
##					GREEN'S RELATIONS                        
##	
##  Here we give functions to work with the Green's relations of 
##  a semigroup.
##	The five green's relations are R, L, J, H, D:
##	two elements <x>, <y> from <S> are R-related if and only if
##  $xS^1 = yS^1$, L-related if and only if $S^1x=S^1y$ and J-related
##  if and only if $S^1xS^1=S^1yS^1$; finally, $H$ is the meet
##  of  $R$ and $L$, and <D = R o L>.
##  Recall that relations R, L and J induce a partial order among
##	the elements of the semigroup: for two elements <x>, <y> from <S>, 
##	we say that <x> is  less than or equal to <y> in the order on <R> 
##	if $xS^1 \subseteq yS^1$;
##  similarly, $x$ is less than or equal to $y$ under $L$ if
##  $S^1x\subseteq S^1y$;
##  finally <x> is less than or equal to <y> under <J> if
##  $S^1xS^1 \subseteq S^1tS^1$.
##  We extend this preorder to a partial order on equivalence classes in
##  the natural way.
##

#############################################################################
## 
#P  IsGreensRelation( <R> )
#P  IsGreensRRelation( <R> )
#P  IsGreensLRelation( <R> )
#P  IsGreensDRelation( <R> )
#P  IsGreensJRelation( <R> )
#P  IsGreensHRelation( <R> )
##
##	returns true if the equivalence relation <R> is one of Green's relations.
##
DeclareProperty("IsGreensRelation", IsEquivalenceRelation );
DeclareProperty("IsGreensRRelation", IsEquivalenceRelation );
DeclareProperty("IsGreensLRelation", IsEquivalenceRelation );
DeclareProperty("IsGreensDRelation", IsEquivalenceRelation );
DeclareProperty("IsGreensJRelation", IsEquivalenceRelation );
DeclareProperty("IsGreensHRelation", IsEquivalenceRelation );

#############################################################################
## 
#P  IsGreensClass( <C> )
#P  IsGreensRClass( <C> )
#P  IsGreensLClass( <C> )
#P  IsGreensDClass( <C> )
#P  IsGreensJClass( <C> )
#P  IsGreensHClass( <C> )
##
##	returns true if the equivalence class <C> arises from one of Green's
##	relations.
##
DeclareProperty("IsGreensClass", IsEquivalenceClass);
DeclareProperty("IsGreensRClass", IsEquivalenceClass);
DeclareProperty("IsGreensLClass", IsEquivalenceClass);
DeclareProperty("IsGreensDClass", IsEquivalenceClass);
DeclareProperty("IsGreensJClass", IsEquivalenceClass);
DeclareProperty("IsGreensHClass", IsEquivalenceClass);

#############################################################################
##
#F  GreensRRelation(<S>)
#F  GreensLRelation(<S>)
#F  GreensDRelation(<S>)
#F  GreensJRelation(<S>)
#F  GreensHRelation(<S>)
##
##	create the Green's relations.
##
DeclareGlobalFunction("GreensRRelation");
DeclareGlobalFunction("GreensLRelation");
DeclareGlobalFunction("GreensDRelation");
DeclareGlobalFunction("GreensJRelation");
DeclareGlobalFunction("GreensHRelation");

#############################################################################
##
#F  GreensRClassOfElement(<S>, <a>)
#F  GreensLClassOfElement(<S>, <a>)
#F  GreensDClassOfElement(<S>, <a>)
#F  GreensJClassOfElement(<S>, <a>)
#F  GreensHClassOfElement(<S>, <a>)
##
##  Creates the <X> class of the element <a> in the semigroup <S>
##  where <X> is one of L, R, D, J or H.
##
##  Note, this checks that <a> in <S>. For more efficiency when 
##  <a> in <S> is known, you could write (for example)
##  EquivalenceClassOfElementNC(GreensRRelation(S),a);
##
DeclareGlobalFunction("GreensRClassOfElement");
DeclareGlobalFunction("GreensLClassOfElement");
DeclareGlobalFunction("GreensDClassOfElement");
DeclareGlobalFunction("GreensJClassOfElement");
DeclareGlobalFunction("GreensHClassOfElement");

#############################################################################
## 
#O  IsGreensLessThanOrEqual( <C1>, <C2> )
##
##	returns true if the greens class <C1> is less than or equal to <C2> 
##	under the respective ordering (as defined above). 
##
DeclareOperation("IsGreensLessThanOrEqual", [IsGreensClass, IsGreensClass]);

#############################################################################
## 
#A  RClassOfHClass( <H> )
#A  LClassOfHClass( <H> )
##
##	are attributes reflecting the natural ordering over the various Green's
##	classes. `RClassOfHClass' and `LClassOfHClass' return the <R> and 
##	<L> classes	respectively in which an <H> class is contained.   
##
DeclareAttribute("RClassOfHClass", IsGreensHClass);
DeclareAttribute("LClassOfHClass", IsGreensHClass);

#############################################################################
##
#A  GreensRClasses( <D> )
#A  GreensLClasses( <D> )
#A  GreensJClasses( <D> )
#A  GreensDClasses( <D> )
#A  GreensHClasses( <D> )
##
##  for  a domain 
##  Return the R, L, J, D, or H classes contained in D.
##  D might be the semigroup itself, or a class, etc
##
DeclareAttribute("GreensRClasses", IsDomain);
DeclareAttribute("GreensLClasses", IsDomain);
DeclareAttribute("GreensJClasses", IsDomain);
DeclareAttribute("GreensDClasses", IsDomain);
DeclareAttribute("GreensHClasses", IsDomain);

############################################################################
##
#A  GroupHClassOfGreensDClass( <D> )
##
##	for a D class of a semigroup.
##	Returns a group H class of the D class. Or fail if there are no
##	group H class
##
DeclareAttribute("GroupHClassOfGreensDClass",IsGreensDClass and IsEquivalenceClass);

#############################################################################
## 
#C  IsGreensRClassEnumerator( <E> )
#C  IsGreensLClassEnumerator( <E> )
#C  IsGreensJClassEnumerator( <E> )
#C  IsGreensHClassEnumerator( <E> )
#C  IsGreensDClassEnumerator( <E> )
##
##	are categories for Enumerators of the five Green's classes.
##
DeclareCategory("IsGreensRClassEnumerator", IsDomainEnumerator);
DeclareCategory("IsGreensLClassEnumerator", IsDomainEnumerator);
DeclareCategory("IsGreensJClassEnumerator", IsDomainEnumerator);
DeclareCategory("IsGreensHClassEnumerator", IsDomainEnumerator);
DeclareCategory("IsGreensDClassEnumerator", IsDomainEnumerator);

#############################################################################
##
#P  IsRegularDClass( <D> )
##
##  returns true if the Greens D class <D> is regular.   A D class is regular
##  if and only if each of its elements is regular, which in turn is true
##  if and only if any one element of <D> is regular.   Since idempotents
##  are clearly regular, we have that a D class is regular if and only if
##  it contains an idempotent.
##
DeclareProperty("IsRegularDClass", IsGreensDClass);


#############################################################################
##
#P  IsGroupHClass( <H> )
##
##  returns true if the Greens H class <H> is a group, which in turn is
##  true if and only if <H>^2 intersects <H>. 
##
DeclareProperty("IsGroupHClass", IsGreensHClass);

#############################################################################
##
#A  EggBoxOfDClass( <D> )
##
##  A matrix whose rows represent R classes and columns represent L classes.
##  The entries are the H classes.
##
DeclareAttribute("EggBoxOfDClass", IsGreensDClass);

#############################################################################
##
#F  DisplayEggBoxOfDClass( <D> )
##
##  A ``picture'' of the D class <D>, as an array of 1s and 0s.
##  A 1 represents a group H class.
##
DeclareGlobalFunction("DisplayEggBoxOfDClass");



#############################################################################
##
#E

