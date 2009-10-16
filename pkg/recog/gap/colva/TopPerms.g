#represents group element g from the main branch as a permutation of the 
#socle factors.

MySocleAction:= function(soc, g)
local grp;
grp:= PermAction(GroupWithGenerators([g]), group(soc), homom(soc), group(factor(soc)));
if not Size(GeneratorsOfGroup(grp)) = 1 then
  return fail;
fi;
return GeneratorsOfGroup(grp)[1];
end;

  
  
#copied from TrivialActionPushdown in ordering.m
RearrangeTopFactors:= function(ri)

local soc_found, soc, nri, d, R, phi, I, i, Pgens, Pinv_ims, P, perms, 
  ki, pgs,alpha,zeta,pgs_ims;

nri:= StructuralCopy(ri);
soc_found:= false;
while Haskernel(nri) and not soc_found do
  if HasTFordered(factor(nri)) and TFordered(factor(nri)) = "Socle" then
      soc_found:= true;
  fi;
  if not soc_found then
    nri:= kernel(nri);
  fi;
od;

if not soc_found then 
  Print("solvable group, nothing do do\n");
  return ri; 
fi;
 
#was hoping to use this a short-cut, but it seems that 
#groups in the socle are not necessarily represented as explicit direct
#products. 
if not IsDirectProduct(group(factor(nri))) then 
  SetTFordered(ri, "Pker");
  return ri;
fi;

soc:= nri;
R:= RefineMap(group(soc), homom(soc), group(factor(soc)));
phi:= R[1];
I:= R[2];
Sethomom(soc, phi);
Setgroup(factor(soc), I);

#now we find the degree of the permutation action.
Pgens:= [Identity(SymmetricGroup(2))];
Pinv_ims:= [Identity(overgroup(soc))];
P:= GroupWithGenerators(Pgens);

#work up the tree, checking whether action is trivial (in 
#which case push down to Pker). 
while (Hasparent(nri)) do
  nri:= parent(nri);

  #now need to find the permutation action of the preimages of the 
  #generators of  the factor on the factors of the socle.  
  perms:= List(pregensfac(nri), x ->MySocleAction(soc,x));

  #first do the case where this is not a new action - must belong to a lower
  #factor group or be trivial.
  if IsSubgroup(P, GroupWithGenerators(perms)) then
    if HasTFordered(factor(kernel(nri))) and (factor(kernel(nri))!.TFordered = "Socle") then 
      #don't reorder, just label this as the beginning of Pker
      SetTFordered(nri, "Pker");
    elif HasTFordered(kernel(nri)) and kernel(nri)!.TFordered = "Pker" then
      #move the label for Pker one level higher
      Unbind(kernel(nri)!.TFordered);
      ResetFilterObj(kernel(nri), HasTFordered);
      SetTFordered(nri, "Pker");
    else
      ki:= GroupHomomorphismByImagesNC(P, overgroup(soc), Pgens, Pinv_ims);
      #have to move down below all bits that act nontrivially on socle.
      while not (HasTFordered(factor(kernel(nri))) and 
                factor(kernel(nri))!.TFordered = "Socle") do
          if IsBound(group(factor(kernel(nri)))!.Pcgs) then 
            #move past a (soluble) PC group
            pgs:= pregensfac(kernel(nri));
            pgs_ims:= List(pgs, x->x*Image(ki,MySocleAction(soc, x))^-1);
            alpha:= GroupHomomorphismByImagesNC(group(factor(kernel(nri))), overgroup(nri), pgs, pgs_ims);
            zeta:= function(g)
               return Image(homom(kernel(nri)),(g*Image(alpha, 
                    Image(homom(kernel(nri)), g))^-1));
            end;
          else
            #should have a nonabelian group to move past here, 
            #according to Mark, it'll be a permutation group by this point.
            #I think what we should be doing is same style as "past non ab"
            #but that we don't need the checks, as the trivial action should
            #definitely pass down. however, will just use zeta for now.
            zeta:= PastNonAb(nri);
            if zeta = false then
              Print("unexpected error in rearrange top factors: found a layer with trivial action that won't push down");
              return false;
            fi;
          fi;
          nri:= SwapFactors(nri, zeta);
      od;
    fi;
  else 
  #have found some new permutations to add
    for i in [1..Length(perms)] do
      if not perms[i] in P then
        Add(Pgens, perms[i]);
        P:= GroupWithGenerators(Pgens);
        Add(Pinv_ims, pregensfac(nri)[i]);
      fi;
    od;
  fi;
od;
#now need to put the map from G to the perm group in to the top level of
#ri, but should discuss how we want to do this.
ri!.HomomToSocleAction:=  g->MySocleAction(soc, g);
ri!.SocleAction:= P;
return ri;
end;
