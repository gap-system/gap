#############################################################################
##
#W    read.g            GAP 4 package 'polycyclic'               Bettina Eick 
#W                                                              Werner Nickel
#W                                                                   Max Horn
##

##
## matrix -- basics about matrices, rational spaces, lattices and modules
##
ReadPkg( "polycyclic", "gap/matrix/intmat.gi");
ReadPkg( "polycyclic", "gap/matrix/rowbases.gi");
ReadPkg( "polycyclic", "gap/matrix/latbases.gi");
ReadPkg( "polycyclic", "gap/matrix/lattices.gi");
ReadPkg( "polycyclic", "gap/matrix/modules.gi");
ReadPkg( "polycyclic", "gap/matrix/triangle.gi");
ReadPkg( "polycyclic", "gap/matrix/hnf.gi");

##  
##
## basic -- basic functions for pcp groups
##
ReadPkg( "polycyclic", "gap/basic/collect.gi");
ReadPkg( "polycyclic", "gap/basic/colftl.gi");
ReadPkg( "polycyclic", "gap/basic/colcom.gi");
ReadPkg( "polycyclic", "gap/basic/coldt.gi");
ReadPkg( "polycyclic", "gap/basic/colsave.gi");

ReadPkg( "polycyclic", "gap/basic/pcpelms.gi");
ReadPkg( "polycyclic", "gap/basic/pcppcps.gi");
ReadPkg( "polycyclic", "gap/basic/pcpgrps.gi");
ReadPkg( "polycyclic", "gap/basic/pcppara.gi");
ReadPkg( "polycyclic", "gap/basic/pcpexpo.gi");
ReadPkg( "polycyclic", "gap/basic/pcpsers.gi");
ReadPkg( "polycyclic", "gap/basic/grphoms.gi");
ReadPkg( "polycyclic", "gap/basic/pcpfact.gi");
ReadPkg( "polycyclic", "gap/basic/chngpcp.gi");  
ReadPkg( "polycyclic", "gap/basic/convert.gi");
ReadPkg( "polycyclic", "gap/basic/orbstab.gi");   

ReadPkg( "polycyclic", "gap/basic/construct.gi");

##
## cohomology  - extensions and complements
##
ReadPkg( "polycyclic", "gap/cohom/cohom.gi");   
ReadPkg( "polycyclic", "gap/cohom/addgrp.gi");   
ReadPkg( "polycyclic", "gap/cohom/general.gi");   
ReadPkg( "polycyclic", "gap/cohom/solabel.gi");    
ReadPkg( "polycyclic", "gap/cohom/solcohom.gi");    
ReadPkg( "polycyclic", "gap/cohom/twocohom.gi"); 
ReadPkg( "polycyclic", "gap/cohom/intcohom.gi"); 
ReadPkg( "polycyclic", "gap/cohom/onecohom.gi");  
ReadPkg( "polycyclic", "gap/cohom/grpext.gi");      
ReadPkg( "polycyclic", "gap/cohom/grpcom.gi");     
ReadPkg( "polycyclic", "gap/cohom/norcom.gi");     

##
## action - under polycyclic matrix groups
##
ReadPkg( "polycyclic", "gap/action/extend.gi");
ReadPkg( "polycyclic", "gap/action/basepcgs.gi");
ReadPkg( "polycyclic", "gap/action/freegens.gi");
ReadPkg( "polycyclic", "gap/action/dixon.gi");
ReadPkg( "polycyclic", "gap/action/kernels.gi");
ReadPkg( "polycyclic", "gap/action/orbstab.gi");
ReadPkg( "polycyclic", "gap/action/orbnorm.gi");

##
## some more high level functions for pcp groups
##
ReadPkg( "polycyclic", "gap/pcpgrp/general.gi");
ReadPkg( "polycyclic", "gap/pcpgrp/inters.gi");
ReadPkg( "polycyclic", "gap/pcpgrp/grpinva.gi");
ReadPkg( "polycyclic", "gap/pcpgrp/torsion.gi");
ReadPkg( "polycyclic", "gap/pcpgrp/maxsub.gi");
ReadPkg( "polycyclic", "gap/pcpgrp/findex.gi"); 
ReadPkg( "polycyclic", "gap/pcpgrp/nindex.gi"); 
ReadPkg( "polycyclic", "gap/pcpgrp/nilpot.gi"); 
ReadPkg( "polycyclic", "gap/pcpgrp/polyz.gi"); 
ReadPkg( "polycyclic", "gap/pcpgrp/pcpattr.gi"); 
ReadPkg( "polycyclic", "gap/pcpgrp/wreath.gi");
ReadPkg( "polycyclic", "gap/pcpgrp/fitting.gi");
ReadPkg( "polycyclic", "gap/pcpgrp/centcon.gi");
ReadPkg( "polycyclic", "gap/pcpgrp/normcon.gi");
ReadPkg( "polycyclic", "gap/pcpgrp/schur.gi");
ReadPkg( "polycyclic", "gap/pcpgrp/tensor.gi");

##
## matrep -- computing a matrix representation
##
ReadPkg( "polycyclic", "gap/matrep/matrep.gi");
ReadPkg( "polycyclic", "gap/matrep/affine.gi");
ReadPkg( "polycyclic", "gap/matrep/unitri.gi");

##
## examples - generic groups and an example list
##
ReadPkg( "polycyclic", "gap/exam/pcplib.gi");
ReadPkg( "polycyclic", "gap/exam/matlib.gi");
ReadPkg( "polycyclic", "gap/exam/nqlib.gi");
ReadPkg( "polycyclic", "gap/exam/generic.gi");
ReadPkg( "polycyclic", "gap/exam/bgnilp.gi");
ReadPkg( "polycyclic", "gap/exam/metacyc.gi");
ReadPkg( "polycyclic", "gap/exam/metagrp.gi");

##
## schur covers and schur towers of p-groups
##
ReadPkg( "polycyclic", "gap/cover/const/bas.gi"); # basic stuff
ReadPkg( "polycyclic", "gap/cover/const/orb.gi"); # orbits
ReadPkg( "polycyclic", "gap/cover/const/aut.gi"); # automorphisms
ReadPkg( "polycyclic", "gap/cover/const/com.gi"); # complements
ReadPkg( "polycyclic", "gap/cover/const/cov.gi"); # Schur covers
#ReadPkg( "polycyclic", "gap/cover/const/ord.gi"); # order
#ReadPkg( "polycyclic", "gap/cover/const/ccc.gi"); # coclass
#ReadPkg( "polycyclic", "gap/cover/trees/xtree.gi"); # cover trees
 

