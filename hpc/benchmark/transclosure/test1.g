#description transitive closure of binary relations
#author Alexander Konovalov
#timelimit 1
#cmdlineops
#packages: FR (only to construct binary relations for the test) 

LoadPackage("FR");

starttime:=Runtime();

for i in [1..6] do
  Print("Test ", i, "\n");
  n:=GrigorchukMachine^i;
  r:=BinaryRelationOnPointsNC(n!.transitions);
  t:=TransitiveClosureBinaryRelation(r);
od;

Print("*** RUNTIME ",Runtime()-starttime,"\n");
