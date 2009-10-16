# program to build project list
# Each project is a file `gapproj<n>'. Entries are separated by flags
# started with an @-character.
# All following lines will be taken as verbatim HTML
# Recognized are the following fields:
# @Name
# Title of project 
# @Contact
# Name of the person posing the problem
# @Date
# last update
# @Time
# Estimat of time it takes (see desc.html for scaling)
# @Public
# If not set to `Yes', the project will not be listed on a public web page.
# @Need
# Interest level/Desirability etc.
# @Need<suffix>
# Interest for other list (see MODE below)
# @Math
# Level of mathematical sophistication
# @Prog
# Level of programming sophistication
# @Component
# Part of GAP affected
# @Descr
# Descriptive text
# @Manual
# Possible manual section (might indicate better what to do)
# @Ref
# Published literature
# @Rem
# Remarks
# @Application
# Applications or uses that would be possible if this feature was
# implemented. (This might be useful for grant applications and therefore 
# will not be listed in the public section)

# the colors indicating increasing values
COLORS:=["#8080ff","#80ffff","#80ff80","#ffff80","#ff8080"];

# The different modes permit to build several project lists. The `suf'
# suffix indicales which `need' field will be used. 
MODE:=[
     # Mode 1: General list for GAP
     rec(suf:="", 
         private:=false,
         title:="<font face=\"Gill Sans,Helvetica,Arial\">GAP</font> Project repository",
         titlenohtm:="GAP Project repository",
         dir:="gapproj/",
	 footer:=Concatenation(
  "\n<H3><A HREF=\"http://www.gap-system.org\">",
  "<font face=\"Gill Sans,Helvetica,Arial\">GAP</font> home page</A></H3>")),

     # Mode 2: Projects I'm interested in (AH), public 
     rec(suf:="A", 
         private:=false,
         title:="Possible thesis projects involving\n<font face=\"Gill Sans,Helvetica,Arial\">GAP</font>",
         titlenohtm:="Possible thesis projects, involving GAP",
         dir:="projects/",
	 footer:=Concatenation(
  "\n<H3><A HREF=\"http://www.math.colostate.edu/~hulpke\">Back</A>\n",
  "to Alexander Hulpke's home page</H3>")),
     # Mode 4: General list for GAP, including private
     rec(suf:="", 
         private:=true,
         title:="<font face=\"Gill Sans,Helvetica,Arial\">GAP</font> Project repository\n (restricted)",
         titlenohtm:="GAP Projects (internal)",
         dir:="gapproj/private/",
	 footer:=Concatenation(
  "\n<H3><A HREF=\"http://www.gap-system.org\">",
  "<font face=\"Gill Sans,Helvetica,Arial\">GAP</font> home page</A></H3>")),
     # Mode 4: private list for AH (all projects, even private ones or ones
     # with priority 0)
     rec(suf:="A", 
         private:=true,
         title:="Possible thesis projects involving\n<font face=\"Gill Sans,Helvetica,Arial\">GAP</font> (private version)",
         titlenohtm:="Possible thesis projects, involving GAP",
         dir:="privateproj/",
	 footer:=Concatenation(
  "\n<H3><A HREF=\"http://www.math.colostate.edu/~hulpke\">Back</A>\n",
  "to Alexander Hulpke's home page</H3>"))
	 ];

# abbreviation of names (and email) to save typing
SIGS:=[["AH","Alexander Hulpke","hulpke@math.colostate.edu"],
       ["JN","Joachim Neub&uuml;ser","Joachim.Neubueser@Math.RWTH-Aachen.DE" ],
       ["MN","Max Neunh&ouml;ffer","Max.Neunhoeffer@Math.RWTH-Aachen.DE" ],
       ["VF","Volkmar Felsch","Volkmar.Felsch@Math.RWTH-Aachen.DE" ],
       ["FL","Frank L&uuml;beck","Frank.Luebeck@Math.RWTH-Aachen.De" ],
       ["TB","Thomas Breuer","Thomas.Breuer@Math.RWTH-Aachen.DE" ],
       ["GAP","GAP group","support@gap-system.org" ],
       ["WDJ","David Joyner","wdj@usna.edu"],
       ["BE","Bettina Eick","eick@tu-bs.de"],
       ["SL","Steve Linton","sal@dcs.st-and.ac.uk"],
       ["SK","Stefan Kohl","kohl@mathematik.uni-stuttgart.de"]
       ];

DeCR:=function(str)
  while (Length(str)>0 and str[Length(str)]='\n') do
    str:=str{[1..Length(str)-1]};
  od;
  return str;
end;

BuildProjList:=function(n,which)
local NumBlock,Section,fnam,stream,line,fn,str,r,nam,need,i,con,s1,s2;

  NumBlock:=function(bn,val)
    if val=0 then
      return Concatenation("<TD BGCOLOR=#ffffff width=50>\n",
        "<A HREF=\"./desc.htm#",bn,"\">",bn,"</A>:<BR>\n",
	"<center>-</center></TD>\n");
    else
      return Concatenation("<TD BGCOLOR=",COLORS[val]," width=60>\n",
        "<A HREF=\"./desc.htm#",bn,"\">",bn,"</A>:<BR>\n",
	"<center><font size=+3>",String(val),"</font></center></TD>\n");
    fi;
  end;

  Section:=function(fnam,str,val)
   if val<>false and val<>fail then
    val:=ReplacedString(val,"GAP",
		"\n<font face=\"Gill Sans,Helvetica,Arial\">GAP</font>\n");
     AppendTo(fnam,"<H3><A HREF=\"./desc.htm#",str,"\">",str,"</A></H3>\n",val,"\n");
   fi;
  end;

  fnam:=Concatenation("gapproj",String(n)); 
  if not IsReadableFile(fnam) then
    return fail;
  fi;
  stream:=InputTextFile(fnam);
  line:=ReadLine(stream);
  fn:=fail;
  str:=fail;
  r:=rec();
  r:=rec(Name:=false,
         Contact:="",
	 Date:="",
	 Time:=1,
	 Public:="no",
	 Need:=1,
	 NeedA:=0,
	 Math:=1,
	 Prog:=1,
         Descr:=false,
	 Manual:=false,
	 Ref:=false,
	 Rem:=false,
	 Application:="");
  while line<>fail do
    line:=DeCR(line);
    if Length(line)>0 and line[1]='@' then
      if fn<>fail then
        r.(fn):=str;
      fi;
      fn:=line{[2..Length(line)]};
      str:=fail;
    elif str=fail then
      str:=line;
    else
      str:=Concatenation(str,"\n",line);
    fi;
    if not IsEndOfStream(stream) then
      line:=ReadLine(stream);
    else
      line:=fail;
    fi;
  od;
  if fn<>fail and str<>fail then
    r.(fn):=str;
  fi;
  CloseStream(stream);
  r.Public:=LowercaseString(r.Public);
  # real need
  need:=Int(r.(Concatenation("Need",MODE[which].suf)));
  r.myneed:=need;
  if (need>0 and r.Public<>"no") or MODE[which].private then
    fnam:=Concatenation("gapproj",String(n),".html"); 
    r.fnam:=fnam;
    fnam:=Concatenation(MODE[which].dir,fnam);
    nam:=r.Name;
    PrintTo(fnam,
      "<HEAD>\n<TITLE>",nam,"</TITLE>\n</HEAD>\n<BODY BGCOLOR=#FFFFFF>\n");
    AppendTo(fnam,"<A HREF=\"./projects.htm\">\n",MODE[which].title,
      "</A>\n<HR><TABLE><TR><TD valign=top>\n");
    s1:=NumBlock("Need",need);
    s2:=NumBlock("Time",Int(r.Time));
    if r.Public="no" then
      AppendTo(fnam,"<TABLE><TR><TD><B><font size=+2>",nam,
      "\n</font></B></TR><TR><TD>(restricted)</TD></TR></TABLE>");
    else
      AppendTo(fnam,"<H2>",nam,"\n</H2>");
    fi;
    AppendTo(fnam,"\n</TD>&nbsp;&nbsp;\n",s1,s2,"</TR>\n");
    con:=r.Contact;
    for i in SIGS do
      if i[1]=con then
        con:=i[2];
	if IsBound(i[3]) then
	  con:=Concatenation(con,
	        "<BR>(<A HREF=\"mailto:",i[3],"\">\n",i[3],"</A>)");
	fi;
      fi;
    od;
    AppendTo(fnam,"<TR><TD>\n");

    if IsBound(r.Component) and r.Component<>fail then
      AppendTo(fnam,"<A HREF=\"./desc.htm#Component\">Component</A>:\n<B>",
               r.Component,"</B><BR>\n");
    fi;
    s1:=NumBlock("Math",Int(r.Math));
    s2:=NumBlock("Program",Int(r.Prog));
    AppendTo(fnam,"<A HREF=\"./desc.htm#Contact\">Contact</A>: ",con,
	     "\n<BR>Last Update: ", r.Date,"\n<BR></TD>\n",s1,s2,
	     "</TR></TABLE>\n<P><HR>\n");
    Section(fnam,"Description",r.Descr);
    Section(fnam,"References",r.Ref);
    Section(fnam,"Remarks",r.Rem);
    Section(fnam,"Usage",r.Manual);
    AppendTo(fnam,"<HR>\n",MODE[which].footer,"\n</BODY>\n");
    Exec(Concatenation("chmod go+r ",fnam));
    return r;
  else
    return false;
  fi;
end;

DoProjects:=function(which)
local n,l,r,fnam,title,NumBlock,sorts,so,j;

  NumBlock:=function(val)
    if val=0 then
      return "<TD BGCOLOR=#ffffff ><center>-</center></TD>\n";
    else
      return Concatenation("<TD BGCOLOR=",COLORS[val],">\n<center>",
                String(val),"</center></TD>\n");
    fi;

  end;
  n:=1;
  l:=[];
  r:=BuildProjList(n,which);
  while r<>fail do
    if IsRecord(r) then
      Add(l,r);
    fi;
    n:=n+1;
    r:=BuildProjList(n,which);
  od;
  sorts:=[["Desirability","myneed","projects.htm","Desirability"],
          ["Time requirement","Time","projectT.htm","Time"],
          ["Mathematical knowledge required","Math","projectM.htm",
	   "Mathematics"],
          ["Programming skills required","Prog","projectP.htm",
	   "Programming"]];
  title:=MODE[which].title;
  for so in sorts do
    Sort(l,function(a,b) 
	   if a.(so[2])=b.(so[2]) then
	     return a.Name<b.Name;
	   else
	     return a.(so[2])>b.(so[2]);
	   fi;
	  end);
    fnam:=Concatenation(MODE[which].dir,so[3]);
    PrintTo(fnam,"<HEAD>\n<TITLE>",MODE[which].titlenohtm,
      "</TITLE>\n</HEAD>\n<BODY BGCOLOR=#FFFFFF>\n");
    AppendTo(fnam,"<H2>\n",MODE[which].title,"\n</H2>\n");
    AppendTo(fnam,"<H1>Sorted by ",so[1]);
    AppendTo(fnam,"</H1>");
    AppendTo(fnam,"<TABLE>\n<TR><TD>Name</TD>\n");
    for j in sorts do
      AppendTo(fnam,"<TD><A HREF=\"./",j[3],"\">");
      if j<>so then
	AppendTo(fnam,j[4]);
      else
	AppendTo(fnam,"<B>",j[4],"</B>");
      fi;
      AppendTo(fnam,"</A></TD>");
    od;
    AppendTo(fnam,"</TR>\n");
    for r in l do
      AppendTo(fnam,"<TR>\n");
      if r.Public="no" then 
	AppendTo(fnam,"<TD>\n<I><A HREF=\"",r.fnam,"\">",r.Name,"</A></I>\n");
      else
	AppendTo(fnam,"<TD>\n<A HREF=\"",r.fnam,"\">",r.Name,"</A>\n");
      fi;
      for j in sorts do
	AppendTo(fnam,NumBlock(Int(r.(j[2]))));
      od;
      AppendTo(fnam,"</TR>\n");
    od;
    AppendTo(fnam,"</TABLE>\n");
    AppendTo(fnam,MODE[which].footer,"\n</BODY>\n");
    AppendTo(fnam,"</BODY>\n");
  od;
end;


