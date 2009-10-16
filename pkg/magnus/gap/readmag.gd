#############################################################################
##
#W  readmag.gd           Magnus Client Package                   Steve Linton
##
#H  @(#)$Id: readmag.gd,v 1.1 2000/04/14 09:19:30 sal Exp $
##
#Y  (C) 200 School  Comp. Sci., University of St.  Andrews, Scotland
##
##  This file declares some utility functions useful when GAP is being 
##  used as a client in Magnus packages
##
Revision.readmag_gd :=
    "@(#)$Id: readmag.gd,v 1.1 2000/04/14 09:19:30 sal Exp $";

DeclareInfoClass("InfoMagnus");

DeclareGlobalFunction("IsWhiteSpaceChar");

DeclareGlobalFunction("SkipWS");

DeclareGlobalFunction("MagnusReadWord");

DeclareGlobalFunction("MagnusReadFPGroup");

DeclareGlobalFunction("MagnusReadWordList");

#############################################################################
##
#E  readmag.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
##
