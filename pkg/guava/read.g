#############################################################################
##
#A  read.g                  GUAVA library                       Reinald Baart
#A                                                         Jasper Cramwinckel
#A                                                            Erik Roijackers
#A                                                                Eric Minkes
#A                                                                 Lea Ruscio
#A                                                               David Joyner
##
##  This file is read by GAP upon startup. It installs all functions of
##  the GUAVA library 
##
#H  @(#)$Id: read.g,v 1.7 2004/12/20 21:26:05 gap Exp $
##
## added read divisors.gi 11-2004
##

#############################################################################
##
#F  Read calls to load all files.  
##
ReadPkg("guava", "banner.g");
ReadPkg("guava", "lib/setup.g");
ReadPkg("guava", "lib/divisors.gi");
ReadPkg("guava", "lib/codeword.gi");    
ReadPkg("guava", "lib/codegen.gi");
ReadPkg("guava", "lib/matrices.gi");
ReadPkg("guava", "lib/nordrob.gi");
ReadPkg("guava", "lib/util.gi"); 
ReadPkg("guava", "lib/util2.gi"); 
ReadPkg("guava", "lib/codeops.gi"); 
ReadPkg("guava", "lib/bounds.gi"); 
ReadPkg("guava", "lib/codefun.gi"); 
ReadPkg("guava", "lib/codeman.gi"); 
ReadPkg("guava", "lib/codecr.gi");
ReadPkg("guava", "lib/codecstr.gi");
ReadPkg("guava", "lib/codemisc.gi");
ReadPkg("guava", "lib/codenorm.gi");
ReadPkg("guava", "lib/decoders.gi"); 
ReadPkg("guava", "lib/tblgener.gi"); 
ReadPkg("guava", "lib/toric.gi"); 

