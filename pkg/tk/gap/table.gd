#############################################################################
##
#A  table.gd                      for Tk                       Michael Ummels
##
#H  @(#)$Id: table.gd,v 1.14 2003/08/17 23:27:48 gap Exp $
##
#Y  Copyright 2002-03         Michael Ummels                  Aachen, Germany
##
##  An interface to access tables without bothering if a row is bound or not.
##

Revision.pkg_tk_gap_table_gd :=
  "@(#)$Id: table.gd,v 1.14 2003/08/17 23:27:48 gap Exp $";

# Families for our objects
BindGlobal("EasilyAccessibleTableFamily", NewFamily("EasilyAccessibleTable"));

# Categories for our objects
DeclareCategory("IsEasilyAccessibleTable", IsList);

#
# Create an EasilyAccessibleTable from a table (a list of list)
#
DeclareOperation("EasilyAccessibleTable", [IsList]);

#
# Return the number of rows of an EasilyAccessibleTable
#
DeclareAttribute("NumberOfRows" , IsEasilyAccessibleTable);

#
# Return the number of columns of an EasilyAccessibleTable
#
DeclareAttribute("NumberOfColumns" , IsEasilyAccessibleTable);
