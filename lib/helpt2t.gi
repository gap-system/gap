#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Frank Celler, Alexander Hulpke, Greg Gamble.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##  The files helpt2t.g{d,i}  contain  the function  to convert  TeX source
##  code written in `gapmacro.tex' style  into text for the "screen" online
##  help viewer.
##

#############################################################################
##
#F  HELP_PRINT_SECTION( <book>, <chapter>, <section> [,<key>] ) . print entry
##
##  key is a function name
##
##  main function to extract the help text for a topic from GAP main help
##
HELP_FLUSHRIGHT:=true;
InstallGlobalFunction(HELP_PRINT_SECTION_TEXT, function(arg)
local   book, chapter, section, key, subkey, MatchKey, ssectypes,
        info, chap, filename, stream, p, q, lico,
        line, i, j, lines, IsIgnoredLine, macro, macroarg, tail,
        ttenv, text, verbatim, nontex, item, initem, displaymath, align,
        lastblank, singleline, rund, SetArg, FlushLeft, Gather,
        width, buff, EmptyLine, ll, start, keynotfound, verb, URLends;

  # flush buffer ... then add empty line
  EmptyLine := function()
    if Length(buff)>0 then
      Add(lines,buff);
      if keynotfound then start := start+1; fi;
      buff:="";
    fi;
    if not lastblank then
      Add(lines,"");
      if keynotfound then start := start+1; fi;
      lastblank:=true;
    fi;
  end;

  # get argument in {...} at front of tail (need to handle nested {}'s)
  # ... macroarg is set with the argument matched and tail set to the rest
  SetArg := function()
    local  level, p;
    while 0<Length(tail) and tail[1]=' ' do
      tail := tail{[2..Length(tail)]};
    od;
    if IsEmpty(tail) then
      macroarg:="";
    elif tail[1]<>'{' then
      macroarg:=tail{[1]};
      tail := tail{[2..Length(tail)]};
    else
      level := 0;
      p := 2;
      while true do
        if p > Length(tail) then
          macroarg:=""; # Forget it ... can't match braces
          break;
        elif tail[p] = '{' then
          level := level+1;
        elif tail[p] = '}' then
          if level = 0 then
            macroarg := tail{[2..p-1]};
            tail := tail{[p+1..Length(tail)]};
            break;
          else
            level := level-1;
          fi;
        fi;
        p := p+1;
      od;
    fi;
    return;
  end;

  FlushLeft := function(s)
    local p;
    p:=1;
    while p<=Length(s) and s[p]=' ' do
      p:=p+1;
    od;
    return s{[p..Length(s)]};
  end;

  IsIgnoredLine := function(line)
    # this is meant to catch lines that except for some initial
    # whitespace are of form: "\begingroup ... %"
    # or: "{\obeylines ... %" or: "{%" or "}%"
    if not displaymath and 1<Length(line) and line[Length(line)] = '%' then
      line := FlushLeft(line);
      return 1=Length(line) or
             line{[1..Length(line)-1]} in ["{", "}"] or
             line{[1..2]}="{\\" and IsAlphaChar(line[3]) or
             line[1]='\\' and IsAlphaChar(line[2]);
    else
      return false;
    fi;
  end;

  # Scrubs a % from the beginning of the line in nontex mode
  # and joins lines ending in %
  Gather := function()
    local nextline;

    while line <> fail do
        if nontex and 0<Length(line) and line[1] = '%' then
            line := line{[2..Length(line)]};
        fi;
        if line="$$" then
            # toggle displaymath
            displaymath := not displaymath;
            align := false;
            EmptyLine();
        elif displaymath and
             ((align and line="}") or (not align and line="\\matrix{")) then
            align := not align; # toggle align
        else
            break;
        fi;
        line := Chomp( ReadLine(stream) );
    od;
    # a '%' at end-of-line indicates a continuation
    while line<> fail and 0<Length(line) and line[Length(line)]='%' do
        line := line{[1..Length(line)-1]};
        repeat
            nextline := ReadLine(stream);
            if nontex and nextline<>fail and
               0<Length(nextline) and nextline[1] = '%' then
                nextline := nextline{[2..Length(nextline)]};
            fi;
        until nextline=fail or 0<Length(nextline) and nextline[1]<>'%';
        if nextline=fail then
            break;
        else
            nextline := Chomp(nextline);
        fi;
        line := Concatenation(line, FlushLeft(nextline));
    od;
  end;

  # Returns true if <s> (a string = <lico>) matches
  # <type> (a ssectype of <key>), or else, false.
  # ... <type> is a list of strings that must match <s> in sequence,
  # the following strings in <type> have special meaning:
  #  " " means skip blanks until the next non-blank and the
  #            next string must match at position 1.
  #  "^X" for any X, means scan what remains of string and
  #                        check there are no X chars.
  MatchKey := function(s, type)
    local p, q, str;
    q:=0;
    for str in type do
      if str=" " then
        s:=FlushLeft(s); q:=1;
      elif str[1]='^' then
        if Position(s, str[2]) <> fail then
          return false;
        fi;
        q:=0;
      else
        p:=PositionSublist(s, str);
        if p=fail or (q=1 and p<>1) then
          return false;
        fi;
        s:=s{[p+Length(str)..Length(s)]}; q:=0;
      fi;
    od;
    return true;
  end;

  width:=SizeScreen()[1]-6;
  book:=arg[1];
  chapter:=arg[2];
  section:=arg[3];

  # did we get the section only via a keyword?
  if Length(arg)>3 then
    key:=arg[4];
    p:=Position(key,'!');
    if p=fail then
      subkey:="";
    else
      subkey:=key{[p+1..Length(key)]};
      key:=key{[1..p-1]};
    fi;
    # define subsection matching types: ssectypes
    # (ignoring any @... component)
    if subkey="" then
      ssectypes :=
        [ # \><key>(...)
          [ " ", key, " ", "(", ")", "^!"],
          # \>`<key>' V
          [ Concatenation("`",key,"' "), "^{", " ", "V" ],
          # \>`...'{<key>}
          [ " ", "`", "'", " ", Concatenation("{",key,"}"), "^!" ] ];
    else
      ssectypes :=
        [ # \><key>(...)!{<subkey>}
          [ " ", key, " ", "(", ")", " ", "!", " ",
            Concatenation("{", subkey, "}") ],
          # \>`...'{<key>!<subkey>}
          [ " ", "`", "'", " ", Concatenation("{",key,"!",subkey,"}"), "^!" ],
          # \>`...'{<key>}!{<subkey>}
          [ " ", "`", "'", " ", Concatenation("{",key,"}!{",subkey,"}"), "^!"] ];
    fi;
  else
    key:=fail;
  fi;

  # get the chapter info
  info := HELP_BOOK_INFO(book);
  chap := HELP_CHAPTER_INFO( book, chapter );
  if chap = fail  then
      return fail;
  fi;

  # store lines
  lines := [];

  # open the stream and read in the help
  filename := Filename( info.directories, info.filenames[chapter] );
  stream := StringStreamInputTextFile(filename);
  if section = 0  then
      SeekPositionStream( stream, chap[1] );
      Add( lines, FILLED_LINE( info.chapters[chapter], info.bookname, '_' ) );
  else
      SeekPositionStream( stream, chap[2][section] );
      Add( lines, FILLED_LINE( info.sections[chapter][section],
                               info.chapters[chapter], '_' ) );
      #The repeat loop was a ``workaround'' for a deficiency in
      #`SeekPositionStream' which has now been fixed by FL
      #... so now `ReadLine' need only be executed once. - GG
      #repeat
        # On UNIX with files not in DOS format, stream positioning works
        #  and so we have the \Section... line on the first iteration.
        # On other architectures or with a DOS format file, stream positioning
        #  might get confused due to the CRLF problem (typically just one
        #  extra iteration is necessary to get past the LF). We continue
        #  reading until we know we have actually reached the line.
        line:=ReadLine(stream);
      #until MATCH_BEGIN( line, HELP_SECTION_BEGIN ) and
      #      # A section starts ... ensure it is the right section:
      #      MATCH_BEGIN( line{[10..Length(line)]},
      #                   info.sections[chapter][section] );
  fi;

  # Initialise a number of variables before the main section-scanning loop
  singleline:=0;     # 0 => paragraph-mode: append line to buff, when buff
                     #      gets longer than width, break into lines of
                     #      length width.
                     # 1 => obeylines-mode: simply add line to lines.
                     # 2 => obeylines-mode but ensuring no blank line is
                     #      inserted between lines.
  buff:="";          # In paragraph-mode, line is buffered in buff before
                     #  being broken into lines.
  lastblank:=false;  # Used to avoid having two blank lines in succession.
  start := 1;        # The section is scanned into lines, but displayed
                     #  from lines[start].

  nontex := false;   # Set inside %display{nontex} and %display{nonhtml}
                     #  environments, where after removal of an initial
                     #  % (if there is one), text is interpreted normally.
  # text-mode and verbatim-mode only differ in the way we treat "||"
  text:=false;       # Set inside %display{text}..%enddisplay
  verbatim := false; # Set inside each of \begintt..\endtt and
                     #  \beginexample..\endexample
  ttenv:=false;      # Set inside \begintt..\endtt
  item := 0;         # Set to 1 in \beginitems..\enditems and
                     #  to 1 (in \item entry) or 2 (in \itemitem entry)
                     #  of \beginlist..\endlist. Otherwise, set to 0.
  displaymath:=false;# Set inside $$ .. $$ for maths displays delimited
                     #  by $$ lines i.e. lines with *only* $$.
  align := false;    # Set inside displaymath in \matrix{ .. }
  keynotfound := false; # In case it is not set in the while loop

  line := ReadLine(stream);
  while line <> fail and not MATCH_BEGIN( line, HELP_SECTION_BEGIN ) do
      line := Chomp(line);

      if nontex and 0 < Length(line) and line[1] = '%' and
         not MATCH_BEGIN( line, "%enddisplay" ) then
          line := line{[2..Length(line)]};
      fi;

      if key<>fail then
          # we got the section only via a keyword. Ignore the first
          # part of the section and start only at the interesting
          # bits. When the key and subkey are found, key is set
          # to fail to disable skip mode i.e. key=fail => key found.

          # *Note* key and subkey have come from matches of (partial)
          # words (that the user entered) with the .six file,
          # so we need an *exact* match with key and subkey.
          # We do *not* use MATCH_BEGIN here.

          p:=PositionSublist(line,"\\>");
          if p<>fail then

              Gather(); # needed in case of continuations
              lico:=FlushLeft(NormalizedWhitespace(line{[p+2..Length(line)]}));
              if ForAny(ssectypes, type -> MatchKey(lico, type)) then
                  key := fail;
                  Info(InfoWarning, 2, "Matched line: ", line);
              fi;
          fi;
      fi;

      keynotfound := key<>fail;

      # blanks lines are ok
      if 0 = Length(line)  then
          if not verbatim and not text then
              EmptyLine();
          fi;
      elif verbatim then
          if  MATCH_BEGIN(line,"\\endtt") then
              verbatim := false;
              ttenv := false;
              lastblank:=false;
              EmptyLine();
          elif  ( not ttenv and MATCH_BEGIN(line,"\\endexample") ) then
              verbatim := false;
              ttenv := false;
              lastblank:=false;
              buff :=  Concatenation (ListWithIdenticalEntries (width, "-"));
              EmptyLine();
          else
              lastblank:=true;
              # Any "||" actually represents "|"
              p := PositionSublist(line,"||");
              while p<> fail do
                  line:=Concatenation(line{[1..p]}, line{[p+2..Length(line)]});
                  p := PositionSublist(line,"||",p);
              od;
              Add( lines, line );
              if keynotfound then start := start+1; fi;
          fi;

      elif text then
          if MATCH_BEGIN(line,"%enddisplay")  then
              text := false;
              lastblank:=false;
              EmptyLine();
          elif line[1] = '%'  then
              Add( lines, line{[2..Length(line)]} );
              if keynotfound then start := start+1; fi;
          else
              lastblank:=false;
              Add( lines, line );
              if keynotfound then start := start+1; fi;
          fi;

      # ignore answers to exercises
      elif MATCH_BEGIN(line,"\\answer")  then
          repeat
              line := ReadLine(stream);
          until line = fail  or  line = "\n" or line = "\r\n";

      # displays for text and HTML that need are interpreted
      # normally (except any initial % is first removed)
      elif MATCH_BEGIN(line,"%display{nontex}")
        or MATCH_BEGIN(line,"%display{nonhtml}") then
          nontex := true;
          text := false;
          verbatim := false;

      # ignore displays for TeX or HTML
      elif MATCH_BEGIN(line,"%display{tex}")
        or MATCH_BEGIN(line,"%display{nontext}")
        or MATCH_BEGIN(line,"%display{html}")
        or MATCH_BEGIN(line,"%display{jpeg}")  then
          repeat
              line := ReadLine(stream);
          until line = fail
             or MATCH_BEGIN(line,"%display{text}")
             or MATCH_BEGIN(line,"%display{nontex}")
             or MATCH_BEGIN(line,"%enddisplay");
          if MATCH_BEGIN(line,"%display{text}")  then
              text := true;
              EmptyLine();
          elif MATCH_BEGIN(line,"%display{nontex}") then
              nontex := true;
          fi;

      elif MATCH_BEGIN(line,"\\index{")
        or MATCH_BEGIN(line,"\\indextt{")
        or MATCH_BEGIN(line,"\\atindex{")  then
          # A '%' at end-of-line indicates a continuation
          while line <> fail and line <> "" and
                (line[1] = '%' or line[Length(line)] = '%') do
              line := Chomp( ReadLine(stream) );
          od;
          line:="";

      # example environments
      elif MATCH_BEGIN(line,"\\beginexample") then
          verbatim := true;
          ttenv := false;
          EmptyLine();
          buff := Concatenation (
            Concatenation (ListWithIdenticalEntries (QuoInt (width-9, 2), "-")),
            " Example ",
            Concatenation (ListWithIdenticalEntries (width - 9 - QuoInt (width-9, 2), "-")));
          EmptyLine();
       elif MATCH_BEGIN(line,"\\begintt")  then
          ttenv := true;
          verbatim := true;
          EmptyLine();
       elif MATCH_BEGIN(line,"\\endexample") then  # Just in case ...
          verbatim := false;
          lastblank:=false;
          buff := Concatenation (ListWithIdenticalEntries (width-9, "-"));
          EmptyLine();
       elif  MATCH_BEGIN(line,"\\endtt")  then
          verbatim := false;
          lastblank:=false;
          EmptyLine();
      elif MATCH_BEGIN(line,"%display{text}")  then
          text := true;
          EmptyLine();
      elif MATCH_BEGIN(line,"%enddisplay")  then  # Just in case
          text := false;
          nontex := false;
          lastblank:=false;
          EmptyLine();

      elif MATCH_BEGIN(line,"\\beginitems")
        or MATCH_BEGIN(line,"\\beginlist")  then
          item:=1;
          EmptyLine();

      elif MATCH_BEGIN(line,"\\enditems")
        or MATCH_BEGIN(line,"\\endlist")  then
          item:=0;
          EmptyLine();

      # ignore lines beginning with '%' except if in text
      # or verbatim modes (which we have already dealt with)
      # or if in nontex mode (which we deal with below);
      # also ignore specific lines ending in a '%'
      # (other than the lines mentioned a '%' at end-of-line
      # indicates a continuation)
      elif not nontex and line[1] = '%' or
           # this is meant to exclude lines that after some
           # initial whitespace are of form: "\begingroup ... %"
           # or: "{\obeylines ... %" or "{%" or "}%"
           IsIgnoredLine(line) then
          ;

      # use everything else
      else
          if not text and not verbatim then
              Gather();

              if   MATCH_BEGIN(line,"\\exercise")  then
                  line{[1..9]} := "EXERCISE:";
              elif MATCH_BEGIN(line,"\\danger")  then
                  line{[1..7]} := "DANGER:";

              # cope with `\>' entries
              elif MATCH_BEGIN(line,"\\>") or
                   MATCH_BEGIN(line,"\\)") then
                  displaymath := false; # in case a $$ wasn't matched
                  if singleline<>2 then
                      # force separator if the line above was not
                      # already a header
                      EmptyLine();
                  fi;
                  singleline:=2; # we want it on a single line and it
                                 # may have a `cat' letter
                  rund:=line[2]=')';
                  line:=line{[3..Length(line)]}; # remove `>'
                  if rund then
                      if line[1]='{' then
                          tail:=line;
                          SetArg();
                          if macroarg="" then                 #No matching brace
                              line := line{[2..Length(line)]};#absorb '{' anyway
                          else
                              line := Concatenation(macroarg,"\\,",tail);
                          fi;
                      fi;
                      if 5<Length(line) and line{[1..6]}="\\fmark" then
                          line:=Concatenation(">",line{[7..Length(line)]});
                      fi;
                      # remove an \hfill if present
                      line := ReplacedString(line, "\\hfill", "");
                  else
                      while 0<Length(line) and line[1]=' ' do
                          line:=line{[2..Length(line)]};
                      od;
                      # remove @... label/index stuff from line
                      if 0<Length(line) and line[1]='`' then
                          # types: \>`...'{...}
                          #        \>`...'{...}!{...} -> \>`...'{...!...}
                          #        \>`...'{...}@{...} -> \>`...'{...}
                          #        \>`...'{...}@`...' -> \>`...'{...}
                          p:=PositionSublist(line,"}!{");
                          if p<>fail then
                              line:=Concatenation(line{[1..p-1]},
                                                  line{[p+3..Length(line)]});
                          fi;
                          p:=Position(line,'@');
                          if p<>fail then
                              if p<Length(line) and line[p+1]='`' then
                                q:=Position(tail,'\'');
                                if q<>fail then
                                  line:=Concatenation(
                                            line{[1..p-1]},
                                            line{[q+1..Length(line)]});
                                fi;
                              else
                                tail:=line{[p+1..Length(line)]};
                                SetArg();                    # remove {...}
                                if macroarg<>"" then
                                  line:=Concatenation(line{[1..p-1]},tail);
                                fi;
                              fi;
                          fi;
                      fi;
                      line:=Concatenation("> ",line); # add the leading `>'
                  fi;
              elif displaymath then
                  singleline := 1;
                  if align then
                      # Should we check for \& here?
                      # ... my feeling is that \& should not be allowed
                      # (there are too many other places where it can
                      # cause problems) - GG
                      line := ReplacedString(line, "&", "");
                  fi;
              else
                  # by default we don't request single lines
                  singleline:=0;
              fi;

              # If we wanted to support \~ accents ...
              # (ties ~ as opposed to accents \~)
              #p:=Position(line,'~');
              #while p<>fail do
              #  if p=1 or line[p-1] <> '\\' then
              #    line[p]:=' ';
              #  fi;
              #  p:=Position(line,'~',p);
              #od;

              if item>0 then
                  line:=FlushLeft(line);
                  p := Position(line,'&');
                  initem := p=fail;
                  if not initem then
                      if singleline=2 then
                          line[p] := ' ';
                      else
                          EmptyLine();
                          tail:= FlushLeft(line{[p+1..Length(line)]});
                          line:=Concatenation(line{[1..p-1]},"{\\break}",tail);
                          singleline:=0;
                      fi;
                  fi;
              fi;

              # some further handling of TeX macros
              p:=Position(line,'\\');
              while p<>fail do
                  tail:=line{[p+1..Length(line)]};
                  line:=line{[1..p-1]};
                  macroarg := "";
                  macro := "";
                  if tail = "" then
                      # if line ends in a \ indicating a continuation as
                      # ... we put it back
                      line[p] := '\\';
                      p := fail;
                  elif not IsAlphaChar(tail[1]) then
                      # Single character macros
                      macro := tail{[1]};
                      tail := tail{[2..Length(tail)]};
                      # escaped chars \ { } $ & _ % and <space>
                      if macro[1] in "\\{}$#&_% " then
                          ;
                      # non-alpha accents
                      elif macro[1] in "'`=^.\"~" then
                          # \. could be an accent or multiplication
                          # ... we treat them the same. We don't support \~.
                          if Length(line)>0 and line[Length(line)]='{' and
                             Length(tail)>=2 and tail[2]='}' then
                              # We assume they appear as e.g.: {\'a}
                              line:=line{[1..Length(line)-1]};
                              macroarg:=tail{[1]};
                              tail:=tail{[3..Length(tail)]};
                          fi;
                          if macro = "=" then
                              macro := "-";
                          elif macro = "~" then
                              macro := ""; # just omit it
                          fi;
                      # fine spacing macros ... we just ignore
                      elif macro[1] in "!," then
                          macro := "";
                      elif macro[1] in ";" then
                          macro := " ";
                      # shouldn't get these here ...
                      elif macro[1] in ">)" then
                          macro := Concatenation(" ",macro);
                      # any we missed? ... just treat as escaped char
                      else
                          ;
                      fi;
                  else
                      # Multi-character macros
                      q:=1;
                      while q<=Length(tail) and IsAlphaChar(tail[q]) do
                          q:=q+1;
                      od;
                      macro:=tail{[1..q-1]};
                      tail:=tail{[q..Length(tail)]};
                      # accents have args ... deal with that
                      if macro in ["accent", "c", "d", "b",
                                        "t", "u", "v", "H"] then
                          if macro="accent" then
                              q:=1;
                              while q<=Length(tail) and IsDigitChar(tail[q]) do
                                q:=q+1;
                              od;
                              macro:=tail{[1..q-1]};
                              tail:=tail{[q..Length(tail)]};
                          fi;
                          if macro="19" and Length(tail)>=2 and
                             tail{[1..2]}="{}" then
                              tail:=tail{[3..Length(tail)]};
                          else
                              while 0<Length(tail) and tail[1]=' ' do
                                tail:=tail{[2..Length(tail)]};
                              od;
                              if 1<Length(tail) and macro="t" then
                                macroarg:=tail{[1..2]};
                                tail:=tail{[3..Length(tail)]};
                              elif 0<Length(tail) then
                                macroarg:=tail{[1]};
                                tail:=tail{[2..Length(tail)]};
                              fi;
                          fi;
                      fi;
                      # If macro enclosed in {..} or $..$ remove them
                      if  Length(line)>0 and Length(tail)>0 and
                          ((line[Length(line)]='{' and tail[1]='}') or
                           (line[Length(line)]='$' and tail[1]='$')) then
                          line:=line{[1..Length(line)-1]};
                          tail:=tail{[2..Length(tail)]};
                      fi;
                      # handle some macros
                      # all the \accentNNN accents including umlaut
                      # ... macro just contains NNN for these
                      if macro="18" then
                          macro:="`";
                      elif macro="19" then
                          macro:="'";
                      elif macro="20" then
                          macro:="\\v";
                      elif macro="21" then
                          macro:="\\u";
                      elif macro="22" then
                          macro:="-"; # not elegant
                      elif macro="94" then
                          macro:="^";
                      elif macro="95" then
                          macro:="."; # not elegant
                      elif macro="125" or macro="127" then  # umlaut
                          macro:="\"";
                      # We don't support \accent126 = \~
                      elif macro="126" then
                          macro:="";

                      # alpha accents
                      elif macro in [ "c", "d", "b", "t" ] then   # too hard
                          macro:="";                              # just omit
                      elif macro="u" or macro="v" then
                          # put backslash back
                          macro:=Concatenation("\\",macro);
                      elif macro="H" then # treat like umlaut
                          macro:="\"";

                      # sharp s, ligatures, other specials
                      elif macro in [ "ss", "oe", "OE", "ae", "AE",
                                      "o",  "O",  "l",  "L" , "i", "j"] then
                          ; # good enough without backslash
                      elif macro in [ "aa", "AA" ] then
                          macro := macro{[1]};

                      elif macro="copyright" then
                          macro := "(c)";

                      elif macro in ["GAP", "MOC", "CAS", "ATLAS"] then
                          ; # nothing to do it's right already
                      elif macro = "calR" then
                          macro := "R";
                      elif macro="package" then
                          SetArg(); # sets macroarg and tail as we need it
                          macro := "";
                      elif macro="lq" then
                          macro:="`";
                      elif macro="rq" then
                          macro:="'";
                      elif macro="pif" then
                          macro:="'";
                      elif macro in ["dots","ldots","cdots","vdots"] then
                          macro:="...";
                      elif macro="cdot" then
                          macro:=" . ";
                      elif macro="dot" then
                          macro:=".";

                      elif macro="kernttindent" then
                          macro:="";
                      elif macro="enspace" then
                          macro:="~";
                      elif macro="quad" then
                          macro:="~~";
                      elif macro="qquad" then
                          macro:="~~~";

                      elif macro="item" or macro="itemitem" then
                          EmptyLine();
                          SetArg();
                          singleline:=0;
                          initem:=false;
                          if macroarg="$-$" then
                              macroarg:="-";
                          fi;
                          # to get rid of any ordered list markup that
                          # is only interpreted for the HTML version
                          if macro="itemitem" then
                              q := Position(tail, '%');
                              if q <> fail then
                                  tail := tail{[1..q-1]};
                              fi;
                          fi;
                          # we do this so macroarg is scanned for macros
                          tail:=Concatenation(macroarg,"\\endmacro ",tail);
                          macroarg:="";
                          if macro="item" then
                              item:=1;
                              macro:="\\item";
                          else
                              item:=2;
                              macro:="~~~~\\item";
                          fi;

                      elif macro="endmacro" then
                          q:=PositionSublist(line,"\\item");
                          macroarg:=line{[q+5..Length(line)]};
                          line:=line{[1..q-1]};
                          macro:="";
                          tail:=FlushLeft(tail);
                          # we do this to prevent macroarg expanding
                          macroarg := ReplacedString(macroarg," ","~");
                          if Length(macroarg)>=3 then
                              macroarg:=Concatenation(macroarg,"~");
                          else
                              macroarg:=Concatenation(macroarg,"~~~~"){[1..4]};
                          fi;

                      # font changing commands
                      elif macro in ["bsf","sf","bf","rm","cal","sl","it"] then
                          if Length(line)>0 and line[Length(line)]='{' then
                              line:=line{[1..Length(line)-1]};
                              while 0<Length(tail) and tail[1]=' ' do
                                tail:=tail{[2..Length(tail)]};
                              od;
                              tail:=Concatenation("{",tail);
                              SetArg();
                              if macroarg<>"" then
                                if macro="bsf" then
                                  tail:=Concatenation("*",macroarg,"*",tail);
                                else
                                  tail:=Concatenation(macroarg,tail);
                                fi;
                                macroarg:="";
                              fi;
                          fi;
                          macro:="";
                      elif macro in [ "medskip",    "bigskip" ] then
                          macro:="";
                          EmptyLine();

                      elif macro in [ "par", "begingroup", "endgroup" ] then
                          tail := "";  # assume the rest of the line
                          macro := ""; # is not intended for our eyes

                      elif macro="hrule" then
                          line:= FILLED_LINE("","",'-');
                          line[1] := '-';
                          line[Length(line)] := '-';
                      elif macro="hfill" and align then
                          macro:="";
                      elif macro="hfill" then
                          line:= FILLED_LINE(line,tail,' ');
                      elif macro="break" then
                          line:= FILLED_LINE(line,"~ ",' ');
                          macro:="";
                      elif macro="cr" then
                          macro:="";

                      # math macros
                      elif macro="langle" or macro="lneqq" then
                          macro:="<";
                      elif macro="rangle" then
                          macro:=">";
                      elif macro="ne" or macro="neq" then
                          macro:=" <> ";
                      elif macro="le" or macro="leq" then
                          macro:=" <= ";
                      elif macro="ge" or macro="geq" then
                          macro:=" >= ";
                      elif macro="backslash" or macro="setminus" then
                          macro:="\\";
                      elif macro="bullet" then
                          macro:=".";
                      elif macro="circ" then
                          macro:="o";
                      elif macro="mapsto" then
                          macro:=" |-> ";
                      elif macro="longmapsto" then
                          macro:=" |--> ";
                      elif macro in ["rightarrow", "hookrightarrow", "to"] then
                          macro:=" -> ";
                      elif macro="Rightarrow" then
                          macro:=" => ";
                      elif macro="iff" then
                          macro:=" <=> ";
                      elif macro="vdash" then
                          macro:=" |- ";
                      elif macro="times" then
                          macro:=" x ";
                      elif macro="in" then
                          macro:=" in ";
                      elif macro="gamma" then
                          macro:="y"; # looks similar!
                      elif macro="forall" then
                          macro:=" for all ";
                      elif macro="exists" then
                          macro:=" there exists ";
                      elif macro="mid" then
                          macro:="|";
                      elif macro="colon" then
                          macro:=":";
                      elif macro="ast" then
                          macro:="*";
                      elif macro="lfloor" or macro="lbrack" then
                          macro:="[";
                      elif macro="rfloor" or macro="rbrack" then
                          macro:="]";
                      elif macro="left" or macro="right" then
                          macro:="";
                          if 0<Length(tail) and tail[1]='.' then
                              tail:=tail{[2..Length(tail)]};
                          fi;
                      elif macro="prime" then
                          # this isn't ideal since ^{\prime} becomes ^'
                          # ... but a_N^{\prime} becomes a_N^' at least
                          # showing that the ' belongs to a (rather than N)
                          macro:="'";
                      elif macro="cup" then
                          macro:=" U ";
                      elif macro="over" then
                          macro:="/";
                      elif macro="hbox" then
                          SetArg();
                          macro:="";
                      elif macro="frac" then
                          SetArg();
                          macro:=Concatenation(" ",macroarg,"/");
                          SetArg();
                          macro:=Concatenation(macro,macroarg," ");
                          macroarg:="";
                      elif macro="bmod" then
                          macro:=" mod ";
                      elif macro="pmod" then
                          SetArg();
                          macro:=Concatenation("(mod ",macroarg,")");
                          macroarg:="";
                      elif macro in [ "mathbin", "mathrel", "buildrel",
                                      "mathop",  "limits" ] then
                          macro:=""; # ignore
                      else
                          ; # display the macro name
                      fi;
                  fi;
                  if macro<>"hfill" and macro<>"hrule" then
                      line:=Concatenation(line,macro,macroarg,tail);
                  fi;
                  p := Length(line) - Length(tail);
                  if IsEmpty(line) then line:="";fi;
                  p:=Position(line,'\\',p);
              od;
          fi;

          lastblank:=false;
          if singleline=2 then
              while Length(line)>width do
                  p:=width;
                  while p>=1 and not(line[p] in " ,.>])") do
                      p:=p-1;
                  od;
                  if p = 0 then
                      p:=width-1;
                      if IsAlphaChar(line[p]) or IsDigitChar(line[p]) then
                          Add(lines, Concatenation(line{[1..p]}, "-"));
                      else
                          Add(lines, line{[1..p]});
                      fi;
                  elif line[p] = ' ' then
                      Add(lines, line{[1..p-1]});
                  else
                      Add(lines, line{[1..p]});
                  fi;
                  if keynotfound then start := start+1; fi;
                  line := Concatenation("~~~~",
                                        FlushLeft(line{[p+1..Length(line)]}) );
              od;
              # treat trailing `category' letter(s)
              p:=Length(line);
              if 0<p and line[p] in "CROFPAMV" then
                  # we assume that the character before the category
                  # letter(s) is a blank space
                  if 1<p and line{[p-1..p]} = "AM" then
                      line:=FILLED_LINE(line{[1..p-2]},line{[p-2..p]},' ');
                  else
                      line:=FILLED_LINE(line{[1..p-1]},line{[p-1..p]},' ');
                  fi;
              fi;
              Add(lines,line);
              if keynotfound then start := start+1; fi;
          elif singleline=0 then
              if Length(buff)>0 and buff[Length(buff)] <> '~' then
                  Add(buff,' '); # separating ' '
              elif item>0 and initem and 0=Length(buff) and
                   0<Length(line) and line[1]<>'~' then
                  buff:="~~~~";
              fi;
              buff:=Concatenation(buff,line);

              while Length(buff)>width do # force to fill lines
                  # find the last space to break
                  p:=width;
                  while p>=1 and buff[p] <> ' ' do
                      p:=p-1;
                  od;
                  if p=0 then
                      # cope with overfull lines
                      Add(lines,Concatenation(buff{[1..width-1]},"-"));
                      if keynotfound then start := start+1; fi;
                      buff:=buff{[width..Length(buff)]};
                  else
                      line:=buff{[1..p-1]};
                      buff:=buff{[p+1..Length(buff)]}; # letter p is the ' '

                      if HELP_FLUSHRIGHT and ' ' in line then
                          # remove leading and trailing blanks
                          ll:=1;
                          while ll<Length(line) and line[ll]=' ' do
                            ll:=ll+1;
                          od;
                          line:=line{[ll..Length(line)]};
                          ll:=Length(line);
                          while ll>0 and line[ll]=' ' do
                              ll:=ll-1;
                          od;
                          line:=line{[1..ll]};

                          # flush right adjustment, for this the line must
                          # contain spaces
                          p:=0;
                          while ll<width do
                              p:=Position(line,' ',p);
                              if p=fail then
                                # start anew
                                p:=Position(line,' ',0);
                              fi;
                              # if the line actually contains no
                              #  spaces then give up
                              if p = fail then
                                  break;
                              fi;
                              # add a blank
                              line:=Concatenation(line{[1..p]}, line{[p..ll]});
                              # avoid to add the next blank just there
                              ll:=ll+1;
                              p:=p+1;
                              while p<=ll and line[p]=' ' do
                                p:=p+1;
                              od;
                              if p>ll then
                                p:=0;
                              fi;
                          od;
                      fi;

                      Add(lines,line);
                      if keynotfound then start := start+1; fi;
                      if item>0 then
                          buff := Concatenation( "~~~~", FlushLeft(buff) );
                          if item=2 then
                              buff := Concatenation("~~~~",buff);
                          fi;
                      fi;
                  fi;
              od;
          else
              if displaymath then
                  line := Concatenation("~~~~",line);
              fi;
              Add(lines,line);
              if keynotfound then start := start+1; fi;
          fi;
      fi;
      line := ReadLine(stream);
  od;
  CloseStream(stream);

  # Now we replace ~s by spaces, except in URLs and in `...'
  # (a TeX ~ is a tie which for on-line help amounts to an unstretchable space)
  verb := false; # Set to true inside `...' (named for LaTeX \verb|...|)
  for i in [1 .. Length(lines)] do
    # we assume URLs are not broken over lines, URLs don't contain `...'
    # environments and `...' environments don't contain URLs
    for j in [1 .. Length(lines[i])] do
      # replace a sequence of ~s at the beginning of a line by spaces
      if lines[i][j] = '~' then
        lines[i][j] := ' ';
      else
        break;
      fi;
    od;
    q := 0;
    if verb then
      q := Position(lines[i],''');
      while q<>fail and q<Length(lines[i]) and lines[i][q+1]=''' do
        q := Position(lines[i],''',q+1);
      od;
      if q=fail then
        q := Length(lines[i]);
      else
        verb := false;
      fi;
      tail := lines[i]{[q+1..Length(lines[i])]};
      line := ReplacedString(lines[i]{[1..q]},"~","\\tilde");
      q := Length(line);
      lines[i] := Concatenation(line,tail);
    fi;
    p := PositionSublist(lines[i],"URL{",q);
    URLends := [];
    while p<>fail do
      tail:=lines[i]{[p+3..Length(lines[i])]};
      line:=lines[i]{[1..p+2]};
      SetArg();
      if macroarg="" then # abort ... no matching '}'
        lines[i]:=Concatenation(line,tail);
        Add(URLends, [p, Length(lines[i])]);
        break;
      else
        lines[i]:=Concatenation(
                    line,"{",ReplacedString(macroarg,"~","\\tilde"),"}",tail);
      fi;
      Add(URLends, [p, Length(lines[i]) - Length(tail)]);
      p:=PositionSublist(lines[i],"URL{",Length(lines[i]) - Length(tail));
    od;
    p := q;
    while not verb and p < Length(lines[i]) do
      while p < Length(lines[i]) do
        # this loop sets p to the beginning of the next `...' environment
        # ... or sets p = fail if there isn't one
        p := Position(lines[i], '`', p);
        if p=fail then
          break;
        fi;
        while not IsEmpty(URLends) and p > URLends[1][2] do
          URLends := URLends{[2..Length(URLends)]}; #pop URLends
        od;
        # Have found a ` ... is it the beginning of a `...' environment?
        # It is if: it is not inside a URL, and
        #           ` is not followed by ` unless its followed by ``.
        if IsEmpty(URLends) or p < URLends[1][1] then     # not inside a URL
          if p+1 < Length(lines[i]) and
             lines[i]{[p+1..p+2]} in ["`'", "''"] then
             # ``' or `'' (special cases: ` or ' inside `...')
            p := p + 2; # skip over (nothing to do)
          elif p = Length(lines[i]) or                      # ` (at end of line)
               lines[i][p+1]<>'`'   or                      # ` (on its own)
               p+1 < Length(lines[i]) and lines[i][p+2]='`' # ```
               then
            verb := true;
            break;
          else # `` (but not ```) ... not a `...' environment
            p := p + 1; # continue searching after second `
          fi;
        fi;
      od;
      if not verb then # ... or equivalently: if p = fail
        break;
      fi;
      q := Position(lines[i],''',p);
      while q<>fail and q<Length(lines[i]) and lines[i][q+1]=''' do
        q := Position(lines[i],''',q+1);
      od;
      if q=fail then
        q := Length(lines[i]);
      else
        verb := false; # changed for when we finish this pass of the loop
      fi;
      tail := lines[i]{[q+1..Length(lines[i])]};
      line := Concatenation(lines[i]{[1..p]},
                            ReplacedString(lines[i]{[p+1..q]},"~","\\tilde"));
      lines[i] := Concatenation(line,tail);
      q := Length(line);
    od;
    # at this point any ~ that should not be changed to a blank has been
    # temporarily replaced by: \tilde
    lines[i] := ReplacedString( lines[i], "~", " " );
    lines[i] := ReplacedString( lines[i], "\\tilde", "~" );
  od;

  EmptyLine();

  return rec(lines := lines, start := start);

end);
