#############################################################################
##
#W  fpsemi.gi           GAP library          Andrew Solomon and Isabel Araujo
##
#H  @(#)$Id$
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##  This file contains the declarations for finitely presented semigroups.
##
Revision.fpsemi_gi :=
    "@(#)$Id$";

#############################################################################
##
#M  ElementOfFpSemigroup( <fam>, <elm> )
##
InstallMethod( ElementOfFpSemigroup,
    "for a family of f.p. semigroup elements, and an assoc. word",
    true,
    [ IsElementOfFpSemigroupFamily, IsAssocWord ],
    0,
    function( fam, elm )
    return Objectify( fam!.defaultType, [ Immutable( elm ) ] );
    end );

#############################################################################
##
#M  UnderlyingElement( <elm> )  . . . . . . for element of f.p. semigroup
##
InstallMethod( UnderlyingElement,
    "for an element of an f.p. semigroup (default repres.)",
    true,
    [ IsElementOfFpSemigroup and IsPackedElementDefaultRep ],
    0,
    obj -> obj![1] );


#############################################################################
##
#M  \*( <x1>, <x2> )
##
InstallMethod( \*,
    "for two elements of a f.p. semigroup",
    IsIdenticalObj,
    [ IsElementOfFpSemigroup, IsElementOfFpSemigroup ],
    0,
    function( x1, x2 )
    return ElementOfFpSemigroup(FamilyObj(x1), 
			UnderlyingElement(x1)*UnderlyingElement(x2));
    end );

#############################################################################
##
#M  \<( <x1>, <x2> )
## 
##
InstallMethod( \<,
    "for two elements of a f.p. semigroup",
    IsIdenticalObj,
    [ IsElementOfFpSemigroup, IsElementOfFpSemigroup ],
    0,
    function( x1, x2 )
			local S, RWS;

      S := CollectionsFamily(FamilyObj(x1))!.wholeSemigroup;
      RWS := ReducedConfluentRewritingSystem(S);
      return ReducedForm(RWS, UnderlyingElement(x1)) <
          ReducedForm(RWS, UnderlyingElement(x2));

    end );

#############################################################################
##
#M  \=( <x1>, <x2> )
## 
##
InstallMethod( \=,
    "for two elements of a f.p. semigroup",
    IsIdenticalObj,
    [ IsElementOfFpSemigroup, IsElementOfFpSemigroup ],
    0,
    function( x1, x2 )
			local S, RWS; 

			# This line could be improved - find out how it's done
			# for groups
			S := CollectionsFamily(FamilyObj(x1))!.wholeSemigroup;
			RWS := ReducedConfluentRewritingSystem(S);
			return ReducedForm(RWS, UnderlyingElement(x1)) = 
					ReducedForm(RWS, UnderlyingElement(x2));
    end );

#############################################################################
##
#M  PrintObj( <elm> )
##
InstallMethod( PrintObj,
    "for an f.p. semigroup element",
    true,
    [ IsElementOfFpSemigroup],
    0,
    function( elm )
      PrintObj(elm![1]);
    end );

#############################################################################
##
#M  FactorFreeSemigroupByRelations(<F>,<rels>) .. Create an FpSemigroup
#M  FactorFreeMonoidByRelations(<F>,<rels>) .. Create an FpMonoid
##
##  Note: If the semigroup has fewer relations than generators, 
##  then the semigroup is certainly infinite.
##
InstallGlobalFunction( FactorFreeSemigroupByRelations, 
function( F, rels )

    local S, fam, gens, r;

		# Check that the relations are all lists of length 2
		for r in rels do
			if Length(r) <> 2 then
				Error("A relation should be a list of length 2");
			fi;
		od;

    # Create a new family.
    fam := NewFamily( "FamilyElementsFpSemigroup", IsElementOfFpSemigroup );

    # Create the default type for the elements - 
		# putting IsElementOfFpSemigroup ensures that lists of these things
		# have CategoryCollections(IsElementOfFpSemigroup).

    fam!.freeSemigroup := F;
    fam!.relations := Immutable( rels );

    fam!.defaultType := NewType( fam, IsElementOfFpSemigroup 
			and IsPackedElementDefaultRep );

    # Create the semigroup.
    S := Objectify(
        NewType( CollectionsFamily( fam ),
        IsSemigroup and IsFpSemigroup and IsAttributeStoringRep),
        rec() );

    # Mark <S> to be the 'whole semigroup' of its later subsemigroups.
    FamilyObj( S )!.wholeSemigroup := S;

    # Create generators of the semigroup.
    gens:= List( GeneratorsOfSemigroup( F ),
      s -> ElementOfFpSemigroup( fam, s ) );
    SetGeneratorsOfSemigroup( S, gens );

		if Length(gens) > Length(rels) then
			SetIsFinite(S, false);
		fi;

    return S;
end);

InstallGlobalFunction(FactorFreeMonoidByRelations,
function( fm, rels )

	local
			fs, 				# free semigroup preimage of the free monoid
			fp,					# the fp semigroup resulting
			idgen, 			# free semigroup generator corresponding to id of monoid
			g, 					# a generator
			i, 					# an integer
			semirel,		# A monoid relation converted into a semigroup relation
			rel,				# a monoid relation 
			newrels,		# the relations for a free monoid as a semigroup
			semigroup_gens,	# generators of the free semigroup
			monword2semiword;	# word in the free monoid is mapped to its preimage

	################################################
	# monword2semiword
	# Change a word in the free monoid into a word
	# in the free semigroup. Just increment the generators
	# by one to shift past the identity generator
	################################################
	monword2semiword := function(idgen, w)
		local
				wlist, 		# external rep of the word
				i;				# loop variable

		wlist := ShallowCopy(ExtRepOfObj(w));

		if Length(wlist) = 0 then # it is the identity
			return idgen; 
		fi;

		for i in [1 .. Length(wlist)/2] do
			wlist[2*i-1] := wlist[2*i-1] + 1;
		od;
		return ObjByExtRep(FamilyObj(idgen), wlist);
	end;
	

	###############################################
	#
	#  function proper
	#

	# Check that the relations are all lists of length 2
	for rel in rels do
		if Length(rel) <> 2 then
			Error("A relation should be a list of length 2");
		fi;
	od;

	# First create the free semigroup fs
	# This involves making a new set of generators ...

	# the identity is always the first

	fs := FreeSemigroup(List( Set(GeneratorsOfSemigroup(fm)), x->String(x)));
	# the call to Set ensures that the identity comes first.

	semigroup_gens := GeneratorsOfSemigroup(fs);
	idgen := semigroup_gens[1];


	# ... and relations from the old one.
	newrels := [[idgen*idgen,idgen]];
	for i in [2 .. Length(semigroup_gens)] do
		g := semigroup_gens[i];
		Add(newrels, [idgen*g, g]);
		Add(newrels, [g*idgen, g]);
	od;

	# Now convert the relations over the monoid generators 
	# into relations over the semigroup generators
	# and add them to the newrels
	for rel in rels do
			semirel := [monword2semiword(idgen, rel[1]),
				monword2semiword(idgen, rel[2])];
			Add(newrels, semirel);
	od;

	# finally create the fp semigroup
	fp:=FactorFreeSemigroupByRelations(fs,newrels);

	# the first generator of fp is a multiplicative neutral element for fp
	SetMultiplicativeNeutralElement(fp,GeneratorsOfSemigroup(fp)[1]);

	return fp;

end);


#############################################################################
##
#M  HomomorphismFactorSemigroup(<F>, <C> ) 
##
##  for free semigroup and congruence 
##
InstallMethod(HomomorphismFactorSemigroup, 
    "for a free semigroup and a congruence",
    true,
    [ IsFreeSemigroup, IsSemigroupCongruence ],
    0,
function(s, c)
	local
		fp;			# the semigroup under construction

	if not s = Source(c) then
		TryNextMethod();
	fi;
	fp := FactorFreeSemigroupByRelations(s, GeneratingPairsOfMagmaCongruence(c));
	return MagmaHomomorphismByFunctionNC(s, fp, 
		x->ElementOfFpSemigroup(ElementsFamily(FamilyObj(fp)),x) );
	
end);

#############################################################################
##
#M  HomomorphismFactorSemigroup(<F>, <C> ) 
##
##  for free monoid and congruence 
##
InstallMethod(HomomorphismFactorSemigroup, 
    "for a free semigroup and a congruence",
    true,
    [ IsFreeMonoid, IsSemigroupCongruence ],
    0,
function(s, c)
	local
		fp;			# the semigroup under construction

	if not s = Source(c) then
		TryNextMethod();
	fi;
	fp := FactorFreeMonoidByRelations(s, GeneratingPairsOfMagmaCongruence(c));
	return MagmaHomomorphismByFunctionNC(s, fp, 
		x->ElementOfFpSemigroup(ElementsFamily(FamilyObj(fp)),x) );
end);

#############################################################################
##
#M  HomomorphismFactorSemigroup(<F>, <C> ) 
##
##  for fp semigroup and congruence 
##
InstallMethod(HomomorphismFactorSemigroup, 
    "for an fp semigroup and a congruence",
    true,
    [ IsFpSemigroup, IsSemigroupCongruence ],
    0,
function(s, c)
	local
		srels,	# the relations of c
		frels, 	# srels converted into pairs of words in the free semigroup
		fp;			# the semigroup under construction

	if not s = Source(c) then
		TryNextMethod();
	fi;

	# make the relations, relations of the free semigroup
	srels := GeneratingPairsOfMagmaCongruence(c);
	frels := List(srels, x->[UnderlyingElement(x[1]),UnderlyingElement(x[2])]);

	fp := FactorFreeSemigroupByRelations(FreeSemigroupOfFpSemigroup(s), 
		Concatenation(frels, RelationsOfFpSemigroup(s)));
	return MagmaHomomorphismByFunctionNC(s, fp, 
		x->ElementOfFpSemigroup(ElementsFamily(FamilyObj(fp)),UnderlyingElement(x)) );
	
end);

#############################################################################
##
#M  FreeSemigroupOfFpSemigroup( S ) 
##
##  Underlying free semigroup of an fp semigroup
##
InstallMethod( FreeSemigroupOfFpSemigroup,
    "for a finitely presented semigroup",
    true,
    [ IsSubsemigroupFpSemigroup and IsWholeFamily ], 0,
    T -> ElementsFamily( FamilyObj( T ) )!.freeSemigroup );

#############################################################################
##
#M  Size( <G> ) . . . . . . . . . . . . . . . . . . .  for a free semigroup
##
InstallMethod( Size,
    "for a free semigroup",
    true,
    [ IsFreeSemigroup ], 0,
    function( G )
    if IsTrivial( G ) then
      return 1;
    else
      return infinity;
    fi;
    end );



#############################################################################
##
#M  FreeGeneratorsOfFpSemigroup( S )  
##  
##  Generators of the underlying free semigroup
##
InstallMethod( FreeGeneratorsOfFpSemigroup,
    "for a finitely presented semigroup",
    true,
    [ IsSubsemigroupFpSemigroup and IsWholeFamily ], 0,
    T  -> GeneratorsOfSemigroup( FreeSemigroupOfFpSemigroup( T ) ) );


#############################################################################
##
#M  ViewObj( S )  
##  
##  View a semigroup S
##
InstallMethod( ViewObj,
    "for a free semigroup with generators",
    true,
    [ IsSemigroup and IsFreeSemigroup and HasGeneratorsOfMagma ], 0,
    function( S )
    Print( "<free semigroup on the generators ",GeneratorsOfSemigroup(S),">");
    end );


InstallMethod( ViewObj,
    "for a fp semigroup with generators",
    true,
    [  IsSubsemigroupFpSemigroup and IsWholeFamily and IsSemigroup
    and HasGeneratorsOfMagma ], 0,
    function( S )
    Print( "<fp semigroup on the generators ",
          FreeGeneratorsOfFpSemigroup(S),">");
    end );


#############################################################################
##
#M  RelationsOfFpSemigroup( F )
##
InstallOtherMethod( RelationsOfFpSemigroup,
    "method for a free semigroup",
    true,
    [ IsFreeSemigroup ], 0,
    F -> [] );

InstallMethod( RelationsOfFpSemigroup,
    "for finitely presented semigroup",
    true,
    [ IsSubsemigroupFpSemigroup and IsWholeFamily ], 0,
    S -> ElementsFamily( FamilyObj( S ) )!.relations );

############################################################################
##
#O  NaturalHomomorphismByGenerators( <f>, <s> )
##
##  returns a mapping from the free semigroup <f> with <n> generators to the
##  semigroup <s> with <n> generators, which maps the ith generator to the 
##  ith generator.
##
BindGlobal("FreeSemigroupNatHomByGeneratorsNC",
function(f, s)
 return MagmaHomomorphismByFunctionNC(f, s,
    function(w)
      local
        i, 			# loop var
        prodt,	# product in the target semigroup
        gens,		# generators of the target semigroup
        v;			# ext rep as <gen>, <exp> pairs

			if Length(w) = 0 then
				return One(Representative(s));
			fi;

      gens := GeneratorsOfSemigroup(s);
      v := ExtRepOfObj(w);
      prodt := gens[v[1]]^v[2]; 
      for i in [2 .. Length(v)/2] do
        prodt := prodt*gens[v[2*i-1]]^v[2*i];
      od;
      return prodt;

    end);
end);

InstallMethod( NaturalHomomorphismByGenerators,
    "for a free semigroup and semigroup",
    true,
    [  IsFreeSemigroup, IsSemigroup and HasGeneratorsOfMagma], 0,
function(f, s)

	if Size(GeneratorsOfMagma(f)) <> Size(GeneratorsOfMagma(s)) then
		Error("Semigroups must have the same rank.");
	fi;

	return FreeSemigroupNatHomByGeneratorsNC(f, s);

end);


InstallMethod( NaturalHomomorphismByGenerators,
    "for an fp semigroup and semigroup",
    true,
    [  IsFpSemigroup, IsSemigroup and HasGeneratorsOfSemigroup], 0,
function(f, s)
	local 
			psi; # the homom from the free semi

	if Size(GeneratorsOfSemigroup(f)) <> Size(GeneratorsOfSemigroup(s)) then
		Error("Semigroups must have the same rank.");
	fi;

	psi := FreeSemigroupNatHomByGeneratorsNC(FreeSemigroupOfFpSemigroup(f), s);

	# check that the relations hold
	if Length(
			Filtered(RelationsOfFpSemigroup(f), x->x[1]^psi <> x[2]^psi))>0 then
		return fail;
	fi;

	# now create the homomorphism from the fp semi	
	return MagmaHomomorphismByFunctionNC(f, s, e->UnderlyingElement(e)^psi);
end);



#############################################################################
##
#E

