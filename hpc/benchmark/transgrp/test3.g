#description Construct the transitive groups of degree 20
#author Alexander Hulpke
#timelimit 1
#cmdlineops
#packages
InfoAli:=NewInfoClass("InfoAli");
Read("pnormea.g");
Read("mintransind.g");
Read("examine4");
starttime:=0;
l:=Length(MakeTransitiveGroups(20));
if l<>1117 then
  Print("*** FAIL\n");
fi;
Print("*** RUNTIME ",Runtime()-starttime,"\n");
