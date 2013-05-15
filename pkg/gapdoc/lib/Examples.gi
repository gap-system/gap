#############################################################################
##
#W  Examples.gi                  GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2007,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files Examples.g{d,i} contain functions for extracting and checking
##  GAP examples in GAPDoc manuals.
##  


##  <#GAPDoc Label="ExtractExamples">
##  <ManSection >
##  <Func Arg="path, main, files, units" Name="ExtractExamples" />
##  <Returns>a list of lists</Returns>
##  <Func Arg="tree, units" Name="ExtractExamplesXMLTree" />
##  <Returns>a list of lists</Returns>
##  <Description>
##  The  argument   <A>tree</A>  must   be  a   parse tree of a
##  &GAPDoc; document, see <Ref Func="ParseTreeXMLFile"/>. 
##  The function <Ref Func="ExtractExamplesXMLTree"/> returns a data
##  structure representing the <C>&lt;Example></C> elements of the document. 
##  The return value can be used with <Ref Func="RunExamples"/> to check and
##  optionally update the examples of the document.<P/> 
##  Depending 
##  on the argument <A>units</A> several examples are collected in one list.
##  Recognized values for <A>units</A> are <C>"Chapter"</C>, <C>"Section"</C>,
##  <C>"Subsection"</C> or <C>"Single"</C>. The latter means that each example
##  is in a separate list. For all other value of <A>units</A> just one list
##  with all examples is returned.<P/>
##  
##  The arguments <A>path</A>, <A>main</A> and <A>files</A> of <Ref
##  Func="ExtractExamples"/> are the same as for <Ref Func="ComposedDocument"/>.
##  This function first contructs and parses the &GAPDoc; document and then
##  applies <Ref Func="ExtractExamplesXMLTree"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

# obsolete
# Extract examples units-wise from a GAPDoc document as XML tree, 
# 'units' can either be: "Chapter" or "Section" or "Subsection" or "Single"
#     then a list of strings is returned
# For all other values of 'units' one string with all examples is returned.
# Before each extracted example there is its paragraph number in a comment:
#  [ chapter, section, subsection, paragraph ]
InstallGlobalFunction(ManualExamplesXMLTree, function( tree, units )
  local secelts, sec, exelts, res, str, a, ex;
  if units = "Chapter" then
    secelts := ["Chapter", "Appendix"];
  elif units = "Section" then
    secelts := ["Section"];
  elif units = "Subsection" then
    secelts := ["Subsection", "ManSection"];
  elif units = "Single" then
    secelts := ["Example"];
  else
    secelts := 0;
  fi;
  if secelts <> 0 then
    sec := XMLElements(tree, secelts);
  else
    sec := [tree];
  fi;
  # want to put section numbers in comments
  AddParagraphNumbersGapDocTree(tree);
  exelts := List(sec, a-> XMLElements(a, ["Example"]));
  res := [];
  for a in exelts do
    str := "";
    for ex in a do
      Append(str, "# from paragraph ");
      if IsBound(ex.count) then
        Append(str, String(ex.count));
      else
        Append(str, "in Ignore?");
      fi;
      if IsBound(tree.inputorigins) then
        Append(str, String(OriginalPositionDocument(
                                           tree.inputorigins, ex.start)));
      fi;
      Append(str, "\n");
      Append(str, GetTextXMLTree(ex));
      Append(str, "\n");
    od;
    Add(res, str);
  od;
  if secelts = 0 then
    res := res[1];
  fi;
  return res;
end);

InstallGlobalFunction(ExtractExamplesXMLTree, function( tree, units )
  local secelts, sec, exelts, orig, res, l, b, e, a, ex;
  if units = "Chapter" then
    secelts := ["Chapter", "Appendix"];
  elif units = "Section" then
    secelts := ["Section"];
  elif units = "Subsection" then
    secelts := ["Subsection", "ManSection"];
  elif units = "Single" then
    secelts := ["Example"];
  else
    secelts := 0;
  fi;
  if secelts <> 0 then
    sec := XMLElements(tree, secelts);
  else
    sec := [tree];
  fi;
  exelts := List(sec, a-> XMLElements(a, ["Example"]));
  if IsBound(tree.inputorigins) then
    orig := tree.inputorigins;
  elif IsBound(tree.root) and IsBound(tree.root.inputorigins) then
    orig := tree.inputorigins;
  else
    orig := fail;
  fi;
  res := [];
  for a in exelts do
    l := [];
    for ex in a do
      if orig <> fail then
        b := OriginalPositionDocument(orig, ex.start);
        e := OriginalPositionDocument(orig, ex.stop);
        Add(b, e[2]);
      else
        b := [ex.start, ex.stop];
      fi;
      Add(l, [GetTextXMLTree(ex), b]);
    od;
    Add(res, l);
  od;
  return res;
end);

# obsolete
# compose and parse document, then extract examples units-wise
InstallGlobalFunction(ManualExamples, function( path, main, files, units )
  local str, xmltree;
  str:= ComposedDocument( "GAPDoc", path, main, files, true );
  xmltree:= ParseTreeXMLString( str[1], str[2] );
  return ManualExamplesXMLTree(xmltree, units);
end);

# compose and parse document, then extract examples units-wise
InstallGlobalFunction(ExtractExamples, function( path, main, files, units )
  local str, xmltree;
  str:= ComposedDocument( "GAPDoc", path, main, files, true );
  xmltree:= ParseTreeXMLString( str[1], str[2] );
  return ExtractExamplesXMLTree(xmltree, units);
end);

##  <#GAPDoc Label="TestExamples">
##  <ManSection >
##  <Func Arg="str" Name="ReadTestExamplesString" />
##  <Returns><K>true</K> or <K>false</K></Returns>
##  <Func Arg="str[, print]" Name="TestExamplesString" />
##  <Returns><K>true</K> or a list of records</Returns>
##  <Func Arg="[tree][,][path, main, files]" Name="TestManualExamples" />
##  <Returns><K>true</K> or a list of records</Returns>
##  <Description>
##  The argument <A>str</A> must be a string containing lines for the test mode
##  of &GAP;. The function <Ref Func="ReadTestExamplesString"/> just runs 
##  <Ref BookName="Reference" Oper="ReadTest"/> on this code. <P/>
##  
##  The function <Ref Func="TestExamplesString"/> returns <K>true</K> if <Ref
##  BookName="Reference" Oper="ReadTest"/> does not find differences. In the
##  other case it returns a list of records, where each record describes one
##  difference. The records have fields <C>.line</C> with the line number of the
##  relevant input line of <A>str</A>, <C>.input</C> with the input line and
##  <C>.diff</C> with the differences as displayed by <Ref BookName="Reference"
##  Oper="ReadTest"/>. If the optional argument <A>print</A> is given and set 
##  to <K>true</K> then the differences are also printed before the function
##  returns.<P/>
##  
##  The arguments of the function <Ref Func="TestManualExamples"/> is either
##  a parse tree of a &GAPDoc; document or the information to build and parse
##  such a document. The function extracts all examples in <C>"Single"</C>
##  units and applies <Ref Func="TestExamplesString"/> to them.<P/>
##  
##  <Example>
##  gap> TestExamplesString("gap> 1+1;\n2\n");
##  true
##  gap> TestExamplesString("gap> 1+1;\n2\ngap> 2+3;\n4\n");
##  [ rec( diff := "+ 5\n- 4\n", input := "gap> 2+3;", line := 3 ) ]
##  gap> TestExamplesString("gap> 1+1;\n2\ngap> 2+3;\n4\n", true);
##  -----------  bad example --------
##  line: 3
##  input: gap> 2+3;
##  differences:
##  + 5
##  - 4
##  [ rec( diff := "+ 5\n- 4\n", input := "gap> 2+3;", line := 3 ) ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

# obsolete
# test a string with examples 
InstallGlobalFunction(ReadTestExamplesString, function(str)
  local res, file;
  file := InputTextString(str);
  res := ReadTest(file);
  CloseStream(file);
  return res;
end);

# obsolete
# args:  str, print
InstallGlobalFunction(TestExamplesString, function(arg)
  local l, s, z, inp, out, f, lout, pos, bad, i, n, diffs, str;
  str := arg[1];
  l := SplitString(str, "\n", "");
  s := "";
  for i in [1..Length(l)] do
    z := l[i];
    if Length(z) > 4 and z{[1..5]} = "gap> " or
       Length(z) > 1 and z{[1,2]} = "> " then
      Append(s, " #IPL");
      Append(s, String(i));
      Append(s, "--->");
      Append(s, z);
      Add(s, '\n');
    fi;
    Append(s, z);
    Add(s, '\n');
  od;
  inp := InputTextString(s);
  out := "";
  f := OutputTextString(out, false);
  PrintTo1(f, function()
##      READ_TEST_STREAM(inp);
    ReadTest(inp);
  end);
  if not IsClosedStream(inp) then
    CloseStream(inp);
  fi;
  if not IsClosedStream(f) then
    CloseStream(f);
  fi;
  lout := SplitString(out, "\n", "");
  pos := First([1..Length(lout)], i-> Length(lout[i]) > 0 and lout[i][1] = '+');
  if pos = fail then
    return true;
  fi;
  bad := [];
  while pos <> fail do
    i := pos-1;
    while Length(lout[i]) < 7 or lout[i]{[1..7]} <> "-  #IPL" do
      i := i-1;
    od;
    n := lout[i]{[8..Length(lout[i])]};
    n := Int(n{[1..Position(n, '-')-1]});
    diffs := "";
    while IsBound(lout[pos]) and 
           (Length(lout[pos]) < 7 or lout[pos]{[1..7]} <> "-  #IPL") do
      Append(diffs, lout[pos]);
      Add(diffs, '\n');
      pos := pos+1;
    od;
    Add(bad, rec(line := n, input := l[n], diff := diffs));
    pos := First([pos..Length(lout)], i-> Length(lout[i]) > 0 and
                  lout[i][1] = '+');
  od;
  if Length(arg) > 1 and arg[2] = true then
    for z in bad do
      Print("-----------  bad example --------\n",
            "line: ", z.line, "\ninput: ");
      PrintFormattedString(z.input);
      Print("\n");
      Print("differences:\n");
      PrintFormattedString(z.diff);
    od;
  fi;
  return bad;
end);

# obsolete
InstallGlobalFunction(TestManualExamples, function(arg)
  local ex, bad, res, a;
  if IsRecord(arg[1]) then
    ex := ManualExamplesXMLTree(arg[1], "Single");
  else
    ex := ManualExamples(arg[1], arg[2], arg[3], "Single");
  fi;
  bad := Filtered(ex, a-> TestExamplesString(a) <> true);
  res := [];
  for a in bad do 
    Print("===========================\n");
    PrintFormattedString(a); 
    Add(res, TestExamplesString(a, true));
  od; 
  return res;
end);


##  <#GAPDoc Label="RunExamples">
##  <ManSection >
##  <Func Arg="exmpls[, optrec]" Name="RunExamples" />
##  <Returns>nothing</Returns>
##  <Description>
##  The argument <A>exmpls</A> must be the output of a call to 
##  <Ref Func="ExtractExamples"/> or <Ref Func="ExtractExamplesXMLTree"/>.
##  The optional argument <A>optrec</A> must be a record, its components
##  can change the default behaviour of this function.
##  <P/>
##  By default this function runs the &GAP; input of all examples and compares
##  the actual output with the output given in the examples. If differences
##  occur these are displayed together with information on the location of the 
##  source code of that example. Before running the examples in each unit (entry
##  of <A>exmpls</A>) the function <Ref BookName="Reference" Func="START_TEST"/>
##  is called and the screen width is set to 72 characters.
##  <P/>
##  If the argument <A>optrec</A> is given, the following components are
##  recognized:
##  <List>
##  <Mark><C>showDiffs</C></Mark>
##  <Item>
##  The default value is <K>true</K>, if set to something else found differences
##  in the examples are not displayed. 
##  </Item>
##  <Mark><C>width</C></Mark>
##  <Item>
##  The value must be a positive integer which is used as screen width when
##  running the examples. As mentioned above, the default is 72 which is a
##  sensible value for the text version of the &GAPDoc; document used
##  in a 80 character wide terminal.
##  </Item>
##  <Mark><C>changeSources</C></Mark>
##  <Item>
##  If this is set to <K>true</K> then the source code of all manual
##  examples which show differences is adjusted to the current outputs.
##  The default is <K>false</K>.<Br/>
##  Use this feature with care.
##  Note that sometimes differences can indicate a bug, and in such a case
##  it is more appropriate to fix the bug instead of changing the example
##  output. 
##  </Item>
##  <Mark><C>compareFunction</C></Mark>
##  <Item>
##  The function used to compare the output shown in the example and the
##  current output. See <Ref BookName="Reference" Func="Test"/> for more
##  details.
##  </Item>
##  <Mark><C>checkWidth</C></Mark>
##  <Item>
##  If this option is a positive integer <C>n</C> the function prints warnings
##  if an example contains any line with more than <C>n</C> characters (input
##  and output lines are considered). By default this option is set to
##  <K>false</K>.
##  </Item>
##  </List>
##  
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

InstallGlobalFunction(RunExamples, function(arg)
  local exlists, opts, oldscr, l, sp, bad, s, test, pex, new, inp, ch, 
        fnams, str, fch, pos, pre, a, j, ex, i, attedStrin, f;
  exlists := arg[1];
  opts := rec(
          showDiffs := true,
          changeSources := false,
          width := 72,
          compareFunction := EQ,
          checkWidth := false,
  );                 
  if Length(arg) > 1 and IsRecord(arg[2]) then
    for a in RecFields(arg[2]) do
      opts.(a) := arg[2].(a);
    od;
  fi;
  if IsString(opts.compareFunction) then
    if IsBound(TEST.compareFunctions.(opts.compareFunction)) then
      opts.compareFunction := TEST.compareFunctions.(opts.compareFunction);
    else
      opts.compareFunction := EQ;
    fi;
  fi;
  oldscr := SizeScreen();
  SizeScreen([opts.width, oldscr[2]]);
  for j in [1..Length(exlists)] do
    l := exlists[j];
    Print("# Running list ",j," . . .\n");
    START_TEST("");
    for ex in l do
      if IsInt(opts.checkWidth) then
        sp := SplitString(ex[1], "\n", "");
        bad := Filtered([1..Length(sp)], i-> Length(sp[i]) > opts.checkWidth);
        if Length(bad) > 0 then
          Print("# WARNING: Overlong lines ", bad, 
                " in ", ex[2]{[1..3]}, "\n");
        fi;
      fi;
      s := InputTextString(ex[1]);
      test := Test(s, rec(ignoreComments := false,
                   width := opts.width,
                   compareFunction := opts.compareFunction,
                   reportDiff := Ignore
                                 ) );
      CloseStream(s);
      pex := TEST.lastTestData;
      if test = false then
        for i in [1..Length(pex[1])] do
          if opts.compareFunction(pex[2][i], pex[4][i]) <> true then
            if opts.showDiffs = true then
              Print("########> Diff in ", ex[2]{[1..3]}, "\n# Input is:\n");
              PrintFormattedString(pex[1][i]);
              Print("# Expected output:\n");
              PrintFormattedString(pex[2][i]);
              Print("# But found:\n");
              PrintFormattedString(pex[4][i]);
              Print("########\n");
            fi;
          fi;
        od;
      fi;
      if test = false then
        new := "";
        for i in [1..Length(pex[1])] do
          inp := Concatenation("gap> ", JoinStringsWithSeparator(
                    SplitString(pex[1][i], "\n", ""), "\n> "), "\n");
          Append(new, inp);
          Append(new, pex[4][i]);
        od;
        ex[2][4] := new;
      fi;
    od;
  od;
  if opts.changeSources = true then
    ch := [];
    for l in exlists do
      for ex in l do
        if IsString(ex[2][1]) and Length(ex[2]) > 3 then
          Add(ch, ex[2]);
        fi;
      od;
    od;
    if Length(ch) > 0 then
      Print("# Diffs found, changing source files ...\n");
      fnams := Set(List(ch, a-> a[1]));
      for f in fnams do
        Print("# Changing ",f,"\n");
        str := StringFile(f);
        if str = fail then
          Print("# WARNING: Cannot read file ",f,", skipping\n");
        else
          str := SplitString(str, "\n", "");
          for a in str do
            Add(a, '\n');
          od;
          fch := Filtered(ch, a-> a[1] = f);
          for ex in fch do
            # change first line to everything new and empty the remaining ones
            pos := PositionSublist(str[ex[2]], "<Example");
            pre := str[ex[2]]{[1..pos-1]};
            l := SplitString(ex[4], "\n", "");
            new := "";
            for a in l do
              Append(new, pre);
              Append(new, a);
              Add(new, '\n');
            od;
            # maybe escape & and <
            if PositionSublist(str[ex[2]], "<![CDATA[") = fail then
              new := SubstitutionSublist(new, "&", "&amp;");
              new := SubstitutionSublist(new, "<", "&lt;");
            fi;
            str[ex[2]+1] := new;
            for i in [ex[2]+2..ex[3]-1] do
              str[i] := "";
            od;
            Print("        changed lines ", ex[2]+1, "..", ex[3]-1, "\n");
          od;
          str := Concatenation(str);
          FileString(f, str);
        fi;
      od;
    fi;
  fi;
  SizeScreen(oldscr);
end);

