#############################################################################
##
#A  tktable.gd                    for Tk                       Michael Ummels
##
#H  @(#)$Id: tktable.gd,v 1.23 2003/10/22 20:19:45 gap Exp $
##
#Y  Copyright 2002-03         Michael Ummels                  Aachen, Germany
##
##  An interface to display generalized tables with the Tk toolkit.
##

Revision.pkg_tk_gap_tktable_gd :=
  "@(#)$Id: tktable.gd,v 1.23 2003/10/22 20:19:45 gap Exp $";

# Some global variables
BindGlobal("TkTableFamily", NewFamily("TkTable"));
BindGlobal("TkTableFunctionFamily", NewFamily("TkTableFunction"));
BindGlobal("TKTABLE_MINIMUM_WIDTH", 5);
BindGlobal("TKTABLE_LEFT_JUSTIFIED", 1);
BindGlobal("TKTABLE_CENTERED", 2);
BindGlobal("TKTABLE_RIGHT_JUSTIFIED", 3);
BindGlobal("TKTABLE_NON_JUSTIFIED", 4);

DeclareGlobalVariable("TkTableIndices");

# Categories for our objects
DeclareCategory("IsTkTable", IsTkApplication);
DeclareFilter("IsDisplayed");
DeclareCategory("IsTkTableFunction", IsObject);

#
# Create a TkTable from a generalized table or a list
#
DeclareOperation("TkTable", [IsList]);

#
# Show a TkTable on the screen
#
DeclareOperation("Show", [IsTkTable]);

#
# Create a TkTable from a generalized table or a list and show it on the screen
#
DeclareOperation("ShowTkTable", [IsList]);

#
# Update the contents of a TkTable
#
DeclareOperation("Update", [IsTkTable]);

#
# Make a TkTable disappear from the screen
#
DeclareOperation("Hide", [IsTkTable]);

#
# Destroy a TkTable
#
DeclareOperation("Destroy", [IsTkTable]);

#
# Update a cell of a TkTable
#
DeclareOperation("UpdateCell", [IsTkTable, IsList]);

#
# Update cells of a TkTable
#
DeclareOperation("UpdateCells", [IsTkTable, IsList]);

#
# Update a row of a TkTable
#
DeclareOperation("UpdateRow", [IsTkTable, IsInt]);

#
# Update rows of a TkTable
#
DeclareOperation("UpdateRows", [IsTkTable, IsList]);

#
# Update a column of a TkTable
#
DeclareOperation("UpdateColumn", [IsTkTable, IsInt]);

#
# Update columns of a TkTable
#
DeclareOperation("UpdateColumns", [IsTkTable, IsList]);

#
# Scroll to a cell of a TkTable
#
DeclareOperation("ScrollToCell", [IsTkTable, IsList]);

#
# Select a cell of a TkTable
#
DeclareOperation("SelectCell", [IsTkTable, IsList]);

#
# Deselect a cell of a TkTable
#
DeclareOperation("DeselectCell", [IsTkTable, IsList]);

#
# Return whether a cell of a TkTable is selected
#
DeclareOperation("IsSelectedCell", [IsTkTable, IsList]);

#
# Select cells of a TkTable
#
DeclareOperation("SelectCells", [IsTkTable, IsList]);

#
# Deselect cells of a TkTable
#
DeclareOperation("DeselectCells", [IsTkTable, IsList]);

#
# Return all selected cells of a TkTable
#
DeclareAttribute("SelectedCells", IsTkTable, "mutable");

#
# Select a row of a TkTable
#
DeclareOperation("SelectRow", [IsTkTable, IsPosInt]);

#
# Deselect a row of a TkTable
#
DeclareOperation("DeselectRow", [IsTkTable, IsPosInt]);

#
# Return whether a row of a TkTable is selected
#
DeclareOperation("IsSelectedRow", [IsTkTable, IsPosInt]);

#
# Select rows of a TkTable
#
DeclareOperation("SelectRows", [IsTkTable, IsList]);

#
# Deselect rows of a TkTable
#
DeclareOperation("DeselectRows", [IsTkTable, IsList]);

#
# Return all selected rows of a TkTable
#
DeclareAttribute("SelectedRows", IsTkTable, "mutable");

#
# Select a column of a TkTable
#
DeclareOperation("SelectColumn", [IsTkTable, IsPosInt]);

#
# Deselect a column of a TkTable
#
DeclareOperation("DeselectColumn", [IsTkTable, IsPosInt]);

#
# Return whether a column of a TkTable is selected
#
DeclareOperation("IsSelectedColumn", [IsTkTable, IsPosInt]);

#
# Select columns of a TkTable
#
DeclareOperation("SelectColumns", [IsTkTable, IsList]);

#
# Deselect columns of a TkTable
#
DeclareOperation("DeselectColumns", [IsTkTable, IsList]);

#
# Return all selected columns of a TkTable
#
DeclareAttribute("SelectedColumns", IsTkTable, "mutable");

#
# Return whether a row of a TkTable is hidden
#
DeclareOperation("IsHiddenRow", [IsTkTable, IsInt]);

#
# Return all hidden rows of a TkTable
#
DeclareAttribute("HiddenRows", IsTkTable, "mutable");

#
# Hide some rows of a TkTable
#
DeclareOperation("HideRows", [IsTkTable, IsList]);

#
# Hide a single row of a TkTable
#
DeclareOperation("HideRow",  [IsTkTable, IsInt]);

#
# Unhide rows of a TkTable
#
DeclareOperation("UnhideRows", [IsTkTable, IsList]);

#
# Unhide a single row of a TkTable
#
DeclareOperation("UnhideRow", [IsTkTable, IsInt]);

#
# Return whether a column of a TkTable is hidden
#
DeclareOperation("IsHiddenColumn", [IsTkTable, IsInt]);

#
# Return all hidden columns of a TkTable
#
DeclareAttribute("HiddenColumns", IsTkTable, "mutable");

#
# Hide columns of a TkTable
#
DeclareOperation("HideColumns", [IsTkTable, IsList]);

#
# Hide a single column of a TkTable
#
DeclareOperation("HideColumn", [IsTkTable, IsInt]);

#
# Unhide columns of a TkTable
#
DeclareOperation("UnhideColumns", [IsTkTable, IsList]);

#
# Unhide a single column of a TkTable
#
DeclareOperation("UnhideColumn", [IsTkTable, IsInt]);

#
# Return the justification of a TkTable. The result is a positive integer that
# is equal to the value of one of the constants TKTABLE_LEFT_JUSTIFIED,
# TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED.
#
DeclareOperation("Justification", [IsTkTable]);

#
# Set the justification of a TkTable. To have an effect the last argument must
# be the value of one the constants TKTABLE_LEFT_JUSTIFIED, TKTABLE_CENTERED
# and TKTABLE_RIGHT_JUSTIFIED.
#
DeclareOperation("SetJustification", [IsTkTable, IsPosInt]);

#
# Sets the justification of rows of a TkTable. To have an effect the last
# argument must be the value of one the constants TKTABLE_LEFT_JUSTIFIED,
# TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and TKTABLE_NON_JUSTIFIED.
#
DeclareOperation("JustifyRows", [IsTkTable, IsList, IsPosInt]);

#
# Sets the justification of a single row of a TkTable. To have an effect
# the last argument must be the value of one the constants
# TKTABLE_LEFT_JUSTIFIED, TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and
# TKTABLE_NON_JUSTIFIED.
#
DeclareOperation("JustifyRow", [IsTkTable, IsPosInt, IsPosInt]);

#
# Sets the justification of columns of a TkTable. To have an effect the last
# argument must be the value of one the constants TKTABLE_LEFT_JUSTIFIED,
# TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and TKTABLE_NON_JUSTIFIED.
#
DeclareOperation("JustifyColumns", [IsTkTable, IsList, IsPosInt]);

#
# Sets the justification of a single column of a TkTable. To have an effect
# the last argument must be the value of one the constants
# TKTABLE_LEFT_JUSTIFIED, TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and
# TKTABLE_NON_JUSTIFIED.
#
DeclareOperation("JustifyColumn", [IsTkTable, IsPosInt, IsPosInt]);

#
# Sets the justification of a cells of a TkTable. To have an effect the last
# argument must be the value of one the constants TKTABLE_LEFT_JUSTIFIED,
# TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and TKTABLE_NON_JUSTIFIED.
#
DeclareOperation("JustifyCells", [IsTkTable, IsList, IsPosInt]);

#
# Sets the justification of a single cell of a TkTable. To have an effect
# the last argument must be the value of one the constants
# TKTABLE_LEFT_JUSTIFIED, TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and
# TKTABLE_NON_JUSTIFIED.
#
DeclareOperation("JustifyCell", [IsTkTable, IsList, IsPosInt]);

#
# A function to hide rows and columns of a TkTable
#
DeclareGlobalVariable("TkTableHideFunction");

#
# A function to unhide rows and columns of a TkTable
#
DeclareGlobalVariable("TkTableUnhideFunction");
