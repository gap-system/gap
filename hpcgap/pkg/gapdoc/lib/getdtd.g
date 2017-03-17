#############################################################################
##
#W  getdtd.g                     GAPDoc                          Frank Lübeck
##
##
#Y  Copyright (C)  2000,  Frank Lübeck,  Lehrstuhl D für Mathematik,  
#Y  RWTH Aachen
##
##  This  is  a  utility  file  for  the  GAPDoc  package,  which  reads
##  gapdoc.dtd, creates the content of  `GAPDOCDTDINFO' and writes it to
##  `GAPDocDtdInfo.g'. (Because we don't have a dtd-parser.)
##  
##  This is  not read by  the package and  only used when  gapdoc.dtd is
##  changed.
##  
#Revision.getdtd.g :=



# some hacks instead of writing a dtd-parser

dtd := StringFile("gapdoc.dtd");;

pos := PositionSublist(dtd, "<!ELEMENT");
elementdecs := [];
while pos <> fail do
  pos2 := Position(dtd, '>', pos);
  Add(elementdecs, dtd{[pos+10..pos2-1]});
  pos := pos2;
  pos := PositionSublist(dtd, "<!ELEMENT", pos);
od;

elements := [];
elementcontents := rec();
for a in elementdecs do
  wds := WordsString(a);
  Add(elements, wds[1]);
  elementcontents.(wds[1]) := Set(wds{[2..Length(wds)]});
od;

pos := PositionSublist(dtd, "% InnerText");
pos2 := Position(dtd, '>', pos);
innertxt := WordsString(dtd{[pos+13..pos2]});
txt := Concatenation(innertxt, [ "Enum", "List", "Table" ]);
ssent := [ "Subsection", "ManSection" ];

for x in elements do 
  if "InnerText" in elementcontents.(x) then
    elementcontents.(x) :=
      Concatenation(Difference(elementcontents.(x), ["InnerText"]), innertxt);
  fi;
  if "Text" in elementcontents.(x) then
    elementcontents.(x) :=
      Set(Concatenation(Difference(elementcontents.(x), ["Text"]), txt));
  fi;
  if "SubsectionEnt" in elementcontents.(x) then
    elementcontents.(x) :=
      Set(Concatenation(Difference(elementcontents.(x), ["SubsectionEnt"]), 
              ssent));
  fi;
od;

pos := PositionSublist(dtd, "<!ATTLIST");
elementatts := [];
while pos <> fail do
  pos2 := Position(dtd, '>', pos);
  Add(elementatts, dtd{[pos+10..pos2-1]});
  pos := pos2;
  pos := PositionSublist(dtd, "<!ATTLIST", pos);
od;

elementattributes := rec();
for a in elementatts do
  wds := WordsString(a);
  elementattributes.(wds[1]) := wds{[2..Length(wds)]};
od;


DTDINFO := [];
for x in elements do
  rr := rec(name := x);
  atr := [];
  ati := [];
  if IsBound(elementattributes.(x)) then
    a := elementattributes.(x);
    for i in [1..Length(a)-2] do
      if not a[i] in ["IMPLIED","REQUIRED","CDATA"] then 
        jj := i+2;
        while not a[jj] in ["IMPLIED","REQUIRED"] do
          jj := jj+1;
        od;
        if a[jj] = "IMPLIED" then
          Add(ati, a[i]);
        fi;
        if a[jj] = "REQUIRED" then
          Add(atr, a[i]);
        fi;
      fi;
    od;
  fi;
  rr.attr := Set(Concatenation(ati, atr));
  rr.reqattr := Set(atr);
  a := elementcontents.(x);
  if "PCDATA" in a then
    rr.type := "mixed";
  elif "EMPTY" in a then
    rr.type := "empty";
  else
    rr.type := "elements";
  fi;
  if rr.type in ["mixed", "elements"] then
    rr.content := a;
  fi;
  Add(DTDINFO, rr);
od;

PrintTo("GAPDocDtdInfo.g","GAPDOCDTDINFO:=",DTDINFO,";\n");
s:=StringFile("GAPDocDtdInfo.g"); 
s:=Filtered(s, x-> not x in WHITESPACE);  
Add(s,'\n');
FileString("GAPDocDtdInfo.g",s);  
Read("GAPDocDtdInfo.g");
Print(GAPDOCDTDINFO);

