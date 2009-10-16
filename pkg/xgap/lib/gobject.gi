#############################################################################
##
#W  gobject.gi                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: gobject.gi,v 1.14 2002/04/19 09:07:31 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_gobject_gi :=
    "@(#)$Id: gobject.gi,v 1.14 2002/04/19 09:07:31 gap Exp $";


#############################################################################
##
#R  IsGraphicObjectRep  . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsGraphicObjectRep",
    IsComponentObjectRep,
    [ "sheet", "color", "user" ],
    IsGraphicObject );


#############################################################################
##
#M  GraphicObject( <representation>, <sheet>, <def> )  . .  create a template
##
InstallMethod( GraphicObject,
    "for a representation, a graphic sheet, and defaults",
    true,
    [ IsFunction, IsGraphicSheet, IsRecord ], 0,
    function( repres, sheet, def )
    local   obj;

    # fill default record
    if not IsBound( def.color ) then
      if not IsMutable( def ) then def:= ShallowCopy( def ); fi;
      def.color := DefaultsForGraphicObject( sheet ).color;
    fi;
    if not IsBound( def.width ) then
      if not IsMutable( def ) then def:= ShallowCopy( def ); fi;
      def.width := DefaultsForGraphicObject( sheet ).width;
    fi;
    if not IsBound( def.label ) then
      if not IsMutable( def ) then def:= ShallowCopy( def ); fi;
      def.label := DefaultsForGraphicObject( sheet ).label;
    fi;

    # create a template
    obj            := Objectify( NewType( GraphicObjectFamily,
                                          repres and IsAlive ),
                                 rec() );
    obj!.sheet     := sheet;
    obj!.color     := def.color;
    obj!.user      := rec();     # for user
    
    # add object to list of objects stored in <S>
    if IsEmpty( sheet!.free ) then
        Add( sheet!.objects, obj );
    else
        sheet!.objects[sheet!.free[Length(sheet!.free)]] := obj;
        Unbind(sheet!.free[Length(sheet!.free)]);
    fi;

    # and return
    return obj;

end );


#############################################################################
##
#M  ViewObj( <object> ) . . . . . . . . . . . . pretty print a graphic object
##
InstallMethod( ViewObj,
    "for graphic object",
    true,
    [ IsGraphicObject ],
    0,

function( obj )
    if IsAlive(obj)  then
        Print( "<graphic object>" );
    else
        Print( "<dead graphic object>" );
    fi;
end );


#############################################################################
##
#M  WindowId( <gobject> ) . for graphic object, return window id of the sheet
##
InstallOtherMethod( WindowId,
    "for graphic object",
    true,
    [ IsGraphicObject and IsGraphicObjectRep ],
    0,
    obj -> WindowId( obj!.sheet ) );


#############################################################################
##
#M  Delete( <object> )  . . . .  . . . delete a graphic object from its sheet
##
InstallOtherMethod( Delete,
    "for a graphic object",
    true,
    [ IsGraphicObject and IsGraphicObjectRep ],
    0,
function( obj )
    Delete( obj!.sheet, obj );
end );


#############################################################################
##
#M  \=( <gobject>, <gobject> ) . . . . . . . .  comparison of graphic objects
##
## Two graphic objects are to be considered equal w.r.t. \= iff they are
## actually the same objects! This makes "Position" work!
##
InstallOtherMethod( \=,
    "for two graphic objects",
    IsIdenticalObj,
    [ IsGraphicObject and IsGraphicObjectRep, 
      IsGraphicObject and IsGraphicObjectRep ],
    0,
    ReturnFalse
);


#############################################################################
## Implementation of Boxes:


#############################################################################
##
#R  IsBoxObjectRep  . . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsBoxObjectRep",
    IsGraphicObjectRep,
    [ "id", "x", "y", "w", "h" ],
    IsGraphicObject );


#############################################################################
##
#M  Box( <sheet>, <x>, <y>, <w>, <h> )  . . . . . . . . draw a box in a sheet
#M  Box( <sheet>, <x>, <y>, <w>, <h>, <defaults> )  . . draw a box in a sheet
##
##  creates a new graphic object,  namely a filled black  box, on the graphic
##  sheet <sheet> and  returns a {\GAP} record describing  this  object.  The
##  four   corners     of  the    box    are   $(<x>,<y>)$,  $(<x>+<w>,<y>)$,
##  $(<x>+<w>,<y>+<h>)$, and $(<x>,<y>+<h>)$.
##
##  Note that the box is $<w>+1$ pixel wide and $<h>+1$ pixels high.
##
##  If a record <defaults> is given and contains a component `color' of value
##  <color>, the  function works like the first version  of  `Box', except 
##  that the color of the box will be <color>.  See "Color Models" for how 
##  to select a <color>.
##
##  See "table of operations for graphic objects" for a list of operations
##  that apply to boxes.
##
InstallMethod( Box,
    "for sheet, four integers, and record of defaults",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsInt,
      IsRecord ],
    0,

function( sheet, x, y, w, h, def )
    local   box;

    # create a box object in <sheet>
    box := GraphicObject( IsBoxObjectRep, sheet, def );
    box!.x := x;
    box!.y := y;
    box!.w := w;
    box!.h := h;
    # Id's are always non-negative, so Draw knows that not yet drawn
    box!.id := -1;   
      
    # draw the Box and get the identifier
    Draw(box);

    # and return
    return box;

end );


InstallOtherMethod( Box,
    "using default from sheet",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsInt ],
    0,

function( sheet, x, y, w, h )
    return Box( sheet, x, y, w, h, DefaultsForGraphicObject(sheet) );
end );


#############################################################################
##
#M  Draw( <box> ) . . . . . . . . . . . . . . . . . . . . . . . .  draw a box
##
InstallMethod( Draw,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive ],
    0,

function( box )
    
    # If already on screen, destroy first
    if box!.id >= 0 then   
        WcDestroy(WindowId(box), box!.id);
    fi;
    
    # draw the box and get the identifier
    WcSetColor( WindowId(box), ColorId(box!.color) );
    box!.id := WcDrawBox(WindowId(box), 
                         box!.x, box!.y, box!.x+box!.w, box!.y+box!.h);

end );


#############################################################################
##
#M  Destroy( <box> )  . . . . . . . . . . . . . . . . . . . . . destroy <box>
##
InstallMethod( Destroy,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive],
    0,

function( box )
    WcDestroy( WindowId(box), box!.id );
    box!.id := -1;  # no more on screen, info for Draw, in case of Revive
    ResetFilterObj( box, IsAlive );
end );


#############################################################################
##
#M  Revive( <box> )  . . . . . . . . . . . . . . . . . . . . . . revive <box>
##
InstallMethod( Revive,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep ],
    0,

function( box )
    if IsAlive(box) then return; fi;
    if Position(box!.sheet!.objects,box) = fail then
        Error("<box> must be in objlist of sheet");
    fi;
    SetFilterObj(box,IsAlive);
    Draw(box);
end );


#############################################################################
##
#M  Move( <box>, <x>, <y> ) . . . . . . . . . . . . . . . . . . absolute move
##
InstallMethod( Move,
    "for a box, and two integers",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( box, x, y )

    # make sure that we really have to move
    if x = box!.x and y = box!.y then return;  fi;

    # change the position
    box!.x := x;
    box!.y := y;

    # use 'Draw'
    Draw(box);

end );


#############################################################################
##
#M  MoveDelta( <box>, <dx>, <dy> )  . . . . . . . . . . . . . . .  delta move
##
InstallMethod( MoveDelta,
    "for a box, and two integers",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( box, dx, dy )

    # make sure that we really have to move
    if dx = 0 and dy = 0 then return;  fi;

    # change the dimension
    box!.x := box!.x + dx;
    box!.y := box!.y + dy;

    # use 'Draw'
    Draw(box);

end );


#############################################################################
##
#M  PSString( <box> ) . . . . . . . . . . . . . . .  return PostScript string
##
InstallMethod( PSString,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep ],
    0,
    box -> Concatenation(
	    PSColour(box!.color), " setrgbcolor\n",
            "newpath\n",
            String(box!.x), " ", 
            String(box!.sheet!.height-box!.y)," moveto\n",
            String(box!.x), " ", 
            String(box!.sheet!.height-box!.y-box!.h)," lineto\n",
            String(box!.x+box!.w), " ",
            String(box!.sheet!.height-box!.y-box!.h)," lineto\n",
            String(box!.x+box!.w), " ", 
            String(box!.sheet!.height-box!.y)," lineto\n",
            String(box!.x), " ", 
            String(box!.sheet!.height-box!.y)," lineto\n",
            "closepath\nfill\n" ) 
);


#############################################################################
##
#M  PrintInfo( <box> )  . . . . . . . . . . . . . . . . . print debug message
##
InstallMethod( PrintInfo,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep ],
    0,

function( box )
    Print( "#I Box( ", box!.x, ", ", box!.y, ", ", box!.w, ", ",
           box!.h, " ) = ", box!.id, " @ ",
           Position(box!.sheet!.objects,box), "\n" );
end );


#############################################################################
##
#M  ViewObj( <box> )  . . . . . . . . . . . . . . . . . .  pretty print a box
##
InstallMethod( ViewObj,
    "for a box",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive ],
    0,

function( box )
    Print( "<box>" );
end );


#############################################################################
##
#M  Recolor( <box>, <col> ) . . . . . . . . . . . . . . . . . .  change color
##
InstallMethod( Recolor,
    "for a box, and a color",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive,
      IsColor ],
    0,

function( box, col )

    # set new color
    box!.color := col;

    # and create new one
    Draw(box);

end );


#############################################################################
##
#M  Reshape( <box>, <w>, <h> )  . . . . . . . . . . . . . . . .  change <box>
##
InstallOtherMethod( Reshape,
    "for a box, and two integers",
    true,
    [ IsGraphicObject and IsBoxObjectRep and IsAlive, IsInt, IsInt ],
    0,

function( box, w, h )

    # update box dimensions
    box!.w := w;
    box!.h := h;

    # draw a new one
    Draw(box);

end );


#############################################################################
##
#M  \in( <pos>, <box> ) . . . . . . . . . . . . . . . . . . .  <pos> in <box>
##
InstallMethod( \in,
    "for a pair of integers, and a box",
    true,
    [ IsList and IsCyclotomicCollection,
      IsGraphicObject and IsBoxObjectRep and IsAlive ],
    0,

function( pos, box )
    local   ax,  ay,  ix,  iy;

    ax := Maximum( box!.x, box!.x+box!.w );
    ix := Minimum( box!.x, box!.x+box!.w );
    ay := Maximum( box!.y, box!.y+box!.h );
    iy := Minimum( box!.y, box!.y+box!.h );
    return ix <= pos[1] and pos[1] <= ax and iy <= pos[2] and pos[2] <= ay;

end );


#############################################################################
## Implementation of Circles:


#############################################################################
##
#R  IsCircleObjectRep . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsCircleObjectRep",
    IsGraphicObjectRep,
    [ "id", "x", "y", "r", "width" ],
    IsGraphicObject );


#############################################################################
##
#M  Circle( <sheet>, <x>, <y>, <r> )   . . . . . . . draw a circle in a sheet
#M  Circle( <sheet>, <x>, <y>, <r>, <defaults>)  . . draw a circle in a sheet
##
InstallMethod( Circle,
    "for sheet, three integers, and record of defaults",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsRecord ],
    0,

function( sheet, x, y, r, def )
    local   circle;

    # create a circle object in <sheet>
    circle := GraphicObject( IsCircleObjectRep, sheet, def );
    circle!.x        := x;
    circle!.y        := y;
    circle!.r        := Maximum( 1, AbsInt(r) );
    circle!.width    := def.width;
    # Id's are always non-negative, so Draw knows that not yet drawn
    circle!.id       := -1;   

    # draw the circle and get the identifier
    Draw(circle);

    # and return
    return circle;

end );


InstallOtherMethod( Circle,
    "using default from sheet",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt ],
    0,

function( sheet, x, y, r )
    return Circle( sheet, x, y, r, DefaultsForGraphicObject(sheet) );
end );


#############################################################################
##
#M  Draw( <circle> ) . . . . . . . . . . . . . . . . . . . . .  draw a circle
##
InstallMethod( Draw,
    "for a circle",
    true,
    [ IsGraphicObject and IsCircleObjectRep and IsAlive ],
    0,

function( circle )
  
    # draw the circle and get the identifier
    WcSetColor( WindowId(circle), ColorId(circle!.color) ); 
    WcSetLineWidth( WindowId(circle), circle!.width );
    if circle!.id >= 0 then   # Is already on screen, so destroy first!
        WcDestroy(WindowId(circle), circle!.id);
    fi;
    circle!.id := WcDrawCircle( WindowId(circle), circle!.x, circle!.y, 
                                circle!.r );
end );


#############################################################################
##
#M  Destroy( <circle> )  . . . . . . . . . . . . . . . . . . . destroy circle
##
InstallMethod( Destroy,
    "for a circle",
    true,
    [ IsGraphicObject and IsCircleObjectRep and IsAlive],
    0,

function( circle )
    WcDestroy( WindowId(circle), circle!.id );
    circle!.id := -1;  # no more on screen, info for Draw, in case of Revive
    ResetFilterObj( circle, IsAlive );
end );


#############################################################################
##
#M  Revive( <circle> )  . . . . . . . . . . . . . . . . . . . revive <circle>
##
InstallMethod( Revive,
    "for a circle",
    true,
    [ IsGraphicObject and IsCircleObjectRep ],
    0,

function( circle )
    if IsAlive(circle) then return; fi;
    if Position(circle!.sheet!.objects,circle) = fail then
        Error("<circle> must be in objlist of sheet");
    fi;
    SetFilterObj(circle,IsAlive);
    Draw(circle);
end );


#############################################################################
##
#M  Move( <circle>, <x>, <y> ) . . . . . . . . . . . . . . . .  absolute move
##
InstallMethod( Move,
    "for a circle, and two integers",
    true,
    [ IsGraphicObject and IsCircleObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( circle, x, y )

    # make sure that we really have to move
    if x = circle!.x and y = circle!.y then return;  fi;

    # change the position
    circle!.x := x;
    circle!.y := y;

    # use 'Draw'
    Draw(circle);

end );


#############################################################################
##
#M  MoveDelta( <circle>, <dx>, <dy> ) . . . . . . . . . . . . . .  delta move
##
InstallMethod( MoveDelta,
    "for a circle, and two integers",
    true,
    [ IsGraphicObject and IsCircleObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( circle, dx, dy )

    # make sure that we really have to move
    if dx = 0 and dy = 0 then return;  fi;

    # change the dimension
    circle!.x := circle!.x + dx;
    circle!.y := circle!.y + dy;

    # use 'Draw'
    Draw(circle);

end );


#############################################################################
##
#M  PSString( <circle> )  . . . . . . . . . . . . .  output Postscript-String
##
InstallMethod( PSString,
    "for a circle",
    true,
    [ IsGraphicObject and IsCircleObjectRep ],
    0,
    circle -> Concatenation(
	    PSColour(circle!.color), " setrgbcolor\n",
            "newpath\n",
            String(circle!.x), " ", String(circle!.sheet!.height-circle!.y), 
            " ", String(circle!.r), " 0 360 arc\n",
            String(circle!.width), " setlinewidth\n",
            "stroke\n" )
);


#############################################################################
##
#M  PrintInfo( <circle> ) . . . . . . . . . . . . . . . . print debug message
##
InstallMethod( PrintInfo,
    "for a circle",
    true,
    [ IsGraphicObject and IsCircleObjectRep ],
    0,

function( circle )
    Print( "#I Circle( ", circle!.x, ", ", circle!.y, ", ",
           circle!.r, " ) = ", circle!.id, " @ ",
    	   Position(circle!.sheet!.objects,circle), "\n" );
        
end );


#############################################################################
##
#M  ViewObj( <circle> ) . . . . . . . . . . . . . . . . pretty print a circle
##
InstallMethod( ViewObj,
    "for a circle",
    true,
    [ IsGraphicObject and IsCircleObjectRep and IsAlive ],
    0,

function( circle )
    Print( "<circle>" );
end );


#############################################################################
##
#M  Recolor( <circle>, <col> )  . . . . . . . . . . . . . . . .  change color
##
InstallMethod( Recolor,
    "for a circle, and a color",
    true,
    [ IsGraphicObject and IsCircleObjectRep and IsAlive,
      IsColor ],
    0,

function( circle, col )

    # set new color
    circle!.color := col;

    # and create new one
    Draw(circle);

end );


#############################################################################
##
#M  Reshape( <circle>, <r> )  . . . . . . . . . . . . . . . . . change circle
##
InstallOtherMethod( Reshape,
    "for a circle, and an integer",
    true,
    [ IsGraphicObject and IsCircleObjectRep and IsAlive, IsInt ],
    0,

function( circle, r )

    # update circle radius
    circle!.r := r;

    # draw a new one
    Draw(circle);

end );


#############################################################################
##
#M  SetWidth( <circle>, <width> ) . . . . . . . . . . . . . . . change circle
##
InstallOtherMethod( SetWidth,
    "for a circle, and an integer",
    true,
    [ IsGraphicObject and IsCircleObjectRep and IsAlive, IsInt ],
    0,

function( circle, width )

    # update circle line width
    circle!.width := width;

    # draw a new one
    Draw(circle);

end );


#############################################################################
##
#M  \in( <pos>, <circle> ) . . . . . . . . . . . . . . . .  <pos> in <circle>
##
InstallMethod( \in,
    "for a pair of integers, and a box",
    true,
    [ IsList and IsCyclotomicCollection,
      IsGraphicObject and IsCircleObjectRep and IsAlive ],
    0,

function( pos, circle )
    return (pos[1]-circle!.x)^2+(pos[2]-circle!.y)^2 < (circle!.r+3)^2;
end );



#############################################################################
## Implementation of Discs:


#############################################################################
##
#R  IsDiscObjectRep . . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsDiscObjectRep",
    IsGraphicObjectRep,
    [ "id", "x", "y", "r" ],
    IsGraphicObject );


#############################################################################
##
#M  Disc( <sheet>, <x>, <y>, <r> )  . . . . . . . . .  draw a disc in a sheet
#M  Disc( <sheet>, <x>, <y>, <r>, <defaults> )  . . .  draw a disc in a sheet
##
InstallMethod( Disc,
    "for sheet, three integers, and record of defaults",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsRecord ],
    0,

function( sheet, x, y, r, def )
    local   disc;

    # create a disc object in <sheet>
    disc := GraphicObject( IsDiscObjectRep, sheet, def );
    disc!.x        := x;
    disc!.y        := y;
    disc!.r        := Maximum( 1, AbsInt(r) );
    # Id's are always non-negative, so Draw knows that not yet drawn
    disc!.id       := -1;
    
    # draw the disc and get the identifier
    Draw(disc);

    # and return
    return disc;

end );


InstallOtherMethod( Disc,
    "using default from sheet",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt ],
    0,

function( sheet, x, y, r )
    return Disc( sheet, x, y, r, DefaultsForGraphicObject(sheet) );
end );


#############################################################################
##
#M  Draw( <disc> ) . . . . . . . . . . . . . . . . . . . . . . .  draw a disc
##
InstallMethod( Draw,
    "for a disc",
    true,
    [ IsGraphicObject and IsDiscObjectRep and IsAlive ],
    0,

function( disc )
    
    # If already on screen, destroy first
    if disc!.id >= 0 then   
        WcDestroy(WindowId(disc), disc!.id);
    fi;
    
    # draw the disc and get the identifier
    WcSetColor( WindowId(disc), ColorId(disc!.color) ); 
    disc!.id := WcDrawDisc( WindowId(disc), disc!.x, disc!.y, disc!.r );
    
end );


#############################################################################
##
#M  Destroy( <disc> )  . . . . . . . . . . . . . . . . . . . . . destroy disc
##
InstallMethod( Destroy,
    "for a disc",
    true,
    [ IsGraphicObject and IsDiscObjectRep and IsAlive],
    0,

function( disc )
    WcDestroy( WindowId(disc), disc!.id );
    disc!.id := -1;  # no more on screen, info for Draw, in case of Revive
    ResetFilterObj( disc, IsAlive );
end );


#############################################################################
##
#M  Revive( <disc> )  . . . . . . . . . . . . . . . . . . . . . revive <disc>
##
InstallMethod( Revive,
    "for a disc",
    true,
    [ IsGraphicObject and IsDiscObjectRep ],
    0,

function( disc )
    if IsAlive(disc) then return; fi;
    if Position(disc!.sheet!.objects,disc) = fail then
        Error("<disc> must be in objlist of sheet");
    fi;
    SetFilterObj(disc,IsAlive);
    Draw(disc);
end );


#############################################################################
##
#M  Move( <disc>, <x>, <y> ) . . . . . . . . . . . . . . . . .  absolute move
##
InstallMethod( Move,
    "for a disc, and two integers",
    true,
    [ IsGraphicObject and IsDiscObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( disc, x, y )

    # make sure that we really have to move
    if x = disc!.x and y = disc!.y then return;  fi;

    # change the position
    disc!.x := x;
    disc!.y := y;

    # use 'Draw'
    Draw(disc);

end );


#############################################################################
##
#M  MoveDelta( <disc>, <dx>, <dy> ) . . . . . . . . . . . . . . .  delta move
##
InstallMethod( MoveDelta,
    "for a disc, and two integers",
    true,
    [ IsGraphicObject and IsDiscObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( disc, dx, dy )

    # make sure that we really have to move
    if dx = 0 and dy = 0 then return;  fi;

    # change the dimension
    disc!.x := disc!.x + dx;
    disc!.y := disc!.y + dy;

    # use 'Draw'
    Draw(disc);

end );


#############################################################################
##
#M  PSString( <disc> )  . . . . . . . . . . . . . .  output Postscript-String
##
InstallMethod( PSString,
    "for a disc",
    true,
    [ IsGraphicObject and IsDiscObjectRep ],
    0,
    disc -> Concatenation(
	      PSColour(disc!.color), " setrgbcolor\n",
              "newpath\n",
              String(disc!.x), " ", String(disc!.sheet!.height-disc!.y), " ",
              String(disc!.r), " 0 360 arc\nfill\n" )
);


#############################################################################
##
#M  PrintInfo( <disc> ) . . . . . . . . . . . . . . . . print debug message
##
InstallMethod( PrintInfo,
    "for a disc",
    true,
    [ IsGraphicObject and IsDiscObjectRep ],
    0,

function( disc )
    Print( "#I Disc( ", disc!.x, ", ", disc!.y, ", ",
           disc!.r, " ) = ", disc!.id, " @ ",
    	   Position(disc!.sheet!.objects,disc), "\n" );
        
end );


#############################################################################
##
#M  ViewObj( <disc> )  . . . . . . . . . . . . . . . . .  pretty print a disc
##
InstallMethod( ViewObj,
    "for a disc",
    true,
    [ IsGraphicObject and IsDiscObjectRep and IsAlive ],
    0,

function( disc )
    Print( "<disc>" );
end );


#############################################################################
##
#M  Recolor( <disc>, <col> )  . . . . . . . . . . . . . . . . .  change color
##
InstallMethod( Recolor,
    "for a disc, and a color",
    true,
    [ IsGraphicObject and IsDiscObjectRep and IsAlive,
      IsColor ],
    0,

function( disc, col )

    # set new color
    disc!.color := col;

    # and create new one
    Draw(disc);

end );


#############################################################################
##
#M  Reshape( <disc>, <r> )  . . . . . . . . . . . . . . . . . . . change disc
##
InstallOtherMethod( Reshape,
    "for a disc, and an integer",
    true,
    [ IsGraphicObject and IsDiscObjectRep and IsAlive, IsInt ],
    0,

function( disc, r )

    # update disc radius
    disc!.r := r;

    # draw a new one
    Draw(disc);

end );


#############################################################################
##
#M  \in( <pos>, <disc> ) . . . . . . . . . . . . . . . .  <pos> in <disc>
##
InstallMethod( \in,
    "for a pair of integers, and a box",
    true,
    [ IsList and IsCyclotomicCollection,
      IsGraphicObject and IsDiscObjectRep and IsAlive ],
    0,

function( pos, disc )
    return (pos[1]-disc!.x)^2+(pos[2]-disc!.y)^2 <= (disc!.r)^2;
end );


#############################################################################
## Implementation of Diamonds:


#############################################################################
##
#R  IsDiamondObjectRep  . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsDiamondObjectRep",
    IsGraphicObjectRep,
    [ "id", "x", "y", "w", "h", "width" ],
    IsGraphicObject );


#############################################################################
##
#M  Diamond( <sheet>, <x>, <y>, <w>, <h> )  . . . . draw a diamond in a sheet
#M  Diamond( <sheet>, <x>, <y>, <w>, <h>, <defaults> ) . . . . . . . . . dito
##
InstallMethod( Diamond,
    "for sheet, four integers, and record of defaults",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsInt,
      IsRecord ],
    0,

function( sheet, x, y, w, h, def )
    local   dia;

    # create a diamond object in <sheet>
    dia := GraphicObject( IsDiamondObjectRep, sheet, def );
    dia!.x := x;
    dia!.y := y;
    dia!.w := w;
    dia!.h := h;
    dia!.width := def.width;
    # Empty, so Draw knows that not yet drawn
    dia!.ids := [-1,-1,-1,-1];
    
    # draw the Diamond and get the identifier
    Draw(dia);

    # and return
    return dia;

end );


InstallOtherMethod( Diamond,
    "using default from sheet",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsInt ],
    0,

function( sheet, x, y, w, h )
    return Diamond( sheet, x, y, w, h, DefaultsForGraphicObject(sheet) );
end );


#############################################################################
##
#M  Draw( <dia> ) . . . . . . . . . . . . . . . . . . . . . .  draw a diamond
##
InstallMethod( Draw,
    "for a diamond",
    true,
    [ IsGraphicObject and IsDiamondObjectRep and IsAlive ],
    0,

function( dia )
    
    local   x1,  y1,  x2,  y2,  x3,  y3,  x4,  y4;

    # create the four corners
    x1 := dia!.x;
    y1 := dia!.y;
    x2 := dia!.x + dia!.w;
    y2 := dia!.y + dia!.h;
    x3 := 2*x2-x1;
    y3 := y1;
    x4 := x2;
    y4 := 2*y1-y2;

    # If already on screen, destroy first
    if not dia!.ids[1] = -1 then   
        WcDestroyFlat(WindowId(dia), dia!.ids);
    fi;
    
    # draw the diamond and get the identifier
    WcSetColor( WindowId(dia), ColorId(dia!.color) );
    WcSetLineWidth( WindowId(dia), dia!.width );
    dia!.ids[1] := WcDrawLine( WindowId(dia), x1, y1, x2, y2 );
    dia!.ids[2] := WcDrawLine( WindowId(dia), x2, y2, x3, y3 );
    dia!.ids[3] := WcDrawLine( WindowId(dia), x3, y3, x4, y4 );
    dia!.ids[4] := WcDrawLine( WindowId(dia), x4, y4, x1, y1 );

end );


#############################################################################
##
#M  Destroy( <dia> )  . . . . . . . . . . . . . . . . . . . . . destroy <dia>
##
InstallMethod( Destroy,
    "for a diamond",
    true,
    [ IsGraphicObject and IsDiamondObjectRep and IsAlive],
    0,

function( dia )
    WcDestroyFlat( WindowId(dia), dia!.ids );
    # no more on screen, info for Draw, in case of Revive
    dia!.ids := [-1,-1,-1,-1];  
    ResetFilterObj( dia, IsAlive );
end );


#############################################################################
##
#M  Revive( <dia> )  . . . . . . . . . . . . . . . . . . . . . . revive <dia>
##
InstallMethod( Revive,
    "for a diamond",
    true,
    [ IsGraphicObject and IsDiamondObjectRep ],
    0,

function( dia )
    if IsAlive(dia) then return; fi;
    if Position(dia!.sheet!.objects,dia) = fail then
        Error("<diamond> must be in objlist of sheet");
    fi;
    SetFilterObj(dia,IsAlive);
    Draw(dia);
end );


#############################################################################
##
#M  Move( <dia>, <x>, <y> ) . . . . . . . . . . . . . . . . . . absolute move
##
InstallMethod( Move,
    "for a diamond, and two integers",
    true,
    [ IsGraphicObject and IsDiamondObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( dia, x, y )

    # make sure that we really have to move
    if x = dia!.x and y = dia!.y then return;  fi;

    # change the position
    dia!.x := x;
    dia!.y := y;

    # use 'Draw'
    Draw(dia);

end );

#############################################################################
##
#M  MoveDelta( <dia>, <dx>, <dy> )  . . . . . . . . . . . . . . .  delta move
##
InstallMethod( MoveDelta,
    "for a diamond, and two integers",
    true,
    [ IsGraphicObject and IsDiamondObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( dia, dx, dy )

    # make sure that we really have to move
    if dx = 0 and dy = 0 then return;  fi;

    # change the dimension
    dia!.x := dia!.x + dx;
    dia!.y := dia!.y + dy;

    # use 'Draw'
    Draw(dia);

end );


#############################################################################
##
#M  PSString( <dia> ) . . . . . . . . . . . . . . Postscript string for <dia>
##
InstallMethod( PSString,
    "for a diamond",
    true,
    [ IsGraphicObject and IsDiamondObjectRep ],
    0,
        
function (dia)
    
    local   x1,  x2,  x3,  x4,  y1,  y2,  y3,  y4;
    
    # create the four corners, transform y-coordinate
    x1 := dia!.x;
    y1 := dia!.y;
    x2 := dia!.x + dia!.w;
    y2 := dia!.y + dia!.h;
    x3 := 2*x2-x1;
    y3 := y1;
    x4 := x2;
    y4 := 2*y1-y2;

    y1 := dia!.sheet!.height - y1;
    y2 := dia!.sheet!.height - y2;
    y3 := dia!.sheet!.height - y3;
    y4 := dia!.sheet!.height - y4;
    return Concatenation(
	           PSColour(dia!.color), " setrgbcolor\n",
                   "newpath\n",
                   String(x1), " ", String(y1), " moveto\n",
                   String(x2), " ", String(y2), " lineto\n",
                   String(x3), " ", String(y3), " lineto\n",
                   String(x4), " ", String(y4), " lineto\n",
                   String(x1), " ", String(y1), " lineto\n",
                   String(dia!.width), " setlinewidth\n",
                   "closepath\nstroke\n" );
end );


#############################################################################
##
#M  PrintInfo( <dia> )  . . . . . . . . . . . . . . . . . print debug message
##
InstallMethod( PrintInfo,
    "for a diamond",
    true,
    [ IsGraphicObject and IsDiamondObjectRep ],
    0,

function( dia )
    Print( "#I Diamond( ", dia!.x, ", ", dia!.y, ", ",
           dia!.w, ", ", dia!.h, " ) = ", dia!.ids[1], "+",
           dia!.ids[2], "+", dia!.ids[3], "+", dia!.ids[4], " @ ",
    	   Position(dia!.sheet!.objects,dia), "\n" );
end );


#############################################################################
##
#M  ViewObj( <dia> )  . . . . . . . . . . . . . . . .  pretty print a diamond
##
InstallMethod( ViewObj,
    "for a diamond",
    true,
    [ IsGraphicObject and IsDiamondObjectRep and IsAlive ],
    0,

function( dia )
    Print( "<diamond>" );
end );


#############################################################################
##
#M  Recolor( <dia>, <col> ) . . . . . . . . . . . . . . . . . .  change color
##
InstallMethod( Recolor,
    "for a diamond, and a color",
    true,
    [ IsGraphicObject and IsDiamondObjectRep and IsAlive,
      IsColor ],
    0,

function( dia, col )

    # set new color
    dia!.color := col;

    # and create new one
    Draw(dia);

end );


#############################################################################
##
#M  Reshape( <dia>, <w>, <h> )  . . . . . . . . . . . . . . . .  change <dia>
##
InstallOtherMethod( Reshape,
    "for a diamond, and two integers",
    true,
    [ IsGraphicObject and IsDiamondObjectRep and IsAlive, IsInt, IsInt ],
    0,

function( dia, w, h )

    # update diamond dimensions
    dia!.w := w;
    dia!.h := h;

    # draw a new one
    Draw(dia);

end );


#############################################################################
##
#M  SetWidth( <dia>, <width> ) . . . . . . . . . . . . . . . . change diamond
##
InstallOtherMethod( SetWidth,
    "for a diamond, and an integer",
    true,
    [ IsGraphicObject and IsDiamondObjectRep and IsAlive, IsInt ],
    0,
 
function( dia, width )

    # update diamond line width
    dia!.width := width;

    # draw a new one
    Draw(dia);

end );


#############################################################################
##
#M  \in( <pos>, <dia> ) . . . . . . . . . . . . . . . . . . .  <pos> in <dia>
##
InstallMethod( \in,
    "for a pair of integers, and a diamond",
    true,
    [ IsList and IsCyclotomicCollection,
      IsGraphicObject and IsDiamondObjectRep and IsAlive ],
    0,

function( pos, dia )
    
    local   x1,  x3,  y2,  y4;
    
    # create the four corners, transform y-coordinate
    x1 := dia!.x;
    x3 := dia!.x+2*dia!.w;
    y2 := dia!.y + dia!.h;
    y4 := 2*dia!.y-y2;

    return     Minimum( x1, x3 ) <= pos[1]
           and pos[1] <= Maximum( x1, x3 )
           and Minimum( y2, y4 ) <= pos[2]
           and pos[2] <= Maximum( y2, y4 );    
end );



#############################################################################
## Implementation of Rectangles:


#############################################################################
##
#R  IsRectangleObjectRep  . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsRectangleObjectRep",
    IsGraphicObjectRep,
    [ "id", "x", "y", "w", "h", "width" ],
    IsGraphicObject );


#############################################################################
##
#M  Rectangle( <sheet>, <x>, <y>, <w>, <h> )  . . draw a rectangle in a sheet
#M  Rectangle( <sheet>, <x>, <y>, <w>, <h>, <defaults> ) . . . . . . . . dito
##
InstallMethod( Rectangle,
    "for sheet, four integers, and record of defaults",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsInt,
      IsRecord ],
    0,

function( sheet, x, y, w, h, def )
    local   rect;

    # create a rectangle object in <sheet>
    rect := GraphicObject( IsRectangleObjectRep, sheet, def );
    rect!.x := x;
    rect!.y := y;
    rect!.w := w;
    rect!.h := h;
    rect!.width := def.width;
    # Empty, so Draw knows that not yet drawn
    rect!.ids := [-1,-1,-1,-1];
    
    # draw the Rectangle and get the identifier
    Draw(rect);

    # and return
    return rect;

end );


InstallOtherMethod( Rectangle,
    "using default from sheet",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsInt ],
    0,

function( sheet, x, y, w, h )
    return Rectangle( sheet, x, y, w, h, DefaultsForGraphicObject(sheet) );
end );


#############################################################################
##
#M  Draw( <rect> ) . . . . . . . . . . . . . . . . . . . . . draw a rectangle
##
InstallMethod( Draw,
    "for a rectangle",
    true,
    [ IsGraphicObject and IsRectangleObjectRep and IsAlive ],
    0,

function( rect )
    
    local   x1,  y1,  x2,  y2,  x3,  y3,  x4,  y4;

    # create the four corners
    x1 := rect!.x;
    y1 := rect!.y;
    x2 := x1;
    y2 := y1 + rect!.h;
    x3 := x1 + rect!.w;
    y3 := y2;
    x4 := x3;
    y4 := y1;

    # If already on screen, destroy first
    if not rect!.ids[1] = -1 then   
        WcDestroyFlat(WindowId(rect), rect!.ids);
    fi;
    
    # draw the rectangle and get the identifier
    WcSetColor( WindowId(rect), ColorId(rect!.color) );
    WcSetLineWidth( WindowId(rect), rect!.width );
    rect!.ids[1] := WcDrawLine( WindowId(rect), x1, y1, x2, y2 );
    rect!.ids[2] := WcDrawLine( WindowId(rect), x2, y2, x3, y3 );
    rect!.ids[3] := WcDrawLine( WindowId(rect), x3, y3, x4, y4 );
    rect!.ids[4] := WcDrawLine( WindowId(rect), x4, y4, x1, y1 );

end );


#############################################################################
##
#M  Destroy( <rect> )  . . . . . . . . . . . . . . . . . . . . destroy <rect>
##
InstallMethod( Destroy,
    "for a rectangle",
    true,
    [ IsGraphicObject and IsRectangleObjectRep and IsAlive],
    0,

function( rect )
    WcDestroyFlat( WindowId(rect), rect!.ids );
    # no more on screen, info for Draw, in case of Revive
    rect!.ids := [-1,-1,-1,-1];  
    ResetFilterObj( rect, IsAlive );
end );


#############################################################################
##
#M  Revive( <rect> )  . . . . . . . . . . . . . . . . . . . . . revive <rect>
##
InstallMethod( Revive,
    "for a rectangle",
    true,
    [ IsGraphicObject and IsRectangleObjectRep ],
    0,

function( rect )
    if IsAlive(rect) then return; fi;
    if Position(rect!.sheet!.objects,rect) = fail then
        Error("<rectangle> must be in objlist of sheet");
    fi;
    SetFilterObj(rect,IsAlive);
    Draw(rect);
end );


#############################################################################
##
#M  Move( <rect>, <x>, <y> ) . . . . . . . . . . . . . . . . .  absolute move
##
InstallMethod( Move,
    "for a rectangle, and two integers",
    true,
    [ IsGraphicObject and IsRectangleObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( rect, x, y )

    # make sure that we really have to move
    if x = rect!.x and y = rect!.y then return;  fi;

    # change the position
    rect!.x := x;
    rect!.y := y;

    # use 'Draw'
    Draw(rect);

end );


#############################################################################
##
#M  MoveDelta( <rect>, <dx>, <dy> )  . . . . . . . . . . . . . . . delta move
##
InstallMethod( MoveDelta,
    "for a rectangle, and two integers",
    true,
    [ IsGraphicObject and IsRectangleObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( rect, dx, dy )

    # make sure that we really have to move
    if dx = 0 and dy = 0 then return;  fi;

    # change the dimension
    rect!.x := rect!.x + dx;
    rect!.y := rect!.y + dy;

    # use 'Draw'
    Draw(rect);

end );


#############################################################################
##
#M  PSString( <rect> ) . . . . . . . . . . . . . Postscript string for <rect>
##
InstallMethod( PSString,
    "for a rectangle",
    true,
    [ IsGraphicObject and IsRectangleObjectRep ],
    0,
        
function (rect)
    
    local   x1,  x2,  x3,  x4,  y1,  y2,  y3,  y4;
    
    # create the four corners, transform y-coordinate
    x1 := rect!.x;
    y1 := rect!.y;
    x2 := x1;
    y2 := y1 + rect!.h;
    x3 := x1 + rect!.w;
    y3 := y2;
    x4 := x3;
    y4 := y1;

    y1 := rect!.sheet!.height - y1;
    y2 := rect!.sheet!.height - y2;
    y3 := rect!.sheet!.height - y3;
    y4 := rect!.sheet!.height - y4;
    return Concatenation(
	           PSColour(rect!.color), " setrgbcolor\n",
                   "newpath\n",
                   String(x1), " ", String(y1), " moveto\n",
                   String(x2), " ", String(y2), " lineto\n",
                   String(x3), " ", String(y3), " lineto\n",
                   String(x4), " ", String(y4), " lineto\n",
                   String(x1), " ", String(y1), " lineto\n",
                   String(rect!.width), " setlinewidth\n",
                   "closepath\nstroke\n" );
end );


#############################################################################
##
#M  PrintInfo( <rect> ) . . . . . . . . . . . . . . . . . print debug message
##
InstallMethod( PrintInfo,
    "for a rectangle",
    true,
    [ IsGraphicObject and IsRectangleObjectRep ],
    0,

function( rect )
    Print( "#I Rectangle( ", rect!.x, ", ", rect!.y, ", ",
           rect!.w, ", ", rect!.h, " ) = ", rect!.ids[1], "+",
           rect!.ids[2], "+", rect!.ids[3], "+", rect!.ids[4], " @ ",
    	   Position(rect!.sheet!.objects,rect), "\n" );
end );


#############################################################################
##
#M  ViewObj( <rect> ) . . . . . . . . . . . . . . .  pretty print a rectangle
##
InstallMethod( ViewObj,
    "for a rectangle",
    true,
    [ IsGraphicObject and IsRectangleObjectRep and IsAlive ],
    0,

function( rect )
    Print( "<rectangle>" );
end );


#############################################################################
##
#M  Recolor( <rect>, <col> )  . . . . . . . . . . . . . . . . .  change color
##
InstallMethod( Recolor,
    "for a rectangle, and a color",
    true,
    [ IsGraphicObject and IsRectangleObjectRep and IsAlive,
      IsColor ],
    0,

function( rect, col )

    # set new color
    rect!.color := col;

    # and create new one
    Draw(rect);

end );


#############################################################################
##
#M  Reshape( <rect>, <w>, <h> )  . . . . . . . . . . . . . . .  change <rect>
##
InstallOtherMethod( Reshape,
    "for a rectangle, and two integers",
    true,
    [ IsGraphicObject and IsRectangleObjectRep and IsAlive, IsInt, IsInt ],
    0,

function( rect, w, h )

    # update rectangle dimensions
    rect!.w := w;
    rect!.h := h;

    # draw a new one
    Draw(rect);

end );


#############################################################################
##
#M  SetWidth( <rect>, <width> )  . . . . . . . . . . . . . . change rectangle
##
InstallOtherMethod( SetWidth,
    "for a rectangle, and an integer",
    true,
    [ IsGraphicObject and IsRectangleObjectRep and IsAlive, IsInt ],
    0,
 
function( rect, width )

    # update rectangle line width
    rect!.width := width;

    # draw a new one
    Draw(rect);

end );


#############################################################################
##
#M  \in( <pos>, <rect> ) . . . . . . . . . . . . . . . . . .  <pos> in <rect>
##
InstallMethod( \in,
    "for a pair of integers, and a rectangle",
    true,
    [ IsList and IsCyclotomicCollection,
      IsGraphicObject and IsRectangleObjectRep and IsAlive ],
    0,

function( pos, rect )
    
    local   x1,  x3,  y2,  y4;
    
    # create the four corners, transform y-coordinate
    x1 := rect!.x;
    x3 := rect!.x+rect!.w;
    y2 := rect!.y;
    y4 := rect!.y+rect!.h;

    return     Minimum( x1, x3 ) <= pos[1]
           and pos[1] <= Maximum( x1, x3 )
           and Minimum( y2, y4 ) <= pos[2]
           and pos[2] <= Maximum( y2, y4 );    
end );


#############################################################################
## Implementation of Lines:


#############################################################################
##
#R  IsLineObjectRep . . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsLineObjectRep",
    IsGraphicObjectRep,
    [ "id", "x", "y", "w", "h", "width" ],
    IsGraphicObject );


#############################################################################
##
#M  Line( <sheet>, <x>, <y>, <w>, <h> )  . . . . . . . draw a line in a sheet
#M  Line( <sheet>, <x>, <y>, <w>, <h>, <defaults> )  . . . . . . . . . . dito
##
InstallMethod( Line,
    "for sheet, four integers, and record of defaults",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsInt,
      IsRecord ],
    0,

function( sheet, x, y, w, h, def )
    local   line;

    # create a line object in <sheet>
    line := GraphicObject( IsLineObjectRep, sheet, def );
    line!.x := x;
    line!.y := y;
    line!.w := w;
    line!.h := h;
    line!.width := def.width;
    # Empty, so Draw knows that not yet drawn
    line!.id := -1;
    # Not yet labelled:
    line!.label := false;

    # draw the Line and get the identifier
    Draw(line);
    
    # now the label if applicable:
    if IsBound(def.label) and def.label <> false then
      Relabel(line,def.label);
    fi;
    
    # and return
    return line;

end );


InstallOtherMethod( Line,
    "using default from sheet",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsInt,
      IsInt ],
    0,

function( sheet, x, y, w, h )
    return Line( sheet, x, y, w, h, DefaultsForGraphicObject(sheet) );
end );


#############################################################################
##
#M  Draw( <line> )  . . . . . . . . . . . . . . . . . . . . . . . draw a line
##
InstallMethod( Draw,
    "for a line",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive ],
    0,

function( line )
    
    # If already on screen, destroy first
    if not line!.id = -1 then   
        WcDestroy(WindowId(line), line!.id);
    fi;

    # draw the line and get the identifier
    WcSetColor( WindowId(line), ColorId(line!.color) );
    WcSetLineWidth( WindowId(line), line!.width );
    line!.id := WcDrawLine( WindowId(line), line!.x, line!.y, 
                        line!.x+line!.w, line!.y+line!.h );

    # is there a label?
    if line!.label <> false then
        # This is for the case that something with the line changed:
        Relabel(line,line!.label!.text);   
    fi;
    
end );


#############################################################################
##
#M  Destroy( <line> )  . . . . . . . . . . . . . . . . . . . . destroy <line>
##
InstallMethod( Destroy,
    "for a line",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive],
    0,

function( line )
    
    if line!.label <> false then
        # Label is always deleted when Line destroyed!
        Delete( line!.label!.sheet, line!.label);   
        line!.label := false;
    fi;
    
    WcDestroy( WindowId(line), line!.id );
    # no more on screen, info for Draw, in case of Revive
    line!.id := -1;
    ResetFilterObj( line, IsAlive );
end );


#############################################################################
##
#M  Revive( <line> )  . . . . . . . . . . . . . . . . . . . . . revive <line>
##
InstallMethod( Revive,
    "for a line",
    true,
    [ IsGraphicObject and IsLineObjectRep ],
    0,

function( line )
    if IsAlive(line) then return; fi;
    if Position(line!.sheet!.objects,line) = fail then
        Error("<line> must be in objlist of sheet");
    fi;
    SetFilterObj(line,IsAlive);
    Draw(line);     # Label is recreated if present
    # Comment: Relabel works regardless of "IsAlive"-State of Label
    
end );


#############################################################################
##
#M  Move( <line>, <x>, <y> ) . . . . . . . . . . . . . . . . .  absolute move
##
InstallMethod( Move,
    "for a line, and two integers",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( line, x, y )

    # make sure that we really have to move
    if x = line!.x and y = line!.y then return;  fi;

    # change the position
    line!.x := x;
    line!.y := y;

    # use 'Draw'
    Draw(line);

end );


#############################################################################
##
#M  MoveDelta( <line>, <dx>, <dy> )  . . . . . . . . . . . . . . . delta move
##
InstallMethod( MoveDelta,
    "for a line, and two integers",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( line, dx, dy )

    # make sure that we really have to move
    if dx = 0 and dy = 0 then return;  fi;

    # change the dimension
    line!.x := line!.x + dx;
    line!.y := line!.y + dy;

    # use 'Draw'
    Draw(line);

end );


#############################################################################
##
#M  PSString( <line> ) . . . . . . . . . . . . . Postscript string for <line>
##
InstallMethod( PSString,
    "for a line",
    true,
    [ IsGraphicObject and IsLineObjectRep ],
    0,
        
function (line)
    
    return Concatenation(
	PSColour(line!.color), " setrgbcolor\n",
        "newpath\n",
        String(line!.x), " ", String(line!.sheet!.height-line!.y), " moveto\n",
        String(line!.x+line!.w), " ", 
        String(line!.sheet!.height-line!.y-line!.h), " lineto\n",
        String(line!.width), " setlinewidth\n",
        "stroke\n" );
end );


#############################################################################
##
#M  PrintInfo( <line> ) . . . . . . . . . . . . . . . . . print debug message
##
InstallMethod( PrintInfo,
    "for a line",
    true,
    [ IsGraphicObject and IsLineObjectRep ],
    0,

function( line )
    Print( "#I Line( ", line!.x, ", ", line!.y, ", ",
           line!.w, ", ", line!.h, " ) = ", line!.id, " @ ",
    	   Position(line!.sheet!.objects,line), "\n" );
end );


#############################################################################
##
#M  ViewObj( <line> )  . . . . . . . . . . . . . . . . .  pretty print a line
##
InstallMethod( ViewObj,
    "for a line",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive ],
    0,

function( line )
    Print( "<line>" );
end );


#############################################################################
##
#M  Recolor( <line>, <col> )  . . . . . . . . . . . . . . . . .  change color
##
InstallMethod( Recolor,
    "for a line, and a color",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive,
      IsColor ],
    0,

function( line, col )

    # set new color
    line!.color := col;

    # and create new one
    Draw(line);
#THINK: Recolor Label?

end );


#############################################################################
##
#M  Reshape( <line>, <w>, <h> )  . . . . . . . . . . . . . . .  change <line>
##
InstallOtherMethod( Reshape,
    "for a line, and two integers",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive, IsInt, IsInt ],
    0,

function( line, w, h )

    # update line dimensions
    line!.w := w;
    line!.h := h;

    # draw a new one
    Draw(line);

end );


#############################################################################
##
#M  Change( <line>, <x>, <y>, <w>, <h> ) . . . . . . . . . . .  change <line>
##
InstallOtherMethod( Change,
    "for a line, and four integers",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive, 
      IsInt, IsInt, IsInt, IsInt ],
    0,

function( line, x, y, w, h )

    # update line dimensions
    line!.x := x;
    line!.y := y;
    line!.w := w;
    line!.h := h;

    # draw a new one
    Draw(line);

end );


#############################################################################
##
#F  LabelPosition( <line> ) . . . . . . . . . . . . . . . . position of label
##
InstallMethod( LabelPosition,
    "for a line",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive],
    0,
        
function( line )
    local   x1,  y1,  x2,  y2,  x,  y;

    if line!.h >= 0 then
        x1 := line!.x;  x2 := line!.x + line!.w;
        y1 := line!.y;  y2 := line!.y + line!.h;
    else
        x1 := line!.x + line!.w;  x2 := line!.x;
        y1 := line!.y + line!.h;  y2 := line!.y;
    fi;
    x := x1 + QuoInt( x2-x1, 2 );
    y := y1 + QuoInt( y2-y1, 2 );
    if x1-10*FontInfo(FONTS.tiny)[1] < x2 and 
       x2 < x1+10*FontInfo(FONTS.tiny)[1]  then
        x := x + QuoInt(FontInfo(FONTS.tiny)[1],2);
    fi;
    if y2 < y1+(FontInfo(FONTS.tiny)[2]+FontInfo(FONTS.tiny)[1])*3  then
        y := y - QuoInt( FontInfo(FONTS.tiny)[2]+FontInfo(FONTS.tiny)[3], 2 );
    fi;
    if x2 < x1 then
        x := x + FontInfo(FONTS.tiny)[1];
    fi;
    return [ x, y ];

end );


#############################################################################
##
#M  Relabel( <line>, <str> )  . . . . . . . . . . attach str as label to line
##
InstallOtherMethod( Relabel,
    "for a line, and a string",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive, IsString ],
    0,

function( line, str )
    local pos, col;
    
    if line!.label <> false then
        # there is already a label, delete it:
        Delete( line!.label!.sheet, line!.label);
    fi;
    if str = "" then
        # Label is to be removed!
        line!.label := false;
        return;
    fi;
    
    # update line dimensions
    pos := LabelPosition(line);
    col := rec( color := line!.color );
    line!.label := Text(line!.sheet,FONTS.tiny,pos[1],pos[2],str,col);
    
    # no redraw necessary because Text already drawn!

end );


#############################################################################
##
#M  SetWidth( <line>, <width> ) . . . . . . . . . . . . . . . . . change line
##
InstallOtherMethod( SetWidth,
    "for a line, and an integer",
    true,
    [ IsGraphicObject and IsLineObjectRep and IsAlive, IsInt ],
    0,
 
function( line, width )

    # update line line width
    line!.width := width;

    # draw a new one
    Draw(line);

end );


#############################################################################
##
#M  \in( <pos>, <line> ) . . . . . . . . . . . . . . . . . .  <pos> in <line>
##
InstallMethod( \in,
    "for a pair of integers, and a line",
    true,
    [ IsList and IsCyclotomicCollection,
      IsGraphicObject and IsLineObjectRep and IsAlive ],
    0,

function( pos, line )
    
    local   x,  y,  ax,  ay,  ix,  iy,  x1,  y1,  x2,  y2;
    
    x  := pos[1];
    y  := pos[2];
    x1 := line!.x;
    y1 := line!.y;
    x2 := line!.x+line!.w;
    y2 := line!.y+line!.h;
    ax := Maximum( x1, x2 );
    ix := Minimum( x1, x2 );
    ay := Maximum( y1, y2 );
    iy := Minimum( y1, y2 );
    if 5 < x-ax or 5 < ix-x  then
    	return false;
    elif 5 < y-ay or 5 < iy-y  then
    	return false;
    elif ax = ix or ay = iy  then
    	return true;
    else
    	return AbsInt((x-x1)*(y2-y1)
               /(x2-x1)-(y-y1)) < 5;
    fi;

end );


#############################################################################
## Implementation of Texts:


#############################################################################
##
#R  IsTextObjectRep . . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsTextObjectRep",
    IsGraphicObjectRep,
    [ "id", "x", "y", "font", "text", "color" ],
    IsGraphicObject );


#############################################################################
##
#M  Text( <sheet>, <font>, <x>, <y>, <str> ) . . . . . draw a text in a sheet
#M  Text( <sheet>, <font>, <x>, <y>, <str>, <defaults>) . . . . . . . .  dito
##
InstallMethod( Text,
    "for sheet, font, two integers, string, and record of defaults",
    true,
    [ IsGraphicSheet,
      IsFont,
      IsInt,
      IsInt,
      IsString,
      IsRecord ],
    0,

function( sheet, font, x, y, str, def )
    local   text;

    # create a text object in <sheet>
    text := GraphicObject( IsTextObjectRep, sheet, def );
    text!.x        := x;
    text!.y        := y;
    text!.font     := font;
    text!.text     := ShallowCopy(str);
    # Id's are always non-negative, so Draw knows that not yet drawn
    text!.id       := -1;   

    # draw the text and get the identifier
    Draw(text);

    # and return
    return text;

end );


InstallOtherMethod( Text,
    "using default from sheet",
    true,
    [ IsGraphicSheet,
      IsFont,
      IsInt,
      IsInt,
      IsString ],
    0,

function( sheet, font, x, y, str )
    return Text( sheet, font, x, y, str, DefaultsForGraphicObject(sheet) );
end );


#############################################################################
##
#M  Draw( <text> ) . . . . . . . . . . . . . . . . . . . . . . .  draw a text
##
InstallMethod( Draw,
    "for a text",
    true,
    [ IsGraphicObject and IsTextObjectRep and IsAlive ],
    0,

function( text )
  
    # draw the text and get the identifier
    WcSetColor( WindowId(text), ColorId(text!.color) ); 
    if text!.id >= 0 then   # Is already on screen, so destroy first!
      WcDestroy(WindowId(text), text!.id);
    fi;
    text!.id := WcDrawText( WindowId(text), Position(FONTS.fonts,text!.font), 
                        text!.x, text!.y, text!.text );

end );


#############################################################################
##
#M  Destroy( <text> )  . . . . . . . . . . . . . . . . . . . . . destroy text
##
InstallMethod( Destroy,
    "for a text",
    true,
    [ IsGraphicObject and IsTextObjectRep and IsAlive],
    0,

function( text )
    WcDestroy( WindowId(text), text!.id );
    text!.id := -1;  # no more on screen, info for Draw, in case of Revive
    ResetFilterObj( text, IsAlive );
end );


#############################################################################
##
#M  Revive( <text> )  . . . . . . . . . . . . . . . . . . . . . revive <text>
##
InstallMethod( Revive,
    "for a text",
    true,
    [ IsGraphicObject and IsTextObjectRep ],
    0,

function( text )
    if IsAlive(text) then return; fi;
    if Position(text!.sheet!.objects,text) = fail then
        Error("<text> must be in objlist of sheet");
    fi;
    SetFilterObj(text,IsAlive);
    Draw(text);
end );


#############################################################################
##
#M  Move( <text>, <x>, <y> ) . . . . . . . . . . . . . . . . .  absolute move
##
InstallMethod( Move,
    "for a text, and two integers",
    true,
    [ IsGraphicObject and IsTextObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( text, x, y )

    # make sure that we really have to move
    if x = text!.x and y = text!.y then return;  fi;

    # change the position
    text!.x := x;
    text!.y := y;

    # use 'Draw'
    Draw(text);

end );


#############################################################################
##
#M  MoveDelta( <text>, <dx>, <dy> ) . . . . . . . . . . . . . . .  delta move
##
InstallMethod( MoveDelta,
    "for a text, and two integers",
    true,
    [ IsGraphicObject and IsTextObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( text, dx, dy )

    # make sure that we really have to move
    if dx = 0 and dy = 0 then return;  fi;

    # change the dimension
    text!.x := text!.x + dx;
    text!.y := text!.y + dy;

    # use 'Draw'
    Draw(text);

end );


#############################################################################
##
#M  PSString( <text> )  . . . . . . . . . . . . . .  output Postscript-String
##
InstallMethod( PSString,
    "for a text",
    true,
    [ IsGraphicObject and IsTextObjectRep ],
    0,
function(text)
    local   save_text,  c,  a,  b;

    save_text := "";
    for c  in text!.text  do
        if c = ')' or c = '(' then
            Add( save_text, '\\' );
        fi;
        Add( save_text, c );
    od;
    a := QuoInt( FontInfo(text!.font)[1] * 150, 100 );
    b := QuoInt( FontInfo(text!.font)[3] * 168, 100 );
    return Concatenation(
	PSColour(text!.color), " setrgbcolor\n",
       "/Courier findfont [", String(b), " 0 0 ", String(a),
       " 0 0] makefont setfont\n",
       String(text!.x), " ", String(text!.sheet!.height-text!.y), " moveto\n",
       "(", save_text, ") show\n" );
end );


#############################################################################
##
#M  PrintInfo( <text> ) . . . . . . . . . . . . . . . . . print debug message
##
InstallMethod( PrintInfo,
    "for a text",
    true,
    [ IsGraphicObject and IsTextObjectRep ],
    0,

function( text )
  Print( "#I Text( ", FontName(text!.font),", ", text!.x, ", ", 
         text!.y, ", ", text!.text, " ) = ", text!.id, " @ ",
         Position(text!.sheet!.objects,text), "\n" );
        
end );


#############################################################################
##
#M  ViewObj( <text> ) . . . . . . . . . . . . . . . . pretty print a text
##
InstallMethod( ViewObj,
    "for a text",
    true,
    [ IsGraphicObject and IsTextObjectRep and IsAlive ],
    0,

function( text )
    Print( "<text>" );
end );


#############################################################################
##
#M  Recolor( <text>, <col> )  . . . . . . . . . . . . . . . . .  change color
##
InstallMethod( Recolor,
    "for a text, and a color",
    true,
    [ IsGraphicObject and IsTextObjectRep and IsAlive,
      IsColor ],
    0,

function( text, col )

    # set new color
    text!.color := col;

    # and create new one
    Draw(text);

end );


#############################################################################
##
#M  Reshape( <text>, <font> )  . . . . . . . . . . . . .  change font of text
##
InstallOtherMethod( Reshape,
    "for a text, and a font",
    true,
    [ IsGraphicObject and IsTextObjectRep and IsAlive, IsFont ],
    0,

function( text, font )

    # update text font
    text!.font := font;

    # draw a new one
    Draw(text);

end );


#############################################################################
##
#M  Relabel( <text>, <str> ) . . . . . . . . . . . . . . . change str of text
##
InstallOtherMethod( Relabel,
    "for a text, and a string",
    true,
    [ IsGraphicObject and IsTextObjectRep and IsAlive, IsString ],
    0,

function( text, str )

    # update text font
    text!.text := str;

    # draw a new one
    Draw(text);

end );


#############################################################################
##
#M  \in( <pos>, <text> ) . . . . . . . . . . . . . . . . . .  <pos> in <text>
##
InstallMethod( \in,
    "for a pair of integers, and a text",
    true,
    [ IsList and IsCyclotomicCollection,
      IsGraphicObject and IsTextObjectRep and IsAlive ],
    0,

function( pos, text )
    local   d,  x1,  x2,  y1,  y2;

    d  := FontInfo(text!.font);
    y1 := text!.y - d[1];
    y2 := text!.y + d[2];
    x1 := text!.x;
    x2 := text!.x + Length(text!.text) * d[3];
    return x1 <= pos[1] and pos[1] <= x2 and y1 <= pos[2] and pos[2] <= y2;
end );


#############################################################################
## Implementation of Vertices:


#############################################################################
##
#R  IsVertexObjectRep . . . . . . . . . . . . . . . .  default representation
##
DeclareRepresentation( "IsVertexObjectRep",
    IsGraphicObjectRep,
        [ "x", "y", "tx", "ty", "r", "outline", "shape", "highlight", 
          "color", "connections", "connectingLines" ],
    IsGraphicObject );


#############################################################################
##
#V  VERTEX  . . . . . . . . . . . . . . . . . . . . . . .  vertex information
##
BindGlobal( "VERTEX", 
        rec(circle := 1,
            diamond := 2,
            rectangle := 4,
            radius := QuoInt(5*FontInfo(FONTS.tiny)[3]
                             +20*(FontInfo(FONTS.tiny)[1]
                                  +FontInfo(FONTS.tiny)[2])+16,15),
            diameter := 2*QuoInt(5*FontInfo(FONTS.tiny)[3]
                             +20*(FontInfo(FONTS.tiny)[1]
                                  +FontInfo(FONTS.tiny)[2])+16,15)));


#############################################################################
##
#M  Vertex( <sheet>, <x>, <y> ) . . . . . . . . . .  draw a vertex in a sheet
#M  Vertex( <sheet>, <x>, <y>, <defaults>)  . . . . . . . . . . . . . .  dito
##
InstallMethod( Vertex,
    "for sheet, two integers, and record of defaults",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt,
      IsRecord ],
    0,

function( sheet, x, y, def )
    local   vertex, r, label;
    
    # compute the radius
    r := QuoInt( 5*FontInfo(FONTS.tiny)[3]+20*(FontInfo(FONTS.tiny)[1]+
                 FontInfo(FONTS.tiny)[2])+16, 15 );

    # create a vertex record in <sheet>
    vertex           := GraphicObject( IsVertexObjectRep, sheet, def );
    vertex!.x        := x;
    vertex!.y        := y;
    vertex!.r        := r;
    vertex!.ty       := QuoInt( 2*y+FontInfo(FONTS.tiny)[1]
                                   -FontInfo(FONTS.tiny)[2]+1, 2 );
    vertex!.tx       := [ x-QuoInt(10*FontInfo(FONTS.tiny)[3],20),
                          x-QuoInt(10*FontInfo(FONTS.tiny)[3],10),
                          x-QuoInt(28*FontInfo(FONTS.tiny)[3],20),
                          x-QuoInt(18*FontInfo(FONTS.tiny)[3],10) ];
    vertex!.outline  := [ Circle(sheet,x,y,r,rec(color:=vertex!.color)) ];
    if IsBound(def.shape) then
      vertex!.shape := def.shape;
    else
      vertex!.shape    := VERTEX.circle;
    fi;
    vertex!.highlight := false;

    # add list of connections
    vertex!.connections     := [];
    vertex!.connectingLines := [];
    
    # clear label first
    vertex!.label := false;
    # now set label if necessary
    if not IsBound(def.label) or def.label = false  then
      label := false;
    else
      label := def.label{[ 1 .. Minimum(4,Length(def.label)) ]};
      Relabel( vertex, label );
    fi;
    
    # Draw is NOT necessary because everything is in sub-objects
    
    # and return
    return vertex;

end );


InstallOtherMethod( Vertex,
    "for a sheet, and two integers, using default from sheet",
    true,
    [ IsGraphicSheet,
      IsInt,
      IsInt ],
    0,

function( sheet, x, y )
    return Vertex( sheet, x, y, DefaultsForGraphicObject(sheet) );
end );


#############################################################################
##
#M  Draw( <vertex> ) . . . . . . . . . . . . . . . . . . . . .  draw a vertex
##
InstallMethod( Draw,
    "for a vertex",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive ],
    0,

function( vertex )
    
    local o;
    
    for o in vertex!.outline do
        Draw(o);
    od;
    if vertex!.label <> false then
        Draw(vertex!.label);
    fi;
    
end );


#############################################################################
##
#M  Destroy( <vertex> )  . . . . . . . . . . . . . . . . . . . destroy vertex
##
InstallMethod( Destroy,
    "for a vertex",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive],
    0,

function( vertex )
    local   l;

    for l  in vertex!.connections  do
        Disconnect( vertex, l );
    od;
    for l  in vertex!.outline  do
        Delete( vertex!.sheet, l );
    od;
    if vertex!.label <> false  then
        Delete( vertex!.label!.sheet, vertex!.label );
        vertex!.label := false;
    fi;
    ResetFilterObj(vertex, IsAlive);
    # Comment: There is NO Revive for a vertex, because it is not clear
    # what should happen to the outlines!
end );


#############################################################################
##
#M  ConnectionPosition( <vertex>, <x>, <y> ) . . . . . connection to <x>, <y>
##
InstallMethod( ConnectionPosition,
    "for a vertex, and two integers",
    true,    
    [ IsGraphicObject and IsVertexObjectRep and IsAlive, IsInt, IsInt],
    0,    
        
function( vertex, x, y )
    
    # on the same line connect horizontal
    if AbsInt( vertex!.y - y ) < vertex!.r  then
        if x < vertex!.x  then
            return [ vertex!.x - vertex!.r, vertex!.y ];
        else
            return [ vertex!.x + vertex!.r, vertex!.y ];
        fi;
        
    # is it above
    elif y < vertex!.y  then
        return [ vertex!.x, vertex!.y - vertex!.r ];
        
    # otherwise it is below
    else
        return [ vertex!.x, vertex!.y + vertex!.r ];
    fi;
    
end );


#############################################################################
##
#M  Connection( <C>, <D> )  . . . . . . . . . . . . . .  connect two vertices
#M  Connection( <C>, <D>, <def> ) . . . . . . . . . . .  connect two vertices
##
InstallOtherMethod( Connection,
    "for two vertices",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive,
      IsGraphicObject and IsVertexObjectRep and IsAlive],
    0,
        
function( C, D )
    return Connection(C,D,DefaultsForGraphicObject(C!.sheet));
end );

InstallOtherMethod( Connection,
    "for two vertices, and a record",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive,
      IsGraphicObject and IsVertexObjectRep and IsAlive,
      IsRecord ],
    0,
        
function( C, D, def )
    local   L,  pos1,  pos2;
    
    # check if <C> and <D> are already connected
    if C in D!.connections  then
    	return D!.connectingLines[ Position( D!.connections, C ) ];
    fi;

    # compute position
    pos1 := ConnectionPosition( C, D!.x, D!.y );
    pos2 := ConnectionPosition( D, C!.x, C!.y );

    # create a line between <C> and <D>
    L := Line( C!.sheet, pos1[1], pos1[2], pos2[1]-pos1[1], pos2[2]-pos1[2],
               def );  

    # add line to connections of <C> and <D>
    Add( C!.connections, D );  Add( C!.connectingLines, L );
    Add( D!.connections, C );  Add( D!.connectingLines, L );

    # and return the line
    return L;

end );


#############################################################################
##
#M  Disconnect( <C>, <D> )  . . . . . . . . . . . . . disconnect two vertices
##
InstallMethod( Disconnect,
    "for two vertices",
    true,
    [ IsGraphicObject and IsVertexObjectRep,
      IsGraphicObject and IsVertexObjectRep ],
    0,
        
function( C, D )
    local   pos,  L;
    
    # <C> and <D> must be connected
    pos := Position( D!.connections, C );
    if pos = fail  then
        Error( "<C> and <D> must be connected" );
    fi;
    
    # remove connection from <C> and <D>
    L := D!.connectingLines[pos];
    D!.connections := Concatenation(
        D!.connections{[1..pos-1]},
        D!.connections{[pos+1..Length(D!.connections)]} );
    D!.connectingLines := Concatenation(
        D!.connectingLines{[1..pos-1]},
        D!.connectingLines{[pos+1..Length(D!.connectingLines)]} );
    pos := Position( C!.connections, D );
    C!.connections := Concatenation(
        C!.connections{[1..pos-1]},
        C!.connections{[pos+1..Length(C!.connections)]} );
    C!.connectingLines := Concatenation(
        C!.connectingLines{[1..pos-1]},
        C!.connectingLines{[pos+1..Length(C!.connectingLines)]} );
    
    # finally delete <L>
    Delete( L!.sheet, L );
    
end );


#############################################################################
##
#M  Highlight( <ver>, <flag> )  . . . . . . . . . . . . . .  highlight vertex
##
InstallMethod( Highlight,
    "for a vertex, and a boolean",
    true,
    [ IsGraphicObject and IsVertexObjectRep, IsBool ],    
    0,
        
function( vertex, flag )
    local   obj;
    
    vertex!.highlight := flag;
    if vertex!.highlight  then
        for obj  in vertex!.outline  do
            SetWidth( obj, 2 );
        od;
    else
        for obj  in vertex!.outline  do
            SetWidth( obj, 1 );
        od;
    fi;

end );


#############################################################################
##
#M  Highlight( <ver> )  . . . . . . . . . . . . . . . . . .  highlight vertex
##
InstallOtherMethod( Highlight,
    "for a vertex",
    true,
    [ IsGraphicObject and IsVertexObjectRep ],    
    0,
        
function( vertex )
    Highlight( vertex, true);
end );


#############################################################################
##
#M  Move( <vertex>, <x>, <y> ) . . . . . . . . . . . . . . . .  absolute move
##
InstallMethod( Move,
    "for a vertex, and two integers",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( vertex, x, y )

    local   dx,  dy,  obj,  ver2,  pos1,  pos2,  i;
    
    # compute delta move
    dx := x-vertex!.x;
    dy := y-vertex!.y;
    
    MoveDelta( vertex, dx, dy );
end );


#############################################################################
##
#M  MoveDelta( <vertex>, <dx>, <dy> ) . . . . . . . . . . . . . .  delta move
##
InstallMethod( MoveDelta,
    "for a vertex, and two integers",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive,
      IsInt,
      IsInt ],
    0,

function( vertex, dx, dy )
    local   obj,  i,  ver2,  pos1,  pos2;

    # make sure that we really have to move
    if dx = 0 and dy = 0 then return;  fi;

    vertex!.x  := vertex!.x + dx;
    vertex!.y  := vertex!.y + dy;
    vertex!.tx := vertex!.tx + dx;
    vertex!.ty := vertex!.ty + dy;
    
    # move all objects
    for obj  in vertex!.outline  do
        MoveDelta( obj, dx, dy );
    od;
    if vertex!.label <> false then
        MoveDelta( vertex!.label, dx, dy );
    fi;
    
    # move all connections
    for i  in [ 1 .. Length(vertex!.connections) ]  do
        ver2 := vertex!.connections[i];
        pos1 := ConnectionPosition( vertex, ver2!.x, ver2!.y );
        pos2 := ConnectionPosition( ver2, vertex!.x, vertex!.y );
        obj  := vertex!.connectingLines[i];
        Change( obj, pos1[1],         pos1[2],
                     pos2[1]-pos1[1], pos2[2]-pos1[2] );
    od;

end );


#############################################################################
##
#M  PSString( <vertex> )  . . . . . . . . . . . . . . . . . . . .  do nothing
##
InstallMethod( PSString,
    "for a vertex",
    true,
    [ IsGraphicObject and IsVertexObjectRep ],
    0,
function(vertex)
    return "";
end );


#############################################################################
##
#M  PrintInfo( <vertex> ) . . . . . . . . . . . . . . . . print debug message
##
InstallMethod( PrintInfo,
    "for a vertex",
    true,
    [ IsGraphicObject and IsVertexObjectRep ],
    0,

function( vertex )
    Print( "#I  Vertex( W, ", vertex!.x, ", ", vertex!.y,
           " ) = -.", Position(vertex!.sheet!.objects,vertex), "\n" );
end );


#############################################################################
##
#M  ViewObj( <vertex> ) . . . . . . . . . . . . . . . . pretty print a vertex
##
InstallMethod( ViewObj,
    "for a vertex",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive ],
    0,

function( vertex )
    if vertex!.label = false  then
        Print( "<vertex>" );
    else
        Print( "<vertex \"", vertex!.label!.text, "\">" );
    fi;
end );


#############################################################################
##
#M  Recolor( <vertex>, <col> )  . . . . . . . . . . . . . . . .  change color
##
InstallMethod( Recolor,
    "for a vertex, and a color",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive,
      IsColor ],
    0,

function( vertex, col )
    local obj;
    
    # set new color
    vertex!.color := col;
    for obj  in vertex!.outline  do
        Recolor( obj, col );
    od;
    if vertex!.label <> false  then
        Recolor( vertex!.label, col );
    fi;

end );


#############################################################################
##
#M  Reshape( <vertex>, <shape> ) . . . . . . . . . . . change shape of vertex
##
InstallOtherMethod( Reshape,
    "for a vertex, and an integer",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive, IsInt ],
    0,

function( vertex, shape )
    local   obj,  col;
    
    if vertex!.shape = shape  then return;  fi;
    vertex!.shape := shape;

    # delete old outline
    for obj  in vertex!.outline  do
        Delete( vertex!.sheet, obj );
    od;
    vertex!.outline := [];
    
    # and create new ones
    col := rec( color := vertex!.color );
    if vertex!.highlight then col.width := 2;  else col.width := 1;  fi;
    if VERTEX.rectangle <= shape  then
        shape := shape - VERTEX.rectangle;
        Add( vertex!.outline, 
             Rectangle( vertex!.sheet, vertex!.x-vertex!.r, 
                        vertex!.y-vertex!.r, 2*vertex!.r, 
                        2*vertex!.r, col ) );
    fi;
    if VERTEX.diamond <= shape  then
        shape := shape - VERTEX.diamond;
        Add( vertex!.outline, 
             Diamond( vertex!.sheet, vertex!.x-vertex!.r, vertex!.y,
                      vertex!.r, vertex!.r, col ) );
    fi;
    if VERTEX.circle <= shape  then
        shape := shape - VERTEX.circle;
        Add( vertex!.outline, 
             Circle( vertex!.sheet, vertex!.x, vertex!.y, vertex!.r, col ) );
    fi;
    
end );


#############################################################################
##
#M  Relabel( <vertex>, <str> )  . . . . . . . . attach str as label to vertex
##
InstallOtherMethod( Relabel,
    "for a vertex, and a string",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive, IsString ],
    0,

function( vertex, str )
    local col;
    
    if vertex!.label <> false then
        # there is already a label, delete it:
        Delete( vertex!.label!.sheet, vertex!.label);
    fi;
    if str = "" then
        # Label is to be removed!
        vertex!.label := false;
        return;
    fi;

    # update line dimensions
    col := rec( color := vertex!.color );
    if 4 < Length(str)  then str := str{[1..4]};  fi;
    vertex!.label := Text(vertex!.sheet,FONTS.tiny,vertex!.tx[Length(str)], 
                          vertex!.ty, str, col );
    
    # no redraw necessary because Text already drawn!

end );


#############################################################################
##
#M  \in( <pos>, <vertex> ) . . . . . . . . . . . . . . . .  <pos> in <vertex>
##
InstallMethod( \in,
    "for a pair of integers, and a vertex",
    true,
    [ IsList and IsCyclotomicCollection,
      IsGraphicObject and IsVertexObjectRep and IsAlive ],
    0,

function( pos, vertex )
    return (pos[1]-vertex!.x)^2+(pos[2]-vertex!.y)^2 < (vertex!.r+3)^2;
end );


#############################################################################
##
#M  \=( <v1>, <v2> )  . . . . . . . . . . . . . . . . .  compare two vertices
##
InstallMethod( \=,
    "for two vertices",
    true,
    [ IsGraphicObject and IsVertexObjectRep and IsAlive,
      IsGraphicObject and IsVertexObjectRep and IsAlive ],
    0,
        
function( v1, v2 )
    return v1!.outline = v2!.outline;
end );


#############################################################################
##

#E  gobject.gi	. . . . . . . . . . . . . . . . . . . . . . . . . . ends here

