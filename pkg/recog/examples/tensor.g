MakeTensorProduct := function(g,h)
    local d,f,gensg,gensh,gensk,gg,i,j,x,xi;
    gensg := GeneratorsOfGroup(g);        
    gensh := GeneratorsOfGroup(h);
    gensk := [];       
    for i in gensg do 
        for j in gensh do 
            Add(gensk,KroneckerProduct(i,j)); 
        od;
    od;
    for i in gensk do
        ConvertToMatrixRep(i);
    od;
    d := Length(gensk[1]);
    f := FieldOfMatrixGroup(g);
    x := PseudoRandom(GL(d,Size(f)));
    xi := x^-1;
    gensk := List(gensk,y->x*y*x^-1);
    gg := GroupWithGenerators(gensk);
    return gg;
end;

tslgl5 := MakeTensorProduct(SL(5,5),GL(7,5));
tslsl7 := MakeTensorProduct(SL(6,7),SL(5,7));
tglgl3 := MakeTensorProduct(GL(7,3),GL(6,3));
genssl := GeneratorsOfGroup(SL(3,5));
sl2 := Group(Concatenation(genssl,[-genssl[1]^0]));
tsl2sl25 := MakeTensorProduct(sl2,sl2);
