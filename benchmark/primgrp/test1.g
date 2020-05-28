#description Consistency checks for the primitive groups library
#author Alexander Konovalov
#timelimit 1
#cmdlineops

has_errors := false;
Read("testprim.g");
starttime:=Runtime();

for s in [1..30] do
    Print("Testing ", NrPrimitiveGroups(s), " primitive groups of degree ", s, "\n");
    TestAllPrimitiveGroups( s );
od;
Print("\n");

Print("*** RUNTIME ",Runtime()-starttime,"\n");

if has_errors then
  Print("*** FAIL\n");
  QuitGap(1);
else
  QuitGap(0);
fi;
