#############################################################################
##
#W basic.gi               POLENTA package                     Bjoern Assmann
##
## Methods for the calculation of
## constructive pc-sequences for polycyclic rational matrix groups
##
#H  @(#)$Id: basic.gi,v 1.4 2011/09/23 13:36:31 gap Exp $
##
#Y 2003
##

#############################################################################
##
#F DetermineAdmissiblePrime(gensOfG)
##
## determines a prime number which does not divide  the denominators
## of the entries of the matrices in gensOfG and which does not divide the
## the entries of the inverses of the matrices in gensOfG
##
## input is a list of generators of a rational polycyclic matrix group
##
InstallGlobalFunction( DetermineAdmissiblePrime , function(gensOfG)
       local d,list1,list2,g,i,j,antiPrime,temp,temp2,p,found;
        d := Length( gensOfG[1] );
       list1:=[];
       list2:=[];

       # construct a list of all elements in gensOfG and their inverses
       for g in gensOfG do
           Add(list1,g);
           Add(list1,g^-1);
       od;

       #write denominators of all matrix entries in list
       for g in list1 do
           for i in [1..d] do
               for j in [1..d] do
                   Add(list2,DenominatorRat(g[i][j]));
               od;
           od;
       od;
       antiPrime:=ConsideredPrimes(list2);

        #choose a small prime which is not in antiPrime
       found:=false;
       p:=3;
       while not found do
           if not p in antiPrime then
               return p;
           fi;
           p:=NextPrimeInt(p);
       od;
end );

#############################################################################
##
#F POL_NormalSubgroupGeneratorsOfK_p(pcgs,gensOfRealG)
##
## pcgs is a constructive pc-Sequence for I_p(G)
## (image of G under the p-congruence hom.).
## This function calculates  normal subgroup generators for K_p(G)
## (the kernel of the p-congruence hom.)
##
InstallGlobalFunction( POL_NormalSubgroupGeneratorsOfK_p ,
                       function( pcgs, gensOfRealG )
   local g, relations, rightSide, leftSide, preimages, revPreimages,
         preimage, genList, ftl, n, ro, i, j, exp, conj, f_i, f_j,
         r_i, pcSeq;

   n := Length(pcgs.gens);
   preimages := [];
   relations := [];

   # catch the trivial case
   if Length(pcgs.gens)=0 then
       return gensOfRealG;
   fi;

   # calcuclate all preimages of pcgs.gens
   for i in [1..n] do
       preimage := SubsWord( pcgs.wordGens[i], gensOfRealG );
       Add( preimages, preimage);
   od;

   # Attention: In pcgs.gens we have the pc-sequence in inverse order,
   # because we built up  the structure bottom up
   pcSeq := StructuralCopy(Reversed(pcgs.gens));
   revPreimages := StructuralCopy(Reversed(preimages));

   # calculate the relative orders
   ro := RelativeOrdersPcgs_finite( pcgs );

   # express the power relations in terms of gensOfRealG
   for i in [1..n] do
       f_i := pcSeq[i];
       r_i := ro[i];
       exp := ExponentvectorPcgs_finite( pcgs, f_i^r_i );
       leftSide := revPreimages[i]^r_i;
       rightSide := Exp2Groupelement(revPreimages,exp);
       Add(relations,leftSide*(rightSide^-1));
   od;

   # conjugation relations
   for i in [1..n] do
       for j in [1..(i-1)] do
           f_i := pcSeq[i];
           f_j := pcSeq[j];
           conj := (f_j^-1)*f_i*f_j;
           exp := ExponentvectorPcgs_finite( pcgs, conj);
           leftSide := (revPreimages[j]^-1)*revPreimages[i]*revPreimages[j];
           rightSide := Exp2Groupelement(revPreimages,exp);
           Add( relations, leftSide*(rightSide^-1));
       od;
   od;

   # Add  some other relations, because we changed the generating
   # set of the image under the p-congruence hom.
   for i in [1..Length(pcgs.gensOfG)] do
       exp := ExponentvectorPcgs_finite( pcgs, pcgs.gensOfG[i]);
       rightSide := Exp2Groupelement( revPreimages, exp);
       leftSide := gensOfRealG[i];
       Add( relations, leftSide*(rightSide^-1));
   od;
   return relations;
end );

#############################################################################
##
#F Exp2Groupelement(list,exp)
##
InstallGlobalFunction( Exp2Groupelement, function(list,exp)
   local g,i;
   g:=list[1]^0;
   for i in [1..Length(list)] do
       g:=g*list[i]^exp[i];
   od;
   return g;
end );

#############################################################################
##
#F CopyMatrixList(list)
##
InstallGlobalFunction( CopyMatrixList, function(list)
   local i,j,k,list2;
   list2:=[];
   for i in [1..Length(list)] do
       Add(list2,[]);
       for j in [1..Length(list[i])] do
           Add(list2[i],[]);
           for k in [1..Length(list[i][j])] do
               Add(list2[i][j],[]);
               list2[i][j][k]:= list[i][j][k];
           od;
       od;
   od;
   return list2;
end );


#############################################################################
##
#F POL_CopyVectorList(list)
##
InstallGlobalFunction( POL_CopyVectorList, function(list)
   local i,j,k,list2;
   list2:=[];
   for i in [1..Length(list)] do
       Add(list2,[]);
       for j in [1..Length(list[i])] do
           Add(list2[i],[]);
               list2[i][j]:= list[i][j];
       od;
   od;
   return list2;
end );

#############################################################################
##
#F POL_NormalSubgroupGeneratorsU_p( pcgs_GU, gens, gens_K_p )
##
## pcgs_GU  is a constructive pc-Sequence for G/U,
## this function calculates normal subgroup generators for U_p(G)
##
InstallGlobalFunction( POL_NormalSubgroupGeneratorsU_p ,
                       function( pcgs_GU, gens, gens_K_p )
   local relations,rightSide,leftSide,preimages,revPreimages,
         preimage,genList,ftl,n,ro,i,j,exp,conj,f_i,f_j,r_i,pcs, g, k;

   # setup
   pcs := pcgs_GU.pcs;
   n:=Length(pcs);
   preimages:=[];
   relations:=[];
   k := Length( pcgs_GU.pcgs_I_p.gens );

   # catch the trivial case (G/U trivial)
   if Length(pcgs_GU.pcs)=0 then
      return gens;
   fi;

   # catch the trivial case (U_p = 1)
   if Length(pcgs_GU.radicalSeries)=2 then
      return [];
   fi;

   # calculate the relative orders
   #ro:= RelativeOrdersPcgs( pcgs );
   ro := RelativeOrders_CPCS_FactorGU_p( pcgs_GU );

   # the elements stored in gens_K_p where found by evaluating
   # the pcp-relations of G/I_p. So we don't have to calculate them
   # again.
   for g in gens_K_p do
       exp := ExponentVector_CPCS_FactorGU_p( pcgs_GU, g );
       leftSide := g;
       rightSide := Exp2Groupelement( pcs, exp );
       Add( relations, leftSide*(rightSide^-1) );
   od;

   # Express the power relations in terms of gens
   for i in [ (k+1)..n ] do
       f_i:=pcs[i];
       r_i:=ro[i];
       # we have to exclude the case r_i=0 because this means that
       # the order is equal to infinity
       if not r_i=0 then
           exp:=ExponentVector_CPCS_FactorGU_p(pcgs_GU,f_i^r_i);
           leftSide:=f_i^r_i;
           rightSide:=Exp2Groupelement(pcs,exp);
           Add( relations, leftSide*(rightSide^-1) );
       fi;
   od;

   # conjugation relations
   for i in [ (k+1)..n ] do
       for j in [1..(i-1)] do
           f_i := pcs[i];
           f_j := pcs[j];
           conj := (f_j^-1)*f_i*f_j;
           exp := ExponentVector_CPCS_FactorGU_p( pcgs_GU, conj );
           leftSide := (pcs[j]^-1)*pcs[i]*pcs[j];
           rightSide := Exp2Groupelement(pcs,exp);
           Add( relations, leftSide*(rightSide^-1) );
       od;
   od;
   relations := Filtered( relations,x -> not x=x^0 );
   if Length( relations ) = 0 then relations[1] := gens[1]^0; fi;
   return relations;
end );

#############################################################################
##
#E
