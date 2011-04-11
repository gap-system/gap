#############################################################################
##  
#W  helpview.gi                 GAP Library                      Frank Lübeck
##  
#H  @(#)$Id$
##  
#Y  Copyright (C)  2001,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 2001 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##  
##  The  files  helpview.g{d,i} contain the configuration mechanism  for  the
##  different help viewer.
##  
Revision.helpview_gi := 
  "@(#)$Id$";

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
InstallValue(HELP_VIEWER_INFO, rec());

# text on screen
HELP_VIEWER_INFO.screen := rec(
type := "text",
show := Pager
);

#if ARCH_IS_MAC() then
#  # html version on MAC
#  HELP_VIEWER_INFO.("mac default browser") := rec(
#  type := "macurl",
#  show := function(data)
#    if IsBound (data.path) then
#       ExecuteProcess ("./", "Internet Config", 1, 0, [data.protocol, data.path, data.section]);
#    else
#       ExecuteProcess ("", "Internet Config", 1, 0, [data.url, "", data.section]);
#    fi;
#  end
#  );
#  
#  # old name for for backward compatibility
#  HELP_VIEWER_INFO.("internet config") :=
#  	HELP_VIEWER_INFO.("mac default browser"); 
# fi

if ARCH_IS_WINDOWS() then
  # html version on Windows
  HELP_VIEWER_INFO.browser := rec(
  type := "url",
  show := function( filename )
    Print( "Opening help page in default windows browser ... \c" );
    Process( DirectoryCurrent(),
             Filename( Directory( Concatenation( GAPInfo.KernelInfo.GAP_ROOT_PATHS[1], 
                                                 "bin" ) ),
                       "cygstart.exe" ),
             InputTextNone(),
             OutputTextNone(),
             [ , Concatenation( "file:///", filename ) ] );
    Print( "done! \n" );         
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
    Exec(Concatenation("firefox -remote \"openURL(file:", url, ")\""));
  end
  );

  # html version with konqueror  - doesn't work with 'file://...#...' URLs
  HELP_VIEWER_INFO.konqueror := rec(
  type := "url",
  show := function(url)
    Exec(Concatenation("konqueror \"file://", url,"\" >/dev/null 2>1 &"));
  end
  );

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

  # html version using Mac OS X default browser
  HELP_VIEWER_INFO.("mac default browser") := rec (
    type := "url", 
    show := function (url)
            Exec ( Concatenation( "osascript <<ENDSCRIPT\n",
                                  "open location \"file://", url, "\"\n",
                                  "ENDSCRIPT\n" ) );
            return;
        end
  );

  # html version using Mac OS X browser Safari
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
#GAPInfo.UserPreferences.XdviOptions:= " -geometry 739x577 -paper a4 -s 6 -fg \"#111111\" -bg \"#dddddd\" -margins 1cm -gamma 0.8";

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
    Exec(Concatenation("xdvi ", GAPInfo.UserPreferences.XdviOptions, " +",
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
                        GAPInfo.UserPreferences.XpdfOptions, 
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
    return GAPInfo.UserPreferences.HelpViewers;
  fi;

  view := List(arg, LowercaseString);
  
  for i in [1..Length(view)] do 
    a := view[i];
    # special handling of help viewer `less'
    if a = "less" then
      Info(InfoWarning, 2, 
      "Help viewer \"less\": interpreted as ",
      "viewer \"screen\" and setting:\n#I  ",
      "GAPInfo.UserPreferences.Pager := \"less\";\n#I  ",
      "GAPInfo.UserPreferences.PagerOptions:= ",
      "[\"-f\",\"-r\",\"-a\",\"-i\",\"-M\",\"-j2\"];");
      GAPInfo.UserPreferences.Pager := "less";
      GAPInfo.UserPreferences.PagerOptions:= ["-f","-r","-a","-i","-M","-j2"];
      view[i] := "screen";
    elif a = "more" then
      Info(InfoWarning, 2, 
      "Help viewer \"more\": interpreted as ",
      "viewer \"screen\" and setting:\n#I  ",
      "GAPInfo.UserPreferences.Pager := \"more\";\n#I  ",
      "GAPInfo.UserPreferences.PagerOptions := [];");
      GAPInfo.UserPreferences.Pager := "more";
      GAPInfo.UserPreferences.PagerOptions := [];
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
  GAPInfo.UserPreferences.HelpViewers := Filtered(view, a-> a<>fail);  
  if Length( GAPInfo.UserPreferences.HelpViewers ) > 1 then
    Info( InfoWarning, 2, "Trying to use\n#I  ",
          GAPInfo.UserPreferences.HelpViewers, 
          "\n#I  (in this order) as help viewer.");
  else
    Info(InfoWarning, 2, Concatenation(
          "Using ", GAPInfo.UserPreferences.HelpViewers[1],
          " as help viewer."));
  fi;
end);


