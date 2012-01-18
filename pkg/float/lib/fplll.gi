#############################################################################
##
#W  fplll.gi                      GAP library               Laurent Bartholdi
##
#H  @(#)$Id: fplll.gi,v 1.1 2012/01/17 11:03:22 gap Exp $
##
#Y  Copyright (C) 2012 Laurent Bartholdi
##
##  This file deals with fplll's implementation of LLL lattice reduction
##
Revision.float.fplll_gi :=
  "@(#)$Id: fplll.gi,v 1.1 2012/01/17 11:03:22 gap Exp $";

#!!! implement all options, arguments etc. to control quality of reduction
InstallMethod(FPLLLReducedBasis, [IsMatrix], function(m)
    while not ForAll(m,r->IsSubset(Integers,r)) do
        Error(m," must be an integer matrix");
    od;
    return @FPLLL(m,0,true,fail);
end);

InstallMethod(FPLLLShortestVector, [IsMatrix], function(m)
    while not ForAll(m,r->IsSubset(Integers,r)) do
        Error(m," must be an integer matrix");
    od;
    return @FPLLL(m,0,true,true);
end);

#############################################################################
##
#E
