#############################################################################
##
#W    read.g            GAP 4 package 'polycyclic'               Bettina Eick 
#W                                                              Werner Nickel
##

##
## matrix -- basics about matrices, rational spaces, lattices and modules
##
ReadPkg( PolycyclicPkgName, "gap/matrix/intmat.gi");
ReadPkg( PolycyclicPkgName, "gap/matrix/rowbases.gi");
ReadPkg( PolycyclicPkgName, "gap/matrix/latbases.gi");
ReadPkg( PolycyclicPkgName, "gap/matrix/lattices.gi");
ReadPkg( PolycyclicPkgName, "gap/matrix/modules.gi");
ReadPkg( PolycyclicPkgName, "gap/matrix/triangle.gi");
ReadPkg( PolycyclicPkgName, "gap/matrix/hnf.gi");

##  
##
## basic -- basic functions for pcp groups
##
ReadPkg( PolycyclicPkgName, "gap/basic/collect.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/colftl.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/colcom.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/coldt.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/colsave.gi");

ReadPkg( PolycyclicPkgName, "gap/basic/pcpelms.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/pcppcps.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/pcpgrps.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/pcppara.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/pcpexpo.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/pcpsers.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/grphoms.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/pcpfact.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/chngpcp.gi");  
ReadPkg( PolycyclicPkgName, "gap/basic/convert.gi");
ReadPkg( PolycyclicPkgName, "gap/basic/orbstab.gi");   

##
## cohomology  - extensions and complements
##
ReadPkg( PolycyclicPkgName, "gap/cohom/cohom.gi");   
ReadPkg( PolycyclicPkgName, "gap/cohom/addgrp.gi");   
ReadPkg( PolycyclicPkgName, "gap/cohom/general.gi");   
ReadPkg( PolycyclicPkgName, "gap/cohom/solcohom.gi");    
ReadPkg( PolycyclicPkgName, "gap/cohom/twocohom.gi"); 
ReadPkg( PolycyclicPkgName, "gap/cohom/intcohom.gi"); 
ReadPkg( PolycyclicPkgName, "gap/cohom/onecohom.gi");  
ReadPkg( PolycyclicPkgName, "gap/cohom/grpext.gi");      
ReadPkg( PolycyclicPkgName, "gap/cohom/grpcom.gi");     
ReadPkg( PolycyclicPkgName, "gap/cohom/norcom.gi");     

##
## action - under polycyclic matrix groups
##
ReadPkg( PolycyclicPkgName, "gap/action/extend.gi");
ReadPkg( PolycyclicPkgName, "gap/action/basepcgs.gi");
ReadPkg( PolycyclicPkgName, "gap/action/freegens.gi");
ReadPkg( PolycyclicPkgName, "gap/action/dixon.gi");
ReadPkg( PolycyclicPkgName, "gap/action/kernels.gi");
ReadPkg( PolycyclicPkgName, "gap/action/orbstab.gi");
ReadPkg( PolycyclicPkgName, "gap/action/orbnorm.gi");

##
## some more high level functions for pcp groups
##
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/general.gi");
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/inters.gi");
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/grpinva.gi");
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/torsion.gi");
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/maxsub.gi");
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/findex.gi"); 
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/nindex.gi"); 
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/nilpot.gi"); 
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/polyz.gi"); 
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/pcpattr.gi"); 
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/wreath.gi");
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/fitting.gi");
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/centcon.gi");
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/normcon.gi");
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/schur.gi");
ReadPkg( PolycyclicPkgName, "gap/pcpgrp/tensor.gi");

##
## matrep -- computing a matrix representation
##
ReadPkg( PolycyclicPkgName, "gap/matrep/matrep.gi");
ReadPkg( PolycyclicPkgName, "gap/matrep/affine.gi");
ReadPkg( PolycyclicPkgName, "gap/matrep/unitri.gi");

##
## examples - generic groups and an example list
##
ReadPkg( PolycyclicPkgName, "gap/exam/pcplib.gi");
ReadPkg( PolycyclicPkgName, "gap/exam/matlib.gi");
ReadPkg( PolycyclicPkgName, "gap/exam/nqlib.gi");
ReadPkg( PolycyclicPkgName, "gap/exam/generic.gi");
ReadPkg( PolycyclicPkgName, "gap/exam/bgnilp.gi");
ReadPkg( PolycyclicPkgName, "gap/exam/metacyc.gi");
ReadPkg( PolycyclicPkgName, "gap/exam/metagrp.gi");

##
## schur covers and schur towers of p-groups
##
ReadPkg( PolycyclicPkgName, "gap/cover/const/bas.gi"); # basic stuff
ReadPkg( PolycyclicPkgName, "gap/cover/const/orb.gi"); # orbits
ReadPkg( PolycyclicPkgName, "gap/cover/const/aut.gi"); # automorphisms
ReadPkg( PolycyclicPkgName, "gap/cover/const/com.gi"); # complements
ReadPkg( PolycyclicPkgName, "gap/cover/const/cov.gi"); # Schur covers
#ReadPkg( PolycyclicPkgName, "gap/cover/const/ord.gi"); # order
#ReadPkg( PolycyclicPkgName, "gap/cover/const/ccc.gi"); # coclass
#ReadPkg( PolycyclicPkgName, "gap/cover/trees/xtree.gi"); # cover trees
 

