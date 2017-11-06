#############################################################################
##
#A  init.g                  GAPDoc              Frank Lübeck / Max Neunhöffer
##
##
#Y  Copyright (C)  2000,  Frank Lübeck and Max Neunhöffer,  
#Y  Lehrstuhl D für Mathematik,  RWTH Aachen
##

# An alternative Info handler which does not print implicit "#I " and "\n"
BindGlobal("PlainInfoHandler",
function ( infoclass, level, list )
    local cl, out, s, infoOutput;
    if IsBoundGlobal("InfoOutput") then
      infoOutput := ValueGlobal("InfoOutput");
      out := infoOutput(infoclass);
    else
      cl := InfoData.LastClass![1];
      if IsBound(InfoData.Output[cl]) then
        out := InfoData.Output[cl];
      else
        out := DefaultInfoOutput;
      fi;
    fi;
    if out = "*Print*" then
      for s in list do
        Print(s);
      od;
      Print("\c");
    else
      for s  in list  do
          AppendTo( out, s );
      od;
      AppendTo( out, "\c" );
    fi;
end);

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
  MakeImmutable( GAPInfo.TermEncoding );
end;
GAPInfo.tmpfunc();
Add(GAPInfo.PostRestoreFuncs, GAPInfo.tmpfunc);
Unbind(GAPInfo.tmpfunc);

# In HPCGAP some help system functionality is made available through a
# region `HELP_REGION`. To avoid warnings in GAP4 we bind this variable.
if not IsBound(HELP_REGION) then
  BindGlobal("HELP_REGION", fail);
fi;

# A helper interface function to the GAP help system,
# used for resolving references to other help books.
BindGlobal("GetHelpDataRef", function(info, i)
  local res;
  # the `atomic` wrapper is only relevant in HPCGAP, the lock
  # is needed because the HelpData handler may write some information
  # into the data structures of the help system
  atomic readwrite HELP_REGION do
    res := HELP_BOOK_HANDLER.(info.handler).HelpData(info, i, "ref");
  od;
  return res;
end);
# This is make GAPDoc work with GAP < 4.9, despite the HPCGAP specific code
if not IsBound(CopyToRegion) then
  BindGlobal("CopyToRegion", Immutable("notexisting"));
fi;
