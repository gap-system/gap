#############################################################################
##
#W  grppccom.gd                  GAP Library                     Frank Celler
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the operations for the computation of complements in
##  pc groups
##
Revision.grppccom_gd :=
    "@(#)$Id$";

#############################################################################
##
#V  InfoComplement
##
##  Info class for the complement routines.
DeclareInfoClass("InfoComplement");

#############################################################################
##
#O  COAffineBlocks( <S>, <mats> ) . . . . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("COAffineBlocks");

#############################################################################
##
#O  CONextCentralizer( <ocr>, <S>, <H> )  . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("CONextCentralizer");

#############################################################################
##
#O  CONextCocycles( <cor>, <ocr>, <S> ) . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("CONextCocycles");

#############################################################################
##
#O  CONextCentral( <cor>, <ocr>, <S> ) . . . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("CONextCentral");

#############################################################################
##
#O  CONextComplements( <cor>, <S>, <K>, <M> ) . . . . . . . . . . . . . local
##
DeclareGlobalFunction("CONextComplements");

#############################################################################
##
#O  COComplements( <cor>, <G>, <N>, <all> ) . . . . . . . . . . . . . . local
##
DeclareGlobalFunction("COComplements");

#############################################################################
##
#O  COComplementsMain( <G>, <N>, <all>, <fun> )  . . . . . . . . . . . . . local
##
DeclareGlobalFunction("COComplementsMain");

#############################################################################
##
#O  ComplementclassesSolvableNC( <G>, <N> )
##
##  computes a set of representatives of the complement classes of <N> in
##  <G> by cohomological methods. <N> must be a solvable normal subgroup
##  of <G>.
DeclareOperation("ComplementclassesSolvableNC",
  [IsGroup,IsGroup]);

#############################################################################
##
#O  Complementclasses( <G>, <N> ) . . . . . . . . . . . . find all complement
##
##  Let <N> be a normal subgroup of <G>. This command returns a set of
##  representatives for the conjugacy classes of complements of <N> in <G>.
##  Complements are subgroups <U> of <G> which intersect trivially with <N>
##  and together with <N> generate <G>.
DeclareOperation("Complementclasses",[IsGroup,IsGroup]);

#############################################################################
##
#E  grppccom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
