#############################################################################
##
#A  makedoc.g                     for Tk                      Max Neunhoeffer
##                                                             Michael Ummels
##  
#H  @(#)$Id: makedoc.g,v 1.1 2003/05/31 23:04:43 gap Exp $
##  
##  Rebuild the whole documentation, provided sufficiently good (pdf)LaTeX
##  is available. 
##  
# main
Print("\n========== converting main documentation for Tk =================\n");
MakeGAPDocDoc("doc", "manual", [ ], "Tk");

