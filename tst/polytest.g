#############################################################################
##                                                                         ##
##  Polynomial arithmetic timing tests                      Robert Arthur  ##
##                                                                         ##
#############################################################################

if IsBound(Permutations) then   # running GAP3
    # Without these, the parser doesn't like the GAP4 code's presence
    LaurentPolynomialByCoefficients:= x->x;
    ElementsFamily:= x->x;
    FamilyObj:= x->x;
    
    # require a function to test for zero polynomials
    polyIsZero:= function(p)
        return p = Polynomial(p.baseRing, []);
    end;
    # create a polynomial with base field f, coefficient list l
    PolynomialTest:= function(f, l)   # the actual call
        return Polynomial(f, l);
    end;
fi;
if not IsBound(Permutations) then   # running GAP4
    PolynomialTest:= function(f, l)
        return LaurentPolynomialByCoefficients(
                       ElementsFamily(FamilyObj(f)), l, 0);
    end;
    polyIsZero:= IsZero;
fi;

testfields:= [FiniteField(2), FiniteField(3), FiniteField(128), FiniteField(1013),
     Rationals];


# polys[l] will contain 100 random polynomials over testfields[l].
polys:= List(testfields, x->[]);

# Start the calculations!

ProdTest:=function()
local l,i,j,start,scratch;
  for l in [1..Length(testfields)] do
      start:= Runtime();
      for i in [1..100] do
	  for j in [1..100] do
	      scratch:= polys[l][i]*polys[l][j];
	  od;
      od;
      Print("Time for product over ",testfields[l],": ", Runtime()-start, "\n");
  od;
end;
      
AddTest:=function()
local l,i,j,start,scratch;
  for l in [1..Length(testfields)] do
      start:= Runtime();
      for i in [1..100] do
	  for j in [1..100] do
	      scratch:= polys[l][i]+polys[l][j];
	  od;
      od;
      Print("Time for addition over ",testfields[l],": ", Runtime()-start, "\n");
  od;
end;
      
SubTest:=function()
local l,i,j,start,scratch;
  for l in [1..Length(testfields)] do
      start:= Runtime();
      for i in [1..100] do
	  for j in [1..100] do
	      scratch:= polys[l][i]-polys[l][j];
	  od;
      od;
      Print("Time for subtraction over ",testfields[l],": ", Runtime()-start, "\n");
  od;
end;

# Division not defined for all pairs - we must make sure that p2 divides
# p1.   Timing only performed for final division.

DivTest:=function()
local p,l,i,j,start,scratch,total;
  p:= [];
  for l in [1..Length(testfields)] do
      total:= 0;
      for i in [1..100] do
	  for j in [1..100] do
	      p[j]:= polys[l][i]*polys[l][j];
	  od;
	  start:= Runtime();
	  for j in [1..100] do
	      if not polyIsZero(polys[l][i]) then
		  scratch:= p[j]/polys[l][i];
	      fi;
	  od;
	  total:= total + Runtime() - start;
      od;
      Print("Time for division over ", testfields[l],": ",total,"\n");
  od;

end;

DoTests:=function()
local i,j,a,l;
  for i in [1..100] do
      for j in [1..Length(testfields)] do
	  a:= Random([1..20]);
	  l:= List([1..a], x->Random(testfields[j]));
	  Add(polys[j], PolynomialTest(testfields[j], l));
      od;
  od;

  Print("Fields are: ", testfields, "\n");
  AddTest();
  SubTest();
  ProdTest();
  DivTest();
end;


