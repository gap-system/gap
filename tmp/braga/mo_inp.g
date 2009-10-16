##########################################################################
##  Specification for the multiplicative/additive elements
##  defined as subsets of [1 .. 4] 
##  where multiplication is intersection and addition is union
##
##  Note: stuff which might normally be accessed through
##  the family is now global at specification time
##  and therefore "hard coded".
##########################################################################


# the whole set
w := [1,2,3,4];

# The element specification
PosetElementSpec := 
rec(
	# name of the new elements
	ElementName := Concatenation("PosetOn",String(w)),

	# arithmetic operations
	One := a -> w,
	Zero := a -> [],
	Multiplication := function(a, b) return Intersection(a, b); end,
	# MultiplicativeInverse := function(a) end,
	Addition := function(a, b) return Union(a, b); end,
	AdditiveInverse := a -> Filtered(w, x->(not x in a)),

	# Information about the representation 
	# RepInfo := IsAttributeStoringRep,

	# Mathematical properties of the elements
	MathInfo := IsCommutativeElement and IsAdditivelyCommutativeElement
);



mkposet := ArithmeticElementCreator(PosetElementSpec);

a := mkposet([1,2,3]);
b := mkposet([2,3,4]);
a*b;
a+b;


##########################################################################
##
##  Specification for multiplicative elements represented by sets
##  where multiplication is union.
##
##########################################################################

# The element specification
JoinSetElementSpec := 
rec(
	# name of the new elements
	ElementName := "JoinSet",

	# arithmetic operations
	Multiplication := function(a, b) return Union(a, b); end,

	# Mathematical properties of the elements
	MathInfo := IsCommutativeElement 
);



mkjset := ArithmeticElementCreator(JoinSetElementSpec);
a := mkjset([1,2,3]);
b := mkjset([2,3,4]);
s := Semigroup([a,b]);
Size(s);




##########################################################################
##
##  Specification for integers under addition
##
##########################################################################

# The element specification
AddIntSpec := 
rec(
	# name of the new elements
	ElementName := "AddInt",

	# arithmetic operations
	Multiplication := function(a, b) return a + b; end,

	# Mathematical properties of the elements
	MathInfo := IsCommutativeElement 
);



mkaddint := ArithmeticElementCreator(AddIntSpec);
a := mkaddint(1);
a*a;


s := Semigroup(a);
ens := Enumerator(s);
ens[2^20+1];



