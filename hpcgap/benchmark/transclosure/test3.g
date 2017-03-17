#description transitive closure of binary relations
#author Alexander Konovalov
#timelimit 1
#cmdlineops -o 1g
#packages: FR (only to construct binary relations for the test) 

LoadPackage("FR");

starttime:=Runtime();

i:=8;

  Print("Test ", i, "\n");
  n:=GrigorchukMachine^i;
  r:=BinaryRelationOnPointsNC(n!.transitions);
  t:=TransitiveClosureBinaryRelation(r);

Print("*** RUNTIME ",Runtime()-starttime,"\n");
