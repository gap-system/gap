############################################################################
##
##  timing_projectors_mod.g         CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: timing_projectors_mod.g,v 1.3 2005/07/19 14:01:18 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");

MakeReadWriteGlobal ("BFUNC_FROM_TEST_FUNC");
BFUNC_FROM_TEST_FUNC := BFUNC_FROM_TEST_FUNC_MOD;
MakeReadOnlyGlobal ("BFUNC_FROM_TEST_FUNC");

ReadPackage ("crisp", "tst/timing_projectors.g");


############################################################################
##
#E
##
