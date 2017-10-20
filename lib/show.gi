#############################################################################
##
#W  show.gi
##
##  Contains implementations of standard functions for outputting objects
##  to streams.
##
##  These functions should replace all the View/Print/Display variants, and
##  in particular get rid of a lot of code duplication, when there are separate
##  implementations for View and ViewString for instance, and lack of
##  implementations when View exists, but ViewString doesn't (probably for the
##  reason above)
##
##  output streams will be free to ignore/strip formatting helpers
##
##  The naming is still topic of discussion. I renamed Print to Code, because
##  this makes the requirement to output Code clearer.
##

############################################################################
##
#O  ViewObjStream(<stream>, <obj>)
##
InstallMethod(ViewObjStream, "for an output stream, and an object",
              [IsOutputStream, IsObject],
function(stream, obj)
    PrintTo(stream, ViewString(obj));
end);

# A possible implementation for ViewString
# (once ViewObjStream is the default)
NewViewString := function(obj)
   local res, stream;
   res := "";
   stream := OutputTextString(res, true);
   ViewObjStream(stream, obj);
   return res;
end;

# A possible implementation for View if ViewObjStream has a method installed
NewView := function(obj)
    local stream;
    stream := OutputTextFile("*stdout*", true);
    ViewObjStream(stream, obj);
end;

############################################################################
##
#O  DisplayObjStream(<stream>, <obj>)
##
InstallMethod(DisplayObjStream, "for an output stream, and an object",
              [IsOutputStream, IsObject],
function(stream, obj)
    PrintTo(stream, DisplayString(obj));
end);

############################################################################
##
#O  CodeObjStream(<stream>, <obj>)
##
InstallMethod(CodeObjStream, "for an output stream, and an object",
              [IsOutputStream, IsObject],
function(stream, obj)
    PrintTo(stream, String(obj));
end);

############################################################################
##
#E

