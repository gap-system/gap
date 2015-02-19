# Magma to GAP converter
# version 0.1, very raw
# Alexander Hulpke, 12/14


TOKENS:=["if","then","eq","neq","and","or","else","not","assigned",
         "while","ne","repeat","until","error","do","assert","vprint",
	 "freeze","import","local","for","elif",
	 "end for","end function","end if","end intrinsic","end while",
	 "procedure","end procedure","where",
         "function","return",":=","+:=","-:=","*:=","cat:=",
	 "[","]","(",")","`",";","#","!","<",">","&",
	 "cat","[*","*]","->","@@","forward",
	 "+","-","*","/","div","mod","in","^","~","..",".",",","\"",
	 "{","}","|",":","@","cmpne",
	 "%%%" # fake keyword for comments
	 ];
BINOPS:=["+","-","*","/","div","mod","in","^","`","!","cat","and",
         "or","eq","ne","le","gt","lt",".","->","@@","@","cmpne"];
PAROP:=["+","-","div","mod","in","^","`","!","cat","and",
         "or","eq","ne","."];
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

CHARSIDS:=Concatenation(CHARS_DIGITS,CHARS_UALPHA,CHARS_LALPHA,"_");
CHARSOPS:="+-*/,;:=~!";

MgmParse:=function(file)
local Comment,eatblank,gimme,ReadID,ReadOP,ReadExpression,ReadBlock,
      ExpectToken,
      f,l,lines,linum,w,a,idslist,tok,tnum,i,sel,osel,e,comment;

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
	a:=a{[1..p-1]};
	Add(comment,a);
	a:="%%%";
      fi;
      l:=Concatenation(l," ",a);
      #if PositionSublist(l,"two_power")<>fail then Error("ZUGU");fi;
    od;
    eatblank();
  end;

  ExpectToken:=function(s)
    if tok[tnum][2]<>s then
      Error("expected token ",s," not ",tok[tnum]);
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
      if a="end" then
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
      if Length(osel)<>1 then Error("nonunique");fi;
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
	while l[i]<>'"' do
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
  local obj,e,a,b,c,argus,procidf,op,assg,val,pre;

     procidf:=function()
     local a,l,e,b;
      e:=tok[tnum][2];
      if e="(" then
	tnum:=tnum+1;
        a:=ReadExpression([")"]);
	if tok[tnum][2]=","  then 
	  ExpectToken(",");
	  b:=ReadExpression([")"]);
	  ExpectToken(")");
	  a:=rec(type:="pair",left:=a,right:=b);
	  return a;
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
	      e:=ReadExpression(["]"]); #part 2
	      ExpectToken("]");
	      a:=rec(type:="R",from:=a,to:=e);
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
	ExpectToken(">");
	a:=rec(type:="<",args:=l);

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
	if tok[tnum][2]="}" then
	  #empty list
	  tnum:=tnum;
	else
	  repeat 
	    a:=ReadExpression(["}",","]);
	    Add(l,a);
	  until tok[tnum][2]="}";
	fi;
	ExpectToken("}");
	a:=rec(type:="{",args:=l);

      elif not tok[tnum][1] in ["I","N","S"] then
	tnum:=tnum+1;
	if e in ["-","#"] then
	  a:=rec(type:=Concatenation("U",e),arg:=procidf());
	elif e="&" then
	  e:=tok[tnum][2];
	  tnum:=tnum+1;
	  a:=ReadExpression([",",";"]);
	  a:=rec(type:="&",op:=e,arg:=a);
	elif e="~" or e="not" or e="assigned" then
          a:=ReadExpression(Concatenation(stops,["and","or"]));
	  a:=rec(type:=Concatenation("U",e),arg:=a);
	else
	  Error("other unary");
	fi;

      else
	# identifier/number
	a:=rec(type:=tok[tnum][1],name:=tok[tnum][2]);
	tnum:=tnum+1;
	e:=tok[tnum][2];
	while not (e in stops or e in BINOPS) do
	  if e="(" then
	    # fct call
	    assg:=false;
	    tnum:=tnum+1;
	    argus:=[];
	    while tok[tnum][2]<>")" do
	      b:=ReadExpression([",",")",":"]);
	      Add(argus,b);
	      if tok[tnum][2]="," then
		tnum:=tnum+1;
	      elif tok[tnum][2]=":" then
		tnum:=tnum+1;
		assg:=ReadExpression([":="]);
		ExpectToken(":=");
		val:=ReadExpression([")"]);
	      fi;
	    od;
	    ExpectToken(")");
	    a:=rec(type:="C",fct:=a,args:=argus);
	    if assg<>false then
	      a.type:="CA";
	      a.assg:=[assg,val];
	    fi;
	  elif e="[" then
	    # index
	    tnum:=tnum+1;
	    b:=ReadExpression(["]"]);
	    ExpectToken("]");
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
	    ExpectToken(">");
	    a:=rec(type:="<>",op:=pre,left:=b,right:=c);

	  elif e="," and stops=[")"] then
	    # expression '(P,C)'
	    ExpectToken(",");
	    b:=ReadExpression(stops);
	    a:=rec(type:="pair",left:=a,right:=b);
	  elif e="select" then
	    ExpectToken("select");
	    b:=ReadExpression(["else"]);
	    ExpectToken("else");
	    c:=ReadExpression(stops);
	    a:=rec(type:="select",a:=a,b:=b,c:=c);
	  else
	    Error("eh!");
	  fi;
	  e:=tok[tnum][2];
	od;
      fi;
      return a;
    end;

    if tok[tnum]=["K","function"] then
      # function
      tnum:=tnum+1;
      ExpectToken("(");
      argus:=[];
      while tok[tnum][2]<>")" and tok[tnum][2]<>":" do
        if tok[tnum][1]="I" then
	  Add(argus,tok[tnum][2]);
	  tnum:=tnum+1;
	  if tok[tnum]=["O",","] then tnum:=tnum+1;fi; # multiple
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

      a:=ReadBlock(["end function"]:inner);
      ExpectToken("end function");
      a:=rec(type:="F",args:=argus,locals:=a[1],block:=a[2]);
      if assg<>false then
	a.type:="FA";
	a.assg:=assg;
      fi;

      return a;

    # todo: parentheses
    else 
      a:=procidf();
      while tok[tnum][2] in BINOPS do
        op:=tok[tnum][2];
	tnum:=tnum+1;

	b:=procidf();
	a:=rec(type:=Concatenation("B",op),left:=a,right:=b);
      od;
      return a;

    fi;
  end;

  ReadBlock:=function(endkey)
  local l,e,a,aif,b,c,locals,kind,i;
    l:=[];
    locals:=[];

    while tnum<=Length(tok) and
      (endkey=false or ForAll(endkey,x->tok[tnum]<>["K",x])) do
      e:=tok[tnum];
      tnum:=tnum+1;
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
	  ExpectToken(";");
	elif e[2]="while" then
	  a:=ReadExpression(["do"]);
	  ExpectToken("do");
	  b:=ReadBlock(["end while"]:inner);
	  locals:=Union(locals,b[1]);
	  a:=rec(type:="while",cond:=a,block:=b[2]);
	  ExpectToken("end while");
	  ExpectToken(";");
	  Add(l,a);
	elif e[2]="for" then
	  a:=rec(type:="I",name:=tok[tnum][2]);
	  tnum:=tnum+1;
	  ExpectToken("in");
	  c:=ReadExpression(["do"]);
	  ExpectToken("do");
	  b:=ReadBlock(["end for"]:inner);
	  locals:=Union(locals,b[1]);
	  a:=rec(type:="for",var:=a,from:=c,block:=b[2]);
	  ExpectToken("end for");
	  ExpectToken(";");

	elif e[2]="assert" then
	  a:=ReadExpression([";"]);
	  a:=rec(type:="assert",cond:=a);
	  ExpectToken(";");
	  Add(l,a);
	elif e[2]="repeat" then
	  b:=ReadBlock(["until"]);
	  ExpectToken("until");
	  locals:=Union(locals,b[1]);
	  a:=ReadExpression([";"]);
	  a:=rec(type:="repeat",cond:=a,block:=b[2]);
	  Add(l,a);
	  ExpectToken(";");

	elif e[2]="return" then
	  a:=[];
	  while tok[tnum][2]<>";" do
	    Add(a,ReadExpression([",",";"]));
	    if tok[tnum][2]="," then
	      tnum:=tnum+1;
	    fi;
	  od;
	  ExpectToken(";");
	  Add(l,rec(type:="return",values:=a));
	elif e[2]="vprint" or e[2]="error" then
	  if e[2]="vprint" then
	    kind:="Info";
	    a:=ReadExpression([":"]);
	    ExpectToken(":");
	  else 
	    a:=false;
	    kind:="error";
	  fi;
	  c:=[];
	  if tok[tnum][1]="S" then
	    c[1]:=tok[tnum][2];
	  fi;
	  if tok[tnum+1][2]="," then
	    # there are more arguments
	    tnum:=tnum+1;
	    repeat
	      tnum:=tnum+1;
	      b:=ReadExpression([",",";"]);
	      Add(c,b);
	      e:=tok[tnum][2];
	    until e=";";
	  else
	    tnum:=tnum+1;
	  fi;
	  ExpectToken(";");

	  Add(l,rec(type:=kind,class:=a,values:=c));

	elif e[2]="freeze" then
	  ExpectToken(";");
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
	  ExpectToken(";");
	elif e[2]="forward" then
	  a:=ReadExpression([";"]);
	  ExpectToken(";");
	  Add(l,rec(type:="co",
	    text:=Concatenation("Forward declaration of ",a.name)));
	elif e[2]="function" then
	  tnum:=tnum-1;
	  # rewrite: function Bla 
	  # to Bla:=function
	  tok:=Concatenation(tok{[1..tnum-1]},tok{[tnum+1]},[["O",":="]],
	    tok{[tnum]},tok{[tnum+2..Length(tok)]});
          #Error("rewrote");
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
	  ExpectToken(";");
	  for a in c do
	    AddSet(locals,a.name);
	  od;

	else
	  Error("other keyword ",e);
	fi;
      elif e[1]="I" then
	tnum:=tnum-1;
	a:=ReadExpression([",",":=","-:=","+:=","*:=","cat:=",";"]);
	if a.type="I" then
	  AddSet(locals,a.name);
	fi;
	e:=tok[tnum];
	tnum:=tnum+1;
	if e[1]<>"O" then Error("missing separator");fi;
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
	  ExpectToken(";");
	elif e[2]=":=" then
	  # assignment
	  b:=ReadExpression([",",":=",";"]);
	  Add(l,rec(type:="A",left:=a,right:=b));
	  ExpectToken(";");
          if ValueOption("inner")<>true and a.type="I" then
	    Print("> ",a.name," <\n");
	  fi;
	elif e[2]="-:=" then
	  b:=ReadExpression([";"]);
	  ExpectToken(";");
	  Add(l,rec(type:="A-",left:=a,right:=b));
	elif e[2]="+:=" then
	  b:=ReadExpression([";"]);
	  ExpectToken(";");
	  Add(l,rec(type:="A+",left:=a,right:=b));
	elif e[2]="*:=" then
	  b:=ReadExpression([";"]);
	  ExpectToken(";");
	  Add(l,rec(type:="A*",left:=a,right:=b));
	elif e[2]="cat:=" then
	  b:=ReadExpression([";"]);
	  ExpectToken(";");
	  Add(l,rec(type:="Acat",left:=a,right:=b));

	fi;
      elif e[1]="S" then
        # string, print warning
	Add(l,rec(type:="W",text:=e[2]));
	ExpectToken(";");
      else 
	Error("cannot deal with token ",e);
      fi;
    od;

    return [locals,l];
  end;

  tnum:=1; # indicate in token list

  # actual work
  a:=ReadBlock(false);

  return a[2];

end;

GAPOutput:=function(l,f)
local i,doit,printlist,doitpar,indent,START;

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
	AppendTo(f,",");
      else
	first:=false;
      fi;
      if IsRecord(i) then
	doit(i);
      else
	if Length(arg)>1 then
	  AppendTo(f,"\"",i,"\"");
	else
	  AppendTo(f,i);
	fi;
      fi;
    od;
  end;

  doitpar:=function(r,usepar)
    if usepar and r.type<>"I" and r.type<>"N" then
      AppendTo(f,"(");
      doit(r);
      AppendTo(f,")");
    else
      doit(r);
    fi;
  end;

  # doit -- main node processor
  doit:=function(node)
  local t,i,a;
    t:=node.type;
    if t="A" then
      doit(node.left);
      AppendTo(f,":=");
      doit(node.right);
      AppendTo(f,";\n",START);
    elif t[1]='A' and Length(t)=2 and t[2] in "+-*" then
      doit(node.left);
      AppendTo(f,":=");
      doit(node.left);
      AppendTo(f,t{[2]});
      doit(node.right);
      AppendTo(f,";\n",START);
    elif t="Acat" then
      doit(node.left);
      AppendTo(f,":=Concatenation(");
      doit(node.left);
      AppendTo(f,",");
      doit(node.right);
      AppendTo(f,");\n",START);

    elif t="Amult" then
      AppendTo(f,"# =v= MULTIASSIGN =v=\n",START);
      a:=node.left[Length(node.left)];
      doit(a);
      AppendTo(f,":=");
      doit(node.right);
      AppendTo(f,";\n",START);
      for i in [1..Length(node.left)] do
        doit(node.left[i]);
	AppendTo(f,":=");
	doit(a);
	AppendTo(f,".val",String(i),";\n",START);
      od;
      AppendTo(f,"# =^= MULTIASSIGN =^=\n",START);

    elif t="I" or t="N" then
      AppendTo(f,node.name);
    elif t="co" then
      # commentary
      a:=node.text;
      i:=Position(a,'\n');
      while i<>fail do
	AppendTo(f,"\n",START);
	AppendTo(f,"# ",a{[1..i]},START);
	a:=a{[i+1..Length(a)]};
	i:=Position(a,'\n');
      od;

      AppendTo(f,"#  ",a,"\n",START);
    elif t="W" then
      # warning
      AppendTo(f,"Info(InfoWarning,1,");
      if Length(node.text)>40 then
	AppendTo(f,"\n",START,"  ");
      fi;
      AppendTo(f,"\"",node.text,"\");\n",START);
    elif t="Info" then
      # info
      AppendTo(f,"Info(Info");
      doit(node.class);
      AppendTo(f,",1,");
      printlist(node.values,"\"");
      AppendTo(f,");\n",START);
    elif t="return" then
      if Length(node.values)=1 then
        AppendTo(f,"return ");
	doit(node.values[1]);
	AppendTo(f,";\n",START);
      else
	AppendTo(f,"return rec(");
	for i in [1..Length(node.values)] do
	  if i>1 then AppendTo(f,",\n",START,"  ");fi;
	  AppendTo(f,"val",String(i),":=");
	  doit(node.values[i]);
	od;
	AppendTo(f,");\n",START);
      fi;
    elif t[1]='F' then
      # function
      AppendTo(f,"function(");
      printlist(node.args);
      AppendTo(f,")\n",START);
      indent(1);
      if Length(node.locals)>0 then
        AppendTo(f,"local ");
	printlist(node.locals);
	AppendTo(f,";\n",START);
      fi;
      if t="FA" then

	doit(node.assg[1]);
	AppendTo(f,":=ValueOption(\"");
	doit(node.assg[1]);
	AppendTo(f,"\");\n",START,"if ");
	doit(node.assg[1]);
	AppendTo(f,"=fail then\n",START,"  ");
	doit(node.assg[1]);
	AppendTo(f,":=");
	doit(node.assg[2]);
	AppendTo(f,";\n",START,"fi;\n",START);
      fi;
      for i in node.block do
	doit(i);
      od;
      AppendTo(f,"\n");
      indent(-1);
      AppendTo(f,START,"end;\n",START);
    elif t="S" then
      AppendTo(f,"\"");
      AppendTo(f,node.name);
      AppendTo(f,"\"");
    elif t="C" or t="CA" then
      # fct. call
      doit(node.fct);
      AppendTo(f,"(");
      printlist(node.args);
      if t="CA" then
        AppendTo(f,":");
	for i in [1,3..Length(node.assg)-1] do
	  if i>1 then
	    AppendTo(f,",");
	  fi;
	  doit(node.assg[i]);
	  AppendTo(f,":=");
	  doit(node.assg[i+1]);
	od;
      fi;
      AppendTo(f,")");
    elif t="L" then
      # list access
      doit(node.var);
      AppendTo(f,"[");
      doit(node.at);
      AppendTo(f,"]");

    elif t="V" then
      AppendTo(f,"[");
      printlist(node.args);
      AppendTo(f,"]");
    elif t="{" then
      # Set
      AppendTo(f,"Set([");
      printlist(node.args);
      AppendTo(f,"])");
    elif t="[*" then
      AppendTo(f,"# [*-list:\n",START,"[");
      printlist(node.args);
      AppendTo(f,"]");
    elif t="R" then
      AppendTo(f,"[");
      doit(node.from);
      AppendTo(f,"..");
      doit(node.to);
      AppendTo(f,"]");
    elif t="pair" then
      AppendTo(f,"Tuple([");
      doit(node.left);
      AppendTo(f,",");
      doit(node.right);
      AppendTo(f,"])");
    elif t="B!" then
      doit(node.right);
      AppendTo(f,"*FORCEOne(");
      doit(node.left);
      AppendTo(f,")");
    elif t="B`" then
      doit(node.right);
      AppendTo(f,"Attr(");
      doit(node.left);
      AppendTo(f,")");
    elif t="Bdiv" then
      AppendTo(f,"QuoInt(");
      doit(node.left);
      AppendTo(f,",");
      doit(node.right);
      AppendTo(f,")");
    elif t[1]='B' then
      # binary op
      i:=t{[2..Length(t)]};
      a:=i;
      doitpar(node.left,a in PAROP);
      if i="ne" or i="cmpne" then
        i:="<>";
      elif i="eq" then
        i:="=";
      elif i="and" then
        i:=" and ";
      elif i="or" then
        i:=" or ";
      elif i="mod" then
        i:=" mod ";
      fi;
      AppendTo(f,i);
      doitpar(node.right,a in PAROP);
    elif t="U#" then
      AppendTo(f,"Size(");
      doit(node.arg);
      AppendTo(f,")");
    elif t="U-" then
      AppendTo(f,"-");
      doit(node.arg);
    elif t="Unot" then
      AppendTo(f,"not ");
      doit(node.arg);
    elif t="Uassigned" then
      AppendTo(f,"Has");
      doit(node.arg);
    elif t="<>" then
      AppendTo(f,"Sub");
      doit(node.op);
      AppendTo(f,"(");
      if Length(node.left)=1 then
        doit(node.left[1]);
      else
	printlist(node.left);
      fi;
      AppendTo(f,",[");
      printlist(node.right);
      AppendTo(f,"])");
    elif t="<" then
      AppendTo(f,"Span(");
      printlist(node.args);
      AppendTo(f,")");
    elif t=":" then
      AppendTo(f,"List(");
      doit(node.from);
      AppendTo(f,",",node.var,"->");
      doit(node.op);
      AppendTo(f,")");
    elif t="&" then
      if node.op="+" then
        AppendTo(f,"Sum(");
      elif node.op="*" then
        AppendTo(f,"Product(");
      else
        Error("node.op not yet done");
      fi;
      doit(node.arg);
      AppendTo(f,")");
    elif t="if" then
      AppendTo(f,"if ");
      doit(node.cond);
      indent(1);
      AppendTo(f," then\n",START);
      for i in node.block do
	doit(i);
      od;
      indent(-1);
      AppendTo(f,"\n");

      if IsBound(node.elseblock) then
	AppendTo(f,START,"else\n");
	indent(1);
	AppendTo(f,START);
	for i in node.elseblock do
	  doit(i);
	od;
	indent(-1);
	AppendTo(f,"\n");
      fi;
      AppendTo(f,START,"fi;\n",START);
    elif t="while" then
      AppendTo(f,"while ");
      doit(node.cond);
      indent(1);
      AppendTo(f," do\n",START);
      for i in node.block do
	doit(i);
      od;
      indent(-1);
      AppendTo(f,"\n");
      AppendTo(f,START,"od;\n",START);

    elif t="repeat" then
      indent(1);
      AppendTo(f,"repeat\n",START);
      for i in node.block do
	doit(i);
      od;
      indent(-1);
      AppendTo(f,"\n",START);
      AppendTo(f,"until ");
      doit(node.cond);
      AppendTo(f,";\n",START);

    elif t="assert" then
      AppendTo(f,"Assert(1,");
      doit(node.cond);
      AppendTo(f,");\n",START);
    elif t="select" then
      AppendTo(f,"SELECT(");
      doit(node.a);
      AppendTo(f," then ");
      doit(node.b);
      AppendTo(f," else ");
      doit(node.c);
      AppendTo(f,")");
    elif t="error" then
      AppendTo(f,"Error(");
      printlist(node.values,"\"");
      AppendTo(f,")");
    else
      Error("TODO  type ",t," ");
      #Error("type ",t," not yet done");
    fi;
  end;

  PrintTo(f,
    "# File converted from Magma code -- requires editing and checking\n\n");

  for i in l do
    doit(i);
  od;

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
