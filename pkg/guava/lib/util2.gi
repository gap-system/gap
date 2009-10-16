#############################################################################
##
#A  util2.gi                GUAVA library                       Reinald Baart
#A                                                        &Jasper Cramwinckel
#A                                                           &Erik Roijackers
##
##  This file contains miscellaneous functions
##
#H  @(#)$Id: util2.gi,v 1.6 2004/12/20 21:26:06 gap Exp $
##
## minor bug in SortedGaloisFieldElements fixed 9-24-2004
## several functions added 12-16-2005 
##            (CoefficientToPolynomial, ...,DivisorsMultivariatePolynomial)
##

Revision.("guava/lib/util2_gi") :=
    "@(#)$Id: util2.gi,v 1.6 2004/12/20 21:26:06 gap Exp $";

########################################################################
##
#F  AllOneVector( <n> [, <field> ] )
##
##  Return a vector with all ones.
##

InstallMethod(AllOneVector, "length, Field", true, [IsInt, IsField], 0, 
function(n, F) 
    if n <= 0 then
        Error( "AllOneVector: <n> must be a positive integer" );
    fi;
    return List( [ 1 .. n ], x -> One(F) );
end);

InstallOtherMethod(AllOneVector, "length, fieldsize", true, [IsInt, IsInt], 0, 
function(n, q) 
	return AllOneVector(n, GF(q)); 
end); 

InstallOtherMethod(AllOneVector, "length", true, [IsInt], 0, 
function(n) 
	return AllOneVector(n, Rationals); 
end); 


########################################################################
##
#F  AllOneCodeword( <n>, <field> )
##
##  Return a codeword with <n> ones.
##

InstallMethod(AllOneCodeword, "wordlength, field", true, [IsInt, IsField], 0, 
function(n, F) 
    if n <= 0 then
        Error( "AllOneCodeword: <n> must be a positive integer" );
    fi;
    return Codeword( AllOneVector( n, F ), F );
end);

InstallOtherMethod(AllOneCodeword, "wordlength, fieldsize", true, 
	[IsInt, IsInt], 0, 
function(n, q) 
	return AllOneCodeword(n, GF(q)); 
end); 

InstallOtherMethod(AllOneCodeword, "wordlength", true, [IsInt], 0, 
function(n) 
	return AllOneCodeword(n, GF(2)); 
end); 


#############################################################################
##
#F  IntCeiling( <r> )
##
##  Return the smallest integer greater than or equal to r.
##  3/2 => 2,  -3/2 => -1.
##

InstallMethod(IntCeiling, "method for integer", true, [IsInt], 0, 
function(r) 
	# don't round integers 
	return r; 
end); 

InstallMethod(IntCeiling, "method for rational", true, [IsRat], 0, 
function(r) 
	if r > 0 then
		# round positive numbers to smallest integer 
		# greater than r (3/2 => 2)
		return Int(r)+1;
	else
		# round negative numbers to smallest integer
		# greater than r (-3/2 => -1)
		return Int(r);
	fi;
end);


########################################################################
##
#F  IntFloor( <r> ) 
##
##  Return the greatest integer smaller than or equal to r.
##  3/2 => 1, -3/2 => -2.
##

InstallMethod(IntFloor, "method for integer", true, [IsInt], 0, 
function(r) 
	# don't round integers
	return r;
end); 

InstallMethod(IntFloor, "method for rational", true, [IsRat], 0, 
function(r) 
	if r > 0 then
		# round positive numbers to largest integer
		# smaller than r (3/2 => 1)
		return Int(r);
	else
		# round negative numbers to largest integer
		# smaller than r (-3/2 => -2)
		return Int(r-1);
    fi;
end);


########################################################################
##
#F  KroneckerDelta( <i>, <j> )
##
##  Return 1 if i = j,
##         0 otherwise
##

InstallMethod(KroneckerDelta, true, [IsInt, IsInt], 0, 
function ( i, j )
    
    if i = j then
        return 1;
    else
        return 0;
    fi;
    
end);


########################################################################
##
#F  BinaryRepresentation( <elements>, <length> )
##
##  Return a binary representation of an element
##  of GF( 2^k ), where k <= length.
##  
##  The representation is actually the binary 
##  representation of k+1, where k is the exponent 
##  of the element, taken in the field 2^length.  
##  For example, Z(16)^10 = Z(4)^2.  If length = 4, 
##  the binary representation 1011 = 11(base 10) 
##  is returned.  If length = 2, the binary 
##  representation 11 = 3(base 10) is returned. 
##  
##  If elements is a list, then return the binary
##  representation of every element of the list.
##
##  This function is used to make to Gabidulin codes.
##  It is not intended to be a global function, but including
##  it in all five Gabidulin codes is a bit over the top
##
##  Therefore, no error checking is done.
##

BinaryRepresentation := function ( elementlist, length )
    
    local field, i, log, vector, element;
    
    if IsList( elementlist ) then
        return( List( elementlist,
                      x -> BinaryRepresentation( x, length ) ) );
    else
        
        element := elementlist;
        field := Field( element );

        vector := NullVector( length, GF(2) );
    
        if element = Zero(field) then 
            # exception, log is not defined for zeroes
            return vector;
        else
            log := LogFFE( element, Z(2^length) ) + 1; 
        
            for i in [ 1 .. length ] do
                if log >= 2^( length - i ) then
                    vector[ i ] := One(GF(2)); 
                    log := log - 2^( length - i );
                fi;
            od;
        
            return vector;
        fi;
    fi;
end;


########################################################################
##
#F  SortedGaloisFieldElements( <size> )
##
##  Sort the field elements of size <size> according to
##  their log.
##
##  This function is used to make to Gabidulin codes.
##  It is not intended to be a global function, but including
##  it in all five Gabidulin codes is not a good idea.
##

SortedGaloisFieldElements := function ( size )
    
    local field, els, sortlist, alpha;
    
    if IsInt( size ) then
        field := GF( size );
    else
        field := size;
        size := Size( field );
    fi;
    alpha:=PrimitiveRoot( field );
# this line was moved from immed after the local statement 9-2004    
    els := ShallowCopy(AsSSortedList( field ));
    sortlist := NullVector( size );
    # log 1 = 0, so we add one to each log to avoid
    # conflicts with the 0 for zero.

    sortlist := List( els, function( x )
        if x = Zero(field) then
            return 0;
        else
            return LogFFE( x, alpha ) + 1;
        fi;
        end );

    sortlist{ [ 2 .. size ] } := List( els { [ 2 .. size ] },
                                 x -> LogFFE( x, alpha ) + 1 );
    SortParallel( sortlist, els );
    
    return els;
end;

########################################################################
##
#F  CoefficientToPolynomial( <coeffs> , <R> )
##  
##  Input: a list of coeffs = [c0,c1,..,cd]
##         a univariate polynomial ring R = F[x]
##  Output: a polynomial c0+c1*x+...+cd*x^(d-1) in R
##

InstallMethod(CoefficientToPolynomial, true, [IsList, IsRing], 0, 
function(coeffs,R)
  local p,i,j, lengths, F,xx;
  xx:=IndeterminatesOfPolynomialRing(R)[1];
  F:=Field(coeffs);
  p:=Zero(F);
# lengths:=List([1..Length(coeffs)],i->Sum(List([1..i],j->1+coeffs[j])));
  for i in [1..Length(coeffs)] do 
   p:=p+coeffs[i]*xx^(i-1); 
  od;
  return p;
end);

########################################################################
##
#F  VandermondeMat( <Pts> , <a> )
##  
## Input: Pts=[x1,..,xn], a >0 an integer
## Output: Vandermonde matrix (xi^j), 
##         for xi in Pts and 0 <= j <= a
##         (an nx(a+1) matrix)
##
InstallMethod(VandermondeMat, true, [IsList, IsInt], 0, 
function(Pts,a)
 local V,n,i,j;
 n:=Length(Pts);
 V:=List([1..(a+1)],j->List([1..n],i->Pts[i]^(j-1)));
 return TransposedMat(V);
end);

###########################################################
##
##      DegreeMonomialTerm(m)
##  
## Input: a monomial m in n variables,
##          (not all of which need occur)
##        a multivariate polynomial ring R containing m
## Output: the list of degrees of each variable in m.
##
DegreesMonomialTerm:=function(m,R)
## output is a different format if m is not a monomial
local degrees, e, n0, i, j, l, n1, n,vars,x;
 vars:=IndeterminatesOfPolynomialRing(R);
 e:=ExtRepPolynomialRatFun(m);
 n0:=Length(e);
 n:=Int(n0/2);
 degrees:=[];
 if n>1 then 
  for i in [1..n] do
   l:=e[2*i-1];
   n1:=Length(l);
   for j  in [1..Int(n1/2)] do
     degrees:=Concatenation(degrees,[l[2*j]]);
   od;
  od;
 fi;
 if n=1 then 
  for x in vars do
    degrees:=Concatenation(degrees,[DegreeIndeterminate(m,x)]);
  od;
 fi;
 return degrees;
end;

########################################################################
##
#F  DivisorsMultivariatePolynomial( <f> , <R> )
##  
## Input: f is a polynomial in R=F[x1,...,xn]
## Output: all divisors of f
## uses a slow algorithm (see Joachim von zur Gathen, Jürgen Gerhard,
##  Modern Computer Algebra, exercise 16.10)
##
InstallMethod(DivisorsMultivariatePolynomial, true, 
[IsPolynomial, IsPolynomialRing], 0, function(f,R)
local p,var,vars,mons,degrees,g,d,r,div,ffactors,F,R1,fam,fex,cand,i,j,
      select,T,TN,ti,terms,L,N,k,varpow,nvars,cp,perm,cnt,vals,forig,ediv,
      KroneckerMap,InverseKroneckerMapUnivariate;

 KroneckerMap:=function(f,vars,var,p)
 # maps polys in x1,...,xn to polys in x 
 # induced by xi -> x^(p^(i-1))
 local g;
  g:=Value(f,vars, List([1..Length(vars)],i->var[1]^(p^(i-1))));
  return g;
 end;

 InverseKroneckerMapUnivariate:=function(g,varpow)
 local coeffs,d,f,i;
  if not IsUnivariatePolynomial(g) then
    Error("this function assumes polynomial is univariate");
  fi;
  coeffs:=CoefficientsOfUnivariateLaurentPolynomial(g);
  coeffs:=ShiftedCoeffs(coeffs[1],coeffs[2]);
  d:=Length(coeffs)-1;
  f:=Zero(g);
  for i in [1..Length(coeffs)] do
    if not IsZero(coeffs[i]) then
      f:=f+coeffs[i]*varpow[i];
    fi;
  od;
  return f;
 end;

  cp:=ConstituentsPolynomial(f);
  mons:=cp.monomials;
  # count variable frequencies
  L:=ListWithIdenticalEntries(
    Maximum(List(cp.variables,
      IndeterminateNumberOfUnivariateRationalFunction)),0);
  for i in mons do
    T:=ExtRepPolynomialRatFun(i)[1];
    for j in [1,3..Length(T)-1] do
      L[T[j]]:=L[T[j]]+T[j+1];
    od;
  od;
  T:=[1..Length(L)];
  SortParallel(L,T);
  T:=Reversed(T);
  L:=Reversed(L);
  if ForAny([1..Length(L)],i->L[i]>0 and L[T[i]]<>L[i]) then
    perm:=PermList(T)^-1;
    Info(InfoPoly,2,"Variable swap: ",perm);
    f:=OnIndeterminates(f,perm);
    cp:=ConstituentsPolynomial(f);
    mons:=cp.monomials;
  else
    perm:=(); # irrelevant swap
  fi;

  vars:=cp.variables;
  nvars:=Length(vars);
  F:=CoefficientsRing(R);
  R1:=PolynomialRing(F,1);
  var:=IndeterminatesOfPolynomialRing(R1);
  degrees:=List([1..Length(mons)],i->DegreesMonomialTerm(mons[i],R));
  d:=Maximum(Flat(degrees));
  p:=NextPrimeInt(d);
  p:=Maximum(d+1,2);

  forig:=f;

  # coefficient shift to remove duplicate roots
  cnt:=0;
  vals:=List(vars,i->Zero(F));
  repeat
    if cnt>0 then
      vals:=List(vars,i->Random(F));
      f:=Value(forig,vars,List([1..nvars],i->vars[i]-vals[i]));
    fi;
    g:=KroneckerMap(f,vars,var,p);
    cnt:=cnt+1;
    L:=DegreeOfUnivariateLaurentPolynomial(Gcd(g,Derivative(g)));
    Info(InfoPoly,3,"Trying shift: ",vals,": ",L);
  until cnt>DegreeOfUnivariateLaurentPolynomial(g) or L=0;

  # prepare padic representations of powers
  L:=ListWithIdenticalEntries(nvars,0);
  varpow:=List([0..DegreeOfUnivariateLaurentPolynomial(g)],
		i->Concatenation(CoefficientsQadic(i,p),L){[1..nvars]});
  varpow:=List(varpow,i->Product(List([1..nvars],j->vars[j]^i[j])));

  fam:=FamilyObj(f);
  fex:=ExtRepPolynomialRatFun(f);
  L:=Factors(R1,g);
  N:=Length(L);
  cand:=[1..N];
  for k in [1..QuoInt(N,2)] do
    T:=Combinations(cand,k);
    Info(InfoPoly,2,"Length ",k,": ",Length(T)," candidates");
    ti:=1;
    while ti<=Length(T) do;
      terms:=T[ti];
      div:=Product(L{terms});
      div:=InverseKroneckerMapUnivariate(div,varpow);
      ediv:=ExtRepPolynomialRatFun(div);
      #if not IsOne(ediv[Length(ediv)]) then
      #  div:=div/ediv[Length(ediv)];
      #	 ediv:=ExtRepPolynomialRatFun(div);
      #fi;
      # call the library routine used to test quotient of polynomials
      r:=QuotientPolynomialsExtRep(fam,fex,ediv);
      if r<>fail then
	fex:=r;
	f:=PolynomialByExtRepNC(fam,fex);
	Info(InfoPoly,1,"found factor ",terms," ",div," remainder ",f);
	ffactors:=DivisorsMultivariatePolynomial(f,R);
	Add(ffactors,div);
	if ForAny(vals,i->not IsZero(i)) then
	  ffactors:=List(ffactors,
	                 i->Value(i,vars,List([1..nvars],j->vars[j]+vals[j])));
	fi;

	if not IsOne(perm) then
	  ffactors:=List(ffactors,i->OnIndeterminates(i,perm^-1));
	fi;
	return ffactors;
      fi;
      ti:=ti+1;
    od;
  od;

  if ForAny(vals,i->not IsZero(i)) then
    f:=Value(f,vars,List([1..nvars],j->vars[j]+vals[j]));
  fi;

  if not IsOne(perm) then
    f:=OnIndeterminates(f,perm^-1);
  fi;
  return [f];
end);

###########################################################
##
#F    MultiplicityInList(L,a)
##  
## Input: a list L
##        an element a of L
## Output: the multiplicity a occurs in L
##
MultiplicityInList:=function(L,a)
local mult,b;
  mult:=0;
  for b in L do
   if b=a then mult:=mult+1; fi;
  od;
  return mult;
end;

###########################################################
##
#F    MostCommonInList(L,a)
##  
## Input: a list L
## Output: an a in L which occurs at least as much as any other in L
##
MostCommonInList:=function(L)
local mults,max,maxi,x;
  mults:=List(L,x->MultiplicityInList(L,x));
  max:=Maximum(mults);
  maxi:=Position(mults,max);
  return L[maxi];
end;