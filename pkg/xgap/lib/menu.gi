#############################################################################
##
#W  menu.gi                     XGAP library                     Frank Celler
##
#H  @(#)$Id: menu.gi,v 1.9 1999/07/01 15:02:29 gap Exp $
##
#Y  Copyright 1993-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_menu_gi :=
    "@(#)$Id: menu.gi,v 1.9 1999/07/01 15:02:29 gap Exp $";


#############################################################################
##
## Pulldown-Menus:
##
#############################################################################


#############################################################################
##
#R  IsPulldownMenuRep( <obj> )
##
DeclareRepresentation( "IsPulldownMenuRep", IsAttributeStoringRep,
    [ "title", "sheet", "entries", "functions", "enabled" ] );


#############################################################################
##
#M  WindowId( <menu> )  . . . . . . . . . . . . . . . . . . . . . .  for menu
##
InstallOtherMethod( WindowId,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep ],
    0,
    menu -> WindowId( menu!.sheet ) );


#############################################################################
##
#M  Menu( <sheet>, <title>, <ents>, <fncs> ) . add a menu to a graphic sheet
##
InstallMethod( Menu,
    "for graphic sheet",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep,
      IsString,
      IsList,
      IsList ],
    0,

function( sheet, title, lbs, func )
    local   str,  i,  id,  menu,  l;

    # if function is a list, check its length
    if IsList(func)  then
        if Number(lbs) <> Number(func)  then
            Error( "need ", Length(lbs), " menu functions" );
        fi;
    fi;

    # create a string from <lbs>
    str := "";
    for i  in [ 1 .. Length(lbs)-1 ]  do
    	if IsBound(lbs[i])  then
            Append( str, lbs[i] );
            Append( str, "|" );
    	else
    	    Append( str, "-|" );
        fi;
    od;
    Append( str, lbs[Length(lbs)] );

    # create menu in <sheet>
    id := WcMenu( WindowId(sheet), title, str );

    menu:= Objectify( NewType( MenuFamily, IsMenu and IsPulldownMenuRep ),
                      rec() );

    menu!.title      := title;
    menu!.sheet      := sheet;
    # only the bound non-delimiters:
    l := Filtered([1..Length(lbs)],x->IsBound(lbs[x]) and (lbs[x][1] <> '-'));
#T was `Copy'!
    menu!.entries    := lbs{l};
#T was `Copy'!
    menu!.functions  := func{l};
    menu!.enabled    := List(l,x->true);
    
    SetMenuId( menu, id );
    SetFilterObj( menu, IsAlive );

    # store the menu (`MenuSelected' needs this)
    sheet!.menus[id+1] := menu;

    # return menu
    return menu;

end );


#############################################################################
##
#M  Menu( <sheet>, <title>, <zipped> ) . . . .  add a menu to a graphic sheet
##
InstallOtherMethod( Menu,
    "for graphic sheet (three arguments)",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep,
      IsString,
      IsList ],
    0,

function( sheet, title, zipped )
    local i, lbs, func;

    # distribute labels and functions
    lbs  := [];
    func := [];
    for i  in [ 1, 3 .. Length(zipped)-1 ]  do
        if IsBound(zipped[i])  then
            lbs[(i+1)/2] := zipped[i];
        else
            lbs[(i+1)/2] := "-";
        fi;
        if IsBound(zipped[i+1]) then
            Add( func, zipped[i+1] );
        else
            Add( func, false );
        fi;
    od;

    # call the standard method
    return Menu( sheet, title, lbs, func );
end );


#############################################################################
##
#M  PrintObj( <menu> )  . . . . . . . . . . . . . . . . . pretty print a menu
##
InstallMethod( PrintObj,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep ],
    0,
function( menu )
    if IsAlive( menu ) then
        Print( "<menu \"", menu!.title, "\">" );
    else
        Print( "<dead menu>" );
    fi;
end );



#############################################################################
##
#M  Check( <menu>, <entry>, <flag> )  . . . . . . . . . . .  check menu entry
##
InstallMethod( Check,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep,
      IsString,
      IsBool ],
    0,

function( menu, entry, flag )
    local   pos;

    pos := Position( menu!.entries, entry );
    if pos = fail  then
        Error( "unknown menu entry \"", entry, "\"" );
    fi;
    if flag  then
        WcCheckMenu( WindowId(menu), MenuId(menu), pos, 1 );
    else
        WcCheckMenu( WindowId(menu), MenuId(menu), pos, 0 );
    fi;
end );


#############################################################################
##
#M  Destroy( <menu> )   . . . . . . . . . . . . . . . . . . .  destroy a menu
##
InstallOtherMethod( Destroy,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep ],
    0,

function( menu )
    WcDestroyMenu( WindowId(menu), MenuId(menu) );
    ResetFilterObj( menu, IsAlive );
    # note: is not removed from sheet!    
end );


#############################################################################
##
#M  Delete( <menu> )   . . . . . . . . . . . . . . . . . . . .  delete a menu
##
##  mainly for backward compatibility
##
InstallOtherMethod( Delete,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep ],
    0,

function( menu )
    WcDestroyMenu( WindowId(menu), MenuId(menu) );
    ResetFilterObj( menu, IsAlive );
    # note: is not removed from sheet!    
end );


#############################################################################
##
#M  Enable( <menu>, <entry>, <flag> ) . . . . . . . . . . . enable menu entry
##
InstallMethod( Enable,
    "for menu",
    true,
    [ IsMenu and IsPulldownMenuRep,
      IsString,
      IsBool ],
    0,

function( menu, entry, flag )
    local   pos;

    pos := Position( menu!.entries, entry );
    if pos = fail  then
        Error( "unknown menu entry \"", entry, "\"" );
    fi;
    if flag  then
        WcEnableMenu( WindowId(menu), MenuId(menu), pos, 1 );
        menu!.enabled[pos] := true;
    else
        WcEnableMenu( WindowId(menu), MenuId(menu), pos, 0 );
        menu!.enabled[pos] := false;
    fi;

end );

InstallOtherMethod( Enable,
    "for a menu, and a menu entry",
    true,
    [ IsMenu and IsPulldownMenuRep,
      IsString ],
    0,
        
function( menu, entry )
    Enable(menu, entry, true);
end );

InstallMethod( Enable,
    "for a menu, an integer, and a boolean",
    true,
    [ IsMenu and IsPulldownMenuRep,
      IsInt,
      IsBool ],
    0,

function( menu, entry, flag )

    if entry < 1 or entry > Length(menu!.entries) then
        Error( "unknown menu entry \"", entry, "\"" );
    fi;
    if flag  then
        WcEnableMenu( WindowId(menu), MenuId(menu), entry, 1 );
        menu!.enabled[entry] := true;
    else
        WcEnableMenu( WindowId(menu), MenuId(menu), entry, 0 );
        menu!.enabled[entry] := false;
    fi;

end );

InstallOtherMethod( Enable,
    "for a menu, and a menu entry index",
    true,
    [ IsMenu and IsPulldownMenuRep,
      IsInt ],
    0,
        
function( menu, entry )
    Enable(menu, entry, true);
end );

#############################################################################
##
#M  Enable( <menu>, <boollist> )  . . . . . . . . . . . . . enable menu entry
##
InstallMethod( Enable,
    "for menu, and a list",
    true,
    [ IsMenu and IsPulldownMenuRep,
      IsList ],
    0,

function( menu, boollist )
  local i;
  
  if Length(menu!.entries) <> Length(boollist) then
    Error("Length of <boollist> must match the number of menu entries!");
  fi;
  
  for i in [1..Length(menu!.entries)] do
    if IsBound(boollist[i]) and boollist[i] <> fail then
      if boollist[i] = true then
        Enable(menu,menu!.entries[i],true);
      else
        Enable(menu,menu!.entries[i],false);
      fi;
    fi;
  od;
end);

      
#############################################################################
##
#F  MenuSelected( <wid>, <mid>, <eid> ) . . . . . . . menu selector, internal
##
InstallGlobalFunction( MenuSelected, function( wid, mid, eid )
    local   menu;

    menu := WINDOWS[wid+1]!.menus[mid+1];
    menu!.functions[eid](WINDOWS[wid+1], menu, menu!.entries[eid]);

end );


#############################################################################
##
## Popup-Menus:
##
#############################################################################


#############################################################################
##
#R  IsPopupMenuRep( <obj> )
##
DeclareRepresentation( "IsPopupMenuRep", IsAttributeStoringRep,
    [ "title", "entries", "functions" ] );


#############################################################################
##
#M  PopupMenu( <name>, <labels> ) . . . . . . . . . . . . create a popup menu
##
InstallMethod( PopupMenu,
    "for a string and a list of strings",
    true,
    [ IsString, IsList ],
    0,
function( title, lbs )
    local   pop,  str,  i,  id;

    # create window command
    str := ShallowCopy(lbs[1]);
    for i  in [ 2 .. Length(lbs) ]  do
        Append( str, "|" );
        Append( str, lbs[i] );
    od;

    # construct a popup menu record
    id              := WcPopupMenu( title, str );
    pop             := rec();
    Objectify( NewType( MenuFamily, IsPopupMenuRep ), pop );
    pop!.title      := title;
    pop!.entries    := StructuralCopy(lbs);
    SetMenuId(pop, id);

    # and return
    return pop;

end );


#############################################################################
##
#M  PrintObj( <pop> ) . . . . . . . . . . . . . . . . .  pretty print a popup
##
InstallOtherMethod( PrintObj,
    "for a popup menu",
    true,
    [ IsMenu and IsPopupMenuRep ],
    0,
function( pop )
    Print( "<popup menu \"", pop!.title, "\">" );
end );


#############################################################################
##
#M  Query( <pop> ) . . . . . . . . . . . . . . actually put a popup on screen
##
InstallOtherMethod( Query,
    "for a popup menu",
    true,
    [ IsPopupMenuRep ],
    0,
function( pop )
    local   res;

    # show popup shell and query user
    res := WcQueryPopup(MenuId(pop));
    
    # return 'false' or name of entry
    if res = 0  then
    	return false;
    else
    	return pop!.entries[res];
    fi;

end );


#############################################################################
##
## TextSelectors:
##
#############################################################################


#############################################################################
##
#R  IsTextSelector( <obj> )
##
DeclareRepresentation( "IsTsMenuRep", IsAttributeStoringRep,
        [ "title", "labels", "buttons", "selected", 
          "buttonFuncs", "textFuncs", "names" ] );


#############################################################################
##
#V  IndexOfSelectedButton . . . . . . . . . . . . . . . . .  as the name says
##
##  contains the index of the button, that was last selected in a text
##  selector.
##
IndexOfSelectedButton := 0;


#############################################################################
##
#V  IndexOfSelectedText . . . . . . . . . . . . . . . . . .  as the name says
##
##  contains the index of the text, that was last selected in a text
##  selector.
##
IndexOfSelectedText := 0;


#############################################################################
##
#M  TextSelector( <name>, <list>, <buttons> ) . . . .  create a text selector
##
InstallMethod( TextSelector,
    "for a string, and two lists",
    true,    
    [ IsString, IsList, IsList ],
    0,

function( name, lbs, bts )
    local   str1,  str2,  sel,  i,  lfs,  bfs,  id;
    
    if Length(lbs) mod 2 <> 0 then
        Error( "list of labels must have even length" );
    fi;
    if Length(bts) mod 2 <> 0 then
        Error( "list of buttons must have even length" );
    fi;
    
    # create label string
    str1 := ShallowCopy(lbs[1]);
    for i  in [ 3, 5 .. Length(lbs)-1 ]  do
        Append( str1, "|" );
        Append( str1, lbs[i] );
    od;
    lfs := lbs{[ 2, 4 .. Length(lbs) ]};
    
    # create button string
    str2 := ShallowCopy(bts[1]);
    for i  in [ 3, 5 .. Length(bts)-1 ]  do
        Append( str2, "|" );
        Append( str2, bts[i] );
    od;
    bfs := bts{[ 2, 4 .. Length(bts) ]};
    
    # create text selector record
    id               := WcTextSelector( name, str1, str2 );
    sel              := rec();
    Objectify( NewType( MenuFamily, IsTsMenuRep ), sel );
    SetMenuId(sel,id);
    sel!.title       := ShallowCopy(name);
    sel!.labels      := lbs{[1, 3 .. Length(lbs)-1]};
    sel!.names       := List(sel!.labels,ShallowCopy);
    sel!.buttons     := bts{[1, 3 .. Length(bts)-1]};
    SetFilterObj(sel, IsAlive);
    sel!.selected    := 0;
    sel!.buttonFuncs := bfs;
    sel!.textFuncs   := lfs;
    
    # Store it globally to find it again:
    WcStoreTs(id,sel);
            
    # force lables to be real strings
    if not ForAll( sel!.labels, IsString ) then
        Print( "warning (TextSelector): all labels must be strings\n" );
    fi;
    
    # and return
    return sel;
    
end );


#############################################################################
##
#M  Close( <sel> )  . . . . . . . . . . . . . . . . . . close a text selector
##
InstallOtherMethod( Close,
    "for a text selector",
    true,
    [ IsTsMenuRep ],
    0,

function( sel )
    WcTsClose(MenuId(sel));
    ResetFilterObj(sel,IsAlive);
end );


#############################################################################
##
#M  Destroy( <sel> )  . . . . . . . . . . . . . . . . destroy a text selector
##
## same functionality than "Close"!
##
InstallOtherMethod( Destroy,
    "for a text selector",
    true,
    [ IsTsMenuRep ],
    0,

function( sel )
    WcTsClose(MenuId(sel));
    ResetFilterObj(sel,IsAlive);
end );


#############################################################################
##
#M  Enable( <sel>, <bt>, <flag> ) . . . . . . . . . . . . . . . enable button
##
InstallOtherMethod( Enable,
    "for a text selector, a string, and a flag",
    true,
    [ IsTsMenuRep, IsString, IsBool ],
    0,

function( sel, bt, flag )
    local   pos;

    pos := Position( sel!.buttons, bt );
    if pos = fail  then
        Error( "unknown button \"", bt, "\"" );
    fi;
    if flag  then
        WcTsEnable( MenuId(sel), pos, 1 );
    else
        WcTsEnable( MenuId(sel), pos, 0 );
    fi;
    
end );


#############################################################################
##
#M  Enable( <sel>, <bt>, <flag> ) . . . . . . . . . . . . . . . enable button
##
InstallOtherMethod( Enable,
    "for a text selector, an index, and a flag",
    true,
    [ IsTsMenuRep, IsInt, IsBool ],
    0,

function( sel, bt, flag )
    if bt < 1 or bt > Length(sel!.buttons) then
        Error( "unknown button number ", bt );
    fi;
    if flag  then
        WcTsEnable( MenuId(sel), bt, 1 );
    else
        WcTsEnable( MenuId(sel), bt, 0 );
    fi;
    
end );


#############################################################################
##
#M  PrintObj( <sel> ) . . . . . . . . . . . . .  pretty print a text selector
##
InstallOtherMethod( PrintObj,
    "for a text selector",
    true,
    [ IsTsMenuRep ],
    0,

function( sel )
    Print( "<text selector \"", sel!.title, "\">" );
end );


#############################################################################
##
#M  Relabel( <sel>, <text> )  . . . . . . . . . . . . . . . . .  set new text
##
InstallOtherMethod( Relabel,
    "for a text selector, and a list of strings",
    true,
    [ IsTsMenuRep, IsList ],
    0,

function( sel, text )
    local   str,  i;
    
    if Length(text) <> Length(sel!.labels)  then
        Error( "the text selector has ", Length(sel!.labels), " labels" );
    fi;
    str := ShallowCopy(text[1]);
    for i  in [ 2 .. Length(text) ]  do
        Append( str, "|" );
        Append( str, text[i] );
    od;
    WcTsChangeText( MenuId(sel), str );
    sel!.labels := StructuralCopy(text);
    if not ForAll( sel!.labels, IsString ) then
      Print( "warning (Relabel for text selector): labels must be strings\n");
    fi;
end );


#############################################################################
##
#M  Relabel( <sel>, <index>, <text> ) . . . . . . . . . . . . .  set new text
##
InstallOtherMethod( Relabel,
    "for a text selector, an index, and a string",
    true,
    [ IsTsMenuRep, IsInt, IsString ],
    0,

function( sel, index, text )
    local   str,  i;
    
    if index = 1 then
      str := ShallowCopy(text);
    else
      str := ShallowCopy(sel!.labels[1]);
    fi;
    for i  in [ 2 .. Length(sel!.labels) ]  do
      Append( str, "|" );
      if i <> index then
        Append( str, sel!.labels[i] );
      else
        Append( str, text );
      fi;
    od;
    WcTsChangeText( MenuId(sel), str );
    sel!.labels[index] := text;
end );


#############################################################################
##
#M  SetName( <sel>, <index>, <text> ) . . . . . . . . . . . . .  set new name
##
InstallOtherMethod( SetName,
    "for a text selector, an index, and a string",
    true,
    [ IsTsMenuRep, IsInt, IsString ],
    0,

function( sel, index, text )
  if index < 1 or index > Length(sel!.names) then
    return;
  else
    sel!.names[index] := text;
  fi;
end );


#############################################################################
##
#M  Reset( <sel> )  . . . . . . . . . . . . . . . . . . . . . remove highligh
##
InstallMethod( Reset,
    "for a text selector",
    true,
    [ IsTsMenuRep ],
    0,

function( sel )
    WcTsUnhighlight(MenuId(sel));
end );


#############################################################################
##
#M  TextSelected( <sid>, <tid> )  . . . . . . . . . . text selected, internal
##
##  just looks up id in global list of text selectors
##
InstallOtherMethod( TextSelected,
    "for two integers",
    true,
    [ IsInt, IsInt ],
    0,

function( sid, tid )
    local   sel;
    
    sel := SELECTORS[sid+1];
    return TextSelected( sel, tid );
end );


#############################################################################
##
#M  TextSelected( <sel>, <tid> )  . . . . . . . . . . . . . . . text selected
##
InstallMethod( TextSelected,
    "for a text selector, and an integer",
    true,
    [ IsMenu and IsTsMenuRep, IsInt ],
    0,

function( sel, tid )
    if 0 < tid  then
        sel!.selected := tid;
        IndexOfSelectedText := tid;
        return sel!.textFuncs[tid]( sel, sel!.labels[tid] );
    else
        return fail;
    fi;
end );


#############################################################################
##
#N  ButtonSelected( <sid>, <bid> )  . . . . . . . . button selected, internal
##
## just looks up id in global list of text selectors
##
InstallMethod( ButtonSelected,
    "for two integers",
    true,
    [ IsInt, IsInt ],
    0,
        
function( sid, bid )
    local   sel, ret;
    
    sel := SELECTORS[sid+1];
    return ButtonSelected( sel, bid );
end );


#############################################################################
##
#M  ButtonSelected( <sel>, <bid> )  . . . . . . . . . . button <bid> selected
##
InstallMethod( ButtonSelected,
    "for a text selector, and an integer",
    true,
    [ IsTsMenuRep, IsInt ],
    0,
        
function( sel, bid )
    IndexOfSelectedButton := bid;
    return sel!.buttonFuncs[bid]( sel, sel!.buttons[bid] );
end );


#############################################################################
##
## Dialoge:
##
#############################################################################


#############################################################################
##
#R  IsDialog( <obj> )
##
DeclareRepresentation( "IsDialogMenuRep", IsAttributeStoringRep,
        [ "text", "type", "cancel", "typeName" ] );


#############################################################################
##
#M  Dialog( <type>, <text> )  . . . . . . . . . . . . . create a popup dialog
##
InstallMethod( Dialog,
    "for a dialog type string, and a string",
    true,
    [ IsString, IsString ],
    0,

function( type, text )
    local   dial;

    # create a dialog record
    dial            := rec( );
    Objectify( NewType( MenuFamily, IsDialogMenuRep ), dial );
    dial!.text      := ShallowCopy(text);

    # check type
    if type = "OKcancel"  then
    	dial!.type   := 1;
        dial!.cancel := 1;
    elif type = "Filename"  then
    	dial!.type   := 2;
        dial!.cancel := 1;
    else
    	Error( "unknown type \"", type, "\"" );
    fi;
    dial!.typeName := ShallowCopy(type);

    # return
    return dial;

end );


#############################################################################
##
#M  PrintObj( <dial> )  . . . . . . . . . . . . . . . . pretty print a dialog
##
InstallOtherMethod( PrintObj,
    "for a dialog",
    true,
    [ IsDialogMenuRep ],
    0,

function( dial )
    Print( "<dialog \"", dial!.typeName, "\">" );
end );

    
#############################################################################
##
#M  Query( <dial>, <def> )  . . . . . . . . . . . query dialog (with default)
##
InstallOtherMethod( Query,
    "for a dialog, and a default string",
    true,
    [ IsDialogMenuRep, IsString ],
    0,

function( dial, def )
    local   res;

    res := WcDialog( dial!.type, dial!.text, def );
    
    # return the result
    if res[1] = dial!.cancel  then
    	return false;
    else
    	return res[2];
    fi;

end );
    

InstallOtherMethod( Query,
    "for a dialog",
    true,
    [ IsDialogMenuRep ],
    0,

function( dial )
    return Query(dial, "");
end );


#############################################################################
##
#V  FILENAME_DIALOG . . . . . . . . . . . . . . a dialog asking for filenames
##
InstallValue( FILENAME_DIALOG, Dialog( "Filename", "Enter a filename" ) );


#############################################################################
##
#M  PopupFromMenu( <menu> ) . . . . . . . .  creates a popup menu from a menu
##
##  creates a popup menu that contains exactly the enabled menu entries of
##  the menu <menu>. This popup is queried via `Query' and if the user 
##  selected an entry the corresponding function installed in the menu is 
##  called with as if the user had selected the menu entry. Returns without 
##  a return value.
##
InstallMethod( PopupFromMenu,
    "for a menu",
    true,
    [ IsMenu ],
    0,
function( menu )
  local   ents,  e,  pop,  res,  pos;
  
  ents := [];
  for e in [1..Length(menu!.enabled)] do
    if menu!.enabled[e] then
      Add(ents,menu!.entries[e]);
    fi;
  od;
  if Length(ents) <> 0 then
    pop := PopupMenu(menu!.title,ents);
    res := Query(pop);
  else
    res := false;
  fi;
  
  if res <> false then
    pos := Position(menu!.entries,res);
    if pos <> fail then
      CallFuncList(menu!.functions[pos],[menu!.sheet,menu,menu!.entries[pos]]);
    fi;
  fi;
end );


#############################################################################
##

#E  menu.gi . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

