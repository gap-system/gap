#############################################################################
##
#A  init.g                  GAPDoc              Frank Lübeck / Max Neunhöffer
##
#H  @(#)$Id: init.g,v 1.17 2007/10/04 22:02:12 gap Exp $
##
#Y  Copyright (C)  2000,  Frank Lübeck and Max Neunhöffer,  
#Y  Lehrstuhl D für Mathematik,  RWTH Aachen
##

ReadPackage("GAPDoc", "lib/UnicodeTools.gd");
ReadPackage("GAPDoc", "lib/PrintUtil.gd");
ReadPackage("GAPDoc", "lib/Text.gd");
ReadPackage("GAPDoc", "lib/ComposeXML.gd");
ReadPackage("GAPDoc", "lib/XMLParser.gd");
ReadPackage("GAPDoc", "lib/GAPDoc.gd");
ReadPackage("GAPDoc", "lib/BibTeX.gd");
ReadPackage("GAPDoc", "lib/BibXMLextTools.gd");
ReadPackage("GAPDoc", "lib/GAPDoc2LaTeX.gd");
ReadPackage("GAPDoc", "lib/GAPDoc2Text.gd");
ReadPackage("GAPDoc", "lib/GAPDoc2HTML.gd");
ReadPackage("GAPDoc", "lib/Make.g");
ReadPackage("GAPDoc", "lib/Examples.gd");

# The handler functions for GAP's help system are read now:
ReadPackage("GAPDoc", "lib/HelpBookHandler.g");

# try to find terminal encoding
GAPInfo.tmpfunc := function()
  local env, pos, enc, a;
  # we leave the GAPInfo.TermEncodingOverwrite for .gaprc
  # for a moment, but don't document it - doesn't work with 
  # loaded workspaces
  if not IsBound(GAPInfo.TermEncodingOverwrite) then
    if IsList(GAPInfo.SystemEnvironment) then
      # for compatibility with GAP 4.4.
      env := rec();
      for a in GAPInfo.SystemEnvironment do
        pos := Position(a, '=');
        env.(a{[1..pos-1]}) := a{[pos+1..Length(a)]};
      od;
    else
      env := GAPInfo.SystemEnvironment;
    fi;
    enc := fail;
    if IsBound(env.LC_CTYPE) then
      enc := env.LC_CTYPE;
    fi;
    if enc = fail and IsBound(env.LC_ALL) then
      enc := env.LC_ALL;
    fi;
    if enc = fail and IsBound(env.LANG) then
      enc := env.LANG;
    fi;
    if enc <> fail and 
                   (PositionSublist(enc, ".UTF-8") <> fail  or
                    PositionSublist(enc, ".utf8") <> fail) then
      GAPInfo.TermEncoding := "UTF-8";
    fi;
    if not IsBound(GAPInfo.TermEncoding) then
      # default is latin1
      GAPInfo.TermEncoding := "ISO-8859-1";
    fi;
  else
    GAPInfo.TermEncoding := GAPInfo.TermEncodingOverwrite;
  fi;
end;
GAPInfo.tmpfunc();
Add(POST_RESTORE_FUNCS, GAPInfo.tmpfunc);
Unbind(GAPInfo.tmpfunc);
