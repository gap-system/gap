############################################################################
##
#W  semitran.gi           GAP library         Isabel Araujo and Robert Arthur 
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the implementation of some bascis for transformation 
##	semigroups 
##
Revision.semitran_gi :=
    "@(#)$Id$";

#############################################################################
##
#M  IsTransformationMonoid( <M> )
##
##  If an object has IsMonoid, then it necessarily contains the identity
##  transformation, and so is a submonoid of the full transformation
##  monoid.
##
InstallTrueMethod(IsTransformationMonoid, IsMonoid and 
	IsTransformationCollection);

#############################################################################
##
#M  IsTransformationMonoid( <S> )
##
##  A transformation semigroup is a transformation monoid iff at least
##  one of the generators is of rank n, where n is the degree of the
##  semigroup.
##
InstallMethod(IsTransformationMonoid, "for a transformation semigroup",
    true, [IsTransformationSemigroup and HasGeneratorsOfSemigroup], 0,
function( S )
    if Filtered(GeneratorsOfSemigroup(S), 
        x->RankOfTransformation(x) = DegreeOfTransformationSemigroup(S))
        <> [] then
        SetGeneratorsOfMonoid(S, GeneratorsOfSemigroup(S));
        return true;
    else
        return false;
    fi;
end);

#############################################################################
##
#M  AsMonoid( <S> )
##
##  Given a Transformation semigroup with known generators
##  for which IsTransformationMonoid
##  is true, return it as a monoid.
##
InstallMethod(AsMonoid, "for transformation semigroup", true,
    [IsTransformationSemigroup and HasGeneratorsOfSemigroup], 0,
function(S)
    if IsTransformationMonoid(S) then
        return Monoid(GeneratorsOfSemigroup(S));
    else
        return fail;
    fi;
end);

##############################################################################
##
#M  IsFinite( <M> )
##	
##	Transformation semigroups (considered in gap) are finite
##
InstallTrueMethod(IsFinite, IsTransformationSemigroup);



#############################################################################
##
#M  DegreeOfTransformationSemigroup( <S> )
##
##  Since we insist all elements must have the same degree, we may simply
##  give the degree of one generator.
##
InstallMethod(DegreeOfTransformationSemigroup, "degree of a trans semigroup", 
true, [IsTransformationSemigroup],0,
function(s)
    return DegreeOfTransformation(AsList(GeneratorsOfSemigroup(s))[1]);
end);

###############################################################################
##
#M	IsomorphismPermGroup( <H> )
##
##	for a greens H class of a semigroup 
##	returns an isomorphism from the H class to an isomorphic Perm group	
##
InstallOtherMethod( IsomorphismPermGroup,
		"for a Green's group H class of a semigroup",
		true,
		[ IsGreensHClass and IsEquivalenceClass ], 0,
function( h )

	local	enum,				# enumerator of h
				isgroup,		# is h a group 
				gens,				# the generators of the perm group
				permgroup,	# the perm group
				perm,				# a permutation
				i,j,				# loop variables
				mapfun;			# the function that computes the mapping 

	if not(IsFinite(h)) then
  	TryNextMethod();
	fi;

	# check if the H class is a group 
	# h is a group iff it contains an idempotent
	enum := Enumerator( h );
	i := 1;
	isgroup := false;
	while IsBound( enum[ i ] ) and not( isgroup ) do	
		if enum[ i ]*enum[ i ] = enum[ i ] then
			isgroup := true;
		fi;
		i := i+1;
	od;
	if not( isgroup ) then
		Error("Can only create Isomorphism of group H classes");	
	fi;

	# now we build the Perm group

	# For each element of h we build the permutation induced in h by itself
	# These permutations are going to be the generators of the perm group
	gens:=[];
	i := 1;
	while IsBound( enum[ i ] ) do
		perm := [];
		j := 1;
		while IsBound( enum[ j ] ) do
      Add( perm, Position( enum, enum[i] * enum[ j ] ) );
	    j := j+1;
    od;
		Add( gens, PermList(perm) ); 	
    i := i+1;
	od;
	# notice that gens now is a list of permutations, entry i of which
	# is the permutation induced in H by the element enum[i]

	# now we build the group
	permgroup := Group( gens );

	mapfun := a -> gens[ Position( enum, a )];

	return MappingByFunction( h, permgroup, mapfun );	

end);


###############################################################################
##
#M	IsomorphismTransformationSemigroup( <S> )
##
##	For a generic semigroup <S>  with
##  MultiplicativeNeutralElement.
##	Returns an isomorphism from <S> to a transformation semigroup
##  It is the right regular representation of $S$. 
##
##  This function could be much more space efficient if we knew how
##  to factor elements of a semigroup into words in the generators!
##
InstallMethod( IsomorphismTransformationSemigroup,
		"for a generic semigroup with multiplicative neutral element",
		true,
		[ IsSemigroup and HasMultiplicativeNeutralElement], 0,
function( s )
	local
		en,			#enumerator of the semigroup - this becomes part of the isomorphism
		points, # on which the semigroup is acting
		gens,		# the generators of the transformation semigroup
		mapfun, # the function which describes the mapping
		g, 			# generator, loop variable
		transg; # g as a transformation
		
	en := EnumeratorSorted(s);
	
	if not(IsFinite(s)) then
  	TryNextMethod();
	fi;

	points := [1 .. Length(en)];

	gens := []; # the generators of the transformation semigroup
	for g in GeneratorsOfSemigroup(s) do
		transg := Transformation( List(points, i->Position(en, en[i]*g)));
		Append(gens, [transg]);
	od;
	

	mapfun := a -> Transformation( List(points, i->Position(en, en[i]*a)));

	return MagmaHomomorphismByFunctionNC( s, Semigroup(gens), mapfun );	

end);

##
##  As above, but add an extra point for faithfulness
##
InstallMethod( IsomorphismTransformationSemigroup,
		"for a generic semigroup",
		true,
		[ IsSemigroup], 0,
function( s )
	local
		en,			#enumerator of the semigroup - this becomes part of the isomorphism
		points, # on which the semigroup is acting
		gens,		# the generators of the transformation semigroup
		mapfun, # the function which describes the mapping
		g, 			# generator, loop variable
		transg; # g as a transformation
		
	en := EnumeratorSorted(s);
	
	if not(IsFinite(s)) then
  	TryNextMethod();
	fi;

	points := [1 .. Length(en)];

	gens := []; # the generators of the transformation semigroup
	for g in GeneratorsOfSemigroup(s) do
		transg := Transformation( 
			Concatenation(List(points, i->Position(en, en[i]*g)),[Position(en,g)]));
		Append(gens, [transg]);
	od;
	

	mapfun := a -> Transformation( 
		Concatenation(List(points, i->Position(en, en[i]*a)),[Position(en,a)]));

	return MagmaHomomorphismByFunctionNC( s, Semigroup(gens), mapfun );	

end);


##
##  For semigroups of SingleValued GeneralMappings with a generating set.
##  For the moment we resist the temptation to install it for a semigroup
##  of general mappings without a generating set - this would be a 
##  highly suspicious object.
##
InstallMethod( IsomorphismTransformationSemigroup,
		"for a semigroup of general mappings",
		true,
		[ IsSemigroup and IsGeneralMappingCollection and HasGeneratorsOfSemigroup], 
		0,
function( s )
	local
		gens,		# the generators of the transformation semigroup
		egens,		# the generators of the endomorphism semigroup
		mapfun; # the function which describes the mapping
		
	egens := GeneratorsOfSemigroup(s);
	if not ForAll(egens, g->IsMapping(g)) then
		TryNextMethod();
	fi;
	gens := List(egens, g->TransformationRepresentation(g)!.transformation);
	
	mapfun := a -> TransformationRepresentation(a)!.transformation; 

	return MagmaHomomorphismByFunctionNC( s, Semigroup(gens), mapfun );	

end);


