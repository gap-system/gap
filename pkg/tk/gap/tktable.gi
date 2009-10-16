#############################################################################
##
#A  tktable.gi                    for Tk                       Michael Ummels
##
#H  @(#)$Id: tktable.gi,v 1.33 2003/10/22 20:19:45 gap Exp $
##
#Y  Copyright 2002-03         Michael Ummels                  Aachen, Germany
##
##  An interface to display generalized tables with the Tk toolkit.
##

Revision.pkg_tk_gap_tktable_gi :=
  "@(#)$Id: tktable.gi,v 1.33 2003/10/22 20:19:45 gap Exp $";

# Representations for our objects
DeclareRepresentation("IsTkTableRep", IsComponentObjectRep,
  ["tkwindow", "tkframe", "tktable", "tkscrollh", "tkscrollv", "id", "table",
  "rows", "cols", "titlerows", "titlecols", "colwidths", "justification",
  "menuitems", "bindings"]);

# Install some global values
InstallValue(TkTableIndices, []);

#
# Create a TkTable from a generalized table
#
InstallMethod(TkTable, "for a generalized table", [IsGeneralizedTable], 0,
  function(table)
    local t, enclrows, enclcols;

    enclrows := function(obj)
      local hrows, srows, i, start, stop, result;

      hrows := HiddenRows(obj);
      srows := Difference(SelectedRows(obj), hrows);
      result := [];
      start := 0;
      for i in [1 .. (Length(srows) + 1)] do
        if i > Length(srows) then
          stop := obj!.rows + 1;
        else
          stop := srows[i];
        fi;
        if IsSubsetSet(hrows, [(start + 1) .. (stop - 1)]) then
          UniteSet(result, [(start + 1) .. (stop - 1)]);
        fi;
        start := stop;
      od;
      return result;
    end;

    enclcols := function(obj)
      local hcols, scols, i, start, stop, result;

      hcols := HiddenColumns(obj);
      scols := Difference(SelectedColumns(obj), hcols);
      result := [];
      start := 0;
      for i in [1 .. (Length(scols) + 1)] do
        if i > Length(scols) then
          stop := obj!.cols + 1;
        else
          stop := scols[i];
        fi;
        if IsSubsetSet(hcols, [(start + 1) .. (stop - 1)]) then
          UniteSet(result, [(start + 1) .. (stop - 1)]);
        fi;
        start := stop;
      od;
      return result;
    end;

    # Create TkTable object
    t := rec(table := table, menuitems := [], bindings := [], justification :=
      TKTABLE_LEFT_JUSTIFIED, id := 0, rows := 0, cols := 0, titlerows := 0,
      titlecols := 0, colwidths := [], tkwindow := 0, tkframe := 0,
      tktable := 0, tkscrollh := 0, tkscrollv := 0);
    Objectify(NewType(TkTableFamily, IsTkTable and IsTkTableRep), t);
    # Register menu items
    RegisterMenuItem(t, "Hide", function(obj, cell)
      HideRows(obj, SelectedRows(obj));
      HideColumns(obj, SelectedColumns(obj));
    end, function(obj, cell)
      return cell[1] in SelectedRows(obj) or cell[2] in SelectedColumns(obj);
    end);
    RegisterMenuItem(t, "Unhide", function(obj, cell)
      UnhideRows(obj, enclrows(obj));
      UnhideColumns(obj, enclcols(obj));
    end, function(obj, cell)
      return (cell[1] in SelectedRows(obj) or cell[2] in SelectedColumns(obj))
        and not (enclrows(obj) = [] and enclcols(obj) = []);
    end);
    return t;
  end);

#
# Create a TkTable from a table given by a list of lists
#
InstallMethod(TkTable, "for a list", [IsList], 0,
  function(list)
    return TkTable(GeneralizedTable(list));
  end);

#
# Show a TkTable on the screen
#
InstallMethod(Show, "for a TkTable", true, [IsTkTable and IsTkTableRep], 0,
  function(obj)
    local index, tkmenu, destroy, popupmenu, findcell, i, j;

    # Determines the cell that lies under the window position (x,y)
    findcell := function(x, y)
      local cell, row, col, cmd;

      cmd := Concatenation(String(obj!.tktable), " index ", "@", String(x),
        ",", String(y));
      row := Int(TkValue(Concatenation("[", cmd, " row", "]")));
      col := Int(TkValue(Concatenation("[", cmd, " col", "]")));
      return [row - obj!.titlerows, col - obj!.titlecols];
    end;

    # Delete Tk objects, when window is closed
    destroy := function(env)
      TkDelete(tkmenu);
      TkDelete(obj!.tkscrollh);
      TkDelete(obj!.tkscrollv);
      TkDelete(obj!.tktable);
      TkDelete(obj!.tkframe);
      TkDelete(obj!.tkwindow);
      ResetFilterObj(obj, IsDisplayed);
      # Unset the Tcl array
      Tk("unset", Concatenation("values", String(obj!.id)));
      RemoveSet(TkTableIndices, obj!.id);
      obj!.id := 0;
      obj!.rows := 0; obj!.cols := 0;
      obj!.titlerows := 0; obj!.titlecols := 0;
      obj!.colwidths := [];
    end;

    # Generate a popup menu
    popupmenu := function(env)
      local cell, i;

      if not obj!.menuitems = []
        then
        Tk(tkmenu, "delete", 1, "end");
        cell := findcell(env.x, env.y);
        for i in [1 .. Length(obj!.menuitems)] do
          if CallFuncList(obj!.menuitems[i].test, [obj, cell]) then
            Tk(tkmenu, "add command", rec(label :=obj!.menuitems[i].caption,
              command := obj!.menuitems[i].func, args := [obj, cell]));
          else
            Tk(tkmenu, "add command", rec(label := obj!.menuitems[i].caption,
              state := "disabled"));
          fi;
        od;
        Tk("tk_popup", tkmenu, env.xroot, env.yroot);
      fi;
    end;

    # Initialize Tk
    if Tk("package require", "Tktable") = fail then
      Error("TkTable: Tk was unable to load the Tktable extension\n");
    fi;
    AddSet(TkPossibleWidgetTypes, "table");
    # Display the table
    if not IsDisplayed(obj) then
      # Use new index for Tk array
      if TkTableIndices = [] then
        index := 1;
      else
        index := Minimum(Difference([1 .. Maximum(TkTableIndices) + 1],
          TkTableIndices));
      fi;
      AddSet(TkTableIndices, index);
      obj!.id := index;
      # Create Tk objects
      obj!.tkwindow := TkWidget("toplevel");
      Tk("wm", "title", obj!.tkwindow, "{GAP}");
      Tk("wm state",obj!.tkwindow,"withdrawn");
      obj!.tkframe := TkWidget("frame", obj!.tkwindow);
      obj!.tktable := TkWidget("table", obj!.tkframe, rec(rows := 2, cols := 2,
        titlerows := 1, titlecols := 1, roworigin := 1, colorigin := 1,
        variable := Concatenation("values", String(obj!.id)), width := 0,
        height := 0, state := "disabled", colstretchmode := "last",
        rowstretchmode := "last", selectmode := "extended"));
      # Define tags
      Tk(obj!.tktable, "configure -background #ffffff");
      Tk(obj!.tktable, "tag configure title", rec(background := "#dcdcdc",
        foreground := "#000000", borderwidth := 1, relief := "sunken",
        anchor := "c"));
      Tk(obj!.tktable, "tag configure hidden", rec(background := "#999999",
        foreground := "#999999", borderwidth := 0));
      Tk(obj!.tktable, "tag configure border", rec(background := "#dcdcdc",
        foreground := "#dcdcdc"));
      Tk(obj!.tktable, "tag configure left", rec(anchor := "w"));
      Tk(obj!.tktable, "tag configure right", rec(anchor := "e"));
      Tk(obj!.tktable, "tag configure center", rec(anchor := "c"));
      # Create and link scrollbars
      obj!.tkscrollh := TkWidget("scrollbar", obj!.tkframe,
        "-orient horizontal");
      obj!.tkscrollv := TkWidget("scrollbar", obj!.tkframe,
        "-orient vertical");
      TkGrid(obj!.tktable, rec(row := 0, column := 0, sticky := "news"));
      TkGrid(obj!.tkscrollh, rec(row := 1, column := 0, sticky := "ew"));
      TkGrid(obj!.tkscrollv, rec(row := 0, column := 1, sticky := "ns"));
      # Bind frame to window
      Tk("grid", "rowconfigure", obj!.tkframe, 0, rec(weight := 1));
      Tk("grid", "columnconfigure", obj!.tkframe, 0, rec(weight := 1));
      # Link scrollbars with table
      TkLink(obj!.tktable, obj!.tkscrollh, "h");
      TkLink(obj!.tktable, obj!.tkscrollv, "v");
      # Bind events
      tkmenu := TkWidget("menu", obj!.tkwindow);
      TkBind(obj!.tktable, "<ButtonPress-3>", popupmenu);
      TkBind(obj!.tkwindow, "<Destroy>", destroy);
      SetFilterObj(obj, IsDisplayed);
      # Load contents of table
      Update(obj);
      # Display the table
      TkPack(obj!.tkframe, rec(fill := "both", expand := 1));
      Tk("wm state",obj!.tkwindow,"normal");
    fi;
  end);

#
# Create a TkTable from a generalized table or a list and show it on the screen
#
InstallMethod(ShowTkTable, "for a list", [IsList], 0,
  function(list)
    local t;

    t := TkTable(list);
    Show(t);
    return t;
  end);

#
# Update the contents of a TkTable
#
InstallMethod(Update, "for a TkTable", [IsTkTable and IsTkTableRep and
  IsDisplayed], 0, function(obj)
    local i, j, command, temp;

    # Reset TkTable
    Tk(obj!.tktable, "height", obj!.titlerows + obj!.rows + 1, 1);
    Tk(obj!.tktable, "tag row {}", obj!.titlerows + obj!.rows + 1);
    Tk(obj!.tktable, "tag col {}", obj!.titlecols + obj!.cols + 1);
    # Determine number of (title) rows and cols
    obj!.rows := Maximum(NumberOfRows(obj!.table),
      NumberOfRows(RowTitles(obj!.table)));
    obj!.cols := Maximum(NumberOfColumns(obj!.table),
      NumberOfColumns(ColumnTitles(obj!.table)));
    obj!.colwidths := [];
    obj!.titlerows := Maximum(NumberOfRows(Title(obj!.table)),
      NumberOfRows(ColumnTitles(obj!.table)), 1);
    obj!.titlecols := Maximum(NumberOfColumns(Title(obj!.table)),
      NumberOfColumns(RowTitles(obj!.table)), 1);
    # Unset Tcl array
    Tk("unset", Concatenation("values", String(obj!.id)));
    command := Concatenation("array set ","values", String(obj!.id), " { ");
    # Label origin of the table
    for i in [1 .. obj!.titlerows] do
      for j in [1 .. Length(Title(obj!.table)[i])] do
        if IsBound(Title(obj!.table)[i][j]) then
          Append(command, Concatenation( String(i), ",", String(j), " {",
            String(Title(obj!.table)[i][j]), "} "));
          if (not IsBound(obj!.colwidths[j])) or
            Length(String(Title(obj!.table)[i][j])) + 2 > obj!.colwidths[j]
            then
            obj!.colwidths[j] := Length(String(Title(obj!.table)[i][j]))+ 2;
          fi;
        fi;
      od;
    od;
    # Create column labels
    for i in [1 .. obj!.titlerows] do
        for j in [1 .. Length(ColumnTitles(obj!.table)[i])] do
          if IsBound(ColumnTitles(obj!.table)[i][j]) then
            Append(command, Concatenation(String(i), ",",
              String(obj!.titlecols + j), " {",
              String(ColumnTitles(obj!.table)[i][j]), "} "));
            if (not IsBound(obj!.colwidths[obj!.titlecols + j])) or
              Length(String(ColumnTitles(obj!.table)[i][j])) + 2 >
              obj!.colwidths[obj!.titlecols + j] then
              obj!.colwidths[obj!.titlecols + j] :=
                Length(String(ColumnTitles(obj!.table)[i][j])) + 2;
            fi;
          fi;
        od;
    od;
    # Create TkTable
    for i in [1 .. obj!.rows] do
      # Create row label
      for j in [1 .. Length(RowTitles(obj!.table)[i])] do
        if IsBound(RowTitles(obj!.table)[i][j]) then
          Append(command, Concatenation(String(obj!.titlerows + i), ",",
            String(j), " {", String(RowTitles(obj!.table)[i][j]), "} "));
          if (not IsBound(obj!.colwidths[j])) or
            Length(String(RowTitles(obj!.table)[i][j])) + 2 > obj!.colwidths[j]
            then
            obj!.colwidths[j] := Length(String(RowTitles(obj!.table)[i][j])) +
              2;
          fi;
        fi;
      od;
      # Create table entries for current row
      for j in [1 .. Length(obj!.table[i])] do
        if IsBound(obj!.table[i][j]) then
          Append(command, Concatenation(String(obj!.titlerows + i), ",",
            String(obj!.titlecols + j), " {", String(obj!.table[i][j]), "} "));
          # Change column width
          if (not IsBound(obj!.colwidths[obj!.titlecols + j])) or
            Length(String(obj!.table[i][j])) + 2 >
            obj!.colwidths[obj!.titlecols + j] then
            obj!.colwidths[obj!.titlecols + j] :=
              Length(String(obj!.table[i][j])) + 2;
          fi;
        fi;
      od;
    od;
    Tk(command, "}");
    # Update Tktable object
    Tk(obj!.tktable, "configure", rec(rows := obj!.rows + obj!.titlerows + 1,
      cols := obj!.cols + obj!.titlecols + 1, titlerows := obj!.titlerows,
      titlecols := obj!.titlecols));
    if obj!.justification = TKTABLE_LEFT_JUSTIFIED then
      Tk(obj!.tktable, "configure", rec(anchor := "w"));
    elif obj!.justification = TKTABLE_CENTERED then
      Tk(obj!.tktable, "configure", rec(anchor := "c"));
    else
      Tk(obj!.tktable, "configure", rec(anchor := "e"));
    fi;
    # Format rows
    Tk(obj!.tktable, "height", obj!.titlerows + obj!.rows + 1, -1);
    Tk(obj!.tktable, "tag row border", obj!.titlerows + obj!.rows + 1);
    # Format columns
    Tk(obj!.tktable, "width", obj!.titlecols + obj!.cols + 1, -1);
    Tk(obj!.tktable, "tag col border", obj!.titlecols + obj!.cols + 1);
    for j in [1 .. obj!.cols + obj!.titlecols] do
      if IsBound(obj!.colwidths[j]) then
        Tk(obj!.tktable, "width", j, obj!.colwidths[j]);
      else
        Tk(obj!.tktable, "width", j, TKTABLE_MINIMUM_WIDTH);
      fi;
    od;
  end);

InstallMethod(Update, "for a TkTable", true, [IsTkTable and IsTkTableRep], 0,
  function(obj)
    Error("Update: <TkTable> is not displayed");
  end);

#
# Hide a TkTable
#
InstallMethod(Hide, "for a TkTable", true, [IsTkTable and IsTkTableRep], 0,
  function(obj)
    if IsDisplayed(obj) then
      TkDelete(obj!.tkwindow);
    fi;
  end);

#
# Set the window title of a TkTable
#
InstallMethod(SetWindowTitle, "for a TkTable and a String", true,
  [IsTkTable and IsTkTableRep, IsString], 0, function(obj, str)
    Tk("wm title", obj!.tkwindow, Concatenation("\"", ReplacedString(str, "\"",
      "\\\""), "\""));
  end);


#
# Registers a new event to a TkApplication
#
InstallMethod(RegisterEvent, "for a TkTable, a TkEvent and a function", true,
  [IsTkTable and IsTkTableRep, IsTkEvent, IsFunction], 0,
  function(obj, event, func)
    local result;

    if not IsRegisteredEvent(obj, event) and not event = TkEvent("ButtonPress",
      "3") then
      if NumberArgumentsFunction(func) = 3 then
        result := function(env)
          local cmd, row, col;

          cmd := Concatenation(String(obj!.tktable), " index ", "@",
            String(env.x), ",", String(env.y));
          row := Int(TkValue(Concatenation("[", cmd, " row", "]")));
          col := Int(TkValue(Concatenation("[", cmd, " col", "]")));
          func(obj, env, [row - obj!.titlerows, col - obj!.titlecols]);
        end;
      else
        result := function(env) func(obj, env); end;
      fi;
      AddSet(obj!.bindings, event);
      return TkBind(obj!.tktable, Concatenation("<", Code(event), ">"), result);
    elif event = TkEvent("ButtonPress", "3") then
      Error("RegisterEvent: This event cannot be registered to <TkTable>");
    else
      Error("RegisterEvent: Event is already registered");
    fi;
  end);

#
# Return whether an event is registered by a TkApplication
#
InstallMethod(IsRegisteredEvent, "for a TkTable and a TkEvent", true,
  [IsTkTable and IsTkTableRep, IsTkEvent], 0, function(obj, event)
    return event in obj!.bindings;
  end);

#
# Unregisters an event from a TkApplication
#
InstallMethod(UnregisterEvent, "for a TkTable and a TkEvent", true,
  [IsTkTable and IsTkTableRep, IsTkEvent], 0, function(obj, event)
    RemoveSet(obj!.bindings, event);
    Tk("bind", obj!.tktable, Concatenation("<", Code(event), ">"), "{}");
  end);

#
# Insert a TkMenuFunction as a menu item of a TkTable
#
InstallMethod(RegisterMenuItem, "for a TkApplication, a string, a function, a \
function and a positive integer", true, [IsTkApplication and IsTkTableRep,
  IsString, IsFunction, IsFunction, IsPosInt], 0,
  function(obj, caption, func, test, ind)
    local l, i;

    if ind > Length(obj!.menuitems) then
      obj!.menuitems[l + 1] := rec(caption := caption, func := func, test :=
        test);
    else
      # Move elements
      l := Length(obj!.menuitems);
      for i in [0 .. l - ind] do
        obj!.menuitems[l - i + 1] := obj!.menuitems[l - i];
      od;
      obj!.menuitems[ind] := rec(caption := caption, func := func, test :=
        test);
    fi;
  end);

InstallMethod(RegisterMenuItem, "for a TkApplication, a string, a function \
and a positive integer", true, [IsTkApplication, IsString, IsFunction,
  IsPosInt], 0, function(obj, caption, func, ind)
    RegisterMenuItem(obj, caption, func, ReturnTrue, ind);
  end);

InstallMethod(RegisterMenuItem, "for a TkApplication, a string, a function \
and a function", true, [IsTkApplication and IsTkTableRep, IsString,
  IsFunction, IsFunction], 0, function(obj, caption, func, test)
    Add(obj!.menuitems, rec(caption := caption, func := func, test := test));
  end);

InstallMethod(RegisterMenuItem, "for a TkApplication, a string and a function",
  true, [IsTkApplication, IsString, IsFunction], 0,
  function(obj, caption, func)
    RegisterMenuItem(obj, caption, func, ReturnTrue);
  end);

#
# Remove a certain menu item of a TkTable
#
InstallMethod(UnregisterMenuItem, "for a TkApplication and a positive integer",
  true, [IsTkApplication and IsTkTableRep, IsPosInt], 0,
  function(obj, ind)
    local i;

    if ind <= Length(obj!.menuitems) then
      for i in [ind .. (Length(obj!.menuitems) - 1)] do
        obj!.menuitems[i] := obj!.menuitems[i + 1];
      od;
      Unbind(obj!.menuitems[Length(obj!.menuitems)]);
    fi;
  end);

InstallMethod(UnregisterMenuItem, "for a TkApplication and a String", true,
  [IsTkApplication and IsTkTableRep, IsString], 0,
  function(obj, text)
    local i;

    i := 1;
    while i <= Length(obj!.menuitems) and not obj!.menuitems[i].caption = text
      do
      i := i + 1;
    od;
    if i <= Length(obj!.menuitems) then
      UnregisterMenuItem(obj, i);
    else
      Error(Concatenation("UnregisterMenuItem: No method with caption ", text,
        " found\n"));
    fi;
  end);

#
# Update cells of a TkTable
#
InstallMethod(UpdateCells, "for a TkTable and a list", [IsTkTable and
  IsTkTableRep and IsDisplayed, IsList], 0, function(obj, cells)
    local cell, i, j, command, wcommand;

    command := Concatenation("array set values", String(obj!.id), " { ");
    wcommand := "";
    for cell in cells do
      if cell[1] in [-obj!.titlerows + 1 .. obj!.rows] and cell[2] in
        [-obj!.titlecols + 1 .. obj!.cols] then
        i := cell[1]; j := cell[2];
        if i < 1 and j < 1 then
          # Change a cell of the table title
          if IsBound(Title(obj!.table)[obj!.titlerows + i][obj!.titlecols + j])
            then
            Append(command, Concatenation(String(obj!.titlerows + i), ",",
              String(obj!.titlecols + j), " {", String(Title(obj!.table)
              [obj!.titlerows + i][obj!.titlecols + j]), "} "));
            # Change column width
            if (not IsBound(obj!.colwidths[obj!.titlecols + j])) or
              Length(String(Title(obj!.table)[obj!.titlerows + i]
              [obj!.titlecols + j])) + 2 > obj!.colwidths[obj!.titlecols + j]
              then
              obj!.colwidths[obj!.titlecols + j] :=
                Length(String(Title(obj!.table)[obj!.titlerows + i]
                [obj!.titlecols + j])) + 2;
              Append(wcommand, Concatenation(String(obj!.titlecols + j), " ",
                String(obj!.colwidths[obj!.titlecols + j]), " "));
            fi;
          else
            Append(command, Concatenation(String(obj!.titlerows + i), ",",
              String(obj!.titlecols + j), " { } "));
          fi;
        elif i < 1 and j >= 1 then
          # Change a cell of the column titles
          if IsBound(ColumnTitles(obj!.table)[obj!.titlerows + i][j]) then
            Append(command, Concatenation(String(obj!.titlerows + i), ",",
              String(obj!.titlecols + j), " {", String(ColumnTitles(obj!.table)
              [obj!.titlerows + i][j]), "} "));
            # Change column width
            if (not IsBound(obj!.colwidths[obj!.titlecols + j])) or
              Length(String(ColumnTitles(obj!.table)[obj!.titlerows + i][j])) +
              2 > obj!.colwidths[obj!.titlecols + j] then
              obj!.colwidths[obj!.titlecols + j] :=
                Length(String(ColumnTitles(obj!.table)[obj!.titlerows + i][j]))
                + 2;
              Append(wcommand, Concatenation(String(obj!.titlecols + j), " ",
                String(obj!.colwidths[obj!.titlecols + j]), " "));
            fi;
          else
            Append(command, Concatenation(String(obj!.titlerows + i), ",",
              String(j), " { } "));
          fi;
        elif i >= 1 and j < 1 then
          # Change a cell of the rows titles
          if IsBound(RowTitles(obj!.table)[i][obj!.titlecols + j]) then
            Append(command, Concatenation(String(obj!.titlerows + i), ",",
              String(obj!.titlecols + j), " {", String(RowTitles(obj!.table)[i]
              [obj!.titlecols + j]), "} "));
            # Change column width
            if (not IsBound(obj!.colwidths[obj!.titlecols + j])) or
              Length(String(RowTitles(obj!.table)[i][obj!.titlecols + j])) + 2 >
              obj!.colwidths[obj!.titlecols + j] then
              obj!.colwidths[obj!.titlecols + j] :=
                Length(String(RowTitles(obj!.table)[i][obj!.titlecols + j]))
                + 2;
              Append(wcommand, Concatenation(String(obj!.titlecols + j), " ",
                String(obj!.colwidths[obj!.titlecols + j]), " "));
            fi;
          else
            Append(command, Concatenation(String(i), ",", String(obj!.titlecols
            + j), " { } "));
          fi;
        else
          # Change a cell of the table body
          if IsBound(obj!.table[i][j]) then
            Append(command, Concatenation(String(obj!.titlerows + i), ",",
              String(obj!.titlecols + j), " {", String(obj!.table[i][j]),
              "} "));
            # Change column width
            if (not IsBound(obj!.colwidths[obj!.titlecols + j])) or
              Length(String(obj!.table[i][j])) + 2 >
              obj!.colwidths[obj!.titlecols + j] then
              obj!.colwidths[obj!.titlecols + j] :=
                Length(String(obj!.table[i][j])) + 2;
              Append(wcommand, Concatenation(String(obj!.titlecols + j), " ",
                String(obj!.colwidths[obj!.titlecols + j]), " "));
            fi;
          else
            Append(command, Concatenation(String(obj!.titlerows + i), ",",
              String(obj!.titlecols + j), " { } "));
          fi;
        fi;
      else
        Error("UpdateCell: No such cell in <TkTable>");
      fi;
    od;
    Tk(command, "}");
    if not wcommand = "" then
      Tk(obj!.tktable, "width", wcommand);
    fi;
  end);

#
# Update a cells of a TkTable
#
InstallMethod(UpdateCell, "for a TkTable and a pair of positive integers",
  [IsTkTable and IsTkTableRep and IsDisplayed, IsList], 0,
  function(obj, cell)
    UpdateCells(obj, [ cell ]);
  end);

#
# Update rows of a TkTable
#
InstallMethod(UpdateRows, "for a TkTable and a list", [IsTkTable and IsTkTableRep
  and IsDisplayed, IsList], 0, function(obj, rows)
    UpdateCells(obj, Cartesian(rows, [-obj!.titlecols + 1 .. obj!.cols]));
  end);

#
# Update a row of a TkTable
#
InstallMethod(UpdateRow, "for a TkTable and an integer", [IsTkTable and
  IsTkTableRep and IsDisplayed, IsInt], 0, function(obj, row)
    UpdateRows(obj, [ row ]);
  end);

#
# Update columns of a TkTable
#
InstallMethod(UpdateColumns, "for a TkTable and a list", [IsTkTable and
  IsTkTableRep and IsDisplayed, IsList], 0, function(obj, cols)
    UpdateCells(obj, Cartesian([-obj!.titlerows + 1 .. obj!.rows], cols));
  end);

#
# Update a column of a TkTable
#
InstallMethod(UpdateColumn, "for a TkTable and an integer", [IsTkTable and
  IsTkTableRep and IsDisplayed, IsInt], 0, function(obj, col)
    UpdateColumns(obj, [ col ]);
  end);

#
# Scroll to a cell of a TkTable
#
InstallMethod(ScrollToCell, "for a TkTable and a pair of positive integers",
  [IsTkTable and IsTkTableRep and IsDisplayed, IsList], 0, function(obj, cell)
    if cell[1] in [1 .. obj!.rows] and cell[2] in [1 .. obj!.cols] then
      Tk(obj!.tktable, "see", Concatenation(String(cell[1] + obj!.titlerows),
        ",", String(cell[2] + obj!.titlecols)));
    else
      Error("ScrollToCell: No such cell in <TkTable>");
    fi;
  end);

InstallMethod(ScrollToCell, "for a TkTable and a pair of positive integers",
  [IsTkTable and IsTkTableRep, IsList], 0, function(obj, cell)
    Error("ScrollToCell: <TkTable> is not displayed");
  end);

#
# Select a cell of a TkTable
#
InstallMethod(SelectCell, "for a TkTable and a pair of positive integers",
  [IsTkTable and IsTkTableRep and IsDisplayed, IsList], 0, function(obj, cell)
    if cell[1] in [1 .. obj!.rows] and cell[2] in [1 .. obj!.cols] then
      Tk(obj!.tktable, "selection set", Concatenation(String(cell[1] +
        obj!.titlerows), ",", String(cell[2] + obj!.titlecols)));
    else
      Error("SelectCell: No such cell in <TkTable>");
    fi;
  end);

InstallMethod(SelectCell, "for a TkTable and a pair of positive integers",
  [IsTkTable and IsTkTableRep, IsList], 0, function(obj, cell)
    Error("SelectCell: <TkTable> is not displayed");
  end);

#
# Deselect a cell of a TkTable
#
InstallMethod(DeselectCell, "for a TkTable and a pair of positive integers",
  [IsTkTable and IsTkTableRep, IsList], 0, function(obj, cell)
    if cell[1] in [1 .. obj!.rows] and cell[2] in [1 .. obj!.cols] then
      Tk(obj!.tktable, "selection clear", Concatenation(String(cell[1] +
        obj!.titlerows), ",", String(cell[2] + obj!.titlecols)));
    else
      Error("SelectCell: No such cell in <TkTable>");
    fi;
  end);

InstallMethod(DeselectCell, "for a TkTable and a pair of positive integers",
  [IsTkTable and IsTkTableRep, IsList], 0, function(obj, cell)
    Error("DeselectCell: <TkTable> is not displayed");
  end);

#
# Return whether a cell of a TkTable is selected
#
InstallMethod(IsSelectedCell, "for a TkTable and a pair of positive integers",
  [IsTkTable, IsList], 0, function(obj, cell)
    if cell[1] in [1 .. obj!.rows] and cell[2] in [1 .. obj!.cols] then
      return cell in SelectedCells(obj);
    else
      Error("IsSelectedCell: No such cell in <TkTable>");
    fi;
  end);

#
# Select cells of a TkTable
#
InstallMethod(SelectCells, "for a TkTable and a list of pairs of positive \
  integers", [IsTkTable, IsList], 0, function(obj, cells)
    local cell;

    for cell in cells do
      SelectCell(obj, cell);
    od;
  end);

#
# Deselect cells of a TkTable
#
InstallMethod(DeselectCells, "for a TkTable and a list of pairs of positive \
  integers", [IsTkTable, IsList], 0, function(obj, cells)
    local cell;

    for cell in cells do
      DeselectCell(obj, cell);
    od;
  end);

#
# Return all selected cells of a TkTable
#
InstallMethod(SelectedCells, "for a TkTable", true, [IsTkTable and IsTkTableRep
  and IsDisplayed], 0, function(obj)
    local cells, text, cell, x, y, pair;

    cells := [];
    # Get selected cells from Tk as string
    text := SplitString(TkValue(Concatenation("[", String(obj!.tktable),
      " curselection", "]")), " ");
    # Extract row and col numbers
    for cell in text do
      pair := SplitString(cell, ",");
      x := Int(pair[1]) - obj!.titlerows;
      y := Int(pair[2]) - obj!.titlecols;
      if (x <= obj!.rows) and (y <= obj!.cols) then
        AddSet(cells, [x, y]);
      fi;
    od;
    return cells;
  end);

InstallMethod(SelectedCells, "for a TkTable", true, [IsTkTable and
  IsTkTableRep], 0, function(obj)
    Error("SelectedCells: <TkTable> is not displayed");
  end);

#
# Select a row of a TkTable
#
InstallMethod(SelectRow, "for a TkTable and a positive integer", [IsTkTable and
  IsTkTableRep and IsDisplayed, IsPosInt], 0, function(obj, row)
    if row in [1 .. obj!.rows] then
      Tk(obj!.tktable, "selection set", Concatenation(String(row +
        obj!.titlerows), ",", String(1 + obj!.titlecols)),
        Concatenation(String(row + obj!.titlerows), ",", String(obj!.cols +
        obj!.titlecols)));
    else
      Error("SelectRow: No such row in <TkTable>");
    fi;
  end);

InstallMethod(SelectRow, "for a TkTable and a positive integer", [IsTkTable and
  IsTkTableRep, IsPosInt], 0, function(obj, row)
    Error("SelectRow: <TkTable> is not displayed");
  end);

#
# Deselect a row of a TkTable
#
InstallMethod(DeselectRow, "for a TkTable and a positive integer", [IsTkTable
  and IsTkTableRep and IsDisplayed, IsPosInt], 0, function(obj, row)
    if row in [1 .. obj!.rows] then
      Tk(obj!.tktable, "selection clear", Concatenation(String(row +
        obj!.titlerows), ",", String(1 + obj!.titlecols)),
        Concatenation(String(row + obj!.titlerows), ",", String(obj!.cols +
        obj!.titlecols)));
    else
      Error("DeselectRow: No such row in <TkTable>");
    fi;
  end);

InstallMethod(DeselectRow, "for a TkTable and a positive integer", [IsTkTable
  and IsTkTableRep, IsPosInt], 0, function(obj, row)
    Error("DeselectRow: <TkTable> is not displayed");
  end);

#
# Return whether a row of a TkTable is selected
#
InstallMethod(IsSelectedRow, "for a TkTable and a positive integer",
  [IsTkTable, IsPosInt], 0, function(obj, row)
    if row in [1 .. obj!.rows] then
      return row in SelectedRows(obj);
    else
      Error("IsSelectedRow: No such row in <TkTable>");
    fi;
  end);

#
# Select rows of a TkTable
#
InstallMethod(SelectRows, "for a TkTable and a list of positive integers",
  [IsTkTable, IsList], 0, function(obj, rows)
    local row;

    for row in rows do
      SelectRow(obj, row);
    od;
  end);

#
# Deselect rows of a TkTable
#
InstallMethod(DeselectRows, "for a TkTable and a list of positive integers",
  [IsTkTable, IsList], 0, function(obj, rows)
    local row;

    for row in rows do
      DeselectRow(obj, row);
    od;
  end);

#
# Return all selected rows of a TkTable
#
InstallMethod(SelectedRows, "for a TkTable", true, [IsTkTable], 0,
  function(obj)
    local cells, rows, row, i, current;

    # Get selected cells and delete col component
    cells := SelectedCells(obj);
    Apply(cells, cell -> cell[1]);
    # Count occurences of the same row
    rows := [];
    i := 0; current := 0;
    for row in cells do
      if row <> current then
        i := 1; current := row;
      else
        i := i + 1;
      fi;
      if i = obj!.cols then
        AddSet(rows, current);
      fi;
    od;
    return rows;
  end);

#
# Select a column of a TkTable
#
InstallMethod(SelectColumn, "for a TkTable and a positive integer", [IsTkTable
  and IsTkTableRep and IsDisplayed, IsPosInt], 0, function(obj, col)
    if col in [1 .. obj!.cols] then
      Tk(obj!.tktable, "selection set", Concatenation(String(1 +
        obj!.titlerows), ",", String(col + obj!.titlecols)),
        Concatenation(String(obj!.rows + obj!.titlerows), ",", String(col +
        obj!.titlecols)));
    else
      Error("SelectColumn: No such column in <TkTable>");
    fi;
  end);

InstallMethod(SelectColumn, "for a TkTable and a positive integer", [IsTkTable
  and IsTkTableRep, IsPosInt], 0, function(obj, row)
    Error("SelectColumn: <TkTable> is not displayed");
  end);

#
# Deselect a column of a TkTable
#
InstallMethod(DeselectColumn, "for a TkTable and a positive integer", [IsTkTable
  and IsTkTableRep and IsDisplayed, IsPosInt], 0, function(obj, col)
    if col in [1 .. obj!.cols] then
      Tk(obj!.tktable, "selection clear", Concatenation(String(1 +
        obj!.titlerows), ",", String(col + obj!.titlecols)),
        Concatenation(String(obj!.rows + obj!.titlerows), ",", String(col +
        obj!.titlecols)));
    else
      Error("DeselectColumn: No such column in <TkTable>");
    fi;
  end);

InstallMethod(DeselectColumn, "for a TkTable and a positive integer", [IsTkTable
  and IsTkTableRep, IsPosInt], 0, function(obj, row)
    Error("DeselectColumn: <TkTable> is not displayed");
  end);

#
# Return whether a column of a TkTable is selected
#
InstallMethod(IsSelectedColumn, "for a TkTable and a positive integer",
  [IsTkTable, IsPosInt], 0, function(obj, col)
    if col in [1 .. obj!.cols] then
      return col in SelectedColumns(obj);
    else
      Error("IsSelectedColumn: No such column in <TkTable>");
    fi;
  end);

#
# Select columns of a TkTable
#
InstallMethod(SelectColumns, "for a TkTable and a list of positive integers",
  [IsTkTable, IsList], 0, function(obj, cols)
    local col;

    for col in cols do
      SelectColumn(obj, col);
    od;
  end);

#
# Deselect columns of a TkTable
#
InstallMethod(DeselectColumns, "for a TkTable and a list of positive integers",
  [IsTkTable, IsList], 0, function(obj, cols)
    local col;

    for col in cols do
      DeselectColumn(obj, col);
    od;
  end);

#
# Return all selected columns of a TkTable
#
InstallMethod(SelectedColumns, "for a TkTable", true, [IsTkTable], 0,
  function(obj)
    local cells, cols, col, i, current;
  
    # Get selected cells and delete row component
    cells := SelectedCells(obj);
    Apply(cells, cell -> cell[2]); Sort(cells);
    # Count occurences of the same col
    cols := [];
    i := 0; current := 0;
    for col in cells do
      if col <> current then
        i := 1; current := col;
      else
        i := i + 1;
      fi;
      if i = obj!.rows then
        AddSet(cols, current);
      fi;
    od;
    return cols;
  end);

#
# Return whether a row of a TkTable is hidden
#
InstallMethod(IsHiddenRow, "for a TkTable and a positive integer", true,
  [IsTkTable and IsTkTableRep and IsDisplayed, IsInt], 0,
  function(obj, row)
    if row in [-obj!.titlerows + 1 .. obj!.rows] then
      return Int(TkValue(Concatenation("[", String(obj!.tktable), " height ",
        String(obj!.titlerows + row), "]"))) = 0;
    else
      Error("IsHiddenRow: No such row in <TkTable>");
    fi;
  end);

InstallMethod(IsHiddenRow, "for a TkTable and a positive integer", true,
  [IsTkTable and IsTkTableRep, IsInt], 0,
  function(obj, row)
    Error("UnhideRows: <TkTable> is not displayed");
  end);

#
# Return all hidden rows of a TkTable
#
InstallMethod(HiddenRows, "for a TkTable", true, [IsTkTable], 0,
  function(obj)
    local result, i;

    result := [];
    for i in [-obj!.titlerows + 1 .. obj!.rows] do
      if IsHiddenRow(obj, i) then
        Add(result, i);
      fi;
    od;
    return result;
  end);

#
# Hide some rows of a TkTable
#
InstallMethod(HideRows, "for a TkTable and a list of positive integers", true,
  [IsTkTable and IsTkTableRep and IsDisplayed, IsList], 0,
  function(obj, rows)
    local command, i;

    command := "";
    for i in rows do
      if i in [-obj!.titlerows + 1 .. obj!.rows] then
        Append(command, Concatenation(String(i + obj!.titlerows), " 0 "));
      else
        Error("HideRows: No such row in <TkTable>");
      fi;
    od;
    if not command = "" then
      # Set row height to 0
      Tk(obj!.tktable, "height", command);
    fi;
  end);

InstallMethod(HideRows, "for a TkTable and a list", true, [IsTkTable and
  IsTkTableRep, IsList], 0, function(obj, col)
    Error("HideRows: <TkTable> is not displayed");
  end);

#
# Hide a single row of a TkTable
#
InstallMethod(HideRow, "for a TkTable and a natural number", true, [IsTkTable,
  IsPosInt], 0, function(obj, row)
    HideRows(obj, [row]);
  end);

#
# Unhide rows of a TkTable
#
InstallMethod(UnhideRows, "for a TkTable and a list", true, [IsTkTable and
  IsTkTableRep and IsDisplayed, IsList], 0,
  function(obj, rows)
    local command, i;

    command := "";
    # Set row height back to 1 line
    for i in rows do
      if i in [-obj!.titlerows + 1 .. obj!.rows] then
        if IsHiddenRow(obj, i) then
          Append(command, Concatenation(String(i + obj!.titlerows), " 1 "));
        fi;
      else
        Error("UnhideRows: No such row in <TkTable>");
      fi;
    od;
    if not command = "" then
      # Set row height to 1
      Tk(obj!.tktable, "height", command);
    fi;
  end);

InstallMethod(UnhideRows, "for a TkTable and a list", true, [IsTkTable and
  IsTkTableRep, IsList], 0, function(obj, col)
    Error("UnhideRows: <TkTable> is not displayed");
  end);

#
# Unhide a single row of a TkTable
#
InstallMethod(UnhideRow, "for a TkTable and a natural number", true,
  [IsTkTable, IsInt], 0, function(obj, row)
    UnhideRows(obj, [row]);
  end);

#
# Return whether a column of a TkTable is hidden
#
InstallMethod(IsHiddenColumn, "for a TkTable and a positive integer", true,
  [IsTkTable and IsTkTableRep and IsDisplayed, IsInt], 0,
  function(obj, col)
    if col in [-obj!.titlecols + 1 .. obj!.cols] then
      return Int(TkValue(Concatenation("[", String(obj!.tktable), " width ",
        String(obj!.titlecols + col), "]"))) = 0;
    else
      Error("IsHiddenColumn: No such column in <TkTable>");
    fi;
  end);

InstallMethod(IsHiddenColumn, "for a TkTable and a positive integer", true,
  [IsTkTable and IsTkTableRep, IsInt], 0,
  function(obj, col)
    Error("UnhideRows: <TkTable> is not displayed");
  end);

#
# Return all hidden columns of a TkTable
#
InstallMethod(HiddenColumns, "for a TkTable", true, [IsTkTable], 0,
  function(obj)
    local result, i;

    result := [];
    for i in [-obj!.titlecols + 1 .. obj!.cols] do
      if IsHiddenColumn(obj, i) then
        Add(result, i);
      fi;
    od;
    return result;
  end);

#
# Hide columns of a TkTable
#
InstallMethod(HideColumns, "for a TkTable and a list", true, [IsTkTable and
  IsTkTableRep and IsDisplayed, IsList], 0,
  function(obj, cols)
    local command, i;

    command := "";
    for i in cols do
      if i in [-obj!.titlecols + 1 .. obj!.cols] then
        Append(command, Concatenation(String(i + obj!.titlecols), " 0 "));
      else
        Error("HideColumns: No such column in <TkTable>");
      fi;
    od;
    if not command = "" then
      # Set col width to 0
      Tk(obj!.tktable, "width", command);
    fi;
  end);

InstallMethod(HideColumns, "for a TkTable and a list", true, [IsTkTable and
  IsTkTableRep, IsList], 0, function(obj, col)
    Error("HideColumns: <TkTable> is not displayed");
  end);

#
# Hide a single column of a TkTable
#
InstallMethod(HideColumn, "for a TkTable and a positive integer", true,
  [IsTkTable, IsInt], 0, function(obj, col)
    HideColumns(obj, [col]);
  end);

#
# Unhide columns of a TkTable
#
InstallMethod(UnhideColumns, "for a TkTable and a list", true, [IsTkTable and
  IsTkTableRep and IsDisplayed, IsList], 0,
  function(obj, cols)
    local command, i;

    command := "";
    for i in cols do
      if i in [-obj!.titlecols + 1 .. obj!.cols] then
        if IsHiddenColumn(obj, i) then
          if IsBound(obj!.colwidths[i + obj!.titlecols]) then
            Append(command, Concatenation(String(i + obj!.titlecols), " ",
              String(obj!.colwidths[i + obj!.titlecols]), " "));
          else
            Append(command, Concatenation(String(i + obj!.titlecols), " ",
              String(TKTABLE_MINIMUM_WIDTH), " "));
          fi;
        fi;
      else
        Error("UnhideColumns: No such column in <TkTable>");
      fi;
    od;
    if not command = "" then
      # Set col width back to the col's saved witdh resp. default width
      Tk(obj!.tktable, "width", command);
    fi;
  end);

InstallMethod(UnhideColumns, "for a TkTable and a list", true, [IsTkTable and
  IsTkTableRep, IsList], 0, function(obj, col)
    Error("UnhideColumns: <TkTable> is not displayed");
  end);

#
# Unhide a single column of a TkTable
#
InstallMethod(UnhideColumn, "for a TkTable and a positive integer", true,
  [IsTkTable, IsInt], 0, function(obj, col)
    UnhideColumns(obj, [col]);
  end);

#
# Return the justification of a TkTable. The result is a positive integer that
# is equal to the value of one of the constants TKTABLE_LEFT_JUSTIFIED,
# TKTABLE_CENTERED and TKTABLE_RIGHT_JUSTIFIED.
#
InstallMethod(Justification, "for a TkTable", true, [IsTkTable and
  IsTkTableRep], 0, function(obj)
    return obj!.justification;
  end);

#
# Set the justification of a TkTable. To have an effect the last argument must
# be the value of one the constants TKTABLE_LEFT_JUSTIFIED, TKTABLE_CENTERED
# and TKTABLE_RIGHT_JUSTIFIED.
#
InstallMethod(SetJustification, "for a TkTable", true, [IsTkTable and
  IsTkTableRep, IsPosInt], 0, function(obj, val)
    if val = TKTABLE_LEFT_JUSTIFIED or val = TKTABLE_CENTERED or val =
      TKTABLE_RIGHT_JUSTIFIED  then
      obj!.justification := val;
      if IsDisplayed(obj) then
        if val = TKTABLE_LEFT_JUSTIFIED then
          Tk(obj!.tktable, "configure", rec(anchor := "w"));
        elif val = TKTABLE_CENTERED then
          Tk(obj!.tktable, "configure", rec(anchor := "c"));
        else
          Tk(obj!.tktable, "configure", rec(anchor := "e"));
        fi;
      fi;
    fi;
  end);

#
# Sets the justification of rows of a TkTable. To have an effect the last
# argument must be the value of one the constants TKTABLE_LEFT_JUSTIFIED,
# TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and TKTABLE_NON_JUSTIFIED.
#
InstallMethod(JustifyRows, "for a TkTable, a list and a positve integer",
  true, [IsTkTable, IsList, IsPosInt], 0,
  function(obj, list, val)
    JustifyCells(obj, Cartesian(list, [1 .. obj!.cols]), val);
  end);

#
# Sets the justification of a single row of a TkTable. To have an effect
# the last argument must be the value of one the constants
# TKTABLE_LEFT_JUSTIFIED, TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and
# TKTABLE_NON_JUSTIFIED.
#
InstallMethod(JustifyRow, "for a TkTable, a positive integer and a positve \
integer", true, [IsTkTable, IsPosInt, IsPosInt], 0,
  function(obj, pos, val)
    JustifyRows(obj, [pos], val);
  end);

#
# Sets the justification of columns of a TkTable. To have an effect the last
# argument must be the value of one the constants TKTABLE_LEFT_JUSTIFIED,
# TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and TKTABLE_NON_JUSTIFIED.
#
InstallMethod(JustifyColumns, "for a TkTable, a list and a positve integer",
  true, [IsTkTable, IsList, IsPosInt], 0,
  function(obj, list, val)
    JustifyCells(obj, Cartesian([1 .. obj!.rows], list), val);
  end);

#
# Sets the justification of a single column of a TkTable. To have an effect
# the last argument must be the value of one the constants
# TKTABLE_LEFT_JUSTIFIED, TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and
# TKTABLE_NON_JUSTIFIED.
#
InstallMethod(JustifyColumn, "for a TkTable, a positive integer and a positve \
integer", true, [IsTkTable, IsPosInt, IsPosInt], 0,
  function(obj, pos, val)
    JustifyColumns(obj, [pos], val);
  end);

#
# Sets the justification of a cells of a TkTable. To have an effect the last
# argument must be the value of one the constants TKTABLE_LEFT_JUSTIFIED,
# TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and TKTABLE_NON_JUSTIFIED.
#
InstallMethod(JustifyCells, "for a TkTable, a list and a positve integer",
  true, [IsTkTable and IsTkTableRep and IsDisplayed, IsList, IsPosInt], 0,
  function(obj, list, val)
    local command, cell;

    command := "";
    for cell in list do
      if cell[1] in [1 .. obj!.rows] and cell[2] in [1 .. obj!.cols] then
        Append(command, Concatenation(String(cell[1] + obj!.titlerows), ",",
          String(cell[2] + obj!.titlecols), " "));
      else
        Error("JustifyCells: No such cell in <TkTable>");
      fi;
    od;
    if not command = "" then
      if val = TKTABLE_LEFT_JUSTIFIED then
        Tk(obj!.tktable, "tag cell left", command);
      elif val = TKTABLE_RIGHT_JUSTIFIED then
        Tk(obj!.tktable, "tag cell right", command);
      elif val = TKTABLE_CENTERED then
        Tk(obj!.tktable, "tag cell center", command);
      elif val = TKTABLE_NON_JUSTIFIED then
        Tk(obj!.tktable, "tag cell {}", command);
      fi;
    fi;
  end);

InstallMethod(JustifyCells, "for a TkTable, a list and a positve integer",
  true, [IsTkTable and IsTkTableRep, IsList, IsPosInt], 0,
  function(obj, list, val)
    Error("Justification: <TkTable> is not displayed");
  end);

#
# Sets the justification of a single cell of a TkTable. To have an effect the
# last argument must be the value of one the constants TKTABLE_LEFT_JUSTIFIED,
# TKTABLE_CENTERED, TKTABLE_RIGHT_JUSTIFIED and TKTABLE_NON_JUSTIFIED.
#
InstallMethod(JustifyCell, "for a TkTable, a pair of positive integers and a \
positve integer", true, [IsTkTable, IsList, IsPosInt], 0,
  function(obj, pos, val)
    JustifyCells(obj, [pos], val);
  end);

#
# Print a representation of a TkTable
#
InstallMethod(PrintObj, "for a TkTable", true, [IsTkTable], 0,
  function(obj)
    Print("<TkTable>");
  end);
