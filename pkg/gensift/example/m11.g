# $Id: m11.g,v 1.1.1.1 2004/12/22 13:22:48 gap Exp $
# Example for sifting in M11:
LoadPackage("atlasrep");
gens := AtlasGenerators("M11",1);
g := Group(gens.generators);
sr := PrepareSiftRecords(PreSift.M11,g);
ResetGeneralizedSiftProfile(Length(sr));
Print("Results: ",TestGeneralizedSift(sr,g,1/100,50),"\n");
DisplayGeneralizedSiftProfile();
