#############################################################################
##
#W  show.gi
##
##  Contains implementations of standard functions for outputting objects
##  to streams.
##
##  These functions should replace all the View/Print/Display variants, and
##  in particular get rid of a lot of code duplication, when there are separate
##  implementations for ViewObj and ViewString for instance, and lack of
##  implementations when ViewObj exists, but ViewString doesn't (probably for
##  the reason above)
##
##  Output streams will be free to ignore/strip formatting helpers
##
##  The naming is still topic of discussion. I renamed Print to Code, because
##  this makes the requirement to output Code clearer.
##

############################################################################
##
#O  ViewObj(<stream>, <obj>)
##
InstallMethod(ViewObj, "for an output stream, and an object",
              [IsOutputStream, IsObject],
function(stream, obj)
    PrintTo(stream, ViewString(obj));
end);

# A possible implementation for ViewString
# (once ViewObj with a stream parameter is the default)
NewViewString := function(obj)
   local res, stream;
   res := "";
   stream := OutputTextString(res, true);
   ViewObj(stream, obj);
   return res;
end;

# A possible implementation for View if ViewObj has a method installed
NewViewObj := function(obj)
    local stream;
    stream := OutputTextFile("*stdout*", true);
    ViewObj(stream, obj);
    CloseStream(stream);
end;

############################################################################
##
#O  DisplayObj(<stream>, <obj>)
##
InstallMethod(DisplayObj, "for an output stream, and an object",
              [IsOutputStream, IsObject],
function(stream, obj)
    PrintTo(stream, DisplayString(obj));
end);

############################################################################
##
#O  CodeObj(<stream>, <obj>)
##
InstallMethod(CodeObj, "for an output stream, and an object",
              [IsOutputStream, IsObject],
function(stream, obj)
    PrintTo(stream, String(obj));
end);

############################################################################
##
#E

