#description Consistency checks for the small groups library
#author Alexander Konovalov
#timelimit 1
#cmdlineops
#packages

has_errors := false;
Read("testgrps.g");
starttime:=Runtime();

for s in [257..511] do
    Print("Testing groups of order ", s, " \n");
    TestAllGroups( s );
od;
Print("\n");

Print("*** RUNTIME ",Runtime()-starttime,"\n");

if has_errors then
  Print("*** FAIL\n");
  QuitGap(1);
else
  QuitGap(0);
fi;
