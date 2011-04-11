#############################################################################
##  
#W  helpview.gd                 GAP Library                      Frank Lübeck
##  
#H  @(#)$Id$
##  
#Y  Copyright (C)  2001,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 2001 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##  
##  The  files  helpview.g{d,i} contain the configuration mechanism  for  the
##  different help viewer.
##  
Revision.helpview_gd := 
  "@(#)$Id$";

DeclareGlobalVariable("HELP_VIEWER_INFO");
DeclareGlobalFunction("FindWindowId");
DeclareGlobalFunction("SetHelpViewer");

