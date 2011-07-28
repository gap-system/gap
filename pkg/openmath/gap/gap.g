#############################################################################
##
#W  gap.g               OpenMath Package               Andrew Solomon
#W                                                     Marco Costantini
##
#H  @(#)$Id: gap.g,v 1.63 2010/11/12 13:18:23 alexk Exp $
##
#Y    Copyright (C) 1999, 2000, 2001, 2006
#Y    School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y    Copyright (C) 2004, 2005, 2006 Marco Costantini
##
##  This file contains the semantic mappings from parsed openmath
##  symbols to GAP objects.
##

Revision.("openmath/gap/gap.g") :=
    "@(#)$Id: gap.g,v 1.63 2010/11/12 13:18:23 alexk Exp $";


######################################################################
##
#F  OMgapId( <obj> )
##
##  Forces GAP to evaluate its argument.
##
BindGlobal("OMgapId",  x->x);


######################################################################
##
#F  OMgap1ARGS( <obj> )
#F  OMgap2ARGS( <obj> )
##
##  OMgapnARGS Throws an error if the argument is not of length n.
##
BindGlobal("OMgap1ARGS", function(x)
  if Length(x) <> 1 then
    Error("argument list of length 1 expected");
  fi;
	return true;
end);

BindGlobal("OMgap2ARGS", function(x)
  if Length(x) <> 2 then
    Error("argument list of length 2 expected");
  fi;
	return true;
end);


######################################################################
##
##  Semantic mappings for symbols from arith1.cd
## 
BindGlobal("OMgapPlus", Sum);
BindGlobal("OMgapTimes", Product);
BindGlobal("OMgapDivide", x-> OMgapId([OMgap2ARGS(x), x[1]/x[2]])[2]);
BindGlobal("OMgapPower", x-> OMgapId([OMgap2ARGS(x), x[1]^x[2]])[2]);


######################################################################
##
##  Semantic mappings for symbols from field3.cd
##
BindGlobal("OMgap_field_by_poly", function( x )
    # The 1st argument of field_by_poly is a univariate polynomial 
    # ring R over a field, and the second argument is an irreducible
    # polynomial f in this polynomial ring R. So, when applied to R
    # and f, the value of field_by_poly is value the quotient ring R/(f).
	return AlgebraicExtension( x[1], x[2] );;
	end);	
	
	
######################################################################
##
##  Semantic mappings for symbols from field4.cd
##
BindGlobal("OMgap_field_by_poly_vector", function( x )
    # The symbol field_by_poly_vector has two arguments, the 1st 
    # should be a field_by_poly(R,f). The 2nd argument should be a 
    # list L of elements of F, the coefficient field of the univariate 
    # polynomial ring R = F[X]. The length of the list L should be equal 
    # to the degree d of f. When applied to R and L, it represents the 
    # element L[0] + L[1] x + L[2] x^2 + ... + L[d-1] ^(d-1) of R/(f),
    # where x stands for the image of x under the natural map R -> R/(f).
	return ObjByExtRep( FamilyObj( One( x[1] ) ), x[2] );
	end);

######################################################################
##
##  Semantic mappings for symbols from groupname1.cd
##
BindGlobal("OMquaternion_group", function() 
	local F, a, b, Q;
	F := FreeGroup( "a", "b" );
	a:=F.1; b:=F.2;
	Q :=F/[ a^4, b^2*a^2, a*b*a^-1*b ]; 
	return Image( EpimorphismQuotientSystem( PQuotient( Q, 2, 3 ) ) );
	end);
	
######################################################################
##
##  Semantic mappings for symbols from relation.cd
## 
BindGlobal("OMgapEq", x-> OMgapId([OMgap2ARGS(x), x[1]=x[2]])[2]);
BindGlobal("OMgapNeq", x-> not OMgapEq(x));
BindGlobal("OMgapLt", x-> OMgapId([OMgap2ARGS(x), x[1]<x[2]])[2]);
BindGlobal("OMgapLe",x-> OMgapId([OMgap2ARGS(x), x[1]<=x[2]])[2]);
BindGlobal("OMgapGt", x-> OMgapId([OMgap2ARGS(x), x[1]>x[2]])[2]);
BindGlobal("OMgapGe", x-> OMgapId([OMgap2ARGS(x), x[1]>=x[2]])[2]);

######################################################################
##
##  Semantic mappings for symbols from integer.cd
## 
BindGlobal("OMgapQuotient", 
	x-> OMgapId([OMgap2ARGS(x), EuclideanQuotient(x[1],x[2])])[2]);
BindGlobal("OMgapRem", 
	x-> OMgapId([OMgap2ARGS(x), EuclideanRemainder(x[1],x[2])])[2]);
BindGlobal("OMgapGcd", Gcd);

######################################################################
##
##  Semantic mappings for symbols from logic1.cd
## 
BindGlobal("OMgapNot", x-> OMgapId([OMgap1ARGS(x), not x[1]])[2]);
BindGlobal("OMgapOr", function(x) local t; return ForAny( x, t -> t = true ); end );
BindGlobal("OMgapXor", function(x) 
	local t; return IsOddInt(Number( x, t -> t = true ) ); end );
BindGlobal("OMgapAnd", function(x) local t; return ForAll( x, t -> t = true ); end );
# Old 2-argument versions were:
# BindGlobal("OMgapOr", x -> OMgapId([OMgap2ARGS(x), x[1] or x[2]])[2]);
# BindGlobal("OMgapXor", 
#	x-> OMgapId([OMgap2ARGS(x), (x[1] or x[2]) and not (x[1] and x[2])])[2]);
# BindGlobal("OMgapAnd", x-> OMgapId([OMgap2ARGS(x), x[1] and x[2]])[2]);

######################################################################
##
##  Semantic mappings for symbols from list1.cd
## 
BindGlobal("OMgapList", List);
BindGlobal("OMgapMap", x -> List( x[2], x[1] ) );
BindGlobal("OMgapSuchthat", x -> Filtered( x[1], x[2] ) );


######################################################################
##
##  Semantic mappings for symbols from set1.cd
## 
BindGlobal("OMgapSet", Set);
BindGlobal("OMgapIn", x-> OMgapId([OMgap2ARGS(x), x[1] in x[2]])[2]);
BindGlobal("OMgapUnion", Union);
BindGlobal("OMgapIntersect", Intersection);
BindGlobal("OMgapSetDiff", 
	x-> OMgapId([OMgap2ARGS(x), Difference(x[1], x[2])])[2]);
# Old 2-argument versions were:
# BindGlobal("OMgapUnion", x-> OMgapId([OMgap2ARGS(x), Union(x[1],x[2])])[2]);
# BindGlobal("OMgapIntersect", 
#	x-> OMgapId([OMgap2ARGS(x), Intersection(x[1], x[2])])[2]);

######################################################################
##
##  Semantic mappings for symbols from linalg1.cd
## 
BindGlobal("OMgapMatrixRow", OMgapId);
BindGlobal("OMgapMatrix", OMgapId);

######################################################################
##
##  Semantic mappings for symbols from permut1.cd
## 
BindGlobal("OMgapPermutation", PermList );

######################################################################
##
##  Semantic mappings for symbols from group1.cd
## 
BindGlobal("OMgapConjugacyClass",
	x->OMgapId([OMgap2ARGS(x), ConjugacyClass(x[1], x[2])])[2]);
BindGlobal("OMgapDerivedSubgroup",
	x->OMgapId([OMgap1ARGS(x), DerivedSubgroup(x[1])])[2]);
BindGlobal("OMgapElementSet",
	x->OMgapId([OMgap1ARGS(x), Elements(x[1])])[2]);
BindGlobal("OMgapIsAbelian", 
	x->OMgapId([OMgap1ARGS(x), IsAbelian(x[1])])[2]);
BindGlobal("OMgapIsNormal", 
	x->OMgapId([OMgap2ARGS(x), IsNormal(x[1], x[2])])[2]);
BindGlobal("OMgapIsSubgroup",
	x->OMgapId([OMgap2ARGS(x), IsSubgroup(x[1], x[2])])[2]);
BindGlobal("OMgapNormalClosure",
	x->OMgapId([OMgap2ARGS(x), NormalClosure(x[1], x[2])])[2]);
BindGlobal("OMgapQuotientGroup",  
	x->OMgapId([OMgap2ARGS(x), x[1]/ x[2]])[2]);
BindGlobal("OMgapSylowSubgroup", 
	x->OMgapId([OMgap2ARGS(x), SylowSubgroup(x[1], x[2])])[2]);

######################################################################
##
##  Semantic mappings for symbols from permgrp.cd
## 
BindGlobal("OMgapIsPrimitive",
	x->OMgapId([OMgap1ARGS(x), IsPrimitive(x[1])])[2]);
BindGlobal("OMgapOrbit", x->OMgapId([OMgap2ARGS(x), Orbit(x[1], x[2])])[2]);
BindGlobal("OMgapStabilizer", 
	x->OMgapId([OMgap2ARGS(x), Stabilizer(x[1], x[2])])[2]);
BindGlobal("OMgapIsTransitive", 
	x->OMgapId([OMgap1ARGS(x), IsTransitive(x[1])])[2]);


######################################################################
##
##  Semantic mappings for symbols from polyd1.cd
##
BindGlobal("OMgap_poly_ring_d_named", function( x )
    # poly_ring_d_named is the constructor of polynomial ring. 
    # The first argument is a ring (the ring of the coefficients), 
    # the remaining arguments are the names of the variables.
	local coeffring, indetnames, indets, name;
	coeffring := x[1];
	indetnames := x{[2..Length(x)]};
	# We call Indeterminate with the 'old' option to enforce 
	# the usage of existing indeterminates when applicable
	indets := List( indetnames, name -> Indeterminate( coeffring, name : old ) );
	return PolynomialRing( coeffring, indets );
	end);
	
	
BindGlobal("OMgap_poly_ring_d",	function( x )
    # poly_ring_d is the constructor of polynomial ring.
    # The first argument is a ring (the ring of the coefficients), 
    # the second is the number of variables as an integer. 
	local coeffring, rank;
	coeffring := x[1];
	rank := x[2];
	return PolynomialRing( coeffring, rank );
	end);
		

BindGlobal("OMgap_SDMP", function( x )
    # SDMP is the constructor for multivariate polynomials without
    # any indication of variables or domain for the coefficients.
	# Its arguments are just *monomials*. No monomials should differ only by
    # the coefficient (i.e it is not permitted to have both 2*x*y and x*y 
    # as monomials in a SDMP). 
	# We just pass the list of monomials (represented as lists containing
	# coefficients and powers and indeterminates) as the 2nd argument in 
	# the DMP symbol, which will construct the polynomial in the polynomial 
	# ring given as the 1st argument of the DMP symbol
	return x;
	end);
	
	
BindGlobal("OMgap_DMP",	function( x )
    # DMP is the constructor of Distributed Multivariate Polynomials. 
    # The first argument is the polynomial ring containing the polynomial 
    # and the second is a "SDMP"
	local one, polyring, terms, fam, ext, t, term, i, poly;
	polyring := x[1];
	one := One( CoefficientsRing( polyring ) );
	terms := x[2];
	fam:=RationalFunctionsFamily( FamilyObj( one ) );
	ext := [];
	for t in terms do
	  term := [];
	  for i in [2..Length(t)] do
	    if t[i]<>0 then
	      Append( term, [i-1,t[i]] );
	    fi;
	  od;
	  Add( ext, term );
	  Add( ext, one*t[1] );
	od;
    poly := PolynomialByExtRep( fam, ext );	
	return poly;
	end);


######################################################################
##
##  Semantic mappings for symbols from polyu.cd
##
BindGlobal("OMgap_poly_u_rep", function( x )
	local indetname, rep, coeffs, r, i, indet, fam, nr;
	indetname := x[1];
	rep := x{[2..Length(x)]};
	coeffs:=[];
	for r in rep do
      coeffs[r[1]+1]:=r[2];
    od;  
    for i in [1..Length(coeffs)] do
      if not IsBound(coeffs[i]) then
        coeffs[i]:=0;
      fi;  
    od;
    indet := Indeterminate( Rationals, indetname : old );
	fam := FamilyObj( 1 );
    nr := IndeterminateNumberOfLaurentPolynomial( indet ); 
	return LaurentPolynomialByCoefficients( fam, coeffs, 0, nr );
	end );
	
BindGlobal("OMgap_term", x->x );
		

#####################################################################
##
##  The Symbol Table for supported symbols from official OpenMath CDs
##
##  Maps a pair ["cd", "name"] to the corresponding OMgap... function
##  defined above or immediately in the record
##
InstallValue( OMsymRecord, rec( 

alg1 := rec( 
	one  := 1, 
	zero := 0
),

arith1 := rec(
	abs := x -> AbsoluteValue(x[1]),
	divide := OMgapDivide,
	gcd := Gcd,
	lcm := Lcm,
	minus := x -> x[1]-x[2],
	plus := OMgapPlus,
	power := OMgapPower,
	product := x -> Product( List( x[1], i -> x[2](i) ) ),
	root := 
		function(x) 
		if x[2]=2 then 
        	return Sqrt(x[1]);
      	elif x[1]=1 then 
        	return E(x[2]);
      	else
        	Error("OpenMath package: the symbol arith1.root \n", 
            	  "is supported only for square roots and roots of unity!\n");  
      	fi;  
      	end,
    sum := x -> Sum( List( x[1], i -> x[2](i) ) ),
    times := OMgapTimes,
    unary_minus := x -> -x[1]
),

arith2 := rec( 
	inverse := x -> Inverse(x[1]), 
	times := OMgapTimes
),

arith3 := rec( 
	extended_gcd := 
		function(x)
	  	local r;
	  	if Length(x)=2 then
			r := Gcdex( x[1], x[2] );
			return [ r.gcd, r.coeff1, r.coeff2 ];
	  	else
        	Error("OpenMath package: the symbol arith3.extended_gcd \n", 
            	  "for more than two arguments is not implemented yet!\n");  
	  	fi;
	  	end
),

bigfloat1 := rec(
	bigfloat := fail, # maybe later
	bigfloatprec := fail
),	

calculus1 := rec(
	defint := fail,
	diff := x -> Derivative(x[1]),
	int := fail,
	nthdiff := 
		function(x)
        local n, f, i;
        n := x[1];
        f := x[2];
        for i in [ 1 .. n ] do
        	f := Derivative( f );
        	if IsZero(f) then
            	return f;
          	fi;
        od;
        return f;
        end,
    partialdiff := fail
),

coercions := rec(
	 int2flt  := fail # converts an integer to a float
),

combinat1 := rec(
	Bell := x -> Bell(x[1]),
	binomial := x -> Binomial(x[1],x[2]),
	Fibonacci := x -> Fibonacci(x[1]),
	multinomial := x -> Factorial(x[1]) / Product( List( x{[ 2 .. Length(x) ]}, Factorial ) ),
	Stirling1 := x -> Stirling1(x[1],x[2]),
	Stirling2 := x -> Stirling2(x[1],x[2])
),

field1 := rec(
	addition := fail, 
	additive_group := fail, 
	carrier := fail, 
	expression := fail, 
	field := fail, 
	identity := fail, 
	inverse := fail, 
	is_commutative := fail, 
	is_subfield := fail, 
	minus := fail, 
	multiplication := fail, 
	multiplicative_group := fail, 
	power := fail, 
	subfield := fail, 
	subtraction := fail, 
	zero := fail
),

field2 := rec(
	conjugation := fail, 
	is_automorphism := fail, 
	is_endomorphism := fail, 
	is_homomorphism := fail, 
	is_isomorphism := fail, 
	isomorphic := fail, 
	left_multiplication := fail, 
	right_multiplication := fail
),

field3 := rec(
	field_by_poly := OMgap_field_by_poly,
	fraction_field := fail,
	free_field := fail
),
    
field4 := rec(
	automorphism_group := fail,
	field_by_poly_map := fail,
	field_by_poly_vector := OMgap_field_by_poly_vector,
	homomorphism_by_generators := fail
),
     
fieldname1 := rec(
	C := fail,
	Q := Rationals,
	R := fail
),

finfield1 := rec(
	conway_polynomial := x -> ConwayPolynomial( x[1], x[2] ), 
	discrete_log := x -> LogFFE( x[2], x[1] ), 
	field_by_conway := x -> GF( x[1], x[2] ), 
	is_primitive := x -> x[1] = PrimitiveRoot( DefaultField( x[1] ) ), 
	is_primitive_poly := fail,  # see IsPrimitivePolynomial
	minimal_polynomial := fail, # see MinimalPolynomial
	primitive_element := 
		function(x)
		if IsBound(x[2]) then
			Error("OpenMath: 2-argument version of finfield1.primitive_element is not supported \n");
		else
			return Z(x[1]);
		fi;	 
		end
),

fns1 := rec(
    domain := fail, 
    domainofapplication := fail, 
	identity := x -> IdFunc(x[1]),
	image := fail, 
    inverse := fail, 
	lambda := "LAMBDA",
    left_compose := fail, 
    left_inverse := fail, 
    range := fail, 
    right_inverse := fail
),

graph1 := rec(
	arrowset := fail, 
	digraph := fail, 
	edgeset := fail, 
	graph := fail, 
	source := fail, 
	target := fail, 
	vertexset := fail
),

graph2 := rec(
	automorphism_group := fail, 
	is_automorphism := fail, 
	is_endomorphism := fail, 
	is_homomorphism := fail, 
	is_isomorphism := fail, 
	isomorphic := fail
),

group1 := rec(
	carrier := OMgapElementSet,
	expression := fail, # might be useful to embed the result of the 2nd argument into the 1st argument,
	                    # but single expression from arith1 CD will work too
	group := fail,      # our private symbol group1.group_by_generators is installed in private/private.g
	identity := x -> One( x[1] ),
	inversion := x -> MappingByFunction( x[1], x[1], a->a^-1, a->a^-1 ),
	is_commutative := OMgapIsAbelian,
	is_normal := OMgapIsNormal,
	is_subgroup := OMgapIsSubgroup,
	monoid := x -> AsMonoid( x[1] ),
	multiplication := fail, # represents a unary function, whose argument should be a group G.  
	                        # It returns the multiplication map on G. We allow for the map to be n-ary. 
	normal_closure := OMgapNormalClosure,
	power := fail, # using just arith1 CD will work too   
	subgroup := x-> Subgroup( x[2], x[1] )
),

group2 := rec(
	conjugation := x -> ConjugatorAutomorphism( x[1], x[2] ),
	is_automorphism := fail,
	is_endomorphism := fail,
	is_homomorphism := fail,
	is_isomorphism := fail,
	isomorphic := fail,
	left_multiplication := fail, 
	right_inverse_multiplication := fail,
	right_multiplication := fail
),

group3 := rec(
	alternating_group := x -> AlternatingGroup( x[1] ),
	alternatingn := x -> AlternatingGroup( x[1] ),
	automorphism_group := x -> AutomorphismGroup( x[1] ),
	center := x -> Center( x[1] ),
	centralizer := x -> Centralizer( x[1], x[2] ), # 2nd argument as list not supported yet
	derived_subgroup := OMgapDerivedSubgroup,      
	direct_power := x -> DirectProduct( ListWithIdenticalEntries( x[1], x[2] ) ),
	direct_product := x -> DirectProduct( x[1] ),
	free_group := x -> FreeGroup( x[1] ),
	GL := fail,
	GLn := x -> GL( x[1], x[2] ),
	invertibles := fail,
	normalizer := x ->  Normalizer( x[1], x[2] ),
	quotient_group := OMgapQuotientGroup,     
	SL := fail,
	SLn := x -> SL( x[1], x[2] ),
	sylow_subgroup := OMgapSylowSubgroup,
	symmetric_group := x -> SymmetricGroup( x[1] ), 
	symmetric_groupn := x -> SymmetricGroup( x[1] )
),

group4 := rec(
	are_conjugate := fail,
	conjugacy_class := OMgapConjugacyClass,
	conjugacy_class_representatives := fail,
	conjugacy_classes := fail, 
	left_coset := fail,
	left_coset_representative := fail, 
	left_cosets := fail,
	left_transversal := fail, 
	right_coset := fail,
	right_coset_representative := fail,
	right_cosets := fail,
	right_transversal := fail 
),

group5 := rec(
	homomorphism_by_generators := fail,
	left_quotient_map := fail,
	right_quotient_map := fail
),
	
groupname1 := rec(
	cyclic_group := x -> CyclicGroup(x[1]),
	dihedral_group := x -> DihedralGroup(2*x[1]),
	generalized_quaternion_group := fail,
	quaternion_group := OMquaternion_group()
),

integer1 := rec(
	factorial := x -> Factorial( x[1] ),
    factorof := x -> IsInt( x[2]/ x[1] ),
    quotient := x -> QuoInt( x[1], x[2] ), # is OMgapQuotient now obsolete?
    remainder := x -> RemInt( x[1], x[2] ) # is OMgapRem now obsolete?
),

integer2 := rec(
	class := x -> ZmodnZObj(x[1],x[2]),
	divides := x -> IsInt( x[2]/ x[1] ),
	eqmod := x -> IsInt( (x[1]-x[2])/x[3] ),
	euler := x -> Phi(x[1]),
	modulo_relation := x -> function(a,b) return IsInt( (a-b)/x[1] ); end,
	neqmod := x -> not IsInt( (x[1]-x[2])/x[3] ),
	ord := 
		function(x)
		local i;
		if not IsInt(x[2]/x[1]) then
			return 0;
		else
			return Number( FactorsInt(x[2]), i -> i=x[1]);
		fi;	 
		end
),

interval1 := rec(
	integer_interval := x -> [ x[1] .. x[2] ],
	interval := fail, 
	interval_cc := fail, 
	interval_co := fail, 
	interval_oc := fail, 
	interval_oo := fail
),

list1 := rec(
	list := OMgapList,
	map := OMgapMap,
	suchthat := OMgapSuchthat
),

list2 := rec(
	append := fail, 
	cons := fail, 
	first := fail, 
	("in") := fail, 
	list_selector := fail, 
	nil := fail, 
	rest := fail, 
	reverse := fail, 
	size := fail
),

list3 := rec(
	difference := fail, 
	entry := fail, 
	length := fail, 
	list_of_lengthn := fail, 
	select := fail
),

logic1 := rec(
	("and") := OMgapAnd,
    equivalent := x -> x[1] and x[2] or not x[1] and not x[2],
   	("false") := false,
    implies := x -> not x[1] or x[2],   	
	("not") := OMgapNot,
	("or") := OMgapOr, 
	("true") := true,
	xor := OMgapXor
),

monoid1 := rec(
	carrier := fail, 
	divisor_of := fail, 
	expression := fail, 
	identity := fail, 
	invertibles := fail, 
	is_commutative := fail, 
	is_invertible := fail, 
	is_submonoid := fail, 
	monoid := fail, # our private symbol monoid1.monoid_by_generators is installed in private/private.g
	multiplication := fail, 
	semigroup := fail, 
	submonoid := fail
),

monoid2 := rec(
	is_automorphism := fail, 
	is_endomorphism := fail, 
	is_homomorphism := fail, 	
	is_isomorphism := fail, 
	isomorphic := fail, 
	left_multiplication := fail, 
	right_multiplication := fail
),	

monoid3 := rec(
	automorphism_group := fail, 
	concatenation := fail, 
	cyclic_monoid := fail, 
	direct_power := fail, 
	direct_product := fail, 
	emptyword := fail, 
	free_monoid := fail, 
	left_regular_representation := fail, 
	maps_monoid := fail, 
	strings := fail
),

multiset1 := rec(
	cartesian_produc := fail, 
	emptyset := fail, 
	("in") := fail, 
	intersect := fail, 
	multiset := fail, 
	notin := fail, 
	notprsubset := fail, 
	notsubset := fail, 
	prsubset := fail, 
	setdiff := fail, 
	size := fail, 
	subset := fail, 
	union := fail,
),

nums1 := rec(
	based_integer := fail, 
	e := fail, 
	gamma := fail, 
	i := E(4),
	infinity := infinity,
	NaN := "nan",
	pi := fail, 
	rational := OMgapDivide
),

permgp1 := rec(
	group := 
		function(x)
		local i;
		if x[1] = "left_compose" then
			Error( "GAP does not accept permutation groups with permutation1.left_compose multiplication \n" );
		elif not x[1] = "right_compose" then
			if not IsPerm(x[1]) then
				Error( "The first argument must be permutation1.left_compose or permutation1.right_compose \n" ); 
			fi;
		else
			return Group( x{ [ 2 .. Length(x) ] } );
		fi;	 
		end,
    base := fail,
    generators := fail,
    is_in := fail,
    is_primitive := OMgapIsPrimitive,
    is_subgroup := fail,
    is_transitive := OMgapIsTransitive,
    orbit := OMgapOrbit,
    orbits := fail,
    order := fail,
    schreier_tree := fail,
    stabilizer := OMgapStabilizer, # n-ary function  
    stabilizer_chain := fail,
    support := fail
),

permgp2 := rec(
    alternating_group := fail,
    symmetric_group := fail,
    cyclic_group := fail,
    dihedral_group := fail,
    quaternion_group := fail,
    vierer_group := fail
),

permgrp := rec(
 	is_primitive := fail,
    is_transitive := fail,
    orbit := fail,
    stabilizer := fail
),

permut1 := rec(
	permutation := OMgapPermutation
),

permutation1 := rec(
	action := 
		function(x)
			return x[2]^x[1];
		end,
	are_distinct := 
		function(x)
			return Length(x)=Length(Set(x));
		end,		
	cycle := 
		function(x)
			local img;
		    img := x{[2..Length(x)]};
		    Add( img, x[1] );
			return MappingPermListList( x, img );
		end,
	cycle_type := 
		function(x)
		local c, r, t, i, j;
		r:=[];
		c := CycleStructurePerm( x[1] );
		for i in [1..Length(c)] do
		  if IsBound(c[i]) then
		    t := i+1;
		    Append( r, List([1..c[i]], j -> t ) );
		  fi;
		od;
		return r;
		end,
	cycles := fail,
	domain := x -> [ 1 .. DegreeOfTransformation( x[1] ) ],
	endomap := Transformation,
	endomap_left_compose := x -> x[2]*x[1],
	endomap_right_compose := x -> x[1]*x[2],
	fix := fail, # permutation1.support refers to permutations,
	             # but permutation1.fix refers to endomaps in terms
	             # of their support, and also contains a typo. We
	             # do not support it, and the fixed points of a
	             # permutation can be easily computed anyway.
	inverse := x -> x[1]^-1,
	is_bijective := 
		function(x)
			if IsTransformation(x[1]) then
				return DegreeOfTransformation(x[1]) = RankOfTransformation(x[1]);
			else
				# the example in the CD is_bijective(endomap(2,3,5)) contradicts to the endomap definition
				Error( "permutation1.is_bijective: the argument must be a transformation!!!!\n" );
			fi;		
		end,
	is_endomap := 
		function(x)
		local len;
		if IsList(x) then
			if ForAll( x, IsPosInt ) then
				len := Length(x);
				if ForAll( x, t -> t <= len ) then
					return true;
				fi;
			fi;
		fi;
		return false;					
		end,	
	is_list_perm := 
		function(x)
		local len;
		if IsList(x) then
			if ForAll( x, IsPosInt ) then
				len := Length(x);
				if ForAll( x, t -> t <= len ) then
					if Length(Set(x)) = len then
						return true;
					fi;
				fi;
			fi;
		fi;
		return false;					
		end,
	is_permutation := 
		function( x )
			local t,c,i;
			if ForAll( x[1], IsPerm ) then
				for t in x[1] do
					c := CycleStructurePerm(t);
					if ForAny( [ 1 .. Length(c)-1 ], i -> IsBound(c[i])) then
						return false;
					elif c[Length(c)]>1 then
						return false;
					fi;	
				od;
				if Length(x[1]) > 1 and Intersection( List( x[1], MovedPoints ) ) <> [] then
					return false;
				else
					return true;
				fi;	
			fi;	
			return false;
		end,
	left_compose := "left_compose",   # string to analyse in permgp1.group
	length :=
		function(x)
			local c, i;
			c := CycleStructurePerm( x[1] );
			if ForAny( [ 1 .. Length(c)-1 ], i -> IsBound(c[i])) then
				Error( "permutation1.lenght requires a cycle, not a product of cycles!!!\n");
			else
				return Length(c)+1;
			fi;
		end,
	list_perm := PermList,
	listendomap := x -> ListPerm( x[1] ), 
	order := x -> Order( x[1] ),
	permutation := 
		function( x )
			if Length( x ) = 0 then
				return ();
			elif ForAll( x, IsPerm ) then
				return Product( x );
			else
				Error( "permutation1.permutation requires a list of cycles!!!\n");
			fi;	
		end,
	permutationsn := x -> AsList( SymmetricGroup(x[1]) ),
	right_compose := "right_compose", # string to analyse in permgp1.group
	sign := x -> SignPerm( x[1] ),
	support := x -> MovedPoints( x[1] )
),

poly := rec(
	coefficient := fail, 
	coefficient_ring := fail, 
	convert := fail, degree := fail, 
	degree_wrt := fail, 
	discriminant := fail, 
	evaluate := fail, 
	expand := fail, 
	factor := fail, 
	factored := fail, 
	gcd := fail, 
	lcm := fail, 
	leading_coefficient := fail, 
	partially_factored := fail, 
	power := fail, 
	resultant := fail, 
	squarefree := fail, 
	squarefreed := fail
),	

polyd1 := rec(
	ambient_ring := fail, 
	anonymous := fail, 
	DMP := OMgap_DMP,
	DMPL := fail, 
	minus := fail, 
	plus := fail,
	poly_ring_d := OMgap_poly_ring_d,
	poly_ring_d_named := OMgap_poly_ring_d_named,
	power := fail, 
	rank := fail,
	SDMP := OMgap_SDMP,
	term := OMgap_term,
	times := fail, 
	variables := fail
),

polyd3 := rec(
	collect := fail, 
	list_to_poly_d := fail, 
	poly_d_named_to_arith := fail, 
	poly_d_to_arith := fail
),

polygb := rec(
	completely_reduced := fail, 
	groebner := fail, 
	groebner_basis := fail, 
	groebnered := fail, 
	reduce := fail
),

polygb2 := rec(
	extended_in := fail, 
	("in") := fail, 
	in_radical := fail, 
	minimal_groebner_element := fail
),	

polynomial1 := rec(
	coefficient := fail, 
	coefficient_ring := fail, 
	degree := fail, 
	expand := fail, 
	leading_coefficient := fail, 
	leading_monomial := fail, 
	leading_term  := fail
),	

polynomial2 := rec(
	class := fail, 
	divides := fail, 
	eqmod := fail, 
	modulo_relation := fail, 
	neqmod := fail
),

polynomial3 := rec(
	factors := fail, 
	gcd := fail, 
	quotient := fail, 
	remainder := fail
),	

# polynomial4 (cf. SVN: na3/protocolx/openmath/polynomial4.ocd) 

polyoperators1 := rec(
	expand := fail, 
	factor := fail, 
	factors := fail, 
	gcd := fail
),	

polyu := rec(
	poly_u_rep := OMgap_poly_u_rep,
	polynomial_ring_u := fail,
	polynomial_u := fail,
	term := OMgap_term
),

quant1 := rec(
	exists := fail, 
	forall := fail
),	

relation1 := rec(
	approx := fail,
	eq := OMgapEq,
	geq := OMgapGe,	
	gt := OMgapGt,
	leq := OMgapLe,		
	lt := OMgapLt,
	neq := OMgapNeq
),

ring1 := rec(
	addition := fail, 
	additive_group := fail, 
	carrier := fail, 
	expression := fail, 
	identity := fail, 
	is_commutative := fail, 
	is_subring := fail, 
	multiplication := fail, 
	multiplicative_monoid := fail,
	negation := fail, 
	power := fail, 
	ring := fail, 
	subring := fail, 
	subtraction := fail, 
	zero := fail
),

ring2 := rec(
	is_automorphism := fail, 
	is_endomorphism := fail, 
	is_homomorphism := fail, 
	is_isomorphism := fail, 
	isomorphic := fail, 
	left_multiplication := fail, 
	right_multiplication := fail
),

ring3 := rec(
	direct_power := fail, 
	direct_product := fail, 
	free_ring := fail, 
	ideal := fail, 
	integers := fail, 
	invertibles := fail, 
	is_ideal := fail, 
	kernel := fail, 
	m_poly_ring := fail,
	matrix_ring := fail, 
	multiplicative_group := fail, 
	poly_ring := fail, 
	rincipal_ideal := fail, 
	quotient_ring := fail
),

ring4 := rec(
	is_domain := fail, 
	is_field := fail, 
	is_maximal_ideal := fail, 
	is_prime_ideal := fail, 
	is_zero_divisor := fail
),

ring5 := rec(
	automorphism_group := fail, 
	homomorphism_by_generators := fail, 
	quotient_by_poly_map := fail, 
	quotient_map := fail
),

ringname1 := rec(
	quaternions := fail, 
	Z := fail, 
	Zm := fail
),

semigroup1 := rec(
	carrier := fail, 
	expression := fail, 
	factor_of := fail, 
	is_commutative := fail, 
	is_subsemigroup := fail, 
	magma := fail, 
	multiplication := fail, 
	semigroup := fail, # our private symbol semigroup1.semiroup_by_generators 
	                   # is installed in private/private.g
	subsemigroup := fail
),

semigroup2 := rec(
	is_automorphism := fail, 
	is_endomorphism := fail, 
	is_homomorphism := fail, 
	is_isomorphism := fail, 
	isomorphic := fail, 
	left_multiplication := fail, 
	right_multiplication := fail
),

semigroup3 := rec(
	automorphism_group := AutomorphismGroup, # requires MONOID package and GRAPE, duplicated in semigroup4 CD
	cyclic_semigroup := fail, 
	direct_power := fail, 
	direct_product := fail, 
	free_semigroup := fail, 
	left_regular_representation := fail, 
	maps_semigroup := fail
),

semigroup4 := rec(
	automorphism_group := fail,
	homomorphism_by_generators := fail
),

set1 := rec(
	cartesian_product := Cartesian,
    emptyset := [ ],
 	("in") := OMgapIn,
	intersect := OMgapIntersect,  
	map := OMgapMap,  
	notin := x -> not x[1] in x[2],	   
    notprsubset := x -> not IsSubset( x[2], x[1] ) or IsEqualSet( x[2], x[1] ),	
    notsubset := x -> not IsSubset( x[2], x[1] ),
    prsubset := x -> IsSubset( x[2], x[1] ) and not IsEqualSet( x[2], x[1] ),
	set := OMgapSet,
	setdiff := OMgapSetDiff,
	size := x -> Size( x[1] ),
	subset := x -> IsSubset( x[2], x[1] ),    
	suchthat := OMgapSuchthat, 
	union := OMgapUnion
),	  

set3 := rec(
	big_intersect := fail, 
	big_union := fail, 
	cartesian_power := fail, 
	k_subsets := fail, 
	map_with_condition := fail, 
	map_with_target := fail, 
	map_with_target_and_condition := fail, 
	powerset := fail
),
	
setname1 := rec(
	C := fail, # the set of complex numbers
	N := NonnegativeIntegers,
	P := fail, # the set of positive prime numbers
	Q := Rationals,
	R := fail, # the set of real numbers
	Z := Integers
),

setname2 := rec(
	A := fail, # the set of algebraic numbers
	Boolean := [ true, false ], 
	GFp := 
		function( x )
		if not IsPrimeInt( x[1] ) then
			Error( "OpenMath : the argument of setname2.GFp must be a prime integer \n");
		else
			return GF( x[1] );	
		fi;	
		end, 
	GFpn := 
		function( x )
		if not IsPrimeInt( x[1] ) then
			Error( "OpenMath : the 1st argument of setname2.GFpn must be a prime integer \n");
		else
			return GF( x[1]^x[2] );	
		fi;	
		end,	
	H := fail, # the set of quaternions (over reals?)
	QuotientField := fail, # the quotient field of any integral domain
	Zm := x -> Integers mod x[1]
)

));
 

OMsymRecord.semigroup4 := rec(
	automorphism_group := AutomorphismGroup, # requires MONOID package and GRAPE, duplicated in semigroup3 CD
	homomorphism_by_generators :=            # requires MONOID
        function(x)
        local g;
        # we use NC method trusting that the client send valid input (this must be the case for the GAP client)
        return SemigroupHomomorphismByImagesOfGensNC( x[1], x[2], List( x[3], g -> g[2] ) );
        end);

 
######################################################################
##
#F  OMsymLookup( [<cd>, <name>] )
##
##  Maps a pair [<cd>, <name>] to the corresponding OMgap... function
##  defined above by looking up the symbol table.
##
BindGlobal("OMsymLookup", function( symbol )
local cd, name;
cd := symbol[1];
name := symbol[2];
if IsBound( OMsymRecord.(cd) ) then
  if IsBound( OMsymRecord.(cd).(name) ) then
    if not OMsymRecord.(cd).(name) = fail then
      return OMsymRecord.(cd).(name);
    else
      # the symbol is present in the CD but not implemented
	  # The number, format and sequence of arguments for the three error messages
	  # below is strongly fixed as it is needed in the SCSCP package to return
	  # standard OpenMath errors to the client
	  Error("OpenMathError: ", "unhandled_symbol", " cd=", symbol[1], " name=", symbol[2]);
    fi;
  else
    # the symbol is not present in the mentioned content dictionary.
	Error("OpenMathError: ", "unexpected_symbol", " cd=", symbol[1], " name=", symbol[2]);
  fi;
else
  # we didn't even find the cd
  Error("OpenMathError: ", "unsupported_CD", " cd=", symbol[1], " name=", symbol[2]);
fi;  	
end);
 

#############################################################################
#E
