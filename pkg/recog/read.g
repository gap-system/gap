#############################################################################
##
##  read.g                recog package                   Max Neunhoeffer
##                                                            Ákos Seress
##
##  Copyright 2005 Lehrstuhl D für Mathematik, RWTH Aachen
##
##  Reading the implementation part of the recog package.
##
##  $Id: read.g,v 1.22 2006/10/11 03:30:27 gap Exp $
##
#############################################################################

#ReadPackage("recog","gap/homwdata.gi");  # Now in the orb package.
ReadPackage("recog","gap/libhacks.gi");   # This should go in the future!
#ReadPackage("recog","gap/memory.gi");
#ReadPackage("recog","gap/slptools.gi");
# now in GAP library

# Generic:
ReadPackage("recog","gap/methsel.gi");
ReadPackage("recog","gap/recognition.gi");

# Permutations:
ReadPackage("recog","gap/recoggiant.gi");
ReadPackage("recog","gap/snksetswrsr.gi");
ReadPackage("recog","gap/perm.gi");

# Matrices/Projective:
ReadPackage("recog","gap/matimpr.gi");
ReadPackage("recog","gap/c6.gi");
ReadPackage("recog","gap/tensor.gi");
ReadPackage("recog","gap/shortorbs.gi");
ReadPackage("recog","gap/blackbox.gi");
ReadPackage("recog","gap/forms.gi");
ReadPackage("recog","gap/classical.gi");
ReadPackage("recog","gap/slconstr.gi");
ReadPackage("recog","gap/twoelorders.gi");
ReadPackage("recog","gap/derived.gi");
ReadPackage("recog","gap/semilinear.gi");
ReadPackage("recog","gap/subfield.gi");

# All the method installations are now here:
ReadPackage("recog","gap/matrix.gi");
ReadPackage("recog","gap/projective.gi");

