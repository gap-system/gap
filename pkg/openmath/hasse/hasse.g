###########################################################################
##
#W  hasse/hasse.g       OpenMath Package                     Andrew Solomon
#W                                                         Marco Costantini
##
#Y  Copyright (C) 1999, 2000, 2001, 2006
#Y  School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  This file contains the function for drawing Hasse diagrams
##


###########################################################################
##
#P IsHasseDiagram
##
## Hasse diagram GAP definitions.
##

DeclareProperty("IsHasseDiagram", IsBinaryRelation);

###########################################################################
## Return the Hasse Diagram of a partial order.
##

HasseDiagram := function(rel)
	local h;
	h :=  HasseDiagramBinaryRelation(rel);
	SetIsHasseDiagram(h,true);
	return h;
end;



# f is a list of elements, le is the comparison function
CreateHasseDiagram := function(f, le)
  local rel, lc, tups, i, j, IsMinimalInList, MinElts, EltCovers, ListCovers;


 # true iff x is the only element of list which divides x
 IsMinimalInList := function(x, list, le)
   local i;

   for i in list do
     if le(i, x) and x <> i then
       return false;
     fi;
   od;
   return true;
 end;


 ## return the minimal elements of a list under le
 MinElts := function(list, le)
   local i;

   return Filtered(list, x->IsMinimalInList(x, list, le));
 end;


 ## for x in list, return the elements which cover it under le
 EltCovers := function(list, x, le)
   local xunder;

   xunder := Filtered(list, y->le(x,y) and y <> x);
   return MinElts(xunder,le);
 end;


 ## for a list, return the set of pairs, x, covers(x)
 ListCovers := function(list,le)
   return List(list, x->[x, EltCovers(list, x, le)]);
 end;


  lc := ListCovers(f, le);
  tups := [];
  for i in lc do
    for j in i[2] do
      Append(tups, [Tuple([i[1], j])]);
    od;
  od;
  rel := BinaryRelationByElements(Domain(f), tups);
  SetIsHasseDiagram(rel, true);
  return rel;
end;


BindGlobal( "OMDirectoryTemporary", DirectoryTemporary() );


BindGlobal("DrawHasse", function(h)

	local output, filename;

	filename := Filename( OMDirectoryTemporary, "nsinput.html" );
	RemoveFile( filename );

	output := OutputTextFile( filename, false ); #append
	SetPrintFormattingStatus( output, false );
	AppendTo(output, TOP_HTML);

	OMPutObject(output,h);
	AppendTo(output, BOTTOM_HTML);
	CloseStream(output);

	Exec(Concatenation(BROWSER_COMMAND, " ", filename, " &"));
end);


###########################################################################
#E

