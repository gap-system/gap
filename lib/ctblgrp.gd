#############################################################################
##
#W  ctblgrp.gd                   GAP library                 Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C) 1997
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for the Dixon-Schneider algorithm
##
Revision.ctblgrp_gd :=
    "@(#)$Id$";


#############################################################################
##
#1
##  The {\GAP} library implementation of the Dixon-Schneider algorithm
##  first computes the linear characters, using the commutator factor group.
##  If irreducible characters are missing afterwards,
##  they are computed using the techniques described in~\cite{Dix67},
##  \cite{Sch90} and \cite{Hulpke93}.
##
##  Called with a group $G$, the function `CharacterTable'
##  (see~"CharacterTable") returns a character table object that stores
##  already information such as class lengths, but not the irreducible
##  characters.
##  The routines that compute the irreducibles may use the information that
##  is already contained in this table object.
##  In particular the ordering of classes in the computed characters
##  coincides with the ordering of classes in the character table of <G>
##  (see~"The Interface between Character Tables and Groups").
##  Thus it is possible to combine computations using the group
##  with character theoretic computations
##  (see~"Advanced Methods for Dixon-Schneider Calculations" for details),
##  for example one can enter known characters.
##  Note that the user is responsible for the correctness of the characters.
##  (There is little use in providing the trivial character to the routine.)
##
##  The computation of irreducible characters from the group needs to
##  identify the classes of group elements very often,
##  so it can be helpful to store a class list of all group elements.
##  Since this is obviously limited by the group order,
##  it is controlled by the global function `IsDxLargeGroup'
##  (see~"IsDxLargeGroup").
##
##  The routines compute in a prime field of size $p$,
##  such that the exponent of the group divides $(p-1)$ and such that
##  $2 \sqrt{|G|} \< p$.
##  Currently prime fields of size smaller than $65\,536$ are handled more
##  efficiently than larger prime fields,
##  so the runtime of the character calculation depends on how large the
##  chosen prime is.
##
##  The routine stores a Dixon record (see~"DixonRecord") in the group
##  that helps routines that identify classes,
##  for example `FusionConjugacyClasses', to work much faster.
##  Note that interrupting Dixon-Schneider calculations will prevent {\GAP}
##  from cleaning up the Dixon record;
##  when the computation by `IrrDixonSchneider' is complete,
##  the possibly large record is shrunk to an acceptable size.
##


#############################################################################
##
#F  IsDxLargeGroup( <G> )
##
##  returns `true' if the order of the group <G> is smaller than the current
##  value of the global variable `DXLARGEGROUPORDER',
##  and `false' otherwise.
##  In Dixon-Schneider calculations, for small groups in the above sense a
##  class map is stored, whereas for large groups,
##  each occurring element is identified individually.
##
DeclareGlobalFunction( "IsDxLargeGroup" );


#############################################################################
##
#F  DxModularValuePol
#F  DxDegreeCandidates
##
DeclareGlobalFunction("DxModularValuePol");
DeclareGlobalFunction("DxDegreeCandidates");


#############################################################################
##
#A  DixonRecord( <G> )
##
##  The `DixonRecord' of a group contains information used by the routines
##  to compute the irreducible characters and related information via the
##  Dixon-Schneider algorithm such as class arrangement and character spaces
##  split obtained so far.
##  Usually this record is passed as argument to all subfunctions to avoid a
##  long argument list.
##  It has a component `.conjugacyClasses' which contains the classes of <G>
##  *ordered as the algorithm needs them*.
##
DeclareAttribute("DixonRecord",IsGroup,"mutable");


#############################################################################
##
#O  DxPreparation(<G>,<D>)
##
##  Creates enttries in the dixon record <D> of the group <G> which are
##  representation dependent, like functions to identify the class of
##  elements.
DeclareOperation("DxPreparation",[IsGroup,IsRecord]);


#############################################################################
##
#F  ClassComparison(<c>,<d>)  . . . . . . . . . . . . compare classes c and d
##
##  Comparison function for conjugacy classes, used by `Sort'.
##  Comparison is based first on the size of the class and then on the
##  order of the representatives. Thus the 1-Class is in the first position,
##  as required. Since sorting is primary by the class sizes,smaller
##  classes are in earlier positions, making the active columns those to
##  smaller classes, thus reducing the work for calculating class matrices.
##  Additionally, galois conjugated classes are kept together, thus increasing
##  the chance,that with one columns of them active to be several active,
##  again reducing computation time.
##
DeclareGlobalFunction( "ClassComparison");


#############################################################################
##
#F  DxIncludeIrreducibles( <D>, <new>[, <newmod>] )
##
##  This function takes a list of irreducible characters <new>, each given as
##  a list of values (corresponding to the class arrangement in <D>), and
##  adds these to a partial computed list of irreducibles as maintained by
##  the Dixon record <D>.
##  This permits one to add characters in interactive use obtained from other
##  sources and to continue the Dixon-Schneider calculation afterwards.
##  If the optional argument <newmod> is given, it must be a
##  list of reduced characters, corresponding to <new>.
##  (Otherwise the function has to reduce the characters itself.)
##
##  The function closes the new characters under the action of Galois
##  automorphisms and tensor products with linear characters.
##
DeclareGlobalFunction( "DxIncludeIrreducibles" );


#############################################################################
##
#F  SplitCharacters( <D>, <list> )   split characters according to the spaces
##
##  This routine decomposes the characters given in <list> according to the
##  character spaces found up to this point. By applying this routine to
##  tensor products etc., it may result in characters with smaller norm,
##  even irreducible ones. Since the recalculation of characters is only
##  possible if the degree is small enough, the splitting process is
##  applied only to characters of sufficiently small degree.
##
DeclareGlobalFunction( "SplitCharacters" );


#############################################################################
##
#F  OrbitSplit(<D>) . . . . . . . . . . . . . . try to split two-orbit-spaces
##
##  Tries to split two-orbit character spaces.
##
DeclareGlobalFunction("OrbitSplit");


#############################################################################
##
#F  DxSplitDegree(<D>,<space>,<r>)                                    local
##
##  estimates the number of parts obtained when splitting the character space
##  <space> with matrix number <r>. This estimate is obtained using charcter
##  morphisms.
##
DeclareGlobalFunction("DxSplitDegree");


#############################################################################
##
#F  BestSplittingMatrix(<D>)
##
##  returns the number of the class sum matrix that is assumed to yield the 
##  best (cost/earning ration) split. This matrix then will be the next one
##  computed and used.
##
DeclareGlobalFunction("BestSplittingMatrix");


#############################################################################
##
#F  DixonInit( <G> ) . . . . . . . . . . initialize Dixon-Schneider algorithm
##
##  This function does all the initializations for the Dixon-Schneider
##  algorithm. This includes calculation of conjugacy classes, power maps,
##  linear characters and character morphisms.
##  It returns a record (see~"DixonRecord", "Components of a Dixon Record")
##  that can be used when calculating the irreducible characters of <G>
##  interactively.
##
DeclareGlobalFunction( "DixonInit" );


#############################################################################
##
#F  DixonSplit( <D> ) .  calculate matrix, split spaces and obtain characters
##
##  This function performs one splitting step in the Dixon-Schneider
##  algorithm. It selects a class, computes the (partial) class sum matrix,
##  uses it to split character spaces and stores all the irreducible
##  characters obtained that way.
##
DeclareGlobalFunction( "DixonSplit" );


#############################################################################
##
#F  DixontinI( <D> )  . . . . . . . . . . . . . . . .  reverse initialisation
##
##  This function ends a Dixon-Schneider calculation.
##  It sorts the characters according to the degree and
##  unbinds components in the Dixon record that are not of use any longer.
##  It returns a list of irreducible characters.
##
DeclareGlobalFunction( "DixontinI" );


#############################################################################
##
#A  IrrDixonSchneider( <G> ) . . . . irreducible characters of finite group G
##
##  computes the irreducible characters of the finite group <G>,
##  using the Dixon-Schneider method (see~"The Dixon-Schneider Algorithm").
##  It calls `DixonInit' and `DixonSplit',
#T  and `OrbitSplit', % is not documented!
##  and finally returns the list returned by `DixontinI'
##  (see~"Advanced Methods for Dixon-Schneider Calculations",
##  "Components of a Dixon Record",
##  "An Example of Advanced Dixon-Schneider Calculations").
##
DeclareAttribute( "IrrDixonSchneider", IsGroup );
DeclareOperation( "IrrDixonSchneider", [ IsGroup, IsRecord ] );


#############################################################################
##
#E

