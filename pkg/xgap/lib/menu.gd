#############################################################################
##
#W  menu.gd                     XGAP library                     Frank Celler
##
#H  @(#)$Id: menu.gd,v 1.9 1999/11/25 18:06:57 gap Exp $
##
#Y  Copyright 1993-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Cyopright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##
##  This files contains the menu and text selector  functions.  The low level
##  window functions are  in "window.g", the high  level window  functions in
##  "sheet.gi".
##
Revision.pkg_xgap_lib_menu_gd :=
    "@(#)$Id: menu.gd,v 1.9 1999/11/25 18:06:57 gap Exp $";


#############################################################################
##
#C  IsMenu( <obj> )  . . . . . . . . . . . . . . . . . . . . .  menu category
##
DeclareCategory( "IsMenu", IsObject );


#############################################################################
##
#A  MenuId( <menu> )  . . . . . . . . . . . . . . . . . . . . . . . . menu id
##
DeclareAttribute( "MenuId", IsMenu );


#############################################################################
##
#V  MenuFamily  . . . . . . . . . . . . . . . . . . . . . . . family of menus
##
##  The family of menus contains all menus, such as pulldown menus,
##  popup menus, information menus, text selectors, and dialog boxes.
##  The different kinds of menus are distinguished via representations.
##
BindGlobal( "MenuFamily", NewFamily( "MenuFamily", IsMenu ) );


#############################################################################
##
#O  Menu( <sheet>, <title>, <ents>, <fncs> ) .  add a menu to a graphic sheet
#O  Menu( <sheet>, <title>, <zipped> ) . . . .  add a menu to a graphic sheet
##
##  `Menu' returns a pulldown menu. It is attached to the sheet <sheet>
##  under the title <title>. In the first form <ents> is a list of strings
##  consisting of the names of the menu entries. <fncs> is a list of
##  functions. They are called when the corresponding menu entry is selected
##  by the user. The parameters they get are the graphic sheet as first
##  parameter, the menu object as second, and the name of the selected entry
##  as third parameter. In the second form the entry names and functions are
##  all in one list <zipped> in alternating order, meaning first a menu entry,
##  then the corresponding function and so on.
##  Note that you can delete menus but it is not possible to modify them,
##  once they are attached to the sheet.
##  If a name of a menu entry begins with a minus sign or the list entry
##  in <ents> is not bound, a dummy menu entry is generated, which can sort
##  the menu entries within a menu in blocks. The corresponding function
##  does not matter.
##
DeclareOperation( "Menu", [ IsGraphicSheet, IsString, IsList, IsList ] );


#############################################################################
##
#O  Check( <menu>, <entry>, <flag> )  . . . . . . . . . . .  check menu entry
## 
##  Modifies the ``checked'' state of a menu entry. This is visualized by a 
##  small check mark behind the menu entry. <menu> must be a menu object,
##  <entry> the string exactly as in the definition of the menu, and <flag>
##  a boolean value.
##
DeclareOperation( "Check", [ IsMenu, IsObject, IsBool ] );


#############################################################################
##
#O  Enable( <menu>, <entry>, <flag> ) . . . .  enable an object for selection
#O  Enable( <menu>, <boollist> ) . . . . . enable/disable all entries at once
##
##  Modifies the ``enabled'' state of a menu entries. Only enabled menu entries
##  can be selected by the user. Disabled menu entries are visualized
##  by grey or shaded letters in the menu. <menu> must be a menu object,
##  <entry> the string exactly as in the definition of the menu, and <flag>
##  a boolean value. <entry> can also be a natural number meaning the index
##  of the corresponding menu entry.
##  In the second form <boollist> must be a list where each
##  entry has either a boolean value or the value `fail' 
##  The list must be as long as the 
##  number of menu entries in the menu <menu>. All menu entries where a 
##  boolean value is provided are enabled or disabled according to this
##  value.
## 
DeclareOperation( "Enable", [ IsMenu, IsObject, IsBool ] );
DeclareOperation( "Enable", [ IsMenu, IsList ] );


#############################################################################
##
#F  MenuSelected( <wid>, <mid>, <eid> ) . . . . . . . menu selector, internal
##
##  For the menu with menu id <mid> in the window with window id <wid>,
##  the <eid>-th entry is selected.
##
DeclareGlobalFunction( "MenuSelected" );


#############################################################################
##
#O  PopupMenu( <name>, <labels> ) . . . . . . . . . . . . create a popup menu
##
##  creates a new popup menu and returns a {\GAP} object describing it.
##  <name> is the title of the menu and <labels> is a list of strings for
##  the entries. Use `Query' to actually put the popup on the screen.
##
DeclareOperation( "PopupMenu", [IsString, IsList] );


#############################################################################
##
#O  Query( <obj> ) . . . . . . . . . actually put a popup or dialog on screen
#O  Query( <obj>, <default> )  . . . . . . . . . . . dito, with default value
##
##  Puts a dialog on screen. Returns `false' if the user clicks ``Cancel'' and
##  a string value or filename, if the user clicks ``OK'', depending on the
##  type of dialog. <default> is an optional initialization value for the 
##  string.
##
DeclareOperation( "Query", [ IsObject ] );
DeclareOperation( "Query", [ IsObject, IsString ] );


#############################################################################
##
#O  TextSelector( <name>, <list>, <buttons> ) . . . .  create a text selector
##
##  creates a new text selector and returns a {\GAP} object describing it.
##  <name> is a title. <list> is an alternating list of strings and
##  functions. The strings are displayed and can be selected by the user.
##  If this happens the corresponding function is called with two
##  parameters.  The first is the text selector object itself, the second
##  the string that is selected. A selected string is highlighted and all
##  other strings are reset at the same time. Use `Reset' to reset all
##  entries.
##
##  <buttons> is an analogous list for the buttons that are 
##  displayed at the bottom of the text selector. The text selector is 
##  displayed immediately and stays on screen until it is closed (use the
##  `Close' operation). Buttons can be enabled and disabled by the `Enable'
##  operation and the string of a text can be changed via `Relabel'.
##
DeclareOperation( "TextSelector", [ IsString, IsList, IsList ] );


#############################################################################
##
#O  ButtonSelected( <sel>, <bid> )  . . . . . .  called if button is selected
##
DeclareOperation( "ButtonSelected", [IsObject, IsInt] );


#############################################################################
##
#O  Reset( <sel> ) . . . . . . . . . . . . . . . .  unhighlight text selector
##
DeclareOperation( "Reset", [IsObject] );


#############################################################################
##
#O  TextSelected( <sel>, <tid> ) . . . . . . . . . . . . . . .  text selected
##
DeclareOperation( "TextSelected", [ IsMenu, IsInt] );


#############################################################################
##
#O  Dialog( <type>, <text> ) . . . . . . . . . . . . .  create a popup dialog
##
##  creates a dialog box and returns a {\GAP} object describing it. There are
##  currently two types of dialogs: A file selector dialog (called
##  `Filename') and a dialog type called `OKcancel'. <text> is a text that
##  appears as a title in the dialog box.
##
DeclareOperation( "Dialog", [ IsString, IsString ] );


#############################################################################
##
#V  FILENAME_DIALOG . . . . . . . . . . . . . . a dialog asking for filenames
##
DeclareGlobalVariable( "FILENAME_DIALOG", "dialog for querying filenames" );


#############################################################################
##
#O  PopupFromMenu( <menu> ) . . . . . . . .  creates a popup menu from a menu
##
##  creates a popup menu that contains exactly the enabled menu entries of
##  the menu <menu>. This popup is queried via `Query' and if the user 
##  selected an entry the corresponding function installed in the menu is 
##  called with as if the user had selected the menu entry. Returns without 
##  a return value.
DeclareOperation( "PopupFromMenu", [ IsMenu ] );


#############################################################################
##

#E  menu.gd . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

