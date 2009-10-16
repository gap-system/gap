#############################################################################
##
#W  Examples.gi                  GAPDoc                          Frank Lübeck
##
#H  @(#)$Id: Examples.gi,v 1.5 2008/06/17 15:47:23 gap Exp $
##
#Y  Copyright (C)  2007,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The files Examples.g{d,i} contain functions for extracting and checking
##  GAP examples in GAPDoc manuals.
##  


##  <#GAPDoc Label="ManualExamples">
##  <ManSection >
##  <Func Arg="path, main, files, units" Name="ManualExamples" />
##  <Returns>a list of strings</Returns>
##  <Func Arg="tree, units" Name="ManualExamplesXMLTree" />
##  <Returns>a list of strings</Returns>
##  <Description>
##  The  argument   <A>tree</A>  must   be  a   parse tree of a
##  &GAPDoc; document, see <Ref Func="ParseTreeXMLFile"/>. 
##  The function <Ref Func="ManualExamplesXMLTree"/> returns a list of strings
##  containing the content of <C>&lt;Example></C> elements. For each example
##  there is a comment line showing the paragraph number and (if available) the
##  original location  of this example with file and line number. Depending 
##  on the argument <A>units</A> several examples are colleected in one string.
##  Recognized values for <A>units</A> are <C>"Chapter"</C>, <C>"Section"</C>,
##  <C>"Subsection"</C> or <C>"Single"</C>. The latter means that each example
##  is in a separate string. For all other value of <A>units</A> just one string
##  with all examples is returned.<P/>
##  
##  The arguments <A>path</A>, <A>main</A> and <A>files</A> of <Ref
##  Func="ManualExamples"/> are the same as for <Ref Func="ComposedDocument"/>.
##  This function first contructs and parses the &GAPDoc; document and then
##  applies <Ref Func="ManualExamplesXMLTree"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
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

# compose and parse document, then extract examples units-wise
InstallGlobalFunction(ManualExamples, function( path, main, files, units )
  local str, xmltree;
  str:= ComposedDocument( "GAPDoc", path, main, files, true );
  xmltree:= ParseTreeXMLString( str[1], str[2] );
  return ManualExamplesXMLTree(xmltree, units);
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
##  [ rec( line := 3, input := "gap> 2+3;", diff := "+ 5\n- 4\n" ) ]
##  gap> TestExamplesString("gap> 1+1;\n2\ngap> 2+3;\n4\n", true);
##  -----------  bad example --------
##  line: 3
##  input: gap> 2+3;
##  differences:
##  + 5
##  - 4
##  [ rec( line := 3, input := "gap> 2+3;", diff := "+ 5\n- 4\n" ) ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>

# test a string with examples 
InstallGlobalFunction(ReadTestExamplesString, function(str)
  local res, file;
  file := InputTextString(str);
  res := ReadTest(file);
  CloseStream(file);
  return res;
end);

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
    READ_TEST_STREAM(inp);
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

