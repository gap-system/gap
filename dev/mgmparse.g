# Magma to GAP converter
MGMCONVER:="version 0.32, 6/25/15"; # very raw
# (C) Alexander Hulpke


TOKENS:=["if","then","eq","cmpeq","neq","and","or","else","not","assigned",
         "while","ne","repeat","until","error","do","assert",
	 "vprint","print","printf","vprintf",
	 "freeze","import","local","for","elif","intrinsic","to",
	 "end for","end function","end if","end intrinsic","end while",
	 "procedure","end procedure","where","break",
         "function","return",":=","+:=","-:=","*:=","cat:=","=",
	 "\\[","\\]","delete","exists",
	 "[","]","(",")","\\(","\\)","`",";","#","!","<",">","&","$",":->","hom",
	 "cat","[*","*]","->","@@","forward","join",
	 "+","-","*","/","div","mod","in","notin","^","~","..",".",",","\"",
	 "{","}","|","::",":","@","cmpne","subset","by","try","end try","catch err",
	 "declare verbose","declare attributes",
	 "exists","forall","time",
	 "sub","eval","select","rec","recformat","require","case","when","end case",
	 "%%%" # fake keyword for comments
	 ];
# Magma binary operators
BINOPS:=["+","-","*","/","div","mod","in","notin","^","`","!","and","|",
         "or","=","eq","cmpeq","ne","le","ge","gt","lt",".","->","@@","@","cmpne"];
# Magma binaries that have to become function calls in GAP
FAKEBIN:=["meet","subset","join","diff","cat"];
BINOPS:=Union(BINOPS,FAKEBIN);

PAROP:=["+","-","div","mod","in","notin","^","`","!","and",
         "or","=","eq","cmpeq","ne","."];
TOKENS:=Union(TOKENS,BINOPS);
TOKENS:=Union(TOKENS,PAROP);

# parses to the following units:

# co commentary
# B* binary operation *
# C function call
# <> substructure constructor
# L list indexing
# I identifier
# V vector
# & reduction operator
# U* unary operation *
# N number
# F function definition
# if conditional
# return
# : [op: a in l] operation
# R range [from..to]
#perm

UnFlat:=function(m)
local n;
  n:=RootInt(Length(m),2);
  if n^2<>Length(m) then
    return fail;
  fi;
  return List([1..n],x->m{[1+n*(x-1)..n*x]});
end;

FILEPRINTSTR:="";
FilePrint:=function(arg)
  local f,i,p;
  f:=arg[1];
  for i in [2..Length(arg)] do
    if not IsString(arg[i]) then
      FILEPRINTSTR:=Concatenation(FILEPRINTSTR,String(arg[i]));
    else
      FILEPRINTSTR:=Concatenation(FILEPRINTSTR,arg[i]);
    fi;
    p:=Position(FILEPRINTSTR,'\b');
    while p<>fail do
      FILEPRINTSTR:=Concatenation(FILEPRINTSTR{[1..p-2]},FILEPRINTSTR{[p+1..Length(FILEPRINTSTR)]});
      p:=Position(FILEPRINTSTR,'\b');
    od;
    p:=Position(FILEPRINTSTR,'\n');
    while p<>fail do
      AppendTo(f,FILEPRINTSTR{[1..p]});
      FILEPRINTSTR:=FILEPRINTSTR{[p+1..Length(FILEPRINTSTR)]};
      p:=Position(FILEPRINTSTR,'\n');
    od;

  od;
end;

CHARSIDS:=Concatenation(CHARS_DIGITS,CHARS_UALPHA,CHARS_LALPHA,"_");
CHARSOPS:="+-*/,;:=~!";

MgmParse:=function(file)
local Comment,eatblank,gimme,ReadID,ReadOP,ReadExpression,ReadBlock,
      ExpectToken,doselect,costack,locals,globvars,defines,problemarea,
      f,l,lines,linum,w,a,idslist,tok,tnum,i,sel,osel,e,comment;

  locals:=[];
  globvars:=[];
  defines:=[];

  # print current area (as being problematic)
  problemarea:=function()
  local l,s;
    Print("\c\n\n");
    l:=0;
    for i in [Maximum(1,tnum-200)..tnum-11] do
      s:=tok[i][2];
      if not IsString(s) then
	s:=String(s);
      fi;
      l:=l+Length(s);
      if l>78 then
	Print("\n");
	l:=Length(s);
      fi;
      Print(s);
    od;
    Print("\n");
    Print(tok{[Maximum(1,tnum-10)..tnum-1]},"\n------\n",tok{[tnum..tnum+10]},"\n");
    l:=0;
    for i in [tnum+11..tnum+50] do
      s:=tok[i][2];
      if not IsString(s) then
	s:=String(s);
      fi;
      l:=l+Length(s);
      if l>78 then
	Print("\n");
	l:=Length(s);
      fi;
      Print(s);
    od;
    Print("\n");
  end;

  eatblank:=function()
    while Length(l)>0 and (l[1]=' ' or l[1]='\t') do
      l:=l{[2..Length(l)]};
    od;
    while Length(l)>0 and l[Length(l)]=' ' do
      l:=l{[1..Length(l)-1]};
    od;
  end;

  # read file

  f:=InputTextFile(file);
  lines:=[];
  while not IsEndOfStream(f) do
    l:=ReadLine(f);
    if l<>fail then
      l:=Chomp(l);
      eatblank();
      Add(lines,l);
    fi;
  od;
  CloseStream(f);

  comment:=[];

  gimme:=function()
  local a,b,p;
    while Length(l)<80 and linum<Length(lines) do
      linum:=linum+1;
      a:=lines[linum];
      # comment?
      if Length(a)>1 and PositionSublist(a,"//")<>fail then
        p:=PositionSublist(a,"//");
	l:=Concatenation(l," ",a{[1..p-1]});
	eatblank();
	a:=a{[p+2..Length(a)]};
        # 1-line comment
	Add(comment,a);
	a:="%%%";
      elif Length(a)>1 and PositionSublist(a,"/*")<>fail then
        p:=PositionSublist(a,"/*");
	l:=Concatenation(l," ",a{[1..p-1]});
	eatblank();
	a:=a{[p+2..Length(a)]};
        # possibly multi-line comment
	p:=PositionSublist(a,"*/");
	while p=fail do
	  linum:=linum+1;
	  b:=lines[linum];
	  a:=Concatenation(a,"\n",b);
	  p:=PositionSublist(a,"*/");
	od;
	Append(l,a{[p+2..Length(a)]});
	a:=a{[1..p-1]};
	Add(comment,a);
	a:="%%%";
      fi;
      l:=Concatenation(l," ",a);
      #if PositionSublist(l,"two_power")<>fail then Error("ZUGU");fi;
    od;
    eatblank();
  end;

  ExpectToken:=function(arg)
  local s,o,i;
    s:=arg[1];
    if Length(arg)>1 then 
      o:=arg[2];
    else
      o:="";
    fi;
    if tok[tnum][2]<>s then
      i:=tnum;
      while tok[i][1]="#" do
	i:=i+1;
      od;
      problemarea();
      if i>tnum then
	Error("infix comment?");
      fi;
      Error("expected token ",s," not ",tok[tnum]," ",o);
    fi;
    tnum:=tnum+1;

  end;

  # tokenize, deal with comments and strings

  tok:=[];
  linum:=0;
  l:="";
  gimme();

  while linum<=Length(lines) and Length(l)>0 do
    gimme(); 
    if l[1] in CHARSIDS then
      i:=1;
      # a word-like identifier
      while l[i] in CHARSIDS do
        i:=i+1;
      od;
      a:=l{[1..i-1]};
      l:=l{[i..Length(l)]};eatblank();
      i:=Position(TOKENS,a);
      if a="end" or a="declare" or a="catch" then
        # special case of `end' token -- blank in name
	i:=1;
	while l[i] in CHARSIDS do
	  i:=i+1;
	od;
	a:=Concatenation(a," ",l{[1..i-1]});
	l:=l{[i..Length(l)]};eatblank();
	i:=Position(TOKENS,a);
        Add(tok,["K",TOKENS[i]]);
      elif a="where" then
	# where -- make a belated assignment
	Add(tok,["O",";"]);
	Add(tok,["#","#T WHERE -- MOVE BEFORE PREVIOUS LINE"]);
      elif i=fail then
	if ForAll(a,x->x in CHARS_DIGITS) then
	  Add(tok,["N",Int(a)]);
	else
	  Add(tok,["I",a]);
	fi;
      # now in K territory
      elif TOKENS[i]="cat" and l{[1,2]}=":=" then
	# fix cat:=
	a:=Concatenation(a,l{[1,2]});
	l:=l{[3..Length(l)]};
	eatblank();
	i:=Position(TOKENS,a);
        Add(tok,["O",TOKENS[i]]);
      else
        Add(tok,["K",TOKENS[i]]);
      fi;
    else
      sel:=[1..Length(TOKENS)];
      i:=0;
      repeat
	i:=i+1;
	osel:=sel;
	sel:=Filtered(sel,x->Length(TOKENS[x])>=i and TOKENS[x][i]=l[i]);
      until Length(sel)=0;
      osel:=Filtered(osel,x->Length(TOKENS[x])=i-1);
      if Length(osel)<>1 then 
	Error("nonunique");
      fi;
      if l{[1..i-1]}<>TOKENS[osel[1]] then Error("token error");fi;
      a:=TOKENS[osel[1]];
      if a="%%%" then # this is where the comment should go
        Add(tok,["#",comment[1]]);
	comment:=comment{[2..Length(comment)]};
      elif a="\"" then
        # string token
	l:=l{[i..Length(l)]};
        gimme();
	i:=1;
	while l[i]<>'"' or (i>1 and l[i-1]='\\') do
	  i:=i+1;
	od;
	Add(tok,["S",l{[1..i-1]}]);
	i:=i+1;
      else
	Add(tok,["O",a]);
      fi;
      l:=l{[i..Length(l)]};eatblank();
    fi;

  od;

  ReadID:=function()
  local i,a;
    gimme();
    i:=1;
    while l[i] in CHARSIDS do
      i:=i+1;
    od;
    a:=l{[1..i-1]};
    l:=l{[i..Length(l)]};
    Print("ID:",a,"\n");
    return a;
  end;

  ReadOP:=function()
  local i,a;
    gimme();
    i:=1;
    while l[i] in CHARSOPS do
      i:=i+1;
    od;
    a:=l{[1..i-1]};
    l:=l{[i..Length(l)]};
    Print("OP:",a,"\n");
    return a;
  end;

  # read identifier, call, function 
  ReadExpression:=function(stops)
  local obj,e,a,b,c,argus,procidf,doprocidf,op,assg,val,pre,lbinops,fcomment;

     lbinops:=Difference(BINOPS,stops);

     procidf:=function()
      local a,b;
       a:=doprocidf();
       while not "[" in stops and tok[tnum][2]="[" do
	 ExpectToken("[");
	 # postfacto indexing
	 b:=ReadExpression(["]"]);
	 ExpectToken("]");
	 a:=rec(type:="L",var:=a,at:=b);
       od;
       return a;
     end;

     doprocidf:=function()
     local a,l,e,b,c,d,eset;

      eset:=function()
	while tok[tnum][1]="#" do
	  Add(costack,tok[tnum]);
	  tnum:=tnum+1;
	od;
	return tok[tnum][2];
      end;

      e:=eset();

      if e in stops then
	a:=rec(type:="none");
      elif e="(" or e="\\(" then
	tnum:=tnum+1;
        a:=ReadExpression([")",","]);
	if tok[tnum][2]=","  then 
	  # pair, permutation
	  ExpectToken(",");
	  b:=ReadExpression([")",","]);
	  if tok[tnum][2]=")" and tok[tnum+1][2]<>"(" then
	    # pair
	    ExpectToken(")");
	    a:=rec(type:="pair",left:=a,right:=b);
	    return a;
	  else
	    # permutation
	    b:=[a.name,b.name];
	    a:=();
	    repeat
	      while tok[tnum][2]="," do
		ExpectToken(",",1);
		e:=ReadExpression([")",","]);
		Add(b,e.name);
	      od;
	      ExpectToken(")",1);
	      b:=MappingPermListList(b,Concatenation(b{[2..Length(b)]},b{[1]}));
	      a:=a*b;
	      if tok[tnum][2]="(" then
		ExpectToken("(");
		# continue
		b:=ReadExpression([")",","]);
		b:=[b.name];
	      else
		b:=fail;
	      fi;
	    until b=fail;
	    a:=rec(type:="perm",perm:=a);
	    return a;
	  fi;
	fi;
	ExpectToken(")");
        return a;
      elif e="[" then
	ExpectToken("[");
	l:=[];
	b:=fail;
	if tok[tnum][2]="]" then
	  #empty list
	  tnum:=tnum;
	else
	  repeat 
	    #tnum:=tnum+1;
	    a:=ReadExpression(["]",",",":","..","|"]);
	    if tok[tnum][2]="|" then
	      ExpectToken("|");
	      b:=a;
	      a:=fail;
	    elif tok[tnum][2]=":" then
	      ExpectToken(":");
	      l:=a; # part 1
	      if tok[tnum][1]<>"I" then
		problemarea();
		Error("weird colon expression");
	      fi;
	      a:=tok[tnum][2]; # part 2
	      tnum:=tnum+1;
	      ExpectToken("in");

	      e:=ReadExpression(["]"]); #part 2
	      ExpectToken("]");
	      a:=rec(type:=":",op:=l,var:=a,from:=e);
	      return a;
	    elif tok[tnum][2]=".." then
	      ExpectToken("..");
	      e:=ReadExpression(["]","by"]); #part 2
	      if tok[tnum][2]="by" then
		ExpectToken("by");
		a:=rec(type:="R",from:=a,to:=e,step:=ReadExpression(["]"]));
	      else
		a:=rec(type:="R",from:=a,to:=e);
	      fi;
	      ExpectToken("]");
	      return a;
	    elif tok[tnum][2]="," then
	      ExpectToken(",");
	    fi;
	    if a<>fail then
	      Add(l,a);
	    fi;
	  until tok[tnum][2]="]";

	fi;
	ExpectToken("]");
        a:=rec(type:="V",args:=l);
	if b<>fail then
	  a.force:=b;
	fi;
      elif e="<" then
	l:=[];
	repeat 
	  tnum:=tnum+1;
	  a:=ReadExpression([">",","]);
	  Add(l,a);
	until tok[tnum][2]=">";
	ExpectToken(">",6);
	a:=rec(type:="<",args:=l);
      elif e="\\[" then
	l:=[];
	repeat 
	  tnum:=tnum+1;
	  a:=ReadExpression(["\\]","]",","]);
	  Add(l,a);
	until tok[tnum][2]="\\]" or tok[tnum][2]="]";
	tnum:=tnum+1; # as ExpectToken("\\]","]");
	l:=List(l,x->x.name);
	a:=PermList(l);
	if Length(l)<>Maximum(l) or a=fail then
	  a:=rec(type:="notperm",notperm:=l);
	else
	  a:=rec(type:="perm",perm:=a);
	fi;

      elif e="[*" then
	l:=[];
	if tok[tnum+1][2]="*]" then
	  #empty list
	  tnum:=tnum+1;
	else
	  repeat 
	    tnum:=tnum+1;
	    a:=ReadExpression(["*]",","]);
	    Add(l,a);
	  until tok[tnum][2]="*]";
	fi;
	ExpectToken("*]");
	a:=rec(type:="[*",args:=l);

      elif e="{" then
	ExpectToken("{");
	l:=[];
	b:=false;
	if tok[tnum][2]="}" then
	  #empty list
	  tnum:=tnum;
	else
	  repeat 
	    a:=ReadExpression(["}",",",".."]);
	    if tok[tnum][2]=".." then
	      ExpectToken("..");
	      b:=true;
	      Add(l,a);
	      a:=ReadExpression(["}"]);
	    elif tok[tnum][2]="," then
	      ExpectToken(",");
	    fi;
	    Add(l,a);
	  until tok[tnum][2]="}";
	fi;
	ExpectToken("}");
	if b=true then
	  a:=rec(type:="R",from:=l[1],to:=l[2]);
	else
	  a:=rec(type:="{",args:=l);
	fi;

      elif e="sub" then
	# substructure
	ExpectToken("sub");
	ExpectToken("<");
	e:=ReadExpression(["|"]);
	ExpectToken("|");
	l:=[];
	repeat
	  if tok[tnum][2]="," then
	    ExpectToken(",");
	  fi;
	  a:=ReadExpression([">",","]);
	  Add(l,a);
	until tok[tnum][2]=">";
	ExpectToken(">",2);
	a:=rec(type:="sub",within:=e,span:=l);
      elif e="recformat" then
	ExpectToken("recformat");
	ExpectToken("<");
	while tok[tnum][2]<>">" do
	  tnum:=tnum+1;
	od;
	ExpectToken(">",3);
	a:=rec(type:="S",name:="unneeded record format");
      elif e="rec" then
	ExpectToken("rec");
	ExpectToken("<");
	e:=ReadExpression(["|"]);
	ExpectToken("|");
	assg:=[];
	if tok[tnum][2]<>">" then
	  repeat
	    if tok[tnum][2]="," then tnum:=tnum+1;fi;
	    b:=ReadExpression([":="]);
	    Add(assg,b);
	    ExpectToken(":=");
	    b:=ReadExpression([",",">"]);
	    Add(assg,b);
	  until tok[tnum][2]=">";
	fi;
	ExpectToken(">",4);
	a:=rec(type:="rec",format:=e,assg:=assg);

      elif e="forall" or e="exists" then
	ExpectToken(e);
        if tok[tnum][2]="(" then
	  ExpectToken("(");
	  d:=ReadExpression([")"]);
	  ExpectToken(")");
	else
	  d:=false; 
	fi;
	ExpectToken("{");
	a:=ReadExpression([":",","]);
	ExpectToken(":");
	a:=ReadExpression(["in"]);
	ExpectToken("in");
	b:=ReadExpression(["|"]);
	ExpectToken("|");
	c:=ReadExpression(["}"]);
	ExpectToken("}");
        a:=rec(type:=e,var:=a,from:=b,cond:=c,varset:=d);
      elif e="hom" then
        ExpectToken("hom");
        ExpectToken("<","hom");
	a:=ReadExpression(["->"]);
	ExpectToken("->");
	b:=ReadExpression(["|"]);
	ExpectToken("|");
	a:=rec(type:="hom",domain:=a,codomain:=b);
	c:=ReadExpression([":->",">",","]);
	if tok[tnum][2]=">" then
	  # image defn
	  a.kind:="images";
	  a.images:=c;
	elif tok[tnum][2]=":->" then
	  # fct defn.
	  ExpectToken(":->");
	  d:=ReadExpression([">"]);
	  a.kind:="fct";
	  a.var:=c;
	  a.expr:=d;
	elif tok[tnum][2]="," then
	  # gens, imgs
	  a.kind:="genimg";
	  a.gens:=c;
	  ExpectToken(",");
	  d:=ReadExpression([">"]);
	  a.images:=d;
	else
	  problemarea();
	  Error(tok[tnum][2], " not yet done");
	fi;
	ExpectToken(">","endhom");


      elif not (tok[tnum][1] in ["I","N","S"] or e="$") then
	tnum:=tnum+1;
	if e in ["-","#"] then
	  a:=rec(type:=Concatenation("U",e),arg:=procidf());
	elif e="+" then
	  # (spurious) +
	  a:=procidf();
	elif e="&" then

	  while tok[tnum][1]="#" do
	    Add(costack,tok[tnum]);
	    tnum:=tnum+1;
	  od;
	  e:=eset();

	  tnum:=tnum+1;
	  a:=ReadExpression(Union([",",";"],stops));
	  a:=rec(type:="&",op:=e,arg:=a);
	elif e="~" or e="not" or e="assigned" or e="eval" then
          a:=ReadExpression(Concatenation(stops,["and","or"]));
	  a:=rec(type:=Concatenation("U",e),arg:=a);
	else
	  problemarea();
	  Error("other unary ",e);
	fi;

      else
	# identifier/number
	if e="$" then
	  a:=rec(type:="I",name:="$");
	else
	  a:=rec(type:=tok[tnum][1],name:=tok[tnum][2]);
	fi;
	tnum:=tnum+1;

	e:=eset();

	while not (e in stops or e in lbinops) do
	  if e="select" then
	    a:=doselect(a,stops);
	  elif e="(" then
	    # fct call
	    assg:=[];
	    tnum:=tnum+1;
	    argus:=[];
	    while tok[tnum][2]<>")"  and tok[tnum][2]<>":" do
	      b:=ReadExpression([",",")",":"]);
	      Add(argus,b);
	      if tok[tnum][2]="," then
		ExpectToken(",");
	      fi;
	    od;
	    if tok[tnum][2]=":" then
	      ExpectToken(":");
	      while tok[tnum][2]<>")" do
		Add(assg,ReadExpression([":="]));
		ExpectToken(":=");
		Add(assg,ReadExpression([")",","]));
		if tok[tnum][2]="," then
		  ExpectToken(",");
		fi;
	      od;
	    fi;

	    ExpectToken(")");
	    if a.type="I" and not a.name in locals then
	      AddSet(globvars,a.name);
	    fi;
	    a:=rec(type:="C",fct:=a,args:=argus);
	    if Length(assg)>0 then
	      a.type:="CA";
	      a.assg:=assg;
	    fi;
	  elif e="[" then
	    # index
	    tnum:=tnum+1;
	    b:=ReadExpression(["]",","]);
	    if tok[tnum][2]="," then
	      # array indexing -- translate to iterated index by opening a parenthesis and keeping
	      # position
	      tok[tnum]:=["O","["];
	    else
	      ExpectToken("]");
	    fi;
	    a:=rec(type:="L",var:=a,at:=b);
	  elif e="<" then
	    pre:=a;
	    # <> structure
	    tnum:=tnum+1;
	    b:=[];
	    repeat
	      a:=ReadExpression(["|",","]);
	      Add(b,a);
	      if tok[tnum][2]="," then
	        ExpectToken(",");
	      else
	        a:=fail;
	      fi;
	    until a=fail;

	    ExpectToken("|");
	    c:=[];
	    repeat
	      a:=ReadExpression([",",">"]);
	      Add(c,a);
	      if tok[tnum][2]="," then
	        ExpectToken(",");
	      else
		a:=fail;
	      fi;
            until a=fail;
	    if tok[tnum][2]=":" then
	      ExpectToken(":");
	      #make rest of assignment a comment
	      e:=tnum;
	      while tok[e][2]<>">" do
		e:=e+1;
	      od;
	      tok:=Concatenation(tok{[1..tnum-1]},tok{[e]},
	          [["#",Concatenation(List(tok{[tnum..e-1]},x->String(x[2])))]],
		  tok{[e+1..Length(tok)]});
	    fi;
	    ExpectToken(">",5);
	    a:=rec(type:="<>",op:=pre,left:=b,right:=c);

	  elif e="," and stops=[")"] then
	    # expression '(P,C)'
	    ExpectToken(",");
	    b:=ReadExpression(stops);
	    a:=rec(type:="pair",left:=a,right:=b);
	  else
	    problemarea();
	    Error("eh!");
	  fi;

	  e:=eset();
	od;
      fi;
      return a;
    end;

    if tok[tnum]=["K","function"] or tok[tnum]=["K","intrinsic"] 
      or tok[tnum]=["K","procedure"] then
      # function
      tnum:=tnum+1;
      ExpectToken("(");
      argus:=[];
      while tok[tnum][2]<>")" and tok[tnum][2]<>":" do
        if tok[tnum][1]="I" then
	  Add(argus,tok[tnum][2]);
	  tnum:=tnum+1;
	  if tok[tnum][2]="::" then
	    ExpectToken("::");
	    if tok[tnum][1]="I" then
	      tnum:=tnum+1; # type identifier
	    else
	      problemarea();
	      Error("don't understand ::");
	    fi;
	  fi;
	  if tok[tnum][2]="," then 
	    tnum:=tnum+1; # multiple
	  fi;
        elif tok[tnum][2]="~" then
	  ExpectToken("~");
	  a:=Concatenation("TILDEVAR~",tok[tnum][2]);
	  Add(argus,a);
	  if tok[tnum][2]="," then 
	    tnum:=tnum+1; # multiple
	  fi;
	fi;
      od;
      assg:=false;
      if tok[tnum][2]=":" then
	ExpectToken(":");
	assg:=[];
	repeat
	  Add(assg,ReadExpression([":="]));
	  ExpectToken(":=");
	  Add(assg,ReadExpression([")",","]));
	  if tok[tnum][2]="," then
	    b:=false;
	    ExpectToken(",");
	  else
	    b:=true;
	  fi;
	until b;
	    
      fi;
      ExpectToken(")");
      fcomment:=fail;
      if tok[tnum]=["O","->"] then
	ExpectToken("->");
	if tok[tnum][1]<>"I" then
	  problemarea();
	  Error("-> unexpected");
	fi;
	a:="-> ";
	repeat
	  a:=Concatenation(a,",",tok[tnum][2]," ");
	  tnum:=tnum+1;
          if tok[tnum][2]="," then
	    tnum:=tnum+1;
	  fi;
        until tok[tnum][2]="{";
	ExpectToken("{");
	while tok[tnum][2]<>"}" do
	  Add(a,' ');
	  if not IsString(tok[tnum][2]) then
	    Append(a,String(tok[tnum][2]));
	  else
	    Append(a,tok[tnum][2]);
	  fi;
	  tnum:=tnum+1;
	od;
	ExpectToken("}");
	fcomment:=a;
      fi;
      if tok[tnum][2]=";" then
	#spurious ; after function definition
	tnum:=tnum+1;
      fi;

      a:=ReadBlock(["end function","end intrinsic","end procedure"]:inner);
      tnum:=tnum+1; # do end .... token

      a:=rec(type:="F",args:=argus,locals:=a[1],block:=a[2]);
      if fcomment<>fail then
        a.comment:=fcomment;
      fi;
      if assg<>false then
	a.type:="FA";
	a.assg:=assg;
      fi;

      return a;

    # todo: parentheses
    else 
      a:=procidf();
      while tok[tnum][2] in lbinops do
        op:=tok[tnum][2];
	tnum:=tnum+1;

	b:=procidf();
	a:=rec(type:=Concatenation("B",op),left:=a,right:=b);
      od;
      return a;

    fi;
  end;

  doselect:=function(arg)
  local cond,yes,no,stops;
    cond:=arg[1];
    if Length(arg)>1 then
      stops:=arg[2];
    else
      stops:=[];
    fi;
    ExpectToken("select");
    yes:=ReadExpression(["else"]);
    ExpectToken("else");
    no:=ReadExpression(Concatenation([";","select"],stops));
    if tok[tnum][2]="select" then
      no:=doselect(no,stops);
    fi;
    return rec(type:="select",cond:=cond,yescase:=yes,nocase:=no);
  end;

  ReadBlock:=function(endkey)
  local l,e,a,aif,b,c,locals,kind,i;
    l:=[];
    locals:=[];

    while tnum<=Length(tok) and
      (endkey=false or ForAll(endkey,x->tok[tnum]<>["K",x])) do
      if Length(costack)>0 then
	for e in costack do
	  Add(l,rec(type:="co",text:=e[2]));
	od;
	costack:=[];
      fi;
      e:=tok[tnum];
      tnum:=tnum+1;
      if e[2]="time" then
	# timing....
	Add(l,rec(type:="co",text:="Next line is timing"));
	e:=tok[tnum];
	tnum:=tnum+1;
      fi;

      if e[1]="#" then
	Add(l,rec(type:="co",text:=e[2]));
      elif e[1]="K" then
	# keyword

	if e[2]="if" then
	  a:=ReadExpression(["then"]);
	  ExpectToken("then");
	  b:=ReadBlock(["else","end if","elif"]:inner);
	  locals:=Union(locals,b[1]);
	  a:=rec(type:="if",cond:=a,block:=b[2]);
	  Add(l,a);
	  while tok[tnum][2]="elif" do
	    ExpectToken("elif");
	    c:=ReadExpression(["then"]);
	    ExpectToken("then");
	    b:=ReadBlock(["else","end if","elif"]:inner);
	    locals:=Union(locals,b[1]);
	    a.elseblock:=[rec(type:="if",cond:=c,block:=b[2])];
	    a:=a.elseblock[1]; # make elif an iterated else if
	  od;
	  if tok[tnum][2]="else" then
	    ExpectToken("else");
	    b:=ReadBlock(["end if"]:inner);
	    locals:=Union(locals,b[1]);
	    a.elseblock:=b[2];
	  fi;
	  ExpectToken("end if");
	  ExpectToken(";",1);

	elif e[2]="try" then
	  b:=ReadBlock(["catch err","end try"]:inner);
	  locals:=Union(locals,b[1]);
	  a:=rec(type:="try",block:=b[2]);
	  Add(l,a);
	  if tok[tnum][2]="catch err" then
	    ExpectToken("catch err");
	    b:=ReadBlock(["end try"]);
	    locals:=Union(locals,b[1]);
	    a.errblock:=b[2];
	  fi;
	  ExpectToken("end try");
	  ExpectToken(";",1);



	elif e[2]="while" then
	  a:=ReadExpression(["do"]);
	  ExpectToken("do");
	  b:=ReadBlock(["end while"]:inner);
	  locals:=Union(locals,b[1]);
	  a:=rec(type:="while",cond:=a,block:=b[2]);
	  ExpectToken("end while");
	  ExpectToken(";",2);
	  Add(l,a);
	elif e[2]="for" then
	  a:=rec(type:="I",name:=tok[tnum][2]);
	  tnum:=tnum+1;
	  if tok[tnum][2]="in" then
	    ExpectToken("in");
	    c:=ReadExpression(["do"]);
	  else
	    ExpectToken(":=");
	    b:=ReadExpression(["to"]);
	    ExpectToken("to");
	    c:=ReadExpression(["do","by"]);
	    c:=rec(type:="R",from:=b,to:=c);
	  fi;

	  ExpectToken("do");
	  b:=ReadBlock(["end for"]:inner);
	  locals:=Union(locals,b[1]);
      #if a.name="cl" then Error("rof");fi;
	  a:=rec(type:="for",var:=a,from:=c,block:=b[2]);
	  ExpectToken("end for");
	  ExpectToken(";",3);
	  Add(l,a);

	elif e[2]="assert" then
	  a:=ReadExpression([";"]);
	  ExpectToken(";",4);
	  a:=rec(type:="assert",cond:=a);
	  Add(l,a);
        elif e[2]="require" then
	  a:=ReadExpression([":"]);
	  ExpectToken(":");
	  c:=ReadExpression([";"]);
	  ExpectToken(";","4b");
	  a:=rec(type:="require",cond:=a,mess:=c);
	  Add(l,a);
	elif e[2]="repeat" then
	  b:=ReadBlock(["until"]);
	  ExpectToken("until");
	  locals:=Union(locals,b[1]);
	  a:=ReadExpression([";"]);
	  a:=rec(type:="repeat",cond:=a,block:=b[2]);
	  Add(l,a);
	  ExpectToken(";",5);

	elif e[2]="return" then
	  a:=[];
	  while tok[tnum][2]<>";" do
	    Add(a,ReadExpression([",",";"]));
	    if tok[tnum][2]="," then
	      tnum:=tnum+1;
	    fi;
	  od;
	  ExpectToken(";",6);
	  Add(l,rec(type:="return",values:=a));
	elif e[2]="vprint" or e[2]="error" or e[2]="print" or e[2]="printf"
	  or e[2]="vprintf" then
	  if e[2]="vprint" or e[2]="vprintf" then
	    kind:="Info";
	    a:=ReadExpression([":"]);
	    ExpectToken(":");
	  elif e[2]="print" or e[2]="printf" then
	    kind:="Print";
	    a:=false;
	  else 
	    a:=false;
	    kind:="error";
	  fi;
	  c:=[];
          repeat
	    b:=ReadExpression([",",";"]);
	    Add(c,b);
	    if tok[tnum][2]="," then
	      ExpectToken(",");
	    fi;
	  until tok[tnum][2]=";";

	  #if tok[tnum][1]="S" then
	  #  c[1]:=tok[tnum][2];
	  #fi;
	  #if tok[tnum+1][2]="," then
	  #  # there are more arguments
	  #  tnum:=tnum+1;
	  #  repeat
	  #    tnum:=tnum+1;
	  #    b:=ReadExpression([",",";"]);
	  #    Add(c,b);
	  #    e:=tok[tnum][2];
	  #  until e=";";
	  #else
	  #  tnum:=tnum+1;
	  #fi;
	  ExpectToken(";",7);

	  Add(l,rec(type:=kind,class:=a,values:=c));

	elif e[2]="freeze" then
	  ExpectToken(";",8);
	elif e[2]="import" then
	  b:=tok[tnum][2];
	  tnum:=tnum+1;
	  ExpectToken(":");
	  c:=[];
	  repeat
	    a:=ReadExpression([",",";"]);
	    Add(c,a);
	    if tok[tnum][2]="," then
	      ExpectToken(",");
	    else
	      a:=fail;
	    fi;
	  until a=fail;
	  b:=Concatenation("import from ",b,":\n");
	  for i in [1..Length(c)] do
	    if i>1 then
	      Append(b,", ");
	    fi;
	    Append(b,c[i].name);
	  od;
	  Add(l,rec(type:="co",text:=b));
	  ExpectToken(";",9);
	elif e[2]="forward" or e[2]="declare verbose"
	  or e[2]="declare attributes" then
	  if e[2]="forward" then b:="Forward";
	  elif e[2]="declare verbose" then b:="Verbose";
	  elif e[2]="declare attributes" then b:="Attribute";
	  fi;
	  repeat
	    a:=ReadExpression([";",",",":"]);
	    if tok[tnum][2]=":" then
	      # skip type
	      ExpectToken(":");
	      ReadExpression([";",","]);
	    fi;
	    Add(l,rec(type:="co",
	      text:=Concatenation(b," declaration of ",String(a.name))));
            if tok[tnum][2]="," then
	      ExpectToken(",",10);
	    fi;
	  until tok[tnum][2]=";";
	  ExpectToken(";",10);
	elif e[2]="function" or e[2]="intrinsic" or e[2]="procedure" then
	  tnum:=tnum-1;
	  # rewrite: function Bla 
	  # to Bla:=function
	  tok:=Concatenation(tok{[1..tnum-1]},tok{[tnum+1]},[["O",":="]],
	    tok{[tnum]},tok{[tnum+2..Length(tok)]});
	elif e[2]="local" then
	  c:=[];
	  repeat
	    a:=ReadExpression([",",";"]);
	    Add(c,a);
	    if tok[tnum][2]="," then
	      ExpectToken(",");
	    else
	      a:=fail;
	    fi;
	  until a=fail;
	  ExpectToken(";",11);
	  for a in c do
	    AddSet(locals,a.name);
	  od;

        elif e[2]="delete" then
	  a:=ReadExpression([";"]);
	  Add(l,rec(type:="A",left:=a,right:=rec(type:="S",name:="delete")));
	  ExpectToken(";",11/2);
	elif e[2]="break" then
	  a:=ReadExpression([";"]);
	  Add(l,rec(type:="break",var:=a));
	  ExpectToken(";",11/3);

	elif e[2]="case" then
	  e:=ReadExpression([":"]); # variable
	  ExpectToken(":");
	  c:=[];
	  while tok[tnum][2]="when" do
	    ExpectToken("when");
	    a:=ReadExpression([":"]);
	    ExpectToken(":");
	    b:=ReadBlock(["when","end case","else"]);
	    locals:=Union(locals,b[1]);
	    Add(c,[a,b[2]]);
	  od;
	  a:=rec(type:="case",test:=e,cases:=c);
	  if tok[tnum][2]="else" then
	    ExpectToken("else");
	    b:=ReadBlock(["end case"]);
	    locals:=Union(locals,b[1]);
            a.elsecase:=b[2];
	  fi;
	  ExpectToken("end case");
	  Add(l,a);
	else
	  problemarea();
	  Error("other keyword ",e);
	fi;
      elif e[1]="I" then
	tnum:=tnum-1;
	a:=ReadExpression([",",":=","-:=","+:=","*:=","cat:=",";","<"]);
	if a.type="I" then
	  AddSet(locals,a.name);
	fi;
	e:=tok[tnum];
	tnum:=tnum+1;
	if e[1]<>"O" then 
	  problemarea();
	  Error("missing separator");
	fi;
	if e[2]="<" then
	  # implicit generator assignment
	  c:=[];
	  repeat
	    e:=ReadExpression([",",">"]);
	    Add(c,e);
	    if tok[tnum][2]="," then
	      ExpectToken(",","impgen");
	    fi;
	  until tok[tnum][2]=">";
	  ExpectToken(">","impgen");
	  e:=tok[tnum];
	  tnum:=tnum+1;
	else
	  c:=fail;
	fi;

	if e[2]="," then 
	  b:=[a];
	  while e[2]="," do
	    a:=ReadExpression([",",":="]);
	    Add(b,a);
	    e:=tok[tnum];
	    tnum:=tnum+1;
	  od;
	  a:=ReadExpression([";"]);
	  Add(l,rec(type:="Amult",left:=b,right:=a));
	  ExpectToken(";",13);
	elif e[2]=":=" then
	  # assignment
	  b:=ReadExpression([",",":=",";","select"]);

	  if tok[tnum][2]="select" then
	    b:=doselect(b);
	  fi;
	  a:=rec(type:="A",left:=a,right:=b);
	  if c<>fail then
	    a.implicitassg:=c;
	  fi;
	  Add(l,a);
	  ExpectToken(";",14);
          if ValueOption("inner")<>true and a.type="I" then
	    Print("> ",a.name," <\n");
	    AddSet(defines,a.name);
	  fi;
	elif e[2]="-:=" then
	  b:=ReadExpression([";"]);
	  ExpectToken(";",15);
	  Add(l,rec(type:="A-",left:=a,right:=b));
	elif e[2]="+:=" then
	  b:=ReadExpression([";"]);
	  ExpectToken(";",16);
	  Add(l,rec(type:="A+",left:=a,right:=b));
	elif e[2]="*:=" then
	  b:=ReadExpression([";"]);
	  ExpectToken(";");
	  Add(l,rec(type:="A*",left:=a,right:=b));
	elif e[2]="cat:=" then
	  b:=ReadExpression([";"]);
	  ExpectToken(";");
	  Add(l,rec(type:="Acat",left:=a,right:=b));
	elif e[2]=";" then
	  a.line:=true; # only command in line
	  Add(l,a);
	else
	  problemarea();
	  Error("anders");
	fi;
      elif e[1]="S" then
	if tok[tnum][2]="," then
	  # multi-argument warning -- turn into print statement
	  tok:=Concatenation(tok{[1..tnum-2]},["dummy",["K","print"]],tok{[tnum-1..Length(tok)]});
	else
	  # string, print warning
	  Add(l,rec(type:="W",text:=e[2]));
	  ExpectToken(";",20);
	fi;
      elif e[2]=";" then
	# empty command?
      else 
	problemarea();
	Error("cannot deal with token ",e);
      fi;
    od;

    return [locals,l];
  end;

  costack:=[];
  tnum:=1; # indicate in token list

  # actual work
  a:=ReadBlock(false);

  return rec(used:=globvars,defines:=defines,code:=a[2]);

end;

GAPOutput:=function(l,f)
local i,doit,printlist,doitpar,indent,START,t,mulicomm;

   START:="";
   indent:=function(n)
     n:=n*2;
     if n<0 then START:=START{[1..Length(START)+n]};
     else Append(START,ListWithIdenticalEntries(n,' '));fi;
   end;

   printlist:=function(arg)
   local l,i,first;
    l:=arg[1];
    first:=true;
    for i in l do
      if not first then
	FilePrint(f,",");
      else
	first:=false;
      fi;
      if IsRecord(i) then
	doit(i);
      else
	if Length(arg)>1 then
	  FilePrint(f,"\"",i,"\"");
	else
	  FilePrint(f,i);
	fi;
      fi;
    od;
  end;

  mulicomm:=function(f,str)
  local i,s,p;
    s:=Length(START);
    p:=Position(str,'\n');
    while Length(str)+s>75 or p<>fail do
      i:=Minimum(75-s,p);
      while str[i]<>' ' and str[i]<>'\n' do
        i:=i-1;
      od;
      FilePrint(f,"#  ",str{[1..i-1]},"\n",START);
      str:=str{[i+1..Length(str)]};
      if p<>fail then
	p:=Position(str,'\n');
      fi;
    od;
    if Length(str)>0 then
      FilePrint(f,"#  ",str,"\n",START);
    else
      FilePrint(f,"\n",START);
    fi;
  end;

  doitpar:=function(r,usepar)
    if usepar and r.type<>"I" and r.type<>"N" and r.type<>"S" then
      FilePrint(f,"(");
      doit(r);
      FilePrint(f,")");
    else
      doit(r);
    fi;
  end;

  # doit -- main node processor
  doit:=function(node)
  local t,i,a,b;
    t:=node.type;
    if t="A" then
      doit(node.left);
      FilePrint(f,":=");
      doit(node.right);
      FilePrint(f,";\n",START);
      if IsBound(node.implicitassg) then
	FilePrint(f,"# Implicit generator Assg from previous line.\n",START);
	for i in [1..Length(node.implicitassg)] do
	  doit(node.implicitassg[i]);
	  FilePrint(f,":=");
	  doit(node.left);
	  FilePrint(f,".",i,"\n",START);
	od;
      fi;
    elif t[1]='A' and Length(t)=2 and t[2] in "+-*" then
      doit(node.left);
      FilePrint(f,":=");
      doit(node.left);
      FilePrint(f,t{[2]});
      doit(node.right);
      FilePrint(f,";\n",START);
    elif t="Acat" then
      doit(node.left);
      FilePrint(f,":=Concatenation(");
      doit(node.left);
      FilePrint(f,",");
      doit(node.right);
      FilePrint(f,");\n",START);

    elif t="Amult" then
      FilePrint(f,"# =v= MULTIASSIGN =v=\n",START);
      a:=node.left[Length(node.left)];
      doit(a);
      FilePrint(f,":=");
      doit(node.right);
      FilePrint(f,";\n",START);
      for i in [1..Length(node.left)] do
        doit(node.left[i]);
	FilePrint(f,":=");
	doit(a);
	FilePrint(f,".val",String(i),";\n",START);
      od;
      FilePrint(f,"# =^= MULTIASSIGN =^=\n",START);

    elif t="I" or t="N" then
      FilePrint(f,node.name);
    elif t="co" then
      # commentary
      mulicomm(f,node.text);
#      a:=node.text;
#      i:=Position(a,'\n');
#      while i<>fail do
#	FilePrint(f,"\n",START);
#	FilePrint(f,"# ",a{[1..i]},START);
#	a:=a{[i+1..Length(a)]};
#	i:=Position(a,'\n');
#      od;
#
#      FilePrint(f,"#  ",a,"\n",START);
    elif t="W" then
      # warning
      FilePrint(f,"Info(InfoWarning,1,");
      if Length(node.text)>40 then
	FilePrint(f,"\n",START,"  ");
      fi;
      FilePrint(f,"\"",node.text,"\");\n",START);
    elif t="Info" then
      # info
      FilePrint(f,"Info(Info");
      doit(node.class);
      FilePrint(f,",1,");
      printlist(node.values,"\"");
      FilePrint(f,");\n",START);
    elif t="Print" then
      # info
      FilePrint(f,"Print(");
      printlist(node.values,"\"");
      FilePrint(f,");\n",START);

    elif t="return" then
      if Length(node.values)=1 then
        FilePrint(f,"return ");
	doit(node.values[1]);
	FilePrint(f,";\n",START);
      else
	FilePrint(f,"return rec(");
	for i in [1..Length(node.values)] do
	  if i>1 then FilePrint(f,",\n",START,"  ");fi;
	  FilePrint(f,"val",String(i),":=");
	  doit(node.values[i]);
	od;
	FilePrint(f,");\n",START);
      fi;
    elif t[1]='F' then
      # function
      FilePrint(f,"function(");
      printlist(node.args);
      FilePrint(f,")\n",START);

      if IsBound(node.comment) then
	mulicomm(f,node.comment);
      fi;

      indent(1);
      if Length(node.locals)>0 then
        FilePrint(f,"local ");
	printlist(node.locals);
	FilePrint(f,";\n",START);
      fi;
      if t="FA" then
	for i in [1,3..Length(node.assg)-1] do
	  doit(node.assg[i]);
	  FilePrint(f,":=ValueOption(\"");
	  doit(node.assg[i]);
	  FilePrint(f,"\");\n",START,"if ");
	  doit(node.assg[i]);
	  FilePrint(f,"=fail then\n",START,"  ");
	  doit(node.assg[i]);
	  FilePrint(f,":=");
	  doit(node.assg[i+1]);
	  FilePrint(f,";\n",START,"fi;\n",START);
	od;

      fi;
      for i in node.block do
	doit(i);
      od;
      FilePrint(f,"\n");
      indent(-1);
      FilePrint(f,START,"end;\n",START);
    elif t="S" then
      FilePrint(f,"\"");
      FilePrint(f,node.name);
      FilePrint(f,"\"");
    elif t="C" or t="CA" then
      # fct. call
      doit(node.fct);
      FilePrint(f,"(");
      printlist(node.args);
      if t="CA" then
        FilePrint(f,":");
	for i in [1,3..Length(node.assg)-1] do
	  if i>1 then
	    FilePrint(f,",");
	  fi;
	  doit(node.assg[i]);
	  FilePrint(f,":=");
	  doit(node.assg[i+1]);
	od;
      fi;
      if IsBound(node.line) then
	FilePrint(f,");\n",START);
      else
	FilePrint(f,")");
      fi;
    elif t="L" then
      # list access
      doit(node.var);
      FilePrint(f,"[");
      doit(node.at);
      FilePrint(f,"]");

    elif t="V" then
      FilePrint(f,"[");
      printlist(node.args);
      FilePrint(f,"]");
    elif t="{" then
      # Set
      FilePrint(f,"Set([");
      printlist(node.args);
      FilePrint(f,"])");
    elif t="perm" then
      # permutation
      FilePrint(f,node.perm);
    elif t="notperm" then
      t:=UnFlat(node.notperm);
      if t=fail then
	t:=node.notperm;
      fi;
      FilePrint(f,"NOTPERM",t,"\n");
    elif t="[*" then
      FilePrint(f,"# [*-list:\n",START,"[");
      printlist(node.args);
      FilePrint(f,"]");
    elif t="R" then
      FilePrint(f,"[");
      doit(node.from);
      if IsBound(node.step) then
	FilePrint(f,",");
	doit(node.from);
	FilePrint(f,"+");
	doit(node.step);
      fi;
      FilePrint(f,"..");
      doit(node.to);
      FilePrint(f,"]");
    elif t="pair" then
      FilePrint(f,"Tuple([");
      doit(node.left);
      FilePrint(f,",");
      doit(node.right);
      FilePrint(f,"])");
    elif t="B!" then
      doit(node.right);
      FilePrint(f,"*FORCEOne(");
      doit(node.left);
      FilePrint(f,")");
    elif t="B`" then
      doit(node.right);
      FilePrint(f,"Attr(");
      doit(node.left);
      FilePrint(f,")");
    elif t="Bdiv" then
      FilePrint(f,"QuoInt(");
      doit(node.left);
      FilePrint(f,",");
      doit(node.right);
      FilePrint(f,")");
    elif t="Bcat" then
      FilePrint(f,"Concatenation(");
      doit(node.left);
      FilePrint(f,",");
      doit(node.right);
      FilePrint(f,")");
    elif t[1]='B' then
      # binary op
      i:=t{[2..Length(t)]};
      a:=i;
      if a in FAKEBIN then
	b:=false;
	if a="meet" then
	  a:="Intersection";
	elif a="join" then
	  a:="Union";
	elif a="cat" then
	  a:="Concatenation";
	elif a="diff" then
	  a:="Difference";
	elif a="subset" then
	  a:="IsSubset";
	  b:=true;
	else
	  Error("Can't do ",a,"yet\n");
	fi;

	FilePrint(f,a,"(");
	if b then
	  doit(node.right);
	  FilePrint(f,",");
	  doit(node.left);
	else
	  doit(node.left);
	  FilePrint(f,",");
	  doit(node.right);
	fi;
	FilePrint(f,")");
      else
	doitpar(node.left,a in PAROP);
	if i="ne" or i="cmpne" then
	  i:="<>";
	elif i="eq" or i="cmpeq" or i="=" then
	  i:="=";
	elif i="and" then
	  i:=" and ";
	elif i="or" then
	  i:=" or ";
	elif i="mod" then
	  i:=" mod ";
	elif i="in" then
	  i:=" in ";
	elif i="gt" then
	  i:=" > ";
	elif i="ge" then
	  i:=" >= ";
	elif i="lt" then
	  i:=" < ";
	elif i="le" then
	  i:=" <= ";
	fi;
	FilePrint(f,i);
	doitpar(node.right,a in PAROP);
      fi;

    elif t="U#" then
      FilePrint(f,"Size(");
      doit(node.arg);
      FilePrint(f,")");
    elif t="U-" then
      FilePrint(f,"-");
      doit(node.arg);
    elif t="U~" then
      FilePrint(f,"~TILDE~");
      doit(node.arg);
    elif t="Unot" then
      FilePrint(f,"not ");
      doit(node.arg);
    elif t="Uassigned" then
      FilePrint(f,"Has");
      doit(node.arg);
    elif t="Ueval" then
      FilePrint(f,"#EVAL\n",START,"    ");
      doit(node.arg);

    elif t="<>" then
      FilePrint(f,"Sub");
      doit(node.op);
      FilePrint(f,"(");
      if Length(node.left)=1 then
        doit(node.left[1]);
      else
	printlist(node.left);
      fi;
      FilePrint(f,",[");
      printlist(node.right);
      FilePrint(f,"])");
    elif t="<" then
      FilePrint(f,"Span(");
      printlist(node.args);
      FilePrint(f,")");
    elif t=":" then
      FilePrint(f,"List(");
      doit(node.from);
      FilePrint(f,",",node.var,"->");
      doit(node.op);
      FilePrint(f,")");
    elif t="&" then
      if node.op="+" then
        FilePrint(f,"Sum(");
      elif node.op="*" then
        FilePrint(f,"Product(");
      elif node.op="cat" then
        FilePrint(f,"Concatenation(");
      else
        Error("operation ",node.op," not yet done");
      fi;
      doit(node.arg);
      FilePrint(f,")");
    elif t="rec" then
      FilePrint(f,"rec(");
      indent(1);
      for i in [1,3..Length(node.assg)-1] do
	if i>1 then
	  FilePrint(f,",\n",START);
	fi;
	FilePrint(f,node.assg[i].name,":=");
	doit(node.assg[i+1]);
      od;
      indent(-1);
      FilePrint(f,")");
    elif t="if" then
      FilePrint(f,"if ");
      doit(node.cond);
      indent(1);
      FilePrint(f," then\n",START);
      for i in node.block do
	doit(i);
      od;
      indent(-1);

      if IsBound(node.elseblock) then
	FilePrint(f,"\b\belse\n");
	indent(1);
	FilePrint(f,START);
	for i in node.elseblock do
	  doit(i);
	od;
	indent(-1);
      fi;
      FilePrint(f,"\b\bfi;\n",START);
    elif t="try" then
      FilePrint(f,"# TODO: try \n");
    elif t="while" then
      FilePrint(f,"while ");
      doit(node.cond);
      indent(1);
      FilePrint(f," do\n",START);
      for i in node.block do
	doit(i);
      od;
      indent(-1);
      #FilePrint(f,"\n");
      FilePrint(f,"\b\bod;\n",START);
    elif t="for" then
      FilePrint(f,"for ");
      doit(node.var);
      FilePrint(f," in ");
      doit(node.from);
      indent(1);
      FilePrint(f," do\n",START);
      for i in node.block do
	doit(i);
      od;
      indent(-1);
      FilePrint(f,"\b\bod;\n",START);

    elif t="repeat" then
      indent(1);
      FilePrint(f,"repeat\n",START);
      for i in node.block do
	doit(i);
      od;
      indent(-1);
      FilePrint(f,"\n",START);
      FilePrint(f,"until ");
      doit(node.cond);
      FilePrint(f,";\n",START);
    elif t="case" then
      for i in [1..Length(node.cases)] do
	if i>1 then
	  FilePrint(f,"\b\bel");
	fi;
	FilePrint(f,"if ");
	doit(node.test);
	FilePrint(f,"=");
	doit(node.cases[i][1]);
	indent(1);
	FilePrint(f," then\n",START);
	for b in node.cases[i][2] do
	  doit(b);
	od;
	indent(-1);
      od;
      if IsBound(node.elsecase) then
	FilePrint(f,"\b\belse\n");
	indent(1);
	FilePrint(f,START);
	for i in node.elsecase do
	  doit(i);
	od;
	indent(-1);
      fi;
      FilePrint(f,"\b\bfi;\n",START);
    elif t="sub" then
      FilePrint(f,"SubStructure(");
      doit(node.within);
      FilePrint(f,",");
      for i in [1..Length(node.span)] do
	if i=2 then
	  FilePrint(f,",#TODO CLOSURE\n",START,"  ");
	fi;

	doit(node.span[i]);
      od;
      FilePrint(f,")");


    elif t="assert" then
      FilePrint(f,"Assert(1,");
      doit(node.cond);
      FilePrint(f,");\n",START);

    elif t="require" then
      FilePrint(f,"if not ");
      doit(node.cond);
      indent(1);
      FilePrint(f,"then\n",START,"Error(");
      doit(node.mess);
      indent(-1);
      FilePrint(f,");\n",START);

    elif t="select" then
      FilePrint(f,"SELECT(");
      doit(node.cond);
      FilePrint(f," then ");
      doit(node.yescase);
      FilePrint(f," else ");
      doit(node.nocase);
      FilePrint(f,")");
    elif t="hom" then
      if node.kind="images" then
        FilePrint(f,"GroupHomomorphismByImages(");
	doit(node.domain);
	FilePrint(f,",");
	doit(node.codomain);
	indent(1);
	FilePrint(f,",\n",START,"GeneratorsOfGroup(");
	doit(node.domain);
	FilePrint(f,"),");
	doit(node.images);
	FilePrint(f,")");
	indent(-1);
      elif node.kind="genimg" then
        FilePrint(f,"GroupHomomorphismByImages(");
	doit(node.domain);
	FilePrint(f,",");
	doit(node.codomain);
	indent(1);
	FilePrint(f,",\n",START);
	doit(node.gens);
	FilePrint(f,",");
	doit(node.images);
	FilePrint(f,")");
	indent(-1);

      elif node.kind="fct" then
        FilePrint(f,"GroupHomomorphismByFunction(");
	doit(node.domain);
	FilePrint(f,",");
	doit(node.codomain);
	indent(1);
	FilePrint(f,",\n",START);
	doit(node.var);
	FilePrint(f,"->");
	doit(node.expr);
	FilePrint(f,")");
	indent(-1);
      else
        Error("unknown kind ",node.kind);
      fi;
    elif t="forall" or t="exists" then
      if node.varset<>false then
        doit(node.varset);
	FilePrint(f,":=");
      fi;
      if t="forall" then
	FilePrint(f,"ForAll(");
      else
	FilePrint(f,"ForAny(");
      fi;
      doit(node.from);
      FilePrint(f,",");
      doit(node.var);
      FilePrint(f,"->");
      doit(node.cond);
      FilePrint(f,")");

    elif t="error" then
      FilePrint(f,"Error(");
      printlist(node.values,"\"");
      FilePrint(f,");\n",START);
    elif t="break" then
      FilePrint(f,"break");
      if node.var.type<>"none" then
	FilePrint(f," ");
	doit(node.var);
      fi;
      FilePrint(f,";\n",START);
    elif t="none" then
      FilePrint(f,"#NOP\n",START);
    else
      Error("NEED TO DO  type ",t," ");
      #Error("type ",t," not yet done");
    fi;
  end;

  PrintTo(f,
    "#  File converted from Magma code -- requires editing and checking\n",
    "#  Magma -> GAP converter, ",MGMCONVER, " by AH\n\n");

  t:="Global Variables used: ";
  for i in [1..Length(l.used)] do
    if i>1 then Append(t,", ");fi;
    Append(t,l.used[i]);
  od;
  mulicomm(f,t);
  FilePrint(f,"\n");

  t:="Defines: ";
  for i in [1..Length(l.defines)] do
    if i>1 then Append(t,", ");fi;
    Append(t,l.defines[i]);
  od;
  mulicomm(f,t);
  FilePrint(f,"\n");


  for i in l.code do
    doit(i);
  od;
  FilePrint(f,"\n");

end;

MagmaConvert:=function(arg)
local infile, f,l;

  infile:=arg[1];
  l:=MgmParse(infile);

  if Length(arg)>1 and IsString(arg[2]) then
    f:=OutputTextFile(arg[2],false);
  else
    f:=fail;
  fi;

  if f=fail then
    f:=OutputTextUser();
  fi;

  GAPOutput(l,f);
  CloseStream(f);
end;
