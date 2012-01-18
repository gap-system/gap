#############################################################################
##
#W    hasse/config.g      OpenMath Package             Andrew Solomon
#W                                                     Marco Costantini
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##    config file for Hasse
##


##########################################################################
# Some System dependent defitions
##
BROWSER_COMMAND := "open"; # "netscape-navigator";


# the location of the server+servlet - a "factory setting"
# probably don't need to change this.
# Update: that web-page may not exist anymore: ask Andrew Solomon or 
# try http://www.archive.org/
# or search HasseDiagramServlet with  http://www.koders.com/ :
# http://www.koders.com/java/fid92C29A57EB2099CDDB9FBFC932F7AD969D97CE8B.aspx
SERVLET := "http://dev.camel.math.ca/hasse_diagram/servlet/HasseDiagramServlet";
# see also "Constructing Mathlets using JavaMath" by Alan Cooper, Stephen Linton
# and Andrew Solomon: http://mathdl.maa.org/mathDL/55/?pa=content&sa=viewDocument&nodeId=485
# and JavaMath at http://sourceforge.net/project/showfiles.php?group_id=12766


###########################################################################
##
## This should not need to be modified.
##

TOP_HTML :=
Concatenation(" <html> <h1>View Hasse Diagram</h1> \n",
"<form action=\n", SERVLET,"\n method=post name=myform> \n",
"Type a name for the diagram to be viewed: \n",
"<input type=text value=foo name=name align=top maxlength=10 size=10><br>\n", 
"<textarea cols=50 rows=15 name=xmlhasse >\n");

BOTTOM_HTML := Concatenation("</textarea>",
"<input type=submit value=\"Take a Look\" align=middle> </form> <hr> \n",
" <center> The Hasse Diagram viewer is derived from ",
"<a href=\"http://www.math.hawaii.edu/~ralph/LatDraw/\">",
"Ralph Freese's LatDraw applet</a>.  </center>\n",
"<p> <center> <em>Copyright &copy; 2000-2001 Andrew Solomon. ",
" All rights reserved.</em> </center> </html>");



#############################################################################
#E
