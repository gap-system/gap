LoadPackage("recog");
SetInfoLevel(InfoRecog,0);
TestGroup := function(g,n)
  local i,l,r;
  r := Runtime();
  l := [];
  for i in [1..n] do
    FindHomMethodsMatrix.LookAtOrders(fail,g);
    Add(l,LastRecognisedSporadic);
    Print(i," (",n,")\r");
  od;
  Print(Collected(l)," used time: ",Runtime()-r,"\n");
end;

AG := AtlasGenerators;
g := Group(AG("M11",1).generators); TestGroup(g,200);
g := Group(AG("M12",1).generators); TestGroup(g,200);
g := Group(AG("M22",1).generators); TestGroup(g,200);
g := Group(AG("M23",1).generators); TestGroup(g,200);
g := Group(AG("M24",1).generators); TestGroup(g,200);
g := Group(AG("HS",1).generators); TestGroup(g,200); 
g := Group(AG("J1",8).generators); TestGroup(g,200);
g := Group(AG("J2",1).generators); TestGroup(g,200);
g := Group(AG("J3",10).generators); TestGroup(g,200);
g := Group(AG("J4",1).generators); TestGroup(g,100);
g := Group(AG("Co3",1).generators); TestGroup(g,200);
g := Group(AG("Co2",3).generators); TestGroup(g,200);
g := Group(AG("Co1",2).generators); TestGroup(g,100);
g := Group(AG("Fi22",1).generators); TestGroup(g,200);
g := Group(AG("Fi23",1).generators); TestGroup(g,100);
g := Group(AG("McL",1).generators); TestGroup(g,200);
g := Group(AG("Ru",2).generators); TestGroup(g,200);
g := Group(AG("He",5).generators); TestGroup(g,200);
g := Group(AG("Suz",1).generators); TestGroup(g,200);
g := Group(AG("Th",1).generators); TestGroup(g,50);
g := Group(AG("Ly",3).generators); TestGroup(g,100);
g := Group(AG("ON",2).generators); TestGroup(g,100);
g := Group(AG("HN",2).generators); TestGroup(g,100);
g := Group(AG("Fi24'",2).generators);TestGroup(g,10);
g := Group(AG("B",1).generators); TestGroup(g,10);

