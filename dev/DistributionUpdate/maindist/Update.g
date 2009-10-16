###########################################################################
##  
##  Update.g                                                (C) Frank Lübeck
##  
##      $Id: Update.g,v 1.2 2005/09/23 15:10:02 gap Exp $
##  
##  This file contains some utilities for extracting information from the
##  dev/Update file. 
##  
##  Usage examples from README:
##  
##    (1b) Extract test code from dev/Update into tst/bugfix.tst and commit it
##        to release branch.  (utils in Update.g)
##           d := UpdateData("../../Update");;
##           l := FixesAndOthersData(d);;
##           PrintTestLines("guck.tst", l);
##        and then copy content of 'guck.tst' to bottom of 
##    (1c) Extract descriptions of changes from dev/Update into ./description* 
##        and commit to release branch.  (utils in Update.g)
##           d := UpdateData("../../Update");;
##           l := FixesAndOthersData(d);;
##           PrintDescriptionLines("guck.html", l);
##        Then copy content of 'guck.html' to new subsection close to top of
##        'Download/bugs.mixer' in CVS of website and commit; run 'mixer' and
##        cut out this subsection from result of 'w3m -dump bugs.html' into
##        description* file.
##  

DisplayUpdateEntry := function ( r )
  local  n;
  for n  in RecFields( r )  do
    Print( "!", n, "\n", r.(n), "\n" );
  od;
  return;
end;    


UpdateData := function(arg)
  local name, str, fields, res, tmp, i, r, j, txt;
  if Length(arg) > 0 then
    name := arg[1];
  else
    name := "../../Update";
  fi;
  str := StringFile(name);
  str := Filtered(SplitString(str,"\n",""), r-> Length(r) = 0 or r[1] <> '%');
  fields := ["date", "changedby", "reportedby", "typeofchange",
            "description", "testcode", "prefetch", "changedfiles"];
  res := [];
  tmp := rec();
  i := 1;
  while i <= Length(str) do
    r := LowercaseString(str[i]);
    if Length(r) > 0 and r[1] = '!' then
      r[1] := ' ';
      RemoveCharacters(r, WHITESPACE);
      if r = "end" then
        if IsBound(tmp.date) and Length(tmp.date) = 0 then
          Print("##########   No '! Date', removing:\n");
          DisplayUpdateEntry(tmp);
        else
          Add(res, tmp);
        fi;
        tmp := rec();
        i := i+1;
        continue;
      fi;
      j := i+1;
      while j <= Length(str) and (Length(str[j]) = 0 or str[j][1] <> '!') do
        j := j+1;
      od;
      txt := JoinStringsWithSeparator(str{[i+1..j-1]}, "\n");
      if not r in fields then
        Print("# no recognized field:\n", str[i], "\n");
      fi;
      tmp.(r) := txt;
      i := j;
    else
      i := i+1;
    fi;
  od;
  return res;
end;

# splits Update data into "Fix..." type and others, each sorted by date
FixesAndOthersData := function(l)
  local f, res;
  f := function(r)
    local s;
    if not IsBound(r.typeofchange) then
      return false;
    fi;
    s := LowercaseString(r.typeofchange);
    StripBeginEnd(s, WHITESPACE);
    return Length(s) > 2 and s{[1..3]} = "fix";
  end;
  res := [];
  res[1] := Filtered(l, f);
  Sort(res[1], function(a, b) return a.date < b.date; end);
  res[2] := Filtered(l, r-> not f(r));
  Sort(res[2], function(a, b) return a.date < b.date; end);
  return res;
end;

# l is result of FixesAndOthersData
PrintTestLines := function(nam, l)
  local f, a, z;
  f := OutputTextFile(nam, false);
  SetPrintFormattingStatus(f, false);
  PrintTo(f, "# For fixes:\n");
  for a in l[1] do
    if IsBound(a.testcode) then
      z := Concatenation("# ", StripBeginEnd(a.date, WHITESPACE)," (",
           StripBeginEnd(a.changedby, WHITESPACE),")");
      NormalizeWhitespace(z);
      PrintTo(f, "\n\n", z, "\n");
      PrintTo(f, a.testcode,"\n");
    fi;
  od;
  PrintTo(f, "# For new features:\n");
  for a in l[2] do
    if IsBound(a.testcode) then
      z := Concatenation("# ", StripBeginEnd(a.date, WHITESPACE)," (",
           StripBeginEnd(a.changedby, WHITESPACE),")");
      NormalizeWhitespace(z);
      PrintTo(f, "\n\n", z, "\n");
      PrintTo(f, a.testcode,"\n");
    fi;
  od;
  CloseStream(f);
end;


PrintDescriptionLinesOld := function(nam, l)
  local f, wrong, crash, xa, xe, attin, a;
  f := OutputTextFile(nam, false);
  SetPrintFormattingStatus(f, false);
  PrintTo(f, "<!-- descriptions of fixes: -->\n", 
             "<h3>Fixed bugs</h3>\n<ol>\n");
  for a in l[1] do
    wrong := PositionSublist(a.typeofchange, "wrong") <> fail and
             PositionSublist(a.typeofchange, "result") <> fail;
    crash := PositionSublist(a.typeofchange, "crash") <> fail;
    if wrong then
      xa := "<b>";
      xe := "</b>";
    elif crash then
      xa := "<i>";
      xe := "</i>";
    else
      xa := "";
      xe := "";
    fi;
    if IsBound(a.description) then
      PrintTo(f, "\n<li>\n", xa, a.description);
      if IsBound(a.reportedby) then
        PrintTo(f, " [Reported by ", StripBeginEnd(a.reportedby, WHITESPACE),
                   "]");
      fi;
      PrintTo(f, xe, "\n</li>\n");
    fi;
  od;
  PrintTo(f, "</ol>\n\n\n\n<!-- descriptions of new features: -->\n",
             "<h3>New or improved functionality</h3>\n<ol>\n");
  for a in l[2] do
    if IsBound(a.description) then
      PrintTo(f, "\n<li>\n", a.description);
      PrintTo(f, "\n</li>\n");
    fi;
  od;
  PrintTo(f, "</ol>\n\n");
  CloseStream(f);
end;

PrintDescriptionLines := function(nam, l)
  local f, ind, headers, attin, i, a;
  f := OutputTextFile(nam, false);
  SetPrintFormattingStatus(f, false);

  # divide the "fix" entries further:
  ind := [];
  ind[1] := Filtered([1..Length(l[1])], i-> 
            PositionSublist(l[1][i].typeofchange, "wrong") <> fail and
            PositionSublist(l[1][i].typeofchange, "result") <> fail);
  ind[2] := Filtered([1..Length(l[1])], i->
            PositionSublist(l[1][i].typeofchange, "crash") <> fail);
  ind[3] := Difference([1..Length(l[1])], UnionSet(ind[1], ind[2]));
  ind[4] := Length(l[1]) + [1..Length(l[2])];
  l := Concatenation(l);
  
  headers := [
         "<h3>Fixed bugs which could produce wrong results</h3>\n<ol>\n",
         "<h3>Fixed bugs which could lead to crashes</h3>\n<ol>\n",
         "<h3>Other fixed bugs</h3>\n<ol>\n",
         "<h3>New or improved functionality</h3>\n<ol>\n" ];
  for i in [1..4] do
    PrintTo(f, headers[i]);
    for a in l{ind[i]} do
      if IsBound(a.description) then
        PrintTo(f, "\n<li>\n", a.description);
        if IsBound(a.reportedby) then
          PrintTo(f, " [Reported by ", StripBeginEnd(a.reportedby, WHITESPACE),
                     "]");
        fi;
        PrintTo(f, "\n</li>\n");
      fi;
    od;
    PrintTo(f, "</ol>\n\n\n");
  od;
  CloseStream(f);
end;

