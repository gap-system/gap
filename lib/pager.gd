#############################################################################
##  
#W  pager.gd                     GAP Library                     Frank Lübeck
##  
#H  @(#)$Id: pager.gd,v 1.3 2002/04/15 10:05:11 sal Exp $
##  
#Y  Copyright  (C) 2001, Lehrstuhl  D  fuer  Mathematik, RWTH  Aachen, Germany 
#Y (C) 2001 School Math and  Comp. Sci., University of St. Andrews, Scotland
#Y Copyright (C) 2002 The GAP Group
##  
##  The  files  pager.g{d,i}  contain  the `Pager'  utility.  A  rudimentary
##  version of this  was integrated in first versions of  GAP's help system.
##  But this utility is certainly useful for other purposes as well.
##  
Revision.pager_gd := 
  "@(#)$Id: pager.gd,v 1.3 2002/04/15 10:05:11 sal Exp $";

#############################################################################
##  
#F  Pager( <lines> ) . . . . . . . . . . . . display text on screen in a pager
#V  PAGER . . . . . . . . . . . . . . . . .  variable for choosing a pager
#V  PAGER_OPTIONS . . . . . . . . . . . . .  options for external pager
##  
##  This function can be used to display a text on screen using a pager, i.e.,
##  the text is shown page by page. 
##  
##  There is a default builtin pager in GAP which has very limited capabilities
##  but should work on any system.
##  
##  At least on a UNIX system one should use an external pager program like
##  `less' or `more'. {\GAP} assumes that this program has a command line option 
##  `+nr' which starts the display of the text with line number `nr'.
##  
##  Which pager is used can be controlled by setting the variable `PAGER'.
##  The default setting is `PAGER := "builtin";' which means that the 
##  internal pager is used.
##  
##  On UNIX systems you probably want to set `PAGER := "less";' or
##  `PAGER := "more";', you can do this for example in your `.gaprc' file.
##  In that case you can also tell {\GAP} a list of standard options for the
##  external pager. These are specified as list of strings in the variable
##  `PAGER_OPTIONS'.
##  
##  Example:
##  \begintt
##    PAGER := "less";
##    PAGER_OPTIONS := ["-f", "-r", "-a", "-i", "-M", "-j2"];
##  \endtt
##  
##  The argument <lines> can have one of the following forms:
##  
##  \beginlist%ordered
##  \item{(1)} a string (i.e., lines are separated by newline characters)
##  \item{(2)} a list of strings (without trailing newline characters) 
##  which are interpreted as lines of the text to be shown
##  \item{(3)} a record with component `.lines' as in (1) or (2) and 
##  optional further components
##  \endlist
##  
##  In case~(3) currently the following additional components are used:
##  
##  \beginitems
##  `.formatted' &
##  can be `false' or `true'. If set to `true' the builtin pager tries 
##  to show the text exactly as it is given (avoiding {\GAP}s automatic 
##  line breaking
##  
##  `.start' &
##  must be an integral number. This is interpreted as the number of the
##  first line shown by the pager (one may see the beginning of the text
##  via back scrolling).
##  \enditems
##  

DeclareGlobalFunction("Pager");

