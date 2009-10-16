#############################################################################
##
#W  sheet.gd                  	XGAP library                     Frank Celler
##
#H  @(#)$Id: sheet.gd,v 1.16 2002/04/23 10:45:18 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains all operations for graphic sheets.
##
Revision.pkg_xgap_lib_sheet_gd :=
    "@(#)$Id: sheet.gd,v 1.16 2002/04/23 10:45:18 gap Exp $";


#############################################################################
#1
##  To access any graphics in {\XGAP} you first have to create a *graphic*
##  *sheet* object. Such objects are linked internally to windows on the
##  screen. You do *not* have to think about redrawing, resizing and other
##  organizing stuff. The graphic sheet object is a {\GAP} object
##  in the category `IsGraphicSheet' and should be saved because it is needed
##  later on for all graphic operations.

#2
##  Every graphic object in {\XGAP} can be <alive> or not. This is controlled
##  by the filter `IsAlive'. Being <alive> means that the object can be used
##  for further operations. If for example the user closes a window by a 
##  mouse operation the corresponding graphic sheet object is no longer 
##  <alive>.


#############################################################################
##
#F  IsAlive( <gobj> ) . . . . . . . . . . filter for living displayed objects
##
##  This filter controls if a graphic object is <alive>, meaning that it can
##  be used for further graphic operations.
##
DeclareFilter( "IsAlive" );


#############################################################################
##
#V  GraphicSheetFamily  . . . . . . . . . . . . . . . .  family of all sheets
##
BindGlobal( "GraphicSheetFamily", NewFamily( "GraphicSheetFamily" ) );


#############################################################################
##
#C  IsGraphicSheet( <gobj> ) . . . . . . . . . . . category of graphic sheets
##
DeclareCategory( "IsGraphicSheet", IsObject );


#############################################################################
##
#O  GraphicSheet( <title>, <width>, <height> ) . . . . . .  new graphic sheet
##
##  creates  a  graphic  sheet with  title  <title> and dimension <width>  by
##  <height>.  A graphic sheet  is the basic  tool  to draw something,  it is
##  like a piece of  paper on which you can  put your graphic objects, and to
##  which you  can attach your  menus.   The coordinate $(0,0)$ is  the upper
##  left corner, $(<width>-1,<height>-1)$ the lower right.
##
##  It is  possible to  change the  default behaviour of   a graphic sheet by
##  installing methods (or   sometimes  called callbacks) for   the following
##  events.  In order to  avoid  confusion with  the {\GAP} term  ``method'' the
##  term ``callback'' will be used in the following.  For example, to install
##  the function `MyLeftPBDownCallback' as callback for the left mouse button
##  down  event of a graphic sheet <sheet>,  you have  to call
##  `InstallCallback' as follows.
##
##  \begintt
##  gap> InstallCallback( sheet, "LeftPBDown", MyLeftPBDownCallback );
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
##  \>Close( <sheet> )!{Callback}
##
##    the function will be called as soon as the user selects ``close graphic
##    sheet'',  the installed  function gets  the graphic sheet <sheet> to
##    close as argument.
##
##  \>LeftPBDown( <sheet>, <x>, <y> )
##
##    the function will be called as soon as  the user presses the left mouse
##    button inside  the   graphic sheet, the  installed   function  gets the
##    graphic sheet <sheet>,  the <x> coordinate and  <y> coordinate of the
##    pointer as arguments.
##
##  \>RightPBDown( <sheet>, <x>, <y> )
##
##    same  as `LeftPBDown' except that the  user has pressed the right mouse
##    button.
##
##  \>ShiftLeftPBDown( <sheet>, <x>, <y> )
##
##    same  as `LeftPBDown' except that the  user has  pressed the left mouse
##    button together with the $SHIFT$ key on the keyboard.
##
##  \>ShiftRightPBDown( <sheet>, <x>, <y> )
##
##    same as  `LeftPBDown' except that the  user has pressed the right mouse
##    button together with the $SHIFT$ key on the keyboard.
##
##  \>CtrlLeftPBDown( <sheet>, <x>, <y> )
##
##    same  as `LeftPBDown' except that the  user has pressed  the left mouse
##    button together with the $CTRL$ key on the keyboard.
##
##  \>CtrlRightPBDown( <sheet>, <x>, <y> )
##
##    same as `LeftPBDown'  except that the  user has pressed the right mouse
##    button together with the $CTRL$ key on the keyboard.
##
DeclareOperation( "GraphicSheet", [ IsString, IsInt, IsInt ] );


#############################################################################
##
#V  DefaultGAPMenu  . . . . . . . . . . . . . . . . . . . .  default GAP menu
##
DeclareGlobalVariable( "DefaultGAPMenu",
    "default menu for graphic sheets" );


#############################################################################
##
#A  WindowId( <sheet> ) . . . . . . . . . . . . . . . .  window id of <sheet>
##
##  Every graphic sheet has a unique number, its <window id>. This is mainly
##  used internally.
##
DeclareAttribute( "WindowId", IsGraphicSheet );


#############################################################################
##
#O  Callback( <sheet>, <key>, <args> ) . . . . .  execute a callback function
##
##  Executes all callback functions of the sheet <sheet> that are stored under
##  the key <func> with the argument list <args>.
##
DeclareOperation( "Callback", [ IsGraphicSheet, IsObject, IsList ] );


#############################################################################
##
#O  Close( <sheet> )  . . . . . . . . . . . . . . . . . close a graphic sheet
##
##  The graphic sheet <sheet> is closed which means that the corresponding
##  window is closed and the sheet becomes <not alive>.
##
DeclareOperation( "Close", [ IsGraphicSheet ] );


#############################################################################
##
#O  InstallCallback( <sheet>, <key>, <func> )  . . . . . install new callback
##
##  Installs a new callback function for the sheet <sheet> for the key <key>.
##  Note that the old functions for this key are *not* deleted.
##
DeclareOperation( "InstallCallback",
    [ IsGraphicSheet, IsObject, IsFunction ] );


#############################################################################
##
#O  RemoveCallback( <sheet>, <func>, <call> ) . . . . . . remove old callback
##
##  Removes an old callback. Note that you have to specify not only the 
##  <key> but also explicitly the <func> which should be removed from the 
##  list!
##
DeclareOperation( "RemoveCallback",
    [ IsGraphicSheet, IsObject, IsFunction ] );


#############################################################################
##
#O  MakeGAPMenu( <sheet> ) . . . . . . . . . . . . . . create a standard menu
##
DeclareOperation( "MakeGAPMenu", [ IsGraphicSheet ] );


#############################################################################
##
#O  Resize( <sheet>, <width>, <height> ) . . . . . . . . . . . . resize sheet
##
##  The <width> and <height> of the sheet <sheet> are changed. That does *not* 
##  automatically mean that the window size is changed. It may also happen
##  that only the scrollbars are changed.
##
DeclareOperation( "Resize", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#A  DefaultsForGraphicObject( <sheet> ) . . . . . . . . .  default color, etc
##
DeclareAttribute( "DefaultsForGraphicObject", IsGraphicSheet );


#############################################################################
##
#O  CtrlLeftPBDown( <sheet>, <x>, <y> ) . .  left pointer button down w. CTRL
##
DeclareOperation( "CtrlLeftPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  CtrlRightPBDown( <sheet>, <x>, <y> ) .  right pointer button down w. CTRL
##
DeclareOperation( "CtrlRightPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  LeftPBDown( <sheet>, <x>, <y> ) . . . . . . . .  left pointer button down
##
DeclareOperation( "LeftPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  RightPBDown( <sheet>, <x>, <y> )  . . . . . . . right pointer button down
##
DeclareOperation( "RightPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  ShiftLeftPBDown( <sheet>, <x>, <y> )  . left pointer button down w. SHIFT
##
DeclareOperation( "ShiftLeftPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#O  ShiftRightPBDown( <sheet>, <x>, <y> ) .right pointer button down w. SHIFT
##
DeclareOperation( "ShiftRightPBDown", [ IsGraphicSheet, IsInt, IsInt ] );


#############################################################################
##
#F  UseFastUpdate . . . . . . . . . . . . . . . . . .  filter for fast update
##
DeclareFilter( "UseFastUpdate" );


#############################################################################
##
#O  SetTitle( <sheet>, <title> )  . . . . . . . . . . . . . . . . add a title
##
##  Every graphic sheet has a title which appears somewhere on the window.
##  It is initially set via the call to the constructor `GraphicSheet' and
##  can be changed later with this operation.
##
DeclareOperation( "SetTitle", [ IsGraphicSheet, IsString ] );


#############################################################################
##
#O  FastUpdate( <sheet>, <flag> ) . . . . . . . . . . . . . switch fastupdate
##
##  Switches the `UseFastUpdate' filter for the sheet <sheet> to the
##  boolean value of <flag>. If this filter is set for a sheet, the screen
##  is no longer updated completely if a graphic object is moved or
##  deleted.  You should call `FastUpdate( <sheet>, true )' before you
##  start large rearrangements of the graphic objects and 
##  `FastUpdate( <sheet>, false )' at the end.
##
DeclareOperation( "FastUpdate", [ IsGraphicSheet, IsBool ] );


#############################################################################
##
#V  BUTTONS . . . . . . . . . . . . . . . . . . . . left/right pointer button
##
DeclareGlobalVariable( "BUTTONS" );


#############################################################################
##
#O  PointerButtonDown( <sheet>, <x>, <y>, <btn>, <state> ) . reaction on user
##
DeclareOperation( "PointerButtonDown", 
        [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt ] );


#############################################################################
##
#O  Drag( <sheet>, <x>, <y>, <bt>, <func> ) . . . . . . . . .  drag something
##
##  Call this function when a button event has occurred, so the button <bt>
##  is still pressed. It waits until the user releases the mouse button and
##  calls <func> for every change of the mouse position with the new x and
##  y position as two integer parameters. You can implement a dragging
##  procedure in this way as in the following example: (we assume that a
##  `LeftPBDown' event just occurred and x and y contain the current mouse
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
##      the box had at one time at least a certain size
##      ... work with box ...
##    else
##      the box was never big enough, we do nothing
##    fi;
##    Delete(box);
## \endtt
##
DeclareOperation( "Drag",
        [ IsGraphicSheet, IsInt, IsInt, IsInt, IsFunction ] );


#############################################################################
##
#O  GMSaveAsPS( <sheet>, <menu>, <entry> )  . . . .  save sheet as postscript
##
##  This operation is called from the menu, if the user clicks on ``save as
##  postscript''. It asks for a filename (defaultname stored in the sheet)
##  and calls the operation <SaveAsPS>.
##
DeclareOperation( "GMSaveAsPS", [ IsGraphicSheet, IsObject, IsString ] );


#############################################################################
##
#O  SaveAsPS( <sheet>, <filename> ) . . . . . . . .  save sheet as postscript
##
##  Saves the graphics in the sheet <sheet> as postscript into the file
##  <filename>, which is overwritten, if it exists.
##
DeclareOperation( "SaveAsPS", [ IsGraphicSheet, IsString ] );


#############################################################################
##

#E  sheet.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

