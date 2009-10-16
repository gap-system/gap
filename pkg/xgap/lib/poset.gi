#############################################################################
##
#W  poset.gi                  	XGAP library                  Max Neunhoeffer
##
#H  @(#)$Id: poset.gi,v 1.19 1999/11/25 18:06:57 gap Exp $
##
#Y  Copyright 1998,       Max Neunhoeffer,              Aachen,       Germany
##
##  This file contains the implementations for graphs and posets
##
Revision.pkg_xgap_lib_poset_gd :=
    "@(#)$Id: poset.gi,v 1.19 1999/11/25 18:06:57 gap Exp $";



#############################################################################
##
##  Declarations of representations:
##
#############################################################################


#############################################################################
##
#R  IsGraphicGraphRep . . . . . . . . . . . . . . .  representation for graph
##
if not IsBound(IsGraphicGraphRep) then
  DeclareRepresentation( "IsGraphicGraphRep",
    IsComponentObjectRep and IsAttributeStoringRep and IsGraphicSheet and
    IsGraphicSheetRep,
# we inherit those components from the sheet:        
    [ "name", "width", "height", "gapMenu", "callbackName", "callbackFunc",
      "menus", "objects", "free",
# now our own components:
      "vertices","edges","selectedvertices","menutypes",
      "menuenabled","rightclickfunction","color"],
    IsGraphicSheet );
fi;



#############################################################################
##
#R  IsGraphicPosetRep . . . . . . . . . . . . . . .  representation for poset
##
if not IsBound(IsGraphicPosetRep) then
  DeclareRepresentation( "IsGraphicPosetRep",
        IsComponentObjectRep and IsAttributeStoringRep and 
        IsGraphicSheet and IsGraphicSheetRep and IsGraphicGraphRep,
# we inherit those components from the sheet:        
    [ "name", "width", "height", "gapMenu", "callbackName", "callbackFunc",
      "menus", "objects", "free",
# now our own components:
      "levels",           # list of levels, stores current total ordering
      "levelparams",      # list of level parameters
      "selectedvertices", # list of selected vertices
      "menutypes",        # one entry per menu which contains list of types
      "menuenabled",      # one entry per menu which contains list of flags
      "rightclickfunction",    # the current function which is called when
                               # user clicks right button
      "color",            # some color infos for the case of different models
      "levelboxes",       # little graphic boxes for the user to handle levels
      "showlevelparams",  # flag, if level parameters are shown
      "showlevels"],      # flag, if levelboxes are shown
    IsGraphicSheet );
fi;


#############################################################################
##
#R  IsGPLevel . . . . . . . . . . . . . . . . . . .  representation for level
##
if not IsBound(IsGPLevel) then
  DeclareRepresentation( "IsGPLevel",
        IsComponentObjectRep,
        [ "top",          # y coordinate of top of level, relative to sheet
          "height",       # height in pixels
          "classes",      # list of classes, which are lists of vertices
          "classparams",  # list of class parameters
          "poset"         # poset to which level belongs
        ],
        IsGraphicObject );
fi;

#############################################################################
##
#R  IsGGVertex . . . . . . . . . . . . . . . . . .  representation for vertex
##
if not IsBound(IsGGVertex) then
  DeclareRepresentation( "IsGGVertex",
        IsComponentObjectRep and IsGraphicObject,
        [ "data",         # the mathematical data
          "obj",          # real graphic object
          "x","y",        # coordinates of graphic object within sheet
          "serial",       # a serial number for comparison
          "label"         # the label of the vertex or false
        ],
        IsGraphicObject );
fi;


#############################################################################
##
#R  IsGPVertex . . . . . . . . . . . . . . . . . .  representation for vertex
##
if not IsBound(IsGPVertex) then
  DeclareRepresentation( "IsGPVertex",
        IsComponentObjectRep and IsGraphicObject,
        [ "data",         # the mathematical data
          "obj",          # real graphic object
          "levelparam",   # level parameter
          "classparam",   # class parameter
          "maximals",     # list of vertices which are maximal subobjects
          "maximalin",    # list of vertices where this one is maximal in
          "x","y",        # coordinates of graphic object within level
          "serial",       # a serial number for comparison
          "label"         # the label of the vertex or false
        ],
        IsGraphicObject );
fi;


#############################################################################
##
##  Some global things we all need:
##
#############################################################################


##  We count all vertices:
PosetLastUsedSerialNumber := 0;


##  The following function is installed as a LeftPBDown in every graph or
##  poset. It calls the operation PosetLeftClick.

PosetLeftClickCallback := function(poset,x,y)
  PosetLeftClick(poset,x,y);
end;
  
##  The following function is installed as a RightPBDown in every graph or
##  poset. It calls the operation PosetRightClick.

PosetRightClickCallback := function(poset,x,y)
  PosetRightClick(poset,x,y);
end;
  
##  The following function is installed as a CtrlLeftPBDown and 
##  ShiftLeftPBDown in every graph or poset. It calls the operation 
##  PosetCtrlLeftClick.

PosetCtrlLeftClickCallback := function(poset,x,y)
  PosetCtrlLeftClick(poset,x,y);
end;
    

##  The following is a for a menu entry and just calls another method:
PosetDoRedraw := function(poset,menu,entry)
  DoRedraw(poset);
end;


##  Our menu which goes in all poset sheets:
PosetMenuEntries :=
  ["Redraw","Show Levels","Show Level Parameters",,
   "Delete Vertices","Delete Edge","Merge Classes",,
   "Magnify Lattice", "Shrink Lattice", "Resize Lattice", "Resize Sheet",
   "Move Lattice",,
   "Change Labels","Average Y Positions","Average X Positions",
   "Rearrange Classes"];
PosetMenuTypes :=
  ["forany","forany","forany",,
   "forsubset","foredge","forsubset",,
   "forany","forany","forany","forany","forany",,
   "forsubset","forany","forsubset","forsubset"];
PosetMenuFunctions :=
  [ PosetDoRedraw,PosetShowLevels,PosetShowLevelparams,,
    UserDeleteVerticesOp, UserDeleteEdgeOp, UserMergeClassesOp,,
    UserMagnifyLattice,UserShrinkLattice,UserResizeLattice,UserResizeSheet,
    UserMoveLattice,,
    UserChangeLabels,UserAverageY,UserAverageX,UserRearrangeClasses];


#############################################################################
##
##  Constructors:
##
#############################################################################


## we need this to set up the colors in a sheet:

BindGlobal( "GPMakeColors",
        function( sheet )
  
  # set up color information:
  if sheet!.color.model = "color"  then
    if COLORS.red <> false  then
      sheet!.color.unselected := COLORS.black;
      sheet!.color.selected   := COLORS.red;
    else
      sheet!.color.unselected := COLORS.dimGray;
      sheet!.color.selected   := COLORS.black;
    fi;
    if COLORS.green <> false  then
      sheet!.color.result := COLORS.green;
    else
      sheet!.color.result := COLORS.black; # COLORS.lightGray;
    fi;
  else
    sheet!.color.selected   := COLORS.black;
    sheet!.color.unselected := COLORS.black;
    sheet!.color.result     := false;
  fi;
end);

  
#############################################################################
##
#M  GraphicGraph( <name>, <width>, <height> ) . . . . . . a new graphic graph
##
##  creates a new graphic graph which is a graphic sheet representation
##  with knowledge about vertices and edges and infrastructure for user
##  interfaces.
##
InstallMethod( GraphicGraph,
    "for a string, and two integers",
    true,
    [ IsString,
      IsInt,
      IsInt ],
    0,

function( name, width, height )
  #local ...;
  
end);


#############################################################################
##
#M  GraphicPoset( <name>, <width>, <height> ) . . . . . . a new graphic poset
##
##  creates a new graphic poset which is a specialization of a graphic graph
##  mainly because per definition a poset comes in "layers" or "levels". This
##  leads to some algorithms that are more efficient than the general ones
##  for graphs.
##
InstallMethod( GraphicPoset,
    "for a string, and two integers",
    true,
    [ IsString,
      IsInt,
      IsInt ],
    0,

function( name, width, height )
  local   poset,  tmpEntries,  tmpTypes,  tmpFuncs,  m;
  
  poset := GraphicSheet(name,width,height);
  SetFilterObj(poset,IsGraphicGraphRep);
  SetFilterObj(poset,IsGraphicPosetRep);
  poset!.levels := [];
  poset!.levelparams := [];
  poset!.selectedvertices := [];
  # think of the GAP menu:
  poset!.menutypes := [List(poset!.menus[1]!.entries,x->"forany")];
  poset!.menuenabled := [List(poset!.menus[1]!.entries,x->true)];
  poset!.rightclickfunction := Ignore;
  
  # set up color information:
  poset!.color := rec();
  if COLORS.red <> false or COLORS.lightGray <> false  then
    poset!.color.model := "color";
    # note: if you rename this, think of the "use black&white" below!  
  else
    poset!.color.model := "monochrome";
  fi;
  GPMakeColors(poset);
  
  poset!.levelboxes := [];
  poset!.showlevels := false;
  poset!.lptexts := [];
  poset!.showlevelparams := true;
  
  InstallCallback(poset,"LeftPBDown",PosetLeftClickCallback);
  InstallCallback(poset,"ShiftLeftPBDown",PosetCtrlLeftClickCallback);
  InstallCallback(poset,"CtrlLeftPBDown",PosetCtrlLeftClickCallback);
  InstallCallback(poset,"RightPBDown",PosetRightClickCallback);
  
  tmpEntries := ShallowCopy(PosetMenuEntries);
  tmpTypes := ShallowCopy(PosetMenuTypes);
  tmpFuncs := ShallowCopy(PosetMenuFunctions);
  if poset!.color.model = "color" then
    Append(tmpEntries,["-","Use Black&White"]);
    Append(tmpTypes,["-","forany"]);
    Append(tmpFuncs,["-",UserUseBlackWhite]);
  fi;
  m := Menu(poset,"Poset",tmpEntries,tmpTypes,tmpFuncs);
  Check(m,"Show Level Parameters",true);
  
  return poset;
end);


#############################################################################
##
#M  CreateLevel(<poset>, <levelparam>) . . . . . . creates new level in poset
#M  CreateLevel(<poset>, <levelparam>, <lptext>) . creates new level in poset
##
##  A level in a graphic poset can be thought of as a horizontal slice of
##  the poset. It has a y coordinate of the top of the level relatively to
##  the graphic sheet and a height. Every class of vertices in a graphic
##  poset is in a level. The levels are totally ordered by their y
##  coordinate. No two vertices which are included in each other are in the
##  same level. A vertex containing another one is always "higher" on the
##  screen, meaning in a "higher" level.  Every level has a unique
##  levelparam, which can be any {\GAP} object. The user is responsible for
##  all methods where a levelparam occurs as parameter and is not just an
##  integer. There is NO {\GAP} object representing a level which is visible
##  for the user of posets. All communication about levels goes via the
##  levelparam.  Returns fail if there is already a level with a level
##  parameter which is considered "equal" by CompareLevels or levelparam if
##  everything went well.
##  The second method allows to specify which text appears for the level at
##  the right edge of the sheet.
##
InstallMethod( CreateLevel,
    "for a graphic poset, a level parameter, and a string",
    true,
    [ IsGraphicPosetRep, IsObject, IsString ],
    0,

function( poset, levelparam, lpstr )
  local   level,  box,  str,  strlen,  text,  l,  firstpos,  before,  look,  
          compare,  i,  cl,  v;
      
  # does this level parameter exist already?
  if Position(poset!.levelparams,levelparam) <> fail then
    return fail;
  fi;
  
  # create a level object:
  level := rec(classes := [],
               classparams := [],
               poset := poset);
  Objectify(NewType(GraphicObjectFamily,IsGPLevel),level);
  
  # is it the first level:
  if poset!.levelparams = [] then
    poset!.levelparams := [levelparam];
    poset!.levels := [level];
    level!.top := 0;
    level!.height := 2 * VERTEX.diameter;
    
    # make a level box:
    box := Box(poset,0,level!.top+level!.height-8,8,8);
    if COLORS.blue <> false then
      Recolor(box,COLORS.blue);
    fi;
    if not poset!.showlevels then
      Destroy(box);
    fi;
    
    poset!.levelboxes := [ box ];
    
    # make a text for level parameter:
    if lpstr <> "" then
      str := lpstr;
    else
      str := String(levelparam);
    fi;
    strlen := Length(str);
    text := Text(poset,FONTS.normal,
                 poset!.width - 24 - strlen*FontInfo(FONTS.normal)[3],
                 level!.top + QuoInt(level!.height,2),str);
    if COLORS.blue <> false then
      Recolor(text,COLORS.blue);
    fi;
    if not poset!.showlevelparams then
      Destroy(text);
    fi;
    
    poset!.lptexts := [ text ];
    
    return levelparam;
  fi;
  
  # now find the position, we choose the last position where the new level
  # can be according to the partial order defined by CompareLevels we do a
  # binary search, we insert not before "firstpos" and before "before".
  # Attention: We cannot decide at a level which is not comparable to the
  # new level, so we have to search linearly for a comparable level!
  l := Length(poset!.levelparams);
  firstpos := 1;
  before := l + 1;
  while firstpos < before do
    look := QuoInt(firstpos + before,2);
    repeat  # search first backward up to firstpos, then down
      compare := CompareLevels(poset,levelparam,poset!.levelparams[look]);
      if compare = 0 then 
        return fail;
      elif compare = fail then   # not comparable
        look := look-1;
      fi;
    until compare <> fail or look < firstpos;
    if compare = fail then
      # search now forward down to before
      look := QuoInt(firstpos + before,2)+1;
      if look = before then
        firstpos := before;   # we insert right HERE!
        compare := 0;
      fi;
      while compare = fail do
        compare := CompareLevels(poset,levelparam,poset!.levelparams[look]);
        if compare = 0 then 
          return fail;
        elif compare = fail then     # not comparable
          look := look+1;
          if look = before then     # nothing comparable in between!
            firstpos := before;     # we insert right HERE!
            compare := 0;           # this does exactly that!
          fi;
        fi;
      od;
    fi;
    if compare < 0 then
      before := look;
    elif compare > 0 then
      firstpos := look+1;
    fi;
  od;
  
  # we now insert at position firstpos = before:
  poset!.levelparams{[firstpos+1..l+1]} := poset!.levelparams{[firstpos..l]};
  poset!.levelparams[firstpos] := levelparam;
  poset!.levels{[firstpos+1..l+1]} := poset!.levels{[firstpos..l]};
  poset!.levels[firstpos] := level;
  poset!.levelboxes{[firstpos+1..l+1]} := poset!.levelboxes{[firstpos..l]};
  poset!.lptexts{[firstpos+1..l+1]} := poset!.lptexts{[firstpos..l]};
  
  if firstpos = 1 then
    level!.top := 0;
  else
    level!.top := poset!.levels[firstpos-1]!.top +
                  poset!.levels[firstpos-1]!.height;
  fi;
  level!.height := 2 * VERTEX.diameter;
  
  # move all lower levels down:
  FastUpdate(poset,true);
  for i in [firstpos+1..l+1] do
    poset!.levels[i]!.top := poset!.levels[i]!.top + level!.height;
    for cl in poset!.levels[i]!.classes do
      for v in cl do
        MoveDelta(v!.obj,0,level!.height);
      od;
    od;
    if poset!.showlevels then
      MoveDelta(poset!.levelboxes[i],0,level!.height);
    fi;
    if poset!.showlevelparams then
      MoveDelta(poset!.lptexts[i],0,level!.height);
    fi;
  od;
  FastUpdate(poset,false);
  
  # has the graphic sheet become higher?
  l := l + 1;    # this means:   l := Length(poset!.levels);
  i := poset!.levels[l]!.top + poset!.levels[l]!.height;
  if i > poset!.height then
    Resize(poset,poset!.width,i);
  fi;
  
  # create a level box:
  box := Box(poset,0,level!.top+level!.height-8,8,8);
  if COLORS.blue <> false then
    Recolor(box,COLORS.blue);
  fi;
  if not poset!.showlevels then
    Destroy(box);
  fi;
  poset!.levelboxes[firstpos] := box;
  
  # create a level parameter text:
  if lpstr <> "" then
    str := lpstr;
  else
    str := String(levelparam);
  fi;
  strlen := Length(str);
  text := Text(poset,FONTS.normal,
               poset!.width - 24 - strlen*FontInfo(FONTS.normal)[3],
               level!.top + QuoInt(level!.height,2),str);
  if COLORS.blue <> false then
    Recolor(text,COLORS.blue);
  fi;
  if not poset!.showlevelparams then
    Destroy(text);
  fi;
  poset!.lptexts[firstpos] := text;
  
  return levelparam;
end);


InstallOtherMethod( CreateLevel,
    "for a graphic poset, and a level parameter",
    true,
    [ IsGraphicPosetRep, IsObject ],
    0,
function( poset, levelparam )
  return CreateLevel(poset,levelparam,"");
end);


#############################################################################
##
#M  CreateClass(<poset>,<levelparam>,<classparam>) . . . .  creates new class
##
##  A class in a graphic poset is a collection of vertices within a level
##  which belong together in some sense.  Every vertex in a graphic poset
##  is in a class, which in turn belongs to a level. Every class in a level
##  has a unique classparam, which can be any {\GAP} object. The user is
##  responsible for all methods where a classparam occurs as parameter and
##  is not just an integer. There is NO {\GAP} object representing a class
##  which is visible to the user of posets. All communication about classes
##  goes via the classparam.  Returns fail if there is no level with
##  parameter levelparam or there is already a class in this level with
##  parameter classparam. Returns classparam otherwise.
##
InstallMethod( CreateClass,
    "for a graphic poset, a level parameter, and a class parameter",
    true,
    [ IsGraphicPosetRep, IsObject, IsObject ],
    0,

function( poset, levelparam, classparam )
  local nr, level;
  
  nr := Position(poset!.levelparams,levelparam);
  if nr = fail then
    return fail;
  fi;
  level := poset!.levels[nr];
  
  nr := Position(level!.classparams,classparam);
  if nr <> fail then
    return fail;
  fi;
  
  Add(level!.classparams,classparam);
  Add(level!.classes,[]);
  
  return classparam;
end);

  
#############################################################################
##
#M  Vertex(<graph>,<data>[,<inf>]) . . . . . . . . . . . . creates new vertex
##
##  Creates a new vertex. <inf> is a record in which additional info can be
##  supplied for the new vertex. For general graphic graphs only the
##  "label", "color", "shape", "x" and "y" components are applicable, they
##  contain a short label which will be attached to the vertex, the color,
##  the shape ("circle", "diamond", or "rectangle") and the coordinates
##  relative to the graphic sheet respectively. For graphic posets also the 
##  components "levelparam" and "classparam" are evaluated. If the component
##  "hints" is bound it must be a list of x coordinates which will be
##  delivered to ChoosePosition to help placement. Those x coordinates will
##  be the coordinates of other vertices related to the new one. All values of
##  record components which are not specified will be determined by calling 
##  some methods for graphic graphs or posets. Those are:
##    ChooseLabel for the label,
##    ChooseColor for the color,
##    ChooseShape for the shape,
##    ChoosePosition for the position,
##    ChooseLevel for the levelparam, and
##    ChooseClass for the classparam.
##    ChooseWidth for the line width of the vertex
##  Returns fail no vertex was created. This happens only, if one of the
##  choose functions return fail or no possible value, for example a
##  non-existing level or class parameter.
##  Returns vertex object if everything went well. 
##
InstallOtherMethod( Vertex,
    "for a graphic poset, an object, and a record",
    true,
    [ IsGraphicPosetRep, IsObject, IsRecord ],
    0,

function( poset, data, info )
  local   lp,  lnr,  level,  cp,  cnr,  class,  vertex,  label,  shape,  
          color,  position, width;
  
  # first determine levelparam:
  if not IsBound(info.levelparam) then
    lp := ChooseLevel(poset,data);
  else
    lp := info.levelparam;
  fi;
  if lp = fail then
    return fail;
  fi;
  
  # we search for the level:
  lnr := Position(poset!.levelparams,lp);
  if lnr = fail then
    return fail;
  fi;
  level := poset!.levels[lnr];
  
  # now determine class:
  if not IsBound(info.classparam) then
    cp := ChooseClass(poset,data,lp);
  else
    cp := info.classparam;
  fi;
  if cp = fail then
    return fail;
  fi;
  
  # we search for the class:
  cnr := Position(level!.classparams,cp);
  if cnr = fail then
    return fail;
  fi;
  class := level!.classes[cnr];
  
  # create a new vertex object:
  PosetLastUsedSerialNumber := PosetLastUsedSerialNumber + 1;
  vertex := rec(data := data,
                levelparam := lp,
                classparam := cp,
                maximals := [],
                maximalin := [],
                serial := PosetLastUsedSerialNumber);
  Objectify(NewType(GraphicObjectFamily,IsGPVertex),vertex);
  SetFilterObj(vertex,IsGGVertex);
  SetFilterObj(vertex,IsAlive);
  
  # choose label, shape, color and position:
  if not IsBound(info.label) then
    label := ChooseLabel(poset,data);
    if label = fail then
      return fail;
    fi;
  else
    label := info.label;
  fi;
  if not IsBound(info.shape) then
    shape := ChooseShape(poset,data);
    if shape = fail then
      return fail;
    fi;
  else
    shape := info.shape;
  fi;
  if not IsBound(info.color) then
    color := ChooseColor(poset,data);
    if color = fail then
      return fail;
    fi;
  else
    color := info.color;
  fi;
  if not (IsBound(info.x) and IsBound(info.y)) then
    if IsBound(info.hints) then
      position := ChoosePosition(poset,data,level,class,info.hints);
    else
      position := ChoosePosition(poset,data,level,class,[]);
    fi;
    if IsBound(info.x) then   # this takes precedence!
      vertex!.x := info.x;
    else
      vertex!.x := position[1];
    fi;
    if IsBound(info.y) then   # this takes precedence!
      vertex!.y := info.y;
    else
      vertex!.y := position[2];
    fi;
  else
    vertex!.x := info.x;
    vertex!.y := info.y;
  fi;
  if not IsBound(info.width) then
    width := ChooseWidth(poset,data);
    if width = fail then
      return fail;
    fi;
  fi;
  
  vertex!.label := label;
  
  # create the graphic object:
  vertex!.obj := Vertex(poset,vertex!.x,level!.top + vertex!.y,
                        rec(label := label,color := color,width := width));
  if shape = "diamond" then
    Reshape(vertex!.obj,VERTEX.diamond);
  elif shape = "rectangle" then
    Reshape(vertex!.obj,VERTEX.rectangle);
  fi;
  
  # put it into the class:
  Add(class,vertex);
  
  return vertex;
end);


#############################################################################
##
##  The following function is only internal:
##
##  Use it on your own risk and only if you know what you are doing!
##
GPSearchWay := function(poset,v1,v2,l2)
  local v, p;
  for v in v1!.maximals do
    if v = v2 then
      return true;
    fi;
    
    if Position(poset!.levelparams,v!.levelparam) < l2 then
      if GPSearchWay(poset,v,v2,l2) then
        return true;
      fi;
    fi;
  od;
  return false;
end;


#############################################################################
##
#M  Edge(<poset>,<vertex1>,<vertex2>) . . . . . . . . . . . . adds a new edge
#M  Edge(<poset>,<vertex1>,<vertex2>,<def>) . . . . . . . . . adds a new edge
##
##  Adds a new edge from <vertex1> to <vertex2>. For posets this puts one
##  of the vertices into the other as a maximal subvertex. So either
##  <vertex1> must lie in a "higher" level than <vertex2> or the other way
##  round. There must be no vertex "between" <vertex1> and <vertex2>. If
##  the two vertices are in the same level or one is already indirectly
##  included in the other fail is returned, otherwise true. That means,
##  that in the case where one of the two vertices is already a maximal
##  subobject of the other, then the method does nothing and returns true.
##  The variation with a defaults record just hands this over to the lower
##  levels, meaning that the line width and color are modified.
##
InstallOtherMethod( Edge,
    "for a graphic poset, two vertices, and a defaults record",
    true,
    [ IsGraphicPosetRep, IsGPVertex, IsGPVertex, IsRecord ],
    0,

function( poset, v1, v2, def )
  local   l1,  l2,  dummy,  l,  p;
  
  # we permute v1 and v2 such that v1 is in higher level:
  if CompareLevels(poset,v1!.levelparam,v2!.levelparam) = 0 then
    return fail;
  fi;
  l1 := Position(poset!.levelparams,v1!.levelparam);
  l2 := Position(poset!.levelparams,v2!.levelparam);
  if l1 > l2 then
    dummy := v1; 
    v1 := v2;
    v2 := dummy;
    dummy := l1;
    l1 := l2;
    l2 := dummy;
  fi;
   
  # first we have to perform a few checks:
  if Position(v1!.maximals,v2) <> fail then
    return true;
  fi;
  if GPSearchWay(poset,v1,v2,l2) then
    return fail;
  fi;
  
  # let's think about color, label and width:
  if not IsBound(def.color) then
    def.color := ChooseColor(poset,v1!.data,v2!.data);
    if def.color = fail then
      return fail;
    fi;
  fi;
  if not IsBound(def.label) then
    def.label := ChooseLabel(poset,v1!.data,v2!.data);
    if def.label = fail then
      return fail;
    fi;
  fi;
  if not IsBound(def.width) then
    def.width := ChooseWidth(poset,v1!.data,v2!.data);
    if def.width = fail then
      return fail;
    fi;
  fi;
  
  # now we know that there is no direct or indirect inclusion of v2 in v1.
  # we can savely put v2 "into" v1.
  Add(v1!.maximals,v2);
  Add(v2!.maximalin,v1);
  Connection(v1!.obj,v2!.obj,def);                                               

  return true;
  
end);

InstallOtherMethod( Edge,
    "for a graphic poset, and two vertices",
    true,
    [ IsGraphicPosetRep, IsGPVertex, IsGPVertex ],
    0,

function( poset, v1, v2 )
  return Edge(poset,v1,v2,rec());
end);

        
#############################################################################
##
##  Destructors:
##
#############################################################################


#############################################################################
##
##  Set this variable temporarily to false if you delete many things!
##
GGDeleteModifiesMenu := true;


#############################################################################
##
#M  Delete(<graph>,<obj>) . . . . . . . . . . . . . remove something in graph
##
##  This operation already exists in {\XGAP} for the graphic objects!
##  Applicable for edges, vertices, classes.
##
##  The following method applies to an edge, given by two vertices. It returns
##  fail if not one of the vertices is maximal in the other and true
##  otherwise. 
InstallOtherMethod( Delete,
    "for a graphic poset, and two vertices",
    true,
    [ IsGraphicPosetRep, IsGPVertex, IsGPVertex ],
    0,

function( poset, v1, v2 )
  local   p,  dummy,  l;
  
  # determine which is the "bigger one":
  p := Position(v2!.maximals,v1);
  if p = fail then
    p := Position(v1!.maximals,v2);
    if p = fail then
      return fail;
    fi;
    # swap the vertices:
    dummy := v1;
    v1 := v2;
    v2 := dummy;
  fi;
  # v1 is now maximal in v2 at position p in v2!.maximals
  
  Disconnect(v1!.obj,v2!.obj);
  l := Length(v2!.maximals);
  v2!.maximals[p] := v2!.maximals[l];
  Unbind(v2!.maximals[l]);
  p := Position(v1!.maximalin,v2);
  # fail is not an option here! If that happens we bomb out!
  l := Length(v1!.maximalin);
  v1!.maximalin[p] := v1!.maximalin[l];
  Unbind(v1!.maximalin[l]);
  
  # think about the menus:
  if GGDeleteModifiesMenu then
    ModifyEnabled(poset,1,Length(poset!.menus));
  fi;
  
  return true;
end);  

##  The following method applies to a vertex. It returns fail if the vertex
##  is not in the poset. The vertex is deleted and all connections to other
##  vertices are also deleted! Returns true if vertex is successfully deleted.
InstallOtherMethod( Delete,
    "for a graphic poset, and a vertex",
    true,
    [ IsGraphicPosetRep, IsGPVertex ],
    0,

function( poset, v )
  local   lp,  l,  cp,  cl,  p,  savemaximals,  savemaximalin,  noerror,  
          v1,  v2,  store;
  
  lp := Position(poset!.levelparams,v!.levelparam);
  if lp = fail then
    return fail;
  fi;
  l := poset!.levels[lp];
  
  cp := Position(l!.classparams,v!.classparam);
  if cp = fail then
    return fail;
  fi;
  cl := l!.classes[cp];
  
  p := Position(cl,v);
  if p = fail then
    return fail;
  fi;
  
  # Remember all connections:
  savemaximals := ShallowCopy(v!.maximals);
  savemaximalin := ShallowCopy(v!.maximalin);
  
  # Delete all connections:
  noerror := true;
  store := GGDeleteModifiesMenu;
  GGDeleteModifiesMenu := false;
  while v!.maximals <> [] do
    if Delete(poset,v,v!.maximals[1]) = fail then
      noerror := fail;
    fi;
  od;
  while v!.maximalin <> [] do
    if Delete(poset,v,v!.maximalin[1]) = fail then
      noerror := fail;
    fi;
  od;
  GGDeleteModifiesMenu := store;
  
  # was it selected?
  RemoveSet(poset!.selectedvertices,v);
  
  # now delete vertex:
  Delete(v!.obj);
  ResetFilterObj(v,IsAlive);
  
  l := Length(cl);
  cl[p] := cl[l];
  Unbind(cl[l]);
  
  # now we have to add new inclusions from the maximal subobjects to those
  # where our vertex was maximal in. We should not do that however, if there is
  # already a way. This ensures that the diagram will be again a Hasse diagram
  # of the remaining vertices with the inclusions induced by the poset
  # before deletion.
  for v1 in savemaximals do
    for v2 in savemaximalin do
      if not GPSearchWay(poset,v2,v1,
                         Position(poset!.levelparams,v1!.levelparam)) then
        Edge(poset,v2,v1);
      fi;
    od;
  od;
        
  # think about the menus:
  if GGDeleteModifiesMenu then
    ModifyEnabled(poset,1,Length(poset!.menus));
  fi;
  
  return noerror;
end);

##  The following method applies to a class. It returns fail if the class
##  is not in the poset. The class is deleted and all vertices including
##  their connections to other vertices are also deleted! Returns true 
##  if class is successfully deleted.
##  The two parameters are a level parameter and a class parameter.
InstallOtherMethod( Delete,
    "for a graphic poset, and two objects",
    true,
    [ IsGraphicPosetRep, IsObject, IsObject ],
    0,

function( poset, levelparam, classparam )
  local   lp,  l,  cp,  noerror,  v,  store;
  
  lp := Position(poset!.levelparams,levelparam);
  if lp = fail then
    return fail;
  fi;
  l := poset!.levels[lp];
  
  cp := Position(l!.classparams,classparam);
  if cp = fail then
    return fail;
  fi;
  
  # delete all vertices:
  noerror := true;
  store := GGDeleteModifiesMenu;
  GGDeleteModifiesMenu := false;
  for v in l!.classes[cp] do
    if Delete(poset,v) = fail then
      noerror := fail;
    fi;
  od;
  GGDeleteModifiesMenu := store;
  
  lp := Length(l!.classes);
  l!.classes[cp] := l!.classes[lp];
  Unbind(l!.classes[lp]);
  l!.classparams[cp] := l!.classparams[lp];
  Unbind(l!.classparams[lp]);
  
  # think about the menus:
  if GGDeleteModifiesMenu then
    ModifyEnabled(poset,1,Length(poset!.menus));
  fi;
    
  return noerror;
end);


#############################################################################
##
#M  DeleteLevel(<poset>,<levelparam>) . . . . . . . . . remove level in poset
##
##  The following method applies to a level. It returns `fail' if no level
##  with level parameter <levelparam> is in the poset. Otherwise the level
##  is deleted and all classes within it are also deleted! `DeleteLevel'
##  returns `true' if the level is successfully deleted.
##
InstallOtherMethod( DeleteLevel,
    "for a graphic poset, and an object",
    true,
    [ IsGraphicPosetRep, IsObject ],
    0,

function( poset, levelparam )
  local   lp,  noerror,  cl,  v,  l,  lev,  store;
  
  lp := Position(poset!.levelparams,levelparam);
  if lp = fail then
    return fail;
  fi;
  
  # delete all vertices:
  noerror := true;
  store := GGDeleteModifiesMenu;
  GGDeleteModifiesMenu := false;
  for cl in poset!.levels[lp]!.classes do
    while cl <> [] do
      if Delete(poset,cl[1]) = fail then
        noerror := fail;
      fi;
    od;
  od;
  GGDeleteModifiesMenu := store;
    
  l := Length(poset!.levels);
  # now we have to move all lower levels up:
  FastUpdate(poset,true);
  for lev in [lp+1..l] do
    poset!.levels[lev]!.top := poset!.levels[lev]!.top 
                               - poset!.levels[lp]!.height;
    for cl in poset!.levels[lev]!.classes do
      for v in cl do
        Move(poset,v,v!.x,v!.y);
      od;
    od;
    if IsAlive(poset!.levelboxes[lev]) then
      MoveDelta(poset!.levelboxes[lev],0,-poset!.levels[lp]!.height);
    fi;
    if IsAlive(poset!.lptexts[lev]) then
      MoveDelta(poset!.lptexts[lev],0,-poset!.levels[lp]!.height);
    fi;
  od;
  FastUpdate(poset,false);
  poset!.levels{[lp..l-1]} := poset!.levels{[lp+1..l]};
  Unbind(poset!.levels[l]);
  poset!.levelparams{[lp..l-1]} := poset!.levelparams{[lp+1..l]};
  Unbind(poset!.levelparams[l]);
  if IsAlive(poset!.levelboxes[lp]) then
    Delete(poset,poset!.levelboxes[lp]);
  fi;
  poset!.levelboxes{[lp..l-1]} := poset!.levelboxes{[lp+1..l]};
  Unbind(poset!.levelboxes[l]);
  if IsAlive(poset!.lptexts[lp]) then
    Delete(poset,poset!.lptexts[lp]);
  fi;
  poset!.lptexts{[lp..l-1]} := poset!.lptexts{[lp+1..l]};
  Unbind(poset!.lptexts[l]);
  
  # think about the menus:
  if GGDeleteModifiesMenu then
    ModifyEnabled(poset,1,Length(poset!.menus));
  fi;

  return noerror;
end);

  
#############################################################################
##
##  Modification methods:
##
#############################################################################


#############################################################################
##
#M  ResizeLevel(<poset>,<levelparam>,<height>)  . . .  change height of level
##
##  Changes the height of a level. The y coordinate can only be changed by
##  permuting levels, see below.
##  Attention: can increase the size of the sheet!
##  Returns fail if no level with parameter levelparam exists and true
##  otherwise. 
##
InstallOtherMethod( ResizeLevel,
    "for a graphic poset, an object, and an integer",
    true,
    [ IsGraphicPosetRep, IsObject, IsInt ],
    0,

function( poset, levelparam, height )
  local   lp,  l,  cl,  v,  dist,  len;
  
  lp := Position(poset!.levelparams,levelparam);
  if lp = fail then
    return fail;
  fi;
  l := poset!.levels[lp];
  
  if height < VERTEX.diameter then
    height := VERTEX.diameter;
  fi;
  
  if height = l!.height then
    return true;
  elif height < l!.height then
    # move all vertices within level into the new range
    FastUpdate(poset,true);
    for cl in l!.classes do
      for v in cl do
        if v!.y > height-VERTEX.radius then
          v!.y := height-VERTEX.radius;
          Move(v!.obj,v!.x,v!.y + l!.top);
        fi;
      od;
    od;
         
    # now move all lower levels up:
    dist := height - l!.height;
    l!.height := height;
    
    # move level box and text:
    if poset!.showlevels then
      Move(poset!.levelboxes[lp],0,l!.top + l!.height - 8);
    fi;
    if poset!.showlevelparams then
      Move(poset!.lptexts[lp],poset!.lptexts[lp]!.x,
           l!.top + QuoInt(l!.height,2));
    fi;
    FastUpdate(poset,false);
    
  else   # height > l!.height
    dist := height - l!.height;
    l!.height := height;
    
    # do we have to increase height of sheet?
    len := Length(poset!.levels);
    if poset!.levels[len]!.top + poset!.levels[len]!.height + dist 
       > poset!.height then
      Resize(poset,poset!.width,
             poset!.levels[len]!.top + poset!.levels[len]!.height + dist);
    fi;
    
    if poset!.showlevels then
      Move(poset!.levelboxes[lp],0,l!.top + l!.height - 8);
    fi;
    if poset!.showlevelparams then
      Move(poset!.lptexts[lp],poset!.lptexts[lp]!.x,
           l!.top + QuoInt(l!.height,2));
    fi;
    
    # next move down all the levels below the increased level:
  fi;
  
  FastUpdate(poset,true);
  for l in [lp+1..Length(poset!.levels)] do
    poset!.levels[l]!.top := poset!.levels[l]!.top + dist;
    for cl in poset!.levels[l]!.classes do
      for v in cl do
        MoveDelta(v!.obj,0,dist);
      od;
    od;
    # move level box:
    if poset!.showlevels then
      MoveDelta(poset!.levelboxes[l],0,dist);
    fi;
    if poset!.showlevelparams then
      MoveDelta(poset!.lptexts[l],0,dist);
    fi;
  od;
  FastUpdate(poset,false);
end);


#############################################################################
##
#M  MoveLevel(<poset>,<levelparam>,<position>) move level to another position
##
##  Moves a level to another position. <position> is an absolute index in
##  the list of levels. The level with parameter <levelparam> will be at the
##  position <position> after the operation. This is only allowed if the
##  new ordering is compatible with the partial order given by CompareLevels
##  and if there is no connection of a vertex in the moving level with 
##  another level with which it is interchanged.
##  So <levelparam> is compared with all levelparams between the old and
##  the new position. If there is a contradiction nothing happens and the
##  method returns fail. If everything works the operation returns true.
##  This operation already exists in {\XGAP} for graphic objects.
##
InstallOtherMethod( MoveLevel,
    "for a graphic poset, an object, and an integer",
    true,
    [ IsGraphicPosetRep, IsObject, IsInt ],
    0,

function( poset, levelparam, position )
  local   lp,  i,  compare,  cl,  v,  v2,  p,  list;
  # nonsense position?
  if position < 1 or position > Length(poset!.levels) then
    return fail;
  fi;
  
  # does level exist?
  lp := Position(poset!.levelparams,levelparam);
  if lp = fail then
    return fail;
  fi;
  
  # nothing to do?
  if position = lp then
    return true;  # we are done
  fi;
  
  if position < lp then   # move level UP
    # check with partial ordering:
    for i in [position..lp-1] do
      compare := CompareLevels(poset,poset!.levelparams[i],levelparam);
      if compare <> fail and compare < 0 then
        # that would contradict the partial order
        return fail;
      fi;
    od;
    
    # now check vertices:
    for cl in poset!.levels[lp]!.classes do
      for v in cl do
        for v2 in v!.maximalin do
          p := Position(poset!.levelparams,v2!.levelparam);
          if p >= position then  # < lp is a MUST!
            return fail;
          fi;
        od;
      od;
    od;
    
    # OK, we can do it:
    FastUpdate(poset,true);
    list := Concatenation([lp],[position..lp-1]);
    poset!.levels{[position..lp]} := poset!.levels{list};
    poset!.levelparams{[position..lp]} := poset!.levelparams{list};
    poset!.levelboxes{[position..lp]} := poset!.levelboxes{list};
    poset!.lptexts{[position..lp]} := poset!.lptexts{list};
    poset!.levels[position]!.top := poset!.levels[position+1]!.top;
    if poset!.showlevels then
      Move(poset!.levelboxes[position],0,poset!.levels[position]!.top 
                                  + poset!.levels[position]!.height - 8);
    fi;
    if poset!.showlevelparams then
      Move(poset!.lptexts[position],poset!.lptexts[position]!.x,
           poset!.levels[position]!.top + 
           QuoInt(poset!.levels[position]!.height,2));
    fi;
    
    for cl in poset!.levels[position]!.classes do
      for v in cl do
        Move(poset,v,v!.x,v!.y);
      od;
    od;
    for i in [position+1..lp] do
      poset!.levels[i]!.top := poset!.levels[i]!.top 
                               + poset!.levels[position]!.height;
      
      if poset!.showlevels then
        Move(poset!.levelboxes[i],0,poset!.levels[i]!.top
                                    + poset!.levels[i]!.height - 8);
      fi;
      if poset!.showlevelparams then
        Move(poset!.lptexts[i],poset!.lptexts[i]!.x,
             poset!.levels[i]!.top + QuoInt(poset!.levels[i]!.height,2));
      fi;
      for cl in poset!.levels[i]!.classes do
        for v in cl do
          Move(poset,v,v!.x,v!.y);
        od;
      od;
    od;
    # in case another one has overwritten our box:
    if poset!.showlevels then
      Draw(poset!.levelboxes[position]);
    fi;
    if poset!.showlevelparams then
      Draw(poset!.lptexts[position]);
    fi;
    FastUpdate(poset,false);
    
    # we did it.
  else   # position > lp, move level DOWN
    # check with partial ordering:
    for i in [lp+1..position] do
      compare := CompareLevels(poset,poset!.levelparams[i],levelparam);
      if compare <> fail and compare > 0 then
        # that would contradict the partial order
        return fail;
      fi;
    od;
    
    # now check vertices:
    for cl in poset!.levels[lp]!.classes do
      for v in cl do
        for v2 in v!.maximals do
          p := Position(poset!.levelparams,v2!.levelparam);
          if p <= position then  # > lp is a MUST!
            return fail;
          fi;
        od;
      od;
    od;
    
    # OK, we can do it:
    FastUpdate(poset,true);
    list := Concatenation([lp+1..position],[lp]);
    poset!.levels{[lp..position]} := poset!.levels{list};
    poset!.levelparams{[lp..position]} := poset!.levelparams{list};
    poset!.levelboxes{[lp..position]} := poset!.levelboxes{list};
    poset!.lptexts{[lp..position]} := poset!.lptexts{list};
    poset!.levels[position]!.top := poset!.levels[position-1]!.top
                                  - poset!.levels[position]!.height
                                    + poset!.levels[position-1]!.height;
    if poset!.showlevels then
      Move(poset!.levelboxes[position],0,poset!.levels[position]!.top
                                       + poset!.levels[position]!.height - 8);
    fi;
    if poset!.showlevelparams then
      Move(poset!.lptexts[position],poset!.lptexts[position]!.x,
           poset!.levels[position]!.top + 
           QuoInt(poset!.levels[position]!.height,2));
    fi;
    for cl in poset!.levels[position]!.classes do
      for v in cl do
        Move(poset,v,v!.x,v!.y);
      od;
    od;
    for i in [lp..position-1] do
      poset!.levels[i]!.top := poset!.levels[i]!.top 
                             - poset!.levels[position]!.height;
      if poset!.showlevels then
        Move(poset!.levelboxes[i],0,poset!.levels[i]!.top
                                           + poset!.levels[i]!.height - 8);
      fi;
      if poset!.showlevelparams then
        Move(poset!.lptexts[i],poset!.lptexts[i]!.x,
             poset!.levels[i]!.top + QuoInt(poset!.levels[i]!.height,2));
      fi;
      for cl in poset!.levels[i]!.classes do
        for v in cl do
          Move(poset,v,v!.x,v!.y);
        od;
      od;
    od;
    # in case another one has overwritten our box:
    if poset!.showlevels then
      Draw(poset!.levelboxes[position]);
    fi;
    if poset!.showlevelparams then
      Draw(poset!.lptexts[position]);
    fi;
    FastUpdate(poset,false);
    
    # we did it.
  fi;
  
  return true;
end);


#############################################################################
##
#M  Relabel(<graph>,<vertex>,<label>)  . . . . . . . . change label of vertex
#M  Relabel(<graph>,<vertex>)  . . . . . . . . . . . . change label of vertex
#M  Relabel(<poset>,<vertex1>,<vertex2>,<label>) . . . . change label of edge
#M  Relabel(<poset>,<vertex1>,<vertex2>) . . . . . . . . change label of edge
##
##  Changes the label of the vertex <vertex> or the edge between <vertex1>
##  and <vertex2>. This must be a short string. In the method where no
##  label is specified the new label is chosen functionally: the operation
##  `ChooseLabel' is called. `Relabel' returns `fail' if an error occurs
##  and `true' otherwise.  This operations already exists in {\XGAP} for
##  graphic objects.
##
InstallOtherMethod( Relabel,
    "for a graphic graph, a vertex, and a string",
    true,
    [ IsGraphicGraphRep, IsGGVertex, IsString ],
    0,

function( graph, vertex, label )
  if label = "" then
    label := false;
  fi;
  # we just call the low level routines:
  vertex!.label := label;
  Relabel(vertex!.obj,label);
end);

InstallOtherMethod( Relabel,
    "for a graphic graph, and a vertex",
    true,
    [ IsGraphicGraphRep, IsGGVertex ],    
    0,
        
function( graph, vertex)
  local label;
  
  label := ChooseLabel( graph, vertex!.data );
  if label = "" then
    label := false;
  fi;
  # we just call the low level routines:
  vertex!.label := label;
  Relabel(vertex!.obj,label);
end);
  
InstallOtherMethod( Relabel,
    "for a graphic poset, two vertices, and a string",
    true,
    [ IsGraphicPosetRep, IsGPVertex, IsGPVertex, IsString ],
    0,

function( poset, v1, v2, label )
  local   p;
  p := Position(v1!.maximals,v2);
  if p = fail then
    p := Position(v2!.maximals,v1);
    if p = fail then
      return fail;
    fi;
  fi;
  # we know now that there is a connection!
  p := Position(v1!.obj!.connections,v2!.obj);
  
  if label = "" then
    label := false;
  fi;
  
  # now we just call the low level routines:
  Relabel(v1!.obj!.connectingLines[p],label);
end);

InstallOtherMethod( Relabel,
    "for a graphic poset, and two vertices",
    true,
    [ IsGraphicPosetRep, IsGPVertex, IsGPVertex ],    
    0,
        
function( poset, v1, v2)
  local   label;
  
  label := ChooseLabel( poset, v1!.data, v2!.data );
  if label = "" then
    label := false;
  fi;
  # we just call the low level routines:
  Relabel(poset,v1,v2,label);
end);
  
  
#############################################################################
##
#M  Move(<graph>,<vertex>,<x>,<y>) . . . . . . . . . . . . . . .  move vertex
#M  Move(<graph>,<vertex>) . . . . . . . . . . . . . . . . . . .  move vertex
##
##  Moves vertex <vertex>. For posets coordinates are relative to the level
##  of the vertex. <vertex> must be a vertex object in <graph>. If no
##  coordinates are specified the operation `ChoosePosition' is
##  called. Returns `fail' if an error occurs and `true' otherwise.  This
##  operations already exists in {\XGAP} for graphic objects.
##
InstallOtherMethod( Move,
    "for a graphic poset, a vertex, and two integers",
    true,
    [ IsGraphicPosetRep, IsGPVertex, IsInt, IsInt ],
    0,

function( poset, vertex, x, y )
  local l;
  
  if x < VERTEX.radius then 
    x := VERTEX.radius;
  elif x > poset!.width-VERTEX.radius then
    x := poset!.width-VERTEX.radius;
  fi;
  l := Position(poset!.levelparams,vertex!.levelparam);
  l := poset!.levels[l];
  if y < VERTEX.radius then
    y := VERTEX.radius;
  elif y > l!.height-VERTEX.radius then
    y := l!.height-VERTEX.radius;
  fi;
  
  vertex!.x := x;
  vertex!.y := y;
  Move(vertex!.obj,x,y+l!.top);
  
  return true;
end);

InstallOtherMethod( Move,
    "for a graphic poset, and a vertex",
    true,
    [ IsGraphicPosetRep, IsGPVertex ],
    0,

function( poset, vertex )
  local position;
  
  position := ChoosePosition(poset, vertex!.data, vertex!.levelparam,
                             vertex!.classparam); 
  Move(poset,vertex,position[1],position[2]);
end);


#############################################################################
##
#M  Reshape(<graph>,<vertex>,<shape>)  . . . . . . . . change shape of vertex
#M  Reshape(<graph>,<vertex>)  . . . . . . . . . . . . change shape of vertex
##
##  Changes the shape of the vertex <vertex>. <vertex> must be a vertex
##  object in the graph or poset <graph>. For the method where no shape is
##  specified the new shape is chosen functionally: `ChooseShape` is called
##  for the corresponding data.  `Reshape' returns `fail' if an error
##  occurs and `true' otherwise.  This operations already exists in {\XGAP}
##  for graphic objects.
##
InstallOtherMethod( Reshape,
    "for a graphic graph, a vertex, and a string",
    true,
    [ IsGraphicGraphRep, IsGGVertex, IsString ],
    0,

function( graph, vertex, shape )
  if shape = "circle" then
    Reshape(vertex!.obj,VERTEX.circle);
  elif shape = "diamond" then
    Reshape(vertex!.obj,VERTEX.diamond);
  else
    Reshape(vertex!.obj,VERTEX.rectangle);
  fi;
  return true;
end);

InstallOtherMethod( Reshape,
    "for a graphic graph, and a vertex",
    true,
    [ IsGraphicGraphRep, IsGGVertex ],
    0,

function( graph, vertex )
  local shape;
  
  shape := ChooseShape( graph, vertex!.data );
  Reshape(graph, vertex, shape);
  return true;
end);


#############################################################################
##
#M  Recolor(<graph>,<vertex>,<color>)  . . . . . . . . change color of vertex
#M  Recolor(<graph>,<vertex>)  . . . . . . . . . . . . change color of vertex
#M  Recolor(<poset>,<vertex1>,<vertex2>,<color>) . .  change color of an edge
#M  Recolor(<poset>,<vertex1>,<vertex2>) . . . . . .  change color of an edge
##
##  Changes the color of the vertex <vertex> or the edge between <vertex1>
##  and <vertex2>. <vertex> must be a vertex object in <graph>. For the
##  method where no color is specified the new color is chosen
##  functionally: `ChooseColor' is called for the corresponding
##  data. `Recolor' returns `fail' if an error occurs and `true'
##  otherwise. This operation already exists in {\XGAP} for graphic objects.
##
InstallOtherMethod( Recolor,
    "for a graphic graph, a vertex, and a color",
    true,
    [ IsGraphicGraphRep, IsGGVertex, IsColor ],
    0,

function( graph, vertex, color )
  Recolor(vertex!.obj,color);
  return true;
end);

InstallOtherMethod( Recolor,
    "for a graphic graph, and a vertex",
    true,
    [ IsGraphicGraphRep, IsGGVertex ],
    0,

function( graph, vertex )
  local color;
  
  color := ChooseColor( graph, vertex!.data );
  Recolor(graph, vertex, color);
  return true;
end);

InstallOtherMethod( Recolor,
    "for a graphic poset, two vertices, and a color",
    true,
    [ IsGraphicPosetRep, IsGPVertex, IsGPVertex, IsColor ],
    0,

function( poset, vertex1, vertex2, color )
  local   p;
  p := Position(vertex1!.maximals,vertex2);
  if p = fail then
    p := Position(vertex2!.maximals,vertex1);
    if p = fail then
      return fail;
    fi;
  fi;
  # we know now that there is a connection!
  p := Position(vertex1!.obj!.connections,vertex2!.obj);
  Recolor(vertex1!.obj!.connectingLines[p],color);
  return true;
end);

InstallOtherMethod( Recolor,
    "for a graphic poset, and two vertices",
    true,
    [ IsGraphicPosetRep, IsGPVertex, IsGPVertex ],
    0,

function( poset, vertex1, vertex2 )
  local   color;
  
  color := ChooseColor( poset, vertex1!.data, vertex2!.data );
  return Recolor(poset, vertex1, vertex2, color);
end);


#############################################################################
##
#M  SetWidth(<graph>,<vertex1>,<vertex2>,<width>) . change line width of edge
#M  SetWidth(<graph>,<vertex1>,<vertex2>) . . . . . change line width of edge
##
##  Changes the line width of an edge. <vertex1> and <vertex2> must be
##  vertices in the graph <graph>. For the method where no line width is
##  specified the width is chosen functionally: `ChooseWidth' is called for
##  the corresponding data pair. Returns `fail' if an error occurs and
##  `true' otherwise. This operation already exists in {\XGAP} for graphic
##  objects.
##
InstallOtherMethod( SetWidth,
    "for a graphic poset, two vertices, and an integer",
    true,
    [ IsGraphicPosetRep, IsGPVertex, IsGPVertex, IsInt ],
    0,

function( poset, vertex1, vertex2, width )
  local   p;
  p := Position(vertex1!.maximals,vertex2);
  if p = fail then
    p := Position(vertex2!.maximals,vertex1);
    if p = fail then
      return fail;
    fi;
  fi;
  # we know now that there is a connection!
  p := Position(vertex1!.obj!.connections,vertex2!.obj);
  SetWidth(vertex1!.obj!.connectingLines[p],width);
  return true;
end);

InstallOtherMethod( SetWidth,
    "for a graphic poset, and two vertices",
    true,
    [ IsGraphicPosetRep, IsGPVertex, IsGPVertex ],
    0,

function( poset, vertex1, vertex2 )
  local   width;
  
  width := ChooseWidth( poset, vertex1!.data, vertex2!.data );
  return SetWidth(poset, vertex1, vertex2, width);
end);


#############################################################################
##
#M  Highlight(<graph>,<vertex>)  . . . . . . . change highlightning of vertex
#M  Highlight(<graph>,<vertex>,<flag>) . . . . change highlightning of vertex
##
##  Changes the highlighting status of the vertex <vertex>. <vertex> must
##  be a vertex object in <graph>. For the method where no flag is
##  specified the new status is chosen functionally: `ChooseHighlight' is
##  called for the corresponding data. Returns `fail' if an error occurs
##  and `true' otherwise. This operation already exists in {\XGAP} for
##  graphic objects.
##
InstallOtherMethod( Highlight,
    "for a graphic graph, a vertex, and a flag",
    true,
    [ IsGraphicGraphRep, IsGGVertex, IsBool ],
    0,

function( graph, vertex, flag )
  Highlight(vertex!.obj,flag);
  return true;
end);

InstallOtherMethod( Highlight,
    "for a graphic graph, and a vertex",
    true,
    [ IsGraphicGraphRep, IsGGVertex ],
    0,

function( graph, vertex )
  local flag;
  
  flag := ChooseHighlight( graph, vertex!.data );
  Highlight(graph, vertex, flag);
  return true;
end);


#############################################################################
##
##  Set this variable temporarily to false if you change many selections!
##
GGSelectModifiesMenu := true;


#############################################################################
##
#M  Select(<graph>,<vertex>,<flag>) . . . . . . . . . . (de-)selects a vertex
#M  Select(<graph>,<vertex>)  . . . . . . . . . . . . . . .  selects a vertex
##
##  Changes the selection state of the vertex <vertex>. <vertex> must be a
##  vertex object in <graph>. The flag determines whether the vertex
##  should be selected or deselected. This operation already exists in
##  {\XGAP} for graphic objects.  The method without flags assumes `true'.
##
InstallOtherMethod( Select,
    "for a graphic graph, a vertex, and a flag",
    true,
    [ IsGraphicGraphRep, IsGGVertex, IsBool ],
    0,
      
function(graph,vertex,flag)
  local   p,  l;
  p := PositionSet(graph!.selectedvertices,vertex);
  if flag then
    if p <> fail then  
      return;
    fi;
    Highlight(graph,vertex,true);
    Recolor(graph,vertex,graph!.color.selected);
    AddSet(graph!.selectedvertices,vertex);
  else
    if p = fail then
      return;
    fi;
    Highlight(graph,vertex,false);
    Recolor(graph,vertex,graph!.color.unselected);
    RemoveSet(graph!.selectedvertices,vertex);
  fi;
  if GGSelectModifiesMenu then
    ModifyEnabled(graph,1,Length(graph!.menus));
  fi;
  return;
end);

InstallOtherMethod( Select,
    "for a graphic graph, and a vertex",
    true,
    [ IsGraphicGraphRep, IsGGVertex ],
    0,
      
function(graph,vertex)
  Select(graph,vertex,true);
end);  


#############################################################################
##
#M  DeselectAll(<graph>) . . . . . . . . . . . . . . . deselects all vertices
##
##  Deselects all vertices in graph.
##
InstallOtherMethod( DeselectAll,
    "for a graphic graph",
    true,
    [ IsGraphicGraphRep ],
    0,
      
function(graph)
  local   v;
  for v in graph!.selectedvertices do
    Highlight(graph,v,false);
    Recolor(graph,v,graph!.color.unselected);
  od;
  graph!.selectedvertices := [];
end);


#############################################################################
##
#M  Selected(<graph>) . . . . . . . . .  returns set of all selected vertices
##
##  Returns a (shallow-)copy of the set of all selected vertices.
##
InstallOtherMethod( Selected,
    "for a graphic graph",
    true,
    [ IsGraphicGraphRep ],
    0,
      
function(graph)
  return ShallowCopy(graph!.selectedvertices);
end);


#############################################################################
##
##  Methods for functional decisions:
##
#############################################################################


#############################################################################
##
#M  CompareLevels(<poset>,<levelp1>,<levelp2>) . . . compares two levelparams
##
##  Compare two levelparams. -1 means that levelp1 is "higher", 1 means
##  that levelp2 is "higher", 0 means that they are equal. fail means that
##  they are not comparable. This method is for the case if level
##  parameters are integers and lower values mean higher levels like in the
##  case of group lattices and subgroup indices.
##
InstallMethod( CompareLevels,
    "for a graphic poset, and two integers",
    true,
    [ IsGraphicPosetRep, IsInt, IsInt ],
    0,

function( poset, l1, l2 )
  if l1 < l2 then
    return -1;
  elif l1 > l2 then
    return 1;
  else
    return 0;
  fi;
end);


#############################################################################
##
#M  ChooseLabel(<graph>,<data>) . . . . . . . is called while vertex creation
#M  ChooseLabel(<graph>,<data>,<data>)  . . . . is called while edge creation
##
##  This operation is called while vertex or edge creation, if the caller 
##  didn't specify a label for the vertex or edge. It has to return a short 
##  string which will be attached to the vertex. If it returns fail the new 
##  vertex is not generated! This method just returns the empty string, so 
##  no label is generated.
##  This method is also called in the Relabel method without label parameter.
##
InstallMethod( ChooseLabel,
    "for a graphic graph, and an object",
    true,
    [ IsGraphicGraphRep, IsObject ],
    0,

function( graph, data )
  return "";
end);

InstallOtherMethod( ChooseLabel,
    "for a graphic graph, and two objects",
    true,
    [ IsGraphicGraphRep, IsObject, IsObject ],
    0,

function( poset, data1, data2 )
  return "";
end);


#############################################################################
##
#M  ChooseLevel(<poset>,<data>) . . . . . . . is called while vertex creation
##
##  This operation is called while vertex creation, if the caller didn't
##  specify a level where the vertex belongs to. It has to return a
##  levelparam which exists in the poset. If it returns fail the new vertex
##  is not generated!
##  This method just chooses the last, lowest level or fail, if there is no 
##  level in the poset.
##
InstallMethod( ChooseLevel,
    "for a graphic poset, and an object",
    true,
    [ IsGraphicPosetRep, IsObject ],
    0,

function( poset, data )
  local l;
  l := Length(poset!.levelparams);
  if l > 0 then
    return poset!.levelparams[Length(poset!.levelparams)];
  else
    return fail;
  fi;
end);


#############################################################################
##
#M  ChooseClass(<poset>,<data>,<levelp>) . .  is called while vertex creation
##
##  This operation is called while vertex creation, if the caller didn't
##  specify a class where the vertex belongs to. It has to return a
##  classparam which exists in the poset in levelp. If it returns fail the
##  new vertex is not generated!
##  This method just generates a new class in the level with classparam one 
##  bigger than the maximum of all (integer) classparams. It returns fail if
##  this maximum is no integer.
##
InstallMethod( ChooseClass,
    "for a graphic graph, and two objects",
    true,
    [ IsGraphicPosetRep, IsObject, IsObject ],
    0,

function( poset, data, levelparam )
  local l,m;
  
  l := Position(poset!.levelparams,levelparam);
  if l = fail then 
    return fail;
  fi;
  l := poset!.levels[l];
  
  if l!.classparams = [] then
    return CreateClass(poset,levelparam,1);
  fi;
    
  m := Maximum(l!.classparams);
  if not IsInt(m) then
    return fail;
  fi;
  
  return CreateClass(poset,levelparam,m+1);
end);
  

#############################################################################
##
#M  ChooseShape(<graph>,<data>) . . . . . . . is called while vertex creation
##
##  This operation is called while vertex creation.
##  It has to return a string out of the following list:
##  "circle", "diamond", "rectangle"
##  If it returns fail the new vertex is not generated!
##  This method just returns "circle".
##
InstallMethod( ChooseShape,
    "for a graphic graph, and an object",
    true,
    [ IsGraphicGraphRep, IsObject ],
    0,

function( graph, data )
  return "circle";
end);


#############################################################################
##
#M  ChooseWidth(<graph>,<data>) . . . . . . . is called while vertex creation
#M  ChooseWidth(<graph>,<data1>,<data2>)  . . . is called while edge creation
##
##  This operation is called while vertex or edge creation.
##  It has to return a line width.
##  If it returns fail the new vertex or edge is not generated!
##  This is also called by the SetWidth operation without width parameter.
##  This method just returns 1.
##
InstallOtherMethod( ChooseWidth,
    "for a graphic graph, and an object",
    true,
    [ IsGraphicGraphRep, IsObject ],
    0,

function( graph, data )
  return 1;
end);

InstallOtherMethod( ChooseWidth,
    "for a graphic graph, and two objects",
    true,
    [ IsGraphicGraphRep, IsObject, IsObject ],
    0,

function( graph, data1, data2 )
  return 1;
end);


#############################################################################
##
#M  ChooseColor(<graph>,<data>) . . . . . . . is called while vertex creation
#M  ChooseColor(<graph>,<data1>,<data2>). . . . is called while edge creation
##
##  This operation is called while vertex or edge creation. It has to return a
##  color. If it returns fail the new vertex is not generated!
##  It is also called in the Recolor method without color parameter.
##  This method just returns black.
##
InstallMethod( ChooseColor,
    "for a graphic graph, and an object",
    true,
    [ IsGraphicGraphRep, IsObject ],
    0,

function( graph, data )
  return COLORS.black;
end);

InstallOtherMethod( ChooseColor,
    "for a graphic graph, and two objects",
    true,
    [ IsGraphicGraphRep, IsObject, IsObject ],
    0,

function( graph, data1, data2 )
  return COLORS.black;
end);


#############################################################################
##
#M  ChooseHighlight(<graph>,<data>) . . . . . is called while vertex creation
##
##  This operation is called while vertex creation. It has to return a
##  flag which indicates, whether the vertex is highlighted or not. If it 
##  returns fail the new vertex is not generated!
##  It is also called in the Highlight method without flag parameter.
##
##  The following method just returns false.
InstallMethod( ChooseHighlight,
    "for a graphic graph, and an object",
    true,
    [ IsGraphicGraphRep, IsObject ],
    0,

function( graph, data )
  return false;
end);


#############################################################################
##
#M  ChoosePosition(<poset>,<data>,<level>,<class>)  . . . . . . . . . . . . . 
#M  ChoosePosition(<graph>,<data>)  . . . . . is called while vertex creation
##
##  This operation is called while vertex creation.  It has to return a
##  list with two integers: the coordinates. For posets those are relative
##  to the level the vertex resides in.  If it returns fail the new vertex
##  is not generated!  
##  This method positions a new vertex in a nonempty class next to the last
##  member in the class and a new vertex in a new class halfway to the
##  right end of the sheet from the rightmost vertex in the level or
##  halfway to the left end of the sheet from the leftmost vertex in the
##  class, depending where there is more space.
##
InstallMethod( ChoosePosition,
    "for a graphic poset, an object, a level object, a list, and a list",
    true,
    [ IsGraphicPosetRep, IsObject, IsGPLevel, IsList, IsList ],
    0,

function( poset, data, level, class, hints )
  local   position,  ranges,  cl,  gaps,  maxindex,  i;
  
  position := [];
  # not first in class:
  if class <> [] then
    # just near the others in the class:
    position[2] := class[Length(class)]!.y;
    position[1] := class[Length(class)]!.x + VERTEX.diameter + 2;
  else
    # collect all x ranges where classes reside:
    ranges := [[0,0]];
    for cl in level!.classes do
      if cl <> [] then
        Add(ranges,[cl[1]!.x-VERTEX.radius,cl[Length(cl)]!.x+VERTEX.radius]);
      fi;
    od;
    Add(ranges,[poset!.width,poset!.width]);
    ranges := Set(ranges);
    gaps := List([1..Length(ranges)-1],x->ranges[x+1][1]-ranges[x][2]);
    
    # search largest gap:
    maxindex := 1;
    for i in [2..Length(gaps)] do
      if gaps[i] > gaps[maxindex] then
        maxindex := i;
      fi;
    od;
    
    position[1] := QuoInt(ranges[maxindex][2]+ranges[maxindex+1][1],2);
    position[2] := QuoInt(level!.height,2);
  fi;
  return position;
end);



#############################################################################
##
##  Methods for getting information:
##
#############################################################################


#############################################################################
##
#M  WhichLevel(<poset>,<y>) . . . . . .  determine level in which position is
##
##  Determines level in which position is. Returns levelparam or fail.
##
InstallMethod( WhichLevel,
    "for a graphic poset, and an integer",
    true,
    [ IsGraphicPosetRep, IsInt ],
    0,

function( poset, y )
  local left, right, look;
  
  if poset!.levels = [] or y < 0 or y >= poset!.height then
    return fail;
  fi;
  
  # we do a binary search:
  left := 1;
  right := Length(poset!.levels);
  while left <= right do
    look := QuoInt(left+right,2);
    if y < poset!.levels[look]!.top then
      right := look-1;
    elif y >= poset!.levels[look]!.top + poset!.levels[look]!.height then
      left := look+1;
    else
      return poset!.levelparams[look];
    fi;
  od;
  
  return fail;
end);


#############################################################################
##
#M  WhichClass(<poset>,<x>,<y>) . . . .  determine class in which position is
##
##  Determines a class with a vertex which contains the position. The first
##  class found is taken.  Returns list with levelparam as first and
##  classparam as second element.  Returns fail if no such class is found.
##
InstallMethod( WhichClass,
    "for a graphic poset, and two integers",
    true,
    [ IsGraphicPosetRep, IsInt, IsInt ],
    0,
        
function(poset, x, y)
  local   lp,  l,  cl,  v;
  
  # first determine the level:
  lp := WhichLevel(poset,y);
  l := Position(poset!.levelparam,l);
  l := poset!.levels[l];
  
  # now search classes:
  for cl in [1..Length(l!.classes)] do
    for v in l!.classes[cl] do
      if [x,y] in v!.obj then
        return [lp,l!.classparams[cl]];
      fi;
    od;
  od;
  
  return fail;
end);


#############################################################################
##
#M  WhichVertex(<graph>,<x>,<y>) . . .  determine vertex in which position is
#M  WhichVertex(<graph>,<data>)  . . . . .  determine vertex with data <data>
#M  WhichVertex(<graph>,<data>,<func>)   . . .  determine vertex functionally
##
##  Determines a vertex which contains the position.  Returns vertex.
##  In the third form the function func must take two parameters "data" and
##  the data entry of a vertex in question. It must return true or false, 
##  according to the right vertex being found or not.
##  The function can for example consider just one record component of
##  data records.
##  Returns fail in case no vertex is found.
##
InstallOtherMethod( WhichVertex,
    "for a graphic poset, and two integers",
    true,
    [ IsGraphicPosetRep, IsInt, IsInt ],
    0,
        
function(poset, x, y)
  local   lp,  l,  cl,  v;
  
  # first determine the level:
  lp := WhichLevel(poset,y);
  l := Position(poset!.levelparams,lp);
  if l = fail then
    return fail;    # not even within a level
  fi;
  l := poset!.levels[l];
  
  # now search classes:
  for cl in [1..Length(l!.classes)] do
    for v in l!.classes[cl] do
      if [x,y] in v!.obj then
        return v;
      fi;
    od;
  od;
  
  return fail;
end);

##  Method for a data object with comparison function:
##
InstallOtherMethod( WhichVertex,
    "for a graphic poset, an object, and a function",
    true,
    [ IsGraphicPosetRep, IsObject, IsFunction ],
    0,
        
function(poset, data, func)
  
  local   lp,  l,  cl,  v;
  
  for lp in [1..Length(poset!.levels)] do
    l := poset!.levels[lp];
    for cl in [1..Length(l!.classes)] do
      for v in l!.classes[cl] do
        if func(data,v!.data) then
          return v;
        fi;
      od;
    od;
  od;
  
  return fail;
end);

##  Method for a data object:
##
InstallOtherMethod( WhichVertex,
    "for a graphic poset, and an object",
    true,
    [ IsGraphicPosetRep, IsObject ],
    0,
        
function(poset, data)
  
  local   lp,  l,  cl,  v;
  
  for lp in [1..Length(poset!.levels)] do
    l := poset!.levels[lp];
    for cl in [1..Length(l!.classes)] do
      for v in l!.classes[cl] do
        if v!.data = data then
          return v;
        fi;
      od;
    od;
  od;
  
  return fail;
end);


#############################################################################
##
#M  WhichVertices(<graph>,<x>,<y>) .  determine vertices in which position is
#M  WhichVertices(<graph>,<data>)  . . .  determine vertices with data <data>
#M  WhichVertices(<graph>,<data>,<func>) . .  determine vertices functionally
##
##  Determines the list of vertices which contain the position. Returns list.
##  In the third form the function func must take two parameters "data" and
##  the data entry of a vertex in question. It must return true or false, 
##  according to the vertex belonging into the result or not.
##  The function can for example consider just one record component of
##  data records.
##  Returns the empty list in case no vertex is found.
##
InstallMethod( WhichVertices,
    "for a graphic poset, and two integers",
    true,
    [ IsGraphicPosetRep, IsInt, IsInt ],
    0,
        
function(poset, x, y)
  local   lp,  l,  cl,  v, res;
  
  # first determine the level:
  lp := WhichLevel(poset,y);
  l := Position(poset!.levelparams,lp);
  if l = fail then
    return fail;    # not even within a level
  fi;
  l := poset!.levels[l];
  
  res := [];
  # now search classes:
  for cl in [1..Length(l!.classes)] do
    for v in l!.classes[cl] do
      if [x,y] in v!.obj then
        Add(res,v);
      fi;
    od;
  od;
  
  return res;
end);

##  Method for a data object with comparison function:
##
InstallOtherMethod( WhichVertices,
    "for a graphic poset, an object, and a function",
    true,
    [ IsGraphicPosetRep, IsObject, IsFunction ],
    0,
        
function(poset, data, func)
  
  local   lp,  l,  cl,  v,  res;
  
  res := [];
  for lp in [1..Length(poset!.levels)] do
    l := poset!.levels[lp];
    for cl in [1..Length(l!.classes)] do
      for v in l!.classes[cl] do
        if func(data, v!.data) then
          Add(res,v);
        fi;
      od;
    od;
  od;
  
  return res;
end);

##  Method for a data object:
##
InstallOtherMethod( WhichVertices,
    "for a graphic poset, and an object",
    true,
    [ IsGraphicPosetRep, IsObject ],
    0,
        
function(poset, data)
  
  local   lp,  l,  cl,  v,  res;
  
  res := [];
  for lp in [1..Length(poset!.levels)] do
    l := poset!.levels[lp];
    for cl in [1..Length(l!.classes)] do
      for v in l!.classes[cl] do
        if v!.data = data then
          Add(res,v);
        fi;
      od;
    od;
  od;
  
  return res;
end);


#############################################################################
##
#M  Levels(<poset>) . . . . . . . . . . . . . returns the list of levelparams
##
##  Returns the list of levelparams in descending order meaning highest to
##  lowest. 
##
InstallMethod( Levels,
    "for a graphic poset",
    true,
    [ IsGraphicPosetRep ],
    0,
        
function(poset)
  return poset!.levelparams;
end);


#############################################################################
##
#M  Classes(<poset>,<levelparam>) . . . . . . returns the list of classparams
##
##  Returns the list of classparams in level levelparam. Returns fail if no
##  level with parameter <levelparam> occurs.
##
InstallMethod( Classes,
    "for a graphic poset, and an object",
    true,
    [ IsGraphicPosetRep, IsObject ],
    0,
        
function(poset, levelparam)
  local l;
  
  l := Position(poset!.levelparams,levelparam);
  if l = fail then
    return fail;
  fi;
  l := poset!.levels[l];
  return l!.classparams;
end);


#############################################################################
##
#M  Vertices(<poset>,<levelparam>,<classparam>)  . . . . . . returns vertices
##
##  Returns the list of vertices in class classparams in level
##  levelparam. Returns fail no level with paramter <levelparam> or no
##  class with parameter <classparam> in the level.
##
InstallMethod( Vertices,
    "for a graphic poset, and two objects",
    true,
    [ IsGraphicPosetRep, IsObject, IsObject ],
    0,
        
function(poset, levelparam, classparam)
  local l, cl;
  
  l := Position(poset!.levelparams,levelparam);
  if l = fail then
    return fail;
  fi;
  l := poset!.levels[l];
  
  cl := Position(l!.classparams,classparam);
  if cl = fail then
    return fail;
  else
    return l!.classes[cl];
  fi;
end);


#############################################################################
##
#M  Maximals(<poset>,<vertex>) . . . . . . . . .  returns maximal subvertices
##
##  Returns the list of maximal subvertices in <vertex>. Returns fail if an
##  error occurs.
##
InstallMethod( Maximals,
    "for a graphic poset, and an object",
    true,
    [ IsGraphicPosetRep, IsObject ],
    0,
        
function(poset, vertex)
  return vertex!.maximals;
end);


#############################################################################
##
#M  MaximalIn(<poset>,<vertex>) . .  returns vertices, in which v. is maximal
##
##  Returns the list of vertices, in which <vertex> is maximal.  Returns
##  fail if an error occurs.
##
InstallMethod( MaximalIn,
    "for a graphic poset, and an object",
    true,
    [ IsGraphicPosetRep, IsObject ],
    0,
        
function(poset, vertex)
  return vertex!.maximalin;
end);


#############################################################################
##
#M  PositionLevel(<poset>,<levelparam>) . . . . . returns y position of level 
##
##  Returns the y position of the level relative to the graphic
##  sheet and the height. Returns fail if no level with parameter 
##  <levelparam> exists.
##
InstallMethod( PositionLevel,
    "for a graphic poset, and an object",
    true,
    [ IsGraphicPosetRep, IsObject ],
    0,
        
function(poset, levelparam)
  local l;
  
  l := Position(poset!.levelparams,levelparam);
  if l = fail then
    return fail;
  fi;
  return [poset!.levels[l]!.top,poset!.levels[l]!.height];
end);



#############################################################################
##
##  Methods for menus and mouseclicks:
##
#############################################################################


#############################################################################
##
#M  InstallPopup(<graph>,<func>) . install function for right click on vertex
##
##  Installs a function that is called if the user clicks with the right
##  button on a vertex. The function gets as parameters:
##   poset,vertex,x,y        (click position)
##
InstallMethod( InstallPopup,
    "for a graphic graph, and a function",
    true,
    [ IsGraphicGraphRep, IsFunction ],
    0,
        
function(graph, func)
  graph!.rightclickfunction := func;
end);


#############################################################################
##
#M  Menu(<graph>,<title>,<entrylist>,<typelist>,<functionslist>) . . new menu
##
##  This operation already exists in {\XGAP} for GraphicSheets.
##  Builts a new Menu but with information about the type of the menu entry.
##  This information describes the relation between the selection state of
##  the vertices and the parameters supplied to the functions. The following 
##  types are supported:
##    "forany"    : always enabled, generic routines don't change anything
##    "forone"    : enabled iff exactly one vertex is selected
##    "fortwo"    : enabled iff exactly two vertices are selected
##    "forthree"  : enabled iff exactly three vertices are selected
##    "forsubset" : enabled iff at least one vertex is selected
##    "foredge"   : enabled iff a connected pair of two vertices is selected
##    "formin2"   : enabled iff at least two vertices are selected
##    "formin3"   : enabled iff at least three vertices are selected
##  The IsMenu object is returned. It is also stored in the sheet.
InstallOtherMethod( Menu,
    "for a graphic graph, a string, a list of strings, a list of strings, and a list of functions",
    true,
    [ IsGraphicGraphRep, IsString, IsList, IsList, IsList ],
    0,
        
function(graph, title, entrylist, typelist, functionslist)
  local   l,  menu,  nr;
  
  l := Filtered([1..Length(entrylist)],
                x->IsBound(entrylist[x]) and (entrylist[x][1] <> '-'));
  menu := Menu(graph,title,entrylist,functionslist);
  Add(graph!.menutypes,typelist{l});
  Add(graph!.menuenabled,List(l,x->true));
  nr := Length(graph!.menuenabled);
  
  ModifyEnabled(graph,nr,nr);
  
  return graph!.menus[nr];
end);


#############################################################################
##
#M  ModifyEnabled(<graph>,<from>,<to>) , . .  modifies enablednes of entries
##
##  Modifies the "Enabledness" of menu entries according to their type and
##  number of selected vertices. <from> is the first menu to work on and
##  <to> the last one (indices). Only IsAlive menus are considered. Returns 
##  nothing.
##  There are two different methods for graphs and posets:  
##
InstallMethod( ModifyEnabled,
    "for a graph, and two integers",
    true,
    [ IsGraphicGraphRep, IsInt, IsInt ],
    0,
        
function(graph, from, to)
  local   len,  i,  j,  flag;
  
  len := Length(graph!.selectedvertices);
  for i in [from..to] do
    if IsAlive(graph!.menus[i]) then
      for j in [1..Length(graph!.menutypes[i])] do
        if graph!.menutypes[i][j] = "forone" then
          flag := len = 1;
        elif graph!.menutypes[i][j] = "fortwo" then
          flag := len = 2;
        elif graph!.menutypes[i][j] = "forthree" then
          flag := len = 3;
        elif graph!.menutypes[i][j] = "forsubset" then
          flag := len >= 1;
        elif graph!.menutypes[i][j] = "foredge" then
          flag := false;
          if len = 2 then
            if Position(graph!.edges,graph!.selectedvertices) <> fail or
               Position(graph!.edges,Reversed(graph!.selectedvertices))
               <> fail then
              flag := true;
            fi;
          fi;
        elif graph!.menutypes[i][j] = "formin2" then
          flag := len >= 2;
        elif graph!.menutypes[i][j] = "formin3" then
          flag := len >= 3;
        else
          flag := true;
        fi;
        if graph!.menuenabled[i][j] <> flag then
          graph!.menuenabled[i][j] := flag;
          Enable(graph!.menus[i]!.entries[j],flag);
        fi;
      od;
    fi;
  od;
end);
  
## Here follows nearly the same but: selected edges are different!
InstallMethod( ModifyEnabled,
    "for a poset, and two integers",
    true,
    [ IsGraphicPosetRep, IsInt, IsInt ],
    0,
        
function(poset, from, to)
  local   len,  i,  j,  flag;
  
  len := Length(poset!.selectedvertices);
  for i in [from..to] do
    if IsAlive(poset!.menus[i]) then
      for j in [1..Length(poset!.menutypes[i])] do
        if poset!.menutypes[i][j] = "forone" then
          flag := len = 1;
        elif poset!.menutypes[i][j] = "fortwo" then
          flag := len = 2;
        elif poset!.menutypes[i][j] = "forthree" then
          flag := len = 3;
        elif poset!.menutypes[i][j] = "forsubset" then
          flag := len >= 1;
        elif poset!.menutypes[i][j] = "foredge" then
          flag := false;
          if len = 2 then
            if Position(poset!.selectedvertices[1]!.maximals,
                        poset!.selectedvertices[2]) <> fail or
               Position(poset!.selectedvertices[2]!.maximals,
                        poset!.selectedvertices[1]) <> fail then
              flag := true;
            fi;
          fi;
        elif poset!.menutypes[i][j] = "formin2" then
          flag := len >= 2;
        elif poset!.menutypes[i][j] = "formin3" then
          flag := len >= 3;
        else   # "forany"
          flag := true;
        fi;
        if poset!.menuenabled[i][j] <> flag then
          poset!.menuenabled[i][j] := flag;
          Enable(poset!.menus[i],poset!.menus[i]!.entries[j],flag);
        fi;
      od;
    fi;
  od;
end);
  

#############################################################################
##
##  Methods for actual user interaction:
##
#############################################################################


#############################################################################
##
#M  PosetLeftClick(poset,x,y) . . . . method which is called after left click
##
##  This method is called when the user does a left click in a poset. It lets
##  the user move, select and deselect vertices or edges.
##  Edges are selected as pair of vertices.
##
InstallMethod(PosetLeftClick,
    "for a graph, and two integers",
    true,
    [ IsGraphicGraphRep, IsInt, IsInt ],
    0,

function(poset,x,y)
  
  local   v,  lp,  lev,  cp,  cl,  list,  minx,  maxx,  storex,  storey,  v2,  
          lno,  line,  limit,  box,  bx,  bw,  by,  bh;
  
  # is this a click on a vertex?
  v := WhichVertex(poset,x,y);
  if v <> fail then
    
    # yes! search for level:
    lp := v!.levelparam;
    lev := poset!.levels[Position(poset!.levelparams,lp)];
    
    # now we search for the class:
    cp := v!.classparam;
    cl := lev!.classes[Position(lev!.classparams,cp)];
    
    # we search for minimum and maximum x coordinates, rel. to mouse:
    list := List(cl,v->v!.x);
    minx := Minimum(list) - x;
    maxx := Maximum(list) - x;
    
    storex := v!.x;
    storey := v!.y;
    
    if Drag(poset,x,y,BUTTONS.left,
            function(x,y) 
              if x + minx < VERTEX.radius then 
                x := VERTEX.radius - minx; 
              elif x + maxx > poset!.width-VERTEX.radius then
                x := poset!.width-VERTEX.radius-maxx;
              fi;
              if y < lev!.top+VERTEX.radius then 
                y := lev!.top + VERTEX.radius; 
              elif y > lev!.top+lev!.height-VERTEX.radius then
                y := lev!.top+lev!.height-VERTEX.radius;
              fi;
	      Move(poset,v,x,y-lev!.top); 
            end) then
      for v2 in cl do
        if v <> v2 then
          Move(poset,v2,v2!.x + v!.x - storex,v2!.y + v!.y - storey);
        fi;
      od;
      # better we redraw:
      DoRedraw(poset);
    else
      DeselectAll(poset);
      Select(poset,v,true);
    fi;
  else  # no click on a vertex, so we drag a box:
    # if this is a poset then we check if somebody clicked on a level box:
    if IsGraphicPosetRep(poset) then
      if poset!.showlevels and x < 8 then
        lno := First([1..Length(poset!.levelboxes)],
                     i->([x,y] in poset!.levelboxes[i]));
        if lno <> fail then
          # user clicked on the levelbox no lno, he can now resize this level
          line := Line(poset,0,y,poset!.width,0);
          if COLORS.blue <> false then
            Recolor(line,COLORS.blue);
          fi;
          limit := poset!.levels[lno]!.top + VERTEX.diameter;
          if Drag(poset,x,y,BUTTONS.left,
                  function(x,y)
                    if y < limit then
                      y := limit;
                    fi;
                    Move(line,0,y);
                  end) then
            # the user moved the line! the new y coordinate is the new lower
            # limit of the level!      
            Delete(poset,line);
            ResizeLevel(poset,poset!.levelparams[lno],line!.y
                              - poset!.levels[lno]!.top);
          else
            Delete(poset,line);
          fi;
          return;
        fi;
      fi;
    fi;
    storex := x;
    storey := y;
    box := Rectangle(poset,x,y,0,0);
    if Drag(poset,x,y,BUTTONS.left,
            function(x,y)
              local bx,by,bw,bh;
              if x < storex then
                bx := x;
                bw := storex - x;
              else
                bx := storex;
                bw := x - storex;
              fi;
              if y < storey then
                by := y;
                bh := storey - y;
              else
                by := storey;
                bh := y - storey;
              fi;
              if bx <> box!.x or by <> box!.y then
                Move(box,bx,by);
              fi;
              if bw <> box!.w or bh <> box!.h then
                Reshape(box,bw,bh);
              fi;
            end) then
      # the box had at one time at least a certain size
      if box!.w > 0 and box!.h > 0 then
        DeselectAll(poset);
        GGSelectModifiesMenu := false;
        for lev in poset!.levels do
          if lev!.top < box!.y+box!.h and 
             lev!.top + lev!.height >= box!.y then
            for cl in lev!.classes do
              for v in cl do
                if [v!.x,v!.y+lev!.top] in box then
                  Select(poset,v,true);
                fi;
              od;
            od;
          fi;
        od;
        GGSelectModifiesMenu := true;
        ModifyEnabled(poset,1,Length(poset!.menus));
      fi;
      Delete(poset,box);
      # better we redraw:
      DoRedraw(poset);
    else  # no moving, so user wants to deselect all vertices
      DeselectAll(poset);
      ModifyEnabled(poset,1,Length(poset!.menus));
      Delete(poset,box);
    fi;   # Drag(...) --> true
  fi;
end);


#############################################################################
##
#M  PosetCtrlLeftClick(poset,x,y) . . method which is called after left click
##
##  This operation is called when the user does a left click in a poset while
##  holding down the control key. It lets the user move, select and deselect
##  vertices or edges. The difference to the operation without the control
##  key is, that while selecting the old vertices are NOT deselected.
##  Moving does not move the whole class but only one vertex. This allows
##  for permuting the vertices within a class.
##  Edges are selected as pair of vertices.
##
InstallMethod(PosetCtrlLeftClick,
    "for a graph, and two integers",
    true,
    [ IsGraphicGraphRep, IsInt, IsInt ],
    0,

function(poset,x,y)
  
  local   v,  lp,  lev,  cp,  cl,  storex,  storey,  lno,  box,  levellen,  
          pos,  bx,  bw,  by,  bh;
  
  # is this a click on a vertex?
  v := WhichVertex(poset,x,y);
  if v <> fail then
    
    # yes! search for level:
    lp := v!.levelparam;
    lev := poset!.levels[Position(poset!.levelparams,lp)];
    
    # now we search for the class:
    cp := v!.classparam;
    cl := lev!.classes[Position(lev!.classparams,cp)];
    
    storex := v!.x;
    storey := v!.y;
    
    if not Drag(poset,x,y,BUTTONS.left,
            function(x,y) 
              if x < VERTEX.radius then 
                x := VERTEX.radius;
              elif x > poset!.width-VERTEX.radius then
                x := poset!.width-VERTEX.radius;
              fi;
              if y < lev!.top+VERTEX.radius then 
                y := lev!.top + VERTEX.radius; 
              elif y > lev!.top+lev!.height-VERTEX.radius then
                y := lev!.top+lev!.height-VERTEX.radius;
              fi;
	      Move(poset,v,x,y-lev!.top); 
            end) then
      Select(poset,v,PositionSet(poset!.selectedvertices,v) = fail);
    else
      # better we redraw:
      DoRedraw(poset);
    fi;
  else  # no click on a vertex, so we drag a box:
    # if this is a poset then we check if somebody clicked on a level box:
    if IsGraphicPosetRep(poset) then
      if poset!.showlevels and x < 8 then
        lno := First([1..Length(poset!.levelboxes)],
                     i->([x,y] in poset!.levelboxes[i]));
        if lno <> fail then
          # user clicked on the levelbox no lno, he can now move this level
          box := Box(poset,4,y-8,8,8);
          if COLORS.red <> false then
            Recolor(box,COLORS.red);
          fi;
          levellen := Length(poset!.levels);
          if Drag(poset,x,y,BUTTONS.left,
                  function(x,y)
                    if y < 8 then
                      y := 8;
                    elif y > poset!.levels[levellen]!.top
                             + poset!.levels[levellen]!.height then
                      y := poset!.levels[levellen]!.top
                           + poset!.levels[levellen]!.height;
                    fi;
                    Move(box,4,y-8);
                  end) then
            # the user moved the box! we have to search in which level lies
            # the new y coordinate:
            pos := First([levellen,levellen-1..1],
                         i->box!.y >= poset!.levels[i]!.top);
            MoveLevel(poset,poset!.levelparams[lno],pos);
          fi;
          Delete(poset,box);
          return;
        fi;
      fi;
    fi;
    storex := x;
    storey := y;
    box := Rectangle(poset,x,y,0,0);
    if Drag(poset,x,y,BUTTONS.left,
            function(x,y)
              local bx,by,bw,bh;
              if x < storex then
                bx := x;
                bw := storex - x;
              else
                bx := storex;
                bw := x - storex;
              fi;
              if y < storey then
                by := y;
                bh := storey - y;
              else
                by := storey;
                bh := y - storey;
              fi;
              if bx <> box!.x or by <> box!.y then
                Move(box,bx,by);
              fi;
              if bw <> box!.w or bh <> box!.h then
                Reshape(box,bw,bh);
              fi;
            end) then
      # the box had at one time at least a certain size
      if box!.w > 0 and box!.h > 0 then
        GGSelectModifiesMenu := false;
        for lev in poset!.levels do
          if lev!.top < box!.y+box!.h and 
             lev!.top + lev!.height >= box!.y then
            for cl in lev!.classes do
              for v in cl do
                if [v!.x,v!.y+lev!.top] in box then
                  Select(poset,v,true);
                fi;
              od;
            od;
          fi;
        od;
        # better we redraw:
        Delete(poset,box);
        DoRedraw(poset);
        GGSelectModifiesMenu := true;
        ModifyEnabled(poset,1,Length(poset!.menus));
      else
        Delete(poset,box);
      fi;
      # Drag(...) --> true    
    else
      Delete(poset,box);
    fi;
  fi;
end);


#############################################################################
##
#M  PosetRightClick(graph,x,y) . . . method which is called after right click
##
##  This method is called when the user does a right click in a graph. 
##  This method just finds the vertex under the mouse pointer and calls the
##  rightclickfunction of the poset. Note that the rightclickfunction
##  can be called with `fail' if no vertex is hit.
##
InstallMethod(PosetRightClick,
    "for a graph, and two integers",
    true,
    [ IsGraphicGraphRep, IsInt, IsInt ],
    0,

function(graph,x,y)
  local   v;
  
  # is this a click on a vertex?
  v := WhichVertex(graph,x,y);
  if graph!.rightclickfunction <> false then
    graph!.rightclickfunction(graph,v,x,y);
  fi;
  return;
end);

  
#############################################################################
##
#M  UserDeleteVerticesOp . . . is called if the user wants to delete vertices
##
##  This operation is called when the user selects "Delete vertices". 
##  The generic method actually deletes the selected vertices including all
##  their edges.
##
InstallMethod( UserDeleteVerticesOp,
    "for a graphic poset, a menu, and a menu entry",
    true,
    [ IsGraphicGraphRep, IsMenu, IsString ],
    0,
        
function( graph, menu, entry )
  local   v;
  
  # it is guaranteed, that at least one vertex is selected!
  while graph!.selectedvertices <> [] do
    Delete(graph,graph!.selectedvertices[1]);
  od;
end);
    

#############################################################################
##
#M  UserDeleteEdgeOp  . . . . . is called if the user wants to delete an edge
##
##  This operation is called when the user selects "Delete edge". 
##  The generic method deletes the edge with no further warning!
##
InstallMethod( UserDeleteEdgeOp,
    "for a graphic graph, a menu, and a menu entry",
    true,
    [ IsGraphicGraphRep, IsMenu, IsString ],
    0,
        
function( graph, menu, entry )
  # it is guaranteed, that exactly two connected vertices are selected!
  Delete(graph,graph!.selectedvertices[1],graph!.selectedvertices[2]);
end);


#############################################################################
##
#M  UserMergeClassesOp (<sheet>, <menu>, <entry>) . . . . . . . . . . . . . .
##  . . . . . . . . . . . . . .  is called if the user wants to merge classes
##
##  This operation is called when the user selects `Merge Classes'.
##  The generic method walks through all levels and merges all classes that
##  contain a selected vertex. Afterwards `UserRearrangeClasses' is called.
##
InstallMethod( UserMergeClassesOp,
    "for a graphic poset, a menu, and a menu entry",
    true,
    [ IsGraphicGraphRep and IsGraphicPosetRep, IsMenu, IsString ],
    0,
        
function( poset, menu, entry )
  local   lps,  verts,  v,  pos,  i,  level,  cps,  cpos,  cls,  j;
  
  # it is guaranteed, that at least one vertex is selected!
  # we walk through the selected vertices and sort them according to their
  # level parameter:
  lps := [];
  verts := [];
  for v in Selected(poset) do
    pos := Position(lps,v!.levelparam);
    if pos = fail then
      Add(lps,v!.levelparam);
      Add(verts,[v]);
    else
      Add(verts[pos],v);
    fi;
  od;
  
  # All levels:
  for i in [1..Length(lps)] do
    # the current level:
    level := poset!.levels[Position(poset!.levelparams,lps[i])];
    
    # Now we collect all classes occuring:
    cps := [];
    cpos := [];
    cls := [];
    for v in verts[i] do
      pos := Position(cps,v!.classparam);
      if pos = fail then
        Add(cps,v!.classparam);
        pos := Position(level!.classparams,v!.classparam);
        Add(cpos,pos);
        Add(cls,level!.classes[pos]);
      fi;
    od;
    
    # now we have a list of classes that should be merged:
    # let's move all vertices into the first class:
    for j in [2..Length(cls)] do
      for v in cls[j] do
        v!.classparam := cps[1];
        Add(cls[1],v);
      od;
    od;
    
    # now we have to delete the other classes (but not their vertices!):
    cpos := cpos{[2..Length(cps)]};
    Sort(cpos);
    for j in [Length(cpos),Length(cpos)-1..1] do
      level!.classes[cpos[j]] := level!.classes[Length(level!.classes)];
      Unbind(level!.classes[Length(level!.classes)]);
      level!.classparams[cpos[j]] := 
        level!.classparams[Length(level!.classparams)];
      Unbind(level!.classparams[Length(level!.classparams)]);
    od;
  od;
  
  # At last we rearrange those classes:
  UserRearrangeClasses( poset, menu, "Rearrange Classes" );    
end);


#############################################################################
##
## This is used by the following three methods:
##
BindGlobal("PosetScaleLattice",function(poset,factorx,factory)
  local   l,  pos,  cl,  v,  newx,  newy,  diffx,  diffy;
  
  FastUpdate(poset,true);  
  Resize(poset, Int(poset!.width*factorx), Int(poset!.height*factory));
  for l in [1..Length(poset!.levelparams)] do
    pos := PositionLevel(poset,poset!.levelparams[l]);
    ResizeLevel(poset,poset!.levelparams[l],Int(pos[2]*factory));
    for cl in poset!.levels[l]!.classes do
      if cl <> [] then
        v := cl[1];
        newx := Int(v!.x*factorx);
        newy := Int(v!.y*factory);
        diffx := newx - v!.x;
        diffy := newy - v!.y;
        for v in cl do
          Move(poset,v,v!.x + diffx,v!.y + diffy);
        od;
      fi;
    od;
  od;
  FastUpdate(poset,false);
end);


#############################################################################
##
#M  UserMagnifyLattice . . . . . .  lets the user magnify the graphic lattice
##
##  This operation is called when the user selects "Magnify Lattice". 
##  The generic method scales everything by 144/100 including the sheet,
##  all heights of levels and positions of vertices.
##
InstallMethod( UserMagnifyLattice,
    "for a graphic poset, a menu, and a string",
    true,
    [ IsGraphicPosetRep, IsMenu, IsString ],
    0,
    
function(poset, menu, entry)
  local   l,  pos,  cl,  v;
  PosetScaleLattice(poset,144/100,144/100);
end);


#############################################################################
##
#M  UserShrinkLattice . . . . . . .  lets the user shrink the graphic lattice
##
##  This operation is called when the user selects "Shrink Lattice". 
##  The generic method scales everything by 100/144 including the sheet,
##  all heights of levels and positions of vertices.
##
InstallMethod( UserShrinkLattice,
    "for a graphic poset, a menu, and a string",
    true,
    [ IsGraphicPosetRep, IsMenu, IsString ],
    0,
    
function(poset, menu, entry)
  local   l,  pos,  cl,  v;
  PosetScaleLattice(poset,100/144,100/144);
end);

##
## Make a rational number from a string, accept fraction:
##
BindGlobal("PosetRatString",
  function( st )
    local n,d,p;
    p := Position( st, '/' );
    if p = fail then
      return Int(st);
    else
      n := Int(st{[1..p-1]});
      d := Int(st{[p+1..Length(st)]});
      if d <> 0 then
        return n/d;
      else
        return infinity;
      fi;
    fi;
  end);
  
##
## Extracts two factors out of a string:
##
BindGlobal("PosetFactorsString", 
  function( factor )
    local   p,  x,  y;

    # find ","
    p := Position( factor, ',' );
    if p = fail  then
        x := PosetRatString(factor);
        y := x;
    elif p = 1  then
        x := 1;
        y := PosetRatString(factor{[2..Length(factor)]});
    elif p = Length(factor)  then
        x := PosetRatString(factor{[1..p-1]});
        y := 1;
    else
        x := PosetRatString(factor{[1..p-1]});
        y := PosetRatString(factor{[p+1..Length(factor)]});
    fi;
    if x <= 0  then x := 1;  fi;
    if y <= 0  then y := 1;  fi;
    return [ x, y ];
  end);


#############################################################################
##
#M  UserResizeLattice . . . . . . .  lets the user resize the graphic lattice
##
##  This operation is called when the user selects "Resize Lattice". 
##  The generic method asks the user for a x and a y factor and scales
##  everything including the sheet, all heights of levels and positions of 
##  vertices.
##
InstallMethod( UserResizeLattice,
    "for a graphic poset, a menu, and a string",
    true,
    [ IsGraphicPosetRep, IsMenu, IsString ],
    0,
    
function(poset, menu, entry)
  local   res,  fac;
  
  res := Query( Dialog( "OKcancel", "X,Y factors" ) );
  if res = false or 0 = Length(res)  then
    return;
  fi;
  fac := PosetFactorsString(res);
  if fac[1] <> 1 or fac[2] <> 1 then
    PosetScaleLattice(poset,fac[1],fac[2]);
  fi;
end);


#############################################################################
##
#M  UserResizeSheet . . . . . . . . .  lets the user resize the graphic sheet
##
##  This operation is called when the user selects "Resize Sheet". 
##  The generic method asks the user for a x and a y pixel number and
##  changes the width and height of the sheet. No positions of levels and
##  vertices are changed. If the user asks for trouble he gets it!
##
InstallMethod( UserResizeSheet,
    "for a graphic graph, a menu, and a string",
    true,
    [ IsGraphicGraphRep, IsMenu, IsString ],
    0,
    
function(poset, menu, entry)
  local   res,  pix,  oldwidth,  t;
  res := Query( Dialog( "OKcancel", "New Width,Height" ) );
  if res = false or 0 = Length(res)  then
    return;
  fi;
  pix := PosetFactorsString(res);
  if pix[1] = 1 then
    pix[1] := poset!.width;
  fi;
  if pix[2] = 1 then
    pix[2] := poset!.height;
  fi;
  
  oldwidth := poset!.width;
  
  Resize(poset,pix[1],pix[2]);
  
  # we now have to move the texts of levelparameters if it is a poset:
  if IsGraphicPosetRep(poset) and poset!.showlevelparams then
    for t in [1..Length(poset!.levels)] do
      MoveDelta(poset!.lptexts[t],poset!.width-oldwidth,0);
    od;
  fi;
end);


#############################################################################
##
#M  UserMoveLattice . . . . . . . . . . . . . lets the user move all vertices
##
##  This operation is called when the user selects "Move Lattice". 
##  The generic method asks the user for a pixel number and
##  changes the position of all vertices horizontally. No positions of 
##  levels are changed. 
##
InstallMethod( UserMoveLattice,
    "for a graphic poset, a menu, and a string",
    true,
    [ IsGraphicGraphRep and IsGraphicPosetRep, IsMenu, IsString ],
    0,
    
function(poset, menu, entry)
  local   res,  pix,  l,  cl,  v;
  res := Query( Dialog( "OKcancel", "Move horizontally" ) );
  if res = false or 0 = Length(res)  then
    return;
  fi;
  pix := Int(res);
  if pix <> 0 then
    for l in poset!.levels do
      for cl in l!.classes do
        for v in cl do
          Move(poset,v,v!.x+pix,v!.y);
        od;
      od;
    od;
  fi;
end);


#############################################################################
##
#M  UserChangeLabels . . . . . . . .  lets the user change labels of vertices
##
##  This operation is called when the user selects "Change Labels". 
##  The user is prompted for every selected vertex, which label it should
##  have.
##
InstallMethod( UserChangeLabels,
    "for a graphic graph, a menu, and a string",
    true,
    [ IsGraphicGraphRep, IsMenu, IsString ],
    0,
        
function(graph, menu, entry)
  local   D,  sel,  v,  res;
  
  D := Dialog("OKcancel", "Label");
  sel := Selected(graph);
  for v in sel do
    res := Query(D,v!.label);
    if res = false then
      return;
    fi;
    if 0 < Length(res) then
      Relabel(graph,v,res);
    fi;
  od;
end);


#############################################################################
##
#M  UserAverageY . . . . . . . . .  average all y positions within all levels
##
##  This operation is called when the user selects ``Average Y Positions''.
##  In all level the average y coordinate is calculated and all vertices are
##  moved to this y position.
##
InstallMethod( UserAverageY,
    "for a graphic poset, a menu, and a string",
    true,
    [ IsGraphicSheet and IsGraphicGraphRep and IsGraphicPosetRep,
      IsMenu, IsString ],
    0,
function( poset, menu, string )
  local   lev,  av,  n,  cl,  v;
  for lev in poset!.levels do
    av := 0;
    n := 0;
    for cl in lev!.classes do
      for v in cl do
        av := av + v!.y;
        n := n + 1;
      od;
    od;
    if n > 0 then
      av := QuoInt(av,n);
      for cl in lev!.classes do
        for v in cl do
          Move(poset,v,v!.x,av);
        od;
      od;
    fi;
  od;
end);


#############################################################################
##
#M  UserAverageX . . . . . . . . . . average all x positions of sel. vertices
##
##  This operation is called when the user selects ``Average X Positions''.
##  The average of all x coordinates of the selected vertices is calculated.
##  Then all classes with a selected vertex are moved such that the first
##  selected vertex in this class has the calculated position as x position.
##
InstallMethod( UserAverageX,
    "for a graphic poset, a menu, and a string",
    true,
    [ IsGraphicSheet and IsGraphicGraphRep and IsGraphicPosetRep,
      IsMenu, IsString ],
    0,
function( poset, menu, string )
  local   sel,  av,  list,  v,  pair,  vertices,  diff;
  sel := Selected(poset);
  # we have at least one selected vertex!
  av := 0;
  list := [];   # we store all levelparam/classparam pairs
  for v in sel do
    av := av + v!.x;
    AddSet(list,[v!.levelparam,v!.classparam]);
  od;
  av := QuoInt(av,Length(sel));
  
  FastUpdate(poset,true);
  for pair in list do
    vertices := Vertices(poset,pair[1],pair[2]);
    if vertices <> fail then
      v := First(vertices,x->x in sel);
      if v <> fail then
        diff := av - v!.x;
        for v in vertices do
          Move(poset,v,v!.x + diff,v!.y);
        od;
      fi;
    fi;
  od;
  FastUpdate(poset,false);
end);

  
#############################################################################
##
#M  UserRearrangesClasses . . . . . . . . . . rearrange vertices within class
##
##  This operation is called when the user selects ``Rearrange Classes''.
##  All classes with a selected vertex are rearranged: The vertices are
##  lined up neatly one after the other, sorted according to their current
##  x position.
##
InstallMethod( UserRearrangeClasses,
    "for a graphic poset, a menu, and a string",
    true,
    [ IsGraphicSheet and IsGraphicGraphRep and IsGraphicPosetRep,
      IsMenu, IsString ],
    0,
function( poset, menu, string )
  local   sel,  av,  list,  v,  pair,  vlist,  xlist,  perm,  i;
  
  sel := Selected(poset);
  # we have at least one selected vertex!
  av := 0;
  list := [];   # we store all levelparam/classparam pairs
  for v in sel do
    AddSet(list,[v!.levelparam,v!.classparam]);
  od;
  
  FastUpdate(poset,true);
  for pair in list do
    # get the vertices in class:
    vlist := Vertices(poset,pair[1],pair[2]);
    if vlist <> fail then
      xlist := List(vlist,y->y!.x);
      perm := Sortex(xlist);
      vlist := Permuted(vlist,perm);
      for i in [2..Length(vlist)] do
        Move(poset,vlist[i],vlist[1]!.x + (i-1)*(VERTEX.diameter+2),
             vlist[1]!.y);
      od;
    fi;
  od;
  FastUpdate(poset,false);
end);


############################################################################
##
#M  UserUseBlackWhite . . . . . . . . . .  called if user selects bw in menu
##
##  This is called if the user selects ``Use Black and White'' in the menu.
##
InstallMethod( UserUseBlackWhite,
    "for a graphic graph, a menu, and a string",
    true,
    [ IsGraphicSheet and IsGraphicGraphRep, IsMenu, IsString ],
    0,
function( sheet, menu, entry )
  local   v;
  if sheet!.color.model = "monochrome" then
    sheet!.color.model := "color";
    Check(menu,entry,false);  
  else
    sheet!.color.model := "monochrome";
    Check(menu,entry,true);  
  fi;
  GPMakeColors(sheet);
  for v in Selected(sheet) do
    Recolor(sheet,v,sheet!.color.selected);
  od;
end);


#############################################################################
##
#M  PosetShowLevels  . . . . . . . . . . . . . . . . switch display of levels
##
##  This operation is called when the user selects "Show Levels" in the menu.
##  Switches the display of the little boxes for level handling on and off.
##
InstallMethod( PosetShowLevels,
    "for a graphic poset, a menu, and a menu entry",
    true,
    [ IsGraphicPosetRep, IsMenu, IsString ],
    0,
        
function( poset, menu, entry )
  local   b;
  poset!.showlevels := not(poset!.showlevels);
  if poset!.showlevels then
    for b in [1..Length(poset!.levelboxes)] do
      Revive(poset!.levelboxes[b]);
      Move(poset!.levelboxes[b],0,poset!.levels[b]!.top
                                  +poset!.levels[b]!.height-8);
    od;
  else
    for b in poset!.levelboxes do
      Destroy(b);
    od;
  fi;
  Check(menu,entry,poset!.showlevels);
end);


#############################################################################
##
#M  PosetShowLevelparams . . . . . . . . .  switch display of levelparameters
##
##  This operation is called when the user selects "Show Levelparameters" in 
##  the menu. Switches the display of the level parameters at the right of
##  the screen on and off.
##
InstallMethod( PosetShowLevelparams,
    "for a graphic poset, a menu, and a menu entry",
    true,
    [ IsGraphicPosetRep, IsMenu, IsString ],
    0,
        
function( poset, menu, entry )
  local   t;
  poset!.showlevelparams := not(poset!.showlevelparams);
  if poset!.showlevelparams then
    for t in [1..Length(poset!.lptexts)] do
      Revive(poset!.lptexts[t]);
      Move(poset!.lptexts[t],poset!.lptexts[t]!.x,poset!.levels[t]!.top
                                  +QuoInt(poset!.levels[t]!.height,2));
    od;
  else
    for t in poset!.lptexts do
      Destroy(t);
    od;
  fi;
  Check(menu,entry,poset!.showlevelparams);
end);


#############################################################################
##
#M  DoRedraw(<graph>). . . . . . . . . . redraws all vertices and connections
##
##  Redraws all vertices and connections.
##
InstallMethod( DoRedraw,
    "for a graphic poset",
    true,
    [ IsGraphicPosetRep ],
    0,

function(poset)
  local   lev,  cl,  v,  v2,  pos;
  
  for lev in poset!.levels do
    for cl in lev!.classes do
      for v in cl do
        Draw(v!.obj);
        for v2 in v!.maximals do
          pos := Position(v!.obj!.connections,v2!.obj);
          if pos <> fail then
            Draw(v!.obj!.connectingLines[pos]);
          fi;
        od;
      od;
    od;
  od;
end);


#############################################################################
##
##  Some things that don't fit in other sections:
##
#############################################################################

##
##  We want Position and PositionSorted for lists of vertices:
##
InstallMethod( EQ, "for two vertices", true, [IsGGVertex,IsGGVertex],0,
        IsIdenticalObj );
InstallMethod( \<, "for two vertices", true, [IsGGVertex,IsGGVertex],0,
        function(a,b) return (a!.serial < b!.serial); end);
InstallMethod( EQ, "for two levels", true, [IsGPLevel,IsGPLevel],0,
        IsIdenticalObj );
        
##
##  ViewObj methods:
##
InstallMethod( ViewObj,"for a graphic graph",true,
        [IsGraphicSheet and IsGraphicSheetRep and IsGraphicGraphRep],
        0,function( sheet ) 
  Print("<");
  if not IsAlive(sheet) then
    Print("dead ");
  fi;
  Print("graphic graph \"",sheet!.name,"\">");
end);
  
InstallMethod( ViewObj,"for a graphic poset",true,
        [IsGraphicSheet and IsGraphicSheetRep and IsGraphicGraphRep and 
         IsGraphicPosetRep],
        0,function( sheet ) 
  Print("<");
  if not IsAlive(sheet) then
    Print("dead ");
  fi;
  Print("graphic poset \"",sheet!.name,"\">");
end);
  
InstallMethod( ViewObj,"for a level",true,
        [IsGraphicObject and IsGPLevel],
        0,function( level ) 
  local   pos;
  pos := Position(level!.poset!.levels,level);
  Print("<level of graphic poset \"",level!.poset!.name,"\", Parameter: ",
        level!.poset!.levelparams[pos],">");
end);

InstallMethod( ViewObj,"for a vertex",true,
        [IsGraphicObject and IsGGVertex],
        0,function( vertex ) 
  Print("<vertex of graphic graph, label: \"",vertex!.label,"\", Serial:",
        vertex!.serial,">");
end);

## FIXME: ... TODO-List for graphs:
        
# comments for GraphicGraphRep
# generic Graph Menu with at least Redraw, probably Deletes also
#M  GraphicGraph( <name>, <width>, <height> ) . . . . . . a new graphic graph
#M  Vertex(<graph>,<data>[,<inf>]) . . . . . . . . . . . . creates new vertex
#M  Edge(<graph>,<vertex1>,<vertex2>) . . . . . . . . . . . . adds a new edge
#M  Edge(<graph>,<vertex1>,<vertex2>,<def>) . . . . . . . . . adds a new edge
#M  Delete(<graph>,<obj>) . . . . . . . . . . . . . remove something in graph
#M  Move(<graph>,<vertex>,<x>,<y>) . . . . . . . . . . . . . . .  move vertex
#M  Move(<graph>,<vertex>) . . . . . . . . . . . . . . . . . . .  move vertex
#M  SetWidth(<graph>,<vertex1>,<vertex2>,<width>) . change line width of edge
#M  SetWidth(<graph>,<vertex1>,<vertex2>) . . . . . change line width of edge
#M  ChooseLabel(<graph>,<data>,<data>)  . . . . is called while edge creation
#M  ChoosePosition(<graph>,<data>)  . . . . . is called while vertex creation
#M  WhichVertex(<graph>,<x>,<y>) . . .  determine vertex in which position is
#M  WhichVertex(<graph>,<data>)  . . . . .  determine vertex with data <data>


