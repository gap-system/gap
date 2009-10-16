#############################################################################
##  
#W  helpdef.gd                  GAP Library       Frank Celler / Frank Lübeck
##  
#H  @(#)$Id: helpdef.gd,v 1.2 2002/04/15 10:04:53 sal Exp $
##  
#Y  Copyright (C)  2001,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 2001 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##  
##  The  files  helpdef.g{d,i}  contain  the  `default'  help  book  handler
##  functions, which implement access of GAP's online help to help documents
##  produced  from `gapmacro.tex'-  .tex and  .msk files  using buildman.pe,
##  tex, pdftex and convert.pl.
##  
##  The function  which converts the  TeX sources  to text for  the "screen"
##  viewer is outsourced into `helpt2t.g{d,i}'.
##  
Revision.helpdef_gd := 
  "@(#)$Id: helpdef.gd,v 1.2 2002/04/15 10:04:53 sal Exp $";
  
DeclareGlobalFunction("GapLibToc2Gap");
DeclareGlobalVariable("HELP_CHAPTER_BEGIN");
DeclareGlobalVariable("HELP_SECTION_BEGIN");
DeclareGlobalVariable("HELP_FAKECHAP_BEGIN");
DeclareGlobalVariable("HELP_PRELCHAPTER_BEGIN");
DeclareGlobalFunction("HELP_CHAPTER_INFO");
DeclareGlobalFunction("HELP_PRINT_SECTION_URL");
DeclareGlobalFunction("HELP_PRINT_SECTION_MAC_IC_URL");

