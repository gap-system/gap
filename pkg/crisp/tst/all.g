############################################################################
##
##  all.g                           CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: all.g,v 1.7 2005/07/19 14:01:18 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp");

if not IsBound (PRINT_METHODS) then
	PRINT_METHODS := false;
fi;

Print ("testing class construction \n");
ReadPackage ("crisp", "tst/classes.g");

Print ("testing bases of classes \n");
ReadPackage ("crisp", "tst/basis.g");

Print ("testing boundaries of classes  \n");
ReadPackage ("crisp", "tst/boundary.g");

Print ("testing characteristics of classes  \n");
ReadPackage ("crisp", "tst/char.g");

Print ("testing membership for classes  \n");
ReadPackage ("crisp", "tst/in.g");

Print ("testing injectors \n");
ReadPackage ("crisp", "tst/injectors.g");

Print ("testing normal subgroups \n");
ReadPackage ("crisp", "tst/normals.g");

Print ("testing projectors routines \n");
ReadPackage ("crisp", "tst/projectors.g");

Print ("testing radicals \n");
ReadPackage ("crisp", "tst/radicals.g");

Print ("testing residuals \n");
ReadPackage ("crisp", "tst/residuals.g");

Print ("testing socles \n");
ReadPackage ("crisp", "tst/socle.g");

Print ("testing print routines \n");
ReadPackage ("crisp", "tst/print.g");


FAST_TEST := true;
DO_TIMING := false;

ReadPackage ("crisp", "tst/timing_injectors.g");
ReadPackage ("crisp", "tst/timing_normals.g");
ReadPackage ("crisp", "tst/timing_normpro.g");
ReadPackage ("crisp", "tst/timing_projectors.g");
ReadPackage ("crisp", "tst/timing_radicals.g");
ReadPackage ("crisp", "tst/timing_residuals.g");
ReadPackage ("crisp", "tst/timing_socle.g");

FAST_TEST := false;
DO_TIMING := true;

ReadPackage ("crisp", "tst/timing_injectors.g");
ReadPackage ("crisp", "tst/timing_normals.g");
ReadPackage ("crisp", "tst/timing_projectors.g");
ReadPackage ("crisp", "tst/timing_radicals.g");
ReadPackage ("crisp", "tst/timing_residuals.g");
ReadPackage ("crisp", "tst/timing_socle.g");
ReadPackage ("crisp", "tst/timing_normpro.g");


############################################################################
##
#E
##
