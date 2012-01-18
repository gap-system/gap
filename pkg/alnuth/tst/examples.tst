gap> START_TEST("Testing examples from Alnuth");  

# example 1
gap> F := ExampleMatField(1);
<rational matrix field of unknown degree>
gap> DegreeOverPrimeField(F);
4
gap> DefiningPolynomial(F);
x_1^4+6*x_1^3+5*x_1^2-12*x_1-11
gap> basis := Basis(F, 
> [ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ],
> [ [ -1, 1, 1, 0 ], [ 5, -5, -5, 11 ], [ 3, -4, -7, 11 ], [ 3, -3, -4, 7 ] ],
>   [ [ 9, -10, -13, 22 ], [ -12, 17, 21, -33 ], [ -11, 18, 28, -44 ], 
>       [ -9, 13, 18, -28 ] ], 
>   [ [ -3, 5, 7, -11 ], [ 7, -9, -13, 22 ], [ 6, -9, -13, 22 ], 
>      [ 5, -7, -10, 17 ] ] ]);;
gap> ForAll(BasisVectors(basis), mat-> IsIntegerOfNumberField(F, mat));
true
gap> ForAll(BasisVectors(MaximalOrderBasis(F)), 
>           mat-> ForAll( Coefficients( basis, mat ), IsInt));
true
gap> ug := UnitGroup(F);
<matrix group with 4 generators>
gap> RelationLatticeOfUnits(F,GeneratorsOfGroup(ug));
[ [ 2, 0, 0, 0 ] ]

# example 2
gap> F := ExampleMatField(2);
<rational matrix field of unknown degree>
gap> DegreeOverPrimeField(F);
4
gap> DefiningPolynomial(F);
x_1^4+6*x_1^3+5*x_1^2-12*x_1-11
gap> basis := Basis(F, 
> [ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ], 
>   [ [ -1, 1, 1, 0 ], [ -4, -9, -5, 11 ], [ -6, -8, -7, 11 ], 
>       [ -5, -8, -5, 11 ] ], 
>   [ [ -9, -18, -13, 22 ], [ 15, 29, 21, -33 ], [ 25, 34, 28, -44 ], 
>       [ 12, 19, 15, -22 ] ], 
>   [ [ 6, 9, 7, -11 ], [ -11, -17, -13, 22 ], [ -12, -17, -13, 22 ], 
>       [ -8, -12, -9, 16 ] ] ] );;
gap> ForAll(BasisVectors(basis), mat-> IsIntegerOfNumberField(F, mat));
true
gap> ForAll(BasisVectors(MaximalOrderBasis(F)), 
>           mat-> ForAll( Coefficients( basis, mat ), IsInt));
true
gap> ug := UnitGroup(F);
<matrix group with 4 generators>
gap> Size(ug);
infinity

# example 3
gap> F := ExampleMatField(3);
<rational matrix field of unknown degree>
gap> DegreeOverPrimeField(F);
4
gap> DefiningPolynomial(F);
x_1^4+30*x_1^3-x_1^2-3390*x_1-13691
gap> basis := Basis( F, 
> [ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ], 
>   [ [ -4, 6, 7, 0 ], [ -31, -60, -35, 77 ], [ -35, -48, -41, 66 ], 
>       [ -34, -53, -33, 75 ] ], 
>   [ [ -11, -15, -10, 22 ], [ 3, 3, 6, 0 ], [ 7, 10, 8, -11 ], 
>       [ -3, -5, 0, 12 ] ], 
>   [ [ 4, 10, 8, -11 ], [ -15, -27, -18, 33 ], [ -18, -25, -21, 33 ], 
>       [ -13, -20, -14, 26 ] ] ] );;
gap> ForAll(BasisVectors(basis), mat-> IsIntegerOfNumberField(F, mat));
true
gap> ForAll(BasisVectors(MaximalOrderBasis(F)), 
>           mat-> ForAll( Coefficients( basis, mat ), IsInt));
true
gap> ug := UnitGroup(F);
<matrix group with 4 generators>
gap> Size(ug);
infinity

# example 4
gap> F := ExampleMatField(4);
<rational matrix field of unknown degree>
gap> DegreeOverPrimeField(F);
4
gap> DefiningPolynomial(F);
x_1^4+2*x_1^3-7*x_1^2-8*x_1+1
gap> basis := Basis( F, 
> [ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ], 
>   [ [ 0, -1, 1, 0 ], [ -1, -4, -5, 11 ], [ -1, 4, 4, -11 ], [ -1, 1, 0, -2 ] ]
>     , 
>   [ [ 0, 8, 9, -22 ], [ -2, 8, -1, -11 ], [ 3, -10, -5, 22 ],
>       [ 1, -5, -6, 15 ] ],
>   [ [ 1, -5, -3, 11 ], [ 1, -9, -7, 22 ], [ -2, 9, 7, -22 ], [ -1, 3, 2, -7 ]
>      ] ] );;
gap> ForAll(BasisVectors(basis), mat-> IsIntegerOfNumberField(F, mat));
true
gap> ForAll(BasisVectors(MaximalOrderBasis(F)), 
>           mat-> ForAll( Coefficients( basis, mat ), IsInt));
true
gap> ug := UnitGroup(F);
<matrix group with 4 generators>
gap> Size(ug);
infinity

# example 5
gap> F := ExampleMatField(5);
<rational matrix field of unknown degree>
gap> DegreeOverPrimeField(F);
4
gap> DefiningPolynomial(F);
x_1^4-364*x_1^3+2751*x_1^2-364*x_1+1
gap> basis := Basis( F,
> [ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ], 
>   [ [ 148, 95, 101, -165 ], [ -257, -165, -175, 286 ], [ 96, 65, 67, -110 ], 
>       [ -64, -40, -43, 70 ] ], 
>   [ [ 3549, 2310, 2437, -3982 ], [ -6147, -4001, -4221, 6897 ], 
>       [ 2195, 1430, 1508, -2464 ], [ -1560, -1015, -1071, 1750 ] ], 
>   [ [ 2999, 1953, 2060, -3366 ], [ -5195, -3383, -3568, 5830 ], 
>       [ 1853, 1206, 1272, -2079 ], [ -1319, -859, -906, 1480 ] ] ] );;
gap> ForAll(BasisVectors(basis), mat-> IsIntegerOfNumberField(F, mat));
true
gap> ForAll(BasisVectors(MaximalOrderBasis(F)), 
>           mat-> ForAll( Coefficients( basis, mat ), IsInt));
true
gap> ug := UnitGroup(F);
<matrix group with 4 generators>
gap> Size(ug);
infinity

# example 6
gap> F := ExampleMatField(6);
<rational matrix field of unknown degree>
gap> DegreeOverPrimeField(F);
4
gap> DefiningPolynomial(F);
x_1^4+18*x_1^3+75*x_1^2-54*x_1-531
gap> basis := Basis( F,
> [ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ], 
>   [ [ -6, -2, -3, 0 ], [ 15, 18, 15, -33 ], [ 11, 16, 7, -22 ], 
>       [ 14, 21, 13, -37 ] ], 
>   [ [ -2, -11, -4, 22 ], [ -27, -36, -24, 66 ], [ -15, -22, -9, 33 ],
>       [ -31, -47, -26, 83 ] ],
>   [ [ 29, 55, 26, -99 ], [ 82, 118, 68, -209 ], [ 37, 55, 25, -88 ],
>       [ 102, 155, 82, -270 ] ] ] );;
gap> ForAll(BasisVectors(basis), mat-> IsIntegerOfNumberField(F, mat));
true
gap> ForAll(BasisVectors(MaximalOrderBasis(F)), 
>           mat-> ForAll( Coefficients( basis, mat ), IsInt));
true
gap> ug := UnitGroup(F);
<matrix group with 4 generators>
gap> Size(ug);
infinity

# example 7
gap> F := ExampleMatField(7);
<rational matrix field of unknown degree>
gap> DegreeOverPrimeField(F);
4
gap> DefiningPolynomial(F);
x_1^4-9118*x_1^3+39843*x_1^2-9118*x_1+1
gap> basis := Basis( F,
> [ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ], 
>   [ [ -16591/25, -4204252/75, -1139984/125, 933941/25 ], 
>       [ 127557/100, 2685042/25, 2183967/125, -3578691/50 ], 
>       [ 160, 39760/3, 2155, -35325/4 ], 
>       [ 47976/25, 4036224/25, 3282924/125, -2689776/25 ] ], 
>   [ [ -172958/5, -227281196/75, -61682584/125, 50500116/25 ],
>       [ 1325391/20, 145139966/25, 118170042/125, -193493841/50 ],
>       [ 32695/4, 2148280/3, 116606, -1909325/4 ],
>       [ 498078/5, 218173052/25, 177632124/125, -145429076/25 ] ],
>   [ [ -1572318/25, -137719084/25, -22425524/25, 91800234/25 ],
>       [ 3012234/25, 263839042/25, 42962292/25, -703475043/100 ],
>       [ 29725/2, 1301735, 211968, -867705 ],
>       [ 4527973/25, 1189801372/75, 64580524/25, -264364324/25 ] ] ] );;
gap> ForAll(BasisVectors(basis), mat-> IsIntegerOfNumberField(F, mat));
true
gap> ForAll(BasisVectors(MaximalOrderBasis(F)), 
>           mat-> ForAll( Coefficients( basis, mat ), IsInt));
true
gap> ug := UnitGroup(F);
<matrix group with 4 generators>
gap> Size(ug);
infinity

# example 8
gap> F := ExampleMatField(8);
<rational matrix field of unknown degree>
gap> DegreeOverPrimeField(F);
4
gap> DefiningPolynomial(F);
x_1^4-2693461698*x_1^3+915480803*x_1^2-183198*x_1+1
gap> basis := Basis( F,
> [ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ], 
>   [ [ 350938712911/294, 1500326345/2, 22032258785/49, 12381906785/28 ], 
>       [ -321440829383/245, -824530541, -48432850131/98, -6804693081/14 ], 
>       [ -1895565335102/441, -8103883972/3, -238010709389/147, -33439903349/21 
>          ], [ 423681072037/105, 2535838285, 10639636697/7, 2989684151/2 ] ], 
>   [ [ 4296545420323143572/147, 1800113708794452685/98, 539482234887109565/49, 
>           1061142474502207065/98 ], 
>       [ -23612415601847672819/735, -989283921486886210/49, 
>           -592963764782450491/49, -1166338752161250809/98 ], 
>       [ -232074212936617048906/2205, -9723159685193494472/147, 
>           -5827933970510514158/147, -1910556664266896923/49 ], 
>       [ 3458087129618678238/35, 434648032727934931/7, 260522311384860087/7, 
>           256219085901701948/7 ] ], 
>   [ [ -359040394192145849/98, -225639486739431445/98, 
>       -270490678428289125/196, -266022798598028295/196 ],
>       [ 2959753770581068096/735, 124004119958269647/49, 74326437761644025/49,
>           73098737073176767/49 ],
>       [ 3232209784961308454/245, 1218772319845216676/147,
>           243505363658010411/49, 239483218757603493/49 ],
>       [ -433462064765870443/35, -54481979964874243/7, -65311563750512469/14,
>          -64232767911560593/14 ] ] ] );;
gap> ForAll(BasisVectors(basis), mat-> IsIntegerOfNumberField(F, mat));
true
gap> ForAll(BasisVectors(MaximalOrderBasis(F)), 
>           mat-> ForAll( Coefficients( basis, mat ), IsInt));
true
gap> ug := UnitGroup(F);
<matrix group with 4 generators>
gap> Size(ug);
infinity

# example 9
gap> F := ExampleMatField(9);
<rational matrix field of unknown degree>
gap> DegreeOverPrimeField(F);
4
gap> DefiningPolynomial(F);
x_1^4-50691194176*x_1^3+13505436470112846*x_1^2-5255736770373376*x_1+1
gap> basis := Basis( F,
> [ [ [ 1, 0, 0, 0 ], [ 0, 1, 0, 0 ], [ 0, 0, 1, 0 ], [ 0, 0, 0, 1 ] ], 
>   [
>       [ 851504247972/229, -1937936674346/229, -603837909603/229, 
>           1577056081004/229 ], 
>       [ 589771389309/458, -671133447401/229, -209117560764/229, 
>           546155850465/229 ], 
>       [ -314679082561/229, 2148551139301/687, 223154956025/229, 
>           -582817030683/229 ], 
>       [ 260652277735/458, -889841242682/687, -92421808448/229, 
>           241378880370/229 ] ], 
>   [
>       [ 479595170949875358661/229, -3274539508376250773645/687,
>           -340102839979551252617/229, 888252880017494540431/229 ],
>       [ 166089147656173639110/229, -378003163829060810519/229,
>           -235562800592787808287/458, 307611862433136447321/229 ],
>       [ -177237322072221156244/229, 1210126057694719416842/687,
>           125687079941754647751/229, -328259272238145784528/229 ],
>       [ 73403753002708619935/229, -167059987151745488349/229,
>           -104107907570323308205/458, 135950274239559405325/229 ] ],
>   [
>       [ -168577244280151879851/229, 1150997507992512356939/687,
>           119545823245159623469/229, -312220038497649730859/229 ],
>       [ -116760353367458396067/458, 265735501720229196779/458,
>           41400049650414034161/229, -216250551372975665307/458 ],
>       [ 62298749337598187302/229, -425358152864100770527/687,
>           -44178888490966125184/229, 115382820501957885815/229 ],
>       [ -51602698069330099209/458, 352328555032045040059/1374,
>           18296915011903387616/229, -95572782957948415617/458 ] ] ] );;
gap> ForAll(BasisVectors(basis), mat-> IsIntegerOfNumberField(F, mat));
true
gap> ForAll(BasisVectors(MaximalOrderBasis(F)), 
>           mat-> ForAll( Coefficients( basis, mat ), IsInt));
true
gap> ug := UnitGroup(F);
<matrix group with 4 generators>
gap> Size(ug);
infinity

# no more examples
gap> F := ExampleMatField(10);
fail

gap> STOP_TEST( "examples.tst", 10000000);   


