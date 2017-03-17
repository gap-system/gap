#############################################################################
##
#W  PrintUtil.gi                 GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##  
##  The  files PrintUtil.gd and  PrintUtil.gi contain utilities  for printing
##  objects or large amounts of data.
##  

##  a hack: type for objects which only exist to print something
InstallValue(DUMMYTBPTYPE, NewType(NewFamily(""), IsObjToBePrinted));


InstallMethod(PrintObj, "IsObjToBePrinted", true, [IsObjToBePrinted], 0, 
        function(obj) obj!.f(); 
end); 

##  <#GAPDoc Label="PrintTo1">
##  <ManSection >
##  <Func Arg="filename, fun" Name="PrintTo1" />
##  <Func Arg="filename, fun" Name="AppendTo1" />
##  <Description>
##  The  argument  <A>fun</A>  must  be a  function  without  arguments.
##  Everything which is  printed by a call <A>fun()</A>  is printed into
##  the file <A>filename</A>. As with <Ref BookName="ref" Func="PrintTo"
##  />  and <Ref  BookName="ref" Func="AppendTo"  /> this  overwrites or
##  appends  to, respectively,  a previous  content of  <A>filename</A>.
##  <P/>
##  
##  These functions can be particularly efficient when many small pieces
##  of text shall be written to a file, because no multiple reopening of
##  the file is necessary.
##  
##  <Example>
##  gap> f := function() local i; 
##  >   for i in [1..100000] do Print(i, "\n"); od; end;; 
##  gap> PrintTo1("nonsense", f); # now check the local file `nonsense'
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(PrintTo1, function(file, fun)
  local   obj;
  obj := rec(f := fun);
  Objectify(DUMMYTBPTYPE, obj);
  PrintTo(file, obj);
end);

InstallGlobalFunction(AppendTo1, function(file, fun)
  local   obj;
  obj := rec(f := fun);
  Objectify(DUMMYTBPTYPE, obj);
  AppendTo(file, obj);
end);

##  <#GAPDoc Label="StringPrint">
##  <ManSection >
##  <Func Arg="obj1[, obj2[, ...]]" Name="StringPrint" />
##  <Func Arg="obj" Name="StringView" />
##  <Description>
##  These  functions  return a  string  containing  the output  of  a
##  <C>Print</C> or <C>ViewObj</C> call with the same arguments.<P/>
##  
##  This should  be considered  as a (temporary?)  hack. It  would be
##  better to  have <Ref  BookName="ref" Oper="String"/>  methods for
##  all  &GAP; objects  and  to have  a  generic <Ref  BookName="ref"
##  Func="Print"/>-function which just interprets these strings.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(StringPrint, function(obj)
  local   str,  out;
  str := "";
  out := OutputTextString(str, false);
  PrintTo1(out, function() Print(obj); end);
  CloseStream(out);
  return str;
end);

InstallGlobalFunction(StringView, function(obj)
  local   str,  out;
  str := "";
  out := OutputTextString(str, false);
  PrintTo1(out, function() View(obj); end);
  CloseStream(out);
  return str;
end);


##  <#GAPDoc Label="PrintFormattedString">
##  <ManSection >
##  <Func Arg="str" Name="PrintFormattedString" />
##  <Description>
##  This  function  prints a  string  <A>str</A>.  The difference  to
##  <C>Print(str);</C>  is   that  no  additional  line   breaks  are
##  introduced  by  &GAP;'s  standard printing  mechanism.  This  can
##  be  used  to  print  lines  which are  longer  than  the  current
##  screen width.  In particular  one can  print text  which contains
##  escape sequences  like those explained in  <Ref Var="TextAttr"/>,
##  where  lines   may  have   more  characters   than  <Emph>visible
##  characters</Emph>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(PrintFormattedString, function(str)
  local   n,  l,  i;
  Print("\c");
  n := QuoInt(SizeScreen()[1], 2)+1;
  l := Length(str);
  i := 0;
  while i+n<=l do
    Print(str{[i+1..i+n]}, "\c");
    i := i+n;
  od;
  if i<l then
    Print(str{[i+1..l]}, "\c");
  fi;
end);

  
##  <#GAPDoc Label="Page">
##  <ManSection >
##  <Func Arg="..." Name="Page" />
##  <Func Arg="obj" Name="PageDisplay" />
##  <Description>
##  These functions  are similar to <Ref  BookName="ref" Func="Print"
##  /> and  <Ref BookName="ref" Func="Display" />,  respectively. The
##  difference is that the output is not sent directly to the screen,
##  but  is piped  into the  current pager;  see <Ref  BookName="ref"
##  Func="Pager" />.
## 
##  <!-- cannot be run in automatic test -->
##  <Log>
##  gap> Page([1..1421]+0);
##  gap> PageDisplay(CharacterTable("Symmetric", 14));
##  </Log>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(Page, function(arg)
  local   str,  out;
  str := "";
  out := OutputTextString(str, true);
  CallFuncList(PrintTo, Concatenation([out],arg));
  CloseStream(out);
  Pager(rec(lines := str, formatted:=true));
end);

InstallGlobalFunction(PageDisplay, function(x)
  local   str,  out;
  # since output to proper string is terribly slow
  str := [,1];
  out := OutputTextString(str, true);
  PrintTo1(out, function() Display(x);end);
  CloseStream(out);
  str := str{[3..Length(str)]};
  CONV_STRING(str);
  Pager(rec(lines := str, formatted:=true));
end);


##  <#GAPDoc Label="StringFile">
##  <ManSection >
##  <Func Arg="filename" Name="StringFile" />
##  <Func Arg="filename, str[, append]" Name="FileString" />
##  <Description>
##  The  function <Ref  Func="StringFile" />  returns the  content of
##  file  <A>filename</A> as  a string.  This works  efficiently with
##  arbitrary (binary or text) files. If something went wrong,   this 
##  function returns <K>fail</K>.
##  <P/>
##  
##  Conversely  the function  <Ref  Func="FileString"  /> writes  the
##  content of a string <A>str</A>  into the file <A>filename</A>. If
##  the  optional third  argument <A>append</A>  is given  and equals
##  <K>true</K> then  the content  of <A>str</A>  is appended  to the
##  file. Otherwise  previous  content  of  the file is deleted. This 
##  function returns the number of  bytes  written  or <K>fail</K> if 
##  something went wrong.<P/>
##  
##  Both functions are quite efficient, even with large files. 
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
##  moved into lib/string.g{d,i}

# GAP3 tyœe dispatcher for viewing and printing records
InstallMethod(ViewObj, [IsRecord], function(r)
  if IsBound(r.operations) and IsBound(r.operations.ViewObj) then
    r.operations.ViewObj(r);
  else
    TryNextMethod();
  fi;
end);

InstallMethod(PrintObj, [IsRecord], function(r)
  if IsBound(r.operations) and IsBound(r.operations.PrintObj) then
    r.operations.PrintObj(r);
  else
    TryNextMethod();
  fi;
end);
##  # example:
##  r := rec( a := 1, b := 2, operations := rec(
##           ViewObj := function(r) Print("view rec"); end,
##           PrintObj := function(r) Print("print rec"); end)  );
##  View(r,  rec( c := 3 )); Print("\n");
##  Print(r, "\n", rec( c := 3 ), "\n");

