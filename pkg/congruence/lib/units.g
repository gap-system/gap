#############################################################################
#
# ann.g                  The Congruence package                     Ann Dooms
#                                                                Eric Jespers
#                                                         Alexander Konovalov
#
#############################################################################


#############################################################################
#
# NormalSubgroupsForM2Q(G,H)
#
# Returns a list of normal subgroups N of G such that quotient G/N is H.
#
NormalSubgroupsForM2Q := function( G, H )
local ord,m, N;
ord:= Size(G)/Size(H);
# Can we speedup this computing only normal subgroups of given size? 
m:=Filtered( NormalSubgroups(G) , N -> Size(N)=ord);
m:=Filtered( m, N -> IdGroup( G/N ) = IdGroup( H ) );
return m;
end;


#############################################################################
#
# GeneratorsInM2Q(G,H)
#
# Returns a list of lists of generators of a subgroup of f.i. in M_2(Q), 
# one for each homomorphic image. 
# H has to be S3 or D8!
#
GeneratorsInM2Q:=function(G,H)
local k,m;
if IdGroup(H)=[6,1] then 
    k:=3;  # H = S_3
else 
    k:=4;  # H = D_8
fi;
m:=NormalSubgroupsForM2Q(G,H);
if Length(m) > 0 then
  return GeneratorsOfGroup( PrincipalCongruenceSubgroup(k*Size(G)/Size(H) ) );
else
  return [ ];
fi;
end;


#############################################################################
#
# MatrixEntries( matrix, k )
#
# Returns a list with integer entries. Will be applied with k=4n or 3n.
# PROBLEM: some matrices gave non-integers! SOLUTION: multiplied with -I_2!
#
MatrixEntries := function( matrix, k )
local g11,g12,g21,g22;
g11:=(matrix[1][1]-1)/k;
if not IsInt(g11) then
  matrix:=-matrix;
  g11:=(matrix[1][1]-1)/k;
fi;
g12:=matrix[1][2]/k;
g21:=matrix[2][1]/k;
g22:=(matrix[2][2]-1)/k;
return [ g11, g12, g21, g22 ];
end;


#############################################################################
#
# D8Alpha(matrix,n)
#
# Returns a list with integer entries. 
# Will be applied with n = order of the normal subgroup N determining M_2(Q).
#
D8Alpha := function(matrix,n)
local m,a0,a1,a2,a3;
m := MatrixEntries(matrix,4*n);
a0 := m[1] +   m[4];
a1 := m[1] -   m[2] + 2*m[3] - m[4];
a2 := m[1] + 2*m[3] -   m[4];
a3 :=-m[1] +   m[2] +   m[4];
return [ a0, a1, a2, a3 ];
end;


#############################################################################
#
# S3Alpha(matrix,n)
#
# Returns a list with integer entries.
# Will be applied with n = order of the normal subgroup N determining M_2(Q).
#
S3Alpha:= function(matrix,n)
local m,a0,a1,a2,a3;
m := MatrixEntries(matrix,3*n);
a0 :=    m[1] +   m[4];
a1 :=  2*m[1] + 3*m[2] - m[3] -   m[4];
a2 := -2*m[1] - 3*m[2] + m[3] + 2*m[4];
a3 :=   -m[1] - 3*m[2] + m[4];
return [ a0, a1, a2, a3 ];
end;


#############################################################################
#
# Alphas( G, H )
#
# Returns a list of lists with integer entries which will serve for the units in U(ZG).
#
Alphas := function( G, H ) 
local gen,f,alpha,i;
gen := GeneratorsInM2Q( G, H );
if IdGroup(H)=[6,1] then
    f:=S3Alpha;
else
    f:=D8Alpha;
fi;
alpha:=[];
if Length(gen) > 0 then
  for i in [1..Length(gen)] do
    alpha[i] := f( gen[i], Size(G)/Size(H) );
  od;  
fi;          
return alpha;  
end;


#############################################################################
#
# LiftGenerator(G,N)
#
# Lifts a minimal list of generators form G/N to G.
#
LiftGenerator := function( G, N )
local l,q,s,hom,i;
l:=[];
hom:=NaturalHomomorphismByNormalSubgroup(G,N);
q := Image( hom );
s := MinimalGeneratingSet( q );
for i in [ 1 .. Length(s) ] do
    Add( l, PreImagesRepresentative( hom,s[i]) );
od;
return l;
end;


#############################################################################
#
# CreateUnits(G,H)
#
# Creates units of ZG. H must be D8 or S3.
#
CreateUnits:=function(G,H)
local m,alpha,a,b,x,y,ZG,emb,hat,u,i,j;
m:=NormalSubgroupsForM2Q(G,H);
alpha:=Alphas(G,H);
a:=[];
b:=[];
ZG:=GroupRing(Integers,G);
emb := Embedding(G,ZG);
hat:=[];
u:=[];
if Length(m)<>0 then
    for i in [1..Length(m)] do
        hat[i]:=Sum( List(m[i], x->x^emb));
        u[i]:=[];
        x := LiftGenerator(G,m[i])[1];
        y := LiftGenerator(G,m[i])[2];
        if x^2=Identity(G) then
            a[i]:=y^emb;
            b[i]:=x^emb;
        else
            a[i]:=x^emb;
            b[i]:=y^emb;
        fi;
        if IdGroup(H)=[6,1] then
            for j in [1..Length(alpha)] do
                u[i][j]:=Identity(ZG) + 
                        (alpha[j][1]*Identity(ZG) +
                         alpha[j][2]*a[i] +
                         alpha[j][3]*b[i] +
                         alpha[j][4]*a[i]^2*b[i])*(Identity(ZG)-a[i])*hat[i];
            od;
        else   
            for j in [1..Length(alpha)] do 
                u[i][j]:=Identity(ZG) + 
                        (alpha[j][1]*Identity(ZG) +
                         alpha[j][2]*a[i] +
                         alpha[j][3]*b[i] +
                         alpha[j][4]*a[i]*b[i])*(Identity(ZG)-a[i]^2)*hat[i];
            od;
        fi;
    od;
else
fi;
return u;
end;


#############################################################################
#
# UnitsOfZGOfFiniteIndexInM2Q(G)
#
UnitsOfZGOfFiniteIndexInM2Q:=
function(G)
local u,v;
u:=[];
v:=[];
if IsNilpotent(G)=true then
   u:=CreateUnits(G,DihedralGroup(8));
else
   u:=CreateUnits(G,DihedralGroup(8));
   v:=CreateUnits(G,DihedralGroup(6));  
fi;
return [u,v];
end;