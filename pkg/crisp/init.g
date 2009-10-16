############################################################################
##
##  init.g                          CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: init.g,v 1.8 2007/10/03 15:34:25 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
DeclareAutoPackage ("crisp", "1.3.2", true);
DeclarePackageAutoDocumentation ("crisp", "doc");

ReadPackage ("crisp", "lib/classes.gd");
ReadPackage ("crisp", "lib/grpclass.gd");
ReadPackage ("crisp", "lib/fitting.gd");
ReadPackage ("crisp", "lib/schunck.gd");
ReadPackage ("crisp", "lib/form.gd");
ReadPackage ("crisp", "lib/projector.gd");
ReadPackage ("crisp", "lib/injector.gd");
ReadPackage ("crisp", "lib/normpro.gd");
ReadPackage ("crisp", "lib/solveeq.gd");
ReadPackage ("crisp", "lib/compl.gd");
ReadPackage ("crisp", "lib/radical.gd");
ReadPackage ("crisp", "lib/residual.gd");
ReadPackage ("crisp", "lib/util.gd");
ReadPackage ("crisp", "lib/samples.gd");
ReadPackage ("crisp", "lib/socle.gd");

if not CompareVersionNumbers (GAPInfo.Version, "4.4.7") then
   ReadPackage ("crisp", "lib/pcgscache.gd");
fi;


############################################################################
##
#E
##