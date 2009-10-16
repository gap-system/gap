#############################################################################
##
#A  table.gi                      for Tk                       Michael Ummels
##
#H  @(#)$Id: table.gi,v 1.19 2003/08/17 23:27:48 gap Exp $
##
#Y  Copyright 2002-03         Michael Ummels                  Aachen, Germany
##
##  An interface to access tables without bothering if a row is bound or not.
##

Revision.pkg_tk_gap_table_gi :=
  "@(#)$Id: table.gi,v 1.19 2003/08/17 23:27:48 gap Exp $";

# Representations for our objects
DeclareRepresentation("IsEasilyAccessibleTableRep", IsComponentObjectRep,
  ["rows"]);

#
# Create an EasilyAccessibleTable from a table (a list of list)
#
InstallMethod(EasilyAccessibleTable, "for a list of lists", true, [IsList], 0,
  function(list)
    local obj, i;

    obj := rec(rows := []);
    for i in [1 .. Length(list)] do
      if IsBound(list[i]) then
        if IsList(list[i]) then
          obj.rows[i] := ShallowCopy(list[i]);
        else
          obj.rows[i] := [ list[i] ];
        fi;
      fi;
    od;
    Objectify(NewType(EasilyAccessibleTableFamily, IsEasilyAccessibleTable and
      IsEasilyAccessibleTableRep and IsMutable), obj);
    return obj;
  end);

#
# Return the number of rows of an EasilyAccessibleTable
#
InstallMethod(NumberOfRows, "for an EasilyAccessibleTable", true,
  [IsEasilyAccessibleTable and IsEasilyAccessibleTableRep], 0, function(obj)
    local num, i;

    num := 0;
    for i in [1 .. Length(obj!.rows)] do
      if IsBound(obj!.rows[i]) and not obj!.rows[i] = [] then
        num := i;
      fi;
    od;
    return num;
  end);

#
# Return the number of columns of an EasilyAccessibleTable
#
InstallMethod(NumberOfColumns, "for an EasilyAccessibleTable", true,
  [IsEasilyAccessibleTable and IsEasilyAccessibleTableRep], 0, function(obj)
    local num, i;

    num := 0;
    for i in [1 .. Length(obj!.rows)] do
      if IsBound(obj!.rows[i]) then
        num := Maximum(num, Length(obj!.rows[i]));
      fi;
    od;
    return num;
  end);

#
# Return the number of rows of an EasilyAccessibleTable
#
InstallMethod(Length, "for a EasilyAccessibleTable", true,
  [IsEasilyAccessibleTable], 0, function(obj)
    return NumberOfRows(obj);
  end);

#
# Return a certain row of an EasilyAccessibleTable
#
InstallMethod(\[\], "for an EasilyAccessibleTable and a positive integer",
  true, [IsEasilyAccessibleTable and IsEasilyAccessibleTableRep, IsPosInt], 0,
  function(obj, pos)
    if not IsBound(obj!.rows[pos]) then
      obj!.rows[pos] := [];
    fi;
    return obj!.rows[pos];
  end);

#
# Rows are always bound in EasilyAccessibleTables
#
InstallMethod(IsBound\[\], "for an EasilyAccessibleTable and a positive \
integer", true, [IsEasilyAccessibleTable,  IsPosInt], 0, function(obj, pos)
    return true;
  end);

#
# Set a row of an EasilyAccessibleTable
#
InstallMethod(\[\]\:\=, "for a mutable EasilyAccessibleTable, a positive \
integer and a list", true,
  [IsEasilyAccessibleTable and IsEasilyAccessibleTableRep and IsMutable,
  IsPosInt, IsList], 0, function(obj, pos, list)
    obj!.rows[pos] := list;
  end);

#
# Rows of an EasilyAccessibleTable cannot be unbound
#
InstallMethod(Unbind\[\], "for a mutable EasilyAccessible and a positive \
integer", true, [IsEasilyAccessibleTable and IsEasilyAccessibleTableRep and
  IsMutable, IsPosInt], 0, function(obj, pos)
    Error("you can only unbind cells of <EasilyAccessibleTable>");
  end);

#
# Print a representation of an EasilyAccessibleTable
#
InstallMethod(PrintObj, "for an EasilyAccessibleTable", true,
  [IsEasilyAccessibleTable and IsEasilyAccessibleTableRep], 0, function(obj)
    local i, j, cnt;

    Print("[ ");
    cnt := 0;
    for i in [1 .. Length(obj!.rows)] do
      if IsBound(obj!.rows[i]) and not obj!.rows[i] = [] then
        # Print all preceeding empty rows
        if i > cnt + 1 then
          Print(", ");
        fi;
        for j in [1 .. cnt] do
          Print("[  ], ");
        od;
        Print(obj!.rows[i]);
        cnt := 0;
      else
        # Remember that you had cnt + 1 empty rows since last non-empty rows
        cnt := cnt + 1;
      fi;
    od;
    Print(" ]");
  end);
