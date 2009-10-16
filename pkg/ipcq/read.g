#############################################################################
##
#W    read.g            share package 'ipcq'
##

#############################################################################
##
#R The banner?
##

#############################################################################
##
#R Read functions for polycyclic
##

# computing module presentations
ReadPkg("ipcq", "gap/words.gi");
ReadPkg("ipcq", "gap/getdefs.gi");
ReadPkg("ipcq", "gap/qsystem.gi");
ReadPkg("ipcq", "gap/msystem.gi");
ReadPkg("ipcq", "gap/modpres.gi");
ReadPkg("ipcq", "gap/printpr.gi");

# computing matrix representations of modules
ReadPkg("ipcq", "gap/zmeg.gi");

# the polycyclic quotient methods
ReadPkg("ipcq", "gap/checksys.gi");
ReadPkg("ipcq", "gap/initquot.gi");
ReadPkg("ipcq", "gap/nextquot.gi");
ReadPkg("ipcq", "gap/polyquot.gi");

# examples
ReadPkg("ipcq", "gap/examples.gi");

# further examples
ReadPkg("ipcq", "exam/eddie.gi");
ReadPkg("ipcq", "exam/werner.gi");
ReadPkg("ipcq", "exam/paper.gi");

