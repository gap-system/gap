#############################################################################
##  
#W  laguna.gi                The LAGUNA package                  Viktor Bovdi
#W                                                        Alexander Konovalov
#W                                                         Richard Rossmanith
#W                                                            Csaba Schneider
##
#H  $Id: mip.gi,v 1.1 2005/05/28 13:13:03 alexk Exp $
##
#############################################################################


#############################################################################
##
## ATTRIBUTES OF P-GROUPS AND THEIR MODULAR GROUP ALGBERAS
## RELATED WITH THE MODULAR ISOMORPHISM PROBLEM
##
#############################################################################


#############################################################################
##
#A  JenningsFactors( <G> )
##  
##  Let M[n](G) denote the n-th term of the Brauer-Jennings-Zassenhaus series
##  (in what follows - jennings series, see [S.A.Jennings, The structure of
##  the group ring of a p-group over a modular field, Trans.Amer.Math.Soc.,
##  50 (1941), 175-185 ]): M[n](G) = G \cap ( 1 + I^n ), where I is the 
##  augmentation ideal of the group algebra KG. Then the length of this 
##  series and isomorphism types of factors M[i]/M[i+1], M[i]/M[i+2] and
##  M[i]/M[2i+1] are determined by the group algebra KG [I.B.S.Passi, 
##  S.K.Sehgal, Isomorphism of modular group algebras, Math.Z., 129 (1972),
##  65-73; J.Ritter, S.K.Sehgal, Isomorphism of group rings, Arch.Math.
##  (Basel), 40 (1983), 32-39].
##  The function calculates this factors and returns a list containing three
##  lists of catalogue numbers of appropriate factors.
InstallMethod(JenningsFactors,
              "for a p-group ",
              true,
              [ IsPGroup ],
              0,
function(G)
local M, i, j1, j2, j3;
M := JenningsSeries(G);
j1 := List( [ 1 .. Length(M)-1 ], i -> IdGroup( M[i] / M[i+1] ) );
j2 := List( [ 1 .. Length(M)-2 ], i -> IdGroup( M[i] / M[i+2] ) );
j3 := List( [ 1 .. Int((Length(M)-1)/2) ], i -> IdGroup( M[i] / M[i+2] ) );
return [ j1, j2, j3 ]; 
end);


#############################################################################
##
#A  SandlingFactorGroup( <G> )
##  
##  Let gamma[1]=G, ..., gamma[n] be the lower central series of the group G.
##  Then the isomorphism type of the factorgroup G / (gamma[2]^p * gamma[3])
##  is determined by the group algebra KG [R.Sandling, The modular group
##  algebra of a central elementary-by-abelian p-group, Arch.Math. (Basel),
##  52 (1989), 22-27]. This factorgroup is returned by this function.
InstallMethod(SandlingFactorGroup,
              "for a p-group ",
              true,
              [ IsPGroup ],
              0,
function(G)
local gamma, H; 
if IsAbelian(G) then   
	return TrivialSubgroup(G);
else   
	gamma := LowerCentralSeries(G);
	H := ClosureGroup( Agemo( gamma[2], PrimePGroup(G) ), gamma[3] );
	return( G/H );
fi;
end); 


#############################################################################
##
#A  QuillenSeries( <G> )
##  
##  Let G be a p-group of order p^n. It was proved in [D.Quillen, The 
##  spectrum of an equivariant cohomology ring II, Ann. of Math., (2) 94 
##  (1984), 573-602] that the number of conjugacy classes of maximal 
##  elementary abelian subgroups of given rank is determined by the group 
##  algebra KG. 
##  The function calculates this numbers for each possible rank and returns 
##  a list of the length n, where i-th element corresponds to the number of
##  conjugacy classes of maximal elementary abelian subgroups of the rank i.
InstallMethod(QuillenSeries,
              "for a p-group ",
              true,
              [ IsPGroup ],
              0,
function(G)
local qs, latt, msl, ccs, ccs_repr, i, x, n;
latt := LatticeSubgroups(G);
msl := MinimalSupergroupsLattice(latt);
ccs := ConjugacyClassesSubgroups(latt);
ccs_repr := List(ccs, Representative);
qs := [];
for i in [ 1 .. LogInt( Size(G), PrimePGroup(G) ) ] do
  qs[i]:=0;
od;
for i in [ 1 .. Length(ccs_repr) ] do 
  if IsElementaryAbelian( ccs_repr[i] ) then
    if ForAll( msl[i], 
               x -> IsElementaryAbelian( ccs[x[1]][x[2]] ) = false ) then
      n := LogInt( Size(ccs_repr[i]), PrimePGroup(G) );
      qs[n] := qs[n] + 1;
    fi;
  fi;
od;
return qs;
end);


#############################################################################
##
#A  ClassSumNumbers( <G> )
##  
##  Let l[i] be the number of class sums S such that there exists class sum L
##  such that L^(p^i)=S. Equivalently, l[i] is the number of conjugacy 
##  classes S for which the following condition holds: if x in S, then there 
##  exists y in G such that y^(p^i)=x, but p^i-th powers of all of its 
##  conjugates are not equal to x. It was proved in [M.M.Parmenter, C.Polcino
##  Milies, A note on isomorphic group rings, Bol.Soc.Bras.Mat., 12 (1981), 
##  57-56] that the numbers l[i] are determined by the group algebra KG.
##  The function calculates the list of l[i]. The calculation is finished
##  when we reach i such that all p^i-th powers of class sums are trivial.
InstallMethod(ClassSumNumbers,
              "for a p-group ",
              true,
              [ IsPGroup ],
              0,
function(G)
local F, FG, emb, cc, cs, l, i, x;
F :=GF( PrimePGroup(G) );
FG := GroupRing(F,G);
emb := Embedding(G,FG);
cc := ConjugacyClasses(G);
cs := []; 
l := [];
cs[1] := List( cc, c -> Sum( List( AsList(c), x -> x^emb ) ) );
i:=0;
repeat 
  i:=i+1;
  cs[i+1] := List( cs[i], x -> x^PrimePGroup(G) );
  l[i] := Length( Set( Filtered( cs[i+1], x -> x in cs[1]) ) );
until ForAll( cs[i+1], x -> x=Zero(FG) or x=One(FG) );
return l;
end);


#############################################################################
##
#A  NumberOfConjugacyClassesPPowers( <G> )
##  
##  The number of conjugacy classes of p^i-th powers of elements of the group
##  G is determined by the group algebra KG [M.Wursthorn, Die modularen
##  Gruppenringe der gruppen der Ordnung 2^6, Diplomarbeit, Universitat 
##  Stuttgart, 1990; M.Wursthorn, Isomorphisms of modular group algebras: an
##  algorithm and its application to groups of order 2^6, J.Symbolic Comput.
##  15 (1993), no.2, 211-227].
##  For a p-group G of exponent p^t, the function returns a list of the 
##  length t, i-th entry of which is the number of conjugacy classes of
##  p^i-th powers of elements of the group G.
InstallMethod(NumberOfConjugacyClassesPPowers,
              "for a p-group",
              true,
              [ IsPGroup ],
              0,
function(G)
local ncc, pow, cc, i, x;
ncc := []; 
pow := []; 
pow[1] := AsList(G);
cc := ConjugacyClasses(G);
for i in [ 1 .. Length(Factors(Exponent(G))) ] do
  pow[i+1] := Set( List( pow[i], x -> x^PrimePGroup(G) ) );
  ncc[i] := Length( Set( List( pow[i+1], 
                    x -> PositionProperty( [ 1 .. Length(cc) ], 
                                             i -> x in cc[i]) ) ) );
od;
return ncc;
end);


#############################################################################
##
#A  RoggenkampParameter( <G> )
##  
##  Let T = { g_1, ..., g_t} be the full system of representatives of 
##  conjugacy classes of the group G. Then the number
##  R(G) = \sum_{i=1,...,t} log_p ( | C_G( g_i ) / \Phi( C_G( g_i ) ) |) 
##  is determined by the group algebra KG. This parameter was introduced
##  by K.Roggenkamp and was described in [M.Wursthorn, Die modularen
##  Gruppenringe der gruppen der Ordnung 2^6, Diplomarbeit, Universitat 
##  Stuttgart, 1990; M.Wursthorn, Isomorphisms of modular group algebras: an
##  algorithm and its application to groups of order 2^6, J.Symbolic Comput.
##  15 (1993), no.2, 211-227]. 
InstallMethod(RoggenkampParameter,
              "for a p-group ",
              true,
              [ IsPGroup ],
              0,
function(G)
local reps, sum, g, c, pn;
reps := List( ConjugacyClasses(G), Representative );
sum := 0;
for g in reps do
  c := Centralizer( G, g );
  pn := Size( c / FrattiniSubgroup(c) );
  sum := sum + LogInt( pn, PrimePGroup(G) );
od;
return sum;
end);


#############################################################################
##
#A  KernelSize( < KG , [ n, m, k] > )
##  
##  Returns the size of the kernel of the following mapping, depending on
##  three parameters [ n, m, k]: Phi_nmk from I^n/I^n+m to I^(np^k)/I^(np^k+m),
##  which is induced by turning an element x from I^n to ist p^k-th power
##  and maps  x + I^n+m  to  x^(p^k) + I^(np^k+m). The kernel size of such
##  mapping is an invariant of KG [see M.Wursthorn, Die modularen 
##  Gruppenringe der gruppen der Ordnung 2^6, Diplomarbeit, Universitat 
##  Stuttgart, 1990; M.Wursthorn, Isomorphisms of modular group algebras: an
##  algorithm and its application to groups of order 2^6, J.Symbolic Comput.
##  15 (1993), no.2, 211-227]. 
InstallMethod( KernelSizeOp,
    "LAGUNA : kernel size of power mapping",
    true,
    [ IsPModularGroupAlgebra, IsList ],
    0,
function( KG, pars ) 
local n, m, k, p, A, w, v, q, q1, i, v1, f, c, a, r, x;
# first some preliminary calculations
n := pars[1]; 
m := pars[2]; 
k := pars[3];
p := Characteristic(UnderlyingField(KG));
A := AugmentationIdealPowerSeries(KG);
w := WeightedBasis(KG);    
v := w.weightedBasis;
q := w.weights;
# we analyze the list of weights to determine positions 
# of basis elements of I^n/I^n+m in the WeightedBasis
q1:=Filtered([1..Length(q)], i -> n <=q[i] and q[i]<=n+m-1);
# from this we may deduce the size of I^n/I^n+m
Info(LAGInfo, 3, "Testing factorideal I^", n, "/I^", n+m, " of size ", p, "^", Length(q1), "=", 
                 p^Length(q1) );
if n*p^k >= AugmentationIdealNilpotencyIndex(KG) then
  return p^Length(q1);        # if the result is evident
elif p^Length(q1) < LAGUNA_LOWER_KERNEL_SIZE_LIMIT or 
     p^Length(q1) > LAGUNA_UPPER_KERNEL_SIZE_LIMIT then 
                              # if the test will be too long!!!!
  return fail;                # (this limit may be changed in future)
else
  v1:=List(q1, i -> v[i]);           # basis of I^n/I^n+m 
  f:=UnderlyingField(KG)^Length(q1); # such vector space could be
  c:=Enumerator(f);                  # very nicely enumerated!!!
  r:=0;                              # here we store the result
  for a in c do
    # now coset representatives of I^n/I^n+m can be generated "on fly"
    x:=Sum(List([1..Length(q1)], i -> a[i]*v1[i]));
    if x^(p^k) in A[ Minimum( Length(A),n*p^k+m ) ] then
      r:=r+1;
    fi;
  od;
  return r;
fi;
end );


############################################################################
##
#E
##