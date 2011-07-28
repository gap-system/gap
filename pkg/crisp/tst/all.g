############################################################################
##
##  all.g                           CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: all.g,v 1.8 2011/05/18 16:53:33 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
LoadPackage ("crisp", "", false);

PRINT_METHODS := false;

#Print ("testing manual examples\n");
#ReadTest (Filename (DirectoriesPackageLibrary ("crisp", "doc"), "manual.examples.tst"));

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

############################################################################
##
#E
##
