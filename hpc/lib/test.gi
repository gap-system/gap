#############################################################################
##
#W  test.gi                 GAP library                          Frank Lübeck
##
#Y  Copyright (C) 2011 The GAP Group
##
##  This file contains functions for test files.
##

##  FirstDiff := function(a, b)
##    return First([1..Length(a)],  i-> not IsBound(b[i]) or b[i] <> a[i]);
##  end;

InstallGlobalFunction(ParseTestInput, function(str, ignorecomments)
  local lines, inp, pos, outp, ign, i;
  lines := SplitString(str, "\n", "");
  inp := [];
  pos := [];
  outp := [];
  ign := [];
  i := 1;
  while i <= Length(lines) do
    if i = 1 and  Length(lines[1]) > 0 and lines[1][1] = '#' then
      if ignorecomments = true then
        # ignore comment lines at beginning of file
        while i <= Length(lines) and Length(lines[i]) > 0 and
              lines[i][1] = '#' do
          Add(ign, i);
          i := i+1;
        od;
      else
        Add(inp, "\n");
        i := 2;
        while i <= Length(lines) and Length(lines[i]) > 0 and 
              lines[i][1] = '#' do
          i := i+1;
        od;
        Add(outp, JoinStringsWithSeparator(lines{[1..i-1]}, "\n"));
        Add(outp[1], '\n');
      fi;
    elif Length(lines[i]) = 0 and ignorecomments = true and i < Length(lines) 
         and Length(lines[i+1]) > 0 and lines[i+1][1] = '#' then
      # ignore an empty line followed by comment lines
      Add(ign, i);
      i := i+1;
      while i <= Length(lines) and Length(lines[i]) > 0 and
            lines[i][1] = '#' do
        Add(ign, i);
        i := i+1;
      od;
    elif Length(lines[i]) > 4 and lines[i]{[1..5]} = "gap> " then
      Add(outp, "");
      Add(inp, lines[i]{[6..Length(lines[i])]});
      Add(inp[Length(inp)], '\n');
      Add(pos, i);
      i := i+1;
    elif Length(lines[i]) > 1 and lines[i]{[1..2]} = "> " then
      Append(inp[Length(inp)], lines[i]{[3..Length(lines[i])]});
      Add(inp[Length(inp)], '\n');
      i := i+1;
    elif Length(outp) > 0 then
      Append(outp[Length(outp)], lines[i]);
      Add(outp[Length(outp)], '\n');
      i := i+1;
    else
      i := i+1;
    fi;
  od;
  Add(pos, ign);
  return [inp, outp, pos];
end);

InstallGlobalFunction(ParseTestFile, function(arg)
  local fnam, ignorecomments, str;
  fnam := arg[1];
  if Length(arg) > 1 then
    ignorecomments := arg[2];
  else
    ignorecomments := true;
  fi;
  str := StringFile(fnam);
  if str = fail then
    Error("Cannot read file ",fnam,"\n");
    return;
  fi;
  return ParseTestInput(str, ignorecomments);
end);

InstallGlobalFunction(RunTests, function(arg)
  local tests, opts, breakOnError, inp, outp, pos, cmp, times, ttime, 
        s, res, fres, t, f, i;
  # don't enter break loop in case of error during test
  tests := arg[1];
  opts := rec( breakOnError := false, showProgress := false );
  if Length(arg) > 1 and IsRecord(arg[2]) then
    for f in RecFields(arg[2]) do
      opts.(f) := arg[2].(f);
    od;
  fi;
  breakOnError := BreakOnError;
  BreakOnError := opts.breakOnError;

  # we collect outputs and add them as 4th entry to 'tests'
  # also collect timings and add them as 5th entry to 'tests'
  inp := tests[1];
  outp := tests[2];
  pos := tests[3];
  cmp := [];
  times := [];
  ttime := Runtime();
  for i in [1..Length(inp)] do
    if opts.showProgress = true then
      Print("# line ", pos[i], ", input:\n",inp[i]);
    fi;
    s := InputTextString(inp[i]);
    res := "";
    fres := OutputTextString(res, false);
    SET_OUTPUT(fres, true);
    t := Runtime();
    READ_STREAM_LOOP(s, true);
    SET_PREVIOUS_OUTPUT();
    CloseStream(fres);
    CloseStream(s);
    Add(cmp, res);
    Add(times, Runtime()-t);
  od;
  # add total time to 'times'
  Add(times, Runtime() - ttime);
  tests[4] := cmp;
  tests[5] := times;
  # reset
  BreakOnError := breakOnError;
end);

BindGlobal("TEST", AtomicRecord( rec(Timings := rec())));
TEST.compareFunctions := AtomicRecord(rec());
TEST.compareFunctions.uptonl := function(a, b)
  a := ShallowCopy(a);
  b := ShallowCopy(b);
  while Length(a) > 0 and a[Length(a)] = '\n' do
    Remove(a);
  od;
  while Length(b) > 0 and b[Length(b)] = '\n' do
    Remove(b);
  od;
  return a=b;
end;
TEST.compareFunctions.uptowhitespace := function(a, b)
  a := ReplacedString(ShallowCopy(a), "\\\n", "");
  b := ReplacedString(ShallowCopy(b), "\\\n", "");
  RemoveCharacters(a, " \n\t\r");
  RemoveCharacters(b, " \n\t\r");
  return a=b;
end;


##  
##  <#GAPDoc Label="Test">
##  <ManSection>
##  <Func Name="Test" Arg='fname[, optrec]'/>
##  <Returns><K>true</K> or <K>false</K>.</Returns>
##  <Description>
##  The argument <Arg>fname</Arg> must be the name of a file or an 
##  open input stream. The content of this file or stream should contain
##  &GAP; input and output. The function <Ref Func="Test" /> runs the input
##  lines, compares the actual output with the output stored in 
##  <Arg>fname</Arg> and reports differences. With an optional record as
##  argument <Arg>optrec</Arg> details of this process can be adjusted.
##  <P/>
##  More precisely, the content of <Arg>fname</Arg> must have the following
##  format. <Br/>
##  Lines starting with <C>"gap> "</C> are considered as &GAP; input, 
##  they can be followed by lines starting with <C>"> "</C> if the input is
##  continued over several lines. <Br/>
##  To allow for comments in <Arg>fname</Arg> the following lines are ignored
##  by default: lines at the beginning of <Arg>fname</Arg> that start with
##  <C>"#"</C>, and one empty line together with one or more lines starting 
##  with <C>"#"</C>.<Br/>
##  All other lines are considered as &GAP; output from the
##  preceding &GAP; input.
##  <P/>
##  By default the actual &GAP; output is compared exactly with the
##  stored output, and if these are different some information about the 
##  differences is printed.
##  <P/>
##  If any differences are found then <Ref Func="Test" /> returns <K>false</K>,
##  otherwise <K>true</K>.
##  <P/>
##  If the optional argument <Arg>optrec</Arg> is given it must be a record.
##  The following components of <Arg>optrec</Arg> are recognized and can change
##  the default behaviour of <Ref Func="Test" />:
##  <List>
##  <Mark><C>ignoreComments</C></Mark>
##  <Item>If set to <K>false</K> then no lines in <Arg>fname</Arg>
##  are ignored as explained above (default is <K>true</K>).</Item>
##  <Mark><C>width</C></Mark>
##  <Item>The screen width used for the new output (default is <C>80</C>).
##  </Item>
##  <Mark><C>compareFunction</C></Mark>
##  <Item>This must be a function that gets two strings as input, the newly
##  generated and the stored output of some &GAP; input. The function must
##  return <K>true</K> or <K>false</K>, indicating if the strings should
##  be considered equivalent or not. By default <Ref Oper="\=" /> is used.
##  <Br/>
##  Two strings are recognized as abbreviations in this component: 
##  <C>"uptowhitespace"</C> checks if the two strings become equal after
##  removing all white space. And <C>"uptonl"</C> compares the string up
##  to trailing newline characters.
##  </Item>
##  <Mark><C>reportDiff</C></Mark>
##  <Item>A function that gets six arguments and reports a difference in the
##  output: the &GAP; input, the expected &GAP; output, the newly generated
##  output, the name of tested file, the line number of the input, the
##  time to run the input. (The default is demonstrated in the example
##  below.)</Item>
##  <Mark><C>rewriteToFile</C></Mark>
##  <Item>If this is bound to a string it is considered as a file name
##  and that file is written with the same input and comment lines as
##  <Arg>fname</Arg> but the output substituted by the newly generated
##  version (default is <K>false</K>).</Item>
##  <Mark><C>writeTimings</C></Mark>
##  <Item>If this is bound to a string it is considered as a file name,
##  that file is written and contains timing information for each input 
##  in <Arg>fname</Arg>. </Item>
##  <Mark><C>compareTimings</C></Mark>
##  <Item>If this is bound to a string it is considered as name of a file to 
##  which timing information was stored via <C>writeTimings</C> in a previous
##  call. The new timings are compared to the stored ones. 
##  By default only commands which take more than a threshold of 
##  100 milliseconds are considered, and only differences of more than 20% are
##  considered significant. These defaults can be overwritten by assigning a 
##  list <C>[timingfile, threshold, percentage]</C> to this component.
##  (The default of <C>compareTimings</C> is <K>false</K>.)</Item>
##  <Mark><C>reportTimeDiff</C></Mark>
##  <Item>This component can be used to overwrite the default function to
##  display timing differences. It must be a function with 5 arguments:
##  &GAP; input, name of test file, line number, stored time, new time.
##  </Item>
##  <Mark><C>ignoreSTOP_TEST</C></Mark>
##  <Item>By default set to <K>true</K>, in that case the output of &GAP;
##  input starting with <C>"STOP_TEST"</C> is not checked.</Item>
##  <!--  don't document now, needs some work to become useful
##  <Mark><C>breakOnError</C></Mark>
##  <Item>If this is <K>true</K> then &GAP; enters a break loop in case of 
##  an error (default is <K>false</K>).</Item>
##  -->
##  <Mark><C>showProgress</C></Mark>
##  <Item>If this is <K>true</K> then &GAP; prints position information
##  and the input line before it is processed
##  (default is <K>false</K>).</Item>
##  <Mark><C>subsWindowsLineBreaks</C></Mark>
##  <Item>If this is <K>true</K> then &GAP; substitutes DOS/Windows style
##  line breaks "\r\n" by UNIX style line breaks "\n" after reading the test
##  file. (default is <K>true</K>).</Item>
##  <Mark><C>showProgress</C></Mark>
##  <Item>If this is <K>true</K> then &GAP; prints position information
##  and the input line before it is processed
##  (default is <K>false</K>).</Item>
##  <Mark><C>subsWindowsLineBreaks</C></Mark>
##  <Item>If this is <K>true</K> then &GAP; substitutes DOS/Windows style
##  line breaks "\r\n" by UNIX style line breaks "\n" after reading the test
##  file. (default is <K>true</K>).</Item>
##  </List>
## 
##  <Example><![CDATA[
##  gap> tnam := Filename(DirectoriesLibrary(), "../doc/ref/demo.tst");;
##  gap> mask := function(str) return Concatenation("| ", 
##  >          JoinStringsWithSeparator(SplitString(str, "\n", ""), "\n| "),
##  >          "\n"); end;;
##  gap> Print(mask(StringFile(tnam)));
##  | # this is a demo file for the 'Test' function
##  | #
##  | gap> g := Group((1,2), (1,2,3));
##  | Group([ (1,2), (1,2,3) ])
##  | 
##  | # another comment following an empty line
##  | # the following fails:
##  | gap> a := 13+29;
##  | 41
##  gap> ss := InputTextString(StringFile(tnam));;
##  gap> Test(ss);
##  ########> Diff in test stream, line 8:
##  # Input is:
##  a := 13+29;
##  # Expected output:
##  41
##  # But found:
##  42
##  ########
##  false
##  gap> RewindStream(ss);
##  true
##  gap> dtmp := DirectoryTemporary();;
##  gap> ftmp := Filename(dtmp,"demo.tst");;
##  gap> Test(ss, rec(reportDiff := Ignore, rewriteToFile := ftmp));
##  false
##  gap> Test(ftmp);
##  true
##  gap> Print(mask(StringFile(ftmp)));
##  | # this is a demo file for the 'Test' function
##  | #
##  | gap> g := Group((1,2), (1,2,3));
##  | Group([ (1,2), (1,2,3) ])
##  | 
##  | # another comment following an empty line
##  | # the following fails:
##  | gap> a := 13+29;
##  | 42
##  ]]></Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction("Test", function(arg)
  local fnam, nopts, opts, size, full, pf, ret, lines, ign, new, n, 
        cT, ok, oldtimes, thr, delta, len, c, i, j, d;
  
  # get arguments and set options
  fnam := arg[1];
  if Length(arg) > 1 and IsRecord(arg[2]) then
    nopts := arg[2];
  else 
    nopts := rec();
  fi;
  opts := rec(
           ignoreComments := true,
           isStream := IsStream(fnam),
           width := 80,
           ignoreSTOP_TEST := true,
           compareFunction := EQ,
           showProgress := false,
           writeTimings := false,
           compareTimings := false,
           reportTimeDiff := function(inp, fnam, line, oldt, newt)
             local d;
             d := String(Int(100*(newt-oldt)/oldt));
             if d[1] <> '-' then
               d := Concatenation("+", d);
             fi;
             Print("########> Time diff in ",
                   fnam,", line ",line,":\n");
             Print("# Input:\n", inp);
             Print("# Old time: ", oldt,"   New time: ", newt,
             "    (", d, "%)\n");
           end,
           rewriteToFile := false,
           breakOnError := false,
           reportDiff := function(inp, expout, found, fnam, line, time)
             if IsStream(fnam) then
               fnam := "test stream";
             fi;
             Print("########> Diff in ",
                   fnam,", line ",line,":\n");
             Print("# Input is:\n", inp);
             Print("# Expected output:\n", expout);
             Print("# But found:\n", found);
             Print("########\n");
           end,
           subsWindowsLineBreaks := true,
         );
  for c in RecFields(nopts) do
    opts.(c) := nopts.(c);
  od;
  # check shortcuts
  if IsString(opts.compareFunction) then
    if IsBound(TEST.compareFunctions.(opts.compareFunction)) then
      opts.compareFunction := TEST.compareFunctions.(opts.compareFunction);
    else
      opts.compareFunction := EQ;
    fi;
  fi;

  # now start the work
  size := SizeScreen();
  SizeScreen([opts.width, size[2]]);
  
  # remember the full input 
  if not opts.isStream then
    full := StringFile(fnam);
    if full = fail then
      Error("Cannot read file ",fnam,"\n");
      return;
    fi;
  else
    full := ReadAll(fnam);
  fi;
  # change Windows to UNIX line breaks
  if opts.subsWindowsLineBreaks = true then
    full := ReplacedString(full, "\r\n", "\n");
  fi;
  
  # split input into GAP input, GAP output and comments
  pf := ParseTestInput(full, opts.ignoreComments);
  
  # run the GAP inputs and collect the outputs and the timings
  RunTests(pf, rec(breakOnError := opts.breakOnError, 
                   showProgress := opts.showProgress));

  # reset screen width
  SizeScreen(size);

  # check for and report differences
  ret := true;
  for i in [1..Length(pf[1])] do
    if opts.compareFunction(pf[2][i], pf[4][i]) <> true then
      if not opts.ignoreSTOP_TEST or 
         PositionSublist(pf[1][i], "STOP_TEST") <> 1 then
        ret := false;
        opts.reportDiff(pf[1][i], pf[2][i], pf[4][i], fnam, pf[3][i], pf[5][i]);
      else
        # print output of STOP_TEST
        Print(pf[4][i]);
      fi;
    fi;
  od;

  # maybe rewrite the input into a file
  if IsString(opts.rewriteToFile) then
    lines := SplitString(full, "\n", "");
    ign := pf[3][Length(pf[3])];
    new := [];
    for i in ign do
      new[i] := lines[i];
      Add(new[i], '\n');
    od;
    for i in [1..Length(pf[1])] do
      n := Number(pf[1][i], c-> c = '\n'); 
      new[pf[3][i]] := "";
      for j in [1..Number(pf[1][i], c-> c = '\n')] do
        Append(new[pf[3][i]], lines[pf[3][i]+j-1]);
        Add(new[pf[3][i]], '\n');
      od; 
      if PositionSublist(pf[1][i], "STOP_TEST") <> 1 then
        Append(new[pf[3][i]], pf[4][i]);
      fi;
    od;
    new := Concatenation(Compacted(new));
    FileString(opts.rewriteToFile, new);
  fi;

  # maybe store the timings into a file
  if IsString(opts.writeTimings) then
    PrintTo(opts.writeTimings, "TEST.Timings.(\"", opts.writeTimings,
            "\") := \n", pf[5], ";\n");
  fi;

  # maybe compare timings
  cT := opts.compareTimings;
  if IsList(cT) and IsString(cT[1]) then
    ok := READ(cT[1]);
    if not ok then
      Info(InfoWarning, 1, "Could not read timings from ", cT[1]);
    else
      oldtimes := TEST.Timings.(cT[1]);
      if Length(cT) > 1 and IsInt(cT[2]) then
        thr := cT[2];
      else
        thr := 100;
      fi;
      if Length(cT) > 2 and IsInt(cT[3]) then
        delta := cT[3];
      else 
        delta := 10;
      fi;
      for i in [1..Length(pf[1])] do
        if oldtimes[i] >= thr and 
           AbsInt(oldtimes[i] - pf[5][i])/oldtimes[i] > delta/100 then
          opts.reportTimeDiff(pf[1][i], fnam, pf[3][i], oldtimes[i], pf[5][i]);
        fi;
      od;
      # compare total times
      len := Length(oldtimes);
      if oldtimes[len] >= thr and
         AbsInt(oldtimes[len] - pf[5][len])/oldtimes[len] > delta/100 then
         d := String(Int(100*(pf[5][len] - oldtimes[len])/oldtimes[len]));
         if d[1] <> '-' then
           d := Concatenation("+", d);
         fi;
         Print("########> Total time for ", fnam, ":\n");
         Print("# Old time: ", oldtimes[len],"   New time: ", pf[5][len],
         "    (", d, "%)\n");
      fi;
    fi;
  fi;

  # store internal test data in TEST
  TEST.lastTestData := pf;

  # return true/false
  return ret;
end);


##  <#GAPDoc Label="TestDirectory">
##  <ManSection>
##  <Func Name="TestDirectory" Arg='inlist[, optrec]'/>
##  <Returns><K>true</K> or <K>false</K>.</Returns>
##  <Description>
##  The argument <Arg>inlist</Arg> must be either a single filename
##  or directory name, or a list of filenames and directories.
##  The function <Ref Func="TestDirectory" /> will take create a list of files
##  to be tested by taking any files in <Arg>inlist</Arg>, and recursively searching
##  any directories in <Arg>inlist</Arg> for files ending in <C>.tst</C>.
##  Each of these files is then run through <Ref Func="Test" />, and the results
##  printed, and <K>true</K> returned if all tests passed.
##  <P/>
##  If the optional argument <Arg>optrec</Arg> is given it must be a record.
##  The following components of <Arg>optrec</Arg> are recognized and can change
##  the default behaviour of <Ref Func="TestDirectory" />:
##  <List >
##  <Mark><C>testOptions</C></Mark>
##  <Item>A record which will be passed on as the second argument of <Ref Func="Test" />
##  if present.</Item>
##  <Mark><C>earlyStop</C></Mark>
##  <Item>If <K>true</K>, stop as soon as any <Ref Func="Test" /> fails (defaults to <K>false</K>).
##  </Item>
##  <Mark><C>showProgress</C></Mark>
##  <Item>Print information about how tests are progressing (defaults to <K>true</K>).
##  </Item>
##  <Mark><C>exitGAP</C></Mark>
##  <Item>Rather than returning <K>true</K> or <K>false</K>, exit GAP with the return value
##  of GAP set to success or fail, depending on if all tests passed (defaults to <K>false</K>).
##  </Item>
##  <Mark><C>stonesLimit</C></Mark>
##  <Item>Only try tests which take less than <C>stonesLimit</C> stones (defaults to infinity)</Item>
##  <Mark><C>renormaliseStones</C></Mark>
##  <Item>Re-normalise the stones number given in every tst files's 'STOP_TEST'</Item>
##  </List>
## 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

###################################
##
## TestDirectory(<files> [, <options> ])
## <files>: A directory (or filename) or list of filenames and directories
## <options>: Optional record of options (with defaults)
## 
##    testOptions := rec()   : Options to pass on to Test
##    earlyStop := false     : Stop once one test fails
##    showProgress := true   : Show progress
##    recursive := true      : Search through directories recursively
##    exitGAP := false       : Exit GAP, setting exit value depending on if tests succeeded
##    stonesLimit := infinity: Set limit (in GAPstones) on longest test to be run.
##    renormaliseStones := false: Edit tst files to re-normalise the gapstones stored in every file.
##
##

InstallGlobalFunction( "TestDirectory", function(arg)
  local basedirs, nopts, opts, files, newfiles, filestones, filetimes, 
        f, c, i, recurseFiles, StringEnd, getStones, setStones,
        startTime, time, stones, testResult, testTotal,
        totalTime, totalStones, STOP_TEST_CPY, stopPos,
        count, prod;
  

  testTotal := true;
  totalTime := 0;
  totalStones := 0;
  count := 0;
  prod := 1;
  
  STOP_TEST_CPY := STOP_TEST;
  STOP_TEST := function(arg) end;
  
  StringEnd := function(str, postfix)
    return Length(str) >= Length(postfix) and str{[Length(str)-Length(postfix)+1..Length(str)]} = postfix;
  end;
  
  getStones := function(file)
    local lines, l, start, finish, stones;
    
    lines := SplitString(StringFile(file.name),"\n");
    for l in lines do
      if PositionSublist(l, "STOP_TEST") <> fail then
        # Try our best to get the stones out!
        start := PositionSublist(l, ",");
        finish := PositionSublist(l, ")");
        stones := EvalString(l{[start+1..finish-1]});
        if IsInt(stones) then
          return stones;
        fi;
      fi;
    od;
    return 0;
  end;
  
  setStones := function(file, newstones)
    local lines, l, start, finish, stones;
    lines := SplitString(StringFile(file.name), "\n");
    for i in [1..Length(lines)] do
      if PositionSublist(lines[i], "STOP_TEST") <> fail then
        # Try our best to get the stones out!
        start := PositionSublist(lines[i], ",");
        finish := PositionSublist(lines[i], ")");
        stones := EvalString(lines[i]{[start+1..finish-1]});
        if IsInt(stones) then
          lines[i] := Concatenation(lines[i]{[1..start]}," ",String(newstones),
                                    lines[i]{[finish..Length(lines[i])]});
          FileString(file.name, Concatenation(List(lines, x -> Concatenation(x,"\n"))));
        else
          Print("Unable to parse STOP_TEST in ", file.name);
        fi;
      fi;
    od;
  end;
          
    
  
  if IsString(arg[1]) or IsDirectory(arg[1]) then
    basedirs := [arg[1]];
  else
    basedirs := arg[1];
  fi;
    
  if Length(arg) > 1 and IsRecord(arg[2]) then
    nopts := arg[2];
  else
    nopts := rec();
  fi;
  
  opts := rec(
    testOptions := rec(),
    earlyStop := false,
    showProgress := true,
    exitGAP := false,
    stonesLimit := infinity,
    renormaliseStones := false
  );
  
  for c in RecFields(nopts) do
    opts.(c) := nopts.(c);
  od;
  
  
  if opts.exitGAP then
    GAP_EXIT_CODE(1);
  fi;
  
  files := [];
  filetimes := [];
  
  recurseFiles := function(dir, basedir)
    local dircontents, testfiles, t, testrecs, shortName, recursedirs, d;
    dircontents := List(DirectoryContents(dir), x -> Filename(Directory(dir), x));
    testfiles := Filtered(dircontents, x -> Length(x) > 4 and x{[Length(x)-3..Length(x)]} = ".tst");
    testrecs := [];
    for t in testfiles do
      shortName := t{[Length(basedir)+1..Length(t)]};
      if shortName[1] = '/' then
        shortName := shortName{[2..Length(shortName)]};
      fi;
      Add(testrecs, rec(name := t, shortName := shortName));
    od;
    Append(files, testrecs);
    recursedirs := Filtered(dircontents, x -> IsDirectoryPath(x) and not(StringEnd(x,"/.")) and not(StringEnd(x,"/..")));
    for d in recursedirs do
      recurseFiles(d, basedir);
    od;
  end;
  
  files := [];
  for f in basedirs do
    if IsDirectoryPath(f) then
      if IsDirectory(f) then
        recurseFiles(f![1], f![1]);
      else
        recurseFiles(f,f);
      fi;
    else
      Add(files, rec(name := f, shortName := f));
    fi;
  od;

  filestones := List(files, getStones);
  
  # Sort fastest to slowest
  SortParallel(filestones, files);
  
  stopPos := PositionProperty(filestones, x -> x >= opts.stonesLimit);
  if stopPos <> fail then
    filestones := filestones{[1..stopPos-1]};
    files := files{[1..stopPos-1]};
  fi;
    
  
  if opts.showProgress then
    Print( "Architecture: ", GAPInfo.Architecture, "\n\n",
           "test file         GAP4stones     time(msec)\n",
           "-------------------------------------------\n" );
  fi;
  
  for i in [1..Length(files)] do
    if opts.showProgress then
      Print("testing: ", files[i].name, "\n");
    fi;
    
    startTime := Runtime();
    testResult := Test(files[i].name, opts.testOptions);
    if not(testResult) and opts.earlyStop then
      STOP_TEST := STOP_TEST_CPY;
      if opts.exitGAP then
        # Do not change the next line - it is needed for testing scrips
        Print( "#I  Errors detected while testing\n\n" );
        QUIT_GAP(1);
      fi;
      return false;
    fi;
    testTotal := testTotal and testResult;
    
    time := Runtime() - startTime;
    filetimes[i] := time;
    if time > 100 and filestones[i] > 1000 then
      stones := QuoInt(filestones[i], time);
      totalTime := totalTime + time;
      totalStones := totalStones + filestones[i];
      prod := prod * stones;
      count := count + 1;
    else
      stones := 0;
    fi;
    
    if opts.showProgress then
      Print( String( files[i].shortName, -20 ),
             String( stones, 8 ),
             String( time, 15 ) );
      if i < Length(filestones) and filestones[i+1] > 0 and totalTime > 0 then
      #Print(totalTime,":", filestones[i+1],":" ,10^3,":",totalStones,":" );
        Print("   ( next ~", Int( (totalTime * filestones[i+1] )/10^3/totalStones), " sec )" );
      fi;
      Print("\n");
    fi;
  od;       
  
  STOP_TEST := STOP_TEST_CPY;
  
  Print("-------------------------------------------\n");
  if count = 0 then
    count:= 1;
  fi;
  Print( "total",
         String( RootInt( prod, count ), 23 ),
         String( totalTime, 15 ), "\n\n" );
        
        
  if opts.renormaliseStones then
    for i in [1..Length(files)] do
      if filetimes[i] < 5 then
        setStones(files[i], 1);
      else
        setStones(files[i], filetimes[i] * 10000);
      fi;
    od;
  fi;
  
  if opts.exitGAP then
    if testTotal then
      # Do not change the next line - it is needed for testing scrips
      Print( "#I  No errors detected while testing\n\n" );
      QUIT_GAP(0);
    else
      # Do not change the next line - it is needed for testing scrips
      Print( "#I  Errors detected while testing\n\n" );
      QUIT_GAP(1);
    fi;
  fi;
  
  return testTotal;
end);
