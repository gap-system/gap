##                                                            Frank Lübeck
##  Validating the manual and checking for text between
##  chapters/sections/subsections.
##
LoadPackage( "GAPDoc" );

LoadPackage( "ctbllib" );

Read( "makedocreldata.g" );

if not IsBound( GAPInfo.ManualDataRef ) then
  Error( "read the data from makedocrel.g first" );
fi;

pathtodoc:= GAPInfo.ManualDataRef.pathtodoc;;
main:= GAPInfo.ManualDataRef.main;;
bookname:= GAPInfo.ManualDataRef.bookname;;
pathtoroot:= GAPInfo.ManualDataRef.pathtoroot;;
files:= GAPInfo.ManualDataRef.files;;

#  MakeGAPDocDoc( pathtodoc, main, files, bookname, pathtoroot );;
Print("Collecting document for ref manual . . .\n");
doc := ComposedDocument( "GAPDoc", pathtodoc, main, files, true );

gapdocdtd := Filename(DirectoriesPackageLibrary("gapdoc"), "../gapdoc.dtd");

Print("Loading gaprxp . . .");
if LoadPackage("gaprxp") = true then
  Print(" ok\nParsing with rxp (with validation) . . .\n");
  resrxp := XMLParseWithRxp(doc[1], [ "-V", "-D", "Book", 
                                  gapdocdtd]);    
  Print("ERRORS:\n");
  for a in resrxp.err do
    Print(a,"\n");
  od;
  Print("Creating parse tree . . .\n");
  tree := XMLMakeTree(resrxp.out);
else
  Print(" not found!\nParsing with GAPDoc parser (without validation) . . .");
  tree := ParseTreeXMLString( doc[1], doc[2] );
  Print("Calling CheckAndCleanGapDocTree . . .\n");
  CheckAndCleanGapDocTree( tree );
fi;

AddParagraphNumbersGapDocTree(tree);

# Utility, substitutes content of chapters, section, subsections respectively
# by strings like ___Chapter[4,0,0,0].
FoldSectioning := function(tree, sectype)
  local fun, elnams;
  if sectype = "Chapter" then
    elnams := ["Chapter","TitlePage","Appendix","Bibliography"];
  elif sectype = "Section" then
    elnams := ["Section"];
  elif sectype = "Subsection" then
    elnams := ["Subsection", "ManSection"];
  else
    elnams := [sectype];
  fi;
  fun := function(r)
    if r.name in ["XMLPI", "XMLDOCTYPE", "XMLCOMMENT", "COMMENT"] then
      if not IsBound(r.origcontent) then
        r.origcontent := r.content;
      fi;
      r.content := "";
    elif r.name in elnams then
      if not IsBound(r.origcontent) then
        r.origcontent := r.content;
      fi;
      r.content := Concatenation("___", r.name, 
                     SubstitutionSublist(String(r.count), " ",""), "\n");
    fi;
  end;
  ApplyToNodesParseTree(tree, fun);
end;

# remove the folding
MoveBackOrigContent := function(tree)
  ApplyToNodesParseTree(tree, function(r) if IsBound(r.origcontent) then
    r.content := r.origcontent; Unbind(r.origcontent); fi;end);
end;

# Show the structure of a folded (sub)tree. Text between sections is
# truncated after 3/4 of a line. Warnings are printed if there is text
# between sections. (Text before any section is fine.)
StringStructure := function(tree)
  local str, sp, new, pos, r, i, iss;
  str := GetTextXMLTree(tree);
  NormalizeWhitespace(str);
  str := SubstitutionSublist(str, " ___", "\n___");
  sp := SplitString(str,"","\n");
  new := [];
  for r in sp do
    if Length(r) > 2 and r{[1..3]} = "___" then
      pos := Position(r,']');
      if pos = Length(r) then
        Add(new, r);
      else
        Add(new, r{[1..pos]});
        Add(new, r{[pos+1 .. Minimum(pos+60, Length(r))]});
      fi;
    else
      Add(new, r{[1..Minimum(60, Length(r))]});
    fi;
  od;
  # print warnings
  iss := new[1]{[1..Minimum(Length(new[1]),3)]} = "___";
  for i in [2..Length(new)]  do
    if new[i]{[1..Minimum(Length(new[i]),3)]} = "___" then
      iss := true;
    else
      if iss then 
        Print("Warning: text after ",new[i-1],"\n",new[i]," . . .\n");
      fi;
      iss := false;
    fi;
  od;

  return JoinStringsWithSeparator(new, "\n");
end;


# And an example how to use above utilities:
SectionStructuresWithWarnings := function(tree)
  local chstr, chaps, chapstr, secs, secstr, ch, s;
  MoveBackOrigContent(tree);
  Print("######  Checking chapter structure . . .\n");
  FoldSectioning(tree, "Chapter");
  chstr := StringStructure(tree);
  MoveBackOrigContent(tree);
  Print("######  Checking section structures of chapters . . .\n");
  chaps := XMLElements(tree,["Chapter","Appendix"]);
  chapstr := [];
  for ch in chaps do 
    Print("Chapter ", ch.count, "\n");
    FoldSectioning(ch,"Section");
    Add(chapstr, StringStructure(ch));
  od;
  MoveBackOrigContent(tree);
  Print("######  Checking subsection structures of sections . . .\n");
  secs := XMLElements(tree,["Section"]);
  secstr := [];
  for s in secs do 
    #Print("Section ", s.count, "\n");
    FoldSectioning(s,"Subsection");
    Add(secstr, StringStructure(s));
  od;
  MoveBackOrigContent(tree);
  return [chstr, chapstr, secstr];
end;

# a variant of 'WordsString'
Words := function(str)
  local res;
  res := SplitString(str, "", " \n\t\r\240\302\"\\:;,.'/?[]{}\|=+-_()<>*&^%$#@!~`");
  return res;
end;

# a fragment of what one could do with a word list, would like to find
# a list of words for the spell checker
CheckWords := function(wlist)
  local bnd, fu, gapv;
  # numbers
  wlist := Filtered(wlist, a-> not ForAll(a, IsDigitChar));
  # documented GAP variables
  wlist := Filtered(wlist, a-> not IsDocumentedWord(a));
  # further bound GAP variables
  bnd := Filtered(wlist, a-> IsBoundGlobal(a));
  wlist := Filtered(wlist, a-> not IsBoundGlobal(a));
  # further words which may refer to GAP variables
  fu := function(s)
    s := Filtered(s, x-> IsDigitChar(x) or IsUpperAlphaChar(x));
    return Length(s) > 1;
  end;
  gapv := Filtered(wlist, fu);
  wlist := Filtered(wlist, a-> not fu(a));
  return [wlist, gapv, bnd];
end;

# a general utility, could maybe made more general to cover FoldSectioning
# as well
HideElementsXMLTree := function(tree, elts)
  local fu;
  if IsString(elts) then
    elts := [elts];
  fi;
  fu := function(r)
    if r.name in elts then
      if not IsBound(r.origcontent) then
        r.origcontent := r.content;
      fi;
      r.content := "";
    fi;
  end;
  ApplyToNodesParseTree(tree, fu);
end;

# remove the folding or hiding
MoveBackOrigContent := function(tree)
  ApplyToNodesParseTree(tree, function(r) if IsBound(r.origcontent) then
    r.content := r.origcontent; Unbind(r.origcontent); fi;end);
end;

# as the name says
SomeTests := function(tree)
  local txt, wds, chk;
  # after hiding these there shouldn't be any GAP variable names any more
  HideElementsXMLTree(tree, ["C","M","Math","Display","A","Arg", "Example",
      "XMLPI", "XMLDOCTYPE", "XMLCOMMENT", "COMMENT"]);
  txt := GetTextXMLTree(tree);
  txt := SubstitutionSublist(txt, "\342\200\223", "-");
  wds := Set(Words(txt));
  chk := CheckWords(wds);
  return chk;
end;

# f is called before recursion, g afterwards
# Will generalize ApplyToNodesParseTree to a 3-arg version . . .
ApplyToNodes2 := function ( r, f, g )
    local  ff;
    ff := function ( rr )
          local  a;
          if IsList( rr.content ) and not IsString( rr.content )  then
              for a  in rr.content  do
                  f( a );
                  ff( a );
                  g( a );
              od;
          fi;
          return;
      end;
    f( r );
    ff( r );
    g( r );
    return;
end;

# This finds <A> elements in outside ManSections (should not happen) and
# strings in <A> elements which are not given in Arg attributes of the
# current ManSection. 
CheckAContent := function(tree)
  local c1, c2, fu, g;

  c1 := 0;
  c2 := 0;
  fu := function(r)
    local w;
    if r.name = "ManSection" then
      GAPInfo.ARGLIST := [];
    elif r.name in ["Func","Oper","Meth","Filt","Prop",
                                  "Attr","Var","Fam","InfoClass"] then
      if IsBound(r.attributes.Arg) then
        Append(GAPInfo.ARGLIST, WordsString(r.attributes.Arg));
      fi;
    elif r.name in ["A", "Arg"] then
      if not IsBound(GAPInfo.ARGLIST) then
        Print("<A> outside ManSection: ", GetTextXMLTree(r),"\n");
        c1 := c1+1;
      else
        w := WordsString(GetTextXMLTree(r));
        w := Filtered(w, a-> not a in GAPInfo.ARGLIST);
        if Length(w) > 0 then
          Print("Wrong <A>: ",w,"/",GAPInfo.ARGLIST,"\n");
          c2 := c2+1;
        fi;
      fi;
    fi;
  end;
  g := function(r)
    if r.name = "ManSection" then
      Unbind(GAPInfo.ARGLIST);
    fi;
  end;
  ApplyToNodes2(tree, fu, g);
  Print(c1," outside ManSection, ",c2," wrong usages.\n");
end;

# one call that shows text between subsections
strs := SectionStructuresWithWarnings(tree);

