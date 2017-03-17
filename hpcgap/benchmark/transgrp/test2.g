#description Construct the transitive groups of degree 16
#author Alexander Hulpke
#timelimit 1
#cmdlineops
#packages
InfoAli:=NewInfoClass("InfoAli");
Read("pnormea.g");
Read("mintransind.g");
Read("examine4");
starttime:=0;
l:=Length(MakeTransitiveGroups(16));
if l<>1954 then
  Print("*** FAIL\n");
fi;
Print("*** RUNTIME ",Runtime()-starttime,"\n");

