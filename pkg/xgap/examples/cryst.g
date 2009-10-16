# An example using cryst-GAP:
# $Id:
RequirePackage("crystcat");
RequirePackage("cryst");
g := SpaceGroupBBNWZ(4,6,3,1,2);
s := GraphicSubgroupLattice(g);
m := MaximalSubgroupClassReps(g,rec(latticeequal := true));;
mm := m{[1..3]};
for i in mm do InsertVertex(s,i); od;
w := WyckoffPositions(g);;
ww := w{[1..3]};
www := List(ww,WyckoffStabilizer);
for i in www do InsertVertex(s,i); od;

