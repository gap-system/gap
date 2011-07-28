# RequirePackage("NQL");
# 
# G:=NilpotentQuotient(ExamplesOfLPresentations(1),2);
# 
# # as <G> is finite
# iso:=IsomorphismPcGroup(G) ;
# AutN := AutomorphismGroup( Range( iso ) );
# osi:=InverseGeneralMapping(iso);
# Aut := Group( List(GeneratorsOfGroup(AutN), x-> iso*x*osi));
# Size(Aut);

G:=SmallGroup(8,3);
iso:=IsomorphismPcpGroup(G);
osi:=InverseGeneralMapping(iso);
N:=Range( iso );
Q:=Range( IsomorphismPcpGroup( SmallGroup(4,2) ) );

AutN:=AutomorphismGroup(G);
Aut:= Group( List(GeneratorsOfGroup(AutN),x-> osi*x*iso ) );
SetAutomorphismGroup( N, Aut );

# kein hom, da Q.1^Coupling * Q.2^Coupling * Q.1^Coupling * Q.2^Coupling \neq 1
## #Coupling:=GroupHomomorphismByImagesNC(Q,Aut,[Q.1,Q.2],[Aut.1,Aut.2]);
## Coupling:=GroupHomomorphismByImagesNC(Q,Aut,[Q.1,Q.2],[Aut.1,Aut.3]);
Coupling := GroupHomomorphismByImagesNC(Q,Aut,[Q.1,Q.2],[Aut.1,Aut.3]);
