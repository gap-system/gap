#############################################################################
##  
#W  helpt2t.gd                  GAP Library                 Frank Celler 
#W                                                          Alexander Hulpke
#W                                                          Greg Gamble
##  
#H  @(#)$Id: helpt2t.gd,v 1.2 2001/07/27 16:28:54 gap Exp $
##  
#Y  Copyright  (C)  1996-2001, Lehrstuhl  D  fuer  Mathematik, RWTH  Aachen,
#Y  Germany (C) 2001 School Math and  Comp. Sci., University of St. Andrews,
#Y  Scotland
##  
##  The files  helpt2t.g{d,i} contain the  probably longest function  in the
##  GAP library. It converts TeX source code written in `gapmacro.tex' style
##  into text for the "screen" online help viewer.
##  
Revision.helpt2t_gd := 
  "@(#)$Id: helpt2t.gd,v 1.2 2001/07/27 16:28:54 gap Exp $";

DeclareGlobalFunction("HELP_PRINT_SECTION_TEXT");

#############################################################################
##
#E
