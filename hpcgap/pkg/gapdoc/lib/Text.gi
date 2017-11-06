#############################################################################
##
#W  Text.gi                      GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  The files Text.g{d,i}  contain some utilities for  dealing with text
##  strings.
##  

##  
##  <#GAPDoc Label="CharsColls">
##  <ManSection>
##  <Var Name="WHITESPACE" />
##  <Var Name="CAPITALLETTERS" />
##  <Var Name="SMALLLETTERS" />
##  <Var Name="LETTERS" />
##  <Var Name="DIGITS" />
##  <Var Name="HEXDIGITS" />
##  <Var Name="BOXCHARS" />
##  <Description>
##  These variables contain sets of characters which are useful for
##  text processing. They are defined as follows.<P/>
##  <List >
##  <Mark><C>WHITESPACE</C></Mark>
##  <Item><C>" \n\t\r"</C></Item>
##  <Mark><C>CAPITALLETTERS</C></Mark>
##  <Item><C>"ABCDEFGHIJKLMNOPQRSTUVWXYZ"</C></Item>
##  <Mark><C>SMALLLETTERS</C></Mark>
##  <Item><C>"abcdefghijklmnopqrstuvwxyz"</C></Item>
##  <Mark><C>LETTERS</C></Mark>
##  <Item>concatenation of <C>CAPITALLETTERS</C> and <C>SMALLLETTERS</C></Item>
##  <Mark><C>DIGITS</C></Mark><Item><C>"0123456789"</C></Item>
##  <Mark><C>HEXDIGITS</C></Mark><Item><C>"0123456789ABCDEFabcdef"</C></Item>
##  <Mark><C>BOXCHARS</C></Mark>
##     <Item><Alt Not="LaTeX"><C>"─│┌┬┐├┼┤└┴┘━┃┏┳┓┣╋┫┗┻┛═║╔╦╗╠╬╣╚╩╝"</C></Alt>
##     <Alt Only="LaTeX"><C>Encode(Unicode(9472 + [ 0, 2, 12, 44, 16, 28,
##     60, 36, 20, 52, 24, 1, 3, 15, 51, 19, 35, 75, 43, 23, 59, 27, 80, 81,
##     84, 102, 87, 96, 108, 99, 90, 105, 93 ]), "UTF-8")</C></Alt>, 
##  these are  in UTF-8 encoding,  the <C>i</C>-th unicode  character is
##  <C>BOXCHARS{[3*i-2..3*i]}</C>.</Item>
##  </List>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallValue(WHITESPACE, " \n\t\r");
InstallValue(CAPITALLETTERS, "ABCDEFGHIJKLMNOPQRSTUVWXYZ");
IsSet(CAPITALLETTERS);
InstallValue(SMALLLETTERS, "abcdefghijklmnopqrstuvwxyz");
IsSet(SMALLLETTERS);
InstallValue(LETTERS, Concatenation(CAPITALLETTERS, SMALLLETTERS));
IsSet(LETTERS);
InstallValue(DIGITS, "0123456789");
InstallValue(HEXDIGITS, "0123456789ABCDEFabcdef");
InstallValue(BOXCHARS, "─│┌┬┐├┼┤└┴┘━┃┏┳┓┣╋┫┗┻┛═║╔╦╗╠╬╣╚╩╝");

MakeImmutable(WHITESPACE);
MakeImmutable(CAPITALLETTERS);
MakeImmutable(SMALLLETTERS);
MakeImmutable(LETTERS);
MakeImmutable(DIGITS);
MakeImmutable(HEXDIGITS);
MakeImmutable(BOXCHARS);

# utilities to find lines
InstallGlobalFunction(PositionLinenumber, function(str, nr)
  local pos, i;
  pos := 0;
  i := 1;
  while i < nr and pos <> fail do
    pos := Position(str, '\n', pos);
    i := i+1;
  od;
  if i = nr and IsInt(pos) then
    return pos+1;
  else
    return fail;
  fi;
end);
InstallGlobalFunction(NumberOfLines, function(str)
  local pos, i;
  if Length(str) = 0 then
    return 0;
  fi;
  pos := 0;
  i := 1;
  while pos <> fail do
    pos := Position(str, '\n', pos);
    i := i+1;
  od;
  if str[Length(str)] = '\n' then
    return i-2;
  else
    return i-1;
  fi;
end);

##  
##  <#GAPDoc Label="TextAttr">
##  <ManSection>
##  <Var Name="TextAttr" />
##  <Description>
##  The  record  <Ref Var="TextAttr"/>  contains  strings  which can  be
##  printed  to   change  the  terminal  attribute   for  the  following
##  characters. This  only works  with terminals which  understand basic
##  ANSI escape sequences.  Try the following example to see  if this is
##  the case for the terminal you are  using. It shows the effect of the
##  foreground and background color  attributes and of the <C>.bold</C>,
##  <C>.blink</C>, <C>.normal</C>, <C>.reverse</C> and <C>.underscore</C>
##  which can partly be mixed.
##  
##  <Listing Type="Example">
##  extra := ["CSI", "reset", "delline", "home"];;
##  for t in Difference(RecNames(TextAttr), extra) do
##    Print(TextAttr.(t), "TextAttr.", t, TextAttr.reset,"\n");
##  od;
##  </Listing>
##  
##  The suggested defaults for colors <C>0..7</C> are black, red, green,
##  brown, blue,  magenta, cyan,  white. But this  may be  different for
##  your terminal configuration.<P/>
##  
##  The  escape  sequence <C>.delline</C>  deletes  the  content of  the
##  current line and  <C>.home</C> moves the cursor to  the beginning of
##  the current line.
##  
##  <Listing Type="Example">
##  for i in [1..5] do 
##    Print(TextAttr.home, TextAttr.delline, String(i,-6), "\c"); 
##    Sleep(1); 
##  od;
##  </Listing>
##  
##  <Index>UseColorsInTerminal</Index> 
##  Whenever  you  use  this  in   some  printing  routines  you  should
##  make  it optional.  Use  these attributes  only  when 
##  <C>UserPreference("UseColorsInTerminal");</C> returns <K>true</K>.
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
##  
InstallValue(TextAttr, rec());
TextAttr.CSI := "\033[";
TextAttr.reset := Concatenation(TextAttr.CSI, "0m");
TextAttr.normal := Concatenation(TextAttr.CSI, "22m");
TextAttr.bold := Concatenation(TextAttr.CSI, "1m");
TextAttr.underscore := Concatenation(TextAttr.CSI, "4m");
TextAttr.blink := Concatenation(TextAttr.CSI, "5m");
TextAttr.reverse := Concatenation(TextAttr.CSI, "7m");
# foreground colors 0..7 (default: black, red, green, brown, blue, magenta,
# cyan, white
TextAttr.0 := Concatenation(TextAttr.CSI, "30m");
TextAttr.1 := Concatenation(TextAttr.CSI, "31m");
TextAttr.2 := Concatenation(TextAttr.CSI, "32m");
TextAttr.3 := Concatenation(TextAttr.CSI, "33m");
TextAttr.4 := Concatenation(TextAttr.CSI, "34m");
TextAttr.5 := Concatenation(TextAttr.CSI, "35m");
TextAttr.6 := Concatenation(TextAttr.CSI, "36m");
TextAttr.7 := Concatenation(TextAttr.CSI, "37m");
# background colors 0..7
TextAttr.b0 := Concatenation(TextAttr.CSI, "40m");
TextAttr.b1 := Concatenation(TextAttr.CSI, "41m");
TextAttr.b2 := Concatenation(TextAttr.CSI, "42m");
TextAttr.b3 := Concatenation(TextAttr.CSI, "43m");
TextAttr.b4 := Concatenation(TextAttr.CSI, "44m");
TextAttr.b5 := Concatenation(TextAttr.CSI, "45m");
TextAttr.b6 := Concatenation(TextAttr.CSI, "46m");
TextAttr.b7 := Concatenation(TextAttr.CSI, "47m");

TextAttr.delline := Concatenation(TextAttr.CSI, "2K");
TextAttr.home := Concatenation(TextAttr.CSI, "1G");

MakeImmutable(TextAttr);

##  <#GAPDoc Label="RepeatedString">
##  <ManSection >
##  <Func Arg="c, len" Name="RepeatedString" />
##  <Func Arg="c, len" Name="RepeatedUTF8String" />
##  <Description>
##  Here <A>c</A> must be either a  character or a string and <A>len</A>
##  is a non-negative number. Then <Ref Func="RepeatedString" /> returns
##  a string of length <A>len</A> consisting of copies of <A>c</A>.
##  <P/>
##  In the variant <Ref Func="RepeatedUTF8String" /> the argument <A>c</A>
##  is considered as string in UTF-8 encoding, and it can also be specified
##  as unicode string or character, see <Ref Oper="Unicode" />. The result is 
##  a string in UTF-8 encoding which has visible width <A>len</A> as explained
##  in <Ref Func="WidthUTF8String"/>. 
##  <Example>
##  gap> RepeatedString('=',51);
##  "==================================================="
##  gap> RepeatedString("*=",51);
##  "*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*"
##  gap> s := "bäh";;
##  gap> enc := GAPInfo.TermEncoding;;
##  gap> if enc &lt;&gt; "UTF-8" then s := Encode(Unicode(s, enc), "UTF-8"); fi;
##  gap> l := RepeatedUTF8String(s, 8);;
##  gap> u := Unicode(l, "UTF-8");;
##  gap> Print(Encode(u, enc), "\n");
##  bähbähbä
##  </Example>
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction(RepeatedString, function(s, n)
  local res, i;
  res := EmptyString(n+1);
  if n = 0 then
    return res;
  elif IsString(s) and Length(s) > 0 then
    if Length(s) > n then
      for i in [1..n] do
        res[i] := s[i];
      od;
      return s;
    else
      Append(res, s);
    fi;
  elif IsChar(s) then
    res[1] := s;
  else
    Error("First argument must be character or non-empty string\n");
  fi;
  while 2*Length(res) <= n do
    Append(res, res);
  od;
  Append(res, res{[1..n-Length(res)]});
  return res;
end);
InstallGlobalFunction(RepeatedUTF8String, function(s, n)
  local res, w, r, u, tail, i;
  if IsUnicodeCharacter(s) then
    # need to check this first because s is also in IsChar
    s := Encode(Unicode([Int(s)]),"utf8");
  elif IsChar(s) then
    res := "";
    Add(res,s);
    s := res;
  elif IsUnicodeString(s) then
    s := Encode(s, "utf8");
  elif not IsString(s) then
    Error("RepeatedUTF8String: First argument must be character, string \
or unicode \ncharacter or string.\n"); 
  fi;
  w := WidthUTF8String(s);
  if w = 0 then
    if n = 0 then 
      return "";
    else
      Error("RepeatedUTF8String: First argument has width 0.\n"); 
    fi;
  fi;
  r := QuotientRemainder(n, w);
  if r[2] <> 0 then
    u := Unicode(s, "utf8");
    tail := "";
    i := 1;
    while WidthUTF8String(tail) < r[2] do
      Append(tail, Encode(u{[i]}, "utf8"));
      i := i+1;
    od;
  else
    tail := "";
  fi;
  if r[1] = 0 then
    return tail;
  fi;
  r := r[1]*Length(s)+Length(tail);
  res := EmptyString(r);
  Append(res, s);
  while 2*Length(res) <= r do
    Append(res, res);
  od;
  Append(res, res{[1..r-Length(tail)-Length(res)]});
  Append(res, tail);
  return res;
end);


##  <#GAPDoc Label="PositionMatchingDelimiter">
##  <ManSection >
##  <Func Arg="str, delim, pos" Name="PositionMatchingDelimiter" />
##  <Returns>position as integer or <K>fail</K></Returns>
##  <Description>
##  Here <A>str</A> must  be a string and <A>delim</A>  a string with
##  two  different characters.  This function  searches the  smallest
##  position   <C>r</C>  of   the  character   <C><A>delim</A>[2]</C>
##  in   <A>str</A>   such  that   the   number   of  occurrences  of
##  <C><A>delim</A>[2]</C>    in    <A>str</A>   between    positions
##  <C><A>pos</A>+1</C>  and  <C>r</C> is  by  one  greater than  the
##  corresponding number of occurrences of <C><A>delim</A>[1]</C>.<P/>
##  
##  If such an <C>r</C> exists, it is returned. Otherwise <K>fail</K>
##  is returned.
##  
##  <Example>
##  gap> PositionMatchingDelimiter("{}x{ab{c}d}", "{}", 0);
##  fail
##  gap> PositionMatchingDelimiter("{}x{ab{c}d}", "{}", 1);
##  2
##  gap> PositionMatchingDelimiter("{}x{ab{c}d}", "{}", 6);
##  11
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction(PositionMatchingDelimiter, function(str, delim, pos)
  local   b,  e,  p,  l,  level;

  b := delim[1];
  e := delim[2];
  
  p := pos+1;
  l := Length(str);
  level := 0;
  while true do
    if p > l then
      return fail;
    elif str[p] = b then
      level := level+1;
    elif str[p] = e then
      if level = 0 then 
        return p;
      else
        level := level-1;
      fi;
    fi;
    p := p+1;
  od;
end);

##  <#GAPDoc Label="SubstitutionSublist">
##  <ManSection >
##  <Func Arg="list, sublist, new[, flag]" Name="SubstitutionSublist" />
##  <Returns>the changed list</Returns>
##  <Description>
##  This function looks for (non-overlapping) occurrences of a sublist
##  <A>sublist</A> in a list <A>list</A> (compare <Ref BookName="ref"
##  Oper="PositionSublist"  />) and  returns a  list where  these are
##  substituted with the list <A>new</A>.<P/>
##  
##  The  optional argument  <A>flag</A>  can  either be  <C>"all"</C>
##  (this is the default if not given) or <C>"one"</C>. In the second
##  case only  the first occurrence of <A>sublist</A> is substituted.
##  <P/>
##  
##  If <A>sublist</A> does not  occur in <A>list</A> then <A>list</A>
##  itself is returned (and not a <C>ShallowCopy(list)</C>).
##  
##  <Example>
##  gap> SubstitutionSublist("xababx", "ab", "a");
##  "xaax"
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
InstallGlobalFunction(SubstitutionSublist, function(arg)
  local   str,  substr,  lss,  subs,  all,  p,  s, off;
  str := arg[1];
  substr := arg[2];
  lss := Length(substr);
  subs := arg[3];
  if Length(arg)>3 then
    all := arg[4]="all";
  else
    all := true;
  fi;
  
  p := PositionSublist(str, substr);
  if p = fail then 
    # return original object in case of no substitution
    return str; 
  fi;
  s := str{[]};
  off := 1-lss;
  while p<>fail do
    Append(s, str{[off+lss..p-1]});
    Append(s, subs);
##      str := str{[p+lss..Length(str)]};
    off := p;
    if all then
      p := PositionSublist(str, substr, p+lss-1);
    else
      p := fail;
    fi;
    if p=fail then
      Append(s, str{[off+lss..Length(str)]});
    fi;
  od;
  return s;
end);
    

##  <#GAPDoc Label="NumberDigits">
##  <ManSection >
##  <Func Arg="str, base" Name="NumberDigits" />
##  <Returns>integer</Returns>
##  <Func Arg="n, base" Name="DigitsNumber" />
##  <Returns>string</Returns>
##  <Description>
##  The argument  <A>str</A> of  <Ref Func="NumberDigits" />  must be
##  a  string  consisting  only  of an  optional  leading  <C>'-'</C>
##  and characters  in  <C>0123456789abcdefABCDEF</C>,  describing an
##  integer  in  base <A>base</A>  with  <M>2  \leq <A>base</A>  \leq
##  16</M>. This function returns the corresponding integer.<P/>
##  
##  The function <Ref Func="DigitsNumber" /> does the reverse.
##  
##  <Example>
##  gap> NumberDigits("1A3F",16);
##  6719
##  gap> DigitsNumber(6719, 16);
##  "1A3F"
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(NumberDigits, function(str, base)
  local   res,  x,  nr, sign;
  res := 0;
  sign := 1;
  for x in str do
    nr := INT_CHAR(x) - 48;
    if nr = -3 then 
      # '-'
      sign := -sign;
    else
      if nr>48 then 
        nr := nr - 39;
      elif nr>15 then
        nr := nr - 7;
      fi;
      res := res*base + nr;
    fi;
  od;
  return sign*res;
end);

InstallGlobalFunction(DigitsNumber, function(n, base)
  local str, s;
  s := "";
  if n<0 then
    Add(s, '-');
    n := -n;
  fi;
  str := "";
  while n <> 0 do
    Add(str, HEXDIGITS[(n mod base) + 1]);
    n := QuoInt(n, base);
  od;
  return Concatenation(s, Reversed(str));
end);

##  <#GAPDoc Label="LabelInt">
##  <ManSection >
##  <Func Arg="n, type, pre, post" Name="LabelInt" />
##  <Returns>string</Returns>
##  <Description>
##  The argument <A>n</A> must be an integer in the range from 1 to 5000,
##  while <A>pre</A> and <A>post</A> must be strings.
##  <P/>
##  The argument <A>type</A> can be one of <C>"Decimal"</C>,
##  <C>"Roman"</C>, <C>"roman"</C>, <C>"Alpha"</C>, <C>"alpha"</C>.
##  <P/>
##  The function returns a string that starts with <A>pre</A>, followed by
##  a decimal, respectively roman number or alphanumerical number literal
##  (capital, respectively small letters), followed by <A>post</A>.
##  <P/>
##  <Example>
##  gap> List([1,2,3,4,5,691], i-> LabelInt(i,"Decimal","","."));
##  [ "1.", "2.", "3.", "4.", "5.", "691." ]
##  gap> List([1,2,3,4,5,691], i-> LabelInt(i,"alpha","(",")"));
##  [ "(a)", "(b)", "(c)", "(d)", "(e)", "(zo)" ]
##  gap> List([1,2,3,4,5,691], i-> LabelInt(i,"alpha","(",")"));
##  [ "(a)", "(b)", "(c)", "(d)", "(e)", "(zo)" ]
##  gap> List([1,2,3,4,5,691], i-> LabelInt(i,"Alpha","",".)"));
##  [ "A.)", "B.)", "C.)", "D.)", "E.)", "ZO.)" ]
##  gap> List([1,2,3,4,5,691], i-> LabelInt(i,"roman","","."));
##  [ "i.", "ii.", "iii.", "iv.", "v.", "dcxci." ]
##  gap> List([1,2,3,4,5,691], i-> LabelInt(i,"Roman","",""));
##  [ "I", "II", "III", "IV", "V", "DCXCI" ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(LabelInt, function(n, type, pre, post)
  local l1, l2, l3, l, res, r, i;
  if not IsInt(n) or n < 1 or n>5000 then
    return fail;
  fi;
  if type="roman" then
    l1 := ["","i","ii","iii","iv","v","vi","vii","viii","ix"];
    l2 := ["","x","xx","xxx","xl","l","lx","lxx","lxxx","xc"];
    l3 := ["","c","cc","ccc","cd","d","dc","dcc","dccc","cm","m"];
  elif type="Roman" then
    l1 := ["","I","II","III","IV","V","VI","VII","VIII","IX"];
    l2 := ["","X","XX","XXX","XL","L","LX","LXX","LXXX","XC"];
    l3 := ["","C","CC","CCC","CD","D","DC","DCC","DCCC","CM","M"];
  fi;
  if type="alpha" then
    l := LETTERS{[27..52]};
  elif type="Alpha" then
    l := LETTERS{[1..26]};
  fi;
  if type="Decimal" then
    res := String(n);
  elif type in ["roman","Roman"] then
    res := "";
    for i in [1..QuoInt(n,1000)] do
      Append(res, l3[11]);
    od;
    Append(res, l3[QuoInt(n,100) mod 10 + 1]);
    Append(res, l2[QuoInt(n,10) mod 10 + 1]);
    Append(res, l1[n mod 10 + 1]);
  elif type in ["alpha", "Alpha"] then
    if n < 27 then
      res := l{[n]};
    elif n <= 26*27 then
      res := l{[QuoInt(n-1,26),((n-1) mod 26)+1]};
    else
      res := l{[QuoInt(n-27,26*26),
                QuoInt((n-27) mod 26^2-1, 26)+1,((n-1) mod 26)+1]};
    fi;
  fi;
  return Concatenation(pre, res, post);
end);
 
##  <#GAPDoc Label="StripBeginEnd">
##  <ManSection >
##  <Func Arg="list, strip" Name="StripBeginEnd" />
##  <Returns>changed string</Returns>
##  <Description>
##  Here <A>list</A>  and <A>strip</A>  must be lists.  This function
##  returns the  sublist of list  which does not contain  the leading
##  and trailing  entries which are  entries of <A>strip</A>.  If the
##  result  is  equal  to  <A>list</A>  then  <A>list</A>  itself  is
##  returned.
##  
##  <Example>
##  gap> StripBeginEnd(" ,a, b,c,   ", ", ");
##  "a, b,c"
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(StripBeginEnd, function(str, chars)
  local   pb,  l,  pe;
  pb := 1;
  l := Length(str);
  while  pb <= l and str[pb] in chars do
    pb := pb + 1;
  od;
  pe := l;
  while pe > 0 and str[pe] in chars do
    pe := pe - 1;
  od;
  if pb > 1 or pe < l then
    return str{[pb..pe]};
  else
    return str;
  fi;
end);


##  <#GAPDoc Label="NormalizedWhitespace">
##  <ManSection >
##  <Func Arg="str" Name="NormalizedWhitespace" />
##  <Returns>new string with white space normalized</Returns>
##  <Description>
##  This  function  gets  a  string  <A>str</A>  and  returns  a  new
##  string  which  is a  copy  of  <A>str</A> with  normalized  white
##  space.  Note  that  the   library  function  <Ref  BookName="ref"
##  Func="NormalizeWhitespace"  />  works in place  and  changes  its
##  argument.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
# moved into GAP library
##  InstallGlobalFunction(NormalizedWhitespace, function(str)
##    local   res;
##    res := ShallowCopy(str);
##    NormalizeWhitespace(res);
##    return res;
##  end);



##  <#GAPDoc Label="WrapTextAttribute">
##  <ManSection >
##  <Func Arg="str, attr" Name="WrapTextAttribute" />
##  <Returns>a string with markup</Returns>
##  <Description>
##  The argument <A>str</A> must be a text as &GAP; string, possibly with 
##  markup by escape sequences as in <Ref Var="TextAttr" />. This function
##  returns a string which is wrapped by the escape sequences <A>attr</A>
##  and <C>TextAttr.reset</C>. It takes care of markup in the given string
##  by appending <A>attr</A> also after each given <C>TextAttr.reset</C> in
##  <A>str</A>.
##  <Example>
##  gap> str := Concatenation("XXX",TextAttr.2, "BLUB", TextAttr.reset,"YYY");
##  "XXX\033[32mBLUB\033[0mYYY"
##  gap> str2 := WrapTextAttribute(str, TextAttr.1);
##  "\033[31mXXX\033[32mBLUB\033[0m\033[31m\027YYY\033[0m"
##  gap> str3 := WrapTextAttribute(str, TextAttr.underscore);
##  "\033[4mXXX\033[32mBLUB\033[0m\033[4m\027YYY\033[0m"
##  gap> # use Print(str); and so on to see how it looks like.
##  </Example>
##  </Description>
##  </ManSection>
##  
##  <#/GAPDoc>
InstallGlobalFunction(WrapTextAttribute, function(str, attr)
  if IsList(attr) and Length(attr) > 0 and IsString(attr[1]) and
     Length(attr[1]) > 1 and attr[1]{[1,2]} = TextAttr.CSI and
                            attr[2] = TextAttr.reset then
    attr := attr[1];
  fi;
  if IsString(attr) and Length(attr) > 1 and attr{[1,2]} = TextAttr.CSI then
    # we mark inner attribute starters by appending a char 23
    str := SubstitutionSublist(str, TextAttr.reset, Concatenation(
                                              TextAttr.reset, attr, "\027"));
    str := Concatenation(attr, str, TextAttr.reset);
  elif IsString(attr) then
    str := Concatenation(attr,str,attr);
  elif IsList(attr) and Length(attr) = 2 and IsString(attr[1]) and
    IsString(attr[2]) then
    str := Concatenation(attr[1], str, attr[2]);
  else
    Error("WrapTextAttribute: argument attr must be string or list of two strings.\n");
  fi;
  return str;
end);

##  <#GAPDoc Label="FormatParagraph">
##  <ManSection >
##  <Func Arg="str[, len][, flush][, attr][, widthfun]" 
##      Name="FormatParagraph" />
##  <Returns>the formatted paragraph as string</Returns>
##  <Description>
##  This function formats a text given  in the string <A>str</A> as a
##  paragraph. The optional arguments have the following meaning:
##  
##  <List >
##  <Mark><A>len</A></Mark>
##  <Item>the length of  the lines of the formatted  text, default is
##  <C>78</C> (counted without a visible length of the strings
##  specified in the <A>attr</A> argument)</Item>
##  <Mark><A>flush</A></Mark>
##  <Item>can  be <C>"left"</C>,  <C>"right"</C>, <C>"center"</C>  or
##  <C>"both"</C>, telling that lines should be flushed left, flushed
##  right, centered or left-right justified, respectively, default is
##  <C>"both"</C></Item>
##  <Mark><A>attr</A></Mark>
##  <Item>is a  list of two strings;  the first is prepended  and the
##  second  appended to  each line  of  the result  (can for  example
##  be  used  for  indenting,  <C>["  ",  ""]</C>,  or  some  markup,
##  <C>[TextAttr.bold,   TextAttr.reset]</C>,   default  is   <C>["",
##  ""]</C>)</Item>
##  <Mark><A>widthfun</A></Mark>
##  <Item>must be a function which returns the display width of text in 
##  <A>str</A>. The default is <C>Length</C> assuming that each byte 
##  corresponds to a character of width one. If <A>str</A> is given in 
##  <C>UTF-8</C> encoding one can use <Ref Func="WidthUTF8String"/> here.
##  </Item>
##  </List>
##  
##  This function  tries to handle  markup with the  escape sequences
##  explained in <Ref Var="TextAttr"/> correctly.
##  
##  <Example>
##  gap> str := "One two three four five six seven eight nine ten eleven.";;
##  gap> Print(FormatParagraph(str, 25, "left", ["/* ", " */"]));           
##  /* One two three four five */
##  /* six seven eight nine ten */
##  /* eleven. */
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
BindGlobal("SPACESTRINGS", [" "]);
# only relevant for HPCGAP, to allow for formatting of help pages in any thread
if IsBound(HPCGAP) then
  MakeThreadLocal("SPACESTRINGS");                                             
fi;                                                                            

InstallGlobalFunction(FormatParagraph, function(arg)
  local   str,  len,  flush,  attr, width, i, words, esc, l, j, k, lw,  
          lines,  s,  ss,  nsp,  res,  a,  new,  qr,  b;
  str := arg[1];
  # default line length
  len := 78;
  # default flush (flush left and right)
  flush := "both";
  # default attribute (empty)
  attr := false;
  # default width function assumes that one byte is one character
  width := Length;
  # scan further arg's
  for i in [2..Length(arg)] do
    if IsInt(arg[i]) then
      len := arg[i];
    elif arg[i] in ["both", "left", "right", "center"] then
      flush := arg[i];
    elif IsList(arg[i]) then
      attr := arg[i];
    elif IsFunction(arg[i]) then
      width := arg[i];
    else
      Error("wrong argument", arg[i]);
    fi;
  od;
  for i in [Length(SPACESTRINGS)+1..len] do
    SPACESTRINGS[i] := Concatenation(SPACESTRINGS[i-1], " ");
  od;
  # we scan the string
  words := [];
  i := 1;
  esc := CHAR_INT(27);
  l := Length(str);
  while i<=l do
    if str[i] in WHITESPACE then
      # delete leading whitespace
      if Length(words)>0 then
        Add(words, 1);
      fi;
      i := i+1;
      while i<=l and str[i] in WHITESPACE do
        i := i+1;
      od;
    elif str[i] = esc then
      # sequences starting with ESC and stopping with the first letter
      # afterwards are not changed and considered to have length zero
      j := i+1;
      while j<=l and not str[j] in SMALLLETTERS and not str[j] in
        CAPITALLETTERS do
        j := j+1;
      od;
      if j>l then
        Error("string end inside escape sequence");
      else
        Add(words, [0, [i..j]]);
      fi;
      i := j+1;
    else
      j := i+1;
      while j<=l and not (str[j] in WHITESPACE or str[j]=esc) do
        j := j+1;
      od;
      if ForAll([i..j-1], k-> IsChar(str[k])) then
        Add(words, [width(str{[i..j-1]}), [i..j-1]]);
      else
        Add(words, [j-i, [i..j-1]]);
      fi;
      i := j;
    fi;
  od;
  # remove trailing white space
  lw := Length(words);
  if lw>0 and IsInt(words[lw]) then
    Unbind(words[lw]);
  fi;
  
  # split into lines
  lines := [];
  i := 1;
  lw := Length(words);
  while i <= lw do
    s := words[i][1];
    j := i+1;
    nsp := 0;
    while j <= lw and s+nsp < len do
      if IsInt(words[j]) then
        nsp := nsp+1;
        j := j+1;
      else
        # line breaks only at white space
        ss := s+nsp;
        k := j;
        while k <= lw and IsList(words[k]) do
          ss := ss+words[k][1];
          k := k+1;
        od;
        if s=0 or ss <= len then
          s := ss-nsp;
          j := k;
        else
          break;
        fi;
      fi;
    od;
    if IsInt(words[j-1]) then
      Add(lines, [s,nsp-1,[i..j-2]]);
      i := j;
    else
      Add(lines, [s,nsp,[i..j-1]]);
      i := j+1;
    fi;
  od;
  
  # format lines
  res := "";
  for i in [1..Length(lines)] do
    a := lines[i];
    new := words{a[3]};
    # now fill with spaces
    nsp := len - a[1] - a[2];
    if nsp > 0 then
      if flush = "right" then
        new := Concatenation([nsp], new);
      elif flush = "both" and a[2] > 0 and i < Length(lines) then
        qr := QuotientRemainder(nsp, a[2]);
        for j in [1..Length(new)] do
          if IsInt(new[j]) then
            if qr[2]>0 then
              new[j] := new[j]+qr[1]+1;
              qr[2] := qr[2]-1;
            else
              new[j] := new[j]+qr[1];
            fi;
          fi;
        od;
      elif flush = "center" and nsp > 1 then
        new := Concatenation([QuoInt(nsp,2)], new);
      fi;
    fi;
    # add text attribute begin
    if attr <> false and Length(new)>0 then
      if IsInt(new[1]) then
        new := Concatenation([new[1]], [attr[1]], new{[2..Length(new)]});
      else
        Append(res, attr[1]);
      fi;
    fi;
    s := "";
    for b in new do
      if IsInt(b) then
        Append(s, SPACESTRINGS[b]);
      elif IsString(b) then
        Append(s, b);
      else # range
        Append(s, str{b[2]});
      fi;
    od;
    # add text attribute begin after each text attribute reset (if it
    # is an escape sequence) 
    # and the end attribute
    if attr <> false then
      if Length(attr[1])>2 and attr[1]{[1,2]} = TextAttr.CSI then
        s := SubstitutionSublist(s, TextAttr.reset, attr[1]);
      fi;
      Append(s, attr[2]);
    fi;
    Add(s, '\n');
    Append(res, s);
  od;
##  if PositionSublist(res,"\033[33X")<> fail and PositionSublist(res,"\033[133X")= fail then Error("FP"); fi;
##  if PositionSublist(res,"Emph")<> fail then Error("FP"); fi;
  return res;
end);

##  <#GAPDoc Label="StripEscapeSequences">
##  <ManSection >
##  <Func Arg="str" Name="StripEscapeSequences" />
##  <Returns>string without escape sequences</Returns>
##  <Description>
##  This  function  returns  the  string one  gets  from  the  string
##  <A>str</A> by  removing all escape sequences  which are explained
##  in <Ref Var="TextAttr"/>.  If <A>str</A> does not  contain such a
##  sequence then <A>str</A> itself is returned.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(StripEscapeSequences, function(str)
  local   esc,  res,  i,  ls,  p;
  esc := CHAR_INT(27);
  res := "";
  i := 1;
  ls := Length(str);
  while i <= ls do
    if str[i] = esc then
      i := i+1;
      while not str[i] in LETTERS do
        i := i+1;
      od;
      # first letter is last character of escape sequence
      i := i+1; 
      # remove \027 marker of inner escape sequences as well
      if IsBound(str[i]) and str[i] = '\027' then
        i := i+1;
      fi;
    else
      p := Position(str, esc, i);
      if p=fail then
        if i=1 then
          # don't copy if no escape there
          return str;
        else
          Append(res, str{[i..ls]});
          return res;
        fi;
      else
        Append(res, str{[i..p-1]});
        i := p;
      fi;
    fi;
  od;
  return res;
end);
InstallGlobalFunction(SubstituteEscapeSequences, function(str, subs)
  local orig, special, hash, esc, res, i, ls, seq, pos, p, b, e, width, 
        cont, nb, ne, flush, pY, indlen, par, j, row, a, l, n, k, widthfun;

  # maybe we need to simplify some substitution strings because
  # of the current encoding, we cache the result
  if GAPInfo.TermEncoding <> "UTF-8" then
    if IsBound(subs.(GAPInfo.TermEncoding)) then
      subs := subs.(GAPInfo.TermEncoding);
    else
      orig := subs;
      subs := ShallowCopy(subs);
      for a in RecNames(subs) do
        if IsList(subs.(a)) then
          subs.(a) := [subs.(a)[1], List(subs.(a)[2], x-> 
                                Encode(
                                SimplifiedUnicodeString(Unicode(x, "UTF-8"), 
                                GAPInfo.TermEncoding),
                                GAPInfo.TermEncoding))];
        fi;
      od;
      orig.(GAPInfo.TermEncoding) := subs;
    fi;
  fi;
  # we need a special handling of tags to reformat paragraphs and to
  # fill lines
  special := [];
  for a in ["format", "FillString"] do
    Add(special, Position(subs.hash[1], subs.(a)[1][1]));
    Add(special, Position(subs.hash[1], subs.(a)[1][2]));
  od;
  hash := subs.hash;
  esc := CHAR_INT(27);
  res := "";
  i := 1;
  ls := Length(str);
  while i <= ls do
    if str[i] = esc and IsBound(str[i+1]) and str[i+1] = '[' then
      seq := "";
      i := i+1;
      while not str[i] in LETTERS do
        i := i+1;
        Add(seq, str[i]);
      od;
      # first letter is last character of escape sequence
      i := i+1; 
      if IsBound(str[i]) and str[i] = '\027' then
        cont := true;
        i := i+1;
      else
        cont := false;
      fi;
      pos := PositionSet(hash[1], seq);
      if pos <> fail and not pos in special then
        if cont and (Length(hash[2][pos]) = 0 or hash[2][pos][1] <> esc) then
          seq := "";
        else
          seq := hash[2][pos];
        fi;
      else
        Add(res, esc);
        Add(res, '[');
      fi;
      Append(res, seq);
    else
      p := Position(str, esc, i);
      if p=fail then
        if i=1 then
          # don't copy if no escape there
          return str;
        else
          Append(res, str{[i..ls]});
          i := ls+1;
        fi;
      else
        Append(res, str{[i..p-1]});
        i := p;
      fi;
    fi;
  od;
  # now we reformat paragraphs
  if GAPInfo.TermEncoding = "UTF-8" then
    widthfun := WidthUTF8String;
  else
    widthfun := Length;
  fi;
  str := res;
  res := "";
  pos := 0;
  b := Concatenation(TextAttr.CSI, subs.format[1][1]);
  e := Concatenation(TextAttr.CSI, subs.format[1][2]);
  width := SizeScreen()[1] - 2;
  while pos <> fail do
    nb := PositionSublist(str, b, pos);
    if nb = fail then
      Append(res, str{[pos+1..Length(str)]});
      pos := fail;
    else
      ne := PositionSublist(str, e, nb);
      # find flush mode
      if str[nb+Length(b)+2] = '0' then
        flush := subs.flush[2][1];
      elif str[nb+Length(b)+2] = '1' then
        flush := "left";
      elif str[nb+Length(b)+2] = '2' then
        flush := "center";
      else
        flush := "both";
      fi;
      Append(res, str{[pos+1..nb-1]});
      # find indent
      pY := Position(str, 'Y', nb);
      # the +2 because all help text has additional indentation of 2
      indlen := Int(str{[nb+Length(b)+4..pY-1]}) + 2;
      par := FormatParagraph(str{[pY+1..ne-1]}, width - indlen, flush,
                          [RepeatedString(" ", indlen), ""], widthfun);
      # remove leading blanks if there is already something on this line
      # (e.g., initial indentation or a list mark)
      i := Length(res);
      while i > 0 and res[i] <> '\n' do
        i := i-1;
      od;
      i := widthfun(StripEscapeSequences(res{[i+1..Length(res)]}));
      while i > 0 and par[1] = ' ' do
        Remove(par,1);
        i := i-1;
      od;
      if Length(par) > 1 and par[Length(par)] = '\n' then
        Unbind(par[Length(par)]);
      fi;
      Append(res, par);
      pos := ne + Length(e) - 1;
    fi;
  od;
  # a finally we expand the fill strings
  b := Concatenation(TextAttr.CSI, subs.FillString[1][1]);
  if PositionSublist(res, b) <> fail then
    str := res;
    res := "";
    pos := 0;
    nb := PositionSublist(str, b, pos);
    while nb <> fail do
      # find row
      i := nb-1;
      while i>0 and str[i] <> '\n' do
        i := i-1;
      od;
      j := nb+1;
      while Length(str) >= j and str[j] <> '\n' do
        j := j+1;
      od;
      Append(res, str{[pos+1..i]});
      # split row into pieces to fill
      row := [str{[i+1..nb-1]}, str{[nb+Length(b)..j-1]}];
      nb := PositionSublist(row[Length(row)], b);
      while nb <> fail do
        a := row[Length(row)];
        row[Length(row)] := a{[1..nb-1]};
        Add(row, a{[nb+Length(b)..Length(a)]});
        nb := PositionSublist(row[Length(row)], b);
      od;
      # lengths of the fillings
      l := width - Sum(row, a-> widthfun(StripEscapeSequences(a)));
      n := Length(row)-1;
      ls := [];
      for k in [1..n] do
        Add(ls, QuoInt(l,n));
      od;
      k := n;
      while Sum(ls) < l do
        ls[k] := ls[k]+1;
        k := k-1;
      od;
      # cannot do much when line already too long
      if l < 0 then
        ls := 0*ls;
      fi;
      for i in [1..n] do
        Append(res, row[i]);
        Append(res, RepeatedUTF8String(subs.FillString[2][1], ls[i]));
      od;
      Append(res, row[n+1]);
      pos := j-1;
      nb := PositionSublist(str, b, pos);
    od;
    Append(res, str{[pos+1..Length(str)]});
  fi;
  return res;
end);



##  <#GAPDoc Label="WordsString">
##  <ManSection >
##  <Func Arg="str" Name="WordsString" />
##  <Returns>list of strings containing the words</Returns>
##  <Description>
##  This returns  the list of  words of a  text stored in  the string
##  <A>str</A>. All non-letters are considered as word boundaries and
##  are removed.
##  <Example>
##  gap> WordsString("one_two \n    three!?");
##  [ "one", "two", "three" ]
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##  
InstallGlobalFunction(WordsString, function(str)
  local   nonletters, wds;
  nonletters := Set("0123456789 \n\r\t\b+*~^\\\"#'`'/?-_.:,;<>|=()[]{}&%$§!");
  wds := SplitString(str, "", nonletters);
  return wds;
end);

# The GAP library will contain a new function CrcString. To make GAPDoc
# running with current/older versions of GAP we use the following helper,
# if necessary with a simple fallback.
if IsBoundGlobal("CrcString") then
  InstallGlobalFunction(CrcText, CrcString); 
else
  InstallGlobalFunction(CrcText, function(s)
    local n, res;
    n := "guckCRCXQWYNVOH";
    FileString(n, s);
    res := CrcFile(n);
    RemoveFile(n);
    return res;
  end);
fi;

##  <#GAPDoc Label="Base64String">
##  <ManSection >
##  <Func Arg="str" Name="Base64String" />
##  <Func Arg="bstr" Name="StringBase64" />
##  <Returns>a string</Returns>
##  <Description>
##  The  first  function  translates  arbitrary   binary  data  given  as  a
##  GAP  string  into   a  <E>base  64</E>  encoded   string.  This  encoded
##  string  contains  only  printable  ASCII   characters  and  is  used  in
##  various  data  transfer  protocols  (<C>MIME</C>  encoded  emails,  weak
##  password   encryption,  ...).   We   use  the   specification  in   <URL
##  Text="RFC&#160;2045">http://tools.ietf.org/html/rfc2045</URL>.<P/>
##  
##  The second function  has the reverse functionality. Here  we also accept
##  the characters  <C>-_</C> instead of  <C>+/</C> as last  two 
##  characters.  Whitespace is ignored.
##  
##  <Example>
##  gap> b := Base64String("This is a secret!");
##  "VGhpcyBpcyBhIHNlY3JldCEA="
##  gap> StringBase64(b);                       
##  "This is a secret!"
##  </Example>
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
BindGlobal("Base64LETTERS",
          "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/");
BindGlobal("Base64REVERSE",
[,,,,,,,,,-1,,,-1,,,,,,,,,,,,,,,,,,,-1,,,,,,,,,,,62,,62,,63,52,53,54,55,56,57,58,59,60,61,,,,-2,,,,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,,,,,63,,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51]);

MakeImmutable(Base64LETTERS);
MakeImmutable(Base64REVERSE);

InstallGlobalFunction(Base64String, function(str)
  local istr, pad, i, res, a, d, c, b;
  istr := INTLIST_STRING(str, 1);
  pad := (-Length(istr)) mod 3;
  for i in [1..pad] do
    Add(istr,0);
  od;
  i := 1;
  res := "";
  while i < Length(istr) do
    if i > 1 and i mod 57 = 1 then
      Add(res, '\n');
    fi;
    a := (istr[i]*256+istr[i+1])*256+istr[i+2];
    d := RemInt(a, 64);
    a := (a-d)/64;
    c := RemInt(a, 64);
    a := (a-c)/64;
    b := RemInt(a, 64);
    a := (a-b)/64;
    Append(res, Base64LETTERS{[a,b,c,d]+1});
    i := i+3;
  od;
  if i mod 57 = 1 and pad > 0 then
    Add(res, '\n');
  fi;
  for i in [1..pad] do
    Add(res, '=');
  od;
  return res;
end);
 
InstallGlobalFunction(StringBase64, function(bstr)
  local istr, res, j, n, d, c, a;
  istr := Base64REVERSE{INTLIST_STRING(bstr, 1)};
  res := [];
  j := 0;
  n := 0;
  for a in istr do
    if a <> -1 then
      if a = -2 then
        Unbind(res[Length(res)]);
      else
        n := n*64+a;
        j := j+1;
        if j = 4 then
          d := RemInt(n, 256);
          n := (n-d)/256;
          c := RemInt(n, 256);
          n := (n-c)/256;
          Append(res, [n,c,d]);
          j := 0;
          n := 0;
        fi;
      fi;
    fi;
  od;
  return STRING_SINTLIST(res);
end);


