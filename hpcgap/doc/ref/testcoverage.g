# This simple script checks how the manual is covered with examples.
# It prints the list of ManSections that have no examples, and also
# a short summary with the number of ManSections with/without examples.

Read( "makedocreldata.g" );

doc := ComposedXMLString(
    GAPInfo.ManualDataRef.pathtodoc, 
    GAPInfo.ManualDataRef.main, 
    GAPInfo.ManualDataRef.files);;

r := ParseTreeXMLString(doc);;

CheckAndCleanGapDocTree(r);

x:=XMLElements( r, ["ManSection"] );;

with:=0;
without:=0;

for m in x do
  y := XMLElements( m, ["Example"] );
  if Length(y)=0 then
    if IsBound(m.content[1].attributes) and
      IsBound(m.content[1].attributes.Name) then
      Print( m.content[1].attributes.Name );
    elif IsBound(m.content[2].attributes) and
      IsBound(m.content[2].attributes.Name) then
      Print( m.content[2].attributes.Name );
    else
      Print( m.content[1].content[1].content );
    fi;  
    without := without + 1;
    Print("\n");
  else
    with := with + 1;
  fi;
od;

Print( "*** TEST COVERAGE REPORT: \n");
Print( Length(x), " mansections \n");
Print( with, " with examples \n");
Print( without , " without examples \n");
