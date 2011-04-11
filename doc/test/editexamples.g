# usage: Editexamples(file) where `file' is the path to an xml source file
# produces `file.new' in the current directory, which contains reedited
# examples that are produced from the GAP output. 

GAPEXEC:="../../../bin/gap.sh";
EditExamples:=function(fnam)
local s,t,r,ex,inex,l,p,a,i,ran,m,b,tstnam,tsttwo,e,n;

  SizeScreen([255,]);
  p:=Positions(fnam,'/');
  tstnam:=fnam{[p[Length(p)]+1..Length(fnam)]};
  tsttwo:=Concatenation(tstnam,".in");
  PrintTo(tsttwo,"SizeScreen([80,]);\n");
  AppendTo(tsttwo,"LogTo(\"",Concatenation(tstnam,".out"),"\");\n");
 
  # read in source and process
  s:=InputTextFile(fnam);
  m:=[];
  t:=[];
  r:=rec();
  n:=0;
  e:=0;
  inex:=false;
  while not IsEndOfStream(s) do
    l:=ReadLine(s);
    if l<>fail then
      if inex then
        # example processing
	if l="]]></Example>\n" then
	  #AppendTo(tsttwo,"Print(\"%$#@\\n\");\n");
	  AppendTo(tsttwo,"#!@$%\n");
	  inex:=false;
	  n:=n+1;
	  Add(m,l);
	  r.ende:=n;
	elif Length(l)<2 then
	# empty line has length 1 b/c \n
	  l:=l; # empty line
	elif l{[1,2]}="> " then
	  AppendTo(tsttwo,l{[3..Length(l)]});
	elif Length(l)>5 and l{[1..5]}="gap> " then
	  AppendTo(tsttwo,l{[6..Length(l)]});
	fi;
      else
        # nonexample
	n:=n+1;
	Add(m,l);
	# start/end examples?
	if l="<Example><![CDATA[\n" then
	  e:=e+1;
	  r:=rec(start:=n,num:=e);
	  Add(t,r);
	  inex:=true;
	  #AppendTo(tsttwo,"Print(\"@#$%--",e,"\\n\");\n");
	  AppendTo(tsttwo,"#%$@!--",e,"\n");
	fi;
      fi;
    fi;
  od;
  CloseStream(s);
  AppendTo(tsttwo,"LogTo();\n");

  # execute
  Exec(Concatenation(GAPEXEC," -b <",tsttwo));
  Exec(Concatenation("rm -f ",tsttwo));

  # now read in the output
  tsttwo:=Concatenation(tstnam,".out");
  s:=InputTextFile(tsttwo);
  inex:=false;
  while not IsEndOfStream(s) do
    l:=ReadLine(s);
    if l<>fail then
      if inex then
        if Length(l)>10 and l{[1..10]}="gap> #!@$%" then
	  inex:=false;
	else
	  Add(ex,l);
	fi;
      else
	if Length(l)>12 and l{[1..12]}="gap> #%$@!--" then
	  # start example
	  inex:=true;
	  p:=Int(Chomp(l{[13..Length(l)]}));
	  ex:=[];
	  t[p].ex:=ex;
	fi;
      fi;
    fi;
  od;
  CloseStream(s);
  Exec(Concatenation("rm -f ",tsttwo));

  # reverse order so that changes in line numbers don't matter
  t:=Reversed(t);
 
  for i in t do
    m:=Concatenation(m{[1..i.start]},i.ex,m{[i.ende..Length(m)]});
  od;

  # Create new file
  tstnam:=Concatenation(tstnam,".new");
  PrintTo(tstnam);
  for i in m do
    AppendTo(tstnam,i);
  od;

  SizeScreen([80,]);

end;
