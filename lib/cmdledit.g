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
##  This file contains function for handling some keys in line edit mode.
##  It is only used if the GAP kernel was compiled to use the GNU
##  readline library.
##
##  To avoid using the readline library, pass '--without-readline' to
##  the configure script when compiling GAP.
##

# Declare the user preferences related to readline
# also if readline is not supported,
# in order to get them documented also in this case.
DeclareUserPreference( rec(
  name:= ["HistoryMaxLines", "SaveAndRestoreHistory"],
  description:= [
    "<C>HistoryMaxLines</C> is the maximal amount of input lines held in \
&GAP;'s command line history.",
    "If <C>SaveAndRestoreHistory</C> is <K>true</K> then &GAP; saves its \
command line history before terminating a &GAP; session, and prepends the \
stored history when &GAP; is started. \
If this is enabled it is suggested to set <C>HistoryMaxLines</C> to some \
finite value. \
It is also possible to set <C>HistoryMaxLines</C> to <Ref Var=\"infinity\"/> \
to keep arbitrarily many lines.",
    "These preferences are ignored if &GAP; was not compiled with \
readline support.",
    ],
  default:= [10000, true],
  check:= function(max, save)
    return ((IsInt( max ) and 0 <= max) or max = infinity)
           and save in [true, false];
  end
  )
);

DeclareUserPreference( rec(
  name := "Autocompleter",
  description := [
                   "Set how names are filtered during tab-autocomplete, \
this can be: \
<C>\"default\"</C>: case-sensitive matching. \
<C>\"case-insensitive\"</C>: case-insensitive matching, \
or a record with two components named <C>filter</C> and \
<C>completer</C>, which are both functions which take two arguments. \
<C>filter</C> takes a list of names and a partial identifier and returns \
all the members of <C>names</C> which are a valid extension of the partial \
identifier. \
<C>completer</C> takes a list of names and a partial identifier and \
returns the partial identifier as extended as possible (it may also change \
the identifier, for example to correct the case, or spelling mistakes), or \
returns <K>fail</K> to leave the existing partial identifier.",
"This preference is ignored if &GAP; was not compiled with \
readline support.",
  ],
  default := "default",
  ) );

DeclareUserPreference( rec(
  name:= "HistoryBackwardSearchSkipIdenticalEntries",
  description:= [
    "When a command is executed multiple times, it is also stored in history \
multiple times. Setting this option to <K>true</K> skips identical entries \
when searching backwards in history."
    ],
  default:= false,
  values:= [ true, false ],
  multi:= false,
  ) );


if GAPInfo.CommandLineOptions.E then
############################################################################
##       readline interface functions
GAPInfo.UseReadline := true;

##  <#GAPDoc Label="readline">
##  <Section Label="sec:readline">
##  <Heading>Editing using the <C>readline</C> library</Heading>
##
##  The  descriptions  in  this  section   are  valid  only  if  your  &GAP;
##  installation uses the <C>readline</C>  library for command line editing.
##  You  can check  by <C>IsBound(GAPInfo.UseReadline);</C>  if this  is the
##  case. <P/>
##
##  You        can        use        all       the        features        of
##  <C>readline</C>,         as         for        example         explained
##  in  <URL>https://tiswww.case.edu/php/chet/readline/rluserman.html</URL>.
##  Therefore  the  command  line  editing   in  &GAP;  is  similar  to  the
##  <C>bash</C> shell  and many other  programs. On a Unix/Linux  system you
##  may also have a manpage, try <C>man readline</C>. <P/>
##
##  Compared  to the  command line  editing which  was used  in &GAP;  up to
##  version&nbsp;4.4 (or compared to  not using the <C>readline</C> library)
##  using <C>readline</C> has several advantages:
##  <List>
##  <Item>Most keys still do the  same as explained in
##  <Ref Sect="Line Editing"/> (in the default configuration).
##  </Item>
##  <Item>There are many additional commands, e.g. undoing (<B>Ctrl-_</B>,
##  keyboard macros (<B>Ctrl-x(</B>, <B>Ctrl-x)</B> and <B>Ctrl-xe</B>),
##  file name completion (hit <B>Esc</B> two or four times),
##  showing matching parentheses,
##  <C>vi</C>-style key bindings, deleting and yanking text, ...</Item>
##  <Item>Lines which are longer than a physical terminal row can be edited
##  more conveniently.</Item>
##  <Item>Arbitrary unicode characters can be typed into string literals.
##  </Item>
##  <Item>The   key   bindings   can   be  configured,   either   via   your
##  <File>~/.inputrc</File>   file   or   by  &GAP;   commands,   see   <Ref
##  Subsect="ssec:readlineCustom"/>.</Item>
##  <Item>The command line history can be saved to and read from a file, see
##  <Ref Subsect="ssec:cmdlinehistory"/>.</Item>
##  <!-- <Item>demo mode <Ref Subsect="ssec:demoreadline"/>???</Item> -->
##  <Item>Adventurous users can even implement completely new
##  command line editing functions on &GAP; level, see <Ref
##  Subsect="ssec:readlineUserFuncs"/>.</Item>
##
##  </List>
##  <P/>
##
##  <Subsection Label="ssec:readlineCustom">
##  <Index Key="ReadlineInitLine"><C>ReadlineInitLine</C></Index>
##  <Heading>Readline customization</Heading>
##
##  You can use your readline  init file (by default <File>~/.inputrc</File>
##  on Unix/Linux) to  customize key bindings. If you want  settings be used
##  only within  &GAP; you  can write them  between lines  containing <C>$if
##  GAP</C> and <C>$endif</C>. For a detailed documentation of the available
##  settings and functions see <URL Text="here">
##  https://tiswww.case.edu/php/chet/readline/rluserman.html</URL>.
##
##  <Listing Type="From readline init file">
##  $if GAP
##    set blink-matching-paren on
##    "\C-x\C-o": dump-functions
##    "\ep": kill-region
##  $endif
##  </Listing>
##
##  Alternatively,       from      within       &GAP;      the       command
##  <C>ReadlineInitLine(<A>line</A>);</C> can be  used, where <A>line</A> is
##  a string containing a line as in the init file.
##  <P/>
##
##  Caveat:  &GAP;   overwrites  the  following  keys   (after  reading  the
##  <File>~/.inputrc</File>  file):  <C>\C-g</C>, <C>\C-i</C>,  <C>\C-n</C>,
##  <C>\C-o</C>,   <C>\C-p</C>,  <C>\C-r</C>,   <C>\C-\</C>,  <C>\e&lt;</C>,
##  <C>\e&gt;</C>,   <C>Up</C>,   <C>Down</C>,   <C>TAB</C>,   <C>Space</C>,
##  <C>PageUp</C>,  <C>PageDown</C>.  So,  do  not redefine  these  in  your
##  <File>~/.inputrc</File>.
##  <P/>
##
##  Note that after pressing <B>Ctrl-v</B> the next special character is
##  input verbatim. This is very useful to bind keys or key sequences.
##  For example, binding the function key <B>F3</B> to the command
##  <C>kill-whole-line</C> by using the sequence <B>Ctrl-v</B> <B>F3</B>
##  looks on many terminals like this:
##  <C>ReadlineInitLine("\"^[OR\":kill-whole-line");</C>.
##  (You can get the line back later with <B>Ctrl-y</B>.)
##  <P/>
##
##  The <B>Ctrl-g</B> key can be used to type any unicode character by its code
##  point. The number of the character can either be given as a count, or if the
##  count is one the input characters before the cursor are taken (as decimal
##  number or as hex number which starts with <C>0x</C>. For example, the
##  double stroke character &#8484; can be input by any of the three key
##  sequences <B>Esc 8484 Ctrl-g</B>, <B>8484 Ctrl-g</B> or <B>0x2124
##  Ctrl-g</B>.
##  <P/>
##
##  Some terminals bind the <B>Ctrl-s</B> and <B>Ctrl-q</B> keys to stop and
##  restart terminal  output. Furthermore,  sometimes <B>Ctrl-\</B>  quits a
##  program. To disable this behaviour (and maybe use these keys for command
##  line editing)  you can use  <C>Exec("stty stop undef; stty  start undef;
##  stty quit undef");</C> in your &GAP; session or your <F>gaprc</F> file
##  (see <Ref Sect="sect:gap.ini"/>).
##  <P/>
##  </Subsection>
##
##  <Subsection Label="ssec:cmdlinehistory">
##  <Heading>The command line history</Heading>
##
##  &GAP; can save your input lines for later reuse. The keys <B>Ctrl-p</B>
##  (or <B>Up</B>), <B>Ctrl-n</B> (or <B>Down</B>),
##  <B>ESC&lt;</B> and <B>ESC&gt;</B> work as documented in <Ref
##  Sect="Line Editing"/>, that is they scroll backward and
##  forward in the history or go to its beginning or end.
##  Also, <B>Ctrl-o</B> works as documented, it is useful for repeating a
##  sequence of previous lines.
##  (But <B>Ctrl-l</B> clears the screen as in other programs.)
##  <P/>
##
##  The command line history can be used across several instances of &GAP;
##  via the following two commands.
##  </Subsection>
##
##  <ManSection >
##  <Func Arg="[fname], [app]" Name="SaveCommandLineHistory" />
##  <Returns><K>fail</K> or number of saved lines</Returns>
##  <Func Arg="[fname], [app]" Name="ReadCommandLineHistory" />
##  <Returns><K>fail</K> or number of added lines</Returns>
##
##  <Description>
##  The first  command saves the  lines in the  command line history  to the
##  file given by  the string <A>fname</A>. The default  for <A>fname</A> is
##  <F>history</F> in the user's &GAP; root path <C>GAPInfo.UserGapRoot</C>
##  or  <F>"~/.gap_hist"</F>  if this directory does not exist.
##  If   the  optional  argument  <A>app</A>  is
##  <K>true</K> then the lines are appended  to that file otherwise the file
##  is overwritten.
##  <P/>
##  The  second command  is  the  converse, it  reads  the  lines from  file
##  <A>fname</A>. If the optional argument <A>app</A> is true the lines
##  are appended to the history, else it <Emph>prepends</Emph> them.
##  <P/>
##  By  default, the command line history stores up to 1000 input lines.
##  command  line  history. This number may be restricted or enlarged via
##  via <C>SetUserPreference("HistoryMaxLines", num);</C> which may be set
##  to a non negative number <C>num</C> to store up to <C>num</C> input
##  lines or to <K>infinity</K> to store arbitrarily many lines.
##  An automatic storing and restoring  of the command line history can
##  be configured via
##  <C>SetUserPreference("SaveAndRestoreHistory", true);</C>.
##  <P/>
##  Note that these functions are only available if your &GAP; is configured
##  to use the <C>readline</C> library.
##  </Description>
##  </ManSection>
##
##  <Subsection Label="ssec:readlineUserFuncs">
##  <Index Key="InstallReadlineMacro"><C>InstallReadlineMacro</C></Index>
##  <Index Key="InvocationReadlineMacro"><C>InvocationReadlineMacro</C></Index>
##
##  <Heading>Writing your own command line editing functions</Heading>
##  It is possible to write new command line editing functions in &GAP; as
##  follows.
##  <P/>
##  The functions have one argument <A>l</A> which is a list with five
##  entries of the form <C>[count, key, line, cursorpos, markpos]</C> where
##  <C>count</C> and <C>key</C> are the last pressed key and its count
##  (these are not so useful here because users probably do not want to
##  overwrite the binding of a single key), then <C>line</C> is a string
##  containing the line typed so far, <C>cursorpos</C> is the current
##  position of the cursor (point), and <C>markpos</C> the current position
##  of the mark.
##  <P/>
##  The result of such a  function must  be a list which can have various
##  forms:
##  <List >
##  <Mark><C>[str]</C></Mark>
##  <Item>with a string <C>str</C>. In this case the text <C>str</C> is
##  inserted at the cursor position.</Item>
##  <Mark><C>[kill, begin, end]</C></Mark>
##  <Item> where <C>kill</C> is <K>true</K> or <K>false</K> and <C>begin</C>
##  and <C>end</C> are positions on the input line. This removes the text
##  from the lower position to before the higher position. If <C>kill</C>
##  is <K>true</K> the text is killed, i.e. put in the kill ring for later
##  yanking.
##  </Item>
##  <Mark><C>[begin, end, str]</C></Mark>
##  <Item>where <C>begin</C> and <C>end</C> are positions on the input line
##  and <C>str</C> is a string.
##  Then the text from position <C>begin</C> to before <C>end</C> is
##  substituted by <C>str</C>.
##  </Item>
##  <Mark><C>[1, lstr]</C></Mark>
##  <Item>
##  where <C>lstr</C> is a list of strings. Then these strings are displayed
##  like a list of possible completions. The input line is not changed.
##  </Item>
##  <Mark><C>[2, chars]</C></Mark>
##  <Item>where <C>chars</C> is a string. The characters from <C>chars</C>
##  are used as the next characters from the input. (At most 512 characters
##  are possible.)</Item>
##  <Mark><C>[100]</C></Mark>
##  <Item>This rings the bell as configured in the terminal.</Item>
##  </List>
##
##  In the first three cases the result list can contain a position as a
##  further entry, this becomes the new cursor position. Or it
##  can contain two positions as further entries, these become the new
##  cursor position and the new position of the mark.
##  <P/>
##
##  Such a function can be installed as a macro for <C>readline</C> via
##  <C>InstallReadlineMacro(name, fun);</C> where <C>name</C> is a string
##  used as name of the macro and <C>fun</C> is a function as above.
##  This macro can be called by a key sequence which is returned by
##  <C>InvocationReadlineMacro(name);</C>.
##  <P/>
##  As an example we define a function which puts double quotes around the
##  word under or before the cursor position. The space character, the
##  characters in <C>"(,)"</C>, and the beginning and end of the line
##  are considered as word boundaries. The function is then installed as a
##  macro and bound to the key sequence <B>Esc</B> <B>Q</B>.
##  <P/>
##  <Log>
##  gap> EditAddQuotes := function(l)
##  >   local str, pos, i, j, new;
##  >   str := l[3];
##  >   pos := l[4];
##  >   i := pos;
##  >   while i > 1 and (not str[i-1] in ",( ") do
##  >     i := i-1;
##  >   od;
##  >   j := pos;
##  >   while IsBound(str[j]) and not str[j] in ",) " do
##  >     j := j+1;
##  >   od;
##  >   new := "\"";
##  >   Append(new, str{[i..j-1]});
##  >   Append(new, "\"");
##  >   return [i, j, new];
##  > end;;
##  gap> InstallReadlineMacro("addquotes", EditAddQuotes);
##  gap> invl := InvocationReadlineMacro("addquotes");;
##  gap> ReadlineInitLine(Concatenation("\"\\eQ\":\"",invl,"\""));;
##  </Log>
##  </Subsection>
##
##  </Section>
##  <#/GAPDoc>
##


if not IsBound(GAPInfo.CommandLineEditFunctions) then
  GAPInfo.CommandLineEditFunctions := rec(
  # This is the GAP function called by the readline handler function
  # handled-by-GAP (GAP_rl_func in src/sysfiles.c).
  KeyHandler := function(l)
    local macro, res, key;
    # remember this key
    key := l[2];
    res:=[];
    if l[2] >= 1000 then
      macro := QuoInt(l[2], 1000);
      if IsBound(GAPInfo.CommandLineEditFunctions.Macros.(macro)) then
        res := GAPInfo.CommandLineEditFunctions.Macros.(macro)(l);
      fi;
    else
      if IsBound(GAPInfo.CommandLineEditFunctions.Functions.(l[2])) then
        res := GAPInfo.CommandLineEditFunctions.Functions.(l[2])(l);
      fi;
    fi;
    GAPInfo.CommandLineEditFunctions.LastKey := key;
    return res;
  end,
  Macros := rec(),
  Functions := rec(),
  # here we save readline init lines for post restore
  RLInitLines := [],
  RLKeysGAPHandler := []
  );
  if IsHPCGAP then
    GAPInfo.CommandLineEditFunctions :=
        AtomicRecord(GAPInfo.CommandLineEditFunctions);
  fi;
fi;

# wrapper around kernel functions to store data for post restore function
BindGlobal("ReadlineInitLine", function(str)
  READLINEINITLINE(ShallowCopy(str));
  Add(GAPInfo.CommandLineEditFunctions.RLInitLines, str);
end);
BindGlobal("BindKeysToGAPHandler", function(str)
  BINDKEYSTOGAPHANDLER(ShallowCopy(str));
  Add(GAPInfo.CommandLineEditFunctions.RLKeysGAPHandler, str);
end);

CallAndInstallPostRestore( function()
  local clef, l, a;
  clef := GAPInfo.CommandLineEditFunctions;
  l := clef.RLKeysGAPHandler;
  clef.RLKeysGAPHandler := [];
  for a in l do
    BindKeysToGAPHandler(a);
  od;
  l := clef.RLInitLines;
  clef.RLInitLines := [];
  for a in l do
    ReadlineInitLine(a);
  od;
end);

# bind macro to a key sequence
BindGlobal("BindKeySequence", function(seq, subs)
  ReadlineInitLine(Concatenation("\"", seq, "\": \"", subs, "\""));
end);

# general utility functions
# ringing bell according to terminal configuration (rl_ding)
GAPInfo.CommandLineEditFunctions.Functions.RingBell := function(arg)
  return [100];
end;
# sends <Return> and so calls accept-line
GAPInfo.CommandLineEditFunctions.Functions.AcceptLine := function(arg)
  return [101];
end;
# cands is list of strings, this displays them as matches for completion
# (rl_display_match_list)
GAPInfo.CommandLineEditFunctions.Functions.DisplayMatches := function(cand)
   return [1, cand];
end;
# this inserts a sequence of keys given as string into the input stream
# (rl_stuff_char, up to 512 characters are accepted)
GAPInfo.CommandLineEditFunctions.Functions.StuffChars := function(str)
  return [2, str];
end;

GAPInfo.CommandLineEditFunctions.Functions.UnicodeChar := function(l)
  local helper, j, i, hc, hex, c, pos, k;
  # same as GAPDoc's UNICODE_RECODE.UTF8UnicodeChar
  helper := function ( n )
    local  res, a, b, c, d;
    res := "";
    if n < 0  then
        return fail;
    elif n < 128  then
        Add( res, CHAR_INT( n ) );
    elif n < 2048  then
        a := n mod 64;
        b := (n - a) / 64;
        Add( res, CHAR_INT( b + 192 ) );
        Add( res, CHAR_INT( a + 128 ) );
    elif n < 65536  then
        a := n mod 64;
        n := (n - a) / 64;
        b := n mod 64;
        c := (n - b) / 64;
        Add( res, CHAR_INT( c + 224 ) );
        Add( res, CHAR_INT( b + 128 ) );
        Add( res, CHAR_INT( a + 128 ) );
    elif n < 2097152  then
        a := n mod 64;
        n := (n - a) / 64;
        b := n mod 64;
        n := (n - b) / 64;
        c := n mod 64;
        d := (n - c) / 64;
        Add( res, CHAR_INT( d + 240 ) );
        Add( res, CHAR_INT( c + 128 ) );
        Add( res, CHAR_INT( b + 128 ) );
        Add( res, CHAR_INT( a + 128 ) );
    else
        return fail;
    fi;
    return res;
  end;
  # if count=1 we consider the previous characters
  if l[1] = 1 then
    j := l[4]-1;
    i := j;
    hc := "0123456789abcdefABCDEF";
    while i > 0 and l[3][i] in hc do
      i := i-1;
    od;
    if i>1 and l[3][i] = 'x' and l[3][i-1] = '0' then
      hex := true;
      i := i-1;
    else
      hex := false;
      i := i+1;
    fi;
    c := 0;
    if hex then
      for k in [i+2..j] do
        pos := Position(hc, l[3][k]);
        if pos > 16 then
          pos := pos-6;
        fi;
        c := c*16+(pos-1);
      od;
    else
      for k in [i..j] do
        pos := Position(hc, l[3][k]);
        c := c*10 + (pos-1);
      od;
    fi;
    return [i, j+1, helper(c)];
  else
    return [helper(l[1])];
  fi;
end;
GAPInfo.CommandLineEditFunctions.Functions.7 :=
                       GAPInfo.CommandLineEditFunctions.Functions.UnicodeChar;
BindKeysToGAPHandler("\007");


# The history is stored within the GAPInfo record. Several GAP level
# command line edit functions below deal with the history. The maximal
# number of lines in the history is configurable via a user preference.
# TODO: should it be made thread-local in HPC-GAP?
if not IsBound(GAPInfo.History) then
  GAPInfo.History := rec(Lines := [], Pos := 0, Last := 0);
fi;


## We use key 0 (not bound) to add line to history.
GAPInfo.CommandLineEditFunctions.Functions.AddHistory := function(l)
  local i, max, hist;
  max := UserPreference("HistoryMaxLines");
  # no history
  if max <= 0 then
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
  while Length(hist) >= max do
    # overrun, throw oldest line away
    Remove(hist, 1);
    GAPInfo.History.Last := GAPInfo.History.Last - 1;
  od;
  Add(hist, l[3]);
  GAPInfo.History.Pos := Length(hist) + 1;
  if i = 0 then
    return [];
  else
    return [false, Length(l[3])+1, Length(l[3]) + i + 1];
  fi;
end;
GAPInfo.CommandLineEditFunctions.Functions.0 :=
                       GAPInfo.CommandLineEditFunctions.Functions.AddHistory;

##  C-p: previous line starting like current before point
GAPInfo.CommandLineEditFunctions.Functions.BackwardHistory := function(l)
  local hist, n, start;
  if UserPreference("HistoryMaxLines") <= 0 then
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
      if UserPreference("HistoryBackwardSearchSkipIdenticalEntries") and hist[n] = l[3] then
        continue;
      fi;
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
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('P') mod 32) :=
                GAPInfo.CommandLineEditFunctions.Functions.BackwardHistory;
BindKeysToGAPHandler("\020");
ReadlineInitLine("\"\\eOA\": \"\\C-p\"");
ReadlineInitLine("\"\\e[A\": \"\\C-p\"");

##  C-n: next line starting like current before point
GAPInfo.CommandLineEditFunctions.Functions.ForwardHistory := function(l)
  local hist, n, start;
  if UserPreference("HistoryMaxLines") <= 0 then
    return [];
  fi;
  hist := GAPInfo.History.Lines;
  n := GAPInfo.History.Pos;
  if n > Length(hist) then
    # special case on empty line, we don't wrap to the beginning, but
    # the position of the last history use
    if Length(l[3]) = 0 and GAPInfo.History.Last < Length(hist) then
      GAPInfo.History.Pos := GAPInfo.History.Last;
      n := GAPInfo.History.Pos;
    else
      n := 0;
    fi;
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
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('N') mod 32) :=
                GAPInfo.CommandLineEditFunctions.Functions.ForwardHistory;
BindKeysToGAPHandler("\016");
ReadlineInitLine("\"\\eOB\": \"\\C-n\"");
ReadlineInitLine("\"\\e[B\": \"\\C-n\"");

##  ESC <:  beginning of history
GAPInfo.CommandLineEditFunctions.Functions.BeginHistory := function(l)
  if UserPreference("HistoryMaxLines") <= 0 or
                                  Length(GAPInfo.History.Lines) = 0 then
    return [];
  fi;
  GAPInfo.History.Pos := 1;
  GAPInfo.History.Last := 1;
  return [1, Length(l[3]), GAPInfo.History.Lines[1], 1];
end;
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('<')) :=
                    GAPInfo.CommandLineEditFunctions.Functions.BeginHistory;
BindKeysToGAPHandler("\\e<");

##  ESC >:  end of history
GAPInfo.CommandLineEditFunctions.Functions.EndHistory := function(l)
  if UserPreference("HistoryMaxLines") <= 0 or
                                  Length(GAPInfo.History.Lines) = 0 then
    return [];
  fi;
  GAPInfo.History.Pos := Length(GAPInfo.History.Lines);
  GAPInfo.History.Last := GAPInfo.History.Pos;
  return [1, Length(l[3]), GAPInfo.History.Lines[GAPInfo.History.Pos], 1];
end;
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('>')) :=
                         GAPInfo.CommandLineEditFunctions.Functions.EndHistory;
BindKeysToGAPHandler("\\e>");

##  C-o:  line after last choice from history (for executing consecutive
##        lines from the history
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('O') mod 32) := function(l)
  local n, cf;
  cf := GAPInfo.CommandLineEditFunctions;
  if IsBound(cf.ctrlo) then
    n := GAPInfo.History.Last + 1;
    if UserPreference("HistoryMaxLines") <= 0 or
                                  Length(GAPInfo.History.Lines) < n then
      return [];
    fi;
    GAPInfo.History.Last := n;
    Unbind(cf.ctrlo);
    return [1, Length(l[3]), GAPInfo.History.Lines[n], 1];
  else
    cf.ctrlo := true;
    return GAPInfo.CommandLineEditFunctions.Functions.StuffChars("\015\017");
  fi;
end;
BindKeysToGAPHandler("\017");

##  C-r: previous line containing text between mark and point (including
##  the smaller, excluding the larger)
GAPInfo.CommandLineEditFunctions.Functions.HistorySubstring := function(l)
  local hist, n, txt, pos;
  if UserPreference("HistoryMaxLines") <= 0 then
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
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('R') mod 32) :=
                   GAPInfo.CommandLineEditFunctions.Functions.HistorySubstring;
BindKeysToGAPHandler("\022");

############################################################################
##
#F  SaveCommandLineHistory( [<fname>], [append] )
#F  ReadCommandLineHistory( [<fname>] )
##
##  Use the first command to write the currently saved command lines in the
##  history to file <fname>. If not given the default file name 'history'
##  in GAPInfo.UserGapRoot or '~/.gap_hist' is used.
##  The second command prepends the lines from <fname> to the current
##  command line history (as much as possible when the user preference
##  HistoryMaxLines is less than infinity).
##
BindGlobal("SaveCommandLineHistory", function(arg)
  local  fnam, append, hist, out;

  if Length(arg) > 0 then
    fnam := arg[1];
  else
    if IsExistingFile(GAPInfo.UserGapRoot) then
      fnam := Concatenation(GAPInfo.UserGapRoot, "/history");
    else
      fnam := UserHomeExpand("~/.gap_hist");
    fi;
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
  WriteAll(out,JoinStringsWithSeparator(hist,"\n"));
  WriteAll(out,"\n");
  CloseStream(out);
  return Length(hist);
end);

BindGlobal("ReadCommandLineHistory", function(arg)
  local hist, max, fnam, s, append;
  hist := GAPInfo.History.Lines;
  max := UserPreference("HistoryMaxLines");
  if Length(arg) > 0 and IsString(arg[1]) then
    fnam := arg[1];
  else
    if IsExistingFile(GAPInfo.UserGapRoot) then
      fnam := Concatenation(GAPInfo.UserGapRoot, "/history");
    else
      fnam := UserHomeExpand("~/.gap_hist");
    fi;
  fi;
  if true in arg then
    append := true;
  else
    append := false;
  fi;
  s := StringFile(fnam);
  if s = fail then
    return fail;
  fi;

  s := SplitString(s, "", "\n");

  if append then
    if Length(s) > max then
        s := s{[1..max]};
    fi;
    Append(hist, s);
    if Length(hist) > max then
        hist := hist{[Length(hist) - max..Length(hist)]};
    fi;
  else
    if Length(hist) >= max then
        return 0;
    fi;
    if Length(s) + Length(hist)  > max then
        s := s{[Length(s)-max+Length(hist)+1..Length(s)]};
    fi;
    hist := Concatenation(s, hist);
  fi;
  GAPInfo.History.Lines := hist;
  GAPInfo.History.Last := 0;
  GAPInfo.History.Pos := Length(hist) + 1;
  return Length(s);
end);

###   Free:   C-g,  C-^

##  This deletes the content of current buffer line, when appending a space
##  would result in a sequence of space- and tab-characters followed by the
##  current prompt. Otherwise a space is inserted at point.
GAPInfo.DeletePrompts := true;
GAPInfo.CommandLineEditFunctions.Functions.SpaceDeletePrompt :=  function(l)
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
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR(' ')) :=
                GAPInfo.CommandLineEditFunctions.Functions.SpaceDeletePrompt;
BindKeysToGAPHandler(" ");

# These methods implement 'extender' for standard case sensitive and
# case insensitive matching.
# These methods take a list of candidates (cand), and the current
# partially written identifier from the command line. They return a
# replacement for 'identifier'. This extends 'identifier'
# to include all characters which occur in all members of cand.
# In the case-insensitive case this matching is done case-insensitively,
# and we also change the existing letters of the identifier to match
# identifiers.
# When there is no extension or change, these methods return 'fail'.
BindGlobal("STANDARD_EXTENDERS", rec(
  caseSensitive := function(cand, word)
      local i, j, c, match;
      i := Length(word);
      while true do
        if i = Length(cand[1]) then
          break;
        fi;
        c := cand[1][i+1];
        match := true;
        for j in [2..Length(cand)] do
          if Length(cand[j]) <= i or cand[j][i+1] <> c then
            match := false;
            break;
          fi;
        od;
        if not match then
          break;
        else
          i := i+1;
        fi;
      od;
      if i > Length(word) then
        return cand[1]{[1..i]};
      else
        return fail;
      fi;
    end,

    caseInsensitive := function(cand, word)
      local i, j, c, lowword, filtequal, match;
      # Check if exactly 'word' exists, ignoring case.
      lowword := LowercaseString(word);
      # If there are several equal words, just pick the first one...
      filtequal := First(cand, a -> LowercaseString(a) = lowword);
      if filtequal <> fail then
        return filtequal;
      fi;
      i := Length(word);
      while true do
        if i = Length(cand[1]) then
          break;
        fi;
        c := LowercaseChar(cand[1][i+1]);
        match := true;
        for j in [2..Length(cand)] do
          if Length(cand[j]) <= i or LowercaseChar(cand[j][i+1]) <> c then
            match := false;
            break;
          fi;
        od;
        if not match then
          break;
        else
          i := i+1;
        fi;
      od;
      if i >= Length(word) then
        return cand[1]{[1..i]};
      else
        return fail;
      fi;
    end,
));

# C-i: Completion as GAP level function
GAPInfo.CommandLineEditFunctions.Functions.Completion := function(l)
    local cf, pos, word, wordplace, idbnd, i, cmps, r, searchlist, cand, j,
          completeFilter, completeExtender, extension, hasbang;

      completeFilter := function(filterlist, partial)
        local pref, lowpartial;
        pref := UserPreference("Autocompleter");
        if pref = "case-insensitive" then
          lowpartial := LowercaseString(partial);
          return Filtered(filterlist,
                          a -> PositionSublist(LowercaseString(a), lowpartial) = 1);
        elif pref = "default" then
          return Filtered(filterlist, a-> PositionSublist(a, partial) = 1);
        elif IsRecord(pref) and IsFunction(pref.completer) then
          return pref.completer(filterlist, partial);
        else
          ErrorNoReturn("Invalid setting of UserPreference 'Autocompleter'");
        fi;
    end;

    completeExtender := function(filterlist, partial)
      local pref;
      pref := UserPreference("Autocompleter");
      if pref = "case-insensitive" then
        return STANDARD_EXTENDERS.caseInsensitive(filterlist, partial);
      elif pref = "default" then
        return STANDARD_EXTENDERS.caseSensitive(filterlist, partial);
      elif IsRecord(pref) and IsFunction(pref.extender) then
        return pref.extender(filterlist, partial);
      else
        ErrorNoReturn("Invalid setting of UserPreference 'Autocompleter'");
      fi;
    end;

    # check if Ctrl-i was hit repeatedly in a row
  cf := GAPInfo.CommandLineEditFunctions;
  if Length(l)=6 and l[6] = true and cf.LastKey = 9 then
    cf.tabcount := cf.tabcount + 1;
  else
    cf.tabcount := 1;
    Unbind(cf.tabrec);
    Unbind(cf.tabbang);
    Unbind(cf.tabcompnam);
  fi;
  pos := l[4]-1;
  # in whitespace in beginning of line \t is just inserted
  if ForAll([1..pos], i -> l[3][i] in " \t") then
     return ["\t"];
  fi;
  # find word to complete
  while pos > 0 and l[3][pos] in IdentifierLetters do
    pos := pos-1;
  od;
  wordplace := [pos+1, l[4]-1];
  word := l[3]{[wordplace[1]..wordplace[2]]};
  # see if we are in the case of a component name
  while pos > 0 and l[3][pos] in " \n\t\r" do
    pos := pos-1;
  od;
  idbnd := IDENTS_BOUND_GVARS();
  if pos > 0 and l[3][pos] = '.' then
    cf.tabcompnam := true;
    if cf.tabcount = 1 then
      # try to find name of component object
      i := pos;
      while i > 0 and (l[3][i] in IdentifierLetters or l[3][i] in ".!") do
        i := i-1;
      od;
      cmps := SplitString(l[3]{[i+1..pos]}, ".");
      hasbang := [];
      i := Length(cmps);
      while i > 0 do
        # distinguish '.' from '!.' and record for each component which was used
        if Last(cmps[i]) = '!' then
            hasbang[i] := true;
            Remove(cmps[i]); # remove the trailing '!'
        else
            hasbang[i] := false;
        fi;
        NormalizeWhitespace(cmps[i]);
        if not IsValidIdentifier(cmps[i]) then
            break;
        fi;
        i := i-1;
      od;
      hasbang := hasbang{[i+1..Length(cmps)]};
      cmps := cmps{[i+1..Length(cmps)]};
      r := fail;
      if Length(cmps) > 0 and cmps[1] in idbnd then
        r := ValueGlobal(cmps[1]);
        for j in [2..Length(cmps)] do
          if not hasbang[j-1] and IsRecord(r) and IsBound(r.(cmps[j])) then
            r := r.(cmps[j]);
          elif hasbang[j-1] and (IsRecord(r) or IsComponentObjectRep(r)) and IsBound(r!.(cmps[j])) then
            r := r!.(cmps[j]);
          else
            r := fail;
            break;
          fi;
        od;
      fi;
      if IsRecord(r) or IsComponentObjectRep(r) then
        cf.tabrec := r;
        cf.tabbang := hasbang[Length(cmps)];
      fi;
    fi;
  fi;
  # now produce the searchlist
  if IsBound(cf.tabrec) then
    # the first two <TAB> hits try existing component names only first
    if cf.tabbang then
      searchlist := ShallowCopy(NamesOfComponents(cf.tabrec));
    elif IsRecord(cf.tabrec) then
      searchlist := ShallowCopy(RecNames(cf.tabrec));
    else
      searchlist := [];
    fi;
    if cf.tabcount > 2 then
      Append(searchlist, ALL_RNAMES());
    fi;
  else
    # complete variable name
    searchlist := idbnd;
  fi;

  cand := completeFilter(searchlist, word);
  #  in component name search we try again with all names if this is empty
  if IsBound(cf.tabcompnam) and Length(cand) = 0 and cf.tabcount < 3 then
    searchlist := ALL_RNAMES();
    cand := completeFilter(searchlist, word);
  fi;

  if (not IsBound(cf.tabcompnam) and cf.tabcount = 2) or
     (IsBound(cf.tabcompnam) and cf.tabcount in [2,4]) then
    if Length(cand) > 0 then
      # we prepend the partial word which was completed
      return GAPInfo.CommandLineEditFunctions.Functions.DisplayMatches(
                                        Concatenation([word], Set(cand)));
    else
      # ring the bell
      return GAPInfo.CommandLineEditFunctions.Functions.RingBell();
    fi;
  fi;
  if Length(cand) = 0 then
    return [];
  elif Length(cand) = 1 then
      return [ wordplace[1], wordplace[2]+1, cand[1]{[1..Length(cand[1])]}];
  fi;
  extension := completeExtender(cand, word);
  if extension = fail then
    return [];
  else
    return [ wordplace[1], wordplace[2] + 1, extension ];
  fi;
end;
GAPInfo.CommandLineEditFunctions.Functions.(INT_CHAR('I') mod 32) :=
                     GAPInfo.CommandLineEditFunctions.Functions.Completion;
BindKeysToGAPHandler("\011");

#############################################################################
##
##  Simple utilities to create an arbitrary number of macros
##
# name a string, fun a function
InstallReadlineMacro := function(name, fun)
  local cfm, pos;
  cfm := GAPInfo.CommandLineEditFunctions.Macros;
  if not IsBound(cfm.Names) then
    cfm.Names := [];
  fi;
  pos := Position(cfm.Names, name);
  if pos = fail then
    pos := Length(cfm.Names)+1;
  fi;
  cfm.(pos) := fun;
  cfm.Names[pos] := name;
end;
# A sequence to invoce macro name ('ESC num C-x C-g'  sets GAPMacroNumber in
# kernel and then any key that calls handled-by-GAP will do it)
# We assume that 'C-xC-g' and <TAB> are not overwritten.
InvocationReadlineMacro := function(name)
  local cfm, pos;
  cfm := GAPInfo.CommandLineEditFunctions.Macros;
  if not IsBound(cfm.Names) then
    cfm.Names := [];
  fi;
  pos := Position(cfm.Names, name);
  if pos = fail then
    return fail;
  fi;
  return Concatenation("\033", String(pos), "\030\007\t");
end;
##  # Example
##  gap> InstallReadlineMacro("My Macro", function(l) return ["my text"]; end);
##  gap> InvocationReadlineMacro("My Macro");
##  "\0331\030\007\t"
##  gap> BindKeySequence("^[OR",last);  # first arg with C-v<F3>

  # for compatibility with the non-readline kernel code
  LineEditKeyHandlers := [];
  LineEditKeyHandler := function(l)
    return [l[1], l[3], l[5]];
  end;
else
  # some experimental code, use readline instead
  ReadLib("cmdleditx.g");

fi;

