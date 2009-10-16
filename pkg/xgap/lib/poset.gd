#############################################################################
##
#W  poset.gd                  	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: poset.gd,v 1.14 1999/11/25 18:06:57 gap Exp $
##
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains declarations for graphs and posets
##
Revision.pkg_xgap_lib_poset_gd :=
    "@(#)$Id: poset.gd,v 1.14 1999/11/25 18:06:57 gap Exp $";


#############################################################################
##
##  Constructors:
##
#############################################################################

#############################################################################
##
#O  GraphicGraph( <name>, <width>, <height> ) . . . . . . . new graphic graph
##
##  creates a new graphic graph which is a graphic sheet representation
##  with knowledge about vertices and edges and infrastructure for user
##  interfaces.
##
DeclareOperation("GraphicGraph",[IsString, IsInt, IsInt]);


#############################################################################
##
#O  GraphicPoset(<name>, <width>, <height>) . . . . . . creates graphic poset
##
##  creates a new graphic poset which is a specialization of a graphic graph
##  mainly because per definition a poset comes in ``levels'' or ``layers''. 
##  This leads to some algorithms that are more efficient than the general 
##  ones for graphs.
##
DeclareOperation("GraphicPoset",[IsString, IsInt, IsInt]);


#############################################################################
##
#O  CreateLevel(<poset>, <levelparam>) . . . . . . creates new level in poset
#O  CreateLevel(<poset>, <levelparam>, <lptext>) . creates new level in poset
##
##  A level in a graphic poset can be thought of as a horizontal slice of
##  the poset. It has a y coordinate of the top of the level relatively to
##  the graphic sheet and a height. Every class of vertices in a graphic
##  poset is in a level. The levels are totally ordered by their y
##  coordinate. No two vertices which are included in each other are in the
##  same level. A vertex containing another one is always ``higher'' on the
##  screen, meaning in a ``higher'' level.  Every level has a unique level
##  parameter, which can be any {\GAP} object. The user is responsible for all
##  methods where a level parameter occurs as parameter and is not just an
##  integer. There is NO {\GAP} object representing a level which is visible
##  for the user of posets. All communication about levels goes via the
##  level parameter. `CreateLevel' creates a new level with level parameter
##  <levelparam> in the graphic poset <poset>. It returns `fail' if there
##  is already a level with a level parameter which is considered ``equal''
##  to <levelparam> by `CompareLevels' or <levelparam> if everything went
##  well.
##
##  The second method allows to specify which text appears for the level at
##  the right edge of the sheet.
##
DeclareOperation("CreateLevel",[IsGraphicSheet,IsObject]);
DeclareOperation("CreateLevel",[IsGraphicSheet,IsObject,IsString]);


#############################################################################
##
#O  CreateClass(<poset>,<levelparam>,<classparam>) . . . .  creates new class
##
##  A class in a graphic poset is a collection of vertices within a level
##  which belong together in some sense.  Every vertex in a graphic poset
##  is in a class, which in turn belongs to a level. Every class in a level
##  has a unique class parameter, which can be any {\GAP} object. The user is
##  responsible for all methods where a class parameter occurs as parameter
##  and is not just an integer. There is NO {\GAP} object representing a class
##  which is visible to the user of posets. All communication about classes
##  goes via the class parameter.  `CreateClass' creates a new class in the
##  level with level parameter <levelparam> in the graphic poset
##  <poset>. It returns `fail' if there is no level with level parameter
##  <levelparam> or there is already a class in this level with class
##  parameter <classparam>. `CreateClass' returns <classparam> otherwise.
##
DeclareOperation("CreateClass",[IsGraphicSheet, IsObject, IsObject]);


#############################################################################
##
#O  Vertex(<graph>,<data>[,<inf>]) . . . . . . . . . . . . creates new vertex
##
##  Creates a new vertex. <inf> is a record in which additional info can be
##  supplied for the new vertex. For general graphic graphs only the
##  `label', `color', `shape', `x' and `y' components are applicable, they
##  contain a short label which will be attached to the vertex, the color,
##  the shape (`circle', `diamond', or `rectangle') and the coordinates
##  relative to the graphic sheet respectively. For graphic posets also the 
##  components `levelparam' and `classparam' are evaluated. If the component
##  `hints' is bound in <inf> it must be a list of x coordinates which will be
##  delivered to `ChoosePosition' to help placement. Those x coordinates will
##  be the coordinates of other vertices related to the new one. All values of
##  record components which are not specified will be determined by calling 
##  some methods for graphic graphs or posets. Those are:
##    `ChooseLabel' for the label,
##    `ChooseColor' for the color,
##    `ChooseShape' for the shape,
##    `ChoosePosition' for the position,
##    `ChooseLevel' for the level parameter, 
##    `ChooseClass' for the class parameter, and
##    `ChooseWidth' for the line width of the vertex.
##  `Vertex' returns `fail' if no vertex was created. This happens only, if
##  one of the choose functions return `fail' or no possible value, for
##  example a non-existing level or class parameter. `Vertex' returns a
##  vertex object if everything went well.
##
DeclareOperation("Vertex",[IsGraphicSheet, IsObject, IsRecord]);


#############################################################################
##
#O  Edge(<graph>,<vertex1>,<vertex2>) . . . . . . . . . . . . adds a new edge
#O  Edge(<graph>,<vertex1>,<vertex2>,<defaults>) . adds a new edge, with defs
##
##  Adds a new edge from <vertex1> to <vertex2>. For posets this puts one
##  of the vertices into the other as a maximal subvertex. So either
##  <vertex1> must lie in a ``higher'' level than <vertex2> or the other way
##  round. There must be no vertex ``between'' <vertex1> and <vertex2>. If
##  the two vertices are in the same level or one is already indirectly
##  included in the other `fail' is returned, otherwise `true'. That means,
##  that in the case where one of the two vertices is already a maximal
##  subobject of the other, then the method does nothing and returns `true'.
##  The variation with a <defaults> record just hands this over to the lower
##  levels, meaning that the line width and color are modified.
##
DeclareOperation("Edge",[IsGraphicSheet,IsGraphicObject,IsGraphicObject]);


#############################################################################
##
##  Destructors:
##
#############################################################################


#############################################################################
##
#O  Delete(<graph>,<obj>) . . . . . . . . . . . . . remove something in graph
##
##  This operation already exists in {\XGAP} for the graphic objects!
##  Applicable for edges, vertices, classes.
##
DeclareOperation("Delete",[IsGraphicSheet,IsObject]);


#############################################################################
##
#O  DeleteLevel(<poset>,<levelparam>) . . . . . . . . . remove level in poset
##
##  The following method applies to a level. It returns `fail' if no level
##  with level parameter <levelparam> is in the poset. Otherwise the level
##  is deleted and all classes within it are also deleted! `DeleteLevel'
##  returns `true' if the level is successfully deleted.
##
DeclareOperation("DeleteLevel",[IsGraphicSheet,IsObject]);


#############################################################################
##
##  Operations for modifications:
##
#############################################################################


#############################################################################
##
#O  ResizeLevel(<poset>,<levelparam>,<height>)  . . .  change height of level
##
##  Changes the height of a level. The y coordinate can only be changed by
##  permuting levels, see below.
##  Attention: This can increase the size of the sheet!
##  Returns `fail' if no level with level parameter <levelparam> exists and
##  `true' otherwise. 
##
DeclareOperation("ResizeLevel",[IsGraphicSheet,IsObject,IsInt]);


#############################################################################
##
#O  MoveLevel(<poset>,<levelparam>,<position>) move level to another position
##
##  Moves a level to another position. <position> is an absolute index in
##  the list of levels. The level with level parameter <levelparam> will be
##  at the position <position> after the operation. This is only allowed if
##  the new ordering is compatible with the partial order given by
##  `CompareLevels' and if there is no connection of a vertex in the moving
##  level with another level with which it is interchanged.  So
##  <levelparam> is compared with all level parameters between the old and
##  the new position. If there is a contradiction, nothing happens and the
##  method returns `fail'. If everything works the operation returns
##  `true'.
##
DeclareOperation("MoveLevel",[IsGraphicSheet,IsObject,IsInt]);


#############################################################################
##
#O  Relabel(<graph>,<vertex>,<label>)  . . . . . . . . change label of vertex
#O  Relabel(<graph>,<vertex>)  . . . . . . . . . . . . change label of vertex
#O  Relabel(<poset>,<vertex1>,<vertex2>,<label>) . . . . change label of edge
#O  Relabel(<poset>,<vertex1>,<vertex2>) . . . . . . . . change label of edge
##
##  Changes the label of the vertex <vertex> or the edge between <vertex1>
##  and <vertex2>. This must be a short string. In the method where no
##  label is specified the new label is chosen functionally: the operation
##  `ChooseLabel' is called. Returns `fail' if an error occurs and `true'
##  otherwise.  This operation already exists in {\XGAP} for graphic
##  objects.
##
DeclareOperation("Relabel",[IsGraphicSheet,IsGraphicObject,IsString]);


#############################################################################
##
#O  Move(<graph>,<vertex>,<x>,<y>) . . . . . . . . . . . . . . .  move vertex
#O  Move(<graph>,<vertex>) . . . . . . . . . . . . . . . . . . .  move vertex
##
##  Moves vertex <vertex>. For posets coordinates are relative to the level
##  of the vertex. <vertex> must be a vertex object in <graph>. If no
##  coordinates are specified the operation `ChoosePosition' is
##  called. `Move' returns `fail' if an error occurs and `true' otherwise.
##  This operation already exists in {\XGAP} for graphic objects.
##
DeclareOperation("Move",[IsGraphicSheet,IsGraphicObject,IsInt,IsInt]);


#############################################################################
##
#O  Reshape(<graph>,<vertex>)  . . . . . . . . . . . . change shape of vertex
#O  Reshape(<graph>,<vertex>,<shape>)  . . . . . . . . change shape of vertex
##
##  Changes the shape of the vertex <vertex>. <vertex> must be a vertex
##  object in the graph or poset <graph>. For the method where no shape is
##  specified the new shape is chosen functionally: `ChooseShape' is called
##  for the corresponding data.  `Reshape' returns `fail' if an error
##  occurs and `true' otherwise.  This operation already exists in {\XGAP}
##  for graphic objects.
##
DeclareOperation("Reshape",[IsGraphicSheet,IsGraphicObject,IsString]);


#############################################################################
##
#O  Recolor(<graph>,<vertex>)  . . . . . . . . . . . . change color of vertex
#O  Recolor(<graph>,<vertex>,<color>)  . . . . . . . . change color of vertex
#O  Recolor(<poset>,<vertex1>,<vertex2>,<color>) . .  change color of an edge
#O  Recolor(<poset>,<vertex1>,<vertex2>) . . . . . .  change color of an edge
##
##  Changes the color of the vertex <vertex> or the edge between <vertex1>
##  and <vertex2>. <vertex> must be a vertex object in <graph>. For the
##  method where no color is specified the new color is chosen
##  functionally: `ChooseColor' is called for the corresponding
##  data. `Recolor' returns `fail' if an error occurs and `true'
##  otherwise. This operation already exists in {\XGAP} for graphic objects.
##
DeclareOperation("Recolor",[IsGraphicSheet,IsGraphicObject,IsColor]);


#############################################################################
##
#O  SetWidth(<graph>,<vertex1>,<vertex2>,<width>) . change line width of edge
#O  SetWidth(<graph>,<vertex1>,<vertex2>) . . . . . change line width of edge
##
##  Changes the line width of an edge. <vertex1> and <vertex2> must be
##  vertices in the graph <graph>. For the method where no line width is
##  specified the width is chosen functionally: `ChooseWidth' is called for
##  the corresponding data pair. Returns `fail' if an error occurs and
##  `true' otherwise. This operation already exists in {\XGAP} for graphic
##  objects.
##
DeclareOperation("SetWidth",[IsGraphicSheet,IsGraphicObject,
        IsGraphicObject,IsInt]);
DeclareOperation("SetWidth",[IsGraphicSheet,IsGraphicObject,
        IsGraphicObject]);


#############################################################################
##
#O  Highlight(<graph>,<vertex>)  . . . . . . .  change highlighting of vertex
#O  Highlight(<graph>,<vertex>,<flag>) . . . .  change highlighting of vertex
##
##  Changes the highlighting status of the vertex <vertex>. <vertex> must
##  be a vertex object in <graph>. For the method where no flag is
##  specified the new status is chosen functionally: `ChooseHighlight' is
##  called for the corresponding data. Returns `fail' if an error occurs
##  and `true' otherwise. This operation already exists in {\XGAP} for
##  graphic objects.
##
DeclareOperation("Highlight",[IsGraphicSheet,IsGraphicObject,IsBool]);
DeclareOperation("Highlight",[IsGraphicSheet,IsGraphicObject]);


#############################################################################
##
#O  Select(<graph>,<vertex>,<flag>) . . . . . . . . . . (de-)selects a vertex
#O  Select(<graph>,<vertex>)  . . . . . . . . . . . . . . .  selects a vertex
##
##  Changes the selection state of the vertex <vertex>. <vertex> must be a
##  vertex object in <graph>. The flag determines whether the vertex
##  should be selected or deselected. This operation already exists in
##  {\XGAP} for graphic objects.  The method without flags assumes `true'.
##
DeclareOperation( "Select",[IsGraphicSheet,IsGraphicObject,IsBool]);


#############################################################################
##
#O  DeselectAll(<graph>) . . . . . . . . . . . . . . . deselects all vertices
##
##  Deselects all vertices in the graph or poset <graph>.
##
DeclareOperation( "DeselectAll",[IsGraphicSheet] );


#############################################################################
##
#O  Selected(<graph>) . . . . . . . . .  returns set of all selected vertices
##
##  Returns a (shallow-)copy of the set of all selected vertices.
##
DeclareOperation( "Selected",[IsGraphicSheet] );


#############################################################################
##
##  Operations for decisions with respect to data:
##
##  Those are normally supplied by the user via installing new methods.
##
#############################################################################


#############################################################################
##
#O  ChooseLabel(<graph>,<data>) . . . . . .  is called during vertex creation
#O  ChooseLabel(<graph>,<data>,<data>)  . . .  is called during edge creation
##
##  This operation is called during vertex or edge creation, if the caller
##  didn't specify a label for the vertex or edge. It has to return a short
##  string which will be attached to the vertex. If it returns `fail' the
##  new vertex is not generated! The generic method just returns the empty
##  string, so no label is generated.  This method is also called in the
##  `Relabel' method without label parameter.
##
DeclareOperation("ChooseLabel",[IsGraphicSheet,IsObject]);


#############################################################################
##
#O  ChooseLevel(<poset>,<data>)  . . . . . . is called during vertex creation
##
##  This operation is called during vertex creation, if the caller didn't
##  specify a level to which the vertex belongs. It has to return a level
##  parameter which exists in the poset. If it returns `fail' the new
##  vertex is not generated!
##
DeclareOperation("ChooseLevel",[IsGraphicSheet,IsObject]);


#############################################################################
##
#O  ChooseClass(<poset>,<data>,<levelparam>) .  called during vertex creation
##
##  This operation is called during vertex creation, if the caller didn't
##  specify a class to which the vertex belongs. It has to return a
##  class parameter which exists in the poset in the level with parameter
##  <levelparam>. If it returns `fail' the new vertex is not generated!
##
DeclareOperation("ChooseClass",[IsGraphicSheet,IsObject,IsObject]);


#############################################################################
##
#O  ChooseColor(<graph>,<data>) . . . . . .  is called during vertex creation
#O  ChooseColor(<graph>,<data1>,<data2>). . .  is called during edge creation
##
##  This operation is called during vertex or edge creation. It has to return a
##  color. If it returns `fail' the new vertex is not generated!
##  It is also called in the `Recolor' method without color parameter.
##
DeclareOperation("ChooseColor",[IsGraphicSheet,IsObject]);


#############################################################################
##
#O  ChooseHighlight(<graph>,<data>) . . . . . is called during vertex creation
##
##  This operation is called during vertex creation. It has to return a
##  flag which indicates, whether the vertex is highlighted or not. If it 
##  returns `fail' the new vertex is not generated!
##  It is also called in the `Highlight' method without flag parameter.
##
DeclareOperation("ChooseHighlight",[IsGraphicSheet,IsObject]);


#############################################################################
##
#O  ChoosePosition(<poset>,<data>,<levelparam>,<classparam>,<hints>)  . . . . 
#O  ChoosePosition(<graph>,<data>)  . . . .  is called during vertex creation
##                                            
##  This operation is called during vertex creation.  It has to return a
##  list with two integers: the coordinates. For posets those are relative
##  to the level the vertex resides in.  If it returns `fail' the new
##  vertex is not generated! The parameters <levelparam> and <classparam>
##  are level and class parameters respectively.
##
DeclareOperation("ChoosePosition",[IsGraphicSheet,IsObject]);
DeclareOperation("ChoosePosition",[IsGraphicSheet,IsObject,
                                   IsObject,IsObject,IsList]);


#############################################################################
##
#O  ChooseShape(<graph>,<data>) . . . . . . . is called during vertex creation
##
##  This operation is called during vertex creation.
##  It has to return a string out of the following list:
##  `circle', `diamond', `rectangle'.
##  If it returns `fail' the new vertex is not generated!
##
DeclareOperation("ChooseShape",[IsGraphicSheet,IsObject]);


#############################################################################
##
#O  ChooseWidth(<graph>,<data>) . . . . . . . is called during vertex creation
#O  ChooseWidth(<graph>,<data1>,<data2>)  . . . is called during edge creation
##
##  This operation is called during vertex or edge creation.
##  It has to return a line width.
##  If it returns `fail' the new vertex or edge is not generated!
##  This is also called by the `SetWidth' operation without width parameter.
##
DeclareOperation("ChooseWidth",[IsGraphicSheet,IsObject]);


#############################################################################
##
#O  CompareLevels(<poset>,<levelparam1>,<levelparam2>)  . . . . . . . . . . .
##  . . . . . . . . . . . . . . . . . . . . . . . .  compares two levelparams
##
##  Compare two level parameters. -1 means that the level with parameter
##  <levelparam1> is ``higher'', 1 means that the one with parameter
##  <levelparam2> is ``higher'', 0 means that they are equal. `fail' means
##  that they are not comparable.
##
DeclareOperation("CompareLevels",[IsGraphicSheet,IsObject,IsObject]);


#############################################################################
##
##  Operations for aquiring information about the poset:
##
#############################################################################


#############################################################################
##
#O  WhichLevel(<poset>,<y>) . . . . . .  determine level in which position is
##
##  Determines the level in which position <y> is. `WhichLevel' returns the
##  level parameter or `fail'.
##
DeclareOperation("WhichLevel",[IsGraphicSheet,IsInt]);


#############################################################################
##
#O  WhichClass(<poset>,<x>,<y>) . . . .  determine class in which position is
##
##  Determines a class with a vertex which contains the position
##  $(<x>,<y>)$. The first class found is taken.  `WhichClass' returns a
##  list with the level parameter as first and the class parameter as
##  second element.  `WhichClass' returns `fail' if no such class is found.
##
DeclareOperation("WhichClass",[IsGraphicSheet,IsInt,IsInt]);


#############################################################################
##
#O  WhichVertex(<graph>,<x>,<y>) . . .  determine vertex in which position is
#O  WhichVertex(<graph>,<data>)  . . . . .  determine vertex with data <data>
#O  WhichVertex(<graph>,<data>,<func>)   . . .  determine vertex functionally
##
##  Determines a vertex which contains the position $(<x>,<y>)$.
##  `WhichVertex' returns a vertex.  In the third form the function <func>
##  must take two parameters <data> and the data entry of a vertex in
##  question. It must return `true' or `false', according to the right
##  vertex being found or not.  The function can for example consider just
##  one record component of data records.  `WhichVertex' returns `fail' in
##  case no vertex is found.
##
DeclareOperation("WhichVertex",[IsGraphicSheet,IsInt,IsInt]);
DeclareOperation("WhichVertex",[IsGraphicSheet,IsObject]);
DeclareOperation("WhichVertex",[IsGraphicSheet,IsObject,IsFunction]);


#############################################################################
##
#O  WhichVertices(<graph>,<x>,<y>) .  determine vertices in which position is
#O  WhichVertices(<graph>,<data>)  . . .  determine vertices with data <data>
#O  WhichVertices(<graph>,<data>,<func>) . .  determine vertices functionally
##
##  Determines the list of vertices which contain the position
##  $(<x>,<y>)$. `WhichVertices' returns a list.
##  In the third form the function <func> must take two parameters <data> and
##  the data entry of a vertex in question. It must return `true' or `false', 
##  according to the vertex belonging into the result or not.
##  The function can for example consider just one record component of
##  data records.
##  Returns the empty list in case no vertex is found.
##
DeclareOperation("WhichVertices",[IsGraphicSheet,IsInt,IsInt]);
DeclareOperation("WhichVertices",[IsGraphicSheet,IsObject]);
DeclareOperation("WhichVertices",[IsGraphicSheet,IsObject,IsFunction]);


#############################################################################
##
#O  Levels(<poset>) . . . . . . . . . . . . . returns the list of levelparams
##
##  Returns the list of level parameters in descending order meaning
##  highest to lowest. 
##
DeclareOperation("Levels",[IsGraphicSheet]);


#############################################################################
##
#O  Classes(<poset>,<levelparam>) . . . . . . returns the list of classparams
##
##  Returns the list of class parameters in the level with parameter
##  <levelparam>. `Classes' Returns `fail' if no level with parameter
##  <levelparam> exists. 
##
DeclareOperation("Classes",[IsGraphicSheet,IsObject]);


#############################################################################
##
#O  Vertices(<poset>,<levelparam>,<classparam>)  . . . . . . returns vertices
##
##  Returns the list of vertices in the class with parameter <classparam>
##  in the level with parameter <levelparam>. Returns `fail' if no level
##  with parameter <levelparam> or no class with parameter <classparam>
##  exists in the level.
##
DeclareOperation("Vertices",[IsGraphicSheet,IsObject,IsObject]);


#############################################################################
##
#O  Maximals(<poset>,<vertex>) . . . . . . . . .  returns maximal subvertices
##
##  Returns the list of maximal subvertices in <vertex>. 
##
DeclareOperation("Maximals",[IsGraphicSheet,IsObject]);


#############################################################################
##
#O  MaximalIn(<poset>,<vertex>) . .  returns vertices, in which v. is maximal
##
##  Returns the list of vertices, in which <vertex> is maximal.  
##
DeclareOperation("MaximalIn",[IsGraphicSheet,IsObject]);


#############################################################################
##
#O  PositionLevel(<poset>,<levelparam>) . . . . . returns y position of level 
##
##  Returns the y position of the level relative to the graphic
##  sheet and the height. Returns `fail' if no level with parameter 
##  <levelparam> exists.
##
DeclareOperation("PositionLevel",[IsGraphicSheet,IsObject]);


#############################################################################
##
##  Operations for Menus and Mouse:
##
#############################################################################


#############################################################################
##
#O  Menu(<graph>,<title>,<entrylist>,<typelist>,<functionslist>) . . new menu
##
##  This operation already exists in {\XGAP} for graphic sheets.
##  Builds a new menu with title <title> but with information about the
##  type of the menu entry. 
##  This information describes the relation between the selection state of
##  the vertices and the parameters supplied to the functions. It is stored 
##  in the list <typelist>, which consists of strings. The following 
##  types are supported:
##  \beginitems
##    `forany' &  always enabled, generic routines don't change anything
##
##    `forone' &  enabled iff exactly one vertex is selected
##
##    `fortwo' &  enabled iff exactly two vertices are selected
##
##    `forthree'& enabled iff exactly three vertices are selected
##
##    `forsubset'&enabled iff at least one vertex is selected
##
##    `foredge' & enabled iff a connected pair of two vertices is selected
##
##    `formin2' & enabled iff at least two vertices are selected
##
##    `formin3' & enabled iff at least three vertices are selected
##
##  \enditems
##
##  <entrylist> and <functionslist> are like in the original operation for
##  graphic sheets.
##  The `IsMenu' object is returned. It is also stored in the sheet.
##
DeclareOperation("Menu",[IsGraphicSheet,IsString,IsList,IsList,IsList]);


#############################################################################
##
#O  ModifyEnabled(<graph>,<from>,<to>) , . .  modifies enablednes of entries
##
##  Modifies the ``Enabledness'' of menu entries according to their type and
##  number of selected vertices. This operation works on all menu entries
##  of some menus: <from> is the first menu to work on and
##  <to> the last one (indices). Only menus with the property `IsAlive' are
##  considered. `ModifyEnabled' returns nothing.
##
DeclareOperation("ModifyEnabled",[IsGraphicSheet,IsInt,IsInt]);


#############################################################################
##
#O  InstallPopup(<graph>,<func>) . install function for right click on vertex
##
##  Installs a function that is called if the user clicks with the right
##  button on a vertex. The function gets as parameters:
##   <poset>,<vertex>,<x>,<y>        (click position)
##
DeclareOperation("InstallPopup",[IsGraphicSheet,IsFunction]);

  
#############################################################################
##
##  Methods for user interaction:
##
#############################################################################


#############################################################################
##
#O  PosetLeftClick(<poset>,<x>,<y>) . method which is called after left click
##
##  This operation is called when the user does a left click in the poset
##  <poset>. The current pointer position is supplied in the parameters <x> 
##  and <y>. The generic method for `PosetLeftClick' lets the user move,
##  select and deselect vertices or edges. An edge is selected as pair of
##  vertices. 
##
DeclareOperation( "PosetLeftClick", [IsGraphicSheet, IsInt, IsInt] );


#############################################################################
##
#O  PosetCtrlLeftClick(<poset>,<x>,<y>) . . . . . . . . . . . . . . . . . .
#                                     method which is called after left click
##
##  This operation is called when the user does a left click in a poset
##  <poset> while holding down the control key. The current pointer
##  position is supplied in the parameters <x> and <y>. The generic method
##  for `PosetCtrlLeftClick' lets the user move, select and deselect
##  vertices or edges. The difference to the operation without the control
##  key is, that while selecting the old vertices are NOT deselected.
##  Moving does not move the whole class but only one vertex. This allows
##  for permuting the vertices within a class. An edge is selected as pair
##  of vertices.
##
DeclareOperation( "PosetCtrlLeftClick", [IsGraphicSheet, IsInt, IsInt] );


#############################################################################
##
#O  PosetRightClick(<poset>,<x>,<y>) method which is called after right click
##
##  This operation is called when the user does a right click in the graph
##  <graph>.  The generic method just finds the vertex under the mouse
##  pointer and calls the `rightclickfunction' of the poset or graph which
##  is a component in the {\GAP} object. Note that the `rightclickfunction'
##  can be called with `fail' if no vertex is hit.
##
DeclareOperation( "PosetRightClick", [IsGraphicSheet, IsInt, IsInt] );


#############################################################################
##
#O  UserDeleteVerticesOp (<sheet>, <menu>, <entry>) . . . . . . . . . . . . .
##  . . . . . . . . . . . . .  is called if the user wants to delete vertices
##
##  This operation is called when the user selects `Delete vertices'.
##  The generic method actually deletes the selected vertices including all
##  their edges.
##
DeclareOperation( "UserDeleteVerticesOp", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserDeleteEdgeOp (<sheet>, <menu>, <entry>) . . . . . . . . . . . . . . .
##  . . . . . . . . . . . . . . is called if the user wants to delete an edge
##
##  This operation is called when the user selects `Delete edge'.
##  The generic method deletes the edge with no further warning!
##
DeclareOperation( "UserDeleteEdgeOp", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserMergeClassesOp (<sheet>, <menu>, <entry>) . . . . . . . . . . . . . .
##  . . . . . . . . . . . . . .  is called if the user wants to merge classes
##
##  This operation is called when the user selects `Merge Classes'.
##  The generic method walks through all levels and merges all classes that
##  contain a selected vertex. Afterwards `UserRearrangeClasses' is called.
##
DeclareOperation( "UserMergeClassesOp", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserMagnifyLattice (<sheet>, <menu>, <entry>) . . . . . . . . . . . . . .
##  . . . . . . . . . . . . . . . . lets the user magnify the graphic lattice
##
##  This operation is called when the user selects `Magnify Lattice'. 
##  The generic method scales everything by $144/100$ including the sheet,
##  all heights of levels and positions of vertices.
##
DeclareOperation( "UserMagnifyLattice", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserShrinkLattice (<sheet>, <menu>, <entry>)  . . . . . . . . . . . . . . 
##  . . . . . . . . . . . . . . . .  lets the user shrink the graphic lattice
##
##  This operation is called when the user selects `Shrink Lattice'. 
##  The generic method scales everything by 100/144 including the sheet,
##  all heights of levels and positions of vertices.
##
DeclareOperation( "UserShrinkLattice", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserResizeLattice (<sheet>, <menu>, <entry>)  . . . . . . . . . . . . . . 
##  . . . . . . . . . . . . . . . .  lets the user resize the graphic lattice
##
##  This operation is called when the user selects `Resize Lattice'. 
##  The generic method asks the user for an x and a y factor and scales
##  everything including the sheet, all heights of levels and positions of 
##  vertices.
##
DeclareOperation( "UserResizeLattice", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserResizeSheet (<sheet>, <menu>, <entry>)  . . . . . . . . . . . . . . .   
##  . . . . . . . . . . . . . . . . .  lets the user resize the graphic sheet
##
##  This operation is called when the user selects `Resize Sheet'. 
##  The generic method asks the user for an x and a y pixel number and
##  changes the width and height of the sheet. No positions of levels and
##  vertices are changed. If the user asks for trouble he gets it!
##
DeclareOperation( "UserResizeSheet", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserMoveLattice (<sheet>, <menu>, <entry>)  . . . . . . . . . . . . . . .   
##  . . . . . . . . . . . . . . . . . . . . . lets the user move all vertices
##
##  This operation is called when the user selects `Move Lattice'. 
##  The generic method asks the user for a pixel number and
##  changes the position of all vertices horizontally. No positions of 
##  levels are changed. 
##
DeclareOperation( "UserMoveLattice", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserChangeLabels (<sheet>, <menu>, <entry>) . . . . . . . . . . . . . . .   
##  . . . . . . . . . . . . . . . . . lets the user change labels of vertices
##
##  This operation is called when the user selects `Change Labels'. 
##  The user is prompted for every selected vertex, which label it should
##  have.
##
DeclareOperation( "UserChangeLabels", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserAverageY (<sheet>, <menu>, <entry>) . . . . . . . . . . . . . . . . .   
##  . . . . . . . . . . . . . . . . average all y positions within all levels
##
##  This operation is called when the user selects `Average Y Positions'.
##  In all levels the average y coordinate is calculated and all vertices are
##  moved to this y position.
##
DeclareOperation( "UserAverageY", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserAverageX (<sheet>, <menu>, <entry>) . . . . . . . . . . . . . . . . .   
##  . . . . . . . . . . . . . . . .  average all x positions of sel. vertices
##
##  This operation is called when the user selects `Average X Positions'.
##  The average of all x coordinates of the selected vertices is calculated.
##  Then all classes with a selected vertex are moved such that the first
##  selected vertex in this class has the calculated position as x position.
##
DeclareOperation( "UserAverageX", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  UserRearrangeClasses (<sheet>, <menu>, <entry>) . . . . . . . . . . . . . 
##  . . . . . . .  . . . . . . . . . . . . .  rearrange vertices within class
##
##  This operation is called when the user selects `Rearrange Classes'.
##  All classes with a selected vertex are rearranged: The vertices are
##  lined up neatly one after the other, sorted according to their current
##  x position.
##
DeclareOperation( "UserRearrangeClasses", [IsGraphicSheet, IsMenu, IsString] );


############################################################################
##
#O  UserUseBlackWhite (<sheet>, <menu>, <entry>) . . . . . . . . . . . . . . 
##  . . . . . . . . . . . . . . . . . . .  called if user selects bw in menu
##
##  This is called if the user selects `Use Black and White' in the menu.
##
DeclareOperation( "UserUseBlackWhite", [ IsGraphicSheet, IsMenu, IsString ] );


#############################################################################
##
#O  PosetShowLevels (<sheet>, <menu>, <entry>)  . . . . . . . . . . . . . . . 
##  . . . . . . .  . . . . . . . . . . . . . . . . . switch display of levels
##
##  This operation is called when the user selects `Show Levels' in the menu.
##  Switches the display of the little boxes for level handling on and off.
##
DeclareOperation( "PosetShowLevels", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  PosetShowLevelparams (<sheet>, <menu>, <entry>) . . . . . . . . . . . . . 
##  . . . . . . . . . . . . . . . . . . . . switch display of levelparameters
##
##  This operation is called when the user selects `Show Level Parameters' in 
##  the menu. Switches the display of the level parameters at the right of
##  the screen on and off.
##
DeclareOperation( "PosetShowLevelparams", [IsGraphicSheet, IsMenu, IsString] );


#############################################################################
##
#O  DoRedraw(<graph>). . . . . . . . . . redraws all vertices and connections
##
##  Redraws all vertices and connections.
##
DeclareOperation( "DoRedraw", [IsGraphicSheet] );



