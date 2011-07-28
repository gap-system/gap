#############################################################################
##
#W  init.g                     ParGAP Package                  Gene Cooperman
#W                                                                Greg Gamble
##
#H  @(#)$Id: init.g,v 1.8 2010/03/10 22:37:26 alexk Exp $
##
#Y  Copyright (C) 1999-2001  Gene Cooperman
#Y    See included file, COPYING, for conditions for copying
##


## MPI_Initialized() is defined only if the ParGAP kernel was built _and_ 
## if the binary was invoked as pargap (symbolic link to gap).

if not IsBound(StringFile) then
  # backward compatibility
  if not IsBound(Chomp) then
    Chomp := function(str)
               if IsString(str) and str <> "" and str[Length(str)] = '\n' then
                 return str{[1..Length(str) - 1]};
               fi;
               return str;
             end;
  fi;
  StringFile := function(filename)
                  local stream, string;
                  stream := InputTextFile(filename);
                  string := ReadAll(stream);
                  CloseStream(stream);
                  return string;
                end;
fi;

if IsBoundGlobal("MPI_Initialized") then
  # GAP must have been invoked as pargapmpi
  DeclareAutoPackage("pargap", 
    Chomp(StringFile(
              Filename(DirectoriesPackageLibrary("pargap",""), "VERSION"))),
    function()
      # SendMsg is defined in lib/slavelist.g
      return ARCH_IS_UNIX() and not IsBoundGlobal("SendMsg");
    end
    );
else
  # GAP must have been invoked as gap
  DeclarePackage("pargap",
    Chomp(StringFile(
              Filename(DirectoriesPackageLibrary("pargap",""), "VERSION"))),
    function()
      Info(InfoWarning, 1,
           "``ParGAP'' should be invoked by the script ",
           "generated during installation.");
      Info(InfoWarning, 1,
           "Type `?Running ParGAP' for more details.");
      return false;
    end
    );
fi;

DeclarePackageAutoDocumentation( "pargap", "doc" );

#E init.g . . . . . . . . . . . . . . . . . . . . . . . . . . . . . ends here
