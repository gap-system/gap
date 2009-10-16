

IsImageTrivial := function(I)
# Is the group I trivial or a direct product of scalars?
 local n,L,i;

 if IsPermGroup(I) then return IsTrivial(I); fi;

 if IsMatrixGroup(I) then return IsScalarGroup(I); fi;

 n := NumberOfDPComponents(I);
 L := List([1..n],i->Image(MyProjection(I,i)));
 for i in [1..n] do
   if not IsImageTrivial(L[i]) then return false; fi;
 od;
 return true;
end;

SolveLeafPc := function(ri,rifac)
# Performs constructive recognition of a PC group
 local I,gens,n,trivgens,T,rho,P,mems,T2,ItoT2;

 I := group(rifac);

 if IsTrivial(I) then
   SetName(rifac,"Trivial Group");
   Setslptonice( rifac, 
                StraightLineProgramNC([[[1,0]]],Length(GeneratorsOfGroup(I))));
   Setnicegens(rifac, [One(I)]);
   Setslpforelement( rifac, 
     function(rifac,g)
       return StraightLineProgramNC( [ [1,0] ], 1 );    
     end);
   Setcalcnicegens(rifac, CalcNiceGensGeneric);
   return true;
 fi;

 gens := GeneratorsOfGroup(I);
 n := Size(gens);

 trivgens := GeneratorsWithMemory(List(gens,x->()));
 T := GroupWithGenerators(trivgens);
 rho := GroupHomomorphismByImages(I,T,gens,trivgens);
 P := Pcgs(I);
 Setnicegens(rifac,AsList(P));
 mems := List(AsList(P),x->ImageElm(rho,x));
 Setslptonice(rifac,SLPOfElms(mems));   
 Setcalcnicegens(rifac, CalcNiceGensGeneric);

# Solving the rewriting problem
 T2 := GroupWithMemory(GroupWithGenerators(List(AsList(P),x->())));
 ItoT2 := GroupHomomorphismByImages(I,T2,AsList(P),GeneratorsOfGroup(T2)); 

 Setslpforelement(rifac,
   function(ri,g)
     return SLPOfElm(ImageElm(ItoT2,g));
   end);  

 return true;
end;  


SolveLeafTrivial := function(ri,rifac)
# Performs constructive recognition of a trivial group
# redfines homom ri
 local I,T,x,oldmap;
 I := ShallowCopy(group(rifac));
 T := CyclicGroup(1);
 Setgroup(rifac,T);
 SetName(rifac,"trivial");
 oldmap := StructuralCopy(homom(ri));
 if IsPermGroup(I) then
   Sethomom(ri,GroupHomomorphismByFunction(group(ri),T,
function(g)
local x;
 x := ImageElm(oldmap,g);
 if not IsOne(x) then return fail; fi;
 return One(T);
end));      
 
 elif IsMatrixGroup(I) then
   Sethomom(ri,GroupHomomorphismByFunction(group(ri),T,
function(g)
local x;
 x := ImageElm(oldmap,g);
 if not IsScalarMatrix(x) then return fail; fi;
 return One(T);
end));      
 
 else
   Sethomom(ri, GroupHomomorphismByFunction(group(ri),T,
function(g)
local x,n;
 x := ImageElm(oldmap,g);
 n := Size(I!.DirectProductInfo!.groups);

 if not ForAll([1..n],i->IsScalarMatrix(ImageElm(Projection(I,i),x))) then return fail; fi;
 return One(T);
end));      

 fi;
 
  return SolveLeafPc(ri,rifac);
end;


IsDirectProduct := function(I)
 if HasDirectProductInfo(I) then
   return true;
 elif not HasParentAttr(I) then return false; 
 elif HasDirectProductInfo(I!.ParentAttr) then
   return true;
 else
   return false;
 fi;
end;


InstallGlobalFunction(RecogniseLeaf,
function(ri,I,name)
# Recognises I which is the image of homom(ri)
 local rifac,bool;

 rifac := rec();
 Objectify(RecognitionInfoType,rifac);;
 SetFilterObj(rifac,IsLeaf);
 Setparent(rifac,ri);
 Setfactor(ri,rifac);
 Setgroup(rifac,I);
 if IsPcGroup(I) then 
   bool := SolveLeafPc(ri,rifac);
   Setfhmethsel(rifac,"Pc group"); 

   if bool then SetFilterObj(rifac,IsReady);
     return rifac;
   fi;

 elif IsImageTrivial(I) then
   bool := SolveLeafTrivial(ri,rifac);
   Setfhmethsel(rifac,"trivial group"); 

   if bool then SetFilterObj(rifac,IsReady);
     return rifac;
   fi;

 elif IsDirectProduct(I) then
   bool := SolveLeafDP(ri,rifac,name);
   Setfhmethsel(rifac,"direct product group"); 
   if bool then SetFilterObj(rifac,IsReady);
     return rifac;
   fi;

 elif IsMatrixGroup(I) then
   Setfhmethsel(rifac,"matrix group"); 
#   rifac := RecogniseGroup(I);
#   return rifac;
   if name[1][1]='L' and findnpe(name[1])[1]=DimensionOfMatrixGroup(I) and findnpe(name[1])[2]^findnpe(name[1])[3]=Size(FieldOfMatrixGroup(I))  then
     
     bool := FindHomMethodsMatrix.NaturalSL(rifac,I);
     if bool=true then SetFilterObj(rifac,IsReady);
       Setcalcnicegens(rifac, CalcNiceGensGeneric);
       SetSize(I,SimpleGroupOrder(name[1]));
       SetSize(rifac,Size(I));
       SetName(rifac,name[1]);
       return rifac;
     fi;
   fi;
   rifac := RecogniseGroup(I);
   SetSize(I,SimpleGroupOrder(name[1]));
   SetSize(rifac,Size(I));
   SetName(rifac,name[1]);
   return rifac;
   
   


 elif IsPermGroup(I) then
   Setfhmethsel(rifac,"perm group"); 
   SetName(rifac,name[1]);
   bool := FindHomMethodsPerm.StabChain(rifac,I);
   SetSize(I,SimpleGroupOrder(name[1]));
   if bool then SetFilterObj(rifac,IsReady);
     Setcalcnicegens(rifac, CalcNiceGensGeneric);
     return rifac;
   fi;
 fi;
  
 Error("Can't handle this type of leaf");
end
);
