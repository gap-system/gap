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
##  This file contains functions for test files.
##

##  FirstDiff := function(a, b)
##    return First([1..Length(a)],  i-> not IsBound(b[i]) or b[i] <> a[i]);
##  end;

InstallGlobalFunction(ParseTestInput, function(str, ignorecomments, fnam)
  local lines, inp, pos, outp, ign, commands, i, skipstate, checkifelsefi, foundcmd, testError;
  lines := SplitString(str, "\n", "");
  inp := [];
  pos := [];
  outp := [];
  ign := [];
  commands := [];
  i := 1;
  testError := function(s)
     if IsStream(fnam) then
        ErrorNoReturn(s, " in test stream, line ", i);
    else
        ErrorNoReturn(s, " at ", fnam, ":", i);
    fi;
  end;
  checkifelsefi := l -> ForAny(["#@if","#@else","#@fi"], x -> StartsWith(l, x));
  # Set to true if we find a #@if, #@else or #@fi. Used to check these do not
  # occur in the middle of a single input/output test block.
  foundcmd := false;
  # skipstate represents the current status of '#@if/#@else/#@fi'
  # 0: not in a '#@if'
  # 1: in a #@if with a true condition
  #-1: in a #@if with a false condition
  # 2: in the #@else of a #@if with a false condition
  #-2: in the #@else of a #@if with a true condition
  # Code is executed whenever skipstate >= 0
  skipstate := 0;
  while i <= Length(lines) do
    if checkifelsefi(lines[i]) then
        foundcmd := true;
        Add(ign, i);
        if StartsWith(lines[i], "#@if") then
            if skipstate <> 0 then
                testError("Invalid test file: Nested #@if");
            fi;
            if EvalString(lines[i]{[5..Length(lines[i])]}) then
                skipstate := 1;
            else
                skipstate := -1;
            fi;
        elif StartsWith(lines[i], "#@else") then
            if skipstate = 0 then
                testError("Invalid test file: #@else without #@if");
            elif AbsoluteValue(skipstate) = 2 then
                testError("Invalid test file: two #@else");
            else
                # change 1 -> -2, -1 -> 2
                skipstate := skipstate * -2;
            fi;
        else # Must be #@fi
            if skipstate = 0 then
                testError("Invalid test file: #@fi without #@if");
            fi;
            skipstate := 0;
        fi;

        i := i + 1;
        continue;
    fi;

    if skipstate < 0 then
        Add(ign, i);
        i := i + 1;
        continue;
    fi;


    if Length(outp) = 0 and Length(inp) = 0 and (Length(lines[i]) = 0 or lines[i][1] = '#') then
      if ignorecomments = true then
        # ignore comment lines and empty lines at beginning of file
        Add(ign, i);
        # execute `#@exec` immediately so `#@if` can depend on it
        if StartsWith(lines[i], "#@exec") then
          Read(InputTextString(Concatenation(lines[i]{[7..Length(lines[i])]}, ";\n")));
        elif Length(lines[i]) > 3 and lines[i]{[1..2]} = "#@" then
          Add(commands, lines[i]);
        fi;
        i := i+1;
      else
        Add(inp, "\n");
        Add(pos, i);
        i := i+1;
        while i <= Length(lines) and (Length(lines[i]) = 0 or (StartsWith(lines[i], "#") and not StartsWith(lines[i], "#@"))) do
          i := i+1;
        od;
        Add(outp, JoinStringsWithSeparator(lines{[1..i-1]}, "\n"));
        Add(outp[1], '\n');
      fi;
    elif Length(lines[i]) = 0 and ignorecomments = true and i < Length(lines)
         and StartsWith(lines[i+1], "#") then
      # ignore an empty line followed by comment lines
      Add(ign, i);
      i := i+1;
      while i <= Length(lines) and StartsWith(lines[i], "#") and
            not StartsWith(lines[i], "#@") do
        Add(ign, i);
        i := i+1;
      od;
    elif StartsWith(lines[i], "gap> ") then
      foundcmd := false;
      Add(outp, "");
      Add(inp, lines[i]{[6..Length(lines[i])]});
      Add(inp[Length(inp)], '\n');
      Add(pos, i);
      i := i+1;
    elif StartsWith(lines[i], "> ") then
      if foundcmd then
        testError("Invalid test file: #@ command found in the middle of a single test");
      fi;
      Append(inp[Length(inp)], lines[i]{[3..Length(lines[i])]});
      Add(inp[Length(inp)], '\n');
      i := i+1;
    elif StartsWith(lines[i], ">\t") then
        testError("Invalid test file: Continuation prompt '> ' followed by a tab, expected a regular space");
    elif Length(outp) > 0 then
      if foundcmd and not ForAll(lines[i], c -> c = ' ' or c = '\t') then
        testError("Invalid test file: #@ command found in the middle of a single test");
      fi;
      Append(outp[Length(outp)], lines[i]);
      Add(outp[Length(outp)], '\n');
      i := i+1;
    else
      testError("Invalid test file");
      i := i+1;
    fi;
  od;

  if skipstate <> 0 then
    testError("Invalid test file: Unterminated #@if");
  fi;

  Add(pos, ign);
  return rec( inp := inp, outp := outp, pos := pos, commands := commands );
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
    ErrorNoReturn("Cannot read file ",fnam,"\n");
  fi;
  return ParseTestInput(str, ignorecomments, fnam);
end);

InstallGlobalFunction(RunTests, function(tests, inopts, fnam)
  local opts, breakOnError, alwaysPrintTracebackOnError, inp, outp,
        pos, cmp, times, ttime, nrlines, s, res, fres, t, f, i,
        localbag, failures, startsize, size;
  # don't enter break loop in case of error during test
  opts := rec( breakOnError := false, alwaysPrintTracebackOnError:= false,
               showProgress := "some", localdef := false );

  if not IS_OUTPUT_TTY() then
    opts.showProgress := false;
  fi;
  for f in RecNames(inopts) do
    opts.(f) := inopts.(f);
  od;

  # now start the work
  startsize := SizeScreen();
  SizeScreen([opts.width, startsize[2]]);

  # we collect outputs and add them to 'tests.cmp'
  # also collect timings and add them to 'tests.times'
  inp := tests.inp;
  outp := tests.outp;
  pos := tests.pos;
  cmp := [];
  times := [];
  tests.cmp := cmp;
  tests.times := times;
  failures := 0;

  if Length(inp) = 0 then
    return 0;
  fi;

  breakOnError := BreakOnError;
  BreakOnError := opts.breakOnError;
  alwaysPrintTracebackOnError:= AlwaysPrintTracebackOnError;
  AlwaysPrintTracebackOnError:= opts.alwaysPrintTracebackOnError;

  localbag := false;
  if opts.localdef <> false then
    # Create a local variables bag for the variables listed in
    # #@local (if it exists). We run the test in this context
    # so it does not create/overwrite global variables
    localbag := CREATE_LOCAL_VARIABLES_BAG(opts.localdef);
  fi;
  ttime := Runtime();
  nrlines := pos[Length(pos) - 1];
  for i in [1..Length(inp)] do
    if opts.showProgress = true then
      Print("# line ", pos[i], ", input:\n",inp[i]);
    elif opts.showProgress = "some" then
      Print("\r# line ", pos[i],
            " of ", nrlines,
            " (", Int(pos[i] / nrlines * 100), "%)",
            "\c");
    fi;
    s := InputTextString(inp[i]);
    res := "";
    fres := OutputTextString(res, false);
    t := Runtime();
    READ_STREAM_LOOP(s, fres, localbag);
    t := Runtime() - t;
    CloseStream(fres);
    CloseStream(s);
    # check whether the user aborted by pressing ctrl-C
    if StartsWith(res, "Error, user interrupt") then
        BreakOnError := breakOnError;
        AlwaysPrintTracebackOnError:= alwaysPrintTracebackOnError;
        Error("user interrupt");
        BreakOnError := opts.breakOnError;
        AlwaysPrintTracebackOnError:= opts.alwaysPrintTracebackOnError;
    fi;
    Add(cmp, res);
    Add(times, t);
      # check for and report differences
    if opts.compareFunction(opts.transformFunction(tests.outp[i]),
                            opts.transformFunction(tests.cmp[i])) <> true then
      if opts.showProgress = "some" then
        Print("\r                                    \c\r"); # clear the line
      fi;
      size := SizeScreen();
      SizeScreen(startsize);
      if not opts.ignoreSTOP_TEST or
        PositionSublist(tests.inp[i], "STOP_TEST") <> 1 then
        failures := failures + 1;
        opts.reportDiff(tests.inp[i], tests.outp[i], tests.cmp[i], fnam, tests.pos[i], tests.times[i]);
      else
        # print output of STOP_TEST
        Print(tests.cmp[i]);
      fi;
      SizeScreen(size);
    fi;
  od;
  if opts.showProgress = "some" then
    Print("\r                                    \c\r"); # clear the line
  fi;
  # add total time to 'times'
  Add(times, Runtime() - ttime);
  # reset
  BreakOnError := breakOnError;
  AlwaysPrintTracebackOnError:= alwaysPrintTracebackOnError;
  SizeScreen(startsize);
  return failures;
end);

BindGlobal("TEST", AtomicRecord( rec(Timings := rec())));

TEST.transformFunctions := AtomicRecord(rec());
TEST.transformFunctions.removenl := function(a)
  a := ShallowCopy(a);
  while Length(a) > 0 and a[Length(a)] = '\n' do
    Remove(a);
  od;
  return a;
end;
TEST.transformFunctions.removewhitespace := function(a)
  a := ReplacedString(ShallowCopy(a), "\\\n", "");
  RemoveCharacters(a, " \n\t\r");
  return a;
end;

TEST.compareFunctions := AtomicRecord(rec());
TEST.compareFunctions.uptonl := function(a, b)
  a := TEST.transformFunctions.removenl(a);
  b := TEST.transformFunctions.removenl(b);
  return a=b;
end;
TEST.compareFunctions.uptowhitespace := function(a, b)
  a := TEST.transformFunctions.removewhitespace(a);
  b := TEST.transformFunctions.removewhitespace(b);
  return a=b;
end;


##
## CREATE_LOCAL_VARIABLES_BAG(namelist)
##
## Given a (possibly empty) comma separated string 'namelist',
## create a local variable bag which contains the names in 'namelist'.
##
InstallGlobalFunction(CREATE_LOCAL_VARIABLES_BAG, function(namelist)
    local localvars, func;
    NormalizeWhitespace(namelist);
    if IsEmpty(namelist) then
        localvars := "";
    else
        localvars := Concatenation("local ", namelist, ";");
    fi;
    func := Concatenation("(function() ", localvars,
                          "return GetCurrentLVars(); end)()");
    return EvalString(func);
end);

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
##  Note that the <C>rewriteToFile</C> option is especially useful for
##  generating test files.
##  <P/>
##  More precisely, the content of <Arg>fname</Arg> must have the following
##  format. <Br/>
##  Lines starting with <C>"gap> "</C> are considered as &GAP; input,
##  they can be followed by lines starting with <C>"> "</C> if the input is
##  continued over several lines. <Br/>
##  To allow for comments in <Arg>fname</Arg> the following lines are ignored
##  by default: lines at the beginning of <Arg>fname</Arg> that start with
##  <C>"#"</C> or are empty, and one empty line together with one or more
##  lines starting with <C>"#"</C>.<Br/>
##  All other lines are considered as &GAP; output from the
##  preceding &GAP; input.
##  <P/>
##  Lines which begin "#@" define special configuration options for tests.
##  The <C>#@local</C> and <C>#@exec</C> options can only be used before
##  any &GAP; input, and the other commands can only be used between
##  individual tests (just before a line starting <C>gap></C>, or at end
##  of the file).
##  Currently defined options are:
##  <List>
##  <Mark>#@local identifierlist</Mark>
##  <Item>Run all the tests in the input as if it is in a function with local variable list
##  <C>identifierlist</C>, which is a comma-separated list of
##  identifiers. Multiple #@local lines may be used.
##  These lines should <E>not</E> end with a comma or semicolon.
##  If this option is used then an error will occur unless <E>all</E>
##  the variables used are included in the local list.
##  <P/>
##  As an example, the <Package>Utils</Package> package has a test file
##  <C>tst/iterator.tst</C> which starts with the lines:
##  <Log><![CDATA[
##  #@local  c3c3, cart, G, h, it1, it2, iter, iter0, iter4, iterL
##  #@local  L, n, pairs0, pairs4, pairsL, s3, s4
##  ]]></Log>
##  </Item>
##  <Mark>#@exec gapcode</Mark>
##  <Item>Execute the code <C>gapcode</C> before any test in the input is run.
##  This allows defining global variables when using <C>#@local</C>.
##  </Item>
##  <Mark>#@if EXPR ...  [#@else] ... #@fi</Mark>
##  <Item>A <C>#@if</C> allows to conditionally skip parts of the test input depending on
##  the value of a boolean expression. The exact behavior is done as follows:
##  <P/>
##  If the &GAP; expression <C>EXPR</C> evaluates to <K>true</K>, then the lines after the
##  <C>#@if</C> are used until either a <C>#@else</C> or <C>#@fi</C> is
##  reached. If a <C>#@else</C> is present then the code after the <C>#@else</C>
##  is used if and only if <C>EXPR</C> evaluated to <K>false</K>. Finally,
##  once <C>#fi</C> is reached, evaluation continues normally.
##  <P/>
##  Note that <C>EXPR</C> is evaluated after all <C>#@exec</C> lines have been
##  executed but before any tests are run. Thus, it cannot depend on test
##  results or packages loaded in tests, but it can depend on packages loaded
##  via <C>#@exec</C>.
##  <P/>
##  As an example, the &GAP; test suite contains the test file
##  <C>tst/testinstall/pperm.tst</C> which contains the lines:
##  <Log><![CDATA[
##  #@if GAPInfo.BytesPerVariable = 8
##  gap> HASH_FUNC_FOR_PPERM(f, 10 ^ 6) in [260581, 402746];
##  true
##  #@else
##  gap> HASH_FUNC_FOR_PPERM(f, 10 ^ 6);
##  953600
##  #@fi
##  ]]></Log>
##  </Item>
##  </List>
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
##  <Mark><C>transformFunction</C></Mark>
##  <Item>This must be a function that gets one string as input, either the newly
##  generated or the stored output of some &GAP; input. The function must
##  return a new string which will be used to compare the actual and the expected
##  output. By default <Ref Func="IdFunc" /> is used.
##  <Br/>
##  Two strings are recognized as abbreviations in this component:
##  <C>"removewhitespace"</C> removes all white space.
##  And <C>"removenl"</C> removes all trailing newline characters.
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
##  version; if it is bound to <K>true</K>, then this is treated as if
##  it was bound to <Arg>fname</Arg> (default is <K>false</K>). This is
##  especially useful for generating test files because it ensures that
##  the test files are formatted exactly as <Ref Func="Test" /> expects
##  them to be.
##  </Item>
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
##  and the input line before it is processed; if set to <C>"some"</C>,
##  then GAP shows the current line number of the test being processed;
##  if set to <K>false</K>, no progress updates are displayed
##  (default is <C>"some"</C> if GAP's output goes to a terminal, otherwise
##  <K>false</K>). </Item>
##  <Mark><C>subsWindowsLineBreaks</C></Mark>
##  <Item>If this is <K>true</K> then &GAP; substitutes DOS/Windows style
##  line breaks "\r\n" by UNIX style line breaks "\n" after reading the test
##  file. (default is <K>true</K>).</Item>
##  <Mark><C>returnNumFailures</C></Mark>
##  <Item>If this is <K>true</K> then &GAP; returns the number of input
##  lines of the test file which had differences in their output, instead
##  of returning <K>true</K> or <K>false</K>.</Item>
##  </List>
##
##  <Log><![CDATA[
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
##  ]]></Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareGlobalName("TextAttr"); # from GAPDoc
DeclareGlobalName("DefaultReportDiffColors"); # initialized in Test() or by the user
BindGlobal("DefaultReportDiff", function(inp, expout, found, fnam, line, time)
  if UserPreference("UseColorsInTerminal") = true then
    Print(DefaultReportDiffColors.message);
    Print("########> Diff in ");
    if IsStream(fnam) then
      Print("test stream, line ",line,":");
    else
      Print(fnam,":",line);
    fi;
    Print(TextAttr.reset, "\n", DefaultReportDiffColors.message);
    Print("# Input is:", TextAttr.reset, "\n");
    Print(DefaultReportDiffColors.input);
    Print(inp);
    Print(TextAttr.reset, TextAttr.delline, DefaultReportDiffColors.message);
    Print("# Expected output:", TextAttr.reset, "\n");
    Print(DefaultReportDiffColors.expected);
    Print(expout);
    Print(TextAttr.reset, TextAttr.delline, DefaultReportDiffColors.message);
    Print("# But found:", TextAttr.reset, "\n");
    Print(DefaultReportDiffColors.actual);
    Print(found);
    Print(TextAttr.reset, TextAttr.delline, DefaultReportDiffColors.message);
    Print("########", TextAttr.reset, "\n");
  else
    Print("########> Diff in ");
    if IsStream(fnam) then
      Print("test stream, line ",line,":\n");
    else
      Print(fnam,":",line,"\n");
    fi;
    Print("# Input is:\n", inp);
    Print("# Expected output:\n", expout);
    Print("# But found:\n", found);
    Print("########\n");  fi;
end);

InstallGlobalFunction("Test", function(arg)
  local fnam, nopts, opts, full, pf, failures, lines, ign, new,
        cT, ok, oldtimes, thr, delta, len, c, i, j, d, localdef, line;

  # get arguments and set options
  fnam := arg[1];
  if Length(arg) > 1 and IsRecord(arg[2]) then
    nopts := arg[2];
  else
    nopts := rec();
  fi;
  if not IsBound(DefaultReportDiffColors) then
    BindGlobal("DefaultReportDiffColors", rec(
        message := TextAttr.4,  # blue text
        input := "",
        expected := Concatenation(TextAttr.0, TextAttr.b2), # black text on green background
        actual := Concatenation(TextAttr.7, TextAttr.b1),   # white text on red background
        ));
  fi;
  opts := rec(
           ignoreComments := true,
           isStream := IsStream(fnam),
           width := 80,
           ignoreSTOP_TEST := true,
           compareFunction := EQ,
           transformFunction := IdFunc,
           showProgress := "some",
           writeTimings := false,
           compareTimings := false,
           reportTimeDiff := function(inp, fnam, line, oldt, newt)
             local d;
             d := String(Int(100*(newt-oldt)/oldt));
             if d[1] <> '-' then
               d := Concatenation("+", d);
             fi;
             Print("########> Time diff in ");
             if IsStream(fnam) then
               Print("test stream, line ",line,":\n");
             else
               Print(fnam,":",line,"\n");
             fi;
             Print("# Input:\n", inp);
             Print("# Old time: ", oldt,"   New time: ", newt,
             "    (", d, "%)\n");
           end,
           rewriteToFile := false,
           breakOnError := false,
           reportDiff := DefaultReportDiff,
           subsWindowsLineBreaks := true,
           returnNumFailures := false,
           localdef := false,
         );
  if not IS_OUTPUT_TTY() then
    opts.showProgress := false;
  fi;

  if IsHPCGAP then
    # HPCGAP's window size varies in different threads
    opts.transformFunction := "removewhitespace";
    # HPC-GAP's output is not compatible with changing lines
    opts.showProgress := false;
  fi;

  for c in RecNames(nopts) do
    opts.(c) := nopts.(c);
  od;
  # check shortcuts
  if IsString(opts.compareFunction) then
    if IsBound(TEST.compareFunctions.(opts.compareFunction)) then
      opts.compareFunction := TEST.compareFunctions.(opts.compareFunction);
    else
      Error("Unknown compareFunction '", opts.compareFunction, "'");
    fi;
  fi;
  if IsString(opts.transformFunction) then
    if IsBound(TEST.transformFunctions.(opts.transformFunction)) then
      opts.transformFunction := TEST.transformFunctions.(opts.transformFunction);
    else
      Error("Unknown transformFunction '", opts.transformFunction, "'");
    fi;
  fi;

  # remember the full input
  if not opts.isStream then
    full := StringFile(fnam);
    if full = fail then
      ErrorNoReturn("Cannot read file ",fnam,"\n");
    fi;
  else
    full := ReadAll(fnam);
  fi;
  # change Windows to UNIX line breaks
  if opts.subsWindowsLineBreaks = true then
    full := ReplacedString(full, "\r\n", "\n");
  fi;

  # split input into GAP input, GAP output and comments
  pf := ParseTestInput(full, opts.ignoreComments, fnam);

  # Warn if we have not found any tests in the file
  if IsEmpty(pf.inp) then
    Info(InfoWarning, 1, "Test: File does not contain any tests!");
  fi;
  for line in pf.commands do
    if StartsWith(line, "#@local") then
      line := line{[8..Length(line)]};
      if opts.localdef = false then
        opts.localdef := line;
      else
        opts.localdef := Concatenation(opts.localdef, ", ", line);
      fi;
    else
      ErrorNoReturn("Invalid #@ test option: ", line);
    fi;
  od;

  # run the GAP inputs and collect the outputs and the timings
  failures := RunTests(pf, opts, fnam);

  # maybe rewrite the input into a file
  if opts.rewriteToFile = true then
    opts.rewriteToFile := fnam;
  fi;
  if IsString(opts.rewriteToFile) then
    lines := SplitString(full, "\n", "");
    ign := pf.pos[Length(pf.pos)];
    new := [];
    for i in ign do
      new[i] := lines[i];
      Add(new[i], '\n');
    od;
    for i in [1..Length(pf.inp)] do
      new[pf.pos[i]] := "";
      for j in [1 .. Number(pf.inp[i], c -> c = '\n') +
          Number(pf.outp[i], c -> c = '\n')] do
        if (j = 1 and StartsWith(lines[pf.pos[i] + j - 1], "gap> ")) or
            (j > 1 and StartsWith(lines[pf.pos[i] + j - 1], "> ")) then
          Append(new[pf.pos[i]], lines[pf.pos[i] + j - 1]);
          Add(new[pf.pos[i]], '\n');
        fi;
      od;
      if PositionSublist(pf.inp[i], "STOP_TEST") <> 1 then
        Append(new[pf.pos[i]], pf.cmp[i]);
        if pf.cmp[i] <> "" and Last(pf.cmp[i]) <> '\n' then
            Info(InfoWarning, 1, "An output in the .tst file does not end with a newline. GAP does not support this.");
            Info(InfoWarning, 1, "A newline will be inserted to make the file valid, but the test will fail.");
            Info(InfoWarning, 1, "The location of this problem is marked with '# Newline inserted here'.");
            Append(new[pf.pos[i]], "# Newline inserted here by 'rewriteToFile'\n");
        fi;
      fi;
    od;
    new := Concatenation(Compacted(new));
    FileString(opts.rewriteToFile, new);
  fi;

  # maybe store the timings into a file
  if IsString(opts.writeTimings) then
    PrintTo(opts.writeTimings, "TEST.Timings.(\"", opts.writeTimings,
            "\") := \n", pf.times, ";\n");
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
      for i in [1..Length(pf.inp)] do
        if oldtimes[i] >= thr and
           AbsInt(oldtimes[i] - pf.times[i])/oldtimes[i] > delta/100 then
          opts.reportTimeDiff(pf.inp[i], fnam, pf.pos[i], oldtimes[i], pf.times[i]);
        fi;
      od;
      # compare total times
      len := Length(oldtimes);
      if oldtimes[len] >= thr and
         AbsInt(oldtimes[len] - pf.times[len])/oldtimes[len] > delta/100 then
         d := String(Int(100*(pf.times[len] - oldtimes[len])/oldtimes[len]));
         if d[1] <> '-' then
           d := Concatenation("+", d);
         fi;
         Print("########> Total time for ", fnam, ":\n");
         Print("# Old time: ", oldtimes[len],"   New time: ", pf.times[len],
         "    (", d, "%)\n");
      fi;
    fi;
  fi;

  # store internal test data in TEST, in old list format
  TEST.lastTestData := [pf.inp, pf.outp, pf.pos, pf.cmp, pf.times];
  # And also new record format
  TEST.lastTestDataRec := pf;

  # if requested, return number of failures
  if opts.returnNumFailures then
    return failures;
  fi;

  # return true/false
  return (failures = 0);
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
##  Note that the <C>rewriteToFile</C> option is especially useful for
##  generating test files.
##  The following components of <Arg>optrec</Arg> are recognized and can change
##  the default behaviour of <Ref Func="TestDirectory" />:
##  <List>
##  <Mark><C>testOptions</C></Mark>
##  <Item>A record which will be passed on as the second argument of <Ref Func="Test" />
##  if present.</Item>
##  <Mark><C>earlyStop</C></Mark>
##  <Item>If <K>true</K>, stop as soon as any <Ref Func="Test" /> fails (defaults to <K>false</K>).
##  </Item>
##  <Mark><C>showProgress</C></Mark>
##  <Item>Print information about how tests are progressing (defaults to <C>"some"</C>
##  if GAP's output goes to a terminal, otherwise <K>false</K>).
##  </Item>
##  <Mark><C>suppressStatusMessage</C></Mark>
##  <Item>suppress displaying status messages <C>#I  Errors detected while testing</C> and
##  <C>#I  No errors detected while testing</C> after the test (defaults to <K>false</K>).
##  </Item>
##  <Mark><C>rewriteToFile</C></Mark>
##  <Item>If <K>true</K>, then rewrite each test file to disc, with the output substituted
##  by the results of running the test (defaults to <K>false</K>).
##  This is especially useful for generating test files because it ensures that
##  the test files are formatted exactly as <Ref Func="Test" /> expects
##  them to be.
##  </Item>
##  <Mark><C>exclude</C></Mark>
##  <Item>A list of file and directory names which will be excluded from
##  testing (defaults to <K>[]</K>).
##  </Item>
##  <Mark><C>exitGAP</C></Mark>
##  <Item>Rather than returning <K>true</K> or <K>false</K>, exit GAP with the return value
##  of GAP set to success or fail, depending on if all tests passed (defaults to <K>false</K>).
##  </Item>
##  </List>
##
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction( "TestDirectory", function(arg)
    local  testTotalFailures, testFailedFiles, totalTime, totalMem, STOP_TEST_CPY,
           basedirs, nopts, opts, testOptions, earlyStop,
           showProgress, suppressStatusMessage, exitGAP, c, files,
           filetimes, filemems, recurseFiles, f, i, startTime,
           startMem, testResult, time, mem, startGcTime, gctime,
           totalGcTime, filegctimes;

  testTotalFailures := 0;
  testFailedFiles := 0;
  totalTime := 0;
  totalMem := 0;
  totalGcTime := 0;

  STOP_TEST_CPY := STOP_TEST;
  # wrap STOP_TEST_QUIET to drop the return value so it does not get printed below
  STOP_TEST := function(arg) CallFuncList( STOP_TEST_QUIET, arg ); end;

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
    suppressStatusMessage := false,
    rewriteToFile := false,
    exclude := [],
    exitGAP := false,
  );

  for c in RecNames(nopts) do
    opts.(c) := nopts.(c);
  od;
  opts.exclude := Set(opts.exclude);
  opts.testOptions.returnNumFailures := true;

  if opts.exitGAP then
    GapExitCode(1);
  fi;

  files := [];
  filetimes := [];
  filemems := [];
  filegctimes := [];

  recurseFiles := function(dirs, prefix)
    local dircontents, testfiles, t, testrecs, shortName, recursedirs, d, subdirs;
    if Length(dirs) = 0 then return; fi;
    if prefix in opts.exclude then return; fi;
    dircontents := Union(List(dirs, DirectoryContents));
    testfiles := Filtered(dircontents, x -> EndsWith(x, ".tst"));
    testrecs := [];
    for t in testfiles do
      shortName := Concatenation(prefix, t);
      if shortName[1] = '/' then
        shortName := shortName{[2..Length(shortName)]};
      fi;
      if not shortName in opts.exclude then
        Add(testrecs, rec(name := Filename(dirs, t), shortName := shortName));
      fi;
    od;
    Append(files, testrecs);

    recursedirs := Difference(dircontents, testfiles);
    RemoveSet(recursedirs, ".");
    RemoveSet(recursedirs, "..");
    for d in recursedirs do
      subdirs := List(dirs, x -> Directory(Filename(x, d)));
      subdirs := Filtered(subdirs, IsDirectoryPath);
      recurseFiles(subdirs, Concatenation(prefix,d,"/"));
    od;
  end;

  files := [];
  for f in basedirs do
    if not IsString(f) and IsList(f) and ForAll(f, IsDirectoryPath) then
      recurseFiles(List(f, Directory), "");
    elif IsDirectoryPath(f) then
      recurseFiles( [ Directory(f) ], "" );
    else
      Add(files, rec(name := f, shortName := f));
    fi;
  od;

  SortBy(files, f -> [f.shortName, f.name]);

  if opts.showProgress then
    Print( "Architecture: ", GAPInfo.Architecture, "\n\n" );
  fi;

  for i in [1..Length(files)] do
    if opts.showProgress then
      Print("testing: ", files[i].name, "\n");
    fi;

    startTime := Runtime();
    startMem := TotalMemoryAllocated();
    startGcTime := TOTAL_GC_TIME();

    if opts.rewriteToFile then
      opts.testOptions.rewriteToFile := files[i].name;
    fi;
    testResult := Test(files[i].name, opts.testOptions);
    if (testResult <> 0) and opts.earlyStop then
      STOP_TEST := STOP_TEST_CPY;
      if not opts.suppressStatusMessage then
        # Do not change the next line - it is needed for testing scripts
        Print( "#I  Errors detected while testing\n\n" );
      fi;
      if opts.exitGAP then
        QuitGap(1);
      fi;
      return false;
    fi;
    if testResult <> 0 then
      testFailedFiles := testFailedFiles + 1;
    fi;
    testTotalFailures := testTotalFailures + testResult;

    time := Runtime() - startTime;
    mem := TotalMemoryAllocated() - startMem;
    gctime := TOTAL_GC_TIME() - startGcTime;
    filetimes[i] := time;
    filemems[i] := mem;
    filegctimes[i] := gctime;
    totalTime := totalTime + time;
    totalMem := totalMem + mem;
    totalGcTime := totalGcTime + gctime;

    if opts.showProgress then
        Print( String( time, 8 ), " ms (",String(gctime)," ms GC) and ",
               StringOfMemoryAmount( mem ),
               " allocated for ", files[i].shortName, "\n" );
    fi;
  od;

  STOP_TEST := STOP_TEST_CPY;

  Print("-----------------------------------\n");
  Print( "total",
         String( totalTime, 10 ), " ms (",String( totalGcTime )," ms GC) and ",
         StringOfMemoryAmount( totalMem )," allocated\n" );
  Print( "     ", String( testTotalFailures, 10 ), " failures in " );
  if testTotalFailures > 0 then
    Print( testFailedFiles, " of " );
  fi;
  Print( Length(files), " files\n\n" );

  if not opts.suppressStatusMessage then
    if testTotalFailures = 0 then
      # Do not change the next line - it is needed for testing scripts
      Print( "#I  No errors detected while testing\n\n" );
    else
      # Do not change the next line - it is needed for testing scripts
      Print( "#I  Errors detected while testing\n\n" );
    fi;
  fi;

  if opts.exitGAP then
    if testTotalFailures = 0 then
      QuitGap(0);
    else
      QuitGap(1);
    fi;
  fi;

  return testTotalFailures = 0;
end);

#############################################################################
##
## TestPackage( <pkgname> )
##
##  <#GAPDoc Label="TestPackage">
##  <ManSection>
##  <Func Name="TestPackage" Arg='pkgname'/>
##  <Description>
##  It is recommended that a &GAP; package specifies a standard test in its
##  <F>PackageInfo.g</F> file. If <A>pkgname</A> is a string with the name of
##  a &GAP; package, then <C>TestPackage(pkgname)</C> will check if this
##  package is loadable and has the standard test, and will run this test in
##  the current &GAP; session.<P/>
##
##  The output of the test depends on the particular package, and it also
##  may depend on the current &GAP; session (loaded packages, state of the
##  random sources, defined global variables etc.).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
InstallGlobalFunction( "TestPackage", function(pkgname)
local testfile, str;
pkgname := LowercaseString(pkgname);
if not IsBound( GAPInfo.PackagesInfo.(pkgname) ) then
    Print("#I  No package with the name ", pkgname, " is available\n");
    return fail;
elif LoadPackage( pkgname ) = fail then
    Print( "#I ", pkgname, " package cannot be loaded\n" );
    return fail;
elif not IsBound( GAPInfo.PackagesInfo.(pkgname)[1].TestFile ) then
    Print("#I No standard tests specified in ", pkgname, " package, version ",
          GAPInfo.PackagesInfo.(pkgname)[1].Version,  "\n");
    # Since a TestFile is not required, technically we passed "all" tests
    return true;
else
    testfile := Filename( DirectoriesPackageLibrary( pkgname, "" ),
                          GAPInfo.PackagesInfo.(pkgname)[1].TestFile );
    str:= StringFile( testfile );
    if not IsString( str ) then
        Print( "#I Test file `", testfile, "' for package `", pkgname,
        " version ", GAPInfo.PackagesInfo.(pkgname)[1].Version, " is not readable\n" );
        return fail;
    fi;
    if EndsWith(testfile,".tst") then
        if Test( testfile, rec(compareFunction := "uptowhitespace") ) then
            Print( "#I  No errors detected while testing package ", pkgname,
                   " version ", GAPInfo.PackagesInfo.(pkgname)[1].Version,
                   "\n#I  using the test file `", testfile, "'\n");
            return true;
        else
            Print( "#I  Errors detected while testing package ", pkgname,
                   " version ", GAPInfo.PackagesInfo.(pkgname)[1].Version,
                   "\n#I  using the test file `", testfile, "'\n");
            return false;
        fi;
    elif not READ( testfile ) then
        Print( "#I Test file `", testfile, "' for package `", pkgname,
        " version ", GAPInfo.PackagesInfo.(pkgname)[1].Version, " is not readable\n" );
        return fail;
    else
        # At this point, the READ succeeded, but we have no idea what the
        # outcome of that test was. Hopefully, that file printed a message of
        # its own and then terminated GAP with a suitable error code (e.g. by
        # using TestDirectory with exitGAP:=true); in that case we never get
        # here and all is fine.
        return fail;
    fi;
fi;
end);
