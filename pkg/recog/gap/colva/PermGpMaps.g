## Functions to compute a sequence of maps for a normal series in a permuation group
## Uses only standard BSGS functions

PermGrpMaps := function(G,ri)
 
 local g,Soc,Rad,C,phi,i,Facs,temp,Orbs,PermtoPc;

# First Solvable groups  
 if IsSolvable(G) then
# Want to construct a PC presentation - not sure how best to do this, so currently doing nothing!
   PermtoPc := IsomorphismPcGroup(G);
   
   ri!.Maps := [ PermtoPc ];
   ri!.Names := [Size(G)];
   ri!.Class := "Permutation Group";
   ri!.Scalars := [0];
   ri!.TFLayers := [4];
   ri!.MapImages := [Image(PermtoPc)];
   return true;
 fi;

# Don't know what I am doing here!

# Use ChiefSeriesThrough for the moment
 Soc := Socle(G); Rad := RadicalGroup(G);
 C := ChiefSeriesThrough(G,[Soc,Rad]); 
 phi := List([1..(Size(C)-1)],i->NaturalHomomorphismByNormalSubgroupNC(C[i],C[i+1]));
 Facs := List(phi,i->Image(i));
 
 ri!.Maps := phi;
 ri!.MapImages := [];
 ri!.Names := [];
 ri!.Scalars := List(phi,x->0);
 ri!.TFlevels := [];
 i := Size(phi);
 while i>0 do
   if IsSubgroup(Rad,C[i]) then
     ri!.TFlevels[i]:=4;
   elif IsSubgroup(Soc,C[i]) then
     ri!.TFlevels[i]:=3;
   else
     ri!.TFlevels[i]:=1;
   fi;
   if IsSolvable(Facs[i]) then
     ri!.Names[i]:=Size(Facs[i]);
     PermtoPc := IsomorphismPcGroup(Facs[i]);
     ri!.Maps[i] := ri!.Maps[i]*PermtoPc;
     ri!.MapImages[i] := StructuralCopy(Image(PermtoPc));
   else
     Orbs := Orbits(Facs[i]);
     temp := IdentifySimple(Image(ActionHomomorphism(Facs[i],Orbs[1])));
     temp := temp[2];
     if not IsString(temp) then temp := temp[1]; fi;
     ri!.Names[i]:=[temp, Size(Orbs)];
     ri!.MapImages[i] := ShallowCopy(Facs[i]);
   fi;
   i := i-1;
 od;
     
 return true;
end;

    
