#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Lübeck.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  The  files  helpview.g{d,i} contain the configuration mechanism  for  the
##  different help viewer.
##

#############################################################################
##
##  the user interface for the help viewer choice
##

#############################################################################
##
#V  HELP_VIEWER_INFO
##
##  This record  contains records  for each  possible help  viewer: each
##  stores the `.type' of the  output data (currently supported: "text",
##  "url", "pdf", "dvi")  and a function `.show' for  showing the output
##  data.
##
##  The  output data  (from  handler.HelpData) must  have the  following
##  form:
##
##  "text":   a format as allowed by `Pager' (usually rec(lines:=text,
##            start:=linenr, formatted:=true))
##
##  "url":    an URL (usually local `file://' URL)
##
##  "dvi":    a filename or a record rec(file:=filename, page:=pagenr)
##            where pagenr is the first page to show
##
##  "pdf":    same as for "dvi"
##

#  The preferred help viewers can be specified via a user preference.
DeclareUserPreference( rec(
  name:= [ "HelpViewers", "XpdfOptions", "XdviOptions" ],
  description:= [
    "Here you can choose your preferred help viewers. See the help for \
<Ref Func=\"SetHelpViewer\"/> for further options.",
    "Try <C>HelpViewers:= [ \"screen\", \"firefox\", \"xpdf\" ];</C>.",
    "(For <C>\"screen\"</C> we also suggest to set the <C>Pager</C> entry \
to <C>\"less\"</C>.)"
    ],
  default:= [ [ "screen" ], "", "" ],
  check:= function( helpviewers, xpdfoptions, xdvioptions )
    return IsList( helpviewers ) and ForAll( helpviewers, IsString )
           and IsString( xpdfoptions ) and IsString( xdvioptions );
    end,
  ) );


# text on screen
HELP_VIEWER_INFO.screen := rec(
type := "text",
show := PagerAsHelpViewer,
);


if ARCH_IS_WINDOWS() then
  # html version on Windows
  HELP_VIEWER_INFO.browser := rec(
  type := "url",
  show := function( filename )
    local pos, winfilename;
    if not StartsWith(filename, "/cygdrive") and
       not StartsWith(filename, "/proc/cygdrive") then
      Error( "the name of the help file ", filename , " must start with /cygdrive or /proc/cygdrive" );
    else
      # Ignoring part of the URL after '#' since we are unable
      # to navigate to the precise location on Windows
      winfilename:=MakeExternalFilename( SplitString( filename, "#" )[1] );
    fi;
    Print( "Opening help page ", winfilename, " in default windows browser ... \c" );
    Exec( Concatenation("start ", winfilename ) );
    Print( "done! \n" );
  end
  );


elif ARCH_IS_MAC_OS_X() then
  # html version using macOS default browser
  HELP_VIEWER_INFO.("mac default browser") := rec (
    type := "url",
    show := function (url)
            Exec ( Concatenation( "osascript <<ENDSCRIPT\n",
                                  "open location \"file://", url, "\"\n",
                                  "ENDSCRIPT\n" ) );
            return;
        end
  );

  HELP_VIEWER_INFO.browser := HELP_VIEWER_INFO.("mac default browser");

  # html version using macOS browser Safari
  HELP_VIEWER_INFO.safari := rec (
    type := "url",
    show := function (url)
            Exec ( Concatenation( "osascript <<ENDSCRIPT\n",
                                  "tell application \"Safari\"\n",
                                  "activate\n",
                                  "open location \"file://", url, "\"\n",
                                  "end tell\n",
                                  "ENDSCRIPT\n" ) );
            return;
        end);

  # html version using macOS browser Firefox
  HELP_VIEWER_INFO.firefox := rec (
    type := "url",
    show := function (url)
            Exec ( Concatenation( "osascript <<ENDSCRIPT\n",
                                  "tell application \"Firefox\"\n",
                                  "activate\n",
                                  "open location \"file://", url, "\"\n",
                                  "end tell\n",
                                  "ENDSCRIPT\n" ) );
            return;
        end);
    HELP_VIEWER_INFO.preview := rec(
        type := "pdf",
        show := function(file)
          local   page;
          # unfortunately one cannot (yet?) give a start page to Preview.app
          # it is currently ignored
          page := 1;
          if IsRecord(file) then
            if IsBound(file.page) then
              page := file.page;
            fi;
            file := file.file;
          fi;
          Exec(Concatenation("open -a Preview ", file));
          Print("#  see page ", page, " in the Preview window.\n");
        end
    );
    HELP_VIEWER_INFO.("adobe reader") := rec(
        type := "pdf",
        show := function(file)
          local   page;
          # unfortunately one cannot (yet?) give a start page to acroread
          # it is currently ignored
          page := 1;
          if IsRecord(file) then
            if IsBound(file.page) then
              page := file.page;
            fi;
            file := file.file;
          fi;
          Exec(Concatenation("open -a \"Adobe Reader\" ", file));
          Print("#  see page ", page, " in the Adobe Reader window.\n");
        end
    );
    HELP_VIEWER_INFO.("pdf viewer") := rec(
        type := "pdf",
        show := function(file)
          local   page;
          # unfortunately one cannot (yet?) give a start page to acroread
          # it is currently ignored
          page := 1;
          if IsRecord(file) then
            if IsBound(file.page) then
              page := file.page;
            fi;
            file := file.file;
          fi;
          Exec(Concatenation("open ", file));
          Print("#  see page ", page, " in the pdf viewer window.\n");
        end
    );
    HELP_VIEWER_INFO.("skim") := rec(
        type := "pdf",
        show := function(file)
            local   page;
            page := 1;
            if IsRecord(file) then
                if IsBound(file.page) then
                page := file.page;
                fi;
                file := file.file;
            fi;
            Exec( Concatenation(
                "osascript <<ENDSCRIPT\n",
                    "tell application \"Skim\"\n",
                    "activate\n",
                    "open \"", file, "\"\n",
                    "set theDoc to document of front window\n",
                    "go theDoc to page ",String(page)," of theDoc\n",
                    "end tell\n",
                "ENDSCRIPT\n" ) );
            return;
        end
    );

else # UNIX but not macOS

  # Graphical systems handled differently in WSL and standard Linux
  if ARCH_IS_WSL() then
    HELP_VIEWER_INFO.browser := rec(
    type := "url",
    show := function( url )
      # Ignoring part of the URL after '#' since we are unable
      # to navigate to the precise location on Windows
      url := SplitString( url, "#" )[1];
      Exec(Concatenation("explorer.exe \"$(wslpath -a -w \"",url, "\")\""));
    end
    );

    HELP_VIEWER_INFO.("pdf viewer") := rec(
        type := "pdf",
        show := function(file)
          local   page;
          # unfortunately one cannot (yet?) give a start page to windows
          page := 1;
          if IsRecord(file) then
            if IsBound(file.page) then
              page := file.page;
            fi;
            file := file.file;
          fi;
          Exec(Concatenation("explorer.exe \"$(wslpath -a -w \"",file, "\")\""));
          Print("#  see page ", page, " in PDF.\n");
    end
    );
  else
    # html version with netscape
    HELP_VIEWER_INFO.netscape := rec(
    type := "url",
    show := function(url)
      Exec(Concatenation("netscape -remote \"openURL(file:", url, ")\""));
    end
    );

    # html version with mozilla
    HELP_VIEWER_INFO.mozilla := rec(
    type := "url",
    show := function(url)
      Exec(Concatenation("mozilla -remote \"openURL(file:", url, ")\""));
    end
    );

    # html version with firefox
    HELP_VIEWER_INFO.firefox := rec(
    type := "url",
    show := function(url)
      Exec(Concatenation("firefox \"file://", url,"\" >/dev/null 2>&1 &"));
    end
    );

    # html version with chrome
    HELP_VIEWER_INFO.chrome := rec(
    type := "url",
    show := function(url)
      Exec(Concatenation("chromium-browser \"file://", url,"\" >/dev/null 2>&1 &"));
    end
    );

    # html version with konqueror  - doesn't work with 'file://...#...' URLs
    HELP_VIEWER_INFO.konqueror := rec(
    type := "url",
    show := function(url)
      Exec(Concatenation("konqueror \"file://", url,"\" >/dev/null 2>&1 &"));
    end
    );
  fi;

  # html version with lynx
  HELP_VIEWER_INFO.lynx := rec(
  type := "url",
  show := function(url)
    Exec(Concatenation("lynx \"", url, "\""));
  end
  );

  # html version with w3m
  HELP_VIEWER_INFO.w3m := rec(
  type := "url",
  show := function(url)
    Exec(Concatenation("w3m \"", url, "\""));
  end
  );

  HELP_VIEWER_INFO.elinks := rec(
  type := "url",
  show := function(url)
    Exec(Concatenation("elinks \"", url, "\""));
  end
  );

  HELP_VIEWER_INFO.links2ng := rec(
  type := "url",
  show := function(url)
    Exec(Concatenation("links2 \"", url, "\""));
  end
  );

  HELP_VIEWER_INFO.links2 := rec(
  type := "url",
  show := function(url)
    Exec(Concatenation("links2 -g \"", url, "\""));
  end
  );
fi;

# Function to find the X-windows window ID of a program accessing file
# <bookf>. Used for a hack below: xdvi doesn't provide a -remote control.
# Having compiled GAPHOME/etc/xrmtcmd.c one can reuse running xdvi's for
# each help file. This was provided by Alexander Hulpke.
#
# This may not work if several people on the same machine want to use it.
#
# Set "XLSCLIENTSCMD := fail;" to turn this off.
FWITF:=fail;
XLSCLIENTSCMD:=false;
InstallGlobalFunction(FindWindowId, function(prog,bookf)
local s,l,a,e,n,c;
  if FWITF=fail then
    FWITF:=Filename(DirectoryTemporary(),"clients");
  fi;
  if XLSCLIENTSCMD=false then
    XLSCLIENTSCMD:=Filename(DirectoriesSystemPrograms(),"xlsclients");
  fi;
  if XLSCLIENTSCMD=fail then
    return fail;
  fi;
  Exec(Concatenation(XLSCLIENTSCMD," -l >",FWITF));
  s:=InputTextFile(FWITF);
  # find the proper jobs
  #T also get the right display/user. Probably this has to be done via the
  #T `Machine' parameter.
  while not IsEndOfStream(s) do
    l:=ReadLine(s);
    if l<>fail then
      e:=Length(l);
      if l[e]='\n' then
        e:=e-1;
      fi;
      a:=1;
      while l[a]=' ' do
        a:=a+1;
      od;
      if l{[a..a+6]}="Window " then
        n:=l{[a+7..e-1]};
      elif l{[a..a+7]}="Command:" then
        c:=l{[a+10..e]};
        a:=PositionSublist(c,prog);
        e:=Length(c);
        # does the program name occur and is called on the right file?
        if a<>fail and e>Length(bookf)
           and c{[e-Length(bookf)+1..e]}=bookf then
          # now convert n in an integer
          e:=0;
          a:="0123456789abcdef";
          c:=3; # first two characters are 0x
          while c<=Length(n) do
            e:=e*16+Position(a,n[c])-1;
            c:=c+1;
          od;
          return e;
        fi;
      fi;
    fi;
  od;
  CloseStream(s);
  return fail;
end);

XRMTCMD:=false;

##  dvi version with xdvi
##  default options, can be adjusted in gap.ini file or by environment
##  variables
##  longer example:
#SetUserPreference("XdviOptions", " -geometry 739x577 -paper a4 -s 6 -fg \"#111111\" -bg \"#dddddd\" -margins 1cm -gamma 0.8");

HELP_VIEWER_INFO.xdvi := rec(
type := "dvi",
show := function(file)
  local   page,wnum;
  page := 1;
  if IsRecord(file) then
    if IsBound(file.page) then
      page := file.page;
    fi;
    file := file.file;
  fi;
  if XRMTCMD=false then
    XRMTCMD:=Filename(DirectoriesSystemPrograms(),"xrmtcmd");
  fi;
  if XRMTCMD<>fail then
    wnum:=FindWindowId("xdvi",file); # get the window ID of a running XDVI
                                     # for the right book
  else
    wnum:=fail;
  fi;
  if wnum=fail or XRMTCMD=fail then
    Exec(Concatenation("xdvi ", UserPreference("XdviOptions"), " +",
            String(page), " ", file, " &"));
  else
    #Print("Window: ",wnum,"\n");
    # command for xdvi: a (to \relax), pagenumber, goto
    file:=Concatenation("a",String(page),"g");
    Exec(Concatenation(XRMTCMD," ",String(wnum)," ",file));
  fi;
end
);

# pdf version with xpdf (very good with well configured fonts!)
HELP_VIEWER_INFO.xpdf := rec(
type := "pdf",
show := function(file)
  local   page;
  page := 1;
  if IsRecord(file) then
    if IsBound(file.label) then
      page := Concatenation("+", file.label);
    elif IsBound(file.page) then
      page := String(file.page);
    else
      page := "";
    fi;
    file := file.file;
  fi;
  Exec(Concatenation("xpdf -remote gap4 -raise ",
                        UserPreference("XpdfOptions"),
                        " ", file, " ", page, " 2>/dev/null &"));
end
);

# pdf version with acroread: less nice since there is no start page argument
# and no remote control.
# When accessing several sections of the same file in a row this viewer
# assumes that acroread is still running and only tells the page number
# to visit.
ACROREAD_OPTIONS := "";
ACROREAD_FILE  := "";
HELP_VIEWER_INFO.acroread := rec(
type := "pdf",
show := function(file)
  local   page;
  # unfortunately one cannot (yet?) give a start page to acroread
  # it is currently ignored
  page := 1;
  if IsRecord(file) then
    if IsBound(file.page) then
      page := file.page;
    fi;
    file := file.file;
  fi;
  if file <> ACROREAD_FILE then
    Exec(Concatenation("acroread ", ACROREAD_OPTIONS, " ", file, " &"));
    ACROREAD_FILE := file;
  fi;
  Print("#  see page ", page, " in acroread window.\n");
end
);

if IsHPCGAP then
    MakeReadOnlyObj(HELP_VIEWER_INFO);
fi;

#############################################################################
##
#F  SetHelpViewer(<viewer>):  Set the viewer used for help
##

# Can give one or more strings for the preferred help viewer;
# the HELP tries to get the data for the viewer in the order given here.
# No argument shows current setting.
InstallGlobalFunction(SetHelpViewer, function(arg)
  local   view,  i,  a;

  if Length(arg) = 0 then
    return UserPreference("HelpViewers");
  fi;

  view := List(arg, LowercaseString);

  for i in [1..Length(view)] do
    a := view[i];
    # special handling of help viewer `less'
    if a = "less" then
      Info(InfoWarning, 2,
      "Help viewer \"less\": interpreted as ",
      "viewer \"screen\" and setting:\n#I  ",
      "SetUserPreference(\"Pager\",\"less\");\n#I  ",
      "SetUserPreference(\"PagerOptions\", ",
      "[\"-f\",\"-r\",\"-a\",\"-i\",\"-M\",\"-j2\"]);");
      SetUserPreference("Pager", "less");
      SetUserPreference("PagerOptions", ["-f","-r","-a","-i","-M","-j2"]);
      view[i] := "screen";
    elif a = "more" then
      Info(InfoWarning, 2,
      "Help viewer \"more\": interpreted as ",
      "viewer \"screen\" and setting:\n#I  ",
      "SetUserPreferences(\"Pager\", \"more\");\n#I  ",
      "SetUserPreference(\"PagerOptions\", []);");
      SetUserPreference("Pager", "more");
      SetUserPreference("PagerOptions",  []);
      view[i] := "screen";
    elif not IsBound(HELP_VIEWER_INFO.(a)) then
      Info(InfoWarning, 1, Concatenation(
           "GAP's help system has NO support for help viewer ",a,"!\n"));
      view[i] := fail;
    fi;
  od;
  if not "screen" in view then
    Add(view, "screen");
  fi;
  SetUserPreference("HelpViewers", Filtered(view, a-> a<>fail));
  if Length( UserPreference("HelpViewers") ) > 1 then
    Info( InfoWarning, 2, "Trying to use\n#I  ",
          UserPreference("HelpViewers"),
          "\n#I  (in this order) as help viewer.");
  else
    Info(InfoWarning, 2, Concatenation(
          "Using ", UserPreference("HelpViewers")[1],
          " as help viewer."));
  fi;
end);


