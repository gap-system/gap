# This is the fifth example from the XGAP manual:
# A finitely presented group.
# $Id:
f := FreeGroup(2);
g := f/[f.1^6];
s := GraphicSubgroupLattice(g);
IdGroup(SymmetricGroup(3));
s3 := SmallGroup(6,1);
IMAGE_GROUP := s3;;
