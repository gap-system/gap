p := 3;
d := 1;
q := p^d;
n := 3;
m := 2;
a := GL(m,q);        
b := GL(n,q);
f := GF(q);
agens := GeneratorsOfGroup(a);
bgens := GeneratorsOfGroup(b);
if Length(agens) > 2 or Length(bgens) > 2 then
    Error("Alarm: more than 2 generators.");
fi;
x := IdentityMat(m+n)*One(f);
y := IdentityMat(m+n)*One(f);
u := IdentityMat(m+n)*One(f);
v := IdentityMat(m+n)*One(f);
x{[1..m]}{[1..m]} := agens[1];
u{[m+1..m+n]}{[m+1..m+n]} := bgens[1];
y{[1..m]}{[1..m]} := agens[2];
v{[m+1..m+n]}{[m+1..m+n]} := bgens[2];
for i in [m+1..m+n] do
    for j in [1..m] do
        x[i][j] := Random(f);
        y[i][j] := Random(f);
        u[i][j] := Random(f);
        v[i][j] := Random(f);
    od;
od;
ConvertToMatrixRep(x,q);        
ConvertToMatrixRep(y,q);
ConvertToMatrixRep(u,q);
ConvertToMatrixRep(v,q);
t := RandomUnimodularMat(m+n)*One(f);
ConvertToMatrixRep(t,q);
x := t * x * t^-1;
y := t * y * t^-1;
u := t * u * t^-1;
v := t * v * t^-1;
g := Group(x,y,u,v);

