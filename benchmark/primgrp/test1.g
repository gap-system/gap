#description Consistency checks for the primitive groups library
#author Alexander Konovalov
#timelimit 1
#cmdlineops
#packages: SCSCP (for error handling with CALL_AND_CATCH)

ReadPackage("scscp/lib/errors.g");

has_errors := false;
Read("testprim.g");
starttime:=Runtime();

for s in [1..30] do
    Print("Testing ", NrPrimitiveGroups(s), " primitive groups of degree ", s, "\n");
    TestAllPrimitiveGroups( s );
od;
Print("\n");

if has_errors then
  Print("*** FAIL\n");
fi;

Print("*** RUNTIME ",Runtime()-starttime,"\n");
