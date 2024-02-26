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
##  This is outdated experimental code for command line editing and a history
##  and demo mechanism which is only used when GAP is not compiled with
##  libreadline. It is kept temporarily for people who have difficulties
##  compiling with libreadline.
##

############################################################################
##
#F  LineEditKeyHandler( <l> )
##
##  This function is called from the kernel in command line editing mode
##  if a key number <n> is pressed for which `LineEditKeyHandlers[ <n> + 1 ]
##  is bound to some key handler function. It does some checking of the result
##  of the key handler functions.
##
##  The argument <l> for this and for the key handler functions is a list of
##  the form  `[linestr, ch, ppos, length, yankstr]' where `linestr' is a string
##  with the content of the current input line, `ch' is the key pressed (as
##  integer), `ppos' is the position of the cursor on the input line, `length'
##  is the maximal length of the current input line and `yankstr' is a string
##  with the content of the current yank buffer.
##
##  The handler functions usually must return a list `[linestr, ppos, yankstr]'
##  where `linestr' is a string containing the new content of the input line,
##  `ppos' is the new position of the cursor (in [1..Length(linestr)+1]) and
##  `yankstr' is the new value of the yank buffer.
##
##  The exception is that a handler function can also return a positive small
##  integer <n>. In that case the next <n> input lines (including the current
##  line) are read by {\GAP} by calling <n> times the key handler for `<ESC>-N'.
##
##  The default handler for `<ESC>-N' does the following: It assumes that
##  `AutomaticInputLines' is a list of strings and that
##  `AutomaticInputLinesCounter' is a positive integer, it returns as current
##  input line entry number `AutomaticInputLinesCounter' of
##  `AutomaticInputLines' and increases the counter by one.
##  The key `<ESC>-S' is bound to deliver all lines currently bound to
##  `AutomaticInputLines' as input to {\GAP}. Typing `<ESC>-S' on the second
##  input line below, leads to the following:
##
##  \beginexample
##  gap> AutomaticInputLines := ["a:=1;", "b:=2;", "c:=a+b;"];;
##  gap> a:=1;
##  1
##  gap> b:=2;
##  2
##  gap> c:=a+b;
##  3
##  \endexample
##
##  The key numbers are computed as follows: For ascii characters <k> they
##  are given by `INT_CHAR(<k>)'. Combined with the `Ctrl' key has number
##  `INT_CHAR(<k>) mod 32' and combined with the `Esc' key (pressed before)
##  the number is `INT_CHAR(<k>) + 256'.
##

BindGlobal("CommandLineRegion", NewSpecialRegion("command line region"));

BindGlobal("LineEditKeyHandlers", []);
LockAndMigrateObj(LineEditKeyHandlers, CommandLineRegion);
# args: [linestr, ch, ppos, length, yankstr]
# returns: [linestr, ppos, yankstr]
BindGlobal("LineEditKeyHandler", function(l)
  local res;
  atomic CommandLineRegion do
    if not IsBound(LineEditKeyHandlers[l[2]+1]) then
      return [l[1], l[3], l[5]];
    fi;
    res := LineEditKeyHandlers[l[2]+1](l);
##    if not IS_INT(res) and not (IS_STRING_REP(res[1]) and
##            LENGTH(res[1]) < l[4]-1 and
##            IS_STRING_REP(res[3]) and LENGTH(res[3]) < 32768 and
##            res[2] < l[4] and res[2] <= LENGTH(res[1])+1) then
    if not (IsSmallIntRep(res) and res >= 0) and not (IsStringRep(res[1]) and
            Length(res[1]) < l[4]-1 and
            IsStringRep(res[3]) and Length(res[3]) < 32768 and
            res[2] < l[4] and res[2] <= Length(res[1])+1) then
      Error("Key handler for line editing produced invalid result.");
    fi;
    return res;
  od;
end);

############################################################################
##
#V  CommandLineHistory
#V  MaxCommandLineHistory
##
##  The input lines from a {\GAP} session with command line editing switched on
##  are stored in the list `CommandLineHistory'. This list is of form
##  `[pos, line1, line2, ..., lastline]' where pos is an integer which defines
##  a current line number in the history, and the remaining entries are input
##  lines for {\GAP} (without a trailing '\n').
##
##  If the integer `MaxCommandLineHistory' is equal to `0' all input lines of
##  a session  are stored. If it has a positive value then it specifies the
##  maximal number of input lines saved in the history.
##

# init empty history
BindGlobal("CommandLineHistory", [1]);
LockAndMigrateObj(CommandLineHistory, CommandLineRegion);
MaxCommandLineHistory := 1000;

# history position from previous line
LastPosCLH := 1;
# here we implement the command line handlers for the keys
# Ctrl-P, Ctrl-N, Ctrl-L, Esc-<, Esc->
# key number 0 is used as a hook for saving a new line in the history
BindGlobal("CommandLineHistoryHandler", function(l)
  local key, hist, n, m, start, res, i;
  atomic CommandLineRegion do

  key := l[2];
  hist := CommandLineHistory;
  if key = 0 then  # save line data
    # no trailing white space
    while Length(l[1]) > 0 and Last(l[1]) in "\n\r\t " do
      Remove(l[1]);
    od;
    MaxCommandLineHistory := UserPreference("HistoryMaxLines");
    if not IsInt(MaxCommandLineHistory) then
      MaxCommandLineHistory := 0;
    fi;
    if MaxCommandLineHistory > 0 and
       Length(hist) >= MaxCommandLineHistory+1 then
      # overrun, throw oldest line away
      for i in [2..Length(hist)-1] do
        hist[i] := hist[i+1];
      od;
      hist[Length(hist)] := MakeImmutable(l[1]);
      if hist[1] > 2 then
        hist[1] := hist[1]-1;
      else
        hist[1] := Length(hist)+1;
      fi;
    else
      Add(hist, MakeImmutable(l[1]));
    fi;
    LastPosCLH := hist[1];
    hist[1] := Length(hist)+1;
    return [l[1], l[3], l[5]];
  elif key = 16 then  # CTR('P')
    # searching backward in history for line starting with input before
    # cursor
    n := hist[1];
    if n < 2 then n := Length(hist)+1; fi;
    m := l[3]-1;
    start := l[1]{[1..m]};
    for i in [n-1,n-2..2] do
      hist[1] := i;
      if Length(hist[i]) >= m and hist[i]{[1..m]} = start then
        if hist[1] < 2 then
          hist[1] := Length(hist)+1;
        fi;
        return [hist[i], l[3], l[5]];
      fi;
    od;
    # not found, point to last line
    hist[1] := Length(hist)+1;
    return [start, l[3], l[5]];
  elif key = 14 then  # CTR('N')
    # searching forward in history for line starting with input before
    # cursor; first time for current line we start at last history pointer
    # from previous line   (so one can repeat a sequence of lines by
    # repeated ctrl-N.
    if Length(hist) = 1 then return [l[1],l[3],l[5]]; fi;
    if hist[1] = Length(hist)+1 then
      if  LastPosCLH < hist[1]-1 then
        hist[1] := LastPosCLH;
        LastPosCLH := Length(hist)+1;
      else
        hist[1] := 2;
      fi;
    fi;
    m := l[3]-1;
    start := l[1]{[1..m]};
    for i in [hist[1]+1..Length(hist)] do
      hist[1] := i;
      if Length(hist[i]) >= m and hist[i]{[1..m]} = start then
        return [hist[i], l[3], l[5]];
      fi;
    od;
    # not found, point after newest line
    hist[1] := Length(hist)+1;
    return [start, l[3], l[5]];
  elif key = 12 then  # CTR('L')
    if Length(hist) = 1 then return [l[1],l[3],l[5]]; fi;
    res := l[1]{[1..l[3]-1]};
    Append(res, hist[Length(hist)]);
    Append(res, l[1]{[l[3]..Length(l[1])]});
    return [res, l[3] + Length(hist[Length(hist)]), l[5]];
  elif key = 316 then  # ESC('<')
    if hist[1] > 1 then
      hist[1] := 2;
      return [hist[2], 1, l[5]];
    else
      return ["", 1, l[5]];
    fi;
  elif key = 318 then  # ESC('>')
    if hist[1] > 1 then
      hist[1] := Length(hist)+1;
    fi;
    return ["", 1, l[5]];
  else
    Error("Cannot handle command line history with key ", key);
  fi;
  od;
end);

# install the handlers for the history commands
atomic CommandLineRegion do
  for tmpclh in [0, 16, 14, 12, 316, 318] do
    LineEditKeyHandlers[tmpclh+1] := CommandLineHistoryHandler;
  od;
od;
Unbind(tmpclh);

############################################################################
##
#F  SaveCommandLineHistory( [<fname>] )
#F  ReadCommandLineHistory( [<fname>] )
##
##  Use the first command to write the currently saved command lines in the
##  history to file <fname>. If not given the default file name `~/.gap_hist'
##  is used. The second command prepends the lines from <fname> to the current
##  command line history.
##
BindGlobal("SaveCommandLineHistory", function(arg)
  local fnam, hist, max, start, i;
  atomic CommandLineRegion do

  if Length(arg) > 0 then
    fnam := arg[1];
  else
    fnam := "~/.gap_hist";
  fi;
  hist := CommandLineHistory;
  max := UserPreference("HistoryMaxLines");
  if IsInt(max) and max > 0 and Length(hist)+1 > max then
    start := Length(hist)-max+1;
  else
    start := 2;
  fi;
  PrintTo(fnam,"");
  for i in [start..Length(hist)] do
    AppendTo(fnam, hist[i], "\n");
  od;
  od;

end);

BindGlobal("ReadCommandLineHistory", function(arg)
  local fnam, hist, s, n;
  atomic CommandLineRegion do

  if Length(arg) > 0 then
    fnam := arg[1];
  else
    fnam := "~/.gap_hist";
  fi;
  hist := CommandLineHistory;
  s := StringFile(fnam);
  if IsString(s) then
    s := SplitString(s,"","\n");
    MaxCommandLineHistory := UserPreference("HistoryMaxLines");
    if not IsInt(MaxCommandLineHistory) then
      MaxCommandLineHistory := 0;
    fi;
    if MaxCommandLineHistory > 0 and
       Length(s) + Length(hist) - 1 > MaxCommandLineHistory then
      n := MaxCommandLineHistory + 1 - Length(hist);
      s := s{[Length(s)-n+1..Length(s)]};
    fi;
    hist{[Length(s)+2..Length(s)+Length(hist)]} := hist{[2..Length(hist)]};
    hist{[2..Length(s)+1]} := MakeImmutable(s);
  fi;
  hist[1] := Length(hist) + 1;

  od;
end);

# Implementation of the default ESC-N and ESC-S behaviour described above.
AutomaticInputLines := LockAndMigrateObj([], CommandLineRegion);
AutomaticInputLinesCounter := 1;
BindGlobal("DefaultEscNHandler", function(arg)
  local res;
  atomic CommandLineRegion do
    if AutomaticInputLinesCounter <= Length(AutomaticInputLines) then
      res := AutomaticInputLines[AutomaticInputLinesCounter];
      AutomaticInputLinesCounter := AutomaticInputLinesCounter + 1;
      return [res, Length(res)+1, arg[1][5]];
    else
      return ["",1,arg[1][5]];
    fi;
  od;
end);
atomic CommandLineRegion do
  LineEditKeyHandlers[334+1] := DefaultEscNHandler;
od;

# ESC('S') calls Length(AutomaticInputLines) often ESC('N')
atomic CommandLineRegion do
  LineEditKeyHandlers[339+1] := function(arg)
    atomic CommandLineRegion do
      AutomaticInputLinesCounter := 1;
      return Length(AutomaticInputLines);
    od;
  end;
od;

##  Standard behaviour to insert a character for the key.
##  We don't install this directly in LineEditKeyHandlers but this can be
##  useful for writing other key handlers)
BindGlobal("LineEditInsert", function(l)
  local line;
  atomic CommandLineRegion do
    line := l[1]{[1..l[3]-1]};
    Add(line, CHAR_INT(l[2]));
    Append(line, l[1]{[l[3]..Length(l[1])]});
    return [line, l[3]+1, l[5]];
  od;
end);

##  This will be installed as handler for the space-key, it removes the prompts
##  "gap> ", "> ", "brk> " in beginning of lines when the trailing space is
##  typed. This makes a special hack in the kernel unnecessary and it can
##  be switched off by setting 'GAPInfo.DeletePrompts := false;'.
GAPInfo.DeletePrompts := true;
BindGlobal("LineEditDelPrompt", function(l);
  atomic CommandLineRegion do
    if GAPInfo.DeletePrompts and l[1]{[1..l[3]-1]} in ["gap>", ">", "brk>"] then
      return [l[1]{[l[3]..Length(l[1])]}, 1, l[5]];
    else
      return LineEditInsert(l);
    fi;
  od;
end);
atomic CommandLineRegion do
  LineEditKeyHandlers[33] := LineEditDelPrompt;
od;

############################################################################
##       readline interface functions

if not IsBound(GAPInfo.History) then
  GAPInfo.History :=
    AtomicRecord(rec(MaxLines := -1, Lines := [], Pos := 0));
  ShareSpecialObj(GAPInfo.History.Lines);
fi;
GAPInfo.History.AddLine := function(l)
  local hist, len;
  hist := GAPInfo.History;
  MakeImmutable(l);
  # if history switched off
  if hist.MaxLines = 0 then
    return;
  fi;
  # no trailing white space
  len := Length(l);
##    while len > 0 and l[len] in "\n\r\t " do
##      Remove(l);
##      len := len - 1;
##    od;
  # no empty lines
  if len = 0 then
    return;
  fi;
  atomic hist.Lines do
    if hist.MaxLines > 0 and Length(hist.Lines) >= hist.MaxLines then
      # overrun, throw oldest line away
      Remove(hist.Lines, 1);
    fi;
    Add(hist.Lines, l);
    hist.Pos := Length(hist.Lines) + 1;
  od;
end;

GAPInfo.History.PrevLine := function(start)
  local hist, pos, first;
  hist := GAPInfo.History;
  atomic hist.Lines do
    pos := hist.Pos - 1;
    if pos = 0 then
      pos := Length(hist.Lines);
    fi;
    first := pos;
    repeat
      if PositionSublist(hist.Lines[pos], start) = 1 then
        hist.Pos := pos;
        return hist.Lines[pos];
      fi;
      if pos > 1 then
        pos := pos - 1;
      else
        pos := Length(hist.Lines);
      fi;
    until pos = first;
  od;
end;

# Operations to enable and disable raw mode on terminals.

# Set operations are not available yet, so we cheat by using
# [] in lieu of Set([]); AddSet() and RemoveSet() accept the
# empty list as a proper set because it is sorted.

TERMINAL_REGION := ShareSpecialObj("TERMINAL_REGION");
TERMINAL_FILE_IDS := LockAndMigrateObj([], TERMINAL_REGION);
TERMINAL_EXITING := false;

TERMINAL_BEGIN_EDIT := function(fid)
  atomic TERMINAL_REGION do
    while TERMINAL_EXITING do
      Sleep(1); # idle wait until program exit
    od;
    if RAW_MODE_FILE(fid, true) then
      AddSet(TERMINAL_FILE_IDS, fid);
      return true;
    else
      return false;
    fi;
  od;
end;

TERMINAL_END_EDIT := function(fid)
  atomic TERMINAL_REGION do
    if not TERMINAL_EXITING then
      RemoveSet(TERMINAL_FILE_IDS, fid);
      return RAW_MODE_FILE(fid, false);
    fi;
  od;
end;

TERMINAL_CLOSE := function()
  local fid;
  atomic TERMINAL_REGION do
    TERMINAL_EXITING := true;
    for fid in TERMINAL_FILE_IDS do
      RAW_MODE_FILE(fid, false);
    od;
  od;
end;
