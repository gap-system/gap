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
##  GREEN'S RELATIONS                        
#1	
##  Green's equivalence relations play a very important role in semigroup
##  theory. In this section we describe how they can be used in {\GAP}.
##  
##  The five Green's relations are <R>, <L>, <J>, <H>, <D>:
##  two elements <x>, <y> from <S> are <R>-related if and only if
##  $xS^1 = yS^1$, <L>-related if and only if $S^1x=S^1y$ and <J>-related
##  if and only if $S^1xS^1=S^1yS^1$; finally, $H = R \wedge L$, and
##  $D = R \circ L$.
##  
##  Recall that relations <R>, <L> and <J> induce a partial order among
##  the elements of the semigroup: for two elements <x>, <y> from <S>,
##  we say that <x> is  less than or equal to <y> in the order on <R>
##  if $xS^1 \subseteq yS^1$;
##  similarly, $x$ is less than or equal to $y$ under $L$ if
##  $S^1x\subseteq S^1y$;
##  finally <x> is less than or equal to <y> under <J> if
##  $S^1xS^1 \subseteq S^1tS^1$.
##  We extend this preorder to a partial order on equivalence classes in
##  the natural way.
##

#############################################################################
##  
#P  IsGreensRelation(<equiv-relation>)
#P  IsGreensRRelation(<equiv-relation>)
#P  IsGreensLRelation(<equiv-relation>)
#P  IsGreensJRelation(<equiv-relation>)
#P  IsGreensHRelation(<equiv-relation>)
#P  IsGreensDRelation(<equiv-relation>)
##
##  return `true' if the equivalence relation <equiv-relation> is
##  a Green's relation of any type, or of <R>, <L>, <J>, <H>, <D> type,
##  respectively, or `false' otherwise.
##
DeclareProperty("IsGreensRelation", IsEquivalenceRelation);
DeclareProperty("IsGreensRRelation", IsEquivalenceRelation);
DeclareProperty("IsGreensLRelation", IsEquivalenceRelation);
DeclareProperty("IsGreensJRelation", IsEquivalenceRelation);
DeclareProperty( "IsGreensHRelation", IsEquivalenceRelation);
DeclareProperty( "IsGreensDRelation", IsEquivalenceRelation);

#############################################################################
##  
#A  AssociatedSemigroup(<equiv-relation>) . . . . .  for equivalence relation
##
##  Add a new attribute to an equivalence relation so that it
##  knows what semigroup it is associated with. 
## 
DeclareAttribute("AssociatedSemigroup", IsEquivalenceRelation);

#############################################################################
##
#P  IsGreensClass(<equiv-class>)
#P  IsGreensRClass(<equiv-class>)
#P  IsGreensLClass(<equiv-class>)
#P  IsGreensJClass(<equiv-class>)
#P  IsGreensHClass(<equiv-class>)
#P  IsGreensDClass(<equiv-class>)
##
##  return `true' if the equivalence class <equiv-class> is
##  a Green's class of any type, or of <R>, <L>, <J>, <H>, <D> type,
##  respectively, or `false' otherwise.
##
DeclareProperty("IsGreensClass", IsEquivalenceClass);
DeclareProperty("IsGreensRClass", IsEquivalenceClass);
DeclareProperty("IsGreensLClass", IsEquivalenceClass);
DeclareProperty("IsGreensJClass", IsEquivalenceClass);
DeclareProperty("IsGreensHClass", IsEquivalenceClass);
DeclareProperty("IsGreensDClass", IsEquivalenceClass);

#############################################################################
##
#A  AssociatedSemigroup(<greens-class>) . . . . . . . . .   for Green's class
##
##  A greens class needs what semigroup it is associated with
##
DeclareAttribute("AssociatedSemigroup", IsGreensClass);

#############################################################################
##
#A  InternalRepresentative(<greens class>)
##
##  The internal representation of the Green's class might be different
##  than a collection elements of the semigroup.
##
DeclareAttribute("InternalRepresentative", IsGreensClass);


#############################################################################
##
#A  GreensRRelation(<semigroup>)
#A  GreensLRelation(<semigroup>)
#A  GreensJRelation(<semigroup>)
#A  GreensDRelation(<semigroup>)
#A  GreensHRelation(<semigroup>)
##
##  The Green's relations (which are equivalence relations)
##  are attributes of the semigroup <semigroup>.
##
DeclareAttribute("GreensRRelation", IsSemigroup);
DeclareAttribute("GreensLRelation", IsSemigroup);
DeclareAttribute("GreensJRelation", IsSemigroup);
DeclareAttribute("GreensDRelation", IsSemigroup);
DeclareAttribute("GreensHRelation", IsSemigroup);

#############################################################################
##
#O  GreensRClasses(<semigroup>)
#O  GreensLClasses(<semigroup>)
#O  GreensJClasses(<semigroup>)
#O  GreensDClasses(<semigroup>)
#O  GreensHClasses(<semigroup>)
##
##  return the <R>, <L>, <J>, <H>, or <D> Green's classes, respectively for
##  semigroup <semigroup>. 
##
DeclareOperation("GreensRClasses", [IsSemigroup]);
DeclareOperation("GreensLClasses", [IsSemigroup]);
DeclareOperation("GreensJClasses", [IsSemigroup]);
DeclareOperation("GreensDClasses", [IsSemigroup]);
DeclareOperation("GreensHClasses", [IsSemigroup]);

#############################################################################
##
#O  GreensRClassOfElement(<S>, <a>)
#O  GreensLClassOfElement(<S>, <a>)
#O  GreensDClassOfElement(<S>, <a>)
#O  GreensJClassOfElement(<S>, <a>)
#O  GreensHClassOfElement(<S>, <a>)
##
##  Creates the <X> class of the element <a> in the semigroup <S>
##  where <X> is one of L, R, D, J or H.
##
DeclareOperation("GreensRClassOfElement", [IsSemigroup, IsObject]);
DeclareOperation("GreensLClassOfElement", [IsSemigroup, IsObject]);
DeclareOperation("GreensDClassOfElement", [IsSemigroup, IsObject]);
DeclareOperation("GreensJClassOfElement", [IsSemigroup, IsObject]);
DeclareOperation("GreensHClassOfElement", [IsSemigroup, IsObject]);

#############################################################################
## 
#O  IsGreensLessThanOrEqual( <C1>, <C2> )
##
##  returns `true' if the greens class <C1> is less than or equal to <C2> 
##  under the respective ordering (as defined above), and `false' otherwise. 
##
##  Only defined for R, L and J classes.
##
DeclareOperation("IsGreensLessThanOrEqual", [IsGreensClass, IsGreensClass]);

#############################################################################
## 
#A  RClassOfHClass( <H> )
#A  LClassOfHClass( <H> )
##
##  are attributes reflecting the natural ordering over the various Green's
##  classes. `RClassOfHClass' and `LClassOfHClass' return the <R> and 
##  <L> classes	respectively in which an <H> class is contained.   
##
DeclareAttribute("RClassOfHClass", IsGreensHClass);
DeclareAttribute("LClassOfHClass", IsGreensHClass);

############################################################################
##
#A  GroupHClassOfGreensDClass( <Dclass> )
##
##  for a D class <Dclass> of a semigroup,
##  returns a group H class of the D class, or `fail' if there is no
##  group H class.
##
DeclareAttribute("GroupHClassOfGreensDClass",IsGreensDClass);

#############################################################################
##
#P  IsRegularDClass( <Dclass> )
##
##  returns `true' if the Greens D class <Dclass> is regular. A  D  class  is
##  regular if and only if each of its elements is regular, which in turn  is
##  true if and only if any one element of <Dclass> is  regular.  Idempotents
##  are regular since $eee=e$ so it follows that a Greens D class  containing
##  an idempotent is regular. Conversely, it is true that a regular  D  class
##  must contain at least one idempotent. (See~\cite{Howie76}, Prop.~3.2).
##
DeclareProperty("IsRegularDClass", IsGreensDClass);

#############################################################################
##
#P  IsGroupHClass( <Hclass> )
##
##  returns `true' if the Greens H class <Hclass> is a group, which  in  turn
##  is true if and only if <Hclass>^2 intersects <Hclass>.
##
DeclareProperty("IsGroupHClass", IsGreensHClass);

#############################################################################
##
#A  EggBoxOfDClass( <Dclass> )
##
##  returns for a Green's D class <Dclass> a matrix whose  rows  represent  R
##  classes and columns represent L classes. The entries are the H classes.
##
DeclareAttribute("EggBoxOfDClass", IsGreensDClass);

#############################################################################
##
#F  DisplayEggBoxOfDClass( <Dclass> )
##
##  displays a ``picture'' of the D class <Dclass>, as an array of 1s and 0s.
##  A 1 represents a group H class.
##
DeclareGlobalFunction("DisplayEggBoxOfDClass");

#############################################################################
##
#E semirel.gd 
