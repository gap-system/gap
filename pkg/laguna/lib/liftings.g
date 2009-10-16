#############################################################################
##  
#W  liftings.g                 The LAGUNA package           Wolfgang Kimmerle
#W                                                        Alexander Konovalov
##
#H  $Id: liftings.g,v 1.4 2007/03/26 20:36:52 alexk Exp $
##
#############################################################################


###########################################################################
#
#              MODULAR ISOMORPHISM PROBLEM LIFTING TESTS
#
###########################################################################


###########################################################################
##
##  RelsIndices( G )
##
RelsIndices:=function(G)
local gens,   # minimal generating set of the group G
      f,      # isomorphism from G to the finitely presented group H
      F,      # free group used to test results 
      H,      # image of this isomorphism
      fgens,  # images of minimal generating set of G in H
      fs,     # isomorphism from H to simplified fp group HS
      HS,     # an image of this isomorphism,
      fsgens, # images of minimal generating set of G in HS
      rels,   # defining relations of the simplified fp group HS
      relsindices, # their indices, returned by this function
      testrels,    # relations defined by the returned indices
      r,      # current relation from rels
      ind,    # indices of the current relation
      extrep, # external representation of the current relation r
      elts,   # numbers of generators from the current relation
      pows,   # powers of generators from the current relation
      i, j, x,# cycle parameters
      ords;   # orders of elements from the minimal generating set of HS;
gens:=MinimalGeneratingSet(G);
f:=IsomorphismFpGroup(G);
H:=Image(f);
fgens:=List(gens, x -> x^f);
fs:=IsomorphismSimplifiedFpGroup(H);
HS:=Image(fs);
if Length(GeneratorsOfGroup(HS)) = Length(gens) then
  fsgens:=List(fgens, x -> x^fs);
  if fsgens=GeneratorsOfGroup(HS) then
    ords:=List(fsgens,Order);
    rels:=ShallowCopy( RelatorsOfFpGroup(HS) );
    # for some groups, e.g. [16,6] and [32,11] we need to add
    # ALL relations determining the order of generators, otherwise
    # some of them will be omitted and we will have an error while
    # creating the group from relations with only positive powers
    # of generators
    for x in fsgens do
      Add( rels, x^Order(x) );
    od;
    relsindices:=[];
    for r in rels do
      ind:=[];
      extrep:=ExtRepOfObj(r);
      elts:=List([1,3 .. Length(extrep)-1], i -> extrep[i]);
      pows:=List([2,4 .. Length(extrep)  ], i -> extrep[i]);
      for i in [1..Length(elts)] do
        if pows[i]>0 then
          for j in [1..pows[i]] do
            Add(ind,elts[i]);
          od;
        else
          for j in [1 .. (ords[elts[i]]+pows[i]) ] do
            Add(ind,elts[i]);
          od;
        fi;
      od;
      # here we use addset since it might happen that this relation
      # was already there (when we enforced adding relations, determining
      # powers of generators, it might be that some of them were already 
      # there). There is some overhead that may neglected because of the
      # simplicity of the computation that mainly rewrites an external 
      # presentation of the relation
      AddSet(relsindices, ind);
    od;
    
    # test that the result is correct
    # F is a free group of rank that is the maximal number of generators
    F := FreeGroup(Maximum( Flat( relsindices ) ) );       
    testrels := List( relsindices, i -> 
                      Product( List( i, j -> GeneratorsOfGroup( F )[j] ) ) );  
    if IdGroup(G) <> IdGroup(F/testrels) then
      Error("LAGUNA: relsindices do not determine the group !!!\n");
    fi;

    return relsindices;
  fi;
else
  Error("SimplifiedFpGroup was not enough!!!");
fi;
end;


###########################################################################
##
##  Lookahead( KG, V, relsindex, maps, n, look, F, rels,
##             pin1, dimJ, basJ, BasIn )
##
Lookahead := function( KG, V, relsindex, maps, n, look, F, rels,
                       pin1, dimJ, basJ, BasIn )
local f, H_fp, H_free, h_free, h, r, rh, x, ims, back, obs, obscoeffs,
i, j, f1,f2,f3, strel, gens, m, row, t, b, prod, prodcoeffs,
sysmat, vec, fullmat, res, left, right, firstpos, flag, k, sysrel,
r1, r2, rn, l;

if look="full" then
  # we do nothing here and go further since the line below
  # was already computed in the main program (we need not lastn here)
  # lastn:=Minimum( 2*n, AugmentationIdealNilpotencyIndex(KG) );
elif n+look<=2*n then
  # we do nothing here and go further since the line below
  # was already computed in the main program (we need not lastn here)
  # lastn:=Minimum( n+look, AugmentationIdealNilpotencyIndex(KG) );
else
  # or we return the output back since lookahead can not be applied
  Info(LAGInfo, 2, "LAGInfo: lookahead ignored since 2*n<n+", look);
  return maps;
fi;

Info(LAGInfo, 3, "LAGInfo: starting lookahead with n=", n, " and look=", look );

# create an empty list to store mappings liftable up to I^lastn
res:=[];

for f in maps do
  Info(LAGInfo, 3, "LAGInfo: calculated system for ", Position(maps,f),
                   "-th homomorphism of ", Length(maps) );
  # calculating preimages of f(x) in V(KG)
  ims:=List( MappingGeneratorsImages(f)[2],
             x -> PreImagesRepresentative(pin1,x));
  # and returning them to the group algebra KG
  ims:=List(ims, x -> x^NaturalBijectionToNormalizedUnitGroup(KG));

  # substitute them into group relations and calculate obstructions
  obs:=List(rels, r -> (MappedWord(r, GeneratorsOfGroup(F), ims)-One(KG) ) );

  # find coefficient of obstructions in the basis of I^n and take only
  # first dimJ values
  # we will obtain the matrix with rows corresponding to relations
  # and columns corresponding to basis elements of J

  obscoeffs:=List(obs, r -> Coefficients(BasIn,r){[1 .. dimJ]});
  obscoeffs:=-One(UnderlyingField(KG))*obscoeffs;
  # Print("OBSTRUCTIONS : \n");
  # Display(obscoeffs);

  # now we generate the matrix of the system of linear equations
  sysmat:=[];

  for rn in [1 .. Length(rels)] do
    # generate subsystem of linear equations corresponding to the rn-th relation
    # taking rn-th relation and substitute basis elements instead of one
    # of each components
    # Print("relation ", rn,
    #       ", t=", [1..Length(relsindex[rn])],
    #       ", b=", [1..Length(basJ)], "\n");

    # create a zero matrix with dimJ rows
    # and dimJ*Number_of_generators_of_H columns
    sysrel:=List([1 .. dimJ ], i ->
            List([1 .. dimJ*Length(ims)], k -> Zero(UnderlyingField(KG))));
    # in this matrix m-th row corresponds to equation, arising from the
    # m-th element of basJ

    for t in [1..Length(relsindex[rn])] do
    # fixing t-th entry in the set of rn-th relation entries

      # calculating products from is left and right sides
      left :=Product(List([1..t], i -> ims[relsindex[rn][i]]));
      right:=Product(List([t+1..Length(relsindex[rn])], i ->
                     ims[relsindex[rn][i]]));

      for b in [1 .. Length(basJ)] do
        # substituting b-th element of the basis of J
        prod:=left * basJ[b] * right;
        # taking its first dimJ coordinates in the same basis
        prodcoeffs:=Coefficients(BasIn,prod){[1..dimJ]};
        # we obtain coefficients (c_1, ... c_dimJ)
        # standing for x_kl in the equation number m:
        # - k is fixed and corresponds to the number of generator,
        #   modified by multiplication on the basis element from basJ[b],
        #   and could be obtained as k=relsindex[rn][t]
        # - l is determined from the number of basis element,
        #   used for modification,
        #   i.e. l=b
        # - m is the position of the coefficient in the list prodcoeffs, i.e. the
        #   number of the basis element corresponding to this coefficient
        # Thus, we need to add m-th coefficient to l-th element in the k-th
        # block in the m-th row of sysrel

	k:=relsindex[rn][t];
	for m in [1..Length(prodcoeffs)] do
	  sysrel[m][dimJ*(k-1)+b]:=sysrel[m][dimJ*(k-1)+b]+prodcoeffs[m];
	od;

      od; # finished substitution of basis elements into t-th entry of the
          # rn-th relation
    od; # finished calculation for all t from 1 to length of rn-th relation
    # now sysrel contains all coefficients and could be attached to sysmat
    Append(sysmat,sysrel);
  od; # finished adding systems for each relation

# Print("Dimensions of sysmat : ", DimensionsMat(sysmat),"\n");
  r1:=RankMat(sysmat);

  obscoeffs:=Flat(obscoeffs);
  fullmat:=[];
  for i in [1..Length(sysmat)] do
    fullmat[i]:=[];
    for j in [1..Length(sysmat[1])] do
      fullmat[i][j]:=sysmat[i][j];
    od;
    fullmat[i][j+1]:=obscoeffs[i];
  od;

# Print("Dimensions of fullmat : ", DimensionsMat(fullmat),"\n");
  r2:=RankMat(fullmat);

# Print("MATRICES RANKS: sysmat=", r1, " fullmat=", r2, "\n");

  if r1<>r2 then
#   Print("- \c");
  else
#   Print("+ \c");
#   Print("solution of non-homogeneous system \n");
#   Display(SolutionMat(TransposedMat(sysmat),obscoeffs));
#   Print("solutions of homogeneous system \n");
#   Print("NullspaceMat : ",
#         DimensionsMat(NullspaceMat(TransposedMat(sysmat))), "\n");
    Add(res,f);
    Info(LAGInfo, 3, "LAGInfo: after testing ", Position(maps,f),
                     "-th homomorphism of ", Length(maps),
                     " selected ", Length(res), " homomorphisms" );
  fi;

od; # finished lookahead for all f in maps
return res;
end;


###########################################################################
##
##  ParametrizationSpace( KG, V, F, relsindex, f, n )
##
ParametrizationSpace:=function( KG, V, F, relsindex, f, n )
local H_fp, H_free, rels, h_free, h, r, rh, x, ims, back, obs, obscoeffs, i, j,
strel, gens, m, dimJ, row, t, b, prod, prodcoeffs,
sysmat, vec, fullmat, res, left, right, firstpos, basJ, pos, flag, k, sysrel,
r1, r2, lastn, prn, pin, rn, l, basI, BasI, dimI, ParamBasis;

rels := List( relsindex, i -> 
              Product( List( i, j -> GeneratorsOfGroup( F )[j] ) ) );

Print("Reading relations for group ", IdGroup(F/rels), "\n");

# define dimension and basis of J=I^(n-1)/I^n
pos :=Filtered([1..Length(WeightedBasis(KG).weights)],
                i -> WeightedBasis(KG).weights[i]>=n-1 and
		     WeightedBasis(KG).weights[i]<n);
dimJ:=Length(pos);
basJ:=List(pos, i -> WeightedBasis(KG).weightedBasis[i]);
basI:=WeightedBasis(KG).weightedBasis{[pos[1] ..
Length(WeightedBasis(KG).weights)]};
BasI:=Basis(AugmentationIdealPowerSeries(KG)[n-1], basI);
dimI:=Length(Filtered([1..Length(WeightedBasis(KG).weights)],
                i -> WeightedBasis(KG).weights[i]>=n-1 and
		     WeightedBasis(KG).weights[i]<=n));

Info(LAGInfo, 2, "LAGInfo: starting constraction of parametrization space");
V[n]:=AugmentationIdealPowerFactorGroup(KG,n);
Info(LAGInfo, 2, "LAGInfo: calculated V[", n, "] of order ",
                 Size(V[n]), " with center of order ", Size(Center(V[n])),
                 " generated by ", GeneratorsOfGroup(Center(V[n])));

# calculate projection from V(KG) on V[n]
prn:=ShallowCopy(GeneratorsOfGroup(V[n]));
for i in [ Position(WeightedBasis(KG).weights, n) ..
Length(GeneratorsOfGroup(PcNormalizedUnitGroup(KG))) ] do
  Add(prn, One(V[n]));
od;
pin := GroupHomomorphismByImages (PcNormalizedUnitGroup(KG), V[n],

GeneratorsOfGroup(PcNormalizedUnitGroup(KG)), prn);

  # calculating preimages of f(x) in V(KG)
  ims:=List( MappingGeneratorsImages(f)[2], x ->
PreImagesRepresentative(pin,x));
  # and returning them to the group algebra KG
  ims:=List(ims, x -> x^NaturalBijectionToNormalizedUnitGroup(KG));

  # substitute them into group relations and calculate obstructions
  obs:=List(rels, r -> (MappedWord(r, GeneratorsOfGroup(F), ims)-One(KG) ) );

  # find coefficient of obstructions in the basis of I^n and take only
  # first dimIn values
  # we will obtain the matrix with rows corresponding to relations
  # and columns corresponding to first dimIn basis elements of In

  obscoeffs:=List(obs, r -> Coefficients(BasI,r){[1 .. dimI]});
  obscoeffs:=-One(UnderlyingField(KG))*obscoeffs;
  Print("OBSTRUCTIONS : \n");
  Display(obscoeffs);

  # now we generate matrix of the system of linear equations
  sysmat:=[];

  for rn in [1 .. Length(relsindex)] do
    # generate subsystem of linear equations corresponding to the rn-th relation
    # taking rn-th relation and substitute basis elements instead of one of
    # each components
    Print("relation ", rn, ", t=", [1..Length(relsindex[rn])], ", b=",
[1..Length(basJ)], "\n");

    # create zero matrix with dimI rows and dimI*Number_of_generators_of_H columns
    sysrel:=List([1 .. dimI ], i -> List([1 .. dimI*Length(ims)], k ->
Zero(UnderlyingField(KG))));
    # in this matrix m-th row corresponds to equation, arising from thHe m-th
    # element of basJ

    for t in [1..Length(relsindex[rn])] do
    #fixing t-th entry in the set of rn-th relation entries

      #calculating products from is left and right sides
      left :=Product(List([1..t], i -> ims[relsindex[rn][i]]));
      right:=Product(List([t+1..Length(relsindex[rn])], i ->
ims[relsindex[rn][i]]));

      for b in [1 .. Length(basJ)] do
        # substituting b-th element of the basis of J
        prod:=left * basJ[b] * right;
        # taking its first dimJ coordinates in the same basis
        prodcoeffs:=Coefficients(BasI,prod){[1..dimI]};
        # we obtain coefficients (c_1, ... c_dimI)
        # standing for x_kl in the equation number m:
        # - k is fixed and corresponds to the number of generator,
        #   modified by multiplication on the basis element from basJ[b],
        #   and could be obtained as k=relsindex[rn][t]
        # - l is determined from the number of basis element, used for
        #   modification,
        #   i.e. l=b
        # - m is the position of the coefficient in the list prodcoeffs, i.e. the
        #   number of the basis element corresponding to this coefficient
        # Thus, we need to add m-th coefficient to l-th element in the k-th
        # block in the m-th row of sysrel

	k:=relsindex[rn][t];
	for m in [1..Length(prodcoeffs)] do
	  sysrel[m][dimI*(k-1)+b]:=sysrel[m][dimI*(k-1)+b]+prodcoeffs[m];
	od;

      od; # finished substitution of basis elements into t-th entry of the
          # rn-th relation
    od; # finished calculation for all t from 1 to length of rn-th relation
    # now sysrel contains all coefficients and could be attached to sysmat
    Append(sysmat,sysrel);
  od; # finished adding systems for each relation

  Print("Dimensions of sysmat : ", DimensionsMat(sysmat),"\n");
  r1:=RankMat(sysmat);

  obscoeffs:=Flat(obscoeffs);
  fullmat:=[];
  for i in [1..Length(sysmat)] do
    fullmat[i]:=[];
    for j in [1..Length(sysmat[1])] do
      fullmat[i][j]:=sysmat[i][j];
    od;
    fullmat[i][j+1]:=obscoeffs[i];
  od;

  Print("Dimensions of fullmat : ", DimensionsMat(fullmat),"\n");
  r2:=RankMat(fullmat);

  Print("MATRICES RANKS: sysmat=", r1, " fullmat=", r2, "\n");

  if r1<>r2 then
    Print("DIFFERENT RANKS - SYSTEM NOT SOLVABLE \n");
  else
    Print("SYSTEM IS SOLVABLE !!! \n");
    Print("solution of non-homogeneous system \n");
    Display(SolutionMat(TransposedMat(sysmat),obscoeffs));
    Print("solutions of homogeneous system \n");
    ParamBasis:=NullspaceMat(TransposedMat(sysmat));
    Print("NullspaceMat : ", DimensionsMat(ParamBasis), "\n");
    pos:=Flat(List([1..Length(ims)], i -> dimI*(i-1)+dimJ+[1..dimI-dimJ]));
    ParamBasis:=Filtered(ParamBasis, x -> ForAll(pos, i ->
x[i]=Zero(UnderlyingField(KG))));
    Display(ParamBasis);
  fi;

end;


###########################################################################
##
## MIPLiftingTest(KG, H, mode, num, look)
##
## KG is a modular group algebra, H is a group
## mode = "iso", "sub", "lin"
## num = 0 (full test) or 1 (return the first obtained lifting, if exist)
## look = 0 (without lookahead), "full" or k, which is the lookahead step
##
###########################################################################
MIPLiftingTest := function( KG, H, mode, num, look )
local         # Local variables (in alphabetical order):
      actcon, # internal function for an action by conjugation with an
              # element u from V[n] on the lifting f
      actfun, # internal function for an action of the element phi from
              # Aut(H) on the lifting f
        AutH, # the automorphism group of the group H
       autsH, # the list of elements of the automorphism group AutH
      eltsv2, # the list of elements of the group V[2]=V(KG)/1+I^2
           i, # usually cycle parameter
        maps, # maps[n] is the constructed set of homomorphisms H -> V[n]
         map, # current element of maps
      ngensH, # the minimal number of generators of the group H
      ngensV, # the number of generators of the group V[2]=V(KG)/1+I^2
orbitsByAutH, # Orbits domain for action of Aut(H) on the set of
              # homomorphisms (epimorphisms) from H to V[2]=V(KG)/1+I^2
       orbit, # current orbit from orbitsByAutH
           V, # the list of factorgroups V[n]=V(KG)/1+I^n, where I is the
              # augmentation ideal. The last element is V[t(KG)] = V(KG)
     vtuples, # the list of ngensH-tuples of indices in { 1, ..., |V[2]| }
          vt, # current tuple from vtuples
           w, # the list of weights of elements of the weigthed basis,
              # extended by t(KG) as its last element
        umap, # canonical projection from V(KG) to V(KG)/1+I^2

      n,    # number of iteration from 2 to t(I)-1,
            # where t(I) is the nilpotency index of I
      back, # homomorphism from V[n] in KG (used to check that Image(H)
            # generates KG/I^n)
      pr,   # images of generators of V[n+1] under projection pi
            # from V[n+1] onto V[n];
      j,    # cycle parameter
      pi,   # projection from V[n+1] onto V[n]
      ker,  # kernel of projection pi from V[n+1] onto V[n]
      f,    # currently lifted gomomorphism
      c1,c2,# current elements of kernel
      lift, # current lifting of f depending of c1 and c2
      eltsker, ims, h, m, x, bas, mat, cf, dim,
      kertuples, t, v, par, partuples, parmap, preimreps,flag, res,
      pcumap, mi, orbs, mapsorbs, tmp, orbf,
      phi, u, lifts, diremb, dirpr, natmap, D, S, DS, orbv, pr1, pi1,
      celts, genss, prn, pin, newelts, newtuples, f1, lifts1, wt,
      relsindex, rels, pos, dimJ, basJ, BasIn, basIn, lastn, pin1, prn1,
      F, # free group
      fg; # generators of the free group F

# In the isomorphism test mode we check that the groups
# G and H can not be splitted by known MIP invariants.
# Otherwise a warning will be displayed.
if mode="iso" then
  if MIPInvariantsRecord(UnderlyingGroup(KG)) <> MIPInvariantsRecord(H) then
    Info(LAGInfo, 1,
        "LAGInfo WARNING: G and H are splitted by MIP invariants!!!" );
  else
    Info(LAGInfo, 1,
        "LAGInfo: G and H have the same set of MIP invariants" );
  fi;
fi;

# Reducing the generating set of the group H.
# Computing the relations indices for the group H.
# Check that they actually define the group H.
ngensH := Size( MinimalGeneratingSet( H ) );
H := Group( MinimalGeneratingSet( H ) );
IsPGroup(H); # to enforce AutPGrp usage

relsindex:=RelsIndices(H);
Info(LAGInfo, 2, "LAGInfo: Relations indices for H : ", relsindex );

####################################################### this part
                                                     ## was moved
F := FreeGroup(Maximum( Flat( relsindex ) ) );       ## from
fg := GeneratorsOfGroup( F );                        ## Lookahead
                                                     ## since it
rels:=List(relsindex, i -> List( i, j -> fg[j] ) );  ## does not
rels:=List(rels, i -> Product(i));                   ## depend on
Info(LAGInfo, 2, "LAGInfo: relations for ",          ## the number
                  IdGroup(F/rels), " loaded" );      ## of step n
                                                     ##
#######################################################

# Calculating the automorphism group of H
#
# WARNING 1: Make sure that AutPGrp package is installed
#
# WARNING 2: it was noticed that if groups G and H have different
# orders of the automorphism group, it is preferable to select
# as H the group with the bigger automorphism group
#
Info(LAGInfo, 2, "LAGInfo: calculating Aut(H) ..." );
AutH := AutomorphismGroup( H );
autsH := AsList( AutH );
Info(LAGInfo, 2, "LAGInfo: calculated Aut(H) of order ", Size(AutH) );

# Defining actions of Aut(H) and V[n] on liftings
#
# 4.1. An action of the element phi from Aut(H) on the lifting f
# defined as composition phi*f
actfun := function(f,phi)
return phi*f;
end;
# 4.2. An action by conjugation with an element u from V[n]
# on the lifting f defined via conjugating of images of
# generators of the source of the lifting f
actcon := function(f,u)
local x;
return GroupHomomorphismByImagesNC( Source(f),
                                    ImagesSource(f),
                                    MappingGeneratorsImages(f)[1],
                                    List( MappingGeneratorsImages(f)[2],
                                          x -> x^u) );
end;

# Calculation of the list of weights of elements of the weigthed basis
# and extending it by writing t(KG) to its end
w := ShallowCopy( WeightedBasis(KG).weights );
Info(LAGInfo, 2, "LAGInfo: Weights of weighted basis elements ", w);
Add( w, AugmentationIdealNilpotencyIndex( KG ) );


Info(LAGInfo, 2, " ");
Info(LAGInfo, 1, "LAGInfo: ************ STEP 2 STARTED *************");
Info(LAGInfo, 1, "LAGInfo: construction of homomorphisms from H to V[2]");
Info(LAGInfo, 2, " ");

# calculating of V[2] = V(KG)/1+I^2
V := [ ];
V[2] := AugmentationIdealPowerFactorGroup( KG, 2 );
Info(LAGInfo, 2, "LAGInfo: calculated V[2]=V(KG)/1+I^2 of order ",
                  Size(V[2]));

# calculating homomorphism umap from V(KG) to V(KG)/1+I^2 :
# if ngensV is the number of generators of V[2], then the 1st ngensV
# generators of V(KG) go to corresponding generators of V[2]
# and the remaining generators of V(KG) to identity
ims := ShallowCopy( GeneratorsOfGroup( V[2] ) );
ngensV := Length(ims);
for i in [ ngensV+1 ..
           Length( GeneratorsOfGroup( NormalizedUnitGroup( KG ) ) ) ] do
  Add(ims, One( V[2] ) );
od;
# use NC-method since we always will get a homomorphism
umap := GroupHomomorphismByImagesNC( NormalizedUnitGroup( KG ),
             V[2],
             GeneratorsOfGroup( NormalizedUnitGroup( KG ) ),
             ims );

# calculating homomorphisms from H to V[2]=V(KG)/1+I^2
maps := [];
maps[2] := [];
eltsv2 := Elements(V[2]);
vtuples := Tuples( [ 1 .. Size(V[2]) ], ngensH );
Info(LAGInfo, 2, "LAGInfo: generated ", Length(vtuples),
                 " ", ngensH, "-tuples of elements of V[2]");

# to find an isomorphism of group algebras we need only epimorphisms
# onto V[2]=V(KG)/1+I^2. This is why we select only such tuples which
# will lead us to such epimorhism
if mode="iso" then
  vtuples := Filtered( vtuples, vt ->
                       V[2]=Subgroup(V[2], List(vt, i -> eltsv2[i])));
Info(LAGInfo, 2, "LAGInfo: ", Length(vtuples),
                 " of them lead to an epimorphism");

fi;

# and now we generate this homomorphisms from the list of (probably
# filtered) tuples using NC-method since we always will get a
# homomorphism. So this step is fast, and the work, if necessary in
# the "iso" mode, actually was done at the previous step, checking
# that we have epimorphism
maps[2] := List( vtuples, vt ->
                 GroupHomomorphismByImagesNC( H,
                      V[2],
                      GeneratorsOfGroup( H ),
                      List( vt, i -> eltsv2[i] ) ) );
# to save memory, we do not longer need to store vtuples
Unbind(vtuples);
Info(LAGInfo, 1, "LAGInfo: calculated ", Length(maps[2]),
                 " homomorphisms from H in V[2]");
Info(LAGInfo,2,  "         with images of order ",  
                 Set( List( maps[2], i -> Size(Image(i)))) );

# we may consider the action of Aut(H) on the set of homomorphisms
# (epimorphisms) from H to V[2]=V(KG)/1+I^2, and to work only with
# orbit representatives under this action. Thus we will replace
# maps[2] by the list of their orbit representatives
orbitsByAutH := OrbitsDomain( AutomorphismGroup(H), maps[2], actfun );
maps[2] := List( orbitsByAutH, orbit -> orbit[1] );
Info(LAGInfo, 2, "LAGInfo: found ", Length(maps[2]),
                 " representatives of them under action of Aut(H)");

# in "iso" mode we need only those epimorphisms from H to V[2], whose
# images in V[2] also generates KG/I^2. To check this, we check that
# the dimension of the subspace of KG, generated by their preimage
# representatives under the canonical projection umap from V(KG) onto
# V[2], is not less than dim(KG/I^2) = dim(KG) - dim(I^2).
if mode="iso" then
  maps[2] := Filtered( maps[2], map ->
               Dimension( Subspace( KG, List( Elements( H ), h ->
                 PreImagesRepresentative( umap, h^map ) ) ) )  >=
                   Dimension( KG ) -
                   Dimension( AugmentationIdealPowerSeries( KG )[2] ) );
  Info(LAGInfo, 1, "LAGInfo: found ", Length(maps[2]),
                   " of them which image generates FG/I^2");
fi;

ker:=[];
par:=[];

for n in [ 3 .. AugmentationIdealNilpotencyIndex(KG)-1] do
  Info(LAGInfo, 2, " ");
  Info(LAGInfo, 1, "LAGInfo: ************ STEP ", n, " STARTED *************");
  Info(LAGInfo, 1, "LAGInfo: construction of homomorphisms from H to V[",n,"]");
  Info(LAGInfo, 2, " ");

  #
  # PRELIMINARY COMPUTATIONS
  #
  
  # calculating of V[n] = V(KG)/1+I^n
  V[n]:= AugmentationIdealPowerFactorGroup(KG,n);

  Info(LAGInfo, 2, "LAGInfo: calculated V[", n, "] of order ",
                    Size(V[n]), " with center of order ", Size(Center(V[n])),
                   " generated by ", GeneratorsOfGroup(Center(V[n])));

  # calculating of V[n+1] = V(KG)/1+I^(n+1)
  V[n+1]:= AugmentationIdealPowerFactorGroup(KG,n+1);
  Info(LAGInfo, 2, "LAGInfo: calculated V[", n+1, "] of order ",
                   Size(V[n+1]), " with center of order ", Size(Center(V[n+1])),
                   " generated by ", GeneratorsOfGroup(Center(V[n+1])));

  # calculate homomorphism from V(KG) to V[n]=V(KG)/1+I^n
  ims:=ShallowCopy(GeneratorsOfGroup(V[n]));
  for i in [ Length(ims)+1 ..
             Length(GeneratorsOfGroup(NormalizedUnitGroup(KG))) ] do
    Add(ims, One(V[n]) );
  od;
  umap:=GroupHomomorphismByImagesNC(NormalizedUnitGroup(KG),
                                    V[n],
                                    GeneratorsOfGroup(NormalizedUnitGroup(KG)),
                                    ims);

  # calculate projection from V[n] on V[n-1]
  pr:=ShallowCopy(GeneratorsOfGroup(V[n-1]));
  for i in [ Position(w, n-1) .. Position(w,n)-1 ] do
    Append(pr, [One(V[n-1])]);
  od;
  pi := GroupHomomorphismByImagesNC(V[n],
                                    V[n-1],
                                    GeneratorsOfGroup(V[n]),
                                    pr);

  # its kernel is just 1+I^(n-1)/1+I^n
  ker[n]:=Kernel(pi);
  Info(LAGInfo, 2, "LAGInfo: calculated Ker[",n,"]=1+I^", n-1, "/1+I^", n,
                   " of order ", Size(ker[n]) );

  # calculate projection from V[n+1] on V[n]
  pr1:=ShallowCopy(GeneratorsOfGroup(V[n]));
  for i in [ Position(w, n) .. Position(w,n+1)-1 ] do
    Append(pr1, [One(V[n])]);
  od;
  pi1 := GroupHomomorphismByImagesNC(V[n+1],
                                     V[n],
                                     GeneratorsOfGroup(V[n+1]),
                                     pr1);
  
  #
  # if n=3, we try to check whether there are homomorphisms
  # from H to V[2] that are liftable to homomorphisms from H to V[3]
  #
  if n=3 then
    maps[n-1]:=Filtered(maps[n-1], f ->
               GroupHomomorphismByImages( H,
                    V[n],
                    GeneratorsOfGroup(H),
                    List( [ 1 .. ngensH ], i ->
                          PreImagesRepresentative(pi,
                             GeneratorsOfGroup(H)[i]^f))) <> fail);
    Info(LAGInfo, 2, "LAGInfo: ", Length(maps[n-1]),
                     " homomorphisms from H to V[", n-1,
                     "] are liftable to non-modified homomorfism from H to V[",
                     n,"]");
    if Length(maps[n-1])=0 then
      return [];
    fi;
  fi;

  # 
  # now we calculate non-modified liftings of this homomorphisms
  #
  lifts:=List( maps[n-1], f ->
               GroupHomomorphismByImagesNC( H,
                    V[n],
                    GeneratorsOfGroup(H),
                    List( [ 1 .. ngensH ], i ->
                    PreImagesRepresentative(pi, GeneratorsOfGroup(H)[i]^f))));
  Info(LAGInfo, 2, "LAGInfo: generated ", Length(lifts),
                   " non-modified liftings from H to V[",n,"]");

  maps[n]:=[];

#
# PREPARATIONS FOR LOOKAHEAD PROCEDURE
#
if look<>0 then
  ### ATTENTION! The text below was moved from Lookahead !

  if look="full" then
    lastn:=Minimum( 2*n, AugmentationIdealNilpotencyIndex(KG) );
  elif n+look<=2*n then
    lastn:=Minimum( n+look, AugmentationIdealNilpotencyIndex(KG) );
  else
    Info(LAGInfo, 2, "LAGInfo: lookahead ignored since 2*n<n+", look);
  fi;

  Info(LAGInfo, 2, "LAGInfo: preparations for lookahead");

  # define dimension and basis of J=I^n/I^lastn
  pos :=Filtered([1..Length(WeightedBasis(KG).weights)],
                  i -> WeightedBasis(KG).weights[i]>=n and
                       WeightedBasis(KG).weights[i]<lastn);
  dimJ:=Length(pos);
  basJ:=List(pos, i -> WeightedBasis(KG).weightedBasis[i]);
  basIn := WeightedBasis(KG).weightedBasis{
             [pos[1]..Length(WeightedBasis(KG).weights)]};
  BasIn := Basis(AugmentationIdealPowerSeries(KG)[n], basIn);

  V[lastn]:=AugmentationIdealPowerFactorGroup(KG,lastn);
  Info(LAGInfo, 2, "LAGInfo: calculated V[", lastn, "] of order ",
                   Size(V[lastn]), " with center of order ",
                   Size(Center(V[lastn])),
                   " generated by ", GeneratorsOfGroup(Center(V[lastn])));

  # calculate projection from V(KG) on V[n]
  prn1:=ShallowCopy(GeneratorsOfGroup(V[n]));
  for i in [ Position(WeightedBasis(KG).weights, n) ..
  Length(GeneratorsOfGroup(PcNormalizedUnitGroup(KG))) ] do
    Add(prn1, One(V[n]));
  od;
  pin1 := GroupHomomorphismByImagesNC(PcNormalizedUnitGroup(KG),
            V[n],
            GeneratorsOfGroup(PcNormalizedUnitGroup(KG)),
            prn1);
  ###          
  ### end of the part depending from n, moved from lookahead
  ###
fi;

  ##########################################
  # beginning of the cycle over f in lifts #
  ##########################################

  for f in lifts do
    Info(LAGInfo, 2, "LAGInfo: testing modifications for ", Position(lifts,f),
                     " of ", Length(lifts), " liftings from H to V[",n,"]");

    # calculation of the parametrization space should be placed here
    # currently it is commented and another method is used
    # with parametrizations space we should do it in the following way:
    # - calculate system of linear equations
    # - find solution of non-homogeneous system and basis of solutions
    #   for corresponding homogeneous one
    # - calculate all solutions over GF(p)
    # - apply conjugation action to this solutions
    # - generate liftings, modified using represenatives of orbits under
    #   this action
    # - apply lookahead procedure
    # ParametrizationSpace(KG,V,F,relsindex,f,n);

    # 
    # calculation of parametrization subgroup
    #

    # first we consider the action of Aut(H)
    Info(LAGInfo, 2, "Original homomorphism : \n", f );
    # calculate the full orbit generated by f under the action of Aut(H)
    orbf:=List(autsH, aut -> aut*f);
    # select only those elements in this orbit, which are obtained by
    # multiplication of images of f on kernel elements
    orbf:=Filtered(orbf, aut -> ForAll([1..ngensH],
          i -> MappingGeneratorsImages(f)[2][i]^-1 *
               MappingGeneratorsImages(aut)[2][i] in ker[n]));
    # now we gather tuples of this kernel elements from images of orbit elements
    orbf:=Set(List(orbf, aut -> List([1..ngensH],
          i -> MappingGeneratorsImages(f)[2][i]^-1 *
               MappingGeneratorsImages(aut)[2][i])));
    Info(LAGInfo, 3, "LAGInfo: action of Aut(H) gives ", orbf);

    # now we consider action by conjugation using elements of the 
    # previous kernel, thus, of ker[n-1]
    # we select elements of the previous kernel using condition that 
    # their weight is n-2
    orbv:= List( Filtered([1..Length(w)-1], j -> w[j]=n-2 ), i ->
                                            GeneratorsOfGroup(V[n])[i]);
    Info(LAGInfo, 2, "LAGInfo: selecting ", orbv, " for conjugation action");
    # calculate the full orbit generated by f under the conjugation by ker[n-1]
    orbv:=List( orbv, u -> actcon(f,u) );
    # select only those elements in this orbit, which are obtained by
    # multiplication of images of f on kernel elements
    orbv:=Filtered(orbv, aut -> ForAll([1..ngensH],
                           i -> MappingGeneratorsImages(f)[2][i]^-1 *
                                MappingGeneratorsImages(aut)[2][i] in ker[n]));
    # now we gather tuples of this kernel elements from images of orbit elements
    orbv:=Set(List(orbv, aut -> List([1..ngensH],
                           i -> MappingGeneratorsImages(f)[2][i]^-1 *
                                MappingGeneratorsImages(aut)[2][i])));
    Info(LAGInfo, 3, "LAGInfo: conjugation action gives ", orbv);

    # D is a direct product of ngensH copies of ker[n]
    # diremb and dirpr - corresponding embeddings and projections
    D:=DirectProduct(List([1..ngensH], i -> ker[n]));
    diremb:=List([1..ngensH], i -> Embedding(D,i));
    dirpr :=List([1..ngensH], i -> Projection(D,i));

    # for further step we calculate the union of obtained sets of tuples
    # and embed each tuple in the direct product D
    genss:= List( Union(orbf,orbv), x ->
                  Product(List([1..ngensH], i -> x[i]^diremb[i] )));

    # further reduction could be obtained if in the center of V[n+1]
    # there are elements, which are projected in the n-th kernel and
    # an order of such elements and their projections is equal to 2
    celts:=Filtered(GeneratorsOfGroup(Center(V[n+1])),
                    x -> Order(x)=2 and x^pi1 in ker[n] and Order(x^pi1)=2 );
    # after finding the subgroup generating by such elements in V[n+1] 
    # we project them onto V[n]
    celts:=List( celts, x -> x^pi1);
    Info(LAGInfo, 2,
         "LAGInfo: adding elements of order 2 projected into kernel : ", celts);
    # and embed obtained projections in the direct product D
    celts:=Set( Flat( List( celts, x ->
                List([1..ngensH], i -> x^diremb[i] ) ) ) );

    # before generating the subgroup, we need to remember, whether we
    # actually obtained new elements on this step
    newelts:=Filtered(celts, x -> not x in genss);

    S:=Subgroup(D, Union(genss,celts));
    natmap:=NaturalHomomorphismByNormalSubgroup(D,S);
    DS:=Image(natmap); # DS is the factor group D/S
    # t is a list of elements of D
    t:=List(AsList(DS), s -> PreImagesRepresentative(natmap,s));
    # now we 'distribute' elements of t into components of direct product
    partuples:=List(t, u -> List([1..ngensH], i -> u^dirpr[i]));
    newtuples:=List( Subgroup(D,newelts), u -> List([1..ngensH], i -> u^dirpr[i]));
    newtuples:=Filtered(newtuples, x -> not x in partuples);
    Info(LAGInfo, 2, "LAGInfo: this gives additional ",
                     Length(newtuples), " cases to check");
    Info(LAGInfo, 2, "LAGInfo: |D|=", Size(D), " |S|=", Size(S),
                     " |D/S|=", Length(partuples));

    # first, if newtuples is a non-empty list, we need to add to consideration
    # also homomorphisms, obtained from f by multiplication of its images by
    # elements from newtuples
    lifts1:=[f];
    # if newtuples is empty, this will be skipped
    for wt in newtuples do
      Add(lifts1, GroupHomomorphismByImagesNC( H, V[n], GeneratorsOfGroup(H),
        List([1 .. ngensH], i -> MappingGeneratorsImages(f)[2][i]*wt[i]) ) );
    od;

    #
    # now partuples are representatives of the parametrization subgroup
    # that must be used to modify homomorphisms in the list lifts1 and
    # check whether such modification is good
    #
    for f1 in lifts1 do
      for v in partuples do
        # we use NC method since we always have a homomorphism
        # now lift is a homomorphism modified using v from partuples
        lift:=GroupHomomorphismByImagesNC( H, V[n], GeneratorsOfGroup(H),
              List([1 .. ngensH], i -> MappingGeneratorsImages(f1)[2][i]*v[i]));

        # check immediately whether this homomorphism
        # extends to homomorphism from H to V[n+1]
        # to not to add it to the list in case of negative answer
        flag:=GroupHomomorphismByImages( H, V[n+1], GeneratorsOfGroup(H),
              List([1 .. ngensH],
              i -> PreImagesRepresentative(pi1, GeneratorsOfGroup(H)[i]^lift)));
        # if it is possible to lift the homomorphism 'lift' to V[n+1], then
        # we check some other conditions       
        if flag <> fail then
        
          if mode="iso" then
            # we first send elements of H to V[n] and then send them to KG
            # to find the dimension of the subspace generated by them
            bas:=List( Elements(H), h -> PreImagesRepresentative(umap,h^lift));
            dim:=Dimension(Subspace(KG,bas));
            if dim >= Dimension(KG)-Dimension(AugmentationIdealPowerSeries(KG)[n]) then
              if look<>0 then
                Append( maps[n],
                        Lookahead(KG,V,relsindex,[lift],n, look, F, 
                        rels, pin1, dimJ, basJ, BasIn));
              else
                Add(maps[n], lift);
              fi;
              Print("\r", Length(maps[n]), " \c");
            fi;
            
          else
          
            if look<>0 then
              Append( maps[n],
                      Lookahead(KG,V,relsindex,[lift],n, look, F, 
                      rels, pin1, dimJ, basJ, BasIn));
            else 
              Add(maps[n], lift); # if we do not use lookahead, we just add this lifting
            fi;
            Print("\r", Length(maps[n]), " \c");
            
          fi;
          
        fi; # end of checking additional conditions for 'lift'
      od; # finished cycle over v in partuples
    od; # finished cycle over f1 in lifts1

    # may we remove this printing?
    Print("\n");

    Info(LAGInfo, 2, "LAGInfo: found ", Length(maps[n]),
                     " liftings after checking ", Position(lifts,f),
                     " of ", Length(lifts), " homomorphisms");
  od; # end of the cycle over f in lifts

  Info(LAGInfo, 1, "LAGInfo: found ", Length(maps[n]),
                   " homomorphisms from H in V[", n, "]");

  if Length(maps[n])=0 then
    Info(LAGInfo, 1, "LAGInfo: no homomorphisms from H to V[",n,"]");
    return maps[n];
  fi;

  Info(LAGInfo, 2, "This ", Length(maps[n]), " homomorphisms have ",
                   Length(Set(List(maps[n], x -> Image(x)))), " images \n");

#
# Calling "Lookahead" to 2*n - this block of text is commented
# because it was moved inside the cycle
#
#  if look<>0 then
#    maps[n]:=Lookahead(KG,V,relsindex,maps[n],n, look, F, rels);
#    Info(LAGInfo, 2, "LAGInfo: after lookahead having ", Length(maps[n]),
#                     " homomorphisms from H in V[", n, "]");
#  fi;

  if Length(maps[n])=0 then
    Info(LAGInfo, 1, "LAGInfo: no homomorphisms from H to V[",n,"]");
    return maps[n];
  fi;

od; # finished for n, where n in the number of step

n:=AugmentationIdealNilpotencyIndex(KG);

#################
# THE LAST STEP #
#################

#
# To list all homomorphisms it is desirable to use action of Aut(H) !!!
#

Info(LAGInfo, 2, " ");
Info(LAGInfo, 1, "LAGInfo: ********* LAST STEP ", n, " STARTED *****");
Info(LAGInfo, 2, " ");
V[n]:= PcNormalizedUnitGroup(KG);
Info(LAGInfo, 2, "LAGInfo: calculated V(KG) of order ", Size(V[n]) );
pcumap:=NaturalBijectionToNormalizedUnitGroup(KG);

# calculate projection from V[n] on V[n-1]
pr:=ShallowCopy(GeneratorsOfGroup(V[n-1]));
for i in [ Position(w, n-1) .. Length(w)-1 ] do
  Append(pr, [One(V[n-1])]);
od;
pi := GroupHomomorphismByImages (V[n], V[n-1], GeneratorsOfGroup(V[n]), pr);
# its kernel is just 1+I^(n-1)
ker[n]:=Kernel(pi);
Info(LAGInfo, 2, "LAGInfo: 1+I^", n-1, " of order ", Size(ker[n]) );

# calculating homomorphisms from H to Ker(pi)=1+I^(n-1)
par[n]:=[];
eltsker:=Elements(ker[n]);
partuples:=Tuples( [ 1 .. Length(eltsker)], ngensH);
for v in partuples do
  map:= GroupHomomorphismByImages( H,
                                   ker[n],
                                   GeneratorsOfGroup(H),
                                   List(v, i -> eltsker[i]) );
  if map <> fail then
    Add(par[n], map);
  fi;
od;
Info(LAGInfo, 2, "LAGInfo: found ", Length(par[n]),
                 " homomorphisms from H to 1+I^", n-1);
Unbind(partuples);

maps[n]:=[];
for f in maps[n-1] do
  preimreps:=List([1 .. ngensH], i ->
               PreImagesRepresentative(pi, GeneratorsOfGroup(H)[i]^f) );
  lift:=GroupHomomorphismByImages( H, V[n], GeneratorsOfGroup(H), preimreps);
  if lift <> fail then
    for parmap in par[n] do
      # can we use NC here like it was before ???
      lift:=GroupHomomorphismByImages( H, V[n], GeneratorsOfGroup(H),
            List([1 .. ngensH],
                 i -> preimreps[i]*GeneratorsOfGroup(H)[i]^parmap) );
      if lift <> fail then
        if mode="iso" then
          bas:=List( Elements(H), h -> (h^lift)^pcumap );
          dim:=Dimension(Subspace(KG,bas));
          if dim >=
          Dimension(KG)-Dimension(AugmentationIdealPowerSeries(KG)[n]) then
            Add(maps[n], lift);
            if num=1 then
              return maps[n];
            fi;
            Print("\r", Length(maps[n]), " \c");
          fi;
        elif Size(Kernel(lift))=1 then
          if mode="sub" then
            Add(maps[n], lift);
            if num=1 then
              return maps[n];
            fi;
            Print("\r", Length(maps[n]), " \c");
          elif mode="lin" then
            if Size(H) = Dimension(Subspace(KG, List(Elements(H),
                                                h -> (h^lift)^pcumap ))) then
              Add(maps[n], lift);
              if num=1 then
                return maps[n];
              fi;
              Print("\r", Length(maps[n]), " \c");
            fi;
          fi;
        fi;
      fi;
    od; # end of the loop over parmap in par[n]
  fi;
od; # end of the loop over f in maps[n-1]

Info(LAGInfo, 1, "LAGInfo: found ", Length(maps[n]),
                 " homomorphisms from H in V[", n, "]");

if Length(maps[n])=0 then
  Info(LAGInfo, 1, "LAGInfo: no liftings from modulo I^", n-1, " to V(KG)");
fi;

return maps[n];

end;


#############################################################################
##
##  MIPSplittingByLiftingTest( l, startno, forcedTest )
##
MIPSplittingByLiftingTest := function( l, startno, forcedTest )
local   fg, # list of Lie algebras for the tested family l[i]
         i, # the number of current family from the list l
         j, # loop parameter
    output, # output text file saved in the current directory
    primep, # the prime p for corresponding p-groups
      size, # the order of these groups
 curfamily, # the current family
   curpair, # current pair from the current family
    n1, n2, # numbers of the 1st and 2nd groups from
            # the current pair in the current family
  testres;  # the result of the MIPLiftingTest for the current pair
# determine the order of groups
size:=l[1][1][1][1];
primep:=Factors(size)[1];
output:=OutputTextFile(
        Concatenation( "split", String(size), ".txt" ), false);
PrintTo(output, "split", size, ":=[ \n");
for i in [ startno .. Length(l) ] do
  Print("***********************************************\n");
  Print("Testing ", i, "-th family ", l[i][1], " of ", Length(l), "\n");
  # now we will define the current family from the list l;
  # curfamily is a list of two elements, the first is a list of
  # identificators of groups from the current family, and the second
  # contains identificators of pairs with meta-information for each pair
  curfamily:=l[i];
  # now we make a list of group algebras for groups from the current family
  fg := List( curfamily[1], j -> GroupRing( GF(primep), SmallGroup(j) ) );
  # the next cycle is over the pairs in the current family
  for curpair in curfamily[2] do
    Print("Comparing ", curpair[1][1], " and ",  curpair[1][2], " : \c");
    if (not curpair[2].splitted) or forcedTest then
      if not IsBound(curpair[2].splittedByLiftings) then
      # we determine numbers of group algebras, corresponding to our
      # pair of groups in the list of group algebras fg for our family
      n1:=Position(curfamily[1], curpair[1][1]);
      n2:=Position(curfamily[1], curpair[1][2]);
      # now we actually check the isomorphism of group algebras
      # and save the result of the test, which is true if the
      # list returned by MIPLiftingTest is empty, and false
      # otherwise (false will mean a counterexample to MIP!)
      # we notice that the performance is better if the second group
      # has bigger automorphism group (if not equal), so we check this
      if Size(AutomorphismGroup(UnderlyingGroup(fg[n1]))) >
         Size(AutomorphismGroup(UnderlyingGroup(fg[n2]))) then
        testres := MIPLiftingTest( fg[n2], UnderlyingGroup( fg[n1] ),
                     "iso",     # switch test to isomorphism mode
                      1,        # return at least one lifting
                      "full" ); # full steps in lookahead
      else
        testres := MIPLiftingTest( fg[n1], UnderlyingGroup( fg[n2] ),
                     "iso",     # switch test to isomorphism mode
                      1,        # return at least one lifting
                     "full" );  # full steps in lookahead
        fi;
        if Length(testres)=0 then
          curpair[2].splittedByLiftings := true;
        else
          curpair[2].splittedByLiftings := false;
          # if we discovered the counterexample to MIP, we terminate the test
          AppendTo( output, "\n\n", "MIP COUNTEREXAMPLE DISCOVERED!!! \n");
          AppendTo( output, "for the pair ", curpair, " the isomorphism is \n");
          AppendTo( output, testres);
          Error("MIP COUNTEREXAMPLE DISCOVERED!!! See output file for details");
        fi;
        # we check whether the pair was not already splitted by other
        # tools, and if so, we also switch the general result
        if not curpair[2].splitted then
          curpair[2].splitted:=curpair[2].splittedByLiftings;
        fi;
        Print(curpair[2].splittedByLiftings," \n");
      else
        # skip the pair if it was already checked
        Print(curpair[2].splittedByLiftings," \n");
      fi;
    else
      # skip the pair if it is splitted and the test is not forced
      Print(curpair[2].splitted," \n");
    fi;
  od; # end of the cycle over pairs
  AppendTo( output, "\n", "\043", " ", i, "\n");
  AppendTo( output, "[ ");
  AppendTo( output, curfamily[1], ", \n", "[ ");
  for j in curfamily[2] do
    AppendTo( output, "[ ", j[1], ", \n", j[2], " ] , " , "\n");
  od;
  AppendTo( output, "], ");   # closing the list of pairs
  AppendTo( output, "], \n"); # closing the current family
od;
AppendTo( output, "];"); # closing the whole list
# end of the cycle over families
CloseStream(output);
return l;
end;


#############################################################################
##
## MIPSplittingExample(n)
##
## This is a small utility function to generate an example to test each
## possible pair of non-abelian p-groups of a given (small) order n
##
MIPSplittingExample:=function(n)
local li, lpr, x, l;
li  := AllSmallGroups( Size, n, IsAbelian, false );
li  := List( li, IdGroup );
lpr := Combinations( li, 2 );
lpr := List( lpr, x -> [ x, rec(splitted:=false) ] );
l   := [ li, lpr ];
return [ l ];
end;


#############################################################################
##
## IsKnownMIP(G)
##
## The function checks whether some known positive theoretical resuts on MIP
## can be applied to the group G
##
IsKnownMIP:=function(G)
local p,M;

if not IsPGroup(G) then
  Error("IsKNownMIP: G should be a p-group");
fi;

p:=PrimePGroup(G);

if IsAbelian(G) then
  Info(LAGInfo,2,"MIP holds for G since is abelian");
  return true;

elif NilpotencyClassOfGroup(G)=LogInt(Size(G),p)-1 then
  if p=2 then
    Info(LAGInfo,2,"MIP holds for G since G is 2-group of max.class");
    return true;
  else
    if Size(G) <= p^(p+1) then
      if ForAny( MaximalSubgroups(G), IsElementaryAbelian ) then
        Info(LAGInfo,2,"MIP holds for G since G is of max.class of order <=p^(p+1) with el.ab.max sbgrp");
        return true;
      fi;
    fi;
  fi;

elif Index(G,Center(G))=p^2 then
  Info(LAGInfo,2,"MIP holds for G since (G:Z(G))=p^2");
  return true;

elif NilpotencyClassOfGroup(G)=2 then
  if IsElementaryAbelian(DerivedSubgroup(G)) then
    Info(LAGInfo,2,"MIP holds for G since cl(G)=2 and G' elem.abelian");
    return true;
  fi;

elif IsCyclic(DerivedSubgroup(G)) then
  if IsCyclic(G/DerivedSubgroup(G)) then
    Info(LAGInfo,2,"MIP holds for G since G is metacyclic");
    return true;
  fi;

else
  for M in MaximalSubgroups(G) do
    if IsElementaryAbelian(M) then
      if IsCyclic(G/M) then
        Info(LAGInfo,2,"MIP holds for G since G is elem.abelian-by-cyclic");
        return true;
      fi;
    fi;
  od;

fi;

Info(LAGInfo,2,"It is not known whether the MIP holds for G");
return false;

end;


#############################################################################
##
#E
##