#############################################################################
##
#W    hasse/hasse.g       OpenMath Package             Andrew Solomon
#W                                                     Marco Costantini
##
#H    @(#)$Id: hasse.g,v 1.11 2009/04/18 10:14:10 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##    This file contains the function for drawing Hasse diagrams
##


Revision.("openmath/hasse/hasse.g") :=
    "@(#)$Id: hasse.g,v 1.11 2009/04/18 10:14:10 alexk Exp $";


#########################################################################
##
#P IsHasseDiagram
##
## Hasse diagram GAP definitions.
##

DeclareProperty("IsHasseDiagram", IsBinaryRelation);

##########################################################################
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



#######################################################################
##
#F  OMPutListVar( <stream>, <list> )  
##
##
BindGlobal("OMPutListVar", 
function(stream, x)
  local i;

  OMWriteLine(stream, ["<OMA>"]);
  OMIndent := OMIndent +1;

	OMPutSymbol( stream, "list1", "list" );
	for i in x do
		OMPutVar(stream, i); 
	od;

	OMIndent := OMIndent -1;
	OMWriteLine(stream, ["</OMA>"]);
end);


#######################################################################
##
#M  OMPut( <stream>, <hasse diagram> )
##
## Addendum to GAP OpenMath phrasebook.
##
InstallMethod(OMPut, "for a Hasse diagram", true,
[IsOutputStream,IsHasseDiagram],0,
function(stream, x)
	local d, i;
	d := UnderlyingDomainOfBinaryRelation(x);
	OMWriteLine(stream, ["<OMBIND>"]);
	OMIndent := OMIndent +1;
	OMPutSymbol(stream, "fns2", "constant");
	OMWriteLine(stream, ["<OMBVAR>"]);
	OMIndent := OMIndent +1;
	for i in d do
		OMPutVar(stream, i);
	od;
	OMIndent := OMIndent -1;
	OMWriteLine(stream, ["</OMBVAR>"]);

	OMWriteLine(stream, ["<OMA>"]);
	OMIndent := OMIndent +1;
	OMPutSymbol(stream, "relation2", "hasse_diagram");
	
	for i in d do
		OMWriteLine(stream, ["<OMA>"]);
		OMIndent := OMIndent +1;
		OMPutSymbol(stream, "list1", "list");
		OMPutVar(stream, i);
		OMPutListVar(stream, ImagesElm(x, i));
		OMIndent := OMIndent -1;
		OMWriteLine(stream, ["</OMA>"]);
	od;
	OMIndent := OMIndent -1;
	OMWriteLine(stream, ["</OMA>"]);
	OMIndent := OMIndent -1;
	OMWriteLine(stream, ["</OMBIND>"]);
end);



BindGlobal( "OMDirectoryTemporary", DirectoryTemporary() );


BindGlobal("DrawHasse", 
function(h)

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


#############################################################################
#E

