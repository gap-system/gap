#############################################################################
##
#W  window.g                    XGAP library                     Frank Celler
##
#H  @(#)$Id: window.g,v 1.11 2003/05/20 13:11:08 gap Exp $
##
#Y  Copyright 1993-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_window_g :=
    "@(#)$Id: window.g,v 1.11 2003/05/20 13:11:08 gap Exp $";


#############################################################################
##
#V  WINDOWS . . . . . . . . . . . . . . . . . . . . . . . . . list of windows
##
BindGlobal( "WINDOWS", [] );


#############################################################################
##
#F  WcStoreWindow( <id>, <w> )  . . . . . . . . . . . . . store window object
##
BindGlobal( "WcStoreWindow", function( id, w )
    WINDOWS[id+1] := w;
end );


#############################################################################
##
#F  WcCloseWindow( <id> ) . . . . . . . . . . . . . . . . . . .  close window
##
BindGlobal( "WcCloseWindow", function( id )
    Unbind(WINDOWS[id+1]);
    WindowCmd([ "XCW", id  ]);
end );


#############################################################################
##
#F  WcOpenWindow( <name>, <width>, <height> ) . . . . . . . . . . open window
##
BindGlobal( "WcOpenWindow", function( name, width, height )
    return WindowCmd([ "XOW", name, width, height ])[1];
end );


#############################################################################
##
#F  WcResizeWindow( <id>, <width>, <height> ) . . . . . . . . . resize window
##
BindGlobal( "WcResizeWindow", function( id, width, height )
    WindowCmd([ "XRE", id, width, height ]);
end );


#############################################################################
##
#F  WcSetColor( <id>, <col> ) . . . . . . . . . . . . . . . . . .   set color
##
BindGlobal( "WcSetColor", function( id, col )
    WindowCmd([ "XCO", id, col ]);
end );


#############################################################################
##
#F  WcDrawBox( <id>, <x1>, <y1>, <x2>, <y2> ) . . . . . . . . . .  draw a box
##
BindGlobal( "WcDrawBox", function( id, x1, y1, x2, y2 )
    return WindowCmd([ "XDB", id, x1, y1, x2, y2 ])[1];
end );


#############################################################################
##
#F  WcDrawCircle( <id>, <x>, <y>, <r> ) . . . . . . . . . . . . draw a circle
##
BindGlobal( "WcDrawCircle", function( id, x, y, r )
    return WindowCmd([ "XDC", id, x, y, r ])[1];
end );


#############################################################################
##
#F  WcDrawDisc( <id>, <x>, <y>, <r> ) . . . . . . . . . . . . . . draw a disc
##
BindGlobal( "WcDrawDisc", function( id, x, y, r )
    return WindowCmd([ "XDD", id, x, y, r ])[1];
end );


#############################################################################
##
#F  WcDrawLine( <id>, <x1>, <y1>, <x2>, <y2> )  . . . . . . . . . draw a line
##
BindGlobal( "WcDrawLine", function( id, x1, y1, x2, y2 )
    return WindowCmd([ "XDL", id, x1, y1, x2, y2 ])[1];
end );


#############################################################################
##
#F  WcDrawText( <id>, <fid>, <x>, <y>, <str> )  . . . . . . . . . draw a text
##
BindGlobal( "WcDrawText", function( id, fid, x, y, str )
    return WindowCmd([ "XDT", id, fid, x, y, str ])[1];
end );


#############################################################################
##
#F  WcDestroyMenu( <wid>, <mid> ) . . . . . . . . . . . . . .  destroy a menu
##
BindGlobal( "WcDestroyMenu", function( wid, mid )
    WindowCmd([ "XDM", wid, mid ]);
end );


#############################################################################
##
#F  WcDestroy( <id>, <obj> )  . . . . . . . . . . destroy <obj> on sheet <id>
##
BindGlobal( "WcDestroy", function( arg )
    local   cmd;

    cmd := Concatenation( ["XRO"], arg );
    WindowCmd(cmd);

end );


#############################################################################
##
#F  WcDestroyFlat( <id>, <objlist> )  . . . . . . destroy <obj> on sheet <id>
##
##  Works with lists of ids instead of ids because of Flat
##
BindGlobal( "WcDestroyFlat", function( arg )
    local   cmd;

    cmd := Concatenation( ["XRO"], Flat(arg) );
    WindowCmd(cmd);

end );


#############################################################################
##
#F  WcEnableMenu( <wid>, <mid>, <pos>, <flag> ) . . . . en/disable menu entry
##
BindGlobal( "WcEnableMenu", function( wid, mid, pos, flag )
    WindowCmd([ "XEM", wid, mid, pos, flag ]);
end );


#############################################################################
##
#F  WcFastUpdate( <wid>, <flag> ) . . . . . . . . . .  en/disable fast update
##
BindGlobal( "WcFastUpdate", function( wid, flag )
    if flag  then
        WindowCmd([ "XFU", wid, 1 ]);
    else
        WindowCmd([ "XFU", wid, 0 ]);
    fi;
end );


#############################################################################
##
#F  WcQueryPointer( <id> )  . . . . . . . . . . . . . . . . . . query pointer
##
##  <id> must be a `WindowId' of an {\XGAP} sheet. This function returns a
##  vector of four integers. The first two are the coordinates of the mouse 
##  pointer relative to the {\XGAP} sheet. Values outside the window are 
##  represented by $-1$. The third element is a number where the pressed      
##  buttons are coded. If no mouse button is pressed, the value is zero.
##  `BUTTONS.left' is added to the value, if the left mouse button is pressed
##  and `BUTTONS.right' is added, if the right mouse button is pressed. The
##  fourth value codes the state of the shift and control. Here the values
##  `BUTTONS.shift' and `BUTTONS.ctrl' are used.
##
BindGlobal( "WcQueryPointer", function( id )
    return WindowCmd([ "XQP", id ]);
end );


#############################################################################
##
#F  WcQueryPopup( <id> )  . . . . . . . . . . . . . . . . .  query popup menu
##
BindGlobal( "WcQueryPopup", function( id )
    return WindowCmd([ "XSP", id ])[1];
end );


#############################################################################
##
#F  WcSetLineWidth( <id>, <w> ) . . . . . . . . . . . . . . .  set line width
##
BindGlobal( "WcSetLineWidth", function( id, w )
    WindowCmd([ "XLW", id, w ]);
end );


#############################################################################
##
#F  WcSetTitle( <id>, <text> )  . . . . . . . . . . . . . .  set window title
##
BindGlobal( "WcSetTitle", function( id, text )
    WindowCmd([ "XAT", id, text ]);
end );



#############################################################################
##
#F  WcTextSelector( <name>, <text>, <btn> ) . . . . .  create a text selector
##
BindGlobal( "WcTextSelector", function( name, text, btn )
    local   sel, id;
    
    # create text selector
    return WindowCmd([ "XOS", name, text, btn ])[1];

end );


#############################################################################
##
#F  WcTsChangeText( <id>, <str> ) . . . . . . .  change text of text selector
##
BindGlobal( "WcTsChangeText", function( id, str )
    WindowCmd([ "XCL", id, str ]);
end );


#############################################################################
##
#V  SELECTORS . . . . . . . . . . . . . . . . . . . . . . . list of selectors
##
BindGlobal( "SELECTORS", [] );


#############################################################################
##
#F  WcStoreTs( <id>, <t> )  . . . . . . . . . . .  store text selector object
##
BindGlobal( "WcStoreTs", function( id, t )
    SELECTORS[id+1] := t;
end );


#############################################################################
##
#F  WcTsClose( <id> ) . . . . . . . . . . . . . . . . . . close text selector
##
BindGlobal( "WcTsClose", function( id )
    WindowCmd([ "XCS", id ]);
    Unbind(SELECTORS[id+1]);
end );


#############################################################################
##
#F  WcTsEnable( <id>, <pos>, <flag> ) . . . .  enable button in text selector
##
BindGlobal( "WcTsEnable", function( id, pos, flag )
    WindowCmd([ "XEB", id, pos, flag ]);
end );


#############################################################################
##
#F  WcTsUnhighlight( <id> ) . . . . . . . . remove highlight in text selector
##
BindGlobal( "WcTsUnhighlight", function(id)
   WindowCmd([ "XUS", id ]);
end );


#############################################################################
##
#F  WcMenu( <wid>, <title>, <str> ) . . . . . .  create new menu for a window
##
BindGlobal( "WcMenu", function( id, title, str )
    return WindowCmd([ "XME", id, title, str ])[1];
end );


#############################################################################
##
#F  WcCheckMenu( <wid>, <mid>, <pos>, <flag> )  . .  check/uncheck menu entry
##
BindGlobal( "WcCheckMenu", function( wid, mid, pos, flag )
    WindowCmd([ "XCM", wid, mid, pos, flag ]);
end );


#############################################################################
##
#F  WcPopupMenu( <title>, <str> ) . . . . . . . . . . . . create a popup menu
##
BindGlobal( "WcPopupMenu", function( title, str )
    local   pop;
    
    return WindowCmd([ "XPS", title, str ])[1];
end );


#############################################################################
##
#F  WcDialog( <type>, <text>, <def> ) . . . . . . . . . . . . . . . .  dialog
##
BindGlobal( "WcDialog", function( type, text, def )
    return WindowCmd([ "XSD", type, text, def ]);
end );


#############################################################################
##
#F  HELP_PRINT_LINES_XGAP . . . . . . . . . . .  we want a pretty help window
##

# obsolete: HELP_XGAP_SHEET:=fail;

BindGlobal( "HELP_XGAP_HYPERLINK", function(sheet,x,y)
  local obj,  i,  s;
  obj := First(sheet!.objects,o->[x,y] in o);
  if obj = fail then
    return;
  fi;
  if obj!.text[1] = '[' then
    i := Position(obj!.text,']');
    s := obj!.text{[2..i-1]};
    HELP(s);
  else
    HELP(obj!.text);
  fi;
  return;
end);
 
# The following is a rather unholy hack to display help pages in a different
# window, necessary to overcome some deficiencies in the XGAP terminal
# window. Max.

BindGlobal( "HELP_PRINT_LINES_XGAP", function(lines)
  
  local l,font,h,i,HELP_XGAP_SHEET;

  if IsString(lines) then
      lines := SplitString(lines,"\n");
  elif IsRecord(lines) then
      lines := lines.lines;
  fi;
  l:=Length(lines);
  #if HELP_XGAP_SHEET=fail or not IsAlive(HELP_XGAP_SHEET.sheet) then
    font:=FontInfo(FONTS.normal);
    h:=font[1]+font[2]+1;
  HELP_XGAP_SHEET := GraphicSheet("XGAP-Help",81*(font[3]+1),h*(l+1));
  #  HELP_XGAP_SHEET:=rec(sheet:=GraphicSheet("XGAP-Help",81*(font[3]+1),
  #                                           h*(l+1)),
  #                       l:=l,font:=font,h:=h);
  #else
  #  font:=HELP_XGAP_SHEET.font;
  #  h:=HELP_XGAP_SHEET.h;
  #  for i in ShallowCopy(HELP_XGAP_SHEET.sheet!.objects) do
  #    Delete(HELP_XGAP_SHEET.sheet,i);
  #  od;
  #  if l <> HELP_XGAP_SHEET.l then
  #    Resize(HELP_XGAP_SHEET.sheet,81*(font[3]+1),h*(l+1));
  #    HELP_XGAP_SHEET.l:=l;
  #  fi;
  #fi;
  
  for i in [1..l] do
    Text(HELP_XGAP_SHEET,FONTS.normal,font[3],h*(i-1)+font[1],lines[i]);
  od;

  InstallCallback(HELP_XGAP_SHEET,"LeftPBDown",HELP_XGAP_HYPERLINK);
end);

MakeReadWriteGVar("PAGER_BUILTIN");
PAGER_BUILTIN := HELP_PRINT_LINES_XGAP;
MakeReadOnlyGVar("PAGER_BUILTIN");

#HELP_PRINT_LINES:=HELP_PRINT_LINES_XGAP;

