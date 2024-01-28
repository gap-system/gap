#############################################################################
##
##  This file is part of GAP, a system for computational discrete algebra.
##  This file's authors include Isabel Araújo.
##
##  Copyright of GAP belongs to its developers, whose names are too numerous
##  to list here. Please refer to the COPYRIGHT file for details.
##
##  SPDX-License-Identifier: GPL-2.0-or-later
##
##


#############################################################################
##
#M  OrderingsFamily(<F>)
##
InstallMethod( OrderingsFamily,
  "for a family", true, [IsFamily], 0,
  function( fam)
    local ord_req, ord_imp;

    ord_req := IsOrdering;
    ord_imp := IsObject;
    return NewFamily( "OrderingsFamily(...)",ord_req,ord_imp);

end);


######################################################################
##
#M  ViewObj( <ord> )
##
InstallMethod( ViewObj,
  "for an ordering", true,
  [IsOrdering], 0,
  function(ord)
    Print("Ordering");
  end);


######################################################################
##
##  Creating orderings
##

######################################################################
##
#F  CreateOrderingByLtFunction( <fam>, <fun>, <list> )
##
##  creates an orderings for the elements of the family fam
##  with LessThan given by <fun>
##  and with the properties list in <list>
##
BindGlobal("CreateOrderingByLtFunction",
function( fam, fun, list)
    local ord,prop;

    if NumberArgumentsFunction(fun)<>2 then
      return Error("Function for orderings has to have two arguments");
    fi;

    ord := Objectify(
            NewType( OrderingsFamily( fam ),
            IsAttributeStoringRep),rec());

    SetFamilyForOrdering(ord, fam);
    SetLessThanFunction(ord, fun);

    # now set the properties in list to true
    for prop in list do
      Setter(prop)(ord,true);
    od;

    return ord;
end);


######################################################################
##
#F  CreateOrderingByLteqFunction( <fam>, <fun>, <list> )
##
##  creates an orderings for the elements of the family fam
##  with LessThanOrequal given by <fun>
##  and with the properties list in <list>
##
BindGlobal("CreateOrderingByLteqFunction",
function( fam, fun, list)
    local ord,prop;

    if NumberArgumentsFunction(fun)<>2 then
      return Error("Function for orderings has to have two arguments");
    fi;

    ord := Objectify(
            NewType( OrderingsFamily( fam ),
            IsAttributeStoringRep),rec());

    SetFamilyForOrdering(ord, fam);
    SetLessThanOrEqualFunction(ord, fun);

    # now set the properties in list to true
    for prop in list do
      Setter(prop)(ord,true);
    od;

    return ord;
end);


######################################################################
##
#M  OrderingByLessThanFunctionNC( <fam>, <fun> )
##
InstallMethod( OrderingByLessThanFunctionNC,
  "for a family and a function", true,
  [IsFamily, IsFunction], 0,
  function(fam, fun)
    return CreateOrderingByLtFunction(fam,fun,[]);
  end);



InstallOtherMethod( OrderingByLessThanFunctionNC,
  "for a family, a function, and a list of properties", true,
  [IsFamily,IsFunction,IsList], 0,
  function(fam,fun,list)
    return CreateOrderingByLtFunction( fam,fun,list );
  end);


######################################################################
##
#M  OrderingByLessThanOrEqualFunctionNC( <fam>, <fun> )
##
InstallMethod( OrderingByLessThanOrEqualFunctionNC,
  "for a family and a function", true,
  [IsFamily, IsFunction], 0,
  function(fam, fun)
    return CreateOrderingByLteqFunction(fam,fun,[]);
  end);


InstallOtherMethod( OrderingByLessThanOrEqualFunctionNC,
  "for a family, a function, and a list of properties", true,
  [IsFamily,IsFunction,IsList], 0,
  function(fam,fun,list)
    return CreateOrderingByLteqFunction( fam,fun,list );
  end);


#############################################################################
##
#A  LessThanOrEqualFunction( <ord> )
##
InstallMethod( LessThanOrEqualFunction,
  "for an ordering which has a LessThanFunction", true,
  [IsOrdering and HasLessThanFunction], 0,
  function( ord)
    local fun;

    fun := function(x,y)
      return x=y or LessThanFunction(ord)(x,y);
    end;

    return fun;
end);


#############################################################################
##
#A  LessThanFunction( <ord> )
##
InstallMethod( LessThanFunction,
  "for an ordering which has a LessThanOrEqualFunction", true,
  [IsOrdering and HasLessThanOrEqualFunction], 0,
  function( ord)
    local fun;

    fun := function(x,y)
      return x<>y and LessThanOrEqualFunction(ord)(x,y);
    end;

    return fun;
end);


#############################################################################
##
#A  IsLessThanUnder( <ord>, <obj1>, <obj2> )
##
InstallMethod( IsLessThanUnder,
  "for an ordering ", true,
  [IsOrdering, IsObject,IsObject], 0,
  function( ord, obj1, obj2 )
    local fun;

    if FamilyObj(obj1)<>FamilyObj(obj2) then
      Error("Can only compare objects belonging to the same family");
    fi;
    if FamilyObj(ord)<>OrderingsFamily(FamilyObj(obj1)) then
      Error(ord," and ",obj1,obj2," do not have compatible families");
    fi;
    fun := LessThanFunction(ord);
    return fun(obj1,obj2);

end);


#############################################################################
##
#A  IsLessThanOrEqualUnder( <ord>,<obj1>, <obj2> )
##
InstallMethod( IsLessThanOrEqualUnder,
  "for an ordering and two objects ", true,
  [IsOrdering,IsObject,IsObject], 0,
  function( ord, obj1, obj2 )
    local fun;

    fun := LessThanOrEqualFunction(ord);
    return fun(obj1,obj2);

  end);


#############################################################################
##
#A  IsIncomparableUnder( <ord>,<obj1>, <obj2> )
##
##  for an ordering <ord> on the elements of the family of <el1> and <el2>.
##  Returns true if $el1\neq el2$i and  `IsLessThanUnder'(<ord>,<el1>,<el2>),
##  `IsLessThanUnder'(<ord>,<el2>,<el1>) are both false.
##  Returns false otherwise.
##  Notice that if obj1=obj2 then they are comparable
##
InstallMethod( IsIncomparableUnder,
  "for an ordering", true,
  [IsOrdering,IsObject,IsObject], 0,
  function(ord,obj1,obj2)
    local lteqfun;

    if FamilyObj(obj1)<>FamilyObj(obj2) then
      Error("`obj1' and `obj2' must belong to same family");
    fi;
    if not (FamilyObj(ord)=OrderingsFamily(FamilyObj(obj1))) then
      Error("`ord' is not an ordering in `OrderingsFamily(obj1)'");
    fi;

    # if we know that the ordering is total
    # then any pair of elements is comparable
    if HasIsTotalOrdering(ord) and IsTotalOrdering(ord) then
      return false;
    fi;

    lteqfun := LessThanOrEqualFunction( ord );
    # now check that neither obj1 is less than or equal to obj2
    # nor obj2 is less than or equal to obj1
    # Note that if obj1=obj2 then they are comparable!
    if (not lteqfun(obj1,obj2)) and (not lteqfun(obj2,obj1)) then
      return true;
    fi;
    return false;

end);


######################################################################
##
##  Orderings on families of associative words
##

#############################################################################
##
#M  LexicographicOrdering( <fam> )
#M  LexicographicOrdering( <fam>, <alphabet> )
#M  LexicographicOrdering( <fam>, <gensord> )
#M  LexicographicOrdering( <f> )
#M  LexicographicOrdering( <f>, <alphabet> )
#M  LexicographicOrdering( <f>, <gensord> )
#B  LexicographicOrderingNC( <fam>, <alphabet> )
##
##  LexicographicOrderingNC is the function that actually does the work
##
BindGlobal("LexicographicOrderingNC",
function(fam,alphabet)
    local ltfun,          # the less than function
          ord;            # the ordering

    ltfun := function(w1,w2)
      local i,x,y;

      for i in [1..Minimum(Length(w1),Length(w2))] do
        x := Subword(w1,i,i);
        y := Subword(w2,i,i);
        if Position(alphabet,x)< Position(alphabet,y) then
          return true;
        elif Position(alphabet,y)<Position(alphabet,x) then
          return false;
        fi;
      od;
      # at this time the shortest one is a prefix of the other one
      # or they are equal
      return Length(w1)<Length(w2);
    end;

    ord := OrderingByLessThanFunctionNC(fam,ltfun,[IsTotalOrdering,
        IsOrderingOnFamilyOfAssocWords]);
    SetIsTranslationInvariantOrdering(ord, false);
    SetOrderingOnGenerators(ord,alphabet);

    return ord;
end);


InstallOtherMethod( LexicographicOrdering,
  "for a family of words of a free semigroup or free monoid",
  true,
  [IsFamily and IsAssocWordFamily], 0,
  function(fam)
    local gens;         # the generating set

  # first find out if fam is a family of free semigroup or monoid
  # because we need to get a list of generators (in the default order)
  if IsBound(fam!.freeSemigroup) then
    gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
  elif IsBound(fam!.freeMonoid) then
    gens := GeneratorsOfMonoid(fam!.freeMonoid);
  else
    TryNextMethod();
  fi;

  return LexicographicOrderingNC(fam,gens);

end);


InstallMethod( LexicographicOrdering,
  "for a family of words of a free semigroup or free monoid and a list of generators",
  true,
  [IsFamily and IsAssocWordFamily,IsList and IsAssocWordCollection], 0,
  function(fam,alphabet)
    local gens;

  # first find out if fam is a family of free semigroup or monoid
  # because we need to get a list of generators (in the default order)
  if IsBound(fam!.freeSemigroup) then
    gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
  elif IsBound(fam!.freeMonoid) then
    gens := GeneratorsOfMonoid(fam!.freeMonoid);
  else
    TryNextMethod();
  fi;

  # now check that the elements of alphabet lie in the right family
  if ElementsFamily(FamilyObj(alphabet))<>fam then
    Error("Elements of `alphabet' should be in family `fam'");
  fi;

  # alphabet has to be a list of size Length(gens)
  # and all gens have to appear in the alphabet
  if Length(alphabet)<>Length(gens) or Set(alphabet)<>gens then
    Error("The list `alphabet' does not contain all generators");
  fi;

  return LexicographicOrderingNC(fam,alphabet);

end);


InstallOtherMethod( LexicographicOrdering,
  "for a family of words of a free semigroup or free monoid and a list",
  true,
  [IsFamily and IsAssocWordFamily,IsList], 0,
  function(fam,orderofgens)
    local gens,           # list of generators
          alphabet,       # list of gens in the appropriate ordering
          n;              # the size of the generating set

    # first find out if fam is a family of free semigroup or monoid
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    # we have to do some checking
    # orderofgens has to be a list of size Length(gens)
    # and all indexed of gens have to appear in the list
    n := Length(gens);
    if Length(orderofgens)<>n or Set(orderofgens)<>[1..n] then
      Error("`list' is not compatible with `fam'");
    fi;

    # we have to turn the list giving the order of gens
    # in a list of gens
    alphabet := List([1..Length(gens)],i->gens[orderofgens[i]]);

    return LexicographicOrderingNC(fam,alphabet);
end);


InstallOtherMethod( LexicographicOrdering,
  "for a free semigroup",
  true,
  [IsFreeSemigroup], 0,
  function(f)
    return LexicographicOrderingNC(ElementsFamily(FamilyObj(f)),
                                   GeneratorsOfSemigroup(f));
end);


InstallOtherMethod( LexicographicOrdering,
  "for a free monoid",
  true,
  [IsFreeMonoid], 0,
  function(f)
    return LexicographicOrderingNC(ElementsFamily(FamilyObj(f)),
                                   GeneratorsOfMonoid(f));
end);


InstallOtherMethod( LexicographicOrdering,
  "for a free semigroup and a list of generators",
  IsElmsColls,
  [IsFreeSemigroup,IsList and IsAssocWordCollection], 0,
  function(f,alphabet)
    return LexicographicOrdering(ElementsFamily(FamilyObj(f)),alphabet);
end);


InstallOtherMethod( LexicographicOrdering,
  "for a free monoid and a list of generators",
  IsElmsColls,
  [IsFreeMonoid,IsList and IsAssocWordCollection], 0,
  function(f,alphabet)
    return LexicographicOrdering(ElementsFamily(FamilyObj(f)),alphabet);
end);


InstallOtherMethod( LexicographicOrdering,
  "for a free semigroup and a list",
  true,
  [IsFreeSemigroup,IsList], 0,
  function(f,gensord)
    return LexicographicOrdering(ElementsFamily(FamilyObj(f)),gensord);
end);


InstallOtherMethod( LexicographicOrdering,
  "for a free monoid and a list",
  true,
  [IsFreeMonoid,IsList], 0,
  function(f,gensord)
    return LexicographicOrdering(ElementsFamily(FamilyObj(f)),gensord);
end);


#############################################################################
##
#M  ShortLexOrdering( <fam> )
#M  ShortLexOrdering( <fam>, <alphabet> )
#M  ShortLexOrdering( <fam>, <gensorder> )
#M  ShortLexOrdering( <f> )
#M  ShortLexOrdering( <f>, <alphabet> )
#M  ShortLexOrdering( <f>, <gensorder> )
#B  ShortLexOrderingNC ( <fam>, <alphabet> )
##
##  We implement these for families of elements of free smg and monoids
##  In the first form returns the ShortLexOrdering for the elements of fam
##  with the generators of the freeSmg (or freeMonoid) in the default order.
##  In the second form returns the ShortLexOrdering for the elements of fam
##  with the generators of the freeSmg (or freeMonoid) in the following order:
##  gens[i]<gens[j] if and only if orderofgens[i]<orderofgens[j]
##
BindGlobal("ShortLexOrderingNC",
function(fam,alphabet)
local ltfun, ord;

  # the less than function
  ltfun := function(w1,w2)

    # if w1=w2 then w1 is certainly not less than w2
    if w1=w2 then
      return false;
    fi;

    if Length(w1)<Length(w2) then
      return true;
    elif Length(w1)=Length(w2) then
      return IsLessThanUnder(LexicographicOrdering(fam,alphabet),w1,w2);
    fi;
    return false;
  end;

  ord := OrderingByLessThanFunctionNC(fam,ltfun,[IsTotalOrdering,
            IsReductionOrdering, IsShortLexOrdering,
            IsOrderingOnFamilyOfAssocWords]);
  SetOrderingOnGenerators(ord,alphabet);

  alphabet:=MakeImmutable(List(alphabet,i->GeneratorSyllable(i,1)));
  ord!.alphnums:=alphabet;
  if IsSSortedList(alphabet) then
    SetLetterRepWordsLessFunc(ord,function(a,b)
      if Length(a)<Length(b) then
        return true;
      elif Length(a)>Length(b) then
        return false;
      else
        return a<b;
      fi;
    end);
  else
    ord!.alphpos:=MakeImmutable(List([1..Maximum(alphabet)],i->Position(alphabet,i)));
    SetLetterRepWordsLessFunc(ord,function(a,b)
      if Length(a)<Length(b) then
        return true;
      elif Length(a)>Length(b) then
        return false;
      else
        return List(a,i->SignInt(i)*ord!.alphpos[AbsInt(i)])<
               List(b,i->SignInt(i)*ord!.alphpos[AbsInt(i)]);
      fi;
    end);
  fi;

  return ord;

end);


InstallOtherMethod( ShortLexOrdering,
  "for a family of words of a free semigroup or free  monoid", true,
  [IsFamily and IsAssocWordFamily], 0,
  function(fam)
    local gens;

    # first find out if fam is a family of free semigroup or monoid
    # because we need to get a list of generators (in the default order)
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    return ShortLexOrderingNC(fam,gens);
end);


InstallMethod( ShortLexOrdering,
  "for a family of words of a free semigroup or free monoid and a list of generators",
  true,
  [IsFamily and IsAssocWordFamily,IsList and IsAssocWordCollection], 0,
  function(fam,alphabet)

    local x,            # loop variable
          gens,         # the generators of the semigroup or monoid
          ltfun,        # the less than function of the ordering being built,
          ord;          # the ordering

    # first find out if fam is a family of free semigroup or monoid
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    # now check that the elements of alphabet lie in the right family
    if ElementsFamily(FamilyObj(alphabet))<>fam then
      Error("Elements of `alphabet' should be in family `fam'");
    fi;

    # alphabet has to be a list of size Length(gens)
    # and all gens have to appear in the alphabet
    if Length(alphabet)<>Length(gens) or Set(alphabet)<>gens then
      Error("`fam' and `alphabet' are not compatible");
    fi;

    # now build the ordering
    return ShortLexOrderingNC(fam,alphabet);

end);


InstallOtherMethod( ShortLexOrdering,
  "for a family of free words of a free semigroup or free  monoid and a list",
  true, [IsFamily and IsAssocWordFamily,IsList], 0,
  function(fam,orderofgens)

    local i,            # loop variable
          gens,         # the generators of the semigroup or monoid
          n,            # the length of the generators list
          alphabet;     # the gens in the desired order

    # first find out if fam is a family of free semigroup or monoid
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    # we have to do some checking
    # orderofgens has to be a list of size Length(gens)
    # and all gens have to appear in the list
    n := Length(gens);
    if Length(orderofgens)<>n or Set(orderofgens)<>[1..n] then
      Error("`fam' and `orderofgens' are not compatible");
    fi;

    # we have to turn the list giving the order of gens
    # in a list of gens
    alphabet := List([1..Length(gens)],i->gens[orderofgens[i]]);

    return ShortLexOrderingNC(fam,alphabet);
end);


InstallOtherMethod( ShortLexOrdering,
  "for a free semigroup", true,
  [IsFreeSemigroup], 0,
  f -> ShortLexOrderingNC(ElementsFamily(FamilyObj(f)),
        GeneratorsOfSemigroup(f)));


InstallOtherMethod( ShortLexOrdering,
  "for a free monoid", true,
  [IsFreeMonoid], 0,
  f -> ShortLexOrderingNC(ElementsFamily(FamilyObj(f)),GeneratorsOfMonoid(f)));


InstallOtherMethod( ShortLexOrdering,
  "for a free semigroup and a list of generators in the required order",
  IsElmsColls,
  [IsFreeSemigroup, IsList and IsAssocWordCollection], 0,
  function(f,alphabet)
    return ShortLexOrdering( ElementsFamily(FamilyObj(f)),alphabet);
  end);


InstallOtherMethod( ShortLexOrdering,
  "for a free monoid and a list of generators in the required order ",
  IsElmsColls,
  [IsFreeMonoid,IsList and IsAssocWordCollection], 0,
  function(f,alphabet)
    return ShortLexOrdering( ElementsFamily(FamilyObj(f)),alphabet);
  end);


InstallOtherMethod( ShortLexOrdering,
  "for a free semigroup and a list", true,
  [IsFreeSemigroup, IsList], 0,
  function(f,gensorder)
    return ShortLexOrdering( ElementsFamily(FamilyObj(f)),gensorder);
  end);


InstallOtherMethod( ShortLexOrdering,
  "for a free monoid and a list", true,
  [IsFreeMonoid,IsList], 0,
  function(f,gensorder)
    return ShortLexOrdering( ElementsFamily(FamilyObj(f)),gensorder);
  end);


#############################################################################
##
#F  IsShortLexLessThanOrEqual( <u>, <v> )
##
##  for two associative words <u> and <v>.
##  It returns true if <u> is less than or equal to <v>, with
##  respect to the shortlex ordering.
##  (the shortlex ordering is the default one given by u<=v)
##  (we have this function here to assure compatibility with gap4.2).
##
InstallGlobalFunction( IsShortLexLessThanOrEqual,
function( u, v )
  local fam,ord;

  fam := FamilyObj(u);
  ord := ShortLexOrdering(fam);

  return IsLessThanOrEqualUnder(ord,u,v);
end);


#############################################################################
##
#M  WeightLexOrdering( <fam>,<alphabet>,<wt>)
#M  WeightLexOrdering( <fam>,<gensord>,<wt>)
#M  WeightLexOrdering( <f>,<wt>,<alphabet>)
#M  WeightLexOrdering( <f>,<wt>,<gensord>)
#B  WeightLexOrderingNC( <fam>,<alphabet>,<wt>)
##
BindGlobal("WeightLexOrderingNC",
function(fam,alphabet,wt)
  local wordwt,       # function that given a word returns its weight
        ltfun,        # the less than function
        auxalph,
        ord;          # the ordering

  #########################################################
  # this is a function that given a word returns its weight
  wordwt := function(w)
    local i, sum;
    sum := 0;
    for i in [1..Length(alphabet)] do
      sum := sum + ExponentSumWord(w,alphabet[i])*wt[i];
    od;
    return sum;
  end;

  # the less than function
  ltfun := function(w1,w2)
    local w1wt,w2wt;        # the weights of words w1 and w2, resp

    # if w1=w2 then w1 is certainly not less than w2
    if w1=w2 then
      return false;
    fi;

    # then if the sum of the weights of w1 is less than
    # the sum of the weight of w2 then returns true
    # so we calculate the weight of w1
    w1wt := wordwt(w1);
    w2wt := wordwt(w2);
    if w1wt<w2wt then
      return true;
    elif w1wt=w2wt then
      return IsLessThanUnder(LexicographicOrdering(fam,alphabet),w1,w2);
    fi;
    return false;
  end;

  ord := OrderingByLessThanFunctionNC(fam,ltfun,[IsTotalOrdering,
            IsReductionOrdering, IsWeightLexOrdering,
            IsOrderingOnFamilyOfAssocWords]);
  SetOrderingOnGenerators(ord,alphabet);
  SetWeightOfGenerators(ord,wt);

  auxalph := ShallowCopy(alphabet);
  auxalph := List(auxalph,i->GeneratorSyllable(i,1));
  ord!.alphnums:=auxalph;
  if IsSSortedList(auxalph) then
    SetLetterRepWordsLessFunc(ord,function(a,b)
      local wa,wb;
      wa:=Sum(a,i->wt[i]);
      wb:=Sum(b,i->wt[i]);
      if wa<wb then
        return true;
      elif wa>wb then
        return false;
      else
        return a<b;
      fi;
    end);
  else
    ord!.alphpos:=List([1..Maximum(auxalph)],i->Position(auxalph,i));
    SetLetterRepWordsLessFunc(ord,function(a,b)
      local wa,wb;
      wa:=Sum(a,i->wt[i]);
      wb:=Sum(b,i->wt[i]);
      if wa<wb then
        return true;
      elif wa>wb then
        return false;
      else
        return List(a,i->SignInt(i)*ord!.alphpos[AbsInt(i)])<
               List(b,i->SignInt(i)*ord!.alphpos[AbsInt(i)]);
      fi;
    end);
  fi;

  return ord;

end);


InstallMethod( WeightLexOrdering,
  "for a family of words of a free semigroup or free monoid, a list of generators and a list of weights",
  true,
  [IsFamily and IsAssocWordFamily,IsList and IsAssocWordCollection, IsList], 0,
  function(fam,alphabet,wt)

    local x,            # loop variable
          gens,         # the generators of the semigroup or monoid
          ltfun,        # the less than function of the ordering being built,
          w1wt,w2wt,    # the weights of w1 and w2, resp
          ord;          # the ordering

    # first find out if fam is a family of free semigroup or monoid
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    # now check that the elements of alphabet lie in the right family
    if ElementsFamily(FamilyObj(alphabet))<>fam then
      Error("Elements of `alphabet' should be in family `fam'");
    fi;

    # alphabet and wt both have to be lists of size Length(gens)
    # and all gens have to appear in the alphabet
    if Length(alphabet)<>Length(gens) or Length(wt)<>Length(gens)
          or Set(alphabet)<> gens then
      Error("`alphabet' and `wt' are not compatible with `fam'");
    fi;

    return WeightLexOrderingNC(fam,alphabet,wt);
end);


InstallOtherMethod( WeightLexOrdering,
  "for a family of words of a free semigroup or free monoid, and two lists",
  true, [IsFamily and IsAssocWordFamily,IsList,IsList], 0,
  function(fam,orderofgens,wt)

  local gens,         # the generators of the semigroup or monoid
        alphabet;     # the gens in the desired order

  # first find out if fam is a family of free semigroup or monoid
  if IsBound(fam!.freeSemigroup) then
    gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
  elif IsBound(fam!.freeMonoid) then
    gens := GeneratorsOfMonoid(fam!.freeMonoid);
  else
    TryNextMethod();
  fi;

  # alphabet and wt both have to be lists of size Length(gens)
  # and all gens have to appear in the alphabet
  if Length(orderofgens)<>Length(gens) or Length(wt)<>Length(gens)
    or Set(orderofgens)<> [1..Length(gens)] then
    Error("`orderofgens' and `wt' are not compatible with `fam'");
  fi;

  # we have to turn the list giving the order of gens
  # in a list of gens
  alphabet := List([1..Length(gens)],i->gens[orderofgens[i]]);

  return WeightLexOrderingNC(fam,alphabet,wt);
end);


InstallOtherMethod( WeightLexOrdering,
  "for a free semigroup, a list of generators and a list of weights",
  true,
  [IsFreeSemigroup,IsList and IsAssocWordCollection,IsList], 0,
  function(f,alphabet,wt)
    return WeightLexOrdering( ElementsFamily(FamilyObj(f)),alphabet,wt);
  end);


InstallOtherMethod( WeightLexOrdering,
  "for a free monoid, a list of generators and a list of weights",
  true,
  [IsFreeMonoid,IsList and IsAssocWordCollection,IsList], 0,
  function(f,alphabet,wt)
    return WeightLexOrdering( ElementsFamily(FamilyObj(f)),alphabet,wt);
  end);


InstallOtherMethod( WeightLexOrdering,
  "for a free semigroup, a list giving ordering on generators and a list of weights",
  true,
  [IsFreeSemigroup,IsList,IsList], 0,
  function(f,orderofgens,wt)
    return WeightLexOrdering( ElementsFamily(FamilyObj(f)),orderofgens,wt);
  end);

InstallOtherMethod( WeightLexOrdering,
  "for a free monoid, a list giving ordering on generators and a list of weights",
  true,
  [IsFreeMonoid,IsList,IsList], 0,
  function(f,orderofgens,wt)
    return WeightLexOrdering( ElementsFamily(FamilyObj(f)),orderofgens,wt);
  end);


#############################################################################
##
#M  BasicWreathProductOrdering( <fam> )
#M  BasicWreathProductOrdering( <fam>, <alphabet>)
#M  BasicWreathProductOrdering( <fam>, <gensord>)
#M  BasicWreathProductOrdering( <f>)
#M  BasicWreathProductOrdering( <f>, <alphabet>)
#M  BasicWreathProductOrdering( <f>, <gensord>)
#B  BasicWreathProductOrderingNC( <fam>, <alphabet>)
##
##  We implement these for families of elements of free smg and monoids
##  In the first form returns the BasicWreathProductOrdering for the
##  elements of fam with the generators of the freeSmg (or freeMonoid)
##  in the default order.
##  In the second form returns the BasicWreathProductOrdering for the
##  elements of fam with the generators of the freeSmg (or freeMonoid)
##  in the following order:
##  gens[i]<gens[j] if and only if orderofgens[i]<orderofgens[j]
##
##  So with the given order on the generators
##  u<v if u'<v' where u=xu'y and v=xv'y
##  So, if u and v have no common prefix, u is less than v wrt this ordering if
##    (i) maxletter(v) > maxletter(u); or
##   (ii) maxletter(u) = maxletter(v) and
##        #maxletter(u) < #maxletter(v); or
##  (iii) maxletter(u) = maxletter(v) =b and
##        #maxletter(u) = #maxletter(v) and
##        if u = u1 * b * u2 * b ... b * uk
##           v = v1 * b * v2 * b ... b * vk
##        then u1<v1 in the basic wreath product ordering.
##
BindGlobal("BasicWreathProductOrderingNC",
function(fam,alphabet)
  local ltfun,            # the less than function
        oltfun,
        nltfun,
        alphpos,
        ord;              # the ordering

  nltfun := function(u,v)
    local l,eu,ev,mp,np,me,ne;

    eu:=ExtRepOfObj(u);
    ev:=ExtRepOfObj(v);
    if eu=ev then
      return false;
    fi;
    # find the longest common prefix
    l:=1;
    while l<=Length(eu) and l<=Length(ev) and eu[l]=ev[l] do
      l:=l+1;
    od;
    l:=l-1;

    if l<>0 or (l=0 and (IsEmpty(eu) or IsEmpty(ev))) then
      if IsEvenInt(l) then
        # disagree on generator or ran out
        # if u is a proper prefix of v (ie l=|u|) then u<v
        if Length(eu)=l then
          return true;
        # but if v is a proper prefix of u then u>v
        elif Length(ev)=l then
          return false;
        fi;
        eu:=eu{[l+1..Length(eu)]};
        ev:=ev{[l+1..Length(ev)]};
      elif SignInt(eu[l+1])=SignInt(ev[l+1]) then
        # disagree on exponent
        # if u is a proper prefix of v (ie l=|u|) then u<v
        if Length(eu)=l+1 and AbsInt(eu[l+1])<AbsInt(ev[l+1]) then
          return true;
        # but if v is a proper prefix of u then u>v
        elif Length(ev)=l+1 and AbsInt(eu[l+1])>AbsInt(ev[l+1]) then
          return false;
        fi;
        if AbsInt(eu[l+1])<AbsInt(ev[l+1]) then
          ev:=ev{[l..Length(ev)]};
          ev[2]:=ev[2]-eu[l+1];
          eu:=eu{[l+2..Length(eu)]};
        else
          eu:=eu{[l..Length(eu)]};
          eu[2]:=eu[2]-ev[l+1];
          ev:=ev{[l+2..Length(ev)]};
        fi;
      else
        eu:=eu{[l..Length(eu)]};
        ev:=ev{[l..Length(ev)]};
      fi;
    fi;
    # now eu and ev don't have a common prefix.

    #T the code now assumes that all exponents are positive. If we use free
    #T groups, this needs to be cleaned up
    mp:=Length(eu)-1;
    np:=Length(ev)-1;
    me:=eu[mp+1];
    ne:=ev[np+1];
    while mp>0 and np>0 do
      if ord!.alphpos[ev[np]]<ord!.alphpos[eu[mp]] then
        ne:=ne-1;
        if ne=0 then
          np:=np-2;
          if np>0 then
            ne:=ev[np+1];
          fi;
        fi;
      elif ord!.alphpos[eu[mp]]<ord!.alphpos[ev[np]] then
        me:=me-1;
        if me=0 then
          mp:=mp-2;
          if mp>0 then
            me:=eu[mp+1];
          fi;
        fi;
      else
        ne:=ne-1;
        if ne=0 then
          np:=np-2;
          if np>0 then
            ne:=ev[np+1];
          fi;
        fi;
        me:=me-1;
        if me=0 then
          mp:=mp-2;
          if mp>0 then
            me:=eu[mp+1];
          fi;
        fi;
      fi;
    od;

    return mp<=0 and np<>0;
  end;

  ########
  #
  # this is obsolete but for tests

  oltfun := function(u,v)
    local l,m,n,ltgens;

    # we start by building the function that gives the order on the alphabet
    ltgens := function(x,y)
      return Position(alphabet,x)< Position(alphabet,y);
    end;

    if u=v then
      return false;
    fi;

    l := LengthOfLongestCommonPrefixOfTwoAssocWords( u, v);
    if l<>0 then
      # if u is a proper prefix of v (ie l=|u|) then u<v
      # but if v is a proper prefix of u then u>v
      if l=Length(u) then
        return true;
      elif l=Length(v) then
        return false;
      fi;

      # at this stage none of the words is a proper prefix of the other one
      # so remove the common prefix from both words
      u := Subword( u, l+1, Length(u) );
      v := Subword( v, l+1, Length(v) );
    fi;

    m := Length( u );
    n := Length( v );

    # so now u and v have no common prefixes
    # (in particular they are not equal)

    while m>0 and n>0 do
      if ltgens(Subword( v, n, n),Subword( u, m, m)) then
        n := n - 1;
      elif ltgens(Subword( u, m, m),Subword( v, n, n)) then
        m := m - 1;
      else
        m := m - 1;
        n := n - 1;
      fi;
    od;

    return m =0 and n<>0;
  end;

  ltfun:=function(u,v)
  local x,y;
    x:=oltfun(u,v);
    y:=nltfun(u,v);
    if x=y then
      return x;
    else
      Error("disagree");
    fi;
  end;

  if AssertionLevel()=0 then
    ltfun:=nltfun;
  fi;


  ord := OrderingByLessThanFunctionNC(fam,ltfun,[IsTotalOrdering,
            IsBasicWreathProductOrdering,
            IsOrderingOnFamilyOfAssocWords, IsReductionOrdering]);
  SetOrderingOnGenerators(ord,alphabet);

  alphpos:=List(alphabet,i->GeneratorSyllable(i,1));
  ord!.alphpos:=List([1..Maximum(alphpos)],i->Position(alphpos,i));

  return ord;

end);


InstallOtherMethod(BasicWreathProductOrdering,
  "for a family of words of a free semigroup or free monoid and a list",
  true, [IsAssocWordFamily and IsFamily], 0,
  function(fam)
    local gens;       # the generators list

    # first find out if fam is a family of free semigroup or monoid
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    return BasicWreathProductOrderingNC(fam,gens);
end);


InstallMethod(BasicWreathProductOrdering,
  "for a family of words of a free semigroup or free monoid and a list of generators",
  true, [IsAssocWordFamily and IsFamily, IsList and IsAssocWordCollection], 0,
  function(fam,alphabet)
    local gens;       # the generators of the semigroup or monoid

    # first find out if fam is a family of free semigroup or monoid
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    # we have to do some checking
    # alphabet has to be a list of size Length(gens)
    # all gens have to appear in the list
    if Length(alphabet)<>Length(gens) or Set(alphabet)<>gens then
      Error("`alphabet' is not compatible with `fam'");
    fi;

    return BasicWreathProductOrderingNC(fam,alphabet);

end);


InstallMethod(BasicWreathProductOrdering,
  "for a family of words of a free semigroup or free monoid and a list",
  true, [IsAssocWordFamily and IsFamily, IsList], 0,
  function(fam,orderofgens)
    local gens,       # the generators of the semigroup or monoid
          n,          # the length of the generators list
          alphabet;   # the generators in the appropriate order

    # first find out if fam is a family of free semigroup or monoid
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    # we have to do some checking
    # orderofgens has to be a list of size Length(gens)
    # all gens have to appear in the list
    n := Length(gens);
    if Length(orderofgens)<>n or Set(orderofgens)<>[1..n] then
      Error("`orderofgens' is not compatible with `fam'");
    fi;

    # we have to turn the list giving the order of gens
    # in a list of gens
    alphabet := List([1..Length(gens)],i->gens[orderofgens[i]]);

    return BasicWreathProductOrderingNC(fam,alphabet);

end);


InstallOtherMethod(BasicWreathProductOrdering,
  "for a free semigroup", true,
  [IsFreeSemigroup], 0,
  f-> BasicWreathProductOrderingNC(ElementsFamily(FamilyObj(f)),
          GeneratorsOfSemigroup(f)));


InstallOtherMethod(BasicWreathProductOrdering,
  "for a free monoid", true,
  [IsFreeMonoid], 0,
  f-> BasicWreathProductOrderingNC(ElementsFamily(FamilyObj(f)),
          GeneratorsOfMonoid(f)));


InstallOtherMethod(BasicWreathProductOrdering,
  "for a free semigroup and a list of generators", true,
  [IsFreeSemigroup,IsList and  IsAssocWordCollection], 0,
  function(f,alphabet)
    return BasicWreathProductOrdering(ElementsFamily(FamilyObj(f)),alphabet);
  end);


InstallOtherMethod(BasicWreathProductOrdering,
  "for a free monoid and a list of generators", true,
  [IsFreeMonoid,IsList and IsAssocWordCollection], 0,
  function(f,alphabet)
    return BasicWreathProductOrdering(ElementsFamily(FamilyObj(f)),alphabet);
  end);


InstallOtherMethod(BasicWreathProductOrdering,
  "for a free semigroup and a list", true,
  [IsFreeSemigroup,IsList], 0,
  function(f,gensorder)
    return BasicWreathProductOrdering(ElementsFamily(FamilyObj(f)),gensorder);
  end);


InstallOtherMethod(BasicWreathProductOrdering,
  "for a free monoid and a list", true,
  [IsFreeMonoid,IsList], 0,
  function(f,gensorder)
    return BasicWreathProductOrdering(ElementsFamily(FamilyObj(f)),gensorder);
  end);


#############################################################################
##
#F  IsBasicWreathLessThanOrEqual( <u>, <v> )
##
##  for two associative words <u> and <v>.
##  It returns true if <u> is less than or equal to <v>, with
##  respect to the basic wreath product ordering.
##  (we have this function here to assure compatibility with gap4.2).
##
InstallGlobalFunction( IsBasicWreathLessThanOrEqual,
function( u, v )
  local fam,ord;

  fam := FamilyObj(u);
  ord := BasicWreathProductOrdering(fam);

  return IsLessThanOrEqualUnder(ord,u,v);
end);


#############################################################################
##
#M  WreathProductOrdering( <fam>, <levels> )
#M  WreathProductOrdering( <fam>, <gensord>, <levels>)
#M  WreathProductOrdering( <f>, <levels>)
#M  WreathProductOrdering( <f>, <gensord>, <levels>)
##
##  We implement these for families of elements of free smg and monoids
##  In the first form returns the WreathProductOrdering for the
##  elements of fam with the generators of the freeSmg (or freeMonoid)
##  in the default order.
##  In the second form returns the WreathProductOrdering for the
##  elements of fam with the generators of the freeSmg (or freeMonoid)
##  in the following order:
##  gens[i]<gens[j] if and only if orderofgens[i]<orderofgens[j]
##
##  <levels> is a list of length equal to the number of generators,
##  specifying the levels of the generators IN THEIR NEW ORDERING,
##  That is, levels[i] is the level of the generator that comes i-th
##  in the new ordering.
##
##  So with the given order on the generators
##  u<v if u'<v' where u=xu'y and v=xv'y
##  So, if u and v have no common prefix, u is less than v wrt this ordering if
##    (i) u_max < v_max in the shortlex ordering, where u_max, v_max are
##        the words obtained from u, v by removing all letters that do not
##        the highest level, or
##   (ii) u_max = v_max and
##        if u = u1 * u_m1 * u2 * u_m2 ... b * u_mk
##           v = v1 * v_m1 * v2 * v_m2 ... b * v_mk
##           where u_mi, v_mi are the maximal subwords of u, v containing
##           only the letters of maximal weight
##           (so u_max = u_m1 * u_m2 * ... * u_mk = v_m1 * v_m2 * ... * v_mk),
##           then u1<v1 in the wreath product ordering.
##
InstallOtherMethod(WreathProductOrdering,
  "for a family of words of a free semigroup or free monoid and a list",
  true, [IsAssocWordFamily and IsFamily,IsList], 0,
  function(fam, levels)
    local gens;

    # first find out if fam is a family of free semigroup or monoid
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    return WreathProductOrdering(fam,[1..Length(gens)],levels);
end);

InstallMethod(WreathProductOrdering,
  "for a family of words of a free semigroup or free monoid and a list",
  true, [IsAssocWordFamily and IsFamily, IsList, IsList], 0,
  function(fam,orderofgens,levels)
    local i,  # loop variable
       gens,  # the generators of the semigroup or monoid
     ltgens,  # the function giving the order on the alphabet
      ltfun,  # the less than function
        ord;  # the ordering

    # first find out if fam is a family of free semigroup or monoid
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    # we have to do some checking
    # orderofgens has to be a list of size Length(gens)
    if Length(orderofgens)<>Length(gens) then
      TryNextMethod();
    fi;
    # all gens have to appear in the list
    for i in [1..Length(orderofgens)] do
      if not i in orderofgens then
        TryNextMethod();
      fi;
    od;

  # now we build the less than function for the ordering
  ltfun := function(u,v)
    local l,  #length of common prefix of u,v
          m,  #current position in scan of u (from right)
          n,  #current position in scan of v (from right)
       ug, vg,  #Current generators of u, v
   ug_lev, vg_lev,  #levels of urrent generators of u, v
     sl_lev,  #level at which one of the words  u,v  is
        #smaller in the shortlex ordering
                     sl,  #sl=1 or 2 if u or v, resp., is
        #smaller in the shortlex ordering at level sl_lev.
        #note sl=0 <=> sl_lev=0.
          levgens;  #functions on generators

    # we start by building the function that gives the order on
    # the alphabet
    # we construct it from the list <orderofgens>
    ltgens := function(x,y)
      return Position(orderofgens,Position(gens,x))<
          Position(orderofgens,Position(gens,y));
    end;

    #and similarly for the level function on the alphabet
    levgens := function(x)
      return levels[Position(orderofgens,Position(gens,x))];
    end;

    if u=v then
      return false;
    fi;

    if Length(u)=0 then
      return true;
    fi;
    if Length(v)=0 then
      return false;
    fi;

    l := LengthOfLongestCommonPrefixOfTwoAssocWords( u, v);
    if l<>0 then
      # if u is a proper prefix of v (ie l=|u|) then u<v
      # but if v is a proper prefix of u then u>v
      if l=Length(u) then
        return true;
      elif l=Length(v) then
        return false;
      fi;

    # at this stage none of the words is a proper prefix of the
    # other one so remove the common prefix from both words
      u := Subword( u, l+1, Length(u) );
      v := Subword( v, l+1, Length(v) );
    fi;

    # so now u and v have no common prefixes
    # (in particular they are not equal)

    m := Length( u );
      n := Length( v );
    sl_lev := 0;
    sl := 0;

    #We now start scanning u,v from right to left.
    #sl_lev denotes the level of the block of generators
    #which is currently distinguishing between u,v.
    #sl = 1 or 2 if u or v is smaller, respectively, in this block.
    #Initially sl_lev=sl=0. This can also occur later if either
    # (i) we read two equal generators in u,v at a higher level
    #     than sl_lev. Then everything to the right of these
    #     equal generators becomes irrelevant.
    #(ii) we read a generator in u or v at a higher level than
    #     sl_lev that is not matched by a generator at the same
    #     level in the other word. We keep scanning backwards
    #     along the other word until we find a generator of the
    #     corresponding level or higher, but keep sl_lev=sl=0
    #     while we are doing this.
    while m>0 or n>0 do
                        #Print(m,n,sl,sl_lev,"\n");
      if m<>0 then
          ug := Subword(u,m,m);
          ug_lev := levgens(ug);
      fi;
      if n<>0 then
          vg := Subword(v,n,n);
          vg_lev := levgens(vg);
      fi;
        if m = 0 then
          #we have reached the beginning of u, but
          #u might be ahead in shortlex at sl_lev
            if  sl <> 2 or vg_lev >= sl_lev then
        #u is certainly smaller
        return true;
          fi;
          #u is ahead in shortlex at sl_lev, so keep
          #scanning v
          n := n-1;
        elif n = 0 then
          #we have reached the beginning of v, but
          #v might be ahead in shortlex at sl_lev
            if  sl <> 1 or ug_lev >= sl_lev then
        #v is certainly smaller
        return false;
          fi;
          #v is ahead in shortlex at sl_lev, so keep
          #scanning u.
          m := m-1;
      elif vg_lev < ug_lev and sl_lev <= ug_lev then
          #u is now at a higher level than v
          n := n - 1;
          if sl_lev < ug_lev then
        #we are in situation (ii) (see above)
            sl_lev := 0;
            sl := 0;
          fi;
      elif ug_lev < vg_lev and sl_lev <= vg_lev  then
          #v is now at a higher level than u
          m := m - 1;
          if sl_lev < vg_lev then
        #we are in situation (ii) (see above)
            sl_lev := 0;
            sl := 0;
          fi;
      elif ug_lev = vg_lev and sl_lev <= vg_lev  then
          #u and v are at same level so use shortlex
          if ltgens(ug,vg) then
        sl := 1;
            sl_lev := ug_lev;
          elif ltgens(vg,ug) then
        sl := 2;
            sl_lev := ug_lev;
          elif sl_lev < ug_lev then
              #u and v are equal at this higher level.
        #everything to the right of u,v is now
        #irrelevant we are in situation (i) above.
        sl := 0;
            sl_lev := 0;
          fi;
          m := m - 1;
          n := n - 1;
      else
          #ug and vg are both at a lower level than sl_lev,
          #so can be ignored.
          m := m-1;
          n := n-1;
      fi;
    od;

    #We have reached the ends of both words, so sl tells us
    #which is the smaller.
    if sl = 1 then
      return true;
    elif sl = 2 then
      return false;
    else
      Error("There is a bug in WreathProductOrdering!");
    fi;
  end;

    ord := OrderingByLessThanFunctionNC(fam,ltfun,[IsTotalOrdering,
              IsWreathProductOrdering,
      IsOrderingOnFamilyOfAssocWords, IsReductionOrdering]);
    SetOrderingOnGenerators(ord,orderofgens);
    SetLevelsOfGenerators(ord,List([1..Length(gens)],j->
        levels[Position(orderofgens,j)]) );

    return ord;

end);

InstallOtherMethod(WreathProductOrdering,
  "for a family of associative words, a list of generators and a list with the levels of the generators", true,
  [IsAssocWordFamily,IsList and IsAssocWordCollection,IsList], 0,
  function(fam,alphabet,levels)
    local gens,gensord,n;

    # first find out if fam is a family of free semigroup or monoid
    if IsBound(fam!.freeSemigroup) then
      gens := GeneratorsOfSemigroup(fam!.freeSemigroup);
    elif IsBound(fam!.freeMonoid) then
      gens := GeneratorsOfMonoid(fam!.freeMonoid);
    else
      TryNextMethod();
    fi;

    # we have to do some checking
    # alphabet has to be a list of size Length(gens)
    # all gens have to appear in the list
    n := Length(gens);
    if Length(alphabet)<>n or Set(alphabet)<>gens then
      Error("`alphabet' is not compatible with `fam'");
    fi;

    # we have to turn the `alphabet' to a list giving the order of gens
    gensord := List([1..Length(gens)],i-> Position(gens,alphabet[i]));

    return WreathProductOrdering(fam,gensord,levels);
  end);

InstallOtherMethod(WreathProductOrdering,
  "for a free monoid and a list", true,
  [IsFreeMonoid,IsList,IsList], 0,
  function(f,gensorder,levels)
    return WreathProductOrdering(ElementsFamily(FamilyObj(f)),gensorder,levels);
  end);

InstallOtherMethod(WreathProductOrdering,
  "for a free semigroup", true,
  [IsFreeSemigroup,IsList], 0,
  function(f,levels)
        return WreathProductOrdering(ElementsFamily(FamilyObj(f)),levels);
  end);

InstallOtherMethod(WreathProductOrdering,
  "for a free monoid", true,
  [IsFreeMonoid,IsList], 0,
  function(f,levels)
        return WreathProductOrdering(ElementsFamily(FamilyObj(f)),levels);
  end);

InstallOtherMethod(WreathProductOrdering,
  "for a free semigroup and a list", true,
  [IsFreeSemigroup,IsList,IsList], 0,
  function(f,gensorder,levels)
    return WreathProductOrdering(ElementsFamily(FamilyObj(f)),gensorder,levels);
  end);

InstallOtherMethod(WreathProductOrdering,
  "for a free monoid and a list", true,
  [IsFreeMonoid,IsList,IsList], 0,
  function(f,gensorder,levels)
    return WreathProductOrdering(ElementsFamily(FamilyObj(f)),gensorder,levels);
  end);
