
# this is a development utility to generate the files like
# bibxmlextinfo.g or gapdocdtdinfo.g

## not interesting enough to properly parse DTDs, we later give 
## access to a proper validating parser instead

dtd := StringFile("bibxmlext.dtd");
NormalizeWhitespace(dtd);

# read entities
entities := rec();
pos := PositionSublist(dtd, "<!ENTITY % ");
while pos <> fail do
  pos := pos+11;
  tmp := Position(dtd, ' ', pos);
  nam := dtd{[pos..tmp-1]};
  cont := dtd{[tmp+2..Position(dtd, '"', tmp+1)-1]};
  entities.(nam) := cont;
  pos := PositionSublist(dtd, "<!ENTITY % ", pos);
od;

# substitute entities
while ForAny(RecNames(entities), a-> PositionSublist(dtd,
                                            Concatenation("%",a)) <> fail) do
  for a in RecNames(entities) do
    dtd := SubstitutionSublist(dtd, Concatenation("%",a,";"), entities.(a));
  od;
od;

# get elements 
elements := rec();
pos := PositionSublist(dtd, "<!ELEMENT ");
while pos <> fail do
  pos := pos+2;
  tmp := Position(dtd, '>', pos);
  if dtd[tmp-1] = ' ' then
    tmp := tmp-1;
  fi;
  s := dtd{[pos..tmp-1]};
  tmp := Position(s, ' ',8);
  nam := s{[9..tmp-1]};
  s := s{[tmp+1..Length(s)]};
  s := SubstitutionSublist(s, "?", ", optional");
  s := SubstitutionSublist(s, "*", ", repeated");
  s := SubstitutionSublist(s, "(", "[");
  s := SubstitutionSublist(s, ")", "]");
  s := SubstitutionSublist(s, "|", ", or,");
  s := SubstitutionSublist(s, "#", "");
  if s{[1,Length(s)]} <> "[]" then
    s := Concatenation("[",s,"]");
  fi;
  ss := "";
  inword := false;
  for x in s do
    if (not inword and x in LETTERS) or (inword and not x in LETTERS) then
      Add(ss,'"');
      inword := not inword;
    fi;
    Add(ss, x);
  od;
  elements.(nam) := EvalString(ss);
  pos := PositionSublist(dtd, "<!ELEMENT ", pos);
od;

# attributes
attributes := rec();
pos := PositionSublist(dtd, "<!ATTLIST");
while pos <> fail do
  pos2 := Position(dtd, '>', pos);
  a := dtd{[pos+10..pos2-1]};
  pos := pos2;
  tmp := WordsString(a);
  attributes.(tmp[1]) := tmp{[2..Length(tmp)]};
  pos := PositionSublist(dtd, "<!ATTLIST", pos);
od;

PrintTo("bibxmlextinfo.g", "Bibxmlext := \n", [elements, attributes], ";\n");

    

  

