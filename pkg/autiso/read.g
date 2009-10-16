#############################################################################
##
#W    read.g                 The AutIso package                  Bettina Eick
##

#############################################################################
##
#R  Global vars
##
SMTX.RAND_ELM_LIMIT := 5000;
MIP_GLLIMIT := 2000;

# some flags for the algorithm
if not IsBound(USE_PARTI) then USE_PARTI := true; fi;
if not IsBound(USE_MSERS) then USE_MSERS := false; fi;

# checking modes for the package
if not IsBound(CHECK_AUT) then CHECK_AUT := false; fi;
if not IsBound(CHECK_STB) then CHECK_STB := false; fi;
if not IsBound(CHECK_COV) then CHECK_COV := false; fi;
if not IsBound(CHECK_CNF) then CHECK_CNF := false; fi;

#############################################################################
##
#R  Read the install files.
##
ReadPkg("autiso", "gap/cfstab/general.gi");
ReadPkg("autiso", "gap/cfstab/pgroup.gi");
ReadPkg("autiso", "gap/cfstab/test.gi");
ReadPkg("autiso", "gap/cfstab/orbstab.gi");

ReadPkg("autiso", "gap/precom/chains.gi");

ReadPkg("autiso", "gap/grpalg/helpers.gi");
ReadPkg("autiso", "gap/grpalg/algebra.gi");
ReadPkg("autiso", "gap/grpalg/basis.gi");
ReadPkg("autiso", "gap/grpalg/init.gi");
ReadPkg("autiso", "gap/grpalg/cover.gi");
ReadPkg("autiso", "gap/grpalg/induc.gi");
ReadPkg("autiso", "gap/grpalg/check.gi");
ReadPkg("autiso", "gap/grpalg/autiso.gi");
ReadPkg("autiso", "gap/grpalg/test.gi");

ReadPkg("autiso", "gap/mip/detbins.gi");
ReadPkg("autiso", "gap/mip/chkbins.gi");
ReadPkg("autiso", "gap/mip/brauer.gi");

#ReadPkg("autiso", "gap/liealg/basis.gi");
#ReadPkg("autiso", "gap/liealg/init.gi");
#ReadPkg("autiso", "gap/liealg/cover.gi");
#ReadPkg("autiso", "gap/grpalg/induc.gi");
#ReadPkg("autiso", "gap/grpalg/check.gi");
#ReadPkg("autiso", "gap/liealg/autiso.gi");

