#############################################################################
##
#W  sheet.gi                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: sheet.gi,v 1.15 2001/03/13 08:48:14 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains all methods for graphic sheets.
##  The low level window functions are in `window.g'.
##  The menu functions are in `menu.g'.
##

##
Revision.pkg_xgap_lib_sheet_gi :=
    "@(#)$Id: sheet.gi,v 1.15 2001/03/13 08:48:14 gap Exp $";


#############################################################################
##
#R  IsGraphicSheetRep . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsGraphicSheetRep",
    IsComponentObjectRep and IsAttributeStoringRep,
    [ "name", "width", "height", "gapMenu", "callbackName", "callbackFunc",
      "menus", "objects", "free", "filenamePS" ],
    IsGraphicSheet );


#############################################################################
##
#M  GraphicSheet( <title>, <width>, <height> ) . . . . .  a new graphic sheet
##
##  creates  a  graphic  sheet with  title  <title> and dimension <width>  by
##  <height>.  A graphic sheet  is the basic  tool  to draw something,  it is
##  like a piece of  paper on which you can  put your graphic objects, and to
##  which you  can attach your  menus.   The coordinate $(0,0)$ is  the upper
##  left corner, $(<width>-1,<height>-1)$ the lower right.
##
##  It is  possible to  change the  default behaviour of   a graphic sheet by
##  installing methods (or   sometimes  called callbacks) for   the following
##  events.  In order to  avoid  confusion with  the {\GAP} term  \"method\" the
##  term \"callback\" will be used in the following.  For example, to install
##  the function `MyLeftPBDownCallback' as callback for the left mouse button
##  down  event of a graphic <sheet>,  you have  to call `InstallCallback' as
##  follows.
##
##  \begintt
##      gap> InstallCallback( sheet, "LeftPBDown", MyLeftPBDownCallback );
##  \endtt
##
##  {\XGAP} stores for each graphic sheet a list of callback keys and a list
##  of callback functions for each key. That means that when a certain 
##  callback key is triggered for a graphic sheet then the corresponding
##  list of callback functions is called one function after the other. The
##  following keys have predefined meanings which are explained below:
##    `Close', `LeftPBDown', `RightPBDown', `ShiftLeftPBDown', 
##    `ShiftRightPBDown', `CtrlLeftPBDown', `CtrlRightPBDown'.
##  All of these keys are strings. You can install your own callback 
##  functions for new keys, however they will not be triggered automatically.
##
##  \> Close( <sheet> )
##
##    the function will be called as soon as the user selects \"close graphic
##    sheet\",  the installed  function gets  the graphic <sheet> to close as
##    argument.
##
##  \> LeftPBDown( <sheet>, <x>, <y> )
##
##    the function will be called as soon as  the user presses the left mouse
##    button inside  the   graphic sheet, the  installed   function  gets the
##    graphic <sheet>,  the <x> coordinate and  <y> coordinate of the pointer
##    as arguments.
##
##  \> RightPBDown( <sheet>, <x>, <y> )
##
##    same  as `LeftPBDown' except that the  user has pressed the right mouse
##    button.
##
##  \> ShiftLeftPBDown( <sheet>, <x>, <y> )
##
##    same  as `LeftPBDown' except that the  user has  pressed the left mouse
##    button together with the $SHIFT$ key on the keyboard.
##
##  \> ShiftRightPBDown( <sheet>, <x>, <y> )
##
##    same as  `LeftPBDown' except that the  user has pressed the right mouse
##    button together with the $SHIFT$ key on the keyboard.
##
##  \> CtrlLeftPBDown( <sheet>, <x>, <y> )
##
##    same  as `LeftPBDown' except that the  user has pressed  the left mouse
##    button together with the $CTR$ key on the keyboard.
##
##  \> CtrlRightPBDown( <sheet>, <x>, <y> )
##
##    same as `LeftPBDown'  except that the  user has pressed the right mouse
##    button together with the $CTR$ key on the keyboard.
##
InstallMethod( GraphicSheet,
    "for a string, and two integers",
    true,
    [ IsString,
      IsInt,
      IsInt ],
    0,

function( title, width, height )
    local   s,  id,  defaults;
    
    # create a new object
    s := rec();
    s.name   := title;
    s.width  := width;
    s.height := height;
    Objectify( NewType( GraphicSheetFamily, 
                        IsGraphicSheet and IsGraphicSheetRep ), s );

    # really create a window and store the id
    if width > 800 or height > 600 then
      id := WcOpenWindow( title, width+15, height+15 );
    else
      id := WcOpenWindow( title, width, height );
    fi;

    SetWindowId( s, id );
    SetFilterObj( s, IsAlive );

    # store in list of windows
    WcStoreWindow( id, s );

    # store list of callbacks
    s!.callbackName := [];
    s!.callbackFunc := [];

    # add menu to close GraphicSheet
    s!.menus := [];
    MakeGAPMenu(s);

    # there are no objects right now
    s!.objects := [];
    s!.free    := [];

    # no fast update
    ResetFilterObj( s, UseFastUpdate );

    # set defaults for color, line width, shape
    defaults       := rec();
    defaults.color := COLORS.black;
    defaults.width := 1;
    defaults.shape := 1;
    defaults.label := false;
    SetDefaultsForGraphicObject( s, defaults );
    
    s!.filenamePS := "";
    
    # return the graphic sheet <s>
    return s;

end );


#############################################################################
##
#V  DefaultGAPMenu  . . . . . . . . . . . . . . . . . . . .  default GAP menu
##
GMCloseGS := function( sheet, menu, entry ) Close(sheet); end;

InstallValue( DefaultGAPMenu,
[
##FIXME: do we have ideas to save sheets except postscript?
## "save",                   Ignore,
##    "save as",                Ignore,
##   ,                         ,
    "save as postscript",     GMSaveAsPS,
##    "save as LaTeX",          Ignore,
    ,                         ,
    "close graphic sheet",    GMCloseGS,
] );


#############################################################################
##
#M  GMSaveAsPS( <sheet>, <menu>, <entry> )  . . . .  save sheet as postscript
##
##  This operation is called from the menu, if the user clicks on ``save as
##  postscript''. It asks for a filename (defaultname stored in the sheet)
##  and calls the operation <SaveAsPS>.
##
InstallMethod( GMSaveAsPS,
    "for a graphic sheet",
    true,
    [ IsGraphicSheet, IsMenu, IsString ],
    0,
function( sheet, menu, entry )
  local   res;
  res := Query( Dialog("Filename", "Enter a filename"), sheet!.filenamePS );
  if res = false  then
    return;
  fi;
  sheet!.filenamePS := res;
  SaveAsPS( sheet, res );
end);


#############################################################################
##
#M  SaveAsPS( <sheet>, <filename> ) . . . . . . . .  save sheet as postscript
##
##  Saves the graphics in the sheet <sheet> as postscript into the file
##  <filename>, which is overwritten, if it exists.
##
InstallMethod( SaveAsPS,
    "for a graphic sheet, and a string",
    true,
    [ IsGraphicSheet, IsString ],
    0,
function( sheet, file )
  local   str,  a,  b,  obj;
  
  # set filename and create file
  PrintTo( file, "%!PS-Adobe-3.0 EPSF-3.0\n" );
  
  # collect string in <str>
  str := "";
  
  # we follow Adobes document conventions:
  Append( str, "%%Creator: XGAP4\n");
  Append( str, "%%Pages: 1\n");
  
  #FIXME: is that necessary with EPS?
  # landscape or portrait
  #
  #if sheet!.height <= sheet!.width  then
  #  Append( str, "90 rotate\n" );
  #  a := QuoInt( sheet!.height*1000, 6 );
  #  b := QuoInt( sheet!.width*1000,  8 );
  #  a := Maximum(a,b);
  #  Append( str, "100000 " );
  #  Append( str, String(a) );
  #  Append( str, " div 100000 " );
  #  Append( str, String(a) );
  #  Append( str, " div scale\n" );
  #  Append( str, "0 " );
  #  Append( str, String(-sheet!.height) );
  #  Append( str, " translate\n" );
  #else
  a := QuoInt( sheet!.height*1000, 8 );
  b := QuoInt( sheet!.width*1000,  6 );
  a := Maximum(a,b);
  Append( str, "%%BoundingBox: 0 0 ");
  Append( str, String(QuoInt(sheet!.width*100000+QuoInt(a,2),a)));
  Append( str, " ");
  Append( str, String(QuoInt(sheet!.height*100000+QuoInt(a,2),a)));
  Append( str, "\n");
  Append( str, "100000 " );
  Append( str, String(a) );
  Append( str, " div 100000 " );
  Append( str, String(a) );
  Append( str, " div scale\n" );
  #fi;
  
  Append( str, "%%Page: 1\n");
  for obj  in sheet!.objects  do
    if IsAlive(obj) then
      Append( str, PSString(obj) );
    fi;
  od;
  Append( str, "showpage\n" );
  Append( str, "%%EOF\n");
  
  AppendTo( file, str );
  
end);


#############################################################################
##
#M  Callback( <sheet>, <key>, <args> ) . . . . .  execute a callback function
##
##  Executes all callback functions of the sheet <sheet> that are stored under
##  the key <func> with the argument list <args>.
##
InstallMethod( Callback,
    "for graphic sheet",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep,
      IsObject,
      IsList ],
    0,

function( sheet, key, args )
    local   p,  list,  f,  l;

    p := Position( sheet!.callbackName, key );
    if p <> fail  then
        list := sheet!.callbackFunc[p];
        for f  in list  do
            CallFuncList( f, args );
        od;
    fi;
end );


#############################################################################
##
#M  Close( <sheet> ) . . . . . . . . . . . . . . . . . .  close graphic sheet
##
##  The graphic sheet is closed which means that the corresponding window is
##  closed and the sheet becomes <not alive>.
##
InstallMethod( Close,
    "for graphic sheet",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep ],
    0,

function( sheet )
    local   obj;

    Callback( sheet, "Close", [ sheet ] );
    ResetFilterObj( sheet, IsAlive );
    WcCloseWindow(WindowId(sheet));
    for obj  in sheet!.objects  do
        ResetFilterObj( obj, IsAlive );
    od;
end );


#############################################################################
##
#M  InstallCallback( <sheet>, <key>, <func> )  . . . . . install new callback
##
##  Installs a new callback function for the sheet <sheet> for the key <key>.
##  Note that the old functions for this key are *not* deleted.
##
InstallMethod( InstallCallback,
    "for a graphic sheet, an object, and a function",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep,
      IsObject,
      IsFunction ],
    0,

function( sheet, key, func )
    local   p,  list;

    p := Position( sheet!.callbackName, key );
    if p <> fail  then
        list := sheet!.callbackFunc[p];
        Add( list, func );
    else
        Add( sheet!.callbackName, key   );
        Add( sheet!.callbackFunc, [func] );
    fi;
end );


#############################################################################
##
#M  RemoveCallback( <sheet>, <key>, <func> )  . . . . . . remove old callback
##
##  Removes an old callback. Note that you have to specify not only the 
##  <key> but also explicitly the <func> which should be removed from the 
##  list!
##
InstallMethod( RemoveCallback,
    "for a graphic sheet, an object, and a function",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep,
      IsObject,
      IsFunction ],
    0,

function( sheet, key, func )
    local   p, q, list;

    p := Position( sheet!.callbackName, key );
    if p <> fail  then
      list := sheet!.callbackFunc[p];
      q := Position(list,func);
      if q <> fail then
        list[q] := list[Length(list)];
        Unbind(list[Length(list)]);
      fi;	
    fi;
end );


#############################################################################
##
#M  MakeGAPMenu( <sheet> ) . . . . . . . . . . . . . . create a standard menu
##
InstallMethod( MakeGAPMenu,
    "for graphic sheet",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep ],
    0,

function( sheet )
  sheet!.gapMenu := Menu( sheet, "Sheet", DefaultGAPMenu );
  ##FIXME: see earlier: do we have ideas for that?
        #Enable( sheet!.gapMenu, "save", false );
        #Enable( sheet!.gapMenu, "save as", false );
        #Enable( sheet!.gapMenu, "save as LaTeX", false );
end );


#############################################################################
##
#M  Resize( <sheet>, <width>, <height> ) . . . . . . . . . . . . resize sheet
##
##  The <width> and <height> of the sheet are changed. That does *not* 
##  automatically mean that the window size is changed. It may also happen
##  that only the scrollbars are changed.
##
InstallMethod( Resize,
    "for graphic sheet",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep,
      IsInt,
      IsInt ],
    0,

function( sheet, width, height )
    WcResizeWindow( WindowId(sheet), width, height );
    sheet!.height := height;
    sheet!.width  := width;
end );


#############################################################################
##
#M  ViewObj( <sheet> )  . . . . . . . . . . . .  pretty print a graphic sheet
##
InstallMethod( ViewObj,
    "for graphic sheet",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep ],
    0,

function( sheet )
    if IsAlive(sheet)  then
        Print( "<graphic sheet \"", sheet!.name, "\">" );
    else
        Print( "<dead graphic sheet>" );
    fi;
end );


#############################################################################
##
#M  Delete( <sheet>, <obj> )  . . . . . . . . . . . . delete <obj> in <sheet>
##
InstallOtherMethod( Delete,
    "for graphic sheet, and object",
    true,
    [ IsGraphicSheet and IsGraphicSheetRep, IsGraphicObject ],
    0,
function( sheet, obj )
    local   pos;

    # find position of object
    pos := Position( sheet!.objects, obj );

    # destroy object
    Destroy(obj);

    # and remove it from the list of objects
    Unbind(sheet!.objects[pos]);
    Add( sheet!.free, pos );

end );


#############################################################################
##
#M  FastUpdate( <sheet>, <flag> ) . . . . . . . . . . . . . switch fastupdate
##
##  Switches the `UseFastUpdate' filter for the sheet <sheet> to the
##  boolean value of <flag>. If this filter is set for a sheet, the screen
##  is no longer updated completely if a graphic object is moved or
##  deleted.  You should call `FastUpdate( <sheet>, true )' before you
##  start large rearrangements of the graphic objects and 
##  `FastUpdate( <sheet>, false )' at the end.
##
InstallMethod( FastUpdate,
    "for a graphic sheet, and a flag",
    true,
    [ IsGraphicSheet, IsBool ],
    0,

function (sheet, flag)
    if flag then
        if not UseFastUpdate(sheet) then
            WcFastUpdate( WindowId(sheet), true );
        fi;
        SetFilterObj(sheet, UseFastUpdate);
    else
        if UseFastUpdate(sheet) then
            WcFastUpdate( WindowId(sheet), false );
        fi;
        ResetFilterObj(sheet, UseFastUpdate);
    fi;
end );


#############################################################################
##
#M  FastUpdate( <sheet> ) . . . . . . . . . . . . . . .  switch fastupdate on
##
InstallOtherMethod( FastUpdate,
    "for a graphic sheet",
    true,
    [ IsGraphicSheet ],
    0,

function ( sheet )
    if not UseFastUpdate(sheet) then
        WcFastUpdate( WindowId(sheet), true );
        SetFilterObj( sheet, UseFastUpdate );
    fi;
end );

    
#############################################################################
##
#M  SetTitle( <sheet>, <title> )  . . . . . . . . . . . . . . . . add a title
##
##  Every graphic sheet has a title which appears somewhere on the window.
##  It is initially set via the call to the constructor `GraphicSheet' and
##  can be changed later with this operation.
##
InstallMethod( SetTitle,
    "for a graphic sheet, and a string",
    true,
    [ IsGraphicSheet, IsString ],
    0,
        
function ( S, title )
    S!.name := title;
    WcSetTitle( WindowId(S), title);
end );


#############################################################################
##
#V  BUTTONS . . . . . . . . . . . . . . . . . . . . left/right pointer button
##
InstallValue( BUTTONS, rec(left  := 1,
                           right := 2,
                           shift := 1,
                           ctrl  := 2) );


#############################################################################
##
#M  PointerButtonDown( <sheet>, <x>, <y>, <btn>, <state> . . reaction on user
##
InstallMethod( PointerButtonDown,
    "for a graphic sheet, two integers, a button no., and a state list",
    true,    
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt ], 
    0,
      
function( sheet, x, y, btn, state )
    local   upper,  lower,  name;

    upper := "LRSC";
    lower := "lrsc";
    name := "PBDown";
    if btn = BUTTONS.left  then
        name := Concatenation( "Left", name );
    else
        name := Concatenation( "Right", name );
    fi;
    if QuoInt(state,BUTTONS.shift) mod 2 = 1  then
        name := Concatenation( "Shift", name );
    fi;
    if QuoInt(state,BUTTONS.ctrl) mod 2 = 1  then
        name := Concatenation( "Ctrl", name );
    fi;
    
    Callback(sheet, name, [sheet,x,y] );
    
end );
    
        
#############################################################################
##
#M  PointerButtonDown( <wid>, <x>, <y>, <btn> ) . . . . button down, internal
##
InstallOtherMethod( PointerButtonDown,
    "for a window no., two integers, and a button no.",
    true,
    [ IsInt, IsInt, IsInt, IsInt ],    
    0,    
        
function( wid, x, y, btn )
    local    win,  qry;

    win := WINDOWS[wid+1];
    qry := WcQueryPointer( wid );
    PointerButtonDown( win, x, y, btn, qry[4] );

end );


#############################################################################
##
#F  Drag( <sheet>, <x>, <y>, <bt>, <func> ) . . . . . . . . .  drag something
##
##  Call this function when a button event has occured, so the button <bt>
##  is still pressed. It waits until the user releases the mouse button and
##  calls <func> for every change of the mouse position with the new x and
##  y position as two integer parameters. You can implement a dragging
##  procedure in this way as in the following example: (we assume that a
##  LeftPBDown event just occured and x and y contain the current mouse
##  pointer position):
##
##  \begintt
##    storex := x;
##    storey := y;
##    box := Rectangle(sheet,x,y,0,0);
##    if Drag(sheet,x,y,BUTTONS.left,
##            function(x,y)
##              local bx,by,bw,bh;
##              if x < storex then
##                bx := x;
##                bw := storex - x;
##              else
##                bx := storex;
##                bw := x - storex;
##              fi;
##              if y < storey then
##                by := y;
##                bh := storey - y;
##              else
##                by := storey;
##                bh := y - storey;
##              fi;
##              if bx <> box!.x or by <> box!.y then
##                Move(box,bx,by);
##              fi;
##              if bw <> box!.w or bh <> box!.h then
##                Reshape(box,bw,bh);
##              fi;
##            end) then
##      # the box had at one time at least a certain size
##      ... work with box ...
##    else
##      # the box was never big enough, we do nothing
##    fi;
##    Delete(box);
## \endtt
##
InstallMethod( Drag,
    "for a sheet, two integers, a button number and a function",
    true,    
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsFunction ],    
    0,
        
function( sheet, x, y, bt, func )
    local   tmp, count;
    
    # wait for a small movement
    repeat
        tmp := WcQueryPointer( WindowId(sheet) );
        if tmp[3] <> bt  then return false;  fi;
    until 5 < AbsInt(x-tmp[1]) or 5 < AbsInt(y-tmp[2]);
    
    # now start dragging:
    count := 30;
    FastUpdate(sheet,true);
    while true  do
        tmp := WcQueryPointer( WindowId(sheet) );
        if tmp[3] <> bt  then 
            FastUpdate(sheet,false);
            return true;
        fi;
        if tmp[1] = -1  then tmp[1] := x;  fi;
        if tmp[2] = -1  then tmp[2] := y;  fi;
        if tmp[1] <> x or tmp[2] <> y  then
            func( tmp[1], tmp[2] );
            x := tmp[1];
            y := tmp[2];
        fi;
        count := count - 1;
        if count <= 0 then
            FastUpdate(sheet,false);
            FastUpdate(sheet,true);
            count := 30;
        fi;
    od;
    
end );


#############################################################################
##

#E  sheet.gi  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

