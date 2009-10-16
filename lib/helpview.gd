#############################################################################
##  
#W  helpview.gd                 GAP Library                      Frank Lübeck
##  
#H  @(#)$Id: helpview.gd,v 1.2 2002/04/15 10:04:53 sal Exp $
##  
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 2001 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##  
##  The  files  helpview.g{d,i} contain the configuration mechanism  for  the
##  different help viewer.
##  
Revision.helpview_gd := 
  "@(#)$Id: helpview.gd,v 1.2 2002/04/15 10:04:53 sal Exp $";

DeclareGlobalVariable("HELP_VIEWER_INFO");
DeclareGlobalFunction("FindWindowId");
DeclareGlobalFunction("SetHelpViewer");

