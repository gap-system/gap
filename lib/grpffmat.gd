#############################################################################
##
#W  grpffmat.gd                 GAP Library                      Frank Celler
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1996,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for matrix groups over finite fields.
##
Revision.grpffmat_gd :=
    "@(#)$Id$";


#############################################################################
##
#C  IsFFEMatrixGroup
##
DeclareSynonym( "IsFFEMatrixGroup", IsFFECollCollColl and IsMatrixGroup );


#############################################################################
##
#M  IsFinite( <ffe-mat-grp> )
##
##  *Note:*  The following implication only holds  if  there are no  infinite
##  dimensional matrices.
##
InstallTrueMethod( IsFinite,
    IsFFEMatrixGroup and IsFinitelyGeneratedGroup );


#############################################################################
##
#F  NicomorphismOfFFEMatrixGroup
##
DeclareGlobalFunction( "NicomorphismOfFFEMatrixGroup" );


#############################################################################
##
#F  ProjectiveActionOnFullSpace( <G>, <F>, <n> )
##
##  Let <G> be a group of <n> by <n> matrices over a field contained in the
##  finite field <F>.
#T why is <n> an argument?
#T (it should be read off from the group!)
##  `ProjectiveActionOnFullSpace' returns the image of the projective action
##  of <G> on the full row space $<F>^<n>$.
##
DeclareGlobalFunction( "ProjectiveActionOnFullSpace" );


#############################################################################
##
#F  ConjugacyClassesOfNaturalGroup 
##
DeclareGlobalFunction( "ConjugacyClassesOfNaturalGroup" );


#############################################################################
##
#F  Phi2( <n> ) . . . . . . . . . . . .  Modification of Euler's Phi function
##
##  This is needed for the computation of the class numbers of SL(n,q),
##  PSL(n,q), SU(n,q) and PSU(n,q)
##
DeclareGlobalFunction("Phi2");

#############################################################################
##
#F  NrConjugacyClassesGL( <n>, <q> ) . . . . . . . . Class number for GL(n,q)
#F  NrConjugacyClassesGU( <n>, <q> ) . . . . . . . . Class number for GU(n,q)
#F  NrConjugacyClassesSL( <n>, <q> ) . . . . . . . . Class number for SL(n,q)
#F  NrConjugacyClassesSU( <n>, <q> ) . . . . . . . . Class number for SU(n,q)
#F  NrConjugacyClassesPGL( <n>, <q> ) . . . . . . .  Class number for PGL(n,q)
#F  NrConjugacyClassesPGU( <n>, <q> ) . . . . . . .  Class number for PGU(n,q)
#F  NrConjugacyClassesPSL( <n>, <q> ) . . . . . . .  Class number for PSL(n,q)
#F  NrConjugacyClassesPSU( <n>, <q> ) . . . . . . .  Class number for PSU(n,q)
#F  NrConjugacyClassesSLIsogeneous( <n>, <q>, <f> ) . . for SL(n,q) isogeneous
#F  NrConjugacyClassesSUIsogeneous( <n>, <q>, <f> ) . . for SU(n,q) isogeneous
##
##  The first of  these functions compute for given $<n>  \in N$ and prime
##  power $<q>$  the number of  conjugacy classes in the  classical groups
##  $GL( <n>, <q>  )$, $GU( <n>, <q>  )$, $SL( <n>, <q> )$,  $SU( <n>, <q>
##  )$, $PGL(  <n>, <q> )$,  $PGU( <n>, <q> )$,  $PSL( <n>, <q>  )$, $PSL(
##  <n>, <q> )$, respectively. (See also "ConjugacyClasses!attribute"  and
##  Section~"Classical Groups".)
##  
##  For  each  divisor  $<f>$ of  $<n>$  there  is  a  group of  Lie  type
##  with  the same  order  as $SL(  <n>,  <q> )$,  such  that its  derived
##  subgroup  modulo  its center  is  isomorphic  to  $PSL( <n>,  <q>  )$.
##  The  various  such  groups  with  fixed $<n>$  and  $<q>$  are  called
##  *isogeneous*. (Depending  on congruence conditions on  $<q>$ and $<n>$
##  several of  these groups  may actually  be isomorphic.)  The  function
##  `NrConjugacyClassesSLIsogeneous'  computes  the  number  of  conjugacy
##  classes in this group. The extreme cases  $<f> = 1$ and $<f> = n$ lead
##  to the groups $SL( <n>, <q> )$ and $PGL( <n>, <q> )$, respectively.
## 
##  The function `NrConjugacyClassesSUIsogeneous' is the analogous one for
##  the corresponding unitary groups.
##  
##  The  formulae   for  the  number   of  conjugacy  classes   are  taken
##  from~\cite{Mac81}.
##  
DeclareGlobalFunction("NrConjugacyClassesGL");
DeclareGlobalFunction("NrConjugacyClassesGU");
DeclareGlobalFunction("NrConjugacyClassesSL");
DeclareGlobalFunction("NrConjugacyClassesSU");
DeclareGlobalFunction("NrConjugacyClassesPGL");
DeclareGlobalFunction("NrConjugacyClassesPGU");
DeclareGlobalFunction("NrConjugacyClassesPSL");
DeclareGlobalFunction("NrConjugacyClassesPSU");
DeclareGlobalFunction("NrConjugacyClassesSLIsogeneous");
DeclareGlobalFunction("NrConjugacyClassesSUIsogeneous");


#############################################################################
##
#E

