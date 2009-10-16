n := 12;
sgens := [ [ [ 0,1,-1,1 ],[ 0,0,0,1 ],[ 1,1,-1,1 ],[ 1,0,-1,0 ] ],
           [ [ 1,0,0,0 ],[ 0,1,0,1 ],[ 0,0,1,-1 ],[ 0,0,0,-1 ] ] ] * Z(7)^0;
ConvertToMatrixRep(sgens[1]);
ConvertToMatrixRep(sgens[2]);
s5 := Group(sgens);
# Make one new empty generator:
gen := [];
for i in [1..4*n] do
    Add(gen,0*[1..4*n]*Z(7));
    ConvertToVectorRep(gen[Length(gen)]);
od;
ConvertToMatrixRep(gen);
gens := [];
id := sgens[1]^0;
for i in [0..n-1] do
    m := MutableCopyMat(gen);
    for j in [0..n-1] do
        m{[1+4*j..4+4*j]}{[1+4*j..4+4*j]} := id;
    od;
    m{[1+4*i..4+4*i]}{[1+4*i..4+4*i]} := sgens[1];
    Add(gens,m);
    m := MutableCopyMat(gen);
    for j in [0..n-1] do
        m{[1+4*j..4+4*j]}{[1+4*j..4+4*j]} := id;
    od;
    m{[1+4*i..4+4*i]}{[1+4*i..4+4*i]} := sgens[2];
    Add(gens,m);
od;
# Set a transposition on top:
m := MutableCopyMat(gen);
for j in [2..n-1] do
    m{[1+4*j..4+4*j]}{[1+4*j..4+4*j]} := id;
od; 
m{[1..4]}{[5..8]} := id;
m{[5..8]}{[1..4]} := id;
Add(gens,m);
m := MutableCopyMat(gen);
for j in [0..n-2] do
    m{[5+4*j..8+4*j]}{[1+4*j..4+4*j]} := id;
od; 
m{[1..4]}{[4*n-3..4*n]} := id;
Add(gens,m);
r := RandomInvertibleMat(n*4,GF(7));
ConvertToMatrixRep(r);
ri := r^-1;
gens2 := List(gens,x->r*x*ri);
g := Group(gens2);

