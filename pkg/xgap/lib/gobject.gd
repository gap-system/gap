############################################################################
##
#W  gobject.gd                 	XGAP library                     Frank Celler
##
#H  @(#)$Id: gobject.gd,v 1.11 2002/04/23 10:45:18 gap Exp $
##
#Y  Copyright 1995-1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  Copyright 1997,       Frank Celler,                 Huerth,       Germany
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
Revision.pkg_xgap_lib_gobject_gd :=
    "@(#)$Id: gobject.gd,v 1.11 2002/04/23 10:45:18 gap Exp $";

#############################################################################
#1
##  All graphics within graphic sheets are so called graphic objects. They 
##  are {\GAP} objects in the category `IsGraphicObject'. These objects are
##  linked internally to the actual graphics within the window. You can 
##  modify these objects via certain operations which leads to the
##  corresponding change of the real graphics on the screen. The types of
##  graphic objects supported in {\XGAP} are: boxes, circles, discs, diamonds,
##  rectangles, lines, texts, vertices and connections. Vertices are compound
##  objects consisting of a circle, rectangle oder diamond with a short text
##  inside. They remember their connections to other vertices. That means
##  that if for example the position of a vertex is changed, the line which 
##  makes the connection to some other vertex is also changed automatically.
##  For every graphic object there is a constructor which has the same name 
##  as the graphic object (e.g. `Box' is the constructor for boxes).
##  


#############################################################################
##
#C  IsGraphicObject( <gobj> ) . . . . . . . . . . category of graphic objects
##
##  This is the category in which all graphic objects are.
##
DeclareCategory( "IsGraphicObject", IsObject );


#############################################################################
##
#V  GraphicObjectFamily
##
BindGlobal( "GraphicObjectFamily",
    NewFamily( "GraphicObjectFamily", IsGraphicObject ) );


#############################################################################
##
#O  GraphicObject( <catrep>, <sheet>, <defaults> )  . . .  new graphic object
##
DeclareOperation( "GraphicObject", [ IsObject, IsGraphicSheet, IsRecord ] );


#############################################################################
##
#O  Delete( <sheet>, <object> ) . . .  delete a graphic object from its sheet
#O  Delete( <object> )  . . . . . . .  delete a graphic object from its sheet
##
##  Deletes a graphic object. Calls `Destroy' first, so the graphic object
##  is no more <alive> afterwards. The object is deleted from the list of
##  objects in its graphic sheet. There is no way to reactivate such an
##  object afterwards.
##
DeclareOperation( "Delete", [ IsGraphicSheet, IsGraphicObject ] );


#############################################################################
##
#O  Destroy( <object> ) . . . . . . . . . . . . . .  destroy a graphic object
##
##  Destroys a graphic object. It disappears from the screen and will not be 
##  <alive> any more after this call.
##  Note that <object> is *not* deleted from the list of objects in its
##  graphic sheet <sheet>.  
##  This makes it possible to `Revive' it again.
##  In order to delete <object> from <sheet>,
##  use `Delete( <sheet>, <obj> )', which calls `Destroy' for <obj>.
##
DeclareOperation( "Destroy", [ IsGraphicObject ] );


#############################################################################
##
#O  Revive( <object> ) . . . . . . . . . . . . . revive a dead graphic object
##
##  Note that <object> must be in the list of objects in its graphic sheet!
##  So this is only possible for `Destroyed', not
##  for `Deleted' graphic objects.
##
DeclareOperation( "Revive", [ IsGraphicObject ] );


#############################################################################
##
#O  Draw( <object> )  . . . . . . . . . . . . . . . (re)draw a graphic object
##
##  This operation (re-)draws a graphic object on the screen. You normally
##  do not need to call this yourself. But in some rare cases of object
##  overlaps you could find it useful.
##
DeclareOperation( "Draw", [ IsGraphicObject ] );


#############################################################################
##
#O  Move( <object>, <x>, <y> )  . . . . . . . . . . . . . . . . absolute move
##
##  Changes the position of a graphic object absolutely. It must be <alive>
##  and will be moved at once on the screen.
##
DeclareOperation( "Move", [ IsGraphicObject, IsInt, IsInt ] );


#############################################################################
##
#O  MoveDelta( <object>, <dx>, <dy> ) . . . . . . . . . . . . . .  delta move
##
##  Changes the position of a graphic object relatively. It must be <alive>
##  and will be moved at once on the screen.
##
DeclareOperation( "MoveDelta", [ IsGraphicObject, IsInt, IsInt ] );


#############################################################################
##
#O  PrintInfo( <object> ) . . . . . . . . . . . . . . . . .  print debug info
##
##  This operation prints debugging info about a graphic object.
##
DeclareOperation( "PrintInfo", [ IsGraphicObject ] );
#T regard this as a special case of `Display'?


#############################################################################
##
#O  PSString( <object> )  . . . . . . . . . . . . . . . . . PostScript string
##
##  Creates a postscript string which describes the graphic object. Normally
##  you do not need to call this because it is only used internally if the
##  user exports the whole graphic sheet to encapsulated postscript.
##
DeclareOperation( "PSString", [ IsGraphicObject ] );


#############################################################################
##
#O  Recolor( <object>, <col> )  . . . . . . . . . . . . . . . .  change color
##
##  Changes the color of a graphic object. See "Color Models" for how 
##  to select a <color>. 
##
DeclareOperation( "Recolor", [ IsGraphicObject, IsColor ] );

DeclareSynonym( "Recolour", Recolor );


#############################################################################
##
#O  Reshape( <object>, ... )  . . . . . . . . . . . . . . . reshape an object
##
##  Changes the shape of a graphic object. The parameters depend on the type
##  of the object. See the descriptions of the constructors for the actual
##  usage.
##
DeclareOperation( "Reshape", [ IsGraphicObject, IsObject ] );


#############################################################################
##
#O  Change( <object>, ... ) . . . . . . . . . . . . . . . .  change an object
##
##  Changes the shape of a graphic object. The parameters depend on the type
##  of the object. See the descriptions of the constructors for the actual
##  usage.
##
DeclareOperation( "Change", [ IsGraphicObject, IsObject ] );


#############################################################################
##
#O  Relabel( <object>, <str> )  . . . . . . . . . . . . . . relabel an object
##
##  Changes the label of a graphic object. The second argument must always
##  be a string.
##
DeclareOperation( "Relabel", [ IsObject, IsString ] );


#############################################################################
##
#O  LabelPosition( <object>, ... )  . . . . . . . . .  calculate a label pos.
##
DeclareOperation( "LabelPosition", [ IsGraphicObject ] );


#############################################################################
##
#O  SetWidth( <object>, <w> )  . . . . . . . . . . . . . .  change line width
##
##  Changes the line width of the graphic object. The line width <w> must be
##  a relatively small integer.
##
DeclareOperation( "SetWidth", [ IsGraphicObject, IsObject ] );


#############################################################################
##
#O  Box( <sheet>, <x>, <y>, <w>, <h> )  . . . . . . . . draw a box in a sheet
#O  Box( <sheet>, <x>, <y>, <w>, <h>, <defaults> )  . . draw a box in a sheet
##
##  creates a new graphic object,  namely a filled black  box, in the graphic
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
##  See "operations for graphic objects" for a list of operations
##  that apply to boxes.
##
##  Note that `Reshape' for boxes takes three parameters, namely the box
##  object, the new width, and the new height of the box.
##
DeclareOperation( "Box",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Circle( <sheet>, <x>, <y>, <r> )  . . . . . . .  draw a circle in a sheet
#O  Circle( <sheet>, <x>, <y>, <r>, <defaults> )  .  draw a circle in a sheet
##
##  creates a new graphic object, namely a black circle, in the graphic sheet
##  <sheet> and returns a {\GAP} record describing this object. The center
##  of the circle is $(<x>,<y>)$ and the radius is $<r>$.
##
##  If a record <defaults> is given and contains a component `color' of value
##  <color>, the  function works like the first version  of  `Circle', except 
##  that the color of the circle will be <color>.  See "Color Models" for how 
##  to select a <color>. If the record contains a component `width' of value
##  <width>, the line width of the circle is set accordingly.
##
##  See "operations for graphic objects" for a list of operations
##  that apply to circles.
##
##  Note that `Reshape' for circles takes two parameters, namely the circle
##  object, and the new radius of the circle.
##
DeclareOperation( "Circle",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Disc( <sheet>, <x>, <y>, <r> )  . . . . . . . . .  draw a disc in a sheet
#O  Disc( <sheet>, <x>, <y>, <r>, <defaults> )  . . .  draw a disc in a sheet
##
##  creates a new graphic object, namely a disc (a black filled circle), 
##  in the graphic sheet
##  <sheet> and returns a {\GAP} record describing this object. The center
##  of the disc is $(<x>,<y>)$ and the radius is $<r>$.
##
##  If a record <defaults> is given and contains a component `color' of value
##  <color>, the  function works like the first version  of  `Disc', except 
##  that the color of the disc will be <color>.  See "Color Models" for how 
##  to select a <color>. 
##
##  See "operations for graphic objects" for a list of operations
##  that apply to discs.
##
##  Note that `Reshape' for discs takes two parameters, namely the disc
##  object, and the new radius.
##
DeclareOperation( "Disc",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Diamond( <sheet>, <x>, <y>, <w>, <h> )  . . . . draw a diamond in a sheet
#O  Diamond( <sheet>, <x>, <y>, <w>, <h>, <defaults> )
##
##  creates a new graphic object, namely a black diamond, in the graphic sheet
##  <sheet> and returns a {\GAP} record describing this object. The left
##  corner of the diamond is $(<x>,<y>)$, the others are $(<x>+<w>,<y>-<h>)$,
##  $(<x>+<w>,<y>+<h>)$, and $(<x>+2<w>,<y>)$.
##
##  If a record <defaults> is given and contains a component `color' of value
##  <color>, the  function works like the first version  of  `Diamond', except 
##  that the color of the diamond will be <color>.  See "Color Models" for how 
##  to select a <color>. If the record contains a component `width' with 
##  integer value <width>, the line width is set accordingly.
##
##  See "operations for graphic objects" for a list of operations
##  that apply to diamonds.
##
##  Note that `Reshape' for diamonds takes three parameters, namely the diamond
##  object, and the new <width> and <height> values.
##
DeclareOperation( "Diamond",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Rectangle( <sheet>, <x>, <y>, <w>, <h> )  . . draw a Rectangle in a sheet
#O  Rectangle( <sheet>, <x>, <y>, <w>, <h>, <defaults> )
##
##  creates a new graphic object,  namely a black  rectangle, in the graphic
##  sheet <sheet> and  returns a {\GAP} record describing  this  object.  The
##  four   corners     of  the    box    are   $(<x>,<y>)$,  $(<x>+<w>,<y>)$,
##  $(<x>+<w>,<y>+<h>)$, and $(<x>,<y>+<h>)$.
##
##  Note that the rectangle is $<w>+1$ pixel wide and $<h>+1$ pixels high.
##
##  If a record <defaults> is given and contains a component `color' of value
##  <color>, the  function works like the first version  of  `Rectangle', 
##  except 
##  that the color of the rectangle will be <color>.  See "Color Models" for 
##  how 
##  to select a <color>. If the record contains a component `width' with 
##  integer value <width>, the line width is set accordingly.
##
##  See "operations for graphic objects" for a list of operations
##  that apply to rectangles.
##
##  Note that `Reshape' for rectangles takes three parameters, namely the 
##  rectangle object, and the new <width> and <height> values.
##
DeclareOperation( "Rectangle",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Line( <sheet>, <x>, <y>, <w>, <h> ) . . . . . . .  draw a line in a sheet
#O  Line( <sheet>, <x>, <y>, <w>, <h>, <defaults> ) .  draw a line in a sheet
##
##  creates a new graphic object,  namely a black  line, in the graphic
##  sheet <sheet> and  returns a {\GAP} record describing  this  object.  The
##  line has the end points $(<x>,<y>)$ and $(<x>+<w>,<y>+<h>)$.
##
##  If a record <defaults> is given and contains a component `color' of value
##  <color>, the  function works like the first version  of  `Line', except 
##  that the color of the line will be <color>.  See "Color Models" for how 
##  to select a <color>. If the record contains a component `width' with 
##  integer value <width>, the line width is set accordingly. If the record
##  contains a component `label' with a string value <label>, a text object
##  is attached as a label to the line.
##
##  See "operations for graphic objects" for a list of operations
##  that apply to lines.
##
##  Note that `Reshape' for lines takes three parameters, namely the 
##  line object, and the new <w> and <h> value. `Change' for
##  lines in contrast takes five parameters, namely the line object and all 
##  four coordinates like in the original call.
##
DeclareOperation( "Line",
    [ IsGraphicSheet, IsInt, IsInt, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  Text( <sheet>, <font>, <x>, <y>, <str> )  . . . . write a text in a sheet
#O  Text( <sheet>, <font>, <x>, <y>, <str>, <defaults> )
##
##  creates a new graphic object, namely the string <str> as a black text,
##  in the graphic sheet <sheet> and returns a {\GAP} record describing
##  this object.  The text has the baseline of the first character at
##  $(x,y)$.
##
##  If a record <defaults> is given and contains a component `color' of value
##  <color>, the  function works like the first version  of  `Text', except 
##  that the color of the text will be <color>.  See "Color Models" for how 
##  to select a <color>. 
##
##  See "operations for graphic objects" for a list of operations
##  that apply to texts.
##
##  Note that `Reshape' for texts takes two parameters, namely the 
##  text object, and the new font. Use `Relabel' to change the string of the
##  text.
##
DeclareOperation( "Text",
    [ IsGraphicSheet, IsFont, IsInt, IsInt, IsString, IsRecord ] );


#############################################################################
##
#O  Vertex( <sheet>, <x>, <y> ) . . . . . . . . . . . . . . . . draw a vertex
#O  Vertex( <sheet>, <x>, <y>, <defaults> ) . . . . . . . . . . draw a vertex
##
##  creates a new graphic object,  namely a black  vertex, in the graphic
##  sheet <sheet> and  returns a {\GAP} record describing  this  object.  The
##  center has the position $(x,y)$.
##
##  A vertex consists of a circle of a certain standard size, and a short 
##  string inside it (up to 4 letters).
##
##  If a record <defaults> is given and contains a component `label' with a
##  string value <label> this is used for the label. In addition this record
##  is forwarded to the constructors of the circle and the label, such that
##  defaults for those subobjects like color can be controlled.
##
##  Note that the highlighting status of a vertex normally changes the line
##  width and the color of a vertex!
##
##  See "operations for graphic objects" for a list of operations
##  that apply to vertices.
##
##  Note that `Reshape' for vertices takes two parameters, namely the 
##  vertex object, and the new shape as an integer. Use the globally defined
##  record `VERTEX' (see "VERTEXREC") to access the integers for the shapes.
##  Use `Relabel' to change the label of the vertex.
##
DeclareOperation( "Vertex",
    [ IsGraphicSheet, IsInt, IsInt, IsRecord ] );


#############################################################################
##
#O  ConnectionPosition( <vertex>, <x>, <y> ) . calculate pos. of a connection
##
DeclareOperation( "ConnectionPosition", 
        [ IsGraphicObject, IsInt, IsInt ] );


#############################################################################
##
#O  Connection( <vertex>, <vertex>) . . . . . . . . . .  connect two vertices
#O  Connection( <vertex>, <vertex>, <defaults>) . . . .  connect two vertices
##
##  Connects two vertices with a line.
##  The second variation can get a <defaults> record for the actual line. The
##  same entries as in the <defaults> record for lines are allowed.
##
DeclareOperation( "Connection", 
        [ IsGraphicObject,
          IsGraphicObject ] );


#############################################################################
##
#O  Disconnect( <vertex>, <vertex>) .  delete connection between two vertices
##
##  Deletes connection between two vertices.
##
DeclareOperation( "Disconnect", 
        [ IsGraphicObject,
          IsGraphicObject ] );


#############################################################################
##
#O  Highlight( <vertex> ) . . . . . . .  switch highlighting status of vertex
#O  Highlight( <vertex>, <flag> ) . . .  switch highlighting status of vertex
##
##  In the first form this operation switches the highlighting status of a
##  vertex to ON. In the second form the <flag> decides about ON or OFF.
##  Highlighting normally means a thicker line width and a change in color.
##
DeclareOperation( "Highlight", 
        [ IsGraphicObject, IsBool ] );


#############################################################################
##

#E  gobject.gd  . . . . . . . . . . . . . . . . . . . . . . . . . . ends here

