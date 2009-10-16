#############################################################################
##
#A  gentable.gd                   for Tk                       Michael Ummels
##
#H  @(#)$Id: gentable.gd,v 1.3 2003/08/17 23:27:48 gap Exp $
##
#Y  Copyright 2002-03         Michael Ummels                  Aachen, Germany
##
##  An interface to work with tables that have row, column and corner titles.
##

Revision.pkg_tk_gap_gentable_gd :=
  "@(#)$Id: gentable.gd,v 1.3 2003/08/17 23:27:48 gap Exp $";

# Families for our objects
BindGlobal("GeneralizedTableFamily", NewFamily("GeneralizedTable"));

# Categories for our objects
DeclareCategory("IsGeneralizedTable", IsEasilyAccessibleTable);

#
# Create a new GeneralizedTable from a GAP table
#
DeclareOperation("GeneralizedTable", [IsList]);

#
# Return a reference to the list of all corner titles
#
DeclareOperation("Title", [IsGeneralizedTable]);

#
# Return a reference to the list of all row titles
#
DeclareOperation("RowTitles", [IsGeneralizedTable]);

#
# Return a reference to the list of all column titles
#
DeclareOperation("ColumnTitles", [IsGeneralizedTable]);
