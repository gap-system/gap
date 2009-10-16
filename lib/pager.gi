#############################################################################
##  
#W  pager.gi                     GAP Library                     Frank Lübeck
##  
#H  @(#)$Id: pager.gi,v 1.4 2002/05/10 12:56:28 gap Exp $
##  
#Y  Copyright  (C) 2001, Lehrstuhl  D  fuer  Mathematik, RWTH  Aachen, Germany 
#Y (C) 2001 School Math and  Comp. Sci., University of St. Andrews, Scotland
#Y Copyright (C) 2002 The GAP Group
##  
##  The  files  pager.g{d,i}  contain  the `Pager'  utility.  A  rudimentary
##  version of this  was integrated in first versions of  GAP's help system.
##  But this utility is certainly useful for other purposes as well.
##  
Revision.pager_gi := 
  "@(#)$Id: pager.gi,v 1.4 2002/05/10 12:56:28 gap Exp $";
##  
##  There is a builtin pager `PAGER_BUILTIN', but  at least under UNIX one
##  should use an external one.  This can be  set via the variable `PAGER'
##  (e.g., PAGER :=  "less";). Here,  `less'  should be  in the executable
##  PATH of the user and we assume that it supports an argument `+num' for
##  starting display in   line number `num'.   Additional options  can  be
##  assigned to `PAGER_OPTIONS' as list of strings.
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
##                           beginning is available via back scrolling
##  
 
#############################################################################
##
#F  PAGER_BUILTIN( <lines> )	. . . . . . . . . . . . . . . .  format lines
##
# We take  into account a  variable from the  GAPDoc package. If  the text
# contains ANSI color sequences we reset  the terminal before we print the
# last line.
if not IsBound(ANSI_COLORS) then
  ANSI_COLORS := false;
fi;
BindGlobal("PAGER_BUILTIN", function( lines )
  local   formatted,  linepos,  size,  wd,  pl,  count,  i,  stream,  
          halt,  delhaltline,  from,  len,  char, out;
  
  formatted := false;
  linepos := 1;
  # don't print this to LOG files
  out := OutputTextUser();
  
  if IsRecord(lines) then
    if IsBound(lines.formatted) then
      formatted := lines.formatted;
    fi;
    if IsBound(lines.start) then
      linepos := lines.start;
    fi;
    lines := lines.lines;
  fi;
  
  if IsString(lines) then
    lines := SplitString(lines, "\n", "");
  fi;
  
  size   := SizeScreen();
  wd := QuoInt(size[1]+2, 2);
  # really print line without breaking it
  pl := function(l)
    local   r;
    r := 1;
    while r*wd<=Length(l) do
      PrintTo(out, l{[(r-1)*wd+1..r*wd]}, "\c");
      r := r+1;
    od;
    if (r-1)*wd < Length(l) then
      PrintTo(out, l{[(r-1)*wd+1..Length(l)]});
    fi;
    PrintTo(out, "\n");
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
  if IsBound(ANSI_COLORS) and ANSI_COLORS = true then
    halt := Concatenation("\033[0m", halt);
  fi;
  delhaltline := function()
    local i;
    for i  in halt  do 
      if i <> '\c' then
        PrintTo(out,  "\b\c \c\b\c" );
      fi;
    od;
  end;
  from := linepos; 
  len := Length(lines);
  repeat
    for i in [from..Minimum(len, from+size[2]-2)] do
      pl(lines[i]);
    od;
    if len = i+1 then
      pl(lines[len]);
      char := 'q';
    elif len = i then
      char := 'q';
    else
      PrintTo(out, halt);
      char := CHAR_INT(ReadByte(stream));
      while not char in " nbpq" do
        char := CHAR_INT(ReadByte(stream));
      od;
      if char = ' ' then
        from := from+size[2]-1;
      elif char = 'n' then
        from := from+1;
      elif char = 'p' and from>1 then
        from := from-1;
      elif char = 'b' then
        from := Maximum(1, from-size[2]+1);
      fi;
      delhaltline();  
    fi;
  until char = 'q';
  
  CloseStream(stream);
end);

# for using `more' or `less' or ... (read from `PAGER')
# we assume that PAGER allows command line option +num for starting
# display in line num
PAGER := "builtin";
PAGER_OPTIONS := [];

BindGlobal("PAGER_EXTERNAL",  function( lines )
  local   path,  pager,  linepos,  str,  i,  cmdargs,  stream;
  path := DirectoriesSystemPrograms();
  pager := Filename(path, PAGER);
  if pager=fail then
    Error("Pager ", PAGER, " not found, change `PAGER'.");
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
  Process(path[1], pager, stream, OutputTextUser(),
          Concatenation(PAGER_OPTIONS, cmdargs));
end);

InstallGlobalFunction("Pager",  function(lines)
  if PAGER="builtin" then
    PAGER_BUILTIN(lines);
  else
    PAGER_EXTERNAL(lines);
  fi;
end);


