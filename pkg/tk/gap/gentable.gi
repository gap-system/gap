#############################################################################
##
#A  gentable.gi                   for Tk                       Michael Ummels
##
#H  @(#)$Id: gentable.gi,v 1.4 2003/08/20 21:05:51 gap Exp $
##
#Y  Copyright 2002-03         Michael Ummels                  Aachen, Germany
##
##  An interface to work with tables that have row, column and corner titles.
##

Revision.pkg_tk_gap_gentable_gi :=
  "@(#)$Id: gentable.gi,v 1.4 2003/08/20 21:05:51 gap Exp $";

# Representations for our objects
DeclareRepresentation("IsGeneralizedTableRep", IsComponentObjectRep, ["table",
  "rowtitles", "coltitles", "corner"]);

#
# Create a new GeneralizedTable from a list of lists
#
InstallMethod(GeneralizedTable, "for a list", true, [IsList], 0,
  function(table)
    local obj;

    obj := rec(table := EasilyAccessibleTable(table), rowtitles :=
      EasilyAccessibleTable([]), coltitles := EasilyAccessibleTable([]),
      corner := EasilyAccessibleTable([]));
    Objectify(NewType(GeneralizedTableFamily, IsGeneralizedTable and
      IsGeneralizedTableRep and IsMutable), obj);
    return obj;
  end);

#
# Return the number of entry rows of a GeneralizedTable
#
InstallMethod(Length, "for a GeneralizedTable", true, [IsGeneralizedTable and
  IsGeneralizedTableRep], 0, function(obj)
    return Length(obj!.table);
  end);

#
# Return a certain row of a GeneralizedTable
#
InstallMethod(\[\], "for a GeneralizedTable and a positive integer", true,
  [IsGeneralizedTable and IsGeneralizedTableRep, IsPosInt], 0,
  function(obj, pos)
    return obj!.table[pos];
  end);

#
# Return if a certain row of a GeneralizedTable is bound
#
InstallMethod(IsBound\[\], "for a GeneralizedTable and a positive integer",
  true, [IsGeneralizedTable and IsGeneralizedTableRep,
  IsPosInt], 0, function(obj, pos)
    return IsBound(obj!.table[pos]);
  end);

#
# Set a certain row of a GeneralizedTable
#
InstallMethod(\[\]\:\=, "for a mutable GeneralizedTable, a positive integer \
and a list", true, [IsGeneralizedTable and IsGeneralizedTableRep and
  IsMutable, IsPosInt, IsList], 0, function(obj, pos, val)
    obj!.table[pos] := val;
  end);

#
# Unbind a certain row of a GeneralizedTable
#
InstallMethod(Unbind\[\], "for a mutable GeneralizedTable and a positive \
integer", true, [IsGeneralizedTable and IsGeneralizedTableRep and IsMutable,
  IsPosInt], 0, function(obj, pos)
    Unbind(obj!.table[pos]);
  end);

#
# Return a reference to the title list of a GeneralizedTable
#
InstallMethod(Title, "for a GeneralizedTable", true, [IsGeneralizedTable and
  IsGeneralizedTableRep and IsMutable], 0, function(obj)
    return obj!.corner;
  end);

#
# Return a reference to the list of all row titles
#
InstallMethod(RowTitles, "for a GeneralizedTable", true, [IsGeneralizedTable
  and IsGeneralizedTableRep], 0, function(obj)
    return obj!.rowtitles;
  end);

#
# Return a reference to the list of all column titles
#
InstallMethod(ColumnTitles, "for a GeneralizedTable", true,
  [IsGeneralizedTable and IsGeneralizedTableRep], 0, function(obj)
    return obj!.coltitles;
  end);

#
# Return the number of rows of a GeneralizedTable
#
InstallMethod(NumberOfRows, "for a GeneralizedTable", true,
  [IsGeneralizedTable and IsGeneralizedTableRep], 0, function(obj)
    return NumberOfRows(obj!.table);
  end);

#
# Return the number of columns of a GeneralizedTable
#
InstallMethod(NumberOfColumns, "for a GeneralizedTable", true,
  [IsGeneralizedTable and IsGeneralizedTableRep], 0, function(obj)
    return NumberOfColumns(obj!.table);
  end);

#
# Displays a GeneralizedTable in a user readable form
#
InstallMethod(Display, "for a GeneralizedTable", true, [IsGeneralizedTable], 0,
  function(obj)
    local rows, cols, shownrows, showncols, width, nextwidth, widths,
      titlewidths, titlecols, titlerows, x, y, numcols, numrows, i, j, k, max,
      title, s;

    rows := Maximum(NumberOfRows(obj), NumberOfRows(RowTitles(obj)));
    cols := Maximum(NumberOfColumns(obj), NumberOfColumns(ColumnTitles(obj)));
    titlerows := Maximum(NumberOfRows(ColumnTitles(obj)),
      NumberOfRows(Title(obj)));
    titlecols := Maximum(NumberOfColumns(RowTitles(obj)),
      NumberOfColumns(Title(obj)));
    # Calculate the width of each column and the number of columns/rows needed
    # for the title
    widths := [];
    titlewidths := [];
    # First traverse the title cells
    for i in [1 .. Length(Title(obj))] do
      for j in [1 .. Length(Title(obj)[i])] do
        if IsBound(Title(obj)[i][j]) and Length(String(Title(obj)[i][j])) <
          SizeScreen()[1] - 4 then
          if IsBound(titlewidths[j]) then
            titlewidths[j] := Maximum(titlewidths[j],
              Length(String(Title(obj)[i][j])));
          else
            titlewidths[j] := Length(String(Title(obj)[i][j]));
          fi;
        fi;
      od;
    od;
    # Then traverse the title rows
    for i in [1 .. Length(ColumnTitles(obj))] do
      for j in [1 .. Length(ColumnTitles(obj)[i])] do
        if IsBound(ColumnTitles(obj)[i][j]) and
          Length(String(ColumnTitles(obj)[i][j])) < SizeScreen()[1] - 4 then
          if IsBound(widths[j]) then
            widths[j] := Maximum(widths[j],
              Length(String(ColumnTitles(obj)[i][j])));
          else
            widths[j] := Length(String(ColumnTitles(obj)[i][j]));
          fi;
        fi;
      od;
    od;
    # Then traverse the other rows
    for i in [1 .. rows] do
      # In a row first traverse the title cells
      if IsBound(RowTitles(obj)[i]) then
        for j in [1 .. Length(RowTitles(obj)[i])] do
          if IsBound(RowTitles(obj)[i][j]) and
            Length(String(RowTitles(obj)[i][j])) < SizeScreen()[1] - 4 then
            if IsBound(titlewidths[j]) then
              titlewidths[j] := Maximum(titlewidths[j],
                Length(String(RowTitles(obj)[i][j])));
            else
              titlewidths[j] := Length(String(RowTitles(obj)[i][j]));
            fi;
          fi;
        od;
      fi;
      # Then traverse the other cells
      if IsBound(obj[i]) then
        for j in [1 .. Length(obj[i])] do
          if IsBound(obj[i][j]) and Length(String(obj[i][j])) <
            SizeScreen()[1] - 4 then
            if IsBound(widths[j])  then
              widths[j] := Maximum(widths[j], Length(String(obj[i][j])));
            else
              widths[j] := Length(String(obj[i][j]));
            fi;
          fi;
        od;
      fi;
    od;
    # Print the table
    s := InputTextUser();
    shownrows := 0; showncols := 0;
    x := 1; y := 1;
    while shownrows < rows do
      width := 0;
      # Calculate number of columns to be displayed
      numcols := 0;
      for j in [1 .. titlecols] do
        if IsBound(titlewidths[j]) then
          width := width + titlewidths[j];
        else
          width := width + 1;
        fi;
        width := width + 3;
      od;
      j := showncols + 1;
      if IsBound(widths[j]) then
        nextwidth := width + widths[j];
      else
        nextwidth := width + 1;
      fi;
      repeat
        j := j + 1;
        numcols := numcols + 1;
        width := nextwidth;
        nextwidth := nextwidth + 3;
        if IsBound(widths[j]) then
          nextwidth := nextwidth + widths[j];
        else
          nextwidth := nextwidth + 1;
        fi;
      until showncols + numcols = cols or nextwidth >= SizeScreen()[1] - 1;
      # Print the titl
      for i in [1 .. titlerows] do
        for j in [1 .. titlecols] do
          if IsBound(Title(obj)[i][j]) then
            if Length(String(Title(obj)[i][j])) < SizeScreen() - 4 then
              Print(String(Title(obj)[i][j]));
              max := titlewidths[j] - Length(String(Title(obj)[i][j]));
            else
              Print("*");
              max := titlewidths[j] - 1;
            fi;
          else
            if IsBound(widths[j]) then
              max := titlewidths[j];
            else
              max := 1;
            fi;
          fi;
          for k in [1 .. max] do
            Print(" ");
          od;
          # Print delimeter
          if j < titlecols then
            Print("   ");
          else
            Print(" | ");
          fi;
        od;
        # Print the i-th title row
        for j in [showncols + 1 .. showncols + numcols] do
          if IsBound(ColumnTitles(obj)[i][j]) then
            if Length(String(ColumnTitles(obj)[i][j])) < SizeScreen() - 4 then
              Print(String(ColumnTitles(obj)[i][j]));
              max := widths[j] - Length(String(ColumnTitles(obj)[i][j]));
            else
              Print("*");
              max := widths[j] - 1;
            fi;
          else
            if IsBound(widths[j]) then
              max := widths[j];
            else
              max := 1;
            fi;
          fi;
          for k in [1 .. max] do
            Print(" ");
          od;
          # Print delimeter
          if j < showncols + numcols then
            Print(" . ");
          else
            Print("\n");
          fi;
        od;
      od;
      # Print borderline
      if titlerows > 0 then
        for k in [1 .. width] do
          Print("-");
        od;
        Print("\n");
      fi;
      # Print other rows
      numrows := Minimum(rows - shownrows, SizeScreen()[2] - 3 - titlerows - 1
        mod (titlerows + 1));
      for i in [shownrows + 1 .. shownrows + numrows] do
        # Print the title of the i-th row
        for j in [1 .. titlecols] do
          if IsBound(RowTitles(obj)[i][j]) then
            if Length(String(RowTitles(obj)[i][j])) < SizeScreen() - 4 then
              Print(String(RowTitles(obj)[i][j]));
              max := titlewidths[j] - Length(String(RowTitles(obj)[i][j]));
            else
              Print("*");
              max := titlewidths[j] - 1;
            fi;
          else
            if IsBound(titlewidths[j]) then
              max := titlewidths[j];
            else
              max := 1;
            fi;
          fi;
          for k in [1 .. max] do
            Print(" ");
          od;
          # Print delimeter
          if j < titlecols then
            Print(" . ");
          else
            Print(" | ");
          fi;
        od;
        # Print the contents of the i-th row
        for j in [showncols + 1 .. showncols + numcols] do
          if IsBound(obj[i][j]) then
            if Length(String(obj[i][j])) < SizeScreen()[1] - 4 then
              Print(String(obj[i][j]));
              max := widths[j] - Length(String(obj[i][j]));
            else
              Print("*");
              max := widths[j] - 1;
            fi;
          else
            if IsBound(widths[j]) then
              max := widths[j];
            else
              max := 1;
            fi;
          fi;
          for k in [1 .. max] do
            Print(" ");
          od;
          # Print delimeter
          if j < showncols + numcols then
            Print(" . ");
          else
            Print("\n");
          fi;
        od;
      od;
      # Wait on user
      if showncols + numcols < cols or shownrows + numrows < rows then
        Print("\n");
        Print("Showing page ", String(x), "/", String(y),
          ". Please press ENTER to view next page.\c");
        k := ReadLine(s);
        Print("\n");
      fi;
      # Update page information
      if showncols + numcols = cols then
        showncols := 0; y := 1;
        shownrows := shownrows + numrows; x := x + 1;
      else
        showncols := showncols + numcols; y := y + 1;
      fi;
    od;
  end);

#
# Print a representation of a GeneralizedTable
#
InstallMethod(PrintObj, "for a GeneralizedTable", true, [IsGeneralizedTable],
  0, function(obj)
    Print("<GeneralizedTable with ", String(NumberOfRows(obj)), " rows and ",
      String(NumberOfColumns(obj)), " columns>");
  end);
