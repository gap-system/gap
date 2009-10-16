#############################################################################
##
#W  cmdledit.g                    GAP library                    Frank Lübeck 
##
#H  @(#)$Id: cmdledit.g,v 4.7 2009/07/25 16:19:22 gap Exp $
##
#Y  Copyright (C)  2006 The GAP Group
##
##  This file contains function for handling some keys in line edit mode.
##
Revision.cmdledit_g :=
    "@(#)$Id: cmdledit.g,v 4.7 2009/07/25 16:19:22 gap Exp $";


if IsBound(BindKeysToGAPHandler) then
############################################################################
##       readline interface functions

if not IsBound(GAPInfo.CommandLineEditFunctions) then
  GAPInfo.CommandLineEditFunctions := rec(
  KeyHandler := function(l) 
    local macro;
    if l[2] >= 1000 then
      macro := QuoInt(l[2], 1000);
      if IsBound(GAPInfo.CommandLineEditFunctions.Macros.(macro)) then
        return GAPInfo.CommandLineEditFunctions.Macros.(macro)(l);
      fi;
    else
      if IsBound(GAPInfo.CommandLineEditFunctions.Functions.(l[2])) then
        return GAPInfo.CommandLineEditFunctions.Functions.(l[2])(l);
      fi;
    fi;
    return [];
  end,
  Macros := rec(),
  Functions := rec()
  );
fi;



if not IsBound(GAPInfo.History) then
  GAPInfo.History := rec(MaxLines := infinity, 
                         Lines := [], Pos := 0, Last := 0);
fi;

BindGlobal("BindKeySequence", function(seq, subs)
  ReadlineInitLine(Concatenation("\"", seq, "\": \"", subs, "\""));
end);

## We use key 0 (not bound) to add line to history.
GAPInfo.CommandLineEditFunctions.Functions.0 := function(l)
  local i, hist;
  # no history
  if GAPInfo.History.MaxLines <= 0 then
    return [];
  fi;
  # no trailing white space
  i := 0;
  while Length(l[3]) > 0 and l[3][Length(l[3])] in "\n\r\t " do
    Remove(l[3]);
    i := i + 1;
  od;
  if Length(l[3]) = 0 then
    return [false, 1, i+1, 1];
  fi;
  hist := GAPInfo.History.Lines;
  if Length(hist) >= GAPInfo.History.MaxLines then
    # overrun, throw oldest line away
    Remove(hist, 1);
    GAPInfo.History.Last := GAPInfo.History.Last - 1;
  fi;
  Add(hist, l[3]);
  GAPInfo.History.Pos := Length(hist) + 1;
  if i = 0 then
    return [];
  else
    return [false, Length(l[3])+1, Length(l[3]) + i + 1];
  fi;
end;
##  C-p: previous line starting like current before point
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('P') mod 32) := function(l)
  local hist, n, start;
  if GAPInfo.History.MaxLines <= 0 then
    return [];
  fi;
  hist := GAPInfo.History.Lines;
  n := GAPInfo.History.Pos;
  # searching backward in history for line starting with input before cursor
  if l[4] = Length(l[3]) + 1 then
    start := l[3];
  else
    start := l[3]{[1..l[4]-1]};
  fi;
  while n > 1 do
    n := n - 1;
    if PositionSublist(hist[n], start) = 1 then
      GAPInfo.History.Pos := n;
      GAPInfo.History.Last := n;
      return [1, Length(l[3])+1, hist[n], l[4]];
    fi;
  od;
  # not found, delete rest of line and wrap over
  GAPInfo.History.Pos := Length(hist)+1;
  if Length(start) = Length(l[3]) then
    return [];
  else
    return [false, l[4], Length(l[3])+1];
  fi;
end;
# bind to C-p and map Up-key
BindKeysToGAPHandler("\020");
ReadlineInitLine("\"\\eOA\": \"\\C-p\"");
ReadlineInitLine("\"\\e[A\": \"\\C-p\"");

##  C-n: next line starting like current before point
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('N') mod 32) := function(l)
  local hist, n, start;
  if GAPInfo.History.MaxLines <= 0 then
    return [];
  fi;
  hist := GAPInfo.History.Lines;
  n := GAPInfo.History.Pos;
  if n > Length(hist) then
    n := 0;
  fi;
  # searching forward in history for line starting with input before cursor
  if l[4] = Length(l[3]) + 1 then
    start := l[3];
  else
    start := l[3]{[1..l[4]-1]};
  fi;
  while n < Length(hist) do
    n := n + 1;
    if PositionSublist(hist[n], start) = 1 then
      GAPInfo.History.Pos := n;
      GAPInfo.History.Last := n;
      return [1, Length(l[3])+1, hist[n], l[4]];
    fi;
  od;
  # not found, delete rest of line and wrap over
  GAPInfo.History.Pos := Length(hist)+1;
  if Length(start) = Length(l[3]) then
    return [];
  else
    return [false, l[4], Length(l[3])+1];
  fi;
end;
# bind to C-n and map Down-key
BindKeysToGAPHandler("\016");
ReadlineInitLine("\"\\eOB\": \"\\C-n\"");
ReadlineInitLine("\"\\e[B\": \"\\C-n\"");

##  ESC <:  beginning of history
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('<')) := function(l)
  if GAPInfo.History.MaxLines <= 0 or Length(GAPInfo.History.Lines) = 0 then
    return [];
  fi;
  GAPInfo.History.Pos := 1;
  GAPInfo.History.Last := 1;
  return [1, Length(l[3]), GAPInfo.History.Lines[1], 1];
end;
BindKeysToGAPHandler("\\e<");

##  ESC >:  end of history
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('>')) := function(l)
  if GAPInfo.History.MaxLines <= 0 or Length(GAPInfo.History.Lines) = 0 then
    return [];
  fi;
  GAPInfo.History.Pos := Length(GAPInfo.History.Lines);
  GAPInfo.History.Last := GAPInfo.History.Pos;
  return [1, Length(l[3]), GAPInfo.History.Lines[GAPInfo.History.Pos], 1];
end;
BindKeysToGAPHandler("\\e>");

##  C-o:  line after last choice from history (for executing consecutive
##        lines from the history
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('O') mod 32) := function(l)
  local n;
  n := GAPInfo.History.Last + 1;
  if GAPInfo.History.MaxLines <= 0 or Length(GAPInfo.History.Lines) < n then
    return [];
  fi;
  GAPInfo.History.Last := n;
  return [1, Length(l[3]), GAPInfo.History.Lines[n], 1];
end;
BindKeysToGAPHandler("\017");

##  C-r: previous line containing text between mark and point (including
##  the smaller, excluding the larger) 
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('R') mod 32) := function(l)
  local hist, n, txt, pos;
  if GAPInfo.History.MaxLines <= 0 then
    return [];
  fi;
  hist := GAPInfo.History.Lines;
  n := GAPInfo.History.Pos;
  # text to search
  if l[4] < l[5] then
    if l[5] > Length(l[3])+1 then
      l[5] := Length(l[3])+1;
    fi;
    txt := l[3]{[l[4]..l[5]-1]};
  else
    if l[5] < 1 then
      l[5] := 1;
    fi;
    txt := l[3]{[l[5]..l[4]-1]};
  fi;
  while n > 1 do
    n := n - 1;
    pos := PositionSublist(hist[n], txt);
    if pos <> fail then
      GAPInfo.History.Pos := n;
      return [1, Length(l[3])+1, hist[n], pos + Length(txt), pos];
    fi;
  od;
  # not found, do nothing and wrap over
  GAPInfo.History.Pos := Length(hist)+1;
  return [];
end;
BindKeysToGAPHandler("\022");

############################################################################
##  
#F  SaveCommandLineHistory( [<fname>], [append] )
#F  ReadCommandLineHistory( [<fname>] )
##  
##  Use the first command to write the currently saved command lines in the 
##  history to file <fname>. If not given the default file name `~/.gap_hist' 
##  is used. The second command prepends the lines from <fname> to the current
##  command line history (as much as possible when GAPInfo.History.MaxLines
##  is less than infinity).
##  
BindGlobal("SaveCommandLineHistory", function(arg)
  local fnam, append, hist, out, i;
  if Length(arg) > 0 then
    fnam := arg[1];
  else
    fnam := "~/.gap_hist";
  fi;
  if true in arg then
    append := true;
  else
    append := false;
  fi;
  hist := GAPInfo.History.Lines;
  out := OutputTextFile(fnam, append);
  if out = fail then
    return fail;
  fi;
  SetPrintFormattingStatus(out, false);
  for i in [1..Length(hist)] do
    AppendTo(fnam, hist[i], "\n");
  od;
  CloseStream(out);
  return Length(hist);
end);

BindGlobal("ReadCommandLineHistory", function(arg)
  local hist, fnam, s;
  hist := GAPInfo.History.Lines;
  if Length(hist) >= GAPInfo.History.MaxLines then
    return 0;
  fi;
  if Length(arg) > 0 and IsString(arg[1]) then
    fnam := arg[1];
  else
    fnam := "~/.gap_hist";
  fi;
  s := StringFile(fnam);
  if s = fail then
    return fail;
  fi;
  GAPInfo.History.Last := 0;
  s := SplitString(s, "", "\n");
  if Length(s) + Length(hist)  > GAPInfo.History.MaxLines then
    s := s{[Length(s)-GAPInfo.History.MaxLines+Length(hist)+1..Length(s)]};
  fi;
  hist{[Length(s)+1..Length(s)+Length(hist)]} := hist;
  hist{[1..Length(s)]} := s;
end);

###   Free:   C-g,  C-^

##  This deletes the content of current buffer line, when appending a space
##  would result in a sequence of space- and tab-characters followed by the
##  current prompt. Otherwise a space is inserted at point.
GAPInfo.DeletePrompts := true;
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR(' ')) :=  function(l)
  local txt, len, pr, i;
  if GAPInfo.DeletePrompts <> true or l[4] = 1 or l[3][l[4]-1] <> '>' then
    return [" "];
  fi;
  txt := l[3];
  len := Length(txt);
  pr := CPROMPT();
  Remove(pr);
  i := 1;
  while txt[i] in "\t " do 
    i := i+1;
  od;
  if len - i+1 = Length(pr) and txt{[i..len]} = pr then
    return [false, 1, i+Length(pr), 1];
  fi;
  return [" "];
end;
BindKeysToGAPHandler(" ");


# C-i: Completion
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('I') mod 32) := function(l)
  local pos, word, cand, i, c, j;
  pos := l[4]-1;
  while pos > 0 and IsAlphaChar(l[3][pos]) do 
    pos := pos-1;
  od;
  word := l[3]{[pos+1..l[4]-1]};
  cand := Filtered(IDENTS_BOUND_GVARS(), a-> PositionSublist(a, word) = 1);
  if Length(cand) = 0 then
    return [];
  elif Length(cand) = 1 then
    return [cand[1]{[Length(word)+1..Length(cand[1])]}];
  fi;
  i := Length(word);
  while true do
    if i = Length(cand[1]) then
      break;
    fi;
    c := cand[1][i+1];
    for j in [2..Length(cand)] do
      if Length(cand[j]) > i and cand[j][i+1] = c then
        j := j+1;
      else
        break;
      fi;
    od;
    if j <= Length(cand) then
      break;
    else
      i := i+1;
    fi;
  od;
  if i > Length(word) then
    return [cand[1]{[Length(word)+1..i]}];
  else
    return [];
  fi;
end;
BindKeysToGAPHandler("\011");

fi;

############################################################################
############################################################################
############################################################################
############################################################################
############################################################################
############################################################################
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
BindGlobal("LineEditKeyHandlers", []);
# args: [linestr, ch, ppos, length, yankstr]
# returns: [linestr, ppos, yankstr]
BindGlobal("LineEditKeyHandler", function(l)
  local res, lin;
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
MaxCommandLineHistory := 0;

# history position from previous line
LastPosCLH := 0;
# here we implement the command line handlers for the keys
# Ctrl-P, Ctrl-N, Ctrl-L, Esc-<, Esc->
# key number 0 is used as a hook for saving a new line in the history
BindGlobal("CommandLineHistoryHandler", function(l)
  local key, hist, n, m, start, res, i;
  key := l[2];
  hist := CommandLineHistory;
  if key = 0 then  # save line data
    # no trailing white space
    while Length(l[1]) > 0 and l[1][Length(l[1])] in "\n\r\t " do
      Unbind(l[1][Length(l[1])]);
    od;
    if MaxCommandLineHistory > 0 and 
       Length(hist) >= MaxCommandLineHistory+1 then
      # overrun, throw oldest line away
      for i in [2..Length(hist)-1] do
        hist[i] := hist[i+1];
      od;
      hist[Length(hist)] := l[1];
      if hist[1] > 2 then
        hist[1] := hist[1]-1;
      else
        hist[1] := Length(hist)+1;
      fi;
    else
      Add(hist, l[1]);
    fi;
    LastPosCLH := hist[1];
    hist[1] := Length(hist)+1;
    return [l[1], l[3], l[5]];
  elif key = 16 then  # CTR('P')
    # searching backward in history for line starting with input before 
    # cursor
    n := hist[1];
    if n < 2 then return [l[1],l[3],l[5]]; fi; 
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
        hist[1] := 1;
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
end);

# install the handlers for the history commands
for tmpclh in [0, 16, 14, 12, 316, 318] do
  LineEditKeyHandlers[tmpclh+1] := CommandLineHistoryHandler;
od;
Unbind(tmpclh);

if not IsBound(BindKeysToGAPHandler) then
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
  local fnam, hist, i;
  if Length(arg) > 0 then
    fnam := arg[1];
  else
    fnam := "~/.gap_hist";
  fi;
  hist := CommandLineHistory;
  PrintTo(fnam,"");
  for i in [2..Length(hist)] do
    AppendTo(fnam, hist[i], "\n");
  od;
end);

BindGlobal("ReadCommandLineHistory", function(arg)
  local fnam, hist, s, n;
  if Length(arg) > 0 then
    fnam := arg[1];
  else
    fnam := "~/.gap_hist";
  fi;
  hist := CommandLineHistory;
  s := StringFile(fnam);
  if IsString(s) then
    s := SplitString(s,"","\n");
    if MaxCommandLineHistory > 0 and 
       Length(s) + Length(hist) - 1 > MaxCommandLineHistory then
      n := MaxCommandLineHistory + 1 - Length(hist);
      s := s{[Length(s)-n+1..Length(s)]};
    fi;
    hist{[Length(s)+2..Length(s)+Length(hist)]} := hist{[2..Length(hist)]};
    hist{[2..Length(s)+1]} := s;
  fi;
end);
fi;

# Implementation of the default ESC-N and ESC-S behaviour described above.
AutomaticInputLines := [];
AutomaticInputLinesCounter := 1;
BindGlobal("DefaultEscNHandler", function(arg)
  local res;
  if AutomaticInputLinesCounter <= Length(AutomaticInputLines) then
    res := AutomaticInputLines[AutomaticInputLinesCounter];
    AutomaticInputLinesCounter := AutomaticInputLinesCounter + 1;
    return [res, Length(res)+1, arg[1][5]];
  else
    return ["",1,arg[1][5]];
  fi;
end);
LineEditKeyHandlers[334+1] := DefaultEscNHandler;

# ESC('S') calls Length(AutomaticInputLines) often ESC('N')
LineEditKeyHandlers[339+1] := function(arg) 
  AutomaticInputLinesCounter := 1;
  return Length(AutomaticInputLines);
end;

##  Standard behaviour to insert a character for the key.
##  We don't install this directly in LineEditKeyHandlers but this can be 
##  useful for writing other key handlers)
BindGlobal("LineEditInsert", function(l)
  local line;
  line := l[1]{[1..l[3]-1]};
  Add(line, CHAR_INT(l[2]));
  Append(line, l[1]{[l[3]..Length(l[1])]});
  return [line, l[3]+1, l[5]];
end);

##  This will be installed as handler for the space-key, it removes the prompts
##  "gap> ", "> ", "brk> " in beginning of lines when the trailing space is 
##  typed. This makes a special hack in the kernel unnecessary and it can
##  be switched off by setting 'GAPInfo.DeletePrompts := false;'.
GAPInfo.DeletePrompts := true;
BindGlobal("LineEditDelPrompt", function(l);
  if GAPInfo.DeletePrompts and l[1]{[1..l[3]-1]} in ["gap>", ">", "brk>"] then
    return [l[1]{[l[3]..Length(l[1])]}, 1, l[5]];
  else
    return LineEditInsert(l);
  fi;
end);
LineEditKeyHandlers[33] := LineEditDelPrompt;

############################################################################
##       readline interface functions

if not IsBound(GAPInfo.History) then
  GAPInfo.History := rec(MaxLines := -1, Lines := [], Pos := 0);
fi;
GAPInfo.History.AddLine := function(l)
  local hist, len;
  hist := GAPInfo.History;
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
  if hist.MaxLines > 0 and Length(hist.Lines) >= hist.MaxLines then
    # overrun, throw oldest line away
    Remove(hist.Lines, 1);
  fi;
  Add(hist.Lines, l);
  hist.Pos := Length(hist.Lines) + 1;
end;
GAPInfo.History.PrevLine := function(start)
  local hist, len, pos, first;
  hist := GAPInfo.History;
  len := Length(start);
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
end;



############################################################################
##  
