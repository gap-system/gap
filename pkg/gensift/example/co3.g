# $Id: co3.g,v 1.1.1.1 2004/12/22 13:22:48 gap Exp $
# Example for sifting in Co3:
LoadPackage("atlasrep");
gens := AtlasGenerators("Co3",1);
g := Group(gens.generators);
sr := PrepareSiftRecords(PreSift.Co3,g);
ResetGeneralizedSiftProfile(Length(sr));
Print("Results: ",TestGeneralizedSift(sr,g,1/100,50),"\n");
DisplayGeneralizedSiftProfile();
