# this functions provides the small nilpotent Lie algebras calculated by
# Mubarakzyanov and of Morozov as reported in 
# Patera, J.; Sharp, R. T.; Winternitz, P.; Zassenhaus, H.
# Invariants of real low dimension Lie algebras.
# J. Mathematical Phys. 17 (1976), no. 6, 986--994.


SmallNilpotentLieAlgebras := function(campo)
local z,u,alfa,t,a,i, Campo;

Campo := function ( campo )
    if IsInt( campo )  then
        if campo = 0  then
            return Rationals;
        elif campo = -1  then
            return GaussianRationals;
        elif IsPrimePowerInt( campo )  then
            return GF( campo );
        fi;
    fi;
    if not IsField( campo )  then
        Error( "Qual'e' il campo?" );
    fi;
    return campo;
end;


campo:=Campo(campo);

# campo:=GF(p);;
z:=Zero(campo);;
u:=One(campo);;
alfa:=u;;
t:=[];;a:=[];;


# dimensioni 1, 3 e 4
t[1]:=[];;a[1]:=[];;
t[3]:=[];;a[3]:=[];;
t[4]:=[];;a[4]:=[];;
t[1][1]:=EmptySCTable(1,z,"antisymmetric");
t[3][1]:=EmptySCTable(3,z,"antisymmetric");
t[4][1]:=EmptySCTable(4,z,"antisymmetric");
SetEntrySCTable(t[3][1],2,3,[u,1]);
SetEntrySCTable(t[4][1],2,4,[u,1]);
SetEntrySCTable(t[4][1],3,4,[u,2]);
a[1][1]:=LieAlgebraByStructureConstants(campo,t[1][1]);
a[3][1]:=LieAlgebraByStructureConstants(campo,t[3][1]);
a[4][1]:=LieAlgebraByStructureConstants(campo,t[4][1]);

# dimensione 5
t[5]:=[];a[5]:=[];
for i in [1..6] do
  t[5][i]:=EmptySCTable(5,z,"antisymmetric");
od;

SetEntrySCTable(t[5][1],3,5,[u,1]);
SetEntrySCTable(t[5][1],4,5,[u,2]);

SetEntrySCTable(t[5][2],2,5,[u,1]);
SetEntrySCTable(t[5][2],3,5,[u,2]);
SetEntrySCTable(t[5][2],4,5,[u,3]);

SetEntrySCTable(t[5][3],3,4,[u,2]);
SetEntrySCTable(t[5][3],3,5,[u,1]);
SetEntrySCTable(t[5][3],4,5,[u,3]);

SetEntrySCTable(t[5][4],2,4,[u,1]);
SetEntrySCTable(t[5][4],3,5,[u,1]);

SetEntrySCTable(t[5][5],3,4,[u,1]);
SetEntrySCTable(t[5][5],2,5,[u,1]);
SetEntrySCTable(t[5][5],3,5,[u,2]);

SetEntrySCTable(t[5][6],3,4,[u,1]);
SetEntrySCTable(t[5][6],2,5,[u,1]);
SetEntrySCTable(t[5][6],3,5,[u,2]);
SetEntrySCTable(t[5][6],4,5,[u,3]);

for i in [1..6] do
 a[5][i]:=LieAlgebraByStructureConstants(campo,t[5][i]);
od;

# dimensione 6
t[6]:=[];a[6]:=[];
for i in [1..22] do
  t[6][i]:=EmptySCTable(6,z,"antisymmetric");
od;

SetEntrySCTable(t[6][1],1,2,[u,3]);
SetEntrySCTable(t[6][1],1,3,[u,4]);
SetEntrySCTable(t[6][1],1,5,[u,6]);
SetEntrySCTable(t[6][2],1,2,[u,3]);
SetEntrySCTable(t[6][2],1,3,[u,4]);
SetEntrySCTable(t[6][2],1,4,[u,5]);
SetEntrySCTable(t[6][2],1,5,[u,6]);
SetEntrySCTable(t[6][3],1,2,[u,6]);
SetEntrySCTable(t[6][3],1,3,[u,4]);
SetEntrySCTable(t[6][3],2,3,[u,5]);
SetEntrySCTable(t[6][4],1,2,[u,5]);
SetEntrySCTable(t[6][4],1,3,[u,6]);
SetEntrySCTable(t[6][4],2,4,[u,6]);
SetEntrySCTable(t[6][5],1,3,[u,5]);
SetEntrySCTable(t[6][5],1,4,[u,6]);
SetEntrySCTable(t[6][5],2,3,[-alfa,6]);
# ho messo -alfa, senno' veniva scomponibile
SetEntrySCTable(t[6][5],2,4,[u,5]);

SetEntrySCTable(t[6][6],1,2,[u,6]);
SetEntrySCTable(t[6][6],1,3,[u,4]);
SetEntrySCTable(t[6][6],1,4,[u,5]);
SetEntrySCTable(t[6][6],2,3,[u,5]);
SetEntrySCTable(t[6][7],1,3,[u,4]);
SetEntrySCTable(t[6][7],1,4,[u,5]);
SetEntrySCTable(t[6][7],2,3,[u,6]);
SetEntrySCTable(t[6][8],1,2,[u,3,u,5]);
SetEntrySCTable(t[6][8],1,3,[u,4]);
SetEntrySCTable(t[6][8],2,5,[u,6]);
SetEntrySCTable(t[6][9],1,2,[u,3]);
SetEntrySCTable(t[6][9],1,3,[u,4]);
SetEntrySCTable(t[6][9],1,5,[u,6]);
SetEntrySCTable(t[6][9],2,3,[u,6]);
SetEntrySCTable(t[6][10],1,2,[u,3]);
SetEntrySCTable(t[6][10],1,3,[u,5]);
SetEntrySCTable(t[6][10],1,4,[u,6]);
SetEntrySCTable(t[6][10],2,3,[-alfa,6]);
SetEntrySCTable(t[6][10],2,4,[u,5]);

SetEntrySCTable(t[6][11],1,2,[u,3]);
SetEntrySCTable(t[6][11],1,3,[u,4]);
SetEntrySCTable(t[6][11],1,4,[u,5]);
SetEntrySCTable(t[6][11],2,3,[u,6]);
SetEntrySCTable(t[6][12],1,3,[u,4]);
SetEntrySCTable(t[6][12],1,4,[u,6]);
SetEntrySCTable(t[6][12],2,5,[u,6]);
SetEntrySCTable(t[6][13],1,2,[u,5]);
SetEntrySCTable(t[6][13],1,3,[u,4]);
SetEntrySCTable(t[6][13],1,4,[u,6]);
SetEntrySCTable(t[6][13],2,5,[u,6]);
SetEntrySCTable(t[6][14],1,3,[u,4]);
SetEntrySCTable(t[6][14],1,4,[u,6]);
SetEntrySCTable(t[6][14],2,3,[u,5]);
SetEntrySCTable(t[6][14],2,5,[alfa,6]);
SetEntrySCTable(t[6][15],1,2,[u,3,u,5]);
SetEntrySCTable(t[6][15],1,3,[u,4]);
SetEntrySCTable(t[6][15],1,4,[u,6]);
SetEntrySCTable(t[6][15],2,5,[u,6]);

SetEntrySCTable(t[6][16],1,3,[u,4]);
SetEntrySCTable(t[6][16],1,4,[u,5]);
SetEntrySCTable(t[6][16],1,5,[u,6]);
SetEntrySCTable(t[6][16],2,3,[u,5]);
SetEntrySCTable(t[6][16],2,4,[u,6]);
SetEntrySCTable(t[6][17],1,2,[u,3]);
SetEntrySCTable(t[6][17],1,3,[u,4]);
SetEntrySCTable(t[6][17],1,4,[u,6]);
SetEntrySCTable(t[6][17],2,5,[u,6]);
SetEntrySCTable(t[6][18],1,2,[u,3]);
SetEntrySCTable(t[6][18],1,3,[u,4]);
SetEntrySCTable(t[6][18],1,4,[u,6]);
SetEntrySCTable(t[6][18],2,3,[u,5]);
SetEntrySCTable(t[6][18],2,5,[alfa,6]);
SetEntrySCTable(t[6][19],1,2,[u,3]);
SetEntrySCTable(t[6][19],1,3,[u,4]);
SetEntrySCTable(t[6][19],1,4,[u,5]);
SetEntrySCTable(t[6][19],1,5,[u,6]);
SetEntrySCTable(t[6][19],2,3,[u,6]);
SetEntrySCTable(t[6][20],1,2,[u,3]);
SetEntrySCTable(t[6][20],1,3,[u,4]);
SetEntrySCTable(t[6][20],1,4,[u,5]);
SetEntrySCTable(t[6][20],1,5,[u,6]);
SetEntrySCTable(t[6][20],2,3,[u,5]);
SetEntrySCTable(t[6][20],2,4,[u,6]);

SetEntrySCTable(t[6][21],1,2,[u,3]);
SetEntrySCTable(t[6][21],1,5,[u,6]);
SetEntrySCTable(t[6][21],2,3,[u,4]);
SetEntrySCTable(t[6][21],2,4,[u,5]);
SetEntrySCTable(t[6][21],3,4,[u,6]);
SetEntrySCTable(t[6][22],1,2,[u,3]);
SetEntrySCTable(t[6][22],1,3,[u,5]);
SetEntrySCTable(t[6][22],1,5,[u,6]);
SetEntrySCTable(t[6][22],2,3,[u,4]);
SetEntrySCTable(t[6][22],2,4,[u,5]);
SetEntrySCTable(t[6][22],3,4,[u,6]);

for i in [1..22] do
 a[6][i]:=LieAlgebraByStructureConstants(campo,t[6][i]);
od;


# return a[d][n];
# end;

return a;
end;

