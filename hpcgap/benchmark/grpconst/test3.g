#description Construct and test all groups of orders from 1 to 100
#author Alexander Konovalov
#timelimit 1
#cmdlineops
#packages: grpconst

Read("grpconst.g" );

has_errors:=false;

starttime:=Runtime();

for i in [257..511] do
    Print("Constructing and testing all groups of order ", i, "\n");
    ConstructAndTestAllGroups( i );
od;
    
if has_errors then
  Print("*** FAIL\n");
fi;

Print("*** RUNTIME ",Runtime()-starttime,"\n");
