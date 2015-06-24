# Magma to GAP converter
# version 0.2, very raw
# Alexander Hulpke, 6/22/15


TOKENS:=["if","then","eq","cmpeq","neq","and","or","else","not","assigned",
         "while","ne","repeat","until","error","do","assert","vprint","print","printf",
	 "freeze","import","local","for","elif","intrinsic","to",
	 "end for","end function","end if","end intrinsic","end while",
	 "procedure","end procedure","where","break",
         "function","return",":=","+:=","-:=","*:=","cat:=","=",
	 "\\[","\\]","delete","exists",
	 "[","]","(",")","`",";","#","!","<",">","&","$",
	 "cat","[*","*]","->","@@","forward",
	 "+","-","*","/","div","mod","in","^","~","..",".",",","\"",
	 "{","}","|","::",":","@","cmpne","subset","by","try","end try",
	 "declare verbose","declare attributes",
	 "exists","forall",
	 "sub","eval","select","rec","recformat","require","case","when","end case",
	 "%%%" # fake keyword for comments
	 ];
BINOPS:=["+","-","*","/","div","mod","in","^","`","!","cat","and","|",
         "or","eq","cmpeq","ne","le","ge","gt","lt",".","->","@@","@","cmpne","meet","subset"];
PAROP:=["+","-","div","mod","in","^","`","!","cat","and",
         "or","eq","cmpeq","ne","."];
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


CHARSIDS:=Concatenation(CHARS_DIGITS,CHARS_UALPHA,CHARS_LALPHA,"_");
CHARSOPS:="+-*/,;:=~!";

GLOBALS:=[];

MgmParse:=function(file)
local Comment,eatblank,gimme,ReadID,ReadOP,ReadExpression,ReadBlock,
      ExpectToken,doselect,costack,locals,
      f,l,lines,linum,w,a,idslist,tok,tnum,i,sel,osel,e,comment;

  locals:=[];

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
      #Error("ZZZZ");
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
      if a="end" or a="declare" then
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
  local obj,e,a,b,c,argus,procidf,op,assg,val,pre,lbinops;

     lbinops:=Difference(BINOPS,stops);

     procidf:=function()
     local a,l,e,b,eset;

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
      elif e="(" then
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
      elif not (tok[tnum][1] in ["I","N","S"] or e="$") then
	tnum:=tnum+1;
	if e in ["-","#"] then
	  a:=rec(type:=Concatenation("U",e),arg:=procidf());
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
	  Error("other unary");
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
	  if e="(" then
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
	      AddSet(GLOBALS,a.name);
	    fi;
	    a:=rec(type:="C",fct:=a,args:=argus);
	    if Length(assg)>0 then
	      a.type:="CA";
	      a.assg:=assg;
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
      if tok[tnum]=["O","->"] then
	ExpectToken("->");
	if tok[tnum][1]<>"I" then
	  Error("-> unexpected");
	fi;
	a:=Concatenation("-> ",tok[tnum][2],"\n");
	tnum:=tnum+1;
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
	a:=rec(type:="co",text:=a);
      fi;
      if tok[tnum][2]=";" then
	#spurious ; after function definition
	tnum:=tnum+1;
      fi;

      a:=ReadBlock(["end function","end intrinsic","end procedure"]:inner);
      tnum:=tnum+1; # do end .... token

      a:=rec(type:="F",args:=argus,locals:=a[1],block:=a[2]);
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

  doselect:=function(cond)
  local yes,no;
    ExpectToken("select");
    yes:=ReadExpression(["else"]);
    ExpectToken("else");
    no:=ReadExpression([";","select"]);
    if tok[tnum][2]="select" then
      no:=doselect(no);
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
	elif e[2]="vprint" or e[2]="error" or e[2]="print" or e[2]="printf" then
	  if e[2]="vprint" then
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
	elif e[2]="forward" then
	  repeat
	    a:=ReadExpression([";",","]);
	    Add(l,rec(type:="co",
	      text:=Concatenation("Forward declaration of ",a.name)));
            if tok[tnum][2]="," then
	      ExpectToken(",",10);
	    fi;
	  until tok[tnum][2]=";";
	  ExpectToken(";",10);
	elif e[2]="function" or e[2]="intrinsic" then
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
	    b:=ReadBlock(["when","end case"]);
	    Add(c,[a,b[2]]);
	  od;
	  ExpectToken("end case");
	  Add(l,rec(type:="case",test:=e,cases:=c));
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
	  ExpectToken(";",13);
	elif e[2]=":=" then
	  # assignment
	  b:=ReadExpression([",",":=",";","select"]);

	  if tok[tnum][2]="select" then
	    b:=doselect(b);
	  fi;
	  Add(l,rec(type:="A",left:=a,right:=b));
	  ExpectToken(";",14);
          if ValueOption("inner")<>true and a.type="I" then
	    Print("> ",a.name," <\n");
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
	Error("cannot deal with token ",e);
      fi;
    od;

    return [locals,l];
  end;

  costack:=[];
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
    if usepar and r.type<>"I" and r.type<>"N" and r.type<>"S" then
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
    elif t="Print" then
      # info
      AppendTo(f,"Print(");
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
	for i in [1,3..Length(node.assg)-1] do
	  doit(node.assg[i]);
	  AppendTo(f,":=ValueOption(\"");
	  doit(node.assg[i]);
	  AppendTo(f,"\");\n",START,"if ");
	  doit(node.assg[i]);
	  AppendTo(f,"=fail then\n",START,"  ");
	  doit(node.assg[i]);
	  AppendTo(f,":=");
	  doit(node.assg[i+1]);
	  AppendTo(f,";\n",START,"fi;\n",START);
	od;

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
      if IsBound(node.line) then
	AppendTo(f,");\n",START);
      else
	AppendTo(f,")");
      fi;
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
    elif t="perm" then
      # permutation
      AppendTo(f,node.perm);
    elif t="notperm" then
      t:=UnFlat(node.notperm);
      if t=fail then
	t:=node.notperm;
      fi;
      AppendTo(f,"NOTPERM",t,"\n");
    elif t="[*" then
      AppendTo(f,"# [*-list:\n",START,"[");
      printlist(node.args);
      AppendTo(f,"]");
    elif t="R" then
      AppendTo(f,"[");
      doit(node.from);
      if IsBound(node.step) then
	AppendTo(f,",");
	doit(node.from);
	AppendTo(f,"+");
	doit(node.step);
      fi;
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
    elif t="Bcat" then
      AppendTo(f,"Concatenation(");
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
      elif i="eq" or i="cmpeq" then
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
      AppendTo(f,i);
      doitpar(node.right,a in PAROP);
    elif t="U#" then
      AppendTo(f,"Size(");
      doit(node.arg);
      AppendTo(f,")");
    elif t="U-" then
      AppendTo(f,"-");
      doit(node.arg);
    elif t="U~" then
      AppendTo(f,"~TILDE~");
      doit(node.arg);
    elif t="Unot" then
      AppendTo(f,"not ");
      doit(node.arg);
    elif t="Uassigned" then
      AppendTo(f,"Has");
      doit(node.arg);
    elif t="Ueval" then
      AppendTo(f,"#EVAL\n",START,"    ");
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
      elif node.op="cat" then
        AppendTo(f,"Concatenation(");
      else
        Error("node.op not yet done");
      fi;
      doit(node.arg);
      AppendTo(f,")");
    elif t="rec" then
      AppendTo(f,"rec(");
      indent(1);
      for i in [1,3..Length(node.assg)-1] do
	if i>1 then
	  AppendTo(f,",\n",START);
	fi;
	AppendTo(f,node.assg[i].name,":=");
	doit(node.assg[i+1]);
      od;
      indent(-1);
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
      #AppendTo(f,"\n");

      if IsBound(node.elseblock) then
	AppendTo(f,"\b\belse\n");
	indent(1);
	AppendTo(f,START);
	for i in node.elseblock do
	  doit(i);
	od;
	indent(-1);
	#AppendTo(f,"\n");
      fi;
      AppendTo(f,"\b\bfi;\n",START);
    elif t="while" then
      AppendTo(f,"while ");
      doit(node.cond);
      indent(1);
      AppendTo(f," do\n",START);
      for i in node.block do
	doit(i);
      od;
      indent(-1);
      #AppendTo(f,"\n");
      AppendTo(f,"\b\bod;\n",START);
    elif t="for" then
      AppendTo(f,"for ");
      doit(node.var);
      AppendTo(f," in ");
      doit(node.from);
      indent(1);
      AppendTo(f," do\n",START);
      for i in node.block do
	doit(i);
      od;
      indent(-1);
      AppendTo(f,"\b\bod;\n",START);

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

    elif t="sub" then
      AppendTo(f,"SubStructure(");
      doit(node.within);
      AppendTo(f,",");
      for i in [1..Length(node.span)] do
	if i=2 then
	  AppendTo(f,",#TODO CLOSURE\n",START,"  ");
	fi;

	doit(node.span[i]);
      od;
      AppendTo(f,")");


    elif t="assert" then
      AppendTo(f,"Assert(1,");
      doit(node.cond);
      AppendTo(f,");\n",START);

    elif t="require" then
      AppendTo(f,"if not ");
      doit(node.cond);
      indent(1);
      AppendTo(f,"then\n",START,"Error(");
      doit(node.mess);
      indent(-1);
      AppendTo(f,");\n",START);

    elif t="select" then
      AppendTo(f,"SELECT(");
      doit(node.cond);
      AppendTo(f," then ");
      doit(node.yescase);
      AppendTo(f," else ");
      doit(node.nocase);
      AppendTo(f,")");
    elif t="error" then
      AppendTo(f,"Error(");
      printlist(node.values,"\"");
      AppendTo(f,");\n",START);
    elif t="break" then
      AppendTo(f,"break");
      if node.var.type<>"none" then
	AppendTo(f," ");
	doit(node.var);
      fi;
      AppendTo(f,";\n",START);
    elif t="none" then
      AppendTo(f,"#NOP\n",START);
    else
      Error("NEED TO DO  type ",t," ");
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
