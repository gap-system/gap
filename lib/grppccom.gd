#############################################################################
##
#W  grppccom.gd                  GAP Library                     Frank Celler
#W                                                           Alexander Hulpke
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
##
##  This file contains the operations for the computation of complements in
##  pc groups
##
Revision.grppccom_gd :=
    "@(#)$Id$";

#############################################################################
##
#F  InfoComplement
##
InfoComplement := NewInfoClass("InfoComplement");

#############################################################################
##
#O  COAffineBlocks( <S>, <mats> ) . . . . . . . . . . . . . . . . . . . local
##
COAffineBlocks := NewOperationArgs("COAffineBlocks");

#############################################################################
##
#O  CONextCentralizer( <ocr>, <S>, <H> )  . . . . . . . . . . . . . . . local
##
CONextCentralizer := NewOperationArgs("CONextCentralizer");

#############################################################################
##
#O  CONextCocycles( <cor>, <ocr>, <S> ) . . . . . . . . . . . . . . . . local
##
CONextCocycles := NewOperationArgs("CONextCocycles");

#############################################################################
##
#O  CONextCentral( <cor>, <ocr>, <S> ) . . . . . . . . . . . . . . . . local
##
CONextCentral := NewOperationArgs("CONextCentral");

#############################################################################
##
#O  CONextComplements( <cor>, <S>, <K>, <M> ) . . . . . . . . . . . . . local
##
CONextComplements := NewOperationArgs("CONextComplements");

#############################################################################
##
#O  COComplements( <cor>, <G>, <N>, <all> ) . . . . . . . . . . . . . . local
##
COComplements := NewOperationArgs("COComplements");

#############################################################################
##
#O  COComplementsMain( <G>, <N>, <all>, <fun> )  . . . . . . . . . . . . . local
##
COComplementsMain := NewOperationArgs("COComplementsMain");

#############################################################################
##
#O  ComplementclassesSolvableNC( <G>, <N> )
##
ComplementclassesSolvableNC := NewOperation("ComplementclassesSolvableNC",
  [IsGroup,IsGroup]);

#############################################################################
##
#O  Complementclasses( <G>, <N> ) . . . . . . . . . . . . find all complement
##
Complementclasses := NewOperation("Complementclasses",[IsGroup,IsGroup]);

#############################################################################
##
#E  grppccom.gd . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
