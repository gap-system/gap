####################################################################
## INPUT:
##   (1) (black box with Order oracle) group <gp>
##   (2) involution <i> of <gp>
## OUTPUT: list of one or two elements commuting with <i>
ElementsCommutingWithInvolution := function(gp, i)
local  g, y, o, m;
   g := PseudoRandom(gp);
   y := Comm(i, g);
   o := Order(y);
   m := (o - o mod 2)/2;
   if o mod 2 = 0 then
return [Comm(i, g)^m, Comm(i, g^-1)^m];
   else
return [g*Comm(i, g)^m];
   fi;
end;

##########################################################
## INPUT: matrix <mat>
## OUTPUT: <true> iff <mat> is <scalar>
IsScalarMatrix := function(mat);
return mat[1][1]*mat^0 = mat;
end;

##########################################################
## INPUT: 
##   (1) (black box) group <gp>
##   (2) element <x> supergroup of <gp>
## OUTPUT: <true> iff <x> is centralised by <gp>
IsCentralisedBy := function(gp, x)
local  central, y;
   central := true;
   for y in GeneratorsOfGroup(gp) do
      central := central and IsOne(Comm(x, y));
   od;
return central;
end;

#########################################################################
##
#F InvolutionCentraliser( <group> , <inv> , <Nrgens> , <limit> , <repn> )
##
## black box "Bray trick" for computing involution centralisers
## <Nrgens> is the number of (distinct) gens prescribed by the user before
## the algorithm cuts off; <limit> is the number of random choices the 
## algorithm will make before reporting failure; <repn> is the representation
## of <group> (either "wb" or "bb")
InvolutionCentraliser := function(gp, i, Nrgens, limit, rep)
local  cgens, n, gens;
   cgens := [i];
   n := 0;
   while n < limit and Length(cgens) < Nrgens do
      n := n+1;
      gens := ElementsCommutingWithInvolution(gp, i);
      if rep = "wb" then
         gens := Filtered(gens, x->not IsScalarMatrix(x));
      else
         gens := Filtered(gens, x->not IsCentralisedBy(gp, x));
      fi;
      cgens := Concatenation(gens, cgens);
   od;
return Group(cgens);
end;

#####################################################################################
## INPUT:
## (1) a matrix group <gp>
## (2) the (natural) vector space <V> upon which <gp> acts
## OUTPUT: the support of <gp>
GroupSupport := function(gp, V)
local  bas, x, b;
   bas := [];
   for x in GeneratorsOfGroup(gp) do
      for b in Basis(V) do
         Add(bas, b-b*x);
      od;
   od;
return Subspace(V, bas);
end;

#####################################################################################
## INPUT:
## (1) a matrix group <gp>
## (2) the (natural) vector space <V> upon which <gp> acts
## OUTPUT: the subspace of <V> centralised by <gp>
GroupCentralisedSpace := function(gp, V)
local  cent, x, nbasis;
   cent := V;
   for x in GeneratorsOfGroup(gp) do
      nbasis := NullspaceMat( x - x^0 );
      cent := Intersection(cent, Subspace(V, nbasis));
   od;
return cent;
end;

####################################################################################
## INPUT:
## (1) <m> x <m> matrix
## (2) integer <n>
## OUTPUT: matrix inserted at the top left of <n> x <n> matrix
InsertBlock := function(block, n)
local  m, f, zrow, bas, top;
   m := Length(block);
   f := Field(block[1][1]);
   zrow := List([1..n-m], i->Zero(f));
   bas := Basis( f^n );
   top := List( block, x->Concatenation(x, zrow) );
return Concatenation(top, bas{[m+1..n]});
end;

#####################################################################################
## INPUT:
## (1) a matrix
## (2) s subspace preserved by matrix
## OUTPUT: the transformation induced by the matrix on the subspace
ActionOnSubspace := function(x, W)
return List( Basis(W), w->Coefficients(Basis(W), w*x) );
end;


##################################
### routines for handling SLPs ###
##################################
ProdProg := function(slp1, slp2)
return ProductOfStraightLinePrograms(slp1, slp2);
end;

###############################
PowerProg := function(slp, n)
local prg;
   prg := StraightLineProgram([[1,n]],1);
return CompositionOfStraightLinePrograms(prg, slp);
end;

################################
InvProg := function(slp)
return PowerProg(slp, -1);
end;

###############################
ConjProg := function(slp1, slp2)
return ProdProg( InvProg(slp2) , ProdProg(slp1,slp2) );
end;

## writes a nonnegative integer <n> < <p>^<e> in base <p>
NtoPadic := function(p, e, n)
local  j, output; 
   output := [];
   for j in [1..e] do
      output[j] := (n mod p)*Z(p)^0;
      n := ( n - (n mod p) )/p;
   od;
return output;
end;

## writes a vector in GF(<p>)^<e> as a nonnegative integer 
PadictoN := function(p, e, vector)
local  j, output; 
   output := 0;
   for j in [1..e] do
      output := output + p^(j-1)*IntFFE(vector[j]);
   od;
return output;
end;

## computes the 2-part of <n>
2part := function(n)
local  k, m;
   k := 0;
   m := n;
   while m mod 2 = 0 do
      m := m/2;
      k := k + 1;
   od;
return [k,m];
end;
