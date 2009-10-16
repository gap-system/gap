#############################################################################
##
#W  semiquo.gi           GAP library          Andrew Solomon and Isabel Araujo
##
#H  @(#)$Id: semiquo.gi,v 4.13 2002/04/15 10:05:22 sal Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the implementation for quotient semigroups.
##
Revision.semiquo_gi :=
    "@(#)$Id: semiquo.gi,v 4.13 2002/04/15 10:05:22 sal Exp $";



#############################################################################
##
#F  HomomorphismQuotientSemigroup(<cong>) 
##
##
InstallGlobalFunction(HomomorphismQuotientSemigroup, 
function(cong)

	local
			S, 			# the preimage
			Q, 			# the quotient semigroup
			Qrep,		# a representative element of Q
			Qgens,	# the generators of Q
			filters, # the filters of the object's type
			efam; 	# elements family of Q
			

	# Check that cong is a congruence on S
	if not IsSemigroupCongruence(cong) then
		Error("usage: HomomorphismQuotientSemigroup(<cong>)");
	fi;

	S := Source(cong);
		
	Qrep := EquivalenceClassOfElementNC(cong, Representative(S));

	# Create a new family.
	efam := FamilyObj(Qrep);

	# Create the semigroup.
	filters := IsSemigroup and IsQuotientSemigroup and IsAttributeStoringRep;
	if IsMonoid(S) then
		filters := filters and IsMagmaWithOne;
	fi;
	Q := Objectify( NewType( CollectionsFamily( efam ), filters), rec() );

	SetRepresentative(Q, Qrep);
	SetQuotientSemigroupPreimage(Q, S);
	SetQuotientSemigroupCongruence(Q, cong);
	SetQuotientSemigroupHomomorphism(Q, 
		MagmaHomomorphismByFunctionNC(S, Q, x->EquivalenceClassOfElementNC(cong,x)));

	efam!.quotient := Q;

	if IsMonoid(Q) and HasOne(S) then
		SetOne(Q, One(S)^QuotientSemigroupHomomorphism(Q));
	fi;

	# Create generators of the semigroup.
	if HasGeneratorsOfSemigroup(S) then
		Qgens:= List( GeneratorsOfSemigroup( S ),
      s -> s^QuotientSemigroupHomomorphism(Q));
    SetGeneratorsOfSemigroup( Q, Qgens );
	fi;

	return QuotientSemigroupHomomorphism(Q);
end);


#############################################################################
##
#M  HomomorphismFactorSemigroup(<s>, <cong> )
##
##  for a generic semigroup and congruence
##
InstallMethod(HomomorphismFactorSemigroup,
    "for a semigroup and a congruence",
    true,
    [ IsSemigroup, IsSemigroupCongruence ],
    0,
function(s, c)

  if not s = Source(c) then
    TryNextMethod();
  fi;
	return HomomorphismQuotientSemigroup(c);
end);

#############################################################################
##
#M  ViewObj( S )  
##  
##  View a quotient semigroup S
##
InstallMethod( ViewObj,
    "for a quotient semigroup with generators",
    true,
    [ IsQuotientSemigroup], 0,
    function( S )
    Print( "<quotient of ",QuotientSemigroupPreimage(S)," by ",
			QuotientSemigroupCongruence(S),">");
    end );


#############################################################################
##
#E
