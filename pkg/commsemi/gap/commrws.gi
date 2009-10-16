#############################################################################
##
#W  commrws.gi           COMMSEMI library                      Isabel Araujo
##
#H  @@(#)$Id: commrws.gi,v 1.2 2000/06/01 15:43:59 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##
##
Revision.commrws_gi :=
    "@@(#)$Id: commrws.gi,v 1.2 2000/06/01 15:43:59 gap Exp $";

# The operation Elements for a commutative semigroup uses
# semigroup rws instead of commutative smg rws.
# Check why this is... (it comes from a kernel call...)
# Perhaps the commutative rws should be the one it is
# returned when ReducedConflRws is called for a commut smg?!

############################################################################
##
#R  IsCommutativeSemigroupRwsRep(<obj>)
##
##  reduced - is the system known to be reduced
##  lessthanorequal(a, b) - is <a> less than or equal<b> in the word order
##
DeclareRepresentation("IsCommutativeSemigroupRwsRep",
IsComponentObjectRep,["semigroup", "vectorrws"]); 

############################################################################
## 
#A  CommutativeSemigroupRws(<S>,<vlteq>)
## 
##  returns a commutative rewriting system of the fp semigroup
##  <S> with respect to the shortlex ordering (ie TotalOrder on vectors)
##
InstallMethod(CommutativeSemigroupRws,
"for an fp commutative semigroup or monoid  and an order", true,
[IsSemigroup and IsCommutative,IsFunction], 0,
function(s,vlteq)
  local rel,          # the relations of the fp comm semigroup
        vrel,         # the relations as relations between vectors
        u,            # a word relation
        fam,          # the family
        vrws,         # the correspondent vector rws
				prop,
        commrws;      # the commutative rws

  if IsFpSemigroup(s) then 
		rel := RelationsOfFpSemigroup(s);
		prop := IsBuiltFromSemigroup;
	elif IsFpMonoid(s) then
		rel := RelationsOfFpMonoid(s);
		prop := IsBuiltFromMonoid;
	else
		#this only works for fp semigroups or monoids
		TryNextMethod();
  fi;
	
  # we start by writing the relations of S as relations between vectors
  vrel := [];
  for u in rel do
    Add(vrel, [AssocWordToVector(u[1]),AssocWordToVector(u[2])]);
  od;
  vrws := VectorRewritingSystem(vrel,vlteq);

  fam := NewFamily("Family of Commutative Semigroup Rewriting systems",
  IsCommutativeSemigroupRws);

  commrws := Objectify(NewType(fam,
    IsMutable and IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep),
   rec(semigroup:= s,
    vectorrws:=vrws));

	Setter(prop)(commrws,true);

  return commrws;

end);


###########################################################################  
##  
#A  CommutativeSemigroupRws(<S>)
##  
##  returns a commutative rewriting system of the fp semigroup  
##  <S> with respect to the shortlex ordering (ie TotalOrder on vectors) 
##  
InstallOtherMethod(CommutativeSemigroupRws,
"for an fp commutative semigroup", true,
[IsSemigroup and IsCommutative], 0,
function(S) 
  return CommutativeSemigroupRws(S,IsVectorTotalOrderLessThanOrEqual);
end); 

###########################################################################
## 
#A  CommutativeReducedConfluentSemigroupRws(<S>)
## 
##  returns a reduced confluent commutative rewriting system of the fp semigroup
##  <S> with respect to the shortlex ordering (ie TotalOrder on vectors)
## 
InstallMethod(CommutativeReducedConfluentSemigroupRws,
"for a finitely presented commutative semigroup", true,
[IsSemigroup and IsCommutative], 0,
function(s)
  local comrws, rws, fam;
    
  # this only works for fp monoids or fp semigroups
  if not (IsFpSemigroup(s) or IsFpMonoid(s)) then
    TryNextMethod();
  fi;

  comrws := CommutativeSemigroupRws(s);
  fam := FamilyObj(comrws);
  MakeConfluent(comrws);
  rws:= Objectify(NewType(fam,IsAttributeStoringRep and
          IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep), 
          rec(semigroup:=s, vectorrws :=VectorRewritingSystem(comrws) ));

	if IsFpMonoid(s) then
		SetIsBuiltFromMonoid(rws,true);
	elif IsFpSemigroup(s) then
		SetIsBuiltFromSemigroup(rws,true);
	fi;

  return rws;
end); 


###########################################################################
##
#A  PrintObj(<rws>)
##
##
InstallMethod(ViewObj, "for a commutative semigroup rewriting system", true,
[IsCommutativeSemigroupRws and IsBuiltFromSemigroup], 0,
function(rws)
  Print("Commutative Semigroup Rewriting System for ");
  Print(SemigroupOfRewritingSystem(rws));
  Print(" with rules \n");
  Print(Rules(rws));
end);

InstallMethod(ViewObj, "for a commutative semigroup rewriting system", true,
[IsCommutativeSemigroupRws and IsBuiltFromMonoid], 0,
function(rws)
  Print("Commutative Semigroup Rewriting System for ");
  Print(MonoidOfRewritingSystem(rws));
  Print(" with rules \n");
  Print(Rules(rws));
end);


############################################################################
##
#M  ReduceRules(<RWS>)
##
InstallMethod(ReduceRules,
"for Commutative Semigroup Rewriting System",
true,
[IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep and IsMutable],0,
function(commrws)
  ReduceRules(commrws!.vectorrws);
end);

############################################################################
##
#M  MakeConfluent (<RWS>)
##
InstallMethod(MakeConfluent,
"for Commutative Semigroup Rewriting System",
true,
[IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep and IsMutable],0,
function(commrws)
  MakeConfluent(commrws!.vectorrws);
end);

############################################################################
##
#M  ReducedForm(<COMM RWS>,w)
##
InstallMethod(ReducedForm,
"for Commutative Semigroup Rewriting System and an word in the underlying free semigroup",
true,
[IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep and IsBuiltFromSemigroup ,IsAssocWord],0,
function(commrws,w )
  local vrules,rho, lteq, vw, vwreduced,s;

  s := SemigroupOfRewritingSystem(commrws);
  vw := AssocWordToVector( w );
  vwreduced := ReducedForm(VectorRewritingSystem(commrws),vw);
  
  return UnderlyingElement(VectorToElementOfCommutativeFpSemigroup(
                           s,vwreduced));

end);

InstallMethod(ReducedForm,
"for Commutative Semigroup Rewriting System and an word in the underlying free monoid",
true,
[IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep and IsBuiltFromMonoid,IsAssocWord],0,
function(commrws,w )
  local vrules,rho, lteq, vw, vwreduced,s;

  s := MonoidOfRewritingSystem(commrws);
  vw := AssocWordToVector( w );
  vwreduced := ReducedForm(VectorRewritingSystem(commrws),vw);

  return UnderlyingElement(VectorToElementOfCommutativeFpMonoid(
                           s,vwreduced));

end);


############################################################################
##
#A  VectorRewritingSystem(<commrws>)
##
##  returns a vector rewriting system
##  of the commutative semigroup rws 
##
InstallOtherMethod(VectorRewritingSystem,
"for a commutative semigroup rewriting system", true,
[IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep], 0,
function(commrws)
  return commrws!.vectorrws;
end);

############################################################################
##
#M  SemigroupOfRewritingSystem(<COMM RWS>)
##
##  for a Commutative Semigroup Rewriting System
##  returns the semigroup of the rewriting system
##
InstallMethod(SemigroupOfRewritingSystem,
"for a commutative semigroup rewriting system", true,
[IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep and IsBuiltFromSemigroup], 0,
function(commrws)
  return commrws!.("semigroup");
end);

############################################################################
##
#M  MonoidOfRewritingSystem(<COMM RWS>)
##
##  for a Commutative Semigroup Rewriting System
##  returns the semigroup of the rewriting system
##
InstallMethod(MonoidOfRewritingSystem,
"for a commutative semigroup rewriting system", true,
[IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep and IsBuiltFromMonoid], 0,
function(commrws)
  return commrws!.("semigroup");
end);


############################################################################
##
#M  Rules(<COMM RWS>)
##
##  for a Commutative Semigroup Rewriting System
##  returns the set of rules of the rewriting system
##  (as a commutative rws, ie, the rules of the form yx->yx are not
##  written, but the rules are in the free semigroup !???!??!?!?!??!)
##
InstallMethod(Rules,
"for a commutative semigroup rewriting system", true,
[IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep and IsBuiltFromSemigroup], 0,
function(commrws)
  local vrules,       # the vector rules of the rws
        vu,           # a vector rules
        wu,           # a word rule
        wrules,       # the corresponding word rules  
        k,            # loop variable
        s;            # the semigroup of the rws
		
  s := SemigroupOfRewritingSystem(commrws);
  vrules := Rules(VectorRewritingSystem(commrws));
  wrules := [];
  for vu in vrules do
    wu := [];
    for k in [1..2] do
      wu[k] := UnderlyingElement( 
              VectorToElementOfCommutativeFpSemigroup(s,vu[k]));
    od;
    Add(wrules,wu);
  od; 

  return wrules; 
end);

InstallMethod(Rules,
"for a commutative semigroup rewriting system", true,
[IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep and IsBuiltFromMonoid], 0,
function(commrws)
  local vrules,       # the vector rules of the rws
        vu,           # a vector rules
        wu,           # a word rule
        wrules,       # the corresponding word rules
        k,            # loop variable
        s;            # the monoid of the rws
    
  s := MonoidOfRewritingSystem(commrws);
  vrules := Rules(VectorRewritingSystem(commrws));
  wrules := [];
  for vu in vrules do
    wu := [];
    for k in [1..2] do
      wu[k] := UnderlyingElement(
              VectorToElementOfCommutativeFpMonoid(s,vu[k]));
    od;
    Add(wrules,wu);
  od;

  return wrules;
end);

############################################################################
##
#M  VectorRulesOfCommutativeSemigroupRws(<COMM RWS>)
##
##  for a Commutative Semigroup Rewriting System
##  returns the set of vector rules of the rewriting system
##
InstallMethod(VectorRulesOfCommutativeSemigroupRws,
"for a commutative semigroup rewriting system", true,
[IsCommutativeSemigroupRws and IsCommutativeSemigroupRwsRep], 0,
function(commrws)
  return Rules(VectorRewritingSystem(commrws));;
end);

############################################################################
##
#A  ReducedConfluentCommutativeSemigroupRws( <S>)
##
##  returns a reduced confluent rewriting system of the commutative fp semigroup
##  <S> with respect to the TotalOrder on vectors (=shortlex on words).
##
InstallMethod(ReducedConfluentCommutativeSemigroupRws,
"for an fp commutative semigroup", true,
[IsSemigroup and IsCommutative], 0,
function(S)
		# only works for fp semigrousp or monoids
		if not (IsFpSemigroup(S) or IsFpMonoid(S)) then
			TryNextMethod();
		fi;
    return ReducedConfluentCommutativeSemigroupRws(S,
                IsVectorTotalOrderLessThanOrEqual);
end);

############################################################################
##
#A  ReducedConfluentCommutativeSemigroupRws( <S>,<vlteq>)
##
##  returns a reduced confluent rewriting system of the commutative fp semigroup
##  <S> with respect to the TotalOrder on vectors (=shortlex on words).
##
InstallOtherMethod(ReducedConfluentCommutativeSemigroupRws,
"for an fp commutative semigroup and an ordering on vectors", true,
[IsSemigroup and IsCommutative,IsFunction], 0,
function(S,vlteq)
  local commrws,
        fam;

	# only works for fp semigrousp or monoids
	if not (IsFpSemigroup(S) or IsFpMonoid(S)) then
		TryNextMethod();
	fi;

  # build the rws and make it confluent
  commrws := CommutativeSemigroupRws(S,vlteq);
  MakeConfluent(commrws);
  
  # make it immutable
  fam := NewFamily("Family of reduced confluent commutative rws",
      IsReducedConfluentCommutativeSemigroupRws);

  return commrws;
end);
