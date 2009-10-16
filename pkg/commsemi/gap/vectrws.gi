###########################################################################T
##
#W  vectrws.gi           COMMSEMI library                    Isabel Araujo
##
#H  @(#)$Id: vectrws.gi,v 1.2 2000/06/01 15:43:59 gap Exp $
##
#Y  Copyright (C)  1997,  Lehrstuhl D fuer Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St.  Andrews, Scotland
##
##
##
Revision.vectrws_gi :=
    "@(#)$Id: vectrws.gi,v 1.2 2000/06/01 15:43:59 gap Exp $";

# This file contains methods for vector rewriting systems
# Vector rewriting systems are basically what underlies a
# commutative semigroup rws. This rises from the fact that 
# a word on a free commutative semigroup can be seen as
# vector, where the entries are the exponents of the generators
# in the word.

############################################################################
##
#R  IsVectorRewritingSystemRep(<obj>)
##
##  We represent our vector rws as a set of rules and an order
##  on the vectors. The field dimension tells us the length
##  of the vectors. 
##   
##  On the file orders.gi a few orders are already defined.
##
DeclareRepresentation("IsVectorRewritingSystemRep",
IsComponentObjectRep,["rules", "dimension", "lessthanorequal"]);

############################################################################
## 
#A  VectorRewritingSystem(<vlist>,<vlteq>)
## 
##  returns a vector rewriting system 
##  with respect to the vlteq ordering 
## 
InstallMethod(VectorRewritingSystem,
"for a list of vector rules and an order", true,
[IsList,IsFunction], 0,
function(vlist,vlteq)
  local i,            # loop variable
        n,            # the length of the vectors
        fam,          # the family
        vector_relations_with_correct_order,
        vrws;     # the commutative rws

  # changes the set of relations so that lhs is greater then rhs
  # and remove trivial relations of the type u=u
  vector_relations_with_correct_order:=function(r,vlteq)
    local i,q;

    q:=ShallowCopy(r);
    for i in [1..Length(q)] do
      if vlteq(q[i][1],q[i][2]) then
        q[i]:=[q[i][2],q[i][1]];
      fi;
      if q[i][1]=q[i][2] then
        Unbind(q[i]);
      fi;
    od;
    return Set(q);
  end;

  # create the new family
  fam := NewFamily("Family of Vector Rewriting systems",
  IsVectorRewritingSystem);

  if IsEmpty(vlist) then
    vrws := Objectify(NewType(fam,
      IsMutable and IsVectorRewritingSystem and IsVectorRewritingSystemRep),
      rec(rules:=[], dimension:=0, lessthanorequal:=vlteq));
  fi;

  # else we
  # have to check that vlist is indeed a list of rules,
  # ie it has to be a list of pairs and all the entries of
  # the pairs have to be have the same length
  if ForAny([1..Length(vlist)],i->Length(vlist[i])<>2) then
    Error(vlist," should be a list of pairs");
  else
    n := Length(vlist[1][1]);
    # so all entries have to have length n
    if ForAny([1..Length(vlist)],i->Length(vlist[i][1])<>n or
                                    Length(vlist[i][2])<>n) then
      Error("Wrong vector dimensions");
    fi;
  fi;

  # and we are now ready to create the vector rewriting system
  vrws := Objectify(NewType(fam,
    IsMutable and IsVectorRewritingSystem and IsVectorRewritingSystemRep),
    rec(rules:=vector_relations_with_correct_order(vlist,vlteq),
    dimension := n, lessthanorequal:=vlteq));

  return vrws;

end);

############################################################################  
##  
#A  VectorRewritingSystem(<vlist>)
##  
##  returns a vector rewriting system 
##  with respect to the TotalOrder on vectors 
##  
InstallOtherMethod(VectorRewritingSystem,
"for a list of vector rules", true,
[IsList], 0,
function(vlist) 
  return VectorRewritingSystem(vlist,IsVectorTotalOrderLessThanOrEqual);
end); 

############################################################################
##
#A  PrintObj(<rws>)
##
##
InstallMethod(ViewObj, "for a list of vector rules and an order", true,
[IsVectorRewritingSystem], 0,
function(rws)
  Print("Vector Rewriting System ");
  Print(" with rules \n");
  Print(Rules(rws));
end);

############################################################################
##
## Membership to Ap(N^n,a_1,...,a_r)
## returns true if x is in the set Ap(N^n,list) and false otherwise
##
## Now, x \in Ap(N^n,a_1,...,a_r) iff x \in \cap_{i=1}^r Ap(N^n,a_i)
## and x \in Ap(N^n,a_i) iff not(div(a_i,x))
## (ie, if x cannot be written as a+b for some b\in N^n)
## (see Rosales & Garcia, p.51)
##
BindGlobal("InAp",
function(list,x)
  local i,r;

  r := Length(list);
  for i in [1..r] do
    if IsVectorDivLessThanOrEqual(list[i],x) then return false; fi;
  od;
  return true;

end);

#############################################################################
##
#M  ReduceRules(<vrws>)
##  
##  for a vector rewriting system
##  
##
InstallMethod(ReduceRules,
"for Vector Semigroup Rewriting System",
true,
[IsVectorRewritingSystem and IsVectorRewritingSystemRep and IsMutable],0,
function(vrws)
  local rho,            # the rules of the rws
        lteq,           # the order
        i,j,            # loop variables
        c,              # swapping auxiliary variable
        rrho,           # the reduced set of relations we build from rho
        r,              # Length of rrho
        auxrho;         # auxiliar list to remove one entry of rrho

  rho := vrws!.rules;
  lteq := OrderOfRewritingSystem(vrws);

  # first we eliminate entries (a,a) in rho and entries (a,b) with lt(a,b)
  # we create a new list rrho of relations from the original one
  # in such a way that the above condition is fulfilled
  rrho := [];
  for i in [1..Length(rho)] do
    if not lteq(rho[i][1],rho[i][2]) then
      Add( rrho, rho[i] );
    elif not( lteq(rho[i][2],rho[i][1]) ) then
      Add( rrho, [rho[i][2],rho[i][1]] );
    fi;
  od;

  # now, for each pair (a_i,b_i) in rho we have to make sure
  # that a_i\in Ap(N^n,a_1,...,a_{i-1},a_{i+1},...,a_r) and
  # that b_i\in Ap(N^n,a_1,...,a_r)

  # so if we find a_j such that a_i\in Ap(N^n,a_j) we substitute
  # a_i by a_i-a_j-b_j;
  # if b_i\in Ap(N^n,a_j) we substitute b_i by b_i-a_j+b_j
  # We have to check if a_i<>b_i (if they are equal we remove (a_i,b_i)
  # from rrho) and also that lteq(b_i,a_i) (if not swap them)
  # If we modify entry i we have to start from the beggining again
  i :=1;
  r := Length(rrho);
  while i in [1..r] do

    j := 1;
    while j in [1..r] do

      if j<>i then
      if not InAp([rrho[j][1]],rrho[i][1]) then
        rrho[i][1] := rrho[i][1] - rrho[j][1] + rrho[j][2];
        # the following value for j will let us keep track that
        # an alteration has been done and will also
        # take us out of the loop for j
        j := -1;
      elif not InAp([rrho[j][1]],rrho[i][2]) then
        rrho[i][2] := rrho[i][2] - rrho[j][1] + rrho[j][2];
        # same comment for j as above
        j := -1;
      fi;
      # if j=-1 it means that we have modified entry i
      # make sure that ai<>b_i and lteq(b_i,a_i)
      if j=-1 then
        if rrho[i][1]=rrho[i][2] then
          auxrho := rrho{[i+1..Length(rrho)]};
          rrho := rrho{[1..i-1]};
          Append(rrho, auxrho);
          # rrho has one less entry so,
          r := r-1;
        elif lteq(rrho[i][1],rrho[i][2]) then
          c := rrho[i][1];
          rrho[i][1] := rrho[i][2];
          rrho[i][2] := c;
        fi;
        # we need to start looking again from the start so let i be 1
        i := 0;
      fi;

      # if not modifications occurr we will look at the next relation
      # if there where modifications this will make j=0 and so
      # will take us out of the loop and we will start again with i=1
      fi;
      j := j+1;

    od;
    i := i+1;
 
  od;

  vrws!.rules := rrho;

end); 

#############################################################################
##
#M  MakeConfluent (<vrws>)
##
##  for a vector rewriting system
##  changes the vector rws so that it becomes confluent
##  This implementation also guaranteed that the system will become
##  reduced. 
##  This is based on Knuth Bendix. 
##  See Rosales & Garcia, Alg 6.8 p.61
##
InstallMethod(MakeConfluent,
"for Vector Rewriting System",
true,
[IsVectorRewritingSystem and IsVectorRewritingSystemRep and IsMutable],0,
function(vrws)
  local rho,                      # the rules
        lteq,                     # the order relation
        n,                        # the length of the n-tuples
        i,j,                      # loop variables
        sij,sji;                  # as described in Rosales and Garcia

  # We start by reducing the vector rws 
  ReduceRules(vrws);
  rho := vrws!.rules;
  lteq := OrderOfRewritingSystem(vrws);

  n := vrws!.dimension;

  # check all pairs of rules to find where confluence fails
  i := 1;
  while i in [1..Length(rho)] do

    j:=1;
    while j in [1..Length(rho)] do
      if i<>j then
        # these sij and sji are described are as in Lemma 6.6 of
        # Rosales & Garcia, p. 60
        sij := List([1..n],k->Maximum(rho[i][1][k],rho[j][1][k]))-rho[i][1];
        sji := List([1..n],k->Maximum(rho[i][1][k],rho[j][1][k]))-rho[j][1];
        if ReducedForm(vrws,rho[i][2]+sij)<>ReducedForm(vrws,rho[j][2]+sji) then
          Add(rho,[ReducedForm(vrws,rho[i][2]+sij),
              ReducedForm(vrws,rho[j][2]+sji)]);
          i:=0;j:=-1;
          # now we want to be sure that our systems is still reduced
          ReduceRules(vrws);
          # and our set of rules has changed
          rho := vrws!.rules;
        fi;
      fi;
      j := j+1;
    od;
    i := i+1;
  od;

end);

#############################################################################
##
#M  ReducedForm(<vrws>,<w>)
##
##  for a vector rewriting system and a vector of compatible length
##
InstallMethod(ReducedForm,
"for Vector Rewriting System and a vector",
true,
[IsVectorRewritingSystem and IsVectorRewritingSystemRep,IsList],0,
function(vrws,x )
  local i,                  # loop variable
        rho;                # vector rules

  rho := Rules(vrws);
  i := 1;
  while i in [1..Length(rho)] do
    if not( InAp([rho[i][1]],x) ) then
      x := x - rho[i][1] + rho[i][2];
      i := 0;
    fi;
    i := i+1;
  od;
  return x;

end);
  
#############################################################################
##
#M  Rules(<vrws>)
##
##
InstallMethod(Rules,
"for a vector rewriting system", true,
[IsVectorRewritingSystem and IsVectorRewritingSystemRep], 0,
function(vrws)
  return vrws!.rules;
end);

#############################################################################
##
#A  OrderOfRewritingSystem(<vrws>)
##
##  The order of the rewriting system.
##
InstallMethod(OrderOfRewritingSystem,
"for a vector rewriting system", true,
[IsVectorRewritingSystem and IsVectorRewritingSystemRep], 0,
function(vrws)
  return vrws!.lessthanorequal;
end);

############################################################################
##
#F  VectorToAssocWord(f,v)
##
##  for a free semigroup <f> and a vector <v>
##  It returns the word in f which is a product 
##
InstallGlobalFunction(VectorToAssocWord,
function(f,v)
  local n,        # length of the vector
        x,        # generators of the semigroup f
        u,        # the word
        i,j,        # loop variable
        firstentry; # the first non-zero entry of v

  n := Length( v );
	if HasIsFreeSemigroup(f) and IsFreeSemigroup(f) then
		x := GeneratorsOfSemigroup(f);
	elif HasIsFreeMonoid(f) and IsFreeMonoid(f) then
		x := GeneratorsOfMonoid(f);
	fi;

  # Errors
  if n<>Length(x) then
    Error("The length of v should be equal to the rank of f");
  fi;
  if ForAll([1..n], i->v[i]=0) then
    if HasOne(f) then
      return One(f);
    else
      Error("The semigroup does not have an identity element");
    fi;
  fi;

  u := [];

  j := 1;
  while j in [1..n] do
    if v[j]<>0 then
      u := x[j]^v[j];
      firstentry := j;
      j := n;
    fi;
    j := j+1;
  od;
  for j in [firstentry+1..n] do
    if v[j] <> 0 then
      u := u * x[j]^v[j];
    fi;
  od;

  return u;
end);

############################################################################
##
#F  VectorRulesWithGivenOrderOnGenerators(rho,order)
##
BindGlobal("VectorRulesWithGivenOrderOnGenerators",
function( rho, order )
  local reorderedvector,      # function that reorders the entries of a vector
        copyofrho,
        i,k;                  # loop variables

  reorderedvector := function( v, order )
    local i,ov;

    ov := [];
    for i in [1..Length(v)] do
      ov[i] := v[ order[i] ];
    od;

    return ov;
  end;
 
  copyofrho := StructuralCopy(rho);
  for i in [1..Length(copyofrho)] do
    for k in [1..2] do
      copyofrho[i][k] := reorderedvector( copyofrho[i][k], order );
    od;
  od;

  return copyofrho;

end);


############################################################################
##
#F  CommutativeSemigroupRws(vrws,orderofgens)
##
##  For a vector rws and an order on the generators  
##  It returns the commuttaive semigroup rws changing the order
##  of the generators as given by orderofgens
##
InstallOtherMethod( CommutativeSemigroupRws,"",true,[IsList,IsList],0,
function(vrws,orderofgens)
  local rho,            # the set of rules of vrws
        f,              # the free semigroup
        respectorder,   # put the vectors of the rules in the given order
        u,              # a word rule
        h,              # the commutative fp semigroup
        wordrules,      # rules translated from vectors to words
        j,k;            # loop variables

  rho := Rules(vrws);
  f := FreeSemigroup(Length(rho[1][1]));
  respectorder := VectorRulesWithGivenOrderOnGenerators( rho, orderofgens );
  wordrules := [];
  for j in [1..Length(rho)] do
    u := [];
    for k in [1..2] do
      u[k] := VectorToAssocWord( f, respectorder[j][k] );
    od;
    Add( wordrules, u );
  od;

  h := Abelianization( f/wordrules );

  return CommutativeSemigroupRws( h );
end);

############################################################################
##
#F  CommutativeSemigroupRws(vrws)
##
##  For a vector rws (it uses the same order on generators) 
##
InstallOtherMethod( CommutativeSemigroupRws,
"for a vector rewriting system",true,
[IsVectorRewritingSystem], 0,
function(vrws) 
  local n;      # the number of generators of the correspondent semigroup

  n := vrws!.dimension; 
  return CommutativeSemigroupRws(vrws,[1..n]);
end);

#######################################################################
##
#E vectorrws.gi
##
## 
