#############################################################################
##
#A  chartabl.gd                    for Tk                       Michael Ummels
##
##
#H  @(#)$Id: chartabl.gd,v 1.5 2003/08/17 23:27:48 gap Exp $
##
##  An interface to display character tables via Tk.
##

Revision.pkg_tk_gap_chartabl_gd :=
  "@(#)$Id: chartabl.gd,v 1.5 2003/08/17 23:27:48 gap Exp $";

DeclareGlobalFunction("SelectedCharsToGAP");
DeclareGlobalFunction("SelectedClassesToGAP");
DeclareGlobalFunction("SubmatrixToGAP");

DeclareOperation( "ShowCharacterTable", [IsNearlyCharacterTable, IsRecord] );
DeclareOperation( "ShowCharacterTable", [IsNearlyCharacterTable] );

DeclareOperation( "ShowTableOfMarks", [IsTableOfMarks, IsRecord] );
DeclareOperation( "ShowTableOfMarks", [IsTableOfMarks] );
