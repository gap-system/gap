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
##  The  files  pager.g{d,i}  contain  the `Pager'  utility.  A  rudimentary
##  version of this  was integrated in first versions of  GAP's help system.
##  But this utility is certainly useful for other purposes as well.
##
##
##  There is a builtin pager `PAGER_BUILTIN', but  at least under UNIX one
##  should use an external one.  This can be  set via the variable
##  `SetUserPreference("Pager", ...);'
##  (e.g., SetUserPreference("Pager", "less");).
##  Here,  `less'  should be  in the executable
##  PATH of the user and we assume that it supports an argument `+num' for
##  starting display in   line number `num'.   Additional options  can  be
##  given by  `SetUserPreference("PagerOptions", ...);' as list of strings.
##
##  The user function is `Pager'.
##
##  The input of `Pager( lines )' can have one the following forms:
##
##   (1) a string (i.e., lines are separated by '\n')
##   (2) a list of strings (without '\n') interpreted as lines of output
##   (3) a record with component .lines as in (1) or (2) and optional further
##       components
##
##  In (3) currently the following components are used:
##
##   .formatted (true/false) If true, the builtin pager tries to avoid
##                           line breaks by GAP's Print.
##   .start (number)         The display is started with line .start, but
##                           beginning is available via back scrolling.
##   .exitAtEnd (true/false) If true (default), the pager is terminated
##                           as soon as the end of the list is reached;
##                           if false, entering 'q' is necessary in order to
##                           return from the pager.
##

# The preferred pager can be specified via a user preference.
DeclareUserPreference( rec(
  name:= [ "Pager", "PagerOptions" ],
  description:= [
  "For displaying help pages on screen and other things &GAP; has a rudimentary \
builtin pager. We recommend using a more sophisticated external program.  \
For example, when you have the program <C>less</C> on your computer we recommend:",
    " <C>Pager := \"less\";</C>",
    " <C>PagerOptions := [\"-f\", \"-r\", \"-a\", \"-i\", \"-M\", \"-j2\"];</C>",
    "If you want to use <C>more</C>, we suggest to use the <C>-f</C> option.  \
If you want to use the pager defined in your environment then \
leave the <C>Pager</C> and <C>PagerOptions</C> preferences empty."
    ],
  default:= function()    # copied from GAPInfo.READENVPAGEREDITOR
    local str, sp, pager, options;
    if IsBound(GAPInfo.KernelInfo.ENVIRONMENT.PAGER) then
      str := GAPInfo.KernelInfo.ENVIRONMENT.PAGER;
      sp := SplitStringInternal(str, "", " \n\t\r");
      if Length(sp) > 0 then
        pager:= sp[1];
        options:= sp{ [ 2 .. Length( sp ) ] };
        # 'less' could have options in variable 'LESS'
        if "less" in SplitStringInternal(sp[1], "", "/\\") then
          if IsBound(GAPInfo.KernelInfo.ENVIRONMENT.LESS) then
            str := GAPInfo.KernelInfo.ENVIRONMENT.LESS;
            sp := SplitStringInternal(str, "", " \n\t\r");
            Append( options, sp );
          fi;
          # make sure -r is used
          Add( options, "-r" );
        elif "more" in SplitStringInternal(sp[1], "", "/\\") then
          if IsBound(GAPInfo.KernelInfo.ENVIRONMENT.MORE) then
            # similarly for 'more'
            str := GAPInfo.KernelInfo.ENVIRONMENT.MORE;
            sp := SplitStringInternal(str, "", " \n\t\r");
            Append( options, sp );
          fi;
          # make sure -f is used
          Add( options, "-f" );
        fi;
        return [ pager, options ];
      fi;
    fi;
    # The builtin pager does not work in HPCGAP
    if IsHPCGAP then
      return [ "less" , ["-f","-r","-a","-i","-M","-j2"] ];
    else
      return [ "builtin", [] ];
    fi;
  end,
  ) );
## HACKUSERPREF  temporary until all packages are adjusted
GAPInfo.UserPreferences.Pager := UserPreference("Pager");

#############################################################################
##
#F  PAGER_BUILTIN( <lines> )    . . . . . . . . . . . . . . . .  format lines
##
# If  the text contains ANSI color sequences we reset  the terminal before
# we print the last line.
BindGlobal("PAGER_BUILTIN", function( lines )
  local formatted, linepos, exitAtEnd, size, wd, pl, count, i, stream, halt,
        lenhalt, delhaltline, from, len, emptyline, char, out;

  formatted := false;
  linepos := 1;
  exitAtEnd:= true;
  # don't print this to LOG files
  out := OutputTextUser();

  if IsRecord(lines) then
    if IsBound(lines.formatted) then
      formatted := lines.formatted;
    fi;
    if IsBound(lines.start) and IsInt(lines.start) then
      linepos := lines.start;
    fi;
    if IsBound( lines.exitAtEnd ) then
      exitAtEnd:= lines.exitAtEnd;
    fi;
    lines := lines.lines;
  fi;

  if IsString(lines) then
    lines := SplitString(lines, "\n", "");
  elif not formatted then
    lines := ShallowCopy(lines);
  fi;

  if Length( lines ) = 0 then
    return;
  fi;

  size   := SizeScreen();
  wd := QuoInt(size[1]+2, 2);
  # really print line without breaking it
  pl := function(l, final)
    local   r;
    r := 1;
    while r*wd<=Length(l) do
      PrintTo(out, l{[(r-1)*wd+1..r*wd]}, "\c");
      r := r+1;
    od;
    if (r-1)*wd < Length(l) then
      PrintTo(out, l{[(r-1)*wd+1..Length(l)]});
    fi;
    PrintTo(out, final);
  end;

  if not formatted then
    # cope with overfull lines
    count:=1;
    while count<=Length(lines) do
      if Length(lines[count])>size[1]-2 then
        # find the last blank before this position
        i:=size[1]-2;
        while i>0 and lines[count][i]<>' ' do
          i:=i-1;
        od;
        if i>0 then
          if not IsBound(lines[count+1]) then
            lines[count+1]:="";
          fi;
          lines[count+1]:=Concatenation(
             lines[count]{[i+1..Length(lines[count])]}," ", lines[count+1]);
          lines[count]:=lines[count]{[1..i-1]};
        fi;
      fi;
      count:=count+1;
    od;
  fi;

  stream := InputTextFile("*errin*");
  count  := 0;
  halt   :=
    "  -- <space> page, <n> next line, <b> back, <p> back line, <q> quit --\c";
  # remember number of visible characters
  lenhalt := Length(halt)-1;
  if UserPreference("UseColorsInTerminal") = true then
    halt := Concatenation("\033[0m", halt);
  fi;
  delhaltline := function()
    local i;
    for i  in [1..lenhalt] do
      PrintTo(out,  "\b\c \c\b\c" );
    od;
  end;
  from := linepos;
  len := Length(lines);
  emptyline:= String( "", size[1]-2 );
  repeat
    for i in [from..Minimum(len, from+size[2]-2)] do
      pl(lines[i], "\n");
    od;
    if len = i then
      if exitAtEnd then
        break;
      fi;
      for i in [ len+1 .. from+size[2]-2 ] do
        pl( emptyline, "\n" );
      od;
    fi;
    pl(halt, "");
    repeat
      char := ReadByte(stream);
      if char = fail then
        char := 'q';
      else
        char := CHAR_INT(char);
      fi;
    until char in " nbpq";
    if char = ' ' and i < len then
      from := from+size[2]-1;
    elif char = 'n' and i < len then
      from := from+1;
    elif char = 'p' and from>1 then
      from := from-1;
    elif char = 'b' then
      from := Maximum(1, from-size[2]+1);
    fi;
    delhaltline();
  until char = 'q';

  CloseStream(stream);
end);

# for using `more' or `less' or ... (read from `UserPreference("Pager")')
# we assume that UserPreference("Pager") allows command line option
# +num for starting display in line num

BindGlobal("PAGER_EXTERNAL",  function( lines )
  local   path,  pager,  linepos,  str,  i,  cmdargs,  stream;

  pager := UserPreference("Pager");
  if not (Length(pager) > 0 and pager[1] = '/' and IsExecutableFile(pager))
      then
    path := DirectoriesSystemPrograms();
    pager := Filename( path, UserPreference("Pager") );
  fi;
  if pager=fail then
    Error( "Pager ", UserPreference("Pager"),
            " not found, reset with `SetUserPreference(\"Pager\", ...);'." );
  fi;
  linepos := 1;
  if IsRecord(lines) then
    if IsBound(lines.start) then
      linepos := lines.start;
    fi;
    lines := lines.lines;
  fi;

  if not IsString(lines) then
    str:="";
    for i in lines do
      Append(str,i);
      Add(str,'\n');
    od;
    lines := str;
  fi;
  if linepos > 1 then
    cmdargs := [Concatenation("+", String(linepos))];
  else
    cmdargs := [];
  fi;
  stream:=InputTextString(lines);
  Process(DirectoryCurrent(), pager, stream, OutputTextUser(),
  Concatenation( UserPreference("PagerOptions"), cmdargs ));
end);

InstallGlobalFunction("Pager",  function(lines)
  if UserPreference("Pager") = "builtin" then
    PAGER_BUILTIN(lines);
  else
    PAGER_EXTERNAL(lines);
  fi;
end);

BindGlobal( "PagerAsHelpViewer", function( lines )
  if UserPreference( "Pager" ) = "builtin" then
    if IsRecord( lines ) then
      lines.exitAtEnd:= false;
    else
      lines:= rec( lines:= lines, exitAtEnd:= false );
    fi;
    PAGER_BUILTIN( lines );
  else
    PAGER_EXTERNAL( lines );
  fi;
end );


