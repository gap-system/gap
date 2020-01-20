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
Print("*** RUNTIME ",Runtime()-starttime,"\n");
if l<>1954 then
  Print("*** FAIL\n");
  QuitGap(1);
else
  QuitGap(0);
fi;
