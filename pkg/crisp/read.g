############################################################################
##
##  read.g                          CRISP                 Burkhard H\"ofling
##
##  @(#)$Id: read.g,v 1.3 2005/12/21 17:14:23 gap Exp $
##
##  Copyright (C) 2000 by Burkhard H\"ofling, Mathematisches Institut,
##  Friedrich Schiller-Universit\"at Jena, Germany
##
ReadPackage ("crisp", "lib/classes.gi"); 
ReadPackage ("crisp", "lib/grpclass.gi"); 
ReadPackage ("crisp", "lib/fitting.gi");
ReadPackage ("crisp", "lib/schunck.gi");
ReadPackage ("crisp", "lib/form.gi");
ReadPackage ("crisp", "lib/projector.gi");
ReadPackage ("crisp", "lib/injector.gi");
ReadPackage ("crisp", "lib/normpro.gi");
ReadPackage ("crisp", "lib/solveeq.gi");
ReadPackage ("crisp", "lib/compl.gi");
ReadPackage ("crisp", "lib/radical.gi");
ReadPackage ("crisp", "lib/residual.gi");
ReadPackage ("crisp", "lib/util.gi");
ReadPackage ("crisp", "lib/samples.gi");
ReadPackage ("crisp", "lib/socle.gi");

if not IsBound (ComputedInducedPcgses) then
   ReadPackage ("crisp", "lib/pcgscache.gi");
fi;



############################################################################
##
#E
##
